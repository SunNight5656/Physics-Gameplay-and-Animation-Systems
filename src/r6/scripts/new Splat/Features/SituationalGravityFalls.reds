module RealisticPush

// Per-body-part Situational Gravity Falls.
//
// This is the Situational counterpart to BodyGravityFalls.reds. The old
// Situational routes used one-shot downward RFC_Burst impulses. Each enabled
// body-part override now owns a frame-integrated constant downward force at the
// live rig slot for that body part. Horizontal/forward, slam, anchor, tumble,
// anti-tuck, shin and foot behaviors remain separate impulses.

public class SGF_TickEvent extends Event {
  public let part: Int32; // 0 Head, 1 Chest, 2 Pelvis, 3 Left Knee, 4 Right Knee
  public let generation: Int32;
  public let downPerSec: Float;
  public let radius: Float;
  public let startDelay: Float;
  public let duration: Float;
  public let updateInterval: Float;
  public let maxDeltaTime: Float;
  public let armedSimTime: Float;
}

@addField(NPCPuppet) private let sgf_headGeneration: Int32;
@addField(NPCPuppet) private let sgf_chestGeneration: Int32;
@addField(NPCPuppet) private let sgf_pelvisGeneration: Int32;
@addField(NPCPuppet) private let sgf_leftKneeGeneration: Int32;
@addField(NPCPuppet) private let sgf_rightKneeGeneration: Int32;

@addField(NPCPuppet) private let sgf_headStartSimTime: Float;
@addField(NPCPuppet) private let sgf_chestStartSimTime: Float;
@addField(NPCPuppet) private let sgf_pelvisStartSimTime: Float;
@addField(NPCPuppet) private let sgf_leftKneeStartSimTime: Float;
@addField(NPCPuppet) private let sgf_rightKneeStartSimTime: Float;

@addField(NPCPuppet) private let sgf_headLastSimTime: Float;
@addField(NPCPuppet) private let sgf_chestLastSimTime: Float;
@addField(NPCPuppet) private let sgf_pelvisLastSimTime: Float;
@addField(NPCPuppet) private let sgf_leftKneeLastSimTime: Float;
@addField(NPCPuppet) private let sgf_rightKneeLastSimTime: Float;

private func SGF_Pos(value: Float) -> Float {
  return value < 0.0 ? -value : value;
}

private func SGF_Clamp(value: Float, minimum: Float, maximum: Float) -> Float {
  if value < minimum { return minimum; }
  if value > maximum { return maximum; }
  return value;
}

private func SGF_GetGeneration(puppet: wref<NPCPuppet>, part: Int32) -> Int32 {
  if part == 0 { return puppet.sgf_headGeneration; }
  if part == 1 { return puppet.sgf_chestGeneration; }
  if part == 2 { return puppet.sgf_pelvisGeneration; }
  if part == 3 { return puppet.sgf_leftKneeGeneration; }
  return puppet.sgf_rightKneeGeneration;
}

private func SGF_NextGeneration(puppet: wref<NPCPuppet>, part: Int32) -> Int32 {
  if part == 0 {
    puppet.sgf_headGeneration += 1;
    return puppet.sgf_headGeneration;
  }
  if part == 1 {
    puppet.sgf_chestGeneration += 1;
    return puppet.sgf_chestGeneration;
  }
  if part == 2 {
    puppet.sgf_pelvisGeneration += 1;
    return puppet.sgf_pelvisGeneration;
  }
  if part == 3 {
    puppet.sgf_leftKneeGeneration += 1;
    return puppet.sgf_leftKneeGeneration;
  }
  puppet.sgf_rightKneeGeneration += 1;
  return puppet.sgf_rightKneeGeneration;
}

