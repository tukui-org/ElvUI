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
	if frame.TopArrow:IsShown() then frame.TopArrow:Hide() end
	if frame.LeftArrow:IsShown() then frame.LeftArrow:Hide() end
	if frame.RightArrow:IsShown() then frame.RightArrow:Hide() end
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
		--style1: border
		--style2: background
		--style3: top arrow only
		--style4: side arrows only
		--style5: border + top arrow
		--style6: background + top arrow
		--style7: border + side arrows
		--style8: background + side arrows
		if self.db.targetGlow == "style1" or self.db.targetGlow == "style5" or self.db.targetGlow == "style7" then -- original glow
			frame.Glow:Show()
			frame.Glow:SetOutside(frame.HealthBar, 2.5 + mod.mult, 2.5 + mod.mult, frame.PowerBar:IsShown() and frame.PowerBar)
		end
		if self.db.targetGlow == "style2" or self.db.targetGlow == "style6" or self.db.targetGlow == "style8" then -- new background glow
			frame.Glow2:Show()
			if self.db.useTargetScale then
				if self.db.targetScale >= 0.75 then
					scale = self.db.targetScale
				else
					scale = 0.75
				end
			end
			frame.Glow2:SetPoint("TOPLEFT", frame.HealthBar, -E:Scale(20*scale), E:Scale(10*scale))
			frame.Glow2:SetPoint("BOTTOMRIGHT", (frame.PowerBar:IsShown() and frame.PowerBar) or frame.HealthBar, E:Scale(20*scale), -E:Scale(10*scale))
		end
		if self.db.targetGlow == "style3" or self.db.targetGlow == "style5" or self.db.targetGlow == "style6" then -- top arrow
			frame.TopArrow:SetPoint("BOTTOM", frame.HealthBar, "TOP", 0, E:Scale(2*scale))
			frame.TopArrow:Show()
		end
		if self.db.targetGlow == "style4" or self.db.targetGlow == "style7" or self.db.targetGlow == "style8" then -- side arrows
			frame.RightArrow:SetPoint("RIGHT", frame.HealthBar, "LEFT", E:Scale(2*scale), 0)
			frame.LeftArrow:SetPoint("LEFT", frame.HealthBar, "RIGHT", -E:Scale(2*scale), 0)
			frame.RightArrow:Show()
			frame.LeftArrow:Show()
		end
		if (r ~= frame.Glow.r or g ~= frame.Glow.g or b ~= frame.Glow.b or a ~= frame.Glow.a) then
			frame.Glow:SetBackdropBorderColor(r, g, b, a);
			frame.Glow2:SetVertexColor(r, g, b, a);
			frame.TopArrow:SetVertexColor(r, g, b, a);
			frame.LeftArrow:SetVertexColor(r, g, b, a);
			frame.RightArrow:SetVertexColor(r, g, b, a);
			frame.Glow.r, frame.Glow.g, frame.Glow.b, frame.Glow.a = r, g, b, a;
		end
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

	local glow = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	glow:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark.tga]])
	glow:Hide()
	frame.Glow2 = glow

	local top = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	top:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicator.tga]])
	top:Size(45)
	top:Hide()
	frame.TopArrow = top

	local left = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	left:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorLeft.tga]])
	left:Size(45)
	left:Hide()
	frame.LeftArrow = left

	local right = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	right:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorRight.tga]])
	right:Size(45)
	right:Hide()
	frame.RightArrow = right

	return f
end