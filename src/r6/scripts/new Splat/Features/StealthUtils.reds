module RealisticPush

// Special death-animation classification must survive the lethal OnHit ->
// OnDeath handoff. Several Blackwall effects replace or remove their upload
// status while the final attack is being processed, so checking one live tag
// only inside OnDeath is not reliable.
@addField(NPCPuppet) public let rfc_blackwallKillArmed: Bool;
@addField(NPCPuppet) public let rfc_finisherKillArmed: Bool;
@addField(NPCPuppet) public let rfc_stealthKillArmed: Bool;

public class RFC_SpecialAnimationReleaseEvent extends Event {}

private func RFC_AttackRecordEquals(ad: ref<AttackData>, recordID: TweakDBID) -> Bool {
  if !IsDefined(ad)
    || !IsDefined(ad.GetAttackDefinition())
    || !IsDefined(ad.GetAttackDefinition().GetRecord()) {
    return false;
  }

  return ad.GetAttackDefinition().GetRecord().GetID() == recordID;
}

public func RFC_IsBlackwallAttack(ad: ref<AttackData>) -> Bool {
  if !IsDefined(ad) {
    return false;
  }

  // HauntedKill is carried by the native Blackwall force-kill attack. Keep
  // the record checks as explicit coverage for the normal, boss, and DOT
  // variants found in the shipped TweakDB.
  return ad.HasFlag(hitFlag.HauntedKill)
    || RFC_AttackRecordEquals(ad, t"Attacks.BlackwallHackAttack")
    || RFC_AttackRecordEquals(ad, t"Attacks.BossBlackwallAttack")
    || RFC_AttackRecordEquals(ad, t"Attacks.BlackWallAttack");
}

private func RFC_HasBlackwallStatus(p: wref<NPCPuppet>) -> Bool {
  if !IsDefined(p) {
    return false;
  }

  return StatusEffectSystem.ObjectHasStatusEffectWithTag(p, n"Blackwall")
    || StatusEffectSystem.ObjectHasStatusEffectWithTag(p, n"BlackWallHack")
    || StatusEffectSystem.ObjectHasStatusEffectWithTag(p, n"BlackwallBrainMeltDeathAnimation")
    || StatusEffectSystem.ObjectHasStatusEffectWithTag(p, n"ChimeraBlackWall")
    || StatusEffectSystem.ObjectHasStatusEffectWithTag(p, n"BlackWallUploadActive")
    || StatusEffectSystem.ObjectHasStatusEffect(p, t"BaseStatusEffect.SoMi_Q306_BlackwallHackQuestForceKill")
    || StatusEffectSystem.ObjectHasStatusEffect(p, t"BaseStatusEffect.HauntedGunBlackWallForceKill")
    || StatusEffectSystem.ObjectHasStatusEffect(p, t"BaseStatusEffect.HauntedBlackwallForceKill")
    || StatusEffectSystem.ObjectHasStatusEffect(p, t"BaseStatusEffect.HauntedBlackwallAfterKill")
    || StatusEffectSystem.ObjectHasStatusEffect(p, t"BaseStatusEffect.BossHauntedBlackwallHackForceKill");
}

private func RFC_IsFinisherAttack(ad: ref<AttackData>) -> Bool {
  return IsDefined(ad)
    && (
      ad.HasFlag(hitFlag.FinisherTriggered)
      || RFC_AttackRecordEquals(ad, t"Attacks.Finisher_Fake_Attack")
    );
}

private func RFC_IsStealthAttack(ad: ref<AttackData>) -> Bool {
  return IsDefined(ad)
    && (
      ad.HasFlag(hitFlag.SilentKillModifier)
      || ad.HasFlag(hitFlag.StealthHit)
    );
}

public func RFC_ClearSpecialAnimationContext(p: wref<NPCPuppet>) -> Void {
  if !IsDefined(p) {
    return;
  }

  p.rfc_blackwallKillArmed = false;
  p.rfc_finisherKillArmed = false;
  p.rfc_stealthKillArmed = false;
}

public func RFC_CaptureSpecialAnimationContext(p: wref<NPCPuppet>, ad: ref<AttackData>) -> Void {
  if !IsDefined(p) {
    return;
  }

  RFC_ClearSpecialAnimationContext(p);

  // Blackwall must win over the generic workspot/pending-behavior detector
  // used by remote takedowns and synchronized stealth animations.
  if RFC_IsBlackwallAttack(ad) || RFC_HasBlackwallStatus(p) {
    p.rfc_blackwallKillArmed = true;
    return;
  }

  if RFC_IsFinisherAttack(ad) {
    p.rfc_finisherKillArmed = true;
    return;
  }

  if RFC_IsStealthAttack(ad) || RFC_IsStealthOrFinisher(p) {
    p.rfc_stealthKillArmed = true;
  }
}

public func RFC_SpecialAnimationRestoreRequested(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  if !IsDefined(p) {
    return false;
  }

  return (RFC_IsBlackwallKill(p) && c.restoreBlackwallAnimations)
    || (RFC_IsFinisherKill(p) && c.restoreFinisherAnimations)
    || (RFC_IsStealthKill(p) && c.restoreStealthKillAnimations);
}

public func RFC_ArmRestoredSpecialAnimation(p: wref<NPCPuppet>, releaseDelay: Float) -> Void {
  if !IsDefined(p) {
    return;
  }

  // These are the native gates read while the lethal hit selects Death versus
  // ForcedRagdoll. Restoring them only after wrappedMethod() is too late.
  p.SetSkipDeathAnimation(false);
  NPCPuppet.ChangeForceRagdollOnDeath(p, false);
  p.rfc_splatDeathAnimationActive = true;

  let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(p.GetGame());
  if IsDefined(ds) {
    let evt: ref<RFC_SpecialAnimationReleaseEvent> = new RFC_SpecialAnimationReleaseEvent();
    ds.DelayEvent(p, evt, MaxF(6.0, releaseDelay + 1.0), false);
  }
}

@addMethod(NPCPuppet)
protected cb func OnRFC_SpecialAnimationReleaseEvent(evt: ref<RFC_SpecialAnimationReleaseEvent>) -> Bool {
  this.rfc_splatDeathAnimationActive = false;
  RFC_ClearSpecialAnimationContext(this);
  return true;
}


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
  return IsDefined(p)
    && (
      p.rfc_blackwallKillArmed
      || RFC_IsBlackwallAttack(p.rfc_lastAttack)
      || RFC_HasBlackwallStatus(p)
    );
}

public func RFC_IsFinisherKill(p: wref<NPCPuppet>) -> Bool {
  return IsDefined(p)
    && (
      p.rfc_finisherKillArmed
      || RFC_IsFinisherAttack(p.rfc_lastAttack)
    );
}

public func RFC_IsStealthKill(p: wref<NPCPuppet>) -> Bool {
  return IsDefined(p)
    && !RFC_IsBlackwallKill(p)
    && !RFC_IsFinisherKill(p)
    && (
      p.rfc_stealthKillArmed
      || RFC_IsStealthAttack(p.rfc_lastAttack)
      || RFC_IsStealthOrFinisher(p)
    );
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
