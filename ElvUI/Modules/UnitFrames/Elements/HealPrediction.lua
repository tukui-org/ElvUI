local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--WoW API / Variables
local CreateFrame = CreateFrame
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

function UF:Construct_HealComm(frame)
	local health = frame.Health
	local parent = health.ClipFrame

	local myBar = CreateFrame('StatusBar', nil, parent)
	myBar:SetFrameLevel(11)
	myBar.parent = parent
	UF.statusbars[myBar] = true
	myBar:Hide()

	local otherBar = CreateFrame('StatusBar', nil, parent)
	otherBar:SetFrameLevel(11)
	otherBar.parent = parent
	UF.statusbars[otherBar] = true
	otherBar:Hide()

	local absorbBar = CreateFrame('StatusBar', nil, parent)
	absorbBar:SetFrameLevel(11)
	absorbBar.parent = parent
	UF.statusbars[absorbBar] = true
	absorbBar:Hide()

	local healAbsorbBar = CreateFrame('StatusBar', nil, parent)
	healAbsorbBar:SetFrameLevel(11)
	healAbsorbBar.parent = parent
	UF.statusbars[healAbsorbBar] = true
	healAbsorbBar:Hide()

	local overAbsorb = parent:CreateTexture(nil, "ARTWORK")
	overAbsorb.parent = parent
	UF.statusbars[overAbsorb] = true
	overAbsorb:Hide()

	local overHealAbsorb = parent:CreateTexture(nil, "ARTWORK")
	overHealAbsorb.parent = parent
	UF.statusbars[overHealAbsorb] = true
	overHealAbsorb:Hide()

	local texture = (not health.isTransparent and health:GetStatusBarTexture()) or E.media.blankTex
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

		-- this now unclips, allowing personal and other heals to overflow
		myBar:SetParent(frame.Health)
		otherBar:SetParent(frame.Health)

		if frame.db.health then
			local health = frame.Health
			local parent = health.ClipFrame
			local orientation = frame.db.health.orientation or health:GetOrientation()
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
				local width = health:GetWidth()
				width = width > 0 and width or health.WIDTH
				local p1 = reverseFill and "RIGHT" or "LEFT"
				local p2 = reverseFill and "LEFT" or "RIGHT"

				myBar:Size(width, 0)
				myBar:ClearAllPoints()
				myBar:Point("TOP", parent, "TOP")
				myBar:Point("BOTTOM", parent, "BOTTOM")
				myBar:Point(p1, health:GetStatusBarTexture(), p2)

				otherBar:Size(width, 0)
				otherBar:ClearAllPoints()
				otherBar:Point("TOP", parent, "TOP")
				otherBar:Point("BOTTOM", parent, "BOTTOM")
				otherBar:Point(p1, myBar:GetStatusBarTexture(), p2)

				absorbBar:Size(width, 0)
				absorbBar:ClearAllPoints()
				absorbBar:Point("TOP", parent, "TOP")
				absorbBar:Point("BOTTOM", parent, "BOTTOM")

				if showAbsorbAmount then
					absorbBar:Point(p2, parent, p2)
				else
					absorbBar:Point(p1, otherBar:GetStatusBarTexture(), p2)
				end

				healAbsorbBar:Size(width, 0)
				healAbsorbBar:ClearAllPoints()
				healAbsorbBar:Point("TOP", parent, "TOP")
				healAbsorbBar:Point("BOTTOM", parent, "BOTTOM")
				healAbsorbBar:Point(p2, health:GetStatusBarTexture(), p2)

				if healPrediction.overAbsorb then
					healPrediction.overAbsorb:Size(1, 0)
					healPrediction.overAbsorb:ClearAllPoints()
					healPrediction.overAbsorb:Point("TOP", parent, "TOP")
					healPrediction.overAbsorb:Point("BOTTOM", parent, "BOTTOM")
					healPrediction.overAbsorb:Point(p1, parent, p2)
				end

				if healPrediction.overHealAbsorb then
					healPrediction.overHealAbsorb:Size(1, 0)
					healPrediction.overHealAbsorb:ClearAllPoints()
					healPrediction.overHealAbsorb:Point("TOP", parent, "TOP")
					healPrediction.overHealAbsorb:Point("BOTTOM", parent, "BOTTOM")
					healPrediction.overHealAbsorb:Point(p2, parent, p1)
				end
			else
				local height = health:GetHeight()
				height = height > 0 and height or health.HEIGHT
				local p1 = reverseFill and "TOP" or "BOTTOM"
				local p2 = reverseFill and "BOTTOM" or "TOP"

				myBar:Size(0, height)
				myBar:ClearAllPoints()
				myBar:Point("LEFT", parent, "LEFT")
				myBar:Point("RIGHT", parent, "RIGHT")
				myBar:Point(p1, health:GetStatusBarTexture(), p2)

				otherBar:Size(0, height)
				otherBar:ClearAllPoints()
				otherBar:Point("LEFT", parent, "LEFT")
				otherBar:Point("RIGHT", parent, "RIGHT")
				otherBar:Point(p1, myBar:GetStatusBarTexture(), p2)

				absorbBar:Size(0, height)
				absorbBar:ClearAllPoints()
				absorbBar:Point("LEFT", parent, "LEFT")
				absorbBar:Point("RIGHT", parent, "RIGHT")
				if showAbsorbAmount then
					absorbBar:Point(p2, parent, p2)
				else
					absorbBar:Point(p1, otherBar:GetStatusBarTexture(), p2)
				end

				healAbsorbBar:Size(0, height)
				healAbsorbBar:ClearAllPoints()
				healAbsorbBar:Point("LEFT", parent, "LEFT")
				healAbsorbBar:Point("RIGHT", parent, "RIGHT")
				healAbsorbBar:Point(p2, health:GetStatusBarTexture(), p2)

				if healPrediction.overAbsorb then
					healPrediction.overAbsorb:Size(0, 1)
					healPrediction.overAbsorb:ClearAllPoints()
					healPrediction.overAbsorb:Point("LEFT", parent, "LEFT")
					healPrediction.overAbsorb:Point("RIGHT", parent, "RIGHT")
					healPrediction.overAbsorb:Point(p1, parent, p2)
				end

				if healPrediction.overHealAbsorb then
					healPrediction.overHealAbsorb:Size(0, 1)
					healPrediction.overHealAbsorb:ClearAllPoints()
					healPrediction.overHealAbsorb:Point("LEFT", parent, "LEFT")
					healPrediction.overHealAbsorb:Point("RIGHT", parent, "RIGHT")
					healPrediction.overHealAbsorb:Point(p2, parent, p1)
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
	local parent = self.parent
	local pred = parent and parent.db and parent.db.healPrediction
	if pred and (pred.showOverAbsorbs and pred.showAbsorbAmount) and hasOverAbsorb then
		self.absorbBar:SetValue(UnitGetTotalAbsorbs(unit))
	end
end
