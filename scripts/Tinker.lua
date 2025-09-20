local script        = {}
local translation   = {
  en = {
    root = "Autofarm V2",

    menu_general = "General",
    menu_utilities = "Utilities",
    menu_debug = "Visual Debug",
    toggle_key = "Toggle Key",
    farm_targets = "Farming Targets",
    target_ancients = "Ancient Camps",
    target_non_ancients = "Non‑Ancients",
    target_lane = "Lane Creeps",

    items_to_use = "Usable Items",
    item_bottle = "Bottle",
    item_blink = "Blink Dagger",

    auto_defense_matrix = "Auto Defense Matrix",
    gear_matrix_options = "Defense Matrix Settings",
    matrix_precast = "Auto‑cast at Fountain",
    matrix_panic = "Use while Escaping",

    prefer_bounty = "Prioritize High‑Gold Camps",

    blink_options_label = "Blink Settings",
    gear_blink_behavior = "Blink Behavior",
    blink_travel = "Use for Traveling",
    blink_escape = "Use for Escaping",
    blink_hold_after_rearm = "Delay after Rearm",
    blink_hold_tp_lock = "Hold during TP Lock",

    bottle_options_label = "Bottle Settings",
    gear_bottle_behavior = "Bottle Behavior",
    bottle_use_hp = "Use when Low HP",
    bottle_use_mana = "Use when Low Mana",

    marching_control_label = "March Control",
    gear_controls = "Controls",
    march_use_custom = "Custom March Counts per Camp",
    march_small = "Small Camps",
    march_medium = "Medium Camps",
    march_large = "Large Camps",
    march_ancient = "Ancient Camps",
    march_count_fmt = "%d Marches",

    status_overlay = "Show Status Overlay",
    gear_overlay_options = "Overlay Settings",
    status_lock = "Lock Position (disable dragging)",

    debug_overlay = "Enable Debug Overlay",
    debug_world = "Draw World Guides",
    gear_world_options = "World Settings",
    debug_show_order_throttle = "Show Order Rate",
    debug_show_spot_metrics = "Show Camp Metrics",
    debug_pretty_map = "Use Polished Map Drawing",
    debug_bounty = "Show Gold on Map/Overlay",

    tooltip_autofarm =
    "Autofarm is still in development (enemies may catch you).\nRecommended once March of the Machines is Level 4 and Rearm is Level 1."
  },
  ru = {
    root = "Авто фарм V2",

    menu_general = "Общее",
    menu_utilities = "Утилиты",
    menu_debug = "Визуал",
    toggle_key = "Клавиша включения",
    farm_targets = "Цели фарма",
    target_ancients = "Древние лагеря",
    target_non_ancients = "Обычные лагеря",
    target_lane = "Крипы на линии",

    items_to_use = "Использовать",
    item_bottle = "Боттл",
    item_blink = "Блинк‑даггер",

    auto_defense_matrix = "Авто Defense Matrix",
    gear_matrix_options = "Настройки Defense Matrix",
    matrix_precast = "Автокаст у фонтана",
    matrix_panic = "Использовать при побеге",

    prefer_bounty = "Предпочитать более выгодные кемпы",

    blink_options_label = "Настройки Блинка",
    gear_blink_behavior = "Поведение Блинка",
    blink_travel = "Использовать для перемещения",
    blink_escape = "Использовать при побеге",
    blink_hold_after_rearm = "Задержка после Rearm",
    blink_hold_tp_lock = "Блокировать при ТП‑локе",

    bottle_options_label = "Настройки Ботла",
    gear_bottle_behavior = "Поведение Ботла",
    bottle_use_hp = "Использовать для лечения HP",
    bottle_use_mana = "Использовать для восстановления маны",

    marching_control_label = "Настройки March",
    gear_controls = "Контроль",
    march_use_custom = "Своё количество для каждого лагеря",
    march_small = "Маленькие лагеря",
    march_medium = "Средние лагеря",
    march_large = "Большие лагеря",
    march_ancient = "Древние лагеря",
    march_count_fmt = "%d каста",

    status_overlay = "Показывать оверлей статуса",
    gear_overlay_options = "Настройки оверлея",
    status_lock = "Зафиксировать позицию (запрещает двигать)",

    debug_overlay = "Включить оверлей отладки",
    debug_world = "Рисовать информацию в мире",
    gear_world_options = "Настройки мира",
    debug_show_order_throttle = "Показывать частоту команд",
    debug_show_spot_metrics = "Показывать метрики лагерей",
    debug_pretty_map = "Красивое оформление карты",
    debug_bounty = "Показывать золото на карте/оверлее",

    tooltip_autofarm =
    "Скрипт всё ещё в разработке (враги могут поймать).\nРекомендуется включать при March of the Machines 4 уровня и Rearm 1 уровня."
  }
}

local __lang_cached = nil
local function __lang_index()
  if __lang_cached ~= nil then return __lang_cached end
  local d = Menu.Find("SettingsHidden", "", "", "", "Main", "Language")
  local v = d and d:Get() or 0
  if v ~= 0 and v ~= 1 then v = 0 end
  __lang_cached = v
  return v
end

local function __lang_code()
  return __lang_index() == 1 and "ru" or "en"
end

function L(key)
  local code = __lang_code()
  return (translation[code] and translation[code][key]) or (translation.en and translation.en[key]) or tostring(key)
end

do
  local d = Menu.Find("SettingsHidden", "", "", "", "Main", "Language")
  if d and d.SetCallback then
    local prev = d:Get()
    d:SetCallback(function(ctrl)
      local cur = (ctrl and ctrl.Get and ctrl:Get()) or d:Get()
      if cur ~= prev then
        prev = cur
        Engine.ReloadScriptSystem()
      end
    end)
  end
end

local autoFarmMenu = Menu.Create("Heroes", "Hero List", "Tinker", L("root"), L("menu_general"))
local utilityMenu  = Menu.Create("Heroes", "Hero List", "Tinker", L("root"), L("menu_utilities"))
local debugMenu    = Menu.Create("Heroes", "Hero List", "Tinker", L("root"), L("menu_debug"))
Config             = {
  AutoFarm = autoFarmMenu:Bind(L("toggle_key"), Enum.ButtonCode.BUTTON_CODE_NONE, "\u{f11c}"),
  ToFarm = autoFarmMenu:MultiCombo(L("farm_targets"), {
    L("target_ancients"), L("target_non_ancients"), L("target_lane")
  }, { L("target_ancients"), L("target_non_ancients") }),
  ItemsToUse = utilityMenu:MultiSelect(L("items_to_use"), {
    { L("item_bottle"), "panorama/images/items/bottle_png.vtex_c", true },
    { L("item_blink"),  "panorama/images/items/blink_png.vtex_c",  true }
  }, true),
  AutoMatrix = utilityMenu:Switch(L("auto_defense_matrix"), true,
    "panorama/images/spellicons/tinker_defense_matrix_png.vtex_c"),
  Matrix = {},
  PreferBounty = autoFarmMenu:Switch(L("prefer_bounty"), true, "\u{f3d1}"),
  BlinkGroup = utilityMenu:Label(L("blink_options_label"), "panorama/images/items/blink_png.vtex_c"),
  Blink = {},
  BottleGroup = utilityMenu:Label(L("bottle_options_label"), "panorama/images/items/bottle_png.vtex_c"),
  Bottle = {},
  MarchControl = {},
  StatusOverlay = autoFarmMenu:Switch(L("status_overlay"), true, "\u{f2d2}"),
  Status = {},
  Debug = {
    Overlay = debugMenu:Switch(L("debug_overlay"), false, "\u{f108}"),
    World   = debugMenu:Switch(L("debug_world"), false, "\u{f279}"),
  }
}

Config.AutoFarm:ToolTip(L("tooltip_autofarm"))

do
  local g                         = Config.AutoMatrix:Gear(L("gear_matrix_options"))
  Config.Matrix.PrecastAtFountain = g:Switch(L("matrix_precast"), true, "\u{f2cd}")
  Config.Matrix.UseDuringPanic    = g:Switch(L("matrix_panic"), true, "\u{f002}")

  local sg                        = Config.StatusOverlay:Gear(L("gear_overlay_options"))
  Config.Status.Lock              = sg:Switch(L("status_lock"), true, "\u{f023}")

  local overlayGear               = Config.Debug.Overlay:Gear(L("gear_overlay_options"))
  Config.Debug.Orders             = overlayGear:Switch(L("debug_show_order_throttle"), false, "\u{f0ae}")
  Config.Debug.Spot               = overlayGear:Switch(L("debug_show_spot_metrics"), true, "\u{f080}")

  local worldGear                 = Config.Debug.World:Gear(L("gear_world_options"))
  Config.Debug.Pretty             = worldGear:Switch(L("debug_pretty_map"), true, "\u{f5a0}")
  Config.Debug.Bounty             = worldGear:Switch(L("debug_bounty"), true, "\u{f51e}")

  local m                         = autoFarmMenu:Label(L("marching_control_label"), "\u{f0c9}"):Gear(L("gear_controls"))
  Config.MarchControl.UseCustom   = m:Switch(L("march_use_custom"), true, "\u{f013}")
  Config.MarchControl.Small       = m:Slider(L("march_small"), 1, 5, 2, L("march_count_fmt"))
  Config.MarchControl.Medium      = m:Slider(L("march_medium"), 1, 5, 3, L("march_count_fmt"))
  Config.MarchControl.Large       = m:Slider(L("march_large"), 1, 5, 3, L("march_count_fmt"))
  Config.MarchControl.Ancient     = m:Slider(L("march_ancient"), 1, 5, 4, L("march_count_fmt"))

  local bg                        = Config.BlinkGroup:Gear(L("gear_blink_behavior"))
  Config.Blink.Travel             = bg:Switch(L("blink_travel"), true, "\u{f70c}")
  Config.Blink.Escape             = bg:Switch(L("blink_escape"), true, "\u{f2f5}")
  Config.Blink.HoldAfterRearm     = bg:Switch(L("blink_hold_after_rearm"), true, "\u{f017}")
  Config.Blink.HoldTPLock         = bg:Switch(L("blink_hold_tp_lock"), true, "\u{f023}")

  local botg                      = Config.BottleGroup:Gear(L("gear_bottle_behavior"))
  Config.Bottle.UseHP             = botg:Switch(L("bottle_use_hp"), true, "\u{f004}")
  Config.Bottle.UseMana           = botg:Switch(L("bottle_use_mana"), true, "\u{f0d0}")
end

local function SyncMarchSlidersDisabled()
  local useCustom = Config.MarchControl.UseCustom:Get()
  Config.MarchControl.Small:Disabled(not useCustom)
  Config.MarchControl.Medium:Disabled(not useCustom)
  Config.MarchControl.Large:Disabled(not useCustom)
  Config.MarchControl.Ancient:Disabled(not useCustom)
