local script       = {}

--#region Configuration
---@class ScriptConfig
local CONFIG       = {
  RUNE_DURATION = 90.0,
  FONT_SIZE = 16,
  FONT_WEIGHT = Enum.FontWeight.BOLD,
  RUNE_INVALID_ID = 4294967295,
  RUNE_EMPTY_ALT_ID = -1
}
--#endregion

--#region Menu
local menu         = Menu.Create("General", "Main", "Items Manager", "General", "General")
local enableSwitch = menu:Switch("Enable Rune Timer", true)
local gear         = enableSwitch:Gear("Settings")

---@class ScriptSettings
local settings     = {
  enable    = enableSwitch,
  gear      = gear,
  yOffset   = gear:Slider("Vertical Offset (Y)", -30, 30, -15, "%dpx"),
  textColor = gear:ColorPicker("Timer Color", Color(255, 220, 0, 255))
}
-- Add icons and tooltips
settings.enable:Image("panorama/images/items/bottle_png.vtex_c")
settings.enable:ToolTip("Shows a 90-second expiration timer above your Bottle when it contains a rune.")

settings.yOffset:Icon("\u{f338}")
settings.yOffset:ToolTip("Adjust the vertical position of the timer text relative to the item slot.")

settings.textColor:Icon("\u{f53f}")
settings.textColor:ToolTip("Choose the color for the countdown timer text.")

--#endregion

--#region State Management
---@class ScriptState
local state = {
  pickupTime = nil, ---@type number|nil
  bottleSlot = nil ---@type number|nil
}

--- Resets the script's state variables to their default values.
local function resetState()
  state.pickupTime = nil
  state.bottleSlot = nil
end
--#endregion

--#region Core Logic
local font = Render.LoadFont("Arial", CONFIG.FONT_SIZE, CONFIG.FONT_WEIGHT)
local inventoryPanel1 = Panorama.GetPanelByName("inventory_list", false)
local inventoryPanel2 = Panorama.GetPanelByName("inventory_list2", false)

--- Finds the bottle and its rune status, updating the script's state.
script.OnUpdate = function()
  if not settings.enable:Get() or not Engine.IsInGame() then
    resetState()
    return
  end

  local hero = Heroes.GetLocal()
  if not hero then
    resetState()
    return
  end

  local bottle, slot = nil, nil
  for i = 0, 5 do
    local item = NPC.GetItemByIndex(hero, i)
    if item and Entity.GetUnitName(item) == "item_bottle" then
      bottle, slot = item, i
      break
    end
  end

  state.bottleSlot = slot

  if bottle then
    local runeType = Bottle.GetRuneType(bottle)
    if runeType ~= CONFIG.RUNE_INVALID_ID and runeType ~= CONFIG.RUNE_EMPTY_ALT_ID then
      if not state.pickupTime then
        state.pickupTime = GameRules.GetGameTime()
      end
    else
      state.pickupTime = nil
    end
  else
    state.pickupTime = nil
  end
end

--- Handles drawing the timer text on the screen.
script.OnDraw = function()
  if not settings.enable:Get() or not state.pickupTime or not state.bottleSlot then
    return
  end

  local elapsedTime = GameRules.GetGameTime() - state.pickupTime
  local timeLeft = CONFIG.RUNE_DURATION - elapsedTime

  if timeLeft <= 0 then
    state.pickupTime = nil
    return
  end

  -- Determine which inventory panel the bottle is in
  local panel
  if state.bottleSlot <= 2 then
    panel = inventoryPanel1 and inventoryPanel1:GetChild(state.bottleSlot)
  else
    panel = inventoryPanel2 and inventoryPanel2:GetChild(state.bottleSlot - 3)
  end

  if not panel then return end

  local timerText = string.format("%.1f", timeLeft)
  local panelPos = panel:GetPositionWithinWindow()
  local textWidth = Render.TextSize(font, CONFIG.FONT_SIZE, timerText).x

  local drawX = panelPos.x + panel:GetLayoutWidth() / 2 - (textWidth / 2)
  local drawY = panelPos.y + settings.yOffset:Get()

  Render.Text(font, CONFIG.FONT_SIZE, timerText, Vec2(drawX, drawY), settings.textColor:Get())
end
--#endregion

--#region Callbacks
script.OnGameEnd = function()
  resetState()
end
--#endregion

return script
