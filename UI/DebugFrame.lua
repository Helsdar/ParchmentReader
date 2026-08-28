

local L = ParchmentReader.L

local function Colorize(color, text)
    return color .. text .. "|r"
end

local function EscapeDebugValue(value)
    local text = tostring(value)
    return (text:gsub("%z", "\\0"))
end

local function FormatDebugNumber(value)
    if type(value) ~= "number" then return L["none"] end
    return string.format("%.2f", value)
end

local function AppendEditorDiagnostics(info, reader)
    table.insert(info, "")
    table.insert(info, Colorize("|cFF00FF00", L["[Editor]"]))

    local editor = ParchmentReaderEditorFrame
    local editBox = editor and editor.contentInput
    local scrollFrame = editor and editor.contentScroll
    if not editBox or not scrollFrame then
        table.insert(info, L["Editor state: not created"])
        return
    end

    local text = editBox:GetText() or ""
    local lineCount = math.max(1, editBox:GetNumLines() or 1)
    local fontFile, fontHeight, fontFlags = editBox:GetFont()
    local spacing = editBox:GetSpacing() or 0
    local calculatedHeight = lineCount * (tonumber(fontHeight) or 12)
        + math.max(0, lineCount - 1) * spacing + 8
    local hitLeft, hitRight, hitTop, hitBottom
    if editBox.GetHitRectInsets then
        hitLeft, hitRight, hitTop, hitBottom = editBox:GetHitRectInsets()
    end

    table.insert(info, string.format(
        L["Editor shown: %s"], tostring(editor:IsShown())))
    table.insert(info, string.format(
        L["Text: %d bytes; %d characters; cursor: %d"],
        #text,
        reader:CountUTF8Characters(text),
        editBox:GetCursorPosition() or 0))
    table.insert(info, string.format(L["Lines: %s"], tostring(lineCount)))
    table.insert(info, string.format(
        L["Font: %s; size: %s; flags: %s; spacing: %s"],
        EscapeDebugValue(fontFile or L["none"]),
        FormatDebugNumber(fontHeight),
        EscapeDebugValue(fontFlags or L["none"]),
        FormatDebugNumber(spacing)))
    table.insert(info, string.format(
        L["Height: %s; legacy formula height: %s; viewport: %s"],
        FormatDebugNumber(editBox:GetHeight()),
        FormatDebugNumber(calculatedHeight),
        FormatDebugNumber(scrollFrame:GetHeight())))
    table.insert(info, string.format(
        L["Bounds: top %s; bottom %s; scale %s"],
        FormatDebugNumber(editBox:GetTop()),
        FormatDebugNumber(editBox:GetBottom()),
        FormatDebugNumber(editBox:GetEffectiveScale())))
    table.insert(info, string.format(
        L["Scroll: %s; range: %s"],
        FormatDebugNumber(scrollFrame:GetVerticalScroll()),
        FormatDebugNumber(scrollFrame:GetVerticalScrollRange())))
    table.insert(info, string.format(
        L["Hit rect insets: L %s; R %s; T %s; B %s"],
        FormatDebugNumber(hitLeft),
        FormatDebugNumber(hitRight),
        FormatDebugNumber(hitTop),
        FormatDebugNumber(hitBottom)))
end

