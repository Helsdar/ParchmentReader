




ParchmentReader = ParchmentReader or {}
ParchmentReader.books              = {}
ParchmentReader.currentBook        = nil
ParchmentReader.currentPage        = 1
ParchmentReader.currentReadingOffset = 0
ParchmentReader.currentCollection  = nil
ParchmentReader.DEFAULT_LAUNCHER_X = 320
ParchmentReader.DEFAULT_LAUNCHER_Y = 0
local L = ParchmentReader.L

BINDING_HEADER_PARCHMENT_READER = L["Parchment Reader"]
BINDING_NAME_PARCHMENTREADER_TOGGLE_READER = L["Show / Hide Reader"]
BINDING_NAME_PARCHMENTREADER_TOGGLE_MINIMIZE = L["Minimize / Restore Reader"]
BINDING_NAME_PARCHMENTREADER_QUICK_NOTE = L["Open Quick Note"]

local SEP = "\0"
local LEGACY_BUILTIN_PREFIX = "builtin:"

function ParchmentReader:BookKey(collection, title)
    return (collection or "") .. SEP .. title
end

function ParchmentReader:ParseBookKey(key)
    local sepPos = key:find(SEP, 1, true)
    if not sepPos then return nil, key end
    local col = key:sub(1, sepPos - 1)
    local title = key:sub(sepPos + 1)
    if col == "" then col = nil end
    return col, title
end

function ParchmentReader:CountUTF8Characters(text)
    local value = text or ""
    local _, continuationBytes = value:gsub("[\128-\191]", "")
    return #value - continuationBytes
end


local DEFAULTS = {
    hide            = false,
    windowWidth     = 760,
    windowHeight    = 520,
    minimapAngle    = 315,
    fontSize        = 14,
    fontName        = "ChatFontNormal",
    sidebarCollapsed = false,
    transparencyMode = "off",
    floatingLauncherX = ParchmentReader.DEFAULT_LAUNCHER_X,
    floatingLauncherY = ParchmentReader.DEFAULT_LAUNCHER_Y,
    floatingLauncherLocked = false,
}

local TRANSPARENCY_MODES = {
    off = true,
    always = true,
    smart = true,
}

function ParchmentReader:NormalizeTransparencyMode(mode)
    if TRANSPARENCY_MODES[mode] then return mode end
    return DEFAULTS.transparencyMode
end

local function ApplyDefaults(t)
    for k, v in pairs(DEFAULTS) do
        if t[k] == nil then t[k] = v end
    end
end

local function MoveSelectedBook(oldKey, newKey)
    if ParchmentReaderDB and ParchmentReaderDB.selectedBook == oldKey then
        ParchmentReaderDB.selectedBook = newKey
    end
end


local function MigrateCustomBooks()
    if ParchmentReaderDB.customBooksVersion then return end

    local old = ParchmentReaderDB.customBooks
    if old then
        local new = {}
        for title, data in pairs(old) do
            local collection = nil
            if type(data) == "table" then
                collection = data.collection
            elseif type(data) == "string" then
                data = { content = data, collection = nil }
            end
            local key = ParchmentReader:BookKey(collection, title)
            new[key] = data
        end
        ParchmentReaderDB.customBooks = new
    end

    local oldPages = ParchmentReaderDB.bookPages
    if oldPages then
        local newPages = {}
        for title, page in pairs(oldPages) do

            local collection = nil
            local bookData = ParchmentReaderDB.customBooks or {}
            for key, data in pairs(bookData) do
                local _, t = ParchmentReader:ParseBookKey(key)
                if t == title then
                    collection = type(data) == "table" and data.collection or nil
                    break
                end
            end
            newPages[ParchmentReader:BookKey(collection, title)] = page
        end
        ParchmentReaderDB.bookPages = newPages
    end

    ParchmentReaderDB.customBooksVersion = 2
end

local function MoveSavedBookValue(values, oldKey, newKey)
    if type(values) ~= "table" or oldKey == newKey then return end
    if values[newKey] == nil then
        values[newKey] = values[oldKey]
    end
    values[oldKey] = nil
end

local function ClearSavedBookState(bookKey)
    if ParchmentReaderDB.bookPages then
        ParchmentReaderDB.bookPages[bookKey] = nil
    end
    if ParchmentReaderDB.bookPositions then
        ParchmentReaderDB.bookPositions[bookKey] = nil
    end
    if ParchmentReaderDB.bookmarks then
        ParchmentReaderDB.bookmarks[bookKey] = nil
    end
    if ParchmentReaderDB.selectedBook == bookKey then
        ParchmentReaderDB.selectedBook = nil
    end
