module RealisticPush

// Shared fields/helpers moved to RFC_OnHitShared.reds

private func RFC_Length3(v: Vector4) -> Float {
  return SqrtF(v.X * v.X + v.Y * v.Y + v.Z * v.Z);
}

// Fields

@addField(NPCPuppet) public let rfc_mv_lastT: Float;
@addField(NPCPuppet) public let rfc_mv_lastX: Float;
@addField(NPCPuppet) public let rfc_mv_lastY: Float;
@addField(NPCPuppet) public let rfc_mv_vx: Float;
@addField(NPCPuppet) public let rfc_mv_vy: Float;

@addField(NPCPuppet) public let rfc_lastAttack: ref<AttackData>;

@addField(NPCPuppet) public let m_RFC_ArcadeKickDone: Bool;
@addField(NPCPuppet) public let m_RFC_ArcadeDeathT: Float;

@addField(NPCPuppet) public let rfc_mv_lastPos: Vector4;
@addField(NPCPuppet) public let rfc_mv_dirX: Float;
@addField(NPCPuppet) public let rfc_mv_dirY: Float;
@addField(NPCPuppet) public let rfc_mv_dirT: Float;

@addField(NPCPuppet) public let rfc_lastPlanarVX: Float;
@addField(NPCPuppet) public let rfc_lastPlanarVY: Float;
@addField(NPCPuppet) public let rfc_walkLastSeen: Float;
@addField(NPCPuppet) public let rfc_pf_staggerUntil: Float;

// Small helpers

public static func RFC_IsPlayerAttack(victim: ref<GameObject>, ad: ref<AttackData>) -> Bool {
  if !IsDefined(victim) || !IsDefined(ad) {
    return false;
  }

  let gi: GameInstance = victim.GetGame();
  let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gi).GetLocalPlayerMainGameObject() as PlayerPuppet;
  if !IsDefined(player) {
    return false;
  }

  let inst: ref<GameObject> = ad.GetInstigator();
  if !IsDefined(inst) {
    return false;
  }

  return inst == player;
}

public class RFC_TryGrenadeKickEvent extends Event {
  public let hitPos: Vector4;
}

public func RFC_IsVehicleHit(ad: ref<AttackData>) -> Bool {
  if !IsDefined(ad) {
    return false;
  }
  return ad.HasFlag(hitFlag.VehicleImpact);
}

public func RFC_SampleMove2D(p: wref<NPCPuppet>) -> Void {
  if !IsDefined(p) {
    return;
  }

  let nowT: Float = EngineTime.ToFloat(GameInstance.GetSimTime(p.GetGame()));
  let curPos: Vector4 = p.GetWorldPosition();

  if p.rfc_mv_lastT <= 0.0 {
    p.rfc_mv_lastT = nowT;
    p.rfc_mv_lastX = curPos.X;
    p.rfc_mv_lastY = curPos.Y;
    return;
  }

  let dt: Float = nowT - p.rfc_mv_lastT;
  if dt < 0.016 {
    return;
  }

  let dx: Float = curPos.X - p.rfc_mv_lastX;
  let dy: Float = curPos.Y - p.rfc_mv_lastY;

  p.rfc_mv_lastT = nowT;
  p.rfc_mv_lastX = curPos.X;
  p.rfc_mv_lastY = curPos.Y;

  let len: Float = SqrtF(dx * dx + dy * dy);
  if len < 0.01 {
    return;
  }

  p.rfc_lastPlanarVX = dx / MaxF(dt, 0.016);
  p.rfc_lastPlanarVY = dy / MaxF(dt, 0.016);
}

private func GS_OverrideForward(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  if c.st_overrideGlobalForward {
    return true;
  }
  if c.run_overrideGlobalForward {
    return true;
  }
  if c.cow_overrideGlobalForward {
    return true;
  }
  if c.stair_overrideGlobalForward {
    return true;
  }
  if c.wsStand_overrideGlobalForward {
    return true;
  }
  return false;
}

private func GS_OverrideChest(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  if c.st_overrideGlobalChest {
    return true;
  }
  if c.run_overrideGlobalChest {
    return true;
  }
  if c.cow_overrideGlobalChest {
    return true;
  }
  if c.stair_overrideGlobalChest {
    return true;
  }
  if c.wsStand_overrideGlobalChest {
    return true;
  }
  return false;
}

