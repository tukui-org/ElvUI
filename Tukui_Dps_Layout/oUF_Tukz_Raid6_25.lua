if not TukuiCF["raidframes"].enable == true then return end

local raidframe_width
local raidframe_height
if TukuiCF["raidframes"].griddps ~= true then
	raidframe_width = TukuiDB.Scale(110)*TukuiCF["raidframes"].scale
	raidframe_height = TukuiDB.Scale(21)*TukuiCF["raidframes"].scale
else
	raidframe_width = (ChatLBackground:GetWidth() / 5) - (TukuiDB.Scale(7) - TukuiDB.Scale(1))
	raidframe_height = TukuiDB.Scale(37)
end



local function Shared(self, unit)
	self.colors = TukuiDB.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = TukuiDB.SpawnMenu
	
	-- an update script to all elements
	self:HookScript("OnShow", TukuiDB.updateAllElements)

	local health = CreateFrame('StatusBar', nil, self)
	if TukuiCF["raidframes"].griddps ~= true then
		health:SetHeight(raidframe_height*.75)
	else
		health:SetHeight(raidframe_height*.83)
	end
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(TukuiCF["media"].normTex)
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	
	self.Health.bg = health.bg
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	if TukuiCF["raidframes"].griddps ~= true then
		health.value:SetPoint("RIGHT", health, "RIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(1))
	else
		health.value:SetPoint("BOTTOM", health, "BOTTOM", 0, TukuiDB.Scale(4))
	end
	health.value:SetFont(TukuiCF["media"].uffont, (TukuiCF["raidframes"].fontsize*.83)*TukuiCF["raidframes"].scale, "THINOUTLINE")
	health.value:SetTextColor(1,1,1)
	health.value:SetShadowOffset(1, -1)
	self.Health.value = health.value		
	
	health.PostUpdate = TukuiDB.PostUpdateHealth
	health.frequentUpdates = true
	
	if TukuiCF.unitframes.classcolor ~= true then
		health.colorClass = false
		health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))
		health.bg:SetTexture(unpack(TukuiCF["unitframes"].healthbackdropcolor))
	else
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
	power:SetStatusBarTexture(TukuiCF["media"].normTex)
	self.Power = power
	if TukuiCF["raidframes"].hidenonmana == true then
		power.PostUpdate = TukuiDB.PostUpdatePower
	end
	
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
	power.bg:SetTexture(TukuiCF["media"].normTex)
	power.bg.multiplier = 0.3
	self.Power.bg = power.bg
	
	power.colorPower = true
	power.colorTapping = false
	power.colorDisconnected = true
	
	local name = health:CreateFontString(nil, "OVERLAY")
	if TukuiCF["raidframes"].griddps ~= true then
		name:SetPoint("LEFT", health, "LEFT", TukuiDB.Scale(2), TukuiDB.Scale(1))
		name:SetFont(TukuiCF["media"].uffont, TukuiCF["raidframes"].fontsize*TukuiCF["raidframes"].scale, "THINOUTLINE")
	else
		name:SetPoint("TOP", health, "TOP", 0, TukuiDB.Scale(-3))
		name:SetFont(TukuiCF["media"].uffont, (TukuiCF["raidframes"].fontsize-1)*TukuiCF["raidframes"].scale, "THINOUTLINE")	
	end
	name:SetShadowOffset(1, -1)
	name.frequentUpdates = 0.2
	self:Tag(name, "[Tukui:getnamecolor][Tukui:nameshort]")
	self.Name = name
	
	if TukuiCF["raidframes"].role == true then
		local LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		LFDRole:SetHeight(TukuiDB.Scale(6))
		LFDRole:SetWidth(TukuiDB.Scale(6))
		if TukuiCF["raidframes"].griddps ~= true then
			LFDRole:SetPoint("BOTTOMRIGHT", TukuiDB.Scale(-2), TukuiDB.Scale(-2))
		else
			LFDRole:SetPoint("TOP", self.Name, "BOTTOM", 0, TukuiDB.Scale(-1))
		end
		LFDRole:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\lfdicons.blp")
		self.LFDRole = LFDRole
	end
	
    if TukuiCF["unitframes"].aggro == true then
		table.insert(self.__elements, TukuiDB.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', TukuiDB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', TukuiDB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', TukuiDB.UpdateThreat)
	end
	
	if TukuiCF["unitframes"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:SetHeight(TukuiDB.Scale(15)*TukuiCF["raidframes"].scale)
		RaidIcon:SetWidth(TukuiDB.Scale(15)*TukuiCF["raidframes"].scale)
		if TukuiCF["raidframes"].griddps ~= true then
			RaidIcon:SetPoint('LEFT', self.Name, 'RIGHT')
		else
			RaidIcon:SetPoint('CENTER', self, 'TOP')
		end
		RaidIcon:SetTexture('Interface\\AddOns\\Tukui\\media\\textures\\raidicons.blp')
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(TukuiCF["raidframes"].fontsize)
	ReadyCheck:SetWidth(TukuiCF["raidframes"].fontsize)
	if TukuiCF["raidframes"].griddps ~= true then
		ReadyCheck:SetPoint('LEFT', self.Name, 'RIGHT', 4, 0)
	else	
		ReadyCheck:SetPoint('TOP', self.Name, 'BOTTOM', 0, -2)
	end
	self.ReadyCheck = ReadyCheck
	

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
	
    local debuffs = CreateFrame('Frame', nil, self)
	if TukuiCF["raidframes"].griddps ~= true then
		debuffs:SetPoint('LEFT', self, 'RIGHT', TukuiDB.Scale(6), 0)
		debuffs:SetHeight(raidframe_height)
		debuffs:SetWidth(raidframe_height*5)
		debuffs.size = (raidframe_height)
		debuffs.num = 5
		debuffs.spacing = 2
	else
		debuffs:SetPoint('BOTTOM', self, 'BOTTOM', 0, 1)
		debuffs:SetHeight(raidframe_height*0.6)
		debuffs:SetWidth(raidframe_height*0.6)
		debuffs.size = (raidframe_height*0.6)
		debuffs.num = 1
		debuffs.spacing = 0	
	end
    debuffs.initialAnchor = 'LEFT'
	debuffs.PostCreateIcon = TukuiDB.PostCreateAura
	debuffs.PostUpdateIcon = TukuiDB.PostUpdateAura
	self.Debuffs = debuffs
	
	-- Debuff Aura Filter
	self.Debuffs.CustomFilter = TukuiDB.AuraFilter
				
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
	
	if TukuiCF["raidframes"].hidenonmana == true then
		self:RegisterEvent("UNIT_DISPLAYPOWER", TukuiDB.CheckPower)	
	end

	
	return self
end

oUF:RegisterStyle('TukuiDPSR6R25', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiDPSR6R25")	
	local raid
	if TukuiCF["raidframes"].griddps ~= true then
		raid = self:SpawnHeader("oUF_TukuiDPSR6R25", nil, "custom [@raid6,noexists][@raid26,exists] hide;show",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', raidframe_width,
			'initial-height', raidframe_height,			
			"showRaid", true, 
			"showParty", true,
			"showSolo", false,
			"point", "BOTTOM",
			"showPlayer", TukuiCF["raidframes"].showplayerinparty,
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",	
			"yOffset", TukuiDB.Scale(6)
		)	
		raid:SetPoint("BOTTOMLEFT", ChatLBackground, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(40))
	else
		raid = self:SpawnHeader("oUF_TukuiDPSR6R25", nil, "custom [@raid6,noexists][@raid26,exists] hide;show",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', raidframe_width,
			'initial-height', raidframe_height,	
			"showRaid", true, 
			"showParty", true,
			"showPlayer", TukuiCF["raidframes"].showplayerinparty,
			"xoffset", TukuiDB.Scale(6),
			"yOffset", TukuiDB.Scale(-6),
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"columnSpacing", TukuiDB.Scale(6),
			"columnAnchorPoint", "TOP"		
		)	
		raid:SetPoint("BOTTOMLEFT", ChatLBackground, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(35))	
	end
	
	local function ChangeVisibility(visibility)
		if(visibility) then
			local type, list = string.split(' ', visibility, 2)
			if(list and type == 'custom') then
				RegisterAttributeDriver(oUF_TukuiDPSR6R25, 'state-visibility', list)
			end
		end	
	end
	
	local raidToggle = CreateFrame("Frame")
	raidToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	raidToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	raidToggle:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		if not InCombatLockdown() then
			if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
				ChangeVisibility("custom [group:party,nogroup:raid][group:raid] show;hide")
			else
				if TukuiCF["raidframes"].gridonly == true then
					ChangeVisibility("custom [@raid26,exists] hide;show")
				else
					ChangeVisibility("custom [@raid6,noexists][@raid26,exists] hide;show")
				end
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)