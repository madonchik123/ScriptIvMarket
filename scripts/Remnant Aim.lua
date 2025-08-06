local script = {}

-- Menu
local menu = Menu.Find("Heroes", "Hero List", "Void Spirit", "Main Settings", "Hero Settings")
local Keybind = menu:Bind("Auto Remnant Aim", Enum.ButtonCode.KEY_MOUSE5,
  "panorama/images/spellicons/void_spirit_aether_remnant_png.vtex_c")
local MinRemnantDistance = menu:Slider("Minimum Remnant Distance", 50, 300, 150)
local DrawDebugInfo = menu:Switch("Draw Debug Info", true)
--local PredictionStrength = menu:Slider("Prediction Strength", 1, 5, 3)

local Font = Render.LoadFont("Arial")
local lastPositions = {}
local hero = nil

-- Projects point p onto the line segment from a to b
local function ProjectPointOnLineSegment(a, b, p)
  local ab = b - a
  local ab_len_sqr = ab:LengthSqr()
  if ab_len_sqr == 0 then return a end
  local ap = p - a
  local t = ap:Dot(ab) / ab_len_sqr
  t = math.max(0, math.min(1, t))
  return a + ab:Scaled(t)
end
-- Returns closest enemy hero to mouse
local function GetClosestHeroToMouse()
  local WorldPos = Input.GetWorldCursorPos()
  local FHeroes = Heroes.InRadius(WorldPos, 850, Enum.TeamNum.TEAM_NONE, Enum.TeamType.TEAM_ENEMY)
  local ClosestDist = math.huge
  local ClosestHero = nil
  for _, FHero in pairs(FHeroes) do
    if Entity.IsAlive(FHero) and not Entity.IsSameTeam(FHero, hero) then
      local Position = Entity.GetAbsOrigin(FHero)
      local Distance = WorldPos:Distance(Position)
      if ClosestDist > Distance then
        ClosestDist = Distance
        ClosestHero = FHero
      end
    end
  end
  return ClosestHero
end
-- Returns: blockScore (0 = not blocked, negative = partially blocked, -1000 = fully blocked)
local function CreepBlockScore(remnantPos, predictedPos, remnantWidth, creeps)
  local blockScore = 0
  for _, creep in ipairs(creeps) do
    if Entity.IsAlive(creep) and not NPC.IsHero(creep) and not Entity.IsSameTeam(creep, hero) then
      local creepPos = Entity.GetAbsOrigin(creep)
      -- Project creep onto the line from remnant to predictedPos
      local proj = ProjectPointOnLineSegment(remnantPos, predictedPos, creepPos)
      local distToLine = proj and proj:Distance(creepPos) or 9999
      local distToRemnant = remnantPos:Distance(creepPos)
      local distToPred = predictedPos:Distance(creepPos)
      -- Only consider creeps that are between remnant and predictedPos
      local onPath = (remnantPos:Distance(proj) + predictedPos:Distance(proj)) <=
          (remnantPos:Distance(predictedPos) + 1)
      if onPath and distToLine < remnantWidth then
        -- If the creep is very close to the line, and between remnant and predictedPos, heavily penalize
        if distToLine < remnantWidth * 0.7 then
          return -1000                  -- fully blocked
        else
          blockScore = blockScore - 200 -- partially blocked
        end
      elseif distToRemnant < remnantWidth * 1.2 or distToPred < remnantWidth * 1.2 then
        blockScore = blockScore - 50 -- near remnant or predictedPos, but not directly blocking
      end
    end
  end
  return blockScore
end

local function PredictPosition(target, delay)
  local id = Entity.GetIndex(target)
  local pos = Entity.GetAbsOrigin(target)
  local prev = lastPositions[id]
  lastPositions[id] = pos

  if prev then
    local velocity = (pos - prev)
    local speed = velocity:Length()
    if speed > 5 then -- Only predict if actually moving
      local moveDir = velocity:Normalized()
      return pos + moveDir:Scaled(NPC.GetMoveSpeed(target) * delay)
    end
  end

  -- fallback: use facing if no velocity info yet
  local dir = Entity.GetRotation(target):GetForward():Normalized()
  local activity = NPC.GetActivity(target)
  if activity == Enum.GameActivity.ACT_DOTA_RUN or activity == Enum.GameActivity.ACT_DOTA_RUN_RARE then
    return pos + dir:Scaled(NPC.GetMoveSpeed(target) * delay)
  end
  return pos
