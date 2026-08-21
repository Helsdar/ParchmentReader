

local READER_BINDING = "PARCHMENTREADER_TOGGLE_READER"
local MINIMIZE_BINDING = "PARCHMENTREADER_TOGGLE_MINIMIZE"
local QUICK_NOTE_BINDING = "PARCHMENTREADER_QUICK_NOTE"
local ADDON_NAME = "ParchmentReader"
local L = ParchmentReader.L

local MODIFIER_KEYS = {
    LALT = true,
    RALT = true,
    LCTRL = true,
    RCTRL = true,
    LSHIFT = true,
    RSHIFT = true,
}

local function FormatBindingKey(key)
    if not key or key == "" then return L["Not assigned"] end
    if GetBindingText then
        local text = GetBindingText(key, "KEY_", true)
        if text and text ~= "" then return text end
    end
    return key
end

local function GetBindingLabel(action)
    return _G["BINDING_NAME_" .. action] or action
end

local function StopBindingCapture(frame, consumeCurrentKey)
    if not frame then return end

    local action = frame.capturingBindingAction
    frame.capturingBindingAction = nil
    if consumeCurrentKey and not InCombatLockdown() then
        frame:SetPropagateKeyboardInput(false)
    end
    frame:EnableKeyboard(false)
    if not InCombatLockdown() then
        if consumeCurrentKey then
            C_Timer.After(0, function()
                if not frame.capturingBindingAction and not InCombatLockdown() then
                    frame:SetPropagateKeyboardInput(true)
                end
            end)
        else
            frame:SetPropagateKeyboardInput(true)
        end
    end

    if not action then return end

    local control = frame.bindingControls and frame.bindingControls[action]
    if control then
        control.setKeyButton:SetText(L["Set Key"])
    end
end

local function StartBindingCapture(frame, action)
    if InCombatLockdown() then
        ParchmentReader:PrintMessage(
            "Key bindings cannot be changed in combat.")
        return
    end

    StopBindingCapture(frame)
    frame.capturingBindingAction = action
    frame:EnableKeyboard(true)
    frame:SetPropagateKeyboardInput(false)
    frame.bindingControls[action].setKeyButton:SetText(L["Press a key…"])
end

local function BuildBindingKey(key)
    local parts = {}
    if IsControlKeyDown and IsControlKeyDown() then
        parts[#parts + 1] = "CTRL"
    end
    if IsAltKeyDown and IsAltKeyDown() then
        parts[#parts + 1] = "ALT"
    end
    if IsShiftKeyDown and IsShiftKeyDown() then
        parts[#parts + 1] = "SHIFT"
    end
    parts[#parts + 1] = key
    return table.concat(parts, "-")
end

local function GetAddonMetadata(field)
    return C_AddOns.GetAddOnMetadata(ADDON_NAME, field) or ""
end

function ParchmentReader:RegisterWoWSettingsCategory()
    if self.wowSettingsCategory then
        return self.wowSettingsCategory
    end

    local title = GetAddonMetadata("Title")
    local panel = CreateFrame("Frame", "ParchmentReaderWoWSettingsPanel")
    panel.name = title

    local heading = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    heading:SetText(title)

    local notes = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    notes:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -48)
    notes:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -32, -48)
    notes:SetJustifyH("LEFT")
    notes:SetJustifyV("TOP")
    notes:SetWordWrap(true)
    notes:SetText(L["An in-game library for reading, organizing, and bookmarking books and notes"])

    local author = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    author:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -20)
    author:SetText(string.format(
        L["Author: %s"], GetAddonMetadata("Author")))

    local version = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -8)
    version:SetText(string.format(
        L["Version: %s"], GetAddonMetadata("Version")))

    local openButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    openButton:SetSize(180, 24)
    openButton:SetPoint("TOPLEFT", version, "BOTTOMLEFT", -2, -20)
    openButton:SetText(L["Open Settings"])
    openButton:SetScript("OnClick", function()
        ParchmentReader:ShowSettings()
    end)

    local category = Settings.RegisterCanvasLayoutCategory(panel, title)
    Settings.RegisterAddOnCategory(category)

    self.wowSettingsPanel = panel
    self.wowSettingsCategory = category
    return category
