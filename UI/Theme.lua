


local Theme = {
    palettes = {
        AzerothGlass = {
            bg = {
                base = {0.08, 0.08, 0.10, 0.85},
                surface = {0.11, 0.10, 0.09, 0.93},
                sidebar = {0.06, 0.06, 0.08, 0.85},
                control = {0.09, 0.09, 0.11, 0.78},
                track = {0.03, 0.03, 0.04, 0.80},
                popover = {0.045, 0.042, 0.055, 0.99},
                popoverRow = {0.075, 0.070, 0.085, 0.98},
                popoverAction = {0.14, 0.11, 0.055, 0.98},
            },
            border = {
                subtle = {1, 1, 1, 0.08},
                elevated = {0.82, 0.68, 0.38, 0.52},
            },
            accent = {
                gold = {0.82, 0.68, 0.38, 1},
                goldDim = {0.82, 0.68, 0.38, 0.35},
            },
            text = {
                primary = {0.92, 0.89, 0.82, 1},
                secondary = {0.75, 0.73, 0.68, 1},
                muted = {0.55, 0.53, 0.48, 1},
            },
            state = {
                clear = {0, 0, 0, 0},
                hover = {1, 1, 1, 0.06},
                active = {0.82, 0.68, 0.38, 0.12},
                danger = {0.85, 0.35, 0.30, 1},
            },
            shadow = {
                soft = {0, 0, 0, 0.24},
                strong = {0, 0, 0, 0.68},
            },
        },
    },
    metrics = {
        topbarHeight = 32,
        sidebarWidth = 200,
        collapsedSidebarWidth = 28,
        footerHeight = 28,
        contentInsetX = 16,
        contentInsetY = 12,
        shadowSize = 6,
        minWidth = 480,
        minHeight = 360,
        compactMinWidth = 320,
        compactMinHeight = 200,
        maxWidth = 1400,
        maxHeight = 900,
        defaultWidth = 760,
        defaultHeight = 520,
    },
}

Theme.paletteName = "AzerothGlass"
Theme.colors = Theme.palettes[Theme.paletteName]
ParchmentReader.Theme = Theme

function Theme:Get(group, name)
    local colors = self.colors[group]
    return colors and colors[name]
end

local function SetTextureColor(texture, color)
    texture:SetColorTexture(color[1], color[2], color[3], color[4])
end

local function SetVertexColor(texture, color)
    texture:SetVertexColor(color[1], color[2], color[3], color[4])
end

local PRUI = {}
ParchmentReader.PRUI = PRUI
local L = ParchmentReader.L
local TOOLTIP_DELAY_SECONDS = 0.5

function PRUI.SetFontStringColor(fontString, color)
    fontString:SetTextColor(color[1], color[2], color[3], color[4])
end

function PRUI.SetBorderColor(frame, color)
    local border = frame.pruiBorder
    if not border then return end
    for _, texture in pairs(border) do
        SetTextureColor(texture, color)
    end
end

function PRUI.AddBorder(frame, color)
    if frame.pruiBorder then
        PRUI.SetBorderColor(frame, color or Theme:Get("border", "subtle"))
        return frame.pruiBorder
    end

    local border = {}
    border.top = frame:CreateTexture(nil, "BORDER")
    border.top:SetPoint("TOPLEFT")
    border.top:SetPoint("TOPRIGHT")
    border.top:SetHeight(1)

    border.bottom = frame:CreateTexture(nil, "BORDER")
    border.bottom:SetPoint("BOTTOMLEFT")
    border.bottom:SetPoint("BOTTOMRIGHT")
    border.bottom:SetHeight(1)

    border.left = frame:CreateTexture(nil, "BORDER")
    border.left:SetPoint("TOPLEFT")
    border.left:SetPoint("BOTTOMLEFT")
    border.left:SetWidth(1)

    border.right = frame:CreateTexture(nil, "BORDER")
    border.right:SetPoint("TOPRIGHT")
    border.right:SetPoint("BOTTOMRIGHT")
    border.right:SetWidth(1)

    frame.pruiBorder = border
    PRUI.SetBorderColor(frame, color or Theme:Get("border", "subtle"))
    return border
end

