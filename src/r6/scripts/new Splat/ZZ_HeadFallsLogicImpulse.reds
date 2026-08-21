module RealisticPush

private func RFC_HeadHardBlock(p: wref<NPCPuppet>) -> Bool {
  let gPos: Vector4;
  let gN: Vector4;
  let probe: Vector4;
  let h: Float;

  if !IsDefined(p) { return true; }
  if RFC_IsVehicleContext(p) { return true; }
  if RFC_Explode_IsRecent(p) { return true; }

  probe = p.GetWorldPosition();
  probe.Z += 0.45;

  if !RFC_RaycastDown_Ground(p.GetGame(), probe, 2.5, gPos, gN) {
    return true;
  }

  h = MaxF(0.0, probe.Z - gPos.Z);
  if h > 0.95 {
    return true;
  }

  return false;
}

private func RFC_SitOverrideHeadBlock(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  return GS_CurrentOverrideHead(p, c);
}

private static func HIS_ReboundRequiresHeadImpulse(s: ref<HIS_Settings>) -> Bool {
  return s.reboundRequiresHeadImpulse;
}
private static func HIS_RollChancePct(chancePct: Int32) -> Bool {
  let clamped: Int32;
  let roll: Int32;

  clamped = chancePct;
  if clamped <= 0 { return false; };
  if clamped >= 100 { return true; };

  roll = RandRange(1, 101);
  return roll <= clamped;
}

private static func HIS_ShouldTriggerHeadImpulse(s: ref<HIS_Settings>) -> Bool {
  return HIS_RollChancePct(s.chancePct);
}

private static func HIS_ShouldTriggerRebound(s: ref<HIS_Settings>) -> Bool {
  return HIS_RollChancePct(s.reboundChancePct);
}

public func HIS_ApplyModeOverrides(s: ref<HIS_Settings>, c: RFCConfig) -> Void {
  if !IsDefined(s) { return; };

  // V132 Native Settings already stores one HIS_Settings object per mode.
  // Keep the selected mode's Head Forward Rebound value instead of replacing
  // it with the older RFCModSettings preset field.
  s.reboundKneeNearPct = ClampF(s.reboundKneeNearPct, 0.0, 100.0);
}

private static func HIS_ShouldRun(p: wref<NPCPuppet>, s: ref<HIS_Settings>) -> Bool {
  if !IsDefined(p) { return false; };
  if !IsDefined(s) { return false; };
  if !RFC_RandomAllowHead(p, RFC.Cfg()) { return false; };
  if !s.enabled && !s.enableRebound && !s.backEnabled && !s.enableBackRebound { return false; };
  return true;
}

private static func HIS_IsOnGround(p: wref<NPCPuppet>) -> Bool {
  let nav: ref<NavigationSystem>;
  if !IsDefined(p) { return false; };
  nav = GameInstance.GetNavigationSystem(p.GetGame());
  if !IsDefined(nav) { return false; };
  return nav.IsOnGround(p);
}

private static func HIS_GroundGateActive(baseDelay: Float, stepDelay: Float, stepIndex: Int32, gateDelay: Float) -> Bool {
  let elapsed: Float;
  if gateDelay <= 0.00 { return true; };
  elapsed = MaxF(0.0, baseDelay) + (Cast<Float>(stepIndex) * MaxF(0.0, stepDelay));
  return elapsed >= gateDelay;
}

private static func HIS_DeathGateActive(baseDelay: Float, stepDelay: Float, stepIndex: Int32, deathDelay: Float) -> Bool {
  let elapsed: Float;
  if deathDelay <= 0.00 { return true; };
  elapsed = MaxF(0.0, baseDelay) + (Cast<Float>(stepIndex) * MaxF(0.0, stepDelay));
  return elapsed >= deathDelay;
}

private static func HIS_GetHeadPos(p: wref<NPCPuppet>, out headPos: Vector4) -> Bool {
  let slotComponent = p.GetSlotComponent();
  let headTransform: WorldTransform;
  let gotHead: Bool;

  if !IsDefined(slotComponent) { return false; };
  gotHead = slotComponent.GetSlotTransform(n"Head", headTransform);
  if !gotHead { return false; };

  headPos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(headTransform));
  return true;
}

private static func HIS_GetNeckPos(p: wref<NPCPuppet>, out neckPos: Vector4) -> Bool {
  let slotComponent = p.GetSlotComponent();
  let neckTransform: WorldTransform;
  let gotNeck: Bool;

  if !IsDefined(slotComponent) { return false; };
  gotNeck = slotComponent.GetSlotTransform(n"Neck", neckTransform);
  if !gotNeck { return false; };

  neckPos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(neckTransform));
  return true;
}

private static func HIS_GetHeadTargetPos(p: wref<NPCPuppet>, s: ref<HIS_Settings>, out targetPos: Vector4) -> Bool {
  let headPos: Vector4;
  let neckPos: Vector4;
  let dir: Vector4;
  let offset: Float;

  if !HIS_GetHeadPos(p, headPos) { return false; };

  offset = s.headTargetOffset;
  if AbsF(offset) <= 0.0001 {
    targetPos = headPos;
    return true;
  };

  if HIS_GetNeckPos(p, neckPos) {
    dir = headPos - neckPos;
    if Vector4.Length(dir) > 0.0001 {
      dir = Vector4.Normalize(dir);
      targetPos = headPos + (dir * offset);
      return true;
    };
  };

  targetPos = headPos + Vector4(0.0, 0.0, offset, 0.0);
  return true;
}

