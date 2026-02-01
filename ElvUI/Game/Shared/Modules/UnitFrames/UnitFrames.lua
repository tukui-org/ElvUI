local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local NP = E:GetModule('NamePlates')
local PA = E:GetModule('PrivateAuras')
local TT = E:GetModule('Tooltip')
local LSM = E.Libs.LSM
local ElvUF = E.oUF

local _G = _G
local hooksecurefunc = hooksecurefunc
local wipe, type, unpack, assert, tostring = wipe, type, unpack, assert, tostring
local huge, strfind, gsub, format, strjoin, strmatch = math.huge, strfind, gsub, format, strjoin, strmatch
local pcall, min, next, pairs, ipairs, tinsert, strsub = pcall, min, next, pairs, ipairs, tinsert, strsub

local CreateColor = CreateColor
local GameTooltip = GameTooltip
local CreateFrame = CreateFrame
local PlaySound = PlaySound
local UIParent = UIParent
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local GetInstanceInfo = GetInstanceInfo
local GetInventorySlotInfo = GetInventorySlotInfo
local GetInventoryItemLink = GetInventoryItemLink
local UnregisterStateDriver = UnregisterStateDriver
local RegisterStateDriver = RegisterStateDriver

local CastingBarFrame_OnLoad = CastingBarFrame_OnLoad
local CastingBarFrame_SetUnit = CastingBarFrame_SetUnit
local PetCastingBarFrame_OnLoad = PetCastingBarFrame_OnLoad
local CompactRaidFrameManager_SetSetting = CompactRaidFrameManager_SetSetting

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local IsReplacingUnit = IsReplacingUnit or C_PlayerInteractionManager.IsReplacingUnit

local SELECT_AGGRO = SOUNDKIT.IG_CREATURE_AGGRO_SELECT
local SELECT_NPC = SOUNDKIT.IG_CHARACTER_NPC_SELECT
local SELECT_NEUTRAL = SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT
local SELECT_LOST = SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT

local POWERTYPE_ALTERNATE = Enum.PowerType.Alternate or 10
local CURVE_RED = CreateColor(1, 0, 0)
local CURVE_YELLOW = CreateColor(1, 1, 0)
local CURVE_HEALTH = {}

-- GLOBALS: Arena_LoadUI

UF.headerstoload = {}
UF.unitgroupstoload = {}
UF.unitstoload = {}

UF.groupPrototype = {}
UF.headerPrototype = {}
UF.headers = {}
UF.groupunits = {}
UF.units = {}

UF.classbars = {}
UF.statusbars = {}
UF.fontstrings = {}
UF.badHeaderPoints = {
	TOP = 'BOTTOM',
	LEFT = 'RIGHT',
	BOTTOM = 'TOP',
	RIGHT = 'LEFT',
}

UF.headerFunctions = {}
UF.classMaxResourceBar = { -- also used by Nameplates
	DEATHKNIGHT = 6,
	SHAMAN = E.Retail and 10 or nil,
	PALADIN = 5,
	WARLOCK = 5,
	EVOKER = 6,
	MONK = 6,
	MAGE = 4,
	ROGUE = 7,
	DRUID = 5,
	PRIEST = 3
}

function UF:GetAuraSortTime(which, a, b)
	return a.noTime and huge or a[which] or -huge, b.noTime and huge or b[which] or -huge
end

function UF:GetAuraSortValue(dir, A, B)
	if dir == 'DESCENDING' then return A < B else return A > B end
end

function UF:GetAuraSortDirection(dir, a, b, A, B)
	if A == B then
		return UF:GetAuraSortValue(dir, a.auraInstanceID or 0, b.auraInstanceID or 0)
	else -- we sort by Aura Instance ID if they match priority
		return UF:GetAuraSortValue(dir, A, B)
	end
end

UF.SortAuraFuncs = {
	TIME_REMAINING = function(a, b, dir)
		return UF:GetAuraSortDirection(dir, a, b, UF:GetAuraSortTime('expiration', a, b))
	end,
	DURATION = function(a, b, dir)
		return UF:GetAuraSortDirection(dir, a, b, UF:GetAuraSortTime('duration', a, b))
	end,
	NAME = function(a, b, dir)
		return UF:GetAuraSortDirection(dir, a, b, a.name or '', b.name or '')
	end,
	PLAYER = function(a, b, dir)
		return UF:GetAuraSortDirection(dir, a, b, a.isPlayer and 1 or 0, b.isPlayer and 1 or 0)
	end,
	INDEX = function(a, b, dir)
		return UF:GetAuraSortValue(dir, a.auraInstanceID or 0, b.auraInstanceID or 0)
	end
}

UF.headerGroupBy = {
	CLASS = function(header)
		local groupingOrder = header.db and strjoin(',', header.db.CLASS1, header.db.CLASS2, header.db.CLASS3, header.db.CLASS4, header.db.CLASS5, header.db.CLASS6, header.db.CLASS7, header.db.CLASS8, header.db.CLASS9)
		if E.Retail and groupingOrder then
			groupingOrder = groupingOrder..strjoin(',', header.db.CLASS10, header.db.CLASS11, header.db.CLASS12, header.db.CLASS13)
		end

		local sortMethod = header.db and header.db.sortMethod
		header:SetAttribute('groupingOrder', groupingOrder or 'DEATHKNIGHT,DEMONHUNTER,DRUID,EVOKER,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK')
		header:SetAttribute('sortMethod', sortMethod or 'NAME')
		header:SetAttribute('groupBy', 'CLASS')
	end,
	ROLE = function(header)
		local groupingOrder = header.db and strjoin(',', header.db.ROLE1, header.db.ROLE2, header.db.ROLE3, 'NONE')
		local sortMethod = header.db and header.db.sortMethod
		header:SetAttribute('groupingOrder', groupingOrder or 'TANK,HEALER,DAMAGER,NONE')
		header:SetAttribute('sortMethod', sortMethod or 'NAME')
		header:SetAttribute('groupBy', 'ASSIGNEDROLE')
	end,
	NAME = function(header)
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute('groupBy', nil)
	end,
	GROUP = function(header)
		local sortMethod = header.db and header.db.sortMethod
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', sortMethod or 'INDEX')
		header:SetAttribute('groupBy', 'GROUP')
	end,
	PETNAME = function(header)
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute('groupBy', nil)
		header:SetAttribute('filterOnPet', true) --This is the line that matters. Without this, it sorts based on the owners name
	end,
	INDEX = function(header)
		header:SetAttribute('groupingOrder', '1,2,3,4,5,6,7,8')
		header:SetAttribute('sortMethod', 'INDEX')
		header:SetAttribute('groupBy', nil)
	end,
}

local POINT_COLUMN_ANCHOR_TO_DIRECTION = {
	TOPTOP = 'UP_RIGHT',
	BOTTOMBOTTOM = 'TOP_RIGHT',
	LEFTLEFT = 'RIGHT_UP',
	RIGHTRIGHT = 'LEFT_UP',
	RIGHTTOP = 'LEFT_DOWN',
	LEFTTOP = 'RIGHT_DOWN',
	LEFTBOTTOM = 'RIGHT_UP',
	RIGHTBOTTOM = 'LEFT_UP',
	BOTTOMRIGHT = 'UP_LEFT',
	BOTTOMLEFT = 'UP_RIGHT',
	TOPRIGHT = 'DOWN_LEFT',
	TOPLEFT = 'DOWN_RIGHT'
}

local DIRECTION_TO_POINT = {
	DOWN_RIGHT = 'TOP',
	DOWN_LEFT = 'TOP',
	UP_RIGHT = 'BOTTOM',
	UP_LEFT = 'BOTTOM',
	RIGHT_DOWN = 'LEFT',
	RIGHT_UP = 'LEFT',
	LEFT_DOWN = 'RIGHT',
	LEFT_UP = 'RIGHT',
	UP = 'BOTTOM',
	DOWN = 'TOP'
}

local DIRECTION_TO_GROUP_ANCHOR_POINT = {
	DOWN_RIGHT = 'TOPLEFT',
	DOWN_LEFT = 'TOPRIGHT',
	UP_RIGHT = 'BOTTOMLEFT',
	UP_LEFT = 'BOTTOMRIGHT',
	RIGHT_DOWN = 'TOPLEFT',
	RIGHT_UP = 'BOTTOMLEFT',
	LEFT_DOWN = 'TOPRIGHT',
	LEFT_UP = 'BOTTOMRIGHT',
	OUT_RIGHT_UP = 'BOTTOM',
	OUT_LEFT_UP = 'BOTTOM',
	OUT_RIGHT_DOWN = 'TOP',
	OUT_LEFT_DOWN = 'TOP',
	OUT_UP_RIGHT = 'LEFT',
	OUT_UP_LEFT = 'RIGHT',
	OUT_DOWN_RIGHT = 'LEFT',
	OUT_DOWN_LEFT = 'RIGHT',
}

local INVERTED_DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	DOWN_RIGHT = 'RIGHT',
	DOWN_LEFT = 'LEFT',
	UP_RIGHT = 'RIGHT',
	UP_LEFT = 'LEFT',
	RIGHT_DOWN = 'BOTTOM',
	RIGHT_UP = 'TOP',
	LEFT_DOWN = 'BOTTOM',
	LEFT_UP = 'TOP',
	UP = 'TOP',
	DOWN = 'BOTTOM'
}

local DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	DOWN_RIGHT = 'LEFT',
	DOWN_LEFT = 'RIGHT',
	UP_RIGHT = 'LEFT',
	UP_LEFT = 'RIGHT',
	RIGHT_DOWN = 'TOP',
	RIGHT_UP = 'BOTTOM',
	LEFT_DOWN = 'TOP',
	LEFT_UP = 'BOTTOM',
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1,
}

function UF:ConvertGroupDB(group)
	local db = UF.db.units[group.groupName]
	if db.point and db.columnAnchorPoint then
		db.growthDirection = POINT_COLUMN_ANCHOR_TO_DIRECTION[db.point..db.columnAnchorPoint]
		db.point = nil
		db.columnAnchorPoint = nil
	end

	if db.growthDirection == 'UP' or db.growthDirection == 'DOWN' then
		db.growthDirection = db.growthDirection..'_RIGHT'
	end
end

function UF:ResetAuraPriority()
	for unitName, content in pairs(E.db.unitframe.units) do
		local default = P.unitframe.units[unitName]
		if default then
			if content.buffs then
				content.buffs.priority = default.buffs.priority
			end
			if content.debuffs then
				content.debuffs.priority = default.debuffs.priority
			end
			if content.aurabar then
				content.aurabar.priority = default.aurabar.priority
			end
		end
	end
end

