module RealisticPush

@addField(NPCPuppet) private let m_RFC_ShoulderWaistImpactDone: Bool;
@addField(NPCPuppet) public let rfc_deadRagdollActivationHandled: Bool;

public func RFC_ResetDeadRagdollActivationLatch(p: wref<NPCPuppet>) -> Void {
  if IsDefined(p) { p.rfc_deadRagdollActivationHandled = false; }
}

public class RFC_ShoulderWaistDelayedFallEvent extends Event {
  public let shoulderStrength: Float;
  public let waistStrength: Float;
  public let radius: Float;
}

private func RFC_GetShoulderWaistSlotPos(
  p: wref<NPCPuppet>,
  slotName: CName,
  out pos: Vector4
) -> Bool {
  let slotComponent: ref<SlotComponent>;
  let slotTransform: WorldTransform;

  if !IsDefined(p) {
    return false;
  }

  slotComponent = p.GetSlotComponent();
  if !IsDefined(slotComponent) || !slotComponent.GetSlotTransform(slotName, slotTransform) {
    return false;
  }

  pos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
  return true;
}

public func RFC_ApplyShoulderWaistFall(
  p: wref<NPCPuppet>,
  shoulderStrength: Float,
  hipStrength: Float,
  radius: Float
) -> Void {
  let basePos: Vector4;
  let shoulderPos: Vector4;
  let hipPos: Vector4;
  let leftHipPos: Vector4;
  let rightHipPos: Vector4;
  let gotLeftHip: Bool;
  let gotRightHip: Bool;
  let leftShoulderPos: Vector4;
  let rightShoulderPos: Vector4;
  let gotLeftShoulder: Bool;
  let gotRightShoulder: Bool;

  if !IsDefined(p) || RFC_IsVehicleContext(p) || RFC_TimeDilationBlocksImpulsesNow(p) {
    return;
  }

  basePos = p.GetWorldPosition();
  gotLeftShoulder = RFC_GetShoulderWaistSlotPos(p, n"LeftShoulder", leftShoulderPos);
  gotRightShoulder = RFC_GetShoulderWaistSlotPos(p, n"RightShoulder", rightShoulderPos);
  if gotLeftShoulder && gotRightShoulder {
    shoulderPos = new Vector4(
      (leftShoulderPos.X + rightShoulderPos.X) * 0.50,
      (leftShoulderPos.Y + rightShoulderPos.Y) * 0.50,
      (leftShoulderPos.Z + rightShoulderPos.Z) * 0.50,
      1.0
    );
  } else {
    if !RFC_GetShoulderWaistSlotPos(p, n"Spine3", shoulderPos)
      && !RFC_GetShoulderWaistSlotPos(p, n"Chest", shoulderPos) {
      shoulderPos = basePos;
      shoulderPos.Z += 1.12;
    }
  }

  if !RFC_GetShoulderWaistSlotPos(p, n"Hips", hipPos) {
    if !RFC_GetShoulderWaistSlotPos(p, n"Pelvis", hipPos) {
      gotLeftHip = RFC_GetShoulderWaistSlotPos(p, n"LeftUpLeg", leftHipPos);
      gotRightHip = RFC_GetShoulderWaistSlotPos(p, n"RightUpLeg", rightHipPos);
      if gotLeftHip && gotRightHip {
        hipPos = new Vector4(
          (leftHipPos.X + rightHipPos.X) * 0.50,
          (leftHipPos.Y + rightHipPos.Y) * 0.50,
          (leftHipPos.Z + rightHipPos.Z) * 0.50,
          1.0
        );
      } else {
        if gotLeftHip {
          hipPos = leftHipPos;
        } else {
          if gotRightHip {
            hipPos = rightHipPos;
          } else {
            hipPos = basePos;
            hipPos.Z += 0.90;
          }
        }
      }
    }
  }

  if shoulderStrength > 0.0001 {
    p.QueueEvent(CreateRagdollApplyImpulseEvent(
      shoulderPos,
      new Vector4(0.0, 0.0, 0.0 - AbsF(shoulderStrength), 1.0),
      radius
    ));
  }

  if hipStrength > 0.0001 {
    p.QueueEvent(CreateRagdollApplyImpulseEvent(
      hipPos,
      new Vector4(0.0, 0.0, 0.0 - AbsF(hipStrength), 1.0),
      radius
    ));
  }
}

