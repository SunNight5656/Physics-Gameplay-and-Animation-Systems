module RealisticPush

// Random Impulses V139
// One profile is rolled per NPC death. A single 0..1 value per category keeps
// every Min/Max pair internally consistent for that NPC instead of changing
// strength again on every delayed pulse.

@addField(NPCPuppet) public let rfc_randomProfileSeeded: Bool;
@addField(NPCPuppet) public let rfc_randomProfileActive: Bool;
@addField(NPCPuppet) public let rfc_randomAllowHead: Bool;
@addField(NPCPuppet) public let rfc_randomAllowBody: Bool;
@addField(NPCPuppet) public let rfc_randomAllowShoulderWaist: Bool;
@addField(NPCPuppet) public let rfc_randomAllowSituational: Bool;
@addField(NPCPuppet) public let rfc_randomHeadT: Float;
@addField(NPCPuppet) public let rfc_randomBodyT: Float;
@addField(NPCPuppet) public let rfc_randomShoulderWaistT: Float;
@addField(NPCPuppet) public let rfc_randomSituationalT: Float;

public func RFC_RandomResetProfile(p: wref<NPCPuppet>) -> Void {
  if !IsDefined(p) { return; }
  p.rfc_randomProfileSeeded = false;
  p.rfc_randomProfileActive = false;
  p.rfc_randomAllowHead = true;
  p.rfc_randomAllowBody = true;
  p.rfc_randomAllowShoulderWaist = true;
  p.rfc_randomAllowSituational = true;
}

private func RFC_RandomRollPct(pct: Float) -> Bool {
  let clamped: Float = ClampF(pct, 0.0, 100.0);
  if clamped <= 0.0 { return false; }
  if clamped >= 100.0 { return true; }
  return RandRangeF(0.0, 100.0) < clamped;
}

private func RFC_RandomCategoryEnabled(c: RFCConfig, category: Int32) -> Bool {
  let hs: ref<HIS_Settings>;
  let gs: ref<GS_Settings>;

  if category == 0 {
    hs = SPLATSettingsRuntime.Head();
    return IsDefined(hs) && (hs.enabled || hs.enableRebound || hs.backEnabled || hs.enableBackRebound);
  }
  if category == 1 {
    gs = SPLATSettingsRuntime.Body();
    return IsDefined(gs) && gs.enabled;
  }
  if category == 2 {
    return c.shoulderHipFallsEnabled
      && (c.shoulderHipEarlyFallEnabled || c.shoulderHipImpactFallEnabled);
  }
  if category == 3 {
    return c.standEnabled || c.runEnabled || c.walkEnabled
      || c.wsStandEnabled || c.cowerEnabled || c.stairsEnabled;
  }
  return false;
}

private func RFC_RandomCanDisable(c: RFCConfig, category: Int32) -> Bool {
  if !RFC_RandomCategoryEnabled(c, category) { return false; }
  if category == 0 { return c.randomCanDisableHead; }
  if category == 1 { return c.randomCanDisableBody; }
  if category == 2 { return c.randomCanDisableShoulderWaist; }
  if category == 3 { return c.randomCanDisableSituational; }
  return false;
}

private func RFC_RandomSetAllowed(p: wref<NPCPuppet>, category: Int32, allowed: Bool) -> Void {
  if category == 0 { p.rfc_randomAllowHead = allowed; return; }
  if category == 1 { p.rfc_randomAllowBody = allowed; return; }
  if category == 2 { p.rfc_randomAllowShoulderWaist = allowed; return; }
  if category == 3 { p.rfc_randomAllowSituational = allowed; return; }
}

public func RFC_RandomEnsureProfile(p: wref<NPCPuppet>, c: RFCConfig) -> Void {
  let eligible: Int32 = 0;
  let maxDisabled: Int32;
  let disabled: Int32 = 0;
  let start: Int32;
  let i: Int32 = 0;
  let category: Int32;

  if !IsDefined(p) || p.rfc_randomProfileSeeded { return; }

  p.rfc_randomProfileSeeded = true;
  p.rfc_randomProfileActive = c.randomImpulsesEnabled && RFC_RandomRollPct(c.randomImpulseChancePct);
  p.rfc_randomAllowHead = true;
  p.rfc_randomAllowBody = true;
  p.rfc_randomAllowShoulderWaist = true;
  p.rfc_randomAllowSituational = true;
  p.rfc_randomHeadT = RandRangeF(0.0, 1.0);
  p.rfc_randomBodyT = RandRangeF(0.0, 1.0);
  p.rfc_randomShoulderWaistT = RandRangeF(0.0, 1.0);
  p.rfc_randomSituationalT = RandRangeF(0.0, 1.0);

  if !p.rfc_randomProfileActive || !c.randomDisableGroupsEnabled { return; }

  if RFC_RandomCanDisable(c, 0) { eligible += 1; }
  if RFC_RandomCanDisable(c, 1) { eligible += 1; }
  if RFC_RandomCanDisable(c, 2) { eligible += 1; }
  if RFC_RandomCanDisable(c, 3) { eligible += 1; }

  // Always preserve at least one category from the user's disable pool.
  maxDisabled = c.randomMaxDisabledGroups;
  if maxDisabled > eligible - 1 { maxDisabled = eligible - 1; }
  if maxDisabled <= 0 { return; }

  // Random starting category avoids always favoring Head/Body when the cap is hit.
  start = RandRange(0, 4);
  while i < 4 && disabled < maxDisabled {
    category = start + i;
    if category >= 4 { category -= 4; }

    if RFC_RandomCanDisable(c, category)
      && RFC_RandomRollPct(c.randomDisableChancePct) {
      RFC_RandomSetAllowed(p, category, false);
      disabled += 1;
    }
    i += 1;
  }
}

