local Market = {}

local json = require("assets.JSON")

-- Configuration
local SCRIPTS_JSON_URL = "https://raw.githubusercontent.com/madonchik123/ScriptIvMarket/refs/heads/main/scripts.json"
local MARKET_UPDATE_URL = "https://raw.githubusercontent.com/madonchik123/ScriptIvMarket/refs/heads/main/market.lua"
local CONFIG_FILE = "market"

-- UI Configuration
local ui = {
  pos = Vec2(300, 200),
  size = Vec2(700, 500),
  dragging = false,
  dragOffset = Vec2(0, 0),
  activeTab = "browse", -- "browse" or "installed"
  scroll = 0,
  maxScroll = 0,
  scrollbarDragging = false,
  scrollbarDragOffset = 0
}

local state = {
  isOpen = false,
  scripts = {},
  installed = {},
  status = "",
  statusTime = 0,
  lastMouse = false,
  popup = {
    isOpen = false,
    message = "",
    onYes = nil,
    onNo = nil
  },
  drawingPopup = false
}

local fonts = {
  regular = nil,
  bold = nil
}

-- Colors
local colors = {
  bg = Color(18, 18, 18, 250),
  header = Color(25, 25, 25, 255),
  accent = Color(52, 152, 219, 255),
  text = Color(236, 240, 241, 255),
  textDim = Color(149, 165, 166, 255),
  border = Color(44, 62, 80, 255),
  button = Color(44, 62, 80, 200),
  buttonHover = Color(52, 73, 94, 255),
  success = Color(46, 204, 113, 255),
  danger = Color(231, 76, 60, 255),
  scrollbar = Color(60, 60, 60, 255),
  scrollbarHover = Color(80, 80, 80, 255)
}

-- Helper Functions
local function parseJSON(str)
  return json:decode(str)
end

local function saveScriptsData()
  if not Config then return end
  local scriptsList = ""
  for scriptName, scriptUrl in pairs(state.scripts) do
    Config.WriteString(CONFIG_FILE, "script_" .. scriptName, scriptUrl)
    if scriptsList == "" then
      scriptsList = scriptName
    else
      scriptsList = scriptsList .. "," .. scriptName
    end
  end
  Config.WriteString(CONFIG_FILE, "Market_Scripts", scriptsList)
end

local function loadScriptsData()
  if not Config then return end
  state.scripts = {}
  local scriptsList = Config.ReadString(CONFIG_FILE, "Market_Scripts", "")
  if scriptsList ~= "" then
    for scriptName in scriptsList:gmatch("([^,]+)") do
      local scriptUrl = Config.ReadString(CONFIG_FILE, "script_" .. scriptName, "")
      if scriptUrl ~= "" then
        state.scripts[scriptName] = scriptUrl
      end
    end
  end
end
local function saveInstalledScripts()
  if not Config then return end
  for scriptName, _ in pairs(state.installed) do
    Config.WriteString(CONFIG_FILE, "installed_" .. scriptName, "true")
    Config.WriteString(CONFIG_FILE, "installed_" .. scriptName, "true")
  end
  for scriptName, _ in pairs(state.scripts) do
    if not state.installed[scriptName] then
      Config.WriteString(CONFIG_FILE, "installed_" .. scriptName, "false")
    end
  end
end

local function isScriptInstalled(scriptName)
  local filename = Engine.GetCheatDirectory() .. "/scripts/" .. scriptName .. ".lua"
  local file = io.open(filename, "r")
  if file then
    file:close()
    return true
  end
  return false
end

local function loadInstalledScripts()
  state.installed = {}
  for scriptName, _ in pairs(state.scripts) do
    if isScriptInstalled(scriptName) then
      state.installed[scriptName] = true
    end
  end
end

local function setStatus(msg)
  state.status = msg
  state.statusTime = os.clock() + 3
end

-- Network Functions
local function updateMarket()
  setStatus("Updating market script...")
  local headers = { ["User-Agent"] = "Umbrella/1.0", ['Connection'] = 'Keep-Alive' }
  HTTP.Request("GET", MARKET_UPDATE_URL, { headers = headers }, function(response)
    if response.code == 200 and response.response then
      local filename = Engine.GetCheatDirectory() .. "/scripts/market.lua"
      local file = io.open(filename, "w")
      if file then
        file:write(response.response)
        file:close()
        setStatus("Market updated! Reloading...")
        Engine.ReloadScriptSystem()
      else
        setStatus("Failed to write market file")
      end
    else
      setStatus("Update failed: " .. tostring(response.code))
    end
  end, "update_market")
