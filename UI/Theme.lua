


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

Theme.palettes.HallowsEnd = {
    bg = {
        base = {23/255, 28/255, 25/255, 1},
        surface = {29/255, 36/255, 31/255, 1},
        sidebar = {20/255, 26/255, 22/255, 1},
        control = {40/255, 48/255, 39/255, 1},
        track = {12/255, 17/255, 13/255, 0.80},
        popover = {23/255, 28/255, 25/255, 0.99},
        popoverRow = {29/255, 36/255, 31/255, 0.98},
        popoverAction = {40/255, 48/255, 39/255, 0.98},
    },
    border = {subtle = {180/255, 120/255, 65/255, 0.45}, elevated = {217/255, 154/255, 87/255, 0.60}},
    accent = {gold = {217/255, 154/255, 87/255, 1}, goldDim = {217/255, 154/255, 87/255, 0.35}},
    text = {
        primary = {232/255, 221/255, 198/255, 1},
        secondary = {194/255, 187/255, 167/255, 1},
        muted = {149/255, 154/255, 133/255, 1},
    },
    state = {
        clear = {0, 0, 0, 0}, hover = {217/255, 154/255, 87/255, 0.08},
        active = {217/255, 154/255, 87/255, 0.18}, danger = {0.85, 0.35, 0.30, 1},
    },
    shadow = {soft = {0, 0, 0, 0.24}, strong = {0, 0, 0, 0.68}},
}


Theme.palettes.Classic = {
    bg = {
        base = {0.13, 0.085, 0.055, 1}, surface = {0.94, 0.88, 0.75, 1},
        sidebar = {0.10, 0.065, 0.045, 1}, control = {0.12, 0.095, 0.075, 1},
        track = {0.035, 0.025, 0.02, 0.92}, popover = {0.105, 0.075, 0.055, 1},
        popoverRow = {0.13, 0.085, 0.065, 1}, popoverAction = {0.20, 0.085, 0.075, 1},
    },
    border = {subtle = {0.53, 0.44, 0.29, 0.60}, elevated = {0.70, 0.59, 0.37, 0.90}},
    accent = {gold = {0.87, 0.72, 0.42, 1}, goldDim = {0.76, 0.61, 0.35, 0.58}},
    text = {
        primary = {0.96, 0.90, 0.76, 1}, secondary = {0.85, 0.79, 0.67, 1},
        muted = {0.68, 0.63, 0.53, 1},
    },
    paperText = {
        primary = {0.16, 0.115, 0.075, 1}, secondary = {0.29, 0.23, 0.17, 1},
        muted = {0.38, 0.30, 0.22, 1},
    },
    paperAccent = {gold = {0.43, 0.27, 0.12, 1}, goldDim = {0.43, 0.27, 0.12, 0.50}},
    state = {
        clear = {0, 0, 0, 0}, hover = {0.83, 0.68, 0.42, 0.10},
        active = {0.36, 0.085, 0.075, 0.82}, danger = {0.94, 0.42, 0.33, 1},
    },
    shadow = {soft = {0, 0, 0, 0.26}, strong = {0, 0, 0, 0.72}},
}
Theme.palettes.QuestJournal = {
    bg = {
        base = {0.13, 0.14, 0.15, 1}, surface = {0.88, 0.77, 0.56, 1},
        sidebar = {0.07, 0.08, 0.085, 1}, control = {0.10, 0.11, 0.12, 1},
        track = {0.025, 0.03, 0.035, 1}, popover = {0.075, 0.085, 0.095, 1},
        popoverRow = {0.10, 0.11, 0.12, 1}, popoverAction = {0.15, 0.14, 0.10, 1},
    },
    border = {subtle = {0.46, 0.48, 0.47, 0.85}, elevated = {0.70, 0.71, 0.66, 1}},
    accent = {gold = {1, 0.82, 0.25, 1}, goldDim = {0.89, 0.65, 0.16, 0.65}},
    text = {primary = {0.95, 0.91, 0.79, 1}, secondary = {0.84, 0.82, 0.74, 1}, muted = {0.62, 0.63, 0.60, 1}},
    paperText = {primary = {0.055, 0.040, 0.025, 1}, secondary = {0.065, 0.050, 0.035, 1}, muted = {0.075, 0.060, 0.040, 1}},
    paperAccent = {gold = {0.080, 0.050, 0.020, 1}, goldDim = {0.080, 0.050, 0.020, 0.55}},
    state = {
        clear = {0, 0, 0, 0}, hover = {1, 0.82, 0.25, 0.10},
        active = {0.70, 0.48, 0.08, 0.22}, danger = {1, 0.72, 0.60, 1},
    },
    shadow = {soft = {0, 0, 0, 0.30}, strong = {0, 0, 0, 0.75}},
}


Theme.palettes.Forever = {
    bg = {
        base = {0.15, 0.095, 0.055, 1}, surface = {0.88, 0.77, 0.56, 1},
        sidebar = {0.095, 0.060, 0.035, 1}, control = {0.13, 0.085, 0.045, 1},
        track = {0.035, 0.022, 0.012, 1}, popover = {0.105, 0.068, 0.040, 1},
        popoverRow = {0.14, 0.09, 0.05, 1}, popoverAction = {0.25, 0.055, 0.035, 1},
    },
    border = {subtle = {0.57, 0.40, 0.19, 0.85}, elevated = {0.79, 0.61, 0.30, 1}},
    accent = {gold = {1, 0.82, 0.20, 1}, goldDim = {0.82, 0.61, 0.25, 0.70}},
    text = {primary = {0.96, 0.91, 0.79, 1}, secondary = {0.86, 0.80, 0.68, 1}, muted = {0.67, 0.58, 0.44, 1}},
    paperText = {primary = {0.055, 0.040, 0.025, 1}, secondary = {0.065, 0.050, 0.035, 1}, muted = {0.075, 0.060, 0.040, 1}},
    paperAccent = {gold = {0.080, 0.050, 0.020, 1}, goldDim = {0.080, 0.050, 0.020, 0.55}},
    state = {
        clear = {0, 0, 0, 0}, hover = {1, 0.80, 0.30, 0.12},
        active = {0.80, 0.55, 0.16, 0.25}, danger = {1, 0.64, 0.48, 1},
    },
    shadow = {soft = {0, 0, 0, 0.30}, strong = {0, 0, 0, 0.75}},
}


Theme.names = {AzerothGlass = "Azeroth Glass", LightParchment = "Light Parchment", WarmParchment = "Warm Parchment", Classic = "Leatherbound", QuestJournal = "Gray UI", Forever = "Forever", HallowsEnd = "Hallow's End"}
Theme.order = {"AzerothGlass", "LightParchment", "WarmParchment", "Classic", "QuestJournal", "Forever"}
Theme.skins = {
    Classic = {chrome = "ClassicLeatherBC1", paper = "ClassicPaperBC1", trim = "ClassicTrim",
        chromeOpacity = 0.72, paperOpacity = 0.96, cornerSize = 14,
        rim = {{0.17, 0.16, 0.14, 1}, {0.59, 0.53, 0.40, 1}, {0.25, 0.19, 0.11, 1}}},
    Forever = {chrome = "ClassicLeatherBC1", paper = "ClassicPaperBC1", nativeButtons = true,
        actionOpacity = 0.98, actionColor = {0.30, 0.025, 0.015, 1}, actionInk = {1, 1, 1, 1},
        titleInk = {1, 0.82, 0.20, 1}, chromeOpacity = 0.96, paperOpacity = 0.96,
        hideCornerArtwork = true,
        rim = {{0.16, 0.095, 0.035, 1}, {0.79, 0.61, 0.30, 1}, {0.34, 0.22, 0.09, 1}}},
    QuestJournal = {paper = "ClassicPaperBC1", nativeButtons = true, actionOpacity = 0.96,
        actionColor = {0.20, 0.022, 0.016, 1}, chromeColor = {0.07, 0.08, 0.085, 1},
        chromeOpacity = 0.96, fallbackChromeOpacity = 0, paperOpacity = 0.96, hideCornerArtwork = true,
        rim = {{0.08, 0.09, 0.10, 1}, {0.64, 0.66, 0.63, 1}, {0.26, 0.28, 0.29, 1}}},
}
local function NativeGray(red, green, blue)
    return {path = "Interface\\Buttons\\GreyscaleRamp64", coords = {0.5 / 64, 63.5 / 64, 0.5 / 64, 63.5 / 64},
        tint = {red, green, blue, 1}, sourceAlpha = 1}
