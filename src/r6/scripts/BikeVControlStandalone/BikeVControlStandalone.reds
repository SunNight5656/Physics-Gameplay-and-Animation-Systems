module BikeVControlStandalone1600

// Standalone motorcycle mode, impact, rider, V-control, lean-fall,
// and pickup-recovery system.
//
// No SPLAT dependency.
//
// Proven topple actuator:
//   KnockOverBikeEvent(forceKnockdown=true, applyDirectionalForce=false)
//   + signed motorcycle-local PhysicalImpulseEvent.
//
// V additions:
//   - Bullet, vehicle-impact, and wall-impact topples affect V while mounted.
//   - Excessive BikeTilt causes a lean fall.
//   - V is unmounted into a directionless ragdoll and receives only a
//     downward gravity impulse.
//   - Remounting/picking up a fallen bike runs the reverse control sequence:
//       Exit Park + target tilt 0 + air control ON + tilt control ON.
//   - Recovery uses generation tokens, so old delayed suppression pulses
//     cannot turn tilt/air control back off after V remounts.
//
// Zero-threshold impact behavior:
//   A vehicle or world impact threshold of 0.0 means any reported
//   VehicleBumpEvent qualifies, including a light touch.
//
// Build marker:
// BVC1604_SYMMETRIC_TOUCH_KNOCKOFF

public class BVCModeConfig {
  public let enabled: Bool;

  public let bulletEnabled: Bool;
  public let bulletPlayerOnly: Bool;
  public let bulletHitsRequired: Float;
  public let bulletChance: Float;
  public let bulletStrength: Float;

  public let vehicleImpactEnabled: Bool;
  public let vehicleImpactThreshold: Float;
  public let vehicleImpactChance: Float;
  public let vehicleImpactStrength: Float;

  public let worldImpactEnabled: Bool;
  public let worldImpactThreshold: Float;
  public let worldImpactChance: Float;
  public let worldImpactStrength: Float;

  public let riderKnockoffEnabled: Bool;
  // ON keeps the current BVC behavior for a rider killed while mounted:
  // skip the mounted death animation and immediately hand the dead NPC to ragdoll.
  // OFF leaves a dead NPC rider in the native motorcycle death-animation path.
  public let killMotorcycleDeathAnimation: Bool;
  public let impactDirectionFlip: Bool;
  public let toppleCooldown: Float;

  public let leanFallEnabled: Bool;
  public let leanFallAngle: Float;
  public let leanFallMinSpeed: Float;
  public let leanFallMaxSpeed: Float;
  public let leanFallBikeStrength: Float;

  public let playerGravityFallStrength: Float;
  public let pickupRecoveryEnabled: Bool;
}

public class BVCState {
  public let activeMode: Int32;
  public let debugPopups: Bool;
  public let manualControllerEnabled: Bool;
  public let modes: array<ref<BVCModeConfig>>;
}

public class BVCSuppressEvent extends Event {
  public let generation: Int32;
}

public class BVCRecoveryEvent extends Event {
  public let generation: Int32;
  public let finalPulse: Bool;
}

public class BVCPlayerMonitorEvent extends Event {}

@addField(PlayerPuppet)
private let bvc_state: ref<BVCState>;

@addField(PlayerPuppet)
private let bvc_inputsRegistered: Bool;

@addField(PlayerPuppet)
private let bvc_manualSide: Int32;

@addField(PlayerPuppet)
private let bvc_nextDirectionInputTime: Float;

@addField(PlayerPuppet)
private let bvc_nextManualToppleTime: Float;

@addField(PlayerPuppet)
private let bvc_markerShown: Bool;

@addField(PlayerPuppet)
private let bvc_monitorScheduled: Bool;

@addField(PlayerPuppet)
private let bvc_lastMountedBike: wref<BikeObject>;

@addField(BikeObject)
public let bvc_controlGeneration: Int32;

@addField(BikeObject)
public let bvc_recoveryActive: Bool;

@addField(BikeObject)
public let bvc_needsPickupRecovery: Bool;

@addField(BikeObject)
public let bvc_recoveryNotBefore: Float;

@addField(BikeObject)
public let bvc_riderMountedAtTopple: Bool;

@addField(BikeObject)
public let bvc_seenUnmountAfterTopple: Bool;

@addField(BikeObject)
public let bvc_suppressAfterReceiver: Bool;

@addField(BikeObject)
public let bvc_lastToppleTime: Float;

@addField(BikeObject)
public let bvc_bulletHitCount: Float;

@addField(BikeObject)
public let bvc_leanLatched: Bool;

public func BVCNow(owner: wref<GameObject>) -> Float {
  if !IsDefined(owner) {
    return 0.00;
  };

  return EngineTime.ToFloat(
    GameInstance.GetSimTime(owner.GetGame())
  );
}

public func BVCClampFloat(
  value: Float,
  low: Float,
  high: Float
) -> Float {
  if value < low {
    return low;
  };

  if value > high {
    return high;
  };

  return value;
}

public func BVCModeName(mode: Int32) -> String {
  if mode == 0 {
    return "REALISM CUSTOM";
  };

  if mode == 1 {
    return "REALISM PLUS";
  };

  if mode == 2 {
    return "CLINT EASTWOOD OLD WEST";
  };

  if mode == 3 {
    return "ARNOLD / ARCADE";
  };

  return "VANILLA";
}

public func BVCSideName(side: Float) -> String {
  if side < 0.00 {
    return "LEFT";
  };

  return "RIGHT";
}

