-- Bike V Control Standalone 1600
-- Native Settings UI and persistent per-mode settings.

local TAB = "/bikeModeImpactTopple"
local GLOBAL = TAB .. "/global"
local BRIDGE_VERSION = 1604

local MODE_LABELS = {
  "Realism Custom",
  "Realism Plus",
  "Clint Eastwood Old West",
  "Arnold / Arcade",
  "Vanilla"
}

local MODE_KEYS = {
  "realismCustom",
  "realismPlus",
  "dirtyHarry",
  "arnoldArcade",
  "vanilla"
}

local nativeSettings = nil
local livePlayer = nil
local initialized = false

local function scriptDir()
  local ok, info = pcall(function()
    return debug.getinfo(1, "S")
  end)

  if ok
    and info
    and type(info.source) == "string"
    and info.source:sub(1, 1) == "@" then
    return info.source:sub(2):match("^(.*[\\/])") or ""
  end

  return ""
end

local USER_FILE =
  scriptDir() .. "user_settings.json"

local defaults = {
  activeMode = 0,
  debugPopups = true,
  manualControllerEnabled = true,
  modes = {
    {
      enabled = true,
      bulletEnabled = true,
      bulletPlayerOnly = false,
      bulletChance = 100.0,
      bulletStrength = 3.8,
      vehicleImpactEnabled = true,
      vehicleImpactThreshold = 2.0,
      vehicleImpactChance = 100.0,
      vehicleImpactStrength = 4.0,
      worldImpactEnabled = true,
      worldImpactThreshold = 4.5,
      worldImpactChance = 100.0,
      worldImpactStrength = 4.0,
      riderKnockoffEnabled = true,
      impactDirectionFlip = false,
      toppleCooldown = 0.35,
      leanFallEnabled = true,
      leanFallAngle = 38.0,
      leanFallMinSpeed = 0.0,
      leanFallMaxSpeed = 100.0,
      leanFallBikeStrength = 3.8,
      playerGravityFallStrength = 8.0,
      pickupRecoveryEnabled = true
    },
    {
      enabled = true,
      bulletEnabled = true,
      bulletPlayerOnly = false,
      bulletChance = 100.0,
      bulletStrength = 4.2,
      vehicleImpactEnabled = true,
      vehicleImpactThreshold = 1.75,
      vehicleImpactChance = 100.0,
      vehicleImpactStrength = 4.6,
      worldImpactEnabled = true,
      worldImpactThreshold = 4.0,
      worldImpactChance = 100.0,
      worldImpactStrength = 4.6,
      riderKnockoffEnabled = true,
      impactDirectionFlip = false,
      toppleCooldown = 0.30,
      leanFallEnabled = true,
      leanFallAngle = 34.0,
      leanFallMinSpeed = 0.0,
      leanFallMaxSpeed = 100.0,
      leanFallBikeStrength = 4.2,
      playerGravityFallStrength = 8.0,
      pickupRecoveryEnabled = true
    },
    {
      enabled = true,
      bulletEnabled = true,
      bulletPlayerOnly = false,
      bulletChance = 100.0,
      bulletStrength = 4.8,
      vehicleImpactEnabled = true,
      vehicleImpactThreshold = 1.25,
      vehicleImpactChance = 100.0,
      vehicleImpactStrength = 5.2,
      worldImpactEnabled = true,
      worldImpactThreshold = 3.25,
      worldImpactChance = 100.0,
      worldImpactStrength = 5.0,
      riderKnockoffEnabled = true,
      impactDirectionFlip = false,
      toppleCooldown = 0.25,
      leanFallEnabled = true,
      leanFallAngle = 30.0,
      leanFallMinSpeed = 0.0,
      leanFallMaxSpeed = 100.0,
      leanFallBikeStrength = 4.8,
      playerGravityFallStrength = 8.5,
      pickupRecoveryEnabled = true
    },
    {
      enabled = true,
      bulletEnabled = true,
      bulletPlayerOnly = false,
      bulletChance = 100.0,
      bulletStrength = 6.5,
      vehicleImpactEnabled = true,
      vehicleImpactThreshold = 0.75,
      vehicleImpactChance = 100.0,
      vehicleImpactStrength = 7.0,
      worldImpactEnabled = true,
      worldImpactThreshold = 2.0,
      worldImpactChance = 100.0,
      worldImpactStrength = 7.0,
      riderKnockoffEnabled = true,
      impactDirectionFlip = false,
      toppleCooldown = 0.20,
      leanFallEnabled = true,
      leanFallAngle = 24.0,
      leanFallMinSpeed = 0.0,
      leanFallMaxSpeed = 100.0,
      leanFallBikeStrength = 6.5,
      playerGravityFallStrength = 9.0,
      pickupRecoveryEnabled = true
    },
    {
      enabled = false,
      bulletEnabled = false,
      bulletPlayerOnly = false,
      bulletChance = 0.0,
      bulletStrength = 0.0,
      vehicleImpactEnabled = false,
      vehicleImpactThreshold = 9999.0,
      vehicleImpactChance = 0.0,
      vehicleImpactStrength = 0.0,
      worldImpactEnabled = false,
      worldImpactThreshold = 9999.0,
      worldImpactChance = 0.0,
      worldImpactStrength = 0.0,
      riderKnockoffEnabled = false,
      impactDirectionFlip = false,
      toppleCooldown = 0.35,
      leanFallEnabled = false,
      leanFallAngle = 90.0,
      leanFallMinSpeed = 0.0,
      leanFallMaxSpeed = 0.0,
      leanFallBikeStrength = 0.0,
      playerGravityFallStrength = 0.0,
      pickupRecoveryEnabled = false
    }
  }
}

