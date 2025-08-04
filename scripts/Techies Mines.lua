local script = {}

local main = Menu.Create("General", "Main", "Techies Mines")
local menu = main:Create("Main Settings"):Create("Main Settings")
local IsToggled = menu:Switch("Automaticly Destroy Mines", true,
  "panorama/images/spellicons/techies_land_mines_png.vtex_c")
local CountTalent = menu:Switch("Take in count level 25 talent (if learned)", false, "\u{f05b}")

local hero = nil
local player = nil
local IsRanged = nil
local ActivationTime = 1
local TalantLearned = false

GetDistanceFromTo = function(From, To)
  return From:Distance(To)
end

IsTalantLearned = function()
  local Heroes = Heroes.GetAll()
  for Index, EnemyHero in pairs(Heroes) do
    if not Entity.IsSameTeam(hero, EnemyHero) then
      local name = NPC.GetUnitName(EnemyHero)
      if name == "npc_dota_hero_techies" then
        return Hero.TalentIsLearned(EnemyHero, Enum.TalentTypes.TALENT_8)
      end
    end
  end
end

script.OnUpdate = function()
  if CountTalent:Get() then
    if TalantLearned == false then
      TalantLearned = IsTalantLearned()
      if TalantLearned == true then
        ActivationTime = 0.2
      end
    end
  end
  if not IsToggled:Get() then return end
  if hero == nil or player == nil then
    hero = Heroes.GetLocal()
    player = Players.GetLocal()
    IsRanged = NPC.IsRanged(hero)
  end
  if not Entity.IsAlive(hero) then return end
  local Surroundings = Entity.GetUnitsInRadius(hero, 500, Enum.TeamType.TEAM_ENEMY)
  local closestMineDistance = math.huge
  local closestMine = nil
  for Index, Unit in pairs(Surroundings) do
    local name = Entity.GetUnitDesignerName(Unit)
    if name == "npc_dota_techies_mines" and Entity.IsAlive(Unit) then
      local distance = GetDistanceFromTo(Entity.GetAbsOrigin(hero), Entity.GetAbsOrigin(Unit))
      if distance < closestMineDistance then
        closestMineDistance = distance
        closestMine = Unit
      end
    end
  end
  if closestMine ~= nil then
    if IsRanged then
      local AttackRange = NPC.GetAttackRange(hero) + NPC.GetAttackRangeBonus(hero)
      local AttackPoint = NPC.GetAttackAnimPoint(hero)
      local TimeToFace = NPC.GetTimeToFace(hero, closestMine)
      local ProjectileSpeed = NPC.GetAttackProjectileSpeed(hero)
      local distToMine = GetDistanceFromTo(Entity.GetAbsOrigin(hero), Entity.GetAbsOrigin(closestMine))
      if distToMine <= AttackRange then
        local timeToHit = AttackPoint + TimeToFace
        if ProjectileSpeed > 0 then
          timeToHit = timeToHit + (distToMine / ProjectileSpeed)
        end
        if timeToHit < ActivationTime then
          Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, closestMine, nil, nil,
            Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, hero)
          --Log.Write("Can destroy mine! Time to hit: " .. timeToHit .. "s, Activation Time: " .. ActivationTime .. "s")
        end
      end
    else
      local AttackRange = NPC.GetAttackRange(hero) + NPC.GetAttackRangeBonus(hero)
      local AttackPoint = NPC.GetAttackAnimPoint(hero) -- For melee, still use attack point
      local TimeToFace = NPC.GetTimeToFace(hero, closestMine)
      local MoveSpeed = NPC.GetMoveSpeed(hero)
      local distToMine = GetDistanceFromTo(Entity.GetAbsOrigin(hero), Entity.GetAbsOrigin(closestMine))
      -- Time to walk into attack range (if not already)
      local timeToReach = 0

      if distToMine > AttackRange then
        timeToReach = (distToMine - AttackRange) / MoveSpeed
      end

      local timeToHit = timeToReach + TimeToFace + AttackPoint

      if timeToHit < ActivationTime then
        Player.PrepareUnitOrders(player, Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET, closestMine, nil, nil,
          Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, hero)
        --Log.Write("Can destroy mine! Time to hit: " .. timeToHit .. "s, Activation Time: " .. ActivationTime .. "s")
      end
    end
  end
end

script.OnGameEnd = function()
  hero = nil
  IsRanged = nil
  player = nil
  ActivationTime = 1
end

return script
