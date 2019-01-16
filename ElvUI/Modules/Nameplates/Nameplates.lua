local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUF = ElvUI.oUF

local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')

--Cache global variables
local _G = _G
--Lua functions
local select = select
local pairs = pairs
local type = type
local tonumber = tonumber
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction
local SetCVar, GetCVarDefault = SetCVar, GetCVarDefault
local UnitFactionGroup = UnitFactionGroup
local UnitIsPVPSanctuary = UnitIsPVPSanctuary
local UnitIsFriend = UnitIsFriend
local C_NamePlate = C_NamePlate
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local IsInInstance = IsInInstance
local GetCVar = GetCVar
local Lerp = Lerp

local function CopySettings(from, to)
	for setting, value in pairs(from) do
		if(type(value) == 'table' and to[setting] ~= nil) then
			CopySettings(from[setting], to[setting])
		else
			if(to[setting] ~= nil) then
				to[setting] = from[setting]
			end
		end
	end
end

function NP:ResetSettings(unit)
	CopySettings(P.nameplates.units[unit], self.db.units[unit])
end

function NP:CopySettings(from, to)
	if (from == to) then return end

	CopySettings(self.db.units[from], self.db.units[to])
end

function NP:Style(frame, unit)
	if (not unit) then
		return
	end

	NP:StylePlate(frame, unit)

	return frame
end

function NP:Construct_RaisedELement(nameplate)
	local RaisedElement = CreateFrame('Frame', nameplate:GetDebugName()..'RaisedElement', nameplate)
	RaisedElement:SetFrameStrata(nameplate:GetFrameStrata())
	RaisedElement:SetFrameLevel(10)
	RaisedElement:SetAllPoints()

	return RaisedElement
end

function NP:StylePlate(nameplate)
	nameplate:SetPoint('CENTER')
	nameplate:SetSize(self.db.clickableWidth, self.db.clickableHeight)
	nameplate:SetScale(_G.UIParent:GetEffectiveScale())

	nameplate.RaisedElement = NP:Construct_RaisedELement(nameplate)

	nameplate.Health = NP:Construct_Health(nameplate)

	nameplate.Health.Text = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.Health.Text:SetPoint('CENTER', nameplate.Health, 'CENTER', 0, 0) -- need option
	nameplate:Tag(nameplate.Health.Text, '[perhp]%') -- need option

	nameplate.HealthPrediction = NP:Construct_HealthPrediction(nameplate)

	nameplate.Power = NP:Construct_Power(nameplate)

	nameplate.Power.Text = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.Power.Text:SetPoint('CENTER', nameplate.Power, 'CENTER', 0, 0) -- need option
	nameplate:Tag(nameplate.Power.Text, '[perpp]%') -- need option

	nameplate.PowerPrediction = NP:Construct_PowerPrediction(nameplate)

	nameplate.Name = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.Name:SetPoint('BOTTOMLEFT', nameplate.Health, 'TOPLEFT', 0, E.Border*2) -- need option
	nameplate.Name:SetJustifyH('LEFT')
	nameplate.Name:SetJustifyV('BOTTOM')
	nameplate.Name:SetWordWrap(false)
	nameplate:Tag(nameplate.Name, '[namecolor][name:abbrev] [npctitle]')

	nameplate.Level = NP:Construct_TagText(nameplate.RaisedElement)
	nameplate.Level:SetPoint('BOTTOMRIGHT', nameplate.Health, 'TOPRIGHT', 0, E.Border*2) -- need option
	nameplate.Level:SetJustifyH('RIGHT')
	nameplate:Tag(nameplate.Level, '[difficultycolor][level]')

	nameplate.ClassificationIndicator = NP:Construct_ClassificationIndicator(nameplate.RaisedElement)
	nameplate.ClassificationIndicator:SetPoint('TOPLEFT', nameplate, 'TOPLEFT')

	nameplate.Castbar = NP:Construct_Castbar(nameplate)

	nameplate.Portrait = NP:Construct_Portrait(nameplate.RaisedElement)

	nameplate.QuestIcons = NP:Construct_QuestIcons(nameplate.RaisedElement)

	nameplate.RaidTargetIndicator = NP:Construct_RaidTargetIndicator(nameplate.RaisedElement)

	nameplate.TargetIndicator = NP:Construct_TargetIndicator(nameplate)

	nameplate.ThreatIndicator = NP:Construct_ThreatIndicator(nameplate.RaisedElement)

	nameplate.Highlight = NP:Construct_Highlight(nameplate)

	--nameplate.Auras = NP:Construct_Auras(nameplate)

	nameplate.Buffs = NP:Construct_Buffs(nameplate)
	nameplate.Debuffs = NP:Construct_Debuffs(nameplate)

	nameplate.ClassPower = NP:Construct_ClassPower(nameplate)

	nameplate.PvPIndicator = NP:Construct_PvPIndicator(nameplate.RaisedElement)

	nameplate.HealerSpecs = NP:Construct_HealerSpecs(nameplate.RaisedElement)

	if E.myclass == 'DEATHKNIGHT' then
		nameplate.Runes = NP:Construct_Runes(nameplate)
	end
