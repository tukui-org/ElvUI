local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')
local LSM = E.Libs.LSM

local _G = _G
local floor = floor
local hooksecurefunc = hooksecurefunc

local UnitPower = UnitPower
local CreateFrame = CreateFrame
local UnitPowerMax = UnitPowerMax
local GetUnitPowerBarInfo = GetUnitPowerBarInfo
local GetUnitPowerBarStrings = GetUnitPowerBarStrings

local function UpdateTooltip(self)
	if _G.GameTooltip:IsForbidden() then return end

	if self.powerName and self.powerTooltip then
		_G.GameTooltip:SetText(self.powerName, 1, 1, 1)
		_G.GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
		_G.GameTooltip:Show()
	end
end

local function OnEnter(self)
	if not self:IsVisible() or _G.GameTooltip:IsForbidden() then return end

	_G.GameTooltip:ClearAllPoints()
	_G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, self)

	UpdateTooltip(self)
end

local function OnLeave()
	_G.GameTooltip:Hide()
end

function BL:SetAltPowerBarText(text, name, value, max, percent)
	local textFormat = E.db.general.altPowerBar.textFormat
	if textFormat == 'NONE' or not textFormat then
		text:SetText('')
	elseif textFormat == 'NAME' then
		text:SetFormattedText('%s', name)
	elseif textFormat == 'NAMEPERC' then
		text:SetFormattedText('%s: %s%%', name, percent)
	elseif textFormat == 'NAMECURMAX' then
		text:SetFormattedText('%s: %s / %s', name, value, max)
	elseif textFormat == 'NAMECURMAXPERC' then
		text:SetFormattedText('%s: %s / %s - %s%%', name, value, max, percent)
	elseif textFormat == 'PERCENT' then
		text:SetFormattedText('%s%%', percent)
	elseif textFormat == 'CURMAX' then
		text:SetFormattedText('%s / %s', value, max)
	elseif textFormat == 'CURMAXPERC' then
		text:SetFormattedText('%s / %s - %s%%', value, max, percent)
	end
end

function BL:SetUpUnitPowerBarAlt()
	local holder = BL.AltPowerBarHolder
	if not holder then return end

	local bar = _G.PlayerPowerBarAlt
	if not bar then return end

	if self == bar and bar.isPlayerBar then
		bar:SetParent(holder)
		bar:ClearAllPoints()
		bar:Point('CENTER', BL.AltPowerBarHolder)
	end
end

function BL:PositionAltPowerBar()
	local holder = CreateFrame('Frame', 'AltPowerBarHolder', E.UIParent)
	holder:Point('TOP', E.UIParent, 'TOP', 0, -40)
	holder:Size(128, 50)

	BL.AltPowerBarHolder = holder

	local bar = _G.PlayerPowerBarAlt
	if bar then
		bar:SetParent(holder)
		bar:ClearAllPoints()
		bar:Point('CENTER', holder)
		bar:SetMovable(true)
		bar:SetUserPlaced(true)
		bar:SetDontSavePosition(true)
	end

	if E.Mists then -- Blizzard adjusts this in UnitPowerBarAlt_SetUp when it has isPlayerBar
		hooksecurefunc('UnitPowerBarAlt_SetUp', BL.SetUpUnitPowerBarAlt)
	end

	E:CreateMover(holder, 'AltPowerBarMover', L["Alternative Power"], nil, nil, nil, nil, nil, 'general,alternativePowerGroup')
end

function BL:UpdateAltPowerBarColors()
	local bar = BL.AltPowerBar
	if not bar then return end

	if E.db.general.altPowerBar.statusBarColorGradient then
		local power, maxPower = bar.powerValue or 0, bar.powerMaxValue or 0
		local value = (maxPower > 0 and power / maxPower) or 0

		if bar.colorGradientValue ~= value then
			bar.colorGradientValue = value

			local r, g, b = E:ColorGradient(value, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
			bar:SetStatusBarColor(r, g, b)
		end
	else
		local color = E.db.general.altPowerBar.statusBarColor
		bar:SetStatusBarColor(color.r, color.g, color.b)
	end
end

function BL:UpdateAltPowerBarSettings()
	local bar = BL.AltPowerBar
	if not bar then return end

	local db = E.db.general.altPowerBar
	bar:Size(db.width or 250, db.height or 20)
	bar:SetStatusBarTexture(LSM:Fetch('statusbar', db.statusBar))
	bar.text:FontTemplate(LSM:Fetch('font', db.font), db.fontSize or 12, db.fontOutline or 'OUTLINE')
	BL.AltPowerBarHolder:Size(bar.backdrop:GetSize())

	E:SetSmoothing(bar, db.smoothbars)

	BL:SetAltPowerBarText(bar.text, bar.powerName or '', bar.powerValue or 0, bar.powerMaxValue or 0, bar.powerPercent or 0)
end

function BL:UpdateAltPowerBar()
	local bar = _G.PlayerPowerBarAlt
	if bar then
		bar:UnregisterAllEvents()
		bar:Hide()
	end

	local barInfo = GetUnitPowerBarInfo('player')
	if barInfo then
		local powerName, powerTooltip = GetUnitPowerBarStrings('player')
		local power = UnitPower('player', _G.ALTERNATE_POWER_INDEX) or 0
		local maxPower = UnitPowerMax('player', _G.ALTERNATE_POWER_INDEX) or 0
		local perc = (maxPower > 0 and floor(power / maxPower * 100)) or 0

		self.powerMaxValue = maxPower
		self.powerName = powerName
		self.powerPercent = perc
		self.powerTooltip = powerTooltip
		self.powerValue = power

		self:Show()
		self:SetMinMaxValues(barInfo.minPower, maxPower)
		self:SetValue(power)

		if E.db.general.altPowerBar.statusBarColorGradient then
			local value = (maxPower > 0 and power / maxPower) or 0

			if self.colorGradientValue ~= value then
				self.colorGradientValue = value

				local r, g, b = E:ColorGradient(value, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
				self:SetStatusBarColor(r, g, b)
			end
		end

		BL:SetAltPowerBarText(self.text, powerName or '', power, maxPower, perc)
	else
		self.powerMaxValue = nil
		self.powerName = nil
		self.powerPercent = nil
		self.powerTooltip = nil
		self.powerValue = nil

		self:Hide()
	end
end

function BL:SkinAltPowerBar()
	if not E.db.general.altPowerBar.enable then return end

	local bar = CreateFrame('StatusBar', 'ElvUI_AltPowerBar', E.UIParent)
	bar:CreateBackdrop(nil, true)
	bar:SetMinMaxValues(0, 200)
	bar:Point('CENTER', BL.AltPowerBarHolder)
	bar:SetScript('OnEnter', OnEnter)
	bar:SetScript('OnLeave', OnLeave)
	bar:Hide()

	BL.AltPowerBar = bar

	bar.text = bar:CreateFontString(nil, 'OVERLAY')
	bar.text:Point('CENTER', bar, 'CENTER')
	bar.text:SetJustifyH('CENTER')

	BL:UpdateAltPowerBarSettings()
	BL:UpdateAltPowerBarColors()

	bar:RegisterEvent('UNIT_POWER_UPDATE')
	bar:RegisterEvent('UNIT_POWER_BAR_SHOW')
	bar:RegisterEvent('UNIT_POWER_BAR_HIDE')
	bar:RegisterEvent('PLAYER_ENTERING_WORLD')
	bar:SetScript('OnEvent', BL.UpdateAltPowerBar)
end
