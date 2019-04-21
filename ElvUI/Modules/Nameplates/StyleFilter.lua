local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local _G = _G
local ipairs, next, pairs, rawget, rawset, select = ipairs, next, pairs, rawget, rawset, select
local setmetatable, tonumber, type, unpack = setmetatable, tonumber, type, unpack
local gsub, tinsert, tremove, sort, wipe = gsub, tinsert, tremove, sort, wipe

local GetInstanceInfo = GetInstanceInfo
local GetLocale = GetLocale
local GetRaidTargetIndex = GetRaidTargetIndex
local GetSpecializationInfo = GetSpecializationInfo
local GetSpellCharges = GetSpellCharges
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetTalentInfo = GetTalentInfo
local GetTime = GetTime
local IsResting = IsResting
local PowerBarColor = PowerBarColor
local UnitAffectingCombat = UnitAffectingCombat
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitInVehicle = UnitInVehicle
local UnitIsQuestBoss = UnitIsQuestBoss
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

local hooksecurefunc = hooksecurefunc
local C_Timer_NewTimer = C_Timer.NewTimer
local C_SpecializationInfo_GetPvpTalentSlotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo
local INTERRUPTED = INTERRUPTED
local FAILED = FAILED

local FallbackColor = {r=1, b=1, g=1}

do -- E.CreatureTypes; Do *not* change the value, only the key (['key'] = 'value').
	local c, locale = {}, GetLocale()
	if locale == "frFR" then
		c['Aberration'] = 'Aberration'
		c['Bête'] = 'Beast'
		c['Bestiole'] = 'Critter'
		c['Démon'] = 'Demon'
		c['Draconien'] = 'Dragonkin'
		c['Élémentaire'] = 'Elemental'
		c['Nuage de gaz'] = 'Gas Cloud'
		c['Géant'] = 'Giant'
		c['Humanoïde'] = 'Humanoid'
		c['Machine'] = 'Mechanical'
		c['Non spécifié'] = 'Not specified'
		c['Totem'] = 'Totem'
		c['Mort-vivant'] = 'Undead'
		c['Mascotte sauvage'] = 'Wild Pet'
		c['Familier pacifique'] = 'Non-combat Pet'
	elseif locale == "deDE" then
		c['Anomalie'] = 'Aberration'
		c['Wildtier'] = 'Beast'
		c['Kleintier'] = 'Critter'
		c['Dämon'] = 'Demon'
		c['Drachkin'] = 'Dragonkin'
		c['Elementar'] = 'Elemental'
		c['Gaswolke'] = 'Gas Cloud'
		c['Riese'] = 'Giant'
		c['Humanoid'] = 'Humanoid'
		c['Mechanisch'] = 'Mechanical'
		c['Nicht spezifiziert'] = 'Not specified'
		c['Totem'] = 'Totem'
		c['Untoter'] = 'Undead'
		c['Ungezähmtes Tier'] = 'Wild Pet'
		c['Haustier'] = 'Non-combat Pet'
	elseif locale == "koKR" then
		c['돌연변이'] = 'Aberration'
		c['야수'] = 'Beast'
		c['동물'] = 'Critter'
		c['악마'] = 'Demon'
		c['용족'] = 'Dragonkin'
		c['정령'] = 'Elemental'
		c['가스'] = 'Gas Cloud'
		c['거인'] = 'Giant'
		c['인간형'] = 'Humanoid'
		c['기계'] = 'Mechanical'
		c['기타'] = 'Not specified'
		c['토템'] = 'Totem'
		c['언데드'] = 'Undead'
		c['야생 애완동물'] = 'Wild Pet'
		c['애완동물'] = 'Non-combat Pet'
	elseif locale == "ruRU" then
		c['Аберрация'] = 'Aberration'
		c['Животное'] = 'Beast'
		c['Существо'] = 'Critter'
		c['Демон'] = 'Demon'
		c['Дракон'] = 'Dragonkin'
		c['Элементаль'] = 'Elemental'
		c['Газовое облако'] = 'Gas Cloud'
		c['Великан'] = 'Giant'
		c['Гуманоид'] = 'Humanoid'
		c['Механизм'] = 'Mechanical'
		c['Не указано'] = 'Not specified'
		c['Тотем'] = 'Totem'
		c['Нежить'] = 'Undead'
		c['дикий питомец'] = 'Wild Pet'
		c['Спутник'] = 'Non-combat Pet'
	elseif locale == "zhCN" then
		c['畸变'] = 'Aberration'
		c['野兽'] = 'Beast'
		c['小动物'] = 'Critter'
		c['恶魔'] = 'Demon'
		c['龙类'] = 'Dragonkin'
		c['元素生物'] = 'Elemental'
		c['气体云雾'] = 'Gas Cloud'
		c['巨人'] = 'Giant'
		c['人型生物'] = 'Humanoid'
		c['机械'] = 'Mechanical'
		c['未指定'] = 'Not specified'
		c['图腾'] = 'Totem'
		c['亡灵'] = 'Undead'
		c['野生宠物'] = 'Wild Pet'
		c['非战斗宠物'] = 'Non-combat Pet'
	elseif locale == "zhTW" then
		c['畸變'] = 'Aberration'
		c['野獸'] = 'Beast'
		c['小動物'] = 'Critter'
		c['惡魔'] = 'Demon'
		c['龍類'] = 'Dragonkin'
		c['元素生物'] = 'Elemental'
		c['氣體雲'] = 'Gas Cloud'
		c['巨人'] = 'Giant'
		c['人型生物'] = 'Humanoid'
		c['機械'] = 'Mechanical'
		c['不明'] = 'Not specified'
		c['圖騰'] = 'Totem'
		c['不死族'] = 'Undead'
		c['野生寵物'] = 'Wild Pet'
		c['非戰鬥寵物'] = 'Non-combat Pet'
	elseif locale == "esES" then
		c['Desviación'] = 'Aberration'
		c['Bestia'] = 'Beast'
		c['Alma'] = 'Critter'
		c['Demonio'] = 'Demon'
		c['Dragon'] = 'Dragonkin'
		c['Elemental'] = 'Elemental'
		c['Nube de Gas'] = 'Gas Cloud'
		c['Gigante'] = 'Giant'
		c['Humanoide'] = 'Humanoid'
		c['Mecánico'] = 'Mechanical'
		c['No especificado'] = 'Not specified'
		c['Tótem'] = 'Totem'
		c['No-muerto'] = 'Undead'
		c['Mascota salvaje'] = 'Wild Pet'
		c['Mascota no combatiente'] = 'Non-combat Pet'
	elseif locale == "esMX" then
		c['Desviación'] = 'Aberration'
		c['Bestia'] = 'Beast'
		c['Alma'] = 'Critter'
		c['Demonio'] = 'Demon'
		c['Dragón'] = 'Dragonkin'
		c['Elemental'] = 'Elemental'
		c['Nube de Gas'] = 'Gas Cloud'
		c['Gigante'] = 'Giant'
		c['Humanoide'] = 'Humanoid'
		c['Mecánico'] = 'Mechanical'
		c['Sin especificar'] = 'Not specified'
		c['Totém'] = 'Totem'
		c['No-muerto'] = 'Undead'
		c['Mascota salvaje'] = 'Wild Pet'
		c['Mascota mansa'] = 'Non-combat Pet'
	elseif locale == "ptBR" then
		c['Aberração'] = 'Aberration'
		c['Fera'] = 'Beast'
		c['Bicho'] = 'Critter'
		c['Demônio'] = 'Demon'
		c['Dracônico'] = 'Dragonkin'
		c['Elemental'] = 'Elemental'
		c['Gasoso'] = 'Gas Cloud'
		c['Gigante'] = 'Giant'
		c['Humanoide'] = 'Humanoid'
		c['Mecânico'] = 'Mechanical'
		c['Não especificado'] = 'Not specified'
		c['Totem'] = 'Totem'
		c['Renegado'] = 'Undead'
		c['Mascote Selvagem'] = 'Wild Pet'
		c['Mascote não-combatente'] = 'Non-combat Pet'
	elseif locale == "itIT" then
		c['Aberrazione'] = 'Aberration'
		c['Bestia'] = 'Beast'
		c['Animale'] = 'Critter'
		c['Demone'] = 'Demon'
		c['Dragoide'] = 'Dragonkin'
		c['Elementale'] = 'Elemental'
		c['Nube di Gas'] = 'Gas Cloud'
		c['Gigante'] = 'Giant'
		c['Umanoide'] = 'Humanoid'
		c['Meccanico'] = 'Mechanical'
		c['Non Specificato'] = 'Not specified'
		c['Totem'] = 'Totem'
		c['Non Morto'] = 'Undead'
		c['Mascotte selvatica'] = 'Wild Pet'
		c['Animale Non combattente'] = 'Non-combat Pet'
	else -- enUS
		c['Aberration'] = 'Aberration'
		c['Beast'] = 'Beast'
		c['Critter'] = 'Critter'
		c['Demon'] = 'Demon'
		c['Dragonkin'] = 'Dragonkin'
		c['Elemental'] = 'Elemental'
		c['Gas Cloud'] = 'Gas Cloud'
		c['Giant'] = 'Giant'
		c['Humanoid'] = 'Humanoid'
		c['Mechanical'] = 'Mechanical'
		c['Not specified'] = 'Not specified'
		c['Totem'] = 'Totem'
		c['Undead'] = 'Undead'
		c['Wild Pet'] = 'Wild Pet'
		c['Non-combat Pet'] = 'Non-combat Pet'
	end

	E.CreatureTypes = c
