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

  if c.vanillaMode {
    return wrappedMethod(attackData, hitPosition, frameImpulse);
  }

  // Keep melee impulses vanilla (your existing behavior)
  if attackData != null && RFC_IsMeleeLike(attackData.GetAttackType()) {
    return wrappedMethod(attackData, hitPosition, frameImpulse);
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
