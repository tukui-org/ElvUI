local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:NewModule('UnitFrames', 'AceTimer-3.0', 'AceEvent-3.0', 'AceHook-3.0');
local LSM = LibStub("LibSharedMedia-3.0");
UF.LSM = LSM

--Cache global variables
--Lua functions
local _G = _G
local select, pairs, type, unpack, assert, tostring = select, pairs, type, unpack, assert, tostring
local min = math.min
local tinsert = table.insert
local find, gsub, format = string.find, string.gsub, string.format
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local UnitFrame_OnEnter = UnitFrame_OnEnter
local UnitFrame_OnLeave = UnitFrame_OnLeave
local IsInInstance = IsInInstance
local InCombatLockdown = InCombatLockdown
local CompactRaidFrameManager_GetSetting = CompactRaidFrameManager_GetSetting
local CompactRaidFrameManager_SetSetting = CompactRaidFrameManager_SetSetting
local GetInstanceInfo = GetInstanceInfo
local UnregisterStateDriver = UnregisterStateDriver
local RegisterStateDriver = RegisterStateDriver
local UnregisterAttributeDriver = UnregisterAttributeDriver
local CompactRaidFrameManager_UpdateShown = CompactRaidFrameManager_UpdateShown
local CompactRaidFrameContainer = CompactRaidFrameContainer
local MAX_RAID_MEMBERS = MAX_RAID_MEMBERS
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, ElvCharacterDB, ElvUF_Parent, oUF_RaidDebuffs, CompactRaidFrameManager
-- GLOBALS: PlayerFrame, RuneFrame, PetFrame, TargetFrame, ComboFrame, FocusFrame
-- GLOBALS: FocusFrameToT, TargetFrameToT, CompactUnitFrameProfiles, PartyMemberBackground

local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

UF.headerstoload = {}
UF.unitgroupstoload = {}
UF.unitstoload = {}

UF.groupPrototype = {}
UF.headerPrototype = {}
UF.headers = {}
UF.groupunits = {}
UF.units = {}

UF.statusbars = {}
UF.fontstrings = {}
UF.badHeaderPoints = {
	['TOP'] = 'BOTTOM',
	['LEFT'] = 'RIGHT',
	['BOTTOM'] = 'TOP',
	['RIGHT'] = 'LEFT',
}

UF.headerFunctions = {}
UF.classMaxResourceBar = {
	['DEATHKNIGHT'] = 6,
	['PALADIN'] = 5,
	['WARLOCK'] = 5,
	['MONK'] = 6,
	['MAGE'] = 4,
	['ROGUE'] = 10,
	["DRUID"] = 5
}

UF.instanceMapIDs = {
	[30] = 40, -- Alterac Valley
	[489] = 10, -- Warsong Gulch
	[529] = 15, -- Arathi Basin
	[566] = 15, -- Eye of the Storm
	[607] = 15, -- Strand of the Ancients
	[628] = 40, -- Isle of Conquest
	[726] = 10, -- Twin Peaks
	[727] = 10, -- Silvershard Mines [STVDiamondMineBG]
	[761] = 10, -- The Battle for Gilneas [GilneasBattleground2]
	[968] = 10, -- Rated Eye of the Storm
	[998] = 10, -- Temple of Kotmogu
	[1105] = 15, -- Deepwind Gourge [GoldRush]
	[1280] = 40, -- Tarren Mill vs Southshore [HillsbradFoothillsBG]
	[1681] = 15, -- Arathi Blizzard [ArathiBasinWinter]
	[1803] = 10, -- Seething Shore [AzeriteBG]
	--[1715] = 5, -- Battle for Blackrock Mountain
	--do not have enough information on this one yet, going to store the instanceID for now.
}

UF.headerGroupBy = {
	['CLASS'] = function(header)
		header:SetAttribute("groupingOrder", "DEATHKNIGHT,DEMONHUNTER,DRUID,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK")
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute("groupBy", 'CLASS')
	end,
	['MTMA'] = function(header)
		header:SetAttribute("groupingOrder", "MAINTANK,MAINASSIST,NONE")
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute("groupBy", 'ROLE')
	end,
	['ROLE'] = function(header)
		header:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute("groupBy", 'ASSIGNEDROLE')
	end,
	['NAME'] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute("groupBy", nil)
	end,
	['GROUP'] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute('sortMethod', 'INDEX')
		header:SetAttribute("groupBy", 'GROUP')
	end,
	['CLASSROLE'] = function(header)
		header:SetAttribute("groupingOrder", "DEATHKNIGHT,WARRIOR,DEMONHUNTER,ROGUE,MONK,PALADIN,DRUID,SHAMAN,HUNTER,PRIEST,MAGE,WARLOCK")
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute("groupBy", 'CLASS')
	end,
	['PETNAME'] = function(header)
		header:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		header:SetAttribute('sortMethod', 'NAME')
		header:SetAttribute("groupBy", nil)
		header:SetAttribute("filterOnPet", true) --This is the line that matters. Without this, it sorts based on the owners name
	end,
}

local POINT_COLUMN_ANCHOR_TO_DIRECTION = {
	['TOPTOP'] = 'UP_RIGHT',
	['BOTTOMBOTTOM'] = 'TOP_RIGHT',
	['LEFTLEFT'] = 'RIGHT_UP',
	['RIGHTRIGHT'] = 'LEFT_UP',
	['RIGHTTOP'] = 'LEFT_DOWN',
	['LEFTTOP'] = 'RIGHT_DOWN',
	['LEFTBOTTOM'] = 'RIGHT_UP',
	['RIGHTBOTTOM'] = 'LEFT_UP',
	['BOTTOMRIGHT'] = 'UP_LEFT',
	['BOTTOMLEFT'] = 'UP_RIGHT',
	['TOPRIGHT'] = 'DOWN_LEFT',
	['TOPLEFT'] = 'DOWN_RIGHT'
}

local DIRECTION_TO_POINT = {
	DOWN_RIGHT = "TOP",
	DOWN_LEFT = "TOP",
	UP_RIGHT = "BOTTOM",
	UP_LEFT = "BOTTOM",
	RIGHT_DOWN = "LEFT",
	RIGHT_UP = "LEFT",
	LEFT_DOWN = "RIGHT",
	LEFT_UP = "RIGHT",
	UP = "BOTTOM",
	DOWN = "TOP"
}

