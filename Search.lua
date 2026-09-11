


ParchmentReader = ParchmentReader or {}

local SEARCH_CASE_FOLD = {
    ["А"] = "а", ["Б"] = "б", ["В"] = "в", ["Г"] = "г",
    ["Д"] = "д", ["Е"] = "е", ["Ё"] = "ё", ["Ж"] = "ж",
    ["З"] = "з", ["И"] = "и", ["Й"] = "й", ["К"] = "к",
    ["Л"] = "л", ["М"] = "м", ["Н"] = "н", ["О"] = "о",
    ["П"] = "п", ["Р"] = "р", ["С"] = "с", ["Т"] = "т",
    ["У"] = "у", ["Ф"] = "ф", ["Х"] = "х", ["Ц"] = "ц",
    ["Ч"] = "ч", ["Ш"] = "ш", ["Щ"] = "щ", ["Ъ"] = "ъ",
    ["Ы"] = "ы", ["Ь"] = "ь", ["Э"] = "э", ["Ю"] = "ю",
    ["Я"] = "я", ["À"] = "à", ["Á"] = "á", ["Â"] = "â",
    ["Ã"] = "ã", ["Ä"] = "ä", ["Æ"] = "æ", ["Ç"] = "ç",
    ["É"] = "é", ["È"] = "è", ["Ê"] = "ê", ["Ë"] = "ë",
    ["Í"] = "í", ["Î"] = "î", ["Ï"] = "ï", ["Ñ"] = "ñ",
    ["Ó"] = "ó", ["Ô"] = "ô", ["Õ"] = "õ", ["Ö"] = "ö",
    ["Œ"] = "œ", ["Ú"] = "ú", ["Ù"] = "ù", ["Û"] = "û",
    ["Ü"] = "ü", ["Ÿ"] = "ÿ", ["ẞ"] = "ß",
}

local searchIndex = nil

local function SearchString(value)
    if type(value) == "string" then return value end
    return ""
end

local function TrimSearchText(value)
    local trimmed = string.gsub(value, "^%s+", "")
    return (string.gsub(trimmed, "%s+$", ""))
end

function ParchmentReader:NormalizeSearchText(value)
    local normalized = string.lower(SearchString(value))
    normalized = string.gsub(
        normalized,
        "([\194-\223][\128-\191])",
        SEARCH_CASE_FOLD)
    normalized = string.gsub(
        normalized,
        "([\224-\239][\128-\191][\128-\191])",
        SEARCH_CASE_FOLD)
    return TrimSearchText(normalized)
end

