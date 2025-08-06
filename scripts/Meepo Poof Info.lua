local script = {}

local Menu = Menu.Find("Heroes", "Hero List", "Meepo", "Main Settings", "Poof Binds")

local PoofDamageCalculator = Menu:Switch("Show if poof is gonna kill creeps", true)

local hero = nil
local font = nil

-- Load font once
local function EnsureFont()
  if not font then
    font = Render.LoadFont("Arial", 0, 600)
  end
end

local function GetNearestCreeps()
  local ents = Entity.GetUnitsInRadius(hero, 400, Enum.TeamType.TEAM_ENEMY)
  local creeps = {}
  for _, ent in pairs(ents) do
    if NPC.IsLaneCreep(ent) or NPC.IsCreep(ent) then
      table.insert(creeps, ent)
    end
  end
  return creeps
end

local function CountAmountOfPoofs()
  local MeepoClones = Entity.GetHeroesInRadius(hero, 400, Enum.TeamType.TEAM_FRIEND)
  local Poofs = 0
  for _, entity in pairs(MeepoClones) do
    local Poof = NPC.GetAbility(entity, "meepo_poof")
    if Poof and Ability.IsReady(Poof) and NPC.GetMana(entity) > 80 then
      Poofs = Poofs + 1
    end
  end
  return Poofs
end

local function GetPoofDamage()
  local poof = NPC.GetAbility(hero, "meepo_poof")
  if not poof then return 0 end
  local level = Ability.GetLevel(poof)
  local damages = { 50, 80, 110, 140 }
  return damages[level] or 0
end

script.OnDraw = function()
  if hero == nil then
    hero = Heroes.GetLocal()
  end
  if not hero then return end
  name = NPC.GetUnitName(hero)
  if name ~= "npc_dota_hero_meepo" then return end
  if not PoofDamageCalculator:Get() then return end
  EnsureFont()

  local creeps = GetNearestCreeps()
  local poofs = CountAmountOfPoofs()
  local poofDmg = GetPoofDamage()
  local totalDmg = poofs * 2 * poofDmg

  for _, creep in pairs(creeps) do
    if not Entity.IsAlive(creep) then goto continue end

    local hp = Entity.GetHealth(creep)
    local pos = Entity.GetAbsOrigin(creep) + Vector(0, 0, 100) -- a bit above
    local screenPos, visible = Render.WorldToScreen(pos)
    if visible then
      local text, color
      if totalDmg >= hp then
        text = "KILL"
        color = Color(0, 255, 0, 255)
      else
        text = "HP left: " .. math.floor(hp - totalDmg)
        color = Color(255, 0, 0, 255)
      end
      Render.Text(font, 18, text, screenPos, color)
    end
    ::continue::
  end
end

script.OnGameEnd = function()
  hero = nil
  font = nil
end

return script
