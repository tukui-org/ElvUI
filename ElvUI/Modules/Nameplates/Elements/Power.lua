local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_PowerBar(nameplate)
	local Power = CreateFrame('StatusBar', nil, nameplate)
	Power:SetFrameStrata(nameplate:GetFrameStrata())
	Power:SetFrameLevel(1)
	Power:CreateBackdrop('Transparent')
	Power:SetPoint('TOP', nameplate.Health, 'TOP', 0, -14)
	Power:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', self.db.statusbar))

	Power.frequentUpdates = true
	Power.colorTapping = true
	Power.colorClass = true
	Power.Smooth = true
	Power.displayAltPower = true
	Power.useAtlas = true

	function Power:PreUpdate(unit)
		local _, pToken = UnitPowerType(unit)
		local Color = _G.ElvUI.oUF.colors.power[pToken]

		if Color then
			self:SetStatusBarColor(unpack(Color))
		end
	end

	function Power:PostUpdate(unit, cur, min, max)
		local db = NP.db.units[self.__owner.frameType]
		if not db then return end

		if db.powerbar.hideWhenEmpty and ((cur == 0 and min == 0) or (min == 0 and max == 0)) then
			self:Hide()
		else
			self:PreUpdate(unit)
			self:Show()
		end
	end

	return Power
end

function NP:Construct_PowerPrediction(nameplate)
	local PowerBar = CreateFrame('StatusBar', nil, nameplate.Power)
	PowerBar:SetReverseFill(true)
	PowerBar:SetPoint('TOP')
	PowerBar:SetPoint('BOTTOM')
	PowerBar:SetPoint('RIGHT', nameplate.Power:GetStatusBarTexture(), 'RIGHT')
	PowerBar:SetWidth(130)
	PowerBar:SetStatusBarTexture(E.LSM:Fetch('statusbar', self.db.statusbar))

	return { mainBar = PowerBar }
end

function NP:Update_Power(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.powerbar.enable then
		nameplate:EnableElement('Power')
	else
		nameplate:DisableElement('Power')
	end

	if db.powerbar.text.enable then
		nameplate.Power.Text:Show()
	else
		nameplate.Power.Text:Hide()
	end

	nameplate.Power.width = db.powerbar.width
	nameplate.Power.height = db.powerbar.height
	nameplate.Power:SetSize(db.powerbar.width, db.powerbar.height)
end

function NP:Update_PowerPrediction(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.powerbar.enable and db.powerbar.costPrediction then
		nameplate:EnableElement('PowerPrediction')
	else
		nameplate:DisableElement('PowerPrediction')
	end
end