private static func HIS_GetReboundProbePos(p: wref<NPCPuppet>, out probePos: Vector4) -> Bool {
  // Head Forward Rebound detection must track the actual Head slot.
  // Do not offset the probe through the Neck: the skull can move substantially
  // while the Neck remains nearly stationary on some ragdolls.
  return HIS_GetHeadPos(p, probePos);
}

private static func HIS_GetLeftKneePos(p: wref<NPCPuppet>, out kneePos: Vector4) -> Bool {
  let slotComponent = p.GetSlotComponent();
  let kneeTransform: WorldTransform;
  let ok: Bool;

  if !IsDefined(slotComponent) { return false; };

  ok = slotComponent.GetSlotTransform(n"LeftLeg", kneeTransform);
  if !ok { ok = slotComponent.GetSlotTransform(n"LeftUpLeg", kneeTransform); };
  if !ok { return false; };

  kneePos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(kneeTransform));
  return true;
}

private static func HIS_GetRightKneePos(p: wref<NPCPuppet>, out kneePos: Vector4) -> Bool {
  let slotComponent = p.GetSlotComponent();
  let kneeTransform: WorldTransform;
  let ok: Bool;

  if !IsDefined(slotComponent) { return false; };

  ok = slotComponent.GetSlotTransform(n"RightLeg", kneeTransform);
  if !ok { ok = slotComponent.GetSlotTransform(n"RightUpLeg", kneeTransform); };
  if !ok { return false; };

  kneePos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(kneeTransform));
  return true;
}

private static func HIS_GetLeftFootPos(p: wref<NPCPuppet>, out footPos: Vector4) -> Bool {
  let slotComponent = p.GetSlotComponent();
  let footTransform: WorldTransform;
  let ok: Bool;

  if !IsDefined(slotComponent) { return false; };

  ok = slotComponent.GetSlotTransform(n"LeftFoot", footTransform);
  if !ok { ok = slotComponent.GetSlotTransform(n"LeftToe", footTransform); };
  if !ok { ok = slotComponent.GetSlotTransform(n"LeftLeg", footTransform); };
  if !ok { ok = slotComponent.GetSlotTransform(n"LeftUpLeg", footTransform); };
  if !ok { return false; };

  footPos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(footTransform));
  return true;
}

private static func HIS_GetRightFootPos(p: wref<NPCPuppet>, out footPos: Vector4) -> Bool {
  let slotComponent = p.GetSlotComponent();
  let footTransform: WorldTransform;
  let ok: Bool;

  if !IsDefined(slotComponent) { return false; };

  ok = slotComponent.GetSlotTransform(n"RightFoot", footTransform);
  if !ok { ok = slotComponent.GetSlotTransform(n"RightToe", footTransform); };
  if !ok { ok = slotComponent.GetSlotTransform(n"RightLeg", footTransform); };
  if !ok { ok = slotComponent.GetSlotTransform(n"RightUpLeg", footTransform); };
  if !ok { return false; };

  footPos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(footTransform));
  return true;
}

private static func HIS_GetFootMid(leftFootPos: Vector4, rightFootPos: Vector4) -> Vector4 {
  return (leftFootPos + rightFootPos) * 0.5;
}

private static func HIS_GetKneeMid(leftKneePos: Vector4, rightKneePos: Vector4) -> Vector4 {
  return (leftKneePos + rightKneePos) * 0.5;
}

// Prefer the real leg/knee slots. Some NPC rigs do not expose those slots, so
// fall back to the foot slots instead of permanently failing the rebound gate.
private static func HIS_GetLeftReboundKneePos(p: wref<NPCPuppet>, out kneePos: Vector4) -> Bool {
  if HIS_GetLeftKneePos(p, kneePos) { return true; };
  return HIS_GetLeftFootPos(p, kneePos);
}

private static func HIS_GetRightReboundKneePos(p: wref<NPCPuppet>, out kneePos: Vector4) -> Bool {
  if HIS_GetRightKneePos(p, kneePos) { return true; };
  return HIS_GetRightFootPos(p, kneePos);
}

