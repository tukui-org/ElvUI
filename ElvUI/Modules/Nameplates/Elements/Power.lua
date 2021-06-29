local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local unpack = unpack
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local CreateFrame = CreateFrame
local UnitPowerType = UnitPowerType
local POWERTYPE_ALTERNATE = Enum.PowerType.Alternate or 10

function NP:Power_UpdateColor(_, unit)
	if self.unit ~= unit then return end

	local element = self.Power
	local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)
	element.token = ptoken

	local sf = NP:StyleFilterChanges(self)
	if sf.PowerColor then return end

	local Selection = element.colorSelection and NP:UnitSelectionType(unit, element.considerSelectionInCombatHostile)

	local r, g, b, t, atlas
	if element.colorDisconnected and not UnitIsConnected(unit) then
		t = self.colors.disconnected
	elseif element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
		t = self.colors.tapped
	elseif element.colorPower then
		if element.displayType ~= POWERTYPE_ALTERNATE then
			t = NP.db.colors.power[ptoken or ptype]
			if not t then
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
			t = NP.db.colors.power.ALT_POWER
		end

		if element.useAtlas and t and t.atlas then
			atlas = t.atlas
		end
	elseif (element.colorClass and self.isPlayer) or (element.colorClassNPC and not self.isPlayer) or (element.colorClassPet and UnitPlayerControlled(unit) and not self.isPlayer) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif Selection then
		t = NP.db.colors.selection[Selection]
	elseif element.colorReaction and UnitReaction(unit, 'player') then
		local reaction = UnitReaction(unit, 'player')
		if reaction <= 3 then reaction = 'bad' elseif reaction == 4 then reaction = 'neutral' else reaction = 'good' end
		t = NP.db.colors.reactions[reaction]
	elseif element.colorSmooth then
		local adjust = 0 - (element.min or 0)
		r, g, b = self:ColorGradient((element.cur or 1) + adjust, (element.max or 1) + adjust, unpack(element.smoothGradient or self.colors.smooth))
	end

	if t then
		r, g, b = t[1] or t.r, t[2] or t.g, t[3] or t.b
	end

	if atlas then
		element:SetStatusBarAtlas(atlas)
		element:SetStatusBarColor(1, 1, 1)
	elseif b then
		element:SetStatusBarColor(r, g, b)
	end

	if element.bg and b then element.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier) end

	if element.PostUpdateColor then
		element:PostUpdateColor(unit, r, g, b)
	end
end

function NP:Power_PostUpdate(_, cur) --unit, cur, min, max
	local db = NP.db.units[self.__owner.frameType]

	if not db then return end

	if self.__owner.frameType ~= 'PLAYER' and db.power.displayAltPower and not self.displayType then
		self:Hide()
		return
	end

	if db.power and db.power.enable and db.power.hideWhenEmpty and (cur == 0) then
		self:Hide()
	else
		self:Show()
	end
end

function NP:Construct_Power(nameplate)
	local Power = CreateFrame('StatusBar', nameplate:GetName()..'Power', nameplate)
	Power:SetFrameStrata(nameplate:GetFrameStrata())
	Power:SetFrameLevel(5)
	Power:CreateBackdrop('Transparent', nil, nil, nil, nil, true)

	local clipFrame = CreateFrame('Frame', nil, Power)
	clipFrame:SetClipsChildren(true)
	clipFrame:SetAllPoints()
	clipFrame:EnableMouse(false)
	Power.ClipFrame = clipFrame

	NP.StatusBars[Power] = true

	Power.frequentUpdates = true
	Power.colorTapping = false
	Power.colorClass = false

	Power.PostUpdate = NP.Power_PostUpdate
	Power.UpdateColor = NP.Power_UpdateColor

	return Power
end

function NP:Update_Power(nameplate)
	local db = NP:PlateDB(nameplate)

	if db.power.enable then
		if not nameplate:IsElementEnabled('Power') then
			nameplate:EnableElement('Power')
		end

		nameplate.Power:SetStatusBarTexture(LSM:Fetch('statusbar', NP.db.statusbar))
		nameplate.Power:Point('CENTER', nameplate, 'CENTER', db.power.xOffset, db.power.yOffset)

		nameplate:SetPowerUpdateMethod(E.global.nameplate.effectivePower)
		nameplate:SetPowerUpdateSpeed(E.global.nameplate.effectivePowerSpeed)

		E:SetSmoothing(nameplate.Power, NP.db.smoothbars)
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
