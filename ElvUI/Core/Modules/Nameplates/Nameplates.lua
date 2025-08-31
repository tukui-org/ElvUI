local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM
local ElvUF = E.oUF

local _G = _G
local hooksecurefunc = hooksecurefunc
local select, strsplit, tonumber = select, strsplit, tonumber
local pairs, ipairs, wipe, tinsert = pairs, ipairs, wipe, tinsert

local CreateFrame = CreateFrame
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local GetPartyAssignment = GetPartyAssignment
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local IsResting = IsResting
local UIParent = UIParent
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitGUID = UnitGUID
local UnitIsBattlePet = UnitIsBattlePet
local UnitIsDead = UnitIsDead
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitIsGameObject = UnitIsGameObject
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVPSanctuary = UnitIsPVPSanctuary
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitReaction = UnitReaction
local UnitSelectionType = UnitSelectionType
local UnitThreatSituation = UnitThreatSituation
local UnitWidgetSet = UnitWidgetSet
local UnitIsVisible = UnitIsVisible

local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly

local C_NamePlate_SetNamePlateEnemyClickThrough = C_NamePlate.SetNamePlateEnemyClickThrough
local C_NamePlate_SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlyClickThrough = C_NamePlate.SetNamePlateFriendlyClickThrough
local C_NamePlate_SetNamePlateFriendlySize = C_NamePlate.SetNamePlateFriendlySize
local C_NamePlate_SetNamePlateSelfClickThrough = C_NamePlate.SetNamePlateSelfClickThrough
local C_NamePlate_SetNamePlateSelfSize = C_NamePlate.SetNamePlateSelfSize
local C_NamePlate_GetNamePlates = C_NamePlate.GetNamePlates

local GetCVarDefault = C_CVar.GetCVarDefault
local GetCVar = C_CVar.GetCVar

