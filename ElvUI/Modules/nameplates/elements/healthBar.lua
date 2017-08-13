local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
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

	local r, g, b;
	local scale = 1
	if ( not UnitIsConnected(frame.unit) ) then
		r, g, b = self.db.reactions.offline.r, self.db.reactions.offline.g, self.db.reactions.offline.b
	else
		if ( frame.HealthBar.ColorOverride ) then
			--[[local healthBarColorOverride = frame.optionTable.healthBarColorOverride;
			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b;]]
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
					--By Reaction
					local reactionType = UnitReaction(frame.unit, "player")
					if(reactionType == 4) then
						r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
					elseif(reactionType > 4) then
						r, g, b = self.db.reactions.good.r, self.db.reactions.good.g, self.db.reactions.good.b
					else
						r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
					end
				end
			end
		end
	end

	if ( r ~= frame.HealthBar.r or g ~= frame.HealthBar.g or b ~= frame.HealthBar.b ) then
		frame.HealthBar:SetStatusBarColor(r, g, b);
		frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b = r, g, b;
	end

	if(not frame.isTarget or not self.db.useTargetScale) then
		frame.ThreatScale = scale
		self:SetFrameScale(frame, scale)
	end
end

local function UpdateFillBar(frame, previousTexture, bar, amount)
	if ( amount == 0 ) then
		bar:Hide();
		return previousTexture;
	end

	bar:ClearAllPoints()
	bar:Point("TOPLEFT", previousTexture, "TOPRIGHT");
	bar:Point("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT");

	local totalWidth = frame:GetSize();
	bar:SetWidth(totalWidth);

	return bar:GetStatusBarTexture();
end

function mod:UpdateElement_HealPrediction(frame)
	local unit = frame.displayedUnit or frame.unit
	local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0
	local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

	if(health < myCurrentHealAbsorb) then
		myCurrentHealAbsorb = health
	end

	local maxOverflow = 1
	if(health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * maxOverflow) then
		allIncomingHeal = maxHealth * maxOverflow - health + myCurrentHealAbsorb
	end

	local otherIncomingHeal = 0
	if(allIncomingHeal < myIncomingHeal) then
		myIncomingHeal = allIncomingHeal
	else
		otherIncomingHeal = allIncomingHeal - myIncomingHeal
	end

	if(health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth) then
		if(allIncomingHeal > myCurrentHealAbsorb) then
			totalAbsorb = max(0, maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal))
		else
			totalAbsorb = max(0, maxHealth - health)
		end
	end

	if(myCurrentHealAbsorb > allIncomingHeal) then
		myCurrentHealAbsorb = myCurrentHealAbsorb - allIncomingHeal
	else
		myCurrentHealAbsorb = 0
	end

	frame.PersonalHealPrediction:SetMinMaxValues(0, maxHealth)
	frame.PersonalHealPrediction:SetValue(myIncomingHeal)
	frame.PersonalHealPrediction:Show()

	frame.HealPrediction:SetMinMaxValues(0, maxHealth)
	frame.HealPrediction:SetValue(otherIncomingHeal)
	frame.HealPrediction:Show()


	frame.AbsorbBar:SetMinMaxValues(0, maxHealth)
	frame.AbsorbBar:SetValue(totalAbsorb)
	frame.AbsorbBar:Show()

	local previousTexture = frame.HealthBar:GetStatusBarTexture();
	previousTexture = UpdateFillBar(frame.HealthBar, previousTexture, frame.PersonalHealPrediction , myIncomingHeal);
	previousTexture = UpdateFillBar(frame.HealthBar, previousTexture, frame.HealPrediction, allIncomingHeal);
	previousTexture = UpdateFillBar(frame.HealthBar, previousTexture, frame.AbsorbBar, totalAbsorb);
end


function mod:UpdateElement_MaxHealth(frame)
	local maxHealth = UnitHealthMax(frame.displayedUnit);
	frame.HealthBar:SetMinMaxValues(0, maxHealth)
end

function mod:UpdateElement_Health(frame)
	local health = UnitHealth(frame.displayedUnit);
	local _, maxHealth = frame.HealthBar:GetMinMaxValues()

	frame.HealthBar:SetValue(health)

	if self.db.units[frame.UnitType].healthbar.text.enable then
		frame.HealthBar.text:SetText(E:GetFormattedText(self.db.units[frame.UnitType].healthbar.text.format, health, maxHealth))
	else
		frame.HealthBar.text:SetText("")
	end
end

function mod:ConfigureElement_HealthBar(frame, configuring)
	local healthBar = frame.HealthBar
	local absorbBar = frame.AbsorbBar

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
	if(not configuring) and (self.db.units[frame.UnitType].healthbar.enable or frame.isTarget) then
		healthBar:Show()
	end
	absorbBar:Hide()

	healthBar.text:SetAllPoints(healthBar)
	healthBar.text:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)	
end

function mod:ConstructElement_HealthBar(parent)
	local frame = CreateFrame("StatusBar", "$parentHealthBar", parent)
	self:StyleFrame(frame)

	parent.AbsorbBar = CreateFrame("StatusBar", "$parentAbsorbBar", frame)
	parent.AbsorbBar:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))
	parent.AbsorbBar:SetStatusBarColor(1, 1, 0, 0.25)

	parent.HealPrediction = CreateFrame("StatusBar", "$parentHealPrediction", frame)
	parent.HealPrediction:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))
	parent.HealPrediction:SetStatusBarColor(0, 1, 0, 0.25)

	parent.PersonalHealPrediction = CreateFrame("StatusBar", "$parentPersonalHealPrediction", frame)
	parent.PersonalHealPrediction:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))
	parent.PersonalHealPrediction:SetStatusBarColor(0, 1, 0.5, 0.25)

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