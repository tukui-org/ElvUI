local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsUnit = UnitIsUnit

function mod:UpdateElement_Glow(frame)
	if(not frame.HealthBar:IsShown()) then return end
	local r, g, b, shouldShow;
	if (UnitIsUnit(frame.unit, "target") and self.db.useTargetGlow) then
		r, g, b = 1, 1, 1
		shouldShow = true
	else
		-- Use color based on the type of unit (neutral, etc.)
		local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
		local perc = health/maxHealth
		if perc <= self.db.lowHealthThreshold then
			if perc <= self.db.lowHealthThreshold / 2 then
				r, g, b = 1, 0, 0
			else
				r, g, b = 1, 1, 0
			end

			shouldShow = true
		end
	end

	if(shouldShow) then
		frame.Glow:Show()
		if ( (r ~= frame.Glow.r or g ~= frame.Glow.g or b ~= frame.Glow.b) ) then
			frame.Glow:SetBackdropBorderColor(r, g, b);
			frame.Glow.r, frame.Glow.g, frame.Glow.b = r, g, b;
		end
		frame.Glow:SetOutside(frame.HealthBar, 2.5 + mod.mult, 2.5 + mod.mult, frame.PowerBar:IsShown() and frame.PowerBar)
	elseif(frame.Glow:IsShown()) then
		frame.Glow:Hide()
	end
end

function mod:ConfigureElement_Glow(frame)
	frame.Glow:SetFrameLevel(0)
	frame.Glow:SetFrameStrata("BACKGROUND")
	frame.Glow:SetOutside(frame.HealthBar, 2.5 + mod.mult, 2.5 + mod.mult, frame.PowerBar:IsShown() and frame.PowerBar)
	frame.Glow:SetBackdrop( {
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(3),
		insets = {left = E:Scale(5), right = E:Scale(5), top = E:Scale(5), bottom = E:Scale(5)},
	})

	--frame.Glow:SetBackdropBorderColor(0, 0, 0)
	frame.Glow:SetScale(E.PixelMode and 1.5 or 2)
end

function mod:ConstructElement_Glow(frame)
	local f = CreateFrame("Frame", nil, frame)
	f:Hide()
	return f
end