end

local function SeedStarterBooks()
    if ParchmentReaderDB.starterBooksSeeded == true then return end

    local starterBooks = ParchmentReader.starterBooks
    if type(starterBooks) ~= "table" or #starterBooks == 0 then return end

    local now = time()
    for _, starterBook in ipairs(starterBooks) do
        local title = starterBook.title
        local content = starterBook.content
        if type(title) == "string" and title ~= ""
            and type(content) == "string" and content ~= ""
        then
            local newKey = ParchmentReader:BookKey(nil, title)
            local legacyTitle = starterBook.legacyTitle or title
            local legacyKey = LEGACY_BUILTIN_PREFIX .. legacyTitle
            local legacyKeys = {
                legacyKey,


                ParchmentReader:BookKey(nil, legacyKey),
            }

            if ParchmentReaderDB.customBooks[newKey] == nil then
                ParchmentReaderDB.customBooks[newKey] = {
                    content = content,
                    collection = nil,
                    createdAt = now,
                    modifiedAt = now,
                }
                for _, oldKey in ipairs(legacyKeys) do
                    MoveSavedBookValue(ParchmentReaderDB.bookPages, oldKey, newKey)
                    MoveSavedBookValue(ParchmentReaderDB.bookPositions, oldKey, newKey)
                    MoveSavedBookValue(ParchmentReaderDB.bookmarks, oldKey, newKey)
                    MoveSelectedBook(oldKey, newKey)
                end
                if ParchmentReaderDB.selectedBook == legacyTitle then
                    ParchmentReaderDB.selectedBook = newKey
                end
            else

                for _, oldKey in ipairs(legacyKeys) do
                    ClearSavedBookState(oldKey)
                end
                if ParchmentReaderDB.selectedBook == legacyTitle then
                    ParchmentReaderDB.selectedBook = nil
                end
            end
        end
    end


    ParchmentReaderDB.starterBooksSeeded = true
end


local function LoadSavedBooks()
    if not ParchmentReaderDB.customBooks then return end

    for key, data in pairs(ParchmentReaderDB.customBooks) do
        local collection, title = ParchmentReader:ParseBookKey(key)
        local content = type(data) == "table" and data.content or data

        ParchmentReader.books[key] = {
            title      = title,
            content    = content,
            totalPages = 1,
            custom     = true,
            collection = collection,
        }
    end
end






