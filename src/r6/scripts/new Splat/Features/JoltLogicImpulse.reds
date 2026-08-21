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

// Preserve the torso model that previously worked in SPLAT: resolve the broad
// torso part, bias the event toward the live central spine, wake the corpse via
// SPLAT's own ragdoll event, then deliver one delayed ApplyImpulse event. The
// newer bone-index/wide-contact experiment bypassed this callback chain and its
// torso-only forced ground wait could expire without ever dispatching.
private func SHHJM_QueueWorkingTorsoModel(puppet: ref<NPCPuppet>, targetWasAlreadyDead: Bool, srcPos: Vector4, anchorPos: Vector4, fireDelay: Float, s: ref<SHHJM_Settings>) -> Void {
  let applyAnchor: Vector4;
  let impulse: Vector4;
  let radius: Float;

  applyAnchor = SHHJM_BiasAnchorInwardBySettings(puppet, 1, anchorPos, s);
  impulse = SHHJM_BuildImpulse(puppet, srcPos, applyAnchor, 1, s);
  radius = SHHJM_GetRadius(1, s);

  LogChannel(
    n"DEBUG",
    s"[SPLAT_JOLT_TRACE] TORSO_GROUND_NATIVE_DISPATCH anchor=\(applyAnchor) impulse=\(impulse) radius=\(radius) dead=\(puppet.IsDead()) ragdoll=\(puppet.IsRagdolling()) delay=\(fireDelay)"
  );

  if puppet.IsDead() && !puppet.IsRagdolling() {
    if ScriptedPuppet.CanRagdoll(puppet) {
      puppet.QueueEvent(CreateForceRagdollEvent(n"SHHJM_CustomJolt"));
    };
    SHHJM_Sched(
      puppet,
      CreateRagdollApplyImpulseEvent(applyAnchor, impulse, radius),
      MaxF(0.012, fireDelay)
    );
  } else if fireDelay <= 0.001 {
    puppet.QueueEvent(
      CreateRagdollApplyImpulseEvent(applyAnchor, impulse, radius)
    );
  } else {
    SHHJM_Sched(
      puppet,
      CreateRagdollApplyImpulseEvent(applyAnchor, impulse, radius),
      fireDelay
    );
  };
}

