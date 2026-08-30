module RealisticPush

// Authoritative runtime shutdown used by SPLAT and bundled companion lanes.
// RFC.Cfg() also maps an enabled Global Impulse Chance of zero to vanillaMode,
// so one test covers both user-facing master-off conditions.
public func RFC_SPLATRuntimeDisabled(c: RFCConfig) -> Bool {
  return c.vanillaMode;
}

public func RFC_SPLATRuntimeDisabledNow() -> Bool {
  return RFC_SPLATRuntimeDisabled(RFC.Cfg());
}

// Global suppression for Sandevistan/Kerenzikov/scripted slow motion.
// IsTimeDilationActive() is the engine-owned state used by the base game.
public func RFC_TimeDilationBlocksImpulses(obj: wref<GameObject>, c: RFCConfig) -> Bool {
  if RFC_SPLATRuntimeDisabled(c) { return true; }

  if !c.disableAllImpulsesDuringTimeDilation || !IsDefined(obj) {
    return false;
  }

  let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(obj.GetGame());
  return IsDefined(timeSystem) && timeSystem.IsTimeDilationActive();
}

public func RFC_TimeDilationBlocksImpulsesNow(obj: wref<GameObject>) -> Bool {
  if !IsDefined(obj) {
    return false;
  }
  return RFC_TimeDilationBlocksImpulses(obj, RFC.Cfg());
}