local DIRECTION_TO_GROUP_ANCHOR_POINT = {
	DOWN_RIGHT = "TOPLEFT",
	DOWN_LEFT = "TOPRIGHT",
	UP_RIGHT = "BOTTOMLEFT",
	UP_LEFT = "BOTTOMRIGHT",
	RIGHT_DOWN = "TOPLEFT",
	RIGHT_UP = "BOTTOMLEFT",
	LEFT_DOWN = "TOPRIGHT",
	LEFT_UP = "BOTTOMRIGHT",
	OUT_RIGHT_UP = "BOTTOM",
	OUT_LEFT_UP = "BOTTOM",
	OUT_RIGHT_DOWN = "TOP",
	OUT_LEFT_DOWN = "TOP",
	OUT_UP_RIGHT = "LEFT",
	OUT_UP_LEFT = "RIGHT",
	OUT_DOWN_RIGHT = "LEFT",
	OUT_DOWN_LEFT = "RIGHT",
}

local INVERTED_DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	DOWN_RIGHT = "RIGHT",
	DOWN_LEFT = "LEFT",
	UP_RIGHT = "RIGHT",
	UP_LEFT = "LEFT",
	RIGHT_DOWN = "BOTTOM",
	RIGHT_UP = "TOP",
	LEFT_DOWN = "BOTTOM",
	LEFT_UP = "TOP",
	UP = "TOP",
	DOWN = "BOTTOM"
}

