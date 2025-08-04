-- Teleport Particle Tracker - API v2.0 VERSION
print("Loading Teleport Particle Tracker v2.0...")

local teleport_tracker = {}
local teleport_data = {}
local scan_data = {}

-- Создаем меню по новому API
local tab = Menu.Create("General", "Info", "Teleport", "Tracker")
local group = tab:Create("Settings")

-- Настройки через меню
local ui = {}
ui.enabled = group:Switch("Enabled", true)
ui.debug = group:Switch("Debug", false)
ui.show_scans = group:Switch("Show Enemy Scans", true)
ui.enemy_only = group:Switch("Enemy Teleports Only", true)
ui.chat_teleports = group:Switch("Chat Notifications", true)
ui.team_visible = group:Switch("Team Visible Lines", false)

-- Функция для проверки настроек
local function IsEnabled() return ui.enabled:Get() end
local function IsDebugEnabled() return ui.debug:Get() end
local function ShowScans() return ui.show_scans:Get() end
local function EnemyOnly() return ui.enemy_only:Get() end
local function ChatTeleports() return ui.chat_teleports:Get() end
local function TeamVisible() return not ui.team_visible:Get() end

-- Данные для телепортов
local teleport_info = {
    start_particles = {},
    end_particles = {},
    teleports = {}
}

-- Получение красивого имени героя
local function GetHeroDisplayName(hero)
    if not hero then return "Unknown" end
    local unit_name = NPC.GetUnitName(hero)
    local display_name = Engine.GetDisplayNameByUnitName(unit_name)
    return display_name or unit_name or "Unknown"
end

-- Отправка сообщения в чат команды
local function SendChatMessage(message)
    if ChatTeleports() then
        Engine.ExecuteCommand("say_team \"" .. message .. "\"")
    end
end

-- Функция для создания круга (из старого кода)
local function GetCircle(x, y, radius, steps)
    local circle = {}
    for i = 0, steps - 1 do
        local angle = (i * 2 * math.pi) / steps
        local px = x + math.cos(angle) * radius
        local py = y + math.sin(angle) * radius
        table.insert(circle, {px, py})
    end
    return circle
end

-- Функция для рисования телепорта (адаптированная из старого кода)
local function DrawTeleport(entity, start_pos, end_pos)
    local clientside = TeamVisible()
    
    if IsDebugEnabled() then
        print("Drawing teleport from " .. tostring(start_pos) .. " to " .. tostring(end_pos))
    end
    
    -- Рисуем стрелку
    local direction = (end_pos - start_pos):Normalized()
    local end_pos_line = end_pos + direction:Scaled(-300)
    local arrow_size = math.min(math.max(300, (end_pos - start_pos):Length() / 10), 1000)
    
    -- Вычисляем стрелку (упрощенный вариант без Rotated)
    local arrow_left = end_pos_line + Vector(
        direction.x * math.cos(math.rad(-30)) - direction.y * math.sin(math.rad(-30)),
        direction.x * math.sin(math.rad(-30)) + direction.y * math.cos(math.rad(-30)),
        0
    ):Scaled(-arrow_size)
    
    local arrow_right = end_pos_line + Vector(
        direction.x * math.cos(math.rad(30)) - direction.y * math.sin(math.rad(30)),
        direction.x * math.sin(math.rad(30)) + direction.y * math.cos(math.rad(30)),
        0
    ):Scaled(-arrow_size)
    
    -- Рисуем круг в конце
    local circle_end = GetCircle(end_pos.x, end_pos.y, 275, 20)
    for i, xy in pairs(circle_end) do
        MiniMap.SendLine(Vector(xy[1], xy[2], end_pos.z), i == 1, clientside)
    end
    
    -- Рисуем стрелку
    MiniMap.SendLine(end_pos_line, true, clientside)
    MiniMap.SendLine(arrow_left, false, clientside)
    MiniMap.SendLine(end_pos_line, true, clientside)
    MiniMap.SendLine(arrow_right, false, clientside)
    MiniMap.SendLine(start_pos, true, clientside)
    MiniMap.SendLine(end_pos_line, false, clientside)
    
    -- Отправляем сообщение в чат
    if ChatTeleports() then
        local hero_name = GetHeroDisplayName(entity)
        SendChatMessage(hero_name .. " использует телепорт!")
    end
end