end

function ParchmentReader:RefreshBindingControl(action)
    local frame = ParchmentReaderSettingsFrame
    local control = frame and frame.bindingControls and frame.bindingControls[action]
    if not control then return end

    local key1, key2 = GetBindingKey(action)
    local value = FormatBindingKey(key1)
    if key2 then
        value = value .. " / " .. FormatBindingKey(key2)
    end
    control.bindingValue:SetText(value)
    if key1 or key2 then
        control.clearKeyButton:Enable()
    else
        control.clearKeyButton:Disable()
    end
end

function ParchmentReader:RefreshAddonBindingControls()
    self:RefreshBindingControl(READER_BINDING)
    self:RefreshBindingControl(MINIMIZE_BINDING)
    self:RefreshBindingControl(QUICK_NOTE_BINDING)
end

function ParchmentReader:SetAddonBinding(action, key)
    if InCombatLockdown() then
        self:PrintMessage("Key bindings cannot be changed in combat.")
        return false
    end

    local oldKey1, oldKey2 = GetBindingKey(action)
    if not SetBinding(key, action) then
        self:PrintMessage("Could not assign %s.", GetBindingLabel(action))
        return false
    end

    if oldKey1 and oldKey1 ~= key then SetBinding(oldKey1) end
    if oldKey2 and oldKey2 ~= key then SetBinding(oldKey2) end
    SaveBindings(GetCurrentBindingSet())
    self:RefreshAddonBindingControls()
    return true
end

function ParchmentReader:ClearAddonBinding(action, silent)
    if InCombatLockdown() then
        if not silent then
            self:PrintMessage("Key bindings cannot be changed in combat.")
        end
        return false
    end

    local key1, key2 = GetBindingKey(action)
    if key1 then SetBinding(key1) end
    if key2 then SetBinding(key2) end
    if key1 or key2 then
        SaveBindings(GetCurrentBindingSet())
    end
    self:RefreshAddonBindingControls()
    return true
end

