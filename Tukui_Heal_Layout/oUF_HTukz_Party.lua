if not TukuiCF["raidframes"].enable == true == true or TukuiCF["raidframes"].gridonly == true then return end

local font2 = TukuiCF["media"].uffont
local font1 = TukuiCF["media"].font
local normTex = TukuiCF["media"].normTex

--Frame Size
local party_width = TukuiDB.Scale((TukuiActionBarBackground:GetWidth() / 5) + 7)
local party_height = TukuiDB.Scale(50)
local pet_width = party_width
local pet_height = TukuiDB.Scale(20)

local function Shared(self, unit)	
	self.colors = TukuiDB.oUF_colors
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = TukuiDB.SpawnMenu
	
	-- an update script to all elements
	self:HookScript("OnShow", TukuiDB.updateAllElements)
	
	if unit == "raidpet" then
		local health = CreateFrame('StatusBar', nil, self)
		health:SetAllPoints(self)
		health:SetStatusBarTexture(normTex)
		self.Health = health
		
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints(health)
		health.bg:SetTexture(normTex)
		health.frequentUpdates = true
		
		self.Health.bg = health.bg
		-- Setup Colors
		if TukuiCF["unitframes"].classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))	
			self.Health.bg:SetTexture(unpack(TukuiCF["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true		
			health.bg.multiplier = 0.3				
		end
		health.colorDisconnected = false
		
		-- border for all frames
		local FrameBorder = CreateFrame("Frame", nil, self)
		FrameBorder:SetPoint("TOPLEFT", self, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		TukuiDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		
		local name = health:CreateFontString(nil, "OVERLAY")
		name:SetPoint("CENTER", health, 0, 0)
		name:SetFont(font2, TukuiCF["raidframes"].fontsize, "THINOUTLINE")
		name:SetShadowOffset(1, -1)
		name.frequentUpdates = 0.2
		self:Tag(name, "[Tukui:getnamecolor][Tukui:nameshort]")
		self.Name = name
		
		if TukuiCF["unitframes"].aggro == true then
			table.insert(self.__elements, TukuiDB.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', TukuiDB.UpdateThreat)
		end
		
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
		
		--Heal Comm
		if TukuiCF["raidframes"].healcomm == true then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			mhpb:SetWidth(party_width)
			mhpb:SetStatusBarTexture(TukuiCF["media"].normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			ohpb:SetWidth(party_width)
			ohpb:SetStatusBarTexture(TukuiCF["media"].normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		if TukuiCF["raidframes"].showrange == true then
			local range = {insideAlpha = 1, outsideAlpha = TukuiCF["raidframes"].raidalphaoor}
			self.Range = range
		end
		
		if TukuiCF["unitframes"].showsmooth == true then health.Smooth = true end	
	else
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(party_height*.86)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		if TukuiCF["raidframes"].gridhealthvertical == true then
			health:SetOrientation("VERTICAL")
		end
		health:SetStatusBarTexture(normTex)
		self.Health = health
		
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints(health)
		health.bg:SetTexture(normTex)
		
		self.Health.bg = health.bg
			
		health.value = health:CreateFontString(nil, "OVERLAY")
		health.value:SetPoint("BOTTOM", health, "BOTTOM", 0, TukuiDB.Scale(4))
		health.value:SetFont(font2, TukuiCF["raidframes"].fontsize, "THINOUTLINE")
		health.value:SetTextColor(1,1,1)
		health.value:SetShadowOffset(1, -1)
		self.Health.value = health.value
		
		health.PostUpdate = TukuiDB.PostUpdateHealth
		
		health.frequentUpdates = true
		
		-- Setup Colors
		if TukuiCF["unitframes"].classcolor ~= true then
			health.colorTapping = false
			health.colorClass = false
			health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))	
			self.Health.bg:SetTexture(unpack(TukuiCF["unitframes"].healthbackdropcolor))
		else
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true		
			health.bg.multiplier = 0.3				
		end
		health.colorDisconnected = false
		
		-- border for all frames
		local FrameBorder = CreateFrame("Frame", nil, self)
		FrameBorder:SetPoint("TOPLEFT", self, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
		FrameBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
		TukuiDB.SetTemplate(FrameBorder)
		FrameBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))
		FrameBorder:SetFrameLevel(2)
		self.FrameBorder = FrameBorder
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, TukuiDB.Scale(-1)+(-TukuiDB.mult*2))
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		power:SetStatusBarTexture(normTex)
		self.Power = power
		--[[if TukuiCF["raidframes"].hidenonmana == true then
			power.PostUpdate = TukuiDB.PostUpdatePowerParty
		end]]
		
		-- border between health and power
		self.HealthBorder = CreateFrame("Frame", nil, power)
		self.HealthBorder:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, TukuiDB.mult)
		self.HealthBorder:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, TukuiDB.mult)
		TukuiDB.SetTemplate(self.HealthBorder)
		self.HealthBorder:SetBackdropBorderColor(unpack(TukuiCF["media"].altbordercolor))	
			
		power.frequentUpdates = true

		power.bg = self.Power:CreateTexture(nil, "BORDER")
		power.bg:SetAllPoints(power)
		power.bg:SetTexture(normTex)
		power.bg.multiplier = 0.3
		self.Power.bg = power.bg
		
		power.colorPower = true
		power.colorTapping = false
		power.colorDisconnected = true

		
		local name = health:CreateFontString(nil, "OVERLAY")
		name:SetPoint("TOP", health, 0, TukuiDB.Scale(-2))
		name:SetFont(font2, TukuiCF["raidframes"].fontsize, "THINOUTLINE")
		name:SetShadowOffset(1, -1)
		self:Tag(name, "[Tukui:getnamecolor][Tukui:nameshort]")
		self.Name = name
		
		local leader = health:CreateTexture(nil, "OVERLAY")
		leader:SetHeight(TukuiDB.Scale(12))
		leader:SetWidth(TukuiDB.Scale(12))
		leader:SetPoint("TOPLEFT", 0, 6)
		self.Leader = leader
		
		local LFDRole = health:CreateTexture(nil, "OVERLAY")
		LFDRole:SetHeight(TukuiDB.Scale(6))
		LFDRole:SetWidth(TukuiDB.Scale(6))
		LFDRole:SetPoint("TOPRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(-2))
		LFDRole:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\lfdicons.blp")
		self.LFDRole = LFDRole
		
		local MasterLooter = health:CreateTexture(nil, "OVERLAY")
		MasterLooter:SetHeight(TukuiDB.Scale(12))
		MasterLooter:SetWidth(TukuiDB.Scale(12))
		self.MasterLooter = MasterLooter
		self:RegisterEvent("PARTY_LEADER_CHANGED", TukuiDB.MLAnchorUpdate)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", TukuiDB.MLAnchorUpdate)
		
		if TukuiCF["unitframes"].aggro == true then
			table.insert(self.__elements, TukuiDB.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', TukuiDB.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', TukuiDB.UpdateThreat)
		end
		
		if TukuiCF["unitframes"].showsymbols == true then
			local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
			RaidIcon:SetHeight(TukuiDB.Scale(18))
			RaidIcon:SetWidth(TukuiDB.Scale(18))
			RaidIcon:SetPoint('CENTER', self, 'TOP')
			RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\raidicons.blp")
			self.RaidIcon = RaidIcon
		end
		
		local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		ReadyCheck:SetHeight(TukuiCF["raidframes"].fontsize)
		ReadyCheck:SetWidth(TukuiCF["raidframes"].fontsize)
		ReadyCheck:SetPoint('CENTER', self.Health, 'CENTER', 0, -4)
		self.ReadyCheck = ReadyCheck
		
		local debuffs = CreateFrame('Frame', nil, self)
		debuffs:SetPoint('TOP', self, 'BOTTOM', TukuiDB.Scale(-1), TukuiDB.Scale(-4))
		debuffs:SetHeight((party_width / 3)*.95)
		debuffs:SetWidth(party_width)
		debuffs.size = (party_width / 3) *.95
		debuffs.spacing = 2
		debuffs.initialAnchor = 'LEFT'
		debuffs.num = 3
		debuffs.PostCreateIcon = TukuiDB.PostCreateAura
		debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
		self.Debuffs = debuffs	
		
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
		
		-- Debuff Aura Filter
		self.Debuffs.CustomFilter = TukuiDB.AuraFilter
		
		--Heal Comm
		if TukuiCF["raidframes"].healcomm == true then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			if TukuiCF["raidframes"].gridhealthvertical == true then
				mhpb:SetOrientation("VERTICAL")
				mhpb:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP', 0, 0)
				mhpb:SetHeight(party_height)
			else
				mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
				mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			end
			mhpb:SetWidth(party_width)
			mhpb:SetStatusBarTexture(TukuiCF["media"].normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			if TukuiCF["raidframes"].gridhealthvertical == true then		
				ohpb:SetOrientation("VERTICAL")
				ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
				ohpb:SetHeight(party_height)
			else
				ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
				ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			end
			ohpb:SetWidth(party_width)
			ohpb:SetStatusBarTexture(TukuiCF["media"].normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		if TukuiCF["raidframes"].showrange == true then
			local range = {insideAlpha = 1, outsideAlpha = TukuiCF["raidframes"].raidalphaoor}
			self.Range = range
		end
		
		if TukuiCF["unitframes"].showsmooth == true then
			health.Smooth = true
			if self.Power then
				power.Smooth = true
			end
		end	
			
		if TukuiCF["auras"].raidunitbuffwatch == true then
			TukuiDB.createAuraWatch(self,unit)
		end
	end
	
	return self
end

oUF:RegisterStyle('TukuiHealParty', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiHealParty")
	local yOffset = 0
	if TukuiCF["castbar"].castermode == true and (HealElementsCharPos and HealElementsCharPos["PlayerCastBar"] ~= true) then
		yOffset = yOffset + 28
	end
	
	local party
	if TukuiCF["raidframes"].partypets == true then
		party = self:SpawnHeader("oUF_TukuiHealParty", nil, "custom [@raid6,exists] hide;show", 
			'oUF-initialConfigFunction', ([[
				local header = self:GetParent()
				local pet = header:GetChildren():GetName()
				self:SetWidth(%d)
				self:SetHeight(%d)
				for i = 1, 5 do
					if pet == "oUF_TukuiHealPartyUnitButton"..i.."Pet" then
						header:GetChildren():SetWidth(%d)
						header:GetChildren():SetHeight(%d)		
					end
				end
			]]):format(party_width, party_height, pet_width, pet_height),	
			"showRaid", true, 
			"showParty", true,
			"showSolo", false,
			"point", "LEFT",
			"columnAnchorPoint", "TOP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"showPlayer", TukuiCF["raidframes"].showplayerinparty,
			"xoffset", TukuiDB.Scale(6),
			'template', 'oUF_HealerParty'
		)	
	else
		party = self:SpawnHeader("oUF_TukuiHealParty", nil, "custom [@raid6,exists] hide;show", 
			'oUF-initialConfigFunction', ([[
				local header = self:GetParent()
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(party_width, party_height),	
			"showRaid", true, 
			"showParty", true,
			"showSolo", false,
			"point", "LEFT",
			"columnAnchorPoint", "TOP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"showPlayer", TukuiCF["raidframes"].showplayerinparty,
			"xoffset", TukuiDB.Scale(6)
		)		
	end
	party:SetPoint("BOTTOM", TukuiActionBarBackground, "TOP", 0, TukuiDB.Scale(32+yOffset))	
	
	local partyToggle = CreateFrame("Frame")
	partyToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	partyToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	partyToggle:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		if not InCombatLockdown() then
			if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
				oUF_TukuiHealParty:SetAttribute("showRaid", false)
				oUF_TukuiHealParty:SetAttribute("showParty", false)			
			else
				oUF_TukuiHealParty:SetAttribute("showParty", true)
				oUF_TukuiHealParty:SetAttribute("showRaid", true)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)