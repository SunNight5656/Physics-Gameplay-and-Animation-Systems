module RealisticPush

// SPLAT Juggernaut Mode - vehicle + world-object lane.
// NPCs deliberately use the already-proven AAA Trip OnLook path.
// This loop is active only while the real SPLAT mode selector is Juggernaut.

public class SPLAT_JuggernautTickEvt extends Event {}
public class SPLAT_JuggernautResetCooldownEvt extends Event {}

@addField(PlayerPuppet) private let splatJuggernautLoopStarted: Bool;
@addField(PlayerPuppet) private let splatJuggernautCooldown: Bool;
@addField(PlayerPuppet) private let splatJuggernautLastPosValid: Bool;
@addField(PlayerPuppet) private let splatJuggernautLastPos: Vector4;

private func SPLAT_JuggernautDelay(t: Float) -> Float {
  if t <= 0.00 { return 0.01; }
  return t;
}

private func SPLAT_JuggernautSchedule(owner: wref<GameObject>, evt: ref<Event>, delay: Float) -> Void {
  if !IsDefined(owner) || !IsDefined(evt) { return; }
  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(owner.GetGame());
  if !IsDefined(ds) { return; }
  ds.DelayEvent(owner, evt, MaxF(0.001, delay), false);
}

private func SPLAT_JuggernautResolveMountedVehicle(obj: ref<GameObject>) -> wref<VehicleObject> {
  if !IsDefined(obj) { return null; }
  let vehicle: wref<VehicleObject>;
  if VehicleComponent.GetVehicle(obj.GetGame(), obj, vehicle) && IsDefined(vehicle) {
    return vehicle;
  }
  return null;
}

private func SPLAT_JuggernautLookObject(player: wref<PlayerPuppet>) -> ref<GameObject> {
  if !IsDefined(player) { return null; }
  let targeting: ref<TargetingSystem> = GameInstance.GetTargetingSystem(player.GetGame());
  if !IsDefined(targeting) { return null; }

  // Read both target lanes every tick. The old code only asked the broad lane
  // when the combat-target lane returned NULL. On an occupied car the first
  // result can be the driver/passenger, which prevented the vehicle lane from
  // ever seeing the VehicleObject.
  let primary: ref<GameObject> = targeting.GetLookAtObject(player, false, false);
  let broad: ref<GameObject> = targeting.GetLookAtObject(player, true, true);

  let vehicle: wref<VehicleObject> = primary as VehicleObject;
  if IsDefined(vehicle) { return vehicle; }
  vehicle = broad as VehicleObject;
  if IsDefined(vehicle) { return vehicle; }

  // If the crosshair resolves a seated NPC instead of the chassis, convert
  // that occupant back to the mounted vehicle for Juggernaut smashing.
  vehicle = SPLAT_JuggernautResolveMountedVehicle(primary);
  if IsDefined(vehicle) { return vehicle; }
  vehicle = SPLAT_JuggernautResolveMountedVehicle(broad);
  if IsDefined(vehicle) { return vehicle; }

  // Preserve the already-working NPC path when a standing NPC is the target.
  let primaryNPC: wref<NPCPuppet> = primary as NPCPuppet;
  if IsDefined(primaryNPC) { return primary; }
  let broadNPC: wref<NPCPuppet> = broad as NPCPuppet;
  if IsDefined(broadNPC) { return broad; }

  // Prefer the broad lane for street props/destructibles; many are not valid
  // combat targets and therefore never appear in the primary lane.
  if IsDefined(broad) { return broad; }
  return primary;
}

private func SPLAT_JuggernautCentered(player: wref<PlayerPuppet>, dirToTarget: Vector4) -> Bool {
  let forward: Vector4 = Vector4.Normalize(player.GetWorldForward());
  let right: Vector4 = Vector4.Normalize(player.GetWorldRight());
  let aimDot: Float = Vector4.Dot(forward, dirToTarget);
  let sideDot: Float = AbsF(Vector4.Dot(right, dirToTarget));
  return aimDot >= 0.72 && sideDot <= 0.78;
}

