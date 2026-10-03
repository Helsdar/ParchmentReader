


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
        minWidth = 460,
        minHeight = 320,
        compactMinWidth = 320,
        compactMinHeight = 200,
        maxWidth = 1400,
        maxHeight = 900,
        defaultWidth = 720,
        defaultHeight = 480,
    },
}


Theme.palettes.LightParchment = {
    bg = {
        base = {0.890, 0.859, 0.792, 1},
        surface = {0.945, 0.918, 0.859, 1},
        sidebar = {0.906, 0.871, 0.800, 1},
        control = {0.961, 0.933, 0.875, 1},
        track = {0.420, 0.388, 0.329, 0.25},
        popover = {0.949, 0.922, 0.863, 1},
        popoverRow = {0.922, 0.890, 0.824, 1},
        popoverAction = {0.878, 0.835, 0.741, 1},
    },
    border = {
        subtle = {0.420, 0.388, 0.329, 0.24},
        elevated = {0.478, 0.388, 0.259, 0.52},
    },
    accent = {
        gold = {0.478, 0.357, 0.204, 1},
        goldDim = {0.478, 0.357, 0.204, 0.30},
    },
    text = {
        primary = {0.251, 0.231, 0.200, 1},
        secondary = {0.365, 0.337, 0.290, 1},
        muted = {0.443, 0.412, 0.357, 1},
    },
    state = {
        clear = {0, 0, 0, 0},
        hover = {0.420, 0.365, 0.278, 0.08},
        active = {0.420, 0.365, 0.278, 0.16},
        danger = {0.620, 0.130, 0.090, 1},
    },
    shadow = {
        soft = {0.180, 0.165, 0.137, 0.12},
        strong = {0.120, 0.110, 0.090, 0.30},
    },
}


Theme.palettes.WarmParchment = {
    bg = {
        base = {0.741, 0.584, 0.384, 1},
        surface = {0.847, 0.686, 0.467, 1},
        sidebar = {0.780, 0.635, 0.443, 1},
        control = {0.875, 0.733, 0.529, 1},
        track = {0.365, 0.267, 0.169, 0.25},
        popover = {0.867, 0.718, 0.510, 1},
        popoverRow = {0.831, 0.675, 0.463, 1},
        popoverAction = {0.780, 0.608, 0.384, 1},
    },
    border = {subtle = {0.365, 0.267, 0.169, 0.26}, elevated = {0.384, 0.255, 0.133, 0.52}},
    accent = {gold = {0.384, 0.247, 0.125, 1}, goldDim = {0.384, 0.247, 0.125, 0.30}},
    text = {
        primary = {0.231, 0.176, 0.122, 1},
        secondary = {0.270, 0.200, 0.135, 1},
        muted = {0.357, 0.275, 0.184, 1},
    },
    state = {
        clear = {0, 0, 0, 0}, hover = {0.365, 0.255, 0.137, 0.08},
        active = {0.365, 0.255, 0.137, 0.16}, danger = {0.580, 0.110, 0.070, 1},
    },
    shadow = {soft = {0.180, 0.137, 0.090, 0.12}, strong = {0.120, 0.090, 0.055, 0.30}},
}
Theme.names = {AzerothGlass = "Azeroth Glass", LightParchment = "Light Parchment", WarmParchment = "Warm Parchment"}
Theme.order = {"AzerothGlass", "LightParchment", "WarmParchment"}

function Theme:IsLight(value)
    return (value or self.paletteName) ~= "AzerothGlass" and self.palettes[value or self.paletteName] ~= nil
end


function Theme:NormalizeSlots(db)
    local moon = type(db.moonTheme) == "string" and self.palettes[db.moonTheme] and db.moonTheme or "AzerothGlass"
    local sun = type(db.sunTheme) == "string" and self.palettes[db.sunTheme] and db.sunTheme or "LightParchment"
    if moon == sun then sun = moon == "LightParchment" and "AzerothGlass" or "LightParchment" end
    db.moonTheme, db.sunTheme = moon, sun
    return moon, sun
end

function Theme:GetToggleTarget(db, current)
    local moon, sun = self:NormalizeSlots(db)
    current = current or self.paletteName
    if current == moon then return sun, "sun" end
    if current == sun then return moon, "moon" end
    if self:IsLight(current) then return moon, "moon" end
    return sun, "sun"
end

function Theme:NormalizeName(value)
    if type(value) == "string" and self.palettes[value] then return value end
    return "AzerothGlass"
