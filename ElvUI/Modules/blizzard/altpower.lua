local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard');

local floor = math.floor
local format = string.format
local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
-- GLOBALS: CreateFrame, PlayerPowerBarAlt, ALTERNATE_POWER_INDEX, hooksecurefunc
-- GLOBALS: GameTooltip, GameTooltip_SetDefaultAnchor, ElvUI_AltPowerBar, AltPowerBarHolder

local function updateTooltip(self)
	if GameTooltip:IsForbidden() then return end

	if self.powerName and self.powerTooltip then
		GameTooltip:SetText(self.powerName, 1, 1, 1)
		GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
		GameTooltip:Show()
	end
end

local function onEnter(self)
	if not self:IsVisible() then return end

	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	updateTooltip(self)
end

local function onLeave()
	GameTooltip:Hide()
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

	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:Point('CENTER', holder, 'CENTER')
	PlayerPowerBarAlt:SetParent(holder)
	PlayerPowerBarAlt.ignoreFramePositionManager = true

	--The Blizzard function FramePositionDelegate:UIParentManageFramePositions()
	--calls :ClearAllPoints on PlayerPowerBarAlt under certain conditions.
	--Doing ".ClearAllPoints = E.noop" causes error when you enter combat.
	local function Position(bar) bar:Point('CENTER', AltPowerBarHolder, 'CENTER') end
	hooksecurefunc(PlayerPowerBarAlt, "ClearAllPoints", Position)

	E:CreateMover(holder, 'AltPowerBarMover', L["Alternative Power"], nil, nil, nil, nil, nil, 'general,alternativePowerGroup')
end

function B:UpdateAltPowerBarColors()
	local bar = ElvUI_AltPowerBar

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
	local bar = ElvUI_AltPowerBar
	local width = E.db.general.altPowerBar.width or 250
	local height = E.db.general.altPowerBar.height or 20
	local fontOutline = E.db.general.altPowerBar.fontOutline or 'OUTLINE'
	local fontSize = E.db.general.altPowerBar.fontSize or 12
	local statusBar = E.db.general.altPowerBar.statusBar
	local font = E.db.general.altPowerBar.font

	bar:SetSize(width, height)
	bar:SetStatusBarTexture(E.LSM:Fetch("statusbar", statusBar))
	bar.text:SetFont(E.LSM:Fetch("font", font), fontSize, fontOutline)
	AltPowerBarHolder:SetSize(bar.backdrop:GetSize())

	local textFormat = E.db.general.altPowerBar.textFormat
	if textFormat == 'NONE' or not textFormat then
		bar.text:SetText("")
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
	powerbar:SetPoint("CENTER", AltPowerBarHolder)
	powerbar:Hide()

	powerbar:SetScript("OnEnter", onEnter)
	powerbar:SetScript("OnLeave", onLeave)

	powerbar.text = powerbar:CreateFontString(nil, "OVERLAY")
	powerbar.text:SetPoint("CENTER", powerbar, "CENTER")
	powerbar.text:SetJustifyH("CENTER")

	B:UpdateAltPowerBarSettings()
	B:UpdateAltPowerBarColors()

	--Event handling
	powerbar:RegisterEvent("UNIT_POWER_UPDATE")
	powerbar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	powerbar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	powerbar:RegisterEvent("PLAYER_ENTERING_WORLD")
	powerbar:SetScript("OnEvent", function(bar)
		PlayerPowerBarAlt:UnregisterAllEvents()
		PlayerPowerBarAlt:Hide()

		local barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo('player')
		if not barType then
			barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo('target')
		end

		bar.powerName = powerName
		bar.powerTooltip = powerTooltip

		if barType then
			local power = UnitPower("player", ALTERNATE_POWER_INDEX)
			local maxPower = UnitPowerMax("player", ALTERNATE_POWER_INDEX) or 0
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
