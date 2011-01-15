local ElvDB = ElvDB
local ElvCF = ElvCF

if not ElvCF["raidframes"].enable == true then return end
if IsAddOnLoaded("ElvUI_Dps_Layout") then return end

local raid_width = ElvDB.Scale((ElvuiActionBarBackground:GetWidth() / 5) - 7)*ElvCF["raidframes"].scale
local raid_height = ElvDB.Scale(24)*ElvCF["raidframes"].scale

local function Shared(self, unit)
	self.colors = ElvDB.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = ElvDB.SpawnMenu
	
	-- an update script to all elements
	self:HookScript("OnShow", ElvDB.updateAllElements)

	local health = CreateFrame('StatusBar', nil, self)
	health:SetHeight(raid_height)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(ElvCF["media"].normTex)
	if ElvCF["raidframes"].gridhealthvertical == true then
		health:SetOrientation("VERTICAL")
	end
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(ElvCF["media"].normTex)
	
	self.Health.bg = health.bg
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:SetPoint("BOTTOM", health, "BOTTOM", 0, ElvDB.Scale(1))
	health.value:SetFont(ElvCF["media"].uffont, (ElvCF["raidframes"].fontsize*.83)*ElvCF["raidframes"].scale, "THINOUTLINE")
	health.value:SetTextColor(1,1,1)
	health.value:SetShadowOffset(1, -1)
	self.Health.value = health.value		
	
	health.PostUpdate = ElvDB.PostUpdateHealth
	health.frequentUpdates = true
	
	-- Setup Colors
	if ElvCF["unitframes"].classcolor ~= true then
		health.colorTapping = false
		health.colorClass = false
		health:SetStatusBarColor(unpack(ElvCF["unitframes"].healthcolor))	
		self.Health.bg:SetTexture(unpack(ElvCF["unitframes"].healthbackdropcolor))
	else
		health.colorTapping = true	
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

	local name = health:CreateFontString(nil, "OVERLAY")
    name:SetPoint("TOP", health, 0, 0)
	name:SetFont(ElvCF["media"].uffont, ElvCF["raidframes"].fontsize*ElvCF["raidframes"].scale, "THINOUTLINE")
	name:SetShadowOffset(1, -1)
	
	self:Tag(name, "[Elvui:getnamecolor][Elvui:nameshort]")
	self.Name = name
	
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
		RaidIcon:SetPoint('CENTER', self, 'TOP', 0, 3)
		RaidIcon:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp')
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(ElvCF["raidframes"].fontsize)
	ReadyCheck:SetWidth(ElvCF["raidframes"].fontsize)
	ReadyCheck:SetPoint('CENTER', self.Health, 'CENTER', 0, -4)
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
		
	--Heal Comm
	if ElvCF["raidframes"].healcomm == true then
		local mhpb = CreateFrame('StatusBar', nil, self.Health)
		if ElvCF["raidframes"].gridhealthvertical == true then
			mhpb:SetOrientation("VERTICAL")
			mhpb:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP', 0, 0)
			mhpb:SetHeight(raid_height)
		else
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		end
		mhpb:SetWidth(raid_width)
		mhpb:SetStatusBarTexture(ElvCF["media"].normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
		if ElvCF["raidframes"].gridhealthvertical == true then		
			ohpb:SetOrientation("VERTICAL")
			ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
			ohpb:SetHeight(raid_height)
		else
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		end
		ohpb:SetWidth(raid_width)
		ohpb:SetStatusBarTexture(ElvCF["media"].normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
	end
				
	if ElvCF["raidframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = ElvCF["raidframes"].raidalphaoor}
		self.Range = range
	end
	
	if ElvCF["unitframes"].showsmooth == true then
		health.Smooth = true
	end	
	
	if ElvCF["auras"].raidunitbuffwatch == true then
		ElvDB.createAuraWatch(self,unit)
    end
		
	-- execute an update on every raids unit if party or raid member changed
	-- should fix issues with names/symbols/etc not updating introduced with 4.0.3 patch
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", ElvDB.updateAllElements)
	self:RegisterEvent("RAID_ROSTER_UPDATE", ElvDB.updateAllElements)
	
	return self
end
	
oUF:RegisterStyle('ElvuiHealR26R40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiHealR26R40")	
	local yOffset = 0
	if ElvCF["castbar"].castermode == true and (HealElementsCharPos and HealElementsCharPos["PlayerCastBar"] ~= true) then
		yOffset = yOffset + 28
	end
	local raid = self:SpawnHeader("ElvuiHealR26R40", nil, "custom [@raid26,exists] show;hide",
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
		"xoffset", ElvDB.Scale(6),
		"yOffset", ElvDB.Scale(-6),
		"point", "LEFT",
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"maxColumns", 8,
		"unitsPerColumn", 5,
		"columnSpacing", ElvDB.Scale(6),
		"columnAnchorPoint", "TOP"		
	)
	raid:SetPoint("BOTTOM", ElvuiActionBarBackground, "TOP", 0, ElvDB.Scale(6+yOffset))	
	
	local raidToggle = CreateFrame("Frame")
	raidToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	raidToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	raidToggle:SetScript("OnEvent", function(self)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		if not InCombatLockdown() then
			if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
				ElvuiHealR26R40:SetAttribute("showRaid", false)
				ElvuiHealR26R40:SetAttribute("showParty", false)			
			else
				ElvuiHealR26R40:SetAttribute("showParty", true)
				ElvuiHealR26R40:SetAttribute("showRaid", true)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)

