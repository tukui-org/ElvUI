local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local oUF = E.oUF

local _G = _G
local pairs, ipairs, wipe, tinsert = pairs, ipairs, wipe, tinsert
local format, select, strsplit = format, select, strsplit

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
local UnitSelectionType = UnitSelectionType
local UnitThreatSituation = UnitThreatSituation
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

function NP:CVarReset()
	SetCVar('nameplateMinAlpha', 1)
	SetCVar('nameplateMaxAlpha', 1)
	SetCVar('nameplateClassResourceTopInset', GetCVarDefault('nameplateClassResourceTopInset'))
	SetCVar('nameplateGlobalScale', 1)
	SetCVar('NamePlateHorizontalScale', 1)
	SetCVar('nameplateLargeBottomInset', GetCVarDefault('nameplateLargeBottomInset'))
	SetCVar('nameplateLargerScale', 1)
	SetCVar('nameplateLargeTopInset', GetCVarDefault('nameplateLargeTopInset'))
	SetCVar('nameplateMaxAlphaDistance', GetCVarDefault('nameplateMaxAlphaDistance'))
	SetCVar('nameplateMaxScale', 1)
	SetCVar('nameplateMaxScaleDistance', 40)
	SetCVar('nameplateMinAlphaDistance', GetCVarDefault('nameplateMinAlphaDistance'))
	SetCVar('nameplateMinScale', 1)
	SetCVar('nameplateMinScaleDistance', 0)
	SetCVar('nameplateMotionSpeed', GetCVarDefault('nameplateMotionSpeed'))
	SetCVar('nameplateOccludedAlphaMult', GetCVarDefault('nameplateOccludedAlphaMult'))
	SetCVar('nameplateOtherAtBase', GetCVarDefault('nameplateOtherAtBase'))
	SetCVar('nameplateOverlapH', GetCVarDefault('nameplateOverlapH'))
	SetCVar('nameplateOverlapV', GetCVarDefault('nameplateOverlapV'))
	SetCVar('nameplateResourceOnTarget', GetCVarDefault('nameplateResourceOnTarget'))
	SetCVar('nameplateSelectedAlpha', 1)
	SetCVar('nameplateSelectedScale', 1)
	SetCVar('nameplateSelfAlpha', 1)
	SetCVar('nameplateSelfBottomInset', GetCVarDefault('nameplateSelfBottomInset'))
	SetCVar('nameplateSelfScale', 1)
	SetCVar('nameplateSelfTopInset', GetCVarDefault('nameplateSelfTopInset'))
	SetCVar('nameplateTargetBehindMaxDistance', 40)
end

function NP:SetCVars()
	if NP.db.units.ENEMY_NPC.questIcon.enable or NP.db.units.FRIENDLY_NPC.questIcon.enable then
		SetCVar('showQuestTrackingTooltips', 1)
	end

	if NP.db.clampToScreen then
		SetCVar('nameplateOtherTopInset', 0.08)
		SetCVar('nameplateOtherBottomInset', 0.1)
	elseif GetCVar('nameplateOtherTopInset') == '0.08' and GetCVar('nameplateOtherBottomInset') == '0.1' then
		SetCVar('nameplateOtherTopInset', -1)
		SetCVar('nameplateOtherBottomInset', -1)
	end

	SetCVar('nameplateMotion', NP.db.motionType == 'STACKED' and 1 or 0)

	SetCVar('NameplatePersonalShowAlways', NP.db.units.PLAYER.visibility.showAlways and 1 or 0)
	SetCVar('NameplatePersonalShowInCombat', NP.db.units.PLAYER.visibility.showInCombat and 1 or 0)
	SetCVar('NameplatePersonalShowWithTarget', NP.db.units.PLAYER.visibility.showWithTarget and 1 or 0)
	SetCVar('NameplatePersonalHideDelayAlpha', NP.db.units.PLAYER.visibility.alphaDelay)
	SetCVar('NameplatePersonalHideDelaySeconds', NP.db.units.PLAYER.visibility.hideDelay)

	-- the order of these is important !!
	SetCVar('nameplateShowAll', NP.db.visibility.showAll and 1 or 0)
	SetCVar('nameplateShowSelf', (NP.db.units.PLAYER.useStaticPosition or not NP.db.units.PLAYER.enable) and 0 or 1)
	SetCVar('nameplateShowEnemyMinions', NP.db.visibility.enemy.minions and 1 or 0)
	SetCVar('nameplateShowEnemyGuardians', NP.db.visibility.enemy.guardians and 1 or 0)
	SetCVar('nameplateShowEnemyMinus', NP.db.visibility.enemy.minus and 1 or 0)
	SetCVar('nameplateShowEnemyPets', NP.db.visibility.enemy.pets and 1 or 0)
	SetCVar('nameplateShowEnemyTotems', NP.db.visibility.enemy.totems and 1 or 0)
	SetCVar('nameplateShowFriendlyMinions', NP.db.visibility.friendly.minions and 1 or 0)
	SetCVar('nameplateShowFriendlyGuardians', NP.db.visibility.friendly.guardians and 1 or 0)
	SetCVar('nameplateShowFriendlyNPCs', NP.db.visibility.friendly.npcs and 1 or 0)
	SetCVar('nameplateShowFriendlyPets', NP.db.visibility.friendly.pets and 1 or 0)
	SetCVar('nameplateShowFriendlyTotems', NP.db.visibility.friendly.totems and 1 or 0)
