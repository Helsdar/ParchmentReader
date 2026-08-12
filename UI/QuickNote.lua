


local QUICK_NOTE_COLLECTION = "Notes"
local QUICK_NOTE_MIN_FRAME_LEVEL = 50
local QUICK_NOTE_READER_LEVEL_OFFSET = 40
local L = ParchmentReader.L

local function Trim(value)
    return (value or ""):match("^%s*(.-)%s*$")
end

local function CollectionExists(name)
    for _, collectionName in ipairs(ParchmentReaderDB.collections or {}) do
        if collectionName == name then
            return true
        end
    end
    return false
end

local function RefreshContentHitRect(frame)
    local scrollFrame = frame.contentScroll
    local editBox = frame.contentInput
    if not scrollFrame or not editBox then return end

    local scrollRange = scrollFrame:GetVerticalScrollRange() or 0
    if scrollRange <= 0 then
        editBox:SetHitRectInsets(0, 0, 0, 0)
        return
    end

    local offset = math.max(0, scrollFrame:GetVerticalScroll() or 0)
    local viewportHeight = math.max(0, scrollFrame:GetHeight() or 0)
    local editBoxHeight = math.max(0, editBox:GetHeight() or 0)
    editBox:SetHitRectInsets(
        0,
        0,
        math.min(offset, editBoxHeight),
        math.max(0, editBoxHeight - offset - viewportHeight))
end

local function RefreshContentLayout(frame)
    local scrollFrame = frame.contentScroll
    local editBox = frame.contentInput
    if not scrollFrame or not editBox then return end

    local width = math.floor(scrollFrame:GetWidth() or 0)
    if width < 1 then return end

    editBox:SetWidth(width)
    scrollFrame:UpdateScrollChildRect()
    RefreshContentHitRect(frame)
end

local function CaptureBaseline(frame)
    frame.quickNoteBaseline = {
        title = frame.titleInput:GetText() or "",
        content = frame.contentInput:GetText() or "",
    }
    frame.isDirty = false
end

local function RefreshDirtyState(frame)
    local baseline = frame.quickNoteBaseline
    if frame.syncingQuickNote or not baseline then return end

    frame.isDirty = (frame.titleInput:GetText() or "") ~= baseline.title
        or (frame.contentInput:GetText() or "") ~= baseline.content
end

local function ResetQuickNote(frame)
    frame.syncingQuickNote = true
    frame.titleInput:SetText("")
    frame.contentInput:SetText("")
    frame.contentScroll:SetVerticalScroll(0)
    frame.syncingQuickNote = false
    ParchmentReader.PRUI.SetEditBoxInvalid(frame.contentInput, false)
    CaptureBaseline(frame)
    RefreshContentLayout(frame)
end

local function HideQuickNote(frame)
    frame.isDirty = false
    frame:Hide()
    ResetQuickNote(frame)
end

local function ShowDiscardConfirmation(frame)
    if frame.discardPopup and frame.discardPopup:IsShown() then return end
    frame.discardPopup = StaticPopup_Show(
        "PARCHMENTREADER_DISCARD_QUICK_NOTE", nil, nil, frame)
end

local function RequestQuickNoteClose(frame)
    if frame.isDirty then
        ShowDiscardConfirmation(frame)
    else
        HideQuickNote(frame)
    end
end

local function UpdateQuickNoteFrameLevel(frame)
    local readerLevel = ParchmentReaderFrame
        and ParchmentReaderFrame:GetFrameLevel() or 0
    frame:SetFrameLevel(math.max(
        QUICK_NOTE_MIN_FRAME_LEVEL,
        readerLevel + QUICK_NOTE_READER_LEVEL_OFFSET))
end

local function BuildUniqueTitle(collection, requestedTitle, timestamp)
    local baseTitle = Trim(requestedTitle)
    if baseTitle == "" then
        baseTitle = string.format(
            L["Note - %s"],
            date("%Y-%m-%d %H:%M", timestamp))
    end

    local title = baseTitle
    local suffix = 2
    while ParchmentReader.books[ParchmentReader:BookKey(collection, title)] do
        title = string.format("%s (%d)", baseTitle, suffix)
        suffix = suffix + 1
    end
    return title
end