private static func HIS_GetUpperPos(p: wref<NPCPuppet>, out upperPos: Vector4) -> Bool {
  let slotComponent = p.GetSlotComponent();
  let upperTransform: WorldTransform;
  let ok: Bool;

  if !IsDefined(slotComponent) { return false; };

  ok = slotComponent.GetSlotTransform(n"Spine3", upperTransform);
  if !ok { ok = slotComponent.GetSlotTransform(n"Chest", upperTransform); };
  if !ok { ok = slotComponent.GetSlotTransform(n"Neck", upperTransform); };
  if !ok { return false; };

  upperPos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(upperTransform));
  return true;
}
private static func HIS_ReboundForwardDetectorPasses(
  p: wref<NPCPuppet>,
  s: ref<HIS_Settings>,
  headNow: Vector4,
  upperNow: Vector4
) -> Bool {
  let probeNow: Vector4;
  let probeRelStart: Vector4;
  let probeRelNow: Vector4;
  let headForwardMove: Float;
  let headDrop: Float;
  let leftKneeNow: Vector4;
  let rightKneeNow: Vector4;
  let kneeMidStart: Vector4;
  let kneeMidNow: Vector4;
  let startDist: Float;
  let nowDist: Float;
  let closedPct: Float;

  if !s.reboundUseNeckFoldGate {
    return true;
  };

  if s.reboundNeckFoldMin <= 0.0001 &&
     s.reboundNeckDropMin <= 0.0001 &&
     s.reboundKneeNearPct <= 0.0001 {
    return true;
  };

  if !HIS_GetReboundProbePos(p, probeNow) {
    probeNow = headNow;
  };

  probeRelStart = p.hisStartProbePos - p.hisStartUpperPos;
  probeRelNow = probeNow - upperNow;

  if s.reboundNeckFoldMin > 0.0001 {
    // Match the known-working continuous rebound detector: measure absolute
    // forward displacement from the captured death-start Head slot. A signed
    // relative-to-chest delta can invert on some rigs and never pass.
    headForwardMove = AbsF(Vector4.Dot(probeNow - p.hisStartProbePos, p.hisBasisForward));

    if headForwardMove < s.reboundNeckFoldMin {
      return false;
    };
  };

  if s.reboundNeckDropMin > 0.0001 {
    headDrop = probeRelStart.Z - probeRelNow.Z;

    if headDrop < s.reboundNeckDropMin {
      return false;
    };
  };

  if s.reboundKneeNearPct > 0.0001 {
    if !HIS_GetLeftReboundKneePos(p, leftKneeNow) { return false; };
    if !HIS_GetRightReboundKneePos(p, rightKneeNow) { return false; };

    kneeMidStart = HIS_GetKneeMid(p.hisStartLeftKneePos, p.hisStartRightKneePos);
    kneeMidNow = HIS_GetKneeMid(leftKneeNow, rightKneeNow);

    startDist = Vector4.Length(p.hisStartProbePos - kneeMidStart);
    nowDist = Vector4.Length(probeNow - kneeMidNow);

    if startDist <= 0.0001 {
      if s.reboundKneeNearPct > 99.9999 && nowDist > 0.0001 {
        return false;
      };
    } else {
      closedPct = ((startDist - nowDist) / startDist) * 100.0;
      if closedPct < s.reboundKneeNearPct {
        return false;
      };
    };
  };

  return true;
}

private static func HIS_CaptureBasis(p: wref<NPCPuppet>) -> Void {
  let wt: WorldTransform;
  let fwd: Vector4;
  let right: Vector4;

  wt = p.GetWorldTransform();
  fwd = Quaternion.GetForward(WorldTransform.GetOrientation(wt));
  right = Quaternion.GetRight(WorldTransform.GetOrientation(wt));

  p.hisBasisForward = Vector4.Normalize(Vector4(fwd.X, fwd.Y, 0.0, 0.0));
  p.hisBasisRight = Vector4.Normalize(Vector4(right.X, right.Y, 0.0, 0.0));

  if Vector4.Length(p.hisBasisForward) <= 0.0001 {
    p.hisBasisForward = Vector4(0.0, 1.0, 0.0, 0.0);
  };

  if Vector4.Length(p.hisBasisRight) <= 0.0001 {
    p.hisBasisRight = Vector4(1.0, 0.0, 0.0, 0.0);
  };
}

private static func HIS_CaptureForwardReboundStart(p: wref<NPCPuppet>, s: ref<HIS_Settings>) -> Void {
  let headPos: Vector4;

  if !IsDefined(p) { return; };

  if !HIS_GetHeadPos(p, headPos) {
    headPos = p.hisPrevHeadPos;
  };

  if !HIS_GetUpperPos(p, p.hisStartUpperPos) {
    p.hisStartUpperPos = headPos;
  };

  if !HIS_GetReboundProbePos(p, p.hisStartProbePos) {
    p.hisStartProbePos = headPos;
  };

  if !HIS_GetLeftReboundKneePos(p, p.hisStartLeftKneePos) {
    p.hisStartLeftKneePos = p.hisStartUpperPos;
  };

  if !HIS_GetRightReboundKneePos(p, p.hisStartRightKneePos) {
    p.hisStartRightKneePos = p.hisStartUpperPos;
  };

  p.hisReboundStartSeeded = true;
}

private static func HIS_GetStepWeight(stepIndex: Int32, steps: Int32, rampMode: Int32) -> Float {
  let t: Float;

  if steps <= 1 { return 1.0; };
  t = Cast<Float>(stepIndex + 1) / Cast<Float>(steps);

  if rampMode == 1 {
    return 1.0 - t + (1.0 / Cast<Float>(steps));
  };

  return t;
}


private static func HIS_Sign(v: Float) -> Float {
  if v < 0.0 { return -1.0; };
  return 1.0;
}