@addMethod(NPCPuppet)
protected cb func OnRFC_ShoulderWaistDelayedFallEvent(evt: ref<RFC_ShoulderWaistDelayedFallEvent>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  if !IsDefined(evt)
    || c.vanillaMode
    || RFC_TimeDilationBlocksImpulses(this, c)
    || !c.shoulderHipFallsEnabled
    || RFC_IsVehicleContext(this)
    || RFC_MasterDeathChanceBlocksImpulses(this) {
    return true;
  }

  RFC_ApplyShoulderWaistFall(
    this,
    evt.shoulderStrength,
    evt.waistStrength,
    evt.radius
  );
  return true;
}

public func RFC_ScheduleShoulderWaistFall(
  p: wref<NPCPuppet>,
  shoulderStrength: Float,
  waistStrength: Float,
  radius: Float,
  delay: Float
) -> Void {
  let ds: ref<DelaySystem>;
  let evt: ref<RFC_ShoulderWaistDelayedFallEvent>;

  if !IsDefined(p) || RFC_IsVehicleContext(p) {
    return;
  }

  if delay <= 0.0001 {
    RFC_ApplyShoulderWaistFall(p, shoulderStrength, waistStrength, radius);
    return;
  }

  ds = GameInstance.GetDelaySystem(p.GetGame());
  if !IsDefined(ds) {
    return;
  }

  evt = new RFC_ShoulderWaistDelayedFallEvent();
  evt.shoulderStrength = shoulderStrength;
  evt.waistStrength = waistStrength;
  evt.radius = radius;
  ds.DelayEvent(p, evt, MaxF(0.0, delay), false);
}

@wrapMethod(NPCPuppet)
protected cb func OnRagdollEnabledEvent(evt: ref<RagdollNotifyEnabledEvent>) -> Bool {
  let s: ref<GS_Settings> = SPLATSettingsRuntime.Body();
  let c: RFCConfig = RFC.Cfg();
  let ds0: ref<DelaySystem>;
  let first: ref<RFC_MicroBrake>;
  let pos2: Vector4;
  let chestPos2: Vector4;
  let pelvisPos2: Vector4;
  let fwd2: Vector4;
  let flat: Vector4;
  let v: Vector4;
  let vz: Float;
  let res: Bool = wrappedMethod(evt);

  // A death can receive several ForceRagdoll wake events. The engine has
  // already enabled ragdoll on the first callback; processing every later
  // notification again re-arms Head/Body/impact events and looks like a
  // never-ending body-part twitch. Run the death setup once per death.
  if this.IsDead() {
    if this.rfc_deadRagdollActivationHandled { return res; }
    this.rfc_deadRagdollActivationHandled = true;
  }

  this.m_RFC_ShoulderWaistImpactDone = false;

  // Explosion ragdolls are owned by the dedicated explosion path. Do not add
  // micro-brakes, wake pings, Head Falls, Body Falls, or shoulder/waist forces.
  if RFC_Explode_IsRecent(this) {
    return res;
  }

  if RFC_MasterDeathChanceBlocksImpulses(this) {
    return res;
  }

  // The engine already owns ragdoll activation, collision state, disposal, and
  // its dead-puppet settle checks. Do not inject generic chest/pelvis counter-
  // impulses from OnRagdollEnabledEvent: every later ForceRagdoll activation
  // can re-enter this callback and repeatedly disturb individual body parts.
  if c.vanillaMode || RFC_TimeDilationBlocksImpulses(this, c) {
    return res;
  }

  // GS forward / early-drop setup
  if !s.enabled && !c.shoulderHipFallsEnabled { return res; }

  this.gs_rollDone = false;
  this.gs_rollOK = false;
  this.gs_fbDone = false;
  this.gs_fbSign = 1.0;
  this.gs_forwardDo = false;
  this.gs_earlyForwardDo = false;
  this.gs_impactForwardDo = false;
  this.gs_impactDone = false;

  this.gs_earlyStepIdx = 0;
  this.gs_earlyStepMax = 0;

  GS_CacheMomentum(this, s);

  this.gs_forwardDo = s.enabled && s.forwardEnabled && GS_RollChancePct(s.forwardChancePct);
  this.gs_earlyForwardDo = s.enabled && s.earlyDropForwardEnabled && GS_RollChancePct(s.earlyDropForwardChancePct);

  this.gs_impactForwardDo = false;

  ds0 = GameInstance.GetDelaySystem(this.GetGame());
  if !IsDefined(ds0) { return res; }

  if this.gs_forwardDo {
    ds0.DelayEvent(this, new GS_ForwardEvt(), GS_Clamp(s.forwardDelaySec, 0.00, 2.00), false);
  }

if (s.enabled && s.earlyDropEnabled && this.rfc_allowBodyChest && !GS_OverrideChest(this, c))
  || c.shoulderHipEarlyFallEnabled {
  this.gs_earlyStepMax = Max(1, s.earlyDropSteps);
  this.gs_earlyStepIdx = 0;

  if s.earlyDropUseRamp && s.earlyDropSteps > 1 && s.earlyDropRampSec > 0.001 {
    GS_ScheduleRamp(ds0, this, s.earlyDropSteps, s.earlyDropDelaySec, s.earlyDropRampSec, false);
  } else {
    ds0.DelayEvent(this, new GS_EarlyStepEvt(), MaxF(0.001, s.earlyDropDelaySec), false);
  }
}

  return res;
}

