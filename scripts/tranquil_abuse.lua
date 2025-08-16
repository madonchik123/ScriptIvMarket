local script = {}

-- ========= Menu =========
local root = Menu.Create("General", "Main", "Tranquil Abuse")
root:Icon("\u{f782}")
local rootMenu = root:Create("Main")

-- General
local generalGroup = rootMenu:Create("General")
local Toggle = generalGroup:Switch("Enable", true, "\u{f205}")
local AbuseWhenOnCooldown = generalGroup:Switch("Abuse When On Cooldown", false, "\u{f078}")
local DisableAfterToggle = generalGroup:Switch("Disable After", true, "\u{f078}")
local DisableAfter = generalGroup:Slider("Disable After", 5, 50, 10, "%d min")
local IgnoreRadius = generalGroup:Slider("Ignore Enemies Radius", 100, 800, 150, "%d")
local BlockOrders = generalGroup:Switch("Block Orders During Cycle", false, "\u{f078}")

-- Lead
local realGroup = rootMenu:Create("Real-Time Lead")
local RealTimeLead = realGroup:Switch("Enable Real-Time Lead", true, "\u{f017}")
local RTTravelPercent = realGroup:Slider("Travel Time %", 5, 60, 25, function(v) return v .. "%" end)
local RTMinLead = realGroup:Slider("Min Lead", 20, 350, 60, "%d ms")
local RTMaxLead = realGroup:Slider("Max Lead", 80, 650, 650, "%d ms")
local RTMultiExtra = realGroup:Slider("Extra / Projectile", 0, 200, 30, "%d ms")
local RTPingScale = realGroup:Slider("Ping Scale %", 0, 150, 60, function(v) return v .. "%" end)

local manualGroup = rootMenu:Create("Manual Lead")
local BaseDropLead = manualGroup:Slider("Base Drop Lead", 50, 400, 120, "%d ms")
local PingCompensation = manualGroup:Switch("Ping Compensation", true, "\u{f078}")

-- Safety
local safetyGroup = rootMenu:Create("Safety & Pickup")
local PickupBuffer = safetyGroup:Slider("Pickup Safety Buffer", 50, 700, 150, "%d ms")
local ProjectileGrouping = safetyGroup:Slider("Projectile Grouping Window", 40, 300, 170, "%d ms")

-- Advanced Timing (tunable; cached every tick)
local advGroup = rootMenu:Create("Advanced")
local ADV_InputLatency = advGroup:Slider("Input Latency", 10, 60, 30, "%d ms")
local ADV_EarlyFudge = advGroup:Slider("Early Fudge Bias", 10, 40, 25, "%d ms")
local ADV_ImmediateThreshold = advGroup:Slider("Immediate Threshold", 10, 120, 60, "%d ms")
local ADV_EmergencyWindow = advGroup:Slider("Emergency Window", 40, 120, 75, "%d ms")
local ADV_PostPickupSuppress = advGroup:Slider("Post-Pickup Suppress", 80, 300, 180, "%d ms")
local ADV_UncertaintyBuffer = advGroup:Slider("Impact Uncertainty", 20, 60, 30, "%d ms")
local ADV_MinDropInterval = advGroup:Slider("Min Drop Interval", 30, 120, 50, "%d ms")

-- Debug
local debugGroup = rootMenu:Create("Debug & Telemetry")
local DebugMode = debugGroup:Switch("Debug Mode", false, "\u{f188}")
local LogProjectiles = debugGroup:Switch("Log Projectiles", false, "\u{f188}")
debugGroup:SearchHidden(true)

local function ApplyMenuState()
  local enabled = Toggle:Get()
  realGroup:Disabled(not enabled)
  manualGroup:Disabled(not enabled or (enabled and RealTimeLead:Get()))
  safetyGroup:Disabled(not enabled)
  advGroup:Disabled(not enabled)
  debugGroup:Disabled(not enabled)
  IgnoreRadius:Disabled(not enabled)
  BlockOrders:Disabled(not enabled)
  DisableAfter:Disabled(not enabled)
  DisableAfterToggle:Disabled(not enabled)
