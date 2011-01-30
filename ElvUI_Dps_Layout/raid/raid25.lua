local DB, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales


if not C["raidframes"].enable == true then return end

local raidframe_width
local raidframe_height
if C["raidframes"].griddps ~= true then
	raidframe_width = DB.Scale(110)*C["raidframes"].scale
	raidframe_height = DB.Scale(21)*C["raidframes"].scale
else
	raidframe_width = ((ChatLBackground2:GetWidth() / 5) - (DB.Scale(7) - DB.Scale(1)))*C["raidframes"].scale
	raidframe_height = DB.Scale(37)*C["raidframes"].scale
end



local function Shared(self, unit)
	self.colors = DB.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = DB.SpawnMenu
	
	-- an update script to all elements
	self:HookScript("OnShow", DB.updateAllElements)

	local health = CreateFrame('StatusBar', nil, self)
	if C["raidframes"].griddps ~= true then
		health:SetHeight(raidframe_height*.75)
	else
		health:SetHeight(raidframe_height*.83)
	end
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(C["media"].normTex)
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	
	self.Health.bg = health.bg
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	if C["raidframes"].griddps ~= true then
		health.value:SetPoint("RIGHT", health, "RIGHT", DB.Scale(-2), DB.Scale(1))
	else
		health.value:SetPoint("BOTTOM", health, "BOTTOM", 0, DB.Scale(4))
	end
	health.value:SetFont(C["media"].uffont, (C["raidframes"].fontsize*.83)*C["raidframes"].scale, "THINOUTLINE")
	health.value:SetTextColor(1,1,1)
	health.value:SetShadowOffset(1, -1)
	self.Health.value = health.value		
	
	health.PostUpdate = DB.PostUpdateHealth
	health.frequentUpdates = true
	
	if C.unitframes.classcolor ~= true then
		health.colorClass = false
		health:SetStatusBarColor(unpack(C["unitframes"].healthcolor))
		health.bg:SetTexture(unpack(C["unitframes"].healthbackdropcolor))
	else
		health.colorClass = true
		health.colorReaction = true	
		health.bg.multiplier = 0.3		
	end
	health.colorDisconnected = false	
	
	-- border for all frames
	local FrameBorder = CreateFrame("Frame", nil, self)
	FrameBorder:SetPoint("TOPLEFT", self, "TOPLEFT", DB.Scale(-2), DB.Scale(2))
	FrameBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", DB.Scale(2), DB.Scale(-2))
	DB.SetTemplate(FrameBorder)
	FrameBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	FrameBorder:SetFrameLevel(2)
	self.FrameBorder = FrameBorder
	
	-- power
	local power = CreateFrame('StatusBar', nil, self)
	power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, DB.Scale(-1)+(-DB.mult*2))
	power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, DB.Scale(-1)+(-DB.mult*2))
	power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
	power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	power:SetStatusBarTexture(C["media"].normTex)
	self.Power = power
	if C["raidframes"].hidenonmana == true then
		power.PostUpdate = DB.PostUpdatePower
	end
	
	-- border between health and power
	self.HealthBorder = CreateFrame("Frame", nil, power)
	self.HealthBorder:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -DB.mult)
	self.HealthBorder:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -DB.mult)
	self.HealthBorder:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, DB.mult)
	self.HealthBorder:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, DB.mult)
	DB.SetTemplate(self.HealthBorder)
	self.HealthBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))	
	
	power.frequentUpdates = true

	power.bg = self.Power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(C["media"].normTex)
	power.bg.multiplier = 0.3
	self.Power.bg = power.bg
	
	power.colorPower = true
	power.colorTapping = false
	power.colorDisconnected = true
	
	local name = health:CreateFontString(nil, "OVERLAY")
	if C["raidframes"].griddps ~= true then
		name:SetPoint("LEFT", health, "LEFT", DB.Scale(2), DB.Scale(1))
		name:SetFont(C["media"].uffont, C["raidframes"].fontsize*C["raidframes"].scale, "THINOUTLINE")
	else
		name:SetPoint("TOP", health, "TOP", 0, DB.Scale(-3))
		name:SetFont(C["media"].uffont, (C["raidframes"].fontsize-1)*C["raidframes"].scale, "THINOUTLINE")	
	end
	name:SetShadowOffset(1, -1)
	
	self:Tag(name, "[Elvui:getnamecolor][Elvui:nameshort]")
	self.Name = name
	
	if C["raidframes"].role == true then
		local LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
		LFDRole:SetHeight(DB.Scale(6))
		LFDRole:SetWidth(DB.Scale(6))
		if C["raidframes"].griddps ~= true then
			LFDRole:SetPoint("BOTTOMRIGHT", DB.Scale(-2), DB.Scale(-2))
		else
			LFDRole:SetPoint("TOP", self.Name, "BOTTOM", 0, DB.Scale(-1))
		end
		LFDRole:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\lfdicons.blp")
		self.LFDRole = LFDRole
	end
	
    if C["unitframes"].aggro == true then
		table.insert(self.__elements, DB.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', DB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', DB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', DB.UpdateThreat)
	end
	
	if C["unitframes"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:SetHeight(DB.Scale(15)*C["raidframes"].scale)
		RaidIcon:SetWidth(DB.Scale(15)*C["raidframes"].scale)
		if C["raidframes"].griddps ~= true then
			RaidIcon:SetPoint('LEFT', self.Name, 'RIGHT')
		else
			RaidIcon:SetPoint('CENTER', self, 'TOP')
		end
		RaidIcon:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp')
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(C["raidframes"].fontsize)
	ReadyCheck:SetWidth(C["raidframes"].fontsize)
	if C["raidframes"].griddps ~= true then
		ReadyCheck:SetPoint('LEFT', self.Name, 'RIGHT', 4, 0)
	else	
		ReadyCheck:SetPoint('TOP', self.Name, 'BOTTOM', 0, -2)
	end
	self.ReadyCheck = ReadyCheck
	

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
	
    local debuffs = CreateFrame('Frame', nil, self)
	if C["raidframes"].griddps ~= true then
		debuffs:SetPoint('LEFT', self, 'RIGHT', DB.Scale(6), 0)
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
	debuffs.PostCreateIcon = DB.PostCreateAura
	debuffs.PostUpdateIcon = DB.PostUpdateAura
	self.Debuffs = debuffs
	
	-- Debuff Aura Filter
	self.Debuffs.CustomFilter = DB.AuraFilter
				
	if C["raidframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["raidframes"].raidalphaoor}
		self.Range = range
	end
	
	if C["unitframes"].showsmooth == true then
		health.Smooth = true
		if self.Power then
			power.Smooth = true
		end
	end	
	
	if C["auras"].raidunitbuffwatch == true then
		DB.createAuraWatch(self,unit)
    end
	
	if C["raidframes"].hidenonmana == true then
		self:RegisterEvent("UNIT_DISPLAYPOWER", DB.CheckPower)	
	end

	-- execute an update on every raids unit if party or raid member changed
	-- should fix issues with names/symbols/etc not updating introduced with 4.0.3 patch
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", DB.updateAllElements)
	self:RegisterEvent("RAID_ROSTER_UPDATE", DB.updateAllElements)
	
	return self
end

oUF:RegisterStyle('ElvuiDPSR6R25', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiDPSR6R25")	
	local raid
	if C["raidframes"].griddps ~= true then
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
			"showPlayer", C["raidframes"].showplayerinparty,
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",	
			"yOffset", DB.Scale(6)
		)	
		raid:SetPoint("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", DB.Scale(2), DB.Scale(40))
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
			"showPlayer", C["raidframes"].showplayerinparty,
			"xoffset", DB.Scale(6),
			"yOffset", DB.Scale(-6),
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"columnSpacing", DB.Scale(6),
			"columnAnchorPoint", "TOP"		
		)	
		raid:SetPoint("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", DB.Scale(2), DB.Scale(35))	
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
				if C["raidframes"].gridonly == true then
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