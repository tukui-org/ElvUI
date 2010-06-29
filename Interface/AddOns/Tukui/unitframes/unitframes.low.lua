--[[--------------------------------------------------------------------
	oUF_Tukz
	
	I'd like to thank Haste for his awesome oUF framework, without which 
	this layout would do absolutely nothing. I'd also like to thank Caellian 
	for his cleanly written oUF_Caellian which helped me as a guide to write 
	this layout. 

	Supported Units:
		Player
		Pet
		Target
		Target Target
		Focus
		Party 
		Vehicule
		Raid10
		Raid25
		Raid40
		Raid15
		Arena#
		Boss#

	Required Dependencies:
		oUF
	
----------------------------------------------------------------------]]

if not TukuiDB["unitframes"].enable == true or not TukuiDB.lowversion == true then return end

------------------------------------------------------------------------
--	Textures and Medias
------------------------------------------------------------------------
local floor = math.floor
local format = string.format

local normTex = TukuiDB["media"].normTex
local glowTex = TukuiDB["media"].glowTex
local bubbleTex = TukuiDB["media"].bubbleTex

local backdrop = {
	bgFile = TukuiDB["media"].blank,
	insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult},
}

local font = TukuiDB["media"].uffont
local font2 = TukuiDB["media"].font
local _, class = UnitClass("player")

------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------