private func SHHJM_QueueJolt(puppet: ref<NPCPuppet>, part: Int32, boneIndex: Int32, targetWasAlreadyDead: Bool, srcPos: Vector4, anchorPos: Vector4, fireDelay: Float, s: ref<SHHJM_Settings>) -> Void {
  let waitEvt: ref<SHHJM_WaitForGroundEvt>;
  let applyAnchor: Vector4;
  let impulse: Vector4;
  let radius: Float;
  let nowT: Float;
  let effectiveDelay: Float;

  let c: RFCConfig = RFC.Cfg();
  if part == 1 {
    LogChannel(
      n"DEBUG",
      s"[SPLAT_JOLT_TRACE] TORSO_QUEUE_ENTRY definedPuppet=\(IsDefined(puppet)) definedSettings=\(IsDefined(s)) vanilla=\(c.vanillaMode) joltsEnabled=\(c.bulletJoltsEnabled) bone=\(boneIndex)"
    );
  };
  if !IsDefined(puppet) || !IsDefined(s) {
    return;
  };
  if c.vanillaMode || RFC_TimeDilationBlocksImpulses(puppet, c) || !c.bulletJoltsEnabled {
    return;
  };

  if part == 1 {
    applyAnchor = SHHJM_BiasAnchorInwardBySettings(puppet, part, anchorPos, s);
  } else {
    applyAnchor = SHHJM_BoneLocalApplyPoint(srcPos, anchorPos, part, s);
  };

  // Ground waiting is controlled only by the existing menu setting. Do not
  // force it for torso: a settled horizontal ragdoll can remain false in the
  // navigation ground test, which previously swallowed every chest/back jolt.
  if puppet.IsDead()
    && c.bulletJoltWaitForGround
    && !c.bulletJoltAllowAirborne
    && !SHHJM_IsOnGround(puppet) {
    nowT = SHHJM_Now(puppet);
    waitEvt = new SHHJM_WaitForGroundEvt();
    waitEvt.srcPos = srcPos;
    waitEvt.anchorPos = anchorPos;
    waitEvt.part = part;
    waitEvt.boneIndex = boneIndex;
    waitEvt.targetWasAlreadyDead = targetWasAlreadyDead;
    waitEvt.fireDelay = MaxF(0.001, fireDelay);
    waitEvt.armedAt = nowT;
    waitEvt.expireAt = nowT + MaxF(0.10, SHHJM_GetGroundWaitMax(part, s));
    SHHJM_Sched(puppet, waitEvt, 0.01);
    return;
  };

  effectiveDelay = fireDelay;

  // Torso must use the same native impulse-event lane that is already working
  // for head, arms, and legs. The previous torso-only intermediate event was
  // successfully queued by OnHit but could disappear before the engine's
  // RagdollApplyImpulse event reached the active corpse. Keep the broad torso
  // anchor and configured torso radius, but dispatch the native event directly.
  if part == 1 {
    impulse = SHHJM_BuildImpulse(puppet, srcPos, applyAnchor, part, s);
    radius = SHHJM_GetRadius(part, s);
    LogChannel(
      n"DEBUG",
      s"[SPLAT_JOLT_TRACE] TORSO_NATIVE_DISPATCH anchor=\(applyAnchor) impulse=\(impulse) radius=\(radius) dead=\(puppet.IsDead()) ragdoll=\(puppet.IsRagdolling()) delay=\(effectiveDelay)"
    );

    if puppet.IsDead() && !puppet.IsRagdolling() {
      if ScriptedPuppet.CanRagdoll(puppet) {
        puppet.QueueEvent(CreateForceRagdollEvent(n"SHHJM_CustomJolt"));
      };
      SHHJM_Sched(
        puppet,
        CreateRagdollApplyImpulseEvent(applyAnchor, impulse, radius),
        MaxF(0.012, effectiveDelay)
      );
    } else if effectiveDelay <= 0.001 {
      puppet.QueueEvent(
        CreateRagdollApplyImpulseEvent(applyAnchor, impulse, radius)
      );
    } else {
      SHHJM_Sched(
        puppet,
        CreateRagdollApplyImpulseEvent(applyAnchor, impulse, radius),
        effectiveDelay
      );
    };
    return;
  };

  // Send the real engine impulse event directly. The intermediate
  // SHHJM_ApplyImpulseEvt callback added a second set of runtime gates after
  // OnHit had already approved the jolt, allowing a valid hit to disappear
  // before CreateRagdollApplyImpulseEvent ever reached the puppet.
  impulse = SHHJM_BuildImpulse(puppet, srcPos, applyAnchor, part, s);
  radius = SHHJM_GetBoneRadius(part, s);
  if part == 1 {
    LogChannel(
      n"DEBUG",
      s"[SPLAT_JOLT_TRACE] TORSO_EVENT anchor=\(applyAnchor) impulse=\(impulse) radius=\(radius) dead=\(puppet.IsDead()) ragdoll=\(puppet.IsRagdolling()) fireDelay=\(fireDelay)"
    );
  };
  // Preserve active death animations on newly lethal hits. Existing
  // dead/ragdoll targets are the Bullet Jolt lane and may be refreshed.
  if RFC_AnyDeathAnimationOwnsLifecycle(puppet)
    && !puppet.IsRagdolling()
    && !targetWasAlreadyDead {
    return;
  };

  if puppet.IsDead() && !puppet.IsRagdolling() {
    if ScriptedPuppet.CanRagdoll(puppet) {
      puppet.QueueEvent(CreateForceRagdollEvent(n"SHHJM_CustomJolt"));
    };
    SHHJM_Sched(
      puppet,
      CreateRagdollApplyImpulseEvent(applyAnchor, impulse, radius),
      MaxF(0.012, effectiveDelay)
    );
  } else if effectiveDelay <= 0.001 {
    puppet.QueueEvent(
      CreateRagdollApplyImpulseEvent(applyAnchor, impulse, radius)
    );
  } else {
    SHHJM_Sched(
      puppet,
      CreateRagdollApplyImpulseEvent(applyAnchor, impulse, radius),
      effectiveDelay
    );
  };
}