function UF:ResetFilters(includeIndicators, resetPriority) -- keep similar to with resetFilter in Filters.lua of Options
	if includeIndicators then
		E.global.unitframe.AuraBarColors = E:CopyTable({}, G.unitframe.AuraBarColors)
		E.global.unitframe.AuraHighlightColors = E:CopyTable({}, G.unitframe.AuraHighlightColors)

		for name in next, E.global.unitframe.aurawatch do
			local default = G.unitframe.aurawatch[name]
			E.global.unitframe.aurawatch[name] = (default and E:CopyTable({}, default)) or nil
		end

		for name in next, E.db.unitframe.filters.aurawatch do -- profile specific
			local default = P.unitframe.filters.aurawatch[name]
			E.db.unitframe.filters.aurawatch[name] = (default and E:CopyTable({}, default)) or nil
		end
	end

	if resetPriority then
		UF:ResetAuraPriority()
		NP:ResetAuraPriority()
	end

	for name, data in next, E.global.unitframe.aurafilters do
		local default = G.unitframe.aurafilters[name]
		if default then
			data.type = default.type
			data.spells = E:CopyTable({}, default.spells)
		else -- not a default filter, delete it
			E.global.unitframe.aurafilters[name] = nil
		end
	end
end

function UF:CreateRaisedText(RaisedElement)
	local text = RaisedElement:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(text)

	return text
end

function UF:CreateRaisedElement(frame)
	local RaisedElement = CreateFrame('Frame', '$parent_RaisedElement', frame)
	local RaisedLevel = frame:GetFrameLevel() + 100

	RaisedElement:SetAllPoints()
	RaisedElement:SetFrameLevel(RaisedLevel)

	RaisedElement.TextureParent = CreateFrame('Frame', '$parent_TextureParent', RaisedElement)
	RaisedElement.frameName = RaisedElement:GetName()
	RaisedElement.__owner = frame

	-- layer levels (level +1 is icons)
	RaisedElement.AuraLevel = RaisedLevel
	RaisedElement.PrivateAurasLevel = RaisedLevel + 5
	RaisedElement.PVPSpecLevel = RaisedLevel + 10
	RaisedElement.AuraBarLevel = RaisedLevel + 15
	RaisedElement.RaidDebuffLevel = RaisedLevel + 20
	RaisedElement.AuraWatchLevel = RaisedLevel + 25
	RaisedElement.RestingIconLevel = RaisedLevel + 30
	RaisedElement.RaidRoleLevel = RaisedLevel + 35
	RaisedElement.CastBarLevel = RaisedLevel + 40

	return RaisedElement
end

function UF:SetAlpha_MouseTags(mousetags, alpha)
	if not mousetags then return end
	for fs in next, mousetags do
		fs:SetAlpha(alpha)
	end
end

function UF:UnitFrame_OnEnter()
	if GameTooltip:IsForbidden() then
		self.UpdateTooltip = nil
	else
		_G.GameTooltip_SetDefaultAnchor(GameTooltip, self)

		self.UpdateTooltip = (E:NotSecretValue(self.unit) and self.unit and GameTooltip:SetUnit(self.unit) and UF.UnitFrame_OnEnter) or nil
	end

	UF:SetAlpha_MouseTags(self.__mousetags, 1)
end

function UF:UnitFrame_OnLeave()
	self.UpdateTooltip = nil

	if not GameTooltip:IsForbidden() then
		if not E.private.tooltip.enable or TT.db.fadeOut then
			GameTooltip:FadeOut()
		else
			GameTooltip:Hide()
		end
	end

	UF:SetAlpha_MouseTags(self.__mousetags, 0)
end

function UF:Construct_UF(frame, unit)
	frame.SHADOW_SPACING = 3
	frame.CLASSBAR_YOFFSET = 0 -- placeholder
	frame.BOTTOM_OFFSET = 0 -- placeholder

	if not UF.groupunits[unit] then
		UF['Construct_'..gsub(E:StringTitle(unit), 't(arget)', 'T%1')..'Frame'](UF, frame, unit)
	else
		UF['Construct_'..E:StringTitle(UF.groupunits[unit])..'Frames'](UF, frame, unit) -- arena and boss only
	end

	return frame
end

function UF:GetObjectAnchorPoint(frame, point, ignoreShown)
	if point == 'Frame' then
		return frame
	end

	local place = frame[point]
	if place and (ignoreShown or place:IsShown()) then
		return place
	else
		return frame
	end
end

function UF:GetPositionOffset(position, offset)
	if not offset then offset = 2 end
	local x, y = 0, 0
	if strfind(position, 'LEFT') then
		x = offset
	elseif strfind(position, 'RIGHT') then
		x = -offset
	end

	if strfind(position, 'TOP') then
		y = -offset
	elseif strfind(position, 'BOTTOM') then
		y = offset
	end

	return x, y
end

function UF:GetAuraOffset(p1, p2)
	local x, y = 0, 0
	if p1 == 'RIGHT' and p2 == 'LEFT' then
		x = -3
	elseif p1 == 'LEFT' and p2 == 'RIGHT' then
		x = 3
	end

	if strfind(p1, 'TOP') and strfind(p2, 'BOTTOM') then
		y = -1
	elseif strfind(p1, 'BOTTOM') and strfind(p2, 'TOP') then
		y = 1
	end

	return x, y
end

function UF:GetAuraAnchorFrame(frame, attachTo)
	if attachTo == 'FRAME' then
		return frame
	elseif attachTo == 'AURAS' and frame.Auras then
		return frame.Auras
	elseif attachTo == 'BUFFS' and frame.Buffs then
		return frame.Buffs
	elseif attachTo == 'DEBUFFS' and frame.Debuffs then
		return frame.Debuffs
	elseif attachTo == 'HEALTH' and frame.Health then
		return frame.Health
	elseif attachTo == 'POWER' and frame.Power then
		return frame.Power
	elseif attachTo == 'TRINKET' and (frame.Trinket or frame.PVPSpecIcon) then
		local _, instanceType = GetInstanceInfo()
		return (instanceType == 'arena' and frame.Trinket) or frame.PVPSpecIcon
	else
		return frame
	end
end