local function AddSoftShadow(frame)
    local size = Theme.metrics.shadowSize
    local color = Theme:Get("shadow", "soft")
    local shadow = {}

    shadow.top = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    shadow.top:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -size, 0)
    shadow.top:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", size, 0)
    shadow.top:SetHeight(size)

    shadow.bottom = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    shadow.bottom:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -size, 0)
    shadow.bottom:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", size, 0)
    shadow.bottom:SetHeight(size)

    shadow.left = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    shadow.left:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, size)
    shadow.left:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, -size)
    shadow.left:SetWidth(size)

    shadow.right = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    shadow.right:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, size)
    shadow.right:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 0, -size)
    shadow.right:SetWidth(size)

    for _, texture in pairs(shadow) do
        SetTextureColor(texture, color)
    end
    frame.pruiShadow = shadow
end

function PRUI.ApplySurface(frame, options)
    options = options or {}
    if not frame.pruiBackground then
        local background = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
        background:SetAllPoints()
        frame.pruiBackground = background
    end
    SetTextureColor(frame.pruiBackground, options.color or Theme:Get("bg", "base"))
    PRUI.AddBorder(frame, options.borderColor or Theme:Get("border", "subtle"))
    if options.shadow and not frame.pruiShadow then
        AddSoftShadow(frame)
    end
    return frame
end

function PRUI.Panel(parent, options)
    options = options or {}
    local frame = CreateFrame("Frame", options.name, parent)
    return PRUI.ApplySurface(frame, options)
end

local function SetButtonContentOffset(button, pressed)
    local content = button.pruiContent
    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", button, "TOPLEFT", 0, pressed and -1 or 0)
    content:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, pressed and -1 or 0)
end

function PRUI.RefreshButton(button)
    local enabled = button:IsEnabled()
    local stateColor = Theme:Get("state", "clear")
    local borderColor = button.pruiBorderColor or Theme:Get("border", "subtle")
    local textColor = button.pruiTextColor or Theme:Get("text", "secondary")
    local emphasized = button.pruiPressed or button.pruiSelected or button.pruiHovered

    if not enabled then
        textColor = Theme:Get("text", "muted")
        if button.pruiSelected then
            stateColor = Theme:Get("state", "active")
            borderColor = Theme:Get("accent", "goldDim")
        end
    elseif button.pruiPressed or button.pruiSelected then
        stateColor = Theme:Get("state", "active")
        borderColor = Theme:Get("accent", "goldDim")
        textColor = button.pruiTextColor or Theme:Get("text", "primary")
    elseif button.pruiHovered then
        stateColor = Theme:Get("state", "hover")
        borderColor = Theme:Get("accent", "goldDim")
        textColor = button.pruiTextColor or Theme:Get("text", "primary")
    end

    SetTextureColor(button.pruiState, stateColor)
    button.pruiBackground:SetAlpha(
        emphasized and 1 or (button.pruiIdleBackgroundAlpha or 1))
    PRUI.SetBorderColor(button, borderColor)
    button.label:SetTextColor(textColor[1], textColor[2], textColor[3], textColor[4])
    if button.icon then
        SetVertexColor(button.icon, textColor)
    end
    button:SetAlpha(enabled and 1 or 0.5)
    SetButtonContentOffset(button, enabled and button.pruiPressed)
end

function PRUI.SetButtonIdleBackgroundAlpha(button, alpha)
    button.pruiIdleBackgroundAlpha = math.max(0, math.min(1, tonumber(alpha) or 1))
    PRUI.RefreshButton(button)
end

function PRUI.SetButtonSelected(button, selected)
    button.pruiSelected = selected == true
    PRUI.RefreshButton(button)
end

function PRUI.SetButtonTextColor(button, color)
    button.pruiTextColor = color
    PRUI.RefreshButton(button)
end

function PRUI.SetButtonBorderColor(button, color)
    button.pruiBorderColor = color
    PRUI.RefreshButton(button)
end

