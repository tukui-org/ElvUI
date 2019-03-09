local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame
local UnitPowerType = UnitPowerType

function NP:Construct_Power(nameplate)
	local Power = CreateFrame('StatusBar', nameplate:GetDebugName()..'Power', nameplate)
	Power:SetFrameStrata(nameplate:GetFrameStrata())
	Power:SetFrameLevel(5)
	Power:CreateBackdrop('Transparent')
	Power:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))

	local statusBarTexture = Power:GetStatusBarTexture()
	statusBarTexture:SetSnapToPixelGrid(false)
	statusBarTexture:SetTexelSnappingBias(0)

	NP.StatusBars[Power] = true

	Power.frequentUpdates = true
	Power.colorTapping = false
	Power.colorClass = false
	Power.Smooth = true

	function Power:PreUpdate(unit)
		local _, pToken = UnitPowerType(unit)
		self.token = pToken

		if self.__owner.PowerColorChanged then return end

		local Color = NP.db.colors.power[pToken]
		if Color then
			self:SetStatusBarColor(Color.r, Color.g, Color.b)
		else
			Color = _G.ElvUI.oUF.colors.power[pToken]
			if Color then
				self:SetStatusBarColor(unpack(Color))
			end
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
	PowerBar:Point('TOP')
	PowerBar:Point('BOTTOM')
	PowerBar:Point('RIGHT', nameplate.Power:GetStatusBarTexture(), 'RIGHT')
	PowerBar:Width(130)
	PowerBar:SetStatusBarTexture(E.LSM:Fetch('statusbar', NP.db.statusbar))
	NP.StatusBars[PowerBar] = true

	return { mainBar = PowerBar }
end

function NP:Update_Power(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.power.enable then
		if not nameplate:IsElementEnabled('Power') then
			nameplate:EnableElement('Power')
		end

		nameplate.Power:Point('CENTER', nameplate, 'CENTER', 0, db.power.yOffset)
	else
		if nameplate:IsElementEnabled('Power') then
			nameplate:DisableElement('Power')
		end
	end

	if db.power.text.enable then
		nameplate.Power.Text:ClearAllPoints()
		nameplate.Power.Text:Point(E.InversePoints[db.power.text.position], nameplate, db.power.text.position, db.power.text.xOffset, db.power.text.yOffset)
		nameplate.Power.Text:SetFont(E.LSM:Fetch('font', db.power.text.font), db.power.text.fontSize, db.power.text.fontOutline)
		nameplate.Power.Text:Show()
	else
		nameplate.Power.Text:Hide()
	end

	nameplate:Tag(nameplate.Power.Text, db.power.text.format)

	nameplate.Power.displayAltPower = db.power.displayAltPower
	nameplate.Power.useAtlas = db.power.useAtlas
	nameplate.Power.colorClass = db.power.useClassColor or false
	nameplate.Power.width = db.power.width
	nameplate.Power.height = db.power.height
	nameplate.Power:Size(db.power.width, db.power.height)
end

function NP:Update_PowerPrediction(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.power.enable and db.power.costPrediction then
		if not nameplate:IsElementEnabled('PowerPrediction') then
			nameplate:EnableElement('PowerPrediction')
		end

		nameplate.PowerPrediction.mainBar:Width(db.power.width)
	else
		if nameplate:IsElementEnabled('PowerPrediction') then
			nameplate:DisableElement('PowerPrediction')
		end
	end
end