function UF:UpdateColors()
	local db = UF.db.colors

	ElvUF.colors.tapped = E:SetColorTable(ElvUF.colors.tapped, db.tapped)
	ElvUF.colors.disconnected = E:SetColorTable(ElvUF.colors.disconnected, db.disconnected)
	ElvUF.colors.health = E:SetColorTable(ElvUF.colors.health, db.health)

	ElvUF.colors.power.MANA = E:SetColorTable(ElvUF.colors.power.MANA, db.power.MANA)
	ElvUF.colors.power.RAGE = E:SetColorTable(ElvUF.colors.power.RAGE, db.power.RAGE)
	ElvUF.colors.power.FOCUS = E:SetColorTable(ElvUF.colors.power.FOCUS, db.power.FOCUS)
	ElvUF.colors.power.ENERGY = E:SetColorTable(ElvUF.colors.power.ENERGY, db.power.ENERGY)
	ElvUF.colors.power.RUNIC_POWER = E:SetColorTable(ElvUF.colors.power.RUNIC_POWER, db.power.RUNIC_POWER)
	ElvUF.colors.power.PAIN = E:SetColorTable(ElvUF.colors.power.PAIN, db.power.PAIN)
	ElvUF.colors.power.FURY = E:SetColorTable(ElvUF.colors.power.FURY, db.power.FURY)
	ElvUF.colors.power.LUNAR_POWER = E:SetColorTable(ElvUF.colors.power.LUNAR_POWER, db.power.LUNAR_POWER)
	ElvUF.colors.power.INSANITY = E:SetColorTable(ElvUF.colors.power.INSANITY, db.power.INSANITY)
	ElvUF.colors.power.MAELSTROM = E:SetColorTable(ElvUF.colors.power.MAELSTROM, db.power.MAELSTROM)

	ElvUF.colors.power.SHADOW_ORBS = E:SetColorTable(ElvUF.colors.power.SHADOW_ORBS, db.classResources.PRIEST)
	ElvUF.colors.power.HOLY_POWER = E:SetColorTable(ElvUF.colors.power.HOLY_POWER, db.classResources.PALADIN)

	ElvUF.colors.power[POWERTYPE_ALTERNATE] = E:SetColorTable(ElvUF.colors.power[POWERTYPE_ALTERNATE], db.power.ALT_POWER)
	ElvUF.colors.chargedComboPoint = E:SetColorTable(ElvUF.colors.chargedComboPoint, db.classResources.chargedComboPoint)

	for i = 0, 3 do
		ElvUF.colors.threat[i] = E:SetColorTable(ElvUF.colors.threat[i], db.threat[i])
	end

	for i = 1, 3 do
		ElvUF.colors.happiness[i] = E:SetColorTable(ElvUF.colors.happiness[i], db.happiness[i])
	end

	for i = 1, 8 do
		ElvUF.colors.reaction[i] = E:SetColorTable(ElvUF.colors.reaction[i], db.reaction[i])
	end

	for i = 0, 9 do
		if i ~= 4 then -- selection doesnt have 4 and skips to 13
			ElvUF.colors.selection[i] = E:SetColorTable(ElvUF.colors.selection[i], db.selection[i])
		end
	end
	ElvUF.colors.selection[13] = E:SetColorTable(ElvUF.colors.selection[13], db.selection[13])

	if not ElvUF.colors.ComboPoints then
		ElvUF.colors.ComboPoints = {}
	end

	for i = 1, 7 do
		ElvUF.colors.ComboPoints[i] = E:SetColorTable(ElvUF.colors.ComboPoints[i], db.classResources.comboPoints[i])
	end

	if not ElvUF.colors.empoweredCast then
		ElvUF.colors.empoweredCast = {}
	end

	for i in next, P.unitframe.colors.empoweredCast do
		ElvUF.colors.empoweredCast[i] = E:SetColorTable(ElvUF.colors.empoweredCast[i], db.empoweredCast[i])
	end

	-- Evoker, Monk, Mage, Paladin and Warlock, Death Knight
	if not ElvUF.colors.ClassBars then ElvUF.colors.ClassBars = {} end
	ElvUF.colors.ClassBars.PALADIN = E:SetColorTable(ElvUF.colors.ClassBars.PALADIN, db.classResources.PALADIN)
	ElvUF.colors.ClassBars.PRIEST = E:SetColorTable(ElvUF.colors.ClassBars.PRIEST, db.classResources.PRIEST)

	if not ElvUF.colors.ClassBars.EVOKER then ElvUF.colors.ClassBars.EVOKER = {} end
	ElvUF.colors.ClassBars.EVOKER.EBON_MIGHT = E:SetColorTable(ElvUF.colors.ClassBars.EVOKER.EBON_MIGHT, db.classResources.EVOKER.EBON_MIGHT)

	if not ElvUF.colors.ClassBars.MONK then ElvUF.colors.ClassBars.MONK = {} end
	if not ElvUF.colors.ClassBars.EVOKER.ESSENCE then ElvUF.colors.ClassBars.EVOKER.ESSENCE = {} end
	for i = 1, 6 do
		ElvUF.colors.ClassBars.EVOKER.ESSENCE[i] = E:SetColorTable(ElvUF.colors.ClassBars.EVOKER.ESSENCE[i], db.classResources.EVOKER.ESSENCE[i])
		ElvUF.colors.ClassBars.MONK[i] = E:SetColorTable(ElvUF.colors.ClassBars.MONK[i], db.classResources.MONK[i])
	end

	if not ElvUF.colors.ClassBars.SHAMAN then ElvUF.colors.ClassBars.SHAMAN = {} end
	ElvUF.colors.ClassBars.SHAMAN.MAELSTROM = E:SetColorTable(ElvUF.colors.ClassBars.SHAMAN.MAELSTROM, db.classResources.SHAMAN.MAELSTROM)

	if not ElvUF.colors.ClassBars.MAGE then ElvUF.colors.ClassBars.MAGE = {} end
	ElvUF.colors.ClassBars.MAGE.FROST_ICICLES = E:SetColorTable(ElvUF.colors.ClassBars.MAGE.FROST_ICICLES, db.classResources.MAGE.FROST_ICICLES)
	ElvUF.colors.ClassBars.MAGE.ARCANE_CHARGES = E:SetColorTable(ElvUF.colors.ClassBars.MAGE.ARCANE_CHARGES, db.classResources.MAGE.ARCANE_CHARGES)

	if not ElvUF.colors.ClassBars.DEMONHUNTER then ElvUF.colors.ClassBars.DEMONHUNTER = {} end
	ElvUF.colors.ClassBars.DEMONHUNTER.SOUL_FRAGMENTS = E:SetColorTable(ElvUF.colors.ClassBars.DEMONHUNTER.SOUL_FRAGMENTS, db.classResources.DEMONHUNTER.SOUL_FRAGMENTS)

	if not ElvUF.colors.ClassBars.WARLOCK then ElvUF.colors.ClassBars.WARLOCK = {} end
	ElvUF.colors.ClassBars.WARLOCK.SOUL_SHARDS = E:SetColorTable(ElvUF.colors.ClassBars.WARLOCK.SOUL_SHARDS, db.classResources.WARLOCK.SOUL_SHARDS)
	ElvUF.colors.ClassBars.WARLOCK.DEMONIC_FURY = E:SetColorTable(ElvUF.colors.ClassBars.WARLOCK.DEMONIC_FURY, db.classResources.WARLOCK.DEMONIC_FURY)

	if not ElvUF.colors.ClassBars.WARLOCK.BURNING_EMBERS then ElvUF.colors.ClassBars.WARLOCK.BURNING_EMBERS = {} end
	for i = 1, 4 do
		ElvUF.colors.ClassBars.WARLOCK.BURNING_EMBERS[i] = E:SetColorTable(ElvUF.colors.ClassBars.WARLOCK.BURNING_EMBERS[i], db.classResources.WARLOCK.BURNING_EMBERS[i])
	end

	if not ElvUF.colors.ClassBars.DEATHKNIGHT then ElvUF.colors.ClassBars.DEATHKNIGHT = {} end
	for i = -1, 4 do
		ElvUF.colors.ClassBars.DEATHKNIGHT[i] = E:SetColorTable(ElvUF.colors.ClassBars.DEATHKNIGHT[i], db.classResources.DEATHKNIGHT[i])
	end

	-- Druid (Cataclysm only)
	if not ElvUF.colors.ClassBars.DRUID then ElvUF.colors.ClassBars.DRUID = {} end
	ElvUF.colors.ClassBars.DRUID[1] = E:SetColorTable(ElvUF.colors.ClassBars.DRUID[1], db.classResources.DRUID[1])
	ElvUF.colors.ClassBars.DRUID[2] = E:SetColorTable(ElvUF.colors.ClassBars.DRUID[2], db.classResources.DRUID[2])

	local health = ElvUF.colors.health
	local smooth = ElvUF.colors.smooth
	if smooth then
		smooth[7] = health.r
		smooth[8] = health.g
		smooth[9] = health.b
	elseif not smooth then
		ElvUF.colors.smooth = { CURVE_RED.r, CURVE_RED.g, CURVE_RED.b, CURVE_YELLOW.r, CURVE_YELLOW.g, CURVE_YELLOW.b, health.r, health.g, health.b }
	end

	if health.SetCurve then
		wipe(CURVE_HEALTH)

		CURVE_HEALTH[0.0] = CURVE_RED
		CURVE_HEALTH[0.5] = CURVE_YELLOW
		CURVE_HEALTH[1.0] = health

		health:SetCurve(CURVE_HEALTH)
	end

	ElvUF.colors.castColor = E:SetColorTable(ElvUF.colors.castColor, db.castColor)
	ElvUF.colors.castNoInterrupt = E:SetColorTable(ElvUF.colors.castNoInterrupt, db.castNoInterrupt)

	if not ElvUF.colors.DebuffHighlight then ElvUF.colors.DebuffHighlight = {} end
	ElvUF.colors.DebuffHighlight.Magic = E:SetColorTable(ElvUF.colors.DebuffHighlight.Magic, db.debuffHighlight.Magic)
	ElvUF.colors.DebuffHighlight.Curse = E:SetColorTable(ElvUF.colors.DebuffHighlight.Curse, db.debuffHighlight.Curse)
	ElvUF.colors.DebuffHighlight.Disease = E:SetColorTable(ElvUF.colors.DebuffHighlight.Disease, db.debuffHighlight.Disease)
	ElvUF.colors.DebuffHighlight.Poison = E:SetColorTable(ElvUF.colors.DebuffHighlight.Poison, db.debuffHighlight.Poison)
end

function UF:Update_StatusBars(statusbars)
	for statusbar in pairs(statusbars or UF.statusbars) do
		UF:Update_StatusBar(statusbar)
		UF:Update_StatusBar(statusbar.bg)
	end
end

function UF:Update_StatusBar(statusbar, texture)
	if not statusbar then return end

	if not texture then
		texture = LSM:Fetch('statusbar', UF.db.statusbar)
	end

	local useBlank = statusbar.parent and statusbar.parent.isTransparent or statusbar.isTransparent
	local newTexture = (not useBlank and texture) or E.media.blankTex

	if statusbar:IsObjectType('StatusBar') then
		statusbar:SetStatusBarTexture(newTexture)
	elseif statusbar:IsObjectType('Texture') then
		statusbar:SetTexture(newTexture)
	end
end

function UF:Update_FontString(object)
	object:FontTemplate(LSM:Fetch('font', UF.db.font), UF.db.fontSize, UF.db.fontOutline)
end

function UF:Update_FontStrings()
	local font, size, outline = LSM:Fetch('font', UF.db.font), UF.db.fontSize, UF.db.fontOutline
	for obj in pairs(UF.fontstrings) do
		obj:FontTemplate(font, size, outline)
	end
end

function UF:Construct_PrivateAuras(frame)
	return CreateFrame('Frame', frame.frameName..'PrivateAuras', frame.RaisedElementParent)
end

function UF:Configure_PrivateAuras(frame)
	if not E.Retail then return end -- dont exist on classic

	if frame.PrivateAuras then
		PA:RemoveAuras(frame.PrivateAuras)
	end

	local db = frame.db and frame.db.privateAuras
	if db and db.enable then
		PA:SetupPrivateAuras(db, frame.PrivateAuras, frame.unit)

		frame.PrivateAuras:ClearAllPoints()
		frame.PrivateAuras:Point(E.InversePoints[db.parent.point], frame, db.parent.point, db.parent.offsetX, db.parent.offsetY)
		frame.PrivateAuras:Size(db.icon.size)
		frame.PrivateAuras:SetFrameLevel(frame.RaisedElementParent.PrivateAurasLevel)
	end
end

function UF:Construct_Fader()
	return { UpdateRange = UF.UpdateRange }
end

do -- IDs maintained in Difficulty Datatext
	local diffs = {
		keys = {
			none = {0},
			timewalking = {24, 33, 151},
			dungeonNormal = {1, 38, 173, 198, 201, 205}, -- 205 is follower
			dungeonHeroic = {2, 39, 174},
			dungeonMythic = {23, 40},
			dungeonMythicKeystone = {8},
			raidNormal = {3, 4, 14, 148, 175, 176, 185, 186, 215}, -- 148 is ZG/AQ40, 215 is Sunken Temple
			raidHeroic = {5, 6, 15, 193, 194},
			raidMythic = {16},
		}
	}

	local function HandleDifficulties(fader, db)
		if not diffs[fader] then
			diffs[fader] = {}
		else
			wipe(diffs[fader])
		end

		for key, ids in next, diffs.keys do
			if db.instanceDifficulties[key] then
				for _, val in next, ids do
					diffs[fader][val] = true
				end
			end
		end

		return next(diffs[fader]) and diffs[fader] or nil
	end

	function UF:Configure_Fader(frame)
		local db = frame.db and frame.db.enable and frame.db.fader
		if db and db.enable then
			if not frame:IsElementEnabled('Fader') then
				frame:EnableElement('Fader')
			end

			local fader = frame.Fader
			fader:SetOption('Hover', db.hover)
			fader:SetOption('Combat', db.combat)
			fader:SetOption('PlayerTarget', db.playertarget)
			fader:SetOption('Focus', db.focus)
			fader:SetOption('Health', db.health)
			fader:SetOption('Power', db.power)
			fader:SetOption('Vehicle', db.vehicle)
			fader:SetOption('Casting', db.casting)
			fader:SetOption('MinAlpha', db.minAlpha)
			fader:SetOption('MaxAlpha', db.maxAlpha)
			fader:SetOption('DynamicFlight', db.dynamicflight)

			if frame ~= _G.ElvUF_Player then
				fader:SetOption('Range', db.range)
				fader:SetOption('UnitTarget', db.unittarget)
			end

			fader:SetOption('Smooth', (db.smooth > 0 and db.smooth) or nil)
			fader:SetOption('Delay', (db.delay > 0 and db.delay) or nil)
			fader:SetOption('InstanceDifficulty', HandleDifficulties(fader, db))

			fader:ClearTimers()
			fader.configTimer = E:ScheduleTimer(fader.ForceUpdate, 0.25, fader, true)
		elseif frame:IsElementEnabled('Fader') then
			frame:DisableElement('Fader')
			E:UIFrameFadeIn(frame, 1, frame:GetAlpha(), 1)
		end
	end
end

function UF:Construct_ClipFrame(frame, bar)
	local clipFrame = CreateFrame('Frame', nil, bar)
	clipFrame:SetClipsChildren(true)
	clipFrame:SetAllPoints()
	clipFrame:EnableMouse(false)
	clipFrame.__frame = frame
	bar.ClipFrame = clipFrame

	return clipFrame