function PRUI.Button(parent, text, options)
    options = options or {}
    local button = CreateFrame("Button", options.name, parent)
    button:SetSize(options.width or 100, options.height or 24)

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    SetTextureColor(background, Theme:Get("bg", "control"))
    button.pruiBackground = background

    local stateTexture = button:CreateTexture(nil, "BACKGROUND", nil, 1)
    stateTexture:SetAllPoints()
    button.pruiState = stateTexture
    PRUI.AddBorder(button, Theme:Get("border", "subtle"))

    local content = CreateFrame("Frame", nil, button)
    content:SetAllPoints()
    button.pruiContent = content

    local label = content:CreateFontString(nil, "OVERLAY", options.fontObject or "GameFontNormalSmall")
    label:SetPoint("LEFT", content, "LEFT", 8, 0)
    label:SetPoint("RIGHT", content, "RIGHT", -8, 0)
    label:SetJustifyH(options.justifyH or "CENTER")
    label:SetWordWrap(false)
    label:SetMaxLines(1)
    label:SetText(text or "")
    button.label = label

    function button:SetText(value)
        self.label:SetText(value or "")
    end

    function button:GetFontString()
        return self.label
    end

    button:SetScript("OnEnter", function(self)
        self.pruiHovered = true
        PRUI.RefreshButton(self)
    end)
    button:SetScript("OnLeave", function(self)
        self.pruiHovered = false
        self.pruiPressed = false
        PRUI.RefreshButton(self)
    end)
    button:SetScript("OnMouseDown", function(self, mouseButton)
        if mouseButton == "LeftButton" and self:IsEnabled() then
            self.pruiPressed = true
            PRUI.RefreshButton(self)
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self.pruiPressed = false
        PRUI.RefreshButton(self)
    end)
    button:SetScript("OnEnable", PRUI.RefreshButton)
    button:SetScript("OnDisable", PRUI.RefreshButton)
    PRUI.RefreshButton(button)
    return button
end

function PRUI.IconButton(parent, icon, tooltip, options)
    options = options or {}
    options.width = options.width or 24
    options.height = options.height or 24
    local button = PRUI.Button(parent, options.iconText or "", options)

    if icon then
        button.label:Hide()
        local texture = button.pruiContent:CreateTexture(nil, "ARTWORK")
        texture:SetSize(options.iconSize or 14, options.iconSize or 14)
        texture:SetPoint("CENTER")
        texture:SetTexture(icon)
        if options.texCoord then
            texture:SetTexCoord(
                options.texCoord[1], options.texCoord[2],
                options.texCoord[3], options.texCoord[4])
        end
        button.icon = texture
        PRUI.RefreshButton(button)
    end

    if tooltip then
        PRUI.AttachTooltip(button, tooltip)
    end
    return button
end

function PRUI.AttachTooltip(frame, tooltip)
    frame:HookScript("OnEnter", function(self)
        self.pruiTooltipGeneration = (self.pruiTooltipGeneration or 0) + 1
        local generation = self.pruiTooltipGeneration
        C_Timer.After(TOOLTIP_DELAY_SECONDS, function()
            if self.pruiTooltipGeneration ~= generation
                or not self:IsShown()
                or not self:IsMouseOver()
            then
                return
            end

            local text
            if type(tooltip) == "function" then
                text = tooltip(self)
            else
                text = tooltip
            end
            if not text or text == "" then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:SetText(tostring(text))
            GameTooltip:Show()
        end)
    end)
    local function CancelTooltip(self)
        self.pruiTooltipGeneration = (self.pruiTooltipGeneration or 0) + 1
        if GameTooltip:IsOwned(self) then
            GameTooltip:Hide()
        end
    end
    frame:HookScript("OnLeave", CancelTooltip)
    frame:HookScript("OnHide", CancelTooltip)
end

function PRUI.MakeMovable(frame, handle)
    frame:SetMovable(true)
    handle:EnableMouse(true)
    handle:RegisterForDrag("LeftButton")
    handle:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    handle:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
    end)
end

function PRUI.Window(parent, options)
    options = options or {}
    local frame = PRUI.Panel(parent, {
        name = options.name,
        color = options.color or Theme:Get("bg", "base"),
        shadow = options.shadow ~= false,
    })
    frame:SetClampedToScreen(true)

    local topbar = PRUI.Panel(frame, {color = Theme:Get("bg", "sidebar")})
    topbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    topbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    topbar:SetHeight(options.topbarHeight or Theme.metrics.topbarHeight)
    frame.topbar = topbar
    PRUI.MakeMovable(frame, topbar)

    local closeButton = PRUI.IconButton(topbar, nil, L["Close"], {
        width = 24,
        height = 24,
        iconText = "×",
        fontObject = "GameFontNormal",
    })
    closeButton:SetPoint("RIGHT", topbar, "RIGHT", -4, 0)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)
    frame.closeButton = closeButton

    local title = topbar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", topbar, "LEFT", 12, 0)
    title:SetPoint("RIGHT", closeButton, "LEFT", -8, 0)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    title:SetMaxLines(1)
    title:SetText(options.title or "")
    PRUI.SetFontStringColor(title, Theme:Get("text", "primary"))
    frame.title = title

    return frame
