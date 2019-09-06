local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")
local oUF = E.oUF

--Lua functions
local _G = _G
local format, pairs, select, strsplit, type, wipe = format, pairs, select, strsplit, type, wipe
--WoW API / Variables
local CreateFrame = CreateFrame
local GetCVar = GetCVar
local GetCVarDefault = GetCVarDefault
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local SetCVar = SetCVar
local ShowBossFrameWhenUninteractable = ShowBossFrameWhenUninteractable
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitGUID = UnitGUID
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVPSanctuary = UnitIsPVPSanctuary
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitPlayerControlled = UnitPlayerControlled
local UnitReaction = UnitReaction
local UnitSelectionType = UnitSelectionType
local UnitThreatSituation = UnitThreatSituation
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

local function CopySettings(from, to)
	for setting, value in pairs(from) do
		if (type(value) == "table" and to[setting] ~= nil) then
			CopySettings(from[setting], to[setting])
		else
			if (to[setting] ~= nil) then
				to[setting] = from[setting]
			end
		end
	end
end

function NP:ResetSettings(unit)
	CopySettings(P.nameplates.units[unit], self.db.units[unit])
end

function NP:CopySettings(from, to)
	if (from == to) then
		return
	end

	CopySettings(self.db.units[from], self.db.units[to])
end

function NP:CVarReset()
	SetCVar("nameplateMinAlpha", 1)
	SetCVar("nameplateMaxAlpha", 1)
	SetCVar("nameplateClassResourceTopInset", GetCVarDefault("nameplateClassResourceTopInset"))
	SetCVar("nameplateGlobalScale", 1)
	SetCVar("NamePlateHorizontalScale", 1)
	SetCVar("nameplateLargeBottomInset", GetCVarDefault("nameplateLargeBottomInset"))
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateLargeTopInset", GetCVarDefault("nameplateLargeTopInset"))
	SetCVar("nameplateMaxAlphaDistance", GetCVarDefault("nameplateMaxAlphaDistance"))
	SetCVar("nameplateMaxScale", 1)
	SetCVar("nameplateMaxScaleDistance", 40)
	SetCVar("nameplateMinAlphaDistance", GetCVarDefault("nameplateMinAlphaDistance"))
	SetCVar("nameplateMinScale", 1)
	SetCVar("nameplateMinScaleDistance", 0)
	SetCVar("nameplateMotionSpeed", GetCVarDefault("nameplateMotionSpeed"))
	SetCVar("nameplateOccludedAlphaMult", GetCVarDefault("nameplateOccludedAlphaMult"))
	SetCVar("nameplateOtherAtBase", GetCVarDefault("nameplateOtherAtBase"))
	SetCVar("nameplateOverlapH", GetCVarDefault("nameplateOverlapH"))
	SetCVar("nameplateOverlapV", GetCVarDefault("nameplateOverlapV"))
	SetCVar("nameplateResourceOnTarget", GetCVarDefault("nameplateResourceOnTarget"))
	SetCVar("nameplateSelectedAlpha", 1)
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateSelfAlpha", 1)
	SetCVar("nameplateSelfBottomInset", GetCVarDefault("nameplateSelfBottomInset"))
	SetCVar("nameplateSelfScale", 1)
	SetCVar("nameplateSelfTopInset", GetCVarDefault("nameplateSelfTopInset"))
	SetCVar("nameplateTargetBehindMaxDistance", 40)
end

