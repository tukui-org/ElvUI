if not TukuiCF["unitframes"].enable == true then return end

------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local db = TukuiCF["unitframes"]
local font1 = TukuiCF["media"].uffont
local font2 = TukuiCF["media"].font
local normTex = TukuiCF["media"].normTex
local glowTex = TukuiCF["media"].glowTex
local bubbleTex = TukuiCF["media"].bubbleTex

local backdrop = {
	bgFile = TukuiCF["media"].blank,
	insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult},
}

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	-- set our own colors
	self.colors = TukuiDB.oUF_colors
	
	-- register click
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- menu? lol
	self.menu = TukuiDB.SpawnMenu

	-- backdrop for every units
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)

	-- this is the glow border
	TukuiDB.CreateShadow(self)
	
	------------------------------------------------------------------------
	--	Player and Target units layout (mostly mirror'd)
	------------------------------------------------------------------------
	
	if (unit == "player" or unit == "target") then
		-- create a panel
		local panel = CreateFrame("Frame", nil, self)
		if TukuiDB.lowversion then
			TukuiDB.CreatePanel(panel, 186, 21, "BOTTOM", self, "BOTTOM", 0, 0)
		else
			TukuiDB.CreatePanel(panel, 250, 21, "BOTTOM", self, "BOTTOM", 0, 0)
		end
		panel:SetFrameLevel(2)
		panel:SetFrameStrata("MEDIUM")
		panel:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
		self.panel = panel
	
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		if TukuiDB.lowversion then
			health:SetHeight(TukuiDB.Scale(20))
		else
			health:SetHeight(TukuiDB.Scale(26))
		end
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
				
		-- health bar background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
	
		health.value = TukuiDB.SetFontString(panel, font1, 12)
		health.value:SetPoint("RIGHT", panel, "RIGHT", TukuiDB.Scale(-4), 0)
		health.PostUpdate = TukuiDB.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG

		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
		end

		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetHeight(TukuiDB.Scale(8))
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
		power:SetStatusBarTexture(normTex)
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = TukuiDB.SetFontString(panel, font1, 12)
		power.value:SetPoint("LEFT", panel, "LEFT", TukuiDB.Scale(4), 0)
		power.PreUpdate = TukuiDB.PreUpdatePower
		power.PostUpdate = TukuiDB.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		power.frequentUpdates = true
		power.colorDisconnected = true

		if db.showsmooth == true then
			power.Smooth = true
		end
		
		if db.unicolor == true then
			power.colorTapping = true
			power.colorClass = true
			powerBG.multiplier = 0.1				
		else
			power.colorPower = true
		end

		-- portraits
		if (db.charportrait == true) then
			local portrait = CreateFrame("PlayerModel", nil, self)
			portrait:SetFrameLevel(8)
			if TukuiDB.lowversion then
				portrait:SetHeight(51)
			else
				portrait:SetHeight(57)
			end
			portrait:SetWidth(33)
			portrait:SetAlpha(1)
			if unit == "player" then
				health:SetPoint("TOPLEFT", 34,0)
				health:SetPoint("TOPRIGHT")
				power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
				power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
				panel:SetPoint("TOPLEFT", power, "BOTTOMLEFT", 0, -TukuiDB.mult)
				panel:SetPoint("TOPRIGHT", power, "BOTTOMRIGHT", 0, -TukuiDB.mult)
				portrait:SetPoint("TOPLEFT", health, "TOPLEFT", -34,0)
			elseif unit == "target" then
				health:SetPoint("TOPRIGHT", -34,0)
				health:SetPoint("TOPLEFT")
				power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
				power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
				panel:SetPoint("TOPRIGHT", power, "BOTTOMRIGHT", 0, -TukuiDB.mult)
				panel:SetPoint("TOPLEFT", power, "BOTTOMLEFT", 0, -TukuiDB.mult)
				portrait:SetPoint("TOPRIGHT", health, "TOPRIGHT", 34,0)
			end
			table.insert(self.__elements, TukuiDB.HidePortrait)
			self.Portrait = portrait
		end

		if (unit == "player") then
			-- combat icon
			local Combat = health:CreateTexture(nil, "OVERLAY")
			Combat:SetHeight(TukuiDB.Scale(19))
			Combat:SetWidth(TukuiDB.Scale(19))
			Combat:SetPoint("LEFT",0,1)
			Combat:SetVertexColor(0.69, 0.31, 0.31)
			self.Combat = Combat

			-- custom info (low mana warning)
			FlashInfo = CreateFrame("Frame", "FlashInfo", self)
			FlashInfo:SetScript("OnUpdate", TukuiDB.UpdateManaLevel)
			FlashInfo.parent = self
			FlashInfo:SetToplevel(true)
			FlashInfo:SetAllPoints(panel)
			FlashInfo.ManaLevel = TukuiDB.SetFontString(FlashInfo, font1, 12)
			FlashInfo.ManaLevel:SetPoint("CENTER", panel, "CENTER", 0, 0)
			self.FlashInfo = FlashInfo
			
			-- pvp status text
			local status = TukuiDB.SetFontString(panel, font1, 12)
			status:SetPoint("CENTER", panel, "CENTER", 0, 0)
			status:SetTextColor(0.69, 0.31, 0.31, 0)
			self.Status = status
			self:Tag(status, "[pvp]")
			
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
						
			-- the threat bar on info left panel ? :P
			if (db.showthreat == true) then
				local ThreatBar = CreateFrame("StatusBar", self:GetName()..'_ThreatBar', TukuiInfoLeft)
				ThreatBar:SetFrameLevel(5)
				ThreatBar:SetPoint("TOPLEFT", TukuiInfoLeft, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				ThreatBar:SetPoint("BOTTOMRIGHT", TukuiInfoLeft, TukuiDB.Scale(-2), TukuiDB.Scale(2))
			  
				ThreatBar:SetStatusBarTexture(normTex)
				ThreatBar:GetStatusBarTexture():SetHorizTile(false)
				ThreatBar:SetBackdrop(backdrop)
				ThreatBar:SetBackdropColor(0, 0, 0, 0)
		   
				ThreatBar.Text = TukuiDB.SetFontString(ThreatBar, font2, 12)
				ThreatBar.Text:SetPoint("RIGHT", ThreatBar, "RIGHT", TukuiDB.Scale(-30), 0)
		
				ThreatBar.Title = TukuiDB.SetFontString(ThreatBar, font2, 12)
				ThreatBar.Title:SetText(tukuilocal.unitframes_ouf_threattext)
				ThreatBar.Title:SetPoint("LEFT", ThreatBar, "LEFT", TukuiDB.Scale(30), 0)
					  
				ThreatBar.bg = ThreatBar:CreateTexture(nil, 'BORDER')
				ThreatBar.bg:SetAllPoints(ThreatBar)
				ThreatBar.bg:SetTexture(0.1,0.1,0.1)
		   
				ThreatBar.useRawThreat = false
				self.ThreatBar = ThreatBar
			end
			
			-- experience bar on player via mouseover for player currently levelling a character
			if TukuiDB.level ~= MAX_PLAYER_LEVEL then
				local Experience = CreateFrame("StatusBar", self:GetName().."_Experience", self)
				Experience:SetStatusBarTexture(normTex)
				Experience:SetStatusBarColor(0, 0.4, 1, .8)
				Experience:SetBackdrop(backdrop)
				Experience:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
				Experience:SetWidth(panel:GetWidth() - TukuiDB.Scale(4))
				Experience:SetHeight(panel:GetHeight() - TukuiDB.Scale(4))
				Experience:SetPoint("TOPLEFT", panel, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				Experience:SetPoint("BOTTOMRIGHT", panel, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				Experience:SetFrameLevel(10)
				Experience:SetAlpha(0)				
				Experience:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
				Experience:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
				Experience.Tooltip = true						
				Experience.Rested = CreateFrame('StatusBar', nil, self)
				Experience.Rested:SetParent(Experience)
				Experience.Rested:SetAllPoints(Experience)
				local Resting = Experience:CreateTexture(nil, "OVERLAY")
				Resting:SetHeight(28)
				Resting:SetWidth(28)
				if TukuiDB.myclass == "SHAMAN" or TukuiDB.myclass == "DEATHKNIGHT" or TukuiDB.myclass == "PALADIN" or TukuiDB.myclass == "WARLOCK" or TukuiDB.myclass == "DRUID" then
					Resting:SetPoint("LEFT", -18, 76)
				else
					Resting:SetPoint("LEFT", -18, 68)
				end
				Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
				Resting:SetTexCoord(0, 0.5, 0, 0.421875)
				self.Resting = Resting
				self.Experience = Experience
			end
			
			-- reputation bar for max level character
			if TukuiDB.level == MAX_PLAYER_LEVEL then
				local Reputation = CreateFrame("StatusBar", self:GetName().."_Reputation", self)
				Reputation:SetStatusBarTexture(normTex)
				Reputation:SetBackdrop(backdrop)
				Reputation:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
				Reputation:SetWidth(panel:GetWidth() - TukuiDB.Scale(4))
				Reputation:SetHeight(panel:GetHeight() - TukuiDB.Scale(4))
				Reputation:SetPoint("TOPLEFT", panel, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				Reputation:SetPoint("BOTTOMRIGHT", panel, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				Reputation:SetFrameLevel(10)
				Reputation:SetAlpha(0)

				Reputation:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
				Reputation:HookScript("OnLeave", function(self) self:SetAlpha(0) end)

				Reputation.PostUpdate = TukuiDB.UpdateReputationColor
				Reputation.Tooltip = true
				self.Reputation = Reputation
			end
			
			-- show druid mana when shapeshifted in bear, cat or whatever
			if TukuiDB.myclass == "DRUID" then
				CreateFrame("Frame"):SetScript("OnUpdate", function() TukuiDB.UpdateDruidMana(self) end)
				local DruidMana = TukuiDB.SetFontString(health, font1, 12)
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
				
				local eclipseBar = CreateFrame('Frame', nil, self)
				eclipseBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(1))
				if TukuiDB.lowversion then
					eclipseBar:SetSize(TukuiDB.Scale(186), TukuiDB.Scale(8))
				else
					eclipseBar:SetSize(TukuiDB.Scale(250), TukuiDB.Scale(8))
				end
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
				eclipseBarText:SetPoint('TOP', panel)
				eclipseBarText:SetPoint('BOTTOM', panel)
				eclipseBarText:SetFont(font1, 12)
				eclipseBar.Text = eclipseBarText

				self.EclipseBar = eclipseBar
			end

			-- set holy power bar or shard bar
			if (TukuiDB.myclass == "WARLOCK" or TukuiDB.myclass == "PALADIN") then
				self.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(11))
	
				local bars = CreateFrame("Frame", nil, self)
				bars:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(1))
				if TukuiDB.lowversion then
					bars:SetWidth(TukuiDB.Scale(186))
				else
					bars:SetWidth(TukuiDB.Scale(250))
				end
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
						bars[i]:SetStatusBarColor(255/255,101/255,101/255)
						bars[i].bg:SetTexture(255/255,101/255,101/255)
					elseif TukuiDB.myclass == "PALADIN" then
						bars[i]:SetStatusBarColor(228/255,225/255,16/255)
						bars[i].bg:SetTexture(228/255,225/255,16/255)
					end
					
					if i == 1 then
						bars[i]:SetPoint("LEFT", bars)
						if TukuiDB.lowversion then
							bars[i]:SetWidth(TukuiDB.Scale(62))
						else
							bars[i]:SetWidth(TukuiDB.Scale(82)) -- setting SetWidth here just to fit fit 250 perfectly
						end
						bars[i].bg:SetAllPoints(bars[i])
					else
						bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", TukuiDB.Scale(1), 0)
						if TukuiDB.lowversion then
							bars[i]:SetWidth(TukuiDB.Scale(61))
						else
							bars[i]:SetWidth(TukuiDB.Scale(83)) -- setting SetWidth here just to fit fit 250 perfectly
						end
						bars[i].bg:SetAllPoints(bars[i])
					end
					
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
			end

			-- deathknight runes
			if TukuiDB.myclass == "DEATHKNIGHT" and db.runebar == true then
				-- rescale top shadow border
				self.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(13))
				
				local Runes = CreateFrame("Frame", nil, self)
				Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(1))
				Runes:SetHeight(TukuiDB.Scale(8))
				if TukuiDB.lowversion then
					Runes:SetWidth(TukuiDB.Scale(186))
				else
					Runes:SetWidth(TukuiDB.Scale(250))
				end
				Runes:SetBackdrop(backdrop)
				Runes:SetBackdropColor(0, 0, 0)

				for i = 1, 6 do
					Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
					Runes[i]:SetHeight(TukuiDB.Scale(8))
					if TukuiDB.lowversion then
						Runes[i]:SetWidth(TukuiDB.Scale(181) / 6)
					else
						Runes[i]:SetWidth(TukuiDB.Scale(245) / 6)
					end
					if (i == 1) then
						Runes[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(1))
					else
						Runes[i]:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", TukuiDB.Scale(1), 0)
					end
					Runes[i]:SetStatusBarTexture(normTex)
					Runes[i]:GetStatusBarTexture():SetHorizTile(false)
				end

				self.Runes = Runes
			end
			
			-- shaman totem bar
			if TukuiDB.myclass == "SHAMAN" and db.totemtimer == true then
				-- rescale top shadow border
				self.shadow:SetPoint("TOPLEFT", TukuiDB.Scale(-4), TukuiDB.Scale(13))
				
				local TotemBar = {}
				TotemBar.Destroy = true
				for i = 1, 4 do
					TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
					if (i == 1) then
					   TotemBar[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(1))
					else
					   TotemBar[i]:SetPoint("TOPLEFT", TotemBar[i-1], "TOPRIGHT", TukuiDB.Scale(1), 0)
					end
					TotemBar[i]:SetStatusBarTexture(normTex)
					TotemBar[i]:SetHeight(TukuiDB.Scale(8))
					if TukuiDB.lowversion then
						TotemBar[i]:SetWidth(TukuiDB.Scale(183) / 4)
					else
						TotemBar[i]:SetWidth(TukuiDB.Scale(247) / 4)
					end
					TotemBar[i]:SetBackdrop(backdrop)
					TotemBar[i]:SetBackdropColor(0, 0, 0)
					TotemBar[i]:SetMinMaxValues(0, 1)

					TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
					TotemBar[i].bg:SetAllPoints(TotemBar[i])
					TotemBar[i].bg:SetTexture(normTex)
					TotemBar[i].bg.multiplier = 0.3
				end
				self.TotemBar = TotemBar
			end
			
			-- script for pvp status and low mana
			self:SetScript("OnEnter", function(self) 
				FlashInfo.ManaLevel:Hide() status:SetAlpha(1) UnitFrame_OnEnter(self) 
			end)
			self:SetScript("OnLeave", function(self) 
				FlashInfo.ManaLevel:Show() status:SetAlpha(0) UnitFrame_OnLeave(self) 
			end)
		end
		
		if (unit == "target") then			
			-- Unit name on target
			local Name = health:CreateFontString(nil, "OVERLAY")
			Name:SetPoint("LEFT", panel, "LEFT", TukuiDB.Scale(4), 0)
			Name:SetJustifyH("LEFT")
			Name:SetFont(font1, 12)

			self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
			self.Name = Name
			
			-- combo points on target
			local CPoints = {}
			CPoints.unit = PlayerFrame.unit
			for i = 1, 5 do
				CPoints[i] = health:CreateTexture(nil, "OVERLAY")
				CPoints[i]:SetHeight(TukuiDB.Scale(12))
				CPoints[i]:SetWidth(TukuiDB.Scale(12))
				CPoints[i]:SetTexture(bubbleTex)
				if i == 1 then
					if TukuiDB.lowversion then
						CPoints[i]:SetPoint("TOPRIGHT", TukuiDB.Scale(15), TukuiDB.Scale(1.5))
					else
						CPoints[i]:SetPoint("TOPLEFT", TukuiDB.Scale(-15), TukuiDB.Scale(1.5))
					end
					CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
				else
					CPoints[i]:SetPoint("TOP", CPoints[i-1], "BOTTOM", TukuiDB.Scale(1))
				end
			end
			CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
			CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
			CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
			CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
			self.CPoints = CPoints
			self:RegisterEvent("UNIT_COMBO_POINTS", TukuiDB.UpdateCPoints)
		end

		if (unit == "target" and db.targetauras) or (unit == "player" and db.playerauras) then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			
			if (TukuiDB.myclass == "SHAMAN" or TukuiDB.myclass == "DEATHKNIGHT" or TukuiDB.myclass == "PALADIN" or TukuiDB.myclass == "WARLOCK") and (db.playerauras) and (unit == "player") then
				if TukuiDB.lowversion then
					buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 34)
				else
					buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 38)
				end
			else
				if TukuiDB.lowversion then
					buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 26)
				else
					buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 30)
				end
			end
			
			if TukuiDB.lowversion then
				buffs:SetHeight(21.5)
				buffs:SetWidth(186)
				buffs.size = 21.5
				buffs.num = 8
				
				debuffs:SetHeight(21.5)
				debuffs:SetWidth(186)
				debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 0, 2)
				debuffs.size = 21.5	
				debuffs.num = 24
			else				
				buffs:SetHeight(26)
				buffs:SetWidth(252)
				buffs.size = 26
				buffs.num = 9
				
				debuffs:SetHeight(26)
				debuffs:SetWidth(252)
				debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", -2, 2)
				debuffs.size = 26
				debuffs.num = 27
			end
						
			buffs.spacing = 2
			buffs.initialAnchor = 'TOPLEFT'
			buffs.PostCreateIcon = TukuiDB.PostCreateAura
			buffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Buffs = buffs	
						
			debuffs.spacing = 2
			debuffs.initialAnchor = 'TOPRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = TukuiDB.PostCreateAura
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
		end
		
		-- cast bar for player and target
		if (db.unitcastbar == true) then
			-- castbar of player and target
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetStatusBarTexture(normTex)
			
			castbar.bg = castbar:CreateTexture(nil, "BORDER")
			castbar.bg:SetAllPoints(castbar)
			castbar.bg:SetTexture(normTex)
			castbar.bg:SetVertexColor(0.15, 0.15, 0.15)
			castbar:SetFrameLevel(6)
			castbar:SetPoint("TOPLEFT", panel, TukuiDB.Scale(2), TukuiDB.Scale(-2))
			castbar:SetPoint("BOTTOMRIGHT", panel, TukuiDB.Scale(-2), TukuiDB.Scale(2))
			
			castbar.CustomTimeText = TukuiDB.CustomCastTimeText
			castbar.CustomDelayText = TukuiDB.CustomCastDelayText
			castbar.PostCastStart = TukuiDB.CheckCast
			castbar.PostChannelStart = TukuiDB.CheckChannel

			castbar.time = TukuiDB.SetFontString(castbar, font1, 12)
			castbar.time:SetPoint("RIGHT", panel, "RIGHT", TukuiDB.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")

			castbar.Text = TukuiDB.SetFontString(castbar, font1, 12)
			castbar.Text:SetPoint("LEFT", panel, "LEFT", TukuiDB.Scale(4), 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			if db.cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(TukuiDB.Scale(26))
				castbar.button:SetWidth(TukuiDB.Scale(26))
				TukuiDB.SetTemplate(castbar.button)
				TukuiDB.CreateShadow(castbar.button)

				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
			
				if unit == "player" then
					if db.charportrait == true then
						castbar.button:SetPoint("LEFT", -82.5, 26.5)
					else
						castbar.button:SetPoint("LEFT", -46.5, 26.5)
					end
				elseif unit == "target" then
					if db.charportrait == true then
						castbar.button:SetPoint("RIGHT", 82.5, 26.5)
					else
						castbar.button:SetPoint("RIGHT", 46.5, 26.5)
					end					
				end
			end
			
			-- cast bar latency on player
			if unit == "player" and db.cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end
					
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if db.combatfeedback == true then
			local CombatFeedbackText 
			if TukuiDB.lowversion then
				CombatFeedbackText = TukuiDB.SetFontString(health, font1, 12, "OUTLINE")
			else
				CombatFeedbackText = TukuiDB.SetFontString(health, font1, 14, "OUTLINE")
			end
			CombatFeedbackText:SetPoint("CENTER", 0, 1)
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
		
		if db.healcomm then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			if TukuiDB.lowversion then
				mhpb:SetWidth(186)
			else
				mhpb:SetWidth(250)
			end
			mhpb:SetStatusBarTexture(normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
			mhpb:SetMinMaxValues(0,1)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetWidth(250)
			ohpb:SetStatusBarTexture(normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		-- player aggro
		if db.playeraggro == true then
			table.insert(self.__elements, TukuiDB.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', TukuiDB.UpdateThreat)
		end
	end
	
	------------------------------------------------------------------------
	--	Target of Target unit layout
	------------------------------------------------------------------------
	
	if (unit == "targettarget") then
		-- create panel if higher version
		local panel = CreateFrame("Frame", nil, self)
		if not TukuiDB.lowversion then
			TukuiDB.CreatePanel(panel, 129, 17, "BOTTOM", self, "BOTTOM", 0, TukuiDB.Scale(0))
			panel:SetFrameLevel(2)
			panel:SetFrameStrata("MEDIUM")
			panel:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
			self.panel = panel
		end
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(18))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
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
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true			
		end
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		if TukuiDB.lowversion then
			Name:SetPoint("CENTER", health, "CENTER", 0, 0)
			Name:SetFont(font1, 12, "OUTLINE")
		else
			Name:SetPoint("CENTER", panel, "CENTER", 0, 0)
			Name:SetFont(font1, 12)
		end
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		if db.totdebuffs == true and TukuiDB.lowversion ~= true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:SetHeight(20)
			debuffs:SetWidth(127)
			debuffs.size = 20
			debuffs.spacing = 2
			debuffs.num = 6

			debuffs:SetPoint("TOPLEFT", health, "TOPLEFT", -0.5, 24)
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = TukuiDB.PostCreateAura
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
		end
	end
	
	------------------------------------------------------------------------
	--	Pet unit layout
	------------------------------------------------------------------------
	
	if (unit == "pet") then
		-- create panel if higher version
		local panel = CreateFrame("Frame", nil, self)
		if not TukuiDB.lowversion then
			TukuiDB.CreatePanel(panel, 129, 17, "BOTTOM", self, "BOTTOM", 0, TukuiDB.Scale(0))
			panel:SetFrameLevel(2)
			panel:SetFrameStrata("MEDIUM")
			panel:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
			self.panel = panel
		end
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(13))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
				
		self.Health = health
		self.Health.bg = healthBG
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true	
			health.colorClass = true
			health.colorReaction = true	
			if TukuiDB.myclass == "HUNTER" then
				health.colorHappiness = true
			end
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetHeight(TukuiDB.Scale(4))
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
		power:SetStatusBarTexture(normTex)
		
		power.frequentUpdates = true
		power.colorPower = true
		if db.showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
				
		self.Power = power
		self.Power.bg = powerBG
				
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		if TukuiDB.lowversion then
			Name:SetPoint("CENTER", self, "CENTER", 0, 0)
			Name:SetFont(font1, 12, "OUTLINE")
		else
			Name:SetPoint("CENTER", panel, "CENTER", 0, 0)
			Name:SetFont(font1, 12)
		end
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium] [Tukui:diffcolor][level]')
		self.Name = Name
		
		if (db.unitcastbar == true) then
			-- castbar of player and target
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetStatusBarTexture(normTex)
			
			if not TukuiDB.lowversion then
				castbar.bg = castbar:CreateTexture(nil, "BORDER")
				castbar.bg:SetAllPoints(castbar)
				castbar.bg:SetTexture(normTex)
				castbar.bg:SetVertexColor(0.15, 0.15, 0.15)
				castbar:SetFrameLevel(6)
				castbar:SetPoint("TOPLEFT", panel, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				castbar:SetPoint("BOTTOMRIGHT", panel, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				
				castbar.CustomTimeText = TukuiDB.CustomCastTimeText
				castbar.CustomDelayText = TukuiDB.CustomCastDelayText
				castbar.PostCastStart = TukuiDB.CheckCast
				castbar.PostChannelStart = TukuiDB.CheckChannel

				castbar.time = TukuiDB.SetFontString(castbar, font1, 12)
				castbar.time:SetPoint("RIGHT", panel, "RIGHT", TukuiDB.Scale(-4), 0)
				castbar.time:SetTextColor(0.84, 0.75, 0.65)
				castbar.time:SetJustifyH("RIGHT")

				castbar.Text = TukuiDB.SetFontString(castbar, font1, 12)
				castbar.Text:SetPoint("LEFT", panel, "LEFT", TukuiDB.Scale(4), 0)
				castbar.Text:SetTextColor(0.84, 0.75, 0.65)
				
				self.Castbar = castbar
				self.Castbar.Time = castbar.time
			end
		end
		
		-- update pet name, this should fix "UNKNOWN" pet names on pet unit.
		self:RegisterEvent("UNIT_PET", TukuiDB.UpdatePetInfo)
	end


	------------------------------------------------------------------------
	--	Focus unit layout
	------------------------------------------------------------------------
	
	if (unit == "focus") then
		-- hide shadow
		self.shadow:SetAlpha(0)
		
		-- create health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetPoint("TOPLEFT")
		health:SetPoint("BOTTOMRIGHT")
		health:SetStatusBarTexture(normTex)
		health:GetStatusBarTexture():SetHorizTile(false)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		health.value = TukuiDB.SetFontString(health, font1, 12, "OUTLINE")
		health.value:SetPoint("RIGHT", health, "RIGHT", TukuiDB.Scale(-4), 0)
		health.PostUpdate = TukuiDB.PostUpdateHealth
		
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("LEFT", health, "LEFT", TukuiDB.Scale(4), 0)
		Name:SetJustifyH("LEFT")
		Name:SetFont(font1, 12, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
		self.Name = Name

		-- create focus debuff feature
		if db.focusdebuffs == true then
			local debuffs = CreateFrame("Frame", nil, self)
			debuffs:SetHeight(26)
			debuffs:SetWidth(TukuiCF["panels"].tinfowidth - 10)
			debuffs.size = 26
			debuffs.spacing = 2
			debuffs.num = 40
						
			debuffs:SetPoint("TOPRIGHT", self, "TOPRIGHT", 2, 38)
			debuffs.initialAnchor = "TOPRIGHT"
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			
			debuffs.PostCreateIcon = TukuiDB.PostCreateAura
			debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Debuffs = debuffs
		end
		
		-- focus cast bar in the center of the screen
		if db.unitcastbar == true then
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
			TukuiDB.CreateShadow(castbar.bg)
			
			castbar.time = TukuiDB.SetFontString(castbar, font1, 12)
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", TukuiDB.Scale(-4), 0)
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")
			castbar.CustomTimeText = CustomCastTimeText

			castbar.Text = TukuiDB.SetFontString(castbar, font1, 12)
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", TukuiDB.Scale(4), 0)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			castbar.CustomDelayText = TukuiDB.CustomCastDelayText
			castbar.PostCastStart = TukuiDB.CheckCast
			castbar.PostChannelStart = TukuiDB.CheckChannel
			
			if db.cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)
				castbar.button:SetHeight(TukuiDB.Scale(40))
				castbar.button:SetWidth(TukuiDB.Scale(40))
				castbar.button:SetPoint("CENTER", 0, TukuiDB.Scale(50))
				TukuiDB.SetTemplate(castbar.button)

				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, TukuiDB.Scale(2), TukuiDB.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, TukuiDB.Scale(-2), TukuiDB.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				
				TukuiDB.CreateShadow(castbar.button)
			end

			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
	end
	
	------------------------------------------------------------------------
	--	Focus target unit layout
	------------------------------------------------------------------------

	if (unit == "focustarget") then
		-- create panel if higher version
		local panel = CreateFrame("Frame", nil, self)
		TukuiDB.CreatePanel(panel, 129, 17, "BOTTOM", self, "BOTTOM", 0, 0)
		panel:SetFrameLevel(2)
		panel:SetFrameStrata("MEDIUM")
		panel:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
		self.panel = panel
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(18))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
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
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true			
		end
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", panel, "CENTER", 0, 0)
		Name:SetFont(font1, 12)
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium] [Tukui:diffcolor][level]')
		self.Name = Name
	end

	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and TukuiCF["arena"].unitframes == true) or (unit and unit:find("boss%d") and db.showboss == true) then
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(TukuiDB.Scale(22))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)

		health.frequentUpdates = true
		health.colorDisconnected = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)

		health.value = TukuiDB.SetFontString(health, font1,12, "OUTLINE")
		health.value:SetPoint("LEFT", TukuiDB.Scale(2), 0)
		health.PostUpdate = TukuiDB.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if db.showsmooth == true then
			health.Smooth = true
		end
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
	
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetHeight(TukuiDB.Scale(6))
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
		power:SetStatusBarTexture(normTex)
		
		power.frequentUpdates = true
		power.colorPower = true
		if db.showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = TukuiDB.SetFontString(health, font1, 12, "OUTLINE")
		power.value:SetPoint("RIGHT", TukuiDB.Scale(-2), 0)
		power.PreUpdate = TukuiDB.PreUpdatePower
		power.PostUpdate = TukuiDB.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, 12, "OUTLINE")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name
		
		-- create buff at left of unit if they are boss units
		if (unit and unit:find("boss%d")) then
			local buffs = CreateFrame("Frame", nil, self)
			buffs:SetHeight(26)
			buffs:SetWidth(252)
			buffs:SetPoint("RIGHT", self, "LEFT", TukuiDB.Scale(-4), 0)
			buffs.size = 26
			buffs.num = 3
			buffs.spacing = 2
			buffs.initialAnchor = 'RIGHT'
			buffs["growth-x"] = "LEFT"
			buffs.PostCreateIcon = TukuiDB.PostCreateAura
			buffs.PostUpdateIcon = TukuiDB.PostUpdateAura
			self.Buffs = buffs
		end

		-- create debuff for both arena and boss units
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(26)
		debuffs:SetWidth(200)
		debuffs:SetPoint('LEFT', self, 'RIGHT', TukuiDB.Scale(4), 0)
		debuffs.size = 26
		debuffs.num = 5
		debuffs.spacing = 2
		debuffs.initialAnchor = 'LEFT'
		debuffs["growth-x"] = "RIGHT"
		debuffs.PostCreateIcon = TukuiDB.PostCreateAura
		debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
		self.Debuffs = debuffs	
				
		-- trinket feature via trinket plugin
		if (TukuiCF.arena.unitframes) and (unit and unit:find('arena%d')) then
			local Trinketbg = CreateFrame("Frame", nil, self)
			Trinketbg:SetHeight(26)
			Trinketbg:SetWidth(26)
			Trinketbg:SetPoint("RIGHT", self, "LEFT", -6, 0)				
			TukuiDB.SetTemplate(Trinketbg)
			Trinketbg:SetFrameLevel(0)
			self.Trinketbg = Trinketbg
			
			local Trinket = CreateFrame("Frame", nil, Trinketbg)
			Trinket:SetAllPoints(Trinketbg)
			Trinket:SetPoint("TOPLEFT", Trinketbg, TukuiDB.Scale(2), TukuiDB.Scale(-2))
			Trinket:SetPoint("BOTTOMRIGHT", Trinketbg, TukuiDB.Scale(-2), TukuiDB.Scale(2))
			Trinket:SetFrameLevel(1)
			Trinket.trinketUseAnnounce = true
			self.Trinket = Trinket
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
		health:SetHeight(TukuiDB.Scale(20))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
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
		
		if db.unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(font1, 12, "OUTLINE")
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
	InvFrame:SetAllPoints()
	
	-- symbols, now put the symbol on the frame we created above.
	local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\raidicons.blp") -- thx hankthetank for texture
	RaidIcon:SetHeight(20)
	RaidIcon:SetWidth(20)
	RaidIcon:SetPoint("TOP", 0, 8)
	self.RaidIcon = RaidIcon
	
	return self
