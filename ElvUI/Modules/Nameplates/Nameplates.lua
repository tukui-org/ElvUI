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

function NP:StylePlate(frame, realUnit)
	local HealthTexture = LSM:Fetch('statusbar', self.db.statusbar)
	local PowerTexture = LSM:Fetch('statusbar', self.db.statusbar)
	local CastTexture = LSM:Fetch('statusbar', self.db.statusbar)
	local Font, FontSize, FontFlag = LSM:Fetch('font', 'Arial'), 12, 'OUTLINE'

	frame:SetPoint('CENTER')
	frame:SetSize(150, 10)
	frame:SetScale(UIParent:GetEffectiveScale())

	local Health = CreateFrame('StatusBar', nil, frame)
	local Power = CreateFrame('StatusBar', nil, frame)
	local AdditionalPower = CreateFrame('StatusBar', nil, frame)
	local FloatingCombatFeedback = CreateFrame('Frame', nil, Health)
	local CastBar = CreateFrame('StatusBar', nil, frame)

	local Name = Health:CreateFontString(nil, 'OVERLAY')
	local Info = Health:CreateFontString(nil, 'OVERLAY')
	local RaidIcon = Health:CreateTexture(nil, 'OVERLAY')
	local QuestIcon = Health:CreateTexture(nil, 'OVERLAY', 2)

	Health:SetFrameStrata(frame:GetFrameStrata())
	Health:SetFrameLevel(4)
	Health:SetAllPoints()
	Health:CreateBackdrop('Transparent')
	Health.backdrop:CreateShadow()
	Health:SetStatusBarTexture(HealthTexture)

	Health.Value = Health:CreateFontString(nil, 'OVERLAY')
	Health.Value:SetFont(Font, FontSize, FontFlag)
	Health.Value:SetPoint('RIGHT', Health, 'LEFT', -20, 0)
	frame:Tag(Health.Value, '[curhp]')

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

	frame.HealthPrediction = {}

	for _, Bar in pairs({ 'myBar', 'otherBar', 'absorbBar', 'healAbsorbBar' }) do
		frame.HealthPrediction[Bar] = CreateFrame('StatusBar', nil, Health)
		frame.HealthPrediction[Bar]:SetStatusBarTexture(HealthTexture)
		frame.HealthPrediction[Bar]:SetPoint('TOP')
		frame.HealthPrediction[Bar]:SetPoint('BOTTOM')
		frame.HealthPrediction[Bar]:SetWidth(150)
	end

	frame.HealthPrediction.myBar:SetPoint('LEFT', Health:GetStatusBarTexture(), 'RIGHT')
	frame.HealthPrediction.myBar:SetFrameLevel(Health:GetFrameLevel() + 2)
	frame.HealthPrediction.myBar:SetStatusBarColor(0, 0.3, 0.15, 1)
	frame.HealthPrediction.myBar:SetMinMaxValues(0,1)

	frame.HealthPrediction.otherBar:SetPoint('LEFT', frame.HealthPrediction.myBar:GetStatusBarTexture(), 'RIGHT')
	frame.HealthPrediction.otherBar:SetFrameLevel(Health:GetFrameLevel() + 1)
	frame.HealthPrediction.otherBar:SetStatusBarColor(0, 0.3, 0, 1)

	frame.HealthPrediction.absorbBar:SetPoint('LEFT', frame.HealthPrediction.otherBar:GetStatusBarTexture(), 'RIGHT')
	frame.HealthPrediction.absorbBar:SetFrameLevel(Health:GetFrameLevel())
	frame.HealthPrediction.absorbBar:SetStatusBarColor(0.3, 0.3, 0, 1)

	frame.HealthPrediction.healAbsorbBar:SetPoint('RIGHT', Health:GetStatusBarTexture())
	frame.HealthPrediction.healAbsorbBar:SetFrameLevel(Health:GetFrameLevel() + 3)
	frame.HealthPrediction.healAbsorbBar:SetStatusBarColor(1, 0.3, 0.3, 1)
	frame.HealthPrediction.healAbsorbBar:SetReverseFill(true)

	frame.HealthPrediction.maxOverflow = 1
	frame.HealthPrediction.frequentUpdates = true

	CastBar:SetFrameStrata(frame:GetFrameStrata())
	CastBar:SetStatusBarTexture(CastTexture)
	CastBar:SetFrameLevel(6)
	CastBar:CreateBackdrop('Transparent')
	CastBar.backdrop:CreateShadow()
	CastBar:SetHeight(16)
	CastBar:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, -20)
	CastBar:SetPoint('TOPRIGHT', Health, 'BOTTOMRIGHT', 0, -20)

	CastBar.Button = CreateFrame('Frame', nil, CastBar)
	CastBar.Button:SetSize(18, 18)
	CastBar.Button:SetTemplate()
	CastBar.Button:CreateShadow()
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

	Power:SetFrameStrata(frame:GetFrameStrata())
	Power:SetFrameLevel(2)
	Power:SetSize(130, 4)
	Power:CreateBackdrop('Transparent')
	Power.backdrop:CreateShadow()
	Power:SetPoint('TOP', Health, 'TOP', 0, -14)
	Power:SetStatusBarTexture(PowerTexture)

	Power.Value = Power:CreateFontString(nil, 'OVERLAY')
	Power.Value:SetFont(Font, FontSize, FontFlag)
	Power.Value:SetPoint('RIGHT', Power, 'LEFT', -20, 0)
	frame:Tag(Power.Value, '[curpp]')

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
	AdditionalPower:SetFrameStrata(frame:GetFrameStrata())
	AdditionalPower:SetFrameLevel(2)
	AdditionalPower:SetSize(130, 4)
	AdditionalPower:CreateBackdrop('Transparent')
	AdditionalPower.backdrop:CreateShadow()
	AdditionalPower:SetPoint('TOP', Power, 'BOTTOM', 0, -2)
	AdditionalPower:SetStatusBarTexture(PowerTexture)

	AdditionalPower.Value = AdditionalPower:CreateFontString(nil, 'OVERLAY')
	AdditionalPower.Value:SetFont(Font, FontSize, FontFlag)
	AdditionalPower.Value:SetPoint('LEFT', AdditionalPower, 'RIGHT', 20, 0)
	frame:Tag(AdditionalPower.Value, '[curmana]')

	AdditionalPower.colorPower = true
	AdditionalPower.PreUpdate = function(bar)
		local Color = ElvUF.colors.power[ADDITIONAL_POWER_BAR_NAME]

		if Color then
			bar.Value:SetTextColor(Color[1], Color[2], Color[3])
		end

		bar.Value:UpdateTag()
	end

	AdditionalPower.PostUpdate = AdditionalPower.PostUpdate

	frame.AdditionalPower = AdditionalPower

	local mainBar = CreateFrame('StatusBar', nil, Power)
	mainBar:SetReverseFill(true)
	mainBar:SetPoint('TOP')
	mainBar:SetPoint('BOTTOM')
	mainBar:SetPoint('RIGHT', Power:GetStatusBarTexture(), 'RIGHT')
	mainBar:SetWidth(130)
	mainBar:SetStatusBarTexture(PowerTexture)

	local altBar = CreateFrame('StatusBar', nil, AdditionalPower)
	altBar:SetReverseFill(true)
	altBar:SetPoint('TOP')
	altBar:SetPoint('BOTTOM')
	altBar:SetPoint('RIGHT', AdditionalPower:GetStatusBarTexture(), 'RIGHT')
	altBar:SetWidth(130)
	altBar:SetStatusBarTexture(PowerTexture)

	frame.PowerPrediction = {
		mainBar = mainBar,
		altBar = altBar
	}

	Name:SetPoint('BOTTOM', Health, 'TOP', 0, 15)
	Name:SetJustifyH('LEFT')
	Name:SetFont(Font, FontSize, FontFlag)

	Info:SetPoint('TOP', Power, 'BOTTOM', 0, -5)
	Info:SetJustifyH('LEFT')
	Info:SetFont(Font, FontSize, FontFlag)
	Info.frequentUpdates = true

	RaidIcon:SetSize(16, 16)
	RaidIcon:SetPoint('TOP', Health, 0, 8)

	QuestIcon:Hide()
	QuestIcon:SetSize(24, 24)
	QuestIcon:SetPoint('CENTER', Name, 'CENTER', 0, 20)
	QuestIcon:SetTexture('Interface\\MINIMAP\\ObjectIcons')
	QuestIcon:SetTexCoord(0.125, 0.250, 0.125, 0.250)

	frame:Tag(Name, '[name] [level] [npctitle]')
	frame:Tag(Info, '[quest:info]')

	FloatingCombatFeedback:SetPoint('CENTER')
	FloatingCombatFeedback:SetSize(16,16)
	FloatingCombatFeedback.mode = 'Fountain'
	FloatingCombatFeedback.xOffset = 60
	FloatingCombatFeedback.yOffset = 10
	FloatingCombatFeedback.yDirection = 1 -- 1 (Up) or -1 (Down)
	FloatingCombatFeedback.scrollTime = 1.5

	for i = 1, 12 do
		FloatingCombatFeedback[i] = FloatingCombatFeedback:CreateFontString(nil, 'OVERLAY')
		FloatingCombatFeedback[i]:SetFont(Font, 18, 'THINOUTLINE')
	end

	local Leader = Health:CreateTexture(nil, 'OVERLAY', 2)
	Leader:Size(14, 14)
	Leader:Point('TOPLEFT', 0, 8)

	local PvP = Health:CreateTexture(nil, 'OVERLAY')
	PvP:Size(36, 36)
	PvP:Point('CENTER', Health)

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

	frame.ThreatIndicator = ThreatIndicator

	-- Register with oUF
	frame.Health = Health
	frame.Power = Power
	frame.Castbar = CastBar

	frame.Name = Name
	frame.Info = Info

	frame.QuestIndicator = QuestIcon
	frame.RaidTargetIndicator = RaidTargetIndicator
	frame.PvPIndicator = PvP

	frame.FloatingCombatFeedback = FloatingCombatFeedback