function NP:SetCVars()
	if NP.db.units.ENEMY_NPC.questIcon.enable or NP.db.units.FRIENDLY_NPC.questIcon.enable then
		SetCVar("showQuestTrackingTooltips", 1)
	end

	if NP.db.clampToScreen then
		SetCVar("nameplateOtherTopInset", 0.08)
		SetCVar("nameplateOtherBottomInset", 0.1)
	elseif GetCVar("nameplateOtherTopInset") == "0.08" and GetCVar("nameplateOtherBottomInset") == "0.1" then
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end

	SetCVar("nameplateMaxDistance", NP.db.loadDistance)
	SetCVar("nameplateMotion", NP.db.motionType == "STACKED" and 1 or 0)

	SetCVar("NameplatePersonalShowAlways", NP.db.units.PLAYER.visibility.showAlways and 1 or 0)
	SetCVar("NameplatePersonalShowInCombat", NP.db.units.PLAYER.visibility.showInCombat and 1 or 0)
	SetCVar("NameplatePersonalShowWithTarget", NP.db.units.PLAYER.visibility.showWithTarget and 1 or 0)
	SetCVar("NameplatePersonalHideDelayAlpha", NP.db.units.PLAYER.visibility.hideDelay)

	-- the order of these is important !!
	SetCVar("nameplateShowAll", NP.db.visibility.showAll and 1 or 0)
	SetCVar("nameplateShowSelf", (NP.db.units.PLAYER.useStaticPosition or not NP.db.units.PLAYER.enable) and 0 or 1)
	SetCVar("nameplateShowEnemyMinions", NP.db.visibility.enemy.minions and 1 or 0)
	SetCVar("nameplateShowEnemyGuardians", NP.db.visibility.enemy.guardians and 1 or 0)
	SetCVar("nameplateShowEnemyMinus", NP.db.visibility.enemy.minus and 1 or 0)
	SetCVar("nameplateShowEnemyPets", NP.db.visibility.enemy.pets and 1 or 0)
	SetCVar("nameplateShowEnemyTotems", NP.db.visibility.enemy.totems and 1 or 0)
	SetCVar("nameplateShowFriendlyMinions", NP.db.visibility.friendly.minions and 1 or 0)
	SetCVar("nameplateShowFriendlyGuardians", NP.db.visibility.friendly.guardians and 1 or 0)
	SetCVar("nameplateShowFriendlyNPCs", NP.db.visibility.friendly.npcs and 1 or 0)
	SetCVar("nameplateShowFriendlyPets", NP.db.visibility.friendly.pets and 1 or 0)
	SetCVar("nameplateShowFriendlyTotems", NP.db.visibility.friendly.totems and 1 or 0)
end

function NP:PLAYER_REGEN_DISABLED()
	if (NP.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 1)
	elseif (NP.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 0)
	end

	if (NP.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 1)
	elseif (NP.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 0)
	end
end

function NP:PLAYER_REGEN_ENABLED()
	if (NP.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 0)
	elseif (NP.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 1)
	end

	if (NP.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 0)
	elseif (NP.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 1)
	end
end

function NP:Style(frame, unit)
	if (not unit) then
		return
	end

	frame.isNamePlate = true

	if frame:GetName() == "ElvNP_TargetClassPower" then
		NP:StyleTargetPlate(frame, unit)
	else
		NP:StylePlate(frame, unit)
	end

	return frame
end

function NP:Construct_RaisedELement(nameplate)
	local RaisedElement = CreateFrame("Frame", nameplate:GetDebugName() .. "RaisedElement", nameplate)
	RaisedElement:SetFrameStrata(nameplate:GetFrameStrata())
	RaisedElement:SetFrameLevel(10)
	RaisedElement:SetAllPoints()
	RaisedElement:EnableMouse(false)

	return RaisedElement
end

function NP:StyleTargetPlate(nameplate)
	nameplate:ClearAllPoints()
	nameplate:Point("CENTER")
	nameplate:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	nameplate:SetScale(E.global.general.UIScale)

	nameplate.RaisedElement = NP:Construct_RaisedELement(nameplate)

	--nameplate.Power = NP:Construct_Power(nameplate)

	--nameplate.Power.Text = NP:Construct_TagText(nameplate.RaisedElement)

	nameplate.ClassPower = NP:Construct_ClassPower(nameplate)

	if E.myclass == "DEATHKNIGHT" then
		nameplate.Runes = NP:Construct_Runes(nameplate)
	elseif E.myclass == "MONK" then
		nameplate.Stagger = NP:Construct_Stagger(nameplate)
	end
end

function NP:UpdateTargetPlate(nameplate)
	NP:Update_ClassPower(nameplate)

	if E.myclass == "DEATHKNIGHT" then
		NP:Update_Runes(nameplate)
	elseif E.myclass == "MONK" then
		NP:Update_Stagger(nameplate)
	end

	nameplate:UpdateAllElements("OnShow")
end

