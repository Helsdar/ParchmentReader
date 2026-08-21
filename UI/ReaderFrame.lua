


local Theme = ParchmentReader.Theme
local PRUI = ParchmentReader.PRUI
local L = ParchmentReader.L
local COLLECTION_ROW_POOL_SIZE = 10
local COLLECTION_ROW_HEIGHT = 24
local BOOK_MOVE_ROW_POOL_SIZE = 10
local BOOK_MOVE_ROW_HEIGHT = 24
local BOOKMARK_ROW_POOL_SIZE = 6
local BOOKMARK_ROW_HEIGHT = 40
local BOOKMARK_POPOVER_MAX_WIDTH = 340
local BOOKMARK_POPOVER_HEADER_HEIGHT = 38
local BOOKMARK_POPOVER_FOOTER_HEIGHT = 38
local BOOKMARK_POPOVER_MARGIN = 6
local READER_FOCUS_MODIFIER_KEYS = {
    LALT = true,
    LCTRL = true,
    LSHIFT = true,
    RALT = true,
    RCTRL = true,
    RSHIFT = true,
}
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
    ["Ä"] = "ä", ["Æ"] = "æ", ["Ç"] = "ç", ["É"] = "é",
    ["È"] = "è", ["Ê"] = "ê", ["Ë"] = "ë", ["Í"] = "í",
    ["Î"] = "î", ["Ï"] = "ï", ["Ñ"] = "ñ", ["Ó"] = "ó",
    ["Ô"] = "ô", ["Ö"] = "ö", ["Œ"] = "œ", ["Ú"] = "ú",
    ["Ù"] = "ù", ["Û"] = "û", ["Ü"] = "ü", ["Ÿ"] = "ÿ",
    ["ẞ"] = "ß",
}

local function Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end

local function CollectionExists(name)
    for _, collectionName in ipairs(ParchmentReaderDB.collections or {}) do
        if collectionName == name then return true end
    end
    return false
end

local function SetFontStringColor(fontString, color)
    fontString:SetTextColor(color[1], color[2], color[3], color[4])
end

local function SetTextureColor(texture, color)
    texture:SetVertexColor(color[1], color[2], color[3], color[4])
end

local function RefreshPinButtonColor(button)
    PRUI.SetButtonTextColor(
        button,
        ParchmentReader:IsReaderPinned()
            and Theme:Get("accent", "gold")
            or nil)
end

local function NormalizeSearchText(value)
    local normalized = string.lower(value or "")
    for upper, lower in pairs(SEARCH_CASE_FOLD) do
        normalized = string.gsub(normalized, upper, lower)
    end
    return strtrim(normalized)
end

local function GetSearchTerms(value)
    local terms = {}
    for term in string.gmatch(NormalizeSearchText(value), "%S+") do
        terms[#terms + 1] = term
    end
    return terms
end

local function BookMatchesSearch(bookData, terms)
    if #terms == 0 then return true end

    local searchableText = NormalizeSearchText(
        (bookData.title or "") .. " " .. (bookData.collection or ""))
    for _, term in ipairs(terms) do
        if not string.find(searchableText, term, 1, true) then
            return false
        end
    end
    return true
end

local function ConfigureOutsideDismiss(frame, relatedFrameGetter)
    frame:HookScript("OnShow", function(self)
        self:RegisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    frame:HookScript("OnHide", function(self)
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    frame:SetScript("OnEvent", function(self, event)
        if event ~= "GLOBAL_MOUSE_DOWN" or self:IsMouseOver() then return end
        if self.owner and self.owner:IsMouseOver() then return end
        local relatedFrame = relatedFrameGetter and relatedFrameGetter()
        if relatedFrame and relatedFrame:IsShown() and relatedFrame:IsMouseOver() then
            return
        end
        self:Hide()
    end)
end

local function GetCollectionNameDialog()
    local dialog = _G.ParchmentReaderCollectionNameDialog
    if dialog then return dialog end

    dialog = PRUI.Panel(UIParent, {
        name = "ParchmentReaderCollectionNameDialog",
        color = Theme:Get("bg", "base"),
        shadow = true,
    })
    dialog:SetSize(320, 150)
    dialog:SetPoint("CENTER")
    PRUI.SetAddonFrameLayer(dialog, PRUI.ADDON_FRAME_LEVELS.MODAL)
    dialog:SetClampedToScreen(true)
    ParchmentReader:RegisterEscapeClose("ParchmentReaderCollectionNameDialog")

    local topbar = PRUI.Panel(dialog, {color = Theme:Get("bg", "sidebar")})
    topbar:SetPoint("TOPLEFT", 1, -1)
    topbar:SetPoint("TOPRIGHT", -1, -1)
    topbar:SetHeight(30)
    PRUI.MakeMovable(dialog, topbar)

    dialog.title = topbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dialog.title:SetPoint("CENTER")
    SetFontStringColor(dialog.title, Theme:Get("text", "primary"))

    local label = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -44)
    label:SetText(L["Collection name"])
    SetFontStringColor(label, Theme:Get("text", "secondary"))

    local input = CreateFrame("EditBox", nil, dialog)
    input:SetPoint("TOPLEFT", dialog, "TOPLEFT", 16, -64)
    input:SetPoint("TOPRIGHT", dialog, "TOPRIGHT", -16, -64)
    input:SetHeight(24)
    input:SetAutoFocus(false)
    input:SetMaxLetters(50)
    input:SetFontObject("GameFontNormal")
    input:SetTextInsets(8, 8, 0, 0)
    SetFontStringColor(input, Theme:Get("text", "primary"))
    local inputBackground = input:CreateTexture(nil, "BACKGROUND")
    inputBackground:SetAllPoints()
    local controlColor = Theme:Get("bg", "control")
    inputBackground:SetColorTexture(
        controlColor[1], controlColor[2], controlColor[3], controlColor[4])
    PRUI.AddBorder(input, Theme:Get("border", "subtle"))
    dialog.input = input

    dialog.errorText = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dialog.errorText:SetPoint("TOPLEFT", input, "BOTTOMLEFT", 2, -4)
    dialog.errorText:SetText(
        L["A collection with this name already exists."])
    SetFontStringColor(dialog.errorText, Theme:Get("state", "danger"))
    dialog.errorText:Hide()

    dialog.acceptButton = PRUI.Button(
        dialog, L["Create"], {width = 140, height = 24})
    dialog.acceptButton:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 16, 12)

    local cancelButton = PRUI.Button(
        dialog, L["Cancel"], {width = 110, height = 24})
    cancelButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -16, 12)
    cancelButton:SetScript("OnClick", function()
        dialog:Hide()
    end)

    local function Submit()
        local name = strtrim(dialog.input:GetText() or "")
        if name == "" then return end
        if name ~= dialog.oldName and CollectionExists(name) then
            dialog.errorText:Show()
            return
        end

        dialog:Hide()
        if dialog.oldName then
            ParchmentReader:RenameCollection(dialog.oldName, name)
        else
            ParchmentReader:AddCollection(name)
        end
    end

    dialog.acceptButton:SetScript("OnClick", Submit)
    input:SetScript("OnEnterPressed", Submit)
    input:SetScript("OnEscapePressed", function()
        dialog:Hide()
    end)
    input:SetScript("OnTextChanged", function()
        dialog.errorText:Hide()
    end)
    dialog:Hide()
    return dialog
end

local function ShowCollectionNameDialog(oldName)
    local dialog = GetCollectionNameDialog()
    dialog.oldName = oldName
    dialog.title:SetText(oldName and L["Rename Collection"] or L["New Collection"])
    dialog.acceptButton:SetText(oldName and L["Rename"] or L["Create"])
    dialog.input:SetText(oldName or "")
    dialog.errorText:Hide()
    dialog:Show()
    dialog.input:SetFocus()
    if oldName then
        dialog.input:HighlightText()
    end
end

local function GetDeleteCollectionDialog()
    local dialog = _G.ParchmentReaderDeleteCollectionDialog
    if dialog then return dialog end

    dialog = PRUI.Panel(UIParent, {
        name = "ParchmentReaderDeleteCollectionDialog",
        color = Theme:Get("bg", "base"),
        shadow = true,
    })
    dialog:SetSize(440, 174)
    dialog:SetPoint("CENTER")
    PRUI.SetAddonFrameLayer(dialog, PRUI.ADDON_FRAME_LEVELS.MODAL)
    dialog:SetClampedToScreen(true)
    ParchmentReader:RegisterEscapeClose("ParchmentReaderDeleteCollectionDialog")

    local topbar = PRUI.Panel(dialog, {color = Theme:Get("bg", "sidebar")})
    topbar:SetPoint("TOPLEFT", 1, -1)
    topbar:SetPoint("TOPRIGHT", -1, -1)
    topbar:SetHeight(30)
    PRUI.MakeMovable(dialog, topbar)

    local title = topbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("CENTER")
    title:SetText(L["Delete Collection"])
    SetFontStringColor(title, Theme:Get("text", "primary"))

    dialog.message = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dialog.message:SetPoint("TOPLEFT", dialog, "TOPLEFT", 20, -46)
    dialog.message:SetPoint("TOPRIGHT", dialog, "TOPRIGHT", -20, -46)
    dialog.message:SetJustifyH("CENTER")
    dialog.message:SetText(
        L["Books in this collection will be moved to No Collection."])
    SetFontStringColor(dialog.message, Theme:Get("text", "secondary"))

    dialog.errorText = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dialog.errorText:SetPoint("TOPLEFT", dialog.message, "BOTTOMLEFT", 0, -8)
    dialog.errorText:SetPoint("TOPRIGHT", dialog.message, "BOTTOMRIGHT", 0, -8)
    dialog.errorText:SetJustifyH("CENTER")
    SetFontStringColor(dialog.errorText, Theme:Get("state", "danger"))
    dialog.errorText:Hide()

    dialog.deleteButton = PRUI.Button(
        dialog, L["Delete"], {width = 140, height = 24})
    dialog.deleteButton:SetPoint("BOTTOMLEFT", dialog, "BOTTOMLEFT", 20, 14)
    PRUI.SetButtonTextColor(dialog.deleteButton, Theme:Get("state", "danger"))
    dialog.deleteButton:SetScript("OnClick", function()
        local collectionName = dialog.collectionName
        local deleted, reason, title =
            ParchmentReader:DeleteCollection(collectionName)
        if not deleted then
            if reason == "duplicate" then
                dialog.errorText:SetText(string.format(
                    L["Move or rename “%s” first; No Collection already has that title."],
                    title or L["this book"]))
            elseif reason == "editing" then
                dialog.errorText:SetText(L[
                    "Close the open book editor before deleting this collection."])
            else
                dialog.errorText:SetText(
                    L["The collection could not be deleted safely."])
            end
            dialog.errorText:Show()
            return
        end

        dialog:Hide()
    end)

    local cancelButton = PRUI.Button(
        dialog, L["Cancel"], {width = 110, height = 24})
    cancelButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -20, 14)
    cancelButton:SetScript("OnClick", function()
        dialog:Hide()
    end)
    dialog:Hide()
    return dialog
end

local function ShowDeleteCollectionDialog(collectionName)
    local dialog = GetDeleteCollectionDialog()
    dialog.collectionName = collectionName
    dialog.errorText:Hide()
    dialog.message:SetText(string.format(
        L["Delete |cFFD1AD61%s|r?\nIts books will be moved to No Collection."],
        collectionName))
    dialog:Show()
end

local function GetCollectionContextMenu()
    local menu = _G.ParchmentReaderCollectionContextMenu
    if menu then return menu end

    menu = PRUI.Panel(UIParent, {
        name = "ParchmentReaderCollectionContextMenu",
        color = Theme:Get("bg", "base"),
        shadow = true,
    })
    menu:SetSize(226, 56)
    PRUI.SetAddonFrameLayer(menu, PRUI.ADDON_FRAME_LEVELS.POPOVER)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    ParchmentReader:RegisterEscapeClose("ParchmentReaderCollectionContextMenu")

    menu.renameButton = PRUI.Button(menu, L["Rename Collection"], {
        width = 216,
        height = 23,
        justifyH = "LEFT",
    })
    menu.renameButton:SetPoint("TOPLEFT", menu, "TOPLEFT", 5, -5)
    menu.renameButton.label:ClearAllPoints()
    menu.renameButton.label:SetPoint("LEFT", menu.renameButton.pruiContent, "LEFT", 8, 0)
    menu.renameButton.label:SetPoint("RIGHT", menu.renameButton.pruiContent, "RIGHT", -8, 0)

    menu.deleteButton = PRUI.Button(menu, L["Delete Collection"], {
        width = 216,
        height = 23,
        justifyH = "LEFT",
    })
    menu.deleteButton:SetPoint("TOPLEFT", menu.renameButton, "BOTTOMLEFT", 0, 0)
    menu.deleteButton.label:ClearAllPoints()
    menu.deleteButton.label:SetPoint("LEFT", menu.deleteButton.pruiContent, "LEFT", 8, 0)
    menu.deleteButton.label:SetPoint("RIGHT", menu.deleteButton.pruiContent, "RIGHT", -8, 0)
    PRUI.SetButtonTextColor(menu.deleteButton, Theme:Get("state", "danger"))

    menu.renameButton:SetScript("OnClick", function()
        local name = menu.collectionName
        menu:Hide()
        if ParchmentReaderFrame and ParchmentReaderFrame.collectionPopover then
            ParchmentReaderFrame.collectionPopover:Hide()
        end
        ShowCollectionNameDialog(name)
    end)
    menu.deleteButton:SetScript("OnClick", function()
        local name = menu.collectionName
        menu:Hide()
        if ParchmentReaderFrame and ParchmentReaderFrame.collectionPopover then
            ParchmentReaderFrame.collectionPopover:Hide()
        end
        ShowDeleteCollectionDialog(name)
    end)

    ConfigureOutsideDismiss(menu, function()
        return ParchmentReaderFrame and ParchmentReaderFrame.collectionPopover
    end)
    menu:Hide()
    return menu
end

local function ShowCollectionContextMenu(collectionName, anchor)
    local menu = GetCollectionContextMenu()
    menu.collectionName = collectionName
    menu.owner = anchor
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 4, 0)
    menu:Show()
end

