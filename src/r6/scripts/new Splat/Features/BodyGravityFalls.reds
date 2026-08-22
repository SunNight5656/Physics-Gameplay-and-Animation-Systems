module RealisticPush

// Whole-ragdoll Gravity Falls.
//
// General Gravity intentionally has no head/chest/pelvis/knee targeting.
// Body-part ownership remains in Situational Falls. A matching Situational
// override blocks this complete General Gravity profile so the two systems do
// not stack.

public class BFG_RegularTickEvent extends Event {
  public let generation: Int32;
  public let downPerSec: Float;
  public let startDelay: Float;
  public let duration: Float;
  public let updateInterval: Float;
  public let maxDeltaTime: Float;
}

public class BFG_ImpactTickEvent extends Event {
  public let generation: Int32;
  public let downPerSec: Float;
  public let startDelay: Float;
  public let duration: Float;
  public let updateInterval: Float;
  public let maxDeltaTime: Float;
}

@addField(NPCPuppet) private let bfg_regularGeneration: Int32;
@addField(NPCPuppet) private let bfg_regularStartSimTime: Float;
@addField(NPCPuppet) private let bfg_regularLastSimTime: Float;
@addField(NPCPuppet) private let bfg_impactGeneration: Int32;
@addField(NPCPuppet) private let bfg_impactStartSimTime: Float;
@addField(NPCPuppet) private let bfg_impactLastSimTime: Float;

private func BFG_Pos(value: Float) -> Float {
  return value < 0.0 ? 0.0 : value;
}

private func BFG_Clamp(value: Float, minimum: Float, maximum: Float) -> Float {
  if value < minimum { return minimum; }
  if value > maximum { return maximum; }
  return value;
}

private func BFG_NewRegularTick(oldEvent: ref<BFG_RegularTickEvent>) -> ref<BFG_RegularTickEvent> {
  let event: ref<BFG_RegularTickEvent> = new BFG_RegularTickEvent();
  event.generation = oldEvent.generation;
  event.downPerSec = oldEvent.downPerSec;
  event.startDelay = oldEvent.startDelay;
  event.duration = oldEvent.duration;
  event.updateInterval = oldEvent.updateInterval;
  event.maxDeltaTime = oldEvent.maxDeltaTime;
  return event;
}

private func BFG_NewImpactTick(oldEvent: ref<BFG_ImpactTickEvent>) -> ref<BFG_ImpactTickEvent> {
  let event: ref<BFG_ImpactTickEvent> = new BFG_ImpactTickEvent();
  event.generation = oldEvent.generation;
  event.downPerSec = oldEvent.downPerSec;
  event.startDelay = oldEvent.startDelay;
  event.duration = oldEvent.duration;
  event.updateInterval = oldEvent.updateInterval;
  event.maxDeltaTime = oldEvent.maxDeltaTime;
  return event;
}

private func BFG_IsBlocked(puppet: wref<NPCPuppet>, config: RFCConfig) -> Bool {
  if !IsDefined(puppet) { return true; }
  if config.vanillaMode || RFC_TimeDilationBlocksImpulses(puppet, config) { return true; }
  if RFC_IsVehicleContext(puppet) || RFC_Explode_IsRecent(puppet) { return true; }
  if RFC_MasterDeathChanceBlocksImpulses(puppet) { return true; }

  // Gravity Falls starts from the actual ragdoll-enabled callback. Death
  // animation routing may deliberately close the old Body impulse gates before
  // ragdoll begins; those stale gates must not suppress Gravity Falls after the
  // animation has handed control back to physics.
  // Any enabled component in the captured Situational section owns the fall.
  // General Gravity must not continue beneath body-part-specific forces.
  if RFC_SitOverrideBodyBlock(puppet, config) { return true; }
  return false;
}

public func BFG_Cancel(puppet: wref<NPCPuppet>) -> Void {
  if !IsDefined(puppet) { return; }
  puppet.bfg_regularGeneration += 1;
  puppet.bfg_impactGeneration += 1;
}

public func BFG_BeginRegular(
  puppet: wref<NPCPuppet>,
  settings: ref<GS_Settings>,
  config: RFCConfig
) -> Void {
  let event: ref<BFG_RegularTickEvent>;
  let now: Float;

  if !IsDefined(puppet) || !IsDefined(settings) { return; }
  BFG_Cancel(puppet);
  if !settings.enabled || !settings.regularGravityEnabled { return; }
  if BFG_IsBlocked(puppet, config) || !GS_ShouldRun(puppet, settings) { return; }

  now = EngineTime.ToFloat(GameInstance.GetSimTime(puppet.GetGame()));
  puppet.bfg_regularStartSimTime = now;
  puppet.bfg_regularLastSimTime = now;

  event = new BFG_RegularTickEvent();
  event.generation = puppet.bfg_regularGeneration;
  event.downPerSec = BFG_Pos(RFC_RandomBodyValue(
    puppet,
    config,
    settings.bodyDownPerSecMin,
    settings.bodyDownPerSec
  ));
  event.startDelay = BFG_Pos(settings.bodyStartDelay);
  event.duration = BFG_Pos(settings.bodyDuration);
  event.updateInterval = BFG_Clamp(settings.gravityUpdateInterval, 0.008, 0.050);
  event.maxDeltaTime = BFG_Clamp(settings.gravityMaxDeltaTime, 0.016, 0.100);

  if event.downPerSec > 0.0 && event.duration > 0.0 {
    puppet.QueueEvent(event);
  }
}