function NP:ScalePlate(nameplate, scale, targetPlate)
	local mult = (nameplate == _G.ElvNP_Player and E.mult) or E.global.general.UIScale
	if targetPlate and NP.targetPlate then
		NP.targetPlate:SetScale(mult)
		NP.targetPlate = nil
	end

	if not nameplate then
		return
	end

	local targetScale = format("%.2f", mult * scale)
	nameplate:SetScale(targetScale)

	if targetPlate then
		NP.targetPlate = nameplate
	end
end

function NP:StylePlate(nameplate)
	nameplate:ClearAllPoints()
	nameplate:Point("CENTER")
	nameplate:SetScale(E.global.general.UIScale)

	nameplate.RaisedElement = NP:Construct_RaisedELement(nameplate)
	nameplate.Health = NP:Construct_Health(nameplate)
	nameplate.Health.Text = NP:Construct_TagText(nameplate.RaisedElement)
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
	nameplate.HealerSpecs = NP:Construct_HealerSpecs(nameplate.RaisedElement)
	nameplate.Cutaway = NP:Construct_Cutaway(nameplate)
	nameplate.NazjatarFollowerXP = NP:Construct_NazjatarFollowerXP(nameplate)
	nameplate.NazjatarFollowerXP.Rank = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.NazjatarFollowerXP.ProgressText = NP:Construct_TagText(nameplate.RaisedElement)

	NP:Construct_Auras(nameplate)

	if E.myclass == "DEATHKNIGHT" then
		nameplate.Runes = NP:Construct_Runes(nameplate)
	elseif E.myclass == "MONK" then
		nameplate.Stagger = NP:Construct_Stagger(nameplate)
	end

	NP.Plates[nameplate] = nameplate:GetName()

	NP:StyleFilterPlateStyled(nameplate)
end

function NP:UpdatePlate(nameplate)
	NP:Update_Tags(nameplate)
	NP:Update_Highlight(nameplate)

	if (nameplate.VisibilityChanged or nameplate.NameOnlyChanged) or (not NP.db.units[nameplate.frameType].enable) or NP.db.units[nameplate.frameType].nameOnly then
		NP:DisablePlate(nameplate, nameplate.NameOnlyChanged or (NP.db.units[nameplate.frameType].nameOnly and not nameplate.VisibilityChanged))
	else
		NP:Update_Health(nameplate)
		NP:Update_HealthPrediction(nameplate)
		NP:Update_Power(nameplate)
		NP:Update_Castbar(nameplate)
		NP:Update_ClassPower(nameplate)
		NP:Update_Auras(nameplate, true)
		NP:Update_ClassificationIndicator(nameplate)
		NP:Update_QuestIcons(nameplate)
		NP:Update_Portrait(nameplate)
		NP:Update_PvPIndicator(nameplate) -- Horde / Alliance / HonorInfo
		NP:Update_PvPClassificationIndicator(nameplate) -- Cart / Flag / Orb / Assassin Bounty
		NP:Update_TargetIndicator(nameplate)
		NP:Update_ThreatIndicator(nameplate)
		NP:Update_RaidTargetIndicator(nameplate)
		NP:Update_HealerSpecs(nameplate)
		NP:Update_Cutaway(nameplate)
		NP:Update_NazjatarFollowerXP(nameplate)

		if E.myclass == "DEATHKNIGHT" then
			NP:Update_Runes(nameplate)
		elseif E.myclass == "MONK" then
			NP:Update_Stagger(nameplate)
		end

		if nameplate == _G.ElvNP_Player then
			NP:Update_Fader(nameplate)
		end

		if nameplate.isTarget then
			NP:SetupTarget(nameplate)
		end
	end

	NP:StyleFilterEvents(nameplate)
end