function ParchmentReader:CreateQuickNoteFrame()
    local Theme = self.Theme
    local PRUI = self.PRUI
    local frame = PRUI.Window(UIParent, {
        name = "ParchmentReaderQuickNoteFrame",
        title = L["Quick Note"],
    })
    frame:SetSize(420, 340)
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    frame:SetFrameStrata("HIGH")
    UpdateQuickNoteFrameLevel(frame)
    self:RegisterEscapeClose("ParchmentReaderQuickNoteFrame")

    StaticPopupDialogs["PARCHMENTREADER_DISCARD_QUICK_NOTE"] = {
        text = L["Discard this quick note?"],
        button1 = L["Discard Changes"],
        button2 = L["Keep Editing"],
        OnAccept = function(_, quickNoteFrame)
            quickNoteFrame.discardPopup = nil
            HideQuickNote(quickNoteFrame)
        end,
        OnCancel = function(_, quickNoteFrame)
            quickNoteFrame.discardPopup = nil
            quickNoteFrame:Show()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    frame.closeButton:SetScript("OnClick", function()
        RequestQuickNoteClose(frame)
    end)

    local titleLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titleLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -50)
    titleLabel:SetText(L["Title (optional):"])
    PRUI.SetFontStringColor(titleLabel, Theme:Get("text", "secondary"))

    local titleInput, titleSurface = PRUI.EditBox(frame)
    titleSurface:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 0, -6)
    titleSurface:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    titleSurface:SetHeight(28)
    titleInput:SetMaxLetters(100)
    titleInput:SetScript("OnEscapePressed", function(input)
        input:ClearFocus()
    end)
    titleInput:HookScript("OnTextChanged", function()
        RefreshDirtyState(frame)
    end)
    frame.titleInput = titleInput

    local contentLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    contentLabel:SetPoint("TOPLEFT", titleSurface, "BOTTOMLEFT", 0, -14)
    contentLabel:SetText(L["Note:"])
    PRUI.SetFontStringColor(contentLabel, Theme:Get("text", "secondary"))

    local collectionHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    collectionHint:SetPoint("TOP", contentLabel, "TOP", 0, 0)
    collectionHint:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    collectionHint:SetJustifyH("RIGHT")
    collectionHint:SetText(L["Saved to Notes"])
    PRUI.SetFontStringColor(collectionHint, Theme:Get("text", "muted"))

    local contentSurface = PRUI.Panel(frame, {color = Theme:Get("bg", "surface")})
    contentSurface:SetPoint("TOPLEFT", contentLabel, "BOTTOMLEFT", 0, -6)
    contentSurface:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 56)
    frame.contentSurface = contentSurface

    local scrollFrame = CreateFrame(
        "ScrollFrame",
        "ParchmentReaderQuickNoteScrollFrame",
        contentSurface,
        "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", contentSurface, "TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", contentSurface, "BOTTOMRIGHT", -24, 8)
    PRUI.StyleScrollFrame(scrollFrame)
    frame.contentScroll = scrollFrame

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAllPoints(scrollFrame)
    editBox:SetFontObject("GameFontNormal")
    PRUI.SetFontStringColor(editBox, Theme:Get("text", "primary"))
    editBox:SetAutoFocus(false)
    editBox:EnableMouse(true)
    editBox:EnableKeyboard(true)
    if InCombatLockdown() then
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        editBox:SetPropagateKeyboardInput(false)
    end
    editBox:SetAltArrowKeyMode(false)
    local selectionColor = Theme:Get("accent", "gold")
    editBox:SetHighlightColor(
        selectionColor[1], selectionColor[2], selectionColor[3], 0.38)
    editBox.pruiContainer = contentSurface

    editBox:SetScript("OnEscapePressed", function(input)
        input:ClearFocus()
    end)
    editBox:SetScript("OnEditFocusGained", function()
        if not editBox.pruiInvalid then
            PRUI.SetBorderColor(contentSurface, Theme:Get("accent", "goldDim"))
        end
    end)
    editBox:SetScript("OnEditFocusLost", function()
        if not editBox.pruiInvalid then
            PRUI.SetBorderColor(contentSurface, Theme:Get("border", "subtle"))
        end
    end)
    editBox:SetScript("OnCursorChanged", function(_, _x, y, _cursorWidth, height)
        local cursorTop = -(y or 0)
        local cursorBottom = cursorTop + (height or 0)
        local scrollOffset = scrollFrame:GetVerticalScroll() or 0
        local viewportHeight = scrollFrame:GetHeight() or 0
        if cursorTop < scrollOffset then
            scrollFrame:SetVerticalScroll(cursorTop)
        elseif cursorBottom > scrollOffset + viewportHeight then
            scrollFrame:SetVerticalScroll(cursorBottom - viewportHeight)
        end
    end)
    editBox:SetScript("OnTextChanged", function(input)
        if input.pruiInvalid then
            PRUI.SetEditBoxInvalid(input, false)
        end
        RefreshContentLayout(frame)
        RefreshDirtyState(frame)
    end)

    scrollFrame:SetScrollChild(editBox)
    editBox:SetFrameLevel(scrollFrame:GetFrameLevel() + 1)
    frame.contentInput = editBox

    contentSurface:EnableMouse(true)
    contentSurface:SetScript("OnMouseDown", function()
        editBox:SetFocus()
    end)
    scrollFrame:SetScript("OnSizeChanged", function()
        RefreshContentLayout(frame)
    end)
    scrollFrame:HookScript("OnVerticalScroll", function()
        RefreshContentHitRect(frame)
    end)
    scrollFrame:HookScript("OnScrollRangeChanged", function()
        RefreshContentHitRect(frame)
    end)

    local saveButton = PRUI.Button(frame, L["Save"], {width = 104, height = 26})
    saveButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 16)
    PRUI.SetButtonTextColor(saveButton, Theme:Get("accent", "gold"))
    saveButton:SetScript("OnClick", function()
        ParchmentReader:SaveQuickNote()
    end)

    local cancelButton = PRUI.Button(frame, L["Cancel"], {width = 104, height = 26})
    cancelButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)
    cancelButton:SetScript("OnClick", function()
        RequestQuickNoteClose(frame)
    end)

    frame:HookScript("OnShow", function()
        RefreshContentLayout(frame)
    end)
    frame:SetScript("OnEvent", function(quickNoteFrame, event)
        if event == "PLAYER_REGEN_ENABLED" then
            quickNoteFrame.contentInput:SetPropagateKeyboardInput(false)
            quickNoteFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end
    end)
    frame:HookScript("OnHide", function()
        titleInput:ClearFocus()
        editBox:ClearFocus()
        if frame.isDirty then
            frame:Show()
            ShowDiscardConfirmation(frame)
        end
    end)

    frame.syncingQuickNote = false
    frame.isDirty = false
    ResetQuickNote(frame)
    frame:Hide()
    return frame
