local Market = {}

local json = require("assets.JSON")

-- Configuration
local SCRIPTS_JSON_URL  = "https://raw.githubusercontent.com/madonchik123/ScriptIvMarket/refs/heads/main/scripts.json"
local SCRIPT_INFO_URL   = "https://raw.githubusercontent.com/madonchik123/ScriptIvMarket/refs/heads/main/scriptinfo.json"
local MARKET_UPDATE_URL = "https://raw.githubusercontent.com/madonchik123/ScriptIvMarket/refs/heads/main/MarketNew.lua"
local CONFIG_FILE       = "market"

local SCROLL_SPEED = 40
local ITEM_H       = 100
local ITEM_GAP     = 6

-- UI state
local ui = {
  pos              = Vec2(300, 200),
  size             = Vec2(720, 520),
  dragging         = false,
  dragOffset       = Vec2(0, 0),
  activeTab        = "browse",
  scroll           = 0,
  maxScroll        = 0,
  scrollbarDragging     = false,
  scrollbarDragOffset   = 0,
}

local state = {
  isOpen      = false,
  scripts     = {},
  scriptInfo  = {},
  installed   = {},
  status      = "",
  statusTime  = 0,
  lastMouse   = false,
  language    = 0,
  popup = {
    isOpen   = false,
    message  = "",
    onYes    = nil,
    onNo     = nil,
  },
  drawingPopup = false,
}

local fonts = { regular = nil, bold = nil }

-- Color palette
local C = {
  bg           = Color(16, 16, 20,  245),
  header       = Color(22, 22, 28,  255),
  item         = Color(28, 28, 36,  255),
  itemHover    = Color(36, 36, 46,  255),
  accent       = Color(56, 152, 220, 255),
  accentHover  = Color(80, 172, 240, 255),
  text         = Color(230, 235, 240, 255),
  textDim      = Color(140, 150, 160, 255),
  border       = Color(48,  56,  72,  180),
  button       = Color(44,  54,  72,  220),
  buttonHover  = Color(58,  70,  92,  255),
  success      = Color(46,  204, 113, 255),
  successHov   = Color(64,  220, 130, 255),
  danger       = Color(220, 70,  55,  255),
  dangerHov    = Color(240, 90,  70,  255),
  warn         = Color(240, 180, 40,  255),
  scrollTrack  = Color(28,  28,  36,  255),
  scrollThumb  = Color(64,  72,  96,  255),
  scrollThumbH = Color(88,  100, 130, 255),
  overlay      = Color(0,   0,   0,   180),
  separator    = Color(255, 255, 255, 12),
}

-- ── Helpers ──────────────────────────────────────────────────────────────────

local function parseJSON(str) return json:decode(str) end

