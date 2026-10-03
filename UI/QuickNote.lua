


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
    local popup = frame.discardPopup
    frame.discardPopup = nil
    frame.pendingQuickNoteAction = nil

    frame.draftGeneration = (frame.draftGeneration or 0) + 1
    if popup then popup:Hide() end
    frame.editingBook = nil
    frame.savedBookBaseline = nil
    frame.syncingQuickNote = true
    frame.titleInput:SetText("")
    frame.contentInput:SetText("")
    frame.contentScroll:SetVerticalScroll(0)
    frame.syncingQuickNote = false
    ParchmentReader.PRUI.SetEditBoxInvalid(frame.titleInput, false)
    ParchmentReader.PRUI.SetEditBoxInvalid(frame.contentInput, false)
    CaptureBaseline(frame)
    RefreshContentLayout(frame)
    if ParchmentReader.RefreshQuickNoteResumeRow then ParchmentReader:RefreshQuickNoteResumeRow() end
end

local function HideQuickNote(frame)
    frame.isDirty = false
    frame:Hide()
    ResetQuickNote(frame)
end

local function ShowDiscardConfirmation(frame, action)
    frame.pendingQuickNoteAction = action or "close"
    if frame.discardPopup and frame.discardPopup:IsShown() then return end
    frame.discardPopup = StaticPopup_Show(
        "PARCHMENTREADER_DISCARD_QUICK_NOTE", nil, nil,
        {frame = frame, generation = frame.draftGeneration})
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
    frame:SetSize(420, 380)
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    PRUI.SetAddonFrameLayer(frame, PRUI.ADDON_FRAME_LEVELS.WINDOW)
    UpdateQuickNoteFrameLevel(frame)
    self:RegisterEscapeClose("ParchmentReaderQuickNoteFrame")

    StaticPopupDialogs["PARCHMENTREADER_DISCARD_QUICK_NOTE"] = {
        text = L["Discard this quick note?"],
        button1 = L["Discard Changes"],
        button2 = L["Keep Editing"],
        OnAccept = function(_, data)
            local quickNoteFrame = data.frame
            if quickNoteFrame.draftGeneration ~= data.generation then return end
            quickNoteFrame.discardPopup = nil
            local action = quickNoteFrame.pendingQuickNoteAction
            quickNoteFrame.pendingQuickNoteAction = nil
            HideQuickNote(quickNoteFrame)
            if action == "resume" then ParchmentReader:ResumeLastQuickNote()
            elseif action == "new" then ParchmentReader:ShowQuickNote() end
        end,
        OnCancel = function(_, data)
            local quickNoteFrame = data.frame
            if quickNoteFrame.draftGeneration ~= data.generation then return end
            quickNoteFrame.discardPopup = nil
            quickNoteFrame.pendingQuickNoteAction = nil
            quickNoteFrame:Show()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    frame.closeButton:SetScript("OnClick", function()
        RequestQuickNoteClose(frame)
    end)

    local resumeButton = PRUI.Button(frame, L["Resume"], {width = 148, height = 24})
    resumeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -46)
    resumeButton:SetScript("OnClick", function()
        if not frame.editingBook then ParchmentReader:ResumeLastQuickNote(); return end
        if frame.isDirty then ShowDiscardConfirmation(frame, "new")
        else
            ResetQuickNote(frame)
            ParchmentReader:ShowQuickNote()
            frame.titleInput:ClearFocus()
            frame.contentInput:SetFocus()
        end
    end)
    frame.resumeButton = resumeButton
    local resumeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    resumeLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -52)
    resumeLabel:SetPoint("RIGHT", resumeButton, "LEFT", -10, 0)
    resumeLabel:SetJustifyH("LEFT")
    resumeLabel:SetWordWrap(false)
    PRUI.SetFontStringColor(resumeLabel, Theme:Get("text", "secondary"))
    PRUI.AttachTooltip(resumeButton, function()
        return frame.editingBook and L["New Note"] or L["Resume Last Quick Note"]
    end)
    local resumeHit = CreateFrame("Frame", nil, frame)
    resumeHit:SetAllPoints(resumeLabel)
    resumeHit:EnableMouse(true)
    PRUI.AttachTooltip(resumeHit, function()
        local book = frame.editingBook and ParchmentReader.books[frame.editingBook]
            or ParchmentReader:GetLastQuickNote()
        return book and book.title or L["No saved quick note yet."]
    end)
    frame.resumeLabel = resumeLabel

    local titleLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titleLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -90)
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
    frame.titleLabel = titleLabel

    local contentLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    contentLabel:SetPoint("TOPLEFT", titleSurface, "BOTTOMLEFT", 0, -14)
    contentLabel:SetText(L["Note:"])
    PRUI.SetFontStringColor(contentLabel, Theme:Get("text", "secondary"))

    local collectionHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    collectionHint:SetPoint("TOPLEFT", contentLabel, "TOPRIGHT", 8, 0)
    collectionHint:SetWordWrap(false)
    collectionHint:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    collectionHint:SetJustifyH("RIGHT")
    collectionHint:SetText(L["Saved to Notes"])
    frame.collectionHint = collectionHint
    local collectionHit = CreateFrame("Frame", nil, frame)
    collectionHit:SetAllPoints(collectionHint)
    collectionHit:EnableMouse(true)
    PRUI.AttachTooltip(collectionHit, function() return collectionHint:GetText() end)
    PRUI.SetFontStringColor(collectionHint, Theme:Get("text", "muted"))

    local contentSurface = PRUI.Panel(frame, {color = Theme:Get("bg", "surface")})
    contentSurface:SetPoint("TOPLEFT", contentLabel, "BOTTOMLEFT", 0, -6)
    contentSurface:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 56)
    PRUI.ApplyPaperSurface(contentSurface)
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
    Theme:BindColor(editBox, "SetHighlightColor", selectionColor, 0.38)
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
        if editBox.pruiRefreshingThemeInk then return end
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

    local saveButton = PRUI.Button(frame, L["Save"], {width = 176, height = 26})
    saveButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 16)
    PRUI.SetButtonTextColor(saveButton, Theme:Get("accent", "gold"))
    frame.saveButton = saveButton
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