end
Constants = {
  MARCH_CAST_RANGE              = 900,
  MARCH_PAIR_COVERAGE_FRAC      = 1.1,
  TP_MIN_DISTANCE               = 2000,
  BLINK_MAX_RANGE               = 1200,
  POST_TP_LOCK_TIME             = 3.8,
  NO_REARM_AFTER_TP             = 1.6,
  SAME_SPOT_TP_EPS              = 800,
  SAME_SPOT_TP_COOLDOWN         = 7.5,
  BLINK_HOLD_AFTER_REARM        = 0.6,
  BLINK_HOLD_BEFORE_TP          = 0.6,
  BLINK_SAFE_STANDOFF           = 220,
  BLINK_MIN_DISTANCE            = 450,
  ORDER_COOLDOWN                = 0.02,
  ORDERS_PER_UPDATE             = 1,
  MOVE_RESEND_INTERVAL          = 0.25,
  MOVE_POS_EPS                  = 72,
  ABILITY_DEDUP_INTERVAL        = 0.18,
  CAST_POS_EPS                  = 48,
  BOTTLE_CHECK_COOLDOWN         = 0.1,
  BOTTLE_MISSING_THRESHOLD      = 50,
  FOUNTAIN_MIN_MANA_FRAC        = 0.5,
  FOUNTAIN_RADIANT              = Vector(6752.5625, 6281.28125, 384.0),
  FOUNTAIN_DIRE                 = Vector(-6988.40625, -6464.71875, 384.0),
  SPOT_SCAN_INTERVAL            = 0.35,
  CAMP_CLEAR_DELAY              = 0.8,
  CAMP_CLEAR_CONFIRM_DELAY      = 2,
  MARCH_MIN_RECAST_GAP          = 0.6,
  REARM_MIN_GAP_AFTER_MARCH     = 0.35,
  HOLD_ACTIONS_DURING_CONFIRM   = true,
  PANIC_HP_FRAC                 = 0.40,
  PANIC_COOLDOWN                = 1.5,
  PANIC_ARM_TIME                = 0.25,
  PANIC_MATRIX_COOLDOWN         = 1.0,
  SPOT_COMMIT_TIME              = 5.0,
  FARM_TP_MIN_INTERVAL          = 5.0,
  IDLE_DECISION_DELAY           = 0.6,
  BOUNTY_SCORE_FACTOR_HIGH      = 1.0,
  BOUNTY_SCORE_FACTOR_LOW       = 0.3,
  KEEN_LANDING_RADIUS_STRUCTURE = 800,
  KEEN_LANDING_RADIUS_OUTPOST   = 250,
  ENEMY_RISK_RADIUS             = 1400,
  ENEMY_RISK_PATH_STEP          = 550,
  ENEMY_RISK_W_SPOT             = 1.0,
  ENEMY_RISK_W_ANCHOR           = 1.0,
  ENEMY_RISK_W_PATH             = 1.4,
  ENEMY_RISK_WEIGHT             = 80.0,
  ENEMY_RISK_HARD_BLOCK         = 0.45,
  ENEMY_RISK_BLOCK_RADIUS       = 1000,
  PENDING_TP_MAX_AGE            = 2.5,
  MARCH_VERIFY_MAX_AGE          = 1.2,
  MARCH_VERIFY_COOLDOWN_EPS     = 0.01,
}
State = {
  Hero = nil,
  Player = nil,
  HeroTeam = nil,
  IsChanneling = false,
  Rearm = nil,
  March = nil,
  KeenTeleport = nil,
  Blink = nil,

  FarmState = "IDLE",
  CurrentFarmSpot = nil,

  MatrixCastTime = 0,

  NextOrderTime = 0,
  OrdersThisUpdate = 0,
  NextBottleCheck = 0,

  LastMovePos = nil,
  LastMoveTime = 0,
  LastAbilityOrders = {},

  DebugFont = nil,
  LastOrderDebug = nil,
  OrderCounterStart = 0,
  OrdersSentThisSecond = 0,
  OrdersPerSec = 0,

  LastTeleportAt = 0,
  TeleportLockUntil = 0,
  MovingAfterTeleport = false,
  LastTeleportCastPos = nil,
  RecalcAfterTP = false,

  PendingTPPos = nil,
  PendingTPSince = 0,
  PendingTPForce = false,

  BlockTPThisSpot = false,
  LastSpotTelePos = nil,

  LastRearmAt = 0,
  LastSpotScan = 0,

  CachedBestSpot = nil,
  AfterMarchCheck = nil,

  LastHP = 0,
  LastHPTime = 0,
  PanicCooldownUntil = 0,
  PanicArmingSince = nil,
  LastPanicMatrixAt = 0,
  PanicReason = nil,

  TargetSpotKey = nil,
  SpotCommitUntil = 0,
  LastFarmTPAt = 0,
  JustClearedSpotAt = 0,

  LastMarchCastAt = 0,

  LastTeleportAnchor = nil,
  CurrentSpotMarchCasts = 0,
  CurrentSpotMarchRequired = nil,
  MarchTotalCasts = 0,
  MarchModeWasCustom = false,
  PendingMarchVerify = nil,
  StatusUI = {
    x = Render.ScreenSize().x / 1.35,
    y = Render.ScreenSize().y / 1.1,
    dragging = false,
    dragDX = 0,
    dragDY = 0,
    mousePrevDown = false
  }
}

local Utils = {}

local ORDER_NAME = {
  [Enum.UnitOrder.DOTA_UNIT_ORDER_NONE]             = "NONE",
  [Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION] = "MOVE",
  [Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET]   = "CAST_NO_TARGET",
  [Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION]    = "CAST_POSITION",
  [Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET]      = "CAST_TARGET",
}

local function RecordOrder(order, ability, allowed, reason, targetEntity, targetPos)
  State.LastOrderDebug = {
    at      = GameRules.GetGameTime(),
    order   = ORDER_NAME[order] or tostring(order),
    ability = ability and Ability.GetName(ability) or nil,
    allowed = allowed,
    reason  = reason or (allowed and "sent" or "blocked"),
    tpos    = targetPos
  }
end

local function ShouldAllowOrder(order, ability, targetEntity, targetPos)
  local t = GameRules.GetGameTime()

  if (State.OrdersThisUpdate or 0) >= (Constants.ORDERS_PER_UPDATE or 1) then
    return false, "perUpdateCap"
  end

  if t < (State.NextOrderTime or 0) then
    return false, "globalCooldown"
  end

  if order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION and targetPos then
    local lastPos, lastTime = State.LastMovePos, State.LastMoveTime or 0
    if lastPos and (t - lastTime) < Constants.MOVE_RESEND_INTERVAL and targetPos:Distance(lastPos) < Constants.MOVE_POS_EPS then
      return false, "moveDedup"
    end
    return true
  end

  if ability then
    local aKey = tostring(ability)
    local last = State.LastAbilityOrders[aKey]
    if last and (t - (last.at or 0)) < Constants.ABILITY_DEDUP_INTERVAL then
      if last.order == order then
        if order == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET then
          return false, "abilityNoTargetDedup"
        elseif order == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET and targetEntity and last.target == targetEntity then
          return false, "abilityTargetDedup"
        elseif order == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION and targetPos and last.pos
            and targetPos:Distance(last.pos) < Constants.CAST_POS_EPS then
          return false, "abilityPosDedup"
        end
      end
    end
    return true
  end

  return true
end
local function OnMarchIssued() end

function Utils.IssueOrder(order, ability, data)
  local t = GameRules.GetGameTime()

  if State.IsChanneling then
    RecordOrder(order, ability, false, "channeling", nil, nil)
    return false
  end

  local targetEntity  = (data and type(data) == "userdata" and Entity.IsEntity(data)) and data or nil
  local targetPos     = (data and type(data) == "userdata" and not Entity.IsEntity(data)) and data or nil

  local allow, reason = ShouldAllowOrder(order, ability, targetEntity, targetPos)
  if not allow then
    RecordOrder(order, ability, false, reason, targetEntity, targetPos)
    return false
  end

  Player.PrepareUnitOrders(
    State.Player, order, targetEntity, targetPos, ability,
    Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY, State.Hero,
    false, false, false, true, false, false
  )

  State.NextOrderTime    = t + Constants.ORDER_COOLDOWN
  State.OrdersThisUpdate = (State.OrdersThisUpdate or 0) + 1

  if t - (State.OrderCounterStart or 0) >= 1.0 then
    State.OrdersPerSec         = State.OrdersSentThisSecond or 0
    State.OrdersSentThisSecond = 0
    State.OrderCounterStart    = t
  end
  State.OrdersSentThisSecond = (State.OrdersSentThisSecond or 0) + 1

  if order == Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION and targetPos then
    State.LastMovePos  = targetPos
    State.LastMoveTime = t
  end

  if ability then
    local aKey = tostring(ability)
    State.LastAbilityOrders[aKey] = { order = order, at = t, pos = targetPos, target = targetEntity }
  end

  RecordOrder(order, ability, true, "sent", targetEntity, targetPos)
  if ability and State.March and ability == State.March then
    OnMarchIssued()
  end
  return true
end

function Utils.CastAbility(ability, order, data)
  if ability and Ability.CanBeExecuted(ability) == -1 then
    local ok = Utils.IssueOrder(order, ability, data)
    return ok
  end
  return false
end

function Utils.MoveTo(pos)
  return Utils.IssueOrder(Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, pos)
end

local function FormatGold(n) return tostring(math.floor(n + 0.5)) .. "g" end

local Tinker = {}
local function GetAbilityCooldownRemaining(ability)
  if not ability then return 0 end
  if Ability.GetCooldownTimeRemaining then
    local cd = Ability.GetCooldownTimeRemaining(ability) or 0
    if cd < 0 then cd = 0 end
    return cd
  end
  if Ability.GetCooldown then
    local cd = Ability.GetCooldown(ability) or 0
    if cd < 0 then cd = 0 end
    return cd
  end
  return (Ability.CanBeExecuted(ability) == -1) and 0 or 0.1
end

function Tinker.QueueMarchVerify()
  if not State.March then return end
  State.PendingMarchVerify = {
    requestedAt = GameRules.GetGameTime(),
    baseCD      = GetAbilityCooldownRemaining(State.March),
    expireAt    = GameRules.GetGameTime() + Constants.MARCH_VERIFY_MAX_AGE
  }
end

