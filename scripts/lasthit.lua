---@diagnostic disable: undefined-global

local LASThitv6 = {}

local DEFAULT_RING_COLOR = Color(80, 255, 120, 220)
LASThitv6.DEFAULT_ATTACK_RANGE_COLOR = Color(255, 210, 80, 210)
LASThitv6.PROJECTILE_CONTACT_DISTANCE_CAP_FRACTION = 0.45
LASThitv6.MELEE_ATTACK_RANGE_BUFFER = 30
LASThitv6.RANGED_ATTACK_RANGE_BUFFER = 0
LASThitv6.MELEE_PREPOSITION_EDGE_BUFFER = 24
LASThitv6.RANGED_PREPOSITION_EDGE_BUFFER = 35
LASThitv6.MELEE_LATE_GAP_CLOSE_MAX_TIME = 0.120
LASThitv6.MELEE_LATE_GAP_CLOSE_MAX_GAP = 45
LASThitv6.MOVE_SPEED_FALLBACK = 250
LASThitv6.MELEE_PREDICTION_IMPACT_AFTER_HIT_BUFFER = 0.066
LASThitv6.MELEE_PREDICT_READY_MAX_LATE = 0.090
LASThitv6.MELEE_REACHABILITY_GRACE = 0.050
LASThitv6.RANGED_REACHABILITY_GRACE = 0.050
LASThitv6.MELEE_CONFIRM_RETRY_MAX_APPROACH = 0.200
LASThitv6.ATTACK_CONFIRM_RETRY_COOLDOWN = 0.750
LASThitv6.SYNC_ATTACK_IMPACT_WINDOW = 0.100
LASThitv6.SYNC_ATTACK_MAX_QUEUE_TIME = 0.500
LASThitv6.SYNC_SPLIT_MAX_QUEUE_TIME = 0.066
LASThitv6.SYNC_ATTACK_MAX_LATE = 0.066
LASThitv6.SYNC_ATTACK_TIMING_SAFETY = 0.050
LASThitv6.SYNC_ATTACK_REPLACE_EARLIER_WINDOW = 0.050
LASThitv6.SYNC_ATTACK_MAX_UNITS = 4
LASThitv6.SYNC_ATTACK_ORDER_ID = "lasthitv6_sync_attack"
LASThitv6.SYNC_ATTACK_START_TIMEOUT = 0.250
LASThitv6.SYNC_SPLIT_START_TIMEOUT = 0.300
LASThitv6.SYNC_ATTACK_CONFIRM_TIMEOUT = 0.650
LASThitv6.SYNC_ATTACK_FAIL_COOLDOWN = 0.500
LASThitv6.SYNC_ATTACK_RETRY_MAX = 1
LASThitv6.pending_attack_preposition_logged = false
LASThitv6.melee_swing_lock_until = 0
LASThitv6.melee_swing_lock_target_index = nil
LASThitv6.melee_hard_lock_until = 0
LASThitv6.melee_hard_lock_target_index = nil
LASThitv6.melee_hard_lock_unit_indexes = {}
LASThitv6.melee_hard_lock_block_log_until = 0
LASThitv6.MELEE_HARD_LOCK_ORDER_ID = "lasthitv6_melee_hard_lock"
LASThitv6.MELEE_HARD_LOCK_REISSUE_INTERVAL = 0.066
LASThitv6.MELEE_HARD_LOCK_REISSUE_INITIAL_DELAY = 0.180
LASThitv6.attack_confirm_retry_block_until = {}
local RING_THICKNESS = 1.6
local GROUND_OFFSET = 3
local RADIUS_PARTICLE_GROUND_OFFSET = 10
local MOVE_ORDER_INTERVAL = 0.10
local MOVE_ORDER_ID = "lasthitv6_move"
local ATTACK_ORDER_INTERVAL = 0.12
local ATTACK_ORDER_ID = "lasthitv6_attack"
local ATTACK_CONFIRM_TIMEOUT = 0.45
local ATTACK_CONFIRM_BUFFER = 0.133
local ATTACK_RECOVERY_BUFFER = 0.033
local ATTACK_ORDER_FIXED_LEAD = 0.033
LASThitv6.MELEE_ATTACK_START_BUFFER = 0
LASThitv6.MELEE_ATTACK_TIMING_SAFETY_LEAD = 0.016
LASThitv6.melee_attack_timing_safety = LASThitv6.MELEE_ATTACK_TIMING_SAFETY_LEAD
LASThitv6.MELEE_DENY_EXTRA_ATTACK_LEAD = ATTACK_ORDER_FIXED_LEAD
local OUR_PENDING_HIT_BUFFER = 0.200
local PREDICTION_EVENT_GRACE = 0.200
local PREDICTION_CONFIRMED_EVENT_STALE_GRACE = 0.667
local PREDICTION_FUTURE_EVENT_EXPIRE_GRACE = 0.100
local PREDICTION_INCOMING_EXPIRE_GRACE = 0.066
local PREDICTION_REFRESH_EPSILON = 0.033
local HIT_GROUP_WINDOW = 0.001
local PREDICT_ATTACK_EARLY_WINDOW = 2.00
local PREDICT_ATTACK_LATE_WINDOW = 2.00
local PREDICT_READY_MAX_LATE = 0.133
local PENDING_DIRECT_OVERRIDE_WINDOW = 0.066
local PREDICTION_FUTURE_ATTACK_COUNT = 3
local PREDICTION_FUTURE_ATTACK_HORIZON = 3.50
local DENY_BEFORE_LASTHIT_MARGIN = 0.800
local PREDICTION_IMPACT_AFTER_HIT_BUFFER = 0.033
local TOWER_SETUP_BEFORE_HIT_BUFFER = 0.050
local TOWER_LASTHIT_AFTER_HIT_BUFFER = 0.033
local GLYPH_IMPACT_AFTER_END_BUFFER = 0.033
local MODE_ENEMY_CREEPS = "Enemy Creeps"
local MODE_FRIENDLY_CREEPS = "Friendly Creeps"
local BOX_PADDING = 8
local BOX_LINE_HEIGHT = 16
local BOX_FONT_SIZE = 14
local BOX_MAX_ROWS = 10
local MIN_CIRCLE_SEGMENTS = 96
local MAX_CIRCLE_SEGMENTS = 360
LASThitv6.radius_particles = {}
LASThitv6.radius_particle_fail_log_until = {}
LASThitv6.RADIUS_PARTICLE_FALLBACK_NAMES = {
    "Dota",
    "Solid Glow",
    "Solid",
    "Dotted",
    "Fade",
    "Dust",
    "Fog",
    "Pulse",
    "Waves",
    "Link",
    "Infinity",
    "Rounded",
    "Slide",
    "Flashlight",
    "Searching",
    "Illuminate",
    "Scene",
    "Portal",
}
LASThitv6.RADIUS_PARTICLE_FALLBACK_PATHS = {
    ["Dota"] = "materials/ui_mouseactions/range_display.vpcf",
    ["Solid Glow"] = "materials/radius_particle/glow_solid.vpcf",
    ["Solid"] = "materials/radius_particle/solid.vpcf",
    ["Dotted"] = "materials/radius_particle/dotted_finish.vpcf",
    ["Fade"] = "materials/radius_particle/fade_finish.vpcf",
    ["Fade Dynamic"] = "materials/radius_particle/fade_dynamic.vpcf",
    ["Dust"] = "materials/radius_particle/dust.vpcf",
    ["Fog"] = "materials/radius_particle/fog.vpcf",
    ["Pulse"] = "particles/new_particle_radius/new_particle_radius_1.vpcf",
    ["Waves"] = "particles/new_particle_radius/new_particle_radius_2.vpcf",
    ["Link"] = "particles/new_particle_radius/new_particle_radius_3.vpcf",
    ["Infinity"] = "particles/new_particle_radius/new_particle_radius_4.vpcf",
    ["Rounded"] = "particles/new_particle_radius/new_particle_radius_5.vpcf",
    ["Slide"] = "particles/new_particle_radius/new_particle_radius_6.vpcf",
    ["Flashlight"] = "particles/new_particle_radius/28.vpcf",
    ["Searching"] = "particles/new_particle_radius/29.vpcf",
    ["Illuminate"] = "particles/new_particle_radius/31.vpcf",
    ["Scene"] = "particles/new_particle_radius/32.vpcf",
    ["Portal"] = "particles/new_particle_radius/33.vpcf",
}

LASThitv6.ATTACK_CONFIRM_START_TIMEOUT = 0.350
LASThitv6.MELEE_ATTACK_CONFIRM_START_TIMEOUT = 0.400
LASThitv6.MELEE_GAP_ATTACK_CONFIRM_EXTRA = 0.200
LASThitv6.MELEE_HARD_LOCK_EXTRA = 0.050
LASThitv6.RANGED_PROJECTILE_CONFIRM_BUFFER = 0.066
LASThitv6.attack_confirmation_start_check_until = 0
LASThitv6.attack_confirmation_started = false

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
local TOWER_HIT_TEXT_COLOR = Color(255, 220, 120, 255)
local GLYPH_HIT_TEXT_COLOR = Color(180, 150, 255, 255)
local TEXT_SHADOW_COLOR = Color(0, 0, 0, 255)

local GLYPH_SHIELD_MODIFIER_NAME = "modifier_fountain_glyph"

LASThitv6.SHRAPNEL_MODIFIER_NAME = "modifier_sniper_shrapnel_slow"
LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL = 1.000
LASThitv6.SHRAPNEL_FALLBACK_DURATION_AFTER_PULSE = 8.800
LASThitv6.SHRAPNEL_MAX_TICKS = 8
LASThitv6.SHRAPNEL_PULSE_EXPIRE_GRACE = 0.250
LASThitv6.SHRAPNEL_SPECIAL_VALUE_NAMES = {
    "damage",
    "shrapnel_damage",
    "damage_per_second",
    "dps",
}
LASThitv6.SHRAPNEL_DURATION_VALUE_NAMES = { "duration" }
LASThitv6.SHRAPNEL_DAMAGE_DELAY_VALUE_NAMES = { "damage_delay" }
LASThitv6.active_shrapnel_pulses = {}

LASThitv6.SHADOW_STRIKE_MODIFIER_NAME = "modifier_queenofpain_shadow_strike"
LASThitv6.SHADOW_STRIKE_ABILITY_NAME = "queenofpain_shadow_strike"
LASThitv6.SHADOW_STRIKE_FALLBACK_INTERVAL = 3.000
LASThitv6.SHADOW_STRIKE_FALLBACK_DURATION = 16.000
LASThitv6.SHADOW_STRIKE_MAX_TICKS = 6
LASThitv6.SHADOW_STRIKE_DAMAGE_VALUE_NAMES = { "duration_damage" }
LASThitv6.SHADOW_STRIKE_INTERVAL_VALUE_NAMES = { "damage_interval" }
LASThitv6.SHADOW_STRIKE_DURATION_VALUE_NAMES = { "duration" }

local tab = Menu.Create("General", "Main", "LastHitV6")
local main = tab:Create("Main")
local settings = main:Create("Settings")
LASThitv6.extra_settings = main:Create("Дополнителные Настройки")
local visuals = main:Create("Visual Settings")
local box_font = Render.LoadFont("Arial", 0, 500)

function LASThitv6.CreateSyncAttackSwitch(parent)
    if parent and parent.Label then
        LASThitv6.multi_hero_settings = parent:Label("Настройки Управления Нескольками Героями")
        if LASThitv6.multi_hero_settings and LASThitv6.multi_hero_settings.Gear then
            LASThitv6.multi_hero_settings_gear = LASThitv6.multi_hero_settings:Gear("Настройки Управления Нескольками Героями")
            if LASThitv6.multi_hero_settings_gear and LASThitv6.multi_hero_settings_gear.Switch then
                return LASThitv6.multi_hero_settings_gear:Switch("Синхроризвать атаку", false)
            end
        end
    end

    return parent:Switch("Настройки Управления Нескольками Героями / Синхроризвать атаку", false)
end

