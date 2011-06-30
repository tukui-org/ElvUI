local E, C, L, DB = unpack(ElvUI) -- Import Functions/Constants, Config, Locales

local oUF = ElvUF or oUF
assert(oUF, "ElvUI was unable to locate oUF.")

if not C["raidframes"].enable == true == true or C["raidframes"].gridonly == true then return end
if IsAddOnLoaded("ElvUI_Dps_Layout") then return end

local RAID_WIDTH = (((ElvuiActionBarBackground:GetWidth() - (3*4)) / 5))*C["raidframes"].scale
local RAID_HEIGHT = E.Scale(50)*C["raidframes"].scale
local POWERTHEME = C["raidframes"].mini_powerbar
local BORDER = 2
local SPACING = 1

local function Shared(self, unit)
	local POWERBAR_WIDTH = RAID_WIDTH - (BORDER*2)
	local POWERBAR_HEIGHT = 8
		
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
	
	if unit == "raidpet" then
		--Health Bar
		local health = E.ContructHealthBar(self, true, nil)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -2, -2)
		health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", 2, 2)
		self.Health = health
	
		--Name
		self:FontString("Name", C["media"].uffont, C["unitframes"].fontsize, "THINOUTLINE")
		self.Name:SetPoint("CENTER", health, "CENTER")
		self.Name.frequentUpdates = 0.5
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namemedium]')	
	else
		--Health Bar
		local health = E.ContructHealthBar(self, true, true)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		if POWERTHEME == true then
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end
		if C["raidframes"].gridhealthvertical == true then
			health:SetOrientation("VERTICAL")
		end		
		health.value:Point("BOTTOM", health, "BOTTOM", 0, 7)
		health.value:SetFont(C["media"].uffont, (C["raidframes"].fontsize-1)*C["raidframes"].scale, "THINOUTLINE")
		
		self.Health = health
				
		--Power Bar
		local power = E.ConstructPowerBar(self, true, nil)
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

		self.Power = power

		--Name
		self:FontString("Name", C["media"].uffont, (C["unitframes"].fontsize-1)*C["raidframes"].scale, "THINOUTLINE")
		self.Name:Point("TOP", health, "TOP", 0, -3)
		self.Name.frequentUpdates = 0.3
		self:Tag(self.Name, "[Elvui:getnamecolor][Elvui:nameshort]")

		if C["raidframes"].role == true then
			local LFDRole = self:CreateTexture(nil, "OVERLAY")
			LFDRole:Size(17, 17)
			LFDRole:Point("TOP", self.Name, "BOTTOM", 0, -1)
			LFDRole.Override = E.RoleIconUpdate
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
		RaidIcon:SetPoint('CENTER', self, 'TOP')
		RaidIcon:SetTexture('Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp')
		self.RaidIcon = RaidIcon
		
		local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		ReadyCheck:SetHeight(C["raidframes"].fontsize)
		ReadyCheck:SetWidth(C["raidframes"].fontsize)
		ReadyCheck:Point('TOP', self.Name, 'BOTTOM', 0, -2)
		self.ReadyCheck = ReadyCheck
		

		if C["unitframes"].debuffhighlight == true then
			local dbh = self:CreateTexture(nil, "OVERLAY")
			if POWERTHEME then
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
		
		if C["raidframes"].debuffs == true then
			local debuffs = CreateFrame('Frame', nil, self)
			debuffs:Point('TOP', self, 'BOTTOM', 0, -1)
			debuffs:SetHeight(RAID_HEIGHT/3)
			debuffs:SetWidth(RAID_WIDTH)
			debuffs.spacing = 2
			debuffs.num = 3
			debuffs.size = ((RAID_WIDTH - (debuffs.spacing*(debuffs.num - 1))) / debuffs.num)
			debuffs.initialAnchor = 'TOPLEFT'
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			debuffs.CustomFilter = E.AuraFilter	
			self.Debuffs = debuffs
		end
		
		--Heal Comm
		if C["raidframes"].healcomm == true then
			local mhpb = CreateFrame('StatusBar', nil, health)
			if C["raidframes"].gridhealthvertical == true then
				mhpb:SetOrientation("VERTICAL")
				mhpb:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'TOPLEFT')
				mhpb:SetPoint('BOTTOMRIGHT', health:GetStatusBarTexture(), 'TOPRIGHT')
				mhpb:SetHeight(RAID_HEIGHT)
			else
				mhpb:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
				mhpb:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT')		
				mhpb:SetWidth(RAID_WIDTH - (BORDER*2))
			end
			
			mhpb:SetStatusBarTexture(C["media"].blank)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

			local ohpb = CreateFrame('StatusBar', nil, health)
			if C["raidframes"].gridhealthvertical == true then		
				ohpb:SetOrientation("VERTICAL")
				ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'TOPLEFT')
				ohpb:SetPoint('BOTTOMRIGHT', mhpb:GetStatusBarTexture(), 'TOPRIGHT')
				ohpb:SetHeight(RAID_HEIGHT)
			else
				ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
				ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
				ohpb:SetWidth(RAID_WIDTH - (BORDER*2))
			end
			ohpb:SetStatusBarTexture(C["media"].blank)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
				PostUpdate = function(self)
					if self.myBar:GetValue() == 0 then self.myBar:SetAlpha(0) else self.myBar:SetAlpha(1) end
					if self.otherBar:GetValue() == 0 then self.otherBar:SetAlpha(0) else self.otherBar:SetAlpha(1) end
				end
			}
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
	end
	
	
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

oUF:RegisterStyle('ElvuiHealParty', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiHealParty")
	local party
	if C["raidframes"].partypets == true then
		party = self:SpawnHeader("ElvuiHealParty", nil, "custom [@raid6,exists] hide;show", 
			'oUF-initialConfigFunction', ([[
				local header = self:GetParent()
				local pet = header:GetChildren():GetName()
				self:SetWidth(%d)
				self:SetHeight(%d)
				for i = 1, 5 do
					if pet == "ElvuiHealPartyUnitButton"..i.."Pet" then
						header:GetChildren():SetWidth(%d)
						header:GetChildren():SetHeight(%d)		
					end
				end
			]]):format(RAID_WIDTH, RAID_HEIGHT, RAID_WIDTH, 20*C["raidframes"].scale),	
			"showRaid", true, 
			"showParty", true,
			"showSolo", false,
			"point", "LEFT",
			"columnAnchorPoint", "TOP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"showPlayer", C["raidframes"].showplayerinparty,
			"xoffset", 3,
			'template', 'HealerPartyPets'
		)	
	else
		party = self:SpawnHeader("ElvuiHealParty", nil, "custom [@raid6,exists] hide;show", 
			'oUF-initialConfigFunction', ([[
				local header = self:GetParent()
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(RAID_WIDTH, RAID_HEIGHT),	
			"showRaid", true, 
			"showParty", true,
			"showSolo", false,
			"point", "LEFT",
			"columnAnchorPoint", "TOP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"showPlayer", C["raidframes"].showplayerinparty,
			"xoffset", 3
		)		
	end
	party:SetPoint("BOTTOM", ElvuiActionBarBackground, "TOP", 0, E.Scale(32))	
	
	local partyToggle = CreateFrame("Frame")
	partyToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	partyToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	partyToggle:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		if not InCombatLockdown() then
			if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
				ElvuiHealParty:SetAttribute("showRaid", false)
				ElvuiHealParty:SetAttribute("showParty", false)			
			else
				ElvuiHealParty:SetAttribute("showParty", true)
				ElvuiHealParty:SetAttribute("showRaid", true)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)