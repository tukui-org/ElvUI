local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Lua functions
local floor = floor
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_AltPowerBar(frame)
	local altpower = CreateFrame("StatusBar", nil, frame)
	altpower:SetStatusBarTexture(E.media.blankTex)
	UF.statusbars[altpower] = true
	altpower:SetStatusBarColor(.7, 0.7, 0.6)
	altpower:GetStatusBarTexture():SetHorizTile(false)

	altpower.PostUpdate = UF.AltPowerBarPostUpdate
	altpower:CreateBackdrop(nil, true)

	altpower.text = altpower:CreateFontString(nil, 'OVERLAY')
	altpower.text:Point("CENTER")
	altpower.text:SetJustifyH("CENTER")
	UF:Configure_FontString(altpower.text)

	altpower:SetScript("OnShow", UF.ToggleResourceBar)
	altpower:SetScript("OnHide", UF.ToggleResourceBar)
	altpower:Hide()

	return altpower
end

function UF:AltPowerBarPostUpdate(unit, cur, _, max)
	if not self.barType then return end
	local perc = (cur and max and max > 0) and floor((cur/max)*100) or 0
	local parent = self:GetParent()

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
			self.text:SetText('')
		end
	end
end