function Tinker.ProcessMarchVerify()
  local v = State.PendingMarchVerify
  if not v or not State.March then return end
  local now = GameRules.GetGameTime()
  if now > (v.expireAt or 0) then
    State.PendingMarchVerify = nil
    return
  end
  local cd  = GetAbilityCooldownRemaining(State.March)
  local eps = Constants.MARCH_VERIFY_COOLDOWN_EPS or 0.01
  if cd > (v.baseCD or 0) + eps then
    State.MarchTotalCasts = (State.MarchTotalCasts or 0) + 1
    if State.FarmState == "FARMING_SPOT" and State.CurrentFarmSpot then
      State.CurrentSpotMarchCasts = (State.CurrentSpotMarchCasts or 0) + 1
    end
    State.LastMarchCastAt    = now
    State.PendingMarchVerify = nil
  end
end

local function GetRequiredMarchesForCampType(campType)
  local mc = Config.MarchControl
  if campType == 1 then
    return mc.Small:Get()
  elseif campType == 2 then
    return mc.Medium:Get()
  elseif campType == 3 then
    return mc.Large:Get()
  elseif campType == 4 then
    return mc.Ancient:Get()
  end
  return 0
end

local function ComputeRequiredMarchesForSpot(spot)
  if not spot then return 0 end
  local function req(c)
    if not c or not c.type then return 0 end
    return GetRequiredMarchesForCampType(c.type)
  end
  local r1 = req(spot.camp1)
  if spot.single then return r1 end
  local r2 = req(spot.camp2)
  return math.max(r1, r2)
end

local function MarkSpotFarmedAndLeave()
  if State.CurrentFarmSpot then
    if State.CurrentFarmSpot.camp1 then State.CurrentFarmSpot.camp1.farmed = true end
    if (not State.CurrentFarmSpot.single) and State.CurrentFarmSpot.camp2 then
      State.CurrentFarmSpot.camp2.farmed = true
    end
  end
  State.AfterMarchCheck          = nil
  State.FarmState                = "IDLE"
  State.JustClearedSpotAt        = GameRules.GetGameTime()
  State.CurrentFarmSpot          = nil
  State.CurrentSpotMarchCasts    = 0
  State.CurrentSpotMarchRequired = nil
end
OnMarchIssued = function()
  State.LastMarchCastAt = GameRules.GetGameTime()
  Tinker.QueueMarchVerify()
end
local function KeenLevel()
  if not State.KeenTeleport then return 0 end
  return Ability.GetLevel(State.KeenTeleport) or 0
end
local function GetLandingRadiusForAnchor(e)
  if not e or not Entity.IsEntity(e) then return 0 end
  if NPC.IsStructure(e) then
    if string.find((Entity.GetUnitName(e) or ""), "npc_dota_watch_tower") then
      return Constants.KEEN_LANDING_RADIUS_OUTPOST
    end
    return Constants.KEEN_LANDING_RADIUS_STRUCTURE
  end
  return NPC.GetPaddedCollisionRadius(e) or 72
end
function Tinker.ResolveKeenTeleport(desiredPos)
  local lvl                           = KeenLevel()
  local allowCreep                    = lvl >= 2
  local allowHero                     = lvl >= 3

  local bestAnchor, bestCat, bestDist = nil, nil, math.huge

  local function consider(e, cat)
    if not e or not Entity.IsAlive(e) then return end
    if Entity.GetTeamNum(e) ~= State.HeroTeam then return end
    if e == State.Hero then return end
    local p = Entity.GetAbsOrigin(e)
    local d = p:Distance(desiredPos)
    if d < bestDist then
      bestDist, bestAnchor, bestCat = d, e, cat
    end
  end

  for _, e in ipairs(NPCs.GetAll(Enum.UnitTypeFlags.TYPE_STRUCTURE) or {}) do
    consider(e, "structure")
  end
  if allowCreep then
    for _, e in ipairs(NPCs.GetAll(Enum.UnitTypeFlags.TYPE_LANE_CREEP) or {}) do
      if Entity.IsSameTeam(e, State.Hero) and Entity.IsAlive(e) and not Entity.IsDormant(e) and not NPC.IsWaitingToSpawn(e) then
        consider(e, "creep")
      end
    end
  end
  if allowHero then
    for _, e in ipairs(Heroes.GetAll() or {}) do
      consider(e, "hero")
    end
  end

  if bestAnchor then
    local anchorPos = Entity.GetAbsOrigin(bestAnchor)
    local r         = GetLandingRadiusForAnchor(bestAnchor)
    local d         = desiredPos:Distance(anchorPos)
    local finalPos  = (d > r) and (anchorPos + (desiredPos - anchorPos):Normalized() * r) or desiredPos
    return {
      castOrder     = Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION,
      castData      = finalPos,
      anchor        = bestAnchor,
      anchorPos     = anchorPos,
      landingRadius = r,
      finalPos      = finalPos,
      cat           = bestCat
    }
  end

  return {
    castOrder     = Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION,
    castData      = desiredPos,
    anchor        = nil,
    anchorPos     = nil,
    landingRadius = 0,
    finalPos      = desiredPos,
    cat           = "raw"
  }
end

function Tinker.SelectTeleportAnchor(targetPos)
  local res = Tinker.ResolveKeenTeleport(targetPos)
  if res and res.anchor then
    return {
      entity        = res.anchor,
      pos           = res.anchorPos,
      cat           = res.cat,
      landingRadius = res.landingRadius,
      finalPos      = res.finalPos
    }
  end
  return nil
end

function Tinker.IntendedKeenTPPos(rawPos)
  local res = Tinker.ResolveKeenTeleport(rawPos)
  return res and res.finalPos or rawPos
end

function Tinker.GetEnemyLastKnownPositions()
  local out = {}
  if not Heroes or not Heroes.GetAll then return out end
  for _, h in ipairs(Heroes.GetAll() or {}) do
    if h ~= State.Hero
        and Entity.IsEntity(h)
        and Entity.GetTeamNum(h) ~= State.HeroTeam
        and Entity.IsAlive(h)
        and (not NPC.IsIllusion or not NPC.IsIllusion(h)) then
      local p = (not Entity.IsDormant(h)) and Entity.GetAbsOrigin(h)
          or (Hero.GetLastMaphackPos and Hero.GetLastMaphackPos(h))
      if p then table.insert(out, p) end
    end
  end
  return out
end

local function MinDistToEnemies(pt, enemyPts)
  local best = math.huge
  for _, ep in ipairs(enemyPts) do
    local d = pt:Distance(ep)
    if d < best then best = d end
  end
  return best
end

local function RiskAtPoint(pt, enemyPts)
  local R = Constants.ENEMY_RISK_RADIUS
  if #enemyPts == 0 then return 0 end
  local d = MinDistToEnemies(pt, enemyPts)
  if d >= R then return 0 end
  local r = 1 - (d / R)
  return math.max(0, math.min(1, r * r))
end
local function AnyEnemyWithin(pt, enemyPts, radius)
  for _, ep in ipairs(enemyPts or {}) do
    if pt:Distance(ep) <= radius then return true end
  end
  return false
end
local function PathRisk(a, b, enemyPts)
  if #enemyPts == 0 then return 0 end
  local step = Constants.ENEMY_RISK_PATH_STEP
  local ab   = b - a
  local L    = ab:Length()
  if L < 1 then return RiskAtPoint(b, enemyPts) end
  local dir   = ab / L
  local t     = 0
  local worst = 0
  while t <= L do
    local p = a + dir * t
    local r = RiskAtPoint(p, enemyPts)
    if r > worst then worst = r end
    t = t + step
  end
  local rend = RiskAtPoint(b, enemyPts)
  if rend > worst then worst = rend end
  return worst
end
function Tinker.IsTeleportSafe(rawTargetPos)
  local enemyPts = Tinker.GetEnemyLastKnownPositions()
  if #enemyPts == 0 then return true end

  local res       = Tinker.ResolveKeenTeleport(rawTargetPos)
  local land      = (res and res.finalPos) or rawTargetPos
  local anchorPos = (res and res.anchorPos) or land

  local riskLimit = Constants.ENEMY_RISK_HARD_BLOCK or 0.45
  local blockR    = Constants.ENEMY_RISK_BLOCK_RADIUS or 1000

  if RiskAtPoint(rawTargetPos, enemyPts) >= riskLimit then return false end
  if RiskAtPoint(land, enemyPts) >= riskLimit then return false end
  if PathRisk(anchorPos, rawTargetPos, enemyPts) >= riskLimit then return false end

  if AnyEnemyWithin(land, enemyPts, blockR) then return false end
  if AnyEnemyWithin(rawTargetPos, enemyPts, blockR) then return false end

  return true
end

local function HasFountainBuff()
  local modifier = NPC.GetModifier(State.Hero, "modifier_fountain_aura_buff")
  if modifier then
    local continous = Modifier.IsCurrentlyInAuraRange(modifier)
    if continous then
      return true
    end
  end
  return false
end
local function CampIndex(camp)
  if not camp then return "nil" end
  return camp.index and tostring(camp.index) or tostring(camp)
end

local function SpotKey(spot)
  if not spot then return "nil" end
  if spot.single then return "S:" .. CampIndex(spot.camp1) end
  local a = CampIndex(spot.camp1)
  local b = CampIndex(spot.camp2)
  if b < a then a, b = b, a end
  return "P:" .. a .. "|" .. b
end

local function RecenterSpot(spot)
  if not spot then return end
  if spot.single then
    if spot.camp1 and spot.camp1.pos then spot.pos = spot.camp1.pos end
  else
    if spot.camp1 and spot.camp1.pos and spot.camp2 and spot.camp2.pos then
      spot.pos = (spot.camp1.pos + spot.camp2.pos) / 2
    end
  end
end

local function IsCampAncient(camp) return camp and camp.type == 4 end
local function ComputeMarchCastInfo(spot)
  if not spot then return nil end
  local castPos = spot.pos
  local maxDist = 0
  if spot.camp1 and spot.camp1.pos then maxDist = math.max(maxDist, castPos:Distance(spot.camp1.pos)) end
  if spot.camp2 and spot.camp2.pos then maxDist = math.max(maxDist, castPos:Distance(spot.camp2.pos)) end
  return { pos = castPos, maxDist = maxDist }