private static func HIS_PickRange(minV: Float, maxV: Float) -> Float {
  let lo: Float = minV;
  let hi: Float = maxV;
  let t: Float;

  if hi < lo {
    lo = maxV;
    hi = minV;
  };

  if AbsF(hi - lo) <= 0.0001 {
    return lo;
  };

  t = RandRangeF(0.0, 1.0);
  return lo + ((hi - lo) * t);
}

private static func HIS_PickRangeForPuppet(p: wref<NPCPuppet>, minV: Float, maxV: Float) -> Float {
  let c: RFCConfig = RFC.Cfg();
  if p.rfc_randomProfileActive && c.randomPoolHead {
    return RFC_RandomHeadValue(p, c, minV, maxV);
  };
  return HIS_PickRange(minV, maxV);
}



private static func HIS_LaneMinOk(dirF: Float, minAbs: Float, lane: Int32) -> Bool {
  let need: Float = MaxF(0.0, minAbs);

  // If Direction Min is 0, the detector is off.
  // This makes the lane fire consistently when enabled.
  if need <= 0.0001 {
    return true;
  };

  if lane == 0 {
    return dirF >= need;
  };

  return dirF <= -need;
}

private static func HIS_BuildImpulseForStep(p: wref<NPCPuppet>, s: ref<HIS_Settings>, stepIndex: Int32, lane: Int32) -> Vector4 {
  let up: Vector4 = Vector4(0.0, 0.0, 1.0, 0.0);
  let out: Vector4;
  let w: Float;
  let fwd: Float;
  let side: Float;
  let vert: Float;
  let headNow: Vector4;
  let delta: Vector4;
  let dirF: Float;
  let dirS: Float;
  let upperNow: Vector4;
  let dirMin: Float;

  if lane == 0 {
    w = HIS_GetStepWeight(stepIndex, Max(1, s.steps), s.rampMode);
    dirMin = s.directionMin;
  } else {
    // Falling Back should always push backward.
    // Do not let tiny direction jitter flip the impulse forward.
    fwd = HIS_PickRangeForPuppet(p, s.backForwardBackMin, s.backForwardBackMax) * -1.0;
    side = HIS_PickRangeForPuppet(p, s.backLeftRightMin, s.backLeftRightMax) * HIS_Sign(dirS);
    vert = HIS_PickRangeForPuppet(p, s.backUpDownMin, s.backUpDownMax) * -1.0;
  };

  if !HIS_GetHeadPos(p, headNow) {
    return Vector4(0.0, 0.0, 0.0, 0.0);
  };
  if !HIS_GetUpperPos(p, upperNow) {
    upperNow = headNow;
  };

  if lane == 0 {
    delta = upperNow - p.hisPrevUpperPos;
  } else {
    // Falling Back should be measured from the death-start chest position,
    // not from tiny frame-to-frame jitter.
    delta = upperNow - p.hisStartUpperPos;
  };

  dirF = Vector4.Dot(delta, p.hisBasisForward);
  dirS = Vector4.Dot(delta, p.hisBasisRight);
  if !HIS_LaneMinOk(dirF, dirMin, lane) {
    p.hisPrevHeadPos = headNow;
    p.hisPrevUpperPos = upperNow;
    return Vector4(0.0, 0.0, 0.0, 0.0);
  };

  if lane == 0 {
    // The Head Forward lane has a directional contract: it can never turn
    // into a backward fall because of frame-to-frame chest jitter.
    fwd = AbsF(HIS_PickRangeForPuppet(p, s.forwardBackMin, s.forwardBackMax));
    side = HIS_PickRangeForPuppet(p, s.leftRightMin, s.leftRightMax) * HIS_Sign(dirS);
    vert = HIS_PickRangeForPuppet(p, s.upDownMin, s.upDownMax) * -1.0;
  } else {
    // Fallback is the opposite directional lane and always pushes backward.
    fwd = 0.0 - AbsF(HIS_PickRangeForPuppet(p, s.backForwardBackMin, s.backForwardBackMax));
    side = HIS_PickRangeForPuppet(p, s.backLeftRightMin, s.backLeftRightMax) * HIS_Sign(dirS);
    vert = HIS_PickRangeForPuppet(p, s.backUpDownMin, s.backUpDownMax) * -1.0;
  };

  p.hisHeadTriggered = true;
  p.hisPrevHeadPos = headNow;
  p.hisPrevUpperPos = upperNow;
  p.hisReboundArmed = true;

  if lane == 0 {
    if s.enableRebound && s.reboundRequiresHeadImpulse && !p.hisDidForwardRebound {
      if HIS_ShouldTriggerRebound(s) {
        p.hisDidForwardRebound = true;
        HIS_ScheduleReboundSteps(p, s, 0);
      } else {
        p.hisDidForwardRebound = true;
      };
    };
  } else {
    if s.enableBackRebound && s.backReboundRequiresHeadImpulse && !p.hisDidBackRebound {
      if HIS_RollChancePct(s.backReboundChancePct) {
        p.hisDidBackRebound = true;
        HIS_ScheduleReboundSteps(p, s, 1);
      } else {
        p.hisDidBackRebound = true;
      };
    };
  };

  out = p.hisBasisForward * (fwd * w);
  out += p.hisBasisRight * (side * w);
  out += up * (vert * w);
  // Match the impulse vectors used by the working Arcade/body paths.
  out.W = 1.0;
  return out;
};

