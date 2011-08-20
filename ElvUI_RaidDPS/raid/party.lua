local E, C, L, DB = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
local oUF = ElvUF or oUF
assert(oUF, "ElvUI was unable to locate oUF.")

if not C["raidframes"].enable == true or C["raidframes"].gridonly == true then return end

local font2 = C["media"].uffont
local font1 = C["media"].font
local normTex = C["media"].normTex

--Frame Size
local PARTY_HEIGHT = E.Scale(35)*C["raidframes"].scale
local PARTY_WIDTH = E.Scale(140)*C["raidframes"].scale
local PTARGET_HEIGHT = E.Scale(17)*C["raidframes"].scale
local PTARGET_WIDTH = (PARTY_WIDTH/2)*C["raidframes"].scale
local POWERTHEME = C["raidframes"].mini_powerbar
local BORDER = 2
local SPACING = 1

if E.LoadUFFunctions then E.LoadUFFunctions("DPS") end

local function Shared(self, unit)
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
	
	if unit == "raidtarget" then
		--Health Bar
		local health = E.ContructHealthBar(self, true, nil)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER)
		self.Health = health
		
		--Name
		self:FontString("Name", font1, C["unitframes"].fontsize, "THINOUTLINE")
		self.Name:Point("CENTER", health, "CENTER", 0, 2)
		self.Name.frequentUpdates = 0.5
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namemedium]')

		-- Debuff Highlight
		if C["unitframes"].debuffhighlight == true then
			local dbh = self:CreateTexture(nil, "OVERLAY")
			dbh:SetAllPoints()
			dbh:SetTexture(C["media"].blank)
			dbh:SetBlendMode("ADD")
			dbh:SetVertexColor(0,0,0,0)
			self.DebuffHighlight = dbh
			self.DebuffHighlightFilter = true
			self.DebuffHighlightAlpha = 0.35
		end		
	else
		local POWERBAR_WIDTH = PARTY_WIDTH - (BORDER*2)
		local POWERBAR_HEIGHT = 8
		
		--Health Bar
		local health = E.ContructHealthBar(self, true, true)
		health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
		if POWERTHEME == true then
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + (POWERBAR_HEIGHT/2))
		else
			health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER + POWERBAR_HEIGHT)
		end
		health.value:Point("RIGHT", health, "RIGHT", -4, 0)
		
		self.Health = health

		--Power Bar
		local power = E.ConstructPowerBar(self, true, nil)
		if POWERTHEME == true then
			power:Width((POWERBAR_WIDTH/1.5) - BORDER*2)
			power:Height(POWERBAR_HEIGHT - BORDER*2)
			power:Point("RIGHT", self, "BOTTOMRIGHT", -(BORDER*2 + 4), BORDER + (POWERBAR_HEIGHT/2))
			power:SetFrameStrata("MEDIUM")
			power:SetFrameLevel(self:GetFrameLevel() + 3)
		else
			power:Point("TOPLEFT", health.backdrop, "BOTTOMLEFT", BORDER, -(BORDER + SPACING))
			power:Point("BOTTOMRIGHT", self, "BOTTOMRIGHT", -BORDER, BORDER)
		end	
		self.Power = power
		
		--Name
		self:FontString("Name", font1, C["unitframes"].fontsize, "THINOUTLINE")
		self.Name:SetJustifyH("LEFT")
		self.Name:Point("LEFT", health, "LEFT", 2, 0)
		self.Name.frequentUpdates = 0.2
		self:Tag(self.Name, '[Elvui:getnamecolor][Elvui:namelong]')
		
		--Leader Icon
		local leader = self:CreateTexture(nil, "OVERLAY")
		leader:Size(14)
		leader:Point("TOPRIGHT", -4, 8)
		self.Leader = leader
		
		--Master Looter Icon
		local ml = self:CreateTexture(nil, "OVERLAY")
		ml:Size(14)
		self.MasterLooter = ml
		self:RegisterEvent("PARTY_LEADER_CHANGED", E.MLAnchorUpdate)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", E.MLAnchorUpdate)	
			
		--Aggro Glow
		if C["raidframes"].displayaggro == true then
			table.insert(self.__elements, E.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)
		end
		
		local LFDRole = self:CreateTexture(nil, "OVERLAY")
		LFDRole:Size(17, 17)
		LFDRole:Point("TOPRIGHT", health, "TOPRIGHT", -2, -2)
		LFDRole.Override = E.RoleIconUpdate
		self:RegisterEvent("UNIT_CONNECTION", E.RoleIconUpdate)
		self.LFDRole = LFDRole		
		
		
		
		--Raid Icon
		local RaidIcon = self:CreateTexture(nil, "OVERLAY")
		RaidIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp") 
		RaidIcon:Size(18, 18)
		RaidIcon:Point("CENTER", health, "TOP", 0, BORDER)
		self.RaidIcon = RaidIcon

		local ReadyCheck = self:CreateTexture(nil, "OVERLAY")
		ReadyCheck:Size(C["raidframes"].fontsize, C["raidframes"].fontsize)
		ReadyCheck:Point('LEFT', self.Name, 'RIGHT', 4, 0)
		self.ReadyCheck = ReadyCheck
		
		if C["raidframes"].debuffs == true then
			local debuffs = CreateFrame('Frame', nil, self)
			debuffs:SetPoint('LEFT', self, 'RIGHT', 5, 0)
			debuffs:SetHeight(PARTY_HEIGHT*.9)
			debuffs:SetWidth(200)
			debuffs.size = PARTY_HEIGHT*.9
			debuffs.spacing = 2
			debuffs.initialAnchor = 'LEFT'
			debuffs.num = 5
			debuffs.PostCreateIcon = E.PostCreateAura
			debuffs.PostUpdateIcon = E.PostUpdateAura
			debuffs.CustomFilter = E.AuraFilter
			self.Debuffs = debuffs
		end
		
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

