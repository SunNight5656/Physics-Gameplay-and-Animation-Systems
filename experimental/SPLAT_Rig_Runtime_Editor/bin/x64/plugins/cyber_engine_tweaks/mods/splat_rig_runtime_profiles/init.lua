-- SPLAT Runtime Rig Profile Editor
-- Native Settings UI and controlled typed animRig resource controls.
-- Build: V23-UPLOADED-RIG-DEFAULTS-MAN-BASE-20260817

local TAB = "/splatRigRuntime"
local MASTER = TAB .. "/master"
local EDITOR = TAB .. "/selectedBody"
local USER_FILE = "user_settings.json"
local RUNTIME_FILE = "runtime_config.ini"
local SETTINGS_VERSION = 22
local NORMAL_ANGLE_LIMIT = 300.0
local SAVE_DEBOUNCE_SECONDS = 0.35

local nativeSettings = nil
local config = nil
local editorRefs = {}
local bodySelectorRef = nil
local savePending = false
local saveCountdown = 0.0
local directApplyPending = false

local BODY_DEFS = {
  { label = "Child 4 - Lower Back / Base of Spine", description = "Controls the first spine section above the hips. Changes how the lower torso bends away from the pelvis.", child = 4, stiff = true, exclude = false, sy1 = -4.0, sy2 = 4.0, sz1 = -20.0, sz2 = 20.0, tw1 = -5.0, tw2 = 5.0 },
  { label = "Child 5 - Left Waist / Top of Thigh", description = "Controls the left hip connection where the thigh meets the pelvis. Looser angles let the left leg swing farther from the waist.", child = 5, stiff = false, exclude = false, sy1 = -10.0, sy2 = 10.0, sz1 = 11.0, sz2 = 80.0, tw1 = -1.0, tw2 = 1.0 },
  { label = "Child 6 - Right Waist / Top of Thigh", description = "Controls the right hip connection where the thigh meets the pelvis. Looser angles let the right leg swing farther from the waist.", child = 6, stiff = false, exclude = false, sy1 = -10.0, sy2 = 10.0, sz1 = 11.0, sz2 = 80.0, tw1 = -1.0, tw2 = 1.0 },
  { label = "Child 7 - Middle Back", description = "Controls the middle-lower spine. Changes how much the torso can fold around the center of the back.", child = 7, stiff = false, exclude = false, sy1 = 0.0, sy2 = 0.0, sz1 = -10.0, sz2 = 10.0, tw1 = 0.0, tw2 = 0.0 },
  { label = "Child 8 - Left Upper Leg / Thigh", description = "Controls the left thigh between the hip and knee. This is the upper-leg body, not the lower leg.", child = 8, stiff = false, exclude = false, sy1 = -4.0, sy2 = 4.0, sz1 = -30.0, sz2 = 20.0, tw1 = -10.0, tw2 = 10.0 },
  { label = "Child 9 - Right Upper Leg / Thigh", description = "Controls the right thigh between the hip and knee. This is the upper-leg body, not the lower leg.", child = 9, stiff = false, exclude = false, sy1 = -4.0, sy2 = 4.0, sz1 = -30.0, sz2 = 20.0, tw1 = -10.0, tw2 = 10.0 },
  { label = "Child 10 - Upper-Middle Back", description = "Controls the spine section just below the upper back. Changes bending between the middle back and upper chest.", child = 10, stiff = false, exclude = false, sy1 = -1.0, sy2 = 1.0, sz1 = -10.0, sz2 = 3.0, tw1 = 0.0, tw2 = 0.0 },
  { label = "Child 11 - Left Lower Leg / Shin", description = "Controls the left knee/lower-leg bend. Defaults are taken directly from the supplied man_base rig.", child = 11, stiff = false, exclude = false, sy1 = -1.0, sy2 = 1.0, sz1 = 15.0, sz2 = 80.0, tw1 = -1.0, tw2 = 1.0 },
  { label = "Child 12 - Right Lower Leg / Shin", description = "Controls the right knee/lower-leg bend. Defaults are taken directly from the supplied man_base rig.", child = 12, stiff = false, exclude = false, sy1 = 0.0, sy2 = 0.0, sz1 = 15.0, sz2 = 80.0, tw1 = -1.0, tw2 = 1.0 },
  { label = "Child 13 - Upper Back", description = "Controls the upper spine under the shoulders and neck. Changes how the upper chest and shoulder area folds.", child = 13, stiff = false, exclude = false, sy1 = -1.0, sy2 = 1.0, sz1 = -14.0, sz2 = -1.0, tw1 = -1.0, tw2 = 1.0 },
  { label = "Child 17 - Left Shoulder to Spine", description = "Controls the left shoulder connection to the upper spine. Changes how far the shoulder can move away from the chest.", child = 17, stiff = false, exclude = false, sy1 = -8.0, sy2 = 8.0, sz1 = -8.0, sz2 = 8.0, tw1 = -8.0, tw2 = 8.0 },
  { label = "Child 18 - Right Shoulder to Spine", description = "Controls the right shoulder connection to the upper spine. Changes how far the shoulder can move away from the chest.", child = 18, stiff = false, exclude = false, sy1 = -8.0, sy2 = 8.0, sz1 = -8.0, sz2 = 8.0, tw1 = -8.0, tw2 = 8.0 },
  { label = "Child 19 - Neck Helper / Neutral", description = "This Neck1 helper did not produce a useful visible change in testing. Its six angle defaults are intentionally zero so it stays neutral.", child = 19, stiff = false, exclude = false, sy1 = 0.0, sy2 = 0.0, sz1 = 0.0, sz2 = 0.0, tw1 = 0.0, tw2 = 0.0 },
  { label = "Child 20 - Left Upper Arm", description = "Controls the left upper arm from the shoulder toward the elbow. Changes how the upper arm bends and swings.", child = 20, stiff = false, exclude = true, sy1 = 2.0, sy2 = 35.0, sz1 = -40.0, sz2 = 19.0, tw1 = -19.0, tw2 = 19.0 },
  { label = "Child 21 - Right Upper Arm", description = "Controls the right upper arm from the shoulder toward the elbow. Changes how the upper arm bends and swings.", child = 21, stiff = false, exclude = false, sy1 = -35.0, sy2 = -20.0, sz1 = -40.0, sz2 = 25.0, tw1 = -19.0, tw2 = 19.0 },
  { label = "Child 22 - Actual Neck / Head Joint", description = "This is the joint that actually changes the visible neck and head movement. It controls how far the head can bend from the neck.", child = 22, stiff = false, exclude = false, sy1 = -5.0, sy2 = 5.0, sz1 = -55.0, sz2 = 5.0, tw1 = 0.0, tw2 = 0.0 },
  { label = "Child 23 - Left Lower Arm / Forearm", description = "Controls the left forearm from the elbow toward the wrist. Changes lower-arm bending and twist.", child = 23, stiff = false, exclude = true, sy1 = -80.0, sy2 = 80.0, sz1 = -120.0, sz2 = -10.0, tw1 = -80.0, tw2 = 80.0 },
  { label = "Child 24 - Right Lower Arm / Forearm", description = "Controls the right forearm from the elbow toward the wrist. Changes lower-arm bending and twist.", child = 24, stiff = false, exclude = true, sy1 = -50.0, sy2 = 50.0, sz1 = -120.0, sz2 = -10.0, tw1 = -50.0, tw2 = 50.0 },
  { label = "Child 41 - Left Foot", description = "Controls the left foot at the end of the lower leg. Changes how freely the foot and ankle end of the leg can move.", child = 41, stiff = false, exclude = true, sy1 = -4.0, sy2 = 4.0, sz1 = -8.0, sz2 = 8.0, tw1 = 0.0, tw2 = 0.0, twNull = true },
  { label = "Child 42 - Right Foot", description = "Controls the right foot at the end of the lower leg. Changes how freely the foot and ankle end of the leg can move.", child = 42, stiff = false, exclude = true, sy1 = -4.0, sy2 = 4.0, sz1 = -8.0, sz2 = 8.0, tw1 = 0.0, tw2 = 0.0, twNull = true },
  { label = "Child 55 - Left Hand / Palm", description = "Controls the left hand at the end of the forearm. Changes how freely the hand and wrist end can move.", child = 55, stiff = false, exclude = false, sy1 = -35.0, sy2 = 35.0, sz1 = -30.0, sz2 = 30.0, tw1 = -60.0, tw2 = 60.0 },
  { label = "Child 60 - Right Hand / Palm", description = "Controls the right hand at the end of the forearm. Changes how freely the hand and wrist end can move.", child = 60, stiff = false, exclude = false, sy1 = -35.0, sy2 = 35.0, sz1 = -30.0, sz2 = 30.0, tw1 = -60.0, tw2 = 60.0 },
}