end

if Toggle.SetCallback and RealTimeLead.SetCallback then
  Toggle:SetCallback(ApplyMenuState)
  RealTimeLead:SetCallback(ApplyMenuState)
else
  script._legacyMenuPolling = true
  local nextMenuStateUpdate = 0
  script._UpdateMenuStates = function(now)
    if now >= nextMenuStateUpdate then
      ApplyMenuState()
      nextMenuStateUpdate = now + 0.5
    end
  end
end
ApplyMenuState()

-- ========= Locals / State =========
local player, hero
local gameTime = 0

-- Config cache (updated each tick)
local cfg_enabled = true
local cfg_disableAfter = false
local cfg_disableAtTime = 0
local cfg_ignoreRadius = 150
local cfg_blockOrders = false

local cfg_rtlEnabled = true
local cfg_rtTravelPct = 0.25
local cfg_rtMinLead = 0.065
local cfg_rtMaxLead = 0.260
local cfg_rtMultiExtra = 0.030
local cfg_rtPingScale = 0.60

local cfg_baseLead = 0.120
local cfg_pingComp = true

local cfg_pickupBuffer = 0.180
local cfg_groupWindow = 0.120

local cfg_inputLatency = 0.030
local cfg_earlyFudge = 0.025
local cfg_immediateThreshold = 0.060
local cfg_emergencyWindow = 0.075
local cfg_postPickupSuppress = 0.180
local cfg_uncertainty = 0.030
local cfg_minDropInterval = 0.050

-- Ping (cached)
local pingSec = 0
local nextPingRefresh = 0
local PING_REFRESH_INTERVAL = 0.25

-- Windows (no sorting; linear scan; tiny N)
local maxWindows = 16
local windowsStart, windowsEnd, windowsCount = {}, {}, {}
local windowsN = 0
local earliestIdx = 0

-- State machine
local STATE_IDLE, STATE_DROPPING, STATE_READY, STATE_PICKING = 0, 1, 2, 3
local state = STATE_IDLE

-- Drop/pick variables
local dropAt = 0 -- scheduled time
local dropTime = 0
local itemEntity, itemIndex
local retryTime = 0
local suppressGuardsUntil = 0
local lastImmediateAttempt = 0
local lastOrderTime = 0
local lastDropAttempt = 0
local lastPickupTime = 0

-- Tracking current earliest projectile to allow earlier reschedules
local earliestImpactTime = 0
local earliestProj = nil -- {src=entity, speed=, dist0=}

-- Misc constants
local ORDER_COOLDOWN = 0.010
local PROJECTILE_CLEANUP_INTERVAL = 0.015
local nextWindowsCleanup = 0

local MIN_PROJECTILE_SPEED = 50
local DEFAULT_PROJECTILE_SPEED = 900

-- ========= Utils =========
local function DebugLog(msg)
  if DebugMode:Get() then print("[Tranquil] " .. msg) end
end

local function GetPingSeconds()
  if not NetChannel or not NetChannel.GetAvgLatency then return 0 end
  local ok, v = pcall(NetChannel.GetAvgLatency)
  if not ok or not v then return 0 end
  if v > 3 then return math.min(1.0, v / 1000.0) end -- ms->s
  return math.min(1.0, math.max(0, v))
end