private static func HIS_BuildReboundImpulseForStep(p: wref<NPCPuppet>, s: ref<HIS_Settings>, stepIndex: Int32, lane: Int32) -> Vector4 {
  let up: Vector4 = Vector4(0.0, 0.0, 1.0, 0.0);
  let out: Vector4;
  let w: Float;
  let fwd: Float;
  let side: Float;
  let vert: Float;
  let headNow: Vector4;
  let upperNow: Vector4;
  let delta: Vector4;
  let dirF: Float;
  let dirS: Float;

  if lane == 0 {
    if s.reboundRequiresHeadImpulse && !p.hisReboundArmed {
      return Vector4(0.0, 0.0, 0.0, 0.0);
    };
  } else {
    if s.backReboundRequiresHeadImpulse && !p.hisReboundArmed {
      return Vector4(0.0, 0.0, 0.0, 0.0);
    };
  };

  if lane == 0 {
    w = HIS_GetStepWeight(stepIndex, Max(1, s.reboundSteps), s.reboundRampMode);
  } else {
    w = HIS_GetStepWeight(stepIndex, Max(1, s.backReboundSteps), s.backReboundRampMode);
  };

  if !HIS_GetHeadPos(p, headNow) {
    return Vector4(0.0, 0.0, 0.0, 0.0);
  };
  if !HIS_GetUpperPos(p, upperNow) {
    upperNow = headNow;
  };

  delta = upperNow - p.hisPrevUpperPos;

  dirF = Vector4.Dot(delta, p.hisBasisForward);
  dirS = Vector4.Dot(delta, p.hisBasisRight);

  if lane == 0 {
    if !s.reboundUseNeckFoldGate || (
      s.reboundNeckFoldMin <= 0.0001 &&
      s.reboundNeckDropMin <= 0.0001 &&
      s.reboundKneeNearPct <= 0.0001
    ) {
      if !HIS_LaneMinOk(dirF, s.reboundDirectionMin, 0) {
        p.hisPrevHeadPos = headNow;
        p.hisPrevUpperPos = upperNow;
        return Vector4(0.0, 0.0, 0.0, 0.0);
      };
    };
    // A forward-fall rebound always recoils backward.
    fwd = 0.0 - AbsF(HIS_PickRangeForPuppet(p, s.reboundForwardMin, s.reboundForwardMax));
    side = HIS_PickRangeForPuppet(p, s.reboundSideMin, s.reboundSideMax) * HIS_Sign(dirS) * -1.0;
    vert = HIS_PickRangeForPuppet(p, s.reboundUpMin, s.reboundUpMax);
  } else {
    if !HIS_LaneMinOk(dirF, s.backReboundDirectionMin, 1) { 
      p.hisPrevHeadPos = headNow;
      p.hisPrevUpperPos = upperNow;
      return Vector4(0.0,0.0,0.0,0.0); 
    };
    // A backward-fall rebound always recoils forward.
    fwd = AbsF(HIS_PickRangeForPuppet(p, s.backReboundForwardMin, s.backReboundForwardMax));
    side = HIS_PickRangeForPuppet(p, s.backReboundSideMin, s.backReboundSideMax) * HIS_Sign(dirS) * -1.0;
    vert = HIS_PickRangeForPuppet(p, s.backReboundUpMin, s.backReboundUpMax);
  };

  p.hisPrevHeadPos = headNow;
  p.hisPrevUpperPos = upperNow;

  out = p.hisBasisForward * (fwd * w);
  out += p.hisBasisRight * (side * w);
  out += up * (vert * w);
  // Match the impulse vectors used by the working Arcade/body paths.
  out.W = 1.0;
  return out;
}

private static func HIS_HeadOnlyRadius(radius: Float) -> Float {
  // Head Falls must remain a skull/neck-local impulse. Larger radii reach the
  // chest and make the lane look like a generic torso fall.
  return ClampF(radius, 0.01, 0.30);
}