end

function NP:UpdatePlate(nameplate)
	NP:Update_Auras(nameplate)

	NP:Update_Castbar(nameplate)

	NP:Update_ClassificationIndicator(nameplate)

	NP:Update_QuestIcons(nameplate)

	NP:Update_Portrait(nameplate)

	NP:Update_Health(nameplate)

	NP:Update_HealthPrediction(nameplate)

	NP:Update_Power(nameplate)

	NP:Update_PowerPrediction(nameplate)

	NP:Update_TargetIndicator(nameplate)

	NP:Update_ClassPower(nameplate)

	if E.myclass == 'DEATHKNIGHT' then
		NP:Update_Runes(nameplate)
	end

	NP:Update_Tags(nameplate)

	NP:UpdatePlateEvents(nameplate)

	nameplate:UpdateAllElements('OnShow')
end

function NP:CVarReset()
	SetCVar('nameplateClassResourceTopInset', GetCVarDefault('nameplateClassResourceTopInset'))
	SetCVar('nameplateGlobalScale', GetCVarDefault('nameplateGlobalScale'))
	SetCVar('NamePlateHorizontalScale', GetCVarDefault('NamePlateHorizontalScale'))
	SetCVar('nameplateLargeBottomInset', GetCVarDefault('nameplateLargeBottomInset'))
	SetCVar('nameplateLargerScale', GetCVarDefault('nameplateLargerScale'))
	SetCVar('nameplateLargeTopInset', GetCVarDefault('nameplateLargeTopInset'))
	SetCVar('nameplateMaxAlpha', GetCVarDefault('nameplateMaxAlpha'))
	SetCVar('nameplateMaxAlphaDistance', GetCVarDefault('nameplateMaxAlphaDistance'))
	SetCVar('nameplateMaxScale', GetCVarDefault('nameplateMaxScale'))
	SetCVar('nameplateMaxScaleDistance', GetCVarDefault('nameplateMaxScaleDistance'))
	SetCVar('nameplateMinAlphaDistance', GetCVarDefault('nameplateMinAlphaDistance'))
	SetCVar('nameplateMinScale', GetCVarDefault('nameplateMinScale'))
	SetCVar('nameplateMinScaleDistance', GetCVarDefault('nameplateMinScaleDistance'))
	SetCVar('nameplateMotionSpeed', GetCVarDefault('nameplateMotionSpeed'))
	SetCVar('nameplateOtherAtBase', GetCVarDefault('nameplateOtherAtBase'))
	SetCVar('nameplateOverlapH', GetCVarDefault('nameplateOverlapH'))
	SetCVar('nameplateOverlapV', GetCVarDefault('nameplateOverlapV'))
	SetCVar('nameplateResourceOnTarget', GetCVarDefault('nameplateResourceOnTarget'))
	SetCVar('nameplateSelectedAlpha', GetCVarDefault('nameplateSelectedAlpha'))
	SetCVar('nameplateSelfAlpha', GetCVarDefault('nameplateSelfAlpha'))
	SetCVar('nameplateSelfBottomInset', GetCVarDefault('nameplateSelfBottomInset'))
	SetCVar('nameplateSelfScale', GetCVarDefault('nameplateSelfScale'))
	SetCVar('nameplateSelfTopInset', GetCVarDefault('nameplateSelfTopInset'))
	SetCVar('nameplateShowEnemies', GetCVarDefault('nameplateShowEnemies'))
	SetCVar('nameplateShowEnemyGuardians', GetCVarDefault('nameplateShowEnemyGuardians'))
	SetCVar('nameplateShowEnemyPets', GetCVarDefault('nameplateShowEnemyPets'))
	SetCVar('nameplateShowEnemyTotems', GetCVarDefault('nameplateShowEnemyTotems'))
	SetCVar('nameplateShowFriendlyGuardians', GetCVarDefault('nameplateShowFriendlyGuardians'))
	SetCVar('nameplateShowFriendlyNPCs', GetCVarDefault('nameplateShowFriendlyNPCs'))
	SetCVar('nameplateShowFriendlyPets', GetCVarDefault('nameplateShowFriendlyPets'))
	SetCVar('nameplateShowFriendlyTotems', GetCVarDefault('nameplateShowFriendlyTotems'))
	SetCVar('nameplateShowFriends', GetCVarDefault('nameplateShowFriends'))
	SetCVar('nameplateTargetBehindMaxDistance', GetCVarDefault('nameplateTargetBehindMaxDistance'))
	SetCVar('nameplateSelectedScale', 1)
