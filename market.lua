local market = {}

local json = require("assets.JSON")

-- Configuration
local SCRIPTS_JSON_URL = "https://raw.githubusercontent.com/madonchik123/ScriptIvMarket/refs/heads/main/scripts.json"
local MARKET_UPDATE_URL = "https://raw.githubusercontent.com/madonchik123/ScriptIvMarket/refs/heads/main/market.lua"
local CONFIG_FILE = "market"
local scriptsData = {}
local installedScripts = {}

-- Some simple shit
local function parseJSON(str)
  return json:decode(str)
end

-- Function to save scripts data to config
local function saveScriptsData()
  -- Save each script with its URL
  for scriptName, scriptUrl in pairs(scriptsData) do
    Config.WriteString(CONFIG_FILE, "script_" .. scriptName, scriptUrl)
  end

  -- Save a list of all script names
  local scriptsList = ""
  for scriptName, _ in pairs(scriptsData) do
    if scriptsList == "" then
      scriptsList = scriptName
    else
      scriptsList = scriptsList .. "," .. scriptName
    end
  end
  Config.WriteString(CONFIG_FILE, "Market_Scripts", scriptsList)
end

-- Function to load scripts data from config
local function loadScriptsData()
  scriptsData = {}
  local scriptsList = Config.ReadString(CONFIG_FILE, "Market_Scripts", "")

  if scriptsList ~= "" then
    -- Split the comma-separated list
    for scriptName in scriptsList:gmatch("([^,]+)") do
      local scriptUrl = Config.ReadString(CONFIG_FILE, "script_" .. scriptName, "")
      if scriptUrl ~= "" then
        scriptsData[scriptName] = scriptUrl
      end
    end

    local count = 0
    for _ in pairs(scriptsData) do count = count + 1 end
    Log.Write("[Market] Loaded " .. tostring(count) .. " scripts from config")
  end
end

-- Function to save installed scripts to config
local function saveInstalledScripts()
  for scriptName, _ in pairs(installedScripts) do
    Config.WriteString(CONFIG_FILE, "installed_" .. scriptName, "true")
  end
  -- Clear removed scripts from config
  for scriptName, _ in pairs(scriptsData) do
    if not installedScripts[scriptName] then
      Config.WriteString(CONFIG_FILE, "installed_" .. scriptName, "false")
    end
  end
end

-- Function to load installed scripts from config
local function loadInstalledScripts()
  installedScripts = {}
  for scriptName, _ in pairs(scriptsData) do
    local isInstalled = Config.ReadString(CONFIG_FILE, "installed_" .. scriptName, "false")
    if isInstalled == "true" then
      installedScripts[scriptName] = true
    end
  end
end