end

function UF:Configure_FontString(obj)
	UF.fontstrings[obj] = true
	obj:FontTemplate() --This is temporary.
end

function UF:Update_AllFrames()
	if not E.private.unitframe.enable then return end

	UF.multiplier = UF.db.multiplier

	UF:UpdateColors()
	UF:Update_FontStrings()
	UF:Update_StatusBars()

	for unit, frame in pairs(UF.units) do
		local enabled = UF.db.units[unit].enable
		frame:SetEnabled(enabled)

		if enabled then
			frame:Update()
			E:EnableMover(frame.mover.name)
		else
			E:DisableMover(frame.mover.name)
		end
	end

	for unit, group in pairs(UF.groupunits) do
		local frame = UF[unit]

		local enabled = UF.db.units[group].enable
		if group == 'arena' then
			frame:SetAttribute('oUF-enableArenaPrep', enabled)
		end

		frame:SetEnabled(enabled)

		if enabled then
			frame:Update()
			E:EnableMover(frame.mover.name)
		else
			E:DisableMover(frame.mover.name)
		end

		if frame.isForced then
			UF:ForceShow(frame)
		end
	end

	UF:UpdateAllHeaders()
end

function UF:CreateAndUpdateUFGroup(group, numGroup)
	for i = 1, numGroup do
		local unit = group..i
		local frame = UF[unit]

		if not frame then
			UF.groupunits[unit] = group -- keep above spawn, it's required

			local frameName = gsub(E:StringTitle(unit), 't(arget)', 'T%1')
			frame = ElvUF:Spawn(unit, 'ElvUF_'..frameName, E.Retail and 'SecureUnitButtonTemplate, PingableUnitFrameTemplate' or 'SecureUnitButtonTemplate')
			frame:SetID(i)
			frame.index = i

			UF[unit] = frame
		end

		if not frame.Update then
			local groupName = gsub(E:StringTitle(group), 't(arget)', 'T%1')
			frame.Update = function()
				UF['Update_'..E:StringTitle(groupName)..'Frames'](UF, frame, UF.db.units[group])
			end
		end

		local enabled = UF.db.units[group].enable
		if group == 'arena' then
			frame:SetAttribute('oUF-enableArenaPrep', enabled)
		end

		frame:SetEnabled(enabled)

		if enabled then
			frame:Update()
			E:EnableMover(frame.mover.name)
		else
			E:DisableMover(frame.mover.name)
		end

		if frame.isForced then
			UF:ForceShow(frame)
		end
	end
end

function UF:SetHeaderSortGroup(group, groupBy)
	local func = UF.headerGroupBy[groupBy] or UF.headerGroupBy.INDEX
	func(group)
end

--Keep an eye on this one, it may need to be changed too
function UF.groupPrototype:GetAttribute(name)
	return self.groups[1]:GetAttribute(name)
end

function UF.groupPrototype:Configure_Groups(Header)
	local db = UF.db.units[Header.groupName]
	local width, height, newCols, newRows = 0, 0, 0, 0
	Header.db = db

	local isParty = Header.groupName == 'party'
	local dbWidth, dbHeight = db.width, db.height
	local groupsPerRowCol = isParty and 1 or db.groupsPerRowCol
	local invertGroupingOrder = db.invertGroupingOrder
	local startFromCenter = db.startFromCenter
	local raidWideSorting = db.raidWideSorting
	local direction = db.growthDirection
	local showPlayer = db.showPlayer
	local groupBy = db.groupBy
	local sortDir = db.sortDir

	local groupSpacing = E:Scale(db.groupSpacing)
	local verticalSpacing = E:Scale(db.verticalSpacing)
	local horizontalSpacing = E:Scale(db.horizontalSpacing)
	local WIDTH = E:Scale(dbWidth) + horizontalSpacing
	local HEIGHT = E:Scale(dbHeight + (db.infoPanel and db.infoPanel.enable and db.infoPanel.height or 0)) + verticalSpacing
	local x, y = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction], DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction]

	local HEIGHT_FIVE = HEIGHT * 5
	local WIDTH_FIVE = WIDTH * 5

	local numGroups = Header.numGroups
	for i = 1, numGroups do
		local group = Header.groups[i]
		local lastIndex = i - 1
		local lastGroup = lastIndex % groupsPerRowCol

		if group then
			UF:ConvertGroupDB(group)
			group:ClearAllPoints()
			group:ClearChildPoints()
			group.db = db

			local point = DIRECTION_TO_POINT[direction]
			group:SetAttribute('point', point)

			if point == 'LEFT' or point == 'RIGHT' then
				group:SetAttribute('xOffset', horizontalSpacing * x)
				group:SetAttribute('yOffset', 0)
				group:SetAttribute('columnSpacing', verticalSpacing)
			else
				group:SetAttribute('xOffset', 0)
				group:SetAttribute('yOffset', verticalSpacing * y)
				group:SetAttribute('columnSpacing', horizontalSpacing)
			end

			if not group.isForced then
				if not group.initialized then
					group:SetAttribute('startingIndex', raidWideSorting and (-min(numGroups * (groupsPerRowCol * 5), _G.MAX_RAID_MEMBERS) + 1) or -4)
					group:Show()
					group.initialized = true
				end
				group:SetAttribute('startingIndex', 1)
			end

			if raidWideSorting and invertGroupingOrder then
				group:SetAttribute('columnAnchorPoint', INVERTED_DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])
			else
				group:SetAttribute('columnAnchorPoint', DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])
			end

			if not group.isForced then
				group:SetAttribute('maxColumns', raidWideSorting and numGroups or 1)
				group:SetAttribute('unitsPerColumn', raidWideSorting and (groupsPerRowCol * 5) or 5)
				group:SetAttribute('sortDir', sortDir)
				group:SetAttribute('showPlayer', showPlayer)
				UF:SetHeaderSortGroup(group, groupBy)
			end

			local groupWide = i == 1 and raidWideSorting and strsub('1,2,3,4,5,6,7,8', 1, numGroups + numGroups-1)
			group:SetAttribute('groupFilter', groupWide or tostring(i))
		end

		--MATH!! WOOT
		local point = DIRECTION_TO_GROUP_ANCHOR_POINT[direction]
		if (isParty or raidWideSorting) and startFromCenter then
			point = DIRECTION_TO_GROUP_ANCHOR_POINT['OUT_'..direction]
		end

		if lastGroup == 0 then
			if DIRECTION_TO_POINT[direction] == 'LEFT' or DIRECTION_TO_POINT[direction] == 'RIGHT' then
				if group then group:SetPoint(point, Header, point, 0, height * y) end
				height = height + HEIGHT + groupSpacing
				newRows = newRows + 1
			else
				if group then group:SetPoint(point, Header, point, width * x, 0) end
				width = width + WIDTH + groupSpacing
				newCols = newCols + 1
			end
		else
			if DIRECTION_TO_POINT[direction] == 'LEFT' or DIRECTION_TO_POINT[direction] == 'RIGHT' then
				if newRows == 1 then
					if group then group:SetPoint(point, Header, point, width * x, 0) end
					width = width + WIDTH_FIVE + groupSpacing
					newCols = newCols + 1
				elseif group then
					group:SetPoint(point, Header, point, ((WIDTH_FIVE * lastGroup) + lastGroup * groupSpacing) * x, ((HEIGHT + groupSpacing) * (newRows - 1)) * y)
				end
			else
				if newCols == 1 then
					if group then group:SetPoint(point, Header, point, 0, height * y) end
					height = height + HEIGHT_FIVE + groupSpacing
					newRows = newRows + 1
				elseif group then
					group:SetPoint(point, Header, point, ((WIDTH + groupSpacing) * (newCols - 1)) * x, ((HEIGHT_FIVE * lastGroup) + lastGroup * groupSpacing) * y)
				end
			end
		end

		if height == 0 then height = height + HEIGHT_FIVE + groupSpacing end
		if width == 0 then width = width + WIDTH_FIVE + groupSpacing end
	end

	Header:SetSize(width - horizontalSpacing - groupSpacing, height - verticalSpacing - groupSpacing)
end

function UF.headerPrototype:ExecuteForChildren(method, func, ...)
	local i = 1
	local child = self:GetAttribute('child'..i)
	while child do
		if func then
			func(child, i, ...)
		else
			local methodFunc = method and child[method]
			if methodFunc then
				methodFunc(child, ...)
			end
		end

		i = i + 1
		child = self:GetAttribute('child'..i)
	end
end

function UF.headerPrototype:ClearChildPoints()
	self:ExecuteForChildren('ClearAllPoints')
end

function UF.groupPrototype:Update(Header)
	local db = UF.db.units[Header.groupName]

	UF[Header.groupName].db = db

	for _, Group in ipairs(Header.groups) do
		Group.db = db
		Group:Update()
	end
end

function UF.groupPrototype:AdjustVisibility(Header)
	if not Header.isForced then
		local numGroups = Header.numGroups
		for i, group in ipairs(Header.groups) do
			if i <= numGroups and ((Header.db.raidWideSorting and i <= 1) or not Header.db.raidWideSorting) then
				group:Show()
			elseif group.forceShow then
				group:Hide()
				group:SetAttribute('startingIndex', 1)
				UF:UnshowChildUnits(group)
			else
				group:Reset()
			end
		end
	end
end

function UF.headerPrototype:UpdateChild(index, header, func, db)
	func(UF, self, db) -- self is child

	local name = self:GetName()

	local target = _G[name..'Target']
	if target then
		func(UF, target, db)
	end

	local pet = _G[name..'Pet']
	if pet then
		func(UF, pet, db)
	end
end

function UF.headerPrototype:Update(isForced)
	local db = UF.db.units[self.groupName]

	UF[self.UpdateHeader](UF, self, db, isForced)

	self:ExecuteForChildren(nil, self.UpdateChild, self, UF[self.UpdateFrames], db)
end

function UF.headerPrototype:Reset()
	self:SetAttribute('showPlayer', true)
	self:SetAttribute('showSolo', true)
	self:SetAttribute('showParty', true)
	self:SetAttribute('showRaid', true)
	self:SetAttribute('columnSpacing', nil)
	self:SetAttribute('columnAnchorPoint', nil)
	self:SetAttribute('groupBy', nil)
	self:SetAttribute('groupFilter', nil)
	self:SetAttribute('groupingOrder', nil)
	self:SetAttribute('maxColumns', nil)
	self:SetAttribute('nameList', nil)
	self:SetAttribute('point', nil)
	self:SetAttribute('sortDir', nil)
	self:SetAttribute('sortMethod', 'NAME')
	self:SetAttribute('startingIndex', nil)
	self:SetAttribute('strictFiltering', nil)
	self:SetAttribute('unitsPerColumn', nil)
	self:SetAttribute('xOffset', nil)
	self:SetAttribute('yOffset', nil)
	self:Hide()
