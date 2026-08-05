// SPLAT direct settings data (no Mod Settings dependency)
// Menu: Splat Physics
module RealisticPush

public class RFCModSettings {

  public let splatPresetMode: RFCSplatPresetMode = RFCSplatPresetMode.Realism;

public let masterDeathChancePct: Float = 94.000000;

  // Suppress SPLAT-added impulses during Sandevistan/Kerenzikov/scripted slow
  // motion without changing the configured death-animation/ragdoll handoff.
  public let disableAllImpulsesDuringTimeDilation: Bool = true;

  public let showGlobal: Bool = false;


  public let showAnimationControls: Bool = false;

  // Move NPCs Corpse w/Feet - advanced Global controls
  public let showDetector: Bool = false;

  public let enabled: Bool = true;

  public let showAdvancedMoveNPCsCorpseWithFeet: Bool = false;

  public let contactDistM: Float = 0.95;

  public let minSpeedMps: Float = 1.0;

  public let pushXY: Float = 7.0;

  public let downZ: Float = 3.0;

  public let intervalSec: Float = 0.06;

  public let stickyNearbyRadiusM: Float = 2.5;

  public let movingIntoDot: Float = 0.15;

  public let settleTimeSec: Float = 0.2;

  public let sideXY: Float = 1.25;

  public let liftZ: Float = 0.0;

  public let radius: Float = 1.15;

  public let impactPauseSec: Float = 0.02;

  public let cooldownSec: Float = 0.25;


  public let splatVersion110Top: Bool = false;

  public let showing: Bool = false;

  public let hide: Bool = false;


  public let showrealismPreset: Bool = true;

  public let showRealismPlusPreset: Bool = false;

  public let showdirtyPreset: Bool = false;

  public let showarnoldPreset: Bool = false;

  public let customShowHeadFalls: Bool = false;

  public let customShowBodyFalls: Bool = false;

public let shoulderHipFallsEnabled: Bool = true;

public let shoulderHipEarlyShoulderEnabled: Bool = true;

public let shoulderHipEarlyButtEnabled: Bool = true;

public let shoulderHipImpactShoulderEnabled: Bool = true;

public let shoulderHipImpactButtEnabled: Bool = true;

public let showShoulderWaistEarlyFalls: Bool = false;

  public let shoulderHipEarlyShoulderStrength: Float = 1.0;
  public let shoulderHipEarlyShoulderStrengthMin: Float = 1.0;

  public let shoulderHipEarlyHipStrength: Float = 1.0;
  public let shoulderHipEarlyHipStrengthMin: Float = 1.0;

  public let shoulderHipEarlyDelay: Float = 0.05;

  public let shoulderHipEarlyRadius: Float = 0.85;

public let showShoulderWaistImpactFalls: Bool = false;

  public let shoulderHipImpactShoulderStrength: Float = 4.0;
  public let shoulderHipImpactShoulderStrengthMin: Float = 4.0;

  public let shoulderHipImpactHipStrength: Float = 4.0;
  public let shoulderHipImpactHipStrengthMin: Float = 4.0;

  public let shoulderHipImpactDelay: Float = 0.045;

  public let shoulderHipImpactRadius: Float = 1.0;

public let showSituationSliders: Bool = false;

  // Random Impulses - per-mode controls. Existing physics values remain the
  // authoritative maxima; matching Min fields define the lower bounds.
  public let randomImpulsesEnabled: Bool = false;
  public let randomImpulseChancePct: Float = 100.000000;
  public let randomDisableGroupsEnabled: Bool = false;
  public let randomDisableChancePct: Float = 50.000000;
  public let randomMaxDisabledGroups: Int32 = 1;

  public let randomPoolHead: Bool = true;
  public let randomCanDisableHead: Bool = true;
  public let randomPoolBody: Bool = true;
  public let randomCanDisableBody: Bool = true;
  public let randomPoolShoulderWaist: Bool = true;
  public let randomCanDisableShoulderWaist: Bool = true;
  public let randomPoolSituational: Bool = true;
  public let randomCanDisableSituational: Bool = true;

  public let showSituationLegacyFields: Bool = false;

  public let st_d_headBias: Float = 0.000000;

  public let st_downHead: Float = 0.000000;
  public let st_downHeadMin: Float = 0.000000;

  public let st_d_headSlam: Float = 0.000000;

  public let cow_overrideGlobalForward: Bool = false;

  public let cow_overrideGlobalKnees: Bool = false;

  public let cow_overrideGlobalPelvis: Bool = false;

  public let cow_downHead: Float = 0.000000;
  public let cow_downHeadMin: Float = 0.000000;

  public let cow_headDelay: Float = 0.000000;

  public let cow_headRadius: Float = 0.000000;

  public let cow_downPelvis: Float = 0.000000;
  public let cow_downPelvisMin: Float = 0.000000;

  public let cow_pelvisDelay: Float = 0.000000;

  public let cow_pelvisRadius: Float = 0.000000;

  public let cow_antiTuckZ: Float = 0.000000;
  public let cow_antiTuckZMin: Float = 0.000000;

  public let cow_antiTuckDelay: Float = 0.000000;

  public let cow_antiTuckRadius: Float = 0.000000;

  public let stair_overrideGlobalKnees: Bool = false;

  public let stair_overrideGlobalPelvis: Bool = false;

  public let stair_headFwd: Float = 0.000000;
  public let stair_headFwdMin: Float = 0.000000;

  public let stair_downHead: Float = 0.000000;
  public let stair_downHeadMin: Float = 0.000000;

  public let stair_downPelvis: Float = 0.000000;
  public let stair_downPelvisMin: Float = 0.000000;

  public let stair_vSlamZ: Float = 0.000000;
  public let stair_vSlamZMin: Float = 0.000000;

  public let stair_brakeFwd: Float = 0.000000;
  public let stair_brakeFwdMin: Float = 0.000000;

  public let stair_brakeDelay: Float = 0.000000;

  public let stair_brakeRadius: Float = 0.000000;

  public let stair_plankEnabled: Bool = false;

  public let stair_plankDownHead: Float = 0.000000;
  public let stair_plankDownHeadMin: Float = 0.000000;

  public let stair_plankDownChest: Float = 0.000000;
  public let stair_plankDownChestMin: Float = 0.000000;

  public let stair_plankDownPelvis: Float = 0.000000;
  public let stair_plankDownPelvisMin: Float = 0.000000;

  public let stair_plankFwd: Float = 0.000000;
  public let stair_plankFwdMin: Float = 0.000000;

  public let stair_plankDelay: Float = 0.000000;

  public let stair_plankRadius: Float = 0.000000;

  public let stair_plankBrakeFwd: Float = 0.000000;
  public let stair_plankBrakeFwdMin: Float = 0.000000;

  public let stair_plankBrakeDelay: Float = 0.000000;

  public let stair_plankBrakeRadius: Float = 0.000000;

  public let stair_runUseKnees: Bool = false;

  public let standEnabled: Bool = true;

  public let overrideStand: Bool = true;
  public let st_overrideGlobalHead: Bool = false;

  public let st_overrideGlobalForward: Bool = false;

  public let st_forward: Float = 0.980000;
  public let st_forwardMin: Float = 0.980000;
  public let st_forwardRadius: Float = 0.700000;
  public let st_headRadius: Float = 0.700000;
  public let st_chestRadius: Float = 0.700000;
  public let st_pelvisRadius: Float = 0.700000;
  public let st_kneeRadius: Float = 0.700000;

  public let st_forwardDelay: Float = 0.026000;

  public let st_overrideGlobalChest: Bool = false;

  public let st_overrideGlobalPelvis: Bool = false;

  public let st_downChest: Float = 0.000000;
  public let st_downChestMin: Float = 0.000000;

  public let st_d_chestFall: Float = 0.365000;

  public let st_kneeDown: Float = 0.000000;
  public let st_kneeDownMin: Float = 0.000000;

  public let st_d_knee: Float = 0.000000;

  public let st_downPelvis: Float = 0.000000;
  public let st_downPelvisMin: Float = 0.000000;

  public let st_d_pelvisFall: Float = 0.000000;

  public let runEnabled: Bool = true;

  public let overrideRun: Bool = true;
  public let run_overrideGlobalHead: Bool = false;

  public let run_anchorOffset: Float = 45.234001;

  public let run_anchorFwd: Float = 0.000000;

  public let run_anchorDown: Float = 40.739998;

  public let run_anchorRadius: Float = 0.000000;

  public let run_overrideGlobalForward: Bool = false;

  public let run_forward: Float = 0.000000;
  public let run_forwardMin: Float = 0.000000;
  public let run_forwardRadius: Float = 0.700000;
  public let run_headRadius: Float = 1.700000;
  public let run_chestRadius: Float = 0.700000;
  public let run_pelvisRadius: Float = 0.700000;
  public let run_kneeRadius: Float = 0.550000;
  public let run_vSlamRadius: Float = 0.980000;

  public let run_forwardDelay: Float = 0.000000;

  public let run_overrideGlobalChest: Bool = false;

  public let run_overrideGlobalPelvis: Bool = false;

  public let run_downChest: Float = 33.869999;
  public let run_downChestMin: Float = 33.869999;

  public let run_d_chestFall: Float = 0.029000;

  public let run_kneeDown: Float = 0.000000;
  public let run_kneeDownMin: Float = 0.000000;

  public let run_d_knee: Float = 0.120000;

  public let run_downPelvis: Float = 0.000000;
  public let run_downPelvisMin: Float = 0.000000;

  public let run_d_pelvisFall: Float = 0.000000;

  public let wsStandEnabled: Bool = true;

  public let overrideWorkSpots: Bool = true;

  public let wsStand_overrideGlobalForward: Bool = false;

  public let wsStand_pelvisFwd: Float = 1.060000;
  public let wsStand_pelvisFwdMin: Float = 1.060000;

  public let wsStand_overrideGlobalChest: Bool = true;

  public let wsStand_overrideGlobalPelvis: Bool = false;

  public let wsStand_chestFwd: Float = 1.310000;
  public let wsStand_chestFwdMin: Float = 1.310000;