end

------------------------------------------------------------------------
--	Default position of Tukui unitframes
------------------------------------------------------------------------

-- for lower reso
local adjustXY = 0
local totdebuffs = 0
if TukuiDB.lowversion then adjustXY = 24 end
if db.totdebuffs then totdebuffs = 24 end

oUF:RegisterStyle('Tukz', Shared)

-- player
local player = oUF:Spawn('player', "oUF_Tukz_player")
player:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "TOPLEFT", 0,8+adjustXY)
if TukuiDB.lowversion then
	player:SetSize(TukuiDB.Scale(186), TukuiDB.Scale(51))
else
	player:SetSize(TukuiDB.Scale(250), TukuiDB.Scale(57))
end

-- focus
local focus = oUF:Spawn('focus', "oUF_Tukz_focus")
focus:SetPoint("CENTER", TukuiInfoRight, "CENTER")
focus:SetSize(TukuiInfoRight:GetWidth() - TukuiDB.Scale(4), TukuiInfoRight:GetHeight() - TukuiDB.Scale(4))

-- target
local target = oUF:Spawn('target', "oUF_Tukz_target")
target:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", 0,8+adjustXY)
if TukuiDB.lowversion then
	target:SetSize(TukuiDB.Scale(186), TukuiDB.Scale(51))
