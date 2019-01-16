local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local NP = E:GetModule('NamePlates')

function NP:Construct_Power(nameplate)
	local Power = CreateFrame('StatusBar', nameplate:GetDebugName()..'Power', nameplate)
	Power:SetFrameStrata(nameplate:GetFrameStrata())
	Power:SetFrameLevel(5)
	Power:CreateBackdrop('Transparent')
	Power:SetPoint('TOP', nameplate.Health, 'TOP', 0, -14)
	Power:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))
	NP.StatusBars[Power] = true

	Power.frequentUpdates = true
	Power.colorTapping = false
	Power.colorClass = false
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

		if (db.powerbar and db.powerbar.hideWhenEmpty) and ((cur == 0 and min == 0) or (min == 0 and max == 0)) then
			self:Hide()
		else
			self:PreUpdate(unit)
			self:Show()
		end
	end

	return Power
end

function NP:Construct_PowerPrediction(nameplate)
	local PowerBar = CreateFrame('StatusBar', nameplate:GetDebugName()..'PowerPrediction', nameplate.Power)
	PowerBar:SetReverseFill(true)
	PowerBar:SetPoint('TOP')
	PowerBar:SetPoint('BOTTOM')
	PowerBar:SetPoint('RIGHT', nameplate.Power:GetStatusBarTexture(), 'RIGHT')
	PowerBar:SetWidth(130)
	PowerBar:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
	NP.StatusBars[PowerBar] = true

	return { mainBar = PowerBar }
end

function NP:Update_Power(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.powerbar.enable then
		if not nameplate:IsElementEnabled('Power') then
			nameplate:EnableElement('Power')
		end
	else
		if nameplate:IsElementEnabled('Power') then
			nameplate:DisableElement('Power')
		end
	end

	if db.powerbar.text.enable then
		nameplate.Power.Text:Show()
	else
		nameplate.Power.Text:Hide()
	end

	nameplate.Power.colorClass = db.powerbar.useClassColor or false
	nameplate.Power.width = db.powerbar.width
	nameplate.Power.height = db.powerbar.height
	nameplate.Power:SetSize(db.powerbar.width, db.powerbar.height)
end

function NP:Update_PowerPrediction(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.powerbar.enable and db.powerbar.costPrediction then
		if not nameplate:IsElementEnabled('PowerPrediction') then
			nameplate:EnableElement('PowerPrediction')
		end

		nameplate.PowerPrediction.mainBar:SetWidth(db.powerbar.width)
	else
		if not nameplate:IsElementEnabled('PowerPrediction') then
			nameplate:DisableElement('PowerPrediction')
		end
	end
end