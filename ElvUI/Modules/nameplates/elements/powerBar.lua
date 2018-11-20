local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local PowerBarColor = PowerBarColor
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

function mod:UpdateElement_MaxPower(frame)
	local maxValue = UnitPowerMax(frame.displayedUnit, frame.PowerType);
	frame.PowerBar:SetMinMaxValues(0, maxValue);
end

local temp = {r = 1, b = 1, g = 1}
function mod:UpdateElement_Power(frame)
	self:UpdateElement_MaxPower(frame)
	local unit = frame.displayedUnit or frame.unit
	local curValue = UnitPower(unit, frame.PowerType);
	local maxValue = UnitPowerMax(unit, frame.PowerType);
	if (curValue == 0 and self.db.units[frame.UnitType].powerbar.hideWhenEmpty) then
		frame.PowerBar:Hide()
	else
		frame.PowerBar:Show()
		frame.PowerBar:SetValue(curValue);

		local color = E.db.unitframe.colors.power[frame.PowerToken] or PowerBarColor[frame.PowerToken] or temp
		if(color) then
			frame.PowerBar:SetStatusBarColor(color.r, color.g, color.b)
		end

		if self.db.units[frame.UnitType].powerbar.text.enable then
			frame.PowerBar.text:SetText(E:GetFormattedText(self.db.units[frame.UnitType].powerbar.text.format, curValue, maxValue))
		else
			frame.PowerBar.text:SetText("")
		end
	end

	if(self.db.classbar.enable and self.db.classbar.position == "BELOW") then
		self:ClassBar_Update()
	end

	if (self.db.units[frame.UnitType].castbar.enable) then
		self:ConfigureElement_CastBar(frame)
	end
end

function mod:ConfigureElement_PowerBar(frame)
	local powerBar = frame.PowerBar
	powerBar:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, -E.Border - E.Spacing*3)
	powerBar:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, -E.Border - E.Spacing*3)
	powerBar:SetHeight(self.db.units[frame.UnitType].powerbar.height)
	powerBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))

	powerBar.text:SetAllPoints(powerBar)
	powerBar.text:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_PowerBar(parent)
	local frame = CreateFrame("StatusBar", "$parentPowerBar", parent)
	self:StyleFrame(frame)

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetWordWrap(false)

	frame:Hide()
	return frame
end
