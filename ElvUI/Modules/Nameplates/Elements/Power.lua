local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule('NamePlates')

-- Cache global variables
-- Lua functions
local _G = _G
local unpack = unpack
-- WoW API / Variables
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitThreatSituation = UnitThreatSituation
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local CreateFrame = CreateFrame
local UnitPowerType = UnitPowerType

function NP:Power_UpdateColor(event, unit)
	if self.unit ~= unit then return end

	local element = self.Power
	local ptype, ptoken, altR, altG, altB = UnitPowerType(unit)
	element.token = ptoken

	if self.PowerColorChanged then return end
	local Selection = element.colorSelection and NP:UnitSelectionType(unit, element.considerSelectionInCombatHostile)

	local r, g, b, t, atlas
	if(element.colorDead and element.dead) then
		t = self.colors.dead
	elseif(element.colorDisconnected and element.disconnected) then
		t = self.colors.disconnected
	elseif(element.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = self.colors.tapped
	elseif(element.colorThreat and not UnitPlayerControlled(unit) and UnitThreatSituation('player', unit)) then
		t =  self.colors.threat[UnitThreatSituation('player', unit)]
	elseif(element.colorPower) then
		if(element.displayType ~= _G.ALTERNATE_POWER_INDEX) then
			t = NP.db.colors.power[ptoken or ptype]
			if(not t) then
				if(element.GetAlternativeColor) then
					r, g, b = element:GetAlternativeColor(unit, ptype, ptoken, altR, altG, altB)
				elseif(altR) then
					r, g, b = altR, altG, altB
					if(r > 1 or g > 1 or b > 1) then
						-- BUG: As of 7.0.3, altR, altG, altB may be in 0-1 or 0-255 range.
						r, g, b = r / 255, g / 255, b / 255
					end
				end
			end
		else
			t = self.colors.power[_G.ALTERNATE_POWER_INDEX]
		end

		if(element.useAtlas and t and t.atlas) then
			atlas = t.atlas
		end
	elseif(element.colorClass and UnitIsPlayer(unit)) or
		(element.colorClassNPC and not UnitIsPlayer(unit)) or
		(element.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = self.colors.class[class]
	elseif Selection then
		t = NP.db.colors.selection[Selection]
	elseif(element.colorReaction and UnitReaction(unit, 'player')) then
		local reaction = UnitReaction(unit, 'player')
		if reaction <= 3 then reaction = 'bad' elseif reaction == 4 then reaction = 'neutral' else reaction = 'good' end
		t = NP.db.colors.reactions[reaction]
	elseif(element.colorSmooth) then
		local adjust = 0 - (element.min or 0)
		r, g, b = self:ColorGradient((element.cur or 1) + adjust, (element.max or 1) + adjust, unpack(element.smoothGradient or self.colors.smooth))
	end

	if(t) then
		r, g, b = t[1] or t.r, t[2] or t.g, t[3] or t.b
	end

	if(atlas) then
		element:SetStatusBarAtlas(atlas)
		element:SetStatusBarColor(1, 1, 1)
	else
		element:SetStatusBarTexture(element.texture)

		if(b) then
			element:SetStatusBarColor(r, g, b)
		end
	end

	if element.bg and b then element.bg:SetVertexColor(r * NP.multiplier, g * NP.multiplier, b * NP.multiplier) end

	if(element.PostUpdateColor) then
		element:PostUpdateColor(unit, r, g, b)
	end
end

function NP:Power_PostUpdate(unit, cur, min, max)
	local db = NP.db.units[self.__owner.frameType]

	if not db then return end

	if self.__owner.frameType ~= 'PLAYER' and db.power.displayAltPower and not self.displayType then
		self:Hide()
		return
	end

	if (db.power and db.power.enable and db.power.hideWhenEmpty) and (cur == 0) then
		self:Hide()
	else
		self:Show()
	end
end

function NP:Construct_Power(nameplate)
	local Power = CreateFrame('StatusBar', nameplate:GetDebugName()..'Power', nameplate)
	Power:SetFrameStrata(nameplate:GetFrameStrata())
	Power:SetFrameLevel(5)
	Power:CreateBackdrop('Transparent')
	Power:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', NP.db.statusbar))

	local clipFrame = CreateFrame('Frame', nil, Power)
	clipFrame:SetClipsChildren(true)
	clipFrame:SetAllPoints()
	clipFrame:EnableMouse(false)
	Power.ClipFrame = clipFrame

	NP.StatusBars[Power] = true

	Power.frequentUpdates = true --Azil, keep this for now. It seems it may prevent event bugs
	Power.colorTapping = false
	Power.colorClass = false

	Power.PostUpdate = NP.Power_PostUpdate
	Power.UpdateColor = NP.Power_UpdateColor

	return Power
end

function NP:Update_Power(nameplate)
	local db = NP.db.units[nameplate.frameType]

	if db.power.enable then
		if not nameplate:IsElementEnabled('Power') then
			nameplate:EnableElement('Power')
		end

		nameplate.Power:Point('CENTER', nameplate, 'CENTER', db.power.xOffset, db.power.yOffset)

		E:SetSmoothing(nameplate.Power, NP.db.smoothbars)
	else
		if nameplate:IsElementEnabled('Power') then
			nameplate:DisableElement('Power')
		end
	end

	if db.power.text.enable then
		nameplate.Power.Text:ClearAllPoints()
		nameplate.Power.Text:Point(E.InversePoints[db.power.text.position], db.power.text.parent == 'Nameplate' and nameplate or nameplate[db.power.text.parent], db.power.text.position, db.power.text.xOffset, db.power.text.yOffset)
		nameplate.Power.Text:FontTemplate(E.LSM:Fetch('font', db.power.text.font), db.power.text.fontSize, db.power.text.fontOutline)
		nameplate.Power.Text:Show()
	else
		nameplate.Power.Text:Hide()
	end

	nameplate:Tag(nameplate.Power.Text, db.power.text.format)

	nameplate.Power.displayAltPower = db.power.displayAltPower
	nameplate.Power.useAtlas = db.power.useAtlas
	nameplate.Power.colorClass = db.power.useClassColor
	nameplate.Power.colorPower = not db.power.useClassColor
	nameplate.Power.width = db.power.width
	nameplate.Power.height = db.power.height
	nameplate.Power:Size(db.power.width, db.power.height)
end