@addMethod(NPCPuppet)
protected cb func OnSHHJM_WaitForGroundEvt(evt: ref<SHHJM_WaitForGroundEvt>) -> Bool {
  let c: RFCConfig = RFC.Cfg();
  let s: ref<SHHJM_Settings>;
  let retryEvt: ref<SHHJM_WaitForGroundEvt>;
  let groundedAnchor: Vector4;
  let impulse: Vector4;
  let radius: Float;
  let groundFireDelay: Float;

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
    if evt.part == 1 {
      SHHJM_QueueWorkingTorsoModel(
        this,
        evt.targetWasAlreadyDead,
        evt.srcPos,
        evt.anchorPos,
        evt.fireDelay,
        s
      );
      return true;
    };

    if !SHHJM_GetLiveJoltAnchor(this, evt.part, evt.boneIndex, evt.anchorPos, groundedAnchor) {
      SHHJM_GetExactPartAnchor(this, evt.part, evt.anchorPos, groundedAnchor);
    };
    groundedAnchor = SHHJM_BoneLocalApplyPoint(evt.srcPos, groundedAnchor, evt.part, s);

    impulse = SHHJM_BuildImpulse(this, evt.srcPos, groundedAnchor, evt.part, s);
    radius = SHHJM_GetBoneRadius(evt.part, s);
    groundFireDelay = evt.fireDelay;

    if this.IsDead() && !this.IsRagdolling() {
      if ScriptedPuppet.CanRagdoll(this) {
        this.QueueEvent(CreateForceRagdollEvent(n"SHHJM_CustomJolt"));
      };
      SHHJM_Sched(
        this,
        CreateRagdollApplyImpulseEvent(groundedAnchor, impulse, radius),
        MaxF(0.012, groundFireDelay)
      );
    } else if groundFireDelay <= 0.001 {
      this.QueueEvent(
        CreateRagdollApplyImpulseEvent(groundedAnchor, impulse, radius)
      );
    } else {
      SHHJM_Sched(
        this,
        CreateRagdollApplyImpulseEvent(groundedAnchor, impulse, radius),
        groundFireDelay
      );
    };
    return true;
  };

  if SHHJM_Now(this) >= evt.expireAt {
    return true;
  };

  retryEvt = new SHHJM_WaitForGroundEvt();
  retryEvt.srcPos = evt.srcPos;
  retryEvt.anchorPos = evt.anchorPos;
  retryEvt.part = evt.part;
  retryEvt.boneIndex = evt.boneIndex;
  retryEvt.targetWasAlreadyDead = evt.targetWasAlreadyDead;
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

// Exact ragdoll ChildAnimIndex mapping from the base human rigs. The engine's
// REDscript ragdoll impulse event has no body-index field, so the index is used
// to preserve the exact live bone anchor through SPLAT's delayed jolt pipeline.
private func SHHJM_GetBoneSlotName(boneIndex: Int32) -> CName {
  switch boneIndex {
    case 4: return n"Spine";
    case 5: return n"LeftUpLeg";
    case 6: return n"RightUpLeg";
    case 7: return n"Spine1";
    case 8: return n"LeftLeg";
    case 9: return n"RightLeg";
    case 10: return n"Spine2";
    case 11: return n"LeftFoot";
    case 12: return n"RightFoot";
    case 13: return n"Spine3";
    case 17: return n"LeftArm";
    case 18: return n"RightArm";
    case 19: return n"Neck1";
    case 20: return n"LeftForeArm";
    case 21: return n"RightForeArm";
    case 22: return n"Head";
    case 23: return n"LeftHand";
    case 24: return n"RightHand";
    case 41: return n"LeftToeBase";
    case 42: return n"RightToeBase";
    case 55: return n"LeftHandMiddle2";
    case 60: return n"RightHandMiddle2";
  };
  return n"";
}

