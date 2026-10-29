

local L = ParchmentReader.L
local Theme, PRUI = ParchmentReader.Theme, ParchmentReader.PRUI
local ROW_COUNT, ROW_HEIGHT = 6, 38
local DAY, RETENTION = 86400, 30 * 86400

local function Literal(text)
    return (tostring(text or ""):gsub("|", "||"))
end

local function Remaining(entry)
    local seconds = entry.deletedAt + RETENTION - time()
    if seconds < DAY then return L["Less than 1 day remaining"] end
    local days = math.ceil(seconds / DAY)
    return ParchmentReader:LocalizePlural("TRASH_DAYS_REMAINING", days)
end

local function Label(parent, text, color, font)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormalSmall")
    label:SetJustifyH("LEFT")
    label:SetText(text or "")
    PRUI.SetFontStringColor(label, Theme:Get("text", color or "secondary"))
    return label
end


local function QuietButton(button)
    PRUI.SetButtonIdleBackgroundAlpha(button, 0)
    button.pruiBorderColor = Theme:Get("state", "clear")
    button.pruiHoverBorderColor = Theme:Get("state", "clear")
    button.pruiSelectedBorderColor = Theme:Get("state", "clear")
    PRUI.RefreshButton(button)
end

local function FitButton(button, minimum, maximum)


    local measure = Label(button, button:GetFontString():GetText())
    local width = math.ceil(measure:GetStringWidth() or minimum) + 20
    measure:Hide()
    button:SetWidth(math.max(minimum, math.min(maximum, width)))
end

local function SizeSession(frame, height)
    frame:SetHeight(height)
    frame.visibleRows = math.max(1, math.min(ROW_COUNT, math.floor((height - 172) / ROW_HEIGHT)))
    frame.list:SetHeight(frame.visibleRows * ROW_HEIGHT)
    frame.listSlider:SetHeight(frame.visibleRows * ROW_HEIGHT)
end

local function SetStatus(frame, message, detail)
    frame.status:SetText(message)
    frame.statusTooltip = detail or message

    frame.status:SetShown(message ~= "")
    frame.statusHit:SetShown(message ~= "")
end

local function PreviewText(parent)
    local text = Label(parent, "", "primary")
    text:SetJustifyV("TOP")
    text:SetWordWrap(true)
    text:SetNonSpaceWrap(true)
    text:SetSpacing(2)
    return text
end

local function RenderPreview(frame)
    local top = frame.previewScroll:GetVerticalScroll() or 0
    local bottom = top + frame.previewScroll:GetHeight()
    local used = 0
    for _, chunk in ipairs(frame.previewChunks or {}) do
        if chunk.top + chunk.height > top and chunk.top <= bottom then
            used = used + 1
            local text = frame.previewPool[used]
            if not text then
                text = PreviewText(frame.previewChild)
                frame.previewPool[used] = text
            end
            text:ClearAllPoints()
            text:SetPoint("TOPLEFT", frame.previewChild, "TOPLEFT", 0, -chunk.top)
            text:SetWidth(frame.previewWidth)
            text:SetHeight(chunk.height)
            text:SetText(Literal(chunk.text))
            text:Show()
        end
    end
    for index = used + 1, #frame.previewPool do frame.previewPool[index]:Hide() end
end



