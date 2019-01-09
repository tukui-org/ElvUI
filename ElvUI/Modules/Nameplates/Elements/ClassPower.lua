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
	ClassPower:SetPoint("BOTTOM", frame.Health, "BOTTOM", 0, 14)

	ClassPower:SetSize(130 + ((MAX_POINTS[E.myclass] or 5) - 1), 7)
	local Width = 130 / 6

	for i = 1, (MAX_POINTS[E.myclass] or 5) do
		ClassPower[i] = CreateFrame('StatusBar', nil, ClassPower)
		ClassPower[i]:SetSize(Width, 7)
		ClassPower[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))

		if i == 1 then
			ClassPower[i]:SetPoint('LEFT', ClassPower, 'LEFT', 0, 0)
		else
			ClassPower[i]:SetPoint('LEFT', ClassPower[i - 1], 'LEFT', 1, 0)
		end
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
			for i = 1, max do
				element[i]:SetSize(130 / max, 7)
				if i == 1 then
					element[i]:SetPoint('LEFT', element, 'LEFT', 0, 0)
				else
					element[i]:SetPoint('LEFT', element[i - 1], 'LEFT', 1, 0)
				end
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

	Runes:SetSize(130 + 5, 7)
	local width = 130 / 6

	for i = 1, 6 do
		Runes[i] = CreateFrame("StatusBar", nil, Runes)
		Runes[i]:Hide()
		Runes[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))
		Runes[i]:SetStatusBarColor(0.31, 0.45, 0.63)
		Runes[i]:SetSize(width, 7)

		if i == 1 then
			Runes[i]:SetPoint('LEFT', Runes, 'LEFT', 0, 0)
		else
			Runes[i]:SetPoint('LEFT', Runes[i-1], 'RIGHT', 1, 0)
		end
	end

	return Runes
end

function NP:Update_ClassPower(nameplate)
	if nameplate.frameType == 'PLAYER' then
		nameplate:EnableElement('ClassPower')
		if E.myclass == 'DEATHKNIGHT' then
			nameplate:EnableElement('Runes')
		end
	end
end