local DIRECTION_TO_COLUMN_ANCHOR_POINT = {
	DOWN_RIGHT = "LEFT",
	DOWN_LEFT = "RIGHT",
	UP_RIGHT = "LEFT",
	UP_LEFT = "RIGHT",
	RIGHT_DOWN = "TOP",
	RIGHT_UP = "BOTTOM",
	LEFT_DOWN = "TOP",
	LEFT_UP = "BOTTOM",
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
	local db = self.db.units[group.groupName]
	if db.point and db.columnAnchorPoint then
		db.growthDirection = POINT_COLUMN_ANCHOR_TO_DIRECTION[db.point..db.columnAnchorPoint];
		db.point = nil;
		db.columnAnchorPoint = nil;
	end

	if db.growthDirection == "UP" then
		db.growthDirection = "UP_RIGHT"
	end

	if db.growthDirection == "DOWN" then
		db.growthDirection = "DOWN_RIGHT"
	end
end

function UF:Construct_UF(frame, unit)
	frame:SetScript('OnEnter', UnitFrame_OnEnter)
	frame:SetScript('OnLeave', UnitFrame_OnLeave)

	if(self.thinBorders) then
		frame.SPACING = 0
		frame.BORDER = E.mult
	else
		frame.BORDER = E.Border
		frame.SPACING = E.Spacing
	end

	frame.SHADOW_SPACING = 3
	frame.CLASSBAR_YOFFSET = 0	--placeholder
	frame.BOTTOM_OFFSET = 0 --placeholder

	frame.RaisedElementParent = CreateFrame('Frame', nil, frame)
	frame.RaisedElementParent.TextureParent = CreateFrame('Frame', nil, frame.RaisedElementParent)
	frame.RaisedElementParent:SetFrameLevel(frame:GetFrameLevel() + 100)

	if not self.groupunits[unit] then
		local stringTitle = E:StringTitle(unit)
		if stringTitle:find('target') then
			stringTitle = gsub(stringTitle, 'target', 'Target')
		end
		self["Construct_"..stringTitle.."Frame"](self, frame, unit)
	else
		UF["Construct_"..E:StringTitle(self.groupunits[unit]).."Frames"](self, frame, unit)
	end

	self:Update_StatusBars()
	self:Update_FontStrings()
	return frame
end

function UF:GetObjectAnchorPoint(frame, point)
	if not frame[point] or point == "Frame" then
		return frame
	elseif frame[point] and not frame[point]:IsShown() then
		return frame.Health
	else
		return frame[point]
	end
end

function UF:GetPositionOffset(position, offset)
	if not offset then offset = 2; end
	local x, y = 0, 0
	if find(position, 'LEFT') then
		x = offset
	elseif find(position, 'RIGHT') then
		x = -offset
	end

	if find(position, 'TOP') then
		y = -offset
	elseif find(position, 'BOTTOM') then
		y = offset
	end

	return x, y
end

function UF:GetAuraOffset(p1, p2)
	local x, y = 0, 0
	if p1 == "RIGHT" and p2 == "LEFT" then
		x = -3
	elseif p1 == "LEFT" and p2 == "RIGHT" then
		x = 3
	end

	if find(p1, 'TOP') and find(p2, 'BOTTOM') then
		y = -1
	elseif find(p1, 'BOTTOM') and find(p2, 'TOP') then
		y = 1
	end

	return E:Scale(x), E:Scale(y)
end

function UF:GetAuraAnchorFrame(frame, attachTo, isConflict)
	if isConflict then
		E:Print(format(L["%s frame(s) has a conflicting anchor point, please change either the buff or debuff anchor point so they are not attached to each other. Forcing the debuffs to be attached to the main unitframe until fixed."], E:StringTitle(frame:GetName())))
	end

	if isConflict or attachTo == 'FRAME' then
		return frame
	elseif attachTo == 'TRINKET' then
		if select(2, IsInInstance()) == "arena" then
			return frame.Trinket
		else
			return frame.PVPSpecIcon
		end
	elseif attachTo == 'BUFFS' then
		return frame.Buffs
	elseif attachTo == 'DEBUFFS' then
		return frame.Debuffs
	elseif attachTo == 'HEALTH' then
		return frame.Health
	elseif attachTo == 'POWER' and frame.Power then
		return frame.Power
	else
		return frame
	end
end

function UF:ClearChildPoints(...)
	for i=1, select("#", ...) do
		local child = select(i, ...)
		child:ClearAllPoints()
	end
end

function UF:UpdateColors()
	local db = self.db.colors

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

	if not ElvUF.colors.ComboPoints then ElvUF.colors.ComboPoints = {} end
	ElvUF.colors.ComboPoints[1] = E:SetColorTable(ElvUF.colors.ComboPoints[1], db.classResources.comboPoints[1])
	ElvUF.colors.ComboPoints[2] = E:SetColorTable(ElvUF.colors.ComboPoints[2], db.classResources.comboPoints[2])
	ElvUF.colors.ComboPoints[3] = E:SetColorTable(ElvUF.colors.ComboPoints[3], db.classResources.comboPoints[3])

	--Monk, Mage, Paladin and Warlock, Death Knight
	if not ElvUF.colors.ClassBars then ElvUF.colors.ClassBars = {} end
	if not ElvUF.colors.ClassBars.MONK then ElvUF.colors.ClassBars.MONK = {} end
	ElvUF.colors.ClassBars.PALADIN = E:SetColorTable(ElvUF.colors.ClassBars.PALADIN, db.classResources.PALADIN)
	ElvUF.colors.ClassBars.MAGE = E:SetColorTable(ElvUF.colors.ClassBars.MAGE, db.classResources.MAGE)
	ElvUF.colors.ClassBars.MONK[1] = E:SetColorTable(ElvUF.colors.ClassBars.MONK[1], db.classResources.MONK[1])
	ElvUF.colors.ClassBars.MONK[2] = E:SetColorTable(ElvUF.colors.ClassBars.MONK[2], db.classResources.MONK[2])
	ElvUF.colors.ClassBars.MONK[3] = E:SetColorTable(ElvUF.colors.ClassBars.MONK[3], db.classResources.MONK[3])
	ElvUF.colors.ClassBars.MONK[4] = E:SetColorTable(ElvUF.colors.ClassBars.MONK[4], db.classResources.MONK[4])
	ElvUF.colors.ClassBars.MONK[5] = E:SetColorTable(ElvUF.colors.ClassBars.MONK[5], db.classResources.MONK[5])
	ElvUF.colors.ClassBars.MONK[6] = E:SetColorTable(ElvUF.colors.ClassBars.MONK[6], db.classResources.MONK[6])
	ElvUF.colors.ClassBars.DEATHKNIGHT = E:SetColorTable(ElvUF.colors.ClassBars.DEATHKNIGHT, db.classResources.DEATHKNIGHT)
	ElvUF.colors.ClassBars.WARLOCK = E:SetColorTable(ElvUF.colors.ClassBars.WARLOCK, db.classResources.WARLOCK)

	-- these are just holders.. to maintain and update tables
	if not ElvUF.colors.reaction.good then ElvUF.colors.reaction.good = {} end
	if not ElvUF.colors.reaction.bad then ElvUF.colors.reaction.bad = {} end
	if not ElvUF.colors.reaction.neutral then ElvUF.colors.reaction.neutral = {} end
	ElvUF.colors.reaction.good = E:SetColorTable(ElvUF.colors.reaction.good, db.reaction.GOOD)
	ElvUF.colors.reaction.bad = E:SetColorTable(ElvUF.colors.reaction.bad, db.reaction.BAD)
	ElvUF.colors.reaction.neutral = E:SetColorTable(ElvUF.colors.reaction.neutral, db.reaction.NEUTRAL)

	if not ElvUF.colors.smoothHealth then ElvUF.colors.smoothHealth = {} end
	ElvUF.colors.smoothHealth = E:SetColorTable(ElvUF.colors.smoothHealth, db.health)

	if not ElvUF.colors.smooth then ElvUF.colors.smooth = {1, 0, 0,	1, 1, 0} end
	-- end

	ElvUF.colors.reaction[1] = ElvUF.colors.reaction.bad
	ElvUF.colors.reaction[2] = ElvUF.colors.reaction.bad
	ElvUF.colors.reaction[3] = ElvUF.colors.reaction.bad
	ElvUF.colors.reaction[4] = ElvUF.colors.reaction.neutral
	ElvUF.colors.reaction[5] = ElvUF.colors.reaction.good
	ElvUF.colors.reaction[6] = ElvUF.colors.reaction.good
	ElvUF.colors.reaction[7] = ElvUF.colors.reaction.good
	ElvUF.colors.reaction[8] = ElvUF.colors.reaction.good
	ElvUF.colors.smooth[7] = ElvUF.colors.smoothHealth[1]
	ElvUF.colors.smooth[8] = ElvUF.colors.smoothHealth[2]
	ElvUF.colors.smooth[9] = ElvUF.colors.smoothHealth[3]

	ElvUF.colors.castColor = E:SetColorTable(ElvUF.colors.castColor, db.castColor)
	ElvUF.colors.castNoInterrupt = E:SetColorTable(ElvUF.colors.castNoInterrupt, db.castNoInterrupt)

	if not ElvUF.colors.DebuffHighlight then ElvUF.colors.DebuffHighlight = {} end
	ElvUF.colors.DebuffHighlight.Magic = E:SetColorTable(ElvUF.colors.DebuffHighlight.Magic, db.debuffHighlight.Magic)
	ElvUF.colors.DebuffHighlight.Curse = E:SetColorTable(ElvUF.colors.DebuffHighlight.Curse, db.debuffHighlight.Curse)
	ElvUF.colors.DebuffHighlight.Disease = E:SetColorTable(ElvUF.colors.DebuffHighlight.Disease, db.debuffHighlight.Disease)
	ElvUF.colors.DebuffHighlight.Poison = E:SetColorTable(ElvUF.colors.DebuffHighlight.Poison, db.debuffHighlight.Poison)
end

function UF:Update_StatusBars()
	local statusBarTexture = LSM:Fetch("statusbar", self.db.statusbar)
	for statusbar in pairs(UF.statusbars) do
		if statusbar and statusbar:GetObjectType() == 'StatusBar' and not statusbar.isTransparent then
			statusbar:SetStatusBarTexture(statusBarTexture)
			if statusbar.texture then statusbar.texture = statusBarTexture end --Update .texture on oUF Power element
		elseif statusbar and statusbar:GetObjectType() == 'Texture' then
			statusbar:SetTexture(statusBarTexture)
		end
	end
end

function UF:Update_StatusBar(bar)
	bar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
end

function UF:Update_FontString(object)
	object:FontTemplate(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function UF:Update_FontStrings()
	local stringFont = LSM:Fetch("font", self.db.font)
	for font in pairs(UF.fontstrings) do
		font:FontTemplate(stringFont, self.db.fontSize, self.db.fontOutline)
	end
end

function UF:Configure_FontString(obj)
	UF.fontstrings[obj] = true
	obj:FontTemplate() --This is temporary.
end

function UF:Update_AllFrames()
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return end
	if E.private.unitframe.enable ~= true then return; end
	self:UpdateColors()
	self:Update_FontStrings()
	self:Update_StatusBars()

	for unit in pairs(self.units) do
		if self.db.units[unit].enable then
			self[unit]:Enable()
			self[unit]:Update()
			E:EnableMover(self[unit].mover:GetName())
		else
			self[unit]:Disable()
			E:DisableMover(self[unit].mover:GetName())
		end
	end

	for unit, group in pairs(self.groupunits) do
		if self.db.units[group].enable then
			self[unit]:Enable()
			self[unit]:Update()
			E:EnableMover(self[unit].mover:GetName())
		else
			self[unit]:Disable()
			E:DisableMover(self[unit].mover:GetName())
		end
	end

	self:UpdateAllHeaders()
end

function UF:CreateAndUpdateUFGroup(group, numGroup)
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return end

	for i=1, numGroup do
		local unit = group..i
		local frameName = E:StringTitle(unit)
		frameName = frameName:gsub('t(arget)', 'T%1')
		if not self[unit] then
			self.groupunits[unit] = group;
			self[unit] = ElvUF:Spawn(unit, 'ElvUF_'..frameName)
			self[unit].index = i
			self[unit]:SetParent(ElvUF_Parent)
			self[unit]:SetID(i)
		end

		frameName = E:StringTitle(group)
		frameName = frameName:gsub('t(arget)', 'T%1')
		self[unit].Update = function()
			UF["Update_"..E:StringTitle(frameName).."Frames"](self, self[unit], self.db.units[group])
		end

		if self.db.units[group].enable then
			self[unit]:Enable()

			if group == 'arena' then
				self[unit]:SetAttribute('oUF-enableArenaPrep', true)
			end

			self[unit].Update()

			if self[unit].isForced then
				self:ForceShow(self[unit])
			end
			E:EnableMover(self[unit].mover:GetName())
		else
			self[unit]:Disable()

			if group == 'arena' then
				self[unit]:SetAttribute('oUF-enableArenaPrep', false)
			end

			E:DisableMover(self[unit].mover:GetName())
		end
	end
end

function UF:HeaderUpdateSpecificElement(group, elementName)
	assert(self[group], "Invalid group specified.")
	for i=1, self[group]:GetNumChildren() do
		local frame = select(i, self[group]:GetChildren())
		if frame and frame.Health then
			frame:UpdateElement(elementName)
		end
	end
end

--Keep an eye on this one, it may need to be changed too
--Reference: http://www.tukui.org/forums/topic.php?id=35332
function UF.groupPrototype:GetAttribute(name)
	return self.groups[1]:GetAttribute(name)
end

function UF.groupPrototype:Configure_Groups(self)
	local db = UF.db.units[self.groupName]

	local point
	local width, height, newCols, newRows = 0, 0, 0, 0
	local direction = db.growthDirection
	local xMult, yMult = DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction], DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction]
	local UNIT_HEIGHT = db.infoPanel and db.infoPanel.enable and (db.height + db.infoPanel.height) or db.height
	local groupSpacing = db.groupSpacing

	local numGroups = self.numGroups
	for i=1, numGroups do
		local group = self.groups[i]

		point = DIRECTION_TO_POINT[direction]

		if group then
			UF:ConvertGroupDB(group)
			if point == "LEFT" or point == "RIGHT" then
				group:SetAttribute("xOffset", db.horizontalSpacing * DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[direction])
				group:SetAttribute("yOffset", 0)
				group:SetAttribute("columnSpacing", db.verticalSpacing)
			else
				group:SetAttribute("xOffset", 0)
				group:SetAttribute("yOffset", db.verticalSpacing * DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[direction])
				group:SetAttribute("columnSpacing", db.horizontalSpacing)
			end

			if not group.isForced then
				if not group.initialized then
					group:SetAttribute("startingIndex", db.raidWideSorting and (-min(numGroups * (db.groupsPerRowCol * 5), MAX_RAID_MEMBERS) + 1) or -4)
					group:Show()
					group.initialized = true
				end
				group:SetAttribute('startingIndex', 1)
			end

			group:ClearAllPoints()
			if db.raidWideSorting and db.invertGroupingOrder then
				group:SetAttribute("columnAnchorPoint", INVERTED_DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])
			else
				group:SetAttribute("columnAnchorPoint", DIRECTION_TO_COLUMN_ANCHOR_POINT[direction])
			end

			group:ClearChildPoints()
			group:SetAttribute("point", point)

			if not group.isForced then
				group:SetAttribute("maxColumns", db.raidWideSorting and numGroups or 1)
				group:SetAttribute("unitsPerColumn", db.raidWideSorting and (db.groupsPerRowCol * 5) or 5)
				UF.headerGroupBy[db.groupBy](group)
				group:SetAttribute('sortDir', db.sortDir)
				group:SetAttribute("showPlayer", db.showPlayer)
			end

			if i == 1 and db.raidWideSorting then
				group:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
			else
				group:SetAttribute("groupFilter", tostring(i))
			end
		end

		--MATH!! WOOT
		point = DIRECTION_TO_GROUP_ANCHOR_POINT[direction]
		if db.raidWideSorting and db.startFromCenter then
			point = DIRECTION_TO_GROUP_ANCHOR_POINT["OUT_"..direction]
		end
		if (i - 1) % db.groupsPerRowCol == 0 then
			if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
				if group then
					group:Point(point, self, point, 0, height * yMult)
				end
				height = height + UNIT_HEIGHT + db.verticalSpacing + groupSpacing
				newRows = newRows + 1
			else
				if group then
					group:Point(point, self, point, width * xMult, 0)
				end
				width = width + db.width + db.horizontalSpacing + groupSpacing

				newCols = newCols + 1
			end
		else
			if DIRECTION_TO_POINT[direction] == "LEFT" or DIRECTION_TO_POINT[direction] == "RIGHT" then
				if newRows == 1 then
					if group then
						group:Point(point, self, point, width * xMult, 0)
					end
					width = width + ((db.width + db.horizontalSpacing) * 5) + groupSpacing
					newCols = newCols + 1
				elseif group then
					group:Point(point, self, point, ((((db.width + db.horizontalSpacing) * 5) * ((i-1) % db.groupsPerRowCol))+((i-1) % db.groupsPerRowCol)*groupSpacing) * xMult, (((UNIT_HEIGHT + db.verticalSpacing+groupSpacing) * (newRows - 1))) * yMult)
				end
			else
				if newCols == 1 then
					if group then
						group:Point(point, self, point, 0, height * yMult)
					end
					height = height + ((UNIT_HEIGHT + db.verticalSpacing) * 5) + groupSpacing
					newRows = newRows + 1
				elseif group then
					group:Point(point, self, point, (((db.width + db.horizontalSpacing +groupSpacing) * (newCols - 1))) * xMult, ((((UNIT_HEIGHT + db.verticalSpacing) * 5) * ((i-1) % db.groupsPerRowCol))+((i-1) % db.groupsPerRowCol)*groupSpacing) * yMult)
				end
			end
		end

		if height == 0 then
			height = height + ((UNIT_HEIGHT + db.verticalSpacing) * 5) +groupSpacing
		elseif width == 0 then
			width = width + ((db.width + db.horizontalSpacing) * 5) +groupSpacing
		end
	end

	if not self.isInstanceForced then
		self.dirtyWidth = width - db.horizontalSpacing -groupSpacing
		self.dirtyHeight = height - db.verticalSpacing -groupSpacing
	end

	if self.mover then
		self.mover.positionOverride = DIRECTION_TO_GROUP_ANCHOR_POINT[direction]
		E:UpdatePositionOverride(self.mover:GetName())
		self:GetScript("OnSizeChanged")(self) --Mover size is not updated if frame is hidden, so call an update manually
	end

	self:SetSize(width - db.horizontalSpacing -groupSpacing, height - db.verticalSpacing -groupSpacing)
