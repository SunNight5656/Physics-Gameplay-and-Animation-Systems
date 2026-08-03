-- SPLAT Physics 11.1 - V157 REDscript load-order compile fix
-- Architecture: Native Settings callbacks -> live PlayerPuppet -> REDscript settings state.
-- No external runtime framework, Mod Settings, permanent update loop, or repeated player polling.

local TAB = "/splatPhysics11"
local TAB_KEY = "splatPhysics11"
local GLOBAL_PATH = TAB .. "/global"
local IMPULSE_PATH = TAB .. "/global_impulse"
local MOTORCYCLE_PATH = TAB .. "/global_motorcycles"
local ANIMATION_PATH = TAB .. "/animation_controls"
local VANILLA_PATH = TAB .. "/vanilla_impulse_control"

local nativeSettings, schema, uiConfig
local livePlayer = nil
local bridgeConnected = false
local settingsStore = nil
local restoreQueue = {}
local restoreCursor = 1
local sectionCache = {}
local dynamicRefs = {}
local globalModeRef = nil
local initialized = false
local STATE_VERSION = 160
local BRIDGE_VERSION = 139
local SESSION_TOKEN = 139
local LEGACY_VISIBILITY_BASELINE_MARKER = "V158 closed every menu and situational disclosure by default"
local settingsDirty = false
local uiDirty = false
local persistenceWriteLogged = false

local function logi(x) spdlog.info("[SPLAT Native Settings V157] " .. tostring(x)) end
local function loge(x) spdlog.error("[SPLAT Native Settings V157] " .. tostring(x)) end
local function cn(s) return CName.new(s or "") end

local function scriptDir()
  local ok, info = pcall(function() return debug.getinfo(1, "S") end)
  if ok and info and type(info.source) == "string" and info.source:sub(1,1) == "@" then
    return info.source:sub(2):match("^(.*[\\/])") or ""
  end
  return ""
end
local MOD_DIR = scriptDir()
local INDEX_FILE = MOD_DIR .. "schema_index.json"
-- Mutable state deliberately uses files that are not shipped in the archive.
-- Under MO2, newly created files are routed to Overwrite instead of attempting
-- to replace the read-only/mod-origin copy that supplied init.lua.
local USER_UI_FILE = MOD_DIR .. "user_ui.json"
local USER_SETTINGS_FILE = MOD_DIR .. "user_settings.json"
local LEGACY_UI_FILE = MOD_DIR .. "ui_config.json"
local LEGACY_SETTINGS_FILE = MOD_DIR .. "settings.json"

local function readRaw(path)
  local f, err = io.open(path, "r")
  if not f then return nil, err end
  local ok, raw = pcall(function()
    local value = f:read("*a")
    f:close()
    return value
  end)
  if not ok then
    pcall(function() f:close() end)
    return nil, raw
  end
  return raw, nil
end

local function readJsonFile(path, quietMissing)
  local raw, err = readRaw(path)
  if raw == nil then
    if not quietMissing then loge("Cannot read " .. path .. ": " .. tostring(err)) end
    return nil, "missing"
  end
  local ok, value = pcall(json.decode, raw)
  if not ok or type(value) ~= "table" then
    loge("Invalid JSON " .. path .. ": " .. tostring(value))
    return nil, "invalid"
  end
  return value, "ok"
end

local function readJson(path)
  local value = readJsonFile(path, false)
  return value
end

local function writeRawVerified(path, raw)
  local f, err = io.open(path, "w")
  if not f then
    loge("Cannot write " .. path .. ": " .. tostring(err))
    return false
  end
  local ok, writeErr = pcall(function()
    f:write(raw)
    f:flush()
    f:close()
  end)
  if not ok then
    pcall(function() f:close() end)
    loge("Write failed " .. path .. ": " .. tostring(writeErr))
    return false
  end
  local check, readErr = readRaw(path)
  if check == nil then
    loge("Cannot verify " .. path .. ": " .. tostring(readErr))
    return false
  end
  if check ~= raw then
    loge("Write verification mismatch for " .. path)
    return false
  end
  return true
end

local function writeJsonVerified(path, value)
  local encodedOk, raw = pcall(json.encode, value)
  if not encodedOk then
    loge("Cannot encode " .. path .. ": " .. tostring(raw))
    return false
  end

  -- Verify a temporary copy first, then write the final file directly. The old
  -- remove+rename sequence can be unreliable through virtual filesystems.
  local temp = path .. ".tmp"
  if not writeRawVerified(temp, raw) then return false end

  local previous = readRaw(path)
  if previous ~= nil then
    -- A valid previous copy gives recovery from interruption or corruption.
    writeRawVerified(path .. ".bak", previous)
  end

  local finalOk = writeRawVerified(path, raw)
  pcall(function() os.remove(temp) end)
  if not finalOk and previous ~= nil then
    writeRawVerified(path, previous)
  end
  return finalOk
end

local function loadPersistent(primary, legacy, label)
  local value, status = readJsonFile(primary, true)
  if status == "ok" then return value, "primary" end

  local backup, backupStatus = readJsonFile(primary .. ".bak", true)
  if backupStatus == "ok" then
    logi("Recovered " .. label .. " from backup")
    return backup, "backup"
  end

  -- A corrupt primary should not be silently replaced by a packaged/default
  -- legacy file. Preserve it for diagnosis and wait for an explicit user change.
  if status == "invalid" then return nil, "invalid" end

  local old, oldStatus = readJsonFile(legacy, true)
  if oldStatus == "ok" then
    logi("Migrating legacy " .. label .. " into the MO2-safe user file")
    return old, "legacy"
  end
  return nil, status
end

local function merge(value, defaults)
  if type(value) ~= "table" then value = {} end
  for k, v in pairs(defaults) do
    if type(v) == "table" then value[k] = merge(value[k], v)
    elseif value[k] == nil then value[k] = v end
  end
  return value
end

local function defaultUI()
  local out = {version = STATE_VERSION, impulseSections = {random = false, moveFeet = false, motorcycle = false}, modes = {}, gates = {}, situationalGroups = {}, bottomSections = {moveNpcFeet = false}}
  for _, mode in ipairs(schema.modes) do
    out.modes[mode.key] = {showAll = false, topics = {}}
    out.situationalGroups[mode.key] = {}
    for _, topic in ipairs(schema.topics) do out.modes[mode.key].topics[topic.key] = false end
  end
  return out
end

local function saveUI(force)
  if not uiConfig then return false end
  if not force and not uiDirty then return true end
  uiConfig.version = STATE_VERSION
  if not writeJsonVerified(USER_UI_FILE, uiConfig) then
    uiDirty = true
    return false
  end
  uiDirty = false
  return true
end

-- Do not override Native Settings internals. Earlier SPLAT builds replaced
-- getOptionTable/pathExists/removeOption/removeSubcategory and broke controller
-- input. V129 uses the installed Native Settings API unchanged.


