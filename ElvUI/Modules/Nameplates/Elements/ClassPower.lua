local E, L, V, P, G = unpack(ElvUI)
local ElvUF = ElvUI.oUF

local NP = E:GetModule('NamePlates')

local MAX_POINTS = {
	['PALADIN'] = 5,
	['WARLOCK'] = 5,
	['MONK'] = 6,
	['MAGE'] = 4,
	['ROGUE'] = 6,
	['DRUID'] = 5
}

local COMBO_POINT_COLOR = {
	[1] = {.69, .31, .31, 1},
	[2] = {.65, .42, .31, 1},
	[3] = {.65, .63, .35, 1},
	[4] = {.46, .63, .35, 1},
	[5] = {.33, .63, .33, 1},
	[6] = {.33, .63, .33, 1},
}

function NP:Construct_ClassPower(nameplate)
	local ClassPower = CreateFrame('Frame', nameplate:GetDebugName()..'ClassPower', nameplate)
	ClassPower:Hide()
	ClassPower:SetFrameStrata(nameplate:GetFrameStrata())
	ClassPower:SetFrameLevel(1)
	ClassPower:CreateBackdrop('Transparent')
	ClassPower:SetPoint('BOTTOM', nameplate.Health, 'BOTTOM', 0, 14)

	ClassPower:SetSize(NP.db.classbar.width + ((MAX_POINTS[E.myclass] or 5) - 1), NP.db.classbar.height)
	local Width = NP.db.classbar.width / (MAX_POINTS[E.myclass] or 5)

	for i = 1, (MAX_POINTS[E.myclass] or 5) do
		ClassPower[i] = CreateFrame('StatusBar', nameplate:GetDebugName()..'ClassPower'..i, ClassPower)
		ClassPower[i]:SetSize(Width, NP.db.classbar.height)
		ClassPower[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
		NP.StatusBars[ClassPower[i]] = true

		if i == 1 then
			ClassPower[i]:SetPoint('LEFT', ClassPower, 'LEFT', 0, 0)
		else
			ClassPower[i]:SetPoint('LEFT', ClassPower[i - 1], 'RIGHT', 1, 0)
		end
	end

	function ClassPower:UpdateColor(powerType)
		local color = ElvUF.colors.power[powerType]
		local r, g, b = color[1], color[2], color[3]
		for i = 1, #self do

			local bar = self[i]

			if powerType == 'COMBO_POINTS' then
				r, g, b = unpack(COMBO_POINT_COLOR[i])
			end

			bar:SetStatusBarColor(r, g, b)
		end
	end

	function ClassPower:PostUpdate(cur, max, needUpdate, powerType)
		if cur and cur > 0 then
			self:Show()
		else
			self:Hide()
		end
		if needUpdate then
			for i = 1, max do
				self[i]:SetSize(NP.db.classbar.width / max, NP.db.classbar.height)
				if i == 1 then
					self[i]:SetPoint('LEFT', self, 'LEFT', 0, 0)
				else
					self[i]:SetPoint('LEFT', self[i - 1], 'RIGHT', 1, 0)
				end
			end
		end
	end

	return ClassPower
end

function NP:Construct_Runes(nameplate)
	local Runes = CreateFrame('Frame', nameplate:GetDebugName()..'Runes', nameplate)
	Runes:SetFrameStrata(nameplate:GetFrameStrata())
	Runes:SetFrameLevel(2)
	Runes:SetPoint('BOTTOM', nameplate.Health, 'TOP', 0, 4)
	Runes:CreateBackdrop('Transparent')
	Runes:Hide()

	function Runes:UpdateColor() return end

	function Runes:PostUpdate()
		if (UnitHasVehicleUI('player')) then
			self:Hide()
		else
			self:Show()
		end
	end

	Runes:SetSize(NP.classbar.width + 5, NP.db.classbar.height)
	local width = NP.classbar.width / 6

	for i = 1, 6 do
		Runes[i] = CreateFrame('StatusBar', nameplate:GetDebugName()..'Runes'..i, Runes)
		Runes[i]:Hide()
		Runes[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))
		Runes[i]:SetStatusBarColor(0.31, 0.45, 0.63)
		Runes[i]:SetSize(width, NP.db.classbar.height)
		NP.StatusBars[Runes[i]] = true

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
		if not nameplate:IsEnableElement('ClassPower') then
			nameplate:EnableElement('ClassPower')
		end
	else
		if nameplate:IsEnableElement('ClassPower') then
			nameplate:DisableElement('ClassPower')
		end
	end
end

function NP:Update_Runes(nameplate)
	if nameplate.frameType == 'PLAYER' then
		if not nameplate:IsEnableElement('Runes') then
			nameplate:EnableElement('Runes')
		end
	else
		if nameplate:IsEnableElement('Runes') then
			nameplate:DisableElement('Runes')
		end
	end
end
