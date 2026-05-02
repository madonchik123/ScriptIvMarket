---@diagnostic disable: undefined-global

local LASThitv6 = {}

local DEFAULT_RING_COLOR = Color(80, 255, 120, 220)
local RING_THICKNESS = 1.6
local GROUND_OFFSET = 3
local MOVE_ORDER_INTERVAL = 0.10
local MOVE_DELAY_TICKS = 2
local PREDICTION_MOVE_LOCK_EXTRA_TICKS = 1
local MOVE_ORDER_ID = "lasthitv6_move"
local ATTACK_ORDER_INTERVAL = 0.12
local ATTACK_DELAY_TICKS = 0
local ATTACK_ORDER_ID = "lasthitv6_attack"
local ATTACK_CONFIRM_TIMEOUT = 0.45
local ATTACK_CONFIRM_BUFFER_TICKS = 8
local ATTACK_RECOVERY_BUFFER_TICKS = 1
local ATTACK_ORDER_SERVER_DELAY_TICKS = 2.8
local ATTACK_DELAY_INITIAL_EXTRA_BIAS_TICKS = 0
local ATTACK_DELAY_MAX_BIAS_TICKS = 5
local ATTACK_DELAY_CALIBRATION_ALPHA = 0.35
local OUR_PENDING_HIT_BUFFER_TICKS = 6
local PREDICTION_EVENT_GRACE_TICKS = 6
local PREDICTION_CONFIRMED_EVENT_STALE_TICKS = 20
local PREDICTION_FUTURE_EVENT_EXPIRE_GRACE_TICKS = 3
local PREDICTION_HEALTH_VALIDATION_SLACK = 2
local PREDICTION_EARLY_SAFETY_TICKS = 0
local PREDICTION_ISSUE_LEAD_TICKS = 0.25
local PREDICT_ATTACK_EARLY_WINDOW = 2.00
local PREDICT_ATTACK_LATE_WINDOW = 2.00
local PREDICT_READY_MAX_LATE_TICKS = 4
local PENDING_DIRECT_OVERRIDE_TICKS = 2
local PREDICT_ATTACK_AFTER_TICKS = 1
local PREDICTION_FUTURE_ATTACK_COUNT = 3
local PREDICTION_FUTURE_ATTACK_HORIZON = 3.50
local DENY_BEFORE_LASTHIT_MARGIN_TICKS = 24
local MODE_ENEMY_CREEPS = "Enemy Creeps"
local MODE_FRIENDLY_CREEPS = "Friendly Creeps"
local BOX_PADDING = 8
local BOX_LINE_HEIGHT = 16
local BOX_FONT_SIZE = 14
local BOX_MAX_ROWS = 10
local MIN_CIRCLE_SEGMENTS = 96
local MAX_CIRCLE_SEGMENTS = 360

local BOX_BG_COLOR = Color(10, 18, 12, 185)
local BOX_BORDER_COLOR = Color(80, 255, 120, 220)
local BOX_TEXT_COLOR = Color(235, 255, 235, 255)
local BOX_ENEMY_COLOR = Color(255, 150, 150, 255)
local BOX_FRIENDLY_COLOR = Color(150, 210, 255, 255)
local BOX_KILLABLE_COLOR = Color(120, 255, 120, 255)
local TARGET_LINE_COLOR = Color(255, 230, 80, 235)
local MELEE_TARGET_LINE_COLOR = Color(255, 150, 80, 235)
local TARGET_LINE_SHADOW_COLOR = Color(0, 0, 0, 190)
local PROJECTILE_HIT_TEXT_COLOR = Color(140, 210, 255, 255)
local MELEE_HIT_TEXT_COLOR = Color(255, 170, 100, 255)
local TEXT_SHADOW_COLOR = Color(0, 0, 0, 255)

local tab = Menu.Create("General", "Main", "LastHitV6")
local main = tab:Create("Main")
local settings = main:Create("Settings")
local visuals = main:Create("Visual Settings")
local box_font = Render.LoadFont("Arial", 0, 500)

local ui = {
    enable = settings:Switch("Enable", false),
    work_key = settings:Bind("Work Key", Enum.ButtonCode.KEY_NONE),
    work_radius = settings:Slider("Work Radius", 100, 2000, 600, "%d"),
    tick_delay = settings:Switch("Tick Delay", true),
    visuals_enable = visuals:Switch("Enable", true),
    ring_color = visuals:ColorPicker("Ring Color", DEFAULT_RING_COLOR),
    debug = visuals:Switch("Debug", false),
}

if settings.MultiCombo then
    ui.creep_modes = settings:MultiCombo("Creeps", {
        MODE_ENEMY_CREEPS,
        MODE_FRIENDLY_CREEPS,
    }, {
        MODE_ENEMY_CREEPS,
    })
elseif settings.MultiSelect then
    ui.creep_modes = settings:MultiSelect("Creeps", {
        { MODE_ENEMY_CREEPS, "", true },
        { MODE_FRIENDLY_CREEPS, "", false },
    }, false)
    if ui.creep_modes and ui.creep_modes.DragAllowed then
        ui.creep_modes:DragAllowed(false)
    end
else
    ui.enemy_creeps = settings:Switch(MODE_ENEMY_CREEPS, true)
    ui.friendly_creeps = settings:Switch(MODE_FRIENDLY_CREEPS, false)
end

local next_move_schedule_time = 0
local pending_move_position = nil
local pending_move_execute_time = 0
local next_attack_schedule_time = 0
local next_attack_ready_time = 0
local pending_attack_target_index = nil
local pending_attack_execute_time = 0
local pending_attack_is_friendly = false
local pending_attack_prediction = false
local pending_attack_base_health = nil
local pending_attack_predicted_health = nil
local pending_attack_incoming_time = 0
local pending_attack_events = nil
local pending_attack_move_lock_logged = false
local attack_confirmation_until = 0
local attack_confirmation_target_index = nil
local active_projectiles = {}
local active_melee_swings = {}
local creep_attack_clocks = {}
local our_pending_hits = {}
local attack_delay_bias = nil
local last_attack_issue = nil
local missed_prediction_logs = {}
local debug_prediction = nil

local function update_menu_state()
    local enabled = ui.enable:Get()
    local visuals_enabled = enabled and ui.visuals_enable:Get()

    ui.work_key:Disabled(not enabled)
    ui.work_radius:Disabled(not enabled)
    if ui.creep_modes then
        ui.creep_modes:Disabled(not enabled)
    end
    if ui.enemy_creeps then
        ui.enemy_creeps:Disabled(not enabled)
    end
    if ui.friendly_creeps then
        ui.friendly_creeps:Disabled(not enabled)
    end
    ui.tick_delay:Disabled(not enabled)
    ui.visuals_enable:Disabled(not enabled)
    ui.ring_color:Disabled(not visuals_enabled)
    ui.debug:Disabled(not visuals_enabled)
end

local function is_enemy_creeps_enabled()
    if ui.creep_modes and ui.creep_modes.Get then
        return ui.creep_modes:Get(MODE_ENEMY_CREEPS) == true
    end

    return not ui.enemy_creeps or ui.enemy_creeps:Get() == true
end

local function is_friendly_creeps_enabled()
    if ui.creep_modes and ui.creep_modes.Get then
        return ui.creep_modes:Get(MODE_FRIENDLY_CREEPS) == true
    end

    return ui.friendly_creeps and ui.friendly_creeps:Get() == true
end

local function get_time()
    return GlobalVars.GetCurTime()
end

local function get_tick_interval()
    if GlobalVars.GetIntervalPerTick then
        local tick = tonumber(GlobalVars.GetIntervalPerTick() or 0) or 0
        if tick > 0 then
            return tick
        end
    end

    return 1 / 30
end

local function get_attack_delay_ticks()
    if ui.tick_delay:Get() then
        return ATTACK_DELAY_TICKS
    end

    return 0
end

local function get_attack_order_server_delay_ticks()
    if ui.tick_delay:Get() then
        return ATTACK_ORDER_SERVER_DELAY_TICKS
    end

    return 0
end

local function get_local_hero()
    local hero = Heroes.GetLocal()
    if not hero or Entity.IsAlive(hero) ~= true then
        return nil
    end

    return hero
end

local function get_entity_index(entity)
    return Entity.GetIndex(entity)
end

local function get_entity_by_index(index)
    if not index then
        return nil
    end

    local entity = Entity.Get(index)
    if entity and Entity.IsEntity(entity) == true then
        return entity
    end

    return nil
end

local function get_live_npc_by_index(index)
    local entity = get_entity_by_index(index)
    if entity and Entity.IsNPC(entity) == true and Entity.IsAlive(entity) == true then
        return entity
    end

    return nil
end

local function is_ready_to_draw()
    return ui.enable:Get()
        and ui.visuals_enable:Get()
        and ui.work_key:IsDown()
        and Engine.IsInGame()
end

local function make_readable_unit_name(unit_name)
    local name = tostring(unit_name or "Unknown")
    name = name:gsub("^npc_dota_", "")
    name = name:gsub("^creep_", "")
    name = name:gsub("^neutral_", "neutral ")
    name = name:gsub("goodguys_", "ally ")
    name = name:gsub("badguys_", "enemy ")
    name = name:gsub("_", " ")
    return name
end

local function get_creep_name(creep)
    return make_readable_unit_name(NPC.GetUnitName(creep))
end

