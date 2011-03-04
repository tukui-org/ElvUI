local E, C, L = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
local oUF = ElvUF or oUF
assert(oUF, "ElvUI was unable to locate oUF.")

if not C["raidframes"].enable == true then return end

local RAID_WIDTH = ((ChatLBackground2:GetWidth() / 5) - 2.5)*C["raidframes"].scale
local RAID_HEIGHT = E.Scale(32)*C["raidframes"].scale

local BORDER = 2

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
	
	--Health Bar
	local health = E.ContructHealthBar(self, true, true)
	health:Point("TOPRIGHT", self, "TOPRIGHT", -BORDER, -BORDER)
	health:Point("BOTTOMLEFT", self, "BOTTOMLEFT", BORDER, BORDER)
	health.value:Point("BOTTOM", health, "BOTTOM", 0, 1)
	health.value:SetFont(C["media"].uffont, (C["raidframes"].fontsize-1)*C["raidframes"].scale, "THINOUTLINE")
	
	self.Health = health
				
	--Name
	self:FontString("Name", C["media"].uffont, (C["unitframes"].fontsize-1)*C["raidframes"].scale, "THINOUTLINE")
	self.Name:Point("TOP", health, "TOP", 0, -3)
	self.Name.frequentUpdates = 0.3
	self:Tag(self.Name, "[Elvui:getnamecolor][Elvui:nameshort]")

	if C["raidframes"].role == true then
		local LFDRole = self:CreateTexture(nil, "OVERLAY")
		LFDRole:Size(6, 6)
		LFDRole:Point("TOP", self.Name, "BOTTOM", 0, -1)
		LFDRole:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\lfdicons.blp")
		self.LFDRole = LFDRole
	end
	
	table.insert(self.__elements, E.UpdateThreat)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', E.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', E.UpdateThreat)
	self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', E.UpdateThreat)

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
		dbh:SetAllPoints()
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
	
	if C["auras"].raidunitbuffwatch == true then
		E.createAuraWatch(self,unit)
    end
	
	return self
end

oUF:RegisterStyle('ElvuiDPSR26R40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("ElvuiDPSR26R40")	
	local raid = self:SpawnHeader("ElvuiDPSR26R40", nil, "custom [@raid26,exists] show;hide",
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
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"maxColumns", 8,
		"unitsPerColumn", 5,
		"columnSpacing", 3,
		"columnAnchorPoint", "TOP"		
	)		
	raid:Point("BOTTOMLEFT", ChatLBackground2, "TOPLEFT", 1, 35)

	local raidToggle = CreateFrame("Frame")
	raidToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
	raidToggle:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	raidToggle:SetScript("OnEvent", function(self, event)
		local inInstance, instanceType = IsInInstance()
		local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
		if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
		if not InCombatLockdown() then
			if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
				ElvuiDPSR26R40:SetAttribute("showRaid", false)
				ElvuiDPSR26R40:SetAttribute("showParty", false)			
			else
				ElvuiDPSR26R40:SetAttribute("showParty", true)
				ElvuiDPSR26R40:SetAttribute("showRaid", true)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	end)
end)