end

function NP:PLAYER_REGEN_DISABLED()
	if (NP.db.showFriendlyCombat == 'TOGGLE_ON') then
		SetCVar('nameplateShowFriends', 1);
	elseif (NP.db.showFriendlyCombat == 'TOGGLE_OFF') then
		SetCVar('nameplateShowFriends', 0);
	end

	if (NP.db.showEnemyCombat == 'TOGGLE_ON') then
		SetCVar('nameplateShowEnemies', 1);
	elseif (NP.db.showEnemyCombat == 'TOGGLE_OFF') then
		SetCVar('nameplateShowEnemies', 0);
	end
end

function NP:PLAYER_REGEN_ENABLED()
	if (NP.db.showFriendlyCombat == 'TOGGLE_ON') then
		SetCVar('nameplateShowFriends', 0);
	elseif (NP.db.showFriendlyCombat == 'TOGGLE_OFF') then
		SetCVar('nameplateShowFriends', 1);
	end

	if (NP.db.showEnemyCombat == 'TOGGLE_ON') then
		SetCVar('nameplateShowEnemies', 0);
	elseif (NP.db.showEnemyCombat == 'TOGGLE_OFF') then
		SetCVar('nameplateShowEnemies', 1);
	end
end

function NP:Update_StatusBars()
	for StatusBar in pairs(NP.StatusBars) do
		StatusBar:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
	end
end

function NP:Update_Fonts()
end

function NP:CheckGroup()
	NP.IsInGroup = IsInGroup() or IsInRaid()
end

function NP:PLAYER_ENTERING_WORLD()
	NP.InstanceType = select(2, IsInInstance())

	-- workaround for #206
	local friendlyWidth, friendlyHeight

	if NP.InstanceType ~= 'none' then
		local namePlateVerticalScale = tonumber(GetCVar('NamePlateVerticalScale'))
		local horizontalScale = tonumber(GetCVar('NamePlateHorizontalScale'))
		local zeroBasedScale = namePlateVerticalScale - 1.0

		friendlyWidth = _G.NamePlateDriverFrame.baseNamePlateWidth * horizontalScale
		friendlyHeight = _G.NamePlateDriverFrame.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale)
	end

	C_NamePlate.SetNamePlateFriendlySize(friendlyWidth or NP.db.clickableWidth, friendlyHeight or NP.db.clickableHeight)
end

