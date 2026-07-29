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

  // Preserve the old stagger-window protection independently of the optional
  // PopFix menu. Native ranged impulse must not stack with SPLAT during the
  // incapacitation/death handoff, even when selected vanilla impulses are on.
  let npc: ref<NPCPuppet> = this.GetOwner() as NPCPuppet;
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

  // Keep melee impulses vanilla (your existing behavior)
  if attackData != null && RFC_IsMeleeLike(attackData.GetAttackType()) {
    return wrappedMethod(attackData, hitPosition, frameImpulse);
  }

  // Hard stop for vanilla ranged/explosion physical impulse leaks.
  // If vanilla weapon impulses are not explicitly enabled, bullets should not
  // create a hidden ground shove after all SPLAT jolts/arcade settings are off.
  if !c.vanillaImpulsesEnabled {
    frameImpulse = 0.0;
    this.m_cumulatedPhysicalImpulse = 0.0;
    this.m_ragdollImpulse = 0.0;
    return 0.0;
  }

  // Kill impulses for everything else (ranged, explosions, etc.)
  if c.killImpulsesEverywhere {

    // Exception: allow vanilla impulses for allowed weapons (per-group toggles)
    if c.vanillaImpulsesEnabled && attackData != null && RFC_VanillaImpulseAllowedByWeapon(attackData, c) {
      outImpulse = wrappedMethod(attackData, hitPosition, frameImpulse);

      if RFC_BlockVanillaStumbleSlam(this, outImpulse, frameImpulse) {
        frameImpulse = 0.0;
        this.m_cumulatedPhysicalImpulse = 0.0;
        this.m_ragdollImpulse = 0.0;
        return 0.0;
      }

      return outImpulse;
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

public func RFC_VanillaImpulseAllowedByWeapon(ad: ref<AttackData>, cfg: RFCConfig) -> Bool {
  if !IsDefined(ad) { return false; }

  // If this was an explosion/aoe/vehicle, do NOT allow here. Keep impulses killed.
  // This keeps your grenade/explosion behavior isolated from "weapon exceptions".
  let at: gamedataAttackType = ad.GetAttackType();
  if ad.HasFlag(hitFlag.VehicleImpact) { return false; }
  if AttackData.IsExplosion(at) || AttackData.IsAreaOfEffect(at) || ad.HasFlag(hitFlag.Explosion) { return false; }

  let w: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;

  // No-weapon hits include thrown objects (grenade impact). Not allowed.
  if !IsDefined(w) { return false; }

  let iid: ItemID = w.GetItemID();
  let id: TweakDBID = iid.GetTDBID();

  if !TDBID.IsValid(id) {
    // Fallback: allow generic melee by type only (optional).
    if Equals(at, gamedataAttackType.Melee) {
      return cfg.vanillaAllowBlunt || cfg.vanillaAllowBlade;
    }
    return false;
  }

  // IMPORTANT: these are the real function names in ArcadeWeapons.reds
  if cfg.vanillaAllowHandgun && RFC_ListHas(RFC_Arcade_List_Handgun(), id) { return true; }
  if cfg.vanillaAllowMagnum  && RFC_ListHas(RFC_Arcade_List_Magnum(),  id) { return true; }
  if cfg.vanillaAllowShotgun && RFC_ListHas(RFC_Arcade_List_Shotgun(), id) { return true; }
  if cfg.vanillaAllowSniper  && RFC_ListHas(RFC_Arcade_List_Sniper(),  id) { return true; }
  if cfg.vanillaAllowSMG     && RFC_ListHas(RFC_Arcade_List_SMG(),     id) { return true; }
  if cfg.vanillaAllowAR      && RFC_ListHas(RFC_Arcade_List_AR(),      id) { return true; }
  if cfg.vanillaAllowLMG     && RFC_ListHas(RFC_Arcade_List_LMG(),     id) { return true; }
  if cfg.vanillaAllowBlunt   && RFC_ListHas(RFC_Arcade_List_Blunt(),   id) { return true; }
  if cfg.vanillaAllowBlade   && RFC_ListHas(RFC_Arcade_List_Blade(),   id) { return true; }

  return false;
}