local config = nil

local function logi(value)
  spdlog.info(
    "[Bike V Control Standalone 1604] "
      .. tostring(value)
  )
end

local function loge(value)
  spdlog.error(
    "[Bike V Control Standalone 1604] "
      .. tostring(value)
  )
end

local function deepCopy(value)
  if type(value) ~= "table" then
    return value
  end

  local output = {}

  for key, item in pairs(value) do
    output[key] = deepCopy(item)
  end

  return output
end

local function merge(value, template)
  if type(value) ~= "table" then
    value = {}
  end

  for key, defaultValue in pairs(template) do
    if type(defaultValue) == "table" then
      value[key] =
        merge(value[key], defaultValue)
    elseif value[key] == nil then
      value[key] = defaultValue
    end
  end

  return value
end

local function loadSettings()
  local file = io.open(USER_FILE, "r")

  if not file then
    return deepCopy(defaults)
  end

  local raw = file:read("*a")
  file:close()

  local ok, decoded =
    pcall(json.decode, raw)

  if not ok or type(decoded) ~= "table" then
    loge(
      "Invalid user_settings.json; using defaults"
    )

    return deepCopy(defaults)
  end

  return merge(
    decoded,
    deepCopy(defaults)
  )
end

local function saveSettings()
  if type(config) ~= "table" then
    return false
  end

  local ok, raw =
    pcall(json.encode, config)

  if not ok then
    loge("Could not encode user settings")
    return false
  end

  local file, err =
    io.open(USER_FILE, "w")

  if not file then
    loge(
      "Could not write user settings: "
        .. tostring(err)
    )

    return false
  end

  file:write(raw)
  file:flush()
  file:close()

  return true
end

local function cn(value)
  return CName.new(value or "")
end

local function resolveBridge(playerHint)
  local player =
    playerHint or livePlayer

  if not player or not IsDefined(player) then
    local ok, current = pcall(function()
      return Game.GetPlayer()
    end)

    if ok then
      player = current
    end
  end

  if not player or not IsDefined(player) then
    livePlayer = nil
    return nil
  end

  local ok, version = pcall(function()
    return player:BVCGetBridgeVersion()
  end)

  if not ok
    or tonumber(version) ~= BRIDGE_VERSION then
    return nil
  end

  livePlayer = player
  return player
end

local function applyGlobal(playerHint)
  local player = resolveBridge(playerHint)

  if not player then
    return false
  end

  local mode =
    math.max(
      0,
      math.min(
        4,
        math.floor(config.activeMode or 0)
      )
    )

  local okMode, appliedMode = pcall(function()
    return player:BVCSetActiveMode(mode)
  end)

  if not okMode or appliedMode ~= true then
    return false
  end

  local okDebug, appliedDebug = pcall(function()
    return player:BVCSetGlobalBool(
      cn("debugPopups"),
      config.debugPopups == true
    )
  end)

  if not okDebug or appliedDebug ~= true then
    return false
  end

  local okManual, appliedManual = pcall(function()
    return player:BVCSetGlobalBool(
      cn("manualControllerEnabled"),
      config.manualControllerEnabled == true
    )
  end)

  return okManual and appliedManual == true
