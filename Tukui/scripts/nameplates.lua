-- credits : Caellian - CaelNamePlates !
if not TukuiCF["nameplate"].enable == true then return end

local tNamePlates = CreateFrame("Frame", nil, UIParent)
tNamePlates:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
SetCVar("bloatthreat", 0) -- stop resizing nameplate according to threat level.
SetCVar("bloattest", 1)
if TukuiCF["nameplate"].overlap == true then
	SetCVar("spreadnameplates", "0")
else
	SetCVar("spreadnameplates", "1")
end

local barTexture = TukuiCF["media"].normTex
local overlayTexture = [=[Interface\Tooltips\Nameplate-Border]=]
local font, fontSize, fontOutline = TukuiCF["media"].font, 10, "OUTLINE"
local glowTexture = TukuiCF["media"].glowTex


local backdrop = {
	edgeFile = glowTexture, edgeSize = TukuiDB.Scale(3),
	insets = {left = TukuiDB.Scale(3), right = TukuiDB.Scale(3), top = TukuiDB.Scale(3), bottom = TukuiDB.Scale(3)}
}

local select = select
local isValidFrame = function(frame)
	if frame:GetName() then
		return
	end
	
	overlayRegion = select(2, frame:GetRegions())
	
	return overlayRegion and overlayRegion:GetObjectType() == "Texture" and overlayRegion:GetTexture() == overlayTexture
end

local updateTime = function(self, curValue)
	local minValue, maxValue = self:GetMinMaxValues()
	if self.channeling then
		self.time:SetFormattedText("%.1f ", curValue)
		self.castName:SetText(select(1, (UnitChannelInfo("target"))))
	else
		self.time:SetFormattedText("%.1f ", maxValue - curValue)
		self.castName:SetText(select(1, (UnitCastingInfo("target"))))
	end
end


local function round(num, idp)
  if idp and idp > 0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

local ShortValue = function(value)
	if value >= 1e6 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return value
	end
end

local function CheckTarget(self)
	if UnitName("target") == self.oldname:GetText() and self:GetAlpha() == 1 then
		return true
	else
		return false
	end		
end

local function CheckClass(self)
	local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = self.icon:GetTexCoord()
	if ULx == 0.5 and ULy == 0.5 and LLx == 0.5 and LLy == 0.75 and URx == 0.75 and URy == 0.5 and LRx == 0.75 and LRy == 0.75 then
		return false
	else
		return true
	end
end

