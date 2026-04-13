module RealisticPush

func RFC_IsFaceDown(entity: ref<Entity>) -> Bool {
  let upVec: Vector4 = entity.GetWorldUp();
  let dot: Float = Vector4.Dot(upVec, Vector4(0.0, 0.0, 1.0, 0.0));
  return dot < -0.5;
}

func RFC_IsFaceDownByBones(chestPos: Vector4, pelvisPos: Vector4) -> Bool {
  return chestPos.Z < pelvisPos.Z;
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

    ds.DelayEvent(puppet, CreateRagdollApplyImpulseEvent(chestPos,  twitchVec, twitchForce), t,        false);
    ds.DelayEvent(puppet, CreateRagdollApplyImpulseEvent(pelvisPos, twitchVec, twitchForce), t + 0.15, false);
    ds.DelayEvent(puppet, CreateRagdollApplyImpulseEvent(headPos,   twitchVec, twitchForce), t + 0.30, false);

    t += RandRangeF(c.twitchDelayStepMin, c.twitchDelayStepMax);
  };
}
