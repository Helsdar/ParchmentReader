


local L = ParchmentReader.L


local function FormatTimeAgo(timestamp)
    local delta = math.max(0, time() - timestamp)
    if delta < 60 then
        return L["just now"]
    elseif delta < 3600 then
        return ParchmentReader:LocalizePlural(
            "MINUTES_AGO", math.floor(delta / 60))
    elseif delta < 86400 then
        return ParchmentReader:LocalizePlural(
            "HOURS_AGO", math.floor(delta / 3600))
    else
        return ParchmentReader:LocalizePlural(
            "DAYS_AGO", math.floor(delta / 86400))
    end
end


local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function RefreshCharacterCount(frame)
    if not frame.characterCount or not frame.contentInput then return end
    local count = ParchmentReader:CountUTF8Characters(frame.contentInput:GetText())
    frame.characterCount:SetText(
        ParchmentReader:LocalizePlural("CHARACTER_COUNT", count))
end

local function RefreshEditorDirtyState(frame)
    local baseline = frame.editorBaseline
    if frame.syncingEditor or not baseline then return end

    frame.isDirty = (frame.titleInput:GetText() or "") ~= baseline.title
        or (frame.contentInput:GetText() or "") ~= baseline.content
        or frame.selectedCollection ~= baseline.collection
end

local function CaptureEditorBaseline(frame)
    frame.editorBaseline = {
        title = frame.titleInput:GetText() or "",
        content = frame.contentInput:GetText() or "",
        collection = frame.selectedCollection,
    }
    frame.savedBookBaseline = ParchmentReader:CaptureSavedBookBaseline(frame.editingBook)
    frame.isDirty = false
    RefreshCharacterCount(frame)
end

local function ClearPendingEditorAction(frame)
    frame.pendingEditorAction = nil
    frame.pendingBookKey = nil
end

local function InvalidateEditorConfirmations(frame)
    local discardPopup, deletePopup = frame.discardPopup, frame.deletePopup

    frame.draftGeneration = (frame.draftGeneration or 0) + 1
    frame.discardPopup, frame.deletePopup = nil, nil
    frame.pendingDiscardData, frame.pendingDeleteData = nil, nil
    ClearPendingEditorAction(frame)
    if discardPopup then discardPopup:Hide() end
    if deletePopup then deletePopup:Hide() end
end

local function ShowDiscardConfirmation(frame, action, bookKey)
    frame.pendingEditorAction = action or "close"
    frame.pendingBookKey = bookKey
    if frame.discardPopup and frame.discardPopup:IsShown() then return end

    frame.pendingDiscardData = {editorFrame = frame, generation = frame.draftGeneration}
    frame.discardPopup = StaticPopup_Show(
        "PARCHMENTREADER_DISCARD_CHANGES", nil, nil, frame.pendingDiscardData)
end

local function RequestEditorClose(frame)
    if frame.isDirty then
        ShowDiscardConfirmation(frame)
    else
        InvalidateEditorConfirmations(frame)
        frame:Hide()
    end
end

local function RefreshContentInputHitRect(frame)
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

local function RefreshContentInputLayout(frame)
    local scrollFrame = frame.contentScroll
    local editBox = frame.contentInput
    if not scrollFrame or not editBox then return end

    local width = math.floor(scrollFrame:GetWidth() or 0)
    if width < 1 then return end

    editBox:SetWidth(width)
    scrollFrame:UpdateScrollChildRect()
    RefreshContentInputHitRect(frame)
end

local function ResetContentInputState(frame)
    local editBox = frame.contentInput
    if not editBox then return end

    editBox:ClearHighlightText()
    editBox:SetCursorPosition(0)
    editBox:ClearFocus()
    if frame.contentScroll then
        frame.contentScroll:SetVerticalScroll(0)
    end
end


