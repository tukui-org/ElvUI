if not TukuiCF["raidframes"].enable == true then return end

local raid_width = TukuiDB.Scale((TukuiActionBarBackground:GetWidth() / 5) - 7)*TukuiCF["raidframes"].scale
local raid_height = TukuiDB.Scale(24)*TukuiCF["raidframes"].scale

local function Shared(self, unit)
	self.colors = TukuiDB.oUF_colors
	self:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = TukuiDB.SpawnMenu
	
	-- an update script to all elements
	self:HookScript("OnShow", TukuiDB.updateAllElements)

	local health = CreateFrame('StatusBar', nil, self)
	health:SetHeight(raid_height)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(TukuiCF["media"].normTex)
	if TukuiCF["raidframes"].gridhealthvertical == true then
		health:SetOrientation("VERTICAL")
	end
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(TukuiCF["media"].normTex)
	health.bg:SetTexture(0.1, 0.1, 0.1)
	
	self.Health.bg = health.bg
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:SetPoint("BOTTOM", health, "BOTTOM", 0, TukuiDB.Scale(1))
	health.value:SetFont(TukuiCF["media"].uffont, (TukuiCF["raidframes"].fontsize*.83)*TukuiCF["raidframes"].scale, "THINOUTLINE")
	health.value:SetTextColor(1,1,1)
	health.value:SetShadowOffset(1, -1)
	self.Health.value = health.value		
	
	health.PostUpdate = TukuiDB.PostUpdateHealthRaid
	health.frequentUpdates = true
	
	if TukuiCF["unitframes"].classcolor ~= true then
		health.colorTapping = false
		health.colorClass = false
		health:SetStatusBarColor(unpack(TukuiCF["unitframes"].healthcolor))	
	else
		health.colorTapping = true	
		health.colorClass = true
		health.colorReaction = true			
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
    name:SetPoint("TOP", health, 0, 0)
	name:SetFont(TukuiCF["media"].uffont, TukuiCF["raidframes"].fontsize*TukuiCF["raidframes"].scale, "THINOUTLINE")
	name:SetShadowOffset(1, -1)
	self:Tag(name, "[Tukui:getnamecolor][Tukui:nameshort]")
	self.Name = name
	
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
		RaidIcon:SetPoint('CENTER', self, 'TOP', 0, 3)
		RaidIcon:SetTexture('Interface\\AddOns\\Tukui\\media\\textures\\raidicons.blp')
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(TukuiCF["raidframes"].fontsize)
	ReadyCheck:SetWidth(TukuiCF["raidframes"].fontsize)
	ReadyCheck:SetPoint('CENTER', self.Health, 'CENTER', 0, -4)
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
		
	--Heal Comm
	if TukuiCF["raidframes"].healcomm == true then
		local mhpb = CreateFrame('StatusBar', nil, self.Health)
		if TukuiCF["raidframes"].gridhealthvertical == true then
			mhpb:SetOrientation("VERTICAL")
			mhpb:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP', 0, 0)
			mhpb:SetHeight(raid_height)
		else
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		end
		mhpb:SetWidth(raid_width)
		mhpb:SetStatusBarTexture(TukuiCF["media"].normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
		if TukuiCF["raidframes"].gridhealthvertical == true then		
			ohpb:SetOrientation("VERTICAL")
			ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
			ohpb:SetHeight(raid_height)
		else
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		end
		ohpb:SetWidth(raid_width)
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
	end	
	
	if TukuiCF["auras"].raidunitbuffwatch == true then
		TukuiDB.createAuraWatch(self,unit)
    end
	
	self:RegisterEvent("UNIT_PET", TukuiDB.updateAllElements)
	
	return self
end
	
oUF:RegisterStyle('TukuiHealR26R40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiHealR26R40")	
	local yOffset = 0
	if TukuiCF["castbar"].castermode == true then
		yOffset = yOffset + 28
	end
	local raid = self:SpawnHeader("oUF_TukuiHealR26R40", nil, "custom [@raid26,exists] show;hide",
		'oUF-initialConfigFunction', [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute('initial-width'))
			self:SetHeight(header:GetAttribute('initial-height'))
		]],
		'initial-width', raid_width,
		'initial-height', raid_height,	
		"showRaid", true, 
		"showParty", true,
		"showSolo", false,
		"xoffset", TukuiDB.Scale(6),
		"yOffset", TukuiDB.Scale(-6),
		"point", "LEFT",
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"maxColumns", 8,
		"unitsPerColumn", 5,
		"columnSpacing", TukuiDB.Scale(6),
		"columnAnchorPoint", "TOP"		
	)
	raid:SetPoint("BOTTOM", TukuiActionBarBackground, "TOP", 0, TukuiDB.Scale(6+yOffset))	
	
	local raidToggle = CreateFrame("Frame")
	raidToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	raidToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	raidToggle:SetScript("OnEvent", function(self)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
			oUF_TukuiHealR26R40:SetAttribute("showRaid", false)
			oUF_TukuiHealR26R40:SetAttribute("showParty", false)			
		else
			oUF_TukuiHealR26R40:SetAttribute("showParty", true)
			oUF_TukuiHealR26R40:SetAttribute("showRaid", true)
		end
	end)
end)

