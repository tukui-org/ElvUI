local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local CreateFrame = CreateFrame
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

function UF.HealthClipFrame_HealComm(frame)
	local pred = frame.HealthPrediction
	if pred then
		UF:SetAlpha_HealComm(pred, true)
		UF:SetVisibility_HealComm(pred)
	end
end

function UF:SetAlpha_HealComm(obj, show)
	obj.myBar:SetAlpha(show and 1 or 0)
	obj.otherBar:SetAlpha(show and 1 or 0)
	obj.absorbBar:SetAlpha(show and 1 or 0)
	obj.healAbsorbBar:SetAlpha(show and 1 or 0)
	obj.overAbsorb_:SetAlpha(show and 1 or 0)
	obj.overHealAbsorb_:SetAlpha(show and 1 or 0)
end

function UF:SetTexture_HealComm(obj, texture)
	obj.myBar:SetStatusBarTexture(texture)
	obj.otherBar:SetStatusBarTexture(texture)
	obj.absorbBar:SetStatusBarTexture(texture)
	obj.healAbsorbBar:SetStatusBarTexture(texture)
	obj.overAbsorb_:SetTexture(texture)
	obj.overHealAbsorb_:SetTexture(texture)
end

function UF:SetVisibility_HealComm(obj)
	-- the first update is from `HealthClipFrame_HealComm`
	-- we set this variable to allow `Configure_HealComm` to
	-- update the elements overflow lock later on by option
	if not obj.allowClippingUpdate then
		obj.allowClippingUpdate = true
	end

	if obj.maxOverflow > 1 then
		obj.myBar:SetParent(obj.health)
		obj.otherBar:SetParent(obj.health)
	else
		obj.myBar:SetParent(obj.parent)
		obj.otherBar:SetParent(obj.parent)
	end
end

function UF:Construct_HealComm(frame)
	local health = frame.Health
	local parent = health.ClipFrame

	local myBar = CreateFrame('StatusBar', nil, parent)
	local otherBar = CreateFrame('StatusBar', nil, parent)
	local absorbBar = CreateFrame('StatusBar', nil, parent)
	local healAbsorbBar = CreateFrame('StatusBar', nil, parent)
	local overAbsorb = myBar:CreateTexture(nil, "ARTWORK")
	local overHealAbsorb = myBar:CreateTexture(nil, "ARTWORK")

	myBar:SetFrameLevel(11)
	otherBar:SetFrameLevel(11)
	absorbBar:SetFrameLevel(11)
	healAbsorbBar:SetFrameLevel(11)

	local prediction = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorb_ = overAbsorb,
		overHealAbsorb_ = overHealAbsorb,
		PostUpdate = UF.UpdateHealComm,
		maxOverflow = 1,
		health = health,
		parent = parent,
		frame = frame
	}

	UF:SetAlpha_HealComm(prediction)
	UF:SetTexture_HealComm(prediction, E.media.blankTex)

	return prediction
end