local function BuildCollectionPickerItems()
    local items = {{text = L["No Collection"], pinned = true}}
    for _, name in ipairs(ParchmentReaderDB.collections or {}) do
        items[#items + 1] = {text = name, value = name}
    end
    return items
end

function ParchmentReader:CreateBookEditorFrame()
    local Theme = self.Theme
    local PRUI = self.PRUI
    local frame = PRUI.Window(UIParent, {
        name = "ParchmentReaderEditorFrame",
        title = L["Add Book"],
    })
    frame:SetSize(540, 500)
    frame.draftGeneration = 0
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    PRUI.SetAddonFrameLayer(frame, PRUI.ADDON_FRAME_LEVELS.WINDOW)
    frame:SetToplevel(true)
    self:RegisterEscapeClose("ParchmentReaderEditorFrame")

    StaticPopupDialogs["PARCHMENTREADER_DISCARD_CHANGES"] = {
        text = L["Discard unsaved changes?"],
        button1 = L["Discard Changes"],
        button2 = L["Keep Editing"],
        OnAccept = function(_, data)
            local editorFrame = data.editorFrame
            if editorFrame.draftGeneration ~= data.generation
                or editorFrame.pendingDiscardData ~= data then return end
            local action = editorFrame.pendingEditorAction or "close"
            local pendingBookKey = editorFrame.pendingBookKey
            InvalidateEditorConfirmations(editorFrame)
            editorFrame.isDirty = false
            if action == "open" then
                ParchmentReader:ShowBookEditor(pendingBookKey)
            else
                editorFrame:Hide()
            end
        end,
        OnCancel = function(_, data)
            local editorFrame = data.editorFrame
            if editorFrame.draftGeneration ~= data.generation
                or editorFrame.pendingDiscardData ~= data then return end
            editorFrame.discardPopup = nil
            editorFrame.pendingDiscardData = nil
            ClearPendingEditorAction(editorFrame)
            editorFrame:Show()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopupDialogs["PARCHMENTREADER_DELETE"] = {
        text = L["Delete book “%s”?"],
        button1 = L["Delete"],
        button2 = L["Cancel"],
        OnAccept = function(_, data)
            local bookKey = data.bookKey
            local editorFrame = data.editorFrame
            if editorFrame.draftGeneration ~= data.generation
                or editorFrame.pendingDeleteData ~= data then return end
            InvalidateEditorConfirmations(editorFrame)


            if ParchmentReaderDB.customBooks then
                ParchmentReaderDB.customBooks[bookKey] = nil
            end
            if ParchmentReaderDB.bookPages then
                ParchmentReaderDB.bookPages[bookKey] = nil
            end
            ParchmentReader:DeleteReadingPosition(bookKey)
            ParchmentReader:DeleteLibraryViewBook(bookKey)


            ParchmentReader.books[bookKey] = nil
            if ParchmentReaderDB.lastQuickNote == bookKey then
                ParchmentReaderDB.lastQuickNote = nil
            end
            if ParchmentReader.RefreshQuickNoteResumeRow then
                ParchmentReader:RefreshQuickNoteResumeRow()
            end
            if ParchmentReaderDB.selectedBook == bookKey then
                ParchmentReaderDB.selectedBook = nil
            end


            if ParchmentReader.currentBook == bookKey then
                ParchmentReader.currentBook = nil
                ParchmentReader.currentPage = 1
                ParchmentReader.currentReadingOffset = 0
                ParchmentReader.readerLayoutMetrics = nil
                if ParchmentReaderFrame then
                    ParchmentReaderFrame.title:SetText("")
                    ParchmentReader:UpdateReader()
                end
            end


            if ParchmentReaderFrame then
                ParchmentReader:RefreshBookList()
            end

            editorFrame.isDirty = false
            editorFrame:Hide()
        end,
        OnCancel = function(_, data)
            local editorFrame = data.editorFrame
            if editorFrame.draftGeneration ~= data.generation
                or editorFrame.pendingDeleteData ~= data then return end
            editorFrame.pendingDeleteData = nil
            editorFrame.deletePopup = nil
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    frame.closeButton:SetScript("OnClick", function()
        RequestEditorClose(frame)
    end)

    local helpButton = PRUI.IconButton(frame.topbar, nil, L["Keyboard Help"], {
        width = 24,
        height = 24,
        iconText = "?",
        fontObject = "GameFontNormalSmall",
    })
    helpButton:SetPoint("RIGHT", frame.closeButton, "LEFT", -4, 0)
    helpButton:SetScript("OnClick", function()
        frame.titleInput:ClearFocus()
        frame.contentInput:ClearFocus()
        ParchmentReader:ToggleKeyboardHelp()
    end)
    frame.helpButton = helpButton
    frame.title:ClearAllPoints()
    frame.title:SetPoint("LEFT", frame.topbar, "LEFT", 12, 0)
    frame.title:SetPoint("RIGHT", helpButton, "LEFT", -8, 0)


    local titleLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    titleLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -50)
    titleLabel:SetText(L["Book Title:"])
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
        RefreshEditorDirtyState(frame)
    end)
    frame.titleInput = titleInput


    local collLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    collLabel:SetPoint("TOPLEFT", titleSurface, "BOTTOMLEFT", 0, -14)
    collLabel:SetText(L["Collection:"])
    PRUI.SetFontStringColor(collLabel, Theme:Get("text", "secondary"))
    frame.collLabel = collLabel

    local collectionPicker = PRUI.Dropdown(frame, {
        popoverName = "ParchmentReaderEditorCollectionPopover",
        items = BuildCollectionPickerItems(), getItems = BuildCollectionPickerItems,
        searchable = true, searchThreshold = 8, maxRows = 8,
        onValueChanged = function(value)
            frame.selectedCollection = value
            RefreshEditorDirtyState(frame)
        end,
    })
    collectionPicker:SetPoint("LEFT", collLabel, "RIGHT", 8, 0)
    collectionPicker:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    frame.collectionPicker = collectionPicker
    frame.selectedCollection = nil


    local contentLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    contentLabel:SetPoint("TOPLEFT", collLabel, "BOTTOMLEFT", 0, -24)
    contentLabel:SetText(L["Book Content:"])
    PRUI.SetFontStringColor(contentLabel, Theme:Get("text", "secondary"))

    local characterCount = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    characterCount:SetPoint("TOP", contentLabel, "TOP", 0, 0)
    characterCount:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    characterCount:SetJustifyH("RIGHT")
    PRUI.SetFontStringColor(characterCount, Theme:Get("text", "muted"))
    frame.characterCount = characterCount


    local contentSurface = PRUI.Panel(frame, {color = Theme:Get("bg", "surface")})
    contentSurface:SetPoint("TOPLEFT", contentLabel, "BOTTOMLEFT", 0, -6)
    contentSurface:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 56)
    PRUI.ApplyPaperSurface(contentSurface)
    frame.contentSurface = contentSurface

    local scrollFrame = CreateFrame(
        "ScrollFrame", "BookEditorScrollFrame", contentSurface, "UIPanelScrollFrameTemplate")
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
        RefreshContentInputLayout(frame)
        RefreshCharacterCount(frame)
        RefreshEditorDirtyState(frame)
    end)

    scrollFrame:SetScrollChild(editBox)
    editBox:SetFrameLevel(scrollFrame:GetFrameLevel() + 1)
    frame.contentInput = editBox

    local function FocusContentInput()
        if editBox:IsEnabled() then
            editBox:SetFocus()
        end
    end

    contentSurface:EnableMouse(true)
    contentSurface:SetScript("OnMouseDown", FocusContentInput)
    scrollFrame:SetScript("OnSizeChanged", function()
        RefreshContentInputLayout(frame)
    end)
    scrollFrame:HookScript("OnVerticalScroll", function()
        RefreshContentInputHitRect(frame)
    end)
    scrollFrame:HookScript("OnScrollRangeChanged", function()
        RefreshContentInputHitRect(frame)
    end)
    frame:HookScript("OnShow", function()
        RefreshContentInputLayout(frame)
    end)
    frame:SetScript("OnEvent", function(editorFrame, event)
        if event == "PLAYER_REGEN_ENABLED" then
            editorFrame.contentInput:SetPropagateKeyboardInput(false)
            editorFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
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


    local saveBtn = PRUI.Button(frame, L["Save Book"], {width = 132, height = 26})
    saveBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 16)
    PRUI.SetButtonTextColor(saveBtn, Theme:Get("accent", "gold"))
    saveBtn:SetScript("OnClick", function()
        ParchmentReader:SaveBook()
    end)


    local deleteBtn = PRUI.Button(frame, L["Delete"], {width = 104, height = 26})
    deleteBtn:SetPoint("LEFT", saveBtn, "RIGHT", 8, 0)
    PRUI.SetButtonTextColor(deleteBtn, Theme:Get("state", "danger"))
    deleteBtn:SetScript("OnClick", function()
        ParchmentReader:DeleteBook()
    end)
    frame.deleteBtn = deleteBtn


    local cancelBtn = PRUI.Button(frame, L["Cancel"], {width = 104, height = 26})
    cancelBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)
    cancelBtn:SetScript("OnClick", function()
        RequestEditorClose(frame)
    end)


    local statusLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusLabel:SetPoint("LEFT", deleteBtn, "RIGHT", 10, 0)
    statusLabel:SetPoint("RIGHT", cancelBtn, "LEFT", -10, 0)
    statusLabel:SetJustifyH("CENTER")
    PRUI.SetFontStringColor(statusLabel, Theme:Get("text", "muted"))
    frame.statusLabel = statusLabel

    frame:Hide()
    return frame