end

function UF.groupPrototype:Update(self)
	local group = self.groupName

	UF[group].db = UF.db.units[group]
	for i=1, #self.groups do
		self.groups[i].db = UF.db.units[group]
		self.groups[i]:Update()
	end
end

function UF.groupPrototype:AdjustVisibility(self)
	if not self.isForced then
		local numGroups = self.numGroups
		for i=1, #self.groups do
			local group = self.groups[i]
			if (i <= numGroups) and ((self.db.raidWideSorting and i <= 1) or not self.db.raidWideSorting) then
				group:Show()
			else
				if group.forceShow then
					group:Hide()
					UF:UnshowChildUnits(group, group:GetChildren())
					group:SetAttribute('startingIndex', 1)
				else
					group:Reset()
				end
			end
		end
	end
end

function UF.headerPrototype:ClearChildPoints()
	for i=1, self:GetNumChildren() do
		local child = select(i, self:GetChildren())
		child:ClearAllPoints()
	end
end

function UF.headerPrototype:Update(isForced)
	local group = self.groupName
	local db = UF.db.units[group]
	UF["Update_"..E:StringTitle(group).."Header"](UF, self, db, isForced)

	local i = 1
	local child = self:GetAttribute("child" .. i)

	while child do
		UF["Update_"..E:StringTitle(group).."Frames"](UF, child, db)

		if _G[child:GetName()..'Pet'] then
			UF["Update_"..E:StringTitle(group).."Frames"](UF, _G[child:GetName()..'Pet'], db)
		end

		if _G[child:GetName()..'Target'] then
			UF["Update_"..E:StringTitle(group).."Frames"](UF, _G[child:GetName()..'Target'], db)
		end

		i = i + 1
		child = self:GetAttribute("child" .. i)
	end
