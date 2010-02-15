if not TukuiUF == true then return end

local mediaPath = [=[Interface\Addons\Tukui\media\]=]

local np

local _, class = UnitClass("player")

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
-- local and aurawatch mwahaha
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


local function createAuraWatch(self,unit)
	local auras = CreateFrame("Frame", nil, self)
    auras:SetAllPoints(self.Health)
	
	local debuffs = spellIDs

    auras.presentAlpha = 1
    auras.missingAlpha = 0
    auras.icons = {}
    
    for i, sid in pairs(debuffs) do
      local icon = CreateFrame("Frame", nil, auras)
      icon.spellID = sid
	  local cd = CreateFrame("Cooldown", nil, icon)
		  cd:SetAllPoints(icon)
		  cd:SetReverse()
		  icon.cd = cd
      if i > 16 then
        icon.anyUnit = true
        icon:SetWidth(24)
        icon:SetHeight(24)
		cd:SetAlpha(0)
		local tex = icon:CreateTexture(nil, "OVERLAY")
		tex:SetAllPoints(icon)
        tex:SetTexture([=[Interface\AddOns\Tukui\media\aurawatch]=])
		tex:SetVertexColor(0.8, 0.8, 0.8)
		icon:SetPoint("CENTER",0,0)
		local count = icon:CreateFontString(nil, "OVERLAY")
        count:SetFont(fontlol, 12, "THINOUTLINE")
        count:SetPoint("CENTER", 6, 1)
        icon.count = count	  
	  else
        icon:SetWidth(8)
        icon:SetHeight(8)
        local tex = icon:CreateTexture(nil, "BACKGROUND")
        tex:SetAllPoints(icon)
        tex:SetTexture([=[Interface\AddOns\Tukui\media\indicator]=])
		if class == "DRUID" then
			if i==1 then
				icon:SetPoint("TOPRIGHT",-1,-1)
				tex:SetVertexColor(200/255,100/255,200/255)
			elseif i==2 then
				icon:SetPoint("BOTTOMLEFT",1,1)
				tex:SetVertexColor(50/255,200/255,50/255)
			elseif i==3 then          
				icon:SetPoint("TOPLEFT", 1, -1)
				tex:SetVertexColor(100/255,200/255,50/255)
				local count = icon:CreateFontString(nil, "OVERLAY")
				count:SetFont(fontlol, 8, "THINOUTLINE")
				count:SetPoint("CENTER", 6, 1)
				icon.count = count
			elseif i==4 then
				  icon:SetPoint("BOTTOMRIGHT", -1, 1)
				  tex:SetVertexColor(200/255,100/255,0/255)
			end
		elseif class == "PRIEST" then
			 if i==5 then
				  icon.anyUnit = true
				  icon:SetPoint("TOPRIGHT",-1,-1)
				  tex:SetVertexColor(0.7, 0.3, 0.7)
			 elseif i==6 then
				  icon:SetPoint("BOTTOMRIGHT", -1, 1)
				  tex:SetVertexColor(0.2, 0.7, 0.2)
				  local count = icon:CreateFontString(nil, "OVERLAY")
				  count:SetFont(fontlol, 8, "THINOUTLINE")
				  count:SetPoint("CENTER", -6, 1)
				  icon.count = count
			 elseif i == 7 then
				  icon:SetPoint("BOTTOMLEFT",1,1)
				  tex:SetVertexColor(0.4, 0.7, 0.2)
			 elseif i == 8 then
				  icon.anyUnit = true
				  icon:SetPoint("TOPLEFT", 1, -1)
				  tex:SetVertexColor(0.7, 0.4, 0)          
			 end
		elseif class == "SHAMAN" then
			 if i==9 then
				  icon:SetPoint("TOPRIGHT",-1,-1)
				  tex:SetVertexColor(0.7, 0.3, 0.7)
			 elseif i==10 then
				  icon:SetPoint("BOTTOMLEFT",1,1)
				  tex:SetVertexColor(0.2, 0.7, 0.2)
			 elseif i==11 then          
				  icon:SetPoint("TOPLEFT", 1, -1)
				  tex:SetVertexColor(0.4, 0.7, 0.2)
			 elseif i==12 then
				  icon:SetPoint("BOTTOMRIGHT", -1, 1)
				  tex:SetVertexColor(0.7, 0.4, 0)
			 end
		elseif class == "PALADIN" then
			 if i==13 then
				  icon:SetPoint("TOPRIGHT",-1,-1)
				  tex:SetVertexColor(0.7, 0.3, 0.7)
			 elseif i==14 then          
				  icon:SetPoint("TOPLEFT", 1, -1)
				  tex:SetVertexColor(0.4, 0.7, 0.2)
			 end
		end
		if i==15 then
			 icon:SetPoint("RIGHT", -1, 0)
			 tex:SetVertexColor(0, 1, 0)
		elseif i==16 then
			 icon:SetPoint("LEFT", 1, 0)
			 tex:SetVertexColor(1, 0, 0)
		end
	  end
      auras.icons[sid] = icon
    end
    self.AuraWatch = auras