end

local function RefreshCollectionPicker(frame, activeCollection)
    local items = BuildCollectionPickerItems()
    frame.selectedCollection = activeCollection
    frame.collectionPicker.popover:Hide()
    frame.collectionPicker:SetItems(items)
    frame.collectionPicker:SetValue(activeCollection, true)
end

function ParchmentReader:RefreshEditorCollections()
    local frame = ParchmentReaderEditorFrame
    if not frame or not frame.collectionPicker then return end
    local items = BuildCollectionPickerItems()

    frame.collectionPicker:SetItems(items)
    frame.collectionPicker:SetValue(frame.selectedCollection, true)
    RefreshEditorDirtyState(frame)
end

function ParchmentReader:ShowBookEditor(bookKey)
    local quick = ParchmentReaderQuickNoteFrame
    if bookKey and quick and quick:IsShown() and quick.editingBook == bookKey then
        self:ShowQuickNote()
        return
    end
    local existing = ParchmentReaderEditorFrame
    if bookKey and existing and existing:IsShown() and existing.editingBook == bookKey then
        existing:Raise()
        return
    end
    if bookKey then
        local book = self.books[bookKey]
        if not book then
            self:PrintMessage("Book not found.")
            return
        end
    end

    if not ParchmentReaderEditorFrame then
        self:CreateBookEditorFrame()
    end

    local frame = ParchmentReaderEditorFrame
    if frame:IsShown() and frame.isDirty then
        ShowDiscardConfirmation(frame, "open", bookKey)
        return
    end

    InvalidateEditorConfirmations(frame)
    frame.quickNoteSave = nil
    frame.editingBook = bookKey
    frame.syncingEditor = true

    if bookKey then

        local book = self.books[bookKey]
        local displayTitle = book and book.title or bookKey
        frame.title:SetText(string.format(L["Edit Book: %s"], displayTitle))
        frame.titleInput:SetText(displayTitle)
        frame.titleInput:Enable()

        if book then
            frame.contentInput:SetText(book.content)
            ResetContentInputState(frame)
            RefreshCollectionPicker(frame, book.collection)
        else
            RefreshCollectionPicker(frame, nil)
        end

        local saved = ParchmentReaderDB.customBooks and ParchmentReaderDB.customBooks[bookKey]
        local modifiedAt = saved and saved.modifiedAt
        if modifiedAt then
            frame.statusLabel:SetText(string.format(
                L["Modified: %s"], FormatTimeAgo(modifiedAt)))
            frame.statusLabel:Show()
        else
            frame.statusLabel:Hide()
        end

        frame.deleteBtn:Show()
    else

        frame.title:SetText(L["Add Book"])
        frame.titleInput:SetText("")
        frame.titleInput:Enable()
        frame.contentInput:SetText("")
        ResetContentInputState(frame)

        RefreshCollectionPicker(frame, ParchmentReader.currentCollection)
        frame.statusLabel:Hide()
        frame.deleteBtn:Hide()
    end

    frame.syncingEditor = false
    CaptureEditorBaseline(frame)

    frame:Show()
    frame:Raise()
    RefreshContentInputLayout(frame)
