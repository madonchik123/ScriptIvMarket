local script   = {}

local settings = Menu.Create("Heroes", "Hero List", "Invoker", "Auto Usage", "Sun Strike Settings")
local switch   = settings:Switch("Use on teleport", true)
local gear     = switch:Gear("Settings")
local Delay    = gear:Slider("Teleport Arrive Delay", 0, 0.5, 0.0, "%.1f s")
Delay:Icon("\u{f017}")
switch:Icon("\u{e042}")
local hero, player                = nil, nil

local activeTarget                = nil

local processedTeleportIndices    = {}
local canceledTeleportIndices     = {}

local lastExortTap, lastInvokeTap = 0, 0

local function now()
  return GameRules and GameRules.GetGameTime and GameRules.GetGameTime() or 0
end

local function isEnemyHero(me, ent)
  if not ent or not me then return false end
  if not Entity.IsHero(ent) or not Entity.IsAlive(ent) then return false end
  return Entity.GetTeamNum(ent) ~= Entity.GetTeamNum(me)
end

local function cleanupIndexMaps()
  local t = now()
  for idx, ts in pairs(processedTeleportIndices) do
    if (t - ts) > 5 then
      processedTeleportIndices[idx] = nil
    end
  end
  for idx, info in pairs(canceledTeleportIndices) do
    if (t - (info.time or 0)) > 5 then
      canceledTeleportIndices[idx] = nil
    end
  end
end

local function getExortOrbCount(npc)
  if not npc then return 0 end
  local mods = NPC.GetModifiers(npc) or {}
  local count = 0
  for i = 1, #mods do
    if Modifier.GetName(mods[i]) == "modifier_invoker_exort_instance" then
      count = count + 1
      if count == 3 then break end
    end
  end
  return count
end

local function ensureSunstrikeInvoked()
  hero = hero or Heroes.GetLocal()
  player = player or Players.GetLocal()
  if not hero or not player then return false end

  local Exort     = NPC.GetAbility(hero, "invoker_exort")
  local Invoke    = NPC.GetAbility(hero, "invoker_invoke")
  local Sunstrike = NPC.GetAbility(hero, "invoker_sun_strike")
  if not Exort or not Invoke or not Sunstrike then return false end

  if Ability.CanBeExecuted(Sunstrike) == -1 then
    return true
  end

  if Ability.GetCooldown(Invoke) > 0 or Ability.GetCooldown(Sunstrike) > 0 then
    return false
  end

  local t = now()
  if getExortOrbCount(hero) < 3 then
    if t - lastExortTap >= 0.10 then
      Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, nil, Exort,
        Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, hero)
      lastExortTap = t
    end
    return false
  end

  if t - lastInvokeTap >= 0.05 then
    Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil, nil, Invoke,
      Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, hero, false, false, false, true, false, true)
    lastInvokeTap = t
  end

  return false
end

local function castSunstrikeAt(pos)
  hero = hero or Heroes.GetLocal()
  player = player or Players.GetLocal()
  if not hero or not player or not pos then return false end

  local Sunstrike = NPC.GetAbility(hero, "invoker_sun_strike")
  if not Sunstrike then return false end

  if Ability.CanBeExecuted(Sunstrike) == -1 then
    pos = Vector(pos.x, pos.y, 0) -- force ground Z
    Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, nil, pos, Sunstrike,
      Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, hero)
    return true
  end
  return false
end

local function getSunstrikeDamage()
  local exort = NPC.GetAbility(hero, "invoker_exort")
  local lvl = exort and Ability.GetLevel(exort) - 1
  if not lvl or lvl < 1 then lvl = 1 end

  local ss = NPC.GetAbility(hero, "invoker_sun_strike")
  if ss then
    return Ability.GetLevelSpecialValueFor(ss, "damage", lvl)
  end
  return 0
end

local function getRegenRate(npc)
  return NPC.GetHealthRegen(npc) or 0
end

local function predictHealthAt(target, futureTime)
  local hp = Entity.GetHealth(target) or 0
  local dt = math.max(0, futureTime - now())
  local regen = getRegenRate(target)
  return hp + regen * dt
end

local function lethalAtArrival(target, arrivalTime)
  local predicted = predictHealthAt(target, arrivalTime)
  local damage = getSunstrikeDamage()
  return (predicted - 10) <= damage -- safety margin 10
end

local function tryAcquireTarget()
  if not LIB_HEROES_DATA or not LIB_HEROES_DATA.teleport_time then return end
  cleanupIndexMaps()

  for idx, rec in pairs(LIB_HEROES_DATA.teleport_time) do
    if rec and rec.name == "teleport_end" and not processedTeleportIndices[idx] then
      local target = rec.target
      if isEnemyHero(hero, target) then
        local pos = rec.position
        local endTime = rec.end_time
        if pos and endTime then
          local arriveTime = endTime + Delay:Get()
          local castTime   = arriveTime - 1.70
          local prepTime   = castTime - 0.45

          if lethalAtArrival(target, arriveTime) then
            activeTarget = {
              entity   = target,
              position = pos,
              endTime  = arriveTime, -- store the actual arrival time we aim for
              index    = rec.index,
              prepTime = prepTime,
              castTime = castTime
            }
            processedTeleportIndices[idx] = now()
            Log.Write(string.format("[TP] Target '%s' acquired: cast@%.2f, arrive@%.2f, idx=%s",
              NPC.GetUnitName(target), castTime, arriveTime, tostring(activeTarget.index)))
            return
          else
            processedTeleportIndices[idx] = now()
          end
        end
      end
    end
  end
end

script.OnUpdate = function()
  hero = hero or Heroes.GetLocal()
  player = player or Players.GetLocal()
  if not hero or not player then return end

  if not switch:Get() then return end
  if not NPC.GetUnitName(hero) == "npc_dota_hero_invoker" then return end

  if not activeTarget then
    tryAcquireTarget()
  end

  if activeTarget then
    local t = now()
    local ent = activeTarget.entity

    if not ent or not Entity.IsAlive(ent) then
      activeTarget = nil
      return
    end

    local cancelInfo = canceledTeleportIndices[activeTarget.index]
    if cancelInfo then
      if cancelInfo.destroyImmediately or (cancelInfo.time + 0.03 < activeTarget.endTime) then
        activeTarget = nil
        return
      end
    end

    if t >= activeTarget.prepTime then
      ensureSunstrikeInvoked()
    end

    if t >= activeTarget.castTime then
      if not lethalAtArrival(ent, activeTarget.endTime) then
        activeTarget = nil
        return
      end

      local ok = castSunstrikeAt(activeTarget.position)
      if ok then
        Log.Write(string.format("[TP] Sun Strike cast at %.2f (ETA %.2f, idx=%s).",
          t, activeTarget.endTime, tostring(activeTarget.index)))
        activeTarget = nil
      else
        if t > (activeTarget.endTime - 0.05) then
          activeTarget = nil
        end
      end
    end
  end
end

script.OnParticleDestroy = function(data)
  hero = Heroes.GetLocal()
  if not hero or not NPC.GetUnitName(hero) == "npc_dota_hero_invoker" then return end
  if not switch:Get() then return end

  canceledTeleportIndices[data.index] = { time = now(), destroyImmediately = data.destroyImmediately }
end

return script
