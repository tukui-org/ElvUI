local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--WoW API / Variables
local CreateFrame = CreateFrame
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

function UF:Construct_HealComm(frame)
	local myBar = CreateFrame('StatusBar', nil, frame.Health)
	myBar:SetFrameLevel(11)
	myBar.parent = frame.Health
	UF.statusbars[myBar] = true
	myBar:Hide()

	local otherBar = CreateFrame('StatusBar', nil, frame.Health)
	otherBar:SetFrameLevel(11)
	otherBar.parent = frame.Health
	UF.statusbars[otherBar] = true
	otherBar:Hide()

	local absorbBar = CreateFrame('StatusBar', nil, frame.Health)
	absorbBar:SetFrameLevel(11)
	absorbBar.parent = frame.Health
	UF.statusbars[absorbBar] = true
	absorbBar:Hide()

	local healAbsorbBar = CreateFrame('StatusBar', nil, frame.Health)
	healAbsorbBar:SetFrameLevel(11)
	healAbsorbBar.parent = frame.Health
	UF.statusbars[healAbsorbBar] = true
	healAbsorbBar:Hide()

	local overAbsorb = frame.Health:CreateTexture(nil, "ARTWORK")
	overAbsorb.parent = frame.Health
	UF.statusbars[overAbsorb] = true
	overAbsorb:Hide()

	local overHealAbsorb = frame.Health:CreateTexture(nil, "ARTWORK")
	overHealAbsorb.parent = frame.Health
	UF.statusbars[overHealAbsorb] = true
	overHealAbsorb:Hide()

	local texture = (not frame.Health.isTransparent and frame.Health:GetStatusBarTexture()) or E.media.blankTex
	UF:Update_StatusBar(myBar, texture)
	UF:Update_StatusBar(otherBar, texture)
	UF:Update_StatusBar(absorbBar, texture)
	UF:Update_StatusBar(healAbsorbBar, texture)
	UF:Update_StatusBar(overAbsorb, texture)
	UF:Update_StatusBar(overHealAbsorb, texture)

	return {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorb_ = overAbsorb,
		overHealAbsorb_ = overHealAbsorb,
		PostUpdate = UF.UpdateHealComm,
		maxOverflow = 1,
		parent = frame,
	}
end

