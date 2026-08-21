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

private func RFC_MotorcycleDeathAnim_PrepareDeath(
  p: wref<NPCPuppet>,
  bike: wref<BikeObject>,
  cfg: RFCConfig
) -> Void {
  if !IsDefined(p) {
    return;
  };

  // v9.0 ordering fix:
  // This runs BEFORE wrapped OnDeath so vanilla never gets first ownership of
  // an upright, still-AI-driven motorcycle rider death.
  if IsDefined(bike) {
    p.smbtf_lastMountedBike = bike;
    p.smbtf_lastMountedBikeTime = EngineTime.ToFloat(
      GameInstance.GetSimTime(p.GetGame())
    );

    // Stop the bike's driver AI before vanilla death processing.
    RFC_VehStopDeadBikeDriverAI(bike);

    // Disable the two balance helpers immediately instead of waiting for the
    // queued AI events / native knockover receiver.
    bike.EnableAirControl(false);
    bike.EnableTiltControl(false);

    // Begin the motorcycle knockover before vanilla finishes the NPC death.
    SMBTF_PrepareMountedRiderDeathBike(p, bike);

    // Remove the rider from the workspot before wrapped OnDeath so the seat is
    // no longer treated as the rider's support surface during death resolution.
    let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(p.GetGame());
    if IsDefined(ws) {
      ws.UnmountFromVehicle(bike, p, true);
    }
  }
}

private func RFC_MotorcycleDeathAnim_FinishDeath(
  p: wref<NPCPuppet>
) -> Void {
  if !IsDefined(p) {
    return;
  };

  // Exactly one rider ragdoll request, AFTER vanilla death has processed the
  // already-unmounted rider.
  p.QueueEvent(CreateForceRagdollEvent(n"Splat_MotorcycleDeathAnimCut"));
}

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  let cfg: RFCConfig = RFC.Cfg();
  let shouldCutMotorcycleAnim: Bool;
  let mountedBike: wref<BikeObject>;
  let result: Bool;

  // Capture the strict motorcycle before vanilla death can clear the mount.
  shouldCutMotorcycleAnim = !cfg.vanillaMode
    && !this.rfc_vanillaDeathAnimArmed
    && cfg.killMotorcycleDeathAnim
    && !this.rfc_motorcycleDeathAnimCutDone
    && RFC_MotorcycleDeathAnim_IsMotoContext(this);

  if shouldCutMotorcycleAnim {
    mountedBike = RFC_GetMountedVehicle(this) as BikeObject;

    // Mark first to protect against re-entrant death handling.
    this.rfc_motorcycleDeathAnimCutDone = true;

    // CRITICAL: prepare bike + unmount BEFORE vanilla death processing.
    RFC_MotorcycleDeathAnim_PrepareDeath(this, mountedBike, cfg);
  }

  result = wrappedMethod(evt);

  if shouldCutMotorcycleAnim {
    // Existing SPLAT motorcycle-death path remains the sole rider ragdoll owner.
    RFC_MotorcycleDeathAnim_FinishDeath(this);
  }

  return result;
}