private func SHHJM_GetPartForBoneIndex(boneIndex: Int32) -> Int32 {
  switch boneIndex {
    case 19:
    case 22:
      return 0;
    case 4:
    case 7:
    case 10:
    case 13:
      return 1;
    case 17:
    case 20:
    case 23:
    case 55:
      return 2;
    case 18:
    case 21:
    case 24:
    case 60:
      return 3;
    case 5:
    case 8:
    case 11:
    case 41:
      return 4;
    case 6:
    case 9:
    case 12:
    case 42:
      return 5;
  };
  return 99;
}

private func SHHJM_DefaultBoneIndexForPart(part: Int32) -> Int32 {
  switch part {
    case 0: return 22;
    case 1: return 10;
    case 2: return 17;
    case 3: return 18;
    case 4: return 8;
    case 5: return 9;
  };
  return -1;
}

private func SHHJM_GetExactBoneAnchor(puppet: ref<NPCPuppet>, boneIndex: Int32, fallbackPos: Vector4, out anchorPos: Vector4) -> Bool {
  let slotName: CName = SHHJM_GetBoneSlotName(boneIndex);

  if !Equals(slotName, n"") && SHHJM_GetSlotWorldPos(puppet, slotName, anchorPos) {
    return true;
  };

  // Some human rigs expose the neck proxy as Neck instead of Neck1.
  if boneIndex == 19 && SHHJM_GetSlotWorldPos(puppet, n"Neck", anchorPos) {
    return true;
  };

  anchorPos = fallbackPos;
  return false;
}

private func SHHJM_UpdateTorsoColliderCandidate(slotTransform: WorldTransform, hitPos: Vector4, localOffset: Vector4, out bestPos: Vector4, out bestDistSq: Float) -> Void {
  let candidatePos: Vector4 = WorldPosition.ToVector4(
    WorldTransform.TransformPoint(slotTransform, localOffset)
  );
  let distSq: Float = SHHJM_DistSq(hitPos, candidatePos);

  if distSq < bestDistSq {
    bestDistSq = distSq;
    bestPos = candidatePos;
  };
}

// Spine ragdoll capsules are offset differently in the male and female base
// rigs. Slot position alone addresses the animation bone, not necessarily the
// physics body. Evaluate both rigs' known local capsule centers and select the
// one nearest the real bullet contact. This keeps front-chest and back hits on
// the same torso body without broadening the impulse into the limbs or head.
private func SHHJM_GetTorsoColliderAnchor(puppet: ref<NPCPuppet>, boneIndex: Int32, hitPos: Vector4, out anchorPos: Vector4) -> Bool {
  let slotName: CName = SHHJM_GetBoneSlotName(boneIndex);
  let slotTransform: WorldTransform;
  let bestDistSq: Float;

  if Equals(slotName, n"") || !SHHJM_GetSlotWorldTransform(puppet, slotName, slotTransform) {
    anchorPos = hitPos;
    return false;
  };

  // Zero offset covers the female Spine/Spine2/Spine3 bodies and remains a
  // safe candidate for custom rigs whose collider is centered on the bone.
  anchorPos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
  bestDistSq = SHHJM_DistSq(hitPos, anchorPos);

  switch boneIndex {
    case 4:
      SHHJM_UpdateTorsoColliderCandidate(slotTransform, hitPos, new Vector4(0.140, 0.000, 0.000, 0.0), anchorPos, bestDistSq);
      break;
    case 7:
      // Male Spine1 is +0.09 m; female Spine1 is -0.03 m.
      SHHJM_UpdateTorsoColliderCandidate(slotTransform, hitPos, new Vector4(0.090, 0.000, 0.000, 0.0), anchorPos, bestDistSq);
      SHHJM_UpdateTorsoColliderCandidate(slotTransform, hitPos, new Vector4(-0.030, 0.000, 0.000, 0.0), anchorPos, bestDistSq);
      break;
    case 10:
      SHHJM_UpdateTorsoColliderCandidate(slotTransform, hitPos, new Vector4(0.160, 0.020, 0.000, 0.0), anchorPos, bestDistSq);
      break;
    case 13:
      SHHJM_UpdateTorsoColliderCandidate(slotTransform, hitPos, new Vector4(0.030, 0.020, 0.000, 0.0), anchorPos, bestDistSq);
      break;
  };

  return true;
}