end

local function applyMode(modeIndex, playerHint)
  local player = resolveBridge(playerHint)

  if not player then
    return false
  end

  local mode =
    config.modes[modeIndex + 1]

  if type(mode) ~= "table" then
    return false
  end

  local boolNames = {
    "enabled",
    "bulletEnabled",
    "bulletPlayerOnly",
    "vehicleImpactEnabled",
    "worldImpactEnabled",
    "riderKnockoffEnabled",
    "impactDirectionFlip",
    "leanFallEnabled",
    "pickupRecoveryEnabled"
  }

  local floatNames = {
    "bulletChance",
    "bulletStrength",
    "vehicleImpactThreshold",
    "vehicleImpactChance",
    "vehicleImpactStrength",
    "worldImpactThreshold",
    "worldImpactChance",
    "worldImpactStrength",
    "toppleCooldown",
    "leanFallAngle",
    "leanFallMinSpeed",
    "leanFallMaxSpeed",
    "leanFallBikeStrength",
    "playerGravityFallStrength"
  }

  for _, name in ipairs(boolNames) do
    local ok, applied = pcall(function()
      return player:BVCSetModeBool(
        modeIndex,
        cn(name),
        mode[name] == true
      )
    end)

    if not ok or applied ~= true then
      return false
    end
  end

  for _, name in ipairs(floatNames) do
    local ok, applied = pcall(function()
      return player:BVCSetModeFloat(
        modeIndex,
        cn(name),
        tonumber(mode[name]) or 0.0
      )
    end)

    if not ok or applied ~= true then
      return false
    end
  end

  return true
end

local function applyAll(playerHint)
  local player = resolveBridge(playerHint)

  if not player then
    return false
  end

  if not applyGlobal(player) then
    return false
  end

  for modeIndex = 0, 4 do
    if not applyMode(modeIndex, player) then
      return false
    end
  end

  return true
end

local function setGlobal(name, value)
  config[name] = value
  saveSettings()

  local player = resolveBridge()

  if not player then
    return
  end

  if name == "activeMode" then
    pcall(function()
      player:BVCSetActiveMode(
        math.floor(value)
      )
    end)
  else
    pcall(function()
      player:BVCSetGlobalBool(
        cn(name),
        value == true
      )
    end)
  end
end

local function setModeBool(
  modeIndex,
  name,
  value
)
  local mode =
    config.modes[modeIndex + 1]

  mode[name] = value == true
  saveSettings()

  local player = resolveBridge()

  if player then
    pcall(function()
      player:BVCSetModeBool(
        modeIndex,
        cn(name),
        mode[name]
      )
    end)
  end
end

local function setModeFloat(
  modeIndex,
  name,
  value
)
  local mode =
    config.modes[modeIndex + 1]

  mode[name] =
    tonumber(value) or mode[name]

  saveSettings()

  local player = resolveBridge()

  if player then
    pcall(function()
      player:BVCSetModeFloat(
        modeIndex,
        cn(name),
        mode[name]
      )
    end)
  end
end

local function addSwitch(
  path,
  modeIndex,
  mode,
  defaultsMode,
  name,
  label,
  description,
  order
)
  nativeSettings.addSwitch(
    path,
    label,
    description,
    mode[name],
    defaultsMode[name],
    function(value)
      setModeBool(
        modeIndex,
        name,
        value
      )
    end,
    order
  )
end

local function addFloat(
  path,
  modeIndex,
  mode,
  defaultsMode,
  name,
  label,
  description,
  minimum,
  maximum,
  step,
  format,
  order
)
  nativeSettings.addRangeFloat(
    path,
    label,
    description,
    minimum,
    maximum,
    step,
    format,
    mode[name],
    defaultsMode[name],
    function(value)
      setModeFloat(
        modeIndex,
        name,
        value
      )
    end,
    order
  )
end