end

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

local function UpdateThreat(self, event, unit)
	   if (self.unit ~= unit) then
		  return
	   end
		  local threat = UnitThreatSituation(self.unit)
		  if (threat == 3) then
			self.np:SetBackdropBorderColor(1,0.1,0.1,1)
		  else
			self.np:SetBackdropBorderColor(0.6,0.6,0.6,1)
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

local function menu(self)
	if(self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	end
end

local function CreateStyle(self, unit)
		
	self.menu = menu
	self.colors = colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self:SetAttribute('*type2', 'menu')
	self:SetAttribute('initial-height', 40)
	self:SetAttribute('initial-width', 55)

	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, left = -1, bottom = -1, right = -1}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetHeight(22)
	if gridhealthvertical == true then
		self.Health:SetOrientation('VERTICAL')
	end
	self.Health:SetStatusBarTexture(normTex)
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	 

	self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	self.Health.bg:SetTexture(0.3, 0.3, 0.3)
	self.Health.bg.multiplier = (0.3)
		
	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetPoint("CENTER", self.Health, 0, 1)
	self.Health.value:SetFont(fontlol, 11, "THINOUTLINE")
	self.Health.value:SetTextColor(1,1,1)
	self.Health.value:SetShadowOffset(1, -1)
	
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
	self.Power.bg:SetTexture(normTex)
	self.Power.bg:SetAlpha(1)
	self.Power.bg.multiplier = 0.4
	
	self.np = CreateFrame("Frame", nameplate, self)
    self.np:SetFrameLevel(3)
    self.np:SetFrameStrata("background")
    self.np:SetHeight(13)
    self.np:SetWidth(55)
    self.np:SetPoint("BOTTOM", 0,0)
    self.np:SetScale(1)
	self.np:SetBackdrop( {
        bgFile = BLANK_TEXTURE,
        edgeFile = BLANK_TEXTURE,
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    self.np:SetBackdropColor(0.1,0.1,0.1,1)
    self.np:SetBackdropBorderColor(0.6,0.6,0.6,1)
				
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("CENTER", self.np, 0, 1)
    self.Name:SetJustifyH("CENTER")
	self.Name:SetFont(fontlol, 10)
	self.Name:SetShadowOffset(1, -1)
	self:Tag(self.Name, "[GetNameColor][NameShort]")
		
    if gridaggro == true then
		table.insert(self.__elements, UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UpdateThreat)
    else
        np:SetBackdropBorderColor(0.6,0.6,0.6,1)
    end

	if showsymbols == true then
		self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetHeight(18)
		self.RaidIcon:SetWidth(18)
		self.RaidIcon:SetPoint('CENTER', self, 'TOP')
		self.RaidIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')	
	end
	
	self.ReadyCheck = self.Power:CreateTexture(nil, "OVERLAY")
	self.ReadyCheck:SetHeight(12)
	self.ReadyCheck:SetWidth(12)
	self.ReadyCheck:SetPoint('CENTER') 
	
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	
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
	
	self.PostUpdateHealth = updateHealth
	
	if not unit and raidunitdebuffwatch == true then
		createAuraWatch(self,unit)
    end

end

oUF:RegisterStyle('hRaid40', CreateStyle)
oUF:SetActiveStyle('hRaid40')

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
for i = 1, 8 do
	local raidgroup = oUF:Spawn('header', 'oUF_Group'..i)
	raidgroup:SetManyAttributes('groupFilter', tostring(i), 'showRaid', true, 'xOffset', 4, "point", "LEFT")
	raidgroup:SetFrameStrata('BACKGROUND')	
	table.insert(raid, raidgroup)
	if(i == 1) then
		raidgroup:SetPoint(gridposZ, UIParent, gridposZ, gridposX, gridposY)
	else
		raidgroup:SetPoint('TOPLEFT', raid[i-1], 'BOTTOMLEFT', 0, -4)
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
		if gridonly == true then
			if numraid < 6 then
				raidgroup:Hide()
			else
				raidgroup:Show()
			end
		else
			if numraid < 16 then --16
				raidgroup:Hide()
			else
				raidgroup:Show()
			end
		end
	end
end)
end










