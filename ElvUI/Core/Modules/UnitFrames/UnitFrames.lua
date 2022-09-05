local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM
local ElvUF = E.oUF

local _G = _G
local select, type, unpack, assert, tostring = select, type, unpack, assert, tostring
local huge, strfind, gsub, format, strjoin, strmatch = math.huge, strfind, gsub, format, strjoin, strmatch
local min, next, pairs, ipairs, tinsert, strsub = min, next, pairs, ipairs, tinsert, strsub

local CompactRaidFrameManager_SetSetting = CompactRaidFrameManager_SetSetting
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local hooksecurefunc = hooksecurefunc
local IsReplacingUnit = IsReplacingUnit
local IsAddOnLoaded = IsAddOnLoaded
local RegisterStateDriver = RegisterStateDriver
local UnitExists = UnitExists
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitFrame_OnEnter = UnitFrame_OnEnter
local UnitFrame_OnLeave = UnitFrame_OnLeave
local UnregisterStateDriver = UnregisterStateDriver
local PlaySound = PlaySound
local UnitGUID = UnitGUID

local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local SOUNDKIT_IG_CREATURE_AGGRO_SELECT = SOUNDKIT.IG_CREATURE_AGGRO_SELECT
local SOUNDKIT_IG_CHARACTER_NPC_SELECT = SOUNDKIT.IG_CHARACTER_NPC_SELECT
local SOUNDKIT_IG_CREATURE_NEUTRAL_SELECT = SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT
local SOUNDKIT_INTERFACE_SOUND_LOST_TARGET_UNIT = SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT
local POWERTYPE_ALTERNATE = Enum.PowerType.Alternate or 10
local MAX_BOSS_FRAMES = 8

-- GLOBALS: ElvUF_Parent, Arena_LoadUI
local hiddenParent = CreateFrame('Frame', nil, _G.UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

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
	TOP = 'BOTTOM',
	LEFT = 'RIGHT',
	BOTTOM = 'TOP',
	RIGHT = 'LEFT',
}

UF.headerFunctions = {}
UF.classMaxResourceBar = {
	DEATHKNIGHT = 6,
	PALADIN = 5,
	WARLOCK = 5,
	MONK = 6,
	MAGE = 4,
	ROGUE = 6,
	DRUID = 5
}

UF.SortAuraFuncs = {
	TIME_REMAINING = function(a, b, dir)
		local A = a.noTime and huge or a.expiration or -huge
		local B = b.noTime and huge or b.expiration or -huge
		if dir == 'DESCENDING' then return A < B else return A > B end
	end,
	DURATION = function(a, b, dir)
		local A = a.noTime and huge or a.duration or -huge
		local B = b.noTime and huge or b.duration or -huge
		if dir == 'DESCENDING' then return A < B else return A > B end
	end,
	NAME = function(a, b, dir)
		local A, B = a.name or '', b.name or ''
		if dir == 'DESCENDING' then return A < B else return A > B end
	end,
	PLAYER = function(a, b, dir)
		local A, B = a.isPlayer or false, b.isPlayer or false
		if dir == 'DESCENDING' then return A and not B else return not A and B end
	end,
}

