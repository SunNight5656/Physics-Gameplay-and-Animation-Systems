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
@addField(NPCPuppet) private let m_RFC_InjuryShockPending: Bool;
@addField(NPCPuppet) private let m_RFC_InjuryShockHoldActive: Bool;

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

private func RFC_SHHJM_SourcePos(p: wref<NPCPuppet>, ad: ref<AttackData>, hitPos: Vector4) -> Vector4 {
  let srcPos: Vector4 = hitPos;
  let dx: Float;
  let dy: Float;
  let dz: Float;
  let inst: ref<GameObject>;

  if IsDefined(ad) {
    srcPos = ad.GetAttackPosition();

    dx = hitPos.X - srcPos.X;
    dy = hitPos.Y - srcPos.Y;
    dz = hitPos.Z - srcPos.Z;

    // Some corpse/MaxTac/vehicle-adjacent hits report the attack position almost
    // equal to the hit position. That makes forward strength look like it does
    // nothing because the direction vector collapses. Fall back to the instigator.
    if SqrtF(dx * dx + dy * dy + dz * dz) < 0.10 {
      inst = ad.GetInstigator();
      if IsDefined(inst) {
        srcPos = inst.GetWorldPosition();
      }
    }
  }

  return srcPos;
}

public class RFC_TryGrenadeKickEvent extends Event {
  public let hitPos: Vector4;
}

// Defer briefly so lethal hits can publish death before Animation Control
// decides whether a live bullet reaction is preserved or ended early.
public class RFC_HitReactionGuardEvent extends Event {
  public let hitPos: Vector4;
  public let srcPos: Vector4;
  public let attackData: ref<AttackData>;
  public let allowAnimationCut: Bool;
  public let allowArcadeImpulse: Bool;
}

public class RFC_HitReactionCutEvent extends Event {
  public let hitPos: Vector4;
  public let srcPos: Vector4;
  public let attackData: ref<AttackData>;
  public let allowArcadeImpulse: Bool;
  public let incapacitatedCut: Bool;
}

public class RFC_InjuryShockEvent extends Event {}
public class RFC_InjuryShockResetEvent extends Event {}

@wrapMethod(NPCPuppet)
protected func CanStandUpFromRagdoll(currentPosition: Vector4) -> Bool {
  if this.m_RFC_InjuryShockHoldActive {
    let cfg: RFCConfig = RFC.Cfg();
    if !cfg.vanillaMode && cfg.injuryShockEnabled && !this.IsDead() && !this.IsIncapacitated() {
      return false;
    }
    this.m_RFC_InjuryShockHoldActive = false;
  }
  return wrappedMethod(currentPosition);
}

public func RFC_IsVehicleHit(ad: ref<AttackData>) -> Bool {
  if !IsDefined(ad) {
    return false;
  }
  return ad.HasFlag(hitFlag.VehicleImpact);
}

private func RFC_IsBulletReactionCutSource(ad: ref<AttackData>) -> Bool {
  if !IsDefined(ad) {
    return false;
  }

  let at: gamedataAttackType = ad.GetAttackType();
  if ad.HasFlag(hitFlag.VehicleImpact)
    || ad.HasFlag(hitFlag.Explosion)
    || AttackData.IsExplosion(at)
    || AttackData.IsAreaOfEffect(at) {
    return false;
  }

  if Equals(at, gamedataAttackType.Melee)
    || Equals(at, gamedataAttackType.QuickMelee)
    || Equals(at, gamedataAttackType.StrongMelee) {
    return false;
  }

  return IsDefined(ad.GetWeapon() as WeaponObject);
}

// Injury Shock source rules confirmed in standalone Test R.
// V always qualifies. NPC bullets qualify only when their toggle is enabled.
private func RFC_InjuryShockSourceAllowed(
  victim: wref<NPCPuppet>,
  ad: ref<AttackData>,
  cfg: RFCConfig
) -> Bool {
  let instigatorNPC: ref<NPCPuppet>;

  if !IsDefined(victim) || !RFC_IsBulletReactionCutSource(ad) {
    return false;
  }

  if RFC_IsPlayerAttack(victim, ad) {
    return true;
  }

  if !cfg.injuryShockAllowNPCSources {
    return false;
  }

  instigatorNPC = ad.GetInstigator() as NPCPuppet;
  return IsDefined(instigatorNPC) && instigatorNPC != victim;
}

// Bosses and sub-bosses are separate opt-in classes and default OFF.
private func RFC_InjuryShockActorClassAllowed(
  victim: wref<NPCPuppet>,
  cfg: RFCConfig
) -> Bool {
  if !IsDefined(victim) {
    return false;
  }

  switch victim.GetNPCRarity() {
    case gamedataNPCRarity.Boss:
    case gamedataNPCRarity.MaxTac:
      return cfg.injuryShockAllowBosses;

    case gamedataNPCRarity.Elite:
      return cfg.injuryShockAllowSubBosses;
  }

  return true;
}

// The defeated/incapacitated pipeline publishes IsAboutToBeDefeated before
// GetWasIncapacitated is committed. Check every public state the game itself
// uses so the handoff is classified correctly during the falling animation.
private func RFC_IsIncapacitatedTransition(p: wref<NPCPuppet>) -> Bool {
  if !IsDefined(p) {
    return false;
  }

  let hitComponent: ref<HitReactionComponent> = p.GetHitReactionComponent();

  return p.IsIncapacitated()
    || p.IsAboutToBeDefeated()
    || ScriptedPuppet.IsDefeated(p)
    || (IsDefined(hitComponent) && hitComponent.GetDefeatedHasBeenPlayed())
    || Equals(p.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Unconscious);
}