local colors = setmetatable({
	power = setmetatable({
		["MANA"] = {0.31, 0.45, 0.63},
		["RAGE"] = {0.69, 0.31, 0.31},
		["FOCUS"] = {0.71, 0.43, 0.27},
		["ENERGY"] = {0.65, 0.63, 0.35},
		["RUNES"] = {0.55, 0.57, 0.61},
		["RUNIC_POWER"] = {0, 0.82, 1},
		["AMMOSLOT"] = {0.8, 0.6, 0},
		["FUEL"] = {0, 0.55, 0.5},
		["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
		["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	}, {__index = oUF.colors.power}),
	happiness = setmetatable({
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	}, {__index = oUF.colors.happiness}),
	runes = setmetatable({
		[1] = {0.69, 0.31, 0.31},
		[2] = {0.33, 0.59, 0.33},
		[3] = {0.31, 0.45, 0.63},
		[4] = {0.84, 0.75, 0.65},
	}, {__index = oUF.colors.runes}),
}, {__index = oUF.colors})

oUF.colors.class = {
	["DEATHKNIGHT"] = { 196/255,  30/255,  60/255 },
	["DRUID"]       = { 255/255, 125/255,  10/255 },
	["HUNTER"]      = { 171/255, 214/255, 116/255 },
	["MAGE"]        = { 104/255, 205/255, 255/255 },
	["PALADIN"]     = { 245/255, 140/255, 186/255 },
	["PRIEST"]      = { 212/255, 212/255, 212/255 },	-- tukz priest color
	["ROGUE"]       = { 255/255, 243/255,  82/255 },
	["SHAMAN"]      = {   41/255, 79/255, 155/255 },	-- tukz Shaman color
	["WARLOCK"]     = { 148/255, 130/255, 201/255 },
	["WARRIOR"]     = { 199/255, 156/255, 110/255 },
}

local UnitReactionColor = {
	[1] = { 219/255, 48/255,  41/255 }, -- Hated
	[2] = { 219/255, 48/255,  41/255 }, -- Hostile
	[3] = { 219/255, 48/255,  41/255 }, -- Unfriendly
	[4] = { 218/255, 197/255, 92/255 }, -- Neutral
	[5] = { 75/255,  175/255, 76/255 }, -- Friendly
	[6] = { 75/255,  175/255, 76/255 }, -- Honored
	[7] = { 75/255,  175/255, 76/255 }, -- Revered
	[8] = { 75/255,  175/255, 76/255 }, -- Exalted
}

oUF.colors.tapped = {0.55, 0.57, 0.61}
oUF.colors.disconnected = {0.84, 0.75, 0.65}

oUF.colors.smooth = {0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.15, 0.15, 0.15}

local runeloadcolors = {
	[1] = {.69,.31,.31},
	[2] = {.69,.31,.31},
	[3] = {.33,.59,.33},
	[4] = {.33,.59,.33},
	[5] = {.31,.45,.63},
	[6] = {.31,.45,.63},
}

------------------------------------------------------------------------
--	Fonction (don't edit this if you don't know what you are doing!)
------------------------------------------------------------------------

local SetUpAnimGroup = function(self)
	self.anim = self:CreateAnimationGroup("Flash")
	self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
	self.anim.fadein:SetChange(1)
	self.anim.fadein:SetOrder(2)

	self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
	self.anim.fadeout:SetChange(-1)
	self.anim.fadeout:SetOrder(1)
end

local Flash = function(self, duration)
	if not self.anim then
		SetUpAnimGroup(self)
	end

	self.anim.fadein:SetDuration(duration)
	self.anim.fadeout:SetDuration(duration)
	self.anim:Play()
end

local StopFlash = function(self)
	if self.anim then
		self.anim:Finish()
	end
end

local function Menu(self)
	if(self.unit == "player") then
		ToggleDropDownMenu(1, nil, oUF_Tukz_DropDown, "cursor")
	elseif(_G[string.gsub(self.unit, "(.)", string.upper, 1) .. "FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[string.gsub(self.unit, "(.)", string.upper, 1) .. "FrameDropDown"], "cursor")
	end
end

local SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1.25, -1.25)
	return fs
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

local function ShowThreat(self, event, unit)
	if (self.unit ~= "player") then
		return
	end
	local threat = UnitThreatSituation(self.unit)
	if (threat == 3) then
		self.FrameBackdrop:SetBackdropBorderColor(1, .1, .1)
	else
		self.FrameBackdrop:SetBackdropBorderColor(0, 0, 0)
	end 
end

local PostUpdateHealth = function(self, event, unit, bar, min, max)
	if not UnitIsConnected(unit) then
		bar:SetValue(0)
		bar.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_offline.."|r")
	elseif UnitIsDead(unit) then
		bar.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_dead.."|r")
	elseif UnitIsGhost(unit) then
		bar.value:SetText("|cffD7BEA5"..tukuilocal.unitframes_ouf_ghost.."|r")	
	else
		if min ~= max then
			local r, g, b
			r, g, b = oUF.ColorGradient(min/max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
			if unit == "player" and self:GetAttribute("normalUnit") ~= "pet" then
				if TukuiDB["unitframes"].showtotalhpmp == true then
					bar.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", ShortValue(min), ShortValue(max))
				else
					bar.value:SetFormattedText("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", min, r * 255, g * 255, b * 255, floor(min / max * 100))
				end
			elseif unit == "target" or unit == "focus" or (unit and unit:find("boss%d")) then
				if TukuiDB["unitframes"].showtotalhpmp == true then
					bar.value:SetFormattedText("|cff559655%s|r |cffD7BEA5|||r |cff559655%s|r", ShortValue(min), ShortValue(max))
				else
					bar.value:SetFormattedText("|cffAF5050%s|r |cffD7BEA5-|r |cff%02x%02x%02x%d%%|r", ShortValue(min), r * 255, g * 255, b * 255, floor(min / max * 100))
				end
			elseif (self:GetName():match"oUF_Arena") then
					bar.value:SetText("|cff559655"..ShortValue(min).."|r")
			else
				bar.value:SetFormattedText("|cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, floor(min / max * 100))
			end
		else
			if unit ~= "player" and unit ~= "pet" then
				bar.value:SetText("|cff559655"..ShortValue(max).."|r")
			else
				bar.value:SetText("|cff559655"..max.."|r")
			end
		end
	end
end

local PostNamePosition = function(self)
	self.Info:ClearAllPoints()
	if (self.Power.value:GetText() and UnitIsEnemy("player", "target") and TukuiDB["unitframes"].targetpowerpvponly == true) or (self.Power.value:GetText() and TukuiDB["unitframes"].targetpowerpvponly == false) then
		self.Info:SetPoint("CENTER", self.panel, "CENTER", 0, 1)
	else
		self.Power.value:SetAlpha(0)
		self.Info:SetPoint("LEFT", self.panel, "LEFT", 4, 1)
	end
end

local PreUpdatePower = function(self, event, unit)
	if(self.unit ~= unit) then return end
	local _, pType = UnitPowerType(unit)
	
	local color = self.colors.power[pType]
	if color then
		self.Power:SetStatusBarColor(color[1], color[2], color[3])
	end
end

local PostUpdatePower = function(self, event, unit, bar, min, max)
	if (self.unit ~= "player" and self.unit ~= "vehicle" and self.unit ~= "pet" and self.unit ~= "target" and not(self:GetName():match"oUF_Arena")) then return end

	local pType, pToken = UnitPowerType(unit)
	local color = colors.power[pToken]

	if color then
		bar.value:SetTextColor(color[1], color[2], color[3])
	end

	if min == 0 then
		bar.value:SetText()
	elseif not UnitIsPlayer(unit) and not UnitPlayerControlled(unit) or not UnitIsConnected(unit) then
		bar.value:SetText()
	elseif UnitIsDead(unit) or UnitIsGhost(unit) then
		bar.value:SetText()
	elseif min == max and (pType == 2 or pType == 3 and pToken ~= "POWER_TYPE_PYRITE") then
		bar.value:SetText()
	else
		if min ~= max then
			if pType == 0 then
				if unit == "target" then
					if TukuiDB["unitframes"].showtotalhpmp == true then
						bar.value:SetFormattedText("%s |cffD7BEA5|||r %s", ShortValue(max - (max - min)), ShortValue(max))
					else
						bar.value:SetFormattedText("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), ShortValue(max - (max - min)))
					end
				elseif unit == "player" and self:GetAttribute("normalUnit") == "pet" or unit == "pet" then
					if TukuiDB["unitframes"].showtotalhpmp == true then
						bar.value:SetFormattedText("%s |cffD7BEA5|||r %s", ShortValue(max - (max - min)), ShortValue(max))
					else
						bar.value:SetFormattedText("%d%%", floor(min / max * 100))
					end
				elseif (self:GetName():match"oUF_Arena") then
					bar.value:SetText(ShortValue(min))
					--bar.value:SetTextColor(1, 1, 1)
				else
					if TukuiDB["unitframes"].showtotalhpmp == true then
						bar.value:SetFormattedText("%s |cffD7BEA5|||r %s", ShortValue(max - (max - min)), ShortValue(max))
					else
						bar.value:SetFormattedText("%d%% |cffD7BEA5-|r %d", floor(min / max * 100), max - (max - min))
					end
				end
			else
				bar.value:SetText(max - (max - min))
			end
		else
			if unit == "pet" or unit == "target" or (unit and unit:find("arena%d")) then
				bar.value:SetText(ShortValue(min))
			elseif (self:GetName():match"oUF_Arena") then
				bar.value:SetText("|cffFFFFFF"..min.."|r")
			else
				bar.value:SetText(min)
			end
		end
	end
	if self.Info then
		if self.unit == "target" then PostNamePosition(self) end
	end
end

local delay = 0
local viperAspectName = GetSpellInfo(34074)
local UpdateManaLevel = function(self, elapsed)
	delay = delay + elapsed
	if self.parent.unit ~= "player" or delay < 0.2 or UnitIsDeadOrGhost("player") or UnitPowerType("player") ~= 0 then return end
	delay = 0

	local percMana = UnitMana("player") / UnitManaMax("player") * 100

	if AotV then
		local viper = UnitBuff("player", viperAspectName)
		if percMana >= TukuiDB["unitframes"].highThreshold and viper then
			self.ManaLevel:SetText("|cffaf5050"..tukuilocal.unitframes_ouf_gohawk.."|r")
			Flash(self, 0.3)
		elseif percMana <= TukuiDB["unitframes"].lowThreshold and not viper then
			self.ManaLevel:SetText("|cffaf5050"..tukuilocal.unitframes_ouf_goviper.."|r")
			Flash(self, 0.3)
		else
			self.ManaLevel:SetText()
			StopFlash(self)
		end
	else
		if percMana <= 20 then
			self.ManaLevel:SetText("|cffaf5050"..tukuilocal.unitframes_ouf_lowmana.."|r")
			Flash(self, 0.3)
		else
			self.ManaLevel:SetText()
			StopFlash(self)
		end
	end
end

local UpdateDruidMana = function(self)
	if self.unit ~= "player" then return end

	local num, str = UnitPowerType("player")
	if num ~= 0 then
		local min = UnitPower("player", 0)
		local max = UnitPowerMax("player", 0)

		local percMana = min / max * 100
		if percMana <= TukuiDB["unitframes"].lowThreshold then
			self.FlashInfo.ManaLevel:SetText("|cffaf5050"..tukuilocal.unitframes_ouf_lowmana.."|r")
			Flash(self.FlashInfo, 0.3)
		else
			self.FlashInfo.ManaLevel:SetText()
			StopFlash(self.FlashInfo)
		end

		if min ~= max then
			if self.Power.value:GetText() then
				self.DruidMana:SetPoint("LEFT", self.Power.value, "RIGHT", 1, 0)
				self.DruidMana:SetFormattedText("|cffD7BEA5-|r %d%%|r", floor(min / max * 100))
			else
				self.DruidMana:SetPoint("LEFT", self.panel, "LEFT", 4, 1)
				self.DruidMana:SetFormattedText("%d%%", floor(min / max * 100))
			end
		else
			self.DruidMana:SetText()
		end

		self.DruidMana:SetAlpha(1)
	else
		self.DruidMana:SetAlpha(0)
	end
end

local UpdateCPoints = function(self, event, unit)
	if unit == PlayerFrame.unit and unit ~= self.CPoints.unit then
		self.CPoints.unit = unit
	end
end

local FormatCastbarTime = function(self, duration)
	if self.channeling then
		self.Time:SetFormattedText("%.1f ", duration)
	elseif self.casting then
		self.Time:SetFormattedText("%.1f ", self.max - duration)
	end
end

local UpdateReputationColor = function(self, event, unit, bar)
	local name, id = GetWatchedFactionInfo()
	bar:SetStatusBarColor(FACTION_BAR_COLORS[id].r, FACTION_BAR_COLORS[id].g, FACTION_BAR_COLORS[id].b)
end

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", ceil(s / hour))
	elseif s >= hour then
		return format("%dh", ceil(s / hour))
	elseif s >= minute then
		return format("%dm", ceil(s / minute))
	elseif s >= minute / 12 then
		return floor(s)
	end
	return format("%.1f", s)
end

local Createauratimer = function(self,elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = FormatTime(self.timeLeft)
				self.remaining:SetText(time)
				if self.timeLeft < 5 then
					self.remaining:SetTextColor(0.69, 0.31, 0.31)
				else
					self.remaining:SetTextColor(0.84, 0.75, 0.65)
				end
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

local CancelAura = function(self, button)
	if button == "RightButton" and not self.debuff then
		CancelUnitBuff("player", self:GetID())
	end
end

local function createAura(self, button, icons)
	icons.showDebuffType = true

	button.remaining = SetFontString(button, font2, TukuiDB["unitframes"].auratextscale, "THINOUTLINE")
	button.remaining:SetPoint("CENTER", 0.2, 1)
	
	button.cd.noOCC = true		 	-- hide OmniCC CDs
	button.cd.noCooldownCount = true	-- hide CDC CDs
	button.count:SetFont(TukuiDB["media"].font, TukuiDB:Scale(10), "THINOUTLINE")
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", 0, 2)
	TukuiDB:SetTemplate(button)
	button.icon:SetPoint("TOPLEFT", TukuiDB:Scale(2), TukuiDB:Scale(-2))
	button.icon:SetPoint("BOTTOMRIGHT", TukuiDB:Scale(-2), TukuiDB:Scale(2))
	button.icon:SetTexCoord(.08, .92, .08, .92)
	button.icon:SetDrawLayer("ARTWORK")
	button.overlay:SetTexture()
		
	if TukuiDB["unitframes"].auraspiral == true then
		icons.disableCooldown = false
		button.cd:SetReverse()
		button.overlayFrame = CreateFrame("frame", nil, button, nil)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", TukuiDB:Scale(2), TukuiDB:Scale(-2))
		button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", TukuiDB:Scale(-2), TukuiDB:Scale(2))
		button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)
		   
		button.overlay:SetParent(button.overlayFrame)
		button.count:SetParent(button.overlayFrame)
		button.remaining:SetParent(button.overlayFrame)
	else
		icons.disableCooldown = true
	end
	
	if self.unit == "player" then
		button:SetScript("OnMouseUp", CancelAura)
	end
			
	button.Glow = CreateFrame("Frame", nil, button)
	button.Glow:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
	button.Glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
	button.Glow:SetFrameStrata("BACKGROUND")	
	button.Glow:SetBackdrop{edgeFile = glowTex, edgeSize = 3, insets = {left = 0, right = 0, top = 0, bottom = 0}}
	button.Glow:SetBackdropColor(0, 0, 0, 0)
	button.Glow:SetBackdropBorderColor(0, 0, 0)
end

local function updatedebuff(self, icons, unit, icon, index, offset, filter, isDebuff, duration, timeLeft)
	local _, _, _, _, dtype, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)

	if(icon.debuff) then
		if(not UnitIsFriend("player", unit) and icon.owner ~= "player" and icon.owner ~= "vehicle") then
			icon:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
			icon.icon:SetDesaturated(true)
		else
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			icon:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			icon.icon:SetDesaturated(false)
		end
	end
	
	if duration and duration > 0 then
		if TukuiDB["unitframes"].auratimer == true then
			icon.remaining:Show()
		else
			icon.remaining:Hide()
		end
	else
		icon.remaining:Hide()
	end
 
	icon.duration = duration
	icon.timeLeft = expirationTime
	icon.first = true
	icon:SetScript("OnUpdate", Createauratimer)
end
 
local HidePortrait = function(self, unit)
	if self.unit == "target" then
		if not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit) then
			self.Portrait:SetAlpha(0)
		else
			self.Portrait:SetAlpha(1)
		end
	end
end

local function ShowThreat(self, event, unit)
	if (self.unit ~= unit) then return end
	local status = UnitThreatSituation(unit)
	if status and status > 1 then
		r, g, b = GetThreatStatusColor(status)
		self.FrameBackdrop:SetBackdropBorderColor(r, g, b)
	else
		self.FrameBackdrop:SetBackdropBorderColor(0, 0, 0)
	end
end

local PostUpdateCast = function (self, event, unit)
	if self.Castbar.interrupt then
		self.Castbar:SetStatusBarColor(1, 0, 0, 0.5)
	else
		self.Castbar:SetStatusBarColor(0.31, 0.45, 0.63, 0.5)
	end
end

local SpellCastInterruptable = function(self, event, unit)
	if self.unit ~= unit then return end

	if event == 'UNIT_SPELLCAST_NOT_INTERRUPTABLE' then
		self.Castbar:SetStatusBarColor(1, 0, 0, 0.5)
	else
		self.Castbar:SetStatusBarColor(0,31, 0.45, 0.63, 0.5)
	end
end

------------------------------------------------------------------------
--	Layout Style
------------------------------------------------------------------------

local SetStyle = function(self, unit)
	self.menu = Menu
	self.colors = colors
	self:RegisterForClicks("AnyUp")
	self:SetAttribute("type2", "menu")
	
	-- Right-click focus on arenaframes
	if (unit and unit:find("arena%d")) then
		self:SetAttribute("type2", "focus")
	end

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)
	self.Health = CreateFrame("StatusBar", self:GetName().."_Health", self)
	self.Health:SetFrameLevel(5)
	
	self.FrameBackdrop = CreateFrame("Frame", nil, self)
	self.FrameBackdrop:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 3)
	self.FrameBackdrop:SetFrameStrata("BACKGROUND")
	self.FrameBackdrop:SetBackdrop {
	  edgeFile = glowTex, edgeSize = 3,
	  insets = {left = 0, right = 0, top = 0, bottom = 0}
	}
	self.FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
	self.FrameBackdrop:SetBackdropBorderColor(0, 0, 0)
	self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 3, -3)
	
	self.Health:SetHeight((unit == "player" or unit == "target") and TukuiDB:Scale(20)  
	or self:GetParent():GetName():match("oUF_Party") and 37
		or (unit == "focus") and TukuiDB:Scale(19)
		or (unit == "targettarget" or unit == "focustarget") and TukuiDB:Scale(18)
		or (unit == "pet") and TukuiDB:Scale(12)
		or (unit and unit:find("arena%d")) and TukuiDB:Scale(22)
		or (unit and unit:find("boss%d")) and TukuiDB:Scale(22)
		or self:GetAttribute("unitsuffix") == "pet" and TukuiDB:Scale(10) or TukuiDB:Scale(16))
	
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(normTex)
	self.Health:GetStatusBarTexture():SetHorizTile(false)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	if TukuiDB["unitframes"].showsmooth == true then
		self.Health.Smooth = true
	end		
	self.Health.frequentUpdates = true
		
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(normTex)
    self.Health.bg:SetAlpha(1)
	self.Health.bg.multiplier = 0.3
	
	if TukuiDB["unitframes"].classcolor == true then
		self.Health.colorTapping = true
		self.Health.colorDisconnected = true
		self.Health.colorSmooth = true
		self.Health.colorReaction = true
		self.Health.colorClassPet = false    
		self.Health.colorClass = true
		self.Health.bg.multiplier = 0.3
	else
		self.Health.colorTapping = false
		self.Health.colorDisconnected = false
		self.Health.colorClass = false
		self.Health.colorSmooth = false
		self.Health:SetStatusBarColor(.3, .3, .3, 1)
		self.Health.bg:SetVertexColor(.1, .1, .1, 1)
	end
		
	self.Health.value = SetFontString(self.Health, font, (unit == "player" or unit == "target") and 12 or 12)

	self.Power = CreateFrame("StatusBar", self:GetName().."_Power", self)
	self.Power:SetHeight((unit == "player" or unit == "target") and TukuiDB:Scale(8) or TukuiDB:Scale(5))
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -TukuiDB.mult)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
	self.Power:SetStatusBarTexture(normTex)
	if (unit and unit:find("arena%d")) or (unit and unit:find("boss%d")) then
		self.Power:SetHeight(6)
	end

	self.Power.frequentUpdates = true
	if TukuiDB["unitframes"].showsmooth == true then
		self.Power.Smooth = true
	end
	self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(normTex)
	self.Power.bg:SetAlpha(1)
	self.Power.bg.multiplier = 0.1
	
	self.Power.colorTapping = true
	self.Power.colorDisconnected = true
	self.Power.colorClass = true
	self.Power.colorReaction = true
	if TukuiDB["unitframes"].classcolor == true then
		self.Power.colorPower = true
		self.Power.bg.multiplier = 0.4
	end
	
	self.Power.value = SetFontString(self.Power, font, (unit == "player" or unit == "target") and 12 or 12)
	
	------------------------------------------------------------------------
	--	Panels, text infos and Background!
	------------------------------------------------------------------------
	
	self.panel = CreateFrame("Frame", nil, self)
	
	if unit == "player" or unit == "target" then
		if TukuiDB["unitframes"].charportrait == true then
			TukuiDB:CreatePanel(self.panel, 186-34, 21, "TOP", self.Power, "BOTTOM", 0, TukuiDB:Scale(-1))
		else
			TukuiDB:CreatePanel(self.panel, 186, 21, "TOP", self.Power, "BOTTOM", 0, TukuiDB:Scale(-1))
		end
		self.panel:SetFrameLevel(2)
		self.panel:SetFrameStrata("MEDIUM")
		self.panel:SetBackdropBorderColor(unpack(TukuiDB["media"].altbordercolor))
		
		self.Health.value = SetFontString(self.panel, font, 12)
		self.Health.value:SetPoint("RIGHT", self.panel, "RIGHT", -4, 1)
		
		if (unit == "player") or (unit == "target" and TukuiDB["unitframes"].targetpowerpvponly == true) or (unit == "target" and TukuiDB["unitframes"].targetpowerpvponly == false) then
			self.Power.value = SetFontString(self.panel, font, (unit == "player" or unit == "target") and 12 or 12)
			self.Power.value:SetPoint("LEFT", self.panel, "LEFT", 4, 1)
		end
		
		if unit ~= "player" then
			self.Info = SetFontString(self.panel, font, 12)
			self.Info:SetPoint("LEFT", self.panel, "LEFT", 4, 1)
			self:Tag(self.Info, "[GetNameColor][NameLong] [DiffColor][level] [shortclassification]")
		end
	elseif unit == "targettarget" or unit == "focustarget" then		
		self.Info = SetFontString(self.Health, font, 12, "OUTLINE")
		self.Info:SetPoint("CENTER", self.Health, "CENTER", 0, TukuiDB.mult)
		self:Tag(self.Info, "[GetNameColor][NameMedium]")
	elseif unit == "pet" then		
		self.Info = SetFontString(self.Health, font, 12, "OUTLINE")
		self.Info:SetPoint("CENTER", self, "CENTER", 0, TukuiDB.mult)
		self:Tag(self.Info, "[GetNameColor][NameLong] [DiffColor][level] [shortclassification]")
	elseif unit =="focus" then
		self.FrameBackdrop:SetAlpha(0)
		self.Health.bg.multiplier = 0.13
		
		self.Health.value = SetFontString(self.Health, font,12, "OUTLINE")
		self.Health.value:SetPoint("RIGHT",self.Health,"RIGHT", -6, .5)
		
		self.Info = SetFontString(self.Health, font, 12, "OUTLINE")
		self.Info:SetPoint("LEFT",self.Health,"LEFT", 6, .5)
		self:Tag(self.Info, "[GetNameColor][NameLong]")
	elseif (unit and unit:find("arena%d")) then
		self.Health.value = SetFontString(self.Health, font,12, "OUTLINE")
		self.Health.value:SetPoint("LEFT", 2, 1)
		self.Power.value = SetFontString(self.Health, font, 12, "OUTLINE")
		self.Power.value:SetPoint("RIGHT", -2, 1)	

		self.Info = SetFontString(self.Health, font, 12, "OUTLINE")
		self.Info:SetPoint("CENTER", 0, 1)
		self:Tag(self.Info, "[GetNameColor][NameLong]")
	elseif (unit and unit:find("boss%d")) then
		self.Health.value = SetFontString(self.Health, font,12, "OUTLINE")
		self.Health.value:SetPoint("RIGHT", -6, 1)
		
		self.Info = SetFontString(self.Health, font, 12, "OUTLINE")
		self.Info:SetPoint("LEFT", 6, 1)
		self:Tag(self.Info, "[GetNameColor][NameLong]")
	elseif (self:GetParent():GetName():match"oUF_MainTank" or self:GetParent():GetName():match"oUF_MainAssist") then
		self.Info = SetFontString(self.Health, font, 12, "OUTLINE")
		self.Info:SetPoint("CENTER", 0, 1)
		self:Tag(self.Info, "[GetNameColor][NameShort]")
	else
		self.Health.value:Hide()
		self.Power.value:Hide()
		
		self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4.5, -4.5)
		self.Info:SetPoint("CENTER", 1, 1)
		self:Tag(self.Info, "[NameMedium]")
	end

	
	if unit == "player" then	
		self.Combat = self.Health:CreateTexture(nil, "OVERLAY")
		self.Combat:SetHeight(19)
		self.Combat:SetWidth(19)
		self.Combat:SetPoint("LEFT",0,1)
		self.Combat:SetVertexColor(0.69, 0.31, 0.31)

		self.FlashInfo = CreateFrame("Frame", "FlashInfo", self)
		self.FlashInfo:SetScript("OnUpdate", UpdateManaLevel)
		self.FlashInfo.parent = self
		self.FlashInfo:SetToplevel(true)
		self.FlashInfo:SetAllPoints(self.panel)

		self.FlashInfo.ManaLevel = SetFontString(self.FlashInfo, font, 12)
		self.FlashInfo.ManaLevel:SetPoint("CENTER", self.panel, "CENTER", 0, 1)
				
		self.Status = SetFontString(self.panel, font, 12)
		self.Status:SetPoint("CENTER", self.panel, "CENTER", 0, 1)
		self.Status:SetTextColor(0.69, 0.31, 0.31, 0)
		self:Tag(self.Status, "[pvp]")
	
		self:SetScript("OnEnter", function(self) self.FlashInfo.ManaLevel:Hide() self.Status:SetAlpha(1); UnitFrame_OnEnter(self) end)
		self:SetScript("OnLeave", function(self) self.FlashInfo.ManaLevel:Show() self.Status:SetAlpha(0); UnitFrame_OnLeave(self) end)

		------------------------------------------------------------------------
		--	Runes 
		------------------------------------------------------------------------	
	
		if class == "DEATHKNIGHT" and TukuiDB["unitframes"].runebar == true then
			self.Runes = CreateFrame("Frame", nil, self)
			self.Runes:SetPoint("BOTTOMLEFT",self,"TOPLEFT",0,0)
			self.Runes:SetHeight(TukuiDB:Scale(8))
			self.Runes:SetWidth(TukuiDB:Scale(186))
			self.Runes:SetBackdrop(backdrop)
			self.Runes:SetBackdropColor(0, 0, 0)
			self.Runes.anchor = "TOPLEFT"
			self.Runes.growth = "RIGHT"
			self.Runes.height = TukuiDB:Scale(7)
			self.Runes.spacing = TukuiDB.mult
			self.Runes.width = TukuiDB:Scale(181) / 6

			for i = 1, 6 do
				self.Runes[i] = CreateFrame('StatusBar', nil, self.Runes)
				self.Runes[i]:SetStatusBarTexture(normTex)
				self.Runes[i]:SetStatusBarColor(unpack(runeloadcolors[i]))
			end
			
			self.Runes.FrameBackdrop = CreateFrame("Frame", nil, self.Runes)
			self.Runes.FrameBackdrop:SetPoint("TOPLEFT", self.Runes, "TOPLEFT", -3.5, 3)
			self.Runes.FrameBackdrop:SetPoint("BOTTOMRIGHT", self.Runes, "BOTTOMRIGHT", 3.5, -3)
			self.Runes.FrameBackdrop:SetFrameStrata("BACKGROUND")
			self.Runes.FrameBackdrop:SetBackdrop {
				edgeFile = glowTex, edgeSize = 5,
				insets = {left = 3, right = 3, top = 3, bottom = 3}
			}
			self.Runes.FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
			self.Runes.FrameBackdrop:SetBackdropBorderColor(0, 0, 0)
		end

		------------------------------------------------------------------------
		--	Extra condition (druid mana in cat and bear form)
		------------------------------------------------------------------------

		if class == "DRUID" then
			CreateFrame("Frame"):SetScript("OnUpdate", function() UpdateDruidMana(self) end)
			self.DruidMana = SetFontString(self.Health, font, 12)
			self.DruidMana:SetTextColor(1, 0.49, 0.04)
		end
	end

	------------------------------------------------------------------------
	--	Experience / reputation
	------------------------------------------------------------------------	

	if unit == "player" or unit =="pet" then
			self.Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self.Power)
			self.Experience:SetStatusBarTexture(normTex)
			self.Experience:SetStatusBarColor(0, 0.4, 1, 0.6)
			self.Experience:SetBackdrop(backdrop)
			self.Experience:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
			self.Experience:SetWidth(self.panel:GetWidth() - TukuiDB:Scale(4))
			self.Experience:SetHeight(self.panel:GetHeight() - TukuiDB:Scale(4))
			self.Experience:SetPoint("TOPLEFT", self.panel, TukuiDB:Scale(2), TukuiDB:Scale(-2))
			self.Experience:SetPoint("BOTTOMRIGHT", self.panel, TukuiDB:Scale(-2), TukuiDB:Scale(2))
			self.Experience:SetFrameLevel(10)
			self.Experience:SetAlpha(0)
			
			self.Experience:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
			self.Experience:HookScript("OnLeave", function(self) self:SetAlpha(0) end)

			self.Experience.Tooltip = true
			
			if unit == "player" and UnitLevel("player") ~= MAX_PLAYER_LEVEL then			
				self.Experience.Rested = CreateFrame('StatusBar', nil, self)
				self.Experience.Rested:SetParent(self.Experience)
				self.Experience.Rested:SetAllPoints(self.Experience)
				self.Resting = self.Experience:CreateTexture(nil, "OVERLAY")
				self.Resting:SetHeight(28)
				self.Resting:SetWidth(28)
				self.Resting:SetPoint("LEFT", -18, 68)
				self.Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
				self.Resting:SetTexCoord(0, 0.5, 0, 0.421875)
			end
	end

	if unit == "player" then
		if UnitLevel("player") == MAX_PLAYER_LEVEL then
			self.Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self.Power)
			self.Reputation:SetStatusBarTexture(normTex)
			self.Reputation:SetBackdrop(backdrop)
			self.Reputation:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
			self.Reputation:SetWidth(self.panel:GetWidth() - TukuiDB:Scale(4))
			self.Reputation:SetHeight(self.panel:GetHeight() - TukuiDB:Scale(4))
			self.Reputation:SetPoint("TOPLEFT", self.panel, TukuiDB:Scale(2), TukuiDB:Scale(-2))
			self.Reputation:SetPoint("BOTTOMRIGHT", self.panel, TukuiDB:Scale(-2), TukuiDB:Scale(2))
			self.Reputation:SetFrameLevel(10)
			self.Reputation:SetAlpha(0)

			self.Reputation:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
			self.Reputation:HookScript("OnLeave", function(self) self:SetAlpha(0) end)

			self.Reputation.PostUpdate = UpdateReputationColor
			self.Reputation.Tooltip = true
		end
	end
	
	------------------------------------------------------------------------
	--   Threat Bar (this idea is from Zakriel)
	------------------------------------------------------------------------
	
	-- since t9, added a condition to threat bar, generally we don't care
	-- about this bar when levelling a character, so bar only enabled when in group.
	
	if (TukuiDB["unitframes"].showthreat == true) then
	   if (unit == "player") then 
			self.ThreatBar = CreateFrame("StatusBar", self:GetName()..'_ThreatBar', TukuiInfoLeft)
			self.ThreatBar:SetPoint("TOPLEFT", TukuiInfoLeft, TukuiDB:Scale(2), TukuiDB:Scale(-2))
			self.ThreatBar:SetPoint("BOTTOMRIGHT", TukuiInfoLeft, TukuiDB:Scale(-2), TukuiDB:Scale(2))
		  
			self.ThreatBar:SetStatusBarTexture(normTex)
			self.ThreatBar:GetStatusBarTexture():SetHorizTile(false)
			self.ThreatBar:SetBackdrop(backdrop)
			self.ThreatBar:SetBackdropColor(0, 0, 0, 0)
	   
			self.ThreatBar.Text = SetFontString(self.ThreatBar, font2, 12)
			self.ThreatBar.Text:SetPoint("RIGHT", self.ThreatBar, "RIGHT", -30, 0 )
	
			self.ThreatBar.Title = SetFontString(self.ThreatBar, font2, 12)
			self.ThreatBar.Title:SetText(tukuilocal.unitframes_ouf_threattext)
			self.ThreatBar.Title:SetPoint("LEFT", self.ThreatBar, "LEFT", 30, 0 )
				  
			self.ThreatBar.bg = self.ThreatBar:CreateTexture(nil, 'BORDER')
			self.ThreatBar.bg:SetAllPoints(self.ThreatBar)
			self.ThreatBar.bg:SetTexture(0.1,0.1,0.1)
	   
			self.ThreatBar.useRawThreat = false
	   end
	end
	
	------------------------------------------------------------------------
	--   Totems
	------------------------------------------------------------------------   

    if class == "SHAMAN" and unit == "player" and TukuiDB["unitframes"].totembar == true then
        self.TotemBar = {}
		self.TotemBar.Destroy = true
            for i = 1, 4 do
                self.TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
				if (i == 1) then
                   self.TotemBar[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 1)
                else
                   self.TotemBar[i]:SetPoint("TOPLEFT", self.TotemBar[i-1], "TOPRIGHT", 1, 0)
                end
                self.TotemBar[i]:SetStatusBarTexture(normTex)
                self.TotemBar[i]:SetHeight(TukuiDB:Scale(8))
                self.TotemBar[i]:SetWidth(TukuiDB:Scale(183) / 4)
                self.TotemBar[i]:SetBackdrop(backdrop)
                self.TotemBar[i]:SetBackdropColor(0, 0, 0)
                self.TotemBar[i]:SetMinMaxValues(0, 1)

                self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
                self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
                self.TotemBar[i].bg:SetTexture(normTex)
                self.TotemBar[i].bg.multiplier = 0.6
                				
				self.TotemBar[i].FrameBackdrop = CreateFrame("Frame", nil, self.TotemBar[i])
				self.TotemBar[i].FrameBackdrop:SetPoint("TOPLEFT", self.TotemBar[i], "TOPLEFT", -3, 3)
				self.TotemBar[i].FrameBackdrop:SetPoint("BOTTOMRIGHT", self.TotemBar[i], "BOTTOMRIGHT", 3, -3)
				self.TotemBar[i].FrameBackdrop:SetFrameStrata("BACKGROUND")
				self.TotemBar[i].FrameBackdrop:SetBackdrop {
					edgeFile = glowTex, edgeSize = 4,
					insets = {left = 3, right = 3, top = 3, bottom = 3}
				}
				self.TotemBar[i].FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
				self.TotemBar[i].FrameBackdrop:SetBackdropBorderColor(0, 0, 0)
            end
    end

	------------------------------------------------------------------------
	--	Auras
	------------------------------------------------------------------------	
	
	if unit == "player" or unit == "focus" or unit == "target" or unit == "targettarget" or (unit and unit:find("arena%d")) or (unit and unit:find("boss%d")) then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetHeight(21.5)
		self.Debuffs:SetWidth(186)
		self.Debuffs.size = 21.5
		self.Debuffs.spacing = 2
		self.Debuffs.num = 24
		self.Debuffs.numDebuffs = 24

		self.Buffs = CreateFrame("Frame", nil, self)		
		self.Buffs:SetHeight(21.5)
		self.Buffs:SetWidth(186)
		self.Buffs.size = 21.5
		self.Buffs.spacing = 2
		self.Buffs.num = 8
		self.Buffs.numBuffs = 8
		
			if (unit and unit:find("arena%d")) or (unit and unit:find("boss%d")) then
				if (unit and unit:find("boss%d")) then
					self.Buffs:SetPoint("RIGHT", self, "LEFT", -4, 0)
					self.Buffs.size = 26
					self.Buffs.num = 3
					self.Buffs.numBuffs = 3
					self.Buffs.initialAnchor = "RIGHT"
					self.Buffs["growth-x"] = "LEFT"
				end
				self.Debuffs.num = 5
				self.Debuffs.size = 26
				self.Debuffs:SetPoint('LEFT', self, 'RIGHT', 4, 0)
				self.Debuffs.initialAnchor = "LEFT"
				self.Debuffs["growth-x"] = "RIGHT"
				self.Debuffs["growth-y"] = "DOWN"
				self.Debuffs:SetHeight(26)
				self.Debuffs:SetWidth(200)
				self.Debuffs.onlyShowPlayer = TukuiDB["unitframes"].playerdebuffsonly
			end	
						
			if unit == "focus" and TukuiDB["unitframes"].focusdebuffs == true then
				self.Debuffs:SetHeight(26)
				self.Debuffs:SetWidth(TukuiDB["panels"].tinfowidth - 10)
				self.Debuffs.size = 26
				self.Debuffs.spacing = 2
				self.Debuffs.num = 40
				self.Debuffs.numDebuffs = 40
							
				self.Debuffs:SetPoint("TOPRIGHT", self, "TOPRIGHT", 2, 38)
				self.Debuffs.initialAnchor = "TOPRIGHT"
				self.Debuffs["growth-y"] = "UP"
				self.Debuffs["growth-x"] = "LEFT"
			end
			
			if unit == "player" and TukuiDB["unitframes"].playerauras == true then
				if (class == "SHAMAN" and TukuiDB["unitframes"].totembar == true) or (class == "DEATHKNIGHT" and TukuiDB["unitframes"].runebar == true) then
					self.Buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 26+8)
				else			
					self.Buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 26)
				end
				self.Buffs.initialAnchor = "TOPLEFT"
				self.Buffs["growth-y"] = "UP"
				
				self.Debuffs:SetPoint("BOTTOMLEFT", self.Buffs, "TOPLEFT", -0, 2)
				self.Debuffs.initialAnchor = "TOPRIGHT"
				self.Debuffs["growth-y"] = "UP"
				self.Debuffs["growth-x"] = "LEFT"
			end
			
			if unit == "target" and TukuiDB["unitframes"].targetauras == true then
				self.Buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 26)
				self.Buffs.initialAnchor = "TOPLEFT"
				self.Buffs["growth-y"] = "UP"
				
				self.Debuffs:SetPoint("BOTTOMLEFT", self.Buffs, "TOPLEFT", -0, 2)
				self.Debuffs.initialAnchor = "TOPRIGHT"
				self.Debuffs["growth-y"] = "UP"
				self.Debuffs["growth-x"] = "LEFT"
				self.Debuffs.onlyShowPlayer = TukuiDB["unitframes"].playerdebuffsonly
	
				self.CPoints = {}
				self.CPoints.unit = PlayerFrame.unit
				for i = 1, 5 do
					self.CPoints[i] = self:CreateTexture(nil, "OVERLAY")
					self.CPoints[i]:SetHeight(12)
					self.CPoints[i]:SetWidth(12)
					self.CPoints[i]:SetTexture(bubbleTex)
					if i == 1 then
						self.CPoints[i]:SetPoint("TOPRIGHT", 15, 1.5)
						self.CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
					else
						self.CPoints[i]:SetPoint("TOP", self.CPoints[i-1], "BOTTOM", 1)
					end
				end
				self.CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
				self.CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
				self.CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
				self.CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
				self:RegisterEvent("UNIT_COMBO_POINTS", UpdateCPoints)
			end
					
			if (unit == "player" or unit == "target") and (TukuiDB["unitframes"].charportrait == true) then
				self.Portrait = CreateFrame("PlayerModel", nil, self)
				self.Portrait:SetFrameLevel(8)
				self.Portrait:SetHeight(51)
				self.Portrait:SetWidth(33)
				self.Portrait:SetAlpha(1)
				if unit == "player" then
					self.Health:SetPoint("TOPLEFT", 34,0)
					self.Health:SetPoint("TOPRIGHT")
					self.Portrait:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -34,0)
				elseif unit == "target" then
					self.Health:SetPoint("TOPLEFT")
					self.Health:SetPoint("TOPRIGHT", -34,0)
					self.Portrait:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT", 34,0)
				end
				table.insert(self.__elements, HidePortrait)
			end
	end

	------------------------------------------------------------------------
	--	Castbar
	------------------------------------------------------------------------	

	if TukuiDB["unitframes"].unitcastbar == true then
		self.Castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
		self.Castbar:SetStatusBarTexture(normTex)
		self.Castbar:SetStatusBarColor(0.31, 0.45, 0.63, 0.5)

		self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
		self.Castbar.bg:SetAllPoints(self.Castbar)
		self.Castbar.bg:SetTexture(normTex)
		self.Castbar.bg:SetVertexColor(0.15, 0.15, 0.15)
								
		if unit == "player"  or unit == "target" then
			self.Castbar:SetFrameLevel(6)
			self.Castbar:SetPoint("TOPLEFT", self.panel, TukuiDB:Scale(2), TukuiDB:Scale(-2))
			self.Castbar:SetPoint("BOTTOMRIGHT", self.panel, TukuiDB:Scale(-2), TukuiDB:Scale(2))			
		elseif unit == "focus" then
			self.Castbar:SetFrameLevel(6)
			self.Castbar:SetHeight(TukuiDB:Scale(20))
			self.Castbar:SetWidth(TukuiDB:Scale(240))
			self.Castbar:SetPoint("CENTER", UIParent, "CENTER", 0, 250)
						
			self.Castbar.bg = CreateFrame("Frame", nil, self.Castbar)
			TukuiDB:SetTemplate(self.Castbar.bg)
			self.Castbar.bg:SetPoint("TOPLEFT", TukuiDB:Scale(-2), TukuiDB:Scale(2))
			self.Castbar.bg:SetPoint("BOTTOMRIGHT", TukuiDB:Scale(2), TukuiDB:Scale(-2))
			self.Castbar.bg:SetFrameLevel(0)
			
			self.CastbarBackdrop = CreateFrame("Frame", nil, self)
			self.CastbarBackdrop:SetPoint("TOPLEFT", self.Castbar, "TOPLEFT", -6, 6)
			self.CastbarBackdrop:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMRIGHT", 6, -6)
			self.CastbarBackdrop:SetParent(self.Castbar)
			self.CastbarBackdrop:SetFrameStrata("BACKGROUND")
			self.CastbarBackdrop:SetFrameLevel(0)
			self.CastbarBackdrop:SetBackdrop({
				edgeFile = glowTex, edgeSize = 4,
				insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
			self.CastbarBackdrop:SetBackdropColor(0, 0, 0, 0)
			self.CastbarBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
									
		elseif(unit and unit:find("arena%d")) or (unit and unit:find("boss%d")) then
			self.Castbar:SetFrameLevel(6)
			self.Castbar:SetHeight(6)
			self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
			self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
		else
			self.Castbar:Hide()
		end

		if unit == "player" or unit == "target" or unit == "focus" or (unit and unit:find("arena%d")) or (unit and unit:find("boss%d")) then
			if unit == "player" or unit == target then
				self.Castbar.Time = SetFontString(self.Castbar, font, 12)
				self.Castbar.Time:SetPoint("RIGHT", self.panel, "RIGHT", -4, 1)
				self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
				self.Castbar.Time:SetJustifyH("RIGHT")
				self.Castbar.CustomTimeText = FormatCastbarTime

				self.Castbar.Text = SetFontString(self.Castbar, font, 12)
				self.Castbar.Text:SetPoint("LEFT", self.panel, "LEFT", 4, 1)
				self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			else
				self.Castbar.Time = SetFontString(self.Castbar, font, 12)
				self.Castbar.Time:SetPoint("RIGHT", -2, 1)
				self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
				self.Castbar.Time:SetJustifyH("RIGHT")
				self.Castbar.CustomTimeText = FormatCastbarTime

				self.Castbar.Text = SetFontString(self.Castbar, font, 12)
				self.Castbar.Text:SetPoint("LEFT", 3, 1)
				self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -2, 2)
				self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			end
			
			if TukuiDB["unitframes"].cbicons == true then
				self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
				self.Castbar.Button:SetHeight(TukuiDB:Scale(26))
				self.Castbar.Button:SetWidth(TukuiDB:Scale(26))
				TukuiDB:SetTemplate(self.Castbar.Button)

				self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
				self.Castbar.Icon:SetPoint("TOPLEFT", self.Castbar.Button, TukuiDB:Scale(2), TukuiDB:Scale(-2))
				self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar.Button, TukuiDB:Scale(-2), TukuiDB:Scale(2))
				self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			
				if unit == "player" then
					if TukuiDB["unitframes"].charportrait == true then
						self.Castbar.Button:SetPoint("LEFT", -82.5, 26.5)
					else
						self.Castbar.Button:SetPoint("LEFT", -46.5, 26.5)
					end
				elseif unit == "target" then
					if TukuiDB["unitframes"].charportrait == true then
						self.Castbar.Button:SetPoint("RIGHT", 82.5, 26.5)
					else
						self.Castbar.Button:SetPoint("RIGHT", 46.5, 26.5)
					end
				elseif unit == "focus" then
					self.Castbar.Button:SetHeight(TukuiDB:Scale(34))
					self.Castbar.Button:SetWidth(TukuiDB:Scale(34))
					TukuiDB:SetTemplate(self.Castbar.Button)
					self.Castbar.Button:SetPoint("CENTER", 0, 40)					
				end

				self.IconBackdrop = CreateFrame("Frame", nil, self)
				self.IconBackdrop:SetPoint("TOPLEFT", self.Castbar.Button, "TOPLEFT", -4, 4)
				self.IconBackdrop:SetPoint("BOTTOMRIGHT", self.Castbar.Button, "BOTTOMRIGHT", 4, -4)
				self.IconBackdrop:SetParent(self.Castbar)
				self.IconBackdrop:SetBackdrop({
					edgeFile = glowTex, edgeSize = 4,
					insets = {left = 3, right = 3, top = 3, bottom = 3}
				})
				self.IconBackdrop:SetBackdropColor(0, 0, 0, 0)
				self.IconBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
			end
		end
		
		if unit == "player" and TukuiDB["unitframes"].cblatency == true then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.SafeZone:SetTexture(normTex)
			self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		end
		
		if unit == 'target' or unit == 'focus' then
			self.PostCastStart = PostUpdateCast
			self.PostChannelStart = PostUpdateCast

			self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTABLE', SpellCastInterruptable)
			self:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTABLE', SpellCastInterruptable)
		end
	end

	------------------------------------------------------------------------
	--	Raid or Party Leader
	------------------------------------------------------------------------

	if not unit or unit == "player" then
		self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetHeight(14)
		self.Leader:SetWidth(14)
		self.Leader:SetPoint("TOPLEFT", 2, 8)
	end
		
	------------------------------------------------------------------------
	--      Master Looter
	------------------------------------------------------------------------

    if not unit or unit == "player" then
        self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY")
        self.MasterLooter:SetHeight(14)
        self.MasterLooter:SetWidth(14)
        local MLAnchorUpdate = function (self)
            if self.Leader:IsShown() then
                self.MasterLooter:SetPoint("TOPLEFT", 14, 8)
            else
                self.MasterLooter:SetPoint("TOPLEFT", 2, 8)
            end
        end
        self:RegisterEvent("PARTY_LEADER_CHANGED", MLAnchorUpdate)
        self:RegisterEvent("PARTY_MEMBERS_CHANGED", MLAnchorUpdate)
    end

	------------------------------------------------------------------------
	--      Combat Feedback Text
	------------------------------------------------------------------------
	
	if (unit == "player" or unit == "target") and (TukuiDB["unitframes"].combatfeedback == true) then
			self.CombatFeedbackText = SetFontString(self.Health, font, 14, "OUTLINE")
			self.CombatFeedbackText:SetPoint("CENTER", 0, 1)
			self.CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
	end
	------------------------------------------------------------------------
	--	Arena Trinket
	------------------------------------------------------------------------

	if TukuiDB["arena"].unitframes == true then
		if not IsAddOnLoaded("Gladius") then
			if (unit and unit:find('arena%d') and (not unit:find("arena%dtarget"))) then
				self.Trinketbg = CreateFrame("Frame", nil, self)
				self.Trinketbg:SetHeight(26)
				self.Trinketbg:SetWidth(26)
				self.Trinketbg:SetPoint("RIGHT", self, "LEFT", -6, 0)				
				TukuiDB:SetTemplate(self.Trinketbg)
				self.Trinketbg:SetFrameLevel(0)
				
				self.Trinket = CreateFrame("Frame", nil, self.Trinketbg)
				self.Trinket:SetAllPoints(self.Trinketbg)
				self.Trinket:SetPoint("TOPLEFT", self.Trinketbg, TukuiDB:Scale(2), TukuiDB:Scale(-2))
				self.Trinket:SetPoint("BOTTOMRIGHT", self.Trinketbg, TukuiDB:Scale(-2), TukuiDB:Scale(2))
				self.Trinket:SetFrameLevel(1)
				self.Trinket.trinketUseAnnounce = true
			end
		end
	end
	
	------------------------------------------------------------------------
	--	Unitframes Width/Height
	------------------------------------------------------------------------

	if unit == "player" or unit == "target" then
		self:SetAttribute("initial-height", TukuiDB:Scale(51))
		self:SetAttribute("initial-width", TukuiDB:Scale(186))
	elseif unit == "targettarget" or unit == "focustarget" then
		self:SetAttribute("initial-height", TukuiDB:Scale(18))
		self:SetAttribute("initial-width", TukuiDB:Scale(186))
        self.Power:Hide()        
	elseif unit == "focus" then
		self:SetAttribute("initial-height", TukuiInfoRight:GetHeight() - TukuiDB:Scale(4))
		self:SetAttribute("initial-width", TukuiInfoRight:GetWidth() - TukuiDB:Scale(4))
		self.Power:Hide()
	elseif unit == "pet" then
		self:SetAttribute("initial-height", TukuiDB:Scale(18))
		self:SetAttribute("initial-width", TukuiDB:Scale(186))
	elseif (unit and unit:find("arena%d")) or (unit and unit:find("boss%d")) then
		self:SetAttribute("initial-height", TukuiDB:Scale(29))
		self:SetAttribute("initial-width", TukuiDB:Scale(200))
	elseif(self:GetParent():GetName():match"oUF_MainTank" or self:GetParent():GetName():match"oUF_MainAssist") then
		if TukuiDB["unitframes"].t_mt_power == true then
			self.Power:SetHeight(2)
			self.Power.value:Hide()
			self.Health:SetHeight(17)
		else
			self.Power:Hide()
			self.Health:SetHeight(20)
		end		
		self:SetAttribute("initial-height", TukuiDB:Scale(20))
		self:SetAttribute("initial-width", TukuiDB:Scale(100))
	else
		self:SetAttribute("initial-height", TukuiDB:Scale(37))
		self:SetAttribute("initial-width", TukuiDB:Scale(250))		
	end
		
	------------------------------------------------------------------------
	--	RaidIcons
	------------------------------------------------------------------------

	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetHeight(14)
	self.RaidIcon:SetWidth(14)
	self.RaidIcon:SetPoint("TOP", 0, 8)
	
	------------------------------------------------------------------------
	-- LFD Roles
	------------------------------------------------------------------------

    if not unit or unit == "player" then
        self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
        self.LFDRole:SetHeight(6)
        self.LFDRole:SetWidth(6)
        self.LFDRole:SetPoint("TOPRIGHT", -2, -2)
    end
	
	self.outsideRangeAlpha = 0.3
	self.inRangeAlpha = 1
	self.SpellRange = true

	self.BarFade = false

	self.PostUpdateHealth = PostUpdateHealth
	self.PreUpdatePower = PreUpdatePower
	self.PostUpdatePower = PostUpdatePower
	self.PostCreateAuraIcon = createAura
	self.PostUpdateAuraIcon = updatedebuff
	
	if TukuiDB["unitframes"].playeraggro == true then
		self:RegisterEvent("PLAYER_TARGET_CHANGED", ShowThreat)
		self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", ShowThreat)
		self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", ShowThreat)
	end
	
	if TukuiDB["unitframes"].fadeufooc == true then
		local function fadeUnitframe()
			if(UnitAffectingCombat("player")) then
			  self:SetAlpha(1)
			else
			  self:SetAlpha(TukuiDB["unitframes"].fadeufoocalpha)
			end
		end

		self:RegisterEvent('UNIT_COMBAT', fadeUnitframe)
		self:RegisterEvent('UNIT_HAPPINESS', fadeUnitframe)
		self:RegisterEvent('UNIT_TARGET', fadeUnitframe)
		self:RegisterEvent('UNIT_FOCUS', fadeUnitframe)
		self:RegisterEvent('UNIT_HEALTH', fadeUnitframe)
		self:RegisterEvent('UNIT_POWER', fadeUnitframe)
		self:RegisterEvent('UNIT_ENERGY', fadeUnitframe)
		self:RegisterEvent('UNIT_RAGE', fadeUnitframe)
		self:RegisterEvent('UNIT_MANA', fadeUnitframe)
		self:RegisterEvent('UNIT_RUNIC_POWER', fadeUnitframe)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', fadeUnitframe)
		self:RegisterEvent('PLAYER_REGEN_ENABLED', fadeUnitframe)
		self:RegisterEvent('PLAYER_REGEN_DISABLED', fadeUnitframe)
	end
		
	return self
