if not TukuiUF == true then return end

local fontlol = [=[Interface\Addons\Tukui\Media\Russel Square LT.ttf]=]

local colors = setmetatable({
	power = setmetatable({
		['MANA'] = {0, 144/255, 1},
	}, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

local function menu(self)
	if(self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
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

oUF.Tags['[smarthp]'] = function(u)
	local min, max = UnitHealth(u), UnitHealthMax(u)
	return UnitIsDeadOrGhost(u) and oUF.Tags['[dead]'](u) or (min~=max) and format('|cffff8080%d|r|cff0090ff %.0f|r%%', min-max, min/max*100) or max
end

oUF.Tags['[smartpp]'] = function(u)
	local min, max = UnitPower(u), UnitPowerMax(u)
	return (UnitPowerType(u) == 0 and min > 0) and format('|cff%02x%02x%02x%.0f|r%%', 0, 144, 255, min/max*100)
end

oUF.Tags['[offline]'] = function(u)
	if not UnitIsConnected(u) then
		return ("|cffB1071E"..ouf_offlinedps.."|r")
	end
end
	
oUF.Tags['[dead]'] = function(u) return UnitIsDeadOrGhost(u) and ouf_deaddps end
oUF.Tags['[afk]'] = function(u) return UnitIsAFK(u) and ' AFK' end

oUF.TagEvents['[smarthp]'] = 'UNIT_HEALTH'
oUF.TagEvents['[smartpp]'] = 'UNIT_MANA UNIT_DISPLAYPOWER'

oUF.TagEvents['[afk]'] = 'PLAYER_FLAGS_CHANGED'

local function CreateStyle(self, unit)
	self.menu = menu
	self.colors = colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self:SetAttribute('*type2', 'menu')
	self:SetAttribute('initial-height', 20)
	self:SetAttribute('initial-width', 150)

	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, left = -1, bottom = -1, right = -1}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	self.Health = CreateFrame('StatusBar', nil, self)
    self.Health:SetPoint("TOPLEFT")
    self.Health:SetPoint("TOPRIGHT")
    self.Health:SetHeight(16)
	self.Health:SetStatusBarTexture([=[Interface\AddOns\Tukui\media\normTex]=])
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true

	self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	self.Health.bg:SetTexture(0.3, 0.3, 0.3)
	self.Health.bg.multiplier = (0.3)
	
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetHeight(3)
    self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
    self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
    self.Power:SetStatusBarTexture(normTex)

    self.Power.colorTapping = true
    self.Power.colorDisconnected = true
    self.Power.colorPower = true
    self.Power.colorClass = true
    self.Power.colorReaction = true

    self.Power.frequentUpdates = true
    self.Power.Smooth = true

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
    self.Power.bg:SetAlpha(1)
    self.Power.bg.multiplier = 0.4
	
	local health = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallRight')
	health:SetPoint('CENTER', 0, 1)
	self:Tag(health, '[dead][offline( )][afk( )]')
		
	--local power = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmallLeft')
	--power:SetPoint('LEFT', 3, 0)
	--self:Tag(power, '[smartpp]')

	self.Health.name = self.Health:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLeft')
	self.Health.name:SetFont(fontlol, 13, "THINOUTLINE")
	self.Health.name:SetPoint('LEFT', self, 'RIGHT', 5, 1)
	self:Tag(self.Health.name, '[NameMedium][leader( )]')
	
	if gridaggro == true then
      table.insert(self.__elements, UpdateThreat)
      self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateThreat)
      self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UpdateThreat)
      self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UpdateThreat)
    end
	
	self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
    self.LFDRole:SetHeight(6)
    self.LFDRole:SetWidth(6)
	self.LFDRole:SetPoint("TOPLEFT", 2, -2)

	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	
	self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	self.ReadyCheck:SetHeight(12)
	self.ReadyCheck:SetWidth(12)
	self.ReadyCheck:SetPoint('CENTER')

	self.outsideRangeAlpha = raidalphaoor
	self.inRangeAlpha = 1.0
	if showrange == true then
		self.Range = true
	else
		self.Range = false
	end

	self.Health.Smooth = true
end

oUF:RegisterStyle('Party', CreateStyle)
oUF:SetActiveStyle('Party')

--[[
List of the various configuration attributes
======================================================
showRaid = [BOOLEAN] -- true if the header should be shown while in a raid
showParty = [BOOLEAN] -- true if the header should be shown while in a party and not in a raid
showPlayer = [BOOLEAN] -- true if the header should show the player when not in a raid
showSolo = [BOOLEAN] -- true if the header should be shown while not in a group (implies showPlayer)
nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
strictFiltering = [BOOLEAN] - if true, then characters must match both a group and a class from the groupFilter list
point = [STRING] -- a valid XML anchoring point (Default: "TOP")
xOffset = [NUMBER] -- the x-Offset to use when anchoring the unit buttons (Default: 0)
yOffset = [NUMBER] -- the y-Offset to use when anchoring the unit buttons (Default: 0)
sortMethod = ["INDEX", "NAME"] -- defines how the group is sorted (Default: "INDEX")
sortDir = ["ASC", "DESC"] -- defines the sort order (Default: "ASC")
template = [STRING] -- the XML template to use for the unit buttons
templateType = [STRING] - specifies the frame type of the managed subframes (Default: "Button")
groupBy = [nil, "GROUP", "CLASS", "ROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")
maxColumns = [NUMBER] - maximum number of columns the header will create (Default: 1)
unitsPerColumn = [NUMBER or nil] - maximum units that will be displayed in a singe column, nil is infinate (Default: nil)
startingIndex = [NUMBER] - the index in the final sorted unit list at which to start displaying units (Default: 1)
columnSpacing = [NUMBER] - the ammount of space between the rows/columns (Default: 0)
columnAnchorPoint = [STRING] - the anchor point of each new column (ie. use LEFT for the columns to grow to the right)
--]]



local party = oUF:Spawn("header", "oUF_Group")
party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -399)
party:SetAttribute("showParty", true)
--party:SetAttribute("showPlayer", true)
party:SetAttribute("yOffset", -3)
--party:SetAttribute("template", "oUF_cParty")

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