@wrapMethod(NPCPuppet)
private func OnHitAnimation(hitEvent: ref<gameHitEvent>) -> Void {
  if IsDefined(hitEvent) {
    let cfg: RFCConfig = RFC.Cfg();
    if !cfg.vanillaMode
      && cfg.hitReactionsDisabled
      && !this.IsDead()
      && !RFC_IsIncapacitatedTransition(this)
      && RFC_IsPlayerAttack(this, hitEvent.attackData)
      && RFC_IsBulletReactionCutSource(hitEvent.attackData) {
      return;
    }
  }
  wrappedMethod(hitEvent);
}

private func RFC_StopOrdinaryHitReaction(p: wref<NPCPuppet>) -> Void {
  if !IsDefined(p) {
    return;
  }

  let hitComponent: ref<HitReactionComponent> = p.GetHitReactionComponent();
  if IsDefined(hitComponent) && IsDefined(hitComponent.GetHitReactionProxyAction()) {
    // Stop only the active scripted reaction. Submitting another hit feature,
    // pushing the hit graph event, or forcing an upper-body state makes the
    // graph select a recovery pose instead of simply ending this reaction.
    hitComponent.GetHitReactionProxyAction().Stop();
  }
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
  return GS_CurrentOverrideForward(p, c);
}

private func GS_OverrideChest(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  return GS_CurrentOverrideChest(p, c);
}

// Arcade weapon gating

public func RFC_ArcadeIsMeleeAttack(ad: ref<AttackData>) -> Bool {
  if !IsDefined(ad) {
    return false;
  }

  let at: gamedataAttackType = ad.GetAttackType();
  return Equals(at, gamedataAttackType.Melee)
    || Equals(at, gamedataAttackType.QuickMelee)
    || Equals(at, gamedataAttackType.StrongMelee);
}

// Source controls are deliberately separate from target controls. The selected
// mode decides whether V or an NPC may enter the enabled NPC/vehicle push lane.
// Unknown/environmental instigators are not treated as NPC attacks.
public func RFC_ArcadeAttackSourceAllowed(
  victim: ref<GameObject>,
  ad: ref<AttackData>,
  cfg: RFCConfig
) -> Bool {
  if !IsDefined(victim) || !IsDefined(ad) {
    return false;
  }

  let isMelee: Bool = RFC_ArcadeIsMeleeAttack(ad);
  if RFC_IsPlayerAttack(victim, ad) {
    return isMelee ? cfg.arcadeAllowPlayerMelee : cfg.arcadeAllowPlayerBullet;
  }

  let instigator: ref<GameObject> = ad.GetInstigator();
  if !IsDefined(instigator) {
    return false;
  }

  let npcInstigator: ref<NPCPuppet> = instigator as NPCPuppet;
  if IsDefined(npcInstigator) {
    return isMelee ? cfg.arcadeAllowNPCMelee : cfg.arcadeAllowNPCBullet;
  }

  return false;
}

public func RFC_ArcadeChannelEnabled(ad: ref<AttackData>, cfg: RFCConfig) -> Bool {
  // NPC Arcade weapon push and Vehicle Bullet Push are independent channels.
  // An undefined/stale attack must never fall through as an enabled bullet hit.
  if !IsDefined(ad) {
    return false;
  }
  if RFC_ArcadeIsMeleeAttack(ad) {
    return cfg.arcadeMeleeEnabled;
  }
  return cfg.arcadeBulletsEnabled;
}

private func RFC_ArcadeApplicationPoint(
  npc: ref<NPCPuppet>,
  hitPos: Vector4,
  lowerOffset: Float
) -> Vector4 {
  let t: Float = ClampF(lowerOffset, 0.0, 1.0);
  if !IsDefined(npc) || t <= 0.0 {
    return hitPos;
  }

  let lowerPos: Vector4 = npc.GetWorldPosition();
  lowerPos.Z += 0.85;

  let slotComp: ref<SlotComponent> = npc.GetSlotComponent();
  let slotTransform: WorldTransform;
  if IsDefined(slotComp) && slotComp.GetSlotTransform(n"Hips", slotTransform) {
    lowerPos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
  }

  let outPos: Vector4 = hitPos;
  outPos.X = hitPos.X + (lowerPos.X - hitPos.X) * t;
  outPos.Y = hitPos.Y + (lowerPos.Y - hitPos.Y) * t;
  outPos.Z = hitPos.Z + (lowerPos.Z - hitPos.Z) * t;
  return outPos;
}

private func RFC_ArcadeNamedModeAllowsUnknownBullet(cfg: RFCConfig) -> Bool {
  return cfg.splatPresetMode == EnumInt(RFCSplatPresetMode.RealismPlus)
    || cfg.splatPresetMode == EnumInt(RFCSplatPresetMode.DirtyHarry)
    || cfg.splatPresetMode == EnumInt(RFCSplatPresetMode.Arnold);
}