private func SHHJM_GetLiveJoltAnchor(puppet: ref<NPCPuppet>, part: Int32, boneIndex: Int32, referencePos: Vector4, out anchorPos: Vector4) -> Bool {
  if part == 1 {
    return SHHJM_GetTorsoColliderAnchor(puppet, boneIndex, referencePos, anchorPos);
  };
  return SHHJM_GetExactBoneAnchor(puppet, boneIndex, referencePos, anchorPos);
}

private func SHHJM_UpdateBestBoneCandidate(puppet: ref<NPCPuppet>, hitPos: Vector4, partFilter: Int32, candidateIndex: Int32, out bestDistSq: Float, out bestBoneIndex: Int32, out bestPos: Vector4, out found: Bool) -> Void {
  let candidatePos: Vector4;
  let distSq: Float;

  if SHHJM_GetPartForBoneIndex(candidateIndex) != partFilter {
    return;
  };
  if partFilter == 1 {
    if !SHHJM_GetTorsoColliderAnchor(puppet, candidateIndex, hitPos, candidatePos) {
      return;
    };
  } else {
    if !SHHJM_GetExactBoneAnchor(puppet, candidateIndex, hitPos, candidatePos) {
      return;
    };
  };

  distSq = SHHJM_DistSq(hitPos, candidatePos);
  if !found || distSq < bestDistSq {
    bestDistSq = distSq;
    bestBoneIndex = candidateIndex;
    bestPos = candidatePos;
    found = true;
  };
}

private func SHHJM_ResolveExactBoneIndex(puppet: ref<NPCPuppet>, hitPos: Vector4, partFilter: Int32, out boneIndex: Int32, out anchorPos: Vector4) -> Bool {
  let found: Bool = false;
  let bestDistSq: Float = 0.0;
  let bestBoneIndex: Int32 = -1;
  let bestPos: Vector4;

  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 4, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 5, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 6, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 7, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 8, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 9, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 10, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 11, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 12, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 13, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 17, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 18, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 19, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 20, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 21, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 22, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 23, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 24, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 41, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 42, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 55, bestDistSq, bestBoneIndex, bestPos, found);
  SHHJM_UpdateBestBoneCandidate(puppet, hitPos, partFilter, 60, bestDistSq, bestBoneIndex, bestPos, found);

  if found {
    boneIndex = bestBoneIndex;
    anchorPos = bestPos;
    return true;
  };

  boneIndex = SHHJM_DefaultBoneIndexForPart(partFilter);
  if partFilter == 1 {
    return SHHJM_GetTorsoColliderAnchor(puppet, boneIndex, hitPos, anchorPos);
  };
  if !SHHJM_GetExactBoneAnchor(puppet, boneIndex, hitPos, anchorPos) {
    return false;
  };
  return true;
}

