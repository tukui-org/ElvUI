local _, ns = ...
local oUF = oUF or ns.oUF
assert(oUF, 'oUF_Cutaway was unable to locate oUF install.')

--[[
    Configuration values for both health and power:
        .enabled: enable cutaway for this element, defaults to disabled
        .fadeOutTime: How long it takes the cutaway health to fade, defaults to 0.6 seconds
        .lengthBeforeFade: How long it takes before the cutaway begins to fade, defaults to 0.3 seconds
]]

-- GLOBALS: ElvUI

local C_Timer_After = C_Timer.After
local hooksecurefunc = hooksecurefunc
local UnitHealthMax = UnitHealthMax
local UnitPowerMax = UnitPowerMax
local UnitIsTapDenied = UnitIsTapDenied

local function CreateFadeClosure(element)
    return function()
        ElvUI[1]:UIFrameFadeOut(element, element.fadeOutTime, 1, 0)
        C_Timer_After(element.fadeOutTime, function() element.ready = false; element.playing = false end);
    end
end

local function Health_PreUpdate(self, unit)
    local element = self.__owner.Cutaway.Health
    if element.ready or UnitIsTapDenied(unit) or not element.enabled then
        return
    end
    element.cur = self:GetValue() or 0
    element:SetValue(element.cur)
    element:SetMinMaxValues(0, UnitHealthMax(unit) or 1)
    element.ready = true
end

local function Health_PostUpdate(self, unit, cur, max)
    local element = self.__owner.Cutaway.Health
    if not element.ready or element.playing then
        return
    end
    if (element.cur or 0) > (cur) then
        if (not element.closure) then
            element.closure = CreateFadeClosure(element)
        end
        element:SetAlpha(1)
        C_Timer_After(element.lengthBeforeFade, element.closure)
        element.playing = true
    else
        element.ready = false
        element.playing = false
    end
end

local function Health_PostUpdateColor(self, _, _, _, _)
    local r, g, b, a = self:GetStatusBarColor()
    self.__owner.Cutaway.Health:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, a)
end

local function Power_PreUpdate(self, unit)
    local element = self.__owner.Cutaway.Power
    if element.ready or not element.enabled then
        return
    end
    element.cur = self:GetValue() or 0
    element:SetValue(element.cur)
    element:SetMinMaxValues(0, UnitPowerMax(unit) or 1)
    element.ready = true
end

local function Power_PostUpdate(self, unit, cur, max)
    local element = self.__owner.Cutaway.Power
    if not element.ready or element.playing then
        return
    end
    if (element.cur or 1) > (cur) then
        if (not element.closure) then
            element.closure = CreateFadeClosure(element)
        end
        element:SetAlpha(1)
        C_Timer_After(element.lengthBeforeFade, element.closure)
        element.playing = true
    else
        element.ready = false
        element.playing = false
    end
end

local function Power_PostUpdateColor(self, _, _, _, _)
    local r, g, b, a = self:GetStatusBarColor()
    self.__owner.Cutaway.Power:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, a)
end

local function Enable(self)
    local element = self.Cutaway
    if (element) then
        if (element.Health and element.Health:IsObjectType("StatusBar") and not element.Health:GetStatusBarTexture()) then
            element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
        end

        if (element.Power and element.Power:IsObjectType("StatusBar") and not element.Power:GetStatusBarTexture()) then
            element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
        end

        if element.Health and self.Health then
            self.Health.__owner = self

            element.Health.lengthBeforeFade = element.Health.lengthBeforeFade or 0.3
            element.Health.fadeOutTime = element.Health.fadeOutTime or 0.6

            if not element.Health.hasCutawayHook then
                if self.Health.PreUpdate then
                    hooksecurefunc(self.Health, "PreUpdate", Health_PreUpdate)
                else
                    self.Health.PreUpdate = Health_PreUpdate
                end

                if self.Health.PostUpdate then
                    hooksecurefunc(self.Health, "PostUpdate", Health_PostUpdate)
                else
                    self.Health.PostUpdate = Health_PostUpdate
                end

                if self.Health.PostUpdateColor then
                    hooksecurefunc(self.Health, "PostUpdateColor", Health_PostUpdateColor)
                else
                    self.Health.PostUpdateColor = Health_PostUpdateColor
                end

                element.Health.hasCutawayHook = true
            end
        end

        if element.Power and self.Power then
            self.Power.__owner = self

            element.Power.lengthBeforeFade = element.Power.lengthBeforeFade or 0.3
            element.Power.fadeOutTime = element.Power.fadeOutTime or 0.6

            if not element.Power.hasCutawayHook then
                if self.Power.PreUpdate then
                    hooksecurefunc(self.Power, "PreUpdate", Power_PreUpdate)
                else
                    self.Power.PreUpdate = Power_PreUpdate
                end

                if self.Power.PostUpdate then
                    hooksecurefunc(self.Power, "PostUpdate", Power_PostUpdate)
                else
                    self.Power.PostUpdate = Power_PostUpdate
                end

                if self.Power.PostUpdateColor then
                    hooksecurefunc(self.Power, "PostUpdateColor", Power_PostUpdateColor)
                else
                    self.Power.PostUpdateColor = Power_PostUpdateColor
                end

                element.Power.hasCutawayHook = true
            end
        end
        element:Show()

        return true
    end
end

local function Disable(self)
    local element = self.Cutaway
    if (element) then
        element:Hide()
    end
end

oUF:AddElement("Cutaway", nil, Enable, Disable)
