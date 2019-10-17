local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local oUF = E.oUF

local _G = _G
local unpack, max = unpack, max
local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI

local MAX_POINTS = {
	DRUID = 5,
	DEATHKNIGHT = 6,
	MAGE = 4,
	MONK = 6,
	PALADIN = 5,
	ROGUE = 6,
	WARLOCK = 5
}

function NP:ClassPower_UpdateColor(powerType)
	local color, r, g, b = NP.db.colors.classResources[E.myclass] or NP.db.colors.power[powerType]
	if color then
		r, g, b = color.r, color.g, color.b
	else
		color = oUF.colors.power[powerType]
		r, g, b = unpack(color)
	end

	local db = NP.db.units[self.__owner.frameType]
	local ClassColor = db and db.classpower.classColor and E:ClassColor(E.myclass)
	for i = 1, #self do
		local classColor = ClassColor or (powerType == 'COMBO_POINTS' and NP.db.colors.classResources.comboPoints[i] or powerType == 'CHI' and NP.db.colors.classResources.MONK[i])
		if classColor then r, g, b = classColor.r, classColor.g, classColor.b end

		self[i]:SetStatusBarColor(r, g, b)

		if self[i].bg then self[i].bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier) end
	end
end

function NP:ClassPower_PostUpdate(Cur, _, needUpdate)
	if Cur and Cur > 0 then
		self:Show()
	else
		self:Hide()
	end

	if needUpdate then
		NP:Update_ClassPower(self.__owner)
	end
end

function NP:Construct_ClassPower(nameplate)
	local ClassPower = CreateFrame('Frame', nameplate:GetDebugName()..'ClassPower', nameplate)
	ClassPower:CreateBackdrop('Transparent')
	ClassPower:Hide()
	ClassPower:SetFrameStrata(nameplate:GetFrameStrata())
	ClassPower:SetFrameLevel(5)

	local Max = max(MAX_POINTS[E.myclass] or 0, _G.MAX_COMBO_POINTS)
	local texture = E.LSM:Fetch('statusbar', NP.db.statusbar)

	for i = 1, Max do
		ClassPower[i] = CreateFrame('StatusBar', nameplate:GetDebugName()..'ClassPower'..i, ClassPower)
		ClassPower[i]:SetStatusBarTexture(texture)
		ClassPower[i]:SetFrameStrata(nameplate:GetFrameStrata())
		ClassPower[i]:SetFrameLevel(6)
		NP.StatusBars[ClassPower[i]] = true

		ClassPower[i].bg = ClassPower:CreateTexture(nameplate:GetDebugName()..'ClassPower'..i..'bg', 'BORDER')
		ClassPower[i].bg:SetAllPoints(ClassPower[i])
		ClassPower[i].bg:SetTexture(texture)
	end

	if nameplate == _G.ElvNP_Test then
		ClassPower.Hide = ClassPower.Show
		ClassPower:Show()
		for i = 1, Max do
			ClassPower[i]:SetStatusBarTexture(texture)
			ClassPower[i].bg:SetTexture(texture)
			ClassPower[i].bg:SetVertexColor(NP.db.colors.classResources.comboPoints[i].r, NP.db.colors.classResources.comboPoints[i].g, NP.db.colors.classResources.comboPoints[i].b)
		end
	end

	ClassPower.UpdateColor = NP.ClassPower_UpdateColor
	ClassPower.PostUpdate = NP.ClassPower_PostUpdate

	return ClassPower
end