function NP:ConfigureAll()
	NP.PlayerRole = E:GetPlayerRole() -- GetSpecializationRole(GetSpecialization())

	SetCVar('nameplateMaxDistance', NP.db.loadDistance)
	SetCVar('nameplateMotion', NP.db.motionType == 'STACKED' and 1 or 0)
	SetCVar('NameplatePersonalHideDelayAlpha', NP.db.units.PLAYER.visibility.hideDelay)
	SetCVar('NameplatePersonalShowAlways', (NP.db.units.PLAYER.visibility.showAlways == true and 1 or 0))
	SetCVar('NameplatePersonalShowInCombat', (NP.db.units.PLAYER.visibility.showInCombat == true and 1 or 0))
	SetCVar('NameplatePersonalShowWithTarget', (NP.db.units.PLAYER.visibility.showWithTarget == true and 1 or 0))
	SetCVar('nameplateShowAll', NP.db.displayStyle ~= 'ALL' and 0 or 1)
	SetCVar('nameplateShowFriendlyMinions', NP.db.units.FRIENDLY_PLAYER.minions == true and 1 or 0)
	SetCVar('nameplateShowEnemyMinions', NP.db.units.ENEMY_PLAYER.minions == true and 1 or 0)
	SetCVar('nameplateShowEnemyMinus', NP.db.units.ENEMY_NPC.minors == true and 1 or 0)
	SetCVar('nameplateShowSelf', (NP.db.units.PLAYER.useStaticPosition == true or NP.db.units.PLAYER.enable ~= true) and 0 or 1)
	SetCVar('nameplateMinAlpha', NP.db.nonTargetTransparency)
	SetCVar('nameplateOtherTopInset', NP.db.clampToScreen and 0.08 or -1)
	SetCVar('nameplateOtherBottomInset', NP.db.clampToScreen and 0.1 or -1)

	if NP.db.questIcon then
		SetCVar('showQuestTrackingTooltips', 1)
	end

	C_NamePlate.SetNamePlateSelfSize(NP.db.clickableWidth, NP.db.clickableHeight)
	C_NamePlate.SetNamePlateEnemySize(NP.db.clickableWidth, NP.db.clickableHeight)

	NP:PLAYER_REGEN_ENABLED()

	if NP.db.units['PLAYER'].useStaticPosition then
		_G.ElvNP_Player:Enable()
		_G.ElvNP_Player:UpdateAllElements('OnShow')
	else
		_G.ElvNP_Player:Disable()
	end

	NP:NamePlateCallBack(_G.ElvNP_Player, 'NAME_PLATE_UNIT_ADDED')

	for nameplate in pairs(NP.Plates) do
		NP:NamePlateCallBack(nameplate, 'NAME_PLATE_UNIT_ADDED')
	end

	NP:StyleFilterConfigureEvents() -- Populate `mod.StyleFilterEvents` with events Style Filters will be using and sort the filters based on priority.
	NP:Update_StatusBars()
	NP:Update_Fonts()
end

function NP:NamePlateCallBack(nameplate, event, unit)
	if event == 'NAME_PLATE_UNIT_ADDED' then
		unit = unit or nameplate.unit
		local reaction = UnitReaction('player', unit)
		local faction = UnitFactionGroup(unit)

		if UnitIsUnit(unit, 'player') then
			nameplate.frameType = 'PLAYER'
		elseif UnitIsPVPSanctuary(unit) or (UnitIsPlayer(unit) and UnitIsFriend('player', unit) and reaction and reaction >= 5) then
			nameplate.frameType = 'FRIENDLY_PLAYER'
		elseif not UnitIsPlayer(unit) and (reaction and reaction >= 5) or faction == 'Neutral' then
			nameplate.frameType = 'FRIENDLY_NPC'
		elseif not UnitIsPlayer(unit) and (reaction and reaction <= 4) then
			nameplate.frameType = 'ENEMY_NPC'
		else
			nameplate.frameType = 'ENEMY_PLAYER'
		end

		NP:UpdatePlate(nameplate)

		if NP.db.units['PLAYER'].useStaticPosition then
			NP:UpdatePlate(_G.ElvNP_Player)
		end

		NP.Plates[nameplate] = true
	end
end

function NP:ACTIVE_TALENT_GROUP_CHANGED()
	NP.PlayerRole = E:GetPlayerRole() -- GetSpecializationRole(GetSpecialization())
end

-- Event functions fired from the NamePlate itself
NP.plateEvents = {
	-- any registered as `true` will call noop
	['PLAYER_TARGET_CHANGED'] = function(self)
		self.isTarget = self.unit and UnitIsUnit(self.unit, 'target') or nil
	end,
	['UNIT_TARGET'] = function(self, _, unit)
		unit = unit or self.unit
		self.isTargetingMe = UnitIsUnit(unit..'target', 'player') or nil
	end,
	['SPELL_UPDATE_COOLDOWN'] = true
}