end


Theme.bindings = setmetatable({}, {__mode = "k"})
Theme.textBindings = setmetatable({}, {__mode = "k"})
Theme.textShadows = setmetatable({}, {__mode = "k"})
Theme.paperSurfaces = setmetatable({}, {__mode = "k"})
Theme.colorRoles = {}
for _, palette in pairs(Theme.palettes) do
    for group, colors in pairs(palette) do
        for name, color in pairs(colors) do
            Theme.colorRoles[color] = {group, name}
        end
    end
end




function Theme:ApplyTextShadow(region, fontObject)
    if not region.GetShadowColor or not region.GetShadowOffset
        or not region.SetShadowColor or not region.SetShadowOffset then return end
    local shadow = self.textShadows[region]
    if fontObject or not shadow then
        local source = fontObject or region
        if not source.GetShadowColor or not source.GetShadowOffset then return end
        local r, g, b, a = source:GetShadowColor()
        local x, y = source:GetShadowOffset()


        if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number"
            or type(a) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then return end
        shadow = {r, g, b, a, x, y}
        self.textShadows[region] = shadow
    end
    if self:IsLight() then
        region:SetShadowColor(shadow[1], shadow[2], shadow[3], 0)
        region:SetShadowOffset(0, 0)
    else
        region:SetShadowColor(shadow[1], shadow[2], shadow[3], shadow[4])
        region:SetShadowOffset(shadow[5], shadow[6])
    end
end


local artworkColor = {1, 1, 1, 1}
function Theme:BindIconColor(texture, color, role)
    self:BindColor(texture, "SetVertexColor", role == "artwork" and artworkColor or color)
end

function Theme:ApplyBoundColor(region, method, color, alpha)
    if method == "SetTextColor" then
        self:ApplyTextShadow(region)
    end

    region[method](region, color[1], color[2], color[3], alpha or color[4])
end




local function RefreshEditBoxInk(editBox)
    if not editBox.GetObjectType or editBox:GetObjectType() ~= "EditBox"
        or not editBox.GetTextInsets or not editBox.SetTextInsets then return end
    local left, right, top, bottom = editBox:GetTextInsets()
    if type(left) ~= "number" or type(right) ~= "number"
        or type(top) ~= "number" or type(bottom) ~= "number" then return end

    local parent = editBox.GetParent and editBox:GetParent()
    local scrollOffset
    if parent and parent.GetObjectType and parent:GetObjectType() == "ScrollFrame"
        and parent.GetVerticalScroll and parent.SetVerticalScroll then
        scrollOffset = parent:GetVerticalScroll()
    end
    local previousRefresh = editBox.pruiRefreshingThemeInk
    editBox.pruiRefreshingThemeInk = true
    editBox:SetTextInsets(left + 1, right, top, bottom)
    editBox:SetTextInsets(left, right, top, bottom)
    if type(scrollOffset) == "number" and parent:GetVerticalScroll() ~= scrollOffset then
        parent:SetVerticalScroll(scrollOffset)
    end
    editBox.pruiRefreshingThemeInk = previousRefresh
end




function Theme:ScheduleEditBoxInkRefresh()
    if self.editBoxInkRefreshPending or not C_Timer or not C_Timer.After then return end
    self.editBoxInkRefreshPending = true
    C_Timer.After(0, function()
        self.editBoxInkRefreshPending = nil
        for region, methods in pairs(self.bindings) do
            if methods.SetTextColor then RefreshEditBoxInk(region) end
        end
    end)
end

function Theme:BindColor(region, method, color, alpha)
    local roles = self.bindings[region] or {}
    self.bindings[region] = roles
    roles[method] = {color = color, alpha = alpha}
    local role = self.colorRoles[color]
    local active = role and self:Get(role[1], role[2]) or color
    self:ApplyBoundColor(region, method, active, alpha)
end

function Theme:SetText(region, template, ...)
    local binding = {template = template, args = {...}}
    binding.rendered = string.format(self:AdaptText(template), ...)
    self.textBindings[region] = binding
    region:SetText(binding.rendered)
end

function Theme:Repaint(refreshEditBoxes)
    for region, binding in pairs(self.textBindings) do
        if region:GetText() == binding.rendered then
            binding.rendered = string.format(self:AdaptText(binding.template), unpack(binding.args))
            region:SetText(binding.rendered)
        else

            self.textBindings[region] = nil
        end
    end
    for region, methods in pairs(self.bindings) do
        for method, binding in pairs(methods) do
            local role = self.colorRoles[binding.color]
            local color = role and self:Get(role[1], role[2]) or binding.color
            self:ApplyBoundColor(region, method, color, binding.alpha)
        end
    end
    self:RefreshPaperSurfaces()
    if refreshEditBoxes then self:ScheduleEditBoxInkRefresh() end
