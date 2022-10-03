local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local LSM = E.Libs.LSM

local CreateFrame = CreateFrame
function UF.HealthClipFrame_HealComm(frame)
	if frame.HealthPrediction then
		UF:SetAlpha_HealComm(frame.HealthPrediction, 1)
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

function UF:SetFrameLevel_HealComm(obj, level)
	obj.myBar:SetFrameLevel(level)
	obj.otherBar:SetFrameLevel(level)
	obj.absorbBar:SetFrameLevel(level)
	obj.healAbsorbBar:SetFrameLevel(level)
end

function UF:Construct_HealComm(frame)
	local health = frame.Health
	local parent = health.ClipFrame

	local prediction = {
		myBar = CreateFrame('StatusBar', nil, parent),
		otherBar = CreateFrame('StatusBar', nil, parent),
		absorbBar = CreateFrame('StatusBar', nil, parent),
		healAbsorbBar = CreateFrame('StatusBar', nil, parent),
		PostUpdate = UF.UpdateHealComm,
		maxOverflow = 1,
		health = health,
		parent = parent,
		frame = frame
	}

	UF:SetAlpha_HealComm(prediction, 0)
	UF:SetFrameLevel_HealComm(prediction, 11)
	UF:SetTexture_HealComm(prediction, E.media.blankTex)

	return prediction
end

function UF:SetSize_HealComm(frame)
	local health = frame.Health
	local pred = frame.HealthPrediction
	local orientation = health:GetOrientation()

	local db = frame.db.healPrediction
	local width, height = health:GetSize()

	-- fallback just incase, can happen on profile switching
	if not width or width <= 0 then width = health.WIDTH end
	if not height or height <= 0 then height = health.HEIGHT end

	if orientation == 'HORIZONTAL' then
		local barHeight = db.height or height
		if barHeight == -1 or barHeight > height then barHeight = height end

		pred.myBar:SetSize(width, barHeight)
		pred.otherBar:SetSize(width, barHeight)
		pred.healAbsorbBar:SetSize(width, barHeight)
		pred.absorbBar:SetSize(width, barHeight)
		pred.parent:SetSize(width * (pred.maxOverflow or 0), height)
	else
		local barWidth = db.height or width -- this is really width now not height
		if barWidth == -1 or barWidth > width then barWidth = width end

		pred.myBar:SetSize(barWidth, height)
		pred.otherBar:SetSize(barWidth, height)
		pred.healAbsorbBar:SetSize(barWidth, height)
		pred.absorbBar:SetSize(barWidth, height)
		pred.parent:SetSize(width, height * (pred.maxOverflow or 0))
	end
end

function UF:Configure_HealComm(frame)
	local db = frame.db and frame.db.healPrediction
	if db and db.enable then
		local pred = frame.HealthPrediction
		local parent = pred.parent
		local myBar = pred.myBar
		local otherBar = pred.otherBar
		local absorbBar = pred.absorbBar
		local healAbsorbBar = pred.healAbsorbBar

		local colors = UF.db.colors.healPrediction
		pred.maxOverflow = 1 + (colors.maxOverflow or 0)

		if not frame:IsElementEnabled('HealthPrediction') then
			frame:EnableElement('HealthPrediction')
		end

		local health = frame.Health
		local orientation = health:GetOrientation()
		local reverseFill = health:GetReverseFill()
		local healthBarTexture = health:GetStatusBarTexture() -- :GetTexture() from here sometimes messes up? so use LSM

		pred.reverseFill = reverseFill
		pred.healthBarTexture = healthBarTexture
		pred.myBarTexture = myBar:GetStatusBarTexture()
		pred.otherBarTexture = otherBar:GetStatusBarTexture()

		UF:SetTexture_HealComm(pred, UF.db.colors.transparentHealth and E.media.blankTex or LSM:Fetch('statusbar', UF.db.statusbar))

		myBar:SetReverseFill(reverseFill)
		otherBar:SetReverseFill(reverseFill)
		healAbsorbBar:SetReverseFill(not reverseFill)

		if db.absorbStyle == 'REVERSED' then
			absorbBar:SetReverseFill(not reverseFill)
		else
			absorbBar:SetReverseFill(reverseFill)
		end

		myBar:SetStatusBarColor(colors.personal.r, colors.personal.g, colors.personal.b, colors.personal.a)
		otherBar:SetStatusBarColor(colors.others.r, colors.others.g, colors.others.b, colors.others.a)
		absorbBar:SetStatusBarColor(colors.absorbs.r, colors.absorbs.g, colors.absorbs.b, colors.absorbs.a)
		healAbsorbBar:SetStatusBarColor(colors.healAbsorbs.r, colors.healAbsorbs.g, colors.healAbsorbs.b, colors.healAbsorbs.a)

		myBar:SetOrientation(orientation)
		otherBar:SetOrientation(orientation)
		absorbBar:SetOrientation(orientation)
		healAbsorbBar:SetOrientation(orientation)

		if orientation == 'HORIZONTAL' then
			local p1 = reverseFill and 'RIGHT' or 'LEFT'
			local p2 = reverseFill and 'LEFT' or 'RIGHT'

			local anchor = db.anchorPoint
			pred.anchor, pred.anchor1, pred.anchor2 = anchor, p1, p2

			myBar:ClearAllPoints()
			myBar:Point(anchor, health)
			myBar:Point(p1, healthBarTexture, p2)

			otherBar:ClearAllPoints()
			otherBar:Point(anchor, health)
			otherBar:Point(p1, pred.myBarTexture, p2)

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:Point(anchor, health)

			absorbBar:ClearAllPoints()
			absorbBar:Point(anchor, health)

			parent:ClearAllPoints()
			parent:Point(p1, health, p1)

			if db.absorbStyle == 'REVERSED' then
				absorbBar:Point(p2, health, p2)
			else
				absorbBar:Point(p1, pred.otherBarTexture, p2)
			end
		else
			local p1 = reverseFill and 'TOP' or 'BOTTOM'
			local p2 = reverseFill and 'BOTTOM' or 'TOP'

			-- anchor converts while the health is in vertical orientation to be able to use a height
			-- (well in this case, width) other than -1 which positions the absorb on the left or right side
			local anchor = (db.anchorPoint == 'BOTTOM' and 'RIGHT') or (db.anchorPoint == 'TOP' and 'LEFT') or db.anchorPoint
			pred.anchor, pred.anchor1, pred.anchor2 = anchor, p1, p2

			myBar:ClearAllPoints()
			myBar:Point(anchor, health)
			myBar:Point(p1, healthBarTexture, p2)

			otherBar:ClearAllPoints()
			otherBar:Point(anchor, health)
			otherBar:Point(p1, pred.myBarTexture, p2)

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:Point(anchor, health)

			absorbBar:ClearAllPoints()
			absorbBar:Point(anchor, health)

			parent:ClearAllPoints()
			parent:Point(p1, health, p1)

			if db.absorbStyle == 'REVERSED' then
				absorbBar:Point(p2, health, p2)
			else
				absorbBar:Point(p1, pred.otherBarTexture, p2)
			end
		end
	elseif frame:IsElementEnabled('HealthPrediction') then
		frame:DisableElement('HealthPrediction')
	end