function NP:RegisterElementEvent(nameplate, event, func, unitless)
	if not func then
		func = NP.plateEvents[event]
		if func == true then func = E.noop end
	end

	if not func then return end
	nameplate:RegisterEvent(event, func, unitless)
end

function NP:UpdatePlateEvents(nameplate)
	NP:RegisterElementEvent(nameplate, 'PLAYER_TARGET_CHANGED', nil, true)
	NP:RegisterElementEvent(nameplate, 'SPELL_UPDATE_COOLDOWN', nil, true)
	NP:RegisterElementEvent(nameplate, 'UNIT_TARGET')

	-- NP:StyleFilterEventWatch(nameplate)
end

function NP:Initialize()
	NP.db = E.db.nameplates

	if E.private.nameplates.enable ~= true then return end

	ElvUF:RegisterStyle('ElvNP', function(frame, unit)
		NP:Style(frame, unit)
	end)
	ElvUF:SetActiveStyle('ElvNP')

	NP.Plates = {}
	NP.StatusBars = {}

	local BlizzPlateManaBar = _G.NamePlateDriverFrame.classNamePlatePowerBar
	if BlizzPlateManaBar then
		BlizzPlateManaBar:Hide()
		BlizzPlateManaBar:UnregisterAllEvents()
	end

	hooksecurefunc(_G.NamePlateDriverFrame, 'SetupClassNameplateBars', function(frame)
		if frame.classNamePlateMechanicFrame then
			frame.classNamePlateMechanicFrame:Hide()
		end
		if frame.classNamePlatePowerBar then
			frame.classNamePlatePowerBar:Hide()
			frame.classNamePlatePowerBar:UnregisterAllEvents()
		end
	end)

	NP.Tooltip = CreateFrame('GameTooltip', 'ElvUIQuestTooltip', nil, 'GameTooltipTemplate')
	NP.Tooltip:SetOwner(_G.WorldFrame, 'ANCHOR_NONE')

	ElvUF:Spawn('player', 'ElvNP_Player')
	_G.ElvNP_Player:SetAttribute('unit', 'player')
	_G.ElvNP_Player:RegisterForClicks('LeftButtonDown', 'RightButtonDown')
	_G.ElvNP_Player:SetAttribute('*type1', 'target')
	_G.ElvNP_Player:SetAttribute('*type2', 'togglemenu')
	_G.ElvNP_Player:SetAttribute('toggleForVehicle', true)
	_G.ElvNP_Player:SetPoint('TOP', _G.UIParent, 'CENTER', 0, -150)
	_G.ElvNP_Player:SetSize(NP.db.clickableWidth, NP.db.clickableHeight)
	_G.ElvNP_Player:SetScale(1)
	_G.ElvNP_Player:SetScript('OnEnter', _G.UnitFrame_OnEnter)
	_G.ElvNP_Player:SetScript('OnLeave', _G.UnitFrame_OnLeave)
	_G.ElvNP_Player.frameType = 'PLAYER'

	if not NP.db.units['PLAYER'].useStaticPosition then
		_G.ElvNP_Player:Disable()
	end

	E:CreateMover(_G.ElvNP_Player, 'ElvNP_PlayerMover', L['Player NamePlate'], nil, nil, nil, 'ALL,SOLO', nil, 'player,generalGroup')

	ElvUF:SpawnNamePlates('ElvNP_', function(nameplate, event, unit)
		NP:NamePlateCallBack(nameplate, event, unit)
	end)

	NP:RegisterEvent('PLAYER_REGEN_ENABLED')
	NP:RegisterEvent('PLAYER_REGEN_DISABLED')
	NP:RegisterEvent('PLAYER_ENTERING_WORLD')
	NP:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	NP:RegisterEvent('GROUP_FORMED', 'CheckGroup')
	NP:RegisterEvent('GROUP_LEFT', 'CheckGroup')

	NP:StyleFilterInitializeAllFilters() -- Add metatable to all our StyleFilters so they can grab default values if missing
	NP:ACTIVE_TALENT_GROUP_CHANGED()
	NP:CheckGroup()
	NP:ConfigureAll()

	E.NamePlates = NP
end

local function InitializeCallback()
	NP:Initialize()
end

E:RegisterModule(NP:GetName(), InitializeCallback)
