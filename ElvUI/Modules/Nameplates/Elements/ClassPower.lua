local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ElvUF = E.oUF

local NP = E:GetModule('NamePlates')

local unpack, max = unpack, max
local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI

local MAX_POINTS = {
	['DRUID'] = 5,
	['DEATHKNIGHT'] = 6,
	['MAGE'] = 4,
	['MONK'] = 6,
	['PALADIN'] = 5,
	['ROGUE'] = 6,
	['WARLOCK'] = 5
}

function NP:ClassPower_UpdateColor(powerType)
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

function NP:ClassPower_PostUpdate(cur, max, needUpdate, powerType)
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

function NP:Construct_ClassPower(nameplate)
	local ClassPower = CreateFrame('Frame', nameplate:GetDebugName()..'ClassPower', nameplate)
	ClassPower:Hide()
	ClassPower:SetFrameStrata(nameplate:GetFrameStrata())
	ClassPower:SetFrameLevel(5)
	ClassPower:CreateBackdrop('Transparent')

	for i = 1, max(MAX_POINTS[E.myclass] or 0, MAX_COMBO_POINTS) do
		ClassPower[i] = CreateFrame('StatusBar', nameplate:GetDebugName()..'ClassPower'..i, ClassPower)
		ClassPower[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
		NP.StatusBars[ClassPower[i]] = true

		local statusBarTexture = ClassPower[i]:GetStatusBarTexture()
		statusBarTexture:SetSnapToPixelGrid(false)
		statusBarTexture:SetTexelSnappingBias(0)

		if i == 1 then
			ClassPower[i]:Point('LEFT', ClassPower, 'LEFT', 0, 0)
		else
			ClassPower[i]:Point('LEFT', ClassPower[i - 1], 'RIGHT', 1, 0)
		end
	end

	ClassPower.UpdateColor = NP.ClassPower_UpdateColor
	ClassPower.PostUpdate = NP.ClassPower_PostUpdate

	return ClassPower
end

function NP:Runes_PostUpdate()
	if UnitHasVehicleUI('player') then
		self:Hide()
	else
		self:Show()
	end
end

function NP:Construct_Runes(nameplate)
	local Runes = CreateFrame('Frame', nameplate:GetDebugName()..'Runes', nameplate)
	Runes:SetFrameStrata(nameplate:GetFrameStrata())
	Runes:SetFrameLevel(5)
	Runes:CreateBackdrop('Transparent')
	Runes:Hide()

	Runes.UpdateColor = E.noop
	Runes.PostUpdate = NP.Runes_PostUpdate

	for i = 1, 6 do
		Runes[i] = CreateFrame('StatusBar', nameplate:GetDebugName()..'Runes'..i, Runes)
		Runes[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
		Runes[i]:SetStatusBarColor(NP.db.colors.classResources.DEATHKNIGHT.r, NP.db.colors.classResources.DEATHKNIGHT.g, NP.db.colors.classResources.DEATHKNIGHT.b)
		NP.StatusBars[Runes[i]] = true

		local statusBarTexture = Runes[i]:GetStatusBarTexture()
		statusBarTexture:SetSnapToPixelGrid(false)
		statusBarTexture:SetTexelSnappingBias(0)

		if i == 1 then
			Runes[i]:Point('LEFT', Runes, 'LEFT', 0, 0)
		else
			Runes[i]:Point('LEFT', Runes[i-1], 'RIGHT', 1, 0)
		end
	end

	return Runes
end

function NP:Update_ClassPower(nameplate)
	if nameplate.frameType == 'PLAYER' and NP.db.classbar.enable then
		if not nameplate:IsElementEnabled('ClassPower') then
			nameplate:EnableElement('ClassPower')
			nameplate.ClassPower:Show()
		end

		nameplate.ClassPower:Point('CENTER', nameplate, 'CENTER', 0, NP.db.classbar.yOffset)

		local maxClassBarButtons = nameplate.ClassPower.__max

		local Width = NP.db.classbar.width / maxClassBarButtons
		nameplate.ClassPower:Size(NP.db.classbar.width + (maxClassBarButtons - 1), NP.db.classbar.height)

		for i = 1, maxClassBarButtons do
			nameplate.ClassPower[i]:Size(Width, NP.db.classbar.height)
		end
	else
		if nameplate:IsElementEnabled('ClassPower') then
			nameplate:DisableElement('ClassPower')
			nameplate.ClassPower:Hide()
		end
	end
end

function NP:Update_Runes(nameplate)
	if nameplate.frameType == 'PLAYER' and NP.db.classbar.enable then
		if not nameplate:IsElementEnabled('Runes') then
			nameplate:EnableElement('Runes')
			nameplate.Runes:Show()
		end

		nameplate.Runes:Point('CENTER', nameplate, 'CENTER', 0, NP.db.classbar.yOffset)

		nameplate.sortOrder = NP.db.classbar.sortDirection

		local width = NP.db.classbar.width / 6
		nameplate.Runes:Size(NP.db.classbar.width + 5, NP.db.classbar.height)

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