UF.headerGroupBy = {
	CLASS = function(header)
		local groupingOrder = header.db and strjoin(',', header.db.CLASS1, header.db.CLASS2, header.db.CLASS3, header.db.CLASS4, header.db.CLASS5, header.db.CLASS6, header.db.CLASS7, header.db.CLASS8, header.db.CLASS9)
		if E.Retail and groupingOrder then
			groupingOrder = groupingOrder..strjoin(',', header.db.CLASS10, header.db.CLASS11, header.db.CLASS12)
		end

		local sortMethod = header.db and header.db.sortMethod
		header:SetAttribute('groupingOrder', groupingOrder or 'DEATHKNIGHT,DEMONHUNTER,DRUID,HUNTER,MAGE,PALADIN,PRIEST,ROGUE,SHAMAN,WARLOCK,WARRIOR,MONK')
		header:SetAttribute('sortMethod', sortMethod or 'NAME')
		header:SetAttribute('groupBy', 'CLASS')
	end,
	MTMA = function(header)
		local sortMethod = header.db and header.db.sortMethod
		header:SetAttribute('groupingOrder', 'MAINTANK,MAINASSIST,NONE')
		header:SetAttribute('sortMethod', sortMethod or 'NAME')
		header:SetAttribute('groupBy', 'ROLE')
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
	local db = self.db.units[group.groupName]
	if db.point and db.columnAnchorPoint then
		db.growthDirection = POINT_COLUMN_ANCHOR_TO_DIRECTION[db.point..db.columnAnchorPoint]
		db.point = nil
		db.columnAnchorPoint = nil
	end

	if db.growthDirection == 'UP' then
		db.growthDirection = 'UP_RIGHT'
	end

	if db.growthDirection == 'DOWN' then
		db.growthDirection = 'DOWN_RIGHT'
	end
end

function UF:CreateRaisedText(raised)
	local text = raised:CreateFontString(nil, 'OVERLAY')
	UF:Configure_FontString(text)

	return text
end

function UF:CreateRaisedElement(frame, bar)
	local raised = CreateFrame('Frame', nil, frame)
	local level = frame:GetFrameLevel() + 100
	raised:SetFrameLevel(level)
	raised.__owner = frame

	-- layer levels (level +1 is icons)
	raised.AuraLevel = level
	raised.AuraBarLevel = level + 10
	raised.RaidDebuffLevel = level + 15
	raised.AuraWatchLevel = level + 20
	raised.RestingIconLevel = level + 25
	raised.RaidRoleLevel = level + 30
	raised.CastBarLevel = level + 35

	if bar then
		raised:SetAllPoints()
	else
		raised.TextureParent = CreateFrame('Frame', nil, raised)
	end

	return raised
end

function UF:SetAlpha_MouseTags(mousetags, alpha)
	if not mousetags then return end
	for fs in next, mousetags do
		fs:SetAlpha(alpha)
	end
end

function UF:UnitFrame_OnEnter(...)
	UnitFrame_OnEnter(self, ...)
	UF:SetAlpha_MouseTags(self.__mousetags, 1)
end

function UF:UnitFrame_OnLeave(...)
	UnitFrame_OnLeave(self, ...)
	UF:SetAlpha_MouseTags(self.__mousetags, 0)
end

function UF:Construct_UF(frame, unit)
	frame:SetScript('OnEnter', UF.UnitFrame_OnEnter)
	frame:SetScript('OnLeave', UF.UnitFrame_OnLeave)
	frame.RaisedElementParent = UF:CreateRaisedElement(frame)

	frame.SHADOW_SPACING = 3
	frame.CLASSBAR_YOFFSET = 0 --placeholder
	frame.BOTTOM_OFFSET = 0 --placeholder

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

function UF:ClearChildPoints(...)
	for i=1, select('#', ...) do
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
	ElvUF.colors.power[POWERTYPE_ALTERNATE] = E:SetColorTable(ElvUF.colors.power[POWERTYPE_ALTERNATE], db.power.ALT_POWER)
	ElvUF.colors.chargedComboPoint = E:SetColorTable(ElvUF.colors.chargedComboPoint, db.classResources.chargedComboPoint)

	for i = 0, 3 do
		ElvUF.colors.threat[i] = E:SetColorTable(ElvUF.colors.threat[i], db.threat[i])
	end

	for i = 1, 3 do
		ElvUF.colors.happiness[i] = E:SetColorTable(ElvUF.colors.happiness[i], db.happiness[i])
	end

	for i = 0, 9 do
		if i ~= 4 then -- selection doesnt have 4 and skips to 13
			ElvUF.colors.selection[i] = E:SetColorTable(ElvUF.colors.selection[i], db.selection[i])
		end
	end
	ElvUF.colors.selection[13] = E:SetColorTable(ElvUF.colors.selection[13], db.selection[13])

	if not ElvUF.colors.ComboPoints then ElvUF.colors.ComboPoints = {} end
	for i=1, 6 do
		ElvUF.colors.ComboPoints[i] = E:SetColorTable(ElvUF.colors.ComboPoints[i], db.classResources.comboPoints[i])
	end

	--Monk, Mage, Paladin and Warlock, Death Knight
	if not ElvUF.colors.ClassBars then ElvUF.colors.ClassBars = {} end
	ElvUF.colors.ClassBars.PALADIN = E:SetColorTable(ElvUF.colors.ClassBars.PALADIN, db.classResources.PALADIN)
	ElvUF.colors.ClassBars.MAGE = E:SetColorTable(ElvUF.colors.ClassBars.MAGE, db.classResources.MAGE)
	ElvUF.colors.ClassBars.WARLOCK = E:SetColorTable(ElvUF.colors.ClassBars.WARLOCK, db.classResources.WARLOCK)

	if not ElvUF.colors.ClassBars.MONK then ElvUF.colors.ClassBars.MONK = {} end
	for i=1, 6 do
		ElvUF.colors.ClassBars.MONK[i] = E:SetColorTable(ElvUF.colors.ClassBars.MONK[i], db.classResources.MONK[i])
	end

	if not ElvUF.colors.ClassBars.DEATHKNIGHT then ElvUF.colors.ClassBars.DEATHKNIGHT = {} end
	for i = -1, 4 do
		ElvUF.colors.ClassBars.DEATHKNIGHT[i] = E:SetColorTable(ElvUF.colors.ClassBars.DEATHKNIGHT[i], db.classResources.DEATHKNIGHT[i])
	end

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
	local statusBarTexture = LSM:Fetch('statusbar', self.db.statusbar)
	for statusbar in pairs(UF.statusbars) do
		if statusbar then
			local useBlank = statusbar.isTransparent
			if statusbar.parent then
				useBlank = statusbar.parent.isTransparent
			end
			if statusbar:IsObjectType('StatusBar') then
				if not useBlank then
					statusbar:SetStatusBarTexture(statusBarTexture)
				end
			elseif statusbar:IsObjectType('Texture') then
				statusbar:SetTexture(statusBarTexture)
			end

			UF:Update_StatusBar(statusbar.bg or statusbar.BG, (not useBlank and statusBarTexture) or E.media.blankTex)
		end
	end
end

function UF:Update_StatusBar(statusbar, texture)
	if not statusbar then return end
	if not texture then texture = LSM:Fetch('statusbar', self.db.statusbar) end

	if statusbar:IsObjectType('StatusBar') then
		statusbar:SetStatusBarTexture(texture)
	elseif statusbar:IsObjectType('Texture') then
		statusbar:SetTexture(texture)
	end
end

function UF:Update_FontString(object)
	object:FontTemplate(LSM:Fetch('font', self.db.font), self.db.fontSize, self.db.fontOutline)
end

function UF:Update_FontStrings()
	local font, size, outline = LSM:Fetch('font', self.db.font), self.db.fontSize, self.db.fontOutline
	for obj in pairs(UF.fontstrings) do
		obj:FontTemplate(font, size, outline)
	end
end

function UF:Construct_Fader()
	return { UpdateRange = UF.UpdateRange }
end

function UF:Configure_Fader(frame)
	if frame.db and frame.db.enable and (frame.db.fader and frame.db.fader.enable) then
		if not frame:IsElementEnabled('Fader') then
			frame:EnableElement('Fader')
		end

		frame.Fader:SetOption('Hover', frame.db.fader.hover)
		frame.Fader:SetOption('Combat', frame.db.fader.combat)
		frame.Fader:SetOption('PlayerTarget', frame.db.fader.playertarget)
		frame.Fader:SetOption('Focus', frame.db.fader.focus)
		frame.Fader:SetOption('Health', frame.db.fader.health)
		frame.Fader:SetOption('Power', frame.db.fader.power)
		frame.Fader:SetOption('Vehicle', frame.db.fader.vehicle)
		frame.Fader:SetOption('Casting', frame.db.fader.casting)
		frame.Fader:SetOption('MinAlpha', frame.db.fader.minAlpha)
		frame.Fader:SetOption('MaxAlpha', frame.db.fader.maxAlpha)

		if frame ~= _G.ElvUF_Player then
			frame.Fader:SetOption('Range', frame.db.fader.range)
			frame.Fader:SetOption('UnitTarget', frame.db.fader.unittarget)
		end

		frame.Fader:SetOption('Smooth', (frame.db.fader.smooth > 0 and frame.db.fader.smooth) or nil)
		frame.Fader:SetOption('Delay', (frame.db.fader.delay > 0 and frame.db.fader.delay) or nil)

		frame.Fader:ClearTimers()
		frame.Fader.configTimer = E:ScheduleTimer(frame.Fader.ForceUpdate, 0.25, frame.Fader, true)
	elseif frame:IsElementEnabled('Fader') then
		frame:DisableElement('Fader')
		E:UIFrameFadeIn(frame, 1, frame:GetAlpha(), 1)
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

	UF:UpdateColors()
	UF:Update_FontStrings()
	UF:Update_StatusBars()

	for unit in pairs(UF.units) do
		UF[unit]:Update()
		if UF.db.units[unit].enable then
			UF[unit]:Enable()
			E:EnableMover(UF[unit].mover:GetName())
		else
			UF[unit]:Disable()
			E:DisableMover(UF[unit].mover:GetName())
		end
	end

	for unit, group in pairs(UF.groupunits) do
		if UF.db.units[group].enable then
			UF[unit]:Enable()
			UF[unit]:Update()
			E:EnableMover(UF[unit].mover:GetName())
		else
			UF[unit]:Disable()
			E:DisableMover(UF[unit].mover:GetName())
		end

		if UF[unit].isForced then
			UF:ForceShow(UF[unit])
		end
	end

	UF:UpdateAllHeaders()
end

function UF:CreateAndUpdateUFGroup(group, numGroup)
	for i=1, numGroup do
		local unit = group..i
		local frameName = gsub(E:StringTitle(unit), 't(arget)', 'T%1')
		local frame = self[unit]

		if not frame then
			self.groupunits[unit] = group
			frame = ElvUF:Spawn(unit, 'ElvUF_'..frameName)
			frame.index = i
			frame:SetParent(ElvUF_Parent)
			frame:SetID(i)
			self[unit] = frame
		end

		frameName = gsub(E:StringTitle(group), 't(arget)', 'T%1')
		frame.Update = function()
			UF['Update_'..E:StringTitle(frameName)..'Frames'](self, frame, self.db.units[group])
		end

		if self.db.units[group].enable then
			frame:Enable()

			if group == 'arena' then
				frame:SetAttribute('oUF-enableArenaPrep', true)
			end

			frame.Update()

			E:EnableMover(frame.mover:GetName())
		else
			frame:Disable()

			if group == 'arena' then
				frame:SetAttribute('oUF-enableArenaPrep', false)
			end

			-- for some reason the boss/arena 'uncheck disable' doesnt fire this, we need to so putting it here.
			if group == 'boss' or group == 'arena' then
				UF:Configure_Fader(frame)
			end

			E:DisableMover(frame.mover:GetName())
		end

		if frame.isForced then
			self:ForceShow(frame)
		end
	end
end

function UF:HeaderUpdateSpecificElement(group, elementName)
	local Header = self[group]
	assert(Header, 'Invalid group specified.')

	for i=1, Header:GetNumChildren() do
		local frame = select(i, Header:GetChildren())
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
				UF.headerGroupBy[groupBy](group)
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

function UF.groupPrototype:Update(Header)
	local group = Header.groupName

	UF[group].db = UF.db.units[group]

	for _, Group in ipairs(Header.groups) do
		Group.db = UF.db.units[group]
		Group:Update()
	end
end

function UF.groupPrototype:AdjustVisibility(Header)
	if not Header.isForced then
		local numGroups = Header.numGroups
		for i, group in ipairs(Header.groups) do
			if i <= numGroups and ((Header.db.raidWideSorting and i <= 1) or not Header.db.raidWideSorting) then
				group:Show()
			else
				if group.forceShow then
					group:Hide()
					group:SetAttribute('startingIndex', 1)
					UF:UnshowChildUnits(group, group:GetChildren())
				else
					group:Reset()
				end
			end
		end
	end
end

function UF.headerPrototype:ClearChildPoints()
	for _, child in pairs({ self:GetChildren() }) do
		child:ClearAllPoints()
	end
end

function UF.headerPrototype:UpdateChild(func, child, db)
	func(UF, child, db)

	local name = child:GetName()

	local target = name..'Target'
	if _G[target] then func(UF, _G[target], db) end

	local pet = name..'Pet'
	if _G[pet] then func(UF, _G[pet], db) end
end

function UF.headerPrototype:Update(isForced)
	local group = self.groupName
	local db = UF.db.units[group]

	UF[self.UpdateHeader](UF, self, db, isForced)

	local i = 1
	local child = self:GetAttribute('child' .. i)
	local func = UF[self.UpdateFrames]

	while child do
		self:UpdateChild(func, child, db)

		i = i + 1
		child = self:GetAttribute('child' .. i)
	end
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

function UF:SetMaxAllowedGroups()
	if UF.db.maxAllowedGroups then
		local _, instanceType, difficultyID = GetInstanceInfo()
		UF.maxAllowedGroups = (difficultyID == 16 and 4) or (instanceType == 'raid' and 6) or 8
	else
		UF.maxAllowedGroups = 8
	end
end

function UF:PLAYER_ENTERING_WORLD(_, initLogin, isReload)
	UF:RegisterRaidDebuffIndicator()
	UF:SetMaxAllowedGroups()

	if initLogin then
		UF:Update_AllFrames()
	elseif isReload then
		UF:Update_AllFrames()
	end
end

function UF:CreateHeader(parent, groupFilter, overrideName, template, groupName, headerTemplate)
	local group = parent.groupName or groupName
	local db = UF.db.units[group]
	ElvUF:SetActiveStyle('ElvUF_'..E:StringTitle(group))

	local header = ElvUF:SpawnHeader(overrideName, headerTemplate, nil,
		'oUF-initialConfigFunction', format('self:SetWidth(%d); self:SetHeight(%d);', db.width, db.height),
		'groupFilter', groupFilter, 'showParty', true, 'showRaid', group ~= 'party', 'showSolo', true,
		template and 'template', template
	)

	header.groupName = group

	header.UpdateHeader = format('Update_%sHeader', parent.isRaidFrame and 'Raid' or E:StringTitle(group))
	header.UpdateFrames = format('Update_%sFrames', parent.isRaidFrame and 'Raid' or E:StringTitle(group))

	header:SetParent(parent)
	header:Show()

	for k, v in pairs(UF.headerPrototype) do
		header[k] = v
	end

	return header
end

function UF:CreateAndUpdateHeaderGroup(group, groupFilter, template, headerTemplate, skip)
	local db = UF.db.units[group]
	local Header = UF[group]

	local enable = db.enable
	local visibility = db.visibility
	local numGroups = (group == 'party' and 1) or (db.numGroups and min(UF.maxAllowedGroups or 8, db.numGroups))
	local name, isRaidFrames = E:StringTitle(group), strmatch(group, '^raid(%d)') and true

	if not Header then
		ElvUF:RegisterStyle('ElvUF_'..name, UF[format('Construct_%sFrames', isRaidFrames and 'Raid' or name)])
		ElvUF:SetActiveStyle('ElvUF_'..name)

		if numGroups then
			Header = CreateFrame('Frame', 'ElvUF_'..name, ElvUF_Parent, 'SecureHandlerStateTemplate')
			Header.groups = {}
			Header.groupName = group
			Header.template = Header.template or template
			Header.headerTemplate = Header.headerTemplate or headerTemplate
			Header.isRaidFrame = isRaidFrames
			Header.raidFrameN = isRaidFrames and gsub(group, '.-(%d)', '%1')
			if not UF.headerFunctions[group] then UF.headerFunctions[group] = {} end
			for k, v in pairs(self.groupPrototype) do
				UF.headerFunctions[group][k] = v
			end
		else
			Header = self:CreateHeader(ElvUF_Parent, groupFilter, 'ElvUF_'..name, template, group, headerTemplate)
		end

		Header:Show()

		self[group] = Header
		self.headers[group] = Header
	end

	local groupsChanged = (Header.numGroups ~= numGroups)
	local stateChanged = (Header.enableState ~= enable)
	Header.enableState = enable
	Header.numGroups = numGroups
	Header.db = db

	if numGroups then
		if db.raidWideSorting then
			if not Header.groups[1] then
				Header.groups[1] = self:CreateHeader(Header, nil, 'ElvUF_'..name..'Group1', template or Header.template, nil, headerTemplate or Header.headerTemplate)
			end
		else
			while numGroups > #Header.groups do
				local index = tostring(#Header.groups + 1)
				tinsert(Header.groups, self:CreateHeader(Header, index, 'ElvUF_'..name..'Group'..index, template or Header.template, nil, headerTemplate or Header.headerTemplate))
			end
		end

		if groupsChanged or not skip then
			UF.headerFunctions[group]:AdjustVisibility(Header)
			UF.headerFunctions[group]:Configure_Groups(Header)
		end
	else
		if not UF.headerFunctions[group] then UF.headerFunctions[group] = {} end
		if not UF.headerFunctions[group].Update then
			UF.headerFunctions[group].Update = function()
				UF[Header.UpdateHeader](UF, Header, Header.db)

				for _, child in ipairs({ Header:GetChildren() }) do
					Header:UpdateChild(UF[Header.UpdateFrames], child, Header.db)
				end
			end
		end
	end

	if stateChanged or not skip then
		UF.headerFunctions[group]:Update(Header)
	end

	if enable then
		if not Header.isForced then
			RegisterStateDriver(Header, 'visibility', visibility)
		end
		if Header.mover then
			E:EnableMover(Header.mover:GetName())
		end
	else
		UnregisterStateDriver(Header, 'visibility')
		Header:Hide()
		if Header.mover then
			E:DisableMover(Header.mover:GetName())
		end
	end
end

function UF:CreateAndUpdateUF(unit)
	assert(unit, 'No unit provided to create or update.')

	local frameName = gsub(E:StringTitle(unit), 't(arget)', 'T%1')
	if not self[unit] then
		self[unit] = ElvUF:Spawn(unit, 'ElvUF_'..frameName)
		self.units[unit] = unit
	end

	self[unit].Update = function()
		UF['Update_'..frameName..'Frame'](self, self[unit], self.db.units[unit])
	end

	if self[unit]:GetParent() ~= ElvUF_Parent then
		self[unit]:SetParent(ElvUF_Parent)
	end

	if self.db.units[unit].enable then
		self[unit]:Enable()
		self[unit].Update()
		E:EnableMover(self[unit].mover:GetName())
	else
		self[unit].Update()
		self[unit]:Disable()
		E:DisableMover(self[unit].mover:GetName())
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

		local dispelColor = ORD:GetDispelColor()
		E:CopyTable(dispelColor.none, E.media.bordercolor)
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

function UF:DisableBlizzard()
	if (not E.private.unitframe.disabledBlizzardFrames.raid) and (not E.private.unitframe.disabledBlizzardFrames.party) then return end
	if not CompactRaidFrameManager_SetSetting then
		E:StaticPopup_Show('WARNING_BLIZZARD_ADDONS')
	else
		CompactRaidFrameManager_SetSetting('IsShown', '0')
		_G.UIParent:UnregisterEvent('GROUP_ROSTER_UPDATE')
		_G.CompactRaidFrameManager:UnregisterAllEvents()
		_G.CompactRaidFrameManager:SetParent(hiddenParent)
	end
end

do
	local function EventlessUpdate(frame, elapsed)
		if not frame.unit or not UnitExists(frame.unit) then
			return
		else
			local frequency = frame.elapsed or 0
			if frequency > frame.onUpdateElements then
				local guid = UnitGUID(frame.unit)
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
		if not frame.onUpdateElements then frame.onUpdateElements = 0.2 end
		if not frame.onUpdatePrediction then frame.onUpdatePrediction = 0.4 end
		if not frame.onUpdateAuras then frame.onUpdateAuras = 0.6 end

		frame.__eventless = true
		frame:SetScript('OnUpdate', EventlessUpdate)
	end
end

do
	local disabledPlates = {}
	local function HandleFrame(baseName, doNotReparent)
		local frame
		if type(baseName) == 'string' then
			frame = _G[baseName]
		else
			frame = baseName
		end

		if frame then
			frame:UnregisterAllEvents()
			frame:Hide()

			if not doNotReparent then
				frame:SetParent(hiddenParent)
			end

			local health = frame.healthBar or frame.healthbar
			if health then
				health:UnregisterAllEvents()
			end

			local power = frame.manabar
			if power then
				power:UnregisterAllEvents()
			end

			local spell = frame.castBar or frame.spellbar
			if spell then
				spell:UnregisterAllEvents()
			end

			local altpowerbar = frame.powerBarAlt
			if altpowerbar then
				altpowerbar:UnregisterAllEvents()
			end

			local buffFrame = frame.BuffFrame
			if buffFrame then
				buffFrame:UnregisterAllEvents()
			end
		end
	end

	function ElvUF:DisableBlizzard(unit)
		if not unit then return end

		if unit == 'player' and E.private.unitframe.disabledBlizzardFrames.player then
			local PlayerFrame = _G.PlayerFrame
			HandleFrame(PlayerFrame)

			-- For the damn vehicle support:
			PlayerFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
			PlayerFrame:RegisterEvent('UNIT_ENTERING_VEHICLE')
			PlayerFrame:RegisterEvent('UNIT_ENTERED_VEHICLE')
			PlayerFrame:RegisterEvent('UNIT_EXITING_VEHICLE')
			PlayerFrame:RegisterEvent('UNIT_EXITED_VEHICLE')

			-- User placed frames don't animate
			PlayerFrame:SetMovable(true)
			PlayerFrame:SetUserPlaced(true)
			PlayerFrame:SetDontSavePosition(true)
		elseif unit == 'pet' and E.private.unitframe.disabledBlizzardFrames.player then
			HandleFrame(_G.PetFrame)
		elseif unit == 'target' and E.private.unitframe.disabledBlizzardFrames.target then
			HandleFrame(_G.TargetFrame)
			HandleFrame(_G.ComboFrame)
		elseif unit == 'focus' and E.private.unitframe.disabledBlizzardFrames.focus then
			HandleFrame(_G.FocusFrame)
			HandleFrame(_G.TargetofFocusFrame)
		elseif unit == 'targettarget' and E.private.unitframe.disabledBlizzardFrames.target then
			HandleFrame(_G.TargetFrameToT)
		elseif strmatch(unit, 'boss%d?$') and E.private.unitframe.disabledBlizzardFrames.boss then
			local id = strmatch(unit, 'boss(%d)')
			if id then
				HandleFrame('Boss' .. id .. 'TargetFrame')
			else
				for i = 1, MAX_BOSS_FRAMES do
					HandleFrame(format('Boss%dTargetFrame', i))
				end
			end
		elseif strmatch(unit, 'party%d?$') and E.private.unitframe.disabledBlizzardFrames.party then
			local id = strmatch(unit, 'party(%d)')
			if id then
				HandleFrame('PartyMemberFrame' .. id)
			else
				for i=1, _G.MAX_PARTY_MEMBERS do
					HandleFrame(format('PartyMemberFrame%d', i))
				end
			end
			HandleFrame(_G.PartyMemberBackground)
		elseif strmatch(unit, 'arena%d?$') and E.private.unitframe.disabledBlizzardFrames.arena then
			local id = strmatch(unit, 'arena(%d)')
			if id then
				HandleFrame('ArenaEnemyFrame' .. id)
			else
				for i = 1, _G.MAX_ARENA_ENEMIES do
					HandleFrame(format('ArenaEnemyFrame%d', i))
				end
			end

			if _G.ArenaEnemyFrames then
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
		elseif strmatch(unit, 'nameplate%d+$') then
			local frame = C_NamePlate_GetNamePlateForUnit(unit)
			local plate = frame and frame.UnitFrame
			if plate and not disabledPlates[plate] then
				disabledPlates[plate] = true

				HandleFrame(plate, true)

				hooksecurefunc(plate, 'Show', plate.Hide)
			end
		end
	end
end

function UF:ADDON_LOADED(_, addon)
	if addon ~= 'Blizzard_ArenaUI' then return end

	ElvUF:DisableBlizzard('arena')
	self:UnregisterEvent('ADDON_LOADED')
end

function UF:UnitFrameThreatIndicator_Initialize(_, unitFrame)
	unitFrame:UnregisterAllEvents() -- Arena Taint Fix
end

function UF:ResetUnitSettings(unit)
	E:CopyTable(self.db.units[unit], P.unitframe.units[unit])

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
	Blacklist['raid'..i] = { enable = true, fader = true, visibility = true }
end

function UF:MergeUnitSettings(from, to)
	if from == to then
		E:Print(L["You cannot copy settings from the same unit."])
		return
	end

	E:CopyTable(UF.db.units[to], E:FilterTableFromBlacklist(UF.db.units[from], Blacklist[to]))

	UF:Update_AllFrames()
end

function UF:UpdateBackdropTextureColor(r, g, b, a)
	local m = 0.35
	local n = self.isTransparent and (m * 2) or m

	if self.invertColors then
		local nn = n;n=m;m=nn
	end

	if self.isTransparent then
		if self.backdrop then
			self.backdrop:SetBackdropColor(r * n, g * n, b * n, a or E.media.backdropfadecolor[4])
		else
			local parent = self:GetParent()
			if parent and parent.template then
				parent:SetBackdropColor(r * n, g * n, b * n, a or E.media.backdropfadecolor[4])
			end
		end
	end

	local bg = self.bg or self.BG
	if bg and bg:IsObjectType('Texture') and not bg.multiplier then
		if self.custom_backdrop then
			bg:SetVertexColor(self.custom_backdrop.r, self.custom_backdrop.g, self.custom_backdrop.b, self.custom_backdrop.a or 1)
		else
			bg:SetVertexColor(r * m, g * m, b * m, 1)
		end
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

	if not statusBar.hookedColor then
		hooksecurefunc(statusBar, 'SetStatusBarColor', UF.UpdateBackdropTextureColor)
		statusBar.hookedColor = true
	end

	local orientation = statusBar:GetOrientation()
	local barTexture = statusBar:GetStatusBarTexture() -- This fixes Center Pixel offset problem (normally this has > 2 points)
	barTexture:SetInside(nil, 0, 0) -- This also unsnaps the texture

	UF:HandleStatusBarTemplate(statusBar, statusBar:GetParent(), isTransparent)

	if isTransparent then
		statusBar:SetStatusBarTexture(0, 0, 0, 0)
		UF:Update_StatusBar(statusBar.bg or statusBar.BG, E.media.blankTex)

		UF:SetStatusBarBackdropPoints(statusBar, barTexture, backdropTex, orientation, reverseFill)
	else
		local texture = LSM:Fetch('statusbar', self.db.statusbar)
		statusBar:SetStatusBarTexture(texture)
		UF:Update_StatusBar(statusBar.bg or statusBar.BG, texture)

		if adjustBackdropPoints then
			UF:SetStatusBarBackdropPoints(statusBar, barTexture, backdropTex, orientation, reverseFill)
		end
	end
end

function UF:TargetSound(unit)
	if UnitExists(unit) and not IsReplacingUnit() then
		if UnitIsEnemy(unit, 'player') then
			PlaySound(SOUNDKIT_IG_CREATURE_AGGRO_SELECT)
		elseif UnitIsFriend(unit, 'player') then
			PlaySound(SOUNDKIT_IG_CHARACTER_NPC_SELECT)
		else
			PlaySound(SOUNDKIT_IG_CREATURE_NEUTRAL_SELECT)
		end
	else
		PlaySound(SOUNDKIT_INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

function UF:PLAYER_FOCUS_CHANGED()
	if E.db.unitframe.targetSound then
		UF:TargetSound('focus')
	end
end

function UF:PLAYER_TARGET_CHANGED()
	if E.db.unitframe.targetSound then
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
	if self.unitframeType == 'tank' or self.unitframeType == 'tanktarget' then
		UF:Update_TankFrames(self, E.db.unitframe.units.tank)
		UF:Update_FontStrings()
	elseif self.unitframeType == 'assist' or self.unitframeType == 'assisttarget' then
		UF:Update_AssistFrames(self, E.db.unitframe.units.assist)
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
end

function UF:Initialize()
	UF.db = E.db.unitframe
	UF.thinBorders = UF.db.thinBorders

	UF.SPACING = (UF.thinBorders or E.twoPixelsPlease) and 0 or 1
	UF.BORDER = (UF.thinBorders and not E.twoPixelsPlease) and 1 or 2

	if not E.private.unitframe.enable then return end
	UF.Initialized = true

	E.ElvUF_Parent = CreateFrame('Frame', 'ElvUF_Parent', E.UIParent, 'SecureHandlerStateTemplate')
	E.ElvUF_Parent:SetFrameStrata('LOW')
	RegisterStateDriver(E.ElvUF_Parent, 'visibility', '[petbattle] hide;show')

	ElvUF:Factory(UF.Setup)

	UF:UpdateColors()
	UF:RegisterEvent('PLAYER_ENTERING_WORLD')
	UF:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'SetMaxAllowedGroups')
	UF:RegisterEvent('PLAYER_TARGET_CHANGED')
	UF:RegisterEvent('PLAYER_FOCUS_CHANGED')

	if E.private.unitframe.disabledBlizzardFrames.party and E.private.unitframe.disabledBlizzardFrames.raid then
		UF:DisableBlizzard()
	end

	if (not E.private.unitframe.disabledBlizzardFrames.party) and (not E.private.unitframe.disabledBlizzardFrames.raid) then
		E.RaidUtility.Initialize = E.noop
	end

	if _G.Clique and _G.Clique.BLACKLIST_CHANGED then
		hooksecurefunc(_G.Clique, 'BLACKLIST_CHANGED', UF.UpdateRegisteredClicks)
	end

	if E.private.unitframe.disabledBlizzardFrames.arena then
		if E.Retail then UF:SecureHook('UnitFrameThreatIndicator_Initialize') end

		Arena_LoadUI = E.noop
		-- Blizzard_ArenaUI should not be loaded, called on PLAYER_ENTERING_WORLD if in pvp or arena
		-- this noop happens normally in oUF.DisableBlizzard but we have our own ElvUF.DisableBlizzard

		if IsAddOnLoaded('Blizzard_ArenaUI') then
			ElvUF:DisableBlizzard('arena')
		else
			UF:RegisterEvent('ADDON_LOADED')
		end
	end

	local ORD = E.oUF_RaidDebuffs or _G.oUF_RaidDebuffs
	if not ORD then return end
	ORD.ShowDispellableDebuff = true
	ORD.FilterDispellableDebuff = true
	ORD.MatchBySpellName = false
end

E:RegisterInitialModule(UF:GetName())
