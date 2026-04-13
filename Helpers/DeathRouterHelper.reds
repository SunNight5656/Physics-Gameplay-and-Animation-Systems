// r6/scripts/Splat/Helpers.reds
module RealisticPush


public class DSF_Time {
  public static func Now(game: GameInstance) -> Float {
    return EngineTime.ToFloat(GameInstance.GetSimTime(game));
  }
}


private func RFC_ClampT(t: Float) -> Float = MaxF(0.0, t);

@addField(NPCPuppet) private let rfcExplodeUntil: Float;
@addField(NPCPuppet) private let rfcExplodePos: Vector4;

public func RFC_Explode_MarkAt(p: wref<NPCPuppet>, pos: Vector4, dur: Float) -> Void {
  if !IsDefined(p) { return; }
  p.rfcExplodePos = pos;
  p.rfcExplodeUntil = DSF_Time.Now(p.GetGame()) + MaxF(0.0, dur);
}

public func RFC_Explode_IsRecent(p: wref<NPCPuppet>) -> Bool =
  IsDefined(p) && DSF_Time.Now(p.GetGame()) < p.rfcExplodeUntil;


@addMethod(NPCPuppet)
protected cb func OnRFC_MicroBrake(evt: ref<RFC_MicroBrake>) -> Bool {
  if !RFC_AllowRFC(this) { return true; }
  return true;
}

// ===== RFC hard block window =====
@addField(NPCPuppet) private let rfc_blockUntil: Float;

@addMethod(NPCPuppet)
public func RFC_BlockRFC(seconds: Float) -> Void {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  this.rfc_blockUntil = MaxF(this.rfc_blockUntil, now + seconds);
}

@addMethod(NPCPuppet)
public func RFC_IsRFCBlocked() -> Bool {
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  return now < this.rfc_blockUntil;
}

@addField(NPCPuppet) private let m_RFC_CorpseImpulseReady: Bool;

public class RFC_EnableCorpseImpulseEvent extends Event {}
@addMethod(NPCPuppet)
protected cb func OnRFC_EnableCorpseImpulseEvent(evt: ref<RFC_EnableCorpseImpulseEvent>) -> Bool {
  this.m_RFC_CorpseImpulseReady = true;
  return true;
}

public class RFC_MicroBrake extends Event {
  public let step: Int32; // 0..5
}



public class RFC_CutDeathAnimEvent extends Event {}
@addMethod(NPCPuppet)
protected cb func OnRFC_CutDeathAnimEvent(evt: ref<RFC_CutDeathAnimEvent>) -> Bool {
  if RFC_IsStealthOrFinisher(this) { return true; }

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
 
 if IsDefined(ds) {
    ds.DelayEvent(this, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), 0.00, false);
   // ds.DelayEvent(this, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), 0.64, false);
 //   ds.DelayEvent(this, CreateForceRagdollEvent(n"RFC_force_ragdoll_all"), 0.78, false);
  }
  return true;
}

private func RFC_ScheduleCut(ds: ref<DelaySystem>, p: wref<NPCPuppet>, t: Float) -> Void {
  if !IsDefined(ds) || !IsDefined(p) { return; }
  let t0: Float = MaxF(t, 0.0);
  ds.DelayEvent(p, new RFC_CutDeathAnimEvent(), t0, false);
}

public func RFC_ApplyHeadSlam(
  dsOpt: ref<DelaySystem>,
  p: wref<NPCPuppet>,
  headPos: Vector4,
  dirX: Float,
  dirY: Float,
  c: RFCConfig
) -> Void {
  if !IsDefined(p) { return; }
  if c.vanillaMode { return; }
  if !ScriptedPuppet.CanRagdoll(p) { return; }

  if !c.settleEnabled || c.settleRadius <= 0.0 || c.settleStrength <= 0.0 {
    return;
  }

  let ds: ref<DelaySystem> = IsDefined(dsOpt) ? dsOpt : GameInstance.GetDelaySystem(p.GetGame());
  if !IsDefined(ds) { return; }

  let strength: Float = c.settleStrength;
  let fwd:  Float = c.settleFwd;
  let down: Float = c.settleDown;

  // Mostly down, tiny forward bias so it feels like a neck snap, not a shove
  let headSlamImp: Vector4 = new Vector4(
    dirX * fwd * strength * 0.2,
    dirY * fwd * strength * 0.2,
    down * strength * 1.8,
    0.0
  );

  let tHead: Float = RFC_ClampT(c.settleDelay);

  ds.DelayEvent(
    p,
    CreateRagdollApplyImpulseEvent(headPos, headSlamImp, c.settleRadius),
    tHead,
    false
  );
}


