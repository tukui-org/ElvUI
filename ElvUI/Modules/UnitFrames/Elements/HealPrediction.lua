local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local CreateFrame = CreateFrame
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs, UnitGetTotalHealAbsorbs = UnitGetTotalAbsorbs, UnitGetTotalHealAbsorbs

function UF.HealthClipFrame_HealComm(frame)
	local pred = frame.HealthPrediction
	if pred then
		UF:SetAlpha_HealComm(pred, 1)
		UF:SetVisibility_HealComm(pred)
	end
end

function UF:SetAlpha_HealComm(obj, alpha)
	obj.myBar:SetAlpha(alpha)
	obj.otherBar:SetAlpha(alpha)
	obj.absorbBar:SetAlpha(alpha)
	obj.healAbsorbBar:SetAlpha(alpha)
	obj.overAbsorb_:SetAlpha(alpha)
	obj.overHealAbsorb_:SetAlpha(alpha)
	obj.overAbsorbBar:SetAlpha(alpha)
	obj.overHealAbsorbBar:SetAlpha(alpha)
end

function UF:SetTexture_HealComm(obj, texture)
	obj.myBar:SetStatusBarTexture(texture)
	obj.otherBar:SetStatusBarTexture(texture)
	obj.absorbBar:SetStatusBarTexture(texture)
	obj.healAbsorbBar:SetStatusBarTexture(texture)
	obj.overAbsorb_:SetTexture(texture)
	obj.overHealAbsorb_:SetTexture(texture)
	obj.overAbsorbBar:SetStatusBarTexture(texture)
	obj.overHealAbsorbBar:SetStatusBarTexture(texture)
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

	local overAbsorbBar = CreateFrame('StatusBar', nil, parent)
	local overHealAbsorbBar = CreateFrame('StatusBar', nil, parent)

	myBar:SetFrameLevel(11)
	otherBar:SetFrameLevel(11)
	absorbBar:SetFrameLevel(11)
	healAbsorbBar:SetFrameLevel(11)
	overAbsorbBar:SetFrameLevel(11)
	overHealAbsorbBar:SetFrameLevel(11)

	local prediction = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorb_ = overAbsorb,
		overHealAbsorb_ = overHealAbsorb,
		overAbsorbBar = overAbsorbBar,
		overHealAbsorbBar = overHealAbsorbBar,
		PostUpdate = UF.UpdateHealComm,
		maxOverflow = 1,
		health = health,
		parent = parent,
		frame = frame
	}

	UF:SetAlpha_HealComm(prediction, 0)
	UF:SetTexture_HealComm(prediction, E.media.blankTex)

	return prediction
end

