if not TukuiCF["unitframes"].enable == true then return end

------------------------------------------------------------------------
--	Variables
------------------------------------------------------------------------

local db = TukuiCF["unitframes"]
local font1 = TukuiCF["media"].uffont
local font2 = TukuiCF["media"].font
local normTex = TukuiCF["media"].normTex
local glowTex = TukuiCF["media"].glowTex

local backdrop = {
	bgFile = TukuiCF["media"].blank,
	insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult},
}

------------------------------------------------------------------------
-- Frame Sizes
------------------------------------------------------------------------
local player_width = TukuiDB.Scale(220)
local player_height = TukuiDB.Scale(40)

local target_width = TukuiDB.Scale(220)
local target_height = TukuiDB.Scale(40)

local smallframe_width = TukuiDB.Scale(95)
local smallframe_height = TukuiDB.Scale(30)

local arenaboss_width = TukuiDB.Scale(180)
local arenaboss_height = TukuiDB.Scale(23)

local assisttank_width = TukuiDB.Scale(100)
local assisttank_height = TukuiDB.Scale(20)

--Offset of PowerBar for Player/Target
local powerbar_offset = TukuiDB.Scale(11)

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	-- Set Colors
	self.colors = TukuiDB.oUF_colors
	
	-- Register Frames for Click
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- Setup Menu
	self.menu = TukuiDB.SpawnMenu
	
	-- Update all elements on show
	self:HookScript("OnShow", TukuiDB.updateAllElements)
	
	-- For Testing..
	--[[self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)]]
	
	-- Border for non Player/Target frames
	if not (unit == "player" or unit == "target") then
		local FrameBorder = CreateFrame("Frame", nil, self)
		FrameBorder:SetPoint("TOPLEFT", self, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		TukuiDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		
		TukuiDB.CreateShadow(self.FrameBorder)
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
	end
		
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
		health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -powerbar_offset, powerbar_offset)
		health:SetStatusBarTexture(normTex)
		self.health = health
		
		-- Border for HealthBar
		local FrameBorder = CreateFrame("Frame", nil, health)
		FrameBorder:SetPoint("TOPLEFT", health, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		TukuiDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		TukuiDB.CreateShadow(self.FrameBorder)
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
	
		-- Health Bar Background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		health.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
		health.value:SetPoint("RIGHT", health, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
		health.PostUpdate = TukuiDB.PostUpdateHealth
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
			health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))	
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
		end
		health.colorDisconnected = false
		
		-- Power Frame Border
		local PowerFrame = CreateFrame("Frame", nil, self)
		PowerFrame:SetHeight(original_height)
		PowerFrame:SetWidth(original_width)
		PowerFrame:SetFrameLevel(self:GetFrameLevel() - 1)
		PowerFrame:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", powerbar_offset, -powerbar_offset)

		TukuiDB.SetTemplate(PowerFrame)
		PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
		self.PowerFrame = PowerFrame
		TukuiDB.CreateShadow(self.PowerFrame)
		
		-- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", TukuiDB.mult*2, -TukuiDB.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -TukuiDB.mult*2, TukuiDB.mult*2)
		power:SetStatusBarTexture(normTex)
		power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)
				
		-- Power Background
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		power.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
		power.value:SetPoint("LEFT", health, "LEFT", TukuiDB.Scale(4), TukuiDB.Scale(1))
		power.PreUpdate = TukuiDB.PreUpdatePower
		power.PostUpdate = TukuiDB.PostUpdatePower
		
		--Adjust player frame size
		player_width = player_width + powerbar_offset
		player_height = player_height + powerbar_offset
		
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
		if TukuiCF["unitframes"].debuffhighlight == true then
			local dbh = health:CreateTexture(nil, "OVERLAY", health)
			dbh:SetAllPoints(health)
			dbh:SetTexture(TukuiCF["media"].normTex)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.4		
		end
		
		-- Portraits
		if (db.charportrait == true) then
			local PFrame = CreateFrame("Frame", nil, self)
			PFrame:SetPoint('TOPRIGHT', self.Health,'TOPLEFT', TukuiDB.Scale(-6), TukuiDB.Scale(2))
			PFrame:SetWidth(original_width/5)
			PFrame:SetHeight(original_height+ TukuiDB.Scale(11))
			TukuiDB.SetTemplate(PFrame)
			PFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
			self.PFrame = PFrame
			TukuiDB.CreateShadow(self.PFrame)			
			local portrait = CreateFrame("PlayerModel", nil, PFrame)
			portrait:SetFrameLevel(2)
			
			--dont ask me why but the playerframe looks completely fucked when i set it how it should be..
			portrait:SetPoint('BOTTOMLEFT', PFrame, 'BOTTOMLEFT', TukuiDB.Scale(1), TukuiDB.Scale(2))		
			portrait:SetPoint('TOPRIGHT', PFrame, 'TOPRIGHT', TukuiDB.Scale(-2), TukuiDB.Scale(-2))	
			table.insert(self.__elements, TukuiDB.HidePortrait)
		
			self.Portrait = portrait
			player_width = player_width + (PFrame:GetWidth() + TukuiDB.Scale(6))
		end
			
		-- combat icon
		local Combat = health:CreateTexture(nil, "OVERLAY")
		Combat:SetHeight(TukuiDB.Scale(19))
		Combat:SetWidth(TukuiDB.Scale(19))
		Combat:SetPoint("CENTER",0,7)
		Combat:SetVertexColor(0.69, 0.31, 0.31)
		self.Combat = Combat

		-- custom info (low mana warning)
		FlashInfo = CreateFrame("Frame", "FlashInfo", self)
		FlashInfo:SetScript("OnUpdate", TukuiDB.UpdateManaLevel)
		FlashInfo.parent = self
		FlashInfo:SetToplevel(true)
		FlashInfo:SetAllPoints(health)
		FlashInfo.ManaLevel = TukuiDB.SetFontString(FlashInfo, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
		FlashInfo.ManaLevel:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(-5))
		self.FlashInfo = FlashInfo
		
		-- pvp status text
		local status = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
		status:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(-5))
		status:SetTextColor(0.69, 0.31, 0.31, 0)
		self.Status = status
		self:Tag(status, "[pvp]")
		
		-- script for pvp status and low mana
		self:SetScript("OnEnter", function(self) FlashInfo.ManaLevel:Hide() status:SetAlpha(1) UnitFrame_OnEnter(self) end)
		self:SetScript("OnLeave", function(self) FlashInfo.ManaLevel:Show() status:SetAlpha(0) UnitFrame_OnLeave(self) end)
		
		-- leader icon
		local Leader = health:CreateTexture(nil, "OVERLAY")
		Leader:SetHeight(TukuiDB.Scale(14))
		Leader:SetWidth(TukuiDB.Scale(14))
		Leader:SetPoint("TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(8))
		self.Leader = Leader
		
		-- master looter
		local MasterLooter = health:CreateTexture(nil, "OVERLAY")
		MasterLooter:SetHeight(TukuiDB.Scale(14))
		MasterLooter:SetWidth(TukuiDB.Scale(14))
		self.MasterLooter = MasterLooter
		self:RegisterEvent("PARTY_LEADER_CHANGED", TukuiDB.MLAnchorUpdate)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", TukuiDB.MLAnchorUpdate)
					
		-- the threat bar below minimap
		if db.showthreat == true and not IsAddOnLoaded("Omen") then
			-- the threat bar
			local ThreatBar = CreateFrame("StatusBar", self:GetName()..'_ThreatBar', self)
			ThreatBar:SetWidth(original_width)
			ThreatBar:SetHeight(TukuiDB.Scale(5))
			ThreatBar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + -TukuiDB.Scale(5))
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
			TukuiDB.SetTemplate(self.ThreatBar.F)
			self.ThreatBar.F:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			self.ThreatBar.F:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			self.ThreatBar.F:SetFrameLevel(self.ThreatBar:GetFrameLevel() - 1)
		end
		
		-- swingbar
		if db.swingbar == true then
			local Swing = CreateFrame("StatusBar", self:GetName().."_SwingBar", TukuiActionBarBackground)
			Swing:SetStatusBarTexture(normTex)
			Swing:SetStatusBarColor(unpack(TukuiCF["media"].bordercolor))
			Swing:GetStatusBarTexture():SetHorizTile(false)
			self.Swing = Swing
			
			self.Swing:SetHeight(TukuiDB.Scale(4))
			self.Swing:SetWidth(TukuiActionBarBackground:GetWidth()-TukuiDB.Scale(4))
			self.Swing:SetPoint("BOTTOM", TukuiActionBarBackground, "TOP", 0, TukuiDB.Scale(4))
			
			self.Swing.bg = CreateFrame("Frame", nil, self.Swing)
			self.Swing.bg:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			self.Swing.bg:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			self.Swing.bg:SetFrameStrata("BACKGROUND")
			self.Swing.bg:SetFrameLevel(self.Swing:GetFrameLevel() - 1)
			TukuiDB.SetTemplate(self.Swing.bg)
		end
		
		-- experience bar on player via mouseover for player currently levelling a character
		if TukuiDB.level ~= MAX_PLAYER_LEVEL then
			local Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self)
			Experience:SetStatusBarTexture(normTex)
			Experience:SetStatusBarColor(0, 0.4, 1, .8)
			Experience:SetWidth(original_width)
			Experience:SetHeight(TukuiDB.Scale(5))
			Experience:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + -TukuiDB.Scale(5))
			Experience.noTooltip = true
			Experience:EnableMouse(true)
			self.Experience = Experience

			
			Experience.Text = self.Experience:CreateFontString(nil, 'OVERLAY')
			Experience.Text:SetFont(font1, TukuiCF["unitframes"].fontsize, "OUTLINE")
			Experience.Text:SetPoint('CENTER', self.Experience)
			Experience.Text:Hide()
			self.Experience.Text = Experience.Text
			self.Experience.PostUpdate = TukuiDB.ExperienceText
			
			Experience:SetScript("OnEnter", function(self) if not InCombatLockdown() then Experience:SetHeight(TukuiDB.Scale(20)) Experience.Text:Show() end end)
			Experience:SetScript("OnLeave", function(self) if not InCombatLockdown() then Experience:SetHeight(TukuiDB.Scale(5)) Experience.Text:Hide() end end)
			
			self.Experience.Rested = CreateFrame('StatusBar', nil, self.Experience)
			self.Experience.Rested:SetAllPoints(self.Experience)
			self.Experience.Rested:SetStatusBarTexture(normTex)
			self.Experience.Rested:SetStatusBarColor(1, 0, 1, 0.2)
			self.Experience.Rested:SetBackdrop(backdrop)
			self.Experience.Rested:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))

			
			local Resting = Experience:CreateTexture(nil, "OVERLAY", Experience.Rested)
			Resting:SetHeight(22)
			Resting:SetWidth(22)
			Resting:SetPoint("CENTER", self.Health, "TOPLEFT", TukuiDB.Scale(-3), TukuiDB.Scale(6))
			Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
			Resting:SetTexCoord(0, 0.5, 0, 0.421875)
			Resting:Hide()
			self.Resting = Resting
			
			self.Experience.F = CreateFrame("Frame", nil, self.Experience)
			TukuiDB.SetTemplate(self.Experience.F)
			self.Experience.F:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			self.Experience.F:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			self.Experience.F:SetFrameLevel(self.Experience:GetFrameLevel() - 1)
			self:RegisterEvent("PLAYER_UPDATE_RESTING", TukuiDB.RestingIconUpdate)
		end
		
		-- reputation bar for max level character
		if TukuiDB.level == MAX_PLAYER_LEVEL then
			local Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self)
			Reputation:SetStatusBarTexture(normTex)
			Reputation:SetBackdrop(backdrop)
			Reputation:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
			Reputation:SetWidth(original_width)
			Reputation:SetHeight(TukuiDB.Scale(5))
			Reputation:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + -TukuiDB.Scale(5))
			Reputation.Tooltip = true

			Reputation:HookScript("OnEnter", function(self)
				if not InCombatLockdown() then
						Reputation:SetHeight(TukuiDB.Scale(20))
				end
			end)
			
			Reputation:HookScript("OnLeave", function(self)
				if not InCombatLockdown() then
						Reputation:SetHeight(TukuiDB.Scale(5))
				end
			end)

			Reputation.PostUpdate = TukuiDB.UpdateReputationColor
			
			self.Reputation = Reputation
			self.Reputation.F = CreateFrame("Frame", nil, self.Reputation)
			TukuiDB.SetTemplate(self.Reputation.F)
			self.Reputation.F:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			self.Reputation.F:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			self.Reputation.F:SetFrameLevel(self.Reputation:GetFrameLevel() - 1)
		end
		

		-- show druid mana when shapeshifted in bear, cat or whatever
		if TukuiDB.myclass == "DRUID" then
			--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
			self.FrameBorder.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(17))
			player_height = player_height + TukuiDB.Scale(14)
			
			CreateFrame("Frame"):SetScript("OnUpdate", function() TukuiDB.UpdateDruidMana(self) end)
			local DruidMana = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
			DruidMana:SetTextColor(1, 0.49, 0.04)
			self.DruidMana = DruidMana
				local eclipseBar = CreateFrame('Frame', nil, self)
				eclipseBar:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, TukuiDB.Scale(5))
				eclipseBar:SetSize(original_width, TukuiDB.Scale(8))
				eclipseBar:SetFrameStrata("MEDIUM")
				eclipseBar:SetFrameLevel(8)
				TukuiDB.SetTemplate(eclipseBar)
				eclipseBar:SetBackdropBorderColor(0,0,0,0)
				eclipseBar:SetScript("OnShow", function() TukuiDB.EclipseDisplay(self, false) end)
				eclipseBar:SetScript("OnUpdate", function() TukuiDB.EclipseDisplay(self, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
				eclipseBar:SetScript("OnHide", function() TukuiDB.EclipseDisplay(self, false) end)
				
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
				eclipseBarText:SetPoint("CENTER", self.Health, "CENTER", TukuiDB.Scale(1), TukuiDB.Scale(-5))
				eclipseBarText:SetFont(font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
				eclipseBar.Text = eclipseBarText

				self.EclipseBar = eclipseBar
				
				eclipseBar.FrameBackdrop = CreateFrame("Frame", nil, eclipseBar)
				TukuiDB.SetTemplate(eclipseBar.FrameBackdrop)
				eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
				eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
				eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)
		end

		-- set holy power bar or shard bar
		if (TukuiDB.myclass == "WARLOCK" or TukuiDB.myclass == "PALADIN") then
			--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
			self.FrameBorder.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(17))
			player_height = player_height + TukuiDB.Scale(14)
			
			local bars = CreateFrame("Frame", nil, self)
			bars:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, TukuiDB.Scale(5))
			bars:SetWidth(original_width)
			bars:SetHeight(TukuiDB.Scale(8))
			TukuiDB.SetTemplate(bars)
			bars:SetBackdropBorderColor(0,0,0,0)
			
			for i = 1, 3 do					
				bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
				bars[i]:SetHeight(TukuiDB.Scale(8))					
				bars[i]:SetStatusBarTexture(normTex)
				bars[i]:GetStatusBarTexture():SetHorizTile(false)

				bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
				
				if TukuiDB.myclass == "WARLOCK" then
					bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
					bars[i].bg:SetTexture(148/255, 130/255, 201/255)
				elseif TukuiDB.myclass == "PALADIN" then
					bars[i]:SetStatusBarColor(228/255,225/255,16/255)
					bars[i].bg:SetTexture(228/255,225/255,16/255)
				end
				
				if i == 1 then
					bars[i]:SetPoint("LEFT", bars)
				else
					bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", TukuiDB.Scale(1), 0)
				end
				
				bars[i].bg:SetAllPoints(bars[i])
				bars[i]:SetWidth(TukuiDB.Scale(original_width - 2)/3)
				
				bars[i].bg:SetTexture(normTex)					
				bars[i].bg:SetAlpha(.15)
			end
			
			
			if TukuiDB.myclass == "WARLOCK" then
				bars.Override = TukuiDB.UpdateShards				
				self.SoulShards = bars
			elseif TukuiDB.myclass == "PALADIN" then
				bars.Override = TukuiDB.UpdateHoly
				self.HolyPower = bars
			end
			bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
			TukuiDB.SetTemplate(bars.FrameBackdrop)
			bars.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
		end

		-- deathknight runes
		if TukuiDB.myclass == "DEATHKNIGHT" and db.runebar == true then
			--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
			self.FrameBorder.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(17))
			player_height = player_height + TukuiDB.Scale(14)
				
			local Runes = CreateFrame("Frame", nil, self)
			Runes:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, TukuiDB.Scale(5))
			Runes:SetHeight(TukuiDB.Scale(8))
			Runes:SetWidth(original_width)

			Runes:SetBackdrop(backdrop)
			Runes:SetBackdropColor(0, 0, 0)

			for i = 1, 6 do
				Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
				Runes[i]:SetHeight(TukuiDB.Scale(8))
				Runes[i]:SetWidth((original_width - 5) / 6)

				if (i == 1) then
					Runes[i]:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, TukuiDB.Scale(5))
				else
					Runes[i]:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", TukuiDB.Scale(1), 0)
				end
				Runes[i]:SetStatusBarTexture(normTex)
				Runes[i]:GetStatusBarTexture():SetHorizTile(false)
			end

			Runes.FrameBackdrop = CreateFrame("Frame", nil, Runes)
			TukuiDB.SetTemplate(Runes.FrameBackdrop)
			Runes.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			Runes.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			Runes.FrameBackdrop:SetFrameLevel(Runes:GetFrameLevel() - 1)
			self.Runes = Runes
			
			self.Runes:HookScript("OnShow", function()
				if self.Debuffs then self.Debuffs:ClearAllPoints() self.Debuffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", TukuiDB.Scale(1), TukuiDB.Scale(17)) end	
			end)
		end
			
		-- shaman totem bar
		if TukuiDB.myclass == "SHAMAN" and db.totemtimer == true then
			--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
			self.FrameBorder.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(17))
			player_height = player_height + TukuiDB.Scale(14)
							
			local TotemBar = CreateFrame("Frame", nil, self)
			TotemBar.Destroy = true
			TotemBar:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, TukuiDB.Scale(5))
			TotemBar:SetHeight(TukuiDB.Scale(8))
			TotemBar:SetWidth(original_width)

			TotemBar:SetBackdrop(backdrop)
			TotemBar:SetBackdropColor(0, 0, 0)

			for i = 1, 4 do
				TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
				TotemBar[i]:SetHeight(TukuiDB.Scale(8))
				TotemBar[i]:SetWidth((original_width - 3) / 4)

				if (i == 1) then
					TotemBar[i]:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, TukuiDB.Scale(5))
				else
					TotemBar[i]:SetPoint("TOPLEFT", TotemBar[i-1], "TOPRIGHT", TukuiDB.Scale(1), 0)
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
			TukuiDB.SetTemplate(TotemBar.FrameBackdrop)
			TotemBar.FrameBackdrop:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			TotemBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			TotemBar.FrameBackdrop:SetFrameLevel(TotemBar:GetFrameLevel() - 1)
			self.TotemBar = TotemBar
			self.TotemBar:HookScript("OnShow", function()
				if self.Debuffs then self.Debuffs:ClearAllPoints() self.Debuffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", TukuiDB.Scale(1), TukuiDB.Scale(17)) end	
			end)
		end
				
		-- auras 
		if TukuiCF["auras"].playerauras then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)

			debuffs:SetHeight(((26 / original_width) * original_width))
			debuffs:SetWidth(original_width + TukuiDB.Scale(4))
			debuffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", TukuiDB.Scale(1), TukuiDB.Scale(6))
			debuffs.size = (debuffs:GetHeight())
			debuffs.num = (floor(debuffs:GetWidth() / debuffs:GetHeight()))
			debuffs.spacing = 2
			debuffs.initialAnchor = 'TOPRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = TukuiDB.PostCreateAura
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			
			if TukuiCF["auras"].playershowonlydebuffs == false then
				buffs:SetPoint("BOTTOM", debuffs, "TOP", 0, TukuiDB.Scale(2))
				buffs:SetHeight(debuffs:GetHeight())
				buffs:SetWidth(debuffs:GetWidth())
				buffs.size = (debuffs:GetHeight())
				buffs.num = (floor(debuffs:GetWidth() / debuffs:GetHeight()))
				buffs.spacing = 2
				buffs.initialAnchor = 'TOPLEFT'
				buffs.PostCreateIcon = TukuiDB.PostCreateAura
				buffs.PostUpdateIcon = TukuiDB.PostUpdateAura
				self.Buffs = buffs	
			end
			
			self.Debuffs = debuffs
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = TukuiDB.AuraFilter
		end
			
		-- cast bar for player and target
		if TukuiCF["castbar"].unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			if TukuiCF["castbar"].castermode == true then
				castbar:SetWidth(TukuiActionBarBackground:GetWidth() - TukuiDB.Scale(2))
				castbar:SetPoint("BOTTOMRIGHT", TukuiActionBarBackground, "TOPRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(5))
			else
				castbar:SetWidth(original_width)
				castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -powerbar_offset + -TukuiDB.Scale(5))
			end
 
			castbar:SetHeight(TukuiDB.Scale(20))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
 
			castbar.bg = CreateFrame("Frame", nil, castbar)
			TukuiDB.SetTemplate(castbar.bg)
			castbar.bg:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)
 
			castbar.time = TukuiDB.SetFontString(castbar, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = CustomCastTimeText
 
			castbar.Text = TukuiDB.SetFontString(castbar, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
 
			castbar.CustomDelayText = TukuiDB.CustomCastDelayText
			castbar.PostCastStart = TukuiDB.PostCastStart
			castbar.PostChannelStart = TukuiDB.PostCastStart
 
			-- cast bar latency on player
			if TukuiCF["castbar"].cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end			
 
			if TukuiCF["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(castbar:GetHeight()+TukuiDB.Scale(4))
				castbar.button:SetWidth(castbar:GetHeight()+TukuiDB.Scale(4))
				castbar.button:SetPoint("RIGHT", castbar, "LEFT", TukuiDB.Scale(-4), 0)
				TukuiDB.SetTemplate(castbar.button)
 
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				if TukuiCF["castbar"].castermode == true and unit == "player" then
					castbar:SetWidth(TukuiActionBarBackground:GetWidth() - castbar.button:GetWidth() - TukuiDB.Scale(6))
				else
					castbar:SetWidth(original_width - castbar.button:GetWidth() - TukuiDB.Scale(2))
				end
			end
 
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if db.combatfeedback == true then
			local CombatFeedbackText 
			CombatFeedbackText = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize*1.1, "OUTLINE")

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
			table.insert(self.__elements, TukuiDB.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', TukuiDB.UpdateThreat)
		end
		
		-- update all frames when changing area, to fix exiting instance while in vehicle
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", TukuiDB.updateAllElements)
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
		health:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", powerbar_offset, powerbar_offset)
		health:SetStatusBarTexture(normTex)
		self.health = health
		
		-- Border for HealthBar
		local FrameBorder = CreateFrame("Frame", nil, health)
		FrameBorder:SetPoint("TOPLEFT", health, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		TukuiDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		TukuiDB.CreateShadow(self.FrameBorder)
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
	
		-- Health Bar Background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		health.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
		health.value:SetPoint("RIGHT", health, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
		health.PostUpdate = TukuiDB.PostUpdateHealth
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
			health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))	
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
		end
		health.colorDisconnected = false
		
		
		-- Power Frame Border
		local PowerFrame = CreateFrame("Frame", nil, self)
		PowerFrame:SetHeight(original_height)
		PowerFrame:SetWidth(original_width)
		PowerFrame:SetFrameLevel(self:GetFrameLevel() - 1)
		PowerFrame:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", -powerbar_offset, -powerbar_offset)
		TukuiDB.SetTemplate(PowerFrame)
		PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
		self.PowerFrame = PowerFrame
		TukuiDB.CreateShadow(self.PowerFrame)
		
		-- Power Bar
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", TukuiDB.mult*2, -TukuiDB.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -TukuiDB.mult*2, TukuiDB.mult*2)
		power:SetStatusBarTexture(normTex)
		power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)
				
		-- Power Background
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		power.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
		power.value:SetPoint("LEFT", health, "LEFT", TukuiDB.Scale(4), TukuiDB.Scale(1))
		power.PreUpdate = TukuiDB.PreUpdatePower
		power.PostUpdate = TukuiDB.PostUpdatePower
		target_width = target_width + powerbar_offset
		target_height = target_height + powerbar_offset
		
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
		if TukuiCF["unitframes"].debuffhighlight == true then
			local dbh = health:CreateTexture(nil, "OVERLAY", health)
			dbh:SetAllPoints(health)
			dbh:SetTexture(TukuiCF["media"].normTex)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.4		
		end
		
		-- Portraits
		if (db.charportrait == true) then
			local PFrame = CreateFrame("Frame", nil, self)
			PFrame:SetPoint('TOPLEFT', self.Health,'TOPRIGHT', TukuiDB.Scale(6), TukuiDB.Scale(2))
			PFrame:SetWidth(original_width/5)
			PFrame:SetHeight(original_height+ TukuiDB.Scale(11))
			TukuiDB.SetTemplate(PFrame)
			PFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
			self.PFrame = PFrame
			TukuiDB.CreateShadow(self.PFrame)			
			local portrait = CreateFrame("PlayerModel", nil, PFrame)
			portrait:SetFrameLevel(2)
			
			portrait:SetPoint('BOTTOMLEFT', PFrame, 'BOTTOMLEFT', TukuiDB.Scale(2), TukuiDB.Scale(2))		
			portrait:SetPoint('TOPRIGHT', PFrame, 'TOPRIGHT', TukuiDB.Scale(-2), TukuiDB.Scale(-2))		
			table.insert(self.__elements, TukuiDB.HidePortrait)
		
			self.Portrait = portrait
			target_width = target_width + (PFrame:GetWidth() + TukuiDB.Scale(6))
		end
						
		-- Unit name on target
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("LEFT", health, "LEFT", 0, TukuiDB.Scale(1))
		Name:SetJustifyH("LEFT")
		Name:SetFont(font1, TukuiCF["unitframes"].fontsize, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
		self.Name = Name

		if TukuiCF["auras"].targetauras then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			
			buffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", TukuiDB.Scale(-1), TukuiDB.Scale(4))
			buffs:SetHeight(((26 / original_width) * original_width))
			buffs:SetWidth(original_width + TukuiDB.Scale(4))
			buffs.size = (buffs:GetHeight())
			buffs.num = (floor(buffs:GetWidth() / buffs:GetHeight()))
			buffs.spacing = 2
			buffs.initialAnchor = 'TOPLEFT'
			buffs.PostCreateIcon = TukuiDB.PostCreateAura
			buffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Buffs = buffs	
			
			debuffs:SetHeight(buffs:GetHeight())
			debuffs:SetWidth(buffs:GetWidth())
			debuffs:SetPoint("BOTTOM", buffs, "TOP", 0, TukuiDB.Scale(2))
			debuffs.size = (debuffs:GetHeight())
			debuffs.num = (floor(debuffs:GetWidth() / debuffs:GetHeight()))
			debuffs.spacing = 2
			debuffs.initialAnchor = 'TOPRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = TukuiDB.PostCreateAura
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
			
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = TukuiDB.AuraFilter
		end
		
		-- cast bar for target
		if TukuiCF["castbar"].unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetWidth(original_width)
			castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -powerbar_offset + -TukuiDB.Scale(5))
 
			castbar:SetHeight(TukuiDB.Scale(20))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
 
			castbar.bg = CreateFrame("Frame", nil, castbar)
			TukuiDB.SetTemplate(castbar.bg)
			castbar.bg:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)
 
			castbar.time = TukuiDB.SetFontString(castbar, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = CustomCastTimeText
 
			castbar.Text = TukuiDB.SetFontString(castbar, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
 
			castbar.CustomDelayText = TukuiDB.CustomCastDelayText
			castbar.PostCastStart = TukuiDB.PostCastStart
			castbar.PostChannelStart = TukuiDB.PostCastStart
  
			if TukuiCF["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(castbar:GetHeight()+TukuiDB.Scale(4))
				castbar.button:SetWidth(castbar:GetHeight()+TukuiDB.Scale(4))
				castbar.button:SetPoint("RIGHT", castbar, "LEFT", TukuiDB.Scale(-4), 0)
				TukuiDB.SetTemplate(castbar.button)
 
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				castbar:SetWidth(original_width - castbar.button:GetWidth() - TukuiDB.Scale(2))
			end
 
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if db.combatfeedback == true then
			local CombatFeedbackText 
			CombatFeedbackText = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize*1.1, "OUTLINE")
			
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
		if TukuiDB.myclass == "DRUID" or TukuiDB.myclass == "ROGUE" then
			target_height = target_height + TukuiDB.Scale(14)
		end
		
		local bars = CreateFrame("Frame", nil, self)
		bars:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, TukuiDB.Scale(5))
		bars:SetWidth(original_width)
		bars:SetHeight(TukuiDB.Scale(8))
		TukuiDB.SetTemplate(bars)
		bars:SetBackdropBorderColor(0,0,0,0)
		bars:SetBackdropColor(0,0,0,0)
		
		for i = 1, 5 do					
			bars[i] = CreateFrame("StatusBar", self:GetName().."_Combo"..i, self)
			bars[i]:SetHeight(TukuiDB.Scale(8))					
			bars[i]:SetStatusBarTexture(normTex)
			bars[i]:GetStatusBarTexture():SetHorizTile(false)
							
			if i == 1 then
				bars[i]:SetPoint("LEFT", bars)
			else
				bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", TukuiDB.Scale(1), 0)
			end
			bars[i]:SetAlpha(0.15)
			bars[i]:SetWidth(TukuiDB.Scale(original_width - 4)/5)
		end
		
		bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
		bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
		bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
		

		self.CPoints = bars
		self.CPoints.Override = TukuiDB.ComboDisplay
		
		bars.FrameBackdrop = CreateFrame("Frame", nil, bars[1])
		TukuiDB.SetTemplate(bars.FrameBackdrop)
		bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
		
	end
	
	------------------------------------------------------------------------
	--	Target of Target, Pet, focus, focustarget unit layout mirrored
	------------------------------------------------------------------------
	
	if (unit == "targettarget" or unit == "pet" or unit == "focustarget" or unit == "focus") then
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetPoint("TOPLEFT")
		health:SetPoint("BOTTOMRIGHT")
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		self.Health = health
		self.Health.bg = healthBG
				
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))	
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
		end
		health.colorDisconnected = false
		healthBG.multiplier = 0.3
		
		-- power frame
		local PowerFrame = CreateFrame("Frame", nil, self)
		PowerFrame:SetHeight(smallframe_height)
		PowerFrame:SetWidth(smallframe_width)
		PowerFrame:SetFrameLevel(self:GetFrameLevel() - 1)
		if unit == "focustarget" or unit == "targettarget" then
			PowerFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", TukuiDB.Scale(7), TukuiDB.Scale(-7))
		elseif unit == "focus" or unit == "pet" then
			PowerFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", TukuiDB.Scale(-7), TukuiDB.Scale(-7))
		end
		PowerFrame:SetFrameStrata("LOW")
		TukuiDB.SetTemplate(PowerFrame)
		PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
		TukuiDB.CreateShadow(PowerFrame)
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", TukuiDB.mult*2, -TukuiDB.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -TukuiDB.mult*2, TukuiDB.mult*2)
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
		dbh:SetTexture(TukuiCF["media"].normTex)
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
		Name:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(1))
		Name:SetFont(font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
		Name:SetJustifyH("CENTER")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		if unit == "targettarget" and TukuiCF["auras"].totdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:SetHeight((20 / smallframe_width) * smallframe_width)
			debuffs:SetWidth(smallframe_width)
			debuffs.size = ((20 / smallframe_width) * smallframe_width)
			debuffs.spacing = 2
			debuffs.num = 4

			debuffs:SetPoint("TOP", self, "BOTTOM", TukuiDB.Scale(7), -TukuiDB.Scale(10))
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = TukuiDB.PostCreateAuraSmall
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = TukuiDB.AuraFilter
		end
		
		if unit == "focus" and TukuiCF["auras"].focusdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:SetHeight((20 / smallframe_width) * smallframe_width)
			debuffs:SetWidth(smallframe_width)
			debuffs.size = ((20 / smallframe_width) * smallframe_width)
			debuffs.spacing = 2
			debuffs.num = 4

			debuffs:SetPoint("TOP", self, "BOTTOM", TukuiDB.Scale(7), -TukuiDB.Scale(10))
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = TukuiDB.PostCreateAuraSmall
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = TukuiDB.AuraFilter
		end
		
		if unit == "pet" then
			if (TukuiCF["castbar"].unitcastbar == true) then
				local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
				castbar:SetStatusBarTexture(normTex)
				self.Castbar = castbar
			end
		end
		
		if TukuiCF["castbar"].unitcastbar == true and unit == "focus" then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetHeight(TukuiDB.Scale(20))
			castbar:SetWidth(TukuiDB.Scale(240))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			castbar:SetPoint("CENTER", UIParent, "CENTER", 0, 250)		
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			TukuiDB.SetTemplate(castbar.bg)
			castbar.bg:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			
			castbar.time = TukuiDB.SetFontString(castbar, font1, TukuiCF["unitframes"].fontsize)
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = CustomCastTimeText

			castbar.Text = TukuiDB.SetFontString(castbar, font1, TukuiCF["unitframes"].fontsize)
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomDelayText = TukuiDB.CustomCastDelayText
			castbar.PostCastStart = TukuiDB.PostCastStart
			castbar.PostChannelStart = TukuiDB.PostCastStart
			
			castbar.CastbarBackdrop = CreateFrame("Frame", nil, castbar)
			castbar.CastbarBackdrop:SetPoint("TOPLEFT", castbar, "TOPLEFT", TukuiDB.Scale(-6), TukuiDB.Scale(6))
			castbar.CastbarBackdrop:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", TukuiDB.Scale(6), TukuiDB.Scale(-6))
			castbar.CastbarBackdrop:SetParent(castbar)
			castbar.CastbarBackdrop:SetFrameStrata("BACKGROUND")
			castbar.CastbarBackdrop:SetFrameLevel(4)
			castbar.CastbarBackdrop:SetBackdrop({
				edgeFile = glowTex, edgeSize = 4,
				insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
			castbar.CastbarBackdrop:SetBackdropColor(0, 0, 0, 0)
			castbar.CastbarBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
			
			if TukuiCF["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(TukuiDB.Scale(40))
				castbar.button:SetWidth(TukuiDB.Scale(40))
				castbar.button:SetPoint("CENTER", 0, TukuiDB.Scale(50))
				TukuiDB.SetTemplate(castbar.button)
				
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				
				castbar.IconBackdrop = CreateFrame("Frame", nil, self)
				castbar.IconBackdrop:SetPoint("TOPLEFT", castbar.button, "TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(4))
				castbar.IconBackdrop:SetPoint("BOTTOMRIGHT", castbar.button, "BOTTOMRIGHT", TukuiDB.Scale(4), TukuiDB.Scale(-4))
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
		
		self:RegisterEvent("UNIT_PET", TukuiDB.updateAllElements)	
	end
	
	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and TukuiCF["arena"].unitframes == true) or (unit and unit:find("boss%d") and TukuiCF["raidframes"].showboss == true) then
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(arenaboss_height)
		health:SetPoint("TOPLEFT")
		if (unit and unit:find('arena%d')) then
			health:SetPoint("TOPRIGHT", -arenaboss_height*.80, 0)
		else
			health:SetPoint("TOPRIGHT")
		end
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)

		health.value = TukuiDB.SetFontString(health, font1,TukuiCF["unitframes"].fontsize, "OUTLINE")
		health.value:SetPoint("LEFT", TukuiDB.Scale(2), TukuiDB.Scale(1))
		health.PostUpdate = TukuiDB.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))	
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
		end
		health.colorDisconnected = false
		healthBG.multiplier = 0.3
		
		-- power frame
		local PowerFrame = CreateFrame("Frame", nil, self)
		PowerFrame:SetHeight(arenaboss_height)
		PowerFrame:SetWidth(arenaboss_width)
		PowerFrame:SetFrameLevel(self:GetFrameLevel() - 1)
		PowerFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", TukuiDB.Scale(7), TukuiDB.Scale(-7))
		
		TukuiDB.SetTemplate(PowerFrame)
		PowerFrame:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
		TukuiDB.CreateShadow(PowerFrame)
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", TukuiDB.mult*2, -TukuiDB.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -TukuiDB.mult*2, TukuiDB.mult*2)
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
		
		if (unit and unit:find('arena%d')) then
			power.value = TukuiDB.SetFontString(health, font1, TukuiCF["unitframes"].fontsize, "OUTLINE")
			power.value:SetPoint("RIGHT", health, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
			power.PreUpdate = TukuiDB.PreUpdatePower
			power.PostUpdate = TukuiDB.PostUpdatePower
		end

		
		self.Power = power
		self.Power.bg = powerBG
		
		-- names
		local Name
		if (unit and unit:find('arena%d')) then
			Name = health:CreateFontString(nil, "OVERLAY")
			Name:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(1))
			Name:SetJustifyH("CENTER")
			Name:SetFont(font1, TukuiCF["unitframes"].fontsize, "OUTLINE")
			Name:SetShadowColor(0, 0, 0)
			Name:SetShadowOffset(1.25, -1.25)
		else
			Name = health:CreateFontString(nil, "OVERLAY")
			Name:SetPoint("RIGHT", health, "RIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(1))
			Name:SetJustifyH("RIGHT")
			Name:SetFont(font1, TukuiCF["unitframes"].fontsize, "OUTLINE")
			Name:SetShadowColor(0, 0, 0)
			Name:SetShadowOffset(1.25, -1.25)		
		end
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort] [Tukui:diffcolor][level] [shortclassification]')
		self.Name = Name
					
		-- trinket feature via trinket plugin
		if not IsAddOnLoaded("Gladius") then
			if (unit and unit:find('arena%d')) then
				local Trinketbg = CreateFrame("Frame", nil, self)
				Trinketbg:SetHeight(arenaboss_height)
				Trinketbg:SetWidth(arenaboss_height)
				Trinketbg:SetPoint("TOPRIGHT", self, "TOPRIGHT")				
				TukuiDB.SetTemplate(Trinketbg)
				Trinketbg:SetFrameLevel(self.Health:GetFrameLevel()+1)
				self.Trinketbg = Trinketbg
				
				local Trinket = CreateFrame("Frame", nil, Trinketbg)
				Trinket:SetAllPoints(Trinketbg)
				Trinket:SetPoint("TOPLEFT", Trinketbg, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				Trinket:SetPoint("BOTTOMRIGHT", Trinketbg, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				Trinket:SetFrameLevel(Trinketbg:GetFrameLevel()+1)
				Trinket.trinketUseAnnounce = true
				self.Trinket = Trinket
			end
		end
		
		--only need to see debuffs for arena frames
		if (unit and unit:find("arena%d")) and TukuiCF["auras"].arenadebuffs == true then
			-- create arena/boss debuff/buff spawn point
			local buffs = CreateFrame("Frame", nil, self)
			buffs:SetHeight(arenaboss_height)
			buffs:SetWidth(252)
			buffs:SetPoint("RIGHT", self, "LEFT", TukuiDB.Scale(-4), 0)
			buffs.size = arenaboss_height
			buffs.num = 3
			buffs.spacing = 2
			buffs.initialAnchor = 'RIGHT'
			buffs["growth-x"] = "LEFT"
			buffs.PostCreateIcon = TukuiDB.PostCreateAura
			buffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Buffs = buffs
			
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs:SetHeight(arenaboss_height)
			debuffs:SetWidth(arenaboss_width*2)
			debuffs:SetPoint("LEFT", self, "RIGHT", TukuiDB.Scale(4), 0)
			debuffs.size = arenaboss_height
			debuffs.num = 3
			debuffs.spacing = 2
			debuffs.initialAnchor = 'LEFT'
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = TukuiDB.PostCreateAura
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
			
			--set filter for buffs/debuffs
			self.Buffs.CustomFilter = TukuiDB.ArenaBuffFilter
			self.Debuffs.CustomFilter = TukuiDB.ArenaDebuffFilter
		end
		
		
		if TukuiCF["castbar"].unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetWidth(arenaboss_width)
			castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, TukuiDB.Scale(-12))		
			
			castbar:SetHeight(TukuiDB.Scale(14))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			TukuiDB.SetTemplate(castbar.bg)
			castbar.bg:SetPoint("TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			
			castbar.time = TukuiDB.SetFontString(castbar, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = CustomCastTimeText

			castbar.Text = TukuiDB.SetFontString(castbar, font1, TukuiCF["unitframes"].fontsize, "THINOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomDelayText = TukuiDB.CustomCastDelayText
			castbar.PostCastStart = TukuiDB.PostCastStart
			castbar.PostChannelStart = TukuiDB.PostCastStart
									
			if TukuiCF["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(castbar:GetHeight()+TukuiDB.Scale(4))
				castbar.button:SetWidth(castbar:GetHeight()+TukuiDB.Scale(4))
				castbar.button:SetPoint("RIGHT", castbar, "LEFT", TukuiDB.Scale(-4), 0)
				TukuiDB.SetTemplate(castbar.button)
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				castbar:SetWidth(arenaboss_width - castbar.button:GetWidth() - TukuiDB.Scale(2))
			end

			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end		
	end

	------------------------------------------------------------------------
	--	Main tanks and Main Assists layout (both mirror'd)
	------------------------------------------------------------------------
	
	if(self:GetParent():GetName():match"oUF_MainTank" or self:GetParent():GetName():match"oUF_MainAssist") then
		-- Right-click focus on maintank or mainassist units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:SetAllPoints()
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))	
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
		end
		health.colorDisconnected = false
		healthBG.multiplier = 0.3
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, TukuiDB.Scale(1))
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, TukuiCF["unitframes"].fontsize, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		self.Name = Name
	end

	------------------------------------------------------------------------
	--	Features we want for all units at the same time
	------------------------------------------------------------------------
	
	-- here we create an invisible frame for all element we want to show over health/power.
	-- because we can only use self here, and self is under all elements.
	local InvFrame = CreateFrame("Frame", nil, self)
	InvFrame:SetFrameStrata("HIGH")
	InvFrame:SetFrameLevel(5)
	InvFrame:SetAllPoints(self.Health)
	
	-- symbols, now put the symbol on the frame we created above.
	local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\raidicons.blp") 
	RaidIcon:SetHeight(15)
	RaidIcon:SetWidth(15)
	RaidIcon:SetPoint("TOP", 0, 8)
	self.RaidIcon = RaidIcon
	
	return self
end

------------------------------------------------------------------------
--	Default Positions
------------------------------------------------------------------------
oUF:RegisterStyle('Tukz', Shared)


-- Player
local player = oUF:Spawn('player', "oUF_Tukz_player")
player:SetPoint("BOTTOMRIGHT", TukuiActionBarBackground, "TOPLEFT", TukuiDB.Scale(-15),TukuiDB.Scale(185))
player:SetSize(player_width, player_height)

-- Target
local target = oUF:Spawn('target', "oUF_Tukz_target")
target:SetPoint("BOTTOMLEFT", TukuiActionBarBackground, "TOPRIGHT", TukuiDB.Scale(15),TukuiDB.Scale(185))
target:SetSize(target_width, target_height)

-- Focus
local focus = oUF:Spawn('focus', "oUF_Tukz_focus")
focus:SetPoint("TOPLEFT", oUF_Tukz_target, "BOTTOMLEFT", TukuiDB.Scale(9),TukuiDB.Scale(-42))
focus:SetSize(smallframe_width, smallframe_height)

-- Target's Target
local tot = oUF:Spawn('targettarget', "oUF_Tukz_targettarget")
tot:SetPoint("TOPRIGHT", oUF_Tukz_target, "BOTTOMRIGHT", 0,TukuiDB.Scale(-42))
tot:SetSize(smallframe_width, smallframe_height)

-- Player's Pet
local pet = oUF:Spawn('pet', "oUF_Tukz_pet")
pet:SetPoint("TOPLEFT", oUF_Tukz_player, "BOTTOMLEFT", 0,TukuiDB.Scale(-42))
pet:SetSize(smallframe_width, smallframe_height)

-- Focus's target
if db.showfocustarget == true then
	local focustarget = oUF:Spawn('focustarget', "oUF_Tukz_focustarget")
	focustarget:SetPoint("TOP", oUF_Tukz_focus, "BOTTOM", 0,TukuiDB.Scale(-32))
	focustarget:SetSize(smallframe_width, smallframe_height)
end


if TukuiCF.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
		if i == 1 then
			arena[i]:SetPoint("BOTTOMLEFT", RDummyFrame, "TOPLEFT", -80, 285)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 34)
		end
		arena[i]:SetSize(arenaboss_width, arenaboss_height)
	end
end

if TukuiCF.raidframes.showboss then
	for i = 1,MAX_BOSS_FRAMES do
		local t_boss = _G["Boss"..i.."TargetFrame"]
		t_boss:UnregisterAllEvents()
		t_boss.Show = TukuiDB.dummy
		t_boss:Hide()
		_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
		_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
	end

	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
		if i == 1 then
			boss[i]:SetPoint("BOTTOMLEFT", RDummyFrame, "TOPLEFT", -80, 285)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 34)             
		end
		boss[i]:SetSize(arenaboss_width, arenaboss_height)
	end
end


if TukuiCF["raidframes"].maintank == true then
	local tank = oUF:SpawnHeader('oUF_MainTank', nil, 'raid', 
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true, 
		'groupFilter', 'MAINTANK', 
		'yOffset', 7, 
		'point' , 'BOTTOM',
		'template', 'oUF_tukzMtt'
	)
	tank:SetPoint("BOTTOM", ChatLBackground, "TOP", -42, 450)
end

if TukuiCF["raidframes"].mainassist == true then
	local assist = oUF:SpawnHeader("oUF_MainAssist", nil, 'raid', 
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true, 
		'groupFilter', 'MAINASSIST', 
		'yOffset', 7, 
		'point' , 'BOTTOM',
		'template', 'oUF_tukzMtt'
	)
	if TukuiCF["raidframes"].maintank == true then 
		assist:SetPoint("TOPLEFT", oUF_MainTank, "BOTTOMLEFT", 2, -50)
	else
		assist:SetPoint("BOTTOM", ChatLBackground, "TOP", -42, 450)
	end
end

local party
if TukuiCF["raidframes"].disableblizz == true then --seriosly lazy addon authors can suck my dick
	party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)
	local blizzloader = CreateFrame("Frame")
	blizzloader:RegisterEvent("ADDON_LOADED")
	blizzloader:SetScript("OnEvent", function(self, event, addon)
		if addon == "Tukui_Heal_Layout" then 
			TukuiDB.Kill(CompactRaidFrameManager)
			TukuiDB.Kill(CompactRaidFrameContainer)
			TukuiDB.Kill(CompactPartyFrame)
		end
	end)
end

------------------------------------------------------------------------
--	Right-Click on unit frames menu.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "LEAVE", "CANCEL" };
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
if oUF_Tukz_player.ThreatBar then
	oUF_Tukz_player.ThreatBar:SetPoint("TOPLEFT", oUF_Tukz_target.Health, "BOTTOMLEFT", 0, -powerbar_offset + -TukuiDB.Scale(5))
end