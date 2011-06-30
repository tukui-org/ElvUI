local E, C, L, DB = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
local oUF = ElvUF or oUF
assert(oUF, "ElvUI was unable to locate oUF.")

if not C["raidframes"].enable == true then return end

local RAID_WIDTH
local RAID_HEIGHT
if C["raidframes"].griddps ~= true then
	RAID_WIDTH = E.Scale(110)*C["raidframes"].scale
	RAID_HEIGHT = E.Scale(25)*C["raidframes"].scale
else
	RAID_WIDTH = (((ChatLBGDummy:GetWidth() - (3*4)) / 5))*C["raidframes"].scale
	RAID_HEIGHT = E.Scale(40)*C["raidframes"].scale
end

local POWERTHEME = C["raidframes"].mini_powerbar
local SPACING = 1
local BORDER = 2

local function Shared(self, unit)
	local POWERBAR_WIDTH = RAID_WIDTH - (BORDER*2)
	local POWERBAR_HEIGHT = 8
	
	if C["raidframes"].griddps ~= true then
		POWERBAR_HEIGHT = 7
	end
	
	-- Set Colors
	self.colors = E.oUF_colors
	
	-- Register Frames for Click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- Setup Menu
	self.menu = E.SpawnMenu
	
	-- Frame Level
	self:SetFrameLevel(5)
	
	--Health Bar
	local health = E.ContructHealthBar(self, true, true)
	health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
	if C["raidframes"].griddps ~= true then
		health.value:Point("RIGHT", health, "RIGHT", -2, 0)
		if POWERTHEME == true then
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end
	else
		if POWERTHEME == true then
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end
		health.value:Point("BOTTOM", health, "BOTTOM", 0, 4)
		
	end
	health.value:SetFont(C["media"].uffont, (C["raidframes"].fontsize-1)*C["raidframes"].scale, "THINOUTLINE")
	
	self.Health = health
			
	--Power Bar
	local power = E.ConstructPowerBar(self, true, nil)
	if C["raidframes"].griddps ~= true then
		if POWERTHEME == true then
			power:Width((POWERBAR_WIDTH/1.5) - BORDER*2)
			power:Height(POWERBAR_HEIGHT - BORDER*2)
			power:Point("RIGHT", self, "BOTTOMRIGHT", -(BORDER*2 + 4), (BORDER + (POWERBAR_HEIGHT/2)) - 1)
			power:SetFrameStrata("MEDIUM")
			power:SetFrameLevel(self:GetFrameLevel() + 3)
		else
			power:Point("TOPLEFT", health.backdrop, "BOTTOMLEFT", BORDER, -(BORDER + SPACING))
			power:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -BORDER, BORDER)
		end	
	else
		if POWERTHEME == true then
			power:Width((POWERBAR_WIDTH / 1.3) - BORDER*2)
			power:Height(POWERBAR_HEIGHT - 1 - BORDER*2)
			power:Point("CENTER", self, "BOTTOM", 0, (BORDER + (POWERBAR_HEIGHT/2)) - 1)
			power:SetFrameStrata("MEDIUM")
			power:SetFrameLevel(self:GetFrameLevel() + 3)
		else
			power:Point("TOPLEFT", health.backdrop, "BOTTOMLEFT", BORDER, -(BORDER + SPACING))
			power:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -BORDER, BORDER)
		end		
	end

	self.Power = power

	--Name
	self:FontString("Name", C["media"].uffont, (C["unitframes"].fontsize-1)*C["raidframes"].scale, "THINOUTLINE")
	if C["raidframes"].griddps ~= true then
		self.Name:Point("LEFT", health, "LEFT", 2, 0)
	else
		self.Name:Point("TOP", health, "TOP", 0, -3)
	end
	self.Name.frequentUpdates = 0.3
	self:Tag(self.Name, "[Elvui:getnamecolor][Elvui:nameshort]")

	if C["raidframes"].role == true then
		local LFDRole = self:CreateTexture(nil, "OVERLAY")
		LFDRole:Size(17, 17)
		LFDRole.Override = E.RoleIconUpdate
		if C["raidframes"].griddps ~= true then
			LFDRole:Point("TOPRIGHT", self.Health, "TOPRIGHT", -2, -2)
		else
			LFDRole:Point("TOP", self.Name, "BOTTOM", 0, -1)
		end
		self:RegisterEvent("UNIT_CONNECTION", E.RoleIconUpdate)
		self.LFDRole = LFDRole
	end
	
	--Aggro Glow
	if C["raidframes"].displayaggro == true then
		table.insert(self.__elements, E.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)
	end


	local RaidIcon = self:CreateTexture(nil, 'OVERLAY')
	RaidIcon:Size(15*C["raidframes"].scale, 15*C["raidframes"].scale)
	if C["raidframes"].griddps ~= true then
		RaidIcon:SetPoint('LEFT', self.Name, 'RIGHT')
	else
		RaidIcon:SetPoint('CENTER', self, 'TOP')
	end
	RaidIcon:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp')
	self.RaidIcon = RaidIcon
	
	local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetHeight(C["raidframes"].fontsize)
	ReadyCheck:SetWidth(C["raidframes"].fontsize)
	if C["raidframes"].griddps ~= true then
		ReadyCheck:Point('LEFT', self.Name, 'RIGHT', 4, 0)
	else	
		ReadyCheck:Point('TOP', self.Name, 'BOTTOM', 0, -2)
	end
	self.ReadyCheck = ReadyCheck
	

	if C["unitframes"].debuffhighlight == true then
		local dbh = self:CreateTexture(nil, "OVERLAY")
		if POWERTHEME == true then
			dbh:SetPoint("TOPLEFT")
			dbh:SetPoint("BOTTOMRIGHT", health.backdrop, "BOTTOMRIGHT")
		else
			dbh:SetAllPoints()
		end
		dbh:SetTexture(C["media"].blank)
		dbh:SetBlendMode("ADD")
		dbh:SetVertexColor(0,0,0,0)
		self.DebuffHighlight = dbh
		self.DebuffHighlightFilter = true
		self.DebuffHighlightAlpha = 0.35
	end
	
	if C["raidframes"].griddps ~= true and C["raidframes"].debuffs == true then
		local debuffs = CreateFrame('Frame', nil, self)
		debuffs:SetPoint('LEFT', self, 'RIGHT', E.Scale(6), 0)
		debuffs:SetHeight(RAID_HEIGHT)
		debuffs:SetWidth(RAID_HEIGHT*5)
		debuffs.size = (RAID_HEIGHT)
		debuffs.num = 5
		debuffs.spacing = 2
		
		debuffs.initialAnchor = 'LEFT'
		debuffs.PostCreateIcon = E.PostCreateAura
		debuffs.PostUpdateIcon = E.PostUpdateAura
		self.Debuffs = debuffs
		
		-- Debuff Aura Filter
		self.Debuffs.CustomFilter = E.AuraFilter		
	elseif C["raidframes"].debuffs == true then
		-- Raid Debuffs (big middle icon)
		local RaidDebuffs = CreateFrame('Frame', nil, self)
		RaidDebuffs:Height(RAID_HEIGHT*0.6)
		RaidDebuffs:Width(RAID_HEIGHT*0.6)
		RaidDebuffs:Point('BOTTOM', self, 'BOTTOM', 0, 1)
		RaidDebuffs:SetFrameLevel(self:GetFrameLevel() + 2)
		RaidDebuffs:SetFrameStrata("MEDIUM")
		RaidDebuffs:SetFrameLevel(50)
		
		RaidDebuffs:SetTemplate("Default")
		
		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, 'OVERLAY')
		RaidDebuffs.icon:SetTexCoord(.1,.9,.1,.9)
		RaidDebuffs.icon:Point("TOPLEFT", 2, -2)
		RaidDebuffs.icon:Point("BOTTOMRIGHT", -2, 2)
		
		RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, 'OVERLAY')
		RaidDebuffs.count:SetFont(C["media"].uffont, C["general"].fontscale*0.75, "THINOUTLINE")
		RaidDebuffs.count:SetPoint('BOTTOMRIGHT', RaidDebuffs, 'BOTTOMRIGHT', 0, 2)
		RaidDebuffs.count:SetTextColor(1, .9, 0)
		
		RaidDebuffs:FontString('time', C["media"].uffont, C["general"].fontscale*0.75, "THINOUTLINE")
		RaidDebuffs.time:SetPoint('CENTER')
		RaidDebuffs.time:SetTextColor(1, .9, 0)
		
		self.RaidDebuffs = RaidDebuffs
	end
				
	if C["raidframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["raidframes"].raidalphaoor}
		self.Range = range
	end
	
	if C["raidframes"].raidunitbuffwatch == true then
		E.createAuraWatch(self,unit)
    end
	
	--Resurrect Indicator
	local Resurrect = CreateFrame('Frame', nil, self)
	Resurrect:SetFrameLevel(20)

	local ResurrectIcon = Resurrect:CreateTexture(nil, "OVERLAY")
	ResurrectIcon:Point(health.value:GetPoint())
	ResurrectIcon:Size(30, 25)
	ResurrectIcon:SetDrawLayer('OVERLAY', 7)

	self.ResurrectIcon = ResurrectIcon
	
	if C["raidframes"].mouseglow == true then
		self:CreateShadow("Default")
		
		--self.shadow is used for threat, if we leave it like this, it may cause complications
		self.mouseglow = self.shadow
		self.shadow = nil
		
		self.mouseglow:SetFrameStrata("BACKGROUND")
		if POWERTHEME then
			self.mouseglow:Point("TOPLEFT", self.Health.backdrop, -4, 4)
			self.mouseglow:Point("TOPRIGHT", self.Health.backdrop, 4, 4)
			self.mouseglow:Point("BOTTOMLEFT", self.Health.backdrop, -4, -4)
			self.mouseglow:Point("BOTTOMRIGHT", self.Health.backdrop, 4, -4)		
		else
			self.mouseglow:Point("TOPLEFT", -4, 4)
			self.mouseglow:Point("TOPRIGHT", 4, 4)
			self.mouseglow:Point("BOTTOMLEFT", -4, -4)
			self.mouseglow:Point("BOTTOMRIGHT", 4, -4)
		end
		self.mouseglow:Hide()
		
		self:HookScript("OnEnter", function(self)
			local unit = self.unit
			if not unit then return end
			self.mouseglow:Show()
			
			local reaction = UnitReaction(unit, 'player')
			local _, class = UnitClass(unit)
			
			if UnitIsPlayer(unit) then
				local c = E.colors.class[class]
				self.mouseglow:SetBackdropBorderColor(c[1], c[2], c[3], 1)
			elseif reaction then
				local c = E.oUF_colors.reaction[reaction]
				self.mouseglow:SetBackdropBorderColor(c[1], c[2], c[3], 1)
			else
				self.mouseglow:SetBackdropBorderColor(.84, .75, .65, 1)
			end			
		end)
		
		self:HookScript("OnLeave", function(self)
			self.mouseglow:Hide()		
		end)	
	end	
	
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
			'initial-width', RAID_WIDTH,
			'initial-height', RAID_HEIGHT,			
			"showRaid", true, 
			"showParty", true,
			"showSolo", false,
			"point", "BOTTOM",
			"showPlayer", C["raidframes"].showplayerinparty,
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",	
			"yOffset", E.Scale(6)
		)	
		raid:Point("BOTTOMLEFT", ChatLBGDummy, "TOPLEFT", 0, 10)
	else
		raid = self:SpawnHeader("ElvuiDPSR6R25", nil, "custom [@raid6,noexists][@raid26,exists] hide;show",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', RAID_WIDTH,
			'initial-height', RAID_HEIGHT,	
			"showRaid", true, 
			"showParty", true,
			"showPlayer", C["raidframes"].showplayerinparty,
			"xoffset", 3,
			"yOffset", -3,
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5",
			"groupingOrder", "1,2,3,4,5",
			"groupBy", "GROUP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"columnSpacing", 3,
			"columnAnchorPoint", "TOP"		
		)	
		raid:Point("BOTTOMLEFT", ChatLBGDummy, "TOPLEFT", 0, 10)	
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
			
			if inInstance and instanceType == "raid" and maxPlayers == 10 then
				raid:SetAttribute("groupFilter", "1,2")
			else
				raid:SetAttribute("groupFilter", "1,2,3,4,5")
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)