function UF:Configure_HealComm(frame)
	local db = frame.db.healPrediction
	if db and db.enable then
		local pred = frame.HealthPrediction
		local myBar = pred.myBar
		local otherBar = pred.otherBar
		local absorbBar = pred.absorbBar
		local healAbsorbBar = pred.healAbsorbBar
		local overAbsorb = pred.overAbsorb_
		local overHealAbsorb = pred.overHealAbsorb_
		local overAbsorbBar = pred.overAbsorbBar
		local overHealAbsorbBar = pred.overHealAbsorbBar

		local c = self.db.colors.healPrediction
		pred.maxOverflow = 1 + (c.maxOverflow or 0)

		if pred.allowClippingUpdate then
			UF:SetVisibility_HealComm(pred)
		end

		if not frame:IsElementEnabled('HealthPrediction') then
			frame:EnableElement('HealthPrediction')
		end

		local health = frame.Health
		local orientation = health:GetOrientation()
		local reverseFill = health:GetReverseFill()
		local healthBarTexture = health:GetStatusBarTexture()
		local absorbStyle = db.absorbStyle
		local showOverAbsorbs = db.showOverAbsorbs

		UF:SetTexture_HealComm(pred, UF.db.colors.transparentHealth and E.media.blankTex or healthBarTexture:GetTexture())

		myBar:SetOrientation(orientation)
		otherBar:SetOrientation(orientation)
		absorbBar:SetOrientation(orientation)
		healAbsorbBar:SetOrientation(orientation)

		myBar:SetReverseFill(reverseFill)
		otherBar:SetReverseFill(reverseFill)
		healAbsorbBar:SetReverseFill(not reverseFill)

		overAbsorbBar:SetReverseFill(not reverseFill)
		overHealAbsorbBar:SetReverseFill(not reverseFill)

		if absorbStyle == 'REVERSED' then
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

		overAbsorbBar:SetStatusBarColor(c.overabsorbs.r, c.overabsorbs.g, c.overabsorbs.b, c.overabsorbs.a)
		overHealAbsorbBar:SetStatusBarColor(c.overhealabsorbs.r, c.overhealabsorbs.g, c.overhealabsorbs.b, c.overhealabsorbs.a)

		if showOverAbsorbs and absorbStyle == 'OVERFLOW' then
			pred.overAbsorb = overAbsorb
		elseif pred.overAbsorb then
			pred.overAbsorb:Hide()
			pred.overAbsorb = nil
		end

		if showOverAbsorbs and absorbStyle == 'OVERFLOW' then
			pred.overHealAbsorb = overHealAbsorb
		elseif pred.overHealAbsorb then
			pred.overHealAbsorb:Hide()
			pred.overHealAbsorb = nil
		end

		local width, height = health:GetSize()
		if not width or width <= 0 then width = health.WIDTH end
		if not height or height <= 0 then height = health.HEIGHT end

		if orientation == "HORIZONTAL" then
			local p1 = reverseFill and "RIGHT" or "LEFT"
			local p2 = reverseFill and "LEFT" or "RIGHT"

			local barHeight = db.height
			local anchor = db.anchorPoint
			if barHeight == -1 or barHeight > height then barHeight = height end

			myBar:ClearAllPoints()
			myBar:SetSize(width, barHeight)
			myBar:SetPoint(anchor, health)
			myBar:SetPoint(p1, healthBarTexture, p2)

			otherBar:ClearAllPoints()
			otherBar:SetSize(width, barHeight)
			otherBar:SetPoint(anchor, health)
			otherBar:SetPoint(p1, myBar:GetStatusBarTexture(), p2)

			absorbBar:ClearAllPoints()
			absorbBar:SetSize(width, barHeight)
			absorbBar:SetPoint(anchor, health)

			if absorbStyle == 'REVERSED' then
				absorbBar:SetPoint(p2, health, p2)
			else
				absorbBar:SetPoint(p1, otherBar:GetStatusBarTexture(), p2)
			end

			--Do for vertical as well
			overAbsorbBar:ClearAllPoints()
			overAbsorbBar:SetSize(width, barHeight)
			overAbsorbBar:SetPoint(anchor, health)
			overAbsorbBar:SetPoint(p2, health, p2)

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetSize(width, barHeight)
			healAbsorbBar:SetPoint(anchor, health)

			if absorbStyle == 'REVERSED' then
				healAbsorbBar:SetPoint(p2, health, p2)
			else
				healAbsorbBar:SetPoint(p2, healthBarTexture, p2)
			end

			healAbsorbBar:SetPoint(p2, healthBarTexture, p2)

			--Do for vertical as well
			overHealAbsorbBar:ClearAllPoints()
			overHealAbsorbBar:SetSize(width, barHeight)
			overHealAbsorbBar:SetPoint(anchor, health)
			overHealAbsorbBar:SetPoint(p2, health, p2)

			if pred.overAbsorb then
				pred.overAbsorb:ClearAllPoints()
				pred.overAbsorb:SetSize(5, barHeight)
				pred.overAbsorb:SetPoint(anchor, health)
				pred.overAbsorb:SetPoint(p1, health, p2)
			end

			if pred.overHealAbsorb then
				pred.overHealAbsorb:ClearAllPoints()
				pred.overHealAbsorb:SetSize(5, barHeight)
				pred.overHealAbsorb:SetPoint(anchor, health)
				pred.overHealAbsorb:SetPoint(p2, health, p1)
			end
		else
			local p1 = reverseFill and "TOP" or "BOTTOM"
			local p2 = reverseFill and "BOTTOM" or "TOP"

			local barWidth = db.height -- this is really width now not height
			local anchor = (db.anchorPoint == "BOTTOM" and "RIGHT") or (db.anchorPoint == "TOP" and "LEFT") or db.anchorPoint -- convert this for vertical too
			if barWidth == -1 or barWidth > width then barWidth = width end

			myBar:ClearAllPoints()
			myBar:SetSize(barWidth, height)
			myBar:SetPoint(anchor, health)
			myBar:SetPoint(p1, healthBarTexture, p2)

			otherBar:ClearAllPoints()
			otherBar:SetSize(barWidth, height)
			otherBar:SetPoint(anchor, health)
			otherBar:SetPoint(p1, myBar:GetStatusBarTexture(), p2)

			absorbBar:ClearAllPoints()
			absorbBar:SetSize(barWidth, height)
			absorbBar:SetPoint(anchor, health)
			if absorbStyle then
				absorbBar:SetPoint(p2, health, p2)
			else
				absorbBar:SetPoint(p1, otherBar:GetStatusBarTexture(), p2)
			end

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetSize(barWidth, height)
			healAbsorbBar:SetPoint(anchor, health)
			healAbsorbBar:SetPoint(p2, healthBarTexture, p2)

			if pred.overAbsorb then
				pred.overAbsorb:ClearAllPoints()
				pred.overAbsorb:SetSize(barWidth, 5)
				pred.overAbsorb:SetPoint(anchor, health)
				pred.overAbsorb:SetPoint(p1, health, p2)
			end

			if pred.overHealAbsorb then
				pred.overHealAbsorb:ClearAllPoints()
				pred.overHealAbsorb:SetSize(barWidth, 5)
				pred.overHealAbsorb:SetPoint(anchor, health)
				pred.overHealAbsorb:SetPoint(p2, health, p1)
			end
		end
	elseif frame:IsElementEnabled('HealthPrediction') then
		frame:DisableElement('HealthPrediction')
	end