// Use the game's actual hit-reaction zone instead of guessing only from
// distance to nearby slots. This keeps head/body/left-right arm/left-right leg
// selection stable even after the corpse twists or slides.
private func SHHJM_ResolveBodyPartFromHitEvent(puppet: ref<NPCPuppet>, evt: ref<gameHitEvent>, hitPos: Vector4, out part: Int32, out anchorPos: Vector4) -> Bool {
  let shape: HitShapeData;
  let userData: ref<HitShapeUserDataBase>;
  let recognized: Bool;
  let i: Int32 = 0;

  if !IsDefined(puppet) || !IsDefined(evt) || ArraySize(evt.hitRepresentationResult.hitShapes) <= 0 {
    return false;
  };

  // Armor and clothing can occupy hitShapes[0] without carrying a reaction
  // zone. Keep the engine's shape order, but continue until a real anatomical
  // zone is found instead of dropping otherwise valid chest hits.
  while i < ArraySize(evt.hitRepresentationResult.hitShapes) {
    recognized = false;
    shape = evt.hitRepresentationResult.hitShapes[i];
    userData = shape.userData as HitShapeUserDataBase;

    if IsDefined(userData) {
      if HitShapeUserDataBase.IsHitReactionZoneHead(userData) {
        part = 0;
        recognized = true;
      } else {
        if HitShapeUserDataBase.IsHitReactionZoneTorso(userData) {
          part = 1;
          recognized = true;
        } else {
          if HitShapeUserDataBase.IsHitReactionZoneLeftArm(userData) {
            part = 2;
            recognized = true;
          } else {
            if HitShapeUserDataBase.IsHitReactionZoneRightArm(userData) {
              part = 3;
              recognized = true;
            } else {
              if HitShapeUserDataBase.IsHitReactionZoneLeftLeg(userData) {
                part = 4;
                recognized = true;
              } else {
                if HitShapeUserDataBase.IsHitReactionZoneRightLeg(userData) {
                  part = 5;
                  recognized = true;
                };
              };
            };
          };
        };
      };
    };

    // Settled corpse hits do not always retain an EHitReactionZone torso tag,
    // but Cyberpunk still classifies the same central collider as the BODY
    // dismemberment part. Use that fallback after explicit limb/head checks.
    if IsDefined(userData)
      && !recognized
      && Equals(
        HitShapeUserDataBase.GetDismembermentBodyPart(userData),
        gameDismBodyPart.BODY
      ) {
      part = 1;
      recognized = true;
    };

    if recognized {
      if part == 1 {
        anchorPos = hitPos;
      } else {
        SHHJM_GetExactPartAnchor(puppet, part, hitPos, anchorPos);
      };
      LogChannel(
        n"DEBUG",
        s"[SPLAT_JOLT_TRACE] SHAPE_RESOLVE shapeIndex=\(i) part=\(part) hit=\(hitPos) anchor=\(anchorPos)"
      );
      return true;
    };

    i += 1;
  };

  return false;
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
    LogChannel(
      n"DEBUG",
      s"[SPLAT_JOLT_TRACE] SPATIAL_RESOLVE part=\(part) hit=\(hitPos) anchor=\(anchorPos)"
    );
    return true;
  };

  LogChannel(n"DEBUG", s"[SPLAT_JOLT_TRACE] RESOLVE_FAILED hit=\(hitPos)");
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
      // Torso has its own explicit radius slider. Do not collapse it through
      // the mode-wide local-bone radius scale: that scale can be zero while
      // the torso slider is nonzero, which reduced a requested 10.0 m event
      // to the ineffective 0.005 m floor. This restores the earlier working
      // torso behavior where the torso radius is applied directly.
      return ClampF(s.torsoRadius, 0.005, 10.000);
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

private func SHHJM_GetBoneRadius(part: Int32, s: ref<SHHJM_Settings>) -> Float {
  // The engine event is position/radius based, not a direct rigid-body-index
  // call. The previous 0.005-0.025 m radius could miss the ragdoll collider
  // completely even though the correct live bone anchor was selected. Keep
  // the exact bone anchor, but guarantee a collider-contacting local radius.
  if part == 1 {
    // Chest/back is a chain of four central ragdoll bodies rather than one
    // small distal body. Give it its own wider sphere and honor the full torso
    // slider range; the old shared 0.20 m ceiling made larger menu values inert.
    return ClampF(SHHJM_GetRadius(part, s), 0.100, 10.000);
  };
  return ClampF(SHHJM_GetRadius(part, s), 0.120, 0.200);
}