local function RefreshConfig(now)
  cfg_enabled = Toggle:Get()
  cfg_disableAfter = DisableAfterToggle:Get()
  cfg_disableAtTime = DisableAfter:Get() * 60
  cfg_ignoreRadius = IgnoreRadius:Get()
  cfg_blockOrders = BlockOrders:Get()

  cfg_rtlEnabled = RealTimeLead:Get()
  cfg_rtTravelPct = RTTravelPercent:Get() * 0.01
  cfg_rtMinLead = RTMinLead:Get() * 0.001
  cfg_rtMaxLead = RTMaxLead:Get() * 0.001
  cfg_rtMultiExtra = RTMultiExtra:Get() * 0.001
  cfg_rtPingScale = RTPingScale:Get() * 0.01

  cfg_baseLead = BaseDropLead:Get() * 0.001
  cfg_pingComp = PingCompensation:Get()

  cfg_pickupBuffer = PickupBuffer:Get() * 0.001
  cfg_groupWindow = ProjectileGrouping:Get() * 0.001

  cfg_inputLatency = ADV_InputLatency:Get() * 0.001
  cfg_earlyFudge = ADV_EarlyFudge:Get() * 0.001
  cfg_immediateThreshold = ADV_ImmediateThreshold:Get() * 0.001
  cfg_emergencyWindow = ADV_EmergencyWindow:Get() * 0.001
  cfg_postPickupSuppress = ADV_PostPickupSuppress:Get() * 0.001
  cfg_uncertainty = ADV_UncertaintyBuffer:Get() * 0.001
  cfg_minDropInterval = ADV_MinDropInterval:Get() * 0.001

  if now >= nextPingRefresh then
    nextPingRefresh = now + PING_REFRESH_INTERVAL
    pingSec = cfg_pingComp and GetPingSeconds() or 0
  end
end

local function HasTranquils()
  return hero and NPC.HasItem(hero, "item_tranquil_boots")
end

-- ========= Windows =========
local function RecomputeEarliest()
  earliestIdx = 0
  local best = math.huge
  for i = 1, windowsN do
    local s = windowsStart[i]
    if s < best then
      best = s; earliestIdx = i
    end
  end
end

local function AddWindow(s, e)
  local mergeTol = cfg_groupWindow * 2
  for i = 1, windowsN do
    if s <= windowsEnd[i] + mergeTol and e >= windowsStart[i] - mergeTol then
      if s < windowsStart[i] then windowsStart[i] = s end
      if e > windowsEnd[i] then windowsEnd[i] = e end
      windowsCount[i] = (windowsCount[i] or 1) + 1
      if earliestIdx == 0 or windowsStart[i] < windowsStart[earliestIdx] then earliestIdx = i end
      return i
    end
  end
  if windowsN < maxWindows then
    windowsN = windowsN + 1
    windowsStart[windowsN] = s
    windowsEnd[windowsN] = e
    windowsCount[windowsN] = 1
    if earliestIdx == 0 or s < windowsStart[earliestIdx] then earliestIdx = windowsN end
    return windowsN
  else
    -- Replace latest-start window if new is earlier (keep near-future ones)
    local worstIdx, worstStart = 1, windowsStart[1]
    for i = 2, windowsN do
      if windowsStart[i] > worstStart then
        worstStart = windowsStart[i]; worstIdx = i
      end
    end
    if s < worstStart then
      windowsStart[worstIdx] = s
      windowsEnd[worstIdx] = e
      windowsCount[worstIdx] = 1
      RecomputeEarliest()
      return worstIdx
    end
  end
end

local function CleanupWindows(now)
  local cutoff = now - cfg_pickupBuffer
  local w = 1
  for i = 1, windowsN do
    if windowsEnd[i] > cutoff then
      if w ~= i then
        windowsStart[w] = windowsStart[i]
        windowsEnd[w] = windowsEnd[i]
        windowsCount[w] = windowsCount[i]
      end
      w = w + 1
    end
  end
  for i = w, windowsN do
    windowsStart[i] = nil
    windowsEnd[i] = nil
    windowsCount[i] = nil
  end
  windowsN = w - 1
  RecomputeEarliest()
end

local function IsSafeToPickup(now)
  local safeTime = now + cfg_pickupBuffer
  for i = 1, windowsN do
    if windowsStart[i] <= safeTime and windowsEnd[i] >= now then
      return false
    end
  end
  return true
end

-- ========= Lead / Timing =========
local function ComputeLead(travelTime, projCount)
  local base = cfg_baseLead + cfg_inputLatency + cfg_earlyFudge
  if not cfg_rtlEnabled then
    return math.min(base + (cfg_pingComp and pingSec or 0), math.max(0, travelTime - 0.01))
  end

  local pingPart = (cfg_pingComp and pingSec or 0) * cfg_rtPingScale
  local lead = base + pingPart + (travelTime * cfg_rtTravelPct) + math.max(0, (projCount or 1) - 1) * cfg_rtMultiExtra
  if lead < cfg_rtMinLead then lead = cfg_rtMinLead end
  if lead > cfg_rtMaxLead then lead = cfg_rtMaxLead end

  local safety = 0.015
  if lead > travelTime - safety then
    lead = math.max(cfg_rtMinLead, travelTime - safety)
  end
  return lead
