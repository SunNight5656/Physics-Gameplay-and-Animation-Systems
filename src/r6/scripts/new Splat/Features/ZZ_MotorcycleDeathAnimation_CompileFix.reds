module RealisticPush

// ─────────────────────────────────────────────────────────────────────────────
// Motorcycle Death Animation Cut
// ─────────────────────────────────────────────────────────────────────────────
// Purpose:
// - Keep the existing car/vehicle safety gates intact.
// - Let motorcycle riders skip the death animation and go straight into ragdoll.
// - The Mod Settings toggle is NOT declared in this feature file anymore.
// - Menu field belongs in RFCModSettings inside SPLATSettingsData.reds.
// - Types.reds copies that menu value into RFCConfig, like the rest of SPLAT.
//
// Vehicle type rule:
// - A live mounted VehicleObject must downcast to BikeObject.
// - If the mount is already unavailable, require both the cached Moto workspot
//   kind and motorcycle-specific runtime animation tags.

@addField(NPCPuppet)
private let rfc_motorcycleDeathAnimCutDone: Bool;

private func RFC_MotorcycleDeathAnim_HasTags(p: wref<ScriptedPuppet>, tags: array<CName>) -> Bool {
  if !IsDefined(p) {
    return false;
  };
  return p.HasRuntimeAnimsetTags(tags);
}

private func RFC_MotorcycleDeathAnim_HasMotoTags(p: wref<ScriptedPuppet>) -> Bool {
  let tags: array<CName>;

  if !IsDefined(p) {
    return false;
  };

  ArrayPush(tags, n"motorcycle");
  ArrayPush(tags, n"moto");
  ArrayPush(tags, n"bike");
  ArrayPush(tags, n"veh_bike");
  ArrayPush(tags, n"veh_moto");
  ArrayPush(tags, n"veh_motorcycle");
  ArrayPush(tags, n"moto_mount");
  ArrayPush(tags, n"bike_mount");
  ArrayPush(tags, n"moto_dismount");
  ArrayPush(tags, n"bike_dismount");

  return RFC_MotorcycleDeathAnim_HasTags(p, tags);
}

private func RFC_MotorcycleDeathAnim_IsMotoContext(p: wref<ScriptedPuppet>) -> Bool {
  let np: wref<NPCPuppet>;
  let vehicle: wref<VehicleObject>;
  let bike: wref<BikeObject>;

  if !IsDefined(p) {
    return false;
  };

  np = p as NPCPuppet;
  if !IsDefined(np) {
    return false;
  };

  vehicle = RFC_GetMountedVehicle(np);
  if IsDefined(vehicle) {
    bike = vehicle as BikeObject;
    return IsDefined(bike);
  };

  // Wrapped death processing can occasionally remove the mount before another
  // OnDeath wrapper observes it. The fallback remains motorcycle-specific by
  // requiring both independent signals instead of treating unknown vehicles as bikes.
  return np.RFC_GetWSKindLastSeen() == 6 && RFC_MotorcycleDeathAnim_HasMotoTags(np);
}

private func RFC_MotorcycleDeathAnim_ForceCut(
  p: wref<NPCPuppet>,
  bike: wref<BikeObject>,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(p) {
    return;
  };

  // A direct rider bullet arms a side-specific bike topple before wrapped
  // damage can erase the mount. Consume that exact handoff here: DriverDead,
  // NoDriver, one immediate unmount, and one signed bike topple.
  let coordinatedTopple: Bool = RFC_VehConsumeArcadeRiderBikeTopple(p, true, cfg);

  // If VehicleObject.OnHit already toppled the bike, there is no rider-side
  // latch to consume. Still send the missing AI shutdown events and unmount
  // exactly once so an empty motorcycle cannot continue its traffic task.
  if IsDefined(bike) && !coordinatedTopple {
    RFC_VehStopDeadBikeDriverAI(bike);
    let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(p.GetGame());
    if IsDefined(ws) {
      ws.UnmountFromVehicle(bike, p, true);
    }
  }

  // One directionless wake is the whole death-animation handoff. Repeating it
  // at 0.03/0.08/0.16 restarted the rider pose and produced the visible pop.
  p.QueueEvent(CreateForceRagdollEvent(n"Splat_MotorcycleDeathAnimCut"));
}

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  let cfg: RFCConfig = RFC.Cfg();
  let shouldCutMotorcycleAnim: Bool;
  let mountedBike: wref<BikeObject>;
  let result: Bool;

  // Capture the strict vehicle type before vanilla death processing can clear
  // the NPC's mounting relationship.
  shouldCutMotorcycleAnim = !cfg.vanillaMode
    && cfg.killMotorcycleDeathAnim
    && !this.rfc_motorcycleDeathAnimCutDone
    && RFC_MotorcycleDeathAnim_IsMotoContext(this);
  if shouldCutMotorcycleAnim {
    mountedBike = RFC_GetMountedVehicle(this) as BikeObject;
  }

  result = wrappedMethod(evt);

  if !shouldCutMotorcycleAnim {
    return result;
  };

  this.rfc_motorcycleDeathAnimCutDone = true;
  RFC_MotorcycleDeathAnim_ForceCut(this, mountedBike, cfg);

  return result;
}
