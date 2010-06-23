if not TukuiDB["unitframes"].enable == true then return end

local fontlol = TukuiDB["media"].uffont
local normTex = TukuiDB["media"].normTex

local _, class = UnitClass("player")

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

--------------------------------------------------------------------------------------------
-- THE AURAWATCH FUNCTION ITSELF. HERE BE DRAGONS!
--------------------------------------------------------------------------------------------

TukuiDB.countOffsets = {
	TOPLEFT = {6*TukuiDB["unitframes"].gridscale, 1},
	TOPRIGHT = {-6*TukuiDB["unitframes"].gridscale, 1},
	BOTTOMLEFT = {6*TukuiDB["unitframes"].gridscale, 1},
	BOTTOMRIGHT = {-6*TukuiDB["unitframes"].gridscale, 1},
	LEFT = {6*TukuiDB["unitframes"].gridscale, 1},
	RIGHT = {-6*TukuiDB["unitframes"].gridscale, 1},
	TOP = {0, 0},
	BOTTOM = {0, 0},
}

function TukuiDB.auraIcon(self, icon)
	TukuiDB:SetTemplate(icon)
	icon.icon:SetPoint("TOPLEFT", TukuiDB:Scale(1), TukuiDB:Scale(-1))
	icon.icon:SetPoint("BOTTOMRIGHT", TukuiDB:Scale(-1), TukuiDB:Scale(1))
	icon.icon:SetTexCoord(.08, .92, .08, .92)
	icon.icon:SetDrawLayer("ARTWORK")
	if (icon.cd) then
		icon.cd:SetReverse()
	end
	icon.overlay:SetTexture()
end

local _, class = UnitClass("player")
function TukuiDB.createAuraWatch(self, unit)
	local auras = CreateFrame("Frame", nil, self)
	auras:SetPoint("TOPLEFT", self.Health, 2, -2)
	auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.icons = {}
	auras.PostCreateIcon = TukuiDB.auraIcon
	
	if (not TukuiDB["unitframes"].auratimer) then
		auras.hideCooldown = true
	end
	
	local buffs = {}
	local debuffs = TukuiDB.debuffids
	
	if (TukuiDB.buffids["ALL"]) then
		for key, value in pairs(TukuiDB.buffids["ALL"]) do
			tinsert(buffs, value)
		end
	end
	
	if (TukuiDB.buffids[class]) then
		for key, value in pairs(TukuiDB.buffids[class]) do
			tinsert(buffs, value)
		end
	end
	
	-- "Cornerbuffs"
	if (buffs) then
		for key, spell in pairs(buffs) do
			local icon = CreateFrame("Frame", nil, auras)	  
			icon.spellID = spell[1]
			icon.anyUnit = spell[4]
			icon:SetWidth(TukuiDB:Scale(6*TukuiDB["unitframes"].gridscale))
			icon:SetHeight(TukuiDB:Scale(6*TukuiDB["unitframes"].gridscale))
			icon:SetPoint(spell[2], 0, 0)
			
			local tex = icon:CreateTexture(nil, "OVERLAY")
			tex:SetAllPoints(icon)
			tex:SetTexture([=[Interface\AddOns\Tukui\media\textures\blank]=])
			if (spell[3]) then
				tex:SetVertexColor(unpack(spell[3]))
			else
				tex:SetVertexColor(0.8, 0.8, 0.8)
			end
			
			local count = icon:CreateFontString(nil, "OVERLAY")
			count:SetFont(TukuiDB["media"].uffont, 8*TukuiDB["unitframes"].gridscale, "THINOUTLINE")
			count:SetPoint("CENTER", unpack(TukuiDB.countOffsets[spell[2]]))
			icon.count = count
			
			auras.icons[spell[1]] = icon
		end
	end
	
	-- Raid debuffs (Big icon in the middle)
	if (debuffs) then
		 for key, spellID in pairs(debuffs) do
			local icon = CreateFrame("Frame", nil, auras)	  
			icon.spellID = spellID
			icon.anyUnit = true
			icon:SetWidth(TukuiDB:Scale(22*TukuiDB["unitframes"].gridscale))
			icon:SetHeight(TukuiDB:Scale(22*TukuiDB["unitframes"].gridscale))
			icon:SetPoint("CENTER", 0, 0)
			
			local count = icon:CreateFontString(nil, "OVERLAY")
			count:SetFont(TukuiDB["media"].uffont, 9*TukuiDB["unitframes"].gridscale, "THINOUTLINE")
			count:SetPoint("BOTTOMRIGHT", 2, 2)
			icon.count = count
			
			auras.icons[spellID] = icon
		 end
	end
	
	self.AuraWatch = auras