end

local function GetVerifyDelay()
  return math.max(0.15, math.min(0.14, pingSec * 1.2 + 0.035))
end

local function ClearCycle(now)
  dropAt = 0
  earliestImpactTime = 0
  earliestProj = nil
  -- keep only future windows
  local eps = 0.005
  local w = 1
  for i = 1, windowsN do
    if windowsEnd[i] > now + eps then
      if w ~= i then
        windowsStart[w] = windowsStart[i]
        windowsEnd[w] = windowsEnd[i]
        windowsCount[w] = windowsCount[i]
      end
      w = w + 1
    end
  end
  for i = w, windowsN do
    windowsStart[i] = nil
    windowsEnd[i] = nil
    windowsCount[i] = nil
  end
  windowsN = w - 1
  RecomputeEarliest()
end

-- ========= Orders =========
local function DropTranquils(now, priority)
  if not hero or not player then return false end
  if not HasTranquils() then return false end

  if (not priority) and (now - lastOrderTime < ORDER_COOLDOWN) then return false end
  if now - lastDropAttempt < cfg_minDropInterval then return false end

  local tranquil = NPC.GetItem(hero, "item_tranquil_boots")
  local cooldown = Ability.GetCooldown(tranquil)
  if not tranquil then return false end
  if AbuseWhenOnCooldown:Get() == false and cooldown > 0 then return false end

  local ok = pcall(function()
    Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_DROP_ITEM,
      nil, Entity.GetAbsOrigin(hero), tranquil,
      Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
      hero, false, false, false, true)
  end)

  if ok then
    lastOrderTime = now
    lastDropAttempt = now
    dropTime = now
    dropAt = 0
    earliestImpactTime = 0
    earliestProj = nil
    state = STATE_DROPPING
    DebugLog(priority and "Drop sent (PRIORITY)" or "Drop sent")
    return true
  end
  return false
end

local function FindDroppedTranquils()
  local items = PhysicalItems.GetAll()
  if not items or #items == 0 then return false end
  local heroPos = Entity.GetAbsOrigin(hero)
  local best, bestD = nil, 1e9
  for i = 1, #items do
    local fitem = items[i]
    local item = PhysicalItem.GetItem(fitem)
    if item and Entity.GetClassName(item) == "C_DOTA_Item_TranquilBoots" then
      local ipos = Entity.GetAbsOrigin(fitem)
      local d = ipos and heroPos:Distance(ipos) or 0
      if d < bestD then
        best = fitem; bestD = d
      end
    end
  end
  if best then
    itemEntity = best
    local it = PhysicalItem.GetItem(best)
    itemIndex = it and Entity.GetIndex(it) or nil
    return true
  end
  return false
end

local function PickupTranquils(now)
  if not itemEntity then return false end
  if now - lastOrderTime < ORDER_COOLDOWN then return false end

  local ok = pcall(function()
    Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_PICKUP_ITEM,
      itemEntity, Vector(0, 0, 0), nil,
      Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
      hero, false, false, false, true)
  end)
  if ok then
    lastOrderTime = now
    retryTime = now + 0.08
    DebugLog("Pickup order")
    return true
  end
  return false
end

-- ========= OnProjectile =========
local function GetProjectilePos(data)
  return data.position or data.pos or data.origin or data.startPos or data.start or data.start_position or
      data.spawnOrigin or data.spawn_origin
end

