local ActionWheel = {}

local wheelConfig = {
  radius = 160,
  innerRadius = 50,
  selectorRadius = 100,
  thickness = 25,
  centerRadius = 12,
  knobMaxDist = 38,
  textPadding = 15,
  textScale = 1.0,
  backgroundColor = Color(0, 0, 0, 0),
  borderColor = Color(0, 0, 0, 0),
  accentColor = Color(255, 255, 255, 255),
  textColor = Color(255, 255, 255, 255),
  textShadowColor = Color(0, 0, 0, 255),
  arrowColor = Color(255, 255, 255, 255),
  knobColor = Color(200, 200, 200, 255),
  knobShadowColor = Color(0, 0, 0, 150),
}

local actions = {}
local font = nil
local selectedAction = nil
local wasVisible = false

local isEditMode = false
local draggedIndex = nil
local onReorder = nil
local onRemove = nil
local lastLeftClick = false
local lastRightClick = false

local function InitializeFont()
  if not font then
    font = Render.LoadFont("Proximanova", Enum.FontCreate.FONTFLAG_BOLD, 600)
  end
  return font
end

local function GetScreenCenter()
  local screenSize = Render.ScreenSize()
  return Vec2(screenSize.x / 2, screenSize.y / 2)
end

local function CalculateAngle(centerX, centerY, pointX, pointY)
  local dx = pointX - centerX
  local dy = pointY - centerY
  local angle = math.atan(dy, dx)
  angle = math.deg(angle)
  if angle < 0 then
    angle = angle + 360
  end
  return angle
end

local function CalculateDistance(centerX, centerY, pointX, pointY)
  local dx = pointX - centerX
  local dy = pointY - centerY
  return math.sqrt(dx * dx + dy * dy)
end

local function GetSelectedAction(centerPos, mouseX, mouseY, numActions)
  local distance = CalculateDistance(centerPos.x, centerPos.y, mouseX, mouseY)

  if distance < wheelConfig.innerRadius then
    return nil
  end

  if distance > (wheelConfig.radius + 100) then
    return nil
  end

  local angle = CalculateAngle(centerPos.x, centerPos.y, mouseX, mouseY)

  local anglePerSegment = 360 / numActions
  local startOffset = 270 - (anglePerSegment / 2)

  local rotatedAngle = (angle - startOffset) % 360
  local selectedSegment = math.floor(rotatedAngle / anglePerSegment) + 1

  if selectedSegment > numActions then
    selectedSegment = selectedSegment - numActions
  end

  return selectedSegment
end

local function DrawSelectionIndicator(centerPos, numActions, selectedAction)
  if not selectedAction then return end

  local anglePerSegment = 360 / numActions
  local startDeg = 270 - (anglePerSegment / 2) + (selectedAction - 1) * anglePerSegment

  Render.Circle(centerPos, wheelConfig.selectorRadius, wheelConfig.accentColor,
    wheelConfig.thickness, startDeg, 1.0 / numActions, false, 32)
end

local function DrawActionLabels(centerPos, numActions, selectedAction)
  local anglePerSegment = 360 / numActions

  for i = 1, numActions do
    local midAngle = 270 + (i - 1) * anglePerSegment
    local midAngleRad = math.rad(midAngle)

    local labelRadius = wheelConfig.radius + (wheelConfig.textPadding or 15)
    local labelX = centerPos.x + math.cos(midAngleRad) * labelRadius
    local labelY = centerPos.y + math.sin(midAngleRad) * labelRadius

    if font then
      local actionText = actions[i].name
      if type(actionText) == "function" then
        actionText = actionText()
      end

      local baseSize = (i == selectedAction) and 20 or 18
      local scale = wheelConfig.textScale or 1.0
      local fontSize = math.floor(baseSize * scale)

      local textSize = Render.TextSize(font, fontSize, actionText)

      local anchorX = 0.5 - 0.5 * math.cos(midAngleRad)

      local anchorY = 0.5 - 0.5 * math.sin(midAngleRad)

      local drawPos = Vec2(
        labelX - textSize.x * anchorX,
        labelY - textSize.y * anchorY
      )

      local textColor = (i == selectedAction) and wheelConfig.accentColor or Color(200, 200, 200, 255)

      if isEditMode then
        if i == draggedIndex then
          textColor = Color(255, 200, 0, 255)
          actionText = "[DRAGGING] " .. actionText
        elseif i == selectedAction then
          actionText = "[R-CLICK DELETE] " .. actionText
          textColor = Color(255, 100, 100, 255)
        end
      end

      Render.Text(font, fontSize, actionText, Vec2(drawPos.x + 1, drawPos.y + 1), wheelConfig.textShadowColor)
      Render.Text(font, fontSize, actionText, drawPos, textColor)
    end
  end
