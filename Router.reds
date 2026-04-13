module RealisticPush

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
  let isStealth: Bool = RFC_IsStealthOrFinisher(this);
  let gs: ref<GS_Settings> = new GS_Settings();
  let s: ref<HIS_Settings> = new HIS_Settings();
  let sh: ref<SHHJM_Settings> = new SHHJM_Settings();
  let res: Bool;
  let useDeathAnim: Bool = false;

  // GS state reset
  if gs.enabled {
    this.gs_impactDone = false;
    this.gs_rollDone = false;
    this.gs_rollOK = false;
    this.gs_fbDone = false;
    this.gs_fbSign = 1.0;
    this.gs_forwardDo = false;
    this.gs_earlyForwardDo = false;
    this.gs_impactForwardDo = false;

    this.gs_earlyStepIdx = 0;
    this.gs_earlyStepMax = 0;
    this.gs_impactStepIdx = 0;
    this.gs_impactStepMax = 0;
  }

  res = wrappedMethod(evt);

  // HIS reset and scheduling
  this.hisDidForwardGround = false;
  this.hisDidBackGround = false;
  this.hisDidForwardRebound = false;
  this.hisDidBackRebound = false;
  this.hisHeadImpulseFired = false;
  this.hisBackHeadImpulseFired = false;
  this.hisDeathStartTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));

  if HIS_ShouldRun(this, s) {
    if s.enabled && s.onDeath && HIS_ShouldTriggerHeadImpulse(s) {
      if !s.disableOnGround || s.disableOnGroundDelay > 0.00 || !HIS_IsOnGround(this) {
        HIS_CaptureBasis(this);
        HIS_ScheduleMainSteps(this, s, 0);
      };
    };

    if s.backEnabled && s.backOnDeath && HIS_RollChancePct(s.backChancePct) {
      if !s.backDisableOnGround || s.backDisableOnGroundDelay > 0.00 || !HIS_IsOnGround(this) {
        HIS_CaptureBasis(this);
        HIS_ScheduleMainSteps(this, s, 1);
      };
    };

    if s.enableRebound && !s.reboundRequiresHeadImpulse && !s.reboundOnImpact && HIS_ShouldTriggerRebound(s) {
      if !s.reboundDisableOnGround || s.reboundDisableOnGroundDelay > 0.00 || !HIS_IsOnGround(this) {
        HIS_CaptureBasis(this);
        this.hisDidForwardRebound = true;
        HIS_ScheduleReboundSteps(this, s, 0);
      };
    };

    if s.enableBackRebound && !s.backReboundRequiresHeadImpulse && !s.backReboundOnImpact && HIS_RollChancePct(s.backReboundChancePct) {
      if !s.backReboundDisableOnGround || s.backReboundDisableOnGroundDelay > 0.00 || !HIS_IsOnGround(this) {
        HIS_CaptureBasis(this);
        this.hisDidBackRebound = true;
        HIS_ScheduleReboundSteps(this, s, 1);
      };
    };
  };

  if this.shhjm_lastHitValid {
    if SHHJM_GetPartEnabled(this.shhjm_lastBodyPart, sh) {
      SHHJM_Sched(this, new SHHJM_OnDeathApplyEvt(), SHHJM_GetDeathDelay(this.shhjm_lastBodyPart, sh));
    };
  };

  // RFC early-out conditions after wrappedMethod so other OnDeath systems still run
  if RFC_IsVehicleContext(this) {
    return res;
  }

  if c.vanillaMode {
    return res;
  }

  if isStealth {
    if c.respectCinematics {
      return res;
    }

    if c.stealthRagdollsEnabled {
      RFC_Stealth_SchedForceRagdoll(this, c.stealthRagdollDelay);
    }

    return res;
  }

  if c.skipDeathAnim {
    useDeathAnim = false;
  } else {
    if c.deathAnimChance > 0.0 && RandF() < c.deathAnimChance {
      useDeathAnim = true;
    }
  }

  if useDeathAnim {
    let tCut: Float = MaxF(0.0, c.animCompatDelay);
    RFC_ScheduleCut(ds, this, tCut);

    if RFC_IsWorkspotOrPerch(this) {
      RFC_ScheduleCut(ds, this, tCut + 0.06);
    }
  } else {
    RFC_ScheduleCut(ds, this, 0.0);

    if RFC_IsWorkspotOrPerch(this) {
      RFC_ScheduleCut(ds, this, 0.06);
    }
  }

  RFC_DeathImpulseRouter.RunOnDeathImpulses(this, evt, ds, c);
  return res;
}
