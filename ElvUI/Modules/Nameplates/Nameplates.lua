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
	Health.Value:SetPoint('CENTER', Health, 'CENTER', 0, 0)
	nameplate:Tag(Health.Value, '[perhp]%')

	Health.PostUpdate = function(bar, _, min, max)
		bar.Value:SetTextColor(bar.__owner:ColorGradient(min, max, .69, .31, .31, .65, .63, .35, .33, .59, .33))

		if (min ~= max) then
			bar:SetStatusBarColor(bar.__owner:ColorGradient(min, max, 1, .1, .1, .6, .3, .3, .2, .2, .2))
		else
			bar:SetStatusBarColor(0.2, 0.2, 0.2, 1)
		end
	end

	Health.frequentUpdates = true
	Health.colorTapping = false
	Health.colorDisconnected = false
	Health.colorClass = false

	Health:SetStatusBarColor(0.2, 0.2, 0.2, 1)

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
	CastBar:SetHeight(16)
	CastBar:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, -20)
	CastBar:SetPoint('TOPRIGHT', Health, 'BOTTOMRIGHT', 0, -20)

	CastBar.Button = CreateFrame('Frame', nil, CastBar)
	CastBar.Button:SetSize(18, 18)
	CastBar.Button:SetTemplate()
	--CastBar.Button:CreateShadow()
	CastBar.Button:SetPoint('RIGHT', CastBar, 'LEFT', -6, 0)

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
	CastBar.Text:SetPoint('LEFT', CastBar, 'LEFT', 4, 0)
	CastBar.Text:SetTextColor(0.84, 0.75, 0.65)
	CastBar.Text:SetJustifyH('LEFT')
	CastBar.Text:SetSize(75, 16)

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
	Power:SetSize(130, 4)
	Power:CreateBackdrop('Transparent')
	--Power.backdrop:CreateShadow()
	Power:SetPoint('TOP', Health, 'TOP', 0, -14)
	Power:SetStatusBarTexture(Texture)

	Power.Value = Power:CreateFontString(nil, 'OVERLAY')
	Power.Value:SetFont(Font, FontSize, FontFlag)
	Power.Value:SetPoint('CENTER', Power, 'CENTER', 0, 0)
	nameplate:Tag(Power.Value, '[perpp]%')

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
	AdditionalPower:SetSize(130, 4)
	AdditionalPower:CreateBackdrop('Transparent')
	--AdditionalPower.backdrop:CreateShadow()
	AdditionalPower:SetPoint('TOP', Power, 'BOTTOM', 0, -2)
	AdditionalPower:SetStatusBarTexture(Texture)

	AdditionalPower.Value = AdditionalPower:CreateFontString(nil, 'OVERLAY')
	AdditionalPower.Value:SetFont(Font, FontSize, FontFlag)
	AdditionalPower.Value:SetPoint('LEFT', AdditionalPower, 'RIGHT', 20, 0)
	nameplate:Tag(AdditionalPower.Value, '[curmana]')

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
	PowerBar:SetPoint('TOP')
	PowerBar:SetPoint('BOTTOM')
	PowerBar:SetPoint('RIGHT', Power:GetStatusBarTexture(), 'RIGHT')
	PowerBar:SetWidth(130)
	PowerBar:SetStatusBarTexture(Texture)

	local AltPowerBar = CreateFrame('StatusBar', nil, AdditionalPower)
	AltPowerBar:SetReverseFill(true)
	AltPowerBar:SetPoint('TOP')
	AltPowerBar:SetPoint('BOTTOM')
	AltPowerBar:SetPoint('RIGHT', AdditionalPower:GetStatusBarTexture(), 'RIGHT')
	AltPowerBar:SetWidth(130)
	AltPowerBar:SetStatusBarTexture(Texture)

	nameplate.PowerPrediction = {
		mainBar = PowerBar,
		altBar = AltPowerBar
	}

	Name:ClearAllPoints()
	Name:SetPoint('BOTTOMLEFT', Health, 'TOPLEFT', 0, E.Border*2)
	Name:SetJustifyH('LEFT')
	Name:SetJustifyV('BOTTOM')
	Name:SetFont(Font, FontSize, FontFlag)
	Name:SetWordWrap(false)

	Level:ClearAllPoints()
	Level:SetPoint('LEFT', Name, 'RIGHT', 0, 0)
	Level:SetJustifyH('RIGHT')
	Level:SetFont(Font, FontSize, FontFlag)

	Info:ClearAllPoints()
	Info:SetPoint('TOP', Power, 'BOTTOM', 0, -5)
	Info:SetJustifyH('LEFT')
	Info:SetFont(Font, FontSize, FontFlag)

	RaidIcon:ClearAllPoints()
	RaidIcon:SetPoint('TOP', Health, 0, 8)
	RaidIcon:SetSize(16, 16)

	QuestIcon:Hide()
	QuestIcon:SetSize(24, 24)
	QuestIcon:ClearAllPoints()
	QuestIcon:SetPoint('CENTER', Name, 'CENTER', 0, 20)
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

		local index = GetRaidTargetIndex(ele.unit)
		if (index) and not UnitIsUnit(ele.unit, 'player') then
			SetRaidTargetIconTexture(element, index)
			element:Show()
		else
			element:Hide()
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

	nameplate.Health.colorTapping = false
	nameplate.Health.colorDisconnected = false
	nameplate.Health.colorClass = self.db.units.PLAYER.healthbar.useClassColor

	nameplate.Health:SetSize(self.db.units.PLAYER.healthbar.width, self.db.units.PLAYER.healthbar.height)
