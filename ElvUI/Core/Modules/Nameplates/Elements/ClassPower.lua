local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local max, next, ipairs = max, next, ipairs

local CreateFrame = CreateFrame
local UnitHasVehicleUI = UnitHasVehicleUI
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

function NP:ClassPower_SetBarColor(bar, r, g, b)
	bar:SetStatusBarColor(r, g, b)

	if bar.bg then
		bar.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier)
	end
end

function NP:ClassPower_UpdateColor(powerType, rune)
	local isRunes = powerType == 'RUNES'
	local colors, powers, fallback = UF:ClassPower_GetColor(NP.db.colors, powerType)
	if isRunes and NP.db.colors.chargingRunes then
		NP:Runes_UpdateCharged(self, rune)
	elseif isRunes and rune and not self.classColor then
		local color = UF:ClassPower_BarColor(isRunes, rune)
		NP:ClassPower_SetBarColor(rune, color.r, color.g, color.b)
	else
		for index, bar in ipairs(self) do
			local color = self.classColor or UF:ClassPower_BarColor(bar, index, colors, powers, isRunes)
			if not color or not color.r then
				NP:ClassPower_SetBarColor(bar, fallback.r, fallback.g, fallback.b)
			else
				NP:ClassPower_SetBarColor(bar, color.r, color.g, color.b)
			end
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
	local containerName = nameplate.frameName..'ClassPower'
	local ClassPower = CreateFrame('Frame', containerName, nameplate)
	ClassPower:CreateBackdrop('Transparent', nil, nil, nil, nil, true)
	ClassPower:Hide()
	ClassPower:SetFrameStrata(nameplate:GetFrameStrata())
	ClassPower:SetFrameLevel(5)

	local texture = LSM:Fetch('statusbar', NP.db.statusbar)
	local total = max(UF.classMaxResourceBar[E.myclass] or 0, MAX_COMBO_POINTS)

	for i = 1, total do
		local barName = containerName..i
		local bar = CreateFrame('StatusBar', barName, ClassPower)
		bar:SetStatusBarTexture(texture)
		bar:SetFrameStrata(nameplate:GetFrameStrata())
		bar:SetFrameLevel(6)
		NP.StatusBars[bar] = 'classpower'

		bar.bg = ClassPower:CreateTexture(barName..'bg', 'BORDER')
		bar.bg:SetTexture(texture)
		bar.bg:SetAllPoints()

		if nameplate == NP.TestFrame then
			local combo = NP.db.colors.classResources.comboPoints[i]
			if combo then
				bar.bg:SetVertexColor(combo.r, combo.g, combo.b)
			end
		end

		ClassPower[i] = bar
	end

	if nameplate == NP.TestFrame then
		ClassPower.Hide = ClassPower.Show
		ClassPower:Show()
	end

	ClassPower.UpdateColor = NP.ClassPower_UpdateColor
	ClassPower.PostUpdate = NP.ClassPower_PostUpdate

	return ClassPower
end

function NP:Update_ClassPower(nameplate)
	local db = NP:PlateDB(nameplate)

	if nameplate == NP.TestFrame then
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

		nameplate.ClassPower.classColor = db.classpower.classColor and E.myClassColor

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

function NP:Runes_UpdateCharged(runes, rune)
	local colors = NP.db.colors.classResources.DEATHKNIGHT
	local classColor = (runes and runes.classColor) or (rune and rune.__owner and rune.__owner.classColor)

	if rune then
		NP:ClassPower_SetBarColor(rune, UF:Runes_GetColor(rune, colors, classColor))
	elseif runes then
		for _, bar in ipairs(runes) do
			NP:ClassPower_SetBarColor(bar, UF:Runes_GetColor(bar, colors, classColor))
		end
	end
end

function NP:Runes_PostUpdate()
	self:SetShown(not UnitHasVehicleUI('player'))

	if NP.db.colors.chargingRunes then
		NP:Runes_UpdateCharged(self)
	end
end

function NP:Runes_UpdateChargedColor()
	if NP.db.colors.chargingRunes then
		NP:Runes_UpdateCharged(nil, self)
	end
end

function NP:Runes_PostUpdateColor(r, g, b, color, rune)
	NP.ClassPower_UpdateColor(self, 'RUNES', rune)
end

function NP:Construct_Runes(nameplate)
	local containerName = nameplate.frameName..'Runes'
	local Runes = CreateFrame('Frame', containerName, nameplate)
	Runes:SetFrameStrata(nameplate:GetFrameStrata())
	Runes:SetFrameLevel(5)
	Runes:CreateBackdrop('Transparent', nil, nil, nil, nil, true)
	Runes:Hide()

	Runes.PostUpdate = NP.Runes_PostUpdate
	Runes.PostUpdateColor = NP.Runes_PostUpdateColor

	local texture = LSM:Fetch('statusbar', NP.db.statusbar)
	local color = NP.db.colors.classResources.DEATHKNIGHT[0]

	for i = 1, 6 do
		local barName = containerName..i
		local rune = CreateFrame('StatusBar', barName, Runes)
		rune:SetStatusBarTexture(texture)
		rune:SetStatusBarColor(color.r, color.g, color.b)
		rune.PostUpdateColor = NP.Runes_UpdateChargedColor
		rune.__owner = Runes
		NP.StatusBars[rune] = 'runes'

		rune.bg = rune:CreateTexture(barName..'bg', 'BORDER')
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

		nameplate.Runes.classColor = E.Retail and db.classpower.classColor and E.myClassColor
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
	local Stagger = CreateFrame('StatusBar', nameplate.frameName..'Stagger', nameplate)
	Stagger:SetFrameStrata(nameplate:GetFrameStrata())
	Stagger:SetFrameLevel(5)
	Stagger:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
	Stagger:CreateBackdrop('Transparent', nil, nil, nil, nil, true)
	Stagger:Hide()

	NP.StatusBars[Stagger] = 'stagger'

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