local function BuildPreview(frame, content)
    frame.previewChunks = {}
    frame.previewWidth = math.max(1, frame.previewScroll:GetWidth() - 4)
    frame.previewMeasure:SetWidth(frame.previewWidth)
    local offset, height = 1, 0
    while offset <= #content do
        local last = math.min(#content, offset + 2047)
        local newlineAt = offset
        for _ = 1, 32 do
            newlineAt = content:find("\n", newlineAt, true)
            if not newlineAt or newlineAt > last then break end
            if _ == 32 then last = newlineAt; break end
            newlineAt = newlineAt + 1
        end
        if last < #content then
            while last > offset do
                local following = content:byte(last + 1)
                if following < 128 or following >= 192 then break end
                last = last - 1
            end
            local newline = content:sub(offset + 1024, last):match(".*()\n")
            if newline then last = offset + 1023 + newline end
        end
        local chunk = content:sub(offset, last)
        frame.previewMeasure:SetText(Literal(chunk))
        local chunkHeight = math.max(16, frame.previewMeasure:GetStringHeight() or 16)
        frame.previewChunks[#frame.previewChunks + 1] = {
            text = chunk, top = height, height = chunkHeight,
        }
        height = height + chunkHeight
        offset = last + 1
    end
    frame.previewMeasure:SetText("")
    frame.previewChild:SetSize(frame.previewWidth, math.max(1, height))
    frame.previewScroll:SetVerticalScroll(0)
    RenderPreview(frame)
end

local function UpdateSelection(frame, entry)
    frame.selectedEntry = entry
    frame.previewTitle:SetText(entry and Literal(entry.title) or L["Select a book to preview."])
    frame.previewMetadata:SetText(entry and string.format(
        L["Original collection: %s"], Literal(entry.collection or L["No Collection"])) or "")
    if entry then frame.restoreButton:Enable(); frame.deleteButton:Enable()
    else frame.restoreButton:Disable(); frame.deleteButton:Disable() end
    if frame.previewEntry ~= entry then
        frame.previewEntry = entry
        BuildPreview(frame, entry and entry.saved.content or "")
    else

        RenderPreview(frame)
    end
end

local function ValidPrompt(data)
    return data and data.frame:IsShown() and data.frame.session == data.session
        and data.frame.pendingConfirmation == data
end

local function ClearPrompt(data)
    if type(data) == "table" and data.frame and data.frame.pendingConfirmation == data then
        data.frame.pendingConfirmation = nil
        data.frame.confirmationPopup = nil
    end
end

local function DismissPrompt(frame)
    local data, popup = frame.pendingConfirmation, frame.confirmationPopup
    frame.pendingConfirmation, frame.confirmationPopup = nil, nil


    if data and popup and popup.data == data then popup:Hide() end
end

local function Confirm(frame, kind)
    local entry = frame.selectedEntry
    if kind == "entry" and not entry then return end
    DismissPrompt(frame)
    local data = {frame = frame, session = frame.session, id = entry and entry.id,
        entry = entry, snapshot = kind == "all" and ParchmentReader:CaptureTrashEntries() or nil}
    frame.pendingConfirmation = data
    local popup = StaticPopup_Show(kind == "all" and "PARCHMENTREADER_EMPTY_TRASH"
        or "PARCHMENTREADER_DELETE_TRASH", entry and Literal(entry.title) or nil, nil, data)
    if frame.pendingConfirmation == data then frame.confirmationPopup = popup end
end

local function RegisterConfirmations()
    local function dialog(text, action, all)
        return {
            text = text, button1 = action, button2 = L["Cancel"], timeout = 0,
            whileDead = true, hideOnEscape = true,
            OnAccept = function(_, data)
                if not ValidPrompt(data) then return end
                ClearPrompt(data)
                local removed
                if all then removed = ParchmentReader:EmptyTrash(data.snapshot) > 0
                else removed = ParchmentReader:DeleteTrashedBook(data.id, data.entry) end
                local message = L["This Trash entry is no longer available."]
                if removed then
                    if all then message = ParchmentReader:GetTrashCount() == 0 and L["Trash emptied."]
                        or L["Books permanently deleted. Other entries remain in Trash."]
                    else message = L["Book permanently deleted."] end
                end
                SetStatus(data.frame, message)
                ParchmentReader:RefreshTrashUI()
            end,
            OnCancel = function(_, data)
                ClearPrompt(data)
            end,
            OnHide = function(popup) ClearPrompt(popup.data) end,
        }
    end
    StaticPopupDialogs["PARCHMENTREADER_DELETE_TRASH"] = dialog(
        L["Permanently delete “%s”? This cannot be undone."], L["Delete Permanently"], false)
    StaticPopupDialogs["PARCHMENTREADER_EMPTY_TRASH"] = dialog(
        L["Permanently delete all books currently in Trash? This cannot be undone."], L["Empty Trash"], true)
end

function ParchmentReader:RefreshTrashUI()
    local frame = ParchmentReaderTrashFrame
    if not frame or not frame:IsShown() then return end
    local entries = self:GetTrashEntries()


    if #entries > 0 and frame:GetHeight() == 240 then SizeSession(frame, 360) end
    local selectedIndex, previousIndex
    for index, entry in ipairs(frame.entries or {}) do
        if entry.id == frame.selectedID then previousIndex = index; break end
    end
    for index, entry in ipairs(entries) do
        if entry.id == frame.selectedID then selectedIndex = index; break end
    end
    local changed = not selectedIndex
    if not selectedIndex and #entries > 0 then
        selectedIndex = math.min(previousIndex or 1, #entries)
    end
    frame.selectedID = selectedIndex and entries[selectedIndex].id or nil
    frame.entries = entries
    local visibleRows = frame.visibleRows or ROW_COUNT
    local offset = frame.offset or 0
    local movedVisibleSelection = previousIndex and previousIndex ~= selectedIndex
        and previousIndex > offset and previousIndex <= offset + visibleRows
    if selectedIndex and (changed or frame.revealSelection or movedVisibleSelection) then
        offset = math.max(selectedIndex - visibleRows, math.min(offset, selectedIndex - 1))
    end
    frame.revealSelection = nil
    frame.offset = math.max(0, math.min(offset, #entries - visibleRows))
    frame.listSlider:SetMinMaxValues(0, math.max(0, #entries - visibleRows))
    frame.listSlider:SetValue(frame.offset)
    frame.listSlider:SetShown(#entries > visibleRows)
    for index, row in ipairs(frame.rows) do
        local entry = index <= visibleRows and entries[index + frame.offset] or nil
        row.entry = entry
        row:SetShown(entry ~= nil)
        if entry then
            row:SetText(Literal(entry.title))
            row.details:SetText(Remaining(entry))
            PRUI.SetButtonSelected(row, entry.id == frame.selectedID)
            row.selectionRail:SetShown(entry.id == frame.selectedID)
        end
    end
    local populated = #entries > 0
    frame.emptyState:SetShown(not populated)
    for _, control in ipairs(frame.populatedControls) do control:SetShown(populated) end
    frame.countLabel:SetText(self:LocalizePlural("TRASH_BOOK_COUNT", #entries))
    UpdateSelection(frame, selectedIndex and entries[selectedIndex])
end

function ParchmentReader:CreateTrashFrame()
    local frame = PRUI.Window(UIParent, {name = "ParchmentReaderTrashFrame", title = L["Trash"]})
    frame:SetSize(620, 360)
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    frame:SetToplevel(true)
    PRUI.SetAddonFrameLayer(frame, PRUI.ADDON_FRAME_LEVELS.WINDOW)
    self:RegisterEscapeClose("ParchmentReaderTrashFrame")
    frame.session, frame.rows, frame.previewPool = 0, {}, {}
    RegisterConfirmations()

    local retention = Label(frame, L["Books in Trash are permanently deleted after 30 days."])
    retention:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -44)
    retention:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -44)
    retention:SetHeight(28)
    retention:SetJustifyV("TOP")
    retention:SetWordWrap(true)
    frame.retention = retention

    local list = CreateFrame("Frame", nil, frame)
    list:SetSize(208, 4 * ROW_HEIGHT)
    list:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -104)
    list:EnableMouseWheel(true)
    frame.list = list
    local slider = CreateFrame("Slider", nil, frame)
    slider:SetPoint("TOPLEFT", list, "TOPRIGHT", 1, 0)
    slider:SetSize(5, 4 * ROW_HEIGHT)
    slider:SetOrientation("VERTICAL")
    slider:SetValueStep(1)
    slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    slider:GetThumbTexture():SetSize(4, 24)
    Theme:BindColor(slider:GetThumbTexture(), "SetVertexColor", Theme:Get("accent", "goldDim"))
    slider:SetMinMaxValues(0, 0)
    slider:SetValue(0)
    slider:SetScript("OnValueChanged", function(_, value)
        local offset = math.floor(value + 0.5)
        if frame.offset == offset then return end
        frame.offset = offset
        ParchmentReader:RefreshTrashUI()
    end)
    frame.listSlider = slider
    list:SetScript("OnMouseWheel", function(_, delta)
        slider:SetValue((frame.offset or 0) - delta)
    end)
    for index = 1, ROW_COUNT do
        local row = PRUI.Button(list, "", {width = 208, height = ROW_HEIGHT, justifyH = "LEFT"})
        QuietButton(row)
        row:SetPoint("TOPLEFT", list, "TOPLEFT", 0, -(index - 1) * ROW_HEIGHT)
        row.label:ClearAllPoints()
        row.label:SetPoint("TOPLEFT", row.pruiContent, "TOPLEFT", 7, -6)
        row.label:SetPoint("TOPRIGHT", row.pruiContent, "TOPRIGHT", -7, -6)
        row.details = Label(row.pruiContent)
        row.details:SetPoint("BOTTOMLEFT", row.pruiContent, "BOTTOMLEFT", 7, 5)
        row.details:SetPoint("BOTTOMRIGHT", row.pruiContent, "BOTTOMRIGHT", -7, 5)
        row.details:SetWordWrap(false)
        row.divider = row:CreateTexture(nil, "BORDER")
        row.divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 7, 0)
        row.divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -7, 0)
        row.divider:SetHeight(1)
        Theme:BindColor(row.divider, "SetColorTexture", Theme:Get("border", "subtle"))
        row.selectionRail = row:CreateTexture(nil, "BORDER")
        row.selectionRail:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -5)
        row.selectionRail:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 5)
        row.selectionRail:SetWidth(2)
        Theme:BindColor(row.selectionRail, "SetColorTexture", Theme:Get("accent", "gold"))
        PRUI.AttachTooltip(row, function(button)
            local entry = button.entry
            return entry and Literal(entry.title) .. "\n" .. string.format(
                L["Original collection: %s"], Literal(entry.collection or L["No Collection"]))
                .. "\n" .. Remaining(entry) or ""
        end)
        row:SetScript("OnClick", function(button)
            if not button.entry then return end
            frame.selectedID = button.entry.id
            frame.revealSelection = true
            SetStatus(frame, "")
            ParchmentReader:RefreshTrashUI()
        end)
        frame.rows[index] = row
    end
    frame.countLabel = Label(frame)
    frame.countLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -80)
    frame.countLabel:SetWidth(208)
    frame.countLabel:SetHeight(16)
    frame.paneDivider = frame:CreateTexture(nil, "BORDER")
    frame.paneDivider:SetPoint("TOPLEFT", frame, "TOPLEFT", 232, -80)
    frame.paneDivider:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 232, 52)
    frame.paneDivider:SetWidth(1)
    Theme:BindColor(frame.paneDivider, "SetColorTexture", Theme:Get("border", "subtle"))

    frame.emptyState = CreateFrame("Frame", nil, frame)
    frame.emptyState:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -44)
    frame.emptyState:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)
    frame.emptyIcon = frame.emptyState:CreateTexture(nil, "ARTWORK")
    frame.emptyIcon:SetTexture("Interface\\AddOns\\ParchmentReader\\Assets\\Trash")
    frame.emptyIcon:SetSize(28, 28)
    frame.emptyIcon:SetPoint("CENTER", frame.emptyState, "CENTER", 0, 36)
    Theme:BindIconColor(frame.emptyIcon, Theme:Get("text", "muted"))
    frame.emptyText = Label(frame.emptyState, L["Trash is empty."], "secondary", "GameFontNormal")
    frame.emptyText:SetPoint("TOP", frame.emptyIcon, "BOTTOM", 0, -12)
    frame.emptyText:SetWidth(540)
    frame.emptyText:SetJustifyH("CENTER")
    frame.emptyHint = Label(frame.emptyState, L["Restore deleted books within 30 days."], "muted")
    frame.emptyHint:SetPoint("TOP", frame.emptyText, "BOTTOM", 0, -8)
    frame.emptyHint:SetWidth(540)
    frame.emptyHint:SetJustifyH("CENTER")
    frame.emptyHint:SetWordWrap(true)

    frame.previewTitle = Label(frame, "", "primary", "GameFontNormal")
    frame.previewTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 240, -80)
    frame.previewTitle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, -80)
    frame.previewTitle:SetHeight(18)
    frame.previewTitle:SetWordWrap(false)
    frame.previewMetadata = Label(frame)
    frame.previewMetadata:SetPoint("TOPLEFT", frame.previewTitle, "BOTTOMLEFT", 0, -6)
    frame.previewMetadata:SetPoint("TOPRIGHT", frame.previewTitle, "BOTTOMRIGHT", 0, -6)
    frame.previewMetadata:SetHeight(16)
    frame.previewMetadata:SetWordWrap(false)
    local scroll = CreateFrame("ScrollFrame", "ParchmentReaderTrashPreviewScroll", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 240, -132)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 92)
    scroll:SetClipsChildren(true)
    PRUI.StyleScrollFrame(scroll)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(1, 1)
    scroll:SetScrollChild(child)
    frame.previewScroll, frame.previewChild = scroll, child
    frame.previewMeasure = PreviewText(frame)
    frame.previewMeasure:Hide()
    scroll:HookScript("OnVerticalScroll", function() RenderPreview(frame) end)



    frame.restoreButton = PRUI.Button(frame, L["Restore"], {width = 136, height = 28})
    PRUI.SetButtonBorderColor(frame.restoreButton, Theme:Get("accent", "gold"))
    PRUI.SetButtonTextColor(frame.restoreButton, Theme:Get("accent", "gold"))
    frame.restoreButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 240, 16)
    frame.restoreButton:SetScript("OnClick", function()
        local entry = frame.selectedEntry
        if not entry then return end
        local ok, key = ParchmentReader:RestoreTrashedBook(entry.id, entry)
        if not ok then SetStatus(frame, L["This Trash entry could not be restored."])
        else
            local book = ParchmentReader.books[key]
            local message = string.format(L["Restored “%s”."], Literal(book.title))
            local status = L["Book restored."]
            if book.collection ~= entry.collection then
                message = message .. " " .. L["The original collection no longer exists; restored without a collection."]
                status = L["Restored without a collection."]
            end
            if book.title ~= entry.title then
                message = message .. " " .. L["The title was changed to avoid replacing another book."]
                status = (book.collection ~= entry.collection and status .. "\n" or "")
                    .. L["Renamed to avoid a duplicate title."]
            end
            SetStatus(frame, status, message)
        end
        ParchmentReader:RefreshTrashUI()
    end)
    frame.deleteButton = PRUI.Button(frame, L["Delete Permanently"], {width = 210, height = 28})
    PRUI.SetButtonBorderColor(frame.deleteButton, Theme:Get("border", "elevated"))
    FitButton(frame.deleteButton, 126, 196)
    frame.deleteButton:SetPoint("LEFT", frame.restoreButton, "RIGHT", 8, 0)
    frame.deleteButton:SetScript("OnClick", function() Confirm(frame, "entry") end)
    PRUI.AttachTooltip(frame.deleteButton, L["Delete Permanently"])
    frame.status = Label(frame)
    frame.status:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 240, 52)
    frame.status:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 52)
    frame.status:SetHeight(34)
    frame.status:SetJustifyV("TOP")
    frame.status:SetWordWrap(true)
    frame.statusHit = CreateFrame("Frame", nil, frame)
    frame.statusHit:SetAllPoints(frame.status)
    frame.statusHit:EnableMouse(true)
    PRUI.AttachTooltip(frame.statusHit, function() return frame.statusTooltip end, {wrapText = true})
    frame.emptyButton = PRUI.Button(frame, L["Empty Trash"], {width = 136, height = 28})
    PRUI.SetButtonBorderColor(frame.emptyButton, Theme:Get("border", "elevated"))
    FitButton(frame.emptyButton, 136, 208)
    frame.emptyButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 16)
    frame.emptyButton:SetScript("OnClick", function() Confirm(frame, "all") end)
    PRUI.AttachTooltip(frame.emptyButton, L["Empty Trash"])
    frame.populatedControls = {retention, list, frame.countLabel, frame.paneDivider,
        frame.previewTitle, frame.previewMetadata, scroll, frame.restoreButton,
        frame.deleteButton, frame.emptyButton}
    frame:HookScript("OnHide", function()
        frame.session = frame.session + 1
        DismissPrompt(frame)
    end)


    local function RefreshTimeLabels(session)
        C_Timer.After(30, function()
            if not frame:IsShown() or frame.session ~= session then return end
            ParchmentReader:RefreshTrashUI()
            RefreshTimeLabels(session)
        end)
    end
    frame:HookScript("OnShow", function() RefreshTimeLabels(frame.session) end)
    frame:Hide()
    return frame
