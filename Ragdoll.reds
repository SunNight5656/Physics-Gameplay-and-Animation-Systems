module RealisticPush

@wrapMethod(NPCPuppet)
protected cb func OnRagdollEnabledEvent(evt: ref<RagdollNotifyEnabledEvent>) -> Bool {
  let s: ref<GS_Settings> = new GS_Settings();
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

  // RFC ragdoll wake / momentum cleanup
  if RFC_AllowRFC(this) {
    ds0 = GameInstance.GetDelaySystem(this.GetGame());
    if IsDefined(ds0) {
      first = new RFC_MicroBrake();
      first.step = 0;
      ds0.DelayEvent(this, first, 0.0, false);

      ds0.DelayEvent(this, new RFC_ForceRagdollSoon(), 0.000, false);
      ds0.DelayEvent(this, new RFC_ForceRagdollSoon(), 0.006, false);
      ds0.DelayEvent(this, new RFC_ForceRagdollSoon(), 0.014, false);
      ds0.DelayEvent(this, new RFC_ForceRagdollSoon(), 0.022, false);
      ds0.DelayEvent(this, new RFC_ForceRagdollSoon(), 0.040, false);

      pos2 = this.GetWorldPosition();

      chestPos2 = pos2;
      chestPos2.Z += 1.12;

      pelvisPos2 = pos2;
      pelvisPos2.Z += 0.95;

      fwd2 = this.GetWorldForward();
      flat = Vector4.Normalize(new Vector4(fwd2.X, fwd2.Y, 0.0, 0.0));

      RFC_CancelPlanarMomentum(ds0, this, chestPos2, pelvisPos2, flat.X, flat.Y);

      v = this.GetVelocity();
      if AbsF(v.Z) > 0.01 {
        vz = -v.Z * ClampF(1.0 + AbsF(v.Z) * 0.10, 1.0, 2.0);
        ds0.DelayEvent(
          this,
          CreateRagdollApplyImpulseEvent(chestPos2, new Vector4(0.0, 0.0, vz, 1.0), 0.85),
          0.000,
          false
        );
      }
    }
  }

  // GS forward / early-drop setup
  if !s.enabled { return res; }

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

  if !GS_OverrideForward(this, c) {
    this.gs_forwardDo = s.forwardEnabled && GS_RollChancePct(s.forwardChancePct);
    this.gs_earlyForwardDo = s.earlyDropForwardEnabled && GS_RollChancePct(s.earlyDropForwardChancePct);
  } else {
    this.gs_forwardDo = false;
    this.gs_earlyForwardDo = false;
  }

  this.gs_impactForwardDo = false;

  ds0 = GameInstance.GetDelaySystem(this.GetGame());
  if !IsDefined(ds0) { return res; }

  if this.gs_forwardDo {
    ds0.DelayEvent(this, new GS_ForwardEvt(), GS_Clamp(s.forwardDelaySec, 0.00, 2.00), false);
  }

if s.earlyDropEnabled && !GS_OverrideChest(this, c) {
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
  if RFC_ImpactIsStairsLane(p, c) { return c.stair_overrideGlobalForward; }
  if RFC_ImpactIsWSStandLane(p, c) { return c.wsStand_overrideGlobalForward; }
  if RFC_ImpactIsCowerLane(p, c) { return c.cow_overrideGlobalForward; }
  if RFC_ImpactIsRunLane(p, c) { return c.run_overrideGlobalForward; }
  return c.st_overrideGlobalForward;
}

private func RFC_ImpactOverrideChest(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  if RFC_ImpactIsStairsLane(p, c) { return c.stair_overrideGlobalChest; }
  if RFC_ImpactIsWSStandLane(p, c) { return c.wsStand_overrideGlobalChest; }
  if RFC_ImpactIsCowerLane(p, c) { return c.cow_overrideGlobalChest; }
  if RFC_ImpactIsRunLane(p, c) { return c.run_overrideGlobalChest; }
  return c.st_overrideGlobalChest;
}

@wrapMethod(NPCPuppet)
protected cb func OnRagdollImpactEvent(evt: ref<RagdollImpactEvent>) -> Bool {
  let gs: ref<GS_Settings> = new GS_Settings();
  let hs: ref<HIS_Settings> = new HIS_Settings();
  let ds: ref<DelaySystem>;
  let c: RFCConfig = RFC.Cfg();
  let res: Bool = wrappedMethod(evt);

  // GS impact / body impulses
  if gs.enabled && gs.impactEnabled && !this.gs_impactDone {
    ds = GameInstance.GetDelaySystem(this.GetGame());
    if IsDefined(ds) {
      if !RFC_ImpactOverrideChest(this, c) {
        this.gs_impactDone = true;
        this.gs_impactStepMax = Max(1, gs.impactSteps);
        this.gs_impactStepIdx = 0;

        if !RFC_ImpactOverrideForward(this, c) {
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
  }

  // HIS impact / rebound
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