end
Theme.skins.QuestJournal.nativeSurfaces = {
    paper = {atlas = "QuestBG-Parchment", relativeCoords = {0.08, 0.92, 0.08, 0.92}, sourceAlpha = 1},
    chrome = NativeGray(0.20, 0.21, 0.22),
    sidebar = NativeGray(0.14, 0.15, 0.16),
    control = NativeGray(0.12, 0.13, 0.14),
    row = NativeGray(0.10, 0.11, 0.12),
    popover = NativeGray(0.14, 0.15, 0.16),
    popoverRow = NativeGray(0.12, 0.13, 0.14),
    popoverAction = NativeGray(0.16, 0.17, 0.18),
}



Theme.skins.Forever.nativeSurfaces = {
    paper = Theme.skins.QuestJournal.nativeSurfaces.paper,
    chrome = {path = "Interface\\DialogFrame\\UI-DialogBox-Background", wrap = "REPEAT", tileSize = 128, sourceAlpha = 1},
}
Theme.skins.Forever.nativeButtonAtlas = "128-RedButton"
Theme.skins.Forever.nativeControlAtlases = {
    "common-search-border-left", "common-search-border-middle", "common-search-border-right",
}
Theme.skins.Forever.nativeFrame = {
    TopLeftCorner = {atlas = "UI-Frame-DiamondMetal-CornerTopLeft"},
    TopRightCorner = {atlas = "UI-Frame-DiamondMetal-CornerTopRight"},
    BottomLeftCorner = {atlas = "UI-Frame-DiamondMetal-CornerBottomLeft"},
    BottomRightCorner = {atlas = "UI-Frame-DiamondMetal-CornerBottomRight"},
    TopEdge = {atlas = "_UI-Frame-DiamondMetal-EdgeTop"},
    BottomEdge = {atlas = "_UI-Frame-DiamondMetal-EdgeBottom"},
    LeftEdge = {atlas = "!UI-Frame-DiamondMetal-EdgeLeft"},
    RightEdge = {atlas = "!UI-Frame-DiamondMetal-EdgeRight"},
}
Theme.classicButtonThemes = {QuestJournal = true, Forever = true}

function Theme:UsesClassicButtons(value)
    return self.classicButtonThemes[value == nil and self.paletteName or value] == true
end

function Theme:GetSkin(value)
    return self.skins[value == nil and self.paletteName or value]
end

function Theme:IsHybrid(value)
    return self:GetSkin(value) ~= nil
end

function Theme:UsesPaperInk(region)
    return self:IsLight() or (self:IsHybrid() and self:IsPaperRegion(region))
end

function Theme:IsActionButton(button)
    return button.pruiButtonSkinRole == "action" and button.pruiIdleBackgroundAlpha ~= 0
end




Theme.currentHoliday = {enabled = false, themeName = "HallowsEnd", seasonId = "hallows-end-2026"}

function Theme:GetAvailableHoliday()
    local event = self.currentHoliday
    if type(event) == "table" and event.enabled == true and event.themeName == "HallowsEnd"
        and type(event.seasonId) == "string" and event.seasonId ~= "" then return event end
end

function Theme:IsLight(value)
    local name = value or self.paletteName
    return name == "LightParchment" or name == "WarmParchment"
end

function Theme:IsOrdinary(value)
    return value == "AzerothGlass" or value == "LightParchment" or value == "WarmParchment"
        or (type(value) == "string" and self.skins[value] ~= nil)
end

function Theme:NormalizeSeasonalState(db)

    db.holidayAppearanceEnabled = db.holidayAppearanceEnabled ~= false
    db.themeName = self:NormalizeName(db.themeName)
    if db.hallowsEndReturnTheme == "WoWClassic" then db.hallowsEndReturnTheme = "QuestJournal" end
    if db.themeName == "HallowsEnd" then
        local event = self:GetAvailableHoliday()
        if not self:IsOrdinary(db.hallowsEndReturnTheme) then db.hallowsEndReturnTheme = "AzerothGlass" end
        if not db.holidayAppearanceEnabled or not event
            or (db.hallowsEndActiveSeason ~= nil and db.hallowsEndActiveSeason ~= event.seasonId) then


            db.themeName = db.hallowsEndReturnTheme
            db.hallowsEndReturnTheme, db.hallowsEndActiveSeason = nil, nil
        else

            db.hallowsEndActiveSeason = event.seasonId
        end
    else

        db.hallowsEndReturnTheme, db.hallowsEndActiveSeason = nil, nil
    end
end


function Theme:NormalizeSlots(db)
    if db.moonTheme == "WoWClassic" then db.moonTheme = "QuestJournal" end
    if db.sunTheme == "WoWClassic" then db.sunTheme = "QuestJournal" end
    local moon = self:IsOrdinary(db.moonTheme) and db.moonTheme or "AzerothGlass"
    local sun = self:IsOrdinary(db.sunTheme) and db.sunTheme or "LightParchment"
    if moon == sun then sun = moon == "LightParchment" and "AzerothGlass" or "LightParchment" end
    db.moonTheme, db.sunTheme = moon, sun
    return moon, sun
end

function Theme:GetToggleTarget(db, current)
    local moon, sun = self:NormalizeSlots(db)
    current = self:NormalizeName(current or self.paletteName)
    if current == "HallowsEnd" then
        if db.hallowsEndReturnTheme == "WoWClassic" then db.hallowsEndReturnTheme = "QuestJournal" end
        local target = self:IsOrdinary(db.hallowsEndReturnTheme) and db.hallowsEndReturnTheme or "AzerothGlass"
        return target, target == moon and "moon" or target == sun and "sun" or self:IsLight(target) and "sun" or "moon"
    end
    if current == moon then return sun, "sun" end
    if current == sun then return moon, "moon" end
    if self:IsLight(current) then return moon, "moon" end
    return sun, "sun"
end

function Theme:NormalizeName(value)
    if value == "WoWClassic" then return "QuestJournal" end
    if type(value) == "string" and self.palettes[value] then return value end
    return "AzerothGlass"
end


Theme.bindings = setmetatable({}, {__mode = "k"})
Theme.textBindings = setmetatable({}, {__mode = "k"})
Theme.textShadows = setmetatable({}, {__mode = "k"})
Theme.paperSurfaces = setmetatable({}, {__mode = "k"})
Theme.holidayBackgrounds = setmetatable({}, {__mode = "k"})
Theme.classicSurfaces = setmetatable({}, {__mode = "k"})
Theme.classicFrames = setmetatable({}, {__mode = "k"})
Theme.skinButtons = setmetatable({}, {__mode = "k"})
Theme.colorRoles = {}
for _, palette in pairs(Theme.palettes) do
    for group, colors in pairs(palette) do
        for name, color in pairs(colors) do
            Theme.colorRoles[color] = {group, name}
        end
    end
end



function Theme:IsPaperRegion(region)
    for _ = 1, 32 do
        if not region then return false end
        if region.pruiInkSurface then return region.pruiInkSurface == "paper" end
        region = region.GetParent and region:GetParent()
    end
    return false
end