local function addModeControls(
  modeIndex,
  order
)
  local label =
    MODE_LABELS[modeIndex + 1]

  local key =
    MODE_KEYS[modeIndex + 1]

  local path =
    TAB .. "/" .. key

  local mode =
    config.modes[modeIndex + 1]

  local defaultsMode =
    defaults.modes[modeIndex + 1]

  nativeSettings.addSubcategory(
    path,
    label .. " — V + Bike Controls",
    order
  )

  local index = 1

  addSwitch(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "enabled",
    "Enable " .. label .. " Bike System",
    "Master switch for bullet, impact, V rider, lean fall, and pickup recovery behavior.",
    index
  )
  index = index + 1

  addSwitch(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "bulletEnabled",
    "Bullets Topple Motorcycles",
    "Applies to empty motorcycles, NPC riders, and V while mounted.",
    index
  )
  index = index + 1

  addSwitch(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "bulletPlayerOnly",
    "Player Bullets Only",
    "When enabled, NPC bullets cannot trigger motorcycle topples.",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "bulletChance",
    "Bullet Topple Chance",
    "Chance for a valid ranged/direct hit to trigger the topple actuator.",
    0.0,
    100.0,
    1.0,
    "%.0f",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "bulletStrength",
    "Bullet Topple Strength",
    "Mass-scaled motorcycle-local side force. 3.8 matches the working standalone value.",
    0.0,
    12.0,
    0.1,
    "%.1f",
    index
  )
  index = index + 1

  addSwitch(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "vehicleImpactEnabled",
    "Car / Vehicle Impacts Topple Bikes",
    "Qualifying VehicleBumpEvent collisions with another vehicle topple the bike and can remove the rider.",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "vehicleImpactThreshold",
    "Car Impact Threshold",
    "Minimum impact velocity change. Set to 0 for any reported contact, including when your vehicle owns the bump and the NPC motorcycle is only evt.hitVehicle.",
    0.0,
    30.0,
    0.25,
    "%.2f",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "vehicleImpactChance",
    "Car Impact Topple Chance",
    "Chance for a qualifying vehicle-to-bike collision to topple the motorcycle.",
    0.0,
    100.0,
    1.0,
    "%.0f",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "vehicleImpactStrength",
    "Car Impact Topple Strength",
    "Mass-scaled side force for vehicle-to-bike collisions.",
    0.0,
    12.0,
    0.1,
    "%.1f",
    index
  )
  index = index + 1

  addSwitch(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "worldImpactEnabled",
    "Wall / World Impacts Topple Bikes",
    "Qualifying impacts with walls and world geometry topple the bike and can remove V or an NPC rider.",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "worldImpactThreshold",
    "Wall Impact Threshold",
    "Minimum wall/world impact velocity change. Set to 0 for any reported contact.",
    0.0,
    30.0,
    0.25,
    "%.2f",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "worldImpactChance",
    "Wall Impact Topple Chance",
    "Chance for a qualifying wall/world collision to topple the motorcycle.",
    0.0,
    100.0,
    1.0,
    "%.0f",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "worldImpactStrength",
    "Wall Impact Topple Strength",
    "Mass-scaled side force for wall/world collisions.",
    0.0,
    12.0,
    0.1,
    "%.1f",
    index
  )
  index = index + 1

  addSwitch(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "riderKnockoffEnabled",
    "Impacts and Bullets Remove Riders",
    "NPCs use explicit Bumped unmount. V uses the native CollisionExiting state machine. This bypasses the minimum trigger without leaving V mounted.",
    index
  )
  index = index + 1

  addSwitch(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "impactDirectionFlip",
    "Reverse Collision Fall Side",
    "Flip the side derived from VehicleBumpEvent.hitNormal.",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "toppleCooldown",
    "Topple Cooldown",
    "Minimum seconds between topples on the same motorcycle.",
    0.0,
    3.0,
    0.05,
    "%.2f",
    index
  )
  index = index + 1

  addSwitch(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "leanFallEnabled",
    "V Falls From Excessive Lean",
    "Reads Vehicle.BikeTilt while V is driving. Crossing the selected angle topples the bike and drops V with gravity.",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "leanFallAngle",
    "V Lean Fall Angle",
    "Absolute BikeTilt angle that triggers V's lean fall.",
    5.0,
    90.0,
    1.0,
    "%.0f",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "leanFallMinSpeed",
    "V Lean Fall Minimum Speed",
    "Minimum absolute motorcycle speed for a lean fall.",
    0.0,
    100.0,
    0.5,
    "%.1f",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "leanFallMaxSpeed",
    "V Lean Fall Maximum Speed",
    "Maximum absolute motorcycle speed for a lean fall.",
    0.0,
    100.0,
    0.5,
    "%.1f",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "leanFallBikeStrength",
    "V Lean Fall Bike Strength",
    "Motorcycle side force when V exceeds the lean angle.",
    0.0,
    12.0,
    0.1,
    "%.1f",
    index
  )
  index = index + 1

  addFloat(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "playerGravityFallStrength",
    "V Downward Gravity Fall Strength",
    "Downward-only ragdoll impulse applied to V after unmounting. No sideways or upward launch is added.",
    0.0,
    30.0,
    0.5,
    "%.1f",
    index
  )
  index = index + 1

  addSwitch(
    path,
    modeIndex,
    mode,
    defaultsMode,
    "pickupRecoveryEnabled",
    "Restore Bike Controls When V Picks It Up",
    "On remount, repeatedly sends Exit Park, target tilt 0, air control ON, and tilt control ON while invalidating old shutdown pulses.",
    index
  )
