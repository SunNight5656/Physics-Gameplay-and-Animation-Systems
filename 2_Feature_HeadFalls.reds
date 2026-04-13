module RealisticPush

public class HIS_Settings {
  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.displayName", "Show Section HeadForwardSection")
  @runtimeProperty("ModSettings.description", "Turn this on to show this section in Mod Settings. Turn it off to hide the section.")
  public let showHeadForwardSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Enable")
  @runtimeProperty("ModSettings.description", "Master switch for this section.")
  public let enabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "On Death")
  @runtimeProperty("ModSettings.description", "Fire this lane when death starts.")
  public let onDeath: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "On Impact")
  @runtimeProperty("ModSettings.description", "Fire this lane when the body hits the ground.")
  public let onGroundImpact: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Force Ragdoll First")
  @runtimeProperty("ModSettings.description", "Force ragdoll before this lane applies its impulse steps.")
  public let forceRagdollFirst: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Disable On Ground")
  @runtimeProperty("ModSettings.description", "Stop this lane once the body is considered on the ground.")
  public let disableOnGround: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Disable On Ground Delay")
  @runtimeProperty("ModSettings.description", "Delay before the on ground lockout becomes active.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let disableOnGroundDelay: Float = 0.20;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Kill On Death Delay")
  @runtimeProperty("ModSettings.description", "Delay before this lane is killed after death starts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let headKillOnDeathDelay: Float = 0.30;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Direction Min")
  @runtimeProperty("ModSettings.description", "Minimum forward movement needed before the forward head lane is allowed to fire.")
  @runtimeProperty("ModSettings.min", "0.0000")
  @runtimeProperty("ModSettings.max", "7.00")
  @runtimeProperty("ModSettings.step", "0.00001")
  public let directionMin: Float = 0.00001;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Forward/Back Min")
  @runtimeProperty("ModSettings.description", "Minimum forward or backward impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let forwardBackMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Forward/Back Max")
  @runtimeProperty("ModSettings.description", "Maximum forward or backward impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let forwardBackMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Side Min")
  @runtimeProperty("ModSettings.description", "Minimum left or right impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let leftRightMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Side Max")
  @runtimeProperty("ModSettings.description", "Maximum left or right impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let leftRightMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Up/Down Min")
  @runtimeProperty("ModSettings.description", "Minimum vertical impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let upDownMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Up/Down Max")
  @runtimeProperty("ModSettings.description", "Maximum vertical impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let upDownMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Chance %")
  @runtimeProperty("ModSettings.description", "Chance for this lane to fire when its trigger happens.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "1")
  public let chancePct: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius used for this lane.")
  @runtimeProperty("ModSettings.min", "0.01")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let radius: Float = 0.04;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Head Target Offset")
  @runtimeProperty("ModSettings.description", "Moves the impulse point along the Neck to Head direction. Positive moves it higher, toward the top or front of the head. Negative moves it lower, back down toward the neck or deeper into the head.")
  @runtimeProperty("ModSettings.min", "-0.30")
  @runtimeProperty("ModSettings.max", "0.30")
  @runtimeProperty("ModSettings.step", "0.01")
  public let headTargetOffset: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Delay")
  @runtimeProperty("ModSettings.description", "Delay before the first impulse step in this lane.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "4.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let delaySec: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Steps")
  @runtimeProperty("ModSettings.description", "Number of impulse steps used by this lane.")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "20")
  @runtimeProperty("ModSettings.step", "1")
  public let steps: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Step Delay")
  @runtimeProperty("ModSettings.description", "Delay between impulse steps.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "4.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let stepDelay: Float = 0.03;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showHeadForwardSection")
  @runtimeProperty("ModSettings.displayName", "Ramp Mode")
  @runtimeProperty("ModSettings.description", "Shape used to scale the impulse across steps.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "4")
  @runtimeProperty("ModSettings.step", "1")
  public let rampMode: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.displayName", "Show ReboundForwardSection")
  @runtimeProperty("ModSettings.description", "Turn this on to show this section in Mod Settings. Turn it off to hide the section.")
  public let showReboundForwardSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Enable")
  @runtimeProperty("ModSettings.description", "Master switch for this section.")
  public let enableRebound: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Wait For Head Impulse")
  @runtimeProperty("ModSettings.description", "Only allow rebound after the main forward head impulse has fired.")
  public let reboundRequiresHeadImpulse: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "On Impact")
  @runtimeProperty("ModSettings.description", "Fire this lane when the body hits the ground.")
  public let reboundOnImpact: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Disable On Ground")
  @runtimeProperty("ModSettings.description", "Stop this lane once the body is considered on the ground.")
  public let reboundDisableOnGround: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Disable On Ground Delay")
  @runtimeProperty("ModSettings.description", "Delay before the on ground lockout becomes active.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundDisableOnGroundDelay: Float = 0.35;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Kill On Death Delay")
  @runtimeProperty("ModSettings.description", "Delay before this lane is killed after death starts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundKillOnDeathDelay: Float = 0.50;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Forward/Back Min")
  @runtimeProperty("ModSettings.description", "Minimum forward or backward impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundForwardMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Direction Min")
  @runtimeProperty("ModSettings.description", "Minimum movement in the lane direction required before the lane can fire.")
  @runtimeProperty("ModSettings.min", "0.00001")
  @runtimeProperty("ModSettings.max", "7.00")
  @runtimeProperty("ModSettings.step", "0.00001")
  public let reboundDirectionMin: Float = 0.00001;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Forward/Back Max")
  @runtimeProperty("ModSettings.description", "Maximum forward or backward impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundForwardMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Side Min")
  @runtimeProperty("ModSettings.description", "Minimum left or right impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundSideMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Side Max")
  @runtimeProperty("ModSettings.description", "Maximum left or right impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundSideMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Up/Down Min")
  @runtimeProperty("ModSettings.description", "Minimum vertical impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundUpMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Up/Down Max")
  @runtimeProperty("ModSettings.description", "Maximum vertical impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundUpMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Chance %")
  @runtimeProperty("ModSettings.description", "Chance for this lane to fire when its trigger happens.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "1")
  public let reboundChancePct: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius used for this lane.")
  @runtimeProperty("ModSettings.min", "0.01")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundRadius: Float = 0.04;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Delay")
  @runtimeProperty("ModSettings.description", "Delay before the first impulse step in this lane.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "4.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundDelay: Float = 0.03;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Steps")
  @runtimeProperty("ModSettings.description", "Number of impulse steps used by this lane.")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "20")
  @runtimeProperty("ModSettings.step", "1")
  public let reboundSteps: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Step Delay")
  @runtimeProperty("ModSettings.description", "Delay between impulse steps.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "4.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let reboundStepDelay: Float = 0.03;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
  @runtimeProperty("ModSettings.category.order", "6")
  @runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
  @runtimeProperty("ModSettings.displayName", "Ramp Mode")
  @runtimeProperty("ModSettings.description", "Shape used to scale the impulse across steps.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "4")
  @runtimeProperty("ModSettings.step", "1")
  public let reboundRampMode: Int32 = 1;

@runtimeProperty("ModSettings.mod", "Splat Physics")
@runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
@runtimeProperty("ModSettings.category.order", "6")
@runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
@runtimeProperty("ModSettings.displayName", "Use Neck Fold Gate")
@runtimeProperty("ModSettings.description", "Gate forward rebound using neck movement relative to chest instead of torso drop.")
public let reboundUseNeckFoldGate: Bool = true;

@runtimeProperty("ModSettings.mod", "Splat Physics")
@runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
@runtimeProperty("ModSettings.category.order", "6")
@runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
@runtimeProperty("ModSettings.displayName", "Neck Fold Min")
@runtimeProperty("ModSettings.description", "Minimum forward neck fold relative to chest before forward rebound can fire.")
@runtimeProperty("ModSettings.min", "0.00")
@runtimeProperty("ModSettings.max", "2.00")
@runtimeProperty("ModSettings.step", "0.01")
public let reboundNeckFoldMin: Float = 0.10;

@runtimeProperty("ModSettings.mod", "Splat Physics")
@runtimeProperty("ModSettings.category", "Rebound Head: Falling Forward")
@runtimeProperty("ModSettings.category.order", "6")
@runtimeProperty("ModSettings.dependency", "showReboundForwardSection")
@runtimeProperty("ModSettings.displayName", "Neck Drop Min")
@runtimeProperty("ModSettings.description", "Minimum neck height drop from the captured start before forward rebound can fire.")
@runtimeProperty("ModSettings.min", "0.00")
@runtimeProperty("ModSettings.max", "2.00")
@runtimeProperty("ModSettings.step", "0.01")
public let reboundNeckDropMin: Float = 0.05;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.displayName", "Show HeadBackSection")
  @runtimeProperty("ModSettings.description", "Turn this on to show this section in Mod Settings. Turn it off to hide the section.")
  public let showHeadBackSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Enable")
  @runtimeProperty("ModSettings.description", "Master switch for this section.")
  public let backEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "On Death")
  @runtimeProperty("ModSettings.description", "Fire this lane when death starts.")
  public let backOnDeath: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "On Impact")
  @runtimeProperty("ModSettings.description", "Fire this lane when the body hits the ground.")
  public let backOnGroundImpact: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Disable On Ground")
  @runtimeProperty("ModSettings.description", "Stop this lane once the body is considered on the ground.")
  public let backDisableOnGround: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Disable On Ground Delay")
  @runtimeProperty("ModSettings.description", "Delay before the on ground lockout becomes active.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backDisableOnGroundDelay: Float = 0.20;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Kill On Death Delay")
  @runtimeProperty("ModSettings.description", "Delay before this lane is killed after death starts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backKillOnDeathDelay: Float = 0.30;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Force Ragdoll First")
  @runtimeProperty("ModSettings.description", "Force ragdoll before this lane applies its impulse steps.")
  public let backForceRagdollFirst: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Direction Min")
  @runtimeProperty("ModSettings.description", "Minimum movement in the lane direction required before the lane can fire.")
  @runtimeProperty("ModSettings.min", "0.00001")
  @runtimeProperty("ModSettings.max", "7.00")
  @runtimeProperty("ModSettings.step", "0.00001")
  public let backDirectionMin: Float = 0.00001;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Forward/Back Min")
  @runtimeProperty("ModSettings.description", "Minimum forward or backward impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backForwardBackMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Forward/Back Max")
  @runtimeProperty("ModSettings.description", "Maximum forward or backward impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backForwardBackMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Side Min")
  @runtimeProperty("ModSettings.description", "Minimum left or right impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backLeftRightMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Side Max")
  @runtimeProperty("ModSettings.description", "Maximum left or right impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backLeftRightMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Up/Down Min")
  @runtimeProperty("ModSettings.description", "Minimum vertical impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backUpDownMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Up/Down Max")
  @runtimeProperty("ModSettings.description", "Maximum vertical impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backUpDownMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Chance %")
  @runtimeProperty("ModSettings.description", "Chance for this lane to fire when its trigger happens.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "1")
  public let backChancePct: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius used for this lane.")
  @runtimeProperty("ModSettings.min", "0.01")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backRadius: Float = 0.04;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Delay")
  @runtimeProperty("ModSettings.description", "Delay before the first impulse step in this lane.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "4.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backDelaySec: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Steps")
  @runtimeProperty("ModSettings.description", "Number of impulse steps used by this lane.")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "20")
  @runtimeProperty("ModSettings.step", "1")
  public let backSteps: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Step Delay")
  @runtimeProperty("ModSettings.description", "Delay between impulse steps.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "4.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backStepDelay: Float = 0.03;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "7")
  @runtimeProperty("ModSettings.dependency", "showHeadBackSection")
  @runtimeProperty("ModSettings.displayName", "Ramp Mode")
  @runtimeProperty("ModSettings.description", "Shape used to scale the impulse across steps.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "4")
  @runtimeProperty("ModSettings.step", "1")
  public let backRampMode: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.displayName", "Show ReboundBackSection")
  @runtimeProperty("ModSettings.description", "Turn this on to show this section in Mod Settings. Turn it off to hide the section.")
  public let showReboundBackSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Enable")
  @runtimeProperty("ModSettings.description", "Master switch for this section.")
  public let enableBackRebound: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Wait For Back Head Impulse")
  @runtimeProperty("ModSettings.description", "Only allow rebound after the main back head impulse has fired.")
  public let backReboundRequiresHeadImpulse: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "On Impact")
  @runtimeProperty("ModSettings.description", "Fire this lane when the body hits the ground.")
  public let backReboundOnImpact: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Disable On Ground")
  @runtimeProperty("ModSettings.description", "Stop this lane once the body is considered on the ground.")
  public let backReboundDisableOnGround: Bool = false;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Disable On Ground Delay")
  @runtimeProperty("ModSettings.description", "Delay before the on ground lockout becomes active.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundDisableOnGroundDelay: Float = 0.35;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Kill On Death Delay")
  @runtimeProperty("ModSettings.description", "Delay before this lane is killed after death starts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.50")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundKillOnDeathDelay: Float = 0.50;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Direction Min")
  @runtimeProperty("ModSettings.description", "Minimum movement in the lane direction required before the lane can fire.")
  @runtimeProperty("ModSettings.min", "0.00001")
  @runtimeProperty("ModSettings.max", "7.00")
  @runtimeProperty("ModSettings.step", "0.00001")
  public let backReboundDirectionMin: Float = 0.00001;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Forward/Back Min")
  @runtimeProperty("ModSettings.description", "Minimum forward or backward impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundForwardMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Forward/Back Max")
  @runtimeProperty("ModSettings.description", "Maximum forward or backward impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundForwardMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Side Min")
  @runtimeProperty("ModSettings.description", "Minimum left or right impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-200.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundSideMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Side Max")
  @runtimeProperty("ModSettings.description", "Maximum left or right impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-200.00")
  @runtimeProperty("ModSettings.max", "200.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundSideMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Up/Down Min")
  @runtimeProperty("ModSettings.description", "Minimum vertical impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundUpMin: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Up/Down Max")
  @runtimeProperty("ModSettings.description", "Maximum vertical impulse value for this lane.")
  @runtimeProperty("ModSettings.min", "-600.00")
  @runtimeProperty("ModSettings.max", "600.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundUpMax: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Chance %")
  @runtimeProperty("ModSettings.description", "Chance for this lane to fire when its trigger happens.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "1")
  public let backReboundChancePct: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius used for this lane.")
  @runtimeProperty("ModSettings.min", "0.01")
  @runtimeProperty("ModSettings.max", "2.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundRadius: Float = 0.04;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Delay")
  @runtimeProperty("ModSettings.description", "Delay before the first impulse step in this lane.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "4.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundDelay: Float = 0.03;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Steps")
  @runtimeProperty("ModSettings.description", "Number of impulse steps used by this lane.")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "20")
  @runtimeProperty("ModSettings.step", "1")
  public let backReboundSteps: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Step Delay")
  @runtimeProperty("ModSettings.description", "Delay between impulse steps.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "4.00")
  @runtimeProperty("ModSettings.step", "0.01")
  public let backReboundStepDelay: Float = 0.03;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Rebound Head: Falling Back")
  @runtimeProperty("ModSettings.category.order", "8")
  @runtimeProperty("ModSettings.dependency", "showReboundBackSection")
  @runtimeProperty("ModSettings.displayName", "Ramp Mode")
  @runtimeProperty("ModSettings.description", "Shape used to scale the impulse across steps.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "4")
  @runtimeProperty("ModSettings.step", "1")
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
}

@addField(NPCPuppet)
private let hisStartNeckPos: Vector4;

@addField(NPCPuppet)
private let hisStartChestPos: Vector4;

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

private static func HIS_ShouldRun(p: wref<NPCPuppet>, s: ref<HIS_Settings>) -> Bool {
  if !IsDefined(p) { return false; };
  if !IsDefined(s) { return false; };
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

private static func HIS_GetChestPos(p: wref<NPCPuppet>, out chestPos: Vector4) -> Bool {
  let slotComponent = p.GetSlotComponent();
  let chestTransform: WorldTransform;
  let ok: Bool;

  if !IsDefined(slotComponent) { return false; };

  ok = slotComponent.GetSlotTransform(n"Chest", chestTransform);
  if !ok { ok = slotComponent.GetSlotTransform(n"Spine3", chestTransform); };
  if !ok { ok = slotComponent.GetSlotTransform(n"Neck", chestTransform); };
  if !ok { return false; };

  chestPos = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(chestTransform));
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

private static func HIS_LaneMinOk(dirF: Float, minAbs: Float, lane: Int32) -> Bool {
  let need: Float = MaxF(0.0, minAbs);
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
    w = HIS_GetStepWeight(stepIndex, Max(1, s.backSteps), s.backRampMode);
    dirMin = s.backDirectionMin;
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

  if !HIS_LaneMinOk(dirF, dirMin, lane) {
    p.hisPrevHeadPos = headNow;
    p.hisPrevUpperPos = upperNow;
    return Vector4(0.0, 0.0, 0.0, 0.0);
  };

  if lane == 0 {
    fwd = HIS_PickRange(s.forwardBackMin, s.forwardBackMax) * HIS_Sign(dirF);
    side = HIS_PickRange(s.leftRightMin, s.leftRightMax) * HIS_Sign(dirS);
    vert = HIS_PickRange(s.upDownMin, s.upDownMax);
  } else {
    fwd = HIS_PickRange(s.backForwardBackMin, s.backForwardBackMax) * HIS_Sign(dirF);
    side = HIS_PickRange(s.backLeftRightMin, s.backLeftRightMax) * HIS_Sign(dirS);
    vert = HIS_PickRange(s.backUpDownMin, s.backUpDownMax);
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
  out.W = 0.0;
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

  let neckNow: Vector4;
  let chestNow: Vector4;
  let neckRelStart: Vector4;
  let neckRelNow: Vector4;
  let neckFoldVec: Vector4;
  let neckFoldF: Float;
  let neckDrop: Float;

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
    if s.reboundUseNeckFoldGate {
      if !HIS_GetNeckPos(p, neckNow) {
        neckNow = headNow;
      };
      if !HIS_GetChestPos(p, chestNow) {
        chestNow = upperNow;
      };

      neckRelStart = p.hisStartNeckPos - p.hisStartChestPos;
      neckRelNow = neckNow - chestNow;
      neckFoldVec = neckRelNow - neckRelStart;

      neckFoldF = Vector4.Dot(neckFoldVec, p.hisBasisForward);
      neckDrop = p.hisStartNeckPos.Z - neckNow.Z;

      if neckFoldF < s.reboundNeckFoldMin {
        p.hisPrevHeadPos = headNow;
        p.hisPrevUpperPos = upperNow;
        return Vector4(0.0, 0.0, 0.0, 0.0);
      };

      if neckDrop < s.reboundNeckDropMin {
        p.hisPrevHeadPos = headNow;
        p.hisPrevUpperPos = upperNow;
        return Vector4(0.0, 0.0, 0.0, 0.0);
      };
    };

    if !HIS_LaneMinOk(dirF, s.reboundDirectionMin, 0) {
      p.hisPrevHeadPos = headNow;
      p.hisPrevUpperPos = upperNow;
      return Vector4(0.0, 0.0, 0.0, 0.0);
    };

    fwd = HIS_PickRange(s.reboundForwardMin, s.reboundForwardMax) * HIS_Sign(dirF) * -1.0;
    side = HIS_PickRange(s.reboundSideMin, s.reboundSideMax) * HIS_Sign(dirS) * -1.0;
    vert = HIS_PickRange(s.reboundUpMin, s.reboundUpMax);
  } else {
    if !HIS_LaneMinOk(dirF, s.backReboundDirectionMin, 1) {
      p.hisPrevHeadPos = headNow;
      p.hisPrevUpperPos = upperNow;
      return Vector4(0.0, 0.0, 0.0, 0.0);
    };

    fwd = HIS_PickRange(s.backReboundForwardMin, s.backReboundForwardMax) * HIS_Sign(dirF) * -1.0;
    side = HIS_PickRange(s.backReboundSideMin, s.backReboundSideMax) * HIS_Sign(dirS) * -1.0;
    vert = HIS_PickRange(s.backReboundUpMin, s.backReboundUpMax);
  };

  p.hisPrevHeadPos = headNow;
  p.hisPrevUpperPos = upperNow;

  out = p.hisBasisForward * (fwd * w);
  out += p.hisBasisRight * (side * w);
  out += up * (vert * w);
  out.W = 0.0;
  return out;
}
private static func HIS_SendRaw(p: wref<NPCPuppet>, s: ref<HIS_Settings>, radius: Float, impulse: Vector4) -> Void {
  let headPos: Vector4;
  if !IsDefined(p) { return; };
  if !HIS_GetHeadTargetPos(p, s, headPos) { return; };
  p.QueueEvent(CreateRagdollApplyImpulseEvent(headPos, impulse, radius));
}

private static func HIS_SendStep(p: wref<NPCPuppet>, s: ref<HIS_Settings>, stepIndex: Int32, lane: Int32) -> Void {
  if lane == 0 {
    HIS_SendRaw(p, s, s.radius, HIS_BuildImpulseForStep(p, s, stepIndex, lane));
    p.hisHeadImpulseFired = true;
  } else {
    HIS_SendRaw(p, s, s.backRadius, HIS_BuildImpulseForStep(p, s, stepIndex, lane));
    p.hisBackHeadImpulseFired = true;
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
  // keep stored positions so rebound can read follow-through motion
  if !HIS_GetHeadPos(p, p.hisPrevHeadPos) { };
  if !HIS_GetUpperPos(p, p.hisPrevUpperPos) { p.hisPrevUpperPos = p.hisPrevHeadPos; };
  p.hisHeadTriggered = false;
  p.hisHeadMoveSeeded = false;
  ds = GameInstance.GetDelaySystem(p.GetGame());


  if !HIS_GetNeckPos(p, p.hisStartNeckPos) { p.hisStartNeckPos = p.hisPrevHeadPos; };
  if !HIS_GetChestPos(p, p.hisStartChestPos) { p.hisStartChestPos = p.hisPrevUpperPos; };

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
  let s: ref<HIS_Settings> = new HIS_Settings();
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

@addMethod(NPCPuppet)
protected cb func OnHIS_ReboundEvt(evt: ref<HIS_ReboundEvt>) -> Bool {
  let s: ref<HIS_Settings> = new HIS_Settings();
  let ds: ref<DelaySystem>;
  let retryEvt: ref<HIS_ReboundEvt>;
  if !HIS_ShouldRun(this, s) { return true; };
  if evt.lane == 0 {
    if !s.enableRebound { return true; };
    if s.reboundRequiresHeadImpulse && !this.hisHeadImpulseFired {
      ds = GameInstance.GetDelaySystem(this.GetGame());
      if IsDefined(ds) {
        retryEvt = new HIS_ReboundEvt();
        retryEvt.stepIndex = evt.stepIndex;
        retryEvt.lane = evt.lane;
        ds.DelayEvent(this, retryEvt, 0.01, false);
      };
      return true;
    };
    if HIS_DeathGateActive(s.reboundDelay, s.reboundStepDelay, evt.stepIndex, s.reboundKillOnDeathDelay) && s.reboundDisableOnGround && HIS_IsOnGround(this) && HIS_GroundGateActive(s.reboundDelay, s.reboundStepDelay, evt.stepIndex, s.reboundDisableOnGroundDelay) { return true; };
  } else {
    if !s.enableBackRebound { return true; };
    if s.backReboundRequiresHeadImpulse && !this.hisBackHeadImpulseFired {
      ds = GameInstance.GetDelaySystem(this.GetGame());
      if IsDefined(ds) {
        retryEvt = new HIS_ReboundEvt();
        retryEvt.stepIndex = evt.stepIndex;
        retryEvt.lane = evt.lane;
        ds.DelayEvent(this, retryEvt, 0.01, false);
      };
      return true;
    };
    if HIS_DeathGateActive(s.backReboundDelay, s.backReboundStepDelay, evt.stepIndex, s.backReboundKillOnDeathDelay) && s.backReboundDisableOnGround && HIS_IsOnGround(this) && HIS_GroundGateActive(s.backReboundDelay, s.backReboundStepDelay, evt.stepIndex, s.backReboundDisableOnGroundDelay) { return true; };
  };
  HIS_SendReboundStep(this, s, evt.stepIndex, evt.lane);
  return true;
}