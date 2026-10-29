
local RETENTION = 30 * 86400
local STATE_FIELDS = {"bookPages", "bookPositions", "bookmarks", "favoriteBooks"}

local function Copy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local result = {}
    seen[value] = result
    for key, item in pairs(value) do result[Copy(key, seen)] = Copy(item, seen) end
    return result
end

local function Finite(value)
    return type(value) == "number" and value == value
        and value ~= math.huge and value ~= -math.huge
end

local function ValidEntry(id, entry)
    return type(id) == "string" and type(entry) == "table" and entry.id == id
        and type(entry.title) == "string" and entry.title ~= ""
        and (entry.collection == nil or type(entry.collection) == "string")
        and Finite(entry.deletedAt) and entry.deletedAt >= 0
        and type(entry.saved) == "table" and type(entry.saved.content) == "string"
end

local function Store()
    if type(ParchmentReaderDB.trashBooks) ~= "table" then

        if ParchmentReaderDB.trashBooks ~= nil then
            ParchmentReaderDB.invalidTrashBooks = ParchmentReaderDB.trashBooks
        end
        ParchmentReaderDB.trashBooks = {}
    end
    return ParchmentReaderDB.trashBooks
end

local function Notify(self, library)
    if library and ParchmentReaderFrame and self.RefreshBookList then self:RefreshBookList() end
    if self.RefreshTrashUI then self:RefreshTrashUI() end
    if library and self.RefreshQuickNoteResumeRow then self:RefreshQuickNoteResumeRow() end
end

function ParchmentReader:ScheduleTrashExpiry()
    local nearest
    for id, entry in pairs(Store()) do
        if ValidEntry(id, entry) then
            local deadline = entry.deletedAt + RETENTION
            if not nearest or deadline < nearest then nearest = deadline end
        end
    end
    if self.trashExpiryDeadline == nearest and self.trashExpiryScheduled then return end
    self.trashExpiryGeneration = (self.trashExpiryGeneration or 0) + 1
    local generation = self.trashExpiryGeneration
    if self.trashExpiryTimer and self.trashExpiryTimer.Cancel then self.trashExpiryTimer:Cancel() end
    self.trashExpiryTimer = nil
    self.trashExpiryDeadline, self.trashExpiryScheduled = nearest, false
    if not nearest or not C_Timer then return end
    local function expire()
        if self.trashExpiryGeneration ~= generation then return end
        self.trashExpiryScheduled = false
        self:PruneTrash()
    end

    local delay = math.min(3600, math.max(0, nearest - time()))
    if C_Timer.NewTimer then
        self.trashExpiryTimer = C_Timer.NewTimer(delay, expire)
        self.trashExpiryScheduled = true
    elseif C_Timer.After then
        C_Timer.After(delay, expire)
        self.trashExpiryScheduled = true
    end
end

function ParchmentReader:InitializeTrash()
    self.trashExpiryScheduled = false
    self:PruneTrash()
end

function ParchmentReader:PruneTrash()
    local entries, now, removed = Store(), time(), 0
    for id, entry in pairs(entries) do

        if ValidEntry(id, entry) and now >= entry.deletedAt + RETENTION then
            entries[id], removed = nil, removed + 1
        end
    end
    self:ScheduleTrashExpiry()
    if removed > 0 then Notify(self) end
    return removed
end