public func BFG_BeginImpact(
  puppet: wref<NPCPuppet>,
  settings: ref<GS_Settings>,
  config: RFCConfig
) -> Void {
  let event: ref<BFG_ImpactTickEvent>;
  let now: Float;

  if !IsDefined(puppet) || !IsDefined(settings) { return; }
  puppet.bfg_impactGeneration += 1;
  if !settings.enabled || !settings.impactEnabled { return; }
  if BFG_IsBlocked(puppet, config) || !GS_ShouldRun(puppet, settings) { return; }

  now = EngineTime.ToFloat(GameInstance.GetSimTime(puppet.GetGame()));
  puppet.bfg_impactStartSimTime = now;
  puppet.bfg_impactLastSimTime = now;

  event = new BFG_ImpactTickEvent();
  event.generation = puppet.bfg_impactGeneration;
  event.downPerSec = BFG_Pos(RFC_RandomBodyValue(
    puppet,
    config,
    settings.impactStrengthPctMin,
    settings.impactStrengthPct
  ));
  event.startDelay = BFG_Pos(settings.impactDelaySec);
  event.duration = BFG_Pos(settings.impactDuration);
  event.updateInterval = BFG_Clamp(settings.gravityUpdateInterval, 0.008, 0.050);
  event.maxDeltaTime = BFG_Clamp(settings.gravityMaxDeltaTime, 0.016, 0.100);

  if event.downPerSec > 0.0 && event.duration > 0.0 {
    puppet.QueueEvent(event);
  }
}

@addMethod(NPCPuppet)
protected cb func OnBFG_RegularTickEvent(event: ref<BFG_RegularTickEvent>) -> Bool {
  let settings: ref<GS_Settings> = SPLATSettingsRuntime.Body();
  let config: RFCConfig = RFC.Cfg();
  let now: Float;
  let elapsed: Float;
  let deltaTime: Float;
  let position: Vector4;
  let delaySystem: ref<DelaySystem>;

  if !IsDefined(event) || event.generation != this.bfg_regularGeneration { return true; }
  if !IsDefined(settings) || !settings.enabled || !settings.regularGravityEnabled { return true; }
  if !this.IsRagdolling() || BFG_IsBlocked(this, config) { return true; }

  now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  elapsed = now - this.bfg_regularStartSimTime;
  deltaTime = now - this.bfg_regularLastSimTime;
  if deltaTime <= 0.000001 { deltaTime = event.updateInterval; }
  deltaTime = BFG_Clamp(deltaTime, 0.0, event.maxDeltaTime);
  this.bfg_regularLastSimTime = now;

  if elapsed >= event.startDelay
    && elapsed <= event.startDelay + event.duration
    && deltaTime > 0.0 {
    position = this.GetWorldPosition();
    position.Z += 0.75;
    this.QueueEvent(CreateRagdollApplyImpulseEvent(
      position,
      new Vector4(0.0, 0.0, -(event.downPerSec * deltaTime), 1.0),
      10000.0
    ));
  }

  if elapsed < event.startDelay + event.duration && this.IsRagdolling() {
    delaySystem = GameInstance.GetDelaySystem(this.GetGame());
    if IsDefined(delaySystem) {
      delaySystem.DelayEvent(this, BFG_NewRegularTick(event), event.updateInterval, false);
    }
  }
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnBFG_ImpactTickEvent(event: ref<BFG_ImpactTickEvent>) -> Bool {
  let settings: ref<GS_Settings> = SPLATSettingsRuntime.Body();
  let config: RFCConfig = RFC.Cfg();
  let now: Float;
  let elapsed: Float;
  let deltaTime: Float;
  let position: Vector4;
  let delaySystem: ref<DelaySystem>;

  if !IsDefined(event) || event.generation != this.bfg_impactGeneration { return true; }
  if !IsDefined(settings) || !settings.enabled || !settings.impactEnabled { return true; }
  if !this.IsRagdolling() || BFG_IsBlocked(this, config) { return true; }

  now = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  elapsed = now - this.bfg_impactStartSimTime;
  deltaTime = now - this.bfg_impactLastSimTime;
  if deltaTime <= 0.000001 { deltaTime = event.updateInterval; }
  deltaTime = BFG_Clamp(deltaTime, 0.0, event.maxDeltaTime);
  this.bfg_impactLastSimTime = now;

  if elapsed >= event.startDelay
    && elapsed <= event.startDelay + event.duration
    && deltaTime > 0.0 {
    position = this.GetWorldPosition();
    position.Z += 0.75;
    this.QueueEvent(CreateRagdollApplyImpulseEvent(
      position,
      new Vector4(0.0, 0.0, -(event.downPerSec * deltaTime), 1.0),
      10000.0
    ));
  }

  if elapsed < event.startDelay + event.duration && this.IsRagdolling() {
    delaySystem = GameInstance.GetDelaySystem(this.GetGame());
    if IsDefined(delaySystem) {
      delaySystem.DelayEvent(this, BFG_NewImpactTick(event), event.updateInterval, false);
    }
  }
  return true;
}
