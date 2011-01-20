local ElvDB = ElvDB
local ElvCF = ElvCF

if not ElvCF["unitframes"].enable == true then return end
if IsAddOnLoaded("ElvUI_Dps_Layout") then return end

------------------------------------------------------------------------
--	Variables
------------------------------------------------------------------------

local db = ElvCF["unitframes"]
local font1 = ElvCF["media"].uffont
local font2 = ElvCF["media"].font
local normTex = ElvCF["media"].normTex
local glowTex = ElvCF["media"].glowTex

local backdrop = {
	bgFile = ElvCF["media"].blank,
	insets = {top = -ElvDB.mult, left = -ElvDB.mult, bottom = -ElvDB.mult, right = -ElvDB.mult},
}

local player_width
local player_height
local target_width
local target_height
local smallframe_width
local smallframe_height
local arenaboss_width
local arenaboss_height
local assisttank_width
local assisttank_height

--Offset of PowerBar for Player/Target
local powerbar_offset = ElvDB.Scale(ElvCF["unitframes"].poweroffset)

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	--Set Sizes
	player_width = ElvDB.Scale(ElvCF["framesizes"].playtarwidth)
	player_height = ElvDB.Scale(ElvCF["framesizes"].playtarheight)

	target_width = ElvDB.Scale(ElvCF["framesizes"].playtarwidth)
	target_height = ElvDB.Scale(ElvCF["framesizes"].playtarheight)

	smallframe_width = ElvDB.Scale(ElvCF["framesizes"].smallwidth)
	smallframe_height = ElvDB.Scale(ElvCF["framesizes"].smallheight)

	arenaboss_width = ElvDB.Scale(ElvCF["framesizes"].arenabosswidth)
	arenaboss_height = ElvDB.Scale(ElvCF["framesizes"].arenabossheight)

	assisttank_width = ElvDB.Scale(ElvCF["framesizes"].assisttankwidth)
	assisttank_height = ElvDB.Scale(ElvCF["framesizes"].assisttankheight)
	
	-- Set Colors
	self.colors = ElvDB.oUF_colors
	
	-- Register Frames for Click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- Setup Menu
	self.menu = ElvDB.SpawnMenu
	
	-- Update all elements on show
	self:HookScript("OnShow", ElvDB.updateAllElements)
	
	-- For Testing..
	--[[self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)]]
	
	------------------------------------------------------------------------
	--	Player
	------------------------------------------------------------------------
	if unit == "player" then
		local original_height = player_height
		local original_width = player_width
		
		-- Health Bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetWidth(original_width)
		health:SetHeight(original_height)
		if powerbar_offset ~= 0 then
			health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -powerbar_offset, powerbar_offset)
		else
			health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -powerbar_offset, original_height * 0.35)	
		end
		health:SetStatusBarTexture(normTex)
		self.health = health
		
		-- Border for HealthBar
		local FrameBorder = CreateFrame("Frame", nil, health)
		FrameBorder:SetPoint("TOPLEFT", health, "TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
		ElvDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		ElvDB.CreateShadow(self.FrameBorder)
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
	
		-- Health Bar Background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		health.value = ElvDB.SetFontString(health, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
		health.value:SetPoint("RIGHT", health, "RIGHT", ElvDB.Scale(-4), ElvDB.Scale(1))
		health.PostUpdate = ElvDB.PostUpdateHealth
		self.Health = health
		self.Health.bg = healthBG
		health.frequentUpdates = true
		
		-- Smooth Bar Animation
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		-- Setup Colors
		if db.classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(ElvCF["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(ElvCF["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true	
			health.bg.multiplier = 0.3			
		end
		health.colorDisconnected = false

		-- Power Frame Border
		local PowerFrame = CreateFrame("Frame", nil, self)
		if powerbar_offset ~= 0 then
			PowerFrame:SetHeight(original_height)
			PowerFrame:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", powerbar_offset, -powerbar_offset)
			PowerFrame:SetWidth(original_width)
			PowerFrame:SetFrameLevel(self:GetFrameLevel() - 1)
		else
			PowerFrame:SetHeight(original_height * 0.35)
			PowerFrame:SetPoint("TOP", self.Health, "BOTTOM", 0, -ElvDB.mult*3)
			PowerFrame:SetWidth(original_width + ElvDB.mult*4)
		end
		
	
		ElvDB.SetTemplate(PowerFrame)
		PowerFrame:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))	
		self.PowerFrame = PowerFrame
		if powerbar_offset ~= 0 then
			ElvDB.CreateShadow(self.PowerFrame)
		else
			self.FrameBorder.shadow:SetPoint("BOTTOMLEFT", self.PowerFrame, "BOTTOMLEFT", ElvDB.Scale(-4), ElvDB.Scale(-4))
		end
		
		-- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", ElvDB.mult*2, -ElvDB.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -ElvDB.mult*2, ElvDB.mult*2)
		power:SetStatusBarTexture(normTex)
		power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)
				
		-- Power Background
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		power.value = ElvDB.SetFontString(health, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
		power.value:SetPoint("LEFT", health, "LEFT", ElvDB.Scale(4), ElvDB.Scale(1))
		power.PreUpdate = ElvDB.PreUpdatePower
		power.PostUpdate = ElvDB.PostUpdatePower
		
		--Adjust player frame size
		player_width = player_width + powerbar_offset
		if powerbar_offset ~= 0 then
			player_height = player_height + powerbar_offset
		else
			player_height = player_height + PowerFrame:GetHeight()
		end
		
		self.Power = power
		self.Power.bg = powerBG
		
		-- Update the Power bar Frequently
		power.frequentUpdates = true
		
		-- Setup Power Colors
		power.colorDisconnected = true
		power.colorPower = true
		power.colorTapping = false
		power.colorDisconnected = true
		
		-- Smooth Animation
		if db.showsmooth == true then
			power.Smooth = true
		end
		
		-- Debuff Highlight (Overlays Health Bar)
		if ElvCF["unitframes"].debuffhighlight == true then
			local dbh = health:CreateTexture(nil, "OVERLAY", health)
			dbh:SetAllPoints(health)
			dbh:SetTexture(ElvCF["media"].normTex)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.4		
		end
		
		-- Portraits
		if (db.charportrait == true) then
			local PFrame = CreateFrame("Frame", nil, self)
			if powerbar_offset ~= 0 then
				PFrame:SetPoint('TOPRIGHT', self.Health,'TOPLEFT', ElvDB.Scale(-6), ElvDB.Scale(2))
				PFrame:SetPoint('BOTTOMRIGHT', self.Health,'BOTTOMLEFT', ElvDB.Scale(-6) - powerbar_offset, -powerbar_offset)
				PFrame:SetWidth(original_width/5)
			else
				PFrame:SetPoint('TOPRIGHT', self.Health,'TOPLEFT', ElvDB.Scale(-6), ElvDB.Scale(2))
				PFrame:SetPoint('BOTTOMRIGHT', self.Health,'BOTTOMLEFT', ElvDB.Scale(-6), ElvDB.Scale(-3) + -(original_height * 0.35))
				PFrame:SetWidth(original_width/5)
	
			end
			ElvDB.SetTemplate(PFrame)
			PFrame:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			self.PFrame = PFrame
			ElvDB.CreateShadow(self.PFrame)			
			local portrait = CreateFrame("PlayerModel", nil, PFrame)
			portrait:SetFrameLevel(2)
			
			--dont ask me why but the playerframe looks completely fucked when i set it how it should be..
			portrait:SetPoint('BOTTOMLEFT', PFrame, 'BOTTOMLEFT', ElvDB.Scale(1), ElvDB.Scale(2))		
			portrait:SetPoint('TOPRIGHT', PFrame, 'TOPRIGHT', ElvDB.Scale(-2), ElvDB.Scale(-2))	
			table.insert(self.__elements, ElvDB.HidePortrait)
		
			self.Portrait = portrait
			player_width = player_width + (PFrame:GetWidth() + ElvDB.Scale(6))
		end
			
		-- combat icon
		local Combat = health:CreateTexture(nil, "OVERLAY")
		Combat:SetHeight(ElvDB.Scale(19))
		Combat:SetWidth(ElvDB.Scale(19))
		Combat:SetPoint("CENTER",0,7)
		Combat:SetVertexColor(0.69, 0.31, 0.31)
		self.Combat = Combat

		-- custom info (low mana warning)
		FlashInfo = CreateFrame("Frame", "FlashInfo", self)
		FlashInfo:SetScript("OnUpdate", ElvDB.UpdateManaLevel)
		FlashInfo.parent = self
		FlashInfo:SetToplevel(true)
		FlashInfo:SetAllPoints(health)
		FlashInfo.ManaLevel = ElvDB.SetFontString(FlashInfo, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
		FlashInfo.ManaLevel:SetPoint("CENTER", health, "CENTER", 0, ElvDB.Scale(-5))
		self.FlashInfo = FlashInfo
		
		local PvP = health:CreateFontString(nil, "OVERLAY")
		PvP:SetFont(font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
		PvP:SetPoint("CENTER", health, "CENTER", 0, ElvDB.Scale(-5))
		PvP:SetTextColor(0.69, 0.31, 0.31)
		PvP:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
		PvP:Hide()
		self.PvP = PvP
		self.PvP.Override = ElvDB.dummy
		
		local PvPUpdate = CreateFrame("Frame", nil, self)
		PvPUpdate:SetScript("OnUpdate", function(self, elapsed) ElvDB.PvPUpdate(self:GetParent(), elapsed) end)
		
		self:SetScript("OnEnter", function(self) FlashInfo.ManaLevel:Hide() PvP:Show() UnitFrame_OnEnter(self) end)
		self:SetScript("OnLeave", function(self) FlashInfo.ManaLevel:Show() PvP:Hide() UnitFrame_OnLeave(self) end)
		
		-- leader icon
		local Leader = health:CreateTexture(nil, "OVERLAY")
		Leader:SetHeight(ElvDB.Scale(14))
		Leader:SetWidth(ElvDB.Scale(14))
		Leader:SetPoint("TOPLEFT", ElvDB.Scale(2), ElvDB.Scale(8))
		self.Leader = Leader
		
		-- master looter
		local MasterLooter = health:CreateTexture(nil, "OVERLAY")
		MasterLooter:SetHeight(ElvDB.Scale(14))
		MasterLooter:SetWidth(ElvDB.Scale(14))
		self.MasterLooter = MasterLooter
		self:RegisterEvent("PARTY_LEADER_CHANGED", ElvDB.MLAnchorUpdate)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", ElvDB.MLAnchorUpdate)
		
		-- experience bar on player via mouseover for player currently levelling a character
		if ElvDB.level ~= MAX_PLAYER_LEVEL then
			local Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self)
			Experience:SetStatusBarTexture(normTex)
			Experience:SetStatusBarColor(0, 0.4, 1, .8)
			Experience:SetWidth(original_width)
			Experience:SetHeight(ElvDB.Scale(5))
			Experience:SetFrameStrata("HIGH")
			if powerbar_offset ~= 0 then
				Experience:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + -ElvDB.Scale(5))
			else	
				Experience:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -ElvDB.Scale(8))
			end
			Experience.noTooltip = true
			Experience:EnableMouse(true)
			self.Experience = Experience

			
			Experience.Text = self.Experience:CreateFontString(nil, 'OVERLAY')
			Experience.Text:SetFont(font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
			Experience.Text:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
			Experience.Text:SetPoint('CENTER', self.Experience)
			Experience.Text:Hide()
			self.Experience.Text = Experience.Text
			self.Experience.PostUpdate = ElvDB.ExperienceText
			
			Experience:SetScript("OnEnter", function(self) if not InCombatLockdown() then Experience:SetHeight(ElvDB.Scale(20)) Experience.Text:Show() end end)
			Experience:SetScript("OnLeave", function(self) if not InCombatLockdown() then Experience:SetHeight(ElvDB.Scale(5)) Experience.Text:Hide() end end)
			if ElvCF["unitframes"].combat == true then
				Experience:HookScript("OnEnter", function(self) ElvDB.Fader(self, true, true) end)
				Experience:HookScript("OnLeave", function(self) ElvDB.Fader(self, false, true) end)
			end
			
			self.Experience.Rested = CreateFrame('StatusBar', nil, self.Experience)
			self.Experience.Rested:SetAllPoints(self.Experience)
			self.Experience.Rested:SetStatusBarTexture(normTex)
			self.Experience.Rested:SetStatusBarColor(1, 0, 1, 0.2)
			self.Experience.Rested:SetBackdrop(backdrop)
			self.Experience.Rested:SetBackdropColor(unpack(ElvCF["media"].backdropcolor))
			
			local Resting = Experience:CreateTexture(nil, "OVERLAY", Experience.Rested)
			Resting:SetHeight(22)
			Resting:SetWidth(22)
			Resting:SetPoint("CENTER", self.Health, "TOPLEFT", ElvDB.Scale(-3), ElvDB.Scale(6))
			Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
			Resting:SetTexCoord(0, 0.5, 0, 0.421875)
			Resting:Hide()
			self.Resting = Resting
			
			self.Experience.F = CreateFrame("Frame", nil, self.Experience)
			ElvDB.SetTemplate(self.Experience.F)
			self.Experience.F:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			self.Experience.F:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
			self.Experience.F:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
			self.Experience.F:SetFrameLevel(self.Experience:GetFrameLevel() - 1)
			self:RegisterEvent("PLAYER_UPDATE_RESTING", ElvDB.RestingIconUpdate)
		end
		
		-- reputation bar for max level character
		if ElvDB.level == MAX_PLAYER_LEVEL then
			local Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self)
			Reputation:SetStatusBarTexture(normTex)
			Reputation:SetBackdrop(backdrop)
			Reputation:SetBackdropColor(unpack(ElvCF["media"].backdropcolor))
			Reputation:SetWidth(original_width)
			Reputation:SetHeight(ElvDB.Scale(5))
			if powerbar_offset ~= 0 then
				Reputation:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + -ElvDB.Scale(5))
			else
				Reputation:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -ElvDB.Scale(8))
			end
			Reputation.Tooltip = false

			Reputation:SetScript("OnEnter", function(self)
				if not InCombatLockdown() then
					Reputation:SetHeight(ElvDB.Scale(20))
					Reputation.Text:Show()
				end
			end)
			
			Reputation:SetScript("OnLeave", function(self)
				if not InCombatLockdown() then
					Reputation:SetHeight(ElvDB.Scale(5))
					Reputation.Text:Hide()
				end
			end)
			
			if ElvCF["unitframes"].combat == true then
				Reputation:HookScript("OnEnter", function(self) ElvDB.Fader(self, true, true) end)
				Reputation:HookScript("OnLeave", function(self) ElvDB.Fader(self, false, true) end)
			end			

			Reputation.Text = Reputation:CreateFontString(nil, 'OVERLAY')
			Reputation.Text:SetFont(font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
			Reputation.Text:SetPoint('CENTER', Reputation)
			Reputation.Text:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
			Reputation.Text:Hide()
			
			Reputation.PostUpdate = ElvDB.UpdateReputation
			self.Reputation = Reputation
			self.Reputation.Text = Reputation.Text
			self.Reputation.F = CreateFrame("Frame", nil, self.Reputation)
			ElvDB.SetTemplate(self.Reputation.F)
			self.Reputation.F:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			self.Reputation.F:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
			self.Reputation.F:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
			self.Reputation.F:SetFrameLevel(self.Reputation:GetFrameLevel() - 1)
		end
		
		if db.showthreat == true and not IsAddOnLoaded("Omen") then
			-- the threat bar, we move this to targetframe at bottom of file
			local ThreatBar = CreateFrame("StatusBar", self:GetName()..'_ThreatBar', self)
			ThreatBar:SetWidth(original_width)
			ThreatBar:SetHeight(ElvDB.Scale(5))
			if powerbar_offset ~= 0 then
				ThreatBar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + -ElvDB.Scale(5))
			else
				ThreatBar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -ElvDB.Scale(8))
			end
			ThreatBar:SetStatusBarTexture(normTex)
			ThreatBar:GetStatusBarTexture():SetHorizTile(false)
			ThreatBar:SetBackdrop(backdrop)
			ThreatBar:SetBackdropColor(0, 0, 0, 0)
			ThreatBar.bg = ThreatBar:CreateTexture(nil, 'BORDER')
			ThreatBar.bg:SetAllPoints(ThreatBar)
			ThreatBar.bg:SetTexture(0.1,0.1,0.1)
			ThreatBar.useRawThreat = false
			self.ThreatBar = ThreatBar
			
			self.ThreatBar.F = CreateFrame("Frame", nil, self.ThreatBar)
			ElvDB.SetTemplate(self.ThreatBar.F)
			self.ThreatBar.F:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			self.ThreatBar.F:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
			self.ThreatBar.F:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
			self.ThreatBar.F:SetFrameLevel(self.ThreatBar:GetFrameLevel() - 1)
		end
		
		--CLASS BARS
		if ElvCF["unitframes"].classbar == true then
			-- show druid mana when shapeshifted in bear, cat or whatever
			if ElvDB.myclass == "DRUID" then
				--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
				self.FrameBorder.shadow:SetPoint("TOPLEFT", ElvDB.Scale(-4), ElvDB.Scale(17))
				player_height = player_height + ElvDB.Scale(14)
				
				CreateFrame("Frame"):SetScript("OnUpdate", function() ElvDB.UpdateDruidMana(self) end)
				local DruidMana = ElvDB.SetFontString(health, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
				local eclipseBar = CreateFrame('Frame', nil, self)
				eclipseBar:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, ElvDB.Scale(5))
				eclipseBar:SetSize(original_width, ElvDB.Scale(8))
				eclipseBar:SetFrameStrata("MEDIUM")
				eclipseBar:SetFrameLevel(8)
				ElvDB.SetTemplate(eclipseBar)
				eclipseBar:SetBackdropBorderColor(0,0,0,0)

				local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
				lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
				lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				lunarBar:SetStatusBarTexture(normTex)
				lunarBar:SetStatusBarColor(.30, .52, .90)
				eclipseBar.LunarBar = lunarBar

				local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
				solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
				solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				solarBar:SetStatusBarTexture(normTex)
				solarBar:SetStatusBarColor(.80, .82,  .60)
				eclipseBar.SolarBar = solarBar

				local eclipseBarText = solarBar:CreateFontString(nil, 'OVERLAY')
				eclipseBarText:SetPoint("CENTER", self.Health, "CENTER", ElvDB.Scale(1), ElvDB.Scale(-5))
				eclipseBarText:SetFont(font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
				eclipseBar.Text = eclipseBarText
			

				self.EclipseBar = eclipseBar
				
				self.EclipseBar.PostUpdatePower = ElvDB.EclipseDirection
		
				eclipseBar.FrameBackdrop = CreateFrame("Frame", nil, eclipseBar)
				ElvDB.SetTemplate(eclipseBar.FrameBackdrop)
				eclipseBar.FrameBackdrop:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
				eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
				eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
				eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)
				
				self.EclipseBar:SetScript("OnShow", function() ElvDB.MoveBuffs(self.EclipseBar, false) end)
				self.EclipseBar:SetScript("OnUpdate", function() ElvDB.MoveBuffs(self.EclipseBar, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
				self.EclipseBar:SetScript("OnHide", function() ElvDB.MoveBuffs(self.EclipseBar, false) end)
			end
			
			-- set holy power bar or shard bar
			if (ElvDB.myclass == "WARLOCK" or ElvDB.myclass == "PALADIN") then
				--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
				self.FrameBorder.shadow:SetPoint("TOPLEFT", ElvDB.Scale(-4), ElvDB.Scale(17))
				player_height = player_height + ElvDB.Scale(14)
				
				local bars = CreateFrame("Frame", nil, self)
				bars:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, ElvDB.Scale(5))
				bars:SetWidth(original_width)
				bars:SetHeight(ElvDB.Scale(8))
				ElvDB.SetTemplate(bars)
				bars:SetBackdropBorderColor(0,0,0,0)
				
				for i = 1, 3 do					
					bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, bars)
					bars[i]:SetHeight(ElvDB.Scale(8))					
					bars[i]:SetStatusBarTexture(normTex)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)

					bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
					
					if ElvDB.myclass == "WARLOCK" then
						bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
						bars[i].bg:SetTexture(148/255, 130/255, 201/255)
					elseif ElvDB.myclass == "PALADIN" then
						bars[i]:SetStatusBarColor(228/255,225/255,16/255)
						bars[i].bg:SetTexture(228/255,225/255,16/255)
					end
					
					if i == 1 then
						bars[i]:SetPoint("LEFT", bars)
					else
						bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", ElvDB.Scale(1), 0)
					end
					
					bars[i].bg:SetAllPoints(bars[i])
					bars[i]:SetWidth(ElvDB.Scale(original_width - 2)/3)
					
					bars[i].bg:SetTexture(normTex)					
					bars[i].bg:SetAlpha(.15)
				end
				
				if ElvDB.myclass == "WARLOCK" then
					bars.Override = ElvDB.UpdateShards				
					self.SoulShards = bars
					self.SoulShards:SetScript("OnShow", function() ElvDB.MoveBuffs(self.SoulShards, false) end)
					self.SoulShards:SetScript("OnUpdate", function() ElvDB.MoveBuffs(self.SoulShards, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
					self.SoulShards:SetScript("OnHide", function() ElvDB.MoveBuffs(self.SoulShards, false) end)	
					
					-- show/hide bars on entering/leaving vehicle
					self:RegisterEvent("UNIT_ENTERING_VEHICLE", function() ElvDB.ToggleBars(self.SoulShards) end)
					self:RegisterEvent("UNIT_ENTERED_VEHICLE", function() ElvDB.ToggleBars(self.SoulShards) end)
					self:RegisterEvent("UNIT_EXITING_VEHICLE", function() ElvDB.ToggleBars(self.SoulShards) end)
					self:RegisterEvent("UNIT_EXITED_VEHICLE", function() ElvDB.ToggleBars(self.SoulShards) end)
				elseif ElvDB.myclass == "PALADIN" then
					bars.Override = ElvDB.UpdateHoly
					self.HolyPower = bars
					self.HolyPower:SetScript("OnShow", function() ElvDB.MoveBuffs(self.HolyPower, false) end)
					self.HolyPower:SetScript("OnUpdate", function() ElvDB.MoveBuffs(self.HolyPower, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
					self.HolyPower:SetScript("OnHide", function() ElvDB.MoveBuffs(self.HolyPower, false) end)	
		
					-- show/hide bars on entering/leaving vehicle
					self:RegisterEvent("UNIT_ENTERING_VEHICLE", function() ElvDB.ToggleBars(self.HolyPower) end)
					self:RegisterEvent("UNIT_ENTERED_VEHICLE", function() ElvDB.ToggleBars(self.HolyPower) end)
					self:RegisterEvent("UNIT_EXITING_VEHICLE", function() ElvDB.ToggleBars(self.HolyPower) end)
					self:RegisterEvent("UNIT_EXITED_VEHICLE", function() ElvDB.ToggleBars(self.HolyPower) end)
				end
				bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
				ElvDB.SetTemplate(bars.FrameBackdrop)
				bars.FrameBackdrop:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
				bars.FrameBackdrop:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
				bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
				bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
			end
			
			-- deathknight runes
			if ElvDB.myclass == "DEATHKNIGHT" then
				--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
				self.FrameBorder.shadow:SetPoint("TOPLEFT", ElvDB.Scale(-4), ElvDB.Scale(17))
				player_height = player_height + ElvDB.Scale(14)
					
				local Runes = CreateFrame("Frame", nil, self)
				Runes:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, ElvDB.Scale(5))
				Runes:SetHeight(ElvDB.Scale(8))
				Runes:SetWidth(original_width)

				Runes:SetBackdrop(backdrop)
				Runes:SetBackdropColor(0, 0, 0)

				for i = 1, 6 do
					Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, Runes)
					Runes[i]:SetHeight(ElvDB.Scale(8))
					Runes[i]:SetWidth((original_width - 5) / 6)

					if (i == 1) then
						Runes[i]:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, ElvDB.Scale(5))
					else
						Runes[i]:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", ElvDB.Scale(1), 0)
					end
					Runes[i]:SetStatusBarTexture(normTex)
					Runes[i]:GetStatusBarTexture():SetHorizTile(false)
				end

				Runes.FrameBackdrop = CreateFrame("Frame", nil, Runes)
				ElvDB.SetTemplate(Runes.FrameBackdrop)
				Runes.FrameBackdrop:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
				Runes.FrameBackdrop:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
				Runes.FrameBackdrop:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
				Runes.FrameBackdrop:SetFrameLevel(Runes:GetFrameLevel() - 1)
				self.Runes = Runes
				
				self.Runes:SetScript("OnShow", function() ElvDB.MoveBuffs(self.Runes, false) end)
				self.Runes:SetScript("OnUpdate", function() ElvDB.MoveBuffs(self.Runes, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
				self.Runes:SetScript("OnHide", function() ElvDB.MoveBuffs(self.Runes, false) end)	

				-- show/hide bars on entering/leaving vehicle
				self:RegisterEvent("UNIT_ENTERING_VEHICLE", function() ElvDB.ToggleBars(self.Runes) end)
				self:RegisterEvent("UNIT_ENTERED_VEHICLE", function() ElvDB.ToggleBars(self.Runes) end)
				self:RegisterEvent("UNIT_EXITING_VEHICLE", function() ElvDB.ToggleBars(self.Runes) end)
				self:RegisterEvent("UNIT_EXITED_VEHICLE", function() ElvDB.ToggleBars(self.Runes) end)
			end
				
			-- shaman totem bar
			if ElvDB.myclass == "SHAMAN" then
				--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
				self.FrameBorder.shadow:SetPoint("TOPLEFT", ElvDB.Scale(-4), ElvDB.Scale(17))
				player_height = player_height + ElvDB.Scale(14)
								
				local TotemBar = CreateFrame("Frame", nil, self)
				TotemBar.Destroy = true
				TotemBar:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, ElvDB.Scale(5))
				TotemBar:SetHeight(ElvDB.Scale(8))
				TotemBar:SetWidth(original_width)

				TotemBar:SetBackdrop(backdrop)
				TotemBar:SetBackdropColor(0, 0, 0)

				for i = 1, 4 do
					TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, TotemBar)
					TotemBar[i]:SetHeight(ElvDB.Scale(8))
					TotemBar[i]:SetWidth((original_width - 3) / 4)

					if (i == 1) then
						TotemBar[i]:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, ElvDB.Scale(5))
					else
						TotemBar[i]:SetPoint("TOPLEFT", TotemBar[i-1], "TOPRIGHT", ElvDB.Scale(1), 0)
					end
					TotemBar[i]:SetStatusBarTexture(normTex)
					TotemBar[i]:GetStatusBarTexture():SetHorizTile(false)
					TotemBar[i]:SetBackdrop(backdrop)
					TotemBar[i]:SetBackdropColor(0, 0, 0)
					TotemBar[i]:SetMinMaxValues(0, 1)

					
					TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
					TotemBar[i].bg:SetAllPoints(TotemBar[i])
					TotemBar[i].bg:SetTexture(normTex)
					TotemBar[i].bg.multiplier = 0.3
				end

				TotemBar.FrameBackdrop = CreateFrame("Frame", nil, TotemBar)
				ElvDB.SetTemplate(TotemBar.FrameBackdrop)
				TotemBar.FrameBackdrop:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
				TotemBar.FrameBackdrop:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
				TotemBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
				TotemBar.FrameBackdrop:SetFrameLevel(TotemBar:GetFrameLevel() - 1)
				self.TotemBar = TotemBar
				
				self.TotemBar:SetScript("OnShow", function() ElvDB.MoveBuffs(self.TotemBar, false) end)
				self.TotemBar:SetScript("OnUpdate", function() ElvDB.MoveBuffs(self.TotemBar, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
				self.TotemBar:SetScript("OnHide", function() ElvDB.MoveBuffs(self.TotemBar, false) end)	
				
				-- show/hide bars on entering/leaving vehicle
				self:RegisterEvent("UNIT_ENTERING_VEHICLE", function() ElvDB.ToggleBars(self.TotemBar) end)
				self:RegisterEvent("UNIT_ENTERED_VEHICLE", function() ElvDB.ToggleBars(self.TotemBar) end)
				self:RegisterEvent("UNIT_EXITING_VEHICLE", function() ElvDB.ToggleBars(self.TotemBar) end)
				self:RegisterEvent("UNIT_EXITED_VEHICLE", function() ElvDB.ToggleBars(self.TotemBar) end)
			end
		end
				
		-- auras 
		if ElvCF["auras"].playerauras then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)

			debuffs.num = ElvCF["auras"].playtarbuffperrow
			debuffs:SetWidth(original_width + ElvDB.Scale(4))
			debuffs.spacing = ElvDB.Scale(2)
			debuffs.size = (((original_width + ElvDB.Scale(4)) - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("BOTTOM", self.Health, "TOP", 0, ElvDB.Scale(6))	
			debuffs.initialAnchor = 'BOTTOMRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = ElvDB.PostCreateAura
			debuffs.PostUpdateIcon = ElvDB.PostUpdateAura
			
			if ElvCF["auras"].playershowonlydebuffs == false then
				buffs.num = ElvCF["auras"].playtarbuffperrow
				buffs:SetWidth(debuffs:GetWidth())
				buffs.spacing = ElvDB.Scale(2)
				buffs.size = ((((original_width + ElvDB.Scale(4)) - (buffs.spacing*(buffs.num - 1))) / buffs.num))
				buffs:SetPoint("BOTTOM", debuffs, "TOP", 0, ElvDB.Scale(2))
				buffs:SetHeight(debuffs:GetHeight())
				buffs.initialAnchor = 'BOTTOMLEFT'
				buffs["growth-y"] = "UP"	
				buffs["growth-x"] = "RIGHT"
				buffs.PostCreateIcon = ElvDB.PostCreateAura
				buffs.PostUpdateIcon = ElvDB.PostUpdateAura
				self.Buffs = buffs	
			end
			
			self.Debuffs = debuffs
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = ElvDB.AuraFilter
		end
			
		-- cast bar for player
		if ElvCF["castbar"].unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			if ElvCF["castbar"].castermode == true then
				castbar:SetWidth(ElvuiActionBarBackground:GetWidth() - ElvDB.Scale(4))
				castbar:SetPoint("BOTTOMRIGHT", ElvuiActionBarBackground, "TOPRIGHT", ElvDB.Scale(-2), ElvDB.Scale(5))
			else
				castbar:SetWidth(original_width)
				if powerbar_offset ~= 0 then
					castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -powerbar_offset + -ElvDB.Scale(5))
				else
					castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -ElvDB.Scale(8))
				end
			end
 
			castbar:SetHeight(ElvDB.Scale(20))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			castbar:SetFrameStrata("DIALOG")
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			ElvDB.SetTemplate(castbar.bg)
			castbar.bg:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			castbar.bg:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			castbar.bg:SetFrameStrata("DIALOG")
			
			castbar.time = ElvDB.SetFontString(castbar, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", ElvDB.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = ElvDB.CustomCastTimeText
 
			castbar.Text = ElvDB.SetFontString(castbar, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
 
			castbar.CustomDelayText = ElvDB.CustomCastDelayText
			castbar.PostCastStart = ElvDB.PostCastStart
			castbar.PostChannelStart = ElvDB.PostCastStart
 
			-- cast bar latency on player
			if ElvCF["castbar"].cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "OVERLAY")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end			
 
			if ElvCF["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(castbar:GetHeight()+ElvDB.Scale(4))
				castbar.button:SetWidth(castbar:GetHeight()+ElvDB.Scale(4))
				castbar.button:SetPoint("RIGHT", castbar, "LEFT", ElvDB.Scale(-4), 0)
				ElvDB.SetTemplate(castbar.button)
				castbar.button:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, ElvDB.Scale(2), ElvDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, ElvDB.Scale(-2), ElvDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				if ElvCF["castbar"].castermode == true and unit == "player" then
					castbar:SetWidth(ElvuiActionBarBackground:GetWidth() - castbar.button:GetWidth() - ElvDB.Scale(6))
				else
					castbar:SetWidth(original_width - castbar.button:GetWidth() - ElvDB.Scale(2))
				end
			end
 
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if db.combatfeedback == true then
			local CombatFeedbackText 
			CombatFeedbackText = ElvDB.SetFontString(health, font1, ElvCF["unitframes"].fontsize*1.1, "OUTLINE")

			if db.charportrait == true then
				CombatFeedbackText:SetPoint("CENTER", self.Portrait, "CENTER")
			else
				CombatFeedbackText:SetPoint("CENTER", 0, -5)
			end
			CombatFeedbackText.colors = {
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
			self.CombatFeedbackText = CombatFeedbackText
		end
		
		-- player aggro
		if db.playeraggro == true then
			table.insert(self.__elements, ElvDB.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', ElvDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ElvDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', ElvDB.UpdateThreat)
		end
		
		--Heal Comm
		if ElvCF["raidframes"].healcomm == true then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)	
			mhpb:SetWidth(original_width)
			mhpb:SetStatusBarTexture(ElvCF["media"].normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			ohpb:SetWidth(original_width)
			ohpb:SetStatusBarTexture(ElvCF["media"].normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		--Autohide in combat
		if ElvCF["unitframes"].combat == true then
			self:RegisterEvent("PLAYER_ENTERING_WORLD", ElvDB.Fader)
			self:RegisterEvent("PLAYER_REGEN_ENABLED", ElvDB.Fader)
			self:RegisterEvent("PLAYER_REGEN_DISABLED", ElvDB.Fader)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", ElvDB.Fader)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", ElvDB.Fader)
			self:RegisterEvent("UNIT_HEALTH", ElvDB.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_START", ElvDB.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_STOP", ElvDB.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", ElvDB.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", ElvDB.Fader)
			self:RegisterEvent("UNIT_PORTRAIT_UPDATE", ElvDB.Fader)
			self:RegisterEvent("UNIT_MODEL_CHANGED", ElvDB.Fader)	
			self:HookScript("OnEnter", function(self) ElvDB.Fader(self, true) end)
			self:HookScript("OnLeave", function(self) ElvDB.Fader(self, false) end)
		end
		
		-- alt power bar
		local AltPowerBar = CreateFrame("StatusBar", nil, self.Health)
		AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		AltPowerBar:SetHeight(4)
		AltPowerBar:SetStatusBarTexture(ElvCF.media.normTex)
		AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
		AltPowerBar:SetStatusBarColor(1, 0, 0)

		AltPowerBar:SetPoint("LEFT")
		AltPowerBar:SetPoint("RIGHT")
		AltPowerBar:SetPoint("TOP", self.Health, "TOP")
		
		AltPowerBar:SetBackdrop({
		  bgFile = ElvCF["media"].blank, 
		  edgeFile = ElvCF["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = 1, 
		  insets = { left = 0, right = 0, top = 0, bottom = ElvDB.Scale(-1)}
		})
		AltPowerBar:SetBackdropColor(0, 0, 0, 0)
		AltPowerBar:SetBackdropBorderColor(0, 0, 0, 0)
		self.AltPowerBar = AltPowerBar				
		
		-- update all frames when changing area, to fix exiting instance while in vehicle
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", ElvDB.updateAllElements)
	end
	
	------------------------------------------------------------------------
	-- Target
	------------------------------------------------------------------------
	if unit == "target" then
		local original_height = target_height
		local original_width = target_width
		
		-- Health Bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetWidth(original_width)
		health:SetHeight(original_height)
		if powerbar_offset ~= 0 then
			health:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", powerbar_offset, powerbar_offset)
		else
			health:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", powerbar_offset, original_height * 0.35)	
		end
		health:SetStatusBarTexture(normTex)
		self.health = health
		
		-- Border for HealthBar
		local FrameBorder = CreateFrame("Frame", nil, health)
		FrameBorder:SetPoint("TOPLEFT", health, "TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
		ElvDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		ElvDB.CreateShadow(self.FrameBorder)
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
	
		-- Health Bar Background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		health.value = ElvDB.SetFontString(health, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
		health.value:SetPoint("RIGHT", health, "RIGHT", ElvDB.Scale(-4), ElvDB.Scale(1))
		health.PostUpdate = ElvDB.PostUpdateHealth
		self.Health = health
		self.Health.bg = healthBG
		health.frequentUpdates = true
		
		-- Smooth Bar Animation
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		-- Setup Colors
		if db.classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(ElvCF["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(ElvCF["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true		
			health.bg.multiplier = 0.3				
		end
		health.colorDisconnected = false
		
		
		-- Power Frame Border
		local PowerFrame = CreateFrame("Frame", nil, self)
		if powerbar_offset ~= 0 then
			PowerFrame:SetHeight(original_height)
			PowerFrame:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", -powerbar_offset, -powerbar_offset)
			PowerFrame:SetWidth(original_width)
			PowerFrame:SetFrameLevel(self:GetFrameLevel() - 1)
		else
			PowerFrame:SetHeight(original_height * 0.35)
			PowerFrame:SetPoint("TOP", self.Health, "BOTTOM", 0, -ElvDB.mult*3)
			PowerFrame:SetWidth(original_width + ElvDB.mult*4)
		end
		
		ElvDB.SetTemplate(PowerFrame)
		PowerFrame:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))	
		self.PowerFrame = PowerFrame
		if powerbar_offset ~= 0 then
			ElvDB.CreateShadow(self.PowerFrame)
		else
			self.FrameBorder.shadow:SetPoint("BOTTOMLEFT", self.PowerFrame, "BOTTOMLEFT", ElvDB.Scale(-4), ElvDB.Scale(-4))
		end
		
		-- Power Bar
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", ElvDB.mult*2, -ElvDB.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -ElvDB.mult*2, ElvDB.mult*2)
		power:SetStatusBarTexture(normTex)
		power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)
				
		-- Power Background
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		power.value = ElvDB.SetFontString(health, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
		power.value:SetPoint("LEFT", health, "LEFT", ElvDB.Scale(4), ElvDB.Scale(1))
		power.PreUpdate = ElvDB.PreUpdatePower
		power.PostUpdate = ElvDB.PostUpdatePower
		
		target_width = target_width + powerbar_offset
		if powerbar_offset ~= 0 then
			target_height = target_height + powerbar_offset
		else
			target_height = target_height + PowerFrame:GetHeight()
		end
		
		self.Power = power
		self.Power.bg = powerBG
		
		-- Update the Power bar Frequently
		power.frequentUpdates = true
		
		-- Setup Power Colors
		power.colorDisconnected = true
		power.colorPower = true
		power.colorTapping = false
		power.colorDisconnected = true
		
		-- Smooth Animation
		if db.showsmooth == true then
			power.Smooth = true
		end
		
		-- Debuff Highlight (Overlays Health Bar)
		if ElvCF["unitframes"].debuffhighlight == true then
			local dbh = health:CreateTexture(nil, "OVERLAY", health)
			dbh:SetAllPoints(health)
			dbh:SetTexture(ElvCF["media"].normTex)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.4		
		end
		
		-- Portraits
		if (db.charportrait == true) then			
			local PFrame = CreateFrame("Frame", nil, self)
			if powerbar_offset ~= 0 then
				PFrame:SetPoint('TOPLEFT', self.Health,'TOPRIGHT', ElvDB.Scale(6), ElvDB.Scale(2))
				PFrame:SetPoint('BOTTOMLEFT', self.Health,'BOTTOMRIGHT', ElvDB.Scale(6) + powerbar_offset, -powerbar_offset)
				PFrame:SetWidth(original_width/5)
			else
				PFrame:SetPoint('TOPLEFT', self.Health,'TOPRIGHT', ElvDB.Scale(6), ElvDB.Scale(2))
				PFrame:SetPoint('BOTTOMLEFT', self.Health,'BOTTOMRIGHT', ElvDB.Scale(6), ElvDB.Scale(-3) + -(original_height * 0.35))
				PFrame:SetWidth(original_width/5)
			end
			ElvDB.SetTemplate(PFrame)
			PFrame:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			self.PFrame = PFrame
			ElvDB.CreateShadow(self.PFrame)			
			local portrait = CreateFrame("PlayerModel", nil, PFrame)
			portrait:SetFrameLevel(2)
			
			--dont ask me why but the playerframe looks completely fucked when i set it how it should be..
			portrait:SetPoint('BOTTOMLEFT', PFrame, 'BOTTOMLEFT', ElvDB.Scale(2), ElvDB.Scale(2))		
			portrait:SetPoint('TOPRIGHT', PFrame, 'TOPRIGHT', ElvDB.Scale(-2), ElvDB.Scale(-2))		
			table.insert(self.__elements, ElvDB.HidePortrait)
		
			self.Portrait = portrait
			target_width = target_width + (PFrame:GetWidth() + ElvDB.Scale(6))
		end
						
		-- Unit name on target
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("LEFT", health, "LEFT", 0, ElvDB.Scale(1))
		Name:SetJustifyH("LEFT")
		Name:SetFont(font1, ElvCF["unitframes"].fontsize, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		self:Tag(Name, '[Elvui:getnamecolor][Elvui:namelong] [Elvui:diffcolor][level] [shortclassification]')
		self.Name = Name
		
		if ElvCF["auras"].targetauras then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			
			buffs.num = ElvCF["auras"].playtarbuffperrow
			buffs:SetWidth(original_width + ElvDB.Scale(4))
			buffs.spacing = ElvDB.Scale(2)
			buffs.size = (((original_width + ElvDB.Scale(4)) - (buffs.spacing*(buffs.num - 1))) / buffs.num)
			buffs:SetHeight(buffs.size)
			buffs:SetPoint("BOTTOM", self.Health, "TOP", 0, ElvDB.Scale(6))	
			buffs.initialAnchor = 'BOTTOMLEFT'
			buffs["growth-y"] = "UP"
			buffs["growth-x"] = "RIGHT"
			buffs.PostCreateIcon = ElvDB.PostCreateAura
			buffs.PostUpdateIcon = ElvDB.PostUpdateAura
			self.Buffs = buffs	
			
			debuffs.num = ElvCF["auras"].playtarbuffperrow
			debuffs:SetWidth(original_width + ElvDB.Scale(4))
			debuffs.spacing = ElvDB.Scale(2)
			debuffs.size = (((original_width + ElvDB.Scale(4)) - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("BOTTOM", buffs, "TOP", 0, ElvDB.Scale(2))
			debuffs.initialAnchor = 'BOTTOMRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = ElvDB.PostCreateAura
			debuffs.PostUpdateIcon = ElvDB.PostUpdateAura
			self.Debuffs = debuffs
			
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = ElvDB.AuraFilter
		end
		
		-- cast bar for target
		if ElvCF["castbar"].unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetWidth(original_width)
			if powerbar_offset ~= 0 then
				castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -powerbar_offset + -ElvDB.Scale(5))
			else
				castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -ElvDB.Scale(8))
			end
 
			castbar:SetHeight(ElvDB.Scale(20))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
 
			castbar.bg = CreateFrame("Frame", nil, castbar)
			ElvDB.SetTemplate(castbar.bg)
			castbar.bg:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			castbar.bg:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)

 
			castbar.time = ElvDB.SetFontString(castbar, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", ElvDB.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = ElvDB.CustomCastTimeText
 
			castbar.Text = ElvDB.SetFontString(castbar, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
 
			castbar.CustomDelayText = ElvDB.CustomCastDelayText
			castbar.PostCastStart = ElvDB.PostCastStart
			castbar.PostChannelStart = ElvDB.PostCastStart
  
			if ElvCF["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(castbar:GetHeight()+ElvDB.Scale(4))
				castbar.button:SetWidth(castbar:GetHeight()+ElvDB.Scale(4))
				castbar.button:SetPoint("RIGHT", castbar, "LEFT", ElvDB.Scale(-4), 0)
				ElvDB.SetTemplate(castbar.button)
				castbar.button:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, ElvDB.Scale(2), ElvDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, ElvDB.Scale(-2), ElvDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				castbar:SetWidth(original_width - castbar.button:GetWidth() - ElvDB.Scale(2))
			end
 
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if db.combatfeedback == true then
			local CombatFeedbackText 
			CombatFeedbackText = ElvDB.SetFontString(health, font1, ElvCF["unitframes"].fontsize*1.1, "OUTLINE")
			
			if db.charportrait == true then
				CombatFeedbackText:SetPoint("CENTER", self.Portrait, "CENTER")
			else
				CombatFeedbackText:SetPoint("CENTER", 0, -5)
			end
			CombatFeedbackText.colors = {
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
			self.CombatFeedbackText = CombatFeedbackText
		end
		
		-- Setup ComboBar
		--We only need to change the target height for these classes, because no one else will see it but rarely if they are in a vehicle
		if ElvDB.myclass == "DRUID" or ElvDB.myclass == "ROGUE" then
			target_height = target_height + ElvDB.Scale(14)
		end
		
		local bars = CreateFrame("Frame", nil, self)
		bars:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, ElvDB.Scale(5))
		bars:SetWidth(original_width)
		bars:SetHeight(ElvDB.Scale(8))
		ElvDB.SetTemplate(bars)
		bars:SetBackdropBorderColor(0,0,0,0)
		bars:SetBackdropColor(0,0,0,0)
		
		for i = 1, 5 do					
			bars[i] = CreateFrame("StatusBar", self:GetName().."_Combo"..i, bars)
			bars[i]:SetHeight(ElvDB.Scale(8))					
			bars[i]:SetStatusBarTexture(normTex)
			bars[i]:GetStatusBarTexture():SetHorizTile(false)
							
			if i == 1 then
				bars[i]:SetPoint("LEFT", bars)
			else
				bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", ElvDB.Scale(1), 0)
			end
			bars[i]:SetAlpha(0.15)
			bars[i]:SetWidth(ElvDB.Scale(original_width - 4)/5)
		end
		
		bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
		bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
		bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
		

		self.CPoints = bars
		self.CPoints.Override = ElvDB.ComboDisplay
		
		bars.FrameBackdrop = CreateFrame("Frame", nil, bars[1])
		ElvDB.SetTemplate(bars.FrameBackdrop)
		bars.FrameBackdrop:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
		bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
		bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
		bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
		
		--Heal Comm
		if ElvCF["raidframes"].healcomm == true then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)	
			mhpb:SetWidth(original_width)
			mhpb:SetStatusBarTexture(ElvCF["media"].normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			ohpb:SetWidth(original_width)
			ohpb:SetStatusBarTexture(ElvCF["media"].normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end	

		-- alt power bar
		local AltPowerBar = CreateFrame("StatusBar", nil, self.Health)
		AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		AltPowerBar:SetHeight(4)
		AltPowerBar:SetStatusBarTexture(ElvCF.media.normTex)
		AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
		AltPowerBar:SetStatusBarColor(1, 0, 0)

		AltPowerBar:SetPoint("LEFT")
		AltPowerBar:SetPoint("RIGHT")
		AltPowerBar:SetPoint("TOP", self.Health, "TOP")
		
		AltPowerBar:SetBackdrop({
		  bgFile = ElvCF["media"].blank, 
		  edgeFile = ElvCF["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = 1, 
		  insets = { left = 0, right = 0, top = 0, bottom = ElvDB.Scale(-1)}
		})
		AltPowerBar:SetBackdropColor(0, 0, 0, 0)
		AltPowerBar:SetBackdropBorderColor(0, 0, 0, 0)

		self.AltPowerBar = AltPowerBar				
		
	end
	
	------------------------------------------------------------------------
	--	Target of Target, Pet, focus, focustarget unit layout mirrored
	------------------------------------------------------------------------
	
	if (unit == "targettarget" or unit == "pet" or unit == "focustarget" or unit == "focus") then
		local original_width = smallframe_width
		local original_height = smallframe_height
		
		local smallpowerbar_offset
		if powerbar_offset ~= 0 then
			smallpowerbar_offset = powerbar_offset*(7/9)
		else
			smallpowerbar_offset = ElvDB.Scale(7)
		end

		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		if unit == "focus" or unit == "focustarget" then
			health:SetPoint("TOPLEFT", self, "TOPLEFT")
		else
			health:SetPoint("TOP", self, "TOP")
		end
		health:SetWidth(original_width)
		health:SetHeight(original_height)
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		
		self.Health = health
		self.Health.bg = healthBG
		health.frequentUpdates = true
		health.PostUpdate = ElvDB.PostUpdateHealth
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		local FrameBorder = CreateFrame("Frame", nil, self)
		FrameBorder:SetPoint("TOPLEFT", self.Health, "TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
		ElvDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		ElvDB.CreateShadow(self.FrameBorder)
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
		
		-- Setup Colors
		if db.classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(ElvCF["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(ElvCF["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true		
			health.bg.multiplier = 0.3				
		end
		health.colorDisconnected = false
		
		-- power frame
		local PowerFrame = CreateFrame("Frame", nil, self)
		if powerbar_offset ~= 0 then
			PowerFrame:SetWidth(original_width)
			PowerFrame:SetHeight(original_height)
			PowerFrame:SetFrameLevel(self:GetFrameLevel() - 1)
			if unit == "focus" or unit == "focustarget" then
				PowerFrame:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", smallpowerbar_offset, -smallpowerbar_offset)
				smallframe_width = smallframe_width + smallpowerbar_offset			
				smallframe_height = smallframe_height + smallpowerbar_offset	
			elseif unit == "targettarget" or unit == "pet" then
				PowerFrame:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -smallpowerbar_offset, 0)
				PowerFrame:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT", smallpowerbar_offset, 0)
				PowerFrame:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, -smallpowerbar_offset)
				smallframe_width = smallframe_width + smallpowerbar_offset*2
				smallframe_height = smallframe_height + smallpowerbar_offset
			end
		else
			PowerFrame:SetWidth(original_width + ElvDB.Scale(4))
			PowerFrame:SetHeight(original_height * 0.3)
			PowerFrame:SetPoint("TOP", self.Health, "BOTTOM", 0,-ElvDB.Scale(3))
			smallframe_height = smallframe_height + (original_height * 0.3)
		end
		PowerFrame:SetFrameStrata("LOW")
		ElvDB.SetTemplate(PowerFrame)
		PowerFrame:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))	
		if powerbar_offset ~= 0 then
			ElvDB.CreateShadow(PowerFrame)
		else
			self.FrameBorder.shadow:SetPoint("BOTTOMLEFT", PowerFrame, "BOTTOMLEFT", ElvDB.Scale(-4), ElvDB.Scale(-4))
		end
		self.PowerFrame = PowerFrame
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", ElvDB.mult*2, -ElvDB.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -ElvDB.mult*2, ElvDB.mult*2)
		power:SetStatusBarTexture(normTex)
		power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)
		power:SetFrameStrata("LOW")
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3

				
		self.Power = power
		self.Power.bg = powerBG
		
		power.frequentUpdates = true
		power.colorDisconnected = true

		local dbh = health:CreateTexture(nil, "OVERLAY", health)
		dbh:SetAllPoints(health)
		dbh:SetTexture(ElvCF["media"].normTex)
		dbh:SetBlendMode("ADD")
		dbh:SetVertexColor(0,0,0,0)
		self.DebuffHighlight = dbh
		self.DebuffHighlightFilter = true
		self.DebuffHighlightAlpha = 0.4	
		
		if db.showsmooth == true then
			power.Smooth = true
		end
		
		power.colorPower = true
		powerBG.multiplier = 0.3
		power.colorTapping = false
		power.colorDisconnected = true
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, ElvDB.Scale(1))
		Name:SetFont(font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
		Name:SetJustifyH("CENTER")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Elvui:getnamecolor][Elvui:namemedium]')
		self.Name = Name
		
		if unit == "targettarget" and ElvCF["auras"].totdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, health)			
			debuffs.num = ElvCF["auras"].smallbuffperrow
			debuffs:SetWidth(original_width + ElvDB.Scale(4))
			debuffs.spacing = ElvDB.Scale(2)
			debuffs.size = (((original_width + ElvDB.Scale(4)) - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("TOP", self, "BOTTOM", 0, -ElvDB.Scale(5))
			debuffs.initialAnchor = 'TOPLEFT'
			debuffs["growth-y"] = "DOWN"
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = ElvDB.PostCreateAura
			debuffs.PostUpdateIcon = ElvDB.PostUpdateAura
			self.Debuffs = debuffs	
			
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = ElvDB.AuraFilter
		end
		
		if unit == "focus" and ElvCF["auras"].focusdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, health)			
			debuffs.num = ElvCF["auras"].smallbuffperrow
			debuffs:SetWidth(original_width + ElvDB.Scale(4))
			debuffs.spacing = ElvDB.Scale(2)
			debuffs.size = (((original_width + ElvDB.Scale(4)) - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("TOP", self, "BOTTOM", 0, -ElvDB.Scale(5))
			debuffs.initialAnchor = 'TOPLEFT'
			debuffs["growth-y"] = "DOWN"
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = ElvDB.PostCreateAura
			debuffs.PostUpdateIcon = ElvDB.PostUpdateAura
			self.Debuffs = debuffs	
			
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = ElvDB.AuraFilter
		end
		
		if unit == "pet" then
			if (ElvCF["castbar"].unitcastbar == true) then
				local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
				castbar:SetStatusBarTexture(normTex)
				self.Castbar = castbar
			end
			if ElvCF["auras"].raidunitbuffwatch == true then
				ElvDB.createAuraWatch(self,unit)
			end
			
			--Autohide in combat
			if ElvCF["unitframes"].combat == true then
				self:HookScript("OnEnter", function(self) ElvDB.Fader(self, true) end)
				self:HookScript("OnLeave", function(self) ElvDB.Fader(self, false) end)
			end
			
			-- update pet name, this should fix "UNKNOWN" pet names on pet unit.
			self:RegisterEvent("UNIT_PET", ElvDB.updateAllElements)
		end
		
		if ElvCF["castbar"].unitcastbar == true and unit == "focus" then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetHeight(ElvDB.Scale(20))
			castbar:SetWidth(ElvDB.Scale(240))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			castbar:SetPoint("CENTER", UIParent, "CENTER", 0, 250)		
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			ElvDB.SetTemplate(castbar.bg)
			castbar.bg:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			castbar.bg:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			
			castbar.time = ElvDB.SetFontString(castbar, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", ElvDB.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = ElvDB.CustomCastTimeText

			castbar.Text = ElvDB.SetFontString(castbar, font1, ElvCF["unitframes"].fontsize)
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomDelayText = ElvDB.CustomCastDelayText
			castbar.PostCastStart = ElvDB.PostCastStart
			castbar.PostChannelStart = ElvDB.PostCastStart
			
			castbar.CastbarBackdrop = CreateFrame("Frame", nil, castbar)
			castbar.CastbarBackdrop:SetPoint("TOPLEFT", castbar, "TOPLEFT", ElvDB.Scale(-6), ElvDB.Scale(6))
			castbar.CastbarBackdrop:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", ElvDB.Scale(6), ElvDB.Scale(-6))
			castbar.CastbarBackdrop:SetParent(castbar)
			castbar.CastbarBackdrop:SetFrameStrata("BACKGROUND")
			castbar.CastbarBackdrop:SetFrameLevel(4)
			castbar.CastbarBackdrop:SetBackdrop({
				edgeFile = glowTex, edgeSize = 4,
				insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
			castbar.CastbarBackdrop:SetBackdropColor(0, 0, 0, 0)
			castbar.CastbarBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
			
			if ElvCF["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(ElvDB.Scale(40))
				castbar.button:SetWidth(ElvDB.Scale(40))
				castbar.button:SetPoint("CENTER", 0, ElvDB.Scale(50))
				ElvDB.SetTemplate(castbar.button)
				castbar.button:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, ElvDB.Scale(2), ElvDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, ElvDB.Scale(-2), ElvDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				
				castbar.IconBackdrop = CreateFrame("Frame", nil, self)
				castbar.IconBackdrop:SetPoint("TOPLEFT", castbar.button, "TOPLEFT", ElvDB.Scale(-4), ElvDB.Scale(4))
				castbar.IconBackdrop:SetPoint("BOTTOMRIGHT", castbar.button, "BOTTOMRIGHT", ElvDB.Scale(4), ElvDB.Scale(-4))
				castbar.IconBackdrop:SetParent(castbar)
				castbar.IconBackdrop:SetBackdrop({
					edgeFile = glowTex, edgeSize = 4,
					insets = {left = 3, right = 3, top = 3, bottom = 3}
				})
				castbar.IconBackdrop:SetBackdropColor(0, 0, 0, 0)
				castbar.IconBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
			end

			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
	end
	
	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and ElvCF["arena"].unitframes == true) or (unit and unit:find("boss%d") and ElvCF["raidframes"].showboss == true) then
		local original_height = arenaboss_height
		local original_width = arenaboss_width

		local arenapowerbar_offset
		if powerbar_offset ~= 0 then
			arenapowerbar_offset = powerbar_offset*(7/9)
		else
			arenapowerbar_offset = ElvDB.Scale(7)
		end		
		
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(arenaboss_height)
		health:SetPoint("TOPLEFT")
		if (unit and unit:find('arena%d')) then
			health:SetWidth(arenaboss_width - (arenaboss_height*.80) - ElvDB.Scale(6))
		else
			health:SetWidth(arenaboss_width)
		end
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(ElvCF["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(ElvCF["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true		
			healthBG.multiplier = 0.3
		end
		health.colorDisconnected = false
		
		local FrameBorder = CreateFrame("Frame", nil, self)
		FrameBorder:SetPoint("TOPLEFT", self.Health, "TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
		if (unit and unit:find('arena%d')) then
			FrameBorder:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", ElvDB.Scale(2) + arenaboss_height*.80 + ElvDB.Scale(6), ElvDB.Scale(-2))
		else
			FrameBorder:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
		end
		ElvDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		ElvDB.CreateShadow(self.FrameBorder)
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
		
		-- power frame
		local PowerFrame = CreateFrame("Frame", nil, self)
		if powerbar_offset ~= 0 then
			PowerFrame:SetHeight(arenaboss_height)
			PowerFrame:SetWidth(arenaboss_width)
			PowerFrame:SetFrameLevel(self:GetFrameLevel() - 1)
			PowerFrame:SetPoint("TOPLEFT", self.Health, "TOPLEFT", arenapowerbar_offset, -arenapowerbar_offset)
		else
			PowerFrame:SetWidth(arenaboss_width + ElvDB.Scale(4))
			PowerFrame:SetHeight(arenaboss_height * 0.3)
			PowerFrame:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", -ElvDB.Scale(2), -ElvDB.Scale(3))		
		end
		arenaboss_height = arenaboss_height + arenapowerbar_offset
		arenaboss_width = arenaboss_width + arenapowerbar_offset
		ElvDB.SetTemplate(PowerFrame)
		PowerFrame:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))	
		if powerbar_offset ~= 0 then
			ElvDB.CreateShadow(PowerFrame)
		else
			self.FrameBorder.shadow:SetPoint("BOTTOMLEFT", PowerFrame, "BOTTOMLEFT", ElvDB.Scale(-4), ElvDB.Scale(-4))
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", ElvDB.mult*2, -ElvDB.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -ElvDB.mult*2, ElvDB.mult*2)
		power:SetStatusBarTexture(normTex)
		power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)		
		
		power.frequentUpdates = true
		power.colorPower = true
		power.colorDisconnected = true
		
		if db.showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.colorPower = true
		powerBG.multiplier = 0.3
		power.colorTapping = false
		power.colorDisconnected = true
				
		self.Power = power
		self.Power.bg = powerBG
		
		--Health and Power
		if (unit and unit:find('arena%d')) then
			health.value = ElvDB.SetFontString(health, font1,ElvCF["unitframes"].fontsize, "OUTLINE")
			health.value:SetPoint("LEFT", ElvDB.Scale(2), ElvDB.Scale(1))
			health.PostUpdate = ElvDB.PostUpdateHealth
			
			power.value = ElvDB.SetFontString(health, font1, ElvCF["unitframes"].fontsize, "OUTLINE")
			power.value:SetPoint("RIGHT", health, "RIGHT", ElvDB.Scale(-2), ElvDB.Scale(1))
			power.PreUpdate = ElvDB.PreUpdatePower
			power.PostUpdate = ElvDB.PostUpdatePower			
		else
			health.value = ElvDB.SetFontString(health, font1,ElvCF["unitframes"].fontsize, "OUTLINE")
			health.value:SetPoint("TOPLEFT", health, "TOPLEFT", ElvDB.Scale(2), ElvDB.Scale(-2))
			health.PostUpdate = ElvDB.PostUpdateHealth
			
			power.value = ElvDB.SetFontString(health, font1, ElvCF["unitframes"].fontsize, "OUTLINE")
			power.value:SetPoint("BOTTOMLEFT", health, "BOTTOMLEFT", ElvDB.Scale(2), ElvDB.Scale(1))
			power.value:SetJustifyH("RIGHT")
			power.PreUpdate = ElvDB.PreUpdatePower
			power.PostUpdate = ElvDB.PostUpdatePower

			-- alt power bar
			local AltPowerBar = CreateFrame("StatusBar", nil, self)
			local apb_bg = CreateFrame("Frame", nil, AltPowerBar)
			apb_bg:SetWidth(arenaboss_width + ElvDB.Scale(-3))
			apb_bg:SetHeight(arenaboss_height * 0.2)
			apb_bg:SetPoint("BOTTOMLEFT", self, "TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(3))
			ElvDB.SetTemplate(apb_bg)
			apb_bg:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
			apb_bg:SetFrameLevel(AltPowerBar:GetFrameLevel() - 1)
			AltPowerBar:SetStatusBarTexture(ElvCF.media.normTex)
			AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
			AltPowerBar:SetStatusBarColor(1, 0, 0)
		
			AltPowerBar:SetPoint("TOPLEFT", apb_bg, "TOPLEFT", ElvDB.Scale(2), ElvDB.Scale(-2))
			AltPowerBar:SetPoint("BOTTOMRIGHT", apb_bg, "BOTTOMRIGHT", ElvDB.Scale(-2), ElvDB.Scale(2))
			
			AltPowerBar:SetBackdrop({
			  bgFile = ElvCF["media"].blank, 
			  edgeFile = ElvCF["media"].blank, 
			  tile = false, tileSize = 0, edgeSize = 1, 
			  insets = { left = 0, right = 0, top = 0, bottom = ElvDB.Scale(-1)}
			})
			AltPowerBar:SetBackdropColor(0, 0, 0, 0)
			AltPowerBar:SetBackdropBorderColor(0, 0, 0, 0)
			AltPowerBar:HookScript("OnShow", function(self) self:GetParent().FrameBorder.shadow:SetPoint("TOPLEFT", ElvDB.Scale(-4), ElvDB.Scale(12)) end)
			AltPowerBar:HookScript("OnHide", function(self) self:GetParent().FrameBorder.shadow:SetPoint("TOPLEFT", ElvDB.Scale(-4), ElvDB.Scale(4)) end)
			AltPowerBar.FrameBackdrop = apb_bg		
			self.AltPowerBar = AltPowerBar	
		end
		
		-- names
		local Name
		if (unit and unit:find('arena%d')) then
			Name = health:CreateFontString(nil, "OVERLAY")
			Name:SetPoint("CENTER", health, "CENTER", 0, ElvDB.Scale(1))
			Name:SetJustifyH("CENTER")
			Name:SetFont(font1, ElvCF["unitframes"].fontsize, "OUTLINE")
			Name:SetShadowColor(0, 0, 0)
			Name:SetShadowOffset(1.25, -1.25)
		else
			Name = health:CreateFontString(nil, "OVERLAY")
			Name:SetPoint("RIGHT", health, "RIGHT", ElvDB.Scale(-2), ElvDB.Scale(1))
			Name:SetJustifyH("RIGHT")
			Name:SetFont(font1, ElvCF["unitframes"].fontsize, "OUTLINE")
			Name:SetShadowColor(0, 0, 0)
			Name:SetShadowOffset(1.25, -1.25)	
		end
		
		Name.frequentUpdates = 0.2
		self:Tag(Name, '[Elvui:getnamecolor][Elvui:nameshort] [Elvui:diffcolor][level] [shortclassification]')
		self.Name = Name
					
		-- trinket feature via trinket plugin
		if not IsAddOnLoaded("Gladius") then
			if (unit and unit:find('arena%d')) then
				local Trinketbg = CreateFrame("Frame", nil, self)
				Trinketbg:SetHeight(original_height)
				Trinketbg:SetWidth(original_height)
				Trinketbg:SetPoint("RIGHT", self.FrameBorder, "RIGHT",ElvDB.Scale(-2), 0)				
				ElvDB.SetTemplate(Trinketbg)
				Trinketbg:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
				Trinketbg:SetFrameLevel(self.Health:GetFrameLevel()+1)
				self.Trinketbg = Trinketbg
				
				local Trinket = CreateFrame("Frame", nil, Trinketbg)
				Trinket:SetAllPoints(Trinketbg)
				Trinket:SetPoint("TOPLEFT", Trinketbg, ElvDB.Scale(2), ElvDB.Scale(-2))
				Trinket:SetPoint("BOTTOMRIGHT", Trinketbg, ElvDB.Scale(-2), ElvDB.Scale(2))
				Trinket:SetFrameLevel(Trinketbg:GetFrameLevel()+1)
				Trinket.trinketUseAnnounce = true
				self.Trinket = Trinket
			end
		end
		
		-- create arena/boss debuff/buff spawn point
		local buffs = CreateFrame("Frame", nil, self)
		buffs:SetHeight(arenaboss_height + 8)
		buffs:SetWidth(252)
		buffs:SetPoint("RIGHT", self, "LEFT", ElvDB.Scale(-4), 0)
		buffs.size = arenaboss_height
		buffs.num = 3
		buffs.spacing = 2
		buffs.initialAnchor = 'RIGHT'
		buffs["growth-x"] = "LEFT"
		buffs.PostCreateIcon = ElvDB.PostCreateAura
		buffs.PostUpdateIcon = ElvDB.PostUpdateAura
		self.Buffs = buffs		
		
		--only need to see debuffs for arena frames
		if (unit and unit:find("arena%d")) and ElvCF["auras"].arenadebuffs == true then	
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs:SetHeight(arenaboss_height + 8)
			debuffs:SetWidth(arenaboss_width*2)
			debuffs:SetPoint("LEFT", self, "RIGHT", ElvDB.Scale(4), 0)
			debuffs.size = arenaboss_height
			debuffs.num = 3
			debuffs.spacing = 2
			debuffs.initialAnchor = 'LEFT'
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = ElvDB.PostCreateAura
			debuffs.PostUpdateIcon = ElvDB.PostUpdateAura
			self.Debuffs = debuffs
			
			--set filter for buffs/debuffs
			self.Buffs.CustomFilter = ElvDB.AuraFilter
			self.Debuffs.CustomFilter = ElvDB.AuraFilter
		end
		
		
		if ElvCF["castbar"].unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetWidth(original_width)
			if powerbar_offset ~= 0 then
				castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + ElvDB.Scale(-1))
			else
				castbar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -(original_height * 0.35) + ElvDB.Scale(5))
			end
			
			castbar:SetHeight(ElvDB.Scale(16))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			ElvDB.SetTemplate(castbar.bg)
			castbar.bg:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
			castbar.bg:SetPoint("TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			
			castbar.time = ElvDB.SetFontString(castbar, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", ElvDB.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = ElvDB.CustomCastTimeText

			castbar.Text = ElvDB.SetFontString(castbar, font1, ElvCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomDelayText = ElvDB.CustomCastDelayText
			castbar.PostCastStart = ElvDB.PostCastStart
			castbar.PostChannelStart = ElvDB.PostCastStart
									
			if ElvCF["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(castbar:GetHeight()+ElvDB.Scale(4))
				castbar.button:SetWidth(castbar:GetHeight()+ElvDB.Scale(4))
				castbar.button:SetPoint("RIGHT", castbar, "LEFT", ElvDB.Scale(-4), 0)
				ElvDB.SetTemplate(castbar.button)
				castbar.button:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, ElvDB.Scale(2), ElvDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, ElvDB.Scale(-2), ElvDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				castbar:SetWidth(original_width - castbar.button:GetWidth() - ElvDB.Scale(2))
				
				castbar:ClearAllPoints()
				if powerbar_offset ~= 0 then
					castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", castbar.button:GetWidth() + ElvDB.Scale(2), -powerbar_offset + ElvDB.Scale(-1))
				else
					castbar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -(original_height * 0.35) + ElvDB.Scale(5))
				end				
			end

			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end		
	end
	
	------------------------------------------------------------------------
	--	Main tanks and Main Assists layout (both mirror'd)
	------------------------------------------------------------------------
	
	if(self:GetParent():GetName():match"ElvHealMainTank" or self:GetParent():GetName():match"ElvHealMainAssist") then
		-- Right-click focus on maintank or mainassist units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:SetAllPoints()
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(ElvCF["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(ElvCF["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true	
			healthBG.multiplier = 0.3
		end
		health.colorDisconnected = false
		
		-- Border for HealthBar
		local FrameBorder = CreateFrame("Frame", nil, health)
		FrameBorder:SetPoint("TOPLEFT", health, "TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
		ElvDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		ElvDB.CreateShadow(self.FrameBorder)
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, ElvDB.Scale(1))
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, ElvCF["unitframes"].fontsize, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Elvui:getnamecolor][Elvui:nameshort]')
		self.Name = Name
	end	
	
	------------------------------------------------------------------------
	--	Features we want for all units at the same time
	------------------------------------------------------------------------
	
	-- here we create an invisible frame for all element we want to show over health/power.
	-- because we can only use self here, and self is under all elements.
	if unit ~= "party" then
		local InvFrame = CreateFrame("Frame", nil, self)
		InvFrame:SetFrameStrata("MEDIUM")
		InvFrame:SetFrameLevel(5)
		InvFrame:SetAllPoints(self.Health)
		
		-- symbols, now put the symbol on the frame we created above.
		local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
		RaidIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp") 
		RaidIcon:SetHeight(15)
		RaidIcon:SetWidth(15)
		RaidIcon:SetPoint("TOP", 0, 8)
		self.RaidIcon = RaidIcon
	end	
	
	return self
end

------------------------------------------------------------------------
--	Default Positions
------------------------------------------------------------------------
oUF:RegisterStyle('Elv', Shared)

local yoffset = 0

if ElvCF["actionbar"].bottomrows == 1 then
	yoffset = yoffset + 30
end

-- Player
local player = oUF:Spawn('player', "ElvHeal_player")
player:SetPoint("BOTTOMRIGHT", ElvuiActionBarBackground, "TOPLEFT", ElvDB.Scale(-35),ElvDB.Scale(205) + yoffset)
player:SetSize(player_width, player_height)

-- Target
local target = oUF:Spawn('target', "ElvHeal_target")
target:SetPoint("BOTTOMLEFT", ElvuiActionBarBackground, "TOPRIGHT", ElvDB.Scale(35),ElvDB.Scale(205) + yoffset)
target:SetSize(target_width, target_height)

-- Focus
local focus = oUF:Spawn('focus', "ElvHeal_focus")
if powerbar_offset ~= 0 then
	focus:SetPoint("TOPLEFT", ElvHeal_target, "BOTTOMLEFT", ElvDB.Scale(9),ElvDB.Scale(-42))
else
	focus:SetPoint("TOPLEFT", ElvHeal_target, "BOTTOMLEFT", 0,ElvDB.Scale(-42))
end
focus:SetSize(smallframe_width, smallframe_height)

-- Target's Target
local tot = oUF:Spawn('targettarget', "ElvHeal_targettarget")
tot:SetPoint("TOPRIGHT", ElvHeal_target, "BOTTOMRIGHT", 0,ElvDB.Scale(-42))
tot:SetSize(smallframe_width, smallframe_height)

-- Player's Pet
local pet = oUF:Spawn('pet', "ElvHeal_pet")
pet:SetPoint("TOPRIGHT", ElvHeal_player, "BOTTOMRIGHT", 0,ElvDB.Scale(-42))
pet:SetSize(smallframe_width, smallframe_height)
pet:SetParent(player)

-- Focus's target
if db.showfocustarget == true then
	local focustarget = oUF:Spawn('focustarget', "ElvHeal_focustarget")
	focustarget:SetPoint("TOP", ElvHeal_focus, "BOTTOM", 0,ElvDB.Scale(-32))
	focustarget:SetSize(smallframe_width, smallframe_height)
end


if ElvCF.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "ElvHealArena"..i)
		if i == 1 then
			arena[i]:SetPoint("BOTTOMLEFT", ChatRBackground2, "TOPLEFT", -80, 285)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 38)
		end
		arena[i]:SetSize(arenaboss_width, arenaboss_height)
	end
end

if ElvCF.raidframes.showboss then
	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "ElvHealBoss"..i)
		if i == 1 then
			boss[i]:SetPoint("BOTTOMLEFT", ChatRBackground2, "TOPLEFT", -80, 285)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 38)             
		end
		boss[i]:SetSize(arenaboss_width, arenaboss_height)
	end
end


if ElvCF["raidframes"].maintank == true then
	local tank = oUF:SpawnHeader('ElvHealMainTank', nil, 'raid', 
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true, 
		'groupFilter', 'MAINTANK', 
		'yOffset', 7, 
		'point' , 'BOTTOM',
		'template', 'Elv_Mtt'
	)
	tank:SetPoint("BOTTOM", ChatLBackground2, "TOP", -42, 450)
end

if ElvCF["raidframes"].mainassist == true then
	local assist = oUF:SpawnHeader("ElvHealMainAssist", nil, 'raid', 
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true, 
		'groupFilter', 'MAINASSIST', 
		'yOffset', 7, 
		'point' , 'BOTTOM',
		'template', 'Elv_Mtt'
	)
	if ElvCF["raidframes"].maintank == true then 
		assist:SetPoint("TOPLEFT", ElvHealMainTank, "BOTTOMLEFT", 2, -50)
	else
		assist:SetPoint("BOTTOM", ChatLBackground2, "TOP", -42, 450)
	end
end

local party
if ElvCF["raidframes"].disableblizz == true then --seriosly lazy addon authors can suck my dick
	for i = 1,MAX_BOSS_FRAMES do
		local t_boss = _G["Boss"..i.."TargetFrame"]
		t_boss:UnregisterAllEvents()
		t_boss.Show = ElvDB.dummy
		t_boss:Hide()
		_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
		_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
	end
	party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)
	local blizzloader = CreateFrame("Frame")
	blizzloader:RegisterEvent("ADDON_LOADED")
	blizzloader:SetScript("OnEvent", function(self, event, addon)
		if addon == "ElvUI_Heal_Layout" then 
			ElvDB.Kill(CompactRaidFrameContainer)
			ElvDB.Kill(CompactPartyFrame)
		end
	end)
end

------------------------------------------------------------------------
--	Right-Click on unit frames menu.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
	UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
	UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "SELECT_ROLE", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
	UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end

--Move threatbar to targetframe
if ElvHeal_player.ThreatBar then
	if powerbar_offset ~= 0 then
		ElvHeal_player.ThreatBar:SetPoint("TOPLEFT", ElvHeal_target.Health, "BOTTOMLEFT", 0, -powerbar_offset + -ElvDB.Scale(5))
	else
		ElvHeal_player.ThreatBar:SetPoint("TOPRIGHT", ElvHeal_target.Health, "BOTTOMRIGHT", 0, -(ElvHeal_target.Health:GetHeight() * 0.35) + -ElvDB.Scale(8))
	end
end