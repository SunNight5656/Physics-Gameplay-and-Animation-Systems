module RealisticPush

private func GS_OverrideForward(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  if c.st_overrideGlobalForward { return true; }
  if c.run_overrideGlobalForward { return true; }
  if c.cow_overrideGlobalForward { return true; }
  if c.stair_overrideGlobalForward { return true; }
  if c.wsStand_overrideGlobalForward { return true; }
  return false;
}

private func GS_OverrideChest(p: ref<NPCPuppet>, c: RFCConfig) -> Bool {
  if c.st_overrideGlobalChest { return true; }
  if c.run_overrideGlobalChest { return true; }
  if c.cow_overrideGlobalChest { return true; }
  if c.stair_overrideGlobalChest { return true; }
  if c.wsStand_overrideGlobalChest { return true; }
  return false;
}

public class GS_Settings {

  // =========================
  // Standard Impulses
  // =========================

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Enable Global Body Impulses")
  @runtimeProperty("ModSettings.description", "Turns all standard impulses on or off.")
  public let enabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Use Body Impulse Chance Gate")
  @runtimeProperty("ModSettings.description", "Lets only some NPCs get standard impulses.")
  @runtimeProperty("ModSettings.dependency", "enabled")
  public let useChance: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Body Impulse Chance (%)")
  @runtimeProperty("ModSettings.description", "100 means always. 50 means about half.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "enabled")
  public let chancePct: Float = 100.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Scale Force By Speed")
  @runtimeProperty("ModSettings.description", "Makes faster NPCs get stronger impulses.")
  @runtimeProperty("ModSettings.dependency", "enabled")
  public let momentumEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Speed To Force Ratio")
  @runtimeProperty("ModSettings.description", "How much speed increases force.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "10.0")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.dependency", "enabled")
  public let momentumMult: Float = 1.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Max Speed Multiplier")
  @runtimeProperty("ModSettings.description", "Caps the extra force from speed.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "10.0")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.dependency", "enabled")
  public let momentumMaxScale: Float = 1000.0;

  // =========================
  // Standard Forward
  // =========================

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Enable Standard Forward")
  @runtimeProperty("ModSettings.description", "Adds a standalone standard forward push.")
  public let forwardEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Standard Forward Chance (%)")
  @runtimeProperty("ModSettings.description", "Chance to apply the standard forward push.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "forwardEnabled")
  public let forwardChancePct: Float = 100.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Standard Forward Impulse")
  @runtimeProperty("ModSettings.description", "How strong the standard forward push is.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "1000.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "forwardEnabled")
  public let forwardStrengthPct: Float = 35.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Standard Forward Lock Direction On Fall")
  @runtimeProperty("ModSettings.description", "Keeps the direction from changing after ragdoll starts.")
  @runtimeProperty("ModSettings.dependency", "forwardEnabled")
  public let forwardUseCached: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Standard Forward Use Facing Direction")
  @runtimeProperty("ModSettings.description", "Uses where the NPC is facing.")
  @runtimeProperty("ModSettings.dependency", "forwardEnabled")
  public let forwardUseFacing: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Standard Forward Radius (m)")
  @runtimeProperty("ModSettings.description", "Impulse radius for the standard forward push.")
  @runtimeProperty("ModSettings.min", "0.10")
  @runtimeProperty("ModSettings.max", "12.00")
  @runtimeProperty("ModSettings.step", "0.10")
  @runtimeProperty("ModSettings.dependency", "forwardEnabled")
  public let forwardRadiusM: Float = 1.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Standard Forward Delay (sec)")
  @runtimeProperty("ModSettings.description", "How long to wait before the standard forward push.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "forwardEnabled")
  public let forwardDelaySec: Float = 0.03;

  // =========================
  // Impact Slam
  // ========================

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Enable Impact")
  @runtimeProperty("ModSettings.description", "Enable Impact")
  public let enableImpact: Bool = false;

  // =========================
  // Impact Forward
  // =========================

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Enable Impact Forward")
  @runtimeProperty("ModSettings.description", "Adds forward push during impact.")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactForwardAlso: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Forward Chance (%)")
  @runtimeProperty("ModSettings.description", "Chance to apply impact forward push.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactForwardChancePct: Float = 100.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Forward Impulse")
  @runtimeProperty("ModSettings.description", "How strong the impact forward push is.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100000.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactForwardStrengthPct: Float = 35.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Forward Radius (m)")
  @runtimeProperty("ModSettings.description", "Impulse radius for the impact forward push.")
  @runtimeProperty("ModSettings.min", "0.10")
  @runtimeProperty("ModSettings.max", "12.00")
  @runtimeProperty("ModSettings.step", "0.10")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactForwardRadiusM: Float = 1.10;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Forward Use Facing Direction")
  @runtimeProperty("ModSettings.description", "Uses where the NPC is facing.")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactForwardUseFacing: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Forward Lock Direction On Fall")
  @runtimeProperty("ModSettings.description", "Keeps the direction from changing after ragdoll starts.")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactForwardUseCached: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Enable Impact Slam")
  @runtimeProperty("ModSettings.description", "Applies extra force on ground hit.")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Delay (sec)")
  @runtimeProperty("ModSettings.description", "How long to wait after impact.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.005")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactDelaySec: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Strength (%)")
  @runtimeProperty("ModSettings.description", "How strong the impact force is.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "1000.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactStrengthPct: Float = 70.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Radius (m)")
  @runtimeProperty("ModSettings.description", "Impulse radius for the impact slam.")
  @runtimeProperty("ModSettings.min", "0.10")
  @runtimeProperty("ModSettings.max", "12.00")
  @runtimeProperty("ModSettings.step", "0.10")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactRadiusM: Float = 1.10;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Pulses")
  @runtimeProperty("ModSettings.description", "How many impact pulses to send.")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "12")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactSteps: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Ramp Impact Force")
  @runtimeProperty("ModSettings.description", "Makes each impact pulse get stronger.")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactUseRamp: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Impact Ramp Time (sec)")
  @runtimeProperty("ModSettings.description", "How long the impact ramp lasts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "10.60")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "enableImpact")
  public let impactRampSec: Float = 0.12;

  // =========================
  // Early Drop
  // =========================

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Enable Early Drop")
  @runtimeProperty("ModSettings.description", "Applies force right after ragdoll starts.")
  public let earlyDropEnabled: Bool = false;

  // =========================
  // Early Drop Forward
  // =========================

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Enable Early Drop Forward")
  @runtimeProperty("ModSettings.description", "Adds forward push during early drop.")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropForwardEnabled: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Forward Chance (%)")
  @runtimeProperty("ModSettings.description", "Chance to apply early drop forward push.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropForwardChancePct: Float = 100.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Forward Impulse")
  @runtimeProperty("ModSettings.description", "How strong the early drop forward push is.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100000.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropForwardStrengthPct: Float = 35.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Forward Radius (m)")
  @runtimeProperty("ModSettings.description", "Impulse radius for the early drop forward push.")
  @runtimeProperty("ModSettings.min", "0.10")
  @runtimeProperty("ModSettings.max", "12.00")
  @runtimeProperty("ModSettings.step", "0.10")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropForwardRadiusM: Float = 0.85;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Forward Use Facing Direction")
  @runtimeProperty("ModSettings.description", "Uses where the NPC is facing.")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropForwardUseFacing: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Forward Lock Direction On Fall")
  @runtimeProperty("ModSettings.description", "Keeps the direction from changing after ragdoll starts.")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropForwardUseCached: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Delay (sec)")
  @runtimeProperty("ModSettings.description", "How long to wait before the first push.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropDelaySec: Float = 0.05;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Ramp Early Drop Force")
  @runtimeProperty("ModSettings.description", "Makes each early drop pulse get stronger.")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropUseRamp: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Ramp Time (sec)")
  @runtimeProperty("ModSettings.description", "How long the early drop ramp lasts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "10.60")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropRampSec: Float = 0.12;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Strength (%)")
  @runtimeProperty("ModSettings.description", "How strong the first downward push is.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "1001.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropStrengthPct: Float = 25.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Radius (m)")
  @runtimeProperty("ModSettings.description", "Impulse radius for the early drop.")
  @runtimeProperty("ModSettings.min", "0.10")
  @runtimeProperty("ModSettings.max", "12.00")
  @runtimeProperty("ModSettings.step", "0.10")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropRadiusM: Float = 0.85;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Early Drop Pulses")
  @runtimeProperty("ModSettings.description", "How many early drop pulses to send.")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "12")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.dependency", "earlyDropEnabled")
  public let earlyDropSteps: Int32 = 1;

  // =========================
  // Debug Tools
  // =========================

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Show Debug Tools")
  @runtimeProperty("ModSettings.description", "Shows or hides debug tools.")
  public let showDebugSettings: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Debug: Reverse Gravity")
  @runtimeProperty("ModSettings.description", "Pushes upward for testing.")
  @runtimeProperty("ModSettings.dependency", "showDebugSettings")
  public let reverseGravity: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Debug: Extreme Mode")
  @runtimeProperty("ModSettings.description", "Greatly increases force for testing.")
  @runtimeProperty("ModSettings.dependency", "showDebugSettings")
  public let extremeMode: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Debug: Proof Down Force")
  @runtimeProperty("ModSettings.description", "Used only in Proof Mode.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "60.0")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.dependency", "showDebugSettings")
  public let debugProofZ: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Debug: Proof Forward Force")
  @runtimeProperty("ModSettings.description", "Used only in Proof Mode.")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "30.0")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.dependency", "showDebugSettings")
  public let debugProofF: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Debug: Extreme Multiplier")
  @runtimeProperty("ModSettings.description", "Extra force used in Extreme Mode.")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "10.0")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.dependency", "showDebugSettings")
  public let extremeMult: Float = 0.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Debug: Max Down Force")
  @runtimeProperty("ModSettings.description", "Limits the strongest downward force.")
  @runtimeProperty("ModSettings.min", "1.0")
  @runtimeProperty("ModSettings.max", "25.0")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.dependency", "showDebugSettings")
public let maxZNormal: Float = 2525.0;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Body Impulses")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "[GS] Debug: Max Forward Force")
  @runtimeProperty("ModSettings.description", "Limits the strongest forward force.")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "20.0")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.dependency", "showDebugSettings")
  public let maxFNormal: Float = 0.0;

}

// Per puppet state
@addField(NPCPuppet) private let gs_rollDone: Bool;
@addField(NPCPuppet) private let gs_rollOK: Bool;

@addField(NPCPuppet) private let gs_impactDone: Bool;

@addField(NPCPuppet) private let gs_fbDone: Bool;
@addField(NPCPuppet) private let gs_fbSign: Float;

@addField(NPCPuppet) private let gs_forwardDo: Bool;
@addField(NPCPuppet) private let gs_earlyForwardDo: Bool;
@addField(NPCPuppet) private let gs_impactForwardDo: Bool;

private func GS_Clamp01(v: Float) -> Float {
  if v < 0.0 { return 0.0; }
  if v > 1.0 { return 1.0; }
  return v;
}

private func GS_Clamp(v: Float, lo: Float, hi: Float) -> Float {
  if v < lo { return lo; }
  if v > hi { return hi; }
  return v;
}

private func GS_RollChancePct(pct: Float) -> Bool {
  let c01: Float = GS_Clamp01(pct / 100.0);
  if c01 <= 0.0 { return false; }
  if c01 >= 1.0 { return true; }
  return RandF() < c01;
}

private func GS_StrengthToZ(pct: Float, s: ref<GS_Settings>) -> Float {
  let zBase: Float = GS_Pos(pct);

  if s.extremeMode {
    return zBase * GS_Pos(s.extremeMult);
  }

  return zBase;
}

private func GS_ApplyBodyOnlyMode(
  p: wref<NPCPuppet>,
  zMag: Float,
  radiusM: Float,
  zOffset: Float,
  s: ref<GS_Settings>
) -> Void {
  let imp: Vector4;
  let dir: Vector4;

  if !IsDefined(p) { return; }

  dir = GS_GetForwardDir(p, s);

  imp = new Vector4(
    dir.X * zMag,
    dir.Y * zMag,
    zMag * GS_VertSign(s),
    1.0
  );

  GS_ApplyImpulse(p, imp, radiusM, zOffset);
}
private func GS_StrengthToF(val: Float, s: ref<GS_Settings>) -> Float {
  return GS_Pos(val);
}

// Ease in curve so it starts slow then ramps faster.
// t in 0..1, returns 0..1
private func GS_EaseIn(t: Float) -> Float {
  let x: Float = GS_Clamp01(t);
  return x * x;
}

private func GS_ShouldRun(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Bool {
  let chance01: Float;
  let roll: Float;

  if !IsDefined(p) { return false; }
  if !s.useChance { return true; }

  if p.gs_rollDone {
    return p.gs_rollOK;
  }

  p.gs_rollDone = true;

  chance01 = GS_Clamp01(s.chancePct / 100.0);
  if chance01 <= 0.0 { p.gs_rollOK = false; return false; }
  if chance01 >= 1.0 { p.gs_rollOK = true; return true; }

  roll = RandF();
  p.gs_rollOK = roll < chance01;
  return p.gs_rollOK;
}

private func GS_RollForwardBack(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Float {
  let c01: Float;
  if !IsDefined(p) { return 1.0; }

  if p.gs_fbDone {
    return p.gs_fbSign;
  }

  p.gs_fbDone = true;

  c01 = GS_Clamp01(s.forwardChancePct / 100.0);
  if RandF() < c01 {
    p.gs_fbSign = 1.0;
  } else {
    p.gs_fbSign = -1.0;
  }

  return p.gs_fbSign;
}

private func GS_GetForwardDirMode(
  p: wref<NPCPuppet>,
  useFacing: Bool,
  useCached: Bool,
  s: ref<GS_Settings>
) -> Vector4 {
  let dir: Vector4;
  let v: Vector4;
  let len: Float;

  if !IsDefined(p) {
    return new Vector4(0.0, 1.0, 0.0, 0.0);
  }

  if useFacing {
    dir = p.GetWorldForward();
  } else {
    if useCached && p.gs_vel2D > 0.05 {
      dir = p.gs_dir2D;
    } else {
      v = p.GetVelocity();
      v.Z = 0.0;
      len = Vector4.Length(v);
      if len > 0.05 {
        dir = v / len;
      } else {
        dir = p.GetWorldForward();
      }
    }
  }

  dir.Z = 0.0;
  len = Vector4.Length(dir);
  if len <= 0.001 {
    return new Vector4(0.0, 1.0, 0.0, 0.0);
  }

  return dir / len;
}

private func GS_GetForwardDir(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Vector4 {
  return GS_GetForwardDirMode(p, s.forwardUseFacing, s.forwardUseCached, s);
}

private func GS_CacheMomentum(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Void {
  let v: Vector4;
  let len: Float;
  if !IsDefined(p) { return; }

  v = p.GetVelocity();
  v.Z = 0.0;
  len = Vector4.Length(v);
  p.gs_vel2D = len;

  if len > 0.05 {
    p.gs_dir2D = v / len;
  } else {
    p.gs_dir2D = p.GetWorldForward();
    p.gs_dir2D.Z = 0.0;
    len = Vector4.Length(p.gs_dir2D);
    if len > 0.001 {
      p.gs_dir2D = p.gs_dir2D / len;
    } else {
      p.gs_dir2D = new Vector4(0.0, 1.0, 0.0, 0.0);
    }
  }
}

private func GS_MomentumScale(p: wref<NPCPuppet>, s: ref<GS_Settings>) -> Float {
  let v: Float;
  let sc: Float;
  if !s.momentumEnabled { return 1.0; }
  if !IsDefined(p) { return 1.0; }

  v = p.gs_vel2D;
  if v < 0.0 { v = 0.0; }
  sc = 1.0 + (v * GS_Pos(s.momentumMult));
  return sc;
}

private func GS_GetPointAtHeight(p: wref<NPCPuppet>, height: Float, forwardOffset: Float, s: ref<GS_Settings>) -> Vector4 {
  let pos: Vector4;
  let fDir: Vector4;

  pos = p.GetWorldPosition();
  pos.Z += height;

  fDir = GS_GetForwardDir(p, s);
  pos.X += fDir.X * forwardOffset;
  pos.Y += fDir.Y * forwardOffset;
  return pos;
}

private func GS_ApplyImpulseAtPoint(p: wref<NPCPuppet>, pos: Vector4, impulse: Vector4, radiusM: Float) -> Void {
  if !IsDefined(p) { return; }
  p.QueueEvent(CreateRagdollApplyImpulseEvent(pos, impulse, radiusM));
}

private func GS_ApplyForwardAtPoint(
  p: wref<NPCPuppet>,
  pos: Vector4,
  fMag: Float,
  radiusM: Float,
  s: ref<GS_Settings>,
  reverseDir: Bool
) -> Void {
  let fbSign: Float;
  let fDir: Vector4;
  let imp: Vector4;

  if !IsDefined(p) { return; }

  fbSign = GS_RollForwardBack(p, s);
  if reverseDir {
    fbSign *= -1.0;
  }

  fDir = GS_GetForwardDir(p, s);
  imp = new Vector4(0.0, 0.0, 0.0, 1.0);
  imp.X = fDir.X * (fMag * fbSign);
  imp.Y = fDir.Y * (fMag * fbSign);

  GS_ApplyImpulseAtPoint(p, pos, imp, radiusM);
}

private func GS_ApplyForwardAtPointMode(
  p: wref<NPCPuppet>,
  pos: Vector4,
  fMag: Float,
  radiusM: Float,
  s: ref<GS_Settings>,
  useFacing: Bool,
  useCached: Bool
) -> Void {
  let fDir: Vector4;
  let imp: Vector4;

  if !IsDefined(p) { return; }
  if fMag <= 0.001 { return; }

  fDir = GS_GetForwardDirMode(p, useFacing, useCached, s);
  imp = new Vector4(0.0, 0.0, 0.0, 1.0);
  imp.X = fDir.X * fMag;
  imp.Y = fDir.Y * fMag;

  GS_ApplyImpulseAtPoint(p, pos, imp, radiusM);
}

private func GS_ApplyForwardOnlyMode(
  p: wref<NPCPuppet>,
  fMag: Float,
  radiusM: Float,
  zOffset: Float,
  s: ref<GS_Settings>,
  useFacing: Bool,
  useCached: Bool
) -> Void {
  let pos: Vector4;
  if !IsDefined(p) { return; }
  pos = p.GetWorldPosition();
  pos.Z += zOffset;
  GS_ApplyForwardAtPointMode(p, pos, fMag, radiusM, s, useFacing, useCached);
}

private func GS_Abs(v: Float) -> Float {
  if v < 0.0 { return -v; }
  return v;
}

private func GS_Pos(v: Float) -> Float {
  return GS_Abs(v);
}

private func GS_Dot2(a: Vector4, b: Vector4) -> Float {
  return (a.X * b.X) + (a.Y * b.Y);
}

private func GS_GetRightDirFromForward(fwd: Vector4) -> Vector4 {
  let r: Vector4 = new Vector4(-fwd.Y, fwd.X, 0.0, 0.0);
  let len: Float = Vector4.Length(r);
  if len <= 0.001 {
    return new Vector4(1.0, 0.0, 0.0, 0.0);
  }
  return r / len;
}

private func GS_ApplyImpulse(p: wref<NPCPuppet>, impulse: Vector4, radiusM: Float, zOffset: Float) -> Void {
  let pos: Vector4;
  if !IsDefined(p) { return; }
  pos = p.GetWorldPosition();
  pos.Z += zOffset;
  p.QueueEvent(CreateRagdollApplyImpulseEvent(pos, impulse, radiusM));
}

private func GS_VertSign(s: ref<GS_Settings>) -> Float {
  return s.reverseGravity ? 1.0 : -1.0;
}

private func GS_ApplyVerticalAndForwardMode(
  p: wref<NPCPuppet>,
  zMag: Float,
  fMag: Float,
  radiusM: Float,
  zOffset: Float,
  s: ref<GS_Settings>,
  useFacing: Bool,
  useCached: Bool
) -> Void {
  let zSign: Float;
  let fDir: Vector4;
  let imp: Vector4;

  if !IsDefined(p) { return; }

  zSign = GS_VertSign(s);
  fDir = GS_GetForwardDirMode(p, useFacing, useCached, s);

  imp = new Vector4(0.0, 0.0, zMag * zSign, 1.0);

  if fMag > 0.001 {
    imp.X += fDir.X * fMag;
    imp.Y += fDir.Y * fMag;
  }

  GS_ApplyImpulse(p, imp, radiusM, zOffset);
}

private func GS_ScheduleRamp(
  ds: ref<DelaySystem>,
  p: wref<NPCPuppet>,
  steps: Int32,
  baseDelay: Float,
  rampSec: Float,
  isImpact: Bool
) -> Void {
  let n: Int32;
  let i: Int32;
  let e: ref<Event>;
  let tStep: Float;
  let when: Float;

  if !IsDefined(ds) || !IsDefined(p) { return; }

  n = steps;
  if n < 1 { return; }

  if rampSec <= 0.001 || n == 1 {
    if isImpact {
      e = new GS_ImpactStepEvt();
    } else {
      e = new GS_EarlyStepEvt();
    }
    ds.DelayEvent(p, e, MaxF(0.0, baseDelay), false);
    return;
  }

  tStep = rampSec / Cast<Float>(n);

  i = 0;
  while i < n {
    if isImpact {
      e = new GS_ImpactStepEvt();
    } else {
      e = new GS_EarlyStepEvt();
    }
    when = MaxF(0.0, baseDelay + (Cast<Float>(i) * tStep));
    ds.DelayEvent(p, e, when, false);
    i += 1;
  }
}

// Events
public class GS_ForwardEvt extends Event {}
public class GS_EarlyStepEvt extends Event {}
public class GS_ImpactStepEvt extends Event {}

// We store progress counters by consuming them down each step
@addField(NPCPuppet) private let gs_earlyStepIdx: Int32;
@addField(NPCPuppet) private let gs_earlyStepMax: Int32;

@addField(NPCPuppet) private let gs_impactStepIdx: Int32;
@addField(NPCPuppet) private let gs_impactStepMax: Int32;
@addField(NPCPuppet) private let gs_vel2D: Float;
@addField(NPCPuppet) private let gs_dir2D: Vector4;

@addMethod(NPCPuppet)
protected cb func OnGS_ForwardEvt(e: ref<GS_ForwardEvt>) -> Bool {
  let s: ref<GS_Settings> = new GS_Settings();
  let fMag: Float;

  if !s.enabled { return true; }
  if !s.forwardEnabled { return true; }
  if !ScriptedPuppet.CanRagdoll(this) { return true; }
// if !GS_ShouldRun(this, s) { return true; }
  if !this.gs_forwardDo { return true; }

  fMag = GS_StrengthToF(s.forwardStrengthPct, s);
  if s.showDebugSettings {
    fMag = GS_Pos(s.debugProofF);
  }

  GS_ApplyForwardOnlyMode(this, fMag, s.forwardRadiusM, 1.00, s, s.forwardUseFacing, s.forwardUseCached);
  return true;
}


@addMethod(NPCPuppet)
protected cb func OnGS_EarlyStepEvt(e: ref<GS_EarlyStepEvt>) -> Bool {
  let s: ref<GS_Settings> = new GS_Settings();
  let zMagFull: Float;
  let fMagFull: Float;
  let t01: Float;
  let w: Float;

  if !s.enabled { return true; }
  if !s.earlyDropEnabled { return true; }
  if !ScriptedPuppet.CanRagdoll(this) { return true; }
  if !GS_ShouldRun(this, s) { return true; }

  if this.gs_earlyStepMax <= 0 {
    this.gs_earlyStepMax = s.earlyDropSteps;
    this.gs_earlyStepIdx = 0;
  }

  if this.gs_earlyStepMax < 1 { this.gs_earlyStepMax = 1; }

  t01 = 1.0;
  if this.gs_earlyStepMax > 1 {
    t01 = Cast<Float>(this.gs_earlyStepIdx) / Cast<Float>(this.gs_earlyStepMax - 1);
  }

  w = GS_EaseIn(t01);

  zMagFull = GS_StrengthToZ(s.earlyDropStrengthPct, s);
  fMagFull = 0.0;

  if this.gs_earlyForwardDo {
    fMagFull = GS_StrengthToF(s.earlyDropForwardStrengthPct, s);
  }

  if s.showDebugSettings {
    zMagFull = GS_Pos(s.debugProofZ);
    if this.gs_earlyForwardDo {
      fMagFull = GS_Pos(s.debugProofF);
    }
  }

  w = w * GS_MomentumScale(this, s);

  GS_ApplyVerticalAndForwardMode(this, zMagFull * w, 0.0, s.earlyDropRadiusM, 1.05, s, s.earlyDropForwardUseFacing, s.earlyDropForwardUseCached);
  if this.gs_earlyForwardDo {
    GS_ApplyForwardOnlyMode(this, fMagFull * w, s.earlyDropForwardRadiusM, 1.05, s, s.earlyDropForwardUseFacing, s.earlyDropForwardUseCached);
  }

  this.gs_earlyStepIdx += 1;
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnGS_ImpactStepEvt(e: ref<GS_ImpactStepEvt>) -> Bool {
  let s: ref<GS_Settings> = new GS_Settings();
  let zMagFull: Float;
  let fMagFull: Float;
  let t01: Float;
  let w: Float;
  let fMagUse: Float;

  if !s.enabled { return true; }
  if !s.impactEnabled { return true; }
  if !ScriptedPuppet.CanRagdoll(this) { return true; }
  if !GS_ShouldRun(this, s) { return true; }

  if this.gs_impactStepMax <= 0 {
    this.gs_impactStepMax = s.impactSteps;
    this.gs_impactStepIdx = 0;
  }

  if this.gs_impactStepMax < 1 { this.gs_impactStepMax = 1; }

t01 = 1.0;
if this.gs_impactStepMax > 1 {
  t01 = Cast<Float>(this.gs_impactStepIdx + 1) / Cast<Float>(this.gs_impactStepMax);
}

w = GS_EaseIn(t01);

  zMagFull = GS_StrengthToZ(s.impactStrengthPct, s);
  w = w * GS_MomentumScale(this, s);

  if this.gs_impactForwardDo {
    fMagFull = GS_StrengthToF(s.impactForwardStrengthPct, s);
    fMagUse = fMagFull;
  } else {
    fMagUse = 0.0;
  }

  if s.showDebugSettings && this.gs_impactForwardDo {
    fMagUse = GS_Pos(s.debugProofF);
  }

GS_ApplyBodyOnlyMode(this, zMagFull * w, s.impactRadiusM, 0.95, s);

  // optional forward lane
  if this.gs_impactForwardDo {
    GS_ApplyForwardOnlyMode(this, fMagUse, s.impactForwardRadiusM, 0.95, s, s.impactForwardUseFacing, s.impactForwardUseCached);
  }

  this.gs_impactStepIdx += 1;
  return true;
}
