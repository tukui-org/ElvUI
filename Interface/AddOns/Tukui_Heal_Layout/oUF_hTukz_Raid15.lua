if not TukuiDB["unitframes"].enable == true or TukuiDB["unitframes"].gridonly == true then return end

local fontlol = TukuiDB["media"].uffont
local normTex = TukuiDB["media"].normTex

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
		bar.value:SetText(tukuilocal.unitframes_ouf_deadheal)
	elseif(UnitIsGhost(unit)) then
		bar:SetValue(0)
		bar.value:SetText(tukuilocal.unitframes_ouf_ghostheal)
	elseif(not UnitIsConnected(unit)) then
		bar.value:SetText(tukuilocal.unitframes_disconnected)
	elseif(self:GetParent():GetName():match"oUF_Group") then
		if(d < 100) then
			bar.value:SetText("|cffFFFFFF".."-"..numberize_raid(missing))
		else
			bar.value:SetText(" ")
		end
    end
end

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", ceil(s / hour))
	elseif s >= hour then
		return format("%dh", ceil(s / hour))
	elseif s >= minute then
		return format("%dm", ceil(s / minute))
	elseif s >= minute / 12 then
		return floor(s)
	end
	return format("%.1f", s)
end

local SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(1.25, -1.25)
	return fs
end

local Createauratimer = function(self,elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = FormatTime(self.timeLeft)
				self.remaining:SetText(time)
				self.remaining:SetTextColor(0.84, 0.75, 0.65)
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

local function auraIcon(self, button, icons)
	icons.showDebuffType = true

	button.remaining = SetFontString(button, TukuiDB["media"].font, TukuiDB["unitframes"].auratextscale, "THINOUTLINE")
	button.remaining:SetPoint("CENTER", 0.2, 1)
	
	button.cd.noOCC = true		 	-- hide OmniCC CDs
	button.cd.noCooldownCount = true	-- hide CDC CDs
	button.count:SetFont(TukuiDB["media"].pixelfont, TukuiDB:Scale(10), "THINOUTLINE")
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", 0, 2)
	TukuiDB:SetTemplate(button)
	button.icon:SetPoint("TOPLEFT", TukuiDB:Scale(2), TukuiDB:Scale(-2))
	button.icon:SetPoint("BOTTOMRIGHT", TukuiDB:Scale(-2), TukuiDB:Scale(2))
	button.icon:SetTexCoord(.08, .92, .08, .92)
	button.icon:SetDrawLayer("ARTWORK")
	button.overlay:SetTexture()
		
	if TukuiDB["unitframes"].auraspiral == true then
		icons.disableCooldown = false
		button.cd:SetReverse()
		button.overlayFrame = CreateFrame("frame", nil, button, nil)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", TukuiDB:Scale(2), TukuiDB:Scale(-2))
		button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", TukuiDB:Scale(-2), TukuiDB:Scale(2))
		button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)
		   
		button.overlay:SetParent(button.overlayFrame)
		button.count:SetParent(button.overlayFrame)
		button.remaining:SetParent(button.overlayFrame)
	else
		icons.disableCooldown = true
	end
end

local function updatedebuff(self, icons, unit, icon, index, offset, filter, isDebuff, duration, timeLeft)
	local _, _, _, _, dtype, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)

	if(icon.debuff) then
		local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
		icon:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
		icon.icon:SetDesaturated(false)
	end
	if duration and duration > 0 then
		if TukuiDB["unitframes"].auratimer == true then
			icon.remaining:Show()
		else
			icon.remaining:Hide()
		end
	else
		icon.remaining:Hide()
	end
 
	icon.duration = duration
	icon.timeLeft = expirationTime
	icon.first = true
	icon:SetScript("OnUpdate", Createauratimer)
end

local function UpdateThreat(self, event, unit)
	if (self.unit ~= unit) then
		return
	end
	local threat = UnitThreatSituation(self.unit)
	if (threat == 3) then
		self.Name:SetTextColor(1,0.1,0.1)
	else
		self.Name:SetTextColor(1,1,1)
	end 
end

local function menu(self)
	if(self.unit:match('party')) then
		ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
	end
end