  public let wsStand_chestDown: Float = 2.410000;
  public let wsStand_chestDownMin: Float = 2.410000;

  public let wsStand_chestDelay: Float = 0.100000;

  public let wsStand_chestRadius: Float = 0.800000;

  public let wsStand_kneeDown: Float = 0.000000;
  public let wsStand_kneeDownMin: Float = 0.000000;

  public let wsStand_kneeDelay: Float = 0.120000;

  public let wsStand_kneeRadius: Float = 0.450000;

  public let wsStand_pelvisDown: Float = 0.000000;
  public let wsStand_pelvisDownMin: Float = 0.000000;

  public let wsStand_pelvisDelay: Float = 0.000000;

  public let cowerEnabled: Bool = false;

  public let overrideCower: Bool = false;
  public let cow_overrideGlobalHead: Bool = false;

  public let cow_overrideGlobalChest: Bool = false;

  public let cow_downChest: Float = 5.000000;
  public let cow_downChestMin: Float = 5.000000;

  public let cow_chestDelay: Float = 0.060000;

  public let cow_chestRadius: Float = 0.850000;

  public let cow_kneeDown: Float = 2.000000;
  public let cow_kneeDownMin: Float = 2.000000;

  public let cow_kneeDelay: Float = 0.120000;

  public let cow_kneeRadius: Float = 0.350000;

  public let stairsEnabled: Bool = false;

  public let overrideStairs: Bool = false;
  public let stair_overrideGlobalHead: Bool = false;

  public let stair_overrideGlobalForward: Bool = false;

  public let stair_forward: Float = 0.000000;
  public let stair_forwardMin: Float = 0.000000;
  public let stair_forwardRadius: Float = 0.700000;
  public let stair_headRadius: Float = 0.700000;
  public let stair_chestRadius: Float = 0.700000;
  public let stair_pelvisRadius: Float = 0.700000;

  public let stair_overrideGlobalChest: Bool = false;

  public let stair_chestFwd: Float = 0.000000;
  public let stair_chestFwdMin: Float = 0.000000;

  public let stair_downChest: Float = 0.000000;
  public let stair_downChestMin: Float = 0.000000;

  public let stair_kneeDown: Float = 0.000000;
  public let stair_kneeDownMin: Float = 0.000000;

  public let stair_kneeDelay: Float = 0.000000;

  public let stair_kneeRadius: Float = 0.000000;

  public let showGravity: Bool = false;

  public let gravityEnabled: Bool = false;

  public let overrideGravity: Bool = false;

  public let gravityMode: Int32 = 0;

  public let gravityFalloffMode: Int32 = 0;

  public let gravityBurstEnabled: Bool = false;

  public let gravityBurstSteps: Int32 = 1;

  public let gravityBurstStepTime: Float = 0.010000;

  public let gravityBurstReverse: Bool = false;

  public let gravityBurstAltShape: Bool = false;

public let showArcade: Bool = false;

  public let customShowBulletJolts: Bool = false;

  public let arcadeBulletsEnabled: Bool = false;

  public let arcadeOnHitEnabled: Bool = true;

  public let arcadeOnDeathEnabled: Bool = true;

  public let arcadeMeleeEnabled: Bool = false;

  public let arcadeMeleeStrength: Float = 8.000000;

  public let arcadeMeleeUp: Float = 1.000000;

  public let arcadeMeleeDown: Float = 0.000000;

  public let arcadePlayerOnly: Bool = true;

  public let showArcadeTargetFilters: Bool = false;

  public let enemyTypeFiltersEnabled: Bool = true;

  public let enemyBypassCanRagdollGate: Bool = true;

  public let enemyArcadeAllowMaxTac: Bool = true;

  public let enemyArcadeScaleMaxTac: Float = 1.000000;

  public let enemyJoltAllowMaxTac: Bool = true;

  public let enemyJoltScaleMaxTac: Float = 1.000000;

  public let enemyArcadeAllowBosses: Bool = true;

  public let enemyArcadeScaleBosses: Float = 0.650000;

  public let enemyJoltAllowBosses: Bool = true;

  public let enemyJoltScaleBosses: Float = 0.650000;

  public let enemyArcadeAllowMechs: Bool = true;

  public let enemyArcadeScaleMechs: Float = 0.350000;

  public let enemyJoltAllowMechs: Bool = true;

  public let enemyJoltScaleMechs: Float = 0.350000;

  public let enemyArcadeAllowRobots: Bool = true;

  public let enemyArcadeScaleRobots: Float = 0.350000;

  public let enemyJoltAllowRobots: Bool = true;

  public let enemyJoltScaleRobots: Float = 0.350000;

  public let showArcadeAdvanced: Bool = false;

  public let arcadeMeleeRadius: Float = 0.600000;

  public let arcadeBulletRadius: Float = 0.600000;

  public let arcadeApplicationPointOffset: Float = 0.500000;

  public let arcadeBulletCooldown: Float = 0.350000;

  public let arcadeImpulseDelay: Float = 0.060000;

  public let arcadeCowScale: Float = 1.000000;

  public let showArcadeWeaponMuls: Bool = false;

  public let weaponchoice: Bool = false;

  public let arcadeAllowHandgun: Bool = false;

  public let arcadeAllowMagnum: Bool = false;

  public let arcadeAllowShotgun: Bool = false;

  public let arcadeAllowSniper: Bool = false;

  public let arcadeAllowSMG: Bool = false;

  public let arcadeAllowAR: Bool = false;

  public let arcadeAllowLMG: Bool = false;

  public let arcadeAllowBlunt: Bool = false;

  public let arcadeAllowBlade: Bool = false;

  public let arcadeMulHandgun: Float = 1.000000;

  public let arcadeMulMagnum: Float = 1.000000;

  public let arcadeMulShotgun: Float = 1.000000;

  public let arcadeMulSniper: Float = 1.000000;

  public let arcadeMulSMG: Float = 1.000000;

  public let arcadeMulAR: Float = 1.000000;

  public let arcadeMulLMG: Float = 1.000000;

  public let arcadeMulBlunt: Float = 1.000000;

  public let arcadeMulBlade: Float = 1.000000;

  public let arcadeBulletStrength: Float = 0.000000;

  public let arcadeBulletUp: Float = 1.500000;

  public let arcadeBulletDown: Float = 0.000000;

public let showVehicleWipSettings: Bool = false;

  public let vehicleImpulseEnabled: Bool = false;

  public let showVehicleImpulsesAdvanced: Bool = false;

  public let vehicleOccupantShieldTime: Float = 0.650000;

  public let vehicleExitShieldTime: Float = 0.850000;

  // Legacy source gate remains dedicated to vehicle melee push.
  public let vehicleImpulsePlayerOnly: Bool = true;

  // Issue #19: independent source gates for the two vehicle target lanes.
  public let vehicleBulletPlayerOnly: Bool = true;
  public let vehicleExplosionPlayerOnly: Bool = true;

  public let vehicleImpulseCooldown: Float = 0.0;

  public let vehicleImpulseMassCompensation: Bool = true;

  public let vehicleImpulseReferenceMass: Float = 1500.0;

  public let vehicleImpulseMinMassScale: Float = 0.75;

  public let vehicleImpulseMaxMassScale: Float = 2.25;

  public let vehicleImpulseClampEnabled: Bool = true;

  public let vehicleImpulseMaxHorizontal: Float = 16900.0;

  public let vehicleImpulseMaxLift: Float = 16900.0;

  public let vehicleUseExplosionMultipliers: Bool = true;

  public let vehicleUseArcadeWeaponFilters: Bool = false;

  public let vehicleUseArcadeWeaponMultipliers: Bool = false;

  public let vehicleExplosionEnabled: Bool = true;

  public let vehicleExplosionStrength: Float = 8281.0;

  public let vehicleExplosionLift: Float = 296.0;

  public let vehicleExplosionDown: Float = 0.0;

  public let vehicleExplosionRadius: Float = 3.0;

  public let vehicleBulletEnabled: Bool = true;

  public let vehicleBulletStrength: Float = 250.0;

  public let vehicleBulletLift: Float = 0.0;

  public let vehicleBulletDown: Float = 0.0;

  public let vehicleBulletRadius: Float = 0.80;

  public let vehicleMeleeEnabled: Bool = true;

  public let vehicleMeleeStrength: Float = 2500.0;

  public let vehicleMeleeLift: Float = 100.0;

  public let vehicleMeleeDown: Float = 0.0;

  public let vehicleMeleeRadius: Float = 1.0;

  public let vehicleAllowHandgun: Bool = true;

  public let vehicleMulHandgun: Float = 1.0;

  public let vehicleAllowMagnum: Bool = true;

  public let vehicleMulMagnum: Float = 1.35;

  public let vehicleAllowShotgun: Bool = true;

  public let vehicleMulShotgun: Float = 1.45;

  public let vehicleAllowSniper: Bool = true;

  public let vehicleMulSniper: Float = 1.25;

  public let vehicleAllowSMG: Bool = true;

  public let vehicleMulSMG: Float = 0.75;

  public let vehicleAllowAR: Bool = true;

  public let vehicleMulAR: Float = 0.90;

  public let vehicleAllowLMG: Bool = true;

  public let vehicleMulLMG: Float = 1.10;

  public let vehicleAllowBlunt: Bool = true;

  public let vehicleMulBlunt: Float = 1.50;

  public let vehicleAllowBlade: Bool = false;

  public let vehicleMulBlade: Float = 0.70;

  public let vehicleAllowGorilla: Bool = true;

  public let vehicleMulGorilla: Float = 2.00;

  public let vehicleAllowUnknownBullet: Bool = true;

  public let vehicleMulUnknownBullet: Float = 1.0;

  public let vehicleOccupantShieldEnabled: Bool = true;

  public let vehicleMountedHitImmunity: Bool = false;

  public let vehicleExitShieldEnabled: Bool = true;

public let showGrenadesExplosions: Bool = false;

  public let grenadeEnabled: Bool = false;

  public let grenadeExceptionFrag: Bool = false;

  public let grenadeExceptionFlash: Bool = false;