do	-- credit: oUF/private.lua
	local selectionTypes = {[0]=0,[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[13]=13}
	-- 10 and 11 are unavailable to players, 12 is inconsistent due to bugs and its reliance on cvars

	function NP:UnitExists(unit)
		return unit and (UnitExists(unit) or UnitIsVisible(unit))
	end

	function NP:UnitSelectionType(unit, considerHostile)
		if considerHostile and UnitThreatSituation('player', unit) then
			return 0
		elseif E.Retail then
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

function NP:ResetAuraPriority()
	for unitType, content in pairs(E.db.nameplates.units) do
		local default = P.nameplates.units[unitType]
		if default then
			if content.buffs and content.buffs.filters then
				content.buffs.filters.priority = default.buffs.filters.priority
			end
			if content.debuffs and content.debuffs.filters then
				content.debuffs.filters.priority = default.debuffs.filters.priority
			end
		end
	end
end

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
	E:SetCVar('nameplateMinAlpha', 1)
	E:SetCVar('nameplateMaxAlpha', 1)
	E:SetCVar('nameplateClassResourceTopInset', GetCVarDefault('nameplateClassResourceTopInset'))
	E:SetCVar('nameplateGlobalScale', 1)
	E:SetCVar('NamePlateHorizontalScale', 1)
	E:SetCVar('nameplateLargeBottomInset', GetCVarDefault('nameplateLargeBottomInset'))
	E:SetCVar('nameplateLargerScale', 1)
	E:SetCVar('nameplateLargeTopInset', GetCVarDefault('nameplateLargeTopInset'))
	E:SetCVar('nameplateMaxAlphaDistance', GetCVarDefault('nameplateMaxAlphaDistance'))
	E:SetCVar('nameplateMaxScale', 1)
	E:SetCVar('nameplateMaxScaleDistance', 40)
	E:SetCVar('nameplateMinAlphaDistance', GetCVarDefault('nameplateMinAlphaDistance'))
	E:SetCVar('nameplateMinScale', 1)
	E:SetCVar('nameplateMinScaleDistance', 0)
	E:SetCVar('nameplateMotionSpeed', GetCVarDefault('nameplateMotionSpeed'))
	E:SetCVar('nameplateOccludedAlphaMult', GetCVarDefault('nameplateOccludedAlphaMult'))
	E:SetCVar('nameplateOtherAtBase', GetCVarDefault('nameplateOtherAtBase'))
	E:SetCVar('nameplateResourceOnTarget', GetCVarDefault('nameplateResourceOnTarget'))
	E:SetCVar('nameplateSelectedAlpha', 1)
	E:SetCVar('nameplateSelectedScale', 1)
	E:SetCVar('nameplateSelfAlpha', 1)
	E:SetCVar('nameplateSelfBottomInset', GetCVarDefault('nameplateSelfBottomInset'))
	E:SetCVar('nameplateSelfScale', 1)
	E:SetCVar('nameplateSelfTopInset', GetCVarDefault('nameplateSelfTopInset'))
	E:SetCVar('nameplateTargetBehindMaxDistance', 40)

	if not E.Retail then
		E:SetCVar('nameplateNotSelectedAlpha', 1)
	end
end

function NP:ToggleCVar(cvar, enabled)
	E:SetCVar(cvar, enabled and 1 or 0)
end

function NP:CombatCVar(cvar, option, switch)
	if option == 'TOGGLE_ON' then
		E:SetCVar(cvar, switch and 1 or 0)
	elseif option == 'TOGGLE_OFF' then
		E:SetCVar(cvar, switch and 0 or 1)
	end
end

function NP:SetCVars()
	local db = NP.db

	if db.clampToScreen then
		E:SetCVar('nameplateOtherTopInset', 0.08)
		E:SetCVar('nameplateOtherBottomInset', 0.1)

		if not E.Retail then -- dont exist in retail
			E:SetCVar('clampTargetNameplateToScreen', 1)
		end
	elseif GetCVar('nameplateOtherTopInset') == '0.08' and GetCVar('nameplateOtherBottomInset') == '0.1' then
		E:SetCVar('nameplateOtherTopInset', -1)
		E:SetCVar('nameplateOtherBottomInset', -1)

		if not E.Retail then
			E:SetCVar('clampTargetNameplateToScreen', 0)
		end
	end

	if E.Mists then
		E:SetCVar('nameplateMaxDistance', db.loadDistance)
	end

	-- the order of these is important !!
	local visibility = db.visibility
	NP:ToggleCVar('nameplateShowAll', visibility.showAll)
	NP:ToggleCVar('nameplateShowOnlyNames', visibility.nameplateShowOnlyNames)

	local enemyVisibility = visibility.enemy
	NP:ToggleCVar('nameplateShowEnemyMinions', enemyVisibility.minions)
	NP:ToggleCVar('nameplateShowEnemyGuardians', enemyVisibility.guardians)
	NP:ToggleCVar('nameplateShowEnemyMinus', enemyVisibility.minus)
	NP:ToggleCVar('nameplateShowEnemyPets', enemyVisibility.pets)
	NP:ToggleCVar('nameplateShowEnemyTotems', enemyVisibility.totems)

	local friendlyVisibility = visibility.friendly
	NP:ToggleCVar('nameplateShowFriendlyMinions', friendlyVisibility.minions)
	NP:ToggleCVar('nameplateShowFriendlyGuardians', friendlyVisibility.guardians)
	NP:ToggleCVar('nameplateShowFriendlyNPCs', friendlyVisibility.npcs)
	NP:ToggleCVar('nameplateShowFriendlyPets', friendlyVisibility.pets)
	NP:ToggleCVar('nameplateShowFriendlyTotems', friendlyVisibility.totems)

	local playerDB = db.units.PLAYER
	local playerVisibility = playerDB.visibility
	E:SetCVar('NameplatePersonalHideDelayAlpha', playerVisibility.alphaDelay)
	E:SetCVar('NameplatePersonalHideDelaySeconds', playerVisibility.hideDelay)

	NP:ToggleCVar('NameplatePersonalShowAlways', playerVisibility.showAlways)
	NP:ToggleCVar('NameplatePersonalShowInCombat', playerVisibility.showInCombat)
	NP:ToggleCVar('NameplatePersonalShowWithTarget', playerVisibility.showWithTarget)

	NP:ToggleCVar('nameplateShowSelf', not (playerDB.useStaticPosition or not playerDB.enable))

	-- Blizzard bug resets them after reload
	E:SetCVar('nameplateOverlapH', db.overlapH)
	E:SetCVar('nameplateOverlapV', db.overlapV)

	-- 10.1 things
	E:SetCVar('nameplatePlayerMaxDistance', 60)
end

function NP:PLAYER_REGEN_DISABLED()
	NP:CombatCVar('nameplateShowFriends', NP.db.showFriendlyCombat, true)
	NP:CombatCVar('nameplateShowEnemies', NP.db.showEnemyCombat, true)
end

function NP:PLAYER_REGEN_ENABLED()
	NP:CombatCVar('nameplateShowFriends', NP.db.showFriendlyCombat)
	NP:CombatCVar('nameplateShowEnemies', NP.db.showEnemyCombat)
end

function NP:Style(unit)
	local frameName = self:GetName()
	self.frameName = frameName
	self.isNamePlate = true

	if frameName == 'ElvNP_Player' then
		NP.PlayerFrame = self
	elseif frameName == 'ElvNP_TestFrame' then
		NP.TestFrame = self
	end

	if frameName == 'ElvNP_TargetClassPower' then
		NP:StyleTargetPlate(self, unit)
	else
		NP:StylePlate(self, unit)
	end

	return self
end

function NP:Construct_FlashTexture(nameplate, element)
	local barTexture = element:GetStatusBarTexture()

	local flashTexture = element:CreateTexture(nil, 'OVERLAY')
	flashTexture:SetTexture(LSM:Fetch('background', 'ElvUI Blank'))
	flashTexture:Point('BOTTOMLEFT', barTexture, 'BOTTOMLEFT')
	flashTexture:Point('TOPRIGHT', barTexture, 'TOPRIGHT')
	flashTexture:Hide()

	element.barTexture = barTexture
	element.flashTexture = flashTexture
end

function NP:Construct_RaisedELement(nameplate)
	local RaisedElement = CreateFrame('Frame', '$parent_RaisedElement', nameplate)
	RaisedElement:SetFrameStrata(nameplate:GetFrameStrata())
	RaisedElement:SetFrameLevel(10)
	RaisedElement:SetAllPoints()
	RaisedElement:EnableMouse(false)

	RaisedElement.frameName = RaisedElement:GetName()

	return RaisedElement
end

function NP:Construct_ClassPowerTwo(nameplate)
	if nameplate ~= NP.TestFrame then
		if E.myclass == 'DEATHKNIGHT' then
			nameplate.Runes = NP:Construct_Runes(nameplate)
		elseif E.myclass == 'MONK' and E.Retail then
			nameplate.Stagger = NP:Construct_Stagger(nameplate)
		end
	end
end

function NP:Update_ClassPowerTwo(nameplate)
	if nameplate ~= NP.TestFrame then
		if E.myclass == 'DEATHKNIGHT' then
			NP:Update_Runes(nameplate)
		elseif E.myclass == 'MONK' and E.Retail then
			NP:Update_Stagger(nameplate)
		end
	end
end

function NP:StyleTargetPlate(nameplate)
	nameplate:SetScale(E.uiscale)
	nameplate:ClearAllPoints()
	nameplate:Point('CENTER')
	nameplate:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)

	nameplate.RaisedElement = NP:Construct_RaisedELement(nameplate)
	nameplate.ClassPower = NP:Construct_ClassPower(nameplate)

	NP:Construct_ClassPowerTwo(nameplate)
