

ParchmentReader = ParchmentReader or {}

local localeAliases = {
    enGB = "enUS",
    esMX = "esES",
}
local activeLocale = GetLocale and GetLocale() or "enUS"
activeLocale = localeAliases[activeLocale] or activeLocale

local defaultStrings = {}
local activeStrings = {}

ParchmentReader.locale = activeLocale
ParchmentReader.L = setmetatable({}, {
    __index = function(_, key)
        return activeStrings[key] or defaultStrings[key] or key
    end,
})

function ParchmentReader:RegisterLocale(locale, strings)
    if locale == "enUS" then
        defaultStrings = strings
    end
    if locale == activeLocale then
        activeStrings = strings
    end
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
