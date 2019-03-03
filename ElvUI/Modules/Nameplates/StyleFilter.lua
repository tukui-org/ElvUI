local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates');
local LSM = E.Libs.LSM;

local _G = _G
local ipairs, next, pairs, rawget, rawset, select = ipairs, next, pairs, rawget, rawset, select
local setmetatable, tonumber, type, unpack = setmetatable, tonumber, type, unpack
local gsub, strsplit, tinsert, tremove, sort, wipe = gsub, strsplit, tinsert, tremove, sort, wipe

local GetInstanceInfo = GetInstanceInfo
local GetPvpTalentInfo = GetPvpTalentInfo
local GetSpecializationInfo = GetSpecializationInfo
local GetSpellCharges = GetSpellCharges
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetTalentInfo = GetTalentInfo
local GetTime = GetTime
local UnitAffectingCombat = UnitAffectingCombat
local UnitClassification = UnitClassification
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsQuestBoss = UnitIsQuestBoss
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitReaction = UnitReaction
local PowerBarColor = PowerBarColor
local C_Timer_NewTimer = C_Timer.NewTimer
local INTERRUPTED = INTERRUPTED
local FAILED = FAILED

local FallbackColor = {r=1, b=1, g=1}

function mod:StyleFilterAuraWaitTimer(frame, button, varTimerName, timeLeft, mTimeLeft)
	if button and not button[varTimerName] then
		local updateIn = timeLeft-mTimeLeft
		if updateIn > 0 then
			-- also add a tenth of a second to updateIn to prevent the timer from firing on the same second
            button[varTimerName] = C_Timer_NewTimer(updateIn+0.1, function()
				if frame and frame:IsShown() then
					mod:StyleFilterUpdate(frame, 'FAKE_AuraWaitTimer')
                end
                if button and button[varTimerName] then
	                button[varTimerName] = nil
	            end
            end)
		end
    end
end

function mod:StyleFilterAuraCheck(frame, names, auras, mustHaveAll, missing, minTimeLeft, maxTimeLeft)
	local total, count, isSpell, timeLeft, hasMinTime, hasMaxTime, minTimeAllow, maxTimeAllow = 0, 0
	for name, value in pairs(names) do
		if value == true then --only if they are turned on
			total = total + 1 --keep track of the names
		end

		if auras.createdIcons and auras.createdIcons > 0 then
			for i = 1, auras.createdIcons do
				local button = auras[i]
				if button and button:IsShown() then
					isSpell = (button.name and button.name == name) or (button.spellID and button.spellID == tonumber(name))
					if isSpell and (value == true) then
						hasMinTime = minTimeLeft and minTimeLeft ~= 0
						hasMaxTime = maxTimeLeft and maxTimeLeft ~= 0
						timeLeft = (hasMinTime or hasMaxTime) and button.expiration and (button.expiration - GetTime())
						minTimeAllow = not hasMinTime or (timeLeft and timeLeft > minTimeLeft)
						maxTimeAllow = not hasMaxTime or (timeLeft and timeLeft < maxTimeLeft)
						if timeLeft then -- if we use a min/max time setting; we must create a delay timer
							if hasMinTime then self:StyleFilterAuraWaitTimer(frame, button, 'hasMinTimer', timeLeft, minTimeLeft) end
							if hasMaxTime then self:StyleFilterAuraWaitTimer(frame, button, 'hasMaxTimer', timeLeft, maxTimeLeft) end
						end
						if minTimeAllow and maxTimeAllow then
							count = count + 1 --keep track of how many matches we have
						end
					end
				end
			end
		end
	end

	if total == 0 then
		return nil --If no auras are checked just pass nil, we dont need to run the filter here.
	else
		return ((mustHaveAll and not missing) and total == count)	-- [x] Check for all [ ] Missing: total needs to match count
		or ((not mustHaveAll and not missing) and count > 0)		-- [ ] Check for all [ ] Missing: count needs to be greater than zero
		or ((not mustHaveAll and missing) and count == 0)			-- [ ] Check for all [x] Missing: count needs to be zero
		or ((mustHaveAll and missing) and total ~= count)			-- [x] Check for all [x] Missing: count must not match total
	end
end

function mod:StyleFilterCooldownCheck(names, mustHaveAll)
	local total, count, duration, charges = 0, 0
	local _, gcd = GetSpellCooldown(61304)

	for name, value in pairs(names) do
		if value == "ONCD" or value == "OFFCD" then --only if they are turned on
			total = total + 1 --keep track of the names

			charges = GetSpellCharges(name)
			_, duration = GetSpellCooldown(name)

			if (charges and charges == 0 and value == "ONCD") --charges exist and the current number of charges is 0 means that it is completely on cooldown.
			or (charges and charges > 0 and value == "OFFCD") --charges exist and the current number of charges is greater than 0 means it is not on cooldown.
			or (charges == nil and (duration > gcd and value == "ONCD")) --no charges exist and the duration of the cooldown is greater than the GCD spells current cooldown then it is on cooldown.
			or (charges == nil and (duration <= gcd and value == "OFFCD")) then --no charges exist and the duration of the cooldown is at or below the current GCD cooldown spell then it is not on cooldown.
				count = count + 1
				--print(((charges and charges == 0 and value == "ONCD") and name.." (charge) passes because it is on cd") or ((charges and charges > 0 and value == "OFFCD") and name.." (charge) passes because it is offcd") or ((charges == nil and (duration > gcd and value == "ONCD")) and name.."passes because it is on cd.") or ((charges == nil and (duration <= gcd and value == "OFFCD")) and name.." passes because it is off cd."))
			end
		end
	end

	if total == 0 then
		return nil
	else
		return (mustHaveAll and total == count) or (not mustHaveAll and count > 0)
	end