function ParchmentReader:CreateDebugFrame()
    local Theme = self.Theme
    local PRUI = self.PRUI
    local frame = PRUI.Window(UIParent, {
        name = "ParchmentReaderDebugFrame",
        title = L["Debug Info"],
    })
    frame:SetSize(640, 520)
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    PRUI.SetAddonFrameLayer(
        frame,
        PRUI.ADDON_FRAME_LEVELS.DEBUG,
        PRUI.ADDON_DEBUG_STRATA)
    self:RegisterEscapeClose("ParchmentReaderDebugFrame")


    local contentSurface = PRUI.Panel(frame, {color = Theme:Get("bg", "surface")})
    contentSurface:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -48)
    contentSurface:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 58)

    local scrollFrame = CreateFrame("ScrollFrame", nil, contentSurface, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", contentSurface, "TOPLEFT", 6, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", contentSurface, "BOTTOMRIGHT", -24, 6)
    PRUI.StyleScrollFrame(scrollFrame)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(math.max(1, scrollFrame:GetWidth() - 10), 1)
    scrollFrame:SetScrollChild(scrollChild)

    local debugText = scrollChild:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
    debugText:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 8, -8)
    debugText:SetWidth(scrollChild:GetWidth() - 16)
    debugText:SetJustifyH("LEFT")
    debugText:SetJustifyV("TOP")
    debugText:SetSpacing(2)
    PRUI.SetFontStringColor(debugText, Theme:Get("text", "primary"))

    frame.debugText = debugText
    frame.debugScrollChild = scrollChild
    frame.debugScrollFrame = scrollFrame

    scrollFrame:SetScript("OnSizeChanged", function(_, width, height)
        scrollChild:SetWidth(math.max(1, width - 10))
        debugText:SetWidth(math.max(1, scrollChild:GetWidth() - 16))
        scrollChild:SetHeight(math.max(height, debugText:GetStringHeight() + 16))
    end)


    local refreshBtn = PRUI.Button(frame, L["Refresh"], {width = 112, height = 26})
    refreshBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 16)
    refreshBtn:SetScript("OnClick", function()
        ParchmentReader:UpdateDebugInfo()
    end)


    local copyBtn = PRUI.Button(
        frame, L["Print to Chat"], {width = 156, height = 26})
    copyBtn:SetPoint("LEFT", refreshBtn, "RIGHT", 8, 0)
    copyBtn:SetScript("OnClick", function()
        ParchmentReader:PrintDebugToChat()
    end)


    local closeBtn = PRUI.Button(frame, L["Close"], {width = 104, height = 26})
    closeBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    frame:Hide()
    return frame
end

function ParchmentReader:ShowDebugInfo()
    if not ParchmentReaderDebugFrame then
        self:CreateDebugFrame()
    end

    self:UpdateDebugInfo()
    ParchmentReaderDebugFrame:Show()
end