private func RFC_ImpactNowT(p: ref<NPCPuppet>) -> Float {
  if !IsDefined(p) { return 0.0; }
  return EngineTime.ToFloat(GameInstance.GetSimTime(p.GetGame()));
}

private func RFC_ImpactIsStairsLane(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  if !IsDefined(p) { return false; }
  if !c.stairsEnabled { return false; }
  return RFC_IsOnStairs(p) || p.RFC_WasStairsRecent(1.25);
}

private func RFC_ImpactIsWSStandLane(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  if !IsDefined(p) { return false; }
  if !c.wsStandEnabled { return false; }
  return RFC_IsWorkspotOrPerch(p);
}

private func RFC_ImpactIsCowerLane(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  if !IsDefined(p) { return false; }
  if !c.cowerEnabled { return false; }
  return RFC_IsCoweringStrict(p);
}

private func RFC_ImpactIsRunLane(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  let nowT: Float;
  let walkRecent: Bool;
  let isRun: Bool;
  let isWalk: Bool;

  if !IsDefined(p) { return false; }
  if !c.runEnabled { return false; }

  nowT = RFC_ImpactNowT(p);
  walkRecent = p.rfc_walkLastSeen > 0.0 && ((nowT - p.rfc_walkLastSeen) <= 1.25);
  isRun = p.RFC_WasRunningRecent(1.25);
  isWalk = RFC_IsClearlyWalking(p) || RFC_IsWalking(p) || walkRecent;

  return isRun || isWalk;
}

private func RFC_ImpactOverrideForward(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  return GS_CurrentOverrideForward(p, c);
}

private func RFC_ImpactOverrideChest(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  return GS_CurrentOverrideChest(p, c);
}