end

function NP:PLAYER_REGEN_DISABLED()
	if NP.db.showFriendlyCombat == 'TOGGLE_ON' then
		SetCVar('nameplateShowFriends', 1)
	elseif NP.db.showFriendlyCombat == 'TOGGLE_OFF' then
		SetCVar('nameplateShowFriends', 0)
	end

	if NP.db.showEnemyCombat == 'TOGGLE_ON' then
		SetCVar('nameplateShowEnemies', 1)
	elseif NP.db.showEnemyCombat == 'TOGGLE_OFF' then
		SetCVar('nameplateShowEnemies', 0)
	end
end

function NP:PLAYER_REGEN_ENABLED()
	if NP.db.showFriendlyCombat == 'TOGGLE_ON' then
		SetCVar('nameplateShowFriends', 0)
	elseif NP.db.showFriendlyCombat == 'TOGGLE_OFF' then
		SetCVar('nameplateShowFriends', 1)
	end

	if NP.db.showEnemyCombat == 'TOGGLE_ON' then
		SetCVar('nameplateShowEnemies', 0)
	elseif NP.db.showEnemyCombat == 'TOGGLE_OFF' then
		SetCVar('nameplateShowEnemies', 1)
	end
end

function NP:Style(frame, unit)
	if not unit then return end

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
	nameplate:SetPoint('CENTER')
	nameplate:SetSize(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	nameplate:SetScale(E.global.general.UIScale)

	nameplate.RaisedElement = NP:Construct_RaisedELement(nameplate)

	--nameplate.Power = NP:Construct_Power(nameplate)

	--nameplate.Power.Text = NP:Construct_TagText(nameplate.RaisedElement)

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
	local mult = (nameplate == _G.ElvNP_Player and 1) or E.global.general.UIScale
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

function NP:StylePlate(nameplate)
	nameplate:ClearAllPoints()
	nameplate:SetPoint('CENTER')
	nameplate:SetScale(E.global.general.UIScale)

	nameplate.StyleFilterChanges = {}

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
	nameplate.WidgetXPBar = NP:Construct_WidgetXPBar(nameplate)

	NP:Construct_Auras(nameplate)

	if E.myclass == 'DEATHKNIGHT' then
		nameplate.Runes = NP:Construct_Runes(nameplate)
	elseif E.myclass == 'MONK' then
		nameplate.Stagger = NP:Construct_Stagger(nameplate)
	end

	NP.Plates[nameplate] = nameplate:GetName()
end

function NP:UpdatePlate(nameplate, updateBase)
	NP:Update_RaidTargetIndicator(nameplate)
	NP:Update_PVPRole(nameplate)
	NP:Update_Portrait(nameplate)
	NP:Update_QuestIcons(nameplate)
	NP:Update_WidgetXPBar(nameplate)

	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)
	if sf.Visibility or sf.NameOnly or db.nameOnly or not db.enable then
		NP:DisablePlate(nameplate, sf.NameOnly or (db.nameOnly and not sf.Visibility))
	elseif updateBase then
		NP:Update_Tags(nameplate)
		NP:Update_Health(nameplate)
		NP:Update_HealthPrediction(nameplate)
		NP:Update_Highlight(nameplate)
		NP:Update_Power(nameplate)
		NP:Update_Castbar(nameplate)
		NP:Update_ClassPower(nameplate)
		NP:Update_Auras(nameplate, true)
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

	if nameplate.isTarget then
		NP:SetupTarget(nameplate, nil, true)
	end

	NP:StyleFilterEvents(nameplate)
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