// Arcade weapon gating

public func RFC_ArcadeAllowedByWeapon(ad: ref<AttackData>, cfg: RFCConfig) -> Bool {
  if !IsDefined(ad) {
    return false;
  }

  let at: gamedataAttackType = ad.GetAttackType();

  // Never arcade shove vehicles or explosions
  if ad.HasFlag(hitFlag.VehicleImpact) {
    return false;
  }
  if AttackData.IsExplosion(at) || AttackData.IsAreaOfEffect(at) || ad.HasFlag(hitFlag.Explosion) {
    return false;
  }

  let w: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;

  // No-weapon hits include thrown objects such as grenade impact
  if !IsDefined(w) {
    return false;
  }

  let iid: ItemID = w.GetItemID();
  let id: TweakDBID = iid.GetTDBID();

  if !TDBID.IsValid(id) {
    if Equals(at, gamedataAttackType.Melee) {
      return cfg.arcadeAllowBlade || cfg.arcadeAllowBlunt;
    }
    return false;
  }

  if RFC_ListHas(RFC_Arcade_List_Shotgun(), id) { return cfg.arcadeAllowShotgun; }
  if RFC_ListHas(RFC_Arcade_List_Sniper(), id) { return cfg.arcadeAllowSniper; }
  if RFC_ListHas(RFC_Arcade_List_Handgun(), id) { return cfg.arcadeAllowHandgun; }
  if RFC_ListHas(RFC_Arcade_List_Magnum(), id) { return cfg.arcadeAllowMagnum; }
  if RFC_ListHas(RFC_Arcade_List_SMG(), id) { return cfg.arcadeAllowSMG; }
  if RFC_ListHas(RFC_Arcade_List_AR(), id) { return cfg.arcadeAllowAR; }
  if RFC_ListHas(RFC_Arcade_List_LMG(), id) { return cfg.arcadeAllowLMG; }
  if RFC_ListHas(RFC_Arcade_List_Blunt(), id) { return cfg.arcadeAllowBlunt; }
  if RFC_ListHas(RFC_Arcade_List_Blade(), id) { return cfg.arcadeAllowBlade; }

  // Final melee fallback by attack type
  if Equals(at, gamedataAttackType.Melee) {
    return cfg.arcadeAllowBlade || cfg.arcadeAllowBlunt;
  }

  return false;
}

// Arcade OnHit shove

private func RFC_ArcadeWeaponMul(ad: ref<AttackData>, cfg: RFCConfig) -> Float {
  if !IsDefined(ad) {
    return 1.0;
  }

  // Never apply arcade scaling for explosions or vehicle impacts
  let at: gamedataAttackType = ad.GetAttackType();
  if ad.HasFlag(hitFlag.VehicleImpact) {
    return 0.0;
  }
  if AttackData.IsExplosion(at) || AttackData.IsAreaOfEffect(at) || ad.HasFlag(hitFlag.Explosion) {
    return 0.0;
  }

  let w: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;

  // No WeaponObject includes thrown items such as grenade impact
  if !IsDefined(w) {
    return 0.0;
  }

  let id: TweakDBID = w.GetItemID().GetTDBID();
  if !TDBID.IsValid(id) {
    if Equals(at, gamedataAttackType.Melee) {
      return cfg.arcadeMulBlade;
    }
    return 1.0;
  }

  if RFC_ListHas(RFC_Arcade_List_Shotgun(), id) { return cfg.arcadeMulShotgun; }
  if RFC_ListHas(RFC_Arcade_List_Sniper(), id) { return cfg.arcadeMulSniper; }
  if RFC_ListHas(RFC_Arcade_List_Handgun(), id) { return cfg.arcadeMulHandgun; }
  if RFC_ListHas(RFC_Arcade_List_Magnum(), id) { return cfg.arcadeMulMagnum; }
  if RFC_ListHas(RFC_Arcade_List_SMG(), id) { return cfg.arcadeMulSMG; }
  if RFC_ListHas(RFC_Arcade_List_AR(), id) { return cfg.arcadeMulAR; }
  if RFC_ListHas(RFC_Arcade_List_LMG(), id) { return cfg.arcadeMulLMG; }
  if RFC_ListHas(RFC_Arcade_List_Blunt(), id) { return cfg.arcadeMulBlunt; }
  if RFC_ListHas(RFC_Arcade_List_Blade(), id) { return cfg.arcadeMulBlade; }

  if Equals(at, gamedataAttackType.Melee) {
    return cfg.arcadeMulBlade;
  }

  return 1.0;
}