end

function NP:UpdateTargetPlate(nameplate)
	NP:Update_ClassPower(nameplate)
	NP:Update_ClassPowerTwo(nameplate)

	nameplate:UpdateAllElements('OnShow')
end

function NP:ScalePlate(nameplate, scale, targetPlate)
	local mult = (nameplate == NP.PlayerFrame or nameplate == NP.TestFrame) and 1 or E.uiscale
	if targetPlate and NP.targetPlate then
		NP.targetPlate:SetScale(mult)
		NP.targetPlate = nil
	end

	if not nameplate then return end
	nameplate:SetScale(scale * mult)

	if targetPlate then
		NP.targetPlate = nameplate
	end
end

function NP:PostUpdateAllElements(event)
	if self == NP.TestFrame or self.widgetsOnly then return end -- skip test and widget plates

	if event and (event == 'ForceUpdate' or not NP.StyleFilterEventFunctions[event]) then
		NP:StyleFilterUpdate(self, event)
		self.StyleFilterBaseAlreadyUpdated = nil -- keep after StyleFilterUpdate
	end

	if event == 'NAME_PLATE_UNIT_ADDED' and self.isTarget then
		NP:SetupTarget(self)
	end
end

function NP:StylePlate(nameplate)
	nameplate:SetScale(E.uiscale)
	nameplate:ClearAllPoints()
	nameplate:Point('CENTER')

	nameplate.RaisedElement = NP:Construct_RaisedELement(nameplate)
	nameplate.Health = NP:Construct_Health(nameplate)
	nameplate.Health.Text = NP:Construct_TagText(nameplate)
	nameplate.Health.Text.frequentUpdates = .1
	nameplate.HealthPrediction = NP:Construct_HealthPrediction(nameplate)
	nameplate.Power = NP:Construct_Power(nameplate)
	nameplate.Power.Text = NP:Construct_TagText(nameplate)
	nameplate.Name = NP:Construct_TagText(nameplate)
	nameplate.Level = NP:Construct_TagText(nameplate)
	nameplate.Title = NP:Construct_TagText(nameplate)
	nameplate.ClassificationIndicator = NP:Construct_ClassificationIndicator(nameplate)
	nameplate.Castbar = NP:Construct_Castbar(nameplate)
	nameplate.Portrait = NP:Construct_Portrait(nameplate)
	nameplate.QuestIcons = NP:Construct_QuestIcons(nameplate)
	nameplate.RaidTargetIndicator = NP:Construct_RaidTargetIndicator(nameplate)
	nameplate.TargetIndicator = NP:Construct_TargetIndicator(nameplate)
	nameplate.ThreatIndicator = NP:Construct_ThreatIndicator(nameplate)
	nameplate.Highlight = NP:Construct_Highlight(nameplate)
	nameplate.ClassPower = NP:Construct_ClassPower(nameplate)
	nameplate.PvPIndicator = NP:Construct_PvPIndicator(nameplate) -- Horde / Alliance / HonorInfo
	nameplate.PvPClassificationIndicator = NP:Construct_PvPClassificationIndicator(nameplate) -- Cart / Flag / Orb / Assassin Bounty
	nameplate.PVPRole = NP:Construct_PVPRole(nameplate)
	nameplate.Cutaway = NP:Construct_Cutaway(nameplate)
	nameplate.PrivateAuras = NP:Construct_PrivateAuras(nameplate)
	nameplate.BossMods = NP:Construct_BossMods(nameplate)

	NP:Construct_Auras(nameplate)
	NP:StyleFilterEvents(nameplate) -- prepare the watcher

	NP:Construct_ClassPowerTwo(nameplate)

	NP.Plates[nameplate] = nameplate.frameName

	hooksecurefunc(nameplate, 'UpdateAllElements', NP.PostUpdateAllElements)
