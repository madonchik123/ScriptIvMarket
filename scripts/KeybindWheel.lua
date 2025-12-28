local ActionWheel = require("ActionWheel")
local Wheel = {}

local Settings = Menu.Create("Scripts", "Main", "Action Wheel")
Settings:Icon("\u{f013}")
local General = Settings:Create("General"):Create("Main")
local Bind = General:Bind("Show Wheel", Enum.ButtonCode.KEY_K)

local ConfigUI = Settings:Create("Configuration"):Create("Main")

local NewPath = ConfigUI:Input("New Item Path", "")
NewPath:ToolTip(
  'Enter the menu item path in the format: Menu.Find("Category", "Subcategory", "Item Name"), \ncan be obtained when you right click on the switch and then press copy lua path \n(turn on developer mode in settings to see this option)')
local NewName = ConfigUI:Input("Custom Name (Optional)", "")
local AddBtn = ConfigUI:Button("Add Item", function() end)

local EditModeBtn = ConfigUI:Button("Reorganize Layout", function() end)
local isEditing = false

local restoreQueue = {}

ActionWheel.Setup({
  radius = 160,
  textPadding = 20,
  textScale = 1.0,
})

local function CreateActionItem(name, path)
  return {
    name = function()
      local item = Menu.Find(table.unpack(path))
      local localizedName = Localizer.Get(name) or name

      if item then
        if item:Type() == Enum.WidgetType.MenuSwitch then
          return localizedName .. ": " .. (item:Get() and "ON" or "OFF")
        elseif item:Type() == Enum.WidgetType.MenuBind then
          return localizedName
        end
      end
      return localizedName
    end,
    callback = function()
      local item = Menu.Find(table.unpack(path))

      if item then
        local actionName = Localizer.Get(name) or name
        local message = nil

        if item:Type() == Enum.WidgetType.MenuSwitch then
          -- Toggle Switch
          local newState = not item:Get()
          item:Set(newState)
          message = "Toggled " .. actionName .. ": " .. (newState and "ON" or "OFF")
        elseif item:Type() == Enum.WidgetType.MenuBind then
          -- Trigger Bind
          local oldKey = item:Get()
          local wheelKey = Bind:Get()

          if oldKey ~= wheelKey then
            item:Set(wheelKey)

            table.insert(restoreQueue, {
              item = item,
              key = oldKey,
              time = os.clock() + 0.1
            })
            message = "Triggered " .. actionName
          end
        end

        if message and Notification then
          local me = Heroes.GetLocal()
          Notification({
            id = "aw_" .. tostring(os.clock()),
            duration = 1,
            timer = 1,
            hero = me and NPC.GetUnitName(me) or "npc_dota_hero_invoker",
            secondary_text = "\aDEFAULT" .. message,
            sound = "sounds/ui/yoink"
          })
        end
      else
        Log.Write("Error: Menu item not found for '" .. name .. "'")
      end
    end
  }
end

local currentActions = {}

local function SerializeActions()
  local str = ""
  for _, action in ipairs(currentActions) do
    local pathStr = table.concat(action.path, ",")
    str = str .. action.rawName .. "|" .. pathStr .. ";"
  end
  Config.WriteString("ActionWheel", "Actions", str)
end

local function LoadActions()
  local str = Config.ReadString("ActionWheel", "Actions", "")
  if str == "" then
    currentActions = {
      { rawName = "Auto Control",   path = { "General", "Main", "Auto Control Renewal", "Main", "Main Settings", "Enable" } },
      { rawName = "Auto Disabler",  path = { "General", "Main", "Auto Disabler", "Main", "General", "Enable" } },
      { rawName = "Item Snatcher",  path = { "General", "Main", "Snatcher", "Main", "Items Snatcher", "Enable" } },
      { rawName = "Rune Snatcher",  path = { "General", "Main", "Snatcher", "Main", "Runes Snatcher", "Enable" } },
      { rawName = "MpHp Abuse",     path = { "Miscellaneous", "Other", "MpHp Abuse", "Main", "Settings", "Enable" } },
      { rawName = "Tree Changer 2", path = { "Changer", "Main", "Tree Changer 2", "Main", "Main Settings", "Enabled" } },
      { rawName = "Dodger",         path = { "General", "Main", "Dodger", "Main", "General", "Enable" } },
      { rawName = "Kill Stealer",   path = { "General", "Main", "Kill Stealer", "Main", "Main Settings", "Enable" } },
    }
    SerializeActions()
  else
    currentActions = {}
    for item in str:gmatch("([^;]+)") do
      local name, pathStr = item:match("^(.*)|(.*)$")
      if name and pathStr then
        local path = {}
        for p in pathStr:gmatch("([^,]+)") do
          table.insert(path, p)
        end
        table.insert(currentActions, { rawName = name, path = path })
      end
    end
  end

  local wheelActions = {}
  for _, action in ipairs(currentActions) do
    table.insert(wheelActions, CreateActionItem(action.rawName, action.path))
  end
  ActionWheel.SetActions(wheelActions)
end

AddBtn:SetCallback(function()
  local pathStr = NewPath:Get()
  local customName = NewName:Get()

  local path = {}
  local content = pathStr:match("Menu%.Find%s*%(%s*(.*)%s*%)") or pathStr
  for arg in content:gmatch("\"([^\"]+)\"") do
    table.insert(path, arg)
  end

  if #path > 0 then
    local item = Menu.Find(table.unpack(path))

    if item then
      local type = item:Type()
      if type == Enum.WidgetType.MenuSwitch or type == Enum.WidgetType.MenuBind then
        local name = (customName ~= "" and customName) or item:Name()
        table.insert(currentActions, { rawName = name, path = path })
        SerializeActions()
        LoadActions()
        Log.Write("Added: " .. name)
      else
        Log.Write("Error: Item must be a Switch or Bind (Type: " .. tostring(type) .. ")")
      end
    else
      Log.Write("Error: Menu item not found")
    end
  else
    Log.Write("Error: Invalid path format")
  end
end)

EditModeBtn:SetCallback(function()
  isEditing = not isEditing

  if isEditing then
    EditModeBtn:ToolTip("Click to Close Edit Mode")
    ActionWheel.SetEditMode(true,
      function(from, to)
        if currentActions[from] and currentActions[to] then
          local temp = currentActions[from]
          currentActions[from] = currentActions[to]
          currentActions[to] = temp
          SerializeActions()
          LoadActions()
        end
      end,
      function(index)
        if currentActions[index] then
          table.remove(currentActions, index)
          SerializeActions()
          LoadActions()
        end
      end
    )
  else
    EditModeBtn:ToolTip("Click to Open Edit Mode")
    ActionWheel.SetEditMode(false)
  end
end)

Wheel.OnDraw = function()
  local now = os.clock()
  for i = #restoreQueue, 1, -1 do
    local task = restoreQueue[i]
    if now > task.time then
      task.item:Set(task.key)
      table.remove(restoreQueue, i)
    end
  end

  ActionWheel.Update(Bind:IsDown())
end

LoadActions()

return Wheel