function UF:Configure_HealComm(frame)
	if (frame.db.healPrediction and frame.db.healPrediction.enable) then
		local healPrediction = frame.HealthPrediction
		local myBar = healPrediction.myBar
		local otherBar = healPrediction.otherBar
		local absorbBar = healPrediction.absorbBar
		local healAbsorbBar = healPrediction.healAbsorbBar
		local c = self.db.colors.healPrediction
		healPrediction.maxOverflow = 1 + (c.maxOverflow or 0)

		if not frame:IsElementEnabled('HealthPrediction') then
			frame:EnableElement('HealthPrediction')
		end

		myBar:SetParent(frame.Health)
		otherBar:SetParent(frame.Health)
		absorbBar:SetParent(frame.Health)
		healAbsorbBar:SetParent(frame.Health)

		if frame.db.health then
			local orientation = frame.db.health.orientation or frame.Health:GetOrientation()
			local reverseFill = not not frame.db.health.reverseFill
			local showAbsorbAmount = frame.db.healPrediction.showAbsorbAmount

			myBar:SetOrientation(orientation)
			otherBar:SetOrientation(orientation)
			absorbBar:SetOrientation(orientation)
			healAbsorbBar:SetOrientation(orientation)

			if frame.db.healPrediction.showOverAbsorbs and not showAbsorbAmount then
				healPrediction.overAbsorb = healPrediction.overAbsorb_
				healPrediction.overHealAbsorb = healPrediction.overHealAbsorb_
			else
				if healPrediction.overAbsorb then
					healPrediction.overAbsorb:Hide()
					healPrediction.overAbsorb = nil
					healPrediction.overHealAbsorb:Hide()
					healPrediction.overHealAbsorb = nil
				end
			end

			if orientation == "HORIZONTAL" then
				local width = frame.Health:GetWidth()
				width = width > 0 and width or frame.Health.WIDTH
				local p1 = reverseFill and "RIGHT" or "LEFT"
				local p2 = reverseFill and "LEFT" or "RIGHT"

				myBar:ClearAllPoints()
				myBar:Point("TOP", frame.Health, "TOP")
				myBar:Point("BOTTOM", frame.Health, "BOTTOM")
				myBar:Point(p1, frame.Health:GetStatusBarTexture(), p2)
				myBar:Size(width, 0)

				otherBar:ClearAllPoints()
				otherBar:Point("TOP", frame.Health, "TOP")
				otherBar:Point("BOTTOM", frame.Health, "BOTTOM")
				otherBar:Point(p1, myBar:GetStatusBarTexture(), p2)
				otherBar:Size(width, 0)

				absorbBar:ClearAllPoints()
				absorbBar:Point("TOP", frame.Health, "TOP")
				absorbBar:Point("BOTTOM", frame.Health, "BOTTOM")

				if showAbsorbAmount then
					absorbBar:Point(p2, frame.Health, p2)
				else
					absorbBar:Point(p1, otherBar:GetStatusBarTexture(), p2)
				end

				absorbBar:Size(width, 0)

				healAbsorbBar:ClearAllPoints()
				healAbsorbBar:Point("TOP", frame.Health, "TOP")
				healAbsorbBar:Point("BOTTOM", frame.Health, "BOTTOM")
				healAbsorbBar:Point(p2, frame.Health:GetStatusBarTexture(), p2)
				healAbsorbBar:Size(width, 0)

				if healPrediction.overAbsorb then
					healPrediction.overAbsorb:ClearAllPoints()
					healPrediction.overAbsorb:Point("TOP", frame.Health, "TOP")
					healPrediction.overAbsorb:Point("BOTTOM", frame.Health, "BOTTOM")
					healPrediction.overAbsorb:Point(p1, frame.Health, p2)
					healPrediction.overAbsorb:Size(1, 0)
				end

				if healPrediction.overHealAbsorb then
					healPrediction.overHealAbsorb:ClearAllPoints()
					healPrediction.overHealAbsorb:Point("TOP", frame.Health, "TOP")
					healPrediction.overHealAbsorb:Point("BOTTOM", frame.Health, "BOTTOM")
					healPrediction.overHealAbsorb:Point(p2, frame.Health, p1)
					healPrediction.overHealAbsorb:Size(1, 0)
				end
			else
				local height = frame.Health:GetHeight()
				height = height > 0 and height or frame.Health.HEIGHT
				local p1 = reverseFill and "TOP" or "BOTTOM"
				local p2 = reverseFill and "BOTTOM" or "TOP"

				myBar:ClearAllPoints()
				myBar:Point("LEFT", frame.Health, "LEFT")
				myBar:Point("RIGHT", frame.Health, "RIGHT")
				myBar:Point(p1, frame.Health:GetStatusBarTexture(), p2)
				myBar:Size(0, height)

				otherBar:ClearAllPoints()
				otherBar:Point("LEFT", frame.Health, "LEFT")
				otherBar:Point("RIGHT", frame.Health, "RIGHT")
				otherBar:Point(p1, myBar:GetStatusBarTexture(), p2)
				otherBar:Size(0, height)

				absorbBar:ClearAllPoints()
				absorbBar:Point("LEFT", frame.Health, "LEFT")
				absorbBar:Point("RIGHT", frame.Health, "RIGHT")

				if showAbsorbAmount then
					absorbBar:Point(p2, frame.Health, p2)
				else
					absorbBar:Point(p1, otherBar:GetStatusBarTexture(), p2)
				end

				absorbBar:Size(0, height)

				healAbsorbBar:ClearAllPoints()
				healAbsorbBar:Point("LEFT", frame.Health, "LEFT")
				healAbsorbBar:Point("RIGHT", frame.Health, "RIGHT")
				healAbsorbBar:Point(p2, frame.Health:GetStatusBarTexture(), p2)
				healAbsorbBar:Size(0, height)

				if healPrediction.overAbsorb then
					healPrediction.overAbsorb:ClearAllPoints()
					healPrediction.overAbsorb:Point("LEFT", frame.Health, "LEFT")
					healPrediction.overAbsorb:Point("RIGHT", frame.Health, "RIGHT")
					healPrediction.overAbsorb:Point(p1, frame.Health, p2)
					healPrediction.overAbsorb:Size(0, 1)
				end

				if healPrediction.overHealAbsorb then
					healPrediction.overHealAbsorb:ClearAllPoints()
					healPrediction.overHealAbsorb:Point("LEFT", frame.Health, "LEFT")
					healPrediction.overHealAbsorb:Point("RIGHT", frame.Health, "RIGHT")
					healPrediction.overHealAbsorb:Point(p2, frame.Health, p1)
					healPrediction.overHealAbsorb:Size(0, 1)
				end
			end

			myBar:SetReverseFill(reverseFill)
			otherBar:SetReverseFill(reverseFill)
			absorbBar:SetReverseFill(showAbsorbAmount and not reverseFill or reverseFill)
			healAbsorbBar:SetReverseFill(not reverseFill)
		end

		myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
		otherBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)
		absorbBar:SetStatusBarColor(c.absorbs.r, c.absorbs.g, c.absorbs.b, c.absorbs.a)
		healAbsorbBar:SetStatusBarColor(c.healAbsorbs.r, c.healAbsorbs.g, c.healAbsorbs.b, c.healAbsorbs.a)

		if healPrediction.overAbsorb then
			healPrediction.overAbsorb:SetVertexColor(c.overabsorbs.r, c.overabsorbs.g, c.overabsorbs.b, c.overabsorbs.a)
		end
		if healPrediction.overHealAbsorb then
			healPrediction.overHealAbsorb:SetVertexColor(c.overhealabsorbs.r, c.overhealabsorbs.g, c.overhealabsorbs.b, c.overhealabsorbs.a)
		end
	else
		if frame:IsElementEnabled('HealthPrediction') then
			frame:DisableElement('HealthPrediction')
		end
	end
end

function UF:UpdateHealComm(unit, _, _, _, _, hasOverAbsorb)
	local frame = self.parent
	if frame.db and frame.db.healPrediction and frame.db.healPrediction.showOverAbsorbs and frame.db.healPrediction.showAbsorbAmount then
		if hasOverAbsorb then
			self.absorbBar:SetValue(UnitGetTotalAbsorbs(unit))
		end
	end
end
