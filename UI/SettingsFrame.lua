

local READER_BINDING = "PARCHMENTREADER_TOGGLE_READER"
local COMPACT_BINDING = "PARCHMENTREADER_TOGGLE_COMPACT"
local MINIMIZE_BINDING = "PARCHMENTREADER_TOGGLE_MINIMIZE"
local QUICK_NOTE_BINDING = "PARCHMENTREADER_QUICK_NOTE"
local RESUME_QUICK_NOTE_BINDING = "PARCHMENTREADER_RESUME_QUICK_NOTE"
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
        ParchmentReader:RefreshBindingControl(action)
        ParchmentReader.PRUI.SetButtonSelected(control.setKeyButton, false)
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
    ParchmentReader.PRUI.SetButtonSelected(frame.bindingControls[action].setKeyButton, true)
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
    if frame.capturingBindingAction ~= action then control.bindingValue:SetText(value) end
    if key1 or key2 then
        control.clearKeyButton:Enable()
    else
        control.clearKeyButton:Disable()
    end
end

function ParchmentReader:RefreshAddonBindingControls()
    self:RefreshBindingControl(READER_BINDING)
    self:RefreshBindingControl(COMPACT_BINDING)
    self:RefreshBindingControl(MINIMIZE_BINDING)
    self:RefreshBindingControl(QUICK_NOTE_BINDING)
    self:RefreshBindingControl(RESUME_QUICK_NOTE_BINDING)
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
    frame:SetSize(644, 510)
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    frame:EnableKeyboard(false)
    PRUI.SetAddonFrameLayer(frame, PRUI.ADDON_FRAME_LEVELS.WINDOW)
    frame:SetToplevel(true)
    self:RegisterEscapeClose("ParchmentReaderSettingsFrame")



    frame.sections, frame.sectionButtons, frame.numericInputs = {}, {}, {}
    local navigation = PRUI.Panel(frame, {color = Theme:Get("bg", "sidebar")})
    navigation:SetPoint("TOPLEFT", frame.topbar, "BOTTOMLEFT", 0, 0)
    navigation:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 45)
    navigation:SetWidth(144)
    local footer = PRUI.Panel(frame, {color = Theme:Get("bg", "sidebar")})
    footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
    footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    footer:SetHeight(44)

    local function Text(parent, text, x, y, width, role, font)
        local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
        label:SetWidth(width or 456)
        label:SetJustifyH("LEFT")
        label:SetJustifyV("TOP")
        label:SetWordWrap(true)
        label:SetText(text)
        PRUI.SetFontStringColor(label, Theme:Get("text", role or "secondary"))
        return label
    end
    local function Section(key, title, description, index)
        local panel = CreateFrame("Frame", nil, frame)
        panel:SetPoint("TOPLEFT", frame, "TOPLEFT", 166, -52)
        panel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -22, 58)
        Text(panel, title, 0, 0, nil, "primary", "GameFontNormalLarge")
        Text(panel, description, 0, 27, nil, "muted")
        frame.sections[key] = panel
        local button = PRUI.Button(navigation, title, {width = 124, height = 32, justifyH = "LEFT"})
        button:SetPoint("TOPLEFT", navigation, "TOPLEFT", 10, -(16 + (index - 1) * 40))
        button:SetScript("OnClick", function() frame:SelectSection(key) end)
        frame.sectionButtons[key] = button
        return panel
    end
    function frame:SelectSection(key)
        if not self.sections[key] then return end
        StopBindingCapture(self)
        for _, input in ipairs(self.numericInputs) do input:ClearFocus() end
        self.selectedSection = key
        for sectionKey, panel in pairs(self.sections) do
            panel:SetShown(sectionKey == key)
            PRUI.SetButtonSelected(self.sectionButtons[sectionKey], sectionKey == key)
        end
    end
    local reading = Section("reading", L["Reading"], L["Font and window size for comfortable reading."], 1)
    local appearance = Section("appearance", L["Appearance"], L["Choose a theme and background behavior."], 2)
    local controls = Section("controls", L["Controls"], L["Navigation and quick access to the reader."], 3)
    local general = Section("general", L["General"], L["Interface language and maintenance."], 4)



    local function NumberControl(parent, label, name, x, y, width, low, high, step, value, apply)
        Text(parent, label, x, y + 7, width - 74)
        local input, surface = PRUI.EditBox(parent, {name = name .. "Input", fontObject = "GameFontNormalSmall"})
        surface:SetSize(66, 28)
        surface:SetPoint("TOPLEFT", parent, "TOPLEFT", x + width - 66, -y)
        input:SetNumeric(true)
        input:SetMaxLetters(4)
        input:SetJustifyH("RIGHT")
        local slider = PRUI.Slider(parent, {name = name, width = width})
        slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -(y + 36))
        slider:SetMinMaxValues(low, high)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        slider:SetRangeLabels(low, high)
        slider.valueText:Hide()
        slider:SetValue(value)
        input:SetText(tostring(math.floor(value)))
        slider.numericInput = input
        frame.numericInputs[#frame.numericInputs + 1] = input
        slider:HookScript("OnValueChanged", function(_, current)
            current = math.floor(current)
            input:SetText(tostring(current))
            if not frame.syncingSizeControls then apply(current) end
        end)
        local function Commit()
            local minimum, maximum = slider:GetMinMaxValues()
            local current = tonumber(input:GetText())
            if current then
                slider:SetValue(math.max(minimum, math.min(maximum, math.floor(current))))
            end
            input:SetText(tostring(math.floor(slider:GetValue())))
        end
        input:HookScript("OnEditFocusLost", Commit)
        input:SetScript("OnEnterPressed", function() Commit(); input:ClearFocus() end)
        input:SetScript("OnEscapePressed", function()
            input:SetText(tostring(math.floor(slider:GetValue())))
            input:ClearFocus()
        end)
        return slider
    end

    Text(reading, L["Font:"], 0, 56)
    local fontDropdown = PRUI.Dropdown(reading, {
        name = "ParchmentReaderFontDropdown", popoverName = "ParchmentReaderFontPopover",
        popoverShadow = false, popoverPadding = 8, rowBorder = false, justifyH = "LEFT",
        width = 456, height = 28, value = ParchmentReaderDB.fontName or "ChatFontNormal",
        items = {
            {value = "ChatFontNormal", text = L["Chat Font (EN/DE/FR/RU/ES)"]},
            {value = "QuestFont", text = L["Quest Font (Latin sizing)"]},
            {value = "GameFontNormal", text = L["Game Font (Latin sizing)"]},
            {value = "MORPHEUS.TTF", text = L["Morpheus (Latin only)"]},
        },
        onValueChanged = function(value)
            ParchmentReaderDB.fontName = value
            ParchmentReader:UpdateFont()
            frame:RefreshFontSample()
        end,
    })
    fontDropdown:SetPoint("TOPLEFT", reading, "TOPLEFT", 0, -72)
    frame.fontDropdown = fontDropdown
    local fontHint = Text(reading, "", 0, 108, nil, "muted")
    local fontSizeSlider = NumberControl(reading, L["Font size:"], "ParchmentReaderFontSizeSlider",
        0, 136, 456, 8, 24, 1, ParchmentReaderDB.fontSize or 14, function(value)
            ParchmentReaderDB.fontSize = value
            ParchmentReader:UpdateFont()
            frame:RefreshFontSample()
        end)
    frame.fontSizeSlider = fontSizeSlider
    local sampleSurface = PRUI.Panel(reading, {color = Theme:Get("bg", "surface")})
    sampleSurface:SetSize(456, 92)
    sampleSurface:SetPoint("TOPLEFT", reading, "TOPLEFT", 0, -212)
    PRUI.ApplyPaperSurface(sampleSurface, false)
    Text(sampleSurface, L["Text preview"], 12, 8, 432, "muted")
    frame.fontSample = Text(sampleSurface, L["A quiet evening in Azeroth."], 12, 28, 432, "primary")
    frame.fontSample:SetHeight(56)
    frame.fontSample:SetMaxLines(2)
    function frame:RefreshFontSample()
        ParchmentReader:ApplyFontTo(self.fontSample)
        PRUI.SetFontStringColor(self.fontSample, Theme:Get("text", "primary"))
        fontHint:SetText(ParchmentReaderDB.fontName == "ChatFontNormal"
            and L["Chat Font scales Latin and Cyrillic consistently."]
            or L["Quest and Game fonts use fixed-size Cyrillic fallback; Morpheus supports Latin only."])
    end
    Text(reading, L["Reader window size"], 0, 316, nil, "primary")
    local widthSlider = NumberControl(reading, L["Window width:"], "ParchmentReaderWidthSlider",
        0, 332, 216, minWidth, metrics.maxWidth, 20, ParchmentReaderDB.windowWidth, function(value)
            ParchmentReaderDB.windowWidth = value
            if ParchmentReaderFrame then
                ParchmentReaderFrame:SetWidth(value)
                ParchmentReader:SaveReaderPosition()
                ParchmentReader:UpdateContentWidth()
            end
        end)
    local heightSlider = NumberControl(reading, L["Window height:"], "ParchmentReaderHeightSlider",
        240, 332, 216, minHeight, metrics.maxHeight, 20, ParchmentReaderDB.windowHeight, function(value)
            ParchmentReaderDB.windowHeight = value
            if ParchmentReaderFrame then
                ParchmentReaderFrame:SetHeight(value)
                ParchmentReader:SaveReaderPosition()
            end
        end)
    frame.widthSlider, frame.heightSlider = widthSlider, heightSlider



    Text(appearance, L["Current theme"], 0, 56)
    frame.themeCards, frame.themeSlotDropdowns = {}, {}
    local themeItems = {}
    for index, themeName in ipairs(Theme.order) do
        themeItems[#themeItems + 1] = {value = themeName, text = L[Theme.names[themeName]]}
        local card = PRUI.Button(appearance, L[Theme.names[themeName]], {width = 144, height = 76})
        card:SetPoint("TOPLEFT", appearance, "TOPLEFT", (index - 1) * 156, -76)
        card.label:ClearAllPoints()
        card.label:SetPoint("BOTTOMLEFT", card.pruiContent, "BOTTOMLEFT", 4, 8)
        card.label:SetPoint("BOTTOMRIGHT", card.pruiContent, "BOTTOMRIGHT", -4, 8)
        card.label:SetWordWrap(true)
        card.label:SetMaxLines(2)
        local swatch = card.pruiContent:CreateTexture(nil, "ARTWORK")
        swatch:SetPoint("TOPLEFT", card.pruiContent, "TOPLEFT", 9, -8)
        swatch:SetSize(126, 28)
        local palette = Theme.palettes[themeName]
        swatch:SetColorTexture(unpack(palette.bg.surface))
        local preview = card.pruiContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        preview:SetPoint("CENTER", swatch, "CENTER", 0, 0)
        preview:SetText("Aa")
        preview:SetTextColor(unpack(palette.text.primary))
        card:SetScript("OnClick", function() ParchmentReader:SetTheme(themeName) end)
        PRUI.AttachTooltip(card, L[Theme.names[themeName]])
        frame.themeCards[themeName] = card
    end
    for index, slot in ipairs({"sun", "moon"}) do
        local x = (index - 1) * 240
        local label = Text(appearance, L[slot == "sun" and "Sun button" or "Moon button"], x + 20, 168, 196)
        local icon = appearance:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("RIGHT", label, "LEFT", -4, 0)
        icon:SetTexture("Interface\\AddOns\\ParchmentReader\\Assets\\" .. (slot == "sun" and "ThemeSun" or "ThemeMoon"))
        Theme:BindIconColor(icon, Theme:Get("text", "secondary"))
        local dropdown = PRUI.Dropdown(appearance, {
            name = "ParchmentReader" .. slot .. "ThemeDropdown",
            popoverName = "ParchmentReader" .. slot .. "ThemePopover",
            width = 216, height = 28,
            popoverShadow = false, popoverPadding = 8, rowBorder = false, justifyH = "LEFT",
            items = themeItems, value = ParchmentReaderDB[slot .. "Theme"],
            onValueChanged = function(value) ParchmentReader:SetThemeSlot(slot, value) end,
        })
        dropdown:SetPoint("TOPLEFT", appearance, "TOPLEFT", x, -184)
        PRUI.AttachTooltip(dropdown, function(button) return button:GetFontString():GetText() end)
        frame.themeSlotDropdowns[slot] = dropdown
    end
    function frame:RefreshThemeControls()
        for themeName, card in pairs(self.themeCards) do
            PRUI.SetButtonSelected(card, themeName == Theme:NormalizeName(ParchmentReaderDB.themeName))
        end
        local moon, sun = Theme:NormalizeSlots(ParchmentReaderDB)
        self.themeSlotDropdowns.moon:SetValue(moon, true)
        self.themeSlotDropdowns.sun:SetValue(sun, true)
    end
    Text(appearance, L["Quick theme switching in the reader."], 0, 220, nil, "muted")
    Text(appearance, L["Reader transparency:"], 0, 260)
    local transparencyHint, customTransparencyControls, combatTransparencyCheck
    local transparencyDropdown = PRUI.Dropdown(appearance, {
        name = "ParchmentReaderTransparencyDropdown", popoverName = "ParchmentReaderTransparencyPopover",
        popoverShadow = false, popoverPadding = 8, rowBorder = false, justifyH = "LEFT",
        width = 456, height = 28, value = ParchmentReaderDB.transparencyMode or "off",
        items = {
            {value = "off", text = L["Off — standard background"]},
            {value = "always", text = L["Always — transparent background"]},
            {value = "smart", text = L["Smart — transparent until hovered"]},
            {value = "custom", text = L["Custom — adjust transparency"]},
        },
        onValueChanged = function(value)
            ParchmentReader:SetReaderTransparencyMode(value)
            frame:RefreshTransparencyHint()
        end,
    })
    transparencyDropdown:SetPoint("TOPLEFT", appearance, "TOPLEFT", 0, -276)
    frame.transparencyDropdown = transparencyDropdown
    transparencyHint = Text(appearance, "", 0, 312, nil, "muted")
    customTransparencyControls = CreateFrame("Frame", nil, appearance)
    customTransparencyControls:SetSize(456, 58)
    customTransparencyControls:SetPoint("TOPLEFT", appearance, "TOPLEFT", 0, -308)
    frame.customTransparencyControls = customTransparencyControls
    local customTransparencyLabel = Text(customTransparencyControls, "", 0, 0, 216)
    local customTransparencySlider = PRUI.Slider(customTransparencyControls, {
        name = "ParchmentReaderCustomTransparencySlider", width = 216})
    customTransparencySlider:SetPoint("TOPLEFT", customTransparencyControls, "TOPLEFT", 0, -27)
    customTransparencySlider:SetMinMaxValues(0, 100)
    customTransparencySlider:SetValueStep(1)
    customTransparencySlider:SetObeyStepOnDrag(true)
    customTransparencySlider:SetRangeLabels("0%", "100%")
    customTransparencySlider.valueText:Hide()
    PRUI.AttachTooltip(customTransparencySlider, function()
        local text = L["0% keeps the standard background; 100% hides the background. Text stays visible."]
        if Theme:IsLight() then
            text = text .. "\n\n" .. L["At high transparency, light-theme text may be harder to read. Use a dark theme or enable Transparent until hovered."]
        end
        return text
    end)
    local function RefreshCustomTransparencyLabel(value)
        customTransparencyLabel:SetText(string.format(L["Transparency: %d%%"], value))
    end
    customTransparencySlider:HookScript("OnValueChanged", function(_, value)
        value = ParchmentReader:NormalizeCustomTransparency(value)
        RefreshCustomTransparencyLabel(value)
        if not frame.refreshingCustomTransparency then
            ParchmentReader:SetReaderCustomTransparency(value)
        end
    end)
    frame.customTransparencySlider = customTransparencySlider
    local customHoverCheck = PRUI.Checkbox(customTransparencyControls, L["Transparent until hovered"], {
        name = "ParchmentReaderCustomTransparencyHoverCheck", width = 216, height = 38})
    customHoverCheck:SetPoint("TOPLEFT", customTransparencyControls, "TOPLEFT", 240, -12)
    customHoverCheck.label:SetWordWrap(true)
    customHoverCheck.label:SetMaxLines(2)
    PRUI.AttachTooltip(customHoverCheck, L["The selected theme becomes opaque while you interact with the reader."])
    customHoverCheck:HookScript("OnClick", function(self)
        ParchmentReader:SetReaderCustomTransparencyUntilHovered(PRUI.IsCheckboxChecked(self))
    end)
    frame.customTransparencyHoverCheck = customHoverCheck
    function frame:RefreshTransparencyHint()
        local mode = ParchmentReaderDB.transparencyMode
        local custom = mode == "custom"
        customTransparencyControls:SetShown(custom)
        transparencyHint:SetShown(not custom)
        self.refreshingCustomTransparency = true
        local amount = ParchmentReader:NormalizeCustomTransparency(ParchmentReaderDB.readerCustomTransparency)
        customTransparencySlider:SetValue(amount)
        RefreshCustomTransparencyLabel(amount)
        customHoverCheck:SetChecked(ParchmentReaderDB.readerCustomTransparencyUntilHovered == true)
        PRUI.RefreshCheckbox(customHoverCheck)
        self.refreshingCustomTransparency = false
        combatTransparencyCheck:ClearAllPoints()
        combatTransparencyCheck:SetPoint("TOPLEFT", appearance, "TOPLEFT", 0, custom and -372 or -352)
        local key = mode == "smart" and "The selected theme becomes opaque while you interact with the reader."
            or mode == "always" and "The reader keeps its transparent background while you interact."
            or "Standard background of the selected theme."
        transparencyHint:SetText(L[key])
    end
    combatTransparencyCheck = PRUI.Checkbox(appearance, L["Transparent background in combat"], {
        name = "ParchmentReaderCombatTransparencyCheck", width = 456})
    combatTransparencyCheck:SetPoint("TOPLEFT", appearance, "TOPLEFT", 0, -352)
    combatTransparencyCheck:SetChecked(ParchmentReaderDB.readerCombatTransparency == true)
    PRUI.RefreshCheckbox(combatTransparencyCheck)
    PRUI.AttachTooltip(combatTransparencyCheck, L["Combat forces transparency; leaving combat restores the selected mode."])
    combatTransparencyCheck:HookScript("OnClick", function(self)
        ParchmentReader:SetReaderCombatTransparencyEnabled(PRUI.IsCheckboxChecked(self))
    end)
    frame.combatTransparencyCheck = combatTransparencyCheck

    local keyboardNavigationCheck = PRUI.Checkbox(controls, L["Keyboard navigation"], {
        name = "ParchmentReaderKeyboardNavigationCheck", width = 456})
    keyboardNavigationCheck:SetPoint("TOPLEFT", controls, "TOPLEFT", 0, -56)
    keyboardNavigationCheck:SetChecked(ParchmentReaderDB.readerKeyboardNavigation ~= false)
    PRUI.RefreshCheckbox(keyboardNavigationCheck)
    keyboardNavigationCheck:HookScript("OnClick", function(self)
        ParchmentReader:SetReaderKeyboardNavigationEnabled(PRUI.IsCheckboxChecked(self))
    end)
    frame.keyboardNavigationCheck = keyboardNavigationCheck
    Text(controls, L["Activate: click the page.\nExit: click elsewhere or press Esc."], 0, 86, nil, "muted")
    Text(controls, L["Shortcuts:"], 0, 134, nil, "primary")
    frame.bindingControls = {}
    local function CreateBindingRow(action, label, y)
        local row = CreateFrame("Frame", nil, controls)
        row:SetSize(456, 34)
        row:SetPoint("TOPLEFT", controls, "TOPLEFT", 0, -y)
        local rowLabel = Text(row, label, 0, 9, 232)
        local setKeyButton = PRUI.Button(row, "", {width = 180, height = 32})
        setKeyButton:SetPoint("TOPRIGHT", row, "TOPRIGHT", -36, 0)
        setKeyButton:SetScript("OnClick", function()
            for _, input in ipairs(frame.numericInputs) do input:ClearFocus() end
            StartBindingCapture(frame, action)
        end)
        PRUI.AttachTooltip(setKeyButton, function() return setKeyButton:GetFontString():GetText() end)
        local clearKeyButton = PRUI.IconButton(row, nil, L["Clear"], {
            width = 28, height = 28, iconText = "×", fontObject = "GameFontNormal",
        })
        clearKeyButton:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -2)
        clearKeyButton:SetScript("OnClick", function()
            StopBindingCapture(frame)
            ParchmentReader:ClearAddonBinding(action)
        end)
        frame.bindingControls[action] = {
            bindingValue = setKeyButton:GetFontString(), setKeyButton = setKeyButton,
            clearKeyButton = clearKeyButton, label = rowLabel,
        }
    end
    CreateBindingRow(READER_BINDING, L["Show / Hide Reader"], 156)
    CreateBindingRow(COMPACT_BINDING, L["Toggle Compact Mode"], 192)
    CreateBindingRow(MINIMIZE_BINDING, L["Minimize / Restore Reader"], 228)
    CreateBindingRow(QUICK_NOTE_BINDING, L["Open Quick Note"], 264)
    CreateBindingRow(RESUME_QUICK_NOTE_BINDING, L["Resume Last Quick Note"], 300)
    Text(controls, L["Click a shortcut field, then press a key. Esc cancels."], 0, 340, nil, "muted")
    Text(controls, L["Also available in WoW Key Bindings; disabled in combat."], 0, 370, nil, "muted")

    Text(general, L["Interface language:"], 0, 56)
    StaticPopupDialogs["PARCHMENTREADER_RELOAD_LANGUAGE"] = {
        text = L["Language choice saved.\n\nReload the interface now?"], button1 = L["Reload UI"], button2 = L["Later"],
        OnAccept = ReloadUI, timeout = 0, whileDead = true, hideOnEscape = true,
    }
    local languageDropdown = PRUI.Dropdown(general, {
        name = "ParchmentReaderLanguageDropdown", popoverName = "ParchmentReaderLanguagePopover",
        popoverShadow = false, popoverPadding = 8, rowBorder = false, justifyH = "LEFT",
        width = 456, height = 28, value = ParchmentReaderDB.interfaceLanguage or "auto",
        items = {
            {value = "auto", text = L["Auto — WoW client language"]},
            {value = "enUS", text = L["English"]}, {value = "deDE", text = L["Deutsch"]},
            {value = "frFR", text = L["Français"]}, {value = "esES", text = L["Español"]},
            {value = "ptBR", text = L["Português (Brasil)"]}, {value = "ruRU", text = L["Русский"]},
        },
        onValueChanged = function(value)
            value = ParchmentReader:NormalizeInterfaceLanguage(value)
            if ParchmentReaderDB.interfaceLanguage == value then return end
            ParchmentReaderDB.interfaceLanguage = value
            StaticPopup_Show("PARCHMENTREADER_RELOAD_LANGUAGE")
        end,
    })
    languageDropdown:SetPoint("TOPLEFT", general, "TOPLEFT", 0, -72)
    frame.languageDropdown = languageDropdown
    Text(general, L["Applied after reload."], 0, 108, nil, "muted")
    local minimapCheck = PRUI.Checkbox(general, L["Show minimap button"], {name = "ParchmentReaderMinimapCheck", width = 456})
    minimapCheck:SetPoint("TOPLEFT", general, "TOPLEFT", 0, -144)
    minimapCheck:SetChecked(not ParchmentReaderDB.hide)
    PRUI.RefreshCheckbox(minimapCheck)
    minimapCheck:HookScript("OnClick", function(self)
        local checked = PRUI.IsCheckboxChecked(self)
        ParchmentReaderDB.hide = not checked
        if ParchmentReader.minimapBtn then ParchmentReader.minimapBtn:SetShown(checked) end
    end)
    local debugBtn = PRUI.Button(general, L["Debug Info"], {width = 184, height = 30})
    debugBtn:SetPoint("TOPLEFT", general, "TOPLEFT", 0, -184)
    debugBtn:SetScript("OnClick", function() ParchmentReader:ShowDebugInfo() end)
    Text(general, L["Maintenance"], 0, 238, nil, "primary")
    Text(general, L["Reading history"], 0, 266, 264)
    Text(general, L["Recently opened books. Your books and favorites are kept."], 0, 286, 264, "muted")
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
    frame:RegisterEvent("UPDATE_BINDINGS")
    frame:SetScript("OnEvent", function(settingsFrame, event)
        if event == "UPDATE_BINDINGS" then
            ParchmentReader:RefreshAddonBindingControls()
        elseif event == "PLAYER_REGEN_DISABLED" and settingsFrame.capturingBindingAction then
            StopBindingCapture(settingsFrame)
            ParchmentReader:PrintMessage(
                "Key capture cancelled because combat started.")
        end
    end)
    frame:HookScript("OnShow", function(settingsFrame)
        StopBindingCapture(settingsFrame)
        ParchmentReader:RefreshAddonBindingControls()
        ParchmentReader:SyncWindowSizeControls()
        settingsFrame:RefreshThemeControls()
        settingsFrame:RefreshFontSample()
        settingsFrame:RefreshTransparencyHint()
    end)
    frame:HookScript("OnHide", function(settingsFrame)
        for _, input in ipairs(settingsFrame.numericInputs) do input:ClearFocus() end
        StopBindingCapture(settingsFrame)
    end)
    StopBindingCapture(frame)
    self:RefreshAddonBindingControls()

    StaticPopupDialogs["PARCHMENTREADER_RESET"] = {
        text = L["Reset all settings to defaults?"],
        button1 = L["Reset to Defaults"],
        button2 = L["Cancel"],
        OnAccept = function()
            if InCombatLockdown() then
                ParchmentReader:PrintMessage("Settings cannot be reset in combat.")
                return
            end


            local resetFromCompact = ParchmentReaderDB.sidebarCollapsed == true
            ParchmentReaderDB.windowWidth = metrics.defaultWidth
            ParchmentReaderDB.windowHeight = metrics.defaultHeight
            ParchmentReaderDB.normalWindowWidth = metrics.defaultWidth
            ParchmentReaderDB.normalWindowHeight = metrics.defaultHeight
            ParchmentReaderDB.windowX = 0
            ParchmentReaderDB.windowY = 0
            ParchmentReaderDB.fontSize = 14
            ParchmentReaderDB.fontName = "ChatFontNormal"
            ParchmentReaderDB.hide = false
            ParchmentReaderDB.minimapAngle = 315
            ParchmentReaderDB.transparencyMode = "off"
            ParchmentReaderDB.readerCustomTransparency = 50
            ParchmentReaderDB.readerCustomTransparencyUntilHovered = false
            ParchmentReaderDB.readerCombatTransparency = false
            ParchmentReaderDB.readerMinimized = false
            ParchmentReader.readerMinimized = false
            ParchmentReaderDB.readerPinned = false
            ParchmentReaderDB.readerKeyboardNavigation = true
            local reloadForLanguage = ParchmentReader.locale
                ~= ParchmentReader:ResolveInterfaceLocale("auto")
            ParchmentReaderDB.interfaceLanguage = "auto"
            ParchmentReader:ResetThemes()
            ParchmentReader:HideFloatingLauncher()
            ParchmentReader:ResetFloatingLauncherSettings()
            ParchmentReader:RefreshReaderPinState()
            ParchmentReader:RefreshEscapeCloseRegistration()
            ParchmentReader:ClearAddonBinding(READER_BINDING, true)
            ParchmentReader:ClearAddonBinding(COMPACT_BINDING, true)
            ParchmentReader:ClearAddonBinding(MINIMIZE_BINDING, true)
            ParchmentReader:ClearAddonBinding(QUICK_NOTE_BINDING, true)
            ParchmentReader:ClearAddonBinding(RESUME_QUICK_NOTE_BINDING, true)


            widthSlider:SetValue(metrics.defaultWidth)
            heightSlider:SetValue(metrics.defaultHeight)
            fontSizeSlider:SetValue(14)
            fontDropdown:SetValue("ChatFontNormal", true)
            transparencyDropdown:SetValue("off", true)
            combatTransparencyCheck:SetChecked(false)
            PRUI.RefreshCheckbox(combatTransparencyCheck)
            minimapCheck:SetChecked(true)
            PRUI.RefreshCheckbox(minimapCheck)
            keyboardNavigationCheck:SetChecked(true)
            PRUI.RefreshCheckbox(keyboardNavigationCheck)
            languageDropdown:SetValue("auto", true)
            frame:RefreshThemeControls()
            frame:RefreshFontSample()
            frame:RefreshTransparencyHint()


            if ParchmentReaderFrame then
                if resetFromCompact then
                    ParchmentReader:ApplySidebarState(false)
                else
                    ParchmentReader:SyncReadingPosition()
                    ParchmentReader:StopReaderScrollAnimation()
                    ParchmentReader:UpdateReaderResizeBounds(
                        false, metrics.defaultWidth, metrics.defaultHeight)
                end
                ParchmentReaderDB.windowX = 0
                ParchmentReaderDB.windowY = 0
                ParchmentReader:ApplyReaderPosition()
            end
            ParchmentReaderDB.sidebarCollapsed = false



            ParchmentReaderDB.compactWindowWidth = nil
            ParchmentReaderDB.compactWindowHeight = nil

            if ParchmentReader.minimapBtn then
                ParchmentReader.minimapBtn:Show()
                ParchmentReader:UpdateMinimapButtonPosition()
            end

            ParchmentReader:UpdateFont()
            ParchmentReader:SetReaderTransparencyMode("off")
            ParchmentReader:SetReaderCombatTransparencyEnabled(false)
            ParchmentReader:SetReaderKeyboardNavigationEnabled(true)

            if reloadForLanguage then
                StaticPopup_Show("PARCHMENTREADER_RELOAD_LANGUAGE")
            end

        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    local clearHistoryButton = PRUI.Button(general, L["Clear History"], {width = 176, height = 30})
    clearHistoryButton:SetPoint("TOPRIGHT", general, "TOPRIGHT", 0, -266)
    clearHistoryButton:SetScript("OnClick", function()
        ParchmentReader:ConfirmClearReadingHistory()
    end)
    Text(general, L["Default settings"], 0, 340, 264)
    Text(general, L["Appearance, controls, and window positions."], 0, 360, 264, "muted")
    local resetButton = PRUI.Button(general, L["Reset to Defaults"], {width = 176, height = 30})
    resetButton:SetPoint("TOPRIGHT", general, "TOPRIGHT", 0, -340)
    resetButton:SetScript("OnClick", function() StaticPopup_Show("PARCHMENTREADER_RESET") end)
    Text(footer, L["Changes are saved immediately."], 16, 15, 456, "muted")
    local closeButton = PRUI.Button(footer, L["Close"], {width = 104, height = 28})
    closeButton:SetPoint("RIGHT", footer, "RIGHT", -12, 0)
    closeButton:SetScript("OnClick", function() frame:Hide() end)
    frame:RefreshThemeControls()
    frame:RefreshFontSample()
    frame:RefreshTransparencyHint()
    frame:SelectSection("reading")
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