  public let grenadeExceptionSmoke: Bool = false;

  public let grenadeExceptionPiercing: Bool = false;

  public let grenadeExceptionEMP: Bool = false;

  public let grenadeExceptionBiohazard: Bool = false;

  public let grenadeExceptionIncendiary: Bool = false;

  public let grenadeExceptionRecon: Bool = false;

  public let grenadeExceptionCutting: Bool = false;

  public let grenadeExceptionSonic: Bool = false;

  public let grenadeExceptionOzob: Bool = false;

  public let overrideGrenade: Bool = false;

  public let explPlayerOnly: Bool = true;

  public let grenadeKickRadius: Float = 1.200000;

  public let grenadeKickX: Float = 0.000000;

  public let grenadeKickY: Float = 0.000000;

  public let grenadeKickZ: Float = 100.000000;

  public let grenadeKickDown: Float = 0.000000;

  public let grenadeKickCallDelay: Float = 0.000000;

  public let showExplosionsAdvanced: Bool = false;

  public let explAffectGrenades: Bool = true;

  public let explAffectWeapon: Bool = false;

  public let explAffectBullet: Bool = false;

  public let explAffectVeh: Bool = false;

  public let explAffectVehicle: Bool = false;

  public let explMulGrenades: Float = 1.000000;

  public let explMulWeapon: Float = 1.000000;

  public let explMulBullet: Float = 1.000000;

  public let explMulVehicle: Float = 1.000000;

public let showSettle: Bool = false;

  public let settleEnabled: Bool = true;

  public let overrideSettle: Bool = false;

  public let settleStrength: Float = 3.240000;

  public let settleDelay: Float = 2.260000;

  public let settleFwd: Float = 0.100000;

  public let settleDown: Float = 0.600000;

  public let settleRadius: Float = 0.800000;

public let showTwitch: Bool = false;

  public let twitchEnabled: Bool = true;

  public let overrideTwitch: Bool = false;

  public let twitchChance: Float = 1.000000;

  public let twitchDelayStart: Float = 3.200000;

  public let twitchDuration: Float = 20.500000;

  public let twitchForce: Float = 200.000000;
  public let customShowTripSettings: Bool = false;

public let customTripEmotion_showEmotionSection: Bool = false;

  public let customTripEmotion_enabled: Bool = false;

  public let customTripEmotion_aggressionFirst: Bool = true;

  public let customTripEmotion_autoReactionMode: Int32 = 1;

  public let customTripEmotion_testingMode: Bool = false;

  public let customTripEmotion_showAdvanced: Bool = false;

  public let customTripEmotion_workspotBackOffFallbackEnabled: Bool = true;

  public let customTripEmotion_workspotBackOffFallbackDelaySec: Float = 3.00;

  public let customTripEmotion_showPushReactionPopup: Bool = false;

  public let customTripEmotion_allowAggressionCombat: Bool = true;

  public let customTripEmotion_allowWalkAway: Bool = true;

  public let customTripEmotion_allowFlee: Bool = true;

  public let customTripEmotion_allowCompleteSurrender: Bool = true;


public let customTripAnimation_showTripAnimationSection: Bool = false;

  public let customTripAnimation_enabled: Bool = false;

  public let customTripAnimation_showTripAnimationAdvanced: Bool = false;

  public let customTripAnimation_chancePct: Float = 100.00;

  public let customTripAnimation_forwardPush: Float = 4.00;

  public let customTripAnimation_downwardForce: Float = 3.00;

  public let customTripAnimation_ragdollDelaySec: Float = 1.15;

  public let customTripAnimation_bodyArea: Float = 5.00;

  public let customTripAnimation_hitHeight: Float = 0.55;

  public let customTripAnimation_lockoutSec: Float = 3.00;

public let customTripOnLook_showOnLookSection: Bool = false;

  public let customTripOnLook_enabled: Bool = false;

  public let customTripOnLook_aggressiveOnly: Bool = true;

  public let customTripOnLook_requireCenterScreen: Bool = true;

  public let customTripOnLook_showAdvancedOnLook: Bool = false;

  public let customTripOnLook_contactDistM: Float = 0.85;

  public let customTripOnLook_minSpeedMps: Float = 6.90;

  public let customTripOnLook_pushXY: Float = 28.00;

  public let customTripOnLook_downZ: Float = 11.00;

  public let customTripOnLook_centerAimTightness: Float = 0.90;

  public let customTripOnLook_centerLaneWidth: Float = 0.35;

  public let customTripOnLook_sideXY: Float = 9.00;

  public let customTripOnLook_liftZ: Float = 1.00;

  public let customTripOnLook_radius: Float = 1.20;

  public let customTripOnLook_zOffset: Float = 0.50;

  public let customTripOnLook_cooldownSec: Float = 0.80;

  public let customTripOnLook_intervalSec: Float = 0.05;

  public let customTripOnLook_impactPauseSec: Float = 0.03;

  public let customTripOnLook_impulseDelaySec: Float = 0.03;

  public let customTripOnLook_emotionDelayAfterRagdoll: Float = 0.20;


public let showTumble: Bool = true;

  public let tumbleEnabled: Bool = true;

  public let overrideTumbleStairs: Bool = false;

  public let tumbleStairs_steps: Int32 = 6;

  public let tumbleStairs_stepDelay: Float = 0.080000;

  public let tumbleStairs_delay: Float = 0.080000;

  public let tumbleStairs_down: Float = 94.750000;

  public let tumbleStairs_fwd: Float = 0.000000;

  public let tumbleStairs_side: Float = 82.250000;

  public let tumbleStairs_downDelay: Float = 0.360000;

  public let tumbleStairs_fwdDelay: Float = 0.410000;

  public let tumbleStairs_sideDelay: Float = 0.150000;

  public let tumbleStairs_radius: Float = 0.850000;

  public let tumbleStairs_yawDeg: Float = 0.000000;

  public let tumbleStairs_pitchDeg: Float = 2.000000;

  public let tumbleStairs_rollDeg: Float = 1.000000;

public let showTumblesD: Bool = false;

  public let directionalTumbleEnabled: Bool = false;

  public let overrideTumbleDirectional: Bool = false;

  public let tumbleDir_steps: Int32 = 6;

  public let tumbleDir_stepDelay: Float = 0.040000;

  public let tumbleDir_down: Float = 1.000000;

  public let tumbleDir_fwd: Float = 0.000000;

  public let tumbleDir_side: Float = 2.800000;

  public let tumbleDir_downDelay: Float = 0.000000;

  public let tumbleDir_fwdDelay: Float = 0.040000;

  public let tumbleDir_sideDelay: Float = 1.030000;

  public let tumbleDir_radius: Float = 1.350000;

  public let st_overrideGlobalKnees: Bool = false;

  public let st_d_headSnap: Float = 0.000000;

  public let st_shinDown: Float = 0.000000;

  public let st_shinDelay1: Float = 0.000000;

  public let st_shinDelay2: Float = 0.000000;

  public let st_shinBack: Float = 0.000000;

  public let st_shinRadius: Float = 0.000000;

  public let st_footDown: Float = 0.000000;

  public let st_footFwd: Float = 0.000000;

  public let st_footDelay: Float = 0.000000;

  public let st_footRadius: Float = 0.000000;

  public let st_vSlamZ: Float = 0.000000;

  public let st_d_vSlam: Float = 0.000000;

  public let st_antiTuckZ: Float = 0.000000;

  public let st_antiTuckDelay: Float = 0.000000;

  public let st_antiTuckRadius: Float = 0.000000;

  public let st_anchorFwd: Float = 0.000000;

  public let st_anchorDown: Float = 0.000000;

  public let st_anchorOffset: Float = 0.000000;

  public let st_anchorRadius: Float = 0.000000;

  public let realismPlusShowHead: Bool = false;

  public let showRealismPlusHeadMultipliers: Bool = false;

  public let realismPlus_headDownScale: Float = 1.15;

  public let realismPlus_headUpScale: Float = 0.85;

  public let realismPlus_headForwardScale: Float = 0.90;

  public let realismPlus_headSideScale: Float = 0.90;

  public let realismPlus_headSlamScale: Float = 1.20;

  public let realismPlusMode_headReboundKneeNearPct: Float = 3.000000;

  public let realismPlusShowBody: Bool = false;

  public let realismPlus_multipliersEnabled: Bool = true;

  public let showRealismPlusBodyMultipliers: Bool = false;

  public let realismPlus_bodyDownScale: Float = 1.25;

  public let realismPlus_bodyUpScale: Float = 0.85;

  public let realismPlus_bodyForwardScale: Float = 0.90;

  public let realismPlus_bodySideScale: Float = 0.90;

  public let realismPlus_bodySlamScale: Float = 1.35;

  public let realismPlusShowSituation: Bool = false;

  public let showRealismPlusSituationalMultipliers: Bool = false;

  public let realismPlus_situationalDownScale: Float = 1.30;

  public let realismPlus_situationalUpScale: Float = 0.80;

  public let realismPlus_situationalForwardScale: Float = 0.85;

  public let realismPlus_situationalSideScale: Float = 0.85;

  public let realismPlus_situationalSlamScale: Float = 1.40;

  public let realismPlusShowArcade: Bool = false;

  public let realismPlusShowJolts: Bool = false;

  public let realismPlusMode_bulletJoltsEnabled: Bool = true;

  public let realismPlusMode_bulletJoltStrengthScale: Float = 2.500000;

  public let realismPlusMode_bulletJoltRadiusScale: Float = 1.000000;

  public let realismPlusMode_bulletJoltDelayScale: Float = 0.000000;

  public let realismPlusMode_bulletJoltWaitForGround: Bool = false;

  public let realismPlusMode_bulletJoltGroundWaitMax: Float = 3.000000;

  public let realismPlusMode_bulletJoltAllowAirborne: Bool = false;

  public let realismPlusMode_arcadeBulletsEnabled: Bool = false;

  public let realismPlusMode_arcadePlayerOnly: Bool = true;

  public let realismPlusMode_arcadeOnHitEnabled: Bool = false;

