local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUF = E.oUF

local NP = E:GetModule('NamePlates')

local unpack = unpack
local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI

local MAX_POINTS = {
	['PALADIN'] = 5,
	['WARLOCK'] = 5,
	['MONK'] = 6,
	['MAGE'] = 4,
	['ROGUE'] = 6,
	['DRUID'] = 5
}

function NP:Construct_ClassPower(nameplate)
	local ClassPower = CreateFrame('Frame', nameplate:GetDebugName()..'ClassPower', nameplate)
	ClassPower:Hide()
	ClassPower:SetFrameStrata(nameplate:GetFrameStrata())
	ClassPower:SetFrameLevel(5)
	ClassPower:CreateBackdrop('Transparent')

	ClassPower:Size(NP.db.classbar.width + ((MAX_POINTS[E.myclass] or 5) - 1), NP.db.classbar.height)
	local Width = NP.db.classbar.width / (MAX_POINTS[E.myclass] or 5)

	for i = 1, (MAX_POINTS[E.myclass] or 5) do
		ClassPower[i] = CreateFrame('StatusBar', nameplate:GetDebugName()..'ClassPower'..i, ClassPower)
		ClassPower[i]:Size(Width, NP.db.classbar.height)
		ClassPower[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
		NP.StatusBars[ClassPower[i]] = true

		if i == 1 then
			ClassPower[i]:Point('LEFT', ClassPower, 'LEFT', 0, 0)
		else
			ClassPower[i]:Point('LEFT', ClassPower[i - 1], 'RIGHT', 1, 0)
		end
	end

	function ClassPower:UpdateColor(powerType)
		local color, r, g, b = NP.db.colors.power[powerType]
		if color then
			r, g, b = color.r, color.g, color.b
		else
			color = ElvUF.colors.power[powerType]
			r, g, b = unpack(color)
		end

		for i = 1, #self do
			if powerType == 'COMBO_POINTS' then
				r, g, b = NP.db.colors.classResources.comboPoints[i].r, NP.db.colors.classResources.comboPoints[i].g, NP.db.colors.classResources.comboPoints[i].b
			end

			self[i]:SetStatusBarColor(r, g, b)
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
				self[i]:Size(NP.db.classbar.width / max, NP.db.classbar.height)
				if i == 1 then
					self[i]:Point('LEFT', self, 'LEFT', 0, 0)
				else
					self[i]:Point('LEFT', self[i - 1], 'RIGHT', 1, 0)
				end
			end
		end
	end

	return ClassPower
end

function NP:Construct_Runes(nameplate)
	local Runes = CreateFrame('Frame', nameplate:GetDebugName()..'Runes', nameplate)
	Runes:SetFrameStrata(nameplate:GetFrameStrata())
	Runes:SetFrameLevel(5)
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

	Runes:Size(NP.db.classbar.width + 5, NP.db.classbar.height)
	local width = NP.db.classbar.width / 6

	for i = 1, 6 do
		Runes[i] = CreateFrame('StatusBar', nameplate:GetDebugName()..'Runes'..i, Runes)
		Runes[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
		Runes[i]:SetStatusBarColor(NP.db.colors.classResources.DEATHKNIGHT.r, NP.db.colors.classResources.DEATHKNIGHT.g, NP.db.colors.classResources.DEATHKNIGHT.b)
		Runes[i]:Size(width, NP.db.classbar.height)
		NP.StatusBars[Runes[i]] = true

		if i == 1 then
			Runes[i]:Point('LEFT', Runes, 'LEFT', 0, 0)
		else
			Runes[i]:Point('LEFT', Runes[i-1], 'RIGHT', 1, 0)
		end
	end

	return Runes
end

function NP:Update_ClassPower(nameplate)
	if nameplate.frameType == 'PLAYER' then
		if not nameplate:IsElementEnabled('ClassPower') then
			nameplate:EnableElement('ClassPower')
			nameplate.ClassPower:Show()
		end

		nameplate.ClassPower:Point('CENTER', nameplate, 'CENTER', 0, NP.db.classbar.yOffset)
	else
		if nameplate:IsElementEnabled('ClassPower') then
			nameplate:DisableElement('ClassPower')
			nameplate.ClassPower:Hide()
		end
	end
end

function NP:Update_Runes(nameplate)
	if nameplate.frameType == 'PLAYER' then
		if not nameplate:IsElementEnabled('Runes') then
			nameplate:EnableElement('Runes')
			nameplate.Runes:Show()
		end

		nameplate.Runes:Point('CENTER', nameplate, 'CENTER', 0, NP.db.classbar.yOffset)

		nameplate.sortOrder = NP.db.classbar.sortDirection

		nameplate.Runes:Size(NP.db.classbar.width + 5, NP.db.classbar.height)
		local width = NP.db.classbar.width / 6

		for i = 1, 6 do
			nameplate.Runes[i]:SetStatusBarColor(NP.db.colors.classResources.DEATHKNIGHT.r, NP.db.colors.classResources.DEATHKNIGHT.g, NP.db.colors.classResources.DEATHKNIGHT.b)
			nameplate.Runes[i]:Size(width, NP.db.classbar.height)
		end
	else
		if nameplate:IsElementEnabled('Runes') then
			nameplate:DisableElement('Runes')
			nameplate.Runes:Hide()
		end
	end
end
