if not TukuiNamePlates == true then return end

local caelNamePlates = CreateFrame("Frame", nil, UIParent)
caelNamePlates:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

local barTexture = [=[Interface\Addons\Tukui\media\normTex]=]
local overlayTexture = [=[Interface\Tooltips\Nameplate-Border]=]
local glowTexture = [=[Interface\Addons\Tukui\media\glowTex]=]
local font, fontSize, fontOutline = [=[Interface\Addons\Tukui\media\neuropol x cd rg.ttf]=], 9, "OUTLINE"
local backdrop = {
		edgeFile = glowTexture, edgeSize = 5,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
local select = select

local IsValidFrame = function(frame)
	if frame:GetName() then
		return
	end

	overlayRegion = select(2, frame:GetRegions())

	return overlayRegion and overlayRegion:GetObjectType() == "Texture" and overlayRegion:GetTexture() == overlayTexture
end

local UpdateTime = function(self, curValue)
	local minValue, maxValue = self:GetMinMaxValues()
	if self.channeling then
		self.time:SetFormattedText("%.1f ", curValue)
	else
		self.time:SetFormattedText("%.1f ", maxValue - curValue)
	end
end

local ThreatUpdate = function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= 0.2 then
		if not self.oldglow:IsShown() then
			self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
		else
			self.healthBar.hpGlow:SetBackdropBorderColor(self.oldglow:GetVertexColor())
		end

		self.healthBar:SetStatusBarColor(self.r, self.g, self.b)

		self.elapsed = 0
	end
end

local UpdateFrame = function(self)
	local r, g, b = self.healthBar:GetStatusBarColor()
	local newr, newg, newb
	if g + b == 0 then
		newr, newg, newb = 0.69, 0.31, 0.31
		self.healthBar:SetStatusBarColor(0.69, 0.31, 0.31)
	elseif r + b == 0 then
		newr, newg, newb = 0.33, 0.59, 0.33
		self.healthBar:SetStatusBarColor(0.33, 0.59, 0.33)
	elseif r + g == 0 then
		newr, newg, newb = 0.31, 0.45, 0.63
		self.healthBar:SetStatusBarColor(0.31, 0.45, 0.63)
	elseif 2 - (r + g) < 0.05 and b == 0 then
		newr, newg, newb = 0.65, 0.63, 0.35
		self.healthBar:SetStatusBarColor(0.65, 0.63, 0.35)
	else
		newr, newg, newb = r, g, b
	end

	self.r, self.g, self.b = newr, newg, newb

	self.healthBar:ClearAllPoints()
	self.healthBar:SetPoint("CENTER", self.healthBar:GetParent())
	self.healthBar:SetHeight(6)
	self.healthBar:SetWidth(100)

	self.castBar:ClearAllPoints()
	self.castBar:SetPoint("TOP", self.healthBar, "BOTTOM", 0, -4)
	self.castBar:SetHeight(5)
	self.castBar:SetWidth(100)

	self.highlight:ClearAllPoints()
	self.highlight:SetAllPoints(self.healthBar)

	self.name:SetText(self.oldname:GetText())

	local level, elite, mylevel = tonumber(self.level:GetText()), self.elite:IsShown(), UnitLevel("player")
	self.level:ClearAllPoints()
	self.level:SetPoint("RIGHT", self.healthBar, "LEFT", -2, 1)
	if self.boss:IsShown() then
		self.level:SetText("B")
		self.level:SetTextColor(0.8, 0.05, 0)
		self.level:Show()
	elseif not elite and level == mylevel then
		self.level:Hide()
	else
		self.level:SetText(level..(elite and "+" or ""))
	end
end

local FixCastbar = function(self)
	self.castbarOverlay:Hide()

	self:SetHeight(5)
	self:ClearAllPoints()
	self:SetPoint("TOP", self.healthBar, "BOTTOM", 0, -4)
end

local ColorCastBar = function(self, shielded)
	if shielded then
		self:SetStatusBarColor(0.8, 0.05, 0)
		self.cbGlow:SetBackdropBorderColor(0.75, 0.75, 0.75)
	else
		self.cbGlow:SetBackdropBorderColor(0, 0, 0)
	end
end

local OnSizeChanged = function(self)
	self.needFix = true
end

local OnValueChanged = function(self, curValue)
	UpdateTime(self, curValue)
	if self.needFix then
		FixCastbar(self)
		self.needFix = nil
	end
end

local OnShow = function(self)
	self.channeling  = UnitChannelInfo("target") 
	FixCastbar(self)
	ColorCastBar(self, self.shieldedRegion:IsShown())
end

local OnHide = function(self)
	self.highlight:Hide()
	self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
end

local OnEvent = function(self, event, unit)
	if unit == "target" then
		if self:IsShown() then
			ColorCastBar(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
		end
	end
end

local CreateFrame = function(frame)
	if frame.done then
		return
	end

	frame.nameplate = true

	frame.healthBar, frame.castBar = frame:GetChildren()
	local healthBar, castBar = frame.healthBar, frame.castBar
	local glowRegion, overlayRegion, castbarOverlay, shieldedRegion, spellIconRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = frame:GetRegions()

	frame.oldname = nameTextRegion
	nameTextRegion:Hide()

	local newNameRegion = frame:CreateFontString()
	newNameRegion:SetPoint("BOTTOM", healthBar, "TOP", 0, 3)
	newNameRegion:SetFont(font, fontSize, fontOutline)
	newNameRegion:SetTextColor(0.84, 0.75, 0.65)
	newNameRegion:SetShadowOffset(1.25, -1.25)
	frame.name = newNameRegion

	frame.level = levelTextRegion
	levelTextRegion:SetFont(font, fontSize, fontOutline)
	levelTextRegion:SetShadowOffset(1.25, -1.25)

	healthBar:SetStatusBarTexture(barTexture)

	healthBar.hpBackground = healthBar:CreateTexture(nil, "BORDER")
	healthBar.hpBackground:SetAllPoints(healthBar)
	healthBar.hpBackground:SetTexture(barTexture)
	healthBar.hpBackground:SetVertexColor(0.15, 0.15, 0.15)

	healthBar.hpGlow = CreateFrame("Frame", nil, healthBar)
	healthBar.hpGlow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -4.5, 4.5)
	healthBar.hpGlow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 4.5, -4.5)
	healthBar.hpGlow:SetBackdrop(backdrop)
	healthBar.hpGlow:SetBackdropColor(0, 0, 0)
	healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)

	castBar.castbarOverlay = castbarOverlay
	castBar.healthBar = healthBar
	castBar.shieldedRegion = shieldedRegion
	castBar:SetStatusBarTexture(barTexture)

	castBar:HookScript("OnShow", OnShow)
	castBar:HookScript("OnSizeChanged", OnSizeChanged)
	castBar:HookScript("OnValueChanged", OnValueChanged)
	castBar:HookScript("OnEvent", OnEvent)
	castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	castBar:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

	castBar.time = castBar:CreateFontString(nil, "ARTWORK")
	castBar.time:SetPoint("RIGHT", castBar, "LEFT", -2, 1)
	castBar.time:SetFont(font, fontSize, fontOutline)
	castBar.time:SetTextColor(0.84, 0.75, 0.65)
	castBar.time:SetShadowOffset(1.25, -1.25)

	castBar.cbBackground = castBar:CreateTexture(nil, "BORDER")
	castBar.cbBackground:SetAllPoints(castBar)
	castBar.cbBackground:SetTexture(barTexture)
	castBar.cbBackground:SetVertexColor(0.15, 0.15, 0.15)

	castBar.cbGlow = CreateFrame("Frame", nil, castBar)
	castBar.cbGlow:SetPoint("TOPLEFT", castBar, "TOPLEFT", -4.5, 4)
	castBar.cbGlow:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 4.5, -4.5)
	castBar.cbGlow:SetBackdrop(backdrop)
	castBar.cbGlow:SetBackdropColor(0, 0, 0)
	castBar.cbGlow:SetBackdropBorderColor(0, 0, 0)
		
	spellIconRegion:ClearAllPoints()
	spellIconRegion:SetPoint("TOPLEFT", healthBar, "TOPRIGHT", 5, 0)
	spellIconRegion:SetHeight(15)
	spellIconRegion:SetWidth(15)
		
	castBar.cbIcon = CreateFrame("Frame", nil, castBar)
	castBar.cbIcon:SetFrameLevel(0)
	castBar.cbIcon:SetFrameStrata("BACKGROUND")
	castBar.cbIcon:SetPoint("TOPLEFT", spellIconRegion, "TOPLEFT", -4, 4)
	castBar.cbIcon:SetPoint("BOTTOMRIGHT", spellIconRegion, "BOTTOMRIGHT", 4, -4)
	castBar.cbIcon:SetBackdrop(backdrop)
	castBar.cbIcon:SetBackdropColor(0, 0, 0)
	castBar.cbIcon:SetBackdropBorderColor(0, 0, 0)
		
	highlightRegion:SetTexture(barTexture)
	highlightRegion:SetVertexColor(0.25, 0.25, 0.25)
	frame.highlight = highlightRegion

	raidIconRegion:ClearAllPoints()
	raidIconRegion:SetPoint("LEFT", healthBar, "RIGHT", 2, 0)
	raidIconRegion:SetHeight(15)
	raidIconRegion:SetWidth(15)

	frame.oldglow = glowRegion
	frame.elite = stateIconRegion
	frame.boss = bossIconRegion

	frame.done = true

	glowRegion:SetTexture(nil)
	overlayRegion:SetTexture(nil)
	shieldedRegion:SetTexture(nil)
	castbarOverlay:SetTexture(nil)
	stateIconRegion:SetTexture(nil)
	bossIconRegion:SetTexture(nil)

	UpdateFrame(frame)
	frame:SetScript("OnShow", UpdateFrame)
	frame:SetScript("OnHide", OnHide)

	frame.elapsed = 0
	frame:SetScript("OnUpdate", ThreatUpdate)
end

local numKids = 0
local lastUpdate = 0
local OnUpdate = function(self, elapsed)
	lastUpdate = lastUpdate + elapsed

	if lastUpdate > 0.1 then
		lastUpdate = 0

		if WorldFrame:GetNumChildren() ~= numKids then
			numKids = WorldFrame:GetNumChildren()
			for i = 1, select("#", WorldFrame:GetChildren()) do
				frame = select(i, WorldFrame:GetChildren())

				if IsValidFrame(frame) then
					CreateFrame(frame)
				end
			end
		end
	end
end

caelNamePlates:SetScript("OnUpdate", OnUpdate)