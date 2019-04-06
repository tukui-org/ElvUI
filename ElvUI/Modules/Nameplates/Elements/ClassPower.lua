local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local ElvUF = E.oUF

local _G = _G
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
	local color, r, g, b = NP.db.colors.classResources[E.myclass] or NP.db.colors.power[powerType]
	if color then
		r, g, b = color.r, color.g, color.b
	else
		color = ElvUF.colors.power[powerType]
		r, g, b = unpack(color)
	end

	local db = NP.db.units[self.__owner.frameType]
	local ClassColor = db and db.classpower.classColor and (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or _G.RAID_CLASS_COLORS[E.myclass])
	for i = 1, #self do
		local classColor = ClassColor or (powerType == 'COMBO_POINTS' and NP.db.colors.classResources.comboPoints[i] or powerType == 'CHI' and NP.db.colors.classResources.MONK[i])
		if classColor then r, g, b = classColor.r, classColor.g, classColor.b end

		self[i]:SetStatusBarColor(r, g, b)
		local bg = self[i].bg
		if(bg) then
			local mu = bg.multiplier or 1
			bg:SetColorTexture(r * mu, g * mu, b * mu)
		end
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

	for i = 1, Max do
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
		ClassPower[i].bg:SetSnapToPixelGrid(false)
		ClassPower[i].bg:SetTexelSnappingBias(0)
		ClassPower[i].bg.multiplier = .35
	end

	if nameplate == _G.ElvNP_Test then
		ClassPower.Hide = ClassPower.Show
		ClassPower:Show()
		for i = 1, Max do
			ClassPower[i]:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
			ClassPower[i].bg:SetColorTexture(NP.db.colors.classResources.comboPoints[i].r, NP.db.colors.classResources.comboPoints[i].g, NP.db.colors.classResources.comboPoints[i].b)
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
				nameplate.ClassPower[i]:Point('LEFT', nameplate.ClassPower, 'LEFT', 0, 0)
			else
				nameplate.ClassPower[i]:Size(Width - 1, db.classpower.height)
				nameplate.ClassPower[i].bg:Size(Width - 1, db.classpower.height)
				nameplate.ClassPower[i]:Point('LEFT', nameplate.ClassPower[i - 1], 'RIGHT', 1, 0)
			end
		end

		nameplate.ClassPower[maxClassBarButtons]:Point('RIGHT', nameplate.ClassPower)
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
		nameplate.Runes:Point('CENTER', nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)

		nameplate.Runes.sortOrder = db.classpower.sortDirection

		local width = db.classpower.width / 6
		nameplate.Runes:Size(db.classpower.width, db.classpower.height)

		local runeColor = (db.classpower.classColor and (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or _G.RAID_CLASS_COLORS[E.myclass])) or NP.db.colors.classResources.DEATHKNIGHT

		for i = 1, 6 do
			nameplate.Runes[i]:SetStatusBarColor(runeColor.r, runeColor.g, runeColor.b)

			if i == 1 then
				nameplate.Runes[i]:Point('LEFT', nameplate.Runes, 'LEFT', 0, 0)
				nameplate.Runes[i]:Size(width, db.classpower.height)
				nameplate.Runes[i].bg:Size(width, db.classpower.height)
			else
				nameplate.Runes[i]:Point('LEFT', nameplate.Runes[i-1], 'RIGHT', 1, 0)
				nameplate.Runes[i]:Size(width - 1, db.classpower.height)
				nameplate.Runes[i].bg:Size(width - 1, db.classpower.height)
			end
		end

		nameplate.Runes[6]:Point('RIGHT', nameplate.Runes)
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
	Stagger:CreateBackdrop('Transparent')
	Stagger:Hide()

	return Stagger
end

function NP:Update_Stagger(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if (nameplate.frameType == 'PLAYER' or nameplate.frameType == 'TARGET') and db.classpower and db.classpower.enable then
		if not nameplate:IsElementEnabled('Stagger') then
			nameplate:EnableElement('Stagger')
		end

		nameplate.Stagger:Show()
		nameplate.Stagger:Point('CENTER', nameplate, 'CENTER', db.classpower.xOffset, db.classpower.yOffset)
		nameplate.Stagger:Size(db.classpower.width, db.classpower.height)
	else
		if nameplate:IsElementEnabled('Stagger') then
			nameplate:DisableElement('Stagger')
		end

		nameplate.Stagger:Hide()
	end
end