private func SGF_SetTimes(puppet: wref<NPCPuppet>, part: Int32, startTime: Float) -> Void {
  if part == 0 {
    puppet.sgf_headStartSimTime = startTime;
    puppet.sgf_headLastSimTime = startTime;
    return;
  }
  if part == 1 {
    puppet.sgf_chestStartSimTime = startTime;
    puppet.sgf_chestLastSimTime = startTime;
    return;
  }
  if part == 2 {
    puppet.sgf_pelvisStartSimTime = startTime;
    puppet.sgf_pelvisLastSimTime = startTime;
    return;
  }
  if part == 3 {
    puppet.sgf_leftKneeStartSimTime = startTime;
    puppet.sgf_leftKneeLastSimTime = startTime;
    return;
  }
  puppet.sgf_rightKneeStartSimTime = startTime;
  puppet.sgf_rightKneeLastSimTime = startTime;
}

private func SGF_GetStartTime(puppet: wref<NPCPuppet>, part: Int32) -> Float {
  if part == 0 { return puppet.sgf_headStartSimTime; }
  if part == 1 { return puppet.sgf_chestStartSimTime; }
  if part == 2 { return puppet.sgf_pelvisStartSimTime; }
  if part == 3 { return puppet.sgf_leftKneeStartSimTime; }
  return puppet.sgf_rightKneeStartSimTime;
}

private func SGF_GetLastTime(puppet: wref<NPCPuppet>, part: Int32) -> Float {
  if part == 0 { return puppet.sgf_headLastSimTime; }
  if part == 1 { return puppet.sgf_chestLastSimTime; }
  if part == 2 { return puppet.sgf_pelvisLastSimTime; }
  if part == 3 { return puppet.sgf_leftKneeLastSimTime; }
  return puppet.sgf_rightKneeLastSimTime;
}

private func SGF_SetLastTime(puppet: wref<NPCPuppet>, part: Int32, value: Float) -> Void {
  if part == 0 { puppet.sgf_headLastSimTime = value; return; }
  if part == 1 { puppet.sgf_chestLastSimTime = value; return; }
  if part == 2 { puppet.sgf_pelvisLastSimTime = value; return; }
  if part == 3 { puppet.sgf_leftKneeLastSimTime = value; return; }
  puppet.sgf_rightKneeLastSimTime = value;
}

private func SGF_CopyTick(oldEvent: ref<SGF_TickEvent>) -> ref<SGF_TickEvent> {
  let event: ref<SGF_TickEvent> = new SGF_TickEvent();
  event.part = oldEvent.part;
  event.generation = oldEvent.generation;
  event.downPerSec = oldEvent.downPerSec;
  event.radius = oldEvent.radius;
  event.startDelay = oldEvent.startDelay;
  event.duration = oldEvent.duration;
  event.updateInterval = oldEvent.updateInterval;
  event.maxDeltaTime = oldEvent.maxDeltaTime;
  event.armedSimTime = oldEvent.armedSimTime;
  return event;
}

private func SGF_IsBlocked(puppet: wref<NPCPuppet>, config: RFCConfig) -> Bool {
  if !IsDefined(puppet) { return true; }
  if config.vanillaMode || RFC_TimeDilationBlocksImpulses(puppet, config) { return true; }
  if RFC_IsVehicleContext(puppet) || RFC_Explode_IsRecent(puppet) { return true; }
  if RFC_MasterDeathChanceBlocksImpulses(puppet) { return true; }
  // An armed Situational gravity event may survive a restored death animation.
  // It waits for the actual ragdoll handoff before its delay/duration begins.
  return false;
}

private func SGF_LivePartPosition(puppet: ref<NPCPuppet>, part: Int32) -> Vector4 {
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
    puppet, 0.0, 0.0, R,
    headPos, chestPos, pelvisPos,
    leftKneePos, rightKneePos,
    leftShinPos, rightShinPos,
    leftFootPos, rightFootPos
  );

  if part == 0 { return headPos; }
  if part == 1 { return chestPos; }
  if part == 2 { return pelvisPos; }
  if part == 3 { return leftKneePos; }
  return rightKneePos;
}