private func RFC_ArcadeCanResetLatch(p: ref<NPCPuppet>) -> Bool {
  if !IsDefined(p) {
    return false;
  }
  if p.IsIncapacitated() {
    return false;
  }
  if !RFC_IsClearlyStanding(p) {
    return false;
  }
  return true;
}

private func RFC_ArcadeApplyOnHit(
  npc: ref<NPCPuppet>,
  hitPos: Vector4,
  srcPos: Vector4,
  cfg: RFCConfig
) -> Void {
  if npc.IsDead() {
    return;
  }

  if !IsDefined(npc) {
    return;
  }
  if !cfg.arcadeBulletsEnabled {
    return;
  }
  if !ScriptedPuppet.CanRagdoll(npc) {
    return;
  }

  RFC_TryStopWorkspot(npc);

  if npc.IsDead() && !npc.m_RFC_CorpseImpulseReady {
    return;
  }
  if !npc.IsDead() && npc.IsIncapacitated() {
    return;
  }

  if npc.m_RFC_ArcadeKickDone {
    if RFC_ArcadeCanResetLatch(npc) {
      npc.m_RFC_ArcadeKickDone = false;
    } else {
      return;
    }
  }

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(npc.GetGame());
  if !IsDefined(ds) {
    return;
  }

  RFC_TryStopWorkspot(npc);

  npc.QueueEvent(CreateForceRagdollEvent(n"Splat_ArcadeHit"));
  ds.DelayEvent(npc, CreateForceRagdollEvent(n"Splat_ArcadeHit"), 0.040, false);
  ds.DelayEvent(npc, CreateForceRagdollEvent(n"Splat_ArcadeHit"), 0.080, false);

  let dir: Vector4 = hitPos - srcPos;
  let len: Float = MaxF(0.001, RFC_Length3(dir));
  let nx: Float = dir.X / len;
  let ny: Float = dir.Y / len;

  let isCow: Bool = RFC_IsCoweringStrict(npc);
  let cowScale: Float = isCow ? 0.75 : 1.0;

  let mul: Float = RFC_ArcadeWeaponMul(npc.rfc_lastAttack, cfg);
  if mul <= 0.0 {
    return;
  }

  let s: Float = cfg.arcadeBulletStrength * cowScale * mul;
  if s == 0.0 {
    return;
  }

  let impulse: Vector4 = new Vector4(
    nx * s,
    ny * s,
    cfg.arcadeBulletUp,
    1.0
  );

  let r: Float = (cfg.arcadeBulletRadius > 0.0) ? cfg.arcadeBulletRadius : 0.60;

  ds.DelayEvent(
    npc,
    CreateRagdollApplyImpulseEvent(hitPos, impulse, r),
    RFC_ClampT(cfg.arcadeImpulseDelay),
    false
  );

  npc.m_RFC_ArcadeKickDone = true;
  npc.m_RFC_ArcadeDeathT = EngineTime.ToFloat(GameInstance.GetSimTime(npc.GetGame()));
}

// Bullet corpse bloom