local PROFILE_BODY_PHYSICS = {
  [4] = { shape = 0, radius = 0.119999997, half = 0.0299999993, x = 0.140000001, y = 0.0, z = 0.0, i = 0.0, j = 0.866024971, k = 0.0, r = 0.5, filter = 2, root = false },
  [5] = { shape = 0, radius = 0.0700000003, half = 0.000500000024, x = 0.0399999991, y = 0.0, z = 0.0, i = 0.0, j = 0.707107008, k = 0.0, r = 0.707107008, filter = 2, root = false },
  [6] = { shape = 0, radius = 0.0700000003, half = 0.000500000024, x = 0.0399999991, y = 0.0, z = 0.0, i = 0.0, j = 0.707107008, k = 0.0, r = 0.707107008, filter = 2, root = false },
  [7] = { shape = 0, radius = 0.0900000036, half = 0.0949999988, x = 0.0900000036, y = 0.0, z = 0.0, i = 0.0, j = 0.87462002, k = 0.0, r = 0.484809995, filter = 2, root = false },
  [8] = { shape = 0, radius = 0.0799999982, half = 0.159999996, x = 0.00999999978, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 2, root = false },
  [9] = { shape = 0, radius = 0.0799999982, half = 0.159999996, x = 0.0199999996, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 2, root = false },
  [10] = { shape = 0, radius = 0.0949999988, half = 0.0850000009, x = 0.159999996, y = 0.0199999996, z = 0.0, i = 0.0, j = 0.866024971, k = 0.0, r = 0.5, filter = 2, root = false },
  [11] = { shape = 0, radius = 0.0649999976, half = 0.158000007, x = 0.00999999978, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 2, root = false },
  [12] = { shape = 0, radius = 0.0649999976, half = 0.158000007, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 2, root = false },
  [13] = { shape = 0, radius = 0.100000001, half = 0.0799999982, x = 0.0299999993, y = 0.0199999996, z = 0.0, i = 0.0, j = 0.688354015, k = 0.0, r = 0.725374997, filter = 2, root = false },
  [17] = { shape = 0, radius = 0.100000001, half = 0.0299999993, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 2, root = false },
  [18] = { shape = 0, radius = 0.100000001, half = 0.0350000001, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 2, root = false },
  [19] = { shape = 0, radius = 0.0599999987, half = 0.0599999987, x = 0.0599999987, y = 0.0199999996, z = 0.0, i = 0.0, j = 0.707107008, k = 0.0, r = 0.707107008, filter = 2, root = false },
  [20] = { shape = 0, radius = 0.0700000003, half = 0.109999999, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 0, root = false },
  [21] = { shape = 0, radius = 0.0700000003, half = 0.109999999, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 0, root = false },
  [22] = { shape = 1, radius = 0.0599999987, half = 0.0599999987, x = 0.0450000018, y = 0.0329999998, z = 0.0, i = 0.0, j = 0.0, k = -0.0610489994, r = 0.998134971, filter = 2, root = false },
  [23] = { shape = 0, radius = 0.0500000007, half = 0.0804200023, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 1, root = false },
  [24] = { shape = 0, radius = 0.0500000007, half = 0.0806419998, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 1, root = false },
  [41] = { shape = 0, radius = 0.0549999997, half = 0.075000003, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.195089996, r = 0.980785012, filter = 2, root = false },
  [42] = { shape = 0, radius = 0.0549999997, half = 0.075000003, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.195089996, r = 0.980785012, filter = 2, root = false },
  [55] = { shape = 0, radius = 0.0399999991, half = 0.0426490009, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 2, root = false },
  [60] = { shape = 0, radius = 0.0399999991, half = 0.0426490009, x = 0.0, y = 0.0, z = 0.0, i = 0.0, j = 0.0, k = 0.0, r = 1.0, filter = 2, root = false },
}

