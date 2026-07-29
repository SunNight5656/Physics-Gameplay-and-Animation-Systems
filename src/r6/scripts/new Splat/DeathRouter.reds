module RealisticPush

@addField(NPCPuppet) public let rfc_masterDeathChanceDone: Bool;
@addField(NPCPuppet) public let rfc_masterDeathChancePass: Bool;

public func RFC_ResetMasterDeathChance(p: wref<NPCPuppet>) -> Void {
  if !IsDefined(p) { return; }
  p.rfc_masterDeathChanceDone = false;
  p.rfc_masterDeathChancePass = true;
}

public func RFC_MasterDeathChancePass(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  let chance01: Float;

  if !IsDefined(p) { return true; }
  if !c.masterDeathChanceEnabled {
    p.rfc_masterDeathChanceDone = true;
    p.rfc_masterDeathChancePass = true;
    return true;
  }

  if p.rfc_masterDeathChanceDone {
    return p.rfc_masterDeathChancePass;
  }

  p.rfc_masterDeathChanceDone = true;
  chance01 = ClampF(c.masterDeathChance, 0.0, 1.0);

  if chance01 <= 0.0 {
    p.rfc_masterDeathChancePass = false;
    return false;
  }

  if chance01 >= 1.0 {
    p.rfc_masterDeathChancePass = true;
    return true;
  }

  p.rfc_masterDeathChancePass = RandF() < chance01;
  return p.rfc_masterDeathChancePass;
}

public func RFC_MasterDeathChanceBlocksImpulses(p: wref<NPCPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  return p.rfc_masterDeathChanceDone && !p.rfc_masterDeathChancePass;
}

public func RFC_BlockAllDeathImpulseLanes(p: wref<NPCPuppet>) -> Void {
  if !IsDefined(p) { return; }
  p.rfc_allowHeadFalls = false;
  p.rfc_allowBodyForward = false;
  p.rfc_allowBodyChest = false;
}