end

function UF:ZONE_CHANGED_NEW_AREA(event)
	local previous = UF.maxAllowedGroups

	if E.Retail and UF.db.maxAllowedGroups then
		local _, instanceType, difficultyID = GetInstanceInfo()
		UF.maxAllowedGroups = (difficultyID == 16 and 4) or (instanceType == 'raid' and 6) or 8
	else
		UF.maxAllowedGroups = 8
	end

	if previous ~= UF.maxAllowedGroups then
		UF:Update_AllFrames()
	end

	if event then
		UF:UnregisterEvent(event)
	end
end

do
	local ChestSlotID = GetInventorySlotInfo('CHESTSLOT')
	local LegSlotID = GetInventorySlotInfo('LEGSSLOT')

	local chestSlotItem, legSlotItem -- local cache of the items
	function UF:UNIT_INVENTORY_CHANGED(_, unit) -- limited to Mages only currently
		if unit ~= 'player' then return end

		local ChestItem = GetInventoryItemLink('player', ChestSlotID) -- Mage: Regeneration
		local LegItem = GetInventoryItemLink('player', LegSlotID) -- Mage: Mass Regeneration

		if chestSlotItem ~= ChestItem or legSlotItem ~= LegItem then
			chestSlotItem = ChestItem
			legSlotItem = LegItem

			UF:UpdateRangeSpells()
		end
	end
end

function UF:PLAYER_ENTERING_WORLD(_, initLogin, isReload)
	UF:RegisterRaidDebuffIndicator()
	UF:UpdateRangeSpells()

	local _, instanceType = GetInstanceInfo()
	if instanceType == 'raid' then
		if initLogin or isReload then
			UF:ZONE_CHANGED_NEW_AREA()
		else
			UF:RegisterEvent('ZONE_CHANGED_NEW_AREA')
		end
	elseif UF.maxAllowedGroups ~= 8 then
		UF.maxAllowedGroups = 8

		UF:Update_AllFrames()
	end
end

do
	local attributes = {}
	function UF:CreateHeader(parent, groupFilter, overrideName, template, groupName, headerTemplate)
		local group = parent.groupName or groupName
		local db = UF.db.units[group]
		ElvUF:SetActiveStyle('ElvUF_'..E:StringTitle(group))

		-- setup the attributes for header
		attributes['oUF-initialConfigFunction'] = format('self:SetWidth(%d); self:SetHeight(%d);', db.width, db.height)
		attributes.template = template or nil
		attributes.groupFilter = groupFilter
		attributes.showRaid = group ~= 'party'
		attributes.showParty = true
		attributes.showSolo = true

		local header = ElvUF:SpawnHeader(overrideName, headerTemplate, attributes)
		header.UpdateHeader = format('Update_%sHeader', parent.isRaidFrame and 'Raid' or E:StringTitle(group))
		header.UpdateFrames = format('Update_%sFrames', parent.isRaidFrame and 'Raid' or E:StringTitle(group))
		header.groupName = group

		if parent ~= E.UFParent then
			header:SetParent(parent)
		end

		header:Show()

		for k, v in pairs(UF.headerPrototype) do
			header[k] = v
		end

		return header
	end
end

function UF:CreateAndUpdateHeaderGroup(group, groupFilter, template, headerTemplate, skip)
	local db = UF.db.units[group]
	local Header = UF[group]

	local enable = db.enable
	local visibility = db.visibility
	local numGroups = (group == 'party' and 1) or (db.numGroups and min(UF.maxAllowedGroups, db.numGroups))
	local name, isRaidFrames = E:StringTitle(group), strmatch(group, '^raid(%d)') and true

	if not Header then
		ElvUF:RegisterStyle('ElvUF_'..name, UF[format('Construct_%sFrames', isRaidFrames and 'Raid' or name)])
		ElvUF:SetActiveStyle('ElvUF_'..name)
		if not UF.headerFunctions[group] then UF.headerFunctions[group] = {} end

		if numGroups then
			Header = CreateFrame('Frame', 'ElvUF_'..name, E.UFParent, 'SecureHandlerStateTemplate')
			Header.groups = {}
			Header.groupName = group
			Header.template = Header.template or template
			Header.headerTemplate = Header.headerTemplate or headerTemplate
			Header.isRaidFrame = isRaidFrames
			Header.raidFrameN = isRaidFrames and gsub(group, '.-(%d)', '%1')

			for k, v in pairs(UF.groupPrototype) do
				UF.headerFunctions[group][k] = v
			end
		else
			Header = UF:CreateHeader(E.UFParent, groupFilter, 'ElvUF_'..name, template, group, headerTemplate)
		end

		Header:Show()

		UF[group] = Header
		UF.headers[group] = Header
	end

	local groupFunctions = UF.headerFunctions[group]
	local groupsChanged = (Header.numGroups ~= numGroups)
	local stateChanged = (Header.enableState ~= enable)
	Header.enableState = enable
	Header.numGroups = numGroups
	Header.db = db

	if numGroups then
		if db.raidWideSorting then
			if not Header.groups[1] then
				Header.groups[1] = UF:CreateHeader(Header, nil, 'ElvUF_'..name..'Group1', template or Header.template, nil, headerTemplate or Header.headerTemplate)
			end
		else
			while numGroups > #Header.groups do
				local index = tostring(#Header.groups + 1)
				tinsert(Header.groups, UF:CreateHeader(Header, index, 'ElvUF_'..name..'Group'..index, template or Header.template, nil, headerTemplate or Header.headerTemplate))
			end
		end

		if groupsChanged or not skip then
			groupFunctions:AdjustVisibility(Header)
			groupFunctions:Configure_Groups(Header)
		end
	elseif not groupFunctions.Update then -- tank / assist
		groupFunctions.Update = function(_, header)
			UF[header.UpdateHeader](UF, header, header.db)

			header:ExecuteForChildren(nil, header.UpdateChild, header, UF[header.UpdateFrames], header.db)
		end
	end

	if stateChanged or not skip then
		groupFunctions:Update(Header)
	end

	if enable then
		if not Header.isForced then
			RegisterStateDriver(Header, 'visibility', visibility)
		end
		if Header.mover then
			E:EnableMover(Header.mover.name)
		end
	else
		UnregisterStateDriver(Header, 'visibility')
		Header:Hide()
		if Header.mover then
			E:DisableMover(Header.mover.name)
		end
	end
end

function UF:CreateAndUpdateUF(unit)
	assert(unit, 'No unit provided to create or update.')

	local frameName = gsub(E:StringTitle(unit), 't(arget)', 'T%1')
	local frame = UF[unit]
	if not frame then
		frame = ElvUF:Spawn(unit, 'ElvUF_'..frameName, E.Retail and 'SecureUnitButtonTemplate, PingableUnitFrameTemplate' or 'SecureUnitButtonTemplate')

		UF.units[unit] = frame
		UF[unit] = frame
	end

	if not frame.Update then
		frame.Update = function()
			UF['Update_'..frameName..'Frame'](UF, frame, UF.db.units[unit])
		end
	end

	local enabled = UF.db.units[unit].enable
	frame:SetEnabled(enabled)

	if enabled then
		frame:Update()
		E:EnableMover(frame.mover.name)
	else
		E:DisableMover(frame.mover.name)
	end
end

do
	local mouseover = {
		tank = true,
		assist = true,
		party = true,
		raid = true,
		raidpet = true
	}

	-- 1) we need to get some things ready very early on
	function UF:PrepareFrame(frame, group)
		-- we use this to move various objects over the base frame
		if not frame.RaisedElementParent then
			frame.RaisedElementParent = UF:CreateRaisedElement(frame)
		end

		-- setup some useful variables that we need
		if group then
			local parent = frame:GetParent()
			frame.originalParent = parent

			local parentName = parent and parent:GetName()
			frame.originalParentName = parentName or nil

			if group == 'party' then
				frame.childType = frame.isChild and ((parentName and frame == _G[parentName..'Target'] and 'target') or 'pet') or nil
			end
		end

		-- handle the enter / leave scripts, for ones that need it
		if not group or mouseover[group] then
			frame:SetScript('OnEnter', UF.UnitFrame_OnEnter)
			frame:SetScript('OnLeave', UF.UnitFrame_OnLeave)
		end
	end

	-- 2) after that we need to setup additional things
	function UF:ConstructFrame(frame, unitframeType)
		frame.unitframeType = unitframeType
		frame.frameName = frame:GetName()
		frame.customTexts = {}
	end

	-- various checks to determine the setup
	local isPet = { partypet = true, pet = true, raidpet = true }
	local noAuras = { assisttarget = true, partypet = true, partytarget = true, tanktarget = true }
	local noInfoPanel = { assist = true, assisttarget = true, partypet = true, partytarget = true, raidpet = true, tank = true, tanktarget = true }
	local noPortrait = { assist = true, assisttarget = true, partypet = true, partytarget = true, tank = true, tanktarget = true }
	local noPower = { assist = true, assisttarget = true, partypet = true, partytarget = true, raidpet = true, tank = true, tanktarget = true }
	local noBossArena = { arena = true, boss = true }
	local noTargets = { arena = true, assisttarget = true, focustarget = true, partytarget = true, pettarget = true, tanktarget = true, targettarget = true, targettargettarget = true }

	-- which elements on what
	local auraHighlight = { assist = true, boss = true, focus = true, party = true, pet = true, player = true, raid = true, raidpet = true, tank = true, target = true }
	local castBar = { arena = true, boss = true, focus = true, party = true, pet = true, player = true, target = true }
	local classBar = { party = true, player = true, raid = true }
	local iconCombat = { party = true, raid = true, player = true, target = true, focus = true }
	local iconPhase = { party = true, raid = true, target = true }
	local iconPVP = { player = true, target = true }
	local iconRaid = { party = true, player = true, raid = true, target = true }
	local iconRoles = { party = true, raid = true }
	local pvpIndicator = { arena = true, party = true, raid = true }
	local raidDebuffs = { assist = true, party = true, raid = true, raidpet = true, tank = true }

	-- 3) this is used on all the unitframes to configure elements
	--- the order of these is sometimes very important, try not to change them
	---------------------------------------------------------------------------
	--- which is not the unitframeType, its used for setting up frames
	---- party: 'party', 'partytarget', 'partypet'
	---- assist: 'assist', 'assisttarget'
	---- tank: 'tank', 'tanktarget'
	function UF:ConfigureFrame(frame, which, offset)
		if not noInfoPanel[which] then
			UF:Configure_InfoPanel(frame)
		end

		UF:Configure_HealthBar(frame)
		UF:Configure_HealComm(frame)
		UF:Configure_Cutaway(frame)
		UF:Configure_Fader(frame)

		if not noBossArena[which] then
			UF:Configure_Threat(frame)
		end

		if not noPower[which] then
			UF:Configure_Power(frame)
			UF:Configure_PowerPrediction(frame)
		end

		--[[if not noPortrait[which] then
			UF:Configure_Portrait(frame)
		end]]

		if not noAuras[which] then
			UF:EnableDisable_Auras(frame)
			UF:Configure_AllAuras(frame)

			UF:Configure_CustomTexts(frame)
		end

		if not noTargets[which] then
			UF:Configure_AuraWatch(frame, isPet[which])
			UF:Configure_PrivateAuras(frame)
		end

		if raidDebuffs[which] then
			UF:Configure_RaidDebuffs(frame)
		end

		if auraHighlight[which] then
			UF:Configure_AuraHighlight(frame)
		end

		if castBar[which] then
			UF:Configure_Castbar(frame)
		end

		if which ~= 'arena' then
			UF:Configure_RaidIcon(frame)
		end

		if iconPhase[which] then
			UF:Configure_PhaseIcon(frame)
		end

		if iconPVP[which] then
			UF:Configure_PVPIcon(frame)
		end

		if iconCombat[which] then
			UF:Configure_CombatIndicator(frame)
		end

		if iconRaid[which] then
			UF:Configure_RaidRoleIcons(frame)

			if not E.Classic then
				UF:Configure_ResurrectionIcon(frame)
			end
		end

		if iconRoles[which] then
			UF:Configure_ReadyCheckIcon(frame)

			if E.allowRoles then
				UF:Configure_RoleIcon(frame)
			end

			if not E.Classic then
				UF:Configure_SummonIcon(frame)
			end

			if E.Retail or E.Mists then
				UF:Configure_AltPowerBar(frame)
			end
		end

		if not E.Classic and pvpIndicator[which] then
			UF:Configure_PvPClassificationIndicator(frame)
		end

		if classBar[which] then
			UF:Configure_ClassBar(frame)
		end

		-- any additional custom setup
		if which == 'pet' then
			UF:Configure_AuraBars(frame)
		elseif which == 'focus' then
			UF:Configure_AuraBars(frame)
		elseif which == 'target' then
			UF:Configure_AuraBars(frame)
		elseif which == 'arena' then
			UF:Configure_Trinket(frame)

			if not E.Classic then
				UF:Configure_PVPSpecIcon(frame)
			end
		elseif which == 'player' then
			UF:Configure_AuraBars(frame)
			UF:Configure_PVPText(frame)
			UF:Configure_PartyIndicator(frame)
			UF:Configure_RestingIndicator(frame)

			if (E.Classic or E.TBC or E.Wrath) and E.myclass ~= 'WARRIOR' then
				UF:Configure_EnergyManaRegen(frame)
			end

			-- We need to update Target AuraBars if attached to Player AuraBars,
			-- mainly because of issues when using power offset on player and switching to/from middle orientation
			if UF.db.units.target.aurabar.attachTo == 'PLAYER_AURABARS' and UF.target then
				UF:Configure_AuraBars(UF.target)
			end
		end

		-- trigger some final things
		UF:UpdateNameSettings(frame)
		UF:HandleRegisterClicks(frame)

		-- set mover snapping offset, if available
		if offset then
			E:SetMoverSnapOffset(frame.mover.name, -offset)
		end

		-- do the update to the frame; which fires an update to all oUF elements
		frame:UpdateAllElements('ElvUI_UpdateAllElements')
	end
