local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM
local oUF = E.oUF

local _G = _G
local next, ipairs = next, ipairs
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

function NP:ClassPower_SetBarColor(bar, r, g, b)
	bar:SetStatusBarColor(r, g, b)

	if bar.bg then
		bar.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier)
	end
end

function NP:ClassPower_UpdateColor(powerType, rune)
	local color, r, g, b = NP.db.colors.classResources[E.myclass] or NP.db.colors.power[powerType]
	if color then
		r, g, b = color.r, color.g, color.b
	else
		r, g, b = unpack(oUF.colors.power[powerType])
	end

	local isRunes = powerType == 'RUNES'
	if isRunes and E.Retail and NP.db.colors.chargingRunes then
		NP:Runes_UpdateCharged(self)
	elseif isRunes and rune then
		NP:ClassPower_SetBarColor(rune, r, g, b)
	else
		local db = NP:PlateDB(self.__owner)
		local classColor = db.classpower and db.classpower.classColor and E:ClassColor(E.myclass)
		for i, bar in ipairs(self) do
			local classCombo = classColor
			or (powerType == 'COMBO_POINTS' and NP.db.colors.classResources.comboPoints[i])
			or (powerType == 'CHI' and NP.db.colors.classResources.MONK[i])
			or (isRunes and NP.db.colors.classResources.DEATHKNIGHT[bar.runeType or 0])

			if classCombo then r, g, b = classCombo.r, classCombo.g, classCombo.b end

			NP:ClassPower_SetBarColor(bar, r, g, b)
		end
	end
end

function NP:ClassPower_PostUpdate(Cur, _, needUpdate, powerType, chargedPoints)
	if Cur and Cur > 0 then
		self:Show()
	else
		self:Hide()
	end

	if needUpdate then
		NP:Update_ClassPower(self.__owner)
	end

	if powerType == 'COMBO_POINTS' and E.myclass == 'ROGUE' then
		NP.ClassPower_UpdateColor(self, powerType)

		if chargedPoints then
			local color = NP.db.colors.classResources.chargedComboPoint
			for _, chargedIndex in next, chargedPoints do
				self[chargedIndex]:SetStatusBarColor(color.r, color.g, color.b)
				self[chargedIndex].bg:SetVertexColor(color.r * NP.multiplier, color.g * NP.multiplier, color.b * NP.multiplier)
			end
		end
	end
end

function NP:Construct_ClassPower(nameplate)
	local frameName = nameplate:GetName()
	local ClassPower = CreateFrame('Frame', frameName..'ClassPower', nameplate)
	ClassPower:CreateBackdrop('Transparent', nil, nil, nil, nil, true, true)
	ClassPower:Hide()
	ClassPower:SetFrameStrata(nameplate:GetFrameStrata())
	ClassPower:SetFrameLevel(5)

	local Max = max(MAX_POINTS[E.myclass] or 0, _G.MAX_COMBO_POINTS)
	local texture = LSM:Fetch('statusbar', NP.db.statusbar)

	for i = 1, Max do
		local bar = CreateFrame('StatusBar', frameName..'ClassPower'..i, ClassPower)
		bar:SetStatusBarTexture(texture)
		bar:SetFrameStrata(nameplate:GetFrameStrata())
		bar:SetFrameLevel(6)
		NP.StatusBars[bar] = true

		bar.bg = ClassPower:CreateTexture(frameName..'ClassPower'..i..'bg', 'BORDER')
		bar.bg:SetTexture(texture)
		bar.bg:SetAllPoints()

		if nameplate == _G.ElvNP_Test then
			local combo = NP.db.colors.classResources.comboPoints[i]
			bar.bg:SetVertexColor(combo.r, combo.g, combo.b)
		end

		ClassPower[i] = bar
	end

	if nameplate == _G.ElvNP_Test then
		ClassPower.Hide = ClassPower.Show
		ClassPower:Show()
	end

	ClassPower.UpdateColor = NP.ClassPower_UpdateColor
	ClassPower.PostUpdate = NP.ClassPower_PostUpdate

	return ClassPower
end

function NP:Update_ClassPower(nameplate)
	local db = NP:PlateDB(nameplate)

	if nameplate == _G.ElvNP_Test then
		if not db.nameOnly and db.classpower and db.classpower.enable then
			NP.ClassPower_UpdateColor(nameplate.ClassPower, 'COMBO_POINTS')
			nameplate.ClassPower:SetAlpha(1)
		else
			nameplate.ClassPower:SetAlpha(0)
		end
	end

	local target = nameplate.frameType == 'TARGET'
	if (target or nameplate.frameType == 'PLAYER') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('ClassPower') then
			nameplate:EnableElement('ClassPower')
		end

		local anchor = target and NP:GetClassAnchor()
		nameplate.ClassPower:ClearAllPoints()
		nameplate.ClassPower:Point('CENTER', anchor or nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)
		nameplate.ClassPower:Size(db.classpower.width, db.classpower.height)

		for i = 1, #nameplate.ClassPower do
			nameplate.ClassPower[i]:Hide()
			nameplate.ClassPower[i].bg:Hide()
		end

		local maxButtons = nameplate.ClassPower.__max
		if maxButtons > 0 then
			local Width = db.classpower.width / maxButtons
			for i = 1, maxButtons do
				local button = nameplate.ClassPower[i]
				button:Show()
				button.bg:Show()
				button:ClearAllPoints()

				if i == 1 then
					local width = Width - (maxButtons == 6 and 2 or 0)
					button:Point('LEFT', nameplate.ClassPower, 'LEFT', 0, 0)
					button:Size(width, db.classpower.height)
				else
					button:Point('LEFT', nameplate.ClassPower[i - 1], 'RIGHT', 1, 0)
					button:Size(Width - 1, db.classpower.height)

					if i == maxButtons then
						button:Point('RIGHT', nameplate.ClassPower)
					end
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

