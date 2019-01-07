local E, L, V, P, G = unpack(ElvUI)
local ElvUF = ElvUI.oUF

local NP = E:GetModule('NamePlates')

local MAX_POINTS = {
	['PALADIN'] = 5,
	['WARLOCK'] = 5,
	['MONK'] = 6,
	['MAGE'] = 4,
	['ROGUE'] = 6,
	["DRUID"] = 5
}

local COMBO_POINT_COLOR = {
	[1] = {.69, .31, .31, 1},
	[2] = {.65, .42, .31, 1},
	[3] = {.65, .63, .35, 1},
	[4] = {.46, .63, .35, 1},
	[5] = {.33, .63, .33, 1},
	[6] = {.33, .63, .33, 1},
}

function NP:Construct_ClassPower(frame)
	local ClassPower = CreateFrame("Frame", nil, frame)
	ClassPower:Hide()
	ClassPower:SetFrameStrata(frame:GetFrameStrata())
	ClassPower:SetFrameLevel(2)
	ClassPower:CreateBackdrop("Transparent")
	ClassPower:SetSize(130, 7)
	ClassPower:SetPoint("BOTTOM", frame.Health, "BOTTOM", 0, 14)

	for index = 1, (MAX_POINTS[E.myclass] or 5) do
		local Bar = CreateFrame('StatusBar', nil, ClassPower)
		Bar:SetSize(130 / (MAX_POINTS[E.myclass] or 5), 7)
		Bar:SetPoint('TOPLEFT', ClassPower, 'TOPLEFT', (index - 1) * Bar:GetWidth(), 0)
		Bar:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))

		ClassPower[index] = Bar
	end

	ClassPower.UpdateColor = function(element, powerType)
		local color = ElvUF.colors.power[powerType]
		local r, g, b = color[1], color[2], color[3]
		for i = 1, #element do

			local bar = element[i]

			if powerType == "COMBO_POINTS" then
				r, g, b = unpack(COMBO_POINT_COLOR[i])
			end

			bar:SetStatusBarColor(r, g, b)
		end
	end

	ClassPower.PostUpdate = function(element, cur, max, needUpdate, powerType)
		if cur and cur > 0 then
			element:Show()
		else
			element:Hide()
		end
		if needUpdate then
			for index = 1, max do
				element[index]:SetSize(130/max, 7)
				element[index]:SetPoint('TOPLEFT', element, 'TOPLEFT', (index - 1) * element[index]:GetWidth(), 0)
			end
		end
	end

	return ClassPower
end

function NP:Construct_Runes(frame)
	local Runes = CreateFrame("Frame", nil, frame)
	Runes:SetFrameStrata(frame:GetFrameStrata())
	Runes:SetFrameLevel(2)
	Runes:SetPoint("BOTTOM", frame.Health, "TOP", 0, 4)
	Runes:SetSize(130, 7)
	Runes:CreateBackdrop()
	Runes:Hide()
	Runes.UpdateColor = function() end
	Runes.PostUpdate = function()
		if (UnitHasVehicleUI('player')) then
			Runes:Hide()
		else
			Runes:Show()
		end
	end

	for i = 1, 6 do
		Runes[i] = CreateFrame("StatusBar", nil, Runes)
		Runes[i]:Hide()
		Runes[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))
		Runes[i]:SetStatusBarColor(0.31, 0.45, 0.63)

		Runes[i]:SetSize(130 / 6, 7)
		Runes[i]:SetPoint('TOPLEFT', Runes, 'TOPLEFT', (i - 1) * Runes[i]:GetWidth(), 0)
	end

	return Runes
end