oUF:RegisterStyle('ElvuiDPSParty', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiDPSParty")
	local party
	if C["raidframes"].partytarget ~= true then
		party = self:SpawnHeader("ElvuiDPSParty", nil, "custom [@raid6,exists] hide;show", 
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', PARTY_WIDTH,
			'initial-height', PARTY_HEIGHT,			
			"showParty", true, 
			"showPlayer", C["raidframes"].showplayerinparty, 
			"showRaid", true, 
			"showSolo", false,
			"yOffset", E.Scale(-8)
		)
	else
		party = self:SpawnHeader("ElvuiDPSParty", nil, "custom [@raid6,exists] hide;show", 
			'oUF-initialConfigFunction', ([[
				local header = self:GetParent()
				local ptarget = header:GetChildren():GetName()
				self:SetWidth(%d)
				self:SetHeight(%d)
				for i = 1, 5 do
					if ptarget == "ElvuiDPSPartyUnitButton"..i.."Target" then
						header:GetChildren():SetWidth(%d)
						header:GetChildren():SetHeight(%d)		
					end
				end
			]]):format(PARTY_WIDTH, PARTY_HEIGHT, PTARGET_WIDTH, PTARGET_HEIGHT),			
			"showParty", true, 
			"showPlayer", C["raidframes"].showplayerinparty, 
			"showRaid", true, 
			"showSolo", false,
			"yOffset", E.Scale(-27),
			'template', 'DPSPartyTarget'
		)	
	end
	party:Point("BOTTOMLEFT", ChatLBGDummy, "TOPLEFT", 0, 10)
	
	local partyToggle = CreateFrame("Frame")
	partyToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	partyToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	partyToggle:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		if not InCombatLockdown() then
			if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
				ElvuiDPSParty:SetAttribute("showRaid", false)
				ElvuiDPSParty:SetAttribute("showParty", false)			
			else
				ElvuiDPSParty:SetAttribute("showParty", true)
				ElvuiDPSParty:SetAttribute("showRaid", true)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)