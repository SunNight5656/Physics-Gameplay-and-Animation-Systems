module RealisticPush

private func GetBool(key: String, fallback: Bool) -> Bool {
  return fallback;
}

private func GetFloat(key: String, fallback: Float) -> Float {
  return fallback;
}

private func RFC_ClampI(x: Int32, lo: Int32, hi: Int32) -> Int32 {
  if x < lo {
    return lo;
  }
  if x > hi {
    return hi;
  }
  return x;
}

public func RFC_ClampT(t: Float) -> Float {
  return t < 0.001 ? 0.001 : t;
}

private func RFC_ClampF(x: Float, lo: Float, hi: Float) -> Float {
  if x < lo {
    return lo;
  }
  if x > hi {
    return hi;
  }
  return x;
}

public enum RFCSplatPresetMode {
  Realism = 0,
  RealismPlus = 4,
  DirtyHarry = 2,
  Arnold = 3,
  Vanilla = 5
}

// CONFIG STRUCTS

public struct RFC_GlobalRampConfig {
  public let enabled: Bool;
  public let steps: Int32;
  public let stepTime: Float;

  public let reverse: Bool;
  public let altShape: Bool;
  public let falloffMode: Int32; // 0 = exp, 1 = linear
}

// Workspot-style config block
public struct RFC_WSKindConfig {
  public let headFwd: Float;
  public let headDown: Float;
  public let headRadius: Float;
  public let headDelay: Float;

  public let chestFwd: Float;
  public let chestFwdMin: Float;
  public let chestDown: Float;
  public let chestDownMin: Float;
  public let chestRadius: Float;
  public let chestDelay: Float;

  public let pelvisFwd: Float;
  public let pelvisFwdMin: Float;
  public let pelvisDown: Float;
  public let pelvisDownMin: Float;
  public let pelvisRadius: Float;
  public let pelvisDelay: Float;

  public let kneeDown: Float;
  public let kneeDownMin: Float;
  public let kneeRadius: Float;
  public let kneeDelay: Float;

  public let shinDown: Float;
  public let shinRadius: Float;
  public let shinDelay1: Float;
  public let shinDelay2: Float;

  public let footFwd: Float;
  public let footDown: Float;
  public let footRadius: Float;
  public let footDelay: Float;

  public let settleFwd: Float;
  public let settleDown: Float;
  public let settleRadius: Float;
  public let settleDelay: Float;

  public let body_vSlamZ: Float;
  public let body_vSlamDelay: Float;
  public let body_vSlamRadius: Float;
}

// Cower config
public struct RFC_CowerConfig {
  public let headDown: Float;
  public let headDownMin: Float;
  public let headRadius: Float;
  public let headDelay: Float;

  public let chestDown: Float;
  public let chestDownMin: Float;
  public let chestRadius: Float;
  public let chestDelay: Float;

  public let pelvisDown: Float;
  public let pelvisDownMin: Float;
  public let pelvisRadius: Float;
  public let pelvisDelay: Float;

  public let kneeDown: Float;
  public let kneeDownMin: Float;
  public let kneeDelay: Float;
  public let kneeRadius: Float;

  public let shinDown: Float;
  public let shinRadius: Float;
  public let shinDelay: Float;

  public let settleDown: Float;
  public let settleRadius: Float;
  public let settleDelay: Float;

  public let antiTuckZ: Float;
  public let antiTuckZMin: Float;
  public let antiTuckRadius: Float;
  public let antiTuckDelay: Float;
}

// Master runtime config
public struct RFCConfig {
  public let skipDeathAnim: Bool;
  public let killMotorcycleDeathAnim: Bool;
  public let animCompatDelay: Float;
  public let vanillaMode: Bool;
  public let masterDeathChanceEnabled: Bool;
  public let masterDeathChance: Float;
  public let disableAllImpulsesDuringTimeDilation: Bool;
  public let respectCinematics: Bool;
  public let stealthRagdollsEnabled: Bool;   // master toggle
  public let stealthRagdollDelay: Float;     // seconds after stealth/finisher
  public let blackwallCountsAsStealth: Bool; // treat Blackwall-tag effects as stealth
  public let deathAnimChance: Float;         // 0.0 to 1.0

  // SPLAT named preset selector: Realism / RealismPlus / DirtyHarry / Arnold
  public let splatPresetMode: Int32;

  // Vanilla impulses whitelist override
  public let vanillaImpulsesEnabled: Bool;

  public let vanillaAllowHandgun: Bool;
  public let vanillaAllowMagnum: Bool;
  public let vanillaAllowShotgun: Bool;
  public let vanillaAllowSniper: Bool;
  public let vanillaAllowSMG: Bool;
  public let vanillaAllowAR: Bool;
  public let vanillaAllowLMG: Bool;
  public let vanillaAllowBlunt: Bool;
  public let vanillaAllowBlade: Bool;

  // Live panic-run trip system
  // public let panicTripEnabled: Bool;  // master toggle
  // public let overridePanicTrip: Bool; // menu override vs defaults
  // public let panicTripChance: Float;  // 0.0 to 1.0

  // GravityBurst mini-ramp (used by DeathRouter)
  public let ramp: RFC_GlobalRampConfig;

  public let standEnabled: Bool;
  public let runEnabled: Bool;
  public let cowerEnabled: Bool;
  public let stairsEnabled: Bool;
  public let wsStandEnabled: Bool;

  public let arcadeBulletsEnabled: Bool;  // master toggle
  public let arcadeBulletStrength: Float; // horizontal shove
  public let arcadeBulletUp: Float;       // positive upward amount
  public let arcadeBulletDown: Float;     // positive downward amount; runtime subtracts it
  public let arcadeBulletRadius: Float;   // radius for impulse
  public let arcadeApplicationPointOffset: Float; // 0=hit point, 1=hips/pelvis

  public let arcadeMeleeEnabled: Bool;
  public let arcadeMeleeStrength: Float;
  public let arcadeMeleeUp: Float;
  public let arcadeMeleeDown: Float;
  public let arcadeMeleeRadius: Float;
  public let arcadeOnHitEnabled: Bool;
  public let arcadeOnDeathEnabled: Bool;
  public let arcadeUseWeaponAllowList: Bool;

  public let arcadeAllowHandgun: Bool;
  public let arcadeAllowMagnum: Bool;
  public let arcadeAllowShotgun: Bool;
  public let arcadeAllowSniper: Bool;
  public let arcadeAllowSMG: Bool;
  public let arcadeAllowAR: Bool;
  public let arcadeAllowLMG: Bool;
  public let arcadeAllowBlunt: Bool;
  public let arcadeAllowBlade: Bool;

  // Arcade hit behavior tuning
  public let arcadeBulletCooldown: Float; // anti-volleyball cooldown per target
  public let arcadeImpulseDelay: Float;   // delay before ApplyImpulse
  public let arcadeIncapRagdollEnabled: Bool; // timed ragdoll handoff during incapacitation
  public let arcadeIncapRagdollDelay: Float;  // delay before the incapacitated ragdoll handoff
  public let hitReactionsDisabled: Bool;       // prevent ordinary live bullet reactions from starting
  public let hitReactionCutoffEnabled: Bool;  // stop ordinary live bullet reaction animation
  public let hitReactionCutoffDelay: Float;   // delay before returning to normal upper-body control
  public let injuryShockEnabled: Bool;
  public let injuryShockAllowBosses: Bool;
  public let injuryShockAllowSubBosses: Bool;
  public let injuryShockAllowNPCSources: Bool;
  public let injuryShockChance: Float;
  public let injuryShockDelay: Float;
  public let injuryShockRandomDelay: Float;
  public let injuryShockGetUpDelay: Float;
  public let injuryShockGetUpRandomDelay: Float;
  public let injuryShockLimbsOnly: Bool;
  public let arcadeCowScale: Float;       // cower strength scale

  public let arcadeMulHandgun: Float;
  public let arcadeMulMagnum: Float;
  public let arcadeMulShotgun: Float;
  public let arcadeMulSniper: Float;
  public let arcadeMulSMG: Float;
  public let arcadeMulAR: Float;
  public let arcadeMulLMG: Float;
  public let arcadeMulBlunt: Float;
  public let arcadeMulBlade: Float;

  public let arcadePlayerOnly: Bool;
  public let arcadeAllowPlayerBullet: Bool;
  public let arcadeAllowNPCBullet: Bool;
  public let arcadeAllowPlayerMelee: Bool;
  public let arcadeAllowNPCMelee: Bool;
  public let arcadeIndependentSourceControls: Bool;

  // Enemy type gates / scales for arcade and Bullet Jolts
  public let enemyTypeFiltersEnabled: Bool;
  public let enemyBypassCanRagdollGate: Bool;

  public let enemyArcadeAllowMaxTac: Bool;
  public let enemyArcadeAllowBosses: Bool;
  public let enemyArcadeAllowMechs: Bool;
  public let enemyArcadeAllowRobots: Bool;
  public let enemyArcadeScaleMaxTac: Float;
  public let enemyArcadeScaleBosses: Float;
  public let enemyArcadeScaleMechs: Float;
  public let enemyArcadeScaleRobots: Float;

  public let enemyJoltAllowMaxTac: Bool;
  public let enemyJoltAllowBosses: Bool;
  public let enemyJoltAllowMechs: Bool;
  public let enemyJoltAllowRobots: Bool;
  public let enemyJoltScaleMaxTac: Float;
  public let enemyJoltScaleBosses: Float;
  public let enemyJoltScaleMechs: Float;
  public let enemyJoltScaleRobots: Float;


  // Vehicle Impulses — cars pushed by explosions, bullets, melee, and Gorilla Arms
  public let vehicleImpulseEnabled: Bool;
  public let showVehicleImpulsesAdvanced: Bool;
  public let vehicleImpulsePlayerOnly: Bool; // legacy vehicle-melee source gate
  public let vehicleBulletPlayerOnly: Bool;
  public let vehicleExplosionPlayerOnly: Bool;
  public let vehicleImpulseCooldown: Float;
  public let vehicleImpulseMassCompensation: Bool;
  public let vehicleImpulseReferenceMass: Float;
  public let vehicleImpulseMinMassScale: Float;
  public let vehicleImpulseMaxMassScale: Float;
  public let vehicleImpulseClampEnabled: Bool;
  public let vehicleImpulseMaxHorizontal: Float;
  public let vehicleImpulseMaxLift: Float;
  public let vehicleUseExplosionMultipliers: Bool;
  public let vehicleUseArcadeWeaponFilters: Bool;
  public let vehicleUseArcadeWeaponMultipliers: Bool;
  public let vehicleExplosionEnabled: Bool;
  public let vehicleExplosionStrength: Float;
  public let vehicleExplosionLift: Float;
  public let vehicleExplosionRadius: Float;
  public let vehicleBulletEnabled: Bool;
  public let vehicleBulletStrength: Float;
  public let vehicleBulletLift: Float;
  public let vehicleBulletRadius: Float;
  public let vehicleMotorcycleToppleOnBullet: Bool;
  public let vehicleMotorcycleToppleStrength: Float;
  public let playerMotorcycleLeanToppleEnabled: Bool;
  public let playerMotorcycleLeanToppleAngle: Float;
  public let playerMotorcycleLeanToppleMaxSpeed: Float;
  public let vehicleMeleeEnabled: Bool;
  public let vehicleMeleeStrength: Float;
  public let vehicleMeleeLift: Float;
  public let vehicleMeleeRadius: Float;
  public let vehicleAllowHandgun: Bool;
  public let vehicleAllowMagnum: Bool;
  public let vehicleAllowShotgun: Bool;
  public let vehicleAllowSniper: Bool;
  public let vehicleAllowSMG: Bool;
  public let vehicleAllowAR: Bool;
  public let vehicleAllowLMG: Bool;
  public let vehicleAllowBlunt: Bool;
  public let vehicleAllowBlade: Bool;
  public let vehicleAllowGorilla: Bool;
  public let vehicleAllowUnknownBullet: Bool;
  public let vehicleMulHandgun: Float;
  public let vehicleMulMagnum: Float;
  public let vehicleMulShotgun: Float;
  public let vehicleMulSniper: Float;
  public let vehicleMulSMG: Float;
  public let vehicleMulAR: Float;
  public let vehicleMulLMG: Float;
  public let vehicleMulBlunt: Float;
  public let vehicleMulBlade: Float;
  public let vehicleMulGorilla: Float;
  public let vehicleMulUnknownBullet: Float;

  // v5 vehicle occupant shield: protects puppet impulses without disabling the
  // VehicleObject impulse feature.
  public let vehicleOccupantShieldEnabled: Bool;
  public let vehicleMountedHitImmunity: Bool;
  public let vehicleOccupantShieldTime: Float;
  public let vehicleExitShieldEnabled: Bool;
  public let vehicleExitShieldTime: Float;

  public let explPlayerOnly: Bool;

  public let run_headRadius: Float;
  public let run_chestRadius: Float;
  public let run_pelvisRadius: Float;
  public let run_vSlamRadius: Float;
  public let run_headSlam2Delay: Float;

  public let overrideStand: Bool;
  public let overrideRun: Bool;
  public let overrideCower: Bool;
  public let overrideStairs: Bool;
  public let overrideWsStand: Bool;
  public let overrideWalk: Bool;

  public let st_overrideGlobalHead: Bool;
  public let st_overrideGlobalForward: Bool;
  public let st_overrideGlobalChest: Bool;
  public let st_overrideGlobalPelvis: Bool;
  public let st_overrideGlobalKnees: Bool;


  public let run_overrideGlobalForward: Bool;
  public let run_overrideGlobalHead: Bool;
  public let run_overrideGlobalChest: Bool;
  public let run_overrideGlobalPelvis: Bool;
  public let run_overrideGlobalKnees: Bool;


  public let cow_overrideGlobalForward: Bool;
  public let cow_overrideGlobalHead: Bool;
  public let cow_overrideGlobalChest: Bool;
  public let cow_overrideGlobalPelvis: Bool;
  public let cow_overrideGlobalKnees: Bool;


  public let stair_overrideGlobalForward: Bool;
  public let stair_overrideGlobalHead: Bool;
  public let stair_overrideGlobalChest: Bool;
  public let stair_overrideGlobalPelvis: Bool;
  public let stair_overrideGlobalKnees: Bool;


  public let wsStand_overrideGlobalForward: Bool;
  public let wsStand_overrideGlobalChest: Bool;
  public let wsStand_overrideGlobalPelvis: Bool;
  public let wsStand_overrideGlobalKnees: Bool;


  public let killImpulsesVehiclesOnly: Bool;
  public let killImpulsesEverywhere: Bool;

  // POPFIX (workspot / vehicle / stagger) + gating
  public let popFixEnabled: Bool;
  public let popFix_useGate: Bool;

  // Override spots: force PopFix reason even if detection fails
  public let popFix_overrideWorkspot: Bool;
  public let popFix_overrideVehicle: Bool;
  public let popFix_overrideStagger: Bool;

  // Feature toggles
  public let popFix_staggerSnap: Bool;
  public let popFix_workspotPreemptExit: Bool;

  // IMPORTANT: these must only be used in the vehicle/bike latch window
  public let popFix_vehicleKillExitAnim: Bool;
  public let popFix_bikeKillExitAnim: Bool;

  // POP / EXIT MITIGATION
  public let killBikeDeathAnim: Bool;
  public let killVehicleDeathAnim: Bool;
  public let mitigateWorkspotExitPop: Bool;
  public let mitigateStaggerPop: Bool;

  // TIMINGS (seconds)
  public let ws_ragdollBurstTime: Float;  // workspot snap window
  public let veh_ragdollBurstTime: Float; // vehicle unmount window
  public let stagger_ragdollBurstTime: Float;

  // Timings / pulses
  public let popFix_latchWorkspot: Float;
  public let popFix_latchVehicle: Float;
  public let popFix_latchStagger: Float;

  public let popFix_wsPreemptDelay: Float;

  public let popFix_pulse0: Float;
  public let popFix_pulse1: Float;
  public let popFix_pulse2: Float;
  public let popFix_pulse3: Float;

  public let settleEnabled: Bool;
  public let settleStrength: Float;
  public let settleDelay: Float;
  public let settleFwd: Float;
  public let settleDown: Float;
  public let settleRadius: Float;
  public let overrideSettle: Bool;

  public let overrideGrenade: Bool;
  public let overrideBulletImpulse: Bool;

  public let grenadeEnabled: Bool;

  public let grenadeExceptionFrag: Bool;
  public let grenadeExceptionFlash: Bool;
  public let grenadeExceptionSmoke: Bool;
  public let grenadeExceptionPiercing: Bool;
  public let grenadeExceptionEMP: Bool;
  public let grenadeExceptionBiohazard: Bool;
  public let grenadeExceptionIncendiary: Bool;
  public let grenadeExceptionRecon: Bool;
  public let grenadeExceptionCutting: Bool;
  public let grenadeExceptionSonic: Bool;
  public let grenadeExceptionOzob: Bool;


  // New tumble helpers
  public let tumbleEnabled: Bool;            // stairs tumble
  public let directionalTumbleEnabled: Bool; // roll-resolve directional (workspot/cower/stand)

  // Tumble advanced (only used when override flags are enabled in DeathRouter)
  public let overrideTumbleStairs: Bool;
  public let tumbleStairs_delay: Float;
  public let tumbleStairs_down: Float;
  public let tumbleStairs_fwd: Float;
  public let tumbleStairs_side: Float;
  public let tumbleStairs_downDelay: Float;
  public let tumbleStairs_fwdDelay: Float;
  public let tumbleStairs_sideDelay: Float;
  public let tumbleStairs_radius: Float;
  public let tumbleStairs_yawDeg: Float;
  public let tumbleStairs_pitchDeg: Float;
  public let tumbleStairs_rollDeg: Float;

  public let overrideTumbleDirectional: Bool;
  public let tumbleDir_down: Float;
  public let tumbleDir_fwd: Float;
  public let tumbleDir_side: Float;
  public let tumbleDir_downDelay: Float;
  public let tumbleDir_fwdDelay: Float;
  public let tumbleDir_sideDelay: Float;
  public let tumbleDir_radius: Float;

  public let tumbleStairs_startBase: Float;
  public let tumbleStairs_startScale: Float;
  public let tumbleStairs_startCap: Float;
  public let tumbleStairs_startDelay: Float;
  public let tumbleStairs_stepDelay: Float;
  public let tumbleStairs_steps: Int32;

  public let tumbleDir_startBase: Float;
  public let tumbleDir_startScale: Float;
  public let tumbleDir_startCap: Float;
  public let tumbleDir_startDelay: Float;
  public let tumbleDir_stepDelay: Float;
  public let tumbleDir_steps: Int32;


  // Hit Jolts / Bullet Jolts runtime controls for named modes.
  // Custom mode uses the normal SHHJM_Settings sliders with neutral scale.
  public let bulletJoltsEnabled: Bool;
  public let bulletJoltStrengthScale: Float;
  public let bulletJoltRadiusScale: Float;
  public let bulletJoltDelayScale: Float;
  public let bulletJoltWaitForGround: Bool;
  public let bulletJoltGroundWaitMax: Float;
  public let bulletJoltAllowAirborne: Bool;
  public let headReboundKneeNearPct: Float;

  public let grenadeKickRadius: Float;
  public let grenadeKickX: Float;
  public let grenadeKickY: Float;
  public let grenadeKickZ: Float;
  public let grenadeKickCallDelay: Float;

  public let showExplosionsAdvanced: Bool;

  public let explAffectGrenades: Bool;
  public let explAffectWeapon: Bool;
  public let explAffectBullet: Bool;
  public let explAffectVehicle: Bool;

  public let explMulGrenades: Float;
  public let explMulWeapon: Float;
  public let explMulBullet: Float;
  public let explMulVehicle: Float;

  public let twitchChance: Float;
  public let twitchStrengthMin: Float;
  public let twitchStrengthMax: Float;
  public let twitchDelayStart: Float;
  public let twitchDelayStepMin: Float;
  public let twitchDelayStepMax: Float;
  public let twitchDuration: Float;
  public let twitchForce: Float;
  public let twitchEnabled: Bool;
  public let overrideTwitch: Bool;

