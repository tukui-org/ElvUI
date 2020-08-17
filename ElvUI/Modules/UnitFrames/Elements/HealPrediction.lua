local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

local CreateFrame = CreateFrame
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitHealthMax = UnitHealthMax
local UnitHealth = UnitHealth

function UF.HealthClipFrame_HealComm(frame)
	if frame.HealthPrediction then
		UF:SetAlpha_HealComm(frame.HealthPrediction, 1)
		UF:SetVisibility_HealComm(frame.HealthPrediction)
	end
end

function UF:SetAlpha_HealComm(obj, alpha)
	obj.myBar:SetAlpha(alpha)
	obj.otherBar:SetAlpha(alpha)
	obj.absorbBar:SetAlpha(alpha)
	obj.healAbsorbBar:SetAlpha(alpha)
end

function UF:SetTexture_HealComm(obj, texture)
	obj.myBar:SetStatusBarTexture(texture)
	obj.otherBar:SetStatusBarTexture(texture)
	obj.absorbBar:SetStatusBarTexture(texture)
	obj.healAbsorbBar:SetStatusBarTexture(texture)
end

function UF:SetVisibility_HealComm(obj)
	-- the first update is from `HealthClipFrame_HealComm`
	-- we set this variable to allow `Configure_HealComm` to
	-- update the elements overflow lock later on by option
	if not obj.allowClippingUpdate then
		obj.allowClippingUpdate = true
	end

	-- always let these overflow now, we will control their visibility in the postupdate
	obj.absorbBar:SetParent(obj.health)
	obj.healAbsorbBar:SetParent(obj.health)

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

	myBar:SetFrameLevel(11)
	otherBar:SetFrameLevel(11)
	absorbBar:SetFrameLevel(11)
	healAbsorbBar:SetFrameLevel(11)

	local prediction = {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
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

		local colors = self.db.colors.healPrediction
		pred.maxOverflow = 1 + (colors.maxOverflow or 0)

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

		pred.reverseFill = reverseFill
		pred.myBarTexture = myBar:GetStatusBarTexture()
		pred.otherBarTexture = otherBar:GetStatusBarTexture()

		UF:SetTexture_HealComm(pred, UF.db.colors.transparentHealth and E.media.blankTex or healthBarTexture:GetTexture())

		myBar:SetReverseFill(reverseFill)
		otherBar:SetReverseFill(reverseFill)
		healAbsorbBar:SetReverseFill(not pred.reverseFill)

		if absorbStyle == 'REVERSED' then
			absorbBar:SetReverseFill(not pred.reverseFill)
		else
			absorbBar:SetReverseFill(pred.reverseFill)
		end

		myBar:SetStatusBarColor(colors.personal.r, colors.personal.g, colors.personal.b, colors.personal.a)
		otherBar:SetStatusBarColor(colors.others.r, colors.others.g, colors.others.b, colors.others.a)
		absorbBar:SetStatusBarColor(colors.absorbs.r, colors.absorbs.g, colors.absorbs.b, colors.absorbs.a)
		healAbsorbBar:SetStatusBarColor(colors.healAbsorbs.r, colors.healAbsorbs.g, colors.healAbsorbs.b, colors.healAbsorbs.a)

		myBar:SetOrientation(orientation)
		otherBar:SetOrientation(orientation)
		absorbBar:SetOrientation(orientation)
		healAbsorbBar:SetOrientation(orientation)

		local width, height = health:GetSize()
		if not width or width <= 0 then width = health.WIDTH end
		if not height or height <= 0 then height = health.HEIGHT end

		if orientation == "HORIZONTAL" then
			local p1 = reverseFill and "RIGHT" or "LEFT"
			local p2 = reverseFill and "LEFT" or "RIGHT"

			local barHeight = db.height
			local anchor = db.anchorPoint
			if barHeight == -1 or barHeight > height then barHeight = height end
			pred.anchor, pred.anchor1, pred.anchor2 = anchor, p1, p2

			myBar:ClearAllPoints()
			myBar:SetSize(width, barHeight)
			myBar:SetPoint(anchor, health)
			myBar:SetPoint(p1, healthBarTexture, p2)

			otherBar:ClearAllPoints()
			otherBar:SetSize(width, barHeight)
			otherBar:SetPoint(anchor, health)
			otherBar:SetPoint(p1, pred.myBarTexture, p2)

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetSize(width, barHeight)
			healAbsorbBar:SetPoint(anchor, health)
			healAbsorbBar:SetPoint(p2, healthBarTexture, p2)

			absorbBar:ClearAllPoints()
			absorbBar:SetSize(width, barHeight)
			absorbBar:SetPoint(anchor, health)

			if absorbStyle == 'REVERSED' then
				absorbBar:SetPoint(p2, health, p2)
			else
				absorbBar:SetPoint(p1, pred.otherBarTexture, p2)
			end

		else
			local p1 = reverseFill and "TOP" or "BOTTOM"
			local p2 = reverseFill and "BOTTOM" or "TOP"

			local barWidth = db.height -- this is really width now not height
			local anchor = (db.anchorPoint == "BOTTOM" and "RIGHT") or (db.anchorPoint == "TOP" and "LEFT") or db.anchorPoint -- convert this for vertical too
			if barWidth == -1 or barWidth > width then barWidth = width end
			pred.anchor, pred.anchor1, pred.anchor2 = anchor, p1, p2

			myBar:ClearAllPoints()
			myBar:SetSize(barWidth, height)
			myBar:SetPoint(anchor, health)
			myBar:SetPoint(p1, healthBarTexture, p2)

			otherBar:ClearAllPoints()
			otherBar:SetSize(barWidth, height)
			otherBar:SetPoint(anchor, health)
			otherBar:SetPoint(p1, pred.myBarTexture, p2)

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetSize(barWidth, height)
			healAbsorbBar:SetPoint(anchor, health)
			healAbsorbBar:SetPoint(p2, healthBarTexture, p2)

			absorbBar:ClearAllPoints()
			absorbBar:SetSize(barWidth, height)
			absorbBar:SetPoint(anchor, health)

			if absorbStyle == 'REVERSED' then
				absorbBar:SetPoint(p2, health, p2)
			else
				absorbBar:SetPoint(p1, pred.otherBarTexture, p2)
			end

		end
	elseif frame:IsElementEnabled('HealthPrediction') then
		frame:DisableElement('HealthPrediction')
	end
end

function UF:UpdateHealComm(unit, _, _, absorb, _, hasOverAbsorb, hasOverHealAbsorb)
	local frame = self.frame
	local db = frame and frame.db and frame.db.healPrediction
	if not db or not db.absorbStyle or db.absorbStyle == 'NORMAL' then return end

	local pred = frame.HealthPrediction
	local colors = UF.db.colors.healPrediction
	local absorbBar = pred.absorbBar

	if hasOverAbsorb then
		if db.absorbStyle == 'WRAPPED' then
			absorbBar:SetReverseFill(not pred.reverseFill)
			absorbBar:SetValue((UnitHealthMax(unit) - UnitHealth(unit)) + (UnitGetTotalAbsorbs(unit) - absorb))

			absorbBar:ClearAllPoints()
			absorbBar:SetPoint(pred.anchor, frame.Health)
			absorbBar:SetPoint(pred.anchor2, frame.Health, pred.anchor2)
		else -- OVERFLOW and REVERSED
			absorbBar:SetValue(UnitGetTotalAbsorbs(unit))
		end

		absorbBar:SetStatusBarColor(colors.overabsorbs.r, colors.overabsorbs.g, colors.overabsorbs.b, colors.overabsorbs.a)
	else
		absorbBar:SetStatusBarColor(colors.absorbs.r, colors.absorbs.g, colors.absorbs.b, colors.absorbs.a)

		if db.absorbStyle == 'WRAPPED' then
			absorbBar:SetReverseFill(pred.reverseFill)

			absorbBar:ClearAllPoints()
			absorbBar:SetPoint(pred.anchor, frame.Health)
			absorbBar:SetPoint(pred.anchor1, pred.otherBarTexture, pred.anchor2)
		end
	end

	if hasOverHealAbsorb then
		pred.healAbsorbBar:SetStatusBarColor(colors.overhealabsorbs.r, colors.overhealabsorbs.g, colors.overhealabsorbs.b, colors.overhealabsorbs.a)
	else
		pred.healAbsorbBar:SetStatusBarColor(colors.healAbsorbs.r, colors.healAbsorbs.g, colors.healAbsorbs.b, colors.healAbsorbs.a)
	end
end
