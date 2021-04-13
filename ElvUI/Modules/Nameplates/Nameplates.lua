local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local ElvUF = E.oUF
assert(ElvUF, 'ElvUI was unable to locate oUF.')

local _G = _G
local pairs, ipairs, wipe, tinsert = pairs, ipairs, wipe, tinsert
local format, select, strsplit, tostring = format, select, strsplit, tostring

local CreateFrame = CreateFrame
local GetCVar = GetCVar
local GetCVarDefault = GetCVarDefault
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local InCombatLockdown = InCombatLockdown
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local SetCVar = SetCVar
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitGUID = UnitGUID
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVPSanctuary = UnitIsPVPSanctuary
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitReaction = UnitReaction
local UnitWidgetSet = UnitWidgetSet
local UnitSelectionType = UnitSelectionType
local UnitThreatSituation = UnitThreatSituation
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local ShowBossFrameWhenUninteractable = ShowBossFrameWhenUninteractable
local C_NamePlate_SetNamePlateEnemyClickThrough = C_NamePlate.SetNamePlateEnemyClickThrough
local C_NamePlate_SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlyClickThrough = C_NamePlate.SetNamePlateFriendlyClickThrough
local C_NamePlate_SetNamePlateFriendlySize = C_NamePlate.SetNamePlateFriendlySize
local C_NamePlate_SetNamePlateSelfClickThrough = C_NamePlate.SetNamePlateSelfClickThrough
local C_NamePlate_SetNamePlateSelfSize = C_NamePlate.SetNamePlateSelfSize
local hooksecurefunc = hooksecurefunc