function ParchmentReader:GetSearchTerms(value)
    local terms = {}
    for term in string.gmatch(self:NormalizeSearchText(value), "%S+") do
        terms[#terms + 1] = term
    end
    return terms
end

function ParchmentReader:GetSearchPhrase(value)
    return (string.gsub(self:NormalizeSearchText(value), "%s+", " "))
end

local function NextSearchUnit(text, startIndex)
    local leadByte = string.byte(text, startIndex)
    local length = 1
    if leadByte and leadByte >= 240 and leadByte <= 244 then
        length = 4
    elseif leadByte and leadByte >= 224 and leadByte <= 239 then
        length = 3
    elseif leadByte and leadByte >= 194 and leadByte <= 223 then
        length = 2
    end
    for byteIndex = startIndex + 1, startIndex + length - 1 do
        local continuation = string.byte(text, byteIndex)
        if not continuation or continuation < 128 or continuation > 191 then
            length = 1
            break
        end
    end
    local endIndex = math.min(#text, startIndex + length - 1)
    return string.sub(text, startIndex, endIndex), endIndex
end

local function FoldSearchUnit(unit)
    return SEARCH_CASE_FOLD[unit] or string.lower(unit)
end

function ParchmentReader:GetContentPhraseMatches(content, phrase)
    local source = SearchString(content)
    local normalizedPhrase = self:GetSearchPhrase(phrase)
    if source == "" or normalizedPhrase == "" then return {} end

    local normalizedContent = self:GetSearchPhrase(source)
    local matches = {}
    local searchAt = 1
    while searchAt <= #normalizedContent do
        local matchStart, matchEnd = string.find(
            normalizedContent, normalizedPhrase, searchAt, true)
        if not matchStart then break end
        matches[#matches + 1] = {
            normalizedStart = matchStart,
            normalizedEnd = matchEnd,
        }
        searchAt = matchStart + 1
    end
    if #matches == 0 then return matches end

    local normalizedOffset = 0
    local startMatchIndex = 1
    local endMatchIndex = 1
    local function MapSegment(outputLength, sourceStart, sourceEnd)
        local normalizedStart = normalizedOffset + 1
        local normalizedEnd = normalizedOffset + outputLength
        while startMatchIndex <= #matches
            and matches[startMatchIndex].normalizedStart == normalizedStart
        do
            matches[startMatchIndex].startOffset = sourceStart
            startMatchIndex = startMatchIndex + 1
        end
        while endMatchIndex <= #matches
            and matches[endMatchIndex].normalizedEnd == normalizedEnd
        do
            matches[endMatchIndex].endOffset = sourceEnd
            endMatchIndex = endMatchIndex + 1
        end
        normalizedOffset = normalizedEnd
    end

    local sourceIndex = 1
    local hasOutput = false
    local pendingWhitespaceStart = nil
    local pendingWhitespaceEnd = nil
    while sourceIndex <= #source do
        local unit, unitEnd = NextSearchUnit(source, sourceIndex)
        if string.match(unit, "^%s$") then
            if hasOutput then
                pendingWhitespaceStart = pendingWhitespaceStart or sourceIndex
                pendingWhitespaceEnd = unitEnd
            end
        else
            if pendingWhitespaceStart then
                MapSegment(
                    1,
                    pendingWhitespaceStart - 1,
                    pendingWhitespaceEnd)
                pendingWhitespaceStart = nil
                pendingWhitespaceEnd = nil
            end
            local folded = FoldSearchUnit(unit)
            MapSegment(#folded, sourceIndex - 1, unitEnd)
            hasOutput = true
        end
        sourceIndex = unitEnd + 1
    end

    local mappedMatches = {}
    for _, match in ipairs(matches) do
        if match.startOffset ~= nil and match.endOffset ~= nil then
            mappedMatches[#mappedMatches + 1] = {
                startOffset = match.startOffset,
                endOffset = match.endOffset,
            }
        end
    end
    return mappedMatches
end

local function BookSearchValues(bookData)
    if type(bookData) ~= "table" then
        return "", "", ""
    end
    return SearchString(bookData.title),
        SearchString(bookData.collection),
        SearchString(bookData.content)
end

local function BuildSearchEntry(title, collection, content)
    return {
        sourceTitle = title,
        sourceCollection = collection,
        sourceContent = content,
        normalizedTitle = ParchmentReader:NormalizeSearchText(title),
        normalizedCollection = ParchmentReader:NormalizeSearchText(collection),
        normalizedContent = nil,
    }
end

local function GetValidatedSearchEntry(bookKey, bookData)
    if not searchIndex then searchIndex = {} end

    local title, collection, content = BookSearchValues(bookData)
    local entry = searchIndex[bookKey]
    if not entry
        or entry.sourceTitle ~= title
        or entry.sourceCollection ~= collection
        or entry.sourceContent ~= content
    then
        entry = BuildSearchEntry(title, collection, content)
        searchIndex[bookKey] = entry
    end
    return entry
end

local function MetadataContains(normalizedTitle, normalizedCollection, term)
    return string.find(normalizedTitle, term, 1, true) ~= nil
        or string.find(normalizedCollection, term, 1, true) ~= nil
end

local function MetadataMatches(normalizedTitle, normalizedCollection, terms)
    for _, term in ipairs(terms) do
        if not MetadataContains(normalizedTitle, normalizedCollection, term) then
            return false
        end
    end
    return true
end

local function EnsureNormalizedContent(entry)
    if entry.normalizedContent == nil then
        entry.normalizedContent =
            ParchmentReader:GetSearchPhrase(entry.sourceContent)
    end
    return entry.normalizedContent
end

function ParchmentReader:PruneIndex(books)
    if not searchIndex then return 0 end
    local availableBooks = type(books) == "table" and books or {}
    local removed = 0

    for bookKey in pairs(searchIndex) do
        if availableBooks[bookKey] == nil then
            searchIndex[bookKey] = nil
            removed = removed + 1
        end
    end
    return removed
end

function ParchmentReader:BookMatchesSearch(
    bookKey, bookData, terms, includeContent, searchPhrase)
    if type(terms) ~= "table" or #terms == 0 then return true end
    if bookKey == nil or type(bookData) ~= "table" then return false end

    if includeContent ~= true then
        local normalizedTitle = self:NormalizeSearchText(bookData.title)
        local normalizedCollection = self:NormalizeSearchText(bookData.collection)
        return MetadataMatches(normalizedTitle, normalizedCollection, terms)
    end

    local entry = GetValidatedSearchEntry(bookKey, bookData)
    if MetadataMatches(
        entry.normalizedTitle, entry.normalizedCollection, terms)
    then
        return true
    end

    local normalizedPhrase = SearchString(searchPhrase)
    if normalizedPhrase == "" then return false end
    local normalizedContent = EnsureNormalizedContent(entry)
    return string.find(normalizedContent, normalizedPhrase, 1, true) ~= nil
end

function ParchmentReader:GetSearchIndexDiagnostics()
    local diagnostics = {
        initialized = searchIndex ~= nil,
        entries = 0,
        contentEntries = 0,
        normalizedContentBytes = 0,
    }
    if not searchIndex then return diagnostics end

    for _, entry in pairs(searchIndex) do
        diagnostics.entries = diagnostics.entries + 1
        if entry.normalizedContent ~= nil then
            diagnostics.contentEntries = diagnostics.contentEntries + 1
            diagnostics.normalizedContentBytes =
                diagnostics.normalizedContentBytes + #entry.normalizedContent
        end
    end
    return diagnostics
end