-- Функция для рисования скана
local function DrawScan(position)
    local clientside = TeamVisible()
    
    if IsDebugEnabled() then
        print("Drawing scan at " .. tostring(position))
    end
    
    -- Рисуем круг скана
    local circle_scan = GetCircle(position.x, position.y, 900, 32)
    for i, xy in pairs(circle_scan) do
        MiniMap.SendLine(Vector(xy[1], xy[2], position.z), i == 1, clientside)
    end
    
    -- Отправляем сообщение в чат
    if ChatTeleports() then
        SendChatMessage("Враги используют скан!")
    end
end

-- Попытка нарисовать телепорт
local function TryDrawTeleport(entity)
    for i, info in pairs(teleport_info.teleports) do
        if info.entity == entity then
            if info.start_pos and info.end_pos then
                DrawTeleport(entity, info.start_pos, info.end_pos)
                table.remove(teleport_info.teleports, i)
            end
            return
        end
    end
end

-- Получение индекса телепорта
local function GetTeleportInfoIndex(entity)
    for i, info in pairs(teleport_info.teleports) do
        if info.entity == entity then
            return i
        end
    end
    return nil
end

-- Создание частиц
function teleport_tracker.OnParticleCreate(data)
    if not IsEnabled() then return end
    
    local entity = data.entityForModifiers
    local local_hero = Heroes.GetLocal()
    
    -- Проверяем что это вражеский герой
    if entity and Entity.IsHero(entity) and local_hero and not Entity.IsSameTeam(entity, local_hero) then
        if data.name == "teleport_start" then
            teleport_info.start_particles[data.index] = entity
            if IsDebugEnabled() then
                print("Found teleport_start particle for " .. GetHeroDisplayName(entity))
            end
        elseif data.name == "teleport_end" then
            teleport_info.end_particles[data.index] = entity
            if IsDebugEnabled() then
                print("Found teleport_end particle for " .. GetHeroDisplayName(entity))
            end
        end
    end
end

-- Обновление частиц
function teleport_tracker.OnParticleUpdate(data)
    if not IsEnabled() then return end
    
    -- Обработка старта телепорта
    if teleport_info.start_particles[data.index] then
        local entity = teleport_info.start_particles[data.index]
        local info_index = GetTeleportInfoIndex(entity)
        
        if info_index then
            teleport_info.teleports[info_index].start_pos = data.position
        else
            table.insert(teleport_info.teleports, {entity = entity, start_pos = data.position})
        end
        
        teleport_info.start_particles[data.index] = nil
        TryDrawTeleport(entity)
        
    -- Обработка конца телепорта
    elseif teleport_info.end_particles[data.index] then
        local entity = teleport_info.end_particles[data.index]
        local info_index = GetTeleportInfoIndex(entity)
        
        if info_index then
            teleport_info.teleports[info_index].end_pos = data.position
        else
            table.insert(teleport_info.teleports, {entity = entity, end_pos = data.position})
        end
        
        teleport_info.end_particles[data.index] = nil
        TryDrawTeleport(entity)
    end
end

-- Обработка создания модификаторов (для сканов)
function teleport_tracker.OnModifierCreate(entity, modifier)
    if not IsEnabled() or not ShowScans() then return end
    
    local local_hero = Heroes.GetLocal()
    local modifier_name = Modifier.GetName(modifier)
    
    -- Проверяем что это вражеский скан
    if modifier_name == "modifier_radar_thinker" and local_hero and not Entity.IsSameTeam(entity, local_hero) then
        local position = Entity.GetAbsOrigin(entity)
        
        -- Добавляем скан в данные
        table.insert(scan_data, {
            position = position,
            time = GameRules.GetGameTime()
        })
        
        DrawScan(position)
        
        if IsDebugEnabled() then
            print("Enemy scan detected at: " .. tostring(position))
        end
    end
end

-- Очистка старых данных
function teleport_tracker.OnUpdate()
    if not IsEnabled() then return end
    
    local current_time = GameRules.GetGameTime()
    
    -- Очистка старых телепортов
    for i = #teleport_info.teleports, 1, -1 do
        local teleport = teleport_info.teleports[i]
        if not teleport.entity or not Entity.IsAlive(teleport.entity) then
            table.remove(teleport_info.teleports, i)
        end
    end
    
    -- Очистка старых сканов
    for i = #scan_data, 1, -1 do
        local scan = scan_data[i]
        if current_time - scan.time > 10.0 then
            table.remove(scan_data, i)
        end
    end
end

function teleport_tracker.OnScriptsLoaded()
    print("Teleport Particle Tracker v2.0 loaded!")
end

return teleport_tracker
