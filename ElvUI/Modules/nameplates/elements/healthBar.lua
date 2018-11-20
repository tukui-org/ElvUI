local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local ipairs = ipairs
local tinsert = tinsert
local max = math.max
--WoW API / Variables
local CreateAnimationGroup = CreateAnimationGroup
local CreateFrame = CreateFrame
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitClass = UnitClass
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsUnit = UnitIsUnit
local UnitPlayerControlled = UnitPlayerControlled
local UnitReaction = UnitReaction
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
-- GLOBALS: CUSTOM_CLASS_COLORS

function mod:UpdateElement_HealthColor(frame)
	if(not frame.HealthBar:IsShown()) then return end

	local r, g, b, scale = 1, 1, 1, 1
	if ( not UnitIsConnected(frame.unit) ) then
		r, g, b = self.db.reactions.offline.r, self.db.reactions.offline.g, self.db.reactions.offline.b
	else
		if ( frame.HealthBar.ColorOverride ) then
			--[[
				local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
				r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;
			]]
		else
			--Try to color it by class.
			local _, class = UnitClass(frame.displayedUnit);
			local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
			local useClassColor = self.db.units[frame.UnitType].healthbar.useClassColor
			if (classColor and not frame.inVehicle and ((frame.UnitType == "FRIENDLY_PLAYER" and useClassColor) or (frame.UnitType == "HEALER" and useClassColor) or (frame.UnitType == "ENEMY_PLAYER" and useClassColor) or (frame.UnitType == "PLAYER" and useClassColor))) then
				-- Use class colors for players if class color option is turned on
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( not UnitPlayerControlled(frame.unit) and UnitIsTapDenied(frame.unit) ) then
				-- Use grey if not a player and can't get tap on unit
				r, g, b = self.db.reactions.tapped.r, self.db.reactions.tapped.g, self.db.reactions.tapped.b
			else
				-- Use color based on the type of unit (neutral, etc.)
				local _, status = UnitDetailedThreatSituation("player", frame.unit)
				if status then
					if(status == 3) then --Securely Tanking
						if(E:GetPlayerRole() == "TANK") then
							r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
							scale = self.db.threat.goodScale
						else
							r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
							scale = self.db.threat.badScale
						end
					elseif(status == 2) then --insecurely tanking
						if(E:GetPlayerRole() == "TANK") then
							r, g, b = self.db.threat.badTransition.r, self.db.threat.badTransition.g, self.db.threat.badTransition.b
						else
							r, g, b = self.db.threat.goodTransition.r, self.db.threat.goodTransition.g, self.db.threat.goodTransition.b
						end
						scale = 1
					elseif(status == 1) then --not tanking but threat higher than tank
						if(E:GetPlayerRole() == "TANK") then
							r, g, b = self.db.threat.goodTransition.r, self.db.threat.goodTransition.g, self.db.threat.goodTransition.b
						else
							r, g, b = self.db.threat.badTransition.r, self.db.threat.badTransition.g, self.db.threat.badTransition.b
						end
						scale = 1
					else -- not tanking at all
						if(E:GetPlayerRole() == "TANK") then
							--Check if it is being tanked by an offtank.
							if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and self.db.threat.beingTankedByTank then
								r, g, b = self.db.threat.beingTankedByTankColor.r, self.db.threat.beingTankedByTankColor.g, self.db.threat.beingTankedByTankColor.b
								scale = self.db.threat.goodScale
							else
								r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
								scale = self.db.threat.badScale
							end
						else
							if (IsInRaid() or IsInGroup()) and frame.isBeingTanked and self.db.threat.beingTankedByTank then
								r, g, b = self.db.threat.beingTankedByTankColor.r, self.db.threat.beingTankedByTankColor.g, self.db.threat.beingTankedByTankColor.b
								scale = self.db.threat.goodScale
							else
								r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
								scale = self.db.threat.goodScale
							end
						end
					end
				end

				if (not status) or (status and not self.db.threat.useThreatColor) then
					local reactionType = UnitReaction(frame.displayedUnit, "player")
					if reactionType then
						if reactionType == 4 then
							r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
						elseif reactionType > 4 then
							r, g, b = self.db.reactions.good.r, self.db.reactions.good.g, self.db.reactions.good.b
						else
							r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
						end
					end
				end
			end
		end
	end

	if ( r ~= frame.HealthBar.r or g ~= frame.HealthBar.g or b ~= frame.HealthBar.b ) then
		if not frame.HealthColorChanged then
			frame.HealthBar:SetStatusBarColor(r, g, b);
			if frame.HealthColorChangeCallbacks then
				for _, cb in ipairs(frame.HealthColorChangeCallbacks) do
					cb(self, frame, r, g, b);
				end
			end
		end
		frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b = r, g, b;
	end

	if(not frame.isTarget or not self.db.useTargetScale) then
		frame.ThreatScale = scale
		if not frame.ScaleChanged then
			self:SetFrameScale(frame, scale)
		end
	end
