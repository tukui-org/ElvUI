local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
local _, ns = ...
local oUF = ElvUF or ns.oUF or oUF
assert(oUF, "ElvUI was unable to locate oUF.")

if not C["raidframes"].enable == true == true or C["raidframes"].gridonly == true then return end
if IsAddOnLoaded("ElvUI_Dps_Layout") then return end

local font2 = C["media"].uffont
local font1 = C["media"].font
local normTex = C["media"].normTex

--Frame Size
local party_width = E.Scale((ElvuiActionBarBackground:GetWidth() / 5) + 7)*C["raidframes"].scale
local party_height = E.Scale(50)*C["raidframes"].scale
local pet_width = party_width*C["raidframes"].scale
local pet_height = E.Scale(20)*C["raidframes"].scale

local function Shared(self, unit)	
	self.colors = E.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = E.SpawnMenu
	
	-- an update script to all elements
	self:HookScript("OnShow", E.updateAllElements)
	
	if unit == "raidpet" then
		local health = CreateFrame('StatusBar', nil, self)
		health:SetAllPoints(self)
		health:SetStatusBarTexture(normTex)
		self.Health = health
		
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints(health)
		health.bg:SetTexture(normTex)
		health.frequentUpdates = true
		
		self.Health.bg = health.bg
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
		name:SetPoint("CENTER", health, 0, 0)
		name:SetFont(font2, C["raidframes"].fontsize, "THINOUTLINE")
		name:SetShadowOffset(1, -1)
		
		self:Tag(name, "[Elvui:getnamecolor][Elvui:nameshort]")
		self.Name = name
		
		if C["unitframes"].aggro == true then
			table.insert(self.__elements, E.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)
		end
		
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
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			mhpb:SetWidth(party_width)
			mhpb:SetStatusBarTexture(C["media"].normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			ohpb:SetWidth(party_width)
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
		
		if C["unitframes"].showsmooth == true then health.Smooth = true end	
	else
		local health = CreateFrame('StatusBar', nil, self)
		health:SetHeight(party_height*.86)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		if C["raidframes"].gridhealthvertical == true then
			health:SetOrientation("VERTICAL")
		end
		health:SetStatusBarTexture(normTex)
		self.Health = health
		
		health.bg = health:CreateTexture(nil, 'BORDER')
		health.bg:SetAllPoints(health)
		health.bg:SetTexture(normTex)
		
		self.Health.bg = health.bg
			
		health.value = health:CreateFontString(nil, "OVERLAY")
		health.value:SetPoint("BOTTOM", health, "BOTTOM", 0, E.Scale(4))
		health.value:SetFont(font2, C["raidframes"].fontsize, "THINOUTLINE")
		health.value:SetTextColor(1,1,1)
		health.value:SetShadowOffset(1, -1)
		self.Health.value = health.value
		
		health.PostUpdate = E.PostUpdateHealth
		
		health.frequentUpdates = true
		
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
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, E.Scale(-1)+(-E.mult*2))
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, E.Scale(-1)+(-E.mult*2))
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		power:SetStatusBarTexture(normTex)
		self.Power = power
		--[[if C["raidframes"].hidenonmana == true then
			power.PostUpdate = E.PostUpdatePowerParty
		end]]
		
		-- border between health and power
		self.HealthBorder = CreateFrame("Frame", nil, power)
		self.HealthBorder:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -E.mult)
		self.HealthBorder:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -E.mult)
		self.HealthBorder:SetPoint("BOTTOMLEFT", power, "TOPLEFT", 0, E.mult)
		self.HealthBorder:SetPoint("BOTTOMRIGHT", power, "TOPRIGHT", 0, E.mult)
		self.HealthBorder:SetTemplate("Default")
		self.HealthBorder:SetBackdropBorderColor(unpack(C["media"].altbordercolor))	
			
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
		name:SetPoint("TOP", health, 0, E.Scale(-2))
		name:SetFont(font2, C["raidframes"].fontsize, "THINOUTLINE")
		name:SetShadowOffset(1, -1)
		self:Tag(name, "[Elvui:getnamecolor][Elvui:nameshort]")
		self.Name = name
		
		local leader = health:CreateTexture(nil, "OVERLAY")
		leader:SetHeight(E.Scale(12))
		leader:SetWidth(E.Scale(12))
		leader:SetPoint("TOPLEFT", 0, 6)
		self.Leader = leader
		
		local LFDRole = health:CreateTexture(nil, "OVERLAY")
		LFDRole:SetHeight(E.Scale(6))
		LFDRole:SetWidth(E.Scale(6))
		LFDRole:SetPoint("TOP", self.Name, "BOTTOM", 0, E.Scale(-2))
		LFDRole:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\lfdicons.blp")
		self.LFDRole = LFDRole
		
		local MasterLooter = health:CreateTexture(nil, "OVERLAY")
		MasterLooter:SetHeight(E.Scale(12))
		MasterLooter:SetWidth(E.Scale(12))
		self.MasterLooter = MasterLooter
		self:RegisterEvent("PARTY_LEADER_CHANGED", E.MLAnchorUpdate)
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", E.MLAnchorUpdate)
		
		if C["unitframes"].aggro == true then
			table.insert(self.__elements, E.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)
		end
		
		if C["unitframes"].showsymbols == true then
			local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
			RaidIcon:SetHeight(E.Scale(18))
			RaidIcon:SetWidth(E.Scale(18))
			RaidIcon:SetPoint('CENTER', self, 'TOP')
			RaidIcon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\raidicons.blp")
			self.RaidIcon = RaidIcon
		end
		
		local ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
		ReadyCheck:SetHeight(C["raidframes"].fontsize)
		ReadyCheck:SetWidth(C["raidframes"].fontsize)
		ReadyCheck:SetPoint('CENTER', self.Health, 'CENTER', 0, -4)
		self.ReadyCheck = ReadyCheck
		
		local debuffs = CreateFrame('Frame', nil, self)
		debuffs:SetPoint('TOP', self, 'BOTTOM', E.Scale(-1), E.Scale(-4))
		debuffs:SetHeight((party_width / 3)*.95)
		debuffs:SetWidth(party_width)
		debuffs.size = (party_width / 3) *.95
		debuffs.spacing = 2
		debuffs.initialAnchor = 'LEFT'
		debuffs.num = 3
		debuffs.PostCreateIcon = E.PostCreateAura
		debuffs.PostUpdateIcon = E.PostUpdateAura
		self.Debuffs = debuffs	
		
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
		
		-- Debuff Aura Filter
		self.Debuffs.CustomFilter = E.AuraFilter
		
		--Heal Comm
		if C["raidframes"].healcomm == true then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			if C["raidframes"].gridhealthvertical == true then
				mhpb:SetOrientation("VERTICAL")
				mhpb:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP', 0, 0)
				mhpb:SetHeight(party_height)
			else
				mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
				mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			end
			mhpb:SetWidth(party_width)
			mhpb:SetStatusBarTexture(C["media"].normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			if C["raidframes"].gridhealthvertical == true then		
				ohpb:SetOrientation("VERTICAL")
				ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
				ohpb:SetHeight(party_height)
			else
				ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
				ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)		
			end
			ohpb:SetWidth(party_width)
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
			if self.Power then
				power.Smooth = true
			end
		end	
			
		if C["auras"].raidunitbuffwatch == true then
			E.createAuraWatch(self,unit)
		end
		
		-- execute an update on every raids unit if party or raid member changed
		-- should fix issues with names/symbols/etc not updating introduced with 4.0.3 patch
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", E.updateAllElements)
		self:RegisterEvent("RAID_ROSTER_UPDATE", E.updateAllElements)
	end
	
	return self