local BODY_PAIRS = {
  [5] = 6, [6] = 5,
  [8] = 9, [9] = 8,
  [11] = 12, [12] = 11,
  [17] = 18, [18] = 17,
  [20] = 21, [21] = 20,
  [23] = 24, [24] = 23,
  [41] = 42, [42] = 41,
  [55] = 60, [60] = 55
}

-- Controller tuning keeps all six real rig angle values reachable.
-- Left/right cycles X -> Y -> Z. X/Square toggles Value 1 vs Value 2.
-- Up/down changes the currently selected value by controllerStep.
local CONTROLLER_AXES = {
  { label = "X / Twist", short = "X", field1 = "twistMin", field2 = "twistMax" },
  { label = "Y / Swing", short = "Y", field1 = "swingYMin", field2 = "swingYMax" },
  { label = "Z / Swing", short = "Z", field1 = "swingZMin", field2 = "swingZMax" }
}

local ANATOMICAL_CHILD_ORDER = {
  41, 42, 11, 12, 8, 9, 5, 6, 4, 7, 10, 13,
  17, 18, 20, 21, 23, 24, 55, 60, 19, 22
}

local BODY_BY_CHILD = {}
for _, body in ipairs(BODY_DEFS) do
  BODY_BY_CHILD[body.child] = body
end

local function orderedBodies(useAnatomicalOrder)
  if not useAnatomicalOrder then
    return BODY_DEFS
  end
  local output = {}
  for _, child in ipairs(ANATOMICAL_CHILD_ORDER) do
    table.insert(output, BODY_BY_CHILD[child])
  end
  return output
end

local function bodyLabels(useAnatomicalOrder)
  local output = {}
  for index, body in ipairs(orderedBodies(useAnatomicalOrder)) do
    output[index] = body.label
  end
  return output
end

local function bodyIndexForChild(child, useAnatomicalOrder)
  for index, body in ipairs(orderedBodies(useAnatomicalOrder)) do
    if body.child == child then
      return index - 1
    end
  end
  return 0
end

local SHAPE_LABELS = { "Capsule", "Box", "Sphere" }
local FILTER_LABELS = { "None", "Ragdoll", "Ragdoll Inner" }

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
      value[key] = merge(value[key], defaultValue)
    elseif value[key] == nil then
      value[key] = defaultValue
    end
  end
  return value
end

local function clamp(value, minimum, maximum, fallback)
  local number = tonumber(value)
  if number == nil then
    number = fallback
  end
  return math.max(minimum, math.min(maximum, number))
end

local function makeBodyDefaults(body)
  local physics = PROFILE_BODY_PHYSICS[body.child]
  return {
    stiff = body.stiff,
    excludeEarlyCollision = body.exclude,
    zeroAllAngles = false,
    fiveTimesAngleTest = false,
    swingYMin = body.sy1,
    swingYMax = body.sy2,
    swingZMin = body.sz1,
    swingZMax = body.sz2,
    twistMin = body.tw1,
    twistMax = body.tw2,
    sourceSwingYNull = body.syNull == true,
    sourceSwingZNull = body.szNull == true,
    sourceTwistNull = body.twNull == true,
    shapeType = physics.shape,
    shapeRadius = physics.radius,
    halfHeight = physics.half,
    shapePositionX = physics.x,
    shapePositionY = physics.y,
    shapePositionZ = physics.z,
    shapeRotationI = physics.i,
    shapeRotationJ = physics.j,
    shapeRotationK = physics.k,
    shapeRotationR = physics.r,
    collisionFilter = physics.filter,
    rootDisplacement = physics.root
  }
end

local function makeDefaults()
  local output = {
    settingsVersion = SETTINGS_VERSION,
    enabled = false,
    liveApply = false,
    allBodiesTenThousandTest = false,
    applyRequest = 0,
    anatomicalBodyOrder = true,
    selectedBody = 0,
    matchPairedBodies = false,
    controllerTuningEnabled = false,
    controllerStep = 1.0,
    controllerAxis = 3,
    controllerValueSlot = 1,
    bodies = {}
  }
  for _, body in ipairs(BODY_DEFS) do
    output.bodies[tostring(body.child)] = makeBodyDefaults(body)
  end
  return output
end

local defaults = makeDefaults()

local function logInfo(message)
  spdlog.info("[SPLAT Rig Runtime Editor] " .. tostring(message))
end

local function logError(message)
  spdlog.error("[SPLAT Rig Runtime Editor] " .. tostring(message))
end