end

function mod:UpdateFillBar(frame, previousTexture, bar, amount, inverted)
	if amount == 0 then
		bar:Hide();
		return previousTexture;
	end

	bar:ClearAllPoints()

	if inverted then
		bar:Point("TOPRIGHT", previousTexture, "TOPRIGHT");
		bar:Point("BOTTOMRIGHT", previousTexture, "BOTTOMRIGHT");
	else
		bar:Point("TOPLEFT", previousTexture, "TOPRIGHT");
		bar:Point("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT");
	end

	local totalWidth = frame:GetSize();
	bar:SetWidth(totalWidth);

	return bar:GetStatusBarTexture();
end

function mod:UpdateElement_HealPrediction(frame)
	local unit = frame.displayedUnit or frame.unit
	local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	local absorb = UnitGetTotalAbsorbs(unit) or 0
	local healAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local otherIncomingHeal = 0
	--local hasOverHealAbsorb = false

	local maxOverflow = 1
	if(healAbsorb > allIncomingHeal) then
		healAbsorb = healAbsorb - allIncomingHeal
		allIncomingHeal = 0
		myIncomingHeal = 0

		if(health < healAbsorb) then
			--hasOverHealAbsorb = true
			healAbsorb = health
		end
	else
		allIncomingHeal = allIncomingHeal - healAbsorb
		healAbsorb = 0

		if(health + allIncomingHeal > maxHealth * maxOverflow) then
			allIncomingHeal = maxHealth * maxOverflow - health
		end

		if(allIncomingHeal < myIncomingHeal) then
			myIncomingHeal = allIncomingHeal
		else
			otherIncomingHeal = allIncomingHeal - myIncomingHeal
		end
	end

	--local hasOverAbsorb = false
	if(health + allIncomingHeal + absorb >= maxHealth) then
		--[[if(absorb > 0) then
			hasOverAbsorb = true
		end]]

		absorb = max(0, maxHealth - health - allIncomingHeal)
	end

	frame.PersonalHealPrediction:SetMinMaxValues(0, maxHealth)
	frame.PersonalHealPrediction:SetValue(myIncomingHeal)
	frame.PersonalHealPrediction:Show()

	frame.HealPrediction:SetMinMaxValues(0, maxHealth)
	frame.HealPrediction:SetValue(otherIncomingHeal)
	frame.HealPrediction:Show()

	frame.AbsorbBar:SetMinMaxValues(0, maxHealth)
	frame.AbsorbBar:SetValue(absorb)
	frame.AbsorbBar:Show()

	local previousTexture = frame.HealthBar:GetStatusBarTexture();
	mod:UpdateFillBar(frame.HealthBar, previousTexture, frame.HealAbsorbBar, healAbsorb, true);
	previousTexture = mod:UpdateFillBar(frame.HealthBar, previousTexture, frame.PersonalHealPrediction, myIncomingHeal);
	previousTexture = mod:UpdateFillBar(frame.HealthBar, previousTexture, frame.HealPrediction, allIncomingHeal);
	mod:UpdateFillBar(frame.HealthBar, previousTexture, frame.AbsorbBar, absorb);
end

function mod:UpdateElement_MaxHealth(frame)
	local maxHealth = UnitHealthMax(frame.displayedUnit);
	frame.HealthBar:SetMinMaxValues(0, maxHealth)
	if frame.MaxHealthChangeCallbacks then
		for _, cb in ipairs(frame.MaxHealthChangeCallbacks) do
			cb(self, frame, maxHealth);
		end
	end
end

function mod:UpdateElement_Health(frame)
	local health = UnitHealth(frame.displayedUnit);
	local _, maxHealth = frame.HealthBar:GetMinMaxValues()

	if frame.HealthValueChangeCallbacks then
		for _, cb in ipairs(frame.HealthValueChangeCallbacks) do
			cb(self, frame, health);
		end
	end

	frame.HealthBar:SetValue(health)
	frame.FlashTexture:Point("TOPRIGHT", frame.HealthBar:GetStatusBarTexture(), "TOPRIGHT") --idk why this fixes this

	if self.db.units[frame.UnitType].healthbar.text.enable then
		frame.HealthBar.text:SetText(E:GetFormattedText(self.db.units[frame.UnitType].healthbar.text.format, health, maxHealth))
	else
		frame.HealthBar.text:SetText("")
	end