private func SPLAT_JuggernautVehicleImpulse(
  vehicle: wref<VehicleObject>,
  moveDir: Vector4,
  strength: Float,
  vertical: Float,
  radius: Float,
  massCompensation: Bool
) -> Bool {
  if !IsDefined(vehicle) { return false; }
  if strength == 0.0 && vertical == 0.0 { return false; }

  let scale: Float = 1.0;
  if massCompensation {
    let mass: Float = vehicle.GetTotalMass();
    if mass > 1.0 {
      scale = MinF(2.50, MaxF(0.65, mass / 1800.0));
    }
  }

  let impulse: Vector3;
  impulse.X = moveDir.X * strength * scale;
  impulse.Y = moveDir.Y * strength * scale;
  impulse.Z = vertical * scale;

  let p4: Vector4 = vehicle.GetWorldPosition();
  let pos: Vector3;
  pos.X = p4.X;
  pos.Y = p4.Y;
  pos.Z = p4.Z + 0.45;

  // Existing proven SPLAT helper. Does not read bullet/explosion force values.
  RFC_VehScheduleSelfRightingKill(vehicle);
  vehicle.PhysicsWakeUp();

  let evt: ref<PhysicalImpulseEvent> = new PhysicalImpulseEvent();
  evt.worldImpulse = impulse;
  evt.worldPosition = pos;
  evt.radius = MaxF(0.05, radius);
  vehicle.QueueEvent(evt);
  return true;
}

