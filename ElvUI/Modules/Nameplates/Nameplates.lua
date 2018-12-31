local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUF = ElvUI.oUF

local NP = E:NewModule('NamePlates', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local LSM = LibStub('LibSharedMedia-3.0')

--Cache global variables
--Lua functions
local pairs = pairs
local type = type
local gsub = gsub
local twipe = table.wipe
local format = string.format
local match = string.match
local strjoin = strjoin
local tonumber = tonumber

--WoW API / Variables
local CreateFrame = CreateFrame
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction
local SetCVar, GetCVarDefault = SetCVar, GetCVarDefault

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: NamePlateDriverFrame, UIParent, WorldFrame
-- GLOBALS: CUSTOM_CLASS_COLORS

function NP:Style(frame, unit)
	if (not unit) then
		return
	end

	if unit:match('nameplate') then
		NP:StylePlate(frame, unit)
	else
		E:GetModule('UnitFrames'):Construct_UF(frame, unit)
	end

	return frame
end

function NP:StylePlate(nameplate, realUnit)
	local Texture = LSM:Fetch('statusbar', self.db.statusbar)
	local Font, FontSize, FontFlag = LSM:Fetch('font', self.db.font), self.db.fontSize, self.db.fontOutline

	local Health = CreateFrame('StatusBar', nil, nameplate)
	local Power = CreateFrame('StatusBar', nil, nameplate)
	local AdditionalPower = CreateFrame('StatusBar', nil, nameplate)
	local CastBar = CreateFrame('StatusBar', nil, nameplate)

	local Name = nameplate:CreateFontString(nil, 'OVERLAY')
	local Level = nameplate:CreateFontString(nil, 'OVERLAY')
	local Info = nameplate:CreateFontString(nil, 'OVERLAY')
	local RaidIcon = nameplate:CreateTexture(nil, 'OVERLAY')
	local QuestIcon = nameplate:CreateTexture(nil, 'OVERLAY', 2)

	nameplate:SetPoint('CENTER')
	nameplate:SetSize(self.db.clickableWidth, self.db.clickableHeight)
	nameplate:SetScale(UIParent:GetEffectiveScale())

	Health:SetFrameStrata(nameplate:GetFrameStrata())
	Health:SetFrameLevel(4)
	Health:SetPoint('CENTER')
	Health:CreateBackdrop('Transparent')
	--Health.backdrop:CreateShadow()
	Health:SetStatusBarTexture(Texture)

	Health.Value = Health:CreateFontString(nil, 'OVERLAY')
	Health.Value:SetFont(LSM:Fetch('font', self.db.healthFont), self.db.healthFontSize, self.db.healthFontOutline)
	Health.Value:SetPoint('CENTER', Health, 'CENTER', 0, 0) -- need option
	nameplate:Tag(Health.Value, '[perhp]%') -- need option

	--Health.PostUpdate = function(bar, _, min, max)
	--	bar.Value:SetTextColor(bar.__owner:ColorGradient(min, max, .69, .31, .31, .65, .63, .35, .33, .59, .33))

	--	if (min ~= max) then
	--		bar:SetStatusBarColor(bar.__owner:ColorGradient(min, max, 1, .1, .1, .6, .3, .3, .2, .2, .2))
	--	else
	--		bar:SetStatusBarColor(0.2, 0.2, 0.2, 1)
	--	end
	--end

	--Health:SetStatusBarColor(0.2, 0.2, 0.2, 1) -- need option

	Health:SetStatusBarColor(0.29, 0.69, 0.3, 1) -- need option

	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = false

	Health.Smooth = true

	local HealthPrediction = {}

	for _, Bar in pairs({ 'myBar', 'otherBar', 'absorbBar', 'healAbsorbBar' }) do
		HealthPrediction[Bar] = CreateFrame('StatusBar', nil, Health)
		HealthPrediction[Bar]:SetStatusBarTexture(Texture)
		HealthPrediction[Bar]:SetPoint('TOP')
		HealthPrediction[Bar]:SetPoint('BOTTOM')
		HealthPrediction[Bar]:SetWidth(150)
	end

	HealthPrediction.myBar:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.myBar:SetFrameLevel(Health:GetFrameLevel() + 2)
	HealthPrediction.myBar:SetStatusBarColor(0, 0.3, 0.15, 1)
	HealthPrediction.myBar:SetMinMaxValues(0,1)

	HealthPrediction.otherBar:SetPoint('LEFT', HealthPrediction.myBar:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.otherBar:SetFrameLevel(Health:GetFrameLevel() + 1)
	HealthPrediction.otherBar:SetStatusBarColor(0, 0.3, 0, 1)

	HealthPrediction.absorbBar:SetPoint('LEFT', HealthPrediction.otherBar:GetStatusBarTexture(), 'RIGHT')
	HealthPrediction.absorbBar:SetFrameLevel(Health:GetFrameLevel())
	HealthPrediction.absorbBar:SetStatusBarColor(0.3, 0.3, 0, 1)

	HealthPrediction.healAbsorbBar:SetPoint('RIGHT', Health:GetStatusBarTexture())
	HealthPrediction.healAbsorbBar:SetFrameLevel(Health:GetFrameLevel() + 3)
	HealthPrediction.healAbsorbBar:SetStatusBarColor(1, 0.3, 0.3, 1)
	HealthPrediction.healAbsorbBar:SetReverseFill(true)

	HealthPrediction.maxOverflow = 1
	HealthPrediction.frequentUpdates = true

	nameplate.HealthPrediction = HealthPrediction

	CastBar:SetFrameStrata(nameplate:GetFrameStrata())
	CastBar:SetStatusBarTexture(Texture)
	CastBar:SetFrameLevel(6)
	CastBar:CreateBackdrop('Transparent')
	--CastBar.backdrop:CreateShadow()
	CastBar:SetHeight(16) -- need option
	CastBar:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, -20) -- need option
	CastBar:SetPoint('TOPRIGHT', Health, 'BOTTOMRIGHT', 0, -20) -- need option

	CastBar.Button = CreateFrame('Frame', nil, CastBar)
	CastBar.Button:SetSize(18, 18) -- need option
	CastBar.Button:SetTemplate()
	--CastBar.Button:CreateShadow()
	CastBar.Button:SetPoint('RIGHT', CastBar, 'LEFT', -6, 0) -- need option

	CastBar.Icon = CastBar.Button:CreateTexture(nil, 'ARTWORK')
	CastBar.Icon:SetInside()
	CastBar.Icon:SetTexCoord(unpack({.08, .92, .08, .92}))

	CastBar.Time = CastBar:CreateFontString(nil, 'OVERLAY')
	CastBar.Time:SetFont(Font, FontSize, FontFlag)
	CastBar.Time:SetPoint('RIGHT', CastBar, 'RIGHT', -4, 0)
	CastBar.Time:SetTextColor(0.84, 0.75, 0.65)
	CastBar.Time:SetJustifyH('RIGHT')

	CastBar.Text = CastBar:CreateFontString(nil, 'OVERLAY')
	CastBar.Text:SetFont(Font, FontSize, FontFlag)
	CastBar.Text:SetPoint('LEFT', CastBar, 'LEFT', 4, 0) -- need option
	CastBar.Text:SetTextColor(0.84, 0.75, 0.65)
	CastBar.Text:SetJustifyH('LEFT')
	CastBar.Text:SetSize(75, 16) -- need option

	local function CheckInterrupt(castbar, unit)
		if (unit == 'vehicle') then
			unit = 'player'
		end

		if (castbar.notInterruptible and UnitCanAttack('player', unit)) then
			castbar:SetStatusBarColor(0.87, 0.37, 0.37, 0.7)
		else
			castbar:SetStatusBarColor(0.29, 0.67, 0.30, 0.7)
		end
	end

	CastBar.PostCastStart = CheckInterrupt
	CastBar.PostCastInterruptible = CheckInterrupt
	CastBar.PostCastNotInterruptible = CheckInterrupt
	CastBar.PostChannelStart = CheckInterrupt

	Power:SetFrameStrata(nameplate:GetFrameStrata())
	Power:SetFrameLevel(2)
	Power:CreateBackdrop('Transparent')
	--Power.backdrop:CreateShadow()
	Power:SetPoint('TOP', Health, 'TOP', 0, -14)
	Power:SetStatusBarTexture(Texture)

	Power.Value = Power:CreateFontString(nil, 'OVERLAY')
	Power.Value:SetFont(Font, FontSize, FontFlag)
	Power.Value:SetPoint('CENTER', Power, 'CENTER', 0, 0) -- need option
	nameplate:Tag(Power.Value, '[perpp]%') -- need option

	Power.frequentUpdates = true
	Power.colorTapping = true
	Power.colorClass = true
	Power.Smooth = true
	Power.displayAltPower = true

	Power.PreUpdate = function(power, unit)
		local _, pToken = UnitPowerType(unit)
		local Color = ElvUF.colors.power[pToken]

		if Color then
			power:SetStatusBarColor(Color[1], Color[2], Color[3])
			power.Value:SetTextColor(Color[1], Color[2], Color[3])
		end

		power.Value:UpdateTag()
	end

	Power.PostUpdate = function(power, unit, _, _, max)
		if max == 0 then
			power:Hide()
		else
			power:Show()
		end
		power:PreUpdate(unit)
	end

	AdditionalPower:Hide()
	AdditionalPower:SetFrameStrata(nameplate:GetFrameStrata())
	AdditionalPower:SetFrameLevel(2)
	AdditionalPower:SetSize(130, 4) -- need option
	AdditionalPower:CreateBackdrop('Transparent')
	--AdditionalPower.backdrop:CreateShadow()
	AdditionalPower:SetPoint('TOP', Power, 'BOTTOM', 0, -2) -- need option
	AdditionalPower:SetStatusBarTexture(Texture)

	AdditionalPower.Value = AdditionalPower:CreateFontString(nil, 'OVERLAY')
	AdditionalPower.Value:SetFont(Font, FontSize, FontFlag)
	AdditionalPower.Value:SetPoint('CENTER', AdditionalPower, 'CENTER', 0, 0) -- need option
	nameplate:Tag(AdditionalPower.Value, '[curmana]') -- need option

	AdditionalPower.colorPower = true
	AdditionalPower.PreUpdate = function(bar)
		local Color = ElvUF.colors.power[ADDITIONAL_POWER_BAR_NAME]

		if Color then
			bar.Value:SetTextColor(Color[1], Color[2], Color[3])
		end

		bar.Value:UpdateTag()
	end

	AdditionalPower.PostUpdate = AdditionalPower.PostUpdate

	nameplate.AdditionalPower = AdditionalPower

	local PowerBar = CreateFrame('StatusBar', nil, Power)
	PowerBar:SetReverseFill(true)
	PowerBar:SetPoint('TOP') -- need option
	PowerBar:SetPoint('BOTTOM')
	PowerBar:SetPoint('RIGHT', Power:GetStatusBarTexture(), 'RIGHT')
	PowerBar:SetWidth(130) -- need option
	PowerBar:SetStatusBarTexture(Texture)

	local AltPowerBar = CreateFrame('StatusBar', nil, AdditionalPower)
	AltPowerBar:SetReverseFill(true)
	AltPowerBar:SetPoint('TOP') -- need option
	AltPowerBar:SetPoint('BOTTOM')
	AltPowerBar:SetPoint('RIGHT', AdditionalPower:GetStatusBarTexture(), 'RIGHT')
	AltPowerBar:SetWidth(130) -- need option
	AltPowerBar:SetStatusBarTexture(Texture)

	nameplate.PowerPrediction = {
		mainBar = PowerBar,
		altBar = AltPowerBar
	}

	Name:SetPoint('BOTTOMLEFT', Health, 'TOPLEFT', 0, E.Border*2) -- need option
	Name:SetJustifyH('LEFT')
	Name:SetJustifyV('BOTTOM')
	Name:SetFont(Font, FontSize, FontFlag)
	Name:SetWordWrap(false)

	Level:SetPoint('LEFT', Name, 'RIGHT', 0, 0) -- need option
	Level:SetJustifyH('RIGHT')
	Level:SetFont(Font, FontSize, FontFlag)

	Info:SetPoint('TOP', Power, 'BOTTOM', 0, -5) -- need option
	Info:SetJustifyH('LEFT')
	Info:SetFont(Font, FontSize, FontFlag)

	RaidIcon:SetPoint('TOP', Health, 0, 8) -- need option
	RaidIcon:SetSize(16, 16)

	QuestIcon:Hide()
	QuestIcon:SetSize(24, 24) -- need option
	QuestIcon:SetPoint('CENTER', Name, 'CENTER', 0, 20) -- need option
	QuestIcon:SetTexture('Interface\\MINIMAP\\ObjectIcons')
	QuestIcon:SetTexCoord(0.125, 0.250, 0.125, 0.250)

	nameplate:Tag(Name, '[namecolor][name] [npctitle]')
	nameplate:Tag(Level, '[difficultycolor][level]')
	nameplate:Tag(Info, '[quest:info]')

	--local PvP = Health:CreateTexture(nil, 'OVERLAY')
	--PvP:Size(36, 36)
	--PvP:Point('CENTER', Health)

	local RaidTargetIndicator = Health:CreateTexture(nil, 'OVERLAY', 7)
	RaidTargetIndicator:SetSize(24, 24)
	RaidTargetIndicator:Point('BOTTOM', Health, 'TOP', 0, 24)
	RaidTargetIndicator.Override = function(ele, event)
		local element = ele.RaidTargetIndicator

		if ele.unit then
			local index = GetRaidTargetIndex(ele.unit)
			if (index) and not UnitIsUnit(ele.unit, 'player') then
				SetRaidTargetIconTexture(element, index)
				element:Show()
			else
				element:Hide()
			end
		end
	end

	local ThreatIndicator = Health:CreateTexture(nil, 'OVERLAY')
	ThreatIndicator:SetSize(16, 16)
	ThreatIndicator:SetPoint('CENTER', Health, 'TOPRIGHT')
	ThreatIndicator.feedbackUnit = 'player'

	local ClassificationIndicator = Health:CreateTexture(nil, 'OVERLAY')
	ClassificationIndicator:SetSize(16, 16)
	ClassificationIndicator:SetPoint('RIGHT', Health, 'LEFT')

	nameplate.Health = Health
	nameplate.Power = Power
	nameplate.Castbar = CastBar

	nameplate.Name = Name
	nameplate.Level = Level
	nameplate.Info = Info

	nameplate.QuestIndicator = QuestIcon
	nameplate.RaidTargetIndicator = RaidTargetIndicator
	--nameplate.PvPIndicator = PvP

	nameplate.ThreatIndicator = ThreatIndicator
	nameplate.ClassificationIndicator = ClassificationIndicator
end

function NP:PersonalStyle(nameplate, event, unit)
	-- self.db.units.PLAYER
	-- ['glowStyle'] = 'TARGET_THREAT',

	if self.db.units.PLAYER.healthbar.enable then
		nameplate:EnableElement('Health')
	else
		nameplate:DisableElement('Health')
	end

	if self.db.units.PLAYER.healthbar.enable and self.db.units.PLAYER.healthbar.healPrediction then
		nameplate:EnableElement('HealPrediction')
	else
		nameplate:DisableElement('HealPrediction')
	end

	if self.db.units.PLAYER.healthbar.text.enable then
		nameplate.Health.Value:Show()
	else
		nameplate.Health.Value:Hide()
	end

	nameplate.Health.colorClass = self.db.units.PLAYER.healthbar.useClassColor

	nameplate.Health:SetSize(self.db.units.PLAYER.healthbar.width, self.db.units.PLAYER.healthbar.height)

	if self.db.units.PLAYER.powerbar.enable then
		nameplate:EnableElement('Power')
	else
		nameplate:DisableElement('Power')
	end

	if self.db.units.PLAYER.powerbar.enable and self.db.units.PLAYER.powerbar.costPrediction then
		nameplate:EnableElement('PowerPrediction')
	else
		nameplate:DisableElement('PowerPrediction')
	end

	if self.db.units.PLAYER.powerbar.text.enable then
		nameplate.Power.Value:Show()
	else
		nameplate.Power.Value:Hide()
	end

	nameplate.Power:SetSize(self.db.units.PLAYER.healthbar.width, self.db.units.PLAYER.powerbar.height)
end

function NP:FriendlyStyle(nameplate, event, unit)
	-- self.db.units.FRIENDLY_PLAYER

	if self.db.units.FRIENDLY_PLAYER.healthbar.enable then
		nameplate:EnableElement('Health')
	else
		nameplate:DisableElement('Health')
	end

	if self.db.units.FRIENDLY_PLAYER.healthbar.enable and self.db.units.FRIENDLY_PLAYER.healthbar.healPrediction then
		nameplate:EnableElement('HealPrediction')
	else
		nameplate:DisableElement('HealPrediction')
	end

	if self.db.units.FRIENDLY_PLAYER.healthbar.text.enable then
		nameplate.Health.Value:Show()
	else
		nameplate.Health.Value:Hide()
	end

	nameplate.Health.colorClass = self.db.units.FRIENDLY_PLAYER.healthbar.useClassColor

	nameplate.Health:SetSize(self.db.units.FRIENDLY_PLAYER.healthbar.width, self.db.units.FRIENDLY_PLAYER.healthbar.height)

	if self.db.units.FRIENDLY_PLAYER.powerbar.enable then
		nameplate:EnableElement('Power')
	else
		nameplate:DisableElement('Power')
	end

	if self.db.units.FRIENDLY_PLAYER.powerbar.enable and self.db.units.FRIENDLY_PLAYER.powerbar.costPrediction then
		nameplate:EnableElement('PowerPrediction')
	else
		nameplate:DisableElement('PowerPrediction')
	end

	if self.db.units.FRIENDLY_PLAYER.powerbar.text.enable then
		nameplate.Power.Value:Show()
	else
		nameplate.Power.Value:Hide()
	end

	nameplate.Power:SetSize(self.db.units.FRIENDLY_PLAYER.healthbar.width, self.db.units.FRIENDLY_PLAYER.powerbar.height)
end

function NP:EnemyStyle(nameplate, event, unit)
	-- self.db.units.ENEMY_PLAYER
	if self.db.units.ENEMY_PLAYER.healthbar.enable then
		nameplate:EnableElement('Health')
	else
		nameplate:DisableElement('Health')
	end

	if self.db.units.ENEMY_PLAYER.healthbar.enable and self.db.units.ENEMY_PLAYER.healthbar.healPrediction then
		nameplate:EnableElement('HealPrediction')
	else
		nameplate:DisableElement('HealPrediction')
	end

	if self.db.units.ENEMY_PLAYER.healthbar.text.enable then
		nameplate.Health.Value:Show()
	else
		nameplate.Health.Value:Hide()
	end

	nameplate.Health.colorClass = self.db.units.ENEMY_PLAYER.healthbar.useClassColor

	nameplate.Health:SetSize(self.db.units.ENEMY_PLAYER.healthbar.width, self.db.units.ENEMY_PLAYER.healthbar.height)

	if self.db.units.ENEMY_PLAYER.powerbar.enable then
		nameplate:EnableElement('Power')
	else
		nameplate:DisableElement('Power')
	end

	if self.db.units.ENEMY_PLAYER.powerbar.enable and self.db.units.ENEMY_PLAYER.powerbar.costPrediction then
		nameplate:EnableElement('PowerPrediction')
	else
		nameplate:DisableElement('PowerPrediction')
	end

	if self.db.units.ENEMY_PLAYER.powerbar.text.enable then
		nameplate.Power.Value:Show()
	else
		nameplate.Power.Value:Hide()
	end

	nameplate.Power:SetSize(self.db.units.ENEMY_PLAYER.healthbar.width, self.db.units.ENEMY_PLAYER.powerbar.height)end

function NP:FriendlyNPCStyle(nameplate, event, unit)
	-- self.db.units.FRIENDLY_NPC
	if self.db.units.FRIENDLY_NPC.healthbar.enable then
		nameplate:EnableElement('Health')
	else
		nameplate:DisableElement('Health')
	end

	if self.db.units.FRIENDLY_NPC.healthbar.enable and self.db.units.FRIENDLY_NPC.healthbar.healPrediction then
		nameplate:EnableElement('HealPrediction')
	else
		nameplate:DisableElement('HealPrediction')
	end

	if self.db.units.FRIENDLY_NPC.healthbar.text.enable then
		nameplate.Health.Value:Show()
	else
		nameplate.Health.Value:Hide()
	end

	nameplate.Health.colorClass = self.db.units.FRIENDLY_NPC.healthbar.useClassColor

	nameplate.Health:SetSize(self.db.units.FRIENDLY_NPC.healthbar.width, self.db.units.FRIENDLY_NPC.healthbar.height)

	if self.db.units.FRIENDLY_NPC.powerbar.enable then
		nameplate:EnableElement('Power')
	else
		nameplate:DisableElement('Power')
	end

	if self.db.units.FRIENDLY_NPC.powerbar.enable and self.db.units.FRIENDLY_NPC.powerbar.costPrediction then
		nameplate:EnableElement('PowerPrediction')
	else
		nameplate:DisableElement('PowerPrediction')
	end

	if self.db.units.FRIENDLY_NPC.powerbar.text.enable then
		nameplate.Power.Value:Show()
	else
		nameplate.Power.Value:Hide()
	end

	nameplate.Power:SetSize(self.db.units.FRIENDLY_NPC.healthbar.width, self.db.units.FRIENDLY_NPC.powerbar.height)end

function NP:EnemyNPCStyle(nameplate, event, unit)
	-- self.db.units.ENEMY_NPC
	if self.db.units.ENEMY_NPC.healthbar.enable then
		nameplate:EnableElement('Health')
	else
		nameplate:DisableElement('Health')
	end

	if self.db.units.ENEMY_NPC.healthbar.enable and self.db.units.ENEMY_NPC.healthbar.healPrediction then
		nameplate:EnableElement('HealPrediction')
	else
		nameplate:DisableElement('HealPrediction')
	end

	if self.db.units.ENEMY_NPC.healthbar.text.enable then
		nameplate.Health.Value:Show()
	else
		nameplate.Health.Value:Hide()
	end

	nameplate.Health.colorClass = self.db.units.ENEMY_NPC.healthbar.useClassColor

	nameplate.Health:SetSize(self.db.units.ENEMY_NPC.healthbar.width, self.db.units.ENEMY_NPC.healthbar.height)

	if self.db.units.ENEMY_NPC.powerbar.enable then
		nameplate:EnableElement('Power')
	else
		nameplate:DisableElement('Power')
	end

	if self.db.units.ENEMY_NPC.powerbar.enable and self.db.units.ENEMY_NPC.powerbar.costPrediction then
		nameplate:EnableElement('PowerPrediction')
	else
		nameplate:DisableElement('PowerPrediction')
	end

	if self.db.units.ENEMY_NPC.powerbar.text.enable then
		nameplate.Power.Value:Show()
	else
		nameplate.Power.Value:Hide()
	end

	nameplate.Power:SetSize(self.db.units.ENEMY_NPC.healthbar.width, self.db.units.ENEMY_NPC.powerbar.height)
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
	SetCVar('nameplateMinAlpha', GetCVarDefault('nameplateMinAlpha'))
	SetCVar('nameplateMinAlphaDistance', GetCVarDefault('nameplateMinAlphaDistance'))
	SetCVar('nameplateMinScale', GetCVarDefault('nameplateMinScale'))
	SetCVar('nameplateMinScaleDistance', GetCVarDefault('nameplateMinScaleDistance'))
	SetCVar('nameplateMotionSpeed', GetCVarDefault('nameplateMotionSpeed'))
	SetCVar('nameplateOtherAtBase', GetCVarDefault('nameplateOtherAtBase'))
	SetCVar('nameplateOtherBottomInset', GetCVarDefault('nameplateOtherBottomInset'))
	SetCVar('nameplateOtherTopInset', GetCVarDefault('nameplateOtherTopInset'))
	SetCVar('nameplateOverlapH', GetCVarDefault('nameplateOverlapH'))
	SetCVar('nameplateOverlapV', GetCVarDefault('nameplateOverlapV'))
	SetCVar('nameplateResourceOnTarget', GetCVarDefault('nameplateResourceOnTarget'))
	SetCVar('nameplateSelectedAlpha', GetCVarDefault('nameplateSelectedAlpha'))
	SetCVar('nameplateSelectedScale', GetCVarDefault('nameplateSelectedScale'))
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

	--if self.db.units.PLAYER.useStaticPosition then
	--	self:UpdateVisibility()
	--end
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

	--if self.db.units.PLAYER.useStaticPosition then
	--	self:UpdateVisibility()
	--end
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

	for nameplate in pairs(NP.Plates) do
		NP.NamePlateCallBack(nameplate)
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

	function NP.NamePlateCallBack(nameplate, event, unit)
		if nameplate then
			unit = unit or nameplate.unit
			local reaction = UnitReaction('player', unit)
			local faction = UnitFactionGroup(unit)

			if (UnitIsUnit(unit, 'player')) then
				NP:PersonalStyle(nameplate, event, unit)
			elseif (UnitIsPVPSanctuary(unit) or (UnitIsPlayer(unit) and UnitIsFriend('player', unit) and reaction and reaction >= 5)) then
				NP:FriendlyStyle(nameplate, event, unit)
			elseif (not UnitIsPlayer(unit) and (reaction and reaction >= 5) or faction == 'Neutral') then
				NP:FriendlyNPCStyle(nameplate, event, unit)
			elseif (not UnitIsPlayer(unit) and (reaction and reaction <= 4)) then
				NP:EnemyNPCStyle(nameplate, event, unit)
			else
				NP:EnemyStyle(nameplate, event, unit)
			end
		end

		if event == 'NAME_PLATE_UNIT_ADDED' then
			NP.Plates[nameplate] = true
		end
	end

	ElvUF:SpawnNamePlates('ElvUF_', NP.NamePlateCallBack)

	E.NamePlates = self
end

local function InitializeCallback()
	NP:Initialize()
end

E:RegisterModule(NP:GetName(), InitializeCallback)