function NP:DisablePlate(nameplate, nameOnly)
	if nameplate:IsElementEnabled("Health") then nameplate:DisableElement("Health") end
	if nameplate:IsElementEnabled("HealthPrediction") then nameplate:DisableElement("HealthPrediction") end
	if nameplate:IsElementEnabled("Power") then nameplate:DisableElement("Power") end
	if nameplate:IsElementEnabled("ClassificationIndicator") then nameplate:DisableElement("ClassificationIndicator") end
	if nameplate:IsElementEnabled("Castbar") then nameplate:DisableElement("Castbar") end
	if nameplate:IsElementEnabled("Portrait") then nameplate:DisableElement("Portrait") end
	if nameplate:IsElementEnabled("QuestIcons") then nameplate:DisableElement("QuestIcons") end
	if nameplate:IsElementEnabled("ThreatIndicator") then nameplate:DisableElement("ThreatIndicator") end
	if nameplate:IsElementEnabled("ClassPower") then nameplate:DisableElement("ClassPower") end
	if nameplate:IsElementEnabled("PvPIndicator") then nameplate:DisableElement("PvPIndicator") end
	if nameplate:IsElementEnabled("PvPClassificationIndicator") then nameplate:DisableElement("PvPClassificationIndicator") end
	if nameplate:IsElementEnabled("HealerSpecs") then nameplate:DisableElement("HealerSpecs") end
	if nameplate:IsElementEnabled("Auras") then nameplate:DisableElement("Auras") end

	if E.myclass == "DEATHKNIGHT" and nameplate:IsElementEnabled("Runes") then
		nameplate:DisableElement("Runes")
	end
	if E.myclass == "MONK" and nameplate:IsElementEnabled("Stagger") then
		nameplate:DisableElement("Stagger")
	end

	NP:Update_Tags(nameplate)

	nameplate.Health.Text:Hide()
	nameplate.Power.Text:Hide()
	nameplate.Name:Hide()
	nameplate.Level:Hide()
	nameplate.Title:Hide()

	if nameOnly then
		NP:Update_Highlight(nameplate)
		nameplate.Name:Show()
		nameplate.Name:ClearAllPoints()
		nameplate.Name:Point("CENTER", nameplate, "CENTER", 0, 0)
		if NP.db.units[nameplate.frameType].showTitle then
			nameplate.Title:Show()
			nameplate.Title:ClearAllPoints()
			nameplate.Title:Point("TOP", nameplate.Name, "BOTTOM", 0, -2)
		end
	elseif nameplate:IsElementEnabled("Highlight") then
		nameplate:DisableElement("Hightlight")
	end
end

function NP:SetupTarget(nameplate, removed)
	local TCP = _G.ElvNP_TargetClassPower
	local nameOnly = nameplate and (nameplate.NameOnlyChanged or NP.db.units[nameplate.frameType].nameOnly)
	TCP.realPlate = (NP.db.units.TARGET.classpower.enable and not (removed or nameOnly) and nameplate) or nil

	local moveToPlate = TCP.realPlate or TCP

	if TCP.ClassPower then
		TCP.ClassPower:SetParent(moveToPlate)
		TCP.ClassPower:ClearAllPoints()
		TCP.ClassPower:Point("CENTER", moveToPlate, "CENTER", NP.db.units.TARGET.classpower.xOffset, NP.db.units.TARGET.classpower.yOffset)
	end
	if TCP.Runes then
		TCP.Runes:SetParent(moveToPlate)
		TCP.Runes:ClearAllPoints()
		TCP.Runes:Point("CENTER", moveToPlate, "CENTER", NP.db.units.TARGET.classpower.xOffset, NP.db.units.TARGET.classpower.yOffset)
	end
	if TCP.Stagger then
		TCP.Stagger:SetParent(moveToPlate)
		TCP.Stagger:ClearAllPoints()
		TCP.Stagger:Point("CENTER", moveToPlate, "CENTER", NP.db.units.TARGET.classpower.xOffset, NP.db.units.TARGET.classpower.yOffset)
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
	for StatusBar in pairs(NP.StatusBars) do
		StatusBar:SetStatusBarTexture(E.LSM:Fetch("statusbar", NP.db.statusbar))
	end
end

