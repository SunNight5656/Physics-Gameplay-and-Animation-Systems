module RealisticPush

private func SHHJM_Len3(v: Vector4) -> Float {
  return SqrtF(v.X * v.X + v.Y * v.Y + v.Z * v.Z);
}

private func SHHJM_NormalizeSafe(v: Vector4) -> Vector4 {
  let len: Float = MaxF(0.001, SHHJM_Len3(v));
  return new Vector4(v.X / len, v.Y / len, v.Z / len, 1.0);
}

private func SHHJM_DistSq(a: Vector4, b: Vector4) -> Float {
  let d: Vector4 = a - b;
  return d.X * d.X + d.Y * d.Y + d.Z * d.Z;
}

private func SHHJM_Sched(go: wref<GameObject>, evt: ref<Event>, t: Float) -> Void {
  let ds: ref<DelaySystem>;
  if !IsDefined(go) || !IsDefined(evt) {
    return;
  };
  ds = GameInstance.GetDelaySystem(go.GetGame());
  if !IsDefined(ds) {
    return;
  };
  ds.DelayEvent(go, evt, MaxF(0.001, t), false);
}

private func SHHJM_Now(go: wref<GameObject>) -> Float {
  if !IsDefined(go) {
    return 0.0;
  };
  return EngineTime.ToFloat(GameInstance.GetSimTime(go.GetGame()));
}

private func SHHJM_HasGroundImpactSince(puppet: wref<NPCPuppet>, armedAt: Float) -> Bool {
  if !IsDefined(puppet) {
    return false;
  };
  if !puppet.shhjm_hasGroundImpact {
    return false;
  };
  return puppet.shhjm_lastGroundImpactTime >= armedAt;
}

private func SHHJM_IsOnGround(puppet: wref<NPCPuppet>) -> Bool {
  let nav: ref<NavigationSystem>;
  if !IsDefined(puppet) {
    return false;
  };
  nav = GameInstance.GetNavigationSystem(puppet.GetGame());
  if !IsDefined(nav) {
    return false;
  };
  return nav.IsOnGround(puppet);
}

private func SHHJM_GetWaitForGround(part: Int32, s: ref<SHHJM_Settings>) -> Bool {
  return RFC.Cfg().bulletJoltWaitForGround;
}

private func SHHJM_GetGroundWaitMax(part: Int32, s: ref<SHHJM_Settings>) -> Float {
  return RFC.Cfg().bulletJoltGroundWaitMax;
}

private func SHHJM_QueueJolt(puppet: ref<NPCPuppet>, part: Int32, srcPos: Vector4, anchorPos: Vector4, fireDelay: Float, s: ref<SHHJM_Settings>) -> Void {
  let applyEvt: ref<SHHJM_ApplyImpulseEvt>;
  let waitEvt: ref<SHHJM_WaitForGroundEvt>;
  let applyAnchor: Vector4;
  let nowT: Float;

  let c: RFCConfig = RFC.Cfg();
  if !IsDefined(puppet) || !IsDefined(s) {
    return;
  };
  if c.vanillaMode || RFC_TimeDilationBlocksImpulses(puppet, c) || !c.bulletJoltsEnabled {
    return;
  };

  applyAnchor = SHHJM_BiasAnchorInwardBySettings(puppet, part, anchorPos, s);

  if puppet.IsDead() && c.bulletJoltWaitForGround && !c.bulletJoltAllowAirborne && !SHHJM_IsOnGround(puppet) {
    nowT = SHHJM_Now(puppet);
    waitEvt = new SHHJM_WaitForGroundEvt();
    waitEvt.srcPos = srcPos;
    waitEvt.anchorPos = anchorPos;
    waitEvt.part = part;
    waitEvt.fireDelay = MaxF(0.001, fireDelay);
    waitEvt.armedAt = nowT;
    waitEvt.expireAt = nowT + MaxF(0.10, SHHJM_GetGroundWaitMax(part, s));
    SHHJM_Sched(puppet, waitEvt, 0.01);
    return;
  };

  applyEvt = new SHHJM_ApplyImpulseEvt();
  applyEvt.pos = applyAnchor;
  applyEvt.imp = SHHJM_BuildImpulse(puppet, srcPos, applyAnchor, part, s);
  applyEvt.srcPos = srcPos;
  applyEvt.radius = SHHJM_GetRadius(part, s);
  applyEvt.part = part;

  // Custom SPLAT jolt lane:
  // v73/v74 correctly kill the vanilla physical impulse lane. That also means
  // the custom body-part jolt should not assume the native pipeline already has
  // the corpse in a stable ragdoll state. Wake/refresh ragdoll first, then apply
  // the SPLAT impulse on the next small tick.
  if puppet.IsDead() {
    SHHJM_Sched(puppet, new SHHJM_ForceRagdollEvt(), 0.001);
    SHHJM_Sched(puppet, applyEvt, MaxF(0.012, fireDelay));
  } else {
    SHHJM_Sched(puppet, applyEvt, MaxF(0.001, fireDelay));
  };
}