end
function Tinker.FindBestFarmSpot()
  local myPos                   = Entity.GetAbsOrigin(State.Hero)
  local enabledTargets          = Config.ToFarm:ListEnabled() or {}
  local wantAncient, wantNonAnc = false, false
  for _, name in ipairs(enabledTargets) do
    if name == L("target_ancients") then wantAncient = true end
    if name == L("target_non_ancients") then wantNonAnc = true end
  end
  if not (wantAncient or wantNonAnc) then return nil end

  local allCamps, selectedSet = {}, {}
  for _, camp in pairs(LIB_HEROES_DATA.jungle_spots) do
    if not camp.farmed and camp.team == State.HeroTeam then
      table.insert(allCamps, camp)
      local isAnc = IsCampAncient(camp)
      if (isAnc and wantAncient) or (not isAnc and wantNonAnc) then
        selectedSet[camp] = true
      end
    end
  end
  if #allCamps == 0 then return nil end

  local coverageMax                           = Constants.MARCH_CAST_RANGE * Constants.MARCH_PAIR_COVERAGE_FRAC
  local bountyK                               = Config.PreferBounty:Get() and Constants.BOUNTY_SCORE_FACTOR_HIGH or
      Constants.BOUNTY_SCORE_FACTOR_LOW

  local enemyPts                              = Tinker.GetEnemyLastKnownPositions()
  local wSpot                                 = Constants.ENEMY_RISK_W_SPOT
  local wAnchor                               = Constants.ENEMY_RISK_W_ANCHOR
  local wPath                                 = Constants.ENEMY_RISK_W_PATH
  local riskW                                 = Constants.ENEMY_RISK_WEIGHT
  local bestPairScore, bestPair, bestPairGold = math.huge, nil, 0
  if #allCamps >= 2 then
    for i = 1, #allCamps do
      for j = i + 1, #allCamps do
        local campA, campB = allCamps[i], allCamps[j]
        if selectedSet[campA] or selectedSet[campB] then
          local AB = (campA.pos - campB.pos):Length()
          if (AB * 0.5) <= coverageMax then
            local center        = (campA.pos + campB.pos) / 2
            local distScore     = myPos:Distance(center) / 100.0
            local spreadPenalty = AB / 200.0
            local gold          = (Camp.GetGoldBounty(campA, true) + Camp.GetGoldBounty(campB, true))
            local bountyScore   = (gold / 50.0) * bountyK

            local anchorPos     = Tinker.IntendedKeenTPPos(center)
            local rSpot         = RiskAtPoint(center, enemyPts)
            local rAnchor       = RiskAtPoint(anchorPos, enemyPts)
            local rPath         = PathRisk(anchorPos, center, enemyPts)

            local score         = math.huge
            local riskLimit     = Constants.ENEMY_RISK_HARD_BLOCK
            local blockR        = Constants.ENEMY_RISK_BLOCK_RADIUS
            if (rSpot >= riskLimit) or (rAnchor >= riskLimit) or (rPath >= riskLimit)
                or AnyEnemyWithin(anchorPos, enemyPts, blockR) then
            else
              local riskPenalty = (wSpot * rSpot + wAnchor * rAnchor + wPath * rPath) * riskW
              score             = distScore + spreadPenalty + riskPenalty - bountyScore
            end
            if score < bestPairScore then
              bestPairScore, bestPair, bestPairGold = score, { campA, campB }, gold
            end
          end
        end
      end
    end
  end

  if bestPair then
    return { pos = (bestPair[1].pos + bestPair[2].pos) / 2, camp1 = bestPair[1], camp2 = bestPair[2], gold = bestPairGold }
  end
  local bestSingle, bestSingleScore, bestSingleGold = nil, math.huge, 0
  for camp, _ in pairs(selectedSet) do
    local distScore   = myPos:Distance(camp.pos) / 100.0
    local gold        = Camp.GetGoldBounty(camp, true)
    local bountyScore = (gold / 50.0) * bountyK

    local anchorPos   = Tinker.IntendedKeenTPPos(camp.pos)
    local rSpot       = RiskAtPoint(camp.pos, enemyPts)
    local rAnchor     = RiskAtPoint(anchorPos, enemyPts)
    local rPath       = PathRisk(anchorPos, camp.pos, enemyPts)

    local riskLimit   = Constants.ENEMY_RISK_HARD_BLOCK
    local blockR      = Constants.ENEMY_RISK_BLOCK_RADIUS
    local score       = math.huge
    if (rSpot >= riskLimit) or (rAnchor >= riskLimit) or (rPath >= riskLimit)
        or AnyEnemyWithin(anchorPos, enemyPts, blockR) then
    else
      local riskPenalty = (wSpot * rSpot + wAnchor * rAnchor + wPath * rPath) * riskW
      score             = distScore + riskPenalty - bountyScore
    end
    if score < bestSingleScore then
      bestSingleScore, bestSingle, bestSingleGold = score, camp, gold
    end
  end
  if bestSingle then
    return { pos = bestSingle.pos, camp1 = bestSingle, single = true, gold = bestSingleGold }
  end

  return nil
end

function Tinker.GetBestFarmSpotCached()
  local t = GameRules.GetGameTime()
  if State.CachedBestSpot and t - (State.LastSpotScan or 0) < Constants.SPOT_SCAN_INTERVAL then
    return State.CachedBestSpot
  end
  local best = Tinker.FindBestFarmSpot()
  if best and not best.camp2 then best.single = true end
  State.CachedBestSpot = best
  State.LastSpotScan   = t
  return best
end

local function ManaCost(ability) return (ability and Ability.GetManaCost(ability)) or 0 end

function Tinker.GetEscapeManaCost()
  local tpCost     = State.KeenTeleport and Ability.GetManaCost(State.KeenTeleport) or 0
  local keenReady  = State.KeenTeleport and Ability.CanBeExecuted(State.KeenTeleport) == -1
  local rearmCost  = State.Rearm and Ability.GetManaCost(State.Rearm) or 0
  local rearmReady = State.Rearm and Ability.CanBeExecuted(State.Rearm) == -1

  if keenReady then return tpCost end
  if rearmReady then return rearmCost + tpCost end
  return rearmCost + tpCost
end

function Tinker.GetCampCycleManaCost()
  local tp       = ManaCost(State.KeenTeleport)
  local march    = ManaCost(State.March)
  local rearm    = ManaCost(State.Rearm)
  local tpReady  = State.KeenTeleport and Ability.CanBeExecuted(State.KeenTeleport) == -1
  local preRearm = tpReady and 0 or rearm
  return preRearm + tp + march + rearm + march + tp
end

function Tinker.HasManaForFullCampCycle()
  if not State.KeenTeleport or not State.March or not State.Rearm then return true end
  local curMana = NPC.GetMana(State.Hero) or 0
  local maxMana = NPC.GetMaxMana(State.Hero) or 0
  local need    = Tinker.GetCampCycleManaCost()
  if need > maxMana then return curMana >= (maxMana * 0.9) end
  return curMana >= need
end

function Tinker.NeedsToReturnToFountain()
  if not State.KeenTeleport then return false end
  local escapeMana = Tinker.GetEscapeManaCost()
  return (NPC.GetMana(State.Hero) or 0) < escapeMana
end

function Tinker.ShouldRequestTeleport(pos, force)
  if force then return true end
  local now = GameRules.GetGameTime()
  if now < (State.TeleportLockUntil or 0) then return false end

  local atFountain = HasFountainBuff()
  if not atFountain and now - (State.LastFarmTPAt or 0) < Constants.FARM_TP_MIN_INTERVAL then
    return false
  end

  local intended = Tinker.IntendedKeenTPPos(pos)

  if State.FarmState == "MOVING_TO_SPOT" and State.BlockTPThisSpot and State.LastSpotTelePos then
    if State.LastSpotTelePos:Distance(intended) <= Constants.SAME_SPOT_TP_EPS then return false end
  end

  if State.LastTeleportCastPos and State.LastTeleportCastPos:Distance(intended) <= Constants.SAME_SPOT_TP_EPS then
    if (now - (State.LastTeleportAt or 0)) < Constants.SAME_SPOT_TP_COOLDOWN then return false end
  end

  local myPos = Entity.GetAbsOrigin(State.Hero)
  if myPos:Distance(pos) <= intended:Distance(pos) then
    return false
  end
  if not Tinker.IsTeleportSafe(pos) then
    return false
  end

  return true
end

function Tinker.TryTeleportTo(pos, force)
  if not State.KeenTeleport then return false end
  if Ability.CanBeExecuted(State.KeenTeleport) ~= -1 then return false end
  local now = GameRules.GetGameTime()
  if not force and now < (State.TeleportLockUntil or 0) then return false end

  if not force and not Tinker.IsTeleportSafe(pos) then
    return false
  end

  local res      = Tinker.ResolveKeenTeleport(pos)
  local finalPos = res.finalPos
  local myPos    = Entity.GetAbsOrigin(State.Hero)

  if not force and myPos:Distance(finalPos) <= Constants.TP_MIN_DISTANCE then return false end
  if not force and myPos:Distance(pos) <= finalPos:Distance(pos) then return false end

  local issued = Utils.IssueOrder(res.castOrder, State.KeenTeleport, res.castData)
  if not issued then return false end

  State.LastTeleportAt      = now
  State.TeleportLockUntil   = now + Constants.POST_TP_LOCK_TIME
  State.LastTeleportCastPos = finalPos
  State.LastTeleportAnchor  = res.anchor or nil
  State.MovingAfterTeleport = true
  State.RecalcAfterTP       = true
  return true
end

function Tinker.RequestTeleportToSpot(spot, force)
  if not spot then return false end
  local key        = SpotKey(spot)
  local now        = GameRules.GetGameTime()
  local atFountain = HasFountainBuff()
  local wantForce  = force or atFountain

  if State.TargetSpotKey and key ~= State.TargetSpotKey then
    if not wantForce and now < (State.SpotCommitUntil or 0) then return false end
  end

  if not Tinker.ShouldRequestTeleport(spot.pos, wantForce) and not wantForce then return false end

  if State.KeenTeleport and Ability.CanBeExecuted(State.KeenTeleport) == -1 then
    local started = Tinker.TryTeleportTo(spot.pos, wantForce)
    if started then
      State.TargetSpotKey   = key
      State.SpotCommitUntil = now + Constants.SPOT_COMMIT_TIME
      if State.FarmState == "MOVING_TO_SPOT" then
        State.BlockTPThisSpot = true
        State.LastSpotTelePos = Tinker.IntendedKeenTPPos(spot.pos)
      end
      State.LastFarmTPAt = now
      return true
    else
      State.PendingTPPos   = spot.pos
      State.PendingTPSince = now
      State.PendingTPForce = wantForce
      return true
    end
  end
  if State.Rearm
      and Ability.CanBeExecuted(State.Rearm) == -1
      and State.KeenTeleport
      and Ability.CanBeExecuted(State.KeenTeleport) ~= -1 then
    local needMana = (Ability.GetManaCost(State.Rearm) or 0) + (Ability.GetManaCost(State.KeenTeleport) or 0)
    if (NPC.GetMana(State.Hero) or 0) >= needMana then
      State.PendingTPPos   = spot.pos
      State.PendingTPSince = now
      State.PendingTPForce = false
      if Utils.CastAbility(State.Rearm, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil) then
        State.LastRearmAt     = now
        State.TargetSpotKey   = key
        State.SpotCommitUntil = now + Constants.SPOT_COMMIT_TIME
      end
      return true
    end
  end

  return false