end

function NP:UpdatePlate(nameplate, updateBase)
	NP:Update_RaidTargetIndicator(nameplate)
	NP:Update_PVPRole(nameplate)
	NP:Update_Portrait(nameplate)
	NP:Update_QuestIcons(nameplate)
	NP:Update_BossMods(nameplate)

	local db = NP:PlateDB(nameplate)
	if db.nameOnly or not db.enable then
		NP:DisablePlate(nameplate, db.enable and db.nameOnly, not db.enable)

		if nameplate == NP.TestFrame then
			nameplate.Castbar:SetAlpha(0)
			nameplate.ClassPower:SetAlpha(0)
		end
	elseif updateBase and db.enable then
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
		NP:Update_PrivateAuras(nameplate)

		NP:Update_ClassPowerTwo(nameplate)

		if nameplate == NP.PlayerFrame then
			NP:Update_Fader(nameplate)
		end
	elseif db.enable then
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

function NP:DisablePlate(nameplate, nameOnly, hideRaised)
	for _, element in ipairs(NP.DisableElements) do
		if nameplate:IsElementEnabled(element) then
			nameplate:DisableElement(element)
		end
	end

	if hideRaised and nameplate.RaisedElement:IsShown() then
		nameplate.RaisedElement:Hide()
	end

	NP:Update_PrivateAuras(nameplate, true)

	if nameOnly then
		local styleFilter = nameOnly == 1
		NP:Update_Tags(nameplate, styleFilter)
		NP:Update_Highlight(nameplate, styleFilter)

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
	local TCP = NP.TargetClassPower
	return TCP.realPlate or TCP
end

function NP:SetupTarget(nameplate, removed)
	if not (NP.db.units and NP.db.units.TARGET) then return end

	local TCP = NP.TargetClassPower
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
	NP.StaticSecure:EnableMouse(not NP.db.clickThrough.personal)
end

function NP:SetNamePlateFriendlyClickThrough()
	C_NamePlate_SetNamePlateFriendlyClickThrough(NP.db.clickThrough.friendly)
end

function NP:SetNamePlateEnemyClickThrough()
	C_NamePlate_SetNamePlateEnemyClickThrough(NP.db.clickThrough.enemy)
end

function NP:Update_StatusBars()
	for bar in pairs(NP.StatusBars) do
		local styleFilter = NP:StyleFilterChanges(bar:GetParent())

		if not (styleFilter.health and styleFilter.health.texture) then
			local texture = LSM:Fetch('statusbar', NP.db.statusbar) or E.media.normTex
			if bar.SetStatusBarTexture then
				bar:SetStatusBarTexture(texture)
			else
				bar:SetTexture(texture)
			end
		end
	end
end