function ParchmentReader:GetLastQuickNote()
    local key = ParchmentReaderDB.lastQuickNote
    local book = key and self.books[key]
    local saved = key and ParchmentReaderDB.customBooks and ParchmentReaderDB.customBooks[key]
    if key and (not book or not book.custom or not saved) then
        ParchmentReaderDB.lastQuickNote = nil
        return nil
    end
    return book, key
end

function ParchmentReader:RefreshQuickNoteResumeRow()
    local frame = ParchmentReaderQuickNoteFrame
    if not frame or not frame.resumeLabel then return end
    local book = self:GetLastQuickNote()
    local editing = frame.editingBook and self.books[frame.editingBook]
    frame.resumeLabel:SetText(frame.editingBook
        and string.format(L["Editing: %s"], editing and editing.title or frame.titleInput:GetText())
        or (book and string.format(L["Last note: %s"], book.title) or L["No saved quick note yet."]))
    frame.resumeButton:SetText(frame.editingBook and L["New Note"] or L["Resume"])
    if book or frame.editingBook then frame.resumeButton:Enable() else frame.resumeButton:Disable() end
    frame.title:SetText(frame.editingBook and L["Editing Quick Note"] or L["Quick Note"])
    frame.titleLabel:SetText(frame.editingBook and L["Title:"] or L["Title (optional):"])
    frame.saveButton:SetText(frame.editingBook and L["Save Changes"] or L["Save"])
    frame.collectionHint:SetText(frame.editingBook
        and string.format(L["Collection: %s"], editing and editing.collection or L["No Collection"])
        or L["Saved to Notes"])
end

function ParchmentReader:ShowQuickNote()
    if not ParchmentReaderQuickNoteFrame then self:CreateQuickNoteFrame() end
    local frame = ParchmentReaderQuickNoteFrame
    UpdateQuickNoteFrameLevel(frame)
    self:RefreshQuickNoteResumeRow()
    local alreadyShown = frame:IsShown()
    frame:Show()
    frame:Raise()
    RefreshContentLayout(frame)
    if alreadyShown then return end
    local generation = frame.draftGeneration
    C_Timer.After(0, function()
        if frame:IsShown() and frame.draftGeneration == generation then
            frame.contentInput:SetFocus()
        end
    end)
end

function ParchmentReader:ResumeLastQuickNote()
    local book, key = self:GetLastQuickNote()
    if not book then
        self:ShowQuickNote()
        return
    end
    local editor = ParchmentReaderEditorFrame
    if editor and editor:IsShown() and editor.editingBook == key then
        editor.quickNoteSave = true
        editor:Raise()
        return
    end
    if not ParchmentReaderQuickNoteFrame then self:CreateQuickNoteFrame() end
    local frame = ParchmentReaderQuickNoteFrame
    if frame.editingBook == key then
        self:ShowQuickNote()
        return
    end
    if frame.isDirty then
        ShowDiscardConfirmation(frame, "resume")
        return
    end
    ResetQuickNote(frame)
    frame.editingBook = key
    frame.savedBookBaseline = self:CaptureSavedBookBaseline(key)
    frame.syncingQuickNote = true
    frame.titleInput:SetText(book.title)
    frame.contentInput:SetText(book.content)
    frame.syncingQuickNote = false
    CaptureBaseline(frame)
    self:ShowQuickNote()
    local generation = frame.draftGeneration
    C_Timer.After(0, function()
        if frame:IsShown() and frame.draftGeneration == generation and frame.editingBook == key then
            frame.contentInput:SetFocus()
            frame.contentInput:SetCursorPosition(#frame.contentInput:GetText())
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

    if frame.editingBook then
        local title = Trim(frame.titleInput:GetText())
        self.PRUI.SetEditBoxInvalid(frame.titleInput, title == "")
        if title == "" then self:PrintMessage("Please enter a book title."); return end
        local baseline = frame.savedBookBaseline
        local ok, key, reason = self:SaveCustomBook(frame.editingBook, title, content,
            baseline and baseline.collection, baseline)
        if not ok then
            if reason == "duplicate" then self.PRUI.SetEditBoxInvalid(frame.titleInput, true) end
            return
        end
        ParchmentReaderDB.lastQuickNote = key
        HideQuickNote(frame)
        return
    end

    local now = time()
    local title = BuildUniqueTitle(
        QUICK_NOTE_COLLECTION,
        frame.titleInput:GetText(),
        now)

    if not CollectionExists(QUICK_NOTE_COLLECTION) then
        self:AddCollection(QUICK_NOTE_COLLECTION)
    end

    local ok, savedKey = self:SaveCustomBook(nil, title, content, QUICK_NOTE_COLLECTION)
    if not ok then return end
    ParchmentReaderDB.lastQuickNote = savedKey
    if ParchmentReaderFrame then self:RefreshCollectionSelector() end

    HideQuickNote(frame)
end

function ParchmentReader_OpenQuickNote()
    if ParchmentReader then
        ParchmentReader:ShowQuickNote()
    end
end

function ParchmentReader_ResumeLastQuickNote()
    if ParchmentReader then ParchmentReader:ResumeLastQuickNote() end
end