end

local function RequiredManaBeforeCommit()
  local marchCost  = State.March and (Ability.GetManaCost(State.March) or 0) or 0
  local escapeMana = Tinker.GetEscapeManaCost()
  return marchCost + escapeMana
end
function Tinker.HandleAutoBottle()
  if not Config.ItemsToUse:Get(L("item_bottle")) or State.IsChanneling then return end
  if not Config.Bottle.UseHP:Get() and not Config.Bottle.UseMana:Get() then return end

  local t = GameRules.GetGameTime()
  if t < (State.NextBottleCheck or 0) then return end
  State.NextBottleCheck = t + Constants.BOTTLE_CHECK_COOLDOWN

  local bottle = NPC.GetItem(State.Hero, "item_bottle", true)
  if not bottle or Ability.CanBeExecuted(bottle) ~= -1 or Item.GetCurrentCharges(bottle) <= 0 then return end
  if NPC.HasModifier(State.Hero, "modifier_bottle_regeneration") then return end

  local hpMissing   = Entity.GetMaxHealth(State.Hero) - Entity.GetHealth(State.Hero)
  local manaMissing = NPC.GetMaxMana(State.Hero) - NPC.GetMana(State.Hero)

  local needHP      = Config.Bottle.UseHP:Get() and (hpMissing >= Constants.BOTTLE_MISSING_THRESHOLD)
  local needMana    = Config.Bottle.UseMana:Get() and (manaMissing >= Constants.BOTTLE_MISSING_THRESHOLD)

  if needHP or needMana then
    Utils.CastAbility(bottle, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil)
  end
end

local function CountCampAliveCreeps(camp)
  if not camp or type(camp.alive_creeps) ~= "table" then return 0 end
  local cnt = 0
  for _, unit in pairs(camp.alive_creeps) do
    if unit and Entity.IsAlive(unit) then
      cnt = cnt + 1
    end
  end
  return cnt
end

function Tinker.ProcessAfterMarchCheck()
  local am = State.AfterMarchCheck
  if not am then return end

  local t            = GameRules.GetGameTime()
  local minTime      = Constants.CAMP_CLEAR_DELAY
  local confirmWin   = Constants.CAMP_CLEAR_CONFIRM_DELAY
  local begunConfirm = (t - (am.startedAt or 0)) >= minTime

  if am.camp1 then
    local c1 = CountCampAliveCreeps(am.camp1)
    if c1 > 0 then
      am.zeroSince1 = nil
    else
      if begunConfirm then
        am.zeroSince1 = am.zeroSince1 or t
        if (t - am.zeroSince1) >= confirmWin then
          am.camp1.farmed = true
        end
      end
    end
  end

  if am.camp2 then
    local c2 = CountCampAliveCreeps(am.camp2)
    if c2 > 0 then
      am.zeroSince2 = nil
    else
      if begunConfirm then
        am.zeroSince2 = am.zeroSince2 or t
        if (t - am.zeroSince2) >= confirmWin then
          am.camp2.farmed = true
        end
      end
    end
  end

  local cleared = (am.camp1 and am.camp1.farmed or false)
      and ((not am.camp2) or (am.camp2 and am.camp2.farmed))

  if cleared then
    State.AfterMarchCheck = nil
    if State.FarmState == "FARMING_SPOT" then
      State.FarmState                = "IDLE"
      State.CurrentFarmSpot          = nil
      State.JustClearedSpotAt        = GameRules.GetGameTime()
      State.CurrentSpotMarchCasts    = 0
      State.CurrentSpotMarchRequired = nil
    end
  end
end

local function TryCastMatrix(mode)
  if not Config.AutoMatrix:Get() then return false end
  local m = NPC.GetAbility(State.Hero, "tinker_defense_matrix")
  if not m or Ability.CanBeExecuted(m) ~= -1 then return false end

  if mode == "precast" then
    if not Config.Matrix.PrecastAtFountain:Get() then return false end
    if not HasFountainBuff() then return false end
    if State.IsChanneling then return false end
    if Modifier.GetDuration(NPC.GetModifier(State.Hero, "modifier_tinker_defense_matrix")) > 7 then return false end
    if GameRules.GetGameTime() - (State.MatrixCastTime or 0) < 0.2 then return false end
    local ok = Utils.CastAbility(m, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET, State.Hero)
    if ok then State.MatrixCastTime = GameRules.GetGameTime() end
    return ok
  elseif mode == "panic" then
    if not Config.Matrix.UseDuringPanic:Get() then return false end
    if GameRules.GetGameTime() - (State.LastPanicMatrixAt or 0) < Constants.PANIC_MATRIX_COOLDOWN then return false end
    local ok = Utils.CastAbility(m, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET, State.Hero)
    if ok then State.LastPanicMatrixAt = GameRules.GetGameTime() end
    return ok
  end
  return false
end

function Tinker.HandlePanic()
  if not State.Hero then return false end

  local now    = GameRules.GetGameTime()
  local hp     = Entity.GetHealth(State.Hero) or 0
  local maxHp  = Entity.GetMaxHealth(State.Hero) or 1
  local hpFrac = hp / math.max(1, maxHp)
  if State.LastHP == nil or State.LastHPTime == nil then
    State.LastHP     = hp
    State.LastHPTime = now
    return false
  end

  local lowHP = hpFrac <= Constants.PANIC_HP_FRAC
  if lowHP then
    State.PanicArmingSince = State.PanicArmingSince or now
  else
    State.PanicArmingSince = nil
    return false
  end

  local armed      = State.PanicArmingSince and (now - State.PanicArmingSince) >= Constants.PANIC_ARM_TIME
  local canTrigger = now >= (State.PanicCooldownUntil or 0)
  if not (armed and canTrigger) then return false end

  State.PanicCooldownUntil = now + Constants.PANIC_COOLDOWN
  State.PanicReason        = lowHP and "lowHP" or "hpDPS"
  State.FarmState          = "RETURNING_TO_FOUNTAIN"
  State.AfterMarchCheck    = nil
  State.TargetSpotKey      = nil
  State.SpotCommitUntil    = 0

  local fountainPos        = (State.HeroTeam == 2) and Constants.FOUNTAIN_DIRE or Constants.FOUNTAIN_RADIANT

  if State.IsChanneling then
    State.PendingTPPos   = fountainPos
    State.PendingTPSince = now
    State.PendingTPForce = true
    return true
  end
  TryCastMatrix("panic")

  if Tinker.TryTeleportTo(fountainPos, true) then
    State.LastFarmTPAt = now
    return true
  end

  if Config.ItemsToUse:Get(L("item_blink")) and Config.Blink.Escape:Get() and State.Blink and Ability.CanBeExecuted(State.Blink) == -1 then
    local myPos      = Entity.GetAbsOrigin(State.Hero)
    local toFountain = (fountainPos - myPos)
    local dist       = toFountain:Length()
    local blinkPos   = dist > Constants.BLINK_MAX_RANGE
        and (myPos + toFountain:Normalized() * Constants.BLINK_MAX_RANGE) or fountainPos
    Utils.CastAbility(State.Blink, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, blinkPos)
  end

  Utils.MoveTo(fountainPos)
  return true
end

local function ComputeSafeBlinkPos(targetPos)
  if not State.Hero then return nil end
  local myPos = Entity.GetAbsOrigin(State.Hero)
  local dir   = (targetPos - myPos)
  local dist  = dir:Length()
  if dist <= Constants.BLINK_MIN_DISTANCE then return nil end
  local ndir     = dir:Normalized()
  local standOff = Constants.BLINK_SAFE_STANDOFF
  local maxStep  = Constants.BLINK_MAX_RANGE
  local desired  = math.max(dist - standOff, 0)
  local step     = math.min(maxStep, desired > 0 and desired or dist)
  return myPos + ndir * step
end