end

local function GetAutoPredictionStrength(hero, target)
  -- You can tweak these values for your needs
  local minStrength = 1
  local maxStrength = 5

  local heroPos = Entity.GetAbsOrigin(hero)
  local targetPos = Entity.GetAbsOrigin(target)
  local distance = heroPos:Distance(targetPos)

  -- Get target's movement speed
  local moveSpeed = NPC.GetMoveSpeed(target)
  local velocity = (lastPositions[Entity.GetIndex(target)] or targetPos) - targetPos
  local speed = velocity:Length()
  -- If target is not moving, use minimum prediction
  if speed < 5 then
    return minStrength
  end

  -- Scale prediction strength based on distance and move speed
  -- (You can adjust the formula for your needs)
  local distFactor = math.min(distance / 800, 1)   -- 0 to 1
  local speedFactor = math.min(moveSpeed / 550, 1) -- 0 to 1 (550 is max move speed in Dota)

  -- Weighted average: more weight to speed
  local strength = minStrength + (maxStrength - minStrength) * (0.6 * speedFactor + 0.4 * distFactor)
  return math.floor(strength + 0.5) -- round to nearest integer
end

-- Returns best remnant position and angle to "watch" the predicted crossing point, scoring all possible positions
local function GetBestRemnantPositionAndAngle(hero, targetHero, ARemnant)
  if not hero or not targetHero or not ARemnant then return nil, nil, false, nil end

  local remnantCastRange = 850
  local remnantWidth = 150

  local heroPos = Entity.GetAbsOrigin(hero)
  local targetPos = Entity.GetAbsOrigin(targetHero)
  local latency = NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) or 0.05

  local remnantSpeed = 900
  local distance = heroPos:Distance(targetPos)
  local travelTime = distance / remnantSpeed
  local totalDelay = travelTime + latency

  --local predStrength = PredictionStrength:Get()
  local predStrength = GetAutoPredictionStrength(hero, targetHero)
  local predictedPos = PredictPosition(targetHero, totalDelay * predStrength * 0.5)

  if heroPos:Distance(predictedPos) > remnantCastRange then
    predictedPos = heroPos + (predictedPos - heroPos):Normalized():Scaled(remnantCastRange)
  end

  -- Creep collision check
  local creeps = NPCs.InRadius(heroPos, remnantCastRange, Enum.TeamNum.TEAM_NONE, Enum.TeamType.TEAM_BOTH)

  local bestScore = -math.huge
  local bestPos, bestAngle, bestBlocked = nil, nil, false
  local allTested = {}

  -- 360 degree sweep around predicted position
  local radiusSteps = { 0, 50, 100, 150, 200, 250, 300 }
  local angleStep = 15 -- degrees

  for _, radius in ipairs(radiusSteps) do
    for angleDeg = 0, 359, angleStep do
      local rad = math.rad(angleDeg)
      local offset = Vector(math.cos(rad), math.sin(rad), 0):Normalized():Scaled(radius)
      local testPos = predictedPos + offset

      if testPos:Distance(predictedPos) < MinRemnantDistance:Get() then
        goto continue
      end
      if heroPos:Distance(testPos) <= remnantCastRange then
        local blockScore = CreepBlockScore(testPos, predictedPos, remnantWidth, creeps)
        local score = 0
        score = score + blockScore
        -- Prefer positions closer to predicted path
        score = score - testPos:Distance(predictedPos)
        -- Prefer positions "in front" of the target's movement
        local toTest = (testPos - predictedPos):Normalized()
        local targetDir = Entity.GetRotation(targetHero):GetForward():Normalized()
        score = score + (toTest:Dot(targetDir) * 50)

        -- New: Use enemy's facing
        local enemyFacing = targetDir
        local facingDot = toTest:Dot(enemyFacing)
        score = score + (facingDot * 60) -- Increase this value to prioritize facing more

        if facingDot < 0 then
          score = score - 40 -- Penalize if remnant is behind the enemy
        end
        -- Prefer center (radius == 0)
        if radius == 0 then score = score + 30 end
        -- Penalize being too far from hero
        score = score - (heroPos:Distance(testPos) * 0.1)

        table.insert(allTested, { pos = testPos, score = score })

        if score > bestScore then
          bestScore = score
          bestPos = testPos
          bestBlocked = (blockScore <= -1000)
          -- Facing logic: always "watch" the predicted position
          local watchDir = (predictedPos - testPos):Normalized()
          bestAngle = watchDir:ToAngle()
        end
      end

      ::continue::
    end
  end

  return bestPos, bestAngle, bestBlocked, allTested