end

function UF.headerPrototype:Reset()
	self:Hide()

	self:SetAttribute("showPlayer", true)

	self:SetAttribute("showSolo", true)
	self:SetAttribute("showParty", true)
	self:SetAttribute("showRaid", true)

	self:SetAttribute("columnSpacing", nil)
	self:SetAttribute("columnAnchorPoint", nil)
	self:SetAttribute("groupBy", nil)
	self:SetAttribute("groupFilter", nil)
	self:SetAttribute("groupingOrder", nil)
	self:SetAttribute("maxColumns", nil)
	self:SetAttribute("nameList", nil)
	self:SetAttribute("point", nil)
	self:SetAttribute("sortDir", nil)
	self:SetAttribute("sortMethod", "NAME")
	self:SetAttribute("startingIndex", nil)
	self:SetAttribute("strictFiltering", nil)
	self:SetAttribute("unitsPerColumn", nil)
	self:SetAttribute("xOffset", nil)
	self:SetAttribute("yOffset", nil)
end

function UF:CreateHeader(parent, groupFilter, overrideName, template, groupName, headerTemplate)
	local group = parent.groupName or groupName
	local db = UF.db.units[group]
	ElvUF:SetActiveStyle("ElvUF_"..E:StringTitle(group))
	local header = ElvUF:SpawnHeader(overrideName, headerTemplate, nil,
			'oUF-initialConfigFunction', ("self:SetWidth(%d); self:SetHeight(%d);"):format(db.width, db.height),
			'groupFilter', groupFilter,
			'showParty', true,
			'showRaid', true,
			'showSolo', true,
			template and 'template', template)

	header.groupName = group
	header:SetParent(parent)
	header:Show()

	for k, v in pairs(self.headerPrototype) do
		header[k] = v
	end

	return header
end