@addMethod(NPCPuppet)
protected cb func OnSHHJM_WaitForGroundEvt(evt: ref<SHHJM_WaitForGroundEvt>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let s: ref<SHHJM_Settings>;
  let retryEvt: ref<SHHJM_WaitForGroundEvt>;
  let applyEvt: ref<SHHJM_ApplyImpulseEvt>;
  let groundedAnchor: Vector4;

  if c.vanillaMode || RFC_TimeDilationBlocksImpulses(this, c) || !c.bulletJoltsEnabled {
    return true;
  };
  if !IsDefined(evt) {
    return true;
  };

  s = SPLATSettingsRuntime.Jolts();
  if !SHHJM_GetPartEnabled(evt.part, s) {
    return true;
  };

  if SHHJM_IsOnGround(this) || SHHJM_HasGroundImpactSince(this, evt.armedAt) {
    groundedAnchor = SHHJM_BiasAnchorInwardBySettings(this, evt.part, evt.anchorPos, s);

    applyEvt = new SHHJM_ApplyImpulseEvt();
    applyEvt.pos = groundedAnchor;
    applyEvt.imp = SHHJM_BuildImpulse(this, evt.srcPos, groundedAnchor, evt.part, s);
    applyEvt.srcPos = evt.srcPos;
    applyEvt.radius = SHHJM_GetRadius(evt.part, s);
    applyEvt.part = evt.part;

    // Ground-wait SPLAT jolt lane:
    // fire only after the vanilla lane killer has done its cleanup, and make
    // sure this custom jolt owns the ragdoll refresh instead of depending on
    // the native delayed ground impulse.
    SHHJM_Sched(this, new SHHJM_ForceRagdollEvt(), 0.001);
    SHHJM_Sched(this, applyEvt, MaxF(0.012, evt.fireDelay));
    return true;
  };

  if SHHJM_Now(this) >= evt.expireAt {
    return true;
  };

  retryEvt = new SHHJM_WaitForGroundEvt();
  retryEvt.srcPos = evt.srcPos;
  retryEvt.anchorPos = evt.anchorPos;
  retryEvt.part = evt.part;
  retryEvt.fireDelay = evt.fireDelay;
  retryEvt.expireAt = evt.expireAt;
  retryEvt.armedAt = evt.armedAt;
  SHHJM_Sched(this, retryEvt, 0.01);

  return true;
}

private func SHHJM_GetSlotWorldPos(puppet: ref<NPCPuppet>, slotName: CName, out pos: Vector4) -> Bool {
  let slotComp: ref<SlotComponent>;
  let slotTransform: WorldTransform;

  if !IsDefined(puppet) {
    return false;
  };

  slotComp = puppet.GetSlotComponent();
  if !IsDefined(slotComp) {
    return false;
  };

  if !slotComp.GetSlotTransform(slotName, slotTransform) {
    return false;
  };

  pos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
  return true;
}

private func SHHJM_GetSlotWorldTransform(puppet: ref<NPCPuppet>, slotName: CName, out slotTransform: WorldTransform) -> Bool {
  let slotComp: ref<SlotComponent>;

  if !IsDefined(puppet) {
    return false;
  };

  slotComp = puppet.GetSlotComponent();
  if !IsDefined(slotComp) {
    return false;
  };

  return slotComp.GetSlotTransform(slotName, slotTransform);
}