end

function UF:UpdateHealComm(unit, _, _, absorbs, healAbsorbs, hasOverAbsorb, hasOverHealAbsorb)
	local pred = self.frame and self.frame.db and self.frame.db.healPrediction
	if not pred or not pred.showOverAbsorbs then return end

	local style = pred.absorbStyle
	if hasOverAbsorb then
		if style == 'REVERSED' then
			self.absorbBar:SetValue(UnitGetTotalAbsorbs(unit))
		elseif style == 'WRAPPED' then
			local maxHealth = UnitHealthMax(unit)
			local overAbsorbAmount = UnitGetTotalAbsorbs(unit) - absorbs
			self.overAbsorbBar:SetMinMaxValues(0, maxHealth)
			self.overAbsorbBar:SetValue(overAbsorbAmount)
			self.overAbsorbBar:Show()
		end
	else
		self.overAbsorbBar:Hide()
	end

	if hasOverHealAbsorb then
		if style == 'REVERSED' then
			self.healAbsorbBar:SetValue(UnitGetTotalAbsorbs(unit))
		elseif style == 'WRAPPED' then
			local maxHealth = UnitHealthMax(unit)
			local overHealAbsorbAmount = UnitGetTotalHealAbsorbs(unit) - healAbsorbs
			self.overHealAbsorbBar:SetMinMaxValues(0, maxHealth)
			self.overHealAbsorbBar:SetValue(overHealAbsorbAmount)
			self.overHealAbsorbBar:Show()
		end
	else
		self.overHealAbsorbBar:Hide()
	end
end
