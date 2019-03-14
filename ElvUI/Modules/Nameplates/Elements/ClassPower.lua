local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local ElvUF = E.oUF

local _G = _G
local unpack, max = unpack, max
local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

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

	local db = NP.db.units[self.__owner.frameType]
	local ClassColor = db and db.classpower.classColor and (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
	for i = 1, #self do
		local classColor = ClassColor or (powerType == 'COMBO_POINTS' and NP.db.colors.classResources.comboPoints[i])
		if classColor then r, g, b = classColor.r, classColor.g, classColor.b end

		self[i]:SetStatusBarColor(r, g, b)
	end
end

function NP:ClassPower_PostUpdate(Cur, Max, needUpdate)
	if Cur and Cur > 0 then
		self:Show()
	else
		self:Hide()
	end

	if needUpdate then
		local db = NP.db.units[self.__owner.frameType]
		for i = 1, Max do
			self[i]:Size(db.classpower.width / Max, db.classpower.height)
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

	for i = 1, max(MAX_POINTS[E.myclass] or 0, _G.MAX_COMBO_POINTS) do
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
	local db = NP.db.units[nameplate.frameType]

	if db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('ClassPower') then
			nameplate:EnableElement('ClassPower')
			nameplate.ClassPower:Show()
		end

		nameplate.ClassPower:Point('CENTER', nameplate, 'CENTER', 0, db.classpower.yOffset)

		local maxClassBarButtons = nameplate.ClassPower.__max

		local Width = db.classpower.width / maxClassBarButtons
		nameplate.ClassPower:Size(db.classpower.width + (maxClassBarButtons - 1), db.classpower.height)

		for i = 1, maxClassBarButtons do
			nameplate.ClassPower[i]:Size(Width, db.classpower.height)
		end
	else
		if nameplate:IsElementEnabled('ClassPower') then
			nameplate:DisableElement('ClassPower')
			nameplate.ClassPower:Hide()
		end
	end
end

function NP:Update_Runes(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('Runes') then
			nameplate:EnableElement('Runes')
			nameplate.Runes:Show()
		end

		nameplate.Runes:Point('CENTER', nameplate, 'CENTER', 0, db.classpower.yOffset)

		nameplate.sortOrder = db.classpower.sortDirection

		local width = db.classpower.width / 6
		nameplate.Runes:Size(db.classpower.width + 5, db.classpower.height)

		local runeColor = (db.classpower.classColor and (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])) or NP.db.colors.classResources.DEATHKNIGHT

		for i = 1, 6 do
			nameplate.Runes[i]:SetStatusBarColor(runeColor.r, runeColor.g, runeColor.b)
			nameplate.Runes[i]:Size(width, db.classpower.height)
		end
	else
		if nameplate:IsElementEnabled('Runes') then
			nameplate:DisableElement('Runes')
			nameplate.Runes:Hide()
		end
	end
end