end

function ParchmentReader:ShowQuickNote()
    if not ParchmentReaderQuickNoteFrame then
        self:CreateQuickNoteFrame()
    end

    local frame = ParchmentReaderQuickNoteFrame
    UpdateQuickNoteFrameLevel(frame)
    frame:Show()
    RefreshContentLayout(frame)
    C_Timer.After(0, function()
        if frame:IsShown() then
            frame.contentInput:SetFocus()
        end
    end)
end

function ParchmentReader:SaveQuickNote()
    local frame = ParchmentReaderQuickNoteFrame
    if not frame then return end

    local content = frame.contentInput:GetText() or ""
    local contentInvalid = Trim(content) == ""
    self.PRUI.SetEditBoxInvalid(frame.contentInput, contentInvalid)
    if contentInvalid then
        self:PrintMessage("Please enter a note.")
        return
    end

    local now = time()
    local title = BuildUniqueTitle(
        QUICK_NOTE_COLLECTION,
        frame.titleInput:GetText(),
        now)
    local bookKey = self:BookKey(QUICK_NOTE_COLLECTION, title)

    if not CollectionExists(QUICK_NOTE_COLLECTION) then
        self:AddCollection(QUICK_NOTE_COLLECTION)
    end

    ParchmentReaderDB.customBooks = ParchmentReaderDB.customBooks or {}
    ParchmentReaderDB.customBooks[bookKey] = {
        content = content,
        collection = QUICK_NOTE_COLLECTION,
        createdAt = now,
        modifiedAt = now,
    }
    self.books[bookKey] = {
        title = title,
        content = content,
        totalPages = 1,
        custom = true,
        collection = QUICK_NOTE_COLLECTION,
    }

    if ParchmentReaderFrame then
        self:RefreshCollectionSelector()
        self:RefreshBookList()
    end

    HideQuickNote(frame)
end

function ParchmentReader_OpenQuickNote()
    if ParchmentReader then
        ParchmentReader:ShowQuickNote()
    end
end
