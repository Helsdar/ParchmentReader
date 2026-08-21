


local CHUNK_TARGET_BYTES = 1800
local CHUNK_MIN_BYTES = 900
local TEXT_POOL_SIZE = 32
local CONTENT_PADDING_TOP = 4
local CONTENT_PADDING_BOTTOM = 8
local VIRTUAL_BUFFER_VIEWPORTS = 0.25
local RESIZE_DEBOUNCE_SECONDS = 0.12
local SMOOTH_SCROLL_SPEED = 14
local WHEEL_LINE_COUNT = 4
local LAYOUT_CACHE_LIMIT = 2
local RETURN_TO_BEGINNING_POPUP = "PARCHMENTREADER_RETURN_TO_BEGINNING"
local GO_TO_END_POPUP = "PARCHMENTREADER_GO_TO_END"
local L = ParchmentReader.L

local readerFontObjects = {}

StaticPopupDialogs[RETURN_TO_BEGINNING_POPUP] = {
    text = L["Go to the beginning?\n\nYour saved reading position will move to the start."],
    button1 = L["Go to Beginning"],
    button2 = L["Cancel"],
    OnAccept = function(dialog, data)
        if ParchmentReader.returnToBeginningPopup == dialog then
            ParchmentReader.returnToBeginningPopup = nil
        end

        local frame = ParchmentReaderFrame
        local layout = ParchmentReader.readerLayoutMetrics
        if type(data) ~= "table"
            or not frame
            or not frame:IsShown()
            or ParchmentReader.currentBook ~= data.bookKey
            or not ParchmentReader.books[data.bookKey]
            or not layout
            or layout.bookKey ~= data.bookKey
        then
            return
        end

        ParchmentReader:ScrollReaderToStart()
    end,
    OnCancel = function(dialog)
        if ParchmentReader.returnToBeginningPopup == dialog then
            ParchmentReader.returnToBeginningPopup = nil
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs[GO_TO_END_POPUP] = {
    text = L["Go to the end?\n\nYour saved reading position will move to the end."],
    button1 = L["Go to End"],
    button2 = L["Cancel"],
    OnAccept = function(dialog, data)
        if ParchmentReader.goToEndPopup == dialog then
            ParchmentReader.goToEndPopup = nil
        end

        local frame = ParchmentReaderFrame
        local layout = ParchmentReader.readerLayoutMetrics
        if type(data) ~= "table"
            or not frame
            or not frame:IsShown()
            or ParchmentReader.currentBook ~= data.bookKey
            or not ParchmentReader.books[data.bookKey]
            or not layout
            or layout.bookKey ~= data.bookKey
        then
            return
        end

        ParchmentReader:ScrollReaderToEnd()
    end,
    OnCancel = function(dialog)
        if ParchmentReader.goToEndPopup == dialog then
            ParchmentReader.goToEndPopup = nil
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function RefreshJumpPopupLocalization()
    local beginningPopup = StaticPopupDialogs[RETURN_TO_BEGINNING_POPUP]
    beginningPopup.text =
        L["Go to the beginning?\n\nYour saved reading position will move to the start."]
    beginningPopup.button1 = L["Go to Beginning"]
    beginningPopup.button2 = L["Cancel"]

    local endPopup = StaticPopupDialogs[GO_TO_END_POPUP]
    endPopup.text =
        L["Go to the end?\n\nYour saved reading position will move to the end."]
    endPopup.button1 = L["Go to End"]
    endPopup.button2 = L["Cancel"]
end

local function Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end

local function RemoveCachedLayoutKey(order, layoutKey)
    for index = #order, 1, -1 do
        if order[index] == layoutKey then
            table.remove(order, index)
            return
        end
    end
end

function ParchmentReader:CacheCurrentReaderLayout()
    local layout = self.readerLayoutMetrics
    if not layout or not layout.layoutKey then return end

    self.readerLayoutCache = self.readerLayoutCache or {}
    self.readerLayoutCacheOrder = self.readerLayoutCacheOrder or {}
    RemoveCachedLayoutKey(self.readerLayoutCacheOrder, layout.layoutKey)
    layout.visibleChunkStart = nil
    layout.visibleChunkEnd = nil
    self.readerLayoutCache[layout.layoutKey] = layout
    self.readerLayoutCacheOrder[#self.readerLayoutCacheOrder + 1] = layout.layoutKey

    while #self.readerLayoutCacheOrder > LAYOUT_CACHE_LIMIT do
        local oldestKey = table.remove(self.readerLayoutCacheOrder, 1)
        self.readerLayoutCache[oldestKey] = nil
    end
end

function ParchmentReader:TakeCachedReaderLayout(layoutKey, content)
    local cache = self.readerLayoutCache
    local order = self.readerLayoutCacheOrder
    local layout = cache and cache[layoutKey]
    if layout and layout.content ~= content then
        cache[layoutKey] = nil
        RemoveCachedLayoutKey(order, layoutKey)
        layout = nil
    end
    if not layout then
        self.readerLayoutCacheMisses = (self.readerLayoutCacheMisses or 0) + 1
        return nil
    end

    cache[layoutKey] = nil
    RemoveCachedLayoutKey(order, layoutKey)
    layout.visibleChunkStart = nil
    layout.visibleChunkEnd = nil
    layout.lastCommittedScroll = nil
    layout.layoutCacheReused = true
    self.readerLayoutCacheHits = (self.readerLayoutCacheHits or 0) + 1
    return layout
end

function ParchmentReader:InvalidateReaderLayoutCache(bookKey)
    local cache = self.readerLayoutCache
    local order = self.readerLayoutCacheOrder
    if not cache or not order then return end

    for index = #order, 1, -1 do
        local layoutKey = order[index]
        local layout = cache[layoutKey]
        if layout and layout.bookKey == bookKey then
            cache[layoutKey] = nil
            table.remove(order, index)
        end
    end
end

function ParchmentReader:GetReaderLayoutCacheDiagnostics()
    local order = self.readerLayoutCacheOrder or {}
    return #order,
        LAYOUT_CACHE_LIMIT,
        self.readerLayoutCacheHits or 0,
        self.readerLayoutCacheMisses or 0
end

local function NextUTF8Offset(text, offset)
    if offset >= #text then return #text end

    local leadByte = text:byte(offset + 1)
    local length = 1
    if leadByte and leadByte >= 240 then
        length = 4
    elseif leadByte and leadByte >= 224 then
        length = 3
    elseif leadByte and leadByte >= 192 then
        length = 2
    end

    return math.min(#text, offset + length)
end

local function FindLastSeparator(content, searchStart, searchEnd, separator)
    local lastEnd
    local searchAt = searchStart

    while searchAt <= searchEnd do
        local matchStart = content:find(separator, searchAt, true)
        if not matchStart then break end

        local matchEnd = matchStart + #separator - 1
        if matchEnd > searchEnd then break end

        lastEnd = matchEnd
        searchAt = matchStart + 1
    end

    return lastEnd
end

local function FindChunkEnd(content, startOffset)
    local maximum = math.min(#content, startOffset + CHUNK_TARGET_BYTES)
    maximum = ParchmentReader:SnapReadingOffset(content, maximum)
    if maximum >= #content then return #content end

    local minimum = math.min(maximum, startOffset + CHUNK_MIN_BYTES)
    local searchStart = minimum + 1
    local chunkEnd = FindLastSeparator(content, searchStart, maximum, "\n\n")
        or FindLastSeparator(content, searchStart, maximum, "\n")

    if not chunkEnd then
        for byteIndex = maximum, searchStart, -1 do
            local byte = content:byte(byteIndex)
            if byte == 32 or byte == 9 then
                chunkEnd = byteIndex
                break
            end
        end
    end

    chunkEnd = chunkEnd or maximum
    if chunkEnd <= startOffset then
        chunkEnd = NextUTF8Offset(content, startOffset)
    end

    return chunkEnd
end

local function SplitIntoChunks(content)
    local chunks = {}
    local startOffset = 0

    while startOffset < #content do
        local endOffset = FindChunkEnd(content, startOffset)
        chunks[#chunks + 1] = {
            startOffset = startOffset,
            endOffset = endOffset,
            text = content:sub(startOffset + 1, endOffset),
        }
        startOffset = endOffset
    end

    return chunks
end

local function ConfigureReaderText(fontString)
    fontString:SetJustifyH("LEFT")
    fontString:SetJustifyV("TOP")
    fontString:SetSpacing(2)
    fontString:SetNonSpaceWrap(true)
    local color = ParchmentReader.Theme:Get("text", "primary")
    fontString:SetTextColor(color[1], color[2], color[3], color[4])
end

local function HideTextPool(frame)
    for _, fontString in ipairs(frame.readerTextPool) do
        fontString:Hide()
        fontString:SetText("")
        fontString.chunkIndex = nil
    end
end

local function GetReaderFontObject(fontName, fontSize)
    local cacheKey = fontName:gsub("[^%w]", "_")
    local fontObject = readerFontObjects[fontName]

    if not fontObject then
        fontObject = CreateFont("ParchmentReaderContinuousFont_" .. cacheKey)
        readerFontObjects[fontName] = fontObject
    end

    if fontName:match("%.TTF$") then
        fontObject:SetFont("Fonts\\" .. fontName, fontSize, "")
    else
        local sourceFont = _G[fontName] or _G.ChatFontNormal
        fontObject:CopyFontObject(sourceFont)
        fontObject:SetFontHeight(fontSize)
    end

    return fontObject
end

function ParchmentReader:ApplyFontTo(fontString)
    local fontName = ParchmentReaderDB.fontName or "ChatFontNormal"
    local fontSize = tonumber(ParchmentReaderDB.fontSize) or 14
    fontString:SetFontObject(GetReaderFontObject(fontName, fontSize))
end

function ParchmentReader:InitializeReaderTextObjects(frame)
    local contentChild = frame.contentChild
    local initialWidth = math.max(1, contentChild:GetWidth() - 16)
    frame.readerTextWidth = initialWidth
    frame.readerTextPool = {}

    local measureText = contentChild:CreateFontString(nil, "OVERLAY")
    measureText:SetPoint("TOPLEFT", contentChild, "TOPLEFT", 8, -CONTENT_PADDING_TOP)
    measureText:SetWidth(initialWidth)
    measureText:SetAlpha(0)
    ConfigureReaderText(measureText)
    self:ApplyFontTo(measureText)
    frame.readerMeasureText = measureText

    local message = contentChild:CreateFontString(nil, "OVERLAY")
    message:SetPoint("TOPLEFT", contentChild, "TOPLEFT", 8, -CONTENT_PADDING_TOP)
    message:SetWidth(initialWidth)
    ConfigureReaderText(message)
    self:ApplyFontTo(message)
    frame.readerMessage = message

    for index = 1, TEXT_POOL_SIZE do
        local fontString = contentChild:CreateFontString(nil, "OVERLAY")
        fontString:SetWidth(initialWidth)
        ConfigureReaderText(fontString)
        self:ApplyFontTo(fontString)
        fontString:Hide()
        frame.readerTextPool[index] = fontString
    end
end

local function MeasureTextHeight(frame, text)
    local measureText = frame.readerMeasureText
    measureText:SetText(text)
    local height = measureText:GetStringHeight() or 0
    measureText:SetText("")
    return height
end

local function ValidateChunks(content, chunks)
    local expectedStart = 0
    for _, chunk in ipairs(chunks) do
        if chunk.startOffset ~= expectedStart
            or chunk.endOffset <= chunk.startOffset
            or chunk.endOffset ~= ParchmentReader:SnapReadingOffset(
                content,
                chunk.endOffset)
            or chunk.text ~= content:sub(chunk.startOffset + 1, chunk.endOffset)
        then
            return false
        end
        expectedStart = chunk.endOffset
    end
    return expectedStart == #content
end

local function CanReuseChunkMeasurements(previousLayout, content, descriptor)
    if not previousLayout or previousLayout.content ~= content then return false end
    local previous = previousLayout.descriptor
    return previous.contentRevision == descriptor.contentRevision
        and previous.width == descriptor.width
        and previous.font == descriptor.font
        and previous.fontSize == descriptor.fontSize
        and previous.spacing == descriptor.spacing
        and previous.scale == descriptor.scale
end

local function BuildChunkLayout(
    frame,
    content,
    descriptor,
    layoutKey,
    layoutSignature,
    previousLayout)
    if CanReuseChunkMeasurements(previousLayout, content, descriptor) then
        return {
            bookKey = ParchmentReader.currentBook,
            content = content,
            descriptor = descriptor,
            layoutKey = layoutKey,
            layoutSignature = layoutSignature,
            chunks = previousLayout.chunks,
            chunkCount = previousLayout.chunkCount,
            lineHeight = previousLayout.lineHeight,
            totalHeight = previousLayout.totalHeight,
            poolSize = TEXT_POOL_SIZE,
            heightCacheReused = true,
            chunkIntegrity = previousLayout.chunkIntegrity,
        }
    end

    local chunks = SplitIntoChunks(content)
    local lineHeight = math.max(1, MeasureTextHeight(frame, "Ag"))
    local top = 0

    for _, chunk in ipairs(chunks) do
        chunk.top = top
        chunk.height = math.max(lineHeight, MeasureTextHeight(frame, chunk.text))
        chunk.bottom = chunk.top + chunk.height
        top = chunk.bottom
    end

    return {
        bookKey = ParchmentReader.currentBook,
        content = content,
        descriptor = descriptor,
        layoutKey = layoutKey,
        layoutSignature = layoutSignature,
        chunks = chunks,
        chunkCount = #chunks,
        lineHeight = lineHeight,
        totalHeight = top,
        poolSize = TEXT_POOL_SIZE,
        chunkIntegrity = ValidateChunks(content, chunks),
    }
end

local function FindChunkForY(layout, contentY)
    local chunks = layout.chunks
    if #chunks == 0 then return nil end

    local low = 1
    local high = #chunks
    while low < high do
        local middle = math.floor((low + high) / 2)
        if contentY < chunks[middle].bottom then
            high = middle
        else
            low = middle + 1
        end
    end

    return low
end

local function FindChunkForOffset(layout, offset)
    local chunks = layout.chunks
    if #chunks == 0 then return nil end

    local safeOffset = ParchmentReader:SnapReadingOffset(layout.content, offset)
    local low = 1
    local high = #chunks
    while low < high do
        local middle = math.floor((low + high) / 2)
        if safeOffset < chunks[middle].endOffset then
            high = middle
        else
            low = middle + 1
        end
    end

    return low
end

local function GetMaximumScroll(frame, layout)
    if not layout then return 0 end
    local childHeight = layout.totalHeight + CONTENT_PADDING_TOP + CONTENT_PADDING_BOTTOM
    return math.max(0, childHeight - frame.contentScroll:GetHeight())
end

local function MeasurePrefixHeight(frame, chunk, localOffset)
    if localOffset <= 0 then return 0 end
    return MeasureTextHeight(frame, chunk.text:sub(1, localOffset))
end

local function OffsetToScroll(frame, layout, offset)
    local chunkIndex = FindChunkForOffset(layout, offset)
    if not chunkIndex then return 0 end

    local chunk = layout.chunks[chunkIndex]
    local safeOffset = ParchmentReader:SnapReadingOffset(layout.content, offset)
    local localOffset = Clamp(safeOffset - chunk.startOffset, 0, #chunk.text)
    local prefixHeight = MeasurePrefixHeight(frame, chunk, localOffset)
    local lineTop = math.max(0, prefixHeight - layout.lineHeight)
    return CONTENT_PADDING_TOP + chunk.top + lineTop
end

local function ScrollToOffset(frame, layout, scrollOffset)
    if #layout.chunks == 0 then return 0 end
    if scrollOffset <= 0.5 then return 0 end

    local contentY = math.max(0, scrollOffset - CONTENT_PADDING_TOP)
    local chunkIndex = FindChunkForY(layout, contentY)
    local chunk = layout.chunks[chunkIndex]
    local localY = Clamp(contentY - chunk.top, 0, chunk.height)
    local targetHeight = localY + layout.lineHeight + 0.5
    local low = 0
    local high = #chunk.text

    while high - low > 4 do
        local middle = ParchmentReader:SnapReadingOffset(
            chunk.text,
            math.floor((low + high) / 2))
        if middle <= low then
            middle = NextUTF8Offset(chunk.text, low)
        end
        if middle >= high then break end

        if MeasurePrefixHeight(frame, chunk, middle) <= targetHeight then
            low = middle
        else
            high = middle
        end
    end

    local candidate = low
    local nextOffset = NextUTF8Offset(chunk.text, candidate)
    while nextOffset > candidate and nextOffset <= high do
        if MeasurePrefixHeight(frame, chunk, nextOffset) > targetHeight then
            break
        end
        candidate = nextOffset
        nextOffset = NextUTF8Offset(chunk.text, candidate)
    end

    return chunk.startOffset + candidate
end

function ParchmentReader:RenderVisibleReaderChunks(scrollOffset)
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    if not frame or not layout or layout.bookKey ~= self.currentBook then return end

    if #layout.chunks == 0 then
        HideTextPool(frame)
        return
    end

    local viewportHeight = math.max(1, frame.contentScroll:GetHeight())
    local buffer = viewportHeight * VIRTUAL_BUFFER_VIEWPORTS
    local visibleTop = math.max(0, scrollOffset - CONTENT_PADDING_TOP - buffer)
    local visibleBottom = scrollOffset - CONTENT_PADDING_TOP + viewportHeight + buffer
    local firstChunkIndex = FindChunkForY(layout, visibleTop)
    local lastChunkIndex = firstChunkIndex - 1

    while lastChunkIndex < #layout.chunks
        and lastChunkIndex - firstChunkIndex + 1 < #frame.readerTextPool
    do
        local chunk = layout.chunks[lastChunkIndex + 1]
        if chunk.top > visibleBottom then break end
        lastChunkIndex = lastChunkIndex + 1
    end

    if layout.visibleChunkStart == firstChunkIndex
        and layout.visibleChunkEnd == lastChunkIndex
    then
        return
    end

    local poolIndex = 1
    for chunkIndex = firstChunkIndex, lastChunkIndex do
        local chunk = layout.chunks[chunkIndex]
        local fontString = frame.readerTextPool[poolIndex]
        fontString:ClearAllPoints()
        fontString:SetPoint(
            "TOPLEFT",
            frame.contentChild,
            "TOPLEFT",
            8,
            -(CONTENT_PADDING_TOP + chunk.top))
        fontString:SetText(chunk.text)
        fontString.chunkIndex = chunkIndex
        fontString:Show()

        poolIndex = poolIndex + 1
    end

    for index = poolIndex, #frame.readerTextPool do
        local fontString = frame.readerTextPool[index]
        fontString:Hide()
        fontString:SetText("")
        fontString.chunkIndex = nil
    end

    layout.visibleChunkStart = firstChunkIndex
    layout.visibleChunkEnd = lastChunkIndex
end

local function GetLegacyPageMetrics(frame, layout, scrollOffset)
    local viewportHeight = math.max(1, frame.contentScroll:GetHeight())
    local totalPages = math.max(1, math.ceil(
        (layout.totalHeight + CONTENT_PADDING_TOP + CONTENT_PADDING_BOTTOM)
            / viewportHeight))
    local currentPage = math.floor(scrollOffset / viewportHeight) + 1
    local maximumScroll = GetMaximumScroll(frame, layout)
    if maximumScroll - scrollOffset < 0.5 then
        currentPage = totalPages
    end
    return Clamp(currentPage, 1, totalPages), totalPages
end

function ParchmentReader:UpdateReaderProgress(scrollOffset)
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    if not frame or not layout then return end

    local maximumScroll = GetMaximumScroll(frame, layout)
    local progress
    if maximumScroll <= 0 then
        progress = #layout.content > 0 and 100 or 0
    else
        progress = Clamp(scrollOffset / maximumScroll, 0, 1) * 100
    end
    frame.pageText:SetText(string.format("%d%%", math.floor(progress + 0.5)))
    if frame.progressBar then
        frame.progressBar:SetValue(progress)
    end

    if scrollOffset > 0.5 then
        frame.prevButton:Enable()
    else
        frame.prevButton:Disable()
    end

    if maximumScroll - scrollOffset > 0.5 then
        frame.nextButton:Enable()
    else
        frame.nextButton:Disable()
    end
end

function ParchmentReader:CommitReadingPosition(scrollOffset)
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    if not frame or not layout or layout.bookKey ~= self.currentBook then return end

    local maximumScroll = GetMaximumScroll(frame, layout)
    local clampedScroll = Clamp(scrollOffset or 0, 0, maximumScroll)
    if layout.lastCommittedScroll
        and math.abs(layout.lastCommittedScroll - clampedScroll) < 0.05
    then
        return
    end

    local offset = ScrollToOffset(frame, layout, clampedScroll)
    local currentPage, totalPages = GetLegacyPageMetrics(frame, layout, clampedScroll)

    self.currentReadingOffset = offset
    self.currentPage = currentPage
    local book = self.books[self.currentBook]
    if book then
        book.totalPages = totalPages
    end

    ParchmentReaderDB.bookPages = ParchmentReaderDB.bookPages or {}
    ParchmentReaderDB.bookPages[self.currentBook] = currentPage
    self:SaveReadingPosition(
        self.currentBook,
        layout.content,
        offset,
        currentPage,
        totalPages,
        layout.layoutSignature)
    layout.lastCommittedScroll = clampedScroll
end

function ParchmentReader:HandleReaderScroll(scrollOffset)
    local layout = self.readerLayoutMetrics
    if not layout then return end

    local frame = ParchmentReaderFrame
    local clampedScroll = Clamp(scrollOffset or 0, 0, GetMaximumScroll(frame, layout))
    self:RenderVisibleReaderChunks(clampedScroll)
    self:UpdateReaderProgress(clampedScroll)
end

function ParchmentReader:StopReaderScrollAnimation()
    local frame = ParchmentReaderFrame
    if not frame or not frame.contentScroll then return end
    frame.readerScrollTarget = nil
    frame.contentScroll:SetScript("OnUpdate", nil)
end

local function AdvanceSmoothScroll(self, frame, elapsed)
    local target = frame.readerScrollTarget
    if target == nil then
        frame.contentScroll:SetScript("OnUpdate", nil)
        return
    end

    local current = frame.contentScroll:GetVerticalScroll() or 0
    local distance = target - current
    if math.abs(distance) < 0.5 then
        frame.contentScroll:SetVerticalScroll(target)
        self:HandleReaderScroll(target)
        self:StopReaderScrollAnimation()
        return
    end

    local factor = math.min(1, elapsed * SMOOTH_SCROLL_SPEED)
    local nextScroll = current + distance * factor
    frame.contentScroll:SetVerticalScroll(nextScroll)
    self:HandleReaderScroll(nextScroll)
end

function ParchmentReader:ScrollReaderTo(scrollOffset, immediate)
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    if not frame or not layout then return end

    local target = Clamp(scrollOffset or 0, 0, GetMaximumScroll(frame, layout))
    self:CommitReadingPosition(target)

    if immediate then
        self:StopReaderScrollAnimation()
        frame.contentScroll:SetVerticalScroll(target)
        self:HandleReaderScroll(target)
        return
    end

    frame.readerScrollTarget = target
    frame.contentScroll:SetScript("OnUpdate", function(_, elapsed)
        AdvanceSmoothScroll(self, frame, elapsed)
    end)
end

function ParchmentReader:CanSeekReader()
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    return frame ~= nil
        and layout ~= nil
        and layout.bookKey == self.currentBook
        and GetMaximumScroll(frame, layout) > 0
end

function ParchmentReader:SeekReaderToProgress(progress, commit)
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    if not frame
        or not layout
        or layout.bookKey ~= self.currentBook
    then
        return false
    end

    local maximumScroll = GetMaximumScroll(frame, layout)
    if maximumScroll <= 0 then return false end

    local target = maximumScroll * Clamp(tonumber(progress) or 0, 0, 1)
    self:CancelReaderJumpRequests()
    self:StopReaderScrollAnimation()
    frame.contentScroll:SetVerticalScroll(target)
    self:HandleReaderScroll(target)
    if commit then
        self:CommitReadingPosition(target)
    end
    return true
end

function ParchmentReader:ScrollReaderByPixels(delta)
    local frame = ParchmentReaderFrame
    if not frame or not self.readerLayoutMetrics then return end
    local base = frame.readerScrollTarget
        or frame.contentScroll:GetVerticalScroll()
        or 0
    self:ScrollReaderTo(base + delta, false)
end

function ParchmentReader:ScrollReaderByLines(lineCount)
    local layout = self.readerLayoutMetrics
    if not layout then return end
    local spacing = layout.descriptor.spacing or 0
    self:ScrollReaderByPixels(lineCount * (layout.lineHeight + spacing))
end

function ParchmentReader:ScrollReaderByViewport(factor)
    local frame = ParchmentReaderFrame
    if not frame then return end
    self:ScrollReaderByPixels(frame.contentScroll:GetHeight() * factor)
end

function ParchmentReader:ScrollReaderToStart()
    self:ScrollReaderTo(0, false)
end

function ParchmentReader:CancelReaderJumpRequests()
    local beginningPopup = self.returnToBeginningPopup
    local endPopup = self.goToEndPopup
    self.returnToBeginningPopup = nil
    self.goToEndPopup = nil
    if beginningPopup and beginningPopup:IsShown() then
        StaticPopup_Hide(RETURN_TO_BEGINNING_POPUP)
    end
    if endPopup and endPopup:IsShown() then
        StaticPopup_Hide(GO_TO_END_POPUP)
    end
end

function ParchmentReader:RequestReturnToBeginning()
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    local bookKey = self.currentBook
    if not frame
        or not frame:IsShown()
        or not bookKey
        or not layout
        or layout.bookKey ~= bookKey
    then
        return false
    end

    local currentScroll = frame.readerScrollTarget
        or frame.contentScroll:GetVerticalScroll()
        or 0
    if currentScroll <= 0 then return true end

    local popup = self.returnToBeginningPopup
    if popup and popup:IsShown() then return true end
    popup = self.goToEndPopup
    if popup and popup:IsShown() then return true end

    RefreshJumpPopupLocalization()
    self.returnToBeginningPopup = StaticPopup_Show(
        RETURN_TO_BEGINNING_POPUP, nil, nil, {bookKey = bookKey})
    return self.returnToBeginningPopup ~= nil
end

function ParchmentReader:ScrollReaderToEnd()
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    if not frame or not layout then return end
    self:ScrollReaderTo(GetMaximumScroll(frame, layout), false)
end

function ParchmentReader:RequestGoToEnd()
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    local bookKey = self.currentBook
    if not frame
        or not frame:IsShown()
        or not bookKey
        or not layout
        or layout.bookKey ~= bookKey
    then
        return false
    end

    local currentScroll = frame.readerScrollTarget
        or frame.contentScroll:GetVerticalScroll()
        or 0
    if GetMaximumScroll(frame, layout) - currentScroll <= 0.5 then
        return true
    end

    local popup = self.goToEndPopup
    if popup and popup:IsShown() then return true end
    popup = self.returnToBeginningPopup
    if popup and popup:IsShown() then return true end

    RefreshJumpPopupLocalization()
    self.goToEndPopup = StaticPopup_Show(
        GO_TO_END_POPUP, nil, nil, {bookKey = bookKey})
    return self.goToEndPopup ~= nil
end

function ParchmentReader:ScrollReaderToReadingOffset(offset, immediate)
    local frame = ParchmentReaderFrame
    local layout = self.readerLayoutMetrics
    if not frame or not layout or layout.bookKey ~= self.currentBook then
        return false
    end

    local safeOffset = self:SnapReadingOffset(layout.content, offset)
    local targetScroll = OffsetToScroll(frame, layout, safeOffset)
    self.currentReadingOffset = safeOffset
    self:ScrollReaderTo(targetScroll, immediate == true)
    return true
end

function ParchmentReader:HandleReaderMouseWheel(delta)
    self:ScrollReaderByLines(-delta * WHEEL_LINE_COUNT)
end

function ParchmentReader:HandleReaderKey(key)
    if not self.readerLayoutMetrics then return false end

    if key == "UP" then
        self:ScrollReaderByLines(-3)
    elseif key == "DOWN" then
        self:ScrollReaderByLines(3)
    elseif key == "PAGEUP" then
        self:ScrollReaderByViewport(-0.9)
    elseif key == "PAGEDOWN" then
        self:ScrollReaderByViewport(0.9)
    elseif key == "HOME" then
        self:RequestReturnToBeginning()
    elseif key == "END" then
        self:RequestGoToEnd()
    else
        return false
    end

    return true
end

function ParchmentReader:SyncReadingPosition()
    local frame = ParchmentReaderFrame
    if not frame or not self.readerLayoutMetrics then return end
    local scrollOffset = frame.readerScrollTarget
        or frame.contentScroll:GetVerticalScroll()
        or 0
    self:CommitReadingPosition(scrollOffset)
end

function ParchmentReader:ScheduleReaderLayout(reason)
    local frame = ParchmentReaderFrame
    if not frame then return end

    frame.readerLayoutGeneration = (frame.readerLayoutGeneration or 0) + 1
    frame.readerScheduledReason = reason or frame.readerScheduledReason
    if frame.readerResizeActive then return end
    local generation = frame.readerLayoutGeneration

    C_Timer.After(RESIZE_DEBOUNCE_SECONDS, function()
        if not ParchmentReaderFrame
            or ParchmentReaderFrame.readerLayoutGeneration ~= generation
        then
            return
        end

        local scheduledReason = ParchmentReaderFrame.readerScheduledReason
        ParchmentReaderFrame.readerScheduledReason = nil
        ParchmentReader:UpdateReader(scheduledReason)
    end)
end

function ParchmentReader:UpdateReader(requestedReason)
    local frame = ParchmentReaderFrame
    if not frame or not frame.readerMeasureText then return end

    local book = self.currentBook and self.books[self.currentBook]
    if not book then
        self:StopReaderScrollAnimation()
        self.readerLayoutMetrics = nil
        HideTextPool(frame)
        frame.readerMessage:SetText(L["Select a book from the library."])
        frame.readerMessage:Show()
        frame.contentChild:SetHeight(math.max(1, frame.contentScroll:GetHeight()))
        frame.contentScroll:SetVerticalScroll(0)
        frame.pageText:SetText("")
        if frame.progressBar then
            frame.progressBar:SetValue(0)
        end
        frame.prevButton:Disable()
        frame.nextButton:Disable()
        if self.RefreshBookmarkControls then
            self:RefreshBookmarkControls()
        end
        return
    end

    local content = self:NormalizeLayoutText(book.content)
    local descriptor = self:BuildLayoutDescriptor(frame, book)
    local layoutSignature = self:BuildLayoutSignature(descriptor)
    local layoutKey = self:BuildLayoutKey(descriptor)
    local previousLayout = self.readerLayoutMetrics

    if previousLayout
        and previousLayout.bookKey == self.currentBook
        and previousLayout.layoutKey == layoutKey
    then
        frame.readerMessage:Hide()
        local currentScroll = frame.contentScroll:GetVerticalScroll() or 0
        self:HandleReaderScroll(currentScroll)
        if self.RefreshBookmarkControls then
            self:RefreshBookmarkControls()
        end
        return
    end

    local reflowReason = self:DescribeLayoutChange(
        previousLayout and previousLayout.descriptor,
        descriptor)
    if reflowReason == "initial-layout" then
        reflowReason = requestedReason or self.lastReflowReason or reflowReason
    end

    if previousLayout
        and previousLayout.bookKey == self.currentBook
        and reflowReason == "content-changed"
    then
        local savedPosition = self:GetSavedReadingPosition(self.currentBook)
        self.currentReadingOffset = self:ResolveReadingPosition(content, savedPosition)
            or self.currentReadingOffset
    end

    local restoreLegacyPage = not previousLayout
        and self.pendingReadingRestore ~= true
        and self.lastReflowReason == "legacy-page"
        and self.currentPage > 1

    self:StopReaderScrollAnimation()
    local layout = not previousLayout
        and self:TakeCachedReaderLayout(layoutKey, content)
    if not layout then
        layout = BuildChunkLayout(
            frame,
            content,
            descriptor,
            layoutKey,
            layoutSignature,
            previousLayout)
        layout.layoutCacheReused = false
    end
    self.readerLayoutMetrics = layout
    self.lastReflowReason = reflowReason
    frame.contentChild:SetHeight(math.max(
        1,
        layout.totalHeight + CONTENT_PADDING_TOP + CONTENT_PADDING_BOTTOM))

    if #content == 0 then
        HideTextPool(frame)
        frame.readerMessage:SetText(L["This book is empty."])
        frame.readerMessage:Show()
    else
        frame.readerMessage:Hide()
    end

    local targetScroll
    if restoreLegacyPage then
        targetScroll = (self.currentPage - 1) * frame.contentScroll:GetHeight()
    else
        targetScroll = OffsetToScroll(frame, layout, self.currentReadingOffset or 0)
    end
    targetScroll = Clamp(targetScroll, 0, GetMaximumScroll(frame, layout))

    frame.contentScroll:SetVerticalScroll(targetScroll)
    self:HandleReaderScroll(targetScroll)
    self:CommitReadingPosition(targetScroll)
    self.pendingReadingRestore = false
    self.pendingReadingPosition = nil
    if self.RefreshBookmarkControls then
        self:RefreshBookmarkControls()
    end
end

function ParchmentReader:GetReaderPoolDiagnostics()
    local layout = self.readerLayoutMetrics
    if not layout then return 0, TEXT_POOL_SIZE, nil, nil, false, true end
    return layout.chunkCount,
        layout.poolSize,
        layout.visibleChunkStart,
        layout.visibleChunkEnd,
        layout.heightCacheReused == true,
        layout.chunkIntegrity == true
end