-- Function to clean up scripts that are no longer available
local function cleanupObsoleteScripts()
  Log.Write("[Market] Checking for old scripts...")

  -- Get all config keys that start with "installed_"
  local scriptsToRemove = {}
  local allConfigKeys = {}

  -- We need to check all installed scripts from config and see if they exist in scriptsData
  -- First, get all script names from config
  local configScriptsList = Config.ReadString(CONFIG_FILE, "Market_Scripts", "")
  if configScriptsList ~= "" then
    for scriptName in configScriptsList:gmatch("([^,]+)") do
      local isInstalled = Config.ReadString(CONFIG_FILE, "installed_" .. scriptName, "false")
      if isInstalled == "true" and not scriptsData[scriptName] then
        -- This script is installed but no longer in scriptsData
        table.insert(scriptsToRemove, scriptName)
      end
    end
  end

  -- Remove obsolete scripts
  for _, scriptName in ipairs(scriptsToRemove) do
    Log.Write("[Market] Removing old script: " .. scriptName)
    local filename = Engine.GetCheatDirectory() .. "/scripts/" .. scriptName .. ".lua"

    -- Delete the file
    local success = os.remove(filename)
    if success then
      Log.Write("[Market] Successfully removed old script file: " .. scriptName)
    else
      Log.Write("[Market] Failed to remove file for old script: " .. scriptName)
    end

    -- Remove from config
    Config.WriteString(CONFIG_FILE, "installed_" .. scriptName, "false")
    Config.WriteString(CONFIG_FILE, "script_" .. scriptName, "")
  end

  if #scriptsToRemove > 0 then
    Log.Write("[Market] Removed " .. tostring(#scriptsToRemove) .. " old scripts")
    -- Update the scripts list in config to remove obsolete entries
    saveScriptsData()
    -- Reload script system if we removed any scripts
    Engine.ReloadScriptSystem()
  else
    Log.Write("[Market] No old scripts found")
  end
end

-- Function to update the market script itself
local function updateMarket()
  Log.Write("[Market] Updating market script...")

  local headers = {
    ["User-Agent"] = "Umbrella/1.0",
    ['Connection'] = 'Keep-Alive',
  }

  HTTP.Request("GET", MARKET_UPDATE_URL, {
    headers = headers,
  }, function(response)
    if response.code == 200 and response.response then
      local filename = Engine.GetCheatDirectory() .. "/scripts/market.lua"
      local file = io.open(filename, "w")

      if file then
        file:write(response.response)
        file:close()
        Log.Write("[Market] Successfully updated market script!")
        Log.Write("[Market] Reloading script system...")
        Engine.ReloadScriptSystem()
      else
        Log.Write("[Market] Failed to update market script file")
      end
    else
      Log.Write("[Market] Failed to download market update. Status: " .. tostring(response.code))
    end
  end, "update_market")
end

-- Function to update all installed scripts
local function updateAllScripts(calledby)
  Log.Write("[Market] Updating all installed scripts...")

  for scriptName, _ in pairs(installedScripts) do
    if scriptsData[scriptName] then
      local scriptUrl = scriptsData[scriptName]
      Log.Write("[Market] Updating script: " .. scriptName)

      local headers = {
        ["User-Agent"] = "Umbrella/1.0",
        ['Connection'] = 'Keep-Alive',
      }

      HTTP.Request("GET", scriptUrl, {
        headers = headers,
      }, function(response)
        if response.code == 200 and response.response then
          local filename = Engine.GetCheatDirectory() .. "/scripts/" .. scriptName .. ".lua"
          local file = io.open(filename, "w")
          if file then
            file:write(response.response)
            file:close()
            Log.Write("[Market] Successfully updated: " .. scriptName)
          else
            Log.Write("[Market] Failed to update file for: " .. scriptName)
          end
        else
          Log.Write("[Market] Failed to update script: " .. scriptName .. ". Status: " .. tostring(response.code))
        end
      end, "update_" .. scriptName)
    end
  end
  if calledby then
    Engine.ReloadScriptSystem()
  end
end

-- Function to fetch and parse scripts.json from GitHub
local function fetchScriptsData()
  Log.Write("[Market] Fetching scripts data...")

  local headers = {
    ["User-Agent"] = "Umbrella/1.0",
    ['Connection'] = 'Keep-Alive',
  }

  HTTP.Request("GET", SCRIPTS_JSON_URL, {
    headers = headers,
  }, function(response)
    if response.code == 200 and response.response then
      local success, data = pcall(parseJSON, response.response)
      if success and data then
        scriptsData = data
        local count = 0
        for _ in pairs(scriptsData) do count = count + 1 end
        Log.Write("[Market] Successfully fetched " .. tostring(count) .. " scripts")
        -- Save scripts data to config
        saveScriptsData()
        -- Load installed scripts from config after fetching data
        loadInstalledScripts()
        -- Clean up obsolete scripts
        cleanupObsoleteScripts()
        -- Refresh buttons after fetching data
        createMarketButtons()
        createInstalledButtons()
        -- Auto-update installed scripts if this was called from OnScriptsLoaded
        if next(installedScripts) ~= nil then
          local installedCount = 0
          for _ in pairs(installedScripts) do installedCount = installedCount + 1 end
          Log.Write("[Market] Auto-updating " .. tostring(installedCount) .. " installed scripts...")
          updateAllScripts()
        end
      else
        Log.Write("[Market] Failed to parse JSON data")
      end
    else
      Log.Write("[Market] Failed to fetch scripts data. Status: " .. tostring(response.code))
    end
  end, "fetch_scripts")
end

-- Function to download and install a script
local function installScript(scriptName, scriptUrl)
  Log.Write("[Market] Installing script: " .. scriptName)

  local headers = {
    ["User-Agent"] = "Umbrella/1.0",
    ['Connection'] = 'Keep-Alive',
  }

  HTTP.Request("GET", scriptUrl, {
    headers = headers,
  }, function(response)
    if response.code == 200 and response.response then
      local filename = Engine.GetCheatDirectory() .. "/scripts/" .. scriptName .. ".lua"
      local file = io.open(filename, "w")

      if file then
        file:write(response.response)
        file:close()
        installedScripts[scriptName] = true
        saveInstalledScripts() -- Save to config
        Log.Write("[Market] Successfully installed: " .. scriptName)
        Engine.ReloadScriptSystem()
      else
        Log.Write("[Market] Failed to create file for: " .. scriptName)
      end
    else
      Log.Write("[Market] Failed to download script: " .. scriptName .. ". Status: " .. tostring(response.code))
    end
  end, "install_" .. scriptName)
end

-- Function to delete an installed script
local function deleteScript(scriptName)
  Log.Write("[Market] Deleting script: " .. scriptName)
  local filename = Engine.GetCheatDirectory() .. "/scripts/" .. scriptName .. ".lua"

  -- Use os.remove to delete the file
  local success = os.remove(filename)
  if success then
    installedScripts[scriptName] = nil
    saveInstalledScripts() -- Save to config
    Log.Write("[Market] Successfully deleted: " .. scriptName)
    Engine.ReloadScriptSystem()
    return true
  else
    Log.Write("[Market] Failed to delete: " .. scriptName)
    return false
  end
end

-- Function to check if script is installed
local function isScriptInstalled(scriptName)
  local filename = Engine.GetCheatDirectory() .. "/scripts/" .. scriptName .. ".lua"
  local file = io.open(filename, "r")
  if file then
    file:close()
    return true
  end
  return false
end

-- Create menu structure
local marketMenu = Menu.Create("Scripts", "Main", "Market", "Market")
local Market = marketMenu:Create("Market")
local Installed = marketMenu:Create("Installed Scripts")

-- Create update all button
local updateAllButton = Installed:Button("Update All Scripts", function()
  updateAllScripts(true)
end)

-- Create market update button
local updateMarketButton = Market:Button("Update Market", function()
  updateMarket()
end)

-- Function to create market install buttons
function createMarketButtons()
  -- Clear existing buttons by recreating the Market group
  -- Note: This is a simplified approach - in a real implementation you might want to track buttons
  for scriptName, scriptUrl in pairs(scriptsData) do
    if not isScriptInstalled(scriptName) then
      Market:Button("Install " .. scriptName, function()
        installScript(scriptName, scriptUrl)
      end)
    end
  end
end

-- Function to create installed script delete buttons
function createInstalledButtons()
  for scriptName, _ in pairs(scriptsData) do
    if isScriptInstalled(scriptName) then
      Installed:Button("Delete " .. scriptName, function()
        deleteScript(scriptName)
      end)
    end
  end
end

-- OnScriptsLoaded callback - automatically update all scripts
market.OnScriptsLoaded = function()
  Log.Write("[Market] Scripts loaded - loading cached data and updating installed scripts...")
  -- First load scripts data from config
  loadScriptsData()
  loadInstalledScripts()

  -- Then fetch fresh data from GitHub
  fetchScriptsData()
end

createMarketButtons()
createInstalledButtons()

return market
