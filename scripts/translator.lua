---@diagnostic disable: undefined-global, redundant-parameter, unspecified-field
local translator = {}

local info_tab = Menu.Create("Info Screen")
local main_section = info_tab:Create("Main")
local translator_tab = main_section:Create("Переводчик")
translator_tab:Icon("\u{f0ac}")
local settings_tab = translator_tab:Create("Настройки")
local group = settings_tab:Create("Основные")

local ui = {}

ui.global_switch = group:Switch("Включить переводчик", true)
ui.ru_to_en = group:Switch("Russian -> English", false)
ui.en_to_ru = group:Switch("Английский -> Русский", true)

ui.ru_to_en:SetCallback(function(self)
    if self:Get() then ui.en_to_ru:Set(false) end
end)

ui.en_to_ru:SetCallback(function(self)
    if self:Get() then ui.ru_to_en:Set(false) end
end)

ui.global_switch:SetCallback(function(self)
    local is_enabled = self:Get()
    ui.ru_to_en:Disabled(not is_enabled)
    ui.en_to_ru:Disabled(not is_enabled)
end, true)

local slang_dictionary = {
    "gg", "гг", "wp", "вп", "izi", "изи", "рак", "clown", "ez", "ty", "спс", "gl", "гл", "thx"
}

local function url_encode(str)
  if (str) then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w %-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

local function translate_text_api(text, target_code)
    if not text or text == "" then return end

    local url = string.format(
        "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=%s&dt=t&dt=ld&q=%s",
        target_code,
        url_encode(text)
    )

    local function on_translate_response(response)
        if response and response.code == 200 and response.response then
            local translated_text = string.match(response.response, '%[%[%["(.-)"')
            local detected_lang_code = string.match(response.response, ']],null,"(..)"')
            
            if translated_text and detected_lang_code and detected_lang_code ~= target_code then
                Chat.Print("ConsoleChat", "[Translate]: " .. translated_text)
            end
        end
    end
    HTTP.Request("GET", url, {}, on_translate_response)
end

function translator.OnPostReceivedNetMessage(msg)
    if not ui.global_switch:Get() then return end
    if msg.message_id ~= 612 then return end

    local JSON = require('assets.JSON')
    local protobuf = require('protobuf')
    if not protobuf or not JSON then return end

    local json_string = protobuf.decodeToJSONfromObject(msg.msg_object)
    if not json_string then return end
    
    local message_data = JSON:decode(json_string)
        
    local message_text = message_data.message_text
    if not message_text or message_text == "" then return end

    local lower_text = string.lower(message_text)
    for _, slang_word in ipairs(slang_dictionary) do
        if string.find(lower_text, slang_word, 1, true) then
            return 
        end
    end
    
    local has_latin = string.match(message_text, "[a-zA-Z]")
    local has_cyrillic = string.match(message_text, "[а-яА-Я]")

    local target_code = nil
    
    if ui.en_to_ru:Get() and has_latin then
        target_code = "ru"

    elseif ui.ru_to_en:Get() and has_cyrillic then
        target_code = "en"
    end
    
    if target_code then
        translate_text_api(message_text, target_code)
    end
end

return translator