end

function ParchmentReader:SaveBook()
    local frame = ParchmentReaderEditorFrame
    local title = trim(frame.titleInput:GetText() or "")
    local content = frame.contentInput:GetText()
    local titleInvalid = title == ""
    local contentInvalid = not content or trim(content) == ""
    self.PRUI.SetEditBoxInvalid(frame.titleInput, titleInvalid)
    self.PRUI.SetEditBoxInvalid(frame.contentInput, contentInvalid)

    if titleInvalid then
        self:PrintMessage("Please enter a book title.")
        return
    end

    if contentInvalid then
        self:PrintMessage("Please enter book content.")
        return
    end

    local ok, newKey, reason = self:SaveCustomBook(
        frame.editingBook, title, content, frame.selectedCollection, frame.savedBookBaseline)
    if not ok then
        if reason == "duplicate" then self.PRUI.SetEditBoxInvalid(frame.titleInput, true) end
        return
    end
    if frame.quickNoteSave then ParchmentReaderDB.lastQuickNote = newKey end
    if self.RefreshQuickNoteResumeRow then self:RefreshQuickNoteResumeRow() end
    frame.isDirty = false
    InvalidateEditorConfirmations(frame)
    frame:Hide()
end


function ParchmentReader:SaveCustomBook(oldKey, title, content, collection, baseline)
    if collection ~= nil then
        local found = false
        for _, name in ipairs(ParchmentReaderDB.collections or {}) do
            if name == collection then found = true; break end
        end
        if not found then
            self:PrintMessage("The selected collection no longer exists. Choose another collection.")
            return false
        end
    end
    local newKey = self:BookKey(collection, title)
    local savedBooks = ParchmentReaderDB.customBooks or {}
    local oldBook = oldKey and self.books[oldKey]
    if oldKey and not oldBook then
        self:PrintMessage(baseline and "This book changed or was deleted. Your draft has been kept." or "Book not found.")
        return false
    end


    if oldKey ~= newKey and (self.books[newKey] or savedBooks[newKey]) then
        self:PrintMessage(
            "A book with this title already exists in the selected collection.")
        return false, nil, "duplicate"
    end

    if oldKey and baseline and not self:SavedBookMatchesBaseline(oldKey, baseline) then
        self:PrintMessage("This book changed or was deleted. Your draft has been kept.")
        return false
    end

    local oldSaved = oldKey and savedBooks[oldKey]
    local createdAt = type(oldSaved) == "table" and oldSaved.createdAt or nil
    local rekeyed = oldKey and oldKey ~= newKey
    local contentChanged = oldBook and oldBook.content ~= content

    if oldKey and self.currentBook == oldKey then


        self:SyncReadingPosition()
        if rekeyed or contentChanged then
            self:CancelReaderJumpRequests()
        end
        if contentChanged then
            self:EndContentSearchNavigation(true)
            if rekeyed then
                self.currentReadingOffset = self:ResolveReadingPosition(
                    self:NormalizeLayoutText(content),
                    self:GetSavedReadingPosition(oldKey)) or self.currentReadingOffset
            end
        elseif rekeyed and self.readerSearchNavigation
            and self.readerSearchNavigation.bookKey == oldKey
        then
            self.readerSearchNavigation.bookKey = newKey
        end
    end

    if rekeyed then
        savedBooks[oldKey] = nil
        self.books[oldKey] = nil
        if ParchmentReaderDB.bookPages and ParchmentReaderDB.bookPages[oldKey] then
            ParchmentReaderDB.bookPages[newKey] = ParchmentReaderDB.bookPages[oldKey]
            ParchmentReaderDB.bookPages[oldKey] = nil
        end
        self:MoveReadingPosition(oldKey, newKey)
        self:RekeyLibraryViewBook(oldKey, newKey)
        if ParchmentReaderDB.selectedBook == oldKey then
            ParchmentReaderDB.selectedBook = newKey
        end
        if self.currentBook == oldKey then
            self.currentBook = newKey
        end
    end


    ParchmentReaderDB.customBooks = savedBooks
    local now = time()
    ParchmentReaderDB.customBooks[newKey] = {
        content    = content,
        collection = collection,
        createdAt  = createdAt or now,
        modifiedAt = now,
        revision = (type(oldSaved) == "table" and oldSaved.revision or 0) + 1,
    }


    self.books[newKey] = {
        title      = title,
        content    = content,
        totalPages = 1,
        custom     = true,
        collection = collection,
    }

    if rekeyed then self:RekeyOpenBookReferences(oldKey, newKey) end


    if ParchmentReaderFrame then
        ParchmentReader:RefreshBookList()
    end


    if ParchmentReaderFrame and ParchmentReaderFrame:IsShown() then
        if self.currentBook == newKey then
            self:UpdateReader(rekeyed and "book-key-changed" or nil)
        end
    end
    if self.RefreshQuickNoteResumeRow then self:RefreshQuickNoteResumeRow() end
    return true, newKey
end

function ParchmentReader:DeleteBook()
    local frame = ParchmentReaderEditorFrame
    local bookKey = frame.editingBook

    if not bookKey then return end

    local book = self.books[bookKey]
    local displayTitle = book and book.title or bookKey

    if frame.deletePopup and frame.deletePopup:IsShown() then return end
    frame.pendingDeleteData = {bookKey = bookKey, editorFrame = frame,
        generation = frame.draftGeneration}
    frame.deletePopup = StaticPopup_Show(
        "PARCHMENTREADER_DELETE", displayTitle, nil, frame.pendingDeleteData)
end