end

function mod:StyleFilterAuraWait(frame, button, varTimerName, timeLeft, mTimeLeft)
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
							if hasMinTime then mod:StyleFilterAuraWait(frame, button, 'hasMinTimer', timeLeft, minTimeLeft) end
							if hasMaxTime then mod:StyleFilterAuraWait(frame, button, 'hasMaxTimer', timeLeft, maxTimeLeft) end
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
		if GetSpellInfo(name) then --check spell name valid, GetSpellCharges/GetSpellCooldown will return nil if not known by your class
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
	end

	if total == 0 then
		return nil
	else
		return (mustHaveAll and total == count) or (not mustHaveAll and count > 0)
	end
end

function mod:StyleFilterFinishedFlash(requested)
	if self and not requested then self:Play() end
end

function mod:StyleFilterSetupFlash(FlashTexture)
	FlashTexture.anim = FlashTexture:CreateAnimationGroup("Flash")
	FlashTexture.anim.fadein = FlashTexture.anim:CreateAnimation("ALPHA", "FadeIn")
	FlashTexture.anim.fadein:SetFromAlpha(0)
	FlashTexture.anim.fadein:SetToAlpha(1)
	FlashTexture.anim.fadein:SetOrder(2)

	FlashTexture.anim.fadeout = FlashTexture.anim:CreateAnimation("ALPHA", "FadeOut")
	FlashTexture.anim.fadeout:SetFromAlpha(1)
	FlashTexture.anim.fadeout:SetToAlpha(0)
	FlashTexture.anim.fadeout:SetOrder(1)

	FlashTexture.anim:SetScript("OnFinished", mod.StyleFilterFinishedFlash)
end

function mod:StyleFilterPlateStyled(frame)
	if frame and frame.Name and not frame.Name.__owner then
		frame.Name.__owner = frame
		hooksecurefunc(frame.Name, 'SetFormattedText', mod.StyleFilterNameChanged)
	end
end

function mod:StyleFilterNameChanged()
	if not self.__owner or not self.__owner.NameColorChanged then return end

	local nameText = self:GetText()
	if nameText and nameText ~= "" then
		local unitName = self.__owner.unitName and gsub(self.__owner.unitName,'([%(%)%.%%%+%-%*%?%[%^%$])','%%%1')
		if unitName then self:SetText(gsub(nameText,'|c[fF][fF]%x%x%x%x%x%x%s-('..unitName..')','%1')) end
	end