public func RFC_BulletCorpseKick(
  puppet: ref<NPCPuppet>,
  ds: ref<DelaySystem>,
  hitPos: Vector4,
  _dirIgnored: Vector4,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(puppet) || !IsDefined(ds) {
    return;
  }
  if !ScriptedPuppet.CanRagdoll(puppet) {
    return;
  }

  let rMax: Float = MaxF(0.01, cfg.bulletKickRadius);
  if rMax <= 0.0 {
    return;
  }

  // Timing
  let startDelay: Float = MaxF(0.0, cfg.bulletKickStartDelay);
  let dtRaw: Float = (cfg.bulletKickDelay > 0.0) ? cfg.bulletKickDelay : (rMax * 0.12);
  let dt: Float = MinF(MaxF(dtRaw, 0.02), 0.20);
  let eps: Float = 0.010;

  // Radii
  let r0: Float = MaxF(0.008, rMax * 0.12);
  let r1: Float = MaxF(r0 + 0.006, rMax * 0.38);
  let r2: Float = rMax;

  // Vertical kick only
  let z: Float = cfg.bulletKickZ;

  ds.DelayEvent(puppet, CreateRagdollApplyImpulseEvent(
    hitPos, new Vector4(0.0, 0.0, z * 1.00, 1.0), r0
  ), startDelay + eps, false);

  if rMax > (r0 + 0.02) {
    ds.DelayEvent(puppet, CreateRagdollApplyImpulseEvent(
      hitPos, new Vector4(0.0, 0.0, z * 0.85, 1.0), r1
    ), startDelay + eps + dt, false);

    ds.DelayEvent(puppet, CreateRagdollApplyImpulseEvent(
      hitPos, new Vector4(0.0, 0.0, z * 0.70, 1.0), r2
    ), startDelay + eps + (dt * 2.0), false);
  }
}

// Explosions

private func RFC_ApplyAliveExplosionImpulse(
  sp: wref<ScriptedPuppet>,
  hitPos: Vector4,
  magXY: Float,
  biasZ: Float,
  radius: Float
) -> Void {
  if !IsDefined(sp) || magXY == 0.0 {
    return;
  }
  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(sp.GetGame());
  if !IsDefined(ds) {
    return;
  }

  // Base delay from ModSettings
  let c: RFCConfig = RFC.Cfg();
  let t0: Float = MaxF(0.0, c.grenadeKickCallDelay);

  let p: Vector4 = sp.GetWorldPosition();
  let dx: Float = p.X - hitPos.X;
  let dy: Float = p.Y - hitPos.Y;
  let dz: Float = (p.Z - hitPos.Z) + biasZ;

  let len: Float = MaxF(0.0001, SqrtF(dx * dx + dy * dy + dz * dz));
  let v: Vector4 = new Vector4((dx / len) * magXY, (dy / len) * magXY, (dz / len) * magXY, 1.0);

  ds.DelayEvent(sp, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), t0 + 0.00, false);
  ds.DelayEvent(sp, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), t0 + 0.02, false);
  ds.DelayEvent(sp, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), t0 + 0.04, false);

  let r: Float = MaxF(0.01, radius);
  ds.DelayEvent(sp, CreateRagdollApplyImpulseEvent(hitPos, v, r), t0 + 0.00, false);
  ds.DelayEvent(sp, CreateRagdollApplyImpulseEvent(hitPos, v, r), t0 + 0.04, false);
  ds.DelayEvent(sp, CreateRagdollApplyImpulseEvent(hitPos, v, r), t0 + 0.08, false);

  ds.DelayEvent(sp, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), t0 + 0.12, false);
  ds.DelayEvent(sp, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), t0 + 0.18, false);
}

// Grenade corpse kick
// grenadeKickX is radial strength
// grenadeKickY is sideways swirl strength
// grenadeKickZ is vertical

private enum RFC_ExplSrc {
  Grenade = 0,
  Weapon = 1,
  Bullet = 2,
  Vehicle = 3
}

private func RFC_ClassifyExplosion(ad: ref<AttackData>) -> RFC_ExplSrc {
  if !IsDefined(ad) {
    return RFC_ExplSrc.Grenade;
  }

  if ad.HasFlag(hitFlag.VehicleImpact) {
    return RFC_ExplSrc.Vehicle;
  }

  let w: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;
  if IsDefined(w) {
    return RFC_ExplSrc.Weapon;
  }

  return RFC_ExplSrc.Grenade;
}

private func RFC_ExplEnabled(src: RFC_ExplSrc, cfg: RFCConfig) -> Bool {
  switch src {
    case RFC_ExplSrc.Grenade: return cfg.explAffectGrenades;
    case RFC_ExplSrc.Weapon: return cfg.explAffectWeapon;
    case RFC_ExplSrc.Bullet: return cfg.explAffectBullet;
    case RFC_ExplSrc.Vehicle: return cfg.explAffectVehicle;
  }
  return true;
}