end

local function installScript(scriptName, scriptUrl)
  setStatus("Installing " .. scriptName .. "...")
  local headers = { ["User-Agent"] = "Umbrella/1.0", ['Connection'] = 'Keep-Alive' }
  HTTP.Request("GET", scriptUrl, { headers = headers }, function(response)
    if response.code == 200 and response.response then
      local filename = Engine.GetCheatDirectory() .. "/scripts/" .. scriptName .. ".lua"
      local file = io.open(filename, "w")
      if file then
        file:write(response.response)
        file:close()
        state.installed[scriptName] = true
        saveInstalledScripts()
        setStatus("Installed " .. scriptName)

        state.popup.message = "Installed " .. scriptName .. ", reload scripts?"
        state.popup.onYes = function() Engine.ReloadScriptSystem() end
        state.popup.onNo = nil
        state.popup.isOpen = true
      else
        setStatus("Failed to write file for " .. scriptName)
      end
    else
      setStatus("Download failed: " .. tostring(response.code))
    end
  end, "install_" .. scriptName)
end

local function deleteScript(scriptName)
  local filename = Engine.GetCheatDirectory() .. "/scripts/" .. scriptName .. ".lua"
  local success = os.remove(filename)
  if success then
    state.installed[scriptName] = nil
    saveInstalledScripts()
    setStatus("Deleted " .. scriptName)

    state.popup.message = "Deleted " .. scriptName .. ", reload scripts?"
    state.popup.onYes = function() Engine.ReloadScriptSystem() end
    state.popup.onNo = nil
    state.popup.isOpen = true
  else
    setStatus("Failed to delete " .. scriptName)
  end
end

local function updateAllScripts(calledby)
  setStatus("Updating all scripts...")
  for scriptName, _ in pairs(state.installed) do
    if state.scripts[scriptName] then
      installScript(scriptName, state.scripts[scriptName])
    end
  end
end

local function fetchScriptsData()
  setStatus("Fetching scripts...")
  local headers = { ["User-Agent"] = "Umbrella/1.0", ['Connection'] = 'Keep-Alive' }
  HTTP.Request("GET", SCRIPTS_JSON_URL, { headers = headers }, function(response)
    if response.code == 200 and response.response then
      local success, data = pcall(parseJSON, response.response)
      if success and data then
        state.scripts = data
        saveScriptsData()
        loadInstalledScripts()
        setStatus("Loaded " .. tostring(table.count(state.scripts)) .. " scripts")

        -- Auto-update installed scripts
        if next(state.installed) ~= nil and not Engine.IsInGame() then
          updateAllScripts()
        end
      else
        setStatus("Failed to parse JSON")
      end
    else
      setStatus("Fetch failed: " .. tostring(response.code))
    end
  end, "fetch_scripts")
end

function table.count(t)
  local c = 0
  for _ in pairs(t) do c = c + 1 end
  return c
end

-- UI Rendering
local function InitFonts()
  if not fonts.regular then
    fonts.regular = Render.LoadFont("Proximanova", Enum.FontCreate.FONTFLAG_NONE, 400)
    fonts.bold = Render.LoadFont("Proximanova", Enum.FontCreate.FONTFLAG_BOLD, 600)
  end
end

local function IsHovered(pos, size)
  local mx, my = Input.GetCursorPos()
  return mx >= pos.x and mx <= pos.x + size.x and my >= pos.y and my <= pos.y + size.y
end

local function DrawButton(text, pos, size, color, hoverColor, callback)
  local hovered = IsHovered(pos, size)
  local clicked = hovered and Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE1) and not state.lastMouse

  if state.popup.isOpen and not state.drawingPopup then
    clicked = false
    hovered = false
  end

  local drawColor = hovered and (hoverColor or colors.buttonHover) or (color or colors.button)

  Render.FilledRect(pos, Vec2(pos.x + size.x, pos.y + size.y), drawColor, 4)

  local textSize = Render.TextSize(fonts.regular, 14, text)
  local textPos = Vec2(
    pos.x + (size.x - textSize.x) / 2,
    pos.y + (size.y - textSize.y) / 2
  )
  Render.Text(fonts.regular, 14, text, textPos, colors.text)

  if clicked and callback then callback() end
  return clicked
end