end

local function RefreshEditBox(editBox)
    local enabled = editBox:IsEnabled()
    local textColor = enabled and Theme:Get("text", "primary") or Theme:Get("text", "muted")
    local borderColor
    if editBox.pruiInvalid then
        borderColor = Theme:Get("state", "danger")
    elseif editBox:HasFocus() then
        borderColor = Theme:Get("accent", "goldDim")
    else
        borderColor = Theme:Get("border", "subtle")
    end
    PRUI.SetFontStringColor(editBox, textColor)
    PRUI.SetBorderColor(editBox.pruiContainer, borderColor)
    editBox.pruiContainer.pruiBackground:SetAlpha(
        (editBox:HasFocus() or editBox.pruiInvalid)
            and 1
            or (editBox.pruiIdleBackgroundAlpha or 1))
    editBox.pruiContainer:SetAlpha(enabled and 1 or 0.62)
end

function PRUI.SetEditBoxIdleBackgroundAlpha(editBox, alpha)
    editBox.pruiIdleBackgroundAlpha = math.max(0, math.min(1, tonumber(alpha) or 1))
    RefreshEditBox(editBox)
end

function PRUI.SetEditBoxInvalid(editBox, invalid)
    editBox.pruiInvalid = invalid == true
    RefreshEditBox(editBox)
end

function PRUI.EditBox(parent, options)
    options = options or {}
    local container = PRUI.Panel(parent, {color = Theme:Get("bg", "control")})
    local editBox = CreateFrame("EditBox", options.name, container)
    editBox:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1)
    editBox:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -1, 1)
    editBox:SetFontObject(options.fontObject or "GameFontNormal")
    editBox:SetAutoFocus(options.autoFocus == true)
    editBox:SetMultiLine(options.multiLine == true)
    editBox:SetTextInsets(
        options.insetLeft or 8,
        options.insetRight or 8,
        options.insetTop or 5,
        options.insetBottom or 5)
    editBox.pruiContainer = container

    editBox:HookScript("OnEditFocusGained", RefreshEditBox)
    editBox:HookScript("OnEditFocusLost", RefreshEditBox)
    editBox:HookScript("OnEnable", RefreshEditBox)
    editBox:HookScript("OnDisable", RefreshEditBox)
    editBox:HookScript("OnTextChanged", function(input)
        if input.pruiInvalid then
            PRUI.SetEditBoxInvalid(input, false)
        end
    end)
    RefreshEditBox(editBox)
    return editBox, container
end

local function RefreshSlider(slider)
    local minValue, maxValue = slider:GetMinMaxValues()
    local range = maxValue - minValue
    local ratio = range > 0 and (slider:GetValue() - minValue) / range or 0
    local width = math.max(0.01, slider:GetWidth() * math.max(0, math.min(1, ratio)))
    slider.pruiFill:SetWidth(width)
    if slider.valueText then
        slider.valueText:SetText(tostring(math.floor(slider:GetValue() + 0.5)))
    end
end

function PRUI.Slider(parent, options)
    options = options or {}
    local slider = CreateFrame("Slider", options.name, parent)
    slider:SetSize(options.width or 240, options.height or 16)
    slider:SetOrientation("HORIZONTAL")

    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", slider, "LEFT", 0, 0)
    track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
    track:SetHeight(4)
    SetTextureColor(track, Theme:Get("bg", "track"))
    slider.pruiTrack = track

    local fill = slider:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("LEFT", track, "LEFT", 0, 0)
    fill:SetHeight(4)
    SetTextureColor(fill, Theme:Get("accent", "gold"))
    slider.pruiFill = fill

    slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    local thumb = slider:GetThumbTexture()
    thumb:SetSize(10, 16)
    SetTextureColor(thumb, Theme:Get("accent", "gold"))

    local lowText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lowText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -3)
    PRUI.SetFontStringColor(lowText, Theme:Get("text", "muted"))
    slider.lowText = lowText

    local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetPoint("TOP", slider, "BOTTOM", 0, -3)
    PRUI.SetFontStringColor(valueText, Theme:Get("text", "secondary"))
    slider.valueText = valueText

    local highText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    highText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -3)
    PRUI.SetFontStringColor(highText, Theme:Get("text", "muted"))
    slider.highText = highText

    function slider:SetRangeLabels(low, high)
        self.lowText:SetText(tostring(low))
        self.highText:SetText(tostring(high))
    end

    slider:HookScript("OnValueChanged", RefreshSlider)
    slider:HookScript("OnSizeChanged", RefreshSlider)
    slider:HookScript("OnShow", RefreshSlider)
    return slider