local function CreateStyle(self, unit)

    self.Debuffs = CreateFrame('Frame', nil, self)
    self.Debuffs:SetPoint('LEFT', self, 'RIGHT', 4, 0)
    self.Debuffs:SetHeight(26)
    self.Debuffs:SetWidth(320)
    self.Debuffs.size = 26
    self.Debuffs.spacing = 2
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
	self:SetAttribute('initial-height', TukuiDB:Scale(32*TukuiDB.raidscale))
	self:SetAttribute('initial-width', TukuiDB:Scale(150*TukuiDB.raidscale))

	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetHeight(TukuiDB:Scale(27*TukuiDB.raidscale))
	self.Health:SetStatusBarTexture(normTex)

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
	
	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetPoint("RIGHT", self.Health, -3, 1)
	self.Health.value:SetFont(fontlol, 12*TukuiDB.raidscale, "THINOUTLINE")
	self.Health.value:SetTextColor(1,1,1)
	self.Health.value:SetShadowOffset(1, -1)
		
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(TukuiDB:Scale(4*TukuiDB.raidscale))
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -TukuiDB.mult)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -TukuiDB.mult)
	self.Power:SetStatusBarTexture(normTex)

	self.Power.colorTapping = true
	self.Power.colorDisconnected = true
	self.Power.colorClass = true

	self.Power.frequentUpdates = true
	self.Power.Smooth = true

	self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(normTex)
	self.Power.bg:SetAlpha(1)
	self.Power.bg.multiplier = 0.1
	
	if TukuiDB["unitframes"].classcolor == true then
		self.Power.colorPower = true
		self.Power.bg.multiplier = 0.4
	end
	
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("LEFT", self.Health, 3, 1)
	self.Name:SetFont(fontlol, 12*TukuiDB.raidscale, "THINOUTLINE")
	self.Name:SetShadowOffset(1, -1)
	self:Tag(self.Name, "[NameMedium]")

    self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
    self.Leader:SetHeight(TukuiDB:Scale(12*TukuiDB.raidscale))
    self.Leader:SetWidth(TukuiDB:Scale(12*TukuiDB.raidscale))
    self.Leader:SetPoint("TOPLEFT", 0, 6)

    self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
    self.LFDRole:SetHeight(TukuiDB:Scale(6*TukuiDB.raidscale))
    self.LFDRole:SetWidth(TukuiDB:Scale(6*TukuiDB.raidscale))
	self.LFDRole:SetPoint("TOPRIGHT", TukuiDB:Scale(-2), TukuiDB:Scale(-2))

    self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY")
    self.MasterLooter:SetHeight(TukuiDB:Scale(12*TukuiDB.raidscale))
    self.MasterLooter:SetWidth(TukuiDB:Scale(12*TukuiDB.raidscale))
    local MLAnchorUpdate = function (self)
        if self.Leader:IsShown() then
            self.MasterLooter:SetPoint("TOPLEFT", 12, 6)
        else
            self.MasterLooter:SetPoint("TOPLEFT", 0, 6)
        end
    end
    self:RegisterEvent("PARTY_LEADER_CHANGED", MLAnchorUpdate)
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", MLAnchorUpdate)
	
	if TukuiDB["unitframes"].aggro == true then
      table.insert(self.__elements, UpdateThreat)
      self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateThreat)
      self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UpdateThreat)
      self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UpdateThreat)
    end

	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true

	self.ReadyCheck = self.Power:CreateTexture(nil, "OVERLAY")
	self.ReadyCheck:SetHeight(TukuiDB:Scale(12*TukuiDB.raidscale))
	self.ReadyCheck:SetWidth(TukuiDB:Scale(12*TukuiDB.raidscale))
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
	end
	
    self.PostCreateAuraIcon = auraIcon
	self.PostUpdateHealth = updateHealth
	self.PostUpdateAuraIcon = updatedebuff
end

oUF:RegisterStyle('hRaid15', CreateStyle)
oUF:SetActiveStyle('hRaid15')

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
for i = 1, 3 do
	local raidgroup = oUF:Spawn('header', 'oUF_Group'..i)
	raidgroup:SetManyAttributes('groupFilter', tostring(i), 'showRaid', true, 'yOffset', -4)
	raidgroup:SetFrameStrata('BACKGROUND')	
	table.insert(raid, raidgroup)
	if(i == 1) then
		raidgroup:SetPoint('TOPLEFT', UIParent, 16, -170*TukuiDB.raidscale)
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

			if numraid < 11 or numraid > 15 then
				raidgroup:Hide()
			else
				raidgroup:Show()
			end

	end
end)
end