function NP:Update_ClassPower(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'PLAYER' or nameplate.frameType == 'TARGET') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('ClassPower') then
			nameplate:EnableElement('ClassPower')
		end

		nameplate.ClassPower:ClearAllPoints()
		nameplate.ClassPower:Point('CENTER', nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)

		local maxClassBarButtons = nameplate.ClassPower.__max

		local Width = db.classpower.width / maxClassBarButtons
		nameplate.ClassPower:Size(db.classpower.width, db.classpower.height)

		for i = 1, #nameplate.ClassPower do
			nameplate.ClassPower[i]:Hide()
			nameplate.ClassPower[i].bg:Hide()
		end

		for i = 1, maxClassBarButtons do
			nameplate.ClassPower[i]:Show()
			nameplate.ClassPower[i].bg:Show()
			nameplate.ClassPower[i]:ClearAllPoints()

			if i == 1 then
				nameplate.ClassPower[i]:Size(Width - (maxClassBarButtons == 6 and 2 or 0), db.classpower.height)
				nameplate.ClassPower[i].bg:Size(Width - (maxClassBarButtons == 6 and 2 or 0), db.classpower.height)

				nameplate.ClassPower[i]:ClearAllPoints()
				nameplate.ClassPower[i]:Point('LEFT', nameplate.ClassPower, 'LEFT', 0, 0)
			else
				nameplate.ClassPower[i]:Size(Width - 1, db.classpower.height)
				nameplate.ClassPower[i].bg:Size(Width - 1, db.classpower.height)

				nameplate.ClassPower[i]:ClearAllPoints()
				nameplate.ClassPower[i]:Point('LEFT', nameplate.ClassPower[i - 1], 'RIGHT', 1, 0)

				if i == maxClassBarButtons then
					nameplate.ClassPower[i]:Point('RIGHT', nameplate.ClassPower)
				end
			end
		end
	else
		if nameplate:IsElementEnabled('ClassPower') then
			nameplate:DisableElement('ClassPower')
		end

		nameplate.ClassPower:Hide()
	end
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

	local texture = E.LSM:Fetch('statusbar', NP.db.statusbar)
	local color = NP.db.colors.classResources.DEATHKNIGHT

	for i = 1, 6 do
		Runes[i] = CreateFrame('StatusBar', nameplate:GetDebugName()..'Runes'..i, Runes)
		Runes[i]:SetStatusBarTexture(texture)
		Runes[i]:SetStatusBarColor(color.r, color.g, color.b)
		NP.StatusBars[Runes[i]] = true

		Runes[i].bg = Runes[i]:CreateTexture(nameplate:GetDebugName()..'Runes'..i..'bg', 'BORDER')
		Runes[i].bg:SetVertexColor(color.r * NP.multiplier, color.g * NP.multiplier, color.b * NP.multiplier)
		Runes[i].bg:SetTexture(texture)
		Runes[i].bg:SetAllPoints()
	end

	return Runes
end

function NP:Update_Runes(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'PLAYER' or nameplate.frameType == 'TARGET') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('Runes') then
			nameplate:EnableElement('Runes')
		end

		nameplate.Runes:Show()
		nameplate.Runes:ClearAllPoints()
		nameplate.Runes:Point('CENTER', nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)

		nameplate.Runes.sortOrder = db.classpower.sortDirection

		local width = db.classpower.width / 6
		nameplate.Runes:Size(db.classpower.width, db.classpower.height)

		local runeColor = (db.classpower.classColor and E:ClassColor(E.myclass)) or NP.db.colors.classResources.DEATHKNIGHT

		for i = 1, 6 do
			nameplate.Runes[i]:SetStatusBarColor(runeColor.r, runeColor.g, runeColor.b)

			if i == 1 then
				nameplate.Runes[i]:Size(width, db.classpower.height)
				nameplate.Runes[i].bg:Size(width, db.classpower.height)

				nameplate.Runes[i]:ClearAllPoints()
				nameplate.Runes[i]:Point('LEFT', nameplate.Runes, 'LEFT', 0, 0)
			else
				nameplate.Runes[i]:Size(width - 1, db.classpower.height)
				nameplate.Runes[i].bg:Size(width - 1, db.classpower.height)

				nameplate.Runes[i]:ClearAllPoints()
				nameplate.Runes[i]:Point('LEFT', nameplate.Runes[i-1], 'RIGHT', 1, 0)

				if i == 6 then
					nameplate.Runes[6]:Point('RIGHT', nameplate.Runes)
				end
			end
		end
	else
		if nameplate:IsElementEnabled('Runes') then
			nameplate:DisableElement('Runes')
		end

		nameplate.Runes:Hide()
	end
end

function NP:Construct_Stagger(nameplate)
    local Stagger = CreateFrame('StatusBar', nameplate:GetDebugName()..'Stagger', nameplate)
	Stagger:SetFrameStrata(nameplate:GetFrameStrata())
	Stagger:SetFrameLevel(5)
	Stagger:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
	Stagger:CreateBackdrop('Transparent')
	Stagger:Hide()

	NP.StatusBars[Stagger] = true

	return Stagger
end

function NP:Update_Stagger(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'PLAYER' or nameplate.frameType == 'TARGET') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('Stagger') then
			nameplate:EnableElement('Stagger')
		end

		nameplate.Stagger:ClearAllPoints()
		nameplate.Stagger:Point('CENTER', nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)
		nameplate.Stagger:Size(db.classpower.width, db.classpower.height)
	else
		if nameplate:IsElementEnabled('Stagger') then
			nameplate:DisableElement('Stagger')
		end
	end
end
