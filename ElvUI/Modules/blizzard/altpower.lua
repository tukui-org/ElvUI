local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard');

local floor = math.floor
local format = string.format
local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
-- GLOBALS: CreateFrame, UIParent, PlayerPowerBarAlt, ALTERNATE_POWER_INDEX, hooksecurefunc
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
	local holder = CreateFrame('Frame', 'AltPowerBarHolder', UIParent)
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

	E:CreateMover(holder, 'AltPowerBarMover', L["Alternative Power"])
end

function B:UpdateAltPowerBarColors()
	if E.db.general.altPowerBar.statusBarColorGradient then
		local power = ElvUI_AltPowerBar:GetValue() or 0
		local _, maxPower = ElvUI_AltPowerBar:GetMinMaxValues()
		local value = (maxPower and maxPower > 0 and power / maxPower) or 0
		local r, g, b = E:ColorGradient(value, 0,0.8,0, 0.8,0.8,0, 0.8,0,0)
		ElvUI_AltPowerBar:SetStatusBarColor(r, g, b)
	else
		local color = E.db.general.altPowerBar.statusBarColor
		ElvUI_AltPowerBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
	end
end

function B:UpdateAltPowerBarSettings()
	local width = E.db.general.altPowerBar.width or 200
	local height = E.db.general.altPowerBar.height or 20
	local fontOutline = E.db.general.altPowerBar.fontOutline or 'OUTLINE'
	local fontSize = E.db.general.altPowerBar.fontSize or 12
	local statusBar = E.db.general.altPowerBar.statusBar
	local font = E.db.general.altPowerBar.font

	ElvUI_AltPowerBar:SetSize(width, height)
	ElvUI_AltPowerBar:SetStatusBarTexture(E.LSM:Fetch("statusbar", statusBar))
	ElvUI_AltPowerBar.text:SetFont(E.LSM:Fetch("font", font), fontSize, fontOutline)
	AltPowerBarHolder:SetSize(ElvUI_AltPowerBar.backdrop:GetSize())

	local textFormat = E.db.general.altPowerBar.textFormat
	if textFormat == 'NONE' or not textFormat then
		ElvUI_AltPowerBar.text:SetText("")
	else
		local power = ElvUI_AltPowerBar:GetValue() or 0
		local _, maxPower = ElvUI_AltPowerBar:GetMinMaxValues()
		local perc = (maxPower > 0 and floor(power / maxPower * 100)) or 0
		local text = B:SetAltPowerBarText(ElvUI_AltPowerBar.powerName or "", power, maxPower or 0, perc)
		ElvUI_AltPowerBar.text:SetText(text)
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
			local maxPower = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
			local perc = (maxPower > 0 and floor(power / maxPower * 100)) or 0

			bar:Show()
			bar:SetMinMaxValues(min, maxPower)
			bar:SetValue(power)

			if E.db.general.altPowerBar.statusBarColorGradient then
				local value = (maxPower > 0 and power / maxPower) or 0
				local r, g, b = E:ColorGradient(value, 0,0.8,0, 0.8,0.8,0, 0.8,0,0)
				bar:SetStatusBarColor(r, g, b)
			end

			local text = B:SetAltPowerBarText(powerName or "", power, maxPower, perc)
			bar.text:SetText(text)
		else
			bar:Hide()
		end
	end)
end