// Authoritative six-lane rig mapping for Bullet Jolts.
// man_base animation indices: Head 22, Spine2 10, LeftArm 17,
// RightArm 18, LeftLeg 8, RightLeg 9.
private func SHHJM_GetExactPartAnchor(puppet: ref<NPCPuppet>, part: Int32, fallbackPos: Vector4, out anchorPos: Vector4) -> Bool {
  switch part {
    case 0:
      if SHHJM_GetSlotWorldPos(puppet, n"Head", anchorPos) { return true; };
      break;
    case 1:
      if SHHJM_GetSlotWorldPos(puppet, n"Spine2", anchorPos) { return true; };
      break;
    case 2:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftArm", anchorPos) { return true; };
      break;
    case 3:
      if SHHJM_GetSlotWorldPos(puppet, n"RightArm", anchorPos) { return true; };
      break;
    case 4:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftLeg", anchorPos) { return true; };
      break;
    case 5:
      if SHHJM_GetSlotWorldPos(puppet, n"RightLeg", anchorPos) { return true; };
      break;
  };

  anchorPos = fallbackPos;
  return false;
}

// Use the game's actual hit-reaction zone instead of guessing only from
// distance to nearby slots. This keeps head/body/left-right arm/left-right leg
// selection stable even after the corpse twists or slides.
private func SHHJM_ResolveBodyPartFromHitEvent(puppet: ref<NPCPuppet>, evt: ref<gameHitEvent>, hitPos: Vector4, out part: Int32, out anchorPos: Vector4) -> Bool {
  let shape: HitShapeData;
  let userData: ref<HitShapeUserDataBase>;

  if !IsDefined(puppet) || !IsDefined(evt) || ArraySize(evt.hitRepresentationResult.hitShapes) <= 0 {
    return false;
  };

  shape = evt.hitRepresentationResult.hitShapes[0];
  userData = shape.userData as HitShapeUserDataBase;
  if !IsDefined(userData) {
    return false;
  };

  if HitShapeUserDataBase.IsHitReactionZoneHead(userData) {
    part = 0;
  } else {
    if HitShapeUserDataBase.IsHitReactionZoneTorso(userData) {
      part = 1;
    } else {
      if HitShapeUserDataBase.IsHitReactionZoneLeftArm(userData) {
        part = 2;
      } else {
        if HitShapeUserDataBase.IsHitReactionZoneRightArm(userData) {
          part = 3;
        } else {
          if HitShapeUserDataBase.IsHitReactionZoneLeftLeg(userData) {
            part = 4;
          } else {
            if HitShapeUserDataBase.IsHitReactionZoneRightLeg(userData) {
              part = 5;
            } else {
              return false;
            };
          };
        };
      };
    };
  };

  SHHJM_GetExactPartAnchor(puppet, part, hitPos, anchorPos);
  return true;
}

// The entity's world-up vector does not reliably follow individual ragdoll
// bodies. Spine3's live slot orientation does. Its forward axis points through
// the front of the torso: negative world-Z means prone, positive means supine.
private func SHHJM_IsFaceDownByRig(puppet: ref<NPCPuppet>) -> Bool {
  let torsoTransform: WorldTransform;
  let torsoForward: Vector4;

  if SHHJM_GetSlotWorldTransform(puppet, n"Spine3", torsoTransform)
    || SHHJM_GetSlotWorldTransform(puppet, n"Spine2", torsoTransform) {
    torsoForward = WorldTransform.GetForward(torsoTransform);
    return Vector4.Dot(torsoForward, Vector4(0.0, 0.0, 1.0, 0.0)) < -0.15;
  };

  return RFC_IsFaceDown(puppet);
}