local function tableCount(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  return n
end

local function wrapText(text, maxWidth, font, size)
  if not text or text == "" then return {} end
  local lines, line = {}, ""
  for word in text:gmatch("%S+") do
    local test = line == "" and word or (line .. " " .. word)
    if Render.TextSize(font, size, test).x > maxWidth and line ~= "" then
      table.insert(lines, line)
      line = word
    else
      line = test
    end
  end
  if line ~= "" then table.insert(lines, line) end
  return lines
end

local function getDescription(info)
  if not info then return nil end
  if state.language == 1 and info.description_ru then return info.description_ru end
  return info.description_en or info.description_ru
end

local function setStatus(msg)
  state.status    = msg
  state.statusTime = os.clock() + 4
end

-- ── Persistence ──────────────────────────────────────────────────────────────

local function saveScriptsData()
  if not Config then return end
  local list = {}
  for name, url in pairs(state.scripts) do
    Config.WriteString(CONFIG_FILE, "script_" .. name, url)
    table.insert(list, name)
  end
  Config.WriteString(CONFIG_FILE, "Market_Scripts", table.concat(list, ","))
end

local function loadScriptsData()
  if not Config then return end
  state.scripts = {}
  local raw = Config.ReadString(CONFIG_FILE, "Market_Scripts", "")
  for name in raw:gmatch("([^,]+)") do
    local url = Config.ReadString(CONFIG_FILE, "script_" .. name, "")
    if url ~= "" then state.scripts[name] = url end
  end
end

local function saveInstalledScripts()
  if not Config then return end
  -- Collect all names that have ever been tracked (installed + known scripts)
  local allNames = {}
  for name in pairs(state.installed) do allNames[name] = true end
  for name in pairs(state.scripts)   do allNames[name] = true end
  -- Write definitive state for every name so stale "true" entries get cleared
  for name in pairs(allNames) do
    Config.WriteString(CONFIG_FILE, "installed_" .. name,
      state.installed[name] and "true" or "false")
  end
end

local function isScriptInstalled(name)
  local f = io.open(Engine.GetCheatDirectory() .. "/scripts/" .. name .. ".lua", "r")
  if f then f:close(); return true end
  return false
end

local function loadInstalledScripts()
  state.installed = {}
  for name in pairs(state.scripts) do
    if isScriptInstalled(name) then
      state.installed[name] = true
    end
  end
end

-- ── Network ───────────────────────────────────────────────────────────────────

local HTTP_HEADERS = { ["User-Agent"] = "Umbrella/1.0", ["Connection"] = "Keep-Alive" }

local function updateMarket()
  setStatus("Updating market script…")
  HTTP.Request("GET", MARKET_UPDATE_URL, { headers = HTTP_HEADERS }, function(r)
    if r.code == 200 and r.response then
      local path = Engine.GetCheatDirectory() .. "/scripts/MarketNew.lua"
      local f = io.open(path, "w")
      if f then
        f:write(r.response); f:close()
        setStatus("Market updated — reloading…")
        Engine.ReloadScriptSystem()
      else
        setStatus("Failed to write market file")
      end
    else
      setStatus("Update failed: HTTP " .. tostring(r.code))
    end
  end, "update_market")
end

local function installScript(name, url, opts)
  setStatus("Installing " .. name .. "…")
  HTTP.Request("GET", url, { headers = HTTP_HEADERS }, function(r)
    if r.code == 200 and r.response then
      local path = Engine.GetCheatDirectory() .. "/scripts/" .. name .. ".lua"
      local f = io.open(path, "w")
      if f then
        f:write(r.response); f:close()
        state.installed[name] = true
        saveInstalledScripts()
        setStatus("Installed: " .. name)
        if not (opts and opts.skipReloadPrompt) then
          state.popup.message = "Installed " .. name .. " — reload scripts?"
          state.popup.onYes   = function() Engine.ReloadScriptSystem() end
          state.popup.onNo    = nil
          state.popup.isOpen  = true
        end
      else
        setStatus("Write failed for " .. name)
      end
    else
      setStatus("Download failed for " .. name .. ": HTTP " .. tostring(r.code))
    end
  end, "install_" .. name)
end

local function deleteScript(name)
  local path = Engine.GetCheatDirectory() .. "/scripts/" .. name .. ".lua"
  if os.remove(path) then
    state.installed[name] = nil
    saveInstalledScripts()
    setStatus("Deleted: " .. name)
    state.popup.message = "Deleted " .. name .. " — reload scripts?"
    state.popup.onYes   = function() Engine.ReloadScriptSystem() end
    state.popup.onNo    = nil
    state.popup.isOpen  = true
  else
    setStatus("Failed to delete " .. name)
  end
end

local function updateScript(name)
  local url = state.scripts[name]
  if url then installScript(name, url, { skipReloadPrompt = true }) end
end

local function updateAllScripts(opts)
  setStatus("Updating all installed scripts…")
  for name in pairs(state.installed) do
    if state.scripts[name] then
      installScript(name, state.scripts[name], opts)
    end
  end
end

local function fetchScriptInfo()
  HTTP.Request("GET", SCRIPT_INFO_URL, { headers = HTTP_HEADERS }, function(r)
    if r.code == 200 and r.response then
      local ok, data = pcall(parseJSON, r.response)
      if ok and data then
        state.scriptInfo = data
      else
        setStatus("Failed to parse script info")
      end
    else
      setStatus("Script-info fetch failed: HTTP " .. tostring(r.code))
    end
  end, "fetch_scriptinfo")
end

local function fetchScriptsData()
  setStatus("Fetching script list…")
  HTTP.Request("GET", SCRIPTS_JSON_URL, { headers = HTTP_HEADERS }, function(r)
    if r.code == 200 and r.response then
      local ok, data = pcall(parseJSON, r.response)
      if ok and data then
        state.scripts = data
        saveScriptsData()
        loadInstalledScripts()
        setStatus("Loaded " .. tableCount(state.scripts) .. " scripts")
        if next(state.installed) ~= nil and not Engine.IsInGame() then
          updateAllScripts({ skipReloadPrompt = true })
        end
      else
        setStatus("Failed to parse scripts JSON")
      end
    else
      setStatus("Fetch failed: HTTP " .. tostring(r.code))
    end
  end, "fetch_scripts")
end

local function setupLanguageListener()
  local langMenu = Menu.Find("SettingsHidden", "", "", "", "Main", "Language")
  if not langMenu then return end
  local cur = langMenu:Get()
  if cur ~= nil then state.language = cur end
  langMenu:SetCallback(function(new)
    state.language = (new and new:Get()) or 0
  end)
end

-- ── Font init ─────────────────────────────────────────────────────────────────

local function InitFonts()
  if not fonts.regular then
    fonts.regular = Render.LoadFont("Proximanova", Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.NORMAL)
    fonts.bold    = Render.LoadFont("Proximanova", Enum.FontCreate.FONTFLAG_ANTIALIAS, Enum.FontWeight.BOLD)
  end
end

-- ── Drawing primitives ────────────────────────────────────────────────────────

local FLAGS_ALL = Enum.DrawFlags.RoundCornersAll

local function FilledRect(pos, size, color, radius, flags)
  if flags == nil then flags = FLAGS_ALL end
  Render.FilledRect(pos, pos + size, color, radius or 0, flags)
end

local function OutlineRect(pos, size, color, radius, thickness, flags)
  if flags == nil then flags = FLAGS_ALL end
  Render.Rect(pos, pos + size, color, radius or 0, thickness or 1, flags)
end

local function IsHovered(pos, size)
  return Input.IsCursorInRect(pos.x, pos.y, size.x, size.y)
end

local function DrawButton(text, pos, size, baseColor, hoverColor, callback)
  local hovered = IsHovered(pos, size)
  local clicked = false

  if state.popup.isOpen and not state.drawingPopup then
    hovered = false
  else
    clicked = hovered and Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE1) and not state.lastMouse
  end

  local col = hovered and (hoverColor or C.buttonHover) or (baseColor or C.button)
  FilledRect(pos, size, col, 5)

  local ts  = Render.TextSize(fonts.regular, 14, text)
  local txy = Vec2(pos.x + (size.x - ts.x) * 0.5, pos.y + (size.y - ts.y) * 0.5)
  Render.Text(fonts.regular, 14, text, txy, C.text)

  if clicked and callback then callback() end
  return clicked