end

function UF:LoadUnits()
	for _, unit in pairs(UF.unitstoload) do
		UF:CreateAndUpdateUF(unit)
	end
	UF.unitstoload = nil

	for group, groupOptions in pairs(UF.unitgroupstoload) do
		local numGroup, template = unpack(groupOptions)
		UF:CreateAndUpdateUFGroup(group, numGroup, template)
	end
	UF.unitgroupstoload = nil

	for group, groupOptions in pairs(UF.headerstoload) do
		local groupFilter, template, headerTemplate
		if type(groupOptions) == 'table' then
			groupFilter, template, headerTemplate = unpack(groupOptions)
		end

		UF:CreateAndUpdateHeaderGroup(group, groupFilter, template, headerTemplate)
	end
	UF.headerstoload = nil
end

function UF:RegisterRaidDebuffIndicator()
	local ORD = E.oUF_RaidDebuffs or _G.oUF_RaidDebuffs
	if ORD then
		ORD:ResetDebuffData()

		local _, instanceType = GetInstanceInfo()
		if instanceType == 'party' or instanceType == 'raid' then
			local instance = E.global.unitframe.raidDebuffIndicator.instanceFilter
			local instanceSpells = ((E.global.unitframe.aurafilters[instance] and E.global.unitframe.aurafilters[instance].spells) or E.global.unitframe.aurafilters.RaidDebuffs.spells)
			ORD:RegisterDebuffs(instanceSpells)
		else
			local other = E.global.unitframe.raidDebuffIndicator.otherFilter
			local otherSpells = ((E.global.unitframe.aurafilters[other] and E.global.unitframe.aurafilters[other].spells) or E.global.unitframe.aurafilters.CCDebuffs.spells)
			ORD:RegisterDebuffs(otherSpells)
		end
	end
end

function UF:UpdateAllHeaders(skip)
	if E.private.unitframe.disabledBlizzardFrames.party then
		ElvUF:DisableBlizzard('party')
	end

	for group in pairs(UF.headers) do
		UF:CreateAndUpdateHeaderGroup(group, nil, nil, nil, skip)
	end
end

do
	local function EventlessUpdate(frame, elapsed)
		local unit = frame.__eventless and frame.unit
		local guid = unit and UnitExists(unit) and UnitGUID(unit)
		if not guid then return end

		if E:IsSecretValue(guid) then
			local frequency = frame.elapsed or 0
			if frequency > frame.onUpdateSecrets then
				frame:UpdateAllElements('OnUpdate')

				frame.elapsed = 0
			else
				frame.elapsed = frequency + elapsed
			end
		else
			local frequency = frame.elapsed or 0
			if frequency > frame.onUpdateElements then
				if frame.lastGUID ~= guid then
					frame:UpdateAllElements('OnUpdate')
					frame.lastGUID = guid
				else
					if frame:IsElementEnabled('Health') then frame.Health:ForceUpdate() end
					if frame:IsElementEnabled('Power') then frame.Power:ForceUpdate() end
				end

				frame.elapsed = 0
			else
				frame.elapsed = frequency + elapsed
			end

			local prediction = frame.elapsedPrediction or 0
			if prediction > frame.onUpdatePrediction then
				if frame:IsElementEnabled('HealthPrediction') then frame.HealthPrediction:ForceUpdate() end
				if frame:IsElementEnabled('PowerPrediction') then frame.PowerPrediction:ForceUpdate() end
				if frame:IsElementEnabled('RaidTargetIndicator') then frame.RaidTargetIndicator:ForceUpdate() end

				frame.elapsedPrediction = 0
			else
				frame.elapsedPrediction = prediction + elapsed
			end

			local auras = frame.elapsedAuras or 0
			if auras > frame.onUpdateAuras and frame:IsElementEnabled('Auras') then
				if frame.Auras then frame.Auras:ForceUpdate() end
				if frame.Buffs then frame.Buffs:ForceUpdate() end
				if frame.Debuffs then frame.Debuffs:ForceUpdate() end

				frame.elapsedAuras = 0
			else
				frame.elapsedAuras = auras + elapsed
			end
		end
	end

	function ElvUF:HandleEventlessUnit(frame)
		if not frame.onUpdateSecrets then frame.onUpdateSecrets = 0.5 end -- same as oUF
		if not frame.onUpdateElements then frame.onUpdateElements = 0.2 end
		if not frame.onUpdatePrediction then frame.onUpdatePrediction = 0.4 end
		if not frame.onUpdateAuras then frame.onUpdateAuras = 0.6 end

		frame.__eventless = true
		frame:SetScript('OnUpdate', EventlessUpdate)
	end
end

