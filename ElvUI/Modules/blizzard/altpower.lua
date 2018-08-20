local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: CreateFrame, UIParent, PlayerPowerBarAlt, hooksecurefunc, AltPowerBarHolder

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
	local function Position(self)
		self:Point('CENTER', AltPowerBarHolder, 'CENTER')
	end
	hooksecurefunc(PlayerPowerBarAlt, "ClearAllPoints", Position)

	E:CreateMover(holder, 'AltPowerBarMover', L["Alternative Power"])
end

function B:SkinAltPowerBar()
	if E.db.general.altPowerBar.enable ~= true then return end

	local width = E.db.general.altPowerBar.width or 200
	local height = E.db.general.altPowerBar.height or 20
	local font = E.db.general.altPowerBar.font
	local fontSize = E.db.general.altPowerBar.fontSize or 12
	local fontOutline = E.db.general.altPowerBar.fontOutline or 'OUTLINE'
	local statusBar = E.db.general.altPowerBar.statusBar

	local powerbar = CreateFrame("StatusBar", "Alt Powerbar", UIParent)
	powerbar:SetTemplate("Transparent")
	powerbar:SetStatusBarTexture(E.LSM:Fetch("statusbar", statusBar))
	powerbar:SetMinMaxValues(0, 200)
	powerbar:SetSize(width, height)
	powerbar:SetStatusBarColor(.2, .4, 0.8, 1)
	powerbar:SetPoint("CENTER", AltPowerBarMover)
	powerbar:Hide()

	powerbar.text = powerbar:CreateFontString(nil, "OVERLAY")
	powerbar.text:SetFont(E.LSM:Fetch("font", font), fontSize, fontOutline)
	powerbar.text:SetPoint("CENTER", powerbar, "CENTER")
	powerbar.text:SetJustifyH("CENTER")
	powerbar.text:SetText("")

	--Event handling
	powerbar:RegisterEvent("UNIT_POWER_UPDATE")
	powerbar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	powerbar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	powerbar:RegisterEvent("PLAYER_ENTERING_WORLD")
	powerbar:SetScript("OnEvent", function(self, event, arg1)
		if not powerbar then
			PlayerPowerBarAlt:RegisterEvent("UNIT_POWER_BAR_SHOW")
			PlayerPowerBarAlt:RegisterEvent("UNIT_POWER_BAR_HIDE")
			PlayerPowerBarAlt:RegisterEvent("PLAYER_ENTERING_WORLD")
			if (event == "UNIT_POWER_BAR_SHOW") then
				PlayerPowerBarAlt:Show()
			end
			self:Hide()
			return
		else
			PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_SHOW")
			PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_HIDE")
			PlayerPowerBarAlt:UnregisterEvent("PLAYER_ENTERING_WORLD")
			PlayerPowerBarAlt:Hide()
			if UnitAlternatePowerInfo("player") or UnitAlternatePowerInfo("target") then
				self:Show()
				self:SetMinMaxValues(0, UnitPowerMax("player", ALTERNATE_POWER_INDEX))
				local power = UnitPower("player", ALTERNATE_POWER_INDEX)
				local mpower = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
				local perc = mpower > 0 and floor(power/mpower*100) or 0
				self:SetValue(power)
				self.text:SetText(power.."/"..mpower.." - "..perc.."%")
			else
				self:Hide()
			end
		end
	end)
end