end

oUF:RegisterStyle("Tukz", SetStyle)
oUF:SetActiveStyle("Tukz")

oUF:Spawn("player", "oUF_Tukz_player"):SetPoint("BOTTOMLEFT", TukuiActionBarBackground, "TOPLEFT", 0,8+24)
oUF:Spawn("target", "oUF_Tukz_target"):SetPoint("BOTTOMRIGHT", TukuiActionBarBackground, "TOPRIGHT", 0,8+24)
oUF:Spawn("pet", "oUF_Tukz_pet"):SetPoint("BOTTOMLEFT", TukuiActionBarBackground, "TOPLEFT", 0,8)
oUF:Spawn("focus", "oUF_Tukz_focus"):SetPoint("CENTER", TukuiInfoRight, "CENTER")
oUF:Spawn("targettarget", "oUF_Tukz_targettarget"):SetPoint("BOTTOMRIGHT", TukuiActionBarBackground, "TOPRIGHT", 0,8)

if TukuiDB["unitframes"].showfocustarget == true then oUF:Spawn("focustarget", "oUF_Tukz_focustarget"):SetPoint("BOTTOM", 0, 280) end

if TukuiDB["arena"].unitframes == true then
	if not IsAddOnLoaded("Gladius") then
		local arena = {}
		for i = 1, 5 do
			arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
			if i == 1 then
				arena[i]:SetPoint("BOTTOM", UIParent, "BOTTOM", 252, 260)
			else
				arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 10)
			end
		end
	end