do
	local SetFrameUp = {}
	local SetFrameUnit = {}
	local SetFrameHidden = {}
	local DisabledElements = {}
	local AllowedFuncs = {
		[_G.DefaultCompactUnitFrameSetup] = true
	}

	local function FrameShown(frame, shown)
		if shown then
			frame:Hide()
		end
	end

	function UF:DisableBlizzard_InitializeForGroup()
		if self:IsForbidden() then return end

		local disable = E.private.unitframe.disabledBlizzardFrames
		if disable.raid then
			self:UnregisterAllEvents()
		end
	end

	function UF:DisableBlizzard_SetUpFrame(func)
		if not AllowedFuncs[func] then return end

		local name = (not self.IsForbidden or not self:IsForbidden()) and self:GetDebugName()
		if E:IsSecretValue(name) or not name then return end

		for _, pattern in next, SetFrameUp do
			if strmatch(name, pattern) then
				SetFrameUnit[self] = name
			end
		end
	end

	function UF:DisableBlizzard_SetUnit(token)
		if SetFrameUnit[self] and token ~= nil then
			self:SetScript('OnEvent', nil)
			self:SetScript('OnUpdate', nil)
		end
	end

	function UF:DisableBlizzard_DisableFrame(frame, isNamePlate)
		frame:UnregisterAllEvents()

		if isNamePlate then
			pcall(frame.SetAlpha, frame, 0)
		else
			pcall(frame.Hide, frame)
		end

		tinsert(DisabledElements, (frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar) or nil)
		tinsert(DisabledElements, frame.healthBar or frame.healthbar or frame.HealthBar or nil)
		tinsert(DisabledElements, frame.manabar or frame.ManaBar or nil)
		tinsert(DisabledElements, frame.castBar or frame.spellbar or nil)
		tinsert(DisabledElements, frame.petFrame or frame.PetFrame or nil)
		tinsert(DisabledElements, frame.powerBarAlt or frame.PowerBarAlt or nil)
		tinsert(DisabledElements, frame.CastingBarFrame or nil)
		tinsert(DisabledElements, frame.CcRemoverFrame or nil)
		tinsert(DisabledElements, frame.classPowerBar or nil)
		tinsert(DisabledElements, frame.DebuffFrame or nil)
		tinsert(DisabledElements, frame.BuffFrame or frame.AurasFrame or nil)
		tinsert(DisabledElements, frame.totFrame or nil)

		for index, element in ipairs(DisabledElements) do
			element:UnregisterAllEvents() -- turn elements off
			DisabledElements[index] = nil -- keep this clean
		end
	end

	function UF:DisableBlizzard_HideFrame(frame, pattern)
		if not frame then return end

		UF:DisableBlizzard_DisableFrame(frame)

		if SetFrameUp[frame] ~= pattern then
			SetFrameUp[frame] = pattern
		end

		if not SetFrameHidden[frame] then
			SetFrameHidden[frame] = true

			hooksecurefunc(frame, 'Show', frame.Hide)
			hooksecurefunc(frame, 'SetShown', FrameShown)
		end
	end

	do
		local locked -- TODO: remove this hack once we can adjust hitrects ourselves, coming in a later build
		local function LockedAlpha(blizzPlate)
			if locked or blizzPlate:IsForbidden() then return end

			locked = true
			blizzPlate:SetAlpha(0)
			locked = false
		end

		local hooked = {}
		function ElvUF:DisableBlizzardNamePlate(frame)
			if (not frame or frame:IsForbidden()) or (not E.private.nameplates.enable) then return end

			local plate = frame.UnitFrame
			if not plate then return end

			if E.Retail then
				if not hooked[plate] then
					hooksecurefunc(plate, 'SetAlpha', LockedAlpha)

					hooked[plate] = true
				end

				UF:DisableBlizzard_DisableFrame(plate, true)
			else
				UF:DisableBlizzard_HideFrame(plate, '^NamePlate%d+%.UnitFrame$')
			end
		end
	end

	function UF:DisableBlizzard()
		local disable = E.private.unitframe.disabledBlizzardFrames
		if disable.party or disable.raid then
			-- calls to UpdateRaidAndPartyFrames, which as of writing this is used to show/hide the
			-- Raid Utility and update Party frames via PartyFrame.UpdatePartyFrames not raid frames.
			UIParent:UnregisterEvent('GROUP_ROSTER_UPDATE')
		end

		-- shutdown monk stagger bar background updates
		if disable.player and _G.MonkStaggerBar then
			_G.MonkStaggerBar:UnregisterAllEvents()
		end

		-- shutdown some background updates on party unitframes
		if disable.party then
			UF:DisableBlizzard_HideFrame(_G.CompactPartyFrame, '^CompactPartyFrameMember%d+$')
		end

		-- also handle it for background raid frames and the raid utility
		if disable.raid then
			UF:DisableBlizzard_HideFrame(_G.CompactRaidFrameContainer, '^CompactRaidGroup%d+Member%d+$')

			-- Raid Utility
			if _G.CompactRaidFrameManager then
				_G.CompactRaidFrameManager:UnregisterAllEvents()
				_G.CompactRaidFrameManager:SetParent(E.HiddenFrame)
			end

			if CompactRaidFrameManager_SetSetting then
				CompactRaidFrameManager_SetSetting('IsShown', '0')
			end
		end

		-- handle arena ones as well
		if disable.arena then
			if _G.UnitFrameThreatIndicator_Initialize then
				UF:SecureHook('UnitFrameThreatIndicator_Initialize')
			end

			if E.Retail then
				ElvUF:DisableBlizzard('arena')
			else
				Arena_LoadUI = E.noop
				-- Blizzard_ArenaUI should not be loaded, called on PLAYER_ENTERING_WORLD if in pvp or arena
				-- this noop happens normally in oUF.DisableBlizzard but we have our own ElvUF.DisableBlizzard

				if IsAddOnLoaded('Blizzard_ArenaUI') then
					ElvUF:DisableBlizzard('arena')
				else
					UF:RegisterEvent('ADDON_LOADED')
				end
			end
		end
	end
end

do
	local MAX_PARTY = _G.MEMBERS_PER_RAID_GROUP or _G.MAX_PARTY_MEMBERS or 5
	local MAX_ARENA_ENEMIES = _G.MAX_ARENA_ENEMIES or 5
	local MAX_BOSS_FRAMES = 5

	local handledUnits = {}
	local lockedFrames = {}

	-- lock Boss, Party, and Arena
	local function LockParent(frame, parent)
		if parent ~= E.HiddenFrame then
			frame:SetParent(E.HiddenFrame)
		end
	end

	local function HideFrame(frame, doNotReparent)
		if not frame then return end

		local lockParent = doNotReparent == 1
		if lockParent or not doNotReparent then
			frame:SetParent(E.HiddenFrame)

			if lockParent and not lockedFrames[frame] then
				hooksecurefunc(frame, 'SetParent', LockParent)
				lockedFrames[frame] = true
			end
		end

		UF:DisableBlizzard_DisableFrame(frame)
	end

	function ElvUF:DisableBlizzard(unit)
		if not unit then return end

		if E.private.unitframe.enable and not handledUnits[unit] then
			handledUnits[unit] = true

			local disable = E.private.unitframe.disabledBlizzardFrames
			if unit == 'player' then
				if disable.player then
					local frame = _G.PlayerFrame
					HideFrame(frame)

					if not E.Retail then
						-- For the damn vehicle support:
						frame:RegisterEvent('PLAYER_ENTERING_WORLD')
						frame:RegisterEvent('UNIT_ENTERING_VEHICLE')
						frame:RegisterEvent('UNIT_ENTERED_VEHICLE')
						frame:RegisterEvent('UNIT_EXITING_VEHICLE')
						frame:RegisterEvent('UNIT_EXITED_VEHICLE')

						-- User placed frames don't animate
						frame:SetMovable(true)
						frame:SetUserPlaced(true)
						frame:SetDontSavePosition(true)
					end
				end

				if E.Retail or E.TBC then
					if disable.castbar then
						HideFrame(_G.PlayerCastingBarFrame)
						HideFrame(_G.PetCastingBarFrame)
					end
				elseif disable.castbar then
					CastingBarFrame_SetUnit(_G.CastingBarFrame)
					CastingBarFrame_SetUnit(_G.PetCastingBarFrame)
				else
					CastingBarFrame_OnLoad(_G.CastingBarFrame, 'player', true, false)
					PetCastingBarFrame_OnLoad(_G.PetCastingBarFrame)
				end
			elseif disable.player and unit == 'pet' then
				HideFrame(_G.PetFrame)
			elseif disable.target and unit == 'target' then
				HideFrame(_G.TargetFrame)
				HideFrame(_G.ComboFrame)
			elseif disable.focus and unit == 'focus' then
				HideFrame(_G.FocusFrame)
				HideFrame(_G.TargetofFocusFrame)
			elseif disable.target and unit == 'targettarget' then
				HideFrame(_G.TargetFrameToT)
			elseif disable.boss and strmatch(unit, 'boss%d?$') then
				HideFrame(_G.BossTargetFrameContainer, 1)

				local id = strmatch(unit, 'boss(%d)')
				if id then
					HideFrame(_G['Boss'..id..'TargetFrame'], true)
				else
					for i = 1, MAX_BOSS_FRAMES do
						HideFrame(_G['Boss'..i..'TargetFrame'], true)
					end
				end
			elseif disable.party and strmatch(unit, 'party%d?$') then
				local frame = _G.PartyFrame
				if frame then -- Retail
					HideFrame(frame, 1)

					for child in frame.PartyMemberFramePool:EnumerateActive() do
						HideFrame(child, true)
					end
				else
					HideFrame(_G.PartyMemberBackground)
				end

				local id = strmatch(unit, 'party(%d)')
				if id then
					HideFrame(_G['PartyMemberFrame'..id])
					HideFrame(_G['CompactPartyFrameMember'..id])
				else
					for i = 1, MAX_PARTY do
						HideFrame(_G['PartyMemberFrame'..i])
						HideFrame(_G['CompactPartyFrameMember'..i])
					end
				end
			elseif disable.arena and strmatch(unit, 'arena%d?$') then
				if _G.CompactArenaFrame then -- Retail
					HideFrame(_G.CompactArenaFrame, 1)

					for _, frame in next, _G.CompactArenaFrame.memberUnitFrames do
						HideFrame(frame, true)
					end
				elseif _G.ArenaEnemyFrames then
					_G.ArenaEnemyFrames:UnregisterAllEvents()
					_G.ArenaPrepFrames:UnregisterAllEvents()
					_G.ArenaEnemyFrames:Hide()
					_G.ArenaPrepFrames:Hide()

					-- reference on oUF and clear the global frame reference, to fix ClearAllPoints taint
					ElvUF.ArenaEnemyFrames = _G.ArenaEnemyFrames
					ElvUF.ArenaPrepFrames = _G.ArenaPrepFrames
					_G.ArenaEnemyFrames = nil
					_G.ArenaPrepFrames = nil
				end

				-- actually handle the sub frames now
				local id = strmatch(unit, 'arena(%d)')
				if id then
					HideFrame(_G['ArenaEnemyMatchFrame'..id], true)
					HideFrame(_G['ArenaEnemyPrepFrame'..id], true)
				else
					for i = 1, MAX_ARENA_ENEMIES do
						HideFrame(_G['ArenaEnemyMatchFrame'..i], true)
						HideFrame(_G['ArenaEnemyPrepFrame'..i], true)
					end
				end
			end
		end
	end
end

function UF:ADDON_LOADED(_, addon)
	if addon ~= 'Blizzard_ArenaUI' then return end

	ElvUF:DisableBlizzard('arena')
	UF:UnregisterEvent('ADDON_LOADED')
end

function UF:UnitFrameThreatIndicator_Initialize(_, unitFrame)
	unitFrame:UnregisterAllEvents() -- Arena Taint Fix
end

function UF:ResetUnitSettings(unit)
	local db = UF.db.units[unit]
	local defaults = P.unitframe.units[unit]

	E:CopyTable(db, defaults)

	if db.buffs and db.buffs.sizeOverride then
		db.buffs.sizeOverride = defaults.buffs.sizeOverride or 0
	end

	if db.debuffs and db.debuffs.sizeOverride then
		db.debuffs.sizeOverride = defaults.debuffs.sizeOverride or 0
	end

	UF:Update_AllFrames()
end

function UF:ToggleForceShowFrame(unit)
	local frame = UF[unit]
	if not frame then return end

	if not frame.isForced then
		UF:ForceShow(frame)
	else
		UF:UnforceShow(frame)
	end
end

function UF:ToggleForceShowGroupFrames(group, numGroup)
	for i = 1, numGroup do
		UF:ToggleForceShowFrame(group..i)
	end
end

local Blacklist = {
	player = {
		enable = true,
		aurabars = true,
		fader = true,
		buffs = {
			priority = true,
			minDuration = true,
			maxDuration = true,
		},
		debuffs = {
			priority = true,
			minDuration = true,
			maxDuration = true,
		},
	},
	arena = { enable = true, fader = true },
	assist = { enable = true, fader = true },
	boss = { enable = true, fader = true },
	focus = { enable = true, fader = true },
	focustarget = { enable = true, fader = true },
	pet = { enable = true, fader = true },
	pettarget = { enable = true, fader = true },
	tank = { enable = true, fader = true },
	target = { enable = true, fader = true },
	targettarget = { enable = true, fader = true },
	targettargettarget = { enable = true, fader = true },
	party = { enable = true, fader = true, visibility = true },
	raidpet = { enable = true, fader = true, visibility = true },
}

for i = 1, 3 do
	Blacklist['raid'..i] = { customName = true, enable = true, fader = true, visibility = true }