local function distance_2d(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt((dx * dx) + (dy * dy))
end

local function ceil_to_tick(time)
    local tick = get_tick_interval()
    return math.ceil((time / tick) - 0.000001) * tick
end

local function get_min_attack_damage_vs_target(attacker, target)
    local armor_multiplier = tonumber(NPC.GetArmorDamageMultiplier(target) or 1) or 1
    local true_min_damage = tonumber(NPC.GetTrueDamage(attacker) or 0) or 0
    return math.floor((true_min_damage * armor_multiplier) + 0.0001)
end

local function is_deniable_health(health, max_health)
    max_health = tonumber(max_health or 0) or 0
    health = tonumber(health or 0) or 0
    return max_health > 0 and health > 0 and health <= (max_health * 0.5)
end

local function is_actionable_health(creep, health)
    health = tonumber(health or 0) or 0
    if health <= 0 or health > creep.min_damage then
        return false
    end

    if creep.is_friendly then
        return is_deniable_health(health, creep.max_health)
    end

    return true
end

local function is_target_actionable_after_hits(creep, health_after_hits)
    return is_actionable_health(creep, health_after_hits)
end

local function get_unit_hit_delay(attacker, target)
    local delay = tonumber(NPC.GetAttackAnimPoint(attacker) or 0) or 0
    local projectile_speed = tonumber(NPC.GetAttackProjectileSpeed(attacker) or 0) or 0

    if projectile_speed > 0 and NPC.IsRanged(attacker) == true then
        delay = delay + (distance_2d(Entity.GetAbsOrigin(attacker), Entity.GetAbsOrigin(target)) / projectile_speed)
    end

    return delay
end

local function get_attack_period(npc)
    if not NPC.GetSecondsPerAttack then
        return nil
    end

    local seconds_per_attack = tonumber(NPC.GetSecondsPerAttack(npc, false) or 0) or 0
    if seconds_per_attack <= 0 then
        return nil
    end

    return seconds_per_attack
end

local function get_hero_face_time(hero, target)
    if NPC.GetTimeToFace then
        local face_time = tonumber(NPC.GetTimeToFace(hero, target) or 0) or 0
        if face_time > 0 and face_time < 0.75 then
            return face_time
        end
    end

    return 0
end

local function get_hero_hit_delay(hero, target)
    return get_unit_hit_delay(hero, target) + get_hero_face_time(hero, target)
end

local function get_raw_prediction_attack_delay(hero, target)
    return get_hero_hit_delay(hero, target) + (get_tick_interval() * get_attack_order_server_delay_ticks())
end

local function get_default_attack_delay_bias()
    if ui.tick_delay:Get() ~= true then
        return 0
    end

    return get_tick_interval() * (get_attack_order_server_delay_ticks() + ATTACK_DELAY_INITIAL_EXTRA_BIAS_TICKS)
end

local function get_attack_delay_bias()
    if ui.tick_delay:Get() ~= true then
        return 0
    end

    local max_bias = get_tick_interval() * ATTACK_DELAY_MAX_BIAS_TICKS
    local bias = attack_delay_bias or get_default_attack_delay_bias()
    if bias < 0 then
        return 0
    end
    if bias > max_bias then
        return max_bias
    end

    return bias
end

local function get_prediction_early_safety()
    if ui.tick_delay:Get() ~= true then
        return 0
    end

    return get_tick_interval() * PREDICTION_EARLY_SAFETY_TICKS
end

local function get_prediction_issue_lead()
    if ui.tick_delay:Get() ~= true then
        return 0
    end

    return get_tick_interval() * PREDICTION_ISSUE_LEAD_TICKS
end

local function get_prediction_attack_delay(hero, target)
    if ui.tick_delay:Get() ~= true then
        return get_hero_hit_delay(hero, target)
    end

    return math.max(0, get_raw_prediction_attack_delay(hero, target) - get_attack_delay_bias() + get_prediction_early_safety() + get_prediction_issue_lead())
end

local function get_hero_attack_launch_delay(hero, target)
    return (tonumber(NPC.GetAttackAnimPoint(hero) or 0) or 0) + get_hero_face_time(hero, target)
end

local function get_attack_confirmation_timeout(hero, target)
    local server_delay = get_tick_interval() * get_attack_order_server_delay_ticks()
    local buffer = get_tick_interval() * ATTACK_CONFIRM_BUFFER_TICKS
    return math.max(ATTACK_CONFIRM_TIMEOUT, server_delay + get_hero_attack_launch_delay(hero, target) + buffer)
end

local function get_next_attack_ready_time(hero, target, launch_time)
    local attack_period = get_attack_period(hero)
    if not attack_period then
        return launch_time
    end

    local attack_start = launch_time - get_hero_attack_launch_delay(hero, target)
    return attack_start + attack_period + (get_tick_interval() * ATTACK_RECOVERY_BUFFER_TICKS)
end

local function get_predict_ready_late_limit()
    return get_tick_interval() * PREDICT_READY_MAX_LATE_TICKS
end

local function get_pending_direct_override_window()
    return get_tick_interval() * PENDING_DIRECT_OVERRIDE_TICKS
end

local function get_prediction_log_key(prediction)
    local tick = get_tick_interval()
    return ("%d:%d:%d"):format(
        prediction.creep.index,
        math.floor((prediction.incoming_time / tick) + 0.5),
        #(prediction.events or {})
    )
end

local function should_log_missed_prediction(prediction, now)
    local key = get_prediction_log_key(prediction)
    local muted_until = missed_prediction_logs[key]
    if muted_until and muted_until > now then
        return false
    end

    missed_prediction_logs[key] = now + 0.25
    return true
end

local function get_time_tick(time)
    local tick = get_tick_interval()
    return math.floor((time / tick) + 0.5)
end

local function debug_log(message)
    if ui.debug:Get() then
        local now = get_time()
        print(("[LastHitV6] t=%.4f tick=%d %s"):format(now, get_time_tick(now), message))
    end
end

local function get_debug_target_text(hero, target)
    local health = math.floor((tonumber(Entity.GetHealth(target) or 0) or 0) + 0.5)
    local min_damage = get_min_attack_damage_vs_target(hero, target)
    return ("%s#%d hp=%d min=%d"):format(
        get_creep_name(target),
        get_entity_index(target),
        health,
        min_damage
    )
end

local function get_creeps_in_radius(hero, radius)
    local creeps = {}
    local units = Entity.GetUnitsInRadius(hero, radius, Enum.TeamType.TEAM_BOTH, false, true)

    for i = 1, #units do
        local unit = units[i]
        if NPC.IsCreep(unit) == true and Entity.IsAlive(unit) == true then
            local health = tonumber(Entity.GetHealth(unit) or 0) or 0
            local max_health = tonumber(Entity.GetMaxHealth(unit) or 0) or 0
            local min_damage = get_min_attack_damage_vs_target(hero, unit)
            local is_friendly = Entity.IsSameTeam(hero, unit) == true
            local is_last_hittable = not is_friendly and health > 0 and health <= min_damage
            local is_deniable = is_friendly and health <= min_damage and is_deniable_health(health, max_health)

            creeps[#creeps + 1] = {
                npc = unit,
                index = get_entity_index(unit),
                name = get_creep_name(unit),
                health = health,
                max_health = max_health,
                is_friendly = is_friendly,
                is_ranged = NPC.IsRanged(unit) == true,
                min_damage = min_damage,
                is_killable = is_last_hittable or is_deniable,
                is_last_hittable = is_last_hittable,
                is_deniable = is_deniable,
            }
        end
    end

    table.sort(creeps, function(a, b)
        if a.is_friendly ~= b.is_friendly then
            return not a.is_friendly
        end
        if a.is_killable ~= b.is_killable then
            return a.is_killable
        end
        return a.health < b.health
    end)

    return creeps
end

local function get_ring_color()
    return ui.ring_color:Get() or DEFAULT_RING_COLOR
end

local function get_ground_point(x, y, fallback_z)
    local z = tonumber(World.GetGroundZ(x, y)) or fallback_z
    return Vector(x, y, z + GROUND_OFFSET)
end

local function get_circle_segments(radius)
    local segments = math.floor(radius * 0.65)
    if segments < MIN_CIRCLE_SEGMENTS then
        return MIN_CIRCLE_SEGMENTS
    end
    if segments > MAX_CIRCLE_SEGMENTS then
        return MAX_CIRCLE_SEGMENTS
    end
    return segments
end

local function draw_radius_circle(center, radius, color)
    local segments = get_circle_segments(radius)
    local first_screen, first_visible = nil, false
    local previous_screen, previous_visible = nil, false

    for i = 0, segments - 1 do
        local angle = (i / segments) * 2 * math.pi
        local point = get_ground_point(
            center.x + radius * math.cos(angle),
            center.y + radius * math.sin(angle),
            center.z
        )

        local screen, visible = Render.WorldToScreen(point)
        if i == 0 then
            first_screen = screen
            first_visible = visible
        elseif previous_visible and visible then
            Render.Line(previous_screen, screen, color, RING_THICKNESS)
        end

        previous_screen = screen
        previous_visible = visible
    end

    if previous_visible and first_visible and first_screen then
        Render.Line(previous_screen, first_screen, color, RING_THICKNESS)
    end
end

local function get_box_position(hero_screen, width, height)
    local x = hero_screen.x + 32
    local y = hero_screen.y - (height * 0.5)
    local screen_size = Render.ScreenSize()

    if x + width > screen_size.x then
        x = hero_screen.x - width - 32
    end
    if y < 8 then
        y = 8
    elseif y + height > screen_size.y - 8 then
        y = screen_size.y - height - 8
    end

    return Vec2(x, y)
end

local function get_creep_line(creep)
    local side = creep.is_friendly and "F" or "E"
    local kind = creep.is_ranged and "R" or "M"
    return ("[%s/%s] %s  %d/%d  min %d"):format(side, kind, creep.name, creep.health, creep.max_health, creep.min_damage)
end

local function draw_creep_box(hero_position, creeps)
    if #creeps == 0 then
        return
    end

    local hero_screen, visible = Render.WorldToScreen(hero_position)
    if not visible then
        return
    end

    local shown_rows = math.min(#creeps, BOX_MAX_ROWS)
    local header = ("Creeps in circle: %d"):format(#creeps)
    local width = Render.TextSize(box_font, BOX_FONT_SIZE, header).x

    for i = 1, shown_rows do
        local row_width = Render.TextSize(box_font, BOX_FONT_SIZE, get_creep_line(creeps[i])).x
        if row_width > width then
            width = row_width
        end
    end

    if #creeps > shown_rows then
        local more_width = Render.TextSize(box_font, BOX_FONT_SIZE, "...").x
        if more_width > width then
            width = more_width
        end
    end

    local extra_row = #creeps > shown_rows and 1 or 0
    local box_width = width + (BOX_PADDING * 2)
    local box_height = ((shown_rows + 1 + extra_row) * BOX_LINE_HEIGHT) + (BOX_PADDING * 2)
    local box_pos = get_box_position(hero_screen, box_width, box_height)

    Render.FilledRect(box_pos, box_pos + Vec2(box_width, box_height), BOX_BG_COLOR, 6)
    Render.Rect(box_pos, box_pos + Vec2(box_width, box_height), BOX_BORDER_COLOR, 6, nil, 1.5)
    Render.Text(box_font, BOX_FONT_SIZE, header, box_pos + Vec2(BOX_PADDING, BOX_PADDING), BOX_TEXT_COLOR)

    for i = 1, shown_rows do
        local creep = creeps[i]
        local color = creep.is_killable and BOX_KILLABLE_COLOR
            or (creep.is_friendly and BOX_FRIENDLY_COLOR or BOX_ENEMY_COLOR)
        local y = BOX_PADDING + (i * BOX_LINE_HEIGHT)
        Render.Text(box_font, BOX_FONT_SIZE, get_creep_line(creep), box_pos + Vec2(BOX_PADDING, y), color)
    end

    if #creeps > shown_rows then
        local y = BOX_PADDING + ((shown_rows + 1) * BOX_LINE_HEIGHT)
        Render.Text(box_font, BOX_FONT_SIZE, ("+%d more"):format(#creeps - shown_rows), box_pos + Vec2(BOX_PADDING, y), BOX_TEXT_COLOR)
    end
end

local function get_facing_target(creep)
    local extra_distance = creep.is_ranged and 350 or 120
    local facing_angle = creep.is_ranged and 35 or 25
    local search_distance = NPC.GetAttackRange(creep.npc) + NPC.GetAttackRangeBonus(creep.npc) + extra_distance
    return NPC.FindFacingNPC(creep.npc, nil, Enum.TeamType.TEAM_ENEMY, facing_angle, search_distance)
end

local function draw_facing_target_line(creep)
    local target = get_facing_target(creep)
    if not target then
        return
    end

    local creep_pos = Entity.GetAbsOrigin(creep.npc)
    local target_pos = Entity.GetAbsOrigin(target)
    local start_screen, start_visible = Render.WorldToScreen(get_ground_point(creep_pos.x, creep_pos.y, creep_pos.z))
    local end_screen, end_visible = Render.WorldToScreen(get_ground_point(target_pos.x, target_pos.y, target_pos.z))
    if not start_visible or not end_visible then
        return
    end

    local color = creep.is_ranged and TARGET_LINE_COLOR or MELEE_TARGET_LINE_COLOR
    Render.Line(start_screen, end_screen, TARGET_LINE_SHADOW_COLOR, 3.5)
    Render.Line(start_screen, end_screen, color, 1.7)
end

local function draw_facing_target_lines(creeps)
    for i = 1, #creeps do
        draw_facing_target_line(creeps[i])
    end
end

local function draw_text_at_world(position, text, color)
    local screen, visible = Render.WorldToScreen(position)
    if not visible then
        return
    end

    local size = Render.TextSize(box_font, BOX_FONT_SIZE, text)
    local text_pos = Vec2(screen.x - (size.x * 0.5), screen.y - size.y)
    Render.Text(box_font, BOX_FONT_SIZE, text, text_pos + Vec2(1, 1), TEXT_SHADOW_COLOR)
    Render.Text(box_font, BOX_FONT_SIZE, text, text_pos, color)
end

local function draw_hit_timer(target_index, label, seconds_left, color, z_offset)
    local target = get_live_npc_by_index(target_index)
    if not target then
        return false
    end

    local target_pos = Entity.GetAbsOrigin(target)
    local text_pos = Vector(target_pos.x, target_pos.y, target_pos.z + NPC.GetHealthBarOffset(target, true) + z_offset)
    draw_text_at_world(text_pos, ("%s %.2fs"):format(label, seconds_left), color)
    return true
end

local function set_melee_hit_timer(source, target, hit_time)
    active_melee_swings[get_entity_index(source)] = {
        source_index = get_entity_index(source),
        target_index = get_entity_index(target),
        hit_time = hit_time,
        damage = get_min_attack_damage_vs_target(source, target),
    }
end

local function remember_next_creep_attack(source, target, attack_start)
    local attack_period = get_attack_period(source)
    if not attack_period then
        creep_attack_clocks[get_entity_index(source)] = nil
        return
    end

    creep_attack_clocks[get_entity_index(source)] = {
        source_index = get_entity_index(source),
        target_index = get_entity_index(target),
        next_attack_start = ceil_to_tick(attack_start + attack_period),
        attack_period = attack_period,
        is_ranged = NPC.IsRanged(source) == true,
    }
end

local function set_projectile_hit_timer(source, target, impact_time)
    active_projectiles[get_entity_index(source)] = {
        source_index = get_entity_index(source),
        target_index = get_entity_index(target),
        impact_time = impact_time,
        damage = get_min_attack_damage_vs_target(source, target),
    }
end

local function draw_melee_hit_timer(creep)
    if creep.is_ranged then
        return
    end

    local source_index = creep.index
    local swing = active_melee_swings[source_index]
    if not swing then
        return
    end

    local seconds_left = swing.hit_time - get_time()
    if seconds_left <= 0 then
        active_melee_swings[source_index] = nil
        return
    end

    if not draw_hit_timer(swing.target_index, "Melee Hit In", seconds_left, MELEE_HIT_TEXT_COLOR, 66) then
        active_melee_swings[source_index] = nil
    end
end

local function draw_projectile_hit_timer(creep)
    if not creep.is_ranged then
        return
    end

    local source_index = creep.index
    local projectile = active_projectiles[source_index]
    if not projectile then
        return
    end

    local seconds_left = projectile.impact_time - get_time()
    if seconds_left <= 0 then
        active_projectiles[source_index] = nil
        return
    end

    if not draw_hit_timer(projectile.target_index, "Projectile Hit In", seconds_left, PROJECTILE_HIT_TEXT_COLOR, 48) then
        active_projectiles[source_index] = nil
    end
end

local function draw_attack_hit_timers(creeps)
    for i = 1, #creeps do
        draw_melee_hit_timer(creeps[i])
        draw_projectile_hit_timer(creeps[i])
    end
end

local function draw_prediction_debug()
    if not debug_prediction or debug_prediction.expires_at <= get_time() then
        debug_prediction = nil
        return
    end

    local target = get_live_npc_by_index(debug_prediction.target_index)
    if not target then
        debug_prediction = nil
        return
    end

    local target_pos = Entity.GetAbsOrigin(target)
    local text_pos = Vector(target_pos.x, target_pos.y, target_pos.z + NPC.GetHealthBarOffset(target, true) + 84)
    draw_text_at_world(text_pos, debug_prediction.text, BOX_TEXT_COLOR)
end

local function clear_pending_move()
    next_move_schedule_time = 0
    pending_move_position = nil
    pending_move_execute_time = 0
end

local function clear_pending_attack()
    next_attack_schedule_time = 0
    next_attack_ready_time = 0
    pending_attack_target_index = nil
    pending_attack_execute_time = 0
    pending_attack_is_friendly = false
    pending_attack_prediction = false
    pending_attack_base_health = nil
    pending_attack_predicted_health = nil
    pending_attack_incoming_time = 0
    pending_attack_events = nil
    pending_attack_move_lock_logged = false
    attack_confirmation_until = 0
    attack_confirmation_target_index = nil
end

local function clear_pending_orders()
    clear_pending_move()
    clear_pending_attack()
end

local function clear_attack_hit_timers()
    active_projectiles = {}
    active_melee_swings = {}
    creep_attack_clocks = {}
    our_pending_hits = {}
    attack_delay_bias = nil
    last_attack_issue = nil
    missed_prediction_logs = {}
end

local function schedule_move_to_cursor(now)
    pending_move_position = Input.GetWorldCursorPos()
    pending_move_execute_time = now + (get_tick_interval() * MOVE_DELAY_TICKS)
    next_move_schedule_time = now + MOVE_ORDER_INTERVAL
end

local function execute_move_to_position(player, hero, position)
    Player.PrepareUnitOrders(
        player,
        Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        nil,
        position,
        nil,
        Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
        hero,
        false,
        false,
        false,
        true,
        MOVE_ORDER_ID,
        false
    )
end

local function run_move_orders(player, hero, now)
    if pending_move_position and now >= pending_move_execute_time then
        execute_move_to_position(player, hero, pending_move_position)
        pending_move_position = nil
        pending_move_execute_time = 0
    end

    if not pending_move_position and now >= next_move_schedule_time then
        schedule_move_to_cursor(now)
    end
end

local function get_live_creep_by_index(hero, index, target_is_friendly)
    local entity = get_entity_by_index(index)
    if entity
        and Entity.IsNPC(entity) == true
        and NPC.IsCreep(entity) == true
        and Entity.IsAlive(entity) == true
    then
        local is_friendly = Entity.IsSameTeam(hero, entity) == true
        if target_is_friendly == nil or is_friendly == target_is_friendly then
            return entity
        end
    end

    return nil
end

local function get_live_enemy_creep_by_index(hero, index)
    return get_live_creep_by_index(hero, index, false)
end

local function get_live_friendly_creep_by_index(hero, index)
    return get_live_creep_by_index(hero, index, true)
end

local function is_valid_creep_target(hero, target, target_is_friendly)
    if target
        and Entity.IsNPC(target) == true
        and NPC.IsCreep(target) == true
        and Entity.IsAlive(target) == true
    then
        local is_friendly = Entity.IsSameTeam(hero, target) == true
        return target_is_friendly == nil or is_friendly == target_is_friendly
    end

    return false
end

local function is_valid_enemy_creep_target(hero, target)
    return is_valid_creep_target(hero, target, false)
end

local function is_source_for_target_side(hero, source, target_is_friendly)
    return source and (Entity.IsSameTeam(hero, source) == true) ~= target_is_friendly
end

local function is_target_ready_for_action(hero, target, target_is_friendly)
    local health = tonumber(Entity.GetHealth(target) or 0) or 0
    local min_damage = get_min_attack_damage_vs_target(hero, target)
    if health <= 0 or health > min_damage then
        return false
    end

    if target_is_friendly then
        local max_health = tonumber(Entity.GetMaxHealth(target) or 0) or 0
        return is_deniable_health(health, max_health)
    end

    return true
end

local function remember_our_pending_hit(target, hit_time)
    local target_index = get_entity_index(target)
    our_pending_hits[target_index] = ceil_to_tick(hit_time) + (get_tick_interval() * OUR_PENDING_HIT_BUFFER_TICKS)
end

local function remember_our_melee_pending_hit(hero, target, now)
    local hit_time = now
        + (get_tick_interval() * get_attack_order_server_delay_ticks())
        + get_hero_hit_delay(hero, target)

    remember_our_pending_hit(target, hit_time)
end

local function clear_expired_our_pending_hits(now)
    for target_index, expires_at in pairs(our_pending_hits) do
        local target = get_entity_by_index(target_index)
        if expires_at <= now or not target or Entity.IsAlive(target) ~= true then
            our_pending_hits[target_index] = nil
        end
    end
end

local function is_our_hit_pending(target, now)
    local target_index = get_entity_index(target)
    local expires_at = our_pending_hits[target_index]
    if not expires_at then
        return false
    end

    if expires_at <= now or Entity.IsAlive(target) ~= true then
        our_pending_hits[target_index] = nil
        return false
    end

    return true
end

local function find_killable_creep(creeps, now, target_is_friendly)
    for i = 1, #creeps do
        local creep = creeps[i]
        if creep.is_friendly == target_is_friendly
            and creep.is_killable
            and not is_our_hit_pending(creep.npc, now)
        then
            return creep
        end
    end

    return nil
end

local function get_prediction_move_lock_window()
    return get_tick_interval() * (MOVE_DELAY_TICKS + PREDICTION_MOVE_LOCK_EXTRA_TICKS)
end

local function can_spare_attack_before_pending(hero, target, now)
    if not pending_attack_target_index or not pending_attack_prediction or pending_attack_is_friendly then
        return false
    end

    local launch_time = now + get_hero_attack_launch_delay(hero, target)
    local ready_time = get_next_attack_ready_time(hero, target, launch_time)
    local required_margin = get_tick_interval() * DENY_BEFORE_LASTHIT_MARGIN_TICKS
    return pending_attack_execute_time - ready_time > required_margin
end

local function is_prediction_move_lock_active(now)
    return now >= pending_attack_execute_time - get_prediction_move_lock_window()
end

local function schedule_attack_target(creep, now)
    pending_attack_target_index = creep.index
    pending_attack_execute_time = now + (get_tick_interval() * get_attack_delay_ticks())
    pending_attack_is_friendly = creep.is_friendly
    pending_attack_prediction = false
    pending_attack_base_health = nil
    pending_attack_predicted_health = nil
    pending_attack_incoming_time = 0
    pending_attack_events = nil
    pending_attack_move_lock_logged = false
    next_attack_schedule_time = now + ATTACK_ORDER_INTERVAL
    clear_pending_move()
    debug_log(("SCHEDULE_DIRECT target=%s#%d hp=%d min=%d execute_in=%.4f delay_ticks=%.2f tick_delay=%s"):format(
        creep.name,
        creep.index,
        math.floor(creep.health + 0.5),
        creep.min_damage,
        pending_attack_execute_time - now,
        get_attack_delay_ticks(),
        tostring(ui.tick_delay:Get())
    ))
end

local function schedule_attack_at(prediction, now)
    local creep = prediction.creep
    pending_attack_target_index = creep.index
    pending_attack_execute_time = math.max(now, prediction.execute_time)
    pending_attack_is_friendly = creep.is_friendly
    pending_attack_prediction = true
    pending_attack_base_health = prediction.base_health
    pending_attack_predicted_health = prediction.health_after_hits
    pending_attack_incoming_time = prediction.incoming_time
    pending_attack_events = prediction.events
    pending_attack_move_lock_logged = false
    next_attack_schedule_time = now + ATTACK_ORDER_INTERVAL
    if pending_attack_execute_time - now <= get_prediction_move_lock_window() then
        clear_pending_move()
    end
    debug_log(("SCHEDULE_PREDICT target=%s#%d hp=%d predicted_hp=%d incoming_in=%.4f execute_in=%.4f predict_delay=%.4f raw_delay=%.4f bias=%.4f early=%.4f lead=%.4f after_ticks=%.2f server_ticks=%.2f events=%d tick_delay=%s"):format(
        creep.name,
        creep.index,
        math.floor(creep.health + 0.5),
        math.floor(prediction.health_after_hits + 0.5),
        prediction.incoming_time - now,
        pending_attack_execute_time - now,
        prediction.attack_delay or 0,
        prediction.raw_attack_delay or 0,
        prediction.attack_delay_bias or 0,
        prediction.early_safety or 0,
        get_prediction_issue_lead(),
        PREDICT_ATTACK_AFTER_TICKS,
        get_attack_order_server_delay_ticks(),
        #(prediction.events or {}),
        tostring(ui.tick_delay:Get())
    ))
end

local function execute_attack_target(player, hero, target)
    Player.PrepareUnitOrders(
        player,
        Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET,
        target,
        Entity.GetAbsOrigin(target),
        nil,
        Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
        hero,
        false,
        false,
        false,
        true,
        ATTACK_ORDER_ID,
        false
    )
end

local will_target_die_before_our_hit
local has_incoming_hit_before_our_hit

local function issue_attack_target_once(player, hero, target, now, target_is_friendly, allow_incoming_before_our_hit)
    if target_is_friendly == nil and target then
        target_is_friendly = Entity.IsSameTeam(hero, target) == true
    end

    if not is_valid_creep_target(hero, target, target_is_friendly) then
        debug_log("SKIP_ATTACK invalid_or_dead_target")
        return false
    end

    if is_our_hit_pending(target, now) then
        local pending_left = math.max(0, (our_pending_hits[get_entity_index(target)] or now) - now)
        debug_log(("SKIP_ATTACK our_hit_pending target=%s pending_left=%.4f"):format(
            get_debug_target_text(hero, target),
            pending_left
        ))
        return false
    end

    if attack_confirmation_until > now then
        debug_log(("SKIP_ATTACK waiting_confirmation target=%s confirmation_left=%.4f"):format(
            get_debug_target_text(hero, target),
            attack_confirmation_until - now
        ))
        return false
    end

    if now < next_attack_ready_time then
        debug_log(("SKIP_ATTACK attack_recovering target=%s ready_in=%.4f"):format(
            get_debug_target_text(hero, target),
            next_attack_ready_time - now
        ))
        return false
    end

    if target_is_friendly and allow_incoming_before_our_hit ~= true then
        local has_earlier_hit, hit_in = has_incoming_hit_before_our_hit(hero, target, now, target_is_friendly)
        if has_earlier_hit then
            debug_log(("SKIP_ATTACK deny_timing_missed target=%s incoming_in=%.4f"):format(
                get_debug_target_text(hero, target),
                hit_in
            ))
            return false
        end
    end

    local will_die_before_hit, lethal_in = will_target_die_before_our_hit(hero, target, now, target_is_friendly)
    if will_die_before_hit then
        debug_log(("SKIP_ATTACK target_will_die_before_our_hit target=%s lethal_in=%.4f"):format(
            get_debug_target_text(hero, target),
            lethal_in
        ))
        return false
    end

    clear_pending_move()
    local confirmation_timeout = get_attack_confirmation_timeout(hero, target)
    local raw_attack_delay = get_raw_prediction_attack_delay(hero, target)
    local prediction_attack_delay = get_prediction_attack_delay(hero, target)
    debug_log(("ISSUE_ATTACK target=%s hero_hit_delay=%.4f predict_delay=%.4f raw_delay=%.4f bias=%.4f early=%.4f lead=%.4f launch_delay=%.4f confirm_timeout=%.4f server_ticks=%.2f attack_delay_ticks=%.2f tick_delay=%s"):format(
        get_debug_target_text(hero, target),
        get_hero_hit_delay(hero, target),
        prediction_attack_delay,
        raw_attack_delay,
        get_attack_delay_bias(),
        get_prediction_early_safety(),
        get_prediction_issue_lead(),
        get_hero_attack_launch_delay(hero, target),
        confirmation_timeout,
        get_attack_order_server_delay_ticks(),
        get_attack_delay_ticks(),
        tostring(ui.tick_delay:Get())
    ))
    execute_attack_target(player, hero, target)
    last_attack_issue = {
        target_index = get_entity_index(target),
        issue_time = now,
        raw_attack_delay = raw_attack_delay,
        prediction_attack_delay = prediction_attack_delay,
    }
    if NPC.IsRanged(hero) ~= true then
        remember_our_melee_pending_hit(hero, target, now)
    end
    attack_confirmation_target_index = get_entity_index(target)
    attack_confirmation_until = now + confirmation_timeout
    next_attack_schedule_time = attack_confirmation_until
    next_move_schedule_time = now
    pending_attack_target_index = nil
    pending_attack_execute_time = 0
    pending_attack_is_friendly = false
    pending_attack_prediction = false
    pending_attack_base_health = nil
    pending_attack_predicted_health = nil
    pending_attack_incoming_time = 0
    pending_attack_events = nil
    pending_attack_move_lock_logged = false
    return true
end

local function get_projectile_impact_time(source, target, now)
    local projectile_speed = tonumber(NPC.GetAttackProjectileSpeed(source) or 0) or 0
    if projectile_speed <= 0 then
        return nil
    end

    return now + (distance_2d(Entity.GetAbsOrigin(source), Entity.GetAbsOrigin(target)) / projectile_speed)
end

local function get_future_attack_hit_time(source, target, attack_start)
    local hit_time = attack_start + (tonumber(NPC.GetAttackAnimPoint(source) or 0) or 0)

    if NPC.IsRanged(source) == true then
        local projectile_speed = tonumber(NPC.GetAttackProjectileSpeed(source) or 0) or 0
        if projectile_speed <= 0 then
            return nil
        end

        hit_time = hit_time + (distance_2d(Entity.GetAbsOrigin(source), Entity.GetAbsOrigin(target)) / projectile_speed)
    end

    return ceil_to_tick(hit_time)
end

local function find_creep_by_index(creeps, index)
    for i = 1, #creeps do
        if creeps[i].index == index then
            return creeps[i]
        end
    end

    return nil
end

local function get_facing_target_for_unit(unit)
    local is_ranged = NPC.IsRanged(unit) == true
    local extra_distance = is_ranged and 350 or 120
    local facing_angle = is_ranged and 35 or 25
    local search_distance = NPC.GetAttackRange(unit) + NPC.GetAttackRangeBonus(unit) + extra_distance
    return NPC.FindFacingNPC(unit, nil, Enum.TeamType.TEAM_ENEMY, facing_angle, search_distance)
end

local function is_facing_target(unit, target)
    local facing_target = get_facing_target_for_unit(unit)
    return facing_target and get_entity_index(facing_target) == get_entity_index(target)
end

local function get_incoming_hit_events(hero, now, target_is_friendly)
    local events = {}

    for source_index, projectile in pairs(active_projectiles) do
        local source = get_live_npc_by_index(projectile.source_index)
        local target = get_live_creep_by_index(hero, projectile.target_index, target_is_friendly)

        if not source or projectile.impact_time <= now then
            active_projectiles[source_index] = nil
        elseif target and is_source_for_target_side(hero, source, target_is_friendly) then
            events[#events + 1] = {
                kind = "projectile",
                source_index = projectile.source_index,
                target_index = projectile.target_index,
                hit_time = projectile.impact_time,
                damage = tonumber(projectile.damage or 0) or 0,
            }
        end
    end

    for source_index, swing in pairs(active_melee_swings) do
        local source = get_live_npc_by_index(swing.source_index)
        local target = get_live_creep_by_index(hero, swing.target_index, target_is_friendly)

        if not source or swing.hit_time <= now then
            active_melee_swings[source_index] = nil
        elseif target and is_source_for_target_side(hero, source, target_is_friendly) then
            events[#events + 1] = {
                kind = "melee",
                source_index = swing.source_index,
                target_index = swing.target_index,
                hit_time = swing.hit_time,
                damage = tonumber(swing.damage or 0) or 0,
            }
        end
    end

    for source_index, clock in pairs(creep_attack_clocks) do
        local source = get_live_npc_by_index(clock.source_index)
        local target = get_live_creep_by_index(hero, clock.target_index, target_is_friendly)

        if not source then
            creep_attack_clocks[source_index] = nil
        elseif target and is_source_for_target_side(hero, source, target_is_friendly) and is_facing_target(source, target) then
            local attack_period = tonumber(clock.attack_period or get_attack_period(source) or 0) or 0
            if attack_period <= 0 then
                creep_attack_clocks[source_index] = nil
            else
                while clock.next_attack_start + attack_period < now do
                    clock.next_attack_start = ceil_to_tick(clock.next_attack_start + attack_period)
                end

                for attack_number = 1, PREDICTION_FUTURE_ATTACK_COUNT do
                    local attack_start = clock.next_attack_start + (attack_period * (attack_number - 1))
                    if attack_start - now > PREDICTION_FUTURE_ATTACK_HORIZON then
                        break
                    end

                    local hit_time = get_future_attack_hit_time(source, target, attack_start)
                    if hit_time and hit_time > now and hit_time - now <= PREDICTION_FUTURE_ATTACK_HORIZON then
                        events[#events + 1] = {
                            kind = clock.is_ranged and "future_projectile" or "future_melee",
                            source_index = clock.source_index,
                            target_index = clock.target_index,
                            attack_start = attack_start,
                            hit_time = hit_time,
                            damage = get_min_attack_damage_vs_target(source, target),
                        }
                    end
                end
            end
        elseif target and is_source_for_target_side(hero, source, target_is_friendly) then
            creep_attack_clocks[source_index] = nil
        end
    end

    table.sort(events, function(a, b)
        return a.hit_time < b.hit_time
    end)

    return events
end

local function get_target_hit_groups(events, target_index)
    local tick = get_tick_interval()
    local groups = {}
    local groups_by_time = {}

    for i = 1, #events do
        local event = events[i]
        if event.target_index == target_index then
            local key = math.floor((event.hit_time / tick) + 0.5)
            local group = groups_by_time[key]
            if not group then
                group = {
                    hit_time = event.hit_time,
                    damage = 0,
                    events = {},
                }
                groups_by_time[key] = group
                groups[#groups + 1] = group
            end

            if event.hit_time > group.hit_time then
                group.hit_time = event.hit_time
            end
            group.damage = group.damage + event.damage
            group.events[#group.events + 1] = event
        end
    end

    table.sort(groups, function(a, b)
        return a.hit_time < b.hit_time
    end)

    return groups
end

has_incoming_hit_before_our_hit = function(hero, target, now, target_is_friendly)
    local target_index = get_entity_index(target)
    local deadline = now + get_prediction_attack_delay(hero, target)
    local events = get_incoming_hit_events(hero, now, target_is_friendly)

    for i = 1, #events do
        local event = events[i]
        if event.target_index == target_index and event.hit_time <= deadline then
            return true, event.hit_time - now
        end
    end

    return false, 0
end

will_target_die_before_our_hit = function(hero, target, now, target_is_friendly)
    local target_index = get_entity_index(target)
    local health_after_hits = tonumber(Entity.GetHealth(target) or 0) or 0
    local deadline = now + get_prediction_attack_delay(hero, target)
    local events = get_incoming_hit_events(hero, now, target_is_friendly)

    for i = 1, #events do
        local event = events[i]
        if event.target_index == target_index and event.hit_time <= deadline then
            health_after_hits = health_after_hits - (tonumber(event.damage or 0) or 0)
            if health_after_hits <= 0 then
                return true, event.hit_time - now
            end
        end
    end

    return false, 0
end

local function find_incoming_hit_prediction(hero, creeps, now, target_is_friendly)
    local tick = get_tick_interval()
    local events = get_incoming_hit_events(hero, now, target_is_friendly)
    local best_prediction = nil

    for i = 1, #creeps do
        local creep = creeps[i]
        if creep.is_friendly == target_is_friendly
            and creep.health > creep.min_damage
            and not is_our_hit_pending(creep.npc, now)
        then
            local health_after_hits = creep.health
            local contributing_events = {}
            local hit_groups = get_target_hit_groups(events, creep.index)

            for j = 1, #hit_groups do
                local hit_group = hit_groups[j]
                health_after_hits = health_after_hits - hit_group.damage
                for k = 1, #hit_group.events do
                    contributing_events[#contributing_events + 1] = hit_group.events[k]
                end

                if health_after_hits <= 0 then
                    break
                end

                if is_target_actionable_after_hits(creep, health_after_hits) then
                    local hero_hit_delay = get_prediction_attack_delay(hero, creep.npc)
                    local wanted_land_time = hit_group.hit_time + (tick * PREDICT_ATTACK_AFTER_TICKS)
                    local execute_time = wanted_land_time - hero_hit_delay
                    local timing_error = execute_time - now
                    local execute_late = now - execute_time
                    local candidate = {
                        creep = creep,
                        base_health = creep.health,
                        execute_time = execute_time,
                        incoming_time = hit_group.hit_time,
                        target_is_friendly = creep.is_friendly,
                        health_after_hits = health_after_hits,
                            attack_delay = hero_hit_delay,
                            raw_attack_delay = get_raw_prediction_attack_delay(hero, creep.npc),
                            attack_delay_bias = get_attack_delay_bias(),
                            early_safety = get_prediction_early_safety(),
                            events = contributing_events,
                        }

                    if execute_late > get_predict_ready_late_limit() then
                        if should_log_missed_prediction(candidate, now) then
                            debug_log(("PREDICT_CANDIDATE_SKIP target=%s#%d reason=timing_missed predicted_hp=%d incoming_in=%.4f execute_late=%.4f late_limit=%.4f predict_delay=%.4f early=%.4f lead=%.4f after_ticks=%.2f events=%d"):format(
                                creep.name,
                                creep.index,
                                math.floor(health_after_hits + 0.5),
                                hit_group.hit_time - now,
                                execute_late,
                                get_predict_ready_late_limit(),
                                hero_hit_delay,
                                get_prediction_early_safety(),
                                get_prediction_issue_lead(),
                                PREDICT_ATTACK_AFTER_TICKS,
                                #(contributing_events or {})
                            ))
                        end
                    elseif timing_error <= PREDICT_ATTACK_EARLY_WINDOW and timing_error >= -PREDICT_ATTACK_LATE_WINDOW then
                        if not best_prediction
                            or candidate.incoming_time < best_prediction.incoming_time
                            or (
                                candidate.incoming_time == best_prediction.incoming_time
                                and candidate.health_after_hits < best_prediction.health_after_hits
                            )
                        then
                            best_prediction = candidate
                        end

                        break
                    else
                        break
                    end
                end
            end
        end
    end

    return best_prediction
end

local function has_valid_incoming_hit_prediction(hero, target, now, target_is_friendly)
    local target_index = get_entity_index(target)
    local target_health = tonumber(Entity.GetHealth(target) or 0) or 0
    local min_damage = get_min_attack_damage_vs_target(hero, target)
    local max_health = tonumber(Entity.GetMaxHealth(target) or 0) or 0
    local events = get_incoming_hit_events(hero, now, target_is_friendly)
    local health_after_hits = target_health

    for i = 1, #events do
        local event = events[i]
        if event.target_index == target_index then
            health_after_hits = health_after_hits - event.damage
            if health_after_hits <= 0 then
                return false
            end
            if health_after_hits <= min_damage
                and (not target_is_friendly or is_deniable_health(health_after_hits, max_health))
            then
                return true
            end
        end
    end

    return false
end

local function has_valid_prediction_health(hero, target, now, predicted_health, incoming_time)
    predicted_health = tonumber(predicted_health or 0) or 0
    if predicted_health <= 0 then
        return false
    end

    incoming_time = tonumber(incoming_time or 0) or 0
    if incoming_time > 0 and now > incoming_time + (get_tick_interval() * 2) then
        return false
    end

    return predicted_health <= get_min_attack_damage_vs_target(hero, target)
end

local function has_valid_prediction_events(hero, target, now, predicted_health, incoming_time, events, base_health, target_is_friendly)
    local target_index = get_entity_index(target)
    local current_health = tonumber(Entity.GetHealth(target) or 0) or 0
    local max_health = tonumber(Entity.GetMaxHealth(target) or 0) or 0
    local min_damage = get_min_attack_damage_vs_target(hero, target)
    local health_after_events = current_health
    local event_count = #(events or {})
    predicted_health = tonumber(predicted_health or 0) or 0
    incoming_time = tonumber(incoming_time or 0) or 0
    base_health = tonumber(base_health or current_health) or current_health
    local grace = get_tick_interval() * PREDICTION_EVENT_GRACE_TICKS
    local confirmed_stale_grace = get_tick_interval() * PREDICTION_CONFIRMED_EVENT_STALE_TICKS
    local future_expire_grace = get_tick_interval() * PREDICTION_FUTURE_EVENT_EXPIRE_GRACE_TICKS
    local past_damage = 0
    local grace_counted_damage = 0
    local stale_counted_damage = 0
    local reflected_past_damage = 0
    local expired_past_damage = 0
    local expired_past_event = nil
    local expired_past_extra = nil

    local function fail(reason, event, extra)
        local event_text = ""
        if event then
            event_text = (" event_kind=%s source=%s hit_in=%.4f event_target=%s"):format(
                tostring(event.kind),
                tostring(event.source_index),
                (tonumber(event.hit_time or now) or now) - now,
                tostring(event.target_index)
            )
        end

        if extra and extra ~= "" then
            event_text = event_text .. " " .. extra
        end

        debug_log(("PREDICT_VALIDATE_FAIL target=%s reason=%s predicted_hp=%s incoming_in=%.4f base_hp=%d current_hp=%d recalculated_hp=%d min=%d events=%d grace_counted=%d stale_counted=%d reflected_past=%d expired_past=%d%s"):format(
            get_debug_target_text(hero, target),
            reason,
            tostring(predicted_health),
            incoming_time - now,
            math.floor(base_health + 0.5),
            math.floor(current_health + 0.5),
            math.floor(health_after_events + 0.5),
            min_damage,
            event_count,
            math.floor(grace_counted_damage + 0.5),
            math.floor(stale_counted_damage + 0.5),
            math.floor(reflected_past_damage + 0.5),
            math.floor(expired_past_damage + 0.5),
            event_text
        ))
        return false
    end

    if predicted_health <= 0 then
        return fail("predicted_hp_dead")
    end

    if incoming_time > 0 and now > incoming_time + (get_tick_interval() * 2) then
        return fail(("incoming_expired age=%.4f"):format(now - incoming_time))
    end

    if predicted_health > min_damage then
        return fail("predicted_hp_above_min")
    end
    if target_is_friendly and not is_deniable_health(predicted_health, max_health) then
        return fail("predicted_hp_not_deniable")
    end

    for i = 1, #(events or {}) do
        local event = events[i]
        if event.target_index ~= target_index then
            return fail("event_target_changed", event, ("event_index=%d"):format(i))
        end

        if event.kind ~= "projectile" and event.kind ~= "melee" and event.kind ~= "future_melee" and event.kind ~= "future_projectile" then
            return fail("unknown_event_kind", event, ("event_index=%d"):format(i))
        end

        if event.hit_time > now then
            local damage = 0

            if event.kind == "projectile" then
                local projectile = active_projectiles[event.source_index]
                if not projectile or projectile.target_index ~= target_index or projectile.impact_time <= now then
                    return fail("projectile_missing_or_expired", event, ("event_index=%d"):format(i))
                end
                damage = tonumber(projectile.damage or event.damage or 0) or 0
            elseif event.kind == "melee" then
                local swing = active_melee_swings[event.source_index]
                if not swing or swing.target_index ~= target_index or swing.hit_time <= now then
                    return fail("melee_swing_missing_or_expired", event, ("event_index=%d"):format(i))
                end
                damage = tonumber(swing.damage or event.damage or 0) or 0
            elseif event.kind == "future_melee" or event.kind == "future_projectile" then
                local source = get_live_npc_by_index(event.source_index)
                if not source or not is_source_for_target_side(hero, source, target_is_friendly) then
                    return fail("future_attack_clock_invalid", event, ("event_index=%d"):format(i))
                end

                if event.kind == "future_melee" then
                    local swing = active_melee_swings[event.source_index]
                    if swing and swing.target_index == target_index and swing.hit_time > now then
                        damage = tonumber(swing.damage or event.damage or 0) or 0
                    end
                else
                    local projectile = active_projectiles[event.source_index]
                    if projectile and projectile.target_index == target_index and projectile.impact_time > now then
                        damage = tonumber(projectile.damage or event.damage or 0) or 0
                    end
                end

                if damage <= 0 then
                    local clock = creep_attack_clocks[event.source_index]
                    if not clock or clock.target_index ~= target_index then
                        return fail("future_attack_clock_invalid", event, ("event_index=%d"):format(i))
                    end
                    if not is_facing_target(source, target) then
                        return fail("future_attack_not_facing_target", event, ("event_index=%d"):format(i))
                    end

                    local expected_hit_time = get_future_attack_hit_time(source, target, event.attack_start or clock.next_attack_start)
                    if not expected_hit_time then
                        return fail("future_attack_no_expected_hit_time", event, ("event_index=%d"):format(i))
                    end
                    if expected_hit_time <= now then
                        if now - expected_hit_time <= future_expire_grace and event.hit_time > now then
                            damage = tonumber(event.damage or 0) or 0
                            stale_counted_damage = stale_counted_damage + damage
                        else
                            return fail("future_attack_expected_hit_expired", event, ("event_index=%d expected_hit_in=%.4f future_grace=%.4f"):format(i, expected_hit_time - now, future_expire_grace))
                        end
                    else
                        damage = get_min_attack_damage_vs_target(source, target)
                    end
                end
            end

            health_after_events = health_after_events - damage
        else
            local damage = tonumber(event.damage or 0) or 0
            local age = now - event.hit_time
            past_damage = past_damage + damage

            if age <= grace then
                local expected_after_past = base_health - past_damage
                if current_health > expected_after_past + 2 then
                    health_after_events = health_after_events - damage
                    grace_counted_damage = grace_counted_damage + damage
                else
                    reflected_past_damage = reflected_past_damage + damage
                end
            elseif (event.kind == "projectile"
                or event.kind == "melee"
                or event.kind == "future_melee"
                or event.kind == "future_projectile")
                and age <= confirmed_stale_grace
            then
                local expected_after_past = base_health - past_damage
                if current_health > expected_after_past + 2 then
                    health_after_events = health_after_events - damage
                    stale_counted_damage = stale_counted_damage + damage
                else
                    reflected_past_damage = reflected_past_damage + damage
                end
            else
                local expected_after_past = base_health - past_damage
                if current_health > expected_after_past + 2 then
                    expired_past_damage = expired_past_damage + damage
                    if not expired_past_event then
                        expired_past_event = event
                        expired_past_extra = ("event_index=%d age=%.4f damage=%d grace=%.4f expected_after_past=%d"):format(
                            i,
                            age,
                            math.floor(damage + 0.5),
                            grace,
                            math.floor(expected_after_past + 0.5)
                        )
                    end
                else
                    reflected_past_damage = reflected_past_damage + damage
                end
            end
        end
    end

    if expired_past_damage > 0 then
        return fail("past_event_not_reflected_after_grace", expired_past_event, expired_past_extra)
    end

    if health_after_events <= 0 then
        return fail("recalculated_hp_dead")
    end

    if health_after_events > min_damage + PREDICTION_HEALTH_VALIDATION_SLACK then
        return fail("recalculated_hp_above_min")
    end

    if target_is_friendly and not is_deniable_health(health_after_events, max_health) then
        return fail("recalculated_hp_not_deniable")
    end

    return true
end

ui.enable:SetCallback(update_menu_state, true)
ui.visuals_enable:SetCallback(update_menu_state, true)

function LASThitv6.OnDraw()
    if not is_ready_to_draw() then
        return
    end

    local hero = get_local_hero()
    if not hero then
        return
    end

    local hero_position = Entity.GetAbsOrigin(hero)
    local creeps = get_creeps_in_radius(hero, ui.work_radius:Get())

    draw_radius_circle(hero_position, ui.work_radius:Get(), get_ring_color())
    draw_creep_box(hero_position, creeps)

    if ui.debug:Get() then
        draw_facing_target_lines(creeps)
        draw_attack_hit_timers(creeps)
        draw_prediction_debug()
    end
end

function LASThitv6.OnUpdate()
    if not Engine.IsInGame() then
        clear_pending_orders()
        clear_attack_hit_timers()
        return
    end

    if not ui.enable:Get() or not ui.work_key:IsDown() then
        clear_pending_orders()
        return
    end

    local hero = get_local_hero()
    local player = Players.GetLocal()
    if not hero or not player then
        return
    end

    local now = get_time()
    clear_expired_our_pending_hits(now)

    local creeps = get_creeps_in_radius(hero, ui.work_radius:Get())
    local enemy_mode = is_enemy_creeps_enabled()
    local friendly_mode = is_friendly_creeps_enabled()

    if not enemy_mode and not friendly_mode then
        run_move_orders(player, hero, now)
        return
    end

    if attack_confirmation_until > 0 and attack_confirmation_until <= now then
        attack_confirmation_until = 0
        attack_confirmation_target_index = nil
    end
    if attack_confirmation_until > 0 then
        clear_pending_move()
        return
    end

    if pending_attack_target_index then
        if now < pending_attack_execute_time then
            if pending_attack_prediction then
                local target = get_live_creep_by_index(hero, pending_attack_target_index, pending_attack_is_friendly)
                if not target then
                    debug_log(("PENDING_WAIT_CLEAR target=index=%s reason=target_dead_or_stale"):format(tostring(pending_attack_target_index)))
                    clear_pending_attack()
                    return
                end

                local refreshed_prediction = find_incoming_hit_prediction(hero, creeps, now, pending_attack_is_friendly)
                local has_target_refreshed_prediction = refreshed_prediction
                    and refreshed_prediction.creep.index == pending_attack_target_index

                local old_execute_in = pending_attack_execute_time - now
                if is_target_ready_for_action(hero, target, pending_attack_is_friendly)
                    and old_execute_in <= get_pending_direct_override_window()
                then
                    debug_log(("PENDING_DIRECT_OVERRIDE target=%s old_execute_in=%.4f window=%.4f reason=close_pending"):format(
                        get_debug_target_text(hero, target),
                        old_execute_in,
                        get_pending_direct_override_window()
                    ))
                    issue_attack_target_once(player, hero, target, now, pending_attack_is_friendly, true)
                    return
                end

                if has_target_refreshed_prediction
                    and refreshed_prediction.execute_time < pending_attack_execute_time - get_tick_interval()
                then
                    local execute_late = now - refreshed_prediction.execute_time
                    debug_log(("PENDING_REFRESH_PREDICT target=%s old_execute_in=%.4f new_execute_in=%.4f execute_late=%.4f predicted_hp=%d incoming_in=%.4f events=%d"):format(
                        get_debug_target_text(hero, target),
                        pending_attack_execute_time - now,
                        refreshed_prediction.execute_time - now,
                        execute_late,
                        math.floor(refreshed_prediction.health_after_hits + 0.5),
                        refreshed_prediction.incoming_time - now,
                        #(refreshed_prediction.events or {})
                    ))

                    if refreshed_prediction.execute_time <= now then
                        if execute_late <= get_predict_ready_late_limit()
                            and has_valid_prediction_events(hero, target, now, refreshed_prediction.health_after_hits, refreshed_prediction.incoming_time, refreshed_prediction.events, refreshed_prediction.base_health, pending_attack_is_friendly)
                        then
                            issue_attack_target_once(player, hero, target, now, pending_attack_is_friendly, true)
                        elseif execute_late > get_predict_ready_late_limit() then
                            debug_log(("PENDING_REFRESH_SKIP target=%s reason=timing_missed execute_late=%.4f late_limit=%.4f"):format(
                                get_debug_target_text(hero, target),
                                execute_late,
                                get_predict_ready_late_limit()
                            ))
                            clear_pending_attack()
                        end
                    else
                        schedule_attack_at(refreshed_prediction, now)
                    end
                end
            end

            if pending_attack_target_index
                and pending_attack_is_friendly
                and enemy_mode
                and now >= next_attack_schedule_time
            then
                local enemy_prediction = find_incoming_hit_prediction(hero, creeps, now, false)
                if enemy_prediction then
                    local enemy_target = get_live_enemy_creep_by_index(hero, enemy_prediction.creep.index)
                    local execute_late = now - enemy_prediction.execute_time
                    debug_log(("PENDING_DENY_REPLACED_BY_LASTHIT target=%s execute_in=%.4f"):format(
                        enemy_target and get_debug_target_text(hero, enemy_target) or ("index=" .. tostring(enemy_prediction.creep.index)),
                        enemy_prediction.execute_time - now
                    ))
                    if enemy_prediction.execute_time <= now then
                        if enemy_target
                            and execute_late <= get_predict_ready_late_limit()
                            and has_valid_prediction_events(hero, enemy_target, now, enemy_prediction.health_after_hits, enemy_prediction.incoming_time, enemy_prediction.events, enemy_prediction.base_health, false)
                        then
                            issue_attack_target_once(player, hero, enemy_target, now, false, true)
                            return
                        end
                    else
                        schedule_attack_at(enemy_prediction, now)
                        return
                    end
                end

                local enemy_creep = find_killable_creep(creeps, now, false)
                if enemy_creep then
                    debug_log(("PENDING_DENY_REPLACED_BY_DIRECT_LASTHIT target=%s"):format(
                        get_debug_target_text(hero, enemy_creep.npc)
                    ))
                    schedule_attack_target(enemy_creep, now)
                    return
                end
            end

            if not pending_attack_target_index then
                run_move_orders(player, hero, now)
                return
            end

            if not pending_attack_prediction or is_prediction_move_lock_active(now) then
                if pending_attack_prediction and not pending_attack_move_lock_logged then
                    local lock_target = get_live_creep_by_index(hero, pending_attack_target_index, pending_attack_is_friendly)
                    debug_log(("PENDING_MOVE_LOCK target=%s execute_in=%.4f lock_window=%.4f"):format(
                        lock_target and get_debug_target_text(hero, lock_target) or ("index=" .. tostring(pending_attack_target_index)),
                        pending_attack_execute_time - now,
                        get_prediction_move_lock_window()
                    ))
                    pending_attack_move_lock_logged = true
                end
                clear_pending_move()
                return
            end

            if friendly_mode
                and pending_attack_prediction
                and not pending_attack_is_friendly
                and now >= next_attack_schedule_time
            then
                local deny_creep = find_killable_creep(creeps, now, true)
                if deny_creep and can_spare_attack_before_pending(hero, deny_creep.npc, now) then
                    debug_log(("PENDING_DENY_WHILE_WAITING target=%s enemy_execute_in=%.4f"):format(
                        get_debug_target_text(hero, deny_creep.npc),
                        pending_attack_execute_time - now
                    ))
                    issue_attack_target_once(player, hero, deny_creep.npc, now, true)
                    return
                end

                local deny_prediction = find_incoming_hit_prediction(hero, creeps, now, true)
                if deny_prediction and deny_prediction.execute_time <= now then
                    local deny_target = get_live_friendly_creep_by_index(hero, deny_prediction.creep.index)
                    local execute_late = now - deny_prediction.execute_time
                    if deny_target
                        and execute_late <= get_predict_ready_late_limit()
                        and can_spare_attack_before_pending(hero, deny_target, now)
                        and has_valid_prediction_events(hero, deny_target, now, deny_prediction.health_after_hits, deny_prediction.incoming_time, deny_prediction.events, deny_prediction.base_health, true)
                    then
                        debug_log(("PENDING_DENY_PREDICT_WHILE_WAITING target=%s predicted_hp=%d enemy_execute_in=%.4f"):format(
                            get_debug_target_text(hero, deny_target),
                            math.floor(deny_prediction.health_after_hits + 0.5),
                            pending_attack_execute_time - now
                        ))
                        issue_attack_target_once(player, hero, deny_target, now, true, true)
                        return
                    end
                end
            end

            run_move_orders(player, hero, now)
            return
        end

        local fired_target_index = pending_attack_target_index
        local fired_target_is_friendly = pending_attack_is_friendly
        local target = get_live_creep_by_index(hero, fired_target_index, fired_target_is_friendly)
        local is_prediction = pending_attack_prediction
        pending_attack_target_index = nil
        pending_attack_execute_time = 0
        pending_attack_is_friendly = false
        pending_attack_prediction = false
        local base_health = pending_attack_base_health
        local predicted_health = pending_attack_predicted_health
        local predicted_incoming_time = pending_attack_incoming_time
        local predicted_events = pending_attack_events
        pending_attack_base_health = nil
        pending_attack_predicted_health = nil
        pending_attack_incoming_time = 0
        pending_attack_events = nil

        local can_issue_attack = false
        local skip_reason = "target_dead_or_stale"

        if target then
            if is_prediction then
                can_issue_attack = has_valid_prediction_events(hero, target, now, predicted_health, predicted_incoming_time, predicted_events, base_health, fired_target_is_friendly)
                skip_reason = "prediction_validation_failed"
            else
                can_issue_attack = is_target_ready_for_action(hero, target, fired_target_is_friendly)
                skip_reason = ("not_killable hp=%d min=%d"):format(
                    math.floor((tonumber(Entity.GetHealth(target) or 0) or 0) + 0.5),
                    get_min_attack_damage_vs_target(hero, target)
                )
            end
        end

        if can_issue_attack then
            issue_attack_target_once(player, hero, target, now, fired_target_is_friendly, is_prediction)
        else
            local target_text = target and get_debug_target_text(hero, target) or ("index=" .. tostring(fired_target_index))
            if is_prediction then
                debug_log(("PENDING_FIRE_SKIP prediction=true target=%s reason=%s base_hp=%s predicted_hp=%s incoming_in=%.4f events=%d"):format(
                    target_text,
                    skip_reason,
                    tostring(base_health),
                    tostring(predicted_health),
                    (predicted_incoming_time or now) - now,
                    #(predicted_events or {})
                ))
            else
                debug_log(("PENDING_FIRE_SKIP prediction=false target=%s reason=%s"):format(
                    target_text,
                    skip_reason
                ))
            end
        end

        return
    end

    local incoming_prediction = enemy_mode and find_incoming_hit_prediction(hero, creeps, now, false) or nil
    local incoming_prediction_is_friendly = false

    if not incoming_prediction and friendly_mode then
        incoming_prediction = find_incoming_hit_prediction(hero, creeps, now, true)
        incoming_prediction_is_friendly = incoming_prediction ~= nil
    end

    if incoming_prediction and ui.debug:Get() then
        debug_prediction = {
            target_index = incoming_prediction.creep.index,
            expires_at = now + 0.15,
            text = ("%s hp %d in %.2fs"):format(
                incoming_prediction_is_friendly and "Deny" or "Predict",
                math.floor(incoming_prediction.health_after_hits + 0.5),
                math.max(0, incoming_prediction.incoming_time - now)
            ),
        }
    end

    if incoming_prediction and now >= next_attack_schedule_time then
        if incoming_prediction.execute_time <= now then
            local target = get_live_creep_by_index(hero, incoming_prediction.creep.index, incoming_prediction_is_friendly)
            local execute_late = now - incoming_prediction.execute_time
            if execute_late > get_predict_ready_late_limit() then
                if should_log_missed_prediction(incoming_prediction, now) then
                    debug_log(("PREDICT_READY_SKIP target=%s reason=timing_missed predicted_hp=%d incoming_in=%.4f execute_late=%.4f late_limit=%.4f predict_delay=%.4f events=%d"):format(
                        target and get_debug_target_text(hero, target) or ("index=" .. tostring(incoming_prediction.creep.index)),
                        math.floor(incoming_prediction.health_after_hits + 0.5),
                        incoming_prediction.incoming_time - now,
                        execute_late,
                        get_predict_ready_late_limit(),
                        incoming_prediction.attack_delay or 0,
                        #(incoming_prediction.events or {})
                    ))
                end
            elseif target and has_valid_prediction_events(hero, target, now, incoming_prediction.health_after_hits, incoming_prediction.incoming_time, incoming_prediction.events, incoming_prediction.base_health, incoming_prediction_is_friendly) then
                debug_log(("PREDICT_READY_ISSUE target=%s predicted_hp=%d incoming_in=%.4f execute_late=%.4f predict_delay=%.4f raw_delay=%.4f bias=%.4f early=%.4f lead=%.4f after_ticks=%.2f events=%d"):format(
                    get_debug_target_text(hero, target),
                    math.floor(incoming_prediction.health_after_hits + 0.5),
                    incoming_prediction.incoming_time - now,
                    execute_late,
                    incoming_prediction.attack_delay or 0,
                    incoming_prediction.raw_attack_delay or 0,
                    incoming_prediction.attack_delay_bias or 0,
                    incoming_prediction.early_safety or 0,
                    get_prediction_issue_lead(),
                    PREDICT_ATTACK_AFTER_TICKS,
                    #(incoming_prediction.events or {})
                ))
                issue_attack_target_once(player, hero, target, now, incoming_prediction_is_friendly, true)
            else
                debug_log(("PREDICT_READY_SKIP target=%s predicted_hp=%d incoming_in=%.4f execute_late=%.4f predict_delay=%.4f events=%d"):format(
                    target and get_debug_target_text(hero, target) or ("index=" .. tostring(incoming_prediction.creep.index)),
                    math.floor(incoming_prediction.health_after_hits + 0.5),
                    incoming_prediction.incoming_time - now,
                    now - incoming_prediction.execute_time,
                    incoming_prediction.attack_delay or 0,
                    #(incoming_prediction.events or {})
                ))
            end
        else
            schedule_attack_at(incoming_prediction, now)
        end
        return
    end

    local killable_creep = enemy_mode and find_killable_creep(creeps, now, false) or nil
    if not killable_creep and friendly_mode then
        killable_creep = find_killable_creep(creeps, now, true)
    end

    if killable_creep and now >= next_attack_schedule_time then
        clear_pending_move()
        schedule_attack_target(killable_creep, now)
        return
    end

    run_move_orders(player, hero, now)
end

function LASThitv6.OnUnitAnimation(data)
    if not ui.enable:Get() or not data or not data.unit then
        return
    end

    local creep = data.unit
    if NPC.IsCreep(creep) ~= true or NPC.IsRanged(creep) == true or NPC.IsAttacking(creep) ~= true then
        return
    end

    local target = NPC.FindFacingNPC(
        creep,
        nil,
        Enum.TeamType.TEAM_ENEMY,
        25,
        NPC.GetAttackRange(creep) + NPC.GetAttackRangeBonus(creep) + 120
    )
    if not target then
        return
    end

    local attack_start = get_time() - (tonumber(data.lag_compensation_time or 0) or 0)
    local attack_point = tonumber(data.castpoint or NPC.GetAttackAnimPoint(creep) or 0) or 0
    set_melee_hit_timer(creep, target, ceil_to_tick(attack_start + attack_point))
    remember_next_creep_attack(creep, target, attack_start)
end

function LASThitv6.OnUnitAnimationEnd(data)
    if not data or not data.unit then
        return
    end

    local source_index = get_entity_index(data.unit)
    local swing = active_melee_swings[source_index]
    if swing and swing.hit_time <= get_time() then
        active_melee_swings[source_index] = nil
    end
end

function LASThitv6.OnProjectile(data)
    if not ui.enable:Get() or not data or data.isAttack ~= true or not data.source or not data.target then
        return
    end

    local hero = Heroes.GetLocal()
    if hero and (data.source == hero or get_entity_index(data.source) == get_entity_index(hero)) then
        local now = get_time()
        local target_index = get_entity_index(data.target)
        local impact_time = tonumber(data.maxImpactTime or 0) or 0
        if impact_time <= now then
            impact_time = get_projectile_impact_time(data.source, data.target, now)
        end

        if attack_confirmation_target_index == target_index then
            attack_confirmation_until = 0
            attack_confirmation_target_index = nil
            local ready_time = get_next_attack_ready_time(hero, data.target, now)
            next_attack_ready_time = math.max(next_attack_ready_time, ready_time)
            next_attack_schedule_time = math.max(now + ATTACK_ORDER_INTERVAL, ready_time)
            debug_log(("ATTACK_CONFIRMED projectile_sent target=%s ready_in=%.4f"):format(
                is_valid_creep_target(hero, data.target, nil) and get_debug_target_text(hero, data.target) or ("index=" .. tostring(get_entity_index(data.target))),
                math.max(0, ready_time - now)
            ))
        end

        if impact_time and last_attack_issue and last_attack_issue.target_index == target_index then
            local actual_launch_delay = now - last_attack_issue.issue_time
            local actual_hit_delay = impact_time - last_attack_issue.issue_time
            local observed_bias = last_attack_issue.raw_attack_delay - actual_hit_delay

            if observed_bias > -0.25 and observed_bias < 0.50 then
                if attack_delay_bias then
                    attack_delay_bias = (attack_delay_bias * (1 - ATTACK_DELAY_CALIBRATION_ALPHA)) + (observed_bias * ATTACK_DELAY_CALIBRATION_ALPHA)
                else
                    attack_delay_bias = observed_bias
                end

                if attack_delay_bias < 0 then
                    attack_delay_bias = 0
                end

                local max_bias = get_tick_interval() * ATTACK_DELAY_MAX_BIAS_TICKS
                if attack_delay_bias > max_bias then
                    attack_delay_bias = max_bias
                end
            end

            debug_log(("ATTACK_TIMING target=%s launch_delay=%.4f impact_delay=%.4f raw_delay=%.4f predicted_delay=%.4f observed_bias=%.4f active_bias=%.4f early=%.4f lead=%.4f"):format(
                is_valid_creep_target(hero, data.target, nil) and get_debug_target_text(hero, data.target) or ("index=" .. tostring(target_index)),
                actual_launch_delay,
                actual_hit_delay,
                last_attack_issue.raw_attack_delay,
                last_attack_issue.prediction_attack_delay,
                observed_bias,
                get_attack_delay_bias(),
                get_prediction_early_safety(),
                get_prediction_issue_lead()
            ))
            last_attack_issue = nil
        end

        if is_valid_creep_target(hero, data.target, nil) then
            if impact_time then
                remember_our_pending_hit(data.target, impact_time)
                debug_log(("OUR_PROJECTILE target=%s impact_in=%.4f"):format(
                    get_debug_target_text(hero, data.target),
                    impact_time - now
                ))
            end
        end

        return
    end

    local source = data.source
    if NPC.IsCreep(source) ~= true or NPC.IsRanged(source) ~= true then
        return
    end

    local now = get_time()
    local impact_time = tonumber(data.maxImpactTime or 0) or 0
    if impact_time <= now then
        impact_time = get_projectile_impact_time(source, data.target, now)
    end
    if not impact_time then
        return
    end

    set_projectile_hit_timer(source, data.target, ceil_to_tick(impact_time))
    remember_next_creep_attack(source, data.target, now - (tonumber(NPC.GetAttackAnimPoint(source) or 0) or 0))
end

return LASThitv6
