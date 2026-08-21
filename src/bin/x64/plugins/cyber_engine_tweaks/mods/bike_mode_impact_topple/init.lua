-- SPLAT + Bike V Control combined build
-- BVC1604 REDscript remains active, but SPLAT Native Settings is the only
-- motorcycle settings UI and mode owner.
spdlog.info("[BVC1604] Standalone Native Settings UI disabled; controlled by SPLAT")
return {
  title = "Bike V Control + Impact",
  version = 1604,
  standalone = false,
  controlledBy = "SPLAT Native Settings"
}