function Tinker.HandleFarming()
  Tinker.ProcessMarchVerify()

  if not Config.MarchControl.UseCustom:Get() then
    Tinker.ProcessAfterMarchCheck()
  else
    State.AfterMarchCheck = nil
  end
  if Tinker.HandlePanic() then return end
  if State.IsChanneling then return end
  if State.PendingTPPos then
    local age = GameRules.GetGameTime() - (State.PendingTPSince or 0)
    if age > (Constants.PENDING_TP_MAX_AGE or 2.5) then
      State.PendingTPPos   = nil
      State.PendingTPForce = false
    else
      if State.KeenTeleport and Ability.CanBeExecuted(State.KeenTeleport) == -1 then
        if State.PendingTPForce then
          if Tinker.TryTeleportTo(State.PendingTPPos, true) then
            State.PendingTPPos   = nil
            State.PendingTPForce = false
            return
          end
        else
          if Tinker.ShouldRequestTeleport(State.PendingTPPos, false) then
            if Tinker.TryTeleportTo(State.PendingTPPos, false) then
              State.LastFarmTPAt   = GameRules.GetGameTime()
              State.PendingTPPos   = nil
              State.PendingTPForce = false
              return
            end
          else
            State.PendingTPPos   = nil
            State.PendingTPForce = false
          end
        end
      end
    end
  end
  local usingCustom = Config.MarchControl.UseCustom:Get()
  if State.MarchModeWasCustom ~= usingCustom then
    State.MarchModeWasCustom = usingCustom

    if usingCustom then
      State.AfterMarchCheck = nil
    end

    if State.CurrentFarmSpot and usingCustom then
      State.CurrentSpotMarchCasts = 0
      State.CurrentSpotMarchRequired = ComputeRequiredMarchesForSpot(State.CurrentFarmSpot)
      if (State.CurrentSpotMarchRequired or 0) <= 0 then
        MarkSpotFarmedAndLeave()
        return
      end
    end

    SyncMarchSlidersDisabled()
  end

  if State.FarmState == "FARMING_SPOT" and Tinker.NeedsToReturnToFountain() then
    State.FarmState                = "RETURNING_TO_FOUNTAIN"
    State.CurrentFarmSpot          = nil
    State.AfterMarchCheck          = nil
    State.TargetSpotKey            = nil
    State.SpotCommitUntil          = 0
    State.CurrentSpotMarchCasts    = 0
    State.CurrentSpotMarchRequired = nil
    return
  end

  if State.FarmState == "IDLE" then
    if State.JustClearedSpotAt > 0 and (GameRules.GetGameTime() - State.JustClearedSpotAt) < Constants.IDLE_DECISION_DELAY then
      return
    end

    local bestSpot = Tinker.GetBestFarmSpotCached()
    if bestSpot then
      if not Tinker.HasManaForFullCampCycle() then
        State.FarmState       = "RETURNING_TO_FOUNTAIN"
        State.CurrentFarmSpot = nil
        State.AfterMarchCheck = nil
        State.TargetSpotKey   = nil
        State.SpotCommitUntil = 0
        return
      end

      State.CurrentFarmSpot       = bestSpot
      State.TargetSpotKey         = SpotKey(bestSpot)
      State.SpotCommitUntil       = GameRules.GetGameTime() + Constants.SPOT_COMMIT_TIME

      State.BlockTPThisSpot       = false
      State.LastSpotTelePos       = nil
      State.MovingAfterTeleport   = false
      State.RecalcAfterTP         = false
      State.JustClearedSpotAt     = 0
      State.AfterMarchCheck       = nil
      State.LastMarchCastAt       = 0
      State.CurrentSpotMarchCasts = 0
      if Config.MarchControl.UseCustom:Get() then
        State.CurrentSpotMarchRequired = ComputeRequiredMarchesForSpot(bestSpot)
        if (State.CurrentSpotMarchRequired or 0) <= 0 then
          MarkSpotFarmedAndLeave()
          return
        end
      else
        State.CurrentSpotMarchRequired = nil
      end

      State.FarmState = "MOVING_TO_SPOT"
    end
  elseif State.FarmState == "MOVING_TO_SPOT" then
    local spot = State.CurrentFarmSpot
    if not spot or not spot.camp1 or spot.camp1.farmed then
      State.FarmState = "IDLE"
      return
    end

    if State.RecalcAfterTP and (GameRules.GetGameTime() - (State.LastTeleportAt or 0)) > 0.2 then
      RecenterSpot(spot)
      State.RecalcAfterTP = false
    end
    if Config.MarchControl.UseCustom:Get() and (State.CurrentSpotMarchRequired or 0) <= 0 then
      MarkSpotFarmedAndLeave()
      return
    end

    if not Tinker.HasManaForFullCampCycle() then
      State.FarmState                = "RETURNING_TO_FOUNTAIN"
      State.CurrentFarmSpot          = nil
      State.AfterMarchCheck          = nil
      State.TargetSpotKey            = nil
      State.SpotCommitUntil          = 0
      State.CurrentSpotMarchCasts    = 0
      State.CurrentSpotMarchRequired = nil
      return
    end

    local myPos    = Entity.GetAbsOrigin(State.Hero)
    local castInfo = ComputeMarchCastInfo(spot)
    if not castInfo then
      State.FarmState = "IDLE"
      return
    end

    local intended   = Tinker.IntendedKeenTPPos(castInfo.pos)
    local distToLand = myPos:Distance(intended)
    local allowedMax = Constants.MARCH_CAST_RANGE * (spot.single and 1.0 or Constants.MARCH_PAIR_COVERAGE_FRAC)

    if castInfo.maxDist <= allowedMax and myPos:Distance(castInfo.pos) <= Constants.MARCH_CAST_RANGE then
      State.MovingAfterTeleport = false
      State.FarmState           = "FARMING_SPOT"
      if Config.MarchControl.UseCustom:Get() then
        if (State.CurrentSpotMarchRequired or 0) <= (State.CurrentSpotMarchCasts or 0) then
          MarkSpotFarmedAndLeave()
          return
        end
      end
      return
    end

    local requiredMana = RequiredManaBeforeCommit()
    local curMana      = NPC.GetMana(State.Hero) or 0
    local atFountain   = HasFountainBuff()

    if distToLand > Constants.TP_MIN_DISTANCE then
      if curMana >= requiredMana then
        if Tinker.RequestTeleportToSpot(spot, atFountain) then return end
      else
        State.FarmState                = "RETURNING_TO_FOUNTAIN"
        State.CurrentFarmSpot          = nil
        State.AfterMarchCheck          = nil
        State.TargetSpotKey            = nil
        State.SpotCommitUntil          = 0
        State.CurrentSpotMarchCasts    = 0
        State.CurrentSpotMarchRequired = nil
        return
      end
    end
    local holdBlink = State.PendingTPPos ~= nil
    if not holdBlink then
      if Config.Blink.HoldTPLock:Get() and (GameRules.GetGameTime() - (State.LastTeleportAt or 0)) <= 0.25 then
        holdBlink = true
      elseif Config.Blink.HoldAfterRearm:Get() and (GameRules.GetGameTime() - (State.LastRearmAt or 0)) <= Constants.BLINK_HOLD_AFTER_REARM then
        holdBlink = true
      end
    end

    if not holdBlink and Config.ItemsToUse:Get(L("item_blink")) and Config.Blink.Travel:Get() and State.Blink and Ability.CanBeExecuted(State.Blink) == -1 then
      local blinkPos = ComputeSafeBlinkPos(castInfo.pos)
      if blinkPos and Utils.CastAbility(State.Blink, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, blinkPos) then return end
    end

    Utils.MoveTo(castInfo.pos)
  elseif State.FarmState == "FARMING_SPOT" then
    local spot = State.CurrentFarmSpot
    if not spot or (spot.camp1.farmed and (spot.single or spot.camp2.farmed)) then
      State.FarmState                = "IDLE"
      State.AfterMarchCheck          = nil
      State.CurrentSpotMarchCasts    = 0
      State.CurrentSpotMarchRequired = nil
      return
    end
    if Config.MarchControl.UseCustom:Get() then
      local req = State.CurrentSpotMarchRequired or 0
      if req > 0 and (State.CurrentSpotMarchCasts or 0) >= req then
        MarkSpotFarmedAndLeave()
        return
      end
    end

    local escapeMana  = Tinker.GetEscapeManaCost()
    local t           = GameRules.GetGameTime()
    local am          = Config.MarchControl.UseCustom:Get() and nil or State.AfterMarchCheck
    local minGap      = Constants.MARCH_MIN_RECAST_GAP
    local rearmGap    = Constants.REARM_MIN_GAP_AFTER_MARCH
    local canMarchNow = State.March and Ability.CanBeExecuted(State.March) == -1
    local canRearmNow = State.Rearm and Ability.CanBeExecuted(State.Rearm) == -1
    local justTPedAgo = t - (State.LastTeleportAt or 0)

    local c1          = spot.camp1 and CountCampAliveCreeps(spot.camp1) or 0
    local c2          = (not spot.single and spot.camp2 and CountCampAliveCreeps(spot.camp2)) or 0
    local anyAlive    = (c1 > 0) or (c2 > 0)

    if am then
      local begunConfirm = (t - (am.startedAt or 0)) >= Constants.CAMP_CLEAR_DELAY
      local zero1        = (not am.camp1) or CountCampAliveCreeps(am.camp1) == 0
      local zero2        = (not am.camp2) or CountCampAliveCreeps(am.camp2) == 0
      local allZero      = zero1 and zero2

      if (Constants.HOLD_ACTIONS_DURING_CONFIRM and begunConfirm and allZero) then
        return
      end

      if anyAlive and canMarchNow then
        local marchCost = Ability.GetManaCost(State.March) or 0
        if (t - (State.LastMarchCastAt or 0)) >= minGap and ((NPC.GetMana(State.Hero) or 0) - marchCost) >= escapeMana then
          Utils.CastAbility(State.March, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, spot.pos)
        end
        return
      end

      if anyAlive and canRearmNow then
        if justTPedAgo >= Constants.NO_REARM_AFTER_TP and (t - (State.LastMarchCastAt or 0)) >= rearmGap then
          local rearmCost = Ability.GetManaCost(State.Rearm) or 0
          if ((NPC.GetMana(State.Hero) or 0) - rearmCost) >= escapeMana then
            Utils.CastAbility(State.Rearm, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil)
          else
            State.FarmState                = "RETURNING_TO_FOUNTAIN"
            State.CurrentFarmSpot          = nil
            State.AfterMarchCheck          = nil
            State.TargetSpotKey            = nil
            State.SpotCommitUntil          = 0
            State.CurrentSpotMarchCasts    = 0
            State.CurrentSpotMarchRequired = nil
          end
        end
        return
      end

      return
    end

    if canMarchNow then
      local marchCost = Ability.GetManaCost(State.March) or 0
      if ((NPC.GetMana(State.Hero) or 0) - marchCost) >= escapeMana then
        if Utils.CastAbility(State.March, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, spot.pos) then
          if not Config.MarchControl.UseCustom:Get() then
            State.AfterMarchCheck = {
              startedAt  = t,
              zeroSince1 = nil,
              zeroSince2 = nil,
              camp1      = spot.camp1,
              camp2      = spot.single and nil or spot.camp2
            }
          end
        end
      else
        State.FarmState                = "RETURNING_TO_FOUNTAIN"
        State.CurrentFarmSpot          = nil
        State.AfterMarchCheck          = nil
        State.TargetSpotKey            = nil
        State.SpotCommitUntil          = 0
        State.CurrentSpotMarchCasts    = 0
        State.CurrentSpotMarchRequired = nil
      end
      return
    end

    if canRearmNow then
      if justTPedAgo >= Constants.NO_REARM_AFTER_TP and (t - (State.LastMarchCastAt or 0)) >= rearmGap then
        local rearmCost = Ability.GetManaCost(State.Rearm) or 0
        if ((NPC.GetMana(State.Hero) or 0) - rearmCost) >= escapeMana then
          Utils.CastAbility(State.Rearm, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil)
        else
          State.FarmState                = "RETURNING_TO_FOUNTAIN"
          State.CurrentFarmSpot          = nil
          State.AfterMarchCheck          = nil
          State.TargetSpotKey            = nil
          State.SpotCommitUntil          = 0
          State.CurrentSpotMarchCasts    = 0
          State.CurrentSpotMarchRequired = nil
        end
      end
      return
    end
  elseif State.FarmState == "RETURNING_TO_FOUNTAIN" then
    State.TargetSpotKey   = nil
    State.SpotCommitUntil = 0

    if HasFountainBuff() then
      local maxMana     = NPC.GetMaxMana(State.Hero) or 0
      local curMana     = NPC.GetMana(State.Hero) or 0
      local cycleCost   = Tinker.GetCampCycleManaCost()
      local minFracNeed = maxMana * Constants.FOUNTAIN_MIN_MANA_FRAC
      local need        = math.max(minFracNeed, math.min(cycleCost, maxMana * 0.95))
      if curMana >= need then
        State.FarmState = "IDLE"
      end
      return
    end

    local fountainPos = (State.HeroTeam == 2) and Constants.FOUNTAIN_DIRE or Constants.FOUNTAIN_RADIANT
    if State.IsChanneling then
      State.PendingTPPos   = fountainPos
      State.PendingTPSince = GameRules.GetGameTime()
      State.PendingTPForce = true
      return
    end

    if State.KeenTeleport and Ability.CanBeExecuted(State.KeenTeleport) == -1 then
      if Tinker.TryTeleportTo(fountainPos, true) then
        State.LastFarmTPAt = GameRules.GetGameTime()
        return
      end
    end

    if State.Rearm
        and Ability.CanBeExecuted(State.Rearm) == -1
        and State.KeenTeleport
        and Ability.CanBeExecuted(State.KeenTeleport) ~= -1 then
      local needMana = (Ability.GetManaCost(State.Rearm) or 0) + (Ability.GetManaCost(State.KeenTeleport) or 0)
      if (NPC.GetMana(State.Hero) or 0) >= needMana then
        State.PendingTPPos   = fountainPos
        State.PendingTPSince = GameRules.GetGameTime()
        State.PendingTPForce = true
        if Utils.CastAbility(State.Rearm, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET, nil) then
          State.LastRearmAt = GameRules.GetGameTime()
          return
        end
      end
    end

    if Config.ItemsToUse:Get(L("item_blink")) and Config.Blink.Travel:Get() and State.Blink and Ability.CanBeExecuted(State.Blink) == -1 then
      local myPos      = Entity.GetAbsOrigin(State.Hero)
      local toFountain = (fountainPos - myPos)
      local dist       = toFountain:Length()
      local blinkPos   = dist > Constants.BLINK_MAX_RANGE and
          (myPos + toFountain:Normalized() * Constants.BLINK_MAX_RANGE) or fountainPos
      if Utils.CastAbility(State.Blink, Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, blinkPos) then return end
    end

    Utils.MoveTo(fountainPos)
  end
