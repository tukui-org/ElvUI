local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUF = ElvUI.oUF

local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')

--Cache global variables
--Lua functions
local pairs = pairs
local type = type
local gsub = gsub
local wipe = table.wipe
local format = string.format
local strmatch = string.match
local strjoin = strjoin
local tonumber = tonumber
local unpack = unpack

--WoW API / Variables
local CreateFrame = CreateFrame
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction
local SetCVar, GetCVarDefault = SetCVar, GetCVarDefault
local UnitFactionGroup = UnitFactionGroup
local UnitIsPVPSanctuary = UnitIsPVPSanctuary
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local Lerp = Lerp
local C_NamePlate = C_NamePlate

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: NamePlateDriverFrame, UIParent, WorldFrame
-- GLOBALS: CUSTOM_CLASS_COLORS, ADDITIONAL_POWER_BAR_NAME

local function CopySettings(from, to)
	for setting, value in pairs(from) do
		if(type(value) == "table" and to[setting] ~= nil) then
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

function NP:StylePlate(nameplate)
	nameplate:SetPoint('CENTER')
	nameplate:SetSize(self.db.clickableWidth, self.db.clickableHeight)
	nameplate:SetScale(UIParent:GetEffectiveScale())

	nameplate.Health = NP:Construct_HealthBar(nameplate)
	nameplate.Health.Text = NP:Construct_TagText(nameplate)
	nameplate.Health.Text:SetPoint('CENTER', nameplate.Health, 'CENTER', 0, 0) -- need option
	nameplate:Tag(nameplate.Health.Text, '[perhp]%') -- need option

	nameplate.HealthPrediction = NP:Construct_HealthPrediction(nameplate)

	nameplate.Power = NP:Construct_PowerBar(nameplate)
	nameplate.Power.Text = NP:Construct_TagText(nameplate)
	nameplate.Power.Text:SetPoint('CENTER', nameplate.Power, 'CENTER', 0, 0) -- need option
	nameplate:Tag(nameplate.Power.Text, '[perpp]%') -- need option

	nameplate.PowerPrediction = NP:Construct_PowerPrediction(nameplate)

	nameplate.Name = NP:Construct_TagText(nameplate)
	nameplate.Name:SetPoint('BOTTOMLEFT', nameplate.Health, 'TOPLEFT', 0, E.Border*2) -- need option
	nameplate.Name:SetJustifyH('LEFT')
	nameplate.Name:SetJustifyV('BOTTOM')
	nameplate.Name:SetWordWrap(false)
	nameplate:Tag(nameplate.Name, '[namecolor][name:abbrev] [npctitle]')

	nameplate.Level = NP:Construct_TagText(nameplate)
	nameplate.Level:SetPoint('BOTTOMRIGHT', nameplate.Health, 'TOPRIGHT', 0, E.Border*2) -- need option
	nameplate.Level:SetJustifyH('RIGHT')
	nameplate:Tag(nameplate.Level, '[difficultycolor][level]')

	nameplate.ClassificationIndicator = NP:Construct_ClassificationIndicator(nameplate)
	nameplate.ClassificationIndicator:SetPoint('TOPLEFT', nameplate, 'TOPLEFT')

	nameplate.Castbar = NP:Construct_Castbar(nameplate)

	nameplate.QuestIcons = NP:Construct_QuestIcons(nameplate)

	nameplate.RaidTargetIndicator = NP:Construct_RaidTargetIndicator(nameplate)

	nameplate.TargetIndicator = NP:Construct_TargetIndicator(nameplate)

	nameplate.ThreatIndicator = NP:Construct_ThreatIndicator(nameplate)

	nameplate.Highlight = NP:Construct_Highlight(nameplate)

	--nameplate.Auras = NP:Construct_Auras(nameplate)

	nameplate.Buffs = NP:Construct_Buffs(nameplate)
	nameplate.Debuffs = NP:Construct_Debuffs(nameplate)

	nameplate.ClassPower = NP:Construct_ClassPower(nameplate)

	nameplate.PvPIndicator = NP:Construct_PvPIndicator(nameplate)

	if E.myclass == 'DEATHKNIGHT' then
		nameplate.Runes = NP:Construct_Runes(nameplate)
	end
end

function NP:UpdatePlate(nameplate)
	NP:Update_Auras(nameplate)

	NP:Update_Castbar(nameplate)

	NP:Update_ClassificationIndicator(nameplate)

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
	if (self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 1);
	elseif (self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 0);
	end

	if (self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 1);
	elseif (self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 0);
	end
end

function NP:PLAYER_REGEN_ENABLED()
	if (self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 0);
	elseif (self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 1);
	end

	if (self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 0);
	elseif (self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 1);
	end
end