public func BVCCreateMode(mode: Int32) -> ref<BVCModeConfig> {
  let config: ref<BVCModeConfig> = new BVCModeConfig();

  if mode == 0 {
    config.enabled = true;

    config.bulletEnabled = true;
    config.bulletPlayerOnly = false;
    config.bulletHitsRequired = 3.00;
    config.bulletChance = 100.00;
    config.bulletStrength = 3.80;

    config.vehicleImpactEnabled = true;
    config.vehicleImpactThreshold = 2.00;
    config.vehicleImpactChance = 100.00;
    config.vehicleImpactStrength = 4.00;

    config.worldImpactEnabled = true;
    config.worldImpactThreshold = 4.50;
    config.worldImpactChance = 100.00;
    config.worldImpactStrength = 4.00;

    config.riderKnockoffEnabled = true;
    config.killMotorcycleDeathAnimation = true;
    config.impactDirectionFlip = false;
    config.toppleCooldown = 0.35;

    config.leanFallEnabled = true;
    config.leanFallAngle = 38.00;
    config.leanFallMinSpeed = 0.00;
    config.leanFallMaxSpeed = 100.00;
    config.leanFallBikeStrength = 3.80;

    config.playerGravityFallStrength = 8.00;
    config.pickupRecoveryEnabled = true;
    return config;
  };

  if mode == 1 {
    config.enabled = true;

    config.bulletEnabled = true;
    config.bulletPlayerOnly = false;
    config.bulletHitsRequired = 3.00;
    config.bulletChance = 100.00;
    config.bulletStrength = 4.20;

    config.vehicleImpactEnabled = true;
    config.vehicleImpactThreshold = 1.75;
    config.vehicleImpactChance = 100.00;
    config.vehicleImpactStrength = 4.60;

    config.worldImpactEnabled = true;
    config.worldImpactThreshold = 4.00;
    config.worldImpactChance = 100.00;
    config.worldImpactStrength = 4.60;

    config.riderKnockoffEnabled = true;
    config.killMotorcycleDeathAnimation = true;
    config.impactDirectionFlip = false;
    config.toppleCooldown = 0.30;

    config.leanFallEnabled = true;
    config.leanFallAngle = 34.00;
    config.leanFallMinSpeed = 0.00;
    config.leanFallMaxSpeed = 100.00;
    config.leanFallBikeStrength = 4.20;

    config.playerGravityFallStrength = 8.00;
    config.pickupRecoveryEnabled = true;
    return config;
  };

  if mode == 2 {
    config.enabled = true;

    config.bulletEnabled = true;
    config.bulletPlayerOnly = false;
    config.bulletHitsRequired = 3.00;
    config.bulletChance = 100.00;
    config.bulletStrength = 4.80;

    config.vehicleImpactEnabled = true;
    config.vehicleImpactThreshold = 1.25;
    config.vehicleImpactChance = 100.00;
    config.vehicleImpactStrength = 5.20;

    config.worldImpactEnabled = true;
    config.worldImpactThreshold = 3.25;
    config.worldImpactChance = 100.00;
    config.worldImpactStrength = 5.00;

    config.riderKnockoffEnabled = true;
    config.killMotorcycleDeathAnimation = true;
    config.impactDirectionFlip = false;
    config.toppleCooldown = 0.25;

    config.leanFallEnabled = true;
    config.leanFallAngle = 30.00;
    config.leanFallMinSpeed = 0.00;
    config.leanFallMaxSpeed = 100.00;
    config.leanFallBikeStrength = 4.80;

    config.playerGravityFallStrength = 8.50;
    config.pickupRecoveryEnabled = true;
    return config;
  };

  if mode == 3 {
    config.enabled = true;

    config.bulletEnabled = true;
    config.bulletPlayerOnly = false;
    config.bulletHitsRequired = 3.00;
    config.bulletChance = 100.00;
    config.bulletStrength = 6.50;

    config.vehicleImpactEnabled = true;
    config.vehicleImpactThreshold = 0.75;
    config.vehicleImpactChance = 100.00;
    config.vehicleImpactStrength = 7.00;

    config.worldImpactEnabled = true;
    config.worldImpactThreshold = 2.00;
    config.worldImpactChance = 100.00;
    config.worldImpactStrength = 7.00;

    config.riderKnockoffEnabled = true;
    config.killMotorcycleDeathAnimation = true;
    config.impactDirectionFlip = false;
    config.toppleCooldown = 0.20;

    config.leanFallEnabled = true;
    config.leanFallAngle = 24.00;
    config.leanFallMinSpeed = 0.00;
    config.leanFallMaxSpeed = 100.00;
    config.leanFallBikeStrength = 6.50;

    config.playerGravityFallStrength = 9.00;
    config.pickupRecoveryEnabled = true;
    return config;
  };

  config.enabled = false;

  config.bulletEnabled = false;
  config.bulletPlayerOnly = false;
  config.bulletHitsRequired = 3.00;
  config.bulletChance = 0.00;
  config.bulletStrength = 0.00;

  config.vehicleImpactEnabled = false;
  config.vehicleImpactThreshold = 9999.00;
  config.vehicleImpactChance = 0.00;
  config.vehicleImpactStrength = 0.00;

  config.worldImpactEnabled = false;
  config.worldImpactThreshold = 9999.00;
  config.worldImpactChance = 0.00;
  config.worldImpactStrength = 0.00;

  config.riderKnockoffEnabled = false;
  config.killMotorcycleDeathAnimation = false;
  config.impactDirectionFlip = false;
  config.toppleCooldown = 0.35;

  config.leanFallEnabled = false;
  config.leanFallAngle = 90.00;
  config.leanFallMinSpeed = 0.00;
  config.leanFallMaxSpeed = 0.00;
  config.leanFallBikeStrength = 0.00;

  config.playerGravityFallStrength = 0.00;
  config.pickupRecoveryEnabled = false;
  return config;
}

@addMethod(PlayerPuppet)
public final func BVCEnsureState() -> ref<BVCState> {
  let state: ref<BVCState>;
  let mode: Int32;

  if IsDefined(this.bvc_state) {
    return this.bvc_state;
  };

  state = new BVCState();
  state.activeMode = 0;
  state.debugPopups = true;
  state.manualControllerEnabled = true;

  mode = 0;
  while mode < 5 {
    ArrayPush(state.modes, BVCCreateMode(mode));
    mode += 1;
  };

  this.bvc_state = state;
  return this.bvc_state;
}

@addMethod(PlayerPuppet)
public final func BVCGetBridgeVersion() -> Int32 {
  return 1605;
}

@addMethod(PlayerPuppet)
public final func BVCSetActiveMode(mode: Int32) -> Bool {
  let state: ref<BVCState> = this.BVCEnsureState();

  if mode < 0 {
    mode = 0;
  };

  if mode > 4 {
    mode = 4;
  };

  state.activeMode = mode;

  BVCNotify(
    this,
    "BIKE MODE: " + BVCModeName(mode)
  );

  return true;
}

@addMethod(PlayerPuppet)
public final func BVCSetGlobalBool(
  name: CName,
  value: Bool
) -> Bool {
  let state: ref<BVCState> = this.BVCEnsureState();

  if Equals(name, n"debugPopups") {
    state.debugPopups = value;
    return true;
  };

  if Equals(name, n"manualControllerEnabled") {
    state.manualControllerEnabled = value;
    return true;
  };

  return false;
}

@addMethod(PlayerPuppet)
public final func BVCGetModeConfig(
  mode: Int32
) -> ref<BVCModeConfig> {
  let state: ref<BVCState> = this.BVCEnsureState();

  if mode < 0 || mode >= ArraySize(state.modes) {
    return null;
  };

  return state.modes[mode];
}

@addMethod(PlayerPuppet)
public final func BVCSetModeBool(
  mode: Int32,
  name: CName,
  value: Bool
) -> Bool {
  let config: ref<BVCModeConfig> =
    this.BVCGetModeConfig(mode);

  if !IsDefined(config) {
    return false;
  };

  if Equals(name, n"enabled") {
    config.enabled = value;
    return true;
  };

  if Equals(name, n"bulletEnabled") {
    config.bulletEnabled = value;
    return true;
  };

  if Equals(name, n"bulletPlayerOnly") {
    config.bulletPlayerOnly = value;
    return true;
  };

  if Equals(name, n"vehicleImpactEnabled") {
    config.vehicleImpactEnabled = value;
    return true;
  };

  if Equals(name, n"worldImpactEnabled") {
    config.worldImpactEnabled = value;
    return true;
  };

  if Equals(name, n"riderKnockoffEnabled") {
    config.riderKnockoffEnabled = value;
    return true;
  };

  if Equals(name, n"killMotorcycleDeathAnimation") {
    config.killMotorcycleDeathAnimation = value;
    return true;
  };

  if Equals(name, n"impactDirectionFlip") {
    config.impactDirectionFlip = value;
    return true;
  };

  if Equals(name, n"leanFallEnabled") {
    config.leanFallEnabled = value;
    return true;
  };

  if Equals(name, n"pickupRecoveryEnabled") {
    config.pickupRecoveryEnabled = value;
    return true;
  };

  return false;
}

