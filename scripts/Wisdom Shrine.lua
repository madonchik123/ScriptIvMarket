local WisdomInfo = {}
local Toggle = Menu.Find("Info Screen", "Main", "Show Me More", "Main", "World Settings"):Switch(
  "Advanced Wisdom Capture Info", true, '\u{f06e}')
WisdomInfo.particle_indexes = {}
WisdomInfo.wisdom_shrines = {}
local font = nil
local font_bold = nil

-- Called when a shrine particle is created (ambient or active)
function WisdomInfo.OnParticleCreate(particle)
  if particle.fullName == "particles/base_static/experience_shrine_active.vpcf"
      or particle.fullName == "particles/base_static/experience_shrine_ambient_endcap.vpcf" then
    WisdomInfo.particle_indexes[particle.index] = { entity = particle.entity, max = 0, current = 0 }

    if WisdomInfo.wisdom_shrines[particle.entity] == nil then
      WisdomInfo.wisdom_shrines[particle.entity] = {}
    end
    WisdomInfo.wisdom_shrines[particle.entity].fx = particle.index
    WisdomInfo.wisdom_shrines[particle.entity].has = (particle.fullName == "particles/base_static/experience_shrine_active.vpcf")
  end
end

-- Called when a shrine particle is updated
function WisdomInfo.OnParticleUpdate(particle)
  if WisdomInfo.particle_indexes[particle.index] ~= nil then
    if particle.controlPoint == 0 then
      local entity = WisdomInfo.particle_indexes[particle.index].entity

      if WisdomInfo.wisdom_shrines[entity] == nil then
        WisdomInfo.wisdom_shrines[entity] = {}
      end
      WisdomInfo.wisdom_shrines[entity].origin = particle.position
    elseif particle.controlPoint == 1 then
      WisdomInfo.particle_indexes[particle.index].max = particle.position.x
      WisdomInfo.particle_indexes[particle.index].current = particle.position.y
    end
  end
end

-- Called when a shrine particle is destroyed
function WisdomInfo.OnParticleDestroy(particle)
  if WisdomInfo.particle_indexes[particle.index] ~= nil then
    local entity = WisdomInfo.particle_indexes[particle.index].entity
    -- Mark shrine as not being captured, but keep its position for drawing
    if WisdomInfo.wisdom_shrines[entity] then
      WisdomInfo.wisdom_shrines[entity].has = false
      WisdomInfo.wisdom_shrines[entity].fx = nil
    end
    WisdomInfo.particle_indexes[particle.index] = nil
  end
end

-- Draw above all shrines
function WisdomInfo:OnDraw()
  if not Toggle:Get() then return end
  if not font then
    font = Render.LoadFont("Tahoma", 0, 600)
    font_bold = Render.LoadFont("Tahoma", 0, 900)
  end

  local hero = Heroes.GetLocal()
  if not hero then return end

  local current_xp = Hero.GetCurrentXP(hero)
  local current_lvl = NPC.GetCurrentLevel(hero)

  -- XP table for each level (Dota 2 default, up to 30)
  local xp_table = {
    0,     -- Level 1
    240,   -- Level 2
    640,   -- Level 3
    1160,  -- Level 4
    1760,  -- Level 5
    2440,  -- Level 6
    3200,  -- Level 7
    4000,  -- Level 8
    4900,  -- Level 9
    5900,  -- Level 10
    7000,  -- Level 11
    8200,  -- Level 12
    9500,  -- Level 13
    10900, -- Level 14
    12400, -- Level 15
    14000, -- Level 16
    15700, -- Level 17
    17500, -- Level 18
    19400, -- Level 19
    21400, -- Level 20
    23600, -- Level 21
    26000, -- Level 22
    28600, -- Level 23
    31400, -- Level 24
    34400, -- Level 25
    38400, -- Level 26
    43400, -- Level 27
    49400, -- Level 28
    56400, -- Level 29
    63900  -- Level 30
  }

  -- Calculate wisdom rune XP (7 minutes = 420s, 280 XP per 7 min)
  local wisdom_xp = math.floor(GameRules.GetGameTime() / 420) * 280

  for entity, shrine in pairs(WisdomInfo.wisdom_shrines) do
    if shrine.origin then
      local x, y, visible = Renderer.WorldToScreen(shrine.origin)
      if x and y and visible then
        local shrine = WisdomInfo.wisdom_shrines[entity] or {}
        local box_width = 120
        local box_height = 54
        local rounding = 8

        local box_pos = Vector(x - box_width / 2, y - 54)
        local box_end = Vector(box_pos.x + box_width, box_pos.y + box_height)

        Render.Shadow(box_pos, box_end, Color(0, 0, 0, 180), 10, rounding)
        Render.FilledRect(box_pos, box_end, Color(24, 28, 40, 220), rounding)
        Render.OutlineGradient(
          box_pos, box_end,
          Color(80, 180, 255, 180), Color(80, 180, 255, 180),
          Color(0, 0, 0, 0), Color(0, 0, 0, 0),
          rounding, nil, 1.5
        )

        -- XP and level info
        local new_xp = current_xp + wisdom_xp
        local new_lvl = current_lvl
        for lvl = current_lvl + 1, #xp_table do
          if new_xp >= xp_table[lvl] then
            new_lvl = lvl
          else
            break
          end
        end

        local xp_text = string.format("+%d XP", wisdom_xp)
        local lvl_text = string.format("Level after: %d", new_lvl)
        local xp_size = Render.TextSize(font_bold, 16, xp_text)
        local lvl_size = Render.TextSize(font, 12, lvl_text)
        local xp_pos = Vector(box_pos.x + box_width / 2 - xp_size.x / 2, box_pos.y + 8)
        local lvl_pos = Vector(box_pos.x + box_width / 2 - lvl_size.x / 2, xp_pos.y + xp_size.y + 2)

        -- Progress bar if being captured
        local y_offset = 0
        if shrine.has and shrine.fx and WisdomInfo.particle_indexes[shrine.fx] and WisdomInfo.particle_indexes[shrine.fx].max > 0 then
          local particle = WisdomInfo.particle_indexes[shrine.fx]
          local progress = math.min(1, math.max(0, particle.current / particle.max))
          local bar_start = Vector(box_pos.x + 12, box_pos.y + 8)
          local bar_end = Vector(box_end.x - 12, bar_start.y + 12)
          Render.RoundedProgressRect(bar_start, bar_end, Color(255, 220, 60, 255), progress, 6)
          Render.Rect(bar_start, bar_end, Color(80, 80, 80, 180), 6, nil, 1.5)
          -- Progress text
          local progress_text = string.format("Capturing: %.0f%%", progress * 100)
          local progress_size = Render.TextSize(font, 12, progress_text)
          local progress_pos = Vector((bar_start.x + bar_end.x) / 2 - progress_size.x / 2, bar_start.y - 1)
          Render.Text(font, 12, progress_text, progress_pos, Color(255, 255, 120, 255))
          y_offset = 16
        end

        -- Shadow for text
        Render.Text(font_bold, 16, xp_text, xp_pos + Vector(1, 1) + Vector(0, y_offset), Color(0, 0, 0, 180))
        Render.Text(font, 12, lvl_text, lvl_pos + Vector(1, 1) + Vector(0, y_offset), Color(0, 0, 0, 180))
        -- Main text
        Render.Text(font_bold, 16, xp_text, xp_pos + Vector(0, y_offset), Color(80, 220, 255, 255))
        Render.Text(font, 12, lvl_text, lvl_pos + Vector(0, y_offset), Color(200, 255, 200, 255))
      end
    end
  end
end

return WisdomInfo
