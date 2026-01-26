local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local unpack = unpack

local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local CreateFrame = CreateFrame
local UnitPowerType = UnitPowerType

local StatusBarInterpolation = Enum.StatusBarInterpolation
local POWERTYPE_ALTERNATE = Enum.PowerType.Alternate or 10

function NP:Power_UpdateColor(_, unit)
	if self.unit ~= unit then return end

	local element = self.Power
	local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)
	element.token = ptoken

	local Selection = element.colorSelection and NP:UnitSelectionType(unit, element.considerSelectionInCombatHostile)

	local r, g, b, color, atlas
	if element.colorDisconnected and not UnitIsConnected(unit) then
		color = self.colors.disconnected
	elseif element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
		color = self.colors.tapped
	elseif element.colorPower then
		if element.displayType ~= POWERTYPE_ALTERNATE then
			color = NP.Colors.power[ptoken or ptype]

			if not color then
				if element.GetAlternativeColor then
					r, g, b = element:GetAlternativeColor(unit, ptype, ptoken, altR, altG, altB)
				elseif altR then
					r, g, b = altR, altG, altB
					if r > 1 or g > 1 or b > 1 then -- BUG: As of 7.0.3, altR, altG, altB may be in 0-1 or 0-255 range.
						r, g, b = r / 255, g / 255, b / 255
					end
				end
			end
		else
			color = NP.Colors.power.ALT_POWER
		end

		if element.useAtlas and color and color.atlas then
			atlas = color.atlas
		end
	elseif (element.colorClass and self.isPlayer) or (element.colorClassNPC and not self.isPlayer) or (element.colorClassPet and UnitPlayerControlled(unit) and not self.isPlayer) then
		local _, class = UnitClass(unit)
		color = self.colors.class[class]
	elseif Selection then
		color = NP.Colors.selection[Selection]
	elseif element.colorReaction and UnitReaction(unit, 'player') then
		color = NP.Colors.reactions[UnitReaction(unit, 'player')]
	elseif element.colorSmooth then
		if E.Retail then
			local curve = self.colors.power.MANA:GetCurve()
			if curve then
				color = curve:Evaluate(1)
			end
		else
			local adjust = 0 - (element.min or 0)
			r, g, b = self:ColorGradient((element.cur or 1) + adjust, (element.max or 1) + adjust, unpack(element.smoothGradient or self.colors.smooth))
		end
	end

	if atlas then
		element:SetStatusBarTexture(atlas)
		element:GetStatusBarTexture():SetVertexColor(1, 1, 1)
	elseif b then
		element:GetStatusBarTexture():SetVertexColor(r, g, b)
	elseif color then
		element:GetStatusBarTexture():SetVertexColor(color:GetRGB())
	end

	if element.bg and b then
		element.bg:SetVertexColor(r, g, b, NP.multiplier)
	end

	if element.PostUpdateColor then
		element:PostUpdateColor(unit, color)
	end
end

function NP:Power_PostUpdate(_, cur) --unit, cur, min, max
	local db = NP:PlateDB(self.__owner)
	if not db.enable then return end

	if self.__owner.frameType ~= 'PLAYER' and db.power.displayAltPower and not self.displayType then
		self:Hide()
		return
	end

	if db.power and db.power.enable and db.power.hideWhenEmpty and E:NotSecretValue(cur) and (cur == 0) then
		self:Hide()
	else
		self:Show()
	end
end

function NP:Construct_Power(nameplate)
	local Power = CreateFrame('StatusBar', nameplate.frameName..'Power', nameplate)
	Power:SetFrameStrata(nameplate:GetFrameStrata())
	Power:SetFrameLevel(5)
	Power:CreateBackdrop('Transparent', nil, nil, nil, nil, true)

	NP.StatusBars[Power] = 'power'

	Power.colorTapping = false
	Power.colorClass = false

	Power.PostUpdate = NP.Power_PostUpdate
	Power.UpdateColor = NP.Power_UpdateColor

	UF:Construct_ClipFrame(nameplate, Power)

	return Power
end

function NP:Update_Power(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.power.enable then
		if not nameplate:IsElementEnabled('Power') then
			nameplate:EnableElement('Power')
		end

		nameplate.Power:ClearAllPoints()
		nameplate.Power:Point(E.InversePoints[db.power.anchorPoint], nameplate, db.power.anchorPoint, db.power.xOffset, db.power.yOffset)
		nameplate.Power:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))

		if E.Retail then
			nameplate.Power.smoothing = (db.power.smoothbars and StatusBarInterpolation.ExponentialEaseOut) or StatusBarInterpolation.Immediate or nil
		else
			E:SetSmoothing(nameplate.Power, db.power.smoothbars)
		end
	elseif nameplate:IsElementEnabled('Power') then
		nameplate:DisableElement('Power')
	end

	nameplate.Power.displayAltPower = db.power.displayAltPower
	nameplate.Power.useAtlas = db.power.useAtlas
	nameplate.Power.colorClass = db.power.useClassColor
	nameplate.Power.colorPower = not db.power.useClassColor
	nameplate.Power.width = db.power.width
	nameplate.Power.height = db.power.height
	nameplate.Power:Size(db.power.width, db.power.height)
end