end

function UF:UpdateHealComm(_, _, _, absorb, _, hasOverAbsorb, hasOverHealAbsorb, health, maxHealth)
	local frame = self.frame
	local db = frame and frame.db and frame.db.healPrediction
	if not db or not db.absorbStyle then return end

	local pred = frame.HealthPrediction
	local healAbsorbBar = pred.healAbsorbBar
	local absorbBar = pred.absorbBar

	UF:SetSize_HealComm(frame)

	-- absorbs is set to none so hide both and kill code execution
	if not E.Retail or db.absorbStyle == 'NONE' then
		healAbsorbBar:Hide()
		absorbBar:Hide()
		return
	end

	-- handle over heal absorbs
	healAbsorbBar:ClearAllPoints()
	healAbsorbBar:Point(pred.anchor, frame.Health)

	local colors = UF.db.colors.healPrediction
	if hasOverHealAbsorb then -- forward fill it when its greater than health so that you can still see this is being stolen
		healAbsorbBar:SetReverseFill(pred.reverseFill)
		healAbsorbBar:Point(pred.anchor1, pred.healthBarTexture, pred.anchor2)
		healAbsorbBar:SetStatusBarColor(colors.overhealabsorbs.r, colors.overhealabsorbs.g, colors.overhealabsorbs.b, colors.overhealabsorbs.a)
	else -- otherwise just let it backfill so that we know how much is being stolen
		healAbsorbBar:SetReverseFill(not pred.reverseFill)
		healAbsorbBar:Point(pred.anchor2, pred.healthBarTexture, pred.anchor2)
		healAbsorbBar:SetStatusBarColor(colors.healAbsorbs.r, colors.healAbsorbs.g, colors.healAbsorbs.b, colors.healAbsorbs.a)
	end

	-- color absorb bar if in over state
	if hasOverAbsorb then
		absorbBar:SetStatusBarColor(colors.overabsorbs.r, colors.overabsorbs.g, colors.overabsorbs.b, colors.overabsorbs.a)
	else
		absorbBar:SetStatusBarColor(colors.absorbs.r, colors.absorbs.g, colors.absorbs.b, colors.absorbs.a)
	end

	-- if we are in normal mode and overflowing happens we should let a bit show, like blizzard does
	if db.absorbStyle == 'NORMAL' then
		if hasOverAbsorb and health == maxHealth then
			absorbBar:SetValue(1.5)
			absorbBar:SetMinMaxValues(0, 100)
		end
	else
		if hasOverAbsorb then -- non normal mode overflowing
			if db.absorbStyle == 'WRAPPED' then -- engage backfilling
				absorbBar:SetReverseFill(not pred.reverseFill)

				absorbBar:ClearAllPoints()
				absorbBar:Point(pred.anchor, pred.health)
				absorbBar:Point(pred.anchor2, pred.health, pred.anchor2)
			elseif db.absorbStyle == 'OVERFLOW' then -- we need to display the overflow but adjusting the values
				local overflowAbsorb = absorb * (colors.maxOverflow or 0)
				if health == maxHealth then
					absorbBar:SetValue(overflowAbsorb)
				else -- fill the inner part along with the overflow amount so it smoothly transitions
					absorbBar:SetValue((maxHealth - health) + overflowAbsorb)
				end
			end
		elseif db.absorbStyle == 'WRAPPED' then -- restore wrapped to its forward filling state
			absorbBar:SetReverseFill(pred.reverseFill)

			absorbBar:ClearAllPoints()
			absorbBar:Point(pred.anchor, pred.health)
			absorbBar:Point(pred.anchor1, pred.otherBarTexture, pred.anchor2)
		end
	end
end