private func SHHJM_UpdateBestHit(hitPos: Vector4, partId: Int32, candidatePos: Vector4, thresholdSq: Float, out bestDistSq: Float, out bestPart: Int32, out bestPos: Vector4, out found: Bool) -> Void {
  let distSq: Float = SHHJM_DistSq(hitPos, candidatePos);
  if distSq > thresholdSq {
    return;
  };
  if !found || distSq < bestDistSq {
    bestDistSq = distSq;
    bestPart = partId;
    bestPos = candidatePos;
    found = true;
  };
}


private func SHHJM_LerpPos(a: Vector4, b: Vector4, t: Float) -> Vector4 {
  return new Vector4(
    a.X + ((b.X - a.X) * t),
    a.Y + ((b.Y - a.Y) * t),
    a.Z + ((b.Z - a.Z) * t),
    1.0
  );
}

private func SHHJM_BiasAnchorInward(puppet: ref<NPCPuppet>, part: Int32, anchorPos: Vector4) -> Vector4 {
  let targetPos: Vector4;
  let t: Float;

  switch part {
    case 0:
      if SHHJM_GetSlotWorldPos(puppet, n"Head", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.55); };
      break;
    case 1:
      if SHHJM_GetSlotWorldPos(puppet, n"Spine2", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.25); };
      break;
    case 2:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftArm", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.35); };
      break;
    case 3:
      if SHHJM_GetSlotWorldPos(puppet, n"RightArm", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.35); };
      break;
    case 4:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftLeg", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.35); };
      break;
    case 5:
      if SHHJM_GetSlotWorldPos(puppet, n"RightLeg", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.35); };
      break;
  };

  return anchorPos;
}


private func SHHJM_GetApplyOffset(part: Int32, s: ref<SHHJM_Settings>) -> Float {
  switch part {
    case 0:
      return s.headApplyOffset;
    case 1:
      return s.torsoApplyOffset;
    case 2:
      return s.leftArmApplyOffset;
    case 3:
      return s.rightArmApplyOffset;
    case 4:
      return s.leftLegApplyOffset;
    case 5:
      return s.rightLegApplyOffset;
  };
  return 0.0;
}