  public let realismPlusMode_arcadeOnDeathEnabled: Bool = false;

  public let realismPlusMode_arcadeMeleeEnabled: Bool = false;

  public let realismPlusMode_arcadeMeleeStrength: Float = 8.000000;

  public let realismPlusMode_arcadeMeleeUp: Float = 1.000000;

  public let realismPlusMode_arcadeMeleeDown: Float = 0.000000;

  public let realismPlusMode_arcadeBulletStrength: Float = 0.000000;

  public let realismPlusMode_arcadeBulletUp: Float = 0.000000;

  public let realismPlusMode_arcadeBulletDown: Float = 0.000000;

  public let realismPlusMode_showArcadeAdvanced: Bool = false;

  public let realismPlusMode_arcadeMeleeRadius: Float = 0.600000;

  public let realismPlusMode_arcadeBulletRadius: Float = 0.600000;

  public let realismPlusMode_arcadeApplicationPointOffset: Float = 0.500000;

  public let realismPlusMode_arcadeBulletCooldown: Float = 0.350000;

  public let realismPlusMode_arcadeImpulseDelay: Float = 0.060000;

  public let realismPlusMode_arcadeCowScale: Float = 1.000000;

  public let realismPlusMode_showArcadeWeaponMuls: Bool = false;

  public let realismPlusMode_arcadeAllowHandgun: Bool = false;

  public let realismPlusMode_arcadeAllowMagnum: Bool = false;

  public let realismPlusMode_arcadeAllowShotgun: Bool = false;

  public let realismPlusMode_arcadeAllowSniper: Bool = false;

  public let realismPlusMode_arcadeAllowSMG: Bool = false;

  public let realismPlusMode_arcadeAllowAR: Bool = false;

  public let realismPlusMode_arcadeAllowLMG: Bool = false;

  public let realismPlusMode_arcadeAllowBlunt: Bool = false;

  public let realismPlusMode_arcadeAllowBlade: Bool = false;

  public let realismPlusMode_arcadeMulHandgun: Float = 1.000000;

  public let realismPlusMode_arcadeMulMagnum: Float = 1.000000;

  public let realismPlusMode_arcadeMulShotgun: Float = 1.000000;

  public let realismPlusMode_arcadeMulSniper: Float = 1.000000;

  public let realismPlusMode_arcadeMulSMG: Float = 1.000000;

  public let realismPlusMode_arcadeMulAR: Float = 1.000000;

  public let realismPlusMode_arcadeMulLMG: Float = 1.000000;

  public let realismPlusMode_arcadeMulBlunt: Float = 1.000000;

  public let realismPlusMode_arcadeMulBlade: Float = 1.000000;

  public let realismPlusShowVehicles: Bool = false;

  public let realismPlusMode_showVehicleSettings: Bool = false;

  public let realismPlusMode_vehicleImpulseEnabled: Bool = true;

  public let realismPlusMode_vehicleBulletEnabled: Bool = true;

  public let realismPlusMode_vehicleBulletStrength: Float = 250.0;

  public let realismPlusMode_vehicleBulletUp: Float = 0.0;

  public let realismPlusMode_vehicleBulletDown: Float = 0.0;

  public let realismPlusMode_vehicleBulletRadius: Float = 0.800000;

  public let realismPlusMode_vehicleMulHandgun: Float = 0.200000;

  public let realismPlusMode_vehicleMulMagnum: Float = 0.450000;

  public let realismPlusMode_vehicleMulShotgun: Float = 0.650000;

  public let realismPlusMode_vehicleMulSniper: Float = 0.800000;

  public let realismPlusMode_vehicleMulSMG: Float = 0.350000;

  public let realismPlusMode_vehicleMulAR: Float = 0.550000;

  public let realismPlusMode_vehicleMulLMG: Float = 1.000000;

  public let realismPlusMode_vehicleMulUnknownBullet: Float = 0.400000;

  public let realismPlusMode_vehicleExplosionEnabled: Bool = true;

  public let realismPlusMode_vehicleExplosionStrength: Float = 8281.0;

  public let realismPlusMode_vehicleExplosionLift: Float = 296.0;

  public let realismPlusMode_vehicleExplosionDown: Float = 0.0;

  public let realismPlusMode_vehicleExplosionRadius: Float = 3.0;

  public let realismPlusMode_vehicleMeleeEnabled: Bool = true;

  public let realismPlusMode_vehicleMeleeStrength: Float = 2500.0;

  public let realismPlusMode_vehicleMeleeUp: Float = 100.0;

  public let realismPlusMode_vehicleMeleeDown: Float = 0.0;

  public let realismPlusMode_vehicleMeleeRadius: Float = 1.0;

  public let realismPlusShowExplosions: Bool = false;

  public let realismPlusMode_grenadeEnabled: Bool = false;

  public let realismPlusMode_explPlayerOnly: Bool = false;

  public let realismPlusMode_grenadeKickRadius: Float = 1.200000;

  public let realismPlusMode_grenadeKickX: Float = 2.000000;

  public let realismPlusMode_grenadeKickY: Float = 2.000000;

  public let realismPlusMode_grenadeKickZ: Float = 2.200000;

  public let realismPlusMode_grenadeKickDown: Float = 0.0;

  public let realismPlusMode_grenadeKickCallDelay: Float = 0.0;

  public let realismPlusShowExplosionAdvanced: Bool = false;

  public let realismPlusMode_explAffectGrenades: Bool = true;

  public let realismPlusMode_explAffectWeapon: Bool = true;

  public let realismPlusMode_explAffectBullet: Bool = true;

  public let realismPlusMode_explAffectVehicle: Bool = true;

  public let realismPlusMode_explMulGrenades: Float = 0.650000;

  public let realismPlusMode_explMulWeapon: Float = 0.650000;

  public let realismPlusMode_explMulBullet: Float = 0.650000;

  public let realismPlusMode_explMulVehicle: Float = 0.650000;

  public let realismPlusShowSettle: Bool = false;

  public let realismPlusMode_settleEnabled: Bool = true;

  public let realismPlusMode_settleStrength: Float = 0.000000;

  public let realismPlusShowTwitch: Bool = false;

  public let realismPlusMode_twitchEnabled: Bool = false;

  public let realismPlusMode_twitchForce: Float = 200.000000;
  public let realismPlusShowTripSettings: Bool = false;

public let realismPlusTripEmotion_showEmotionSection: Bool = false;

  public let realismPlusTripEmotion_enabled: Bool = false;

  public let realismPlusTripEmotion_aggressionFirst: Bool = true;

  public let realismPlusTripEmotion_autoReactionMode: Int32 = 1;

  public let realismPlusTripEmotion_testingMode: Bool = false;

  public let realismPlusTripEmotion_showAdvanced: Bool = false;

  public let realismPlusTripEmotion_workspotBackOffFallbackEnabled: Bool = true;

  public let realismPlusTripEmotion_workspotBackOffFallbackDelaySec: Float = 3.00;

  public let realismPlusTripEmotion_showPushReactionPopup: Bool = false;

  public let realismPlusTripEmotion_allowAggressionCombat: Bool = true;

  public let realismPlusTripEmotion_allowWalkAway: Bool = true;

  public let realismPlusTripEmotion_allowFlee: Bool = true;

  public let realismPlusTripEmotion_allowCompleteSurrender: Bool = true;


public let realismPlusTripAnimation_showTripAnimationSection: Bool = false;

  public let realismPlusTripAnimation_enabled: Bool = false;

  public let realismPlusTripAnimation_showTripAnimationAdvanced: Bool = false;

  public let realismPlusTripAnimation_chancePct: Float = 100.00;

  public let realismPlusTripAnimation_forwardPush: Float = 4.00;

  public let realismPlusTripAnimation_downwardForce: Float = 3.00;

  public let realismPlusTripAnimation_ragdollDelaySec: Float = 1.15;

  public let realismPlusTripAnimation_bodyArea: Float = 5.00;

  public let realismPlusTripAnimation_hitHeight: Float = 0.55;

  public let realismPlusTripAnimation_lockoutSec: Float = 3.00;

public let realismPlusTripOnLook_showOnLookSection: Bool = false;

  public let realismPlusTripOnLook_enabled: Bool = false;

  public let realismPlusTripOnLook_aggressiveOnly: Bool = true;

  public let realismPlusTripOnLook_requireCenterScreen: Bool = true;

  public let realismPlusTripOnLook_showAdvancedOnLook: Bool = false;

  public let realismPlusTripOnLook_contactDistM: Float = 0.85;

  public let realismPlusTripOnLook_minSpeedMps: Float = 6.90;

  public let realismPlusTripOnLook_pushXY: Float = 28.00;

  public let realismPlusTripOnLook_downZ: Float = 11.00;

  public let realismPlusTripOnLook_centerAimTightness: Float = 0.90;

  public let realismPlusTripOnLook_centerLaneWidth: Float = 0.35;

  public let realismPlusTripOnLook_sideXY: Float = 9.00;

  public let realismPlusTripOnLook_liftZ: Float = 1.00;

  public let realismPlusTripOnLook_radius: Float = 1.20;

  public let realismPlusTripOnLook_zOffset: Float = 0.50;

  public let realismPlusTripOnLook_cooldownSec: Float = 0.80;

  public let realismPlusTripOnLook_intervalSec: Float = 0.05;

  public let realismPlusTripOnLook_impactPauseSec: Float = 0.03;

  public let realismPlusTripOnLook_impulseDelaySec: Float = 0.03;

  public let realismPlusTripOnLook_emotionDelayAfterRagdoll: Float = 0.20;


  public let realismPlusShowTumbles: Bool = false;

  public let realismPlusMode_tumbleEnabled: Bool = true;

  public let realismPlusMode_directionalTumbleEnabled: Bool = false;

  public let realismPlusMode_overrideTumbleStairs: Bool = true;

  public let realismPlusMode_tumbleStairs_down: Float = 19.000000;

  public let realismPlusMode_tumbleStairs_fwd: Float = 9.250000;

  public let realismPlusMode_tumbleStairs_side: Float = 2.800000;

  public let realismPlusMode_tumbleStairs_radius: Float = 1.350000;