private func RFC_ExplMul(src: RFC_ExplSrc, cfg: RFCConfig) -> Float {
  switch src {
    case RFC_ExplSrc.Grenade: return cfg.explMulGrenades;
    case RFC_ExplSrc.Weapon: return cfg.explMulWeapon;
    case RFC_ExplSrc.Bullet: return cfg.explMulBullet;
    case RFC_ExplSrc.Vehicle: return cfg.explMulVehicle;
  }
  return 1.0;
}

private func RFC_GrenadeCorpseKick_InstantScaled(
  puppet: ref<NPCPuppet>,
  hitPos: Vector4,
  cfg: RFCConfig,
  mul: Float
) -> Void {
  if !IsDefined(puppet) {
    return;
  }
  if !ScriptedPuppet.CanRagdoll(puppet) {
    return;
  }
  if cfg.grenadeKickRadius <= 0.0 {
    return;
  }
  if mul <= 0.0 {
    return;
  }

  let rMax: Float = MaxF(0.01, cfg.grenadeKickRadius);
  let r0: Float = MaxF(0.008, rMax * 0.12);
  let r1: Float = MaxF(r0 + 0.006, rMax * 0.38);
  let r2: Float = rMax;

  let p: Vector4 = puppet.GetWorldPosition();
  let rx: Float = p.X - hitPos.X;
  let ry: Float = p.Y - hitPos.Y;

  let rLen: Float = SqrtF(rx * rx + ry * ry);
  if rLen < 0.0001 {
    rx = 0.0;
    ry = 1.0;
    rLen = 1.0;
  }

  let nx: Float = rx / rLen;
  let ny: Float = ry / rLen;

  let tx: Float = -ny;
  let ty: Float = nx;

  let kX: Float = cfg.grenadeKickX * mul;
  let kY: Float = cfg.grenadeKickY * mul;
  let kZ: Float = cfg.grenadeKickZ * mul;

  let baseX: Float = (nx * kX) + (tx * kY);
  let baseY: Float = (ny * kX) + (ty * kY);
  let baseZ: Float = kZ;

  let v0: Vector4 = new Vector4(baseX * 1.00, baseY * 1.00, baseZ * 1.00, 1.0);
  let v1: Vector4 = new Vector4(baseX * 0.85, baseY * 0.85, baseZ * 0.85, 1.0);
  let v2: Vector4 = new Vector4(baseX * 0.70, baseY * 0.70, baseZ * 0.70, 1.0);

  puppet.QueueEvent(CreateRagdollApplyImpulseEvent(hitPos, v0, r0));
  puppet.QueueEvent(CreateRagdollApplyImpulseEvent(hitPos, v1, r1));
  puppet.QueueEvent(CreateRagdollApplyImpulseEvent(hitPos, v2, r2));
}

@addMethod(NPCPuppet)
protected cb func OnRFC_TryGrenadeKickEvent(evt: ref<RFC_TryGrenadeKickEvent>) -> Bool {
  let cfg: RFCConfig = RFC.Cfg();

  if !IsDefined(evt) {
    return true;
  }
  if !ScriptedPuppet.CanRagdoll(this) {
    return true;
  }

  // Master enable + radius gate
  if !cfg.grenadeEnabled || cfg.grenadeKickRadius <= 0.0 {
    return true;
  }

  // Must have context
  if !IsDefined(this.rfc_lastAttack) {
    return true;
  }

  // Only run for explosion or vehicle impact
  let at: gamedataAttackType = this.rfc_lastAttack.GetAttackType();
  let isExpl: Bool = Equals(at, gamedataAttackType.Explosion) || Equals(at, gamedataAttackType.PressureWave);
  let isVeh: Bool = this.rfc_lastAttack.HasFlag(hitFlag.VehicleImpact);

  if !isExpl && !isVeh {
    return true;
  }

  let src: RFC_ExplSrc = RFC_ClassifyExplosion(this.rfc_lastAttack);
  if !RFC_ExplEnabled(src, cfg) {
    return true;
  }

  let mul: Float = RFC_ExplMul(src, cfg);
  if mul <= 0.0 {
    return true;
  }

  RFC_GrenadeCorpseKick_InstantScaled(this, evt.hitPos, cfg, mul);
  return true;
}