end

function mod:StyleFilterBorderLock(backdrop, switch)
	if switch == true then
		backdrop.ignoreBorderColors = true --but keep the backdrop updated
	else
		backdrop.ignoreBorderColors = nil --restore these borders to be updated
	end
end

function mod:StyleFilterSetChanges(frame, actions, HealthColorChanged, PowerColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, AlphaChanged, NameColorChanged, PortraitShown, NameOnlyChanged, VisibilityChanged)
	if VisibilityChanged then
		frame.StyleChanged = true
		frame.VisibilityChanged = true
		mod:DisablePlate(frame) -- disable the plate elements
		frame:ClearAllPoints() -- lets still move the frame out cause its clickable otherwise
		frame:Point('TOP', E.UIParent, 'BOTTOM', 0, -500)
		return --We hide it. Lets not do other things (no point)
	end
	if HealthColorChanged then
		frame.StyleChanged = true
		frame.HealthColorChanged = actions.color.healthColor
		frame.Health:SetStatusBarColor(actions.color.healthColor.r, actions.color.healthColor.g, actions.color.healthColor.b, actions.color.healthColor.a);
		--[[if frame.CutawayHealth then
			frame.CutawayHealth:SetStatusBarColor(actions.color.healthColor.r * 1.5, actions.color.healthColor.g * 1.5, actions.color.healthColor.b * 1.5, actions.color.healthColor.a);
		end]]
	end
	if PowerColorChanged then
		frame.StyleChanged = true
		frame.PowerColorChanged = true
		frame.Power:SetStatusBarColor(actions.color.powerColor.r, actions.color.powerColor.g, actions.color.powerColor.b, actions.color.powerColor.a);
	end
	if BorderChanged then
		frame.StyleChanged = true
		frame.BorderChanged = true
		mod:StyleFilterBorderLock(frame.Health.backdrop, true)
		frame.Health.backdrop:SetBackdropBorderColor(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		if frame.Power.backdrop and (frame.frameType and mod.db.units[frame.frameType].power and mod.db.units[frame.frameType].power.enable) then
			mod:StyleFilterBorderLock(frame.Power.backdrop, true)
			frame.Power.backdrop:SetBackdropBorderColor(actions.color.borderColor.r, actions.color.borderColor.g, actions.color.borderColor.b, actions.color.borderColor.a)
		end
	end
	if FlashingHealth then
		frame.StyleChanged = true
		frame.FlashingHealth = true
		if not TextureChanged then
			frame.FlashTexture:SetTexture(LSM:Fetch("statusbar", mod.db.statusbar))
		end
		frame.FlashTexture:SetVertexColor(actions.flash.color.r, actions.flash.color.g, actions.flash.color.b)
		if not frame.FlashTexture.anim then
			mod:StyleFilterSetupFlash(frame.FlashTexture)
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
		frame.StyleChanged = true
		frame.ScaleChanged = true
		mod:ScalePlate(frame, actions.scale)
	end
	if AlphaChanged then
		frame.StyleChanged = true
		frame.AlphaChanged = true
		E:UIFrameFadeIn(frame, 0, 0, actions.alpha / 100)
	end
	if NameColorChanged then
		frame.StyleChanged = true
		frame.NameColorChanged = true

		mod.StyleFilterNameChanged(frame.Name)
		frame.Name:SetTextColor(actions.color.nameColor.r, actions.color.nameColor.g, actions.color.nameColor.b, actions.color.nameColor.a)
	end
	if PortraitShown then
		frame.StyleChanged = true
		frame.PortraitShown = true
		mod:Update_Portrait(frame)
		frame.Portrait:ForceUpdate()
	end
	if NameOnlyChanged then
		frame.StyleChanged = true
		frame.NameOnlyChanged = true
		mod:DisablePlate(frame, true)
	end
end

function mod:StyleFilterUpdatePlate(frame, nameOnly)
	mod:UpdatePlate(frame) -- enable elements back

	if frame.frameType then
		if mod.db.units[frame.frameType].health.enable then
			frame.Health:ForceUpdate()
		end
		if mod.db.units[frame.frameType].power.enable then
			frame.Power:ForceUpdate()
		end
	end

	if mod.db.threat.enable and mod.db.threat.useThreatColor and not UnitIsTapDenied(frame.unit) then
		frame.ThreatIndicator:ForceUpdate() -- this will account for the threat health color
	end

	if not nameOnly then
		E:UIFrameFadeIn(frame, mod.db.fadeIn and 1 or 0, 0, 1) -- fade those back in so it looks clean
	end
end

function mod:StyleFilterClearChanges(frame, HealthColorChanged, PowerColorChanged, BorderChanged, FlashingHealth, TextureChanged, ScaleChanged, AlphaChanged, NameColorChanged, PortraitShown, NameOnlyChanged, VisibilityChanged)
	frame.StyleChanged = nil
	if VisibilityChanged then
		frame.VisibilityChanged = nil
		mod:StyleFilterUpdatePlate(frame)
		frame:ClearAllPoints() -- pull the frame back in
		frame:Point('CENTER')
	end
	if HealthColorChanged then
		frame.HealthColorChanged = nil
		frame.Health:SetStatusBarColor(frame.Health.r, frame.Health.g, frame.Health.b);
		--[[if frame.CutawayHealth then
			frame.CutawayHealth:SetStatusBarColor(frame.Health.r * 1.5, frame.Health.g * 1.5, frame.Health.b * 1.5, 1);
		end]]
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
		mod:StyleFilterBorderLock(frame.Health.backdrop, false)
		frame.Health.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		if frame.Power.backdrop and (frame.frameType and mod.db.units[frame.frameType].power and mod.db.units[frame.frameType].power.enable) then
			mod:StyleFilterBorderLock(frame.Power.backdrop, false)
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
		frame.Highlight.texture:SetTexture(LSM:Fetch("statusbar", mod.db.statusbar))
		frame.Health:SetStatusBarTexture(LSM:Fetch("statusbar", mod.db.statusbar))
	end
	if ScaleChanged then
		frame.ScaleChanged = nil
		if frame.isTarget then
			mod:ScalePlate(frame, mod.db.units.TARGET.scale, true)
		else
			mod:ScalePlate(frame, frame.ThreatScale or 1)
		end
	end
	if AlphaChanged then
		frame.AlphaChanged = nil
		E:UIFrameFadeIn(frame, mod.db.fadeIn and 1 or 0, 0, 1)
	end
	if NameColorChanged then
		frame.NameColorChanged = nil
		frame.Name:UpdateTag()
		frame.Name:SetTextColor(1, 1, 1, 1)
	end
	if PortraitShown then
		frame.PortraitShown = nil
		mod:Update_Portrait(frame)
		frame.Portrait:ForceUpdate()
	end
	if NameOnlyChanged then
		frame.NameOnlyChanged = nil
		mod:StyleFilterUpdatePlate(frame, true)
	end
end

function mod:StyleFilterConditionCheck(frame, filter, trigger)
	-- Name or GUID
	if trigger.names and next(trigger.names) then
		local pass
		for name, value in pairs(trigger.names) do
			if value == true then --only check names that are checked
				pass = 1
				if tonumber(name) then --check as guid
					if frame.npcID and (name == frame.npcID) then
						pass = 2
						break
					end
				else
					if name and name ~= "" and (name == frame.unitName) then
						pass = 2
						break
		end end end end

		if pass == 1 then return end
	end

	-- Casting Spell
	if trigger.casting and trigger.casting.spells and next(trigger.casting.spells) then
		local pass
		for spellName, value in pairs(trigger.casting.spells) do
			if value == true then --only check spell that are checked
				pass = 1
				if frame.Castbar and (frame.Castbar.casting or frame.Castbar.channeling) then
					local spell = frame.Castbar.Text:GetText() --Make sure we can check spell name
					if spell and spell ~= "" and spell ~= FAILED and spell ~= INTERRUPTED then
						if tonumber(spellName) then
							spellName = GetSpellInfo(spellName)
						end
						if spellName and spellName == spell then
							pass = 2
							break
		end end end end end

		--If we cant check spell name, we ignore this trigger when the castbar is shown
		if pass == 1 then return end
	end

	-- Casting Interruptible
	if trigger.casting and (trigger.casting.interruptible or trigger.casting.notInterruptible) then
		if not (frame.Castbar and (frame.Castbar.casting or frame.Castbar.channeling)
		and ((trigger.casting.interruptible and not frame.Castbar.notInterruptible)
		or (trigger.casting.notInterruptible and frame.Castbar.notInterruptible))) then return end
	end

	-- Health
	if trigger.healthThreshold then
		local healthUnit = (trigger.healthUsePlayer and "player") or frame.unit
		local health, maxHealth = UnitHealth(healthUnit), UnitHealthMax(healthUnit)
		local percHealth = (maxHealth and (maxHealth > 0) and health/maxHealth) or 0
		local underHealthThreshold = trigger.underHealthThreshold and (trigger.underHealthThreshold ~= 0) and (trigger.underHealthThreshold > percHealth)
		local overHealthThreshold = trigger.overHealthThreshold and (trigger.overHealthThreshold ~= 0) and (trigger.overHealthThreshold < percHealth)
		if not (underHealthThreshold or overHealthThreshold) then return end
	end

	-- Power
	if trigger.powerThreshold then
		local powerUnit = (trigger.powerUsePlayer and "player") or frame.unit
		local power, maxPower = UnitPower(powerUnit, frame.PowerType), UnitPowerMax(powerUnit, frame.PowerType)
		local percPower = (maxPower and (maxPower > 0) and power/maxPower) or 0
		local underPowerThreshold = trigger.underPowerThreshold and (trigger.underPowerThreshold ~= 0) and (trigger.underPowerThreshold > percPower)
		local overPowerThreshold = trigger.overPowerThreshold and (trigger.overPowerThreshold ~= 0) and (trigger.overPowerThreshold < percPower)
		if not (underPowerThreshold or overPowerThreshold) then return end
	end

	-- Resting
	if trigger.isResting and not IsResting() then return end

	-- Quest Boss
	if trigger.questBoss and not UnitIsQuestBoss(frame.unit) then return end

	-- Player Combat
	if trigger.inCombat or trigger.outOfCombat then
		local inCombat = UnitAffectingCombat("player")
		if not ((trigger.inCombat and inCombat) or (trigger.outOfCombat and not inCombat)) then return end
	end

	-- Unit Combat
	if trigger.inCombatUnit or trigger.outOfCombatUnit then
		local inCombat = UnitAffectingCombat(frame.unit)
		if not ((trigger.inCombatUnit and inCombat) or (trigger.outOfCombatUnit and not inCombat)) then return end
	end

	-- Player Target
	if trigger.isTarget or trigger.notTarget then
		if not ((trigger.isTarget and frame.isTarget) or (trigger.notTarget and not frame.isTarget)) then return end
	end

	-- Unit Target
	if trigger.targetMe or trigger.notTargetMe then
		if not ((trigger.targetMe and frame.isTargetingMe) or (trigger.notTargetMe and not frame.isTargetingMe)) then return end
	end

	-- Unit Focus
	if trigger.isFocus or trigger.notFocus then
		if not ((trigger.isFocus and frame.isFocused) or (trigger.notFocus and not frame.isFocused)) then return end
	end

	-- Classification
	if trigger.classification.worldboss or trigger.classification.rareelite or trigger.classification.elite or trigger.classification.rare or trigger.classification.normal or trigger.classification.trivial or trigger.classification.minus then
		if not (frame.classification
		and ((trigger.classification.worldboss and frame.classification == "worldboss")
		or (trigger.classification.rareelite   and frame.classification == "rareelite")
		or (trigger.classification.elite	   and frame.classification == "elite")
		or (trigger.classification.rare		   and frame.classification == "rare")
		or (trigger.classification.normal	   and frame.classification == "normal")
		or (trigger.classification.trivial	   and frame.classification == "trivial")
		or (trigger.classification.minus	   and frame.classification == "minus"))) then return end
	end

	-- Group Role
	if trigger.role.tank or trigger.role.healer or trigger.role.damager then
		if not (E.myrole
		and ((trigger.role.tank and E.myrole == "TANK")
		or (trigger.role.healer and E.myrole == "HEALER")
		or (trigger.role.damager and E.myrole == "DAMAGER"))) then return end
	end

	do -- Class
		local matchMyClass --Only check spec when we match the class
		if trigger.class and next(trigger.class) then
			matchMyClass = trigger.class[E.myclass] and trigger.class[E.myclass].enabled
			if not matchMyClass then return end
		end

		-- Specialization
		if matchMyClass and (trigger.class[E.myclass] and trigger.class[E.myclass].specs and next(trigger.class[E.myclass].specs)) then
			if not (trigger.class[E.myclass].specs[E.myspec and GetSpecializationInfo(E.myspec)]) then return end
		end
	end

	do -- Instance
		-- Type
		local _, instanceType, instanceDifficulty
		if trigger.instanceType.none or trigger.instanceType.scenario or trigger.instanceType.party or trigger.instanceType.raid or trigger.instanceType.arena or trigger.instanceType.pvp then
			_, instanceType, instanceDifficulty = GetInstanceInfo()
			if not (instanceType
			and ((trigger.instanceType.none	  and instanceType == "none")
			or (trigger.instanceType.scenario and instanceType == "scenario")
			or (trigger.instanceType.party	  and instanceType == "party")
			or (trigger.instanceType.raid	  and instanceType == "raid")
			or (trigger.instanceType.arena	  and instanceType == "arena")
			or (trigger.instanceType.pvp	  and instanceType == "pvp"))) then return end
		end

		-- Difficulty
		if trigger.instanceType.party or trigger.instanceType.raid then
			if not instanceDifficulty then _, _, instanceDifficulty = GetInstanceInfo() end

			local dungeon = trigger.instanceDifficulty.dungeon
			if trigger.instanceType.party and instanceType == "party" and (dungeon.normal or dungeon.heroic or dungeon.mythic or dungeon["mythic+"] or dungeon.timewalking) then
				if not (instanceDifficulty
				and ((dungeon.normal	and instanceDifficulty == 1)
				or (dungeon.heroic		and instanceDifficulty == 2)
				or (dungeon.mythic		and instanceDifficulty == 23)
				or (dungeon["mythic+"]	and instanceDifficulty == 8)
				or (dungeon.timewalking	and instanceDifficulty == 24))) then return end
			end

			local raid = trigger.instanceDifficulty.raid
			if trigger.instanceType.raid and instanceType == "raid" and (raid.lfr or raid.normal or raid.heroic or raid.mythic or raid.timewalking or raid.legacy10normal or raid.legacy25normal or raid.legacy10heroic or raid.legacy25heroic) then
				if not (instanceDifficulty
				and ((raid.lfr			and (instanceDifficulty == 7 or instanceDifficulty == 17))
				or (raid.normal			and instanceDifficulty == 14)
				or (raid.heroic			and instanceDifficulty == 15)
				or (raid.mythic			and instanceDifficulty == 16)
				or (raid.timewalking	and instanceDifficulty == 33)
				or (raid.legacy10normal	and instanceDifficulty == 3)
				or (raid.legacy25normal	and instanceDifficulty == 4)
				or (raid.legacy10heroic	and instanceDifficulty == 5)
				or (raid.legacy25heroic	and instanceDifficulty == 6))) then return end
			end
		end
	end

	-- Talents
	if trigger.talent.enabled then
		local pvpTalent = trigger.talent.type == "pvp"
		local talentRows = (pvpTalent and 4) or 7
		local selected, pass

		for i = 1, talentRows do
			if trigger.talent["tier"..i.."enabled"] and trigger.talent["tier"..i].column > 0 then
				if pvpTalent then
					-- column is actually the talentID for pvpTalents
					local slotInfo = C_SpecializationInfo_GetPvpTalentSlotInfo(i)
					selected = (slotInfo and slotInfo.selectedTalentID) == trigger.talent["tier"..i].column
				else
					selected = select(4, GetTalentInfo(i, trigger.talent["tier"..i].column, 1))
				end

				if (selected and not trigger.talent["tier"..i].missing) or (trigger.talent["tier"..i].missing and not selected) then
					pass = true
					if not trigger.talent.requireAll then
						break -- break when not using requireAll because we matched one
					end
				elseif trigger.talent.requireAll then
					pass = false -- fail because requireAll
					break
				end
			end
		end

		if not pass then
			return
		end
	end

	-- Level
	if trigger.level then
		local myLevel = UnitLevel('player')
		local level = (frame.unit == 'player' and myLevel) or UnitLevel(frame.unit)
		local curLevel = (trigger.curlevel and trigger.curlevel ~= 0 and (trigger.curlevel == level))
		local minLevel = (trigger.minlevel and trigger.minlevel ~= 0 and (trigger.minlevel <= level))
		local maxLevel = (trigger.maxlevel and trigger.maxlevel ~= 0 and (trigger.maxlevel >= level))
		local matchMyLevel = trigger.mylevel and (level == myLevel)
		if not (curLevel or minLevel or maxLevel or matchMyLevel) then return end
	end

	-- Unit Type
	if trigger.nameplateType and trigger.nameplateType.enable then
		if not (frame.frameType
		and ((trigger.nameplateType.friendlyPlayer and frame.frameType == 'FRIENDLY_PLAYER')
		or (trigger.nameplateType.friendlyNPC	 and frame.frameType == 'FRIENDLY_NPC')
		or (trigger.nameplateType.enemyPlayer	 and frame.frameType == 'ENEMY_PLAYER')
		or (trigger.nameplateType.enemyNPC		 and frame.frameType == 'ENEMY_NPC')
		or (trigger.nameplateType.healer		 and frame.frameType == 'HEALER')
		or (trigger.nameplateType.player		 and frame.frameType == 'PLAYER'))) then return end
	end

	-- Creature Type
	if trigger.creatureType and trigger.creatureType.enable then
		if not trigger.creatureType[E.CreatureTypes[frame.creatureType]] then return end
	end

	-- Reaction (or Reputation) Type
	if trigger.reactionType and trigger.reactionType.enable then
		local reaction = (trigger.reactionType.reputation and frame.repReaction) or frame.reaction
		if not (reaction
		and ((reaction == 1 and trigger.reactionType.hated)
		or (reaction == 2 and trigger.reactionType.hostile)
		or (reaction == 3 and trigger.reactionType.unfriendly)
		or (reaction == 4 and trigger.reactionType.neutral)
		or (reaction == 5 and trigger.reactionType.friendly)
		or (reaction == 6 and trigger.reactionType.honored)
		or (reaction == 7 and trigger.reactionType.revered)
		or (reaction == 8 and trigger.reactionType.exalted))) then return end
	end

	--Try to match according to cooldown conditions
	if trigger.cooldowns and trigger.cooldowns.names and next(trigger.cooldowns.names) then
		if mod:StyleFilterCooldownCheck(trigger.cooldowns.names, trigger.cooldowns.mustHaveAll) == false then return end -- will be nil if none are set to ONCD or OFFCD
	end

	--Try to match according to buff aura conditions
	if trigger.buffs and trigger.buffs.names and next(trigger.buffs.names) then
		if mod:StyleFilterAuraCheck(frame, trigger.buffs.names, frame.Buffs, trigger.buffs.mustHaveAll, trigger.buffs.missing, trigger.buffs.minTimeLeft, trigger.buffs.maxTimeLeft) == false then return end -- will be nil if none are selected
	end

	--Try to match according to debuff aura conditions
	if trigger.debuffs and trigger.debuffs.names and next(trigger.debuffs.names) then
		if mod:StyleFilterAuraCheck(frame, trigger.debuffs.names, frame.Debuffs, trigger.debuffs.mustHaveAll, trigger.debuffs.missing, trigger.debuffs.minTimeLeft, trigger.debuffs.maxTimeLeft) == false then return end -- will be nil if none are selected
	end

	--Try to match according to raid target conditions
	if trigger.raidTarget.star or trigger.raidTarget.circle or trigger.raidTarget.diamond or trigger.raidTarget.triangle or trigger.raidTarget.moon or trigger.raidTarget.square or trigger.raidTarget.cross or trigger.raidTarget.skull then
		if not (frame.RaidTargetIndex
		and ((frame.RaidTargetIndex == 1 and trigger.raidTarget.star)
		or (frame.RaidTargetIndex == 2 and trigger.raidTarget.circle)
		or (frame.RaidTargetIndex == 3 and trigger.raidTarget.diamond)
		or (frame.RaidTargetIndex == 4 and trigger.raidTarget.triangle)
		or (frame.RaidTargetIndex == 5 and trigger.raidTarget.moon)
		or (frame.RaidTargetIndex == 6 and trigger.raidTarget.square)
		or (frame.RaidTargetIndex == 7 and trigger.raidTarget.cross)
		or (frame.RaidTargetIndex == 8 and trigger.raidTarget.skull))) then return end
	end

	if trigger.inVehicleUnit and not frame.UnitInVehicle then return end

	-- Plugin Callback
	if mod.StyleFilterCustomCheck and (mod:StyleFilterCustomCheck(frame, filter, trigger) == false) then return end

	-- Pass it along
	mod:StyleFilterPass(frame, filter.actions);
end

function mod:StyleFilterPass(frame, actions)
	local healthBarEnabled = (frame.frameType and mod.db.units[frame.frameType].health.enable) or (mod.db.displayStyle ~= "ALL") or (frame.isTarget and mod.db.alwaysShowTargetHealth)
	local powerBarEnabled = frame.frameType and mod.db.units[frame.frameType].power and mod.db.units[frame.frameType].power.enable
	local healthBarShown = healthBarEnabled and frame.Health:IsShown()

	mod:StyleFilterSetChanges(frame, actions,
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

function mod:StyleFilterClear(frame)
	if frame and frame.StyleChanged then
		mod:StyleFilterClearChanges(frame, frame.HealthColorChanged, frame.PowerColorChanged, frame.BorderChanged, frame.FlashingHealth, frame.TextureChanged, frame.ScaleChanged, frame.AlphaChanged, frame.NameColorChanged, frame.PortraitShown, frame.NameOnlyChanged, frame.VisibilityChanged)
	end
end

function mod:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] --Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

mod.StyleFilterEventFunctions = { -- a prefunction to the injected ouf watch
	['PLAYER_TARGET_CHANGED'] = function(self)
		self.isTarget = self.unit and UnitIsUnit(self.unit, 'target') or nil
	end,
	['PLAYER_FOCUS_CHANGED'] = function(self)
		self.isFocused = self.unit and UnitIsUnit(self.unit, 'focus') or nil
	end,
	['RAID_TARGET_UPDATE'] = function(self)
		self.RaidTargetIndex = self.unit and GetRaidTargetIndex(self.unit) or nil
	end,
	['UNIT_ENTERED_VEHICLE'] = function(self)
		self.UnitInVehicle = self.unit and UnitInVehicle(self.unit) or nil
	end,
	['UNIT_EXITED_VEHICLE'] = function(self)
		self.UnitInVehicle = self.unit and UnitInVehicle(self.unit) or nil
	end,
	['UNIT_EXITING_VEHICLE'] = function(self)
		self.UnitInVehicle = self.unit and UnitInVehicle(self.unit) or nil
	end,
	['UNIT_TARGET'] = function(self, _, unit)
		unit = unit or self.unit
		self.isTargetingMe = UnitIsUnit(unit..'target', 'player') or nil
	end
}

function mod:StyleFilterSetVariables(nameplate)
	for _, func in pairs(mod.StyleFilterEventFunctions) do
		func(nameplate)
	end
end

function mod:StyleFilterClearVariables(nameplate)
	nameplate.isTarget = nil
	nameplate.isFocused = nil
	nameplate.isTargetingMe = nil
	nameplate.RaidTargetIndex = nil
	nameplate.ThreatScale = nil
	nameplate.UnitInVehicle = nil
end

mod.StyleFilterTriggerList = {} -- configured filters enabled with sorted priority
mod.StyleFilterTriggerEvents = {} -- events required by the filter that we need to watch for
mod.StyleFilterPlateEvents = { -- events watched inside of ouf, which is called on the nameplate itself
	['NAME_PLATE_UNIT_ADDED'] = 1 -- rest is populated from `StyleFilterDefaultEvents` as needed
}
mod.StyleFilterDefaultEvents = { -- list of events style filter uses to populate plate events
	'PLAYER_TARGET_CHANGED',
	'PLAYER_FOCUS_CHANGED',
	'PLAYER_UPDATE_RESTING',
	'RAID_TARGET_UPDATE',
	'SPELL_UPDATE_COOLDOWN',
	'UNIT_AURA',
	'UNIT_DISPLAYPOWER',
	'UNIT_ENTERED_VEHICLE',
	'UNIT_EXITED_VEHICLE',
	'UNIT_EXITING_VEHICLE',
	'UNIT_FACTION',
	'UNIT_FLAGS',
	'UNIT_HEALTH',
	'UNIT_HEALTH_FREQUENT',
	'UNIT_MAXHEALTH',
	'UNIT_NAME_UPDATE',
	'UNIT_POWER_FREQUENT',
	'UNIT_POWER_UPDATE',
	'UNIT_TARGET',
	'UNIT_THREAT_LIST_UPDATE',
}

function mod:StyleFilterWatchEvents()
	for _, event in ipairs(mod.StyleFilterDefaultEvents) do
		mod.StyleFilterPlateEvents[event] = mod.StyleFilterTriggerEvents[event] and true or nil
	end
end

function mod:StyleFilterConfigure()
	wipe(mod.StyleFilterTriggerList)
	wipe(mod.StyleFilterTriggerEvents)

	for filterName, filter in pairs(E.global.nameplate.filters) do
		if filter.triggers and E.db.nameplates and E.db.nameplates.filters then
			if E.db.nameplates.filters[filterName] and E.db.nameplates.filters[filterName].triggers and E.db.nameplates.filters[filterName].triggers.enable then
				tinsert(mod.StyleFilterTriggerList, {filterName, filter.triggers.priority or 1})

				-- NOTE: 0 for fake events, 1 to override StyleFilterWaitTime
				mod.StyleFilterTriggerEvents.FAKE_AuraWaitTimer = 0 -- for minTimeLeft and maxTimeLeft aura trigger
				mod.StyleFilterTriggerEvents.NAME_PLATE_UNIT_ADDED = 1

				if filter.triggers.casting then
					if next(filter.triggers.casting.spells) then
						for _, value in pairs(filter.triggers.casting.spells) do
							if value == true then
								mod.StyleFilterTriggerEvents.FAKE_Casting = 0
								break
							end
						end
					end

					if filter.triggers.casting.interruptible or filter.triggers.casting.notInterruptible then
						mod.StyleFilterTriggerEvents.FAKE_Casting = 0
					end
				end

				-- real events
				mod.StyleFilterTriggerEvents.PLAYER_TARGET_CHANGED = true

				if filter.triggers.reactionType and filter.triggers.reactionType.enable then
					mod.StyleFilterTriggerEvents.UNIT_FACTION = true
				end

				if filter.triggers.targetMe or filter.triggers.notTargetMe then
					mod.StyleFilterTriggerEvents.UNIT_TARGET = true
				end

				if filter.triggers.isFocus or filter.triggers.notFocus then
					mod.StyleFilterTriggerEvents.PLAYER_FOCUS_CHANGED = true
				end
				
				if filter.triggers.isResting then
                    mod.StyleFilterTriggerEvents.PLAYER_UPDATE_RESTING = true
                end

				if filter.triggers.healthThreshold then
					mod.StyleFilterTriggerEvents.UNIT_HEALTH = true
					mod.StyleFilterTriggerEvents.UNIT_MAXHEALTH = true
					mod.StyleFilterTriggerEvents.UNIT_HEALTH_FREQUENT = true
				end

				if filter.triggers.powerThreshold then
					mod.StyleFilterTriggerEvents.UNIT_POWER_UPDATE = true
					mod.StyleFilterTriggerEvents.UNIT_POWER_FREQUENT = true
					mod.StyleFilterTriggerEvents.UNIT_DISPLAYPOWER = true
				end

				if filter.triggers.raidTarget then
					mod.StyleFilterTriggerEvents.RAID_TARGET_UPDATE = true
				end

				if filter.triggers.unitInVehicle then
					mod.StyleFilterTriggerEvents.UNIT_ENTERED_VEHICLE = true
					mod.StyleFilterTriggerEvents.UNIT_EXITED_VEHICLE = true
					mod.StyleFilterTriggerEvents.UNIT_EXITING_VEHICLE = true
				end

				if filter.triggers.isResting then
                    mod.StyleFilterTriggerEvents.PLAYER_UPDATE_RESTING = true
                end

				if next(filter.triggers.names) then
					for _, value in pairs(filter.triggers.names) do
						if value == true then
							mod.StyleFilterTriggerEvents.UNIT_NAME_UPDATE = true
							break
						end
					end
				end

				if filter.triggers.inCombat or filter.triggers.outOfCombat or filter.triggers.inCombatUnit or filter.triggers.outOfCombatUnit then
					mod.StyleFilterTriggerEvents.UNIT_THREAT_LIST_UPDATE = true
					mod.StyleFilterTriggerEvents.UNIT_FLAGS = true
				end

				if next(filter.triggers.cooldowns.names) then
					for _, value in pairs(filter.triggers.cooldowns.names) do
						if value == "ONCD" or value == "OFFCD" then
							mod.StyleFilterTriggerEvents.SPELL_UPDATE_COOLDOWN = true
							break
						end
					end
				end

				if next(filter.triggers.buffs.names) then
					for _, value in pairs(filter.triggers.buffs.names) do
						if value == true then
							mod.StyleFilterTriggerEvents.UNIT_AURA = true
							break
						end
					end
				end

				if next(filter.triggers.debuffs.names) then
					for _, value in pairs(filter.triggers.debuffs.names) do
						if value == true then
							mod.StyleFilterTriggerEvents.UNIT_AURA = true
							break
						end
					end
				end
			end
		end
	end

	mod:StyleFilterWatchEvents()

	if next(mod.StyleFilterTriggerList) then
		sort(mod.StyleFilterTriggerList, mod.StyleFilterSort) -- sort by priority
	else
		if _G.ElvNP_Player then
			mod:StyleFilterClear(_G.ElvNP_Player)
		end

		for nameplate in pairs(mod.Plates) do
			mod:StyleFilterClear(nameplate)
		end
	end
end

function mod:StyleFilterUpdate(frame, event)
	if not (frame and mod.StyleFilterTriggerEvents[event]) then return end

	if mod.StyleFilterTriggerEvents[event] ~= 1 then
		if not frame.StyleFilterWaitTime then
			frame.StyleFilterWaitTime = GetTime()
		elseif GetTime() > (frame.StyleFilterWaitTime + 0.1) then
			frame.StyleFilterWaitTime = nil
		else
			return --block calls faster than 0.1 second
		end
	end

	mod:StyleFilterClear(frame)

	local filter
	for filterNum in ipairs(mod.StyleFilterTriggerList) do
		filter = E.global.nameplate.filters[mod.StyleFilterTriggerList[filterNum][1]];
		if filter then
			mod:StyleFilterConditionCheck(frame, filter, filter.triggers)
		end
	end
end

do -- oUF style filter inject watch functions without actually registering any events
	local update = function(frame, event, ...)
		if mod.StyleFilterEventFunctions[event] then
			mod.StyleFilterEventFunctions[event](frame, event, ...)
		end
		mod:StyleFilterUpdate(frame, event)
	end

	local oUF_event_metatable = {
		__call = function(funcs, frame, ...)
			for _, func in next, funcs do
				func(frame, ...)
			end
		end,
	}

	local oUF_fake_register = function(frame, event, remove)
		local curev = frame[event]
		if curev then
			local kind = type(curev)
			if kind == 'function' and curev ~= update then
				frame[event] = setmetatable({curev, update}, oUF_event_metatable)
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
			frame[event] = (not remove and update) or nil
		end
	end

	local styleFilterIsWatching = function(frame, event)
		local curev = frame[event]
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

function mod:StyleFilterRegister(nameplate, event, unitless, func)
	if not nameplate:IsEventRegistered(event) then
		nameplate:RegisterEvent(event, func or E.noop, unitless)
	end
end

-- events we actually register on plates when they aren't added
function mod:StyleFilterEvents(nameplate)
	mod:StyleFilterRegister(nameplate,'PLAYER_FOCUS_CHANGED', true)
	mod:StyleFilterRegister(nameplate,'PLAYER_TARGET_CHANGED', true)
	mod:StyleFilterRegister(nameplate,'PLAYER_UPDATE_RESTING', true)
	mod:StyleFilterRegister(nameplate,'RAID_TARGET_UPDATE', true)
	mod:StyleFilterRegister(nameplate,'SPELL_UPDATE_COOLDOWN', true)
	mod:StyleFilterRegister(nameplate,'UNIT_FLAGS')
	mod:StyleFilterRegister(nameplate,'UNIT_TARGET')
	mod:StyleFilterRegister(nameplate,'UNIT_THREAT_LIST_UPDATE')
	mod:StyleFilterRegister(nameplate,'UNIT_ENTERED_VEHICLE')
	mod:StyleFilterRegister(nameplate,'UNIT_EXITED_VEHICLE')
	mod:StyleFilterRegister(nameplate,'UNIT_EXITING_VEHICLE', true)

	mod:StyleFilterEventWatch(nameplate)
end

-- Shamelessy taken from AceDB-3.0 and stripped down by Simpy
local function copyDefaults(dest, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if not rawget(dest, k) then rawset(dest, k, {}) end
			if type(dest[k]) == "table" then copyDefaults(dest[k], v) end
		elseif rawget(dest, k) == nil then
			rawset(dest, k, v)
		end
	end
end

local function removeDefaults(db, defaults)
	setmetatable(db, nil)

	for k,v in pairs(defaults) do
		if type(v) == "table" and type(db[k]) == "table" then
			removeDefaults(db[k], v)
			if next(db[k]) == nil then db[k] = nil end
		elseif db[k] == defaults[k] then
			db[k] = nil
		end
	end
end

function mod:StyleFilterClearDefaults()
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

function mod:StyleFilterCopyDefaults(tbl)
	copyDefaults(tbl, E.StyleFilterDefaults);
end

function mod:StyleFilterInitialize()
	for _, filterTable in pairs(E.global.nameplate.filters) do
		mod:StyleFilterCopyDefaults(filterTable);
	end
end
