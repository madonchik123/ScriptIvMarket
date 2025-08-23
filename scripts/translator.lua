local Translator = {}

-- ========== Utils ==========
Translator.Utils = {
  UrlEncode = function(str)
    if not str then return "" end
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w %-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
    str = string.gsub(str, " ", "+")
    return str
  end,
  Clamp = function(v, mn, mx) return math.max(mn, math.min(v, mx)) end,
  Css = function(tbl)
    local s = ""
    for k, v in pairs(tbl) do s = s .. k .. ": " .. v .. "; " end
    return s
  end,
  Rgba = function(r, g, b, a)
    a = Translator.Utils.Clamp(a or 255, 0, 255); return string.format("rgba(%d,%d,%d, %.2f)", r, g, b, a / 255)
  end,
  DebugLog = function(msg)
    if Translator.Config.options.debug_log:Get() then
      Chat.Print("ConsoleChat", "[TranslatorDBG] " .. tostring(msg))
    end
  end
}

-- ========== Config / Menu ==========
Translator.Config = {
  options = {},
  languages = {
    names = {},
    codes = {
      -- Broad Google Translate language set (gtx-friendly)
      ["Afrikaans"] = "af",
      ["Albanian"] = "sq",
      ["Amharic"] = "am",
      ["Arabic"] = "ar",
      ["Armenian"] = "hy",
      ["Assamese"] = "as",
      ["Aymara"] = "ay",
      ["Azerbaijani"] = "az",
      ["Bambara"] = "bm",
      ["Basque"] = "eu",
      ["Belarusian"] = "be",
      ["Bengali"] = "bn",
      ["Bhojpuri"] = "bho",
      ["Bosnian"] = "bs",
      ["Bulgarian"] = "bg",
      ["Catalan"] = "ca",
      ["Cebuano"] = "ceb",
      ["Chichewa"] = "ny",
      ["Chinese (Simplified)"] = "zh-CN",
      ["Chinese (Traditional)"] = "zh-TW",
      ["Corsican"] = "co",
      ["Croatian"] = "hr",
      ["Czech"] = "cs",
      ["Danish"] = "da",
      ["Dhivehi"] = "dv",
      ["Dogri"] = "doi",
      ["Dutch"] = "nl",
      ["English"] = "en",
      ["Esperanto"] = "eo",
      ["Estonian"] = "et",
      ["Ewe"] = "ee",
      ["Filipino"] = "fil",
      ["Finnish"] = "fi",
      ["French"] = "fr",
      ["Frisian"] = "fy",
      ["Galician"] = "gl",
      ["Georgian"] = "ka",
      ["German"] = "de",
      ["Greek"] = "el",
      ["Guarani"] = "gn",
      ["Gujarati"] = "gu",
      ["Haitian Creole"] = "ht",
      ["Hausa"] = "ha",
      ["Hawaiian"] = "haw",
      ["Hebrew"] = "he",
      ["Hindi"] = "hi",
      ["Hmong"] = "hmn",
      ["Hungarian"] = "hu",
      ["Icelandic"] = "is",
      ["Igbo"] = "ig",
      ["Ilocano"] = "ilo",
      ["Indonesian"] = "id",
      ["Irish"] = "ga",
      ["Italian"] = "it",
      ["Japanese"] = "ja",
      ["Javanese"] = "jv",
      ["Kannada"] = "kn",
      ["Kazakh"] = "kk",
      ["Khmer"] = "km",
      ["Kinyarwanda"] = "rw",
      ["Konkani"] = "gom",
      ["Korean"] = "ko",
      ["Krio"] = "kri",
      ["Kurdish (Kurmanji)"] = "ku",
      ["Kurdish (Sorani)"] = "ckb",
      ["Kyrgyz"] = "ky",
      ["Lao"] = "lo",
      ["Latin"] = "la",
      ["Latvian"] = "lv",
      ["Lingala"] = "ln",
      ["Lithuanian"] = "lt",
      ["Luganda"] = "lg",
      ["Luxembourgish"] = "lb",
      ["Macedonian"] = "mk",
      ["Maithili"] = "mai",
      ["Malagasy"] = "mg",
      ["Malay"] = "ms",
      ["Malayalam"] = "ml",
      ["Maltese"] = "mt",
      ["Maori"] = "mi",
      ["Marathi"] = "mr",
      ["Meiteilon (Manipuri)"] = "mni-Mtei",
      ["Mizo"] = "lus",
      ["Mongolian"] = "mn",
      ["Myanmar (Burmese)"] = "my",
      ["Nepali"] = "ne",
      ["Norwegian"] = "no",
      ["Odia (Oriya)"] = "or",
      ["Oromo"] = "om",
      ["Pashto"] = "ps",
      ["Persian"] = "fa",
      ["Polish"] = "pl",
      ["Portuguese"] = "pt",
      ["Punjabi"] = "pa",
      ["Quechua"] = "qu",
      ["Romanian"] = "ro",
      ["Russian"] = "ru",
      ["Samoan"] = "sm",
      ["Sanskrit"] = "sa",
      ["Scots Gaelic"] = "gd",
      ["Sepedi"] = "nso",
      ["Serbian"] = "sr",
      ["Sesotho"] = "st",
      ["Shona"] = "sn",
      ["Sindhi"] = "sd",
      ["Sinhala"] = "si",
      ["Slovak"] = "sk",
      ["Slovenian"] = "sl",
      ["Somali"] = "so",
      ["Spanish"] = "es",
      ["Sundanese"] = "su",
      ["Swahili"] = "sw",
      ["Swedish"] = "sv",
      ["Tagalog"] = "tl",
      ["Tajik"] = "tg",
      ["Tamil"] = "ta",
      ["Tatar"] = "tt",
      ["Telugu"] = "te",
      ["Thai"] = "th",
      ["Tigrinya"] = "ti",
      ["Tsonga"] = "ts",
      ["Turkish"] = "tr",
      ["Turkmen"] = "tk",
      ["Twi (Akan)"] = "ak",
      ["Ukrainian"] = "uk",
      ["Urdu"] = "ur",
      ["Uyghur"] = "ug",
      ["Uzbek"] = "uz",
      ["Vietnamese"] = "vi",
      ["Welsh"] = "cy",
      ["Xhosa"] = "xh",
      ["Yiddish"] = "yi",
      ["Yoruba"] = "yo",
      ["Zulu"] = "zu"
    },
    code_to_name = {},
    codes_list = {}
  },
  slang = {
    "gg", "wp", "izi", "ez", "ty", "gl", "thx", "omg", "lol", "afk", "brb", "wtf", "noob", "pro", "clown",
    "6666", "233", "666", "88", "gm", "nb", "sb", "nt", "hf", "gj", "tara", "laro", "wow", "nice", "lag", "dc", "respawn",
    "push", "def", "carry", "feed"
  },
  Initialize = function(self)
    -- Build name/code helpers
    self.languages.code_to_name = {}
    for name, code in pairs(self.languages.codes) do self.languages.code_to_name[code] = name end
    -- Names sorted alphabetically
    self.languages.names = {}
    for name, _ in pairs(self.languages.codes) do table.insert(self.languages.names, name) end
    table.sort(self.languages.names)
    -- Ordered code list by names
    self.languages.codes_list = {}
    for _, name in ipairs(self.languages.names) do
      local c = self.languages.codes[name]; if c then table.insert(self.languages.codes_list, c) end
    end

    local info_tab       = Menu.Create("Info Screen")
    local main_section   = info_tab:Create("Main")
    local translator_tab = main_section:Create("Translator")
    translator_tab:Icon("\u{f0ac}")

    local settings_tab               = translator_tab:Create("Settings")
    local general                    = settings_tab:Create("General")
    local incoming                   = settings_tab:Create("Incoming")
    local outgoing                   = settings_tab:Create("Outgoing")
    local visuals                    = settings_tab:Create("Visuals")

    self.options.enabled             = general:Switch("Enable Translator", true)
    -- New bind to open/close (no more Enter auto-open)
    self.options.open_bind           = general:Bind("Open/Close Translator", Enum.ButtonCode.KEY_F8, "\u{f0ac}")
    self.options.live_preview        = general:Switch("Live Translate Preview (while typing)", true)
    self.options.debounce_ms         = general:Slider("Typing Debounce (ms)", 80, 500, 220)
    self.options.debug_log           = general:Switch("Debug Logging", false)

    self.options.incoming_target     = incoming:Combo("Incoming -> Target", self.languages.names, 96)
    self.options.outgoing_target     = outgoing:Combo("Outgoing -> Target", self.languages.names, 27)
    self.options.auto_skip_same_lang = outgoing:Switch("Skip translation if text already in target language", true)
    self.options.smart_channel       = outgoing:Switch("Smart channel detection (gg/glhf -> ALL)", true)

    self.options.show_toolbar        = visuals:Switch("Show floating toolbar (controls)", true)
    self.options.render_opacity      = visuals:Slider("Overlay Opacity", 80, 255, 190)
    -- Position controls (move overlay)
    self.options.pos_x               = visuals:Slider("Position X (px)", -800, 800, 0)
    self.options.pos_y               = visuals:Slider("Position Y (bottom margin px)", 0, 800, 230)
    self.options.max_input_len       = visuals:Slider("Max Input Length", 20, 240, 140)
  end,
  GetLangCodeFromCombo = function(self, combo)
    local idx = combo:Get()
    local name = self.languages.names[idx + 1]
    return self.languages.codes[name] or "en"
  end
}