script.OnProjectile = function(data)
  if not data then return end
  local now = GameRules.GetGameTime()
  if not hero then return end

  if cfg_disableAfter and now >= cfg_disableAtTime then return end
  if not cfg_enabled then return end

  local target = data.target
  if not target or target ~= hero then return end
  local source = data.source
  if not source or Entity.IsSameTeam(hero, source) or not Entity.IsHero(source) then return end

  -- Distance from current projectile pos if available
  local heroPos = Entity.GetAbsOrigin(hero)
  local projPos = GetProjectilePos(data)
  local srcPos = (not projPos) and Entity.GetAbsOrigin(source) or nil
  local distance = heroPos:Distance(projPos or srcPos)
  if distance <= cfg_ignoreRadius then return end

  if LogProjectiles:Get() then
    print(string.format("[Proj] %s->me spd=%s dst=%.0f",
      NPC.GetUnitName(source) or "?", tostring(data.moveSpeed or data.original_move_speed), distance))
  end

  -- New projectile observed -> lift post-pickup suppression immediately (we want to react)
  if now < suppressGuardsUntil then suppressGuardsUntil = now end

  -- Impact time
  local speed = math.max(MIN_PROJECTILE_SPEED, data.moveSpeed or data.original_move_speed or DEFAULT_PROJECTILE_SPEED)
  local impactTime = (data.maxImpactTime and data.maxImpactTime > now) and data.maxImpactTime
      or (data.expireTime and data.expireTime > now) and data.expireTime
      or (now + distance / speed)

  -- Add window
  AddWindow(impactTime - cfg_uncertainty, impactTime + cfg_uncertainty)

  -- Only schedule when boots are on hero and idle
  if state ~= STATE_IDLE or not HasTranquils() then return end

  local travel = impactTime - now
  -- Approx projectile pressure from overlapping windows
  local count = 1
  for i = 1, windowsN do
    if windowsStart[i] <= impactTime + 0.05 and windowsEnd[i] >= now then
      local c = windowsCount[i] or 1
      if c > count then count = c end
    end
  end

  local lead = ComputeLead(travel, count)
  local dropTimeAt = impactTime - lead

  -- Emergency: impact soon -> drop right now
  if travel <= cfg_emergencyWindow then
    if now - lastImmediateAttempt > 0.010 then
      lastImmediateAttempt = now
      DropTranquils(now, true)
    end
    return
  end

  -- Immediate window
  if dropTimeAt <= now + cfg_immediateThreshold then
    if now - lastImmediateAttempt > 0.010 then
      lastImmediateAttempt = now
      DropTranquils(now, true)
    end
  else
    -- Schedule earliest drop
    if dropAt == 0 or dropTimeAt < dropAt - 0.004 then
      dropAt = dropTimeAt
      earliestImpactTime = impactTime
      earliestProj = { src = source, speed = speed, dist0 = distance }
      DebugLog(string.format("Scheduled drop in %.3fs (lead %.3fs)", dropAt - now, lead))
    end
  end
end

