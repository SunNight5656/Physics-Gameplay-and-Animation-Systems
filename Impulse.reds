module RealisticPush

public class RFC_DeathImpulseRouter {

  public static func RunOnDeathImpulses(
    puppet: ref<NPCPuppet>,
    evt: ref<gameDeathEvent>,
    ds: ref<DelaySystem>,
    c: RFCConfig
  ) -> Void {

  if c.arcadeBulletsEnabled && c.arcadeOnDeathEnabled {
    let ad2: ref<AttackData> = puppet.rfc_lastAttack;

    if IsDefined(ad2) && RFC_ArcadeAllowedByWeapon(ad2, c) {
      let at2: gamedataAttackType = ad2.GetAttackType();

      if !AttackData.IsExplosion(at2)
        && !AttackData.IsAreaOfEffect(at2)
        && !ad2.HasFlag(hitFlag.Explosion)
        && !ad2.HasFlag(hitFlag.VehicleImpact) {

        let srcPos: Vector4 = ad2.GetAttackPosition();
        let inst: wref<GameObject> = evt.instigator;
        if IsDefined(inst) {
          srcPos = inst.GetWorldPosition();
        }

        let tgtPos: Vector4 = puppet.GetWorldPosition();

        let dx: Float = tgtPos.X - srcPos.X;
        let dy: Float = tgtPos.Y - srcPos.Y;
        let len: Float = SqrtF(dx * dx + dy * dy);
        if len < 0.0001 {
          dx = 0.0;
          dy = 1.0;
          len = 1.0;
        };

        dx /= len;
        dy /= len;

        RFC_TryStopWorkspot(puppet);

        puppet.QueueEvent(CreateForceRagdollEvent(n"Splat_ArcadeOnDeath"));
        if IsDefined(ds) {
          ds.DelayEvent(puppet, CreateForceRagdollEvent(n"Splat_ArcadeOnDeath"), 0.040, false);
          ds.DelayEvent(puppet, CreateForceRagdollEvent(n"Splat_ArcadeOnDeath"), 0.080, false);
        }

        let horiz: Float = c.arcadeBulletStrength;
        let up: Float = c.arcadeBulletUp;
        let r: Float = (c.arcadeBulletRadius > 0.0) ? c.arcadeBulletRadius : 0.60;

        let impulse: Vector4 = new Vector4(dx * horiz, dy * horiz, up, 1.0);

        if IsDefined(ds) {
          ds.DelayEvent(
            puppet,
            CreateRagdollApplyImpulseEvent(tgtPos, impulse, r),
            RFC_ClampT(c.arcadeImpulseDelay),
            false
          );
        } else {
          puppet.QueueEvent(CreateRagdollApplyImpulseEvent(tgtPos, impulse, r));
        }


      }
    }
  }

// Grenade kick logic (STRICT)
if c.grenadeEnabled && c.grenadeKickRadius > 0.0 {

  let adE: ref<AttackData> = puppet.rfc_lastAttack;

  if IsDefined(adE) {
    // STRICT: only treat as grenade if the attack type is Explosion/PressureWave
    // or it was a vehicle impact. Do NOT use hitFlag.Explosion here.
    let atE: gamedataAttackType = adE.GetAttackType();
    let isExplE: Bool = Equals(atE, gamedataAttackType.Explosion) || Equals(atE, gamedataAttackType.PressureWave);
    let isVehE: Bool = adE.HasFlag(hitFlag.VehicleImpact);

    if isExplE || isVehE {

      // For explosions, use the attack position. For vehicle, use victim position.
      let hitPosE: Vector4 = puppet.GetWorldPosition();
      if isExplE {
        hitPosE = adE.GetAttackPosition();
      }

      let eKick: ref<RFC_TryGrenadeKickEvent> = new RFC_TryGrenadeKickEvent();
      eKick.hitPos = hitPosE;

      if IsDefined(ds) {
        ds.DelayEvent(puppet, eKick, MaxF(0.0, c.grenadeKickCallDelay), false);
      } else {
        puppet.QueueEvent(eKick);
      }
    }
  }
}


  // Timing / velocity stamps and router gates
  let nowT: Float = EngineTime.ToFloat(GameInstance.GetSimTime(puppet.GetGame()));

  let vv: Vector4 = puppet.GetVelocity();
  let planar: Float = SqrtF(vv.X * vv.X + vv.Y * vv.Y);

  // Heuristic: some builds report cm/s. If it's huge, convert to m/s-ish.
  if planar > 20.0 {
    planar *= 0.01;
  }

  let isRunLive:  Bool = planar > 1.55;
  let isWalkLive: Bool = planar > 0.12 && planar <= 1.55;

  // Stamp "recent" windows for the router to use later
  if isRunLive {
    puppet.rfc_runLastSeen = nowT;
  } else if isWalkLive {
    puppet.rfc_walkLastSeen = nowT;
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
  let gCorpseKickActive: Bool = !gVanilla && c.corpseKickEnabled;
  let gWalkActive:       Bool = !gVanilla && c.walkEnabled;

  // (you were forcing puppet off anyway)
  gSettleActive = false;

  // Corpse-impulse gates (bullet bloom / grenade shove)
  puppet.m_RFC_CorpseImpulseReady = false;
  if gCorpseKickActive && IsDefined(ds) {
ds.DelayEvent(puppet, new RFC_EnableCorpseImpulseEvent(), RFC_ClampT(c.bulletKickCallDelay), false);
  }
  if gGrenadeActive && IsDefined(ds) && RFC_Explode_IsRecent(puppet) && c.grenadeKickRadius > 0.0 {
    let e: ref<RFC_TryGrenadeKickEvent> = new RFC_TryGrenadeKickEvent();
    e.hitPos = puppet.rfcExplodePos;
ds.DelayEvent(puppet, e, MaxF(0.0, c.grenadeKickCallDelay), false);
  }

  // Build world positions and forward basis
  let dirX: Float;
  let dirY: Float;
  RFC_GetFlatForward(puppet, dirX, dirY);

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
    puppet, dirX, dirY, R,
    headPos, chestPos, pelvisPos,
    leftKneePos, rightKneePos,
    leftShinPos, rightShinPos,
    leftFootPos, rightFootPos
  );

  let isWS:  Bool = RFC_IsWorkspotOrPerch(puppet);
  let isCow: Bool = RFC_IsCoweringStrict(puppet);

  // “recent” truth (RUN already had puppet; WALK now matches it)
  let isRun:  Bool = isRunLive  || puppet.RFC_WasRunningRecent(1.25);
  let isWalk: Bool =
    RFC_IsClearlyWalking(puppet) ||
    RFC_IsWalking(puppet) ||
    ((nowT - puppet.rfc_walkLastSeen) <= 1.25);

  // STAIRS / STEEP-RAMP precheck (so ramps can enter the stairs branch)
  // ─────────────────────────
  let isStairFlag: Bool = RFC_IsOnStairs(puppet) || puppet.RFC_WasStairsRecent(1.25);

  let gPos: Vector4;
  let gN: Vector4;
  let downhill: Vector4 = Vector4(dirX, dirY, 0.0, 0.0);

  let didGroundHit: Bool = false;
  let heightToGround: Float = 0.0;
  let isSteepRamp: Bool = false;

  if RFC_RaycastDown_Ground(puppet.GetGame(), pelvisPos + Vector4(0.0, 0.0, 0.45, 0.0), 2.5, gPos, gN) {
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
      return;
    }

    if c.stair_kneeRadius > 0.0 && AbsF(c.stair_kneeDown) > 0.0001 {
      let kv: Vector4 = Vector4(0.0, 0.0, c.stair_kneeDown, 1.0);
      RFC_Burst(ds, puppet, leftKneePos,  kv, c.stair_kneeRadius, RFC_ClampT(c.stair_kneeDelay), c);
      RFC_Burst(ds, puppet, rightKneePos, kv, c.stair_kneeRadius, RFC_ClampT(c.stair_kneeDelay), c);
    }

    let ax: Float = dirX;
    let ay: Float = dirY;
    if isSteepRamp {
      ax = downhill.X;
      ay = downhill.Y;
    }

    let stairHeadVec:   Vector4 = Vector4(dirX * c.stair_headFwd,  dirY * c.stair_headFwd,  c.stair_downHead,   1.0);
    let stairChestVec:  Vector4 = Vector4(dirX * c.stair_chestFwd, dirY * c.stair_chestFwd, c.stair_downChest,  1.0);
    let stairPelvisVec: Vector4 = Vector4(0.0, 0.0, c.stair_downPelvis, 1.0);

    RFC_Burst(ds, puppet, headPos,   stairHeadVec,   0.70, RFC_ClampT(c.stair_kneeDelay + 0.06), c);
    RFC_Burst(ds, puppet, chestPos,  stairChestVec,  0.70, RFC_ClampT(c.stair_kneeDelay + 0.10), c);
    RFC_Burst(ds, puppet, pelvisPos, stairPelvisVec, 0.70, RFC_ClampT(c.stair_kneeDelay + 0.12), c);

    if AbsF(c.stair_vSlamZ) > 0.001 {
      let sv3: Vector4 = Vector4(0.0, 0.0, c.stair_vSlamZ, 1.0);
      RFC_Burst(ds, puppet, chestPos, sv3, 0.98, RFC_ClampT(c.stair_kneeDelay + 0.18), c);
    }

    if AbsF(c.stair_brakeFwd) > 0.001 && c.stair_brakeRadius > 0.0 {
      let bv2: Vector4 = Vector4(dirX * c.stair_brakeFwd, dirY * c.stair_brakeFwd, 0.0, 1.0);
      RFC_Burst(ds, puppet, chestPos, bv2, c.stair_brakeRadius, RFC_ClampT(c.stair_brakeDelay), c);
    }

    let hb: Vector4 = Vector4(dirX * 0.06, dirY * 0.06, 0.85, 1.0);
    RFC_Burst(ds, puppet, headPos, hb, 0.55, RFC_ClampT(c.st_d_headSlam + 0.12), c);

    if gSettleActive {
      RFC_ApplyGlobalSettle(ds, puppet, headPos, chestPos, pelvisPos, dirX, dirY, c);
    }

    // STAIRS / STEEP-RAMP tumble ONLY (exclusive)
    if c.tumbleEnabled {
      if c.overrideTumbleStairs {
        let tumbleStartO: Float = c.tumbleStairs_startBase;
        if didGroundHit {
          tumbleStartO = c.tumbleStairs_startBase + MinF(c.tumbleStairs_startCap, heightToGround * c.tumbleStairs_startScale);
        }

        RFC_ScheduleSideTumble_Torque(
          ds, puppet, pelvisPos, chestPos, headPos,
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
          ds, puppet, pelvisPos, chestPos, headPos,
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

    RFC_ScheduleTwitch(puppet, ds, chestPos, pelvisPos, headPos, c);
    return;
  }

  // ─────────────────────────
  // WORKSPOT
  // ─────────────────────────
  if isWS {
    if !gWSActive {
      return;
    }

    let W: RFC_WSKindConfig = RFC_WSConfigForKind(c, puppet.RFC_GetLastOrLiveKind());

    if W.headRadius > 0.0 {
      let hv: Vector4 = Vector4(dirX * W.headFwd, dirY * W.headFwd, W.headDown, 3.0);
      RFC_Burst(ds, puppet, headPos, hv, W.headRadius, RFC_ClampT(W.headDelay + 0.010), c);
    }

    if W.chestRadius > 0.0 {
      let cv: Vector4 = Vector4(dirX * W.chestFwd, dirY * W.chestFwd, W.chestDown, 1.0);
      RFC_Burst(ds, puppet, chestPos, cv, W.chestRadius, RFC_ClampT(W.chestDelay + 0.012), c);
    }

    if W.body_vSlamRadius > 0.0 && AbsF(W.body_vSlamZ) > 0.0001 {
      let bv: Vector4 = Vector4(0.0, 0.0, W.body_vSlamZ, 1.0);
      RFC_Burst(ds, puppet, chestPos, bv, W.body_vSlamRadius, RFC_ClampT(W.body_vSlamDelay), c);
    }

    if W.pelvisRadius > 0.0 && (AbsF(W.pelvisDown) > 0.0001 || AbsF(W.pelvisFwd) > 0.0001) {
      let pv: Vector4 = Vector4(dirX * W.pelvisFwd, dirY * W.pelvisFwd, W.pelvisDown, 1.0);
      RFC_Burst(ds, puppet, pelvisPos, pv, W.pelvisRadius, RFC_ClampT(W.pelvisDelay), c);
    }

    if W.kneeRadius > 0.0 && AbsF(W.kneeDown) > 0.0001 {
      let kv: Vector4 = Vector4(0.0, 0.0, W.kneeDown, 1.0);
      RFC_Burst(ds, puppet, leftKneePos,  kv, W.kneeRadius, RFC_ClampT(W.kneeDelay), c);
      RFC_Burst(ds, puppet, rightKneePos, kv, W.kneeRadius, RFC_ClampT(W.kneeDelay), c);
    }

    if W.shinRadius > 0.0 && AbsF(W.shinDown) > 0.0001 {
      let sv: Vector4 = Vector4(0.0, 0.0, W.shinDown, 1.0);
      RFC_Burst(ds, puppet, leftShinPos,  sv, W.shinRadius, RFC_ClampT(W.shinDelay1), c);
      RFC_Burst(ds, puppet, rightShinPos, sv, W.shinRadius, RFC_ClampT(W.shinDelay1), c);
      RFC_Burst(ds, puppet, leftShinPos,  sv, W.shinRadius, RFC_ClampT(W.shinDelay2), c);
      RFC_Burst(ds, puppet, rightShinPos, sv, W.shinRadius, RFC_ClampT(W.shinDelay2), c);
    }

    if W.footRadius > 0.0 && (AbsF(W.footFwd) > 0.0001 || AbsF(W.footDown) > 0.0001) {
      let fv: Vector4 = Vector4(dirX * W.footFwd, dirY * W.footFwd, W.footDown, 1.0);
      RFC_Burst(ds, puppet, leftFootPos,  fv, W.footRadius, RFC_ClampT(W.footDelay), c);
      RFC_Burst(ds, puppet, rightFootPos, fv, W.footRadius, RFC_ClampT(W.footDelay), c);
    }

    RFC_ApplyHeadSlam(ds, puppet, headPos, dirX, dirY, c);

    if c.directionalTumbleEnabled {
      let tRoll: Float = RFC_ClampT(c.run_d_chestFall + 0.10);

      if c.overrideTumbleDirectional {

        RFC_ScheduleSideTumble_Torque(
          ds, puppet, pelvisPos, chestPos, headPos,
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
          ds, puppet,
          pelvisPos, chestPos, headPos,
          dirX, dirY,
          tRoll,
          0.07,
          3,
          0.55,
          -1.80,
          1.35,
          c
        );

      }
    }

    RFC_ScheduleTwitch(puppet, ds, chestPos, pelvisPos, headPos, c);
    return;
  }

  // ─────────────────────────
  // COWER
  // ─────────────────────────
  if isCow {
    if !gCowerActive {
      return;
    }

    let cow: RFC_CowerConfig = c.cow;

    if cow.headRadius > 0.0 {
      let hv2: Vector4 = Vector4(0.0, 0.0, cow.headDown, 1.0);
      RFC_Burst(ds, puppet, headPos, hv2, cow.headRadius, RFC_ClampT(cow.headDelay), c);
    }
    if cow.chestRadius > 0.0 {
      let cv2: Vector4 = Vector4(0.0, 0.0, cow.chestDown, 1.0);
      RFC_Burst(ds, puppet, chestPos, cv2, cow.chestRadius, RFC_ClampT(cow.chestDelay), c);
    }
    if cow.pelvisRadius > 0.0 {
      let pv2: Vector4 = Vector4(0.0, 0.0, cow.pelvisDown, 1.0);
      RFC_Burst(ds, puppet, pelvisPos, pv2, cow.pelvisRadius, RFC_ClampT(cow.pelvisDelay), c);
    }
    if cow.shinRadius > 0.0 && AbsF(cow.shinDown) > 0.0001 {
      let sv: Vector4 = Vector4(0.0, 0.0, cow.shinDown, 1.0);
      RFC_Burst(ds, puppet, leftShinPos,  sv, cow.shinRadius, RFC_ClampT(cow.shinDelay), c);
      RFC_Burst(ds, puppet, rightShinPos, sv, cow.shinRadius, RFC_ClampT(cow.shinDelay), c);
    }
    if cow.antiTuckRadius > 0.0 && AbsF(cow.antiTuckZ) > 0.0001 {
      let av: Vector4 = Vector4(0.0, 0.0, cow.antiTuckZ, 1.0);
      RFC_Burst(ds, puppet, headPos, av, cow.antiTuckRadius, RFC_ClampT(cow.antiTuckDelay), c);
    }
    if cow.settleRadius > 0.0 {
      let sv2: Vector4 = Vector4(0.0, 0.0, cow.settleDown, 0.8);
      RFC_Burst(ds, puppet, chestPos, sv2, cow.settleRadius, RFC_ClampT(cow.settleDelay), c);
    }

    if gSettleActive {
      RFC_ApplyGlobalSettle(ds, puppet, headPos, chestPos, pelvisPos, dirX, dirY, c);
    }

    if c.directionalTumbleEnabled {
      if c.overrideTumbleDirectional {
        RFC_ScheduleSideTumble_Torque(
          ds, puppet, pelvisPos, chestPos, headPos,
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
          ds, puppet,
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

    RFC_ScheduleTwitch(puppet, ds, chestPos, pelvisPos, headPos, c);
    return;
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

  let isExplosionKill: Bool = RFC_Explode_IsRecent(puppet);

  let walkRecent: Bool = puppet.rfc_walkLastSeen > 0.0
    && (nowT - puppet.rfc_walkLastSeen) <= 1.25;

  let useRun: Bool = gRunActive && !isExplosionKill && (isRun || isWalk || walkRecent);

  // Keep legacy WALK lane disabled (do not delete; other code still references it).

  // STAND excludes RUN and WALK
  let useStand: Bool = !useRun && gStandActive;

  if useRun {
    downHead     = c.run_downHead;
    downChest    = c.run_downChest;
    downPelvis   = c.run_downPelvis;
    kneeDown     = c.run_kneeDown;
    vSlamZ       = c.run_vSlamZ;
    d_headBias   = c.run_d_headBias;
    d_headSlam   = c.run_d_headSlam;
    d_chestFall  = c.run_d_chestFall;
    d_pelvisFall = c.run_d_pelvisFall;

  } else if useStand {
    downHead     = c.st_downHead;
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
      RFC_ApplyGlobalSettle(ds, puppet, headPos, chestPos, pelvisPos, dirX, dirY, c);
    }
    RFC_ScheduleTwitch(puppet, ds, chestPos, pelvisPos, headPos, c);
    return;
  }

  // Small early head unlock (bias)
  let biasVec: Vector4 = Vector4(0.0, 0.0, downHead * 0.20, 1.0);
  RFC_Burst(ds, puppet, headPos, biasVec, 0.70, RFC_ClampT(d_headBias), c);

   if useRun {
    let moveX: Float = dirX;
    let moveY: Float = dirY;
    RFC_GetMoveDirXY(puppet, dirX, dirY, moveX, moveY);

    let runHeadVec: Vector4 = new Vector4(moveX * c.run_forward * 0.8, moveY * c.run_forward * 0.8, downHead, 1.0);
    let runChestVec: Vector4 = new Vector4(moveX * c.run_forward, moveY * c.run_forward, downChest, 1.0);
    let runPelvisVec: Vector4 = new Vector4(moveX * c.run_forward * 0.8, moveY * c.run_forward * 0.8, downPelvis, 1.0);

    RFC_Burst(ds, puppet, headPos, runHeadVec, 1.70, RFC_ClampT(d_headSlam), c);
    RFC_Burst(ds, puppet, chestPos, runChestVec, 0.70, RFC_ClampT(d_chestFall), c);
    RFC_Burst(ds, puppet, pelvisPos, runPelvisVec, 0.70, RFC_ClampT(d_pelvisFall), c);

    if AbsF(kneeDown) > 0.0001 {
      let kvRun: Vector4 = new Vector4(0.0, 0.0, kneeDown, 1.0);
      RFC_Burst(ds, puppet, leftKneePos, kvRun, 0.70, RFC_ClampT(c.run_d_knee), c);
      RFC_Burst(ds, puppet, rightKneePos, kvRun, 0.70, RFC_ClampT(c.run_d_knee), c);
    }

    if AbsF(vSlamZ) > 0.0001 {
      let vvecRun: Vector4 = new Vector4(0.0, 0.0, vSlamZ, 1.0);
      RFC_Burst(ds, puppet, chestPos, vvecRun, 0.98, RFC_ClampT(c.run_d_vSlam), c);
    }

    if c.run_anchorRadius > 0.0 && (AbsF(c.run_anchorFwd) > 0.0001 || AbsF(c.run_anchorDown) > 0.0001) {
      let anVecRun: Vector4 = new Vector4(moveX * c.run_anchorFwd, moveY * c.run_anchorFwd, c.run_anchorDown, 1.0);
      let anTimeRun: Float = RFC_ClampT(d_chestFall + c.run_anchorOffset);
      RFC_Burst(ds, puppet, chestPos, anVecRun, c.run_anchorRadius, anTimeRun, c);
    }

    if c.directionalTumbleEnabled {
      let tRoll: Float = 0.90;

      let rollStepDelay: Float = 0.10;
      let rollSteps: Int32 = 6;
      let rollRadius: Float = 1.55;

      let hb2: Vector4 = new Vector4(dirX * 0.06, dirY * 0.06, 0.85, 1.0);
      RFC_Burst(ds, puppet, headPos, hb2, 0.55, RFC_ClampT(c.st_d_headSlam + 0.12), c);

      if c.overrideTumbleDirectional {
        RFC_ScheduleSideTumble_Torque(
          ds, puppet, pelvisPos, chestPos, headPos,
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
          ds, puppet,
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

    RFC_ScheduleTwitch(puppet, ds, chestPos, pelvisPos, headPos, c);
    return;
  } else {
    // STAND
    let sdx: Float = 0.0;
    let sdy: Float = 0.0;
    if AbsF(dirX) > 0.0001 || AbsF(dirY) > 0.0001 {
      sdx = dirX;
      sdy = dirY;
    }

    let stHeadVec: Vector4 = new Vector4(sdx * c.st_forward * 0.8, sdy * c.st_forward * 0.8, downHead, 1.9);
    let stChestVec: Vector4 = new Vector4(sdx * c.st_forward, sdy * c.st_forward, downChest, 1.0);
    let stPelvisVec: Vector4 = new Vector4(sdx * c.st_forward * 0.8, sdy * c.st_forward * 0.8, downPelvis, 1.0);

    RFC_Burst(ds, puppet, headPos, stHeadVec, 1.0, RFC_ClampT(d_headSlam), c);
    RFC_Burst(ds, puppet, chestPos, stChestVec, 0.70, RFC_ClampT(d_chestFall), c);
    RFC_Burst(ds, puppet, pelvisPos, stPelvisVec, 0.70, RFC_ClampT(d_pelvisFall), c);

    if AbsF(kneeDown) > 0.0001 {
      let kv4: Vector4 = new Vector4(0.0, 0.0, kneeDown, 1.0);
      RFC_Burst(ds, puppet, leftKneePos, kv4, 0.70, RFC_ClampT(c.st_d_knee), c);
      RFC_Burst(ds, puppet, rightKneePos, kv4, 0.70, RFC_ClampT(c.st_d_knee), c);
    }

    if AbsF(vSlamZ) > 0.0001 {
      let vvec4: Vector4 = new Vector4(0.0, 0.0, vSlamZ, 1.0);
      RFC_Burst(ds, puppet, chestPos, vvec4, 0.98, RFC_ClampT(c.st_d_vSlam), c);
    }

    if c.st_forwardDelay > 0.0 && AbsF(c.st_forward) > 0.0001 && (AbsF(sdx) > 0.0001 || AbsF(sdy) > 0.0001) {
      let sHead: Vector4 = new Vector4(sdx * c.st_forward * 0.8, sdy * c.st_forward * 0.8, 0.0, 1.0);
      let sChest: Vector4 = new Vector4(sdx * c.st_forward, sdy * c.st_forward, 0.0, 1.0);
      let sPelvis: Vector4 = new Vector4(sdx * c.st_forward * 0.8, sdy * c.st_forward * 0.8, 0.0, 1.0);

      let tFwd: Float = RFC_ClampT(c.st_forwardDelay);
      RFC_Burst(ds, puppet, headPos, sHead, 0.70, tFwd, c);
      RFC_Burst(ds, puppet, chestPos, sChest, 0.70, tFwd, c);
      RFC_Burst(ds, puppet, pelvisPos, sPelvis, 0.70, tFwd, c);
    }

    RFC_ScheduleTwitch(puppet, ds, chestPos, pelvisPos, headPos, c);
    return;
  }

  }
}