public func RFC_ArcadeAllowedByWeapon(ad: ref<AttackData>, cfg: RFCConfig) -> Bool {
  if !IsDefined(ad) {
    return false;
  }

  let at: gamedataAttackType = ad.GetAttackType();

  // Melee has its own Arcade toggle and force controls. It no longer silently
  // depends on the bullet master toggle.
  if RFC_ArcadeIsMeleeAttack(ad) && !cfg.arcadeMeleeEnabled {
    return false;
  }

  // Never arcade shove vehicles or explosions
  if ad.HasFlag(hitFlag.VehicleImpact) {
    return false;
  }
  if AttackData.IsExplosion(at) || AttackData.IsAreaOfEffect(at) || ad.HasFlag(hitFlag.Explosion) {
    return false;
  }

  let w: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;

  // No-weapon melee includes fists and some Gorilla Arms/incap hits.
  // Keep grenade/throwable no-weapon hits blocked, but allow true melee.
  if !IsDefined(w) {
    if RFC_ArcadeIsMeleeAttack(ad) {
      return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowBlunt || cfg.arcadeAllowBlade;
    }
    // Several valid ranged attacks (including some modded/iconic weapons) lose
    // their WeaponObject before this callback. Named Arcade modes must not turn
    // those bullets into a silent no-op merely because they cannot be grouped.
    return RFC_ArcadeNamedModeAllowsUnknownBullet(cfg);
  }

  let iid: ItemID = w.GetItemID();
  let id: TweakDBID = iid.GetTDBID();

  if !TDBID.IsValid(id) {
    if RFC_ArcadeIsMeleeAttack(ad) {
      return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowBlade || cfg.arcadeAllowBlunt;
    }
    return !cfg.arcadeUseWeaponAllowList || RFC_ArcadeNamedModeAllowsUnknownBullet(cfg);
  }

  if RFC_ListHas(RFC_Arcade_List_Shotgun(), id) { return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowShotgun; }
  if RFC_ListHas(RFC_Arcade_List_Sniper(), id) { return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowSniper; }
  if RFC_ListHas(RFC_Arcade_List_Handgun(), id) { return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowHandgun; }
  if RFC_ListHas(RFC_Arcade_List_Magnum(), id) { return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowMagnum; }
  if RFC_ListHas(RFC_Arcade_List_SMG(), id) { return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowSMG; }
  if RFC_ListHas(RFC_Arcade_List_AR(), id) { return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowAR; }
  if RFC_ListHas(RFC_Arcade_List_LMG(), id) { return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowLMG; }
  if RFC_ListHas(RFC_Arcade_List_Blunt(), id) { return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowBlunt; }
  if RFC_ListHas(RFC_Arcade_List_Blade(), id) { return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowBlade; }

  // Final melee fallback by attack type
  if RFC_ArcadeIsMeleeAttack(ad) {
    return !cfg.arcadeUseWeaponAllowList || cfg.arcadeAllowBlade || cfg.arcadeAllowBlunt;
  }

  return !cfg.arcadeUseWeaponAllowList || RFC_ArcadeNamedModeAllowsUnknownBullet(cfg);
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

  // No WeaponObject includes thrown items, but true melee here is fists/Gorilla.
  if !IsDefined(w) {
    if RFC_ArcadeIsMeleeAttack(ad) {
      return cfg.arcadeMulBlunt;
    }
    return 0.0;
  }

  let id: TweakDBID = w.GetItemID().GetTDBID();
  if !TDBID.IsValid(id) {
    if RFC_ArcadeIsMeleeAttack(ad) {
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

  if RFC_ArcadeIsMeleeAttack(ad) {
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
  if !IsDefined(npc) {
    return;
  }

  if RFC_TimeDilationBlocksImpulses(npc, cfg) {
    return;
  }

  if RFC_IsVehicleContext(npc) {
    return;
  }

  if npc.IsDead() {
    return;
  }

  let rfcIncapHit: Bool = npc.IsIncapacitated();
  if rfcIncapHit && !cfg.arcadeIncapRagdollEnabled {
    return;
  }

  if !RFC_ArcadeChannelEnabled(npc.rfc_lastAttack, cfg) {
    return;
  }
  if !RFC_EnemyAllowsArcade(npc, cfg) {
    return;
  }

  if !ScriptedPuppet.CanRagdoll(npc) && !rfcIncapHit && !RFC_EnemyCanBypassCanRagdoll(npc, cfg) {
    return;
  }

  RFC_TryStopWorkspot(npc);
  if RFC_IsVehicleContext(npc) {
    return;
  }

  if cfg.arcadeBulletCooldown > 0.0 && npc.m_RFC_ArcadeKickDone {
    let nowArcade: Float = EngineTime.ToFloat(GameInstance.GetSimTime(npc.GetGame()));
    if nowArcade - npc.m_RFC_ArcadeDeathT >= cfg.arcadeBulletCooldown {
      npc.m_RFC_ArcadeKickDone = false;
    } else if RFC_ArcadeCanResetLatch(npc) {
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
  if RFC_IsVehicleContext(npc) {
    return;
  }

  let rfcForceDelay: Float = rfcIncapHit ? RFC_ClampT(cfg.arcadeIncapRagdollDelay) : 0.0;

  ds.DelayEvent(npc, CreateForceRagdollEvent(n"Splat_ArcadeHit"), rfcForceDelay, false);
  // One short confirmation wake keeps the known-working Arcade handoff without
  // restoring the old long 0.08-second wake train that could disturb settling.
  ds.DelayEvent(npc, CreateForceRagdollEvent(n"Splat_ArcadeHit"), rfcForceDelay + 0.025, false);

  let dir: Vector4 = hitPos - srcPos;
  let len: Float = MaxF(0.001, RFC_Length3(dir));
  let nx: Float = dir.X / len;
  let ny: Float = dir.Y / len;

  let isCow: Bool = RFC_IsCoweringStrict(npc);
  let cowScale: Float = isCow ? MaxF(0.0, cfg.arcadeCowScale) : 1.0;

  let mul: Float = RFC_ArcadeWeaponMul(npc.rfc_lastAttack, cfg);
  if mul <= 0.0 {
    return;
  }

  let enemyScale: Float = RFC_EnemyArcadeScale(npc, cfg);
  if enemyScale <= 0.0 {
    return;
  }

  let isMelee: Bool = RFC_ArcadeIsMeleeAttack(npc.rfc_lastAttack);
  let baseStrength: Float = isMelee ? cfg.arcadeMeleeStrength : cfg.arcadeBulletStrength;
  let vertical: Float = isMelee
    ? (cfg.arcadeMeleeUp - cfg.arcadeMeleeDown)
    : (cfg.arcadeBulletUp - cfg.arcadeBulletDown);

  let s: Float = baseStrength * cowScale * mul * enemyScale;
  if s == 0.0 && vertical == 0.0 {
    return;
  }

  let impulse: Vector4 = new Vector4(
    nx * s,
    ny * s,
    vertical * cowScale * enemyScale,
    1.0
  );

  let configuredRadius: Float = isMelee ? cfg.arcadeMeleeRadius : cfg.arcadeBulletRadius;
  let r: Float = (configuredRadius > 0.0) ? configuredRadius : 0.60;
  let applyPos: Vector4 = RFC_ArcadeApplicationPoint(
    npc,
    hitPos,
    cfg.arcadeApplicationPointOffset
  );

  ds.DelayEvent(
    npc,
    CreateRagdollApplyImpulseEvent(applyPos, impulse, r),
    // The impulse must arrive after the ragdoll bodies exist. Scheduling both
    // events for the same frame made Arcade OnHit look completely disabled.
    MaxF(RFC_ClampT(cfg.arcadeImpulseDelay), rfcForceDelay + 0.040),
    false
  );

  if cfg.arcadeBulletCooldown > 0.0 {
    npc.m_RFC_ArcadeKickDone = true;
    npc.m_RFC_ArcadeDeathT = EngineTime.ToFloat(GameInstance.GetSimTime(npc.GetGame()));
  } else {
    npc.m_RFC_ArcadeKickDone = false;
    npc.m_RFC_ArcadeDeathT = 0.0;
  }
}

@addMethod(NPCPuppet)
protected cb func OnRFC_HitReactionGuardEvent(evt: ref<RFC_HitReactionGuardEvent>) -> Bool {
  if !IsDefined(evt) || RFC_IsVehicleContext(this) {
    return true;
  }

  let cfg: RFCConfig = RFC.Cfg();
  if cfg.vanillaMode || RFC_TimeDilationBlocksImpulses(this, cfg) {
    return true;
  }

  // Arcade is independent from reaction suppression and timed cutoff.
  if evt.allowArcadeImpulse
    && cfg.arcadeOnHitEnabled
    && RFC_ArcadeChannelEnabled(evt.attackData, cfg) {
    this.rfc_lastAttack = evt.attackData;
    RFC_ArcadeApplyOnHit(this, evt.hitPos, evt.srcPos, cfg);
  }

  // Timed cutoff owns only ordinary live reactions. Incapacitation and death
  // remain with their dedicated lifecycle pipelines.
  if !evt.allowAnimationCut
    || cfg.hitReactionsDisabled
    || !cfg.hitReactionCutoffEnabled
    || this.IsDead()
    || RFC_IsIncapacitatedTransition(this) {
    return true;
  }

  let cutEvt: ref<RFC_HitReactionCutEvent> = new RFC_HitReactionCutEvent();
  let cutDS: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
  if IsDefined(cutDS) {
    cutDS.DelayEvent(this, cutEvt, RFC_ClampT(cfg.hitReactionCutoffDelay), false);
  } else {
    this.QueueEvent(cutEvt);
  }
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnRFC_HitReactionCutEvent(evt: ref<RFC_HitReactionCutEvent>) -> Bool {
  if !IsDefined(evt)
    || RFC_IsVehicleContext(this)
    || this.IsDead()
    || RFC_IsIncapacitatedTransition(this) {
    return true;
  }

  let cfg: RFCConfig = RFC.Cfg();
  if cfg.vanillaMode || RFC_TimeDilationBlocksImpulses(this, cfg) || cfg.hitReactionsDisabled || !cfg.hitReactionCutoffEnabled {
    return true;
  }

  RFC_StopOrdinaryHitReaction(this);
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnRFC_InjuryShockEvent(evt: ref<RFC_InjuryShockEvent>) -> Bool {
  let cfg: RFCConfig;
  let ds: ref<DelaySystem>;
  let getUpDelay: Float;

  // Match the confirmed standalone behavior: the pending latch ends when the
  // delayed collapse starts; the hold latch owns only minimum ground time.
  this.m_RFC_InjuryShockPending = false;

  if !IsDefined(evt)
    || RFC_IsVehicleContext(this)
    || this.IsDead()
    || this.IsIncapacitated() {
    this.m_RFC_InjuryShockHoldActive = false;
    return true;
  }

  cfg = RFC.Cfg();
  if cfg.vanillaMode
    || RFC_TimeDilationBlocksImpulses(this, cfg)
    || !cfg.injuryShockEnabled
    || !RFC_InjuryShockActorClassAllowed(this, cfg)
    || !ScriptedPuppet.CanRagdoll(this) {
    this.m_RFC_InjuryShockHoldActive = false;
    return true;
  }

  getUpDelay = ClampF(cfg.injuryShockGetUpDelay, 0.0, 50.0)
    + RandRangeF(0.0, ClampF(cfg.injuryShockGetUpRandomDelay, 0.0, 50.0));

  ds = GameInstance.GetDelaySystem(this.GetGame());
  this.m_RFC_InjuryShockHoldActive = getUpDelay > 0.0;

  if IsDefined(ds) {
    // Ordinary live-NPC ragdoll only. The game's native recovery loop remains
    // responsible for standing up and returning the actor to its original AI.
    ds.DelayEvent(this, CreateForceRagdollEvent(n"Splat_InjuryShock"), 0.000, false);

    if this.m_RFC_InjuryShockHoldActive {
      ds.DelayEvent(this, new RFC_InjuryShockResetEvent(), getUpDelay, false);
    }
  } else {
    this.QueueEvent(CreateForceRagdollEvent(n"Splat_InjuryShock"));
    this.m_RFC_InjuryShockHoldActive = false;
  }

  return true;
}

@addMethod(NPCPuppet)
protected cb func OnRFC_InjuryShockResetEvent(evt: ref<RFC_InjuryShockResetEvent>) -> Bool {
  // Do not force Combat/Flee/Alerted and do not queue another ragdoll-state
  // event. Clearing the hold lets the already-running native recovery loop
  // return control to the actor's regular AI.
  this.m_RFC_InjuryShockPending = false;
  this.m_RFC_InjuryShockHoldActive = false;
  return true;
}

// Legacy bullet kick system removed. SHHJM Hit Jolts are the only bullet jolt path.

// Explosions

private func RFC_ApplyAliveExplosionImpulse(
  sp: wref<ScriptedPuppet>,
  hitPos: Vector4,
  blastPos: Vector4,
  radial: Float,
  swirl: Float,
  vertical: Float,
  radius: Float,
  callDelay: Float
) -> Void {
  if !IsDefined(sp) {
    return;
  }
  if radial == 0.0 && swirl == 0.0 && vertical == 0.0 {
    return;
  }
  if RFC_IsVehicleContext(sp) {
    return;
  }

  let c: RFCConfig = RFC.Cfg();
  if RFC_TimeDilationBlocksImpulses(sp, c) {
    return;
  }

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(sp.GetGame());
  if !IsDefined(ds) {
    return;
  }

  // True ground-plane radial direction from AttackData's blast center to the NPC.
  // Swirl is the perpendicular tangent and vertical is independent, so a
  // vertical-only explosion still works when Radial strength is zero.
  let p: Vector4 = sp.GetWorldPosition();
  let sourcePos: Vector4 = blastPos;
  if AbsF(sourcePos.X) < 0.001 && AbsF(sourcePos.Y) < 0.001 && AbsF(sourcePos.Z) < 0.001 {
    sourcePos = hitPos;
  }

  let rx: Float = p.X - sourcePos.X;
  let ry: Float = p.Y - sourcePos.Y;
  let rLen: Float = SqrtF(rx * rx + ry * ry);

  if rLen < 0.0001 {
    let fwd: Vector4 = sp.GetWorldForward();
    rx = fwd.X;
    ry = fwd.Y;
    rLen = SqrtF(rx * rx + ry * ry);
  }
  if rLen < 0.0001 {
    rx = 0.0;
    ry = 1.0;
    rLen = 1.0;
  }

  let nx: Float = rx / rLen;
  let ny: Float = ry / rLen;
  let tx: Float = -ny;
  let ty: Float = nx;

  let baseX: Float = (nx * radial) + (tx * swirl);
  let baseY: Float = (ny * radial) + (ty * swirl);
  let rMax: Float = MaxF(0.01, radius);
  let r0: Float = MaxF(0.008, rMax * 0.12);
  let r1: Float = MaxF(r0 + 0.006, rMax * 0.38);
  let r2: Float = rMax;
  let t0: Float = MaxF(0.0, callDelay);

  // One activation is enough to hand the NPC to ragdoll. The three decreasing
  // radial pulses restore the old explosion throw without repeatedly restarting
  // the death/settle cycle.
  let v0: Vector4 = new Vector4(baseX, baseY, vertical, 1.0);
  let v1: Vector4 = new Vector4(baseX * 0.85, baseY * 0.85, vertical * 0.85, 1.0);
  let v2: Vector4 = new Vector4(baseX * 0.70, baseY * 0.70, vertical * 0.70, 1.0);

  ds.DelayEvent(sp, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), t0, false);
  ds.DelayEvent(sp, CreateRagdollApplyImpulseEvent(hitPos, v0, r0), t0 + 0.010, false);
  ds.DelayEvent(sp, CreateRagdollApplyImpulseEvent(hitPos, v1, r1), t0 + 0.040, false);
  ds.DelayEvent(sp, CreateRagdollApplyImpulseEvent(hitPos, v2, r2), t0 + 0.080, false);
}

// Grenade / explosion ragdoll shove
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

  let at: gamedataAttackType = ad.GetAttackType();
  let nativeExplosion: Bool = AttackData.IsExplosion(at)
    || AttackData.IsAreaOfEffect(at)
    || Equals(at, gamedataAttackType.PressureWave);
  let w: ref<WeaponObject> = ad.GetWeapon() as WeaponObject;

  // Explosive bullets normally keep a WeaponObject but reach this callback as
  // a non-explosion attack carrying hitFlag.Explosion. The old classifier never
  // returned Bullet at all, so Realism Custom could silently route them through
  // the disabled Weapon source while the named modes appeared to work because
  // every source filter was enabled there.
  if ad.HasFlag(hitFlag.Explosion) && !nativeExplosion && IsDefined(w) {
    return RFC_ExplSrc.Bullet;
  }

  // Native weapon explosions keep their weapon object. Grenades and pressure
  // waves normally do not, so they remain in the Grenade lane.
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
  if RFC_TimeDilationBlocksImpulses(puppet, cfg) {
    return;
  }
  if RFC_IsVehicleContext(puppet) {
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

  if RFC_IsVehicleContext(puppet) {
    return;
  }

  puppet.QueueEvent(CreateRagdollApplyImpulseEvent(hitPos, v0, r0));
  puppet.QueueEvent(CreateRagdollApplyImpulseEvent(hitPos, v1, r1));
  puppet.QueueEvent(CreateRagdollApplyImpulseEvent(hitPos, v2, r2));
}

@addMethod(NPCPuppet)
protected cb func OnRFC_TryGrenadeKickEvent(evt: ref<RFC_TryGrenadeKickEvent>) -> Bool {
  let cfg: RFCConfig = RFC.Cfg();

  if cfg.vanillaMode || !IsDefined(evt) || RFC_TimeDilationBlocksImpulses(this, cfg) {
    return true;
  }
  if RFC_IsVehicleContext(this) {
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
  let isExpl: Bool = RFC_IsGrenadeExplosion(this.rfc_lastAttack);
  let isVeh: Bool = this.rfc_lastAttack.HasFlag(hitFlag.VehicleImpact);

  if !isExpl && !isVeh {
    return true;
  }

  if RFC_GrenadeExceptionMatches(this.rfc_lastAttack, cfg) {
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
  if !IsDefined(puppet) {
    return;
  }
  if RFC_IsVehicleContext(puppet) {
    return;
  }
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

  if RFC_IsVehicleContext(puppet) {
    return;
  }

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
  if RFC_IsVehicleContext(puppet) {
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

  if RFC_IsVehicleContext(puppet) {
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

// One authoritative explosion/AOE classifier for every regular OnHit lane.
// Regular bullet jolts, Arcade bullet push, Injury Shock, Head Falls, Body Falls,
// and situation death impulses must never piggyback on an explosion hit.
private func RFC_IsGrenadeExplosion(ad: ref<AttackData>) -> Bool {
  if !IsDefined(ad) {
    return false;
  }

  let at: gamedataAttackType = ad.GetAttackType();
  return Equals(at, gamedataAttackType.PressureWave)
    || AttackData.IsExplosion(at)
    || AttackData.IsAreaOfEffect(at)
    || ad.HasFlag(hitFlag.Explosion);
}



private func RFC_SHHJM_ResolveOrDeadFallback(p: ref<NPCPuppet>, evt: ref<gameHitEvent>, hitPos: Vector4, s: ref<SHHJM_Settings>, out part: Int32, out anchorPos: Vector4) -> Bool {
  // Prefer the game's authoritative hit-reaction zone. This directly separates
  // Head, Torso, LeftArm, RightArm, LeftLeg, and RightLeg instead of relying
  // only on proximity after the corpse has rotated or slid.
  if SHHJM_ResolveBodyPartFromHitEvent(p, evt, hitPos, part, anchorPos) {
    return true;
  };

  // Spatial fallback for unusual/synthetic hit events with no hit-shape data.
  if SHHJM_ResolveBodyPart(p, hitPos, part, anchorPos) {
    return true;
  };

  // Do not collapse an unknown corpse hit into the torso lane. If neither the
  // hit-zone index nor the spatial resolver can identify the part, skip it.
  return false;
}

private func RFC_SHHJM_HardBlockHit(p: wref<NPCPuppet>, ad: ref<AttackData>) -> Bool {
  // Keep the true hard blocks only. Do not use the ground/height probe as a
  // hidden cooldown: after a strong jolt the corpse can be airborne or tilted,
  // and the old probe made later bullets look like they were being ignored.
  if !IsDefined(p) { return true; }
  if RFC_IsVehicleContext(p) { return true; }
  if RFC_Explode_IsRecent(p) { return true; }

  if IsDefined(ad) {
    if RFC_IsGrenadeExplosion(ad) || RFC_IsVehicleHit(ad) {
      return true;
    }
  }

  return false;
}

@wrapMethod(NPCPuppet)
protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
  let res: Bool;
  let c: RFCConfig = RFC.Cfg();
  let s: ref<SHHJM_Settings>;
  let hitPos: Vector4;
  let shhjmSrcPos: Vector4;
  let anchorPos: Vector4;
  let part: Int32;
  let shhjmHardBlock: Bool;
  let shhjmQueued: Bool;
  let shhjmRuntimeEnabled: Bool;
  let injuryShockPart: Int32;
  let injuryShockAnchor: Vector4;
  let injuryShockQueued: Bool;
  let vanillaWeaponReactionCandidate: Bool;
  let savedSkipDeathAnimation: Bool;
  let savedForceRagdollOnDeath: Bool;

  if !IsDefined(evt) {
    return wrappedMethod(evt);
  }

  // VANILLA = RIG ONLY.
  // Do not write ANY SPLAT animation, hit-reaction, death, workspot, impulse,
  // or ragdoll-control state here. The installed ragdoll rig remains the only
  // intentional SPLAT exception; script behavior is 100% base-game.
  if c.vanillaMode {
    return wrappedMethod(evt);
  }

  // Preserve damage and the original hit callback, but suppress every SPLAT
  // follow-up while time dilation owns the frame. Vanilla physical impulse is
  // independently zeroed in VanillaImpulseKiller.reds.
  if RFC_TimeDilationBlocksImpulses(this, c) {
    return wrappedMethod(evt);
  }
  // v9 vehicle occupant lane:
  // Do NOT swallow direct hits on a mounted driver/passenger. v8 proved that
  // hard immunity prevents bullets from killing the seated NPC. Instead, let
  // the vanilla NPC damage/death pipeline run, then stop here so SPLAT does not
  // add seated arcade/ragdoll impulses while the vehicle seat/workspot still
  // owns the puppet.
  //
  // Car/window/body hits are still handled separately by VehicleObject.OnHit.
  // The v8 TweakDB DriverKill block remains in place so shooting the car itself
  // does not create the synthetic Attacks.DriverKill puppet hit too early.
  if RFC_IsVehicleContext(this) {
    // SPLAT_BVC_COMBINED_20260818
    // Mounted rider hits bypass SPLAT's motorcycle arm/consume/death path.
    // Exact BVC1604 ScriptedPuppet.OnHit owns rider + motorcycle handling.
    return wrappedMethod(evt);
  }

  this.rfc_vanillaDeathAnimArmed = false;

  // Capture the current attack and arm the explosion isolation window BEFORE
  // vanilla OnHit runs. A lethal hit can enter NPCPuppet.OnDeath from inside
  // wrappedMethod(evt); marking afterward is too late and lets the ordinary
  // Head/Body/Situation/Arcade/Jolt death lanes run on an explosion.
  if IsDefined(evt.attackData) {
    this.rfc_lastAttack = evt.attackData;
    if RFC_IsGrenadeExplosion(evt.attackData) {
      RFC_Explode_MarkAt(this, evt.hitPosition, 2.00);
    } else {
      // A later bullet/melee hit must immediately end the old explosion
      // quarantine. Otherwise the two-second marker misclassifies that new
      // lethal hit and bypasses the normal death/workspot handoff.
      RFC_Explode_Clear(this);
    }
  } else {
    RFC_Explode_Clear(this);
  }

  // Selected Vanilla Impulse weapons must restore the actual native death
  // reaction BEFORE wrappedMethod(evt) processes a potentially lethal hit.
  //
  // Returning early from DeathRouter is too late by itself: the base hit
  // reaction chooses Death vs ForcedRagdoll from ShouldSkipDeathAnimation()
  // and ForceRagdollOnDeath while wrappedMethod(evt) is executing.
  vanillaWeaponReactionCandidate =
    IsDefined(evt.attackData)
    && c.vanillaImpulsesEnabled
    && RFC_VanillaImpulseAllowedByWeapon(evt.attackData, c);

  if vanillaWeaponReactionCandidate {
    this.rfc_vanillaDeathAnimArmed = true;

    savedSkipDeathAnimation = this.ShouldSkipDeathAnimation();
    savedForceRagdollOnDeath =
      this.GetPuppetStateBlackboard().GetBool(
        GetAllBlackboardDefs().PuppetState.ForceRagdollOnDeath
      );

    this.SetSkipDeathAnimation(false);
    NPCPuppet.ChangeForceRagdollOnDeath(this, false);
  }

  // SHHJM pre-wrap capture. This is now hard-gated by the Bullet Jolts
  // runtime switch and the visible Enable Bullet Jolts toggle, so OFF cannot
  // leak delayed ground jolts from pending SHHJM events.
  s = SPLATSettingsRuntime.Jolts();
  shhjmRuntimeEnabled = !c.vanillaMode && c.bulletJoltsEnabled && RFC_EnemyAllowsBulletJolts(this, c);
  shhjmHardBlock = !shhjmRuntimeEnabled || RFC_SHHJM_HardBlockHit(this, evt.attackData);
  this.shhjm_lastHitValid = false;
  this.shhjm_lastBodyPart = 99;

  hitPos = evt.hitPosition;
  shhjmSrcPos = RFC_SHHJM_SourcePos(this, evt.attackData, hitPos);

  if shhjmRuntimeEnabled && !shhjmHardBlock && RFC_SHHJM_ResolveOrDeadFallback(this, evt, hitPos, s, part, anchorPos) && SHHJM_GetPartEnabled(part, s) {
    this.shhjm_lastHitValid = true;
    this.shhjm_lastHitPos = hitPos;
    this.shhjm_lastSrcPos = shhjmSrcPos;
    this.shhjm_lastAnchorPos = anchorPos;
    this.shhjm_lastBodyPart = part;
  }

  res = wrappedMethod(evt);

  // A selected Vanilla Impulse weapon owns the complete lethal reaction.
  //
  // If this hit killed the NPC, keep the native death-animation gates open
  // and return immediately. This prevents Bullet Jolts, Arcade On Hit,
  // reaction cutoff, Injury Shock, and other post-hit SPLAT work from forcing
  // ragdoll over the death animation we just restored.
  //
  // If the hit was nonlethal, restore the exact native state that existed
  // before this hit so the exception remains weapon-scoped.
  if vanillaWeaponReactionCandidate {
    if this.IsDead() {
      this.SetSkipDeathAnimation(false);
      NPCPuppet.ChangeForceRagdollOnDeath(this, false);
      return res;
    }

    this.SetSkipDeathAnimation(savedSkipDeathAnimation);
    NPCPuppet.ChangeForceRagdollOnDeath(this, savedForceRagdollOnDeath);
    this.rfc_vanillaDeathAnimArmed = false;
  }

  // The selected mode's Injury Shock toggle is authoritative. Clear any stale
  // per-NPC state immediately when it is off; queued events also recheck it.
  if !c.injuryShockEnabled {
    this.m_RFC_InjuryShockPending = false;
    this.m_RFC_InjuryShockHoldActive = false;
  }

  // SHHJM post-wrap scheduling. Re-resolve after wrappedMethod() because a
  // lethal bullet can turn a live NPC into a dead/ragdoll target after the
  // pre-wrap resolver already ran. This also restores the ground-wait path.
  if shhjmRuntimeEnabled && !shhjmHardBlock && !RFC_IsVehicleContext(this) {
    if !this.shhjm_lastHitValid && this.IsDead() {
      if RFC_SHHJM_ResolveOrDeadFallback(this, evt, hitPos, s, part, anchorPos) && SHHJM_GetPartEnabled(part, s) {
        this.shhjm_lastHitValid = true;
        this.shhjm_lastHitPos = hitPos;
        this.shhjm_lastSrcPos = shhjmSrcPos;
        this.shhjm_lastAnchorPos = anchorPos;
        this.shhjm_lastBodyPart = part;
      }
    }

    if this.shhjm_lastHitValid && this.IsDead() {
      SHHJM_QueueJolt(
        this,
        this.shhjm_lastBodyPart,
        this.shhjm_lastSrcPos,
        this.shhjm_lastAnchorPos,
        MaxF(0.001, SHHJM_GetHitDelay(this.shhjm_lastBodyPart, s) * MaxF(0.0, c.bulletJoltDelayScale)),
        s
      );
      shhjmQueued = true;
    }
  }

  // If the wrapped game hit changed the puppet into a vehicle workspot/mount,
  // stop here too. This keeps arcade/explosion follow-up impulses off drivers.
  if RFC_IsVehicleContext(this) {
    return res;
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

    if RFC_GrenadeExceptionMatches(ad, cfg) {
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

      // The same radial path handles living targets and targets killed by this
      // hit. It activates ragdoll first, then applies the configured radial,
      // swirl, Up/Down, radius, delay, and source multiplier values.
      RFC_ApplyAliveExplosionImpulse(
        this,
        hitPos,
        rfcSrcPos,
        cfg.grenadeKickX * mul,
        cfg.grenadeKickY * mul,
        cfg.grenadeKickZ * mul,
        cfg.grenadeKickRadius,
        cfg.grenadeKickCallDelay
      );
      return res;
    }

    return res;
  }

  // Vanilla Mode leaves the game's hit-reaction pipeline untouched.
  if cfg.vanillaMode {
    return res;
  }

  let allowArcadeImpulse: Bool = RFC_ArcadeChannelEnabled(ad, cfg)
    && cfg.arcadeOnHitEnabled
    && RFC_ArcadeAttackSourceAllowed(this, ad, cfg)
    && RFC_ArcadeAllowedByWeapon(ad, cfg);
  let isPlayerBulletReactionSource: Bool = RFC_IsPlayerAttack(this, ad)
    && RFC_IsBulletReactionCutSource(ad);
  let allowAnimationCut: Bool = isPlayerBulletReactionSource
    && cfg.hitReactionCutoffEnabled
    && !cfg.hitReactionsDisabled;

  // Injury Shock is separate from normal reaction cutoff. Arcade remains
  // independent and may apply on the same hit that queues the later collapse.
  if cfg.injuryShockEnabled
    && RFC_InjuryShockSourceAllowed(this, ad, cfg)
    && RFC_InjuryShockActorClassAllowed(this, cfg)
    && !this.IsDead()
    && !this.IsIncapacitated()
    && !this.m_RFC_InjuryShockPending
    && !this.m_RFC_InjuryShockHoldActive
    && cfg.injuryShockChance > 0.0
    && SHHJM_ResolveBodyPart(this, hitPos, injuryShockPart, injuryShockAnchor)
    && injuryShockPart != 0
    && (!cfg.injuryShockLimbsOnly || injuryShockPart >= 2)
    && RandF() < cfg.injuryShockChance {
    let shockDS: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
    let shockEvt: ref<RFC_InjuryShockEvent> = new RFC_InjuryShockEvent();
    let shockDelay: Float = ClampF(cfg.injuryShockDelay, 0.0, 50.0) + RandRangeF(0.0, ClampF(cfg.injuryShockRandomDelay, 0.0, 50.0));
    this.m_RFC_InjuryShockPending = true;
    injuryShockQueued = true;
    if IsDefined(shockDS) {
      shockDS.DelayEvent(this, shockEvt, shockDelay, false);
    } else {
      this.QueueEvent(shockEvt);
    }
  }

  // Ordinary cutoff and Arcade share one short guard so the vanilla reaction
  // task has time to start. Incapacitation remains on its lifecycle hook.
  if allowArcadeImpulse || allowAnimationCut || injuryShockQueued {
    let arcadeGuardDS: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
    let arcadeGuardEvt: ref<RFC_HitReactionGuardEvent> = new RFC_HitReactionGuardEvent();
    arcadeGuardEvt.hitPos = hitPos;
    arcadeGuardEvt.srcPos = rfcSrcPos;
    arcadeGuardEvt.attackData = ad;
    arcadeGuardEvt.allowAnimationCut = allowAnimationCut;
    arcadeGuardEvt.allowArcadeImpulse = allowArcadeImpulse;
    if IsDefined(arcadeGuardDS) {
      arcadeGuardDS.DelayEvent(this, arcadeGuardEvt, 0.050, false);
    } else {
      this.QueueEvent(arcadeGuardEvt);
    }
  }

  return res;
}
