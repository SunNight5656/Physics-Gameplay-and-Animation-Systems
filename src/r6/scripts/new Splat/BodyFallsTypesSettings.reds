module RealisticPush

public class GS_Settings {

public let enabled: Bool = true;

  // =========================
  // Menu Gates
  // =========================

public let gshide: Bool = true;

public let showEarlyDropSettings: Bool = false;

public let showImpactFallSettings: Bool = false;

public let ExtraSettings: Bool = false;


  // =========================
  // Standard Body Falls
  // =========================

  public let useChance: Bool = false;

  public let chancePct: Float = 100.000000;

  // Whole-ragdoll Gravity Falls. These are the six basic controls from the
  // standalone model: Regular force/delay/duration and Impact
  // force/delay/duration. Force is integrated against actual simulation time.
  public let regularGravityEnabled: Bool = true;

  public let bodyDownPerSec: Float = 60.000000;
  public let bodyDownPerSecMin: Float = 60.000000;

  public let bodyStartDelay: Float = 0.000000;

  public let bodyDuration: Float = 3.000000;

  public let gravityUpdateInterval: Float = 0.016000;

  public let gravityMaxDeltaTime: Float = 0.050000;

  public let momentumEnabled: Bool = true;

  public let momentumMult: Float = 1.000000;

  public let momentumMaxScale: Float = 1000.000000;

  // =========================
  // Standard Forward
  // =========================

  public let forwardEnabled: Bool = false;

  public let forwardChancePct: Float = 100.000000;

  public let forwardStrengthPct: Float = 2.000000;
  public let forwardStrengthPctMin: Float = 2.000000;

  public let forwardUseCached: Bool = false;

  public let forwardUseFacing: Bool = false;

  public let forwardRadiusM: Float = 1.000000;

  public let forwardDelaySec: Float = 0.030000;

  // =========================
  // Early Drop
  // =========================

  public let earlyDropEnabled: Bool = true;

  // =========================
  // Early Drop Forward
  // =========================

  public let earlyDropForwardEnabled: Bool = false;

  public let earlyDropForwardChancePct: Float = 100.000000;

  public let earlyDropForwardStrengthPct: Float = 1.000000;
  public let earlyDropForwardStrengthPctMin: Float = 1.000000;

  public let earlyDropForwardRadiusM: Float = 0.850000;

  public let earlyDropForwardUseFacing: Bool = false;

  public let earlyDropForwardUseCached: Bool = true;

  public let earlyDropDelaySec: Float = 0.050000;

  public let earlyDropUseRamp: Bool = false;

  public let earlyDropRampSec: Float = 0.120000;

  public let earlyDropStrengthPct: Float = 1.000000;
  public let earlyDropStrengthPctMin: Float = 1.000000;

  public let earlyDropRadiusM: Float = 0.850000;

  public let earlyDropSteps: Int32 = 1;

  // =========================
  // Impact Slam
  // ========================

  public let impactEnabled: Bool = true;

  // =========================
  // Impact Forward
  // =========================

  public let impactForwardAlso: Bool = false;

  public let impactForwardChancePct: Float = 100.000000;

  public let impactForwardStrengthPct: Float = 6.000000;
  public let impactForwardStrengthPctMin: Float = 6.000000;

  public let impactForwardRadiusM: Float = 1.100000;

  public let impactForwardUseFacing: Bool = false;

  public let impactForwardUseCached: Bool = false;

  public let impactDelaySec: Float = 0.000000;

  public let impactStrengthPct: Float = 40.000000;
  public let impactStrengthPctMin: Float = 40.000000;

  public let impactRadiusM: Float = 1.000000;

  public let impactSteps: Int32 = 1;

  public let impactUseRamp: Bool = false;

  public let impactRampSec: Float = 0.120000;

  public let impactDuration: Float = 0.500000;

  // =========================
  // Debug Tools
  // =========================

public let showDebugSettings: Bool = false;

  public let reverseGravity: Bool = false;

  public let extremeMode: Bool = false;

  public let debugProofZ: Float = 0.000000;

  public let debugProofF: Float = 0.000000;

  public let extremeMult: Float = 0.000000;

public let maxZNormal: Float = 25.000000;

  public let maxFNormal: Float = 0.000000;

}

// Per puppet state

public class GS_ForwardEvt extends Event {}
public class GS_EarlyStepEvt extends Event {}
public class GS_ImpactStepEvt extends Event {}

// We store progress counters by consuming them down each step
@addField(NPCPuppet) private let gs_rollDone: Bool;
@addField(NPCPuppet) private let gs_rollOK: Bool;
@addField(NPCPuppet) private let gs_impactDone: Bool;
@addField(NPCPuppet) private let gs_fbDone: Bool;
@addField(NPCPuppet) private let gs_fbSign: Float;
@addField(NPCPuppet) private let gs_forwardDo: Bool;
@addField(NPCPuppet) private let gs_earlyForwardDo: Bool;
@addField(NPCPuppet) private let gs_impactForwardDo: Bool;
@addField(NPCPuppet) private let gs_earlyStepIdx: Int32;
@addField(NPCPuppet) private let gs_earlyStepMax: Int32;

@addField(NPCPuppet) private let gs_impactStepIdx: Int32;
@addField(NPCPuppet) private let gs_impactStepMax: Int32;
@addField(NPCPuppet) private let gs_vel2D: Float;
@addField(NPCPuppet) private let gs_dir2D: Vector4;