local function BuildCollectionItems()
    local items = {{label = L["All Books"], isAll = true}}
    for _, collectionName in ipairs(ParchmentReaderDB.collections or {}) do
        items[#items + 1] = {
            label = collectionName,
            name = collectionName,
        }
    end
    return items
end

local function SetCollectionRowSelected(row, selected)
    PRUI.SetButtonSelected(row, false)

    local background = Theme:Get("bg", selected and "popoverAction" or "popoverRow")
    row.pruiBackground:SetColorTexture(
        background[1], background[2], background[3], background[4])
    PRUI.SetButtonBorderColor(
        row, Theme:Get("border", selected and "elevated" or "subtle"))
    PRUI.SetButtonTextColor(
        row,
        Theme:Get(selected and "accent" or "text", selected and "gold" or "secondary"))

    row.label:ClearAllPoints()
    row.label:SetPoint("LEFT", row.pruiContent, "LEFT", selected and 15 or 10, 0)
    row.label:SetPoint("RIGHT", row.pruiContent, "RIGHT", selected and -47 or -8, 0)
    if selected then
        row.selectedRail:Show()
        row.activeLabel:Show()
    else
        row.selectedRail:Hide()
        row.activeLabel:Hide()
    end
end

local function RefreshCollectionPopover(popover)
    popover.items = BuildCollectionItems()
    local itemCount = #popover.items
    local visibleCount = math.min(itemCount, COLLECTION_ROW_POOL_SIZE)
    local maximumOffset = math.max(0, itemCount - COLLECTION_ROW_POOL_SIZE)
    popover.offset = Clamp(popover.offset or 0, 0, maximumOffset)
    popover:SetHeight(68 + visibleCount * COLLECTION_ROW_HEIGHT)

    for poolIndex, row in ipairs(popover.rows) do
        local item = popover.items[popover.offset + poolIndex]
        if item then
            row.item = item
            row:SetText(item.label)
            local isSelected = item.isAll
                and ParchmentReader.currentCollection == nil
                or item.name == ParchmentReader.currentCollection
            SetCollectionRowSelected(row, isSelected)
            row:Show()
        else
            row.item = nil
            row:Hide()
        end
    end

    if maximumOffset > 0 then
        popover.scrollHint:Show()
    else
        popover.scrollHint:Hide()
    end
end

local function CreateCollectionPopover(readerFrame)
    local popover = PRUI.Panel(UIParent, {
        name = "ParchmentReaderCollectionPopover",
        color = Theme:Get("bg", "popover"),
        borderColor = Theme:Get("border", "elevated"),
        shadow = true,
    })
    popover:SetWidth(224)
    PRUI.SetAddonFrameLayer(popover, PRUI.ADDON_FRAME_LEVELS.POPOVER)
    popover:SetClampedToScreen(true)
    popover:EnableMouse(true)
    popover:EnableMouseWheel(true)
    popover.offset = 0
    popover.rows = {}
    ParchmentReader:RegisterEscapeClose("ParchmentReaderCollectionPopover")

    local strongShadow = Theme:Get("shadow", "strong")
    for _, texture in pairs(popover.pruiShadow or {}) do
        texture:SetColorTexture(
            strongShadow[1], strongShadow[2], strongShadow[3], strongShadow[4])
    end

    local headerSurface = popover:CreateTexture(nil, "BACKGROUND", nil, -6)
    headerSurface:SetPoint("TOPLEFT", popover, "TOPLEFT", 1, -1)
    headerSurface:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -1, -1)
    headerSurface:SetHeight(23)
    local actionColor = Theme:Get("bg", "popoverAction")
    headerSurface:SetColorTexture(
        actionColor[1], actionColor[2], actionColor[3], actionColor[4])

    local headerLabel = popover:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerLabel:SetPoint("LEFT", popover, "TOPLEFT", 9, -13)
    headerLabel:SetText(L["COLLECTIONS"])
    SetFontStringColor(headerLabel, Theme:Get("accent", "gold"))

    local headerRule = popover:CreateTexture(nil, "BORDER")
    headerRule:SetPoint("TOPLEFT", popover, "TOPLEFT", 1, -24)
    headerRule:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -1, -24)
    headerRule:SetHeight(1)
    local elevatedBorder = Theme:Get("border", "elevated")
    headerRule:SetColorTexture(
        elevatedBorder[1], elevatedBorder[2], elevatedBorder[3], elevatedBorder[4])

    for index = 1, COLLECTION_ROW_POOL_SIZE do
        local row = PRUI.Button(popover, "", {
            height = COLLECTION_ROW_HEIGHT,
            justifyH = "LEFT",
        })
        row:SetPoint("TOPLEFT", popover, "TOPLEFT", 5, -(28 + (index - 1) * COLLECTION_ROW_HEIGHT))
        row:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -5, -(28 + (index - 1) * COLLECTION_ROW_HEIGHT))
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        local rowColor = Theme:Get("bg", "popoverRow")
        row.pruiBackground:SetColorTexture(
            rowColor[1], rowColor[2], rowColor[3], rowColor[4])
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", row.pruiContent, "LEFT", 10, 0)
        row.label:SetPoint("RIGHT", row.pruiContent, "RIGHT", -8, 0)
        row.label:SetJustifyH("LEFT")

        local selectedRail = row.pruiContent:CreateTexture(nil, "ARTWORK")
        selectedRail:SetPoint("TOPLEFT", row.pruiContent, "TOPLEFT", 4, -4)
        selectedRail:SetPoint("BOTTOMLEFT", row.pruiContent, "BOTTOMLEFT", 4, 4)
        selectedRail:SetWidth(2)
        local gold = Theme:Get("accent", "gold")
        selectedRail:SetColorTexture(gold[1], gold[2], gold[3], gold[4])
        row.selectedRail = selectedRail

        local activeLabel = row.pruiContent:CreateFontString(
            nil, "OVERLAY", "GameFontNormalSmall")
        activeLabel:SetPoint("RIGHT", row.pruiContent, "RIGHT", -7, 0)
        activeLabel:SetText(L["ACTIVE"])
        activeLabel:SetScale(0.80)
        SetFontStringColor(activeLabel, gold)
        row.activeLabel = activeLabel

        row:SetScript("OnClick", function(button, mouseButton)
            local item = button.item
            if not item then return end
            if mouseButton == "RightButton" and not item.isAll then
                ShowCollectionContextMenu(item.name, button)
                return
            end

            local contextMenu = _G.ParchmentReaderCollectionContextMenu
            if contextMenu then contextMenu:Hide() end
            popover:Hide()
            ParchmentReader:SetCollection(item.isAll and nil or item.name)
        end)
        PRUI.AttachTooltip(row, function(button)
            return button.item and button.item.label
        end)
        popover.rows[index] = row
    end

    local separator = popover:CreateTexture(nil, "BORDER")
    separator:SetPoint("BOTTOMLEFT", popover, "BOTTOMLEFT", 8, 32)
    separator:SetPoint("BOTTOMRIGHT", popover, "BOTTOMRIGHT", -8, 32)
    separator:SetHeight(1)
    local border = Theme:Get("border", "subtle")
    separator:SetColorTexture(border[1], border[2], border[3], border[4])

    local addButton = PRUI.Button(popover, L["+  Add Collection"], {
        height = 25,
        justifyH = "LEFT",
    })
    addButton:SetPoint("BOTTOMLEFT", popover, "BOTTOMLEFT", 5, 5)
    addButton:SetPoint("BOTTOMRIGHT", popover, "BOTTOMRIGHT", -5, 5)
    addButton.pruiBackground:SetColorTexture(
        actionColor[1], actionColor[2], actionColor[3], actionColor[4])
    PRUI.SetButtonBorderColor(addButton, Theme:Get("accent", "goldDim"))
    PRUI.SetButtonTextColor(addButton, Theme:Get("accent", "gold"))
    addButton.label:ClearAllPoints()
    addButton.label:SetPoint("LEFT", addButton.pruiContent, "LEFT", 8, 0)
    addButton.label:SetPoint("RIGHT", addButton.pruiContent, "RIGHT", -8, 0)
    addButton:SetScript("OnClick", function()
        local contextMenu = _G.ParchmentReaderCollectionContextMenu
        if contextMenu then contextMenu:Hide() end
        popover:Hide()
        ShowCollectionNameDialog(nil)
    end)

    popover.scrollHint = popover:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    popover.scrollHint:SetPoint("BOTTOMRIGHT", popover, "BOTTOMRIGHT", -8, 35)
    popover.scrollHint:SetText("↕")
    SetFontStringColor(popover.scrollHint, Theme:Get("text", "muted"))

    popover:SetScript("OnMouseWheel", function(_, delta)
        local maximumOffset = math.max(0, #popover.items - COLLECTION_ROW_POOL_SIZE)
        popover.offset = Clamp(popover.offset - delta, 0, maximumOffset)
        RefreshCollectionPopover(popover)
    end)
    ConfigureOutsideDismiss(popover, function()
        return _G.ParchmentReaderCollectionContextMenu
    end)
    popover:HookScript("OnShow", function()
        PRUI.SetButtonSelected(readerFrame.collectionSelector, true)
        readerFrame.collectionSelector.chevron:SetText("^")
    end)
    popover:HookScript("OnHide", function()
        PRUI.SetButtonSelected(readerFrame.collectionSelector, false)
        readerFrame.collectionSelector.chevron:SetText("v")
    end)
    popover:Hide()
    return popover
end

function ParchmentReader:ToggleCollectionPopover(anchor)
    local frame = ParchmentReaderFrame
    if not frame then return end
    local bookMenu = _G.ParchmentReaderBookContextMenu
    if bookMenu then bookMenu:Hide() end
    local popover = frame.collectionPopover
    if popover:IsShown() then
        local contextMenu = _G.ParchmentReaderCollectionContextMenu
        if contextMenu then contextMenu:Hide() end
        popover:Hide()
        return
    end

    popover.owner = anchor
    popover.offset = 0
    popover:SetWidth(math.max(160, anchor:GetWidth()))
    RefreshCollectionPopover(popover)
    popover:ClearAllPoints()
    popover:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
    popover:Show()
end

function ParchmentReader:RefreshCollectionSelector()
    local frame = ParchmentReaderFrame
    if not frame then return end

    local label = self.currentCollection or L["All Books"]
    frame.collectionSelector:SetText(label)
    frame.collectionSelector.fullLabel = label
    local hasCollectionFilter = self.currentCollection ~= nil
    PRUI.SetButtonTextColor(
        frame.collectionSelector,
        Theme:Get(
            hasCollectionFilter and "accent" or "text",
            hasCollectionFilter and "gold" or "secondary"))
    frame.collectionSelector.collectionAccent:SetShown(hasCollectionFilter)
    if frame.collectionPopover:IsShown() then
        RefreshCollectionPopover(frame.collectionPopover)
    end
end

local function BuildBookMoveItems()
    local items = {{label = L["No Collection"]}}
    for _, collectionName in ipairs(ParchmentReaderDB.collections or {}) do
        items[#items + 1] = {
            label = collectionName,
            collection = collectionName,
        }
    end
    return items
end

local function SetBookMoveRowSelected(row, selected)
    local background = Theme:Get("bg", selected and "popoverAction" or "popoverRow")
    row.pruiBackground:SetColorTexture(
        background[1], background[2], background[3], background[4])
    PRUI.SetButtonBorderColor(
        row, Theme:Get("border", selected and "elevated" or "subtle"))
    PRUI.SetButtonTextColor(
        row,
        Theme:Get(selected and "accent" or "text", selected and "gold" or "secondary"))
    row.label:ClearAllPoints()
    row.label:SetPoint("LEFT", row.pruiContent, "LEFT", selected and 15 or 10, 0)
    row.label:SetPoint("RIGHT", row.pruiContent, "RIGHT", selected and -57 or -8, 0)
    if selected then
        row.selectedRail:Show()
        row.currentLabel:Show()
    else
        row.selectedRail:Hide()
        row.currentLabel:Hide()
    end
    row.isCurrent = selected
end

local function RefreshBookMovePopover(popover)
    popover.items = BuildBookMoveItems()
    local itemCount = #popover.items
    local visibleCount = math.min(itemCount, BOOK_MOVE_ROW_POOL_SIZE)
    local maximumOffset = math.max(0, itemCount - BOOK_MOVE_ROW_POOL_SIZE)
    popover.offset = Clamp(popover.offset or 0, 0, maximumOffset)
    popover:SetHeight(34 + visibleCount * BOOK_MOVE_ROW_HEIGHT)

    local book = ParchmentReader.books[popover.bookKey]
    for poolIndex, row in ipairs(popover.rows) do
        local item = popover.items[popover.offset + poolIndex]
        if item and book then
            row.item = item
            row:SetText(item.label)
            SetBookMoveRowSelected(row, book.collection == item.collection)
            row:Show()
        else
            row.item = nil
            row:Hide()
        end
    end

    if maximumOffset > 0 then
        popover.scrollHint:Show()
    else
        popover.scrollHint:Hide()
    end
end

local function GetBookMovePopover()
    local popover = _G.ParchmentReaderBookMovePopover
    if popover then return popover end

    popover = PRUI.Panel(UIParent, {
        name = "ParchmentReaderBookMovePopover",
        color = Theme:Get("bg", "popover"),
        borderColor = Theme:Get("border", "elevated"),
        shadow = true,
    })
    popover:SetWidth(240)
    PRUI.SetAddonFrameLayer(
        popover,
        PRUI.ADDON_FRAME_LEVELS.POPOVER + 10)
    popover:SetClampedToScreen(true)
    popover:EnableMouse(true)
    popover:EnableMouseWheel(true)
    popover.offset = 0
    popover.rows = {}
    ParchmentReader:RegisterEscapeClose("ParchmentReaderBookMovePopover")

    local header = popover:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("LEFT", popover, "TOPLEFT", 9, -14)
    header:SetText(L["MOVE TO"])
    SetFontStringColor(header, Theme:Get("accent", "gold"))

    local headerRule = popover:CreateTexture(nil, "BORDER")
    headerRule:SetPoint("TOPLEFT", popover, "TOPLEFT", 1, -27)
    headerRule:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -1, -27)
    headerRule:SetHeight(1)
    local border = Theme:Get("border", "elevated")
    headerRule:SetColorTexture(border[1], border[2], border[3], border[4])

    for index = 1, BOOK_MOVE_ROW_POOL_SIZE do
        local row = PRUI.Button(popover, "", {
            height = BOOK_MOVE_ROW_HEIGHT,
            justifyH = "LEFT",
        })
        row:SetPoint(
            "TOPLEFT",
            popover,
            "TOPLEFT",
            5,
            -(29 + (index - 1) * BOOK_MOVE_ROW_HEIGHT))
        row:SetPoint(
            "TOPRIGHT",
            popover,
            "TOPRIGHT",
            -5,
            -(29 + (index - 1) * BOOK_MOVE_ROW_HEIGHT))
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", row.pruiContent, "LEFT", 10, 0)
        row.label:SetPoint("RIGHT", row.pruiContent, "RIGHT", -8, 0)
        row.label:SetJustifyH("LEFT")

        local selectedRail = row.pruiContent:CreateTexture(nil, "ARTWORK")
        selectedRail:SetPoint("TOPLEFT", row.pruiContent, "TOPLEFT", 4, -4)
        selectedRail:SetPoint("BOTTOMLEFT", row.pruiContent, "BOTTOMLEFT", 4, 4)
        selectedRail:SetWidth(2)
        local gold = Theme:Get("accent", "gold")
        selectedRail:SetColorTexture(gold[1], gold[2], gold[3], gold[4])
        row.selectedRail = selectedRail

        local currentLabel = row.pruiContent:CreateFontString(
            nil, "OVERLAY", "GameFontNormalSmall")
        currentLabel:SetPoint("RIGHT", row.pruiContent, "RIGHT", -7, 0)
        currentLabel:SetText(L["CURRENT"])
        currentLabel:SetScale(0.80)
        SetFontStringColor(currentLabel, gold)
        row.currentLabel = currentLabel

        row:SetScript("OnClick", function(button)
            local item = button.item
            local bookKey = popover.bookKey
            local book = ParchmentReader.books[bookKey]
            if not item or not book or button.isCurrent then return end

            local moved, _, reason =
                ParchmentReader:MoveBook(bookKey, item.collection)
            if not moved then
                if reason == "duplicate" then
                    ParchmentReader:PrintMessage(
                        "A book with this title already exists in the target collection.")
                elseif reason == "editing" then
                    ParchmentReader:PrintMessage(
                        "Close the open book editor before moving this book.")
                else
                    ParchmentReader:PrintMessage("The book could not be moved.")
                end
                return
            end
            popover:Hide()
            local menu = _G.ParchmentReaderBookContextMenu
            if menu then menu:Hide() end
        end)
        PRUI.AttachTooltip(row, function(button)
            return button.item and button.item.label
        end)
        popover.rows[index] = row
    end

    popover.scrollHint = popover:CreateFontString(
        nil, "OVERLAY", "GameFontNormalSmall")
    popover.scrollHint:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -8, -8)
    popover.scrollHint:SetText("↕")
    SetFontStringColor(popover.scrollHint, Theme:Get("text", "muted"))

    popover:SetScript("OnMouseWheel", function(_, delta)
        local maximumOffset = math.max(0, #popover.items - BOOK_MOVE_ROW_POOL_SIZE)
        popover.offset = Clamp(popover.offset - delta, 0, maximumOffset)
        RefreshBookMovePopover(popover)
    end)
    ConfigureOutsideDismiss(popover, function()
        return _G.ParchmentReaderBookContextMenu
    end)
    popover:Hide()
    return popover
end

local function GetBookContextMenu()
    local menu = _G.ParchmentReaderBookContextMenu
    if menu then return menu end

    menu = PRUI.Panel(UIParent, {
        name = "ParchmentReaderBookContextMenu",
        color = Theme:Get("bg", "base"),
        shadow = true,
    })
    menu:SetSize(206, 56)
    PRUI.SetAddonFrameLayer(menu, PRUI.ADDON_FRAME_LEVELS.POPOVER)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    ParchmentReader:RegisterEscapeClose("ParchmentReaderBookContextMenu")

    menu.editButton = PRUI.Button(menu, L["Edit Book"], {
        width = 196,
        height = 23,
        justifyH = "LEFT",
    })
    menu.editButton:SetPoint("TOPLEFT", menu, "TOPLEFT", 5, -5)
    menu.editButton.label:ClearAllPoints()
    menu.editButton.label:SetPoint("LEFT", menu.editButton.pruiContent, "LEFT", 8, 0)
    menu.editButton.label:SetPoint("RIGHT", menu.editButton.pruiContent, "RIGHT", -8, 0)

    menu.moveButton = PRUI.Button(menu, L["Move Book…"], {
        width = 196,
        height = 23,
        justifyH = "LEFT",
    })
    menu.moveButton:SetPoint("TOPLEFT", menu.editButton, "BOTTOMLEFT", 0, 0)
    menu.moveButton.label:ClearAllPoints()
    menu.moveButton.label:SetPoint("LEFT", menu.moveButton.pruiContent, "LEFT", 8, 0)
    menu.moveButton.label:SetPoint("RIGHT", menu.moveButton.pruiContent, "RIGHT", -8, 0)

    menu.editButton:SetScript("OnClick", function()
        local bookKey = menu.bookKey
        menu:Hide()
        ParchmentReader:ShowBookEditor(bookKey)
    end)
    menu.moveButton:SetScript("OnClick", function(button)
        local popover = GetBookMovePopover()
        if popover:IsShown() and popover.bookKey == menu.bookKey then
            popover:Hide()
            return
        end

        popover.bookKey = menu.bookKey
        popover.owner = button
        popover.offset = 0
        RefreshBookMovePopover(popover)
        popover:ClearAllPoints()
        popover:SetPoint("TOPLEFT", menu, "TOPRIGHT", 4, 0)
        popover:Show()
    end)

    ConfigureOutsideDismiss(menu, function()
        return _G.ParchmentReaderBookMovePopover
    end)
    menu:HookScript("OnHide", function()
        local popover = _G.ParchmentReaderBookMovePopover
        if popover then popover:Hide() end
    end)
    menu:Hide()
    return menu
end

local function ShowBookContextMenu(bookKey, anchor)
    local menu = GetBookContextMenu()
    local movePopover = _G.ParchmentReaderBookMovePopover
    if movePopover then movePopover:Hide() end
    local collectionMenu = _G.ParchmentReaderCollectionContextMenu
    if collectionMenu then collectionMenu:Hide() end
    if ParchmentReaderFrame and ParchmentReaderFrame.collectionPopover then
        ParchmentReaderFrame.collectionPopover:Hide()
    end

    menu.bookKey = bookKey
    menu.owner = anchor
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 4, 0)
    menu:Show()