local function settingKey(setting)
  return tostring(setting.mode or "global") .. "|" .. tostring(setting.class) .. "." .. tostring(setting.name)
end

local function defaultSettingsStore()
  return {version = STATE_VERSION, writeSerial = 0, valueCount = 0, values = {}}
end

local function savedValueCount()
  local count = 0
  for _ in pairs((settingsStore and settingsStore.values) or {}) do count = count + 1 end
  return count
end

local function saveSettingsNow(force)
  if not settingsStore then return false end
  if not force and not settingsDirty then return true end

  local oldSerial = math.floor(tonumber(settingsStore.writeSerial) or 0)
  settingsStore.version = STATE_VERSION
  settingsStore.writeSerial = oldSerial + 1
  settingsStore.valueCount = savedValueCount()
  if not writeJsonVerified(USER_SETTINGS_FILE, settingsStore) then
    settingsStore.writeSerial = oldSerial
    settingsDirty = true
    return false
  end

  settingsDirty = false
  if not persistenceWriteLogged then
    persistenceWriteLogged = true
    logi("PERSISTENCE WRITE VERIFIED: " .. tostring(settingsStore.valueCount) .. " saved gameplay values; serial=" .. tostring(settingsStore.writeSerial))
  end
  return true
end

local function saveSettingsDebounced()
  -- Native Settings already tells SPLAT exactly when a value changes. Keep the
  -- in-memory value live immediately and write the JSON once when the SPLAT tab
  -- or CET overlay closes (with onShutdown as a final backup).
  settingsDirty = true
end

local function resolveBridge(playerHint)
  -- Fast path: once this PlayerPuppet has passed bridge/version validation, menu
  -- callbacks reuse it directly. IsDefined protects against stale native handles.
  if not playerHint and bridgeConnected and livePlayer and IsDefined(livePlayer) then
    return livePlayer
  end

  -- The player is normally supplied by PlayerPuppet.OnGameAttached. A direct
  -- Game.GetPlayer probe is used only on explicit events (CET init/reload,
  -- overlay open, or a user setting callback), never from a permanent loop.
  local player = playerHint or livePlayer
  if not player or not IsDefined(player) then
    local ok, current = pcall(function() return Game.GetPlayer() end)
    if ok then player = current end
  end
  if not player or not IsDefined(player) then
    livePlayer = nil
    bridgeConnected = false
    return nil
  end

  if livePlayer ~= player then
    livePlayer = player
    bridgeConnected = false
  else
    livePlayer = player
  end

  local vok, version = pcall(function() return player:SPLATGetBridgeVersion() end)
  if not vok or tonumber(version) ~= BRIDGE_VERSION then
    bridgeConnected = false
    return nil
  end

  local tokOk, token = pcall(function() return player:SPLATGetSessionToken() end)
  if not tokOk then
    bridgeConnected = false
    return nil
  end
  if tonumber(token) ~= SESSION_TOKEN then
    local markOk = pcall(function() player:SPLATSetSessionToken(SESSION_TOKEN) end)
    if not markOk then
      bridgeConnected = false
      return nil
    end
    restoreCursor = 1
    logi("Detected a new live PlayerPuppet settings state; replaying saved values")
  end

  if not bridgeConnected then
    bridgeConnected = true
    restoreCursor = 1
    logi("Direct REDscript player bridge connected")
  end
  return player
end
local function storedEntry(setting)
  if not settingsStore or not settingsStore.values then return nil end
  return settingsStore.values[settingKey(setting)]
end

local function readVar(setting, useDefault)
  if useDefault then return setting.default end
  local entry = storedEntry(setting)
  if type(entry) == "table" and entry.value ~= nil then return entry.value end
  if entry ~= nil and type(entry) ~= "table" then return entry end
  return setting.default
end

local function callBridgeSet(setting, value, bridge)
  local b = bridge or resolveBridge()
  if not b then return false end
  local ok, applied = pcall(function()
    if setting.type == "Bool" then return b:SPLATSetBool(cn(setting.mode or "global"), cn(setting.class), cn(setting.name), value == true) end
    if setting.type == "Float" then return b:SPLATSetFloat(cn(setting.mode or "global"), cn(setting.class), cn(setting.name), tonumber(value) or 0.0) end
    if setting.type == "Int32" then return b:SPLATSetInt(cn(setting.mode or "global"), cn(setting.class), cn(setting.name), math.floor(tonumber(value) or 0)) end
    if setting.type == "RFCSplatPresetMode" then return b:SPLATSetMode(math.floor(tonumber(value) or 1)) end
    return false
  end)
  if not ok or applied ~= true then
    loge("REDscript rejected " .. tostring(setting.id) .. ": " .. tostring(applied))
    return false
  end
  return true
end
local function writeVar(setting, value, immediate)
  -- Native Settings callbacks are the change notification. Persist in memory,
  -- apply once to the current player, and write JSON only when the tab/overlay
  -- closes. A future PlayerPuppet rebuilds its restore queue from settingsStore.
  settingsStore.values[settingKey(setting)] = {type = setting.type, value = value}
  saveSettingsDebounced()

  local bridge = resolveBridge()
  if not bridge then return true end
  if not callBridgeSet(setting, value, bridge) then
    loge("Live apply failed; saved value will replay on the next player attach: " .. tostring(setting.id))
    return false
  end
  return true
end
local function migrateObsoleteShoulderButtSettings()
  local values = settingsStore.values or {}
  local migrated = 0

  local function copyIfMissing(oldKey, newKey)
    local oldEntry = values[oldKey]
    if oldEntry ~= nil and values[newKey] == nil then
      values[newKey] = oldEntry
      migrated = migrated + 1
    end
  end

  -- V138 and several earlier test builds used separate legacy names. The live
  -- V139 REDscript settings object uses the unified Shoulder/Waist fields.
  copyIfMissing("realismCustom|RFCModSettings.buttImpactDelay",
                "realismCustom|RFCModSettings.shoulderHipImpactDelay")
  copyIfMissing("realismCustom|RFCModSettings.buttImpactRadius",
                "realismCustom|RFCModSettings.shoulderHipImpactRadius")
  copyIfMissing("realismCustom|RFCModSettings.buttImpactFallEnabled",
                "realismCustom|RFCModSettings.shoulderHipImpactButtEnabled")
  copyIfMissing("realismCustom|RFCModSettings.shoulderImpactFallEnabled",
                "realismCustom|RFCModSettings.shoulderHipImpactShoulderEnabled")
  copyIfMissing("realismCustom|RFCModSettings.shoulderHipEarlyFallEnabled",
                "realismCustom|RFCModSettings.shoulderHipEarlyShoulderEnabled")
  copyIfMissing("realismCustom|RFCModSettings.shoulderHipEarlyFallEnabled",
                "realismCustom|RFCModSettings.shoulderHipEarlyButtEnabled")
  copyIfMissing("realismCustom|RFCModSettings.shoulderHipImpactFallEnabled",
                "realismCustom|RFCModSettings.shoulderHipImpactShoulderEnabled")
  copyIfMissing("realismCustom|RFCModSettings.shoulderHipImpactFallEnabled",
                "realismCustom|RFCModSettings.shoulderHipImpactButtEnabled")

  local obsolete = {
    "realismCustom|RFCModSettings.buttImpactDelay",
    "realismCustom|RFCModSettings.buttImpactFallEnabled",
    "realismCustom|RFCModSettings.buttImpactRadius",
    "realismCustom|RFCModSettings.shoulderHipEarlyFallEnabled",
    "realismCustom|RFCModSettings.shoulderHipImpactFallEnabled",
    "realismCustom|RFCModSettings.shoulderImpactFallEnabled"
  }
  local removed = 0
  for _, key in ipairs(obsolete) do
    if values[key] ~= nil then
      values[key] = nil
      removed = removed + 1
    end
  end

  if migrated > 0 or removed > 0 then
    settingsDirty = true
    logi("Migrated " .. tostring(migrated) .. " and removed " .. tostring(removed) .. " obsolete Shoulder/Butt saved values")
  end
