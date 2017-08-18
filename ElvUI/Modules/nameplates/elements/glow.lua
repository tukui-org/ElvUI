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
	if frame.Glow:IsShown() then frame.Glow:Hide() end
	if frame.Glow2:IsShown() then frame.Glow2:Hide() end
	if not frame.HealthBar:IsShown() then return end

	local scale, r, g, b, a, shouldShow = 1;
	if (UnitIsUnit(frame.unit, "target") and self.db.targetGlow ~= "none") then
		r, g, b, a = self.db.glowColor.r, self.db.glowColor.g, self.db.glowColor.b, self.db.glowColor.a
		shouldShow = true
	else
		-- Use color based on the type of unit (neutral, etc.)
		local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
		local perc = health/maxHealth
		if perc <= self.db.lowHealthThreshold then
			if perc <= self.db.lowHealthThreshold / 2 then
				r, g, b, a = 1, 0, 0, 1
			else
				r, g, b, a = 1, 1, 0, 1
			end

			shouldShow = true
		end
	end

	if(shouldShow) then
		if self.db.targetGlow == "style1" then
			frame.Glow:Show()
		elseif self.db.targetGlow == "none" or self.db.targetGlow == "style2" then
			frame.Glow2:Show()
			if self.db.useTargetScale then
				if self.db.targetScale >= 0.75 then
					scale = self.db.targetScale
				else
					scale = 0.75
				end
			end
			frame.Glow2:SetPoint("TOPLEFT", frame.HealthBar, -E:Scale(20*scale), E:Scale(10*scale))
			frame.Glow2:SetPoint("BOTTOMRIGHT", frame.HealthBar, E:Scale(20*scale), -E:Scale(10*scale))
		end
		if (r ~= frame.Glow.r or g ~= frame.Glow.g or b ~= frame.Glow.b or a ~= frame.Glow.a) then
			frame.Glow:SetBackdropBorderColor(r, g, b, a);
			frame.Glow2:SetVertexColor(r, g, b, a);
			frame.Glow.r, frame.Glow.g, frame.Glow.b, frame.Glow.a = r, g, b, a;
		end
		frame.Glow:SetOutside(frame.HealthBar, 2.5 + mod.mult, 2.5 + mod.mult, frame.PowerBar:IsShown() and frame.PowerBar)
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

	local g = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	g:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark.tga]])
	g:Hide()
	frame.Glow2 = g

	return f
end