function Theme:ResolveColor(region, color)
    local role = self.colorRoles[color]
    if not role then return color end
    local skin = self:GetSkin()
    if region.pruiWindowTitle and skin and skin.titleInk then return skin.titleInk end
    if self:IsHybrid() and self:IsPaperRegion(region) then
        local paper = role[1] == "text" and self.colors.paperText
            or role[1] == "accent" and self.colors.paperAccent
        if paper and paper[role[2]] then return paper[role[2]] end
    end
    if self:UsesClassicButtons() and role[1] == "text" and role[2] ~= "muted" then
        local ancestor = region
        for _ = 1, 12 do
            if not ancestor then break end
            if ancestor.pruiButtonSkinRole then
                if self:IsActionButton(ancestor) then
                    local skin = self:GetSkin()
                    return skin and skin.actionInk or self.colors.accent.gold
                end
                break
            end
            ancestor = ancestor.GetParent and ancestor:GetParent()
        end
    end
    return self:Get(role[1], role[2])
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
    if self:UsesPaperInk(region) then
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
    local active = self:ResolveColor(region, color)
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
            local color = self:ResolveColor(region, binding.color)
            self:ApplyBoundColor(region, method, color, binding.alpha)
        end
    end
    self:RefreshPaperSurfaces()
    self:RefreshHolidayBackgrounds()
    for frame in pairs(self.classicSurfaces) do ParchmentReader.PRUI.RefreshClassicSurface(frame) end
    for frame in pairs(self.classicFrames) do ParchmentReader.PRUI.RefreshClassicFrame(frame) end
    for button in pairs(self.skinButtons) do ParchmentReader.PRUI.RefreshButtonBevel(button) end
    if refreshEditBoxes then self:ScheduleEditBoxInkRefresh() end
end

function Theme:RefreshPaperSurfaces()
    for frame in pairs(self.paperSurfaces) do
        ParchmentReader.PRUI.RefreshPaperSurface(frame)
    end
end

function Theme:RefreshHolidayBackgrounds()
    for frame in pairs(self.holidayBackgrounds) do
        ParchmentReader.PRUI.RefreshHolidayBackground(frame)
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
    if self.paletteName == "HallowsEnd" then return "|cFFA6BD78" end
    return (self:IsLight() or self:IsHybrid()) and "|cFF8A240C" or "|cFFFFD36A"
end


function Theme:AdaptText(text)
    if self.paletteName == "HallowsEnd" then return (text:gsub("|cFFD1AD61", "|cFFD99A57")) end
    if not self:IsLight() then return text end
    return (text:gsub("|cFFD1AD61", "|cFF83511F"))
end

function Theme:DiagnosticText(text, region)
    if not self:UsesPaperInk(region) then return text end
    local colors = {
        ["FFFFFF00"] = "83511F", ["FF00FF00"] = "245C27",
        ["FFFF9900"] = "83511F", ["FFFFAA00"] = "83511F",
        ["FF00FFFF"] = "20585E", ["FF00AAFF"] = "20585E", ["FFFF0000"] = "9E2117",
        ["FF33FF99"] = "245C27",
    }
    if self.paletteName == "QuestJournal" or self.paletteName == "Forever" then
        colors = {
            ["FFFFFF00"] = "180D04", ["FF00FF00"] = "061206",
            ["FFFF9900"] = "180D04", ["FFFFAA00"] = "180D04",
            ["FF00FFFF"] = "061113", ["FF00AAFF"] = "061113", ["FFFF0000"] = "230703",
            ["FF33FF99"] = "061206",
        }
    end
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
    if frame.pruiClassicDecoration then
        frame.pruiClassicDecoration:SetFrameLevel(frame:GetFrameLevel() + 4)
    end
    if frame.pruiForeverDecoration then
        frame.pruiForeverDecoration:SetFrameLevel(frame:GetFrameLevel() + 4)
    end
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

local CLASSIC_ASSETS = "Interface\\AddOns\\ParchmentReader\\Assets\\"
local NATIVE_BUTTON_ASSETS = "Interface\\Buttons\\UI-Panel-Button-"

local function Finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function Rectangle(left, right, top, bottom)
    return Finite(left) and Finite(right) and Finite(top) and Finite(bottom)
        and left >= 0 and right <= 1 and top >= 0 and bottom <= 1 and left < right and top < bottom
end

local function ClientAsset(value)
    return (type(value) == "string" and value:find("%S") ~= nil)
        or (Finite(value) and value > 0 and value == math.floor(value))
end

local function ResolveClientSource(source)
    if not source.atlas then return source.path, source.coords, source.path and "path:" .. source.path end
    if type(C_Texture) ~= "table" or type(C_Texture.GetAtlasInfo) ~= "function" then return end
    local ok, info = pcall(C_Texture.GetAtlasInfo, source.atlas)
    if not ok or type(info) ~= "table" or not Finite(info.width) or info.width <= 0
        or not Finite(info.height) or info.height <= 0 or info.tilesHorizontally or info.tilesVertically
        or info.isRotated or info.rotated then return end
    local left, right, top, bottom = info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord
    if not Rectangle(left, right, top, bottom) then return end
    local asset = ClientAsset(info.file) and info.file or ClientAsset(info.filename) and info.filename
    local crop = source.relativeCoords or {0, 1, 0, 1}
    if not asset or not Rectangle(unpack(crop)) then return end
    local coords = {left + (right - left) * crop[1], left + (right - left) * crop[2],
        top + (bottom - top) * crop[3], top + (bottom - top) * crop[4]}


    local key = "atlas:" .. source.atlas .. ":" .. tostring(asset) .. ":" .. info.width .. ":" .. info.height
        .. ":" .. table.concat(coords, ":")
    return asset, coords, key
end




function PRUI.ApplyClientMaterial(texture, descriptor, failures, width, height)
    if not descriptor then return false end
    failures = failures or {}
    for _, source in ipairs(descriptor.sources or {descriptor}) do
        local asset, coords, key = ResolveClientSource(source)
        if key and not failures[key] then
            local loaded = true
            if texture.pruiClientMaterialKey ~= key then
                texture.pruiClientMaterialKey = nil
                texture.pruiClientMaterialInvalidated = true
                loaded = texture:SetTexture(asset, source.wrap or "CLAMP", source.wrap or "CLAMP") ~= false
            end
            if loaded then
                texture.pruiClientMaterialKey = key
                texture.pruiClientMaterialInvalidated = nil
                if coords then texture:SetTexCoord(unpack(coords))
                elseif source.tileSize and width and height then
                    texture:SetTexCoord(0, width / source.tileSize, 0, height / source.tileSize)
                else texture:SetTexCoord(0, 1, 0, 1) end
                texture:SetVertexColor(unpack(source.tint or {1, 1, 1, 1}))
                texture:SetBlendMode("BLEND")
                return true, source, key
            end
            failures[key] = true
        end
    end
    return false
end

function PRUI.GetClientSurface(skin, kind, frame)
    if not skin or not skin.nativeSurfaces then return end
    if kind == "paper" then return skin.nativeSurfaces.paper end
    if frame and Theme:IsActionButton(frame) then return end
    local role = frame and (frame.pruiButtonSkinRole or frame.pruiSurfaceRole) or "base"
    if role == "icon" then role = "control" end
    return skin.nativeSurfaces[role] or skin.nativeSurfaces.chrome
end

function PRUI.ApplySkinPreview(texture, skin, kind, role)
    if not skin then return end


    texture.pruiClientMaterialKey = nil
    texture.pruiClientMaterialFailures = texture.pruiClientMaterialFailures or {}
    local native = PRUI.ApplyClientMaterial(texture,
        PRUI.GetClientSurface(skin, kind, {pruiSurfaceRole = role}), texture.pruiClientMaterialFailures)
    if not native then
        local asset = kind == "paper" and skin.paper or skin.chrome
        if asset then texture:SetTexture(CLASSIC_ASSETS .. asset)
        else texture:SetColorTexture(unpack(skin.chromeColor)) end
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetVertexColor(1, 1, 1, 1)
        texture:SetBlendMode("BLEND")
        texture.pruiClientMaterialKey, texture.pruiClientMaterialInvalidated = nil, nil
    end
    texture:SetAlpha(1)
    return native
end

local function NativeFaceCoordinates(top, bottom)
    return {
        left = {8.5 / 128, 12 / 128, top / 32, bottom / 32},
        middle = {12 / 128, 68 / 128, top / 32, bottom / 32},
        right = {68 / 128, 71.5 / 128, top / 32, bottom / 32},
    }