end

local function buildRestoreQueue()
  restoreQueue = {}
  restoreCursor = 1
  for key, entry in pairs(settingsStore.values or {}) do
    local mode, cls, name = key:match("^([^|]+)|([^.]+)%.(.+)$")
    if mode and cls and name then
      if type(entry) == "table" and entry.type and entry.value ~= nil then
        table.insert(restoreQueue, {id = key, mode = mode, class = cls, name = name, type = entry.type, value = entry.value})
      end
    end
  end
  table.sort(restoreQueue, function(a,b) return a.id < b.id end)
end

local function processRestoreQueue()
  if restoreCursor > #restoreQueue then return true end
  local bridge = resolveBridge()
  if not bridge then return false end

  local examined = 0
  while restoreCursor <= #restoreQueue do
    local item = restoreQueue[restoreCursor]
    if callBridgeSet(item, item.value, bridge) then
      restoreCursor = restoreCursor + 1
      examined = examined + 1
    else
      -- A valid bridge returned false, so this is a stale/unsupported key rather
      -- than a lifecycle delay. Remove it and continue; never retry forever.
      loge("Discarding unsupported saved value and continuing restore: " .. tostring(item.id))
      if settingsStore.values then settingsStore.values[item.id] = nil end
      settingsDirty = true
      restoreCursor = restoreCursor + 1
      examined = examined + 1
    end
  end
  logi("Event-driven restore completed with " .. tostring(examined) .. " examined saved values")
  return true
end
local function sectionFile(modeKey, topicKey)
  local modeFiles = schema.sectionFiles[modeKey] or {}
  return modeFiles[topicKey]
end
local function loadSection(modeKey, topicKey)
  local key = modeKey .. "/" .. topicKey
  if sectionCache[key] ~= nil then return sectionCache[key] end
  local rel = sectionFile(modeKey, topicKey)
  if not rel then sectionCache[key] = false; return nil end
  local data = readJson(MOD_DIR .. rel)
  sectionCache[key] = data or false
  return data
end

local function topicPath(mode, topic) return TAB .. "/mode_" .. mode.key .. "_" .. topic.key end
local function topicExists(mode, topic) return sectionFile(mode.key, topic.key) ~= nil end
local function isVanillaImpulseSetting(setting)
  local marker = string.lower(tostring(setting.id or "") .. " " .. tostring(setting.name or "") .. " " .. tostring(setting.label or ""))
  return marker:find("vanilla", 1, true) ~= nil
end
local function isMotorcycleSetting(setting)
  local marker = string.lower(tostring(setting.id or "") .. " " .. tostring(setting.name or "") .. " " .. tostring(setting.label or ""))
  return marker:find("motorcycle", 1, true) ~= nil
end
local function isVehicleExplosionSetting(setting)
  local marker = string.lower(tostring(setting.id or "") .. " " .. tostring(setting.name or "") .. " " .. tostring(setting.label or ""))
  return marker:find("vehicleexplosion", 1, true) ~= nil or marker:find("vehicle explosion", 1, true) ~= nil
end
local function filteredSettings(settings, predicate, invert)
  local out = {}
  for _, setting in ipairs(settings or {}) do
    local matched = predicate(setting)
    if (matched and not invert) or (not matched and invert) then table.insert(out, setting) end
  end
  return out
end
local function uiGateBucket(context)
  uiConfig.gates[context] = uiConfig.gates[context] or {}
  return uiConfig.gates[context]
end

local function sectionMaps(settings)
  local lookup, gates = {}, {}
  for _, s in ipairs(settings or {}) do lookup[s.id] = s end
  for _, s in ipairs(settings or {}) do if s.dependency and lookup[s.dependency] then gates[s.dependency] = true end end
  return lookup, gates
end
local function isShowGate(setting, gates)
  return setting.uiOnly == true or (gates[setting.id] and setting.type == "Bool" and type(setting.label) == "string" and setting.label:sub(1,5) == "Show ")
end
local function gateState(setting, gates, context)
  if isShowGate(setting, gates) then
    local bucket = uiGateBucket(context)
    -- Every major mode section starts collapsed. Its master gate hides or
    -- reveals child Show switches without changing any of their saved states.
    if bucket[setting.id] == nil then
      bucket[setting.id] = setting._sectionMaster == true and false or false
    end
    return bucket[setting.id]
  end
  return readVar(setting, false)
end
local function dependencyOK(setting, lookup, gates, context, seen)
  if not setting.dependency or not lookup[setting.dependency] then return true end
  seen = seen or {}
  if seen[setting.id] then return false end
  seen[setting.id] = true
  local parent = lookup[setting.dependency]
  return dependencyOK(parent, lookup, gates, context, seen) and gateState(parent, gates, context) == true
end

local function remember(path, ref)
  if not ref then return end
  dynamicRefs[path] = dynamicRefs[path] or {}
  table.insert(dynamicRefs[path], ref)
end
local function clearDynamic(path)
  local refs = dynamicRefs[path] or {}
  for i = #refs, 1, -1 do pcall(function() nativeSettings.removeOption(refs[i]) end) end
  dynamicRefs[path] = {}
end
local function defer(fn)
  -- Native Settings supports adding/removing options and subcategories while its
  -- UI is active. Run only the requested rebuild from the option callback; no
  -- permanent frame queue is needed.
  if type(fn) ~= "function" then return end
  local ok, err = pcall(fn)
  if not ok then loge("Dynamic UI update failed: " .. tostring(err)) end
end