function ParchmentReader:UpdateDebugInfo()
    if not ParchmentReaderDebugFrame then return end

    local info = {}


    table.insert(info, Colorize(
        "|cFFFFFF00", L["=== Parchment Reader Debug Info ==="]))
    table.insert(info, "")


    table.insert(info, Colorize("|cFF00FF00", L["[SavedVariables Status]"]))
    table.insert(info, string.format(
        L["ParchmentReaderDB exists: %s"], tostring(ParchmentReaderDB ~= nil)))

    if ParchmentReaderDB then
        table.insert(info, string.format(
            L["customBooks exists: %s"],
            tostring(ParchmentReaderDB.customBooks ~= nil)))

        if ParchmentReaderDB.customBooks then
            local savedCount = 0
            for _ in pairs(ParchmentReaderDB.customBooks) do
                savedCount = savedCount + 1
            end
            table.insert(info, string.format(
                L["Books in SavedVariables: %d"], savedCount))
        end


        table.insert(info, "")
        table.insert(info, Colorize("|cFF00FF00", L["[Settings]"]))
        table.insert(info, string.format(
            L["Interface Language: %s; active locale: %s"],
            tostring(ParchmentReaderDB.interfaceLanguage),
            tostring(ParchmentReader.locale)))
        table.insert(info, string.format(
            L["Window Width: %s"], tostring(ParchmentReaderDB.windowWidth)))
        table.insert(info, string.format(
            L["Window Height: %s"], tostring(ParchmentReaderDB.windowHeight)))
        table.insert(info, string.format(
            L["Font Name: %s"], tostring(ParchmentReaderDB.fontName)))
        table.insert(info, string.format(
            L["Font Size: %s"], tostring(ParchmentReaderDB.fontSize)))
        table.insert(info, string.format(
            L["Minimap Hidden: %s"], tostring(ParchmentReaderDB.hide)))
        table.insert(info, string.format(
            L["Compact Mode: %s"], tostring(ParchmentReaderDB.sidebarCollapsed)))
        table.insert(info, string.format(
            L["Transparency Mode: %s"],
            tostring(ParchmentReaderDB.transparencyMode)))
        table.insert(info, string.format(
            L["Combat Transparency: %s"],
            tostring(ParchmentReaderDB.readerCombatTransparency)))
    end


    table.insert(info, "")
    table.insert(info, Colorize("|cFF00FF00", L["[Books in Memory]"]))

    local memoryCount = 0
    local savedMemoryCount = 0
    local runtimeOnlyCount = 0

    for _ in pairs(self.books) do
        memoryCount = memoryCount + 1
    end

    for _, book in pairs(self.books) do
        if book.custom then
            savedMemoryCount = savedMemoryCount + 1
        else
            runtimeOnlyCount = runtimeOnlyCount + 1
        end
    end

    table.insert(info, string.format(L["Total books loaded: %d"], memoryCount))
    table.insert(info, string.format(L["Saved books: %d"], savedMemoryCount))
    table.insert(info, string.format(
        L["Runtime-only books: %d"], runtimeOnlyCount))


    table.insert(info, "")
    table.insert(info, Colorize("|cFF00FF00", L["[Current State]"]))
    table.insert(info, string.format(
        L["Current book: %s"],
        EscapeDebugValue(self.currentBook or L["none"])))
    table.insert(info, string.format(L["Current page: %d"], self.currentPage))
    table.insert(info, string.format(
        L["Reading offset: %d"], self.currentReadingOffset or 0))
    local currentBook = self.currentBook and self.books[self.currentBook]
    local normalizedContent = currentBook and self:NormalizeLayoutText(currentBook.content) or ""
    local progress = #normalizedContent > 0
        and ((self.currentReadingOffset or 0) / #normalizedContent) * 100
        or 0
    table.insert(info, string.format(L["Reading progress: %.2f%%"], progress))
    table.insert(info, string.format(
        L["Last reflow reason: %s"],
        tostring(self.lastReflowReason or L["none"])))
    local layoutKey = self.readerLayoutMetrics and self.readerLayoutMetrics.layoutKey
    table.insert(info, string.format(
        L["Layout key: %s"], EscapeDebugValue(layoutKey or L["none"])))
    local chunkCount, poolSize, visibleStart, visibleEnd, cacheReused,
        chunkIntegrity =
        self:GetReaderPoolDiagnostics()
    table.insert(info, string.format(L["Reader chunks: %d"], chunkCount))
    table.insert(info, string.format(L["FontString pool: %d"], poolSize))
    table.insert(info, string.format(
        L["Visible chunks: %s-%s"],
        tostring(visibleStart or L["none"]),
        tostring(visibleEnd or L["none"])))
    table.insert(info, string.format(
        L["Height cache reused: %s"], tostring(cacheReused)))
    table.insert(info, string.format(
        L["Chunk integrity: %s"], tostring(chunkIntegrity)))
    local cacheCount, cacheLimit, cacheHits, cacheMisses =
        self:GetReaderLayoutCacheDiagnostics()
    table.insert(info, string.format(
        L["Inactive layout cache: %d/%d (hits: %d, misses: %d)"],
        cacheCount,
        cacheLimit,
        cacheHits,
        cacheMisses))
    local layoutCacheReused = self.readerLayoutMetrics
        and self.readerLayoutMetrics.layoutCacheReused == true
    table.insert(info, string.format(
        L["Current layout cache hit: %s"], tostring(layoutCacheReused)))
    table.insert(info, string.format(
        L["Reader frame exists: %s"], tostring(ParchmentReaderFrame ~= nil)))
    table.insert(info, string.format(
        L["Settings frame exists: %s"],
        tostring(ParchmentReaderSettingsFrame ~= nil)))
    table.insert(info, string.format(
        L["Editor frame exists: %s"],
        tostring(ParchmentReaderEditorFrame ~= nil)))

    AppendEditorDiagnostics(info, self)


    table.insert(info, "")
    table.insert(info, Colorize("|cFF00FF00", L["[Book List]"]))

    local sortedBooks = {}
    for key, bookData in pairs(self.books) do
        table.insert(sortedBooks, {key = key, data = bookData})
    end
    table.sort(sortedBooks, function(a, b)
        return self:CompareBookTitles(a.data.title, b.data.title)
    end)

    for _, entry in ipairs(sortedBooks) do
        local bookData = entry.data

        local bookType = bookData.custom
            and Colorize("|cFFFFAA00", L["[SAVED]"])
            or Colorize("|cFF00AAFF", L["[RUNTIME]"])
        local characterCount = self:CountUTF8Characters(bookData.content)
        local lineInfo = string.format(L["(%d chars)"], characterCount)

        table.insert(info, string.format("%s %s %s", bookType, bookData.title, lineInfo))
    end


    if ParchmentReaderDB and ParchmentReaderDB.customBooks then
        local savedBooksCount = 0
        for _ in pairs(ParchmentReaderDB.customBooks) do
            savedBooksCount = savedBooksCount + 1
        end

        if savedBooksCount ~= savedMemoryCount then
            table.insert(info, "")
            table.insert(info, Colorize(
                "|cFFFF0000",
                L["[WARNING] Mismatch between SavedVariables and Memory!"]))
            table.insert(info, string.format(
                L["SavedVariables has %d books, but %d saved books are loaded in memory."],
                savedBooksCount,
                savedMemoryCount))
        end
    end


    table.insert(info, "")
    table.insert(info, Colorize("|cFF00FF00", L["[Memory Usage]"]))
    local memUsage = collectgarbage("count")
    table.insert(info, string.format(
        L["Global Lua memory (GC-managed): %.2f KB"],
        memUsage))


    local fullText = table.concat(info, "\n")

    local frame = ParchmentReaderDebugFrame
    frame.debugText:SetText(fullText)
    if frame.debugScrollChild and frame.debugScrollFrame then
        frame.debugScrollChild:SetHeight(math.max(
            frame.debugScrollFrame:GetHeight(),
            frame.debugText:GetStringHeight() + 16))
    end
end

function ParchmentReader:PrintDebugToChat()
    print(Colorize(
        "|cFF33FF99", L["=== Parchment Reader Debug Info ==="]))


    local savedCount = 0
    if ParchmentReaderDB and ParchmentReaderDB.customBooks then
        for _ in pairs(ParchmentReaderDB.customBooks) do
            savedCount = savedCount + 1
        end
    end


    local memoryCount = 0
    local savedMemoryCount = 0
    for _, book in pairs(self.books) do
        memoryCount = memoryCount + 1
        if book.custom then
            savedMemoryCount = savedMemoryCount + 1
        end
    end

    print(string.format(L["Books in SavedVariables: %d"], savedCount))
    print(string.format(
        L["Books in Memory: %d (saved: %d)"], memoryCount, savedMemoryCount))
    print(string.format(
        L["Current book: %s"],
        EscapeDebugValue(self.currentBook or L["none"])))
    print(string.format(L["Current page: %d"], self.currentPage))
    print(string.format(
        L["Reading offset: %d"], self.currentReadingOffset or 0))
    print(string.format(
        L["Last reflow reason: %s"],
        tostring(self.lastReflowReason or L["none"])))
    local chunkCount, poolSize, visibleStart, visibleEnd, cacheReused,
        chunkIntegrity =
        self:GetReaderPoolDiagnostics()
    print(string.format(
        L["Reader chunks: %d; pool: %d; visible: %s-%s"],
        chunkCount,
        poolSize,
        tostring(visibleStart or L["none"]),
        tostring(visibleEnd or L["none"])))
    print(string.format(
        L["Height cache reused: %s"], tostring(cacheReused)))
    print(string.format(L["Chunk integrity: %s"], tostring(chunkIntegrity)))
    local cacheCount, cacheLimit, cacheHits, cacheMisses =
        self:GetReaderLayoutCacheDiagnostics()
    print(string.format(
        L["Inactive layout cache: %d/%d (hits: %d, misses: %d)"],
        cacheCount,
        cacheLimit,
        cacheHits,
        cacheMisses))

    local editorInfo = {}
    AppendEditorDiagnostics(editorInfo, self)
    for _, line in ipairs(editorInfo) do
        print((line:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")))
    end


    print(L["Book List:"])
    local sortedBooks = {}
    for key, bookData in pairs(self.books) do
        table.insert(sortedBooks, {key = key, data = bookData})
    end
    table.sort(sortedBooks, function(a, b)
        return self:CompareBookTitles(a.data.title, b.data.title)
    end)

    for _, entry in ipairs(sortedBooks) do
        local bookType = entry.data.custom and L["[SAVED]"] or L["[RUNTIME]"]
        local characterCount = self:CountUTF8Characters(entry.data.content)
        print(string.format(
            L["  %s %s (%d chars)"],
            bookType,
            entry.data.title,
            characterCount))
    end
end