@addMethod(PlayerPuppet)
public final func BVCSetModeFloat(
  mode: Int32,
  name: CName,
  value: Float
) -> Bool {
  let config: ref<BVCModeConfig> =
    this.BVCGetModeConfig(mode);

  if !IsDefined(config) {
    return false;
  };

  if Equals(name, n"bulletHitsRequired") {
    config.bulletHitsRequired =
      BVCClampFloat(value, 1.00, 10.00);
    return true;
  };

  if Equals(name, n"bulletChance") {
    config.bulletChance =
      BVCClampFloat(value, 0.00, 100.00);
    return true;
  };

  if Equals(name, n"bulletStrength") {
    config.bulletStrength = MaxF(0.00, value);
    return true;
  };

  if Equals(name, n"vehicleImpactThreshold") {
    config.vehicleImpactThreshold = MaxF(0.00, value);
    return true;
  };

  if Equals(name, n"vehicleImpactChance") {
    config.vehicleImpactChance =
      BVCClampFloat(value, 0.00, 100.00);
    return true;
  };

  if Equals(name, n"vehicleImpactStrength") {
    config.vehicleImpactStrength = MaxF(0.00, value);
    return true;
  };

  if Equals(name, n"worldImpactThreshold") {
    config.worldImpactThreshold = MaxF(0.00, value);
    return true;
  };

  if Equals(name, n"worldImpactChance") {
    config.worldImpactChance =
      BVCClampFloat(value, 0.00, 100.00);
    return true;
  };

  if Equals(name, n"worldImpactStrength") {
    config.worldImpactStrength = MaxF(0.00, value);
    return true;
  };

  if Equals(name, n"toppleCooldown") {
    config.toppleCooldown = MaxF(0.00, value);
    return true;
  };

  if Equals(name, n"leanFallAngle") {
    config.leanFallAngle =
      BVCClampFloat(value, 5.00, 90.00);
    return true;
  };

  if Equals(name, n"leanFallMinSpeed") {
    config.leanFallMinSpeed = MaxF(0.00, value);
    return true;
  };

  if Equals(name, n"leanFallMaxSpeed") {
    config.leanFallMaxSpeed = MaxF(0.00, value);
    return true;
  };

  if Equals(name, n"leanFallBikeStrength") {
    config.leanFallBikeStrength = MaxF(0.00, value);
    return true;
  };

  if Equals(name, n"playerGravityFallStrength") {
    config.playerGravityFallStrength = MaxF(0.00, value);
    return true;
  };

  return false;
}

public func BVCGetPlayer(
  owner: wref<GameObject>
) -> wref<PlayerPuppet> {
  if !IsDefined(owner) {
    return null;
  };

  return GameInstance.GetPlayerSystem(owner.GetGame())
    .GetLocalPlayerMainGameObject() as PlayerPuppet;
}

public func BVCGetActiveConfig(
  owner: wref<GameObject>,
  out mode: Int32
) -> ref<BVCModeConfig> {
  let player: wref<PlayerPuppet> = BVCGetPlayer(owner);
  let state: ref<BVCState>;

  if !IsDefined(player) {
    mode = 4;
    return null;
  };

  state = player.BVCEnsureState();
  mode = state.activeMode;

  return player.BVCGetModeConfig(mode);
}

public func BVCLog(
  owner: wref<GameObject>,
  text: String
) -> Void {
  let activityLog: ref<ActivityLogSystem>;

  if !IsDefined(owner) {
    return;
  };

  activityLog =
    GameInstance.GetActivityLogSystem(owner.GetGame());

  if IsDefined(activityLog) {
    activityLog.AddLog("[BVC1600] " + text);
  };
}

public func BVCNotify(
  owner: wref<GameObject>,
  text: String
) -> Void {
  let player: wref<PlayerPuppet>;
  let state: ref<BVCState>;
  let message: SimpleScreenMessage;

  if !IsDefined(owner) {
    return;
  };

  BVCLog(owner, text);

  player = BVCGetPlayer(owner);

  if !IsDefined(player) {
    return;
  };

  state = player.BVCEnsureState();

  if !state.debugPopups {
    return;
  };

  message.isShown = true;
  message.duration = 2.25;
  message.isInstant = true;
  message.type = SimpleMessageType.Neutral;
  message.message = text;

  GameInstance.GetBlackboardSystem(owner.GetGame())
    .Get(GetAllBlackboardDefs().UI_Notifications)
    .SetVariant(
      GetAllBlackboardDefs().UI_Notifications.WarningMessage,
      ToVariant(message),
      true
    );
}

public func BVCPassChance(chance: Float) -> Bool {
  if chance >= 100.00 {
    return true;
  };

  if chance <= 0.00 {
    return false;
  };

  return RandRangeF(0.00, 100.00) <= chance;
}

public func BVCIsBadPosition(value: Vector4) -> Bool {
  return AbsF(value.X) < 0.001
    && AbsF(value.Y) < 0.001
    && AbsF(value.Z) < 0.001;
}

public func BVCResolveMountedBike(
  rider: wref<GameObject>
) -> wref<BikeObject> {
  let vehicle: wref<VehicleObject>;
  let mountingFacility: ref<IMountingFacility>;
  let mountInfo: MountingInfo;

  if !IsDefined(rider) {
    return null;
  };

  if VehicleComponent.GetVehicle(
    rider.GetGame(),
    rider,
    vehicle
  ) && IsDefined(vehicle) {
    return vehicle as BikeObject;
  };

  mountingFacility =
    GameInstance.GetMountingFacility(rider.GetGame());

  if !IsDefined(mountingFacility) {
    return null;
  };

  mountInfo =
    mountingFacility.GetMountingInfoSingleWithObjects(
      rider
    );

  if !EntityID.IsDefined(mountInfo.parentId) {
    return null;
  };

  return GameInstance.FindEntityByID(
    rider.GetGame(),
    mountInfo.parentId
  ) as BikeObject;
}

public func BVCBulletSide(
  bike: wref<BikeObject>,
  hitPosition: Vector4,
  sourcePosition: Vector4
) -> Float {
  let bikePosition: Vector4;
  let right: Vector4;
  let sideDot: Float;

  if !IsDefined(bike) {
    return 1.00;
  };

  bikePosition = bike.GetWorldPosition();
  right = WorldTransform.GetRight(
    bike.GetWorldTransform()
  );

  sideDot =
    (bikePosition.X - sourcePosition.X) * right.X
      + (bikePosition.Y - sourcePosition.Y) * right.Y;

  if AbsF(sideDot) < 0.10 {
    sideDot =
      (hitPosition.X - bikePosition.X) * right.X
        + (hitPosition.Y - bikePosition.Y) * right.Y;
  };

  if sideDot < 0.00 {
    return -1.00;
  };

  return 1.00;
}