local hiddenNonRuntimeControls = {
  -- These legacy controls have no distinct runtime channel. Keeping them
  -- visible implied precision the scheduler cannot provide.
  overrideGrenade = true,
  tumbleStairs_downDelay = true,
  tumbleStairs_sideDelay = true,
  tumbleStairs_yawDeg = true,
  tumbleStairs_pitchDeg = true,
  tumbleStairs_rollDeg = true,
  tumbleDir_sideDelay = true,
  -- The old mounted-hit shield is intentionally not implemented: it could
  -- make ordinary workspot and vehicle occupants appear invulnerable.
  vehicleMountedHitImmunity = true
}

local function suppressDuplicateOrDeadControl(setting, context)
  if not setting or hiddenNonRuntimeControls[setting.name] then return true end

  -- Vehicle melee controls belong to the combined Arcade / Regular Bullet and
  -- Melee Push section. Do not register a second copy under Vehicles.
  if type(context) == "string" and context:find("/vehicles", 1, true) then
    local n = setting.name or ""
    if n:find("vehicleMelee", 1, true)
      or n:find("vehicleAllowBlunt", 1, true)
      or n:find("vehicleMulBlunt", 1, true)
      or n:find("vehicleAllowBlade", 1, true)
      or n:find("vehicleMulBlade", 1, true)
      or n:find("vehicleAllowGorilla", 1, true)
      or n:find("vehicleMulGorilla", 1, true) then
      return true
    end
  end
  return false
end

local function addSetting(path, setting, index, context, gates, rebuild, collect)
  if suppressDuplicateOrDeadControl(setting, context) then return nil end
  local current = gateState(setting, gates, context)
  local default = isShowGate(setting, gates) and (false) or readVar(setting, true)
  local desc = setting.description or ""
  local ref
  if setting.type == "Bool" then
    ref = nativeSettings.addSwitch(path, setting.label, desc, current, default, function(value)
      if isShowGate(setting, gates) then
        local bucket = uiGateBucket(context)
        bucket[setting.id] = value
        uiDirty = true
        if rebuild then defer(rebuild) end
      else
        writeVar(setting, value, true)
      end
    end, index)
  elseif setting.type == "Float" then
    local mn = setting.min or 0.0
    local mx = setting.max or math.max(10.0, math.abs(current or 0.0) * 2.0)
    if mx <= mn then mx = mn + 1.0 end
    ref = nativeSettings.addRangeFloat(path, setting.label, desc, mn, mx, setting.step or 0.05, "%.2f", current, default,
      function(value) writeVar(setting, value, false) end, index)
  elseif setting.type == "Int32" then
    local mn = math.floor(setting.min or 0)
    local mx = math.floor(setting.max or math.max(100, math.abs(current or 0) * 2))
    if mx <= mn then mx = mn + 1 end
    ref = nativeSettings.addRangeInt(path, setting.label, desc, mn, mx, math.max(1, math.floor(setting.step or 1)), current, default,
      function(value) writeVar(setting, value, false) end, index)
  elseif setting.type == "RFCSplatPresetMode" then
    local labels = {}
    for i, mode in ipairs(schema.modes) do labels[i] = mode.label end
    ref = nativeSettings.addSelectorString(path, setting.label, desc, labels, current, default,
      function(value)
        writeVar(setting, math.floor(value), true)
        if rebuild then defer(rebuild) end
      end, index)
  end
  if collect then remember(path, ref) end
  return ref
end

local function addSettings(path, settings, startIndex, context, rebuild, collect)
  local scope = context:match("^mode/([^/]+)") or "global"
  local scopedSettings = {}
  for _, setting in ipairs(settings or {}) do
    local copy = {}
    for key, value in pairs(setting) do copy[key] = value end
    copy.mode = scope
    table.insert(scopedSettings, copy)
  end
  -- The first UI-only Bool in a mode topic is that topic's master visibility
  -- gate. Dependencies remain intact so turning it off hides every child Show
  -- switch but does not overwrite the child's state.
  for _, setting in ipairs(scopedSettings) do
    if setting.uiOnly == true and setting.type == "Bool" then
      setting._sectionMaster = true
      break
    end
  end
  local lookup, gates = sectionMaps(scopedSettings)
  local idx = startIndex or 1
  for _, setting in ipairs(scopedSettings) do
    if dependencyOK(setting, lookup, gates, context) then
      addSetting(path, setting, idx, context, gates, rebuild, collect)
      idx = idx + 1
    end
  end
  return idx
end

local rebuildGlobalImpulseControls

local function sharedPath(section)
  if section.key == "globalImpulse" then return IMPULSE_PATH end
  if section.key == "motorcycles" then return MOTORCYCLE_PATH end
  return ANIMATION_PATH
end

local function rebuildShared(section)
  if section.key == "globalImpulse" then
    rebuildGlobalImpulseControls(section)
    return
  end
  local path = sharedPath(section)
  clearDynamic(path)
  local context = "shared/" .. section.key
  local function again() rebuildShared(section) end
  addSettings(path, section.settings or {}, 1, context, again, true)
end

local function copySettingEarly(setting)
  local out = {}
  for key, value in pairs(setting or {}) do out[key] = value end
  return out
end

local function situationalGroupPath(mode, groupKey)
  return TAB .. "/mode_" .. mode.key .. "_situational_" .. groupKey
end

