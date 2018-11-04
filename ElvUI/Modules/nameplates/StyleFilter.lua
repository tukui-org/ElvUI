local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates');
local LSM = LibStub("LibSharedMedia-3.0");

local ipairs = ipairs
local next = next
local pairs = pairs
local rawget = rawget
local rawset = rawset
local select = select
local setmetatable = setmetatable
local tonumber = tonumber
local type = type
local unpack = unpack

local strsplit = string.split
local tinsert = table.insert
local tsort = table.sort
local twipe = table.wipe

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

local FAILED = FAILED
local INTERRUPTED = INTERRUPTED

local FallbackColor = {r=1, b=1, g=1}

function mod:StyleFilterAuraWaitTimer(frame, icon, varTimerName, timeLeft, mTimeLeft)
	if icon and not icon[varTimerName] then
		local updateIn = timeLeft-mTimeLeft
		if updateIn > 0 then
			-- also add a tenth of a second to updateIn to prevent the timer from firing on the same second
            icon[varTimerName] = C_Timer_NewTimer(updateIn+0.1, function()
				if frame and frame:IsShown() then
					mod:UpdateElement_Filters(frame, 'AuraWaitTimer_Update')
                end
                if icon and icon[varTimerName] then
	                icon[varTimerName] = nil
	            end
            end)
		end
    end
end

function mod:StyleFilterAuraCheck(frame, names, icons, mustHaveAll, missing, minTimeLeft, maxTimeLeft)
	local total, count, isSpell, timeLeft, hasMinTime, hasMaxTime, minTimeAllow, maxTimeAllow = 0, 0
	for name, value in pairs(names) do
		if value == true then --only if they are turned on
			total = total + 1 --keep track of the names
		end
		for _, icon in pairs(icons) do
			isSpell = (icon.name and icon.name == name) or (icon.spellID and icon.spellID == tonumber(name))
			if isSpell and icon:IsShown() and (value == true) then
				hasMinTime = minTimeLeft and minTimeLeft ~= 0
				hasMaxTime = maxTimeLeft and maxTimeLeft ~= 0
				timeLeft = (hasMinTime or hasMaxTime) and icon.expirationTime and (icon.expirationTime - GetTime())
				minTimeAllow = not hasMinTime or (timeLeft and timeLeft > minTimeLeft)
				maxTimeAllow = not hasMaxTime or (timeLeft and timeLeft < maxTimeLeft)
				if timeLeft then -- if we use a min/max time setting; we must create a delay timer
					if hasMinTime then self:StyleFilterAuraWaitTimer(frame, icon, 'hasMinTimer', timeLeft, minTimeLeft) end
					if hasMaxTime then self:StyleFilterAuraWaitTimer(frame, icon, 'hasMaxTimer', timeLeft, maxTimeLeft) end
				end
				if minTimeAllow and maxTimeAllow then
					count = count + 1 --keep track of how many matches we have
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