private func SHHJM_BoneLocalApplyPoint(srcPos: Vector4, boneAnchor: Vector4, part: Int32, s: ref<SHHJM_Settings>) -> Vector4 {
  let towardSource: Vector4 = SHHJM_NormalizeSafe(srcPos - boneAnchor);
  let exactness: Float = ClampF(SHHJM_GetApplyOffset(part, s), 0.0, 1.0);
  let shift: Float = (1.0 - exactness) * 0.010;

  // Apply Offset still has a visible effect, but can move the event no farther
  // than one centimeter from the selected bone.
  return new Vector4(
    boneAnchor.X + (towardSource.X * shift),
    boneAnchor.Y + (towardSource.Y * shift),
    boneAnchor.Z + (towardSource.Z * shift),
    1.0
  );
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

private func SHHJM_GetLiveStrengthScale() -> Float {
  let c: RFCConfig = RFC.Cfg();
  let menu: ref<RFCModSettings>;
  let mode: Int32;
  let scale: Float = MaxF(0.0, c.bulletJoltStrengthScale);

  if scale > 0.0 {
    return scale;
  };

  // Recover the selected mode's saved value directly when the flattened
  // RFCConfig arrives with an uninitialized zero. This keeps the existing mode
  // scale sliders functional without changing the settings/menu backend.
  menu = SPLATSettingsRuntime.Menu();
  if IsDefined(menu) {
    mode = EnumInt(menu.splatPresetMode);
    if mode == EnumInt(RFCSplatPresetMode.RealismPlus) {
      scale = MaxF(0.0, menu.realismPlusMode_bulletJoltStrengthScale);
    } else if mode == EnumInt(RFCSplatPresetMode.DirtyHarry) {
      scale = MaxF(0.0, menu.dirty_bulletJoltStrengthScale);
    } else if mode == EnumInt(RFCSplatPresetMode.Arnold) {
      scale = MaxF(0.0, menu.arnold_bulletJoltStrengthScale);
    } else {
      scale = MaxF(0.0, menu.realism_bulletJoltStrengthScale);
    };
  };

  // Bullet Jolts have an explicit Enable switch. A missing scale must not
  // silently erase every per-body strength after that switch is enabled.
  return scale > 0.0 ? scale : 1.0;
}


private func SHHJM_BuildImpulse(puppet: ref<NPCPuppet>, srcPos: Vector4, anchorPos: Vector4, part: Int32, s: ref<SHHJM_Settings>) -> Vector4 {
  let dir: Vector4 = SHHJM_NormalizeSafe(anchorPos - srcPos);
  let rawForward: Float = SHHJM_GetForwardStrength(part, s);
  let rawVertical: Float = SHHJM_GetVerticalStrength(part, s);
  let strengthScale: Float = SHHJM_GetLiveStrengthScale();
  let fwd: Float = rawForward * strengthScale;
  let vertical: Float = rawVertical * strengthScale;

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
  // A jolt captured against an already dead/ragdoll target must not be erased
  // by stale death-animation ownership. Newly lethal hits keep the protection
  // so an active death animation is not interrupted unexpectedly.
  if RFC_AnyDeathAnimationOwnsLifecycle(this)
    && !this.IsRagdolling()
    && !evt.targetWasAlreadyDead {
    return true;
  };
  s = SPLATSettingsRuntime.Jolts();
  if !SHHJM_GetPartEnabled(evt.part, s) {
    return true;
  };

  // Restore the known-working broad torso anchor. Distal parts retain their
  // exact ChildAnimIndex targeting.
  if evt.part == 1 {
    SHHJM_GetExactPartAnchor(this, evt.part, evt.pos, liveAnchor);
    liveAnchor = SHHJM_BiasAnchorInwardBySettings(this, evt.part, liveAnchor, s);
  } else {
    if !SHHJM_GetLiveJoltAnchor(this, evt.part, evt.boneIndex, evt.pos, liveAnchor) {
      SHHJM_GetExactPartAnchor(this, evt.part, evt.pos, liveAnchor);
    };
    liveAnchor = SHHJM_BoneLocalApplyPoint(evt.srcPos, liveAnchor, evt.part, s);
  };
  evt.pos = liveAnchor;
  evt.imp = SHHJM_BuildImpulse(this, evt.srcPos, liveAnchor, evt.part, s);
  evt.radius = evt.part == 1 ? SHHJM_GetRadius(evt.part, s) : SHHJM_GetBoneRadius(evt.part, s);

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
  if RFC_AnyDeathAnimationOwnsLifecycle(this)
    && (!IsDefined(evt) || !evt.allowWhileDeathAnimationOwned) {
    return true;
  };
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