function NP:Runes_UpdateCharged(runes)
	local colors = NP.db.colors.classResources.DEATHKNIGHT
	for _, bar in ipairs(runes) do
		local value = bar:GetValue()
		local color = colors[(value and value ~= 1 and -1) or bar.runeType or 0]
		NP:ClassPower_SetBarColor(bar, color.r, color.g, color.b)
	end
end

function NP:Runes_PostUpdate()
	self:SetShown(not UnitHasVehicleUI('player'))

	if E.Retail and NP.db.colors.chargingRunes then
		NP:Runes_UpdateCharged(self)
	end
end

function NP:Runes_PostUpdateColor(r, g, b, color, rune)
	NP.ClassPower_UpdateColor(self, 'RUNES', rune)
end

function NP:Construct_Runes(nameplate)
	local frameName = nameplate:GetName()
	local Runes = CreateFrame('Frame', frameName..'Runes', nameplate)
	Runes:SetFrameStrata(nameplate:GetFrameStrata())
	Runes:SetFrameLevel(5)
	Runes:CreateBackdrop('Transparent', nil, nil, nil, nil, true, true)
	Runes:Hide()

	Runes.PostUpdate = NP.Runes_PostUpdate
	Runes.PostUpdateColor = NP.Runes_PostUpdateColor

	local texture = LSM:Fetch('statusbar', NP.db.statusbar)
	local color = NP.db.colors.classResources.DEATHKNIGHT[0]

	for i = 1, 6 do
		local rune = CreateFrame('StatusBar', frameName..'Runes'..i, Runes)
		rune:SetStatusBarTexture(texture)
		rune:SetStatusBarColor(color.r, color.g, color.b)
		NP.StatusBars[rune] = true

		rune.bg = rune:CreateTexture(frameName..'Runes'..i..'bg', 'BORDER')
		rune.bg:SetVertexColor(color.r * NP.multiplier, color.g * NP.multiplier, color.b * NP.multiplier)
		rune.bg:SetTexture(texture)
		rune.bg:SetAllPoints()
		rune.bg.multiplier = 0.35

		Runes[i] = rune
	end

	return Runes
end

function NP:Update_Runes(nameplate)
	local db = NP:PlateDB(nameplate)

	local target = nameplate.frameType == 'TARGET'
	if (target or nameplate.frameType == 'PLAYER') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('Runes') then
			nameplate:EnableElement('Runes')
		end

		nameplate.Runes:Show()

		local anchor = target and NP:GetClassAnchor()
		nameplate.Runes:ClearAllPoints()
		nameplate.Runes:Point('CENTER', anchor or nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)

		nameplate.Runes.sortOrder = db.classpower.sortDirection

		local width = db.classpower.width / 6
		nameplate.Runes:Size(db.classpower.width, db.classpower.height)

		local classColor = db.classpower.classColor and E:ClassColor(E.myclass)

		for i = 1, 6 do
			local rune = nameplate.Runes[i]
			local color = classColor or NP.db.colors.classResources.DEATHKNIGHT[rune.runeType or 0]
			rune:SetStatusBarColor(color.r, color.g, color.b)

			if i == 1 then
				rune:Size(width, db.classpower.height)
				rune:ClearAllPoints()
				rune:Point('LEFT', nameplate.Runes, 'LEFT', 0, 0)
			else
				rune:Size(width - 1, db.classpower.height)
				rune:ClearAllPoints()
				rune:Point('LEFT', nameplate.Runes[i-1], 'RIGHT', 1, 0)

				if i == 6 then
					rune:Point('RIGHT', nameplate.Runes)
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
	local Stagger = CreateFrame('StatusBar', nameplate:GetName()..'Stagger', nameplate)
	Stagger:SetFrameStrata(nameplate:GetFrameStrata())
	Stagger:SetFrameLevel(5)
	Stagger:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
	Stagger:CreateBackdrop('Transparent', nil, nil, nil, nil, true, true)
	Stagger:Hide()

	NP.StatusBars[Stagger] = true

	return Stagger
end

function NP:Update_Stagger(nameplate)
	local db = NP:PlateDB(nameplate)

	local target = nameplate.frameType == 'TARGET'
	if (target or nameplate.frameType == 'PLAYER') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('Stagger') then
			nameplate:EnableElement('Stagger')
		end

		local anchor = target and NP:GetClassAnchor()
		nameplate.Stagger:ClearAllPoints()
		nameplate.Stagger:Point('CENTER', anchor or nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)

		nameplate.Stagger:Size(db.classpower.width, db.classpower.height)
	elseif nameplate:IsElementEnabled('Stagger') then
		nameplate:DisableElement('Stagger')
	end
end