function NP:ConfigureAll()
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
	SetCVar('showQuestTrackingTooltips', NP.db.questIcon and 1)
	SetCVar('nameplateMinAlpha', NP.db.nonTargetTransparency)
	SetCVar("nameplateOtherTopInset", NP.db.clampToScreen and 0.08 or -1)
	SetCVar("nameplateOtherBottomInset", NP.db.clampToScreen and 0.1 or -1)

	C_NamePlate.SetNamePlateSelfSize(NP.db.clickableWidth, NP.db.clickableHeight)
	C_NamePlate.SetNamePlateEnemySize(NP.db.clickableWidth, NP.db.clickableHeight)

	-- workaround for #206
	local friendlyWidth, friendlyHeight

	if IsInInstance() then
		-- handle it just like blizzard does when using blizzard friendly plates
		local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"))
		local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"))
		local zeroBasedScale = namePlateVerticalScale - 1.0

		friendlyWidth = NamePlateDriverFrame.baseNamePlateWidth * horizontalScale
		friendlyHeight = NamePlateDriverFrame.baseNamePlateHeight * Lerp(1.0, 1.25, zeroBasedScale)
	end

	C_NamePlate.SetNamePlateFriendlySize(friendlyWidth or NP.db.clickableWidth, friendlyHeight or NP.db.clickableHeight)

	if (self.db.showFriendlyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 0);
	elseif (self.db.showFriendlyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 1);
	end

	if (self.db.showEnemyCombat == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 0);
	elseif (self.db.showEnemyCombat == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 1);
	end

	if NP.db.units['PLAYER'].useStaticPosition then
		ElvNP_Player:Enable()
		ElvNP_Player:UpdateAllElements('OnShow')
	else
		ElvNP_Player:Disable()
	end

	NP:NamePlateCallBack(ElvNP_Player, 'NAME_PLATE_UNIT_ADDED')

	for nameplate in pairs(NP.Plates) do
		NP:NamePlateCallBack(nameplate, 'NAME_PLATE_UNIT_ADDED')
	end
end

function NP:NamePlateCallBack(nameplate, event, unit)
	if event == 'NAME_PLATE_UNIT_ADDED' then
		unit = unit or nameplate.unit
		local reaction = UnitReaction('player', unit)
		local faction = UnitFactionGroup(unit)

		if (UnitIsUnit(unit, 'player')) then
			nameplate.frameType = 'PLAYER'
		elseif (UnitIsPVPSanctuary(unit) or (UnitIsPlayer(unit) and UnitIsFriend('player', unit) and reaction and reaction >= 5)) then
			nameplate.frameType = 'FRIENDLY_PLAYER'
		elseif (not UnitIsPlayer(unit) and (reaction and reaction >= 5) or faction == 'Neutral') then
			nameplate.frameType = 'FRIENDLY_NPC'
		elseif (not UnitIsPlayer(unit) and (reaction and reaction <= 4)) then
			nameplate.frameType = 'ENEMY_NPC'
		else
			nameplate.frameType = 'ENEMY_PLAYER'
		end

		NP:UpdatePlate(nameplate)

		if NP.db.units['PLAYER'].useStaticPosition then
			NP:UpdatePlate(ElvNP_Player)
		end

		NP.Plates[nameplate] = true
	end
end

function NP:Initialize()
	self.db = E.db.nameplates

	if E.private.nameplates.enable ~= true then return end

	ElvUF:RegisterStyle('ElvNP', function(frame, unit)
		NP:Style(frame, unit)
	end)
	ElvUF:SetActiveStyle('ElvNP')

	NP.Plates = {}
	NP.StatusBars = {}

	local BlizzPlateManaBar = NamePlateDriverFrame.classNamePlatePowerBar
	if BlizzPlateManaBar then
		BlizzPlateManaBar:Hide()
		BlizzPlateManaBar:UnregisterAllEvents()
	end

	hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
		if frame.classNamePlateMechanicFrame then
			frame.classNamePlateMechanicFrame:Hide()
		end
		if frame.classNamePlatePowerBar then
			frame.classNamePlatePowerBar:Hide()
			frame.classNamePlatePowerBar:UnregisterAllEvents()
		end
	end)

	self.Tooltip = CreateFrame('GameTooltip', "ElvUIQuestTooltip", nil, 'GameTooltipTemplate')
	self.Tooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')

	ElvUF:Spawn('player', 'ElvNP_Player')
	ElvNP_Player:SetAttribute("unit", "player")
	ElvNP_Player:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	ElvNP_Player:SetAttribute("*type1", "target")
	ElvNP_Player:SetAttribute("*type2", "togglemenu")
	ElvNP_Player:SetAttribute("toggleForVehicle", true)
	ElvNP_Player:SetPoint("TOP", UIParent, "CENTER", 0, -150)
	ElvNP_Player:SetSize(NP.db.clickableWidth, NP.db.clickableHeight)
	ElvNP_Player:SetScale(1)
	ElvNP_Player:SetScript('OnEnter', UnitFrame_OnEnter)
	ElvNP_Player:SetScript('OnLeave', UnitFrame_OnLeave)
	ElvNP_Player.frameType = 'PLAYER'

	if not NP.db.units['PLAYER'].useStaticPosition then
		ElvNP_Player:Disable()
	end

	E:CreateMover(ElvNP_Player, 'ElvNP_PlayerMover', L["Player NamePlate"], nil, nil, nil, 'ALL,SOLO', nil, 'player,generalGroup')

	ElvUF:SpawnNamePlates('ElvNP_', function(nameplate, event, unit)
		NP:NamePlateCallBack(nameplate, event, unit)
	end)

	NP:RegisterEvent('PLAYER_REGEN_ENABLED')
	NP:RegisterEvent('PLAYER_REGEN_DISABLED')

	NP:ConfigureAll()

	E.NamePlates = self
end

local function InitializeCallback()
	NP:Initialize()
end

E:RegisterModule(NP:GetName(), InitializeCallback)