function NP:DisablePlate(nameplate, nameOnly)
	for _, element in ipairs(NP.DisableElements) do
		if nameplate:IsElementEnabled(element) then
			nameplate:DisableElement(element)
		end
	end

	if nameOnly then
		NP:Update_Tags(nameplate)
		NP:Update_Highlight(nameplate)

		-- The position values here are forced on purpose.
		nameplate.Name:ClearAllPoints()
		nameplate.Name:SetPoint('CENTER', nameplate, 'CENTER', 0, 0)

		nameplate.RaidTargetIndicator:ClearAllPoints()
		nameplate.RaidTargetIndicator:SetPoint('BOTTOM', nameplate, 'TOP', 0, 0)

		nameplate.Portrait:ClearAllPoints()
		nameplate.Portrait:SetPoint('RIGHT', nameplate.Name, 'LEFT', -6, 0)

		nameplate.PVPRole:ClearAllPoints()
		nameplate.PVPRole:SetPoint('RIGHT', (nameplate.Portrait:IsShown() and nameplate.Portrait) or nameplate.Name, 'LEFT', -6, 0)

		nameplate.QuestIcons:ClearAllPoints()
		nameplate.QuestIcons:SetPoint('LEFT', nameplate.Name, 'RIGHT', 6, 0)

		nameplate.Title:ClearAllPoints()
		nameplate.Title:SetPoint('TOP', nameplate.Name, 'BOTTOM', 0, -2)
	else
		for _, element in ipairs(NP.DisableInNotNameOnly) do
			if nameplate:IsElementEnabled(element) then
				nameplate:DisableElement(element)
			end
		end
	end
end

function NP:SetupTarget(nameplate, removed)
	if not NP.db.units then return end

	local TCP = _G.ElvNP_TargetClassPower
	local cp = NP.db.units.TARGET.classpower

	local db = NP:PlateDB(nameplate)
	local sf = NP:StyleFilterChanges(nameplate)

	TCP.realPlate = (cp.enable and not (removed or sf.NameOnly or db.nameOnly) and nameplate) or nil

	local moveToPlate = TCP.realPlate or TCP

	if TCP.ClassPower then
		TCP.ClassPower:SetParent(moveToPlate)
		TCP.ClassPower:ClearAllPoints()
		TCP.ClassPower:SetPoint('CENTER', moveToPlate, 'CENTER', cp.xOffset, cp.yOffset)
	end
	if TCP.Runes then
		TCP.Runes:SetParent(moveToPlate)
		TCP.Runes:ClearAllPoints()
		TCP.Runes:SetPoint('CENTER', moveToPlate, 'CENTER', cp.xOffset, cp.yOffset)
	end
	if TCP.Stagger then
		TCP.Stagger:SetParent(moveToPlate)
		TCP.Stagger:ClearAllPoints()
		TCP.Stagger:SetPoint('CENTER', moveToPlate, 'CENTER', cp.xOffset, cp.yOffset)
	end
end

function NP:SetNamePlateClickThrough()
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
			bar:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar) or E.media.normTex)
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

function NP:PLAYER_ENTERING_WORLD()
	NP.InstanceType = select(2, GetInstanceInfo())
end