else
	target:SetSize(TukuiDB.Scale(250), TukuiDB.Scale(57))
end

-- tot
local tot = oUF:Spawn('targettarget', "oUF_Tukz_targettarget")
if TukuiDB.lowversion then
	tot:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", 0,8)
	tot:SetSize(TukuiDB.Scale(186), TukuiDB.Scale(18))
else
	tot:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0,8)
	tot:SetSize(TukuiDB.Scale(129), TukuiDB.Scale(36))
end

-- pet
local pet = oUF:Spawn('pet', "oUF_Tukz_pet")
if TukuiDB.lowversion then
	pet:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "TOPLEFT", 0,8)
	pet:SetSize(TukuiDB.Scale(186), TukuiDB.Scale(18))
else
	pet:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0,49+totdebuffs)
	pet:SetSize(TukuiDB.Scale(129), TukuiDB.Scale(36))
end

if db.showfocustarget then 
	local focustarget = oUF:Spawn("focustarget", "oUF_Tukz_focustarget")
	focustarget:SetPoint("BOTTOM", 0, 224)
	focustarget:SetSize(TukuiDB.Scale(129), TukuiDB.Scale(36))
end

if TukuiCF.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
		if i == 1 then
			arena[i]:SetPoint("BOTTOM", UIParent, "BOTTOM", 252, 260)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 10)
		end
		arena[i]:SetSize(TukuiDB.Scale(200), TukuiDB.Scale(29))
	end