  public let walkEnabled: Bool;
  public let randomImpulsesEnabled: Bool;
  public let randomImpulseChancePct: Float;
  public let randomDisableGroupsEnabled: Bool;
  public let randomDisableChancePct: Float;
  public let randomMaxDisabledGroups: Int32;
  public let randomPoolHead: Bool;
  public let randomCanDisableHead: Bool;
  public let randomPoolBody: Bool;
  public let randomCanDisableBody: Bool;
  public let randomPoolShoulderWaist: Bool;
  public let randomCanDisableShoulderWaist: Bool;
  public let randomPoolSituational: Bool;
  public let randomCanDisableSituational: Bool;
  public let shoulderHipFallsEnabled: Bool;
  public let shoulderHipEarlyShoulderEnabled: Bool;
  public let shoulderHipEarlyButtEnabled: Bool;
  public let shoulderHipImpactShoulderEnabled: Bool;
  public let shoulderHipImpactButtEnabled: Bool;
  public let shoulderGeneralStrength: Float;
  public let shoulderGeneralDelay: Float;
  public let shoulderGeneralRadius: Float;
  public let waistGeneralStrength: Float;
  public let waistGeneralDelay: Float;
  public let waistGeneralRadius: Float;
  public let shoulderHipEarlyFallEnabled: Bool;
  public let shoulderHipEarlyShoulderStrength: Float;
  public let shoulderHipEarlyShoulderStrengthMin: Float;
  public let shoulderHipEarlyHipStrength: Float;
  public let shoulderHipEarlyHipStrengthMin: Float;
  public let shoulderHipEarlyDelay: Float;
  public let shoulderHipEarlyRadius: Float;
  public let shoulderHipImpactFallEnabled: Bool;
  public let shoulderHipImpactShoulderStrength: Float;
  public let shoulderHipImpactShoulderStrengthMin: Float;
  public let shoulderHipImpactHipStrength: Float;
  public let shoulderHipImpactHipStrengthMin: Float;
  public let shoulderHipImpactDelay: Float;
  public let shoulderHipImpactRadius: Float;

  public let walk_forward: Float;
  public let walk_forwardDelay: Float;

  public let walk_downHead: Float;
  public let walk_downChest: Float;
  public let walk_downPelvis: Float;

  public let walk_kneeDown: Float;
  public let walk_vSlamZ: Float;

  public let walk_d_headBias: Float;
  public let walk_d_headSlam: Float;
  public let walk_d_chestFall: Float;
  public let walk_d_pelvisFall: Float;
  public let walk_d_knee: Float;
  public let walk_d_vSlam: Float;

  public let stair_forward: Float;
  public let stair_forwardMin: Float;
  public let stair_forwardRadius: Float;
  public let stair_headRadius: Float;
  public let stair_chestRadius: Float;
  public let stair_pelvisRadius: Float;
  public let stair_downHead: Float;
  public let stair_downHeadMin: Float;
  public let stair_downChest: Float;
  public let stair_downChestMin: Float;
  public let stair_downPelvis: Float;
  public let stair_downPelvisMin: Float;
  public let stair_vSlamZ: Float;
  public let stair_vSlamZMin: Float;

  public let stair_kneeDown: Float;
  public let stair_kneeDownMin: Float;
  public let stair_kneeDelay: Float;
  public let stair_kneeRadius: Float;

  public let stair_brakeFwd: Float;
  public let stair_brakeFwdMin: Float;
  public let stair_brakeDelay: Float;
  public let stair_brakeRadius: Float;

  public let stair_headFwd: Float;
  public let stair_headFwdMin: Float;
  public let stair_chestFwd: Float;
  public let stair_chestFwdMin: Float;

  public let stair_plankEnabled: Bool;
  public let stair_plankHeadDown: Float;
  public let stair_plankHeadDownMin: Float;
  public let stair_plankChestDown: Float;
  public let stair_plankChestDownMin: Float;
  public let stair_plankPelvisDown: Float;
  public let stair_plankPelvisDownMin: Float;
  public let stair_plankFwd: Float;
  public let stair_plankFwdMin: Float;
  public let stair_plankRadius: Float;
  public let stair_plankDelay: Float;
  public let stair_plankBrakeFwd: Float;
  public let stair_plankBrakeFwdMin: Float;
  public let stair_plankBrakeDelay: Float;
  public let stair_plankBrakeRadius: Float;

  public let stair_runUseKnees: Bool;
  public let stair_runFeetDown: Float;
  public let stair_runFeetDelay: Float;
  public let stair_runFeetRadius: Float;

  public let st_forward: Float;
  public let st_forwardMin: Float;
  public let st_forwardRadius: Float;
  public let st_headRadius: Float;
  public let st_chestRadius: Float;
  public let st_pelvisRadius: Float;
  public let st_kneeRadius: Float;
  public let st_downHead: Float;
  public let st_downHeadMin: Float;
  public let st_downChest: Float;
  public let st_downChestMin: Float;
  public let st_downPelvis: Float;
  public let st_downPelvisMin: Float;
  public let st_kneeDown: Float;
  public let st_kneeDownMin: Float;
  public let st_vSlamZ: Float;

  public let st_forwardDelay: Float;

  public let st_d_base: Float;
  public let st_d_headBias: Float;
  public let st_d_headSlam: Float;
  public let st_d_headSnap: Float;
  public let st_d_chestFall: Float;
  public let st_d_pelvisFall: Float;
  public let st_d_knee: Float;
  public let st_d_vSlam: Float;

  public let st_shinDelay1: Float;
  public let st_shinDelay2: Float;
  public let st_shinBack: Float;
  public let st_shinDown: Float;
  public let st_shinRadius: Float;

  public let st_footDelay: Float;
  public let st_footFwd: Float;
  public let st_footDown: Float;
  public let st_footRadius: Float;

  public let st_antiTuckDelay: Float;
  public let st_antiTuckZ: Float;
  public let st_antiTuckRadius: Float;

  public let st_anchorOffset: Float;
  public let st_anchorFwd: Float;
  public let st_anchorDown: Float;
  public let st_anchorRadius: Float;

  public let run_forward: Float;
  public let run_forwardMin: Float;
  public let run_forwardRadius: Float;
  public let run_downHead: Float;
  public let run_downHeadMin: Float;
  public let run_downChest: Float;
  public let run_downChestMin: Float;
  public let run_downPelvis: Float;
  public let run_downPelvisMin: Float;
  public let run_kneeDown: Float;
  public let run_kneeDownMin: Float;
  public let run_kneeRadius: Float;
  public let run_vSlamZ: Float;

  public let run_forwardDelay: Float;

  public let run_d_headBias: Float;
  public let run_d_headSlam: Float;
  public let run_d_chestFall: Float;
  public let run_d_pelvisFall: Float;
  public let run_d_knee: Float;
  public let run_d_vSlam: Float;

  public let run_shinDelay1: Float;
  public let run_shinDelay2: Float;
  public let run_shinBack: Float;
  public let run_shinDown: Float;
  public let run_shinRadius: Float;

  public let run_footDelay: Float;
  public let run_footFwd: Float;
  public let run_footDown: Float;
  public let run_footRadius: Float;

  public let run_anchorOffset: Float;
  public let run_anchorFwd: Float;
  public let run_anchorDown: Float;
  public let run_anchorRadius: Float;

  public let wsSit: RFC_WSKindConfig;
  public let wsLedge: RFC_WSKindConfig;
  public let wsLean: RFC_WSKindConfig;
  public let wsStand: RFC_WSKindConfig;
  public let wsCar: RFC_WSKindConfig;
  public let wsMoto: RFC_WSKindConfig;

  public let cow: RFC_CowerConfig;
}

