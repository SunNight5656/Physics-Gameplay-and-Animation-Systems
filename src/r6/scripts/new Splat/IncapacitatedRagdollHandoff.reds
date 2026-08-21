module RealisticPush

// HandleDefeated() and OnDied() both call NPCPuppet.OnIncapacitated(). Hooking
// that shared lifecycle point catches the nonlethal ground state and the route
// that transitions from a defeated animation into death.
public class RFC_IncapacitatedLifecycleHandoffEvent extends Event {}

@wrapMethod(NPCPuppet)
protected func OnIncapacitated() -> Void {
  wrappedMethod();

  let cfg: RFCConfig = RFC.Cfg();

  // v1704: OnDied() also enters this lifecycle. Do not schedule SPLAT's
  // incapacitation ragdoll handoff over a selected Vanilla death animation.
  if RFC_AnyDeathAnimationOwnsLifecycle(this) {
    return;
  }
  if cfg.vanillaMode
    || RFC_TimeDilationBlocksImpulses(this, cfg)
    || !cfg.arcadeIncapRagdollEnabled
    || RFC_Explode_IsRecent(this)
    || RFC_IsVehicleContext(this)
    || this.IsRagdolling()
    || !ScriptedPuppet.CanRagdoll(this) {
    return;
  }

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(this.GetGame());
  if IsDefined(ds) {
    ds.DelayEvent(
      this,
      new RFC_IncapacitatedLifecycleHandoffEvent(),
      ClampF(cfg.arcadeIncapRagdollDelay, 0.0, 2.0),
      false
    );
  } else {
    this.QueueEvent(new RFC_IncapacitatedLifecycleHandoffEvent());
  }
}

@addMethod(NPCPuppet)
protected cb func OnRFC_IncapacitatedLifecycleHandoffEvent(
  evt: ref<RFC_IncapacitatedLifecycleHandoffEvent>
) -> Bool {
  if !IsDefined(evt) || RFC_Explode_IsRecent(this) || RFC_IsVehicleContext(this) {
    return true;
  }

  // A handoff queued by an earlier hit must not wake up during this selected
  // Vanilla weapon death and force the NPC into ragdoll.
  if RFC_AnyDeathAnimationOwnsLifecycle(this) {
    return true;
  }

  let cfg: RFCConfig = RFC.Cfg();
  if cfg.vanillaMode
    || RFC_TimeDilationBlocksImpulses(this, cfg)
    || !cfg.arcadeIncapRagdollEnabled
    || this.IsRagdolling()
    || !ScriptedPuppet.CanRagdoll(this) {
    return true;
  }

  // One handoff is enough. Three wake pulses re-entered the engine's ragdoll
  // enable callback and could continually re-arm SPLAT's body-part events.
  this.QueueEvent(CreateForceRagdollEvent(n"Splat_IncapacitatedLifecycleHandoff"));
  return true;
}