end

oUF:RegisterStyle('ElvuiHealParty', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiHealParty")
	local yOffset = 0
	if C["castbar"].castermode == true and (HealElementsCharPos and HealElementsCharPos["PlayerCastBar"] ~= true) then
		yOffset = yOffset + 28
	end
	
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
			]]):format(party_width, party_height, pet_width, pet_height),	
			"showRaid", true, 
			"showParty", true,
			"showSolo", false,
			"point", "LEFT",
			"columnAnchorPoint", "TOP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"showPlayer", C["raidframes"].showplayerinparty,
			"xoffset", E.Scale(6),
			'template', 'HealerPartyPets'
		)	
	else
		party = self:SpawnHeader("ElvuiHealParty", nil, "custom [@raid6,exists] hide;show", 
			'oUF-initialConfigFunction', ([[
				local header = self:GetParent()
				self:SetWidth(%d)
				self:SetHeight(%d)
			]]):format(party_width, party_height),	
			"showRaid", true, 
			"showParty", true,
			"showSolo", false,
			"point", "LEFT",
			"columnAnchorPoint", "TOP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"showPlayer", C["raidframes"].showplayerinparty,
			"xoffset", E.Scale(6)
		)		
	end
	party:SetPoint("BOTTOM", ElvuiActionBarBackground, "TOP", 0, E.Scale(32+yOffset))	
	
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