do	-- credit: oUF/private.lua
	local selectionTypes = {[0]=0,[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[13]=13}
	-- 10 and 11 are unavailable to players, 12 is inconsistent due to bugs and its reliance on cvars

	function NP:UnitExists(unit)
		return unit and UnitExists(unit) or ShowBossFrameWhenUninteractable(unit)
	end

	function NP:UnitSelectionType(unit, considerHostile)
		if considerHostile and UnitThreatSituation('player', unit) then
			return 0
		else
			return selectionTypes[UnitSelectionType(unit, true)]
		end
	end
end

local Blacklist = {
	PLAYER = {
		enable = true,
		health = {
			enable = true,
		},
	},
	ENEMY_PLAYER = {},
	FRIENDLY_PLAYER = {},
	ENEMY_NPC = {},
	FRIENDLY_NPC = {},
}

function NP:ResetSettings(unit)
	E:CopyTable(NP.db.units[unit], P.nameplates.units[unit])
end

function NP:CopySettings(from, to)
	if from == to then
		E:Print(L["You cannot copy settings from the same unit."])
		return
	end

	E:CopyTable(NP.db.units[to], E:FilterTableFromBlacklist(NP.db.units[from], Blacklist[to]))
end

do
	local empty = {}
	function NP:PlateDB(nameplate)
		return (nameplate and NP.db.units[nameplate.frameType]) or empty
	end
end

function NP:SetCVar(cvar, value)
	if GetCVar(cvar) ~= tostring(value) then
		SetCVar(cvar, value)
	end
end

function NP:CVarReset()
	NP:SetCVar('nameplateMinAlpha', 1)
	NP:SetCVar('nameplateMaxAlpha', 1)
	NP:SetCVar('nameplateClassResourceTopInset', GetCVarDefault('nameplateClassResourceTopInset'))
	NP:SetCVar('nameplateGlobalScale', 1)
	NP:SetCVar('NamePlateHorizontalScale', 1)
	NP:SetCVar('nameplateLargeBottomInset', GetCVarDefault('nameplateLargeBottomInset'))
	NP:SetCVar('nameplateLargerScale', 1)
	NP:SetCVar('nameplateLargeTopInset', GetCVarDefault('nameplateLargeTopInset'))
	NP:SetCVar('nameplateMaxAlphaDistance', GetCVarDefault('nameplateMaxAlphaDistance'))
	NP:SetCVar('nameplateMaxScale', 1)
	NP:SetCVar('nameplateMaxScaleDistance', 40)
	NP:SetCVar('nameplateMinAlphaDistance', GetCVarDefault('nameplateMinAlphaDistance'))
	NP:SetCVar('nameplateMinScale', 1)
	NP:SetCVar('nameplateMinScaleDistance', 0)
	NP:SetCVar('nameplateMotionSpeed', GetCVarDefault('nameplateMotionSpeed'))
	NP:SetCVar('nameplateOccludedAlphaMult', GetCVarDefault('nameplateOccludedAlphaMult'))
	NP:SetCVar('nameplateOtherAtBase', GetCVarDefault('nameplateOtherAtBase'))
	NP:SetCVar('nameplateOverlapH', GetCVarDefault('nameplateOverlapH'))
	NP:SetCVar('nameplateOverlapV', GetCVarDefault('nameplateOverlapV'))
	NP:SetCVar('nameplateResourceOnTarget', GetCVarDefault('nameplateResourceOnTarget'))
	NP:SetCVar('nameplateSelectedAlpha', 1)
	NP:SetCVar('nameplateSelectedScale', 1)
	NP:SetCVar('nameplateSelfAlpha', 1)
	NP:SetCVar('nameplateSelfBottomInset', GetCVarDefault('nameplateSelfBottomInset'))
	NP:SetCVar('nameplateSelfScale', 1)
	NP:SetCVar('nameplateSelfTopInset', GetCVarDefault('nameplateSelfTopInset'))
	NP:SetCVar('nameplateTargetBehindMaxDistance', 40)
end

function NP:SetCVars()
	if NP.db.units.ENEMY_NPC.questIcon.enable or NP.db.units.FRIENDLY_NPC.questIcon.enable then
		NP:SetCVar('showQuestTrackingTooltips', 1)
	end

	if NP.db.clampToScreen then
		NP:SetCVar('nameplateOtherTopInset', 0.08)
		NP:SetCVar('nameplateOtherBottomInset', 0.1)
	elseif GetCVar('nameplateOtherTopInset') == '0.08' and GetCVar('nameplateOtherBottomInset') == '0.1' then
		NP:SetCVar('nameplateOtherTopInset', -1)
		NP:SetCVar('nameplateOtherBottomInset', -1)
	end

	NP:SetCVar('nameplateMotion', NP.db.motionType == 'STACKED' and 1 or 0)

	NP:SetCVar('NameplatePersonalShowAlways', NP.db.units.PLAYER.visibility.showAlways and 1 or 0)
	NP:SetCVar('NameplatePersonalShowInCombat', NP.db.units.PLAYER.visibility.showInCombat and 1 or 0)
	NP:SetCVar('NameplatePersonalShowWithTarget', NP.db.units.PLAYER.visibility.showWithTarget and 1 or 0)
	NP:SetCVar('NameplatePersonalHideDelayAlpha', NP.db.units.PLAYER.visibility.alphaDelay)
	NP:SetCVar('NameplatePersonalHideDelaySeconds', NP.db.units.PLAYER.visibility.hideDelay)

	-- the order of these is important !!
	NP:SetCVar('nameplateShowAll', NP.db.visibility.showAll and 1 or 0)
	NP:SetCVar('nameplateShowSelf', (NP.db.units.PLAYER.useStaticPosition or not NP.db.units.PLAYER.enable) and 0 or 1)
	NP:SetCVar('nameplateShowEnemyMinions', NP.db.visibility.enemy.minions and 1 or 0)
	NP:SetCVar('nameplateShowEnemyGuardians', NP.db.visibility.enemy.guardians and 1 or 0)
	NP:SetCVar('nameplateShowEnemyMinus', NP.db.visibility.enemy.minus and 1 or 0)
	NP:SetCVar('nameplateShowEnemyPets', NP.db.visibility.enemy.pets and 1 or 0)
	NP:SetCVar('nameplateShowEnemyTotems', NP.db.visibility.enemy.totems and 1 or 0)
	NP:SetCVar('nameplateShowFriendlyMinions', NP.db.visibility.friendly.minions and 1 or 0)
	NP:SetCVar('nameplateShowFriendlyGuardians', NP.db.visibility.friendly.guardians and 1 or 0)
	NP:SetCVar('nameplateShowFriendlyNPCs', NP.db.visibility.friendly.npcs and 1 or 0)
	NP:SetCVar('nameplateShowFriendlyPets', NP.db.visibility.friendly.pets and 1 or 0)
	NP:SetCVar('nameplateShowFriendlyTotems', NP.db.visibility.friendly.totems and 1 or 0)
end

function NP:PLAYER_REGEN_DISABLED()
	if NP.db.showFriendlyCombat == 'TOGGLE_ON' then
		NP:SetCVar('nameplateShowFriends', 1)
	elseif NP.db.showFriendlyCombat == 'TOGGLE_OFF' then
		NP:SetCVar('nameplateShowFriends', 0)
	end

	if NP.db.showEnemyCombat == 'TOGGLE_ON' then
		NP:SetCVar('nameplateShowEnemies', 1)
	elseif NP.db.showEnemyCombat == 'TOGGLE_OFF' then
		NP:SetCVar('nameplateShowEnemies', 0)
	end
end

function NP:PLAYER_REGEN_ENABLED()
	if NP.db.showFriendlyCombat == 'TOGGLE_ON' then
		NP:SetCVar('nameplateShowFriends', 0)
	elseif NP.db.showFriendlyCombat == 'TOGGLE_OFF' then
		NP:SetCVar('nameplateShowFriends', 1)
	end

	if NP.db.showEnemyCombat == 'TOGGLE_ON' then
		NP:SetCVar('nameplateShowEnemies', 0)
	elseif NP.db.showEnemyCombat == 'TOGGLE_OFF' then
		NP:SetCVar('nameplateShowEnemies', 1)
	end
end

function NP:Style(frame, unit)
	frame.isNamePlate = true

	if frame:GetName() == 'ElvNP_TargetClassPower' then
		NP:StyleTargetPlate(frame, unit)
	else
		NP:StylePlate(frame, unit)
	end

	return frame
end

function NP:Construct_RaisedELement(nameplate)
	local RaisedElement = CreateFrame('Frame', nameplate:GetName() .. 'RaisedElement', nameplate)
	RaisedElement:SetFrameStrata(nameplate:GetFrameStrata())
	RaisedElement:SetFrameLevel(10)
	RaisedElement:SetAllPoints()
	RaisedElement:EnableMouse(false)

	return RaisedElement
end

function NP:StyleTargetPlate(nameplate)
	nameplate:ClearAllPoints()
	nameplate:Point('CENTER')
	nameplate:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	nameplate:SetScale(E.global.general.UIScale)

	nameplate.RaisedElement = NP:Construct_RaisedELement(nameplate)
	nameplate.ClassPower = NP:Construct_ClassPower(nameplate)

	if E.myclass == 'DEATHKNIGHT' then
		nameplate.Runes = NP:Construct_Runes(nameplate)
	elseif E.myclass == 'MONK' then
		nameplate.Stagger = NP:Construct_Stagger(nameplate)
	end
end

function NP:UpdateTargetPlate(nameplate)
	NP:Update_ClassPower(nameplate)

	if E.myclass == 'DEATHKNIGHT' then
		NP:Update_Runes(nameplate)
	elseif E.myclass == 'MONK' then
		NP:Update_Stagger(nameplate)
	end

	nameplate:UpdateAllElements('OnShow')
end

function NP:ScalePlate(nameplate, scale, targetPlate)
	local mult = (nameplate == _G.ElvNP_Player or nameplate == _G.ElvNP_Test) and 1 or E.global.general.UIScale
	if targetPlate and NP.targetPlate then
		NP.targetPlate:SetScale(mult)
		NP.targetPlate = nil
	end

	if not nameplate then
		return
	end

	local targetScale = format('%.2f', mult * scale)
	nameplate:SetScale(targetScale)

	if targetPlate then
		NP.targetPlate = nameplate
	end
end

function NP:PostUpdateAllElements(event)
	if self == _G.ElvNP_Test or self.widgetsOnly then return end -- skip test and widget plates

	if event and (event == 'ForceUpdate' or not NP.StyleFilterEventFunctions[event]) then
		NP:StyleFilterUpdate(self, event)
		self.StyleFilterBaseAlreadyUpdated = nil -- keep after StyleFilterUpdate
	end

	if event == 'NAME_PLATE_UNIT_ADDED' and self.isTarget then
		NP:SetupTarget(self)
	end
end

function NP:StylePlate(nameplate)
	nameplate:ClearAllPoints()
	nameplate:Point('CENTER')
	nameplate:SetScale(E.global.general.UIScale)

	nameplate.RaisedElement = NP:Construct_RaisedELement(nameplate)
	nameplate.Health = NP:Construct_Health(nameplate)
	nameplate.Health.Text = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.Health.Text.frequentUpdates = .1
	nameplate.HealthPrediction = NP:Construct_HealthPrediction(nameplate)
	nameplate.Power = NP:Construct_Power(nameplate)
	nameplate.Power.Text = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.Name = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.Level = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.Title = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.ClassificationIndicator = NP:Construct_ClassificationIndicator(nameplate.RaisedElement)
	nameplate.Castbar = NP:Construct_Castbar(nameplate)
	nameplate.Portrait = NP:Construct_Portrait(nameplate.RaisedElement)
	nameplate.QuestIcons = NP:Construct_QuestIcons(nameplate.RaisedElement)
	nameplate.RaidTargetIndicator = NP:Construct_RaidTargetIndicator(nameplate.RaisedElement)
	nameplate.TargetIndicator = NP:Construct_TargetIndicator(nameplate)
	nameplate.ThreatIndicator = NP:Construct_ThreatIndicator(nameplate.RaisedElement)
	nameplate.Highlight = NP:Construct_Highlight(nameplate)
	nameplate.ClassPower = NP:Construct_ClassPower(nameplate)
	nameplate.PvPIndicator = NP:Construct_PvPIndicator(nameplate.RaisedElement) -- Horde / Alliance / HonorInfo
	nameplate.PvPClassificationIndicator = NP:Construct_PvPClassificationIndicator(nameplate.RaisedElement) -- Cart / Flag / Orb / Assassin Bounty
	nameplate.PVPRole = NP:Construct_PVPRole(nameplate.RaisedElement)
	nameplate.Cutaway = NP:Construct_Cutaway(nameplate)

	NP:Construct_Auras(nameplate)
	NP:StyleFilterEvents(nameplate) -- prepare the watcher

	if E.myclass == 'DEATHKNIGHT' then
		nameplate.Runes = NP:Construct_Runes(nameplate)
	elseif E.myclass == 'MONK' then
		nameplate.Stagger = NP:Construct_Stagger(nameplate)
	end

	NP.Plates[nameplate] = nameplate:GetName()

	hooksecurefunc(nameplate, 'UpdateAllElements', NP.PostUpdateAllElements)
end

function NP:UpdatePlate(nameplate, updateBase)
	NP:Update_RaidTargetIndicator(nameplate)
	NP:Update_PVPRole(nameplate)
	NP:Update_Portrait(nameplate)
	NP:Update_QuestIcons(nameplate)

	local db = NP:PlateDB(nameplate)
	if db.nameOnly or not db.enable then
		NP:DisablePlate(nameplate, db.enable and db.nameOnly)

		if not db.enable and nameplate.RaisedElement:IsShown() then
			nameplate.RaisedElement:Hide()
		end

		if nameplate == _G.ElvNP_Test then
			nameplate.Castbar:SetAlpha(0)
			nameplate.ClassPower:SetAlpha(0)
		end
	elseif updateBase then
		NP:Update_Tags(nameplate)
		NP:Update_Health(nameplate)
		NP:Update_HealthPrediction(nameplate)
		NP:Update_Highlight(nameplate)
		NP:Update_Power(nameplate)
		NP:Update_Castbar(nameplate)
		NP:Update_ClassPower(nameplate)
		NP:Update_Auras(nameplate)
		NP:Update_ClassificationIndicator(nameplate)
		NP:Update_PvPIndicator(nameplate) -- Horde / Alliance / HonorInfo
		NP:Update_PvPClassificationIndicator(nameplate) -- Cart / Flag / Orb / Assassin Bounty
		NP:Update_TargetIndicator(nameplate)
		NP:Update_ThreatIndicator(nameplate)
		NP:Update_Cutaway(nameplate)

		if E.myclass == 'DEATHKNIGHT' then
			NP:Update_Runes(nameplate)
		elseif E.myclass == 'MONK' then
			NP:Update_Stagger(nameplate)
		end

		if nameplate == _G.ElvNP_Player then
			NP:Update_Fader(nameplate)
		end
	else
		NP:Update_Health(nameplate, true) -- this will only reset the ouf vars so it won't hold stale threat ones
	end
end

NP.DisableInNotNameOnly = {
	'QuestIcons',
	'Highlight',
	'Portrait',
	'PVPRole'
}

NP.DisableElements = {
	'Health',
	'HealthPrediction',
	'Power',
	'ClassificationIndicator',
	'Castbar',
	'ThreatIndicator',
	'TargetIndicator',
	'ClassPower',
	'PvPIndicator',
	'PvPClassificationIndicator',
	'Auras'
}

if E.myclass == 'DEATHKNIGHT' then
	tinsert(NP.DisableElements, 'Runes')
elseif E.myclass == 'MONK' then
	tinsert(NP.DisableElements, 'Stagger')
end

function NP:DisablePlate(nameplate, nameOnly, nameOnlySF)
	for _, element in ipairs(NP.DisableElements) do
		if nameplate:IsElementEnabled(element) then
			nameplate:DisableElement(element)
		end
	end

	if nameOnly then
		NP:Update_Tags(nameplate, nameOnlySF)
		NP:Update_Highlight(nameplate, nameOnlySF)

		-- The position values here are forced on purpose.
		nameplate.Name:ClearAllPoints()
		nameplate.Name:Point('CENTER', nameplate, 'CENTER', 0, 0)

		nameplate.RaidTargetIndicator:ClearAllPoints()
		nameplate.RaidTargetIndicator:Point('BOTTOM', nameplate, 'TOP', 0, 0)

		nameplate.Portrait:ClearAllPoints()
		nameplate.Portrait:Point('RIGHT', nameplate.Name, 'LEFT', -6, 0)

		nameplate.PVPRole:ClearAllPoints()
		nameplate.PVPRole:Point('RIGHT', (nameplate.Portrait:IsShown() and nameplate.Portrait) or nameplate.Name, 'LEFT', -6, 0)

		nameplate.QuestIcons:ClearAllPoints()
		nameplate.QuestIcons:Point('LEFT', nameplate.Name, 'RIGHT', 6, 0)

		nameplate.Title:ClearAllPoints()
		nameplate.Title:Point('TOP', nameplate.Name, 'BOTTOM', 0, -2)

		if nameplate.isTarget then
			NP:SetupTarget(nameplate, true)
		end
	else
		for _, element in ipairs(NP.DisableInNotNameOnly) do
			if nameplate:IsElementEnabled(element) then
				nameplate:DisableElement(element)
			end
		end
	end
end

function NP:GetClassAnchor()
	local TCP = _G.ElvNP_TargetClassPower
	return TCP.realPlate or TCP
end

function NP:SetupTarget(nameplate, removed)
	if not NP.db.units then return end

	local TCP = _G.ElvNP_TargetClassPower
	local cp = NP.db.units.TARGET.classpower

	if removed or not nameplate or not cp.enable then
		TCP.realPlate = nil
	else
		local db = NP:PlateDB(nameplate)
		TCP.realPlate = not db.nameOnly and nameplate or nil
	end

	local anchor = NP:GetClassAnchor()
	if TCP.ClassPower then
		TCP.ClassPower:SetParent(anchor)
		TCP.ClassPower:ClearAllPoints()
		TCP.ClassPower:Point('CENTER', anchor, 'CENTER', cp.xOffset, cp.yOffset)
	end

	if TCP.Runes then
		TCP.Runes:SetParent(anchor)
		TCP.Runes:ClearAllPoints()
		TCP.Runes:Point('CENTER', anchor, 'CENTER', cp.xOffset, cp.yOffset)
	elseif TCP.Stagger then
		TCP.Stagger:SetParent(anchor)
		TCP.Stagger:ClearAllPoints()
		TCP.Stagger:Point('CENTER', anchor, 'CENTER', cp.xOffset, cp.yOffset)
	end
end

function NP:SetNamePlateClickThrough()
	if InCombatLockdown() then return end

	self:SetNamePlateSelfClickThrough()
	self:SetNamePlateFriendlyClickThrough()
	self:SetNamePlateEnemyClickThrough()
end

function NP:SetNamePlateSelfClickThrough()
	C_NamePlate_SetNamePlateSelfClickThrough(NP.db.clickThrough.personal)
	_G.ElvNP_StaticSecure:EnableMouse(not NP.db.clickThrough.personal)
end

function NP:SetNamePlateFriendlyClickThrough()
	C_NamePlate_SetNamePlateFriendlyClickThrough(NP.db.clickThrough.friendly)
end

function NP:SetNamePlateEnemyClickThrough()
	C_NamePlate_SetNamePlateEnemyClickThrough(NP.db.clickThrough.enemy)
end

function NP:Update_StatusBars()
	for bar in pairs(NP.StatusBars) do
		local sf = NP:StyleFilterChanges(bar:GetParent())
		if not sf.HealthTexture then
			bar:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar) or E.media.normTex)
		end
	end
