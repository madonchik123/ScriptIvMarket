local AggroTimer = {}
local Menu = Menu or {}

-- Settings Menu
local menuRoot = Menu.Create("Creeps", "Main", "Aggro Timer", "Settings", "Main")
menuRoot:Parent():Parent():Icon("\u{f78c}")
local settings = {
  enabled = menuRoot:Switch("Enable creep aggro timer", true),
  showPrediction = menuRoot:Switch("Show predicted creep positions", true),
  displayMode = menuRoot:Combo("Display mode", { "All creeps", "Closest creep" }, 0),
  colorCooldown = menuRoot:ColorPicker("Cooldown color", Color(220, 50, 50, 230)),
  colorReady = menuRoot:ColorPicker("Ready color", Color(50, 220, 50, 200)),
  showText = menuRoot:Switch("Show text (timer/ready)", true),
  heightOffset = menuRoot:Slider("Height offset", 0, 50, 15),
  drawRadius = menuRoot:Slider("Draw radius", 0, 2000, 1200),
}

-- Constants
local MELEE_AGGRO_RADIUS = 500
local RANGED_AGGRO_RADIUS = 500
local MELEE_ATTACK_RANGE = 150
local RANGED_ATTACK_RANGE_MAX = 500
local AGGRO_COOLDOWN = 3

local aggroedCreeps = {}

local cooldownExpireTime = 0
local localHero = nil
local fontSize = 12
local font = Render.LoadFont("Arial", fontSize, Enum.FontCreate.FONTFLAG_OUTLINE)

-- Utility: Check if creep is melee or ranged/catapults
local function IsRangedCreep(npc)
  local name = NPC.GetUnitName(npc)
  return NPC.IsRanged(npc) or name:find("catapult")
end
-- Utility: Get creep move speed
local function GetCreepMoveSpeed(creep)
  return NPC.GetMoveSpeed(creep) or 325 -- fallback to 325 if not available
end
-- Utility: Check if hero is within aggro radius of creep
local function IsWithinAggroRadius(creepPos, heroPos, isRanged)
  local radius = isRanged and RANGED_AGGRO_RADIUS or MELEE_AGGRO_RADIUS
  return (creepPos - heroPos):Length2D() <= radius
end

-- Pathfinding: Returns the last walkable position towards target (stops at first block)
local function GetPathableAggroPosition(creep, heroPos, isRanged, remainingAggroTime)
  local creepPos = Entity.GetAbsOrigin(creep)
  local direction = (heroPos - creepPos):Normalized()
  local distance = creepPos:Distance(heroPos)
  local step = 24

  local targetDist = 0
  if isRanged then
    if distance > RANGED_ATTACK_RANGE_MAX then
      targetDist = distance - RANGED_ATTACK_RANGE_MAX
    else
      targetDist = 0
    end
  else
    if distance > MELEE_ATTACK_RANGE then
      targetDist = distance - MELEE_ATTACK_RANGE
    else
      targetDist = 0
    end
  end

  local moveSpeed = GetCreepMoveSpeed(creep)
  local maxChaseDistance = moveSpeed * remainingAggroTime

  if targetDist > maxChaseDistance then
    targetDist = maxChaseDistance
  end

  local lastPos = creepPos
  for d = step, targetDist, step do
    local testPos = creepPos + direction * d
    if not GridNav.IsTraversable(testPos) then
      break
    end
    lastPos = testPos
  end
  return lastPos
end

-- Hook OnPrepareUnitOrders to track aggro cooldown
function AggroTimer.OnPrepareUnitOrders(order)
  if not settings.enabled:Get() then return true end

  local hero = Heroes.GetLocal()
  if not hero then return true end
  --if not NPC.IsVisibleToEnemies(hero) then return true end -- Only trigger aggro if visible!

  if GlobalVars.GetCurTime() < cooldownExpireTime then return true end

  if not order or not order.player or not order.target or not order.order then return true end
  local player = Players.GetLocal()
  if order.player ~= player then return true end

  -- Only consider attack or move orders targeting enemy hero to trigger aggro cooldown
  local isAttackOrMove = order.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET or
      order.order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET or order.order == 4
  if isAttackOrMove and Entity.IsHero(order.target) and Entity.GetTeamNum(order.target) ~= Entity.GetTeamNum(hero) then
    cooldownExpireTime = GlobalVars.GetCurTime() + AGGRO_COOLDOWN
    -- Mark all creeps in aggro radius as aggroed
    local heroPos = Entity.GetAbsOrigin(hero)
    local creeps = NPCs.GetAll(Enum.UnitTypeFlags.TYPE_LANE_CREEP)
    for _, creep in pairs(creeps) do
      if Entity.IsAlive(creep) and Entity.GetTeamNum(creep) ~= Entity.GetTeamNum(hero) then
        local isRanged = IsRangedCreep(creep)
        if IsWithinAggroRadius(Entity.GetAbsOrigin(creep), heroPos, isRanged) then
          aggroedCreeps[creep] = true
        end
      end
    end
  end
  return true