end

function NP:FriendlyStyle(nameplate, event, unit)
	-- self.db.units.FRIENDLY_PLAYER
	nameplate.Health:SetSize(self.db.units.FRIENDLY_PLAYER.healthbar.width, self.db.units.FRIENDLY_PLAYER.healthbar.height)
end

function NP:EnemyStyle(nameplate, event, unit)
	-- self.db.units.ENEMY_PLAYER
	nameplate.Health:SetSize(self.db.units.ENEMY_PLAYER.healthbar.width, self.db.units.ENEMY_PLAYER.healthbar.height)
end

function NP:FriendlyNPCStyle(nameplate, event, unit)
	-- self.db.units.FRIENDLY_NPC
	nameplate.Health:SetSize(self.db.units.FRIENDLY_NPC.healthbar.width, self.db.units.FRIENDLY_NPC.healthbar.height)
end

function NP:EnemyNPCStyle(nameplate, event, unit)
	-- self.db.units.ENEMY_NPC
	nameplate.Health:SetSize(self.db.units.ENEMY_NPC.healthbar.width, self.db.units.ENEMY_NPC.healthbar.height)
end

function NP:CVarReset()
	for cvar, value in next, NP.CVars do
		SetCVar(cvar, value)
	end
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

	NP.CVars = {
		['nameplateGlobalScale'] = 1,
		['namePlateHorizontalScale'] = 1,
		['nameplateLargerScale'] = 1,
		['nameplateMaxDistance'] =NP.db.loadDistance,
		['nameplateMaxScale'] = 1,
		['nameplateMinScale'] = 1,
		['nameplateMotion'] = NP.db.motionType == 'STACKED' and 1 or 0,
		['nameplateOtherAtBase'] = 0,
		['nameplateOtherBottomInset'] = NP.db.clampToScreen and 0.1 or -1,
		['nameplateOtherTopInset'] = NP.db.clampToScreen and 0.08 or -1,
		['nameplateOverlapH'] = GetCVarDefault('nameplateOverlapH'),
		['nameplateOverlapV'] = GetCVarDefault('nameplateOverlapV'),
		['nameplatePersonalHideDelaySeconds'] = NP.db.units.PLAYER.visibility.hideDelay,
		['nameplatePersonalShowAlways'] = (NP.db.units.PLAYER.visibility.showAlways == true and 1 or 0),
		['nameplatePersonalShowInCombat'] = (NP.db.units.PLAYER.visibility.showInCombat == true and 1 or 0),
		['nameplatePersonalShowWithTarget'] = (NP.db.units.PLAYER.visibility.showWithTarget == true and 1 or 0),
		['nameplateResourceOnTarget'] = 0,
		['nameplateSelectedScale'] = 1,
		['nameplateSelfAlpha'] = 1,
		['nameplateSelfScale'] = 1,
		['nameplateShowAll'] = NP.db.displayStyle ~= 'ALL' and 0 or 1,
		['nameplateShowDebuffsOnFriendly'] = 0,
		['nameplateShowFriendlyMinions'] = NP.db.units.FRIENDLY_PLAYER.minions == true and 1 or 0,
		['nameplateShowEnemyMinions'] = NP.db.units.ENEMY_PLAYER.minions == true and 1 or 0,
		['nameplateShowEnemyMinus'] = NP.db.units.ENEMY_NPC.minors == true and 1 or 0,
		['nameplateShowFriendlyNPCs'] = 1,
		['nameplateShowSelf'] = (NP.db.units.PLAYER.useStaticPosition == true or NP.db.units.PLAYER.enable ~= true) and 0 or 1,
		['namePlateVerticalScale'] = 1,
		['showQuestTrackingTooltips'] = NP.db.questIcon and 1,
	}

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

	ElvUF:SpawnNamePlates('ElvUF_', NP.NamePlateCallBack, NP.CVars)

	E.NamePlates = self
end

local function InitializeCallback()
	NP:Initialize()
end

E:RegisterModule(NP:GetName(), InitializeCallback)
