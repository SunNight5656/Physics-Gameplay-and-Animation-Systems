module RealisticPush

// Global suppression for Sandevistan/Kerenzikov/scripted slow motion.
// IsTimeDilationActive() is the engine-owned state used by the base game.
public func RFC_TimeDilationBlocksImpulses(obj: wref<GameObject>, c: RFCConfig) -> Bool {
  // Vanilla is a global SPLAT runtime kill-switch.
  if c.vanillaMode { return true; }

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