end

function NP:GROUP_ROSTER_UPDATE()
	local isInRaid = IsInRaid()
	NP.IsInGroup = isInRaid or IsInGroup()

	wipe(NP.GroupRoles)

	if NP.IsInGroup then
		local Unit = (isInRaid and 'raid') or 'party'
		for i = 1, ((isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()) do
			if UnitExists(Unit .. i) then
				NP.GroupRoles[UnitName(Unit .. i)] = UnitGroupRolesAssigned(Unit .. i)
			end
		end
	end
end

function NP:GROUP_LEFT()
	NP.IsInGroup = IsInRaid() or IsInGroup()
	wipe(NP.GroupRoles)
end

function NP:PLAYER_ENTERING_WORLD(_, initLogin, isReload)
	NP.InstanceType = select(2, GetInstanceInfo())

	if initLogin or isReload then
		NP:ConfigureAll(true)
	end
end

function NP:ToggleStaticPlate()
	local playerEnabled = NP.db.units.PLAYER.enable
	local isStatic = NP.db.units.PLAYER.useStaticPosition

	if playerEnabled and isStatic then
		E:EnableMover('ElvNP_PlayerMover')
		_G.ElvNP_Player:Enable()
		_G.ElvNP_StaticSecure:Show()
	else
		NP:DisablePlate(_G.ElvNP_Player)
		E:DisableMover('ElvNP_PlayerMover')
		_G.ElvNP_Player:Disable()
		_G.ElvNP_StaticSecure:Hide()
	end

	NP:SetCVar('nameplateShowSelf', (isStatic or not playerEnabled) and 0 or 1)
end

function NP:ConfigurePlates(init)
	NP.SkipFading = true

	if _G.ElvNP_Test:IsEnabled() then
		NP:NamePlateCallBack(_G.ElvNP_Test, 'NAME_PLATE_UNIT_ADDED')
	end

	local staticEvent = (NP.db.units.PLAYER.enable and NP.db.units.PLAYER.useStaticPosition) and 'NAME_PLATE_UNIT_ADDED' or 'NAME_PLATE_UNIT_REMOVED'
	if init then -- since this is a fake plate, we actually need to trigger this always
		NP:NamePlateCallBack(_G.ElvNP_Player, staticEvent, 'player')

		_G.ElvNP_Player.StyleFilterBaseAlreadyUpdated = nil
		_G.ElvNP_Player:UpdateAllElements('ForceUpdate')
	else -- however, these only need to happen when changing options
		for nameplate in pairs(NP.Plates) do
			if nameplate.frameType == 'PLAYER' then
				nameplate:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
			elseif nameplate.frameType == 'FRIENDLY_PLAYER' or nameplate.frameType == 'FRIENDLY_NPC' then
				nameplate:Size(NP.db.plateSize.friendlyWidth, NP.db.plateSize.friendlyHeight)
			else
				nameplate:Size(NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight)
			end

			if nameplate == _G.ElvNP_Player then
				NP:NamePlateCallBack(_G.ElvNP_Player, staticEvent, 'player')
			else
				nameplate.previousType = nil -- keep over the callback, we still need a full update
				NP:NamePlateCallBack(nameplate, 'NAME_PLATE_UNIT_ADDED')
			end

			nameplate.StyleFilterBaseAlreadyUpdated = nil
			nameplate:UpdateAllElements('ForceUpdate')
		end
	end

	NP.SkipFading = nil
end

function NP:ConfigureAll(init)
	if E.private.nameplates.enable ~= true then return end

	NP:StyleFilterConfigure() -- keep this at the top
	NP:SetNamePlateClickThrough()
	NP:SetNamePlateSizes()
	NP:PLAYER_REGEN_ENABLED()
	NP:UpdateTargetPlate(_G.ElvNP_TargetClassPower)
	NP:Update_StatusBars()

	NP:ConfigurePlates(init) -- keep before toggle static
	NP:ToggleStaticPlate()
end

function NP:PlateFade(nameplate, timeToFade, startAlpha, endAlpha)
	-- we need our own function because we want a smooth transition and dont want it to force update every pass.
	-- its controlled by fadeTimer which is reset when UIFrameFadeOut or UIFrameFadeIn code runs.

	if not nameplate.FadeObject then
		nameplate.FadeObject = {}
	end

	nameplate.FadeObject.timeToFade = (nameplate.isTarget and 0) or timeToFade
	nameplate.FadeObject.startAlpha = startAlpha
	nameplate.FadeObject.endAlpha = endAlpha
	nameplate.FadeObject.diffAlpha = endAlpha - startAlpha

	if nameplate.FadeObject.fadeTimer then
		nameplate.FadeObject.fadeTimer = 0
	else
		E:UIFrameFade(nameplate, nameplate.FadeObject)
	end
end

function NP:UpdatePlateGUID(nameplate, guid)
	NP.PlateGUID[nameplate.unitGUID] = (guid and nameplate) or nil
end

function NP:UpdatePlateType(nameplate)
	if nameplate == _G.ElvNP_Test then return end

	if nameplate.isMe then
		nameplate.frameType = 'PLAYER'

		if NP.db.units.PLAYER.enable then
			NP.PlayerNamePlateAnchor:ClearAllPoints()
			NP.PlayerNamePlateAnchor:SetParent(NP.db.units.PLAYER.useStaticPosition and _G.ElvNP_Player or nameplate)
			NP.PlayerNamePlateAnchor:SetAllPoints(NP.db.units.PLAYER.useStaticPosition and _G.ElvNP_Player or nameplate)
			NP.PlayerNamePlateAnchor:Show()
		end
	elseif nameplate.isPVPSanctuary then
		nameplate.frameType = 'FRIENDLY_PLAYER'
	elseif not nameplate.isEnemy and (not nameplate.reaction or nameplate.reaction > 4) then -- keep as: not isEnemy, dont switch to isFriend
		nameplate.frameType = (nameplate.isPlayer and 'FRIENDLY_PLAYER') or 'FRIENDLY_NPC'
	else
		nameplate.frameType = (nameplate.isPlayer and 'ENEMY_PLAYER') or 'ENEMY_NPC'
	end
end

function NP:UpdatePlateSize(nameplate)
	if nameplate.frameType == 'PLAYER' then
		nameplate.width, nameplate.height = NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight
	elseif nameplate.frameType == 'FRIENDLY_PLAYER' or nameplate.frameType == 'FRIENDLY_NPC' then
		nameplate.width, nameplate.height = NP.db.plateSize.friendlyWidth, NP.db.plateSize.friendlyHeight
	else
		nameplate.width, nameplate.height = NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight
	end

	nameplate:Size(nameplate.width, nameplate.height)
end

function NP:UpdatePlateBase(nameplate)
	if nameplate == _G.ElvNP_Test then
		NP:UpdatePlate(nameplate, true)
	elseif nameplate == _G.ElvNP_Player then
		NP:UpdatePlate(nameplate, true)

		nameplate.StyleFilterBaseAlreadyUpdated = true
	else
		local update = nameplate.frameType ~= nameplate.previousType
		NP:UpdatePlate(nameplate, update)

		nameplate.StyleFilterBaseAlreadyUpdated = update
		nameplate.previousType = nameplate.frameType
	end
end

function NP:NamePlateCallBack(nameplate, event, unit)
	if event == 'UNIT_FACTION' then
		if nameplate.widgetsOnly then return end

		nameplate.faction = UnitFactionGroup(unit)
		nameplate.reaction = UnitReaction('player', unit) -- Player Reaction
		nameplate.repReaction = UnitReaction(unit, 'player') -- Reaction to Player
		nameplate.isFriend = UnitIsFriend('player', unit)
		nameplate.isEnemy = UnitIsEnemy('player', unit)

		NP:UpdatePlateType(nameplate)
		NP:UpdatePlateSize(nameplate)
		NP:UpdatePlateBase(nameplate)

		NP:StyleFilterUpdate(nameplate, event) -- keep this after UpdatePlateBase
		nameplate.StyleFilterBaseAlreadyUpdated = nil -- keep after StyleFilterUpdate
	elseif event == 'PLAYER_TARGET_CHANGED' then -- we need to check if nameplate exists in here
		NP:SetupTarget(nameplate) -- pass it, even as nil here
	elseif event == 'NAME_PLATE_UNIT_ADDED' then
		if not unit then unit = nameplate.unit end

		nameplate.blizzPlate = nameplate:GetParent().UnitFrame
		nameplate.className, nameplate.classFile, nameplate.classID = UnitClass(unit)
		nameplate.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)
		nameplate.widgetSet = UnitWidgetSet(unit)
		nameplate.classification = UnitClassification(unit)
		nameplate.creatureType = UnitCreatureType(unit)
		nameplate.isMe = UnitIsUnit(unit, 'player')
		nameplate.isPet = UnitIsUnit(unit, 'pet')
		nameplate.isFriend = UnitIsFriend('player', unit)
		nameplate.isEnemy = UnitIsEnemy('player', unit)
		nameplate.isPlayer = UnitIsPlayer(unit)
		nameplate.isPVPSanctuary = UnitIsPVPSanctuary(unit)
		nameplate.faction = UnitFactionGroup(unit)
		nameplate.reaction = UnitReaction('player', unit) -- Player Reaction
		nameplate.repReaction = UnitReaction(unit, 'player') -- Reaction to Player
		nameplate.unitGUID = UnitGUID(unit)
		nameplate.unitName = UnitName(unit)
		nameplate.npcID = nameplate.unitGUID and select(6, strsplit('-', nameplate.unitGUID))

		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate, nameplate.unitGUID)
		end

		NP:UpdatePlateType(nameplate)
		NP:UpdatePlateSize(nameplate)

		if nameplate.widgetsOnly then
			NP:DisablePlate(nameplate)

			if nameplate.RaisedElement:IsShown() then
				nameplate.RaisedElement:Hide()
			end

			nameplate.widgetContainer = nameplate.blizzPlate.WidgetContainer
			if nameplate.widgetContainer then
				nameplate.widgetContainer:SetParent(nameplate)
				nameplate.widgetContainer:ClearAllPoints()
				nameplate.widgetContainer:SetPoint('BOTTOM', nameplate, 'TOP')
			end

			nameplate.previousType = nil -- dont get the plate stuck for next unit
		else
			if not nameplate.RaisedElement:IsShown() then
				nameplate.RaisedElement:Show()
			end

			NP:UpdatePlateBase(nameplate)

			NP:StyleFilterEventWatch(nameplate) -- fire up the watcher
			NP:StyleFilterSetVariables(nameplate) -- sets: isTarget, isTargetingMe, isFocused
		end

		if (NP.db.fadeIn and not NP.SkipFading) and nameplate.frameType ~= 'PLAYER' then
			NP:PlateFade(nameplate, 1, 0, 1)
		end
	elseif event == 'NAME_PLATE_UNIT_REMOVED' then
		if nameplate ~= _G.ElvNP_Test then
			if nameplate.frameType == 'PLAYER' then
				NP.PlayerNamePlateAnchor:Hide()
			end

			if nameplate.isTarget then
				NP:ScalePlate(nameplate, 1, true)
				NP:SetupTarget(nameplate, true)
			end
		end

		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate)
		end

		if not nameplate.widgetsOnly then
			NP:StyleFilterEventWatch(nameplate, true) -- shut down the watcher
			NP:StyleFilterClearVariables(nameplate)
		elseif nameplate.widgetContainer then -- Place Widget Back on Blizzard Plate
			nameplate.widgetContainer:SetParent(nameplate.blizzPlate)
			nameplate.widgetContainer:ClearAllPoints()
			nameplate.widgetContainer:SetPoint('TOP', nameplate.blizzPlate.castBar, 'BOTTOM')
		end

		-- vars that we need to keep in a nonstale state
		nameplate.Health.cur = nil -- cutaway
		nameplate.Power.cur = nil -- cutaway
		nameplate.npcID = nil -- just cause
	end