local function DrawPopup()
  if not state.popup.isOpen then return end

  state.drawingPopup = true

  -- Dim background
  Render.FilledRect(ui.pos, Vec2(ui.pos.x + ui.size.x, ui.pos.y + ui.size.y), Color(0, 0, 0, 200), 8)

  -- Popup Box
  local popupW, popupH = 400, 150
  local popupPos = Vec2(
    ui.pos.x + (ui.size.x - popupW) / 2,
    ui.pos.y + (ui.size.y - popupH) / 2
  )

  Render.FilledRect(popupPos, Vec2(popupPos.x + popupW, popupPos.y + popupH), colors.bg, 8)
  Render.Rect(popupPos, Vec2(popupPos.x + popupW, popupPos.y + popupH), colors.border, 8, 1.0)

  -- Message
  local textSize = Render.TextSize(fonts.regular, 16, state.popup.message)
  Render.Text(fonts.regular, 16, state.popup.message,
    Vec2(popupPos.x + (popupW - textSize.x) / 2, popupPos.y + 40), colors.text)

  -- Buttons
  local btnW, btnH = 100, 35
  local btnY = popupPos.y + popupH - 60

  -- Yes Button
  DrawButton("Yes", Vec2(popupPos.x + 50, btnY), Vec2(btnW, btnH), colors.success, nil, function()
    state.popup.isOpen = false
    if state.popup.onYes then state.popup.onYes() end
  end)

  -- No Button
  DrawButton("No", Vec2(popupPos.x + popupW - 50 - btnW, btnY), Vec2(btnW, btnH), colors.danger, nil, function()
    state.popup.isOpen = false
    if state.popup.onNo then state.popup.onNo() end
  end)

  state.drawingPopup = false
end

-- Create menu structure
local scriptsMenu = Menu.Create("Scripts", "Other", "Market")
scriptsMenu:Icon("\u{f54e}") -- store

local mainMenu = scriptsMenu:Create("Main"):Create("General")

local openButton = mainMenu:Button("Open Market", function()
  state.isOpen = true
end)
openButton:Icon("\u{f07a}") -- shopping-cart