function NP:GROUP_ROSTER_UPDATE()
	local isInRaid = IsInRaid()
	NP.IsInGroup = isInRaid or IsInGroup()

	wipe(NP.GroupRoles)

	if NP.IsInGroup then
		local NumPlayers, Unit =
			(isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers(),
			(isInRaid and "raid") or "party"
		for i = 1, NumPlayers do
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
	local _, instanceType = GetInstanceInfo()
	NP.InstanceType = instanceType

	if NP.db.units.PLAYER.enable and NP.db.units.PLAYER.useStaticPosition then
		NP:UpdatePlate(_G.ElvNP_Player)
	end
end

function NP:ConfigureAll()
	NP:StyleFilterConfigure() -- keep this at the top

	local Scale = E.global.general.UIScale

	C_NamePlate_SetNamePlateSelfSize(NP.db.plateSize.personalWidth * Scale, NP.db.plateSize.personalHeight * Scale)
	C_NamePlate_SetNamePlateEnemySize(NP.db.plateSize.enemyWidth * Scale, NP.db.plateSize.enemyHeight * Scale)
	C_NamePlate_SetNamePlateFriendlySize(NP.db.plateSize.friendlyWidth * Scale, NP.db.plateSize.friendlyHeight * Scale)

	NP:PLAYER_REGEN_ENABLED()

	if NP.db.units.PLAYER.enable and NP.db.units.PLAYER.useStaticPosition then
		_G.ElvNP_Player:Enable()
		_G.ElvNP_StaticSecure:Show()
	else
		NP:DisablePlate(_G.ElvNP_Player)
		_G.ElvNP_Player:Disable()
		_G.ElvNP_StaticSecure:Hide()
	end

	NP:UpdateTargetPlate(_G.ElvNP_TargetClassPower)

	for nameplate in pairs(NP.Plates) do
		if _G.ElvNP_Player ~= nameplate or (NP.db.units.PLAYER.enable and NP.db.units.PLAYER.useStaticPosition) then
			NP:StyleFilterClear(nameplate) -- keep this at the top of the loop

			if nameplate.frameType == "PLAYER" then
				nameplate:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
			elseif nameplate.frameType == "FRIENDLY_PLAYER" or nameplate.frameType == "FRIENDLY_NPC" then
				nameplate:Size(NP.db.plateSize.friendlyWidth, NP.db.plateSize.friendlyHeight)
			else
				nameplate:Size(NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight)
			end

			NP:UpdatePlate(nameplate)

			if nameplate.isTarget then
				NP:SetupTarget(nameplate)
			end

			nameplate:UpdateAllElements("ForceUpdate")

			if nameplate.frameType == "PLAYER" then
				NP.PlayerNamePlateAnchor:ClearAllPoints()
				NP.PlayerNamePlateAnchor:SetParent(NP.db.units.PLAYER.useStaticPosition and _G.ElvNP_Player or nameplate)
				NP.PlayerNamePlateAnchor:SetAllPoints(NP.db.units.PLAYER.useStaticPosition and _G.ElvNP_Player or nameplate)
				NP.PlayerNamePlateAnchor:Show()
			end

			NP:StyleFilterUpdate(nameplate, "NAME_PLATE_UNIT_ADDED") -- keep this at the end of the loop
		end
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
	if event == "NAME_PLATE_UNIT_ADDED" then
		NP:StyleFilterClear(nameplate) -- keep this at the top

		unit = unit or nameplate.unit

		nameplate.blizzPlate = nameplate:GetParent().UnitFrame
		nameplate.className, nameplate.classFile, nameplate.classID = UnitClass(unit)
		nameplate.classification = UnitClassification(unit)
		nameplate.creatureType = UnitCreatureType(unit)
		nameplate.isPet = UnitIsUnit(unit, "pet")
		nameplate.isPlayer = UnitIsPlayer(unit)
		nameplate.isPlayerControlled = UnitPlayerControlled(unit)
		nameplate.reaction = UnitReaction("player", unit)
		nameplate.repReaction = UnitReaction(unit, "player")
		nameplate.unitGUID = UnitGUID(unit)
		nameplate.unitName = UnitName(unit)
		nameplate.npcID = nameplate.unitGUID and select(6, strsplit("-", nameplate.unitGUID))

		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate, nameplate.unitGUID)
		end

		NP:StyleFilterSetVariables(nameplate) -- sets: isTarget, isTargetingMe, isFocused

		if UnitIsUnit(unit, "player") and NP.db.units.PLAYER.enable then
			nameplate.frameType = "PLAYER"
			NP.PlayerNamePlateAnchor:ClearAllPoints()
			NP.PlayerNamePlateAnchor:SetParent(NP.db.units.PLAYER.useStaticPosition and _G.ElvNP_Player or nameplate)
			NP.PlayerNamePlateAnchor:SetAllPoints(NP.db.units.PLAYER.useStaticPosition and _G.ElvNP_Player or nameplate)
			NP.PlayerNamePlateAnchor:Show()
		elseif UnitIsPVPSanctuary(unit) or (nameplate.isPlayer and UnitIsFriend("player", unit) and nameplate.reaction and nameplate.reaction >= 5) then
			nameplate.frameType = "FRIENDLY_PLAYER"
		elseif not nameplate.isPlayer and (nameplate.reaction and nameplate.reaction >= 5) or UnitFactionGroup(unit) == "Neutral" then
			nameplate.frameType = "FRIENDLY_NPC"
		elseif not nameplate.isPlayer and (nameplate.reaction and nameplate.reaction <= 4) then
			nameplate.frameType = "ENEMY_NPC"
		else
			nameplate.frameType = "ENEMY_PLAYER"
		end

		if nameplate.frameType == "PLAYER" then
			nameplate.width, nameplate.height = NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight
		elseif nameplate.frameType == "FRIENDLY_PLAYER" or nameplate.frameType == "FRIENDLY_NPC" then
			nameplate.width, nameplate.height = NP.db.plateSize.friendlyWidth, NP.db.plateSize.friendlyHeight
		else
			nameplate.width, nameplate.height = NP.db.plateSize.enemyWidth, NP.db.plateSize.enemyHeight
		end

		nameplate:Size(nameplate.width, nameplate.height)

		NP:UpdatePlate(nameplate)

		if nameplate.isTarget then
			NP:SetupTarget(nameplate)
		end

		if NP.db.fadeIn and (nameplate ~= _G.ElvNP_Player or (NP.db.units.PLAYER.enable and NP.db.units.PLAYER.useStaticPosition)) then
			NP:PlateFade(nameplate, 1, 0, 1)
		end

		nameplate:UpdateTags()

		NP:StyleFilterUpdate(nameplate, event) -- keep this at the end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		NP:StyleFilterClear(nameplate) -- keep this at the top

		if nameplate.frameType == "PLAYER" and (nameplate ~= _G.ElvNP_Test) then
			NP.PlayerNamePlateAnchor:Hide()
		end

		if nameplate.isTarget then
			NP:SetupTarget(nameplate, true)
			NP:ScalePlate(nameplate, 1, true)
		end

		if nameplate.unitGUID then
			NP:UpdatePlateGUID(nameplate)
		end

		-- cutaway needs this
		nameplate.Health.cur = nil
		nameplate.Power.cur = nil

		NP:StyleFilterClearVariables(nameplate)
	elseif event == "PLAYER_TARGET_CHANGED" then -- we need to check if nameplate exists in here
		NP:SetupTarget(nameplate) -- pass it, even as nil here
	end