// Runtime Config Builder
public class RFC {
  public static func Cfg() -> RFCConfig {
    let c: RFCConfig;
    let menu: ref<RFCModSettings> = SPLATSettingsRuntime.Menu();
    let headSettings: ref<HIS_Settings> = SPLATSettingsRuntime.Head();

    c.headReboundKneeNearPct = RFC_ClampF(headSettings.reboundKneeNearPct, 0.0, 100.0);

    c.splatPresetMode = EnumInt(menu.splatPresetMode);
    // v15: legacy/invalid saved mode values fall back to Realism.
    if c.splatPresetMode != EnumInt(RFCSplatPresetMode.Realism)
      && c.splatPresetMode != EnumInt(RFCSplatPresetMode.RealismPlus)
      && c.splatPresetMode != EnumInt(RFCSplatPresetMode.DirtyHarry)
      && c.splatPresetMode != EnumInt(RFCSplatPresetMode.Arnold)
      && c.splatPresetMode != EnumInt(RFCSplatPresetMode.Vanilla) {
      c.splatPresetMode = EnumInt(RFCSplatPresetMode.Realism);
    }

    // Vanilla is now selected only from SPLAT Mode. Installed ragdoll rigs are
    // external assets and remain untouched by this runtime bypass.
    c.vanillaMode = c.splatPresetMode == EnumInt(RFCSplatPresetMode.Vanilla);

    // Core toggles
    c.masterDeathChanceEnabled = menu.masterDeathChanceEnabled;
    c.masterDeathChance = ClampF(menu.masterDeathChancePct * 0.01, 0.0, 1.0);
    c.disableAllImpulsesDuringTimeDilation = menu.disableAllImpulsesDuringTimeDilation;
    c.respectCinematics = menu.respectCinematics;
    c.skipDeathAnim = menu.skipDeathAnim;
    c.killMotorcycleDeathAnim = menu.killMotorcycleDeathAnim;
    c.animCompatDelay = menu.animCompatDelay;
    // Shoulder and Waist Falls is a separate system with its own master.
    c.shoulderHipFallsEnabled = menu.shoulderHipFallsEnabled;
    c.shoulderHipEarlyShoulderEnabled = menu.shoulderHipEarlyShoulderEnabled;
    c.shoulderHipEarlyButtEnabled = menu.shoulderHipEarlyButtEnabled;
    c.shoulderHipImpactShoulderEnabled = menu.shoulderHipImpactShoulderEnabled;
    c.shoulderHipImpactButtEnabled = menu.shoulderHipImpactButtEnabled;
    c.shoulderGeneralStrength = RFC_ClampF(menu.shoulderGeneralStrength, 0.0, 200.0);
    c.shoulderGeneralDelay = RFC_ClampF(menu.shoulderGeneralDelay, 0.0, 6.0);
    c.shoulderGeneralRadius = RFC_ClampF(menu.shoulderGeneralRadius, 0.1, 12.0);
    c.waistGeneralStrength = RFC_ClampF(menu.waistGeneralStrength, 0.0, 200.0);
    c.waistGeneralDelay = RFC_ClampF(menu.waistGeneralDelay, 0.0, 6.0);
    c.waistGeneralRadius = RFC_ClampF(menu.waistGeneralRadius, 0.1, 12.0);
    c.shoulderHipEarlyFallEnabled = menu.shoulderHipFallsEnabled
      && (menu.shoulderHipEarlyShoulderEnabled || menu.shoulderHipEarlyButtEnabled);
    c.shoulderHipEarlyShoulderStrength = RFC_ClampF(menu.shoulderHipEarlyShoulderStrength, 0.0, 200.0);
    c.shoulderHipEarlyShoulderStrengthMin = RFC_ClampF(menu.shoulderHipEarlyShoulderStrengthMin, 0.0, 200.0);
    c.shoulderHipEarlyHipStrength = RFC_ClampF(menu.shoulderHipEarlyHipStrength, 0.0, 200.0);
    c.shoulderHipEarlyHipStrengthMin = RFC_ClampF(menu.shoulderHipEarlyHipStrengthMin, 0.0, 200.0);
    c.shoulderHipEarlyDelay = RFC_ClampF(menu.shoulderHipEarlyDelay, 0.0, 6.0);
    c.shoulderHipEarlyRadius = RFC_ClampF(menu.shoulderHipEarlyRadius, 0.1, 12.0);
    c.shoulderHipImpactFallEnabled = menu.shoulderHipFallsEnabled
      && (menu.shoulderHipImpactShoulderEnabled || menu.shoulderHipImpactButtEnabled);
    c.shoulderHipImpactShoulderStrength = RFC_ClampF(menu.shoulderHipImpactShoulderStrength, 0.0, 200.0);
    c.shoulderHipImpactShoulderStrengthMin = RFC_ClampF(menu.shoulderHipImpactShoulderStrengthMin, 0.0, 200.0);
    c.shoulderHipImpactHipStrength = RFC_ClampF(menu.shoulderHipImpactHipStrength, 0.0, 200.0);
    c.shoulderHipImpactHipStrengthMin = RFC_ClampF(menu.shoulderHipImpactHipStrengthMin, 0.0, 200.0);
    c.shoulderHipImpactDelay = RFC_ClampF(menu.shoulderHipImpactDelay, 0.0, 6.0);
    c.shoulderHipImpactRadius = RFC_ClampF(menu.shoulderHipImpactRadius, 0.1, 12.0);

    c.arcadePlayerOnly = menu.arcadePlayerOnly;
    c.arcadeIndependentSourceControls = false;
    c.arcadeAllowPlayerBullet = true;
    c.arcadeAllowNPCBullet = !c.arcadePlayerOnly;
    c.arcadeAllowPlayerMelee = true;
    c.arcadeAllowNPCMelee = !c.arcadePlayerOnly;
    c.explPlayerOnly = menu.explPlayerOnly;

    c.grenadeExceptionFrag = menu.grenadeExceptionFrag;
    c.grenadeExceptionFlash = menu.grenadeExceptionFlash;
    c.grenadeExceptionSmoke = menu.grenadeExceptionSmoke;
    c.grenadeExceptionPiercing = menu.grenadeExceptionPiercing;
    c.grenadeExceptionEMP = menu.grenadeExceptionEMP;
    c.grenadeExceptionBiohazard = menu.grenadeExceptionBiohazard;
    c.grenadeExceptionIncendiary = menu.grenadeExceptionIncendiary;
    c.grenadeExceptionRecon = menu.grenadeExceptionRecon;
    c.grenadeExceptionCutting = menu.grenadeExceptionCutting;
    c.grenadeExceptionSonic = menu.grenadeExceptionSonic;
    c.grenadeExceptionOzob = menu.grenadeExceptionOzob;

    c.enemyTypeFiltersEnabled = menu.enemyTypeFiltersEnabled;
    c.enemyBypassCanRagdollGate = menu.enemyBypassCanRagdollGate;

    c.enemyArcadeAllowMaxTac = menu.enemyArcadeAllowMaxTac;
    c.enemyArcadeAllowBosses = menu.enemyArcadeAllowBosses;
    c.enemyArcadeAllowMechs = menu.enemyArcadeAllowMechs;
    c.enemyArcadeAllowRobots = menu.enemyArcadeAllowRobots;
    c.enemyArcadeScaleMaxTac = RFC_ClampF(menu.enemyArcadeScaleMaxTac, 0.0, 5.0);
    c.enemyArcadeScaleBosses = RFC_ClampF(menu.enemyArcadeScaleBosses, 0.0, 5.0);
    c.enemyArcadeScaleMechs = RFC_ClampF(menu.enemyArcadeScaleMechs, 0.0, 5.0);
    c.enemyArcadeScaleRobots = RFC_ClampF(menu.enemyArcadeScaleRobots, 0.0, 5.0);

    c.enemyJoltAllowMaxTac = menu.enemyJoltAllowMaxTac;
    c.enemyJoltAllowBosses = menu.enemyJoltAllowBosses;
    c.enemyJoltAllowMechs = menu.enemyJoltAllowMechs;
    c.enemyJoltAllowRobots = menu.enemyJoltAllowRobots;
    c.enemyJoltScaleMaxTac = RFC_ClampF(menu.enemyJoltScaleMaxTac, 0.0, 5.0);
    c.enemyJoltScaleBosses = RFC_ClampF(menu.enemyJoltScaleBosses, 0.0, 5.0);
    c.enemyJoltScaleMechs = RFC_ClampF(menu.enemyJoltScaleMechs, 0.0, 5.0);
    c.enemyJoltScaleRobots = RFC_ClampF(menu.enemyJoltScaleRobots, 0.0, 5.0);


    // Vehicle Impulses (standalone vehicle shove layer)
    c.vehicleImpulseEnabled = menu.vehicleImpulseEnabled;
    c.showVehicleImpulsesAdvanced = menu.showVehicleImpulsesAdvanced;
    c.vehicleImpulsePlayerOnly = menu.vehicleImpulsePlayerOnly;
    c.vehicleBulletPlayerOnly = menu.vehicleBulletPlayerOnly;
    c.vehicleExplosionPlayerOnly = menu.vehicleExplosionPlayerOnly;
    c.vehicleImpulseCooldown = RFC_ClampF(menu.vehicleImpulseCooldown, 0.0, 3.0);
    c.vehicleImpulseMassCompensation = menu.vehicleImpulseMassCompensation;
    c.vehicleImpulseReferenceMass = RFC_ClampF(menu.vehicleImpulseReferenceMass, 100.0, 16900.0);
    c.vehicleImpulseMinMassScale = RFC_ClampF(menu.vehicleImpulseMinMassScale, 0.10, 10.0);
    c.vehicleImpulseMaxMassScale = RFC_ClampF(menu.vehicleImpulseMaxMassScale, 0.10, 10.0);
    if c.vehicleImpulseMaxMassScale < c.vehicleImpulseMinMassScale {
      c.vehicleImpulseMaxMassScale = c.vehicleImpulseMinMassScale;
    }
    c.vehicleImpulseClampEnabled = menu.vehicleImpulseClampEnabled;
    c.vehicleImpulseMaxHorizontal = RFC_ClampF(menu.vehicleImpulseMaxHorizontal, 0.0, 16900.0);
    c.vehicleImpulseMaxLift = RFC_ClampF(menu.vehicleImpulseMaxLift, 0.0, 16900.0);
    c.vehicleUseExplosionMultipliers = menu.vehicleUseExplosionMultipliers;
    c.vehicleUseArcadeWeaponFilters = menu.vehicleUseArcadeWeaponFilters;
    c.vehicleUseArcadeWeaponMultipliers = menu.vehicleUseArcadeWeaponMultipliers;
    // VehicleObject explosions own this multiplier independently from the NPC
    // "vehicle impacts affect NPCs" source gate below.
    c.explMulVehicle = RFC_ClampF(menu.explMulVehicle, 0.0, 30.0);

    c.vehicleExplosionEnabled = menu.vehicleExplosionEnabled;
    c.vehicleExplosionStrength = RFC_ClampF(menu.vehicleExplosionStrength, 0.0, 16900.0);
    c.vehicleExplosionLift = RFC_ClampF(menu.vehicleExplosionLift, 0.0, 16900.0)
      - RFC_ClampF(menu.vehicleExplosionDown, 0.0, 16900.0);
    c.vehicleExplosionRadius = RFC_ClampF(menu.vehicleExplosionRadius, 0.05, 20.0);

    c.vehicleBulletEnabled = menu.vehicleBulletEnabled;
    c.vehicleBulletStrength = RFC_ClampF(menu.vehicleBulletStrength, 0.0, 8000.0);
    c.vehicleBulletLift = RFC_ClampF(menu.vehicleBulletLift, 0.0, 8000.0)
      - RFC_ClampF(menu.vehicleBulletDown, 0.0, 8000.0);
    c.vehicleBulletRadius = RFC_ClampF(menu.vehicleBulletRadius, 0.05, 20.0);
    // Motorcycle controls are global so Standard/Custom and every named mode
    // use the same toppling actuator. Arnold may still expose the same controls
    // in its Vehicles page, but it no longer owns the feature exclusively.
    c.vehicleMotorcycleToppleOnBullet = menu.arnold_vehicleMotorcycleToppleOnBullet;
    c.vehicleMotorcycleToppleStrength = RFC_ClampF(menu.arnold_vehicleMotorcycleToppleStrength, 0.0, 12.0);
    c.playerMotorcycleLeanToppleEnabled = menu.arnold_playerMotorcycleLeanToppleEnabled;
    c.playerMotorcycleLeanToppleAngle = RFC_ClampF(menu.arnold_playerMotorcycleLeanToppleAngle, 5.0, 90.0);
    c.playerMotorcycleLeanToppleMaxSpeed = RFC_ClampF(menu.arnold_playerMotorcycleLeanToppleMaxSpeed, 0.0, 100.0);

    c.vehicleMeleeEnabled = menu.vehicleMeleeEnabled;
    c.vehicleMeleeStrength = RFC_ClampF(menu.vehicleMeleeStrength, 0.0, 8000.0);
    c.vehicleMeleeLift = RFC_ClampF(menu.vehicleMeleeLift, 0.0, 8000.0)
      - RFC_ClampF(menu.vehicleMeleeDown, 0.0, 8000.0);
    c.vehicleMeleeRadius = RFC_ClampF(menu.vehicleMeleeRadius, 0.05, 20.0);

    c.vehicleAllowHandgun = menu.vehicleAllowHandgun;
    c.vehicleAllowMagnum = menu.vehicleAllowMagnum;
    c.vehicleAllowShotgun = menu.vehicleAllowShotgun;
    c.vehicleAllowSniper = menu.vehicleAllowSniper;
    c.vehicleAllowSMG = menu.vehicleAllowSMG;
    c.vehicleAllowAR = menu.vehicleAllowAR;
    c.vehicleAllowLMG = menu.vehicleAllowLMG;
    c.vehicleAllowBlunt = menu.vehicleAllowBlunt;
    c.vehicleAllowBlade = menu.vehicleAllowBlade;
    c.vehicleAllowGorilla = menu.vehicleAllowGorilla;
    c.vehicleAllowUnknownBullet = menu.vehicleAllowUnknownBullet;

    c.vehicleMulHandgun = RFC_ClampF(menu.vehicleMulHandgun, 0.0, 20.0);
    c.vehicleMulMagnum = RFC_ClampF(menu.vehicleMulMagnum, 0.0, 20.0);
    c.vehicleMulShotgun = RFC_ClampF(menu.vehicleMulShotgun, 0.0, 20.0);
    c.vehicleMulSniper = RFC_ClampF(menu.vehicleMulSniper, 0.0, 20.0);
    c.vehicleMulSMG = RFC_ClampF(menu.vehicleMulSMG, 0.0, 20.0);
    c.vehicleMulAR = RFC_ClampF(menu.vehicleMulAR, 0.0, 20.0);
    c.vehicleMulLMG = RFC_ClampF(menu.vehicleMulLMG, 0.0, 20.0);
    c.vehicleMulBlunt = RFC_ClampF(menu.vehicleMulBlunt, 0.0, 20.0);
    c.vehicleMulBlade = RFC_ClampF(menu.vehicleMulBlade, 0.0, 20.0);
    c.vehicleMulGorilla = RFC_ClampF(menu.vehicleMulGorilla, 0.0, 20.0);
    c.vehicleMulUnknownBullet = RFC_ClampF(menu.vehicleMulUnknownBullet, 0.0, 20.0);

    c.vehicleOccupantShieldEnabled = menu.vehicleOccupantShieldEnabled;
    c.vehicleMountedHitImmunity = menu.vehicleMountedHitImmunity;
    c.vehicleOccupantShieldTime = RFC_ClampF(menu.vehicleOccupantShieldTime, 0.0, 3.0);
    c.vehicleExitShieldEnabled = menu.vehicleExitShieldEnabled;
    c.vehicleExitShieldTime = RFC_ClampF(menu.vehicleExitShieldTime, 0.0, 3.0);

    // Death animation chance
    if c.skipDeathAnim {
      c.deathAnimChance = 0.0;
    } else {
      c.deathAnimChance = ClampF(menu.deathAnimChancePct * 0.01, 0.0, 1.0);
    }

    // Stealth / finisher options
    c.stealthRagdollsEnabled = true;
    c.blackwallCountsAsStealth = false;
    c.stealthRagdollDelay = 2.0;

    c.stealthRagdollsEnabled = menu.stealthRagdollsEnabled;
    c.blackwallCountsAsStealth = menu.blackwallCountsAsStealth;

    // 0.00 means use default
    if menu.stealthRagdollDelay > 0.0 {
      c.stealthRagdollDelay = menu.stealthRagdollDelay;
    }

    c.tumbleEnabled = true;
    c.directionalTumbleEnabled = false;

    // Ramp defaults
    c.ramp.enabled = true;
    c.ramp.steps = 11;
    c.ramp.stepTime = 1.004000;
    c.ramp.reverse = false;
    c.ramp.altShape = true;
    c.ramp.falloffMode = 1; // linear

    // Override ramp values
    if menu.overrideGravity {
      // 0 = Realistic
      // 1 = Gravity+
      // 2 = Cinematic
      switch menu.gravityMode {
        case 0:
          c.ramp.steps = 3;
          c.ramp.stepTime = 0.010;
          break;
        case 1:
          c.ramp.steps = 6;
          c.ramp.stepTime = 0.016;
          break;
        default:
          c.ramp.steps = 8;
          c.ramp.stepTime = 0.022;
          break;
      }

      // Falloff mode selector (0 = exp, 1 = linear)
      c.ramp.falloffMode = menu.gravityFalloffMode;

      if menu.gravityBurstEnabled {
        c.ramp.steps = RFC_ClampI(menu.gravityBurstSteps, 1, 15);

        // 0 keeps spacing from the selected gravityMode
        if menu.gravityBurstStepTime > 0.0 {
          c.ramp.stepTime = menu.gravityBurstStepTime;
        }

        c.ramp.reverse = menu.gravityBurstReverse;
        c.ramp.altShape = menu.gravityBurstAltShape;
      } else {
        c.ramp.reverse = false;
        c.ramp.altShape = false;
      }
    }

    // Master enable
    c.ramp.enabled = menu.gravityEnabled;
    if !c.ramp.enabled {
      c.ramp.steps = 1;
      c.ramp.stepTime = 0.0;
      c.ramp.reverse = false;
      c.ramp.altShape = false;
      c.ramp.falloffMode = 0;
    }

    // Panic run trip
    // c.panicTripEnabled = menu.panicTripEnabled;
    // c.panicTripChance = ClampF(Cast<Float>(menu.panicTripChance) * 0.01, 0.0, 1.0);

    // Tumble toggles
    c.tumbleEnabled = menu.tumbleEnabled;
    c.directionalTumbleEnabled = menu.directionalTumbleEnabled;

    // Tumble advanced overrides
    c.overrideTumbleStairs = menu.overrideTumbleStairs;
    c.overrideTumbleDirectional = menu.overrideTumbleDirectional;

    c.tumbleStairs_delay = 0.080000;
    c.tumbleStairs_down = 19.000000;
    c.tumbleStairs_fwd = 9.250000;
    c.tumbleStairs_side = 2.800000;

    c.tumbleStairs_downDelay = 0.000000;
    c.tumbleStairs_fwdDelay = 0.040000;
    c.tumbleStairs_sideDelay = 0.000000;

    c.tumbleStairs_radius = 1.350000;

    c.tumbleStairs_yawDeg = 0.000000;
    c.tumbleStairs_pitchDeg = 0.000000;
    c.tumbleStairs_rollDeg = 0.000000;

    c.tumbleDir_down = -1.10;
    c.tumbleDir_fwd = 0.55;
    c.tumbleDir_side = 0.45;
    c.tumbleDir_downDelay = 0.00;
    c.tumbleDir_fwdDelay = 0.02;
    c.tumbleDir_sideDelay = 0.04;
    c.tumbleDir_radius = 1.35;

    // PopFix defaults
    c.killBikeDeathAnim = true;
    c.killVehicleDeathAnim = true;
    c.mitigateWorkspotExitPop = false;
    c.mitigateStaggerPop = false;

    c.ws_ragdollBurstTime = 0.08;   // chairs / seats
    c.veh_ragdollBurstTime = 0.12;  // cars
    c.stagger_ragdollBurstTime = 0.06;

    c.popFixEnabled = false;
    c.popFix_useGate = false;

    c.popFix_overrideWorkspot = false;
    c.popFix_overrideVehicle = false;
    c.popFix_overrideStagger = false;

    c.popFix_staggerSnap = false;
    c.popFix_workspotPreemptExit = false;

    // Only meaningful when vehicle latch reason is active
    c.popFix_vehicleKillExitAnim = true;
    c.popFix_bikeKillExitAnim = false;

    c.popFix_latchWorkspot = 0.00;
    c.popFix_latchVehicle = 1.60;
    c.popFix_latchStagger = 1.80;

    c.popFix_wsPreemptDelay = 0.00;

    c.popFix_pulse0 = 0.005;
    c.popFix_pulse1 = 0.015;
    c.popFix_pulse2 = 0.05;
    c.popFix_pulse3 = 0.14;

    c.popFixEnabled = GetBool("popFixEnabled", c.popFixEnabled);
    c.popFix_useGate = GetBool("popFix_useGate", c.popFix_useGate);

    c.popFix_overrideWorkspot = GetBool("popFix_overrideWorkspot", c.popFix_overrideWorkspot);
    c.popFix_overrideVehicle = GetBool("popFix_overrideVehicle", c.popFix_overrideVehicle);
    c.popFix_overrideStagger = GetBool("popFix_overrideStagger", c.popFix_overrideStagger);

    c.popFix_staggerSnap = GetBool("popFix_staggerSnap", c.popFix_staggerSnap);
    c.popFix_workspotPreemptExit = GetBool("popFix_workspotPreemptExit", c.popFix_workspotPreemptExit);

    c.popFix_vehicleKillExitAnim = GetBool("popFix_vehicleKillExitAnim", c.popFix_vehicleKillExitAnim);
    c.popFix_bikeKillExitAnim = GetBool("popFix_bikeKillExitAnim", c.popFix_bikeKillExitAnim);

    c.popFix_latchWorkspot = GetFloat("popFix_latchWorkspot", c.popFix_latchWorkspot);
    c.popFix_latchVehicle = GetFloat("popFix_latchVehicle", c.popFix_latchVehicle);
    c.popFix_latchStagger = GetFloat("popFix_latchStagger", c.popFix_latchStagger);

    c.popFix_wsPreemptDelay = GetFloat("popFix_wsPreemptDelay", c.popFix_wsPreemptDelay);

    c.popFix_pulse0 = GetFloat("popFix_pulse0", c.popFix_pulse0);
    c.popFix_pulse1 = GetFloat("popFix_pulse1", c.popFix_pulse1);
    c.popFix_pulse2 = GetFloat("popFix_pulse2", c.popFix_pulse2);
    c.popFix_pulse3 = GetFloat("popFix_pulse3", c.popFix_pulse3);

    if IsDefined(menu) && menu.overridePopFix {
      // Master enable
      c.popFixEnabled = menu.popFix_enable;

      // Feature toggles
      c.popFix_vehicleKillExitAnim = menu.popFix_killVehicleExitAnim;
      c.popFix_bikeKillExitAnim = menu.popFix_killBikeDeathAnim;
      c.popFix_staggerSnap = menu.popFix_fixStaggerSnap;
      c.popFix_workspotPreemptExit = menu.popFix_tryWorkspotExitMitigation;

      // Legacy mirrors
      c.killBikeDeathAnim = menu.popFix_killBikeDeathAnim;
      c.killVehicleDeathAnim = menu.popFix_killVehicleExitAnim;
      c.mitigateWorkspotExitPop = menu.popFix_tryWorkspotExitMitigation;
      c.mitigateStaggerPop = menu.popFix_fixStaggerSnap;

      // Timings / latch windows
      c.popFix_latchWorkspot = MaxF(0.0, menu.popFix_latchWorkspot);
      c.popFix_latchVehicle = MaxF(0.0, menu.popFix_latchVehicle);
      c.popFix_latchStagger = MaxF(0.0, menu.popFix_latchStagger);
      c.popFix_wsPreemptDelay = MaxF(0.0, menu.popFix_wsPreemptDelay);

      // Wake nudges
      c.popFix_pulse0 = MaxF(0.0, menu.popFix_pulse0);
      c.popFix_pulse1 = MaxF(0.0, menu.popFix_pulse1);
      c.popFix_pulse2 = MaxF(0.0, menu.popFix_pulse2);
      c.popFix_pulse3 = MaxF(0.0, menu.popFix_pulse3);

      // Ensure pulses are non-decreasing
      if c.popFix_pulse1 < c.popFix_pulse0 {
        c.popFix_pulse1 = c.popFix_pulse0;
      }
      if c.popFix_pulse2 < c.popFix_pulse1 {
        c.popFix_pulse2 = c.popFix_pulse1;
      }
      if c.popFix_pulse3 < c.popFix_pulse2 {
        c.popFix_pulse3 = c.popFix_pulse2;
      }
    }

    if c.overrideTumbleStairs {
      c.tumbleStairs_delay = menu.tumbleStairs_delay;
      c.tumbleStairs_down = 0.0 - AbsF(menu.tumbleStairs_down);
      c.tumbleStairs_fwd = menu.tumbleStairs_fwd;
      c.tumbleStairs_side = menu.tumbleStairs_side;
      c.tumbleStairs_downDelay = menu.tumbleStairs_downDelay;
      c.tumbleStairs_fwdDelay = menu.tumbleStairs_fwdDelay;
      c.tumbleStairs_sideDelay = menu.tumbleStairs_sideDelay;
      c.tumbleStairs_radius = menu.tumbleStairs_radius;
      // c.tumbleStairs_yawDeg = menu.tumbleStairs_yawDeg;
      // c.tumbleStairs_pitchDeg = menu.tumbleStairs_pitchDeg;
      // c.tumbleStairs_rollDeg = menu.tumbleStairs_rollDeg;
    }

    if c.overrideTumbleDirectional {
      c.tumbleDir_down = 0.0 - AbsF(menu.tumbleDir_down);
      c.tumbleDir_fwd = menu.tumbleDir_fwd;
      c.tumbleDir_side = menu.tumbleDir_side;
      c.tumbleDir_downDelay = menu.tumbleDir_downDelay;
      c.tumbleDir_fwdDelay = menu.tumbleDir_fwdDelay;
      c.tumbleDir_sideDelay = menu.tumbleDir_sideDelay;
      c.tumbleDir_radius = menu.tumbleDir_radius;
    }

    // Derived tumble scheduler
    c.tumbleStairs_startBase = 0.0;
    c.tumbleStairs_startScale = 1.0;
    c.tumbleStairs_startCap = 2.0;
    c.tumbleStairs_startDelay = c.tumbleStairs_delay;
    c.tumbleStairs_stepDelay = c.tumbleStairs_fwdDelay;
    c.tumbleStairs_steps = 6;

    c.tumbleDir_startBase = 0.0;
    c.tumbleDir_startScale = 1.0;
    c.tumbleDir_startCap = 2.0;
    c.tumbleDir_startDelay = c.tumbleDir_downDelay;
    c.tumbleDir_stepDelay = c.tumbleDir_fwdDelay;
    c.tumbleDir_steps = 6;


    // Menu-driven tumble loop controls. These fields already exist in RFCConfig;
    // The direct settings data supplies the visible sliders and this bridge wires them into runtime.
    if c.overrideTumbleStairs {
      c.tumbleStairs_steps = RFC_ClampI(menu.tumbleStairs_steps, 1, 100);
      c.tumbleStairs_stepDelay = RFC_ClampF(menu.tumbleStairs_stepDelay, 0.0, 30.0);
    }

    if c.overrideTumbleDirectional {
      c.tumbleDir_steps = RFC_ClampI(menu.tumbleDir_steps, 1, 100);
      c.tumbleDir_stepDelay = RFC_ClampF(menu.tumbleDir_stepDelay, 0.0, 30.0);
    }

    // Kill-impulses toggles
    c.killImpulsesEverywhere = menu.killImpulsesEverywhere;
    c.killImpulsesVehiclesOnly = menu.killImpulsesVehiclesOnly;

    // Settle
    c.settleEnabled = menu.settleEnabled;
    c.settleRadius = menu.settleRadius;
    c.settleStrength = menu.settleStrength;
    c.settleDown = menu.settleDown;
    c.settleDelay = menu.settleDelay;
    c.settleFwd = menu.settleFwd;


    c.bulletJoltsEnabled = true;
    c.bulletJoltStrengthScale = 1.0;
    c.bulletJoltRadiusScale = 1.0;
    c.bulletJoltDelayScale = 1.0;
    c.bulletJoltWaitForGround = false;
    c.bulletJoltGroundWaitMax = 3.0;
    c.bulletJoltAllowAirborne = false;

    // Grenade defaults
    c.grenadeKickRadius = 1.2;
    c.grenadeKickX = 2.0;
    c.grenadeKickY = 2.0;
    c.grenadeKickZ = 2.2;
    c.grenadeKickCallDelay = 0.0;

    c.grenadeEnabled = false;

    // Twitch defaults
    c.twitchEnabled = false;
    c.twitchChance = 0.4;
    c.twitchStrengthMin = 0.8;
    c.twitchStrengthMax = 1.2;
    c.twitchDelayStart = 3.2;
    c.twitchDelayStepMin = 0.25;
    c.twitchDelayStepMax = 0.55;
    c.twitchDuration = 20.5;
    c.twitchForce = 200.0;

    // Arcade bullet defaults
    c.arcadeBulletsEnabled = false;
    c.arcadeBulletStrength = 8.0;
    c.arcadeBulletUp = 2.5;
    c.arcadeBulletDown = 0.0;
    c.arcadeBulletRadius = 0.25;
    c.arcadeApplicationPointOffset = 0.0;
    c.arcadeMeleeEnabled = false;
    c.arcadeMeleeStrength = 8.0;
    c.arcadeMeleeUp = 1.0;
    c.arcadeMeleeDown = 0.0;
    c.arcadeMeleeRadius = 0.60;

    c.arcadeOnHitEnabled = true;
    c.arcadeOnDeathEnabled = true;

    c.arcadeAllowBlunt = true;
    c.arcadeAllowBlade = true;
    c.arcadeAllowShotgun = true;
    c.arcadeAllowSniper = true;
    c.arcadeAllowHandgun = true;
    c.arcadeAllowMagnum = true;
    c.arcadeAllowSMG = true;
    c.arcadeAllowAR = true;
    c.arcadeAllowLMG = true;

    if IsDefined(menu) {
      c.arcadeBulletsEnabled = menu.arcadeBulletsEnabled;
      c.arcadeBulletStrength = menu.arcadeBulletStrength;
      c.arcadeBulletUp = menu.arcadeBulletUp;
      c.arcadeBulletDown = menu.arcadeBulletDown;
      c.arcadeBulletRadius = menu.arcadeBulletRadius;
      c.arcadeApplicationPointOffset = menu.arcadeApplicationPointOffset;
      c.arcadeMeleeEnabled = menu.arcadeMeleeEnabled;
      c.arcadeMeleeStrength = menu.arcadeMeleeStrength;
      c.arcadeMeleeUp = menu.arcadeMeleeUp;
      c.arcadeMeleeDown = menu.arcadeMeleeDown;
      c.arcadeMeleeRadius = menu.arcadeMeleeRadius;
      c.arcadeAllowBlunt = menu.arcadeAllowBlunt;
      c.arcadeAllowBlade = menu.arcadeAllowBlade;
      c.arcadeAllowShotgun = menu.arcadeAllowShotgun;
      c.arcadeAllowSniper = menu.arcadeAllowSniper;
      c.arcadeAllowHandgun = menu.arcadeAllowHandgun;
      c.arcadeAllowMagnum = menu.arcadeAllowMagnum;
      c.arcadeAllowSMG = menu.arcadeAllowSMG;
      c.arcadeAllowAR = menu.arcadeAllowAR;
      c.arcadeAllowLMG = menu.arcadeAllowLMG;
      c.arcadeOnHitEnabled = menu.arcadeOnHitEnabled;
      c.arcadeOnDeathEnabled = menu.arcadeOnDeathEnabled;
      c.arcadeUseWeaponAllowList = menu.weaponchoice;
      c.arcadeBulletCooldown = menu.arcadeBulletCooldown;
      c.arcadeImpulseDelay = menu.arcadeImpulseDelay;
      c.arcadeIncapRagdollEnabled = menu.arcadeIncapRagdollEnabled;
      c.arcadeIncapRagdollDelay = RFC_ClampF(menu.arcadeIncapRagdollDelay, 0.0, 2.0);
      c.hitReactionsDisabled = menu.hitReactionsDisabled;
      c.hitReactionCutoffEnabled = menu.hitReactionCutoffEnabled;
      c.hitReactionCutoffDelay = RFC_ClampF(menu.hitReactionCutoffDelay, 0.0, 2.0);
      c.injuryShockEnabled = menu.injuryShockEnabled;
      c.injuryShockAllowBosses = menu.injuryShockAllowBosses;
      c.injuryShockAllowSubBosses = menu.injuryShockAllowSubBosses;
      c.injuryShockAllowNPCSources = menu.injuryShockAllowNPCSources;
      c.injuryShockChance = RFC_ClampF(menu.injuryShockChancePct * 0.01, 0.0, 1.0);
      c.injuryShockDelay = RFC_ClampF(menu.injuryShockDelay, 0.0, 50.0);
      c.injuryShockRandomDelay = RFC_ClampF(menu.injuryShockRandomDelay, 0.0, 50.0);
      c.injuryShockGetUpDelay = RFC_ClampF(menu.injuryShockGetUpDelay, 0.0, 50.0);
      c.injuryShockGetUpRandomDelay = RFC_ClampF(menu.injuryShockGetUpRandomDelay, 0.0, 50.0);
      c.injuryShockLimbsOnly = menu.injuryShockLimbsOnly;
      c.arcadeCowScale = menu.arcadeCowScale;
      c.arcadeMulHandgun = menu.arcadeMulHandgun;
      c.arcadeMulMagnum = menu.arcadeMulMagnum;
      c.arcadeMulShotgun = menu.arcadeMulShotgun;
      c.arcadeMulSniper = menu.arcadeMulSniper;
      c.arcadeMulSMG = menu.arcadeMulSMG;
      c.arcadeMulAR = menu.arcadeMulAR;
      c.arcadeMulLMG = menu.arcadeMulLMG;
      c.arcadeMulBlunt = menu.arcadeMulBlunt;
      c.arcadeMulBlade = menu.arcadeMulBlade;
    }

// STAND — VERY HARD, ALL AT ONCE
c.standEnabled = true;

c.st_forward = 0.600000;
c.st_forwardRadius = 0.700000;
c.st_headRadius = 0.700000;
c.st_chestRadius = 0.700000;
c.st_pelvisRadius = 0.700000;
c.st_kneeRadius = 0.700000;

c.st_downHead = -0.090000;
c.st_downChest = -3.330000;
c.st_downPelvis = -0.020000;
c.st_kneeDown = 0.000000;

c.st_vSlamZ = -0.110000;

// unified timing
c.st_d_knee = 0.996000;
c.st_d_headSlam = 0.952000;
c.st_d_chestFall = 0.020000;
c.st_d_pelvisFall = 0.025000;
c.st_d_headBias = 2.000000;
c.st_d_vSlam = 0.680000;

c.st_d_headSnap = 0.447000;
c.st_forwardDelay = 0.137000;

c.st_antiTuckDelay = 0.000000;
c.st_antiTuckZ = 0.000000;
c.st_antiTuckRadius = 0.000000;

c.st_anchorOffset = 0.020000;
c.st_anchorFwd = 0.000000;
c.st_anchorDown = 0.000000;
c.st_anchorRadius = 0.000000;

c.runEnabled = true;

c.run_forward = 0.000000;
c.run_forwardMin = 0.000000;
c.run_forwardRadius = 0.700000;
c.run_headRadius = 1.700000;
c.run_chestRadius = 0.700000;
c.run_pelvisRadius = 0.700000;
c.run_kneeRadius = 0.550000;
c.run_vSlamRadius = 0.980000;
c.run_forwardDelay = 0.983000;

c.run_downHead = 0.000000;
c.run_downHeadMin = 0.000000;
c.run_downChest = -3.490000;
c.run_downPelvis = 0.000000;
c.run_kneeDown = 0.000000;

c.run_vSlamZ = -0.140000;

// timing
c.run_d_headBias = 0.000000;
c.run_d_knee = 0.179000;
c.run_d_headSlam = 0.568000;
c.run_d_chestFall = 0.070000;
c.run_d_pelvisFall = 0.040000;
c.run_d_vSlam = 0.232000;

// anchor
c.run_anchorOffset = 0.000000;
c.run_anchorFwd = -0.010000;
c.run_anchorDown = -0.910000;
c.run_anchorRadius = 5.000000;

c.wsStandEnabled = true;

c.wsStand.headFwd = 0.030000;
c.wsStand.headDown = -0.060000;
c.wsStand.headDelay = 0.000000;
c.wsStand.headRadius = 1.800000;

c.wsStand.chestFwd = 2.120000;
c.wsStand.chestDown = 0.000000;
c.wsStand.chestDelay = 0.764000;
c.wsStand.chestRadius = 0.800000;

c.wsStand.pelvisFwd = 0.420000;
c.wsStand.pelvisDown = 0.000000;
c.wsStand.pelvisDelay = 0.100000;
c.wsStand.pelvisRadius = 0.600000;

c.wsStand.kneeDown = 0.000000;
c.wsStand.kneeDelay = 0.120000;
c.wsStand.kneeRadius = 0.450000;

c.wsStand.body_vSlamZ = 0.000000;
c.wsStand.body_vSlamDelay = 0.180000;
c.wsStand.body_vSlamRadius = 0.980000;

// COWER — HARD DROP, ALL AT ONCE
c.cow.headDown = -2.60;
c.cow.headRadius = 1.00;
c.cow.headDelay = 0.05;

c.cow.chestDown = -2.30;
c.cow.chestRadius = 0.95;
c.cow.chestDelay = 0.05;

c.cow.pelvisDown = -2.20;
c.cow.pelvisRadius = 0.85;
c.cow.pelvisDelay = 0.05;

c.cow.kneeDown = -1.60;
c.cow.kneeRadius = 0.65;
c.cow.kneeDelay = 0.05;

c.cow.antiTuckZ = 0.55;
c.cow.antiTuckRadius = 0.65;
c.cow.antiTuckDelay = 0.08;

if c.vanillaMode {
  c.killMotorcycleDeathAnim = false;
  c.standEnabled = false;
  c.overrideStand = false;
  c.runEnabled = false;
  c.overrideRun = false;
  c.cowerEnabled = false;
  c.overrideCower = false;
  c.stairsEnabled = false;
  c.overrideStairs = false;
  c.wsStandEnabled = false;
  c.overrideWsStand = false;

  c.settleEnabled = false;
  c.overrideSettle = false;
  c.grenadeEnabled = false;
  c.overrideGrenade = false;
  c.overrideBulletImpulse = false;
  c.twitchEnabled = false;
  c.overrideTwitch = false;
  c.walkEnabled = false;
  c.overrideWalk = false;

  c.tumbleEnabled = false;
  c.directionalTumbleEnabled = false;

  c.killImpulsesVehiclesOnly = true;
  c.killImpulsesEverywhere = false;
  // c.panicTripEnabled = false; // c.overridePanicTrip = false;

  c.vehicleOccupantShieldEnabled = true;
  c.vehicleMountedHitImmunity = false;
  c.vehicleOccupantShieldTime = 0.65;
  c.vehicleExitShieldEnabled = true;
  c.vehicleExitShieldTime = 0.85;

  c.popFixEnabled = false;
  c.popFix_useGate = false;

  c.popFix_overrideWorkspot = false;
  c.popFix_overrideVehicle = false;
  c.popFix_overrideStagger = false;

  c.popFix_staggerSnap = false;
  c.popFix_workspotPreemptExit = false;

  c.popFix_vehicleKillExitAnim = false;
  c.popFix_bikeKillExitAnim = false;

  c.masterDeathChanceEnabled = false;
  c.stealthRagdollsEnabled = false;
  c.vanillaImpulsesEnabled = false;
  c.explPlayerOnly = true;
  c.grenadeKickRadius = 0.0;
  c.grenadeKickX = 0.0;
  c.grenadeKickY = 0.0;
  c.grenadeKickZ = 0.0;
  c.tumbleStairs_steps = 1;
  c.tumbleDir_steps = 1;
  c.tumbleStairs_stepDelay = 0.0;
  c.tumbleDir_stepDelay = 0.0;

  // Continue. Final Vanilla master bypass below must run after all mode assignments.
}

// GROUP ENABLES
c.standEnabled = menu.standEnabled;
c.runEnabled = menu.runEnabled;
c.cowerEnabled = menu.cowerEnabled;
c.stairsEnabled = menu.stairsEnabled;
c.wsStandEnabled = menu.wsStandEnabled;
c.settleEnabled = menu.settleEnabled;
c.twitchEnabled = menu.twitchEnabled;
c.walkEnabled = false;
    c.randomImpulsesEnabled = menu.randomImpulsesEnabled;
    c.randomImpulseChancePct = RFC_ClampF(menu.randomImpulseChancePct, 0.0, 100.0);
    c.randomDisableGroupsEnabled = menu.randomDisableGroupsEnabled;
    c.randomDisableChancePct = RFC_ClampF(menu.randomDisableChancePct, 0.0, 100.0);
    c.randomMaxDisabledGroups = RFC_ClampI(menu.randomMaxDisabledGroups, 1, 3);
    c.randomPoolHead = menu.randomPoolHead;
    c.randomCanDisableHead = menu.randomCanDisableHead;
    c.randomPoolBody = menu.randomPoolBody;
    c.randomCanDisableBody = menu.randomCanDisableBody;
    c.randomPoolShoulderWaist = menu.randomPoolShoulderWaist;
    c.randomCanDisableShoulderWaist = menu.randomCanDisableShoulderWaist;
    c.randomPoolSituational = menu.randomPoolSituational;
    c.randomCanDisableSituational = menu.randomCanDisableSituational;
// c.panicTripEnabled = menu.panicTripEnabled;

c.grenadeEnabled = menu.grenadeEnabled;

// VANILLA IMPULSE KILL SWITCHES (menu-driven)
c.killImpulsesVehiclesOnly = menu.killImpulsesVehiclesOnly;
c.killImpulsesEverywhere = menu.killImpulsesEverywhere;

c.arcadeBulletsEnabled = menu.arcadeBulletsEnabled;
c.arcadeBulletStrength = menu.arcadeBulletStrength;
c.arcadeBulletUp = menu.arcadeBulletUp;

// Arcade bullets
c.arcadeBulletsEnabled = menu.arcadeBulletsEnabled;
c.arcadeBulletStrength = menu.arcadeBulletStrength;
c.arcadeBulletUp = menu.arcadeBulletUp;
c.arcadeBulletDown = menu.arcadeBulletDown;
c.arcadeBulletRadius = menu.arcadeBulletRadius;
c.arcadeApplicationPointOffset = menu.arcadeApplicationPointOffset;
c.arcadeMeleeEnabled = menu.arcadeMeleeEnabled;
c.arcadeMeleeStrength = menu.arcadeMeleeStrength;
c.arcadeMeleeUp = menu.arcadeMeleeUp;
c.arcadeMeleeDown = menu.arcadeMeleeDown;
c.arcadeMeleeRadius = menu.arcadeMeleeRadius;

// Arcade weapon groups
c.arcadeAllowHandgun = menu.arcadeAllowHandgun;
c.arcadeAllowMagnum = menu.arcadeAllowMagnum;
c.arcadeAllowShotgun = menu.arcadeAllowShotgun;
c.arcadeAllowSniper = menu.arcadeAllowSniper;
c.arcadeAllowSMG = menu.arcadeAllowSMG;
c.arcadeAllowAR = menu.arcadeAllowAR;
c.arcadeAllowLMG = menu.arcadeAllowLMG;
c.arcadeAllowBlunt = menu.arcadeAllowBlunt;
c.arcadeAllowBlade = menu.arcadeAllowBlade;

// Arcade behavior tuning
// Base/global values are copied before named mode branches.
// If a named mode sets the same value later, the mode value wins.
c.arcadeBulletCooldown = menu.arcadeBulletCooldown;
c.arcadeImpulseDelay = menu.arcadeImpulseDelay;
c.arcadeIncapRagdollEnabled = menu.arcadeIncapRagdollEnabled;
c.arcadeIncapRagdollDelay = RFC_ClampF(menu.arcadeIncapRagdollDelay, 0.0, 2.0);
c.hitReactionsDisabled = menu.hitReactionsDisabled;
c.hitReactionCutoffEnabled = menu.hitReactionCutoffEnabled;
c.hitReactionCutoffDelay = RFC_ClampF(menu.hitReactionCutoffDelay, 0.0, 2.0);
c.injuryShockEnabled = menu.injuryShockEnabled;
c.injuryShockAllowBosses = menu.injuryShockAllowBosses;
c.injuryShockAllowSubBosses = menu.injuryShockAllowSubBosses;
c.injuryShockAllowNPCSources = menu.injuryShockAllowNPCSources;
c.injuryShockChance = RFC_ClampF(menu.injuryShockChancePct * 0.01, 0.0, 1.0);
c.injuryShockDelay = RFC_ClampF(menu.injuryShockDelay, 0.0, 50.0);
c.injuryShockRandomDelay = RFC_ClampF(menu.injuryShockRandomDelay, 0.0, 50.0);
c.injuryShockGetUpDelay = RFC_ClampF(menu.injuryShockGetUpDelay, 0.0, 50.0);
c.injuryShockGetUpRandomDelay = RFC_ClampF(menu.injuryShockGetUpRandomDelay, 0.0, 50.0);
c.injuryShockLimbsOnly = menu.injuryShockLimbsOnly;
c.arcadeCowScale = menu.arcadeCowScale;

// Safety clamp – don’t let sliders go insane
if c.arcadeBulletStrength < 0.0 {
  c.arcadeBulletStrength = 0.0;
}
if c.arcadeBulletStrength > 80.0 {
  c.arcadeBulletStrength = 80.0;
}

c.arcadeBulletUp = RFC_ClampF(c.arcadeBulletUp, 0.0, 20.0);
c.arcadeBulletDown = RFC_ClampF(c.arcadeBulletDown, 0.0, 20.0);
c.arcadeApplicationPointOffset = RFC_ClampF(c.arcadeApplicationPointOffset, 0.0, 1.0);
c.arcadeMeleeStrength = RFC_ClampF(c.arcadeMeleeStrength, 0.0, 80.0);
c.arcadeMeleeUp = RFC_ClampF(c.arcadeMeleeUp, 0.0, 20.0);
c.arcadeMeleeDown = RFC_ClampF(c.arcadeMeleeDown, 0.0, 20.0);
c.arcadeMeleeRadius = RFC_ClampF(c.arcadeMeleeRadius, 0.05, 5.0);

c.vanillaImpulsesEnabled = menu.vanillaImpulsesEnabled;

c.vanillaAllowHandgun = menu.vanillaAllowHandgun;
c.vanillaAllowMagnum = menu.vanillaAllowMagnum;
c.vanillaAllowShotgun = menu.vanillaAllowShotgun;
c.vanillaAllowSniper = menu.vanillaAllowSniper;
c.vanillaAllowSMG = menu.vanillaAllowSMG;
c.vanillaAllowAR = menu.vanillaAllowAR;
c.vanillaAllowLMG = menu.vanillaAllowLMG;
c.vanillaAllowBlunt = menu.vanillaAllowBlunt;
c.vanillaAllowBlade = menu.vanillaAllowBlade;

// NEW: group enables for tumble helpers
c.tumbleEnabled = menu.tumbleEnabled;
c.directionalTumbleEnabled = menu.directionalTumbleEnabled;

// OVERRIDES
c.overrideStand = menu.st_overrideGlobalHead || menu.st_overrideGlobalForward || menu.st_overrideGlobalChest || menu.st_overrideGlobalPelvis || menu.st_overrideGlobalKnees;
c.overrideRun = menu.run_overrideGlobalHead || menu.run_overrideGlobalForward || menu.run_overrideGlobalChest || menu.run_overrideGlobalPelvis || menu.run_overrideGlobalKnees;
c.overrideCower = menu.cow_overrideGlobalHead || menu.cow_overrideGlobalChest || menu.cow_overrideGlobalPelvis || menu.cow_overrideGlobalKnees;
c.overrideStairs = menu.stair_overrideGlobalHead || menu.stair_overrideGlobalForward || menu.stair_overrideGlobalChest || menu.stair_overrideGlobalPelvis || menu.stair_overrideGlobalKnees;
c.overrideWsStand = menu.wsStand_overrideGlobalForward || menu.wsStand_overrideGlobalChest || menu.wsStand_overrideGlobalPelvis || menu.wsStand_overrideGlobalKnees;
c.overrideBulletImpulse = menu.overrideBulletImpulse;
c.overrideSettle = menu.overrideSettle;
c.overrideTwitch = menu.overrideTwitch;
c.overrideGrenade = menu.overrideGrenade;

// c.overridePanicTrip = menu.overridePanicTrip;
c.overrideWalk = false;

c.st_overrideGlobalHead = menu.st_overrideGlobalHead;
c.st_overrideGlobalForward = menu.st_overrideGlobalForward;
c.st_overrideGlobalChest = menu.st_overrideGlobalChest;
c.st_overrideGlobalPelvis = menu.st_overrideGlobalPelvis;
c.st_overrideGlobalKnees = menu.st_overrideGlobalKnees;


c.run_overrideGlobalHead = menu.run_overrideGlobalHead;
c.run_overrideGlobalForward = menu.run_overrideGlobalForward;
c.run_overrideGlobalChest = menu.run_overrideGlobalChest;
c.run_overrideGlobalPelvis = menu.run_overrideGlobalPelvis;
c.run_overrideGlobalKnees = menu.run_overrideGlobalKnees;


c.cow_overrideGlobalHead = menu.cow_overrideGlobalHead;
c.cow_overrideGlobalForward = menu.cow_overrideGlobalForward;
c.cow_overrideGlobalChest = menu.cow_overrideGlobalChest;
c.cow_overrideGlobalPelvis = menu.cow_overrideGlobalPelvis;
c.cow_overrideGlobalKnees = menu.cow_overrideGlobalKnees;


c.stair_overrideGlobalHead = menu.stair_overrideGlobalHead;
c.stair_overrideGlobalForward = menu.stair_overrideGlobalForward;
c.stair_overrideGlobalChest = menu.stair_overrideGlobalChest;
c.stair_overrideGlobalPelvis = menu.stair_overrideGlobalPelvis;
c.stair_overrideGlobalKnees = menu.stair_overrideGlobalKnees;


c.wsStand_overrideGlobalForward = menu.wsStand_overrideGlobalForward;
c.wsStand_overrideGlobalChest = menu.wsStand_overrideGlobalChest;
c.wsStand_overrideGlobalPelvis = menu.wsStand_overrideGlobalPelvis;
c.wsStand_overrideGlobalKnees = menu.wsStand_overrideGlobalKnees;


// Panic trip override
// if menu.overridePanicTrip {
//   c.panicTripEnabled = menu.panicTripEnabled;
//   c.panicTripChance = RFC_ClampF(Cast<Float>(menu.panicTripChance) * 0.01, 0.0, 1.0);
// }

// Explosions routing (MUST NOT depend on overrideGrenade)
c.showExplosionsAdvanced = menu.showExplosionsAdvanced;

c.explAffectGrenades = menu.explAffectGrenades;
c.explAffectWeapon = menu.explAffectWeapon;
c.explAffectBullet = menu.explAffectBullet;
c.explAffectVehicle = menu.explAffectVehicle;

c.explMulGrenades = MaxF(0.0, menu.explMulGrenades);
c.explMulWeapon = MaxF(0.0, menu.explMulWeapon);
c.explMulBullet = MaxF(0.0, menu.explMulBullet);
c.explMulVehicle = RFC_ClampF(menu.explMulVehicle, 0.0, 30.0);

// Overrides toggles
c.overrideGrenade = menu.overrideGrenade;

// Realism Custom exposes these explosion values directly, matching the
// named modes. The legacy override switch no longer blocks visible sliders.
c.grenadeKickRadius = menu.grenadeKickRadius;
c.grenadeKickX = menu.grenadeKickX;
c.grenadeKickY = menu.grenadeKickY;
c.grenadeKickZ = RFC_ClampF(menu.grenadeKickZ, 0.0, 100.0)
  - RFC_ClampF(menu.grenadeKickDown, 0.0, 100.0);
c.grenadeKickCallDelay = menu.grenadeKickCallDelay;

if !c.grenadeEnabled {
  c.grenadeKickRadius = 0.0;
}

// Twitch override
if menu.overrideTwitch {
  c.twitchEnabled = menu.twitchEnabled;
  c.twitchChance = menu.twitchChance;
  c.twitchDelayStart = menu.twitchDelayStart;
  c.twitchDuration = menu.twitchDuration;
  c.twitchForce = menu.twitchForce;
}

// Settle override
if menu.overrideSettle {
  c.settleEnabled = menu.settleEnabled;
  c.settleStrength = menu.settleStrength;
  c.settleDelay = menu.settleDelay;
  c.settleFwd = menu.settleFwd;
  c.settleDown = menu.settleDown;
  c.settleRadius = menu.settleRadius;
}


// Realism Custom uses its own live Bullet Jolt controls.
c.bulletJoltsEnabled = menu.realism_bulletJoltsEnabled;
c.bulletJoltStrengthScale = RFC_ClampF(menu.realism_bulletJoltStrengthScale, 0.0, 10.0);
c.bulletJoltRadiusScale = RFC_ClampF(menu.realism_bulletJoltRadiusScale, 0.1, 5.0);
c.bulletJoltDelayScale = RFC_ClampF(menu.realism_bulletJoltDelayScale, 0.0, 5.0);
c.bulletJoltWaitForGround = menu.realism_bulletJoltWaitForGround;
c.bulletJoltGroundWaitMax = RFC_ClampF(menu.realism_bulletJoltGroundWaitMax, 0.1, 5.0);
c.bulletJoltAllowAirborne = menu.realism_bulletJoltAllowAirborne;


// Situational sections are off unless their visible "Override Normal Settings"
// master is enabled. This prevents hidden legacy Enable values from creating a
// second master switch or applying Situational impulses without permission.
c.standEnabled = false;
c.runEnabled = false;
c.cowerEnabled = false;
c.stairsEnabled = false;
c.wsStandEnabled = false;

// STAND OVERRIDE  (10) Standing
if c.overrideStand {
  c.standEnabled = true;

  // global
  c.st_forward = menu.st_forward;
  c.st_forwardMin = menu.st_forwardMin;
  c.st_forwardRadius = menu.st_forwardRadius;
  c.st_headRadius = menu.st_headRadius;
  c.st_chestRadius = menu.st_chestRadius;
  c.st_pelvisRadius = menu.st_pelvisRadius;
  c.st_kneeRadius = menu.st_kneeRadius;
  c.st_forwardDelay = menu.st_forwardDelay;

  // head
  c.st_downHead = 0.0 - AbsF(menu.st_downHead);
  c.st_downHeadMin = 0.0 - AbsF(menu.st_downHeadMin);
  c.st_d_headBias = menu.st_d_headBias;
  c.st_d_headSlam = menu.st_d_headSlam;
  c.st_d_headSnap = menu.st_d_headSnap;

  // chest
  c.st_downChest = 0.0 - AbsF(menu.st_downChest);
  c.st_downChestMin = 0.0 - AbsF(menu.st_downChestMin);
  c.st_d_chestFall = menu.st_d_chestFall;

  // pelvis
  c.st_downPelvis = 0.0 - AbsF(menu.st_downPelvis);
  c.st_downPelvisMin = 0.0 - AbsF(menu.st_downPelvisMin);
  c.st_d_pelvisFall = menu.st_d_pelvisFall;

  // knees
  c.st_kneeDown = 0.0 - AbsF(menu.st_kneeDown);
  c.st_kneeDownMin = 0.0 - AbsF(menu.st_kneeDownMin);
  c.st_d_knee = menu.st_d_knee;

  // shins
  // c.st_shinDown = 0.0 - AbsF(menu.st_shinDown);
  // c.st_shinDelay1 = menu.st_shinDelay1;
  // c.st_shinDelay2 = menu.st_shinDelay2;
  // c.st_shinBack = 0.0 - AbsF(menu.st_shinBack);
  // c.st_shinRadius = menu.st_shinRadius;

  // feet
  // c.st_footDown = 0.0 - AbsF(menu.st_footDown);
  // c.st_footFwd = menu.st_footFwd;
  // c.st_footDelay = menu.st_footDelay;
  // c.st_footRadius = menu.st_footRadius;

  // vSlam
  c.st_vSlamZ = 0.0 - AbsF(menu.st_vSlamZ);
  c.st_d_vSlam = menu.st_d_vSlam;

  // anti-tuck
  c.st_antiTuckZ = 0.0 - AbsF(menu.st_antiTuckZ);
  c.st_antiTuckDelay = menu.st_antiTuckDelay;
  c.st_antiTuckRadius = menu.st_antiTuckRadius;

  // anchor
  c.st_anchorFwd = menu.st_anchorFwd;
  c.st_anchorDown = 0.0 - AbsF(menu.st_anchorDown);
  c.st_anchorOffset = 0.0 - AbsF(menu.st_anchorOffset);
  c.st_anchorRadius = menu.st_anchorRadius;
}

// RUN OVERRIDE  (11) Running/Walking
if c.overrideRun {
  c.runEnabled = true;

  // global
  c.run_forward = menu.run_forward;
  c.run_forwardMin = menu.run_forwardMin;
  c.run_forwardRadius = menu.run_forwardRadius;
  c.run_headRadius = menu.run_headRadius;
  c.run_chestRadius = menu.run_chestRadius;
  c.run_pelvisRadius = menu.run_pelvisRadius;
  c.run_kneeRadius = menu.run_kneeRadius;
  c.run_vSlamRadius = menu.run_vSlamRadius;
  c.run_forwardDelay = menu.run_forwardDelay;

  // head
  c.run_downHead = 0.0 - AbsF(menu.run_downHead);
  c.run_downHeadMin = 0.0 - AbsF(menu.run_downHeadMin);
  c.run_d_headBias = menu.run_d_headBias;
  c.run_d_headSlam = menu.run_d_headSlam;

  // chest
  c.run_downChest = 0.0 - AbsF(menu.run_downChest);
  c.run_downChestMin = 0.0 - AbsF(menu.run_downChestMin);
  c.run_d_chestFall = menu.run_d_chestFall;

  // pelvis
  c.run_downPelvis = 0.0 - AbsF(menu.run_downPelvis);
  c.run_downPelvisMin = 0.0 - AbsF(menu.run_downPelvisMin);
  c.run_d_pelvisFall = menu.run_d_pelvisFall;

  // knees
  c.run_kneeDown = 0.0 - AbsF(menu.run_kneeDown);
  c.run_kneeDownMin = 0.0 - AbsF(menu.run_kneeDownMin);
  c.run_d_knee = menu.run_d_knee;

  // vSlam
  c.run_vSlamZ = 0.0 - AbsF(menu.run_vSlamZ);
  c.run_d_vSlam = menu.run_d_vSlam;

  // shins
  // c.run_shinBack = 0.0 - AbsF(menu.run_shinBack);
  // c.run_shinDown = 0.0 - AbsF(menu.run_shinDown);
  // c.run_shinDelay1 = menu.run_shinDelay1;
  // c.run_shinDelay2 = menu.run_shinDelay2;
  // c.run_shinRadius = menu.run_shinRadius;

  // feet
  // c.run_footFwd = menu.run_footFwd;
  // c.run_footDown = 0.0 - AbsF(menu.run_footDown);
  // c.run_footDelay = menu.run_footDelay;
  // c.run_footRadius = menu.run_footRadius;

  // anchor
  c.run_anchorOffset = 0.0 - AbsF(menu.run_anchorOffset);
  c.run_anchorFwd = 0.0 - AbsF(menu.run_anchorFwd);
  c.run_anchorDown = 0.0 - AbsF(menu.run_anchorDown);
  c.run_anchorRadius = menu.run_anchorRadius;
}

// STAIRS OVERRIDE  (13) Stairs
if c.overrideStairs {
  c.stairsEnabled = true;

  // global / torso
  c.stair_forward = menu.stair_forward;
  c.stair_forwardMin = menu.stair_forwardMin;
  c.stair_forwardRadius = menu.stair_forwardRadius;
  c.stair_headRadius = menu.stair_headRadius;
  c.stair_chestRadius = menu.stair_chestRadius;
  c.stair_pelvisRadius = menu.stair_pelvisRadius;
  c.stair_headFwd = menu.stair_headFwd;
  c.stair_headFwdMin = menu.stair_headFwdMin;
  c.stair_downHead = 0.0 - AbsF(menu.stair_downHead);
  c.stair_downHeadMin = 0.0 - AbsF(menu.stair_downHeadMin);
  c.stair_chestFwd = menu.stair_chestFwd;
  c.stair_chestFwdMin = menu.stair_chestFwdMin;
  c.stair_downChest = 0.0 - AbsF(menu.stair_downChest);
  c.stair_downChestMin = 0.0 - AbsF(menu.stair_downChestMin);
  c.stair_downPelvis = 0.0 - AbsF(menu.stair_downPelvis);
  c.stair_downPelvisMin = 0.0 - AbsF(menu.stair_downPelvisMin);

  // vSlam
  c.stair_vSlamZ = 0.0 - AbsF(menu.stair_vSlamZ);
  c.stair_vSlamZMin = 0.0 - AbsF(menu.stair_vSlamZMin);

  // knees
  c.stair_kneeDown = 0.0 - AbsF(menu.stair_kneeDown);
  c.stair_kneeDownMin = 0.0 - AbsF(menu.stair_kneeDownMin);
  c.stair_kneeDelay = menu.stair_kneeDelay;
  c.stair_kneeRadius = menu.stair_kneeRadius;

  // brake
  c.stair_brakeFwd = menu.stair_brakeFwd;
  c.stair_brakeFwdMin = menu.stair_brakeFwdMin;
  c.stair_brakeDelay = menu.stair_brakeDelay;
  c.stair_brakeRadius = menu.stair_brakeRadius;

  // plank
  c.stair_plankEnabled = menu.stair_plankEnabled;
  c.stair_plankHeadDown = 0.0 - AbsF(menu.stair_plankDownHead);
  c.stair_plankHeadDownMin = 0.0 - AbsF(menu.stair_plankDownHeadMin);
  c.stair_plankChestDown = 0.0 - AbsF(menu.stair_plankDownChest);
  c.stair_plankChestDownMin = 0.0 - AbsF(menu.stair_plankDownChestMin);
  c.stair_plankPelvisDown = 0.0 - AbsF(menu.stair_plankDownPelvis);
  c.stair_plankPelvisDownMin = 0.0 - AbsF(menu.stair_plankDownPelvisMin);
  c.stair_plankFwd = menu.stair_plankFwd;
  c.stair_plankFwdMin = menu.stair_plankFwdMin;
  c.stair_plankDelay = menu.stair_plankDelay;
  c.stair_plankRadius = menu.stair_plankRadius;
  c.stair_plankBrakeFwd = menu.stair_plankBrakeFwd;
  c.stair_plankBrakeFwdMin = menu.stair_plankBrakeFwdMin;
  c.stair_plankBrakeDelay = menu.stair_plankBrakeDelay;
  c.stair_plankBrakeRadius = menu.stair_plankBrakeRadius;

  // run helpers
  c.stair_runUseKnees = menu.stair_runUseKnees;
  // c.stair_runFeetDown = 0.0 - AbsF(menu.stair_runFeetDown);
  // c.stair_runFeetDelay = menu.stair_runFeetDelay;
  // c.stair_runFeetRadius = menu.stair_runFeetRadius;
}

// COWER OVERRIDE  (12) Cower
if c.overrideCower {
  c.cowerEnabled = true;

  // head
  c.cow.headDown = 0.0 - AbsF(menu.cow_downHead);
  c.cow.headDownMin = 0.0 - AbsF(menu.cow_downHeadMin);
  c.cow.headDelay = menu.cow_headDelay;
  c.cow.headRadius = menu.cow_headRadius;

  // chest
  c.cow.chestDown = 0.0 - AbsF(menu.cow_downChest);
  c.cow.chestDownMin = 0.0 - AbsF(menu.cow_downChestMin);
  c.cow.chestDelay = menu.cow_chestDelay;
  c.cow.chestRadius = menu.cow_chestRadius;

  // pelvis
  c.cow.pelvisDown = 0.0 - AbsF(menu.cow_downPelvis);
  c.cow.pelvisDownMin = 0.0 - AbsF(menu.cow_downPelvisMin);
  c.cow.pelvisDelay = menu.cow_pelvisDelay;
  c.cow.pelvisRadius = menu.cow_pelvisRadius;

  // knees
  c.cow.kneeDown = 0.0 - AbsF(menu.cow_kneeDown);
  c.cow.kneeDownMin = 0.0 - AbsF(menu.cow_kneeDownMin);
  c.cow.kneeDelay = menu.cow_kneeDelay;
  c.cow.kneeRadius = menu.cow_kneeRadius;

  // shins
  // c.cow.shinDown = 0.0 - AbsF(menu.cow_shinDown);
  // c.cow.shinDelay = menu.cow_shinDelay;
  // c.cow.shinRadius = menu.cow_shinRadius;

  // settle
  // c.cow.settleDown = 0.0 - AbsF(menu.cow_settleDown);
  // c.cow.settleDelay = menu.cow_settleDelay;
  // c.cow.settleRadius = menu.cow_settleRadius;

  // anti-tuck
  c.cow.antiTuckZ = 0.0 - AbsF(menu.cow_antiTuckZ);
  c.cow.antiTuckZMin = 0.0 - AbsF(menu.cow_antiTuckZMin);
  c.cow.antiTuckDelay = menu.cow_antiTuckDelay;
  c.cow.antiTuckRadius = menu.cow_antiTuckRadius;
}

// Workspot Stand override 
if c.overrideWsStand {
  c.wsStandEnabled = true;
  c.wsStand.headFwd = menu.wsStand_headFwd;
  c.wsStand.headDown = 0.0 - AbsF(menu.wsStand_headDown);
  c.wsStand.headDelay = menu.wsStand_headDelay;
  c.wsStand.headRadius = menu.wsStand_headRadius;

  c.wsStand.chestFwd = menu.wsStand_chestFwd;
  c.wsStand.chestFwdMin = menu.wsStand_chestFwdMin;
  c.wsStand.chestDown = 0.0 - AbsF(menu.wsStand_chestDown);
  c.wsStand.chestDownMin = 0.0 - AbsF(menu.wsStand_chestDownMin);
  c.wsStand.chestDelay = menu.wsStand_chestDelay;
  c.wsStand.chestRadius = menu.wsStand_chestRadius;

  c.wsStand.pelvisFwd = menu.wsStand_pelvisFwd;
  c.wsStand.pelvisFwdMin = menu.wsStand_pelvisFwdMin;
  c.wsStand.pelvisDown = 0.0 - AbsF(menu.wsStand_pelvisDown);
  c.wsStand.pelvisDownMin = 0.0 - AbsF(menu.wsStand_pelvisDownMin);
  c.wsStand.pelvisDelay = menu.wsStand_pelvisDelay;
  c.wsStand.pelvisRadius = menu.wsStand_pelvisRadius;

  c.wsStand.kneeDown = 0.0 - AbsF(menu.wsStand_kneeDown);
  c.wsStand.kneeDownMin = 0.0 - AbsF(menu.wsStand_kneeDownMin);
  c.wsStand.kneeDelay = menu.wsStand_kneeDelay;
  c.wsStand.kneeRadius = menu.wsStand_kneeRadius;

  // c.wsStand.shinDown = 0.0 - AbsF(menu.wsStand_shinDown);
  // c.wsStand.shinDelay1 = menu.wsStand_shinDelay1;
  // c.wsStand.shinDelay2 = menu.wsStand_shinDelay2;
  // c.wsStand.shinRadius = menu.wsStand_shinRadius;

  // c.wsStand.footFwd = menu.wsStand_footFwd;
  // c.wsStand.footDown = 0.0 - AbsF(menu.wsStand_footDown);
  // c.wsStand.footDelay = menu.wsStand_footDelay;
  // c.wsStand.footRadius = menu.wsStand_footRadius;

  c.wsStand.body_vSlamZ = 0.0 - AbsF(menu.wsStand_body_vSlamZ);
  c.wsStand.body_vSlamDelay = menu.wsStand_body_vSlamDelay;
  c.wsStand.body_vSlamRadius = menu.wsStand_body_vSlamRadius;
}

if c.splatPresetMode == EnumInt(RFCSplatPresetMode.Realism) {
  // Realism Custom uses the exact same final-config assignment pattern as the
  // working named modes. Reapply the active Realism Custom object here so none
  // of the old base/override ordering can leave NPC or vehicle explosions on
  // stale defaults.
  c.grenadeEnabled = menu.grenadeEnabled;
  c.explPlayerOnly = menu.explPlayerOnly;
  c.explAffectGrenades = menu.explAffectGrenades;
  c.explAffectWeapon = menu.explAffectWeapon;
  c.explAffectBullet = menu.explAffectBullet;
  c.explAffectVehicle = menu.explAffectVehicle;
  c.grenadeKickRadius = RFC_ClampF(menu.grenadeKickRadius, 0.0, 100.0);
  c.grenadeKickX = RFC_ClampF(menu.grenadeKickX, -100.0, 100.0);
  c.grenadeKickY = RFC_ClampF(menu.grenadeKickY, -100.0, 100.0);
  c.grenadeKickZ = RFC_ClampF(menu.grenadeKickZ, 0.0, 100.0)
    - RFC_ClampF(menu.grenadeKickDown, 0.0, 100.0);
  c.grenadeKickCallDelay = RFC_ClampF(menu.grenadeKickCallDelay, 0.0, 10.0);
  c.explMulGrenades = RFC_ClampF(menu.explMulGrenades, 0.0, 10.0);
  c.explMulWeapon = RFC_ClampF(menu.explMulWeapon, 0.0, 10.0);
  c.explMulBullet = RFC_ClampF(menu.explMulBullet, 0.0, 10.0);
  c.explMulVehicle = RFC_ClampF(menu.explMulVehicle, 0.0, 30.0);

  c.vehicleImpulseEnabled = menu.vehicleImpulseEnabled;
  c.vehicleExplosionEnabled = menu.vehicleExplosionEnabled;
  c.vehicleExplosionStrength = RFC_ClampF(menu.vehicleExplosionStrength, 0.0, 16900.0);
  c.vehicleExplosionLift = RFC_ClampF(menu.vehicleExplosionLift, 0.0, 16900.0)
    - RFC_ClampF(menu.vehicleExplosionDown, 0.0, 16900.0);
  c.vehicleExplosionRadius = RFC_ClampF(menu.vehicleExplosionRadius, 0.05, 20.0);
  c.vehicleUseExplosionMultipliers = menu.vehicleUseExplosionMultipliers;

  if !c.grenadeEnabled {
    c.grenadeKickRadius = 0.0;
  }
} else if c.splatPresetMode == EnumInt(RFCSplatPresetMode.RealismPlus) {
  // Global and Animation Controls are shared across all non-Vanilla modes.
  // Their base values were loaded above and are intentionally not overridden
  // by this named mode.
  c.arcadeBulletsEnabled = menu.realismPlusMode_arcadeBulletsEnabled;
  c.arcadeUseWeaponAllowList = true;
  c.vehicleImpulseEnabled = menu.realismPlusMode_vehicleImpulseEnabled;
  c.vehicleBulletEnabled = menu.realismPlusMode_vehicleBulletEnabled;
  c.vehicleBulletStrength = RFC_ClampF(menu.realismPlusMode_vehicleBulletStrength, 0.0, 8000.0);
  c.vehicleBulletLift = RFC_ClampF(menu.realismPlusMode_vehicleBulletUp, 0.0, 8000.0)
    - RFC_ClampF(menu.realismPlusMode_vehicleBulletDown, 0.0, 8000.0);
  c.vehicleBulletRadius = RFC_ClampF(menu.realismPlusMode_vehicleBulletRadius, 0.05, 20.0);
  c.vehicleMulHandgun = RFC_ClampF(menu.realismPlusMode_vehicleMulHandgun, 0.0, 20.0);
  c.vehicleMulMagnum = RFC_ClampF(menu.realismPlusMode_vehicleMulMagnum, 0.0, 20.0);
  c.vehicleMulShotgun = RFC_ClampF(menu.realismPlusMode_vehicleMulShotgun, 0.0, 20.0);
  c.vehicleMulSniper = RFC_ClampF(menu.realismPlusMode_vehicleMulSniper, 0.0, 20.0);
  c.vehicleMulSMG = RFC_ClampF(menu.realismPlusMode_vehicleMulSMG, 0.0, 20.0);
  c.vehicleMulAR = RFC_ClampF(menu.realismPlusMode_vehicleMulAR, 0.0, 20.0);
  c.vehicleMulLMG = RFC_ClampF(menu.realismPlusMode_vehicleMulLMG, 0.0, 20.0);
  c.vehicleMulUnknownBullet = RFC_ClampF(menu.realismPlusMode_vehicleMulUnknownBullet, 0.0, 20.0);
  c.vehicleExplosionEnabled = menu.realismPlusMode_vehicleExplosionEnabled;
  c.vehicleExplosionStrength = RFC_ClampF(menu.realismPlusMode_vehicleExplosionStrength, 0.0, 16900.0);
  c.vehicleExplosionLift = RFC_ClampF(menu.realismPlusMode_vehicleExplosionLift, 0.0, 16900.0)
    - RFC_ClampF(menu.realismPlusMode_vehicleExplosionDown, 0.0, 16900.0);
  c.vehicleExplosionRadius = RFC_ClampF(menu.realismPlusMode_vehicleExplosionRadius, 0.05, 20.0);
  c.vehicleMeleeEnabled = menu.realismPlusMode_vehicleMeleeEnabled;
  c.vehicleMeleeStrength = RFC_ClampF(menu.realismPlusMode_vehicleMeleeStrength, 0.0, 8000.0);
  c.vehicleMeleeLift = RFC_ClampF(menu.realismPlusMode_vehicleMeleeUp, 0.0, 8000.0)
    - RFC_ClampF(menu.realismPlusMode_vehicleMeleeDown, 0.0, 8000.0);
  c.vehicleMeleeRadius = RFC_ClampF(menu.realismPlusMode_vehicleMeleeRadius, 0.05, 20.0);
  c.vehicleUseExplosionMultipliers = menu.vehicleUseExplosionMultipliers;
  c.vehicleUseArcadeWeaponFilters = false;
  c.vehicleUseArcadeWeaponMultipliers = false;
  c.vehicleAllowUnknownBullet = true;
  c.arcadePlayerOnly = menu.realismPlusMode_arcadePlayerOnly;
  c.arcadeIndependentSourceControls = false;
  c.arcadeAllowPlayerBullet = true;
  c.arcadeAllowNPCBullet = !c.arcadePlayerOnly;
  c.arcadeAllowPlayerMelee = true;
  c.arcadeAllowNPCMelee = !c.arcadePlayerOnly;
  c.arcadeOnHitEnabled = menu.realismPlusMode_arcadeOnHitEnabled;
  c.arcadeOnDeathEnabled = menu.realismPlusMode_arcadeOnDeathEnabled;
  c.arcadeBulletStrength = RFC_ClampF(menu.realismPlusMode_arcadeBulletStrength, 0.0, 80.0);
  c.arcadeBulletUp = RFC_ClampF(menu.realismPlusMode_arcadeBulletUp, 0.0, 20.0);
  c.arcadeBulletDown = RFC_ClampF(menu.realismPlusMode_arcadeBulletDown, 0.0, 20.0);
  c.arcadeBulletRadius = RFC_ClampF(menu.realismPlusMode_arcadeBulletRadius, 0.05, 5.0);
  c.arcadeApplicationPointOffset = RFC_ClampF(menu.realismPlusMode_arcadeApplicationPointOffset, 0.0, 1.0);
  c.arcadeMeleeEnabled = menu.realismPlusMode_arcadeMeleeEnabled;
  c.arcadeMeleeStrength = RFC_ClampF(menu.realismPlusMode_arcadeMeleeStrength, 0.0, 80.0);
  c.arcadeMeleeUp = RFC_ClampF(menu.realismPlusMode_arcadeMeleeUp, 0.0, 20.0);
  c.arcadeMeleeDown = RFC_ClampF(menu.realismPlusMode_arcadeMeleeDown, 0.0, 20.0);
  c.arcadeMeleeRadius = RFC_ClampF(menu.realismPlusMode_arcadeMeleeRadius, 0.05, 5.0);
  c.arcadeBulletCooldown = RFC_ClampF(menu.realismPlusMode_arcadeBulletCooldown, 0.0, 2.0);
  c.arcadeImpulseDelay = RFC_ClampF(menu.realismPlusMode_arcadeImpulseDelay, 0.0, 0.50);
  c.arcadeCowScale = RFC_ClampF(menu.realismPlusMode_arcadeCowScale, 0.0, 3.0);
  c.arcadeAllowHandgun = menu.realismPlusMode_arcadeAllowHandgun;
  c.arcadeAllowMagnum = menu.realismPlusMode_arcadeAllowMagnum;
  c.arcadeAllowShotgun = menu.realismPlusMode_arcadeAllowShotgun;
  c.arcadeAllowSniper = menu.realismPlusMode_arcadeAllowSniper;
  c.arcadeAllowSMG = menu.realismPlusMode_arcadeAllowSMG;
  c.arcadeAllowAR = menu.realismPlusMode_arcadeAllowAR;
  c.arcadeAllowLMG = menu.realismPlusMode_arcadeAllowLMG;
  c.arcadeAllowBlunt = menu.realismPlusMode_arcadeAllowBlunt;
  c.arcadeAllowBlade = menu.realismPlusMode_arcadeAllowBlade;
  c.arcadeMulHandgun = RFC_ClampF(menu.realismPlusMode_arcadeMulHandgun, 0.0, 5.0);
  c.arcadeMulMagnum = RFC_ClampF(menu.realismPlusMode_arcadeMulMagnum, 0.0, 5.0);
  c.arcadeMulShotgun = RFC_ClampF(menu.realismPlusMode_arcadeMulShotgun, 0.0, 5.0);
  c.arcadeMulSniper = RFC_ClampF(menu.realismPlusMode_arcadeMulSniper, 0.0, 5.0);
  c.arcadeMulSMG = RFC_ClampF(menu.realismPlusMode_arcadeMulSMG, 0.0, 5.0);
  c.arcadeMulAR = RFC_ClampF(menu.realismPlusMode_arcadeMulAR, 0.0, 5.0);
  c.arcadeMulLMG = RFC_ClampF(menu.realismPlusMode_arcadeMulLMG, 0.0, 5.0);
  c.arcadeMulBlunt = RFC_ClampF(menu.realismPlusMode_arcadeMulBlunt, 0.0, 5.0);
  c.arcadeMulBlade = RFC_ClampF(menu.realismPlusMode_arcadeMulBlade, 0.0, 5.0);

  c.vanillaImpulsesEnabled = menu.realismPlusMode_vanillaImpulsesEnabled;
  c.vanillaAllowHandgun = menu.realismPlusMode_vanillaAllowHandgun;
  c.vanillaAllowMagnum = menu.realismPlusMode_vanillaAllowMagnum;
  c.vanillaAllowShotgun = menu.realismPlusMode_vanillaAllowShotgun;
  c.vanillaAllowSniper = menu.realismPlusMode_vanillaAllowSniper;
  c.vanillaAllowSMG = menu.realismPlusMode_vanillaAllowSMG;
  c.vanillaAllowAR = menu.realismPlusMode_vanillaAllowAR;
  c.vanillaAllowLMG = menu.realismPlusMode_vanillaAllowLMG;
  c.vanillaAllowBlunt = menu.realismPlusMode_vanillaAllowBlunt;
  c.vanillaAllowBlade = menu.realismPlusMode_vanillaAllowBlade;

  c.grenadeEnabled = menu.realismPlusMode_grenadeEnabled;
  c.explPlayerOnly = menu.realismPlusMode_explPlayerOnly;
  c.explAffectGrenades = menu.realismPlusMode_explAffectGrenades;
  c.explAffectWeapon = menu.realismPlusMode_explAffectWeapon;
  c.explAffectBullet = menu.realismPlusMode_explAffectBullet;
  c.explAffectVehicle = menu.realismPlusMode_explAffectVehicle;
  c.grenadeKickRadius = RFC_ClampF(menu.realismPlusMode_grenadeKickRadius, 0.0, 10.0);
  c.grenadeKickX = RFC_ClampF(menu.realismPlusMode_grenadeKickX, 0.0, 40.0);
  c.grenadeKickY = RFC_ClampF(menu.realismPlusMode_grenadeKickY, 0.0, 40.0);
  c.grenadeKickZ = RFC_ClampF(menu.realismPlusMode_grenadeKickZ, 0.0, 40.0)
    - RFC_ClampF(menu.realismPlusMode_grenadeKickDown, 0.0, 40.0);
  c.grenadeKickCallDelay = RFC_ClampF(menu.realismPlusMode_grenadeKickCallDelay, 0.0, 10.0);
  c.explMulGrenades = RFC_ClampF(menu.realismPlusMode_explMulGrenades, 0.0, 10.0);
  c.explMulWeapon = RFC_ClampF(menu.realismPlusMode_explMulWeapon, 0.0, 10.0);
  c.explMulBullet = RFC_ClampF(menu.realismPlusMode_explMulBullet, 0.0, 10.0);
  c.explMulVehicle = RFC_ClampF(menu.realismPlusMode_explMulVehicle, 0.0, 30.0);

  c.tumbleEnabled = menu.realismPlusMode_tumbleEnabled;
  c.directionalTumbleEnabled = menu.realismPlusMode_directionalTumbleEnabled;
  c.overrideTumbleStairs = menu.realismPlusMode_overrideTumbleStairs;
  if c.overrideTumbleStairs {
    c.tumbleStairs_down = 0.0 - AbsF(menu.realismPlusMode_tumbleStairs_down);
    c.tumbleStairs_fwd = menu.realismPlusMode_tumbleStairs_fwd;
    c.tumbleStairs_side = menu.realismPlusMode_tumbleStairs_side;
    c.tumbleStairs_radius = RFC_ClampF(menu.realismPlusMode_tumbleStairs_radius, 0.05, 10.0);
    c.tumbleStairs_steps = RFC_ClampI(menu.realismPlusMode_tumbleStairs_steps, 1, 100);
    c.tumbleStairs_stepDelay = RFC_ClampF(menu.realismPlusMode_tumbleStairs_stepDelay, 0.0, 30.0);
  }
  c.overrideTumbleDirectional = menu.realismPlusMode_overrideTumbleDirectional;
  if c.overrideTumbleDirectional {
    c.tumbleDir_down = 0.0 - AbsF(menu.realismPlusMode_tumbleDir_down);
    c.tumbleDir_fwd = menu.realismPlusMode_tumbleDir_fwd;
    c.tumbleDir_side = menu.realismPlusMode_tumbleDir_side;
    c.tumbleDir_radius = RFC_ClampF(menu.realismPlusMode_tumbleDir_radius, 0.05, 10.0);
    c.tumbleDir_steps = RFC_ClampI(menu.realismPlusMode_tumbleDir_steps, 1, 100);
    c.tumbleDir_stepDelay = RFC_ClampF(menu.realismPlusMode_tumbleDir_stepDelay, 0.0, 30.0);
  }

  c.settleEnabled = menu.realismPlusMode_settleEnabled;
  c.settleStrength = RFC_ClampF(menu.realismPlusMode_settleStrength, 0.0, 20.0);

  // Named modes now use Hit Jolts / Bullet Jolts instead.
  c.bulletJoltsEnabled = menu.realismPlusMode_bulletJoltsEnabled;
  c.bulletJoltStrengthScale = RFC_ClampF(menu.realismPlusMode_bulletJoltStrengthScale, 0.0, 10.0);
  c.bulletJoltRadiusScale = RFC_ClampF(menu.realismPlusMode_bulletJoltRadiusScale, 0.1, 5.0);
  c.bulletJoltDelayScale = RFC_ClampF(menu.realismPlusMode_bulletJoltDelayScale, 0.0, 5.0);
  c.bulletJoltWaitForGround = menu.realismPlusMode_bulletJoltWaitForGround;
  c.bulletJoltGroundWaitMax = RFC_ClampF(menu.realismPlusMode_bulletJoltGroundWaitMax, 0.1, 5.0);
  c.bulletJoltAllowAirborne = menu.realismPlusMode_bulletJoltAllowAirborne;
  c.twitchEnabled = menu.realismPlusMode_twitchEnabled;
  c.twitchForce = RFC_ClampF(menu.realismPlusMode_twitchForce, 0.0, 200.0);
  c.headReboundKneeNearPct = RFC_ClampF(menu.realismPlusMode_headReboundKneeNearPct, 0.0, 100.0);

  // Realism Plus: Realism is still the full base (shape, timing, and strength).
  // Realism Plus only applies hidden multiplier overlays to the final force sources.
  if menu.realismPlus_multipliersEnabled {
    let rpBodyDown: Float = RFC_ClampF(menu.realismPlus_bodyDownScale, 0.0, 5.0);
    let rpBodyUp: Float = RFC_ClampF(menu.realismPlus_bodyUpScale, 0.0, 3.0);
    let rpBodyFwd: Float = RFC_ClampF(menu.realismPlus_bodyForwardScale, 0.0, 3.0);
    let rpBodySide: Float = RFC_ClampF(menu.realismPlus_bodySideScale, 0.0, 3.0);
    let rpBodySlam: Float = RFC_ClampF(menu.realismPlus_bodySlamScale, 0.0, 5.0);

    let rpHeadDown: Float = RFC_ClampF(menu.realismPlus_headDownScale, 0.0, 5.0);
    let rpHeadUp: Float = RFC_ClampF(menu.realismPlus_headUpScale, 0.0, 3.0);
    let rpHeadFwd: Float = RFC_ClampF(menu.realismPlus_headForwardScale, 0.0, 3.0);
    let rpHeadSide: Float = RFC_ClampF(menu.realismPlus_headSideScale, 0.0, 3.0);
    let rpHeadSlam: Float = RFC_ClampF(menu.realismPlus_headSlamScale, 0.0, 5.0);

    let rpSitDown: Float = RFC_ClampF(menu.realismPlus_situationalDownScale, 0.0, 5.0);
    let rpSitUp: Float = RFC_ClampF(menu.realismPlus_situationalUpScale, 0.0, 3.0);
    let rpSitFwd: Float = RFC_ClampF(menu.realismPlus_situationalForwardScale, 0.0, 3.0);
    let rpSitSide: Float = RFC_ClampF(menu.realismPlus_situationalSideScale, 0.0, 3.0);
    let rpSitSlam: Float = RFC_ClampF(menu.realismPlus_situationalSlamScale, 0.0, 5.0);
    let rpAllUp: Float = RFC_ClampF((rpBodyUp + rpHeadUp + rpSitUp) * 0.333333, 0.0, 3.0);
    let rpAllSide: Float = RFC_ClampF(rpSitSide * ((rpBodySide + rpHeadSide) * 0.5), 0.0, 5.0);

    // Body down sources: chest/pelvis/knees/feet/anchors/body-down style forces.
    c.st_downChest = RFC_ClampF(c.st_downChest * rpBodyDown, -80.0, 80.0);
    c.st_downChestMin = RFC_ClampF(c.st_downChestMin * rpBodyDown, -80.0, 80.0);
    c.st_downPelvis = RFC_ClampF(c.st_downPelvis * rpBodyDown, -80.0, 80.0);
    c.st_downPelvisMin = RFC_ClampF(c.st_downPelvisMin * rpBodyDown, -80.0, 80.0);
    c.st_kneeDown = RFC_ClampF(c.st_kneeDown * rpBodyDown, -80.0, 80.0);
    c.st_kneeDownMin = RFC_ClampF(c.st_kneeDownMin * rpBodyDown, -80.0, 80.0);
    c.st_shinDown = RFC_ClampF(c.st_shinDown * rpBodyDown, -80.0, 80.0);
    c.st_footDown = RFC_ClampF(c.st_footDown * rpBodyDown, -80.0, 80.0);
    c.st_anchorDown = RFC_ClampF(c.st_anchorDown * rpBodyDown, -80.0, 80.0);

    c.run_downChest = RFC_ClampF(c.run_downChest * rpBodyDown, -80.0, 80.0);
    c.run_downChestMin = RFC_ClampF(c.run_downChestMin * rpBodyDown, -80.0, 80.0);
    c.run_downPelvis = RFC_ClampF(c.run_downPelvis * rpBodyDown, -80.0, 80.0);
    c.run_downPelvisMin = RFC_ClampF(c.run_downPelvisMin * rpBodyDown, -80.0, 80.0);
    c.run_kneeDown = RFC_ClampF(c.run_kneeDown * rpBodyDown, -80.0, 80.0);
    c.run_kneeDownMin = RFC_ClampF(c.run_kneeDownMin * rpBodyDown, -80.0, 80.0);
    c.run_shinDown = RFC_ClampF(c.run_shinDown * rpBodyDown, -80.0, 80.0);
    c.run_footDown = RFC_ClampF(c.run_footDown * rpBodyDown, -80.0, 80.0);
    c.run_anchorDown = RFC_ClampF(c.run_anchorDown * rpBodyDown, -80.0, 80.0);

    c.walk_downChest = RFC_ClampF(c.walk_downChest * rpBodyDown, -80.0, 80.0);
    c.walk_downPelvis = RFC_ClampF(c.walk_downPelvis * rpBodyDown, -80.0, 80.0);
    c.walk_kneeDown = RFC_ClampF(c.walk_kneeDown * rpBodyDown, -80.0, 80.0);

    c.stair_downChest = RFC_ClampF(c.stair_downChest * rpBodyDown, -80.0, 80.0);
    c.stair_downChestMin = RFC_ClampF(c.stair_downChestMin * rpBodyDown, -80.0, 80.0);
    c.stair_downPelvis = RFC_ClampF(c.stair_downPelvis * rpBodyDown, -80.0, 80.0);
    c.stair_downPelvisMin = RFC_ClampF(c.stair_downPelvisMin * rpBodyDown, -80.0, 80.0);
    c.stair_kneeDown = RFC_ClampF(c.stair_kneeDown * rpBodyDown, -80.0, 80.0);
    c.stair_kneeDownMin = RFC_ClampF(c.stair_kneeDownMin * rpBodyDown, -80.0, 80.0);
    c.stair_runFeetDown = RFC_ClampF(c.stair_runFeetDown * rpBodyDown, -80.0, 80.0);
    c.stair_plankChestDown = RFC_ClampF(c.stair_plankChestDown * rpBodyDown, -80.0, 80.0);
    c.stair_plankChestDownMin = RFC_ClampF(c.stair_plankChestDownMin * rpBodyDown, -80.0, 80.0);
    c.stair_plankPelvisDown = RFC_ClampF(c.stair_plankPelvisDown * rpBodyDown, -80.0, 80.0);
    c.stair_plankPelvisDownMin = RFC_ClampF(c.stair_plankPelvisDownMin * rpBodyDown, -80.0, 80.0);

    // Body forward/back and side sources.
    c.st_forward = RFC_ClampF(c.st_forward * rpBodyFwd, -80.0, 80.0);
    c.st_forwardMin = RFC_ClampF(c.st_forwardMin * rpBodyFwd, -80.0, 80.0);
    c.st_footFwd = RFC_ClampF(c.st_footFwd * rpBodyFwd, -80.0, 80.0);
    c.st_shinBack = RFC_ClampF(c.st_shinBack * rpBodyFwd, -80.0, 80.0);
    c.st_anchorFwd = RFC_ClampF(c.st_anchorFwd * rpBodyFwd, -80.0, 80.0);
    c.run_forward = RFC_ClampF(c.run_forward * rpBodyFwd, -80.0, 80.0);
    c.run_forwardMin = RFC_ClampF(c.run_forwardMin * rpBodyFwd, -80.0, 80.0);
    c.run_footFwd = RFC_ClampF(c.run_footFwd * rpBodyFwd, -80.0, 80.0);
    c.run_shinBack = RFC_ClampF(c.run_shinBack * rpBodyFwd, -80.0, 80.0);
    c.run_anchorFwd = RFC_ClampF(c.run_anchorFwd * rpBodyFwd, -80.0, 80.0);
    c.walk_forward = RFC_ClampF(c.walk_forward * rpBodyFwd, -80.0, 80.0);
    c.stair_forward = RFC_ClampF(c.stair_forward * rpBodyFwd, -80.0, 80.0);
    c.stair_forwardMin = RFC_ClampF(c.stair_forwardMin * rpBodyFwd, -80.0, 80.0);
    c.stair_chestFwd = RFC_ClampF(c.stair_chestFwd * rpBodyFwd, -80.0, 80.0);
    c.stair_chestFwdMin = RFC_ClampF(c.stair_chestFwdMin * rpBodyFwd, -80.0, 80.0);
    c.stair_plankFwd = RFC_ClampF(c.stair_plankFwd * rpBodyFwd, -80.0, 80.0);
    c.stair_plankFwdMin = RFC_ClampF(c.stair_plankFwdMin * rpBodyFwd, -80.0, 80.0);

    // Body impact slam sources.
    c.st_vSlamZ = RFC_ClampF(c.st_vSlamZ * rpBodySlam, -80.0, 80.0);
    c.run_vSlamZ = RFC_ClampF(c.run_vSlamZ * rpBodySlam, -80.0, 80.0);
    c.walk_vSlamZ = RFC_ClampF(c.walk_vSlamZ * rpBodySlam, -80.0, 80.0);
    c.stair_vSlamZ = RFC_ClampF(c.stair_vSlamZ * rpBodySlam, -80.0, 80.0);
    c.stair_vSlamZMin = RFC_ClampF(c.stair_vSlamZMin * rpBodySlam, -80.0, 80.0);
    c.wsStand.body_vSlamZ = RFC_ClampF(c.wsStand.body_vSlamZ * rpBodySlam, -80.0, 80.0);
    c.st_d_chestFall = RFC_ClampF(c.st_d_chestFall * rpBodySlam, -80.0, 80.0);
    c.st_d_pelvisFall = RFC_ClampF(c.st_d_pelvisFall * rpBodySlam, -80.0, 80.0);
    c.st_d_knee = RFC_ClampF(c.st_d_knee * rpBodySlam, -80.0, 80.0);
    c.st_d_vSlam = RFC_ClampF(c.st_d_vSlam * rpBodySlam, -80.0, 80.0);
    c.run_d_chestFall = RFC_ClampF(c.run_d_chestFall * rpBodySlam, -80.0, 80.0);
    c.run_d_pelvisFall = RFC_ClampF(c.run_d_pelvisFall * rpBodySlam, -80.0, 80.0);
    c.run_d_knee = RFC_ClampF(c.run_d_knee * rpBodySlam, -80.0, 80.0);
    c.run_d_vSlam = RFC_ClampF(c.run_d_vSlam * rpBodySlam, -80.0, 80.0);
    c.walk_d_chestFall = RFC_ClampF(c.walk_d_chestFall * rpBodySlam, -80.0, 80.0);
    c.walk_d_pelvisFall = RFC_ClampF(c.walk_d_pelvisFall * rpBodySlam, -80.0, 80.0);
    c.walk_d_knee = RFC_ClampF(c.walk_d_knee * rpBodySlam, -80.0, 80.0);
    c.walk_d_vSlam = RFC_ClampF(c.walk_d_vSlam * rpBodySlam, -80.0, 80.0);

    // Head down / forward / slam sources.
    c.st_downHead = RFC_ClampF(c.st_downHead * rpHeadDown, -1000.0, 1000.0);
    c.st_downHeadMin = RFC_ClampF(c.st_downHeadMin * rpHeadDown, -1000.0, 1000.0);
    c.run_downHead = RFC_ClampF(c.run_downHead * rpHeadDown, -1000.0, 1000.0);
    c.run_downHeadMin = RFC_ClampF(c.run_downHeadMin * rpHeadDown, -1000.0, 1000.0);
    c.walk_downHead = RFC_ClampF(c.walk_downHead * rpHeadDown, -1000.0, 1000.0);
    c.stair_downHead = RFC_ClampF(c.stair_downHead * rpHeadDown, -1000.0, 1000.0);
    c.stair_downHeadMin = RFC_ClampF(c.stair_downHeadMin * rpHeadDown, -1000.0, 1000.0);
    c.stair_plankHeadDown = RFC_ClampF(c.stair_plankHeadDown * rpHeadDown, -80.0, 80.0);
    c.stair_plankHeadDownMin = RFC_ClampF(c.stair_plankHeadDownMin * rpHeadDown, -80.0, 80.0);
    c.wsStand.headDown = RFC_ClampF(c.wsStand.headDown * rpHeadDown, -80.0, 80.0);
    c.cow.headDown = RFC_ClampF(c.cow.headDown * rpHeadDown, -1000.0, 1000.0);
    c.cow.headDownMin = RFC_ClampF(c.cow.headDownMin * rpHeadDown, -1000.0, 1000.0);

    c.stair_headFwd = RFC_ClampF(c.stair_headFwd * rpHeadFwd, -80.0, 80.0);
    c.stair_headFwdMin = RFC_ClampF(c.stair_headFwdMin * rpHeadFwd, -80.0, 80.0);
    c.wsStand.headFwd = RFC_ClampF(c.wsStand.headFwd * rpHeadFwd, -80.0, 80.0);
    c.st_d_headSlam = RFC_ClampF(c.st_d_headSlam * rpHeadSlam, -80.0, 80.0);
    c.st_d_headSnap = RFC_ClampF(c.st_d_headSnap * rpHeadSlam, -80.0, 80.0);
    c.run_d_headSlam = RFC_ClampF(c.run_d_headSlam * rpHeadSlam, -80.0, 80.0);
    c.walk_d_headSlam = RFC_ClampF(c.walk_d_headSlam * rpHeadSlam, -80.0, 80.0);

    // Situational sources: tumble, stairs/directional tumble, settle, Bullet Jolt, explosions.
    c.tumbleStairs_down = RFC_ClampF(c.tumbleStairs_down * rpSitDown, -120.0, 120.0);
    c.tumbleDir_down = RFC_ClampF(c.tumbleDir_down * rpSitDown, -120.0, 120.0);
    c.settleDown = RFC_ClampF(c.settleDown * rpSitDown, -80.0, 80.0);

    c.arcadeBulletUp = RFC_ClampF(c.arcadeBulletUp * rpAllUp, 0.0, 20.0);
    c.arcadeBulletDown = RFC_ClampF(c.arcadeBulletDown * rpSitDown, 0.0, 20.0);
    c.arcadeMeleeUp = RFC_ClampF(c.arcadeMeleeUp * rpAllUp, 0.0, 20.0);
    c.arcadeMeleeDown = RFC_ClampF(c.arcadeMeleeDown * rpSitDown, 0.0, 20.0);
    c.grenadeKickZ = RFC_ClampF(c.grenadeKickZ * rpSitUp, 0.0, 80.0);

    c.tumbleStairs_fwd = RFC_ClampF(c.tumbleStairs_fwd * rpSitFwd, -120.0, 120.0);
    c.tumbleDir_fwd = RFC_ClampF(c.tumbleDir_fwd * rpSitFwd, -120.0, 120.0);
    c.settleFwd = RFC_ClampF(c.settleFwd * rpSitFwd, -80.0, 80.0);
    c.grenadeKickX = RFC_ClampF(c.grenadeKickX * rpSitFwd, 0.0, 80.0);
    c.grenadeKickY = RFC_ClampF(c.grenadeKickY * rpSitFwd, 0.0, 80.0);
    c.stair_brakeFwd = RFC_ClampF(c.stair_brakeFwd * rpSitFwd, -80.0, 80.0);
    c.stair_brakeFwdMin = RFC_ClampF(c.stair_brakeFwdMin * rpSitFwd, -80.0, 80.0);
    c.stair_plankBrakeFwd = RFC_ClampF(c.stair_plankBrakeFwd * rpSitFwd, -80.0, 80.0);
    c.stair_plankBrakeFwdMin = RFC_ClampF(c.stair_plankBrakeFwdMin * rpSitFwd, -80.0, 80.0);

    c.tumbleStairs_side = RFC_ClampF(c.tumbleStairs_side * rpAllSide, -120.0, 120.0);
    c.tumbleDir_side = RFC_ClampF(c.tumbleDir_side * rpAllSide, -120.0, 120.0);

    c.settleEnabled = true;
    c.settleStrength = RFC_ClampF(c.settleStrength * rpSitSlam, 0.0, 40.0);
    c.bulletJoltStrengthScale = RFC_ClampF(c.bulletJoltStrengthScale * rpSitSlam, 0.0, 20.0);
    c.explMulGrenades = RFC_ClampF(c.explMulGrenades * rpSitSlam, 0.0, 20.0);
    c.explMulWeapon = RFC_ClampF(c.explMulWeapon * rpSitSlam, 0.0, 20.0);
    c.explMulBullet = RFC_ClampF(c.explMulBullet * rpSitSlam, 0.0, 20.0);
    c.explMulVehicle = RFC_ClampF(c.explMulVehicle * rpSitSlam, 0.0, 50.0);
  }

} else if c.splatPresetMode == EnumInt(RFCSplatPresetMode.DirtyHarry) {
  // Global and Animation Controls are shared across all non-Vanilla modes.
  // Their base values were loaded above and are intentionally not overridden
  // by this named mode.
  c.arcadeBulletsEnabled = menu.dirty_arcadeBulletsEnabled;
  c.arcadeUseWeaponAllowList = true;
  c.vehicleImpulseEnabled = menu.dirty_vehicleImpulseEnabled;
  c.vehicleBulletEnabled = menu.dirty_vehicleBulletEnabled;
  c.vehicleBulletStrength = RFC_ClampF(menu.dirty_vehicleBulletStrength, 0.0, 8000.0);
  c.vehicleBulletLift = RFC_ClampF(menu.dirty_vehicleBulletUp, 0.0, 8000.0)
    - RFC_ClampF(menu.dirty_vehicleBulletDown, 0.0, 8000.0);
  c.vehicleBulletRadius = RFC_ClampF(menu.dirty_vehicleBulletRadius, 0.05, 20.0);
  c.vehicleMulHandgun = RFC_ClampF(menu.dirty_vehicleMulHandgun, 0.0, 20.0);
  c.vehicleMulMagnum = RFC_ClampF(menu.dirty_vehicleMulMagnum, 0.0, 20.0);
  c.vehicleMulShotgun = RFC_ClampF(menu.dirty_vehicleMulShotgun, 0.0, 20.0);
  c.vehicleMulSniper = RFC_ClampF(menu.dirty_vehicleMulSniper, 0.0, 20.0);
  c.vehicleMulSMG = RFC_ClampF(menu.dirty_vehicleMulSMG, 0.0, 20.0);
  c.vehicleMulAR = RFC_ClampF(menu.dirty_vehicleMulAR, 0.0, 20.0);
  c.vehicleMulLMG = RFC_ClampF(menu.dirty_vehicleMulLMG, 0.0, 20.0);
  c.vehicleMulUnknownBullet = RFC_ClampF(menu.dirty_vehicleMulUnknownBullet, 0.0, 20.0);
  c.vehicleExplosionEnabled = menu.dirty_vehicleExplosionEnabled;
  c.vehicleExplosionStrength = RFC_ClampF(menu.dirty_vehicleExplosionStrength, 0.0, 16900.0);
  c.vehicleExplosionLift = RFC_ClampF(menu.dirty_vehicleExplosionLift, 0.0, 16900.0)
    - RFC_ClampF(menu.dirty_vehicleExplosionDown, 0.0, 16900.0);
  c.vehicleExplosionRadius = RFC_ClampF(menu.dirty_vehicleExplosionRadius, 0.05, 20.0);
  c.vehicleMeleeEnabled = menu.dirty_vehicleMeleeEnabled;
  c.vehicleMeleeStrength = RFC_ClampF(menu.dirty_vehicleMeleeStrength, 0.0, 8000.0);
  c.vehicleMeleeLift = RFC_ClampF(menu.dirty_vehicleMeleeUp, 0.0, 8000.0)
    - RFC_ClampF(menu.dirty_vehicleMeleeDown, 0.0, 8000.0);
  c.vehicleMeleeRadius = RFC_ClampF(menu.dirty_vehicleMeleeRadius, 0.05, 20.0);
  c.vehicleUseExplosionMultipliers = menu.vehicleUseExplosionMultipliers;
  c.vehicleUseArcadeWeaponFilters = false;
  c.vehicleUseArcadeWeaponMultipliers = false;
  c.vehicleAllowUnknownBullet = true;
  c.arcadePlayerOnly = menu.dirty_arcadePlayerOnly;
  c.arcadeIndependentSourceControls = false;
  c.arcadeAllowPlayerBullet = true;
  c.arcadeAllowNPCBullet = !c.arcadePlayerOnly;
  c.arcadeAllowPlayerMelee = true;
  c.arcadeAllowNPCMelee = !c.arcadePlayerOnly;
  c.arcadeOnHitEnabled = menu.dirty_arcadeOnHitEnabled;
  c.arcadeOnDeathEnabled = menu.dirty_arcadeOnDeathEnabled;
  c.arcadeBulletStrength = RFC_ClampF(menu.dirty_arcadeBulletStrength, 0.0, 80.0);
  c.arcadeBulletUp = RFC_ClampF(menu.dirty_arcadeBulletUp, 0.0, 20.0);
  c.arcadeBulletDown = RFC_ClampF(menu.dirty_arcadeBulletDown, 0.0, 20.0);
  c.arcadeBulletRadius = RFC_ClampF(menu.dirty_arcadeBulletRadius, 0.05, 5.0);
  c.arcadeApplicationPointOffset = RFC_ClampF(menu.dirty_arcadeApplicationPointOffset, 0.0, 1.0);
  c.arcadeMeleeEnabled = menu.dirty_arcadeMeleeEnabled;
  c.arcadeMeleeStrength = RFC_ClampF(menu.dirty_arcadeMeleeStrength, 0.0, 80.0);
  c.arcadeMeleeUp = RFC_ClampF(menu.dirty_arcadeMeleeUp, 0.0, 20.0);
  c.arcadeMeleeDown = RFC_ClampF(menu.dirty_arcadeMeleeDown, 0.0, 20.0);
  c.arcadeMeleeRadius = RFC_ClampF(menu.dirty_arcadeMeleeRadius, 0.05, 5.0);
  c.arcadeBulletCooldown = RFC_ClampF(menu.dirty_arcadeBulletCooldown, 0.0, 2.0);
  c.arcadeImpulseDelay = RFC_ClampF(menu.dirty_arcadeImpulseDelay, 0.0, 0.50);
  c.arcadeCowScale = RFC_ClampF(menu.dirty_arcadeCowScale, 0.0, 3.0);
  c.arcadeAllowHandgun = menu.dirty_arcadeAllowHandgun;
  c.arcadeAllowMagnum = menu.dirty_arcadeAllowMagnum;
  c.arcadeAllowShotgun = menu.dirty_arcadeAllowShotgun;
  c.arcadeAllowSniper = menu.dirty_arcadeAllowSniper;
  c.arcadeAllowSMG = menu.dirty_arcadeAllowSMG;
  c.arcadeAllowAR = menu.dirty_arcadeAllowAR;
  c.arcadeAllowLMG = menu.dirty_arcadeAllowLMG;
  c.arcadeAllowBlunt = menu.dirty_arcadeAllowBlunt;
  c.arcadeAllowBlade = menu.dirty_arcadeAllowBlade;
  c.arcadeMulHandgun = RFC_ClampF(menu.dirty_arcadeMulHandgun, 0.0, 5.0);
  c.arcadeMulMagnum = RFC_ClampF(menu.dirty_arcadeMulMagnum, 0.0, 5.0);
  c.arcadeMulShotgun = RFC_ClampF(menu.dirty_arcadeMulShotgun, 0.0, 5.0);
  c.arcadeMulSniper = RFC_ClampF(menu.dirty_arcadeMulSniper, 0.0, 5.0);
  c.arcadeMulSMG = RFC_ClampF(menu.dirty_arcadeMulSMG, 0.0, 5.0);
  c.arcadeMulAR = RFC_ClampF(menu.dirty_arcadeMulAR, 0.0, 5.0);
  c.arcadeMulLMG = RFC_ClampF(menu.dirty_arcadeMulLMG, 0.0, 5.0);
  c.arcadeMulBlunt = RFC_ClampF(menu.dirty_arcadeMulBlunt, 0.0, 5.0);
  c.arcadeMulBlade = RFC_ClampF(menu.dirty_arcadeMulBlade, 0.0, 5.0);

  c.vanillaImpulsesEnabled = menu.dirty_vanillaImpulsesEnabled;
  c.vanillaAllowHandgun = menu.dirty_vanillaAllowHandgun;
  c.vanillaAllowMagnum = menu.dirty_vanillaAllowMagnum;
  c.vanillaAllowShotgun = menu.dirty_vanillaAllowShotgun;
  c.vanillaAllowSniper = menu.dirty_vanillaAllowSniper;
  c.vanillaAllowSMG = menu.dirty_vanillaAllowSMG;
  c.vanillaAllowAR = menu.dirty_vanillaAllowAR;
  c.vanillaAllowLMG = menu.dirty_vanillaAllowLMG;
  c.vanillaAllowBlunt = menu.dirty_vanillaAllowBlunt;
  c.vanillaAllowBlade = menu.dirty_vanillaAllowBlade;

  c.grenadeEnabled = menu.dirty_grenadeEnabled;
  c.explPlayerOnly = menu.dirty_explPlayerOnly;
  c.explAffectGrenades = menu.dirty_explAffectGrenades;
  c.explAffectWeapon = menu.dirty_explAffectWeapon;
  c.explAffectBullet = menu.dirty_explAffectBullet;
  c.explAffectVehicle = menu.dirty_explAffectVehicle;
  c.grenadeKickRadius = RFC_ClampF(menu.dirty_grenadeKickRadius, 0.0, 10.0);
  c.grenadeKickX = RFC_ClampF(menu.dirty_grenadeKickX, 0.0, 40.0);
  c.grenadeKickY = RFC_ClampF(menu.dirty_grenadeKickY, 0.0, 40.0);
  c.grenadeKickZ = RFC_ClampF(menu.dirty_grenadeKickZ, 0.0, 40.0)
    - RFC_ClampF(menu.dirty_grenadeKickDown, 0.0, 40.0);
  c.grenadeKickCallDelay = RFC_ClampF(menu.dirty_grenadeKickCallDelay, 0.0, 10.0);
  c.explMulGrenades = RFC_ClampF(menu.dirty_explMulGrenades, 0.0, 10.0);
  c.explMulWeapon = RFC_ClampF(menu.dirty_explMulWeapon, 0.0, 10.0);
  c.explMulBullet = RFC_ClampF(menu.dirty_explMulBullet, 0.0, 10.0);
  c.explMulVehicle = RFC_ClampF(menu.dirty_explMulVehicle, 0.0, 30.0);

  c.tumbleEnabled = menu.dirty_tumbleEnabled;
  c.directionalTumbleEnabled = menu.dirty_directionalTumbleEnabled;
  c.overrideTumbleStairs = menu.dirty_overrideTumbleStairs;
  if c.overrideTumbleStairs {
    c.tumbleStairs_down = 0.0 - AbsF(menu.dirty_tumbleStairs_down);
    c.tumbleStairs_fwd = menu.dirty_tumbleStairs_fwd;
    c.tumbleStairs_side = menu.dirty_tumbleStairs_side;
    c.tumbleStairs_radius = RFC_ClampF(menu.dirty_tumbleStairs_radius, 0.05, 10.0);
    c.tumbleStairs_steps = RFC_ClampI(menu.dirty_tumbleStairs_steps, 1, 100);
    c.tumbleStairs_stepDelay = RFC_ClampF(menu.dirty_tumbleStairs_stepDelay, 0.0, 30.0);
  }
  c.overrideTumbleDirectional = menu.dirty_overrideTumbleDirectional;
  if c.overrideTumbleDirectional {
    c.tumbleDir_down = 0.0 - AbsF(menu.dirty_tumbleDir_down);
    c.tumbleDir_fwd = menu.dirty_tumbleDir_fwd;
    c.tumbleDir_side = menu.dirty_tumbleDir_side;
    c.tumbleDir_radius = RFC_ClampF(menu.dirty_tumbleDir_radius, 0.05, 10.0);
    c.tumbleDir_steps = RFC_ClampI(menu.dirty_tumbleDir_steps, 1, 100);
    c.tumbleDir_stepDelay = RFC_ClampF(menu.dirty_tumbleDir_stepDelay, 0.0, 30.0);
  }

  c.settleEnabled = menu.dirty_settleEnabled;
  c.settleStrength = RFC_ClampF(menu.dirty_settleStrength, 0.0, 20.0);

  // Named modes now use Hit Jolts / Bullet Jolts instead.
  c.bulletJoltsEnabled = menu.dirty_bulletJoltsEnabled;
  c.bulletJoltStrengthScale = RFC_ClampF(menu.dirty_bulletJoltStrengthScale, 0.0, 10.0);
  c.bulletJoltRadiusScale = RFC_ClampF(menu.dirty_bulletJoltRadiusScale, 0.1, 5.0);
  c.bulletJoltDelayScale = RFC_ClampF(menu.dirty_bulletJoltDelayScale, 0.0, 5.0);
  c.bulletJoltWaitForGround = menu.dirty_bulletJoltWaitForGround;
  c.bulletJoltGroundWaitMax = RFC_ClampF(menu.dirty_bulletJoltGroundWaitMax, 0.1, 5.0);
  c.bulletJoltAllowAirborne = menu.dirty_bulletJoltAllowAirborne;
  c.twitchEnabled = menu.dirty_twitchEnabled;
  c.twitchForce = RFC_ClampF(menu.dirty_twitchForce, 0.0, 200.0);
  c.headReboundKneeNearPct = RFC_ClampF(menu.dirty_headReboundKneeNearPct, 0.0, 100.0);
} else if c.splatPresetMode == EnumInt(RFCSplatPresetMode.Arnold) {
  // Global and Animation Controls are shared across all non-Vanilla modes.
  // Their base values were loaded above and are intentionally not overridden
  // by this named mode.
  c.arcadeBulletsEnabled = menu.arnold_arcadeBulletsEnabled;
  c.arcadeUseWeaponAllowList = true;
  c.vehicleImpulseEnabled = menu.arnold_vehicleImpulseEnabled;
  c.vehicleBulletEnabled = menu.arnold_vehicleBulletEnabled;
  c.vehicleBulletStrength = RFC_ClampF(menu.arnold_vehicleBulletStrength, 0.0, 8000.0);
  c.vehicleBulletLift = RFC_ClampF(menu.arnold_vehicleBulletUp, 0.0, 8000.0)
    - RFC_ClampF(menu.arnold_vehicleBulletDown, 0.0, 8000.0);
  c.vehicleBulletRadius = RFC_ClampF(menu.arnold_vehicleBulletRadius, 0.05, 20.0);
  c.vehicleMotorcycleToppleOnBullet = menu.arnold_vehicleMotorcycleToppleOnBullet;
  c.vehicleMotorcycleToppleStrength = RFC_ClampF(menu.arnold_vehicleMotorcycleToppleStrength, 0.0, 12.0);
  c.playerMotorcycleLeanToppleEnabled = menu.arnold_playerMotorcycleLeanToppleEnabled;
  c.playerMotorcycleLeanToppleAngle = RFC_ClampF(menu.arnold_playerMotorcycleLeanToppleAngle, 5.0, 90.0);
  c.playerMotorcycleLeanToppleMaxSpeed = RFC_ClampF(menu.arnold_playerMotorcycleLeanToppleMaxSpeed, 0.0, 100.0);
  c.vehicleMulHandgun = RFC_ClampF(menu.arnold_vehicleMulHandgun, 0.0, 20.0);
  c.vehicleMulMagnum = RFC_ClampF(menu.arnold_vehicleMulMagnum, 0.0, 20.0);
  c.vehicleMulShotgun = RFC_ClampF(menu.arnold_vehicleMulShotgun, 0.0, 20.0);
  c.vehicleMulSniper = RFC_ClampF(menu.arnold_vehicleMulSniper, 0.0, 20.0);
  c.vehicleMulSMG = RFC_ClampF(menu.arnold_vehicleMulSMG, 0.0, 20.0);
  c.vehicleMulAR = RFC_ClampF(menu.arnold_vehicleMulAR, 0.0, 20.0);
  c.vehicleMulLMG = RFC_ClampF(menu.arnold_vehicleMulLMG, 0.0, 20.0);
  c.vehicleMulUnknownBullet = RFC_ClampF(menu.arnold_vehicleMulUnknownBullet, 0.0, 20.0);
  c.vehicleExplosionEnabled = menu.arnold_vehicleExplosionEnabled;
  c.vehicleExplosionStrength = RFC_ClampF(menu.arnold_vehicleExplosionStrength, 0.0, 16900.0);
  c.vehicleExplosionLift = RFC_ClampF(menu.arnold_vehicleExplosionLift, 0.0, 16900.0)
    - RFC_ClampF(menu.arnold_vehicleExplosionDown, 0.0, 16900.0);
  c.vehicleExplosionRadius = RFC_ClampF(menu.arnold_vehicleExplosionRadius, 0.05, 20.0);
  c.vehicleMeleeEnabled = menu.arnold_vehicleMeleeEnabled;
  c.vehicleMeleeStrength = RFC_ClampF(menu.arnold_vehicleMeleeStrength, 0.0, 8000.0);
  c.vehicleMeleeLift = RFC_ClampF(menu.arnold_vehicleMeleeUp, 0.0, 8000.0)
    - RFC_ClampF(menu.arnold_vehicleMeleeDown, 0.0, 8000.0);
  c.vehicleMeleeRadius = RFC_ClampF(menu.arnold_vehicleMeleeRadius, 0.05, 20.0);
  c.vehicleUseExplosionMultipliers = menu.vehicleUseExplosionMultipliers;
  c.vehicleUseArcadeWeaponFilters = false;
  // Vehicle bullets have their own Arnold multipliers. Do not multiply them
  // a second time by the NPC Arcade weapon multipliers.
  c.vehicleUseArcadeWeaponMultipliers = false;
  c.vehicleAllowUnknownBullet = true;
  c.arcadePlayerOnly = menu.arnold_arcadePlayerOnly;
  c.arcadeIndependentSourceControls = false;
  c.arcadeAllowPlayerBullet = true;
  c.arcadeAllowNPCBullet = !c.arcadePlayerOnly;
  c.arcadeAllowPlayerMelee = true;
  c.arcadeAllowNPCMelee = !c.arcadePlayerOnly;
  c.arcadeOnHitEnabled = menu.arnold_arcadeOnHitEnabled;
  c.arcadeOnDeathEnabled = menu.arnold_arcadeOnDeathEnabled;
  c.arcadeBulletStrength = RFC_ClampF(menu.arnold_arcadeBulletStrength, 0.0, 80.0);
  c.arcadeBulletUp = RFC_ClampF(menu.arnold_arcadeBulletUp, 0.0, 20.0);
  c.arcadeBulletDown = RFC_ClampF(menu.arnold_arcadeBulletDown, 0.0, 20.0);
  c.arcadeBulletRadius = RFC_ClampF(menu.arnold_arcadeBulletRadius, 0.05, 5.0);
  c.arcadeApplicationPointOffset = RFC_ClampF(menu.arnold_arcadeApplicationPointOffset, 0.0, 1.0);
  c.arcadeMeleeEnabled = menu.arnold_arcadeMeleeEnabled;
  c.arcadeMeleeStrength = RFC_ClampF(menu.arnold_arcadeMeleeStrength, 0.0, 80.0);
  c.arcadeMeleeUp = RFC_ClampF(menu.arnold_arcadeMeleeUp, 0.0, 20.0);
  c.arcadeMeleeDown = RFC_ClampF(menu.arnold_arcadeMeleeDown, 0.0, 20.0);
  c.arcadeMeleeRadius = RFC_ClampF(menu.arnold_arcadeMeleeRadius, 0.05, 5.0);
  c.arcadeBulletCooldown = RFC_ClampF(menu.arnold_arcadeBulletCooldown, 0.0, 2.0);
  c.arcadeImpulseDelay = RFC_ClampF(menu.arnold_arcadeImpulseDelay, 0.0, 0.50);
  c.arcadeCowScale = RFC_ClampF(menu.arnold_arcadeCowScale, 0.0, 3.0);
  c.arcadeAllowHandgun = menu.arnold_arcadeAllowHandgun;
  c.arcadeAllowMagnum = menu.arnold_arcadeAllowMagnum;
  c.arcadeAllowShotgun = menu.arnold_arcadeAllowShotgun;
  c.arcadeAllowSniper = menu.arnold_arcadeAllowSniper;
  c.arcadeAllowSMG = menu.arnold_arcadeAllowSMG;
  c.arcadeAllowAR = menu.arnold_arcadeAllowAR;
  c.arcadeAllowLMG = menu.arnold_arcadeAllowLMG;
  c.arcadeAllowBlunt = menu.arnold_arcadeAllowBlunt;
  c.arcadeAllowBlade = menu.arnold_arcadeAllowBlade;
  c.arcadeMulHandgun = RFC_ClampF(menu.arnold_arcadeMulHandgun, 0.0, 5.0);
  c.arcadeMulMagnum = RFC_ClampF(menu.arnold_arcadeMulMagnum, 0.0, 5.0);
  c.arcadeMulShotgun = RFC_ClampF(menu.arnold_arcadeMulShotgun, 0.0, 5.0);
  c.arcadeMulSniper = RFC_ClampF(menu.arnold_arcadeMulSniper, 0.0, 5.0);
  c.arcadeMulSMG = RFC_ClampF(menu.arnold_arcadeMulSMG, 0.0, 5.0);
  c.arcadeMulAR = RFC_ClampF(menu.arnold_arcadeMulAR, 0.0, 5.0);
  c.arcadeMulLMG = RFC_ClampF(menu.arnold_arcadeMulLMG, 0.0, 5.0);
  c.arcadeMulBlunt = RFC_ClampF(menu.arnold_arcadeMulBlunt, 0.0, 5.0);
  c.arcadeMulBlade = RFC_ClampF(menu.arnold_arcadeMulBlade, 0.0, 5.0);

  c.vanillaImpulsesEnabled = menu.arnold_vanillaImpulsesEnabled;
  c.vanillaAllowHandgun = menu.arnold_vanillaAllowHandgun;
  c.vanillaAllowMagnum = menu.arnold_vanillaAllowMagnum;
  c.vanillaAllowShotgun = menu.arnold_vanillaAllowShotgun;
  c.vanillaAllowSniper = menu.arnold_vanillaAllowSniper;
  c.vanillaAllowSMG = menu.arnold_vanillaAllowSMG;
  c.vanillaAllowAR = menu.arnold_vanillaAllowAR;
  c.vanillaAllowLMG = menu.arnold_vanillaAllowLMG;
  c.vanillaAllowBlunt = menu.arnold_vanillaAllowBlunt;
  c.vanillaAllowBlade = menu.arnold_vanillaAllowBlade;

  c.grenadeEnabled = menu.arnold_grenadeEnabled;
  c.explPlayerOnly = menu.arnold_explPlayerOnly;
  c.explAffectGrenades = menu.arnold_explAffectGrenades;
  c.explAffectWeapon = menu.arnold_explAffectWeapon;
  c.explAffectBullet = menu.arnold_explAffectBullet;
  c.explAffectVehicle = menu.arnold_explAffectVehicle;
  c.grenadeKickRadius = RFC_ClampF(menu.arnold_grenadeKickRadius, 0.0, 10.0);
  c.grenadeKickX = RFC_ClampF(menu.arnold_grenadeKickX, 0.0, 40.0);
  c.grenadeKickY = RFC_ClampF(menu.arnold_grenadeKickY, 0.0, 40.0);
  c.grenadeKickZ = RFC_ClampF(menu.arnold_grenadeKickZ, 0.0, 40.0)
    - RFC_ClampF(menu.arnold_grenadeKickDown, 0.0, 40.0);
  c.grenadeKickCallDelay = RFC_ClampF(menu.arnold_grenadeKickCallDelay, 0.0, 10.0);
  c.explMulGrenades = RFC_ClampF(menu.arnold_explMulGrenades, 0.0, 10.0);
  c.explMulWeapon = RFC_ClampF(menu.arnold_explMulWeapon, 0.0, 10.0);
  c.explMulBullet = RFC_ClampF(menu.arnold_explMulBullet, 0.0, 10.0);
  c.explMulVehicle = RFC_ClampF(menu.arnold_explMulVehicle, 0.0, 50.0);

  c.tumbleEnabled = menu.arnold_tumbleEnabled;
  c.directionalTumbleEnabled = menu.arnold_directionalTumbleEnabled;
  c.overrideTumbleStairs = menu.arnold_overrideTumbleStairs;
  if c.overrideTumbleStairs {
    c.tumbleStairs_down = 0.0 - AbsF(menu.arnold_tumbleStairs_down);
    c.tumbleStairs_fwd = menu.arnold_tumbleStairs_fwd;
    c.tumbleStairs_side = menu.arnold_tumbleStairs_side;
    c.tumbleStairs_radius = RFC_ClampF(menu.arnold_tumbleStairs_radius, 0.05, 10.0);
    c.tumbleStairs_steps = RFC_ClampI(menu.arnold_tumbleStairs_steps, 1, 100);
    c.tumbleStairs_stepDelay = RFC_ClampF(menu.arnold_tumbleStairs_stepDelay, 0.0, 30.0);
  }
  c.overrideTumbleDirectional = menu.arnold_overrideTumbleDirectional;
  if c.overrideTumbleDirectional {
    c.tumbleDir_down = 0.0 - AbsF(menu.arnold_tumbleDir_down);
    c.tumbleDir_fwd = menu.arnold_tumbleDir_fwd;
    c.tumbleDir_side = menu.arnold_tumbleDir_side;
    c.tumbleDir_radius = RFC_ClampF(menu.arnold_tumbleDir_radius, 0.05, 10.0);
    c.tumbleDir_steps = RFC_ClampI(menu.arnold_tumbleDir_steps, 1, 100);
    c.tumbleDir_stepDelay = RFC_ClampF(menu.arnold_tumbleDir_stepDelay, 0.0, 30.0);
  }

  c.settleEnabled = menu.arnold_settleEnabled;
  c.settleStrength = RFC_ClampF(menu.arnold_settleStrength, 0.0, 20.0);

  // Named modes now use Hit Jolts / Bullet Jolts instead.
  c.bulletJoltsEnabled = menu.arnold_bulletJoltsEnabled;
  c.bulletJoltStrengthScale = RFC_ClampF(menu.arnold_bulletJoltStrengthScale, 0.0, 10.0);
  c.bulletJoltRadiusScale = RFC_ClampF(menu.arnold_bulletJoltRadiusScale, 0.1, 5.0);
  c.bulletJoltDelayScale = RFC_ClampF(menu.arnold_bulletJoltDelayScale, 0.0, 5.0);
  c.bulletJoltWaitForGround = menu.arnold_bulletJoltWaitForGround;
  c.bulletJoltGroundWaitMax = RFC_ClampF(menu.arnold_bulletJoltGroundWaitMax, 0.1, 5.0);
  c.bulletJoltAllowAirborne = menu.arnold_bulletJoltAllowAirborne;
  c.twitchEnabled = menu.arnold_twitchEnabled;
  c.twitchForce = RFC_ClampF(menu.arnold_twitchForce, 0.0, 200.0);
  c.headReboundKneeNearPct = RFC_ClampF(menu.arnold_headReboundKneeNearPct, 0.0, 100.0);
}

// These controls intentionally use the same field names in every scoped mode
// object. Named-mode branches select their own Enable/Strength fields above,
// while these advanced timing/shape values come from the selected scope.
c.overrideSettle = menu.overrideSettle;
if c.overrideSettle {
  c.settleDelay = RFC_ClampF(menu.settleDelay, 0.0, 30.0);
  c.settleFwd = RFC_ClampF(menu.settleFwd, -50.0, 50.0);
  c.settleDown = RFC_ClampF(menu.settleDown, -50.0, 50.0);
  c.settleRadius = RFC_ClampF(menu.settleRadius, 0.01, 10.0);
}

c.overrideTwitch = menu.overrideTwitch;
if c.overrideTwitch {
  c.twitchChance = RFC_ClampF(menu.twitchChance, 0.0, 1.0);
  c.twitchDelayStart = RFC_ClampF(menu.twitchDelayStart, 0.0, 30.0);
  c.twitchDuration = RFC_ClampF(menu.twitchDuration, 0.0, 60.0);
}

// Vehicle impulses use the actual Bullet, Explosion, and Melee channel toggles.
// The old extra master switch duplicated the Bullet toggle in the menu and could
// silently block a channel even when its own switch was enabled.
c.vehicleImpulseEnabled = c.vehicleBulletEnabled || c.vehicleExplosionEnabled || c.vehicleMeleeEnabled;

// The selected mode's Enable Injury Shock toggle is authoritative. Keep the
// chance at zero when disabled so no caller can accidentally schedule it.
if !c.injuryShockEnabled {
  c.injuryShockChance = 0.0;
}



// Final NPC Arcade channel enforcement. These are runtime-only zeros: the
// saved slider values are preserved and return when the toggle is enabled.
// Vehicle Bullet Push is deliberately not coupled to this NPC toggle.
if !c.arcadeBulletsEnabled {
  c.arcadeBulletStrength = 0.0;
  c.arcadeBulletUp = 0.0;
  c.arcadeBulletDown = 0.0;
}
if !c.arcadeMeleeEnabled {
  c.arcadeMeleeStrength = 0.0;
  c.arcadeMeleeUp = 0.0;
  c.arcadeMeleeDown = 0.0;
}

// The delayed live hit-reaction cutoff is not reliable. Keep the working
// complete-disable option, but do not run the broken timed path.
c.hitReactionCutoffEnabled = false;

// VANILLA = RAGDOLL RIG ONLY.
// This runs after every named-mode branch so Vanilla always wins over saved
// SPLAT settings. Every script-side feature is disabled. Installed ragdoll rig
// assets are intentionally untouched and are the sole SPLAT exception.
if c.vanillaMode {
  // Feature values remain OFF as a redundant safety net. OnHit/OnDeath and all
  // major wrappers still hard-pass directly to the base game before using them.
  c.skipDeathAnim = false;
  c.deathAnimChance = 1.0;
  c.animCompatDelay = 0.0;
  c.killMotorcycleDeathAnim = false;
  c.masterDeathChanceEnabled = false;
  c.masterDeathChance = 1.0;
  c.stealthRagdollsEnabled = false;
  c.vanillaImpulsesEnabled = false;

  c.standEnabled = false;
  c.runEnabled = false;
  c.cowerEnabled = false;
  c.stairsEnabled = false;
  c.wsStandEnabled = false;
  c.walkEnabled = false;
  c.shoulderHipFallsEnabled = false;
  c.shoulderHipEarlyFallEnabled = false;
  c.shoulderHipImpactFallEnabled = false;

  c.settleEnabled = false;
  c.tumbleEnabled = false;
  c.directionalTumbleEnabled = false;
  c.twitchEnabled = false;
  c.bulletJoltsEnabled = false;
  c.grenadeEnabled = false;

  c.arcadeBulletsEnabled = false;
  c.arcadeOnHitEnabled = false;
  c.arcadeOnDeathEnabled = false;
  c.arcadeIncapRagdollEnabled = false;
  c.hitReactionsDisabled = false;
  c.injuryShockEnabled = false;
  c.injuryShockChance = 0.0;

  c.explAffectGrenades = false;
  c.explAffectWeapon = false;
  c.explAffectBullet = false;
  c.explAffectVehicle = false;

  c.vehicleImpulseEnabled = false;
  c.vehicleBulletEnabled = false;
  c.vehicleMotorcycleToppleOnBullet = false;
  c.playerMotorcycleLeanToppleEnabled = false;
  c.vehicleExplosionEnabled = false;
  c.vehicleMeleeEnabled = false;

  c.vehicleOccupantShieldEnabled = false;
  c.vehicleMountedHitImmunity = false;
  c.vehicleOccupantShieldTime = 0.0;
  c.vehicleExitShieldEnabled = false;
  c.vehicleExitShieldTime = 0.0;

  c.popFixEnabled = false;
  c.popFix_useGate = false;
  c.popFix_overrideWorkspot = false;
  c.popFix_overrideVehicle = false;
  c.popFix_overrideStagger = false;
  c.popFix_staggerSnap = false;
  c.popFix_workspotPreemptExit = false;
  c.popFix_vehicleKillExitAnim = false;
  c.popFix_bikeKillExitAnim = false;

  c.killImpulsesVehiclesOnly = false;
  c.killImpulsesEverywhere = false;
}

// v16 precedence rule:
// Mode branches above are true overrides of matching Realism Custom values.
// Realism Custom uses its optional weapon allow-list switch. Named modes enforce
// their own preset weapon lists. Neither path silently changes the master toggle.

return c;
  }
}