public func BVCImpactSide(
  bike: wref<BikeObject>,
  impactNormal: Vector4,
  flipDirection: Bool
) -> Float {
  let right: Vector4;
  let velocity: Vector4;
  let sideDot: Float;
  let side: Float;

  if !IsDefined(bike) {
    return 1.00;
  };

  right = WorldTransform.GetRight(
    bike.GetWorldTransform()
  );

  sideDot =
    impactNormal.X * right.X
      + impactNormal.Y * right.Y
      + impactNormal.Z * right.Z;

  if AbsF(sideDot) < 0.08 {
    velocity = bike.GetLinearVelocity();

    sideDot =
      velocity.X * right.X
        + velocity.Y * right.Y
        + velocity.Z * right.Z;
  };

  if AbsF(sideDot) < 0.08 {
    if RandRangeF(0.00, 1.00) < 0.50 {
      side = -1.00;
    } else {
      side = 1.00;
    };
  } else {
    if sideDot < 0.00 {
      side = -1.00;
    } else {
      side = 1.00;
    };
  };

  if flipDirection {
    side *= -1.00;
  };

  return side;
}

public func BVCIsBulletHit(
  evt: ref<gameHitEvent>
) -> Bool {
  if !IsDefined(evt) || !IsDefined(evt.attackData) {
    return false;
  };

  if evt.attackData.HasFlag(hitFlag.VehicleImpact) {
    return false;
  };

  return AttackData.IsRangedOrDirect(
    evt.attackData.GetAttackType()
  );
}

public func BVCCanToppleNow(
  bike: wref<BikeObject>,
  config: ref<BVCModeConfig>
) -> Bool {
  let now: Float;

  if !IsDefined(bike) || !IsDefined(config) {
    return false;
  };

  now = BVCNow(bike);

  if now < bike.bvc_lastToppleTime
    + config.toppleCooldown {
    return false;
  };

  bike.bvc_lastToppleTime = now;
  return true;
}

public func BVCSendNoDriver(
  bike: wref<BikeObject>
) -> Void {
  let event: ref<AIEvent>;

  if !IsDefined(bike) {
    return;
  };

  event = new AIEvent();
  event.name = n"NoDriver";
  bike.QueueEvent(event);
}

public func BVCScheduleDownwardRagdollImpulse(
  rider: wref<GameObject>,
  strength: Float,
  delay: Float
) -> Void {
  let delaySystem: ref<DelaySystem>;
  let impulse: Vector4;

  if !IsDefined(rider) || strength <= 0.00 {
    return;
  };

  impulse.X = 0.00;
  impulse.Y = 0.00;
  impulse.Z = -strength;
  impulse.W = 0.00;

  delaySystem =
    GameInstance.GetDelaySystem(rider.GetGame());

  if !IsDefined(delaySystem) {
    return;
  };

  // Do not force ragdoll while V is still mounted. The native
  // CollisionExiting state owns the unmount and knockdown transition.
  delaySystem.DelayEvent(
    rider,
    CreateRagdollApplyImpulseEvent(
      rider.GetWorldPosition(),
      impulse,
      2.00
    ),
    delay,
    false
  );
}

public func BVCGetNativeKnockOffForce(
  bike: wref<BikeObject>
) -> Float {
  let vehicleRecord: wref<Vehicle_Record>;
  let dataPackage: wref<VehicleDataPackage_Record>;

  if !IsDefined(bike) {
    return 8.00;
  };

  vehicleRecord =
    TweakDBInterface.GetVehicleRecord(
      bike.GetRecordID()
    );

  if !IsDefined(vehicleRecord) {
    return 8.00;
  };

  dataPackage = vehicleRecord.VehDataPackage();

  if !IsDefined(dataPackage) {
    return 8.00;
  };

  return MaxF(
    0.25,
    dataPackage.KnockOffForce()
  );
}

public func BVCTriggerNativePlayerExit(
  bike: wref<BikeObject>,
  rider: wref<GameObject>,
  side: Float,
  gravityStrength: Float,
  gravityOnly: Bool,
  sourceLabel: String
) -> Bool {
  let collisionForce: Vector4;
  let direction: Vector4;
  let forceMagnitude: Float;
  let nativeThreshold: Float;

  if !IsDefined(bike)
    || !IsDefined(rider)
    || !rider.IsPlayer() {
    return false;
  };

  nativeThreshold =
    BVCGetNativeKnockOffForce(bike);

  if gravityOnly {
    // CollisionExitingDecisions computes:
    //   ExitForce = -CollisionForce + 4 * BikeUp
    //
    // Keep air control disabled and feed an upward collision force.
    // The resulting native exit force is downward, so V exits through the
    // correct state machine instead of being ragdolled inside the workspot.
    bike.EnableAirControl(false);

    direction = bike.GetWorldUp();

    forceMagnitude = MaxF(
      nativeThreshold + 0.25,
      gravityStrength + 4.50
    );
  } else {
    // Normal impacts use a minimal side force just over the bike's native
    // threshold. This triggers CollisionExiting without a large artificial
    // launch.
    bike.EnableAirControl(true);
    bike.EnableTiltControl(true);

    direction =
      WorldTransform.GetRight(
        bike.GetWorldTransform()
      );

    if side < 0.00 {
      direction *= -1.00;
    };

    forceMagnitude = nativeThreshold + 0.25;
  };

  direction = Vector4.Normalize(direction);
  collisionForce = direction * forceMagnitude;

  // This is the input consumed by CollisionExitingDecisions. It drives the
  // game's real ImmediateExitWithForceEvents low-level unmount path.
  bike.AddCollisionForce(collisionForce);

  // Reinforce gravity only after the native exit has had time to detach V.
  BVCScheduleDownwardRagdollImpulse(
    rider,
    gravityStrength,
    0.35
  );

  BVCNotify(
    bike,
    sourceLabel
      + " | V NATIVE COLLISION EXIT"
      + " | NATIVE THRESHOLD "
      + FloatToString(nativeThreshold)
      + " | INPUT "
      + FloatToString(forceMagnitude)
  );

  return true;
}

public func BVCForceCurrentRiderOff(
  bike: wref<BikeObject>,
  side: Float,
  gravityStrength: Float,
  gravityOnlyPlayerExit: Bool,
  sourceLabel: String
) -> Bool {
  let rider: wref<GameObject>;
  let npcRider: wref<NPCPuppet>;
  let activeConfig: ref<BVCModeConfig>;
  let activeMode: Int32;
  let workspotSystem: ref<WorkspotGameSystem>;

  if !IsDefined(bike) {
    return false;
  };

  rider = VehicleComponent.GetDriverMounted(
    bike.GetGame(),
    bike.GetEntityID()
  );

  if !IsDefined(rider) {
    return false;
  };

  if rider.IsPlayer() {
    // Never manually unmount or force-ragdoll V from here. That leaves the
    // player state machine in the mounted animation and caused the ground-stuck
    // failure in 1601.
    return BVCTriggerNativePlayerExit(
      bike,
      rider,
      side,
      gravityStrength,
      gravityOnlyPlayerExit,
      sourceLabel
    );
  };

  // This is the actual Motorcycle Death Animation toggle. BVC's OnHit wrapper
  // runs after vanilla has determined whether the rider died. If the NPC is
  // dead and this switch is OFF, do not perform BVC's forced unmount/ragdoll
  // handoff; leave the native mounted death-animation path intact.
  npcRider = rider as NPCPuppet;

  if IsDefined(npcRider) && npcRider.IsDead() {
    activeConfig = BVCGetActiveConfig(
      bike,
      activeMode
    );

    if IsDefined(activeConfig)
      && !activeConfig.killMotorcycleDeathAnimation {
      BVCNotify(
        bike,
        sourceLabel
          + " | NPC MOTORCYCLE DEATH ANIMATION PRESERVED"
      );

      return false;
    };
  };

  // NPCs do not use the player's vehicle transition state machine.
  workspotSystem =
    GameInstance.GetWorkspotSystem(bike.GetGame());

  if IsDefined(workspotSystem) {
    // Use the valid three-argument overload. Version 1602 attempted to pass
    // zero-argument Vector4/Quaternion constructors, which REDscript rejects.
    workspotSystem.UnmountFromVehicle(
      bike,
      rider,
      true
    );
  };

  rider.QueueEvent(
    CreateForceRagdollEvent(
      n"BVC1604_NPCRiderKnockoff"
    )
  );

  BVCSendNoDriver(bike);

  BVCNotify(
    bike,
    sourceLabel
      + " | NPC RIDER OFF"
  );

  return true;
}

