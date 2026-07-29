module RealisticPush

func RFC_IsFaceDown(entity: ref<Entity>) -> Bool {
  let upVec: Vector4 = entity.GetWorldUp();
  let dot: Float = Vector4.Dot(upVec, Vector4(0.0, 0.0, 1.0, 0.0));
  return dot < -0.5;
}

func RFC_IsFaceDownByBones(chestPos: Vector4, pelvisPos: Vector4) -> Bool {
  return chestPos.Z < pelvisPos.Z;
}

// Twitch must remain identifiable until the delayed impulse actually fires.
// Scheduling a native RagdollApplyImpulseEvent directly loses that identity,
// so an OFF toggle or a later vehicle/workspot state cannot stop the event.
public class RFC_TwitchImpulseEvent extends Event {
  public let pos: Vector4;
  public let imp: Vector4;
  public let radius: Float;
}

@addMethod(NPCPuppet)
protected cb func OnRFC_TwitchImpulseEvent(evt: ref<RFC_TwitchImpulseEvent>) -> Bool {
  if !IsDefined(evt) {
    return true;
  };

  let c: RFCConfig = RFC.Cfg();
  if c.vanillaMode || RFC_TimeDilationBlocksImpulses(this, c) || !c.twitchEnabled {
    return true;
  };
  if RFC_MasterDeathChanceBlocksImpulses(this) || RFC_IsVehicleContext(this) {
    return true;
  };

  this.QueueEvent(CreateRagdollApplyImpulseEvent(evt.pos, evt.imp, evt.radius));
  return true;
}

private func RFC_ScheduleTwitchImpulse(
  puppet: ref<NPCPuppet>,
  ds: ref<DelaySystem>,
  pos: Vector4,
  imp: Vector4,
  radius: Float,
  delay: Float
) -> Void {
  let evt: ref<RFC_TwitchImpulseEvent> = new RFC_TwitchImpulseEvent();
  evt.pos = pos;
  evt.imp = imp;
  evt.radius = radius;
  ds.DelayEvent(puppet, evt, delay, false);
}


func RFC_ScheduleTwitch(
  puppet: ref<NPCPuppet>,
  ds:     ref<DelaySystem>,
  chestPos: Vector4,
  pelvisPos: Vector4,
  headPos:   Vector4,
  c: RFCConfig
) -> Void {

  let gVanilla:          Bool = c.vanillaMode;

  let gTwitchActive:     Bool = !gVanilla && c.twitchEnabled;

  if !gTwitchActive {
    return;
  };

  if RandF() >= c.twitchChance {
    return;
  };

  let tEnd: Float = c.twitchDelayStart + c.twitchDuration;
  let t: Float = c.twitchDelayStart;

  let isFaceDown: Bool = RFC_IsFaceDown(puppet);
  // Or, if you have bone positions:
  // let isFaceDown: Bool = Helpers.IsFaceDownByBones(chestPos, pelvisPos);

  while t < tEnd {
    let twitchVec: Vector4;
    let twitchForce: Float;

    if isFaceDown {
      twitchVec = Vector4(
        RandRangeF(-0.4, 0.4),
        RandRangeF(-0.25, 0.25),
        RandRangeF(-0.7, -0.2),
        0.0
      );
      twitchForce = c.twitchForce * RandRangeF(1.2, 1.5);
    } else {
      twitchVec = Vector4(
        RandRangeF(-0.2, 0.2),
        RandRangeF(-0.1, 0.1),
        RandRangeF(-2.00, -0.4),
        0.0
      );
      twitchForce = c.twitchForce * RandRangeF(0.85, 1.15);
    };

    RFC_ScheduleTwitchImpulse(puppet, ds, chestPos, twitchVec, twitchForce, t);
    RFC_ScheduleTwitchImpulse(puppet, ds, pelvisPos, twitchVec, twitchForce, t + 0.15);
    RFC_ScheduleTwitchImpulse(puppet, ds, headPos, twitchVec, twitchForce, t + 0.30);

    t += RandRangeF(c.twitchDelayStepMin, c.twitchDelayStepMax);
  };
}
