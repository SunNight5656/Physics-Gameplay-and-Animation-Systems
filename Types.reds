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
  public let chestDown: Float;
  public let chestRadius: Float;
  public let chestDelay: Float;

  public let pelvisFwd: Float;
  public let pelvisDown: Float;
  public let pelvisRadius: Float;
  public let pelvisDelay: Float;

  public let kneeDown: Float;
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
  public let headRadius: Float;
  public let headDelay: Float;

  public let chestDown: Float;
  public let chestRadius: Float;
  public let chestDelay: Float;

  public let pelvisDown: Float;
  public let pelvisRadius: Float;
  public let pelvisDelay: Float;

  public let kneeDown: Float;
  public let kneeDelay: Float;
  public let kneeRadius: Float;

  public let shinDown: Float;
  public let shinRadius: Float;
  public let shinDelay: Float;

  public let settleDown: Float;
  public let settleRadius: Float;
  public let settleDelay: Float;

  public let antiTuckZ: Float;
  public let antiTuckRadius: Float;
  public let antiTuckDelay: Float;
}

// Master runtime config
public struct RFCConfig {
  public let skipDeathAnim: Bool;
  public let animCompatDelay: Float;
  public let vanillaMode: Bool;
  public let respectCinematics: Bool;
  public let stealthRagdollsEnabled: Bool;   // master toggle
  public let stealthRagdollDelay: Float;     // seconds after stealth/finisher
  public let blackwallCountsAsStealth: Bool; // treat Blackwall-tag effects as stealth
  public let deathAnimChance: Float;         // 0.0 to 1.0

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
  public let arcadeBulletUp: Float;       // vertical lift
  public let arcadeBulletRadius: Float;   // radius for impulse
  public let arcadeOnHitEnabled: Bool;
  public let arcadeOnDeathEnabled: Bool;

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

  public let st_overrideGlobalForward: Bool;
  public let st_overrideGlobalChest: Bool;
  public let st_overrideGlobalKnees: Bool;

  public let run_overrideGlobalForward: Bool;
  public let run_overrideGlobalChest: Bool;
  public let run_overrideGlobalKnees: Bool;

  public let cow_overrideGlobalForward: Bool;
  public let cow_overrideGlobalChest: Bool;
  public let cow_overrideGlobalKnees: Bool;

  public let stair_overrideGlobalForward: Bool;
  public let stair_overrideGlobalChest: Bool;
  public let stair_overrideGlobalKnees: Bool;

  public let wsStand_overrideGlobalForward: Bool;
  public let wsStand_overrideGlobalChest: Bool;
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

  public let corpseKickEnabled: Bool;

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

  public let bulletKickCallDelay: Float;
  public let bulletKickRadius: Float;
  public let bulletKickZ: Float;
  public let bulletKickStartDelay: Float;
  public let bulletKickDelay: Float;

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
  public let stair_downHead: Float;
  public let stair_downChest: Float;
  public let stair_downPelvis: Float;
  public let stair_vSlamZ: Float;

  public let stair_kneeDown: Float;
  public let stair_kneeDelay: Float;
  public let stair_kneeRadius: Float;

  public let stair_brakeFwd: Float;
  public let stair_brakeDelay: Float;
  public let stair_brakeRadius: Float;

  public let stair_headFwd: Float;
  public let stair_chestFwd: Float;

  public let stair_plankEnabled: Bool;
  public let stair_plankHeadDown: Float;
  public let stair_plankChestDown: Float;
  public let stair_plankPelvisDown: Float;
  public let stair_plankFwd: Float;
  public let stair_plankRadius: Float;
  public let stair_plankDelay: Float;
  public let stair_plankBrakeFwd: Float;
  public let stair_plankBrakeDelay: Float;
  public let stair_plankBrakeRadius: Float;

  public let stair_runUseKnees: Bool;
  public let stair_runFeetDown: Float;
  public let stair_runFeetDelay: Float;
  public let stair_runFeetRadius: Float;

  public let st_forward: Float;
  public let st_downHead: Float;
  public let st_downChest: Float;
  public let st_downPelvis: Float;
  public let st_kneeDown: Float;
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
  public let run_downHead: Float;
  public let run_downChest: Float;
  public let run_downPelvis: Float;
  public let run_kneeDown: Float;
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
    let menu: ref<RFCModSettings> = new RFCModSettings();

