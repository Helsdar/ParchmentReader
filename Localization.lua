


ParchmentReader = ParchmentReader or {}

local localeAliases = {
    enGB = "enUS",
    esMX = "esES",
}
local supportedLocales = {
    enUS = true,
    deDE = true,
    frFR = true,
    esES = true,
    ruRU = true,
}
local clientLocale = GetLocale and GetLocale() or "enUS"
clientLocale = localeAliases[clientLocale] or clientLocale
if not supportedLocales[clientLocale] then
    clientLocale = "enUS"
end
local activeLocale = clientLocale

local defaultStrings = {}
local activeStrings = {}
local registeredLocales = {}

ParchmentReader.locale = activeLocale
ParchmentReader.interfaceLanguage = "auto"
ParchmentReader.L = setmetatable({}, {
    __index = function(_, key)
        return activeStrings[key] or defaultStrings[key] or key
    end,
})

function ParchmentReader:RegisterLocale(locale, strings)
    registeredLocales[locale] = strings
    if locale == "enUS" then
        defaultStrings = strings
    end
    if locale == activeLocale then
        activeStrings = strings
    end
end

function ParchmentReader:NormalizeInterfaceLanguage(language)
    if language == "auto" or supportedLocales[language] then
        return language
    end
    return "auto"
end

function ParchmentReader:ResolveInterfaceLocale(language)
    local normalized = self:NormalizeInterfaceLanguage(language)
    if normalized == "auto" then return clientLocale end
    return normalized
end

function ParchmentReader:SetInterfaceLanguage(language)
    local normalized = self:NormalizeInterfaceLanguage(language)
    local resolved = self:ResolveInterfaceLocale(normalized)

    self.interfaceLanguage = normalized
    self.locale = resolved
    activeLocale = resolved
    activeStrings = registeredLocales[resolved] or defaultStrings
    return normalized, resolved
end

function ParchmentReader:Localize(key, ...)
    local text = self.L[key]
    if select("#", ...) == 0 then return text end
    return string.format(text, ...)
end

local function GetPluralCategory(locale, count)
    local integer = math.floor(math.abs(tonumber(count) or 0))
    if locale == "ruRU" then
        local lastTwo = integer % 100
        local lastOne = integer % 10
        if lastOne == 1 and lastTwo ~= 11 then return "ONE" end
        if lastOne >= 2 and lastOne <= 4
            and (lastTwo < 12 or lastTwo > 14)
        then
            return "FEW"
        end
        return "MANY"
    end
    if locale == "frFR" and (integer == 0 or integer == 1) then
        return "ONE"
    end
    return integer == 1 and "ONE" or "MANY"
end

function ParchmentReader:LocalizePlural(key, count)
    local category = GetPluralCategory(self.locale, count)
    local template = self.L[key .. "_" .. category]
    if template == key .. "_" .. category then
        template = self.L[key .. "_MANY"]
    end
    return string.format(template, count)
end

function ParchmentReader:PrintMessage(key, ...)
    print("|cFF33FF99" .. self.L["Parchment Reader"] .. ":|r "
        .. self:Localize(key, ...))
end