end

function Theme:RefreshPaperSurfaces()
    for frame in pairs(self.paperSurfaces) do
        ParchmentReader.PRUI.RefreshPaperSurface(frame)
    end
end

function Theme:SetPalette(value)
    local previousPalette = self.paletteName
    self.paletteName = self:NormalizeName(value)
    self.colors = self.palettes[self.paletteName]
    self:Repaint(self.paletteName ~= previousPalette)
    return self.paletteName
end

function Theme:SearchMatchColor()
    return self:IsLight() and "|cFF8A240C" or "|cFFFFD36A"
end


function Theme:AdaptText(text)
    if not self:IsLight() then return text end
    return (text:gsub("|cFFD1AD61", "|cFF83511F"))
end

function Theme:DiagnosticText(text)
    if not self:IsLight() then return text end
    local colors = {
        ["FFFFFF00"] = "83511F", ["FF00FF00"] = "245C27",
        ["FFFF9900"] = "83511F", ["FFFFAA00"] = "83511F",
        ["FF00FFFF"] = "20585E", ["FF00AAFF"] = "20585E", ["FFFF0000"] = "9E2117",
        ["FF33FF99"] = "245C27",
    }
    return (text:gsub("|c(%x%x%x%x%x%x%x%x)", function(code)
        return colors[code:upper()] and "|cFF" .. colors[code:upper()] or "|c" .. code
    end))
end

function Theme:TransparentBackgroundAlpha()


    return self:IsLight() and 0.70 or 0.18
end

Theme.paletteName = "AzerothGlass"
Theme.colors = Theme.palettes[Theme.paletteName]
ParchmentReader.Theme = Theme

function Theme:Get(group, name)
    local colors = self.colors[group]
    return colors and colors[name]
end

local function SetTextureColor(texture, color)
    Theme:BindColor(texture, "SetColorTexture", color)
end

local PRUI = {}
ParchmentReader.PRUI = PRUI
local L = ParchmentReader.L
local TOOLTIP_DELAY_SECONDS = 0.5



PRUI.ADDON_FRAME_STRATA = "HIGH"
PRUI.ADDON_DEBUG_STRATA = "HIGH"
PRUI.ADDON_FRAME_LEVELS = {
    READER = 10,
    POPOVER = 30,
    WINDOW = 50,
    MODAL = 70,
    DEBUG = 100,
}

function PRUI.SetAddonFrameLayer(frame, level, strata)
    frame:SetFrameStrata(strata or PRUI.ADDON_FRAME_STRATA)
    frame:SetFrameLevel(level or PRUI.ADDON_FRAME_LEVELS.READER)
end

function PRUI.SetFontStringColor(fontString, color)
    Theme:BindColor(fontString, "SetTextColor", color)
end

function PRUI.SetBorderColor(frame, color, alpha)
    local border = frame.pruiBorder
    if not border then return end
    for _, texture in pairs(border) do
        Theme:BindColor(texture, "SetColorTexture", color, alpha)
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


function PRUI.AddPaperEdges(frame)
    if frame.pruiPaperEdges then
        for _, edge in ipairs(frame.pruiPaperEdges) do
            edge:SetShown(Theme.paletteName == "LightParchment")
        end
        return
    end
    if Theme.paletteName ~= "LightParchment" then return end
    local edges = {}
    for _, side in ipairs({"LEFT", "RIGHT"}) do
        for step = 1, 8 do
            local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -6)
            local inset = (step - 1) * 3
            texture:SetPoint("TOP" .. side, frame, "TOP" .. side,
                side == "LEFT" and inset or -inset, 0)
            texture:SetPoint("BOTTOM" .. side, frame, "BOTTOM" .. side,
                side == "LEFT" and inset or -inset, 0)
            texture:SetWidth(3)
            texture:SetColorTexture(0.42, 0.39, 0.33, (9 - step) * 0.006)
            edges[#edges + 1] = texture
        end
    end
    frame.pruiPaperEdges = edges
end



function PRUI.RefreshPaperSurface(frame)
    local warm = Theme.paletteName == "WarmParchment"
    if warm and not frame.pruiPaperTexture then
        local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -6)
        texture:SetAllPoints()
        texture:SetTexture("Interface\\AddOns\\ParchmentReader\\Assets\\WarmParchment")
        texture:SetVertexColor(1, 1, 1, 1)
        frame.pruiPaperTexture = texture
    end
    if frame.pruiPaperTexture then
        frame.pruiPaperTexture:SetVertexColor(1, 1, 1, 1)
        frame.pruiPaperTexture:SetAlpha(0.30 * (frame.pruiPaperAlpha or 1))
        frame.pruiPaperTexture:SetShown(warm)
    end

    if frame.pruiPaperEdgesEnabled then PRUI.AddPaperEdges(frame) end