end

-- ── Popup ─────────────────────────────────────────────────────────────────────

local function DrawPopup()
  if not state.popup.isOpen then return end
  state.drawingPopup = true

  -- Full-window dim
  FilledRect(ui.pos, ui.size, C.overlay, 8)

  local pW, pH   = 420, 155
  local pPos     = Vec2(ui.pos.x + (ui.size.x - pW) * 0.5, ui.pos.y + (ui.size.y - pH) * 0.5)
  local pSize    = Vec2(pW, pH)

  FilledRect(pPos, pSize, C.bg,     10)
  OutlineRect(pPos, pSize, C.border, 10, 1)

  local ts = Render.TextSize(fonts.regular, 15, state.popup.message)
  Render.Text(fonts.regular, 15, state.popup.message,
    Vec2(pPos.x + (pW - ts.x) * 0.5, pPos.y + 38), C.text)

  local bW, bH = 110, 36
  local bY     = pPos.y + pH - 58
  DrawButton("Yes",
    Vec2(pPos.x + 50, bY), Vec2(bW, bH),
    C.success, C.successHov,
    function() state.popup.isOpen = false; if state.popup.onYes then state.popup.onYes() end end)
  DrawButton("No",
    Vec2(pPos.x + pW - 50 - bW, bY), Vec2(bW, bH),
    C.danger,  C.dangerHov,
    function() state.popup.isOpen = false; if state.popup.onNo  then state.popup.onNo()  end end)

  state.drawingPopup = false