public func RFC_GrenadeCorpseKick_Instant(puppet: ref<NPCPuppet>, hitPos: Vector4, cfg: RFCConfig) -> Void {
  if !ScriptedPuppet.CanRagdoll(puppet) {
    return;
  }
  if cfg.grenadeKickRadius <= 0.0 {
    return;
  }

  let rMax: Float = MaxF(0.01, cfg.grenadeKickRadius);
  let r0: Float = MaxF(0.008, rMax * 0.12);
  let r1: Float = MaxF(r0 + 0.006, rMax * 0.38);
  let r2: Float = rMax;

  let p: Vector4 = puppet.GetWorldPosition();
  let rx: Float = p.X - hitPos.X;
  let ry: Float = p.Y - hitPos.Y;

  let rLen: Float = SqrtF(rx * rx + ry * ry);
  if rLen < 0.0001 {
    rx = 0.0;
    ry = 1.0;
    rLen = 1.0;
  }

  let nx: Float = rx / rLen;
  let ny: Float = ry / rLen;

  let tx: Float = -ny;
  let ty: Float = nx;

  let baseX: Float = (nx * cfg.grenadeKickX) + (tx * cfg.grenadeKickY);
  let baseY: Float = (ny * cfg.grenadeKickX) + (ty * cfg.grenadeKickY);
  let baseZ: Float = cfg.grenadeKickZ;

  let v0: Vector4 = new Vector4(baseX * 1.00, baseY * 1.00, baseZ * 1.00, 1.0);
  let v1: Vector4 = new Vector4(baseX * 0.85, baseY * 0.85, baseZ * 0.85, 1.0);
  let v2: Vector4 = new Vector4(baseX * 0.70, baseY * 0.70, baseZ * 0.70, 1.0);

  puppet.QueueEvent(CreateRagdollApplyImpulseEvent(hitPos, v0, r0));
  puppet.QueueEvent(CreateRagdollApplyImpulseEvent(hitPos, v1, r1));
  puppet.QueueEvent(CreateRagdollApplyImpulseEvent(hitPos, v2, r2));
}

private func RFC_ScheduleGrenadeCorpseKick(
  puppet: ref<NPCPuppet>,
  hitPos: Vector4,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(puppet) {
    return;
  }
  if !ScriptedPuppet.CanRagdoll(puppet) {
    return;
  }
  if !cfg.grenadeEnabled || cfg.grenadeKickRadius <= 0.0 {
    return;
  }

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(puppet.GetGame());
  if !IsDefined(ds) {
    return;
  }

  // Ensure ragdoll is active
  ds.DelayEvent(puppet, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), 0.00, false);
  ds.DelayEvent(puppet, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), 0.02, false);
  ds.DelayEvent(puppet, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), 0.04, false);

  let e: ref<RFC_TryGrenadeKickEvent> = new RFC_TryGrenadeKickEvent();
  e.hitPos = hitPos;

  ds.DelayEvent(puppet, e, MaxF(0.0, cfg.grenadeKickCallDelay), false);
}

private func RFC_IsGrenadeExplosion(ad: ref<AttackData>) -> Bool {
  if !IsDefined(ad) {
    return false;
  }

  let at: gamedataAttackType = ad.GetAttackType();
  if Equals(at, gamedataAttackType.Explosion) {
    return true;
  }
  if Equals(at, gamedataAttackType.PressureWave) {
    return true;
  }

  return false;
}