end

local function ClampBookListScroll(frame)
    local maximum = math.max(
        0,
        frame.bookListScroll:GetHeight() - frame.sidebarScroll:GetHeight())
    local current = frame.sidebarScroll:GetVerticalScroll() or 0
    frame.sidebarScroll:SetVerticalScroll(Clamp(current, 0, maximum))
end

local function ConfigureFrameKeyboard(frame)
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
    frame:RegisterEvent("UI_SCALE_CHANGED")
    frame:SetScript("OnEvent", function(readerFrame, event)
        if event == "PLAYER_REGEN_DISABLED" then
            ParchmentReader:SetReaderKeyboardFocus(false)
        elseif event == "PLAYER_REGEN_ENABLED" then
            readerFrame:SetPropagateKeyboardInput(true)
            readerFrame:EnableKeyboard(false)
            readerFrame.readerKeyboardFocused = false
            ParchmentReader:RefreshReaderKeyboardFocusVisual()
        elseif event == "GLOBAL_MOUSE_DOWN" then
            if readerFrame.readerKeyboardFocused
                and (not readerFrame.contentScroll
                    or not readerFrame.contentScroll:IsMouseOver())
            then
                ParchmentReader:SetReaderKeyboardFocus(false)
            end
        elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
            ParchmentReader:ApplyReaderPosition()
        end
    end)

    if InCombatLockdown() then
        frame:EnableKeyboard(false)
    else
        frame:SetPropagateKeyboardInput(true)
        frame:EnableKeyboard(false)
    end

    frame:SetScript("OnKeyDown", function(readerFrame, key)
        if InCombatLockdown() then
            readerFrame:EnableKeyboard(false)
            return
        end
        if not readerFrame.readerKeyboardFocused
            or ParchmentReaderDB.readerKeyboardNavigation == false
        then
            readerFrame:SetPropagateKeyboardInput(true)
            return
        end
        if _G.GetCurrentKeyBoardFocus and _G.GetCurrentKeyBoardFocus() then
            ParchmentReader:SetReaderKeyboardFocus(false)
            return
        end
        if key == "ESCAPE" then
            ParchmentReader:SetReaderKeyboardFocus(false, true)
            return
        end
        local handled = ParchmentReader:HandleReaderKey(key)
        if handled then
            readerFrame:SetPropagateKeyboardInput(false)
        elseif READER_FOCUS_MODIFIER_KEYS[key] then
            readerFrame:SetPropagateKeyboardInput(true)
        else
            ParchmentReader:SetReaderKeyboardFocus(false)
        end
    end)
end

local function FinishReaderResize(frame)
    frame.readerResizeActive = false
    frame:StopMovingOrSizing()
    ParchmentReader:UpdateReaderResizeBounds()
    ParchmentReader:SaveReaderPosition()
    ParchmentReader:UpdateContentWidth()
end

local function CreateResizeHandle(frame)
    local handle = CreateFrame("Button", nil, frame)
    handle:SetSize(18, 18)
    handle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    handle:SetFrameLevel(frame:GetFrameLevel() + 20)
    handle:RegisterForDrag("LeftButton")
    handle.dots = {}

    local muted = Theme:Get("text", "muted")
    for index = 1, 3 do
        local dot = handle:CreateTexture(nil, "ARTWORK")
        dot:SetSize(2, 2)
        dot:SetPoint("BOTTOMRIGHT", handle, "BOTTOMRIGHT", -(3 + (index - 1) * 4), 3 + (index - 1) * 4)
        dot:SetColorTexture(muted[1], muted[2], muted[3], muted[4])
        handle.dots[index] = dot
    end

    handle:SetScript("OnDragStart", function()
        ParchmentReader:SyncReadingPosition()
        ParchmentReader:StopReaderScrollAnimation()
        frame.readerResizeActive = true
        frame:StartSizing("BOTTOMRIGHT")
    end)
    handle:SetScript("OnDragStop", function()
        FinishReaderResize(frame)
    end)
    handle:SetScript("OnEnter", function()
        local goldDim = Theme:Get("accent", "goldDim")
        for _, dot in ipairs(handle.dots) do
            dot:SetColorTexture(goldDim[1], goldDim[2], goldDim[3], goldDim[4])
        end
    end)
    handle:SetScript("OnLeave", function()
        local color = Theme:Get("text", "muted")
        for _, dot in ipairs(handle.dots) do
            dot:SetColorTexture(color[1], color[2], color[3], color[4])
        end
    end)
    PRUI.AttachTooltip(handle, L["Drag to resize"])
    return handle
end

local RefreshBookmarkPopover

local function SetBookmarkPreviewShown(frame, shown)
    local preview = frame and frame.bookmarkPreview
    local layout = ParchmentReader.readerLayoutMetrics
    local canPreview = shown
        and preview
        and layout
        and layout.bookKey == ParchmentReader.currentBook
        and type(layout.content) == "string"
        and layout.content ~= ""

    if not canPreview then
        if preview then preview:Hide() end
        return
    end

    ParchmentReader:SyncReadingPosition()
    preview:SetHeight(math.max(14, (layout.lineHeight or 14) + 4))
    preview:Show()
end

local function CloseBookmarkRename(row, save)
    if not row.renaming then return end

    local name = row.renameInput:GetText()
    local bookmarkId = row.bookmarkId
    row.renaming = false
    row.renameInput:ClearFocus()
    row.renameContainer:Hide()
    row.jumpButton:Show()

    if save and strtrim(name or "") ~= "" then
        ParchmentReader:RenameBookmark(
            ParchmentReader.currentBook,
            bookmarkId,
            name)
    end
    RefreshBookmarkPopover(row.popover)
end

local function BeginBookmarkRename(row)
    if not row.bookmarkId then return end
    row.renaming = true
    row.jumpButton:Hide()
    row.renameContainer:Show()
    row.renameInput:SetText(row.bookmarkName or "")
    row.renameInput:SetFocus()
    row.renameInput:HighlightText()
end