end

function PRUI.RefreshCheckbox(checkButton)
    local checked = checkButton:GetChecked()
    checkButton.pruiCheck:SetShown(checked == true)
    PRUI.SetBorderColor(
        checkButton.pruiBox,
        checked and Theme:Get("accent", "goldDim") or Theme:Get("border", "subtle"))
end

function PRUI.Checkbox(parent, text, options)
    options = options or {}
    local checkButton = CreateFrame("CheckButton", options.name, parent)
    checkButton:SetSize(options.width or 180, options.height or 22)

    local box = PRUI.Panel(checkButton, {color = Theme:Get("bg", "control")})
    box:SetSize(18, 18)
    box:SetPoint("LEFT")
    checkButton.pruiBox = box

    local check = box:CreateTexture(nil, "ARTWORK")
    check:SetPoint("TOPLEFT", box, "TOPLEFT", 4, -4)
    check:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -4, 4)
    SetTextureColor(check, Theme:Get("accent", "gold"))
    checkButton.pruiCheck = check

    local hover = box:CreateTexture(nil, "OVERLAY")
    hover:SetAllPoints()
    SetTextureColor(hover, Theme:Get("state", "hover"))
    hover:Hide()

    local label = checkButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", box, "RIGHT", 8, 0)
    label:SetPoint("RIGHT", checkButton, "RIGHT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetText(text or "")
    PRUI.SetFontStringColor(label, Theme:Get("text", "secondary"))
    checkButton.label = label

    checkButton:HookScript("OnEnter", function()
        hover:Show()
        PRUI.SetFontStringColor(label, Theme:Get("text", "primary"))
    end)
    checkButton:HookScript("OnLeave", function()
        hover:Hide()
        PRUI.SetFontStringColor(label, Theme:Get("text", "secondary"))
    end)
    checkButton:HookScript("OnClick", PRUI.RefreshCheckbox)
    checkButton:HookScript("OnShow", PRUI.RefreshCheckbox)
    PRUI.RefreshCheckbox(checkButton)
    return checkButton
end

function PRUI.Dropdown(parent, options)
    options = options or {}
    local items = options.items or {}
    local width = options.width or 200
    local height = options.height or 24
    local rowHeight = options.rowHeight or 24
    local dropdown = PRUI.Button(parent, "", {
        name = options.name,
        width = width,
        height = height,
    })

    local arrow = dropdown.pruiContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    arrow:SetPoint("RIGHT", dropdown.pruiContent, "RIGHT", -9, 1)
    arrow:SetText("v")
    PRUI.SetFontStringColor(arrow, Theme:Get("accent", "gold"))
    dropdown.pruiArrow = arrow

    local popover = PRUI.Panel(UIParent, {
        name = options.popoverName,
        color = Theme:Get("bg", "base"),
        shadow = true,
    })
    popover:SetSize(width, 10 + #items * rowHeight)
    popover:SetFrameStrata("TOOLTIP")
    popover:SetClampedToScreen(true)
    popover:EnableMouse(true)
    popover.rows = {}

    for index, item in ipairs(items) do
        local row = PRUI.Button(popover, item.text or tostring(item.value), {
            height = rowHeight,
            justifyH = "LEFT",
        })
        row:SetPoint("TOPLEFT", popover, "TOPLEFT", 5, -(5 + (index - 1) * rowHeight))
        row:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -5, -(5 + (index - 1) * rowHeight))
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", row.pruiContent, "LEFT", 20, 0)
        row.label:SetPoint("RIGHT", row.pruiContent, "RIGHT", -8, 0)
        row.label:SetJustifyH("LEFT")

        local selectedDot = row.pruiContent:CreateTexture(nil, "ARTWORK")
        selectedDot:SetSize(5, 5)
        selectedDot:SetPoint("LEFT", row.pruiContent, "LEFT", 8, 0)
        SetTextureColor(selectedDot, Theme:Get("accent", "gold"))
        row.selectedDot = selectedDot
        row.item = item

        row:SetScript("OnClick", function(button)
            dropdown:SetValue(button.item.value)
            popover:Hide()
        end)
        popover.rows[index] = row
    end

    function dropdown:RefreshRows()
        for _, row in ipairs(popover.rows) do
            local selected = row.item.value == self.value
            PRUI.SetButtonSelected(row, selected)
            row.selectedDot:SetShown(selected)
        end
    end

    function dropdown:SetValue(value, silent)
        self.value = value
        local label = tostring(value or "")
        for _, item in ipairs(items) do
            if item.value == value then
                label = item.text or label
                break
            end
        end
        self:SetText(label)
        self:RefreshRows()
        if not silent and options.onValueChanged then
            options.onValueChanged(value)
        end
    end

    function dropdown:GetValue()
        return self.value
    end

    dropdown:SetScript("OnClick", function(button)
        if popover:IsShown() then
            popover:Hide()
            return
        end
        popover:SetWidth(button:GetWidth())
        button:RefreshRows()
        popover:ClearAllPoints()
        popover:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -4)
        popover:Show()
    end)

    popover:SetScript("OnShow", function(self)
        self:RegisterEvent("GLOBAL_MOUSE_DOWN")
        PRUI.SetButtonSelected(dropdown, true)
    end)
    popover:SetScript("OnHide", function(self)
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
        PRUI.SetButtonSelected(dropdown, false)
    end)
    popover:SetScript("OnEvent", function(self, event)
        if event ~= "GLOBAL_MOUSE_DOWN" or self:IsMouseOver() or dropdown:IsMouseOver() then
            return
        end
        self:Hide()
    end)
    dropdown:HookScript("OnHide", function()
        popover:Hide()
    end)

    if options.popoverName then
        ParchmentReader:RegisterEscapeClose(options.popoverName)
    end
    dropdown.popover = popover
    dropdown:SetValue(options.value, true)
    popover:Hide()
    return dropdown
