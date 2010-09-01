if not TukuiCF["unitframes"].enable == true then return end

local font2 = TukuiCF["media"].uffont
local font1 = TukuiCF["media"].font

local function Shared(self, unit)
	self.colors = TukuiDB.oUF_colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = TukuiDB.SpawnMenu
	self:SetAttribute('type2', 'menu')
	
	self:SetAttribute('initial-height', TukuiDB.Scale(16*TukuiDB.raidscale))
	self:SetAttribute('initial-width', TukuiDB.Scale(120*TukuiDB.raidscale))
	
	self:SetBackdrop({bgFile = TukuiCF["media"].blank, insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)
	
	local health = CreateFrame('StatusBar', nil, self)
	health:SetHeight(TukuiDB.Scale(12))
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:SetStatusBarTexture(TukuiCF["media"].normTex)
	self.Health = health

	health.bg = self.Health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(self.Health)
	health.bg:SetTexture(TukuiCF["media"].blank)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	health.bg.multiplier = (0.3)
	self.Health.bg = health.bg
	
	health.frequentUpdates = true
	
	if TukuiCF.unitframes.unicolor == true then
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(.3, .3, .3, 1)
		health.bg:SetVertexColor(.1, .1, .1, 1)		
	else
		health.colorDisconnected = true	
		health.colorClass = true
		health.colorReaction = true			
	end
	
	local power = CreateFrame("StatusBar", nil, self)
	power:SetHeight(TukuiDB.Scale(3))
	power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -TukuiDB.mult)
	power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
	power:SetStatusBarTexture(TukuiCF["media"].normTex)
	self.Power = power
	
	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = self.Power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(TukuiCF["media"].normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.4
	self.Power.bg = power.bg
	
	if TukuiCF.unitframes.unicolor == true then
		power.colorClass = true
		power.bg.multiplier = 0.1				
	else
		power.colorPower = true
	end
		
	local name = health:CreateFontString(nil, 'OVERLAY')
	name:SetFont(font2, 13*TukuiDB.raidscale, "THINOUTLINE")
	name:SetPoint("LEFT", self, "RIGHT", TukuiDB.Scale(5), TukuiDB.Scale(1))
	self:Tag(name, '[Tukui:namemedium] [Tukui:dead][Tukui:afk]')
	self.Name = name
	
	if TukuiCF["unitframes"].showsymbols == true then
		RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:SetHeight(TukuiDB.Scale(14*TukuiDB.raidscale))
		RaidIcon:SetWidth(TukuiDB.Scale(14*TukuiDB.raidscale))
		RaidIcon:SetPoint("CENTER", self, "CENTER")
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end
	
	if TukuiCF["unitframes"].aggro == true then
		table.insert(self.__elements, TukuiDB.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', TukuiDB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', TukuiDB.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', TukuiDB.UpdateThreat)
    end
	
	local LFDRole = health:CreateTexture(nil, "OVERLAY")
    LFDRole:SetHeight(TukuiDB.Scale(6*TukuiDB.raidscale))
    LFDRole:SetWidth(TukuiDB.Scale(6*TukuiDB.raidscale))
	LFDRole:SetPoint("TOPLEFT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	LFDRole:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\lfdicons.blp")
	self.LFDRole = LFDRole
	
	local ReadyCheck = health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(TukuiDB.Scale(12*TukuiDB.raidscale))
	ReadyCheck:SetWidth(TukuiDB.Scale(12*TukuiDB.raidscale))
	ReadyCheck:SetPoint('CENTER')
	self.ReadyCheck = ReadyCheck
	
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true

	if TukuiCF["unitframes"].showsmooth == true then
		health.Smooth = true
	end
	
	if TukuiCF["unitframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = TukuiCF["unitframes"].raidalphaoor}
		self.Range = range
	end
	
	-- this is needed to be sure vehicle have good health/power color
	-- aswell to be sure the name is displayed/updated correctly
	self:RegisterEvent("UNIT_PET", TukuiDB.updateAllElements)
	
	return self
end

oUF:RegisterStyle('TukuiDpsP05R10R15R25', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiDpsP05R10R15R25")

	local raid = self:SpawnHeader("oUF_TukuiDpsRaid05101525", nil, "custom [@raid26,exists] hide;show", "showParty", true, "showPlayer", TukuiCF["unitframes"].showplayerinparty, "showRaid", true, "groupFilter", "1,2,3,4,5,6,7,8", "groupingOrder", "1,2,3,4,5,6,7,8", "groupBy", "GROUP", "yOffset", TukuiDB.Scale(-3))
	raid:SetPoint('TOPLEFT', UIParent, 15, -350*TukuiDB.raidscale)
	
	local pets = {} 
		pets[1] = oUF:Spawn('partypet1', 'oUF_TukuiPartyPet1') 
		pets[1]:SetPoint('TOPLEFT', raid, 'TOPLEFT', 0, -120*TukuiDB.raidscale) 
	for i =2, 4 do 
		pets[i] = oUF:Spawn('partypet'..i, 'oUF_TukuiPartyPet'..i) 
		pets[i]:SetPoint('TOP', pets[i-1], 'BOTTOM', 0, -8) 
	end
	
	local RaidMove = CreateFrame("Frame")
	RaidMove:RegisterEvent("PLAYER_LOGIN")
	RaidMove:RegisterEvent("RAID_ROSTER_UPDATE")
	RaidMove:RegisterEvent("PARTY_LEADER_CHANGED")
	RaidMove:RegisterEvent("PARTY_MEMBERS_CHANGED")
	RaidMove:SetScript("OnEvent", function(self)
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			local numraid = GetNumRaidMembers()
			local numparty = GetNumPartyMembers()
			if numparty > 0 and numraid == 0 or numraid > 0 and numraid <= 5 then
				raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -399*TukuiDB.raidscale)
				for i,v in ipairs(pets) do v:Enable() end
			elseif numraid > 5 and numraid < 11 then
				raid:SetPoint('TOPLEFT', UIParent, 15, -350*TukuiDB.raidscale)
				for i,v in ipairs(pets) do v:Disable() end
			elseif numraid > 10 and numraid < 16 then
				raid:SetPoint('TOPLEFT', UIParent, 15, -280*TukuiDB.raidscale)
				for i,v in ipairs(pets) do v:Disable() end
			elseif numraid > 15 and numraid < 26 then
				raid:SetPoint('TOPLEFT', UIParent, 15, -172*TukuiDB.raidscale)
				for i,v in ipairs(pets) do v:Disable() end
			elseif numraid > 25 then
				for i,v in ipairs(pets) do v:Disable() end
			end
		end
	end)
end)