local function rebuildTopic(mode, topic)
  local path = topicPath(mode, topic)
  clearDynamic(path)
  local data = loadSection(mode.key, topic.key)
  if not data then return end
  local context = "mode/" .. mode.key .. "/" .. topic.key
  local function again() rebuildTopic(mode, topic) end
  if topic.key == "arcade" then
    local bullet = filteredSettings(data.settings or {}, isVanillaImpulseSetting, true)
    local combined = {}
    for _, setting in ipairs(bullet) do table.insert(combined, setting) end
    local arcadeMaster = nil
    for _, setting in ipairs(bullet) do
      if setting.uiOnly == true and setting.type == "Bool" then arcadeMaster = setting.id; break end
    end
    local vehicles = loadSection(mode.key, "vehicles")
    if vehicles then
      local vehicleMaster = nil
      for _, setting in ipairs(vehicles.settings or {}) do
        if setting.uiOnly == true and setting.type == "Bool" then vehicleMaster = setting.id; break end
      end
      for _, setting in ipairs(vehicles.settings or {}) do
        if setting.id ~= vehicleMaster and not isMotorcycleSetting(setting) and not isVehicleExplosionSetting(setting) then
          local copy = copySettingEarly(setting)
          if copy.dependency == vehicleMaster then
            copy.dependency = arcadeMaster
            copy.dependencyName = arcadeMaster and (arcadeMaster:match("([^.]+)$") or "") or ""
          end
          table.insert(combined, copy)
        end
      end
    end
    addSettings(path, combined, 1, context, again, true)
    return
  elseif topic.key == "explosions" then
    addSettings(path, data.settings or {}, 1, context, again, true)
    local vehicles = loadSection(mode.key, "vehicles")
    if vehicles then
      addSettings(path, filteredSettings(vehicles.settings or {}, isVehicleExplosionSetting, false),
        500, "mode/" .. mode.key .. "/vehicleExplosions", again, true)
    end
    return
  elseif topic.key ~= "situational" then
    addSettings(path, data.settings or {}, 1, context, again, true)
    return
  end

  for _, group in ipairs(data.groups or {}) do
    local oldPath = situationalGroupPath(mode, group.key)
    if nativeSettings.pathExists(oldPath) then nativeSettings.removeSubcategory(oldPath) end
    dynamicRefs[oldPath] = nil
  end

  local idx = 1
  uiConfig.situationalGroups[mode.key] = uiConfig.situationalGroups[mode.key] or {}
  local state = uiConfig.situationalGroups[mode.key]
  if state.__master == nil then state.__master = false end
  for _, group in ipairs(data.groups or {}) do
    if state[group.key] == nil then state[group.key] = false end
  end

  local allRef = nativeSettings.addSwitch(
    path,
    "Show Situational Fall Sections",
    "Shows or hides the separate Standing, Walking & Running, Workspots, Cower, Stairs, and Gravity categories. Saved controls are not changed.",
    state.__master == true,
    false,
    function(value)
      state.__master = value
      uiDirty = true
      defer(again)
    end,
    idx
  )
  remember(path, allRef)
  if state.__master ~= true then return end

  local function makeShow(id, label, description)
    return {id = id, name = id, type = "Bool", default = false, label = label, description = description, uiOnly = true}
  end
  local function classify(setting)
    local n = string.lower(setting.name or "")
    if n:find("head", 1, true) or n:find("antituck", 1, true) then return "head" end
    if n:find("knee", 1, true) then return "knee" end
    if n:find("forward", 1, true) or n:find("fwd", 1, true) or n:find("anchor", 1, true) or n:find("brake", 1, true) then return "forward" end
    if n:find("chest", 1, true) or n:find("vslam", 1, true) then return "shoulder" end
    if n:find("pelvis", 1, true) then return "butt" end
    return "other"
  end

  for groupIndex, group in ipairs(data.groups or {}) do
    local gkey = group.key
    local groupPath = situationalGroupPath(mode, gkey)
    local groupLabel = group.label
    if gkey == "runningWalking" then groupLabel = "Walking & Running" end
    -- These are sibling Native Settings categories, so their explicit indexes
    -- must immediately follow Situational Falls. The old 100+ indexes forced
    -- every opened situation below Tumble.
    nativeSettings.addSubcategory(groupPath, mode.label .. " - " .. groupLabel, 8 + groupIndex)
    dynamicRefs[groupPath] = {}

    local open = state[gkey] == true
    local ref = nativeSettings.addSwitch(groupPath, group.showLabel, group.description or "", open, false, function(value)
      state[gkey] = value
      uiDirty = true
      defer(again)
    end, 1)
    remember(groupPath, ref)

    if open then
      if gkey == "gravity" then
        addSettings(groupPath, group.settings or {}, 2, context .. "/" .. gkey, again, true)
      else
        local buckets = {head = {}, forward = {}, shoulder = {}, butt = {}, knee = {}, other = {}, advanced = {}}
        for _, setting in ipairs(group.settings or {}) do
          local n = string.lower(setting.name or "")
          local technical = n:find("delay", 1, true) or n:find("radius", 1, true) or n:find("offset", 1, true) or n:find("timing", 1, true)
          local oldMaster = n == "overridestand" or n == "overriderun" or n == "overrideworkspots" or n == "overridecower" or n == "overridestairs"
          if not oldMaster then
            table.insert(technical and buckets.advanced or buckets[classify(setting)], copySettingEarly(setting))
          end
        end

        local headNames = {
          standing = "st_overrideGlobalHead",
          runningWalking = "run_overrideGlobalHead",
          cower = "cow_overrideGlobalHead",
          stairs = "stair_overrideGlobalHead"
        }
        if headNames[gkey] then
          table.insert(buckets.head, 1, {
            id = "RFCModSettings." .. headNames[gkey], class = "RFCModSettings",
            name = headNames[gkey], type = "Bool", default = false,
            label = "Override General Head Falls",
            description = "Uses this situation's Head controls instead of General Head Falls.",
            modeScoped = true
          })
        end
        if gkey == "runningWalking" then
          table.insert(buckets.head, {
            id = "RFCModSettings.run_downHeadMin", class = "RFCModSettings",
            name = "run_downHeadMin", type = "Float", default = 0.0,
            label = "Walking & Running Head Down Strength - Minimum",
            description = "Minimum downward Head force for Walking & Running.",
            min = 0.0, max = 1000.0, step = 0.01, modeScoped = true
          })
          table.insert(buckets.head, {
            id = "RFCModSettings.run_downHead", class = "RFCModSettings",
            name = "run_downHead", type = "Float", default = 0.0,
            label = "Walking & Running Head Down Strength - Maximum",
            description = "Maximum downward Head force for Walking & Running.",
            min = 0.0, max = 1000.0, step = 0.01, modeScoped = true
          })
        end

        local function radiusSetting(name, label, defaultValue)
          return {
            id = "RFCModSettings." .. name, class = "RFCModSettings",
            name = name, type = "Float", default = defaultValue,
            label = label, description = "Impulse influence radius for this situation component.",
            min = 0.05, max = 5.0, step = 0.01, modeScoped = true
          }
        end
        if gkey == "standing" then
          table.insert(buckets.advanced, radiusSetting("st_headRadius", "Standing Head Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("st_forwardRadius", "Standing Forward Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("st_chestRadius", "Standing Shoulder / Chest Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("st_pelvisRadius", "Standing Butt / Waist Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("st_kneeRadius", "Standing Knee Radius", 0.70))
        elseif gkey == "runningWalking" then
          table.insert(buckets.advanced, radiusSetting("run_headRadius", "Walking & Running Head Radius", 1.70))
          table.insert(buckets.advanced, radiusSetting("run_forwardRadius", "Walking & Running Forward Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("run_chestRadius", "Walking & Running Shoulder / Chest Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("run_pelvisRadius", "Walking & Running Butt / Waist Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("run_kneeRadius", "Walking & Running Knee Radius", 0.55))
          table.insert(buckets.advanced, radiusSetting("run_vSlamRadius", "Walking & Running Slam Radius", 0.98))
        elseif gkey == "stairs" then
          table.insert(buckets.advanced, radiusSetting("stair_headRadius", "Stairs Head Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("stair_forwardRadius", "Stairs Forward Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("stair_chestRadius", "Stairs Shoulder / Chest Radius", 0.70))
          table.insert(buckets.advanced, radiusSetting("stair_pelvisRadius", "Stairs Butt / Waist Radius", 0.70))
        end

        local arranged = {}
        local sections = {
          {"head", "Show Head Falls", "Shows the independent Head override and Head controls."},
          {"forward", "Show Forward Falls", "Shows the independent Forward override and Forward controls."},
          {"shoulder", "Show Shoulder Falls", "Shows the independent Shoulder/Chest override and controls."},
          {"butt", "Show Butt / Waist Falls", "Shows the independent Butt/Waist override and controls."},
          {"knee", "Show Knee Falls", "Shows the independent Knee override and controls."},
          {"other", "Show Additional Situation Controls", "Shows remaining controls specific to this situation."}
        }
        for _, spec in ipairs(sections) do
          local values = buckets[spec[1]]
          if #values > 0 then
            local gateId = "ui." .. mode.key .. ".situational." .. gkey .. "." .. spec[1]
            table.insert(arranged, makeShow(gateId, spec[2], spec[3]))
            for _, setting in ipairs(values) do
              setting.dependency = gateId
              setting.dependencyName = gateId
              table.insert(arranged, setting)
            end
          end
        end
        if #buckets.advanced > 0 then
          local advancedId = "ui." .. mode.key .. ".situational." .. gkey .. ".timingRadiusOffset"
          table.insert(arranged, makeShow(advancedId, "Show Timing, Radius & Offset Controls", "Shows detailed timing, radius, and offset controls."))
          for _, setting in ipairs(buckets.advanced) do
            setting.dependency = advancedId
            setting.dependencyName = advancedId
            table.insert(arranged, setting)
          end
        end
        addSettings(groupPath, arranged, 2, context .. "/" .. gkey, again, true)
      end
    end
  end
  if data.settings and #data.settings > 0 then addSettings(path, data.settings, 2, context .. "/direct", again, true) end
end

local function addTopicCategory(mode, topic, index)
  local path = topicPath(mode, topic)
  nativeSettings.addSubcategory(path, topic.label, index)
  dynamicRefs[path] = {}
  rebuildTopic(mode, topic)
end

local function rebuildVanillaImpulseControl(mode)
  clearDynamic(VANILLA_PATH)
  local data = loadSection(mode.key, "arcade")
  if not data then return end
  local settings = filteredSettings(data.settings or {}, isVanillaImpulseSetting, false)
  local function again() rebuildVanillaImpulseControl(mode) end
  addSettings(VANILLA_PATH, settings, 1, "mode/" .. mode.key .. "/vanillaImpulse", again, true)
end

local function modeInsertIndex(targetModeIndex)
  local idx = 4
  for mi, mode in ipairs(schema.modes) do
    if mi >= targetModeIndex then break end
    if mode.key ~= "vanilla" and uiConfig.modes[mode.key].showAll then
      for _, topic in ipairs(schema.topics) do
        if topic.key ~= "randomization" and topicExists(mode, topic) then idx = idx + 1 end
      end
    end
  end
  return idx
end

local function removeModeCategories(mode)
  for _, topic in ipairs(schema.topics) do
    local path = topicPath(mode, topic)
    if nativeSettings.pathExists(path) then nativeSettings.removeSubcategory(path) end
    dynamicRefs[path] = nil
    if topic.key == "situational" then
      local data = loadSection(mode.key, topic.key)
      for _, group in ipairs((data and data.groups) or {}) do
        local groupPath = situationalGroupPath(mode, group.key)
        if nativeSettings.pathExists(groupPath) then nativeSettings.removeSubcategory(groupPath) end
        dynamicRefs[groupPath] = nil
      end
    end
  end
end

local function showModeCategories(mode, modeIndex)
  removeModeCategories(mode)
  if nativeSettings.pathExists(VANILLA_PATH) then nativeSettings.removeSubcategory(VANILLA_PATH) end
  dynamicRefs[VANILLA_PATH] = nil
  if mode.key == "vanilla" then return end
  local idx = 4
  local topicByKey = {}
  for _, topic in ipairs(schema.topics) do topicByKey[topic.key] = topic end
  for _, key in ipairs({"head", "body"}) do
    local topic = topicByKey[key]
    if topic and topicExists(mode, topic) then
      addTopicCategory(mode, topic, idx)
      idx = idx + 1
    end
  end
  local approvedOrder = {"situational", "arcade", "explosions", "bulletJolts", "trip", "twitch", "settle", "tumble"}
  for _, key in ipairs(approvedOrder) do
    local topic = topicByKey[key]
    if topic.key ~= "randomization" and topic.key ~= "head" and topic.key ~= "body"
      and topic.key ~= "vehicles" and topicExists(mode, topic) then
      addTopicCategory(mode, topic, idx)
      if topic.key == "situational" then
        -- Reserve indexes 9-14 for the opened situation categories.
        idx = 20
      else
        idx = idx + 1
      end
      if topic.key == "explosions" then
        nativeSettings.addSubcategory(VANILLA_PATH, "Vanilla Impulse Control", idx)
        dynamicRefs[VANILLA_PATH] = {}
        rebuildVanillaImpulseControl(mode)
        idx = idx + 1
      end
    end
  end
end

local globalStaticCount = 0
local globalModeSetting = nil

local function selectedMode()
  if not globalModeSetting then return schema.modes[1] end
  local selected = math.floor(tonumber(readVar(globalModeSetting, false)) or 1)
  for _, mode in ipairs(schema.modes or {}) do
    if tonumber(mode.enumIndex) == selected then return mode end
  end
  return schema.modes[1]
end

local function copySetting(setting)
  local out = {}
  for key, value in pairs(setting or {}) do out[key] = value end
  return out
end

local function globalMoveSettings()
  local section = (schema.bottomSections or {})[1]
  if not section then return {} end
  local out = {}
  for _, setting in ipairs(section.settings or {}) do
    local copy = copySetting(setting)
    -- The Global Impulse section owns visibility. Remove the old nested show gates.
    if copy.name ~= "showDetector" and copy.name ~= "showAdvancedMoveNPCsCorpseWithFeet" then
      copy.dependency = nil
      copy.dependencyName = ""
      table.insert(out, copy)
    end
  end
  return out
end

local function globalRandomSettings(mode)
  if not mode or mode.key == "vanilla" then return {} end
  local data = loadSection(mode.key, "randomization")
  if not data then return {} end
  local out = {}
  local advancedId = "ui." .. mode.key .. ".randomization.advanced"
  for i, setting in ipairs(data.settings or {}) do
    local copy = copySetting(setting)
    -- One Global Impulse show toggle owns this whole block.
    if copy.id ~= advancedId then
      if copy.dependency == advancedId then
        copy.dependency = nil
        copy.dependencyName = ""
      end
      if i == 1 then
        copy.label = "Enable Random Impulses - " .. mode.label
        copy.description = "Randomizes the selected " .. mode.label .. " profile inside each system's regular Minimum and Maximum sliders."
      end
      table.insert(out, copy)
    end
  end
  return out
end

local function globalMotorcycleSettings(mode)
  if not mode or mode.key == "vanilla" then return {} end
  local data = loadSection(mode.key, "vehicles")
  local out = {}
  local seen = {}
  for _, setting in ipairs((data and data.settings) or {}) do
    local marker = string.lower(tostring(setting.id or "") .. " " .. tostring(setting.name or "") .. " " .. tostring(setting.label or ""))
    if setting.uiOnly ~= true and string.find(marker, "motorcycle", 1, true) then
      local copy = copySetting(setting)
      copy.dependency = nil
      copy.dependencyName = ""
      table.insert(out, copy)
      seen[copy.id] = true
    end
  end
  -- The original shared motorcycle controls belong in Global, not in a second
  -- standalone category. Use them as the fallback for modes whose vehicle
  -- schema does not duplicate those controls.
  for _, section in ipairs(schema.sharedSections or {}) do
    if section.key == "motorcycles" then
      for _, setting in ipairs(section.settings or {}) do
        if setting.uiOnly ~= true and not seen[setting.id] then
          local copy = copySetting(setting)
          copy.dependency = nil
          copy.dependencyName = ""
          table.insert(out, copy)
          seen[copy.id] = true
        end
      end
    end
  end
  return out
end

local function addImpulseSectionToggle(label, description, key, idx, again)
  local ref = nativeSettings.addSwitch(IMPULSE_PATH, label, description,
    uiConfig.impulseSections[key] == true, false, function(value)
      uiConfig.impulseSections[key] = value
      uiDirty = true
      defer(again)
    end, idx)
  remember(IMPULSE_PATH, ref)
  return idx + 1
end

rebuildGlobalImpulseControls = function(section)
  clearDynamic(IMPULSE_PATH)
  local context = "shared/globalImpulse"
  local function again() rebuildGlobalImpulseControls(section) end

  -- Standard global impulse controls always remain visible.
  local idx = addSettings(IMPULSE_PATH, section.settings or {}, 1, context, again, true)
  local mode = selectedMode()

  idx = addImpulseSectionToggle("Show Random Impulse Controls",
    "Shows random strength and temporary impulse-group disable controls for the selected mode.",
    "random", idx, again)
  if uiConfig.impulseSections.random then
    idx = addSettings(IMPULSE_PATH, globalRandomSettings(mode), idx,
      "mode/" .. tostring(mode and mode.key or "realismCustom") .. "/randomization", again, true)
  end

  idx = addImpulseSectionToggle("Show Move NPC with Feet Controls",
    "Shows Move NPC with Feet enable and tuning controls.",
    "moveFeet", idx, again)
  if uiConfig.impulseSections.moveFeet then
    idx = addSettings(IMPULSE_PATH, globalMoveSettings(), idx, "global/moveNpcFeet", again, true)
  end

  local motorcycle = globalMotorcycleSettings(mode)
  if #motorcycle > 0 then
    idx = addImpulseSectionToggle("Show Motorcycle Impulse Controls - " .. mode.label,
      "Shows motorcycle topple and rider lean impulse controls for the selected mode.",
      "motorcycle", idx, again)
    if uiConfig.impulseSections.motorcycle then
      idx = addSettings(IMPULSE_PATH, motorcycle, idx,
        "mode/" .. tostring(mode.key) .. "/motorcycle", again, true)
    end
  end

  pcall(function() if nativeSettings.refresh then nativeSettings.refresh() end end)
end

local function buildMenu()
  nativeSettings.addTab(TAB, schema.title, function() saveUI(false); saveSettingsNow(false) end)
  nativeSettings.addSubcategory(GLOBAL_PATH, "SPLAT Mode", 1)
  local modeSetting
  for _, setting in ipairs(schema.globalSettings or {}) do
    if setting.id == schema.modeSettingId then modeSetting = setting; break end
  end
  if not modeSetting then loge("Mode setting missing from schema"); return false end
  globalModeSetting = modeSetting
  local globalImpulseSection = nil
  for _, section in ipairs(schema.sharedSections or {}) do
    if section.key == "globalImpulse" then globalImpulseSection = section; break end
  end
  local function rebuildSelectedMenu()
    if globalImpulseSection then rebuildGlobalImpulseControls(globalImpulseSection) end
    local active = selectedMode()
    for _, candidate in ipairs(schema.modes) do
      removeModeCategories(candidate)
    end
    showModeCategories(active, tonumber(active.enumIndex) or 1)
    pcall(function() if nativeSettings.refresh then nativeSettings.refresh() end end)
  end
  globalModeRef = addSetting(GLOBAL_PATH, modeSetting, 1, "global", {}, rebuildSelectedMenu, false)
  globalStaticCount = 1
  dynamicRefs[GLOBAL_PATH] = {}

  local subIndex = 2
  for _, section in ipairs(schema.sharedSections or {}) do
    -- Motorcycle controls are already selected and rendered inside Global
    -- Impulse Controls. Do not create a second Motorcycle category.
    if section.key ~= "motorcycles" then
      local path = sharedPath(section)
      local label = section.label
      if section.key == "globalImpulse" then label = "Mode Impulse Control" end
      if section.key == "animation" then label = "Animation Control" end
      nativeSettings.addSubcategory(path, label, subIndex)
      dynamicRefs[path] = {}
      rebuildShared(section)
      subIndex = subIndex + 1
    end
  end

  showModeCategories(selectedMode(), tonumber(selectedMode().enumIndex) or 1)


  nativeSettings.registerRestoreDefaultsCallback(TAB, true, function()
    settingsStore = defaultSettingsStore()
    settingsDirty = true
    buildRestoreQueue()
    saveSettingsNow(true)
    local b = resolveBridge()
    if b then pcall(function() b:SPLATResetAll() end) end
    uiConfig = defaultUI()
    uiDirty = true
    saveUI(true)
    logi("Direct settings reset to REDscript defaults. Reopen the Mods menu to refresh visibility.")
  end)
  return true
end



local function initialize()
  if initialized then return end
  schema = readJson(INDEX_FILE)
  if not schema then return end

  local loadedUI, uiSource = loadPersistent(USER_UI_FILE, LEGACY_UI_FILE, "menu visibility state")
  local loadedUIVersion = type(loadedUI) == "table" and tonumber(loadedUI.version) or 0
  if loadedUIVersion ~= 132 and loadedUIVersion ~= 133 and loadedUIVersion ~= 134 and loadedUIVersion ~= 135 and loadedUIVersion ~= 136 and loadedUIVersion ~= 137 and loadedUIVersion ~= 138 and loadedUIVersion ~= 139 and loadedUIVersion ~= 140 and loadedUIVersion ~= 141 and loadedUIVersion ~= 142 and loadedUIVersion ~= 145 and loadedUIVersion ~= 148 and loadedUIVersion ~= 149 and loadedUIVersion ~= 150 and loadedUIVersion ~= STATE_VERSION then
    loadedUI = {}
    if uiSource ~= "invalid" then uiSource = "default" end
    logi("Resetting incompatible legacy menu visibility state")
  end
  if type(loadedUI) == "table" then
    local legacyOpen = loadedUI.impulseAdvanced
    if legacyOpen == nil then legacyOpen = loadedUI.globalAdvanced end
    if type(loadedUI.impulseSections) ~= "table" then
      loadedUI.impulseSections = {
        random = legacyOpen == true,
        moveFeet = legacyOpen == true,
        motorcycle = legacyOpen == true
      }
    end
    loadedUI.impulseAdvanced = nil
    loadedUI.globalAdvanced = nil
    -- V149/V150 used each .all.clean2 switch as an action that overwrote child
    -- switches. V151 turns it into a visibility gate. Start those new masters
    -- closed once while retaining every child gate value.
    if loadedUIVersion == 149 or loadedUIVersion == 150 then
      for _, bucket in pairs(loadedUI.gates or {}) do
        if type(bucket) == "table" then
          for id, _ in pairs(bucket) do
            if type(id) == "string" and id:find("%.all%.clean2$") then bucket[id] = false end
          end
        end
      end
      for _, state in pairs(loadedUI.situationalGroups or {}) do
        if type(state) == "table" then state.__master = false end
      end
      loadedUI.version = STATE_VERSION
      uiDirty = true
    end
    -- V160 intentionally starts every disclosure switch closed. Gameplay
    -- values are preserved; only menu visibility is reset once.
    if loadedUIVersion < STATE_VERSION then
      loadedUI = defaultUI()
      uiDirty = true
      -- Baseline marker retained for compatibility checks:
      -- V158 closed every menu and situational disclosure by default
      logi("V160 closed every menu and situational disclosure by default")
    end
  end
  uiConfig = merge(loadedUI, defaultUI())

  local loadedSettings, settingsSource = loadPersistent(USER_SETTINGS_FILE, LEGACY_SETTINGS_FILE, "gameplay settings")
  local loadedVersion = type(loadedSettings) == "table" and tonumber(loadedSettings.version) or 0
  if loadedVersion ~= 130 and loadedVersion ~= 131 and loadedVersion ~= 132 and loadedVersion ~= 133 and loadedVersion ~= 134 and loadedVersion ~= 135 and loadedVersion ~= 136 and loadedVersion ~= 137 and loadedVersion ~= 138 and loadedVersion ~= 139 and loadedVersion ~= 140 and loadedVersion ~= 141 and loadedVersion ~= 142 and loadedVersion ~= 145 and loadedVersion ~= 148 and loadedVersion ~= 149 and loadedVersion ~= 150 and loadedVersion ~= 157 and loadedVersion ~= 158 and loadedVersion ~= STATE_VERSION then
    loadedSettings = defaultSettingsStore()
    if settingsSource ~= "invalid" then settingsSource = "default" end
    logi("Ignoring incompatible legacy gameplay settings cache")
  end
  settingsStore = merge(loadedSettings, defaultSettingsStore())
  if type(settingsStore.values) ~= "table" then settingsStore.values = {} end
  migrateObsoleteShoulderButtSettings()

  -- One-time migration: an earlier test build shipped V's unfinished lean
  -- topple toggle enabled. Force that experimental control off once, then let
  -- the user change it normally afterward if they deliberately want to test it.
  if settingsStore.vMotorcycleWipDisabled ~= true then
    settingsStore.values["arnoldArcade|RFCModSettings.arnold_playerMotorcycleLeanToppleEnabled"] = {type = "Bool", value = false}
    settingsStore.vMotorcycleWipDisabled = true
    settingsDirty = true
    logi("Disabled unfinished V motorcycle lean topple during migration")
  end

  if settingsSource == "primary" or settingsSource == "backup" then
    logi("PERSISTENCE RELOAD CONFIRMED: loaded " .. tostring(savedValueCount()) .. " gameplay values; serial=" .. tostring(settingsStore.writeSerial or 0))
  end

  nativeSettings = GetMod("nativeSettings")
  if not nativeSettings then loge("Native Settings UI is not installed"); return end
  buildRestoreQueue()
  if buildMenu() then
    initialized = true
    if uiSource ~= "primary" and uiSource ~= "invalid" then uiDirty = true; saveUI(true) end
    if settingsSource ~= "primary" and settingsSource ~= "invalid" then
      settingsDirty = true
      saveSettingsNow(true)
    end
    logi("Menu registered. Standalone event-driven CET bridge active; REDscript bridge version 139 expected; V155 audited menu rebuild active")
  end
end

local function handlePlayerReady(player, source)
  if not initialized or not player or not IsDefined(player) then return false end
  if livePlayer ~= player then bridgeConnected = false end
  livePlayer = player

  local live = resolveBridge(player)
  if not live then
    loge("Player lifecycle event arrived before the SPLAT REDscript bridge was ready")
    return false
  end

  -- Rebuild from the current in-memory settings so changes made earlier in this
  -- session are guaranteed to replay onto a recreated PlayerPuppet.
  buildRestoreQueue()
  if not processRestoreQueue() then return false end
  if settingsDirty then saveSettingsNow(false) end
  logi("Standalone PlayerPuppet lifecycle connected via " .. tostring(source or "event"))
  return true
end

local function tryCurrentPlayer(source)
  local ok, player = pcall(function() return Game.GetPlayer() end)
  if ok and player and IsDefined(player) then
    return handlePlayerReady(player, source)
  end
  return false
end

local function registerPlayerLifecycleObserver()
  local ok, err = pcall(function()
    ObserveAfter("PlayerPuppet", "OnGameAttached", function(player)
      handlePlayerReady(player, "PlayerPuppet.OnGameAttached")
    end)
  end)
  if not ok then
    loge("Could not register PlayerPuppet.OnGameAttached observer: " .. tostring(err))
    return false
  end
  logi("Standalone PlayerPuppet.OnGameAttached observer registered")
  return true
end

registerForEvent("onInit", function()
  registerPlayerLifecycleObserver()
  initialize()
  if not initialized then return end

  -- Supports CET's Reload All Mods while already inside a save. This is one
  -- explicit probe, not a repeating player lookup.
  tryCurrentPlayer("CET onInit/reload")
end)

registerForEvent("onOverlayOpen", function()
  -- Recovery path if the mod was reloaded at the main menu and the player was
  -- attached later without the observer seeing it. Runs only when the user
  -- explicitly opens CET's overlay.
  if initialized and not bridgeConnected then
    tryCurrentPlayer("CET overlay open")
  end
end)

registerForEvent("onOverlayClose", function()
  saveUI(false)
  saveSettingsNow(false)
end)

registerForEvent("onShutdown", function()
  saveUI(false)
  saveSettingsNow(false)
end)

return {title = "Splat Physics 11.1", version = STATE_VERSION, backend = "Standalone event-driven CET + direct PlayerPuppet REDscript + approved mode-driven Native Settings menu"}
