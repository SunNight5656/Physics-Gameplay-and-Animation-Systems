module RealisticPush

// SPLAT Bike Topple Internal v8.7
// Build: SPLAT_BIKE_TOPPLE_INTERNAL_V8_7_20260817
//
// This file deliberately does NOT wrap VehicleObject.OnHit.
// VehicleImpulses.reds calls RFC_BikeBulletThresholdHandle directly so there is
// one authoritative motorcycle bullet path rather than competing wrappers.

@addField(BikeObject) public let smbtf_bulletHitCount: Int32;
@addField(BikeObject) public let smbtf_lastCountedBulletTime: Float;
@addField(BikeObject) public let smbtf_counterGeneration: Int32;
@addField(BikeObject) public let smbtf_lastDropScheduleTime: Float;
@addField(BikeObject) public let smbtf_dropGeneration: Int32;
@addField(BikeObject) public let smbtf_pendingCoordinatedDrop: Bool;
@addField(BikeObject) public let smbtf_pendingCoordinatedSide: Float;
@addField(BikeObject) public let smbtf_pendingCoordinatedStrength: Float;

@addField(NPCPuppet) public let smbtf_lastMountedBike: wref<BikeObject>;
@addField(NPCPuppet) public let smbtf_lastMountedBikeTime: Float;
@addField(NPCPuppet) public let smbtf_coordinatedRagdollUntil: Float;

@addField(PlayerPuppet) private let smbtf_hitsRequired: Int32;
@addField(PlayerPuppet) private let smbtf_thresholdGeneration: Int32;
@addField(PlayerPuppet) private let smbtf_riderRagdollToppleEnabled: Bool;
@addField(PlayerPuppet) private let smbtf_riderRagdollToppleInitialized: Bool;
@addField(PlayerPuppet) private let smbtf_riderLeadTime: Float;
@addField(PlayerPuppet) private let smbtf_riderLeadTimeInitialized: Bool;

public class SMBTF_InternalBikeDropEvent extends Event {
  public let generation: Int32;
  public let side: Float;
  public let strength: Float;
  public let nativeDirectional: Bool;
}

public class SMBTF_InternalKeepBikeDownEvent extends Event {}

private func SMBTF_InternalNow(obj: wref<GameObject>) -> Float {
  if !IsDefined(obj) { return 0.0; }
  return EngineTime.ToFloat(GameInstance.GetSimTime(obj.GetGame()));
}

@addMethod(PlayerPuppet)
public final func SMBTFSetHitsRequired(value: Int32) -> Bool {
  if value < 1 { value = 1; }
  if value > 50 { value = 50; }

  if this.smbtf_hitsRequired != value {
    this.smbtf_hitsRequired = value;
    this.smbtf_thresholdGeneration += 1;
    if this.smbtf_thresholdGeneration < 1 {
      this.smbtf_thresholdGeneration = 1;
    }
  }
  return true;
}

@addMethod(PlayerPuppet)
public final func SMBTFGetHitsRequired() -> Int32 {
  if this.smbtf_hitsRequired < 1 { return 5; }
  if this.smbtf_hitsRequired > 50 { return 50; }
  return this.smbtf_hitsRequired;
}

@addMethod(PlayerPuppet)
public final func SMBTFGetThresholdGeneration() -> Int32 {
  return this.smbtf_thresholdGeneration;
}

@addMethod(PlayerPuppet)
public final func SMBTFSetRiderRagdollToppleEnabled(value: Bool) -> Bool {
  this.smbtf_riderRagdollToppleEnabled = value;
  this.smbtf_riderRagdollToppleInitialized = true;
  return true;
}

@addMethod(PlayerPuppet)
public final func SMBTFGetRiderRagdollToppleEnabled() -> Bool {
  if !this.smbtf_riderRagdollToppleInitialized { return true; }
  return this.smbtf_riderRagdollToppleEnabled;
}

@addMethod(PlayerPuppet)
public final func SMBTFSetRiderLeadTime(value: Float) -> Bool {
  if value < 0.0 { value = 0.0; }
  if value > 0.50 { value = 0.50; }
  this.smbtf_riderLeadTime = value;
  this.smbtf_riderLeadTimeInitialized = true;
  return true;
}