function UF:CreateAndUpdateHeaderGroup(group, groupFilter, template, headerUpdate, headerTemplate)
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return end
	local db = self.db.units[group]
	local raidFilter = UF.db.smartRaidFilter
	local numGroups = db.numGroups
	if(raidFilter and numGroups and (self[group] and not self[group].blockVisibilityChanges)) then
		local inInstance, instanceType = IsInInstance()
		if(inInstance and (instanceType == 'raid' or instanceType == 'pvp')) then
			local _, _, _, _, maxPlayers, _, _, instanceMapID = GetInstanceInfo()

			if UF.instanceMapIDs[instanceMapID] then
				maxPlayers = UF.instanceMapIDs[instanceMapID]
			end

			if maxPlayers > 0 then
				numGroups = E:Round(maxPlayers/5)
				E:Print(group, "Forcing maxGroups to: "..numGroups.." because maxPlayers is: "..maxPlayers)
			end
		end
	end

	if not self[group] then
		local stringTitle = E:StringTitle(group)
		ElvUF:RegisterStyle("ElvUF_"..stringTitle, UF["Construct_"..stringTitle.."Frames"])
		ElvUF:SetActiveStyle("ElvUF_"..stringTitle)

		if db.numGroups then
			self[group] = CreateFrame('Frame', 'ElvUF_'..stringTitle, ElvUF_Parent, 'SecureHandlerStateTemplate');
			self[group].groups = {}
			self[group].groupName = group
			self[group].template = self[group].template or template
			self[group].headerTemplate = self[group].headerTemplate or headerTemplate
			if not UF.headerFunctions[group] then UF.headerFunctions[group] = {} end
			for k, v in pairs(self.groupPrototype) do
				UF.headerFunctions[group][k] = v
			end
		else
			self[group] = self:CreateHeader(ElvUF_Parent, groupFilter, "ElvUF_"..E:StringTitle(group), template, group, headerTemplate)
		end

		self[group].db = db
		self.headers[group] = self[group]
		self[group]:Show()
	end

	self[group].numGroups = numGroups
	if numGroups then
		if db.raidWideSorting then
			if not self[group].groups[1] then
				self[group].groups[1] = self:CreateHeader(self[group], nil, "ElvUF_"..E:StringTitle(self[group].groupName)..'Group1', template or self[group].template, nil, headerTemplate or self[group].headerTemplate)
			end
		else
			while numGroups > #self[group].groups do
				local index = tostring(#self[group].groups + 1)
				 tinsert(self[group].groups, self:CreateHeader(self[group], index, "ElvUF_"..E:StringTitle(self[group].groupName)..'Group'..index, template or self[group].template, nil, headerTemplate or self[group].headerTemplate))
			end
		end

		UF.headerFunctions[group]:AdjustVisibility(self[group])

		if headerUpdate or not self[group].mover then
			UF.headerFunctions[group]:Configure_Groups(self[group])
			if not self[group].isForced and not self[group].blockVisibilityChanges then
				RegisterStateDriver(self[group], "visibility", db.visibility)
			end
		else
			UF.headerFunctions[group]:Configure_Groups(self[group])
			UF.headerFunctions[group]:Update(self[group])
		end

		if(db.enable) then
			if self[group].mover then
				E:EnableMover(self[group].mover:GetName())
			end
		else
			UnregisterStateDriver(self[group], "visibility")
			self[group]:Hide()
			if self[group].mover then
				E:DisableMover(self[group].mover:GetName())
			end
			return
		end
	else
		self[group].db = db

		if not UF.headerFunctions[group] then UF.headerFunctions[group] = {} end
		UF.headerFunctions[group].Update = function()
			local db = UF.db.units[group]
			if db.enable ~= true then
				UnregisterAttributeDriver(UF[group], "state-visibility")
				UF[group]:Hide()
				if(UF[group].mover) then
					E:DisableMover(UF[group].mover:GetName())
				end
				return
			end
			UF["Update_"..E:StringTitle(group).."Header"](UF, UF[group], db)

			for i=1, UF[group]:GetNumChildren() do
				local child = select(i, UF[group]:GetChildren())
				UF["Update_"..E:StringTitle(group).."Frames"](UF, child, UF.db.units[group])

				if _G[child:GetName()..'Target'] then
					UF["Update_"..E:StringTitle(group).."Frames"](UF, _G[child:GetName()..'Target'], UF.db.units[group])
				end

				if _G[child:GetName()..'Pet'] then
					UF["Update_"..E:StringTitle(group).."Frames"](UF, _G[child:GetName()..'Pet'], UF.db.units[group])
				end
			end

			E:EnableMover(UF[group].mover:GetName())
		end

		if headerUpdate then
			UF["Update_"..E:StringTitle(group).."Header"](self, self[group], db)
		else
			UF.headerFunctions[group]:Update(self[group])
		end
	end
end

function UF:PLAYER_REGEN_ENABLED()
	self:Update_AllFrames()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function UF:CreateAndUpdateUF(unit)
	assert(unit, 'No unit provided to create or update.')
	if InCombatLockdown() then self:RegisterEvent('PLAYER_REGEN_ENABLED'); return end

	local frameName = E:StringTitle(unit)
	frameName = frameName:gsub('t(arget)', 'T%1')
	if not self[unit] then
		self[unit] = ElvUF:Spawn(unit, 'ElvUF_'..frameName)
		self.units[unit] = unit
	end

	self[unit].Update = function()
		UF["Update_"..frameName.."Frame"](self, self[unit], self.db.units[unit])
	end

	if self[unit]:GetParent() ~= ElvUF_Parent then
		self[unit]:SetParent(ElvUF_Parent)
	end

	if self.db.units[unit].enable then
		self[unit]:Enable()
		self[unit].Update()
		E:EnableMover(self[unit].mover:GetName())
	else
		self[unit]:Disable()
		E:DisableMover(self[unit].mover:GetName())
	end
end

function UF:LoadUnits()
	for _, unit in pairs(self.unitstoload) do
		self:CreateAndUpdateUF(unit)
	end
	self.unitstoload = nil

	for group, groupOptions in pairs(self.unitgroupstoload) do
		local numGroup, template = unpack(groupOptions)
		self:CreateAndUpdateUFGroup(group, numGroup, template)
	end
	self.unitgroupstoload = nil

	for group, groupOptions in pairs(self.headerstoload) do
		local groupFilter, template, headerTemplate
		if type(groupOptions) == 'table' then
			groupFilter, template, headerTemplate = unpack(groupOptions)
		end

		self:CreateAndUpdateHeaderGroup(group, groupFilter, template, nil, headerTemplate)
	end
	self.headerstoload = nil
end

function UF:RegisterRaidDebuffIndicator()
	local _, instanceType = IsInInstance();
	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs
	if ORD then
		ORD:ResetDebuffData()

		local instance = E.global.unitframe.raidDebuffIndicator.instanceFilter
		local other = E.global.unitframe.raidDebuffIndicator.otherFilter
		local instanceSpells = ((E.global.unitframe.aurafilters[instance] and E.global.unitframe.aurafilters[instance].spells) or E.global.unitframe.aurafilters.RaidDebuffs.spells)
		local otherSpells = ((E.global.unitframe.aurafilters[other] and E.global.unitframe.aurafilters[other].spells) or E.global.unitframe.aurafilters.CCDebuffs.spells)

		if instanceType == "party" or instanceType == "raid" then
			ORD:RegisterDebuffs(instanceSpells)
		else
			ORD:RegisterDebuffs(otherSpells)
		end
	end
end

function UF:UpdateAllHeaders(event)
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED', 'UpdateAllHeaders')
		return
	end

	if event == 'PLAYER_REGEN_ENABLED' then
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	end

	if E.private.unitframe.disabledBlizzardFrames.party then
		ElvUF:DisableBlizzard('party')
	end

	self:RegisterRaidDebuffIndicator()

	local smartRaidFilterEnabled = self.db.smartRaidFilter
	for group, header in pairs(self.headers) do
		UF.headerFunctions[group]:Update(header)

		local shouldUpdateHeader
		if header.numGroups == nil or smartRaidFilterEnabled then
			shouldUpdateHeader = false
		elseif header.numGroups ~= nil and not smartRaidFilterEnabled then
			shouldUpdateHeader = true
		end
		self:CreateAndUpdateHeaderGroup(group, nil, nil, shouldUpdateHeader)

		if group == 'party' or group == 'raid' or group == 'raid40' then
			--Update BuffIndicators on profile change as they might be using profile specific data
			self:UpdateAuraWatchFromHeader(group)
		end
	end
end

local function HideRaid()
	if InCombatLockdown() then return end
	CompactRaidFrameManager:Kill()
	local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
	if compact_raid and compact_raid ~= "0" then
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

function UF:DisableBlizzard()
	if (not E.private.unitframe.disabledBlizzardFrames.raid) and (not E.private.unitframe.disabledBlizzardFrames.party) then return; end
	if not CompactRaidFrameManager_UpdateShown then
		E:StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
	else
		if not CompactRaidFrameManager.hookedHide then
			hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
			CompactRaidFrameManager:HookScript('OnShow', HideRaid)
			CompactRaidFrameManager.hookedHide = true
		end
		CompactRaidFrameContainer:UnregisterAllEvents()

		HideRaid()
	end
end

local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

local HandleFrame = function(baseName)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		-- Keep frame hidden without causing taint
		frame:SetParent(hiddenParent)

		local health = frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end
	end
end

function ElvUF:DisableBlizzard(unit)
	if(not unit) or InCombatLockdown() then return end

	if(unit == 'player') and E.private.unitframe.disabledBlizzardFrames.player then
		HandleFrame(PlayerFrame)

		-- For the damn vehicle support:
		PlayerFrame:RegisterUnitEvent('UNIT_ENTERING_VEHICLE', "player")
		PlayerFrame:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', "player")
		PlayerFrame:RegisterUnitEvent('UNIT_EXITING_VEHICLE', "player")
		PlayerFrame:RegisterUnitEvent('UNIT_EXITED_VEHICLE', "player")
		PlayerFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

		-- User placed frames don't animate
		PlayerFrame:SetUserPlaced(true)
		PlayerFrame:SetDontSavePosition(true)
		RuneFrame:SetParent(PlayerFrame)
	elseif(unit == 'pet') and E.private.unitframe.disabledBlizzardFrames.player then
		HandleFrame(PetFrame)
	elseif(unit == 'target') and E.private.unitframe.disabledBlizzardFrames.target then
		HandleFrame(TargetFrame)
		HandleFrame(ComboFrame)
	elseif(unit == 'focus') and E.private.unitframe.disabledBlizzardFrames.focus then
		HandleFrame(FocusFrame)
		HandleFrame(FocusFrameToT)
	elseif(unit == 'targettarget') and E.private.unitframe.disabledBlizzardFrames.target then
		HandleFrame(TargetFrameToT)
	elseif(unit:match'(boss)%d?$' == 'boss') and E.private.unitframe.disabledBlizzardFrames.boss then
		local id = unit:match'boss(%d)'
		if(id) then
			HandleFrame('Boss' .. id .. 'TargetFrame')
		else
			for i=1, MAX_BOSS_FRAMES do
				HandleFrame(('Boss%dTargetFrame'):format(i))
			end
		end
	elseif(unit:match'(party)%d?$' == 'party') and E.private.unitframe.disabledBlizzardFrames.party then
		local id = unit:match'party(%d)'
		if(id) then
			HandleFrame('PartyMemberFrame' .. id)
		else
			for i=1, 4 do
				HandleFrame(('PartyMemberFrame%d'):format(i))
			end
		end
		HandleFrame(PartyMemberBackground)
	elseif(unit:match'(arena)%d?$' == 'arena') and E.private.unitframe.disabledBlizzardFrames.arena then
		local id = unit:match'arena(%d)'

		if(id) then
			HandleFrame('ArenaEnemyFrame' .. id)
			HandleFrame('ArenaPrepFrame'..id)
			HandleFrame('ArenaEnemyFrame'..id..'PetFrame')
		else
			for i=1, 5 do
				HandleFrame(('ArenaEnemyFrame%d'):format(i))
				HandleFrame(('ArenaPrepFrame%d'):format(i))
				HandleFrame(('ArenaEnemyFrame%dPetFrame'):format(i))
			end
		end
	end
end

function UF:ADDON_LOADED(_, addon)
	if addon ~= 'Blizzard_ArenaUI' then return; end
	ElvUF:DisableBlizzard('arena')
	self:UnregisterEvent("ADDON_LOADED");
end

local hasEnteredWorld = false
function UF:PLAYER_ENTERING_WORLD()
	if not hasEnteredWorld then
		--We only want to run Update_AllFrames once when we first log in or /reload
		self:Update_AllFrames()
		hasEnteredWorld = true
	else
		local _, instanceType = IsInInstance()
		if instanceType ~= "none" then
			--We need to update headers when we zone into an instance
			UF:UpdateAllHeaders()
		end
	end
end

function UF:UnitFrameThreatIndicator_Initialize(_, unitFrame)
	unitFrame:UnregisterAllEvents() --Arena Taint Fix
end

function UF:ResetUnitSettings(unit)
	E:CopyTable(self.db.units[unit], P.unitframe.units[unit]);

	if self.db.units[unit].buffs and self.db.units[unit].buffs.sizeOverride then
		self.db.units[unit].buffs.sizeOverride = P.unitframe.units[unit].buffs.sizeOverride or 0
	end

	if self.db.units[unit].debuffs and self.db.units[unit].debuffs.sizeOverride then
		self.db.units[unit].debuffs.sizeOverride = P.unitframe.units[unit].debuffs.sizeOverride or 0
	end

	self:Update_AllFrames()
end

function UF:ToggleForceShowGroupFrames(unitGroup, numGroup)
	for i=1, numGroup do
		if self[unitGroup..i] and not self[unitGroup..i].isForced then
			UF:ForceShow(self[unitGroup..i])
		elseif self[unitGroup..i] then
			UF:UnforceShow(self[unitGroup..i])
		end
	end
end

local ignoreSettings = {
	['position'] = true,
	['priority'] = true,
}

local ignoreSettingsGroup = {
	['visibility'] = true,
}

local allowPass = {
	['sizeOverride'] = true,
}

function UF:MergeUnitSettings(fromUnit, toUnit, isGroupUnit)
	local db = self.db.units
	local filter = ignoreSettings
	if isGroupUnit then
		filter = ignoreSettingsGroup
	end
	if fromUnit ~= toUnit then
		for option, value in pairs(db[fromUnit]) do
			if type(value) ~= 'table' and not filter[option] then
				if db[toUnit][option] ~= nil then
					db[toUnit][option] = value
				end
			elseif not filter[option] then
				if type(value) == 'table' then
					for opt, val in pairs(db[fromUnit][option]) do
						--local val = db[fromUnit][option][opt]
						if type(val) ~= 'table' and not filter[opt] then
							if db[toUnit][option] ~= nil and (db[toUnit][option][opt] ~= nil or allowPass[opt]) then
								db[toUnit][option][opt] = val
							end
						elseif not filter[opt] then
							if type(val) == 'table' then
								for o, v in pairs(db[fromUnit][option][opt]) do
									if not filter[o] then
										if db[toUnit][option] ~= nil and db[toUnit][option][opt] ~= nil and db[toUnit][option][opt][o] ~= nil then
											db[toUnit][option][opt][o] = v
										end
									end
								end
							end
						end
					end
				end
			end
		end
	else
		E:Print(L["You cannot copy settings from the same unit."])
	end

	self:Update_AllFrames()
end

local function updateColor(self, r, g, b)
	if not self.isTransparent then return end
	if self.backdrop then
		local _, _, _, a = self.backdrop:GetBackdropColor()
		self.backdrop:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, a)
	elseif self:GetParent().template then
		local _, _, _, a = self:GetParent():GetBackdropColor()
		self:GetParent():SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, a)
	end

	if self.bg and self.bg:GetObjectType() == 'Texture' and not self.bg.multiplier then
		self.bg:SetColorTexture(r * 0.35, g * 0.35, b * 0.35)
	end