local function CreateBookmarkRow(popover, index)
    local row = CreateFrame("Frame", nil, popover.list)
    row:SetPoint(
        "TOPLEFT",
        popover.list,
        "TOPLEFT",
        0,
        -((index - 1) * BOOKMARK_ROW_HEIGHT))
    row:SetPoint(
        "TOPRIGHT",
        popover.list,
        "TOPRIGHT",
        0,
        -((index - 1) * BOOKMARK_ROW_HEIGHT))
    row:SetHeight(BOOKMARK_ROW_HEIGHT - 2)
    row.popover = popover

    local deleteButton = PRUI.IconButton(row, nil, L["Delete bookmark"], {
        width = 24,
        height = 24,
        iconText = "×",
        fontObject = "GameFontNormal",
    })
    deleteButton:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    PRUI.SetButtonTextColor(deleteButton, Theme:Get("state", "danger"))
    row.deleteButton = deleteButton

    local editButton = PRUI.IconButton(
        row,
        "Interface\\Buttons\\UI-GuildButton-PublicNote-Up",
        L["Rename bookmark"],
        {
            width = 24,
            height = 24,
            iconSize = 14,
            texCoord = {0.08, 0.92, 0.08, 0.92},
        })
    editButton:SetPoint("RIGHT", deleteButton, "LEFT", -3, 0)
    row.editButton = editButton

    local jumpButton = PRUI.Button(row, "", {
        height = BOOKMARK_ROW_HEIGHT - 2,
        justifyH = "LEFT",
    })
    jumpButton:SetPoint("LEFT", row, "LEFT", 0, 0)
    jumpButton:SetPoint("RIGHT", editButton, "LEFT", -4, 0)
    jumpButton.label:Hide()
    local rowBackground = Theme:Get("bg", "popoverRow")
    jumpButton.pruiBackground:SetColorTexture(
        rowBackground[1],
        rowBackground[2],
        rowBackground[3],
        rowBackground[4])
    row.jumpButton = jumpButton

    local nameText = jumpButton.pruiContent:CreateFontString(
        nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("TOPLEFT", jumpButton.pruiContent, "TOPLEFT", 9, -5)
    nameText:SetPoint("TOPRIGHT", jumpButton.pruiContent, "TOPRIGHT", -7, -5)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    nameText:SetMaxLines(1)
    SetFontStringColor(nameText, Theme:Get("text", "primary"))
    row.nameText = nameText

    local contextText = jumpButton.pruiContent:CreateFontString(
        nil, "OVERLAY", "GameFontNormalSmall")
    contextText:SetPoint("BOTTOMLEFT", jumpButton.pruiContent, "BOTTOMLEFT", 9, 4)
    contextText:SetPoint("BOTTOMRIGHT", jumpButton.pruiContent, "BOTTOMRIGHT", -7, 4)
    contextText:SetJustifyH("LEFT")
    contextText:SetWordWrap(false)
    contextText:SetMaxLines(1)
    contextText:SetScale(0.86)
    SetFontStringColor(contextText, Theme:Get("text", "muted"))
    row.contextText = contextText

    local renameInput, renameContainer = PRUI.EditBox(row, {
        autoFocus = false,
        fontObject = "GameFontNormalSmall",
        insetLeft = 7,
        insetRight = 7,
        insetTop = 3,
        insetBottom = 3,
    })
    renameContainer:SetPoint("LEFT", row, "LEFT", 0, 0)
    renameContainer:SetPoint("RIGHT", editButton, "LEFT", -4, 0)
    renameContainer:SetHeight(26)
    renameContainer:Hide()
    renameInput:SetMaxLetters(80)
    renameInput:SetScript("OnEnterPressed", function()
        CloseBookmarkRename(row, true)
    end)
    renameInput:SetScript("OnEscapePressed", function()
        CloseBookmarkRename(row, false)
    end)
    renameInput:HookScript("OnEditFocusLost", function()
        if row.renaming then
            CloseBookmarkRename(row, true)
        end
    end)
    row.renameInput = renameInput
    row.renameContainer = renameContainer

    jumpButton:SetScript("OnClick", function()
        local layout = ParchmentReader.readerLayoutMetrics
        local bookmark = row.bookmark
        if not layout or not bookmark then return end

        local offset = ParchmentReader:ResolveBookmarkOffset(
            layout.content,
            bookmark)
        if offset == nil then return end

        ParchmentReader:RefreshBookmarkAnchor(
            layout.content,
            bookmark,
            offset)
        popover.activeBookmarkId = bookmark.id
        ParchmentReader:ScrollReaderToReadingOffset(offset, true)
        RefreshBookmarkPopover(popover)
    end)
    editButton:SetScript("OnClick", function()
        BeginBookmarkRename(row)
    end)
    deleteButton:SetScript("OnClick", function()
        local bookmark, bookmarkIndex = ParchmentReader:DeleteBookmark(
            ParchmentReader.currentBook,
            row.bookmarkId)
        if not bookmark then return end

        popover.lastDeleted = {
            bookKey = ParchmentReader.currentBook,
            bookmark = bookmark,
            index = bookmarkIndex,
        }
        if popover.activeBookmarkId == row.bookmarkId then
            popover.activeBookmarkId = nil
        end
        RefreshBookmarkPopover(popover)
        ParchmentReader:RefreshBookmarkControls()
    end)

    row:Hide()
    return row
end

local function UpdateBookmarkPopoverGeometry(popover, bookmarkCount)
    local frame = popover.readerFrame
    local metrics = Theme.metrics
    local availableHeight = math.max(
        BOOKMARK_POPOVER_HEADER_HEIGHT
            + BOOKMARK_ROW_HEIGHT
            + BOOKMARK_POPOVER_FOOTER_HEIGHT,
        frame:GetHeight()
            - metrics.topbarHeight
            - metrics.footerHeight
            - (BOOKMARK_POPOVER_MARGIN * 2))
    local rowsByHeight = Clamp(
        math.floor((availableHeight
            - BOOKMARK_POPOVER_HEADER_HEIGHT
            - BOOKMARK_POPOVER_FOOTER_HEIGHT) / BOOKMARK_ROW_HEIGHT),
        1,
        BOOKMARK_ROW_POOL_SIZE)
    local visibleRows = math.min(
        rowsByHeight,
        math.max(1, bookmarkCount or 0))
    local width = math.min(
        BOOKMARK_POPOVER_MAX_WIDTH,
        frame:GetWidth() - (BOOKMARK_POPOVER_MARGIN * 2))
    local height = BOOKMARK_POPOVER_HEADER_HEIGHT
        + (visibleRows * BOOKMARK_ROW_HEIGHT)
        + BOOKMARK_POPOVER_FOOTER_HEIGHT

    popover.visibleRowCount = visibleRows
    popover:SetSize(width, math.min(height, availableHeight))
    popover:ClearAllPoints()
    popover:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        -BOOKMARK_POPOVER_MARGIN,
        metrics.footerHeight + 5)
    popover.list:SetHeight(visibleRows * BOOKMARK_ROW_HEIGHT)
    popover.emptyText:SetWidth(math.max(1, width - 32))
end