local function normaliseSettings(settings)
  settings.enabled = settings.enabled == true
  settings.liveApply = settings.liveApply == true
  settings.allBodiesTenThousandTest = settings.allBodiesTenThousandTest == true
  settings.applyRequest = math.floor(clamp(settings.applyRequest, 0, 2147483647, 0))
  settings.anatomicalBodyOrder = settings.anatomicalBodyOrder ~= false
  settings.selectedBody = math.floor(clamp(settings.selectedBody, 0, #BODY_DEFS - 1, 0))
  settings.matchPairedBodies = settings.matchPairedBodies == true
  settings.controllerTuningEnabled = settings.controllerTuningEnabled == true
  settings.controllerStep = clamp(settings.controllerStep, 1.0, 100.0, 1.0)
  settings.controllerAxis = math.floor(clamp(settings.controllerAxis, 1, #CONTROLLER_AXES, 3))
  settings.controllerValueSlot = math.floor(clamp(settings.controllerValueSlot, 1, 2, 1))

  for _, body in ipairs(BODY_DEFS) do
    local values = settings.bodies[tostring(body.child)]
    values.stiff = values.stiff == true
    values.excludeEarlyCollision = values.excludeEarlyCollision == true
    values.zeroAllAngles = values.zeroAllAngles == true
    values.fiveTimesAngleTest = values.fiveTimesAngleTest == true
    local angleLimit = (body.child == 11 or body.child == 12) and 1000.0 or NORMAL_ANGLE_LIMIT
    -- Lower legs keep the dedicated +/-1000 test range. No hidden 800 override.
    if body.child == 11 or body.child == 12 then
      values.fiveTimesAngleTest = false
    end
    values.swingYMin = clamp(values.swingYMin, -angleLimit, angleLimit, 0.0)
    values.swingYMax = clamp(values.swingYMax, -angleLimit, angleLimit, 0.0)
    values.swingZMin = clamp(values.swingZMin, -angleLimit, angleLimit, 0.0)
    values.swingZMax = clamp(values.swingZMax, -angleLimit, angleLimit, 0.0)
    values.twistMin = clamp(values.twistMin, -angleLimit, angleLimit, 0.0)
    values.twistMax = clamp(values.twistMax, -angleLimit, angleLimit, 0.0)
    values.shapeType = math.floor(clamp(values.shapeType, 0, 2, 0))
    values.shapeRadius = clamp(values.shapeRadius, 0.001, 2.0, 0.05)
    values.halfHeight = clamp(values.halfHeight, 0.0, 2.0, 0.05)
    values.shapePositionX = clamp(values.shapePositionX, -2.0, 2.0, 0.0)
    values.shapePositionY = clamp(values.shapePositionY, -2.0, 2.0, 0.0)
    values.shapePositionZ = clamp(values.shapePositionZ, -2.0, 2.0, 0.0)
    values.shapeRotationI = clamp(values.shapeRotationI, -1.0, 1.0, 0.0)
    values.shapeRotationJ = clamp(values.shapeRotationJ, -1.0, 1.0, 0.0)
    values.shapeRotationK = clamp(values.shapeRotationK, -1.0, 1.0, 0.0)
    values.shapeRotationR = clamp(values.shapeRotationR, -1.0, 1.0, 1.0)
    values.collisionFilter = math.floor(clamp(values.collisionFilter, 0, 2, 0))
    values.rootDisplacement = values.rootDisplacement == true
  end
  return settings
end

local function loadSettings()
  local file = io.open(USER_FILE, "r")
  if not file then
    return deepCopy(defaults)
  end
  local raw = file:read("*a")
  file:close()
  local ok, decoded = pcall(json.decode, raw)
  if not ok or type(decoded) ~= "table" then
    logError("Invalid user_settings.json; supplied rig defaults loaded")
    return deepCopy(defaults)
  end

  local loaded
  local decodedVersion = tonumber(decoded.settingsVersion)
  if decodedVersion ~= SETTINGS_VERSION then
    -- V23 changes the source-of-truth rig baseline. Old saved body values would
    -- mask these defaults, so reset all 22 bodies once when upgrading.
    loaded = deepCopy(defaults)
    loaded.liveApply = false
    loaded.allBodiesTenThousandTest = false
    loaded.applyRequest = 0
    logInfo("v23 baseline reset: all 22 bodies restored from supplied man_base rig (20260817)")
  else
    loaded = merge(decoded, deepCopy(defaults))
  end
  loaded.settingsVersion = SETTINGS_VERSION
  return normaliseSettings(loaded)
end

local function saveSettings()
  local ok, raw = pcall(json.encode, config)
  if not ok then
    logError("Could not encode user settings")
    return false
  end
  local file, err = io.open(USER_FILE, "w")
  if not file then
    logError("Could not write user_settings.json: " .. tostring(err))
    return false
  end
  file:write(raw)
  file:flush()
  file:close()
  return true
end

local function boolValue(value)
  return value == true and "1" or "0"
end

local function numberValue(value)
  return string.format("%.9f", tonumber(value) or 0.0)
end

local function buildRuntimeConfigText()
  local lines = {
    "# SPLAT Runtime Rig Profile v23 - uploaded man_base defaults; paired editing + explicit V1/V2 controller tuner",
    "enabled=" .. boolValue(config.enabled),
    "live_apply=" .. boolValue(config.liveApply),
    "all_bodies_10000_angle_test=" .. boolValue(config.allBodiesTenThousandTest),
    "apply_request=" .. tostring(config.applyRequest)
  }

  local function add(line)
    table.insert(lines, line)
  end

  for _, body in ipairs(BODY_DEFS) do
    local values = config.bodies[tostring(body.child)]
    local prefix = "body." .. tostring(body.child) .. "."
    add(prefix .. "stiff=" .. boolValue(values.stiff))
    add(prefix .. "exclude_early_collision=" .. boolValue(values.excludeEarlyCollision))
    add(prefix .. "zero_all_angles=" .. boolValue(values.zeroAllAngles))

    -- Keep the legacy native 5x switch OFF. The menu toggle now means:
    -- send 800 to all six angle limits for this body without overwriting
    -- the user's saved slider values.
    local useEightHundred = values.fiveTimesAngleTest == true
    add(prefix .. "five_times_angle_test=0")
    add(prefix .. "swing_y_min=" .. numberValue(useEightHundred and 800.0 or values.swingYMin))
    add(prefix .. "swing_y_max=" .. numberValue(useEightHundred and 800.0 or values.swingYMax))
    add(prefix .. "swing_z_min=" .. numberValue(useEightHundred and 800.0 or values.swingZMin))
    add(prefix .. "swing_z_max=" .. numberValue(useEightHundred and 800.0 or values.swingZMax))
    add(prefix .. "twist_min=" .. numberValue(useEightHundred and 800.0 or values.twistMin))
    add(prefix .. "twist_max=" .. numberValue(useEightHundred and 800.0 or values.twistMax))
    add(prefix .. "shape_type=" .. tostring(values.shapeType))
    add(prefix .. "shape_radius=" .. numberValue(values.shapeRadius))
    add(prefix .. "half_height=" .. numberValue(values.halfHeight))
    add(prefix .. "shape_position_x=" .. numberValue(values.shapePositionX))
    add(prefix .. "shape_position_y=" .. numberValue(values.shapePositionY))
    add(prefix .. "shape_position_z=" .. numberValue(values.shapePositionZ))
    add(prefix .. "shape_rotation_i=" .. numberValue(values.shapeRotationI))
    add(prefix .. "shape_rotation_j=" .. numberValue(values.shapeRotationJ))
    add(prefix .. "shape_rotation_k=" .. numberValue(values.shapeRotationK))
    add(prefix .. "shape_rotation_r=" .. numberValue(values.shapeRotationR))
    add(prefix .. "collision_filter=" .. tostring(values.collisionFilter))
    add(prefix .. "root_displacement=" .. boolValue(values.rootDisplacement))
  end

  -- Native code accepts the payload only when this final marker is present.
  add("complete=1")
  return table.concat(lines, "\n") .. "\n"
end

local function writeRuntimeConfig(runtimeText)
  local file, err = io.open(RUNTIME_FILE, "w")
  if not file then
    logError("Could not write runtime_config.ini: " .. tostring(err))
    return false
  end
  file:write(runtimeText or buildRuntimeConfigText())
  file:flush()
  file:close()
  return true
end

local function requestDirectNativeApply(runtimeText, reason)
  local ok, result = pcall(function()
    return Game.SPLATRigRuntimeNativeApply(runtimeText)
  end)
  if not ok then
    logError("Direct native Apply bridge call failed: " .. tostring(result))
    return false
  end
  if result ~= true then
    logError("Direct native Apply bridge rejected request " .. tostring(config.applyRequest))
    return false
  end
  logInfo("Direct native Apply completed: " .. tostring(reason or "menu change") .. " request=" .. tostring(config.applyRequest))
  return true
end

local function flushCommit(applyNative, reason)
  normaliseSettings(config)
  local runtimeText = buildRuntimeConfigText()
  local settingsSaved = saveSettings()
  local runtimeSaved = writeRuntimeConfig(runtimeText)
  if settingsSaved and runtimeSaved then
    savePending = false
    saveCountdown = 0.0
    local shouldApply = applyNative == true or (applyNative == nil and directApplyPending == true)
    directApplyPending = false
    if shouldApply then
      local l = config.bodies["11"]
      local r = config.bodies["12"]
      logInfo(string.format("V20 lower-leg payload C11 Y=(%.1f,%.1f) Z=(%.1f,%.1f) X=(%.1f,%.1f) | C12 Y=(%.1f,%.1f) Z=(%.1f,%.1f) X=(%.1f,%.1f)",
        l.swingYMin, l.swingYMax, l.swingZMin, l.swingZMax, l.twistMin, l.twistMax,
        r.swingYMin, r.swingYMax, r.swingZMin, r.swingZMax, r.twistMin, r.twistMax))
      return requestDirectNativeApply(runtimeText, reason)
    end
    return true
  end
  savePending = true
  saveCountdown = SAVE_DEBOUNCE_SECONDS
  return false
end

local function commit(immediate, forceNativeApply, reason)
  normaliseSettings(config)
  if forceNativeApply == true or config.liveApply == true then
    directApplyPending = true
  end
  if immediate == true then
    return flushCommit(nil, reason)
  end
  savePending = true
  saveCountdown = SAVE_DEBOUNCE_SECONDS
  return true
end

local function selectedDefinition()
  local index = math.floor(clamp(config.selectedBody, 0, #BODY_DEFS - 1, 0))
  return orderedBodies(config.anatomicalBodyOrder)[index + 1]
end

local function selectedValues()
  local body = selectedDefinition()
  return body, config.bodies[tostring(body.child)]
end

local function pairedChild(child)
  return BODY_PAIRS[tonumber(child)]
end

local function mirrorFieldToPair(child, field, value)
  if not config.matchPairedBodies then
    return nil
  end
  local pair = pairedChild(child)
  if not pair then
    return nil
  end
  local pairValues = config.bodies[tostring(pair)]
  if not pairValues then
    return nil
  end
  pairValues[field] = deepCopy(value)
  return pair
end

local function setAngleGuardsForBody(child)
  local values = config.bodies[tostring(child)]
  if not values then return end
  values.zeroAllAngles = false
  values.fiveTimesAngleTest = false
end

local function showControllerPopup(message)
  local text = tostring(message or "")
  local ok, result = pcall(function()
    Game.SPLATRigRuntimeShowPopup(text)
    return true
  end)
  if not ok or result ~= true then
    logInfo("Controller: " .. text)
  end
end

local function controllerAxisDefinition()
  return CONTROLLER_AXES[math.floor(clamp(config.controllerAxis, 1, #CONTROLLER_AXES, 3))]
end

local function controllerFieldName()
  local axis = controllerAxisDefinition()
  if config.controllerValueSlot == 1 then
    return axis.field1
  end
  return axis.field2
end

local function controllerAngleLimit(body)
  if body.child == 11 or body.child == 12 then
    return 1000.0
  end
  return NORMAL_ANGLE_LIMIT
end

local function controllerStatusText(prefix)
  local body, values = selectedValues()
  local axis = controllerAxisDefinition()
  local field = controllerFieldName()
  local pair = pairedChild(body.child)
  local matchText = "Match OFF"
  if config.matchPairedBodies and pair then
    matchText = "Matched Child " .. tostring(pair)
  elseif config.matchPairedBodies then
    matchText = "No paired side"
  end
  local v1 = tonumber(values[axis.field1]) or 0.0
  local v2 = tonumber(values[axis.field2]) or 0.0
  local active = config.controllerValueSlot == 1 and "V1" or "V2"
  return string.format("%sChild %d | %s | V1=%.1f | V2=%.1f | ACTIVE %s | %s",
    prefix and (tostring(prefix) .. " ") or "",
    body.child,
    axis.short,
    v1,
    v2,
    active,
    matchText)
end

local function cycleControllerAxis(direction)
  if not config.controllerTuningEnabled then return end
  local axis = config.controllerAxis + direction
  if axis < 1 then axis = #CONTROLLER_AXES end
  if axis > #CONTROLLER_AXES then axis = 1 end
  config.controllerAxis = axis
  commit()
  showControllerPopup(controllerStatusText("Axis:"))
end

local function toggleControllerValueSlot()
  if not config.controllerTuningEnabled then return end
  config.controllerValueSlot = (config.controllerValueSlot == 1) and 2 or 1
  commit()
  showControllerPopup(controllerStatusText("Selected:"))
end

local function adjustControllerValue(direction)
  if not config.controllerTuningEnabled then return end
  if not config.enabled then
    showControllerPopup("SPLAT Rig Profile is OFF - enable it in Native Settings")
    return
  end

  local body, values = selectedValues()
  local field = controllerFieldName()
  local limit = controllerAngleLimit(body)
  local step = clamp(config.controllerStep, 1.0, 100.0, 1.0)
  local nextValue = clamp((tonumber(values[field]) or 0.0) + (direction * step), -limit, limit, tonumber(values[field]) or 0.0)

  values[field] = nextValue
  setAngleGuardsForBody(body.child)
  local pair = mirrorFieldToPair(body.child, field, nextValue)
  if pair then
    setAngleGuardsForBody(pair)
  end

  -- A global proof-test override would hide the controller change, so a real
  -- controller adjustment always returns to the ordinary per-body values.
  config.allBodiesTenThousandTest = false
  config.applyRequest = (config.applyRequest + 1) % 2147483647
  commit(true, true, "controller angle tune")
  showControllerPopup(controllerStatusText(direction > 0 and "+" or "-"))
end

local function containsAny(text, names)
  local haystack = string.lower(tostring(text or ""))
  for _, name in ipairs(names) do
    if string.find(haystack, string.lower(name), 1, true) ~= nil then
      return true
    end
  end
  return false
end

local function handleControllerAction(action)
  if not config or not config.controllerTuningEnabled or action == nil then return end

  local actionName = ""
  local actionType = ""
  pcall(function() actionName = Game.NameToString(action:GetName(action)) end)
  pcall(function() actionType = tostring(action:GetType(action).value) end)
  actionName = tostring(actionName or "")
  actionType = tostring(actionType or "")

  -- Reject release/hold edges. CET enum stringification differs between builds,
  -- so an unknown non-release value is still allowed through for the named buttons.
  local upperType = string.upper(actionType)
  if actionType == "0" or string.find(upperType, "RELEASE", 1, true) or string.find(upperType, "HOLD", 1, true) then
    return
  end

  local leftNames = { "DPad_Left", "DPadLeft", "dpad_left", "UI_DPadLeft", "NavigateLeft", "IK_Pad_DPAD_Left", "Pad_DPAD_Left", "DPAD_LEFT" }
  local rightNames = { "DPad_Right", "DPadRight", "dpad_right", "UI_DPadRight", "NavigateRight", "IK_Pad_DPAD_Right", "Pad_DPAD_Right", "DPAD_RIGHT" }
  local upNames = { "DPad_Up", "DPadUp", "dpad_up", "UI_DPadUp", "NavigateUp", "IK_Pad_DPAD_Up", "Pad_DPAD_Up", "DPAD_UP" }
  local downNames = { "DPad_Down", "DPadDown", "dpad_down", "UI_DPadDown", "NavigateDown", "IK_Pad_DPAD_Down", "Pad_DPAD_Down", "DPAD_DOWN" }
  local xNames = { "Reload", "Choice1", "Square", "IK_Pad_X_SQUARE", "Pad_X_SQUARE", "Pad_Square", "Pad_X", "FaceButton_Left", "IK_Pad_FaceButton_Left" }

  if containsAny(actionName, leftNames) then cycleControllerAxis(-1) return end
  if containsAny(actionName, rightNames) then cycleControllerAxis(1) return end
  if containsAny(actionName, upNames) then adjustControllerValue(1) return end
  if containsAny(actionName, downNames) then adjustControllerValue(-1) return end
  if containsAny(actionName, xNames) then toggleControllerValueSlot() return end
end

local function remember(reference)
  if reference ~= nil then
    table.insert(editorRefs, reference)
  end
  return reference
end

local function clearEditor()
  for index = #editorRefs, 1, -1 do
    pcall(function()
      nativeSettings.removeOption(editorRefs[index])
    end)
  end
  editorRefs = {}
end

local function setSelectedBool(name, value)
  local body, values = selectedValues()
  local nextValue = value == true
  values[name] = nextValue
  mirrorFieldToPair(body.child, name, nextValue)
  commit()
end

local function setSelectedNumber(name, value, minimum, maximum)
  local body, values = selectedValues()
  local nextValue = clamp(value, minimum, maximum, values[name] or 0.0)
  values[name] = nextValue
  local isAngle = name == "swingYMin" or name == "swingYMax"
    or name == "swingZMin" or name == "swingZMax"
    or name == "twistMin" or name == "twistMax"
  if isAngle then
    setAngleGuardsForBody(body.child)
  end
  local pair = mirrorFieldToPair(body.child, name, nextValue)
  if pair and isAngle then
    setAngleGuardsForBody(pair)
  end
  commit()
end

local function setSelectedIndex(name, value, maximum)
  local body, values = selectedValues()
  local nextValue = math.floor(clamp(value, 0, maximum, values[name] or 0))
  values[name] = nextValue
  mirrorFieldToPair(body.child, name, nextValue)
  commit()
end

local buildEditor
buildEditor = function()
  clearEditor()
  local body, values = selectedValues()
  local defaultValues = defaults.bodies[tostring(body.child)]
  local index = 1
  local function describe(text)
    return body.description .. " " .. text
  end

  local function addSwitch(name, description, field)
    remember(nativeSettings.addSwitch(
      EDITOR,
      name,
      describe(description),
      values[field] == true,
      defaultValues[field] == true,
      function(value) setSelectedBool(field, value) end,
      index
    ))
    index = index + 1
  end

  local function addFloat(name, description, field, minimum, maximum, step, format)
    remember(nativeSettings.addRangeFloat(
      EDITOR,
      name,
      describe(description),
      minimum,
      maximum,
      step,
      format,
      tonumber(values[field]) or tonumber(defaultValues[field]) or 0.0,
      tonumber(defaultValues[field]) or 0.0,
      function(value) setSelectedNumber(field, value, minimum, maximum) end,
      index
    ))
    index = index + 1
  end

  addSwitch("Make Body Stiff", "Makes this part fight bending and stay firmer. Off lets it move more freely.", "stiff")
  addSwitch("Exclude From Early Collision", "Stops this part from colliding during the first instant of the fall. This can help reduce snagging, popping, or sudden kicks as ragdoll starts.", "excludeEarlyCollision")

  remember(nativeSettings.addButton(
    EDITOR,
    "Set Y, Z, and X Angle Sliders to Zero",
    describe("Sets all six bend limits for this body to zero. It does not change the shape, stiffness, collision settings, or any other body part."),
    "ZERO ANGLES",
    index,
    function()
      values.swingYMin = 0.0
      values.swingYMax = 0.0
      values.swingZMin = 0.0
      values.swingZMax = 0.0
      values.twistMin = 0.0
      values.twistMax = 0.0
      setAngleGuardsForBody(body.child)
      local pair = pairedChild(body.child)
      if config.matchPairedBodies and pair then
        local pairValues = config.bodies[tostring(pair)]
        pairValues.swingYMin = 0.0
        pairValues.swingYMax = 0.0
        pairValues.swingZMin = 0.0
        pairValues.swingZMax = 0.0
        pairValues.twistMin = 0.0
        pairValues.twistMax = 0.0
        setAngleGuardsForBody(pair)
      end
      commit()
      buildEditor()
    end
  ))
  index = index + 1
  local angleSliderLimit = (body.child == 11 or body.child == 12) and 1000.0 or 300.0
  if body.child ~= 11 and body.child ~= 12 then
    addSwitch("800 Angle Test for This Body Part", "When on, Apply sends 800 to all six angle limits for only this body part. Your saved sliders stay unchanged, so turning it off returns to them.", "fiveTimesAngleTest")
  end
  addFloat("Swing Y Value 1", "One side of how far this joint can bend in the Y direction. The number is sent directly to this rig field.", "swingYMin", -angleSliderLimit, angleSliderLimit, 1.0, "%.1f")
  addFloat("Swing Y Value 2", "The other side of the Y bend limit. The number is sent directly to this rig field.", "swingYMax", -angleSliderLimit, angleSliderLimit, 1.0, "%.1f")
  addFloat("Swing Z Value 1", "One side of how far this joint can bend in the Z direction. The number is sent directly to this rig field.", "swingZMin", -angleSliderLimit, angleSliderLimit, 1.0, "%.1f")
  addFloat("Swing Z Value 2", "The other side of the Z bend limit. The number is sent directly to this rig field.", "swingZMax", -angleSliderLimit, angleSliderLimit, 1.0, "%.1f")
  addFloat("Twist / X Value 1", "One side of how far this body part can twist. The number is sent directly to this rig field.", "twistMin", -angleSliderLimit, angleSliderLimit, 1.0, "%.1f")
  addFloat("Twist / X Value 2", "The other side of the twist limit. The number is sent directly to this rig field.", "twistMax", -angleSliderLimit, angleSliderLimit, 1.0, "%.1f")

  remember(nativeSettings.addSelectorString(
    EDITOR,
    "Shape Type (Capsule / Box / Sphere)",
    describe("Changes the invisible solid shape used for this body part. Capsule is rounded like a limb, Box is block-shaped, and Sphere is ball-shaped."),
    SHAPE_LABELS,
    values.shapeType + 1,
    defaultValues.shapeType + 1,
    function(value) setSelectedIndex("shapeType", (tonumber(value) or 1) - 1, 2) end,
    index
  ))
  index = index + 1

  addFloat("Shape Radius", "Makes the invisible collision shape thicker or thinner. Higher means wider/fatter.", "shapeRadius", 0.001, 2.0, 0.001, "%.3f")
  addFloat("Half Height", "Makes the invisible collision shape longer or shorter. Higher means longer.", "halfHeight", 0.0, 2.0, 0.001, "%.3f")
  addFloat("Shape Local Position X", "Moves the invisible collision shape along X so you can line it up with the body part.", "shapePositionX", -2.0, 2.0, 0.001, "%.3f")
  addFloat("Shape Local Position Y", "Moves the invisible collision shape along Y so you can line it up with the body part.", "shapePositionY", -2.0, 2.0, 0.001, "%.3f")
  addFloat("Shape Local Position Z", "Moves the invisible collision shape along Z so you can line it up with the body part.", "shapePositionZ", -2.0, 2.0, 0.001, "%.3f")
  addFloat("Shape Rotation Quaternion I", "Helps rotate the invisible shape. Change this only when the shape is pointing the wrong way.", "shapeRotationI", -1.0, 1.0, 0.001, "%.3f")
  addFloat("Shape Rotation Quaternion J", "Helps rotate the invisible shape. Change this only when the shape is pointing the wrong way.", "shapeRotationJ", -1.0, 1.0, 0.001, "%.3f")
  addFloat("Shape Rotation Quaternion K", "Helps rotate the invisible shape. Change this only when the shape is pointing the wrong way.", "shapeRotationK", -1.0, 1.0, 0.001, "%.3f")
  addFloat("Shape Rotation Quaternion R", "Helps rotate the invisible shape. Change this only when the shape is pointing the wrong way.", "shapeRotationR", -1.0, 1.0, 0.001, "%.3f")

  remember(nativeSettings.addSelectorString(
    EDITOR,
    "Collision Filter",
    describe("Controls what this part is allowed to bump into. None removes the special ragdoll collision group; Ragdoll uses the normal ragdoll group; Ragdoll Inner uses the inner-body group."),
    FILTER_LABELS,
    values.collisionFilter + 1,
    defaultValues.collisionFilter + 1,
    function(value) setSelectedIndex("collisionFilter", (tonumber(value) or 1) - 1, 2) end,
    index
  ))
  index = index + 1

  addSwitch("Is Root Displacement Part", "Lets this part help move the whole ragdoll's main position. Usually leave this off unless you want this part to pull the whole body around.", "rootDisplacement")

  remember(nativeSettings.addButton(
    EDITOR,
    "Reset Selected Body",
    describe("Puts this body back to the supplied rig values. Child 19 returns to the intentionally neutral zero-angle setup."),
    "RESET BODY",
    index,
    function()
      config.bodies[tostring(body.child)] = deepCopy(defaultValues)
      local pair = pairedChild(body.child)
      if config.matchPairedBodies and pair then
        config.bodies[tostring(pair)] = deepCopy(defaults.bodies[tostring(pair)])
      end
      commit()
      buildEditor()
    end
  ))
end

local function buildBodySelector()
  if bodySelectorRef ~= nil then
    pcall(function()
      nativeSettings.removeOption(bodySelectorRef)
    end)
    bodySelectorRef = nil
  end

  bodySelectorRef = nativeSettings.addSelectorString(
    MASTER,
    "Body Part To Edit",
    "Choose the body part you want to tune. The Child number is kept in the name so you can match the menu to the rig file.",
    bodyLabels(config.anatomicalBodyOrder),
    config.selectedBody + 1,
    1,
    function(value)
      config.selectedBody = math.floor(clamp((tonumber(value) or 1) - 1, 0, #BODY_DEFS - 1, 0))
      commit()
      buildEditor()
      if config.controllerTuningEnabled then
        showControllerPopup(controllerStatusText("Body selected:"))
      end
    end,
    6
  )
end

local function buildMenu()
  nativeSettings.addTab(TAB, "SPLAT Rig Runtime Profile", function()
    commit()
  end)
  nativeSettings.addSubcategory(MASTER, "Live Rig Resource Profile - man_base only", 1)
  nativeSettings.addSubcategory(EDITOR, "Selected Body Manual Controls", 2)

  nativeSettings.addSwitch(
    MASTER,
    "Enable Runtime Rig Profile",
    "Enables the saved rig profile for man_base.rig only. No other male, female, size, child, or teen rig is edited.",
    config.enabled == true,
    false,
    function(value)
      config.enabled = value == true
      config.applyRequest = (config.applyRequest + 1) % 2147483647
      commit(true, true, "master profile switch")
    end,
    1
  )

  nativeSettings.addSwitch(
    MASTER,
    "Automatically Apply Every Menu Change Live",
    "Off by default to prevent repeated resource patching and stutter while editing several sliders. When off, use the Apply button once after finishing edits.",
    config.liveApply == true,
    false,
    function(value)
      config.liveApply = value == true
      commit()
    end,
    2
  )

  nativeSettings.addSwitch(
    MASTER,
    "10,000 Angle Proof Test - All Bodies",
      "On the next Apply, forces all six constraint angles on every configured body to 10,000 without overwriting saved sliders.",
    config.allBodiesTenThousandTest == true,
    false,
    function(value)
      config.allBodiesTenThousandTest = value == true
      commit()
    end,
    3
  )

  nativeSettings.addButton(
    MASTER,
    "Apply Saved Rig Once Now",
    "Applies the complete menu state to man_base.rig only. No other human rig is edited. Newly spawned ragdolls use the updated resource; reload the save if an existing NPC was already instantiated.",
    "APPLY ONCE",
    4,
    function()
      config.applyRequest = (config.applyRequest + 1) % 2147483647
      commit(true, true, "Apply Saved Rig Once Now")
    end
  )

  nativeSettings.addSwitch(
    MASTER,
    "Use Anatomical Feet-to-Head Body Order",
    "On uses the practical feet, lower legs, upper legs, torso, arms, and head sequence. Off uses the game's ragdoll-layer order from the rig file.",
    config.anatomicalBodyOrder == true,
    true,
    function(value)
      local selectedChild = selectedDefinition().child
      config.anatomicalBodyOrder = value == true
      config.selectedBody = bodyIndexForChild(selectedChild, config.anatomicalBodyOrder)
      commit()
      buildBodySelector()
      buildEditor()
    end,
    5
  )

  buildBodySelector()

  nativeSettings.addSwitch(
    MASTER,
    "Match Paired Left / Right Body Parts",
    "When on, changing a paired left/right body copies that same changed field to its partner. Pairs are hips, thighs, lower legs, shoulders, upper arms, forearms, feet, and hands. Unpaired spine/neck parts are unchanged.",
    config.matchPairedBodies == true,
    false,
    function(value)
      config.matchPairedBodies = value == true
      commit()
      local body = selectedDefinition()
      local pair = pairedChild(body.child)
      if config.matchPairedBodies and pair then
        showControllerPopup("Pair match ON: Child " .. tostring(body.child) .. " <-> Child " .. tostring(pair))
      elseif config.matchPairedBodies then
        showControllerPopup("Pair match ON: Child " .. tostring(body.child) .. " has no left/right partner")
      else
        showControllerPopup("Pair match OFF")
      end
    end,
    7
  )

  nativeSettings.addSwitch(
    MASTER,
    "Enable Controller Tuning",
    "Arms the gameplay controller tuner for the body selected above. Left/Right cycles X, Y, Z. Every popup shows BOTH values for that axis. X/Square switches the active edit between Value 1 and Value 2. Up/Down changes only the active value and applies it immediately. Turn this off when you want normal controller behavior.",
    config.controllerTuningEnabled == true,
    false,
    function(value)
      config.controllerTuningEnabled = value == true
      commit(true, false, "controller tuning switch")
      if config.controllerTuningEnabled then
        showControllerPopup(controllerStatusText("Controller ON:"))
      else
        showControllerPopup("SPLAT Rig Controller Tuning OFF")
      end
    end,
    8
  )

  nativeSettings.addRangeFloat(
    MASTER,
    "Controller Up / Down Step",
    "How much one Up or Down press adds or subtracts from the active X/Y/Z angle value.",
    1.0,
    100.0,
    1.0,
    "%.0f",
    tonumber(config.controllerStep) or 1.0,
    1.0,
    function(value)
      config.controllerStep = clamp(value, 1.0, 100.0, 1.0)
      commit()
    end,
    9
  )

  nativeSettings.addButton(
    MASTER,
    "Restore All Supplied Rig Defaults",
    "Restores every body to the supplied rig values without changing the master enable switch. Child 19 angles return to zero by design.",
    "RESTORE ALL",
    10,
    function()
      local wasEnabled = config.enabled == true
      local wasMatched = config.matchPairedBodies == true
      local wasControllerTuning = config.controllerTuningEnabled == true
      local controllerStep = config.controllerStep
      local controllerAxis = config.controllerAxis
      local controllerValueSlot = config.controllerValueSlot
      local nextApplyRequest = (config.applyRequest + 1) % 2147483647
      config = deepCopy(defaults)
      config.enabled = wasEnabled
      config.matchPairedBodies = wasMatched
      config.controllerTuningEnabled = wasControllerTuning
      config.controllerStep = controllerStep
      config.controllerAxis = controllerAxis
      config.controllerValueSlot = controllerValueSlot
      config.applyRequest = nextApplyRequest
      commit(true, true, "restore supplied rig defaults")
      buildBodySelector()
      buildEditor()
      logInfo("All supplied rig defaults restored; reopen the tab to refresh master controls")
    end
  )

  buildEditor()
end

registerForEvent("onInit", function()
  config = loadSettings()
  flushCommit()
  nativeSettings = GetMod("nativeSettings")
  if not nativeSettings then
    logError("Native Settings is not installed or did not load")
    return
  end
  local ok, err = pcall(buildMenu)
  if not ok then
    logError("Menu build failed: " .. tostring(err))
    return
  end

  Observe("PlayerPuppet", "OnAction", function(_, action)
    handleControllerAction(action)
  end)

  logInfo("V22-BOTH-VALUES-CONTROLLER-TUNER-MAN-BASE loaded; runtime profile is " .. (config.enabled and "ENABLED" or "disabled"))
end)

registerForEvent("onUpdate", function(deltaTime)
  if not config or not savePending then
    return
  end
  saveCountdown = saveCountdown - (tonumber(deltaTime) or 0.0)
  if saveCountdown <= 0.0 then
    flushCommit()
  end
end)

registerForEvent("onOverlayClose", function()
  if config and savePending then
    flushCommit()
  end
end)

registerForEvent("onShutdown", function()
  if config then
    flushCommit(false, "shutdown save")
  end
end)