end

function UF:ToggleTransparentStatusBar(isTransparent, statusBar, backdropTex, adjustBackdropPoints, invertBackdropTex, reverseFill)
	statusBar.isTransparent = isTransparent

	local statusBarTex = statusBar:GetStatusBarTexture()
	local statusBarOrientation = statusBar:GetOrientation()
	if isTransparent then
		if statusBar.backdrop then
			statusBar.backdrop:SetTemplate("Transparent", nil, nil, nil, true)
			statusBar.backdrop.ignoreUpdates = true
		elseif statusBar:GetParent().template then
			statusBar:GetParent():SetTemplate("Transparent", nil, nil, nil, true)
			statusBar:GetParent().ignoreUpdates = true
		end

		statusBar:SetStatusBarTexture(0, 0, 0, 0)
		if statusBar.texture then statusBar.texture = statusBar:GetStatusBarTexture() end --Needed for Power element

		backdropTex:ClearAllPoints()
		if statusBarOrientation == 'VERTICAL' then
			backdropTex:Point("TOPLEFT", statusBar, "TOPLEFT")
			backdropTex:Point("BOTTOMLEFT", statusBarTex, "TOPLEFT")
			backdropTex:Point("BOTTOMRIGHT", statusBarTex, "TOPRIGHT")
		else
			if reverseFill then
				backdropTex:Point("TOPRIGHT", statusBarTex, "TOPLEFT")
				backdropTex:Point("BOTTOMRIGHT", statusBarTex, "BOTTOMLEFT")
				backdropTex:Point("BOTTOMLEFT", statusBar, "BOTTOMLEFT")
			else
				backdropTex:Point("TOPLEFT", statusBarTex, "TOPRIGHT")
				backdropTex:Point("BOTTOMLEFT", statusBarTex, "BOTTOMRIGHT")
				backdropTex:Point("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT")
			end
		end

		if invertBackdropTex then
			backdropTex:Show()
		end

		if not invertBackdropTex and not statusBar.hookedColor then
			hooksecurefunc(statusBar, "SetStatusBarColor", updateColor)
			statusBar.hookedColor = true
		end

		if backdropTex.multiplier then
			backdropTex.multiplier = 0.25
		end
	else
		if statusBar.backdrop then
			statusBar.backdrop:SetTemplate("Default", nil, nil, not statusBar.PostCastStart and self.thinBorders, true)
			statusBar.backdrop.ignoreUpdates = nil
		elseif statusBar:GetParent().template then
			statusBar:GetParent():SetTemplate("Default", nil, nil, self.thinBorders, true)
			statusBar:GetParent().ignoreUpdates = nil
		end
		statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
		if statusBar.texture then statusBar.texture = statusBar:GetStatusBarTexture() end

		if adjustBackdropPoints then
			backdropTex:ClearAllPoints()
			if statusBarOrientation == 'VERTICAL' then
				backdropTex:Point("TOPLEFT", statusBar, "TOPLEFT")
				backdropTex:Point("BOTTOMLEFT", statusBarTex, "TOPLEFT")
				backdropTex:Point("BOTTOMRIGHT", statusBarTex, "TOPRIGHT")
			else
				if reverseFill then
					backdropTex:Point("TOPRIGHT", statusBarTex, "TOPLEFT")
					backdropTex:Point("BOTTOMRIGHT", statusBarTex, "BOTTOMLEFT")
					backdropTex:Point("BOTTOMLEFT", statusBar, "BOTTOMLEFT")
				else
					backdropTex:Point("TOPLEFT", statusBarTex, "TOPRIGHT")
					backdropTex:Point("BOTTOMLEFT", statusBarTex, "BOTTOMRIGHT")
					backdropTex:Point("BOTTOMRIGHT", statusBar, "BOTTOMRIGHT")
				end
			end
		end

		if invertBackdropTex then
			backdropTex:Hide()
		end

		if backdropTex.multiplier then
			backdropTex.multiplier = 0.25
		end
	end