RefreshBookmarkPopover = function(popover)
    if not popover then return end

    local bookKey = ParchmentReader.currentBook
    local layout = ParchmentReader.readerLayoutMetrics
    local bookmarks = bookKey and ParchmentReader:GetBookmarks(bookKey) or {}
    local bookmarkLimit = ParchmentReader:GetBookmarkLimit()
    UpdateBookmarkPopoverGeometry(popover, #bookmarks)
    local visibleRowCount = popover.visibleRowCount
    local maximumOffset = math.max(0, #bookmarks - visibleRowCount)
    popover.offset = Clamp(popover.offset or 0, 0, maximumOffset)

    for poolIndex, row in ipairs(popover.rows) do
        local bookmarkIndex = popover.offset + poolIndex
        local bookmark = poolIndex <= visibleRowCount
            and bookmarks[bookmarkIndex]
            or nil
        if type(bookmark) == "table" then
            if row.renaming then
                row.renaming = false
                row.renameInput:ClearFocus()
            end
            row.renameContainer:Hide()
            row.jumpButton:Show()
            row.bookmark = bookmark
            row.bookmarkId = bookmark.id
            row.bookmarkName = bookmark.name or L["Bookmark"]
            row.nameText:SetText(row.bookmarkName)

            local context = ""
            if layout and layout.bookKey == bookKey then
                local offset = ParchmentReader:ResolveBookmarkOffset(
                    layout.content,
                    bookmark)
                if offset ~= nil then
                    local progress = #layout.content > 0
                        and (offset / #layout.content) * 100
                        or 0
                    local excerpt = ParchmentReader:GetBookmarkExcerpt(
                        layout.content,
                        bookmark)
                    context = string.format(
                        "%d%%  %s",
                        math.floor(progress + 0.5),
                        excerpt)
                end
            end
            row.contextText:SetText(context)
            PRUI.SetButtonSelected(
                row.jumpButton,
                popover.activeBookmarkId == bookmark.id)
            row:Show()
        else
            row.bookmark = nil
            row.bookmarkId = nil
            row:Hide()
        end
    end

    popover.emptyText:SetShown(#bookmarks == 0)
    local canAdd = layout ~= nil
        and #layout.content > 0
        and #bookmarks < bookmarkLimit
    popover.addButton:SetText(
        #bookmarks >= bookmarkLimit
            and string.format(L["%d max"], bookmarkLimit)
            or L["+  Here"])
    if canAdd then
        popover.addButton:Enable()
    else
        popover.addButton:Disable()
        SetBookmarkPreviewShown(popover.readerFrame, false)
    end
    if popover.offset > 0 then
        popover.scrollUpButton:Enable()
    else
        popover.scrollUpButton:Disable()
    end
    if popover.offset < maximumOffset then
        popover.scrollDownButton:Enable()
    else
        popover.scrollDownButton:Disable()
    end
    popover.scrollUpButton:SetShown(#bookmarks > visibleRowCount)
    popover.scrollDownButton:SetShown(#bookmarks > visibleRowCount)
    popover.rangeText:SetShown(#bookmarks > visibleRowCount)
    if #bookmarks > visibleRowCount then
        popover.rangeText:SetFormattedText(
            L["%d-%d of %d"],
            popover.offset + 1,
            math.min(#bookmarks, popover.offset + visibleRowCount),
            #bookmarks)
    end

    local canUndo = popover.lastDeleted
        and popover.lastDeleted.bookKey == bookKey
    popover.undoButton:SetShown(canUndo == true)
end

local function CreateBookmarkPopover(frame, owner)
    local popover = PRUI.Panel(frame, {
        name = "ParchmentReaderBookmarkPopover",
        color = Theme:Get("bg", "popover"),
        shadow = true,
    })
    popover:SetSize(
        BOOKMARK_POPOVER_MAX_WIDTH,
        BOOKMARK_POPOVER_HEADER_HEIGHT
            + BOOKMARK_ROW_HEIGHT
            + BOOKMARK_POPOVER_FOOTER_HEIGHT)
    popover:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        -BOOKMARK_POPOVER_MARGIN,
        Theme.metrics.footerHeight + 5)
    popover:SetFrameLevel(frame:GetFrameLevel() + 30)
    popover:SetClampedToScreen(true)
    popover:EnableMouse(true)
    popover:EnableMouseWheel(true)
    popover.owner = owner
    popover.readerFrame = frame
    popover.offset = 0
    ParchmentReader:RegisterEscapeClose("ParchmentReaderBookmarkPopover")

    local title = popover:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", popover, "TOPLEFT", 12, -11)
    title:SetText(L["Bookmarks"])
    SetFontStringColor(title, Theme:Get("text", "primary"))

    local addButton = PRUI.Button(popover, L["+  Here"], {
        width = 76,
        height = 24,
    })
    addButton:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -8, -7)
    PRUI.SetButtonBorderColor(addButton, Theme:Get("accent", "goldDim"))
    PRUI.SetButtonTextColor(addButton, Theme:Get("accent", "gold"))
    PRUI.AttachTooltip(addButton, function()
        local bookmarks = ParchmentReader.currentBook
            and ParchmentReader:GetBookmarks(ParchmentReader.currentBook)
            or {}
        if #bookmarks >= ParchmentReader:GetBookmarkLimit() then
            return string.format(
                L["Maximum %d bookmarks per book"],
                ParchmentReader:GetBookmarkLimit())
        end
        return L["Add a bookmark at the current reading position"]
    end)
    addButton:HookScript("OnEnter", function()
        SetBookmarkPreviewShown(frame, true)
    end)
    addButton:HookScript("OnLeave", function()
        SetBookmarkPreviewShown(frame, false)
    end)
    addButton:SetScript("OnClick", function()
        ParchmentReader:SyncReadingPosition()
        local layout = ParchmentReader.readerLayoutMetrics
        if not layout or layout.bookKey ~= ParchmentReader.currentBook then return end

        local bookmark = ParchmentReader:AddBookmark(
            ParchmentReader.currentBook,
            layout.content,
            ParchmentReader.currentReadingOffset or 0)
        if not bookmark then return end

        popover.activeBookmarkId = bookmark.id
        local bookmarks = ParchmentReader:GetBookmarks(ParchmentReader.currentBook)
        popover.offset = math.max(
            0,
            #bookmarks - (popover.visibleRowCount or BOOKMARK_ROW_POOL_SIZE))
        popover.lastDeleted = nil
        RefreshBookmarkPopover(popover)
        ParchmentReader:RefreshBookmarkControls()
    end)
    popover.addButton = addButton

    local list = CreateFrame("Frame", nil, popover)
    list:SetPoint("TOPLEFT", popover, "TOPLEFT", 6, -38)
    list:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -6, -38)
    list:SetHeight(BOOKMARK_ROW_POOL_SIZE * BOOKMARK_ROW_HEIGHT)
    popover.list = list

    local emptyText = list:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    emptyText:SetPoint("CENTER", list, "CENTER", 0, 4)
    emptyText:SetWidth(BOOKMARK_POPOVER_MAX_WIDTH - 32)
    emptyText:SetJustifyH("CENTER")
    emptyText:SetWordWrap(true)
    emptyText:SetText(
        L["No bookmarks yet. Add one at your current position."])
    SetFontStringColor(emptyText, Theme:Get("text", "muted"))
    popover.emptyText = emptyText

    popover.rows = {}
    for index = 1, BOOKMARK_ROW_POOL_SIZE do
        popover.rows[index] = CreateBookmarkRow(popover, index)
    end

    local undoButton = PRUI.Button(popover, L["Undo Delete"], {
        width = 136,
        height = 22,
    })
    undoButton:SetPoint("BOTTOMLEFT", popover, "BOTTOMLEFT", 7, 7)
    undoButton:SetScript("OnClick", function()
        local deleted = popover.lastDeleted
        if not deleted or deleted.bookKey ~= ParchmentReader.currentBook then return end

        ParchmentReader:RestoreBookmark(
            deleted.bookKey,
            deleted.bookmark,
            deleted.index)
        popover.lastDeleted = nil
        RefreshBookmarkPopover(popover)
        ParchmentReader:RefreshBookmarkControls()
    end)
    undoButton:Hide()
    popover.undoButton = undoButton

    local scrollDownButton = PRUI.IconButton(
        popover, nil, L["Later bookmarks"], {
        width = 22,
        height = 22,
        iconText = ">",
        fontObject = "GameFontNormalSmall",
    })
    scrollDownButton:SetPoint("BOTTOMRIGHT", popover, "BOTTOMRIGHT", -7, 7)
    scrollDownButton:SetScript("OnClick", function()
        popover.offset = (popover.offset or 0) + 1
        RefreshBookmarkPopover(popover)
    end)
    popover.scrollDownButton = scrollDownButton

    local scrollUpButton = PRUI.IconButton(
        popover, nil, L["Earlier bookmarks"], {
        width = 22,
        height = 22,
        iconText = "<",
        fontObject = "GameFontNormalSmall",
    })
    scrollUpButton:SetPoint("RIGHT", scrollDownButton, "LEFT", -3, 0)
    scrollUpButton:SetScript("OnClick", function()
        popover.offset = (popover.offset or 0) - 1
        RefreshBookmarkPopover(popover)
    end)
    popover.scrollUpButton = scrollUpButton

    local rangeText = popover:CreateFontString(
        nil, "OVERLAY", "GameFontNormalSmall")
    rangeText:SetPoint("RIGHT", scrollUpButton, "LEFT", -7, 0)
    rangeText:SetJustifyH("RIGHT")
    SetFontStringColor(rangeText, Theme:Get("text", "muted"))
    popover.rangeText = rangeText

    popover:SetScript("OnMouseWheel", function(_, delta)
        popover.offset = (popover.offset or 0) - delta
        RefreshBookmarkPopover(popover)
    end)
    ConfigureOutsideDismiss(popover)
    popover:HookScript("OnShow", function()
        popover.offset = 0
        popover.lastDeleted = nil
        RefreshBookmarkPopover(popover)
    end)
    popover:HookScript("OnHide", function()
        SetBookmarkPreviewShown(frame, false)
        for _, row in ipairs(popover.rows) do
            if row.renaming then
                CloseBookmarkRename(row, true)
            end
        end
        popover.lastDeleted = nil
    end)
    popover:Hide()
    return popover
end

function ParchmentReader:RefreshBookmarkControls()
    local frame = ParchmentReaderFrame
    if not frame or not frame.bookmarkButton then return end

    local hasBook = self.currentBook ~= nil and self.books[self.currentBook] ~= nil
    local bookmarks = hasBook and self:GetBookmarks(self.currentBook) or {}
    if hasBook then
        frame.bookmarkButton:Enable()
    else
        frame.bookmarkButton:Disable()
    end
    frame.bookmarkCount:SetText(#bookmarks > 0 and tostring(#bookmarks) or "")
    frame.bookmarkCount:SetShown(#bookmarks > 0)
    if not hasBook and frame.bookmarkPopover:IsShown() then
        frame.bookmarkPopover:Hide()
        return
    end
    if frame.bookmarkPopover and frame.bookmarkPopover:IsShown() then
        RefreshBookmarkPopover(frame.bookmarkPopover)
    end
end

local TRANSPARENT_BACKGROUND_ALPHA = 0.18
local TRANSPARENT_BORDER_ALPHA = 0.42
local TRANSPARENT_SHADOW_ALPHA = 0.28
local TRANSPARENT_CONTROL_IDLE_ALPHA = 0.40
local TRANSPARENT_DENSE_CONTROL_IDLE_ALPHA = 0.55
local READER_PROGRESS_IDLE_HEIGHT = 4
local READER_PROGRESS_HOVER_HEIGHT = 6
local READER_PROGRESS_HIT_HEIGHT = 12

function ParchmentReader:RefreshReaderKeyboardFocusVisual()
    local frame = ParchmentReaderFrame
    if not frame or not frame.contentSurface then return end

    local focused = frame.readerKeyboardFocused == true
    PRUI.SetBorderColor(
        frame.contentSurface,
        focused
            and Theme:Get("accent", "goldDim")
            or Theme:Get("border", "subtle"))

    local borderAlpha = focused and 1
        or (frame.readerBackgroundTransparent and TRANSPARENT_BORDER_ALPHA or 1)
    for _, texture in pairs(frame.contentSurface.pruiBorder or {}) do
        texture:SetAlpha(borderAlpha)
    end
end

function ParchmentReader:SetReaderKeyboardFocus(focused, consumeCurrentKey)
    local frame = ParchmentReaderFrame
    if not frame then return end

    local shouldFocus = focused == true
        and ParchmentReaderDB.readerKeyboardNavigation ~= false
        and frame:IsShown()
        and self.currentBook ~= nil
        and self.readerLayoutMetrics ~= nil
        and not InCombatLockdown()

    frame.readerKeyboardFocused = shouldFocus
    if shouldFocus then
        frame:RegisterEvent("GLOBAL_MOUSE_DOWN")
    else
        frame:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end

    if InCombatLockdown() then
        frame:EnableKeyboard(false)
    elseif consumeCurrentKey and not shouldFocus then
        frame:SetPropagateKeyboardInput(false)
        frame:EnableKeyboard(false)
        C_Timer.After(0, function()
            if not frame.readerKeyboardFocused and not InCombatLockdown() then
                frame:SetPropagateKeyboardInput(true)
            end
        end)
    else
        frame:SetPropagateKeyboardInput(true)
        frame:EnableKeyboard(shouldFocus)
    end
    self:RefreshReaderKeyboardFocusVisual()
end

function ParchmentReader:SetReaderKeyboardNavigationEnabled(enabled)
    ParchmentReaderDB.readerKeyboardNavigation = enabled == true
    if not ParchmentReaderDB.readerKeyboardNavigation then
        self:SetReaderKeyboardFocus(false)
    else
        self:RefreshReaderKeyboardFocusVisual()
    end
end

local function SetReaderSurfaceTransparency(surface, transparent)
    if not surface then return end

    local backgroundAlpha = transparent and TRANSPARENT_BACKGROUND_ALPHA or 1
    local borderAlpha = transparent and TRANSPARENT_BORDER_ALPHA or 1
    local shadowAlpha = transparent and TRANSPARENT_SHADOW_ALPHA or 1
    if ParchmentReaderFrame
        and surface == ParchmentReaderFrame.contentSurface
        and ParchmentReaderFrame.readerKeyboardFocused
    then
        borderAlpha = 1
    end

    if surface.pruiBackground then
        surface.pruiBackground:SetAlpha(backgroundAlpha)
    end
    if surface.pruiBorder then
        for _, texture in pairs(surface.pruiBorder) do
            texture:SetAlpha(borderAlpha)
        end
    end
    if surface.pruiShadow then
        for _, texture in pairs(surface.pruiShadow) do
            texture:SetAlpha(shadowAlpha)
        end
    end
end

function ParchmentReader:CompareBookTitles(leftTitle, rightTitle)
    local left = NormalizeSearchText(leftTitle)
    local right = NormalizeSearchText(rightTitle)
    if left == right then return (leftTitle or "") < (rightTitle or "") end
    return left < right
end

local function SetReaderControlTransparency(frame, transparent)
    local controlAlpha = transparent and TRANSPARENT_CONTROL_IDLE_ALPHA or 1
    local denseControlAlpha =
        transparent and TRANSPARENT_DENSE_CONTROL_IDLE_ALPHA or 1

    for _, button in ipairs(frame.readerTransparencyControls or {}) do
        PRUI.SetButtonIdleBackgroundAlpha(button, controlAlpha)
    end
    for _, button in ipairs(frame.bookButtons or {}) do
        PRUI.SetButtonIdleBackgroundAlpha(button, denseControlAlpha)
    end
    if frame.searchBox then
        PRUI.SetEditBoxIdleBackgroundAlpha(frame.searchBox, denseControlAlpha)
    end
end

local function GetProgressAtCursor(progressBar)
    local cursorX = GetCursorPosition()
    local effectiveScale = progressBar:GetEffectiveScale()
    local left = progressBar:GetLeft()
    local width = progressBar:GetWidth()
    if not cursorX or not effectiveScale or effectiveScale <= 0
        or not left or not width or width <= 0
    then
        return (progressBar.value or 0) / 100
    end
    return Clamp((cursorX / effectiveScale - left) / width, 0, 1)
end

local function SetReaderProgressSeekVisual(progressBar, active)
    local emphasized = active and ParchmentReader:CanSeekReader()
    local height = emphasized
        and READER_PROGRESS_HOVER_HEIGHT
        or READER_PROGRESS_IDLE_HEIGHT
    progressBar.track:SetHeight(height)
    progressBar.fill:SetHeight(height)
    progressBar.thumb:SetShown(emphasized)
end

local function ConfigureReaderProgressSeek(progressBar)
    progressBar:SetHeight(READER_PROGRESS_HIT_HEIGHT)
    progressBar.track:ClearAllPoints()
    progressBar.track:SetPoint("LEFT")
    progressBar.track:SetPoint("RIGHT")
    progressBar.track:SetHeight(READER_PROGRESS_IDLE_HEIGHT)
    progressBar.fill:ClearAllPoints()
    progressBar.fill:SetPoint("LEFT")
    progressBar.fill:SetHeight(READER_PROGRESS_IDLE_HEIGHT)

    local thumb = progressBar:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(8, 8)
    local gold = Theme:Get("accent", "gold")
    thumb:SetColorTexture(gold[1], gold[2], gold[3], gold[4])
    thumb:Hide()
    progressBar.thumb = thumb
    progressBar:SetValue(progressBar.value or 0)

    local function UpdateSeek(commit)
        local progress = GetProgressAtCursor(progressBar)
        if not commit
            and progressBar.seekProgress
            and math.abs(progressBar.seekProgress - progress) < 0.0001
        then
            return true
        end
        progressBar.seekProgress = progress
        return ParchmentReader:SeekReaderToProgress(progress, commit == true)
    end

    local function FinishSeek()
        if not progressBar.seekDragging then return end
        UpdateSeek(true)
        progressBar.seekDragging = false
        progressBar:SetScript("OnUpdate", nil)
        SetReaderProgressSeekVisual(progressBar, progressBar:IsMouseOver())
    end

    progressBar:EnableMouse(true)
    progressBar:RegisterForDrag("LeftButton")
    progressBar:SetScript("OnEnter", function(self)
        SetReaderProgressSeekVisual(self, true)
    end)
    progressBar:SetScript("OnLeave", function(self)
        if not self.seekDragging then
            SetReaderProgressSeekVisual(self, false)
        end
    end)
    progressBar:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" or not ParchmentReader:CanSeekReader() then
            return
        end
        self.seekProgress = nil
        self.seekDragging = true
        UpdateSeek(false)
        SetReaderProgressSeekVisual(self, true)
        self:SetScript("OnUpdate", function()
            if not IsMouseButtonDown("LeftButton") then
                FinishSeek()
                return
            end
            UpdateSeek(false)
        end)
    end)
    progressBar:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            FinishSeek()
        end
    end)
    progressBar:SetScript("OnDragStop", FinishSeek)
    progressBar:HookScript("OnHide", function(self)
        self.seekDragging = false
        self:SetScript("OnUpdate", nil)
    end)
    SetReaderProgressSeekVisual(progressBar, false)
end

local function IsShownAndMouseOver(region)
    return region and region:IsShown() and region:IsMouseOver()
end

local function IsReaderInteractionActive(frame)
    if frame:IsMouseOver()
        or frame.readerResizeActive
        or frame.readerKeyboardFocused
    then
        return true
    end

    return IsShownAndMouseOver(frame.collectionPopover)
        or IsShownAndMouseOver(frame.bookmarkPopover)
        or IsShownAndMouseOver(_G.ParchmentReaderCollectionContextMenu)
        or IsShownAndMouseOver(_G.ParchmentReaderBookContextMenu)
        or IsShownAndMouseOver(_G.ParchmentReaderBookMovePopover)
end

function ParchmentReader:RefreshReaderTransparency()
    local frame = ParchmentReaderFrame
    if not frame or not frame.readerTransparencySurfaces then return end

    local mode = self:NormalizeTransparencyMode(ParchmentReaderDB.transparencyMode)
    local transparent = mode == "always"
        or (mode == "smart" and not IsReaderInteractionActive(frame))
    if frame.readerBackgroundTransparent == transparent then return end

    frame.readerBackgroundTransparent = transparent
    for _, surface in ipairs(frame.readerTransparencySurfaces) do
        SetReaderSurfaceTransparency(surface, transparent)
    end
    SetReaderControlTransparency(frame, transparent)
end

function ParchmentReader:SetReaderTransparencyMode(mode)
    ParchmentReaderDB.transparencyMode = self:NormalizeTransparencyMode(mode)
    if ParchmentReaderFrame then
        ParchmentReaderFrame.readerBackgroundTransparent = nil
        ParchmentReaderFrame.readerTransparencyElapsed = 0
        self:RefreshReaderTransparency()
    end
end

local FLOATING_LAUNCHER_SIZE = 42
local FLOATING_LAUNCHER_MARGIN = 8
local READER_SCREEN_MARGIN = 8

local function RoundPosition(value)
    if value < 0 then
        return math.ceil(value - 0.5)
    end
    return math.floor(value + 0.5)
end

local function ClampReaderPosition(frame, x, y)
    local parentWidth = UIParent:GetWidth() or 0
    local parentHeight = UIParent:GetHeight() or 0
    local frameWidth = frame:GetWidth() or 0
    local frameHeight = frame:GetHeight() or 0
    local horizontalLimit = math.max(
        0,
        parentWidth / 2 - frameWidth / 2 - READER_SCREEN_MARGIN)
    local verticalLimit = math.max(
        0,
        parentHeight / 2 - frameHeight / 2 - READER_SCREEN_MARGIN)
    return Clamp(x, -horizontalLimit, horizontalLimit),
        Clamp(y, -verticalLimit, verticalLimit)
end

function ParchmentReader:ApplyReaderPosition()
    local frame = ParchmentReaderFrame
    if not frame then return end

    local x = tonumber(ParchmentReaderDB.windowX) or 0
    local y = tonumber(ParchmentReaderDB.windowY) or 0
    x, y = ClampReaderPosition(frame, x, y)
    x = RoundPosition(x)
    y = RoundPosition(y)
    ParchmentReaderDB.windowX = x
    ParchmentReaderDB.windowY = y

    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

function ParchmentReader:SaveReaderPosition()
    local frame = ParchmentReaderFrame
    if not frame then return end

    local frameX, frameY = frame:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if not frameX or not frameY or not parentX or not parentY then return end

    local x, y = ClampReaderPosition(
        frame,
        frameX - parentX,
        frameY - parentY)
    ParchmentReaderDB.windowX = RoundPosition(x)
    ParchmentReaderDB.windowY = RoundPosition(y)
    self:ApplyReaderPosition()
end

local function ClampFloatingLauncherPosition(x, y)
    local parentWidth = UIParent:GetWidth() or 0
    local parentHeight = UIParent:GetHeight() or 0
    local halfSize = FLOATING_LAUNCHER_SIZE / 2
    local horizontalLimit = math.max(
        0,
        parentWidth / 2 - halfSize - FLOATING_LAUNCHER_MARGIN)
    local verticalLimit = math.max(
        0,
        parentHeight / 2 - halfSize - FLOATING_LAUNCHER_MARGIN)
    return Clamp(x, -horizontalLimit, horizontalLimit),
        Clamp(y, -verticalLimit, verticalLimit)
end

local function RefreshFloatingLauncherMenu(menu)
    if not menu then return end
    menu.lockButton:SetText(
        ParchmentReaderDB.floatingLauncherLocked and L["Unlock"] or L["Lock"])
end

local function CreateFloatingLauncherMenu(launcher)
    local menu = PRUI.Panel(UIParent, {
        color = Theme:Get("bg", "popover"),
        shadow = true,
    })
    menu:SetSize(226, 82)
    PRUI.SetAddonFrameLayer(menu, PRUI.ADDON_FRAME_LEVELS.POPOVER)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu.owner = launcher.button

    local lockButton = PRUI.Button(menu, L["Lock"], {
        width = 216,
        height = 24,
        justifyH = "LEFT",
    })
    lockButton:SetPoint("TOPLEFT", menu, "TOPLEFT", 5, -5)
    lockButton:SetScript("OnClick", function()
        ParchmentReaderDB.floatingLauncherLocked =
            not ParchmentReaderDB.floatingLauncherLocked
        RefreshFloatingLauncherMenu(menu)
        menu:Hide()
    end)
    menu.lockButton = lockButton

    local settingsButton = PRUI.Button(menu, L["Open Settings"], {
        width = 216,
        height = 24,
        justifyH = "LEFT",
    })
    settingsButton:SetPoint("TOPLEFT", lockButton, "BOTTOMLEFT", 0, 0)
    settingsButton:SetScript("OnClick", function()
        menu:Hide()
        ParchmentReader:ShowSettings()
    end)

    local closeButton = PRUI.Button(menu, L["Close"], {
        width = 216,
        height = 24,
        justifyH = "LEFT",
    })
    closeButton:SetPoint("TOPLEFT", settingsButton, "BOTTOMLEFT", 0, 0)
    closeButton:SetScript("OnClick", function()
        menu:Hide()
        ParchmentReader:CloseReader()
    end)

    ConfigureOutsideDismiss(menu)
    menu:Hide()
    return menu
end

function ParchmentReader:ApplyFloatingLauncherPosition()
    local launcher = self.floatingLauncher
    if not launcher then return end

    local x = tonumber(ParchmentReaderDB.floatingLauncherX)
        or self.DEFAULT_LAUNCHER_X
    local y = tonumber(ParchmentReaderDB.floatingLauncherY)
        or self.DEFAULT_LAUNCHER_Y
    x, y = ClampFloatingLauncherPosition(x, y)
    ParchmentReaderDB.floatingLauncherX = x
    ParchmentReaderDB.floatingLauncherY = y

    launcher:ClearAllPoints()
    launcher:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

function ParchmentReader:SaveFloatingLauncherPosition()
    local launcher = self.floatingLauncher
    if not launcher then return end

    local launcherX, launcherY = launcher:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if not launcherX or not launcherY or not parentX or not parentY then return end

    local x, y = ClampFloatingLauncherPosition(
        launcherX - parentX,
        launcherY - parentY)
    ParchmentReaderDB.floatingLauncherX = x
    ParchmentReaderDB.floatingLauncherY = y
    self:ApplyFloatingLauncherPosition()
end

function ParchmentReader:ResetFloatingLauncherSettings()
    ParchmentReaderDB.floatingLauncherX = self.DEFAULT_LAUNCHER_X
    ParchmentReaderDB.floatingLauncherY = self.DEFAULT_LAUNCHER_Y
    ParchmentReaderDB.floatingLauncherLocked = false
    self:ApplyFloatingLauncherPosition()
    if self.floatingLauncher and self.floatingLauncher.menu then
        RefreshFloatingLauncherMenu(self.floatingLauncher.menu)
    end
end

function ParchmentReader:CreateFloatingLauncher()
    if self.floatingLauncher then return self.floatingLauncher end

    local launcher = PRUI.Panel(UIParent, {
        name = "ParchmentReaderFloatingLauncher",
        color = Theme:Get("bg", "base"),
        shadow = true,
    })
    launcher:SetSize(FLOATING_LAUNCHER_SIZE, FLOATING_LAUNCHER_SIZE)
    PRUI.SetAddonFrameLayer(launcher, PRUI.ADDON_FRAME_LEVELS.READER)
    launcher:SetClampedToScreen(true)
    launcher:SetMovable(true)

    local button = PRUI.IconButton(
        launcher,
        "Interface\\Icons\\INV_Misc_Book_09",
        L["Left-click to restore Parchment Reader\nRight-click for menu"],
        {
            width = FLOATING_LAUNCHER_SIZE - 4,
            height = FLOATING_LAUNCHER_SIZE - 4,
            iconSize = 25,
            texCoord = {0.08, 0.92, 0.08, 0.92},
        })
    button:SetPoint("CENTER")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    launcher.button = button

    button:SetScript("OnDragStart", function()
        if ParchmentReaderDB.floatingLauncherLocked then return end
        launcher.dragging = true
        launcher:StartMoving()
    end)
    button:SetScript("OnDragStop", function()
        if not launcher.dragging then return end
        launcher.dragging = false
        launcher:StopMovingOrSizing()
        ParchmentReader:SaveFloatingLauncherPosition()
        launcher.suppressClick = true
        C_Timer.After(0, function()
            launcher.suppressClick = false
        end)
    end)

    launcher.menu = CreateFloatingLauncherMenu(launcher)
    button:SetScript("OnClick", function(_, mouseButton)
        if launcher.suppressClick then return end
        if mouseButton == "LeftButton" then
            launcher.menu:Hide()
            ParchmentReader:ShowReader()
        elseif mouseButton == "RightButton" then
            if launcher.menu:IsShown() then
                launcher.menu:Hide()
            else
                RefreshFloatingLauncherMenu(launcher.menu)
                launcher.menu:ClearAllPoints()
                launcher.menu:SetPoint("TOPLEFT", launcher, "BOTTOMRIGHT", 4, -4)
                launcher.menu:Show()
            end
        end
    end)

    launcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
    launcher:RegisterEvent("UI_SCALE_CHANGED")
    launcher:SetScript("OnEvent", function()
        ParchmentReader:ApplyFloatingLauncherPosition()
    end)
    launcher:SetScript("OnShow", function()
        ParchmentReader:ApplyFloatingLauncherPosition()
    end)
    launcher:SetScript("OnHide", function()
        launcher.menu:Hide()
    end)

    self.floatingLauncher = launcher
    self:ApplyFloatingLauncherPosition()
    launcher:Hide()
    return launcher
end

function ParchmentReader:ShowFloatingLauncher()
    local launcher = self:CreateFloatingLauncher()
    self:ApplyFloatingLauncherPosition()
    launcher:Show()
end

function ParchmentReader:HideFloatingLauncher()
    if self.floatingLauncher then
        self.floatingLauncher:Hide()
    end
end

function ParchmentReader:RefreshReaderPinState()
    local button = ParchmentReaderFrame and ParchmentReaderFrame.pinButton
    if not button then return end

    local pinned = self:IsReaderPinned()
    button.tooltipText = pinned
        and L["Unpin Reader"]
        or L["Pin Reader"]
    PRUI.SetButtonSelected(button, pinned)
    RefreshPinButtonColor(button)
    if ParchmentReaderFrame.resizeHandle then
        ParchmentReaderFrame.resizeHandle:SetShown(not pinned)
    end
end

function ParchmentReader:CreateReaderFrame()
    local metrics = Theme.metrics
    local minWidth, minHeight = self:GetReaderMinimumSize()
    local width = Clamp(
        tonumber(ParchmentReaderDB.windowWidth) or metrics.defaultWidth,
        minWidth,
        metrics.maxWidth)
    local height = Clamp(
        tonumber(ParchmentReaderDB.windowHeight) or metrics.defaultHeight,
        minHeight,
        metrics.maxHeight)
    ParchmentReaderDB.windowWidth = width
    ParchmentReaderDB.windowHeight = height

    local frame = PRUI.Panel(UIParent, {
        name = "ParchmentReaderFrame",
        color = Theme:Get("bg", "base"),
        shadow = true,
    })
    frame:SetSize(width, height)
    frame:SetClampedToScreen(true)
    self:ApplyReaderPosition()
    PRUI.SetAddonFrameLayer(frame, PRUI.ADDON_FRAME_LEVELS.READER)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(
            minWidth,
            minHeight,
            metrics.maxWidth,
            metrics.maxHeight)
    elseif frame.SetMinResize and frame.SetMaxResize then
        frame:SetMinResize(minWidth, minHeight)
        frame:SetMaxResize(metrics.maxWidth, metrics.maxHeight)
    end
    self:RegisterEscapeClose("ParchmentReaderFrame")
    ConfigureFrameKeyboard(frame)

    local topbar = PRUI.Panel(frame, {color = Theme:Get("bg", "sidebar")})
    topbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    topbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    topbar:SetHeight(metrics.topbarHeight)
    frame.topbar = topbar
    PRUI.MakeMovable(frame, topbar, function()
        return not ParchmentReader:IsReaderPinned()
    end)
    topbar:HookScript("OnDragStop", function()
        ParchmentReader:SaveReaderPosition()
    end)

    local brandSlot = CreateFrame("Frame", nil, topbar)
    brandSlot:SetSize(20, 24)
    brandSlot:SetPoint("LEFT", topbar, "LEFT", 4, 0)

    local brandIcon = brandSlot:CreateTexture(nil, "ARTWORK")
    brandIcon:SetSize(14, 14)
    brandIcon:SetPoint("CENTER")
    brandIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    brandIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local gold = Theme:Get("accent", "gold")
    brandIcon:SetVertexColor(gold[1], gold[2], gold[3], gold[4])

    local addonLabel = topbar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    addonLabel:SetPoint("LEFT", brandSlot, "RIGHT", 3, 0)
    addonLabel:SetText(L["Parchment Reader"])
    SetFontStringColor(addonLabel, Theme:Get("text", "secondary"))

    local pinButton = PRUI.IconButton(
        topbar,
        "Interface\\AddOns\\ParchmentReader\\Assets\\Pin",
        nil,
        {
            width = 24,
            height = 24,
            iconSize = 16,
        })
    pinButton:SetPoint("LEFT", addonLabel, "RIGHT", 7, 0)
    pinButton:SetScript("OnClick", function()
        ParchmentReader:ToggleReaderPinned()
    end)
    PRUI.AttachTooltip(pinButton, function(button)
        return button.tooltipText
    end)
    frame.pinButton = pinButton

    local closeButton = PRUI.IconButton(topbar, nil, L["Close"], {
        width = 24,
        height = 24,
        iconText = "×",
        fontObject = "GameFontNormal",
    })
    closeButton:SetPoint("RIGHT", topbar, "RIGHT", -4, 0)
    closeButton:SetScript("OnClick", function()
        ParchmentReader:CloseReader()
    end)

    local minimizeButton = PRUI.IconButton(topbar, nil, L["Minimize"], {
        width = 24,
        height = 24,
        iconText = "",
    })
    local minimizeLine = minimizeButton.pruiContent:CreateTexture(nil, "ARTWORK")
    minimizeLine:SetSize(8, 1)
    minimizeLine:SetPoint("CENTER")
    minimizeLine:SetColorTexture(1, 1, 1, 1)
    minimizeButton.icon = minimizeLine
    PRUI.RefreshButton(minimizeButton)
    minimizeButton:SetPoint("RIGHT", closeButton, "LEFT", -3, 0)
    minimizeButton:SetScript("OnClick", function()
        ParchmentReader:MinimizeReader()
    end)
    frame.minimizeButton = minimizeButton

    local settingsButton = PRUI.IconButton(
        topbar,
        "Interface\\Icons\\INV_Misc_Gear_01",
        L["Settings"],
        {
            width = 24,
            height = 24,
            iconSize = 16,
            texCoord = {0.12, 0.88, 0.12, 0.88},
        })
    settingsButton:SetPoint("RIGHT", minimizeButton, "LEFT", -3, 0)
    settingsButton:SetScript("OnClick", function()
        ParchmentReader:ToggleSettings()
    end)
    frame.settingsButton = settingsButton

    local helpButton = PRUI.IconButton(topbar, nil, L["Keyboard Help"], {
        width = 24,
        height = 24,
        iconText = "?",
        fontObject = "GameFontNormalSmall",
    })
    helpButton:SetPoint("RIGHT", settingsButton, "LEFT", -3, 0)
    helpButton:SetScript("OnClick", function()
        if frame.searchBox then
            frame.searchBox:ClearFocus()
        end
        ParchmentReader:ToggleKeyboardHelp()
    end)
    frame.helpButton = helpButton

    local titleArea = CreateFrame("Button", nil, topbar)
    titleArea:SetHeight(metrics.topbarHeight - 4)
    titleArea:RegisterForDrag("LeftButton")
    titleArea:SetScript("OnDragStart", function()
        if ParchmentReader:IsReaderPinned() then return end
        frame:StartMoving()
    end)
    titleArea:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        ParchmentReader:SaveReaderPosition()
    end)
    frame.titleArea = titleArea

    frame.title = titleArea:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetAllPoints()
    frame.title:SetJustifyH("CENTER")
    frame.title:SetWordWrap(false)
    frame.title:SetMaxLines(1)
    local currentBook = self.currentBook and self.books[self.currentBook]
    frame.title:SetText(currentBook and currentBook.title or "")
    SetFontStringColor(frame.title, Theme:Get("text", "primary"))
    PRUI.AttachTooltip(titleArea, function()
        local book = ParchmentReader.currentBook
            and ParchmentReader.books[ParchmentReader.currentBook]
        return book and book.title
    end)

    local sidebar = PRUI.Panel(frame, {color = Theme:Get("bg", "sidebar")})
    sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -(metrics.topbarHeight + 1))
    sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
    sidebar:SetWidth(metrics.sidebarWidth)
    frame.sidebar = sidebar

    local footer = PRUI.Panel(frame, {color = Theme:Get("bg", "base")})
    footer:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMRIGHT", 0, 0)
    footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    footer:SetHeight(metrics.footerHeight)
    frame.footer = footer

    local contentSurface = PRUI.Panel(frame, {color = Theme:Get("bg", "surface")})
    contentSurface:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 0, 0)
    contentSurface:SetPoint("BOTTOMRIGHT", footer, "TOPRIGHT", 0, 0)
    frame.contentSurface = contentSurface
    frame.parchment = contentSurface
    frame.readerTransparencySurfaces = {
        frame,
        topbar,
        sidebar,
        footer,
        contentSurface,
    }

    local collectionSelector = PRUI.Button(sidebar, L["All Books"], {
        height = 32,
        justifyH = "LEFT",
    })
    collectionSelector:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 4, -32)
    collectionSelector:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -4, -32)
    local collectionBackground = Theme:Get("bg", "popoverAction")
    collectionSelector.pruiBackground:SetColorTexture(
        collectionBackground[1],
        collectionBackground[2],
        collectionBackground[3],
        collectionBackground[4])
    PRUI.SetButtonBorderColor(collectionSelector, Theme:Get("accent", "goldDim"))
    collectionSelector.label:ClearAllPoints()
    collectionSelector.label:SetPoint("BOTTOMLEFT", collectionSelector.pruiContent, "BOTTOMLEFT", 12, 4)
    collectionSelector.label:SetPoint("BOTTOMRIGHT", collectionSelector.pruiContent, "BOTTOMRIGHT", -24, 4)
    collectionSelector.label:SetJustifyH("LEFT")

    local collectionEyebrow = collectionSelector.pruiContent:CreateFontString(
        nil, "OVERLAY", "GameFontNormalSmall")
    collectionEyebrow:SetPoint("TOPLEFT", collectionSelector.pruiContent, "TOPLEFT", 12, -3)
    collectionEyebrow:SetPoint("TOPRIGHT", collectionSelector.pruiContent, "TOPRIGHT", -24, -3)
    collectionEyebrow:SetJustifyH("LEFT")
    collectionEyebrow:SetText(L["COLLECTION"])
    collectionEyebrow:SetScale(0.80)
    SetFontStringColor(collectionEyebrow, Theme:Get("text", "muted"))

    local collectionAccent = collectionSelector.pruiContent:CreateTexture(nil, "ARTWORK")
    collectionAccent:SetPoint("TOPLEFT", collectionSelector.pruiContent, "TOPLEFT", 4, -4)
    collectionAccent:SetPoint("BOTTOMLEFT", collectionSelector.pruiContent, "BOTTOMLEFT", 4, 4)
    collectionAccent:SetWidth(2)
    local collectionGold = Theme:Get("accent", "gold")
    collectionAccent:SetColorTexture(
        collectionGold[1], collectionGold[2], collectionGold[3], collectionGold[4])
    collectionAccent:Hide()
    collectionSelector.collectionAccent = collectionAccent

    local chevron = collectionSelector.pruiContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    chevron:SetPoint("BOTTOMRIGHT", collectionSelector.pruiContent, "BOTTOMRIGHT", -8, 6)
    chevron:SetText("v")
    SetFontStringColor(chevron, Theme:Get("text", "muted"))
    collectionSelector.chevron = chevron
    collectionSelector:SetScript("OnClick", function(button)
        ParchmentReader:ToggleCollectionPopover(button)
    end)
    PRUI.AttachTooltip(collectionSelector, function(button)
        return button.fullLabel
    end)
    frame.collectionSelector = collectionSelector

    local searchBox, searchContainer = PRUI.EditBox(sidebar, {
        autoFocus = false,
        insetLeft = 8,
        insetRight = 4,
        insetTop = 4,
        insetBottom = 4,
        fontObject = "GameFontNormalSmall",
    })
    searchContainer:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 4, -4)
    searchContainer:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -4, -4)
    searchContainer:SetHeight(24)
    searchBox:ClearAllPoints()
    searchBox:SetPoint("TOPLEFT", searchContainer, "TOPLEFT", 1, -1)
    searchBox:SetPoint("BOTTOMRIGHT", searchContainer, "BOTTOMRIGHT", -27, 1)
    searchBox:SetMaxLetters(80)

    local searchHint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchHint:SetPoint("LEFT", searchBox, "LEFT", 8, 0)
    searchHint:SetText(L["Search books…"])
    SetFontStringColor(searchHint, Theme:Get("text", "muted"))

    local clearSearchButton = PRUI.IconButton(
        searchContainer, nil, L["Clear Search"], {
        width = 24,
        height = 20,
        iconText = "×",
        fontObject = "GameFontNormal",
    })
    clearSearchButton:SetPoint("RIGHT", searchContainer, "RIGHT", -2, 0)
    clearSearchButton:SetScript("OnClick", function()
        searchBox:SetText("")
        searchBox:SetFocus()
    end)
    clearSearchButton:Hide()

    searchBox:HookScript("OnTextChanged", function(input)
        local hasText = input:GetText() ~= ""
        if hasText then
            searchHint:Hide()
            clearSearchButton:Show()
        else
            searchHint:Show()
            clearSearchButton:Hide()
        end
        if frame.sidebarScroll then
            frame.sidebarScroll:SetVerticalScroll(0)
            ParchmentReader:RefreshBookList()
        end
    end)
    searchBox:SetScript("OnEnterPressed", function(input)
        input:ClearFocus()
    end)
    searchBox:SetScript("OnEscapePressed", function(input)
        if input:GetText() ~= "" then
            input:SetText("")
        else
            input:ClearFocus()
        end
    end)
    PRUI.AttachTooltip(searchBox, L["Search by book title or collection"])
    frame.searchBox = searchBox
    frame.searchContainer = searchContainer
    frame.clearSearchButton = clearSearchButton

    local collapsedLibraryButton = PRUI.IconButton(
        sidebar,
        "Interface\\Icons\\INV_Misc_Book_11",
        L["Exit Compact Mode — show library"],
        {
            width = 20,
            height = 22,
            iconSize = 14,
            texCoord = {0.08, 0.92, 0.08, 0.92},
        })
    collapsedLibraryButton:SetPoint("TOP", sidebar, "TOP", 0, -4)
    collapsedLibraryButton:SetScript("OnClick", function()
        ParchmentReader:ApplySidebarState(false)
    end)
    frame.collapsedLibraryButton = collapsedLibraryButton

    local collapsedQuickNoteButton = PRUI.IconButton(
        sidebar,
        "Interface\\Icons\\INV_Misc_Note_01",
        L["Quick Note"],
        {
            width = 20,
            height = 22,
            iconSize = 14,
            texCoord = {0.08, 0.92, 0.08, 0.92},
        })
    collapsedQuickNoteButton:SetPoint(
        "TOP", collapsedLibraryButton, "BOTTOM", 0, -6)
    PRUI.SetButtonBorderColor(
        collapsedQuickNoteButton, Theme:Get("accent", "goldDim"))
    PRUI.SetButtonTextColor(
        collapsedQuickNoteButton, Theme:Get("accent", "gold"))
    collapsedQuickNoteButton:SetScript("OnClick", function()
        ParchmentReader:ShowQuickNote()
    end)
    collapsedQuickNoteButton:Hide()
    frame.collapsedQuickNoteButton = collapsedQuickNoteButton

    local addBookButton = PRUI.Button(sidebar, L["+  Add Book"], {
        height = 24,
        justifyH = "LEFT",
    })
    addBookButton:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", 4, 32)
    addBookButton:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -4, 32)
    addBookButton.label:SetJustifyH("LEFT")
    local addBookBackground = Theme:Get("bg", "popoverAction")
    addBookButton.pruiBackground:SetColorTexture(
        addBookBackground[1],
        addBookBackground[2],
        addBookBackground[3],
        addBookBackground[4])
    PRUI.SetButtonBorderColor(addBookButton, Theme:Get("accent", "goldDim"))
    PRUI.SetButtonTextColor(addBookButton, Theme:Get("accent", "gold"))
    addBookButton:SetScript("OnClick", function()
        ParchmentReader:ShowBookEditor(nil)
    end)
    frame.addBookBtn = addBookButton

    local toggleButton = PRUI.Button(
        sidebar, L["«  Compact Mode"], {height = 22})
    toggleButton:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", 3, 3)
    toggleButton:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -3, 3)
    toggleButton.tooltipText = L["Compact Mode — hide library"]
    toggleButton:SetScript("OnClick", function()
        ParchmentReader:ToggleSidebar()
    end)
    PRUI.AttachTooltip(toggleButton, function(button)
        return button.tooltipText
    end)
    frame.toggleBtn = toggleButton

    local sidebarScroll = CreateFrame("ScrollFrame", nil, sidebar)
    sidebarScroll:SetPoint("TOPLEFT", collectionSelector, "BOTTOMLEFT", 0, -4)
    sidebarScroll:SetPoint("BOTTOMRIGHT", addBookButton, "TOPRIGHT", 0, 4)
    sidebarScroll:SetClipsChildren(true)
    sidebarScroll:EnableMouseWheel(true)
    local bookListScroll = CreateFrame("Frame", nil, sidebarScroll)
    bookListScroll:SetSize(1, 1)
    sidebarScroll:SetScrollChild(bookListScroll)
    frame.sidebarScroll = sidebarScroll
    frame.bookListScroll = bookListScroll
    frame.bookButtons = {}

    local emptyState = CreateFrame("Frame", nil, sidebarScroll)
    emptyState:SetPoint("TOPLEFT", sidebarScroll, "TOPLEFT", 10, -20)
    emptyState:SetPoint("TOPRIGHT", sidebarScroll, "TOPRIGHT", -10, -20)
    emptyState:SetHeight(154)
    emptyState:SetFrameLevel(sidebarScroll:GetFrameLevel() + 2)

    local emptyIcon = emptyState:CreateTexture(nil, "ARTWORK")
    emptyIcon:SetSize(32, 32)
    emptyIcon:SetPoint("TOP", emptyState, "TOP", 0, 0)
    emptyIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    emptyIcon:SetDesaturated(true)
    emptyIcon:SetAlpha(0.55)

    local emptyTitle = emptyState:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyTitle:SetPoint("TOPLEFT", emptyState, "TOPLEFT", 2, -42)
    emptyTitle:SetPoint("TOPRIGHT", emptyState, "TOPRIGHT", -2, -42)
    emptyTitle:SetJustifyH("CENTER")
    SetFontStringColor(emptyTitle, Theme:Get("text", "secondary"))

    local emptyMessage = emptyState:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    emptyMessage:SetPoint("TOPLEFT", emptyTitle, "BOTTOMLEFT", 0, -6)
    emptyMessage:SetPoint("TOPRIGHT", emptyTitle, "BOTTOMRIGHT", 0, -6)
    emptyMessage:SetJustifyH("CENTER")
    emptyMessage:SetJustifyV("TOP")
    emptyMessage:SetSpacing(2)
    SetFontStringColor(emptyMessage, Theme:Get("text", "muted"))

    local emptyAction = PRUI.Button(emptyState, "", {width = 174, height = 22})
    emptyAction:SetPoint("BOTTOM", emptyState, "BOTTOM", 0, 0)
    emptyAction:SetScript("OnClick", function(button)
        if button.action == "clear-search" then
            searchBox:SetText("")
            searchBox:SetFocus()
        elseif button.action == "add-book" then
            ParchmentReader:ShowBookEditor(nil)
        end
    end)

    emptyState.title = emptyTitle
    emptyState.message = emptyMessage
    emptyState.actionButton = emptyAction
    emptyState:Hide()
    frame.bookListEmptyState = emptyState

    sidebarScroll:SetScript("OnMouseWheel", function(_, delta)
        local current = sidebarScroll:GetVerticalScroll() or 0
        sidebarScroll:SetVerticalScroll(current - delta * 52)
        ClampBookListScroll(frame)
    end)
    sidebarScroll:SetScript("OnSizeChanged", function(_, scrollWidth)
        bookListScroll:SetWidth(math.max(1, scrollWidth))
        ClampBookListScroll(frame)
    end)

    local contentScroll = CreateFrame("ScrollFrame", nil, contentSurface)
    contentScroll:SetPoint(
        "TOPLEFT",
        contentSurface,
        "TOPLEFT",
        metrics.contentInsetX,
        -metrics.contentInsetY)
    contentScroll:SetPoint(
        "BOTTOMRIGHT",
        contentSurface,
        "BOTTOMRIGHT",
        -metrics.contentInsetX,
        metrics.contentInsetY)
    contentScroll:EnableMouseWheel(true)
    contentScroll:SetClipsChildren(true)

    local contentChild = CreateFrame("Frame", nil, contentScroll)
    contentChild:SetWidth(math.max(1, contentScroll:GetWidth()))
    contentChild:SetHeight(1)
    contentScroll:SetScrollChild(contentChild)
    frame.contentScroll = contentScroll
    frame.contentChild = contentChild

    self:InitializeReaderTextObjects(frame)

    local bookmarkPreview = CreateFrame("Frame", nil, contentScroll)
    bookmarkPreview:SetPoint("TOPLEFT", contentScroll, "TOPLEFT", 0, 0)
    bookmarkPreview:SetPoint("TOPRIGHT", contentScroll, "TOPRIGHT", 0, 0)
    bookmarkPreview:SetHeight(18)
    bookmarkPreview:SetFrameLevel(contentScroll:GetFrameLevel() + 12)

    local previewFill = bookmarkPreview:CreateTexture(nil, "BACKGROUND")
    previewFill:SetAllPoints()
    local previewGold = Theme:Get("accent", "gold")
    previewFill:SetColorTexture(
        previewGold[1], previewGold[2], previewGold[3], 0.10)

    local previewRail = bookmarkPreview:CreateTexture(nil, "ARTWORK")
    previewRail:SetPoint("TOPLEFT", bookmarkPreview, "TOPLEFT", 0, 0)
    previewRail:SetPoint("BOTTOMLEFT", bookmarkPreview, "BOTTOMLEFT", 0, 0)
    previewRail:SetWidth(2)
    previewRail:SetColorTexture(
        previewGold[1], previewGold[2], previewGold[3], 0.9)

    bookmarkPreview:Hide()
    frame.bookmarkPreview = bookmarkPreview

    frame.readerMessage:SetText(L["Select a book from the library."])
    contentScroll:EnableMouse(true)
    contentScroll:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            ParchmentReader:SetReaderKeyboardFocus(true)
        end
    end)
    contentScroll:SetScript("OnMouseWheel", function(_, delta)
        ParchmentReader:HandleReaderMouseWheel(delta)
    end)
    contentScroll:SetScript("OnVerticalScroll", function(_, offset)
        ParchmentReader:HandleReaderScroll(offset)
    end)
    contentSurface:SetScript("OnSizeChanged", function()
        ParchmentReader:UpdateContentWidth()
    end)

    local navigation = CreateFrame("Frame", nil, footer)
    navigation:SetPoint("CENTER")
    navigation:SetHeight(metrics.footerHeight - 4)
    frame.navigation = navigation

    local previousButton = PRUI.IconButton(
        navigation, nil, L["Previous screen"], {
        width = 28,
        height = 22,
        iconText = "<",
    })
    previousButton:SetPoint("LEFT", navigation, "LEFT", 0, 0)
    previousButton:SetScript("OnClick", function()
        ParchmentReader:PrevPage()
    end)
    frame.prevButton = previousButton

    local nextButton = PRUI.IconButton(
        navigation, nil, L["Next screen"], {
        width = 28,
        height = 22,
        iconText = ">",
    })
    nextButton:SetPoint("RIGHT", navigation, "RIGHT", 0, 0)
    nextButton:SetScript("OnClick", function()
        ParchmentReader:NextPage()
    end)
    frame.nextButton = nextButton

    local pageText = navigation:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pageText:SetPoint("RIGHT", nextButton, "LEFT", -6, 0)
    pageText:SetWidth(38)
    pageText:SetJustifyH("RIGHT")
    pageText:SetText("")
    SetFontStringColor(pageText, Theme:Get("text", "secondary"))
    frame.pageText = pageText

    local progressBar = PRUI.ProgressBar(navigation, {
        height = READER_PROGRESS_HIT_HEIGHT,
    })
    progressBar:ClearAllPoints()
    progressBar:SetPoint("LEFT", previousButton, "RIGHT", 8, 0)
    progressBar:SetPoint("RIGHT", pageText, "LEFT", -8, 0)
    ConfigureReaderProgressSeek(progressBar)
    frame.progressBar = progressBar

    local bookmarkButton = PRUI.IconButton(
        navigation,
        "Interface\\Icons\\INV_Misc_Note_03",
        nil,
        {
            width = 24,
            height = 22,
            iconSize = 14,
            texCoord = {0.08, 0.92, 0.08, 0.92},
        })
    bookmarkButton:SetPoint("RIGHT", navigation, "RIGHT", 0, 0)
    nextButton:ClearAllPoints()
    nextButton:SetPoint("RIGHT", bookmarkButton, "LEFT", -3, 0)
    PRUI.SetButtonBorderColor(bookmarkButton, Theme:Get("accent", "goldDim"))
    PRUI.SetButtonTextColor(bookmarkButton, Theme:Get("accent", "gold"))
    PRUI.AttachTooltip(bookmarkButton, function()
        local count = ParchmentReader.currentBook
            and #ParchmentReader:GetBookmarks(ParchmentReader.currentBook)
            or 0
        return count > 0
            and string.format(L["Bookmarks (%d)"], count)
            or L["Bookmarks"]
    end)
    frame.bookmarkButton = bookmarkButton

    local bookmarkCount = bookmarkButton.pruiContent:CreateFontString(
        nil, "OVERLAY", "GameFontNormalSmall")
    bookmarkCount:SetPoint(
        "TOPRIGHT",
        bookmarkButton.pruiContent,
        "TOPRIGHT",
        -2,
        -2)
    bookmarkCount:SetJustifyH("RIGHT")
    bookmarkCount:SetText("")
    bookmarkCount:SetScale(0.78)
    bookmarkCount:SetShadowColor(0, 0, 0, 1)
    bookmarkCount:SetShadowOffset(1, -1)
    SetFontStringColor(bookmarkCount, Theme:Get("accent", "gold"))
    frame.bookmarkCount = bookmarkCount

    local bookmarkPopover = CreateBookmarkPopover(frame, bookmarkButton)
    frame.bookmarkPopover = bookmarkPopover
    bookmarkButton:SetScript("OnClick", function()
        if bookmarkPopover:IsShown() then
            bookmarkPopover:Hide()
            return
        end

        frame.collectionPopover:Hide()
        local collectionMenu = _G.ParchmentReaderCollectionContextMenu
        if collectionMenu then collectionMenu:Hide() end
        local bookMenu = _G.ParchmentReaderBookContextMenu
        if bookMenu then bookMenu:Hide() end
        local movePopover = _G.ParchmentReaderBookMovePopover
        if movePopover then movePopover:Hide() end
        bookmarkPopover:Show()
    end)

    footer:SetScript("OnSizeChanged", function(_, footerWidth)
        navigation:SetWidth(math.max(180, math.min(380, footerWidth - 68)))
    end)

    frame.collectionPopover = CreateCollectionPopover(frame)
    frame.resizeHandle = CreateResizeHandle(frame)
    frame.readerTransparencyControls = {
        closeButton,
        minimizeButton,
        settingsButton,
        helpButton,
        collectionSelector,
        clearSearchButton,
        collapsedLibraryButton,
        collapsedQuickNoteButton,
        addBookButton,
        toggleButton,
        emptyAction,
        previousButton,
        nextButton,
        bookmarkButton,
    }

    function frame:RefreshTopbarIdentityLayout(compact)
        addonLabel:SetShown(not compact)
        pinButton:ClearAllPoints()
        pinButton:SetPoint(
            "LEFT",
            compact and brandSlot or addonLabel,
            "RIGHT",
            compact and 3 or 7,
            0)
    end

    function frame:RefreshTitleAreaLayout()
        local rightControl = ParchmentReaderDB.sidebarCollapsed
            and minimizeButton
            or helpButton
        titleArea:ClearAllPoints()
        titleArea:SetPoint("LEFT", pinButton, "RIGHT", 8, 0)
        titleArea:SetPoint("RIGHT", rightControl, "LEFT", -8, 0)
        titleArea:Show()
    end

    frame:SetScript("OnSizeChanged", function()
        if frame.bookmarkPopover:IsShown() then
            for _, row in ipairs(frame.bookmarkPopover.rows) do
                if row.renaming then
                    CloseBookmarkRename(row, true)
                    return
                end
            end
            RefreshBookmarkPopover(frame.bookmarkPopover)
        end
    end)
    frame:HookScript("OnHide", function()
        ParchmentReader:SetReaderKeyboardFocus(false)
        ParchmentReader:CancelReaderJumpRequests()
        searchBox:ClearFocus()
        if frame.readerResizeActive then
            FinishReaderResize(frame)
        else
            frame:StopMovingOrSizing()
        end
        ParchmentReader:SyncReadingPosition()
        ParchmentReader:SaveReaderPosition()
        ParchmentReader:StopReaderScrollAnimation()
        frame.collectionPopover:Hide()
        frame.bookmarkPopover:Hide()
        local contextMenu = _G.ParchmentReaderCollectionContextMenu
        if contextMenu then contextMenu:Hide() end
        local bookMenu = _G.ParchmentReaderBookContextMenu
        if bookMenu then bookMenu:Hide() end
        if not ParchmentReader.readerMinimized then
            ParchmentReader:HideFloatingLauncher()
        end
    end)
    frame:HookScript("OnShow", function()
        ParchmentReader:UpdateContentWidth()
        ParchmentReader:RefreshCollectionSelector()
        ParchmentReader:RefreshBookList()
        ParchmentReader:RefreshBookmarkControls()
        frame.readerBackgroundTransparent = nil
        ParchmentReader:RefreshReaderTransparency()
    end)
    frame:HookScript("OnUpdate", function(_, elapsed)
        if ParchmentReaderDB.transparencyMode ~= "smart" then return end
        frame.readerTransparencyElapsed = (frame.readerTransparencyElapsed or 0) + elapsed
        if frame.readerTransparencyElapsed < 0.08 then return end
        frame.readerTransparencyElapsed = 0
        ParchmentReader:RefreshReaderTransparency()
    end)

    self:RefreshReaderPinState()
    navigation:SetWidth(math.max(
        180,
        math.min(380, width - metrics.sidebarWidth - 68)))
    self:RefreshCollectionSelector()
    self:RefreshBookList()
    self:RefreshBookmarkControls()
    self:ApplySidebarState(ParchmentReaderDB.sidebarCollapsed)
    self:RefreshReaderTransparency()
    self:RefreshReaderKeyboardFocusVisual()
    frame:Hide()
    return frame