function NP:GROUP_ROSTER_UPDATE()
	local isInRaid = IsInRaid()
	NP.IsInGroup = isInRaid or IsInGroup()

	wipe(NP.GroupRoles)

	if NP.IsInGroup then
		local group = isInRaid and 'raid' or 'party'
		for i = 1, (isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers() do
			local unit = group..i
			if UnitExists(unit) then
				NP.GroupRoles[UnitName(unit)] = not E.allowRoles and (GetPartyAssignment('MAINTANK', unit) and 'TANK' or 'NONE') or UnitGroupRolesAssigned(unit)
			end
		end
	end
end

function NP:GROUP_LEFT()
	NP.IsInGroup = IsInRaid() or IsInGroup()

	wipe(NP.GroupRoles)
end

function NP:EnviromentConditionals()
	local db = NP.db
	local env = db and db.enviromentConditions

	local inInstance, instanceType = IsInInstance()
	local value = (inInstance and instanceType) or (IsResting() and 'resting') or 'world'

	-- Handle friendly nameplates if friendly combat toggle is not set
	if env.friendlyEnabled and db.showFriendlyCombat == 'DISABLED' then
		NP:ToggleCVar('nameplateShowFriends', env.friendly[value])
	end

	-- Handle enemy nameplates if enemy combat toggle is not set
	if env.enemyEnabled and db.showEnemyCombat == 'DISABLED' then
		NP:ToggleCVar('nameplateShowEnemies', env.enemy[value])
	end

	-- Handle stacking nameplates
	if env.stackingEnabled then
		NP:ToggleCVar('nameplateMotion', env.stackingNameplates[value])
	else
		NP:ToggleCVar('nameplateMotion', db.motionType == 'STACKED')
	end
end

function NP:PLAYER_ENTERING_WORLD(event, initLogin, isReload)
	if initLogin or isReload then
		NP:ConfigureAll(true)
	end

	wipe(NP.SoundHandlers)

	NP:EnviromentConditionals(event)
end

function NP:ToggleStaticPlate()
	local playerEnabled = NP.db.units.PLAYER.enable
	local isStatic = NP.db.units.PLAYER.useStaticPosition

	if playerEnabled and isStatic then
		E:EnableMover(NP.PlayerFrame.mover.name)
		NP.PlayerFrame:Enable()
		NP.StaticSecure:Show()
	else
		NP:DisablePlate(NP.PlayerFrame)
		E:DisableMover(NP.PlayerFrame.mover.name)
		NP.PlayerFrame:Disable()
		NP.StaticSecure:Hide()
	end

	E:SetCVar('nameplateShowSelf', (isStatic or not playerEnabled) and 0 or 1)
end

function NP:ConfigurePlates(init)
	NP.SkipFading = true

	if NP.TestFrame:IsEnabled() then
		NP:NamePlateCallBack(NP.TestFrame, 'NAME_PLATE_UNIT_ADDED')
	end

	local staticEvent = (NP.db.units.PLAYER.enable and NP.db.units.PLAYER.useStaticPosition) and 'NAME_PLATE_UNIT_ADDED' or 'NAME_PLATE_UNIT_REMOVED'
	if init then -- since this is a fake plate, we actually need to trigger this always
		NP:NamePlateCallBack(NP.PlayerFrame, staticEvent, 'player')

		NP.PlayerFrame.StyleFilterBaseAlreadyUpdated = nil
		NP.PlayerFrame:UpdateAllElements('ForceUpdate')
	else -- however, these only need to happen when changing options
		for nameplate in pairs(NP.Plates) do
			if nameplate.frameType == 'PLAYER' then
				nameplate:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
			elseif nameplate.frameType == 'FRIENDLY_PLAYER' or nameplate.frameType == 'FRIENDLY_NPC' then
				nameplate:Size(NP.db.plateSize.friendlyWidth, NP.db.plateSize.friendlyHeight)
			else
				nameplate:Size(NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight)
			end

			if nameplate == NP.PlayerFrame then
				NP:NamePlateCallBack(NP.PlayerFrame, staticEvent, 'player')
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
	if not E.private.nameplates.enable then return end

	NP:StyleFilterConfigure() -- keep this at the top
	NP:SetNamePlateClickThrough()

	if E.Retail then
		NP:SetNamePlateSizes()
	end

	NP:PLAYER_REGEN_ENABLED()
	NP:UpdateTargetPlate(NP.TargetClassPower)
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

function NP:UnitNPCID(unit) -- also used by Bags.lua
	local guid = UnitGUID(unit)
	return tonumber(guid and select(6, strsplit('-', guid))), guid
end

function NP:UpdateNumPlates()
	-- wish there was another way to get just the amount
	NP.numPlates = #C_NamePlate_GetNamePlates()
end

function NP:UpdatePlateGUID(nameplate, guid)
	NP.PlateGUID[nameplate.unitGUID] = (guid and nameplate) or nil
end

function NP:UpdatePlateType(nameplate)
	if nameplate == NP.TestFrame then return end

	if nameplate.isMe then
		nameplate.frameType = 'PLAYER'

		if NP.db.units.PLAYER.enable then
			NP.PlayerNamePlateAnchor:ClearAllPoints()
			NP.PlayerNamePlateAnchor:SetParent(NP.db.units.PLAYER.useStaticPosition and NP.PlayerFrame or nameplate)
			NP.PlayerNamePlateAnchor:SetAllPoints(NP.db.units.PLAYER.useStaticPosition and NP.PlayerFrame or nameplate)
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
	if nameplate == NP.TestFrame then
		NP:UpdatePlate(nameplate, true)
	elseif nameplate == NP.PlayerFrame then
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
	if event == 'PLAYER_TARGET_CHANGED' then -- we need to check if nameplate exists in here
		if nameplate then
			nameplate.isDead = UnitIsDead(nameplate.unit)

			local styleFilter = NP:StyleFilterChanges(nameplate)
			NP:SetupTarget(nameplate, (styleFilter.general and styleFilter.general.nameOnly) or nameplate.isDead)
		else -- pass it, even as nil here
			NP:SetupTarget(nameplate)
		end

		return -- don't proceed
	elseif not nameplate or not nameplate.UpdateAllElements then
		return -- prevent error when loading in with our plates and Plater
	end

	if event == 'UNIT_HEALTH' or event == 'UNIT_MAXHEALTH' then
		if nameplate.widgetsOnly then return end

		nameplate.isDead = UnitIsDead(unit)

		if nameplate.isDead and not nameplate.isPlayer then
			NP:DisablePlate(nameplate, nil, true)

			nameplate.previousType = nil -- dont get the plate stuck for next unit
		end
	elseif event == 'UNIT_FACTION' then
		if nameplate.widgetsOnly then return end

		nameplate.reaction = UnitReaction('player', unit) -- Player Reaction
		nameplate.repReaction = UnitReaction(unit, 'player') -- Reaction to Player
		nameplate.isFriend = UnitIsFriend('player', unit)
		nameplate.isEnemy = UnitIsEnemy('player', unit)
		nameplate.faction = UnitFactionGroup(unit)
		nameplate.battleFaction = E:GetUnitBattlefieldFaction(unit)
		nameplate.classColor = (nameplate.isPlayer and E:ClassColor(nameplate.classFile)) or (nameplate.repReaction and NP.db.colors.reactions[nameplate.repReaction == 4 and 'neutral' or nameplate.repReaction <= 3 and 'bad' or 'good']) or nil

		NP:UpdatePlateType(nameplate)
		NP:UpdatePlateSize(nameplate)
		NP:UpdatePlateBase(nameplate)

		NP:StyleFilterUpdate(nameplate, event) -- keep this after UpdatePlateBase
		nameplate.StyleFilterBaseAlreadyUpdated = nil -- keep after StyleFilterUpdate
	elseif event == 'NAME_PLATE_UNIT_ADDED' then
		if not unit then unit = nameplate.unit end

		nameplate.blizzPlate = nameplate:GetParent().UnitFrame
		nameplate.widgetsOnly = E.Retail and nameplate.blizzPlate and UnitNameplateShowsWidgetsOnly(unit)
		nameplate.widgetSet = E.Retail and UnitWidgetSet(unit)
		nameplate.classification = UnitClassification(unit)
		nameplate.creatureType = UnitCreatureType(unit)
		nameplate.isMe = UnitIsUnit(unit, 'player')
		nameplate.isPet = UnitIsUnit(unit, 'pet')
		nameplate.isFriend = UnitIsFriend('player', unit)
		nameplate.isEnemy = UnitIsEnemy('player', unit)
		nameplate.isPlayer = UnitIsPlayer(unit)
		nameplate.isDead = UnitIsDead(unit)
		nameplate.isGameObject = UnitIsGameObject(unit)
		nameplate.isPVPSanctuary = UnitIsPVPSanctuary(unit)
		nameplate.isBattlePet = not E.Classic and UnitIsBattlePet(unit)
		nameplate.reaction = UnitReaction('player', unit) -- Player Reaction
		nameplate.repReaction = UnitReaction(unit, 'player') -- Reaction to Player
		nameplate.faction = UnitFactionGroup(unit)
		nameplate.battleFaction = E:GetUnitBattlefieldFaction(unit)
		nameplate.unitName, nameplate.unitRealm = UnitName(unit)
		nameplate.npcID, nameplate.unitGUID = NP:UnitNPCID(unit)
		nameplate.className, nameplate.classFile, nameplate.classID = UnitClass(unit)
		nameplate.classColor = (nameplate.isPlayer and E:ClassColor(nameplate.classFile)) or (nameplate.repReaction and NP.db.colors.reactions[nameplate.repReaction == 4 and 'neutral' or nameplate.repReaction <= 3 and 'bad' or 'good']) or nil

		local specID, specIcon
		local spec = E.Retail and E:GetUnitSpecInfo(unit)
		if spec then
			specID, specIcon = spec.id, spec.icon
		end

		nameplate.specID = specID
		nameplate.specIcon = specIcon

		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate, nameplate.unitGUID)
		end

		NP:UpdateNumPlates()
		NP:UpdatePlateType(nameplate)
		NP:UpdatePlateSize(nameplate)

		nameplate.softTargetFrame = nameplate.blizzPlate and nameplate.blizzPlate.SoftTargetFrame
		if nameplate.softTargetFrame then
			nameplate.softTargetFrame:SetParent(nameplate)
			nameplate.softTargetFrame:SetIgnoreParentAlpha(true)
		end

		nameplate.widgetContainer = nameplate.blizzPlate and nameplate.blizzPlate.WidgetContainer
		if nameplate.widgetContainer then
			nameplate.widgetContainer:SetParent(nameplate)
			nameplate.widgetContainer:SetIgnoreParentAlpha(true)
			nameplate.widgetContainer:ClearAllPoints()

			local db = NP.db.widgets
			local point = db.below and 'BOTTOM' or 'TOP'
			nameplate.widgetContainer:SetPoint(E.InversePoints[point], nameplate, point, db.xOffset, db.yOffset)
		end

		if nameplate.widgetsOnly or nameplate.isGameObject or (nameplate.isDead and not nameplate.isPlayer) then
			NP:DisablePlate(nameplate, nil, true)

			nameplate.previousType = nil -- dont get the plate stuck for next unit
		else
			if not nameplate.RaisedElement:IsShown() then
				nameplate.RaisedElement:Show()
			end

			NP:UpdatePlateBase(nameplate)
			NP:BossMods_UpdateIcon(nameplate)

			NP:StyleFilterEventWatch(nameplate) -- fire up the watcher
			NP:StyleFilterSetVariables(nameplate) -- sets: isTarget, isTargetingMe, isFocused
		end

		if (NP.db.fadeIn and not NP.SkipFading) and nameplate.frameType ~= 'PLAYER' then
			NP:PlateFade(nameplate, 1, 0, 1)
		end
	elseif event == 'NAME_PLATE_UNIT_REMOVED' then
		if nameplate ~= NP.TestFrame then
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

		NP:UpdateNumPlates()

		if not nameplate.widgetsOnly then
			NP:BossMods_UpdateIcon(nameplate, true)

			NP:StyleFilterEventWatch(nameplate, true) -- shut down the watcher
			NP:StyleFilterClearVariables(nameplate)
		end

		if nameplate.softTargetFrame then
			nameplate.softTargetFrame:SetParent(nameplate.blizzPlate)
			nameplate.softTargetFrame:SetIgnoreParentAlpha(false)
		end

		if nameplate.widgetContainer then -- Place Widget Back on Blizzard Plate
			nameplate.widgetContainer:SetParent(nameplate.blizzPlate)
			nameplate.widgetContainer:SetIgnoreParentAlpha(false)
			nameplate.widgetContainer:ClearAllPoints()
			nameplate.widgetContainer:SetPoint('TOP', nameplate.blizzPlate.castBar, 'BOTTOM')
		end

		-- these can appear on SoftTarget nameplates and they aren't
		-- from NAME_PLATE_UNIT_ADDED which means, they will still be shown
		-- in some cases when the plate previously had the element
		if nameplate.QuestIcons then
			nameplate.QuestIcons:Hide()
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