end

function UF:Initialize()
	self.db = E.db.unitframe
	self.thinBorders = self.db.thinBorders or E.PixelMode
	if E.private.unitframe.enable ~= true then return; end
	E.UnitFrames = UF;

	local ElvUF_Parent = CreateFrame('Frame', 'ElvUF_Parent', E.UIParent, 'SecureHandlerStateTemplate');
	ElvUF_Parent:SetFrameStrata("LOW")
	RegisterStateDriver(ElvUF_Parent, "visibility", "[petbattle] hide; show")

	self:UpdateColors()
	ElvUF:RegisterStyle('ElvUF', function(frame, unit)
		self:Construct_UF(frame, unit)
	end)

	self:LoadUnits()
	self:RegisterEvent('PLAYER_ENTERING_WORLD')

	--InterfaceOptionsFrameCategoriesButton9:SetScale(0.0001)
	--[[if E.private.unitframe.disabledBlizzardFrames.arena and E.private.unitframe.disabledBlizzardFrames.focus and E.private.unitframe.disabledBlizzardFrames.party then
		InterfaceOptionsFrameCategoriesButton10:SetScale(0.0001)
	end

	if E.private.unitframe.disabledBlizzardFrames.target then
		InterfaceOptionsCombatPanelTargetOfTarget:SetScale(0.0001)
		InterfaceOptionsCombatPanelTargetOfTarget:SetAlpha(0)
	end]]

	if E.private.unitframe.disabledBlizzardFrames.party and E.private.unitframe.disabledBlizzardFrames.raid then
		self:DisableBlizzard()
		--InterfaceOptionsFrameCategoriesButton11:SetScale(0.0001)

		self:RegisterEvent('GROUP_ROSTER_UPDATE', 'DisableBlizzard')
		UIParent:UnregisterEvent('GROUP_ROSTER_UPDATE') --This may fuck shit up.. we'll see...
	else
		CompactUnitFrameProfiles:RegisterEvent('VARIABLES_LOADED')
	end

	if (not E.private.unitframe.disabledBlizzardFrames.party) and (not E.private.unitframe.disabledBlizzardFrames.raid) then
		E.RaidUtility.Initialize = E.noop
	end

	if E.private.unitframe.disabledBlizzardFrames.arena then
		self:SecureHook('UnitFrameThreatIndicator_Initialize')

		if not IsAddOnLoaded('Blizzard_ArenaUI') then
			self:RegisterEvent('ADDON_LOADED')
		else
			ElvUF:DisableBlizzard('arena')
		end
	end

	local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs
	if not ORD then return end
	ORD.ShowDispellableDebuff = true
	ORD.FilterDispellableDebuff = true
	ORD.MatchBySpellName = false

	self:UpdateRangeCheckSpells()
end

local function InitializeCallback()
	UF:Initialize()
end

E:RegisterInitialModule(UF:GetName(), InitializeCallback)