end

local party = oUF:Spawn("header", "oUF_PartyHide")
party:SetAttribute("showParty", false)

if TukuiDB["unitframes"].t_mt == true then
	local tank = oUF:Spawn("header", "oUF_MainTank")
	tank:SetManyAttributes("showRaid", true, "groupFilter", "MAINTANK", "yOffset", 5, "point" , "BOTTOM")
	tank:SetPoint("BOTTOM", UIParent, "BOTTOM", 500, 560)
	tank:SetAttribute("template", "oUF_tukzMtt")
	tank:Show()

	local assist = oUF:Spawn("header", "oUF_MainAssist")
	assist:SetManyAttributes("showRaid", true, "groupFilter", "MAINASSIST", "yOffset", 5, "point", "BOTTOM")
	assist:SetPoint("TOP", tank, "BOTTOM", 0, -30)
	assist:SetAttribute("template", "oUF_tukzMtt")
	assist:Show()
end

for i = 1,MAX_BOSS_FRAMES do
   local t_boss = _G["Boss"..i.."TargetFrame"]
   t_boss:UnregisterAllEvents()
   t_boss.Show = dummy
   t_boss:Hide()
   _G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
   _G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
end

if not IsAddOnLoaded("DXE") then
	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
	   boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
	   if i == 1 then
		  boss[i]:SetPoint("BOTTOM", UIParent, "BOTTOM", 252, 260)
	   else
		  boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 10)             
	   end
	end
end

--[[ testmode ]]
local testui = TestUI or function() end
TestUI = function()
	testui()
	UnitAura = function()
		-- name, rank, texture, count, dtype, duration, timeLeft, caster
		return 'Penancelol', 'Rank 2', 'Interface\\Icons\\Spell_Holy_Penance', random(5), 'Magic', 0, 0, "player"
	end
	if(oUF) then
		for i, v in pairs(oUF.units) do
			if(v.UNIT_AURA) then
				v:UNIT_AURA("UNIT_AURA", v.unit)
			end
		end
	end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"