end

local Theme = {
  bg           = Color(14, 16, 20, 205),
  bg2          = Color(20, 23, 29, 225),
  border       = Color(70, 78, 92, 205),
  shadow       = Color(0, 0, 0, 180),

  text         = Color(230, 235, 245, 255),
  dim          = Color(160, 170, 185, 255),

  good         = Color(120, 255, 180, 255),
  warn         = Color(255, 220, 130, 255),
  bad          = Color(255, 120, 120, 255),

  accent       = Color(120, 220, 255, 255),
  accent2      = Color(120, 255, 180, 255),
  gold         = Color(255, 220, 110, 255),

  ringCast     = Color(120, 255, 120, 165),
  ringPair     = Color(120, 180, 255, 140),
  ringFail     = Color(255, 120, 120, 150),

  campDot      = Color(255, 210, 120, 220),

  tpAnchor     = Color(200, 140, 255, 245),
  tpAnchorRing = Color(200, 140, 255, 155),
  tpAnchorPath = Color(200, 140, 255, 170),
}

local UI = {
  fonts    = { regular = nil, small = nil, bold = nil },
  pad      = 10,
  rowH     = 18,
  rounding = 10,
}

local function EnsureFonts()
  if not UI.fonts.regular then UI.fonts.regular = Render.LoadFont("Tahoma", 0, 500) end
  if not UI.fonts.small then UI.fonts.small = Render.LoadFont("Tahoma", 0, 450) end
  if not UI.fonts.bold then UI.fonts.bold = Render.LoadFont("Tahoma", 0, 700) end
  if not State.DebugFont then State.DebugFont = UI.fonts.regular end
end

local function Lerp(a, b, t) return a + (b - a) * t end
local function Pulse(t, speed, minA, maxA) return Lerp(minA, maxA, 0.5 + 0.5 * math.sin(t * speed)) end
local function W2S(v) return Render.WorldToScreen(v) end

local function Chip(pos, text, colText, colBg)
  EnsureFonts()
  local padX, padY = 6, 3
  local ts         = Render.TextSize(UI.fonts.small, 14, text)
  local s          = Vec2(pos.x, pos.y)
  local e          = Vec2(pos.x + ts.x + padX * 2, pos.y + ts.y + padY * 2)
  Render.FilledRect(s, e, colBg or Theme.bg2, 8)
  Render.Rect(s, e, Theme.border, 8, nil, 1.0)
  Render.Text(UI.fonts.small, 14, text, Vec2(pos.x + padX, pos.y + padY), colText or Theme.text)
end

local function WorldRing(center, radius, color, thickness, segments)
  segments = segments or 56
  local pts = {}
  for i = 0, segments do
    local ang     = (i / segments) * math.pi * 2
    local wp      = Vector(center.x + math.cos(ang) * radius, center.y + math.sin(ang) * radius, center.z)
    local sp, vis = W2S(wp)
    if not vis then return end
    table.insert(pts, sp)
  end
  if #pts > 1 then Render.PolyLine(pts, color, thickness or 1.8) end
end

local function WorldDashed(a, b, color, thickness, dash, gap)
  local sa, va = W2S(a)
  local sb, vb = W2S(b)
  if not (va and vb) then return end
  thickness = thickness or 1.4
  dash      = dash or 8
  gap       = gap or 6
  local d   = sb - sa
  local len = math.sqrt(d.x * d.x + d.y * d.y)
  if len < 1 then return end
  local dir = Vec2(d.x / len, d.y / len)
  local t = 0
  while t < len do
    local seg = math.min(dash, len - t)
    Render.Line(sa + dir * t, sa + dir * (t + seg), color, thickness)
    t = t + dash + gap
  end
end

local function WorldArrow(fromPos, toPos, color, width)
  local s1, v1 = W2S(fromPos)
  local s2, v2 = W2S(toPos)
  if not (v1 and v2) then return end
  width = width or 2.0
  Render.Line(s1, s2, color, width)
  local v = s2 - s1
  local len = math.sqrt(v.x * v.x + v.y * v.y)
  if len <= 0.01 then return end
  local dir  = Vec2(v.x / len, v.y / len)
  local left = Vec2(-dir.y, dir.x)
  local base = s2 - dir * 12
  Render.FilledTriangle({ s2, base + left * 6, base - left * 6 }, color)
end

local function WorldDot(pos, color)
  local sp, vis = W2S(pos)
  if not vis then return end
  Render.FilledCircle(sp, 5.5, color)
  Render.Circle(sp, 8.5, Color(color.r, color.g, color.b, 70), 1.2, 0, 1, false, 28)
end

local function CampTag(pos, txt)
  local s, vis = W2S(pos); if not vis then return end
  Chip(s + Vec2(10, -8), txt, Theme.text, Color(22, 25, 31, 225))
end

local function DrawTPAnchorDebug(targetPos, pathEndPos, tagText)
  local heroPos  = Entity.GetAbsOrigin(State.Hero)
  local res      = Tinker.ResolveKeenTeleport(targetPos)
  local has      = res and res.anchor ~= nil
  local ap       = has and res.anchorPos or targetPos
  local rad      = res and res.landingRadius or 0
  local fp       = res and res.finalPos or targetPos
  local labelCat = has and (res.cat or "anchor") or "raw"
  local dist     = math.floor(heroPos:Distance(fp))
  local label    = (tagText and (tagText .. " • ") or "") .. "TP • " .. labelCat .. " • " .. dist

  if has and rad > 0 then
    WorldRing(ap, rad, Theme.tpAnchorRing, 1.7, 64)
  end

  WorldDot(fp, has and Theme.tpAnchor or Theme.bad)
  WorldArrow(ap, fp, has and Theme.tpAnchor or Theme.bad, 2.0)

  if pathEndPos then
    WorldDashed(ap, pathEndPos, Theme.tpAnchorPath, 1.6, 8, 6)
  end

  WorldDot(ap, Theme.accent2)
  local s, vis = W2S(ap)
  if vis then
    Chip(s + Vec2(12, -22), label, has and Theme.tpAnchor or Theme.bad, Color(20, 22, 28, 230))
  end
end

local function DrawWorldSpotNeo(spot)
  local castPos    = spot.pos
  local heroPos    = Entity.GetAbsOrigin(State.Hero)
  local castInfo   = ComputeMarchCastInfo(spot)
  local allowedMax = Constants.MARCH_CAST_RANGE * (spot.single and 1.0 or Constants.MARCH_PAIR_COVERAGE_FRAC)
  local now        = GameRules.GetGameTime()

  local s, vis     = W2S(castPos)
  if vis then
    local haloA = math.floor(Pulse(now, 3.0, 0.45, 0.8) * 255)
    Render.CircleGradient(s, 22, Color(0, 0, 0, 0), Color(120, 255, 160, haloA))
  end

  local castAlpha = math.floor(Pulse(now, 3.0, 110, 165))
  WorldRing(castPos, Constants.MARCH_CAST_RANGE, Color(Theme.ringCast.r, Theme.ringCast.g, Theme.ringCast.b, castAlpha),
    2.0, 60)
  if not spot.single then
    local fit = castInfo.maxDist <= allowedMax
    local col = fit and Theme.ringPair or Theme.ringFail
    WorldRing(castPos, allowedMax, col, 1.6, 56)
  end

  if spot.camp1 and spot.camp1.pos then
    WorldDot(spot.camp1.pos, Theme.campDot)
    WorldDashed(castPos, spot.camp1.pos, Color(255, 255, 255, 80), 1.2, 7, 5)
    if Config.Debug.Pretty:Get() then CampTag(spot.camp1.pos, "A") end
  end
  if spot.camp2 and spot.camp2.pos then
    WorldDot(spot.camp2.pos, Theme.campDot)
    WorldDashed(castPos, spot.camp2.pos, Color(255, 255, 255, 80), 1.2, 7, 5)
    WorldDashed(spot.camp1.pos, spot.camp2.pos, Color(255, 230, 140, 95), 1.4, 8, 5)
    if Config.Debug.Pretty:Get() then CampTag(spot.camp2.pos, "B") end
  end

  WorldArrow(heroPos, castPos, Theme.accent2, 2.0)

  if Config.Debug.Bounty:Get() and vis then
    local typ = spot.single and "Single" or "Pair"
    local g   = FormatGold(spot.gold or 0)
    Chip(s + Vec2(12, -26), string.format("%s • %s", typ, g), Theme.gold, Color(20, 22, 28, 225))
  end

  DrawTPAnchorDebug(castPos, castPos, nil)
end

