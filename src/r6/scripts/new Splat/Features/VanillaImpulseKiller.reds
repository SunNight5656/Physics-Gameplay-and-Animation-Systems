module RealisticPush

public func RFC_IsMeleeLike(atkType: gamedataAttackType) -> Bool {
  let t: Int32 = EnumInt(atkType);
  return t == EnumInt(gamedataAttackType.Melee)
      || t == EnumInt(gamedataAttackType.QuickMelee)
      || t == EnumInt(gamedataAttackType.StrongMelee);
}

private func RFC_PF_Now(p: wref<GameObject>) -> Float {
  return EngineTime.ToFloat(GameInstance.GetSimTime(p.GetGame()));
}

private func RFC_BlockVanillaStumbleSlam(hr: ref<HitReactionComponent>, outImpulse: Float, frameImpulse: Float) -> Bool {
  if outImpulse <= 0.0 {
    return false;
  }

  // These thresholds are intentionally conservative.
  // They only trigger on large impulse stacking events.
  if frameImpulse >= 8.0 && hr.m_cumulatedPhysicalImpulse >= 8.0 {
    return true;
  }

  return false;
}

@wrapMethod(HitReactionComponent)
public final func GetPhysicalImpulse(
  attackData: ref<AttackData>,
  hitPosition: Vector4,
  out frameImpulse: Float
) -> Float {
  let c: RFCConfig = RFC.Cfg();
  let outImpulse: Float;

  // True Vanilla Mode keeps the game's original hit and death behavior.
  if c.vanillaMode {
    return wrappedMethod(attackData, hitPosition, frameImpulse);
  }

  let npc: ref<NPCPuppet> = this.GetOwner() as NPCPuppet;

  // v1705: a selected per-weapon Vanilla toggle restores the GAME'S OWN
  // physical impulse for this attack. This must run before stagger/popfix,
  // killImpulsesEverywhere, and SPLAT's large-impulse clamp or the native
  // impulse is already zeroed before the exception can help.
  //
  // The OnHit wrapper arms the NPC before calling the native method. The direct
  // AttackData check is retained as a fallback for call orders where the
  // HitReactionComponent is queried independently.
  let directLane: Int32 =
    RFC_VanillaWeaponLaneForAttack(attackData, c);

  if RFC_VanillaWeaponReactionArmed(npc)
    || (
      directLane > 0
      && RFC_VanillaWeaponLaneEnabled(directLane, c)
    ) {
    // IMPORTANT: selected lane means SPLAT does NOTHING to physical impulse.
    // This is the game's original GetPhysicalImpulse result, untouched.
    let nativeImpulse: Float =
      wrappedMethod(attackData, hitPosition, frameImpulse);

    // Selected lane means SPLAT does nothing to physical impulse.
    // Return the game's own GetPhysicalImpulse result untouched.
    return nativeImpulse;
  }

  // Preserve the old stagger-window protection independently of the optional
  // PopFix menu. Native ranged impulse must not stack with SPLAT during the
  // incapacitation/death handoff, even when selected vanilla impulses are on.
  if IsDefined(npc) {
    let nowT: Float = RFC_PF_Now(npc);

    if !npc.IsDead() && npc.IsIncapacitated() {
      npc.rfc_pf_staggerUntil = nowT + RFC_ClampT(c.popFix_latchStagger);
    }

    if npc.rfc_pf_staggerUntil > nowT && IsDefined(attackData) {
      let at: gamedataAttackType = attackData.GetAttackType();
      if AttackData.IsRangedOrDirect(at) {
        frameImpulse = 0.0;
        this.m_cumulatedPhysicalImpulse = 0.0;
        this.m_ragdollImpulse = 0.0;
        return 0.0;
      }
    }
  }

  // Vehicle occupants keep the normal hit/death animation, but receive no
  // physical push while the dedicated vehicle kill toggle is active.
  if c.killImpulsesVehiclesOnly && IsDefined(this.m_ownerNPC) && RFC_IsVehicleContext(this.m_ownerNPC) {
    frameImpulse = 0.0;
    this.m_cumulatedPhysicalImpulse = 0.0;
    this.m_ragdollImpulse = 0.0;
    return 0.0;
  }

  // v1703: melee is no longer passed through unconditionally.
  // Blunt and Blade now obey the same per-weapon Vanilla exception as firearms.

  // Hard stop for vanilla physical impulse leaks.
  // c.vanillaImpulsesEnabled is automatically true when ANY per-weapon Vanilla
  // toggle is enabled, so visible weapon toggles can no longer be inert behind
  // a forgotten master switch.
  if !c.vanillaImpulsesEnabled {
    frameImpulse = 0.0;
    this.m_cumulatedPhysicalImpulse = 0.0;
    this.m_ragdollImpulse = 0.0;
    return 0.0;
  }

  // Kill impulses for everything else (ranged, explosions, etc.)
  if c.killImpulsesEverywhere {

    // Safety fallback: matching weapon = exact native impulse.
    if c.vanillaImpulsesEnabled
      && attackData != null
      && RFC_VanillaImpulseAllowedByWeapon(attackData, c) {
      return wrappedMethod(attackData, hitPosition, frameImpulse);
    }

    frameImpulse = 0.0;
    this.m_cumulatedPhysicalImpulse = 0.0;
    this.m_ragdollImpulse = 0.0;
    return 0.0;
  }

  // Fallback: vanilla
  outImpulse = wrappedMethod(attackData, hitPosition, frameImpulse);

  if RFC_BlockVanillaStumbleSlam(this, outImpulse, frameImpulse) {
    frameImpulse = 0.0;
    this.m_cumulatedPhysicalImpulse = 0.0;
    this.m_ragdollImpulse = 0.0;
    return 0.0;
  }

  return outImpulse;
}


