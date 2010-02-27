if not TukuiUF == true then return end

if gridonly == true then return end

local mediaPath = [=[Interface\Addons\Tukui\media\]=]

local fontlol = [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=]
local normTex = mediaPath..[=[normTex]=]
local glowTex = mediaPath..[=[glowTex]=]
local bubbleTex = mediaPath..[=[bubbleTex]=]
local buttonTex = mediaPath..[=[buttonTex]=]
local highlightTex = mediaPath..[=[highlightTex]=]
local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = -2, left = -2, bottom = -2, right = -2},
}

------------------------------------------------------------------------
--	Colors
------------------------------------------------------------------------

local colors = setmetatable({
	power = setmetatable({
		["MANA"] = {0.31, 0.45, 0.63},
		["RAGE"] = {0.69, 0.31, 0.31},
		["FOCUS"] = {0.71, 0.43, 0.27},
		["ENERGY"] = {0.65, 0.63, 0.35},
		["RUNES"] = {0.55, 0.57, 0.61},
		["RUNIC_POWER"] = {0, 0.82, 1},
		["AMMOSLOT"] = {0.8, 0.6, 0},
		["FUEL"] = {0, 0.55, 0.5},
		["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
		["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
	}, {__index = oUF.colors.power}),
	happiness = setmetatable({
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	}, {__index = oUF.colors.happiness}),
	runes = setmetatable({
		[1] = {0.69, 0.31, 0.31},
		[2] = {0.33, 0.59, 0.33},
		[3] = {0.31, 0.45, 0.63},
		[4] = {0.84, 0.75, 0.65},
	}, {__index = oUF.colors.runes}),
}, {__index = oUF.colors})

oUF.colors.tapped = {0.55, 0.57, 0.61}
oUF.colors.disconnected = {0.84, 0.75, 0.65}

oUF.colors.smooth = {0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.15, 0.15, 0.15}

-- ------------------------------------------------------------------------
-- local horror
-- ------------------------------------------------------------------------
local select = select
local UnitClass = UnitClass
local UnitIsDead = UnitIsDead
local UnitIsPVP = UnitIsPVP
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification
local UnitReactionColor = UnitReactionColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- ------------------------------------------------------------------------
-- reformat everything above 999 in raidframes
-- ------------------------------------------------------------------------
local numberize_raid = function(v)
	if v <= 999 then return v end
	if v >= 1000000 then
		local value = string.format("%.1fm", v/1000000)
		return value
	elseif v >= 1000 then
		local value = string.format("%.1fk", v/1000)
		return value
	end
end

local updateHealth = function(self, event, unit, bar, min, max)  
    local cur, maxhp = min, max
    local missing = maxhp-cur
    
    local d = floor(cur/maxhp*100)
    
	if(UnitIsDead(unit)) then
		bar:SetValue(0)
		bar.value:SetText(ouf_deadheal)
	elseif(UnitIsGhost(unit)) then
		bar:SetValue(0)
		bar.value:SetText(ouf_ghostheal)
	elseif(not UnitIsConnected(unit)) then
		bar.value:SetText"D/C"

	elseif(self:GetParent():GetName():match"oUF_Group") then
		if(d < 100) then
			bar.value:SetText("|cffFFFFFF".."-"..numberize_raid(missing))
		else
			bar.value:SetText(" ")
		end
    end
end

local function auraIcon(self, icon, icons, index, debuff)
		icons.showDebuffType = true		-- show debuff border type color 
		icon.cd.noOCC = true		 	-- hide OmniCC CDs
		icon.cd.noCooldownCount = true	-- hide CDC CDs
		icons.disableCooldown = true	-- hide CD spiral
		
		icon.count:SetPoint("BOTTOMRIGHT", -3, 5)
		icon.count:SetJustifyH("RIGHT")
		icon.count:SetFont(fontlol, 11, "THINOUTLINE")
		icon.count:SetTextColor(0.84, 0.75, 0.65)
				
		icon.icon:SetTexCoord(.07, .93, .07, .93)
		icon.icon:SetPoint("TOPLEFT", icon, "TOPLEFT", 2, -2)
		icon.icon:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
		
		icon.overlay:SetTexture(buttonTex)		
		icon.overlay:SetTexCoord(0,1,0,1)
		icon.overlay.Hide = function(self) self:SetVertexColor(TUKUI_BORDER_COLOR[1], TUKUI_BORDER_COLOR[2], TUKUI_BORDER_COLOR[3]) end
end

local function menu(self)
	if(self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	end
end


local function CreateStyle(self, unit)

    self.Debuffs = CreateFrame('Frame', nil, self)
    self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMRIGHT', 5, 31.5)
    self.Debuffs:SetHeight(32 * 1)
    self.Debuffs:SetWidth(320)
    self.Debuffs.size = 32 * 1
    self.Debuffs.spacing = 0
    self.Debuffs.initialAnchor = 'LEFT'
    self.Debuffs.showDebuffType = true
	self.Debuffs.num = 5
	self.Debuffs.numBuffs = 5
	self.Debuffs.numDebuffs = 5



	self.menu = menu
	self.colors = colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self:SetAttribute('*type2', 'menu')
	self:SetAttribute('initial-height', 32)
	self:SetAttribute('initial-width', 150)

	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, left = -1, bottom = -1, right = -1}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetHeight(27)
	self.Health:SetStatusBarTexture(normTex)
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorClassPet = true
	self.Health.colorReaction = true

	self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	self.Health.bg:SetTexture(0.3, 0.3, 0.3)
	self.Health.bg.multiplier = (0.3)
	
	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetPoint("RIGHT", self.Health, -3, 1)
	self.Health.value:SetFont(fontlol, 12, "THINOUTLINE")
	self.Health.value:SetTextColor(1,1,1)
	self.Health.value:SetShadowOffset(1, -1)
	
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(4)
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
	self.Power.bg:SetTexture(normTex)
	self.Power.bg:SetAlpha(1)
	self.Power.bg.multiplier = 0.4

	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("LEFT", self.Health, 3, 1)
	self.Name:SetFont(fontlol, 12, "THINOUTLINE")
	self.Name:SetShadowOffset(1, -1)
	self:Tag(self.Name, "[NameMedium]")
	
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	
	self.ReadyCheck = self.Power:CreateTexture(nil, "OVERLAY")
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

	if showsmooth == true then
		self.Health.Smooth = true
	end
	
    self.PostCreateAuraIcon = auraIcon
	self.PostUpdateHealth = updateHealth


end

oUF:RegisterStyle('hRaid10', CreateStyle)
oUF:SetActiveStyle('hRaid10')

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
local raid = {}
for i = 1, 2 do
	local raidgroup = oUF:Spawn('header', 'oUF_Group'..i)
	raidgroup:SetManyAttributes('groupFilter', tostring(i), 'showRaid', true, 'yOffset', -4)
	raidgroup:SetFrameStrata('BACKGROUND')	
	table.insert(raid, raidgroup)
	if(i == 1) then
		raidgroup:SetPoint('TOPLEFT', UIParent, 15, -260)
	else
		raidgroup:SetPoint('TOP', raid[i-1], 'BOTTOM', 0, -15)
	end
	local raidToggle = CreateFrame("Frame")
	raidToggle:RegisterEvent("PLAYER_LOGIN")
	raidToggle:RegisterEvent("RAID_ROSTER_UPDATE")
	raidToggle:RegisterEvent("PARTY_LEADER_CHANGED")
	raidToggle:RegisterEvent("PARTY_MEMBERS_CHANGED")
	raidToggle:SetScript("OnEvent", function(self)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		local numraid = GetNumRaidMembers()
		--if gridonly == true then
			--raidgroup:Hide()
		--else
			if numraid < 6 or numraid > 10 then
				raidgroup:Hide()
			else
				raidgroup:Show()
			end
		--end
	end
end)
end