end

function mod:RegisterHealthBarCallbacks(frame, valueChangeCB, colorChangeCB, maxHealthChangeCB)
	if (valueChangeCB) then
		frame.HealthValueChangeCallbacks = frame.HealthValueChangeCallbacks or {};
		tinsert(frame.HealthValueChangeCallbacks, valueChangeCB);
	end

	if (colorChangeCB) then
		frame.HealthColorChangeCallbacks = frame.HealthColorChangeCallbacks or {};
		tinsert(frame.HealthColorChangeCallbacks, colorChangeCB);
	end

	if (maxHealthChangeCB) then
		frame.MaxHealthChangeCallbacks = frame.MaxHealthChangeCallbacks or {};
		tinsert(frame.MaxHealthChangeCallbacks, maxHealthChangeCB)
	end
end

function mod:ConfigureElement_HealthBar(frame, configuring)
	local healthBar = frame.HealthBar
	local absorbBar = frame.AbsorbBar
	local healAbsorbBar = frame.HealAbsorbBar
	local otherHeals = frame.HealPrediction
	local myHeals = frame.PersonalHealPrediction

	--Position
	healthBar:SetPoint("BOTTOM", frame, "BOTTOM", 0, self.db.units[frame.UnitType].castbar.height + 3)
	if(UnitIsUnit(frame.unit, "target") and not frame.isTarget and self.db.useTargetScale) then
		healthBar:SetHeight(self.db.units[frame.UnitType].healthbar.height * self.db.targetScale)
		healthBar:SetWidth(self.db.units[frame.UnitType].healthbar.width * self.db.targetScale)
	else
		healthBar:SetHeight(self.db.units[frame.UnitType].healthbar.height)
		healthBar:SetWidth(self.db.units[frame.UnitType].healthbar.width)
	end

	--Texture
	healthBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))

	if (not configuring) and (self.db.units[frame.UnitType].healthbar.enable or frame.isTarget) then
		healthBar:Show()
	end
	if not configuring then
		absorbBar:Hide()
	end

	healthBar.text:SetAllPoints(healthBar)
	healthBar.text:SetFont(LSM:Fetch("font", self.db.healthFont), self.db.healthFontSize, self.db.healthFontOutline)

	--Heal Prediction Colors
	local c = self.db.healPrediction
	myHeals:SetStatusBarColor(c.personal.r, c.personal.g, c.personal.b, c.personal.a)
	otherHeals:SetStatusBarColor(c.others.r, c.others.g, c.others.b, c.others.a)
	absorbBar:SetStatusBarColor(c.absorbs.r, c.absorbs.g, c.absorbs.b, c.absorbs.a)
	healAbsorbBar:SetStatusBarColor(c.healAbsorbs.r, c.healAbsorbs.g, c.healAbsorbs.b, c.healAbsorbs.a)
end

function mod:ConstructElement_HealthBar(parent)
	local frame = CreateFrame("StatusBar", "$parentHealthBar", parent)
	self:StyleFrame(frame)

	parent.AbsorbBar = CreateFrame("StatusBar", "$parentAbsorbBar", frame)
	parent.AbsorbBar:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))

	parent.HealAbsorbBar = CreateFrame("StatusBar", "$parentHealAbsorbBar", frame)
	parent.HealAbsorbBar:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))

	parent.HealPrediction = CreateFrame("StatusBar", "$parentHealPrediction", frame)
	parent.HealPrediction:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))

	parent.PersonalHealPrediction = CreateFrame("StatusBar", "$parentPersonalHealPrediction", frame)
	parent.PersonalHealPrediction:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))

	parent.FlashTexture = frame:CreateTexture(nil, "OVERLAY")
	parent.FlashTexture:SetTexture(LSM:Fetch("background", "ElvUI Blank"))
	parent.FlashTexture:Point("BOTTOMLEFT", frame:GetStatusBarTexture(), "BOTTOMLEFT")
	parent.FlashTexture:Point("TOPRIGHT", frame:GetStatusBarTexture(), "TOPRIGHT")
	parent.FlashTexture:Hide()

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetWordWrap(false)
	frame.scale = CreateAnimationGroup(frame)

	frame.scale.width = frame.scale:CreateAnimation("Width")
	frame.scale.width:SetDuration(0.2)
	frame.scale.height = frame.scale:CreateAnimation("Height")
	frame.scale.height:SetDuration(0.2)
	frame:Hide()
	return frame
end