public func BVCScheduleSuppressPulse(
  bike: wref<BikeObject>,
  generation: Int32,
  delay: Float
) -> Void {
  let delaySystem: ref<DelaySystem>;
  let event: ref<BVCSuppressEvent>;

  if !IsDefined(bike) {
    return;
  };

  delaySystem =
    GameInstance.GetDelaySystem(bike.GetGame());

  if !IsDefined(delaySystem) {
    return;
  };

  event = new BVCSuppressEvent();
  event.generation = generation;

  delaySystem.DelayEvent(
    bike,
    event,
    delay,
    false
  );
}

public func BVCStartSelfRightingSuppression(
  bike: wref<BikeObject>,
  generation: Int32
) -> Void {
  if !IsDefined(bike) {
    return;
  };

  if bike.bvc_controlGeneration != generation {
    return;
  };

  if bike.bvc_recoveryActive {
    return;
  };

  bike.EnableAirControl(false);
  bike.EnableTiltControl(false);

  BVCScheduleSuppressPulse(
    bike,
    generation,
    0.02
  );

  BVCScheduleSuppressPulse(
    bike,
    generation,
    0.08
  );

  BVCScheduleSuppressPulse(
    bike,
    generation,
    0.18
  );

  BVCScheduleSuppressPulse(
    bike,
    generation,
    0.36
  );

  BVCScheduleSuppressPulse(
    bike,
    generation,
    0.72
  );
}

@addMethod(BikeObject)
protected cb func OnBVCSuppressEvent(
  evt: ref<BVCSuppressEvent>
) -> Bool {
  if evt.generation != this.bvc_controlGeneration {
    return true;
  };

  if this.bvc_recoveryActive {
    return true;
  };

  this.EnableAirControl(false);
  this.EnableTiltControl(false);

  return true;
}

public func BVCQueueExitPark(
  bike: wref<BikeObject>
) -> Void {
  let event: ref<VehicleParkedEvent>;

  if !IsDefined(bike) {
    return;
  };

  event = new VehicleParkedEvent();
  event.park = false;
  bike.QueueEvent(event);
}

public func BVCApplyRecoveryPulse(
  bike: wref<BikeObject>,
  generation: Int32
) -> Void {
  if !IsDefined(bike) {
    return;
  };

  if generation != bike.bvc_controlGeneration {
    return;
  };

  bike.PhysicsWakeUp();
  bike.SetCustomTargetTilt(0.00);
  bike.EnableAirControl(true);
  bike.EnableTiltControl(true);
  BVCQueueExitPark(bike);
}

public func BVCScheduleRecoveryPulse(
  bike: wref<BikeObject>,
  generation: Int32,
  delay: Float,
  finalPulse: Bool
) -> Void {
  let delaySystem: ref<DelaySystem>;
  let event: ref<BVCRecoveryEvent>;

  if !IsDefined(bike) {
    return;
  };

  delaySystem =
    GameInstance.GetDelaySystem(bike.GetGame());

  if !IsDefined(delaySystem) {
    return;
  };

  event = new BVCRecoveryEvent();
  event.generation = generation;
  event.finalPulse = finalPulse;

  delaySystem.DelayEvent(
    bike,
    event,
    delay,
    false
  );
}

public func BVCStartPickupRecovery(
  bike: wref<BikeObject>,
  mode: Int32
) -> Void {
  let generation: Int32;

  if !IsDefined(bike) {
    return;
  };

  bike.bvc_controlGeneration += 1;
  generation = bike.bvc_controlGeneration;

  bike.bvc_recoveryActive = true;
  bike.bvc_needsPickupRecovery = false;
  bike.bvc_suppressAfterReceiver = false;
  bike.bvc_leanLatched = false;

  BVCApplyRecoveryPulse(
    bike,
    generation
  );

  BVCScheduleRecoveryPulse(
    bike,
    generation,
    0.02,
    false
  );

  BVCScheduleRecoveryPulse(
    bike,
    generation,
    0.08,
    false
  );

  BVCScheduleRecoveryPulse(
    bike,
    generation,
    0.18,
    false
  );

  BVCScheduleRecoveryPulse(
    bike,
    generation,
    0.36,
    false
  );

  BVCScheduleRecoveryPulse(
    bike,
    generation,
    0.72,
    true
  );

  BVCNotify(
    bike,
    "PICKUP RECOVERY START | "
      + BVCModeName(mode)
      + " | GENERATION "
      + IntToString(generation)
  );
}

@addMethod(BikeObject)
protected cb func OnBVCRecoveryEvent(
  evt: ref<BVCRecoveryEvent>
) -> Bool {
  if evt.generation != this.bvc_controlGeneration {
    return true;
  };

  BVCApplyRecoveryPulse(
    this,
    evt.generation
  );

  if evt.finalPulse {
    this.bvc_recoveryActive = false;

    BVCNotify(
      this,
      "PICKUP RECOVERY COMPLETE | TILT ON | AIR ON"
    );
  };

  return true;
}

public func BVCApplyTopple(
  bike: wref<BikeObject>,
  side: Float,
  strength: Float,
  sourceLabel: String,
  mode: Int32,
  knockOffRider: Bool,
  gravityStrength: Float,
  gravityOnlyPlayerExit: Bool
) -> Bool {
  let knockEvent: ref<KnockOverBikeEvent>;
  let impulseEvent: ref<PhysicalImpulseEvent>;
  let position: Vector4;
  let direction: Vector4;
  let rider: wref<GameObject>;

  if !IsDefined(bike) {
    return false;
  };

  rider = VehicleComponent.GetDriverMounted(
    bike.GetGame(),
    bike.GetEntityID()
  );

  bike.bvc_controlGeneration += 1;
  bike.bvc_recoveryActive = false;
  bike.bvc_suppressAfterReceiver = true;
  bike.bvc_needsPickupRecovery = true;
  bike.bvc_riderMountedAtTopple = IsDefined(rider);
  bike.bvc_seenUnmountAfterTopple = !IsDefined(rider);

  knockEvent = new KnockOverBikeEvent();
  knockEvent.forceKnockdown = true;
  knockEvent.applyDirectionalForce = false;
  bike.QueueEvent(knockEvent);

  // A strength of zero now disables only the added motorcycle impulse.
  // It no longer prevents the native knockover event or rider removal.
  if strength > 0.00 {
    impulseEvent = new PhysicalImpulseEvent();
    impulseEvent.radius = 1.00;

    position = bike.GetWorldPosition();
    impulseEvent.worldPosition.X = position.X;
    impulseEvent.worldPosition.Y = position.Y;
    impulseEvent.worldPosition.Z = position.Z + 0.50;

    direction =
      WorldTransform.GetRight(
        bike.GetWorldTransform()
      );

    if side < 0.00 {
      direction *= -1.00;
    };

    direction *= bike.GetTotalMass() * strength;

    impulseEvent.worldImpulse =
      Vector4.Vector4To3(direction);

    bike.PhysicsWakeUp();
    bike.QueueEvent(impulseEvent);
  };

  if knockOffRider {
    BVCForceCurrentRiderOff(
      bike,
      side,
      gravityStrength,
      gravityOnlyPlayerExit,
      sourceLabel
    );
  };

  BVCNotify(
    bike,
    sourceLabel
      + " | "
      + BVCModeName(mode)
      + " | "
      + BVCSideName(side)
      + " | BIKE STRENGTH "
      + FloatToString(strength)
  );

  return true;
}