end
local function DrawWheelCenter(centerPos, mouseX, mouseY)
  Render.Circle(centerPos, wheelConfig.innerRadius, Color(255, 255, 255, 50), 2, 0, 1.0, false, 32)

  local dirX = mouseX - centerPos.x
  local dirY = mouseY - centerPos.y
  local dist = math.sqrt(dirX * dirX + dirY * dirY)

  local knobX = centerPos.x
  local knobY = centerPos.y

  if dist > 0 then
    local clampDist = math.min(dist, wheelConfig.knobMaxDist)
    knobX = centerPos.x + (dirX / dist) * clampDist
    knobY = centerPos.y + (dirY / dist) * clampDist
  end

  local knobPos = Vec2(knobX, knobY)

  Render.FilledCircle(knobPos, wheelConfig.centerRadius, Color(40, 40, 40, 255), 0, 1.0, 16)
  Render.Circle(knobPos, wheelConfig.centerRadius, wheelConfig.knobColor, 2, 0, 1.0, false, 16)
end

local function RenderWheel()
  InitializeFont()

  local centerPos = GetScreenCenter()
  local numActions = #actions

  local mouseX, mouseY = Input.GetCursorPos()

  selectedAction = GetSelectedAction(centerPos, mouseX, mouseY, numActions)

  DrawSelectionIndicator(centerPos, numActions, selectedAction)
  DrawActionLabels(centerPos, numActions, selectedAction)
  DrawWheelCenter(centerPos, mouseX, mouseY)

  if font then
    local instructionText = isEditMode and "EDIT MODE: Drag to Reorder | Right-Click to Delete" or "Release to select"
    local instSize = Render.TextSize(font, 12, instructionText)
    local instPos = Vec2(centerPos.x - instSize.x / 2, centerPos.y + wheelConfig.radius + 60)
    Render.Text(font, 12, instructionText, instPos, isEditMode and Color(255, 200, 0, 255) or Color(200, 200, 200, 150))
  end
end

function ActionWheel.SetActions(newActions)
  actions = newActions
end

function ActionWheel.Setup(config)
  for k, v in pairs(config) do
    wheelConfig[k] = v
  end
end

function ActionWheel.SetEditMode(enabled, reorderCallback, removeCallback)
  isEditMode = enabled
  onReorder = reorderCallback
  onRemove = removeCallback
end

function ActionWheel.Update(isKeyDown)
  if isEditMode then
    RenderWheel()

    local leftClick = Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE1)
    local rightClick = Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE2)

    if leftClick and not lastLeftClick then
      if selectedAction then
        draggedIndex = selectedAction
      end
    elseif not leftClick and lastLeftClick then
      if draggedIndex and selectedAction and draggedIndex ~= selectedAction then
        if onReorder then
          onReorder(draggedIndex, selectedAction)
        end
      end
      draggedIndex = nil
    end

    if rightClick and not lastRightClick then
      if selectedAction and onRemove then
        onRemove(selectedAction)
      end
    end

    lastLeftClick = leftClick
    lastRightClick = rightClick
  elseif isKeyDown then
    wasVisible = true
    RenderWheel()
  else
    if wasVisible then
      if selectedAction and actions[selectedAction] and actions[selectedAction].callback then
        actions[selectedAction].callback()
      end
      wasVisible = false
      selectedAction = nil
    end
  end
end

return ActionWheel