end

function PRUI.ApplyPaperSurface(frame, edges)
    frame.pruiPaperEdgesEnabled = edges == true
    Theme.paperSurfaces[frame] = true
    PRUI.RefreshPaperSurface(frame)
end

function PRUI.SetPaperSurfaceAlpha(frame, alpha)
    frame.pruiPaperAlpha = alpha
    if frame.pruiPaperTexture then frame.pruiPaperTexture:SetAlpha(0.30 * alpha) end
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
            stateColor = button.pruiSelectedStateColor
                or Theme:Get("state", "active")
            borderColor = button.pruiSelectedBorderColor
                or Theme:Get("accent", "goldDim")
            textColor = button.pruiSelectedTextColor or textColor
        end
    elseif button.pruiPressed or button.pruiSelected then
        stateColor = button.pruiSelectedStateColor
            or Theme:Get("state", "active")
        borderColor = button.pruiSelectedBorderColor
            or Theme:Get("accent", "goldDim")
        textColor = button.pruiSelectedTextColor
            or button.pruiTextColor
            or Theme:Get("text", "primary")
    elseif button.pruiHovered then
        stateColor = Theme:Get("state", "hover")
        borderColor = button.pruiHoverBorderColor
            or Theme:Get("accent", "goldDim")
        textColor = button.pruiTextColor or Theme:Get("text", "primary")
    end

    SetTextureColor(button.pruiState, stateColor)
    button.pruiBackground:SetAlpha(
        emphasized and 1 or (button.pruiIdleBackgroundAlpha or 1))
    PRUI.SetBorderColor(button, borderColor)
    Theme:BindColor(button.label, "SetTextColor", textColor)
    if button.icon then
        Theme:BindIconColor(button.icon, button.pruiIconColor or textColor, button.pruiIconRole)
    end
    if button.pruiChevron then
        local chevronColor = enabled and button.pruiChevronColor or textColor
        SetTextureColor(button.pruiChevron.left, chevronColor or textColor)
        SetTextureColor(button.pruiChevron.right, chevronColor or textColor)
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
        button.pruiIconRole = options.iconRole
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