local threatUpdate = function(self, elapsed)	
	self.elapsed = self.elapsed + elapsed
	if self.elapsed >= 0.2 then
		--Filter Nameplates
		if TukuiDB.NPCList[self.oldname:GetText()] then
			self:SetAlpha(0)
			if not InCombatLockdown() then
				self:SetScale(0.00001)
			end
			return
		else
			if not InCombatLockdown() then self:SetScale(1) end
			if TukuiCF["nameplate"].enhancethreat == true then
				if not self.oldglow:IsShown() then
					if InCombatLockdown() and not CheckClass(self) then
						if TukuiDB.Role == "Tank" then
							self.healthBar.hpGlow:SetBackdropBorderColor(1, 0, 0)
							self.healthBar:SetStatusBarColor(1, 0, 0)
							self.healthBar.hpBackground:SetVertexColor(0.3, 0, 0)
						else
							self.healthBar.hpGlow:SetBackdropBorderColor(0, 1, 0)
							self.healthBar:SetStatusBarColor(0, 1, 0)
							self.healthBar.hpBackground:SetVertexColor(0, 0.3, 0)
						end			
					else
						if not CheckTarget(self) then
							self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
						end
						self.healthBar:SetStatusBarColor(self.r, self.g, self.b)		
						self.healthBar.hpBackground:SetVertexColor((self.r * 0.3), (self.g * 0.3), (self.b * 0.3))	
					end
				else
					local r, g, b = self.oldglow:GetVertexColor()
					if g + b == 0 then
						if TukuiDB.Role == "Tank" then
							self.healthBar.hpGlow:SetBackdropBorderColor(0, 1, 0)
							self.healthBar:SetStatusBarColor(0, 1, 0)
							self.healthBar.hpBackground:SetVertexColor(0, 0.3, 0)
						else
							self.healthBar.hpGlow:SetBackdropBorderColor(1, 0, 0)
							self.healthBar:SetStatusBarColor(1, 0, 0)
							self.healthBar.hpBackground:SetVertexColor(0.3, 0, 0)
						end
					else
						self.healthBar:SetStatusBarColor(1, 1, 0)
						self.healthBar.hpGlow:SetBackdropBorderColor(1, 1, 0)
						self.healthBar.hpBackground:SetVertexColor(0.3, 0.3, 0)
					end
				end
			else
				if not self.oldglow:IsShown() and not CheckClass(self) then
					self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
				elseif not CheckTarget(self) then
					local r, g, b = self.oldglow:GetVertexColor()
					if g + b == 0 then
						self.healthBar.hpGlow:SetBackdropBorderColor(1, 0, 0)
					else
						self.healthBar.hpGlow:SetBackdropBorderColor(1, 1, 0)
					end
				end
				self.healthBar:SetStatusBarColor(self.r, self.g, self.b)		
			end
				
			local minHealth, maxHealth = self.oldhealth:GetMinMaxValues()
			local valueHealth = self.oldhealth:GetValue()
			local d = math.floor((valueHealth / maxHealth) * 100)
					
				
			if TukuiCF["nameplate"].showhealth == true then
				self.healthBar.percent:SetText(ShortValue(valueHealth).." - "..(string.format("%d%%", math.floor((valueHealth/maxHealth)*100))))
			end
			
			if TukuiCF["nameplate"].showhealth == true then
				self.healthBar:SetHeight(TukuiDB.Scale(12))
			else
				self.healthBar:SetHeight(TukuiDB.Scale(9))
			end
			self.healthBar:SetWidth(TukuiDB.Scale(110))

			if CheckTarget(self) then
				self.healthBar.hpGlow:SetBackdropBorderColor(0.95, 0.95, 0.95)
				self.name:SetTextColor(1, 1, 0)
			else
				self.name:SetTextColor(1,1,1)
			end				
			
			if CheckClass(self) then
				if (d <= 45 and d >= 20) then
					self.healthBar.hpGlow:SetBackdropBorderColor(1, 1, 0)
				elseif(d < 20) then
					self.healthBar.hpGlow:SetBackdropBorderColor(1, 0, 0)
				else		
					if not CheckTarget(self) then
						self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
					else
						self.healthBar.hpGlow:SetBackdropBorderColor(0.95, 0.95, 0.95)
					end
				end
			end	
		end
		self.elapsed = 0
	end
end

local updatePlate = function(self)
	--Filter Nameplates
	if TukuiDB.NPCList[self.oldname:GetText()] and not InCombatLockdown() then
		self:Hide()
		return
	else
		if not InCombatLockdown() then self:Show() end
		local r, g, b = self.healthBar:GetStatusBarColor()
		local newr, newg, newb
		if g + b == 0 then
			-- Hostile unit
			newr, newg, newb = 0.69, 0.31, 0.31
			self.healthBar:SetStatusBarColor(0.69, 0.31, 0.31)
		elseif r + b == 0 then
			-- Friendly unit
			newr, newg, newb = 0.33, 0.59, 0.33
			self.healthBar:SetStatusBarColor(0.33, 0.59, 0.33)
		elseif r + g == 0 then
			-- Friendly player
			newr, newg, newb = 0.31, 0.45, 0.63
			self.healthBar:SetStatusBarColor(0.31, 0.45, 0.63)
		elseif 2 - (r + g) < 0.05 and b == 0 then
			-- Neutral unit
			newr, newg, newb = 0.65, 0.63, 0.35
			self.healthBar:SetStatusBarColor(0.65, 0.63, 0.35)
		else
			-- Hostile player - class colored.
			newr, newg, newb = r, g, b
		end

		self.r, self.g, self.b = newr, newg, newb

		self.healthBar:ClearAllPoints()
		self.healthBar:SetPoint("CENTER", self.healthBar:GetParent(), 0, TukuiDB.Scale(3))
		if TukuiCF["nameplate"].showhealth == true then
			self.healthBar:SetHeight(TukuiDB.Scale(12))
		else
			self.healthBar:SetHeight(TukuiDB.Scale(9))
		end
		self.healthBar:SetWidth(TukuiDB.Scale(110))
		self.name:SetText(self.oldname:GetText())

		self.healthBar.hpBackground:SetVertexColor(self.r * 0.30, self.g * 0.30, self.b * 0.30)
		self.healthBar.hpBackground:SetAlpha(0.9)
		
		self.castBar:ClearAllPoints()
		self.castBar:SetPoint("TOP", self.healthBar, "BOTTOM", 0, TukuiDB.Scale(-4))
		self.castBar:SetHeight(TukuiDB.Scale(5))
		self.castBar:SetWidth(TukuiDB.Scale(110))

		self.highlight:ClearAllPoints()
		self.highlight:SetAllPoints(self.healthBar)
		
		local level, elite, mylevel = tonumber(self.level:GetText()), self.elite:IsShown(), UnitLevel("player")
		self.level:ClearAllPoints()
		self.level:SetPoint("RIGHT", self.healthBar, "RIGHT", TukuiDB.Scale(-2), 0)
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
end