function NP:ConfigureAll()
	if E.private.nameplates.enable ~= true then return end
	NP:StyleFilterConfigure() -- keep this at the top

	NP:SetNamePlateSizes()
	NP:PLAYER_REGEN_ENABLED()

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

	NP:UpdateTargetPlate(_G.ElvNP_TargetClassPower)

	for nameplate in pairs(NP.Plates) do
		NP:StyleFilterClear(nameplate) -- keep this at the top of the loop

		if nameplate.frameType == 'PLAYER' then
			nameplate:SetSize(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
			SetCVar('nameplateShowSelf', (isStatic or not playerEnabled) and 0 or 1)
		elseif nameplate.frameType == 'FRIENDLY_PLAYER' or nameplate.frameType == 'FRIENDLY_NPC' then
			nameplate:SetSize(NP.db.plateSize.friendlyWidth, NP.db.plateSize.friendlyHeight)
		else
			nameplate:SetSize(NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight)
		end

		if nameplate == _G.ElvNP_Player then
			NP:NamePlateCallBack(_G.ElvNP_Player, (isStatic and playerEnabled) and 'NAME_PLATE_UNIT_ADDED' or 'NAME_PLATE_UNIT_REMOVED', 'player')
		elseif nameplate.frameType ~= 'PLAYER' or playerEnabled then
			NP:UpdatePlate(nameplate, true)
			NP:StyleFilterUpdate(nameplate, 'NAME_PLATE_UNIT_ADDED') -- keep this after update plate
		end

		nameplate:UpdateAllElements('ForceUpdate')
	end

	NP:Update_StatusBars()
	NP:SetNamePlateClickThrough()
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

function NP:NamePlateCallBack(nameplate, event, unit)
	if event == 'NAME_PLATE_UNIT_ADDED' or (event == 'UNIT_FACTION' and nameplate) then
		local updateBase = NP:StyleFilterClear(nameplate) -- keep this at the top

		unit = unit or nameplate.unit

		local blizzPlate = nameplate:GetParent().UnitFrame
		if blizzPlate then
			nameplate.blizzPlate = blizzPlate
			nameplate.widget = blizzPlate.WidgetContainer
		end

		nameplate.className, nameplate.classFile, nameplate.classID = UnitClass(unit)
		nameplate.classification = UnitClassification(unit)
		nameplate.creatureType = UnitCreatureType(unit)
		nameplate.isMe = UnitIsUnit(unit, 'player')
		nameplate.isPet = UnitIsUnit(unit, 'pet')
		nameplate.isFriend = UnitIsFriend('player', unit)
		nameplate.isEnemy = UnitIsEnemy('player', unit)
		nameplate.isPlayer = UnitIsPlayer(unit)
		nameplate.isPVPSanctuary = UnitIsPVPSanctuary(unit)
		nameplate.faction = UnitFactionGroup(unit)
		nameplate.reaction = UnitReaction('player', unit)
		nameplate.repReaction = UnitReaction(unit, 'player')
		nameplate.unitGUID = UnitGUID(unit)
		nameplate.unitName = UnitName(unit)
		nameplate.npcID = nameplate.unitGUID and select(6, strsplit('-', nameplate.unitGUID))

		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate, nameplate.unitGUID)
		end

		NP:StyleFilterSetVariables(nameplate) -- sets: isTarget, isTargetingMe, isFocused

		if nameplate.isMe then
			nameplate.frameType = 'PLAYER'

			if NP.db.units.PLAYER.enable and (nameplate ~= _G.ElvNP_Test) then
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

		if nameplate.frameType == 'PLAYER' then
			nameplate.width, nameplate.height = NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight
		elseif nameplate.frameType == 'FRIENDLY_PLAYER' or nameplate.frameType == 'FRIENDLY_NPC' then
			nameplate.width, nameplate.height = NP.db.plateSize.friendlyWidth, NP.db.plateSize.friendlyHeight
		else
			nameplate.width, nameplate.height = NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight
		end

		nameplate:SetSize(nameplate.width, nameplate.height)

		if nameplate == _G.ElvNP_Player then
			NP:UpdatePlate(nameplate, true)
		else
			NP:UpdatePlate(nameplate, updateBase or (nameplate.frameType ~= nameplate.previousType))
			nameplate.previousType = nameplate.frameType
		end

		if NP.db.fadeIn and (event == 'NAME_PLATE_UNIT_ADDED' and nameplate.frameType ~= 'PLAYER') then
			NP:PlateFade(nameplate, 1, 0, 1)
		end

		NP:StyleFilterUpdate(nameplate, event) -- keep this at the end
	elseif event == 'NAME_PLATE_UNIT_REMOVED' then
		if nameplate.frameType == 'PLAYER' and (nameplate ~= _G.ElvNP_Test) then
			NP.PlayerNamePlateAnchor:Hide()
		end

		if nameplate.isTarget then
			NP:SetupTarget(nameplate, true)
			NP:ScalePlate(nameplate, 1, true)
		end

		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate)
		end

		-- Vars that we need to keep in a nonstale state
		--- Cutaway
		nameplate.Health.cur = nil
		nameplate.Power.cur = nil
		--- WidgetXPBar
		nameplate.npcID = nil

		NP:StyleFilterClearVariables(nameplate) -- keep this at the end
	elseif event == 'PLAYER_TARGET_CHANGED' then -- we need to check if nameplate exists in here
		NP:SetupTarget(nameplate) -- pass it, even as nil here
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

	oUF:RegisterStyle('ElvNP', function(frame, unit) NP:Style(frame, unit) end)
	oUF:SetActiveStyle('ElvNP')

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

	oUF:Spawn('player', 'ElvNP_Player', '')

	_G.ElvNP_Player:ClearAllPoints()
	_G.ElvNP_Player:SetPoint('TOP', _G.UIParent, 'CENTER', 0, -150)
	_G.ElvNP_Player:SetSize(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
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
	StaticSecure:SetPoint('BOTTOMRIGHT', _G.ElvNP_PlayerMover)
	StaticSecure:SetPoint('TOPLEFT', _G.ElvNP_PlayerMover)
	StaticSecure:Hide()
	StaticSecure.unit = 'player' -- Needed for OnEnter, OnLeave

	oUF:Spawn('player', 'ElvNP_Test')

	_G.ElvNP_Test:ClearAllPoints()
	_G.ElvNP_Test:SetPoint('BOTTOM', _G.UIParent, 'BOTTOM', 0, 250)
	_G.ElvNP_Test:SetSize(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	_G.ElvNP_Test:SetScale(1)
	_G.ElvNP_Test:SetMovable(true)
	_G.ElvNP_Test:RegisterForDrag('LeftButton', 'RightButton')
	_G.ElvNP_Test:SetScript('OnDragStart', function() _G.ElvNP_Test:StartMoving() end)
	_G.ElvNP_Test:SetScript('OnDragStop', function() _G.ElvNP_Test:StopMovingOrSizing() end)
	_G.ElvNP_Test.frameType = 'PLAYER'
	_G.ElvNP_Test:Disable()
	NP:DisablePlate(_G.ElvNP_Test)

	oUF:Spawn('player', 'ElvNP_TargetClassPower')

	_G.ElvNP_TargetClassPower:SetScale(1)
	_G.ElvNP_TargetClassPower:SetSize(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	_G.ElvNP_TargetClassPower.frameType = 'TARGET'
	_G.ElvNP_TargetClassPower:SetAttribute('toggleForVehicle', true)
	_G.ElvNP_TargetClassPower:ClearAllPoints()
	_G.ElvNP_TargetClassPower:SetPoint('TOP', E.UIParent, 'BOTTOM', 0, -500)

	NP.PlayerNamePlateAnchor = CreateFrame('Frame', 'ElvUIPlayerNamePlateAnchor', E.UIParent)
	NP.PlayerNamePlateAnchor:EnableMouse(false)
	NP.PlayerNamePlateAnchor:Hide()

	oUF:SpawnNamePlates('ElvNP_', function(nameplate, event, unit)
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
	NP:ConfigureAll()
end

E:RegisterModule(NP:GetName())