private func RFC_RandomRangeWithT(minV: Float, maxV: Float, t: Float) -> Float {
  let lo: Float = minV;
  let hi: Float = maxV;
  if hi < lo {
    lo = maxV;
    hi = minV;
  }
  if AbsF(hi - lo) <= 0.0001 { return lo; }
  return lo + ((hi - lo) * ClampF(t, 0.0, 1.0));
}

public func RFC_RandomAllowHead(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  RFC_RandomEnsureProfile(p, c);
  if !p.rfc_randomProfileActive || !c.randomDisableGroupsEnabled { return true; }
  return p.rfc_randomAllowHead;
}

public func RFC_RandomAllowBody(p: wref<NPCPuppet>, c: RFCConfig) -> Bool {
  RFC_RandomEnsureProfile(p, c);
  if !p.rfc_randomProfileActive || !c.randomDisableGroupsEnabled { return true; }
  return p.rfc_randomAllowBody;
}

public func RFC_RandomHeadValue(p: wref<NPCPuppet>, c: RFCConfig, minV: Float, maxV: Float) -> Float {
  RFC_RandomEnsureProfile(p, c);
  if p.rfc_randomProfileActive && c.randomPoolHead {
    return RFC_RandomRangeWithT(minV, maxV, p.rfc_randomHeadT);
  }
  return maxV;
}

public func RFC_RandomBodyValue(p: wref<NPCPuppet>, c: RFCConfig, minV: Float, maxV: Float) -> Float {
  RFC_RandomEnsureProfile(p, c);
  if p.rfc_randomProfileActive && c.randomPoolBody {
    return RFC_RandomRangeWithT(minV, maxV, p.rfc_randomBodyT);
  }
  return maxV;
}

private func RFC_RandomShoulderWaistValue(p: wref<NPCPuppet>, c: RFCConfig, minV: Float, maxV: Float) -> Float {
  RFC_RandomEnsureProfile(p, c);
  if p.rfc_randomProfileActive && c.randomPoolShoulderWaist {
    return RFC_RandomRangeWithT(minV, maxV, p.rfc_randomShoulderWaistT);
  }
  return maxV;
}

private func RFC_RandomSituationalValue(p: wref<NPCPuppet>, c: RFCConfig, minV: Float, maxV: Float) -> Float {
  RFC_RandomEnsureProfile(p, c);
  if p.rfc_randomProfileActive && c.randomPoolSituational {
    return RFC_RandomRangeWithT(minV, maxV, p.rfc_randomSituationalT);
  }
  // Situational Min/Max is an intrinsic range, not a dependency on the
  // optional global random-group system.
  return RFC_RandomRangeWithT(minV, maxV, RandF());
}