  public let realismPlusMode_tumbleStairs_steps: Int32 = 6;

  public let realismPlusMode_tumbleStairs_stepDelay: Float = 0.040000;

  public let realismPlusMode_overrideTumbleDirectional: Bool = false;

  public let realismPlusMode_tumbleDir_down: Float = 1.100000;

  public let realismPlusMode_tumbleDir_fwd: Float = 0.550000;

  public let realismPlusMode_tumbleDir_side: Float = 0.450000;

  public let realismPlusMode_tumbleDir_radius: Float = 1.350000;

  public let realismPlusMode_tumbleDir_steps: Int32 = 6;

  public let realismPlusMode_tumbleDir_stepDelay: Float = 0.020000;

  public let dirtyHarryShowHead: Bool = false;

  public let dirty_headReboundKneeNearPct: Float = 3.000000;

  public let dirtyHarryShowArcade: Bool = false;

  public let dirtyHarryShowJolts: Bool = false;

  public let dirty_bulletJoltsEnabled: Bool = true;

  public let dirty_bulletJoltStrengthScale: Float = 5.000000;

  public let dirty_bulletJoltRadiusScale: Float = 1.000000;

  public let dirty_bulletJoltDelayScale: Float = 0.000000;

  public let dirty_bulletJoltWaitForGround: Bool = false;

  public let dirty_bulletJoltGroundWaitMax: Float = 2.000000;

  public let dirty_bulletJoltAllowAirborne: Bool = true;

  public let dirty_arcadeBulletsEnabled: Bool = true;

  public let dirty_arcadePlayerOnly: Bool = true;

  public let dirty_arcadeAllowPlayerBullet: Bool = true;

  public let dirty_arcadeAllowNPCBullet: Bool = false;

  public let dirty_arcadeAllowPlayerMelee: Bool = true;

  public let dirty_arcadeAllowNPCMelee: Bool = false;

  public let dirty_arcadeOnHitEnabled: Bool = true;

  public let dirty_arcadeOnDeathEnabled: Bool = true;

  public let dirty_arcadeMeleeEnabled: Bool = true;

  public let dirty_arcadeMeleeStrength: Float = 12.000000;

  public let dirty_arcadeMeleeUp: Float = 1.000000;

  public let dirty_arcadeMeleeDown: Float = 0.000000;

  public let dirty_arcadeBulletStrength: Float = 12.000000;

  public let dirty_arcadeBulletUp: Float = 1.600000;

  public let dirty_arcadeBulletDown: Float = 0.000000;

  public let dirty_showArcadeAdvanced: Bool = false;

  public let dirty_arcadeMeleeRadius: Float = 0.600000;

  public let dirty_arcadeBulletRadius: Float = 0.650000;

  public let dirty_arcadeApplicationPointOffset: Float = 0.500000;

  public let dirty_arcadeBulletCooldown: Float = 0.000000;

  public let dirty_arcadeImpulseDelay: Float = 0.000000;

  public let dirty_arcadeCowScale: Float = 1.000000;

  public let dirty_showArcadeWeaponMuls: Bool = false;

  public let dirty_arcadeAllowHandgun: Bool = true;

  public let dirty_arcadeAllowMagnum: Bool = true;

  public let dirty_arcadeAllowShotgun: Bool = true;

  public let dirty_arcadeAllowSniper: Bool = false;

  public let dirty_arcadeAllowSMG: Bool = false;

  public let dirty_arcadeAllowAR: Bool = false;

  public let dirty_arcadeAllowLMG: Bool = false;

  public let dirty_arcadeAllowBlunt: Bool = false;

  public let dirty_arcadeAllowBlade: Bool = false;

  public let dirty_arcadeMulHandgun: Float = 1.000000;

  public let dirty_arcadeMulMagnum: Float = 1.650000;

  public let dirty_arcadeMulShotgun: Float = 1.250000;

  public let dirty_arcadeMulSniper: Float = 1.000000;

  public let dirty_arcadeMulSMG: Float = 1.000000;

  public let dirty_arcadeMulAR: Float = 1.000000;

  public let dirty_arcadeMulLMG: Float = 1.000000;

  public let dirty_arcadeMulBlunt: Float = 1.000000;

  public let dirty_arcadeMulBlade: Float = 1.000000;

  public let dirtyHarryShowVehicles: Bool = false;

  public let dirty_showVehicleSettings: Bool = false;

  public let dirty_vehicleImpulseEnabled: Bool = true;

  public let dirty_vehicleBulletEnabled: Bool = true;

  public let dirty_vehicleBulletStrength: Float = 250.0;

  public let dirty_vehicleBulletUp: Float = 0.0;

  public let dirty_vehicleBulletDown: Float = 0.0;

  public let dirty_vehicleBulletRadius: Float = 0.800000;

  public let dirty_vehicleMulHandgun: Float = 0.200000;

  public let dirty_vehicleMulMagnum: Float = 0.450000;

  public let dirty_vehicleMulShotgun: Float = 0.650000;

  public let dirty_vehicleMulSniper: Float = 0.800000;

  public let dirty_vehicleMulSMG: Float = 0.350000;

  public let dirty_vehicleMulAR: Float = 0.550000;

  public let dirty_vehicleMulLMG: Float = 1.000000;

  public let dirty_vehicleMulUnknownBullet: Float = 0.400000;

  public let dirty_vehicleExplosionEnabled: Bool = true;

  public let dirty_vehicleExplosionStrength: Float = 8281.0;

  public let dirty_vehicleExplosionLift: Float = 296.0;

  public let dirty_vehicleExplosionDown: Float = 0.0;

  public let dirty_vehicleExplosionRadius: Float = 3.0;

  public let dirty_vehicleMeleeEnabled: Bool = true;

  public let dirty_vehicleMeleeStrength: Float = 2500.0;

  public let dirty_vehicleMeleeUp: Float = 100.0;

  public let dirty_vehicleMeleeDown: Float = 0.0;

  public let dirty_vehicleMeleeRadius: Float = 1.0;

  public let dirtyHarryShowExplosions: Bool = false;

  public let dirty_grenadeEnabled: Bool = true;

  public let dirty_explPlayerOnly: Bool = true;

  public let dirty_grenadeKickRadius: Float = 1.100000;

  public let dirty_grenadeKickX: Float = 1.400000;

  public let dirty_grenadeKickY: Float = 1.400000;

  public let dirty_grenadeKickZ: Float = 1.200000;

  public let dirty_grenadeKickDown: Float = 0.0;

  public let dirty_grenadeKickCallDelay: Float = 0.0;

  public let dirtyHarryShowExplosionAdvanced: Bool = false;

  public let dirty_explAffectGrenades: Bool = true;

  public let dirty_explAffectWeapon: Bool = true;

  public let dirty_explAffectBullet: Bool = true;

  public let dirty_explAffectVehicle: Bool = true;

  public let dirty_explMulGrenades: Float = 0.550000;

  public let dirty_explMulWeapon: Float = 0.550000;

  public let dirty_explMulBullet: Float = 0.550000;

  public let dirty_explMulVehicle: Float = 0.550000;

  public let dirtyHarryShowSettle: Bool = false;

  public let dirty_settleEnabled: Bool = true;

  public let dirty_settleStrength: Float = 0.000000;

  public let dirtyHarryShowTwitch: Bool = false;

  public let dirty_twitchEnabled: Bool = false;

  public let dirty_twitchForce: Float = 200.000000;
  public let dirtyHarryShowTripSettings: Bool = false;

public let dirtyTripEmotion_showEmotionSection: Bool = false;

  public let dirtyTripEmotion_enabled: Bool = false;

  public let dirtyTripEmotion_aggressionFirst: Bool = true;

  public let dirtyTripEmotion_autoReactionMode: Int32 = 1;

  public let dirtyTripEmotion_testingMode: Bool = false;

  public let dirtyTripEmotion_showAdvanced: Bool = false;

  public let dirtyTripEmotion_workspotBackOffFallbackEnabled: Bool = true;

  public let dirtyTripEmotion_workspotBackOffFallbackDelaySec: Float = 3.00;

  public let dirtyTripEmotion_showPushReactionPopup: Bool = false;

  public let dirtyTripEmotion_allowAggressionCombat: Bool = true;

  public let dirtyTripEmotion_allowWalkAway: Bool = true;

  public let dirtyTripEmotion_allowFlee: Bool = true;

  public let dirtyTripEmotion_allowCompleteSurrender: Bool = true;


public let dirtyTripAnimation_showTripAnimationSection: Bool = false;

  public let dirtyTripAnimation_enabled: Bool = false;

  public let dirtyTripAnimation_showTripAnimationAdvanced: Bool = false;

  public let dirtyTripAnimation_chancePct: Float = 100.00;

  public let dirtyTripAnimation_forwardPush: Float = 4.00;

  public let dirtyTripAnimation_downwardForce: Float = 3.00;

  public let dirtyTripAnimation_ragdollDelaySec: Float = 1.15;

  public let dirtyTripAnimation_bodyArea: Float = 5.00;

  public let dirtyTripAnimation_hitHeight: Float = 0.55;

  public let dirtyTripAnimation_lockoutSec: Float = 3.00;

public let dirtyTripOnLook_showOnLookSection: Bool = false;

  public let dirtyTripOnLook_enabled: Bool = false;

  public let dirtyTripOnLook_aggressiveOnly: Bool = true;

  public let dirtyTripOnLook_requireCenterScreen: Bool = true;

  public let dirtyTripOnLook_showAdvancedOnLook: Bool = false;

  public let dirtyTripOnLook_contactDistM: Float = 0.85;

  public let dirtyTripOnLook_minSpeedMps: Float = 6.90;

  public let dirtyTripOnLook_pushXY: Float = 28.00;

  public let dirtyTripOnLook_downZ: Float = 11.00;

  public let dirtyTripOnLook_centerAimTightness: Float = 0.90;

  public let dirtyTripOnLook_centerLaneWidth: Float = 0.35;

  public let dirtyTripOnLook_sideXY: Float = 9.00;