function LASThitv6.GetRadiusParticleNames()
    if type(LIB_HEROES_DATA) == "table" and type(LIB_HEROES_DATA.particles_for_radius) == "table" then
        local source = LIB_HEROES_DATA.particles_for_radius
        local keys = {}
        for key in pairs(source) do
            if tonumber(key) then
                keys[#keys + 1] = key
            end
        end
        table.sort(keys, function(a, b)
            return tonumber(a) < tonumber(b)
        end)

        local names = {}
        for i = 1, #keys do
            local name = source[keys[i]]
            if type(name) == "string" and name ~= "" then
                names[#names + 1] = name
            end
        end
        if #names > 0 then
            return names
        end
    end

    return LASThitv6.RADIUS_PARTICLE_FALLBACK_NAMES
end

local ui = {
    enable = settings:Switch("Enable", false),
    work_radius = settings:Slider("Work Radius", 100, 2000, 600, "%d"),
    work_key = settings:Bind("Work Key", Enum.ButtonCode.KEY_NONE),
    activation_mode = settings:Combo("Activation Mode", { "Hold", "Toggle" }, 0),
    sync_attack = LASThitv6.CreateSyncAttackSwitch(LASThitv6.extra_settings),
    visuals_enable = visuals:Switch("Enable", true),
    debug = visuals:Switch("Debug", false),
}

ui.work_range_settings = ui.work_radius:Gear("Range Settings")
ui.ring_particle = ui.work_range_settings:Combo("Circle Particle", LASThitv6.GetRadiusParticleNames(), 0)
ui.ring_color = ui.work_range_settings:ColorPicker("Circle Color", DEFAULT_RING_COLOR)
ui.attack_range = ui.work_range_settings:Switch("Attack Range", false)
ui.attack_range_particle = ui.work_range_settings:Combo("Attack Range Particle", LASThitv6.GetRadiusParticleNames(), 0)
ui.attack_range_color = ui.work_range_settings:ColorPicker("Attack Range Color", LASThitv6.DEFAULT_ATTACK_RANGE_COLOR)

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
local pending_attack_attack_delay = 0
local pending_attack_move_lock_logged = false
local attack_confirmation_until = 0
local attack_confirmation_target_index = nil
local attack_confirmation_target_is_friendly = false
local attack_confirmation_issue_time = 0
local attack_confirmation_order_seen = false
local active_projectiles = {}
local active_melee_swings = {}
local creep_attack_clocks = {}
local our_pending_hits = {}
local active_setup_hits = {}
local last_attack_issue = nil
local issue_attack_target_once
LASThitv6.sync_attack_queue = {}
LASThitv6.sync_attack_last_issue = {}
LASThitv6.sync_attack_pending = {}
LASThitv6.sync_attack_fail_until = {}
LASThitv6.sync_attack_ready_until = {}
local missed_prediction_logs = {}
local debug_prediction = nil
local get_future_attack_hit_time

local function update_menu_state()
    local enabled = ui.enable:Get()
    local visuals_enabled = enabled and ui.visuals_enable:Get()
    local attack_range_enabled = visuals_enabled and ui.attack_range:Get()

    ui.work_key:Disabled(not enabled)
    ui.work_radius:Disabled(not enabled)
    ui.activation_mode:Disabled(not enabled)
    ui.sync_attack:Disabled(not enabled)
    ui.ring_particle:Disabled(not visuals_enabled)
    ui.ring_color:Disabled(not visuals_enabled)
    ui.attack_range:Disabled(not visuals_enabled)
    ui.attack_range_particle:Disabled(not attack_range_enabled)
    ui.attack_range_color:Disabled(not attack_range_enabled)
    if ui.creep_modes then
        ui.creep_modes:Disabled(not enabled)
    end
    if ui.enemy_creeps then
        ui.enemy_creeps:Disabled(not enabled)
    end
    if ui.friendly_creeps then
        ui.friendly_creeps:Disabled(not enabled)
    end
    ui.visuals_enable:Disabled(not enabled)
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

local function safe_call(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end

    return nil
end

local function get_network_latency()
    if not NetChannel then
        return 0
    end

    local function normalize_latency(value)
        local latency = tonumber(value or 0) or 0
        if latency > 1 then
            latency = latency / 1000
        end
        if latency <= 0 or latency > 1 then
            return 0
        end
        return latency
    end

    local outgoing = 0
    local incoming = 0
    if Enum and Enum.Flow then
        outgoing = normalize_latency(safe_call(NetChannel.GetLatency, Enum.Flow.FLOW_OUTGOING))
        incoming = normalize_latency(safe_call(NetChannel.GetLatency, Enum.Flow.FLOW_INCOMING))
        if outgoing <= 0 then
            outgoing = normalize_latency(safe_call(NetChannel.GetAvgLatency, Enum.Flow.FLOW_OUTGOING))
        end
        if incoming <= 0 then
            incoming = normalize_latency(safe_call(NetChannel.GetAvgLatency, Enum.Flow.FLOW_INCOMING))
        end
    end

    if outgoing > 0 and incoming > 0 then
        return outgoing + incoming
    end
    if outgoing > 0 or incoming > 0 then
        return math.max(outgoing, incoming)
    end

    local latency = normalize_latency(safe_call(NetChannel.GetLatency))
    if latency <= 0 then
        latency = normalize_latency(safe_call(NetChannel.GetAvgLatency))
    end
    return latency
end

local function get_attack_order_lead()
    return get_network_latency() + ATTACK_ORDER_FIXED_LEAD
end

function LASThitv6.GetTickInterval()
    if GlobalVars.GetIntervalPerTick then
        local tick = tonumber(safe_call(GlobalVars.GetIntervalPerTick) or 0) or 0
        if tick > 0 then
            return tick
        end
    end

    return 1 / 30
end

function LASThitv6.GetAttackOrderStartDelay(_hero)
    local command_delay = math.max(LASThitv6.GetTickInterval() * 2, ATTACK_ORDER_INTERVAL - ATTACK_ORDER_FIXED_LEAD)
    return get_network_latency() + command_delay
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

function LASThitv6.ResolveLiveUnit(value)
    if value == nil then
        return nil
    end

    local value_type = type(value)
    if value_type == "number" then
        return get_live_npc_by_index(value)
    end
    if value_type == "string" then
        local index = tonumber(value)
        if index then
            return get_live_npc_by_index(index)
        end
        return nil
    end

    if safe_call(Entity.IsNPC, value) == true and safe_call(Entity.IsAlive, value) == true then
        return value
    end

    return nil
end

function LASThitv6.IsWorkActive()
    if not ui.enable:Get() then
        return false
    end

    if ui.activation_mode:Get() == 1 then
        return ui.work_key:IsToggled()
    end

    return ui.work_key:IsDown()
end

local function is_ready_to_draw()
    return LASThitv6.IsWorkActive()
        and ui.visuals_enable:Get()
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

local function get_attack_damage_range_vs_target(attacker, target)
    local armor_multiplier = tonumber(NPC.GetArmorDamageMultiplier(target) or 1) or 1
    local min_damage = tonumber(safe_call(NPC.GetTrueDamage, attacker) or 0) or 0
    local max_damage = tonumber(safe_call(NPC.GetTrueMaximumDamage, attacker) or 0) or 0

    if min_damage <= 0 then
        local base_min_damage = tonumber(safe_call(NPC.GetMinDamage, attacker) or 0) or 0
        local bonus_damage = tonumber(safe_call(NPC.GetBonusDamage, attacker) or 0) or 0
        min_damage = base_min_damage + bonus_damage
    end
    if max_damage < min_damage then
        max_damage = min_damage
    end

    return math.floor((min_damage * armor_multiplier) + 0.0001),
        math.floor((max_damage * armor_multiplier) + 0.0001)
end

local function get_min_attack_damage_vs_target(attacker, target)
    local min_damage = get_attack_damage_range_vs_target(attacker, target)
    return min_damage
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
    health_after_hits = tonumber(health_after_hits or 0) or 0
    if health_after_hits <= 0 then
        return false
    end

    if creep.is_friendly then
        return health_after_hits <= creep.min_damage
            and is_deniable_health(health_after_hits, creep.max_health)
    end

    return health_after_hits <= creep.min_damage
end

function LASThitv6.GetProjectileTravelRadius(unit)
    if not unit or not NPC then
        return 0
    end

    local radius = 0
    radius = math.max(radius, tonumber(safe_call(NPC.GetProjectileCollisionSize, unit) or 0) or 0)
    radius = math.max(radius, tonumber(safe_call(NPC.GetPaddedCollisionRadius, unit) or 0) or 0)
    radius = math.max(radius, tonumber(safe_call(NPC.GetHullRadius, unit) or 0) or 0)
    return math.max(0, radius)
end

function LASThitv6.GetProjectileTravelDistance(source, target)
    local distance = distance_2d(Entity.GetAbsOrigin(source), Entity.GetAbsOrigin(target))
    return LASThitv6.GetProjectileTravelDistanceFromDistance(source, target, distance)
end

function LASThitv6.GetProjectileTravelDistanceFromDistance(source, target, distance)
    distance = tonumber(distance or 0) or 0
    local contact_distance = LASThitv6.GetProjectileTravelRadius(source) + LASThitv6.GetProjectileTravelRadius(target)

    if contact_distance <= 0 then
        return distance
    end

    contact_distance = math.min(contact_distance, distance * LASThitv6.PROJECTILE_CONTACT_DISTANCE_CAP_FRACTION)
    return math.max(0, distance - contact_distance)
end

function LASThitv6.GetAttackRangeInfo(hero, target)
    if not hero or not target then
        return 0, 0, 0, false
    end

    local hero_pos = Entity.GetAbsOrigin(hero)
    local target_pos = Entity.GetAbsOrigin(target)
    if not hero_pos or not target_pos then
        return 0, 0, 0, false
    end

    local distance = distance_2d(hero_pos, target_pos)
    local attack_range = tonumber(safe_call(NPC.GetAttackRange, hero) or 0) or 0
    local attack_bonus = tonumber(safe_call(NPC.GetAttackRangeBonus, hero) or 0) or 0
    local hero_hull = tonumber(safe_call(NPC.GetHullRadius, hero) or 0) or 0
    local target_hull = tonumber(safe_call(NPC.GetHullRadius, target) or 0) or 0
    local range_buffer = NPC.IsRanged(hero) == true and LASThitv6.RANGED_ATTACK_RANGE_BUFFER or LASThitv6.MELEE_ATTACK_RANGE_BUFFER
    local reach = attack_range + attack_bonus + hero_hull + target_hull + range_buffer
    local gap = math.max(0, distance - reach)

    return distance, reach, gap, distance <= reach
end

function LASThitv6.GetMeleeAttackRangeInfo(hero, target)
    return LASThitv6.GetAttackRangeInfo(hero, target)
end

function LASThitv6.GetCurrentMoveSpeed(unit)
    if unit and NPC.GetMoveSpeed then
        local value = safe_call(NPC.GetMoveSpeed, unit)
        if value ~= nil then
            local move_speed = tonumber(value) or 0
            if move_speed > 0 then
                return move_speed, true
            end

            return 0, true
        end
    end

    return LASThitv6.MOVE_SPEED_FALLBACK, false
end

LASThitv6.attack_data_by_name = nil

function LASThitv6.GetScriptDirectory()
    if debug and debug.getinfo then
        local source = tostring((debug.getinfo(1, "S") or {}).source or "")
        if source:sub(1, 1) == "@" then
            source = source:sub(2)
        end
        return source:match("^(.*[\\/])")
    end

    return nil
end

function LASThitv6.ReadTextFile(path)
    if not io or not io.open or not path then
        return nil
    end

    local file = io.open(path, "rb")
    if not file then
        return nil
    end

    local text = file:read("*a")
    file:close()
    return text
end

function LASThitv6.LoadAttackDataFile(path, data)
    local text = LASThitv6.ReadTextFile(path)
    if not text then
        return false
    end

    for unit_name, attack_rate in text:gmatch('"(npc_dota_[^"]+)"%s*:%s*{%s.-"AttackRate"%s*:%s*"([%d%.]+)"') do
        data[unit_name] = data[unit_name] or {}
        data[unit_name].attack_rate = tonumber(attack_rate)
    end
    for unit_name, attack_point in text:gmatch('"(npc_dota_[^"]+)"%s*:%s*{%s.-"AttackAnimationPoint"%s*:%s*"([%d%.]+)"') do
        data[unit_name] = data[unit_name] or {}
        data[unit_name].attack_point = tonumber(attack_point)
    end

    return true
end

function LASThitv6.GetAttackDataByName()
    if LASThitv6.attack_data_by_name then
        return LASThitv6.attack_data_by_name
    end

    local data = {}
    local script_dir = LASThitv6.GetScriptDirectory()
    local paths = {
        "assets\\data\\npc_heroes.json",
        "assets\\data\\npc_units.json",
        "C:\\Users\\da204\\Downloads\\Umbrella\\assets\\data\\npc_heroes.json",
        "C:\\Users\\da204\\Downloads\\Umbrella\\assets\\data\\npc_units.json",
    }
    if script_dir then
        paths[#paths + 1] = script_dir .. "..\\assets\\data\\npc_heroes.json"
        paths[#paths + 1] = script_dir .. "..\\assets\\data\\npc_units.json"
    end

    for i = 1, #paths do
        LASThitv6.LoadAttackDataFile(paths[i], data)
    end

    LASThitv6.attack_data_by_name = data
    return data
end

function LASThitv6.GetUnitAttackData(unit)
    local unit_name = type(unit) == "string" and unit or tostring(safe_call(NPC.GetUnitName, unit) or "")
    if unit_name == "" then
        return nil
    end

    return LASThitv6.GetAttackDataByName()[unit_name]
end

function LASThitv6.GetBaseAttackRate(unit, data)
    if NPC.GetBaseAttackTime then
        local base_attack_time = tonumber(safe_call(NPC.GetBaseAttackTime, unit) or 0) or 0
        if base_attack_time > 0 then
            return base_attack_time
        end
    end
    if NPC.GetAttackRate then
        local attack_rate = tonumber(safe_call(NPC.GetAttackRate, unit) or 0) or 0
        if attack_rate > 0 then
            return attack_rate
        end
    end
    if data and tonumber(data.attack_rate or 0) and tonumber(data.attack_rate or 0) > 0 then
        return tonumber(data.attack_rate)
    end

    return tonumber(safe_call(NPC.GetAttackTime, unit) or 0) or 0
end

function LASThitv6.GetTargetRadialMoveAwaySpeed(unit, target)
    if not unit or not target then
        return 0
    end
    if NPC.IsRunning and safe_call(NPC.IsRunning, target) ~= true then
        return 0
    end
    if NPC.IsTurning and safe_call(NPC.IsTurning, target) == true then
        return 0
    end
    if not Entity.GetRotation then
        return 0
    end

    local unit_pos = Entity.GetAbsOrigin(unit)
    local target_pos = Entity.GetAbsOrigin(target)
    if not unit_pos or not target_pos then
        return 0
    end

    local dx = (target_pos.x or 0) - (unit_pos.x or 0)
    local dy = (target_pos.y or 0) - (unit_pos.y or 0)
    local distance = math.sqrt((dx * dx) + (dy * dy))
    if distance <= 0 then
        return 0
    end

    local rotation = safe_call(Entity.GetRotation, target)
    if not rotation or not rotation.GetForward then
        return 0
    end

    local forward = rotation:GetForward()
    if not forward then
        return 0
    end
    forward = forward:Normalized()

    local target_move_speed = tonumber(safe_call(NPC.GetMoveSpeed, target) or 0) or 0
    if target_move_speed <= 0 then
        return 0
    end

    local radial = (((forward.x or 0) * dx) + ((forward.y or 0) * dy)) / distance
    return math.max(0, radial * target_move_speed)
end

function LASThitv6.GetApproachTimeFromGap(unit, target, gap, move_speed)
    gap = math.max(0, tonumber(gap or 0) or 0)
    move_speed = tonumber(move_speed or 0) or 0
    if gap <= 0 then
        return 0, move_speed, 0
    end
    if move_speed <= 0 then
        return 999.0, 0, 0
    end

    local away_speed = LASThitv6.GetTargetRadialMoveAwaySpeed(unit, target)
    local effective_speed = math.max(1, move_speed - away_speed)
    return gap / effective_speed, effective_speed, away_speed
end

local function get_preposition_order_lead(hero)
    return get_attack_order_lead() + MOVE_ORDER_INTERVAL
end

function LASThitv6.GetPrepositionEdgeBuffer(hero)
    if hero and NPC.IsRanged(hero) == true then
        return LASThitv6.RANGED_PREPOSITION_EDGE_BUFFER
    end

    return LASThitv6.MELEE_PREPOSITION_EDGE_BUFFER
end

function LASThitv6.GetAttackPrepositionWindow(hero, target)
    local distance, reach, gap = LASThitv6.GetAttackRangeInfo(hero, target)
    local move_speed = LASThitv6.GetCurrentMoveSpeed(hero)
    local edge_buffer = math.min(reach * 0.30, LASThitv6.GetPrepositionEdgeBuffer(hero))
    local safe_reach = math.max(0, reach - edge_buffer)
    gap = math.max(0, distance - safe_reach)
    if gap <= 0 then
        return 0, distance, safe_reach, 0, move_speed
    end

    local approach_time = LASThitv6.GetApproachTimeFromGap(hero, target, gap, move_speed)
    local window = approach_time + get_preposition_order_lead(hero)

    return window, distance, safe_reach, approach_time, move_speed
end

function LASThitv6.GetMeleePrepositionWindow(hero, target)
    return LASThitv6.GetAttackPrepositionWindow(hero, target)
end

function LASThitv6.GetAttackApproachTime(hero, target)
    if not hero or not target then
        return 0, 0, 0, 0, true, 0
    end

    local window, distance, reach, approach_time, move_speed = LASThitv6.GetAttackPrepositionWindow(hero, target)
    local gap = math.max(0, distance - reach)
    if window <= 0 or approach_time <= 0 then
        return 0, distance, reach, 0, true, move_speed
    end

    return approach_time, distance, reach, gap, false, move_speed
end

function LASThitv6.GetMeleeApproachTime(hero, target)
    if not hero or not target or NPC.IsRanged(hero) == true then
        return 0, 0, 0, 0, true, 0
    end

    return LASThitv6.GetAttackApproachTime(hero, target)
end

function LASThitv6.IsAttackReachableByExecuteTime(hero, target, now, execute_time)
    if not hero or not target then
        return true, 0, 0, 0, 0, 0, 0
    end

    local approach_time, distance, reach, gap, in_range, move_speed = LASThitv6.GetAttackApproachTime(hero, target)
    if in_range then
        return true, distance, reach, gap, approach_time, 0, move_speed
    end

    local available_time = math.max(0, (tonumber(execute_time or now) or now) - now)
    local grace = NPC.IsRanged(hero) == true and LASThitv6.RANGED_REACHABILITY_GRACE or LASThitv6.MELEE_REACHABILITY_GRACE
    local reachable = approach_time <= available_time + grace
    return reachable, distance, reach, gap, approach_time, available_time, move_speed
end

function LASThitv6.IsMeleeReachableByExecuteTime(hero, target, now, execute_time)
    if not hero or not target or NPC.IsRanged(hero) == true then
        return true, 0, 0, 0, 0, 0, 0
    end

    return LASThitv6.IsAttackReachableByExecuteTime(hero, target, now, execute_time)
end

function LASThitv6.GetPredictionAfterHitBuffer(hero, has_tower_event)
    local buffer = PREDICTION_IMPACT_AFTER_HIT_BUFFER
    if NPC.IsRanged(hero) ~= true then
        buffer = LASThitv6.MELEE_PREDICTION_IMPACT_AFTER_HIT_BUFFER
    end
    if has_tower_event == true then
        buffer = math.max(buffer, TOWER_LASTHIT_AFTER_HIT_BUFFER)
    end

    return buffer
end

function LASThitv6.GetGlyphImpactAfterEndBuffer(hero)
    if NPC.IsRanged(hero) ~= true then
        return math.max(GLYPH_IMPACT_AFTER_END_BUFFER, LASThitv6.MELEE_PREDICTION_IMPACT_AFTER_HIT_BUFFER)
    end

    return GLYPH_IMPACT_AFTER_END_BUFFER
end

local function get_unit_hit_delay(attacker, target, assume_in_attack_range)
    local delay = LASThitv6.GetScaledAttackAnimPoint(attacker)
    local projectile_speed = tonumber(NPC.GetAttackProjectileSpeed(attacker) or 0) or 0

    if projectile_speed > 0 and NPC.IsRanged(attacker) == true then
        local travel_distance = LASThitv6.GetProjectileTravelDistance(attacker, target)
        if assume_in_attack_range == true then
            local distance, reach, gap = LASThitv6.GetAttackRangeInfo(attacker, target)
            if gap > 0 and reach > 0 then
                travel_distance = LASThitv6.GetProjectileTravelDistanceFromDistance(attacker, target, math.min(distance, reach))
            end
        end
        delay = delay + (travel_distance / projectile_speed)
    end

    return delay
end

function LASThitv6.GetScaledAttackAnimPoint(npc)
    local attack_data = LASThitv6.GetUnitAttackData(npc)
    local attack_point = tonumber(attack_data and attack_data.attack_point or 0) or 0
    if attack_point <= 0 then
        attack_point = tonumber(safe_call(NPC.GetAttackAnimPoint, npc) or 0) or 0
    end
    if attack_point <= 0 then
        return attack_point, attack_point, 1
    end

    local seconds_per_attack = tonumber(safe_call(NPC.GetSecondsPerAttack, npc, false) or 0) or 0
    if seconds_per_attack <= 0 and NPC.GetAttacksPerSecond then
        local attacks_per_second = tonumber(safe_call(NPC.GetAttacksPerSecond, npc) or 0) or 0
        if attacks_per_second > 0 then
            seconds_per_attack = 1 / attacks_per_second
        end
    end
    local base_attack_time = LASThitv6.GetBaseAttackRate(npc, attack_data)
    if seconds_per_attack <= 0 or base_attack_time <= 0 then
        return attack_point, attack_point, 1
    end

    local scale = seconds_per_attack / base_attack_time
    if scale <= 0.10 or scale > 3.00 then
        return attack_point, attack_point, 1
    end

    return attack_point * scale, attack_point, scale
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
    if NPC.GetTimeToFacePosition and target and Entity.GetAbsOrigin then
        local target_pos = safe_call(Entity.GetAbsOrigin, target)
        if target_pos then
            local face_time = tonumber(safe_call(NPC.GetTimeToFacePosition, hero, target_pos) or 0) or 0
            if face_time > 0 and face_time < 0.75 then
                return face_time
            end
        end
    end

    if NPC.GetTimeToFace then
        local face_time = tonumber(safe_call(NPC.GetTimeToFace, hero, target) or 0) or 0
        if face_time > 0 and face_time < 0.75 then
            return face_time
        end
    end

    return 0
end

function LASThitv6.GetAttackStartCheckDelay(hero, target, approach_time)
    return math.max(0, tonumber(approach_time or 0) or 0)
        + get_hero_face_time(hero, target)
        + LASThitv6.GetAttackOrderStartDelay(hero)
        + (LASThitv6.GetTickInterval() * 4)
end

local function get_hero_hit_delay(hero, target, assume_in_attack_range)
    local delay = get_unit_hit_delay(hero, target, assume_in_attack_range) + get_hero_face_time(hero, target)
    if hero then
        delay = delay + LASThitv6.GetAttackOrderStartDelay(hero)
    end

    return delay
end

local function get_raw_prediction_attack_delay(hero, target)
    return get_hero_hit_delay(hero, target, true)
end

local function get_prediction_issue_lead(hero)
    return get_attack_order_lead()
end

local function get_prediction_landing_buffer(hero, impact_after_hit_buffer)
    if hero and NPC.IsRanged(hero) == true then
        return get_prediction_issue_lead(hero) + impact_after_hit_buffer
    end

    return impact_after_hit_buffer
end

local function get_prediction_attack_delay(hero, target)
    local delay = get_raw_prediction_attack_delay(hero, target)
    if hero and NPC.IsRanged(hero) == true then
        delay = delay + get_prediction_issue_lead(hero)
    end

    return delay
end

function LASThitv6.GetSyncPredictionAttackDelay(unit, target)
    local attack_delay = get_raw_prediction_attack_delay(unit, target)
    local distance, reach, gap, in_range = LASThitv6.GetAttackRangeInfo(unit, target)
    local move_speed = LASThitv6.GetCurrentMoveSpeed(unit)
    local approach_time = 0
    if gap > 0 then
        approach_time = LASThitv6.GetApproachTimeFromGap(unit, target, gap, move_speed)
        attack_delay = attack_delay + approach_time
    end

    return attack_delay, approach_time, distance, reach, gap, in_range, move_speed
end

local function get_hero_attack_launch_delay(hero, target)
    local attack_point = LASThitv6.GetScaledAttackAnimPoint(hero)
    return attack_point + get_hero_face_time(hero, target)
end

local function get_attack_confirmation_timeout(hero, target)
    local wait_delay = get_hero_attack_launch_delay(hero, target)
    if NPC.IsRanged(hero) == true then
        wait_delay = get_hero_hit_delay(hero, target)
    end

    return math.max(ATTACK_CONFIRM_TIMEOUT, get_prediction_issue_lead(hero) + wait_delay + ATTACK_CONFIRM_BUFFER)
end

local function get_next_attack_ready_time(hero, target, launch_time)
    local attack_period = get_attack_period(hero)
    if not attack_period then
        return launch_time
    end

    local attack_start = launch_time - get_hero_attack_launch_delay(hero, target)
    return attack_start + attack_period + ATTACK_RECOVERY_BUFFER
end

local function get_next_attack_ready_time_from_start(hero, attack_start)
    local attack_period = get_attack_period(hero)
    if not attack_period then
        return attack_start
    end

    return attack_start + attack_period + ATTACK_RECOVERY_BUFFER
end

local function get_predict_ready_late_limit(hero)
    hero = hero or get_local_hero()
    if hero and NPC.IsRanged(hero) ~= true then
        return LASThitv6.MELEE_PREDICT_READY_MAX_LATE
    end

    return PREDICT_READY_MAX_LATE
end

local function get_pending_direct_override_window()
    return PENDING_DIRECT_OVERRIDE_WINDOW
end

local function get_prediction_log_key(prediction)
    return ("%d:%.3f:%d"):format(
        prediction.creep.index,
        tonumber(prediction.incoming_time or 0) or 0,
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

local function debug_log(message)
    if ui.debug:Get() then
        local now = get_time()
        print(("[LastHitV6] t=%.4f %s"):format(now, message))
    end
end

function LASThitv6.GetModifierEndTime(modifier)
    if not modifier or not Modifier then
        return nil
    end

    local die_time = tonumber(safe_call(Modifier.GetDieTime, modifier) or 0) or 0
    if die_time > 0 then
        return die_time
    end

    return nil
end

function LASThitv6.GetGlyphShieldModifier(creep)
    if not creep or not NPC or not Modifier then
        return nil, nil
    end

    local modifier = safe_call(NPC.GetModifier, creep, GLYPH_SHIELD_MODIFIER_NAME)
    if modifier then
        return modifier, GLYPH_SHIELD_MODIFIER_NAME
    end

    return nil, nil
end

function LASThitv6.GetGlyphShieldEndTime(creep, now)
    local modifier, modifier_name = LASThitv6.GetGlyphShieldModifier(creep)
    if not modifier then
        return nil, nil
    end

    local shield_end_time = LASThitv6.GetModifierEndTime(modifier)
    now = now or get_time()
    if shield_end_time and shield_end_time > now then
        return shield_end_time, modifier_name
    end

    return nil, modifier_name
end

function LASThitv6.HasActiveGlyphShield(creep, now)
    return LASThitv6.GetGlyphShieldEndTime(creep, now) ~= nil
end

function LASThitv6.GetShrapnelModifier(creep)
    if not creep or not NPC or not Modifier then
        return nil, nil
    end

    local modifier = safe_call(NPC.GetModifier, creep, LASThitv6.SHRAPNEL_MODIFIER_NAME)
    if modifier then
        return modifier, LASThitv6.SHRAPNEL_MODIFIER_NAME
    end

    return nil, nil
end

function LASThitv6.GetShrapnelTickInterval(_modifier)
    return LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL
end

function LASThitv6.GetShrapnelPulse(target, now)
    if not target then
        return nil
    end

    local target_index = get_entity_index(target)
    local pulse = LASThitv6.active_shrapnel_pulses[target_index]
    if not pulse then
        return nil
    end

    now = now or get_time()
    local interval = math.max(0.001, tonumber(pulse.interval or LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL) or LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL)
    local first_hit_time = tonumber(pulse.first_hit_time or pulse.last_hit_time or 0) or 0
    local expires_at = tonumber(pulse.expires_at or 0) or 0
    if first_hit_time <= 0 or expires_at <= now - LASThitv6.SHRAPNEL_PULSE_EXPIRE_GRACE then
        LASThitv6.active_shrapnel_pulses[target_index] = nil
        return nil
    end

    local next_hit_time = first_hit_time + interval
    while next_hit_time <= now + 0.001 do
        next_hit_time = next_hit_time + interval
    end

    if next_hit_time > expires_at + LASThitv6.SHRAPNEL_PULSE_EXPIRE_GRACE then
        LASThitv6.active_shrapnel_pulses[target_index] = nil
        return nil
    end

    pulse.next_hit_time = next_hit_time
    return pulse
end

function LASThitv6.GetShrapnelNextTickTime(modifier, now, target)
    local pulse = LASThitv6.GetShrapnelPulse(target, now)
    if pulse then
        local interval = math.max(0.001, tonumber(pulse.interval or LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL) or LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL)
        local next_tick = tonumber(pulse.next_hit_time or 0) or 0
        while next_tick <= now + 0.001 do
            next_tick = next_tick + interval
        end

        return next_tick, interval
    end

    local interval = LASThitv6.GetShrapnelTickInterval(modifier)
    local previous_tick = tonumber(safe_call(Modifier.GetPreviousTick, modifier) or 0) or 0
    local creation_time = tonumber(safe_call(Modifier.GetCreationTime, modifier) or 0) or 0
    local next_tick = 0

    if previous_tick > 0 and previous_tick <= now + interval then
        next_tick = previous_tick + interval
    elseif creation_time > 0 then
        next_tick = creation_time + interval
    else
        next_tick = now + interval
    end

    while next_tick <= now + 0.001 do
        next_tick = next_tick + interval
    end

    return next_tick, interval
end

function LASThitv6.GetAbilityNamedValue(ability, names)
    if not ability or not Ability then
        return 0
    end

    for i = 1, #(names or {}) do
        local value = tonumber(safe_call(Ability.GetLevelSpecialValueFor, ability, names[i], -1) or 0) or 0
        if value > 0 then
            return value
        end

        value = tonumber(safe_call(Ability.GetSpecialValueFor, ability, names[i]) or 0) or 0
        if value > 0 then
            return value
        end
    end

    return 0
end

function LASThitv6.GetAbilitySpecialValue(ability, names)
    local value = LASThitv6.GetAbilityNamedValue(ability, names)
    if value > 0 then
        return value
    end

    return tonumber(safe_call(Ability.GetDamage, ability) or 0) or 0
end

function LASThitv6.GetShrapnelDurationAfterPulse(ability)
    local duration = LASThitv6.GetAbilityNamedValue(ability, LASThitv6.SHRAPNEL_DURATION_VALUE_NAMES)
    local damage_delay = LASThitv6.GetAbilityNamedValue(ability, LASThitv6.SHRAPNEL_DAMAGE_DELAY_VALUE_NAMES)
    if duration > 0 then
        return math.max(0.050, duration - math.max(0, damage_delay))
    end

    return LASThitv6.SHRAPNEL_FALLBACK_DURATION_AFTER_PULSE
end

function LASThitv6.GetShrapnelDamagePerTick(target, modifier, interval)
    local ability = safe_call(Modifier.GetAbility, modifier)
    local damage_per_second = LASThitv6.GetAbilitySpecialValue(ability, LASThitv6.SHRAPNEL_SPECIAL_VALUE_NAMES)
    if damage_per_second <= 0 then
        return 0
    end

    local damage = damage_per_second * math.max(0.001, interval or LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL)
    local magic_multiplier = tonumber(safe_call(NPC.GetMagicalArmorDamageMultiplier, target) or 1) or 1
    return math.max(1, math.floor((damage * magic_multiplier) + 0.0001))
end

function LASThitv6.GetShadowStrikeModifier(creep)
    if not creep or not NPC or not Modifier then
        return nil, nil
    end

    local modifier = safe_call(NPC.GetModifier, creep, LASThitv6.SHADOW_STRIKE_MODIFIER_NAME)
    if modifier then
        return modifier, LASThitv6.SHADOW_STRIKE_MODIFIER_NAME
    end

    return nil, nil
end

function LASThitv6.GetShadowStrikeTickInterval(modifier)
    local ability = safe_call(Modifier.GetAbility, modifier)
    local interval = LASThitv6.GetAbilityNamedValue(ability, LASThitv6.SHADOW_STRIKE_INTERVAL_VALUE_NAMES)
    if interval <= 0 then
        return LASThitv6.SHADOW_STRIKE_FALLBACK_INTERVAL
    end

    return interval
end

function LASThitv6.GetShadowStrikeEndTime(modifier)
    local end_time = LASThitv6.GetModifierEndTime(modifier)
    if end_time then
        return end_time
    end

    local ability = safe_call(Modifier.GetAbility, modifier)
    local duration = LASThitv6.GetAbilityNamedValue(ability, LASThitv6.SHADOW_STRIKE_DURATION_VALUE_NAMES)
    if duration <= 0 then
        duration = LASThitv6.SHADOW_STRIKE_FALLBACK_DURATION
    end

    local creation_time = tonumber(safe_call(Modifier.GetCreationTime, modifier) or 0) or 0
    if creation_time > 0 then
        return creation_time + duration
    end

    return nil
end

function LASThitv6.GetShadowStrikeNextTickTime(modifier, now)
    local interval = LASThitv6.GetShadowStrikeTickInterval(modifier)
    local creation_time = tonumber(safe_call(Modifier.GetCreationTime, modifier) or 0) or 0
    local next_tick = creation_time > 0 and (creation_time + interval) or (now + interval)

    while next_tick <= now + 0.001 do
        next_tick = next_tick + interval
    end

    return next_tick, interval, creation_time
end

function LASThitv6.GetShadowStrikeDamagePerTick(target, modifier)
    local ability = safe_call(Modifier.GetAbility, modifier)
    local damage = LASThitv6.GetAbilityNamedValue(ability, LASThitv6.SHADOW_STRIKE_DAMAGE_VALUE_NAMES)
    if damage <= 0 then
        return 0
    end

    local magic_multiplier = tonumber(safe_call(NPC.GetMagicalArmorDamageMultiplier, target) or 1) or 1
    return math.max(1, math.floor((damage * magic_multiplier) + 0.0001))
end

function LASThitv6.AddShadowStrikeDamageEvents(hero, now, target_is_friendly, events)
    local units = Entity.GetUnitsInRadius(hero, ui.work_radius:Get(), Enum.TeamType.TEAM_BOTH, false, true)

    for i = 1, #units do
        local target = units[i]
        local target_valid = target
            and Entity.IsNPC(target) == true
            and NPC.IsCreep(target) == true
            and Entity.IsAlive(target) == true
            and Entity.IsSameTeam(hero, target) == target_is_friendly
        if target_valid then
            local modifier, modifier_name = LASThitv6.GetShadowStrikeModifier(target)
            if modifier then
                local hit_time, interval, creation_time = LASThitv6.GetShadowStrikeNextTickTime(modifier, now)
                local end_time = LASThitv6.GetShadowStrikeEndTime(modifier)
                local damage = LASThitv6.GetShadowStrikeDamagePerTick(target, modifier)
                local target_index = get_entity_index(target)
                local caster = safe_call(Modifier.GetCaster, modifier)
                local source_index = caster and get_entity_index(caster) or target_index
                local ticks_added = 0

                while damage > 0
                    and hit_time
                    and (not end_time or hit_time <= end_time + PREDICTION_INCOMING_EXPIRE_GRACE)
                    and hit_time - now <= PREDICTION_FUTURE_ATTACK_HORIZON
                    and ticks_added < LASThitv6.SHADOW_STRIKE_MAX_TICKS
                do
                    events[#events + 1] = {
                        kind = "shadow_strike_tick",
                        source_index = source_index,
                        target_index = target_index,
                        hit_time = hit_time,
                        damage = damage,
                        damage_min = damage,
                        damage_max = damage,
                        modifier_name = modifier_name,
                        interval = interval,
                        creation_time = creation_time,
                        expires_at = end_time,
                    }

                    ticks_added = ticks_added + 1
                    hit_time = hit_time + interval
                end
            end
        end
    end
end

function LASThitv6.AddShrapnelDamageEvents(hero, now, target_is_friendly, events)
    local units = Entity.GetUnitsInRadius(hero, ui.work_radius:Get(), Enum.TeamType.TEAM_BOTH, false, true)

    for i = 1, #units do
        local target = units[i]
        local target_valid = target
            and Entity.IsNPC(target) == true
            and NPC.IsCreep(target) == true
            and Entity.IsAlive(target) == true
            and Entity.IsSameTeam(hero, target) == target_is_friendly
        if target_valid then
            local modifier, modifier_name = LASThitv6.GetShrapnelModifier(target)
            local pulse = LASThitv6.GetShrapnelPulse(target, now)
            if modifier or pulse then
                local hit_time, interval = nil, nil
                local damage = 0
                local end_time = nil
                local target_index = get_entity_index(target)
                local source_index = target_index
                local ticks_added = 0

                if pulse then
                    hit_time = tonumber(pulse.next_hit_time or 0) or 0
                    interval = tonumber(pulse.interval or LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL) or LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL
                    damage = tonumber(pulse.damage or 0) or 0
                    end_time = tonumber(pulse.expires_at or 0) or 0
                    source_index = tonumber(pulse.source_index or target_index) or target_index
                    modifier_name = tostring(pulse.modifier_name or modifier_name or LASThitv6.SHRAPNEL_MODIFIER_NAME)
                elseif modifier then
                    hit_time, interval = LASThitv6.GetShrapnelNextTickTime(modifier, now, target)
                    damage = LASThitv6.GetShrapnelDamagePerTick(target, modifier, interval)
                    end_time = LASThitv6.GetModifierEndTime(modifier)
                    local caster = safe_call(Modifier.GetCaster, modifier)
                    source_index = caster and get_entity_index(caster) or target_index
                    modifier_name = modifier_name or LASThitv6.SHRAPNEL_MODIFIER_NAME
                end

                while damage > 0
                    and hit_time
                    and (not end_time or hit_time <= end_time + PREDICTION_INCOMING_EXPIRE_GRACE)
                    and hit_time - now <= PREDICTION_FUTURE_ATTACK_HORIZON
                    and ticks_added < LASThitv6.SHRAPNEL_MAX_TICKS
                do
                    events[#events + 1] = {
                        kind = "shrapnel_tick",
                        source_index = source_index,
                        target_index = target_index,
                        hit_time = hit_time,
                        damage = damage,
                        damage_min = damage,
                        damage_max = damage,
                        modifier_name = modifier_name,
                        interval = interval,
                        first_hit_time = pulse and pulse.first_hit_time or nil,
                        expires_at = end_time,
                    }

                    ticks_added = ticks_added + 1
                    hit_time = hit_time + interval
                end
            end
        end
    end
end

local function is_attack_animation_event(data, unit)
    local activity = tonumber(data and data.activity or 0) or 0
    if Enum and Enum.GameActivity then
        if activity == Enum.GameActivity.ACT_DOTA_ATTACK
            or activity == Enum.GameActivity.ACT_DOTA_ATTACK2
            or activity == Enum.GameActivity.ACT_DOTA_ATTACK_EVENT
            or activity == Enum.GameActivity.ACT_DOTA_ATTACK_EVENT_BASH
            or activity == Enum.GameActivity.ACT_DOTA_ATTACK_SPECIAL
        then
            return true
        end
    end

    local sequence_name = string.lower(tostring(data and data.sequenceName or ""))
    if sequence_name:find("attack", 1, true) then
        return true
    end

    return unit and safe_call(NPC.IsAttacking, unit) == true
end

local function get_debug_target_text(hero, target)
    local health = math.floor((tonumber(Entity.GetHealth(target) or 0) or 0) + 0.5)
    local min_damage = LASThitv6.GetEffectiveMinAttackDamageVsTarget(hero, target, get_time())
    return ("%s#%d hp=%d min=%d"):format(
        get_creep_name(target),
        get_entity_index(target),
        health,
        min_damage
    )
end

function LASThitv6.IsSyncAttackEnabled()
    return ui.sync_attack and ui.sync_attack:Get() == true
end

function LASThitv6.IsSyncAttackUnit(local_hero, unit)
    if not local_hero or not unit or unit == local_hero then
        return false
    end
    if get_entity_index(unit) == get_entity_index(local_hero) then
        return false
    end
    if Entity.IsAlive(unit) ~= true then
        return false
    end
    if not Entity.IsHero or Entity.IsHero(unit) ~= true then
        return false
    end
    if safe_call(NPC.IsIllusion, unit) == true then
        return false
    end

    local player_id = Hero and Hero.GetPlayerID and safe_call(Hero.GetPlayerID, local_hero) or nil
    if player_id ~= nil and Entity.IsControllableByPlayer then
        return safe_call(Entity.IsControllableByPlayer, unit, player_id) == true
    end

    return Entity.IsSameTeam(local_hero, unit) == true
end

function LASThitv6.IsSyncAttackReady(unit, now)
    local unit_index = unit and get_entity_index(unit) or 0
    if unit_index <= 0 then
        return false, 0
    end

    now = tonumber(now or get_time()) or get_time()
    local ready_until = tonumber(LASThitv6.sync_attack_ready_until[unit_index] or 0) or 0
    if ready_until <= now then
        LASThitv6.sync_attack_ready_until[unit_index] = nil
        return true, 0
    end

    return false, ready_until - now
end

function LASThitv6.GetSyncAttackUnits(local_hero, target, now, desired_impact_time, allow_queued_replacement)
    if not LASThitv6.IsSyncAttackEnabled() or not local_hero or not target then
        return {}
    end

    local candidates = {}
    local seen = {}
    local function append_units(units)
        if not units then
            return
        end
        for key, value in pairs(units) do
            local unit = LASThitv6.ResolveLiveUnit(value) or LASThitv6.ResolveLiveUnit(key)
            local index = unit and get_entity_index(unit) or 0
            if index > 0 and not seen[index] then
                seen[index] = true
                candidates[#candidates + 1] = unit
            end
        end
    end

    append_units(Heroes and Heroes.GetAll and safe_call(Heroes.GetAll) or nil)
    append_units(NPCs and NPCs.GetAll and safe_call(NPCs.GetAll) or nil)

    local result = {}
    local target_is_friendly = Entity.IsSameTeam(local_hero, target) == true
    local target_index = get_entity_index(target)
    for i = 1, #candidates do
        local unit = candidates[i]
        if LASThitv6.IsSyncAttackUnit(local_hero, unit)
            and safe_call(NPC.IsAttacking, unit) ~= true
        then
            local unit_index = get_entity_index(unit)
            local failed_until = LASThitv6.sync_attack_fail_until[unit_index] or 0
            local pending = LASThitv6.sync_attack_pending[unit_index]
            local last_issue = LASThitv6.sync_attack_last_issue[unit_index] or 0
            local ready = LASThitv6.IsSyncAttackReady(unit, now)
            local queued_index, queued_item = LASThitv6.GetQueuedSyncAttackIndex(unit_index, target_index)
            local unit_is_queued = LASThitv6.HasQueuedSyncAttackForUnit(unit_index)
            local queued_can_replace = queued_item
                and allow_queued_replacement == true
                and LASThitv6.ShouldReplaceQueuedSyncAttack(queued_item, desired_impact_time)
            if failed_until <= now
                and not pending
                and ready
                and now - last_issue >= ATTACK_ORDER_INTERVAL
                and (not unit_is_queued or queued_can_replace)
            then
                local attack_delay, approach_time, distance, reach, gap, in_range, move_speed =
                    LASThitv6.GetSyncPredictionAttackDelay(unit, target)
                local execute_time = desired_impact_time and (desired_impact_time - attack_delay) or now
                local execute_late = now - execute_time
                local execute_wait = execute_time - now
                if (not desired_impact_time and in_range)
                    or (desired_impact_time
                        and execute_late <= LASThitv6.SYNC_ATTACK_MAX_LATE
                        and execute_wait <= LASThitv6.SYNC_ATTACK_MAX_QUEUE_TIME)
                then
                    local damage_min, damage_max = get_attack_damage_range_vs_target(unit, target)
                    result[#result + 1] = {
                        unit = unit,
                        index = get_entity_index(unit),
                        target_is_friendly = target_is_friendly,
                        damage_min = damage_min,
                        damage_max = damage_max,
                        attack_delay = attack_delay,
                        approach_time = approach_time,
                        execute_time = execute_time,
                        execute_late = execute_late,
                        execute_wait = execute_wait,
                        distance = distance,
                        reach = reach,
                        gap = gap,
                        in_range = in_range,
                        move_speed = move_speed,
                    }
                end
            end
        end
    end

    table.sort(result, function(a, b)
        return (a.execute_time or now) < (b.execute_time or now)
    end)

    return result
end

function LASThitv6.GetNeededSyncAttackUnits(hero, target, now, desired_impact_time, target_health_override, allow_queued_replacement)
    if not hero or not target then
        return {}, 0, 0, 0
    end

    local min_damage, max_damage = get_attack_damage_range_vs_target(hero, target)
    if not LASThitv6.IsSyncAttackEnabled() then
        return {}, min_damage, max_damage, 0
    end

    local health = tonumber(target_health_override or Entity.GetHealth(target) or 0) or 0
    if health <= 0 or health <= min_damage then
        return {}, min_damage, max_damage, 0
    end

    local selected_units = {}
    local sync_units = LASThitv6.GetSyncAttackUnits(hero, target, now or get_time(), desired_impact_time, allow_queued_replacement)
    for i = 1, math.min(#sync_units, LASThitv6.SYNC_ATTACK_MAX_UNITS) do
        local item = sync_units[i]
        selected_units[#selected_units + 1] = item
        min_damage = min_damage + item.damage_min
        max_damage = max_damage + item.damage_max
        if min_damage >= health then
            break
        end
    end

    return selected_units, min_damage, max_damage, #selected_units
end

function LASThitv6.GetEffectiveAttackDamageRange(hero, target, now, desired_impact_time, target_health_override)
    local _, min_damage, max_damage, sync_count = LASThitv6.GetNeededSyncAttackUnits(hero, target, now, desired_impact_time, target_health_override)
    local scheduled_min, scheduled_max, scheduled_count = LASThitv6.GetScheduledSyncDamageForTarget(target, desired_impact_time)
    min_damage = min_damage + scheduled_min
    max_damage = max_damage + scheduled_max
    sync_count = (sync_count or 0) + scheduled_count
    return min_damage, max_damage, sync_count
end

function LASThitv6.GetEffectiveMinAttackDamageVsTarget(hero, target, now, desired_impact_time, target_health_override)
    local min_damage = LASThitv6.GetEffectiveAttackDamageRange(hero, target, now, desired_impact_time, target_health_override)
    return min_damage
end

local function get_creeps_in_radius(hero, radius)
    local creeps = {}
    local units = Entity.GetUnitsInRadius(hero, radius, Enum.TeamType.TEAM_BOTH, false, true)
    local now = get_time()

    for i = 1, #units do
        local unit = units[i]
        if NPC.IsCreep(unit) == true and Entity.IsAlive(unit) == true then
            local health = tonumber(Entity.GetHealth(unit) or 0) or 0
            local max_health = tonumber(Entity.GetMaxHealth(unit) or 0) or 0
            local min_damage, _, sync_attack_count = LASThitv6.GetEffectiveAttackDamageRange(hero, unit, now)
            local is_friendly = Entity.IsSameTeam(hero, unit) == true
            local glyph_shield_end_time, glyph_modifier_name = LASThitv6.GetGlyphShieldEndTime(unit, now)
            local has_glyph_shield = glyph_shield_end_time ~= nil
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
                sync_attack_count = sync_attack_count,
                is_killable = (is_last_hittable or is_deniable) and not has_glyph_shield,
                is_last_hittable = is_last_hittable,
                is_deniable = is_deniable,
                has_glyph_shield = has_glyph_shield,
                glyph_shield_end_time = glyph_shield_end_time,
                glyph_modifier_name = glyph_modifier_name,
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

function LASThitv6.GetAttackRangeColor()
    return ui.attack_range_color:Get() or LASThitv6.DEFAULT_ATTACK_RANGE_COLOR
end

function LASThitv6.GetRadiusParticlePath(particle_name)
    if type(LIB_HEROES_DATA) == "table" and type(LIB_HEROES_DATA.particles_path_for_radius) == "table" then
        local path = LIB_HEROES_DATA.particles_path_for_radius[particle_name]
        if type(path) == "string" and path ~= "" then
            return path
        end
    end

    return LASThitv6.RADIUS_PARTICLE_FALLBACK_PATHS[particle_name]
end

function LASThitv6.GetRadiusParticleSelection(combo)
    local names = LASThitv6.GetRadiusParticleNames()
    if not combo or not combo.Get then
        return names[1] or "Dota"
    end

    local value = combo:Get()
    if type(value) == "string" then
        return value
    end

    local index = tonumber(value or 0) or 0
    return names[index + 1] or names[index] or names[1] or "Dota"
end

function LASThitv6.DestroyRadiusParticle(key)
    local data = LASThitv6.radius_particles[key]
    if data and data.fx and Particle and Particle.Destroy then
        safe_call(Particle.Destroy, data.fx)
    end
    LASThitv6.radius_particles[key] = nil
end

function LASThitv6.DestroyRadiusParticles()
    LASThitv6.DestroyRadiusParticle("work")
    LASThitv6.DestroyRadiusParticle("attack")
end

function LASThitv6.SetRadiusParticleControl(fx, color, radius, target)
    if not fx or not Particle or not Particle.SetControlPoint then
        return
    end

    color = color or Color(255, 255, 255, 255)
    radius = math.max(0, tonumber(radius or 0) or 0)
    if target and safe_call(Entity.IsEntity, target) ~= true then
        local z = tonumber(safe_call(World.GetGroundZ, target.x, target.y) or target.z) or target.z
        local center = Vector(target.x, target.y, z + RADIUS_PARTICLE_GROUND_OFFSET)
        safe_call(Particle.SetControlPoint, fx, 0, center)
    end
    safe_call(Particle.SetControlPoint, fx, 1, Vector(color.r or 255, color.g or 255, color.b or 255))
    safe_call(Particle.SetControlPoint, fx, 2, Vector(radius, color.a or 255, 0))
    safe_call(Particle.SetControlPoint, fx, 3, Vector(1, 0, 0))
end

function LASThitv6.UpdateRadiusParticle(key, combo, color, radius, target)
    if not Particle or not Particle.Create or not target then
        local now = get_time and get_time() or 0
        if ui and ui.debug and ui.debug:Get() and (LASThitv6.radius_particle_fail_log_until[key] or 0) <= now then
            LASThitv6.radius_particle_fail_log_until[key] = now + 1.000
            debug_log(("RADIUS_PARTICLE_FALLBACK key=%s reason=api_unavailable"):format(tostring(key)))
        end
        return false
    end

    local particle_name = LASThitv6.GetRadiusParticleSelection(combo)
    local path = LASThitv6.GetRadiusParticlePath(particle_name)
    if not path then
        local now = get_time and get_time() or 0
        if ui and ui.debug and ui.debug:Get() and (LASThitv6.radius_particle_fail_log_until[key] or 0) <= now then
            LASThitv6.radius_particle_fail_log_until[key] = now + 1.000
            debug_log(("RADIUS_PARTICLE_FALLBACK key=%s reason=missing_path particle=%s"):format(tostring(key), tostring(particle_name)))
        end
        return false
    end

    local target_index = 0
    if safe_call(Entity.IsEntity, target) == true then
        target_index = get_entity_index(target)
    end

    local data = LASThitv6.radius_particles[key]
    if not data or data.path ~= path or data.target_index ~= target_index then
        LASThitv6.DestroyRadiusParticle(key)
        local center = target
        local attachment = Enum
            and Enum.ParticleAttachment
            and Enum.ParticleAttachment.PATTACH_ABSORIGIN_FOLLOW
            or 0
        local create_target = target
        if safe_call(Entity.IsEntity, target) ~= true then
            create_target = center
        end
        local fx = safe_call(Particle.Create, path, attachment, create_target)
        if not fx then
            local now = get_time and get_time() or 0
            if ui and ui.debug and ui.debug:Get() and (LASThitv6.radius_particle_fail_log_until[key] or 0) <= now then
                LASThitv6.radius_particle_fail_log_until[key] = now + 1.000
                debug_log(("RADIUS_PARTICLE_FALLBACK key=%s reason=create_failed particle=%s path=%s attachment=%s"):format(
                    tostring(key),
                    tostring(particle_name),
                    tostring(path),
                    tostring(attachment)
                ))
            end
            return false
        end
        data = {
            fx = fx,
            path = path,
            particle_name = particle_name,
            target_index = target_index,
        }
        LASThitv6.radius_particles[key] = data
    end

    LASThitv6.SetRadiusParticleControl(data.fx, color, radius, target)
    data.color = color
    data.radius = radius
    return true
end

function LASThitv6.GetHeroAttackRange(hero)
    local attack_range = tonumber(NPC.GetAttackRange(hero) or 0) or 0
    local attack_range_bonus = tonumber(NPC.GetAttackRangeBonus(hero) or 0) or 0
    return math.max(0, attack_range + attack_range_bonus)
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
    local damage_min, damage_max = get_attack_damage_range_vs_target(source, target)
    active_melee_swings[get_entity_index(source)] = {
        source_index = get_entity_index(source),
        target_index = get_entity_index(target),
        hit_time = hit_time,
        damage = damage_min,
        damage_min = damage_min,
        damage_max = damage_max,
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
        next_attack_start = attack_start + attack_period,
        attack_period = attack_period,
        is_ranged = NPC.IsRanged(source) == true,
        is_tower = NPC.IsTower(source) == true,
    }
end

local function set_projectile_hit_timer(source, target, impact_time)
    local damage_min, damage_max = get_attack_damage_range_vs_target(source, target)
    active_projectiles[get_entity_index(source)] = {
        source_index = get_entity_index(source),
        target_index = get_entity_index(target),
        impact_time = impact_time,
        damage = damage_min,
        damage_min = damage_min,
        damage_max = damage_max,
        is_tower = NPC.IsTower(source) == true,
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

local function draw_tower_hit_timers()
    local now = get_time()

    for source_index, projectile in pairs(active_projectiles) do
        if projectile.is_tower == true then
            local tower = get_live_npc_by_index(source_index)
            local seconds_left = projectile.impact_time - now
            if not tower or seconds_left <= 0 then
                active_projectiles[source_index] = nil
            elseif not draw_hit_timer(projectile.target_index, "Tower Hit In", seconds_left, TOWER_HIT_TEXT_COLOR, 84) then
                active_projectiles[source_index] = nil
            end
        end
    end

    for source_index, clock in pairs(creep_attack_clocks) do
        if clock.is_tower == true then
            local tower = get_live_npc_by_index(source_index)
            local target = get_live_npc_by_index(clock.target_index)
            local projectile = active_projectiles[source_index]
            local has_exact_projectile = projectile
                and projectile.target_index == clock.target_index
                and projectile.impact_time > now

            if not tower or not target then
                creep_attack_clocks[source_index] = nil
            elseif not has_exact_projectile and get_future_attack_hit_time then
                local hit_time = get_future_attack_hit_time(tower, target, clock.next_attack_start)
                local seconds_left = hit_time and (hit_time - now) or 0
                if seconds_left <= 0 then
                    creep_attack_clocks[source_index] = nil
                elseif not draw_hit_timer(clock.target_index, "Tower Hit In", seconds_left, TOWER_HIT_TEXT_COLOR, 84) then
                    creep_attack_clocks[source_index] = nil
                end
            end
        end
    end
end

function LASThitv6.DrawGlyphShieldTimers(creeps)
    local now = get_time()

    for i = 1, #creeps do
        local creep = creeps[i]
        local shield_end_time = creep.glyph_shield_end_time
        if shield_end_time and shield_end_time > now then
            draw_hit_timer(creep.index, "Glyph Ends In", shield_end_time - now, GLYPH_HIT_TEXT_COLOR, 102)
        end
    end
end

function LASThitv6.DrawShrapnelTickTimers(creeps)
    local now = get_time()

    for i = 1, #creeps do
        local creep = creeps[i]
        local modifier = LASThitv6.GetShrapnelModifier(creep.npc)
        local pulse = LASThitv6.GetShrapnelPulse(creep.npc, now)
        if modifier or pulse then
            local hit_time = pulse and pulse.next_hit_time or LASThitv6.GetShrapnelNextTickTime(modifier, now, creep.npc)
            if hit_time and hit_time >= now - LASThitv6.SHRAPNEL_PULSE_EXPIRE_GRACE then
                draw_hit_timer(creep.index, "Shrapnel Tick In", hit_time - now, GLYPH_HIT_TEXT_COLOR, 120)
            end
        end
    end
end

function LASThitv6.DrawShadowStrikeTickTimers(creeps)
    local now = get_time()

    for i = 1, #creeps do
        local creep = creeps[i]
        local modifier = LASThitv6.GetShadowStrikeModifier(creep.npc)
        if modifier then
            local hit_time = LASThitv6.GetShadowStrikeNextTickTime(modifier, now)
            local end_time = LASThitv6.GetShadowStrikeEndTime(modifier)
            if hit_time and (not end_time or hit_time <= end_time + PREDICTION_INCOMING_EXPIRE_GRACE) then
                draw_hit_timer(creep.index, "Shadow Tick In", hit_time - now, GLYPH_HIT_TEXT_COLOR, 138)
            end
        end
    end
end

local function draw_attack_hit_timers(creeps)
    for i = 1, #creeps do
        draw_melee_hit_timer(creeps[i])
        draw_projectile_hit_timer(creeps[i])
    end
    draw_tower_hit_timers()
    LASThitv6.DrawGlyphShieldTimers(creeps)
    LASThitv6.DrawShrapnelTickTimers(creeps)
    LASThitv6.DrawShadowStrikeTickTimers(creeps)
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

function LASThitv6.ClearMeleeHardLock(reason)
    local had_lock = (tonumber(LASThitv6.melee_hard_lock_until or 0) or 0) > get_time()
    LASThitv6.melee_hard_lock_until = 0
    LASThitv6.melee_hard_lock_target_index = nil
    LASThitv6.melee_hard_lock_unit_indexes = {}
    LASThitv6.melee_hard_lock_block_log_until = 0
    if had_lock and reason then
        debug_log(("MELEE_HARD_LOCK_CLEAR reason=%s"):format(tostring(reason)))
    end
end

function LASThitv6.IsMeleeHardLocked(now)
    now = tonumber(now or get_time()) or get_time()
    local locks = LASThitv6.melee_hard_lock_unit_indexes or {}
    local active_count = 0
    local max_until = 0
    local last_target_index = nil

    for unit_index, lock in pairs(locks) do
        local until_time = tonumber(lock and lock.until_time or 0) or 0
        local target_index = lock and lock.target_index or nil
        local target = target_index and get_live_npc_by_index(target_index) or nil
        if until_time <= now or not target then
            locks[unit_index] = nil
        else
            active_count = active_count + 1
            max_until = math.max(max_until, until_time)
            last_target_index = target_index
        end
    end

    LASThitv6.melee_hard_lock_until = max_until
    LASThitv6.melee_hard_lock_target_index = last_target_index

    if active_count <= 0 then
        LASThitv6.ClearMeleeHardLock(nil)
        return false
    end

    return true
end

function LASThitv6.GetUnitIndexesForHardLock(units)
    local indexes = {}
    local function add_unit(value)
        local unit = LASThitv6.ResolveLiveUnit(value)
        if unit then
            indexes[get_entity_index(unit)] = true
        end
    end

    if type(units) == "table" then
        for key, unit in pairs(units) do
            add_unit(unit)
            add_unit(key)
        end
    else
        add_unit(units)
    end

    return indexes
end

function LASThitv6.LockMeleeHardTarget(target, until_time, reason, units, attack_units)
    local now = get_time()
    until_time = tonumber(until_time or 0) or 0
    if not target or until_time <= now then
        LASThitv6.ClearMeleeHardLock("invalid_lock")
        return
    end
    if units == nil then
        units = get_local_hero()
    end

    until_time = until_time + LASThitv6.MELEE_HARD_LOCK_EXTRA
    local target_index = get_entity_index(target)
    local old_until = tonumber(LASThitv6.melee_hard_lock_until or 0) or 0
    local old_target_index = LASThitv6.melee_hard_lock_target_index
    LASThitv6.melee_hard_lock_target_index = target_index
    LASThitv6.melee_hard_lock_until = old_target_index == target_index and math.max(old_until, until_time) or until_time
    LASThitv6.melee_hard_lock_unit_indexes = LASThitv6.melee_hard_lock_unit_indexes or {}

    local unit_indexes = LASThitv6.GetUnitIndexesForHardLock(units)
    local attack_unit_indexes = LASThitv6.GetUnitIndexesForHardLock(attack_units)
    local has_attack_units = attack_units ~= nil
    local unit_count = 0
    for unit_index in pairs(unit_indexes) do
        local existing = LASThitv6.melee_hard_lock_unit_indexes[unit_index] or {}
        local should_attack = existing.target_index == target_index and existing.attack == true
        if has_attack_units then
            should_attack = should_attack or attack_unit_indexes[unit_index] == true
        end
        LASThitv6.melee_hard_lock_unit_indexes[unit_index] = {
            target_index = target_index,
            until_time = LASThitv6.melee_hard_lock_until,
            attack = should_attack,
            next_order_time = existing.next_order_time or (now + LASThitv6.MELEE_HARD_LOCK_REISSUE_INITIAL_DELAY),
        }
        unit_count = unit_count + 1
    end

    if unit_count > 0 and (old_target_index ~= target_index or old_until <= now) then
        local hero = get_local_hero()
        debug_log(("MELEE_HARD_LOCK target=%s units=%d until_in=%.4f reason=%s"):format(
            hero and get_debug_target_text(hero, target) or ("index=" .. tostring(target_index)),
            unit_count,
            LASThitv6.melee_hard_lock_until - now,
            tostring(reason or "attack")
        ))
    end
end

function LASThitv6.ClearMeleeSwingLock()
    LASThitv6.melee_swing_lock_until = 0
    LASThitv6.melee_swing_lock_target_index = nil
end

function LASThitv6.LockMeleeSwingUntil(target, impact_time)
    impact_time = tonumber(impact_time or 0) or 0
    if not target or impact_time <= get_time() then
        LASThitv6.ClearMeleeSwingLock()
        return
    end

    LASThitv6.melee_swing_lock_until = impact_time + ATTACK_ORDER_FIXED_LEAD
    LASThitv6.melee_swing_lock_target_index = get_entity_index(target)
    LASThitv6.LockMeleeHardTarget(target, LASThitv6.melee_swing_lock_until, "swing")
end

function LASThitv6.IsMeleeSwingLocked(now)
    now = tonumber(now or get_time()) or get_time()
    local lock_until = tonumber(LASThitv6.melee_swing_lock_until or 0) or 0
    if lock_until <= now then
        LASThitv6.ClearMeleeSwingLock()
        return false
    end

    return true
end

local function clear_attack_confirmation()
    attack_confirmation_until = 0
    attack_confirmation_target_index = nil
    attack_confirmation_target_is_friendly = false
    attack_confirmation_issue_time = 0
    attack_confirmation_order_seen = false
    LASThitv6.attack_confirmation_start_check_until = 0
    LASThitv6.attack_confirmation_started = false
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
    pending_attack_attack_delay = 0
    pending_attack_move_lock_logged = false
    LASThitv6.pending_attack_preposition_logged = false
    clear_attack_confirmation()
end

local function clear_pending_orders()
    clear_pending_move()
    clear_pending_attack()
    LASThitv6.sync_attack_queue = {}
    LASThitv6.sync_attack_pending = {}
    LASThitv6.sync_attack_fail_until = {}
    LASThitv6.sync_attack_ready_until = {}
    LASThitv6.ClearMeleeSwingLock()
    LASThitv6.ClearMeleeHardLock(nil)
end

local function clear_attack_hit_timers()
    active_projectiles = {}
    active_melee_swings = {}
    creep_attack_clocks = {}
    our_pending_hits = {}
    active_setup_hits = {}
    LASThitv6.active_shrapnel_pulses = {}
    last_attack_issue = nil
    missed_prediction_logs = {}
    LASThitv6.sync_attack_ready_until = {}
    LASThitv6.pending_attack_preposition_logged = false
    LASThitv6.ClearMeleeSwingLock()
    LASThitv6.ClearMeleeHardLock(nil)
end

local function schedule_move_to_cursor(now)
    pending_move_position = Input.GetWorldCursorPos()
    pending_move_execute_time = now
    next_move_schedule_time = now + MOVE_ORDER_INTERVAL
end

function LASThitv6.GetSelectedMoveUnits(player, hero)
    if not player or not Player or not Player.GetSelectedUnits then
        return hero, hero and 1 or 0
    end

    local selected = safe_call(Player.GetSelectedUnits, player)
    if type(selected) ~= "table" then
        return hero, hero and 1 or 0
    end

    local units = {}
    local seen = {}
    local player_id = hero and Hero and Hero.GetPlayerID and safe_call(Hero.GetPlayerID, hero) or nil

    local function add_selected(value, key)
        local unit = LASThitv6.ResolveLiveUnit(value) or LASThitv6.ResolveLiveUnit(key)
        local index = unit and get_entity_index(unit) or 0
        if index <= 0 or seen[index] then
            return
        end

        local allowed = true
        if hero and Entity.IsSameTeam then
            allowed = safe_call(Entity.IsSameTeam, hero, unit) == true
        end
        if allowed and player_id ~= nil and Entity.IsControllableByPlayer then
            allowed = safe_call(Entity.IsControllableByPlayer, unit, player_id) == true
        end
        if allowed then
            seen[index] = true
            units[#units + 1] = unit
        end
    end

    for key, value in pairs(selected) do
        add_selected(value, key)
    end

    if #units > 0 then
        return units, #units
    end

    return hero, hero and 1 or 0
end

function LASThitv6.ExecuteSelectedMoveOrder(player, hero, position)
    if not player or not position or not Player or not Player.PrepareUnitOrders then
        return false, "missing_api", "none"
    end

    local move_units, move_unit_count = LASThitv6.GetSelectedMoveUnits(player, hero)
    move_unit_count = tonumber(move_unit_count or 0) or 0
    local hard_locked = LASThitv6.IsMeleeHardLocked(get_time())
    if hard_locked then
        local locks = LASThitv6.melee_hard_lock_unit_indexes or {}
        local filtered_units = {}
        local seen = {}
        local function add_unlocked(value)
            local unit = LASThitv6.ResolveLiveUnit(value)
            local index = unit and get_entity_index(unit) or 0
            if index > 0 and not seen[index] and not locks[index] then
                seen[index] = true
                filtered_units[#filtered_units + 1] = unit
            end
        end

        if type(move_units) == "table" then
            for _, unit in pairs(move_units) do
                add_unlocked(unit)
            end
        else
            add_unlocked(move_units)
        end

        move_unit_count = #filtered_units
        if move_unit_count <= 0 then
            return false, "all_selected_units_hard_locked", "hard_lock"
        end
        move_units = move_unit_count == 1 and filtered_units[1] or filtered_units
    end

    if move_unit_count > 1 and not hard_locked and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS then
        local ok, err = pcall(Player.PrepareUnitOrders,
            player,
            Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            nil,
            position,
            nil,
            Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS,
            nil,
            false,
            false,
            false,
            true,
            MOVE_ORDER_ID,
            false
        )
        if ok then
            return true, nil, "selected_units"
        end

        debug_log(("MOVE_ORDER_ERROR method=selected_units units=%d error=%s"):format(move_unit_count, tostring(err)))
    end

    local ok, err = pcall(Player.PrepareUnitOrders,
        player,
        Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        nil,
        position,
        nil,
        Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
        move_units,
        false,
        false,
        false,
        true,
        MOVE_ORDER_ID,
        false
    )

    if ok then
        return true, nil, "passed_selected_units"
    end

    debug_log(("MOVE_ORDER_ERROR method=passed_selected_units units=%d error=%s"):format(move_unit_count, tostring(err)))

    if move_unit_count <= 1 and Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS then
        ok, err = pcall(Player.PrepareUnitOrders,
            player,
            Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            nil,
            position,
            nil,
            Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_SELECTED_UNITS,
            nil,
            false,
            false,
            false,
            true,
            MOVE_ORDER_ID,
            false
        )
        if ok then
            return true, nil, "selected_units"
        end

        debug_log(("MOVE_ORDER_ERROR method=selected_units error=%s"):format(tostring(err)))
    end

    return false, err, "selected_units"
end

local function execute_move_to_position(player, hero, position)
    LASThitv6.ExecuteSelectedMoveOrder(player, hero, position)
end

function LASThitv6.TryPrepositionPendingAttack(player, hero, target, now)
    if not pending_attack_prediction
        or not target
        or Entity.IsAlive(target) ~= true
    then
        return false
    end

    local window, distance, reach, approach_time, move_speed = LASThitv6.GetAttackPrepositionWindow(hero, target)
    local _, actual_reach, actual_gap = LASThitv6.GetAttackRangeInfo(hero, target)
    local execute_in = pending_attack_execute_time - now
    if window <= 0 then
        if LASThitv6.pending_attack_preposition_logged then
            clear_pending_move()
            return true
        end

        return false
    end

    if execute_in > window and not LASThitv6.pending_attack_preposition_logged then
        return false
    end

    clear_pending_move()
    if not LASThitv6.pending_attack_preposition_logged then
        local _, selected_count = LASThitv6.GetSelectedMoveUnits(player, hero)
        debug_log(("PENDING_PREPOSITION target=%s execute_in=%.4f window=%.4f approach=%.4f move_speed=%.1f distance=%.1f reach=%.1f ranged=%s selected_units=%d face=%.4f"):format(
            get_debug_target_text(hero, target),
            pending_attack_execute_time - now,
            window,
            approach_time,
            move_speed,
            distance,
            reach,
            tostring(NPC.IsRanged(hero) == true),
            selected_count or 0,
            get_hero_face_time(hero, target)
        ))
        LASThitv6.pending_attack_preposition_logged = true
    end

    if distance <= reach then
        return true
    end

    if now >= next_move_schedule_time then
        local gap_attack_window = approach_time + get_preposition_order_lead(hero)
        if issue_attack_target_once
            and actual_gap > 0
            and execute_in <= gap_attack_window
        then
            local attack_kind = NPC.IsRanged(hero) == true and "ranged_gap_close" or "melee_gap_close"
            debug_log(("PENDING_GAP_ATTACK target=%s kind=%s execute_in=%.4f window=%.4f approach=%.4f move_speed=%.1f distance=%.1f reach=%.1f"):format(
                get_debug_target_text(hero, target),
                attack_kind,
                execute_in,
                gap_attack_window,
                approach_time,
                move_speed,
                distance,
                actual_reach
            ))
            if issue_attack_target_once(player, hero, target, now, Entity.IsSameTeam(hero, target) == true, true, attack_kind) then
                return true
            end
        end

        execute_move_to_position(player, hero, Entity.GetAbsOrigin(target))
        next_move_schedule_time = now + MOVE_ORDER_INTERVAL
    end

    return true
end

local function run_move_orders(player, hero, now)
    if LASThitv6.IsMeleeSwingLocked(now) then
        clear_pending_move()
        return
    end

    if not pending_move_position and now >= next_move_schedule_time then
        schedule_move_to_cursor(now)
    end

    if pending_move_position and now >= pending_move_execute_time then
        execute_move_to_position(player, hero, pending_move_position)
        pending_move_position = nil
        pending_move_execute_time = 0
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
    if LASThitv6.HasActiveGlyphShield(target) then
        return false
    end

    local health = tonumber(Entity.GetHealth(target) or 0) or 0
    local min_damage = LASThitv6.GetEffectiveMinAttackDamageVsTarget(hero, target, now)
    if health <= 0 or health > min_damage then
        return false
    end

    if target_is_friendly then
        local max_health = tonumber(Entity.GetMaxHealth(target) or 0) or 0
        return is_deniable_health(health, max_health)
    end

    return true
end

local function remember_our_pending_hit(target, hit_time, damage_min, damage_max)
    local target_index = get_entity_index(target)
    our_pending_hits[target_index] = {
        expires_at = hit_time + OUR_PENDING_HIT_BUFFER,
        hit_time = hit_time,
        damage_min = tonumber(damage_min or 0) or 0,
        damage_max = tonumber(damage_max or damage_min or 0) or 0,
    }
end

function LASThitv6.ClearOurPendingHit(target)
    if target then
        our_pending_hits[get_entity_index(target)] = nil
    end
end

local function remember_our_setup_hit(hero, target, hit_time)
    local damage_min, damage_max = get_attack_damage_range_vs_target(hero, target)
    active_setup_hits[get_entity_index(target)] = {
        target_index = get_entity_index(target),
        hit_time = hit_time,
        damage = damage_min,
        damage_min = damage_min,
        damage_max = damage_max,
    }
end

local function remember_our_melee_pending_hit(hero, target, now)
    local hit_time = now
        + get_prediction_issue_lead(hero)
        + get_hero_hit_delay(hero, target)
    local damage_min, damage_max = get_attack_damage_range_vs_target(hero, target)

    remember_our_pending_hit(target, hit_time, damage_min, damage_max)
end

local function clear_expired_setup_hits(now)
    for target_index, setup_hit in pairs(active_setup_hits) do
        local target = get_entity_by_index(target_index)
        if setup_hit.hit_time <= now or not target or Entity.IsAlive(target) ~= true then
            active_setup_hits[target_index] = nil
        end
    end
end

local function clear_expired_our_pending_hits(now)
    for target_index, pending in pairs(our_pending_hits) do
        local target = get_entity_by_index(target_index)
        local expires_at = type(pending) == "table" and pending.expires_at or pending
        if expires_at <= now or not target or Entity.IsAlive(target) ~= true then
            our_pending_hits[target_index] = nil
        end
    end
end

local function is_our_hit_pending(target, now)
    local target_index = get_entity_index(target)
    local pending = our_pending_hits[target_index]
    if not pending then
        return false
    end

    local expires_at = type(pending) == "table" and pending.expires_at or pending
    if expires_at <= now or Entity.IsAlive(target) ~= true then
        our_pending_hits[target_index] = nil
        return false
    end
    if type(pending) == "table" and (tonumber(pending.damage_min or 0) or 0) > 0 then
        local health = tonumber(Entity.GetHealth(target) or 0) or 0
        if health > (tonumber(pending.damage_min or 0) or 0) then
            return false
        end
    end

    return true
end

function LASThitv6.TryPrepositionMeleePending(player, hero, target, now)
    if NPC.IsRanged(hero) == true then
        return false
    end

    return LASThitv6.TryPrepositionPendingAttack(player, hero, target, now)
end

function LASThitv6.FindSplitAttackTargetForUnit(unit, creeps, now, primary_target_index, assigned_targets)
    local enemy_enabled = is_enemy_creeps_enabled()
    local friendly_enabled = is_friendly_creeps_enabled()

    for side_pass = 1, 2 do
        local want_friendly = side_pass == 2
        if (want_friendly and friendly_enabled) or ((not want_friendly) and enemy_enabled) then
            for i = 1, #creeps do
                local creep = creeps[i]
                if creep.is_friendly == want_friendly
                    and creep.index ~= primary_target_index
                    and not assigned_targets[creep.index]
                    and not creep.has_glyph_shield
                    and not is_our_hit_pending(creep.npc, now)
                then
                    local health = tonumber(Entity.GetHealth(creep.npc) or creep.health or 0) or 0
                    local max_health = tonumber(Entity.GetMaxHealth(creep.npc) or creep.max_health or 0) or 0
                    if health > 0 and (not want_friendly or is_deniable_health(health, max_health)) then
                        local damage_min, damage_max = get_attack_damage_range_vs_target(unit, creep.npc)
                        if health <= damage_min then
                            local distance, reach, gap, in_range = LASThitv6.GetMeleeAttackRangeInfo(unit, creep.npc)
                            if in_range then
                                return creep, damage_min, damage_max, distance, reach, gap
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

function LASThitv6.FindSplitPredictionForUnit(unit, creeps, now, primary_target_index, assigned_targets)
    local enemy_enabled = is_enemy_creeps_enabled()
    local friendly_enabled = is_friendly_creeps_enabled()

    for side_pass = 1, 2 do
        local want_friendly = side_pass == 2
        if (want_friendly and friendly_enabled) or ((not want_friendly) and enemy_enabled) then
            local events = LASThitv6.GetIncomingHitEvents(unit, now, want_friendly)
            for i = 1, #creeps do
                local creep = creeps[i]
                if creep.is_friendly == want_friendly
                    and creep.index ~= primary_target_index
                    and not assigned_targets[creep.index]
                    and not creep.has_glyph_shield
                    and not is_our_hit_pending(creep.npc, now)
                then
                    local current_health = tonumber(Entity.GetHealth(creep.npc) or creep.health or 0) or 0
                    local max_health = tonumber(Entity.GetMaxHealth(creep.npc) or creep.max_health or 0) or 0
                    local damage_min, damage_max = get_attack_damage_range_vs_target(unit, creep.npc)
                    local _, _, _, in_range = LASThitv6.GetMeleeAttackRangeInfo(unit, creep.npc)

                    if current_health > damage_min and in_range then
                        local health_after_hits_min = current_health
                        local health_after_hits_max = current_health
                        local contributing_events = {}
                        local hit_groups = LASThitv6.GetTargetHitGroups(events, creep.index)
                        local shield_end_time = LASThitv6.GetGlyphShieldEndTime(creep.npc, now)

                        for j = 1, #hit_groups do
                            local hit_group = hit_groups[j]
                            if not (shield_end_time and hit_group.hit_time <= shield_end_time) then
                                health_after_hits_min = health_after_hits_min - hit_group.damage_max
                                health_after_hits_max = health_after_hits_max - hit_group.damage_min
                                for k = 1, #hit_group.events do
                                    contributing_events[#contributing_events + 1] = hit_group.events[k]
                                end

                                if health_after_hits_max <= 0 then
                                    break
                                end

                                if health_after_hits_max <= damage_min
                                    and (not want_friendly or is_deniable_health(health_after_hits_max, max_health))
                                then
                                    local attack_delay = LASThitv6.GetSyncPredictionAttackDelay(unit, creep.npc)
                                    local has_tower_hit = false
                                    for k = 1, #hit_group.events do
                                        if hit_group.events[k].is_tower == true then
                                            has_tower_hit = true
                                            break
                                        end
                                    end

                                    local landing_buffer = get_prediction_landing_buffer(unit, LASThitv6.GetPredictionAfterHitBuffer(unit, has_tower_hit))
                                    local desired_impact_time = hit_group.hit_time + landing_buffer
                                    local execute_time = desired_impact_time - attack_delay
                                    local execute_late = now - execute_time
                                    local execute_wait = execute_time - now

                                    if execute_late <= LASThitv6.SYNC_ATTACK_MAX_LATE
                                        and execute_wait <= LASThitv6.SYNC_SPLIT_MAX_QUEUE_TIME
                                    then
                                        return {
                                            creep = creep,
                                            execute_time = execute_time,
                                            desired_impact_time = desired_impact_time,
                                            incoming_time = hit_group.hit_time,
                                            health_after_hits = health_after_hits_max,
                                            health_after_hits_min = health_after_hits_min,
                                            health_after_hits_max = health_after_hits_max,
                                            damage_min = damage_min,
                                            damage_max = damage_max,
                                            events = contributing_events,
                                            confidence = LASThitv6.GetPredictionConfidence(contributing_events),
                                        }
                                    end

                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

function LASThitv6.TrySplitSyncAttacks(player, primary_hero, primary_target, now, target_is_friendly, reserved_units)
    if not LASThitv6.IsSyncAttackEnabled() or not player or not primary_hero then
        return 0
    end
    if not is_enemy_creeps_enabled() and not is_friendly_creeps_enabled() then
        return 0
    end

    local reserved_indexes = {}
    reserved_indexes[get_entity_index(primary_hero)] = true
    if reserved_units then
        for i = 1, #reserved_units do
            local unit = reserved_units[i]
            if type(unit) == "table" and unit.unit then
                unit = unit.unit
            end
            local index = unit and get_entity_index(unit) or 0
            if index > 0 then
                reserved_indexes[index] = true
            end
        end
    end

    local candidates = {}
    local seen = {}
    local function append_units(units)
        if not units then
            return
        end
        for key, value in pairs(units) do
            local unit = LASThitv6.ResolveLiveUnit(value) or LASThitv6.ResolveLiveUnit(key)
            local index = unit and get_entity_index(unit) or 0
            if index > 0 and not seen[index] then
                seen[index] = true
                local failed_until = LASThitv6.sync_attack_fail_until[index] or 0
                local pending = LASThitv6.sync_attack_pending[index]
                local last_issue = LASThitv6.sync_attack_last_issue[index] or 0
                local ready = LASThitv6.IsSyncAttackReady(unit, now)
                if not reserved_indexes[index]
                    and not pending
                    and ready
                    and failed_until <= now
                    and now - last_issue >= ATTACK_ORDER_INTERVAL
                    and not LASThitv6.HasQueuedSyncAttackForUnit(index)
                    and LASThitv6.IsSyncAttackUnit(primary_hero, unit)
                    and safe_call(NPC.IsAttacking, unit) ~= true
                then
                    candidates[#candidates + 1] = unit
                end
            end
        end
    end

    append_units(Heroes and Heroes.GetAll and safe_call(Heroes.GetAll) or nil)
    append_units(NPCs and NPCs.GetAll and safe_call(NPCs.GetAll) or nil)
    if #candidates == 0 then
        return 0
    end

    local radius = tonumber(ui.work_radius and ui.work_radius:Get() or 1200) or 1200
    local creeps = get_creeps_in_radius(primary_hero, radius)
    local primary_target_index = primary_target and get_entity_index(primary_target) or 0
    local assigned_targets = {}
    if primary_target_index > 0 then
        assigned_targets[primary_target_index] = true
    end

    local issued = 0
    for i = 1, #candidates do
        local unit = candidates[i]
        local creep, damage_min, damage_max, distance, reach, gap =
            LASThitv6.FindSplitAttackTargetForUnit(unit, creeps, now, primary_target_index, assigned_targets)
        if creep then
            local ok, err = LASThitv6.ExecuteSyncAttackOrder(player, unit, creep.npc, now, {
                target_is_friendly = creep.is_friendly,
                desired_impact_time = now + get_prediction_attack_delay(unit, creep.npc),
                damage_min = damage_min,
                damage_max = damage_max,
                split = true,
            })
            debug_log(("SYNC_ATTACK_SPLIT unit=%s#%d target=%s damage=%d-%d distance=%.1f reach=%.1f gap=%.1f ok=%s err=%s"):format(
                tostring(NPC.GetUnitName(unit) or "unit"),
                get_entity_index(unit),
                get_debug_target_text(primary_hero, creep.npc),
                damage_min,
                damage_max,
                distance,
                reach,
                gap,
                tostring(ok),
                tostring(err or "")
            ))
            if ok then
                assigned_targets[creep.index] = true
                issued = issued + 1
                remember_our_pending_hit(creep.npc, now + get_prediction_attack_delay(unit, creep.npc), damage_min, damage_max)
            end
        else
            local prediction = LASThitv6.FindSplitPredictionForUnit(unit, creeps, now, primary_target_index, assigned_targets)
            if prediction then
                local target = prediction.creep.npc
                local execute_time = prediction.execute_time or now
                if execute_time <= now then
                    local ok, err = LASThitv6.ExecuteSyncAttackOrder(player, unit, target, now, {
                        target_is_friendly = prediction.creep.is_friendly,
                        desired_impact_time = prediction.desired_impact_time,
                        damage_min = prediction.damage_min,
                        damage_max = prediction.damage_max,
                        split = true,
                    })
                    debug_log(("SYNC_ATTACK_SPLIT_PREDICT unit=%s#%d target=%s execute_late=%.4f impact_in=%.4f predicted_hp=%d hp_range=%d-%d damage=%d-%d ok=%s err=%s"):format(
                        tostring(NPC.GetUnitName(unit) or "unit"),
                        get_entity_index(unit),
                        get_debug_target_text(primary_hero, target),
                        now - execute_time,
                        prediction.desired_impact_time - now,
                        math.floor(prediction.health_after_hits + 0.5),
                        math.floor(prediction.health_after_hits_min + 0.5),
                        math.floor(prediction.health_after_hits_max + 0.5),
                        prediction.damage_min,
                        prediction.damage_max,
                        tostring(ok),
                        tostring(err or "")
                    ))
                    if ok then
                        assigned_targets[prediction.creep.index] = true
                        issued = issued + 1
                        remember_our_pending_hit(target, prediction.desired_impact_time, prediction.damage_min, prediction.damage_max)
                    end
                else
                    local unit_index = get_entity_index(unit)
                    local target_index = prediction.creep.index
                    local queued_index, queued_item = LASThitv6.GetQueuedSyncAttackIndex(unit_index, target_index)
                    if LASThitv6.ShouldReplaceQueuedSyncAttack(queued_item, prediction.desired_impact_time) then
                        LASThitv6.RemoveQueuedSyncAttackAt(queued_index)
                    end
                    if not LASThitv6.HasSyncAttackScheduled(unit_index, target_index, prediction.desired_impact_time) then
                        LASThitv6.sync_attack_queue[#LASThitv6.sync_attack_queue + 1] = {
                            unit = unit,
                            unit_index = unit_index,
                            target_index = target_index,
                            target_is_friendly = prediction.creep.is_friendly,
                            execute_time = execute_time,
                            desired_impact_time = prediction.desired_impact_time,
                            damage_min = prediction.damage_min,
                            damage_max = prediction.damage_max,
                            expires_at = prediction.desired_impact_time + LASThitv6.SYNC_ATTACK_IMPACT_WINDOW,
                            split = true,
                        }
                        assigned_targets[prediction.creep.index] = true
                        issued = issued + 1
                        remember_our_pending_hit(target, prediction.desired_impact_time, prediction.damage_min, prediction.damage_max)
                        debug_log(("SYNC_ATTACK_SPLIT_QUEUE unit=%s#%d target=%s execute_in=%.4f impact_in=%.4f predicted_hp=%d hp_range=%d-%d damage=%d-%d confidence=%s events=%d"):format(
                            tostring(NPC.GetUnitName(unit) or "unit"),
                            unit_index,
                            get_debug_target_text(primary_hero, target),
                            execute_time - now,
                            prediction.desired_impact_time - now,
                            math.floor(prediction.health_after_hits + 0.5),
                            math.floor(prediction.health_after_hits_min + 0.5),
                            math.floor(prediction.health_after_hits_max + 0.5),
                            prediction.damage_min,
                            prediction.damage_max,
                            prediction.confidence or "unknown",
                            #(prediction.events or {})
                        ))
                    end
                end
            end
        end
    end

    return issued
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
    return get_prediction_issue_lead(get_local_hero())
end

local function can_spare_attack_before_pending(hero, target, now)
    if not pending_attack_target_index or not pending_attack_prediction or pending_attack_is_friendly then
        return false
    end

    local launch_time = now + get_hero_attack_launch_delay(hero, target)
    local ready_time = get_next_attack_ready_time(hero, target, launch_time)
    local required_margin = DENY_BEFORE_LASTHIT_MARGIN
    return pending_attack_execute_time - ready_time > required_margin
end

local function is_prediction_move_lock_active(now)
    return now >= pending_attack_execute_time - get_prediction_move_lock_window()
end

local function schedule_attack_target(creep, now)
    pending_attack_target_index = creep.index
    pending_attack_execute_time = now
    pending_attack_is_friendly = creep.is_friendly
    pending_attack_prediction = false
    pending_attack_base_health = nil
    pending_attack_predicted_health = nil
    pending_attack_incoming_time = 0
    pending_attack_events = nil
    pending_attack_attack_delay = 0
    pending_attack_move_lock_logged = false
    LASThitv6.pending_attack_preposition_logged = false
    next_attack_schedule_time = now + ATTACK_ORDER_INTERVAL
    clear_pending_move()
    local direct_melee_debug = ""
    local hero = get_local_hero()
    if hero then
        local distance, reach, gap, in_range = LASThitv6.GetAttackRangeInfo(hero, creep.npc)
        local move_speed = LASThitv6.GetCurrentMoveSpeed(hero)
        direct_melee_debug = (" attack_distance=%.1f attack_reach=%.1f attack_gap=%.1f attack_in_range=%s move_speed=%.1f ranged=%s face=%.4f"):format(
            distance,
            reach,
            gap,
            tostring(in_range),
            move_speed,
            tostring(NPC.IsRanged(hero) == true),
            get_hero_face_time(hero, creep.npc)
        )
    end
    debug_log(("SCHEDULE_DIRECT target=%s#%d hp=%d min=%d execute_in=%.4f%s"):format(
        creep.name,
        creep.index,
        math.floor(creep.health + 0.5),
        creep.min_damage,
        pending_attack_execute_time - now,
        direct_melee_debug
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
    pending_attack_attack_delay = prediction.attack_delay or 0
    pending_attack_move_lock_logged = false
    LASThitv6.pending_attack_preposition_logged = false
    next_attack_schedule_time = now + ATTACK_ORDER_INTERVAL
    if pending_attack_execute_time - now <= get_prediction_move_lock_window() then
        clear_pending_move()
    end
    local predict_melee_debug = ""
    local hero = get_local_hero()
    if hero then
        local window, distance, reach, approach_time, move_speed = LASThitv6.GetAttackPrepositionWindow(hero, creep.npc)
        local gap = math.max(0, distance - reach)
        local prep_in = pending_attack_execute_time - now - window
        local scaled_attack_point, base_attack_point, attack_point_scale = LASThitv6.GetScaledAttackAnimPoint(hero)
        predict_melee_debug = (" attack_distance=%.1f attack_reach=%.1f attack_gap=%.1f preposition_window=%.4f prep_in=%.4f approach=%.4f move_speed=%.1f ranged=%s face=%.4f melee_buffer=%.4f melee_start_buffer=%.4f order_start=%.4f attack_point=%.4f base_point=%.4f attack_scale=%.3f"):format(
            distance,
            reach,
            gap,
            window,
            prep_in,
            approach_time,
            move_speed,
            tostring(NPC.IsRanged(hero) == true),
            get_hero_face_time(hero, creep.npc),
            LASThitv6.MELEE_PREDICTION_IMPACT_AFTER_HIT_BUFFER,
            LASThitv6.MELEE_ATTACK_START_BUFFER,
            LASThitv6.GetAttackOrderStartDelay(hero),
            scaled_attack_point,
            base_attack_point,
            attack_point_scale
        )
    end
    debug_log(("SCHEDULE_PREDICT target=%s#%d hp=%d predicted_hp=%d hp_range=%d-%d incoming_in=%.4f execute_in=%.4f predict_delay=%.4f raw_delay=%.4f ping=%.4f fixed=%.4f lead=%.4f land_buffer=%.4f confidence=%s events=%d%s"):format(
        creep.name,
        creep.index,
        math.floor(creep.health + 0.5),
        math.floor(prediction.health_after_hits + 0.5),
        math.floor((prediction.health_after_hits_min or prediction.health_after_hits) + 0.5),
        math.floor((prediction.health_after_hits_max or prediction.health_after_hits) + 0.5),
        prediction.incoming_time - now,
        pending_attack_execute_time - now,
        prediction.attack_delay or 0,
        prediction.raw_attack_delay or 0,
        prediction.network_latency or get_network_latency(),
        ATTACK_ORDER_FIXED_LEAD,
        prediction.order_lead or get_prediction_issue_lead(get_local_hero()),
        prediction.landing_buffer or 0,
        prediction.confidence or "unknown",
        #(prediction.events or {}),
        predict_melee_debug
    ))
end

local function execute_attack_target(player, hero, target)
    if Player.PrepareUnitOrders then
        local ok, err = pcall(Player.PrepareUnitOrders,
            player,
            Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET,
            target,
            Entity.GetAbsOrigin(target),
            nil,
            Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
            hero,
            false,
            false,
            true,
            true,
            ATTACK_ORDER_ID,
            false
        )

        if ok then
            return true, nil, "Player.PrepareUnitOrders"
        end

        debug_log(("ATTACK_ORDER_ERROR method=Player.PrepareUnitOrders target=%s error=%s"):format(
            get_debug_target_text(hero, target),
            tostring(err)
        ))
    end

    if Player.AttackTarget then
        local ok, err = pcall(Player.AttackTarget, player, hero, target, false, true, true, ATTACK_ORDER_ID, false)
        if ok then
            return true, nil, "Player.AttackTarget"
        end

        debug_log(("ATTACK_ORDER_ERROR method=Player.AttackTarget target=%s error=%s"):format(
            get_debug_target_text(hero, target),
            tostring(err)
        ))
        return false, err, "Player.AttackTarget"
    end

    return false, "missing_api", "none"
end

local function execute_attack_target_for_unit(player, unit, target, identifier)
    if not player or not unit or not target then
        return false, "missing_arg", "none"
    end

    if Player.PrepareUnitOrders then
        local ok, err = pcall(Player.PrepareUnitOrders,
            player,
            Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET,
            target,
            Entity.GetAbsOrigin(target),
            nil,
            Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
            unit,
            false,
            false,
            true,
            true,
            identifier or ATTACK_ORDER_ID,
            false
        )

        if ok then
            return true, nil, "Player.PrepareUnitOrders"
        end

        return false, err, "Player.PrepareUnitOrders"
    end

    if Player.AttackTarget then
        local ok, err = pcall(Player.AttackTarget, player, unit, target, false, true, true, identifier or ATTACK_ORDER_ID, false)
        if ok then
            return true, nil, "Player.AttackTarget"
        end

        return false, err, "Player.AttackTarget"
    end

    return false, "missing_api", "none"
end

function LASThitv6.MaintainMeleeHardLock(player, hero, now)
    now = tonumber(now or get_time()) or get_time()
    if not player or not LASThitv6.IsMeleeHardLocked(now) then
        return false
    end

    local target_index = LASThitv6.melee_hard_lock_target_index
    local target = target_index and get_live_npc_by_index(target_index) or nil
    if not target then
        LASThitv6.ClearMeleeHardLock("target_dead_or_stale")
        return false
    end

    local locks = LASThitv6.melee_hard_lock_unit_indexes or {}
    local issued = 0
    for unit_index, lock in pairs(locks) do
        if lock
            and lock.target_index == target_index
            and lock.attack == true
            and now >= (tonumber(lock.next_order_time or 0) or 0)
        then
            local unit = get_live_npc_by_index(unit_index)
            local sync_pending = LASThitv6.sync_attack_pending and LASThitv6.sync_attack_pending[unit_index] or nil
            local confirmation_pending = attack_confirmation_until > now
                and attack_confirmation_target_index == target_index
            local defer_reissue = confirmation_pending
                or (sync_pending and sync_pending.target_index == target_index)
            if defer_reissue then
                lock.next_order_time = now + LASThitv6.MELEE_HARD_LOCK_REISSUE_INTERVAL
            elseif unit and NPC.IsRanged(unit) ~= true and safe_call(NPC.IsAttacking, unit) ~= true then
                local ok, err, method = execute_attack_target_for_unit(player, unit, target, LASThitv6.MELEE_HARD_LOCK_ORDER_ID)
                lock.next_order_time = now + LASThitv6.MELEE_HARD_LOCK_REISSUE_INTERVAL
                if ok then
                    issued = issued + 1
                elseif now >= (LASThitv6.melee_hard_lock_reissue_error_log_until or 0) then
                    debug_log(("MELEE_HARD_LOCK_REISSUE_ERROR unit=%s#%d target=%s method=%s error=%s"):format(
                        tostring(NPC.GetUnitName(unit) or "unit"),
                        unit_index,
                        hero and get_debug_target_text(hero, target) or ("index=" .. tostring(target_index)),
                        tostring(method),
                        tostring(err)
                    ))
                    LASThitv6.melee_hard_lock_reissue_error_log_until = now + 0.250
                end
            else
                lock.next_order_time = now + LASThitv6.MELEE_HARD_LOCK_REISSUE_INTERVAL
            end
        end
    end

    if issued > 0 and now >= (LASThitv6.melee_hard_lock_reissue_log_until or 0) then
        local distance, reach, gap = 0, 0, 0
        if hero then
            distance, reach, gap = LASThitv6.GetMeleeAttackRangeInfo(hero, target)
        end
        debug_log(("MELEE_HARD_LOCK_REISSUE target=%s units=%d distance=%.1f reach=%.1f gap=%.1f"):format(
            hero and get_debug_target_text(hero, target) or ("index=" .. tostring(target_index)),
            issued,
            distance,
            reach,
            gap
        ))
        LASThitv6.melee_hard_lock_reissue_log_until = now + 0.200
    end

    return issued > 0
end

function LASThitv6.TrackSyncAttackOrder(unit, target, now, opts)
    if not unit or not target then
        return
    end

    opts = opts or {}
    local unit_index = get_entity_index(unit)
    local target_is_friendly = opts.target_is_friendly
    if target_is_friendly == nil then
        target_is_friendly = Entity.IsSameTeam(unit, target) == true
    end

    local approach_time = math.max(0, tonumber(opts.approach_time or 0) or 0)
    local order_window = approach_time > 0 and get_preposition_order_lead(unit) or 0
    local start_timeout = opts.split == true and LASThitv6.SYNC_SPLIT_START_TIMEOUT or LASThitv6.SYNC_ATTACK_START_TIMEOUT
    start_timeout = start_timeout + approach_time + order_window
    local confirm_timeout = LASThitv6.SYNC_ATTACK_CONFIRM_TIMEOUT + approach_time + order_window
    LASThitv6.sync_attack_pending[unit_index] = {
        unit = unit,
        unit_index = unit_index,
        unit_name = tostring(NPC.GetUnitName(unit) or "unit"),
        target_index = get_entity_index(target),
        target_is_friendly = target_is_friendly,
        issue_time = now,
        start_check_until = now + start_timeout,
        confirm_until = now + confirm_timeout,
        desired_impact_time = opts.desired_impact_time,
        damage_min = opts.damage_min or 0,
        damage_max = opts.damage_max or 0,
        attack_delay = opts.attack_delay,
        approach_time = approach_time,
        distance = opts.distance,
        reach = opts.reach,
        gap = opts.gap,
        move_speed = opts.move_speed,
        retries = opts.retries or 0,
        split = opts.split == true,
    }
    if NPC.IsRanged(unit) ~= true then
        local lock_units = { unit }
        local player = Players and Players.GetLocal and Players.GetLocal() or nil
        local hero = get_local_hero()
        local selected_units = player and hero and LASThitv6.GetSelectedMoveUnits(player, hero) or nil
        if type(selected_units) == "table" then
            for i = 1, #selected_units do
                lock_units[#lock_units + 1] = selected_units[i]
            end
        elseif selected_units then
            lock_units[#lock_units + 1] = selected_units
        end
        LASThitv6.LockMeleeHardTarget(target, now + confirm_timeout, opts.split == true and "sync_split" or "sync_attack", lock_units, unit)
    end
end

function LASThitv6.MarkSyncAttackFailed(item, now, reason)
    if not item then
        return
    end

    LASThitv6.sync_attack_pending[item.unit_index] = nil
    if item.split == true and item.target_index then
        our_pending_hits[item.target_index] = nil
    end
    local cooldown = item.split == true and 0 or LASThitv6.SYNC_ATTACK_FAIL_COOLDOWN
    if cooldown > 0 then
        LASThitv6.sync_attack_fail_until[item.unit_index] = now + cooldown
    else
        LASThitv6.sync_attack_fail_until[item.unit_index] = nil
    end
    debug_log(("SYNC_ATTACK_CONFIRM_FAIL unit=%s#%d target=index=%s reason=%s waited=%.4f fail_cooldown=%.4f"):format(
        tostring(item.unit_name or "unit"),
        item.unit_index or 0,
        tostring(item.target_index),
        tostring(reason or "no_attack_start"),
        now - (item.issue_time or now),
        cooldown
    ))
end

function LASThitv6.ExecuteSyncAttackOrder(player, unit, target, now, opts)
    if not player or not unit or not target or not Player or not Player.PrepareUnitOrders then
        return false, "missing_api"
    end

    local unit_index = get_entity_index(unit)
    local last_issue = LASThitv6.sync_attack_last_issue[unit_index] or 0
    if now - last_issue < ATTACK_ORDER_INTERVAL then
        return false, "throttled"
    end
    local ready, ready_in = LASThitv6.IsSyncAttackReady(unit, now)
    if not ready then
        return false, ("recovering %.4f"):format(ready_in)
    end

    local ok, err = pcall(Player.PrepareUnitOrders,
        player,
        Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET,
        target,
        Entity.GetAbsOrigin(target),
        nil,
        Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY,
        unit,
        false,
        false,
        true,
        true,
        LASThitv6.SYNC_ATTACK_ORDER_ID,
        false
    )

    if ok then
        LASThitv6.sync_attack_last_issue[unit_index] = now
        LASThitv6.sync_attack_fail_until[unit_index] = nil
        LASThitv6.TrackSyncAttackOrder(unit, target, now, opts)
        return true, nil
    end

    return false, err
end

function LASThitv6.GetQueuedSyncAttackIndex(unit_index, target_index)
    unit_index = tonumber(unit_index or 0) or 0
    target_index = tonumber(target_index or 0) or 0
    if unit_index <= 0 or target_index <= 0 then
        return nil, nil
    end

    for i = #(LASThitv6.sync_attack_queue or {}), 1, -1 do
        local queued = LASThitv6.sync_attack_queue[i]
        if queued
            and queued.unit_index == unit_index
            and queued.target_index == target_index
        then
            return i, queued
        end
    end

    return nil, nil
end

function LASThitv6.HasQueuedSyncAttackForUnit(unit_index)
    unit_index = tonumber(unit_index or 0) or 0
    if unit_index <= 0 then
        return false
    end

    for i = 1, #(LASThitv6.sync_attack_queue or {}) do
        local queued = LASThitv6.sync_attack_queue[i]
        if queued and queued.unit_index == unit_index then
            return true
        end
    end

    return false
end

function LASThitv6.RemoveQueuedSyncAttackAt(index)
    local item = index and LASThitv6.sync_attack_queue and LASThitv6.sync_attack_queue[index] or nil
    if item and item.split == true and item.target_index then
        our_pending_hits[item.target_index] = nil
    end
    if item then
        table.remove(LASThitv6.sync_attack_queue, index)
    end
    return item
end

function LASThitv6.ShouldReplaceQueuedSyncAttack(queued, desired_impact_time)
    if not queued then
        return false
    end
    if not desired_impact_time or not queued.desired_impact_time then
        return false
    end
    return desired_impact_time < queued.desired_impact_time - LASThitv6.SYNC_ATTACK_REPLACE_EARLIER_WINDOW
end

function LASThitv6.HasSyncAttackScheduled(unit_index, target_index, desired_impact_time)
    unit_index = tonumber(unit_index or 0) or 0
    target_index = tonumber(target_index or 0) or 0
    if unit_index <= 0 or target_index <= 0 then
        return false
    end

    local pending = LASThitv6.sync_attack_pending[unit_index]
    if pending
        and pending.target_index == target_index
    then
        return true
    end

    local _, queued = LASThitv6.GetQueuedSyncAttackIndex(unit_index, target_index)
    if queued then
        return not LASThitv6.ShouldReplaceQueuedSyncAttack(queued, desired_impact_time)
    end

    return false
end

function LASThitv6.GetScheduledSyncDamageForTarget(target, desired_impact_time)
    local target_index = target and get_entity_index(target) or 0
    if target_index <= 0 then
        return 0, 0, 0
    end

    local damage_min = 0
    local damage_max = 0
    local count = 0
    local seen_units = {}
    local function close_enough(value)
        if not desired_impact_time or not value then
            return true
        end
        return math.abs(value - desired_impact_time) <= math.max(0.250, LASThitv6.SYNC_ATTACK_IMPACT_WINDOW)
    end
    local function add_item(item)
        if not item
            or item.target_index ~= target_index
            or not close_enough(item.desired_impact_time)
        then
            return
        end

        local unit_index = tonumber(item.unit_index or 0) or 0
        if unit_index > 0 and seen_units[unit_index] then
            return
        end

        local item_min = tonumber(item.damage_min or 0) or 0
        local item_max = tonumber(item.damage_max or 0) or 0
        if (item_min <= 0 or item_max <= 0) and item.unit and Entity.IsAlive(item.unit) == true then
            local fallback_min, fallback_max = get_attack_damage_range_vs_target(item.unit, target)
            if fallback_min > 0 or fallback_max > 0 then
                item_min = fallback_min
                item_max = fallback_max
            end
        end
        if item_min <= 0 and item_max <= 0 then
            return
        end
        if unit_index > 0 then
            seen_units[unit_index] = true
        end

        damage_min = damage_min + item_min
        damage_max = damage_max + item_max
        count = count + 1
    end

    for _, item in pairs(LASThitv6.sync_attack_pending or {}) do
        add_item(item)
    end
    for i = 1, #(LASThitv6.sync_attack_queue or {}) do
        add_item(LASThitv6.sync_attack_queue[i])
    end

    return damage_min, damage_max, count
end

function LASThitv6.QueueSyncedAttacks(player, primary_hero, target, now, target_is_friendly, desired_impact_time, attack_kind, target_health_override, skip_split)
    if not LASThitv6.IsSyncAttackEnabled()
        or attack_kind == "tower_setup"
        or not target
        or not desired_impact_time
    then
        return
    end

    local sync_units, planned_min_damage = LASThitv6.GetNeededSyncAttackUnits(
        primary_hero,
        target,
        now,
        desired_impact_time,
        target_health_override,
        true
    )
    local target_health = tonumber(target_health_override or Entity.GetHealth(target) or 0) or 0
    if #sync_units > 0 and target_health > planned_min_damage then
        debug_log(("SYNC_ATTACK_SKIP_INSUFFICIENT_DAMAGE target=%s hp=%d min=%d units=%d impact_in=%.4f kind=%s"):format(
            get_debug_target_text(primary_hero, target),
            math.floor(target_health + 0.5),
            math.floor(planned_min_damage + 0.5),
            #sync_units,
            desired_impact_time - now,
            tostring(attack_kind or "attack")
        ))
        if skip_split ~= true then
            LASThitv6.TrySplitSyncAttacks(player, primary_hero, target, now, target_is_friendly, nil)
        end
        return
    end

    local reserved_units = {}
    local queued = 0
    for i = 1, #sync_units do
        local item = sync_units[i]
        local unit = item.unit
        reserved_units[#reserved_units + 1] = unit
        local unit_index = get_entity_index(unit)
        local target_index = get_entity_index(target)
        local queued_index, queued_item = LASThitv6.GetQueuedSyncAttackIndex(unit_index, target_index)
        if LASThitv6.ShouldReplaceQueuedSyncAttack(queued_item, desired_impact_time) then
            LASThitv6.RemoveQueuedSyncAttackAt(queued_index)
            debug_log(("SYNC_ATTACK_QUEUE_REPLACE_EARLIER unit=%s#%d target=%s old_impact_in=%.4f new_impact_in=%.4f"):format(
                tostring(NPC.GetUnitName(unit) or "unit"),
                unit_index,
                get_debug_target_text(primary_hero, target),
                (queued_item.desired_impact_time or now) - now,
                desired_impact_time - now
            ))
        end
        if not LASThitv6.HasSyncAttackScheduled(unit_index, target_index, desired_impact_time) then
            local execute_time = item.execute_time or now
            local execute_late = now - execute_time
            if execute_time <= now then
                if execute_late <= LASThitv6.SYNC_ATTACK_MAX_LATE then
                    local ok, err = LASThitv6.ExecuteSyncAttackOrder(player, unit, target, now, {
                        target_is_friendly = target_is_friendly,
                        desired_impact_time = desired_impact_time,
                        damage_min = item.damage_min,
                        damage_max = item.damage_max,
                        attack_delay = item.attack_delay,
                        approach_time = item.approach_time,
                        distance = item.distance,
                        reach = item.reach,
                        gap = item.gap,
                        move_speed = item.move_speed,
                    })
                    debug_log(("SYNC_ATTACK_ISSUE unit=%s#%d target=%s execute_late=%.4f impact_in=%.4f attack_delay=%.4f approach=%.4f move_speed=%.1f distance=%.1f reach=%.1f gap=%.1f damage=%d-%d ok=%s err=%s"):format(
                        tostring(NPC.GetUnitName(unit) or "unit"),
                        unit_index,
                        get_debug_target_text(primary_hero, target),
                        execute_late,
                        desired_impact_time - now,
                        item.attack_delay or 0,
                        item.approach_time or 0,
                        item.move_speed or 0,
                        item.distance or 0,
                        item.reach or 0,
                        item.gap or 0,
                        item.damage_min,
                        item.damage_max,
                        tostring(ok),
                        tostring(err or "")
                    ))
                end
            elseif execute_time - now <= LASThitv6.SYNC_ATTACK_MAX_QUEUE_TIME then
                LASThitv6.sync_attack_queue[#LASThitv6.sync_attack_queue + 1] = {
                    unit = unit,
                    unit_index = unit_index,
                    target_index = target_index,
                    target_is_friendly = target_is_friendly,
                    execute_time = execute_time,
                    desired_impact_time = desired_impact_time,
                    damage_min = item.damage_min,
                    damage_max = item.damage_max,
                    attack_delay = item.attack_delay,
                    approach_time = item.approach_time,
                    distance = item.distance,
                    reach = item.reach,
                    gap = item.gap,
                    move_speed = item.move_speed,
                    expires_at = desired_impact_time + LASThitv6.SYNC_ATTACK_IMPACT_WINDOW,
                }
                queued = queued + 1
            end
        end
    end

    if queued > 0 then
        debug_log(("SYNC_ATTACK_QUEUE target=%s queued=%d impact_in=%.4f kind=%s"):format(
            get_debug_target_text(primary_hero, target),
            queued,
            desired_impact_time - now,
            tostring(attack_kind or "attack")
        ))
    end

    if skip_split ~= true then
        LASThitv6.TrySplitSyncAttacks(player, primary_hero, target, now, target_is_friendly, reserved_units)
    end
end

function LASThitv6.ProcessSyncAttackQueue(player, hero, now)
    if not LASThitv6.IsSyncAttackEnabled() then
        LASThitv6.sync_attack_queue = {}
        return
    end

    for i = #LASThitv6.sync_attack_queue, 1, -1 do
        local item = LASThitv6.sync_attack_queue[i]
        if not item or now > (item.expires_at or now) then
            if item and item.split == true and item.target_index then
                our_pending_hits[item.target_index] = nil
            end
            table.remove(LASThitv6.sync_attack_queue, i)
        elseif now >= item.execute_time then
            local target = get_live_creep_by_index(hero, item.target_index, item.target_is_friendly)
            local unit = item.unit
            if target and unit and Entity.IsAlive(unit) == true then
                local ready, ready_in = LASThitv6.IsSyncAttackReady(unit, now)
                if not ready then
                    local ready_time = now + ready_in
                    if ready_time <= (item.expires_at or now) then
                        item.execute_time = ready_time
                        debug_log(("SYNC_ATTACK_QUEUE_DELAY_READY unit=%s#%d target=%s ready_in=%.4f impact_in=%.4f"):format(
                            tostring(NPC.GetUnitName(unit) or "unit"),
                            item.unit_index or get_entity_index(unit),
                            get_debug_target_text(hero, target),
                            ready_in,
                            (item.desired_impact_time or now) - now
                        ))
                    else
                        table.remove(LASThitv6.sync_attack_queue, i)
                        if item.split == true and item.target_index then
                            our_pending_hits[item.target_index] = nil
                        end
                        debug_log(("SYNC_ATTACK_QUEUE_DROP_RECOVERING unit=%s#%d target=%s ready_in=%.4f impact_in=%.4f"):format(
                            tostring(NPC.GetUnitName(unit) or "unit"),
                            item.unit_index or get_entity_index(unit),
                            get_debug_target_text(hero, target),
                            ready_in,
                            (item.desired_impact_time or now) - now
                        ))
                    end
                else
                    table.remove(LASThitv6.sync_attack_queue, i)
                    local should_fire = true
                    if item.split == true then
                        local distance, reach, gap, in_range = LASThitv6.GetMeleeAttackRangeInfo(unit, target)
                        if not in_range then
                            our_pending_hits[item.target_index] = nil
                            should_fire = false
                            debug_log(("SYNC_ATTACK_SPLIT_DROP_OUT_OF_RANGE unit=%s#%d target=%s execute_late=%.4f distance=%.1f reach=%.1f gap=%.1f"):format(
                                tostring(NPC.GetUnitName(unit) or "unit"),
                                item.unit_index or get_entity_index(unit),
                                get_debug_target_text(hero, target),
                                now - item.execute_time,
                                distance,
                                reach,
                                gap
                            ))
                        end
                    end

                    if should_fire then
                        local ok, err = LASThitv6.ExecuteSyncAttackOrder(player, unit, target, now, {
                            target_is_friendly = item.target_is_friendly,
                            desired_impact_time = item.desired_impact_time,
                            damage_min = item.damage_min,
                            damage_max = item.damage_max,
                            attack_delay = item.attack_delay,
                            approach_time = item.approach_time,
                            distance = item.distance,
                            reach = item.reach,
                            gap = item.gap,
                            move_speed = item.move_speed,
                            split = item.split == true,
                        })
                        debug_log(("SYNC_ATTACK_FIRE unit=%s#%d target=%s execute_late=%.4f impact_in=%.4f attack_delay=%.4f approach=%.4f move_speed=%.1f distance=%.1f reach=%.1f gap=%.1f damage=%d-%d ok=%s err=%s"):format(
                            tostring(NPC.GetUnitName(unit) or "unit"),
                            item.unit_index or get_entity_index(unit),
                            get_debug_target_text(hero, target),
                            now - item.execute_time,
                            (item.desired_impact_time or now) - now,
                            item.attack_delay or 0,
                            item.approach_time or 0,
                            item.move_speed or 0,
                            item.distance or 0,
                            item.reach or 0,
                            item.gap or 0,
                            item.damage_min or 0,
                            item.damage_max or 0,
                            tostring(ok),
                            tostring(err or "")
                        ))
                    end
                end
            elseif item and item.split == true and item.target_index then
                table.remove(LASThitv6.sync_attack_queue, i)
                our_pending_hits[item.target_index] = nil
            else
                table.remove(LASThitv6.sync_attack_queue, i)
            end
        end
    end
end

function LASThitv6.ProcessSyncAttackConfirmations(player, hero, now)
    if not LASThitv6.IsSyncAttackEnabled() then
        LASThitv6.sync_attack_pending = {}
        return
    end

    for unit_index, item in pairs(LASThitv6.sync_attack_pending) do
        local unit = item and item.unit or nil
        local target = item and get_live_creep_by_index(hero, item.target_index, item.target_is_friendly) or nil
        if not item or not unit or Entity.IsAlive(unit) ~= true then
            if item and item.split == true and item.target_index then
                our_pending_hits[item.target_index] = nil
            end
            LASThitv6.sync_attack_pending[unit_index] = nil
        elseif not target then
            if item.split == true and item.target_index then
                our_pending_hits[item.target_index] = nil
            end
            LASThitv6.sync_attack_pending[unit_index] = nil
        elseif now > (item.confirm_until or now) then
            LASThitv6.MarkSyncAttackFailed(item, now, "no_animation")
        elseif now >= (item.start_check_until or now)
            and safe_call(NPC.IsAttacking, unit) ~= true
        then
            local attack_delay, approach_time, distance, reach, gap, in_range, move_speed =
                LASThitv6.GetSyncPredictionAttackDelay(unit, target)
            local desired_impact_time = item.desired_impact_time or (now + attack_delay)
            if item.split ~= true
                and (item.retries or 0) < LASThitv6.SYNC_ATTACK_RETRY_MAX
                and in_range
                and now <= desired_impact_time + LASThitv6.SYNC_ATTACK_MAX_LATE
            then
                debug_log(("SYNC_ATTACK_CONFIRM_RETRY unit=%s#%d target=%s reason=no_attack_start waited=%.4f impact_in=%.4f approach=%.4f move_speed=%.1f distance=%.1f reach=%.1f gap=%.1f retry=%d"):format(
                    tostring(item.unit_name or "unit"),
                    unit_index,
                    get_debug_target_text(hero, target),
                    now - (item.issue_time or now),
                    desired_impact_time - now,
                    approach_time,
                    move_speed,
                    distance,
                    reach,
                    gap,
                    (item.retries or 0) + 1
                ))
                LASThitv6.sync_attack_pending[unit_index] = nil
                LASThitv6.ExecuteSyncAttackOrder(player, unit, target, now, {
                    target_is_friendly = item.target_is_friendly,
                    desired_impact_time = desired_impact_time,
                    damage_min = item.damage_min,
                    damage_max = item.damage_max,
                    attack_delay = attack_delay,
                    approach_time = approach_time,
                    distance = distance,
                    reach = reach,
                    gap = gap,
                    move_speed = move_speed,
                    retries = (item.retries or 0) + 1,
                })
            else
                LASThitv6.MarkSyncAttackFailed(item, now, in_range and "no_attack_start" or "out_of_range")
            end
        end
    end
end

local will_target_die_before_our_hit

issue_attack_target_once = function(player, hero, target, now, target_is_friendly, allow_incoming_before_our_hit, attack_kind)
    attack_kind = attack_kind or "attack"
    if target_is_friendly == nil and target then
        target_is_friendly = Entity.IsSameTeam(hero, target) == true
    end

    if not is_valid_creep_target(hero, target, target_is_friendly) then
        debug_log("SKIP_ATTACK invalid_or_dead_target")
        return false
    end

    if is_our_hit_pending(target, now) then
        local pending = our_pending_hits[get_entity_index(target)]
        local pending_expires_at = type(pending) == "table" and pending.expires_at or pending
        local pending_left = math.max(0, (pending_expires_at or now) - now)
        local pending_damage_min = type(pending) == "table" and (tonumber(pending.damage_min or 0) or 0) or 0
        local pending_damage_max = type(pending) == "table" and (tonumber(pending.damage_max or 0) or 0) or 0
        debug_log(("SKIP_ATTACK our_hit_pending target=%s pending_left=%.4f pending_damage=%d-%d"):format(
            get_debug_target_text(hero, target),
            pending_left,
            math.floor(pending_damage_min + 0.5),
            math.floor(pending_damage_max + 0.5)
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

    local is_timed_melee_attack = NPC.IsRanged(hero) ~= true
        and (allow_incoming_before_our_hit == true or attack_kind == "tower_setup")
    local attack_distance, attack_reach, attack_gap, attack_in_range = LASThitv6.GetAttackRangeInfo(hero, target)
    local attack_approach_time = 0
    local attack_move_speed = 0
    if attack_gap > 0 then
        attack_move_speed = LASThitv6.GetCurrentMoveSpeed(hero)
        attack_approach_time = LASThitv6.GetApproachTimeFromGap(hero, target, attack_gap, attack_move_speed)
    else
        attack_move_speed = LASThitv6.GetCurrentMoveSpeed(hero)
    end
    local melee_face_time = get_hero_face_time(hero, target)
    local ranged_attack_gap_close = NPC.IsRanged(hero) == true and attack_gap > 0
    local allow_gap_close_attack = attack_kind == "melee_gap_close" or attack_kind == "ranged_gap_close" or ranged_attack_gap_close
    if is_timed_melee_attack
        and not attack_in_range
        and not allow_gap_close_attack
        and attack_gap <= LASThitv6.MELEE_LATE_GAP_CLOSE_MAX_GAP
        and attack_approach_time <= LASThitv6.MELEE_LATE_GAP_CLOSE_MAX_TIME
    then
        attack_kind = "melee_gap_close"
        allow_gap_close_attack = true
    end
    if is_timed_melee_attack and not attack_in_range and not allow_gap_close_attack then
        debug_log(("SKIP_ATTACK melee_out_of_range target=%s distance=%.1f reach=%.1f gap=%.1f face=%.4f api_delay=%.4f"):format(
            get_debug_target_text(hero, target),
            attack_distance,
            attack_reach,
            attack_gap,
            melee_face_time,
            get_hero_hit_delay(hero, target)
        ))
        return false
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
    if allow_gap_close_attack and attack_gap > 0 then
        prediction_attack_delay = prediction_attack_delay + attack_approach_time
    end
    local launch_delay = get_hero_attack_launch_delay(hero, target)
    local issue_launch_delay = launch_delay
    if NPC.IsRanged(hero) == true then
        issue_launch_delay = issue_launch_delay + LASThitv6.GetAttackOrderStartDelay(hero)
    end
    local network_latency = get_network_latency()
    local order_lead = get_prediction_issue_lead(hero)
    local latency_for_lead = order_lead - ATTACK_ORDER_FIXED_LEAD
    local start_check_timeout = LASThitv6.ATTACK_CONFIRM_START_TIMEOUT
    if NPC.IsRanged(hero) == true then
        if attack_gap > 0 then
            start_check_timeout = start_check_timeout + attack_approach_time + get_preposition_order_lead(hero)
        end
        start_check_timeout = math.max(
            start_check_timeout,
            issue_launch_delay + order_lead + LASThitv6.RANGED_PROJECTILE_CONFIRM_BUFFER
        )
        confirmation_timeout = math.max(confirmation_timeout, start_check_timeout + ATTACK_CONFIRM_BUFFER)
    else
        start_check_timeout = math.max(
            ATTACK_ORDER_INTERVAL,
            LASThitv6.GetAttackStartCheckDelay(hero, target, attack_gap > 0 and attack_approach_time or 0)
        )
        confirmation_timeout = math.max(
            confirmation_timeout,
            start_check_timeout + ATTACK_CONFIRM_BUFFER,
            prediction_attack_delay + ATTACK_CONFIRM_BUFFER
        )
    end
    local attack_debug = ""
    if NPC.IsRanged(hero) == true then
        local scaled_attack_point, base_attack_point, attack_point_scale = LASThitv6.GetScaledAttackAnimPoint(hero)
        attack_debug = (" projectile_check=%.4f attack_distance=%.1f attack_reach=%.1f attack_gap=%.1f attack_in_range=%s approach=%.4f move_speed=%.1f face=%.4f order_start=%.4f attack_point=%.4f base_point=%.4f attack_scale=%.3f"):format(
            start_check_timeout,
            attack_distance,
            attack_reach,
            attack_gap,
            tostring(attack_in_range),
            attack_approach_time,
            attack_move_speed,
            melee_face_time,
            LASThitv6.GetAttackOrderStartDelay(hero),
            scaled_attack_point,
            base_attack_point,
            attack_point_scale
        )
    else
        local scaled_attack_point, base_attack_point, attack_point_scale = LASThitv6.GetScaledAttackAnimPoint(hero)
        attack_debug = (" melee_distance=%.1f melee_reach=%.1f melee_gap=%.1f melee_in_range=%s approach=%.4f move_speed=%.1f face=%.4f melee_buffer=%.4f melee_start_buffer=%.4f order_start=%.4f melee_attack_point=%.4f melee_base_point=%.4f melee_scale=%.3f late_limit=%.4f start_timeout=%.4f"):format(
            attack_distance,
            attack_reach,
            attack_gap,
            tostring(attack_in_range),
            attack_approach_time,
            attack_move_speed,
            melee_face_time,
            LASThitv6.MELEE_PREDICTION_IMPACT_AFTER_HIT_BUFFER,
            LASThitv6.MELEE_ATTACK_START_BUFFER,
            LASThitv6.GetAttackOrderStartDelay(hero),
            scaled_attack_point,
            base_attack_point,
            attack_point_scale,
            get_predict_ready_late_limit(hero),
            start_check_timeout
        )
    end
    debug_log(("ISSUE_ATTACK target=%s kind=%s hero_hit_delay=%.4f predict_delay=%.4f raw_delay=%.4f ping=%.4f lead_latency=%.4f fixed=%.4f lead=%.4f launch_delay=%.4f confirm_timeout=%.4f%s"):format(
        get_debug_target_text(hero, target),
        attack_kind,
        get_hero_hit_delay(hero, target),
        prediction_attack_delay,
        raw_attack_delay,
        network_latency,
        latency_for_lead,
        ATTACK_ORDER_FIXED_LEAD,
        order_lead,
        issue_launch_delay,
        confirmation_timeout,
        attack_debug
    ))
    attack_confirmation_order_seen = false
    local order_ok, order_error, order_method = execute_attack_target(player, hero, target)
    if not order_ok then
        debug_log(("ATTACK_ORDER_ERROR method=%s target=%s error=%s"):format(
            tostring(order_method),
            get_debug_target_text(hero, target),
            tostring(order_error)
        ))
        return false
    end
    debug_log(("ATTACK_ORDER_SENT method=%s target=%s"):format(
        tostring(order_method),
        get_debug_target_text(hero, target)
    ))

    last_attack_issue = {
        target_index = get_entity_index(target),
        issue_time = now,
        raw_attack_delay = raw_attack_delay,
        prediction_attack_delay = prediction_attack_delay,
        network_latency = network_latency,
        order_lead = order_lead,
        kind = attack_kind,
    }
    local sync_target_health = nil
    if pending_attack_prediction and pending_attack_target_index == get_entity_index(target) then
        sync_target_health = pending_attack_predicted_health
    end
    LASThitv6.QueueSyncedAttacks(player, hero, target, now, target_is_friendly, now + prediction_attack_delay, attack_kind, sync_target_health)
    if NPC.IsRanged(hero) ~= true and attack_kind ~= "tower_setup" then
        if allow_gap_close_attack then
            local damage_min, damage_max = get_attack_damage_range_vs_target(hero, target)
            remember_our_pending_hit(target, now + prediction_attack_delay, damage_min, damage_max)
        else
            remember_our_melee_pending_hit(hero, target, now)
        end
    end
    attack_confirmation_target_index = get_entity_index(target)
    attack_confirmation_target_is_friendly = target_is_friendly
    attack_confirmation_issue_time = now
    attack_confirmation_until = now + confirmation_timeout
    LASThitv6.attack_confirmation_start_check_until = now + start_check_timeout
    LASThitv6.attack_confirmation_started = false
    if NPC.IsRanged(hero) ~= true and attack_kind ~= "tower_setup" then
        LASThitv6.LockMeleeHardTarget(target, attack_confirmation_until, attack_kind, LASThitv6.GetSelectedMoveUnits(player, hero), hero)
    end
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
    pending_attack_attack_delay = 0
    pending_attack_move_lock_logged = false
    LASThitv6.pending_attack_preposition_logged = false
    return true
end

function LASThitv6.TryRetryMeleeAttackStart(player, hero, target, now, target_is_friendly, reason)
    if not player
        or not hero
        or not target
        or NPC.IsRanged(hero) == true
        or Entity.IsAlive(target) ~= true
    then
        return false
    end

    local target_index = get_entity_index(target)
    local blocked_until = LASThitv6.attack_confirm_retry_block_until[target_index] or 0
    if blocked_until > now then
        return false
    end

    if not is_target_ready_for_action(hero, target, target_is_friendly) then
        return "wait"
    end

    local approach_time, distance, reach, gap, in_range, move_speed = LASThitv6.GetMeleeApproachTime(hero, target)
    if not in_range and approach_time > LASThitv6.MELEE_CONFIRM_RETRY_MAX_APPROACH then
        return "wait"
    end

    local will_die, lethal_in = will_target_die_before_our_hit(hero, target, now, target_is_friendly)
    if will_die then
        debug_log(("ATTACK_CONFIRM_RETRY_SKIP target=%s reason=target_will_die lethal_in=%.4f distance=%.1f reach=%.1f gap=%.1f approach=%.4f move_speed=%.1f"):format(
            get_debug_target_text(hero, target),
            lethal_in,
            distance,
            reach,
            gap,
            approach_time,
            move_speed
        ))
        return false
    end

    debug_log(("ATTACK_CONFIRM_RETRY target=%s reason=%s distance=%.1f reach=%.1f gap=%.1f approach=%.4f move_speed=%.1f"):format(
        get_debug_target_text(hero, target),
        tostring(reason or "no_attack_start"),
        distance,
        reach,
        gap,
        approach_time,
        move_speed
    ))

    LASThitv6.attack_confirm_retry_block_until[target_index] = now + LASThitv6.ATTACK_CONFIRM_RETRY_COOLDOWN
    LASThitv6.ClearOurPendingHit(target)
    last_attack_issue = nil
    clear_attack_confirmation()
    next_attack_schedule_time = now
    return issue_attack_target_once(player, hero, target, now, target_is_friendly, false, "attack") == true
end

local function get_projectile_impact_time(source, target, now)
    local projectile_speed = tonumber(NPC.GetAttackProjectileSpeed(source) or 0) or 0
    if projectile_speed <= 0 then
        return nil
    end

    return now + (LASThitv6.GetProjectileTravelDistance(source, target) / projectile_speed)
end

local function get_tower_attack_target(tower)
    if not Tower or type(Tower.GetAttackTarget) ~= "function" then
        return nil
    end

    local target = safe_call(Tower.GetAttackTarget, tower)
    if target and Entity.IsEntity(target) == true then
        return target
    end

    return nil
end

local function remember_ranged_attack_projectile(source, target, attack_start)
    local attack_point = LASThitv6.GetScaledAttackAnimPoint(source)
    local launch_time = attack_start + attack_point
    local impact_time = get_projectile_impact_time(source, target, launch_time)
    if not impact_time then
        return false, nil
    end

    set_projectile_hit_timer(source, target, impact_time)
    remember_next_creep_attack(source, target, attack_start)
    return true, impact_time
end

get_future_attack_hit_time = function(source, target, attack_start)
    local hit_time = attack_start + LASThitv6.GetScaledAttackAnimPoint(source)

    if NPC.IsRanged(source) == true then
        local projectile_speed = tonumber(NPC.GetAttackProjectileSpeed(source) or 0) or 0
        if projectile_speed <= 0 then
            return nil
        end

        hit_time = hit_time + (LASThitv6.GetProjectileTravelDistance(source, target) / projectile_speed)
    end

    return hit_time
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

local function is_attack_source_targeting(source, target)
    if NPC.IsTower(source) == true then
        local tower_target = get_tower_attack_target(source)
        return tower_target and get_entity_index(tower_target) == get_entity_index(target)
    end

    return is_facing_target(source, target)
end

local function prime_tower_attack_clocks(hero, now, target_is_friendly)
    if not Towers or type(Towers.GetAll) ~= "function" then
        return
    end

    local towers = safe_call(Towers.GetAll)
    if type(towers) ~= "table" then
        return
    end

    for _, tower in pairs(towers) do
        if tower and Entity.IsAlive(tower) == true then
            local target = get_tower_attack_target(tower)
            if target
                and is_valid_creep_target(hero, target, target_is_friendly)
                and is_source_for_target_side(hero, tower, target_is_friendly)
            then
                local source_index = get_entity_index(tower)
                local target_index = get_entity_index(target)
                local projectile = active_projectiles[source_index]
                local has_exact_projectile = projectile
                    and projectile.target_index == target_index
                    and projectile.impact_time > now
                local clock = creep_attack_clocks[source_index]

                if not has_exact_projectile
                    and (not clock or clock.target_index ~= target_index)
                then
                    local attack_period = tonumber(get_attack_period(tower) or 0) or 0
                    local hit_time = get_future_attack_hit_time(tower, target, now)
                    if attack_period > 0 and hit_time and hit_time > now then
                        creep_attack_clocks[source_index] = {
                            source_index = source_index,
                            target_index = target_index,
                            next_attack_start = now,
                            attack_period = attack_period,
                            is_ranged = true,
                            is_tower = true,
                            estimated = true,
                        }

                        local damage_min, damage_max = get_attack_damage_range_vs_target(tower, target)
                        debug_log(("TOWER_TARGET_PREDICT target=%s damage=%d-%d projectile_speed=%d impact_in=%.4f"):format(
                            get_debug_target_text(hero, target),
                            damage_min,
                            damage_max,
                            tonumber(NPC.GetAttackProjectileSpeed(tower) or 0) or 0,
                            hit_time - now
                        ))
                    end
                end
            end
        end
    end
end

function LASThitv6.GetIncomingHitEvents(hero, now, target_is_friendly)
    local events = {}

    prime_tower_attack_clocks(hero, now, target_is_friendly)

    if target_is_friendly == false then
        for target_index, setup_hit in pairs(active_setup_hits) do
            local target = get_live_creep_by_index(hero, target_index, false)
            if not target or setup_hit.hit_time <= now then
                active_setup_hits[target_index] = nil
            else
                events[#events + 1] = {
                    kind = "our_setup",
                    source_index = get_entity_index(hero),
                    target_index = target_index,
                    hit_time = setup_hit.hit_time,
                    damage = tonumber(setup_hit.damage or 0) or 0,
                    damage_min = tonumber(setup_hit.damage_min or setup_hit.damage or 0) or 0,
                    damage_max = tonumber(setup_hit.damage_max or setup_hit.damage or 0) or 0,
                }
            end
        end
    end

    LASThitv6.AddShrapnelDamageEvents(hero, now, target_is_friendly, events)
    LASThitv6.AddShadowStrikeDamageEvents(hero, now, target_is_friendly, events)

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
                damage_min = tonumber(projectile.damage_min or projectile.damage or 0) or 0,
                damage_max = tonumber(projectile.damage_max or projectile.damage or 0) or 0,
                is_tower = projectile.is_tower == true,
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
                damage_min = tonumber(swing.damage_min or swing.damage or 0) or 0,
                damage_max = tonumber(swing.damage_max or swing.damage or 0) or 0,
            }
        end
    end

    for source_index, clock in pairs(creep_attack_clocks) do
        local source = get_live_npc_by_index(clock.source_index)
        local target = get_live_creep_by_index(hero, clock.target_index, target_is_friendly)

        if not source then
            creep_attack_clocks[source_index] = nil
        elseif target and is_source_for_target_side(hero, source, target_is_friendly) and is_attack_source_targeting(source, target) then
            local attack_period = tonumber(clock.attack_period or get_attack_period(source) or 0) or 0
            if attack_period <= 0 then
                creep_attack_clocks[source_index] = nil
            else
                while clock.next_attack_start + attack_period < now do
                    clock.next_attack_start = clock.next_attack_start + attack_period
                end

                for attack_number = 1, PREDICTION_FUTURE_ATTACK_COUNT do
                    local attack_start = clock.next_attack_start + (attack_period * (attack_number - 1))
                    if attack_start - now > PREDICTION_FUTURE_ATTACK_HORIZON then
                        break
                    end

                    local hit_time = get_future_attack_hit_time(source, target, attack_start)
                    if hit_time and hit_time > now and hit_time - now <= PREDICTION_FUTURE_ATTACK_HORIZON then
                        local damage_min, damage_max = get_attack_damage_range_vs_target(source, target)
                        events[#events + 1] = {
                            kind = clock.is_ranged and "future_projectile" or "future_melee",
                            source_index = clock.source_index,
                            target_index = clock.target_index,
                            attack_start = attack_start,
                            hit_time = hit_time,
                            damage = damage_min,
                            damage_min = damage_min,
                            damage_max = damage_max,
                            is_tower = clock.is_tower == true,
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

local function get_event_damage_min(event)
    return tonumber(event.damage_min or event.damage or 0) or 0
end

local function get_event_damage_max(event)
    local damage_min = get_event_damage_min(event)
    local damage_max = tonumber(event.damage_max or event.damage or damage_min) or damage_min
    if damage_max < damage_min then
        return damage_min
    end

    return damage_max
end

local function get_event_damage_uncertainty(event)
    return math.max(0, get_event_damage_max(event) - get_event_damage_min(event))
end

function LASThitv6.GetPredictionConfidence(events)
    for i = 1, #(events or {}) do
        local kind = events[i].kind
        if kind == "glyph_end" then
            return "glyph"
        end
        if kind == "shrapnel_tick" then
            return "shrapnel"
        end
        if kind == "shadow_strike_tick" then
            return "shadow_strike"
        end
        if events[i].is_tower == true then
            return "tower"
        end
        if kind == "future_melee" or kind == "future_projectile" then
            return "future"
        end
    end

    return "confirmed"
end

local function get_prediction_replay_tolerance(events)
    local tolerance = 0
    for i = 1, #(events or {}) do
        tolerance = tolerance + get_event_damage_uncertainty(events[i])
    end

    return tolerance
end

function LASThitv6.GetTargetHitGroups(events, target_index)
    local groups = {}
    local group = nil

    for i = 1, #events do
        local event = events[i]
        if event.target_index == target_index then
            if not group or event.hit_time - group.hit_time > HIT_GROUP_WINDOW then
                group = {
                    hit_time = event.hit_time,
                    damage = 0,
                    damage_min = 0,
                    damage_max = 0,
                    events = {},
                }
                groups[#groups + 1] = group
            end

            if event.hit_time > group.hit_time then
                group.hit_time = event.hit_time
            end
            local damage_min = get_event_damage_min(event)
            local damage_max = get_event_damage_max(event)
            group.damage = group.damage + damage_min
            group.damage_min = group.damage_min + damage_min
            group.damage_max = group.damage_max + damage_max
            group.events[#group.events + 1] = event
        end
    end

    table.sort(groups, function(a, b)
        return a.hit_time < b.hit_time
    end)

    return groups
end

will_target_die_before_our_hit = function(hero, target, now, target_is_friendly)
    local target_index = get_entity_index(target)
    local health_after_hits = tonumber(Entity.GetHealth(target) or 0) or 0
    local deadline = now + get_prediction_attack_delay(hero, target)
    local approach_time = LASThitv6.GetAttackApproachTime(hero, target)
    deadline = deadline + approach_time
    local events = LASThitv6.GetIncomingHitEvents(hero, now, target_is_friendly)
    local shield_end_time = LASThitv6.GetGlyphShieldEndTime(target, now)

    for i = 1, #events do
        local event = events[i]
        if event.target_index == target_index
            and event.hit_time <= deadline
            and not (shield_end_time and event.hit_time <= shield_end_time)
        then
            health_after_hits = health_after_hits - (tonumber(event.damage or 0) or 0)
            if health_after_hits <= 0 then
                return true, event.hit_time - now
            end
        end
    end

    return false, 0
end

local function find_incoming_hit_prediction(hero, creeps, now, target_is_friendly)
    local events = LASThitv6.GetIncomingHitEvents(hero, now, target_is_friendly)
    local best_prediction = nil

    for i = 1, #creeps do
        local creep = creeps[i]
        if creep.is_friendly == target_is_friendly
            and creep.health > creep.min_damage
            and not is_our_hit_pending(creep.npc, now)
        then
            local health_after_hits_min = creep.health
            local health_after_hits_max = creep.health
            local contributing_events = {}
            local hit_groups = LASThitv6.GetTargetHitGroups(events, creep.index)
            local shield_end_time = LASThitv6.GetGlyphShieldEndTime(creep.npc, now)

            for j = 1, #hit_groups do
                local hit_group = hit_groups[j]
                if not (shield_end_time and hit_group.hit_time <= shield_end_time) then
                    health_after_hits_min = health_after_hits_min - hit_group.damage_max
                    health_after_hits_max = health_after_hits_max - hit_group.damage_min
                    for k = 1, #hit_group.events do
                        contributing_events[#contributing_events + 1] = hit_group.events[k]
                    end

                    if health_after_hits_max <= 0 then
                        break
                    end

                    if is_target_actionable_after_hits(creep, health_after_hits_max) then
                        local hero_hit_delay = get_prediction_attack_delay(hero, creep.npc)
                        local order_lead = get_prediction_issue_lead(hero)
                        local has_tower_hit = false
                        for k = 1, #hit_group.events do
                            if hit_group.events[k].is_tower == true then
                                has_tower_hit = true
                                break
                            end
                        end
                        local landing_buffer = get_prediction_landing_buffer(hero, LASThitv6.GetPredictionAfterHitBuffer(hero, has_tower_hit))
                        local network_latency = get_network_latency()
                        local wanted_land_time = hit_group.hit_time + landing_buffer
                        local execute_time = wanted_land_time - hero_hit_delay
                        local timing_error = execute_time - now
                        local execute_late = now - execute_time
                        local candidate = {
                            creep = creep,
                            base_health = creep.health,
                            execute_time = execute_time,
                            incoming_time = hit_group.hit_time,
                            target_is_friendly = creep.is_friendly,
                            health_after_hits = health_after_hits_max,
                            health_after_hits_min = health_after_hits_min,
                            health_after_hits_max = health_after_hits_max,
                            attack_delay = hero_hit_delay,
                            raw_attack_delay = get_raw_prediction_attack_delay(hero, creep.npc),
                            network_latency = network_latency,
                            order_lead = order_lead,
                            landing_buffer = landing_buffer,
                            events = contributing_events,
                            confidence = LASThitv6.GetPredictionConfidence(contributing_events),
                        }

                        local attack_reachable, attack_distance, attack_reach, attack_gap, attack_approach, attack_available, attack_move_speed =
                            LASThitv6.IsAttackReachableByExecuteTime(hero, creep.npc, now, execute_time)
                        candidate.attack_approach_time = attack_approach
                        candidate.attack_move_speed = attack_move_speed
                        if not attack_reachable then
                            if should_log_missed_prediction(candidate, now) then
                                debug_log(("PREDICT_CANDIDATE_SKIP target=%s#%d reason=attack_unreachable predicted_hp=%d hp_range=%d-%d incoming_in=%.4f execute_in=%.4f approach=%.4f available=%.4f move_speed=%.1f distance=%.1f reach=%.1f gap=%.1f ranged=%s predict_delay=%.4f confidence=%s events=%d"):format(
                                    creep.name,
                                    creep.index,
                                    math.floor(health_after_hits_max + 0.5),
                                    math.floor(health_after_hits_min + 0.5),
                                    math.floor(health_after_hits_max + 0.5),
                                    hit_group.hit_time - now,
                                    execute_time - now,
                                    attack_approach,
                                    attack_available,
                                    attack_move_speed,
                                    attack_distance,
                                    attack_reach,
                                    attack_gap,
                                    tostring(NPC.IsRanged(hero) == true),
                                    hero_hit_delay,
                                    candidate.confidence,
                                    #(contributing_events or {})
                                ))
                            end
                        elseif execute_late > get_predict_ready_late_limit(hero) then
                            if should_log_missed_prediction(candidate, now) then
                                debug_log(("PREDICT_CANDIDATE_SKIP target=%s#%d reason=timing_missed predicted_hp=%d hp_range=%d-%d incoming_in=%.4f execute_late=%.4f late_limit=%.4f predict_delay=%.4f ping=%.4f lead=%.4f land_buffer=%.4f confidence=%s events=%d"):format(
                                    creep.name,
                                    creep.index,
                                    math.floor(health_after_hits_max + 0.5),
                                    math.floor(health_after_hits_min + 0.5),
                                    math.floor(health_after_hits_max + 0.5),
                                    hit_group.hit_time - now,
                                    execute_late,
                                    get_predict_ready_late_limit(hero),
                                    hero_hit_delay,
                                    network_latency,
                                    order_lead,
                                    landing_buffer,
                                    candidate.confidence,
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
    end

    return best_prediction
end

local function find_tower_setup_candidate(hero, creeps, now)
    local events = LASThitv6.GetIncomingHitEvents(hero, now, false)
    local setup_attack_period = get_attack_period(hero)
    if not setup_attack_period then
        return nil
    end

    local function collect_target_events(target_index)
        local target_events = {}
        local has_tower_event = false

        for i = 1, #events do
            local event = events[i]
            if event.target_index == target_index and event.hit_time > now then
                target_events[#target_events + 1] = event
                if event.is_tower == true then
                    has_tower_event = true
                end
            end
        end

        table.sort(target_events, function(a, b)
            return a.hit_time < b.hit_time
        end)

        return target_events, has_tower_event
    end

    local function needs_setup_before_death(creep, target_events)
        local health_after_hits = creep.health

        for i = 1, #target_events do
            health_after_hits = health_after_hits - get_event_damage_min(target_events[i])

            if health_after_hits <= 0 then
                return true
            end
            if is_target_actionable_after_hits(creep, health_after_hits) then
                return false
            end
        end

        return false
    end

    local function apply_event_damage(health_min, health_max, event)
        return health_min - get_event_damage_max(event),
            health_max - get_event_damage_min(event)
    end

    for i = 1, #creeps do
        local creep = creeps[i]
        if creep.is_friendly == false
            and creep.health > creep.min_damage
            and not is_our_hit_pending(creep.npc, now)
            and not active_setup_hits[creep.index]
        then
            local target_events, has_tower_event = collect_target_events(creep.index)
            if has_tower_event and needs_setup_before_death(creep, target_events) then
                local setup_damage_min, setup_damage_max = get_attack_damage_range_vs_target(hero, creep.npc)
                local setup_hit_delay = get_hero_hit_delay(hero, creep.npc)
                local setup_hit_time = now + setup_hit_delay
                local setup_ready_time = now + setup_attack_period + ATTACK_RECOVERY_BUFFER

                for j = 1, #target_events do
                    local event = target_events[j]
                    if event.is_tower == true then
                        local final_land_time = event.hit_time + get_prediction_landing_buffer(hero, LASThitv6.GetPredictionAfterHitBuffer(hero, true))
                        local final_execute_time = final_land_time - get_prediction_attack_delay(hero, creep.npc)

                        if setup_hit_time < event.hit_time - TOWER_SETUP_BEFORE_HIT_BUFFER
                            and setup_ready_time <= final_execute_time
                            and final_execute_time > now
                        then
                            local health_after_setup_and_tower_min = creep.health
                            local health_after_setup_and_tower_max = creep.health
                            local setup_applied = false
                            local setup_valid = true

                            for k = 1, #target_events do
                                local sim_event = target_events[k]

                                if not setup_applied and setup_hit_time <= sim_event.hit_time then
                                    health_after_setup_and_tower_min = health_after_setup_and_tower_min - setup_damage_max
                                    health_after_setup_and_tower_max = health_after_setup_and_tower_max - setup_damage_min
                                    setup_applied = true

                                    if health_after_setup_and_tower_min <= 0 then
                                        setup_valid = false
                                        break
                                    end
                                end

                                if sim_event.hit_time > event.hit_time + HIT_GROUP_WINDOW then
                                    break
                                end

                                health_after_setup_and_tower_min, health_after_setup_and_tower_max =
                                    apply_event_damage(health_after_setup_and_tower_min, health_after_setup_and_tower_max, sim_event)

                                if sim_event.hit_time < event.hit_time - HIT_GROUP_WINDOW
                                    and health_after_setup_and_tower_max <= 0
                                then
                                    setup_valid = false
                                    break
                                end
                            end

                            if setup_valid
                                and setup_applied
                                and health_after_setup_and_tower_min > 0
                                and is_target_actionable_after_hits(creep, health_after_setup_and_tower_max)
                            then
                                return {
                                    creep = creep,
                                    setup_hit_time = setup_hit_time,
                                    tower_hit_time = event.hit_time,
                                    final_execute_time = final_execute_time,
                                    setup_ready_time = setup_ready_time,
                                    setup_damage_min = setup_damage_min,
                                    setup_damage_max = setup_damage_max,
                                    tower_damage_min = get_event_damage_min(event),
                                    tower_damage_max = get_event_damage_max(event),
                                    health_after_setup_and_tower_min = health_after_setup_and_tower_min,
                                    health_after_setup_and_tower_max = health_after_setup_and_tower_max,
                                }
                            end
                        end
                    end

                end
            end
        end
    end

    return nil
end

function LASThitv6.TryIssueTowerSetup(player, hero, creeps, now, reserved_execute_time)
    if now < next_attack_schedule_time then
        return false
    end

    local setup_candidate = find_tower_setup_candidate(hero, creeps, now)
    if not setup_candidate then
        return false
    end

    if reserved_execute_time
        and setup_candidate.setup_ready_time > reserved_execute_time - ATTACK_ORDER_FIXED_LEAD
    then
        debug_log(("TOWER_SETUP_SKIP target=%s reserved_execute_in=%.4f setup_ready_in=%.4f reason=attack_reserved"):format(
            get_debug_target_text(hero, setup_candidate.creep.npc),
            reserved_execute_time - now,
            setup_candidate.setup_ready_time - now
        ))
        return false
    end

    local target = get_live_enemy_creep_by_index(hero, setup_candidate.creep.index)
    if not target then
        return false
    end

    debug_log(("TOWER_SETUP_ISSUE target=%s hp=%d min=%d setup_damage=%d-%d tower_damage=%d-%d setup_hit_in=%.4f tower_hit_in=%.4f final_execute_in=%.4f ready_in=%.4f hp_after=%d-%d"):format(
        get_debug_target_text(hero, target),
        math.floor(setup_candidate.creep.health + 0.5),
        setup_candidate.creep.min_damage,
        setup_candidate.setup_damage_min,
        setup_candidate.setup_damage_max,
        setup_candidate.tower_damage_min,
        setup_candidate.tower_damage_max,
        setup_candidate.setup_hit_time - now,
        setup_candidate.tower_hit_time - now,
        setup_candidate.final_execute_time - now,
        setup_candidate.setup_ready_time - now,
        math.floor(setup_candidate.health_after_setup_and_tower_min + 0.5),
        math.floor(setup_candidate.health_after_setup_and_tower_max + 0.5)
    ))

    return issue_attack_target_once(player, hero, target, now, false, true, "tower_setup") == true
end

function LASThitv6.FindGlyphShieldPrediction(hero, creeps, now, target_is_friendly)
    for i = 1, #creeps do
        local creep = creeps[i]
        if creep.is_friendly == target_is_friendly
            and is_actionable_health(creep, creep.health)
            and not is_our_hit_pending(creep.npc, now)
        then
            local shield_end_time, modifier_name = LASThitv6.GetGlyphShieldEndTime(creep.npc, now)
            if shield_end_time then
                local attack_delay = get_prediction_attack_delay(hero, creep.npc)
                local raw_attack_delay = get_raw_prediction_attack_delay(hero, creep.npc)
                local order_lead = get_prediction_issue_lead(hero)
                local glyph_after_end_buffer = LASThitv6.GetGlyphImpactAfterEndBuffer(hero)
                local desired_impact_time = shield_end_time + get_prediction_landing_buffer(hero, glyph_after_end_buffer)
                local execute_time = desired_impact_time - attack_delay

                if execute_time - now <= PREDICT_ATTACK_EARLY_WINDOW then
                    return {
                        creep = creep,
                        base_health = creep.health,
                        execute_time = execute_time,
                        incoming_time = desired_impact_time,
                        target_is_friendly = creep.is_friendly,
                        health_after_hits = creep.health,
                        health_after_hits_min = creep.health,
                        health_after_hits_max = creep.health,
                        attack_delay = attack_delay,
                        raw_attack_delay = raw_attack_delay,
                        network_latency = get_network_latency(),
                        order_lead = order_lead,
                        landing_buffer = get_prediction_landing_buffer(hero, glyph_after_end_buffer),
                        confidence = "glyph",
                        glyph_end_time = shield_end_time,
                        glyph_modifier_name = modifier_name,
                        events = {
                            {
                                kind = "glyph_end",
                                target_index = creep.index,
                                hit_time = desired_impact_time,
                                shield_end_time = shield_end_time,
                                modifier_name = modifier_name,
                            },
                        },
                    }
                end
            end
        end
    end

    return nil
end

local function has_valid_incoming_hit_prediction(hero, target, now, target_is_friendly)
    local target_index = get_entity_index(target)
    local target_health = tonumber(Entity.GetHealth(target) or 0) or 0
    local min_damage = LASThitv6.GetEffectiveMinAttackDamageVsTarget(hero, target, now)
    local max_health = tonumber(Entity.GetMaxHealth(target) or 0) or 0
    local events = LASThitv6.GetIncomingHitEvents(hero, now, target_is_friendly)
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
    if incoming_time > 0 and now > incoming_time + PREDICTION_INCOMING_EXPIRE_GRACE then
        return false
    end

    return predicted_health <= LASThitv6.GetEffectiveMinAttackDamageVsTarget(hero, target, now)
end

local function has_valid_prediction_events(hero, target, now, predicted_health, incoming_time, events, base_health, target_is_friendly)
    local target_index = get_entity_index(target)
    local current_health = tonumber(Entity.GetHealth(target) or 0) or 0
    local max_health = tonumber(Entity.GetMaxHealth(target) or 0) or 0
    local expected_impact_time = now + get_prediction_attack_delay(hero, target)
    local min_damage, max_damage, sync_attack_count = LASThitv6.GetEffectiveAttackDamageRange(hero, target, now, expected_impact_time, predicted_health)
    local health_after_events = current_health
    local health_after_events_min = current_health
    local event_count = #(events or {})
    local replay_tolerance = get_prediction_replay_tolerance(events)
    predicted_health = tonumber(predicted_health or 0) or 0
    incoming_time = tonumber(incoming_time or 0) or 0
    base_health = tonumber(base_health or current_health) or current_health
    local grace = PREDICTION_EVENT_GRACE
    local confirmed_stale_grace = PREDICTION_CONFIRMED_EVENT_STALE_GRACE
    local future_expire_grace = PREDICTION_FUTURE_EVENT_EXPIRE_GRACE
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

        debug_log(("PREDICT_VALIDATE_FAIL target=%s reason=%s predicted_hp=%s incoming_in=%.4f base_hp=%d current_hp=%d recalculated_hp=%d hp_range=%d-%d min=%d max=%d sync=%d tolerance=%d events=%d grace_counted=%d stale_counted=%d reflected_past=%d expired_past=%d%s"):format(
            get_debug_target_text(hero, target),
            reason,
            tostring(predicted_health),
            incoming_time - now,
            math.floor(base_health + 0.5),
            math.floor(current_health + 0.5),
            math.floor(health_after_events + 0.5),
            math.floor(health_after_events_min + 0.5),
            math.floor(health_after_events + 0.5),
            min_damage,
            max_damage,
            sync_attack_count or 0,
            math.floor(replay_tolerance + 0.5),
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

    if incoming_time > 0 and now > incoming_time + PREDICTION_INCOMING_EXPIRE_GRACE then
        return fail(("incoming_expired age=%.4f"):format(now - incoming_time))
    end

    if predicted_health > min_damage
        and not (sync_attack_count and sync_attack_count > 0 and predicted_health <= max_damage)
    then
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

        if event.kind ~= "projectile"
            and event.kind ~= "melee"
            and event.kind ~= "future_melee"
            and event.kind ~= "future_projectile"
            and event.kind ~= "our_setup"
            and event.kind ~= "glyph_end"
            and event.kind ~= "shrapnel_tick"
            and event.kind ~= "shadow_strike_tick"
        then
            return fail("unknown_event_kind", event, ("event_index=%d"):format(i))
        end

        if event.hit_time > now then
            local damage = 0
            local damage_max = 0

            if event.kind == "glyph_end" then
                local shield_end_time = LASThitv6.GetGlyphShieldEndTime(target, now)
                local expected_impact_time = now + get_prediction_attack_delay(hero, target)
                if shield_end_time
                    and expected_impact_time < shield_end_time + LASThitv6.GetGlyphImpactAfterEndBuffer(hero) - 0.005
                then
                    return fail("glyph_still_active_for_impact", event, ("event_index=%d shield_ends_in=%.4f expected_impact_in=%.4f"):format(
                        i,
                        shield_end_time - now,
                        expected_impact_time - now
                    ))
                end
            elseif event.kind == "shrapnel_tick" then
                local pulse = LASThitv6.GetShrapnelPulse(target, now)
                if not pulse then
                    return fail("shrapnel_pulse_missing", event, ("event_index=%d"):format(i))
                end

                local interval = math.max(0.001, tonumber(pulse.interval or event.interval or LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL) or LASThitv6.SHRAPNEL_FALLBACK_TICK_INTERVAL)
                local first_hit_time = tonumber(pulse.first_hit_time or event.first_hit_time or 0) or 0
                local expires_at = tonumber(pulse.expires_at or event.expires_at or 0) or 0
                if event.hit_time > expires_at + PREDICTION_INCOMING_EXPIRE_GRACE then
                    return fail("shrapnel_tick_expired", event, ("event_index=%d expires_in=%.4f stored_hit_in=%.4f"):format(
                        i,
                        expires_at - now,
                        event.hit_time - now
                    ))
                end

                local tick_number = math.floor(((event.hit_time - first_hit_time) / interval) + 0.5)
                local expected_hit_time = first_hit_time + (tick_number * interval)
                if tick_number < 1 then
                    return fail("shrapnel_tick_before_grid", event, ("event_index=%d tick_number=%d"):format(i, tick_number))
                end
                if math.abs(expected_hit_time - event.hit_time) > PREDICTION_FUTURE_EVENT_EXPIRE_GRACE then
                    return fail("shrapnel_tick_shifted", event, ("event_index=%d expected_hit_in=%.4f stored_hit_in=%.4f"):format(
                        i,
                        expected_hit_time - now,
                        event.hit_time - now
                    ))
                end

                damage = tonumber(pulse.damage or event.damage or 0) or 0
                damage_max = damage
            elseif event.kind == "shadow_strike_tick" then
                local modifier = LASThitv6.GetShadowStrikeModifier(target)
                if not modifier then
                    return fail("shadow_strike_modifier_missing", event, ("event_index=%d"):format(i))
                end

                local interval = LASThitv6.GetShadowStrikeTickInterval(modifier)
                local creation_time = tonumber(safe_call(Modifier.GetCreationTime, modifier) or event.creation_time or 0) or 0
                local expires_at = LASThitv6.GetShadowStrikeEndTime(modifier) or tonumber(event.expires_at or 0) or 0
                if expires_at > 0 and event.hit_time > expires_at + PREDICTION_INCOMING_EXPIRE_GRACE then
                    return fail("shadow_strike_tick_expired", event, ("event_index=%d expires_in=%.4f stored_hit_in=%.4f"):format(
                        i,
                        expires_at - now,
                        event.hit_time - now
                    ))
                end

                if creation_time > 0 then
                    local tick_number = math.floor(((event.hit_time - creation_time) / interval) + 0.5)
                    local expected_hit_time = creation_time + (tick_number * interval)
                    if tick_number < 1 then
                        return fail("shadow_strike_tick_before_grid", event, ("event_index=%d tick_number=%d"):format(i, tick_number))
                    end
                    if math.abs(expected_hit_time - event.hit_time) > PREDICTION_FUTURE_EVENT_EXPIRE_GRACE then
                        return fail("shadow_strike_tick_shifted", event, ("event_index=%d expected_hit_in=%.4f stored_hit_in=%.4f"):format(
                            i,
                            expected_hit_time - now,
                            event.hit_time - now
                        ))
                    end
                end

                damage = LASThitv6.GetShadowStrikeDamagePerTick(target, modifier)
                damage_max = damage
            elseif event.kind == "projectile" then
                local projectile = active_projectiles[event.source_index]
                if not projectile or projectile.target_index ~= target_index or projectile.impact_time <= now then
                    return fail("projectile_missing_or_expired", event, ("event_index=%d"):format(i))
                end
                damage = get_event_damage_min(projectile)
                damage_max = get_event_damage_max(projectile)
            elseif event.kind == "melee" then
                local swing = active_melee_swings[event.source_index]
                if not swing or swing.target_index ~= target_index or swing.hit_time <= now then
                    return fail("melee_swing_missing_or_expired", event, ("event_index=%d"):format(i))
                end
                damage = get_event_damage_min(swing)
                damage_max = get_event_damage_max(swing)
            elseif event.kind == "our_setup" then
                local setup_hit = active_setup_hits[target_index]
                if not setup_hit or setup_hit.hit_time <= now then
                    return fail("setup_hit_missing_or_expired", event, ("event_index=%d"):format(i))
                end
                damage = get_event_damage_min(setup_hit)
                damage_max = get_event_damage_max(setup_hit)
            elseif event.kind == "future_melee" or event.kind == "future_projectile" then
                local source = get_live_npc_by_index(event.source_index)
                if not source or not is_source_for_target_side(hero, source, target_is_friendly) then
                    return fail("future_attack_clock_invalid", event, ("event_index=%d"):format(i))
                end

                if event.kind == "future_melee" then
                    local swing = active_melee_swings[event.source_index]
                    if swing and swing.target_index == target_index and swing.hit_time > now then
                        damage = get_event_damage_min(swing)
                        damage_max = get_event_damage_max(swing)
                    end
                else
                    local projectile = active_projectiles[event.source_index]
                    if projectile and projectile.target_index == target_index and projectile.impact_time > now then
                        damage = get_event_damage_min(projectile)
                        damage_max = get_event_damage_max(projectile)
                    end
                end

                if damage <= 0 then
                    local clock = creep_attack_clocks[event.source_index]
                    if not clock or clock.target_index ~= target_index then
                        return fail("future_attack_clock_invalid", event, ("event_index=%d"):format(i))
                    end
                    if not is_attack_source_targeting(source, target) then
                        return fail("future_attack_not_facing_target", event, ("event_index=%d"):format(i))
                    end

                    local expected_hit_time = get_future_attack_hit_time(source, target, event.attack_start or clock.next_attack_start)
                    if not expected_hit_time then
                        return fail("future_attack_no_expected_hit_time", event, ("event_index=%d"):format(i))
                    end
                    if math.abs(expected_hit_time - event.hit_time) > future_expire_grace then
                        return fail("future_attack_clock_shifted", event, ("event_index=%d expected_hit_in=%.4f stored_hit_in=%.4f future_grace=%.4f"):format(
                            i,
                            expected_hit_time - now,
                            event.hit_time - now,
                            future_expire_grace
                        ))
                    end
                    if expected_hit_time <= now then
                        if now - expected_hit_time <= future_expire_grace and event.hit_time > now then
                            damage = get_event_damage_min(event)
                            damage_max = get_event_damage_max(event)
                            stale_counted_damage = stale_counted_damage + damage
                        else
                            return fail("future_attack_expected_hit_expired", event, ("event_index=%d expected_hit_in=%.4f future_grace=%.4f"):format(i, expected_hit_time - now, future_expire_grace))
                        end
                    else
                        damage, damage_max = get_attack_damage_range_vs_target(source, target)
                    end
                end
            end

            health_after_events = health_after_events - damage
            health_after_events_min = health_after_events_min - damage_max
        else
            local damage = get_event_damage_min(event)
            local damage_max = get_event_damage_max(event)
            local age = now - event.hit_time
            past_damage = past_damage + damage

            if age <= grace then
                local expected_after_past = base_health - past_damage
                if current_health > expected_after_past + get_event_damage_uncertainty(event) then
                    health_after_events = health_after_events - damage
                    health_after_events_min = health_after_events_min - damage_max
                    grace_counted_damage = grace_counted_damage + damage
                else
                    reflected_past_damage = reflected_past_damage + damage
                end
            elseif (event.kind == "projectile"
                or event.kind == "melee"
                or event.kind == "future_melee"
                or event.kind == "future_projectile"
                or event.kind == "our_setup"
                or event.kind == "shrapnel_tick"
                or event.kind == "shadow_strike_tick")
                and age <= confirmed_stale_grace
            then
                local expected_after_past = base_health - past_damage
                if current_health > expected_after_past + get_event_damage_uncertainty(event) then
                    health_after_events = health_after_events - damage
                    health_after_events_min = health_after_events_min - damage_max
                    stale_counted_damage = stale_counted_damage + damage
                else
                    reflected_past_damage = reflected_past_damage + damage
                end
            else
                local expected_after_past = base_health - past_damage
                if current_health > expected_after_past + get_event_damage_uncertainty(event) then
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

    if health_after_events <= 0 then
        return fail("recalculated_hp_dead")
    end

    if health_after_events > predicted_health + replay_tolerance then
        return fail("recalculated_hp_above_prediction")
    end

    local sync_range_killable = sync_attack_count
        and sync_attack_count > 0
        and health_after_events_min <= min_damage
        and health_after_events <= max_damage

    if health_after_events > min_damage and not sync_range_killable then
        if expired_past_damage > 0 then
            return fail("past_event_not_reflected_after_grace", expired_past_event, expired_past_extra)
        end
        return fail("recalculated_hp_above_min")
    end

    if target_is_friendly and not is_deniable_health(health_after_events, max_health) then
        return fail("recalculated_hp_not_deniable")
    end

    return true
end

ui.enable:SetCallback(update_menu_state, true)
ui.visuals_enable:SetCallback(update_menu_state, true)
ui.attack_range:SetCallback(update_menu_state, true)

function LASThitv6.OnDraw()
    if not is_ready_to_draw() then
        LASThitv6.DestroyRadiusParticles()
        return
    end

    local hero = get_local_hero()
    if not hero then
        LASThitv6.DestroyRadiusParticles()
        return
    end

    local hero_position = Entity.GetAbsOrigin(hero)
    local creeps = get_creeps_in_radius(hero, ui.work_radius:Get())

    if not LASThitv6.UpdateRadiusParticle("work", ui.ring_particle, get_ring_color(), ui.work_radius:Get(), hero) then
        draw_radius_circle(hero_position, ui.work_radius:Get(), get_ring_color())
    end
    if ui.attack_range:Get() then
        local attack_range = LASThitv6.GetHeroAttackRange(hero)
        if attack_range > 0 then
            if not LASThitv6.UpdateRadiusParticle("attack", ui.attack_range_particle, LASThitv6.GetAttackRangeColor(), attack_range, hero) then
                draw_radius_circle(hero_position, attack_range, LASThitv6.GetAttackRangeColor())
            end
        else
            LASThitv6.DestroyRadiusParticle("attack")
        end
    else
        LASThitv6.DestroyRadiusParticle("attack")
    end
    draw_creep_box(hero_position, creeps)

    if ui.debug:Get() then
        draw_facing_target_lines(creeps)
        draw_attack_hit_timers(creeps)
        draw_prediction_debug()
    end
end

local function handle_attack_confirmation(player, hero, now)
    if attack_confirmation_until <= 0 then
        return false
    end

    if attack_confirmation_until > now then
        local target = get_live_creep_by_index(hero, attack_confirmation_target_index, attack_confirmation_target_is_friendly)
        local hero_is_attacking = safe_call(NPC.IsAttacking, hero) == true
        local target_text = target and get_debug_target_text(hero, target) or ("index=" .. tostring(attack_confirmation_target_index))
        local target_hp = target and math.floor((tonumber(Entity.GetHealth(target) or 0) or 0) + 0.5) or -1
        local target_valid = target and is_valid_creep_target(hero, target, attack_confirmation_target_is_friendly) == true
        local target_distance = target and distance_2d(Entity.GetAbsOrigin(hero), Entity.GetAbsOrigin(target)) or -1
        local face_time = target and get_hero_face_time(hero, target) or -1

        if hero_is_attacking then
            LASThitv6.attack_confirmation_started = true
        end

        if not target or target_valid ~= true then
            local reason = target and "target_invalid" or "target_dead_or_stale"
            debug_log(("ATTACK_CONFIRM_EARLY_FAIL target=%s reason=%s order_seen=%s waited=%.4f hero_attacking=%s target_valid=%s hp=%d distance=%.1f face=%.4f"):format(
                target_text,
                reason,
                tostring(attack_confirmation_order_seen),
                now - attack_confirmation_issue_time,
                tostring(hero_is_attacking),
                tostring(target_valid),
                target_hp,
                target_distance,
                face_time
            ))
            LASThitv6.ClearMeleeHardLock(reason)
            clear_attack_confirmation()
            next_attack_schedule_time = now
            return false
        end

        LASThitv6.MaintainMeleeHardLock(player, hero, now)

        if LASThitv6.attack_confirmation_started == true then
            if NPC.IsRanged(hero) == true then
                if now >= (LASThitv6.attack_confirmation_start_check_until or 0) then
                    LASThitv6.attack_confirmation_start_check_until = now + math.max(MOVE_ORDER_INTERVAL, LASThitv6.GetTickInterval() * 2)
                end
                clear_pending_move()
                return true
            end

            clear_pending_move()
            return true
        end

        if now >= (LASThitv6.attack_confirmation_start_check_until or 0) then
            local reason = attack_confirmation_order_seen == true and "no_attack_start" or "order_not_seen"
            if attack_confirmation_order_seen == true and NPC.IsRanged(hero) == true then
                reason = "no_projectile"
            end
            local retry_result = LASThitv6.TryRetryMeleeAttackStart(player, hero, target, now, attack_confirmation_target_is_friendly, reason)
            if retry_result == true then
                return true
            end
            if retry_result == "wait" then
                LASThitv6.attack_confirmation_start_check_until = now + MOVE_ORDER_INTERVAL
                clear_pending_move()
                return true
            end

            debug_log(("ATTACK_CONFIRM_EARLY_FAIL target=%s reason=%s order_seen=%s waited=%.4f hero_attacking=%s target_valid=%s hp=%d distance=%.1f face=%.4f"):format(
                target_text,
                reason,
                tostring(attack_confirmation_order_seen),
                now - attack_confirmation_issue_time,
                tostring(hero_is_attacking),
                tostring(target_valid),
                target_hp,
                target_distance,
                face_time
            ))
            LASThitv6.ClearMeleeHardLock(reason)
            clear_attack_confirmation()
            next_attack_schedule_time = now
            return false
        end

        clear_pending_move()
        return true
    end

    local target = get_live_creep_by_index(hero, attack_confirmation_target_index, attack_confirmation_target_is_friendly)
    local hero_is_attacking = safe_call(NPC.IsAttacking, hero) == true
    local target_text = target and get_debug_target_text(hero, target) or ("index=" .. tostring(attack_confirmation_target_index))
    local target_hp = target and math.floor((tonumber(Entity.GetHealth(target) or 0) or 0) + 0.5) or -1
    local target_valid = target and is_valid_creep_target(hero, target, attack_confirmation_target_is_friendly) == true
    local target_distance = target and distance_2d(Entity.GetAbsOrigin(hero), Entity.GetAbsOrigin(target)) or -1
    local face_time = target and get_hero_face_time(hero, target) or -1
    local reason = NPC.IsRanged(hero) == true and "no_projectile" or "no_melee_animation"
    if not target then
        reason = "target_dead_or_stale"
    elseif attack_confirmation_order_seen ~= true then
        reason = "order_not_seen"
    end

    debug_log(("ATTACK_CONFIRM_FAILED target=%s reason=%s order_seen=%s waited=%.4f hero_attacking=%s target_valid=%s hp=%d distance=%.1f face=%.4f"):format(
        target_text,
        reason,
        tostring(attack_confirmation_order_seen),
        now - attack_confirmation_issue_time,
        tostring(hero_is_attacking),
        tostring(target_valid),
        target_hp,
        target_distance,
        face_time
    ))
    LASThitv6.ClearMeleeHardLock(reason)
    clear_attack_confirmation()
    next_attack_schedule_time = now + ATTACK_ORDER_INTERVAL
    return false
end

function LASThitv6.OnUpdate()
    if not Engine.IsInGame() then
        LASThitv6.DestroyRadiusParticles()
        clear_pending_orders()
        clear_attack_hit_timers()
        return
    end

    if not LASThitv6.IsWorkActive() then
        LASThitv6.DestroyRadiusParticles()
        clear_pending_orders()
        return
    end

    local hero = get_local_hero()
    local player = Players.GetLocal()
    if not hero or not player then
        LASThitv6.DestroyRadiusParticles()
        return
    end

    local now = get_time()
    clear_expired_setup_hits(now)
    clear_expired_our_pending_hits(now)

    local creeps = get_creeps_in_radius(hero, ui.work_radius:Get())
    local enemy_mode = is_enemy_creeps_enabled()
    local friendly_mode = is_friendly_creeps_enabled()

    if not enemy_mode and not friendly_mode then
        run_move_orders(player, hero, now)
        return
    end

    if pending_attack_target_index and pending_attack_prediction and now < pending_attack_execute_time then
        local preposition_target = get_live_creep_by_index(hero, pending_attack_target_index, pending_attack_is_friendly)
        if preposition_target then
            LASThitv6.TryPrepositionPendingAttack(player, hero, preposition_target, now)
        end
    end

    LASThitv6.ProcessSyncAttackQueue(player, hero, now)
    LASThitv6.ProcessSyncAttackConfirmations(player, hero, now)

    if handle_attack_confirmation(player, hero, now) then
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
                local refreshed_attack_delay = has_target_refreshed_prediction
                    and (refreshed_prediction.attack_delay or get_prediction_attack_delay(hero, target))
                    or 0

                local old_execute_in = pending_attack_execute_time - now
                local direct_override_window = get_pending_direct_override_window()
                local target_directly_ready = is_target_ready_for_action(hero, target, pending_attack_is_friendly)
                local target_health_now = tonumber(Entity.GetHealth(target) or 0) or 0
                local hero_min_damage = 0
                if target_directly_ready then
                    hero_min_damage = get_attack_damage_range_vs_target(hero, target)
                end
                local hero_directly_ready = target_directly_ready
                    and target_health_now > 0
                    and target_health_now <= hero_min_damage
                local can_direct_override = target_directly_ready
                    and (hero_directly_ready or old_execute_in <= direct_override_window)
                if can_direct_override then
                    local direct_override_reason = (not pending_attack_is_friendly and hero_directly_ready)
                        and "enemy_direct_ready"
                        or "close_pending"
                    debug_log(("PENDING_DIRECT_OVERRIDE target=%s old_execute_in=%.4f window=%.4f reason=%s"):format(
                        get_debug_target_text(hero, target),
                        old_execute_in,
                        direct_override_window,
                        direct_override_reason
                    ))
                    if issue_attack_target_once(player, hero, target, now, pending_attack_is_friendly, true) then
                        return
                    end
                end

                local refreshed_execute_delta = has_target_refreshed_prediction
                    and (refreshed_prediction.execute_time - pending_attack_execute_time)
                    or 0
                local should_refresh_pending = has_target_refreshed_prediction
                    and math.abs(refreshed_execute_delta) > PREDICTION_REFRESH_EPSILON
                local previous_attack_delay = pending_attack_attack_delay > 0
                    and pending_attack_attack_delay
                    or refreshed_attack_delay
                local attack_delay_delta = previous_attack_delay - refreshed_attack_delay
                local pending_future_clock_shifted = false
                if should_refresh_pending and refreshed_execute_delta > 0 then
                    for i = 1, #(pending_attack_events or {}) do
                        local event = pending_attack_events[i]
                        if event.kind == "future_melee" or event.kind == "future_projectile" then
                            local source = get_live_npc_by_index(event.source_index)
                            local clock = source and creep_attack_clocks[event.source_index] or nil
                            local expected_hit_time = nil
                            if source and clock and clock.target_index == pending_attack_target_index then
                                expected_hit_time = get_future_attack_hit_time(source, target, event.attack_start or clock.next_attack_start)
                            end
                            if not expected_hit_time or math.abs(expected_hit_time - event.hit_time) > PREDICTION_FUTURE_EVENT_EXPIRE_GRACE then
                                pending_future_clock_shifted = true
                                break
                            end
                        end
                    end
                end
                if should_refresh_pending
                    and refreshed_execute_delta > 0
                    and not pending_future_clock_shifted
                    and (attack_delay_delta <= PREDICTION_REFRESH_EPSILON
                        or refreshed_execute_delta > attack_delay_delta + PREDICTION_REFRESH_EPSILON)
                then
                    debug_log(("PENDING_REFRESH_IGNORE_LATER target=%s old_execute_in=%.4f new_execute_in=%.4f execute_delta=%.4f attack_delay_delta=%.4f reason=incoming_time_jitter"):format(
                        get_debug_target_text(hero, target),
                        pending_attack_execute_time - now,
                        refreshed_prediction.execute_time - now,
                        refreshed_execute_delta,
                        attack_delay_delta
                    ))
                    should_refresh_pending = false
                elseif should_refresh_pending
                    and refreshed_execute_delta > 0
                    and pending_future_clock_shifted
                then
                    debug_log(("PENDING_REFRESH_ALLOW_LATER target=%s old_execute_in=%.4f new_execute_in=%.4f execute_delta=%.4f reason=future_clock_shifted"):format(
                        get_debug_target_text(hero, target),
                        pending_attack_execute_time - now,
                        refreshed_prediction.execute_time - now,
                        refreshed_execute_delta
                    ))
                end
                if should_refresh_pending then
                    local execute_late = now - refreshed_prediction.execute_time
                    debug_log(("PENDING_REFRESH_PREDICT target=%s old_execute_in=%.4f new_execute_in=%.4f execute_delta=%.4f attack_delay_delta=%.4f execute_late=%.4f predicted_hp=%d hp_range=%d-%d incoming_in=%.4f land_buffer=%.4f confidence=%s events=%d"):format(
                        get_debug_target_text(hero, target),
                        pending_attack_execute_time - now,
                        refreshed_prediction.execute_time - now,
                        refreshed_execute_delta,
                        attack_delay_delta,
                        execute_late,
                        math.floor(refreshed_prediction.health_after_hits + 0.5),
                        math.floor((refreshed_prediction.health_after_hits_min or refreshed_prediction.health_after_hits) + 0.5),
                        math.floor((refreshed_prediction.health_after_hits_max or refreshed_prediction.health_after_hits) + 0.5),
                        refreshed_prediction.incoming_time - now,
                        refreshed_prediction.landing_buffer or 0,
                        refreshed_prediction.confidence or "unknown",
                        #(refreshed_prediction.events or {})
                    ))

                    if refreshed_prediction.execute_time <= now then
                        if execute_late <= get_predict_ready_late_limit(hero)
                            and has_valid_prediction_events(hero, target, now, refreshed_prediction.health_after_hits, refreshed_prediction.incoming_time, refreshed_prediction.events, refreshed_prediction.base_health, pending_attack_is_friendly)
                        then
                            issue_attack_target_once(player, hero, target, now, pending_attack_is_friendly, true)
                        elseif execute_late > get_predict_ready_late_limit(hero) then
                            debug_log(("PENDING_REFRESH_SKIP target=%s reason=timing_missed execute_late=%.4f late_limit=%.4f"):format(
                                get_debug_target_text(hero, target),
                                execute_late,
                                get_predict_ready_late_limit(hero)
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
                local enemy_creep = find_killable_creep(creeps, now, false)
                if enemy_creep then
                    debug_log(("PENDING_DENY_REPLACED_BY_DIRECT_LASTHIT target=%s"):format(
                        get_debug_target_text(hero, enemy_creep.npc)
                    ))
                    schedule_attack_target(enemy_creep, now)
                    return
                end

                local enemy_prediction = find_incoming_hit_prediction(hero, creeps, now, false)
                if enemy_prediction then
                    local enemy_target = get_live_enemy_creep_by_index(hero, enemy_prediction.creep.index)
                    local execute_late = now - enemy_prediction.execute_time
                    local enemy_execute_in = enemy_prediction.execute_time - now
                    local pending_deny_execute_in = pending_attack_execute_time - now
                    if enemy_prediction.execute_time > pending_attack_execute_time + DENY_BEFORE_LASTHIT_MARGIN then
                        local deny_reachable, deny_distance, deny_reach, deny_gap, deny_approach, deny_available, deny_move_speed =
                            LASThitv6.IsAttackReachableByExecuteTime(hero, target, now, pending_attack_execute_time)
                        if deny_reachable then
                            debug_log(("PENDING_DENY_KEEP_EARLIER target=%s deny_execute_in=%.4f enemy_execute_in=%.4f margin=%.4f"):format(
                                enemy_target and get_debug_target_text(hero, enemy_target) or ("index=" .. tostring(enemy_prediction.creep.index)),
                                pending_deny_execute_in,
                                enemy_execute_in,
                                DENY_BEFORE_LASTHIT_MARGIN
                            ))
                            enemy_prediction = nil
                        else
                            debug_log(("PENDING_DENY_REPLACE_UNREACHABLE target=%s deny_execute_in=%.4f enemy_execute_in=%.4f approach=%.4f available=%.4f move_speed=%.1f distance=%.1f reach=%.1f gap=%.1f"):format(
                                get_debug_target_text(hero, target),
                                pending_deny_execute_in,
                                enemy_execute_in,
                                deny_approach,
                                deny_available,
                                deny_move_speed,
                                deny_distance,
                                deny_reach,
                                deny_gap
                            ))
                        end
                    end
                end

                if enemy_prediction then
                    local enemy_target = get_live_enemy_creep_by_index(hero, enemy_prediction.creep.index)
                    local execute_late = now - enemy_prediction.execute_time
                    debug_log(("PENDING_DENY_REPLACED_BY_LASTHIT target=%s execute_in=%.4f"):format(
                        enemy_target and get_debug_target_text(hero, enemy_target) or ("index=" .. tostring(enemy_prediction.creep.index)),
                        enemy_prediction.execute_time - now
                    ))
                    if enemy_prediction.execute_time <= now then
                        if enemy_target
                            and execute_late <= get_predict_ready_late_limit(hero)
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

            end

            local split_primary_target = get_live_creep_by_index(hero, pending_attack_target_index, pending_attack_is_friendly)
            if split_primary_target then
                local split_reserved_units = nil
                if pending_attack_prediction then
                    local desired_impact_time = pending_attack_execute_time + (pending_attack_attack_delay or 0)
                    LASThitv6.QueueSyncedAttacks(
                        player,
                        hero,
                        split_primary_target,
                        now,
                        pending_attack_is_friendly,
                        desired_impact_time,
                        "pending_sync",
                        pending_attack_predicted_health,
                        true
                    )
                    split_reserved_units = LASThitv6.GetNeededSyncAttackUnits(
                        hero,
                        split_primary_target,
                        now,
                        desired_impact_time,
                        pending_attack_predicted_health
                    )
                end
                LASThitv6.TrySplitSyncAttacks(player, hero, split_primary_target, now, pending_attack_is_friendly, split_reserved_units)
            end

            if not pending_attack_target_index then
                run_move_orders(player, hero, now)
                return
            end

            if pending_attack_prediction then
                local preposition_target = get_live_creep_by_index(hero, pending_attack_target_index, pending_attack_is_friendly)
                if preposition_target and LASThitv6.TryPrepositionPendingAttack(player, hero, preposition_target, now) then
                    return
                end
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
                        and execute_late <= get_predict_ready_late_limit(hero)
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
        pending_attack_attack_delay = 0
        LASThitv6.pending_attack_preposition_logged = false

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
                    LASThitv6.GetEffectiveMinAttackDamageVsTarget(hero, target, now)
                )
            end
        end

        if can_issue_attack then
            if issue_attack_target_once(player, hero, target, now, fired_target_is_friendly, is_prediction) then
                return
            end
            if not fired_target_is_friendly then
                return
            end
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
                return
            end
        end

        if not is_prediction then
            return
        end
    end

    local glyph_prediction = enemy_mode and LASThitv6.FindGlyphShieldPrediction(hero, creeps, now, false) or nil
    local glyph_prediction_is_friendly = false

    if not glyph_prediction and friendly_mode then
        glyph_prediction = LASThitv6.FindGlyphShieldPrediction(hero, creeps, now, true)
        glyph_prediction_is_friendly = glyph_prediction ~= nil
    end

    if glyph_prediction and ui.debug:Get() then
        debug_prediction = {
            target_index = glyph_prediction.creep.index,
            expires_at = now + 0.15,
            text = ("Glyph hp %d ends %.2fs"):format(
                math.floor(glyph_prediction.health_after_hits + 0.5),
                math.max(0, (glyph_prediction.glyph_end_time or now) - now)
            ),
        }
    end

    if glyph_prediction and now >= next_attack_schedule_time then
        local target = get_live_creep_by_index(hero, glyph_prediction.creep.index, glyph_prediction_is_friendly)
        if glyph_prediction.execute_time <= now then
            local execute_late = now - glyph_prediction.execute_time
            if target
                and has_valid_prediction_events(hero, target, now, glyph_prediction.health_after_hits, glyph_prediction.incoming_time, glyph_prediction.events, glyph_prediction.base_health, glyph_prediction_is_friendly)
            then
                debug_log(("GLYPH_READY_ISSUE target=%s predicted_hp=%d shield_ends_in=%.4f impact_in=%.4f execute_late=%.4f predict_delay=%.4f raw_delay=%.4f ping=%.4f fixed=%.4f lead=%.4f modifier=%s"):format(
                    get_debug_target_text(hero, target),
                    math.floor(glyph_prediction.health_after_hits + 0.5),
                    (glyph_prediction.glyph_end_time or now) - now,
                    glyph_prediction.incoming_time - now,
                    execute_late,
                    glyph_prediction.attack_delay or 0,
                    glyph_prediction.raw_attack_delay or 0,
                    glyph_prediction.network_latency or get_network_latency(),
                    ATTACK_ORDER_FIXED_LEAD,
                    glyph_prediction.order_lead or get_prediction_issue_lead(hero),
                    tostring(glyph_prediction.glyph_modifier_name or "")
                ))
                issue_attack_target_once(player, hero, target, now, glyph_prediction_is_friendly, true)
            else
                debug_log(("GLYPH_READY_SKIP target=%s reason=validation_failed shield_ends_in=%.4f impact_in=%.4f"):format(
                    target and get_debug_target_text(hero, target) or ("index=" .. tostring(glyph_prediction.creep.index)),
                    (glyph_prediction.glyph_end_time or now) - now,
                    glyph_prediction.incoming_time - now
                ))
            end
        else
            debug_log(("GLYPH_WAIT target=%s#%d hp=%d min=%d shield_ends_in=%.4f execute_in=%.4f impact_in=%.4f predict_delay=%.4f modifier=%s"):format(
                glyph_prediction.creep.name,
                glyph_prediction.creep.index,
                math.floor(glyph_prediction.creep.health + 0.5),
                glyph_prediction.creep.min_damage,
                (glyph_prediction.glyph_end_time or now) - now,
                glyph_prediction.execute_time - now,
                glyph_prediction.incoming_time - now,
                glyph_prediction.attack_delay or 0,
                tostring(glyph_prediction.glyph_modifier_name or "")
            ))
            schedule_attack_at(glyph_prediction, now)
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

    if enemy_mode and now >= next_attack_schedule_time then
        local reserved_execute_time = incoming_prediction and incoming_prediction.execute_time or nil
        if LASThitv6.TryIssueTowerSetup(player, hero, creeps, now, reserved_execute_time) then
            return
        end
    end

    if incoming_prediction and now >= next_attack_schedule_time then
        if incoming_prediction.execute_time <= now then
            local target = get_live_creep_by_index(hero, incoming_prediction.creep.index, incoming_prediction_is_friendly)
            local execute_late = now - incoming_prediction.execute_time
            if execute_late > get_predict_ready_late_limit(hero) then
                if should_log_missed_prediction(incoming_prediction, now) then
                    debug_log(("PREDICT_READY_SKIP target=%s reason=timing_missed predicted_hp=%d hp_range=%d-%d incoming_in=%.4f execute_late=%.4f late_limit=%.4f predict_delay=%.4f land_buffer=%.4f confidence=%s events=%d"):format(
                        target and get_debug_target_text(hero, target) or ("index=" .. tostring(incoming_prediction.creep.index)),
                        math.floor(incoming_prediction.health_after_hits + 0.5),
                        math.floor((incoming_prediction.health_after_hits_min or incoming_prediction.health_after_hits) + 0.5),
                        math.floor((incoming_prediction.health_after_hits_max or incoming_prediction.health_after_hits) + 0.5),
                        incoming_prediction.incoming_time - now,
                        execute_late,
                        get_predict_ready_late_limit(hero),
                        incoming_prediction.attack_delay or 0,
                        incoming_prediction.landing_buffer or 0,
                        incoming_prediction.confidence or "unknown",
                        #(incoming_prediction.events or {})
                    ))
                end
            elseif target and has_valid_prediction_events(hero, target, now, incoming_prediction.health_after_hits, incoming_prediction.incoming_time, incoming_prediction.events, incoming_prediction.base_health, incoming_prediction_is_friendly) then
                debug_log(("PREDICT_READY_ISSUE target=%s predicted_hp=%d hp_range=%d-%d incoming_in=%.4f execute_late=%.4f predict_delay=%.4f raw_delay=%.4f ping=%.4f fixed=%.4f lead=%.4f land_buffer=%.4f confidence=%s events=%d"):format(
                    get_debug_target_text(hero, target),
                    math.floor(incoming_prediction.health_after_hits + 0.5),
                    math.floor((incoming_prediction.health_after_hits_min or incoming_prediction.health_after_hits) + 0.5),
                    math.floor((incoming_prediction.health_after_hits_max or incoming_prediction.health_after_hits) + 0.5),
                    incoming_prediction.incoming_time - now,
                    execute_late,
                    incoming_prediction.attack_delay or 0,
                    incoming_prediction.raw_attack_delay or 0,
                    incoming_prediction.network_latency or get_network_latency(),
                    ATTACK_ORDER_FIXED_LEAD,
                    incoming_prediction.order_lead or get_prediction_issue_lead(hero),
                    incoming_prediction.landing_buffer or 0,
                    incoming_prediction.confidence or "unknown",
                    #(incoming_prediction.events or {})
                ))
                issue_attack_target_once(player, hero, target, now, incoming_prediction_is_friendly, true)
            else
                debug_log(("PREDICT_READY_SKIP target=%s predicted_hp=%d hp_range=%d-%d incoming_in=%.4f execute_late=%.4f predict_delay=%.4f land_buffer=%.4f confidence=%s events=%d"):format(
                    target and get_debug_target_text(hero, target) or ("index=" .. tostring(incoming_prediction.creep.index)),
                    math.floor(incoming_prediction.health_after_hits + 0.5),
                    math.floor((incoming_prediction.health_after_hits_min or incoming_prediction.health_after_hits) + 0.5),
                    math.floor((incoming_prediction.health_after_hits_max or incoming_prediction.health_after_hits) + 0.5),
                    incoming_prediction.incoming_time - now,
                    now - incoming_prediction.execute_time,
                    incoming_prediction.attack_delay or 0,
                    incoming_prediction.landing_buffer or 0,
                    incoming_prediction.confidence or "unknown",
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

    if enemy_mode and LASThitv6.TryIssueTowerSetup(player, hero, creeps, now) then
        return
    end

    run_move_orders(player, hero, now)
end

local function confirm_our_melee_attack_animation(hero, data)
    if NPC.IsRanged(hero) == true
        or attack_confirmation_until <= 0
        or not is_attack_animation_event(data, hero)
    then
        return false
    end

    local target = get_live_creep_by_index(hero, attack_confirmation_target_index, attack_confirmation_target_is_friendly)
    if not target then
        return false
    end

    local now = get_time()
    local attack_start = now - (tonumber(data.lag_compensation_time or 0) or 0)
    local attack_point = tonumber(data.castpoint or NPC.GetAttackAnimPoint(hero) or 0) or 0
    local impact_time = attack_start + attack_point
    local ready_time = get_next_attack_ready_time_from_start(hero, attack_start)
    local issue_time = attack_confirmation_issue_time

    local attack_kind = last_attack_issue
        and last_attack_issue.target_index == get_entity_index(target)
        and last_attack_issue.kind
        or "attack"

    LASThitv6.LockMeleeSwingUntil(target, impact_time)

    local damage_min, damage_max = get_attack_damage_range_vs_target(hero, target)
    if attack_kind == "tower_setup" then
        remember_our_setup_hit(hero, target, impact_time)
    else
        remember_our_pending_hit(target, impact_time, damage_min, damage_max)
    end
    clear_attack_confirmation()
    next_attack_ready_time = math.max(next_attack_ready_time, ready_time)
    next_attack_schedule_time = math.max(now + ATTACK_ORDER_INTERVAL, ready_time)

    debug_log(("ATTACK_STARTED melee_animation target=%s kind=%s waited=%.4f impact_in=%.4f swing_lock_in=%.4f ready_in=%.4f activity=%s sequence=%s"):format(
        get_debug_target_text(hero, target),
        attack_kind,
        now - issue_time,
        impact_time - now,
        math.max(0, (LASThitv6.melee_swing_lock_until or impact_time) - now),
        math.max(0, ready_time - now),
        tostring(data.activity),
        tostring(data.sequenceName or "")
    ))
    if attack_kind == "tower_setup" then
        debug_log(("OUR_SETUP_HIT target=%s damage=%d-%d impact_in=%.4f"):format(
            get_debug_target_text(hero, target),
            damage_min,
            damage_max,
            impact_time - now
        ))
    end

    if last_attack_issue and last_attack_issue.target_index == get_entity_index(target) then
        local actual_launch_delay = attack_start - last_attack_issue.issue_time
        local actual_hit_delay = impact_time - last_attack_issue.issue_time
        local timing_error = last_attack_issue.prediction_attack_delay - actual_hit_delay
        local distance, reach, gap, in_range = LASThitv6.GetMeleeAttackRangeInfo(hero, target)
        debug_log(("ATTACK_TIMING target=%s launch_delay=%.4f impact_delay=%.4f raw_delay=%.4f predicted_delay=%.4f timing_error=%.4f ping=%.4f fixed=%.4f lead=%.4f melee_distance=%.1f melee_reach=%.1f melee_gap=%.1f melee_in_range=%s face=%.4f"):format(
            get_debug_target_text(hero, target),
            actual_launch_delay,
            actual_hit_delay,
            last_attack_issue.raw_attack_delay,
            last_attack_issue.prediction_attack_delay,
            timing_error,
            last_attack_issue.network_latency or 0,
            ATTACK_ORDER_FIXED_LEAD,
            last_attack_issue.order_lead or 0,
            distance,
            reach,
            gap,
            tostring(in_range),
            get_hero_face_time(hero, target)
        ))
        last_attack_issue = nil
    end

    return true
end

function LASThitv6.ConfirmSyncAttackAnimation(hero, data)
    if not hero
        or not data
        or not data.unit
        or not is_attack_animation_event(data, data.unit)
    then
        return false
    end

    local unit_index = get_entity_index(data.unit)
    local item = LASThitv6.sync_attack_pending[unit_index]
    if not item then
        return false
    end

    local target = get_live_creep_by_index(hero, item.target_index, item.target_is_friendly)
    if not target then
        LASThitv6.sync_attack_pending[unit_index] = nil
        return false
    end

    local now = get_time()
    local attack_start = now - (tonumber(data.lag_compensation_time or 0) or 0)
    local attack_point = tonumber(data.castpoint or NPC.GetAttackAnimPoint(data.unit) or 0) or 0
    local impact_time = attack_start + attack_point
    local ready_time = get_next_attack_ready_time_from_start(data.unit, attack_start)
    local desired_impact_time = item.desired_impact_time or impact_time

    LASThitv6.sync_attack_pending[unit_index] = nil
    LASThitv6.sync_attack_ready_until[unit_index] = ready_time
    remember_our_pending_hit(target, impact_time, item.damage_min, item.damage_max)

    debug_log(("SYNC_ATTACK_STARTED unit=%s#%d target=%s waited=%.4f impact_in=%.4f desired_impact_in=%.4f timing_error=%.4f ready_in=%.4f damage=%d-%d activity=%s sequence=%s"):format(
        tostring(item.unit_name or NPC.GetUnitName(data.unit) or "unit"),
        unit_index,
        get_debug_target_text(hero, target),
        now - (item.issue_time or now),
        impact_time - now,
        desired_impact_time - now,
        desired_impact_time - impact_time,
        math.max(0, ready_time - now),
        item.damage_min or 0,
        item.damage_max or 0,
        tostring(data.activity),
        tostring(data.sequenceName or "")
    ))

    return true
end

function LASThitv6.OnUnitAnimation(data)
    if not ui.enable:Get() or not data or not data.unit then
        return
    end

    local hero = Heroes.GetLocal()
    if hero and (data.unit == hero or get_entity_index(data.unit) == get_entity_index(hero)) then
        confirm_our_melee_attack_animation(hero, data)
        return
    end

    local unit = data.unit
    if LASThitv6.ConfirmSyncAttackAnimation(hero, data) then
        return
    end

    if NPC.IsTower(unit) == true then
        if not hero or not is_attack_animation_event(data, unit) then
            return
        end

        local target = get_tower_attack_target(unit)
        if not target or not is_valid_creep_target(hero, target, nil) then
            return
        end

        local attack_start = get_time() - (tonumber(data.lag_compensation_time or 0) or 0)
        local remembered, impact_time = remember_ranged_attack_projectile(unit, target, attack_start)
        if remembered then
            local damage_min, damage_max = get_attack_damage_range_vs_target(unit, target)
            debug_log(("TOWER_ATTACK_PREDICT target=%s damage=%d-%d projectile_speed=%d impact_in=%.4f"):format(
                get_debug_target_text(hero, target),
                damage_min,
                damage_max,
                tonumber(NPC.GetAttackProjectileSpeed(unit) or 0) or 0,
                impact_time - get_time()
            ))
        end
        return
    end

    local creep = unit
    if NPC.IsCreep(creep) ~= true or NPC.IsRanged(creep) == true or not is_attack_animation_event(data, creep) then
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
    set_melee_hit_timer(creep, target, attack_start + attack_point)
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
        local attack_kind = last_attack_issue
            and last_attack_issue.target_index == target_index
            and last_attack_issue.kind
            or "attack"
        local impact_time = tonumber(data.maxImpactTime or 0) or 0
        if impact_time <= now then
            impact_time = get_projectile_impact_time(data.source, data.target, now)
        end

        if NPC.IsRanged(hero) == true and attack_confirmation_target_index == target_index then
            local ready_time = get_next_attack_ready_time(hero, data.target, now)
            clear_attack_confirmation()
            next_attack_ready_time = math.max(next_attack_ready_time, ready_time)
            next_attack_schedule_time = math.max(now + ATTACK_ORDER_INTERVAL, ready_time)
            debug_log(("ATTACK_CONFIRMED projectile_sent target=%s kind=%s ready_in=%.4f"):format(
                is_valid_creep_target(hero, data.target, nil) and get_debug_target_text(hero, data.target) or ("index=" .. tostring(get_entity_index(data.target))),
                attack_kind,
                math.max(0, ready_time - now)
            ))
        end

        if impact_time and last_attack_issue and last_attack_issue.target_index == target_index then
            local actual_launch_delay = now - last_attack_issue.issue_time
            local actual_hit_delay = impact_time - last_attack_issue.issue_time
            local timing_error = last_attack_issue.prediction_attack_delay - actual_hit_delay
            debug_log(("ATTACK_TIMING target=%s launch_delay=%.4f impact_delay=%.4f raw_delay=%.4f predicted_delay=%.4f timing_error=%.4f ping=%.4f fixed=%.4f lead=%.4f"):format(
                is_valid_creep_target(hero, data.target, nil) and get_debug_target_text(hero, data.target) or ("index=" .. tostring(target_index)),
                actual_launch_delay,
                actual_hit_delay,
                last_attack_issue.raw_attack_delay,
                last_attack_issue.prediction_attack_delay,
                timing_error,
                last_attack_issue.network_latency or 0,
                ATTACK_ORDER_FIXED_LEAD,
                last_attack_issue.order_lead or 0
            ))
            last_attack_issue = nil
        end

        if is_valid_creep_target(hero, data.target, nil) then
            if impact_time then
                if attack_kind == "tower_setup" then
                    remember_our_setup_hit(hero, data.target, impact_time)
                    local damage_min, damage_max = get_attack_damage_range_vs_target(hero, data.target)
                    debug_log(("OUR_SETUP_PROJECTILE target=%s damage=%d-%d impact_in=%.4f"):format(
                        get_debug_target_text(hero, data.target),
                        damage_min,
                        damage_max,
                        impact_time - now
                    ))
                else
                    local damage_min, damage_max = get_attack_damage_range_vs_target(hero, data.target)
                    remember_our_pending_hit(data.target, impact_time, damage_min, damage_max)
                    debug_log(("OUR_PROJECTILE target=%s impact_in=%.4f"):format(
                        get_debug_target_text(hero, data.target),
                        impact_time - now
                    ))
                end
            end
        end

        return
    end

    local source = data.source
    local source_is_attack_unit = NPC.IsCreep(source) == true or NPC.IsTower(source) == true
    if not source_is_attack_unit or NPC.IsRanged(source) ~= true then
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

    set_projectile_hit_timer(source, data.target, impact_time)
    remember_next_creep_attack(source, data.target, now - LASThitv6.GetScaledAttackAnimPoint(source))
    if NPC.IsTower(source) == true and hero and is_valid_creep_target(hero, data.target, nil) then
        local damage_min, damage_max = get_attack_damage_range_vs_target(source, data.target)
        debug_log(("TOWER_PROJECTILE target=%s damage=%d-%d projectile_speed=%d impact_in=%.4f"):format(
            get_debug_target_text(hero, data.target),
            damage_min,
            damage_max,
            tonumber(NPC.GetAttackProjectileSpeed(source) or 0) or 0,
            impact_time - now
        ))
    end
end

function LASThitv6.ShouldBlockMeleeHardLockOrder(data)
    if not LASThitv6.IsMeleeHardLocked(get_time()) then
        return false
    end

    if data
        and (
            data.identifier == ATTACK_ORDER_ID
            or data.identifier == LASThitv6.SYNC_ATTACK_ORDER_ID
            or data.identifier == LASThitv6.MELEE_HARD_LOCK_ORDER_ID
        )
    then
        return false
    end

    local locks = LASThitv6.melee_hard_lock_unit_indexes or {}
    local lock_target_index = LASThitv6.melee_hard_lock_target_index
    local order_target_index = data and data.target and get_entity_index(data.target) or nil
    local order_unit_indexes = LASThitv6.GetUnitIndexesForHardLock(data and (data.units or data.selectedUnits or data.unit or data.npc or data.issuer))
    local order_unit_count = 0
    local touched_locked_count = 0
    local active_lock_count = 0
    local touched_lock_matches_target = order_target_index ~= nil
    for unit_index in pairs(locks) do
        active_lock_count = active_lock_count + 1
    end
    for unit_index in pairs(order_unit_indexes) do
        order_unit_count = order_unit_count + 1
        local lock = locks[unit_index]
        if lock then
            touched_locked_count = touched_locked_count + 1
            if lock.target_index ~= order_target_index then
                touched_lock_matches_target = false
            end
        end
    end

    if order_unit_count > 0 and touched_locked_count <= 0 then
        return false
    end

    if Enum and Enum.UnitOrder
        and data
        and data.order == Enum.UnitOrder.DOTA_UNIT_ORDER_ATTACK_TARGET
        and order_target_index
        and (
            (order_unit_count > 0 and touched_lock_matches_target)
            or (order_unit_count <= 0 and order_target_index == lock_target_index)
        )
    then
        return false
    end

    local now = get_time()
    if now >= (LASThitv6.melee_hard_lock_block_log_until or 0) then
        local hero = get_local_hero()
        local lock_target = get_live_npc_by_index(lock_target_index)
        debug_log(("MELEE_HARD_LOCK_BLOCK order=%s target=%s lock_target=%s lock_left=%.4f identifier=%s locked_units=%d touched=%d order_units=%d"):format(
            data and tostring(data.order) or "nil",
            order_target_index and tostring(order_target_index) or "nil",
            lock_target and hero and get_debug_target_text(hero, lock_target) or ("index=" .. tostring(lock_target_index)),
            math.max(0, (LASThitv6.melee_hard_lock_until or now) - now),
            data and tostring(data.identifier) or "nil",
            active_lock_count,
            touched_locked_count,
            order_unit_count
        ))
        LASThitv6.melee_hard_lock_block_log_until = now + 0.200
    end

    return true
end

function LASThitv6.OnPrepareUnitOrders(data)
    if not data then
        return true
    end

    if LASThitv6.ShouldBlockMeleeHardLockOrder(data) then
        return false
    end

    if not data.identifier then
        return true
    end

    if data.identifier == ATTACK_ORDER_ID then
        attack_confirmation_order_seen = true
        debug_log(("ATTACK_ORDER_PREPARED order=%s target=%s queue=%s show=%s"):format(
            tostring(data.order),
            data.target and tostring(get_entity_index(data.target)) or "nil",
            tostring(data.queue),
            tostring(data.showEffects)
        ))
        return true
    end

    if data.identifier == LASThitv6.SYNC_ATTACK_ORDER_ID then
        debug_log(("SYNC_ATTACK_ORDER_PREPARED order=%s target=%s queue=%s show=%s"):format(
            tostring(data.order),
            data.target and tostring(get_entity_index(data.target)) or "nil",
            tostring(data.queue),
            tostring(data.showEffects)
        ))
        return true
    end

    if data.identifier == LASThitv6.MELEE_HARD_LOCK_ORDER_ID then
        attack_confirmation_order_seen = true
        return true
    end

    if data.identifier == MOVE_ORDER_ID then
        return true
    end

    return true
end

function LASThitv6.OnModifierCreate(entity, modifier)
    if not ui.enable:Get() then
        return
    end

    if not entity
        or not modifier
        or not Modifier
        or Entity.IsNPC(entity) ~= true
        or NPC.IsCreep(entity) ~= true
    then
        return
    end

    local modifier_name = tostring(safe_call(Modifier.GetName, modifier) or "")
    if modifier_name ~= LASThitv6.SHRAPNEL_MODIFIER_NAME
        and modifier_name ~= LASThitv6.SHADOW_STRIKE_MODIFIER_NAME
    then
        return
    end

    local ability = safe_call(Modifier.GetAbility, modifier)
    local ability_name = ""
    if Ability and ability then
        ability_name = tostring(safe_call(Ability.GetName, ability) or "")
    end

    local now = get_time()
    local hero = get_local_hero()
    local target_text = hero and get_debug_target_text(hero, entity)
        or ("%s#%d"):format(get_creep_name(entity), get_entity_index(entity))

    if modifier_name == LASThitv6.SHADOW_STRIKE_MODIFIER_NAME then
        if ui.debug:Get() then
            local hit_time, interval, creation_time = LASThitv6.GetShadowStrikeNextTickTime(modifier, now)
            local damage = LASThitv6.GetShadowStrikeDamagePerTick(entity, modifier)
            local end_time = LASThitv6.GetShadowStrikeEndTime(modifier)
            debug_log(("MODIFIER_CREATE_SHADOW_STRIKE target=%s modifier=%s ability=%s damage=%d tick_in=%.4f interval=%.4f end_in=%.4f creation_age=%.4f previous_tick=%.4f"):format(
                target_text,
                modifier_name,
                ability_name,
                damage,
                hit_time - now,
                interval,
                end_time and (end_time - now) or -1,
                creation_time > 0 and (now - creation_time) or -1,
                tonumber(safe_call(Modifier.GetPreviousTick, modifier) or 0) or 0
            ))
        end

        return
    end

    local interval = LASThitv6.GetShrapnelTickInterval(modifier)
    local damage = LASThitv6.GetShrapnelDamagePerTick(entity, modifier, interval)
    local duration_after_pulse = LASThitv6.GetShrapnelDurationAfterPulse(ability)
    local caster = safe_call(Modifier.GetCaster, modifier)
    local target_index = get_entity_index(entity)
    local source_index = caster and get_entity_index(caster) or target_index
    local existing_pulse = LASThitv6.active_shrapnel_pulses[target_index]
    local first_hit_time = now
    local expires_at = now + duration_after_pulse
    local observed_interval = existing_pulse and (now - (tonumber(existing_pulse.last_hit_time or now) or now)) or -1
    local grid_error = 0
    if existing_pulse and now <= (tonumber(existing_pulse.expires_at or 0) or 0) + LASThitv6.SHRAPNEL_PULSE_EXPIRE_GRACE then
        first_hit_time = tonumber(existing_pulse.first_hit_time or existing_pulse.last_hit_time or now) or now
        expires_at = tonumber(existing_pulse.expires_at or expires_at) or expires_at
        local tick_number = math.floor(((now - first_hit_time) / interval) + 0.5)
        grid_error = now - (first_hit_time + (tick_number * interval))
    end

    LASThitv6.active_shrapnel_pulses[target_index] = {
        source_index = source_index,
        target_index = target_index,
        first_hit_time = first_hit_time,
        last_hit_time = now,
        next_hit_time = now + interval,
        interval = interval,
        damage = damage,
        expires_at = expires_at,
        modifier_name = modifier_name,
    }

    local hit_time = now + interval
    local end_time = LASThitv6.GetModifierEndTime(modifier)

    if ui.debug:Get() then
        debug_log(("MODIFIER_CREATE_SHRAPNEL target=%s modifier=%s ability=%s damage=%d tick_in=%.4f interval=%.4f observed_interval=%.4f grid_error=%.4f end_in=%.4f zone_end_in=%.4f previous_tick=%.4f"):format(
            target_text,
            modifier_name,
            ability_name,
            damage,
            hit_time - now,
            interval,
            observed_interval,
            grid_error,
            end_time and (end_time - now) or -1,
            expires_at - now,
            tonumber(safe_call(Modifier.GetPreviousTick, modifier) or 0) or 0
        ))
    end
end

return LASThitv6
