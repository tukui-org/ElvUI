local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--Lua functions
local floor = math.floor
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_AltPowerBar(frame)
	local altpower = CreateFrame("StatusBar", nil, frame)
	altpower:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[altpower] = true
	altpower:GetStatusBarTexture():SetHorizTile(false)

	altpower.PostUpdate = UF.AltPowerBarPostUpdate
	altpower:CreateBackdrop("Default", true)

	altpower.text = altpower:CreateFontString(nil, 'OVERLAY')
	altpower.text:Point("CENTER")
	altpower.text:SetJustifyH("CENTER")
	UF:Configure_FontString(altpower.text)

	altpower:SetScript("OnShow", UF.ToggleResourceBar)
	altpower:SetScript("OnHide", UF.ToggleResourceBar)

	return altpower
end

function UF:AltPowerBarPostUpdate(unit, cur, _, max)
	if not self.barType then return end
	local perc = (cur and max and max > 0) and floor((cur/max)*100) or 0
	local parent = self:GetParent()

	if perc < 35 then
		self:SetStatusBarColor(0, 1, 0)
	elseif perc < 70 then
		self:SetStatusBarColor(1, 1, 0)
	else
		self:SetStatusBarColor(1, 0, 0)
	end

	if unit == "player" and self.text then
		if perc > 0 then
			self.text:SetFormattedText("%s: %d%%", self.powerName, perc)
		else
			self.text:SetFormattedText("%s: 0%%", self.powerName)
		end
	elseif unit and unit:find("boss%d") and self.text then
		self.text:SetTextColor(self:GetStatusBarColor())
		if not parent.Power.value:GetText() or parent.Power.value:GetText() == "" then
			self.text:Point("BOTTOMRIGHT", parent.Health, "BOTTOMRIGHT")
		else
			self.text:Point("RIGHT", parent.Power.value, "LEFT", 2, E.mult)
		end
		if perc > 0 then
			self.text:SetFormattedText("|cffD7BEA5[|r%d%%|cffD7BEA5]|r", perc)
		else
			self.text:SetText(nil)
		end
	end
end

function UF:Configure_AltPower(frame)
	if not frame.VARIABLES_SET then return end
	local altpower = frame.AlternativePower

	if frame.USE_POWERBAR then
		frame:EnableElement('AlternativePower')
		altpower.text:SetAlpha(1)
		altpower:Point("BOTTOMLEFT", frame.Health.backdrop, "TOPLEFT", frame.BORDER, frame.SPACING+frame.BORDER)
		if not frame.USE_PORTRAIT_OVERLAY then
			altpower:Point("TOPRIGHT", frame, "TOPRIGHT", -(frame.PORTRAIT_WIDTH+frame.BORDER), -frame.BORDER)
		else
			altpower:Point("TOPRIGHT", frame, "TOPRIGHT", -frame.BORDER, -frame.BORDER)
		end
		altpower.Smooth = UF.db.smoothbars
	else
		frame:DisableElement('AlternativePower')
		altpower.text:SetAlpha(0)
		altpower:Hide()
	end
end
