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
	obj.healingPlayer:SetAlpha(alpha)
	obj.healingOther:SetAlpha(alpha)
	obj.damageAbsorb:SetAlpha(alpha)
	obj.healAbsorb:SetAlpha(alpha)
end

function UF:SetTexture_HealComm(obj, texture)
	obj.healingPlayer:SetStatusBarTexture(texture)
	obj.healingOther:SetStatusBarTexture(texture)
	obj.damageAbsorb:SetStatusBarTexture(texture)
	obj.healAbsorb:SetStatusBarTexture(texture)
end

function UF:SetFrameLevel_HealComm(obj, level)
	obj.healingPlayer:SetFrameLevel(level)
	obj.healingOther:SetFrameLevel(level)
	obj.damageAbsorb:SetFrameLevel(level)
	obj.healAbsorb:SetFrameLevel(level)
end

function UF:Construct_HealComm(frame)
	local health = frame.Health
	local parent = health.ClipFrame

	local prediction = {
		healingPlayer = CreateFrame('StatusBar', '$parent_HealingPlayerBar', parent),
		healingOther = CreateFrame('StatusBar', '$parent_HealingOtherBar', parent),
		damageAbsorb = CreateFrame('StatusBar', '$parent_AbsorbDamageBar', parent),
		healAbsorb = CreateFrame('StatusBar', '$parent_AbsorbHealBar', parent),
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

		pred.healingPlayer:SetSize(width, barHeight)
		pred.healingOther:SetSize(width, barHeight)
		pred.healAbsorb:SetSize(width, barHeight)
		pred.damageAbsorb:SetSize(width, barHeight)
		pred.parent:SetSize(width * (pred.maxOverflow or 0), height)
	else
		local barWidth = db.height or width -- this is really width now not height
		if barWidth == -1 or barWidth > width then barWidth = width end

		pred.healingPlayer:SetSize(barWidth, height)
		pred.healingOther:SetSize(barWidth, height)
		pred.healAbsorb:SetSize(barWidth, height)
		pred.damageAbsorb:SetSize(barWidth, height)
		pred.parent:SetSize(width, height * (pred.maxOverflow or 0))
	end
end

function UF:Configure_HealComm(frame)
	local db = frame.db and frame.db.healPrediction
	if db and db.enable then
		local pred = frame.HealthPrediction
		local parent = pred.parent
		local healingPlayer = pred.healingPlayer
		local healingOther = pred.healingOther
		local damageAbsorb = pred.damageAbsorb
		local healAbsorb = pred.healAbsorb

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
		pred.healingPlayerTexture = healingPlayer:GetStatusBarTexture()
		pred.healingOtherTexture = healingOther:GetStatusBarTexture()

		UF:SetTexture_HealComm(pred, UF.db.colors.transparentHealth and E.media.blankTex or LSM:Fetch('statusbar', UF.db.statusbar))

		healingPlayer:SetReverseFill(reverseFill)
		healingOther:SetReverseFill(reverseFill)
		healAbsorb:SetReverseFill(not reverseFill)

		if db.absorbStyle == 'REVERSED' then
			damageAbsorb:SetReverseFill(not reverseFill)
		else
			damageAbsorb:SetReverseFill(reverseFill)
		end

		healingPlayer:GetStatusBarTexture():SetVertexColor(colors.personal.r, colors.personal.g, colors.personal.b, colors.personal.a)
		healingOther:GetStatusBarTexture():SetVertexColor(colors.others.r, colors.others.g, colors.others.b, colors.others.a)
		damageAbsorb:GetStatusBarTexture():SetVertexColor(colors.absorbs.r, colors.absorbs.g, colors.absorbs.b, colors.absorbs.a)
		healAbsorb:GetStatusBarTexture():SetVertexColor(colors.healAbsorbs.r, colors.healAbsorbs.g, colors.healAbsorbs.b, colors.healAbsorbs.a)

		healingPlayer:SetOrientation(orientation)
		healingOther:SetOrientation(orientation)
		damageAbsorb:SetOrientation(orientation)
		healAbsorb:SetOrientation(orientation)

		if orientation == 'HORIZONTAL' then
			local p1 = reverseFill and 'RIGHT' or 'LEFT'
			local p2 = reverseFill and 'LEFT' or 'RIGHT'

			local anchor = db.anchorPoint
			pred.anchor, pred.anchor1, pred.anchor2 = anchor, p1, p2

			healingPlayer:ClearAllPoints()
			healingPlayer:Point(anchor, health)
			healingPlayer:Point(p1, healthBarTexture, p2)

			healingOther:ClearAllPoints()
			healingOther:Point(anchor, health)
			healingOther:Point(p1, pred.healingPlayerTexture, p2)

			healAbsorb:ClearAllPoints()
			healAbsorb:Point(anchor, health)

			damageAbsorb:ClearAllPoints()
			damageAbsorb:Point(anchor, health)

			parent:ClearAllPoints()
			parent:Point(p1, health, p1)

			if db.absorbStyle == 'REVERSED' then
				damageAbsorb:Point(p2, health, p2)
			else
				damageAbsorb:Point(p1, pred.healingOtherTexture, p2)
			end
		else
			local p1 = reverseFill and 'TOP' or 'BOTTOM'
			local p2 = reverseFill and 'BOTTOM' or 'TOP'

			-- anchor converts while the health is in vertical orientation to be able to use a height
			-- (well in this case, width) other than -1 which positions the absorb on the left or right side
			local anchor = (db.anchorPoint == 'BOTTOM' and 'RIGHT') or (db.anchorPoint == 'TOP' and 'LEFT') or db.anchorPoint
			pred.anchor, pred.anchor1, pred.anchor2 = anchor, p1, p2

			healingPlayer:ClearAllPoints()
			healingPlayer:Point(anchor, health)
			healingPlayer:Point(p1, healthBarTexture, p2)

			healingOther:ClearAllPoints()
			healingOther:Point(anchor, health)
			healingOther:Point(p1, pred.healingPlayerTexture, p2)

			healAbsorb:ClearAllPoints()
			healAbsorb:Point(anchor, health)

			damageAbsorb:ClearAllPoints()
			damageAbsorb:Point(anchor, health)

			parent:ClearAllPoints()
			parent:Point(p1, health, p1)

			if db.absorbStyle == 'REVERSED' then
				damageAbsorb:Point(p2, health, p2)
			else
				damageAbsorb:Point(p1, pred.healingOtherTexture, p2)
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

	local isHealthSecret = E:IsSecretValue(health)
	local isMaxHealthSecret = E:IsSecretValue(maxHealth)
	local isAbsorbSecret = E:IsSecretValue(absorb)
	local hasSecretValues = isHealthSecret or isMaxHealthSecret or isAbsorbSecret

	local pred = frame.HealthPrediction
	local healAbsorb = pred.healAbsorb
	local damageAbsorb = pred.damageAbsorb

	UF:SetSize_HealComm(frame)

	-- absorbs is set to none so hide both and kill code execution
	if E.Classic or db.absorbStyle == 'NONE' then
		healAbsorb:Hide()
		damageAbsorb:Hide()
		return
	end

	-- handle over heal absorbs
	healAbsorb:ClearAllPoints()
	healAbsorb:Point(pred.anchor, frame.Health)

	local colors = UF.db.colors.healPrediction
	if hasOverHealAbsorb then -- forward fill it when its greater than health so that you can still see this is being stolen
		healAbsorb:SetReverseFill(pred.reverseFill)
		healAbsorb:Point(pred.anchor1, pred.healthBarTexture, pred.anchor2)
		healAbsorb:GetStatusBarTexture():SetVertexColor(colors.overhealabsorbs.r, colors.overhealabsorbs.g, colors.overhealabsorbs.b, colors.overhealabsorbs.a)
	else -- otherwise just let it backfill so that we know how much is being stolen
		healAbsorb:SetReverseFill(not pred.reverseFill)
		healAbsorb:Point(pred.anchor2, pred.healthBarTexture, pred.anchor2)
		healAbsorb:GetStatusBarTexture():SetVertexColor(colors.healAbsorbs.r, colors.healAbsorbs.g, colors.healAbsorbs.b, colors.healAbsorbs.a)
	end

	-- color absorb bar if in over state
	if hasOverAbsorb then
		damageAbsorb:GetStatusBarTexture():SetVertexColor(colors.overabsorbs.r, colors.overabsorbs.g, colors.overabsorbs.b, colors.overabsorbs.a)
	else
		damageAbsorb:GetStatusBarTexture():SetVertexColor(colors.absorbs.r, colors.absorbs.g, colors.absorbs.b, colors.absorbs.a)
	end

	if hasSecretValues then return end

	-- if we are in normal mode and overflowing happens we should let a bit show, like blizzard does
	if db.absorbStyle == 'NORMAL' then
		if hasOverAbsorb and health == maxHealth then
			damageAbsorb:SetValue(1.5)
			damageAbsorb:SetMinMaxValues(0, 100)
		end
	else
		if hasOverAbsorb then -- non normal mode overflowing
			if db.absorbStyle == 'WRAPPED' then -- engage backfilling
				damageAbsorb:SetReverseFill(not pred.reverseFill)

				damageAbsorb:ClearAllPoints()
				damageAbsorb:Point(pred.anchor, pred.health)
				damageAbsorb:Point(pred.anchor2, pred.health, pred.anchor2)
			elseif db.absorbStyle == 'OVERFLOW' then -- we need to display the overflow but adjusting the values
				local overflowAbsorb = absorb * (colors.maxOverflow or 0)
				if health == maxHealth then
					damageAbsorb:SetValue(overflowAbsorb)
				else -- fill the inner part along with the overflow amount so it smoothly transitions
					damageAbsorb:SetValue((maxHealth - health) + overflowAbsorb)
				end
			end
		elseif db.absorbStyle == 'WRAPPED' then -- restore wrapped to its forward filling state
			damageAbsorb:SetReverseFill(pred.reverseFill)

			damageAbsorb:ClearAllPoints()
			damageAbsorb:Point(pred.anchor, pred.health)
			damageAbsorb:Point(pred.anchor1, pred.healingOtherTexture, pred.anchor2)
		end
	end
end