@wrapMethod(NPCPuppet)
protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
  let res: Bool;
  let s: ref<SHHJM_Settings>;
  let hitPos: Vector4;
  let shhjmSrcPos: Vector4;
  let anchorPos: Vector4;
  let applyEvt: ref<SHHJM_ApplyImpulseEvt>;
  let part: Int32;

  if !IsDefined(evt) {
    return wrappedMethod(evt);
  }

  // SHHJM pre-wrap capture
  s = new SHHJM_Settings();
  this.shhjm_lastHitValid = false;
  this.shhjm_lastBodyPart = 99;

  hitPos = evt.hitPosition;
  shhjmSrcPos = hitPos;
  if IsDefined(evt.attackData) {
    shhjmSrcPos = evt.attackData.GetAttackPosition();
  }

  if SHHJM_ResolveBodyPart(this, hitPos, part, anchorPos) && SHHJM_GetPartEnabled(part, s) {
    this.shhjm_lastHitValid = true;
    this.shhjm_lastHitPos = hitPos;
    this.shhjm_lastSrcPos = shhjmSrcPos;
    this.shhjm_lastAnchorPos = anchorPos;
    this.shhjm_lastBodyPart = part;

    if ScriptedPuppet.CanRagdoll(this) {
      this.QueueEvent(CreateForceRagdollEvent(n"SHHJM_Hit"));
    }
  }

  res = wrappedMethod(evt);

  // SHHJM post-wrap scheduling
  if this.shhjm_lastHitValid {
    applyEvt = new SHHJM_ApplyImpulseEvt();
    applyEvt.pos = this.shhjm_lastAnchorPos;
    applyEvt.imp = SHHJM_BuildImpulse(this.shhjm_lastSrcPos, this.shhjm_lastHitPos, this.shhjm_lastBodyPart, s);
    applyEvt.radius = SHHJM_GetRadius(this.shhjm_lastBodyPart, s);
    SHHJM_Sched(this, applyEvt, MaxF(0.01, SHHJM_GetHitDelay(this.shhjm_lastBodyPart, s)));
  }

  // RFC branch requires attackData
  if !IsDefined(evt.attackData) {
    return res;
  }

  let cfg: RFCConfig = RFC.Cfg();
  let ad: ref<AttackData> = evt.attackData;
  let rfcSrcPos: Vector4 = ad.GetAttackPosition();

  this.rfc_lastAttack = ad;

  RFC_SampleMove2D(this);

  if RFC_IsGrenadeExplosion(ad) || RFC_IsVehicleHit(ad) {
    if cfg.explPlayerOnly && !RFC_IsPlayerAttack(this, ad) {
      return res;
    }

    if cfg.grenadeEnabled && cfg.grenadeKickRadius > 0.0 {
      let src: RFC_ExplSrc = RFC_ClassifyExplosion(ad);
      if !RFC_ExplEnabled(src, cfg) {
        return res;
      }

      let mul: Float = RFC_ExplMul(src, cfg);
      if mul <= 0.0 {
        return res;
      }

      if !this.IsDead() {
        RFC_ApplyAliveExplosionImpulse(
          this,
          hitPos,
          cfg.grenadeKickX * mul,
          cfg.grenadeKickZ * mul,
          cfg.grenadeKickRadius
        );
        return res;
      }

      if this.IsDead() && this.m_RFC_CorpseImpulseReady {
        let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
        if IsDefined(ds) {
          let eKick: ref<RFC_TryGrenadeKickEvent> = new RFC_TryGrenadeKickEvent();
          eKick.hitPos = hitPos;
          ds.DelayEvent(this, eKick, MaxF(0.0, cfg.grenadeKickCallDelay), false);
        } else {
          let eKick2: ref<RFC_TryGrenadeKickEvent> = new RFC_TryGrenadeKickEvent();
          eKick2.hitPos = hitPos;
          this.QueueEvent(eKick2);
        }
        return res;
      }
    }

    return res;
  }

  if cfg.corpseKickEnabled && cfg.bulletKickRadius > 0.0 && this.IsDead() && this.m_RFC_CorpseImpulseReady {
    let ds2: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
    if IsDefined(ds2) {
      let dir: Vector4 = hitPos - rfcSrcPos;
      RFC_BulletCorpseKick(this, ds2, hitPos, dir, cfg);
    }
  }

  if cfg.arcadeBulletsEnabled && cfg.arcadeOnHitEnabled {
    if cfg.arcadePlayerOnly && !RFC_IsPlayerAttack(this, ad) {
      return res;
    }

    let wArc: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;
    if IsDefined(wArc) && RFC_ArcadeAllowedByWeapon(ad, cfg) {
      RFC_ArcadeApplyOnHit(this, hitPos, rfcSrcPos, cfg);
    }
  }

  return res;
}