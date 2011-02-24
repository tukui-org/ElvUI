local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
local _, ns = ...
local oUF = ElvUF or ns.oUF or oUF
assert(oUF, "ElvUI was unable to locate oUF.")

if not C["raidframes"].enable == true then return end
if IsAddOnLoaded("ElvUI_Dps_Layout") then return end

local raid_width = E.Scale((ElvuiActionBarBackground:GetWidth() / 5) - 7)*C["raidframes"].scale
local raid_height = E.Scale(24)*C["raidframes"].scale

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
	if C["raidframes"].gridhealthvertical == true then
		health:SetOrientation("VERTICAL")
	end
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(C["media"].normTex)
	
	self.Health.bg = health.bg
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:SetPoint("BOTTOM", health, "BOTTOM", 0, E.Scale(1))
	health.value:SetFont(C["media"].uffont, (C["raidframes"].fontsize*.83)*C["raidframes"].scale, "THINOUTLINE")
	health.value:SetTextColor(1,1,1)
	health.value:SetShadowOffset(1, -1)
	self.Health.value = health.value		
	
	health.PostUpdate = E.PostUpdateHealth
	health.frequentUpdates = 0.3
	
	-- Setup Colors
	if C["unitframes"].classcolor ~= true then
		health.colorTapping = false
		health.colorClass = false
		health:SetStatusBarColor(unpack(C["unitframes"].healthcolor))	
		self.Health.bg:SetTexture(unpack(C["unitframes"].healthbackdropcolor))
	else
		health.colorTapping = true	
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
    name:SetPoint("TOP", health, 0, 0)
	name:SetFont(C["media"].uffont, C["raidframes"].fontsize*C["raidframes"].scale, "THINOUTLINE")
	name:SetShadowOffset(1, -1)
	name.frequentUpdates = 0.3
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
		RaidIcon:SetPoint('CENTER', self, 'TOP', 0, 3)
		RaidIcon:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp')
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(C["raidframes"].fontsize)
	ReadyCheck:SetWidth(C["raidframes"].fontsize)
	ReadyCheck:SetPoint('CENTER', self.Health, 'CENTER', 0, -4)
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
		
	--Heal Comm
	if C["raidframes"].healcomm == true then
		local mhpb = CreateFrame('StatusBar', nil, self.Health)
		if C["raidframes"].gridhealthvertical == true then
			mhpb:SetOrientation("VERTICAL")
			mhpb:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP', 0, 0)
			mhpb:SetHeight(raid_height)
		else
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		end
		mhpb:SetWidth(raid_width)
		mhpb:SetStatusBarTexture(C["media"].normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
		if C["raidframes"].gridhealthvertical == true then		
			ohpb:SetOrientation("VERTICAL")
			ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
			ohpb:SetHeight(raid_height)
		else
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
		end
		ohpb:SetWidth(raid_width)
		ohpb:SetStatusBarTexture(C["media"].normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
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
	
oUF:RegisterStyle('ElvuiHealR26R40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiHealR26R40")	
	local yOffset = 0
	if C["castbar"].castermode == true and (HealElementsCharPos and HealElementsCharPos["PlayerCastBar"] ~= true) then
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
	raid:SetPoint("BOTTOM", ElvuiActionBarBackground, "TOP", 0, E.Scale(6+yOffset))	
	
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

