module RealisticPush


public func RFC_IsStealthOrFinisher(p: wref<NPCPuppet>) -> Bool {
  let bb: ref<IBlackboard>;

  if !IsDefined(p) { return false; }

  // Blackboard: workspot anim / pending behavior
  bb = p.GetPuppetStateBlackboard();
  if IsDefined(bb) && (
    bb.GetBool(GetAllBlackboardDefs().PuppetState.WorkspotAnimationInProgress) ||
    bb.GetBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior)
  ) {
    return true;
  }

  return false;
}

public func RFC_IsStealthOrFinisherEx(p: wref<NPCPuppet>, blackwallCountsAsStealth: Bool) -> Bool {
  if RFC_IsStealthOrFinisher(p) { return true; }
  if blackwallCountsAsStealth && RFC_IsBlackwallKill(p) {
    return true;
  }
  return false;
}

public func RFC_IsBlackwallKill(p: wref<NPCPuppet>) -> Bool {
  return IsDefined(p) && StatusEffectSystem.ObjectHasStatusEffectWithTag(p, n"Blackwall");
}

public func RFC_IsFinisherKill(p: wref<NPCPuppet>) -> Bool {
  if !IsDefined(p) || !IsDefined(p.rfc_lastAttack) { return false; }
  return p.rfc_lastAttack.HasFlag(hitFlag.FinisherTriggered);
}

public func RFC_Stealth_SchedForceRagdoll(p: wref<NPCPuppet>, delay: Float) -> Void {
  if RFC.Cfg().vanillaMode { return; }
  if !IsDefined(p) || RFC_TimeDilationBlocksImpulsesNow(p) { return; }

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(p.GetGame());
  if !IsDefined(ds) { return; }

  let d: Float = delay;
  if d < 0.001 { d = 0.001; }

  ds.DelayEvent(p, CreateForceRagdollEvent(n"RFC_stealth_force_ragdoll"), d + 0.00, false);
  ds.DelayEvent(p, CreateForceRagdollEvent(n"RFC_stealth_force_ragdoll"), d + 0.02, false);
  ds.DelayEvent(p, CreateForceRagdollEvent(n"RFC_stealth_force_ragdoll"), d + 0.05, false);
}