// -----------------------------------------------------------------------------
// Per-weapon Vanilla lanes.
//
// The selected weapon is classified ONCE and stored on the NPC. Every later
// SPLAT gate reads that same lane instead of independently trying to infer the
// weapon again during nested hit/death callbacks.
//
// Lane IDs:
//   0 = none
//   1 = Handgun
//   2 = Magnum
//   3 = Shotgun
//   4 = Sniper
//   5 = SMG
//   6 = Assault Rifle
//   7 = LMG
//   8 = Blunt
//   9 = Blade
// -----------------------------------------------------------------------------

public func RFC_VanillaWeaponLaneEnabled(
  lane: Int32,
  cfg: RFCConfig
) -> Bool {
  switch lane {
    case 1: return cfg.vanillaAllowHandgun;
    case 2: return cfg.vanillaAllowMagnum;
    case 3: return cfg.vanillaAllowShotgun;
    case 4: return cfg.vanillaAllowSniper;
    case 5: return cfg.vanillaAllowSMG;
    case 6: return cfg.vanillaAllowAR;
    case 7: return cfg.vanillaAllowLMG;
    case 8: return cfg.vanillaAllowBlunt;
    case 9: return cfg.vanillaAllowBlade;
  };

  return false;
}

private func RFC_VanillaOnlyEnabledRangedLane(cfg: RFCConfig) -> Int32 {
  let count: Int32 = 0;
  let lane: Int32 = 0;

  if cfg.vanillaAllowHandgun { count += 1; lane = 1; };
  if cfg.vanillaAllowMagnum  { count += 1; lane = 2; };
  if cfg.vanillaAllowShotgun { count += 1; lane = 3; };
  if cfg.vanillaAllowSniper  { count += 1; lane = 4; };
  if cfg.vanillaAllowSMG     { count += 1; lane = 5; };
  if cfg.vanillaAllowAR      { count += 1; lane = 6; };
  if cfg.vanillaAllowLMG     { count += 1; lane = 7; };

  return count == 1 ? lane : 0;
}

private func RFC_VanillaOnlyEnabledMeleeLane(cfg: RFCConfig) -> Int32 {
  let count: Int32 = 0;
  let lane: Int32 = 0;

  if cfg.vanillaAllowBlunt { count += 1; lane = 8; };
  if cfg.vanillaAllowBlade { count += 1; lane = 9; };

  return count == 1 ? lane : 0;
}

