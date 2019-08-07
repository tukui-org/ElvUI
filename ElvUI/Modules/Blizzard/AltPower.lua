local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

--Lua functions
local _G = _G
local floor = math.floor
local format = string.format
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
-- GLOBALS: AltPowerBarHolder

local function updateTooltip(self)
	if _G.GameTooltip:IsForbidden() then return end

	if self.powerName and self.powerTooltip then
		_G.GameTooltip:SetText(self.powerName, 1, 1, 1)
		_G.GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
		_G.GameTooltip:Show()
	end
end

local function onEnter(self)
	if (not self:IsVisible()) or _G.GameTooltip:IsForbidden() then return end

	_G.GameTooltip:ClearAllPoints()
	_G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, self)
	updateTooltip(self)
end

local function onLeave()
	_G.GameTooltip:Hide()
end

function B:SetAltPowerBarText(name, value, max, percent)
	local textFormat = E.db.general.altPowerBar.textFormat

	if textFormat == 'NONE' or not textFormat then
		return ""
	elseif textFormat == 'NAME' then
		return format("%s", name)
	elseif textFormat == 'NAMEPERC' then
		return format("%s: %s%%", name, percent)
	elseif textFormat == 'NAMECURMAX' then
		return format("%s: %s / %s", name, value, max)
	elseif textFormat == 'NAMECURMAXPERC' then
		return format("%s: %s / %s - %s%%", name, value, max, percent)
	elseif textFormat == 'PERCENT' then
		return format("%s%%", percent)
	elseif textFormat == 'CURMAX' then
		return format("%s / %s", value, max)
	elseif textFormat == 'CURMAXPERC' then
		return format("%s / %s - %s%%", value, max, percent)
	end
end

function B:PositionAltPowerBar()
	local holder = CreateFrame('Frame', 'AltPowerBarHolder', E.UIParent)
	holder:Point('TOP', E.UIParent, 'TOP', 0, -18)
	holder:Size(128, 50)

	_G.PlayerPowerBarAlt:ClearAllPoints()
	_G.PlayerPowerBarAlt:Point('CENTER', holder, 'CENTER')
	_G.PlayerPowerBarAlt:SetParent(holder)
	_G.PlayerPowerBarAlt.ignoreFramePositionManager = true

	--The Blizzard function FramePositionDelegate:UIParentManageFramePositions()
	--calls :ClearAllPoints on PlayerPowerBarAlt under certain conditions.
	--Doing ".ClearAllPoints = E.noop" causes error when you enter combat.
	local function Position(bar) bar:Point('CENTER', AltPowerBarHolder, 'CENTER') end
	hooksecurefunc(_G.PlayerPowerBarAlt, "ClearAllPoints", Position)

	E:CreateMover(holder, 'AltPowerBarMover', L["Alternative Power"], nil, nil, nil, nil, nil, 'general,alternativePowerGroup')
end

function B:UpdateAltPowerBarColors()
	local bar = _G.ElvUI_AltPowerBar

	if E.db.general.altPowerBar.statusBarColorGradient then
		if bar.colorGradientR and bar.colorGradientG and bar.colorGradientB then
			bar:SetStatusBarColor(bar.colorGradientR, bar.colorGradientG, bar.colorGradientB)
		elseif bar.powerValue then
			local power, maxPower = bar.powerValue or 0, bar.powerMaxValue or 0
			local value = (maxPower > 0 and power / maxPower) or 0
			bar.colorGradientValue = value

			local r, g, b = E:ColorGradient(value, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
			bar.colorGradientR, bar.colorGradientG, bar.colorGradientB = r, g, b

			bar:SetStatusBarColor(r, g, b)
		else
			bar:SetStatusBarColor(0.6, 0.6, 0.6) -- uh, fallback!
		end
	else
		local color = E.db.general.altPowerBar.statusBarColor
		bar:SetStatusBarColor(color.r, color.g, color.b)
	end
end

function B:UpdateAltPowerBarSettings()
	local bar = _G.ElvUI_AltPowerBar
	local db = E.db.general.altPowerBar

	bar:Size(db.width or 250, db.height or 20)
	bar:SetStatusBarTexture(E.Libs.LSM:Fetch("statusbar", db.statusBar))
	bar.text:FontTemplate(E.Libs.LSM:Fetch("font", db.font), db.fontSize or 12, db.fontOutline or 'OUTLINE')
	AltPowerBarHolder:Size(bar.backdrop:GetSize())

	E:SetSmoothing(bar, db.smoothbars)

	local textFormat = E.db.general.altPowerBar.textFormat
	if textFormat == 'NONE' or not textFormat then
		bar.text:SetText('')
	else
		local power, maxPower, perc = bar.powerValue or 0, bar.powerMaxValue or 0, bar.powerPercent or 0
		local text = B:SetAltPowerBarText(bar.powerName or "", power, maxPower, perc)
		bar.text:SetText(text)
	end
end

function B:SkinAltPowerBar()
	if E.db.general.altPowerBar.enable ~= true then return end

	local powerbar = CreateFrame("StatusBar", "ElvUI_AltPowerBar", E.UIParent)
	powerbar:CreateBackdrop("Transparent")
	powerbar:SetMinMaxValues(0, 200)
	powerbar:Point("CENTER", AltPowerBarHolder)
	powerbar:Hide()

	powerbar:SetScript("OnEnter", onEnter)
	powerbar:SetScript("OnLeave", onLeave)

	powerbar.text = powerbar:CreateFontString(nil, "OVERLAY")
	powerbar.text:Point("CENTER", powerbar, "CENTER")
	powerbar.text:SetJustifyH("CENTER")

	B:UpdateAltPowerBarSettings()
	B:UpdateAltPowerBarColors()

	--Event handling
	powerbar:RegisterEvent("UNIT_POWER_UPDATE")
	powerbar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	powerbar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	powerbar:RegisterEvent("PLAYER_ENTERING_WORLD")
	powerbar:SetScript("OnEvent", function(bar)
		_G.PlayerPowerBarAlt:UnregisterAllEvents()
		_G.PlayerPowerBarAlt:Hide()

		local barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo('player')
		if not barType then
			barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo('target')
		end

		bar.powerName = powerName
		bar.powerTooltip = powerTooltip

		if barType then
			local power = UnitPower("player", _G.ALTERNATE_POWER_INDEX)
			local maxPower = UnitPowerMax("player", _G.ALTERNATE_POWER_INDEX) or 0
			local perc = (maxPower > 0 and floor(power / maxPower * 100)) or 0

			bar.powerValue = power
			bar.powerMaxValue = maxPower
			bar.powerPercent = perc

			bar:Show()
			bar:SetMinMaxValues(min, maxPower)
			bar:SetValue(power)

			if E.db.general.altPowerBar.statusBarColorGradient then
				local value = (maxPower > 0 and power / maxPower) or 0
				bar.colorGradientValue = value

				local r, g, b = E:ColorGradient(value, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
				bar.colorGradientR, bar.colorGradientG, bar.colorGradientB = r, g, b

				bar:SetStatusBarColor(r, g, b)
			end

			local text = B:SetAltPowerBarText(powerName or "", power, maxPower, perc)
			bar.text:SetText(text)
		else
			bar:Hide()
		end
	end)
end
