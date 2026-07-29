module RealisticPush

// v10: seated vehicle occupant reaction guard
//
// Pipeline finding:
// - NPCPuppet.OnHit must be allowed to run so direct bullets can damage/kill a
//   driver/passenger.
// - The ugly pop-through-door happens later when HitReactionComponent receives
//   NewHitDataEvent and queues death/unconscious force-ragdoll + ragdoll impulse
//   while the vehicle seat/workspot still owns the puppet.
//
// This guard lets damage/death and the normal seated reaction run, while the
// physical-impulse wrapper removes the push that can launch the puppet.
// VehicleObject.OnHit is not touched, so car/window/body arcade impulse still works.

@wrapMethod(HitReactionComponent)
protected cb func OnSetNewHitReactionBehaviorData(evt: ref<NewHitDataEvent>) -> Bool {
  let c = RFC.Cfg();

  if c.vanillaMode {
    return wrappedMethod(evt);
  }

  if c.killImpulsesVehiclesOnly && IsDefined(this.m_ownerNPC) && RFC_IsVehicleContext(this.m_ownerNPC) {
    // Clear accumulated physical push, but keep the vanilla reaction callback.
    // Swallowing this entire callback also swallowed the seated death animation.
    this.m_cumulatedPhysicalImpulse = 0.0;
    this.m_ragdollImpulse = 0.0;
  }

  return wrappedMethod(evt);
}
