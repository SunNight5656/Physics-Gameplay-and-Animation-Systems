module RealisticPush


@addField(NPCPuppet) private let shhjm_lastHitValid: Bool;
@addField(NPCPuppet) private let shhjm_lastHitPos: Vector4;
@addField(NPCPuppet) private let shhjm_lastSrcPos: Vector4;
@addField(NPCPuppet) private let shhjm_lastAnchorPos: Vector4;
@addField(NPCPuppet) private let shhjm_lastBodyPart: Int32;


public class SHHJM_Settings {

  // ===========================================================================
  // HIT JOLTS
  // All body-part jolt sections live under one category.
  // ===========================================================================

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.id", "showHitJolts")
  @runtimeProperty("ModSettings.displayName", "Show Hit Jolts")
  @runtimeProperty("ModSettings.description", "Show or hide all hit jolt sections for falling or on-ground ragdolls.")
  public let showHitJolts: Bool = false;

  // ---------------------------------------------------------------------------
  // HEAD
  // ---------------------------------------------------------------------------

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.id", "showHeadSection")
  @runtimeProperty("ModSettings.displayName", "Show Head Jolts")
  @runtimeProperty("ModSettings.description", "Show or hide head hit jolt settings for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showHitJolts")
  public let showHeadSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Enable")
  @runtimeProperty("ModSettings.description", "Turns head hit jolts on or off for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Forward Strength")
  @runtimeProperty("ModSettings.description", "Forward push for head jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "400.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headForwardStrength: Float = 28.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Up Strength")
  @runtimeProperty("ModSettings.description", "Upward lift for head jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headUpStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Down Strength")
  @runtimeProperty("ModSettings.description", "Downward pull for head jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "505.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headDownStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius for head jolts.")
  @runtimeProperty("ModSettings.min", "0.0001")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.0001")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headRadius: Float = 0.0025;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Apply Offset")
  @runtimeProperty("ModSettings.description", "Moves the head impulse apply point inward toward the neck/chest. Higher = less whole-body lever.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.00")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headApplyOffset: Float = 0.55;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Hit Delay")
  @runtimeProperty("ModSettings.description", "Delay after OnHit before the first head jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headHitDelaySec: Float = 0.01;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Death Delay")
  @runtimeProperty("ModSettings.description", "Delay after death before retrying the cached head jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headDeathDelaySec: Float = 0.02;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Wait For Ground")
  @runtimeProperty("ModSettings.description", "Do not allow head jolts during the fall. Wait until the ragdoll is on the ground, then use the hit or death delay before firing.")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headWaitForGround: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Head Ground Wait Max")
  @runtimeProperty("ModSettings.description", "Maximum time to wait for the ragdoll to reach the ground before cancelling the head jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "3.00")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showHeadSection")
  public let headGroundWaitMaxSec: Float = 0.75;

  // ---------------------------------------------------------------------------
  // TORSO
  // ---------------------------------------------------------------------------

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.id", "showTorsoSection")
  @runtimeProperty("ModSettings.displayName", "Show Torso Jolts")
  @runtimeProperty("ModSettings.description", "Show or hide torso hit jolt settings for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showHitJolts")
  public let showTorsoSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Torso Enable")
  @runtimeProperty("ModSettings.description", "Turns torso hit jolts on or off for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showTorsoSection")
  public let torsoEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Torso Forward Strength")
  @runtimeProperty("ModSettings.description", "Forward push for torso jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "400.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showTorsoSection")
  public let torsoForwardStrength: Float = 30.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Torso Up Strength")
  @runtimeProperty("ModSettings.description", "Upward lift for torso jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showTorsoSection")
  public let torsoUpStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Torso Down Strength")
  @runtimeProperty("ModSettings.description", "Downward pull for torso jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showTorsoSection")
  public let torsoDownStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Torso Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius for torso jolts.")
  @runtimeProperty("ModSettings.min", "0.0001")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.0001")
  @runtimeProperty("ModSettings.dependency", "showTorsoSection")
  public let torsoRadius: Float = 0.0040;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Torso Apply Offset")
  @runtimeProperty("ModSettings.description", "Moves the torso impulse apply point inward toward the spine/hips.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.00")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.dependency", "showTorsoSection")
  public let torsoApplyOffset: Float = 0.25;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Torso Hit Delay")
  @runtimeProperty("ModSettings.description", "Delay after OnHit before the first torso jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showTorsoSection")
  public let torsoHitDelaySec: Float = 0.01;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Torso Death Delay")
  @runtimeProperty("ModSettings.description", "Delay after death before retrying the cached torso jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showTorsoSection")
  public let torsoDeathDelaySec: Float = 0.02;

  // ---------------------------------------------------------------------------
  // LEFT ARM
  // ---------------------------------------------------------------------------

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.id", "showLeftArmSection")
  @runtimeProperty("ModSettings.displayName", "Show Left Arm Jolts")
  @runtimeProperty("ModSettings.description", "Show or hide left arm hit jolt settings for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showHitJolts")
  public let showLeftArmSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Arm Enable")
  @runtimeProperty("ModSettings.description", "Turns left arm hit jolts on or off for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showLeftArmSection")
  public let leftArmEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Arm Forward Strength")
  @runtimeProperty("ModSettings.description", "Forward push for left arm jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "400.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showLeftArmSection")
  public let leftArmForwardStrength: Float = 24.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Arm Up Strength")
  @runtimeProperty("ModSettings.description", "Upward lift for left arm jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showLeftArmSection")
  public let leftArmUpStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Arm Down Strength")
  @runtimeProperty("ModSettings.description", "Downward pull for left arm jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showLeftArmSection")
  public let leftArmDownStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Arm Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius for left arm jolts.")
  @runtimeProperty("ModSettings.min", "0.0001")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.0001")
  @runtimeProperty("ModSettings.dependency", "showLeftArmSection")
  public let leftArmRadius: Float = 0.0030;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Arm Apply Offset")
  @runtimeProperty("ModSettings.description", "Moves the left arm impulse apply point inward toward the shoulder.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.00")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.dependency", "showLeftArmSection")
  public let leftArmApplyOffset: Float = 0.35;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Arm Hit Delay")
  @runtimeProperty("ModSettings.description", "Delay after OnHit before the first left arm jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showLeftArmSection")
  public let leftArmHitDelaySec: Float = 0.01;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Arm Death Delay")
  @runtimeProperty("ModSettings.description", "Delay after death before retrying the cached left arm jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showLeftArmSection")
  public let leftArmDeathDelaySec: Float = 0.02;

  // ---------------------------------------------------------------------------
  // RIGHT ARM
  // ---------------------------------------------------------------------------

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.id", "showRightArmSection")
  @runtimeProperty("ModSettings.displayName", "Show Right Arm Jolts")
  @runtimeProperty("ModSettings.description", "Show or hide right arm hit jolt settings for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showHitJolts")
  public let showRightArmSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Arm Enable")
  @runtimeProperty("ModSettings.description", "Turns right arm hit jolts on or off for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showRightArmSection")
  public let rightArmEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Arm Forward Strength")
  @runtimeProperty("ModSettings.description", "Forward push for right arm jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "400.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showRightArmSection")
  public let rightArmForwardStrength: Float = 24.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Arm Up Strength")
  @runtimeProperty("ModSettings.description", "Upward lift for right arm jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showRightArmSection")
  public let rightArmUpStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Arm Down Strength")
  @runtimeProperty("ModSettings.description", "Downward pull for right arm jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showRightArmSection")
  public let rightArmDownStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Arm Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius for right arm jolts.")
  @runtimeProperty("ModSettings.min", "0.0001")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.0001")
  @runtimeProperty("ModSettings.dependency", "showRightArmSection")
  public let rightArmRadius: Float = 0.0030;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Arm Apply Offset")
  @runtimeProperty("ModSettings.description", "Moves the right arm impulse apply point inward toward the shoulder.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.00")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.dependency", "showRightArmSection")
  public let rightArmApplyOffset: Float = 0.35;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Arm Hit Delay")
  @runtimeProperty("ModSettings.description", "Delay after OnHit before the first right arm jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showRightArmSection")
  public let rightArmHitDelaySec: Float = 0.01;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Arm Death Delay")
  @runtimeProperty("ModSettings.description", "Delay after death before retrying the cached right arm jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showRightArmSection")
  public let rightArmDeathDelaySec: Float = 0.02;

  // ---------------------------------------------------------------------------
  // LEFT LEG
  // ---------------------------------------------------------------------------

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.id", "showLeftLegSection")
  @runtimeProperty("ModSettings.displayName", "Show Left Leg Jolts")
  @runtimeProperty("ModSettings.description", "Show or hide left leg hit jolt settings for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showHitJolts")
  public let showLeftLegSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Leg Enable")
  @runtimeProperty("ModSettings.description", "Turns left leg hit jolts on or off for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showLeftLegSection")
  public let leftLegEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Leg Forward Strength")
  @runtimeProperty("ModSettings.description", "Forward push for left leg jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "400.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showLeftLegSection")
  public let leftLegForwardStrength: Float = 26.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Leg Up Strength")
  @runtimeProperty("ModSettings.description", "Upward lift for left leg jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showLeftLegSection")
  public let leftLegUpStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Leg Down Strength")
  @runtimeProperty("ModSettings.description", "Downward pull for left leg jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showLeftLegSection")
  public let leftLegDownStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Leg Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius for left leg jolts.")
  @runtimeProperty("ModSettings.min", "0.0001")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.0001")
  @runtimeProperty("ModSettings.dependency", "showLeftLegSection")
  public let leftLegRadius: Float = 0.0035;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Leg Apply Offset")
  @runtimeProperty("ModSettings.description", "Moves the left leg impulse apply point inward toward the upper leg.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.00")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.dependency", "showLeftLegSection")
  public let leftLegApplyOffset: Float = 0.35;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Leg Hit Delay")
  @runtimeProperty("ModSettings.description", "Delay after OnHit before the first left leg jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showLeftLegSection")
  public let leftLegHitDelaySec: Float = 0.01;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Left Leg Death Delay")
  @runtimeProperty("ModSettings.description", "Delay after death before retrying the cached left leg jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showLeftLegSection")
  public let leftLegDeathDelaySec: Float = 0.02;

  // ---------------------------------------------------------------------------
  // RIGHT LEG
  // ---------------------------------------------------------------------------

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.id", "showRightLegSection")
  @runtimeProperty("ModSettings.displayName", "Show Right Leg Jolts")
  @runtimeProperty("ModSettings.description", "Show or hide right leg hit jolt settings for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showHitJolts")
  public let showRightLegSection: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Leg Enable")
  @runtimeProperty("ModSettings.description", "Turns right leg hit jolts on or off for falling or on-ground ragdolls.")
  @runtimeProperty("ModSettings.dependency", "showRightLegSection")
  public let rightLegEnabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Leg Forward Strength")
  @runtimeProperty("ModSettings.description", "Forward push for right leg jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "400.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showRightLegSection")
  public let rightLegForwardStrength: Float = 26.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Leg Up Strength")
  @runtimeProperty("ModSettings.description", "Upward lift for right leg jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showRightLegSection")
  public let rightLegUpStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Leg Down Strength")
  @runtimeProperty("ModSettings.description", "Downward pull for right leg jolts.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "100.00")
  @runtimeProperty("ModSettings.step", "1.00")
  @runtimeProperty("ModSettings.dependency", "showRightLegSection")
  public let rightLegDownStrength: Float = 0.00;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Leg Radius")
  @runtimeProperty("ModSettings.description", "Impulse radius for right leg jolts.")
  @runtimeProperty("ModSettings.min", "0.0001")
  @runtimeProperty("ModSettings.max", "0.50")
  @runtimeProperty("ModSettings.step", "0.0001")
  @runtimeProperty("ModSettings.dependency", "showRightLegSection")
  public let rightLegRadius: Float = 0.0035;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Leg Apply Offset")
  @runtimeProperty("ModSettings.description", "Moves the right leg impulse apply point inward toward the upper leg.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "1.00")
  @runtimeProperty("ModSettings.step", "0.05")
  @runtimeProperty("ModSettings.dependency", "showRightLegSection")
  public let rightLegApplyOffset: Float = 0.35;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Leg Hit Delay")
  @runtimeProperty("ModSettings.description", "Delay after OnHit before the first right leg jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showRightLegSection")
  public let rightLegHitDelaySec: Float = 0.01;

  @runtimeProperty("ModSettings.mod", "Splat Physics")
  @runtimeProperty("ModSettings.category", "Hit Jolts")
  @runtimeProperty("ModSettings.category.order", "69")
  @runtimeProperty("ModSettings.displayName", "Right Leg Death Delay")
  @runtimeProperty("ModSettings.description", "Delay after death before retrying the cached right leg jolt.")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "0.10")
  @runtimeProperty("ModSettings.step", "0.01")
  @runtimeProperty("ModSettings.dependency", "showRightLegSection")
  public let rightLegDeathDelaySec: Float = 0.02;
}


public class SHHJM_ApplyImpulseEvt extends Event {
  public let pos: Vector4;
  public let imp: Vector4;
  public let radius: Float;
}

public class SHHJM_WaitForGroundEvt extends Event {
  public let srcPos: Vector4;
  public let anchorPos: Vector4;
  public let part: Int32;
  public let fireDelay: Float;
  public let expireAt: Float;
}

public class SHHJM_OnDeathApplyEvt extends Event {}

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
  switch part {
    case 0:
      return s.headWaitForGround;
  };
  return false;
}

private func SHHJM_GetGroundWaitMax(part: Int32, s: ref<SHHJM_Settings>) -> Float {
  switch part {
    case 0:
      return s.headGroundWaitMaxSec;
  };
  return 0.0;
}

private func SHHJM_QueueJolt(puppet: ref<NPCPuppet>, part: Int32, srcPos: Vector4, anchorPos: Vector4, fireDelay: Float, s: ref<SHHJM_Settings>) -> Void {
  let applyEvt: ref<SHHJM_ApplyImpulseEvt>;
  let waitEvt: ref<SHHJM_WaitForGroundEvt>;
  let groundedAnchor: Vector4;

  if !IsDefined(puppet) || !IsDefined(s) {
    return;
  };

  if SHHJM_GetWaitForGround(part, s) && SHHJM_GetGroundWaitMax(part, s) > 0.0 {
    waitEvt = new SHHJM_WaitForGroundEvt();
    waitEvt.srcPos = srcPos;
    waitEvt.anchorPos = anchorPos;
    waitEvt.part = part;
    waitEvt.fireDelay = MaxF(0.001, fireDelay);
    waitEvt.expireAt = SHHJM_Now(puppet) + MaxF(0.0, SHHJM_GetGroundWaitMax(part, s));
    SHHJM_Sched(puppet, waitEvt, 0.001);
    return;
  };

  groundedAnchor = SHHJM_BiasAnchorInwardBySettings(puppet, part, anchorPos, s);

  applyEvt = new SHHJM_ApplyImpulseEvt();
  applyEvt.pos = groundedAnchor;
  applyEvt.imp = SHHJM_BuildImpulse(srcPos, groundedAnchor, part, s);
  applyEvt.radius = SHHJM_GetRadius(part, s);
  SHHJM_Sched(puppet, applyEvt, MaxF(0.001, fireDelay));
}


@addMethod(NPCPuppet)
protected cb func OnSHHJM_WaitForGroundEvt(evt: ref<SHHJM_WaitForGroundEvt>) -> Bool {
  let s: ref<SHHJM_Settings>;
  let retryEvt: ref<SHHJM_WaitForGroundEvt>;
  let applyEvt: ref<SHHJM_ApplyImpulseEvt>;
  let groundedAnchor: Vector4;

  if !IsDefined(evt) {
    return true;
  };

  s = new SHHJM_Settings();
  if !SHHJM_GetPartEnabled(evt.part, s) {
    return true;
  };

  if SHHJM_IsOnGround(this) {
    groundedAnchor = SHHJM_BiasAnchorInwardBySettings(this, evt.part, evt.anchorPos, s);

    applyEvt = new SHHJM_ApplyImpulseEvt();
    applyEvt.pos = groundedAnchor;
    applyEvt.imp = SHHJM_BuildImpulse(evt.srcPos, groundedAnchor, evt.part, s);
    applyEvt.radius = SHHJM_GetRadius(evt.part, s);
    SHHJM_Sched(this, applyEvt, MaxF(0.001, evt.fireDelay));
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
      if SHHJM_GetSlotWorldPos(puppet, n"Neck", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.55); };
      if SHHJM_GetSlotWorldPos(puppet, n"Chest", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.40); };
      break;
    case 1:
      if SHHJM_GetSlotWorldPos(puppet, n"Spine1", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.25); };
      if SHHJM_GetSlotWorldPos(puppet, n"Hips", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.20); };
      break;
    case 2:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftShoulder", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.35); };
      break;
    case 3:
      if SHHJM_GetSlotWorldPos(puppet, n"RightShoulder", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.35); };
      break;
    case 4:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftUpLeg", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.35); };
      break;
    case 5:
      if SHHJM_GetSlotWorldPos(puppet, n"RightUpLeg", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, 0.35); };
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
      if SHHJM_GetSlotWorldPos(puppet, n"Neck", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      if SHHJM_GetSlotWorldPos(puppet, n"Chest", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 1:
      if SHHJM_GetSlotWorldPos(puppet, n"Spine1", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      if SHHJM_GetSlotWorldPos(puppet, n"Hips", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 2:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftShoulder", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 3:
      if SHHJM_GetSlotWorldPos(puppet, n"RightShoulder", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 4:
      if SHHJM_GetSlotWorldPos(puppet, n"LeftUpLeg", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
      break;
    case 5:
      if SHHJM_GetSlotWorldPos(puppet, n"RightUpLeg", targetPos) { return SHHJM_LerpPos(anchorPos, targetPos, t); };
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
    SHHJM_UpdateBestHit(hitPos, 0, pos, 0.0200, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"Neck", pos) {
    SHHJM_UpdateBestHit(hitPos, 0, pos, 0.0200, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"Spine3", pos) {
    SHHJM_UpdateBestHit(hitPos, 1, pos, 0.0450, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"Spine2", pos) {
    SHHJM_UpdateBestHit(hitPos, 1, pos, 0.0450, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"Chest", pos) {
    SHHJM_UpdateBestHit(hitPos, 1, pos, 0.0450, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"LeftShoulder", pos) {
    SHHJM_UpdateBestHit(hitPos, 2, pos, 0.0350, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftArm", pos) {
    SHHJM_UpdateBestHit(hitPos, 2, pos, 0.0350, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftForeArm", pos) {
    SHHJM_UpdateBestHit(hitPos, 2, pos, 0.0350, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftHand", pos) {
    SHHJM_UpdateBestHit(hitPos, 2, pos, 0.0350, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"RightShoulder", pos) {
    SHHJM_UpdateBestHit(hitPos, 3, pos, 0.0350, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightArm", pos) {
    SHHJM_UpdateBestHit(hitPos, 3, pos, 0.0350, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightForeArm", pos) {
    SHHJM_UpdateBestHit(hitPos, 3, pos, 0.0350, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightHand", pos) {
    SHHJM_UpdateBestHit(hitPos, 3, pos, 0.0350, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"LeftUpLeg", pos) {
    SHHJM_UpdateBestHit(hitPos, 4, pos, 0.0400, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftLeg", pos) {
    SHHJM_UpdateBestHit(hitPos, 4, pos, 0.0400, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"LeftFoot", pos) {
    SHHJM_UpdateBestHit(hitPos, 4, pos, 0.0400, bestDistSq, bestPart, bestPos, found);
  };

  if SHHJM_GetSlotWorldPos(puppet, n"RightUpLeg", pos) {
    SHHJM_UpdateBestHit(hitPos, 5, pos, 0.0400, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightLeg", pos) {
    SHHJM_UpdateBestHit(hitPos, 5, pos, 0.0400, bestDistSq, bestPart, bestPos, found);
  };
  if SHHJM_GetSlotWorldPos(puppet, n"RightFoot", pos) {
    SHHJM_UpdateBestHit(hitPos, 5, pos, 0.0400, bestDistSq, bestPart, bestPos, found);
  };

  if found {
    part = bestPart;
    anchorPos = SHHJM_BiasAnchorInward(puppet, bestPart, bestPos);
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
  switch part {
    case 0:
      return s.headRadius;
    case 1:
      return s.torsoRadius;
    case 2:
      return s.leftArmRadius;
    case 3:
      return s.rightArmRadius;
    case 4:
      return s.leftLegRadius;
    case 5:
      return s.rightLegRadius;
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
  switch part {
    case 0:
      return s.headDeathDelaySec;
    case 1:
      return s.torsoDeathDelaySec;
    case 2:
      return s.leftArmDeathDelaySec;
    case 3:
      return s.rightArmDeathDelaySec;
    case 4:
      return s.leftLegDeathDelaySec;
    case 5:
      return s.rightLegDeathDelaySec;
  };
  return 0.02;
}


private func SHHJM_BuildImpulse(srcPos: Vector4, anchorPos: Vector4, part: Int32, s: ref<SHHJM_Settings>) -> Vector4 {
  let dir: Vector4 = SHHJM_NormalizeSafe(anchorPos - srcPos);
  let fwd: Float = SHHJM_GetForwardStrength(part, s);
  let vertical: Float = SHHJM_GetVerticalStrength(part, s);

  if part == 0 {
    let planarDir: Vector4 = SHHJM_NormalizeSafe(new Vector4(anchorPos.X - srcPos.X, anchorPos.Y - srcPos.Y, 0.0, 0.0));
    return new Vector4(planarDir.X * fwd, planarDir.Y * fwd, 0.0, 1.0);
  };

  return new Vector4(dir.X * fwd, dir.Y * fwd, vertical, 1.0);
}

@addMethod(NPCPuppet)
protected cb func OnSHHJM_ApplyImpulseEvt(evt: ref<SHHJM_ApplyImpulseEvt>) -> Bool {
  if !IsDefined(evt) {
    return true;
  };
  this.QueueEvent(CreateRagdollApplyImpulseEvent(evt.pos, evt.imp, evt.radius));
  return true;
}

@addMethod(NPCPuppet)
protected cb func OnSHHJM_OnDeathApplyEvt(evt: ref<SHHJM_OnDeathApplyEvt>) -> Bool {
  let s: ref<SHHJM_Settings>;
  let part: Int32;

  if !this.shhjm_lastHitValid || !this.IsDead() {
    return true;
  };

  s = new SHHJM_Settings();
  part = this.shhjm_lastBodyPart;
  if !SHHJM_GetPartEnabled(part, s) {
    return true;
  };

  this.QueueEvent(CreateForceRagdollEvent(n"SHHJM_DeathRetry"));

  SHHJM_QueueJolt(this, part, this.shhjm_lastSrcPos, this.shhjm_lastAnchorPos, MaxF(0.012, SHHJM_GetDeathDelay(part, s)), s);
  SHHJM_QueueJolt(this, part, this.shhjm_lastSrcPos, this.shhjm_lastAnchorPos, MaxF(0.012, SHHJM_GetDeathDelay(part, s)) + 0.020, s);

  return true;
}
