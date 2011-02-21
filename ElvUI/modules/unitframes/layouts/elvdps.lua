local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales

if not C["unitframes"].enable == true then return end

------------------------------------------------------------------------
--	Variables
------------------------------------------------------------------------

local font1 = C["media"].uffont
local font2 = C["media"].font
local normTex = C["media"].normTex
local glowTex = C["media"].glowTex

local backdrop = {
	bgFile = C["media"].blank,
	insets = {top = -E.mult, left = -E.mult, bottom = -E.mult, right = -E.mult},
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
local powerbar_offset = E.Scale(C["unitframes"].poweroffset)

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	local resscale = 1
	if E.lowversion == true then resscale = 0.88 end
	--Set Sizes
	player_width = E.Scale(C["framesizes"].playtarwidth*resscale)
	player_height = E.Scale(C["framesizes"].playtarheight*resscale)

	target_width = E.Scale(C["framesizes"].playtarwidth*resscale)
	target_height = E.Scale(C["framesizes"].playtarheight*resscale)

	smallframe_width = E.Scale(C["framesizes"].smallwidth*resscale)
	smallframe_height = E.Scale(C["framesizes"].smallheight*resscale)

	arenaboss_width = E.Scale(C["framesizes"].arenabosswidth*resscale)
	arenaboss_height = E.Scale(C["framesizes"].arenabossheight*resscale)

	assisttank_width = E.Scale(C["framesizes"].assisttankwidth*resscale)
	assisttank_height = E.Scale(C["framesizes"].assisttankheight*resscale)

	-- Set Colors
	self.colors = E.oUF_colors
	
	-- Register Frames for Click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- Setup Menu
	self.menu = E.SpawnMenu
	
	-- Update all elements on show
	self:HookScript("OnShow", E.updateAllElements)
	
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
		FrameBorder:SetPoint("TOPLEFT", health, "TOPLEFT", E.Scale(-2), E.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
		FrameBorder:SetTemplate("Default")
		FrameBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		self.FrameBorder:CreateShadow("Default")
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
	
		-- Health Bar Background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		health:FontString("value", font1, C["unitframes"].fontsize, "THINOUTLINE")
		health.value:SetPoint("RIGHT", health, "RIGHT", E.Scale(-4), E.Scale(1))
		health.PostUpdate = E.PostUpdateHealth
		self.Health = health
		self.Health.bg = healthBG
		health.frequentUpdates = true
		
		-- Smooth Bar Animation
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		-- Setup Colors
		if C["unitframes"].classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(C["unitframes"].healthbackdropcolor))
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
			PowerFrame:SetPoint("TOP", self.Health, "BOTTOM", 0, -E.mult*3)
			PowerFrame:SetWidth(original_width + E.mult*4)
		end
		
	
		PowerFrame:SetTemplate("Default")
		PowerFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor))	
		self.PowerFrame = PowerFrame
		if powerbar_offset ~= 0 then
			self.PowerFrame:CreateShadow("Default")
		else
			self.FrameBorder.shadow:SetPoint("BOTTOMLEFT", self.PowerFrame, "BOTTOMLEFT", E.Scale(-4), E.Scale(-4))
		end
		
		-- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", E.mult*2, -E.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -E.mult*2, E.mult*2)
		power:SetStatusBarTexture(normTex)
		power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)
				
		-- Power Background
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		power:FontString("value", font1, C["unitframes"].fontsize, "THINOUTLINE")
		power.value:SetParent(health)
		power.value:SetPoint("LEFT", health, "LEFT", E.Scale(4), E.Scale(1))
		power.PreUpdate = E.PreUpdatePower
		power.PostUpdate = E.PostUpdatePower
		
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
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end
		
		-- Debuff Highlight (Overlays Health Bar)
		if C["unitframes"].debuffhighlight == true then
			local dbh = health:CreateTexture(nil, "OVERLAY", health)
			dbh:SetAllPoints(health)
			dbh:SetTexture(C["media"].normTex)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.4		
		end
		
		-- Portraits
		if (C["unitframes"].charportrait == true) then
			local PFrame = CreateFrame("Frame", nil, self)
			if powerbar_offset ~= 0 then
				PFrame:SetPoint('TOPRIGHT', self.Health,'TOPLEFT', E.Scale(-6), E.Scale(2))
				PFrame:SetPoint('BOTTOMRIGHT', self.Health,'BOTTOMLEFT', E.Scale(-6) - powerbar_offset, -powerbar_offset)
				PFrame:SetWidth(original_width/5)
			else
				PFrame:SetPoint('TOPRIGHT', self.Health,'TOPLEFT', E.Scale(-6), E.Scale(2))
				PFrame:SetPoint('BOTTOMRIGHT', self.Health,'BOTTOMLEFT', E.Scale(-6), E.Scale(-3) + -(original_height * 0.35))
				PFrame:SetWidth(original_width/5)
	
			end
			PFrame:SetTemplate("Default")
			PFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			self.PFrame = PFrame
			self.PFrame:CreateShadow("Default")		
			local portrait = CreateFrame("PlayerModel", nil, PFrame)
			portrait:SetFrameLevel(2)
			
			--dont ask me why but the playerframe looks completely fucked when i set it how it should be..
			portrait:SetPoint('BOTTOMLEFT', PFrame, 'BOTTOMLEFT', E.Scale(1), E.Scale(2))		
			portrait:SetPoint('TOPRIGHT', PFrame, 'TOPRIGHT', E.Scale(-2), E.Scale(-2))	
			table.insert(self.__elements, E.HidePortrait)
		
			self.Portrait = portrait
			player_width = player_width + (PFrame:GetWidth() + E.Scale(6))
		end
			
		-- combat icon
		local Combat = health:CreateTexture(nil, "OVERLAY")
		Combat:SetHeight(E.Scale(19))
		Combat:SetWidth(E.Scale(19))
		Combat:SetPoint("CENTER",0,7)
		Combat:SetVertexColor(0.69, 0.31, 0.31)
		self.Combat = Combat

		-- custom info (low mana warning)
		FlashInfo = CreateFrame("Frame", "FlashInfo", self)
		FlashInfo:SetScript("OnUpdate", E.UpdateManaLevel)
		FlashInfo.parent = self
		FlashInfo:SetToplevel(true)
		FlashInfo:SetAllPoints(health)
		FlashInfo:FontString("ManaLevel", font1, C["unitframes"].fontsize, "THINOUTLINE")
		FlashInfo.ManaLevel:SetPoint("CENTER", health, "CENTER", 0, E.Scale(-5))
		self.FlashInfo = FlashInfo
		

		local PvP = health:CreateFontString(nil, "OVERLAY")
		PvP:SetFont(font1, C["unitframes"].fontsize, "THINOUTLINE")
		PvP:SetPoint("CENTER", health, "CENTER", 0, E.Scale(-5))
		PvP:SetTextColor(0.69, 0.31, 0.31)
		PvP:SetShadowOffset(E.mult, -E.mult)
		PvP:Hide()
		self.PvP = PvP
		self.PvP.Override = E.dummy
		
		local PvPUpdate = CreateFrame("Frame", nil, self)
		PvPUpdate:SetScript("OnUpdate", function(self, elapsed) E.PvPUpdate(self:GetParent(), elapsed) end)
		
		self:SetScript("OnEnter", function(self) FlashInfo.ManaLevel:Hide() PvP:Show() UnitFrame_OnEnter(self) end)
		self:SetScript("OnLeave", function(self) FlashInfo.ManaLevel:Show() PvP:Hide() UnitFrame_OnLeave(self) end)
				
		-- leader icon
		local Leader = health:CreateTexture(nil, "OVERLAY")
		Leader:SetHeight(E.Scale(14))
		Leader:SetWidth(E.Scale(14))
		Leader:SetPoint("TOPLEFT", E.Scale(2), E.Scale(8))
		self.Leader = Leader
		
		-- master looter
		local MasterLooter = health:CreateTexture(nil, "OVERLAY")
		MasterLooter:SetHeight(E.Scale(14))
		MasterLooter:SetWidth(E.Scale(14))
		self.MasterLooter = MasterLooter
		self:RegisterEvent("PARTY_LEADER_CHANGED", E.MLAnchorUpdate)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", E.MLAnchorUpdate)
							
		-- experience bar on player via mouseover for player currently levelling a character
		if E.level ~= MAX_PLAYER_LEVEL then
			local Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self)
			Experience:SetStatusBarTexture(normTex)
			Experience:SetStatusBarColor(0, 0.4, 1, .8)
			Experience:SetWidth(original_width)
			Experience:SetHeight(E.Scale(5))
			Experience:SetFrameStrata("HIGH")

			if powerbar_offset ~= 0 then
				Experience:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + -E.Scale(5))
			else	
				Experience:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -E.Scale(8))
			end
			Experience.noTooltip = true
			Experience:EnableMouse(true)
			self.Experience = Experience

			
			Experience.Text = self.Experience:CreateFontString(nil, 'OVERLAY')
			Experience.Text:SetFont(font1, C["unitframes"].fontsize, "THINOUTLINE")
			Experience.Text:SetPoint('CENTER', self.Experience)
			Experience.Text:SetShadowOffset(E.mult, -E.mult)
			Experience.Text:Hide()
			self.Experience.Text = Experience.Text
			self.Experience.PostUpdate = E.ExperienceText
			
			Experience:SetScript("OnEnter", function(self) if not InCombatLockdown() then Experience:SetHeight(E.Scale(20)) Experience.Text:Show() end end)
			Experience:SetScript("OnLeave", function(self) if not InCombatLockdown() then Experience:SetHeight(E.Scale(5)) Experience.Text:Hide() end end)
			if C["unitframes"].combat == true then
				Experience:HookScript("OnEnter", function(self) E.Fader(self, true, true) end)
				Experience:HookScript("OnLeave", function(self) E.Fader(self, false, true) end)
			end
			
			self.Experience.Rested = CreateFrame('StatusBar', nil, self.Experience)
			self.Experience.Rested:SetAllPoints(self.Experience)
			self.Experience.Rested:SetStatusBarTexture(normTex)
			self.Experience.Rested:SetStatusBarColor(1, 0, 1, 0.2)
			self.Experience.Rested:SetBackdrop(backdrop)
			self.Experience.Rested:SetBackdropColor(unpack(C["media"].backdropcolor))

			
			local Resting = Experience:CreateTexture(nil, "OVERLAY", Experience.Rested)
			Resting:SetHeight(22)
			Resting:SetWidth(22)
			Resting:SetPoint("CENTER", self.Health, "TOPLEFT", E.Scale(-3), E.Scale(6))
			Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
			Resting:SetTexCoord(0, 0.5, 0, 0.421875)
			Resting:Hide()
			self.Resting = Resting
			
			self.Experience.F = CreateFrame("Frame", nil, self.Experience)
			self.Experience.F:SetTemplate("Default")
			self.Experience.F:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			self.Experience.F:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
			self.Experience.F:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
			self.Experience.F:SetFrameLevel(self.Experience:GetFrameLevel() - 1)
			self:RegisterEvent("PLAYER_UPDATE_RESTING", E.RestingIconUpdate)
		end
		
		-- reputation bar for max level character
		if E.level == MAX_PLAYER_LEVEL then
			local Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self)
			Reputation:SetStatusBarTexture(normTex)
			Reputation:SetBackdrop(backdrop)
			Reputation:SetBackdropColor(unpack(C["media"].backdropcolor))
			Reputation:SetWidth(original_width)
			Reputation:SetHeight(E.Scale(5))
			if powerbar_offset ~= 0 then
				Reputation:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + -E.Scale(5))
			else
				Reputation:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -E.Scale(8))
			end
			Reputation.Tooltip = false

			Reputation:SetScript("OnEnter", function(self)
				if not InCombatLockdown() then
					Reputation:SetHeight(E.Scale(20))
					Reputation.Text:Show()
				end
			end)
			
			Reputation:SetScript("OnLeave", function(self)
				if not InCombatLockdown() then
					Reputation:SetHeight(E.Scale(5))
					Reputation.Text:Hide()
				end
			end)
			
			if C["unitframes"].combat == true then
				Reputation:HookScript("OnEnter", function(self) E.Fader(self, true, true) end)
				Reputation:HookScript("OnLeave", function(self) E.Fader(self, false, true) end)
			end			

			Reputation.Text = Reputation:CreateFontString(nil, 'OVERLAY')
			Reputation.Text:SetFont(font1, C["unitframes"].fontsize, "THINOUTLINE")
			Reputation.Text:SetPoint('CENTER', Reputation)
			Reputation.Text:SetShadowOffset(E.mult, -E.mult)
			Reputation.Text:Hide()
			
			Reputation.PostUpdate = E.UpdateReputation
			self.Reputation = Reputation
			self.Reputation.Text = Reputation.Text
			self.Reputation.F = CreateFrame("Frame", nil, self.Reputation)
			self.Reputation.F:SetTemplate("Default")
			self.Reputation.F:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			self.Reputation.F:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
			self.Reputation.F:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
			self.Reputation.F:SetFrameLevel(self.Reputation:GetFrameLevel() - 1)
		end
				
		--CLASS BARS
		if C["unitframes"].classbar == true then
			-- show druid mana when shapeshifted in bear, cat or whatever
			if E.myclass == "DRUID" then
				--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
				self.FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(17))
				player_height = player_height + E.Scale(14)
				
				CreateFrame("Frame"):SetScript("OnUpdate", function() E.UpdateDruidMana(self) end)
				local DruidMana = health:FontString(nil, font1, C["unitframes"].fontsize, "THINOUTLINE")
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana

				local eclipseBar = CreateFrame('Frame', nil, self)
				eclipseBar:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, E.Scale(5))
				eclipseBar:SetSize(original_width, E.Scale(8))
				eclipseBar:SetFrameStrata("MEDIUM")
				eclipseBar:SetFrameLevel(8)
				eclipseBar:SetTemplate("Default")
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

				eclipseBar:FontString("Text", font1, C["unitframes"].fontsize, "THINOUTLINE")
				eclipseBar.Text:SetPoint("CENTER", self.Health, "CENTER", E.Scale(1), E.Scale(-5))
			
				self.EclipseBar = eclipseBar
				
				self.EclipseBar.PostUpdatePower = E.EclipseDirection
		
				eclipseBar.FrameBackdrop = CreateFrame("Frame", nil, eclipseBar)
				eclipseBar.FrameBackdrop:SetTemplate("Default")
				eclipseBar.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", E.Scale(-2), E.Scale(2))
				eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
				eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)
				
				self.EclipseBar:SetScript("OnShow", function() E.MoveBuffs(self.EclipseBar, false) end)
				self.EclipseBar:SetScript("OnUpdate", function() E.MoveBuffs(self.EclipseBar, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
				self.EclipseBar:SetScript("OnHide", function() E.MoveBuffs(self.EclipseBar, false) end)
			end
			
			-- set holy power bar or shard bar
			if (E.myclass == "WARLOCK" or E.myclass == "PALADIN") then
				--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
				self.FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(17))
				player_height = player_height + E.Scale(14)
				
				local bars = CreateFrame("Frame", nil, self)
				bars:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, E.Scale(5))
				bars:SetWidth(original_width)
				bars:SetHeight(E.Scale(8))
				bars:SetTemplate("Default")
				bars:SetBackdropBorderColor(0,0,0,0)
				
				for i = 1, 3 do					
					bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, bars)
					bars[i]:SetHeight(E.Scale(8))					
					bars[i]:SetStatusBarTexture(normTex)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)

					bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
					
					if E.myclass == "WARLOCK" then
						bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
						bars[i].bg:SetTexture(148/255, 130/255, 201/255)
					elseif E.myclass == "PALADIN" then
						bars[i]:SetStatusBarColor(228/255,225/255,16/255)
						bars[i].bg:SetTexture(228/255,225/255,16/255)
					end
					
					if i == 1 then
						bars[i]:SetPoint("LEFT", bars)
					else
						bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", E.Scale(1), 0)
					end
					
					bars[i].bg:SetAllPoints(bars[i])
					bars[i]:SetWidth(E.Scale(original_width - 2)/3)
					
					bars[i].bg:SetTexture(normTex)					
					bars[i].bg:SetAlpha(.15)
				end
				
				if E.myclass == "WARLOCK" then
					bars.Override = E.UpdateShards				
					self.SoulShards = bars
					self.SoulShards:SetScript("OnShow", function() E.MoveBuffs(self.SoulShards, false) end)
					self.SoulShards:SetScript("OnUpdate", function() E.MoveBuffs(self.SoulShards, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
					self.SoulShards:SetScript("OnHide", function() E.MoveBuffs(self.SoulShards, false) end)	
					
					-- show/hide bars on entering/leaving vehicle
					self:RegisterEvent("UNIT_ENTERING_VEHICLE", function() E.ToggleBars(self.SoulShards) end)
					self:RegisterEvent("UNIT_ENTERED_VEHICLE", function() E.ToggleBars(self.SoulShards) end)
					self:RegisterEvent("UNIT_EXITING_VEHICLE", function() E.ToggleBars(self.SoulShards) end)
					self:RegisterEvent("UNIT_EXITED_VEHICLE", function() E.ToggleBars(self.SoulShards) end)
				elseif E.myclass == "PALADIN" then
					bars.Override = E.UpdateHoly
					self.HolyPower = bars
					self.HolyPower:SetScript("OnShow", function() E.MoveBuffs(self.HolyPower, false) end)
					self.HolyPower:SetScript("OnUpdate", function() E.MoveBuffs(self.HolyPower, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
					self.HolyPower:SetScript("OnHide", function() E.MoveBuffs(self.HolyPower, false) end)	
		
					-- show/hide bars on entering/leaving vehicle
					self:RegisterEvent("UNIT_ENTERING_VEHICLE", function() E.ToggleBars(self.HolyPower) end)
					self:RegisterEvent("UNIT_ENTERED_VEHICLE", function() E.ToggleBars(self.HolyPower) end)
					self:RegisterEvent("UNIT_EXITING_VEHICLE", function() E.ToggleBars(self.HolyPower) end)
					self:RegisterEvent("UNIT_EXITED_VEHICLE", function() E.ToggleBars(self.HolyPower) end)
				end
				bars.FrameBackdrop = CreateFrame("Frame", nil, bars)
				bars.FrameBackdrop:SetTemplate("Default")
				bars.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				bars.FrameBackdrop:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
				bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
				bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
			end
			
			-- deathknight runes
			if E.myclass == "DEATHKNIGHT" then
				--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
				self.FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(17))
				player_height = player_height + E.Scale(14)
					
				local Runes = CreateFrame("Frame", nil, self)
				Runes:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, E.Scale(5))
				Runes:SetHeight(E.Scale(8))
				Runes:SetWidth(original_width)

				Runes:SetBackdrop(backdrop)
				Runes:SetBackdropColor(0, 0, 0)

				for i = 1, 6 do
					Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, Runes)
					Runes[i]:SetHeight(E.Scale(8))
					Runes[i]:SetWidth((original_width - 5) / 6)

					if (i == 1) then
						Runes[i]:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, E.Scale(5))
					else
						Runes[i]:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", E.Scale(1), 0)
					end
					Runes[i]:SetStatusBarTexture(normTex)
					Runes[i]:GetStatusBarTexture():SetHorizTile(false)
				end

				Runes.FrameBackdrop = CreateFrame("Frame", nil, Runes)
				Runes.FrameBackdrop:SetTemplate("Default")
				Runes.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				Runes.FrameBackdrop:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
				Runes.FrameBackdrop:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
				Runes.FrameBackdrop:SetFrameLevel(Runes:GetFrameLevel() - 1)
				self.Runes = Runes
				
				self.Runes:SetScript("OnShow", function() E.MoveBuffs(self.Runes, false) end)
				self.Runes:SetScript("OnUpdate", function() E.MoveBuffs(self.Runes, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
				self.Runes:SetScript("OnHide", function() E.MoveBuffs(self.Runes, false) end)	

				-- show/hide bars on entering/leaving vehicle
				self:RegisterEvent("UNIT_ENTERING_VEHICLE", function() E.ToggleBars(self.Runes) end)
				self:RegisterEvent("UNIT_ENTERED_VEHICLE", function() E.ToggleBars(self.Runes) end)
				self:RegisterEvent("UNIT_EXITING_VEHICLE", function() E.ToggleBars(self.Runes) end)
				self:RegisterEvent("UNIT_EXITED_VEHICLE", function() E.ToggleBars(self.Runes) end)
			end
				
			-- shaman totem bar
			if E.myclass == "SHAMAN" then
				--ReAdjust main background (this is invisible.. we need to adjust this so buffs appear above the unitframe correctly.. and so we can click this module to target ourselfs)
				self.FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(17))
				player_height = player_height + E.Scale(14)
								
				local TotemBar = CreateFrame("Frame", nil, self)
				TotemBar.Destroy = true
				TotemBar:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, E.Scale(5))
				TotemBar:SetHeight(E.Scale(8))
				TotemBar:SetWidth(original_width)

				TotemBar:SetBackdrop(backdrop)
				TotemBar:SetBackdropColor(0, 0, 0)

				for i = 1, 4 do
					TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, TotemBar)
					TotemBar[i]:SetHeight(E.Scale(8))
					TotemBar[i]:SetWidth((original_width - 3) / 4)

					if (i == 1) then
						TotemBar[i]:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, E.Scale(5))
					else
						TotemBar[i]:SetPoint("TOPLEFT", TotemBar[i-1], "TOPRIGHT", E.Scale(1), 0)
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
				TotemBar.FrameBackdrop:SetTemplate("Default")
				TotemBar.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				TotemBar.FrameBackdrop:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
				TotemBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
				TotemBar.FrameBackdrop:SetFrameLevel(TotemBar:GetFrameLevel() - 1)
				self.TotemBar = TotemBar
				
				self.TotemBar:SetScript("OnShow", function() E.MoveBuffs(self.TotemBar, false) end)
				self.TotemBar:SetScript("OnUpdate", function() E.MoveBuffs(self.TotemBar, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
				self.TotemBar:SetScript("OnHide", function() E.MoveBuffs(self.TotemBar, false) end)	
				
				-- show/hide bars on entering/leaving vehicle
				self:RegisterEvent("UNIT_ENTERING_VEHICLE", function() E.ToggleBars(self.TotemBar) end)
				self:RegisterEvent("UNIT_ENTERED_VEHICLE", function() E.ToggleBars(self.TotemBar) end)
				self:RegisterEvent("UNIT_EXITING_VEHICLE", function() E.ToggleBars(self.TotemBar) end)
				self:RegisterEvent("UNIT_EXITED_VEHICLE", function() E.ToggleBars(self.TotemBar) end)
			end
		end		
		-- auras 
		if C["auras"].playerauras then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)

			debuffs.num = C["auras"].playtarbuffperrow
			debuffs:SetWidth(original_width + E.Scale(4))
			debuffs.spacing = E.Scale(2)
			debuffs.size = (((original_width + E.Scale(4)) - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("BOTTOM", self.Health, "TOP", 0, E.Scale(6))	
			debuffs.initialAnchor = 'BOTTOMRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			
			if C["auras"].playershowonlydebuffs == false then
				buffs.num = C["auras"].playtarbuffperrow
				buffs:SetWidth(debuffs:GetWidth())
				buffs.spacing = E.Scale(2)
				buffs.size = ((((original_width + E.Scale(4)) - (buffs.spacing*(buffs.num - 1))) / buffs.num))
				buffs:SetPoint("BOTTOM", debuffs, "TOP", 0, E.Scale(2))
				buffs:SetHeight(debuffs:GetHeight())
				buffs.initialAnchor = 'BOTTOMLEFT'
				buffs["growth-y"] = "UP"	
				buffs["growth-x"] = "RIGHT"
				buffs.PostCreateIcon = E.PostCreateAura
				buffs.PostUpdateIcon = E.PostUpdateAura
				self.Buffs = buffs	
			end
			
			self.Debuffs = debuffs
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = E.AuraFilter
		end
			
		-- cast bar for player
		if C["castbar"].unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			if C["castbar"].castermode == true then
				castbar:SetWidth(ElvuiActionBarBackground:GetWidth() - E.Scale(4))
				if C["unitframes"].swingbar ~= true then
					castbar:SetPoint("BOTTOMRIGHT", ElvuiActionBarBackground, "TOPRIGHT", E.Scale(-2), E.Scale(5))
				else
					castbar:SetPoint("BOTTOMRIGHT", ElvuiActionBarBackground, "TOPRIGHT", E.Scale(-2), E.Scale(14))
				end
			else
				castbar:SetWidth(original_width)
				if powerbar_offset ~= 0 then
					castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -powerbar_offset + -E.Scale(5))
				else
					castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -E.Scale(8))
				end
			end
 
			castbar:SetHeight(E.Scale(20))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			castbar:SetFrameStrata("DIALOG")
 
			castbar.bg = CreateFrame("Frame", nil, castbar)
			castbar.bg:SetTemplate("Default")
			castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			castbar.bg:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			castbar.bg:SetFrameStrata("DIALOG")
			
			castbar:FontString("time", font1, C["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", E.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = E.CustomCastTimeText
 
			castbar:FontString("Text", font1, C["unitframes"].fontsize, "THINOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
 
			castbar.CustomDelayText = E.CustomCastDelayText
			castbar.PostCastStart = E.PostCastStart
			castbar.PostChannelStart = E.PostCastStart
 
			-- cast bar latency on player
			if C["castbar"].cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "OVERLAY")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end			
 
			if C["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(castbar:GetHeight()+E.Scale(4))
				castbar.button:SetWidth(castbar:GetHeight()+E.Scale(4))
				castbar.button:SetPoint("RIGHT", castbar, "LEFT", E.Scale(-4), 0)
				castbar.button:SetTemplate("Default")
				castbar.button:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, E.Scale(2), E.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, E.Scale(-2), E.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				if C["castbar"].castermode == true and unit == "player" then
					castbar:SetWidth(ElvuiActionBarBackground:GetWidth() - castbar.button:GetWidth() - E.Scale(6))
				else
					castbar:SetWidth(original_width - castbar.button:GetWidth() - E.Scale(2))
				end
			end
 
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- swingbar
		if C["unitframes"].swingbar == true then
			local Swing = CreateFrame("StatusBar", self:GetName().."_SwingBar", ElvuiActionBarBackground)
			Swing:SetStatusBarTexture(normTex)
			Swing:SetStatusBarColor(unpack(C["media"].bordercolor))
			Swing:GetStatusBarTexture():SetHorizTile(false)
			self.Swing = Swing
			if C["castbar"].castermode == true then
				self.Swing:SetWidth(ElvuiActionBarBackground:GetWidth()-E.Scale(4))
				self.Swing:SetPoint("BOTTOM", ElvuiActionBarBackground, "TOP", 0, E.Scale(4))
			else
				self.Swing:SetWidth(original_width)
				if self.Castbar then
					self.Swing:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", 0, E.Scale(-6))	
				else
					if powerbar_offset ~= 0 then
						self.Swing:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -powerbar_offset + -E.Scale(5))
					else
						self.Swing:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -E.Scale(8))
					end							
				end
			end
			
			self.Swing:SetHeight(E.Scale(4))
			
			self.Swing.bg = CreateFrame("Frame", nil, self.Swing)
			self.Swing.bg:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
			self.Swing.bg:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
			self.Swing.bg:SetFrameStrata("BACKGROUND")
			self.Swing.bg:SetFrameLevel(self.Swing:GetFrameLevel() - 1)
			self.Swing.bg:SetTemplate("Default")
			self.Swing.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		end
		
		-- add combat feedback support
		if C["unitframes"].combatfeedback == true then
			health:FontString("CombatText", font1, C["unitframes"].fontsize*1.1, "OUTLINE")

			if C["unitframes"].charportrait == true then
				health.CombatText:SetPoint("CENTER", self.Portrait, "CENTER")
			else
				health.CombatText:SetPoint("CENTER", 0, -5)
			end
			health.CombatText.colors = {
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
			self.CombatFeedbackText = health.CombatText
		end
		
		-- player aggro
		if C["unitframes"].playeraggro == true then
			table.insert(self.__elements, E.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)
		end
		
		-- update all frames when changing area, to fix exiting instance while in vehicle
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", E.updateAllElements)
		
		--Autohide in combat
		if C["unitframes"].combat == true then
			self:RegisterEvent("PLAYER_ENTERING_WORLD", E.Fader)
			self:RegisterEvent("PLAYER_REGEN_ENABLED", E.Fader)
			self:RegisterEvent("PLAYER_REGEN_DISABLED", E.Fader)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", E.Fader)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", E.Fader)
			self:RegisterEvent("UNIT_HEALTH", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_START", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_STOP", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", E.Fader)
			self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", E.Fader)
			self:RegisterEvent("UNIT_PORTRAIT_UPDATE", E.Fader)
			self:RegisterEvent("UNIT_MODEL_CHANGED", E.Fader)			
			self:HookScript("OnEnter", function(self) E.Fader(self, true) end)
			self:HookScript("OnLeave", function(self) E.Fader(self, false) end)
		end
		
		-- alt power bar
		local AltPowerBar = CreateFrame("StatusBar", nil, self.Health)
		AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		AltPowerBar:SetHeight(4)
		AltPowerBar:SetStatusBarTexture(C.media.normTex)
		AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
		AltPowerBar:EnableMouse(true)
		AltPowerBar:SetFrameStrata("HIGH")
		
		AltPowerBar:Point("TOPLEFT", ElvuiInfoLeft, "TOPLEFT", 2, -2)
		AltPowerBar:Point("BOTTOMRIGHT", ElvuiInfoLeft, "BOTTOMRIGHT", -2, 2)
		
		AltPowerBar:SetBackdrop({
		  bgFile = C["media"].blank, 
		  edgeFile = C["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = 1, 
		  insets = { left = 0, right = 0, top = 0, bottom = E.Scale(-1)}
		})
		AltPowerBar:SetBackdropColor(0, 0, 0, 0)
		AltPowerBar:SetBackdropBorderColor(0, 0, 0, 0)
		
		AltPowerBar:FontString(nil, font1, C["unitframes"].fontsize, "THINOUTLINE")
		AltPowerBar.text:SetPoint("CENTER")
		AltPowerBar.text:SetJustifyH("CENTER")
		
		AltPowerBar:HookScript("OnShow", E.AltPowerBarOnToggle)
		AltPowerBar:HookScript("OnHide", E.AltPowerBarOnToggle)

		self.AltPowerBar = AltPowerBar		
		self.AltPowerBar.PostUpdate = E.AltPowerBarPostUpdate
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
		FrameBorder:SetPoint("TOPLEFT", health, "TOPLEFT", E.Scale(-2), E.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
		FrameBorder:SetTemplate("Default")
		FrameBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		self.FrameBorder:CreateShadow("Default")
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
	
		-- Health Bar Background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		health:FontString("value", font1, C["unitframes"].fontsize, "THINOUTLINE")
		health.value:SetPoint("RIGHT", health, "RIGHT", E.Scale(-4), E.Scale(1))
		health.PostUpdate = E.PostUpdateHealth
		self.Health = health
		self.Health.bg = healthBG
		health.frequentUpdates = true
		
		-- Smooth Bar Animation
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		-- Setup Colors
		if C["unitframes"].classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(C["unitframes"].healthbackdropcolor))
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
			PowerFrame:SetPoint("TOP", self.Health, "BOTTOM", 0, -E.mult*3)
			PowerFrame:SetWidth(original_width + E.mult*4)
		end
		
		PowerFrame:SetTemplate("Default")
		PowerFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor))	
		self.PowerFrame = PowerFrame
		if powerbar_offset ~= 0 then
			self.PowerFrame:CreateShadow("Default")
		else
			self.FrameBorder.shadow:SetPoint("BOTTOMLEFT", self.PowerFrame, "BOTTOMLEFT", E.Scale(-4), E.Scale(-4))
		end
		
		-- Power Bar
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", E.mult*2, -E.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -E.mult*2, E.mult*2)
		power:SetStatusBarTexture(normTex)
		power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)
				
		-- Power Background
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		power:FontString("value", font1, C["unitframes"].fontsize, "THINOUTLINE")
		power.value:SetParent(health)
		power.value:SetPoint("LEFT", health, "LEFT", E.Scale(4), E.Scale(1))
		power.PreUpdate = E.PreUpdatePower
		power.PostUpdate = E.PostUpdatePower
		
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
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end
		
		-- Debuff Highlight (Overlays Health Bar)
		if C["unitframes"].debuffhighlight == true then
			local dbh = health:CreateTexture(nil, "OVERLAY", health)
			dbh:SetAllPoints(health)
			dbh:SetTexture(C["media"].normTex)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.4		
		end
		
		-- Portraits
		if (C["unitframes"].charportrait == true) then			
			local PFrame = CreateFrame("Frame", nil, self)
			if powerbar_offset ~= 0 then
				PFrame:SetPoint('TOPLEFT', self.Health,'TOPRIGHT', E.Scale(6), E.Scale(2))
				PFrame:SetPoint('BOTTOMLEFT', self.Health,'BOTTOMRIGHT', E.Scale(6) + powerbar_offset, -powerbar_offset)
				PFrame:SetWidth(original_width/5)
			else
				PFrame:SetPoint('TOPLEFT', self.Health,'TOPRIGHT', E.Scale(6), E.Scale(2))
				PFrame:SetPoint('BOTTOMLEFT', self.Health,'BOTTOMRIGHT', E.Scale(6), E.Scale(-3) + -(original_height * 0.35))
				PFrame:SetWidth(original_width/5)
			end
			PFrame:SetTemplate("Default")
			PFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			self.PFrame = PFrame
			self.PFrame:CreateShadow("Default")		
			local portrait = CreateFrame("PlayerModel", nil, PFrame)
			portrait:SetFrameLevel(2)
			
			--dont ask me why but the playerframe looks completely fucked when i set it how it should be..
			portrait:SetPoint('BOTTOMLEFT', PFrame, 'BOTTOMLEFT', E.Scale(2), E.Scale(2))		
			portrait:SetPoint('TOPRIGHT', PFrame, 'TOPRIGHT', E.Scale(-2), E.Scale(-2))		
			table.insert(self.__elements, E.HidePortrait)
		
			self.Portrait = portrait
			target_width = target_width + (PFrame:GetWidth() + E.Scale(6))
		end
						
		-- Unit name on target
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("LEFT", health, "LEFT", 0, E.Scale(1))
		Name:SetJustifyH("LEFT")
		Name:SetFont(font1, C["unitframes"].fontsize, "OUTLINE")
		Name:SetShadowColor(0, 0, 0, 0.4)
		Name:SetShadowOffset(1.25, -1.25)
		self:Tag(Name, '[Elvui:getnamecolor][Elvui:namelong] [Elvui:diffcolor][level] [shortclassification]')
		self.Name = Name
		
		if C["auras"].targetauras then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			
			buffs.num = C["auras"].playtarbuffperrow
			buffs:SetWidth(original_width + E.Scale(4))
			buffs.spacing = E.Scale(2)
			buffs.size = (((original_width + E.Scale(4)) - (buffs.spacing*(buffs.num - 1))) / buffs.num)
			buffs:SetHeight(buffs.size)
			buffs:SetPoint("BOTTOM", self.Health, "TOP", 0, E.Scale(6))	
			buffs.initialAnchor = 'BOTTOMLEFT'
			buffs["growth-y"] = "UP"
			buffs["growth-x"] = "RIGHT"
			buffs.PostCreateIcon = E.PostCreateAura
			buffs.PostUpdateIcon = E.PostUpdateAura
			self.Buffs = buffs	
			
			debuffs.num = C["auras"].playtarbuffperrow
			debuffs:SetWidth(original_width + E.Scale(4))
			debuffs.spacing = E.Scale(2)
			debuffs.size = (((original_width + E.Scale(4)) - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("BOTTOM", buffs, "TOP", 0, E.Scale(2))
			debuffs.initialAnchor = 'BOTTOMRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			self.Debuffs = debuffs
			
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = E.AuraFilter
		end
		
		-- cast bar for target
		if C["castbar"].unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetWidth(original_width)
			if powerbar_offset ~= 0 then
				castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -powerbar_offset + -E.Scale(5))
			else
				castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -(original_height * 0.35) + -E.Scale(8))
			end
 
			castbar:SetHeight(E.Scale(20))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
 
			castbar.bg = CreateFrame("Frame", nil, castbar)
			castbar.bg:SetTemplate("Default")
			castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			castbar.bg:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
			castbar.bg:SetFrameLevel(5)

 
			castbar:FontString("time", font1, C["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", E.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = E.CustomCastTimeText
 
			castbar:FontString("Text", font1, C["unitframes"].fontsize, "THINOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
 
			castbar.CustomDelayText = E.CustomCastDelayText
			castbar.PostCastStart = E.PostCastStart
			castbar.PostChannelStart = E.PostCastStart
  
			if C["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(castbar:GetHeight()+E.Scale(4))
				castbar.button:SetWidth(castbar:GetHeight()+E.Scale(4))
				castbar.button:SetPoint("RIGHT", castbar, "LEFT", E.Scale(-4), 0)
				castbar.button:SetTemplate("Default")
				castbar.button:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, E.Scale(2), E.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, E.Scale(-2), E.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				castbar:SetWidth(original_width - castbar.button:GetWidth() - E.Scale(2))
			end
 
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if C["unitframes"].combatfeedback == true then
			local CombatFeedbackText = health:FontString("CombatFeedback", font1, C["unitframes"].fontsize*1.1, "OUTLINE")
			
			if C["unitframes"].charportrait == true then
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
		if E.myclass == "DRUID" or E.myclass == "ROGUE" then
			target_height = target_height + E.Scale(14)
		end
		
		local bars = CreateFrame("Frame", nil, self)
		bars:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, E.Scale(5))
		bars:SetWidth(original_width)
		bars:SetHeight(E.Scale(8))
		bars:SetTemplate("Default")
		bars:SetBackdropBorderColor(0,0,0,0)
		bars:SetBackdropColor(0,0,0,0)
		
		for i = 1, 5 do					
			bars[i] = CreateFrame("StatusBar", self:GetName().."_Combo"..i, bars)
			bars[i]:SetHeight(E.Scale(8))					
			bars[i]:SetStatusBarTexture(normTex)
			bars[i]:GetStatusBarTexture():SetHorizTile(false)
							
			if i == 1 then
				bars[i]:SetPoint("LEFT", bars)
			else
				bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", E.Scale(1), 0)
			end
			bars[i]:SetAlpha(0.15)
			bars[i]:SetWidth(E.Scale(original_width - 4)/5)
		end
		
		bars[1]:SetStatusBarColor(0.69, 0.31, 0.31)		
		bars[2]:SetStatusBarColor(0.69, 0.31, 0.31)
		bars[3]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[4]:SetStatusBarColor(0.65, 0.63, 0.35)
		bars[5]:SetStatusBarColor(0.33, 0.59, 0.33)
		

		self.CPoints = bars
		self.CPoints.Override = E.ComboDisplay
		
		bars.FrameBackdrop = CreateFrame("Frame", nil, bars[1])
		bars.FrameBackdrop:SetTemplate("Default")
		bars.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", E.Scale(-2), E.Scale(2))
		bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
		bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)

		-- alt power bar
		local AltPowerBar = CreateFrame("StatusBar", nil, self.Health)
		AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
		AltPowerBar:SetHeight(4)
		AltPowerBar:SetStatusBarTexture(C.media.normTex)
		AltPowerBar:GetStatusBarTexture():SetHorizTile(false)

		AltPowerBar:SetPoint("LEFT")
		AltPowerBar:SetPoint("RIGHT")
		AltPowerBar:SetPoint("TOP", self.Health, "TOP")
		
		AltPowerBar:SetBackdrop({
		  bgFile = C["media"].blank, 
		  edgeFile = C["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = 1, 
		  insets = { left = 0, right = 0, top = 0, bottom = E.Scale(-1)}
		})
		AltPowerBar:SetBackdropColor(0, 0, 0, 0)
		AltPowerBar:SetBackdropBorderColor(0, 0, 0, 0)

		self.AltPowerBar = AltPowerBar		
		self.AltPowerBar.PostUpdate = E.AltPowerBarPostUpdate	
	end
	
	------------------------------------------------------------------------
	--	Target of Target, Pet, focus, focustarget unit layout mirrored
	------------------------------------------------------------------------
	
	if (unit == "targettarget" or unit == "pet" or unit == "pettarget" or unit == "focustarget" or unit == "focus") then
		local original_width = smallframe_width
		local original_height = smallframe_height
		if unit == "pettarget" then original_height = original_height*0.8 end
		local smallpowerbar_offset
		if powerbar_offset ~= 0 then
			smallpowerbar_offset = powerbar_offset*(7/9)
		else
			smallpowerbar_offset = E.Scale(7)
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
		health.PostUpdate = E.PostUpdateHealth
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		local FrameBorder = CreateFrame("Frame", nil, self)
		FrameBorder:SetPoint("TOPLEFT", self.Health, "TOPLEFT", E.Scale(-2), E.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
		FrameBorder:SetTemplate("Default")
		FrameBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		self.FrameBorder:CreateShadow("Default")
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
		
		if C["unitframes"].classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(C["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true		
			healthBG.multiplier = 0.3
		end
		health.colorDisconnected = false
		
		-- power frame
		if unit ~= "pettarget" then
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
				PowerFrame:SetWidth(original_width + E.Scale(4))
				PowerFrame:SetHeight(original_height * 0.3)
				PowerFrame:SetPoint("TOP", self.Health, "BOTTOM", 0,-E.Scale(3))
				smallframe_height = smallframe_height + (original_height * 0.3)
			end
			PowerFrame:SetFrameStrata("LOW")
			PowerFrame:SetTemplate("Default")
			PowerFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor))	
			self.PowerFrame = PowerFrame
			if powerbar_offset ~= 0 then
				PowerFrame:CreateShadow("Default")
			else
				self.FrameBorder.shadow:SetPoint("BOTTOMLEFT", PowerFrame, "BOTTOMLEFT", E.Scale(-4), E.Scale(-4))
			end
			
			-- power
			local power = CreateFrame('StatusBar', nil, self)
			power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", E.mult*2, -E.mult*2)
			power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -E.mult*2, E.mult*2)
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
			
			if C["unitframes"].showsmooth == true then
				power.Smooth = true
			end
			
			power.colorPower = true
			powerBG.multiplier = 0.3
			power.colorTapping = false
			power.colorDisconnected = true
		end

		local dbh = health:CreateTexture(nil, "OVERLAY", health)
		dbh:SetAllPoints(health)
		dbh:SetTexture(C["media"].normTex)
		dbh:SetBlendMode("ADD")
		dbh:SetVertexColor(0,0,0,0)
		self.DebuffHighlight = dbh
		self.DebuffHighlightFilter = true
		self.DebuffHighlightAlpha = 0.4	
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, E.Scale(1))
		Name:SetFont(font1, C["unitframes"].fontsize, "THINOUTLINE")
		Name:SetJustifyH("CENTER")
		Name:SetShadowColor(0, 0, 0, 0.4)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Elvui:getnamecolor][Elvui:namemedium]')
		self.Name = Name
		
		if unit == "targettarget" and C["auras"].totdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, health)			
			debuffs.num = C["auras"].smallbuffperrow
			debuffs:SetWidth(original_width + E.Scale(4))
			debuffs.spacing = E.Scale(2)
			debuffs.size = (((original_width + E.Scale(4)) - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("TOP", self, "BOTTOM", 0, -E.Scale(5))
			debuffs.initialAnchor = 'TOPLEFT'
			debuffs["growth-y"] = "DOWN"
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			self.Debuffs = debuffs	
			
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = E.AuraFilter
		end
		
		if unit == "focus" and C["auras"].focusdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, health)			
			debuffs.num = C["auras"].smallbuffperrow
			debuffs:SetWidth(original_width + E.Scale(4))
			debuffs.spacing = E.Scale(2)
			debuffs.size = (((original_width + E.Scale(4)) - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs:SetHeight(debuffs.size)
			debuffs:SetPoint("TOP", self, "BOTTOM", 0, -E.Scale(5))
			debuffs.initialAnchor = 'TOPLEFT'
			debuffs["growth-y"] = "DOWN"
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			self.Debuffs = debuffs	
			
			-- Debuff Aura Filter
			self.Debuffs.CustomFilter = E.AuraFilter
		end
		
		if unit == "pet" then
			if (C["castbar"].unitcastbar == true) then
				local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
				castbar:SetStatusBarTexture(normTex)
				self.Castbar = castbar
			end
			if C["auras"].raidunitbuffwatch == true then
				E.createAuraWatch(self,unit)
			end
			
			--Autohide in combat
			if C["unitframes"].combat == true then
				self:HookScript("OnEnter", function(self) E.Fader(self, true) end)
				self:HookScript("OnLeave", function(self) E.Fader(self, false) end)
			end
			
			-- update pet name, this should fix "UNKNOWN" pet names on pet unit.
			self:RegisterEvent("UNIT_PET", E.updateAllElements)		
		end
		
		if C["castbar"].unitcastbar == true and unit == "focus" then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetHeight(E.Scale(20))
			castbar:SetWidth(E.Scale(240))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			castbar:SetPoint("CENTER", UIParent, "CENTER", 0, 250)		
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			castbar.bg:SetTemplate("Default")
			castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			castbar.bg:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			
			castbar:FontString("time", font1, C["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", E.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = E.CustomCastTimeText

			castbar:FontString("Text", font1, C["unitframes"].fontsize)
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomDelayText = E.CustomCastDelayText
			castbar.PostCastStart = E.PostCastStart
			castbar.PostChannelStart = E.PostCastStart
			
			castbar.CastbarBackdrop = CreateFrame("Frame", nil, castbar)
			castbar.CastbarBackdrop:SetPoint("TOPLEFT", castbar, "TOPLEFT", E.Scale(-6), E.Scale(6))
			castbar.CastbarBackdrop:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT", E.Scale(6), E.Scale(-6))
			castbar.CastbarBackdrop:SetParent(castbar)
			castbar.CastbarBackdrop:SetFrameStrata("BACKGROUND")
			castbar.CastbarBackdrop:SetFrameLevel(4)
			castbar.CastbarBackdrop:SetBackdrop({
				edgeFile = glowTex, edgeSize = 4,
				insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
			castbar.CastbarBackdrop:SetBackdropColor(0, 0, 0, 0)
			castbar.CastbarBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
			
			if C["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(E.Scale(40))
				castbar.button:SetWidth(E.Scale(40))
				castbar.button:SetPoint("CENTER", 0, E.Scale(50))
				castbar.button:SetTemplate("Default")
				castbar.button:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, E.Scale(2), E.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, E.Scale(-2), E.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				
				castbar.IconBackdrop = CreateFrame("Frame", nil, self)
				castbar.IconBackdrop:SetPoint("TOPLEFT", castbar.button, "TOPLEFT", E.Scale(-4), E.Scale(4))
				castbar.IconBackdrop:SetPoint("BOTTOMRIGHT", castbar.button, "BOTTOMRIGHT", E.Scale(4), E.Scale(-4))
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
	
	if (unit and unit:find("arena%d") and C["arena"].unitframes == true) or (unit and unit:find("boss%d") and C["raidframes"].showboss == true) then
		local original_height = arenaboss_height
		local original_width = arenaboss_width

		local arenapowerbar_offset
		if powerbar_offset ~= 0 then
			arenapowerbar_offset = powerbar_offset*(7/9)
		else
			arenapowerbar_offset = E.Scale(7)
		end		
		
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(arenaboss_height)
		health:SetPoint("TOPLEFT")
		if (unit and unit:find('arena%d')) then
			health:SetWidth(arenaboss_width - (arenaboss_height*.80) - E.Scale(6))
		else
			health:SetWidth(arenaboss_width)
		end
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(C["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true		
			healthBG.multiplier = 0.3
		end
		health.colorDisconnected = false
		
		local FrameBorder = CreateFrame("Frame", nil, self)
		FrameBorder:SetPoint("TOPLEFT", self.Health, "TOPLEFT", E.Scale(-2), E.Scale(2))
		if (unit and unit:find('arena%d')) then
			FrameBorder:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", E.Scale(2) + arenaboss_height*.80 + E.Scale(6), E.Scale(-2))
		else
			FrameBorder:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
		end
		FrameBorder:SetTemplate("Default")
		FrameBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		self.FrameBorder:CreateShadow("Default")
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
			PowerFrame:SetWidth(arenaboss_width + E.Scale(4))
			PowerFrame:SetHeight(arenaboss_height * 0.3)
			PowerFrame:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", -E.Scale(2), -E.Scale(3))		
		end
		arenaboss_height = arenaboss_height + arenapowerbar_offset
		arenaboss_width = arenaboss_width + arenapowerbar_offset
		PowerFrame:SetTemplate("Default")
		PowerFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor))	
		if powerbar_offset ~= 0 then
			PowerFrame:CreateShadow("Default")
		else
			self.FrameBorder.shadow:SetPoint("BOTTOMLEFT", PowerFrame, "BOTTOMLEFT", E.Scale(-4), E.Scale(-4))
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", E.mult*2, -E.mult*2)
		power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -E.mult*2, E.mult*2)
		power:SetStatusBarTexture(normTex)
		power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)		
		
		power.frequentUpdates = true
		power.colorPower = true
		power.colorDisconnected = true
		
		if C["unitframes"].showsmooth == true then
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
				
		
		--Health and Power
		if (unit and unit:find('arena%d')) then
			health:FontString("value", font1,C["unitframes"].fontsize, "OUTLINE")
			health.value:SetPoint("LEFT", E.Scale(2), E.Scale(1))
			health.PostUpdate = E.PostUpdateHealth
			
			power:FontString("value", font1, C["unitframes"].fontsize, "OUTLINE")
			power.value:SetParent(health)
			power.value:SetPoint("RIGHT", health, "RIGHT", E.Scale(-2), E.Scale(1))
			power.PreUpdate = E.PreUpdatePower
			power.PostUpdate = E.PostUpdatePower			
		else
			health:FontString("value", font1,C["unitframes"].fontsize, "OUTLINE")
			health.value:SetPoint("TOPLEFT", health, "TOPLEFT", E.Scale(2), E.Scale(-2))
			health.PostUpdate = E.PostUpdateHealth
			
			power:FontString("value", font1, C["unitframes"].fontsize, "OUTLINE")
			power.value:SetPoint("BOTTOMLEFT", health, "BOTTOMLEFT", E.Scale(2), E.Scale(1))
			power.value:SetParent(health)
			power.value:SetJustifyH("LEFT")
			power.PreUpdate = E.PreUpdatePower
			power.PostUpdate = E.PostUpdatePower

			-- alt power bar
			local AltPowerBar = CreateFrame("StatusBar", nil, self)
			local apb_bg = CreateFrame("Frame", nil, AltPowerBar)
			apb_bg:SetWidth(arenaboss_width + E.Scale(-3))
			apb_bg:SetHeight(arenaboss_height * 0.2)
			apb_bg:SetPoint("BOTTOMLEFT", self, "TOPLEFT", E.Scale(-2), E.Scale(3))
			apb_bg:SetTemplate("Default")
			apb_bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
			apb_bg:SetFrameLevel(AltPowerBar:GetFrameLevel() - 1)
			AltPowerBar:SetStatusBarTexture(C.media.normTex)
			AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
		
			AltPowerBar:SetPoint("TOPLEFT", apb_bg, "TOPLEFT", E.Scale(2), E.Scale(-2))
			AltPowerBar:SetPoint("BOTTOMRIGHT", apb_bg, "BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
			
			AltPowerBar:SetBackdrop({
			  bgFile = C["media"].blank, 
			  edgeFile = C["media"].blank, 
			  tile = false, tileSize = 0, edgeSize = 1, 
			  insets = { left = 0, right = 0, top = 0, bottom = E.Scale(-1)}
			})
			AltPowerBar:SetBackdropColor(0, 0, 0, 0)
			AltPowerBar:SetBackdropBorderColor(0, 0, 0, 0)
			AltPowerBar:HookScript("OnShow", function(self) self:GetParent().FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(12)) end)
			AltPowerBar:HookScript("OnHide", function(self) self:GetParent().FrameBorder.shadow:SetPoint("TOPLEFT", E.Scale(-4), E.Scale(4)) end)
			AltPowerBar.FrameBackdrop = apb_bg			
			self.AltPowerBar = AltPowerBar	
			self.AltPowerBar.PostUpdate = E.AltPowerBarPostUpdate
		end
		
		self.Power = power
		self.Power.bg = powerBG
		
		-- names
		local Name
		if (unit and unit:find('arena%d')) then
			Name = health:CreateFontString(nil, "OVERLAY")
			Name:SetPoint("CENTER", health, "CENTER", 0, E.Scale(1))
			Name:SetJustifyH("CENTER")
			Name:SetFont(font1, C["unitframes"].fontsize, "OUTLINE")
			Name:SetShadowColor(0, 0, 0, 0.4)
			Name:SetShadowOffset(1.25, -1.25)
		else
			Name = health:CreateFontString(nil, "OVERLAY")
			Name:SetPoint("RIGHT", health, "RIGHT", E.Scale(-2), E.Scale(1))
			Name:SetJustifyH("RIGHT")
			Name:SetFont(font1, C["unitframes"].fontsize, "OUTLINE")
			Name:SetShadowColor(0, 0, 0, 0.4)
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
				Trinketbg:SetPoint("RIGHT", self.FrameBorder, "RIGHT",E.Scale(-2), 0)				
				Trinketbg:SetTemplate("Default")
				Trinketbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				Trinketbg:SetFrameLevel(self.Health:GetFrameLevel()+1)
				self.Trinketbg = Trinketbg
				
				local Trinket = CreateFrame("Frame", nil, Trinketbg)
				Trinket:SetAllPoints(Trinketbg)
				Trinket:SetPoint("TOPLEFT", Trinketbg, E.Scale(2), E.Scale(-2))
				Trinket:SetPoint("BOTTOMRIGHT", Trinketbg, E.Scale(-2), E.Scale(2))
				Trinket:SetFrameLevel(Trinketbg:GetFrameLevel()+1)
				Trinket.trinketUseAnnounce = true
				self.Trinket = Trinket
			end
		end
		
		-- create arena/boss debuff/buff spawn point
		local buffs = CreateFrame("Frame", nil, self)
		buffs:SetHeight(arenaboss_height + 8)
		buffs:SetWidth(252)
		buffs:SetPoint("RIGHT", self, "LEFT", E.Scale(-4), 0)
		buffs.size = arenaboss_height
		buffs.num = 3
		buffs.spacing = 2
		buffs.initialAnchor = 'RIGHT'
		buffs["growth-x"] = "LEFT"
		buffs.PostCreateIcon = E.PostCreateAura
		buffs.PostUpdateIcon = E.PostUpdateAura
		self.Buffs = buffs		
		
		--only need to see debuffs for arena frames
		if (unit and unit:find("arena%d")) and C["auras"].arenadebuffs == true then	
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs:SetHeight(arenaboss_height + 8)
			debuffs:SetWidth(arenaboss_width*2)
			debuffs:SetPoint("LEFT", self, "RIGHT", E.Scale(4), 0)
			debuffs.size = arenaboss_height
			debuffs.num = 3
			debuffs.spacing = 2
			debuffs.initialAnchor = 'LEFT'
			debuffs["growth-x"] = "RIGHT"
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			self.Debuffs = debuffs
			
			--set filter for buffs/debuffs
			self.Buffs.CustomFilter = E.AuraFilter
			self.Debuffs.CustomFilter = E.AuraFilter
		end
		
		
		if C["castbar"].unitcastbar == true then
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetWidth(original_width)
			if powerbar_offset ~= 0 then
				castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -powerbar_offset + E.Scale(-1))
			else
				castbar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -(original_height * 0.35) + E.Scale(5))
			end
			
			castbar:SetHeight(E.Scale(16))
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			castbar.bg:SetTemplate("Default")
			castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			castbar.bg:SetPoint("TOPLEFT", E.Scale(-2), E.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			
			castbar:FontString("time", font1, C["unitframes"].fontsize, "THINOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", E.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = E.CustomCastTimeText

			castbar:FontString("Text", font1, C["unitframes"].fontsize, "THINOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomDelayText = E.CustomCastDelayText
			castbar.PostCastStart = E.PostCastStart
			castbar.PostChannelStart = E.PostCastStart
									
			if C["castbar"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(castbar:GetHeight()+E.Scale(4))
				castbar.button:SetWidth(castbar:GetHeight()+E.Scale(4))
				castbar.button:SetPoint("RIGHT", castbar, "LEFT", E.Scale(-4), 0)
				castbar.button:SetTemplate("Default")
				castbar.button:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, E.Scale(2), E.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, E.Scale(-2), E.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				castbar:SetWidth(original_width - castbar.button:GetWidth() - E.Scale(2))
				
				castbar:ClearAllPoints()
				if powerbar_offset ~= 0 then
					castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", castbar.button:GetWidth() + E.Scale(2), -powerbar_offset + E.Scale(-1))
				else
					castbar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -(original_height * 0.35) + E.Scale(5))
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
	
	if(self:GetParent():GetName():match"ElvDPSMainTank" or self:GetParent():GetName():match"ElvDPSMainAssist") then
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
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(C["unitframes"].healthcolor))	
			healthBG:SetTexture(unpack(C["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true	
			healthBG.multiplier = 0.3
		end
		health.colorDisconnected = false
		
		-- Border for HealthBar
		local FrameBorder = CreateFrame("Frame", nil, health)
		FrameBorder:SetPoint("TOPLEFT", health, "TOPLEFT", E.Scale(-2), E.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
		FrameBorder:SetTemplate("Default")
		FrameBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		self.FrameBorder:CreateShadow("Default")
		self.FrameBorder.shadow:SetFrameLevel(0)
		self.FrameBorder.shadow:SetFrameStrata("BACKGROUND")
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, E.Scale(1))
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, C["unitframes"].fontsize, "OUTLINE")
		Name:SetShadowColor(0, 0, 0, 0.4)
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

local function LoadDPSLayout()
	local oUF = ElvUF or oUF
	assert(oUF, "ElvUI was unable to locate oUF.")

	if E.LoadUFFunctions then E.LoadUFFunctions("ElvDPS") end
	oUF:RegisterStyle('Elv', Shared)

	local yOffset = 0
	if C["castbar"].castermode == true then
		yOffset = yOffset + 28
	end
	if C["unitframes"].swingbar then 
		yOffset = yOffset + 10
	end

	-- Player
	local player = oUF:Spawn('player', "ElvDPS_player")
	if C["unitframes"].charportrait == true then
		player:SetPoint("BOTTOM", ElvuiActionBarBackground, "TOPLEFT", E.Scale(-20),E.Scale(55+yOffset))
	else
		player:SetPoint("BOTTOMLEFT", ElvuiActionBarBackground, "TOPLEFT", -ElvuiSplitActionBarRightBackground:GetWidth() + E.Scale(-2),E.Scale(35+yOffset))
	end
	player:SetSize(player_width, player_height)

	-- Target
	local target = oUF:Spawn('target', "ElvDPS_target")
	if C["unitframes"].charportrait == true then
		target:SetPoint("BOTTOM", ElvuiActionBarBackground, "TOPRIGHT", E.Scale(20),E.Scale(55+yOffset))
	else
		target:SetPoint("BOTTOMRIGHT", ElvuiActionBarBackground, "TOPRIGHT", ElvuiSplitActionBarRightBackground:GetWidth() + E.Scale(2),E.Scale(35+yOffset))
	end
	target:SetSize(target_width, target_height)

	-- Focus
	local focus = oUF:Spawn('focus', "ElvDPS_focus")
	focus:SetPoint("BOTTOMLEFT", ElvDPS_target, "TOPRIGHT", E.Scale(-35),E.Scale(120))
	focus:SetSize(smallframe_width, smallframe_height)

	-- Target's Target
	local tot = oUF:Spawn('targettarget', "ElvDPS_targettarget")
	tot:SetPoint("BOTTOM", ElvuiActionBarBackground, "TOP", 0,E.Scale(35+yOffset))
	tot:SetSize(smallframe_width, smallframe_height)

	-- Player's Pet
	local pet = oUF:Spawn('pet', "ElvDPS_pet")
	pet:SetPoint("BOTTOM", ElvDPS_targettarget, "TOP", 0,E.Scale(15))
	pet:SetSize(smallframe_width, smallframe_height)
	pet:SetParent(player)

	-- Player's Pet's Target
	if C["unitframes"].pettarget == true then
		local pettarget = oUF:Spawn('pettarget', "ElvDPS_pettarget")
		pettarget:SetPoint("BOTTOM", ElvDPS_pet, "TOP", 0,E.Scale(8))
		pettarget:SetSize(smallframe_width, smallframe_height*0.8)
		pettarget:SetParent(pet)
	end

	-- Focus's target
	if C["unitframes"].showfocustarget == true then
		local focustarget = oUF:Spawn('focustarget', "ElvDPS_focustarget")
		focustarget:SetPoint("BOTTOM", ElvDPS_focus, "TOP", 0,E.Scale(15))
		focustarget:SetSize(smallframe_width, smallframe_height)
	end

	if C.arena.unitframes then
		local arena = {}
		for i = 1, 5 do
			arena[i] = oUF:Spawn("arena"..i, "ElvDPSArena"..i)
			if i == 1 then
				arena[i]:SetPoint("BOTTOMLEFT", ChatRBackground2, "TOPLEFT", -80, 185)
			else
				arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 38)
			end
			arena[i]:SetSize(arenaboss_width, arenaboss_height)
		end
	end

	if C.raidframes.showboss then
		local boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss"..i, "ElvDPSBoss"..i)
			if i == 1 then
				boss[i]:SetPoint("BOTTOMLEFT", ChatRBackground2, "TOPLEFT", -80, 185)
			else
				boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 38)             
			end
			boss[i]:SetSize(arenaboss_width, arenaboss_height)
		end
	end

	if C["raidframes"].maintank == true then
		local tank = oUF:SpawnHeader('ElvDPSMainTank', nil, 'raid', 
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
		tank:Point("LEFT", UIParent, "LEFT", 6, 250)
	end

	if C["raidframes"].mainassist == true then
		local assist = oUF:SpawnHeader("ElvDPSMainAssist", nil, 'raid', 
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
		if C["raidframes"].maintank == true then 
			assist:Point("TOPLEFT", ElvDPSMainTank, "BOTTOMLEFT", 0, -50)
		else
			assist:Point("LEFT", UIParent, "LEFT", 6, 250)
		end
	end

	local party
	if C["raidframes"].disableblizz == true then --seriosly lazy addon authors can suck my dick
		for i = 1,MAX_BOSS_FRAMES do
			local t_boss = _G["Boss"..i.."TargetFrame"]
			t_boss:UnregisterAllEvents()
			t_boss.Show = E.dummy
			t_boss:Hide()
			_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
			_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
		end
		
		party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)
		local blizzloader = CreateFrame("Frame")
		blizzloader:RegisterEvent("ADDON_LOADED")
		blizzloader:SetScript("OnEvent", function(self, event, addon)
			if addon == "Elvui_RaidDPS" then 
				CompactRaidFrameContainer:Kill()
				CompactPartyFrame:Kill()
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
	
	E.LoadDPSMoveElements("ElvDPS")
	E.LoadClassTimers(ElvDPS_player, ElvDPS_target)
end

E.Layouts["DPS"] = LoadDPSLayout