private func SPLAT_JuggernautObjectImpulse(
  obj: ref<GameObject>,
  moveDir: Vector4,
  strength: Float,
  vertical: Float,
  radius: Float
) -> Bool {
  if !IsDefined(obj) { return false; }
  if strength == 0.0 && vertical == 0.0 { return false; }

  // Generic GameObject PhysicalImpulseEvent. Two off-center hits are used so
  // movable/destructible props get translation + torque instead of only a
  // centered shove. Truly static world geometry will still ignore physics.
  let impulse: Vector3;
  impulse.X = moveDir.X * strength;
  impulse.Y = moveDir.Y * strength;
  impulse.Z = vertical;

  let p4: Vector4 = obj.GetWorldPosition();
  let posLow: Vector3;
  posLow.X = p4.X;
  posLow.Y = p4.Y;
  posLow.Z = p4.Z + 0.30;

  let evtLow: ref<PhysicalImpulseEvent> = new PhysicalImpulseEvent();
  evtLow.worldImpulse = impulse;
  evtLow.worldPosition = posLow;
  evtLow.radius = MaxF(0.05, radius);
  obj.QueueEvent(evtLow);

  let impulseHigh: Vector3;
  impulseHigh.X = moveDir.X * strength * 0.65;
  impulseHigh.Y = moveDir.Y * strength * 0.65;
  impulseHigh.Z = vertical * 0.50;

  let posHigh: Vector3;
  posHigh.X = p4.X;
  posHigh.Y = p4.Y;
  posHigh.Z = p4.Z + 1.10;

  let evtHigh: ref<PhysicalImpulseEvent> = new PhysicalImpulseEvent();
  evtHigh.worldImpulse = impulseHigh;
  evtHigh.worldPosition = posHigh;
  evtHigh.radius = MaxF(0.05, radius * 0.75);
  obj.QueueEvent(evtHigh);
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnSPLAT_JuggernautResetCooldownEvt(evt: ref<SPLAT_JuggernautResetCooldownEvt>) -> Bool {
  this.splatJuggernautCooldown = false;
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnSPLAT_JuggernautTickEvt(evt: ref<SPLAT_JuggernautTickEvt>) -> Bool {
  let menu: ref<RFCModSettings> = SPLATSettingsRuntime.Menu();
  let mode: Int32 = EnumInt(menu.splatPresetMode);
  let maxTest: Bool = menu.juggernautMaxTestSensitivity;

  // Keep one dormant watcher so changing into Juggernaut later works without
  // rebuilding the PlayerPuppet. No force logic runs outside the mode.
  if mode != EnumInt(RFCSplatPresetMode.Juggernaut) {
    this.splatJuggernautLastPosValid = false;
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), 0.10);
    return true;
  }

  let interval: Float = SPLAT_JuggernautDelay(menu.juggernautIntervalSec);
  if maxTest { interval = 0.02; }
  let playerPos: Vector4 = this.GetWorldPosition();

  if !menu.juggernautEnabled || RFC_IsMountedToVehicle(this) {
    this.splatJuggernautLastPosValid = false;
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  if !this.splatJuggernautLastPosValid {
    this.splatJuggernautLastPosValid = true;
    this.splatJuggernautLastPos = playerPos;
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  let moveVec: Vector4 = playerPos - this.splatJuggernautLastPos;
  let moveLen: Float = Vector4.Length(moveVec);
  this.splatJuggernautLastPos = playerPos;

  if this.splatJuggernautCooldown || moveLen <= 0.001 || moveLen > 4.0 {
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  let speed: Float = moveLen / interval;
  let minSpeed: Float = menu.juggernautMinSpeedMps;
  if maxTest { minSpeed = MinF(minSpeed, 0.10); }
  if minSpeed > 0.0 && speed < minSpeed {
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  let obj: ref<GameObject> = SPLAT_JuggernautLookObject(this);
  if !IsDefined(obj) {
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  // NPCs are intentionally handled by the proven AAA Trip OnLook path.
  let npc: wref<NPCPuppet> = obj as NPCPuppet;
  if IsDefined(npc) {
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  let targetPos: Vector4 = obj.GetWorldPosition();
  let toTarget: Vector4 = targetPos - playerPos;
  let dist: Float = Vector4.Length(toTarget);
  if dist <= 0.001 {
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  let dirToTarget: Vector4 = Vector4.Normalize(toTarget);
  if !maxTest && menu.juggernautRequireCenterScreen && !SPLAT_JuggernautCentered(this, dirToTarget) {
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  let moveDir: Vector4 = Vector4.Normalize(moveVec);
  let forwardDot: Float = Vector4.Dot(moveDir, dirToTarget);
  if (!maxTest && forwardDot <= 0.15) || (maxTest && forwardDot <= -0.20) {
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  let effectiveSpeed: Float = speed * forwardDot;
  if minSpeed > 0.0 && effectiveSpeed < minSpeed {
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
    return true;
  }

  let didHit: Bool = false;
  let vehicle: wref<VehicleObject> = obj as VehicleObject;

  if IsDefined(vehicle) && menu.juggernautAffectVehicles {
    let vehicleDist: Float = menu.juggernautVehicleContactDistM;
    let vehiclePush: Float = menu.juggernautVehiclePush;
    let vehicleVertical: Float = menu.juggernautVehicleVertical;
    let vehicleRadius: Float = menu.juggernautVehicleRadius;
    if maxTest {
      vehicleDist = MaxF(vehicleDist, 12.0);
      vehiclePush = MaxF(vehiclePush, 10000.0);
      if AbsF(vehicleVertical) < 800.0 { vehicleVertical = 800.0; }
      vehicleRadius = MaxF(vehicleRadius, 2.50);
    }
    if vehicleDist <= 0.0 || dist <= vehicleDist {
      didHit = SPLAT_JuggernautVehicleImpulse(
        vehicle,
        moveDir,
        vehiclePush,
        vehicleVertical,
        vehicleRadius,
        menu.juggernautVehicleMassCompensation
      );
    }
  } else if menu.juggernautAffectObjects {
    let puppet: wref<ScriptedPuppet> = obj as ScriptedPuppet;
    let objectDist: Float = menu.juggernautObjectContactDistM;
    let objectPush: Float = menu.juggernautObjectPush;
    let objectVertical: Float = menu.juggernautObjectVertical;
    let objectRadius: Float = menu.juggernautObjectRadius;
    if maxTest {
      objectDist = MaxF(objectDist, 10.0);
      objectPush = MaxF(objectPush, 8000.0);
      if AbsF(objectVertical) < 600.0 { objectVertical = 600.0; }
      objectRadius = MaxF(objectRadius, 2.00);
    }
    if !IsDefined(puppet) && (objectDist <= 0.0 || dist <= objectDist) {
      didHit = SPLAT_JuggernautObjectImpulse(
        obj,
        moveDir,
        objectPush,
        objectVertical,
        objectRadius
      );
    }
  }

  let cooldown: Float = menu.juggernautCooldownSec;
  if maxTest { cooldown = 0.0; }
  if didHit && cooldown > 0.0 {
    this.splatJuggernautCooldown = true;
    SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautResetCooldownEvt(), cooldown);
  }

  SPLAT_JuggernautSchedule(this, new SPLAT_JuggernautTickEvt(), interval);
  return true;
}


// ---------------------------------------------------------------------------
// COMING SOON collision pass
//
// The original Juggernaut watcher is still the proven NPC/look fallback.
// These hooks use the engine's native collision lanes so cars and physics
// objects no longer depend on TargetingSystem resolving them as look targets.
// Everything below is a hard no-op outside Juggernaut mode.
// ---------------------------------------------------------------------------

private func SPLAT_JuggernautModeActive(menu: ref<RFCModSettings>) -> Bool {
  if !IsDefined(menu) { return false; }
  return menu.juggernautEnabled
    && EnumInt(menu.splatPresetMode) == EnumInt(RFCSplatPresetMode.Juggernaut);
}

private func SPLAT_JuggernautDirectionFromPlayer(
  player: wref<PlayerPuppet>,
  target: ref<GameObject>
) -> Vector4 {
  let dir: Vector4;
  if IsDefined(player) && IsDefined(target) {
    dir = target.GetWorldPosition() - player.GetWorldPosition();
    dir.Z = 0.0;
    if Vector4.Length(dir) > 0.001 {
      return Vector4.Normalize(dir);
    }
  }

  if IsDefined(player) {
    dir = player.GetWorldForward();
    dir.Z = 0.0;
    if Vector4.Length(dir) > 0.001 {
      return Vector4.Normalize(dir);
    }
  }

  dir.X = 1.0;
  dir.Y = 0.0;
  dir.Z = 0.0;
  dir.W = 0.0;
  return dir;
}

private func SPLAT_JuggernautApplyVehicleNativeContact(
  player: wref<PlayerPuppet>,
  vehicle: wref<VehicleObject>,
  menu: ref<RFCModSettings>
) -> Bool {
  if !IsDefined(player) || !IsDefined(vehicle) || !IsDefined(menu) { return false; }
  if !menu.juggernautAffectVehicles || RFC_IsMountedToVehicle(player) { return false; }

  let push: Float = menu.juggernautVehiclePush;
  let vertical: Float = menu.juggernautVehicleVertical;
  let radius: Float = menu.juggernautVehicleRadius;

  if menu.juggernautMaxTestSensitivity {
    push = MaxF(push, 15000.0);
    if AbsF(vertical) < 1000.0 { vertical = 1000.0; }
    radius = MaxF(radius, 3.00);
  }

  return SPLAT_JuggernautVehicleImpulse(
    vehicle,
    SPLAT_JuggernautDirectionFromPlayer(player, vehicle),
    push,
    vertical,
    radius,
    menu.juggernautVehicleMassCompensation
  );
}

private func SPLAT_JuggernautApplyObjectNativeContact(
  player: wref<PlayerPuppet>,
  obj: ref<GameObject>,
  menu: ref<RFCModSettings>
) -> Bool {
  if !IsDefined(player) || !IsDefined(obj) || !IsDefined(menu) { return false; }
  if !menu.juggernautAffectObjects || RFC_IsMountedToVehicle(player) { return false; }

  // NPCs stay owned by the already-working AAA Trip OnLook path.
  let puppet: wref<ScriptedPuppet> = obj as ScriptedPuppet;
  if IsDefined(puppet) { return false; }

  let vehicle: wref<VehicleObject> = obj as VehicleObject;
  if IsDefined(vehicle) {
    return SPLAT_JuggernautApplyVehicleNativeContact(player, vehicle, menu);
  }

  let push: Float = menu.juggernautObjectPush;
  let vertical: Float = menu.juggernautObjectVertical;
  let radius: Float = menu.juggernautObjectRadius;

  if menu.juggernautMaxTestSensitivity {
    push = MaxF(push, 12000.0);
    if AbsF(vertical) < 800.0 { vertical = 800.0; }
    radius = MaxF(radius, 2.50);
  }

  return SPLAT_JuggernautObjectImpulse(
    obj,
    SPLAT_JuggernautDirectionFromPlayer(player, obj),
    push,
    vertical,
    radius
  );
}

// Native vehicle-impact lane. SPLAT intentionally ignores PlayerImpact in its
// normal vehicle system; Juggernaut alone opts back into it here. The original
// VehicleImpulses PlayerImpact bypass remains untouched for every other mode.
@wrapMethod(VehicleObject)
protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  let menu: ref<RFCModSettings> = SPLATSettingsRuntime.Menu();
  if !SPLAT_JuggernautModeActive(menu) || !IsDefined(evt) || !IsDefined(evt.attackData) {
    return result;
  }
  if !evt.attackData.HasFlag(hitFlag.VehicleImpact) {
    return result;
  }

  let instigator: ref<GameObject> = evt.attackData.GetInstigator();
  let player: wref<PlayerPuppet> = instigator as PlayerPuppet;
  if !IsDefined(player) {
    return result;
  }

  SPLAT_JuggernautApplyVehicleNativeContact(player, this, menu);
  return result;
}

// Native VehicleObject bump lane. This is independent of look targeting and
// is used as a second contact route for an on-foot V physically touching a
// car/bike. Vehicle-vs-vehicle bumps are ignored here to avoid unrelated cars
// being launched merely because V is nearby.
@wrapMethod(VehicleObject)
protected cb func OnVehicleBumpEvent(evt: ref<VehicleBumpEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  let menu: ref<RFCModSettings> = SPLATSettingsRuntime.Menu();
  if !SPLAT_JuggernautModeActive(menu) || !menu.juggernautAffectVehicles || !IsDefined(evt) {
    return result;
  }
  if IsDefined(evt.hitVehicle) {
    return result;
  }

  let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame())
    .GetLocalPlayerMainGameObject() as PlayerPuppet;
  if !IsDefined(player) || RFC_IsMountedToVehicle(player) {
    return result;
  }

  let delta: Vector4 = this.GetWorldPosition() - player.GetWorldPosition();
  let maxDist: Float = 3.25;
  if menu.juggernautMaxTestSensitivity { maxDist = 6.00; }
  if Vector4.Length(delta) > maxDist {
    return result;
  }

  SPLAT_JuggernautApplyVehicleNativeContact(player, this, menu);
  return result;
}

// Experimental generic physics-object contact lane. PhysicalCollisionEvent is
// the engine event used by destructible physics devices and exposes the other
// entity directly. We handle both delivery directions: event on V, or event on
// the prop with V as otherEntity. Objects with their own fully overriding
// collision callback may still bypass this base GameObject receiver.
@addMethod(GameObject)
protected cb func OnPhysicalCollisionEvent(evt: ref<PhysicalCollisionEvent>) -> Bool {
  if !IsDefined(evt) {
    return false;
  }

  let menu: ref<RFCModSettings> = SPLATSettingsRuntime.Menu();
  if !SPLAT_JuggernautModeActive(menu) {
    return false;
  }

  let player: wref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame())
    .GetLocalPlayerMainGameObject() as PlayerPuppet;
  if !IsDefined(player) || RFC_IsMountedToVehicle(player) {
    return false;
  }

  let other: ref<GameObject> = evt.otherEntity as GameObject;
  let target: ref<GameObject>;

  if this.IsPlayer() {
    target = other;
  } else if IsDefined(other) && other.IsPlayer() {
    target = this;
  } else {
    return false;
  }

  if !IsDefined(target) || target.IsPlayer() {
    return false;
  }

  let vehicle: wref<VehicleObject> = target as VehicleObject;
  if IsDefined(vehicle) {
    SPLAT_JuggernautApplyVehicleNativeContact(player, vehicle, menu);
    return false;
  }

  SPLAT_JuggernautApplyObjectNativeContact(player, target, menu);
  return false;
}

private func SPLAT_JuggernautStart(player: wref<PlayerPuppet>) -> Void {
  if !IsDefined(player) || player.splatJuggernautLoopStarted { return; }
  player.splatJuggernautLoopStarted = true;
  player.splatJuggernautLastPosValid = false;
  SPLAT_JuggernautSchedule(player, new SPLAT_JuggernautTickEvt(), 0.10);
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool = wrappedMethod();
  SPLAT_JuggernautStart(this);
  return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
  let result: Bool = wrappedMethod(ri);
  SPLAT_JuggernautStart(this);
  return result;
}