end

function ParchmentReader:RefreshBookList()
    local frame = ParchmentReaderFrame
    if not frame then return end

    for _, button in ipairs(frame.bookButtons) do
        button:Hide()
    end

    local sortedBooks = {}
    for bookKey, bookData in pairs(self.books) do
        sortedBooks[#sortedBooks + 1] = {key = bookKey, data = bookData}
    end
    table.sort(sortedBooks, function(a, b)
        return ParchmentReader:CompareBookTitles(a.data.title, b.data.title)
    end)

    local searchTerms = GetSearchTerms(frame.searchBox and frame.searchBox:GetText())
    local visibleIndex = 1
    local buttonHeight = 26
    for _, entry in ipairs(sortedBooks) do
        local bookKey = entry.key
        local bookData = entry.data
        local visible = not self.currentCollection
            or bookData.custom and bookData.collection == self.currentCollection
        visible = visible and BookMatchesSearch(bookData, searchTerms)

        if visible then
            local button = frame.bookButtons[visibleIndex]
            if not button then
                button = PRUI.Button(frame.bookListScroll, "", {
                    height = buttonHeight,
                    justifyH = "LEFT",
                })
                button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                button.label:ClearAllPoints()
                button.label:SetPoint("LEFT", button.pruiContent, "LEFT", 18, 0)
                button.label:SetPoint("RIGHT", button.pruiContent, "RIGHT", -6, 0)
                button.label:SetJustifyH("LEFT")

                local activeDot = button.pruiContent:CreateTexture(nil, "ARTWORK")
                activeDot:SetSize(5, 5)
                activeDot:SetPoint("LEFT", button.pruiContent, "LEFT", 7, 0)
                local gold = Theme:Get("accent", "gold")
                activeDot:SetColorTexture(gold[1], gold[2], gold[3], gold[4])
                button.activeDot = activeDot

                button:SetScript("OnClick", function(bookButton, mouseButton)
                    local data = ParchmentReader.books[bookButton.bookKey]
                    if not data then return end
                    if mouseButton == "LeftButton" then
                        local menu = _G.ParchmentReaderBookContextMenu
                        if menu then menu:Hide() end
                        ParchmentReader:LoadBook(bookButton.bookKey)
                    elseif mouseButton == "RightButton" then
                        ShowBookContextMenu(bookButton.bookKey, bookButton)
                    end
                end)
                button:HookScript("OnEnter", function(bookButton)
                    local data = ParchmentReader.books[bookButton.bookKey]
                    if not data then return end
                    GameTooltip:SetOwner(bookButton, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetText(data.title)
                    if not ParchmentReader.currentCollection and data.collection then
                        local accent = Theme:Get("accent", "gold")
                        GameTooltip:AddLine(data.collection, accent[1], accent[2], accent[3])
                    end
                    local saved = ParchmentReaderDB.customBooks
                        and ParchmentReaderDB.customBooks[bookButton.bookKey]
                    if saved and saved.createdAt then
                        local muted = Theme:Get("text", "muted")
                        GameTooltip:AddLine(
                            date("%Y-%m-%d", saved.createdAt),
                            muted[1],
                            muted[2],
                            muted[3])
                    end
                    local secondary = Theme:Get("text", "secondary")
                    GameTooltip:AddLine(
                        L["Right-click for book actions"],
                        secondary[1],
                        secondary[2],
                        secondary[3])
                    GameTooltip:Show()
                end)
                button:HookScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                PRUI.SetButtonIdleBackgroundAlpha(
                    button,
                    frame.readerBackgroundTransparent
                        and TRANSPARENT_DENSE_CONTROL_IDLE_ALPHA
                        or 1)
                frame.bookButtons[visibleIndex] = button
            end

            button.bookKey = bookKey
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", frame.bookListScroll, "TOPLEFT", 0, -(visibleIndex - 1) * buttonHeight)
            button:SetPoint("TOPRIGHT", frame.bookListScroll, "TOPRIGHT", 0, -(visibleIndex - 1) * buttonHeight)
            button:SetHeight(buttonHeight)
            button:SetText(bookData.title)
            local isCurrent = self.currentBook == bookKey
            PRUI.SetButtonSelected(button, isCurrent)
            if isCurrent then
                button.activeDot:Show()
            else
                button.activeDot:Hide()
            end
            button:Show()
            visibleIndex = visibleIndex + 1
        end
    end

    local contentHeight = math.max(1, (visibleIndex - 1) * buttonHeight)
    frame.bookListScroll:SetHeight(contentHeight)
    frame.bookListScroll:SetWidth(math.max(1, frame.sidebarScroll:GetWidth()))
    if visibleIndex == 1 then
        local emptyState = frame.bookListEmptyState
        if #searchTerms > 0 then
            emptyState.title:SetText(L["No books found"])
            if self.currentCollection then
                emptyState.message:SetText(string.format(
                    L["No books in |cFFD1AD61%s|r match this search."],
                    self.currentCollection))
            else
                emptyState.message:SetText(L[
                    "Try another title or collection name, or clear the search."])
            end
            emptyState.actionButton:SetText(L["Clear Search"])
            emptyState.actionButton.action = "clear-search"
        elseif self.currentCollection then
            emptyState.title:SetText(L["This collection is empty"])
            emptyState.message:SetText(
                L["Add a book to start filling this collection."])
            emptyState.actionButton:SetText(L["+  Add Book"])
            emptyState.actionButton.action = "add-book"
        else
            emptyState.title:SetText(L["Your library is empty"])
            emptyState.message:SetText(
                L["Add your first book to begin your library."])
            emptyState.actionButton:SetText(L["+  Add First Book"])
            emptyState.actionButton.action = "add-book"
        end
        emptyState:Show()
    else
        frame.bookListEmptyState:Hide()
    end
    ClampBookListScroll(frame)
end