local function DrawWorldSpotMinimal(spot)
  local castPos    = spot.pos
  local heroPos    = Entity.GetAbsOrigin(State.Hero)
  local castInfo   = ComputeMarchCastInfo(spot)
  local allowedMax = Constants.MARCH_CAST_RANGE * (spot.single and 1.0 or Constants.MARCH_PAIR_COVERAGE_FRAC)
  WorldRing(castPos, Constants.MARCH_CAST_RANGE, Color(120, 255, 120, 150), 1.6, 48)
  if not spot.single then
    local fit = castInfo.maxDist <= allowedMax
    WorldRing(castPos, allowedMax, fit and Color(120, 180, 255, 140) or Color(255, 120, 120, 140), 1.4, 48)
  end
  if spot.camp1 and spot.camp1.pos then WorldDot(spot.camp1.pos, Theme.campDot) end
  if spot.camp2 and spot.camp2.pos then WorldDot(spot.camp2.pos, Theme.campDot) end
  WorldArrow(heroPos, castPos, Theme.accent2, 1.8)
  DrawTPAnchorDebug(castPos, castPos, nil)
end

local function DrawDockOverlay()
  EnsureFonts()

  local x, y     = 16, 110
  local w        = 360
  local pad      = UI.pad
  local tNow     = GameRules.GetGameTime()
  local lines    = {}

  local stateCol = Theme.text
  if State.FarmState == "FARMING_SPOT" then
    stateCol = Theme.good
  elseif State.FarmState == "RETURNING_TO_FOUNTAIN" then
    stateCol = Theme.warn
  end

  table.insert(lines,
    { "State", string.format("%s  (channeling: %s)", State.FarmState, tostring(State.IsChanneling)), stateCol })

  local tpLockRemain = math.max(0, (State.TeleportLockUntil or 0) - tNow)
  table.insert(lines, { "TP lock",
    string.format("movingAfterTP=%s  remain=%.1fs  pending=%s",
      tostring(State.MovingAfterTeleport),
      tpLockRemain,
      tostring(State.PendingTPPos ~= nil)),
    (tpLockRemain > 0) and Theme.warn or Theme.dim
  })

  if State.CurrentFarmSpot then
    local spot       = State.CurrentFarmSpot
    local castInfo   = ComputeMarchCastInfo(spot)
    local allowedMax = Constants.MARCH_CAST_RANGE * (spot.single and 1.0 or Constants.MARCH_PAIR_COVERAGE_FRAC)
    local fit        = castInfo.maxDist <= allowedMax

    table.insert(lines, { "Spot",
      string.format("key=%s  commitRem=%.1f  lastFarmTP=%.1f",
        tostring(State.TargetSpotKey),
        math.max(0, (State.SpotCommitUntil or 0) - tNow),
        math.max(0, tNow - (State.LastFarmTPAt or 0))),
      Theme.dim })

    if Config.Debug.Bounty:Get() then
      table.insert(lines, { "Bounty", FormatGold(spot.gold or 0), Theme.gold })
    end

    if Config.Debug.Spot:Get() then
      table.insert(lines, { "Type",
        spot.single and "single" or ("pair (" .. math.floor(Constants.MARCH_PAIR_COVERAGE_FRAC * 100) .. "% cover)"),
        Theme.dim })
      table.insert(lines,
        { "Max Camp Dist", string.format("%.0f / %.0f", castInfo.maxDist, allowedMax), fit and Theme.good or Theme.bad })
      table.insert(lines,
        { "Hero->Cast", string.format("%.0f / %d", Entity.GetAbsOrigin(State.Hero):Distance(castInfo.pos),
          Constants.MARCH_CAST_RANGE), Theme.dim })
    end
    local mode = Config.MarchControl.UseCustom:Get() and "Custom Count" or "Until Cleared"
    table.insert(lines, { "March Mode", mode, Theme.accent })
    if Config.MarchControl.UseCustom:Get() then
      local req = State.CurrentSpotMarchRequired or 0
      local have = State.CurrentSpotMarchCasts or 0
      table.insert(lines, { "Marches", string.format("%d / %d", have, req), (have >= req and Theme.good or Theme.dim) })
    end
  end

  if Config.Debug.Orders:Get() then
    local nextReady = math.max(0, (State.NextOrderTime or 0) - tNow)
    table.insert(lines,
      { "Orders", string.format("tick=%d  perSec=%d  next=%.2fs", State.OrdersThisUpdate or 0, State.OrdersPerSec or 0,
        nextReady), Theme.dim })
    if State.LastOrderDebug then
      local lod = State.LastOrderDebug
      local tag = lod.allowed and "sent" or ("blocked:" .. (lod.reason or "?"))
      local pos = lod.tpos and (" to(" .. math.floor(lod.tpos.x) .. "," .. math.floor(lod.tpos.y) .. ")") or ""
      table.insert(lines,
        { "Last Order", string.format("%s%s [%s]%s", lod.order or "?", lod.ability and ("(" .. lod.ability .. ")") or "",
          tag, pos), lod.allowed and Theme.good or Theme.bad })
    end
  end

  local labelW = 0
  for _, r in ipairs(lines) do
    local ts = Render.TextSize(UI.fonts.small, 14, r[1])
    if ts.x > labelW then labelW = ts.x end
  end
  labelW         = labelW + 12
  local contentH = #lines * UI.rowH + pad * 2

  local start    = Vec2(x, y)
  local end_     = Vec2(x + w, y + contentH + 10)
  Render.Shadow(start, end_, Theme.shadow, 14, UI.rounding)
  Render.Blur(start, end_, 0.85, 0.9, UI.rounding)
  Render.FilledRect(start, end_, Theme.bg2, UI.rounding)
  Render.Rect(start, end_, Theme.border, UI.rounding, nil, 1.0)

  Chip(Vec2(x + pad, y - 22), "Auto Push&Farm — Debug", Theme.text, Color(18, 20, 26, 230))

  local ry = y + pad + 6
  for _, r in ipairs(lines) do
    Render.Text(UI.fonts.small, 14, r[1], Vec2(x + pad, ry), Theme.dim)
    Render.Text(UI.fonts.small, 14, r[2], Vec2(x + pad + labelW, ry), r[3])
    ry = ry + UI.rowH
  end
end
local function DrawStatusOverlay()
  if not Config.StatusOverlay:Get() then return end
  EnsureFonts()

  local ui = State.StatusUI
  local pos = Vec2(ui.x, ui.y)

  local isOn = Config.AutoFarm:IsToggled()
  local label = isOn and "AutoFarm: ON" or "AutoFarm: OFF"
  local colBg = isOn and Theme.bg2
  local colBar = isOn and Theme.good or Theme.bad
  local colText = isOn and Theme.good or Theme.bad
  local padX, padY = 10, 7
  local ts = Render.TextSize(UI.fonts.bold, 15, label)
  local w = math.max(140, ts.x + padX * 2 + 6)
  local h = ts.y + padY * 2
  local s = pos
  local e = Vec2(pos.x + w, pos.y + h)
  Render.Shadow(s, e, Theme.shadow, 12, 8)
  Render.Blur(s, e, 0.7, 0.9, 8)
  Render.FilledRect(s, e, Theme.bg2, 8)
  Render.Rect(s, e, Theme.border, 8, nil, 1.0)
  local barW = 5
  Render.FilledRect(s, Vec2(s.x + barW, e.y), colBar, 8)
  Render.Text(UI.fonts.bold, 15, label, Vec2(pos.x + padX + barW + 4, pos.y + padY), colText)
  if not Config.Status.Lock:Get() and Input and Input.GetCursorPos and Input.IsKeyDown then
    local x, y = Input.GetCursorPos()
    local inside = (x >= s.x and x <= e.x and y >= s.y and y <= e.y)
    local down = Input.IsKeyDown(Enum.ButtonCode.KEY_MOUSE1)

    if ui.dragging then
      if down then
        ui.x = x - ui.dragDX
        ui.y = y - ui.dragDY
      else
        ui.dragging = false
      end
    else
      if inside and down and not ui.mousePrevDown then
        ui.dragging = true
        ui.dragDX = x - ui.x
        ui.dragDY = y - ui.y
      end
    end
    ui.mousePrevDown = down
  end
end

script.OnDraw = function()
  if not Engine.IsInGame() then return end
  if not State.Hero or not Entity.IsAlive(State.Hero) then return end
  if Entity.GetUnitName(State.Hero) ~= "npc_dota_hero_tinker" then return end
  DrawStatusOverlay()

  if Config.Debug.World:Get() and State.CurrentFarmSpot then
    if Config.Debug.Pretty:Get() then
      DrawWorldSpotNeo(State.CurrentFarmSpot)
    else
      DrawWorldSpotMinimal(State.CurrentFarmSpot)
    end
  end

  if Config.Debug.World:Get() and State.PendingTPPos then
    DrawTPAnchorDebug(State.PendingTPPos, State.PendingTPPos, "Pending")
  end

  if Config.Debug.Overlay:Get() then
    DrawDockOverlay()
  end
end

script.OnUpdate = function()
  if not Engine.IsInGame() then return end

  State.OrdersThisUpdate = 0

  State.Hero             = Heroes.GetLocal()
  State.Player           = Players.GetLocal()
  if Entity.GetUnitName(State.Hero) ~= "npc_dota_hero_tinker" then return end
  if not State.Hero or not Entity.IsAlive(State.Hero) then
    State.FarmState                = "IDLE"
    State.CurrentFarmSpot          = nil
    State.AfterMarchCheck          = nil
    State.TargetSpotKey            = nil
    State.SpotCommitUntil          = 0
    State.CurrentSpotMarchCasts    = 0
    State.CurrentSpotMarchRequired = nil
    State.PendingMarchVerify       = nil
    return
  end

  State.HeroTeam     = Entity.GetTeamNum(State.Hero)
  State.IsChanneling = NPC.IsChannellingAbility(State.Hero)
  State.Rearm        = NPC.GetAbility(State.Hero, "tinker_rearm")
  State.March        = NPC.GetAbility(State.Hero, "tinker_march_of_the_machines")
  State.KeenTeleport = NPC.GetAbility(State.Hero, "tinker_keen_teleport")
  State.Blink        = NPC.GetItem(State.Hero, "item_blink", true)
      or NPC.GetItem(State.Hero, "item_overwhelming_blink", true)
      or NPC.GetItem(State.Hero, "item_swift_blink", true)
      or NPC.GetItem(State.Hero, "item_arcane_blink", true)

  if Config.AutoFarm:IsToggled() then
    Tinker.HandleAutoBottle()
  end
  TryCastMatrix("precast")

  if not Config.AutoFarm:IsToggled() then
    if State.FarmState ~= "IDLE" then
      State.FarmState                = "IDLE"
      State.CurrentFarmSpot          = nil
      State.AfterMarchCheck          = nil
      State.TargetSpotKey            = nil
      State.SpotCommitUntil          = 0
      State.CurrentSpotMarchCasts    = 0
      State.CurrentSpotMarchRequired = nil
      State.PendingMarchVerify       = nil
    end
    return
  end

  Tinker.HandleFarming()
end
Config.MarchControl.UseCustom:SetCallback(function()
  SyncMarchSlidersDisabled()
end, true)

return script