  public let dirtyTripOnLook_liftZ: Float = 1.00;

  public let dirtyTripOnLook_radius: Float = 1.20;

  public let dirtyTripOnLook_zOffset: Float = 0.50;

  public let dirtyTripOnLook_cooldownSec: Float = 0.80;

  public let dirtyTripOnLook_intervalSec: Float = 0.05;

  public let dirtyTripOnLook_impactPauseSec: Float = 0.03;

  public let dirtyTripOnLook_impulseDelaySec: Float = 0.03;

  public let dirtyTripOnLook_emotionDelayAfterRagdoll: Float = 0.20;


  public let dirtyHarryShowTumbles: Bool = false;

  public let dirty_tumbleEnabled: Bool = true;

  public let dirty_directionalTumbleEnabled: Bool = true;

  public let dirty_overrideTumbleStairs: Bool = true;

  public let dirty_tumbleStairs_down: Float = 24.000000;

  public let dirty_tumbleStairs_fwd: Float = 11.000000;

  public let dirty_tumbleStairs_side: Float = 3.500000;

  public let dirty_tumbleStairs_radius: Float = 1.450000;

  public let dirty_tumbleStairs_steps: Int32 = 7;

  public let dirty_tumbleStairs_stepDelay: Float = 0.045000;

  public let dirty_overrideTumbleDirectional: Bool = true;

  public let dirty_tumbleDir_down: Float = 1.450000;

  public let dirty_tumbleDir_fwd: Float = 0.750000;

  public let dirty_tumbleDir_side: Float = 0.650000;

  public let dirty_tumbleDir_radius: Float = 1.450000;

  public let dirty_tumbleDir_steps: Int32 = 7;

  public let dirty_tumbleDir_stepDelay: Float = 0.035000;

  public let arnoldArcadeShowHead: Bool = false;

  public let arnoldArcadeShowJolts: Bool = false;

  public let arnold_bulletJoltsEnabled: Bool = true;

  public let arnold_bulletJoltStrengthScale: Float = 9.000000;

  public let arnold_bulletJoltRadiusScale: Float = 1.200000;

  public let arnold_bulletJoltDelayScale: Float = 0.000000;

  public let arnold_bulletJoltWaitForGround: Bool = false;

  public let arnold_bulletJoltGroundWaitMax: Float = 1.000000;

  public let arnold_bulletJoltAllowAirborne: Bool = true;

  public let arnold_headReboundKneeNearPct: Float = 3.000000;

  public let arnoldArcadeShowArcade: Bool = false;

  public let arnold_arcadeBulletsEnabled: Bool = true;

  public let arnold_arcadePlayerOnly: Bool = true;

  public let arnold_arcadeAllowPlayerBullet: Bool = true;

  public let arnold_arcadeAllowNPCBullet: Bool = false;

  public let arnold_arcadeAllowPlayerMelee: Bool = true;

  public let arnold_arcadeAllowNPCMelee: Bool = false;

  public let arnold_arcadeOnHitEnabled: Bool = true;

  public let arnold_arcadeOnDeathEnabled: Bool = true;

  public let arnold_arcadeMeleeEnabled: Bool = true;

  public let arnold_arcadeMeleeStrength: Float = 24.000000;

  public let arnold_arcadeMeleeUp: Float = 2.000000;

  public let arnold_arcadeMeleeDown: Float = 0.000000;

  public let arnold_arcadeBulletStrength: Float = 24.000000;

  public let arnold_arcadeBulletUp: Float = 4.500000;

  public let arnold_arcadeBulletDown: Float = 0.000000;

  public let arnold_showArcadeAdvanced: Bool = false;

  public let arnold_arcadeMeleeRadius: Float = 0.600000;

  public let arnold_arcadeBulletRadius: Float = 0.950000;

  public let arnold_arcadeApplicationPointOffset: Float = 0.650000;

  public let arnold_arcadeBulletCooldown: Float = 0.000000;

  public let arnold_arcadeImpulseDelay: Float = 0.000000;

  public let arnold_arcadeCowScale: Float = 1.250000;

  public let arnold_showArcadeWeaponMuls: Bool = false;

  public let arnold_arcadeAllowHandgun: Bool = true;

  public let arnold_arcadeAllowMagnum: Bool = true;

  public let arnold_arcadeAllowShotgun: Bool = true;

  public let arnold_arcadeAllowSniper: Bool = true;

  public let arnold_arcadeAllowSMG: Bool = true;

  public let arnold_arcadeAllowAR: Bool = true;

  public let arnold_arcadeAllowLMG: Bool = true;

  public let arnold_arcadeAllowBlunt: Bool = true;

  public let arnold_arcadeAllowBlade: Bool = false;

  public let arnold_arcadeMulHandgun: Float = 1.100000;

  public let arnold_arcadeMulMagnum: Float = 1.450000;

  public let arnold_arcadeMulShotgun: Float = 1.550000;

  public let arnold_arcadeMulSniper: Float = 1.400000;

  public let arnold_arcadeMulSMG: Float = 0.900000;

  public let arnold_arcadeMulAR: Float = 1.050000;

  public let arnold_arcadeMulLMG: Float = 1.250000;

  public let arnold_arcadeMulBlunt: Float = 1.350000;

  public let arnold_arcadeMulBlade: Float = 0.000000;

  public let arnoldArcadeShowVehicles: Bool = false;

  public let arnold_showVehicleSettings: Bool = false;

  public let arnold_vehicleImpulseEnabled: Bool = true;

  public let arnold_vehicleBulletEnabled: Bool = true;

  public let arnold_vehicleBulletStrength: Float = 1200.0;

  public let arnold_vehicleBulletUp: Float = 0.0;

  public let arnold_vehicleBulletDown: Float = 0.0;

  public let arnold_vehicleBulletRadius: Float = 0.800000;

  public let arnold_vehicleMotorcycleToppleOnBullet: Bool = true;

  public let arnold_vehicleMotorcycleToppleStrength: Float = 3.800000;

  public let arnold_playerMotorcycleLeanToppleEnabled: Bool = false;

  public let arnold_playerMotorcycleLeanToppleAngle: Float = 30.000000;

  public let arnold_playerMotorcycleLeanToppleMaxSpeed: Float = 100.000000;

  // Arnold/Arcade vehicle-bullet multipliers are deliberately separate from
  // the NPC Arcade multipliers. Rate of fire still stacks naturally, so the
  // per-hit SMG/AR values can remain below the heavier weapon classes.
  public let arnold_vehicleMulHandgun: Float = 0.200000;

  public let arnold_vehicleMulMagnum: Float = 0.450000;

  public let arnold_vehicleMulShotgun: Float = 0.650000;

  public let arnold_vehicleMulSniper: Float = 0.800000;

  public let arnold_vehicleMulSMG: Float = 0.350000;

  public let arnold_vehicleMulAR: Float = 0.550000;

  public let arnold_vehicleMulLMG: Float = 1.000000;

  public let arnold_vehicleMulUnknownBullet: Float = 0.400000;

  public let arnold_vehicleExplosionEnabled: Bool = true;

  public let arnold_vehicleExplosionStrength: Float = 8281.0;

  public let arnold_vehicleExplosionLift: Float = 296.0;

  public let arnold_vehicleExplosionDown: Float = 0.0;

  public let arnold_vehicleExplosionRadius: Float = 3.0;

  public let arnold_vehicleMeleeEnabled: Bool = true;

  public let arnold_vehicleMeleeStrength: Float = 2500.0;

  public let arnold_vehicleMeleeUp: Float = 100.0;

  public let arnold_vehicleMeleeDown: Float = 0.0;

  public let arnold_vehicleMeleeRadius: Float = 1.0;

  public let arnoldArcadeShowExplosions: Bool = false;

  public let arnold_grenadeEnabled: Bool = true;

  public let arnold_explPlayerOnly: Bool = true;

  public let arnold_grenadeKickRadius: Float = 2.250000;

  public let arnold_grenadeKickX: Float = 7.000000;

  public let arnold_grenadeKickY: Float = 7.000000;

  public let arnold_grenadeKickZ: Float = 5.500000;

  public let arnold_grenadeKickDown: Float = 0.0;

  public let arnold_grenadeKickCallDelay: Float = 0.0;

  public let arnoldArcadeShowExplosionAdvanced: Bool = false;

  public let arnold_explAffectGrenades: Bool = true;

  public let arnold_explAffectWeapon: Bool = true;

  public let arnold_explAffectBullet: Bool = true;

  public let arnold_explAffectVehicle: Bool = true;

  public let arnold_explMulGrenades: Float = 2.500000;

  public let arnold_explMulWeapon: Float = 2.500000;

  public let arnold_explMulBullet: Float = 2.000000;

  public let arnold_explMulVehicle: Float = 3.000000;

  public let arnoldArcadeShowSettle: Bool = false;

  public let arnold_settleEnabled: Bool = true;

  public let arnold_settleStrength: Float = 2.000000;

  public let arnoldArcadeShowTwitch: Bool = false;

  public let arnold_twitchEnabled: Bool = false;

  public let arnold_twitchForce: Float = 200.000000;
  public let arnoldArcadeShowTripSettings: Bool = false;

public let arnoldTripEmotion_showEmotionSection: Bool = false;

  public let arnoldTripEmotion_enabled: Bool = false;

  public let arnoldTripEmotion_aggressionFirst: Bool = true;

  public let arnoldTripEmotion_autoReactionMode: Int32 = 1;

  public let arnoldTripEmotion_testingMode: Bool = false;

  public let arnoldTripEmotion_showAdvanced: Bool = false;

  public let arnoldTripEmotion_workspotBackOffFallbackEnabled: Bool = true;

  public let arnoldTripEmotion_workspotBackOffFallbackDelaySec: Float = 3.00;

  public let arnoldTripEmotion_showPushReactionPopup: Bool = false;

  public let arnoldTripEmotion_allowAggressionCombat: Bool = true;

  public let arnoldTripEmotion_allowWalkAway: Bool = true;

  public let arnoldTripEmotion_allowFlee: Bool = true;