local shape_quadrant_map = {
    ["ROUND"]                 = {true, true, true, true},
    ["SQUARE"]                = {false, false, false, false},
    ["CORNER-TOPLEFT"]        = {false, false, false, true},
    ["CORNER-TOPRIGHT"]       = {false, false, true, false},
    ["CORNER-BOTTOMLEFT"]     = {false, true, false, false},
    ["CORNER-BOTTOMRIGHT"]    = {true, false, false, false},
    ["SIDE-LEFT"]             = {false, true, false, true},
    ["SIDE-RIGHT"]            = {true, false, true, false},
    ["SIDE-TOP"]              = {false, false, true, true},
    ["SIDE-BOTTOM"]           = {true, true, false, false},
    ["TRICORNER-TOPLEFT"]     = {false, true, true, true},
    ["TRICORNER-TOPRIGHT"]    = {true, false, true, true},
    ["TRICORNER-BOTTOMLEFT"]  = {true, true, false, true},
    ["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local function UpdateButtonPosition(button)
    local angle = math.rad(ParchmentReaderDB.minimapAngle or 200)
    local x = math.cos(angle)
    local y = math.sin(angle)
    local q = 1

    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end


    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quadTable = shape_quadrant_map[shape] or shape_quadrant_map["ROUND"]


    local w = (Minimap:GetWidth() / 2) + 10
    local h = (Minimap:GetHeight() / 2) + 10

    if quadTable[q] then

        x = x * w
        y = y * h
    else

        local diagRadiusW = math.sqrt(2*(w)^2) - 10
        local diagRadiusH = math.sqrt(2*(h)^2) - 10
        x = math.max(-w, math.min(x * diagRadiusW, w))
        y = math.max(-h, math.min(y * diagRadiusH, h))
    end

    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateMinimapIcon()
    local btn = CreateFrame("Button", "ParchmentReaderMinimapBtn", Minimap)


    btn:SetFrameStrata("MEDIUM")
    btn:SetFixedFrameStrata(true)
    btn:SetFrameLevel(8)
    btn:SetFixedFrameLevel(true)
    btn:SetSize(31, 31)

    btn:RegisterForClicks("anyUp")
    btn:RegisterForDrag("LeftButton")


    btn:SetHighlightTexture(136477)


    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture(136430)
    overlay:SetPoint("TOPLEFT")


    local background = btn:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture(136467)
    background:SetPoint("TOPLEFT", 7, -5)


    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(17, 17)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetPoint("TOPLEFT", 7, -6)


    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cFFFFCC00" .. L["Parchment Reader"] .. "|r")
        GameTooltip:AddLine(
            "|cFF00FFFF" .. L["Left-click"] .. "|r – "
                .. L["Show / Hide Reader"], 1, 1, 1)
        GameTooltip:AddLine(
            "|cFF00FFFF" .. L["Ctrl + Left-click"] .. "|r – "
                .. L["Quick Note"], 1, 1, 1)
        GameTooltip:AddLine(
            "|cFF00FFFF" .. L["Right-click"] .. "|r – "
                .. L["Settings"], 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    btn:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            if IsControlKeyDown and IsControlKeyDown() then
                ParchmentReader:ShowQuickNote()
            else
                ParchmentReader:ToggleReader()
            end
        elseif mouseButton == "RightButton" then
            ParchmentReader:ToggleSettings()
        end
    end)


    btn:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self:SetScript("OnUpdate", function(self)
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px = px / scale
            py = py / scale

            local angle = math.deg(math.atan2(py - my, px - mx)) % 360
            ParchmentReaderDB.minimapAngle = angle

            UpdateButtonPosition(self)
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil)
    end)

    UpdateButtonPosition(btn)
    return btn
end

function ParchmentReader:UpdateMinimapButtonPosition()
    if self.minimapBtn then
        self.minimapBtn:ClearAllPoints()
        UpdateButtonPosition(self.minimapBtn)
    end
end

local ESCAPE_HANDLER_NAME = "ParchmentReaderEscapeHandlerFrame"
local ESCAPE_STRATA_ORDER = {
    BACKGROUND = 1,
    LOW = 2,
    MEDIUM = 3,
    HIGH = 4,
    DIALOG = 5,
    FULLSCREEN = 6,
    FULLSCREEN_DIALOG = 7,
    TOOLTIP = 8,
}

local function GetTopEscapeFrame()
    local topFrame
    local topFrameStrata = -1
    local topFrameLevel = -1
    local topFrameOrder = -1
    for frameName, state in pairs(ParchmentReader.escapeCloseFrames or {}) do
        local frame = _G[frameName]
        if frame and frame:IsShown() then
            local strata = ESCAPE_STRATA_ORDER[frame:GetFrameStrata()] or 0
            local level = frame:GetFrameLevel() or 0
            local order = state.order or 0
            local isHigher = strata > topFrameStrata
                or strata == topFrameStrata and level > topFrameLevel
                or strata == topFrameStrata
                    and level == topFrameLevel
                    and order > topFrameOrder
            if isHigher then
                topFrame = frame
                topFrameStrata = strata
                topFrameLevel = level
                topFrameOrder = order
            end
        end
    end
    return topFrame
end

local function RemoveManagedEscapeFrames()
    if not UISpecialFrames then return end

    for index = #UISpecialFrames, 1, -1 do
        local frameName = UISpecialFrames[index]
        if frameName == ESCAPE_HANDLER_NAME
            or (ParchmentReader.escapeCloseFrames
                and ParchmentReader.escapeCloseFrames[frameName])
        then
            table.remove(UISpecialFrames, index)
        end
    end
end

local function SetEscapeHandlerShown(handler, shown)
    ParchmentReader.syncingEscapeHandler = true
    if shown then
        handler:Show()
    else
        handler:Hide()
    end
    ParchmentReader.syncingEscapeHandler = false
end

local function GetEscapeHandler()
    local handler = _G[ESCAPE_HANDLER_NAME]
    if handler then return handler end

    handler = CreateFrame("Frame", ESCAPE_HANDLER_NAME, UIParent)
    handler:SetSize(1, 1)
    handler:SetAlpha(0)
    handler:EnableMouse(false)
    handler:Hide()
    handler:SetScript("OnHide", function()
        if ParchmentReader.syncingEscapeHandler then return end

        local topFrame = GetTopEscapeFrame()
        if topFrame then
            topFrame:Hide()
        end
        ParchmentReader:RefreshEscapeCloseRegistration()
    end)
    return handler
end

function ParchmentReader:RefreshEscapeCloseRegistration()
    if not UISpecialFrames then return end

    local handler = GetEscapeHandler()
    RemoveManagedEscapeFrames()
    table.insert(UISpecialFrames, ESCAPE_HANDLER_NAME)
    SetEscapeHandlerShown(handler, GetTopEscapeFrame() ~= nil)
end

function ParchmentReader:RegisterEscapeClose(frameName)
    local frame = frameName and _G[frameName]
    if not frame then return end

    self.escapeCloseFrames = self.escapeCloseFrames or {}
    if self.escapeCloseFrames[frameName] then return end

    self.escapeCloseFrames[frameName] = {order = 0}

    local function MarkAsTopEscapeFrame()
        ParchmentReader.escapeCloseOrder =
            (ParchmentReader.escapeCloseOrder or 0) + 1
        ParchmentReader.escapeCloseFrames[frameName].order =
            ParchmentReader.escapeCloseOrder
        ParchmentReader:RefreshEscapeCloseRegistration()
    end

    frame:HookScript("OnShow", MarkAsTopEscapeFrame)
    frame:HookScript("OnHide", function()
        ParchmentReader:RefreshEscapeCloseRegistration()
    end)

    if frame:IsShown() then
        MarkAsTopEscapeFrame()
    else
        self:RefreshEscapeCloseRegistration()
    end
end


function ParchmentReader:ToggleReader()
    if self.readerMinimized then
        self:ShowReader()
    elseif ParchmentReaderFrame and ParchmentReaderFrame:IsShown() then
        self:CloseReader()
    else
        self:ShowReader()
    end
end

function ParchmentReader:ShowReader()
    self.readerMinimized = false
    if self.HideFloatingLauncher then
        self:HideFloatingLauncher()
    end

    if not ParchmentReaderFrame then
        self:CreateReaderFrame()
    end
    ParchmentReaderFrame:Show()
    self:UpdateReader()
end

function ParchmentReader:CloseReader()
    self.readerMinimized = false
    if self.HideFloatingLauncher then
        self:HideFloatingLauncher()
    end
    if ParchmentReaderFrame then
        ParchmentReaderFrame:Hide()
    end
end

function ParchmentReader:MinimizeReader()
    if not ParchmentReaderFrame or not ParchmentReaderFrame:IsShown() then
        return
    end

    self.readerMinimized = true
    ParchmentReaderFrame:Hide()
    self:ShowFloatingLauncher()
end

function ParchmentReader:ToggleReaderMinimized()
    if self.readerMinimized then
        self:ShowReader()
    elseif ParchmentReaderFrame and ParchmentReaderFrame:IsShown() then
        self:MinimizeReader()
    end
end

function ParchmentReader_ToggleReader()
    if ParchmentReader then
        ParchmentReader:ToggleReader()
    end
end

function ParchmentReader_ToggleMinimize()
    if ParchmentReader then
        ParchmentReader:ToggleReaderMinimized()
    end
end

function ParchmentReader:ShowSettings()
    if not ParchmentReaderSettingsFrame then
        self:CreateSettingsFrame()
    end
    if self.SyncWindowSizeControls then
        self:SyncWindowSizeControls()
    end
    ParchmentReaderSettingsFrame:Show()
    ParchmentReaderSettingsFrame:Raise()
end

function ParchmentReader:ToggleSettings()
    if ParchmentReaderSettingsFrame and ParchmentReaderSettingsFrame:IsShown() then
        ParchmentReaderSettingsFrame:Hide()
    else
        self:ShowSettings()
    end
end

function ParchmentReader:GetReaderMinimumSize(compact)
    local metrics = self.Theme.metrics
    local useCompactBounds = compact
    if useCompactBounds == nil then
        useCompactBounds = ParchmentReaderDB.sidebarCollapsed == true
    end

    if useCompactBounds then
        return metrics.compactMinWidth, metrics.compactMinHeight
    end
    return metrics.minWidth, metrics.minHeight
end

function ParchmentReader:UpdateReaderResizeBounds(compact)
    local frame = ParchmentReaderFrame
    if not frame then return end

    local metrics = self.Theme.metrics
    local minWidth, minHeight = self:GetReaderMinimumSize(compact)
    local width = math.max(
        minWidth,
        math.min(math.floor(frame:GetWidth() + 0.5), metrics.maxWidth))
    local height = math.max(
        minHeight,
        math.min(math.floor(frame:GetHeight() + 0.5), metrics.maxHeight))
    if width ~= frame:GetWidth() or height ~= frame:GetHeight() then
        frame:SetSize(width, height)
    end

    if frame.SetResizeBounds then
        frame:SetResizeBounds(minWidth, minHeight, metrics.maxWidth, metrics.maxHeight)
    elseif frame.SetMinResize and frame.SetMaxResize then
        frame:SetMinResize(minWidth, minHeight)
        frame:SetMaxResize(metrics.maxWidth, metrics.maxHeight)
    end

    ParchmentReaderDB.windowWidth = width
    ParchmentReaderDB.windowHeight = height
    if self.SyncWindowSizeControls then
        self:SyncWindowSizeControls(width, height)
    end
end

function ParchmentReader:ApplySidebarState(collapsed)
    if not ParchmentReaderFrame then return end

    local wasCollapsed = ParchmentReaderDB.sidebarCollapsed == true
    if wasCollapsed ~= (collapsed == true) then
        self:SyncReadingPosition()
        self:StopReaderScrollAnimation()
    end
    ParchmentReaderDB.sidebarCollapsed = collapsed == true

    local frame = ParchmentReaderFrame
    local sidebar = frame.sidebar
    local toggleBtn = frame.toggleBtn
    local metrics = self.Theme.metrics

    if frame.collectionPopover then
        frame.collectionPopover:Hide()
    end

    if ParchmentReaderDB.sidebarCollapsed then
        sidebar:SetWidth(metrics.collapsedSidebarWidth)
        frame.collectionSelector:Hide()
        if frame.searchBox then frame.searchBox:ClearFocus() end
        if frame.searchContainer then frame.searchContainer:Hide() end
        frame.sidebarScroll:Hide()
        frame.addBookBtn:Hide()
        frame.collapsedLibraryButton:Show()
        frame.collapsedQuickNoteButton:Show()
        frame.settingsButton:Hide()
        frame.helpButton:Hide()
        toggleBtn:SetText("»")
        toggleBtn.tooltipText = L["Exit Compact Mode — show library"]
    else
        sidebar:SetWidth(metrics.sidebarWidth)
        frame.collectionSelector:Show()
        if frame.searchContainer then frame.searchContainer:Show() end
        frame.sidebarScroll:Show()
        frame.addBookBtn:Show()
        frame.collapsedLibraryButton:Hide()
        frame.collapsedQuickNoteButton:Hide()
        frame.settingsButton:Show()
        frame.helpButton:Show()
        toggleBtn:SetText(L["«  Compact Mode"])
        toggleBtn.tooltipText = L["Compact Mode — hide library"]
    end

    self:UpdateReaderResizeBounds(ParchmentReaderDB.sidebarCollapsed)
    if frame.RefreshTitleAreaWidth then
        frame:RefreshTitleAreaWidth()
    end
    if self.RefreshCollectionSelector then
        self:RefreshCollectionSelector()
    end
    self:UpdateContentWidth()
end

function ParchmentReader:ToggleSidebar()
    self:ApplySidebarState(not ParchmentReaderDB.sidebarCollapsed)
end


function ParchmentReader:SetCollection(name)
    self.currentCollection = name
    if ParchmentReaderFrame and ParchmentReaderFrame.sidebarScroll then
        ParchmentReaderFrame.sidebarScroll:SetVerticalScroll(0)
    end
    self:RefreshCollectionSelector()
    self:RefreshBookList()
end

function ParchmentReader:AddCollection(name)
    if not name or name == "" then return end
    for _, c in ipairs(ParchmentReaderDB.collections) do
        if c == name then return end
    end
    table.insert(ParchmentReaderDB.collections, name)
    self:RefreshCollectionSelector()
end

local function CollectionExists(name)
    if name == nil then return true end
    for _, collectionName in ipairs(ParchmentReaderDB.collections or {}) do
        if collectionName == name then return true end
    end
    return false
end

local function RekeyCustomBook(bookKey, targetCollection)
    local book = ParchmentReader.books[bookKey]
    local savedBooks = ParchmentReaderDB.customBooks or {}
    local saved = savedBooks[bookKey]
    if not book or not book.custom or saved == nil then
        return false, nil, "missing"
    end

    if book.collection == targetCollection then
        return true, bookKey
    end

    local newKey = ParchmentReader:BookKey(targetCollection, book.title)
    if newKey ~= bookKey
        and (ParchmentReader.books[newKey] or savedBooks[newKey] ~= nil)
    then
        return false, nil, "duplicate"
    end

    if type(saved) == "table" then
        saved.collection = targetCollection
        saved.modifiedAt = time()
    else
        saved = {
            content = saved,
            collection = targetCollection,
            modifiedAt = time(),
        }
    end

    savedBooks[bookKey] = nil
    savedBooks[newKey] = saved
    ParchmentReaderDB.customBooks = savedBooks

    book.collection = targetCollection
    ParchmentReader.books[bookKey] = nil
    ParchmentReader.books[newKey] = book

    if ParchmentReaderDB.bookPages
        and ParchmentReaderDB.bookPages[bookKey] ~= nil
    then
        ParchmentReaderDB.bookPages[newKey] = ParchmentReaderDB.bookPages[bookKey]
        ParchmentReaderDB.bookPages[bookKey] = nil
    end
    ParchmentReader:MoveReadingPosition(bookKey, newKey)
    MoveSelectedBook(bookKey, newKey)

    local movedCurrentBook = ParchmentReader.currentBook == bookKey
    if movedCurrentBook then
        ParchmentReader.currentBook = newKey
    end

    return true, newKey, nil, movedCurrentBook
end

function ParchmentReader:MoveBook(bookKey, targetCollection)
    if not CollectionExists(targetCollection) then
        return false, nil, "missing-collection"
    end

    local editor = ParchmentReaderEditorFrame
    if editor and editor:IsShown() and editor.editingBook == bookKey then
        return false, nil, "editing"
    end

    if self.currentBook == bookKey
        and ParchmentReaderFrame
        and ParchmentReaderFrame:IsShown()
    then
        self:SyncReadingPosition()
        self:StopReaderScrollAnimation()
    end

    local moved, newKey, reason, movedCurrentBook =
        RekeyCustomBook(bookKey, targetCollection)
    if not moved then return false, nil, reason end

    self:RefreshBookList()
    if movedCurrentBook
        and ParchmentReaderFrame
        and ParchmentReaderFrame:IsShown()
    then
        self:UpdateReader("book-key-changed")
    end
    return true, newKey
end

function ParchmentReader:RenameCollection(oldName, newName)
    if not oldName or not newName or newName == "" then
        return false, "invalid"
    end
    if oldName == newName then return true end
    if not CollectionExists(oldName) then return false, "missing" end
    if CollectionExists(newName) then return false, "duplicate-collection" end

    local currentBookRekeyed = false
    local rekey = {}
    local sourceKeys = {}
    for key, data in pairs(ParchmentReaderDB.customBooks) do
        if type(data) == "table" and data.collection == oldName then
            local _, title = self:ParseBookKey(key)
            local newKey = self:BookKey(newName, title)
            sourceKeys[key] = true
            rekey[#rekey + 1] = {
                oldKey = key,
                newKey = newKey,
                title = title,
                data = data,
            }
        end
    end

    for _, entry in ipairs(rekey) do
        if entry.newKey ~= entry.oldKey
            and not sourceKeys[entry.newKey]
            and (ParchmentReaderDB.customBooks[entry.newKey] ~= nil
                or self.books[entry.newKey] ~= nil)
        then
            return false, "duplicate-book", entry.title
        end
    end

    for index, collectionName in ipairs(ParchmentReaderDB.collections) do
        if collectionName == oldName then
            ParchmentReaderDB.collections[index] = newName
            break
        end
    end

    for _, r in ipairs(rekey) do
        r.data.collection = newName
        ParchmentReaderDB.customBooks[r.oldKey] = nil
        ParchmentReaderDB.customBooks[r.newKey] = r.data

        local memBook = self.books[r.oldKey]
        if memBook then
            memBook.collection = newName
            self.books[r.oldKey] = nil
            self.books[r.newKey] = memBook
        end

        if ParchmentReaderDB.bookPages and ParchmentReaderDB.bookPages[r.oldKey] then
            ParchmentReaderDB.bookPages[r.newKey] = ParchmentReaderDB.bookPages[r.oldKey]
            ParchmentReaderDB.bookPages[r.oldKey] = nil
        end
        self:MoveReadingPosition(r.oldKey, r.newKey)
        MoveSelectedBook(r.oldKey, r.newKey)

        if self.currentBook == r.oldKey then
            self.currentBook = r.newKey
            currentBookRekeyed = true
        end
    end


    if self.currentCollection == oldName then
        self.currentCollection = newName
    end

    self:RefreshCollectionSelector()
    self:RefreshBookList()
    if currentBookRekeyed and ParchmentReaderFrame and ParchmentReaderFrame:IsShown() then
        self:UpdateReader("book-key-changed")
    end
    return true
end

function ParchmentReader:DeleteCollection(name)
    if not name then return end
    if not CollectionExists(name) then return false, "missing" end

    local booksToMove = {}
    for key, book in pairs(self.books) do
        if book.custom and book.collection == name
            and ParchmentReaderDB.customBooks[key] ~= nil
        then
            local title = book.title
            local targetKey = self:BookKey(nil, title)
            if targetKey ~= key
                and (self.books[targetKey]
                    or ParchmentReaderDB.customBooks[targetKey] ~= nil)
            then
                return false, "duplicate", title
            end
            booksToMove[#booksToMove + 1] = key
        end
    end

    local editor = ParchmentReaderEditorFrame
    if editor and editor:IsShown() and editor.editingBook then
        local editingBook = self.books[editor.editingBook]
        if editingBook and editingBook.collection == name then
            return false, "editing", editingBook.title
        end
    end

    if self.currentBook and self.books[self.currentBook]
        and self.books[self.currentBook].collection == name
        and ParchmentReaderFrame
        and ParchmentReaderFrame:IsShown()
    then
        self:SyncReadingPosition()
        self:StopReaderScrollAnimation()
    end

    local movedCurrentBook = false
    for _, key in ipairs(booksToMove) do
        local moved, _, _, movedCurrent = RekeyCustomBook(key, nil)
        if not moved then
            return false, "move-failed"
        end
        movedCurrentBook = movedCurrentBook or movedCurrent
    end

    for index, collectionName in ipairs(ParchmentReaderDB.collections) do
        if collectionName == name then
            table.remove(ParchmentReaderDB.collections, index)
            break
        end
    end


    if self.currentCollection == name then
        self.currentCollection = nil
    end

    self:RefreshCollectionSelector()
    self:RefreshBookList()
    if movedCurrentBook
        and ParchmentReaderFrame
        and ParchmentReaderFrame:IsShown()
    then
        self:UpdateReader("book-key-changed")
    end
    return true, nil, nil, #booksToMove
end


function ParchmentReader:LoadBook(bookKey)
    if not self.books[bookKey] then
        self:PrintMessage("Book not found.")
        return false
    end

    self:CancelReaderJumpRequests()

    if self.currentBook and ParchmentReaderFrame then
        if ParchmentReaderFrame.bookmarkPopover then
            ParchmentReaderFrame.bookmarkPopover:Hide()
        end
        self:SyncReadingPosition()
        self:StopReaderScrollAnimation()
        self:CacheCurrentReaderLayout()
    end

    self.currentBook = bookKey
    ParchmentReaderDB.selectedBook = bookKey
    local book = self.books[bookKey]
    local layoutContent = self:NormalizeLayoutText(book.content)
    local savedPosition = self:GetSavedReadingPosition(bookKey)
    local savedOffset = self:ResolveReadingPosition(layoutContent, savedPosition)
    local savedPage = ParchmentReaderDB.bookPages and ParchmentReaderDB.bookPages[bookKey] or 1
    if savedOffset ~= nil then
        self.currentReadingOffset = savedOffset
        self.currentPage = 1
        self.pendingReadingRestore = true
        self.pendingReadingPosition = savedPosition
        self.lastReflowReason = "saved-position"
    else
        self.currentReadingOffset = 0
        self.currentPage = math.max(1, math.floor(tonumber(savedPage) or 1))
        self.pendingReadingRestore = false
        self.pendingReadingPosition = nil
        self.lastReflowReason = self.currentPage > 1 and "legacy-page" or "book-opened"
    end
    self.readerLayoutMetrics = nil

    if ParchmentReaderFrame and ParchmentReaderFrame.title then
        ParchmentReaderFrame.title:SetText(book.title)
    end

    self:UpdateReader()

    if ParchmentReaderFrame then
        self:RefreshBookList()
    end

    return true
end

function ParchmentReader:NextPage()
    self:ScrollReaderByViewport(0.9)
end

function ParchmentReader:PrevPage()
    self:ScrollReaderByViewport(-0.9)
end


function ParchmentReader:UpdateFont()
    local frame = ParchmentReaderFrame
    if not frame or not frame.readerMeasureText then return end

    frame.readerMeasureText:SetText("")
    self:ApplyFontTo(frame.readerMeasureText)
    self:ApplyFontTo(frame.readerMessage)
    for _, fontString in ipairs(frame.readerTextPool) do
        fontString:Hide()
        fontString:SetText("")
        fontString.chunkIndex = nil
        self:ApplyFontTo(fontString)
    end
    if self.readerLayoutMetrics then
        self.readerLayoutMetrics.visibleChunkStart = nil
        self.readerLayoutMetrics.visibleChunkEnd = nil
    end

    self:UpdateReader("font-setting")
end


function ParchmentReader:UpdateContentWidth()
    local frame = ParchmentReaderFrame
    if not frame or not frame.readerMeasureText then return end

    local contentWidth = frame.contentScroll:GetWidth()
    if contentWidth <= 0 then return end

    local textWidth = math.max(1, contentWidth - 16)
    frame.contentChild:SetWidth(contentWidth)
    frame.readerTextWidth = textWidth
    frame.readerMeasureText:SetWidth(textWidth)
    frame.readerMessage:SetWidth(textWidth)
    for _, fontString in ipairs(frame.readerTextPool) do
        fontString:SetWidth(textWidth)
    end

    self:ScheduleReaderLayout("size-changed")
end


local _boot = CreateFrame("Frame")
_boot:RegisterEvent("ADDON_LOADED")
_boot:RegisterEvent("PLAYER_ENTERING_WORLD")

_boot:SetScript("OnEvent", function(self, event, addonName)

    if event == "ADDON_LOADED" and addonName == "ParchmentReader" then

        ParchmentReaderDB = ParchmentReaderDB or {}
        ApplyDefaults(ParchmentReaderDB)
        ParchmentReaderDB.transparencyMode =
            ParchmentReader:NormalizeTransparencyMode(ParchmentReaderDB.transparencyMode)
        ParchmentReaderDB.floatingLauncherLocked =
            ParchmentReaderDB.floatingLauncherLocked == true
        ParchmentReaderDB.customBooks = ParchmentReaderDB.customBooks or {}
        ParchmentReaderDB.collections = ParchmentReaderDB.collections or {}
        ParchmentReaderDB.bookPages   = ParchmentReaderDB.bookPages   or {}
        ParchmentReaderDB.bookPositions = ParchmentReaderDB.bookPositions or {}
        ParchmentReaderDB.bookmarks = ParchmentReaderDB.bookmarks or {}
        if ParchmentReaderDB.fontSettingsVersion ~= 3 then
            local previousFont = ParchmentReaderDB.fontName
            if previousFont == nil
                or previousFont == "SystemFont_Med1"
                or previousFont == "FRIZQT__.TTF"
                or previousFont == "QuestFont"
                or previousFont == "GameFontNormal"
                or previousFont == "MORPHEUS.TTF"
            then
                ParchmentReaderDB.fontName = "ChatFontNormal"
            end
            ParchmentReaderDB.fontSettingsVersion = 3
        end
        MigrateCustomBooks()
        SeedStarterBooks()
        LoadSavedBooks()
        ParchmentReader:RegisterWoWSettingsCategory()

        local selectedBook = ParchmentReaderDB.selectedBook
        if type(selectedBook) == "string"
            and ParchmentReader.books[selectedBook]
        then
            ParchmentReader:LoadBook(selectedBook)
        elseif selectedBook ~= nil then
            ParchmentReaderDB.selectedBook = nil
        end


        self:UnregisterEvent("ADDON_LOADED")
    end

    if event == "PLAYER_ENTERING_WORLD" then
        if not ParchmentReader.minimapBtn then
            ParchmentReader.minimapBtn = CreateMinimapIcon()
        end

        if ParchmentReaderDB.hide then
            ParchmentReader.minimapBtn:Hide()
        else
            ParchmentReader.minimapBtn:Show()
        end

        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)


SLASH_PARCHMENTREADER1 = "/reader"
SLASH_PARCHMENTREADER2 = "/pr"
SLASH_PARCHMENTREADER3 = "/parchmentreader"
SlashCmdList["PARCHMENTREADER"] = function(msg)
    msg = strtrim(msg):lower()

    if msg == "refresh" or msg == "reload" or msg == "reset" then

        if ParchmentReaderFrame then
            ParchmentReader:CloseReader()
            ParchmentReader:ApplySidebarState(ParchmentReaderDB.sidebarCollapsed)
            ParchmentReader:RefreshCollectionSelector()
            ParchmentReader:RefreshBookList()
            ParchmentReader:UpdateFont()
        end
        ParchmentReader:PrintMessage("Reader refreshed.")
    elseif msg == "" then
        ParchmentReader:ToggleReader()
    else
        ParchmentReader:PrintMessage(
            "Unknown command. Use /reader or /reader refresh.")
    end
end
