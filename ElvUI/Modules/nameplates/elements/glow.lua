local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitHealth = UnitHealth
local UnitIsUnit = UnitIsUnit
local UnitHealthMax = UnitHealthMax

--[[ Target Glow Style Option Variables
	style1:'Border',
	style2:'Background',
	style3:'Top Arrow Only',
	style4:'Side Arrows Only',
	style5:'Border + Top Arrow',
	style6:'Background + Top Arrow',
	style7:'Border + Side Arrows',
	style8:'Background + Side Arrows'
]]

function mod:UpdatePoisiton_Arrow(frame, shouldShow)
	if frame.TopArrow and (shouldShow ~= 2) and (self.db.targetGlow == "style3" or self.db.targetGlow == "style5" or self.db.targetGlow == "style6") then -- top arrow
		local topArrowSpace = -3
		if self.db.units[frame.UnitType].showName and (frame.Name:GetText() ~= nil and frame.Name:GetText() ~= "") then
			topArrowSpace = self.db.fontSize + topArrowSpace
		end
		frame.TopArrow:Point("BOTTOM", frame.HealthBar, "TOP", 0, topArrowSpace)

		if shouldShow then
			frame.TopArrow:Show()
		end
	end

	if (frame.LeftArrow and frame.RightArrow) and (shouldShow ~= 2) and (self.db.targetGlow == "style4" or self.db.targetGlow == "style7" or self.db.targetGlow == "style8") then -- side arrows
		frame.RightArrow:Point("RIGHT", (frame.Portrait:IsShown() and frame.Portrait) or frame.HealthBar, "LEFT", 3, 0)
		frame.LeftArrow:Point("LEFT", frame.HealthBar, "RIGHT", -3, 0)

		if shouldShow then
			frame.RightArrow:Show()
			frame.LeftArrow:Show()
		end
	end
end

function mod:UpdatePosition_Glow(frame, shouldShow)
	local castBar = frame.CastBar and frame.CastBar:IsShown() and frame.CastBar
	local bottomBar = castBar or (frame.PowerBar and frame.PowerBar:IsShown() and frame.PowerBar)
	local iconPosition = castBar and (castBar.Icon and castBar.Icon:IsShown()) and (frame.UnitType and self.db.units[frame.UnitType].castbar.iconPosition)

	if frame.Glow and (self.db.targetGlow == "style1" or self.db.targetGlow == "style5" or self.db.targetGlow == "style7") then -- original glow
		local offset = E:Scale(E.PixelMode and 6 or 8) -- edgeSize is 5 (not attached to the backdrop needs +1 for pixel mode or +3 for non pixel mode)
		frame.Glow:SetOutside((iconPosition == "LEFT" and castBar.Icon) or frame.HealthBar, offset, offset, (iconPosition == "RIGHT" and castBar.Icon) or bottomBar)

		if shouldShow then
			frame.Glow:Show()
		end
	end

	if frame.Glow2 and (self.db.targetGlow == "style2" or self.db.targetGlow == "style6" or self.db.targetGlow == "style8") then -- new background glow
		local scale = 1
		if self.db.useTargetScale then
			if self.db.targetScale >= 0.75 then
				scale = self.db.targetScale
			else
				scale = 0.75
			end
		end

		local size = (E.Border+14+(bottomBar and 3 or 0))*scale;
		frame.Glow2:Point("TOPLEFT", (iconPosition == "LEFT" and castBar.Icon) or frame.HealthBar, "TOPLEFT", -(size*2), size)
		frame.Glow2:Point("BOTTOMRIGHT", (iconPosition == "RIGHT" and castBar.Icon) or bottomBar or frame.HealthBar, "BOTTOMRIGHT", size*2, -size)

		if shouldShow then
			frame.Glow2:Show()
		end
	end
end

function mod:UpdateElement_Glow(frame)
	if frame.TopArrow:IsShown() then frame.TopArrow:Hide() end
	if frame.LeftArrow:IsShown() then frame.LeftArrow:Hide() end
	if frame.RightArrow:IsShown() then frame.RightArrow:Hide() end
	if frame.Glow2:IsShown() then frame.Glow2:Hide() end
	if frame.Glow:IsShown() then frame.Glow:Hide() end
	if not frame.HealthBar:IsShown() then return end

	local shouldShow, r, g, b, a = 0;
	if UnitIsUnit(frame.unit, "target") and (self.db.targetGlow ~= "none") then
		r, g, b, a = self.db.glowColor.r, self.db.glowColor.g, self.db.glowColor.b, self.db.glowColor.a
		shouldShow = 1
	elseif self.db.lowHealthThreshold > 0 then
		-- Use color based on the type of unit (neutral, etc.)
		local health, maxHealth = UnitHealth(frame.unit), UnitHealthMax(frame.unit)
		local perc = (maxHealth > 0 and health/maxHealth) or 0
		if perc <= self.db.lowHealthThreshold then
			if perc <= self.db.lowHealthThreshold / 2 then
				r, g, b, a = 1, 0, 0, 1
			else
				r, g, b, a = 1, 1, 0, 1
			end

			shouldShow = 2
		end
	end

	if shouldShow ~= 0 then
		self:UpdatePosition_Glow(frame, shouldShow);
		self:UpdatePoisiton_Arrow(frame, shouldShow);

		if frame.Glow and (r ~= frame.Glow.r or g ~= frame.Glow.g or b ~= frame.Glow.b or a ~= frame.Glow.a) then
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
	frame.Glow:SetBackdrop({edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(5)})
end

function mod:ConstructElement_Glow(frame)
	local f = CreateFrame("Frame", nil, frame)
	f:Hide()

	local glow = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	glow:SetTexture([[Interface\AddOns\ElvUI\media\textures\spark]])
	glow:Hide()
	frame.Glow2 = glow

	local top = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	top:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicator]])
	top:Size(45)
	top:Hide()
	frame.TopArrow = top

	local left = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	left:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorLeft]])
	left:Size(45)
	left:Hide()
	frame.LeftArrow = left

	local right = frame:CreateTexture(nil, "BACKGROUND", nil, -5)
	right:SetTexture([[Interface\AddOns\ElvUI\media\textures\nameplateTargetIndicatorRight]])
	right:Size(45)
	right:Hide()
	frame.RightArrow = right

	return f
end