@wrapMethod(NPCPuppet)
protected cb func OnRagdollImpactEvent(evt: ref<RagdollImpactEvent>) -> Bool {
  let gs: ref<GS_Settings> = SPLATSettingsRuntime.Body();
  let hs: ref<HIS_Settings> = SPLATSettingsRuntime.Head();
  let ds: ref<DelaySystem>;
  let c: RFCConfig = RFC.Cfg();
  let runMainImpact: Bool;
  let res: Bool = wrappedMethod(evt);
  c = RFC_RandomizeConfig(this, c);
  HIS_ApplyModeOverrides(hs, c);

  if c.vanillaMode || RFC_TimeDilationBlocksImpulses(this, c) {
    return res;
  }

  if RFC_Explode_IsRecent(this) {
    return res;
  }

  this.shhjm_lastGroundImpactTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  this.shhjm_hasGroundImpact = true;

  if RFC_MasterDeathChanceBlocksImpulses(this) {
    return res;
  }

  if c.shoulderHipImpactFallEnabled
    && !this.m_RFC_ShoulderWaistImpactDone
    && ((c.shoulderHipImpactShoulderEnabled && !this.rfc_blockShoulderFalls)
      || (c.shoulderHipImpactButtEnabled && !this.rfc_blockButtFalls)) {
    this.m_RFC_ShoulderWaistImpactDone = true;
    RFC_ScheduleShoulderWaistFall(
      this,
      (c.shoulderHipImpactShoulderEnabled && !this.rfc_blockShoulderFalls) ? c.shoulderHipImpactShoulderStrength : 0.0,
      (c.shoulderHipImpactButtEnabled && !this.rfc_blockButtFalls) ? c.shoulderHipImpactHipStrength : 0.0,
      c.shoulderHipImpactRadius,
      c.shoulderHipImpactDelay
    );
  }

  // The real engine impact event schedules the main Body Falls impact layer.
  runMainImpact = gs.enabled
    && gs.impactEnabled
    && this.rfc_allowBodyChest
    && !RFC_ImpactOverrideChest(this, c);

  if runMainImpact && !this.gs_impactDone {
    ds = GameInstance.GetDelaySystem(this.GetGame());
    if IsDefined(ds) {
      this.gs_impactDone = true;
      this.gs_impactStepMax = Max(1, gs.impactSteps);
      this.gs_impactStepIdx = 0;
      if runMainImpact && !RFC_ImpactOverrideForward(this, c) {
        this.gs_impactForwardDo = gs.impactForwardAlso && GS_RollChancePct(gs.impactForwardChancePct);
      } else {
        this.gs_impactForwardDo = false;
      }

      if gs.impactUseRamp && gs.impactSteps > 1 && gs.impactRampSec > 0.001 {
        GS_ScheduleRamp(ds, this, gs.impactSteps, gs.impactDelaySec, gs.impactRampSec, true);
      } else {
        ds.DelayEvent(this, new GS_ImpactStepEvt(), MaxF(0.001, gs.impactDelaySec), false);
      }
    }
  }

  // HIS impact / rebound
  if !this.rfc_allowHeadFalls { return res; }
  if !HIS_ShouldRun(this, hs) { return res; }

  if hs.enabled && hs.onGroundImpact && !this.hisDidForwardGround {
    if HIS_ShouldTriggerHeadImpulse(hs) {
      HIS_CaptureBasis(this);
      this.hisDidForwardGround = true;
      HIS_ScheduleMainSteps(this, hs, 0);
    } else {
      this.hisDidForwardGround = true;
    }
  }

  if hs.backEnabled && hs.backOnGroundImpact && !this.hisDidBackGround {
    if HIS_RollChancePct(hs.backChancePct) {
      HIS_CaptureBasis(this);
      this.hisDidBackGround = true;
      HIS_ScheduleMainSteps(this, hs, 1);
    } else {
      this.hisDidBackGround = true;
    }
  }

  if hs.enableRebound && hs.reboundOnImpact && !this.hisDidForwardRebound {
    if !hs.reboundRequiresHeadImpulse || this.hisHeadImpulseFired {
      if HIS_ShouldTriggerRebound(hs) {
        HIS_CaptureBasis(this);
        this.hisDidForwardRebound = true;
        HIS_ScheduleReboundSteps(this, hs, 0);
      } else {
        this.hisDidForwardRebound = true;
      }
    }
  }

  if hs.enableBackRebound && hs.backReboundOnImpact && !this.hisDidBackRebound {
    if !hs.backReboundRequiresHeadImpulse || this.hisBackHeadImpulseFired {
      if HIS_RollChancePct(hs.backReboundChancePct) {
        HIS_CaptureBasis(this);
        this.hisDidBackRebound = true;
        HIS_ScheduleReboundSteps(this, hs, 1);
      } else {
        this.hisDidBackRebound = true;
      }
    }
  }

  return res;
}