end

function NP:PersonalStyle(self, event, unit)
end

function NP:FriendlyStyle(self, event, unit)
end

function NP:NPCStyle(self, event, unit)
end

function NP:EnemyStyle(self, event, unit)
end

function NP:CVarReset()
	for cvar, value in next, NP.CVars do
		SetCVar(cvar, value)
	end
end

function NP:Initialize()
	self.db = E.db.nameplates

	ElvUF:RegisterStyle('ElvNP', function(frame, unit)
		NP:Style(frame, unit)
	end)
	ElvUF:SetActiveStyle('ElvNP')

	NP.CVars = {
		['nameplateGlobalScale'] = 1,
		['namePlateHorizontalScale'] = 1,
		['nameplateLargerScale'] = 1,
		['nameplateMaxDistance'] = self.db.loadDistance,
		['nameplateMaxScale'] = 1,
		['nameplateMinScale'] = 1,
		['nameplateMotion'] = self.db.motionType == 'STACKED' and '1' or '0',
		['nameplateOtherAtBase'] = 0,
		['nameplateOtherBottomInset'] = self.db.clampToScreen and '0.1' or '-1',
		['nameplateOtherTopInset'] = self.db.clampToScreen and '0.08' or '-1',
		['nameplateOverlapH'] = GetCVarDefault('nameplateOverlapH'),
		['nameplateOverlapV'] = GetCVarDefault('nameplateOverlapV'),
		['nameplatePersonalHideDelaySeconds'] = self.db.units.PLAYER.visibility.hideDelay,
		['nameplatePersonalShowAlways'] = (self.db.units.PLAYER.visibility.showAlways == true and '1' or '0'),
		['nameplatePersonalShowInCombat'] = (self.db.units.PLAYER.visibility.showInCombat == true and '1' or '0'),
		['nameplatePersonalShowWithTarget'] = (self.db.units.PLAYER.visibility.showWithTarget == true and '1' or '0'),
		['nameplateResourceOnTarget'] = 0,
		['nameplateSelectedScale'] = 1,
		['nameplateSelfAlpha'] = 1,
		['nameplateSelfScale'] = 1,
		['nameplateShowAll'] = self.db.displayStyle ~= 'ALL' and '0' or '1',
		['nameplateShowDebuffsOnFriendly'] = 0,
		['nameplateShowFriendlyMinions'] = self.db.units.FRIENDLY_PLAYER.minions == true and '1' or '0',
		['nameplateShowEnemyMinions'] = self.db.units.ENEMY_PLAYER.minions == true and '1' or '0',
		['nameplateShowEnemyMinus'] = self.db.units.ENEMY_NPC.minors == true and '1' or '0',
		['nameplateShowFriendlyNPCs'] = 1,
		['nameplateShowSelf'] = (self.db.units.PLAYER.useStaticPosition == true or self.db.units.PLAYER.enable ~= true) and '0' or '1',
		['namePlateVerticalScale'] = 1,
		['showQuestTrackingTooltips'] = self.db.questIcon and '1',
	}

	local function NamePlateCallBack(nameplate, event, unit)
		local reaction = UnitReaction('player', unit)
		local faction = UnitFactionGroup(unit)

		if (UnitIsUnit(unit, 'player')) then
			NP:PersonalStyle(nameplate, event, unit)
		elseif (UnitIsPVPSanctuary(unit) or (UnitIsPlayer(unit) and UnitIsFriend('player', unit) and reaction and reaction >= 5)) then
			NP:FriendlyStyle(nameplate, event, unit)
		elseif (not UnitIsPlayer(unit) and (reaction and reaction >= 5) or faction == 'Neutral') then
			NP:NPCStyle(nameplate, event, unit)
		else
			NP:EnemyStyle(nameplate, event, unit)
		end
	end

	ElvUF:SpawnNamePlates(nil, NamePlateCallBack, NP.CVars)

	E.NamePlates = self
end

local function InitializeCallback()
	NP:Initialize()
end

E:RegisterModule(NP:GetName(), InitializeCallback)