end

-- Main Draw function
function AggroTimer.OnDraw()
  if not settings.enabled:Get() or not Engine.IsInGame() then return end
  localHero = Heroes.GetLocal()
  if not localHero then return end

  local curTime = GlobalVars.GetCurTime()
  local aggroActive = curTime < cooldownExpireTime
  local heroVisible = true

  -- If hero is not visible or aggro expired, clear aggroed creeps
  if not heroVisible or not aggroActive then
    aggroedCreeps = {}
  end

  local creeps = NPCs.GetAll(Enum.UnitTypeFlags.TYPE_LANE_CREEP)
  if not creeps then return end

  local heroPos = Entity.GetAbsOrigin(localHero)
  local creepsToDraw = {}

  -- Draw all enemy lane creeps (not just those in aggro radius)
  for _, creep in pairs(creeps) do
    if Entity.IsAlive(creep) and Entity.GetTeamNum(creep) ~= Entity.GetTeamNum(localHero) and not NPC.IsWaitingToSpawn(creep) then
      local isRanged = IsRangedCreep(creep)
      table.insert(creepsToDraw, { npc = creep, ranged = isRanged })
    end
  end

  table.sort(creepsToDraw, function(a, b)
    local aPos = Entity.GetAbsOrigin(a.npc)
    local bPos = Entity.GetAbsOrigin(b.npc)
    return (aPos - heroPos):Length2D() < (bPos - heroPos):Length2D()
  end)

  local displayList = {}
  if settings.displayMode:Get() == 0 then
    displayList = creepsToDraw
  elseif #creepsToDraw > 0 then
    displayList = { creepsToDraw[1] }
  end

  for _, data in pairs(displayList) do
    local npc = data.npc
    local isRanged = data.ranged
    local pos = Entity.GetAbsOrigin(npc)

    local drawRadius = settings.drawRadius:Get()
    if drawRadius > 0 and (pos - heroPos):Length2D() > drawRadius then
      return
    end

    local isAggroed = aggroedCreeps[npc] and aggroActive and heroVisible
    local predictedPos = nil

    if isAggroed and settings.showPrediction:Get() then
      local distance = pos:Distance(heroPos)
      local remaining = math.max(0, cooldownExpireTime - curTime)
      if isRanged then
        if distance > RANGED_ATTACK_RANGE_MAX then
          predictedPos = GetPathableAggroPosition(npc, heroPos, isRanged, remaining)
        end
      else
        if distance > MELEE_ATTACK_RANGE then
          predictedPos = GetPathableAggroPosition(npc, heroPos, isRanged, remaining)
        end
      end
    end

    local screenPos, onScreen = Render.WorldToScreen(pos +
      Vector(0, 0, NPC.GetHealthBarOffset(npc) + settings.heightOffset:Get()))
    local screenPredictedPos, onScreenPred = nil, false
    if predictedPos then
      screenPredictedPos, onScreenPred = Render.WorldToScreen(predictedPos +
        Vector(0, 0, NPC.GetHealthBarOffset(npc) + settings.heightOffset:Get()))
    end

    if onScreen then
      local barWidth = 30
      local barHeight = 4
      local barPos = Vec2(screenPos.x - barWidth / 2, screenPos.y)

      if isAggroed then
        local remaining = cooldownExpireTime - curTime
        local ratio = remaining / AGGRO_COOLDOWN
        Render.FilledRect(barPos, barPos + Vec2(barWidth, barHeight), Color(0, 0, 0, 150), 2)
        Render.FilledRect(barPos, barPos + Vec2(barWidth * ratio, barHeight), settings.colorCooldown:Get(), 2)
        if settings.showText:Get() then
          local txt = string.format("%.1f", remaining)
          local txtSize = Render.TextSize(font, fontSize, txt)
          Render.Text(font, fontSize, txt, Vec2(screenPos.x - txtSize.x / 2, screenPos.y - barHeight - txtSize.y),
            Color(255, 255, 255))
        end
      else
        Render.FilledRect(barPos, barPos + Vec2(barWidth, barHeight), settings.colorReady:Get(), 2)
        if settings.showText:Get() then
          local txt = "Ready"
          local txtSize = Render.TextSize(font, fontSize, txt)
          Render.Text(font, fontSize, txt, Vec2(screenPos.x - txtSize.x / 2, screenPos.y - barHeight - txtSize.y),
            Color(255, 255, 255))
        end
      end

      if predictedPos and onScreenPred then
        Render.Line(Vec2(screenPos.x, screenPos.y), Vec2(screenPredictedPos.x, screenPredictedPos.y),
          Color(255, 255, 0, 200), 1.5)
        Render.FilledCircle(Vec2(screenPredictedPos.x, screenPredictedPos.y), 6, Color(255, 215, 0, 180))
      end
    end
  end
end

return AggroTimer