  public let arnoldTripEmotion_allowCompleteSurrender: Bool = true;


public let arnoldTripAnimation_showTripAnimationSection: Bool = false;

  public let arnoldTripAnimation_enabled: Bool = false;

  public let arnoldTripAnimation_showTripAnimationAdvanced: Bool = false;

  public let arnoldTripAnimation_chancePct: Float = 100.00;

  public let arnoldTripAnimation_forwardPush: Float = 4.00;

  public let arnoldTripAnimation_downwardForce: Float = 3.00;

  public let arnoldTripAnimation_ragdollDelaySec: Float = 1.15;

  public let arnoldTripAnimation_bodyArea: Float = 5.00;

  public let arnoldTripAnimation_hitHeight: Float = 0.55;

  public let arnoldTripAnimation_lockoutSec: Float = 3.00;

public let arnoldTripOnLook_showOnLookSection: Bool = false;

  public let arnoldTripOnLook_enabled: Bool = false;

  public let arnoldTripOnLook_aggressiveOnly: Bool = true;

  public let arnoldTripOnLook_requireCenterScreen: Bool = true;

  public let arnoldTripOnLook_showAdvancedOnLook: Bool = false;

  public let arnoldTripOnLook_contactDistM: Float = 0.85;

  public let arnoldTripOnLook_minSpeedMps: Float = 6.90;

  public let arnoldTripOnLook_pushXY: Float = 28.00;

  public let arnoldTripOnLook_downZ: Float = 11.00;

  public let arnoldTripOnLook_centerAimTightness: Float = 0.90;

  public let arnoldTripOnLook_centerLaneWidth: Float = 0.35;

  public let arnoldTripOnLook_sideXY: Float = 9.00;

  public let arnoldTripOnLook_liftZ: Float = 1.00;

  public let arnoldTripOnLook_radius: Float = 1.20;

  public let arnoldTripOnLook_zOffset: Float = 0.50;

  public let arnoldTripOnLook_cooldownSec: Float = 0.80;

  public let arnoldTripOnLook_intervalSec: Float = 0.05;

  public let arnoldTripOnLook_impactPauseSec: Float = 0.03;

  public let arnoldTripOnLook_impulseDelaySec: Float = 0.03;

  public let arnoldTripOnLook_emotionDelayAfterRagdoll: Float = 0.20;


  public let arnoldArcadeShowTumbles: Bool = false;

  public let arnold_tumbleEnabled: Bool = true;

  public let arnold_directionalTumbleEnabled: Bool = true;

  public let arnold_overrideTumbleStairs: Bool = true;

  public let arnold_tumbleStairs_down: Float = 34.000000;

  public let arnold_tumbleStairs_fwd: Float = 18.000000;

  public let arnold_tumbleStairs_side: Float = 6.000000;

  public let arnold_tumbleStairs_radius: Float = 2.000000;

  public let arnold_tumbleStairs_steps: Int32 = 10;

  public let arnold_tumbleStairs_stepDelay: Float = 0.035000;

  public let arnold_overrideTumbleDirectional: Bool = true;

  public let arnold_tumbleDir_down: Float = 2.250000;

  public let arnold_tumbleDir_fwd: Float = 1.500000;

  public let arnold_tumbleDir_side: Float = 1.200000;

  public let arnold_tumbleDir_radius: Float = 2.000000;

  public let arnold_tumbleDir_steps: Int32 = 10;

  public let arnold_tumbleDir_stepDelay: Float = 0.025000;

  public let showStandingAnchor: Bool = false;

  public let run_overrideGlobalKnees: Bool = false;

  public let run_downHead: Float = 0.000000;

  public let run_downHeadMin: Float = 0.000000;

  public let run_d_headSlam: Float = 0.000000;

  public let run_d_headBias: Float = 0.000000;

  public let run_vSlamZ: Float = 0.000000;

  public let run_d_vSlam: Float = 0.000000;

  public let run_shinBack: Float = 0.000000;

  public let run_shinDown: Float = 0.000000;

  public let run_shinDelay1: Float = 0.000000;

  public let run_shinDelay2: Float = 0.000000;

  public let run_shinRadius: Float = 0.000000;

  public let wsStand_overrideGlobalKnees: Bool = false;

  public let wsStand_headFwd: Float = 0.000000;

  public let wsStand_headDown: Float = 0.000000;

  public let wsStand_headDelay: Float = 0.000000;

  public let wsStand_headRadius: Float = 0.000000;

  public let wsStand_pelvisRadius: Float = 0.000000;

  public let wsStand_body_vSlamZ: Float = 0.000000;

  public let wsStand_body_vSlamDelay: Float = 0.000000;

  public let wsStand_body_vSlamRadius: Float = 0.000000;


  public let masterDeathChanceEnabled: Bool = true;


  public let killImpulsesVehiclesOnly: Bool = false;

  public let killImpulsesEverywhere: Bool = true;

public let showDeathAnimControls: Bool = false;

  public let skipDeathAnim: Bool = true;

  public let killMotorcycleDeathAnim: Bool = true;

  public let deathAnimChancePct: Float = 100.000000;

  public let animCompatDelay: Float = 5.000000;

public let showStealthAnimationControls: Bool = false;

  public let respectCinematics: Bool = false;

  public let stealthRagdollsEnabled: Bool = true;

  public let stealthRagdollDelay: Float = 4.150000;

  public let blackwallCountsAsStealth: Bool = true;

public let showIncapacitatedAnimationControls: Bool = false;

  public let arcadeIncapRagdollEnabled: Bool = true;

  public let arcadeIncapRagdollDelay: Float = 0.000000;

public let showHitReactionAnimationControls: Bool = false;

  public let hitReactionsDisabled: Bool = false;

  public let hitReactionCutoffEnabled: Bool = false;

  public let hitReactionCutoffDelay: Float = 0.000000;

public let showInjuryShockControls: Bool = false;

  public let injuryShockEnabled: Bool = false;

  public let injuryShockAllowBosses: Bool = false;

  public let injuryShockAllowSubBosses: Bool = false;

  public let injuryShockAllowNPCSources: Bool = false;

  public let injuryShockChancePct: Float = 15.000000;

  public let injuryShockDelay: Float = 1.200000;

  public let injuryShockRandomDelay: Float = 0.000000;

  public let injuryShockGetUpDelay: Float = 6.000000;

  public let injuryShockGetUpRandomDelay: Float = 0.000000;

  public let injuryShockLimbsOnly: Bool = true;

  public let realismPlusMode_skipDeathAnim: Bool = true;

  public let realismPlusMode_killMotorcycleDeathAnim: Bool = true;

  public let realismPlusMode_deathAnimChancePct: Float = 0.000000;

  public let realismPlusMode_animCompatDelay: Float = 0.500000;

  public let realismPlusMode_incapReactionCutoffEnabled: Bool = true;

  public let realismPlusMode_incapReactionCutoffDelay: Float = 0.000000;

  public let realismPlusMode_hitReactionsDisabled: Bool = false;

  public let realismPlusMode_hitReactionCutoffEnabled: Bool = false;

  public let realismPlusMode_hitReactionCutoffDelay: Float = 0.000000;

  public let realismPlusMode_injuryShockEnabled: Bool = false;

  public let realismPlusMode_injuryShockChancePct: Float = 15.000000;

  public let realismPlusMode_injuryShockDelay: Float = 1.200000;

  public let realismPlusMode_injuryShockRandomDelay: Float = 0.000000;

  public let realismPlusMode_injuryShockGetUpDelay: Float = 6.000000;

  public let realismPlusMode_injuryShockGetUpRandomDelay: Float = 0.000000;

  public let realismPlusMode_injuryShockLimbsOnly: Bool = true;

  public let realismPlusMode_masterDeathChanceEnabled: Bool = true;

  public let realismPlusMode_masterDeathChancePct: Float = 94.000000;

  public let realismPlusMode_killImpulsesEverywhere: Bool = true;

  public let realismPlusMode_killImpulsesVehiclesOnly: Bool = false;

  public let realismPlusMode_vanillaImpulsesEnabled: Bool = false;

  public let realismPlusMode_vanillaAllowHandgun: Bool = false;

  public let realismPlusMode_vanillaAllowMagnum: Bool = false;

  public let realismPlusMode_vanillaAllowShotgun: Bool = false;

  public let realismPlusMode_vanillaAllowSniper: Bool = false;

  public let realismPlusMode_vanillaAllowSMG: Bool = false;

  public let realismPlusMode_vanillaAllowAR: Bool = false;

  public let realismPlusMode_vanillaAllowLMG: Bool = false;

  public let realismPlusMode_vanillaAllowBlunt: Bool = false;

  public let realismPlusMode_vanillaAllowBlade: Bool = false;

  public let dirty_skipDeathAnim: Bool = false;

  public let dirty_killMotorcycleDeathAnim: Bool = true;

  public let dirty_deathAnimChancePct: Float = 100.000000;

  public let dirty_animCompatDelay: Float = 0.550000;

  public let dirty_incapReactionCutoffEnabled: Bool = true;

  public let dirty_incapReactionCutoffDelay: Float = 0.000000;

  public let dirty_hitReactionsDisabled: Bool = false;

  public let dirty_hitReactionCutoffEnabled: Bool = false;

  public let dirty_hitReactionCutoffDelay: Float = 0.000000;

  public let dirty_injuryShockEnabled: Bool = false;

  public let dirty_injuryShockChancePct: Float = 15.000000;

  public let dirty_injuryShockDelay: Float = 1.200000;

  public let dirty_injuryShockRandomDelay: Float = 0.000000;

  public let dirty_injuryShockGetUpDelay: Float = 6.000000;

  public let dirty_injuryShockGetUpRandomDelay: Float = 0.000000;

  public let dirty_injuryShockLimbsOnly: Bool = true;

  public let dirty_masterDeathChanceEnabled: Bool = true;

  public let dirty_masterDeathChancePct: Float = 90.000000;

  public let dirty_killImpulsesEverywhere: Bool = true;

  public let dirty_killImpulsesVehiclesOnly: Bool = false;

  public let dirty_vanillaImpulsesEnabled: Bool = false;