end




PRUI.nativeButtonFace = {
    states = {
        Up = NativeFaceCoordinates(5.5, 17.5),
        Down = NativeFaceCoordinates(7.5, 18.5),
        Disabled = NativeFaceCoordinates(5.5, 17.5),
    },
    highlight = {8.5 / 128, 71.5 / 128, 5.5 / 32, 17.5 / 32},
    capWidth = 4,
}

local function HideNativeButtonFace(frame)
    frame.pruiNativeFaceActive = nil
    frame.pruiNativeFaceState = nil
    for _, texture in ipairs(frame.pruiNativeFace or {}) do texture:Hide() end
    if frame.pruiNativeHighlight then frame.pruiNativeHighlight:Hide() end
end

local function LoadNativeButtonTexture(texture, path)
    if texture.pruiNativePath == path then return true end


    if texture:SetTexture(path) == false then return false end
    texture.pruiNativePath = path
    return true
end

function PRUI.RefreshNativeButtonFace(frame, state, alpha, hovered)
    local coords = PRUI.nativeButtonFace.states[state]
    if not coords or frame.pruiNativeFaceFailed then
        HideNativeButtonFace(frame)
        return false
    end
    if not frame.pruiNativeFace then
        frame.pruiNativeFace = {}
        for index = 1, 3 do
            local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
            texture:SetVertexColor(1, 1, 1, 1)
            frame.pruiNativeFace[index] = texture
        end
        local highlight = frame:CreateTexture(nil, "BACKGROUND", nil, -4)
        highlight:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        highlight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
        highlight:SetBlendMode("ADD")
        frame.pruiNativeHighlight = highlight
    end
    local path = NATIVE_BUTTON_ASSETS .. state
    for _, texture in ipairs(frame.pruiNativeFace) do
        if not LoadNativeButtonTexture(texture, path) then
            frame.pruiNativeFaceFailed = true
            HideNativeButtonFace(frame)
            return false
        end
    end
    if hovered and not LoadNativeButtonTexture(frame.pruiNativeHighlight, NATIVE_BUTTON_ASSETS .. "Highlight") then
        frame.pruiNativeFaceFailed = true
        HideNativeButtonFace(frame)
        return false
    end
    local width = math.max(1, (frame:GetWidth() or 1) - 2)
    local cap = math.min(PRUI.nativeButtonFace.capWidth, math.max(0, (width - 4) / 2))
    local left, middle, right = unpack(frame.pruiNativeFace)
    left:ClearAllPoints()
    left:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
    left:SetWidth(math.max(0.01, cap))
    right:ClearAllPoints()
    right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    right:SetWidth(math.max(0.01, cap))
    middle:ClearAllPoints()
    middle:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
    middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)
    for index, name in ipairs({"left", "middle", "right"}) do
        local texture = frame.pruiNativeFace[index]
        texture:SetTexCoord(unpack(coords[name]))
        texture:SetAlpha(alpha)
        texture:SetShown(index == 2 or cap > 0)
    end
    frame.pruiNativeHighlight:SetTexCoord(unpack(PRUI.nativeButtonFace.highlight))
    frame.pruiNativeHighlight:SetAlpha(0.14 * alpha)
    frame.pruiNativeHighlight:SetShown(hovered == true)
    frame.pruiNativeFaceActive = true
    frame.pruiNativeFaceState = state
    return true
end

local function NativeAtlasInfo(name)
    if type(C_Texture) ~= "table" or type(C_Texture.GetAtlasInfo) ~= "function" then return end
    local ok, info = pcall(C_Texture.GetAtlasInfo, name)
    if not ok or type(info) ~= "table" or not Finite(info.width) or info.width <= 0
        or not Finite(info.height) or info.height <= 0 or info.isRotated or info.rotated
        or not Rectangle(info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord) then return end
    return info
end

local function HideForeverButton(frame)
    frame.pruiForeverFaceActive = nil
    for _, texture in ipairs(frame.pruiForeverFace or {}) do texture:Hide() end
    if frame.pruiForeverHighlight then frame.pruiForeverHighlight:Hide() end
end



function PRUI.RefreshSkinButtonFace(frame, state, alpha, hovered, skin)
    local base = skin and skin.nativeButtonAtlas
    local control = not base and skin and skin.nativeControlAtlases
    if not base and not control then
        HideForeverButton(frame)
        return PRUI.RefreshNativeButtonFace(frame, state, alpha, hovered)
    end
    HideNativeButtonFace(frame)
    local suffix = state == "Down" and "-Pressed" or state == "Disabled" and "-Disabled" or ""
    local names = control or {base .. "-Left" .. suffix, "_" .. base .. "-Center" .. suffix, base .. "-Right" .. suffix}
    local info = {}
    for index, name in ipairs(names) do
        info[index] = NativeAtlasInfo(name)
        if not info[index] then HideForeverButton(frame); return false end
    end
    if hovered and not NativeAtlasInfo(base .. "-Highlight") then HideForeverButton(frame); return false end
    frame.pruiForeverAtlasFailures = frame.pruiForeverAtlasFailures or {}
    for _, name in ipairs(names) do
        if frame.pruiForeverAtlasFailures[name] then HideForeverButton(frame); return false end
    end
    if not frame.pruiForeverFace then
        frame.pruiForeverFace = {}
        for index = 1, 3 do
            frame.pruiForeverFace[index] = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
        end
        local highlight = frame:CreateTexture(nil, "BACKGROUND", nil, -4)
        highlight:SetAllPoints()
        highlight:SetBlendMode("ADD")
        frame.pruiForeverHighlight = highlight
    end
    local function Atlas(texture, name)
        if frame.pruiForeverAtlasFailures[name] then return false end
        local ok, result = pcall(texture.SetAtlas, texture, name, false)
        if not ok or result == false then frame.pruiForeverAtlasFailures[name] = true; return false end
        local info = NativeAtlasInfo(name)
        texture:SetHorizTile(info and info.tilesHorizontally == true)
        texture:SetVertTile(info and info.tilesVertically == true)
        texture:SetVertexColor(1, 1, 1, 1)
        return true
    end
    for index, texture in ipairs(frame.pruiForeverFace) do
        if not Atlas(texture, names[index]) then HideForeverButton(frame); return false end
    end
    if hovered and not Atlas(frame.pruiForeverHighlight, base .. "-Highlight") then HideForeverButton(frame); return false end
    local width, height = math.max(1, frame:GetWidth()), math.max(1, frame:GetHeight())




    local outsetX = base and math.min(1, width * .09) or 0
    local outsetY = base and math.min(2, height * .09) or 0
    width, height = width + 2 * outsetX, height + 2 * outsetY
    local leftWidth, rightWidth = info[1].width * height / info[1].height, info[3].width * height / info[3].height
    local total = leftWidth + rightWidth


    local capScale = math.min(1, width / total)
    local left, center, right = unpack(frame.pruiForeverFace)
    left:ClearAllPoints()
    left:SetPoint("TOPLEFT", frame, "TOPLEFT", -outsetX, outsetY)
    left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -outsetX, -outsetY)
    left:SetWidth(leftWidth * capScale)
    right:ClearAllPoints()
    right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", outsetX, outsetY)
    right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", outsetX, -outsetY)
    right:SetWidth(rightWidth * capScale)
    center:ClearAllPoints(); center:SetPoint("TOPLEFT", left, "TOPRIGHT"); center:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
    left:SetTexCoord(0, capScale, 0, 1)
    center:SetTexCoord(0, 1, 0, 1)
    right:SetTexCoord(1 - capScale, 1, 0, 1)
    for _, texture in ipairs(frame.pruiForeverFace) do texture:SetAlpha(alpha); texture:Show() end
    center:SetShown(width > total)
    frame.pruiForeverHighlight:ClearAllPoints()
    frame.pruiForeverHighlight:SetPoint("TOPLEFT", frame, "TOPLEFT", -outsetX, outsetY)
    frame.pruiForeverHighlight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", outsetX, -outsetY)
    frame.pruiForeverHighlight:SetAlpha(0.14 * alpha)
    frame.pruiForeverHighlight:SetShown(hovered == true)
    frame.pruiForeverFaceActive, frame.pruiForeverFaceState = true, state
    return true