end

function PRUI.StyleScrollFrame(scrollFrame)
    local name = scrollFrame:GetName()
    local scrollBar = scrollFrame.ScrollBar
        or (name and _G[name .. "ScrollBar"])
    if not scrollBar then return end

    if scrollBar.ScrollUpButton then
        scrollBar.ScrollUpButton:SetAlpha(0)
    end
    if scrollBar.ScrollDownButton then
        scrollBar.ScrollDownButton:SetAlpha(0)
    end

    scrollBar:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    local thumb = scrollBar:GetThumbTexture()
    for index = 1, scrollBar:GetNumRegions() do
        local region = select(index, scrollBar:GetRegions())
        if region ~= thumb and region.SetAlpha then
            region:SetAlpha(0)
        end
    end
    if thumb then
        thumb:SetSize(6, 24)
        SetTextureColor(thumb, Theme:Get("accent", "goldDim"))
    end
end

local function UpdateProgressFill(progressBar)
    local progressWidth = math.max(0.01, progressBar:GetWidth())
    local ratio = progressBar.value / 100
    progressBar.fill:SetWidth(math.max(0.01, progressWidth * ratio))
    if progressBar.thumb then
        local halfThumb = (progressBar.thumb:GetWidth() or 0) / 2
        local thumbX = progressWidth * ratio
        if progressWidth > halfThumb * 2 then
            thumbX = math.max(halfThumb, math.min(progressWidth - halfThumb, thumbX))
        end
        progressBar.thumb:ClearAllPoints()
        progressBar.thumb:SetPoint("CENTER", progressBar, "LEFT", thumbX, 0)
    end
end

function PRUI.ProgressBar(parent, options)
    options = options or {}
    local progressBar = CreateFrame("Frame", options.name, parent)
    progressBar:SetSize(options.width or 140, options.height or 4)

    local track = progressBar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    SetTextureColor(track, Theme:Get("bg", "track"))
    progressBar.track = track

    local fill = progressBar:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOPLEFT")
    fill:SetPoint("BOTTOMLEFT")
    SetTextureColor(fill, Theme:Get("accent", "gold"))
    progressBar.fill = fill
    progressBar.value = 0

    function progressBar:SetValue(value)
        self.value = math.max(0, math.min(100, tonumber(value) or 0))
        UpdateProgressFill(self)
    end

    progressBar:SetScript("OnSizeChanged", UpdateProgressFill)
    progressBar:SetValue(options.value or 0)
    return progressBar
end