function mod:StyleFilterSetChanges(frame, actions, HealthColorChanged, PowerColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, PortraitShown, NameOnlyChanged, VisibilityChanged)
	if VisibilityChanged then
		frame.StyleChanged = true
		frame.VisibilityChanged = true
		if frame.UnitType == "PLAYER" then
			if self.db.units.PLAYER.useStaticPosition then
				self.PlayerFrame__.unitFrame:Hide()
				self.PlayerNamePlateAnchor:Hide()
			else
				E:LockCVar("nameplatePersonalShowAlways", "0")
				frame:Hide()
			end
		else
			frame:Hide()
		end
		return --We hide it. Lets not do other things (no point)
	end
	if FrameLevelChanged then
		frame.StyleChanged = true
		frame.FrameLevelChanged = actions.frameLevel -- we pass this to `ResetNameplateFrameLevel`
	end
	if HealthColorChanged then
		frame.StyleChanged = true
		frame.HealthColorChanged = true
		frame.HealthBar:SetStatusBarColor(actions.color.healthColor.r, actions.color.healthColor.g, actions.color.healthColor.b, actions.color.healthColor.a);
		frame.CutawayHealth:SetStatusBarColor(actions.color.healthColor.r * 1.5, actions.color.healthColor.g * 1.5, actions.color.healthColor.b * 1.5, actions.color.healthColor.a);
	end
	if PowerColorChanged then
		frame.StyleChanged = true
		frame.PowerColorChanged = true
		frame.PowerBar:SetStatusBarColor(actions.color.powerColor.r, actions.color.powerColor.g, actions.color.powerColor.b, actions.color.powerColor.a);
	end
	if BorderChanged then
		frame.StyleChanged = true
		frame.BorderChanged = true
		mod:StyleFilterBorderColorLock(frame.HealthBar.backdrop, true)
		frame.HealthBar.backdrop:SetBackdropBorderColor(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		if mod.db.units[frame.UnitType].powerbar.enable and frame.PowerBar.backdrop then
			mod:StyleFilterBorderColorLock(frame.PowerBar.backdrop, true)
			frame.PowerBar.backdrop:SetBackdropBorderColor(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
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
		frame.HealthBar:SetStatusBarTexture(LSM:Fetch("statusbar", actions.texture.texture))
		if FlashingHealth then
			frame.FlashTexture:SetTexture(LSM:Fetch("statusbar", actions.texture.texture))
		end
	end
	if ScaleChanged then
		frame.StyleChanged = true
		frame.ScaleChanged = true
		local scale = actions.scale
		if frame.isTarget and self.db.useTargetScale then
			scale = scale * self.db.targetScale
		end
		self:SetFrameScale(frame, scale)
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
			frame.Name:SetTextColor(actions.color.nameColor.r, actions.color.nameColor.g, actions.color.nameColor.b, actions.color.nameColor.a)
		end
	end
	if PortraitShown then
		frame.StyleChanged = true
		frame.PortraitShown = true
		self:UpdateElement_Portrait(frame, true)
		self:ConfigureElement_Portrait(frame, true)
		if frame.RightArrow:IsShown() then
			frame.RightArrow:SetPoint("RIGHT", (frame.Portrait:IsShown() and frame.Portrait) or frame.HealthBar, "LEFT", E:Scale(E.Border*2), 0)
		end
	end
	if NameOnlyChanged then
		frame.StyleChanged = true
		frame.NameOnlyChanged = true
		--hide the bars
		if frame.CastBar:IsShown() then frame.CastBar:Hide() end
		if frame.PowerBar:IsShown() then frame.PowerBar:Hide() end
		if frame.HealthBar:IsShown() then frame.HealthBar:Hide() end
		--hide the target indicator
		self:UpdateElement_Glow(frame)
		--position the name and update its color
		frame.Name:ClearAllPoints()
		frame.Name:SetJustifyH("CENTER")
		frame.Name:SetPoint("TOP", frame, "CENTER")
		frame.Level:ClearAllPoints()
		frame.Level:SetPoint("LEFT", frame.Name, "RIGHT")
		frame.Level:SetJustifyH("LEFT")
		if not NameColorChanged then
			self:UpdateElement_Name(frame, true)
		end
		--show the npc title
		self:UpdateElement_NPCTitle(frame, true)
		--position the portrait
		self:ConfigureElement_Portrait(frame, true)
		--position suramar detection
		frame.TopLevelFrame = (frame.Portrait:IsShown() and frame.Portrait) or nil
		self:ConfigureElement_Detection(frame)
	end
end

function mod:StyleFilterClearChanges(frame, HealthColorChanged, PowerColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, FrameLevelChanged, AlphaChanged, NameColorChanged, PortraitShown, NameOnlyChanged, VisibilityChanged)
	frame.StyleChanged = nil
	if VisibilityChanged then
		frame.VisibilityChanged = nil
		if frame.UnitType == "PLAYER" then
			if self.db.units.PLAYER.useStaticPosition then
				self.PlayerFrame__.unitFrame:Show()
				self.PlayerNamePlateAnchor:Show()
			else
				E:LockCVar("nameplatePersonalShowAlways", "1")
			end
		end
		frame:Show()
	end
	if FrameLevelChanged then
		frame.FrameLevelChanged = nil
	end
	if HealthColorChanged then
		frame.HealthColorChanged = nil
		frame.HealthBar:SetStatusBarColor(frame.HealthBar.r, frame.HealthBar.g, frame.HealthBar.b);
		frame.CutawayHealth:SetStatusBarColor(frame.HealthBar.r * 1.5, frame.HealthBar.g * 1.5, frame.HealthBar.b * 1.5, 1);
	end
	if PowerColorChanged then
		frame.PowerColorChanged = nil
		local color = E.db.unitframe.colors.power[frame.PowerToken] or PowerBarColor[frame.PowerToken] or FallbackColor
		if color then
			frame.PowerBar:SetStatusBarColor(color.r, color.g, color.b)
		end
	end
	if BorderChanged then
		frame.BorderChanged = nil
		mod:StyleFilterBorderColorLock(frame.HealthBar.backdrop, false)
		frame.HealthBar.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		if mod.db.units[frame.UnitType].powerbar.enable and frame.PowerBar.backdrop then
			mod:StyleFilterBorderColorLock(frame.PowerBar.backdrop, false)
			frame.PowerBar.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
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
		frame.HealthBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
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
		elseif not UnitIsUnit(frame.displayedUnit, "player") then
			frame:SetAlpha(1 - self.db.nonTargetTransparency)
		end
	end
	if NameColorChanged then
		frame.NameColorChanged = nil
		frame.Name:SetTextColor(frame.Name.r, frame.Name.g, frame.Name.b)
	end
	if PortraitShown then
		frame.PortraitShown = nil
		frame.Portrait:Hide() --This could have been forced so hide it
		self:UpdateElement_Portrait(frame) --Use the original check to determine if this should be shown
		self:ConfigureElement_Portrait(frame)
		if frame.RightArrow:IsShown() then
			frame.RightArrow:SetPoint("RIGHT", (frame.Portrait:IsShown() and frame.Portrait) or frame.HealthBar, "LEFT", E:Scale(E.Border*2), 0)
		end
	end
	if NameOnlyChanged then
		frame.NameOnlyChanged = nil
		frame.TopLevelFrame = nil --We can safely clear this here because it is set upon `UpdateElement_Auras` if needed
		if (frame.UnitType and self.db.units[frame.UnitType].healthbar.enable) or (self.db.displayStyle ~= "ALL") or (frame.isTarget and self.db.alwaysShowTargetHealth) then
			frame.HealthBar:Show()
			self:UpdateElement_Glow(frame)
			if self.db.units[frame.UnitType].powerbar.enable then
				local curValue = UnitPower(frame.displayedUnit, frame.PowerType);
				if not (curValue == 0 and self.db.units[frame.UnitType].powerbar.hideWhenEmpty) then
					frame.PowerBar:Show()
				end
			end
		end
		if self.db.units[frame.UnitType].showName then
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
		if self.db.units[frame.UnitType].portrait.enable then
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

	local castbarShown = frame.CastBar:IsShown()
	local castbarTriggered = false --We use this to prevent additional calls to `UpdateElement_All` when the castbar hides
	local matchMyClass = false --Only check spec when we match the class condition

	if not failed and trigger.names and next(trigger.names) then
		condition = 0
		for unitName, value in pairs(trigger.names) do
			if value == true then --only check names that are checked
				condition = 1
				if tonumber(unitName) then
					guid = UnitGUID(frame.displayedUnit)
					if guid then
						npcid = select(6, strsplit('-', guid))
						if tonumber(unitName) == tonumber(npcid) then
							condition = 2
							break
						end
					end
				else
					name = UnitName(frame.displayedUnit)
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
				if castbarShown then
					spell = frame.CastBar.Name:GetText() --Make sure we can check spell name
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
			castbarTriggered = (condition == 2)
		end
	end

	--Try to match by casting interruptible
	if not failed and (trigger.casting and (trigger.casting.interruptible or trigger.casting.notInterruptible)) then
		condition = false
		if castbarShown and ((trigger.casting.interruptible and frame.CastBar.canInterrupt) or (trigger.casting.notInterruptible and not frame.CastBar.canInterrupt)) then
			condition = true
			castbarTriggered = true
		end
		failed = not condition
	end

	--Try to match by player health conditions
	if not failed and trigger.healthThreshold then
		condition = false
		healthUnit = (trigger.healthUsePlayer and "player") or frame.displayedUnit
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
		powerUnit = (trigger.powerUsePlayer and "player") or frame.displayedUnit
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
		inCombat = UnitAffectingCombat(frame.displayedUnit)
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
		questBoss = UnitIsQuestBoss(frame.displayedUnit)
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
		mySpecID = GetSpecializationInfo(E.myspec)
		if mySpecID and trigger.class[E.myclass].specs[mySpecID] then
			condition = true
		end
		failed = not condition
	end

	--Try to match by classification conditions
	if not failed and (trigger.classification.worldboss or trigger.classification.rareelite or trigger.classification.elite or trigger.classification.rare or trigger.classification.normal or trigger.classification.trivial or trigger.classification.minus) then
		condition = false
		classification = UnitClassification(frame.displayedUnit)
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
		level = (frame.displayedUnit == 'player' and myLevel) or UnitLevel(frame.displayedUnit)
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

		if (trigger.nameplateType.friendlyPlayer and frame.UnitType=='FRIENDLY_PLAYER')
		or (trigger.nameplateType.friendlyNPC	 and frame.UnitType=='FRIENDLY_NPC')
		or (trigger.nameplateType.enemyPlayer	 and frame.UnitType=='ENEMY_PLAYER')
		or (trigger.nameplateType.enemyNPC		 and frame.UnitType=='ENEMY_NPC')
		or (trigger.nameplateType.healer		 and frame.UnitType=='HEALER')
		or (trigger.nameplateType.player		 and frame.UnitType=='PLAYER') then
			condition = true
		end

		failed = not condition
	end

	--Try to match by Reaction (or Reputation) type
	if not failed and trigger.reactionType and trigger.reactionType.enable then
		reaction = (trigger.reactionType.reputation and UnitReaction(frame.displayedUnit, 'player')) or UnitReaction('player', frame.displayedUnit)
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
		condition = self:StyleFilterAuraCheck(frame, trigger.buffs.names, frame.Buffs and frame.Buffs.icons, trigger.buffs.mustHaveAll, trigger.buffs.missing, trigger.buffs.minTimeLeft, trigger.buffs.maxTimeLeft)
		if condition ~= nil then --Condition will be nil if none are selected
			failed = not condition
		end
	end

	--Try to match according to debuff aura conditions
	if not failed and trigger.debuffs and trigger.debuffs.names and next(trigger.debuffs.names) then
		condition = self:StyleFilterAuraCheck(frame, trigger.debuffs.names, frame.Debuffs and frame.Debuffs.icons, trigger.debuffs.mustHaveAll, trigger.debuffs.missing, trigger.debuffs.minTimeLeft, trigger.debuffs.maxTimeLeft)
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
		self:StyleFilterPass(frame, filter.actions, castbarTriggered);
	end
end

function mod:StyleFilterPass(frame, actions, castbarTriggered)
	if castbarTriggered then
		frame.castbarTriggered = castbarTriggered
	end

	local healthBarEnabled = (frame.UnitType and mod.db.units[frame.UnitType].healthbar.enable) or (mod.db.displayStyle ~= "ALL") or (frame.isTarget and mod.db.alwaysShowTargetHealth)
	local powerBarEnabled = mod.db.units[frame.UnitType].powerbar.enable
	local healthBarShown = healthBarEnabled and frame.HealthBar:IsShown()
	self:StyleFilterSetChanges(frame, actions,
		(healthBarShown and actions.color and actions.color.health), --HealthColorChanged
		(healthBarShown and powerBarEnabled and actions.color and actions.color.power), --PowerColorChanged
		(healthBarShown and actions.color and actions.color.border and frame.HealthBar.backdrop), --BorderChanged
		(healthBarShown and actions.flash and actions.flash.enable and frame.FlashTexture), --FlashingHealth
		(healthBarShown and actions.texture and actions.texture.enable), --TextureChanged
		(healthBarShown and actions.scale and actions.scale ~= 1), --ScaleChanged
		(actions.frameLevel and actions.frameLevel ~= 0), --FrameLevelChanged
		(actions.alpha and actions.alpha ~= -1), --AlphaChanged
		(actions.color and actions.color.name), --NameColorChanged
		(actions.usePortrait), --PortraitShown
		(actions.nameOnly), --NameOnlyChanged
		(actions.hide) --VisibilityChanged
	)
end

function mod:ClearStyledPlate(frame)
	if frame.StyleChanged then
		self:StyleFilterClearChanges(frame, frame.HealthColorChanged, frame.PowerColorChanged, frame.BorderChanged, frame.FlashingHealth, frame.TextureChanged, frame.ScaleChanged, frame.FrameLevelChanged, frame.AlphaChanged, frame.NameColorChanged, frame.PortraitShown, frame.NameOnlyChanged, frame.VisibilityChanged)
	end
end

function mod:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] --Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

mod.StyleFilterList = {}
mod.StyleFilterEvents = {}
function mod:StyleFilterConfigureEvents()
	twipe(self.StyleFilterList)
	twipe(self.StyleFilterEvents)

	for filterName, filter in pairs(E.global.nameplate.filters) do
		if filter.triggers and E.db.nameplates and E.db.nameplates.filters then
			if E.db.nameplates.filters[filterName] and E.db.nameplates.filters[filterName].triggers and E.db.nameplates.filters[filterName].triggers.enable then
				tinsert(self.StyleFilterList, {filterName, filter.triggers.priority or 1})

				-- fake events along with "UpdateElement_Cast" (use 1 instead of true to override StyleFilterWaitTime)
				self.StyleFilterEvents["UpdateElement_All"] = true
				self.StyleFilterEvents["AuraWaitTimer_Update"] = true -- for minTimeLeft and maxTimeLeft aura trigger
				self.StyleFilterEvents["NAME_PLATE_UNIT_ADDED"] = 1

				if filter.triggers.casting then
					if next(filter.triggers.casting.spells) then
						for _, value in pairs(filter.triggers.casting.spells) do
							if value == true then
								self.StyleFilterEvents["UpdateElement_Cast"] = 1
								break
							end
						end
					end

					if filter.triggers.casting.interruptible or filter.triggers.casting.notInterruptible then
						self.StyleFilterEvents["UpdateElement_Cast"] = 1
					end
				end

				-- real events
				self.StyleFilterEvents["PLAYER_TARGET_CHANGED"] = true

				if filter.triggers.reactionType and filter.triggers.reactionType.enable then
					self.StyleFilterEvents["UNIT_FACTION"] = true
				end

				if filter.triggers.targetMe or filter.triggers.notTargetMe then
					self.StyleFilterEvents["UNIT_TARGET"] = true
				end

				if filter.triggers.healthThreshold then
					self.StyleFilterEvents["UNIT_HEALTH"] = true
					self.StyleFilterEvents["UNIT_MAXHEALTH"] = true
					self.StyleFilterEvents["UNIT_HEALTH_FREQUENT"] = true
				end

				if filter.triggers.powerThreshold then
					self.StyleFilterEvents["UNIT_POWER_UPDATE"] = true
					self.StyleFilterEvents["UNIT_POWER_FREQUENT"] = true
					self.StyleFilterEvents["UNIT_DISPLAYPOWER"] = true
				end

				if next(filter.triggers.names) then
					for _, value in pairs(filter.triggers.names) do
						if value == true then
							self.StyleFilterEvents["UNIT_NAME_UPDATE"] = true
							break
						end
					end
				end

				if filter.triggers.inCombat or filter.triggers.outOfCombat or filter.triggers.inCombatUnit or filter.triggers.outOfCombatUnit then
					self.StyleFilterEvents["UNIT_THREAT_LIST_UPDATE"] = true
				end

				if next(filter.triggers.cooldowns.names) then
					for _, value in pairs(filter.triggers.cooldowns.names) do
						if value == "ONCD" or value == "OFFCD" then
							self.StyleFilterEvents["SPELL_UPDATE_COOLDOWN"] = true
							break
						end
					end
				end

				if next(filter.triggers.buffs.names) then
					for _, value in pairs(filter.triggers.buffs.names) do
						if value == true then
							self.StyleFilterEvents["UNIT_AURA"] = true
							break
						end
					end
				end

				if next(filter.triggers.debuffs.names) then
					for _, value in pairs(filter.triggers.debuffs.names) do
						if value == true then
							self.StyleFilterEvents["UNIT_AURA"] = true
							break
						end
					end
				end
			end
		end
	end

	if next(self.StyleFilterList) then
		tsort(self.StyleFilterList, self.StyleFilterSort) --sort by priority
	else
		self:ForEachPlate("ClearStyledPlate")
		if self.PlayerFrame__ then
			self:ClearStyledPlate(self.PlayerFrame__.unitFrame)
		end
	end
end

function mod:UpdateElement_Filters(frame, event)
	if not self.StyleFilterEvents[event] then return end

	if self.StyleFilterEvents[event] == true then
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
	for filterNum in ipairs(self.StyleFilterList) do
		filter = E.global.nameplate.filters[self.StyleFilterList[filterNum][1]];
		if filter then
			self:StyleFilterConditionCheck(frame, filter, filter.triggers, nil)
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