  public let dirty_vanillaAllowHandgun: Bool = false;

  public let dirty_vanillaAllowMagnum: Bool = false;

  public let dirty_vanillaAllowShotgun: Bool = false;

  public let dirty_vanillaAllowSniper: Bool = false;

  public let dirty_vanillaAllowSMG: Bool = false;

  public let dirty_vanillaAllowAR: Bool = false;

  public let dirty_vanillaAllowLMG: Bool = false;

  public let dirty_vanillaAllowBlunt: Bool = false;

  public let dirty_vanillaAllowBlade: Bool = false;

  public let arnold_skipDeathAnim: Bool = true;

  public let arnold_killMotorcycleDeathAnim: Bool = true;

  public let arnold_deathAnimChancePct: Float = 0.000000;

  public let arnold_animCompatDelay: Float = 0.000000;

  public let arnold_incapReactionCutoffEnabled: Bool = true;

  public let arnold_incapReactionCutoffDelay: Float = 0.000000;

  public let arnold_hitReactionsDisabled: Bool = false;

  public let arnold_hitReactionCutoffEnabled: Bool = false;

  public let arnold_hitReactionCutoffDelay: Float = 0.000000;

  public let arnold_injuryShockEnabled: Bool = false;

  public let arnold_injuryShockChancePct: Float = 15.000000;

  public let arnold_injuryShockDelay: Float = 1.200000;

  public let arnold_injuryShockRandomDelay: Float = 0.000000;

  public let arnold_injuryShockGetUpDelay: Float = 6.000000;

  public let arnold_injuryShockGetUpRandomDelay: Float = 0.000000;

  public let arnold_injuryShockLimbsOnly: Bool = true;

  public let arnold_masterDeathChanceEnabled: Bool = true;

  public let arnold_masterDeathChancePct: Float = 100.000000;

  public let arnold_killImpulsesEverywhere: Bool = true;

  public let arnold_killImpulsesVehiclesOnly: Bool = false;

  public let arnold_vanillaImpulsesEnabled: Bool = false;

  public let arnold_vanillaAllowHandgun: Bool = false;

  public let arnold_vanillaAllowMagnum: Bool = false;

  public let arnold_vanillaAllowShotgun: Bool = false;

  public let arnold_vanillaAllowSniper: Bool = false;

  public let arnold_vanillaAllowSMG: Bool = false;

  public let arnold_vanillaAllowAR: Bool = false;

  public let arnold_vanillaAllowLMG: Bool = false;

  public let arnold_vanillaAllowBlunt: Bool = false;

  public let arnold_vanillaAllowBlade: Bool = false;

  public let realism_skipDeathAnim: Bool = true;

  public let realism_killMotorcycleDeathAnim: Bool = true;

  public let realism_deathAnimChancePct: Float = 0.000000;

  public let realism_animCompatDelay: Float = 0.500000;

  public let realism_masterDeathChanceEnabled: Bool = true;

  public let realism_masterDeathChancePct: Float = 94.000000;

  public let realism_killImpulsesEverywhere: Bool = true;

  public let realism_killImpulsesVehiclesOnly: Bool = false;

  public let realism_vanillaImpulsesEnabled: Bool = false;

  public let realism_vanillaAllowHandgun: Bool = false;

  public let realism_vanillaAllowMagnum: Bool = false;

  public let realism_vanillaAllowShotgun: Bool = false;

  public let realism_vanillaAllowSniper: Bool = false;

  public let realism_vanillaAllowSMG: Bool = false;

  public let realism_vanillaAllowAR: Bool = false;

  public let realism_vanillaAllowLMG: Bool = false;

  public let realism_vanillaAllowBlunt: Bool = false;

  public let realism_vanillaAllowBlade: Bool = false;

  public let realism_arcadeBulletsEnabled: Bool = false;

  public let realism_arcadePlayerOnly: Bool = true;

  public let realism_arcadeOnHitEnabled: Bool = false;

  public let realism_arcadeOnDeathEnabled: Bool = false;

  public let realism_arcadeBulletStrength: Float = 0.000000;

  public let realism_arcadeBulletUp: Float = 0.000000;

  public let realism_arcadeBulletRadius: Float = 0.600000;

  public let realism_arcadeBulletCooldown: Float = 0.350000;

  public let realism_arcadeImpulseDelay: Float = 0.060000;

  public let realism_arcadeCowScale: Float = 1.000000;

  public let realism_arcadeAllowHandgun: Bool = false;

  public let realism_arcadeAllowMagnum: Bool = false;

  public let realism_arcadeAllowShotgun: Bool = false;

  public let realism_arcadeAllowSniper: Bool = false;

  public let realism_arcadeAllowSMG: Bool = false;

  public let realism_arcadeAllowAR: Bool = false;

  public let realism_arcadeAllowLMG: Bool = false;

  public let realism_arcadeAllowBlunt: Bool = false;

  public let realism_arcadeAllowBlade: Bool = false;

  public let realism_arcadeMulHandgun: Float = 1.000000;

  public let realism_arcadeMulMagnum: Float = 1.000000;

  public let realism_arcadeMulShotgun: Float = 1.000000;

  public let realism_arcadeMulSniper: Float = 1.000000;

  public let realism_arcadeMulSMG: Float = 1.000000;

  public let realism_arcadeMulAR: Float = 1.000000;

  public let realism_arcadeMulLMG: Float = 1.000000;

  public let realism_arcadeMulBlunt: Float = 1.000000;

  public let realism_arcadeMulBlade: Float = 1.000000;

  public let realism_grenadeEnabled: Bool = false;

  public let realism_explPlayerOnly: Bool = false;

  public let realism_explAffectGrenades: Bool = true;

  public let realism_explAffectWeapon: Bool = true;

  public let realism_explAffectBullet: Bool = true;

  public let realism_explAffectVehicle: Bool = true;

  public let realism_grenadeKickRadius: Float = 1.200000;

  public let realism_grenadeKickX: Float = 2.000000;

  public let realism_grenadeKickZ: Float = 2.200000;

  public let realism_explMulGrenades: Float = 0.650000;

  public let realism_explMulWeapon: Float = 0.650000;

  public let realism_explMulBullet: Float = 0.650000;

  public let realism_explMulVehicle: Float = 0.650000;

  public let realism_tumbleEnabled: Bool = true;

  public let realism_directionalTumbleEnabled: Bool = false;

  public let realism_overrideTumbleStairs: Bool = true;

  public let realism_tumbleStairs_down: Float = 19.000000;

  public let realism_tumbleStairs_fwd: Float = 9.250000;

  public let realism_tumbleStairs_side: Float = 2.800000;

  public let realism_tumbleStairs_radius: Float = 1.350000;

  public let realism_tumbleStairs_steps: Int32 = 6;

  public let realism_tumbleStairs_stepDelay: Float = 0.040000;

  public let realism_overrideTumbleDirectional: Bool = false;

  public let realism_tumbleDir_down: Float = 1.100000;

  public let realism_tumbleDir_fwd: Float = 0.550000;

  public let realism_tumbleDir_side: Float = 0.450000;

  public let realism_tumbleDir_radius: Float = 1.350000;

  public let realism_tumbleDir_steps: Int32 = 6;

  public let realism_tumbleDir_stepDelay: Float = 0.020000;

  public let realism_settleEnabled: Bool = true;

  public let realism_settleStrength: Float = 0.000000;

  public let realism_bulletJoltsEnabled: Bool = true;

  public let realism_bulletJoltStrengthScale: Float = 2.500000;

  public let realism_bulletJoltRadiusScale: Float = 1.000000;

  public let realism_bulletJoltDelayScale: Float = 0.000000;

  public let realism_bulletJoltWaitForGround: Bool = false;

  public let realism_bulletJoltGroundWaitMax: Float = 3.000000;

  public let realism_bulletJoltAllowAirborne: Bool = false;

  public let realism_twitchEnabled: Bool = false;

  public let realism_twitchForce: Float = 200.000000;

public let showShoulderButtFalls: Bool = false;

public let shoulderGeneralStrength: Float = 1.0;

public let shoulderGeneralDelay: Float = 0.05;

public let shoulderGeneralRadius: Float = 0.70;

public let waistGeneralStrength: Float = 1.0;

public let waistGeneralDelay: Float = 0.08;

public let waistGeneralRadius: Float = 0.70;

public let shoulderHipEarlyFallEnabled: Bool = false;

public let shoulderHipImpactFallEnabled: Bool = false;

  public let overrideBulletImpulse: Bool = false;

  public let vanillaMode: Bool = false;

public let showVanilla: Bool = false;

  public let vanillaImpulsesEnabled: Bool = false;

  public let showVanillaImpulseWeaponToggles: Bool = false;

  public let vanillaAllowHandgun: Bool = false;

  public let vanillaAllowMagnum: Bool = false;

  public let vanillaAllowSMG: Bool = false;

  public let vanillaAllowAR: Bool = false;

  public let vanillaAllowLMG: Bool = false;

  public let vanillaAllowShotgun: Bool = false;

  public let vanillaAllowSniper: Bool = false;

  public let vanillaAllowBlunt: Bool = false;

  public let vanillaAllowBlade: Bool = false;

  public let showPopFix: Bool = false;

  public let overridePopFix: Bool = true;

  public let popFix_enable: Bool = true;

  public let popFix_killBikeDeathAnim: Bool = true;

  public let popFix_killVehicleExitAnim: Bool = true;

  public let popFix_fixStaggerSnap: Bool = true;

  public let popFix_tryWorkspotExitMitigation: Bool = true;

  public let showPopFixAdvanced: Bool = false;

  public let popFix_latchWorkspot: Float = 2.250000;

  public let popFix_latchVehicle: Float = 1.600000;

  public let popFix_latchStagger: Float = 0.900000;

  public let popFix_wsPreemptDelay: Float = 0.000000;

  public let popFix_pulse0: Float = 0.000000;

  public let popFix_pulse1: Float = 0.020000;

  public let popFix_pulse2: Float = 0.050000;

  public let popFix_pulse3: Float = 0.140000;

  public let showAD: Bool = false;

}