function UF:Configure_HealComm(frame)
	if frame.db.healPrediction and frame.db.healPrediction.enable then
		local healPrediction = frame.HealthPrediction
		local myBar = healPrediction.myBar
		local otherBar = healPrediction.otherBar
		local absorbBar = healPrediction.absorbBar
		local healAbsorbBar = healPrediction.healAbsorbBar
		local overAbsorb = healPrediction.overAbsorb_
		local overHealAbsorb = healPrediction.overHealAbsorb_

		local c = self.db.colors.healPrediction
		healPrediction.maxOverflow = 1 + (c.maxOverflow or 0)

		if healPrediction.allowClippingUpdate then
			UF:SetVisibility_HealComm(healPrediction)
		end

		if not frame:IsElementEnabled('HealthPrediction') then
			frame:EnableElement('HealthPrediction')
		end

		local health = frame.Health
		local orientation = health:GetOrientation()
		local reverseFill = health:GetReverseFill()
		local healthBarTexture = health:GetStatusBarTexture()
		local showAbsorbAmount = frame.db.healPrediction.showAbsorbAmount

		UF:SetTexture_HealComm(healPrediction, UF.db.colors.transparentHealth and E.media.blankTex or healthBarTexture:GetTexture())

		myBar:SetOrientation(orientation)
		otherBar:SetOrientation(orientation)
		absorbBar:SetOrientation(orientation)
		healAbsorbBar:SetOrientation(orientation)

		myBar:SetReverseFill(reverseFill)
		otherBar:SetReverseFill(reverseFill)
		healAbsorbBar:SetReverseFill(not reverseFill)
		if showAbsorbAmount then
			absorbBar:SetReverseFill(not reverseFill)
		else
			absorbBar:SetReverseFill(reverseFill)
		end

		myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
		otherBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)
		absorbBar:SetStatusBarColor(c.absorbs.r, c.absorbs.g, c.absorbs.b, c.absorbs.a)
		healAbsorbBar:SetStatusBarColor(c.healAbsorbs.r, c.healAbsorbs.g, c.healAbsorbs.b, c.healAbsorbs.a)
		overAbsorb:SetVertexColor(c.overabsorbs.r, c.overabsorbs.g, c.overabsorbs.b, c.overabsorbs.a)
		overHealAbsorb:SetVertexColor(c.overhealabsorbs.r, c.overhealabsorbs.g, c.overhealabsorbs.b, c.overhealabsorbs.a)

		if frame.db.healPrediction.showOverAbsorbs then
			healPrediction.overAbsorb = overAbsorb
			healPrediction.overHealAbsorb = overHealAbsorb
		elseif healPrediction.overAbsorb then
			healPrediction.overAbsorb:Hide()
			healPrediction.overAbsorb = nil
			healPrediction.overHealAbsorb:Hide()
			healPrediction.overHealAbsorb = nil
		end

		if orientation == "HORIZONTAL" then
			local width = health:GetWidth()
			width = (width > 0 and width) or health.WIDTH
			local p1 = reverseFill and "RIGHT" or "LEFT"
			local p2 = reverseFill and "LEFT" or "RIGHT"

			myBar:SetSize(width, 0)
			myBar:ClearAllPoints()
			myBar:SetPoint("TOP", health, "TOP")
			myBar:SetPoint("BOTTOM", health, "BOTTOM")
			myBar:SetPoint(p1, healthBarTexture, p2)

			otherBar:SetSize(width, 0)
			otherBar:ClearAllPoints()
			otherBar:SetPoint("TOP", health, "TOP")
			otherBar:SetPoint("BOTTOM", health, "BOTTOM")
			otherBar:SetPoint(p1, myBar:GetStatusBarTexture(), p2)

			absorbBar:SetSize(width, 0)
			absorbBar:ClearAllPoints()
			absorbBar:SetPoint("TOP", health, "TOP")
			absorbBar:SetPoint("BOTTOM", health, "BOTTOM")
			if showAbsorbAmount then
				absorbBar:SetPoint(p2, health, p2)
			else
				absorbBar:SetPoint(p1, otherBar:GetStatusBarTexture(), p2)
			end

			healAbsorbBar:SetSize(width, 0)
			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetPoint("TOP", health, "TOP")
			healAbsorbBar:SetPoint("BOTTOM", health, "BOTTOM")
			healAbsorbBar:SetPoint(p2, healthBarTexture, p2)

			if healPrediction.overAbsorb then
				healPrediction.overAbsorb:SetSize(4, 0)
				healPrediction.overAbsorb:ClearAllPoints()
				healPrediction.overAbsorb:SetPoint("TOP", health, "TOP")
				healPrediction.overAbsorb:SetPoint("BOTTOM", health, "BOTTOM")
				healPrediction.overAbsorb:SetPoint(p1, health, p2)
			end

			if healPrediction.overHealAbsorb then
				healPrediction.overHealAbsorb:SetSize(4, 0)
				healPrediction.overHealAbsorb:ClearAllPoints()
				healPrediction.overHealAbsorb:SetPoint("TOP", health, "TOP")
				healPrediction.overHealAbsorb:SetPoint("BOTTOM", health, "BOTTOM")
				healPrediction.overHealAbsorb:SetPoint(p2, health, p1)
			end
		else
			local height = health:GetHeight()
			height = (height > 0 and height) or health.HEIGHT
			local p1 = reverseFill and "TOP" or "BOTTOM"
			local p2 = reverseFill and "BOTTOM" or "TOP"

			myBar:SetSize(0, height)
			myBar:ClearAllPoints()
			myBar:SetPoint("LEFT", health, "LEFT")
			myBar:SetPoint("RIGHT", health, "RIGHT")
			myBar:SetPoint(p1, healthBarTexture, p2)

			otherBar:SetSize(0, height)
			otherBar:ClearAllPoints()
			otherBar:SetPoint("LEFT", health, "LEFT")
			otherBar:SetPoint("RIGHT", health, "RIGHT")
			otherBar:SetPoint(p1, myBar:GetStatusBarTexture(), p2)

			absorbBar:SetSize(0, height)
			absorbBar:ClearAllPoints()
			absorbBar:SetPoint("LEFT", health, "LEFT")
			absorbBar:SetPoint("RIGHT", health, "RIGHT")
			if showAbsorbAmount then
				absorbBar:SetPoint(p2, health, p2)
			else
				absorbBar:SetPoint(p1, otherBar:GetStatusBarTexture(), p2)
			end

			healAbsorbBar:SetSize(0, height)
			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetPoint("LEFT", health, "LEFT")
			healAbsorbBar:SetPoint("RIGHT", health, "RIGHT")
			healAbsorbBar:SetPoint(p2, healthBarTexture, p2)

			if healPrediction.overAbsorb then
				healPrediction.overAbsorb:SetSize(0, 1)
				healPrediction.overAbsorb:ClearAllPoints()
				healPrediction.overAbsorb:SetPoint("LEFT", health, "LEFT")
				healPrediction.overAbsorb:SetPoint("RIGHT", health, "RIGHT")
				healPrediction.overAbsorb:SetPoint(p1, health, p2)
			end

			if healPrediction.overHealAbsorb then
				healPrediction.overHealAbsorb:SetSize(0, 1)
				healPrediction.overHealAbsorb:ClearAllPoints()
				healPrediction.overHealAbsorb:SetPoint("LEFT", health, "LEFT")
				healPrediction.overHealAbsorb:SetPoint("RIGHT", health, "RIGHT")
				healPrediction.overHealAbsorb:SetPoint(p2, health, p1)
			end
		end
	elseif frame:IsElementEnabled('HealthPrediction') then
		frame:DisableElement('HealthPrediction')
	end
end

function UF:UpdateHealComm(unit, _, _, _, _, hasOverAbsorb)
	local pred = self.frame and self.frame.db and self.frame.db.healPrediction
	if pred and (pred.showOverAbsorbs and pred.showAbsorbAmount) and hasOverAbsorb then
		self.absorbBar:SetValue(UnitGetTotalAbsorbs(unit))
	end
end