public func BVCTryBulletTopple(
  bike: wref<BikeObject>,
  evt: ref<gameHitEvent>,
  directRiderHit: Bool
) -> Void {
  let mode: Int32;
  let config: ref<BVCModeConfig>;
  let instigator: ref<GameObject>;
  let sourcePosition: Vector4;
  let side: Float;
  let label: String;

  if !IsDefined(bike) || !BVCIsBulletHit(evt) {
    return;
  };

  config = BVCGetActiveConfig(bike, mode);

  // Hard master-mode gate. Turning the motorcycle mode OFF must also clear any
  // partially accumulated bullet threshold.
  if !IsDefined(config)
    || !config.enabled {
    bike.bvc_bulletHitCount = 0.00;
    return;
  };

  // Hard bullet-topple gate. OFF means bullets cannot trigger the custom bike
  // topple path at all, and no hidden hit count is retained.
  if !config.bulletEnabled {
    bike.bvc_bulletHitCount = 0.00;
    return;
  };

  instigator = evt.attackData.GetInstigator();

  if config.bulletPlayerOnly {
    if !IsDefined(instigator)
      || !instigator.IsPlayer() {
      return;
    };
  };

  // Deterministic per-bike threshold. 1 = first valid hit, 3 = third valid hit.
  // This applies to the existing working bullet-topple route without changing
  // its topple/rider physics.
  bike.bvc_bulletHitCount += 1.00;

  if bike.bvc_bulletHitCount
    < BVCClampFloat(
      config.bulletHitsRequired,
      1.00,
      10.00
    ) {
    return;
  };

  // A completed group starts fresh whether chance/cooldown passes or not.
  bike.bvc_bulletHitCount = 0.00;

  // Preserve the existing chance behavior exactly as it was, but only AFTER
  // the selected number of bullet hits has been reached.
  if !BVCPassChance(config.bulletChance) {
    return;
  };

  if !BVCCanToppleNow(bike, config) {
    return;
  };

  sourcePosition =
    evt.attackData.GetAttackPosition();

  if IsDefined(instigator) {
    sourcePosition =
      instigator.GetWorldPosition();
  };

  if BVCIsBadPosition(sourcePosition) {
    sourcePosition = evt.hitPosition;
  };

  side = BVCBulletSide(
    bike,
    evt.hitPosition,
    sourcePosition
  );

  if directRiderHit {
    label = "RIDER BULLET TOPPLE";
  } else {
    label = "BIKE BULLET TOPPLE";
  };

  BVCApplyTopple(
    bike,
    side,
    config.bulletStrength,
    label,
    mode,
    config.riderKnockoffEnabled,
    config.playerGravityFallStrength,
    false
  );
}

public func BVCTryVehicleHitFallback(
  bike: wref<BikeObject>,
  evt: ref<gameHitEvent>
) -> Void {
  let mode: Int32;
  let config: ref<BVCModeConfig>;
  let instigator: ref<GameObject>;
  let sourcePosition: Vector4;
  let side: Float;

  if !IsDefined(bike)
    || !IsDefined(evt)
    || !IsDefined(evt.attackData)
    || !evt.attackData.HasFlag(hitFlag.VehicleImpact) {
    return;
  };

  config = BVCGetActiveConfig(bike, mode);

  if !IsDefined(config)
    || !config.enabled
    || !config.vehicleImpactEnabled {
    return;
  };

  // gameHitEvent does not expose VehicleBumpEvent.impactVelocityChange.
  // Use this only as the zero-threshold "any reported touch" fallback.
  if config.vehicleImpactThreshold > 0.00 {
    return;
  };

  if !BVCPassChance(config.vehicleImpactChance) {
    return;
  };

  if !BVCCanToppleNow(bike, config) {
    return;
  };

  instigator = evt.attackData.GetInstigator();
  sourcePosition = evt.attackData.GetAttackPosition();

  if IsDefined(instigator) {
    sourcePosition = instigator.GetWorldPosition();
  };

  if BVCIsBadPosition(sourcePosition) {
    sourcePosition = evt.hitPosition;
  };

  side = BVCBulletSide(
    bike,
    evt.hitPosition,
    sourcePosition
  );

  BVCLog(
    bike,
    "VEHICLE HIT FALLBACK SEEN | THRESHOLD 0"
  );

  BVCApplyTopple(
    bike,
    side,
    config.vehicleImpactStrength,
    "VEHICLE CONTACT HIT FALLBACK",
    mode,
    config.riderKnockoffEnabled,
    config.playerGravityFallStrength,
    false
  );
}

public func BVCImpactThresholdPassed(
  value: Float,
  threshold: Float
) -> Bool {
  // Zero means any reported contact. This deliberately accepts 0.0.
  if threshold <= 0.00 {
    return value >= 0.00;
  };

  return value >= threshold;
}

public func BVCTryImpactTopple(
  bike: wref<BikeObject>,
  evt: ref<VehicleBumpEvent>,
  reverseNormal: Bool,
  collisionRole: String
) -> Void {
  let mode: Int32;
  let config: ref<BVCModeConfig>;
  let impactNormal: Vector4;
  let side: Float;
  let vehicleImpact: Bool;
  let threshold: Float;
  let chance: Float;
  let strength: Float;
  let label: String;

  if !IsDefined(bike) || !IsDefined(evt) {
    return;
  };

  BVCLog(
    bike,
    "BUMP SEEN | DELTA "
      + FloatToString(evt.impactVelocityChange)
      + " | HIT VEHICLE "
      + BoolToString(IsDefined(evt.hitVehicle))
  );

  config = BVCGetActiveConfig(bike, mode);

  if !IsDefined(config) || !config.enabled {
    return;
  };

  vehicleImpact = IsDefined(evt.hitVehicle);

  if vehicleImpact {
    if !config.vehicleImpactEnabled {
      return;
    };

    threshold = config.vehicleImpactThreshold;
    chance = config.vehicleImpactChance;
    strength = config.vehicleImpactStrength;
    label = "CAR / VEHICLE IMPACT";
  } else {
    if !config.worldImpactEnabled {
      return;
    };

    threshold = config.worldImpactThreshold;
    chance = config.worldImpactChance;
    strength = config.worldImpactStrength;
    label = "WALL / WORLD IMPACT";
  };

  if !BVCImpactThresholdPassed(
    evt.impactVelocityChange,
    threshold
  ) {
    return;
  };

  if !BVCPassChance(chance) {
    return;
  };

  if !BVCCanToppleNow(bike, config) {
    return;
  };

  impactNormal =
    Vector4.Vector3To4(evt.hitNormal);

  // VehicleBumpEvent.hitNormal is oriented for the event owner. When the
  // motorcycle is evt.hitVehicle instead, reverse it so the target bike falls
  // away from the contact rather than toward the striking vehicle.
  if reverseNormal {
    impactNormal *= -1.00;
  };

  side = BVCImpactSide(
    bike,
    impactNormal,
    config.impactDirectionFlip
  );

  BVCApplyTopple(
    bike,
    side,
    strength,
    collisionRole
      + " | "
      + label
      + " | DELTA "
      + FloatToString(evt.impactVelocityChange)
      + " | THRESHOLD "
      + FloatToString(threshold),
    mode,
    config.riderKnockoffEnabled,
    config.playerGravityFallStrength,
    false
  );
}

