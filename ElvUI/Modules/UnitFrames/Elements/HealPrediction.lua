local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');


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

			myBar:Size(width, 0)
			myBar:ClearAllPoints()
			myBar:Point("TOP", health, "TOP")
			myBar:Point("BOTTOM", health, "BOTTOM")
			myBar:Point(p1, healthBarTexture, p2)

			otherBar:Size(width, 0)
			otherBar:ClearAllPoints()
			otherBar:Point("TOP", health, "TOP")
			otherBar:Point("BOTTOM", health, "BOTTOM")
			otherBar:Point(p1, myBar:GetStatusBarTexture(), p2)

			absorbBar:Size(width, 0)
			absorbBar:ClearAllPoints()
			absorbBar:Point("TOP", health, "TOP")
			absorbBar:Point("BOTTOM", health, "BOTTOM")
			if showAbsorbAmount then
				absorbBar:Point(p2, health, p2)
			else
				absorbBar:Point(p1, otherBar:GetStatusBarTexture(), p2)
			end

			healAbsorbBar:Size(width, 0)
			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:Point("TOP", health, "TOP")
			healAbsorbBar:Point("BOTTOM", health, "BOTTOM")
			healAbsorbBar:Point(p2, healthBarTexture, p2)

			if healPrediction.overAbsorb then
				healPrediction.overAbsorb:Size(4, 0)
				healPrediction.overAbsorb:ClearAllPoints()
				healPrediction.overAbsorb:Point("TOP", health, "TOP")
				healPrediction.overAbsorb:Point("BOTTOM", health, "BOTTOM")
				healPrediction.overAbsorb:Point(p1, health, p2)
			end

			if healPrediction.overHealAbsorb then
				healPrediction.overHealAbsorb:Size(4, 0)
				healPrediction.overHealAbsorb:ClearAllPoints()
				healPrediction.overHealAbsorb:Point("TOP", health, "TOP")
				healPrediction.overHealAbsorb:Point("BOTTOM", health, "BOTTOM")
				healPrediction.overHealAbsorb:Point(p2, health, p1)
			end
		else
			local height = health:GetHeight()
			height = (height > 0 and height) or health.HEIGHT
			local p1 = reverseFill and "TOP" or "BOTTOM"
			local p2 = reverseFill and "BOTTOM" or "TOP"

			myBar:Size(0, height)
			myBar:ClearAllPoints()
			myBar:Point("LEFT", health, "LEFT")
			myBar:Point("RIGHT", health, "RIGHT")
			myBar:Point(p1, healthBarTexture, p2)

			otherBar:Size(0, height)
			otherBar:ClearAllPoints()
			otherBar:Point("LEFT", health, "LEFT")
			otherBar:Point("RIGHT", health, "RIGHT")
			otherBar:Point(p1, myBar:GetStatusBarTexture(), p2)

			absorbBar:Size(0, height)
			absorbBar:ClearAllPoints()
			absorbBar:Point("LEFT", health, "LEFT")
			absorbBar:Point("RIGHT", health, "RIGHT")
			if showAbsorbAmount then
				absorbBar:Point(p2, health, p2)
			else
				absorbBar:Point(p1, otherBar:GetStatusBarTexture(), p2)
			end

			healAbsorbBar:Size(0, height)
			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:Point("LEFT", health, "LEFT")
			healAbsorbBar:Point("RIGHT", health, "RIGHT")
			healAbsorbBar:Point(p2, healthBarTexture, p2)

			if healPrediction.overAbsorb then
				healPrediction.overAbsorb:Size(0, 1)
				healPrediction.overAbsorb:ClearAllPoints()
				healPrediction.overAbsorb:Point("LEFT", health, "LEFT")
				healPrediction.overAbsorb:Point("RIGHT", health, "RIGHT")
				healPrediction.overAbsorb:Point(p1, health, p2)
			end

			if healPrediction.overHealAbsorb then
				healPrediction.overHealAbsorb:Size(0, 1)
				healPrediction.overHealAbsorb:ClearAllPoints()
				healPrediction.overHealAbsorb:Point("LEFT", health, "LEFT")
				healPrediction.overHealAbsorb:Point("RIGHT", health, "RIGHT")
				healPrediction.overHealAbsorb:Point(p2, health, p1)
			end
		end
	elseif frame:IsElementEnabled('HealthPrediction') then
		frame:DisableElement('HealthPrediction')
	end
end