end

local optionsTable = {
	'EnemyMinus',
	'EnemyMinions',
	'FriendlyMinions',
	'PersonalResource',
	'PersonalResourceOnEnemy',
	'MotionDropDown',
	'ShowAll'
}

function NP:HideInterfaceOptions()
	for _, x in pairs(optionsTable) do
		local o = _G['InterfaceOptionsNamesPanelUnitNameplates' .. x]
		o:SetSize(0.0001, 0.0001)
		o:SetAlpha(0)
		o:Hide()
	end
end

function NP:SetNamePlateSizes()
	if InCombatLockdown() then return end

	local scale = E.global.general.UIScale
	C_NamePlate_SetNamePlateSelfSize(NP.db.plateSize.personalWidth * scale, NP.db.plateSize.personalHeight * scale)
	C_NamePlate_SetNamePlateEnemySize(NP.db.plateSize.enemyWidth * scale, NP.db.plateSize.enemyHeight * scale)
	C_NamePlate_SetNamePlateFriendlySize(NP.db.plateSize.friendlyWidth * scale, NP.db.plateSize.friendlyHeight * scale)
end

function NP:Initialize()
	NP.db = E.db.nameplates

	if E.private.nameplates.enable ~= true then return end
	NP.Initialized = true

	NP.thinBorders = NP.db.thinBorders
	NP.SPACING = (NP.thinBorders or E.twoPixelsPlease) and 0 or 1
	NP.BORDER = (NP.thinBorders and not E.twoPixelsPlease) and 1 or 2

	ElvUF:RegisterStyle('ElvNP', function(frame, unit) NP:Style(frame, unit) end)
	ElvUF:SetActiveStyle('ElvNP')

	NP.Plates = {}
	NP.PlateGUID = {}
	NP.StatusBars = {}
	NP.GroupRoles = {}
	NP.multiplier = 0.35

	local BlizzPlateManaBar = _G.NamePlateDriverFrame.classNamePlatePowerBar
	if BlizzPlateManaBar then
		BlizzPlateManaBar:Hide()
		BlizzPlateManaBar:UnregisterAllEvents()
	end

	hooksecurefunc(_G.NamePlateDriverFrame, 'UpdateNamePlateOptions', NP.SetNamePlateSizes)
	hooksecurefunc(_G.NamePlateDriverFrame, 'SetupClassNameplateBars', function(frame)
		if not frame or frame:IsForbidden() then
			return
		end
		if frame.classNamePlateMechanicFrame then
			frame.classNamePlateMechanicFrame:Hide()
		end
		if frame.classNamePlatePowerBar then
			frame.classNamePlatePowerBar:Hide()
			frame.classNamePlatePowerBar:UnregisterAllEvents()
		end
	end)

	ElvUF:Spawn('player', 'ElvNP_Player', '')

	_G.ElvNP_Player:ClearAllPoints()
	_G.ElvNP_Player:Point('TOP', _G.UIParent, 'CENTER', 0, -150)
	_G.ElvNP_Player:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	_G.ElvNP_Player:SetScale(1)
	_G.ElvNP_Player.frameType = 'PLAYER'

	E:CreateMover(_G.ElvNP_Player, 'ElvNP_PlayerMover', L["Player NamePlate"], nil, nil, nil, 'ALL,SOLO', nil, 'nameplate,playerGroup')

	local StaticSecure = CreateFrame('Button', 'ElvNP_StaticSecure', _G.UIParent, 'SecureUnitButtonTemplate')
	StaticSecure:SetAttribute('unit', 'player')
	StaticSecure:SetAttribute('*type1', 'target')
	StaticSecure:SetAttribute('*type2', 'togglemenu')
	StaticSecure:SetAttribute('toggleForVehicle', true)
	StaticSecure:RegisterForClicks('LeftButtonDown', 'RightButtonDown')
	StaticSecure:SetScript('OnEnter', _G.UnitFrame_OnEnter)
	StaticSecure:SetScript('OnLeave', _G.UnitFrame_OnLeave)
	StaticSecure:ClearAllPoints()
	StaticSecure:Point('BOTTOMRIGHT', _G.ElvNP_PlayerMover)
	StaticSecure:Point('TOPLEFT', _G.ElvNP_PlayerMover)
	StaticSecure:Hide()
	StaticSecure.unit = 'player' -- Needed for OnEnter, OnLeave

	ElvUF:Spawn('player', 'ElvNP_Test')

	_G.ElvNP_Test:ClearAllPoints()
	_G.ElvNP_Test:Point('BOTTOM', _G.UIParent, 'BOTTOM', 0, 250)
	_G.ElvNP_Test:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	_G.ElvNP_Test:SetScale(1)
	_G.ElvNP_Test:SetMovable(true)
	_G.ElvNP_Test:RegisterForDrag('LeftButton', 'RightButton')
	_G.ElvNP_Test:SetScript('OnDragStart', function() _G.ElvNP_Test:StartMoving() end)
	_G.ElvNP_Test:SetScript('OnDragStop', function() _G.ElvNP_Test:StopMovingOrSizing() end)
	_G.ElvNP_Test.frameType = 'PLAYER'
	_G.ElvNP_Test:Disable()
	NP:DisablePlate(_G.ElvNP_Test)

	ElvUF:Spawn('player', 'ElvNP_TargetClassPower')

	_G.ElvNP_TargetClassPower:SetScale(1)
	_G.ElvNP_TargetClassPower:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	_G.ElvNP_TargetClassPower.frameType = 'TARGET'
	_G.ElvNP_TargetClassPower:SetAttribute('toggleForVehicle', true)
	_G.ElvNP_TargetClassPower:ClearAllPoints()
	_G.ElvNP_TargetClassPower:Point('TOP', E.UIParent, 'BOTTOM', 0, -500)

	NP.PlayerNamePlateAnchor = CreateFrame('Frame', 'ElvUIPlayerNamePlateAnchor', E.UIParent)
	NP.PlayerNamePlateAnchor:EnableMouse(false)
	NP.PlayerNamePlateAnchor:Hide()

	ElvUF:SpawnNamePlates('ElvNP_', function(nameplate, event, unit)
		NP:NamePlateCallBack(nameplate, event, unit)
	end)

	NP:RegisterEvent('PLAYER_REGEN_ENABLED')
	NP:RegisterEvent('PLAYER_REGEN_DISABLED')
	NP:RegisterEvent('PLAYER_ENTERING_WORLD')
	NP:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	NP:RegisterEvent('GROUP_ROSTER_UPDATE')
	NP:RegisterEvent('GROUP_LEFT')
	NP:RegisterEvent('PLAYER_LOGOUT')

	NP:StyleFilterInitialize()
	NP:HideInterfaceOptions()
	NP:GROUP_ROSTER_UPDATE()
	NP:SetCVars()
end

E:RegisterModule(NP:GetName())