    // Core toggles
    c.vanillaMode = menu.vanillaMode;
    c.respectCinematics = menu.respectCinematics;
    c.skipDeathAnim = menu.skipDeathAnim;
    c.animCompatDelay = menu.animCompatDelay;

    c.arcadePlayerOnly = menu.arcadePlayerOnly;
    c.explPlayerOnly = menu.explPlayerOnly;

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

    // Bullet corpse bloom defaults
    c.corpseKickEnabled = menu.corpseKickEnabled;
    c.bulletKickRadius = 0.0;
    c.bulletKickZ = 0.0;
    c.bulletKickStartDelay = 0.0;
    c.bulletKickDelay = 0.0;
    c.bulletKickCallDelay = 0.0;

    // Grenade defaults
    c.grenadeKickRadius = 1.2;
    c.grenadeKickX = 2.0;
    c.grenadeKickY = 2.0;
    c.grenadeKickZ = 2.2;
    c.grenadeKickCallDelay = 0.0;

    c.grenadeEnabled = false;

    // Twitch defaults
    c.twitchEnabled = true;
    c.twitchChance = 0.4;
    c.twitchStrengthMin = 0.8;
    c.twitchStrengthMax = 1.2;
    c.twitchDelayStart = 3.2;
    c.twitchDelayStepMin = 0.25;
    c.twitchDelayStepMax = 0.55;
    c.twitchDuration = 20.5;
    c.twitchForce = 1.54;

    // Arcade bullet defaults
    c.arcadeBulletsEnabled = false;
    c.arcadeBulletStrength = 8.0;
    c.arcadeBulletUp = 2.5;
    c.arcadeBulletRadius = 0.25;

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
      c.arcadeBulletRadius = menu.arcadeBulletRadius;
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

c.run_forward = 0.300000;
c.run_forwardDelay = 0.983000;

c.run_downHead = 0.000000;
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
  c.corpseKickEnabled = false;
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

  c.arcadeBulletsEnabled = false;
  c.arcadeBulletStrength = 0.0;
  c.arcadeBulletUp = 0.0;

  c.popFixEnabled = false;
  c.popFix_useGate = false;

  c.popFix_overrideWorkspot = false;
  c.popFix_overrideVehicle = false;
  c.popFix_overrideStagger = false;

  c.popFix_staggerSnap = false;
  c.popFix_workspotPreemptExit = false;

  c.popFix_vehicleKillExitAnim = false;
  c.popFix_bikeKillExitAnim = false;