function Market.OnFrame()
  if not state.isOpen then return end
  InitFonts()

  local mx, my = Input.GetCursorPos()
  local leftClick = Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE1)

  -- Dragging
  if leftClick and not state.lastMouse then
    if IsHovered(ui.pos, Vec2(ui.size.x, 50)) then
      ui.dragging = true
      ui.dragOffset = Vec2(mx - ui.pos.x, my - ui.pos.y)
    end
  elseif not leftClick then
    ui.dragging = false
  end

  if ui.dragging then
    ui.pos = Vec2(mx - ui.dragOffset.x, my - ui.dragOffset.y)
  end

  -- Background with Blur
  Render.Blur(ui.pos, Vec2(ui.pos.x + ui.size.x, ui.pos.y + ui.size.y), 1.0, 1.0, 8)
  Render.FilledRect(ui.pos, Vec2(ui.pos.x + ui.size.x, ui.pos.y + ui.size.y), colors.bg, 8)
  Render.Rect(ui.pos, Vec2(ui.pos.x + ui.size.x, ui.pos.y + ui.size.y), colors.border, 8, 1.0)

  -- Header
  local headerH = 60
  Render.FilledRect(ui.pos, Vec2(ui.pos.x + ui.size.x, ui.pos.y + headerH), colors.header, 8)
  -- Fix bottom rounding of header
  Render.FilledRect(Vec2(ui.pos.x, ui.pos.y + headerH / 2), Vec2(ui.pos.x + ui.size.x, ui.pos.y + headerH), colors
    .header)

  Render.Text(fonts.bold, 24, "Script Market", Vec2(ui.pos.x + 20, ui.pos.y + 18), colors.text)

  -- Close Button
  DrawButton("X", Vec2(ui.pos.x + ui.size.x - 40, ui.pos.y + 15), Vec2(25, 25), Color(0, 0, 0, 0),
    Color(200, 50, 50, 255), function()
      state.isOpen = false
    end)

  -- Tabs
  local tabW = 120
  local tabH = 30
  local tabY = ui.pos.y + headerH + 10

  local browseColor = ui.activeTab == "browse" and colors.accent or colors.button
  DrawButton("Browse", Vec2(ui.pos.x + 20, tabY), Vec2(tabW, tabH), browseColor, nil, function()
    ui.activeTab = "browse"
    ui.scroll = 0
  end)

  local installedColor = ui.activeTab == "installed" and colors.accent or colors.button
  DrawButton("Installed", Vec2(ui.pos.x + 30 + tabW, tabY), Vec2(tabW, tabH), installedColor, nil, function()
    ui.activeTab = "installed"
    ui.scroll = 0
  end)

  -- Update All Button (if installed tab)
  if ui.activeTab == "installed" then
    DrawButton("Update All", Vec2(ui.pos.x + ui.size.x - 140, tabY), Vec2(120, tabH), colors.success, nil, function()
      updateAllScripts(true)
    end)
  end

  -- Content List
  local listY = tabY + tabH + 15
  local listH = ui.size.y - (listY - ui.pos.y) - 40
  local listW = ui.size.x - 40
  local itemH = 50

  -- Filter and Sort
  local items = {}
  if ui.activeTab == "browse" then
    for name, url in pairs(state.scripts) do
      if not state.installed[name] then
        table.insert(items, { name = name, url = url, type = "install" })
      end
    end
  else
    for name, _ in pairs(state.installed) do
      table.insert(items, { name = name, type = "uninstall" })
    end
  end
  table.sort(items, function(a, b) return a.name < b.name end)

  -- Scroll Logic
  local totalH = #items * (itemH + 5)
  ui.maxScroll = math.max(0, totalH - listH)

  -- Scrollbar
  if ui.maxScroll > 0 then
    local scrollbarX = ui.pos.x + ui.size.x - 15
    local scrollbarY = listY
    local scrollbarH = listH
    local thumbH = math.max(30, (listH / totalH) * listH)
    local thumbY = scrollbarY + (ui.scroll / ui.maxScroll) * (scrollbarH - thumbH)

    -- Scrollbar Track
    Render.FilledRect(Vec2(scrollbarX, scrollbarY), Vec2(scrollbarX + 6, scrollbarY + scrollbarH), Color(30, 30, 30, 255),
      3)

    -- Scrollbar Thumb
    local thumbColor = ui.scrollbarDragging and colors.scrollbarHover or colors.scrollbar
    Render.FilledRect(Vec2(scrollbarX, thumbY), Vec2(scrollbarX + 6, thumbY + thumbH), thumbColor, 3)

    -- Dragging Logic
    if leftClick and not state.lastMouse then
      if IsHovered(Vec2(scrollbarX - 5, scrollbarY), Vec2(16, scrollbarH)) then
        ui.scrollbarDragging = true
        ui.scrollbarDragOffset = my - thumbY
      end
    elseif not leftClick then
      ui.scrollbarDragging = false
    end

    if ui.scrollbarDragging then
      local newThumbY = my - ui.scrollbarDragOffset
      local trackRatio = (newThumbY - scrollbarY) / (scrollbarH - thumbH)
      ui.scroll = math.max(0, math.min(ui.maxScroll, trackRatio * ui.maxScroll))
    end
  end


  Render.PushClip(Vec2(ui.pos.x, listY), Vec2(ui.pos.x + ui.size.x, listY + listH))

  local startY = listY - ui.scroll
  for i, item in ipairs(items) do
    local itemY = startY + (i - 1) * (itemH + 5)

    if itemY + itemH > listY and itemY < listY + listH then
      local itemPos = Vec2(ui.pos.x + 20, itemY)
      local itemSize = Vec2(listW - 20, itemH)

      Render.FilledRect(itemPos, Vec2(itemPos.x + itemSize.x, itemPos.y + itemSize.y), Color(30, 30, 30, 255), 4)

      Render.Text(fonts.bold, 18, item.name, Vec2(itemPos.x + 15, itemPos.y + 15), colors.text)

      local btnW = 100
      local btnH = 30
      local btnPos = Vec2(itemPos.x + itemSize.x - btnW - 10, itemPos.y + 10)

      if item.type == "install" then
        DrawButton("Install", btnPos, Vec2(btnW, btnH), colors.accent, nil, function()
          installScript(item.name, item.url)
        end)
      else
        DrawButton("Uninstall", btnPos, Vec2(btnW, btnH), colors.danger, nil, function()
          deleteScript(item.name)
        end)
      end
    end
  end
  Render.PopClip()

  -- Status Bar
  if state.status ~= "" then
    Render.Text(fonts.regular, 14, state.status, Vec2(ui.pos.x + 20, ui.pos.y + ui.size.y - 25), colors.textDim)
    if os.clock() > state.statusTime then state.status = "" end
  end

  -- Update Market Button
  local updateBtnW = 120
  DrawButton("Update Market", Vec2(ui.pos.x + ui.size.x - updateBtnW - 20, ui.pos.y + ui.size.y - 35),
    Vec2(updateBtnW, 25), colors.button, nil, function()
      updateMarket()
    end)

  DrawPopup()

  state.lastMouse = leftClick
end

-- Initialization
Market.OnScriptsLoaded = function()
  loadScriptsData()
  loadInstalledScripts()
  fetchScriptsData()
end

return Market