end

-- ── Menu integration ──────────────────────────────────────────────────────────

local scriptsMenu = Menu.Create("Scripts", "Other", "Market")
scriptsMenu:Icon("\u{f54e}")

local mainMenu   = scriptsMenu:Create("Main"):Create("General")
local openButton = mainMenu:Button("Open Market", function() state.isOpen = true end)
openButton:Icon("\u{f07a}")

-- ── Main frame ────────────────────────────────────────────────────────────────

function Market.OnFrame()
  if not state.isOpen then return end
  InitFonts()

  local cursor    = Vec2(Input.GetCursorPos())
  local leftClick = Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE1)

  -- ── Drag window ──
  if leftClick and not state.lastMouse then
    if Input.IsCursorInRect(ui.pos.x, ui.pos.y, ui.size.x, 52) then
      ui.dragging   = true
      ui.dragOffset = cursor - ui.pos
    end
  end
  if not leftClick then ui.dragging = false end
  if ui.dragging   then ui.pos = cursor - ui.dragOffset end

  -- ── Background ──
  Render.Blur(ui.pos, ui.pos + ui.size, 1.0, 0.85, 10, FLAGS_ALL)
  FilledRect(ui.pos, ui.size, C.bg,     10)
  OutlineRect(ui.pos, ui.size, C.border, 10, 1)

  -- ── Header ──
  local headerH = 52
  FilledRect(ui.pos, Vec2(ui.size.x, headerH), C.header, 10, Enum.DrawFlags.RoundCornersTop)
  -- flat bottom edge of header
  FilledRect(Vec2(ui.pos.x, ui.pos.y + headerH - 8), Vec2(ui.size.x, 8), C.header, 0)

  Render.Text(fonts.bold, 22, "\u{f54e}  Script Market",
    Vec2(ui.pos.x + 18, ui.pos.y + 15), C.text)

  -- Close button
  DrawButton("\u{f00d}", Vec2(ui.pos.x + ui.size.x - 38, ui.pos.y + 14), Vec2(24, 24),
    Color(0, 0, 0, 0), C.danger,
    function() state.isOpen = false end)

  -- ── Tabs ──
  local tabBarY = ui.pos.y + headerH + 8
  local tabW, tabH = 130, 30

  local browseCol    = ui.activeTab == "browse"    and C.accent    or C.button
  local browseHov    = ui.activeTab == "browse"    and C.accentHover or C.buttonHover
  local installedCol = ui.activeTab == "installed" and C.accent    or C.button
  local installedHov = ui.activeTab == "installed" and C.accentHover or C.buttonHover

  DrawButton("Browse",    Vec2(ui.pos.x + 18,          tabBarY), Vec2(tabW, tabH),
    browseCol, browseHov, function() ui.activeTab = "browse";    ui.scroll = 0 end)
  DrawButton("Installed", Vec2(ui.pos.x + 18 + tabW + 8, tabBarY), Vec2(tabW, tabH),
    installedCol, installedHov, function() ui.activeTab = "installed"; ui.scroll = 0 end)

  if ui.activeTab == "installed" then
    DrawButton("\u{f021}  Update All",
      Vec2(ui.pos.x + ui.size.x - 148, tabBarY), Vec2(130, tabH),
      C.success, C.successHov,
      function() updateAllScripts({ skipReloadPrompt = true }) end)
  end

  -- ── Separator ──
  local sepY = tabBarY + tabH + 8
  FilledRect(Vec2(ui.pos.x + 18, sepY), Vec2(ui.size.x - 36, 1), C.separator, 0)

  -- ── Item list ──
  local listX = ui.pos.x + 16
  local listY = sepY + 6
  local listW = ui.size.x - 36
  local listH = ui.size.y - (listY - ui.pos.y) - 38
  local itemW = listW

  -- build visible item list
  local items = {}
  if ui.activeTab == "browse" then
    for name, url in pairs(state.scripts) do
      if not state.installed[name] then
        table.insert(items, { name = name, url = url, mode = "install" })
      end
    end
  else
    for name in pairs(state.installed) do
      table.insert(items, { name = name, url = state.scripts[name], mode = "installed" })
    end
  end
  table.sort(items, function(a, b) return a.name < b.name end)

  local totalH   = #items * (ITEM_H + ITEM_GAP) - ITEM_GAP
  ui.maxScroll   = math.max(0, totalH - listH)
  ui.scroll      = math.max(0, math.min(ui.maxScroll, ui.scroll))

  -- Scrollbar
  local sbW = 5
  local sbX = ui.pos.x + ui.size.x - 14
  if ui.maxScroll > 0 then
    local trackH = listH
    local thumbH = math.max(28, (listH / totalH) * trackH)
    local thumbY = listY + (ui.scroll / ui.maxScroll) * (trackH - thumbH)

    FilledRect(Vec2(sbX, listY), Vec2(sbW, trackH), C.scrollTrack, 3)

    local thumbHov = IsHovered(Vec2(sbX - 4, thumbY), Vec2(sbW + 8, thumbH))
    FilledRect(Vec2(sbX, thumbY), Vec2(sbW, thumbH),
      (thumbHov or ui.scrollbarDragging) and C.scrollThumbH or C.scrollThumb, 3)

    if leftClick and not state.lastMouse then
      if Input.IsCursorInRect(sbX - 4, listY, sbW + 8, trackH) then
        ui.scrollbarDragging    = true
        ui.scrollbarDragOffset  = cursor.y - thumbY
      end
    end
    if not leftClick then ui.scrollbarDragging = false end
    if ui.scrollbarDragging then
      local newThumbY  = cursor.y - ui.scrollbarDragOffset
      local ratio      = (newThumbY - listY) / (trackH - thumbH)
      ui.scroll        = math.max(0, math.min(ui.maxScroll, ratio * ui.maxScroll))
    end
  end

  -- Clip to list area
  Render.PushClip(Vec2(listX - 2, listY), Vec2(listX + itemW + 2, listY + listH))

  local startY = listY - ui.scroll
  for i, item in ipairs(items) do
    local iy  = startY + (i - 1) * (ITEM_H + ITEM_GAP)
    if iy + ITEM_H < listY or iy > listY + listH then goto continue end

    local iPos  = Vec2(listX, iy)
    local iSize = Vec2(itemW, ITEM_H)
    local hov   = IsHovered(iPos, iSize) and not (state.popup.isOpen and not state.drawingPopup)

    FilledRect(iPos, iSize, hov and C.itemHover or C.item, 6)

    local info  = state.scriptInfo[item.name]
    local tx, ty = iPos.x + 14, iy + 12

    -- Script name
    Render.Text(fonts.bold, 16, item.name, Vec2(tx, ty), C.text)
    ty = ty + 22

    -- Hero tag
    if info and info.hero then
      local heroStr = "\u{f007}  " .. tostring(info.hero)
      Render.Text(fonts.regular, 12, heroStr, Vec2(tx, ty), C.accent)
      ty = ty + 17
    end

    -- Description (wrapped)
    local desc = getDescription(info)
    if desc then
      local btnReserve = 220
      local maxW = itemW - btnReserve
      local lines = wrapText(desc, maxW, fonts.regular, 12)
      for li, ln in ipairs(lines) do
        if ty + (li - 1) * 15 + 15 > iy + ITEM_H - 6 then break end
        Render.Text(fonts.regular, 12, ln, Vec2(tx, ty + (li - 1) * 15), C.textDim)
      end
    end

    -- Action buttons (right side)
    local bH   = 28
    local bW1  = 90
    local bX1  = iPos.x + itemW - bW1 - 10
    local bY   = iy + (ITEM_H - bH) * 0.5

    if item.mode == "install" then
      DrawButton("\u{f019}  Install", Vec2(bX1, bY), Vec2(bW1, bH),
        C.accent, C.accentHover,
        function() installScript(item.name, item.url) end)
    else
      -- Update + Uninstall
      local bW2 = 90
      local bX2 = bX1 - bW2 - 6
      DrawButton("\u{f021}  Update", Vec2(bX2, bY), Vec2(bW2, bH),
        C.button, C.buttonHover,
        function() updateScript(item.name) end)
      DrawButton("\u{f1f8}  Remove", Vec2(bX1, bY), Vec2(bW1, bH),
        C.danger, C.dangerHov,
        function() deleteScript(item.name) end)
    end

    ::continue::
  end

  Render.PopClip()

  -- ── Empty-state message ──
  if #items == 0 then
    local msg = ui.activeTab == "browse" and "All available scripts are installed!" or "No scripts installed yet."
    local ts  = Render.TextSize(fonts.regular, 15, msg)
    Render.Text(fonts.regular, 15, msg,
      Vec2(ui.pos.x + (ui.size.x - ts.x) * 0.5, listY + listH * 0.5 - ts.y * 0.5),
      C.textDim)
  end

  -- ── Status bar ──
  local footerY = ui.pos.y + ui.size.y - 30
  FilledRect(Vec2(ui.pos.x + 1, footerY),
    Vec2(ui.size.x - 2, 29), C.header, 0, Enum.DrawFlags.RoundCornersBottom)

  if state.status ~= "" then
    if os.clock() > state.statusTime then
      state.status = ""
    else
      Render.Text(fonts.regular, 13, state.status,
        Vec2(ui.pos.x + 18, footerY + 8), C.textDim)
    end
  end

  -- "Update Market" button bottom-right
  local ubW = 124
  DrawButton("\u{f062}  Update Market",
    Vec2(ui.pos.x + ui.size.x - ubW - 14, footerY + 2), Vec2(ubW, 24),
    C.button, C.buttonHover,
    function() updateMarket() end)

  DrawPopup()

  state.lastMouse = leftClick
end

-- ── Mouse-wheel scroll ────────────────────────────────────────────────────────

function Market.OnKeyEvent(data)
  if not state.isOpen then return true end
  if data.event == Enum.EKeyEvent.EKeyEvent_KEY_DOWN then
    if data.key == Enum.ButtonCode.MOUSE_WHEEL_UP then
      ui.scroll = math.max(0, ui.scroll - SCROLL_SPEED)
      return false
    elseif data.key == Enum.ButtonCode.MOUSE_WHEEL_DOWN then
      ui.scroll = math.min(ui.maxScroll, ui.scroll + SCROLL_SPEED)
      return false
    end
  end
  return true
end

-- ── Initialization ────────────────────────────────────────────────────────────

Market.OnScriptsLoaded = function()
  loadScriptsData()
  loadInstalledScripts()
  setupLanguageListener()
  fetchScriptInfo()
  fetchScriptsData()
end

return Market
