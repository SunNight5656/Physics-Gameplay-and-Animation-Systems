module BikeVControlStandalone1600

// The menu's canonical motorcycle-animation switch lives in BVCModeConfig.
// Capture the mounted bike before vanilla death processing clears the mount,
// then perform the same single unmount/ragdoll handoff used by BVC itself.

@addField(NPCPuppet)
private let bvc_motorcycleDeathAnimationCutDone: Bool;

private func BVCCutMountedRiderDeathAnimation(
  rider: wref<NPCPuppet>,
  bike: wref<BikeObject>
) -> Void {
  let workspotSystem: ref<WorkspotGameSystem>;

  if !IsDefined(rider) || !IsDefined(bike) {
    return;
  }

  workspotSystem = GameInstance.GetWorkspotSystem(rider.GetGame());
  if IsDefined(workspotSystem) {
    workspotSystem.UnmountFromVehicle(bike, rider, true);
  }

  BVCSendNoDriver(bike);
  rider.QueueEvent(CreateForceRagdollEvent(n"BVC1606_MotorcycleDeathAnimationCut"));
}

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  let bike: wref<BikeObject> = BVCResolveMountedBike(this);
  let config: ref<BVCModeConfig>;
  let mode: Int32;
  let shouldCut: Bool = false;
  let result: Bool;

  if IsDefined(bike) {
    config = BVCGetActiveConfig(bike, mode);
    shouldCut = IsDefined(config)
      && config.killMotorcycleDeathAnimation
      && !this.bvc_motorcycleDeathAnimationCutDone;
  }

  result = wrappedMethod(evt);

  if shouldCut {
    this.bvc_motorcycleDeathAnimationCutDone = true;
    BVCCutMountedRiderDeathAnimation(this, bike);
  }

  return result;
}