public func RFC_ApplyLegUnfoldSettle(
  dsOpt: ref<DelaySystem>,
  p: wref<NPCPuppet>,
  leftShinPos: Vector4,
  rightShinPos: Vector4,
  leftFootPos: Vector4,
  rightFootPos: Vector4,
  dirX: Float,
  dirY: Float,
  c: RFCConfig
) -> Void {
  // Hard exits
  if !IsDefined(p) { return; }
  if c.vanillaMode { return; }
  if !c.settleEnabled { return; }
  if c.settleRadius <= 0.0 { return; }
  if !ScriptedPuppet.CanRagdoll(p) { return; }

  // Resolve DelaySystem
  let ds: ref<DelaySystem> = IsDefined(dsOpt) ? dsOpt : GameInstance.GetDelaySystem(p.GetGame());
  if !IsDefined(ds) { return; }

  // Use your existing settle tuning
  let strength: Float = c.settleStrength;
  let fwd:  Float = c.settleFwd;
  let down: Float = c.settleDown;

  // Legs: mostly down, a bit forward to pull them out from under the pelvis
  let shinImp: Vector4 = new Vector4(
    dirX * fwd * strength * 0.6,
    dirY * fwd * strength * 0.6,
    down * strength * 0.4,
    0.0
  );

  let footImp: Vector4 = new Vector4(
    dirX * fwd * strength * 0.9,
    dirY * fwd * strength * 0.9,
    down * strength * 0.6,
    0.0
  );

  // Fire a bit later than torso settle so the body has already dropped
  let tBase: Float = RFC_ClampT(c.settleDelay);
  let tShinL: Float = RFC_ClampT(tBase);
  let tShinR: Float = RFC_ClampT(tBase + 0.02);
  let tFootL: Float = RFC_ClampT(tBase + 0.04);
  let tFootR: Float = RFC_ClampT(tBase + 0.06);

  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(leftShinPos,  shinImp, c.settleRadius), tShinL, false);
  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(rightShinPos, shinImp, c.settleRadius), tShinR, false);
  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(leftFootPos,  footImp, c.settleRadius), tFootL, false);
  ds.DelayEvent(p, CreateRagdollApplyImpulseEvent(rightFootPos, footImp, c.settleRadius), tFootR, false);
}

public func RFC_ApplyGlobalSettle(
  ds: ref<DelaySystem>,
  puppet: ref<NPCPuppet>,
  headPos: Vector4,
  chestPos: Vector4,
  pelvisPos: Vector4,
  dirX: Float,
  dirY: Float,
  c: RFCConfig
) -> Void {
  // Master kill: if settle is disabled or has no power, do nothing.
  if !c.settleEnabled || c.settleRadius <= 0.0 || c.settleStrength <= 0.0 {
    return;
  };

  if !IsDefined(ds) {
    ds = GameInstance.GetDelaySystem(puppet.GetGame());
  };
  if !IsDefined(ds) {
    return;
  };

  let strength: Float = c.settleStrength;
  if strength <= 0.0 {
    return;
  };

  // ─────────────
  // Build direction from UI: forward + down
  // settleFwd / settleDown = ANGLE, not magnitude
  // ─────────────
  let dirBase: Vector4 = new Vector4(
    dirX * c.settleFwd,
    dirY * c.settleFwd,
    c.settleDown,
    0.0
  );

  let len: Float = dirBase.Length();
  if len <= 0.001 {
    return;
  };

  // Normalized direction
  let dir: Vector4 = new Vector4(
    dirBase.X / len,
    dirBase.Y / len,
    dirBase.Z / len,
    0.0
  );
}

private func RFC_ClearDeathTracking(p: wref<NPCPuppet>) -> Void {
  if !IsDefined(p) { return; }
  StatusEffectHelper.RemoveStatusEffect(p, t"WorkspotStatus.Death");
  StatusEffectHelper.RemoveStatusEffect(p, t"WorkspotStatus.SyncAnimation");
  StatusEffectHelper.RemoveStatusEffect(p, t"GameplayRestriction.Workspot");
}

public class RFC_PostDeathClean extends Event {}
@addMethod(NPCPuppet)
protected cb func OnRFC_PostDeathClean(evt: ref<RFC_PostDeathClean>) -> Bool {
  RFC_ClearDeathTracking(this);
  return true;
}

public class RFC_ForceRagdollSoon extends Event {}

private func RFC_SafeT(d: Float) -> Float {
  return MaxF(d, 0.030);
}