private func SHHJM_BiasAnchorInwardBySettings(puppet: ref<NPCPuppet>, part: Int32, anchorPos: Vector4, s: ref<SHHJM_Settings>) -> Vector4 {
  let targetPos: Vector4;
  let t: Float = ClampF(SHHJM_GetApplyOffset(part, s), 0.0, 1.0);

  switch part {
    case 0:
      if SHHJM_GetSlotWorldPos(puppet, n"Head", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 1:
      if SHHJM_GetSlotWorldPos(puppet, n"Spine2", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 2:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftArm", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 3:
      if SHHJM_GetSlotWorldPos(puppet, n"RightArm", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 4:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftLeg", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 5:
      if SHHJM_GetSlotWorldPos(puppet, n"RightLeg", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
  };

  return anchorPos;
}

private func SHHJM_ResolveBodyPart(puppet: ref<NPCPuppet>, hitPos: Vector4, out part: Int32, out anchorPos: Vector4) -> Bool {
  let found: Bool = false;
  let bestDistSq: Float = 0.0;
  let bestPart: Int32 = 99;
  let bestPos: Vector4;
  let pos: Vector4;

  if SHHJM_GetSlotWorldPos(puppet, n"Head", pos) {
    SHHJM_UpdateBestHit(hitPos, 0, pos, 0.0900, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"Neck", pos) {
    SHHJM_UpdateBestHit(hitPos, 0, pos, 0.0900, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"Spine3", pos) {
    SHHJM_UpdateBestHit(hitPos, 1, pos, 0.1600, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"Spine2", pos) {
    SHHJM_UpdateBestHit(hitPos, 1, pos, 0.1600, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"Chest", pos) {
    SHHJM_UpdateBestHit(hitPos, 1, pos, 0.1600, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"LeftShoulder", pos) {
    SHHJM_UpdateBestHit(hitPos, 2, pos, 0.1225, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftArm", pos) {
    SHHJM_UpdateBestHit(hitPos, 2, pos, 0.1225, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftForeArm", pos) {
    SHHJM_UpdateBestHit(hitPos, 2, pos, 0.1225, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftHand", pos) {
    SHHJM_UpdateBestHit(hitPos, 2, pos, 0.1225, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"RightShoulder", pos) {
    SHHJM_UpdateBestHit(hitPos, 3, pos, 0.1225, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightArm", pos) {
    SHHJM_UpdateBestHit(hitPos, 3, pos, 0.1225, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightForeArm", pos) {
    SHHJM_UpdateBestHit(hitPos, 3, pos, 0.1225, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightHand", pos) {
    SHHJM_UpdateBestHit(hitPos, 3, pos, 0.1225, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"LeftUpLeg", pos) {
    SHHJM_UpdateBestHit(hitPos, 4, pos, 0.1600, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftLeg", pos) {
    SHHJM_UpdateBestHit(hitPos, 4, pos, 0.1600, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftFoot", pos) {
    SHHJM_UpdateBestHit(hitPos, 4, pos, 0.1600, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"RightUpLeg", pos) {
    SHHJM_UpdateBestHit(hitPos, 5, pos, 0.1600, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightLeg", pos) {
    SHHJM_UpdateBestHit(hitPos, 5, pos, 0.1600, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightFoot", pos) {
    SHHJM_UpdateBestHit(hitPos, 5, pos, 0.1600, bestDistSq, bestPart, bestPos, found);
  };

  if found {
    part = bestPart;
    SHHJM_GetExactPartAnchor(puppet, bestPart, bestPos, anchorPos);
    return true;
  };

  return false;
}

private func SHHJM_GetPartEnabled(part: Int32, s: ref<SHHJM_Settings>) -> Bool {
  switch part {
    case 0:
      return s.headEnabled;
    case 1:
      return s.torsoEnabled;
    case 2:
      return s.leftArmEnabled;
    case 3:
      return s.rightArmEnabled;
    case 4:
      return s.leftLegEnabled;
    case 5:
      return s.rightLegEnabled;
  };
  return false;
}

private func SHHJM_GetForwardStrength(part: Int32, s: ref<SHHJM_Settings>) -> Float {
  switch part {
    case 0:
      return s.headForwardStrength;
    case 1:
      return s.torsoForwardStrength;
    case 2:
      return s.leftArmForwardStrength;
    case 3:
      return s.rightArmForwardStrength;
    case 4:
      return s.leftLegForwardStrength;
    case 5:
      return s.rightLegForwardStrength;
  };
  return 0.0;
}

private func SHHJM_GetVerticalStrength(part: Int32, s: ref<SHHJM_Settings>) -> Float {
  switch part {
    case 0:
      return s.headUpStrength + (0.0 - s.headDownStrength);
    case 1:
      return s.torsoUpStrength + (0.0 - s.torsoDownStrength);
    case 2:
      return s.leftArmUpStrength + (0.0 - s.leftArmDownStrength);
    case 3:
      return s.rightArmUpStrength + (0.0 - s.rightArmDownStrength);
    case 4:
      return s.leftLegUpStrength + (0.0 - s.leftLegDownStrength);
    case 5:
      return s.rightLegUpStrength + (0.0 - s.rightLegDownStrength);
  };
  return 0.0;
}

private func SHHJM_GetRadius(part: Int32, s: ref<SHHJM_Settings>) -> Float {
  let scale: Float = MaxF(0.0, RFC.Cfg().bulletJoltRadiusScale);
  switch part {
    case 0:
      return ClampF(ClampF(s.headRadius, 0.005, 0.030) * scale, 0.005, 0.150);
    case 1:
      return MaxF(0.005, s.torsoRadius * scale);
    case 2:
      return ClampF(ClampF(s.leftArmRadius, 0.005, 0.030) * scale, 0.005, 0.150);
    case 3:
      return ClampF(ClampF(s.rightArmRadius, 0.005, 0.030) * scale, 0.005, 0.150);
    case 4:
      return ClampF(ClampF(s.leftLegRadius, 0.005, 0.030) * scale, 0.005, 0.150);
    case 5:
      return ClampF(ClampF(s.rightLegRadius, 0.005, 0.030) * scale, 0.005, 0.150);
  };
  return 0.0100;
}

private func SHHJM_GetHitDelay(part: Int32, s: ref<SHHJM_Settings>) -> Float {
  switch part {
    case 0:
      return s.headHitDelaySec;
    case 1:
      return s.torsoHitDelaySec;
    case 2:
      return s.leftArmHitDelaySec;
    case 3:
      return s.rightArmHitDelaySec;
    case 4:
      return s.leftLegHitDelaySec;
    case 5:
      return s.rightLegHitDelaySec;
  };
  return 0.01;
}

private func SHHJM_GetDeathDelay(part: Int32, s: ref<SHHJM_Settings>) -> Float {
  return 0.0;
}


private func SHHJM_BuildImpulse(puppet: ref<NPCPuppet>, srcPos: Vector4, anchorPos: Vector4, part: Int32, s: ref<SHHJM_Settings>) -> Vector4 {
  let dir: Vector4 = SHHJM_NormalizeSafe(anchorPos - srcPos);
  let strengthScale: Float = MaxF(0.0, RFC.Cfg().bulletJoltStrengthScale);
  let fwd: Float = SHHJM_GetForwardStrength(part, s) * strengthScale;
  let vertical: Float = SHHJM_GetVerticalStrength(part, s) * strengthScale;

  // Up/down are body-relative for grounded Bullet Jolts. A prone corpse has
  // the opposite torso orientation from a supine corpse, so swap the vertical
  // sign at the moment the delayed impulse actually fires.
  if SHHJM_IsFaceDownByRig(puppet) {
    vertical = 0.0 - vertical;
  };

  return new Vector4(dir.X * fwd, dir.Y * fwd, vertical, 1.0);
}

@addMethod(NPCPuppet)
protected cb func OnSHHJM_ApplyImpulseEvt(evt: ref<SHHJM_ApplyImpulseEvt>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let s: ref<SHHJM_Settings>;
  let liveAnchor: Vector4;
  if c.vanillaMode || RFC_TimeDilationBlocksImpulses(this, c) || !c.bulletJoltsEnabled {
    return true;
  };
  if !IsDefined(evt) {
    return true;
  };
  if RFC_IsVehicleContext(this) {
    return true;
  };
  s = SPLATSettingsRuntime.Jolts();
  if !SHHJM_GetPartEnabled(evt.part, s) {
    return true;
  };

  // Delayed jolts must follow the live ragdoll body, not the body position
  // captured when the bullet first landed. Re-resolve the selected part and
  // rebuild up/down after the corpse has reached its current face-up/down pose.
  SHHJM_GetExactPartAnchor(this, evt.part, evt.pos, liveAnchor);
  liveAnchor = SHHJM_BiasAnchorInwardBySettings(this, evt.part, liveAnchor, s);
  evt.pos = liveAnchor;
  evt.imp = SHHJM_BuildImpulse(this, evt.srcPos, liveAnchor, evt.part, s);
  evt.radius = SHHJM_GetRadius(evt.part, s);

  // Safety refresh. This is SPLAT's custom lane, not the vanilla impulse lane.
  // If death cut/cleanup timing left the corpse between states, wake ragdoll
  // before applying the custom body-part jolt.
  if this.IsDead() && !this.IsRagdolling() {
    this.QueueEvent(CreateForceRagdollEvent(n"SHHJM_CustomJolt"));
  };

  this.QueueEvent(CreateRagdollApplyImpulseEvent(evt.pos, evt.imp, evt.radius));
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnSHHJM_ForceRagdollEvt(evt: ref<SHHJM_ForceRagdollEvt>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  if c.vanillaMode || RFC_TimeDilationBlocksImpulses(this, c) {
    return true;
  };
  if RFC_IsVehicleContext(this) {
    return true;
  };
  if !ScriptedPuppet.CanRagdoll(this) {
    return true;
  };
  this.QueueEvent(CreateForceRagdollEvent(n"SHHJM_Hit"));
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnSHHJM_OnDeathApplyEvt(evt: ref<SHHJM_OnDeathApplyEvt>) -> Bool {
  return true;
}