-- ========== Translate Core ==========
Translator.Translate = {
  json_lib = require('assets.JSON'),
  cache = {},
  ParseApiResponse = function(self, raw)
    local ok, data = pcall(function() return self.json_lib:decode(raw) end)
    if not ok or type(data) ~= "table" then return nil, nil end
    local sentences, detected = data[1], data[3]
    local parts = {}
    if type(sentences) == "table" then
      for _, seg in ipairs(sentences) do
        if type(seg) == "table" and type(seg[1]) == "string" then table.insert(parts, seg[1]) end
      end
    end
    local out = table.concat(parts, "")
    return (out ~= "" and out or nil), detected
  end,
  Request = function(self, text, target_code, cb)
    if not text or text == "" then
      if cb then cb(nil, nil) end; return
    end
    local key = target_code .. "|" .. text
    local c = self.cache[key]
    if c then
      if cb then cb(c.translated, c.detected) end; return
    end
    local url = string.format(
      "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=%s&dt=t&dt=ld&q=%s",
      target_code, Translator.Utils.UrlEncode(text)
    )
    HTTP.Request("GET", url, {}, function(resp)
      local translated, detected = nil, nil
      if resp and resp.code == 200 and resp.response then translated, detected = self:ParseApiResponse(resp.response) end
      self.cache[key] = { translated = translated or text, detected = detected or "auto" }
      if cb then cb(self.cache[key].translated, self.cache[key].detected) end
    end)
  end
}