end

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
		self.np:SetBackdropBorderColor(unpack(TukuiDB["media"].altbordercolor))
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

local Menu = function(self)
	FriendsDropDown.unit = self.unit
	FriendsDropDown.id = self.id
	FriendsDropDown.initialize = RaidFrameDropDown_Initialize
	ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
end

local function CreateStyle(self, unit)
		
	self.menu = menu
	self.colors = colors
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self:SetAttribute('*type2', 'menu')
	self:SetAttribute('initial-height', TukuiDB:Scale(50*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale))
	self:SetAttribute('initial-width', TukuiDB:Scale(66*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale))

	self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetHeight(TukuiDB:Scale(28*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale))
	if TukuiDB["unitframes"].gridhealthvertical == true then
		self.Health:SetOrientation('VERTICAL')
	end
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
	self.Health.value:SetPoint("CENTER", self.Health, 0, 1)
	self.Health.value:SetFont(fontlol, 11*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale, "THINOUTLINE")
	self.Health.value:SetTextColor(1,1,1)
	self.Health.value:SetShadowOffset(1, -1)
	
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(3*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale)
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
	
	self.np = CreateFrame("Frame", nameplate, self)
    self.np:SetFrameLevel(3)
    self.np:SetFrameStrata("background")
	self.np:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -TukuiDB.mult)
	self.np:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -TukuiDB.mult)
    self.np:SetPoint("BOTTOM", 0,0)
	self.np:SetBackdrop( {
        bgFile = TukuiDB["media"].blank,
        edgeFile = TukuiDB["media"].blank,
        tile = false, tileSize = 0, edgeSize = TukuiDB.mult,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    self.np:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
    self.np:SetBackdropBorderColor(unpack(TukuiDB["media"].altbordercolor))
				
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("CENTER", self.np, "CENTER", 0, TukuiDB.mult)
	self.Name:SetFont(fontlol, 12*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale)
	self:Tag(self.Name, "[GetNameColor][NameShort]")
		
    if TukuiDB["unitframes"].aggro == true then
		table.insert(self.__elements, UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UpdateThreat)
    else
        self.np:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
    end

	if TukuiDB["unitframes"].showsymbols == true then
		self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon:SetHeight(TukuiDB:Scale(18*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale))
		self.RaidIcon:SetWidth(TukuiDB:Scale(18*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale))
		self.RaidIcon:SetPoint('CENTER', self, 'TOP')
		self.RaidIcon:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcons')	
	end
	
	self.ReadyCheck = self.Power:CreateTexture(nil, "OVERLAY")
	self.ReadyCheck:SetHeight(TukuiDB:Scale(12*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale))
	self.ReadyCheck:SetWidth(TukuiDB:Scale(12*TukuiDB["unitframes"].gridscale*TukuiDB.raidscale))
	self.ReadyCheck:SetPoint('CENTER') 
	
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	
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
	
	self.PostUpdateHealth = updateHealth
	
	if not unit and TukuiDB["unitframes"].raidunitdebuffwatch == true then
		TukuiDB.createAuraWatch(self,unit)
    end

end

oUF:RegisterStyle('hRaid40', CreateStyle)
oUF:SetActiveStyle('hRaid40')

local raid = {}
for i = 1, TukuiDB["unitframes"].gridmaxgroup do
	local raidgroup = oUF:Spawn('header', 'oUF_Group'..i)
	raidgroup:SetManyAttributes('groupFilter', tostring(i), 'showRaid', true, 'xOffset', TukuiDB:Scale(4*TukuiDB["unitframes"].gridscale), "point", "LEFT")
	raidgroup:SetFrameStrata('BACKGROUND')	
	table.insert(raid, raidgroup)
	if(i == 1) then
		raidgroup:SetPoint(TukuiDB["unitframes"].gridposZ, UIParent, TukuiDB["unitframes"].gridposZ, TukuiDB["unitframes"].gridposX, TukuiDB["unitframes"].gridposY*TukuiDB.raidscale)
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
		if TukuiDB["unitframes"].gridonly == true then
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