end

local optionsTable = {
	"EnemyMinus",
	"EnemyMinions",
	"FriendlyMinions",
	"PersonalResource",
	"PersonalResourceOnEnemy",
	"MotionDropDown",
	"ShowAll"
}
function NP:HideInterfaceOptions()
	for _, x in pairs(optionsTable) do
		local o = _G["InterfaceOptionsNamesPanelUnitNameplates" .. x]
		o:SetSize(0.0001, 0.0001)
		o:SetAlpha(0)
		o:Hide()
	end
end

function NP:Initialize()
	NP.db = E.db.nameplates

	if E.private.nameplates.enable ~= true then return end
	NP.Initialized = true

	oUF:RegisterStyle("ElvNP", function(frame, unit) NP:Style(frame, unit) end)
	oUF:SetActiveStyle("ElvNP")

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

	hooksecurefunc(_G.NamePlateDriverFrame, "UpdateNamePlateOptions", function()
		local Scale = E.global.general.UIScale
		C_NamePlate_SetNamePlateSelfSize(NP.db.plateSize.personalWidth * Scale, NP.db.plateSize.personalHeight * Scale)
		C_NamePlate_SetNamePlateEnemySize(NP.db.plateSize.enemyWidth * Scale, NP.db.plateSize.enemyHeight * Scale)
		C_NamePlate_SetNamePlateFriendlySize(NP.db.plateSize.friendlyWidth * Scale, NP.db.plateSize.friendlyHeight * Scale)
	end)

	hooksecurefunc(_G.NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
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

	oUF:Spawn("player", "ElvNP_Player", "")

	_G.ElvNP_Player:ClearAllPoints()
	_G.ElvNP_Player:Point("TOP", _G.UIParent, "CENTER", 0, -150)
	_G.ElvNP_Player:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	_G.ElvNP_Player:SetScale(E.mult)
	_G.ElvNP_Player.frameType = "PLAYER"

	E:CreateMover(_G.ElvNP_Player, "ElvNP_PlayerMover", L["Player NamePlate"], nil, nil, nil, "ALL,SOLO", nil, "nameplate,playerGroup")

	local StaticSecure = CreateFrame("Button", "ElvNP_StaticSecure", _G.UIParent, "SecureUnitButtonTemplate")
	StaticSecure:SetAttribute("unit", "player")
	StaticSecure:SetAttribute("*type1", "target")
	StaticSecure:SetAttribute("*type2", "togglemenu")
	StaticSecure:SetAttribute("toggleForVehicle", true)
	StaticSecure:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	StaticSecure:SetScript("OnEnter", _G.UnitFrame_OnEnter)
	StaticSecure:SetScript("OnLeave", _G.UnitFrame_OnLeave)
	StaticSecure:ClearAllPoints()
	StaticSecure:Point("BOTTOMRIGHT", _G.ElvNP_PlayerMover)
	StaticSecure:Point("TOPLEFT", _G.ElvNP_PlayerMover)
	StaticSecure.unit = "player" -- Needed for OnEnter, OnLeave
	StaticSecure:Hide()

	oUF:Spawn("player", "ElvNP_Test")

	_G.ElvNP_Test:ClearAllPoints()
	_G.ElvNP_Test:Point("BOTTOM", _G.UIParent, "BOTTOM", 0, 250)
	_G.ElvNP_Test:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	_G.ElvNP_Test:SetScale(1)
	_G.ElvNP_Test:SetMovable(true)
	_G.ElvNP_Test:RegisterForDrag("LeftButton", "RightButton")
	_G.ElvNP_Test:SetScript("OnDragStart", function() _G.ElvNP_Test:StartMoving() end)
	_G.ElvNP_Test:SetScript("OnDragStop", function() _G.ElvNP_Test:StopMovingOrSizing() end)
	_G.ElvNP_Test.frameType = "PLAYER"
	_G.ElvNP_Test:Disable()
	NP:DisablePlate(_G.ElvNP_Test)

	oUF:Spawn("player", "ElvNP_TargetClassPower")

	_G.ElvNP_TargetClassPower:SetScale(1)
	_G.ElvNP_TargetClassPower:Size(NP.db.plateSize.personalWidth, NP.db.plateSize.personalHeight)
	_G.ElvNP_TargetClassPower.frameType = "TARGET"
	_G.ElvNP_TargetClassPower:SetAttribute("toggleForVehicle", true)
	_G.ElvNP_TargetClassPower:ClearAllPoints()
	_G.ElvNP_TargetClassPower:Point("TOP", E.UIParent, "BOTTOM", 0, -500)

	NP.PlayerNamePlateAnchor = CreateFrame("Frame", "ElvUIPlayerNamePlateAnchor", E.UIParent)
	NP.PlayerNamePlateAnchor:EnableMouse(false)
	NP.PlayerNamePlateAnchor:Hide()

	oUF:SpawnNamePlates("ElvNP_", function(nameplate, event, unit) NP:NamePlateCallBack(nameplate, event, unit) end)

	NP:RegisterEvent("PLAYER_REGEN_ENABLED")
	NP:RegisterEvent("PLAYER_REGEN_DISABLED")
	NP:RegisterEvent("PLAYER_ENTERING_WORLD")
	NP:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	NP:RegisterEvent("GROUP_ROSTER_UPDATE")
	NP:RegisterEvent("GROUP_LEFT")
	NP:RegisterEvent("PLAYER_LOGOUT", NP.StyleFilterClearDefaults)

	NP:StyleFilterInitialize()
	NP:HideInterfaceOptions()
	NP:GROUP_ROSTER_UPDATE()
	NP:SetCVars()
	NP:ConfigureAll()
end

E:RegisterModule(NP:GetName())