function PRUI.MakeMovable(frame, handle, canMove)
    frame:SetMovable(true)
    handle:EnableMouse(true)
    handle:RegisterForDrag("LeftButton")
    handle:SetScript("OnDragStart", function()
        if canMove and not canMove() then return end
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

function PRUI.IsCheckboxChecked(checkButton)
    return checkButton:GetChecked() and true or false
end

function PRUI.RefreshCheckbox(checkButton)
    local checked = PRUI.IsCheckboxChecked(checkButton)
    checkButton.pruiCheck:SetShown(checked)
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

local function GetDropdownOwnerRoot(dropdown)
    local root = dropdown:GetParent() or UIParent
    local ancestor = root:GetParent()
    while ancestor and ancestor ~= UIParent do
        root = ancestor
        ancestor = ancestor:GetParent()
    end
    return root
end

local function GetDropdownPopoverLevel(dropdown)
    local level = PRUI.ADDON_FRAME_LEVELS.POPOVER
    local ancestor = dropdown
    while ancestor and ancestor ~= UIParent do
        level = math.max(level, ancestor:GetFrameLevel() or 0)
        ancestor = ancestor:GetParent()
    end
    return level + 20
end

local function SetChevronExpanded(chevron, expanded)
    local angle = math.rad(45)
    chevron.left:SetRotation(expanded and angle or -angle)
    chevron.right:SetRotation(expanded and -angle or angle)
end

local function AddButtonChevron(button, expanded)
    local chevron = CreateFrame("Frame", nil, button.pruiContent)
    chevron:SetSize(8, 6)
    chevron.left = chevron:CreateTexture(nil, "ARTWORK")
    chevron.left:SetTexture("Interface\\Buttons\\WHITE8X8")
    chevron.left:SetSize(5, 1)
    chevron.left:SetPoint("CENTER", chevron, "CENTER", -1.75, 0)
    chevron.right = chevron:CreateTexture(nil, "ARTWORK")
    chevron.right:SetTexture("Interface\\Buttons\\WHITE8X8")
    chevron.right:SetSize(5, 1)
    chevron.right:SetPoint("CENTER", chevron, "CENTER", 1.75, 0)
    SetChevronExpanded(chevron, expanded)
    button.pruiChevron = chevron
    PRUI.RefreshButton(button)
    return chevron
end

function PRUI.Dropdown(parent, options)
    options = options or {}
    local items = options.items or {}
    local width = options.width or 200
    local height = options.height or 24
    local rowHeight = options.rowHeight or 24
    local popoverWidth = options.popoverWidth or width
    local popoverPadding = options.popoverPadding or 5
    local dropdown = PRUI.Button(parent, "", {
        name = options.name,
        width = width,
        height = height,
        justifyH = options.justifyH,
    })

    dropdown.pruiChevronColor = Theme:Get("accent", "gold")
    local arrow = AddButtonChevron(dropdown, false)
    arrow:SetPoint("RIGHT", dropdown.pruiContent, "RIGHT", -9, 0)
    dropdown.pruiArrow = arrow
    if options.searchable or options.justifyH == "LEFT" then
        dropdown.label:ClearAllPoints()
        dropdown.label:SetPoint("LEFT", dropdown.pruiContent, "LEFT", 8, 0)
        dropdown.label:SetPoint("RIGHT", dropdown.pruiContent, "RIGHT", -24, 0)
        dropdown.label:SetJustifyH("LEFT")
        if options.searchable then
            PRUI.AttachTooltip(dropdown, function(button) return button:GetFontString():GetText() end)
        end
    end

    local popover = PRUI.Panel(GetDropdownOwnerRoot(dropdown), {
        name = options.popoverName,
        color = Theme:Get("bg", "base"),
        shadow = options.popoverShadow ~= false,
    })
    popover:SetSize(popoverWidth, 2 * popoverPadding + #items * rowHeight)
    PRUI.SetAddonFrameLayer(
        popover,
        GetDropdownPopoverLevel(dropdown))
    popover:SetClampedToScreen(true)
    popover:EnableMouse(true)
    popover.rows = {}

    local maxRows = options.maxRows or math.max(1, #items)
    popover.offset = 0
    popover.filteredItems = items
    local searchInput, searchSurface
    if options.searchable then
        searchInput, searchSurface = PRUI.EditBox(popover)
        searchSurface:SetPoint("TOPLEFT", popover, "TOPLEFT", 5, -5)
        searchSurface:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -5, -5)
        searchSurface:SetHeight(26)
        searchInput:SetMaxLetters(100)
        searchInput:SetScript("OnEscapePressed", function() popover:Hide() end)
        searchInput:SetAltArrowKeyMode(false)
        searchInput:SetScript("OnArrowPressed", function(_, key)
            local delta = key == "UP" and -1 or key == "DOWN" and 1 or 0
            if delta == 0 then return end
            popover.keyboardIndex = math.max(1, math.min(#popover.filteredItems,
                (popover.keyboardIndex or 1) + delta))
            local index = popover.keyboardIndex
            if index > popover.offset + maxRows then popover.offset = index - maxRows end
            if index > 1 and index < popover.offset + 2 then popover.offset = math.max(0, index - 2) end
            dropdown:RefreshRows()
        end)
        searchInput:SetScript("OnEnterPressed", function()
            local item = popover.filteredItems[popover.keyboardIndex or 0]
            if item then dropdown:SetValue(item.value); popover:Hide() end
        end)
        searchInput:HookScript("OnEditFocusGained", function() dropdown:RefreshRows() end)
        searchInput:HookScript("OnEditFocusLost", function() dropdown:RefreshRows() end)
        searchInput:HookScript("OnTextChanged", function()
            popover.offset = 0
            popover.keyboardIndex = nil
            dropdown:RefreshRows()
        end)
        popover.searchInput = searchInput
        local placeholder = searchSurface:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        placeholder:SetPoint("LEFT", searchSurface, "LEFT", 8, 0)
        placeholder:SetPoint("RIGHT", searchSurface, "RIGHT", -8, 0)
        placeholder:SetJustifyH("LEFT")
        placeholder:SetText(L["Search collections…"])
        PRUI.SetFontStringColor(placeholder, Theme:Get("text", "muted"))
        popover.searchPlaceholder = placeholder
    end

    for index = 1, maxRows do
        local row = PRUI.Button(popover, "", {height = rowHeight, justifyH = "LEFT"})
        if options.rowBorder == false then
            PRUI.SetButtonBorderColor(row, Theme:Get("state", "clear"))
            PRUI.SetButtonIdleBackgroundAlpha(row, 0)
        end
        row.label:ClearAllPoints()
        row.label:SetPoint("LEFT", row.pruiContent, "LEFT", 20, 0)
        row.label:SetPoint("RIGHT", row.pruiContent, "RIGHT", -8, 0)
        row.label:SetJustifyH("LEFT")
        local selectedDot = row.pruiContent:CreateTexture(nil, "ARTWORK")
        selectedDot:SetSize(5, 5)
        selectedDot:SetPoint("LEFT", row.pruiContent, "LEFT", 8, 0)
        SetTextureColor(selectedDot, Theme:Get("accent", "gold"))
        row.selectedDot = selectedDot
        row:SetScript("OnClick", function(button)
            if not button.item then return end
            dropdown:SetValue(button.item.value)
            popover:Hide()
        end)
        if options.searchable then
            PRUI.AttachTooltip(row, function(button)
                return button.item and button.item.text
            end)
        end
        popover.rows[index] = row
    end

    if options.maxRows then
        popover:EnableMouseWheel(true)
        local function Scroll(delta)
            popover.offset = math.max(0, math.min(popover.offset + delta,
                math.max(0, #popover.filteredItems - maxRows)))
            dropdown:RefreshRows()
        end
        popover:SetScript("OnMouseWheel", function(_, delta) Scroll(-delta) end)
        local previous = PRUI.Button(popover, "", {width = 26, height = 22})
        AddButtonChevron(previous, true):SetPoint("CENTER", previous.pruiContent, "CENTER", 0, 0)
        previous:SetPoint("BOTTOMLEFT", popover, "BOTTOMLEFT", 5, 5)
        previous:SetScript("OnClick", function()
            Scroll(-(maxRows - ((popover.filteredItems[1] and popover.filteredItems[1].pinned) and 1 or 0)))
        end)
        local following = PRUI.Button(popover, "", {width = 26, height = 22})
        AddButtonChevron(following, false):SetPoint("CENTER", following.pruiContent, "CENTER", 0, 0)
        following:SetPoint("BOTTOMRIGHT", popover, "BOTTOMRIGHT", -5, 5)
        following:SetScript("OnClick", function()
            Scroll(maxRows - ((popover.filteredItems[1] and popover.filteredItems[1].pinned) and 1 or 0))
        end)
        local range = popover:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        range:SetPoint("BOTTOM", popover, "BOTTOM", 0, 10)
        PRUI.SetFontStringColor(range, Theme:Get("text", "muted"))
        popover.previousButton, popover.nextButton, popover.rangeLabel = previous, following, range
        local empty = popover:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        empty:SetPoint("LEFT", popover, "LEFT", 12, 0)
        empty:SetPoint("RIGHT", popover, "RIGHT", -12, 0)
        empty:SetText(L["No collections found."])
        PRUI.SetFontStringColor(empty, Theme:Get("text", "muted"))
        popover.emptyLabel = empty
    end

    function dropdown:RefreshRows()
        local searchable = searchInput and #items > (options.searchThreshold or 8)
        local query = searchable and (searchInput:GetText() or "") or ""
        query = query:match("^%s*(.-)%s*$")

        local function normalize(text)
            if ParchmentReader.NormalizeSearchText then
                return ParchmentReader:NormalizeSearchText(text)
            end
            return string.lower(text)
        end
        query = normalize(query)
        local filtered = {}
        for _, item in ipairs(items) do
            if item.pinned or query == "" or normalize(item.text or tostring(item.value)):find(query, 1, true) then
                filtered[#filtered + 1] = item
            end
        end
        popover.filteredItems = filtered
        if searchInput and not popover.keyboardIndex then
            popover.keyboardIndex = query ~= "" and filtered[1] and filtered[1].pinned
                and (#filtered > 1 and 2 or 0) or (#filtered > 0 and 1 or 0)
        end
        popover.offset = math.max(0, math.min(popover.offset, math.max(0, #filtered - maxRows)))
        local visibleRows = math.min(maxRows, #filtered)
        local pinnedFirst = filtered[1] and filtered[1].pinned
        local top = searchable and 36 or popoverPadding
        local scrolling = #filtered > maxRows
        popover:SetHeight(top + math.max(1, visibleRows) * rowHeight + (scrolling and 32 or popoverPadding))
        if searchSurface then
            searchSurface:SetShown(searchable)
            popover.searchPlaceholder:SetShown(query == "")
        end
        for index, row in ipairs(popover.rows) do
            local item = filtered[index + ((pinnedFirst and index == 1) and 0 or popover.offset)]
            if row.item ~= item then
                row.pruiTooltipGeneration = (row.pruiTooltipGeneration or 0) + 1
                if GameTooltip:IsOwned(row) then GameTooltip:Hide() end
            end
            row.item = item
            row:SetShown(item ~= nil)
            if item then
                if options.maxRows or not row.pruiDropdownAnchored then
                    row:ClearAllPoints()
                    row:SetPoint("TOPLEFT", popover, "TOPLEFT", popoverPadding, -(top + (index - 1) * rowHeight))
                    row:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -popoverPadding, -(top + (index - 1) * rowHeight))
                    row.pruiDropdownAnchored = true
                end
                row:SetText(item.text or tostring(item.value))
                local selected = item.value == self.value
                PRUI.SetButtonSelected(row, selected or (searchInput and searchInput:HasFocus()
                    and item == filtered[popover.keyboardIndex]))
                row.selectedDot:SetShown(selected)
            end
        end
        if popover.previousButton then
            popover.previousButton:SetShown(scrolling)
            popover.nextButton:SetShown(scrolling)
            popover.rangeLabel:SetShown(scrolling)
            popover.previousButton:SetEnabled(popover.offset > 0)
            popover.nextButton:SetEnabled(popover.offset + visibleRows < #filtered)
            popover.rangeLabel:SetText(string.format("%d–%d / %d", popover.offset + 1,
                popover.offset + visibleRows - (pinnedFirst and 1 or 0), #filtered - (pinnedFirst and 1 or 0)))
            local noMatches = #filtered == 0 or (query ~= "" and #filtered == 1 and pinnedFirst)
            popover.emptyLabel:ClearAllPoints()
            popover.emptyLabel:SetPoint("TOPLEFT", popover, "TOPLEFT", 12, -(top + visibleRows * rowHeight + 8))
            popover.emptyLabel:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -12, -(top + visibleRows * rowHeight + 8))
            popover.emptyLabel:SetShown(noMatches)
            if noMatches then popover:SetHeight(top + visibleRows * rowHeight + 36) end
        end
    end

    function dropdown:SetItems(newItems)
        items = newItems or {}
        popover.offset = 0
        popover.keyboardIndex = nil
        self:SetValue(self.value, true)
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
        popover:SetWidth(options.popoverWidth or button:GetWidth())
        if options.getItems then button:SetItems(options.getItems()) end
        if searchInput then searchInput:SetText("") end
        popover.offset = 0
        for index, item in ipairs(items) do
            if item.value == button.value then
                popover.offset = math.max(0, index - maxRows)
                popover.keyboardIndex = index
                break
            end
        end
        button:RefreshRows()
        PRUI.SetAddonFrameLayer(
            popover,
            GetDropdownPopoverLevel(button))
        popover:ClearAllPoints()
        popover:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -4)
        popover:Show()
    end)

    popover:SetScript("OnShow", function(self)
        PRUI.SetAddonFrameLayer(
            self,
            GetDropdownPopoverLevel(dropdown))
        C_Timer.After(0, function()
            if self:IsShown() then
                PRUI.SetAddonFrameLayer(
                    self,
                    GetDropdownPopoverLevel(dropdown))
            end
        end)
        self:RegisterEvent("GLOBAL_MOUSE_DOWN")
        SetChevronExpanded(arrow, true)
        PRUI.SetButtonSelected(dropdown, true)
    end)
    popover:SetScript("OnHide", function(self)
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
        if searchInput then searchInput:ClearFocus() end
        SetChevronExpanded(arrow, false)
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



function PRUI.ThemeDropdown(parent, options)
    options = options or {}
    local items = {}
    for _, name in ipairs(Theme.order) do items[#items + 1] = {value = name, text = L[Theme.names[name]]} end
    local dropdown = PRUI.Dropdown(parent, {
        name = "ParchmentReaderThemeDropdown", popoverName = "ParchmentReaderThemePopover",
        width = options.width or 260, popoverWidth = 400, rowHeight = 30,
        value = Theme:NormalizeName(ParchmentReaderDB.themeName), items = items,
        onValueChanged = function(value) ParchmentReader:SetTheme(value) end,
    })
    local popover = dropdown.popover
    for index, row in ipairs(popover.rows) do
        local themeName = row.item.value
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", popover, "TOPLEFT", 5, -(5 + (index - 1) * 30))
        row:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -77, -(5 + (index - 1) * 30))
        row.slotButtons = {}
        for slotIndex, slot in ipairs({"moon", "sun"}) do
            local icon = slot == "moon" and "ThemeMoon" or "ThemeSun"
            local button = PRUI.IconButton(popover,
                "Interface\\AddOns\\ParchmentReader\\Assets\\" .. icon,
                function() return string.format(L[slot == "moon" and "Assign %s to moon slot" or "Assign %s to sun slot"], L[Theme.names[themeName]]) end,
                {width = 30, height = 30, iconSize = 16})
            button:SetPoint("TOPRIGHT", popover, "TOPRIGHT", slotIndex == 1 and -41 or -5,
                -(5 + (index - 1) * 30))
            button:SetScript("OnClick", function()
                ParchmentReader:SetThemeSlot(slot, themeName)
                dropdown:RefreshRows()
            end)
            row.slotButtons[slot] = button
        end
    end
    local refresh = dropdown.RefreshRows
    function dropdown:RefreshRows()
        refresh(self)
        local moon, sun = Theme:NormalizeSlots(ParchmentReaderDB)
        for _, row in ipairs(popover.rows) do
            PRUI.SetButtonSelected(row.slotButtons.moon, row.item.value == moon)
            PRUI.SetButtonSelected(row.slotButtons.sun, row.item.value == sun)
        end
    end
    dropdown:RefreshRows()
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


function ParchmentReader:RefreshThemeButton(frame)
    frame = frame or ParchmentReaderFrame
    if not frame or not frame.themeButton then return end
    local _, slot = Theme:GetToggleTarget(ParchmentReaderDB)
    local suffix = slot == "moon" and "ThemeMoon" or "ThemeSun"
    frame.themeButton.icon:SetTexture("Interface\\AddOns\\ParchmentReader\\Assets\\" .. suffix)
end

function ParchmentReader:SetTheme(value)
    value = Theme:NormalizeName(value)
    ParchmentReaderDB.themeName = value
    Theme:SetPalette(value)
    local frame = ParchmentReaderFrame
    if frame then
        if frame.contentSurface then PRUI.AddPaperEdges(frame.contentSurface) end

        frame.readerBackgroundTransparent = nil
        self:RefreshReaderTransparency()
        self:RefreshThemeButton(frame)
        if self.readerLayoutMetrics and frame.contentScroll then
            self.readerLayoutMetrics.visibleChunkStart = nil
            self:RenderVisibleReaderChunks(frame.contentScroll:GetVerticalScroll())
        end
    end
    local settings = ParchmentReaderSettingsFrame
    if settings and settings.RefreshThemeControls then
        settings:RefreshThemeControls()
    elseif settings and settings.themeDropdown then
        settings.themeDropdown:SetValue(value, true)
    end
    if ParchmentReaderDebugFrame then self:UpdateDebugInfo() end
end

function ParchmentReader:SetThemeSlot(slot, value)
    if (slot ~= "moon" and slot ~= "sun") or not Theme.palettes[value] then return false end
    Theme:NormalizeSlots(ParchmentReaderDB)
    local key, opposite = slot .. "Theme", slot == "moon" and "sunTheme" or "moonTheme"
    if ParchmentReaderDB[opposite] == value then
        ParchmentReaderDB[opposite] = ParchmentReaderDB[key]
    end
    ParchmentReaderDB[key] = value
    self:RefreshThemeButton()
    local settings = ParchmentReaderSettingsFrame
    if settings and settings.RefreshThemeControls then
        settings:RefreshThemeControls()
    elseif settings and settings.themeDropdown then
        settings.themeDropdown:RefreshRows()
    end
    return true
end

function ParchmentReader:ToggleTheme()
    self:SetTheme(Theme:GetToggleTarget(ParchmentReaderDB))
end

function ParchmentReader:ResetThemes()
    ParchmentReaderDB.moonTheme, ParchmentReaderDB.sunTheme = "AzerothGlass", "LightParchment"
    self:SetTheme("AzerothGlass")
end