local updateCombos = function(self)
	if TukuiCF["nameplate"].showcombo == true then
		if self:GetAlpha() == 1 and self.name:GetText() == UnitName("target") then
			if GetComboPoints("player", "target") == 5 then
				for i=1, 5 do
					self.CPoints[i]:Show()
				end
			elseif GetComboPoints("player", "target") == 4 then
				self.CPoints[1]:Show()
				self.CPoints[2]:Show()
				self.CPoints[3]:Show()
				self.CPoints[4]:Show()
				self.CPoints[5]:Hide()
			elseif GetComboPoints("player", "target") == 3 then
				self.CPoints[1]:Show()
				self.CPoints[2]:Show()
				self.CPoints[3]:Show()
				self.CPoints[4]:Hide()
				self.CPoints[5]:Hide()
			elseif GetComboPoints("player", "target") == 2 then
				self.CPoints[1]:Show()
				self.CPoints[2]:Show()
				self.CPoints[3]:Hide()
				self.CPoints[4]:Hide()
				self.CPoints[5]:Hide()		
			elseif GetComboPoints("player", "target") == 1 then
				self.CPoints[1]:Show()
				self.CPoints[2]:Hide()
				self.CPoints[3]:Hide()
				self.CPoints[4]:Hide()
				self.CPoints[5]:Hide()	
			else
				for i=1, 5 do
					self.CPoints[i]:Hide()
				end
			end
		else
			for i=1, 5 do
				self.CPoints[i]:Hide()
			end
		end
	end
end


local fixCastbar = function(self)
	self.castbarOverlay:Hide()

	self:SetHeight(TukuiDB.Scale(5))
	self:ClearAllPoints()
	self:SetPoint("TOP", self.healthBar, "BOTTOM", 0, TukuiDB.Scale(-4))
end

local colorCastBar = function(self, shielded)
	if shielded then
		self:SetStatusBarColor(0.8, 0.05, 0)
		self.cbGlow:SetBackdropBorderColor(0.75, 0.75, 0.75)
		self.icGlow:SetBackdropBorderColor(0.75, 0.75, 0.75)
	else
		self.cbGlow:SetBackdropBorderColor(0, 0, 0)
		self.icGlow:SetBackdropBorderColor(0, 0, 0)
	end
end

local onSizeChanged = function(self)
	self.needFix = true
end

local onValueChanged = function(self, curValue)
	updateTime(self, curValue)
	if self.needFix then
		fixCastbar(self)
		self.needFix = nil
	end
end

local onShow = function(self)	
	self.channeling  = UnitChannelInfo("target")
	fixCastbar(self)
	colorCastBar(self, self.shieldedRegion:IsShown())
end

local onHide = function(self)
	self.highlight:Hide()
	self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
end