end

function mod:StyleFilterSetUpFlashAnim(FlashTexture)
	FlashTexture.anim = FlashTexture:CreateAnimationGroup("Flash")
	FlashTexture.anim.fadein = FlashTexture.anim:CreateAnimation("ALPHA", "FadeIn")
	FlashTexture.anim.fadein:SetFromAlpha(0)
	FlashTexture.anim.fadein:SetToAlpha(1)
	FlashTexture.anim.fadein:SetOrder(2)

	FlashTexture.anim.fadeout = FlashTexture.anim:CreateAnimation("ALPHA", "FadeOut")
	FlashTexture.anim.fadeout:SetFromAlpha(1)
	FlashTexture.anim.fadeout:SetToAlpha(0)
	FlashTexture.anim.fadeout:SetOrder(1)

	FlashTexture.anim:SetScript("OnFinished", function(flash, requested)
		if not requested then flash:Play() end
	end)
end

function mod:StyleFilterBorderColorLock(backdrop, switch)
	if switch == true then
		backdrop.ignoreBorderColors = true --but keep the backdrop updated
	else
		backdrop.ignoreBorderColors = nil --restore these borders to be updated
	end
end

function mod:StyleFilterSetChanges(frame, actions, HealthColorChanged, PowerColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, AlphaChanged, NameColorChanged, PortraitShown, NameOnlyChanged, VisibilityChanged)
	if VisibilityChanged then
		--[[
		frame.StyleChanged = true
		frame.VisibilityChanged = true
		frame:Hide()
		return --We hide it. Lets not do other things (no point)
		]]
	end
	if HealthColorChanged then
		frame.StyleChanged = true
		frame.HealthColorChanged = true
		frame.Health:SetStatusBarColor(actions.color.healthColor.r, actions.color.healthColor.g, actions.color.healthColor.b, actions.color.healthColor.a);
		if frame.CutawayHealth then
			frame.CutawayHealth:SetStatusBarColor(actions.color.healthColor.r * 1.5, actions.color.healthColor.g * 1.5, actions.color.healthColor.b * 1.5, actions.color.healthColor.a);
		end
	end
	if PowerColorChanged then
		frame.StyleChanged = true
		frame.PowerColorChanged = true
		frame.Power:SetStatusBarColor(actions.color.powerColor.r, actions.color.powerColor.g, actions.color.powerColor.b, actions.color.powerColor.a);
	end
	if BorderChanged then
		frame.StyleChanged = true
		frame.BorderChanged = true
		mod:StyleFilterBorderColorLock(frame.Health.backdrop, true)
		frame.Health.backdrop:SetBackdropBorderColor(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		if frame.Power.backdrop and (frame.frameType and mod.db.units[frame.frameType].power and mod.db.units[frame.frameType].power.enable) then
			mod:StyleFilterBorderColorLock(frame.Power.backdrop, true)
			frame.Power.backdrop:SetBackdropBorderColor(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		end
	end
	if FlashingHealth then
		frame.StyleChanged = true
		frame.FlashingHealth = true
		if not TextureChanged then
			frame.FlashTexture:SetTexture(LSM:Fetch("statusbar", self.db.statusbar))
		end
		frame.FlashTexture:SetVertexColor(actions.flash.color.r, actions.flash.color.g, actions.flash.color.b)
		if not frame.FlashTexture.anim then
			self:StyleFilterSetUpFlashAnim(frame.FlashTexture)
		end
		frame.FlashTexture.anim.fadein:SetToAlpha(actions.flash.color.a)
		frame.FlashTexture.anim.fadeout:SetFromAlpha(actions.flash.color.a)
		frame.FlashTexture:Show()
		E:Flash(frame.FlashTexture, actions.flash.speed * 0.1, true)
	end
	if TextureChanged then
		frame.StyleChanged = true
		frame.TextureChanged = true
		frame.Highlight.texture:SetTexture(LSM:Fetch("statusbar", actions.texture.texture))
		frame.Health:SetStatusBarTexture(LSM:Fetch("statusbar", actions.texture.texture))
		if FlashingHealth then
			frame.FlashTexture:SetTexture(LSM:Fetch("statusbar", actions.texture.texture))
		end
	end
	if ScaleChanged then
	--[[
		frame.StyleChanged = true
		frame.ScaleChanged = true
		local scale = actions.scale
		if frame.isTarget and self.db.useTargetScale then
			scale = scale * self.db.targetScale
		end
		self:SetFrameScale(frame, scale)
	]]
	end
	if AlphaChanged then
		frame.StyleChanged = true
		frame.AlphaChanged = true
		frame:SetAlpha(actions.alpha / 100)
	end
	if NameColorChanged then
		frame.StyleChanged = true
		frame.NameColorChanged = true
		local nameText = frame.Name:GetText()
		if nameText and nameText ~= "" then
			frame.Name:SetText(gsub(nameText, '|c[fF][fF]%x%x%x%x%x%x', ''))
			frame.Name:SetTextColor(actions.color.nameColor.r, actions.color.nameColor.g, actions.color.nameColor.b, actions.color.nameColor.a)
		end
	end
	if PortraitShown then
		frame.StyleChanged = true
		frame.PortraitShown = true
		self:Update_Portrait(frame)
		frame.Portrait:ForceUpdate()
	end
	if NameOnlyChanged then
	--[[
		frame.StyleChanged = true
		frame.NameOnlyChanged = true
		--hide the bars
		if frame.Castbar:IsShown() then frame.Castbar:Hide() end
		if frame.Power:IsShown() then frame.Power:Hide() end
		if frame.Health:IsShown() then frame.Health:Hide() end
		--hide the target indicator
		self:UpdateElement_Glow(frame)
		--position the name and update its color
		frame.Name:ClearAllPoints()
		frame.Name:SetJustifyH("CENTER")
		frame.Name:Point("TOP", frame, "CENTER")
		frame.Level:ClearAllPoints()
		frame.Level:Point("LEFT", frame.Name, "RIGHT")
		frame.Level:SetJustifyH("LEFT")
		if not NameColorChanged then
			self:UpdateElement_Name(frame, true)
		end
		--show the npc title
		self:UpdateElement_NPCTitle(frame, true)
		--position the portrait
		self:ConfigureElement_Portrait(frame, true)
		--position suramar detection
		self:ConfigureElement_Detection(frame, frame.Portrait:IsShown() and frame.Portrait)
	]]
	end
end

function mod:StyleFilterClearChanges(frame, HealthColorChanged, PowerColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, AlphaChanged, NameColorChanged, PortraitShown, NameOnlyChanged, VisibilityChanged)
	frame.StyleChanged = nil
	if VisibilityChanged then
		frame.VisibilityChanged = nil
		frame:Show()
	end
	if HealthColorChanged then
		frame.HealthColorChanged = nil
		frame.Health:SetStatusBarColor(frame.Health.r, frame.Health.g, frame.Health.b);
		if frame.CutawayHealth then
			frame.CutawayHealth:SetStatusBarColor(frame.Health.r * 1.5, frame.Health.g * 1.5, frame.Health.b * 1.5, 1);
		end
	end
	if PowerColorChanged then
		frame.PowerColorChanged = nil
		local color = E.db.unitframe.colors.power[frame.Power.token] or PowerBarColor[frame.Power.token] or FallbackColor
		if color then
			frame.Power:SetStatusBarColor(color.r, color.g, color.b)
		end
	end
	if BorderChanged then
		frame.BorderChanged = nil
		mod:StyleFilterBorderColorLock(frame.Health.backdrop, false)
		frame.Health.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		if frame.Power.backdrop and (frame.frameType and mod.db.units[frame.frameType].power and mod.db.units[frame.frameType].power.enable) then
			mod:StyleFilterBorderColorLock(frame.Power.backdrop, false)
			frame.Power.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end
	if FlashingHealth then
		frame.FlashingHealth = nil
		E:StopFlash(frame.FlashTexture)
		frame.FlashTexture:Hide()
	end
	if TextureChanged then
		frame.TextureChanged = nil
		frame.Highlight.texture:SetTexture(LSM:Fetch("statusbar", self.db.statusbar))
		frame.Health:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
	end
	if ScaleChanged then
		frame.ScaleChanged = nil
		if frame.isTarget and self.db.useTargetScale then
			self:SetFrameScale(frame, self.db.targetScale)
		else
			self:SetFrameScale(frame, frame.ThreatScale or 1)
		end
	end
	if AlphaChanged then
		frame.AlphaChanged = nil
		if frame.isTarget then
			frame:SetAlpha(1)
		elseif not UnitIsUnit(frame.unit, "player") then
			frame:SetAlpha(1 - self.db.nonTargetTransparency)
		end
	end
	if NameColorChanged then
		frame.NameColorChanged = nil
		frame.Name:UpdateTag()
	end
	if PortraitShown then
		frame.PortraitShown = nil
		self:Update_Portrait(frame)
		frame.Portrait:ForceUpdate()
	end
	if NameOnlyChanged then
		frame.NameOnlyChanged = nil
		if (frame.frameType and self.db.units[frame.frameType].health.enable) or (self.db.displayStyle ~= "ALL") or (frame.isTarget and self.db.alwaysShowTargetHealth) then
			frame.Health:Show()
			self:UpdateElement_Glow(frame)
			if self.db.units[frame.frameType].power and self.db.units[frame.frameType].power.enable then
				local curValue = UnitPower(frame.unit, frame.PowerType);
				if not (curValue == 0 and self.db.units[frame.frameType].power.hideWhenEmpty) then
					frame.Power:Show()
				end
			end
		end
		if self.db.units[frame.frameType].showName then
			self:ConfigureElement_Level(frame)
			self:ConfigureElement_Name(frame)
			self:UpdateElement_Name(frame)
		else
			frame.Name:SetText("")
		end
		if self.db.showNPCTitles then
			self:UpdateElement_NPCTitle(frame)
		else
			frame.NPCTitle:SetText("")
		end
		if self.db.units[frame.frameType].portrait.enable then
			self:ConfigureElement_Portrait(frame)
		end
	end
end

function mod:StyleFilterConditionCheck(frame, filter, trigger, failed)
	local condition, name, guid, npcid, inCombat, questBoss, reaction, spell, classification;
	local talentSelected, talentFunction, talentRows, _, instanceType, instanceDifficulty;
	local level, myLevel, curLevel, minLevel, maxLevel, matchMyLevel, myRole, mySpecID;
	local power, maxPower, percPower, underPowerThreshold, overPowerThreshold, powerUnit;
	local health, maxHealth, percHealth, underHealthThreshold, overHealthThreshold, healthUnit;

	local isCasting = frame.Castbar and (frame.Castbar.casting or frame.Castbar.channeling)
	local matchMyClass = false --Only check spec when we match the class condition

	if not failed and trigger.names and next(trigger.names) then
		condition = 0
		for unitName, value in pairs(trigger.names) do
			if value == true then --only check names that are checked
				condition = 1
				if tonumber(unitName) then
					guid = UnitGUID(frame.unit)
					if guid then
						npcid = select(6, strsplit('-', guid))
						if tonumber(unitName) == tonumber(npcid) then
							condition = 2
							break
						end
					end
				else
					name = UnitName(frame.unit)
					if unitName and unitName ~= "" and unitName == name then
						condition = 2
						break
					end
				end
			end
		end
		if condition ~= 0 then
			failed = (condition == 1)
		end
	end

	--Try to match by casting spell name or spell id
	if not failed and (trigger.casting and trigger.casting.spells) and next(trigger.casting.spells) then
		condition = 0

		for spellName, value in pairs(trigger.casting.spells) do
			if value == true then --only check spell that are checked
				condition = 1
				if isCasting then
					spell = frame.Castbar.Text:GetText() --Make sure we can check spell name
					if spell and spell ~= "" and spell ~= FAILED and spell ~= INTERRUPTED then
						if tonumber(spellName) then
							spellName = GetSpellInfo(spellName)
						end
						if spellName and spellName == spell then
							condition = 2
							break
						end
					end
				end
			end
		end
		if condition ~= 0 then --If we cant check spell name, we ignore this trigger when the castbar is shown
			failed = (condition == 1)
		end
	end

	--Try to match by casting interruptible
	if not failed and (trigger.casting and (trigger.casting.interruptible or trigger.casting.notInterruptible)) then
		condition = false
		if isCasting and ((trigger.casting.interruptible and frame.Castbar.canInterrupt) or (trigger.casting.notInterruptible and not frame.Castbar.canInterrupt)) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by player health conditions
	if not failed and trigger.healthThreshold then
		condition = false
		healthUnit = (trigger.healthUsePlayer and "player") or frame.unit
		health, maxHealth = UnitHealth(healthUnit), UnitHealthMax(healthUnit)
		percHealth = (maxHealth and (maxHealth > 0) and health/maxHealth) or 0
		underHealthThreshold = trigger.underHealthThreshold and (trigger.underHealthThreshold ~= 0) and (trigger.underHealthThreshold > percHealth)
		overHealthThreshold = trigger.overHealthThreshold and (trigger.overHealthThreshold ~= 0) and (trigger.overHealthThreshold < percHealth)
		if underHealthThreshold or overHealthThreshold then
			condition = true
		end
		failed = not condition
	end

	--Try to match by power conditions
	if not failed and trigger.powerThreshold then
		condition = false
		powerUnit = (trigger.powerUsePlayer and "player") or frame.unit
		power, maxPower = UnitPower(powerUnit, frame.PowerType), UnitPowerMax(powerUnit, frame.PowerType)
		percPower = (maxPower and (maxPower > 0) and power/maxPower) or 0
		underPowerThreshold = trigger.underPowerThreshold and (trigger.underPowerThreshold ~= 0) and (trigger.underPowerThreshold > percPower)
		overPowerThreshold = trigger.overPowerThreshold and (trigger.overPowerThreshold ~= 0) and (trigger.overPowerThreshold < percPower)
		if underPowerThreshold or overPowerThreshold then
			condition = true
		end
		failed = not condition
	end

	--Try to match by player combat conditions
	if not failed and (trigger.inCombat or trigger.outOfCombat) then
		condition = false
		inCombat = UnitAffectingCombat("player")
		if (trigger.inCombat and inCombat) or (trigger.outOfCombat and not inCombat) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by unit combat conditions
	if not failed and (trigger.inCombatUnit or trigger.outOfCombatUnit) then
		condition = false
		inCombat = UnitAffectingCombat(frame.unit)
		if (trigger.inCombatUnit and inCombat) or (trigger.outOfCombatUnit and not inCombat) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by player target conditions
	if not failed and (trigger.isTarget or trigger.notTarget) then
		condition = false
		if (trigger.isTarget and frame.isTarget) or (trigger.notTarget and not frame.isTarget) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by unit target conditions
	if not failed and (trigger.targetMe or trigger.notTargetMe) then
		condition = false
		if (trigger.targetMe and frame.isTargetingMe) or (trigger.notTargetMe and not frame.isTargetingMe) then
			condition = true
		end
		failed = not condition
	end

	--Try to match if unit is a quest boss
	if not failed and trigger.questBoss then
		condition = false
		questBoss = UnitIsQuestBoss(frame.unit)
		if questBoss then
			condition = true
		end
		failed = not condition
	end

	--Try to match by class conditions
	if not failed and trigger.class and next(trigger.class) then
		condition = false
		if trigger.class[E.myclass] and trigger.class[E.myclass].enabled then
			condition = true
			matchMyClass = true
		end
		failed = not condition
	end

	--Try to match by spec conditions
	if not failed and matchMyClass and (trigger.class[E.myclass] and trigger.class[E.myclass].specs and next(trigger.class[E.myclass].specs)) then
		condition = false
		mySpecID = E.myspec and GetSpecializationInfo(E.myspec)
		if mySpecID and trigger.class[E.myclass].specs[mySpecID] then
			condition = true
		end
		failed = not condition
	end

	--Try to match by classification conditions
	if not failed and (trigger.classification.worldboss or trigger.classification.rareelite or trigger.classification.elite or trigger.classification.rare or trigger.classification.normal or trigger.classification.trivial or trigger.classification.minus) then
		condition = false
		classification = UnitClassification(frame.unit)
		if classification
		and ((trigger.classification.worldboss and classification == "worldboss")
		or (trigger.classification.rareelite   and classification == "rareelite")
		or (trigger.classification.elite	   and classification == "elite")
		or (trigger.classification.rare		   and classification == "rare")
		or (trigger.classification.normal	   and classification == "normal")
		or (trigger.classification.trivial	   and classification == "trivial")
		or (trigger.classification.minus	   and classification == "minus")) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by role conditions
	if not failed and (trigger.role.tank or trigger.role.healer or trigger.role.damager) then
		condition = false
		myRole = E:GetPlayerRole()
		if myRole and ((trigger.role.tank and myRole == "TANK") or (trigger.role.healer and myRole == "HEALER") or (trigger.role.damager and myRole == "DAMAGER")) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by instance conditions
	if not failed and (trigger.instanceType.none or trigger.instanceType.scenario or trigger.instanceType.party or trigger.instanceType.raid or trigger.instanceType.arena or trigger.instanceType.pvp) then
		condition = false
		_, instanceType, instanceDifficulty = GetInstanceInfo()
		if instanceType
		and ((trigger.instanceType.none	  and instanceType == "none")
		or (trigger.instanceType.scenario and instanceType == "scenario")
		or (trigger.instanceType.party	  and instanceType == "party")
		or (trigger.instanceType.raid	  and instanceType == "raid")
		or (trigger.instanceType.arena	  and instanceType == "arena")
		or (trigger.instanceType.pvp	  and instanceType == "pvp")) then
			condition = true
		end
		failed = not condition
	end

	--Try to match by instance difficulty
	if not failed and (trigger.instanceType.party or trigger.instanceType.raid) then
		if trigger.instanceType.party and instanceType == "party" and (trigger.instanceDifficulty.dungeon.normal or trigger.instanceDifficulty.dungeon.heroic or trigger.instanceDifficulty.dungeon.mythic or trigger.instanceDifficulty.dungeon["mythic+"] or trigger.instanceDifficulty.dungeon.timewalking) then
			condition = false;
			if ((trigger.instanceDifficulty.dungeon.normal		and instanceDifficulty == 1)
			or (trigger.instanceDifficulty.dungeon.heroic		and instanceDifficulty == 2)
			or (trigger.instanceDifficulty.dungeon.mythic		and instanceDifficulty == 23)
			or (trigger.instanceDifficulty.dungeon["mythic+"]	and instanceDifficulty == 8)
			or (trigger.instanceDifficulty.dungeon.timewalking	and instanceDifficulty == 24)) then
				condition = true
			end
			failed = not condition;
		end

		if trigger.instanceType.raid and instanceType == "raid" and
			(trigger.instanceDifficulty.raid.lfr or trigger.instanceDifficulty.raid.normal or trigger.instanceDifficulty.raid.heroic or trigger.instanceDifficulty.raid.mythic or trigger.instanceDifficulty.raid.timewalking
			or trigger.instanceDifficulty.raid.legacy10normal or trigger.instanceDifficulty.raid.legacy25normal or trigger.instanceDifficulty.raid.legacy10heroic or trigger.instanceDifficulty.raid.legacy25heroic) then
			condition = false;
			if ((trigger.instanceDifficulty.raid.lfr           and (instanceDifficulty == 7 or instanceDifficulty == 17))
			or (trigger.instanceDifficulty.raid.normal         and instanceDifficulty == 14)
			or (trigger.instanceDifficulty.raid.heroic         and instanceDifficulty == 15)
			or (trigger.instanceDifficulty.raid.mythic         and instanceDifficulty == 16)
			or (trigger.instanceDifficulty.raid.timewalking    and instanceDifficulty == 33)
			or (trigger.instanceDifficulty.raid.legacy10normal and instanceDifficulty == 3)
			or (trigger.instanceDifficulty.raid.legacy25normal and instanceDifficulty == 4)
			or (trigger.instanceDifficulty.raid.legacy10heroic and instanceDifficulty == 5)
			or (trigger.instanceDifficulty.raid.legacy25heroic and instanceDifficulty == 6)) then
				condition = true
			end
			failed = not condition
		end
	end

	--Try to match by talent conditions
	if not failed and trigger.talent.enabled then
		condition = false

		talentFunction = (trigger.talent.type == "pvp" and GetPvpTalentInfo) or GetTalentInfo
		talentRows = (trigger.talent.type == "pvp" and 6) or 7

		for i = 1, talentRows do
			if (trigger.talent["tier"..i.."enabled"] and trigger.talent["tier"..i].column > 0) then
				talentSelected = select(4, talentFunction(i, trigger.talent["tier"..i].column, 1))
				if (talentSelected and not trigger.talent["tier"..i].missing) or (trigger.talent["tier"..i].missing and not talentSelected) then
					condition = true
					if not trigger.talent.requireAll then
						break -- break when not using requireAll because we matched one
					end
				elseif trigger.talent.requireAll then
					condition = false -- fail because requireAll failed
					break -- break because requireAll failed
				end
			end
		end

		failed = not condition
	end

	--Try to match by level conditions
	if not failed and trigger.level then
		condition = false
		myLevel = UnitLevel('player')
		level = (frame.unit == 'player' and myLevel) or UnitLevel(frame.unit)
		curLevel = (trigger.curlevel and trigger.curlevel ~= 0 and (trigger.curlevel == level))
		minLevel = (trigger.minlevel and trigger.minlevel ~= 0 and (trigger.minlevel <= level))
		maxLevel = (trigger.maxlevel and trigger.maxlevel ~= 0 and (trigger.maxlevel >= level))
		matchMyLevel = trigger.mylevel and (level == myLevel)
		if curLevel or minLevel or maxLevel or matchMyLevel then
			condition = true
		end
		failed = not condition
	end

	--Try to match by unit type
	if not failed and trigger.nameplateType and trigger.nameplateType.enable then
		condition = false

		if (trigger.nameplateType.friendlyPlayer and frame.frameType=='FRIENDLY_PLAYER')
		or (trigger.nameplateType.friendlyNPC	 and frame.frameType=='FRIENDLY_NPC')
		or (trigger.nameplateType.enemyPlayer	 and frame.frameType=='ENEMY_PLAYER')
		or (trigger.nameplateType.enemyNPC		 and frame.frameType=='ENEMY_NPC')
		or (trigger.nameplateType.healer		 and frame.frameType=='HEALER')
		or (trigger.nameplateType.player		 and frame.frameType=='PLAYER') then
			condition = true
		end

		failed = not condition
	end

	--Try to match by Reaction (or Reputation) type
	if not failed and trigger.reactionType and trigger.reactionType.enable then
		reaction = (trigger.reactionType.reputation and UnitReaction(frame.unit, 'player')) or UnitReaction('player', frame.unit)
		condition = false

		if (reaction==1 and trigger.reactionType.hated)
		or (reaction==2 and trigger.reactionType.hostile)
		or (reaction==3 and trigger.reactionType.unfriendly)
		or (reaction==4 and trigger.reactionType.neutral)
		or (reaction==5 and trigger.reactionType.friendly)
		or (reaction==6 and trigger.reactionType.honored)
		or (reaction==7 and trigger.reactionType.revered)
		or (reaction==8 and trigger.reactionType.exalted) then
			condition = true
		end

		failed = not condition
	end

	--Try to match according to cooldown conditions
	if not failed and trigger.cooldowns and trigger.cooldowns.names and next(trigger.cooldowns.names) then
		condition = self:StyleFilterCooldownCheck(trigger.cooldowns.names, trigger.cooldowns.mustHaveAll)
		if condition ~= nil then --Condition will be nil if none are set to ONCD or OFFCD
			failed = not condition
		end
	end

	--Try to match according to buff aura conditions
	if not failed and trigger.buffs and trigger.buffs.names and next(trigger.buffs.names) then
		condition = self:StyleFilterAuraCheck(frame, trigger.buffs.names, frame.Buffs, trigger.buffs.mustHaveAll, trigger.buffs.missing, trigger.buffs.minTimeLeft, trigger.buffs.maxTimeLeft)
		if condition ~= nil then --Condition will be nil if none are selected
			failed = not condition
		end
	end

	--Try to match according to debuff aura conditions
	if not failed and trigger.debuffs and trigger.debuffs.names and next(trigger.debuffs.names) then
		condition = self:StyleFilterAuraCheck(frame, trigger.debuffs.names, frame.Debuffs, trigger.debuffs.mustHaveAll, trigger.debuffs.missing, trigger.debuffs.minTimeLeft, trigger.debuffs.maxTimeLeft)
		if condition ~= nil then --Condition will be nil if none are selected
			failed = not condition
		end
	end

	--Callback for Plugins
	if self.CustomStyleConditions then
		failed = self:CustomStyleConditions(frame, filter, trigger, failed)
	end

	--If failed is nil it means the filter is empty so we dont run FilterStyle
	if failed == false then --The conditions didn't fail so pass to FilterStyle
		self:StyleFilterPass(frame, filter.actions);
	end
end

function mod:StyleFilterPass(frame, actions)
	local healthBarEnabled = (frame.frameType and mod.db.units[frame.frameType].health.enable) or (mod.db.displayStyle ~= "ALL") or (frame.isTarget and mod.db.alwaysShowTargetHealth)
	local powerBarEnabled = frame.frameType and mod.db.units[frame.frameType].power and mod.db.units[frame.frameType].power.enable
	local healthBarShown = healthBarEnabled and frame.Health:IsShown()

	self:StyleFilterSetChanges(frame, actions,
		(healthBarShown and actions.color and actions.color.health), --HealthColorChanged
		(healthBarShown and powerBarEnabled and actions.color and actions.color.power), --PowerColorChanged
		(healthBarShown and actions.color and actions.color.border and frame.Health.backdrop), --BorderChanged
		(healthBarShown and actions.flash and actions.flash.enable and frame.FlashTexture), --FlashingHealth
		(healthBarShown and actions.texture and actions.texture.enable), --TextureChanged
		(healthBarShown and actions.scale and actions.scale ~= 1), --ScaleChanged
		(actions.alpha and actions.alpha ~= -1), --AlphaChanged
		(actions.color and actions.color.name), --NameColorChanged
		(actions.usePortrait), --PortraitShown
		(actions.nameOnly), --NameOnlyChanged
		(actions.hide) --VisibilityChanged
	)
end

function mod:ClearStyledPlate(frame)
	if frame.StyleChanged then
		self:StyleFilterClearChanges(frame, frame.HealthColorChanged, frame.PowerColorChanged, frame.BorderChanged, frame.FlashingHealth, frame.TextureChanged, frame.ScaleChanged, frame.AlphaChanged, frame.NameColorChanged, frame.PortraitShown, frame.NameOnlyChanged, frame.VisibilityChanged)
	end
end

function mod:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] --Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

mod.StyleFilterTriggerList = {} -- configured filters enabled with sorted priority
mod.StyleFilterTriggerEvents = {} -- events required by the filter that we need to watch for
mod.StyleFilterPlateEvents = { -- events watched inside of ouf, which is called on the nameplate itself
	['NAME_PLATE_UNIT_ADDED'] = 1 -- rest is populated from `StyleFilterDefaultEvents` as needed
}
mod.StyleFilterDefaultEvents = { -- list of events style filter uses to populate plate events
	'PLAYER_TARGET_CHANGED',
	'SPELL_UPDATE_COOLDOWN',
	'UNIT_AURA',
	'UNIT_DISPLAYPOWER',
	'UNIT_FACTION',
	'UNIT_HEALTH',
	'UNIT_HEALTH_FREQUENT',
	'UNIT_MAXHEALTH',
	'UNIT_NAME_UPDATE',
	'UNIT_POWER_FREQUENT',
	'UNIT_POWER_UPDATE',
	'UNIT_TARGET',
	'UNIT_THREAT_LIST_UPDATE'
}

function mod:StyleFilterSetWatchEvents()
	for _, event in ipairs(self.StyleFilterDefaultEvents) do
		self.StyleFilterPlateEvents[event] = self.StyleFilterTriggerEvents[event] and true or nil
	end
end

function mod:StyleFilterConfigureEvents()
	wipe(self.StyleFilterTriggerList)
	wipe(self.StyleFilterTriggerEvents)

	for filterName, filter in pairs(E.global.nameplate.filters) do
		if filter.triggers and E.db.nameplates and E.db.nameplates.filters then
			if E.db.nameplates.filters[filterName] and E.db.nameplates.filters[filterName].triggers and E.db.nameplates.filters[filterName].triggers.enable then
				tinsert(self.StyleFilterTriggerList, {filterName, filter.triggers.priority or 1})

				-- NOTE: 0 for fake events, 1 to override StyleFilterWaitTime
				self.StyleFilterTriggerEvents.FAKE_AuraWaitTimer = 0 -- for minTimeLeft and maxTimeLeft aura trigger
				self.StyleFilterTriggerEvents.NAME_PLATE_UNIT_ADDED = 1

				if filter.triggers.casting then
					if next(filter.triggers.casting.spells) then
						for _, value in pairs(filter.triggers.casting.spells) do
							if value == true then
								self.StyleFilterTriggerEvents.FAKE_Casting = 0
								break
							end
						end
					end

					if filter.triggers.casting.interruptible or filter.triggers.casting.notInterruptible then
						self.StyleFilterTriggerEvents.FAKE_Casting = 0
					end
				end

				-- real events
				self.StyleFilterTriggerEvents.PLAYER_TARGET_CHANGED = true

				if filter.triggers.reactionType and filter.triggers.reactionType.enable then
					self.StyleFilterTriggerEvents.UNIT_FACTION = true
				end

				if filter.triggers.targetMe or filter.triggers.notTargetMe then
					self.StyleFilterTriggerEvents.UNIT_TARGET = true
				end

				if filter.triggers.healthThreshold then
					self.StyleFilterTriggerEvents.UNIT_HEALTH = true
					self.StyleFilterTriggerEvents.UNIT_MAXHEALTH = true
					self.StyleFilterTriggerEvents.UNIT_HEALTH_FREQUENT = true
				end

				if filter.triggers.powerThreshold then
					self.StyleFilterTriggerEvents.UNIT_POWER_UPDATE = true
					self.StyleFilterTriggerEvents.UNIT_POWER_FREQUENT = true
					self.StyleFilterTriggerEvents.UNIT_DISPLAYPOWER = true
				end

				if next(filter.triggers.names) then
					for _, value in pairs(filter.triggers.names) do
						if value == true then
							self.StyleFilterTriggerEvents.UNIT_NAME_UPDATE = true
							break
						end
					end
				end

				if filter.triggers.inCombat or filter.triggers.outOfCombat or filter.triggers.inCombatUnit or filter.triggers.outOfCombatUnit then
					self.StyleFilterTriggerEvents.UNIT_THREAT_LIST_UPDATE = true
				end

				if next(filter.triggers.cooldowns.names) then
					for _, value in pairs(filter.triggers.cooldowns.names) do
						if value == "ONCD" or value == "OFFCD" then
							self.StyleFilterTriggerEvents.SPELL_UPDATE_COOLDOWN = true
							break
						end
					end
				end

				if next(filter.triggers.buffs.names) then
					for _, value in pairs(filter.triggers.buffs.names) do
						if value == true then
							self.StyleFilterTriggerEvents.UNIT_AURA = true
							break
						end
					end
				end

				if next(filter.triggers.debuffs.names) then
					for _, value in pairs(filter.triggers.debuffs.names) do
						if value == true then
							self.StyleFilterTriggerEvents.UNIT_AURA = true
							break
						end
					end
				end
			end
		end
	end

	mod:StyleFilterSetWatchEvents()

	if next(self.StyleFilterTriggerList) then
		sort(self.StyleFilterTriggerList, self.StyleFilterSort) --sort by priority
	else
		if _G.ElvNP_Player then
			self:ClearStyledPlate(_G.ElvNP_Player)
		end

		for nameplate in pairs(mod.Plates) do
			self:ClearStyledPlate(nameplate)
		end
	end
end

function mod:StyleFilterUpdate(frame, event)
	if not (frame and self.StyleFilterTriggerEvents[event]) then return end

	if self.StyleFilterTriggerEvents[event] ~= 1 then
		if not frame.StyleFilterWaitTime then
			frame.StyleFilterWaitTime = GetTime()
		elseif GetTime() > (frame.StyleFilterWaitTime + 0.1) then
			frame.StyleFilterWaitTime = nil
		else
			return --block calls faster than 0.1 second
		end
	end

	self:ClearStyledPlate(frame)

	local filter
	for filterNum in ipairs(self.StyleFilterTriggerList) do
		filter = E.global.nameplate.filters[self.StyleFilterTriggerList[filterNum][1]];
		if filter then
			self:StyleFilterConditionCheck(frame, filter, filter.triggers, nil)
		end
	end
end

do -- oUF style filter inject watch functions without actually registering any events
	local update = function(self, event)
		mod:StyleFilterUpdate(self, event)
	end

	local oUF_event_metatable = {
		__call = function(funcs, self, ...)
			for _, func in next, funcs do
				func(self, ...)
			end
		end,
	}

	local oUF_fake_register = function(self, event, remove)
		local curev = self[event]
		if curev then
			local kind = type(curev)
			if kind == 'function' and curev ~= update then
				self[event] = setmetatable({curev, update}, oUF_event_metatable)
			elseif kind == 'table' then
				for index, infunc in next, curev do
					if infunc == update then
						if remove then
							tremove(curev, index)
						end

						return
					end
				end

				tinsert(curev, update)
			end
		else
			self[event] = (not remove and update) or nil
		end
	end

	local styleFilterIsWatching = function(self, event)
		local curev = self[event]
		if curev then
			local kind = type(curev)
			if kind == 'function' and curev == update then
				return true
			elseif kind == 'table' then
				for _, infunc in next, curev do
					if infunc == update then
						return true
					end
				end
			end
		end
	end

	function mod:StyleFilterEventWatch(frame)
		for _, event in ipairs(mod.StyleFilterDefaultEvents) do
			local holdsEvent = styleFilterIsWatching(frame, event)
			if mod.StyleFilterPlateEvents[event] then
				if not holdsEvent then
					oUF_fake_register(frame, event)
				end
			elseif holdsEvent then
				oUF_fake_register(frame, event, true)
			end
		end
	end
end

-- Shamelessy taken from AceDB-3.0
local function copyDefaults(dest, src)
	-- this happens if some value in the SV overwrites our default value with a non-table
	--if type(dest) ~= "table" then return end
	for k, v in pairs(src) do
		if k == "*" or k == "**" then
			if type(v) == "table" then
				-- This is a metatable used for table defaults
				local mt = {
					-- This handles the lookup and creation of new subtables
					__index = function(t,k)
							if k == nil then return nil end
							local tbl = {}
							copyDefaults(tbl, v)
							rawset(t, k, tbl)
							return tbl
						end,
				}
				setmetatable(dest, mt)
				-- handle already existing tables in the SV
				for dk, dv in pairs(dest) do
					if not rawget(src, dk) and type(dv) == "table" then
						copyDefaults(dv, v)
					end
				end
			else
				-- Values are not tables, so this is just a simple return
				local mt = {__index = function(_,k) return k~=nil and v or nil end}
				setmetatable(dest, mt)
			end
		elseif type(v) == "table" then
			if not rawget(dest, k) then rawset(dest, k, {}) end
			if type(dest[k]) == "table" then
				copyDefaults(dest[k], v)
				if src['**'] then
					copyDefaults(dest[k], src['**'])
				end
			end
		else
			if rawget(dest, k) == nil then
				rawset(dest, k, v)
			end
		end
	end
end

local function removeDefaults(db, defaults, blocker)
	-- remove all metatables from the db, so we don't accidentally create new sub-tables through them
	setmetatable(db, nil)
	-- loop through the defaults and remove their content
	for k,v in pairs(defaults) do
		if k == "*" or k == "**" then
			if type(v) == "table" then
				-- Loop through all the actual k,v pairs and remove
				for key, value in pairs(db) do
					if type(value) == "table" then
						-- if the key was not explicitly specified in the defaults table, just strip everything from * and ** tables
						if defaults[key] == nil and (not blocker or blocker[key] == nil) then
							removeDefaults(value, v)
							-- if the table is empty afterwards, remove it
							if next(value) == nil then
								db[key] = nil
							end
						-- if it was specified, only strip ** content, but block values which were set in the key table
						elseif k == "**" then
							removeDefaults(value, v, defaults[key])
						end
					end
				end
			elseif k == "*" then
				-- check for non-table default
				for key, value in pairs(db) do
					if defaults[key] == nil and v == value then
						db[key] = nil
					end
				end
			end
		elseif type(v) == "table" and type(db[k]) == "table" then
			-- if a blocker was set, dive into it, to allow multi-level defaults
			removeDefaults(db[k], v, blocker and blocker[k])
			if next(db[k]) == nil then
				db[k] = nil
			end
		else
			-- check if the current value matches the default, and that its not blocked by another defaults table
			if db[k] == defaults[k] and (not blocker or blocker[k] == nil) then
				db[k] = nil
			end
		end
	end
end

function mod:PLAYER_LOGOUT()
	for filterName, filterTable in pairs(E.global.nameplate.filters) do
		if G.nameplate.filters[filterName] then
			local defaultTable = E:CopyTable({}, E.StyleFilterDefaults);
			E:CopyTable(defaultTable, G.nameplate.filters[filterName]);
			removeDefaults(filterTable, defaultTable);
		else
			removeDefaults(filterTable, E.StyleFilterDefaults);
		end
	end
end

function mod:StyleFilterInitializeAllFilters()
	for _, filterTable in pairs(E.global.nameplate.filters) do
		self:StyleFilterInitializeFilter(filterTable);
	end
end

function mod:StyleFilterInitializeFilter(tbl)
	copyDefaults(tbl, E.StyleFilterDefaults);
end