  return c;
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
// c.panicTripEnabled = menu.panicTripEnabled;

c.corpseKickEnabled = menu.corpseKickEnabled;
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
c.arcadeBulletRadius = menu.arcadeBulletRadius;

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
c.arcadeBulletCooldown = menu.arcadeBulletCooldown;
c.arcadeImpulseDelay = menu.arcadeImpulseDelay;
c.arcadeCowScale = menu.arcadeCowScale;

// Safety clamp – don’t let sliders go insane
if c.arcadeBulletStrength < 0.0 {
  c.arcadeBulletStrength = 0.0;
}
if c.arcadeBulletStrength > 80.0 {
  c.arcadeBulletStrength = 80.0;
}

if c.arcadeBulletUp < -10.0 {
  c.arcadeBulletUp = -10.0;
}
if c.arcadeBulletUp > 20.0 {
  c.arcadeBulletUp = 20.0;
}

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
c.overrideStand = menu.overrideStand;
c.overrideRun = menu.overrideRun;
c.overrideCower = menu.overrideCower;
c.overrideStairs = menu.overrideStairs;
c.overrideWsStand = menu.overrideWorkSpots;
c.overrideBulletImpulse = menu.overrideBulletImpulse;
c.overrideSettle = menu.overrideSettle;
c.overrideTwitch = menu.overrideTwitch;
c.overrideGrenade = menu.overrideGrenade;

// c.overridePanicTrip = menu.overridePanicTrip;
c.overrideWalk = false;

c.st_overrideGlobalForward = menu.st_overrideGlobalForward;
c.st_overrideGlobalChest = menu.st_overrideGlobalChest;
c.st_overrideGlobalKnees = menu.st_overrideGlobalKnees;

c.run_overrideGlobalForward = menu.run_overrideGlobalForward;
c.run_overrideGlobalChest = menu.run_overrideGlobalChest;
c.run_overrideGlobalKnees = menu.run_overrideGlobalKnees;

c.cow_overrideGlobalForward = menu.cow_overrideGlobalForward;
c.cow_overrideGlobalChest = menu.cow_overrideGlobalChest;
c.cow_overrideGlobalKnees = menu.cow_overrideGlobalKnees;

c.stair_overrideGlobalForward = menu.stair_overrideGlobalForward;
c.stair_overrideGlobalChest = menu.stair_overrideGlobalChest;
c.stair_overrideGlobalKnees = menu.stair_overrideGlobalKnees;

c.wsStand_overrideGlobalForward = menu.wsStand_overrideGlobalForward;
c.wsStand_overrideGlobalChest = menu.wsStand_overrideGlobalChest;
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
c.explMulVehicle = MaxF(0.0, menu.explMulVehicle);

// Overrides toggles
c.overrideGrenade = menu.overrideGrenade;

// Base grenade sliders only belong in overrideGrenade
if menu.overrideGrenade {
  c.grenadeKickRadius = menu.grenadeKickRadius;
  c.grenadeKickX = menu.grenadeKickX;
  c.grenadeKickY = menu.grenadeKickY;
  c.grenadeKickZ = menu.grenadeKickZ;
  c.grenadeKickCallDelay = menu.grenadeKickCallDelay;
}

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

// Bullet bloom override
if menu.overrideBulletImpulse {
  c.bulletKickCallDelay = menu.bulletKickCallDelay;
  c.bulletKickRadius = menu.bulletKickRadius;
  c.bulletKickZ = menu.bulletKickZ;
  c.bulletKickStartDelay = menu.bulletKickStartDelay;
  c.bulletKickDelay = menu.bulletKickDelay;
}

if !c.corpseKickEnabled {
  c.bulletKickRadius = 0.0;
}

if c.arcadeBulletsEnabled {
  if !c.arcadeAllowBlunt
    && !c.arcadeAllowBlade
    && !c.arcadeAllowShotgun
    && !c.arcadeAllowSniper
    && !c.arcadeAllowHandgun
    && !c.arcadeAllowMagnum
    && !c.arcadeAllowSMG
    && !c.arcadeAllowAR
    && !c.arcadeAllowLMG {
    c.arcadeBulletsEnabled = false;
  }
}

// STAND OVERRIDE  (10) Standing
if menu.overrideStand {
  c.standEnabled = menu.standEnabled;

  // global
  c.st_forward = menu.st_forward;
  c.st_forwardDelay = menu.st_forwardDelay;

  // head
  c.st_downHead = 0.0 - AbsF(menu.st_downHead);
  c.st_d_headBias = menu.st_d_headBias;
  c.st_d_headSlam = menu.st_d_headSlam;
  c.st_d_headSnap = menu.st_d_headSnap;

  // chest
  c.st_downChest = 0.0 - AbsF(menu.st_downChest);
  c.st_d_chestFall = menu.st_d_chestFall;

  // pelvis
  c.st_downPelvis = 0.0 - AbsF(menu.st_downPelvis);
  c.st_d_pelvisFall = menu.st_d_pelvisFall;

  // knees
  c.st_kneeDown = 0.0 - AbsF(menu.st_kneeDown);
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
if menu.overrideRun {
  c.runEnabled = menu.runEnabled;

  // global
  c.run_forward = menu.run_forward;
  c.run_forwardDelay = menu.run_forwardDelay;

  // head
  c.run_downHead = 0.0 - AbsF(menu.run_downHead);
  c.run_d_headBias = menu.run_d_headBias;
  c.run_d_headSlam = menu.run_d_headSlam;

  // chest
  c.run_downChest = 0.0 - AbsF(menu.run_downChest);
  c.run_d_chestFall = menu.run_d_chestFall;

  // pelvis
  c.run_downPelvis = 0.0 - AbsF(menu.run_downPelvis);
  c.run_d_pelvisFall = menu.run_d_pelvisFall;

  // knees
  c.run_kneeDown = 0.0 - AbsF(menu.run_kneeDown);
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
  c.run_anchorFwd = menu.run_anchorFwd;
  c.run_anchorDown = 0.0 - AbsF(menu.run_anchorDown);
  c.run_anchorRadius = menu.run_anchorRadius;
}

// STAIRS OVERRIDE  (13) Stairs
if menu.overrideStairs {
  c.stairsEnabled = menu.stairsEnabled;

  // global / torso
  c.stair_forward = menu.stair_forward;
  c.stair_headFwd = menu.stair_headFwd;
  c.stair_downHead = 0.0 - AbsF(menu.stair_downHead);
  c.stair_chestFwd = menu.stair_chestFwd;
  c.stair_downChest = 0.0 - AbsF(menu.stair_downChest);
  c.stair_downPelvis = 0.0 - AbsF(menu.stair_downPelvis);

  // vSlam
  c.stair_vSlamZ = 0.0 - AbsF(menu.stair_vSlamZ);

  // knees
  c.stair_kneeDown = 0.0 - AbsF(menu.stair_kneeDown);
  c.stair_kneeDelay = menu.stair_kneeDelay;
  c.stair_kneeRadius = menu.stair_kneeRadius;

  // brake
  c.stair_brakeFwd = menu.stair_brakeFwd;
  c.stair_brakeDelay = menu.stair_brakeDelay;
  c.stair_brakeRadius = menu.stair_brakeRadius;

  // plank
  c.stair_plankEnabled = menu.stair_plankEnabled;
  c.stair_plankHeadDown = 0.0 - AbsF(menu.stair_plankDownHead);
  c.stair_plankChestDown = 0.0 - AbsF(menu.stair_plankDownChest);
  c.stair_plankPelvisDown = 0.0 - AbsF(menu.stair_plankDownPelvis);
  c.stair_plankFwd = menu.stair_plankFwd;
  c.stair_plankDelay = menu.stair_plankDelay;
  c.stair_plankRadius = menu.stair_plankRadius;
  c.stair_plankBrakeFwd = menu.stair_plankBrakeFwd;
  c.stair_plankBrakeDelay = menu.stair_plankBrakeDelay;
  c.stair_plankBrakeRadius = menu.stair_plankBrakeRadius;

  // run helpers
  c.stair_runUseKnees = menu.stair_runUseKnees;
  // c.stair_runFeetDown = 0.0 - AbsF(menu.stair_runFeetDown);
  // c.stair_runFeetDelay = menu.stair_runFeetDelay;
  // c.stair_runFeetRadius = menu.stair_runFeetRadius;
}

// COWER OVERRIDE  (12) Cower
if menu.overrideCower {
  c.cowerEnabled = menu.cowerEnabled;

  // head
  c.cow.headDown = 0.0 - AbsF(menu.cow_downHead);
  c.cow.headDelay = menu.cow_headDelay;
  c.cow.headRadius = menu.cow_headRadius;

  // chest
  c.cow.chestDown = 0.0 - AbsF(menu.cow_downChest);
  c.cow.chestDelay = menu.cow_chestDelay;
  c.cow.chestRadius = menu.cow_chestRadius;

  // pelvis
  c.cow.pelvisDown = 0.0 - AbsF(menu.cow_downPelvis);
  c.cow.pelvisDelay = menu.cow_pelvisDelay;
  c.cow.pelvisRadius = menu.cow_pelvisRadius;

  // knees
  c.cow.kneeDown = 0.0 - AbsF(menu.cow_kneeDown);
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
  c.cow.antiTuckDelay = menu.cow_antiTuckDelay;
  c.cow.antiTuckRadius = menu.cow_antiTuckRadius;
}

// Workspot Stand override 
if menu.overrideWorkSpots {
  c.wsStand.headFwd = menu.wsStand_headFwd;
  c.wsStand.headDown = 0.0 - AbsF(menu.wsStand_headDown);
  c.wsStand.headDelay = menu.wsStand_headDelay;
  c.wsStand.headRadius = menu.wsStand_headRadius;

  c.wsStand.chestFwd = menu.wsStand_chestFwd;
  c.wsStand.chestDown = 0.0 - AbsF(menu.wsStand_chestDown);
  c.wsStand.chestDelay = menu.wsStand_chestDelay;
  c.wsStand.chestRadius = menu.wsStand_chestRadius;

  c.wsStand.pelvisFwd = menu.wsStand_pelvisFwd;
  c.wsStand.pelvisDown = 0.0 - AbsF(menu.wsStand_pelvisDown);
  c.wsStand.pelvisDelay = menu.wsStand_pelvisDelay;
  c.wsStand.pelvisRadius = menu.wsStand_pelvisRadius;

  c.wsStand.kneeDown = 0.0 - AbsF(menu.wsStand_kneeDown);
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

return c;
  }
}