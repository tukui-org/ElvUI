if not TukuiDB["unitframes"].enable == true then return end

local fontlol = TukuiDB["media"].uffont

local colors = setmetatable({
	power = setmetatable({
		['MANA'] = {0, 144/255, 1},
	}, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

local function menu(self)
	if(self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

local function UpdateThreat(self, event, unit)
	if (self.unit ~= unit) then
		return
	end
	local threat = UnitThreatSituation(self.unit)
	if (threat == 3) then
		self.Health.name:SetTextColor(1,0.1,0.1)
	else
		self.Health.name:SetTextColor(1,1,1)
	end 
end

local function CreateStyle(self, unit)
	self.menu = menu
	self.colors = colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self:SetAttribute('*type2', 'menu')
	self:SetAttribute('initial-height', TukuiDB:Scale(20))
	self:SetAttribute('initial-width', TukuiDB:Scale(150))

	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	self.Health = CreateFrame('StatusBar', nil, self)
    self.Health:SetPoint("TOPLEFT")
    self.Health:SetPoint("TOPRIGHT")
    self.Health:SetHeight(TukuiDB:Scale(16))
	self.Health:SetStatusBarTexture(TukuiDB["media"].normTex)

	self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	self.Health.bg:SetTexture(0.3, 0.3, 0.3)
	self.Health.bg.multiplier = (0.3)
	
	if TukuiDB["unitframes"].classcolor == true then
		self.Health.colorDisconnected = true
		self.Health.colorSmooth = true
		self.Health.colorReaction = true
		self.Health.colorClassPet = false    
		self.Health.colorClass = true
		self.Health.bg.multiplier = 0.3
	else
		self.Health.colorTapping = false
		self.Health.colorDisconnected = false
		self.Health.colorClass = false
		self.Health.colorSmooth = false
		self.Health:SetStatusBarColor(.3, .3, .3, 1)
		self.Health.bg:SetVertexColor(.1, .1, .1, 1)
	end
	
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetHeight(TukuiDB:Scale(3))
    self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -TukuiDB.mult)
    self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
    self.Power:SetStatusBarTexture(TukuiDB["media"].normTex)

    self.Power.colorClass = true	

    self.Power.frequentUpdates = true
    self.Power.Smooth = true

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
    self.Power.bg:SetAlpha(1)
	self.Power.bg.multiplier = 0.1
	
	if TukuiDB["unitframes"].classcolor == true then
		self.Power.colorPower = true
		self.Power.bg.multiplier = 0.4
	end
	
	local health = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallRight')
	health:SetPoint('CENTER', 0, 1)
	self:Tag(health, '[dead][offline( )][afk( )]')

	self.Health.name = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
	self.Health.name:SetFont(fontlol, 13, "THINOUTLINE")
	self.Health.name:SetPoint('LEFT', self, 'RIGHT', 5, 1)
	self:Tag(self.Health.name, '[NameMedium][leader( )]')
	
	if TukuiDB["unitframes"].showsymbols == true then
		self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetHeight(TukuiDB:Scale(14*TukuiDB.raidscale))
		self.RaidIcon:SetWidth(TukuiDB:Scale(14*TukuiDB.raidscale))
		self.RaidIcon:SetPoint('CENTER', self, 'CENTER')
		self.RaidIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')	
	end
	
	if TukuiDB["unitframes"].aggro == true then
      table.insert(self.__elements, UpdateThreat)
      self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateThreat)
      self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UpdateThreat)
      self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UpdateThreat)
    end
	
	self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
    self.LFDRole:SetHeight(TukuiDB:Scale(6))
    self.LFDRole:SetWidth(TukuiDB:Scale(6))
	self.LFDRole:SetPoint("TOPLEFT", TukuiDB:Scale(2), TukuiDB:Scale(-2))

	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	
	self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	self.ReadyCheck:SetHeight(TukuiDB:Scale(12))
	self.ReadyCheck:SetWidth(TukuiDB:Scale(12))
	self.ReadyCheck:SetPoint('CENTER')

	self.outsideRangeAlpha = TukuiDB["unitframes"].raidalphaoor
	self.inRangeAlpha = 1.0
	if TukuiDB["unitframes"].showrange == true then
		self.Range = true
	else
		self.Range = false
	end
	if TukuiDB["unitframes"].showsmooth == true then
		self.Health.Smooth = true
	else
		self.Health.smooth = false
	end
end

oUF:RegisterStyle('Party', CreateStyle)
oUF:SetActiveStyle('Party')

local party = oUF:Spawn("header", "oUF_Group")
party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -399*TukuiDB.raidscale)
party:SetAttribute("showParty", true)
party:SetAttribute("showPlayer", TukuiDB["unitframes"].showplayerinparty)
party:SetAttribute("yOffset", -3)

local partyToggle = CreateFrame("Frame")
partyToggle:RegisterEvent("PLAYER_LOGIN")
partyToggle:RegisterEvent("RAID_ROSTER_UPDATE")
partyToggle:RegisterEvent("PARTY_LEADER_CHANGED")
partyToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
partyToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		local numraid = GetNumRaidMembers()
		if numraid > 0 and (numraid > 5 or numraid ~= GetNumPartyMembers() + 1) then
			party:Hide()
			
		else
			party:Show()
			
		end
	end
end)