function ParchmentReader:GetTrashEntries()
    self:PruneTrash()
    local result = {}
    for id, entry in pairs(Store()) do
        if ValidEntry(id, entry) then result[#result + 1] = entry end
    end
    table.sort(result, function(a, b)
        if a.deletedAt == b.deletedAt then
            local aSerial, bSerial = tonumber(a.id:match("^trash:(%d+)$")), tonumber(b.id:match("^trash:(%d+)$"))
            if (aSerial ~= nil) ~= (bSerial ~= nil) then return aSerial ~= nil end
            if aSerial and bSerial and aSerial ~= bSerial then return aSerial > bSerial end
            return a.id > b.id
        end
        return a.deletedAt > b.deletedAt
    end)
    return result
end

function ParchmentReader:GetTrashCount() return #self:GetTrashEntries() end

function ParchmentReader:GetTrashEntry(id)
    self:PruneTrash()
    local entry = Store()[id]
    return ValidEntry(id, entry) and entry or nil
end

function ParchmentReader:CaptureTrashEntries()
    local result = {}
    for _, entry in ipairs(self:GetTrashEntries()) do result[entry.id] = entry end
    return result
end

function ParchmentReader:DeleteTrashedBook(id, expectedEntry)
    local entry = self:GetTrashEntry(id)
    if not entry or (expectedEntry and entry ~= expectedEntry) then return false end
    Store()[id] = nil
    self:ScheduleTrashExpiry()
    Notify(self)
    return true
end

function ParchmentReader:EmptyTrash(snapshot)
    self:PruneTrash()
    local removed, entries = 0, Store()
    for id, expected in pairs(type(snapshot) == "table" and snapshot or {}) do
        if entries[id] == expected and ValidEntry(id, expected) then
            entries[id], removed = nil, removed + 1
        end
    end
    self:ScheduleTrashExpiry()
    if removed > 0 then Notify(self) end
    return removed
end

local function SourceEditors(key)
    local result = {}
    for _, frame in ipairs({ParchmentReaderEditorFrame or false, ParchmentReaderQuickNoteFrame or false}) do
        if frame and frame.editingBook == key then
            result[#result + 1] = {frame = frame, generation = frame.draftGeneration,
                dirty = frame.isDirty == true, title = frame.titleInput:GetText() or "",
                content = frame.contentInput:GetText() or "", collection = frame.selectedCollection}
        end
    end
    return result
end

local function EditorsMatch(key, expected)
    local current = SourceEditors(key)
    if #current ~= #expected then return false end
    for index, state in ipairs(current) do
        local old = expected[index]
        if state.frame ~= old.frame or state.generation ~= old.generation or state.dirty ~= old.dirty
            or state.title ~= old.title or state.content ~= old.content or state.collection ~= old.collection then
            return false
        end
    end
    return true
end

function ParchmentReader:TrashBook(key, baseline, options)
    self:PruneTrash()
    baseline = baseline or self:CaptureSavedBookBaseline(key)
    if not baseline or not self:SavedBookMatchesBaseline(key, baseline) then return false, nil, "stale" end
    local editors = SourceEditors(key)
    if options and options.editors then
        if not EditorsMatch(key, options.editors) then return false, nil, "stale" end
    else
        for _, state in ipairs(editors) do
            if state.dirty then return false, nil, "dirty" end
        end
    end
    local saved = ParchmentReaderDB.customBooks[key]
    if type(saved) ~= "string" and (type(saved) ~= "table" or type(saved.content) ~= "string") then
        return false, nil, "invalid"
    end
    if self.currentBook == key then
        if self.SyncReadingPosition then self:SyncReadingPosition() end
    end
    local entries = Store()
    local serial = ParchmentReaderDB.nextTrashId
    if not Finite(serial) or serial < 0 or serial % 1 ~= 0 or serial >= 9007199254740990 then serial = 0 end
    local id
    repeat serial = serial + 1; id = "trash:" .. string.format("%.0f", serial) until entries[id] == nil
    ParchmentReaderDB.nextTrashId = serial
    local function state(field)
        local values = ParchmentReaderDB[field]
        return type(values) == "table" and Copy(values[key]) or nil
    end
    local book = self.books[key]
    local entry = {id = id, title = book.title, collection = book.collection, deletedAt = time(),
        saved = type(saved) == "string" and {content = saved, collection = book.collection} or Copy(saved),
        bookPage = state("bookPages"), bookPosition = state("bookPositions"),
        bookmarks = state("bookmarks"), favorite = state("favoriteBooks") == true}
    entries[id] = entry


    if self.currentBook == key then
        if self.StopReaderScrollAnimation then self:StopReaderScrollAnimation() end
        if self.CancelReaderJumpRequests then self:CancelReaderJumpRequests() end
        if self.EndContentSearchNavigation then self:EndContentSearchNavigation(false) end
        self.pendingReadingRestore, self.pendingReadingPosition = false, nil
        self.currentBook, self.currentPage, self.currentReadingOffset = nil, 1, 0
        self.readerLayoutMetrics = nil
        if ParchmentReaderFrame then
            ParchmentReaderFrame.readerLayoutGeneration = (ParchmentReaderFrame.readerLayoutGeneration or 0) + 1
            ParchmentReaderFrame.readerScheduledReason = nil
        end
        if ParchmentReaderFrame and ParchmentReaderFrame.bookmarkPopover then ParchmentReaderFrame.bookmarkPopover:Hide() end
    end
    for _, field in ipairs(STATE_FIELDS) do
        if type(ParchmentReaderDB[field]) == "table" then ParchmentReaderDB[field][key] = nil end
    end
    if self.DeleteLibraryViewBook then self:DeleteLibraryViewBook(key) end
    if self.InvalidateReaderLayoutCache then self:InvalidateReaderLayoutCache(key) end
    ParchmentReaderDB.customBooks[key], self.books[key] = nil, nil
    if ParchmentReaderDB.selectedBook == key then ParchmentReaderDB.selectedBook = nil end
    if ParchmentReaderDB.lastQuickNote == key then ParchmentReaderDB.lastQuickNote = nil end
    for _, state in ipairs(editors) do
        local frame = state.frame

        if state.dirty then self:SyncEditorDraft(frame) end
        if frame == ParchmentReaderQuickNoteFrame and self.CloseTrashedQuickNote then
            self:CloseTrashedQuickNote(frame)
        else
            local discardPopup, deletePopup = frame.discardPopup, frame.deletePopup
            frame.isDirty = false
            frame.draftGeneration = (frame.draftGeneration or 0) + 1
            frame.pendingDeleteData, frame.deletePopup = nil, nil
            frame.pendingDiscardData, frame.discardPopup = nil, nil
            frame.pendingEditorAction, frame.pendingBookKey = nil, nil
            if discardPopup then discardPopup:Hide() end
            if deletePopup then deletePopup:Hide() end
            frame:Hide()
        end
    end
    if ParchmentReaderFrame and self.UpdateReader and not self.currentBook then
        if ParchmentReaderFrame.title then ParchmentReaderFrame.title:SetText("") end
        self:UpdateReader()
    end
    self:ScheduleTrashExpiry()
    Notify(self, true)
    return true, id
end

function ParchmentReader:RestoreTrashedBook(id, expectedEntry)
    local entry = self:GetTrashEntry(id)
    if not entry then return false, nil, "missing" end
    if expectedEntry and expectedEntry ~= entry then return false, nil, "stale" end

    for _, field in ipairs({"customBooks", "bookPages", "bookPositions", "bookmarks", "favoriteBooks"}) do
        if ParchmentReaderDB[field] ~= nil and type(ParchmentReaderDB[field]) ~= "table" then return false, nil, "state" end
    end
    local collection
    for _, name in ipairs(type(ParchmentReaderDB.collections) == "table" and ParchmentReaderDB.collections or {}) do
        if name == entry.collection then collection = name; break end
    end
    local function occupied(title)
        local key = self:BookKey(collection, title)
        if self.books[key] or (ParchmentReaderDB.customBooks or {})[key] ~= nil then return true end
        for _, field in ipairs(STATE_FIELDS) do
            if (ParchmentReaderDB[field] or {})[key] ~= nil then return true end
        end
        return false
    end
    local title = entry.title
    if occupied(title) then
        local template = self.L["%s (restored)"]
        local function prefix(value, limit)
            local characters = 0
            for index = 1, #value do
                local byte = value:byte(index)
                if byte < 128 or byte >= 192 then
                    characters = characters + 1
                    if characters > limit then return value:sub(1, index - 1) end
                end
            end
            return value
        end
        local function candidate(number)
            local discriminator = number and string.format(" (%d)", number) or ""
            local budget = math.max(0, 100 - self:CountUTF8Characters(string.format(template, "") .. discriminator))
            return string.format(template, prefix(entry.title, budget)) .. discriminator
        end
        title = candidate()
        local suffix = 2
        while occupied(title) do title = candidate(suffix); suffix = suffix + 1 end
    end
    local key, saved = self:BookKey(collection, title), Copy(entry.saved)
    saved.collection = collection
    local values = {bookPages = Copy(entry.bookPage), bookPositions = Copy(entry.bookPosition),
        bookmarks = Copy(entry.bookmarks), favoriteBooks = entry.favorite == true and true or nil}

    local book = {title = title, collection = collection, content = saved.content, custom = true, totalPages = 1}
    ParchmentReaderDB.customBooks = ParchmentReaderDB.customBooks or {}
    ParchmentReaderDB.customBooks[key], self.books[key] = saved, book
    for _, field in ipairs(STATE_FIELDS) do
        ParchmentReaderDB[field] = ParchmentReaderDB[field] or {}
        ParchmentReaderDB[field][key] = values[field]
    end
    Store()[id] = nil
    self:ScheduleTrashExpiry()
    Notify(self, true)
    return true, key
end


function ParchmentReader:RequestTrashBook(key, editorFrame)
    self:PruneTrash()
    local baseline = self:CaptureSavedBookBaseline(key)
    if not baseline then return false end
    local previous = self.pendingTrashBook
    if previous and previous.popup and previous.popup.data == previous and previous.popup:IsShown() then
        return false
    end
    if previous and previous.cancel then previous.cancel() end
    local editors, dirty = SourceEditors(key), false
    for _, state in ipairs(editors) do dirty = dirty or state.dirty end
    local data = {bookKey = key, baseline = baseline, editors = editors,
        editorFrame = editorFrame, generation = editorFrame and editorFrame.draftGeneration}
    self.pendingTrashBook = data
    if editorFrame then editorFrame.pendingDeleteData = data end
    local function current(callbackData)
        return callbackData == data and self.pendingTrashBook == data
            and (not editorFrame or (editorFrame.pendingDeleteData == data
                and editorFrame.draftGeneration == data.generation))
    end
    local function clear()
        if self.pendingTrashBook == data then self.pendingTrashBook = nil end
        if editorFrame and editorFrame.pendingDeleteData == data then
            editorFrame.pendingDeleteData, editorFrame.deletePopup = nil, nil
        end
    end
    data.accept = function()
        if not current(data) then clear(); return end
        clear()
        local ok = self:TrashBook(key, baseline, {editors = editors})
        if not ok then self:PrintMessage("This book changed or was deleted. Your draft has been kept.") end
    end



    data.cancel = clear
    local dialog = self.trashBookDialog
    if not dialog then
        dialog = {
            OnAccept = function(_, callbackData) if callbackData and callbackData.accept then callbackData.accept() end end,
            OnCancel = function(_, callbackData) if callbackData and callbackData.cancel then callbackData.cancel() end end,
            OnHide = function(_, callbackData) if callbackData and callbackData.cancel then callbackData.cancel() end end,
            timeout = 0, whileDead = true, hideOnEscape = true,
        }
        self.trashBookDialog = dialog
    end
    dialog.text = self.L[dirty and "Move the saved version of “%s” to Trash? Unsaved changes will be kept separately as a draft."
        or "Move book “%s” to Trash?"] .. "\n\n"
        .. self.L["You can restore it within 30 days: Settings > General > Trash."]
    dialog.button1, dialog.button2 = self.L["Move to Trash"], self.L["Cancel"]
    StaticPopupDialogs["PARCHMENTREADER_DELETE"] = dialog
    data.popup = StaticPopup_Show("PARCHMENTREADER_DELETE", baseline.title, nil, data)
    if editorFrame then editorFrame.deletePopup = data.popup end
    return data.popup ~= nil
end