// Returns a temporary per-NPC copy. Saved sliders are never changed.
public func RFC_RandomizeConfig(p: wref<NPCPuppet>, c: RFCConfig) -> RFCConfig {
  if !IsDefined(p) { return c; }
  RFC_RandomEnsureProfile(p, c);
  if !p.rfc_randomProfileActive { return c; }

  if c.randomDisableGroupsEnabled && !p.rfc_randomAllowShoulderWaist {
    c.shoulderHipFallsEnabled = false;
    c.shoulderHipEarlyFallEnabled = false;
    c.shoulderHipImpactFallEnabled = false;
  } else if c.randomPoolShoulderWaist {
    c.shoulderHipEarlyShoulderStrength = RFC_RandomShoulderWaistValue(p, c, c.shoulderHipEarlyShoulderStrengthMin, c.shoulderHipEarlyShoulderStrength);
    c.shoulderHipEarlyHipStrength = RFC_RandomShoulderWaistValue(p, c, c.shoulderHipEarlyHipStrengthMin, c.shoulderHipEarlyHipStrength);
    c.shoulderHipImpactShoulderStrength = RFC_RandomShoulderWaistValue(p, c, c.shoulderHipImpactShoulderStrengthMin, c.shoulderHipImpactShoulderStrength);
    c.shoulderHipImpactHipStrength = RFC_RandomShoulderWaistValue(p, c, c.shoulderHipImpactHipStrengthMin, c.shoulderHipImpactHipStrength);
  }

  if c.randomDisableGroupsEnabled && !p.rfc_randomAllowSituational {
    c.standEnabled = false;
    c.runEnabled = false;
    c.walkEnabled = false;
    c.wsStandEnabled = false;
    c.cowerEnabled = false;
    c.stairsEnabled = false;
  } else {
    c.st_forward = RFC_RandomSituationalValue(p, c, c.st_forwardMin, c.st_forward);
    c.st_downHead = RFC_RandomSituationalValue(p, c, c.st_downHeadMin, c.st_downHead);
    c.st_downChest = RFC_RandomSituationalValue(p, c, c.st_downChestMin, c.st_downChest);
    c.st_downPelvis = RFC_RandomSituationalValue(p, c, c.st_downPelvisMin, c.st_downPelvis);
    c.st_kneeDown = RFC_RandomSituationalValue(p, c, c.st_kneeDownMin, c.st_kneeDown);

    c.run_forward = RFC_RandomSituationalValue(p, c, c.run_forwardMin, c.run_forward);
    c.run_downHead = RFC_RandomSituationalValue(p, c, c.run_downHeadMin, c.run_downHead);
    c.run_downChest = RFC_RandomSituationalValue(p, c, c.run_downChestMin, c.run_downChest);
    c.run_downPelvis = RFC_RandomSituationalValue(p, c, c.run_downPelvisMin, c.run_downPelvis);
    c.run_kneeDown = RFC_RandomSituationalValue(p, c, c.run_kneeDownMin, c.run_kneeDown);

    c.stair_forward = RFC_RandomSituationalValue(p, c, c.stair_forwardMin, c.stair_forward);
    c.stair_headFwd = RFC_RandomSituationalValue(p, c, c.stair_headFwdMin, c.stair_headFwd);
    c.stair_downHead = RFC_RandomSituationalValue(p, c, c.stair_downHeadMin, c.stair_downHead);
    c.stair_chestFwd = RFC_RandomSituationalValue(p, c, c.stair_chestFwdMin, c.stair_chestFwd);
    c.stair_downChest = RFC_RandomSituationalValue(p, c, c.stair_downChestMin, c.stair_downChest);
    c.stair_kneeDown = RFC_RandomSituationalValue(p, c, c.stair_kneeDownMin, c.stair_kneeDown);
    c.stair_downPelvis = RFC_RandomSituationalValue(p, c, c.stair_downPelvisMin, c.stair_downPelvis);
    c.stair_vSlamZ = RFC_RandomSituationalValue(p, c, c.stair_vSlamZMin, c.stair_vSlamZ);
    c.stair_brakeFwd = RFC_RandomSituationalValue(p, c, c.stair_brakeFwdMin, c.stair_brakeFwd);
    c.stair_plankHeadDown = RFC_RandomSituationalValue(p, c, c.stair_plankHeadDownMin, c.stair_plankHeadDown);
    c.stair_plankChestDown = RFC_RandomSituationalValue(p, c, c.stair_plankChestDownMin, c.stair_plankChestDown);
    c.stair_plankPelvisDown = RFC_RandomSituationalValue(p, c, c.stair_plankPelvisDownMin, c.stair_plankPelvisDown);
    c.stair_plankFwd = RFC_RandomSituationalValue(p, c, c.stair_plankFwdMin, c.stair_plankFwd);
    c.stair_plankBrakeFwd = RFC_RandomSituationalValue(p, c, c.stair_plankBrakeFwdMin, c.stair_plankBrakeFwd);

    c.cow.headDown = RFC_RandomSituationalValue(p, c, c.cow.headDownMin, c.cow.headDown);
    c.cow.chestDown = RFC_RandomSituationalValue(p, c, c.cow.chestDownMin, c.cow.chestDown);
    c.cow.pelvisDown = RFC_RandomSituationalValue(p, c, c.cow.pelvisDownMin, c.cow.pelvisDown);
    c.cow.kneeDown = RFC_RandomSituationalValue(p, c, c.cow.kneeDownMin, c.cow.kneeDown);
    c.cow.antiTuckZ = RFC_RandomSituationalValue(p, c, c.cow.antiTuckZMin, c.cow.antiTuckZ);

    c.wsStand.chestFwd = RFC_RandomSituationalValue(p, c, c.wsStand.chestFwdMin, c.wsStand.chestFwd);
    c.wsStand.chestDown = RFC_RandomSituationalValue(p, c, c.wsStand.chestDownMin, c.wsStand.chestDown);
    c.wsStand.pelvisFwd = RFC_RandomSituationalValue(p, c, c.wsStand.pelvisFwdMin, c.wsStand.pelvisFwd);
    c.wsStand.pelvisDown = RFC_RandomSituationalValue(p, c, c.wsStand.pelvisDownMin, c.wsStand.pelvisDown);
    c.wsStand.kneeDown = RFC_RandomSituationalValue(p, c, c.wsStand.kneeDownMin, c.wsStand.kneeDown);
  }

  return c;
}
