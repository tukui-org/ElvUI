local ElvDB = ElvDB
local ElvCF = ElvCF

if not ElvCF["raidframes"].enable == true then return end

local raidframe_width
local raidframe_height
if ElvCF["raidframes"].griddps ~= true then
	raidframe_width = ElvDB.Scale(110)*ElvCF["raidframes"].scale
	raidframe_height = ElvDB.Scale(21)*ElvCF["raidframes"].scale
else
	raidframe_width = ((ChatLBackground2:GetWidth() / 5) - (ElvDB.Scale(7) - ElvDB.Scale(1)))*ElvCF["raidframes"].scale
	raidframe_height = ElvDB.Scale(37)*ElvCF["raidframes"].scale
end



local function Shared(self, unit)
	self.colors = ElvDB.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = ElvDB.SpawnMenu
	
	-- an update script to all elements
	self:HookScript("OnShow", ElvDB.updateAllElements)

	local health = CreateFrame('StatusBar', nil, self)
	if ElvCF["raidframes"].griddps ~= true then
		health:SetHeight(raidframe_height*.75)
	else
		health:SetHeight(raidframe_height*.83)
	end
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(ElvCF["media"].normTex)
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	
	self.Health.bg = health.bg
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	if ElvCF["raidframes"].griddps ~= true then
		health.value:SetPoint("RIGHT", health, "RIGHT", ElvDB.Scale(-2), ElvDB.Scale(1))
	else
		health.value:SetPoint("BOTTOM", health, "BOTTOM", 0, ElvDB.Scale(4))
	end
	health.value:SetFont(ElvCF["media"].uffont, (ElvCF["raidframes"].fontsize*.83)*ElvCF["raidframes"].scale, "THINOUTLINE")
	health.value:SetTextColor(1,1,1)
	health.value:SetShadowOffset(1, -1)
	self.Health.value = health.value		
	
	health.PostUpdate = ElvDB.PostUpdateHealth
	health.frequentUpdates = true
	
	if ElvCF.unitframes.classcolor ~= true then
		health.colorClass = false
		health:SetStatusBarColor(unpack(ElvCF["unitframes"].healthcolor))
		health.bg:SetTexture(unpack(ElvCF["unitframes"].healthbackdropcolor))
	else
		health.colorClass = true
		health.colorReaction = true	
		health.bg.multiplier = 0.3		
	end
	health.colorDisconnected = false	
	
	-- border for all frames
	local FrameBorder = CreateFrame("Frame", nil, self)
	FrameBorder:SetPoint("TOPLEFT", self, "TOPLEFT", ElvDB.Scale(-2), ElvDB.Scale(2))
	FrameBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", ElvDB.Scale(2), ElvDB.Scale(-2))
	ElvDB.SetTemplate(FrameBorder)
	FrameBorder:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))
	FrameBorder:SetFrameLevel(2)
	self.FrameBorder = FrameBorder
	
	-- power
	local power = CreateFrame('StatusBar', nil, self)
	power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, ElvDB.Scale(-1)+(-ElvDB.mult*2))
	power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, ElvDB.Scale(-1)+(-ElvDB.mult*2))
	power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
	power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	power:SetStatusBarTexture(ElvCF["media"].normTex)
	self.Power = power
	if ElvCF["raidframes"].hidenonmana == true then
		power.PostUpdate = ElvDB.PostUpdatePower
	end
	
	-- border between health and power
	self.HealthBorder = CreateFrame("Frame", nil, power)
	self.HealthBorder:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -ElvDB.mult)
	self.HealthBorder:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -ElvDB.mult)
	self.HealthBorder:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, ElvDB.mult)
	self.HealthBorder:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, ElvDB.mult)
	ElvDB.SetTemplate(self.HealthBorder)
	self.HealthBorder:SetBackdropBorderColor(unpack(ElvCF["media"].altbordercolor))	
	
	power.frequentUpdates = true

	power.bg = self.Power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(ElvCF["media"].normTex)
	power.bg.multiplier = 0.3
	self.Power.bg = power.bg
	
	power.colorPower = true
	power.colorTapping = false
	power.colorDisconnected = true
	
	local name = health:CreateFontString(nil, "OVERLAY")
	if ElvCF["raidframes"].griddps ~= true then
		name:SetPoint("LEFT", health, "LEFT", ElvDB.Scale(2), ElvDB.Scale(1))
		name:SetFont(ElvCF["media"].uffont, ElvCF["raidframes"].fontsize*ElvCF["raidframes"].scale, "THINOUTLINE")
	else
		name:SetPoint("TOP", health, "TOP", 0, ElvDB.Scale(-3))
		name:SetFont(ElvCF["media"].uffont, (ElvCF["raidframes"].fontsize-1)*ElvCF["raidframes"].scale, "THINOUTLINE")	
	end
	name:SetShadowOffset(1, -1)
	
	self:Tag(name, "[Elvui:getnamecolor][Elvui:nameshort]")
	self.Name = name
	
	if ElvCF["raidframes"].role == true then
		local LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		LFDRole:SetHeight(ElvDB.Scale(6))
		LFDRole:SetWidth(ElvDB.Scale(6))
		if ElvCF["raidframes"].griddps ~= true then
			LFDRole:SetPoint("BOTTOMRIGHT", ElvDB.Scale(-2), ElvDB.Scale(-2))
		else
			LFDRole:SetPoint("TOP", self.Name, "BOTTOM", 0, ElvDB.Scale(-1))
		end
		LFDRole:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\lfdicons.blp")
		self.LFDRole = LFDRole
	end
	
    if ElvCF["unitframes"].aggro == true then
		table.insert(self.__elements, ElvDB.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', ElvDB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ElvDB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', ElvDB.UpdateThreat)
	end
	
	if ElvCF["unitframes"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:SetHeight(ElvDB.Scale(15)*ElvCF["raidframes"].scale)
		RaidIcon:SetWidth(ElvDB.Scale(15)*ElvCF["raidframes"].scale)
		if ElvCF["raidframes"].griddps ~= true then
			RaidIcon:SetPoint('LEFT', self.Name, 'RIGHT')
		else
			RaidIcon:SetPoint('CENTER', self, 'TOP')
		end
		RaidIcon:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp')
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(ElvCF["raidframes"].fontsize)
	ReadyCheck:SetWidth(ElvCF["raidframes"].fontsize)
	if ElvCF["raidframes"].griddps ~= true then
		ReadyCheck:SetPoint('LEFT', self.Name, 'RIGHT', 4, 0)
	else	
		ReadyCheck:SetPoint('TOP', self.Name, 'BOTTOM', 0, -2)
	end
	self.ReadyCheck = ReadyCheck
	

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
	
    local debuffs = CreateFrame('Frame', nil, self)
	if ElvCF["raidframes"].griddps ~= true then
		debuffs:SetPoint('LEFT', self, 'RIGHT', ElvDB.Scale(6), 0)
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
	debuffs.PostCreateIcon = ElvDB.PostCreateAura
	debuffs.PostUpdateIcon = ElvDB.PostUpdateAura
	self.Debuffs = debuffs
	
	-- Debuff Aura Filter
	self.Debuffs.CustomFilter = ElvDB.AuraFilter
				
	if ElvCF["raidframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = ElvCF["raidframes"].raidalphaoor}
		self.Range = range
	end
	
	if ElvCF["unitframes"].showsmooth == true then
		health.Smooth = true
		if self.Power then
			power.Smooth = true
		end
	end	
	
	if ElvCF["auras"].raidunitbuffwatch == true then
		ElvDB.createAuraWatch(self,unit)
    end
	
	if ElvCF["raidframes"].hidenonmana == true then
		self:RegisterEvent("UNIT_DISPLAYPOWER", ElvDB.CheckPower)	
	end

	-- execute an update on every raids unit if party or raid member changed
	-- should fix issues with names/symbols/etc not updating introduced with 4.0.3 patch
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", ElvDB.updateAllElements)
	self:RegisterEvent("RAID_ROSTER_UPDATE", ElvDB.updateAllElements)
	
	return self
end

oUF:RegisterStyle('ElvuiDPSR6R25', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiDPSR6R25")	
	local raid
	if ElvCF["raidframes"].griddps ~= true then
		raid = self:SpawnHeader("ElvuiDPSR6R25", nil, "custom [@raid6,noexists][@raid26,exists] hide;show",
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
			"showPlayer", ElvCF["raidframes"].showplayerinparty,
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",	
			"yOffset", ElvDB.Scale(6)
		)	
		raid:SetPoint("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", ElvDB.Scale(2), ElvDB.Scale(40))
	else
		raid = self:SpawnHeader("ElvuiDPSR6R25", nil, "custom [@raid6,noexists][@raid26,exists] hide;show",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', raidframe_width,
			'initial-height', raidframe_height,	
			"showRaid", true, 
			"showParty", true,
			"showPlayer", ElvCF["raidframes"].showplayerinparty,
			"xoffset", ElvDB.Scale(6),
			"yOffset", ElvDB.Scale(-6),
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"columnSpacing", ElvDB.Scale(6),
			"columnAnchorPoint", "TOP"		
		)	
		raid:SetPoint("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", ElvDB.Scale(2), ElvDB.Scale(35))	
	end
	
	local function ChangeVisibility(visibility)
		if(visibility) then
			local type, list = string.split(' ', visibility, 2)
			if(list and type == 'custom') then
				RegisterAttributeDriver(ElvuiDPSR6R25, 'state-visibility', list)
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
				if ElvCF["raidframes"].gridonly == true then
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