end
-- Draws remnant prediction and direction, and all tested positions with their scores
script.OnDraw = function()
  if hero == nil then hero = Heroes.GetLocal() end
  if not hero or NPC.GetUnitName(hero) ~= "npc_dota_hero_void_spirit" then return end
  if not Keybind:IsDown() then return end
  if not DrawDebugInfo:Get() then return end

  local ClosestHero = GetClosestHeroToMouse()
  if not ClosestHero then return end
  local ARemnant = NPC.GetAbility(hero, "void_spirit_aether_remnant")
  if not ARemnant then return end

  local bestPos, bestAngle, pathBlocked, allTested = GetBestRemnantPositionAndAngle(hero, ClosestHero, ARemnant)
  if not bestPos then return end

  -- Draw all tested positions and their scores (as a heatmap)
  if allTested then
    for _, test in ipairs(allTested) do
      local x, y, visible = Renderer.WorldToScreen(test.pos)
      if visible then
        local score = test.score
        local color
        if score > 0 then
          color = Color(80, 255, 120, 120) -- greenish for good
        elseif score > -200 then
          color = Color(255, 200, 80, 120) -- yellowish for ok
        else
          color = Color(255, 80, 80, 120)  -- reddish for bad
        end
        Render.FilledCircle(Vec2(x, y), 10, color)
        Render.Circle(Vec2(x, y), 12, Color(0, 0, 0, 80), 2)
      end
    end
  end

  -- Draw best position highlight
  local x, y, visible = Renderer.WorldToScreen(bestPos)
  if not visible then return end
  local screenPos = Vec2(x, y)

  -- Shadow and glow for best position
  Render.ShadowCircle(screenPos, 22, Color(0, 0, 0, 180), 16)
  Render.CircleGradient(screenPos, 20, Color(180, 80, 255, 0),
    pathBlocked and Color(255, 80, 80, 180) or Color(180, 80, 255, 180))

  -- Draw remnant model
  Render.FilledCircle(screenPos, 18, pathBlocked and Color(255, 80, 80, 180) or Color(180, 80, 255, 180))
  -- Draw catch radius
  Render.Circle(screenPos, 75, pathBlocked and Color(255, 80, 80, 120) or Color(120, 200, 255, 120), 2)

  -- Draw facing direction (arrow)
  local angle = bestAngle or Angle(0, 0, 0)
  local yaw = angle:GetYaw()
  local dir = Vector(math.cos(math.rad(yaw)), math.sin(math.rad(yaw)), 0):Normalized()
  local lineEndWorld = bestPos + dir:Scaled(60)
  local lineEndX, lineEndY, endVisible = Renderer.WorldToScreen(lineEndWorld)
  if endVisible then
    local lineEndScreen = Vec2(lineEndX, lineEndY)
    Render.Line(screenPos, lineEndScreen, pathBlocked and Color(255, 80, 80, 200) or Color(80, 255, 180, 200), 4)
    -- Draw arrow head
    local perp = Vector(-dir.y, dir.x, 0):Normalized()
    local arrowLeft = lineEndScreen + Vec2(perp.x, perp.y) * 8 - dir:Scaled(10)
    local arrowRight = lineEndScreen - Vec2(perp.x, perp.y) * 8 - dir:Scaled(10)
    Render.FilledTriangle({ lineEndScreen, arrowLeft, arrowRight },
      pathBlocked and Color(255, 80, 80, 200) or Color(80, 255, 180, 200))
  end

  -- Draw line from hero to remnant
  local hx, hy, hvisible = Renderer.WorldToScreen(Entity.GetAbsOrigin(hero))
  if hvisible then
    Render.Line(Vec2(hx, hy), screenPos, Color(200, 200, 200, 80), 2)
  end

  -- Draw info box (bottom left)
  local scr = Render.ScreenSize()
  local boxW, boxH = 260, 120
  local boxPos = Vec2(1600, scr.y - boxH - 128)
  local boxEnd = boxPos + Vec2(boxW, boxH)
  Render.Blur(boxPos, boxEnd, 2, 0.7, 12)
  Render.FilledRect(boxPos, boxEnd, Color(30, 20, 60, 220), 12)
  Render.OutlineGradient(boxPos, boxEnd, Color(180, 80, 255, 180), Color(80, 255, 180, 180), Color(80, 80, 255, 180),
    Color(255, 80, 80, 180), 12, nil, 2)

  -- Info text
  local fontSize = 18
  local y = boxPos.y + 16
  Render.Text(Font, fontSize, "Void Spirit Remnant Debug", boxPos + Vec2(16, y - boxPos.y), Color(255, 255, 255, 220))
  y = y + 28
  Render.Text(Font, 15, "Best Score: " .. string.format("%.1f", (allTested and allTested[1] and allTested[1].score or 0)),
    boxPos + Vec2(16, y - boxPos.y), Color(180, 255, 180, 220))
  y = y + 22
  Render.Text(Font, 15, "Remnant Blocked: " .. (pathBlocked and "YES" or "NO"), boxPos + Vec2(16, y - boxPos.y),
    pathBlocked and Color(255, 80, 80, 220) or Color(80, 255, 180, 220))
  y = y + 22
  Render.Text(Font, 15, "Auto Prediction: " .. tostring(GetAutoPredictionStrength(hero, ClosestHero)),
    boxPos + Vec2(16, y - boxPos.y), Color(120, 200, 255, 220))
  y = y + 22
  Render.Text(Font, 15, "Min Distance: " .. tostring(MinRemnantDistance:Get()), boxPos + Vec2(16, y - boxPos.y),
    Color(255, 255, 180, 220))