@addMethod(PlayerPuppet)
public final func SMBTFGetRiderLeadTime() -> Float {
  // Default 80 ms so the rider has time to enter physics before the bike moves.
  if !this.smbtf_riderLeadTimeInitialized { return 0.08; }
  if this.smbtf_riderLeadTime < 0.0 { return 0.0; }
  if this.smbtf_riderLeadTime > 0.50 { return 0.50; }
  return this.smbtf_riderLeadTime;
}

@addMethod(PlayerPuppet)
public final func SMBTFGetBridgeVersion() -> Int32 {
  return 87;
}

private func SMBTF_InternalPlayer(obj: wref<GameObject>) -> ref<PlayerPuppet> {
  if !IsDefined(obj) { return null; }
  return GameInstance.GetPlayerSystem(obj.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
}

private func SMBTF_InternalHitsRequired(bike: wref<BikeObject>) -> Int32 {
  let player: ref<PlayerPuppet> = SMBTF_InternalPlayer(bike);
  if !IsDefined(player) { return 5; }
  return player.SMBTFGetHitsRequired();
}

private func SMBTF_InternalGeneration(bike: wref<BikeObject>) -> Int32 {
  let player: ref<PlayerPuppet> = SMBTF_InternalPlayer(bike);
  if !IsDefined(player) { return 0; }
  return player.SMBTFGetThresholdGeneration();
}

private func SMBTF_InternalRiderToppleEnabled(obj: wref<GameObject>) -> Bool {
  let player: ref<PlayerPuppet> = SMBTF_InternalPlayer(obj);
  if !IsDefined(player) { return true; }
  return player.SMBTFGetRiderRagdollToppleEnabled();
}

private func SMBTF_InternalRiderLeadTime(obj: wref<GameObject>) -> Float {
  let player: ref<PlayerPuppet> = SMBTF_InternalPlayer(obj);
  if !IsDefined(player) { return 0.08; }
  return player.SMBTFGetRiderLeadTime();
}

private func SMBTF_InternalResetCounter(bike: wref<BikeObject>) -> Void {
  if !IsDefined(bike) { return; }
  bike.smbtf_bulletHitCount = 0;
  bike.smbtf_lastCountedBulletTime = 0.0;
  bike.smbtf_counterGeneration = SMBTF_InternalGeneration(bike);
}

private func SMBTF_InternalAcceptOneShot(bike: wref<BikeObject>) -> Bool {
  if !IsDefined(bike) { return false; }

  let generation: Int32 = SMBTF_InternalGeneration(bike);
  if bike.smbtf_counterGeneration != generation {
    bike.smbtf_bulletHitCount = 0;
    bike.smbtf_lastCountedBulletTime = 0.0;
    bike.smbtf_counterGeneration = generation;
  }

  let now: Float = SMBTF_InternalNow(bike);
  // A single gunshot can emit several VehicleObject hit callbacks (especially
  // multi-shape/pellet hits). Collapse callbacks in the same 40 ms shot window.
  if bike.smbtf_lastCountedBulletTime > 0.0
    && now - bike.smbtf_lastCountedBulletTime < 0.040 {
    return false;
  }

  bike.smbtf_lastCountedBulletTime = now;
  return true;
}

private func SMBTF_InternalBadPos(v: Vector4) -> Bool {
  return AbsF(v.X) < 0.001 && AbsF(v.Y) < 0.001 && AbsF(v.Z) < 0.001;
}

private func SMBTF_InternalShotSide(
  bike: wref<BikeObject>,
  hitPos: Vector4,
  srcPos: Vector4
) -> Float {
  let bikePos: Vector4 = bike.GetWorldPosition();
  let right: Vector4 = WorldTransform.GetRight(bike.GetWorldTransform());
  let sideDot: Float = (bikePos.X - srcPos.X) * right.X
    + (bikePos.Y - srcPos.Y) * right.Y;

  if AbsF(sideDot) < 0.10 {
    sideDot = (hitPos.X - bikePos.X) * right.X
      + (hitPos.Y - bikePos.Y) * right.Y;
  }

  if sideDot < 0.0 { return -1.0; }
  return 1.0;
}

@addMethod(BikeObject)
protected cb func OnSMBTF_InternalKeepBikeDownEvent(
  evt: ref<SMBTF_InternalKeepBikeDownEvent>
) -> Bool {
  this.EnableAirControl(false);
  this.EnableTiltControl(false);
  return true;
}

private func SMBTF_InternalScheduleKeepDown(bike: wref<BikeObject>) -> Void {
  if !IsDefined(bike) { return; }
  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(bike.GetGame());
  if !IsDefined(ds) { return; }

  ds.DelayEvent(bike, new SMBTF_InternalKeepBikeDownEvent(), 0.050, false);
  ds.DelayEvent(bike, new SMBTF_InternalKeepBikeDownEvent(), 0.150, false);
  ds.DelayEvent(bike, new SMBTF_InternalKeepBikeDownEvent(), 0.350, false);
  ds.DelayEvent(bike, new SMBTF_InternalKeepBikeDownEvent(), 0.700, false);
}

private func SMBTF_InternalToppleBike(
  bike: wref<BikeObject>,
  side: Float,
  strength: Float,
  nativeDirectional: Bool
) -> Void {
  if !IsDefined(bike) { return; }

  bike.PhysicsWakeUp();

  let knockEvt: ref<KnockOverBikeEvent> = new KnockOverBikeEvent();
  knockEvt.forceKnockdown = true;
  knockEvt.applyDirectionalForce = nativeDirectional;
  bike.QueueEvent(knockEvt);

  if !nativeDirectional && strength > 0.0 {
    let impulseEvt: ref<PhysicalImpulseEvent> = new PhysicalImpulseEvent();
    impulseEvt.radius = 1.0;

    let pos: Vector4 = bike.GetWorldPosition();
    impulseEvt.worldPosition.X = pos.X;
    impulseEvt.worldPosition.Y = pos.Y;
    impulseEvt.worldPosition.Z = pos.Z + 0.50;

    let dir: Vector4 = WorldTransform.GetRight(bike.GetWorldTransform());
    if side < 0.0 { dir *= -1.0; }
    dir *= bike.GetTotalMass() * strength;
    impulseEvt.worldImpulse = Vector4.Vector4To3(dir);
    bike.QueueEvent(impulseEvt);
  }

  SMBTF_InternalScheduleKeepDown(bike);
}

@addMethod(BikeObject)
protected cb func OnSMBTF_InternalBikeDropEvent(
  evt: ref<SMBTF_InternalBikeDropEvent>
) -> Bool {
  if !IsDefined(evt) || evt.generation != this.smbtf_dropGeneration {
    return true;
  }
  SMBTF_InternalToppleBike(this, evt.side, evt.strength, evt.nativeDirectional);
  return true;
}

private func SMBTF_InternalScheduleBikeDrop(
  bike: wref<BikeObject>,
  side: Float,
  strength: Float,
  delay: Float,
  nativeDirectional: Bool
) -> Void {
  if !IsDefined(bike) { return; }

  let now: Float = SMBTF_InternalNow(bike);
  // OnDeath and OnRagdoll can both observe the same transition. One schedule wins.
  if bike.smbtf_lastDropScheduleTime > 0.0
    && now - bike.smbtf_lastDropScheduleTime < 0.060 {
    return;
  }
  bike.smbtf_lastDropScheduleTime = now;

  bike.smbtf_dropGeneration += 1;
  if bike.smbtf_dropGeneration < 1 { bike.smbtf_dropGeneration = 1; }

  let evt: ref<SMBTF_InternalBikeDropEvent> = new SMBTF_InternalBikeDropEvent();
  evt.generation = bike.smbtf_dropGeneration;
  evt.side = side;
  evt.strength = strength;
  evt.nativeDirectional = nativeDirectional;

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(bike.GetGame());
  if IsDefined(ds) {
    ds.DelayEvent(bike, evt, MaxF(0.0, delay), false);
  } else {
    bike.QueueEvent(evt);
  }
}

private func SMBTF_InternalCacheBike(rider: wref<NPCPuppet>) -> wref<BikeObject> {
  if !IsDefined(rider) { return null; }

  let bike: wref<BikeObject> = RFC_GetMountedVehicle(rider) as BikeObject;
  if IsDefined(bike) {
    rider.smbtf_lastMountedBike = bike;
    rider.smbtf_lastMountedBikeTime = SMBTF_InternalNow(rider);
  }
  return bike;
}

private func SMBTF_InternalCurrentOrRecentBike(
  rider: wref<NPCPuppet>
) -> wref<BikeObject> {
  if !IsDefined(rider) { return null; }

  let bike: wref<BikeObject> = SMBTF_InternalCacheBike(rider);
  if IsDefined(bike) { return bike; }

  bike = rider.smbtf_lastMountedBike;
  if IsDefined(bike) {
    let age: Float = SMBTF_InternalNow(rider) - rider.smbtf_lastMountedBikeTime;
    if age >= 0.0 && age <= 1.00 { return bike; }
  }
  return null;
}

private func SMBTF_InternalUnmountAndRagdollRiders(
  bike: wref<BikeObject>
) -> Bool {
  if !IsDefined(bike) { return false; }

  let passengers: array<wref<GameObject>>;
  VehicleComponent.GetAllPassengers(
    bike.GetGame(), bike.GetEntityID(), true, passengers
  );

  let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(bike.GetGame());
  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(bike.GetGame());
  let foundRider: Bool = false;
  let i: Int32 = 0;

  while i < ArraySize(passengers) {
    let rider: wref<NPCPuppet> = passengers[i] as NPCPuppet;
    if IsDefined(rider) {
      foundRider = true;
      rider.smbtf_lastMountedBike = bike;
      rider.smbtf_lastMountedBikeTime = SMBTF_InternalNow(rider);
      // Long enough to survive a real workspot -> ragdoll transition.
      rider.smbtf_coordinatedRagdollUntil = SMBTF_InternalNow(rider) + 1.00;

      if IsDefined(ws) {
        ws.UnmountFromVehicle(bike, rider, true);
      }

      // This only requests ragdoll. The motorcycle is NOT scheduled here.
      // The coordinated bike timer starts inside OnRagdollEnabledEvent after
      // the engine confirms that the NPC has actually entered ragdoll.
      rider.QueueEvent(
        CreateForceRagdollEvent(n"Splat_BikeThreshold_RagdollFirst")
      );

      if IsDefined(ds) {
        ds.DelayEvent(
          rider,
          CreateForceRagdollEvent(n"Splat_BikeThreshold_RagdollConfirm"),
          0.010,
          false
        );
      }
    }
    i += 1;
  }

  return foundRider;
}

// Called directly from the real RFC_VehTryApply in VehicleImpulses.reds.
// It owns ALL motorcycle bullet handling; the caller returns immediately after
// this function, so the old instant topple and generic bike bullet impulse never run.
public func RFC_BikeBulletThresholdHandle(
  bike: ref<BikeObject>,
  evt: ref<gameHitEvent>,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(bike) || !IsDefined(evt) || !IsDefined(evt.attackData) { return; }

  // Existing SPLAT bullet-topple toggle is authoritative.
  if !cfg.vehicleMotorcycleToppleOnBullet {
    SMBTF_InternalResetCounter(bike);
    return;
  }

  // Respect the existing V-only vehicle bullet source gate when enabled.
  if cfg.vehicleBulletPlayerOnly && !RFC_IsPlayerAttack(bike, evt.attackData) {
    return;
  }

  // One real shot increments once even when several vehicle hit callbacks fire.
  if !SMBTF_InternalAcceptOneShot(bike) { return; }

  bike.smbtf_bulletHitCount += 1;
  let required: Int32 = SMBTF_InternalHitsRequired(bike);
  if bike.smbtf_bulletHitCount < required { return; }

  SMBTF_InternalResetCounter(bike);

  let srcPos: Vector4 = evt.attackData.GetAttackPosition();
  let instigator: ref<GameObject> = evt.attackData.GetInstigator();
  if IsDefined(instigator) { srcPos = instigator.GetWorldPosition(); }
  if SMBTF_InternalBadPos(srcPos) { srcPos = evt.hitPosition; }

  let side: Float = SMBTF_InternalShotSide(bike, evt.hitPosition, srcPos);

  // Critical order in v8.6:
  // 1. Arm the motorcycle drop, but DO NOT start its timer.
  // 2. Unmount + request NPC ragdoll.
  // 3. Wait for the NPC's real OnRagdollEnabledEvent.
  // 4. Only after wrappedMethod(evt) confirms the ragdoll transition do we
  //    start the user-controlled bike delay.
  // 5. When that delay expires, topple the motorcycle.
  //
  // This makes the slider measure "time AFTER NPC ragdoll" instead of
  // "time after we asked the NPC to ragdoll."
  bike.smbtf_pendingCoordinatedDrop = true;
  bike.smbtf_pendingCoordinatedSide = side;
  bike.smbtf_pendingCoordinatedStrength = cfg.vehicleMotorcycleToppleStrength;

  let foundRider: Bool = SMBTF_InternalUnmountAndRagdollRiders(bike);

  // Empty motorcycle: there is no rider ragdoll event to wait for.
  if !foundRider {
    bike.smbtf_pendingCoordinatedDrop = false;
    SMBTF_InternalScheduleBikeDrop(
      bike,
      side,
      cfg.vehicleMotorcycleToppleStrength,
      0.0,
      false
    );
  }
}

// This wrapper only caches the mounted bike. It does not alter bullet settings
// and does not topple a bike merely because the rider was hit.
@wrapMethod(NPCPuppet)
protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
  SMBTF_InternalCacheBike(this);
  return wrappedMethod(evt);
}