private static func HIS_SendRaw(p: wref<NPCPuppet>, s: ref<HIS_Settings>, radius: Float, impulse: Vector4) -> Bool {
  let headPos: Vector4;
  if RFC.Cfg().vanillaMode { return false; };
  if !IsDefined(p) { return false; };
  if RFC_TimeDilationBlocksImpulsesNow(p) { return false; };
  if RFC_IsVehicleContext(p) { return false; };
  if !HIS_GetHeadTargetPos(p, s, headPos) { return false; };
  if AbsF(impulse.X) <= 0.0001 && AbsF(impulse.Y) <= 0.0001 && AbsF(impulse.Z) <= 0.0001 { return false; };
  p.QueueEvent(CreateRagdollApplyImpulseEvent(headPos, impulse, HIS_HeadOnlyRadius(radius)));
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnHIS_SituationalHeadEvt(evt: ref<HIS_SituationalHeadEvt>) -> Bool {
  if RFC.Cfg().vanillaMode { return true; }
  let s: ref<HIS_Settings>;
  let impulse: Vector4;

  if !IsDefined(evt) { return true; }

  s = SPLATSettingsRuntime.Head();
  if !IsDefined(s) { return true; }

  impulse = new Vector4(0.0, 0.0, evt.impulseZ, 1.0);
  HIS_SendRaw(this, s, evt.radius, impulse);
  return true;
}

public func HIS_ScheduleSituationalHeadDown(
  p: wref<NPCPuppet>,
  ds: ref<DelaySystem>,
  c: RFCConfig,
  minStrength: Float,
  maxStrength: Float,
  radius: Float,
  delay: Float
) -> Void {
  let evt: ref<HIS_SituationalHeadEvt>;

  if !IsDefined(p) || radius <= 0.0 { return; }
  if RFC_TimeDilationBlocksImpulses(p, c) { return; }
  if RFC_IsVehicleContext(p) || RFC_Explode_IsRecent(p) { return; }

  evt = new HIS_SituationalHeadEvt();
  evt.impulseZ = RFC_RandomHeadValue(p, c, minStrength, maxStrength);
  evt.radius = radius;

  if !IsDefined(ds) {
    p.QueueEvent(evt);
    return;
  }

  // Standard Head Falls works because the head-local event arrives after the
  // ragdoll bodies exist. Generic situational bursts could fire at 0.006 sec
  // and disappear before the Head rigid body was active.
  ds.DelayEvent(p, evt, MaxF(RFC_ClampT(delay), 0.040), false);
}



private static func HIS_SendStep(p: wref<NPCPuppet>, s: ref<HIS_Settings>, stepIndex: Int32, lane: Int32) -> Void {
  let sent: Bool;
  if lane == 0 {
    sent = HIS_SendRaw(p, s, s.radius, HIS_BuildImpulseForStep(p, s, stepIndex, lane));
    if sent { p.hisHeadImpulseFired = true; };
  } else {
    sent = HIS_SendRaw(p, s, s.backRadius, HIS_BuildImpulseForStep(p, s, stepIndex, lane));
    if sent { p.hisBackHeadImpulseFired = true; };
  };
}

private static func HIS_SendReboundStep(p: wref<NPCPuppet>, s: ref<HIS_Settings>, stepIndex: Int32, lane: Int32) -> Void {
  if lane == 0 {
    HIS_SendRaw(p, s, s.reboundRadius, HIS_BuildReboundImpulseForStep(p, s, stepIndex, lane));
  } else {
    HIS_SendRaw(p, s, s.backReboundRadius, HIS_BuildReboundImpulseForStep(p, s, stepIndex, lane));
  };
}

private static func HIS_ScheduleMainSteps(p: wref<NPCPuppet>, s: ref<HIS_Settings>, lane: Int32) -> Void {
  let ds: ref<DelaySystem>;
  let i: Int32;
  let e: ref<HIS_FireEvt>;
  let when: Float;
  let steps: Int32;

  if !IsDefined(p) { return; };
  HIS_GetHeadPos(p, p.hisPrevHeadPos);
  if !HIS_GetUpperPos(p, p.hisPrevUpperPos) { p.hisPrevUpperPos = p.hisPrevHeadPos; };
  p.hisStartUpperPos = p.hisPrevUpperPos;

  if lane == 0 && !p.hisReboundStartSeeded {
    HIS_CaptureForwardReboundStart(p, s);
  };

  p.hisHeadTriggered = false;
  p.hisHeadMoveSeeded = false;
  if lane == 0 { p.hisHeadImpulseFired = false; } else { p.hisBackHeadImpulseFired = false; };
  ds = GameInstance.GetDelaySystem(p.GetGame());

  if !IsDefined(ds) {
    HIS_SendStep(p, s, 0, lane);
    return;
  };

  if lane == 0 { steps = Max(1, s.steps); } else { steps = Max(1, s.backSteps); }


  i = 0;
  while i < steps {
    e = new HIS_FireEvt();
    e.stepIndex = i;
    e.lane = lane;
    if lane == 0 {
      when = MaxF(0.0, s.delaySec) + (Cast<Float>(i) * MaxF(0.0, s.stepDelay));
    } else {
      when = MaxF(0.0, s.backDelaySec) + (Cast<Float>(i) * MaxF(0.0, s.backStepDelay));
    }
    ds.DelayEvent(p, e, when, false);
    i += 1;
  };
}

private static func HIS_ScheduleReboundSteps(p: wref<NPCPuppet>, s: ref<HIS_Settings>, lane: Int32) -> Void {
  let ds: ref<DelaySystem>;
  let i: Int32;
  let e: ref<HIS_ReboundEvt>;
  let when: Float;
  let steps: Int32;

  if !IsDefined(p) { return; };
  if !HIS_GetHeadPos(p, p.hisPrevHeadPos) { };
  if !HIS_GetUpperPos(p, p.hisPrevUpperPos) { p.hisPrevUpperPos = p.hisPrevHeadPos; };
  p.hisHeadTriggered = false;
  p.hisHeadMoveSeeded = false;
  ds = GameInstance.GetDelaySystem(p.GetGame());

  if lane == 0 {
    if !p.hisReboundStartSeeded {
      HIS_CaptureForwardReboundStart(p, s);
    };
  };

  if !IsDefined(ds) {
    HIS_SendReboundStep(p, s, 0, lane);
    return;
  };

  if lane == 0 { steps = Max(1, s.reboundSteps); } else { steps = Max(1, s.backReboundSteps); }

  i = 0;
  while i < steps {
    e = new HIS_ReboundEvt();
    e.stepIndex = i;
    e.lane = lane;
    e.retryIndex = 0;
    if lane == 0 {
      when = MaxF(0.0, s.reboundDelay) + (Cast<Float>(i) * MaxF(0.0, s.reboundStepDelay));
    } else {
      when = MaxF(0.0, s.backReboundDelay) + (Cast<Float>(i) * MaxF(0.0, s.backReboundStepDelay));
    }
    ds.DelayEvent(p, e, when, false);
    i += 1;
  };
}


@addMethod(NPCPuppet)
protected cb func OnHIS_FireEvt(evt: ref<HIS_FireEvt>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let s: ref<HIS_Settings> = SPLATSettingsRuntime.Head();
  HIS_ApplyModeOverrides(s, c);
  if c.vanillaMode { return true; }
  
  if !HIS_ShouldRun(this, s) { return true; };
  if evt.lane == 0 {
    if !s.enabled { return true; };
    if HIS_DeathGateActive(s.delaySec, s.stepDelay, evt.stepIndex, s.headKillOnDeathDelay) && s.disableOnGround && HIS_IsOnGround(this) && HIS_GroundGateActive(s.delaySec, s.stepDelay, evt.stepIndex, s.disableOnGroundDelay) { return true; };
  } else {
    if !s.backEnabled { return true; };
    if HIS_DeathGateActive(s.backDelaySec, s.backStepDelay, evt.stepIndex, s.backKillOnDeathDelay) && s.backDisableOnGround && HIS_IsOnGround(this) && HIS_GroundGateActive(s.backDelaySec, s.backStepDelay, evt.stepIndex, s.backDisableOnGroundDelay) { return true; };
  };
  HIS_SendStep(this, s, evt.stepIndex, evt.lane);
  return true;
}


private static func HIS_ForwardReboundDetectorIsActive(s: ref<HIS_Settings>) -> Bool {
  if !s.reboundUseNeckFoldGate {
    return false;
  };

  if s.reboundNeckFoldMin > 0.0001 {
    return true;
  };

  if s.reboundNeckDropMin > 0.0001 {
    return true;
  };

  if s.reboundKneeNearPct > 0.0001 {
    return true;
  };

  return false;
}

private static func HIS_ForwardReboundWatchElapsed(s: ref<HIS_Settings>, evt: ref<HIS_ReboundEvt>) -> Float {
  return MaxF(0.0, s.reboundDelay)
    + (Cast<Float>(evt.stepIndex) * MaxF(0.0, s.reboundStepDelay))
    + (Cast<Float>(evt.retryIndex) * 0.03);
}

private static func HIS_ForwardReboundWatchShouldStopOnGround(
  p: wref<NPCPuppet>,
  s: ref<HIS_Settings>,
  evt: ref<HIS_ReboundEvt>
) -> Bool {
  if !s.reboundDisableOnGround {
    return false;
  };

  if !HIS_IsOnGround(p) {
    return false;
  };

  return HIS_ForwardReboundWatchElapsed(s, evt) >= s.reboundDisableOnGroundDelay;
}

private static func HIS_ForwardReboundWatchExpired(s: ref<HIS_Settings>, evt: ref<HIS_ReboundEvt>) -> Bool {
  if s.reboundKillOnDeathDelay <= 0.0001 {
    return false;
  };

  return HIS_ForwardReboundWatchElapsed(s, evt) >= s.reboundKillOnDeathDelay;
}

private static func HIS_RetryForwardRebound(p: wref<NPCPuppet>, evt: ref<HIS_ReboundEvt>) -> Void {
  let ds: ref<DelaySystem>;
  let retryEvt: ref<HIS_ReboundEvt>;

  if !IsDefined(p) {
    return;
  };

  ds = GameInstance.GetDelaySystem(p.GetGame());

  if !IsDefined(ds) {
    return;
  };

  retryEvt = new HIS_ReboundEvt();
  retryEvt.stepIndex = evt.stepIndex;
  retryEvt.lane = evt.lane;
  retryEvt.retryIndex = evt.retryIndex + 1;

  ds.DelayEvent(p, retryEvt, 0.03, false);
}

@addMethod(NPCPuppet)
protected cb func OnHIS_ReboundEvt(evt: ref<HIS_ReboundEvt>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let s: ref<HIS_Settings> = SPLATSettingsRuntime.Head();
  let ds: ref<DelaySystem>;
  let retryEvt: ref<HIS_ReboundEvt>;
  let headNow: Vector4;
  let upperNow: Vector4;

  HIS_ApplyModeOverrides(s, c);

  if c.vanillaMode { return true; };

  if !HIS_ShouldRun(this, s) { return true; };

  if evt.lane == 0 {
    if !s.enableRebound { return true; };

    if s.reboundRequiresHeadImpulse && !this.hisHeadImpulseFired {
      ds = GameInstance.GetDelaySystem(this.GetGame());
      if IsDefined(ds) && !HIS_ForwardReboundWatchExpired(s, evt) {
        retryEvt = new HIS_ReboundEvt();
        retryEvt.stepIndex = evt.stepIndex;
        retryEvt.lane = evt.lane;
        retryEvt.retryIndex = evt.retryIndex + 1;
        ds.DelayEvent(this, retryEvt, 0.03, false);
      };
      return true;
    };

    if HIS_ForwardReboundWatchExpired(s, evt) {
      return true;
    };

    if HIS_ForwardReboundWatchShouldStopOnGround(this, s, evt) {
      return true;
    };

    if HIS_ForwardReboundDetectorIsActive(s) {
      if !HIS_GetHeadPos(this, headNow) {
        HIS_RetryForwardRebound(this, evt);
        return true;
      };

      if !HIS_GetUpperPos(this, upperNow) {
        upperNow = headNow;
      };

      if !HIS_ReboundForwardDetectorPasses(this, s, headNow, upperNow) {
        HIS_RetryForwardRebound(this, evt);
        return true;
      };
    };
  } else {
    if !s.enableBackRebound { return true; };

    if s.backReboundRequiresHeadImpulse && !this.hisBackHeadImpulseFired {
      ds = GameInstance.GetDelaySystem(this.GetGame());
      if IsDefined(ds) {
        retryEvt = new HIS_ReboundEvt();
        retryEvt.stepIndex = evt.stepIndex;
        retryEvt.lane = evt.lane;
        retryEvt.retryIndex = evt.retryIndex + 1;
        ds.DelayEvent(this, retryEvt, 0.03, false);
      };
      return true;
    };

    if HIS_DeathGateActive(s.backReboundDelay, s.backReboundStepDelay, evt.stepIndex, s.backReboundKillOnDeathDelay) &&
       s.backReboundDisableOnGround &&
       HIS_IsOnGround(this) &&
       HIS_GroundGateActive(s.backReboundDelay, s.backReboundStepDelay, evt.stepIndex, s.backReboundDisableOnGroundDelay) {
      return true;
    };
  };

  HIS_SendReboundStep(this, s, evt.stepIndex, evt.lane);
  return true;
}
public class RFC_HeadFallsLogicImpulse {

  public static func RunOnDeathHeadFalls(
    puppet: ref<NPCPuppet>,
    ds: ref<DelaySystem>,
    c: RFCConfig
  ) -> Void {
    let s: ref<HIS_Settings>;
    let sh: ref<SHHJM_Settings>;
    let headHardBlock: Bool;
    
    if c.vanillaMode { return; }

    if !IsDefined(puppet) {
      return;
    }

    if RFC_MasterDeathChanceBlocksImpulses(puppet) { return; }
    if !puppet.rfc_allowHeadFalls { return; }
    if RFC_SitOverrideHeadBlock(puppet, c) { return; }

    s = SPLATSettingsRuntime.Head();
    HIS_ApplyModeOverrides(s, c);
    sh = SPLATSettingsRuntime.Jolts();
    headHardBlock = RFC_HeadHardBlock(puppet);

    if headHardBlock {
      return;
    }

    puppet.hisReboundStartSeeded = false;
    HIS_CaptureBasis(puppet);
    HIS_CaptureForwardReboundStart(puppet, s);

    if HIS_ShouldRun(puppet, s) {
      if s.enabled && s.onDeath && HIS_ShouldTriggerHeadImpulse(s) {
        if !s.disableOnGround || s.disableOnGroundDelay > 0.00 || !HIS_IsOnGround(puppet) {
          HIS_CaptureBasis(puppet);
          HIS_ScheduleMainSteps(puppet, s, 0);
        };
      };

      if s.backEnabled && s.backOnDeath && HIS_RollChancePct(s.backChancePct) {
        if !s.backDisableOnGround || s.backDisableOnGroundDelay > 0.00 || !HIS_IsOnGround(puppet) {
          HIS_CaptureBasis(puppet);
          HIS_ScheduleMainSteps(puppet, s, 1);
        };
      };

      if s.enableRebound && !s.reboundRequiresHeadImpulse && !s.reboundOnImpact && HIS_ShouldTriggerRebound(s) {
        if !s.reboundDisableOnGround || s.reboundDisableOnGroundDelay > 0.00 || !HIS_IsOnGround(puppet) {
          HIS_CaptureBasis(puppet);
          puppet.hisDidForwardRebound = true;
          HIS_ScheduleReboundSteps(puppet, s, 0);
        };
      };

      if s.enableBackRebound && !s.backReboundRequiresHeadImpulse && !s.backReboundOnImpact && HIS_RollChancePct(s.backReboundChancePct) {
        if !s.backReboundDisableOnGround || s.backReboundDisableOnGroundDelay > 0.00 || !HIS_IsOnGround(puppet) {
          HIS_CaptureBasis(puppet);
          puppet.hisDidBackRebound = true;
          HIS_ScheduleReboundSteps(puppet, s, 1);
        };
      };
    };

    if puppet.shhjm_lastHitValid {
      if SHHJM_GetPartEnabled(puppet.shhjm_lastBodyPart, sh) {
        SHHJM_Sched(puppet, new SHHJM_OnDeathApplyEvt(), SHHJM_GetDeathDelay(puppet.shhjm_lastBodyPart, sh));
      };
    };
  }
}