end

function UF:MergeUnitSettings(from, to)
	E:CopyTable(UF.db.units[to], E:FilterTableFromBlacklist(UF.db.units[from], Blacklist[to]))

	UF:Update_AllFrames()
end

function UF:SetStatusBarColor(bar, r, g, b, custom, overrideAlpha, overrideBackdrop)
	local mainR, mainG, mainB, mainA = r, g, b, E:Clamp((bar.isTransparent and (UF.multiplier * 2)) or 1)
	local bgR, bgG, bgB, bgA = r, g, b, E:Clamp(overrideBackdrop or (bar.isTransparent and (UF.multiplier * 0.5)) or UF.multiplier)

	local color = custom or bar.custom_backdrop
	if color then
		bgR, bgG, bgB, bgA = color.r, color.g, color.b, overrideBackdrop or (overrideAlpha and bgA) or color.a
	end

	if bar.bg then
		if bar.invertColors then
			bar.bg:SetVertexColor(mainR, mainG, mainB, mainA)
		else
			bar.bg:SetVertexColor(bgR, bgG, bgB, bgA)
		end
	end

	if bar.invertColors then
		bar:GetStatusBarTexture():SetVertexColor(bgR, bgG, bgB, bgA)
	else
		bar:GetStatusBarTexture():SetVertexColor(mainR, mainG, mainB, mainA)
	end
end

function UF:PostUpdateColor(_, color, r, g, b) -- r, g, b would be from from UnitPowerType (alternative color for this power type)
	if not r and color then -- color would be the standard color for this power type
		r, g, b = color:GetRGB()
	end

	if r then
		UF:SetStatusBarColor(self, r, g, b)
	end
end

function UF:SetStatusBarBackdropPoints(statusBar, statusBarTex, backdropTex, statusBarOrientation, reverseFill)
	backdropTex:ClearAllPoints()

	if statusBarOrientation == 'VERTICAL' then
		if reverseFill then
			backdropTex:Point('BOTTOMRIGHT', statusBar, 'BOTTOMRIGHT')
			backdropTex:Point('TOPRIGHT', statusBarTex, 'BOTTOMRIGHT')
			backdropTex:Point('TOPLEFT', statusBarTex, 'BOTTOMLEFT')
		else
			backdropTex:Point('TOPLEFT', statusBar, 'TOPLEFT')
			backdropTex:Point('BOTTOMLEFT', statusBarTex, 'TOPLEFT')
			backdropTex:Point('BOTTOMRIGHT', statusBarTex, 'TOPRIGHT')
		end
	else
		if reverseFill then
			backdropTex:Point('TOPRIGHT', statusBarTex, 'TOPLEFT')
			backdropTex:Point('BOTTOMRIGHT', statusBarTex, 'BOTTOMLEFT')
			backdropTex:Point('BOTTOMLEFT', statusBar, 'BOTTOMLEFT')
		else
			backdropTex:Point('TOPLEFT', statusBarTex, 'TOPRIGHT')
			backdropTex:Point('BOTTOMLEFT', statusBarTex, 'BOTTOMRIGHT')
			backdropTex:Point('BOTTOMRIGHT', statusBar, 'BOTTOMRIGHT')
		end
	end
end

function UF:HandleStatusBarTemplate(statusBar, parent, isTransparent)
	if statusBar.backdrop then
		statusBar.backdrop:SetTemplate(isTransparent and 'Transparent', nil, nil, nil, true)
	elseif parent.template then
		parent:SetTemplate(isTransparent and 'Transparent', nil, nil, nil, true)
	end
end

function UF:ToggleTransparentStatusBar(isTransparent, statusBar, backdropTex, adjustBackdropPoints, invertColors, reverseFill)
	statusBar.isTransparent = isTransparent
	statusBar.invertColors = invertColors
	statusBar.backdropTex = backdropTex

	local orientation = statusBar:GetOrientation()
	local barTexture = statusBar:GetStatusBarTexture() -- This fixes Center Pixel offset problem (normally this has > 2 points)
	barTexture:SetInside(nil, 0, 0) -- This also unsnaps the texture

	UF:HandleStatusBarTemplate(statusBar, statusBar:GetParent(), isTransparent)

	if isTransparent then
		statusBar:SetStatusBarTexture(E.media.blankTex)

		UF:Update_StatusBar(statusBar.bg, E.media.blankTex)
		UF:SetStatusBarBackdropPoints(statusBar, barTexture, backdropTex, orientation, reverseFill)
	else
		local texture = LSM:Fetch('statusbar', UF.db.statusbar)
		statusBar:SetStatusBarTexture(texture)

		UF:Update_StatusBar(statusBar.bg, texture)

		if adjustBackdropPoints then
			UF:SetStatusBarBackdropPoints(statusBar, barTexture, backdropTex, orientation, reverseFill)
		end
	end
end

do
	local playID
	function UF:SOUNDKIT_FINISHED(_, soundID)
		if playID == soundID then
			playID = nil
		end
	end

	function UF:TargetSound(unit, _)
		if playID then
			return -- dont play more
		elseif not UnitExists(unit) then
			_, playID = PlaySound(SELECT_LOST, nil, nil, true)
		elseif not IsReplacingUnit() then
			if UnitIsEnemy(unit, 'player') then
				_, playID = PlaySound(SELECT_AGGRO, nil, nil, true)
			elseif UnitIsFriend(unit, 'player') then
				_, playID = PlaySound(SELECT_NPC, nil, nil, true)
			else
				_, playID = PlaySound(SELECT_NEUTRAL, nil, nil, true)
			end
		end
	end
end

function UF:PLAYER_FOCUS_CHANGED()
	if UF.db.targetSound then
		UF:TargetSound('focus')
	end
end

function UF:PLAYER_TARGET_CHANGED()
	if UF.db.targetSound then
		UF:TargetSound('target')
	end
end

do -- Clique support for registering clicks
	function UF:AllowRegisterClicks(frame)
		if _G.Clique and _G.Clique.IsFrameBlacklisted then
			return _G.Clique:IsFrameBlacklisted(frame)
		else
			return true
		end
	end

	local focusUnits = { arena=1, boss=1, tank=1, assist=1, target=1 }
	function UF:RegisterForClicks(frame, db)
		if focusUnits[frame.unitframeType] and not frame.isChild and db then
			if db.middleClickFocus then
				if frame:GetAttribute('type3') ~= 'focus' then
					frame:SetAttribute('type3', 'focus')
				end
			elseif frame:GetAttribute('type3') == 'focus' then
				frame:SetAttribute('type3', nil)
			end
		end

		frame:RegisterForClicks(UF.db.targetOnMouseDown and 'AnyDown' or 'AnyUp')
	end

	local clickFrames = {}
	function UF:UpdateRegisteredClicks()
		for frame in next, clickFrames do
			UF:HandleRegisterClicks(frame, true)
		end
	end

	function UF:HandleRegisterClicks(frame, skip)
		if UF:AllowRegisterClicks(frame) then
			UF:RegisterForClicks(frame, frame.db)
		elseif focusUnits[frame.unitframeType] and frame:GetAttribute('type3') == 'focus' then
			frame:SetAttribute('type3', nil)
		end

		if not skip then
			clickFrames[frame] = true
		end
	end
end

function UF:AfterStyleCallback()
	-- this will wait until after ouf pushes `EnableElement` onto the newly spawned frames
	-- calling an update onto assist or tank in the styleFunc is before the `EnableElement`
	-- that would cause the auras to be shown when a new frame is spawned (tank2, assist2)
	-- even when they are disabled. this makes sure the update happens after so its proper.

	local unit = self.unitframeType
	if unit == 'tank' or unit == 'tanktarget' then
		UF:Update_TankFrames(self, UF.db.units.tank)
		UF:Update_FontStrings()
	elseif unit == 'assist' or unit == 'assisttarget' then
		UF:Update_AssistFrames(self, UF.db.units.assist)
		UF:Update_FontStrings()
	end
end

function UF:Style(unit)
	UF:Construct_UF(self, unit)
end

function UF:Setup()
	ElvUF:RegisterInitCallback(UF.AfterStyleCallback)
	ElvUF:RegisterStyle('ElvUF', UF.Style)
	ElvUF:SetActiveStyle('ElvUF')

	UF:LoadUnits()
	UF:Update_FontStrings()
end

function UF:Initialize()
	UF.thinBorders = UF.db.thinBorders
	UF.maxAllowedGroups = 8
	UF.multiplier = 0.35
	UF.multiplierPrediction = 1.25

	UF.SPACING = (UF.thinBorders or E.twoPixelsPlease) and 0 or 1
	UF.BORDER = (UF.thinBorders and not E.twoPixelsPlease) and 1 or 2

	if not E.private.unitframe.enable then return end
	UF.Initialized = true

	ElvUF:Factory(UF.Setup)

	UF:UpdateColors()

	UF:RegisterEvent('PLAYER_ENTERING_WORLD')
	UF:RegisterEvent('PLAYER_TARGET_CHANGED')
	UF:RegisterEvent('PLAYER_FOCUS_CHANGED')
	UF:RegisterEvent('SOUNDKIT_FINISHED')

	UF:RegisterEvent('SPELLS_CHANGED', 'UpdateRangeSpells')
	UF:RegisterEvent('CHARACTER_POINTS_CHANGED', 'UpdateRangeSpells')

	if E.TBC or E.Retail then
		UF:RegisterEvent('LEARNED_SPELL_IN_SKILL_LINE', 'UpdateRangeSpells')
	else
		UF:RegisterEvent('LEARNED_SPELL_IN_TAB', 'UpdateRangeSpells')
	end

	if E.Retail or E.Wrath or E.Mists then
		UF:RegisterEvent('PLAYER_TALENT_UPDATE', 'UpdateRangeSpells')
	elseif E.ClassicSOD and E.myclass == 'MAGE' then
		UF:RegisterEvent('UNIT_INVENTORY_CHANGED')
	end

	UF:DisableBlizzard()

	hooksecurefunc('CompactRaidGroup_InitializeForGroup', UF.DisableBlizzard_InitializeForGroup)
	hooksecurefunc('CompactUnitFrame_SetUpFrame', UF.DisableBlizzard_SetUpFrame)
	hooksecurefunc('CompactUnitFrame_SetUnit', UF.DisableBlizzard_SetUnit)

	if _G.Clique and _G.Clique.BLACKLIST_CHANGED then
		hooksecurefunc(_G.Clique, 'BLACKLIST_CHANGED', UF.UpdateRegisteredClicks)
	end

	local ORD = E.oUF_RaidDebuffs or _G.oUF_RaidDebuffs
	if ORD then
		ORD.ShowDispellableDebuff = true
		ORD.FilterDispellableDebuff = true
		ORD.MatchBySpellName = false
	end
end

E:RegisterInitialModule(UF:GetName())
