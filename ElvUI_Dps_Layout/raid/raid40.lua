local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
local _, ns = ...
local oUF = ElvUF or ns.oUF or oUF
assert(oUF, "ElvUI was unable to locate oUF.")

if not C["raidframes"].enable == true then return end

local raid_width
local raid_height

if C["raidframes"].griddps ~= true then
	raid_width = E.Scale(95)*C["raidframes"].scale
	raid_height = E.Scale(11)*C["raidframes"].scale
else
	raid_width = ((ChatLBackground2:GetWidth() / 5) - (E.Scale(7) - E.Scale(1)))*C["raidframes"].scale
	raid_height = E.Scale(30)*C["raidframes"].scale
end

local function Shared(self, unit)
	self.colors = E.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = E.SpawnMenu
	
	-- an update script to all elements
	self:HookScript("OnShow", E.updateAllElements)

	local health = CreateFrame('StatusBar', nil, self)
	health:SetHeight(raid_height)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(C["media"].normTex)
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(C["media"].normTex)
	
	self.Health.bg = health.bg
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	if C["raidframes"].griddps ~= true then
		health.value:SetPoint("RIGHT", health, "RIGHT", E.Scale(-3), E.Scale(1))
	else
		health.value:SetPoint("BOTTOM", health, "BOTTOM", 0, E.Scale(3))
	end
	health.value:SetFont(C["media"].uffont, (C["raidframes"].fontsize*.83)*C["raidframes"].scale, "THINOUTLINE")
	health.value:SetTextColor(1,1,1)
	health.value:SetShadowOffset(1, -1)
	self.Health.value = health.value		
	
	health.PostUpdate = E.PostUpdateHealth
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
	FrameBorder:SetPoint("TOPLEFT", self, "TOPLEFT", E.Scale(-2), E.Scale(2))
	FrameBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
	FrameBorder:SetTemplate("Default")
	FrameBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	FrameBorder:SetFrameLevel(2)
	self.FrameBorder = FrameBorder
		
	local name = health:CreateFontString(nil, "OVERLAY")
	if C["raidframes"].griddps ~= true then
		name:SetPoint("LEFT", health, "LEFT", E.Scale(2), E.Scale(1))
	else
		name:SetPoint("TOP", health, "TOP", 0, E.Scale(-3))
	end
	name:SetFont(C["media"].uffont, (C["raidframes"].fontsize-1)*C["raidframes"].scale, "THINOUTLINE")
	name:SetShadowOffset(1, -1)
	
	self:Tag(name, "[Elvui:getnamecolor][Elvui:nameshort]")
	self.Name = name
	
    if C["unitframes"].aggro == true then
		table.insert(self.__elements, E.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)
	end
	
	if C["unitframes"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:SetHeight(E.Scale(15)*C["raidframes"].scale)
		RaidIcon:SetWidth(E.Scale(15)*C["raidframes"].scale)
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
			
	if C["raidframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["raidframes"].raidalphaoor}
		self.Range = range
	end
	
	if C["unitframes"].showsmooth == true then
		health.Smooth = true
	end	
	
	if C["auras"].raidunitbuffwatch == true then
		E.createAuraWatch(self,unit)
    end
	
	-- execute an update on every raids unit if party or raid member changed
	-- should fix issues with names/symbols/etc not updating introduced with 4.0.3 patch
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", E.updateAllElements)
	self:RegisterEvent("RAID_ROSTER_UPDATE", E.updateAllElements)
		
	return self
end

oUF:RegisterStyle('ElvuiDPSR26R40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiDPSR26R40")	
	local raid
	if C["raidframes"].griddps ~= true then
		raid = self:SpawnHeader("ElvuiDPSR26R40", nil, "custom [@raid26,exists] show;hide",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', raid_width,
			'initial-height', raid_height,	
			"showSolo", false,
			"showRaid", true, 
			"showParty", true,
			"showPlayer", C["raidframes"].showplayerinparty,
			"xoffset", E.Scale(6),
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",	
			"yOffset", E.Scale(-6)
		)	
		raid:SetPoint("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", E.Scale(2), E.Scale(35))
	else
		raid = self:SpawnHeader("ElvuiDPSR26R40", nil, "custom [@raid26,exists] show;hide",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', raid_width,
			'initial-height', raid_height,	
			"showRaid", true, 
			"showParty", true,
			"showPlayer", C["raidframes"].showplayerinparty,
			"xoffset", E.Scale(6),
			"yOffset", E.Scale(-6),
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"maxColumns", 8,
			"unitsPerColumn", 5,
			"columnSpacing", E.Scale(6),
			"columnAnchorPoint", "TOP"		
		)		
		raid:SetPoint("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", E.Scale(2), E.Scale(35))
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
				ElvuiDPSR26R40:SetAttribute("showRaid", false)
				ElvuiDPSR26R40:SetAttribute("showParty", false)			
			else
				ElvuiDPSR26R40:SetAttribute("showParty", true)
				ElvuiDPSR26R40:SetAttribute("showRaid", true)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)