function ParchmentReader:CreateSettingsFrame()
    local metrics = self.Theme.metrics
    local Theme = self.Theme
    local PRUI = self.PRUI
    local minWidth, minHeight = self:GetReaderMinimumSize()
    ParchmentReaderDB.windowWidth = math.max(
        minWidth,
        math.min(tonumber(ParchmentReaderDB.windowWidth) or metrics.defaultWidth, metrics.maxWidth))
    ParchmentReaderDB.windowHeight = math.max(
        minHeight,
        math.min(tonumber(ParchmentReaderDB.windowHeight) or metrics.defaultHeight, metrics.maxHeight))

    local frame = PRUI.Window(UIParent, {
        name = "ParchmentReaderSettingsFrame",
        title = L["Parchment Reader Settings"],
    })
    frame:SetSize(440, 708)
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    frame:EnableKeyboard(false)
    PRUI.SetAddonFrameLayer(frame, PRUI.ADDON_FRAME_LEVELS.WINDOW)
    frame:SetToplevel(true)
    self:RegisterEscapeClose("ParchmentReaderSettingsFrame")


    local debugBtn = PRUI.Button(
        frame.topbar, L["Debug"], {width = 112, height = 24})
    debugBtn:SetPoint("RIGHT", frame.closeButton, "LEFT", -4, 0)
    frame.title:ClearAllPoints()
    frame.title:SetPoint("LEFT", frame.topbar, "LEFT", 12, 0)
    frame.title:SetPoint("RIGHT", debugBtn, "LEFT", -8, 0)
    debugBtn:SetScript("OnClick", function()
        ParchmentReader:ShowDebugInfo()
    end)

    frame.title:SetPoint("RIGHT", debugBtn, "LEFT", -8, 0)

    local yOffset = -58
    local spacing = 62


    local languageText = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormalSmall")
    languageText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
    languageText:SetText(L["Interface language:"])
    PRUI.SetFontStringColor(languageText, Theme:Get("text", "secondary"))

    StaticPopupDialogs["PARCHMENTREADER_RELOAD_LANGUAGE"] = {
        text = L["Language choice saved.\n\nReload the interface now?"],
        button1 = L["Reload UI"],
        button2 = L["Later"],
        OnAccept = ReloadUI,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local languageItems = {
        {value = "auto", text = L["Auto — WoW client language"]},
        {value = "enUS", text = L["English"]},
        {value = "deDE", text = L["Deutsch"]},
        {value = "frFR", text = L["Français"]},
        {value = "esES", text = L["Español"]},
        {value = "ruRU", text = L["Русский"]},
    }
    local languageDropdown = PRUI.Dropdown(frame, {
        name = "ParchmentReaderLanguageDropdown",
        popoverName = "ParchmentReaderLanguagePopover",
        width = 300,
        value = ParchmentReaderDB.interfaceLanguage or "auto",
        items = languageItems,
        onValueChanged = function(value)
            value = ParchmentReader:NormalizeInterfaceLanguage(value)
            if ParchmentReaderDB.interfaceLanguage == value then return end
            ParchmentReaderDB.interfaceLanguage = value
            StaticPopup_Show("PARCHMENTREADER_RELOAD_LANGUAGE")
        end,
    })
    languageDropdown:SetPoint("TOPLEFT", languageText, "BOTTOMLEFT", 0, -5)
    frame.languageDropdown = languageDropdown

    local languageHint = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormalSmall")
    languageHint:SetPoint("LEFT", languageDropdown, "RIGHT", 8, 0)
    languageHint:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
    languageHint:SetJustifyH("LEFT")
    languageHint:SetText(L["Applied after reload."])
    PRUI.SetFontStringColor(languageHint, Theme:Get("text", "muted"))

    yOffset = yOffset - spacing


    local widthText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    widthText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
    widthText:SetText(L["Window width:"])
    PRUI.SetFontStringColor(widthText, Theme:Get("text", "secondary"))

    local widthSlider = PRUI.Slider(frame, {
        name = "ParchmentReaderWidthSlider",
        width = 400,
    })
    widthSlider:SetPoint("TOPLEFT", widthText, "BOTTOMLEFT", 0, -12)
    widthSlider:SetMinMaxValues(minWidth, metrics.maxWidth)
    widthSlider:SetValue(ParchmentReaderDB.windowWidth or metrics.defaultWidth)
    widthSlider:SetValueStep(20)
    widthSlider:SetObeyStepOnDrag(true)
    widthSlider:SetRangeLabels(minWidth, metrics.maxWidth)
    frame.widthSlider = widthSlider

    widthSlider:HookScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.valueText:SetText(value)
        if frame.syncingSizeControls then return end
        ParchmentReaderDB.windowWidth = value

        if ParchmentReaderFrame then
            ParchmentReaderFrame:SetWidth(value)
            ParchmentReader:SaveReaderPosition()

            ParchmentReader:UpdateContentWidth()
        end
    end)

    yOffset = yOffset - spacing


    local heightText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    heightText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
    heightText:SetText(L["Window height:"])
    PRUI.SetFontStringColor(heightText, Theme:Get("text", "secondary"))

    local heightSlider = PRUI.Slider(frame, {
        name = "ParchmentReaderHeightSlider",
        width = 400,
    })
    heightSlider:SetPoint("TOPLEFT", heightText, "BOTTOMLEFT", 0, -12)
    heightSlider:SetMinMaxValues(minHeight, metrics.maxHeight)
    heightSlider:SetValue(ParchmentReaderDB.windowHeight or metrics.defaultHeight)
    heightSlider:SetValueStep(20)
    heightSlider:SetObeyStepOnDrag(true)
    heightSlider:SetRangeLabels(minHeight, metrics.maxHeight)
    frame.heightSlider = heightSlider

    heightSlider:HookScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.valueText:SetText(value)
        if frame.syncingSizeControls then return end
        ParchmentReaderDB.windowHeight = value

        if ParchmentReaderFrame then
            ParchmentReaderFrame:SetHeight(value)
            ParchmentReader:SaveReaderPosition()

        end
    end)

    yOffset = yOffset - spacing - 4


    local fontText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fontText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
    fontText:SetText(L["Font:"])
    PRUI.SetFontStringColor(fontText, Theme:Get("text", "secondary"))

    local fontDropdown = PRUI.Dropdown(frame, {
        name = "ParchmentReaderFontDropdown",
        popoverName = "ParchmentReaderFontPopover",
        width = 300,
        value = ParchmentReaderDB.fontName or "ChatFontNormal",
        items = {
            {value = "ChatFontNormal", text = L["Chat Font (EN/DE/FR/RU/ES)"]},
            {value = "QuestFont", text = L["Quest Font (Latin sizing)"]},
            {value = "GameFontNormal", text = L["Game Font (Latin sizing)"]},
            {value = "MORPHEUS.TTF", text = L["Morpheus (Latin only)"]},
        },
        onValueChanged = function(value)
            ParchmentReaderDB.fontName = value
            ParchmentReader:UpdateFont()
        end,
    })
    fontDropdown:SetPoint("TOPLEFT", fontText, "BOTTOMLEFT", 0, -5)

    local fontHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fontHint:SetPoint("TOPLEFT", fontDropdown, "BOTTOMLEFT", 0, -4)
    fontHint:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
    fontHint:SetJustifyH("LEFT")
    fontHint:SetText(L["Chat Font scales Latin and Cyrillic consistently."])
    PRUI.SetFontStringColor(fontHint, Theme:Get("text", "muted"))

    yOffset = yOffset - 72


    local fontSizeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fontSizeText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
    fontSizeText:SetText(L["Font size:"])
    PRUI.SetFontStringColor(fontSizeText, Theme:Get("text", "secondary"))

    local fontSizeSlider = PRUI.Slider(frame, {
        name = "ParchmentReaderFontSizeSlider",
        width = 400,
    })
    fontSizeSlider:SetPoint("TOPLEFT", fontSizeText, "BOTTOMLEFT", 0, -12)
    fontSizeSlider:SetMinMaxValues(8, 24)
    fontSizeSlider:SetValue(ParchmentReaderDB.fontSize or 14)
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider:SetObeyStepOnDrag(true)
    fontSizeSlider:SetRangeLabels(8, 24)

    fontSizeSlider:HookScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.valueText:SetText(value)
        ParchmentReaderDB.fontSize = value
        ParchmentReader:UpdateFont()
    end)

    yOffset = yOffset - spacing


    local transparencyText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    transparencyText:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
    transparencyText:SetText(L["Reader transparency:"])
    PRUI.SetFontStringColor(transparencyText, Theme:Get("text", "secondary"))

    local transparencyDropdown = PRUI.Dropdown(frame, {
        name = "ParchmentReaderTransparencyDropdown",
        popoverName = "ParchmentReaderTransparencyPopover",
        width = 340,
        value = ParchmentReaderDB.transparencyMode or "off",
        items = {
            {value = "off", text = L["Off — standard background"]},
            {value = "always", text = L["Always — transparent background"]},
            {value = "smart", text = L["Smart — transparent until hovered"]},
        },
        onValueChanged = function(value)
            ParchmentReader:SetReaderTransparencyMode(value)
        end,
    })
    transparencyDropdown:SetPoint("TOPLEFT", transparencyText, "BOTTOMLEFT", 0, -5)

    local transparencyHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    transparencyHint:SetPoint("TOPLEFT", transparencyDropdown, "BOTTOMLEFT", 0, -4)
    transparencyHint:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
    transparencyHint:SetJustifyH("LEFT")
    transparencyHint:SetText(
        L["Smart restores the glass background while you interact with the reader."])
    PRUI.SetFontStringColor(transparencyHint, Theme:Get("text", "muted"))

    yOffset = yOffset - 82


    local minimapCheck = PRUI.Checkbox(frame, L["Show minimap button"], {
        name = "ParchmentReaderMinimapCheck",
        width = 208,
    })
    minimapCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, yOffset)
    minimapCheck:SetChecked(not ParchmentReaderDB.hide)
    PRUI.RefreshCheckbox(minimapCheck)

    minimapCheck:HookScript("OnClick", function(self)
        local checked = self:GetChecked()
        ParchmentReaderDB.hide = not checked

        if ParchmentReader.minimapBtn then
            if checked then
                ParchmentReader.minimapBtn:Show()
            else
                ParchmentReader.minimapBtn:Hide()
            end
        end
    end)

    local keyboardNavigationCheck = PRUI.Checkbox(
        frame, L["Keyboard navigation"], {
            name = "ParchmentReaderKeyboardNavigationCheck",
            width = 184,
        })
    keyboardNavigationCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 236, yOffset)
    keyboardNavigationCheck:SetChecked(
        ParchmentReaderDB.readerKeyboardNavigation ~= false)
    PRUI.RefreshCheckbox(keyboardNavigationCheck)
    PRUI.AttachTooltip(
        keyboardNavigationCheck,
        L["Activate: click the page.\nExit: click elsewhere or press Esc."])
    keyboardNavigationCheck:HookScript("OnClick", function(self)
        ParchmentReader:SetReaderKeyboardNavigationEnabled(
            self:GetChecked() == true)
    end)
    frame.keyboardNavigationCheck = keyboardNavigationCheck

    local shortcutsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    shortcutsText:SetPoint("TOPLEFT", minimapCheck, "BOTTOMLEFT", 0, -22)
    shortcutsText:SetText(L["Shortcuts:"])
    PRUI.SetFontStringColor(shortcutsText, Theme:Get("text", "secondary"))

    frame.bindingControls = {}

    local function CreateBindingRow(action, label, anchor, yOffset)
        local row = CreateFrame("Frame", nil, frame)
        row:SetSize(400, 26)
        row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOffset)

        local rowLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rowLabel:SetPoint("LEFT", row, "LEFT", 0, 0)
        rowLabel:SetWidth(88)
        rowLabel:SetJustifyH("LEFT")
        rowLabel:SetText(label)
        PRUI.SetFontStringColor(rowLabel, Theme:Get("text", "secondary"))

        local bindingSurface = PRUI.Panel(row, {color = Theme:Get("bg", "control")})
        bindingSurface:SetPoint("LEFT", rowLabel, "RIGHT", 6, 0)
        bindingSurface:SetSize(124, 26)
        bindingSurface:EnableMouse(true)

        local bindingValue = bindingSurface:CreateFontString(
            nil, "OVERLAY", "GameFontNormalSmall")
        bindingValue:SetPoint("LEFT", bindingSurface, "LEFT", 8, 0)
        bindingValue:SetPoint("RIGHT", bindingSurface, "RIGHT", -8, 0)
        bindingValue:SetJustifyH("LEFT")
        bindingValue:SetWordWrap(false)
        PRUI.SetFontStringColor(bindingValue, Theme:Get("text", "primary"))
        PRUI.AttachTooltip(bindingSurface, function()
            return bindingValue:GetText()
        end)

        local setKeyButton = PRUI.Button(
            row, L["Set Key"], {width = 92, height = 26})
        setKeyButton:SetPoint("LEFT", bindingSurface, "RIGHT", 8, 0)
        setKeyButton:SetScript("OnClick", function()
            StartBindingCapture(frame, action)
        end)

        local clearKeyButton = PRUI.Button(
            row, L["Clear"], {width = 68, height = 26})
        clearKeyButton:SetPoint("LEFT", setKeyButton, "RIGHT", 8, 0)
        clearKeyButton:SetScript("OnClick", function()
            ParchmentReader:ClearAddonBinding(action)
        end)

        frame.bindingControls[action] = {
            bindingValue = bindingValue,
            clearKeyButton = clearKeyButton,
            setKeyButton = setKeyButton,
        }
        return row
    end

    local readerBindingRow = CreateBindingRow(
        READER_BINDING, L["Reader:"], shortcutsText, -7)
    local minimizeBindingRow = CreateBindingRow(
        MINIMIZE_BINDING, L["Minimize:"], readerBindingRow, -6)
    local quickNoteBindingRow = CreateBindingRow(
        QUICK_NOTE_BINDING, L["Quick Note:"], minimizeBindingRow, -6)

    local bindingHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bindingHint:SetPoint("TOPLEFT", quickNoteBindingRow, "BOTTOMLEFT", 0, -5)
    bindingHint:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
    bindingHint:SetJustifyH("LEFT")
    bindingHint:SetText(
        L["Also available in WoW Key Bindings; disabled in combat."])
    PRUI.SetFontStringColor(bindingHint, Theme:Get("text", "muted"))

    StaticPopupDialogs["PARCHMENTREADER_REPLACE_BINDING"] = {
        text = L["%s is already assigned to %s. Replace it?"],
        button1 = L["Replace"],
        button2 = L["Cancel"],
        OnAccept = function(_, data)
            ParchmentReader:SetAddonBinding(data.action, data.key)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    frame:SetScript("OnKeyDown", function(settingsFrame, key)
        local action = settingsFrame.capturingBindingAction
        if not action then
            StopBindingCapture(settingsFrame)
            return
        end
        if key == "ESCAPE" then
            StopBindingCapture(settingsFrame, true)
            return
        end
        if MODIFIER_KEYS[key] or key == "UNKNOWN" then return end

        local bindingKey = BuildBindingKey(key)
        StopBindingCapture(settingsFrame, true)
        local existingAction = GetBindingAction(bindingKey)
        if existingAction and existingAction ~= ""
            and existingAction ~= action
        then
            StaticPopup_Show(
                "PARCHMENTREADER_REPLACE_BINDING",
                FormatBindingKey(bindingKey),
                GetBindingLabel(existingAction),
                {action = action, key = bindingKey})
        else
            ParchmentReader:SetAddonBinding(action, bindingKey)
        end
    end)

    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:SetScript("OnEvent", function(settingsFrame, event)
        if event == "PLAYER_REGEN_DISABLED" and settingsFrame.capturingBindingAction then
            StopBindingCapture(settingsFrame)
            ParchmentReader:PrintMessage(
                "Key capture cancelled because combat started.")
        end
    end)
    frame:HookScript("OnShow", function(settingsFrame)
        StopBindingCapture(settingsFrame)
        ParchmentReader:RefreshAddonBindingControls()
    end)
    frame:HookScript("OnHide", function(settingsFrame)
        StopBindingCapture(settingsFrame)
    end)
    StopBindingCapture(frame)
    self:RefreshAddonBindingControls()

    StaticPopupDialogs["PARCHMENTREADER_RESET"] = {
        text = L["Reset all settings to defaults?"],
        button1 = L["Reset to Defaults"],
        button2 = L["Cancel"],
        OnAccept = function()

            ParchmentReaderDB.windowWidth = metrics.defaultWidth
            ParchmentReaderDB.windowHeight = metrics.defaultHeight
            ParchmentReaderDB.windowX = 0
            ParchmentReaderDB.windowY = 0
            ParchmentReaderDB.fontSize = 14
            ParchmentReaderDB.fontName = "ChatFontNormal"
            ParchmentReaderDB.hide = false
            ParchmentReaderDB.minimapAngle = 315
            ParchmentReaderDB.sidebarCollapsed = false
            ParchmentReaderDB.transparencyMode = "off"
            ParchmentReaderDB.readerMinimized = false
            ParchmentReader.readerMinimized = false
            ParchmentReaderDB.readerPinned = false
            ParchmentReaderDB.readerKeyboardNavigation = true
            local reloadForLanguage = ParchmentReader.locale
                ~= ParchmentReader:ResolveInterfaceLocale("auto")
            ParchmentReaderDB.interfaceLanguage = "auto"
            ParchmentReader:HideFloatingLauncher()
            ParchmentReader:ResetFloatingLauncherSettings()
            ParchmentReader:RefreshReaderPinState()
            ParchmentReader:RefreshEscapeCloseRegistration()
            ParchmentReader:ClearAddonBinding(READER_BINDING, true)
            ParchmentReader:ClearAddonBinding(MINIMIZE_BINDING, true)
            ParchmentReader:ClearAddonBinding(QUICK_NOTE_BINDING, true)


            widthSlider:SetValue(metrics.defaultWidth)
            heightSlider:SetValue(metrics.defaultHeight)
            fontSizeSlider:SetValue(14)
            fontDropdown:SetValue("ChatFontNormal", true)
            transparencyDropdown:SetValue("off", true)
            minimapCheck:SetChecked(true)
            PRUI.RefreshCheckbox(minimapCheck)
            keyboardNavigationCheck:SetChecked(true)
            PRUI.RefreshCheckbox(keyboardNavigationCheck)
            languageDropdown:SetValue("auto", true)


            if ParchmentReaderFrame then
                ParchmentReaderFrame:SetWidth(metrics.defaultWidth)
                ParchmentReaderFrame:SetHeight(metrics.defaultHeight)
                ParchmentReader:ApplySidebarState(false)
                ParchmentReaderDB.windowX = 0
                ParchmentReaderDB.windowY = 0
                ParchmentReader:ApplyReaderPosition()
            end

            if ParchmentReader.minimapBtn then
                ParchmentReader.minimapBtn:Show()
                ParchmentReader:UpdateMinimapButtonPosition()
            end

            ParchmentReader:UpdateFont()
            ParchmentReader:SetReaderTransparencyMode("off")
            ParchmentReader:SetReaderKeyboardNavigationEnabled(true)

            if reloadForLanguage then
                StaticPopup_Show("PARCHMENTREADER_RELOAD_LANGUAGE")
            end

        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }


    local resetButton = PRUI.Button(
        frame, L["Reset to Defaults"], {width = 176, height = 26})
    resetButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 16)
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("PARCHMENTREADER_RESET")
    end)


    local closeButton = PRUI.Button(frame, L["Close"], {width = 104, height = 26})
    closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 16)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    frame:Hide()
    return frame
end

function ParchmentReader:SyncWindowSizeControls(width, height)
    local frame = ParchmentReaderSettingsFrame
    if not frame or not frame.widthSlider or not frame.heightSlider then return end

    local metrics = self.Theme.metrics
    local minWidth, minHeight = self:GetReaderMinimumSize()
    frame.syncingSizeControls = true
    frame.widthSlider:SetMinMaxValues(minWidth, metrics.maxWidth)
    frame.widthSlider:SetRangeLabels(minWidth, metrics.maxWidth)
    frame.heightSlider:SetMinMaxValues(minHeight, metrics.maxHeight)
    frame.heightSlider:SetRangeLabels(minHeight, metrics.maxHeight)
    frame.widthSlider:SetValue(width or ParchmentReaderDB.windowWidth)
    frame.heightSlider:SetValue(height or ParchmentReaderDB.windowHeight)
    frame.syncingSizeControls = false
end
