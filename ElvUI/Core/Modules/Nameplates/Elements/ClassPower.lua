local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local _G = _G
local max, next, ipairs = max, next, ipairs

local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local MAX_POINTS = { -- match to UF.classMaxResourceBar
	DEATHKNIGHT	= max(6, MAX_COMBO_POINTS),
	PALADIN		= max(5, MAX_COMBO_POINTS),
	WARLOCK		= max(5, MAX_COMBO_POINTS),
	MONK		= max(6, MAX_COMBO_POINTS),
	MAGE		= max(4, MAX_COMBO_POINTS),
	ROGUE		= max(7, MAX_COMBO_POINTS),
	DRUID		= max(5, MAX_COMBO_POINTS)
}

function NP:ClassPower_SetBarColor(bar, r, g, b)
	bar:SetStatusBarColor(r, g, b)

	if bar.bg then
		bar.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier)
	end
end

function NP:ClassPower_UpdateColor(powerType, rune)
	local isRunes = powerType == 'RUNES'

	local classPower = self.classColor
	local colors = NP.db.colors.classResources
	local fallback = NP.db.colors.power[powerType]

	if isRunes and E.Retail and NP.db.colors.chargingRunes then
		NP:Runes_UpdateCharged(self)
	elseif isRunes and rune and not classPower then
		local color = colors.DEATHKNIGHT[rune.runeType or 0]
		NP:ClassPower_SetBarColor(rune, color.r, color.g, color.b)
	else
		local classColor = not classPower and ((isRunes and colors.DEATHKNIGHT) or (powerType == 'COMBO_POINTS' and colors.comboPoints) or (powerType == 'CHI' and colors.MONK))
		for i, bar in ipairs(self) do
			local color = classPower or (isRunes and classColor[bar.runeType or 0]) or (classColor and classColor[i]) or colors[E.myclass] or fallback
			NP:ClassPower_SetBarColor(bar, color.r, color.g, color.b)
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

	local texture = LSM:Fetch('statusbar', NP.db.statusbar)
	local total = MAX_POINTS[E.myclass] or 0

	for i = 1, total do
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

		nameplate.ClassPower.classColor = db.classpower.classColor and E:ClassColor(E.myclass)

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
	local classPower = runes.classColor
	local colors = NP.db.colors.classResources.DEATHKNIGHT
	for _, bar in ipairs(runes) do
		local value = bar:GetValue()
		local color = (value == 1 and classPower) or colors[(value and value ~= 1 and -1) or bar.runeType or 0]
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

		local anchor = target and NP:GetClassAnchor()
		nameplate.Runes:ClearAllPoints()
		nameplate.Runes:Point('CENTER', anchor or nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)
		nameplate.Runes:Show()

		nameplate.Runes.classColor = E.Retail and db.classpower.classColor and E:ClassColor(E.myclass)
		nameplate.Runes.sortOrder = (db.classpower.sortDirection ~= 'NONE') and db.classpower.sortDirection
		nameplate.Runes.colorSpec = E.Retail and NP.db.colors.runeBySpec

		local width = db.classpower.width / 6
		nameplate.Runes:Size(db.classpower.width, db.classpower.height)

		for i = 1, 6 do
			local rune = nameplate.Runes[i]
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
