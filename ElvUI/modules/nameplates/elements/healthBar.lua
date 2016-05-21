local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")
local max = math.max

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
			local _, class = UnitClass(frame.unit);
			local classColor = RAID_CLASS_COLORS[class];
			if ( (frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "HEALER" or frame.UnitType == "ENEMY_PLAYER" or frame.UnitType == "PLAYER") and classColor ) then
				-- Use class colors for players if class color option is turned on
				r, g, b = classColor.r, classColor.g, classColor.b;
			elseif ( not UnitPlayerControlled(frame.unit) and UnitIsTapDenied(frame.unit) ) then
				-- Use grey if not a player and can't get tap on unit
				r, g, b = self.db.reactions.tapped.r, self.db.reactions.tapped.g, self.db.reactions.tapped.b	
			else
				-- Use color based on the type of unit (neutral, etc.)
				local isTanking, status = UnitDetailedThreatSituation("player", frame.unit)
				if status then
					if(isTanking) then
						if(E:GetPlayerRole() == "TANK") then
							r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
							scale = self.db.threat.goodScale
						else
							r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
							scale = self.db.threat.badScale
						end
					else
						if(E:GetPlayerRole() == "TANK") then
							--Check if it is being tanked by an offtank.
							if (IsInRaid() or IsInGroup()) and frame.isBeingTanked then
								r, g, b = .8, 0.1, 1
								scale = self.db.threat.goodScale
							else
								r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
								scale = self.db.threat.badScale
							end
						else
							if (IsInRaid() or IsInGroup()) and frame.isBeingTanked then
								r, g, b = .8, 0.1, 1
								scale = self.db.threat.goodScale
							else
								r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
								scale = self.db.threat.goodScale
							end	
						end
					end
				else
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
	local unit = frame.unit
	local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0
	local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

	local overHealAbsorb = false
	if(health < myCurrentHealAbsorb) then
		overHealAbsorb = true
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

	local overAbsorb = false
	if(health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth) then
		if(totalAbsorb > 0) then
			overAbsorb = true
		end


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
	local maxHealth = UnitHealthMax(frame.unit);
	frame.HealthBar:SetMinMaxValues(0, maxHealth)
end

function mod:UpdateElement_Health(frame)
	local health = UnitHealth(frame.unit);
	frame.HealthBar:SetValue(health)
end

function mod:ConfigureElement_HealthBar(frame, configuring)
	local healthBar = frame.HealthBar
	local absorbBar = frame.AbsorbBar
	local isShown = healthBar:IsShown()
	
	--Position
	healthBar:SetPoint("BOTTOM", frame, "BOTTOM", 0, self.db.units[frame.UnitType].castbar.height + 3)
	healthBar:SetHeight(self.db.units[frame.UnitType].healthbar.height)
	healthBar:SetWidth(self.db.units[frame.UnitType].healthbar.width)

	--Texture
	healthBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
	if(not configuring) then
		healthBar:Show()
	end
	absorbBar:Hide()
end

function mod:ConstructElement_HealthBar(parent)
	local frame = CreateFrame("StatusBar", "$parentHealthBar", parent)
	self:StyleFrame(frame, true)
	
	parent.AbsorbBar = CreateFrame("StatusBar", "$parentAbsorbBar", frame)
	parent.AbsorbBar:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))
	parent.AbsorbBar:SetStatusBarColor(1, 1, 0, 0.25)

	parent.HealPrediction = CreateFrame("StatusBar", "$parentHealPrediction", frame)
	parent.HealPrediction:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))
	parent.HealPrediction:SetStatusBarColor(0, 1, 0, 0.25)
	
	parent.PersonalHealPrediction = CreateFrame("StatusBar", "$parentPersonalHealPrediction", frame)
	parent.PersonalHealPrediction:SetStatusBarTexture(LSM:Fetch("background", "ElvUI Blank"))
	parent.PersonalHealPrediction:SetStatusBarColor(0, 1, 0.5, 0.25)
		
	
	frame.scale = CreateAnimationGroup(frame)
	
	frame.scale.width = frame.scale:CreateAnimation("Width")
	frame.scale.width:SetDuration(0.2)
	frame.scale.height = frame.scale:CreateAnimation("Height")
	frame.scale.height:SetDuration(0.2)	
	frame:Hide()
	return frame
end