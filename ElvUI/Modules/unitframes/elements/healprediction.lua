local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_HealComm(frame)
	local mhpb = CreateFrame('StatusBar', nil, frame.Health)
	mhpb:SetStatusBarTexture(E["media"].blankTex)
	mhpb:Hide()

	local ohpb = CreateFrame('StatusBar', nil, frame.Health)
	ohpb:SetStatusBarTexture(E["media"].blankTex)
	ohpb:Hide()

	local absorbBar = CreateFrame('StatusBar', nil, frame.Health)
	absorbBar:SetStatusBarTexture(E["media"].blankTex)
	absorbBar:Hide()

	local healAbsorbBar = CreateFrame('StatusBar', nil, frame.Health)
	healAbsorbBar:SetStatusBarTexture(E["media"].blankTex)
	healAbsorbBar:Hide()

	local overAbsorb = frame.Health:CreateTexture(nil, "OVERLAY")
	overAbsorb:SetTexture(E["media"].blankTex)
	overAbsorb:Hide()

	local overHealAbsorb = frame.Health:CreateTexture(nil, "OVERLAY")
	overHealAbsorb:SetTexture(E["media"].blankTex)
	overHealAbsorb:Hide()

	local HealthPrediction = {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		maxOverflow = 1,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		PostUpdate = UF.UpdateHealComm
	}
	HealthPrediction.parent = frame

	return HealthPrediction
end

function UF:Configure_HealComm(frame)
	local healPrediction = frame.HealthPrediction
	local c = self.db.colors.healPrediction

	if frame.db.healPrediction then
		if not frame:IsElementEnabled('HealthPrediction') then
			frame:EnableElement('HealthPrediction')
		end

		if not frame.USE_PORTRAIT_OVERLAY then
			healPrediction.myBar:SetParent(frame.Health)
			healPrediction.otherBar:SetParent(frame.Health)
			healPrediction.absorbBar:SetParent(frame.Health)
			healPrediction.healAbsorbBar:SetParent(frame.Health)
		else
			healPrediction.myBar:SetParent(frame.Portrait.overlay)
			healPrediction.otherBar:SetParent(frame.Portrait.overlay)
			healPrediction.absorbBar:SetParent(frame.Portrait.overlay)
			healPrediction.healAbsorbBar:SetParent(frame.Portrait.overlay)
		end

		 if frame.db.health then
			local orientation, reverseFill = frame.db.health.orientation, frame.db.health.reverseFill

			if orientation then
				healPrediction.myBar:SetOrientation(orientation)
				healPrediction.otherBar:SetOrientation(orientation)
				healPrediction.absorbBar:SetOrientation(orientation)
				healPrediction.healAbsorbBar:SetOrientation(orientation)
			end

			if reverseFill then
				healPrediction.myBar:SetReverseFill(reverseFill)
				healPrediction.otherBar:SetReverseFill(reverseFill)
				healPrediction.absorbBar:SetReverseFill(reverseFill)
				healPrediction.healAbsorbBar:SetReverseFill(not reverseFill)
			end
		end

		healPrediction.myBar:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
		healPrediction.otherBar:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)
		healPrediction.absorbBar:SetStatusBarColor(c.absorbs.r, c.absorbs.g, c.absorbs.b, c.absorbs.a)
		healPrediction.healAbsorbBar:SetStatusBarColor(c.healAbsorbs.r, c.healAbsorbs.g, c.healAbsorbs.b, c.healAbsorbs.a)

		healPrediction.maxOverflow = (1 + (c.maxOverflow or 0))
	else
		if frame:IsElementEnabled('HealthPrediction') then
			frame:DisableElement('HealthPrediction')
		end
	end
end

function UF:UpdateFillBar(frame, previousTexture, bar, amount, inverted)
	if ( amount == 0 ) then
		bar:Hide();
		return previousTexture;
	end

	local orientation = frame.Health:GetOrientation()
	bar:ClearAllPoints()

	if orientation == 'HORIZONTAL' then
		if (inverted) or self.db.health.reverseFill then
			bar:Point("TOPRIGHT", previousTexture, "TOPRIGHT");
			bar:Point("BOTTOMRIGHT", previousTexture, "BOTTOMRIGHT");
		else
			bar:Point("TOPLEFT", previousTexture, "TOPRIGHT");
			bar:Point("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT");
		end
	else
		if (inverted) or self.db.health.reverseFill then
			bar:Point("TOPRIGHT", previousTexture, "TOPRIGHT");
			bar:Point("TOPLEFT", previousTexture, "TOPLEFT");
		else
			bar:Point("BOTTOMRIGHT", previousTexture, "TOPRIGHT");
			bar:Point("BOTTOMLEFT", previousTexture, "TOPLEFT");
		end
	end

	local totalWidth, totalHeight = frame.Health:GetSize();
	if orientation == 'HORIZONTAL' then
		bar:Width(totalWidth);
	else
		bar:Height(totalHeight);
	end

	return bar:GetStatusBarTexture();
end

function UF:UpdateHealComm(_, myIncomingHeal, allIncomingHeal, totalAbsorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
	local frame = self.parent
	local previousTexture = frame.Health:GetStatusBarTexture();

	UF:UpdateFillBar(frame, previousTexture, self.healAbsorbBar, healAbsorb, true);
	previousTexture = UF:UpdateFillBar(frame, previousTexture, self.myBar, myIncomingHeal);
	previousTexture = UF:UpdateFillBar(frame, previousTexture, self.otherBar, allIncomingHeal);
	UF:UpdateFillBar(frame, previousTexture, self.absorbBar, totalAbsorb)

	local size = self.maxOverflow

	if frame.db then
		self.overHealAbsorb:ClearAllPoints()
		self.overAbsorb:ClearAllPoints()

		local orientation, reverseFill = frame.Health:GetOrientation(), frame.db.health.reverseFill

		if orientation == 'HORIZONTAL' then
			self.overAbsorb:SetPoint('TOP')
			self.overAbsorb:SetPoint('BOTTOM')

			self.overHealAbsorb:SetPoint('TOP')
			self.overHealAbsorb:SetPoint('BOTTOM')

			if reverseFill then
				self.overAbsorb:SetPoint('RIGHT', frame.Health, 'LEFT')
				self.overHealAbsorb:SetPoint('RIGHT', frame.Health, 'LEFT')
			else
				self.overAbsorb:SetPoint('LEFT', frame.Health, 'RIGHT')
				self.overHealAbsorb:SetPoint('LEFT', frame.Health, 'RIGHT')
			end

			self.overHealAbsorb:SetWidth(size)
			self.overAbsorb:SetWidth(size)
		else
			self.overAbsorb:SetPoint('LEFT')
			self.overAbsorb:SetPoint('RIGHT')

			self.overHealAbsorb:SetPoint('LEFT')
			self.overHealAbsorb:SetPoint('RIGHT')

			if reverseFill then
				self.overAbsorb:SetPoint('BOTTOM', frame.Health, 'TOP')
				self.overHealAbsorb:SetPoint('BOTTOM', frame.Health, 'TOP')
			else
				self.overAbsorb:SetPoint('TOP', frame.Health, 'BOTTOM')
				self.overHealAbsorb:SetPoint('TOP', frame.Health, 'BOTTOM')
			end

			self.overHealAbsorb:SetHeight(size)
			self.overAbsorb:SetHeight(size)
		end
	end
end
