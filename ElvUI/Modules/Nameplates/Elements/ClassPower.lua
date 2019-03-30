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
	local color, r, g, b = NP.db.colors.classResources[E.myclass] or NP.db.colors.power[powerType]
	if color then
		r, g, b = color.r, color.g, color.b
	else
		color = ElvUF.colors.power[powerType]
		r, g, b = unpack(color)
	end

	local db = NP.db.units[self.__owner.frameType]
	local ClassColor = db and db.classpower.classColor and (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
	for i = 1, #self do
		local classColor = ClassColor or (powerType == 'COMBO_POINTS' and NP.db.colors.classResources.comboPoints[i] or powerType == 'CHI' and NP.db.colors.classResources.MONK)
		if classColor then r, g, b = classColor.r, classColor.g, classColor.b end

		self[i]:SetStatusBarColor(r, g, b)
		local bg = self[i].bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
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
		if not db then return end
		for i = 1, self.ClassMax do
			self[i]:Size(db.classpower.width / Max, db.classpower.height)
			self[i].bg:Size(db.classpower.width / Max, db.classpower.height)

			self[i]:ClearAllPoints() -- because max points might change
			if i == 1 then
				self[i]:Point('LEFT', self, 'LEFT', 0, 0)
			elseif i == Max then  -- freaky gap at end of bar
				self[i]:Point('LEFT', self[i - 1], 'RIGHT', 1, 0)
				self[i]:Point('RIGHT', self, 'RIGHT', 0, 0)
			elseif i < Max then
				self[i]:Point('LEFT', self[i - 1], 'RIGHT', 1, 0)
			else
				self[i]:Hide()
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
	ClassPower.ClassMax = max(MAX_POINTS[E.myclass] or 0, _G.MAX_COMBO_POINTS)

	for i = 1, ClassPower.ClassMax do
		ClassPower[i] = CreateFrame('StatusBar', nameplate:GetDebugName()..'ClassPower'..i, ClassPower)
		ClassPower[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
		ClassPower[i]:SetFrameStrata(nameplate:GetFrameStrata())
		ClassPower[i]:SetFrameLevel(6)
		NP.StatusBars[ClassPower[i]] = true

		local statusBarTexture = ClassPower[i]:GetStatusBarTexture()
		statusBarTexture:SetSnapToPixelGrid(false)
		statusBarTexture:SetTexelSnappingBias(0)

		ClassPower[i].bg = ClassPower:CreateTexture(nil, 'BORDER')
		ClassPower[i].bg:SetAllPoints(ClassPower[i])
		ClassPower[i].bg:SetTexture(E.media.blankTex)
		ClassPower[i].bg:SetSnapToPixelGrid(false)
		ClassPower[i].bg:SetTexelSnappingBias(0)
		ClassPower[i].bg.multiplier = .35

		if i == 1 then
			ClassPower[i]:Point('LEFT', ClassPower, 'LEFT', 0, 0)
		elseif i == ClassPower.ClassMax then -- freaky gap at end of bar
			ClassPower[i]:Point('LEFT', ClassPower[i - 1], 'RIGHT', 1, 0)
			ClassPower[i]:Point('RIGHT', ClassPower, 'RIGHT')
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

		Runes[i].bg = Runes[i]:CreateTexture(nil, 'BORDER')
		Runes[i].bg:SetAllPoints()
		Runes[i].bg:SetSnapToPixelGrid(false)
		Runes[i].bg:SetTexelSnappingBias(0)
		Runes[i].bg:SetTexture(E.media.blankTex)
		Runes[i].bg:SetVertexColor(NP.db.colors.classResources.DEATHKNIGHT.r * .35, NP.db.colors.classResources.DEATHKNIGHT.g * .35, NP.db.colors.classResources.DEATHKNIGHT.b * .35)

		if i == 1 then
			Runes[i]:Point('LEFT', Runes, 'LEFT', 0, 0)
		elseif i == 6 then
			Runes[i]:Point('LEFT', Runes[i -1], 'RIGHT', 1, 0)
			Runes[i]:Point('RIGHT')
		else
			Runes[i]:Point('LEFT', Runes[i-1], 'RIGHT', 1, 0)
		end
	end

	return Runes
end

function NP:Update_ClassPower(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'PLAYER' or nameplate.frameType == 'TARGET') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('ClassPower') then
			nameplate:EnableElement('ClassPower')
		end

		nameplate.ClassPower:Point('CENTER', nameplate, 'CENTER', 0, db.classpower.yOffset)

		local maxClassBarButtons = nameplate.ClassPower.__max

		local Width = db.classpower.width / maxClassBarButtons
		nameplate.ClassPower:Size(db.classpower.width, db.classpower.height)

		for i = 1, maxClassBarButtons do
			nameplate.ClassPower[i]:Size(Width - 1, db.classpower.height)
			nameplate.ClassPower[i].bg:Size(Width - 1, db.classpower.height)
		end
	else
		if nameplate:IsElementEnabled('ClassPower') then
			nameplate:DisableElement('ClassPower')
		end

		nameplate.ClassPower:Hide()
	end
end

function NP:Update_Runes(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'PLAYER' or nameplate.frameType == 'TARGET') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('Runes') then
			nameplate:EnableElement('Runes')
		end

		nameplate.Runes:Show()

		nameplate.Runes:Point('CENTER', nameplate, 'CENTER', 0, db.classpower.yOffset)

		nameplate.sortOrder = db.classpower.sortDirection

		local width = db.classpower.width / 6
		nameplate.Runes:Size(db.classpower.width, db.classpower.height)

		local runeColor = (db.classpower.classColor and (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])) or NP.db.colors.classResources.DEATHKNIGHT

		for i = 1, 6 do
			nameplate.Runes[i]:SetStatusBarColor(runeColor.r, runeColor.g, runeColor.b)
			nameplate.Runes[i]:Size(width - 1, db.classpower.height)
			nameplate.Runes[i].bg:Size(width - 1, db.classpower.height)
		end
	else
		if nameplate:IsElementEnabled('Runes') then
			nameplate:DisableElement('Runes')
		end

		nameplate.Runes:Hide()
	end
end