end

function PRUI.RefreshForeverFrame(frame)
    local skin = Theme:GetSkin()
    local layout = skin and skin.nativeFrame
    local decoration = frame.pruiForeverDecoration
    if not layout or type(NineSliceUtil) ~= "table" or type(NineSliceUtil.ApplyLayout) ~= "function" then
        if decoration then decoration:Hide() end
        return false
    end
    local keys, scale = {}, 1
    for piece, descriptor in pairs(layout) do
        local info = NativeAtlasInfo(descriptor.atlas)
        if not info then if decoration then decoration:Hide() end; return false end


        if piece:find("Corner", 1, true) then scale = math.min(scale, 8 / info.width, 8 / info.height)
        elseif piece == "TopEdge" or piece == "BottomEdge" then scale = math.min(scale, 2 / info.height)
        else scale = math.min(scale, 2 / info.width) end
        keys[#keys + 1] = piece .. ":" .. descriptor.atlas .. ":" .. tostring(info.file or info.filename)
            .. ":" .. info.width .. ":" .. info.height .. ":" .. info.leftTexCoord .. ":" .. info.rightTexCoord
            .. ":" .. info.topTexCoord .. ":" .. info.bottomTexCoord
    end
    table.sort(keys)
    local key = table.concat(keys, "|")
    if frame.pruiForeverFrameFailed == key then if decoration then decoration:Hide() end; return false end
    if not decoration then
        decoration = CreateFrame("Frame", nil, frame)
        decoration:EnableMouse(false)
        frame.pruiForeverDecoration = decoration
    end



    decoration:ClearAllPoints()
    decoration:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    decoration:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    decoration:SetFrameLevel(frame:GetFrameLevel() + 4)
    decoration:SetAlpha(frame.pruiClassicAlpha or 1)
    if frame.pruiForeverFrameKey ~= key then
        local checked = {}
        for piece, descriptor in pairs(layout) do checked[piece] = descriptor end


        checked.setupPieceVisualsFunction = function(_, texture, _, descriptor)
            local info = NativeAtlasInfo(descriptor.atlas)
            assert(info, "Native frame atlas became unavailable")
            texture:SetHorizTile(info.tilesHorizontally == true)
            texture:SetVertTile(info.tilesVertically == true)
            local loaded, result = pcall(texture.SetAtlas, texture, descriptor.atlas, false)
            assert(loaded and result ~= false, "Native frame texture unavailable")
            texture:SetSize(info.width * scale, info.height * scale)
            texture:SetVertexColor(1, 1, 1, 1)
        end
        local ok = pcall(NineSliceUtil.ApplyLayout, decoration, checked)
        if not ok then
            frame.pruiForeverFrameFailed = key
            decoration:Hide()
            return false
        end
        frame.pruiForeverFrameKey = key
    end
    decoration:Show()
    return true
end

local function RefreshForeverOutline(frame)
    local hide = frame.pruiForeverFaceActive == true and (Theme:IsActionButton(frame)
        or (frame.pruiInputFrame and not frame.pruiInputOutlineFeedback))
    local saved = frame.pruiForeverOutlineVisibility
    if hide then
        saved = saved or {}
        frame.pruiForeverOutlineVisibility = saved
        for _, texture in pairs(frame.pruiBorder or {}) do
            if saved[texture] == nil then saved[texture] = texture:IsShown() end
            texture:Hide()
        end
    elseif saved then


        for texture, shown in pairs(saved) do texture:SetShown(shown) end
        frame.pruiForeverOutlineVisibility = nil
    end
end

function PRUI.RefreshClassicSurface(frame)
    local kind = Theme.classicSurfaces[frame]
    local skin = Theme:GetSkin()
    local shown = skin ~= nil and kind ~= nil
    if frame.pruiClassicOnlyPaper then
        frame.pruiBackground:SetShown(shown)
        for _, edge in pairs(frame.pruiBorder or {}) do edge:SetShown(shown) end
    end
    local texture = frame.pruiClassicMaterial
    if shown and not texture then

        texture = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
        texture:SetAllPoints()
        texture:SetVertexColor(1, 1, 1, 1)
        frame.pruiClassicMaterial = texture
    end
    if not texture then return end
    local nativeMaterial, nativeSource = false, nil
    if shown then
        local action = kind ~= "paper" and Theme:IsActionButton(frame)
        local asset = kind == "paper" and skin.paper
            or (action and skin.action or skin.chrome)
        if action and skin.nativeButtonAtlas then asset = nil end
        frame.pruiClientMaterialFailures = frame.pruiClientMaterialFailures or {}
        local descriptor = PRUI.GetClientSurface(skin, kind, frame)
        nativeMaterial, nativeSource = PRUI.ApplyClientMaterial(texture, descriptor, frame.pruiClientMaterialFailures,
            frame:GetWidth(), frame:GetHeight())
        if not nativeMaterial then
            if not asset then
                texture:SetColorTexture(unpack(action and skin.actionColor or skin.chromeColor))
            elseif frame.pruiClassicMaterialAsset ~= asset or frame.pruiNativeMaterialActive
                or texture.pruiClientMaterialKey or texture.pruiClientMaterialInvalidated then
                if kind == "paper" then texture:SetTexture(CLASSIC_ASSETS .. asset)
                else texture:SetTexture(CLASSIC_ASSETS .. asset, "REPEAT", "REPEAT") end
            end
            texture.pruiClientMaterialKey = nil
            texture.pruiClientMaterialInvalidated = nil
            texture:SetVertexColor(1, 1, 1, 1)
            texture:SetBlendMode("BLEND")
            if kind == "paper" then texture:SetTexCoord(0, 1, 0, 1) end
        end
        frame.pruiClassicMaterialAsset = asset
    end
    frame.pruiNativeMaterialActive = nativeMaterial or nil
    if shown and not nativeMaterial and kind ~= "paper" and frame.pruiClassicMaterialAsset then

        local tile = frame.pruiClassicMaterialAsset == skin.action and (skin.actionTileSize or 128) or 256
        texture:SetTexCoord(0, math.max(1, frame:GetWidth() or 1) / tile,
            0, math.max(1, frame:GetHeight() or 1) / tile)
    end
    local alpha = frame.pruiClassicAlpha
    if alpha == nil and frame.pruiBackground and frame.pruiBackground.GetAlpha then
        alpha = frame.pruiBackground:GetAlpha()
    end
    alpha = alpha or 1
    if shown then


        frame.pruiClassicAlpha = alpha
        local opacity = kind == "paper" and skin.paperOpacity
            or (Theme:IsActionButton(frame) and skin.actionOpacity
                or (not nativeMaterial and skin.fallbackChromeOpacity or skin.chromeOpacity))
        local materialAlpha = opacity * alpha
        local coverage = materialAlpha * (nativeSource and nativeSource.sourceAlpha or 1)
        frame.pruiBackground:SetAlpha(coverage >= 1 and 0 or (alpha - coverage) / (1 - coverage))
        texture:SetAlpha(materialAlpha)
        frame.pruiClassicPainted = true
    elseif frame.pruiClassicPainted then
        frame.pruiBackground:SetAlpha(frame.pruiHolidayTransparent and 0 or alpha)
        frame.pruiClassicPainted = nil
        frame.pruiClassicAlpha = nil
    end
    local visible = shown and (not frame.pruiBackground or frame.pruiBackground:IsShown() ~= false)
    local native = false
    if visible and skin.nativeControlAtlases and frame.pruiInputFrame then
        native = PRUI.RefreshSkinButtonFace(frame, "Up", skin.chromeOpacity * alpha, false,
            {nativeControlAtlases = skin.nativeControlAtlases})
    elseif visible and skin.nativeButtons and Theme:IsActionButton(frame) then
        local enabled = not frame.IsEnabled or frame:IsEnabled()
        local state = not enabled and "Disabled" or (frame.pruiPressed or frame.pruiSelected) and "Down" or "Up"
        native = PRUI.RefreshSkinButtonFace(frame, state, skin.actionOpacity * alpha,
            enabled and frame.pruiHovered == true and frame.pruiPressed ~= true, skin)
    else
        PRUI.RefreshSkinButtonFace(frame)
    end
    if frame.pruiState then frame.pruiState:SetShown(not native or frame.pruiInputFrame == true) end
    texture:SetShown(visible and not native)
    RefreshForeverOutline(frame)
    if frame.pruiShadow then PRUI.RefreshForeverFrame(frame) end
end

function PRUI.SetClassicSurfaceAlpha(frame, alpha)
    frame.pruiClassicAlpha = (Theme:IsHybrid() or frame.pruiClassicPainted) and alpha or nil
    PRUI.RefreshClassicSurface(frame)
    for _, texture in ipairs(frame.pruiClassicTrim or {}) do texture:SetAlpha(alpha) end
    if frame.pruiForeverDecoration then frame.pruiForeverDecoration:SetAlpha(alpha) end
end

function PRUI.RegisterClassicSurface(frame, kind)
    if not Theme.classicSurfaces[frame] then
        frame:HookScript("OnSizeChanged", PRUI.RefreshClassicSurface)
    end
    Theme.classicSurfaces[frame] = kind
    frame.pruiInkSurface = kind == "paper" and "paper" or "chrome"
    PRUI.RefreshClassicSurface(frame)
end

function PRUI.RefreshClassicFrame(frame)
    local skin = Theme:GetSkin()
    local native = PRUI.RefreshForeverFrame(frame)
    local shown = skin ~= nil and not native
    if shown and not frame.pruiClassicTrim then
        local trim = {}


        local decoration = CreateFrame("Frame", nil, frame)
        decoration:SetAllPoints()
        decoration:SetFrameLevel(frame:GetFrameLevel() + 4)
        decoration:EnableMouse(false)
        frame.pruiClassicDecoration = decoration
        for _, side in ipairs({"TOP", "BOTTOM", "LEFT", "RIGHT"}) do
            for inset = 0, 2 do
                local line = decoration:CreateTexture(nil, "BORDER")
                line.pruiRimInset = inset
                if side == "TOP" or side == "BOTTOM" then
                    local y = side == "TOP" and -inset or inset
                    line:SetPoint(side .. "LEFT", decoration, side .. "LEFT", inset, y)
                    line:SetPoint(side .. "RIGHT", decoration, side .. "RIGHT", -inset, y)
                    line:SetHeight(1)
                else
                    local x = side == "LEFT" and inset or -inset
                    line:SetPoint("TOP" .. side, decoration, "TOP" .. side, x, -inset)
                    line:SetPoint("BOTTOM" .. side, decoration, "BOTTOM" .. side, x, inset)
                    line:SetWidth(1)
                end
                trim[#trim + 1] = line
            end
        end
        for _, corner in ipairs({"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}) do
            local texture = decoration:CreateTexture(nil, "OVERLAY", nil, 7)
            texture.pruiCorner = true
            texture:SetPoint(corner, frame, corner, 0, 0)
            local right, bottom = corner:find("RIGHT"), corner:find("BOTTOM")
            texture:SetTexCoord(right and 0.5 or 0, right and 0 or 0.5,
                bottom and 0.5 or 0, bottom and 0 or 0.5)
            trim[#trim + 1] = texture
        end
        frame.pruiClassicTrim = trim
    end
    if frame.pruiClassicDecoration then frame.pruiClassicDecoration:SetFrameLevel(frame:GetFrameLevel() + 4) end
    for _, texture in ipairs(frame.pruiClassicTrim or {}) do
        local visible = shown and not (skin.hideCornerArtwork and texture.pruiCorner)
        if visible then
            if texture.pruiCorner then
                texture:SetTexture(CLASSIC_ASSETS .. skin.trim)
                texture:SetSize(skin.cornerSize, skin.cornerSize)
            else
                texture:SetColorTexture(unpack(skin.rim[texture.pruiRimInset + 1]))
            end
        end
        texture:SetShown(visible)
        texture:SetAlpha(frame.pruiClassicAlpha or 1)
    end
end

function PRUI.ApplyClassicFrame(frame)
    Theme.classicFrames[frame] = true
    PRUI.RefreshClassicFrame(frame)
end



function PRUI.RefreshButtonBevel(button)
    local shown = Theme:UsesClassicButtons()
        and (not button.pruiBackground or button.pruiBackground:IsShown() ~= false)
    local row = button.pruiButtonSkinRole == "row" or button.pruiIdleBackgroundAlpha == 0
    if shown and not row and not button.pruiButtonBevel then
        local bevel = {}
        for _, side in ipairs({"TOP", "BOTTOM", "LEFT", "RIGHT"}) do
            local inset = 1
            local line = button:CreateTexture(nil, "BORDER", nil, 1)
            line.pruiBevelLight = side == "TOP" or side == "LEFT"
            line.pruiBevelInset = inset
            if side == "TOP" or side == "BOTTOM" then
                local y = side == "TOP" and -inset or inset
                line:SetPoint(side .. "LEFT", button, side .. "LEFT", 3, y)
                line:SetPoint(side .. "RIGHT", button, side .. "RIGHT", -3, y)
                line:SetHeight(1)
            else
                local x = side == "LEFT" and inset or -inset
                line:SetPoint("TOP" .. side, button, "TOP" .. side, x, -3)
                line:SetPoint("BOTTOM" .. side, button, "BOTTOM" .. side, x, 3)
                line:SetWidth(1)
            end
            bevel[#bevel + 1] = line
        end
        button.pruiButtonBevel = bevel
    end
    for _, line in ipairs(button.pruiButtonBevel or {}) do
        local light = line.pruiBevelLight ~= (button.pruiPressed == true)
        local value = light and 0.31 or 0.055
        if Theme.paletteName == "Forever" then
            line:SetColorTexture(light and 0.76 or 0.19, light and 0.54 or 0.10, light and 0.24 or 0.035, 1)
        else line:SetColorTexture(value, value * 1.02, value, 1) end
        line:SetAlpha((button.pruiClassicAlpha or 1) * 0.55)
        line:SetShown(shown and not row and not button.pruiForeverFaceActive)
    end
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
    local role = Theme.colorRoles[options.color or Theme:Get("bg", "base")]
    frame.pruiSurfaceRole = role and role[1] == "bg" and role[2] or "base"
    PRUI.RegisterClassicSurface(frame, role and role[1] == "bg" and role[2] == "surface" and "paper" or "chrome")
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
    if frame.pruiClassicOnlyPaper then return end
    local warm = Theme.paletteName == "WarmParchment"
    if warm and not frame.pruiPaperTexture then
        local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -6)
        texture:SetAllPoints()
        texture:SetTexture("Interface\\AddOns\\ParchmentReader\\Assets\\WarmParchmentBC1")
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

function PRUI.ApplyPaperSurface(frame, edges, classicOnly)
    frame.pruiInkSurface = "paper"
    frame.pruiClassicOnlyPaper = classicOnly == true
    if classicOnly then PRUI.RefreshClassicSurface(frame) end
    frame.pruiPaperEdgesEnabled = edges == true
    Theme.paperSurfaces[frame] = true
    PRUI.RefreshPaperSurface(frame)
end

function PRUI.SetPaperSurfaceAlpha(frame, alpha)
    frame.pruiPaperAlpha = alpha
    if frame.pruiPaperTexture then frame.pruiPaperTexture:SetAlpha(0.30 * alpha) end
end




function PRUI.RefreshHolidayBackground(frame)
    local binding = Theme.holidayBackgrounds[frame]
    if not binding then return end
    local shown = Theme.paletteName == "HallowsEnd" and ParchmentReader:CanUseHolidayAppearance()
    for _, surface in ipairs(binding.surfaces) do
        surface.pruiHolidayTransparent = shown
        surface.pruiBackground:SetAlpha(shown and 0 or 1)
    end
    if not shown then
        if frame.pruiHolidayBackground then frame.pruiHolidayBackground:Hide() end
        return
    end
    local texture = frame.pruiHolidayBackground
    if not texture then
        texture = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
        texture:SetPoint("TOPLEFT", frame, "TOPLEFT", binding.inset, -binding.inset)
        texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -binding.inset, binding.inset)
        texture:SetTexture("Interface\\AddOns\\ParchmentReader\\Assets\\" .. binding.asset)
        frame.pruiHolidayBackground = texture
    end
    texture:SetVertexColor(1, 1, 1, 1)
    texture:SetAlpha(binding.alpha)


    local width, height = frame:GetWidth() - 2 * binding.inset, frame:GetHeight() - 2 * binding.inset
    if type(width) == "number" and type(height) == "number" and width > 0 and height > 0 then
        local aspect = width / height
        local u = math.min(1, aspect / binding.aspect) / binding.zoom
        local v = math.min(1, binding.aspect / aspect) / binding.zoom
        local left, top = (1 - u) * binding.alignX, (1 - v) * binding.alignY
        texture:SetTexCoord(left, left + u, top, top + v)
    end
    texture:Show()
end

function PRUI.ApplyHolidayBackground(frame, asset, aspect, alpha, options)
    options = options or {}
    if not Theme.holidayBackgrounds[frame] then
        frame:HookScript("OnSizeChanged", PRUI.RefreshHolidayBackground)
        frame:HookScript("OnShow", PRUI.RefreshHolidayBackground)
    end
    Theme.holidayBackgrounds[frame] = {
        asset = asset, aspect = aspect, alpha = alpha,
        zoom = math.max(1, tonumber(options.zoom) or 1),
        inset = math.max(0, tonumber(options.inset) or 0),
        alignX = math.max(0, math.min(1, tonumber(options.alignX) or 1)),
        alignY = math.max(0, math.min(1, tonumber(options.alignY) or 1)),
        surfaces = options.surfaces or {},
    }
    PRUI.RefreshHolidayBackground(frame)
end

function PRUI.Panel(parent, options)
    options = options or {}
    local frame = CreateFrame("Frame", options.name, parent)
    return PRUI.ApplySurface(frame, options)
end



local function StackedRowPriority(button)
    local enabled = button:IsEnabled()
    if enabled and button.pruiPressed then return 4 end
    if button.pruiSelected then return 3 end
    if enabled and button.pruiHovered then return 2 end
    if button.pruiStackedSelected then return 1 end
    return 0
end

local function StackedRowNeighbor(button, key)
    local neighbor = button[key]
    if neighbor and neighbor.pruiStackedVisible and neighbor:IsShown() then
        return neighbor
    end
end

local function RefreshStackedRowEdges(button)
    if not button or not button.pruiStackedRow then return end
    local border = button.pruiBorder
    local previous = StackedRowNeighbor(button, "pruiStackedPrevious")
    local following = StackedRowNeighbor(button, "pruiStackedNext")
    local priority = StackedRowPriority(button)
    border.top:SetShown(button.pruiStackedVisible and
        (not previous or priority > StackedRowPriority(previous)))
    border.bottom:SetShown(button.pruiStackedVisible and
        (not following or priority >= StackedRowPriority(following)))
end

local function GetStackedRowPixelSize(region)
    local scale = region:GetEffectiveScale()
    local pixelFactor
    if PixelUtil and PixelUtil.GetPixelToUIUnitFactor then
        pixelFactor = PixelUtil.GetPixelToUIUnitFactor()
    elseif GetPhysicalScreenSize then
        local _, physicalHeight = GetPhysicalScreenSize()
        if physicalHeight and physicalHeight > 0 then pixelFactor = 768 / physicalHeight end
    end
    if not scale or scale <= 0 or not pixelFactor or pixelFactor <= 0 then return end
    return pixelFactor / scale
end

local function RefreshStackedRowGeometry(button)
    local pixel = GetStackedRowPixelSize(button)
    if not pixel then return end
    local border = button.pruiBorder
    local left, right = button:GetLeft(), button:GetRight()
    local top, bottom = button:GetTop(), button:GetBottom()
    local previous = button.pruiStackedGeometry
    if previous and previous[1] == left and previous[2] == right
        and previous[3] == top and previous[4] == bottom and previous[5] == pixel then return end
    button.pruiStackedGeometry = {left, right, top, bottom, pixel}
    local function Offset(position)
        if not position then return 0 end
        return math.floor(position / pixel + 0.5) * pixel - position
    end


    left, right = Offset(left), Offset(right)
    top, bottom = Offset(top), Offset(bottom)
    for _, texture in pairs(border) do
        texture:ClearAllPoints()
        if texture.SetSnapToPixelGrid then texture:SetSnapToPixelGrid(true) end
        if texture.SetTexelSnappingBias then texture:SetTexelSnappingBias(0) end
    end
    border.top:SetPoint("TOPLEFT", button, "TOPLEFT", left, top)
    border.top:SetPoint("TOPRIGHT", button, "TOPRIGHT", right, top)
    border.top:SetHeight(pixel)
    border.bottom:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", left, bottom)
    border.bottom:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", right, bottom)
    border.bottom:SetHeight(pixel)
    border.left:SetPoint("TOPLEFT", button, "TOPLEFT", left, top)
    border.left:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", left, bottom)
    border.left:SetWidth(pixel)
    border.right:SetPoint("TOPRIGHT", button, "TOPRIGHT", right, top)
    border.right:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", right, bottom)
    border.right:SetWidth(pixel)
end

function PRUI.RefreshStackedRowGeometry(rows, viewport)
    local clipTop, clipBottom
    if viewport then
        local pixel = GetStackedRowPixelSize(viewport) or 1
        local top, bottom = viewport:GetTop(), viewport:GetBottom()
        if top and bottom then clipTop, clipBottom = top + pixel, bottom - pixel end
    end
    for _, button in ipairs(rows or {}) do
        if button.pruiStackedRow and button.pruiStackedVisible then
            local top, bottom = button:GetTop(), button:GetBottom()


            if not clipTop or not top or not bottom or (bottom <= clipTop and top >= clipBottom) then
                RefreshStackedRowGeometry(button)
            end
        end
    end
end



function PRUI.SetStackedRows(rows, visibleCount)
    for index, button in ipairs(rows) do
        if not button.pruiStackedRow then
            button.pruiStackedRow = true
            button:HookScript("OnHide", function(self)
                self.pruiHovered, self.pruiPressed = false, false
                PRUI.RefreshButton(self)
            end)
        end
        button.pruiStackedVisible = index <= visibleCount
        button.pruiStackedPrevious = index > 1 and index <= visibleCount and rows[index - 1] or nil
        button.pruiStackedNext = index < visibleCount and rows[index + 1] or nil
    end
    for _, button in ipairs(rows) do RefreshStackedRowEdges(button) end
    PRUI.RefreshStackedRowGeometry(rows)
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
    PRUI.SetClassicSurfaceAlpha(button, emphasized and 1 or (button.pruiIdleBackgroundAlpha or 1))
    PRUI.RefreshButtonBevel(button)
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
    if button.pruiStackedRow then
        RefreshStackedRowEdges(button)
        RefreshStackedRowEdges(button.pruiStackedPrevious)
        RefreshStackedRowEdges(button.pruiStackedNext)
    end
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
    button.pruiButtonSkinRole = options.skinRole or "action"
    Theme.skinButtons[button] = true

    local background = button:CreateTexture(nil, "BACKGROUND", nil, -7)
    background:SetAllPoints()
    SetTextureColor(background, Theme:Get("bg", "control"))
    button.pruiBackground = background
    PRUI.RegisterClassicSurface(button, "chrome")

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
    button:HookScript("OnHide", function(self)
        if self.pruiNativeFace or self.pruiForeverFace then
            self.pruiHovered, self.pruiPressed = false, false
            HideNativeButtonFace(self)
            HideForeverButton(self)
        end
    end)
    button:HookScript("OnShow", function(self)
        if self.pruiNativeFace or self.pruiForeverFace then PRUI.RefreshButton(self) end
    end)
    PRUI.RefreshButton(button)
    return button
end

function PRUI.IconButton(parent, icon, tooltip, options)
    options = options or {}
    options.width = options.width or 24
    options.height = options.height or 24
    options.skinRole = options.skinRole or "icon"
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

function PRUI.AttachTooltip(frame, tooltip, options)
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
            if options and options.wrapText then
                GameTooltip:SetText(tostring(text), 1, 1, 1, 1, true)
            else
                GameTooltip:SetText(tostring(text))
            end
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
    PRUI.ApplyClassicFrame(frame)

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
        skinRole = "action",
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
    title.pruiWindowTitle = true
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
    editBox.pruiContainer.pruiInputOutlineFeedback = (editBox:HasFocus() or editBox.pruiInvalid) and true or false
    PRUI.SetBorderColor(editBox.pruiContainer, borderColor)
    editBox.pruiContainer.pruiBackground:SetAlpha(
        editBox.pruiContainer.pruiHolidayTransparent and 0 or
        (editBox:HasFocus() or editBox.pruiInvalid)
            and 1
            or (editBox.pruiIdleBackgroundAlpha or 1))
    PRUI.SetClassicSurfaceAlpha(editBox.pruiContainer,
        editBox.pruiContainer.pruiHolidayTransparent and 0 or
        (editBox:HasFocus() or editBox.pruiInvalid) and 1 or (editBox.pruiIdleBackgroundAlpha or 1))
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
    container.pruiInputFrame = true

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




function PRUI.BindEditorFocusRelease(frame, editBoxes, relatedFrame)
    local function RefreshListener()
        if frame:IsShown() then
            for _, input in ipairs(editBoxes) do
                if input:HasFocus() then
                    frame:RegisterEvent("GLOBAL_MOUSE_DOWN")
                    return
                end
            end
        end
        frame:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end
    for _, input in ipairs(editBoxes) do
        input:HookScript("OnEditFocusGained", RefreshListener)
        input:HookScript("OnEditFocusLost", RefreshListener)
    end
    frame:HookScript("OnEvent", function(owner, event)
        if event ~= "GLOBAL_MOUSE_DOWN" or owner:IsMouseOver() then return end
        if relatedFrame and relatedFrame:IsShown() and relatedFrame:IsMouseOver() then return end
        for _, input in ipairs(editBoxes) do input:ClearFocus() end
    end)
    frame:HookScript("OnHide", function()
        for _, input in ipairs(editBoxes) do input:ClearFocus() end
        frame:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    RefreshListener()
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
        skinRole = "control",
    })

    dropdown.pruiInputFrame = true
    PRUI.RefreshClassicSurface(dropdown)
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
        local row = PRUI.Button(popover, "", {height = rowHeight, justifyH = "LEFT", skinRole = "row"})
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


function ParchmentReader:IsHolidayAppearanceEnabled()
    return ParchmentReaderDB.holidayAppearanceEnabled ~= false
end

function ParchmentReader:IsHolidayAppearanceAvailable()
    return Theme:GetAvailableHoliday() ~= nil
end

function ParchmentReader:CanUseHolidayAppearance()
    return self:IsHolidayAppearanceAvailable() and self:IsHolidayAppearanceEnabled()
end


function ParchmentReader:RefreshHolidayAppearance(frame)
    local enabled = self:CanUseHolidayAppearance()
    local event = Theme:GetAvailableHoliday()
    local staleSeason = event and ParchmentReaderDB.hallowsEndActiveSeason ~= nil
        and ParchmentReaderDB.hallowsEndActiveSeason ~= event.seasonId
    if (not enabled or staleSeason) and ParchmentReaderDB.themeName == "HallowsEnd" then
        self:SetTheme(Theme:GetToggleTarget(ParchmentReaderDB))
    end
    Theme:RefreshHolidayBackgrounds()
    local settings = ParchmentReaderSettingsFrame
    if settings and settings.RefreshThemeControls then settings:RefreshThemeControls() end
    frame = frame or ParchmentReaderFrame
    if not frame then return end
    if not enabled and self.DismissHolidayDiscovery then self:DismissHolidayDiscovery(frame) end
    if frame.helpButton and frame.themeButton then
        frame.helpButton:ClearAllPoints()
        frame.helpButton:SetPoint("RIGHT", frame.themeButton, "LEFT", -3, 0)
    end
    if frame.RefreshTitleAreaLayout then frame:RefreshTitleAreaLayout() end
    if self.RefreshSeasonalDecoration then self:RefreshSeasonalDecoration(frame) end
end

function ParchmentReader:SetHolidayAppearanceEnabled(enabled)
    ParchmentReaderDB.holidayAppearanceEnabled = enabled == true or enabled == 1
    self:RefreshHolidayAppearance()
end

function ParchmentReader:RefreshThemeButton(frame)
    frame = frame or ParchmentReaderFrame
    if not frame then return end
    if frame.themeButton then
        local _, slot = Theme:GetToggleTarget(ParchmentReaderDB)
        local suffix = slot == "moon" and "ThemeMoon" or "ThemeSun"
        frame.themeButton.icon:SetTexture("Interface\\AddOns\\ParchmentReader\\Assets\\" .. suffix)
    end
    if frame.hallowsEndButton then
        PRUI.SetButtonSelected(frame.hallowsEndButton, Theme.paletteName == "HallowsEnd")
    end
end

function ParchmentReader:SetTheme(value)
    value = Theme:NormalizeName(value)
    if value == "HallowsEnd" and not self:CanUseHolidayAppearance() then return false end
    if self.DismissHolidayDiscovery then self:DismissHolidayDiscovery() end
    if self.DismissForeverDiscovery then self:DismissForeverDiscovery() end
    if value == "HallowsEnd" then
        if ParchmentReaderDB.themeName ~= "HallowsEnd" then
            local previous = Theme:NormalizeName(ParchmentReaderDB.themeName)
            ParchmentReaderDB.hallowsEndReturnTheme = Theme:IsOrdinary(previous) and previous or "AzerothGlass"
        end
        ParchmentReaderDB.hallowsEndActiveSeason = Theme:GetAvailableHoliday().seasonId
    else
        ParchmentReaderDB.hallowsEndReturnTheme, ParchmentReaderDB.hallowsEndActiveSeason = nil, nil
    end
    ParchmentReaderDB.themeName = value
    Theme:NormalizeSeasonalState(ParchmentReaderDB)
    value = ParchmentReaderDB.themeName
    Theme:SetPalette(value)
    if value == "Forever" and self.NoteForeverThemeUsed then self:NoteForeverThemeUsed() end
    local frame = ParchmentReaderFrame
    if frame then
        if frame.contentSurface then PRUI.AddPaperEdges(frame.contentSurface) end

        frame.readerBackgroundTransparent = nil
        self:RefreshReaderTransparency()
        self:RefreshThemeButton(frame)
        if self.RefreshSeasonalDecoration then self:RefreshSeasonalDecoration(frame) end
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
    if value == "WoWClassic" then value = "QuestJournal" end
    if (slot ~= "moon" and slot ~= "sun") or not Theme:IsOrdinary(value) then return false end
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

function ParchmentReader:ToggleHallowsEnd()
    if not self:CanUseHolidayAppearance() then return false end
    if Theme.paletteName == "HallowsEnd" then
        self:SetTheme(Theme:GetToggleTarget(ParchmentReaderDB))
    else
        self:SetTheme("HallowsEnd")
    end
end

function ParchmentReader:ResetThemes()
    ParchmentReaderDB.moonTheme, ParchmentReaderDB.sunTheme = "AzerothGlass", "LightParchment"
    self:SetTheme("AzerothGlass")
end