end

if db.showboss then
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
			boss[i]:SetPoint("BOTTOM", UIParent, "BOTTOM", 252, 260)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 10)             
		end
		boss[i]:SetSize(TukuiDB.Scale(200), TukuiDB.Scale(29))
	end
end

-- THIS NEED TO BE UPDATED FOR 4.0.1 BUT I'M RUNNING OUT OF TIME FOR A v12 RELEASE.
--[[
if db.maintank == true then
	local tank = oUF:SpawnHeader("oUF_MainTank", nil, 'raid, party, solo', 
		"showRaid", true, "groupFilter", "MAINTANK", "yOffset", 5, "point" , "BOTTOM",
		"template", "oUF_tukzMtt"
	)
	tank:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

if db.mainassist == true then
	local assist = oUF:SpawnHeader("oUF_MainAssist", nil, 'raid, party, solo', 
		"showRaid", true, "groupFilter", "MAINASSIST", "yOffset", 5, "point" , "BOTTOM",
		"template", "oUF_tukzMtt"
	)
	assist:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
end
--]]

-- this is just a fake party to hide Blizzard frame if no Tukui raid layout are loaded.
local party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)

------------------------------------------------------------------------
--	Just a command to test buffs/debuffs alignment
------------------------------------------------------------------------

local testui = TestUI or function() end
TestUI = function()
	testui()
	UnitAura = function()
		-- name, rank, texture, count, dtype, duration, timeLeft, caster
		return 'penancelol', 'Rank 2', 'Interface\\Icons\\Spell_Holy_Penance', random(5), 'Magic', 0, 0, "player"
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

------------------------------------------------------------------------
-- Right-Click on unit frames menu. 
-- Doing this to remove SET_FOCUS eveywhere.
-- SET_FOCUS work only on default unitframes.
-- Main Tank and Main Assist, use /maintank and /mainassist commands.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "LEAVE", "CANCEL" };
	UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" }
	UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end