public func BVCTryLeanFall(
  player: wref<PlayerPuppet>,
  bike: wref<BikeObject>,
  config: ref<BVCModeConfig>,
  mode: Int32
) -> Void {
  let leanValue: Float;
  let leanAngle: Float;
  let speed: Float;
  let side: Float;

  if !IsDefined(player)
    || !IsDefined(bike)
    || !IsDefined(config)
    || !config.enabled
    || !config.leanFallEnabled {
    return;
  };

  if !VehicleComponent.IsDriver(
    player.GetGame(),
    player
  ) {
    return;
  };

  leanValue = bike.GetBlackboard().GetFloat(
    GetAllBlackboardDefs().Vehicle.BikeTilt
  );

  leanAngle = AbsF(leanValue);
  speed = AbsF(bike.GetCurrentSpeed());

  if leanAngle
    < config.leanFallAngle - 4.00 {
    bike.bvc_leanLatched = false;
  };

  if bike.bvc_leanLatched {
    return;
  };

  if leanAngle < config.leanFallAngle {
    return;
  };

  if speed < config.leanFallMinSpeed {
    return;
  };

  if speed > config.leanFallMaxSpeed {
    return;
  };

  if !BVCCanToppleNow(bike, config) {
    return;
  };

  if leanValue < 0.00 {
    side = -1.00;
  } else {
    side = 1.00;
  };

  bike.bvc_leanLatched = true;

  BVCApplyTopple(
    bike,
    side,
    config.leanFallBikeStrength,
    "V LEAN FALL | ANGLE "
      + FloatToString(leanAngle)
      + " | SPEED "
      + FloatToString(speed),
    mode,
    true,
    config.playerGravityFallStrength,
    true
  );
}

private func BVCSchedulePlayerMonitor(
  player: wref<PlayerPuppet>,
  delay: Float
) -> Void {
  let delaySystem: ref<DelaySystem>;

  if !IsDefined(player)
    || player.bvc_monitorScheduled {
    return;
  };

  delaySystem =
    GameInstance.GetDelaySystem(player.GetGame());

  if !IsDefined(delaySystem) {
    return;
  };

  player.bvc_monitorScheduled = true;

  delaySystem.DelayEvent(
    player,
    new BVCPlayerMonitorEvent(),
    delay,
    false
  );
}

@addMethod(PlayerPuppet)
protected cb func OnBVCPlayerMonitorEvent(
  evt: ref<BVCPlayerMonitorEvent>
) -> Bool {
  let state: ref<BVCState>;
  let config: ref<BVCModeConfig>;
  let bike: wref<BikeObject>;
  let newMount: Bool;
  let recoveryEligible: Bool;
  let nextDelay: Float;

  this.bvc_monitorScheduled = false;
  state = this.BVCEnsureState();
  config = this.BVCGetModeConfig(
    state.activeMode
  );

  bike = BVCResolveMountedBike(this);
  nextDelay = 0.20;

  if IsDefined(bike)
    && VehicleComponent.IsDriver(
      this.GetGame(),
      this
    ) {
    nextDelay = 0.05;
    newMount = false;

    if !IsDefined(this.bvc_lastMountedBike) {
      newMount = true;
    } else if this.bvc_lastMountedBike.GetEntityID()
      != bike.GetEntityID() {
      newMount = true;
    };

    this.bvc_lastMountedBike = bike;

    recoveryEligible =
      bike.bvc_needsPickupRecovery
      && newMount
      && (
        !bike.bvc_riderMountedAtTopple
        || bike.bvc_seenUnmountAfterTopple
      );

    if IsDefined(config)
      && config.enabled
      && config.pickupRecoveryEnabled
      && recoveryEligible {
      BVCStartPickupRecovery(
        bike,
        state.activeMode
      );
    } else {
      BVCTryLeanFall(
        this,
        bike,
        config,
        state.activeMode
      );
    };
  } else {
    // A topple that began with V mounted must observe a genuine detached
    // frame before a later mount is allowed to run the reverse recovery.
    // This prevents the old 1601 timer from "recovering" while V was still
    // trapped in the mounted workspot.
    if IsDefined(this.bvc_lastMountedBike)
      && this.bvc_lastMountedBike.bvc_needsPickupRecovery
      && this.bvc_lastMountedBike.bvc_riderMountedAtTopple {
      this.bvc_lastMountedBike.bvc_seenUnmountAfterTopple = true;

      BVCLog(
        this,
        "V DISMOUNT OBSERVED | RECOVERY ARMED FOR NEXT MOUNT"
      );
    };

    this.bvc_lastMountedBike = null;
  };

  BVCSchedulePlayerMonitor(
    this,
    nextDelay
  );

  return true;
}

@wrapMethod(MotorcycleComponent)
protected cb func OnKnockOverBikeEvent(
  evt: ref<KnockOverBikeEvent>
) -> Bool {
  let bike: wref<BikeObject>;
  let suppressAfter: Bool;
  let generation: Int32;
  let result: Bool;

  bike = this.GetVehicle() as BikeObject;

  suppressAfter =
    IsDefined(bike)
      && bike.bvc_suppressAfterReceiver;

  if IsDefined(bike) {
    generation =
      bike.bvc_controlGeneration;
  };

  result = wrappedMethod(evt);

  if suppressAfter
    && IsDefined(bike)
    && generation == bike.bvc_controlGeneration {
    bike.bvc_suppressAfterReceiver = false;

    BVCStartSelfRightingSuppression(
      bike,
      generation
    );
  };

  return result;
}

@wrapMethod(VehicleObject)
protected cb func OnHit(
  evt: ref<gameHitEvent>
) -> Bool {
  let result: Bool;
  let bike: wref<BikeObject>;

  bike = this as BikeObject;

  if IsDefined(bike)
    && IsDefined(evt)
    && IsDefined(evt.attackData) {
    if evt.attackData.HasFlag(hitFlag.VehicleImpact) {
      BVCTryVehicleHitFallback(
        bike,
        evt
      );
    } else {
      BVCTryBulletTopple(
        bike,
        evt,
        false
      );
    };
  };

  result = wrappedMethod(evt);
  return result;
}