if E.Mists then
	tinsert(optionsTable, 'NameplateMaxDistanceSlider')
end

function NP:HideInterfaceOptions()
	for _, x in pairs(optionsTable) do
		local o = _G['InterfaceOptionsNamesPanelUnitNameplates'..x]
		if o then
			o:SetSize(0.00001, 0.00001)
			o:SetAlpha(0)
			o:Hide()
		end
	end
end

function NP:SetNamePlateSizes()
	if InCombatLockdown() then return end

	C_NamePlate_SetNamePlateSelfSize(NP.db.plateSize.personalWidth * E.uiscale, NP.db.plateSize.personalHeight * E.uiscale)
	C_NamePlate_SetNamePlateEnemySize(NP.db.plateSize.enemyWidth * E.uiscale, NP.db.plateSize.enemyHeight * E.uiscale)
	C_NamePlate_SetNamePlateFriendlySize(NP.db.plateSize.friendlyWidth * E.uiscale, NP.db.plateSize.friendlyHeight * E.uiscale)
end

function NP:HideClassNameplateBar(bar)
	if not bar then return end

	bar:Hide()
	bar:UnregisterAllEvents()
end

function NP:SetupClassNameplateBars()
	if not self or self:IsForbidden() then return end

	NP:HideClassNameplateBar(self.classNamePlatePowerBar)
	NP:HideClassNameplateBar(self.classNamePlateMechanicFrame)
	NP:HideClassNameplateBar(self.classNamePlateAlternatePowerBar) -- BrewmasterBar / EbonMightBar