-- ========== UI / Panorama ==========
Translator.UI = {
  panels = {
    root = nil,
    input = nil,
    bar = nil,
    team_btn = nil,
    all_btn = nil,
    lang_btn = nil,
    lang_lbl = nil,
    send_plain_btn = nil,
    send_trans_btn = nil,
    preview = nil,
    hint = nil,
    lang_menu = nil,
    lang_search = nil
  },
  state = {
    is_visible = false,
    is_initialized = false,
    current_text = "",
    channel = "team",
    target_code = "en",
    detected_source = "auto",
    live_preview_text = "",
    last_input_time = 0.0,
    next_request_time = 0.0,
    last_opacity = -1,
    last_pos_x = nil,
    last_pos_y = nil
  },

  GetHUD = function()
    return Panorama.GetPanelByName("HUDElements", false)
        or Panorama.GetPanelByName("Hud", false)
        or Panorama.GetPanelByPath({ "HUDElements" }, false)
  end,

  Initialize = function(self)
    if self.state.is_initialized then return true end
    local hud = self.GetHUD()
    if not hud or not hud:IsValid() then
      Translator.Utils.DebugLog("HUD not ready for UI init"); return false
    end

    local C = Translator.Utils.Css
    local R = Translator.Utils.Rgba

    -- Root container (position controlled by settings)
    local root = Panorama.CreatePanel("Panel", "TranslatorRoot", hud, nil, C({
      ["horizontal-align"] = "center",
      ["vertical-align"] = "bottom",
      ["margin-bottom"] = tostring(Translator.Config.options.pos_y:Get() or 230) .. "px",
      ["margin-left"] = tostring(Translator.Config.options.pos_x:Get() or 0) .. "px",
      ["z-index"] = "3000",
      ["flow-children"] = "down"
    }))
    root:SetVisible(false)

    -- Box
    local box = Panorama.CreatePanel("Panel", "TranslatorBox", root, nil, C({
      ["flow-children"] = "down",
      ["background-color"] = R(15, 18, 26, Translator.Config.options.render_opacity:Get() or 190),
      ["border"] = "1px solid #4ac8ff88",
      ["border-radius"] = "10px",
      ["box-shadow"] = "0 12px 28px #000000aa, inset 0 0 28px #0ab1ff22",
      ["padding"] = "10px",
      ["margin-bottom"] = "0px"
    }))

    -- Title
    local title = Panorama.CreatePanel("Panel", "TranslatorTitle", box, nil, C({
      ["flow-children"] = "right", ["margin-bottom"] = "6px"
    }))
    local icon = Panorama.CreatePanel("Label", "TranslatorIcon", title, nil, C({
      ["font-size"] = "16px", ["color"] = "#77d6ff", ["margin-right"] = "6px"
    }))
    icon:SetText("🌐")
    local heading = Panorama.CreatePanel("Label", "TranslatorHeading", title, nil, C({
      ["font-size"] = "16px", ["color"] = "#bfe9ff", ["text-shadow"] = "0px 0px 6px #0ab1ff77"
    }))
    heading:SetText("Translator")

    -- Input row
    local row = Panorama.CreatePanel("Panel", "TranslatorRow", box, nil, C({ ["flow-children"] = "right" }))

    local input = Panorama.CreatePanel("TextEntry", "TranslatorInput", row, nil, C({
      ["width"] = "560px",
      ["height"] = "36px",
      ["margin-right"] = "10px",
      ["font-size"] = "18px",
      ["border-radius"] = "6px",
      ["padding"] = "0px 10px",
      ["border"] = "1px solid #2e5e83aa",
      ["background-color"] = "#0e141d",
      ["color"] = "#d9f2ff"
    }))

    -- Toolbar
    local bar = Panorama.CreatePanel("Panel", "TranslatorBar", row, nil, C({
      ["flow-children"] = "right", ["height"] = "36px"
    }))

    -- Channel segmented
    local seg = Panorama.CreatePanel("Panel", "ChannelSeg", bar, nil, C({
      ["flow-children"] = "right",
      ["height"] = "36px",
      ["margin-right"] = "8px",
      ["background-color"] = "#111722",
      ["border"] = "1px solid #35597a88",
      ["border-radius"] = "6px"
    }))
    local function mkSeg(id, text)
      local b = Panorama.CreatePanel("Button", id, seg, nil, C({
        ["height"] = "34px",
        ["min-width"] = "52px",
        ["padding"] = "0 10px",
        ["margin"] = "1px",
        ["border-radius"] = "5px",
        ["background-color"] = "#0f1520",
        ["border"] = "1px solid #2f557488"
      }))
      local l = Panorama.CreatePanel("Label", id .. "_lbl", b, nil, C({
        ["font-size"] = "13px",
        ["color"] = "#bfe9ff",
        ["vertical-align"] = "middle",
        ["horizontal-align"] = "center"
      }))
      l:SetText(text)
      return b, l
    end
    local team_btn, _ = mkSeg("XTeamBtn", "TEAM")
    local all_btn, _  = mkSeg("XAllBtn", "ALL")

    -- Language button
    local lang_btn    = Panorama.CreatePanel("Button", "XLangBtn", bar, nil, C({
      ["height"] = "36px",
      ["min-width"] = "56px",
      ["margin-right"] = "6px",
      ["background-color"] = "#101826",
      ["border"] = "1px solid #4ac8ff88",
      ["border-radius"] = "6px",
      ["padding"] = "0 10px"
    }))
    local lang_lbl    = Panorama.CreatePanel("Label", "XLangLbl", lang_btn, nil, C({
      ["font-size"] = "13px", ["color"] = "#bfe9ff", ["vertical-align"] = "middle", ["horizontal-align"] = "center"
    }))
    lang_lbl:SetText("EN ▾")

    -- Send plain (hidden; Enter handles plain send)
    local send_plain_btn = Panorama.CreatePanel("Button", "XSendPlainBtn", bar, nil, C({
      ["height"] = "36px",
      ["min-width"] = "46px",
      ["margin-right"] = "6px",
      ["background-color"] = "#0f7c3f22",
      ["border"] = "1px solid #23d27c66",
      ["border-radius"] = "6px",
      ["padding"] = "0 10px"
    }))
    local sp_lbl = Panorama.CreatePanel("Label", "XSendPlainLbl", send_plain_btn, nil, C({
      ["font-size"] = "13px", ["color"] = "#aaf0cf", ["vertical-align"] = "middle", ["horizontal-align"] = "center"
    }))
    sp_lbl:SetText("Send")
    send_plain_btn:SetVisible(false)

    -- Send translated
    local send_trans_btn = Panorama.CreatePanel("Button", "XSendTransBtn", bar, nil, C({
      ["height"] = "36px",
      ["min-width"] = "46px",
      ["background-color"] = "#0b386422",
      ["border"] = "1px solid #3aa0ff66",
      ["border-radius"] = "6px",
      ["padding"] = "0 10px"
    }))
    local st_lbl = Panorama.CreatePanel("Label", "XSendTransLbl", send_trans_btn, nil, C({
      ["font-size"] = "13px", ["color"] = "#9bd9ff", ["vertical-align"] = "middle", ["horizontal-align"] = "center"
    }))
    st_lbl:SetText("Send Translated")

    -- Preview + hint
    local preview = Panorama.CreatePanel("Label", "TranslatorPreview", box, nil, C({
      ["margin-top"] = "6px", ["font-size"] = "14px", ["color"] = "#ffd68a"
    }))
    preview:SetText("")
    local hint = Panorama.CreatePanel("Label", "TranslatorHint", box, nil, C({
      ["margin-top"] = "2px", ["font-size"] = "12px", ["opacity"] = "0.9", ["color"] = "#a0cbe6"
    }))
    hint:SetText("Enter: send original | 🌐: translate & send | Esc: cancel | /lang es, /all, /team")

    -- Language dropdown
    local lang_menu = Panorama.CreatePanel("Panel", "XLangMenu", box, nil, C({
      ["flow-children"] = "down",
      ["margin-top"] = "6px",
      ["background-color"] = "#0a0f18",
      ["border"] = "1px solid #2f5574aa",
      ["border-radius"] = "8px",
      ["box-shadow"] = "0 6px 18px #000000aa",
      ["padding"] = "6px",
      -- New: make it wide so we can fit multiple columns
      ["width"] = "960px",
    }))
    lang_menu:SetVisible(false)

    local search = Panorama.CreatePanel("TextEntry", "XLangSearch", lang_menu, nil, C({
      ["height"] = "28px",
      ["margin-bottom"] = "6px",
      ["font-size"] = "13px",
      ["border-radius"] = "6px",
      ["padding"] = "0 8px",
      ["border"] = "1px solid #2e5e83aa",
      ["background-color"] = "#0e141d",
      ["color"] = "#d9f2ff"
    }))

    -- New: we’ll pack columns ourselves, so no max-height or overflow here
    local list = Panorama.CreatePanel("Panel", "XLangList", lang_menu, nil, C({
      ["flow-children"] = "right",
      ["width"] = "960px",
      ["horizontal-align"] = "left"
    }))

    -- Save references
    self.panels.root = root
    self.panels.input = input
    self.panels.bar = bar
    self.panels.team_btn = team_btn
    self.panels.all_btn = all_btn
    self.panels.lang_btn = lang_btn
    self.panels.lang_lbl = lang_lbl
    self.panels.send_plain_btn = send_plain_btn
    self.panels.send_trans_btn = send_trans_btn
    self.panels.preview = preview
    self.panels.hint = hint
    self.panels.lang_menu = lang_menu
    self.panels.lang_search = search

    self.state.is_initialized = true
    return true
  end,

  Open = function(self, default_channel)
    if not self:Initialize() then
      Chat.Print("ConsoleChat", "[Translator] UI not ready yet. Try again in a second.")
      return
    end
    self.state.is_visible = true
    self.state.current_text = ""
    self.state.channel = default_channel or "team"
    self.state.target_code = Translator.Config:GetLangCodeFromCombo(Translator.Config.options.outgoing_target)
    self.state.detected_source = "auto"
    self.state.live_preview_text = ""
    self.state.last_input_time = GameRules.GetGameTime()

    self.panels.root:SetVisible(true)
    self:BindJsEvents()
    self:SetInputText("")
    self:FocusInput()
    self:UpdateToolbar()
    self:UpdateOpacity()
    self:UpdatePosition(true)

    Translator.Utils.DebugLog("Overlay opened")
  end,

  Close = function(self)
    if not self.state.is_initialized then return end
    self.state.is_visible = false
    self.state.current_text = ""
    self.state.live_preview_text = ""
    if self.panels.root and self.panels.root:IsValid() then
      self.panels.root:SetVisible(false)
    end
    Translator.Utils.DebugLog("Overlay closed")
  end,

  BindJsEvents = function(self)
    if not self.panels.root or not self.panels.root:IsValid() then return end

    local langs = {}
    for _, code in ipairs(Translator.Config.languages.codes_list) do
      local name = Translator.Config.languages.code_to_name[code] or code
      table.insert(langs, { code = code, name = name })
    end
    local function esc(s) return (s or ""):gsub("\\", "\\\\"):gsub("\"", "\\\"") end
    local js_lang_array = "["
    for i, ln in ipairs(langs) do
      js_lang_array = js_lang_array ..
          string.format("{\"code\":\"%s\",\"name\":\"%s\"}%s", esc(ln.code), esc(ln.name), i < #langs and "," or "")
    end
    js_lang_array = js_lang_array .. "]"

    local js = ([[
      (function(){
        const ctx = $.GetContextPanel();
        const input = ctx.FindChildTraverse("TranslatorInput");
        const team = ctx.FindChildTraverse("XTeamBtn");
        const allb = ctx.FindChildTraverse("XAllBtn");
        const langBtn = ctx.FindChildTraverse("XLangBtn");
        const langLbl = ctx.FindChildTraverse("XLangLbl");
        const sendPlain = ctx.FindChildTraverse("XSendPlainBtn");
        const sendTrans = ctx.FindChildTraverse("XSendTransBtn");
        const menu = ctx.FindChildTraverse("XLangMenu");
        const search = ctx.FindChildTraverse("XLangSearch");
        const list = ctx.FindChildTraverse("XLangList");
        if (!input) return;

        const langs = %s;

        // Utility
        const submit = (mode) => {
          input.SetAttributeString("submitted", "1");
          input.SetAttributeString("submitted_text", input.text || "");
          input.SetAttributeString("submit_mode", mode || "plain");
        };
        const updateLive = () => {
          input.SetAttributeString("live_text", input.text || "");
          input.SetAttributeString("live_dirty", "1");
        };
        const command = (cmd) => input.SetAttributeString("command", cmd);
        const selectLang = (code) => { input.SetAttributeString("lang_select", code); closeMenu(); };

        // Build menu items
        function rebuildList(filter) {
          list.RemoveAndDeleteChildren();
          const f = (filter || "").toLowerCase();

          // Filter
          const filtered = langs.filter(l => {
            const n = l.name.toLowerCase(), c = l.code.toLowerCase();
            return !f || n.indexOf(f) !== -1 || c.indexOf(f) !== -1;
          });

          // Layout constants (tweak to taste)
          const MENU_W = 960;   // match the Lua width above
          const ITEM_W = 220;   // width of each language button
          const GAP = 6;
          const ROW_H = 26;     // matches row.style.height below
          const MAX_COL_H = 520; // cap menu height; number of rows per column ~ MAX_COL_H / (ROW_H + margins)
          const MAX_ROWS = Math.max(1, Math.floor(MAX_COL_H / 28)); // ~28 incl. margins
          const maxColsByWidth = Math.max(1, Math.floor((MENU_W + GAP) / (ITEM_W + GAP)));

          // Calculate columns to keep height <= MAX_COL_H and width <= MENU_W
          let cols = Math.max(1, Math.min(maxColsByWidth, Math.ceil(filtered.length / MAX_ROWS)));
          let rowsPerCol = Math.max(1, Math.ceil(filtered.length / cols));

          // Apply sizes
          menu.style.width = MENU_W + "px";
          list.style.width = MENU_W + "px";
          list.style.flowChildren = "right";

          // Create columns
          const columns = [];
          for (let i = 0; i < cols; i++) {
            const col = $.CreatePanel("Panel", list, "LangCol_" + i, {});
            col.style.flowChildren = "down";
            col.style.width = ITEM_W + "px";
            col.style.marginRight = (i < cols - 1 ? GAP : 0) + "px";
            columns.push(col);
          }

          // Add items to columns
          filtered.forEach((l, i) => {
            const colIx = Math.min(Math.floor(i / rowsPerCol), columns.length - 1);
            const parent = columns[colIx];

            const row = $.CreatePanel("Button", parent, "LangItem_" + l.code, {});
            row.AddClass("lang_row");
            row.style.margin = "1px 0px 1px 0px";
            row.style.border = "1px solid #2e5e8377";
            row.style.borderRadius = "4px";
            row.style.backgroundColor = "#0e141d";
            row.style.height = "26px";
            row.style.width = "100%%";
            row.style.overflow = "squish";

            const label = $.CreatePanel("Label", row, "", {});
            label.text = l.name + "  (" + l.code.toUpperCase() + ")";
            label.style.color = "#bfe9ff";
            label.style.fontSize = "13px";
            label.style.margin = "0px 6px";
            label.style.textOverflow = "shrink";

            row.SetPanelEvent("onactivate", () => selectLang(l.code));
          });

          if (filtered.length === 0) {
            const empty = $.CreatePanel("Label", list, "LangEmpty", {});
            empty.text = "No matches";
            empty.style.color = "#9aa7b5";
            empty.style.margin = "4px 0";
          }
        }

        function openMenu() {
          rebuildList(search.text||"");
          menu.visible = true;
          search.SetFocus();
          input.SetAttributeString("menu_open","1");
        }
        function closeMenu() {
          menu.visible = false;
          input.SetAttributeString("menu_open","");
          input.SetFocus();
        }
        function toggleMenu() { if(menu.visible){closeMenu();} else {openMenu();} }

        // Input setup
        input.maxchars = %d;
        input.text = "";
        input.SetFocus();
        input.SetPanelEvent("ontextentrychange", updateLive);
        input.SetPanelEvent("oninputsubmit", ()=>submit("plain"));
        input.SetPanelEvent("onkeypress", (code) => {
          if (code === 13) { submit("plain"); } // Enter sends original (plain)
        });
        input.SetPanelEvent("oncancel", ()=>input.SetAttributeString("cancel","1"));

        // Buttons/events
        team?.SetPanelEvent("onactivate", ()=>command("set_channel_team"));
        allb?.SetPanelEvent("onactivate", ()=>command("set_channel_all"));
        langBtn?.SetPanelEvent("onactivate", ()=>toggleMenu());
        sendPlain?.SetPanelEvent("onactivate", ()=>submit("plain"));
        sendTrans?.SetPanelEvent("onactivate", ()=>submit("translate"));
        search?.SetPanelEvent("ontextentrychange", ()=>rebuildList(search.text||""));

        // Direct calls for Lua
        ctx._translator_focus = ()=>input.SetFocus();
        ctx._translator_set_text = (s)=>{ input.text = s || ""; updateLive(); };

        // Cleanup attrs
        ["submitted","submitted_text","submit_mode","live_text","live_dirty","command","cancel","lang_select","menu_open"].forEach(k=>input.SetAttributeString(k,""));

        for(let i=1;i<=5;i++){ $.Schedule(0.05*i, ()=>{ if(input && input.IsValid()) input.SetFocus(); }); }
      })();
    ]]):format(js_lang_array, Translator.Config.options.max_input_len:Get())

    Engine.RunScript(js, self.panels.root)
  end,

  PollInputBridge = function(self)
    if not self.state.is_visible or not self.panels.input or not self.panels.input:IsValid() then return end

    -- Commands
    local cmd = self.panels.input:GetAttribute("command", "")
    if cmd ~= "" then
      self.panels.input:SetAttribute("command", "")
      if cmd == "set_channel_team" then
        self.state.channel = "team"
      elseif cmd == "set_channel_all" then
        self.state.channel = "all"
      end
      self:UpdateToolbar()
    end

    -- Language selected
    local sel = self.panels.input:GetAttribute("lang_select", "")
    if sel ~= "" then
      self.panels.input:SetAttribute("lang_select", "")
      self.state.target_code = sel
      self:UpdateToolbar()
      self.state.last_input_time = GameRules.GetGameTime()
    end

    -- Live text
    if self.panels.input:GetAttribute("live_dirty", "") == "1" then
      self.panels.input:SetAttribute("live_dirty", "")
      self.state.current_text = self.panels.input:GetAttribute("live_text", self.state.current_text)
      self.state.last_input_time = GameRules.GetGameTime()
    end

    -- Submit
    if self.panels.input:GetAttribute("submitted", "") == "1" then
      local mode = self.panels.input:GetAttribute("submit_mode", "plain")
      self.panels.input:SetAttribute("submitted", "")
      local txt = self.panels.input:GetAttribute("submitted_text", self.state.current_text)
      self.state.current_text = txt
      self:SendMessage(mode)
    end

    -- Cancel
    if self.panels.input:GetAttribute("cancel", "") == "1" then
      self.panels.input:SetAttribute("cancel", "")
      self:Close()
    end

    self:UpdateOpacity()
    self:UpdatePosition(false)
  end,

  ParseSlashCommand = function(self, text)
    if text:sub(1, 1) ~= "/" then return text, nil end
    local parts = {}
    for t in text:gmatch("%S+") do table.insert(parts, t) end
    local cmd = string.lower(parts[1] or "")
    local arg = string.lower(parts[2] or "")
    if cmd == "/lang" and arg ~= "" then
      for name, code in pairs(Translator.Config.languages.codes) do
        if arg == code:lower() or arg == string.lower(name) then return "", { type = "lang", value = code } end
      end
    elseif cmd == "/all" then
      return "", { type = "channel", value = "all" }
    elseif cmd == "/team" then
      return "", { type = "channel", value = "team" }
    elseif cmd == "/swap" then
      -- Kept for power users; even though button is removed
      return "", { type = "swap" }
    end
    return text, nil
  end,

  ApplySlashCommand = function(self, info)
    if info.type == "lang" then
      self.state.target_code = info.value
    elseif info.type == "channel" then
      self.state.channel = info.value
    elseif info.type == "swap" then
      local d = self.state.detected_source
      if d and d ~= "auto" and Translator.Config.languages.code_to_name[d] then
        self.state.target_code, self.state.detected_source = d, self.state.target_code
      end
    end
  end,

  SendMessage = function(self, mode)
    mode = mode or "plain"
    local text = (self.state.current_text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then
      self:Close(); return
    end

    local clean, cmd = self:ParseSlashCommand(text)
    if cmd then
      self:ApplySlashCommand(cmd)
      self:SetInputText("")
      self:UpdateToolbar()
      return
    end

    local channel = self.state.channel
    if Translator.Config.options.smart_channel:Get() then
      local lt = clean:lower()
      if lt:find("gg", 1, true) or lt:find("gl", 1, true) or lt:find("hf", 1, true) or lt:find("wp", 1, true) then
        channel = "all"
      end
    end

    local function do_send(msg)
      if channel == "all" then
        Engine.ExecuteCommand('say "' .. msg .. '"')
      else
        Engine.ExecuteCommand('say_team "' .. msg .. '"')
      end
      self:Close()
    end

    if mode == "plain" then
      do_send(clean)
    else
      Translator.Translate:Request(clean, self.state.target_code, function(out, detected)
        self.state.detected_source = detected or "auto"
        local final = out or clean
        if Translator.Config.options.auto_skip_same_lang:Get() and detected == self.state.target_code then
          final = clean
        end
        Translator.Utils.DebugLog(string.format("Translated send (%s): %s", tostring(detected), final))
        do_send(final)
      end)
    end
  end,

  UpdateToolbar = function(self)
    if not self.state.is_initialized then return end
    local code = self.state.target_code or "en"
    local name = Translator.Config.languages.code_to_name[code] or code
    local channel = self.state.channel

    if self.panels.lang_lbl then self.panels.lang_lbl:SetText((name:sub(1, 3):upper()) .. " ▾") end

    -- Highlight segmented control
    if self.panels.team_btn then self.panels.team_btn:SetStyle(self:SegStyle(channel == "team")) end
    if self.panels.all_btn then self.panels.all_btn:SetStyle(self:SegStyle(channel == "all")) end

    if self.panels.hint then
      self.panels.hint:SetText(string.format(
        "Enter: send original | 🌐: translate & send | Channel: %s | Target: %s (%s) | /lang es, /all, /team",
        channel:upper(), name, code
      ))
    end

    local show = Translator.Config.options.show_toolbar:Get()
    self.panels.bar:SetVisible(true)
    self.panels.team_btn:SetVisible(show)
    self.panels.all_btn:SetVisible(show)
    self.panels.lang_btn:SetVisible(show)
    self.panels.send_plain_btn:SetVisible(false)
    self.panels.send_trans_btn:SetVisible(show)
  end,

  SegStyle = function(self, active)
    local C = Translator.Utils.Css
    if active then
      return C({
        ["height"] = "34px",
        ["min-width"] = "52px",
        ["padding"] = "0 10px",
        ["margin"] = "1px",
        ["border-radius"] = "5px",
        ["background-color"] = "#143a57",
        ["border"] = "1px solid #4ac8ffbb"
      })
    else
      return C({
        ["height"] = "34px",
        ["min-width"] = "52px",
        ["padding"] = "0 10px",
        ["margin"] = "1px",
        ["border-radius"] = "5px",
        ["background-color"] = "#0f1520",
        ["border"] = "1px solid #2f557488"
      })
    end
  end,

  UpdatePreview = function(self)
    if not self.state.is_initialized then return end
    if Translator.Config.options.live_preview:Get() and self.state.live_preview_text ~= "" then
      self.panels.preview:SetText("Preview: " .. self.state.live_preview_text)
    else
      self.panels.preview:SetText("")
    end
  end,

  UpdateOpacity = function(self)
    if not self.state.is_initialized then return end
    local op = Translator.Config.options.render_opacity:Get() or 190
    if op ~= self.state.last_opacity then
      self.state.last_opacity = op
      local box = self.panels.root:FindChild("TranslatorBox")
      if box then box:SetStyle("background-color: " .. Translator.Utils.Rgba(15, 18, 26, op) .. ";") end
    end
  end,

  UpdatePosition = function(self, force)
    if not self.state.is_initialized then return end
    local px = Translator.Config.options.pos_x:Get() or 0
    local py = Translator.Config.options.pos_y:Get() or 230
    if force or px ~= self.state.last_pos_x or py ~= self.state.last_pos_y then
      self.state.last_pos_x, self.state.last_pos_y = px, py
      if self.panels.root and self.panels.root:IsValid() then
        self.panels.root:SetStyle(string.format("margin-left: %dpx; margin-bottom: %dpx;", px, py))
      end
    end
  end,

  TickLivePreview = function(self)
    if not self.state.is_visible or not Translator.Config.options.live_preview:Get() then return end
    local now = GameRules.GetGameTime()
    local debounce = (Translator.Config.options.debounce_ms:Get() or 220) / 1000.0
    if now > self.state.last_input_time + debounce and now > self.state.next_request_time then
      self.state.next_request_time = now + 0.1
      local text, _ = self:ParseSlashCommand(self.state.current_text)
      if text == "" then
        self.state.live_preview_text = ""
        self:UpdatePreview()
        return
      end
      Translator.Translate:Request(text, self.state.target_code, function(out, detected)
        if self.state.is_visible then
          self.state.live_preview_text = out or ""
          self.state.detected_source = detected or "auto"
          self:UpdatePreview()
          self:UpdateToolbar()
        end
      end)
    end
  end,

  RunJs = function(self, js)
    if self.panels.root and self.panels.root:IsValid() then
      Engine.RunScript(js, self.panels.root)
    end
  end,

  FocusInput = function(self)
    self:RunJs(
      "$.Schedule(0.0, function(){ if($.GetContextPanel()._translator_focus) $.GetContextPanel()._translator_focus(); });")
  end,
  SetInputText = function(self, text)
    local safe = (text or ""):gsub("\\", "\\\\"):gsub("'", "\\'")
    self:RunJs(
      "$.Schedule(0.0, function(){ if($.GetContextPanel()._translator_set_text) $.GetContextPanel()._translator_set_text('" ..
      safe .. "'); });")
  end
}

-- ========== Events ==========
Translator.Events = {
  OnDraw = function()
    if not Translator.Config.options.enabled:Get() then
      if Translator.UI.state.is_visible then Translator.UI:Close() end
      return
    end

    -- Open/Close with bind (toggle). Does not touch Enter, so game chat stays normal.
    local b = Translator.Config.options.open_bind
    if b and b:IsPressed() then
      if Translator.UI.state.is_visible then Translator.UI:Close() else Translator.UI:Open("team") end
    end

    Translator.UI:PollInputBridge()
    Translator.UI:TickLivePreview()
  end,

  OnKeyEvent = function(e)
    if not Translator.Config.options.enabled:Get() then return true end

    -- We no longer auto-open on Enter, and we don't consume Enter at all.
    if Translator.UI.state.is_visible and e.event == Enum.EKeyEvent.EKeyEvent_KEY_DOWN then
      if e.key == Enum.ButtonCode.KEY_ESCAPE then
        Translator.UI:Close()
        return false
      end
    end

    return true
  end,

  OnPostReceivedNetMessage = function(msg)
    if not Translator.Config.options.enabled:Get() then return end
    if msg.message_id ~= 612 then return end
    local pb = require('protobuf')
    local JSONLocal = require('assets.JSON')
    if not pb or not JSONLocal then return end
    local json_string = pb.decodeToJSONfromObject(msg.msg_object)
    if not json_string then return end
    local ok, data = pcall(function() return JSONLocal:decode(json_string) end)
    if not ok or type(data) ~= "table" then return end
    local text = data.message_text
    if not text or text == "" then return end

    -- slang skip
    local lt = text:lower()
    for _, w in ipairs(Translator.Config.slang) do if lt:find(w, 1, true) then return end end

    local target = Translator.Config:GetLangCodeFromCombo(Translator.Config.options.incoming_target)
    Translator.Translate:Request(text, target, function(out, _)
      if out and out ~= "" and out ~= text then
        Chat.Print("ConsoleChat", "[Translate] " .. out)
      end
    end)
  end
}

-- ========== Init ==========
Translator.Config:Initialize()
return Translator.Events
