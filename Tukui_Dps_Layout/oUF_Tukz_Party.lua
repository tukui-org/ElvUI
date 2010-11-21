if not TukuiCF["raidframes"].enable == true or TukuiCF["raidframes"].gridonly == true then return end

local font2 = TukuiCF["media"].uffont
local font1 = TukuiCF["media"].font
local normTex = TukuiCF["media"].normTex

--Frame Size
local party_height = TukuiDB.Scale(28)
local party_width = TukuiDB.Scale(130)

local function Shared(self, unit)
	self.colors = TukuiDB.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = TukuiDB.SpawnMenu
	
	-- an update script to all elements
	self:HookScript("OnShow", TukuiDB.updateAllElements)
	
	self:SetBackdrop({bgFile = TukuiCF["media"].blank, insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)
	
	local health = CreateFrame('StatusBar', nil, self)
	health:SetHeight(party_height*.80)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(normTex)
	self.Health = health
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	
	self.Health.bg = health.bg
		
	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:SetPoint("RIGHT", health, -3, 1)
	health.value:SetFont(font2, TukuiCF["raidframes"].fontsize, "THINOUTLINE")
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
	power:SetStatusBarTexture(normTex)
	self.Power = power

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
    name:SetPoint("LEFT", health, 3, 1)
	name:SetFont(font2, TukuiCF["raidframes"].fontsize, "THINOUTLINE")
	name:SetShadowOffset(1, -1)
	name.frequentUpdates = 0.2
	self:Tag(name, "[Tukui:getnamecolor][Tukui:namelong]")
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
		RaidIcon:SetHeight(TukuiDB.Scale(15))
		RaidIcon:SetWidth(TukuiDB.Scale(15))
		RaidIcon:SetPoint('CENTER', self, 'TOP')
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\raidicons.blp")
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(TukuiCF["raidframes"].fontsize)
	ReadyCheck:SetWidth(TukuiCF["raidframes"].fontsize)
	ReadyCheck:SetPoint('LEFT', self.Name, 'RIGHT', 4, 0)
	self.ReadyCheck = ReadyCheck

	
    local debuffs = CreateFrame('Frame', nil, self)
    debuffs:SetPoint('LEFT', self, 'RIGHT', 5, 0)
    debuffs:SetHeight(party_height*.9)
    debuffs:SetWidth(200)
    debuffs.size = party_height*.9
    debuffs.spacing = 2
    debuffs.initialAnchor = 'LEFT'
	debuffs.num = 5
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
	
	if TukuiCF["raidframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = TukuiCF["raidframes"].raidalphaoor}
		self.Range = range
	end
	
	if TukuiCF["unitframes"].showsmooth == true then
		health.Smooth = true
		power.Smooth = true
	end
		
	if TukuiCF["auras"].raidunitbuffwatch == true then
		TukuiDB.createAuraWatch(self,unit)
    end

	self:Hide()
	return self
end

oUF:RegisterStyle('TukuiDPSParty', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiDPSParty")
	local party = self:SpawnHeader("oUF_TukuiDPSParty", nil, "custom [@raid6,exists] hide;show", 
		'oUF-initialConfigFunction', [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute('initial-width'))
			self:SetHeight(header:GetAttribute('initial-height'))
		]],
		'initial-width', party_width,
		'initial-height', party_height,			
		"showParty", true, 
		"showPlayer", TukuiCF["raidframes"].showplayerinparty, 
		"showRaid", true, 
		"showSolo", false,
		"yOffset", TukuiDB.Scale(-8)
	)
	party:SetPoint("BOTTOMLEFT", ChatLBackground, "TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(40))
	
	local partyToggle = CreateFrame("Frame")
	partyToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	partyToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	partyToggle:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		if not InCombatLockdown() then
			if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
				oUF_TukuiDPSParty:SetAttribute("showRaid", false)
				oUF_TukuiDPSParty:SetAttribute("showParty", false)			
			else
				oUF_TukuiDPSParty:SetAttribute("showParty", true)
				oUF_TukuiDPSParty:SetAttribute("showRaid", true)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)