@wrapMethod(VehicleObject)
protected cb func OnVehicleBumpEvent(
  evt: ref<VehicleBumpEvent>
) -> Bool {
  let result: Bool;
  let ownerBike: wref<BikeObject>;
  let hitBike: wref<BikeObject>;

  if IsDefined(evt) {
    ownerBike = this as BikeObject;
    hitBike = evt.hitVehicle as BikeObject;

    // Route A: the motorcycle itself owns the bump event.
    if IsDefined(ownerBike) {
      BVCLog(
        ownerBike,
        "SYMMETRIC BUMP | OWNER BIKE"
      );

      BVCTryImpactTopple(
        ownerBike,
        evt,
        false,
        "OWNER BIKE"
      );
    };

    // Route B: a car or another motorcycle owns the event and the NPC bike is
    // only available through evt.hitVehicle. Version 1603 ignored this route,
    // which is why a threshold of zero still did nothing when lightly touching
    // an occupied NPC motorcycle.
    if IsDefined(hitBike)
      && (
        !IsDefined(ownerBike)
        || ownerBike.GetEntityID()
          != hitBike.GetEntityID()
      ) {
      BVCLog(
        hitBike,
        "SYMMETRIC BUMP | HIT BIKE TARGET"
      );

      BVCTryImpactTopple(
        hitBike,
        evt,
        true,
        "HIT BIKE TARGET"
      );
    };
  };

  result = wrappedMethod(evt);
  return result;
}

// ScriptedPuppet owns the inherited OnHit implementation used by both
// NPCPuppet and PlayerPuppet. Wrapping the base type covers NPC riders and V
// without an invalid PlayerPuppet wrapper or duplicate NPC execution.
@wrapMethod(ScriptedPuppet)
protected cb func OnHit(
  evt: ref<gameHitEvent>
) -> Bool {
  let result: Bool;
  let bike: wref<BikeObject>;

  result = wrappedMethod(evt);
  bike = BVCResolveMountedBike(this);

  if IsDefined(bike) {
    BVCTryBulletTopple(
      bike,
      evt,
      true
    );
  };

  return result;
}

@addMethod(PlayerPuppet)
private final func BVCResolveBikeFromObject(
  object: wref<GameObject>
) -> wref<BikeObject> {
  let bike: wref<BikeObject>;

  if !IsDefined(object) {
    return null;
  };

  bike = object as BikeObject;

  if IsDefined(bike) {
    return bike;
  };

  return BVCResolveMountedBike(object);
}

@addMethod(PlayerPuppet)
private final func BVCFindControlledBike()
  -> wref<BikeObject> {
  let target: wref<GameObject>;
  let bike: wref<BikeObject>;

  target =
    GameInstance.GetTargetingSystem(this.GetGame())
      .GetLookAtObject(
        this,
        false,
        false
      );

  bike = this.BVCResolveBikeFromObject(target);

  if IsDefined(bike) {
    return bike;
  };

  return BVCResolveMountedBike(this);
}

@addMethod(PlayerPuppet)
private final func BVCRegisterInputs() -> Void {
  let state: ref<BVCState>;

  if this.bvc_inputsRegistered {
    return;
  };

  this.RegisterInputListener(this, n"Reload");
  this.RegisterInputListener(this, n"PocketRadio");
  this.RegisterInputListener(this, n"CallVehicle");

  this.bvc_inputsRegistered = true;

  if this.bvc_manualSide == 0 {
    this.bvc_manualSide = 1;
  };

  state = this.BVCEnsureState();

  if state.manualControllerEnabled {
    BVCNotify(
      this,
      "V BIKE CONTROL READY | "
        + BVCModeName(state.activeMode)
        + " | D-PAD LEFT/RIGHT + SQUARE"
    );
  };
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool;
  let activityLog: ref<ActivityLogSystem>;

  result = wrappedMethod();

  this.BVCEnsureState();
  this.BVCRegisterInputs();

  BVCSchedulePlayerMonitor(
    this,
    0.25
  );

  if !this.bvc_markerShown {
    this.bvc_markerShown = true;

    activityLog =
      GameInstance.GetActivityLogSystem(
        this.GetGame()
      );

    if IsDefined(activityLog) {
      activityLog.AddLog(
        "BVC1605_MOTORCYCLE_DEATH_TOGGLE_EXTREME_LANDING loaded"
      );
    };
  };

  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(
  resolveInterface: EntityResolveComponentsInterface
) -> Bool {
  let result: Bool;

  result = wrappedMethod(resolveInterface);

  this.BVCEnsureState();
  this.BVCRegisterInputs();

  BVCSchedulePlayerMonitor(
    this,
    0.25
  );

  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnAction(
  action: ListenerAction,
  consumer: ListenerActionConsumer
) -> Bool {
  let result: Bool;
  let actionName: CName;
  let now: Float;
  let state: ref<BVCState>;
  let config: ref<BVCModeConfig>;
  let bike: wref<BikeObject>;
  let side: Float;

  result = wrappedMethod(
    action,
    consumer
  );

  if NotEquals(
    ListenerAction.GetType(action),
    gameinputActionType.BUTTON_PRESSED
  ) {
    return result;
  };

  state = this.BVCEnsureState();

  if !state.manualControllerEnabled {
    return result;
  };

  actionName = ListenerAction.GetName(action);
  now = BVCNow(this);

  if Equals(actionName, n"PocketRadio") {
    if now < this.bvc_nextDirectionInputTime {
      return result;
    };

    this.bvc_nextDirectionInputTime =
      now + 0.12;

    this.bvc_manualSide = -1;

    BVCNotify(
      this,
      "MANUAL BIKE SIDE: LEFT | "
        + BVCModeName(state.activeMode)
    );

    return result;
  };

  if Equals(actionName, n"CallVehicle") {
    if now < this.bvc_nextDirectionInputTime {
      return result;
    };

    this.bvc_nextDirectionInputTime =
      now + 0.12;

    this.bvc_manualSide = 1;

    BVCNotify(
      this,
      "MANUAL BIKE SIDE: RIGHT | "
        + BVCModeName(state.activeMode)
    );

    return result;
  };

  if !Equals(actionName, n"Reload") {
    return result;
  };

  if now < this.bvc_nextManualToppleTime {
    return result;
  };

  this.bvc_nextManualToppleTime =
    now + 0.25;

  config =
    this.BVCGetModeConfig(state.activeMode);

  if !IsDefined(config)
    || !config.enabled {
    BVCNotify(
      this,
      "MANUAL BIKE TOPPLE BLOCKED: MODE DISABLED"
    );

    return result;
  };

  bike = this.BVCFindControlledBike();

  if !IsDefined(bike) {
    BVCNotify(
      this,
      "MANUAL BIKE TOPPLE: NO MOTORCYCLE OR RIDER"
    );

    return result;
  };

  if this.bvc_manualSide < 0 {
    side = -1.00;
  } else {
    side = 1.00;
  };

  bike.bvc_lastToppleTime = 0.00;

  BVCApplyTopple(
    bike,
    side,
    config.bulletStrength,
    "MANUAL SQUARE TOPPLE",
    state.activeMode,
    config.riderKnockoffEnabled,
    config.playerGravityFallStrength,
    false
  );

  return result;
}