public func SGF_ScheduleDownRange(
  puppet: ref<NPCPuppet>,
  config: RFCConfig,
  part: Int32,
  minimum: Float,
  maximum: Float,
  radius: Float,
  delay: Float
) -> Void {
  let body: ref<GS_Settings> = SPLATSettingsRuntime.Body();
  let event: ref<SGF_TickEvent>;
  let delaySystem: ref<DelaySystem>;
  let now: Float;
  let startTime: Float;
  let strength: Float;
  let duration: Float = 2.0;
  let updateInterval: Float = 0.016;
  let maxDeltaTime: Float = 0.050;

  if !IsDefined(puppet) || part < 0 || part > 4 || radius <= 0.0 { return; }
  if SGF_IsBlocked(puppet, config) { return; }

  if part == 0 {
    strength = RFC_RandomHeadValue(puppet, config, minimum, maximum);
  } else {
    strength = RFC_RandomBodyValue(puppet, config, minimum, maximum);
  }
  strength = SGF_Pos(strength);
  if strength <= 0.0001 { return; }

  if IsDefined(body) {
    duration = SGF_Pos(body.bodyDuration);
    updateInterval = SGF_Clamp(body.gravityUpdateInterval, 0.008, 0.050);
    maxDeltaTime = SGF_Clamp(body.gravityMaxDeltaTime, 0.016, 0.100);
  }
  if duration <= 0.0 { return; }

  now = EngineTime.ToFloat(GameInstance.GetSimTime(puppet.GetGame()));
  // Negative start time = armed, waiting for real ragdoll physics.
  startTime = -1.0;
  SGF_SetTimes(puppet, part, startTime);

  event = new SGF_TickEvent();
  event.part = part;
  event.generation = SGF_NextGeneration(puppet, part);
  event.downPerSec = strength;
  event.radius = radius;
  event.startDelay = SGF_Pos(delay);
  event.duration = duration;
  event.updateInterval = updateInterval;
  event.maxDeltaTime = maxDeltaTime;
  event.armedSimTime = now;

  delaySystem = GameInstance.GetDelaySystem(puppet.GetGame());
  if IsDefined(delaySystem) {
    delaySystem.DelayEvent(puppet, event, event.updateInterval, false);
  } else {
    puppet.QueueEvent(event);
  }
}

@addMethod(NPCPuppet)
protected cb func OnSGF_TickEvent(event: ref<SGF_TickEvent>) -> Bool {
  let config: RFCConfig = RFC.Cfg();
  let delaySystem: ref<DelaySystem>;
  let now: Float;
  let elapsed: Float;
  let deltaTime: Float;
  let position: Vector4;

  if !IsDefined(event) || event.generation != SGF_GetGeneration(this, event.part) { return true; }
  if SGF_IsBlocked(this, config) { return true; }

  now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));

  // Keep the event armed while a death animation owns the body. Once ragdoll
  // actually begins, start this body part's configured delay/duration clock.
  if !this.IsRagdolling() {
    if now - event.armedSimTime <= 10.0 {
      delaySystem = GameInstance.GetDelaySystem(this.GetGame());
      if IsDefined(delaySystem) {
        delaySystem.DelayEvent(this, SGF_CopyTick(event), event.updateInterval, false);
      }
    }
    return true;
  }

  if SGF_GetStartTime(this, event.part) < 0.0 {
    SGF_SetTimes(this, event.part, now + event.startDelay);
  }

  elapsed = now - SGF_GetStartTime(this, event.part);
  if elapsed < 0.0 {
    elapsed = 0.0;
  }

  deltaTime = now - SGF_GetLastTime(this, event.part);
  if deltaTime <= 0.000001 { deltaTime = event.updateInterval; }
  deltaTime = SGF_Clamp(deltaTime, 0.0, event.maxDeltaTime);
  SGF_SetLastTime(this, event.part, now);

  if elapsed <= event.duration && deltaTime > 0.0 {
    position = SGF_LivePartPosition(this, event.part);
    this.QueueEvent(CreateRagdollApplyImpulseEvent(
      position,
      new Vector4(0.0, 0.0, -(event.downPerSec * deltaTime), 1.0),
      event.radius
    ));
  }

  if elapsed < event.duration && this.IsRagdolling() {
    delaySystem = GameInstance.GetDelaySystem(this.GetGame());
    if IsDefined(delaySystem) {
      delaySystem.DelayEvent(this, SGF_CopyTick(event), event.updateInterval, false);
    }
  }
  return true;
}