end

local function buildMenu()
  nativeSettings =
    GetMod("nativeSettings")

  if not nativeSettings then
    loge("Native Settings UI is not installed")
    return false
  end

  nativeSettings.addTab(
    TAB,
    "Bike V Control + Impact"
  )

  nativeSettings.addSubcategory(
    GLOBAL,
    "Active Bike Mode",
    1
  )

  nativeSettings.addSelectorString(
    GLOBAL,
    "Bike Physics Mode",
    "Standalone selector. Each mode has independent motorcycle, V, lean, impact, and recovery settings.",
    MODE_LABELS,
    math.floor(config.activeMode or 0),
    defaults.activeMode,
    function(value)
      setGlobal(
        "activeMode",
        math.max(
          0,
          math.min(
            4,
            math.floor(value)
          )
        )
      )
    end,
    1
  )

  nativeSettings.addSwitch(
    GLOBAL,
    "Show Runtime Popups",
    "Shows which route fired, the selected mode, rider removal, and pickup recovery.",
    config.debugPopups,
    defaults.debugPopups,
    function(value)
      setGlobal(
        "debugPopups",
        value
      )
    end,
    2
  )

  nativeSettings.addSwitch(
    GLOBAL,
    "Enable Manual D-pad + Square Test",
    "D-pad Left/Right selects side. Square topples the targeted or currently ridden bike and applies the V rider behavior.",
    config.manualControllerEnabled,
    defaults.manualControllerEnabled,
    function(value)
      setGlobal(
        "manualControllerEnabled",
        value
      )
    end,
    3
  )

  nativeSettings.addButton(
    GLOBAL,
    "Restore All Standalone Defaults",
    "Restores all five mode configurations.",
    "RESTORE",
    4,
    function()
      config = deepCopy(defaults)
      saveSettings()
      applyAll()
      logi(
        "All defaults restored; reopen the tab to refresh displayed values"
      )
    end
  )

  addModeControls(0, 2)
  addModeControls(1, 3)
  addModeControls(2, 4)
  addModeControls(3, 5)
  addModeControls(4, 6)

  return true
end

local function handlePlayerReady(player)
  if not initialized
    or not player
    or not IsDefined(player) then
    return
  end

  livePlayer = player

  if applyAll(player) then
    logi("REDscript bridge connected")
  else
    loge("REDscript bridge not ready")
  end
end

registerForEvent("onInit", function()
  logi(
    "BUILD MARKER: BVC1604_SYMMETRIC_TOUCH_KNOCKOFF"
  )

  config = loadSettings()

  pcall(function()
    ObserveAfter(
      "PlayerPuppet",
      "OnGameAttached",
      function(player)
        handlePlayerReady(player)
      end
    )
  end)

  initialized = buildMenu()

  if not initialized then
    return
  end

  local ok, player = pcall(function()
    return Game.GetPlayer()
  end)

  if ok
    and player
    and IsDefined(player) then
    handlePlayerReady(player)
  end
end)

registerForEvent("onOverlayOpen", function()
  if not livePlayer
    or not IsDefined(livePlayer) then
    local ok, player = pcall(function()
      return Game.GetPlayer()
    end)

    if ok
      and player
      and IsDefined(player) then
      handlePlayerReady(player)
    end
  end
end)

registerForEvent("onShutdown", function()
  saveSettings()
end)

return {
  title = "Bike V Control + Impact",
  version = 1604,
  standalone = true
}