public func RFC_VanillaWeaponLaneForAttack(
  ad: ref<AttackData>,
  cfg: RFCConfig
) -> Int32 {
  if !IsDefined(ad) {
    return 0;
  };

  let at: gamedataAttackType = ad.GetAttackType();

  // Explosion/AOE/vehicle contacts are never part of the weapon Vanilla lanes.
  if ad.HasFlag(hitFlag.VehicleImpact)
    || AttackData.IsExplosion(at)
    || AttackData.IsAreaOfEffect(at)
    || ad.HasFlag(hitFlag.Explosion) {
    return 0;
  };

  let w: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;
  if !IsDefined(w) {
    w = ad.GetSource() as WeaponObject;
  };

  if IsDefined(w) {
    let iid: ItemID = w.GetItemID();
    let id: TweakDBID = iid.GetTDBID();

    if TDBID.IsValid(id) {
      // Classification is independent from whether that lane is enabled.
      // The lane toggle is checked separately by RFC_VanillaWeaponLaneEnabled().
      if RFC_ListHas(RFC_Arcade_List_Handgun(), id) { return 1; }
      if RFC_ListHas(RFC_Arcade_List_Magnum(),  id) { return 2; }
      if RFC_ListHas(RFC_Arcade_List_Shotgun(), id) { return 3; }
      if RFC_ListHas(RFC_Arcade_List_Sniper(),  id) { return 4; }
      if RFC_ListHas(RFC_Arcade_List_SMG(),     id) { return 5; }
      if RFC_ListHas(RFC_Arcade_List_AR(),      id) { return 6; }
      if RFC_ListHas(RFC_Arcade_List_LMG(),     id) { return 7; }
      if RFC_ListHas(RFC_Arcade_List_Blunt(),   id) { return 8; }
      if RFC_ListHas(RFC_Arcade_List_Blade(),   id) { return 9; }
    };
  };

  // Robust fallback for weapon variants missing from the exact TweakDB lists:
  // if exactly ONE ranged lane is enabled, a ranged/direct attack can safely
  // use that lane without accidentally enabling another weapon category.
  if AttackData.IsRangedOrDirect(at) {
    return RFC_VanillaOnlyEnabledRangedLane(cfg);
  };

  // Same fallback for melee. If both Blunt and Blade are enabled and the item
  // is unknown, do not guess; exact-list classification still works normally.
  if Equals(at, gamedataAttackType.Melee)
    || Equals(at, gamedataAttackType.QuickMelee)
    || Equals(at, gamedataAttackType.StrongMelee) {
    return RFC_VanillaOnlyEnabledMeleeLane(cfg);
  };

  return 0;
}

public func RFC_VanillaImpulseAllowedByWeapon(
  ad: ref<AttackData>,
  cfg: RFCConfig
) -> Bool {
  let lane: Int32 = RFC_VanillaWeaponLaneForAttack(ad, cfg);
  return lane > 0 && RFC_VanillaWeaponLaneEnabled(lane, cfg);
}

public func RFC_VanillaDeathAnimationAllowedByWeapon(
  puppet: wref<NPCPuppet>,
  cfg: RFCConfig
) -> Bool {
  if !IsDefined(puppet) {
    return false;
  };

  // Prefer the lane captured on the original OnHit. This is the authoritative
  // result for nested death callbacks.
  if puppet.rfc_vanillaWeaponLane > 0 {
    return RFC_VanillaWeaponLaneEnabled(
      puppet.rfc_vanillaWeaponLane,
      cfg
    );
  };

  // Fallback only for unusual callback ordering.
  let ad: ref<AttackData> = puppet.rfc_lastAttack;
  if !IsDefined(ad) {
    return false;
  };

  let lane: Int32 = RFC_VanillaWeaponLaneForAttack(ad, cfg);
  return lane > 0 && RFC_VanillaWeaponLaneEnabled(lane, cfg);
}

@addField(NPCPuppet)
public let rfc_vanillaDeathAnimArmed: Bool;

@addField(NPCPuppet)
public let rfc_vanillaWeaponLane: Int32;

// v1706: all later SPLAT callbacks use the lane captured by the original hit.
// This is intentionally not another global/master switch.
public func RFC_VanillaWeaponReactionArmed(p: wref<NPCPuppet>) -> Bool {
  return IsDefined(p) && p.rfc_vanillaWeaponLane > 0;
}
