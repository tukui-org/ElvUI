local addonName = ...
local ADDON = CreateFrame("Frame")

local function GetElvUI()
    if not _G.ElvUI then return nil end
    return unpack(_G.ElvUI)
end

-- Returns all ElvUI Custom Text regions on a specific unit frame
-- whose configured text contains an absorbs tag.
local function GetAbsorbRegions(unit)
    local E = GetElvUI()
    local frame = _G["ElvUF_" .. (unit == "target" and "Target" or "Player")]

    if not E or not frame or not frame.customTexts then
        return nil
    end

    local units = E.db and E.db.unitframe and E.db.unitframe.units
    local unitDB = units and units[unit]
    local customDB = unitDB and unitDB.customTexts

    if not customDB then
        return nil
    end

    local regions = {}

    for name, config in pairs(customDB) do
        local format = config and (config.text_format or config.textFormat or config.format)

        if type(format) == "string" and format:lower():find("absorbs", 1, true) then
            local region = frame.customTexts[name]

            if region then
                regions[#regions + 1] = region
            end
        end
    end

    return regions
end

local function UpdateUnitAbsorb(unit)
    if unit ~= "player" and unit ~= "target" then
        return
    end

    local regions = GetAbsorbRegions(unit)
    if not regions then return end

    local absorb = UnitGetTotalAbsorbs(unit)

    for i = 1, #regions do
        local region = regions[i]

        -- Force the ElvUI Custom Text to refresh immediately instead of
        -- waiting for the normal oUF tag waiter.
        if region.UpdateTag then
            region:UpdateTag()
        end

        -- Secret Value is passed directly to SetAlpha.
        -- Never compare, calculate, or branch on the absorb value.
        if region.SetAlpha then
            region:SetAlpha(absorb)
        end
    end
end

ADDON:RegisterEvent("PLAYER_LOGIN")
ADDON:RegisterEvent("PLAYER_ENTERING_WORLD")
ADDON:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")

ADDON:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        if unit == "player" then
            UpdateUnitAbsorb("player")
        elseif unit == "target" then
            UpdateUnitAbsorb("target")
        end
        return
    end

    -- ElvUI can create/recreate Custom Text regions during setup/profile
    -- changes, so apply after the frames exist.
    C_Timer.After(0, function()
        UpdateUnitAbsorb("player")
        UpdateUnitAbsorb("target")
    end)

    C_Timer.After(1, function()
        UpdateUnitAbsorb("player")
        UpdateUnitAbsorb("target")
    end)
end)

SLASH_ELVUIABSORBTEXT1 = "/eua"
SlashCmdList.ELVUIABSORBTEXT = function()
    UpdateUnitAbsorb("player")
    UpdateUnitAbsorb("target")
end