end

function NP:Initialize()
	if not E.private.nameplates.enable then return end
	NP.Initialized = true

	NP.thinBorders = NP.db.thinBorders
	NP.SPACING = (NP.thinBorders or E.twoPixelsPlease) and 0 or 1
	NP.BORDER = (NP.thinBorders and not E.twoPixelsPlease) and 1 or 2

	ElvUF:RegisterStyle('ElvNP', NP.Style)
	ElvUF:SetActiveStyle('ElvNP')

	NP.Plates = {}
	NP.PlateGUID = {}
	NP.StatusBars = {}
	NP.GroupRoles = {}
	NP.SoundHandlers = {}
	NP.multiplier = 0.35
	NP.numPlates = 0

	if E.Retail then
		NP.SetupClassNameplateBars(_G.NamePlateDriverFrame)
		hooksecurefunc(_G.NamePlateDriverFrame, 'UpdateNamePlateOptions', NP.SetNamePlateSizes)
		hooksecurefunc(_G.NamePlateDriverFrame, 'SetupClassNameplateBars', NP.SetupClassNameplateBars)
	end

	local playerFrame = ElvUF:Spawn('player', 'ElvNP_Player', '')
	playerFrame:SetScale(1)
	playerFrame:ClearAllPoints()
	playerFrame:Point('TOP', UIParent, 'CENTER', 0, -150)
	playerFrame:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	playerFrame.frameType = 'PLAYER'

	local playerHolder = E:CreateMover(playerFrame, 'ElvNP_PlayerMover', L["Player NamePlate"], nil, nil, nil, 'ALL,SOLO', nil, 'nameplate,playerGroup')
	NP.PlayerMover = playerHolder.mover

	local staticSecure = CreateFrame('Button', 'ElvNP_StaticSecure', UIParent, 'SecureUnitButtonTemplate')
	staticSecure:SetAttribute('unit', 'player')
	staticSecure:SetAttribute('*type1', 'target')
	staticSecure:SetAttribute('*type2', 'togglemenu')
	staticSecure:SetAttribute('toggleForVehicle', true)
	staticSecure:RegisterForClicks('LeftButtonDown', 'RightButtonDown')
	staticSecure:SetScript('OnEnter', _G.UnitFrame_OnEnter)
	staticSecure:SetScript('OnLeave', _G.UnitFrame_OnLeave)
	staticSecure:ClearAllPoints()
	staticSecure:Point('TOPLEFT', NP.PlayerMover)
	staticSecure:Point('BOTTOMRIGHT', NP.PlayerMover)
	staticSecure:Hide()
	staticSecure.unit = 'player' -- Needed for OnEnter, OnLeave
	NP.StaticSecure = staticSecure

	local testFrame = ElvUF:Spawn('player', 'ElvNP_TestFrame')
	testFrame:SetScale(1)
	testFrame:ClearAllPoints()
	testFrame:Point('BOTTOM', UIParent, 'BOTTOM', 0, 250)
	testFrame:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	testFrame:SetMovable(true)
	testFrame:RegisterForDrag('LeftButton', 'RightButton')
	testFrame:SetScript('OnDragStart', function() NP.TestFrame:StartMoving() end)
	testFrame:SetScript('OnDragStop', function() NP.TestFrame:StopMovingOrSizing() end)
	testFrame.frameType = 'PLAYER'
	testFrame:Disable()

	NP:DisablePlate(testFrame)

	local targetClassPower = ElvUF:Spawn('player', 'ElvNP_TargetClassPower')
	targetClassPower:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	targetClassPower.frameType = 'TARGET'
	targetClassPower:SetAttribute('toggleForVehicle', true)
	targetClassPower:ClearAllPoints()
	targetClassPower:Point('TOP', E.UIParent, 'BOTTOM', 0, -500)
	NP.TargetClassPower = targetClassPower

	NP.PlayerNamePlateAnchor = CreateFrame('Frame', 'ElvUIPlayerNamePlateAnchor', E.UIParent)
	NP.PlayerNamePlateAnchor:EnableMouse(false)
	NP.PlayerNamePlateAnchor:Hide()

	ElvUF:SpawnNamePlates('ElvNP_', function(nameplate, event, unit)
		NP:NamePlateCallBack(nameplate, event, unit)
	end)

	NP:RegisterEvent('PLAYER_REGEN_ENABLED')
	NP:RegisterEvent('PLAYER_REGEN_DISABLED')
	NP:RegisterEvent('PLAYER_ENTERING_WORLD')
	NP:RegisterEvent('PLAYER_UPDATE_RESTING', 'EnviromentConditionals')
	NP:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'EnviromentConditionals')
	NP:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	NP:RegisterEvent('GROUP_ROSTER_UPDATE')
	NP:RegisterEvent('GROUP_LEFT')
	NP:RegisterEvent('PLAYER_LOGOUT')

	NP:BossMods_RegisterCallbacks()
	NP:StyleFilterInitialize()
	NP:HideInterfaceOptions()
	NP:GROUP_ROSTER_UPDATE()
	NP:SetCVars()
end

E:RegisterModule(NP:GetName())
