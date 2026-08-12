

local L = ParchmentReader.L
local READER_SHORTCUTS = {
    {L["Up / Down"], L["Scroll three lines"]},
    {L["Page Up / Page Down"], L["Scroll by one screen"]},
    {L["Home / End"], L["Confirm jump to beginning / end"]},
    {L["Esc"], L["Close the active window or popover"]},
}

local EDITOR_SHORTCUTS = {
    {L["Arrow keys"], L["Move the text cursor"]},
    {L["Mouse drag"], L["Select text directly"]},
    {L["Shift + navigation"], L["Extend the text selection"]},
    {L["Esc"], L["Leave the field; again requests close"]},
}

local function CreateShortcutSection(frame, titleText, shortcuts, topOffset)
    local Theme = ParchmentReader.Theme
    local PRUI = ParchmentReader.PRUI

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, topOffset)
    title:SetText(titleText)
    PRUI.SetFontStringColor(title, Theme:Get("accent", "gold"))

    local previousRow
    for _, shortcut in ipairs(shortcuts) do
        local row = PRUI.Panel(frame, {color = Theme:Get("bg", "control")})
        row:SetPoint("LEFT", frame, "LEFT", 16, 0)
        row:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
        row:SetHeight(24)
        if previousRow then
            row:SetPoint("TOP", previousRow, "BOTTOM", 0, -2)
        else
            row:SetPoint("TOP", title, "BOTTOM", 0, -5)
        end

        local keyText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        keyText:SetPoint("LEFT", row, "LEFT", 9, 0)
        keyText:SetWidth(142)
        keyText:SetJustifyH("LEFT")
        keyText:SetText(shortcut[1])
        PRUI.SetFontStringColor(keyText, Theme:Get("text", "primary"))

        local description = row:CreateFontString(
            nil, "OVERLAY", "GameFontNormalSmall")
        description:SetPoint("LEFT", keyText, "RIGHT", 8, 0)
        description:SetPoint("RIGHT", row, "RIGHT", -9, 0)
        description:SetJustifyH("LEFT")
        description:SetText(shortcut[2])
        PRUI.SetFontStringColor(description, Theme:Get("text", "secondary"))

        previousRow = row
    end
end

function ParchmentReader:CreateKeyboardHelpFrame()
    local Theme = self.Theme
    local PRUI = self.PRUI
    local frame = PRUI.Window(UIParent, {
        name = "ParchmentReaderKeyboardHelpFrame",
        title = L["Keyboard Help"],
    })
    frame:SetSize(430, 350)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:EnableMouse(true)
    self:RegisterEscapeClose("ParchmentReaderKeyboardHelpFrame")

    CreateShortcutSection(frame, L["READER"], READER_SHORTCUTS, -47)
    CreateShortcutSection(frame, L["EDITOR"], EDITOR_SHORTCUTS, -185)

    local combatNote = frame:CreateFontString(
        nil, "OVERLAY", "GameFontNormalSmall")
    combatNote:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 11)
    combatNote:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 11)
    combatNote:SetJustifyH("CENTER")
    combatNote:SetText(
        L["Reader keys stay active here and pause only during combat."])
    PRUI.SetFontStringColor(combatNote, Theme:Get("text", "muted"))

    frame:Hide()
    return frame
end

function ParchmentReader:ToggleKeyboardHelp()
    local frame = ParchmentReaderKeyboardHelpFrame
        or self:CreateKeyboardHelpFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        frame:Raise()
    end
end