end

function ParchmentReader:ShowTrash()
    self:PruneTrash()
    if self.HideReaderMenus then self:HideReaderMenus() end
    if self.SetReaderKeyboardFocus then self:SetReaderKeyboardFocus(false) end
    local reader = ParchmentReaderFrame
    if reader and reader.searchBox then reader.searchBox:ClearFocus() end
    for _, editor in pairs({ParchmentReaderEditorFrame, ParchmentReaderQuickNoteFrame}) do
        if editor.titleInput then editor.titleInput:ClearFocus() end
        if editor.contentInput then editor.contentInput:ClearFocus() end
    end
    local frame = ParchmentReaderTrashFrame or self:CreateTrashFrame()
    if not frame:IsShown() then
        local count = #self:GetTrashEntries()
        local height = count == 0 and 240 or (count <= 4 and 360 or (count == 5 and 382 or 420))
        SizeSession(frame, height)
        frame.revealSelection = true
        frame.session = frame.session + 1
        SetStatus(frame, "")
    end
    local settings = ParchmentReaderSettingsFrame
    PRUI.SetAddonFrameLayer(frame, math.max(PRUI.ADDON_FRAME_LEVELS.WINDOW,
        (reader and reader:GetFrameLevel() or 0) + 20,
        (settings and settings:IsShown() and settings:GetFrameLevel() or 0) + 20))
    frame:Show()
    frame:Raise()
    self:RefreshTrashUI()
end