-- ========= Update =========
script.OnUpdate = function()
  hero = hero or Heroes.GetLocal()
  player = player or Players.GetLocal()
  gameTime = GameRules.GetGameTime()

  if not hero or not player then return end

  RefreshConfig(gameTime)
  if not cfg_enabled then return end
  if cfg_disableAfter and gameTime >= cfg_disableAtTime then return end

  -- Windows cleanup
  if gameTime >= nextWindowsCleanup then
    nextWindowsCleanup = gameTime + PROJECTILE_CLEANUP_INTERVAL
    CleanupWindows(gameTime)
  end

  -- Fire scheduled drop
  if state == STATE_IDLE and HasTranquils() and dropAt > 0 and gameTime >= dropAt then
    DropTranquils(gameTime, true)
  end

  -- If we moved closer to source, reschedule earlier (only earlier)
  if state == STATE_IDLE and HasTranquils() and earliestProj and earliestImpactTime > 0 then
    local src = earliestProj.src
    if src and Entity.IsAlive(src) then
      local d = Entity.GetAbsOrigin(hero):Distance(Entity.GetAbsOrigin(src))
      if d + 20 < (earliestProj.dist0 or d) then
        local speed = earliestProj.speed or DEFAULT_PROJECTILE_SPEED
        local newImpact = gameTime + (d / speed)
        if newImpact + 0.005 < earliestImpactTime then
          -- recompute lead with current pressure
          local count = 1
          for i = 1, windowsN do
            if windowsStart[i] <= newImpact + 0.05 and windowsEnd[i] >= gameTime then
              local c = windowsCount[i] or 1
              if c > count then count = c end
            end
          end
          local newLead = ComputeLead(newImpact - gameTime, count)
          local newDropAt = newImpact - newLead
          earliestImpactTime = newImpact
          earliestProj.dist0 = d

          if (newImpact - gameTime) <= cfg_emergencyWindow then
            DropTranquils(gameTime, true)
          elseif newDropAt <= gameTime + cfg_immediateThreshold then
            DropTranquils(gameTime, true)
          elseif dropAt == 0 or newDropAt < dropAt - 0.006 then
            dropAt = newDropAt
            DebugLog(string.format("Rescheduled drop in %.3fs", dropAt - gameTime))
          end
        end
      end
    else
      earliestProj = nil
      earliestImpactTime = 0
    end
  end

  -- Guard: if a FUTURE window is dangerously close (and not suppressed), force an emergency drop
  if state == STATE_IDLE and HasTranquils() and gameTime >= suppressGuardsUntil and windowsN > 0 then
    local idx = earliestIdx
    if idx ~= 0 then
      local ts = windowsStart[idx] - gameTime
      local te = windowsEnd[idx] - gameTime
      if te > 0 and (ts <= cfg_emergencyWindow or te <= cfg_emergencyWindow) then
        DropTranquils(gameTime, true)
      end
    end
  end

  -- State machine
  if state == STATE_DROPPING then
    if gameTime - dropTime >= GetVerifyDelay() then
      if HasTranquils() then
        -- Drop didn't register, reset
        state = STATE_IDLE
        dropAt = 0
        DebugLog("Drop verify failed (still on hero)")
      elseif FindDroppedTranquils() then
        state = STATE_READY
        DebugLog("Drop verified")
      else
        -- Allow extra search time
        if gameTime - dropTime > 0.6 then
          state = STATE_IDLE
          dropAt = 0
          DebugLog("Drop timeout: can't find boots")
        end
      end
    end
  elseif state == STATE_READY then
    if not itemEntity and not FindDroppedTranquils() then
      state = STATE_IDLE
      dropAt = 0
      DebugLog("Lost dropped boots")
    else
      if IsSafeToPickup(gameTime) then
        if PickupTranquils(gameTime) then
          state = STATE_PICKING
        end
      else
        if gameTime - dropTime > 4.0 then
          state = STATE_IDLE
          dropAt = 0
          DebugLog("Pickup aborted (timeout)")
        end
      end
    end
  elseif state == STATE_PICKING then
    if HasTranquils() then
      -- Completed cycle
      state = STATE_IDLE
      itemEntity, itemIndex = nil, nil
      lastPickupTime = gameTime
      suppressGuardsUntil = gameTime + cfg_postPickupSuppress
      ClearCycle(gameTime)
      DebugLog("Pickup verified")
    elseif retryTime > 0 and gameTime >= retryTime then
      retryTime = 0
      if IsSafeToPickup(gameTime) then
        PickupTranquils(gameTime)
      else
        state = STATE_READY
      end
    elseif gameTime - dropTime > 2.5 then
      state = STATE_IDLE
      DebugLog("Pickup timeout")
    end
  end
end

-- ========= Order blocking =========
local blocked_orders = {
  [Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_DIRECTION] = true,
  [Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET] = true,
  [Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION] = true,
  [Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_MOVE] = true,
  [Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET] = true,
  [Enum.UnitOrder.DOTA_UNIT_ORDER_HOLD_POSITION] = true,
}

script.OnPrepareUnitOrders = function(order)
  if not cfg_enabled or not cfg_blockOrders then return end
  if state == STATE_IDLE then return end
  if order.order == Enum.UnitOrder.DOTA_UNIT_ORDER_PICKUP_ITEM then
    return true
  end
  return not blocked_orders[order.order]
end

script.OnGameEnd = function()
  if hero then
    hero = nil
    player = nil
  end
end

return script