@wrapMethod(NPCPuppet)
protected cb func OnRagdollEnabledEvent(
  evt: ref<RagdollNotifyEnabledEvent>
) -> Bool {
  let bike: wref<BikeObject> = SMBTF_InternalCurrentOrRecentBike(this);
  let coordinated: Bool = SMBTF_InternalNow(this) <= this.smbtf_coordinatedRagdollUntil;

  // The engine's normal ragdoll transition runs first.
  let result: Bool = wrappedMethod(evt);

  if coordinated
    && IsDefined(bike)
    && bike.smbtf_pendingCoordinatedDrop {
    // Consume the armed drop once. The slider now begins AFTER this real
    // ragdoll-enabled callback, which creates the visible NPC-first sequence.
    bike.smbtf_pendingCoordinatedDrop = false;
    this.smbtf_coordinatedRagdollUntil = 0.0;

    SMBTF_InternalScheduleBikeDrop(
      bike,
      bike.smbtf_pendingCoordinatedSide,
      bike.smbtf_pendingCoordinatedStrength,
      SMBTF_InternalRiderLeadTime(this),
      false
    );
  } else {
    if !coordinated
      && IsDefined(bike)
      && SMBTF_InternalRiderToppleEnabled(this) {
      let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetGame());
      if IsDefined(ws) { ws.UnmountFromVehicle(bike, this, true); }

      // Direct rider ragdoll path remains separate from motorcycle-shot threshold.
      SMBTF_InternalScheduleBikeDrop(bike, 1.0, 0.0, 0.010, true);
    }
  }

  return result;
}

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  // Capture before any death wrapper clears the mount.
  let bike: wref<BikeObject> = SMBTF_InternalCurrentOrRecentBike(this);
  let coordinated: Bool = SMBTF_InternalNow(this) <= this.smbtf_coordinatedRagdollUntil;
  let result: Bool = wrappedMethod(evt);

  if IsDefined(bike) && SMBTF_InternalRiderToppleEnabled(this) {
    RFC_VehStopDeadBikeDriverAI(bike);

    let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetGame());
    if IsDefined(ws) { ws.UnmountFromVehicle(bike, this, true); }

    // Ensure death reaches ragdoll. For a coordinated motorcycle-shot threshold,
    // do NOT move the bike here; OnRagdollEnabledEvent owns the bike timer.
    this.QueueEvent(CreateForceRagdollEvent(n"Splat_BikeRiderDeath_RagdollFirst"));
    if !coordinated {
      SMBTF_InternalScheduleBikeDrop(bike, 1.0, 0.0, 0.018, true);
    }
  }

  return result;
}
