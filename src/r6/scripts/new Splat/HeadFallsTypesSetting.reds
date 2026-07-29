module RealisticPush

public class HIS_Settings {
public let showHeadForwardSection: Bool = false;

public let showReboundForwardSection: Bool = false;

public let showHeadBackSection: Bool = false;

  public let enabled: Bool = false;

  // Hidden compatibility flag. Do not expose this old menu control.
  public let hideFallBack: Bool = false;

  // Hidden compatibility fields. These controls were never read by runtime logic.
  public let forceRagdollFirst: Bool = true;
  public let backForceRagdollFirst: Bool = false;

  public let onDeath: Bool = true;

  public let onGroundImpact: Bool = false;

  public let disableOnGround: Bool = false;

  public let disableOnGroundDelay: Float = 1.500000;

  public let headKillOnDeathDelay: Float = 1.500000;

  public let directionMin: Float = 0.000000;

  public let forwardBackMin: Float = 82.650002;

  public let forwardBackMax: Float = 84.669998;

  public let leftRightMin: Float = 0.000000;

  public let leftRightMax: Float = 0.000000;

  public let upDownMin: Float = 272.759979;

  public let upDownMax: Float = 280.540009;

  public let chancePct: Int32 = 100;

  public let radius: Float = 0.100000;

  public let headTargetOffset: Float = 0.000000;

  public let delaySec: Float = 0.000000;

  public let steps: Int32 = 1;

  public let stepDelay: Float = 0.030000;

  public let rampMode: Int32 = 0;

////////////////////////////////////////////////////////////

  public let enableRebound: Bool = false;

  public let reboundRequiresHeadImpulse: Bool = false;

  public let reboundOnImpact: Bool = false;

  // Legacy property names are preserved so existing saved mode values migrate
  // without resetting. Runtime detection now samples the Head slot directly.
  public let reboundUseNeckFoldGate: Bool = true;

  public let reboundNeckFoldMin: Float = 0.000000;

  public let reboundNeckDropMin: Float = 0.000000;

  public let reboundKneeNearPct: Float = 3.000000;

  public let reboundDisableOnGround: Bool = false;

  public let reboundDisableOnGroundDelay: Float = 1.500000;

  public let reboundKillOnDeathDelay: Float = 1.500000;

  public let reboundForwardMin: Float = 0.000000;

  public let reboundDirectionMin: Float = 0.000010;

  public let reboundForwardMax: Float = 0.000000;

  public let reboundSideMin: Float = 0.000000;

  public let reboundSideMax: Float = 0.000000;

  public let reboundUpMin: Float = 292.179993;

  public let reboundUpMax: Float = 301.779999;

  public let reboundChancePct: Int32 = 100;

  public let reboundRadius: Float = 0.080000;

  public let reboundDelay: Float = 0.000000;

  public let reboundSteps: Int32 = 1;

  public let reboundStepDelay: Float = 0.030000;

  public let reboundRampMode: Int32 = 0;

////////////////////////////////////////////////////////////////

  public let backEnabled: Bool = false;

  public let backOnDeath: Bool = false;

  public let backOnGroundImpact: Bool = false;

  public let backDisableOnGround: Bool = false;

  public let backDisableOnGroundDelay: Float = 1.500000;

  public let backKillOnDeathDelay: Float = 1.500000;

  public let backDirectionMin: Float = 0.050000;

  public let backForwardBackMin: Float = 8.650000;

  public let backForwardBackMax: Float = 12.840000;

  public let backLeftRightMin: Float = 0.000000;

  public let backLeftRightMax: Float = 0.000000;

  public let backUpDownMin: Float = 0.000000;

  public let backUpDownMax: Float = 0.000000;

  public let backChancePct: Int32 = 100;

  public let backRadius: Float = 2.000000;

  public let backDelaySec: Float = 0.020000;

  public let backSteps: Int32 = 1;

  public let backStepDelay: Float = 0.030000;

  public let backRampMode: Int32 = 1;

////////////////////////////////////////////////////////////

  public let enableBackRebound: Bool = false;

  public let backReboundRequiresHeadImpulse: Bool = false;

  public let backReboundOnImpact: Bool = false;

  public let backReboundDisableOnGround: Bool = false;

  public let backReboundDisableOnGroundDelay: Float = 1.500000;

  public let backReboundKillOnDeathDelay: Float = 1.500000;

  public let backReboundDirectionMin: Float = 0.000010;

  public let backReboundForwardMin: Float = 11.340000;

  public let backReboundForwardMax: Float = 14.040000;

  public let backReboundSideMin: Float = 0.000000;

  public let backReboundSideMax: Float = 0.000000;

  public let backReboundUpMin: Float = 0.000000;

  public let backReboundUpMax: Float = 0.000000;

  public let backReboundChancePct: Int32 = 100;

  public let backReboundRadius: Float = 0.100000;

  public let backReboundDelay: Float = 0.030000;

  public let backReboundSteps: Int32 = 1;

  public let backReboundStepDelay: Float = 0.030000;

  public let backReboundRampMode: Int32 = 1;

  public let snapSpeedThreshold: Float = 0.0;
  public let snapRadius: Float = 0.0;
  public let minImpactSpeed: Float = 0.0;
  public let reboundSpeedThreshold: Float = 0.0;
}

public class HIS_FireEvt extends Event {
  public let stepIndex: Int32;
  public let lane: Int32; // 0 forward, 1 back
}

public class HIS_ReboundEvt extends Event {
  public let stepIndex: Int32;
  public let lane: Int32; // 0 forward, 1 back
  public let retryIndex: Int32;
}

// Situational Head overrides use the proven Head Falls delivery path instead
// of the generic body/situation burst. The event carries the chosen force,
// then resolves the live Head slot when it actually fires.
public class HIS_SituationalHeadEvt extends Event {
  public let impulseZ: Float;
  public let radius: Float;
}
@addField(NPCPuppet)
private let hisReboundStartSeeded: Bool;

@addField(NPCPuppet)
private let hisDidForwardGround: Bool;

@addField(NPCPuppet)
private let hisDidBackGround: Bool;

@addField(NPCPuppet)
private let hisDidForwardRebound: Bool;

@addField(NPCPuppet)
private let hisDidBackRebound: Bool;

@addField(NPCPuppet)
private let hisBasisForward: Vector4;

@addField(NPCPuppet)
private let hisBasisRight: Vector4;

@addField(NPCPuppet)
private let hisPrevHeadPos: Vector4;

@addField(NPCPuppet)
private let hisPrevUpperPos: Vector4;

@addField(NPCPuppet)
private let hisStartUpperPos: Vector4;

@addField(NPCPuppet)
private let hisStartProbePos: Vector4;

@addField(NPCPuppet)
private let hisStartLeftKneePos: Vector4;

@addField(NPCPuppet)
private let hisStartRightKneePos: Vector4;

@addField(NPCPuppet)
private let hisHeadTriggered: Bool;

@addField(NPCPuppet)
private let hisHeadMoveSeeded: Bool;

@addField(NPCPuppet)
private let hisReboundArmed: Bool;

@addField(NPCPuppet)
private let hisDeathStartTime: Float;

@addField(NPCPuppet)
private let hisHeadImpulseFired: Bool;

@addField(NPCPuppet)
private let hisBackHeadImpulseFired: Bool;