local onEvent = function(self, event, unit)
	if unit == "target" then
		if self:IsShown() then
			colorCastBar(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
		end
	end
end


local function NameplateOnEvent(frame, event, ...)
	updateCombos(frame)
end


local createPlate = function(frame)
	if frame.done then return end
		
	frame.nameplate = true
	frame.healthBar, frame.castBar = frame:GetChildren()
	local healthBar, castBar = frame.healthBar, frame.castBar
	local glowRegion, overlayRegion, castbarOverlay, shieldedRegion, spellIconRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = frame:GetRegions()
	frame.oldhealth = healthBar
	
	frame.oldname = nameTextRegion
	nameTextRegion:Hide()
	
	local newNameRegion = frame:CreateFontString()
	newNameRegion:SetPoint("BOTTOM", healthBar, "TOP", 0, TukuiDB.Scale(3))
	newNameRegion:SetFont(font, fontSize, fontOutline)
	newNameRegion:SetTextColor(1, 1, 1)
	newNameRegion:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	frame.name = newNameRegion

	frame.level = levelTextRegion
	levelTextRegion:SetFont(font, fontSize, fontOutline)
	levelTextRegion:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)

	healthBar:SetStatusBarTexture(barTexture)

	healthBar.hpBackground = healthBar:CreateTexture(nil, "BORDER")
	healthBar.hpBackground:SetAllPoints(healthBar)
	healthBar.hpBackground:SetTexture(TukuiCF["media"].blank)
	healthBar.hpBackground:SetVertexColor(0.15, 0.15, 0.15)
	
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	frame:RegisterEvent("UNIT_COMBO_POINTS")
	frame:SetScript("OnEvent", NameplateOnEvent)
	
	healthBar.hpGlow = CreateFrame("Frame", nil, healthBar)
	healthBar.hpGlow:SetFrameLevel(healthBar:GetFrameLevel() -1 > 0 and healthBar:GetFrameLevel() -1 or 0)
	healthBar.hpGlow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", TukuiDB.Scale(-3), TukuiDB.Scale(3))
	healthBar.hpGlow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", TukuiDB.Scale(3), TukuiDB.Scale(-3))
	healthBar.hpGlow:SetBackdrop(backdrop)
	healthBar.hpGlow:SetBackdropColor(0, 0, 0)
	healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
	
	if TukuiCF["nameplate"].showhealth == true then
		healthBar.percent = healthBar:CreateFontString(nil, "OVERLAY")	
		healthBar.percent:SetFont(font, fontSize, fontOutline)
		healthBar.percent:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
		healthBar.percent:SetTextColor(1, 1, 1)
		healthBar.percent:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
		healthBar.percent:SetJustifyH("CENTER")	
	end
	
	if TukuiCF["nameplate"].showcombo == true then
		local CPoints = {}
		for i = 1, 5 do
			CPoints[i] = healthBar:CreateTexture(nil, "OVERLAY")
			CPoints[i]:SetHeight(TukuiDB.Scale(10))
			CPoints[i]:SetWidth(TukuiDB.Scale(10))
			CPoints[i]:SetTexture(TukuiCF["media"].bubbleTex)
			if i == 1 then
				CPoints[i]:SetPoint("CENTER", healthBar, "BOTTOM", TukuiDB.Scale(-20), TukuiDB.Scale(-2))
			else
				CPoints[i]:SetPoint("LEFT", CPoints[i-1], "RIGHT")
			end
			CPoints[i]:Hide()
		end
		CPoints[1]:SetVertexColor(0.69, 0.31, 0.31)
		CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
		CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
		CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
		CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
		frame.CPoints = CPoints
	end
	
	castBar.castbarOverlay = castbarOverlay
	castBar.healthBar = healthBar
	castBar.shieldedRegion = shieldedRegion
	castBar:SetStatusBarTexture(barTexture)

	castBar:HookScript("OnShow", onShow)
	castBar:HookScript("OnSizeChanged", onSizeChanged)
	castBar:HookScript("OnValueChanged", onValueChanged)
	castBar:HookScript("OnEvent", onEvent)
	castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	castBar:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

	castBar.time = castBar:CreateFontString(nil, "ARTWORK")
	castBar.time:SetPoint("RIGHT", castBar, "LEFT", TukuiDB.Scale(-2), 0)
	castBar.time:SetFont(font, fontSize, fontOutline)
	castBar.time:SetTextColor(1, 1, 1)
	castBar.time:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)

	castBar.castName = castBar:CreateFontString(nil, "OVERLAY")	
	castBar.castName:SetFont(font, fontSize, fontOutline)
	castBar.castName:SetPoint("TOP", castBar, "BOTTOM", 0, -TukuiDB.mult)
	castBar.castName:SetTextColor(1, 1, 1)
	castBar.castName:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
	castBar.castName:SetJustifyH("CENTER")		
	
	castBar.cbBackground = castBar:CreateTexture(nil, "BACKGROUND")
	castBar.cbBackground:SetAllPoints(castBar)
	castBar.cbBackground:SetTexture(TukuiCF["media"].blank)
	castBar.cbBackground:SetVertexColor(0.15, 0.15, 0.15)

	castBar.cbGlow = CreateFrame("Frame", nil, castBar)
	castBar.cbGlow:SetFrameLevel(castBar:GetFrameLevel() -1 > 0 and castBar:GetFrameLevel() -1 or 0)
	castBar.cbGlow:SetPoint("TOPLEFT", castBar, "TOPLEFT", TukuiDB.Scale(-3), TukuiDB.Scale(3))
	castBar.cbGlow:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", TukuiDB.Scale(3), TukuiDB.Scale(-3))
	castBar.cbGlow:SetBackdrop(backdrop)
	castBar.cbGlow:SetBackdropColor(0.25, 0.25, 0.25, 0)
	castBar.cbGlow:SetBackdropBorderColor(0, 0, 0)

	castBar.Holder = CreateFrame("Frame", nil, castBar)
	castBar.Holder:SetFrameLevel(castBar.Holder:GetFrameLevel() + 1)
	castBar.Holder:SetAllPoints()
	
	-- some frame strata dancing
	castBar.Hold = CreateFrame("Frame", nil, healthBar)
	castBar.Hold:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0)
	castBar.Hold:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)	
	castBar.Hold:SetFrameLevel(10)
	castBar.Hold:SetFrameStrata("MEDIUM")	

	
	local cIconTex = castBar.Hold:CreateTexture(nil, "OVERLAY")
	cIconTex:SetPoint("RIGHT", healthBar, "LEFT", TukuiDB.Scale(-4), TukuiDB.Scale(4))
	cIconTex:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
	cIconTex:SetHeight(22)
	cIconTex:SetWidth(22)	
	frame.icon = cIconTex
	
	spellIconRegion:ClearAllPoints()
	spellIconRegion:SetParent(castBar)
	spellIconRegion:SetTexCoord(.08, .92, .08, .92)
	spellIconRegion:SetPoint("BOTTOMLEFT", castBar, "BOTTOMRIGHT", 5, 0.25)
	spellIconRegion:SetSize(TukuiDB.Scale(22), TukuiDB.Scale(22))
	
	spellIconRegion.IconBackdrop = CreateFrame("Frame", nil, castBar)
	spellIconRegion.IconBackdrop:SetPoint("TOPLEFT", spellIconRegion, "TOPLEFT", TukuiDB.Scale(-3), TukuiDB.Scale(3))
	spellIconRegion.IconBackdrop:SetPoint("BOTTOMRIGHT", spellIconRegion, "BOTTOMRIGHT", TukuiDB.Scale(3), TukuiDB.Scale(-3))
	spellIconRegion.IconBackdrop:SetBackdrop(backdrop)
	spellIconRegion.IconBackdrop:SetBackdropColor(0, 0, 0)
	spellIconRegion.IconBackdrop:SetBackdropBorderColor(0, 0, 0)

	highlightRegion:SetTexture(barTexture)
	highlightRegion:SetVertexColor(0.25, 0.25, 0.25)
	frame.highlight = highlightRegion

	raidIconRegion:ClearAllPoints()
	raidIconRegion:SetPoint("CENTER", healthBar, "CENTER", 0, TukuiDB.Scale(35))
	raidIconRegion:SetSize(TukuiDB.Scale(30), TukuiDB.Scale(30))
	raidIconRegion:SetTexture(TukuiCF["media"].raidicons)	
	
	frame.oldglow = glowRegion
	frame.elite = stateIconRegion
	frame.boss = bossIconRegion
	castBar.icGlow = spellIconRegion.IconBackdrop

	frame.done = true

	glowRegion:SetTexture(nil)
	overlayRegion:SetTexture(nil)
	shieldedRegion:SetTexture(nil)
	castbarOverlay:SetTexture(nil)
	stateIconRegion:SetTexture(nil)
	bossIconRegion:SetTexture(nil)

	updatePlate(frame)
	frame:SetScript("OnShow", updatePlate)
	
	if TukuiCF["nameplate"].showcombo == true then
		frame:HookScript("OnShow", updateCombos)
	end
	
	frame:SetScript("OnHide", onHide)

	frame.elapsed = 0
	
	frame:SetScript("OnUpdate", UpdateClass)	
	frame:HookScript("OnUpdate", threatUpdate)
end

-- update class func
function UpdateClass(frame)
	local r, g, b = frame.healthBar:GetStatusBarColor();
	local r, g, b = floor(r*100+.5)/100, floor(g*100+.5)/100, floor(b*100+.5)/100;
	local classname = "";
	local hasclass = 0;
	for class, color in pairs(RAID_CLASS_COLORS) do
		if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == b then
			classname = class;
		end
	end
	if (classname) then
		texcoord = CLASS_BUTTONS[classname];
		if texcoord then
			hasclass = 1;
		else
			texcoord = {0.5, 0.75, 0.5, 0.75};
			hasclass = 0;
		end
	else
		texcoord = {0.5, 0.75, 0.5, 0.75};
		hasclass = 0;
	end
	frame.icon:SetTexCoord(texcoord[1],texcoord[2],texcoord[3],texcoord[4]);
end	

local numKids = 0
tNamePlates:SetScript("OnUpdate", function(self, elapsed)

	local newNumKids = WorldFrame:GetNumChildren()
	if newNumKids ~= numKids then
		for i = numKids + 1, newNumKids do
			local frame = select(i, WorldFrame:GetChildren())

			if isValidFrame(frame) then
				createPlate(frame)
			end
		end
		numKids = newNumKids
	end
end)