// ─────────────────────────────────────────────────────────────────────────────
// OnDeath: branch routing + gravity-burst impulses everywhere
// ─────────────────────────────────────────────────────────────────────────────
@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
  let timeDilationBlocksImpulses: Bool;

  RFC_RandomResetProfile(this);
  c = RFC_RandomizeConfig(this, c);
  timeDilationBlocksImpulses = RFC_TimeDilationBlocksImpulses(this, c);

  RFC_ResetDeadRagdollActivationLatch(this);

  if RFC_IsVehicleContext(this) {
    let vehicleDeathResult: Bool = wrappedMethod(evt);
    RFC_CleanupFormerVehicleOccupantAfterDeath(this);
    return vehicleDeathResult;
  }

  let isStealth: Bool = RFC_IsStealthOrFinisherEx(this, c.blackwallCountsAsStealth);
  // Vanilla / rigs-only still needs the old death-lane cut. The known-good
  // pipeline allowed the original death first, then immediately forced the
  // animation-to-ragdoll handoff so the native settle reaction could not loop.
  if c.vanillaMode {
    let vanillaResult: Bool = wrappedMethod(evt);
    RFC_ScheduleCut(ds, this, 0.0);
    return vanillaResult;
  }

  // Snapshot the exact explosion lane, but do not return before the original
  // death callback. The old early return skipped SPLAT's workspot release and
  // dedicated explosion kick, which could leave workspot victims stuck and
  // visually unharmed even though the damage pipeline had completed.
  let isExplosionDeath: Bool = RFC_Explode_IsRecent(this);


  // STEALTH / FINISHER / (optional) BLACKWALL
  if isStealth {
    // Keep cinematic kills intact (no cut)
    if c.respectCinematics { return wrappedMethod(evt); }

    let resStealth: Bool = wrappedMethod(evt);

    if timeDilationBlocksImpulses {
      // ForceRagdoll is the animation-to-physics handoff, not an added impulse.
      // Slow motion suppresses SPLAT force vectors but must not restore a vanilla
      // death animation when the user has chosen ragdoll deaths.
      RFC_ScheduleCut(ds, this, 0.0);
    } else if c.stealthRagdollsEnabled {
      RFC_Stealth_SchedForceRagdoll(this, c.stealthRagdollDelay);
    }

    return resStealth;
  }


  // ─────────────────────────
  // Time (needed for walk/run “recent” tracking)
  // ─────────────────────────
  let nowT: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));

  // Movement classification (direction-agnostic): use planar speed, so backward-walk/strafe still count.
  let vv: Vector4 = this.GetVelocity();
  let planar: Float = SqrtF(vv.X * vv.X + vv.Y * vv.Y);

  // Heuristic: some builds report cm/s. If it's huge, convert to m/s-ish.
  if planar > 20.0 {
    planar *= 0.01;
  }

  // Prefer explicit locomotion tags when available, with planar speed as the fallback.
  // This keeps strafing/backward motion valid and prevents the Running/Walking lane
  // from silently missing NPCs whose velocity is sampled late during OnDeath.
  let isRunLive: Bool = planar > 1.55 || RFC_IsRunning(this);
  let isWalkLive: Bool = !isRunLive && (
    RFC_IsClearlyWalking(this) ||
    RFC_IsWalking(this) ||
    (planar > 0.12 && planar <= 1.55)
  );

  // Stamp "recent" windows for the router to use later
  if isRunLive {
    this.rfc_runLastSeen = nowT;
  } else if isWalkLive {
    this.rfc_walkLastSeen = nowT;
  }

  // Restore the shared death-lane state before vanilla OnDeath can queue
  // ragdoll/impact callbacks. Head Falls and Body Falls both read these gates.
  RFC_ResetMasterDeathChance(this);
  RFC_MasterDeathChancePass(this, c);
  GS_ClearSituationSnap(this);
  GS_CaptureSituationSnap(this);
  RFC_ApplyDeathOverrideGates(this, c);
  let arcadeDeathOwnsFall: Bool = !isExplosionDeath && RFC_DeathImpulseRouter.ShouldOwnArcadeDeath(this, c);
  if isExplosionDeath || arcadeDeathOwnsFall || timeDilationBlocksImpulses {
    // The original OnDeath still runs, but no Head, Body, Situational, Jolt,
    // Arcade, or settle lane may arm during its nested ragdoll callbacks.
    RFC_BlockAllDeathImpulseLanes(this);
  }

  // A fresh death must not inherit completed Head Falls/rebound state from an
  // earlier incapacitation or ragdoll transition.
  this.hisDidForwardGround = false;
  this.hisDidBackGround = false;
  this.hisDidForwardRebound = false;
  this.hisDidBackRebound = false;
  this.hisHeadImpulseFired = false;
  this.hisBackHeadImpulseFired = false;
  this.hisReboundArmed = false;
  this.hisReboundStartSeeded = false;
  this.hisDeathStartTime = nowT;

  let res: Bool = wrappedMethod(evt);

  // Time dilation owns only the added impulse lanes. Preserve the normal SPLAT
  // death-animation cutoff so deaths still become ragdolls, then stop before
  // Arcade, Head, Body, Situational, Jolt, Explosion, Settle or Tumble can fire.
  if timeDilationBlocksImpulses {
    if RFC_IsWorkspotOrPerch(this) {
      RFC_TryStopWorkspot(this);
    }
    RFC_ScheduleCut(ds, this, 0.0);
    return res;
  }

  // Explosion deaths must keep the game's real damage/death callback, release
  // ordinary non-vehicle workspots, and then use only SPLAT's dedicated
  // explosion controls. Returning here prevents all regular death impulses.
  if isExplosionDeath {
    if RFC_IsWorkspotOrPerch(this) {
      RFC_TryStopWorkspot(this);
      RFC_ScheduleCut(ds, this, 0.0);
    }

    if c.grenadeEnabled && IsDefined(ds) && c.grenadeKickRadius > 0.0 {
      let explosionKick: ref<RFC_TryGrenadeKickEvent> = new RFC_TryGrenadeKickEvent();
      explosionKick.hitPos = this.rfcExplodePos;
      ds.DelayEvent(this, explosionKick, RFC_ClampT(c.grenadeKickCallDelay), false);
    }

    return res;
  }

  // Restore named-mode Arcade On Death after the workspot-safe vanilla method order.
  // This reads the final RFC.Cfg() values, so Realism Plus / Dirty Harry / Arnold
  // mode overrides win over Realism Custom/base settings.
  let arcadeDeathHandled: Bool = RFC_DeathImpulseRouter.RunArcadeOnDeathOnly(this, evt, ds, c);

  // Death anim selection
  let useDeathAnim: Bool = false;

  if c.skipDeathAnim {
    useDeathAnim = false;
  } else {
if c.deathAnimChance > 0.0 && RandRangeF(0.0, 100.0) < c.deathAnimChance {
  useDeathAnim = true;
}

  }

  if useDeathAnim {
    if c.animCompatDelay > 0.0 {
      RFC_ScheduleCut(ds, this, c.animCompatDelay);
    }
  } else {
    // Restored from the known-good r6(15) route. When no death animation is
    // selected, cut immediately after vanilla OnDeath instead of leaving the
    // native post-hit/death settle lane alive.
    RFC_ScheduleCut(ds, this, 0.0);
  }

  // Arcade On Death owns the lethal impulse when it is enabled. Do not let
  // Head, Body, Situational or Tumble schedule a second competing impulse.
  if arcadeDeathHandled {
    return res;
  }
  // Feature gates
  let gVanilla:          Bool = c.vanillaMode;
  let gStandActive:      Bool = !gVanilla && c.standEnabled;
  let gRunActive:        Bool = !gVanilla && c.runEnabled;
  let gCowerActive:      Bool = !gVanilla && c.cowerEnabled;
  let gStairsActive:     Bool = !gVanilla && c.stairsEnabled;
  let gWSActive:         Bool = !gVanilla && c.wsStandEnabled;
  let gSettleActive:     Bool = !gVanilla && c.settleEnabled;
  let gGrenadeActive:    Bool = !gVanilla && c.grenadeEnabled;

  let sitOverrideForward: Bool = GS_CurrentOverrideForward(this, c);
  let sitOverrideChest: Bool = GS_CurrentOverrideChest(this, c);
  let sitOverridePelvis: Bool = GS_CurrentOverridePelvis(this, c);
  let sitOverrideKnees: Bool = GS_CurrentOverrideKnees(this, c);
  let sitOverrideHead: Bool = GS_CurrentOverrideHead(this, c);

  // NEW: walk gate (keeps routing consistent)
  let gWalkActive: Bool = !gVanilla && c.walkEnabled;

  // (you were forcing this off anyway)
  gSettleActive = false;

  // If engine cannot ragdoll, stop here after we’ve issued any cuts
  if c.skipDeathAnim && !ScriptedPuppet.CanRagdoll(this) {
    return res;
  }

  // This call was missing from V132. Without it, the Head Falls class existed
  // and the menu was wired, but neither Head Forward nor its rebound lane was
  // scheduled on death. Keep it after wrappedMethod/cut selection and before
  // the situation branches begin returning.
  RFC_HeadFallsLogicImpulse.RunOnDeathHeadFalls(this, ds, c);

  if gGrenadeActive && IsDefined(ds) && RFC_Explode_IsRecent(this) && c.grenadeKickRadius > 0.0 {
    let e: ref<RFC_TryGrenadeKickEvent> = new RFC_TryGrenadeKickEvent();
    e.hitPos = this.rfcExplodePos;
    ds.DelayEvent(this, e, RFC_ClampT(c.grenadeKickCallDelay), false);
  }

  // Build world positions and forward basis
  let dirX: Float;
  let dirY: Float;
  RFC_GetFlatForward(this, dirX, dirY);

  let R: RFC_RigOffsets = RFC_RigNeutral.Offsets();

  let headPos: Vector4;
  let chestPos: Vector4;
  let pelvisPos: Vector4;
  let leftKneePos: Vector4;
  let rightKneePos: Vector4;
  let leftShinPos: Vector4;
  let rightShinPos: Vector4;
  let leftFootPos: Vector4;
  let rightFootPos: Vector4;

  RFC_BuildPositions(
    this, dirX, dirY, R,
    headPos, chestPos, pelvisPos,
    leftKneePos, rightKneePos,
    leftShinPos, rightShinPos,
    leftFootPos, rightFootPos
  );

  let isWS:  Bool = RFC_IsWorkspotOrPerch(this);
  let isCow: Bool = RFC_IsCoweringStrict(this);

  // “recent” truth (RUN already had this; WALK now matches it)
  let isRun: Bool = isRunLive || RFC_IsRunning(this) || this.RFC_WasRunningRecent(1.25);
  let isWalk: Bool =
    !isRun && (
      RFC_IsClearlyWalking(this) ||
      RFC_IsWalking(this) ||
      (this.rfc_walkLastSeen > 0.0 && (nowT - this.rfc_walkLastSeen) <= 1.25)
    );

  // ─────────────────────────
  // STAIRS / STEEP-RAMP precheck (so ramps can enter the stairs branch)
  // ─────────────────────────
  let isStairFlag: Bool = RFC_IsOnStairs(this) || this.RFC_WasStairsRecent(1.25);

  let gPos: Vector4;
  let gN: Vector4;
  let downhill: Vector4 = Vector4(dirX, dirY, 0.0, 0.0);

  let didGroundHit: Bool = false;
  let heightToGround: Float = 0.0;
  let isSteepRamp: Bool = false;

  if RFC_RaycastDown_Ground(this.GetGame(), pelvisPos + Vector4(0.0, 0.0, 0.45, 0.0), 2.5, gPos, gN) {
    didGroundHit = true;
    downhill = RFC_DownSlopeDirFromNormal(gN);
    heightToGround = MaxF(0.0, pelvisPos.Z - gPos.Z);

    let upDot: Float = Vector4.Dot(RFC_SafeNormalize(gN, RFC_Up()), RFC_Up());
    isSteepRamp = upDot < 0.94; // tweak 0.96 / 0.92 later
  }

  let isStairLike: Bool = isStairFlag || isSteepRamp;

  // ─────────────────────────
  // STAIRS
  // ─────────────────────────
  if isStairLike {

    if !gStairsActive {
      return res;
    }

    let allowStairKnees: Bool = (!isRun && !isWalk) || c.stair_runUseKnees;
    if sitOverrideKnees && allowStairKnees && c.stair_kneeRadius > 0.0 && AbsF(c.stair_kneeDown) > 0.0001 {
      let kv: Vector4 = Vector4(0.0, 0.0, c.stair_kneeDown, 1.0);
      RFC_Burst(ds, this, leftKneePos,  kv, c.stair_kneeRadius, RFC_ClampT(c.stair_kneeDelay), c);
      RFC_Burst(ds, this, rightKneePos, kv, c.stair_kneeRadius, RFC_ClampT(c.stair_kneeDelay), c);
    }

    let ax: Float = dirX;
    let ay: Float = dirY;
    if isSteepRamp {
      ax = downhill.X;
      ay = downhill.Y;
    }

    let stairHeadVec: Vector4 = Vector4(
      (sitOverrideForward ? ax * c.stair_forward : 0.0) + (sitOverrideHead ? ax * c.stair_headFwd : 0.0),
      (sitOverrideForward ? ay * c.stair_forward : 0.0) + (sitOverrideHead ? ay * c.stair_headFwd : 0.0),
      0.0,
      1.0
    );
    let stairChestVec: Vector4 = Vector4(
      sitOverrideForward ? ax * (c.stair_forward + c.stair_chestFwd) : 0.0,
      sitOverrideForward ? ay * (c.stair_forward + c.stair_chestFwd) : 0.0,
      sitOverrideChest ? c.stair_downChest : 0.0,
      1.0
    );
    let stairPelvisVec: Vector4 = Vector4(
      sitOverrideForward ? ax * c.stair_forward : 0.0,
      sitOverrideForward ? ay * c.stair_forward : 0.0,
      sitOverridePelvis ? c.stair_downPelvis : 0.0,
      1.0
    );

    if sitOverrideHead || sitOverrideForward {
      RFC_Burst(ds, this, headPos, stairHeadVec, MaxF(c.stair_headRadius, c.stair_forwardRadius), RFC_ClampT(c.stair_kneeDelay + 0.06), c);
    }
    if sitOverrideHead {
      HIS_ScheduleSituationalHeadDown(
        this, ds, c,
        c.stair_downHeadMin, c.stair_downHead,
        c.stair_headRadius,
        c.stair_kneeDelay + 0.06
      );
    }
    if sitOverrideForward || sitOverrideChest {
      RFC_Burst(ds, this, chestPos, stairChestVec, MaxF(c.stair_chestRadius, c.stair_forwardRadius), RFC_ClampT(c.stair_kneeDelay + 0.10), c);
    }
    if sitOverrideForward || sitOverridePelvis {
      RFC_Burst(ds, this, pelvisPos, stairPelvisVec, MaxF(c.stair_pelvisRadius, c.stair_forwardRadius), RFC_ClampT(c.stair_kneeDelay + 0.12), c);
    }

    if sitOverrideChest && AbsF(c.stair_vSlamZ) > 0.001 {
      let sv3: Vector4 = Vector4(0.0, 0.0, c.stair_vSlamZ, 1.0);
      RFC_Burst(ds, this, chestPos, sv3, 0.98, RFC_ClampT(c.stair_kneeDelay + 0.18), c);
    }

    if sitOverrideForward && AbsF(c.stair_brakeFwd) > 0.001 && c.stair_brakeRadius > 0.0 {
      let bv2: Vector4 = Vector4(ax * c.stair_brakeFwd, ay * c.stair_brakeFwd, 0.0, 1.0);
      RFC_Burst(ds, this, chestPos, bv2, c.stair_brakeRadius, RFC_ClampT(c.stair_brakeDelay), c);
    }

    // The plank controls were exposed in the menu but never called by the active router.
    if sitOverrideForward || sitOverrideChest || sitOverridePelvis {
      RFC_ApplyStairPlank(ds, this, headPos, chestPos, pelvisPos, ax, ay, c);
    }

    let hb: Vector4 = Vector4(ax * 0.06, ay * 0.06, 0.85, 1.0);
    RFC_Burst(ds, this, headPos, hb, 0.55, RFC_ClampT(c.st_d_headSlam + 0.12), c);

    if gSettleActive {
      RFC_ApplyGlobalSettle(ds, this, headPos, chestPos, pelvisPos, dirX, dirY, c);
    }

    // STAIRS / STEEP-RAMP tumble ONLY (exclusive)
    if c.tumbleEnabled {
      if c.overrideTumbleStairs {
        let tumbleStartO: Float = c.tumbleStairs_delay + c.tumbleStairs_startBase;
        if didGroundHit {
          tumbleStartO = c.tumbleStairs_delay + c.tumbleStairs_startBase + MinF(c.tumbleStairs_startCap, heightToGround * c.tumbleStairs_startScale);
        }

        RFC_ScheduleSideTumble_Torque(
          ds, this, pelvisPos, chestPos, headPos,
          downhill.X, downhill.Y,
          RFC_ClampT(tumbleStartO),
          RFC_ClampT(c.tumbleStairs_stepDelay),
          c.tumbleStairs_steps,
          c.tumbleStairs_side,
          c.tumbleStairs_down,
          c.tumbleStairs_fwd,
          c.tumbleStairs_radius,
          c
        );
      } else {
        // Hardcoded STAIRS tumble
        let tumbleStart: Float = 0.18;
        if didGroundHit {
          tumbleStart = 0.18 + MinF(0.22, heightToGround * 0.10);
        }

        RFC_ScheduleSideTumble_Torque(
          ds, this, pelvisPos, chestPos, headPos,
          downhill.X, downhill.Y,
          RFC_ClampT(tumbleStart),
          0.08,
          16,
          9.25,
          -2.80,
          0.04,
          1.35,
          c
        );
      }
    }

    RFC_ScheduleTwitch(this, ds, chestPos, pelvisPos, headPos, c);
    return res;
  }

  // ─────────────────────────
  // WORKSPOT
  // ─────────────────────────
  if isWS {
    if !gWSActive {
      return res;
    }

    let W: RFC_WSKindConfig = RFC_WSConfigForKind(c, this.RFC_GetLastOrLiveKind());

    if sitOverrideHead && W.headRadius > 0.0 {
      let hv: Vector4 = Vector4(dirX * W.headFwd, dirY * W.headFwd, W.headDown, 3.0);
      RFC_Burst(ds, this, headPos, hv, W.headRadius, RFC_ClampT(W.headDelay + 0.010), c);
    }

    if W.chestRadius > 0.0 && (sitOverrideForward || sitOverrideChest) {
      let cv: Vector4 = Vector4(
        sitOverrideForward ? dirX * W.chestFwd : 0.0,
        sitOverrideForward ? dirY * W.chestFwd : 0.0,
        sitOverrideChest ? W.chestDown : 0.0,
        1.0
      );
      RFC_Burst(ds, this, chestPos, cv, W.chestRadius, RFC_ClampT(W.chestDelay + 0.012), c);
    }

    if sitOverrideChest && W.body_vSlamRadius > 0.0 && AbsF(W.body_vSlamZ) > 0.0001 {
      let bv: Vector4 = Vector4(0.0, 0.0, W.body_vSlamZ, 1.0);
      RFC_Burst(ds, this, chestPos, bv, W.body_vSlamRadius, RFC_ClampT(W.body_vSlamDelay), c);
    }

    if W.pelvisRadius > 0.0 && (sitOverrideForward || sitOverridePelvis) {
      let pv: Vector4 = Vector4(
        sitOverrideForward ? dirX * W.pelvisFwd : 0.0,
        sitOverrideForward ? dirY * W.pelvisFwd : 0.0,
        sitOverridePelvis ? W.pelvisDown : 0.0,
        1.0
      );
      RFC_Burst(ds, this, pelvisPos, pv, W.pelvisRadius, RFC_ClampT(W.pelvisDelay), c);
    }

    if sitOverrideKnees && W.kneeRadius > 0.0 && AbsF(W.kneeDown) > 0.0001 {
      let kv: Vector4 = Vector4(0.0, 0.0, W.kneeDown, 1.0);
      RFC_Burst(ds, this, leftKneePos,  kv, W.kneeRadius, RFC_ClampT(W.kneeDelay), c);
      RFC_Burst(ds, this, rightKneePos, kv, W.kneeRadius, RFC_ClampT(W.kneeDelay), c);
    }

    if W.shinRadius > 0.0 && AbsF(W.shinDown) > 0.0001 {
      let sv: Vector4 = Vector4(0.0, 0.0, W.shinDown, 1.0);
      RFC_Burst(ds, this, leftShinPos,  sv, W.shinRadius, RFC_ClampT(W.shinDelay1), c);
      RFC_Burst(ds, this, rightShinPos, sv, W.shinRadius, RFC_ClampT(W.shinDelay1), c);
      RFC_Burst(ds, this, leftShinPos,  sv, W.shinRadius, RFC_ClampT(W.shinDelay2), c);
      RFC_Burst(ds, this, rightShinPos, sv, W.shinRadius, RFC_ClampT(W.shinDelay2), c);
    }

    if W.footRadius > 0.0 && (AbsF(W.footFwd) > 0.0001 || AbsF(W.footDown) > 0.0001) {
      let fv: Vector4 = Vector4(dirX * W.footFwd, dirY * W.footFwd, W.footDown, 1.0);
      RFC_Burst(ds, this, leftFootPos,  fv, W.footRadius, RFC_ClampT(W.footDelay), c);
      RFC_Burst(ds, this, rightFootPos, fv, W.footRadius, RFC_ClampT(W.footDelay), c);
    }

    RFC_ApplyHeadSlam(ds, this, headPos, dirX, dirY, c);

    if c.directionalTumbleEnabled {
      let tRoll: Float = RFC_ClampT(c.run_d_chestFall + 0.10);

      if c.overrideTumbleDirectional {

        RFC_ScheduleSideTumble_Torque(

          ds, this, pelvisPos, chestPos, headPos,

          dirX, dirY,

          RFC_ClampT(c.tumbleDir_startDelay),

          RFC_ClampT(c.tumbleDir_stepDelay),

          c.tumbleDir_steps,

          c.tumbleDir_side,

          c.tumbleDir_down,

          c.tumbleDir_fwd,

          c.tumbleDir_radius,

          c

        );

      } else {

      RFC_ScheduleGravityRollResolve_Directional(
        ds, this,
        pelvisPos, chestPos, headPos,
        dirX, dirY,
        tRoll,
        0.07,   // stepDelay (tighter taps)
        3,      // steps (kills the “jolt”)
        0.55,   // sideStrength (stronger than 0.10)
        -1.80,  // downStrength (stronger slam)
        1.35,   // radius (tighter than 1.85)
        c
      );

      }

    }

    RFC_ScheduleTwitch(this, ds, chestPos, pelvisPos, headPos, c);
    return res;
  }

  // ─────────────────────────
  // COWER
  // ─────────────────────────
  if isCow {
    if !gCowerActive {
      return res;
    }

    let cow: RFC_CowerConfig = c.cow;

    if sitOverrideHead && cow.headRadius > 0.0 {
      HIS_ScheduleSituationalHeadDown(
        this, ds, c,
        cow.headDownMin, cow.headDown,
        cow.headRadius,
        cow.headDelay
      );
    }
    if sitOverrideChest && cow.chestRadius > 0.0 {
      let cv2: Vector4 = Vector4(0.0, 0.0, cow.chestDown, 1.0);
      RFC_Burst(ds, this, chestPos, cv2, cow.chestRadius, RFC_ClampT(cow.chestDelay), c);
    }
    if sitOverridePelvis && cow.pelvisRadius > 0.0 {
      let pv2: Vector4 = Vector4(0.0, 0.0, cow.pelvisDown, 1.0);
      RFC_Burst(ds, this, pelvisPos, pv2, cow.pelvisRadius, RFC_ClampT(cow.pelvisDelay), c);
    }
    if sitOverrideKnees && cow.kneeRadius > 0.0 && AbsF(cow.kneeDown) > 0.0001 {
      let kvCow: Vector4 = Vector4(0.0, 0.0, cow.kneeDown, 1.0);
      RFC_Burst(ds, this, leftKneePos,  kvCow, cow.kneeRadius, RFC_ClampT(cow.kneeDelay), c);
      RFC_Burst(ds, this, rightKneePos, kvCow, cow.kneeRadius, RFC_ClampT(cow.kneeDelay), c);
    }
    if cow.shinRadius > 0.0 && AbsF(cow.shinDown) > 0.0001 {
      let sv: Vector4 = Vector4(0.0, 0.0, cow.shinDown, 1.0);
      RFC_Burst(ds, this, leftShinPos,  sv, cow.shinRadius, RFC_ClampT(cow.shinDelay), c);
      RFC_Burst(ds, this, rightShinPos, sv, cow.shinRadius, RFC_ClampT(cow.shinDelay), c);
    }
    if cow.antiTuckRadius > 0.0 && AbsF(cow.antiTuckZ) > 0.0001 {
      let av: Vector4 = Vector4(0.0, 0.0, cow.antiTuckZ, 1.0);
      RFC_Burst(ds, this, headPos, av, cow.antiTuckRadius, RFC_ClampT(cow.antiTuckDelay), c);
    }
    if cow.settleRadius > 0.0 {
      let sv2: Vector4 = Vector4(0.0, 0.0, cow.settleDown, 0.8);
      RFC_Burst(ds, this, chestPos, sv2, cow.settleRadius, RFC_ClampT(cow.settleDelay), c);
    }

    if gSettleActive {
      RFC_ApplyGlobalSettle(ds, this, headPos, chestPos, pelvisPos, dirX, dirY, c);
    }

    // COWER gets roll-resolve (NOT tumble), and NOT when running
    if c.directionalTumbleEnabled {
      if c.overrideTumbleDirectional {
        RFC_ScheduleSideTumble_Torque(
          ds, this, pelvisPos, chestPos, headPos,
          dirX, dirY,
          RFC_ClampT(c.tumbleDir_startDelay),
          RFC_ClampT(c.tumbleDir_stepDelay),
          c.tumbleDir_steps,
          c.tumbleDir_side,
          c.tumbleDir_down,
          c.tumbleDir_fwd,
          c.tumbleDir_radius,
          c
        );
      } else {
      RFC_ScheduleGravityRollResolve_Directional(
        ds, this,
        pelvisPos, chestPos, headPos,
        dirX, dirY,
        1.2,
        0.16,
        14,
        0.5,
        -0.2,
        1.85,
        c
      );
      }

    }

    RFC_ScheduleTwitch(this, ds, chestPos, pelvisPos, headPos, c);
    return res;
  } 

  // ─────────────────────────
  // RUN / WALK / STAND
  // ─────────────────────────
  let downHead: Float;
  let downChest: Float;
  let downPelvis: Float;
  let kneeDown: Float;
  let vSlamZ: Float;
  let d_headBias:  Float;
  let d_headSlam:  Float;
  let d_chestFall: Float;
  let d_pelvisFall:Float;

  let isExplosionKill: Bool = RFC_Explode_IsRecent(this);

  // RUN/WALK UNIFIED: we route both walk + run into the RUN lane so they use the same impulses.
  // This avoids walk stealing / missing and makes one behavior to tune in the settings menu.
  let walkRecent: Bool = this.rfc_walkLastSeen > 0.0
    && (nowT - this.rfc_walkLastSeen) <= 1.25;

  // RUN lane fires if either live RUN, live WALK, or we recently detected WALK speed.
  let useRun: Bool = gRunActive && !isExplosionKill && (isRun || isWalk || walkRecent);

  // Keep legacy WALK lane disabled (do not delete; other code still references it).
  let useWalk: Bool = false;

  // STAND excludes RUN and WALK
  let useStand: Bool = !useRun && !useWalk && gStandActive;

  if useRun {
    downHead     = RFC_RandomHeadValue(this, c, c.run_downHeadMin, c.run_downHead);
    downChest    = c.run_downChest;
    downPelvis   = c.run_downPelvis;
    kneeDown     = c.run_kneeDown;
    vSlamZ       = c.run_vSlamZ;
    d_headBias   = c.run_d_headBias;
    d_headSlam   = c.run_d_headSlam;
    d_chestFall  = c.run_d_chestFall;
    d_pelvisFall = c.run_d_pelvisFall;

  } else if useWalk {
    downHead     = c.walk_downHead;
    downChest    = c.walk_downChest;
    downPelvis   = c.walk_downPelvis;
    kneeDown     = c.walk_kneeDown;
    vSlamZ       = c.walk_vSlamZ;
    d_headBias   = c.walk_d_headBias;
    d_headSlam   = c.walk_d_headSlam;
    d_chestFall  = c.walk_d_chestFall;
    d_pelvisFall = c.walk_d_pelvisFall;

  } else if useStand {
    downHead     = RFC_RandomHeadValue(this, c, c.st_downHeadMin, c.st_downHead);
    downChest    = c.st_downChest;
    downPelvis   = c.st_downPelvis;
    kneeDown     = c.st_kneeDown;
    vSlamZ       = c.st_vSlamZ;
    d_headBias   = c.st_d_headBias;
    d_headSlam   = c.st_d_headSlam;
    d_chestFall  = c.st_d_chestFall;
    d_pelvisFall = c.st_d_pelvisFall;

  } else {
    if gSettleActive {
      RFC_ApplyGlobalSettle(ds, this, headPos, chestPos, pelvisPos, dirX, dirY, c);
    }
    RFC_ScheduleTwitch(this, ds, chestPos, pelvisPos, headPos, c);
    return res;
  }

  // Individual situation switches are ownership gates, not merely menu
  // visibility. A closed override must contribute exactly zero to this route.
  if sitOverrideHead {
    if useRun {
      HIS_ScheduleSituationalHeadDown(
        this, ds, c,
        c.run_downHeadMin, c.run_downHead,
        c.run_headRadius,
        d_headSlam
      );
    } else if useStand {
      HIS_ScheduleSituationalHeadDown(
        this, ds, c,
        c.st_downHeadMin, c.st_downHead,
        c.st_headRadius,
        d_headSlam
      );
    }
  }
  // The Head-down component is now owned by the standard Head Falls event.
  // Keep the generic situation vector horizontal-only to prevent duplication.
  downHead = 0.0;
  if !sitOverrideChest { downChest = 0.0; vSlamZ = 0.0; }
  if !sitOverridePelvis { downPelvis = 0.0; }
  if !sitOverrideKnees { kneeDown = 0.0; }
  if !sitOverrideForward {
    if useRun {
      c.run_forward = 0.0;
      c.run_anchorFwd = 0.0;
    } else if useWalk {
      c.walk_forward = 0.0;
    } else if useStand {
      c.st_forward = 0.0;
      c.st_anchorFwd = 0.0;
    }
  }

  if useRun {
    // Use MOVE direction (velocity-based) so WALK and RUN both push forward correctly.
    let moveX: Float = dirX;
    let moveY: Float = dirY;
    RFC_GetMoveDirXY(this, dirX, dirY, moveX, moveY);

    // Build primary impulse vectors
    let runHeadVec:   Vector4 = new Vector4(moveX * c.run_forward * 0.8, moveY * c.run_forward * 0.8, downHead,   1.0);
    let runChestVec:  Vector4 = new Vector4(moveX * c.run_forward,       moveY * c.run_forward,       downChest,  1.0);
    let runPelvisVec: Vector4 = new Vector4(moveX * c.run_forward * 0.8, moveY * c.run_forward * 0.8, downPelvis, 1.0);

    // Main run slam (your existing bursts)
    if sitOverrideForward {
      RFC_Burst(ds, this, headPos, runHeadVec, MaxF(c.run_headRadius, c.run_forwardRadius), RFC_ClampT(d_headSlam), c);
    }
    RFC_Burst(ds, this, chestPos, runChestVec, MaxF(c.run_chestRadius, c.run_forwardRadius), RFC_ClampT(d_chestFall), c);

    // Optional: extra “weight” into pelvis so it feels like momentum collapses the hips
    RFC_Burst(ds, this, pelvisPos, runPelvisVec, MaxF(c.run_pelvisRadius, c.run_forwardRadius), RFC_ClampT(d_pelvisFall), c);

    if sitOverrideKnees && AbsF(kneeDown) > 0.0001 {
      let kvRun: Vector4 = Vector4(0.0, 0.0, kneeDown, 1.0);
      RFC_Burst(ds, this, leftKneePos,  kvRun, c.run_kneeRadius, RFC_ClampT(c.run_d_knee), c);
      RFC_Burst(ds, this, rightKneePos, kvRun, c.run_kneeRadius, RFC_ClampT(c.run_d_knee), c);
    }

    if sitOverrideChest && AbsF(vSlamZ) > 0.0001 {
      let vRun: Vector4 = Vector4(0.0, 0.0, vSlamZ, 1.0);
      RFC_Burst(ds, this, chestPos, vRun, c.run_vSlamRadius, RFC_ClampT(c.run_d_vSlam), c);
    }

    if c.run_forwardDelay > 0.0001 && AbsF(c.run_forward) > 0.0001 {
      let fRun: Vector4 = Vector4(moveX * c.run_forward, moveY * c.run_forward, 0.0, 1.0);
      RFC_Burst(ds, this, chestPos, fRun, c.run_forwardRadius, RFC_ClampT(c.run_forwardDelay), c);
    }

    if c.run_anchorRadius > 0.0 && (AbsF(c.run_anchorFwd) > 0.0001 || AbsF(c.run_anchorDown) > 0.0001) {
      let aRun: Vector4 = Vector4(moveX * c.run_anchorFwd, moveY * c.run_anchorFwd, c.run_anchorDown, 1.0);
      RFC_Burst(ds, this, chestPos, aRun, c.run_anchorRadius, RFC_ClampT(d_chestFall + c.run_anchorOffset), c);
    }

    // ---- Run side-turn (roll resolve), harder slam ----
    if c.directionalTumbleEnabled {
      let tRoll: Float = 0.90;

      let rollStepDelay: Float = 0.10;
      let rollSteps: Int32 = 6;
      let rollRadius: Float = 1.55;

    let hb: Vector4 = new Vector4(dirX * 0.06, dirY * 0.06, 0.85, 1.0);
 RFC_Burst(ds, this, headPos, hb, 0.55, RFC_ClampT(c.st_d_headSlam + 0.12), c);

      if c.overrideTumbleDirectional {

        RFC_ScheduleSideTumble_Torque(

          ds, this, pelvisPos, chestPos, headPos,

          moveX, moveY,

          RFC_ClampT(c.tumbleDir_startDelay),

          RFC_ClampT(c.tumbleDir_stepDelay),

          c.tumbleDir_steps,

          c.tumbleDir_side,

          c.tumbleDir_down,

          c.tumbleDir_fwd,

          c.tumbleDir_radius,

          c

        );

      } else {

      RFC_ScheduleGravityRollResolve_Directional(
        ds, this,
        pelvisPos, chestPos, headPos,
        moveX, moveY,
        tRoll,
        rollStepDelay,
        rollSteps,
        0.30,
        -0.60,
        rollRadius,
        c
      );

      }

    }

    RFC_ScheduleTwitch(this, ds, chestPos, pelvisPos, headPos, c);

  } else if useWalk {

    // ─────────────────────────────────────────────
    // WALK DIRECTION: movement direction (forward/back/strafe)
    // Uses cached planar VX/VY if available, else live velocity,
    // else falls back to facing dirX/dirY.
    // ─────────────────────────────────────────────
    let moveX: Float = dirX;
    let moveY: Float = dirY;
    RFC_GetMoveDirXY(this, dirX, dirY, moveX, moveY);

    // WALK impulses (uses the already-selected downHead/downChest/downPelvis etc)
    let wHeadVec:   Vector4 = new Vector4(moveX * c.walk_forward * 0.55, moveY * c.walk_forward * 0.55, downHead,   1.0);
    let wChestVec:  Vector4 = new Vector4(moveX * c.walk_forward,        moveY * c.walk_forward,        downChest,  1.0);
    let wPelvisVec: Vector4 = new Vector4(moveX * c.walk_forward * 0.70, moveY * c.walk_forward * 0.70, downPelvis, 1.0);

    RFC_Burst(ds, this, headPos,   wHeadVec,   1.35, RFC_ClampT(d_headSlam),   c);
    RFC_Burst(ds, this, chestPos,  wChestVec,  0.80, RFC_ClampT(d_chestFall),  c);
    RFC_Burst(ds, this, pelvisPos, wPelvisVec, 0.80, RFC_ClampT(d_pelvisFall), c);

    if sitOverrideKnees && AbsF(kneeDown) > 0.0001 {
      let kv: Vector4 = new Vector4(0.0, 0.0, kneeDown, 1.0);
      RFC_Burst(ds, this, leftKneePos,  kv, 0.55, RFC_ClampT(c.walk_d_knee), c);
      RFC_Burst(ds, this, rightKneePos, kv, 0.55, RFC_ClampT(c.walk_d_knee), c);
    }

    if sitOverrideChest && AbsF(vSlamZ) > 0.0001 {
      let vvec: Vector4 = new Vector4(0.0, 0.0, vSlamZ, 1.0);
      RFC_Burst(ds, this, chestPos, vvec, 0.98, RFC_ClampT(c.walk_d_vSlam), c);
    }

    if c.walk_forwardDelay > 0.0001 && AbsF(c.walk_forward) > 0.0001 {
      let wf: Vector4 = new Vector4(moveX * c.walk_forward, moveY * c.walk_forward, 0.0, 1.0);
      RFC_Burst(ds, this, chestPos, wf, 0.70, RFC_ClampT(c.walk_forwardDelay), c);
    }

    RFC_ScheduleTwitch(this, ds, chestPos, pelvisPos, headPos, c);
    return res;

  } else {
    // STAND
    let sdx: Float = 0.0;
    let sdy: Float = 0.0;
    if AbsF(dirX) > 0.0001 || AbsF(dirY) > 0.0001 {
      sdx = dirX;
      sdy = dirY;
    }

    let stHeadVec:   Vector4 = new Vector4(sdx * c.st_forward * 0.8, sdy * c.st_forward * 0.8, downHead,   1.9);
    let stChestVec:  Vector4 = new Vector4(sdx * c.st_forward,       sdy * c.st_forward,       downChest,  1.0);
    let stPelvisVec: Vector4 = new Vector4(sdx * c.st_forward * 0.8, sdy * c.st_forward * 0.8, downPelvis, 1.0);

    if sitOverrideForward {
      RFC_Burst(ds, this, headPos, stHeadVec, MaxF(c.st_headRadius, c.st_forwardRadius), RFC_ClampT(d_headSlam), c);
      RFC_Burst(ds, this, headPos, stHeadVec, MaxF(c.st_headRadius, c.st_forwardRadius), RFC_ClampT(1.2), c);
    }

    RFC_Burst(ds, this, chestPos, stChestVec, MaxF(c.st_chestRadius, c.st_forwardRadius), RFC_ClampT(d_chestFall), c);
    RFC_Burst(ds, this, pelvisPos, stPelvisVec, MaxF(c.st_pelvisRadius, c.st_forwardRadius), RFC_ClampT(d_pelvisFall), c);

    if AbsF(kneeDown) > 0.0001 {
      let kv2: Vector4 = new Vector4(0.0, 0.0, kneeDown, 1.0);
      RFC_Burst(ds, this, leftKneePos,  kv2, c.st_kneeRadius, RFC_ClampT(c.st_d_knee), c);
      RFC_Burst(ds, this, rightKneePos, kv2, c.st_kneeRadius, RFC_ClampT(c.st_d_knee), c);
    }

    if c.st_shinRadius > 0.0 && (AbsF(c.st_shinBack) > 0.0001 || AbsF(c.st_shinDown) > 0.0001) {
      let sv2: Vector4 = new Vector4(-sdx * c.st_shinBack, -sdy * c.st_shinBack, c.st_shinDown, 1.0);
      RFC_Burst(ds, this, leftShinPos,  sv2, c.st_shinRadius, RFC_ClampT(c.st_shinDelay1), c);
      RFC_Burst(ds, this, rightShinPos, sv2, c.st_shinRadius, RFC_ClampT(c.st_shinDelay1), c);
      RFC_Burst(ds, this, leftShinPos,  sv2, c.st_shinRadius, RFC_ClampT(c.st_shinDelay2), c);
      RFC_Burst(ds, this, rightShinPos, sv2, c.st_shinRadius, RFC_ClampT(c.st_shinDelay2), c);
    }

    if c.st_footRadius > 0.0 && (AbsF(c.st_footFwd) > 0.0001 || AbsF(c.st_footDown) > 0.0001) {
      let fv2: Vector4 = new Vector4(sdx * c.st_footFwd, sdy * c.st_footFwd, c.st_footDown, 1.0);
      RFC_Burst(ds, this, leftFootPos,  fv2, c.st_footRadius, RFC_ClampT(c.st_footDelay), c);
      RFC_Burst(ds, this, rightFootPos, fv2, c.st_footRadius, RFC_ClampT(c.st_footDelay), c);
    }

    if AbsF(vSlamZ) > 0.0001 {
      let vvec2: Vector4 = new Vector4(0.0, 0.0, vSlamZ, 1.0);
      RFC_Burst(ds, this, chestPos, vvec2, 0.98, RFC_ClampT(c.st_d_vSlam), c);
    }

    if c.st_antiTuckRadius > 0.0 && AbsF(c.st_antiTuckZ) > 0.0001 {
      let atv: Vector4 = new Vector4(0.0, 0.0, c.st_antiTuckZ, 1.0);
      RFC_Burst(ds, this, headPos, atv, c.st_antiTuckRadius, RFC_ClampT(c.st_antiTuckDelay), c);
    }

    if c.st_anchorRadius > 0.0 && (AbsF(c.st_anchorFwd) > 0.0001 || AbsF(c.st_anchorDown) > 0.0001) {
      let anVec: Vector4 = new Vector4(sdx * c.st_anchorFwd, sdy * c.st_anchorFwd, c.st_anchorDown, 1.0);
      let anTime: Float = RFC_ClampT(d_chestFall + c.st_anchorOffset);
      RFC_Burst(ds, this, chestPos, anVec, c.st_anchorRadius, anTime, c);
    }

    if c.directionalTumbleEnabled {
      if c.overrideTumbleDirectional {
        RFC_ScheduleSideTumble_Torque(
          ds, this, pelvisPos, chestPos, headPos,
          dirX, dirY,
          RFC_ClampT(c.tumbleDir_startDelay),
          RFC_ClampT(c.tumbleDir_stepDelay),
          c.tumbleDir_steps,
          c.tumbleDir_side,
          c.tumbleDir_down,
          c.tumbleDir_fwd,
          c.tumbleDir_radius,
          c
        );
      } else {
      RFC_ScheduleGravityRollResolve_Directional(
        ds, this,
        pelvisPos, chestPos, headPos,
        dirX, dirY,
        1.2,
        0.16,
        14,
        0.5,
        -0.2,
        1.85,
        c
      );
      }

    }

    if sitOverrideForward && c.st_forwardDelay > 0.0 && AbsF(c.st_forward) > 0.0001 && (AbsF(sdx) > 0.0001 || AbsF(sdy) > 0.0001) {
      let sHead:   Vector4 = new Vector4(sdx * c.st_forward * 0.8, sdy * c.st_forward * 0.8, 0.0, 1.0);
      let sChest:  Vector4 = new Vector4(sdx * c.st_forward,       sdy * c.st_forward,       0.0, 1.0);
      let sPelvis: Vector4 = new Vector4(sdx * c.st_forward * 0.8, sdy * c.st_forward * 0.8, 0.0, 1.0);

      let tFwd: Float = RFC_ClampT(c.st_forwardDelay);
      RFC_Burst(ds, this, headPos, sHead, MaxF(c.st_headRadius, c.st_forwardRadius), tFwd, c);
      RFC_Burst(ds, this, chestPos, sChest, MaxF(c.st_chestRadius, c.st_forwardRadius), tFwd, c);
      RFC_Burst(ds, this, pelvisPos, sPelvis, MaxF(c.st_pelvisRadius, c.st_forwardRadius), tFwd, c);
    }
  }

  RFC_ScheduleTwitch(this, ds, chestPos, pelvisPos, headPos, c);
  return res;
}