end

-- Casts remnant at best position (both orders)
script.OnUpdate = function()
  if hero == nil then hero = Heroes.GetLocal() end
  if not hero or NPC.GetUnitName(hero) ~= "npc_dota_hero_void_spirit" then return end
  if not Keybind:IsDown() then return end

  local ClosestHero = GetClosestHeroToMouse()
  if not ClosestHero then return end
  local ARemnant = NPC.GetAbility(hero, "void_spirit_aether_remnant")
  if not ARemnant or Ability.GetCooldown(ARemnant) ~= 0.0 or not Ability.IsOwnersManaEnough(ARemnant) or Ability.GetLevel(ARemnant) == 0 then return end

  local remnantCastRange = 850
  local heroPos = Entity.GetAbsOrigin(hero)
  local targetPos = Entity.GetAbsOrigin(ClosestHero)
  if heroPos:Distance(targetPos) > remnantCastRange then return end

  local bestPos, bestAngle, pathBlocked = GetBestRemnantPositionAndAngle(hero, ClosestHero, ARemnant)
  if not bestPos then return end -- don't cast if path is blocked

  -- Calculate the facing direction
  local angle = bestAngle or Angle(0, 0, 0)
  local yaw = angle:GetYaw()
  local facingDir = Vector(math.cos(math.rad(yaw)), math.sin(math.rad(yaw)), 0):Normalized()
  local vectorTarget = bestPos + facingDir:Scaled(200) -- 200 units forward

  -- First: set the angle (vector order)
  Player.PrepareUnitOrders(
    Players.GetLocal(),
    Enum.UnitOrder.DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION,
    nil,
    vectorTarget,
    ARemnant,
    Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
    hero
  )
  -- Second: cast the remnant at the position
  Player.PrepareUnitOrders(
    Players.GetLocal(),
    Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION,
    nil,
    bestPos,
    ARemnant,
    Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
    hero
  )
end

script.OnGameEnd = function()
  lastPositions = nil
  hero = nil
end

return script
