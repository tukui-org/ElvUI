local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = E.Libs.LSM

local _G = _G
local ipairs, next, pairs, select = ipairs, next, pairs, select
local setmetatable, tostring, tonumber, type, unpack = setmetatable, tostring, tonumber, type, unpack
local strmatch, tinsert, tremove, sort, wipe = strmatch, tinsert, tremove, sort, wipe

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
local UnitPlayerControlled = UnitPlayerControlled
local UnitAffectingCombat = UnitAffectingCombat
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitInVehicle = UnitInVehicle
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit
local UnitIsPVP = UnitIsPVP
local UnitIsQuestBoss = UnitIsQuestBoss
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitThreatSituation = UnitThreatSituation

local C_Timer_NewTimer = C_Timer.NewTimer
local C_SpecializationInfo_GetPvpTalentSlotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo

local FallbackColor = {r=1, b=1, g=1}

mod.StyleFilterStackPattern = '([^\n]+)\n?(%d*)$'
mod.TriggerConditions = {
	reactions = {'hated', 'hostile', 'unfriendly', 'neutral', 'friendly', 'honored', 'revered', 'exalted'},
	raidTargets = {'star', 'circle', 'diamond', 'triangle', 'moon', 'square', 'cross', 'skull'},
	tankThreat = {[0] = 3, 2, 1, 0},
	frameTypes = {
		FRIENDLY_PLAYER = 'friendlyPlayer',
		FRIENDLY_NPC = 'friendlyNPC',
		ENEMY_PLAYER = 'enemyPlayer',
		ENEMY_NPC = 'enemyNPC',
		PLAYER = 'player'
	},
	roles = {
		TANK = 'tank',
		HEALER = 'healer',
		DAMAGER = 'damager'
	},
	keys = {
		Modifier = IsModifierKeyDown,
		Shift = IsShiftKeyDown,
		Alt = IsAltKeyDown,
		Control = IsControlKeyDown,
		LeftShift = IsLeftShiftKeyDown,
		LeftAlt = IsLeftAltKeyDown,
		LeftControl = IsLeftControlKeyDown,
		RightShift = IsRightShiftKeyDown,
		RightAlt = IsRightAltKeyDown,
		RightControl = IsRightControlKeyDown,
	},
	threat = {
		[-3] = 'offTank',
		[-2] = 'offTankBadTransition',
		[-1] = 'offTankGoodTransition',
		[0] = 'good',
		[1] = 'badTransition',
		[2] = 'goodTransition',
		[3] = 'bad'
	},
	difficulties = {
		-- dungeons
		[1] = 'normal',
		[2] = 'heroic',
		[8] = 'mythic+',
		[23] = 'mythic',
		[24] = 'timewalking',
		-- raids
		[7] = 'lfr',
		[17] = 'lfr',
		[14] = 'normal',
		[15] = 'heroic',
		[16] = 'mythic',
		[33] = 'timewalking',
		[3] = 'legacy10normal',
		[4] = 'legacy25normal',
		[5] = 'legacy10heroic',
		[6] = 'legacy25heroic',
	}
}

do -- E.CreatureTypes; Do *not* change the value, only the key (['key'] = 'value').
	local c, locale = {}, GetLocale()
	if locale == 'frFR' then
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
	elseif locale == 'deDE' then
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
	elseif locale == 'koKR' then
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
	elseif locale == 'ruRU' then
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
	elseif locale == 'zhCN' then
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
	elseif locale == 'zhTW' then
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
	elseif locale == 'esES' then
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
	elseif locale == 'esMX' then
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
	elseif locale == 'ptBR' then
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
	elseif locale == 'itIT' then
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

function mod:StyleFilterTickerCallback(frame, button, timer)
	if frame and frame:IsShown() then
		mod:StyleFilterUpdate(frame, 'FAKE_AuraWaitTimer')
	end

	if button and button[timer] then
		button[timer]:Cancel()
		button[timer] = nil
	end
end

function mod:StyleFilterTickerCreate(delay, frame, button, timer)
	return C_Timer_NewTimer(delay, function() mod:StyleFilterTickerCallback(frame, button, timer) end)
end

function mod:StyleFilterAuraWait(frame, button, timer, timeLeft, mTimeLeft)
	if button and not button[timer] then
		local updateIn = timeLeft-mTimeLeft
		if updateIn > 0 then -- also add a tenth of a second to updateIn to prevent the timer from firing on the same second
			button[timer] = mod:StyleFilterTickerCreate(updateIn+0.1, frame, button, timer)
		end
	end
end

function mod:StyleFilterAuraCheck(frame, names, auras, mustHaveAll, missing, minTimeLeft, maxTimeLeft)
	local total, count = 0, 0
	for name, value in pairs(names) do
		if value then -- only if they are turned on
			total = total + 1 -- keep track of the names

			if auras.createdIcons and auras.createdIcons > 0 then
				for i = 1, auras.createdIcons do
					local button = auras[i]
					if button then
						if button:IsShown() then
							local spell, stacks, failed = strmatch(name, mod.StyleFilterStackPattern)
							if stacks ~= '' then failed = not (button.stackCount and button.stackCount >= tonumber(stacks)) end
							if not failed and ((button.name and button.name == spell) or (button.spellID and button.spellID == tonumber(spell))) then
								local hasMinTime = minTimeLeft and minTimeLeft ~= 0
								local hasMaxTime = maxTimeLeft and maxTimeLeft ~= 0
								local timeLeft = (hasMinTime or hasMaxTime) and button.expiration and (button.expiration - GetTime())
								local minTimeAllow = not hasMinTime or (timeLeft and timeLeft > minTimeLeft)
								local maxTimeAllow = not hasMaxTime or (timeLeft and timeLeft < maxTimeLeft)
								if timeLeft then -- if we use a min/max time setting; we must create a delay timer
									if hasMinTime then mod:StyleFilterAuraWait(frame, button, 'hasMinTimer', timeLeft, minTimeLeft) end
									if hasMaxTime then mod:StyleFilterAuraWait(frame, button, 'hasMaxTimer', timeLeft, maxTimeLeft) end
								end
								if minTimeAllow and maxTimeAllow then
									count = count + 1 -- keep track of how many matches we have
								end
							end
						else -- cancel stale timers
							if button.hasMinTimer then button.hasMinTimer:Cancel() button.hasMinTimer = nil end
							if button.hasMaxTimer then button.hasMaxTimer:Cancel() button.hasMaxTimer = nil end
	end end end end end end

	if total == 0 then
		return nil -- If no auras are checked just pass nil, we dont need to run the filter here.
	else
		return ((mustHaveAll and not missing) and total == count)	-- [x] Check for all [ ] Missing: total needs to match count
		or ((not mustHaveAll and not missing) and count > 0)		-- [ ] Check for all [ ] Missing: count needs to be greater than zero
		or ((not mustHaveAll and missing) and count == 0)			-- [ ] Check for all [x] Missing: count needs to be zero
		or ((mustHaveAll and missing) and total ~= count)			-- [x] Check for all [x] Missing: count must not match total
	end
end

function mod:StyleFilterCooldownCheck(names, mustHaveAll)
	local _, gcd = GetSpellCooldown(61304)
	local total, count = 0, 0

	for name, value in pairs(names) do
		if GetSpellInfo(name) then -- check spell name valid, GetSpellCharges/GetSpellCooldown will return nil if not known by your class
			if value == 'ONCD' or value == 'OFFCD' then -- only if they are turned on
				total = total + 1 -- keep track of the names

				local charges = GetSpellCharges(name)
				local _, duration = GetSpellCooldown(name)

				if (charges and charges == 0 and value == 'ONCD') -- charges exist and the current number of charges is 0 means that it is completely on cooldown.
				or (charges and charges > 0 and value == 'OFFCD') -- charges exist and the current number of charges is greater than 0 means it is not on cooldown.
				or (charges == nil and (duration > gcd and value == 'ONCD')) -- no charges exist and the duration of the cooldown is greater than the GCD spells current cooldown then it is on cooldown.
				or (charges == nil and (duration <= gcd and value == 'OFFCD')) then -- no charges exist and the duration of the cooldown is at or below the current GCD cooldown spell then it is not on cooldown.
					count = count + 1
					-- print(((charges and charges == 0 and value == 'ONCD') and name..' (charge) passes because it is on cd') or ((charges and charges > 0 and value == 'OFFCD') and name..' (charge) passes because it is offcd') or ((charges == nil and (duration > gcd and value == 'ONCD')) and name..'passes because it is on cd.') or ((charges == nil and (duration <= gcd and value == 'OFFCD')) and name..' passes because it is off cd.'))
	end end end end

	if total == 0 then
		return nil
	else
		return (mustHaveAll and total == count) or (not mustHaveAll and count > 0)
	end
end

function mod:StyleFilterFinishedFlash(requested)
	if not requested then self:Play() end
end

function mod:StyleFilterSetupFlash(FlashTexture)
	local anim = FlashTexture:CreateAnimationGroup('Flash')
	anim:SetScript('OnFinished', mod.StyleFilterFinishedFlash)
	FlashTexture.anim = anim

	local fadein = anim:CreateAnimation('ALPHA', 'FadeIn')
	fadein:SetFromAlpha(0)
	fadein:SetToAlpha(1)
	fadein:SetOrder(2)
	anim.fadein = fadein

	local fadeout = anim:CreateAnimation('ALPHA', 'FadeOut')
	fadeout:SetFromAlpha(1)
	fadeout:SetToAlpha(0)
	fadeout:SetOrder(1)
	anim.fadeout = fadeout

	return anim
end

function mod:StyleFilterUpdatePlate(frame, updateBase)
	if updateBase then
		mod:UpdatePlate(frame, true) -- enable elements back
	end

	if frame.frameType then
		local db = mod:PlateDB(frame)
		if db.health.enable then frame.Health:ForceUpdate() end
		if db.power.enable then frame.Power:ForceUpdate() end
	end

	if mod.db.threat.enable and mod.db.threat.useThreatColor and not UnitIsTapDenied(frame.unit) then
		frame.ThreatIndicator:ForceUpdate() -- this will account for the threat health color
	end

	mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, 0, 1) -- fade those back in so it looks clean
end

function mod:StyleFilterBorderLock(backdrop, switch)
	backdrop.ignoreBorderColors = switch -- but keep the backdrop updated
end

do
	local empty = {}
	function mod:StyleFilterChanges(frame)
		return (frame and frame.StyleFilterChanges) or empty
	end
end

function mod:StyleFilterSetChanges(frame, actions, HealthColor, PowerColor, Borders, HealthFlash, HealthTexture, Scale, Alpha, NameTag, PowerTag, HealthTag, TitleTag, LevelTag, Portrait, NameOnly, Visibility)
	local c = frame.StyleFilterChanges
	if not c then return end

	local db = mod:PlateDB(frame)

	if Visibility then
		c.Visibility = true
		mod:DisablePlate(frame) -- disable the plate elements
		frame:ClearAllPoints() -- lets still move the frame out cause its clickable otherwise
		frame:SetPoint('TOP', E.UIParent, 'BOTTOM', 0, -500)
		return -- We hide it. Lets not do other things (no point)
	end
	if HealthColor then
		local hc = actions.color.healthColor
		c.HealthColor = hc -- used by Health_UpdateColor

		frame.Health:SetStatusBarColor(hc.r, hc.g, hc.b, hc.a)
		frame.Cutaway.Health:SetVertexColor(hc.r * 1.5, hc.g * 1.5, hc.b * 1.5, hc.a)
	end
	if PowerColor then
		local pc = actions.color.powerColor
		c.PowerColor = true

        frame.Power:SetStatusBarColor(pc.r, pc.g, pc.b, pc.a)
        frame.Cutaway.Power:SetVertexColor(pc.r * 1.5, pc.g * 1.5, pc.b * 1.5, pc.a)
	end
	if Borders then
		local bc = actions.color.borderColor
		c.Borders = true

		mod:StyleFilterBorderLock(frame.Health.backdrop, true)
		frame.Health.backdrop:SetBackdropBorderColor(bc.r, bc.g, bc.b, bc.a)
		if frame.Power.backdrop and (frame.frameType and db.power and db.power.enable) then
			mod:StyleFilterBorderLock(frame.Power.backdrop, true)
			frame.Power.backdrop:SetBackdropBorderColor(bc.r, bc.g, bc.b, bc.a)
		end
	end
	if HealthFlash then
		local fc = actions.flash.color
		c.HealthFlash = true

		if not HealthTexture then frame.HealthFlashTexture:SetTexture(LSM:Fetch('statusbar', mod.db.statusbar)) end
		frame.HealthFlashTexture:SetVertexColor(fc.r, fc.g, fc.b)

		local anim = frame.HealthFlashTexture.anim or mod:StyleFilterSetupFlash(frame.HealthFlashTexture)
		anim.fadein:SetToAlpha(fc.a)
		anim.fadeout:SetFromAlpha(fc.a)

		frame.HealthFlashTexture:Show()
		E:Flash(frame.HealthFlashTexture, actions.flash.speed * 0.1, true)
	end
	if HealthTexture then
		local tx = LSM:Fetch('statusbar', actions.texture.texture)
		c.HealthTexture = true

		frame.Highlight.texture:SetTexture(tx)
		frame.Health:SetStatusBarTexture(tx)
		if HealthFlash then frame.HealthFlashTexture:SetTexture(tx) end
	end
	if Scale then
		c.Scale = true
		mod:ScalePlate(frame, actions.scale)
	end
	if Alpha then
		c.Alpha = true
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, frame:GetAlpha(), actions.alpha / 100)
	end
	if Portrait then
		c.Portrait = true
		mod:Update_Portrait(frame)
		frame.Portrait:ForceUpdate()
	end
	if NameOnly then
		c.NameOnly = true
		mod:DisablePlate(frame, true)
	end
	-- Keeps Tag changes after NameOnly
	if NameTag then
		c.NameTag = true
		frame:Tag(frame.Name, actions.tags.name)
		frame.Name:UpdateTag()
	end
	if PowerTag then
		c.PowerTag = true
		frame:Tag(frame.Power.Text, actions.tags.power)
		frame.Power.Text:UpdateTag()
	end
	if HealthTag then
		c.HealthTag = true
		frame:Tag(frame.Health.Text, actions.tags.health)
		frame.Health.Text:UpdateTag()
	end
	if TitleTag then
		c.TitleTag = true
		frame:Tag(frame.Title, actions.tags.title)
		frame.Title:UpdateTag()
	end
	if LevelTag then
		c.LevelTag = true
		frame:Tag(frame.Level, actions.tags.level)
		frame.Level:UpdateTag()
	end
end

function mod:StyleFilterClearChanges(frame, updateBase, HealthColor, PowerColor, Borders, HealthFlash, HealthTexture, Scale, Alpha, NameTag, PowerTag, HealthTag, TitleTag, LevelTag, Portrait, NameOnly, Visibility)
	local db = mod:PlateDB(frame)

	if frame.StyleFilterChanges then
		wipe(frame.StyleFilterChanges)
	end

	if Visibility then
		mod:StyleFilterUpdatePlate(frame, updateBase)
		frame:ClearAllPoints() -- pull the frame back in
		frame:SetPoint('CENTER')
	end
	if HealthColor then
		local h = frame.Health
		if h.r and h.g and h.b then
			h:SetStatusBarColor(h.r, h.g, h.b)
			frame.Cutaway.Health:SetVertexColor(h.r * 1.5, h.g * 1.5, h.b * 1.5, 1)
		end
	end
	if PowerColor then
		local pc = E.db.unitframe.colors.power[frame.Power.token] or _G.PowerBarColor[frame.Power.token] or FallbackColor
		frame.Power:SetStatusBarColor(pc.r, pc.g, pc.b)
		frame.Cutaway.Power:SetVertexColor(pc.r * 1.5, pc.g * 1.5, pc.b * 1.5, 1)
	end
	if Borders then
		local r, g, b = unpack(E.media.bordercolor)
		mod:StyleFilterBorderLock(frame.Health.backdrop)
		frame.Health.backdrop:SetBackdropBorderColor(r, g, b)
		if frame.Power.backdrop and (frame.frameType and db.power and db.power.enable) then
			mod:StyleFilterBorderLock(frame.Power.backdrop)
			frame.Power.backdrop:SetBackdropBorderColor(r, g, b)
		end
	end
	if HealthFlash then
		E:StopFlash(frame.HealthFlashTexture)
		frame.HealthFlashTexture:Hide()
	end
	if HealthTexture then
		local tx = LSM:Fetch('statusbar', mod.db.statusbar)
		frame.Highlight.texture:SetTexture(tx)
		frame.Health:SetStatusBarTexture(tx)
	end
	if Scale then
		mod:ScalePlate(frame, frame.ThreatScale or 1)
	end
	if Alpha then
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, (frame.FadeObject and frame.FadeObject.endAlpha) or 0.5, 1)
	end
	if Portrait then
		mod:Update_Portrait(frame)
		frame.Portrait:ForceUpdate()
	end
	if NameOnly then
		mod:StyleFilterUpdatePlate(frame, updateBase)
	else -- Only update these if it wasn't NameOnly. Otherwise, it leads to `Update_Tags` which does the job.
		if NameTag then frame:Tag(frame.Name, db.name.format) frame.Name:UpdateTag() end
		if PowerTag then frame:Tag(frame.Power.Text, db.power.text.format) frame.Power.Text:UpdateTag() end
		if HealthTag then frame:Tag(frame.Health.Text, db.health.text.format) frame.Health.Text:UpdateTag() end
		if TitleTag then frame:Tag(frame.Title, db.title.format) frame.Title:UpdateTag() end
		if LevelTag then frame:Tag(frame.Level, db.level.format) frame.Level:UpdateTag() end
	end
end

function mod:StyleFilterThreatUpdate(frame, unit)
	if mod:UnitExists(unit) then
		local isTank, offTank, feedbackUnit = mod.ThreatIndicator_PreUpdate(frame.ThreatIndicator, unit, true)
		if feedbackUnit and (feedbackUnit ~= unit) and mod:UnitExists(feedbackUnit) then
			return isTank, offTank, UnitThreatSituation(feedbackUnit, unit)
		else
			return isTank, offTank, UnitThreatSituation(unit)
		end
	end
end

function mod:StyleFilterConditionCheck(frame, filter, trigger)
	local passed -- skip StyleFilterPass when triggers are empty

	-- Health
	if trigger.healthThreshold then
		local healthUnit = (trigger.healthUsePlayer and 'player') or frame.unit
		local health, maxHealth = UnitHealth(healthUnit), UnitHealthMax(healthUnit)
		local percHealth = (maxHealth and (maxHealth > 0) and health/maxHealth) or 0
		local underHealthThreshold = trigger.underHealthThreshold and (trigger.underHealthThreshold ~= 0) and (trigger.underHealthThreshold > percHealth)
		local overHealthThreshold = trigger.overHealthThreshold and (trigger.overHealthThreshold ~= 0) and (trigger.overHealthThreshold < percHealth)
		if underHealthThreshold or overHealthThreshold then passed = true else return end
	end

	-- Power
	if trigger.powerThreshold then
		local powerUnit = (trigger.powerUsePlayer and 'player') or frame.unit
		local power, maxPower = UnitPower(powerUnit, frame.PowerType), UnitPowerMax(powerUnit, frame.PowerType)
		local percPower = (maxPower and (maxPower > 0) and power/maxPower) or 0
		local underPowerThreshold = trigger.underPowerThreshold and (trigger.underPowerThreshold ~= 0) and (trigger.underPowerThreshold > percPower)
		local overPowerThreshold = trigger.overPowerThreshold and (trigger.overPowerThreshold ~= 0) and (trigger.overPowerThreshold < percPower)
		if underPowerThreshold or overPowerThreshold then passed = true else return end
	end

	-- Level
	if trigger.level then
		local myLevel = E.mylevel
		local level = (frame.unit == 'player' and myLevel) or UnitLevel(frame.unit)
		local curLevel = (trigger.curlevel and trigger.curlevel ~= 0 and (trigger.curlevel == level))
		local minLevel = (trigger.minlevel and trigger.minlevel ~= 0 and (trigger.minlevel <= level))
		local maxLevel = (trigger.maxlevel and trigger.maxlevel ~= 0 and (trigger.maxlevel >= level))
		local matchMyLevel = trigger.mylevel and (level == myLevel)
		if curLevel or minLevel or maxLevel or matchMyLevel then passed = true else return end
	end

	-- Resting
	if trigger.isResting then
		if IsResting() then passed = true else return end
	end

	-- Quest Boss
	if trigger.questBoss then
		if UnitIsQuestBoss(frame.unit) then passed = true else return end
	end

	-- Require Target
	if trigger.requireTarget then
		if UnitExists('target') then passed = true else return end
	end

	-- Player Combat
	if trigger.inCombat or trigger.outOfCombat then
		local inCombat = UnitAffectingCombat('player')
		if (trigger.inCombat and inCombat) or (trigger.outOfCombat and not inCombat) then passed = true else return end
	end

	-- Unit Combat
	if trigger.inCombatUnit or trigger.outOfCombatUnit then
		local inCombat = UnitAffectingCombat(frame.unit)
		if (trigger.inCombatUnit and inCombat) or (trigger.outOfCombatUnit and not inCombat) then passed = true else return end
	end

	-- Player Target
	if trigger.isTarget or trigger.notTarget then
		if (trigger.isTarget and frame.isTarget) or (trigger.notTarget and not frame.isTarget) then passed = true else return end
	end

	-- Unit Target
	if trigger.targetMe or trigger.notTargetMe then
		if (trigger.targetMe and frame.isTargetingMe) or (trigger.notTargetMe and not frame.isTargetingMe) then passed = true else return end
	end

	-- Unit Focus
	if trigger.isFocus or trigger.notFocus then
		if (trigger.isFocus and frame.isFocused) or (trigger.notFocus and not frame.isFocused) then passed = true else return end
	end

	-- Unit Pet
	if trigger.isPet or trigger.isNotPet then
		if (trigger.isPet and frame.isPet or trigger.isNotPet and not frame.isPet) then passed = true else return end
	end

	-- Unit Player Controlled
	if trigger.isPlayerControlled or trigger.isNotPlayerControlled then
		local playerControlled = UnitPlayerControlled(frame.unit) and not frame.isPlayer
		if (trigger.isPlayerControlled and playerControlled or trigger.isNotPlayerControlled and not playerControlled) then passed = true else return end
	end

	-- Unit Owned By Player
	if trigger.isOwnedByPlayer or trigger.isNotOwnedByPlayer then
		local ownedByPlayer = UnitIsOwnerOrControllerOfUnit('player', frame.unit)
		if (trigger.isOwnedByPlayer and ownedByPlayer or trigger.isNotOwnedByPlayer and not ownedByPlayer) then passed = true else return end
	end

	-- Unit PvP
	if trigger.isPvP or trigger.isNotPvP then
		local isPvP = UnitIsPVP(frame.unit)
		if (trigger.isPvP and isPvP or trigger.isNotPvP and not isPvP) then passed = true else return end
	end

	-- Unit Tap Denied
	if trigger.isTapDenied or trigger.isNotTapDenied then
		local tapDenied = UnitIsTapDenied(frame.unit)
		if (trigger.isTapDenied and tapDenied) or (trigger.isNotTapDenied and not tapDenied) then passed = true else return end
	end

	-- Player Vehicle
	if trigger.inVehicle or trigger.outOfVehicle then
		local inVehicle = UnitInVehicle('player')
		if (trigger.inVehicle and inVehicle) or (trigger.outOfVehicle and not inVehicle) then passed = true else return end
	end

	-- Unit Vehicle
	if trigger.inVehicleUnit or trigger.outOfVehicleUnit then
		if (trigger.inVehicleUnit and frame.inVehicle) or (trigger.outOfVehicleUnit and not frame.inVehicle) then passed = true else return end
	end

	-- Player Can Attack
	if trigger.playerCanAttack or trigger.playerCanNotAttack then
		local canAttack = UnitCanAttack('player', frame.unit)
		if (trigger.playerCanAttack and canAttack) or (trigger.playerCanNotAttack and not canAttack) then passed = true else return end
	end

	-- Classification
	if trigger.classification.worldboss or trigger.classification.rareelite or trigger.classification.elite or trigger.classification.rare or trigger.classification.normal or trigger.classification.trivial or trigger.classification.minus then
		if trigger.classification[frame.classification] then passed = true else return end
	end

	-- Group Role
	if trigger.role.tank or trigger.role.healer or trigger.role.damager then
		if trigger.role[mod.TriggerConditions.roles[E.myrole]] then passed = true else return end
	end

	-- Unit Type
	if trigger.nameplateType and trigger.nameplateType.enable then
		if trigger.nameplateType[mod.TriggerConditions.frameTypes[frame.frameType]] then passed = true else return end
	end

	-- Creature Type
	if trigger.creatureType and trigger.creatureType.enable then
		if trigger.creatureType[E.CreatureTypes[frame.creatureType]] then passed = true else return end
	end

	-- Key Modifier
	if trigger.keyMod and trigger.keyMod.enable then
		for key, value in pairs(trigger.keyMod) do
			local isDown = mod.TriggerConditions.keys[key]
			if value and isDown then
				if isDown() then passed = true else return end
			end
		end
	end

	-- Reaction (or Reputation) Type
	if trigger.reactionType and trigger.reactionType.enable then
		if trigger.reactionType[mod.TriggerConditions.reactions[(trigger.reactionType.reputation and frame.repReaction) or frame.reaction]] then passed = true else return end
	end

	-- Threat
	if trigger.threat and trigger.threat.enable then
		if trigger.threat.good or trigger.threat.goodTransition or trigger.threat.badTransition or trigger.threat.bad or trigger.threat.offTank or trigger.threat.offTankGoodTransition or trigger.threat.offTankBadTransition then
			local isTank, offTank, threat = mod:StyleFilterThreatUpdate(frame, frame.unit)
			local checkOffTank = trigger.threat.offTank or trigger.threat.offTankGoodTransition or trigger.threat.offTankBadTransition
			local status = (checkOffTank and offTank and threat and -threat) or (not checkOffTank and ((isTank and mod.TriggerConditions.tankThreat[threat]) or threat)) or nil
			if trigger.threat[mod.TriggerConditions.threat[status]] then passed = true else return end
		end
	end

	-- Raid Target
	if trigger.raidTarget.star or trigger.raidTarget.circle or trigger.raidTarget.diamond or trigger.raidTarget.triangle or trigger.raidTarget.moon or trigger.raidTarget.square or trigger.raidTarget.cross or trigger.raidTarget.skull then
		if trigger.raidTarget[mod.TriggerConditions.raidTargets[frame.RaidTargetIndex]] then passed = true else return end
	end

	-- Class and Specialization
	if trigger.class and next(trigger.class) then
		local Class = trigger.class[E.myclass]
		if not Class or (Class.specs and next(Class.specs) and not Class.specs[E.myspec and GetSpecializationInfo(E.myspec)]) then
			return
		else
			passed = true
		end
	end

	do
		local activeID = trigger.location.instanceIDEnabled
		local activeType = trigger.instanceType.none or trigger.instanceType.scenario or trigger.instanceType.party or trigger.instanceType.raid or trigger.instanceType.arena or trigger.instanceType.pvp
		local instanceName, instanceType, difficultyID, instanceID, _

		-- Instance Type
		if activeType or activeID then
			instanceName, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
		end

		if activeType then
			if trigger.instanceType[instanceType] then
				passed = true

				-- Instance Difficulty
				if instanceType == 'raid' or instanceType == 'party' then
					local D = trigger.instanceDifficulty[(instanceType == 'party' and 'dungeon') or instanceType]
					for _, value in pairs(D) do
						if value and not D[mod.TriggerConditions.difficulties[difficultyID]] then return end
					end
				end
			else return end
		end

		-- Location
		if activeID or trigger.location.mapIDEnabled or trigger.location.zoneNamesEnabled or trigger.location.subZoneNamesEnabled then
			if activeID and next(trigger.location.instanceIDs) then
				if (instanceID and trigger.location.instanceIDs[tostring(instanceID)]) or trigger.location.instanceIDs[instanceName] then passed = true else return end
			end
			if trigger.location.mapIDEnabled and next(trigger.location.mapIDs) then
				if (E.MapInfo.mapID and trigger.location.mapIDs[tostring(E.MapInfo.mapID)]) or trigger.location.mapIDs[E.MapInfo.name] then passed = true else return end
			end
			if trigger.location.zoneNamesEnabled and next(trigger.location.zoneNames) then
				if trigger.location.zoneNames[E.MapInfo.realZoneText] then passed = true else return end
			end
			if trigger.location.subZoneNamesEnabled and next(trigger.location.subZoneNames) then
				if trigger.location.subZoneNames[E.MapInfo.subZoneText] then passed = true else return end
			end
		end
	end

	-- Talents
	if trigger.talent.enabled then
		local pvpTalent = trigger.talent.type == 'pvp'
		local selected, complete

		for i = 1, (pvpTalent and 4) or 7 do
			local Tier = 'tier'..i
			local Talent = trigger.talent[Tier]
			if trigger.talent[Tier..'enabled'] and Talent.column > 0 then
				if pvpTalent then
					-- column is actually the talentID for pvpTalents
					local slotInfo = C_SpecializationInfo_GetPvpTalentSlotInfo(i)
					selected = (slotInfo and slotInfo.selectedTalentID) == Talent.column
				else
					selected = select(4, GetTalentInfo(i, Talent.column, 1))
				end

				if (selected and not Talent.missing) or (Talent.missing and not selected) then
					complete = true
					if not trigger.talent.requireAll then
						break -- break when not using requireAll because we matched one
					end
				elseif trigger.talent.requireAll then
					complete = false -- fail because requireAll
					break
		end end end

		if complete then passed = true else return end
	end

	-- Casting
	if trigger.casting then
		local b, c = frame.Castbar, trigger.casting

		-- Spell
		if c.spells and next(c.spells) then
			for _, value in pairs(c.spells) do
				if value then -- only run if at least one is selected
					local castingSpell = (b.spellID and c.spells[tostring(b.spellID)]) or c.spells[b.spellName]
					if (c.notSpell and not castingSpell) or (castingSpell and not c.notSpell) then passed = true else return end
					break -- we can execute this once on the first enabled option then kill the loop
				end
			end
		end

		-- Status
		if c.isCasting or c.isChanneling or c.notCasting or c.notChanneling then
			if (c.isCasting and b.casting) or (c.isChanneling and b.channeling)
			or (c.notCasting and not b.casting) or (c.notChanneling and not b.channeling) then passed = true else return end
		end

		-- Interruptible
		if c.interruptible or c.notInterruptible then
			if (b.casting or b.channeling) and ((c.interruptible and not b.notInterruptible)
			or (c.notInterruptible and b.notInterruptible)) then passed = true else return end
		end
	end

	-- Cooldown
	if trigger.cooldowns and trigger.cooldowns.names and next(trigger.cooldowns.names) then
		local cooldown = mod:StyleFilterCooldownCheck(trigger.cooldowns.names, trigger.cooldowns.mustHaveAll)
		if cooldown ~= nil then -- ignore if none are set to ONCD or OFFCD
			if cooldown then passed = true else return end
		end
	end

	-- Buffs
	if frame.Buffs and trigger.buffs and trigger.buffs.names and next(trigger.buffs.names) then
		local buff = mod:StyleFilterAuraCheck(frame, trigger.buffs.names, frame.Buffs, trigger.buffs.mustHaveAll, trigger.buffs.missing, trigger.buffs.minTimeLeft, trigger.buffs.maxTimeLeft)
		if buff ~= nil then -- ignore if none are selected
			if buff then passed = true else return end
		end
	end

	-- Debuffs
	if frame.Debuffs and trigger.debuffs and trigger.debuffs.names and next(trigger.debuffs.names) then
		local debuff = mod:StyleFilterAuraCheck(frame, trigger.debuffs.names, frame.Debuffs, trigger.debuffs.mustHaveAll, trigger.debuffs.missing, trigger.debuffs.minTimeLeft, trigger.debuffs.maxTimeLeft)
		if debuff ~= nil then -- ignore if none are selected
			if debuff then passed = true else return end
		end
	end

	-- Name or GUID
	if trigger.names and next(trigger.names) then
		for _, value in pairs(trigger.names) do
			if value then -- only run if at least one is selected
				local name = trigger.names[frame.unitName] or trigger.names[frame.npcID]
				if (not trigger.negativeMatch and name) or (trigger.negativeMatch and not name) then passed = true else return end
				break -- we can execute this once on the first enabled option then kill the loop
			end
		end
	end

	-- Plugin Callback
	if mod.StyleFilterCustomChecks then
		for _, customCheck in pairs(mod.StyleFilterCustomChecks) do
			local custom = customCheck(frame, filter, trigger)
			if custom ~= nil then -- ignore if nil return
				if custom then passed = true else return end
			end
		end
	end

	-- Pass it along
	if passed then
		mod:StyleFilterPass(frame, filter.actions)
	end
end

function mod:StyleFilterPass(frame, actions)
	local db = mod:PlateDB(frame)
	local healthBarEnabled = (frame.frameType and db.health.enable) or (mod.db.displayStyle ~= 'ALL') or (frame.isTarget and mod.db.alwaysShowTargetHealth)
	local powerBarEnabled = frame.frameType and db.power and db.power.enable
	local healthBarShown = healthBarEnabled and frame.Health:IsShown()

	mod:StyleFilterSetChanges(frame, actions,
		(healthBarShown and actions.color and actions.color.health), --HealthColor
		(healthBarShown and powerBarEnabled and actions.color and actions.color.power), --PowerColor
		(healthBarShown and actions.color and actions.color.border and frame.Health.backdrop), --Borders
		(healthBarShown and actions.flash and actions.flash.enable and frame.HealthFlashTexture), --HealthFlash
		(healthBarShown and actions.texture and actions.texture.enable), --HealthTexture
		(healthBarShown and actions.scale and actions.scale ~= 1), --Scale
		(actions.alpha and actions.alpha ~= -1), --Alpha
		(actions.tags and actions.tags.name and actions.tags.name ~= ''), --NameTag
		(actions.tags and actions.tags.power and actions.tags.power ~= ''), --PowerTag
		(actions.tags and actions.tags.health and actions.tags.health ~= ''), --HealthTag
		(actions.tags and actions.tags.title and actions.tags.title ~= ''), --TitleTag
		(actions.tags and actions.tags.level and actions.tags.level ~= ''), --LevelTag
		(actions.usePortrait), --Portrait
		(actions.nameOnly), --NameOnly
		(actions.hide) --Visibility
	)
end

function mod:StyleFilterClear(frame, updateBase)
	local c = frame.StyleFilterChanges
	if c and next(c) then
		local shouldUpdate = c.NameOnly or c.Visibility
		mod:StyleFilterClearChanges(frame, updateBase, c.HealthColor, c.PowerColor, c.Borders, c.HealthFlash, c.HealthTexture, c.Scale, c.Alpha, c.NameTag, c.PowerTag, c.HealthTag, c.TitleTag, c.LevelTag, c.Portrait, c.NameOnly, c.Visibility)
		return shouldUpdate
	end
end

function mod:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] -- Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

function mod:StyleFilterVehicleFunction(_, unit)
	unit = unit or self.unit
	self.inVehicle = UnitInVehicle(unit) or nil
end

mod.StyleFilterEventFunctions = { -- a prefunction to the injected ouf watch
	PLAYER_TARGET_CHANGED = function(self)
		self.isTarget = self.unit and UnitIsUnit(self.unit, 'target') or nil
	end,
	PLAYER_FOCUS_CHANGED = function(self)
		self.isFocused = self.unit and UnitIsUnit(self.unit, 'focus') or nil
	end,
	RAID_TARGET_UPDATE = function(self)
		self.RaidTargetIndex = self.unit and GetRaidTargetIndex(self.unit) or nil
	end,
	UNIT_TARGET = function(self, _, unit)
		unit = unit or self.unit
		self.isTargetingMe = UnitIsUnit(unit..'target', 'player') or nil
	end,
	UNIT_ENTERED_VEHICLE = mod.StyleFilterVehicleFunction,
	UNIT_EXITED_VEHICLE = mod.StyleFilterVehicleFunction,
	VEHICLE_UPDATE = mod.StyleFilterVehicleFunction
}

function mod:StyleFilterSetVariables(nameplate)
	for _, func in pairs(mod.StyleFilterEventFunctions) do
		func(nameplate)
	end
end

function mod:StyleFilterClearVariables(nameplate)
	nameplate.isTarget = nil
	nameplate.isFocused = nil
	nameplate.inVehicle = nil
	nameplate.isTargetingMe = nil
	nameplate.RaidTargetIndex = nil
	nameplate.ThreatScale = nil
end

mod.StyleFilterTriggerList = {} -- configured filters enabled with sorted priority
mod.StyleFilterTriggerEvents = {} -- events required by the filter that we need to watch for
mod.StyleFilterPlateEvents = { -- events watched inside of ouf, which is called on the nameplate itself
	NAME_PLATE_UNIT_ADDED = 1 -- rest is populated from StyleFilterDefaultEvents as needed
}
mod.StyleFilterDefaultEvents = { -- list of events style filter uses to populate plate events
	-- this is a list of events already on the nameplate
	'UNIT_AURA',
	'UNIT_DISPLAYPOWER',
	'UNIT_FACTION',
	'UNIT_HEALTH',
	'UNIT_HEALTH_FREQUENT',
	'UNIT_MAXHEALTH',
	'UNIT_NAME_UPDATE',
	'UNIT_PET',
	'UNIT_POWER_FREQUENT',
	'UNIT_POWER_UPDATE',
	-- list of events added during StyleFilterEvents
	'MODIFIER_STATE_CHANGED',
	'PLAYER_FOCUS_CHANGED',
	'PLAYER_REGEN_DISABLED',
	'PLAYER_REGEN_ENABLED',
	'PLAYER_TARGET_CHANGED',
	'PLAYER_UPDATE_RESTING',
	'RAID_TARGET_UPDATE',
	'SPELL_UPDATE_COOLDOWN',
	'UNIT_ENTERED_VEHICLE',
	'UNIT_EXITED_VEHICLE',
	'UNIT_FLAGS',
	'UNIT_TARGET',
	'UNIT_THREAT_LIST_UPDATE',
	'UNIT_THREAT_SITUATION_UPDATE',
	'VEHICLE_UPDATE'
}

function mod:StyleFilterWatchEvents()
	for _, event in ipairs(mod.StyleFilterDefaultEvents) do
		mod.StyleFilterPlateEvents[event] = mod.StyleFilterTriggerEvents[event] and true or nil
	end
end

function mod:StyleFilterConfigure()
	local events = mod.StyleFilterTriggerEvents
	local list = mod.StyleFilterTriggerList
	wipe(events)
	wipe(list)

	for filterName, filter in pairs(E.global.nameplate.filters) do
		local t = filter.triggers
		if t and E.db.nameplates and E.db.nameplates.filters then
			if E.db.nameplates.filters[filterName] and E.db.nameplates.filters[filterName].triggers and E.db.nameplates.filters[filterName].triggers.enable then
				tinsert(list, {filterName, t.priority or 1})

				-- NOTE: 0 for fake events
				events.FAKE_AuraWaitTimer = 0 -- for minTimeLeft and maxTimeLeft aura trigger
				events.NAME_PLATE_UNIT_ADDED = 1
				events.PLAYER_TARGET_CHANGED = 1

				if t.casting then
					if next(t.casting.spells) then
						for _, value in pairs(t.casting.spells) do
							if value then
								events.FAKE_Casting = 0
								break
					end end end

					if (t.casting.interruptible or t.casting.notInterruptible)
					or (t.casting.isCasting or t.casting.isChanneling or t.casting.notCasting or t.casting.notChanneling) then
						events.FAKE_Casting = 0
					end
				end

				if t.isTapDenied or t.isNotTapDenied then			events.UNIT_FLAGS = 1 end
				if t.reactionType and t.reactionType.enable then	events.UNIT_FACTION = 1 end
				if t.keyMod and t.keyMod.enable then				events.MODIFIER_STATE_CHANGED = 1 end
				if t.targetMe or t.notTargetMe then					events.UNIT_TARGET = 1 end
				if t.isFocus or t.notFocus then						events.PLAYER_FOCUS_CHANGED = 1 end
				if t.isResting then									events.PLAYER_UPDATE_RESTING = 1 end
				if t.isPet then										events.UNIT_PET = 1 end

				if t.raidTarget and (t.raidTarget.star or t.raidTarget.circle or t.raidTarget.diamond or t.raidTarget.triangle or t.raidTarget.moon or t.raidTarget.square or t.raidTarget.cross or t.raidTarget.skull) then
					events.RAID_TARGET_UPDATE = 1
				end

				if t.unitInVehicle then
					events.UNIT_ENTERED_VEHICLE = 1
					events.UNIT_EXITED_VEHICLE = 1
					events.VEHICLE_UPDATE = 1
				end

				if t.healthThreshold then
					events.UNIT_HEALTH = 1
					events.UNIT_MAXHEALTH = 1
					events.UNIT_HEALTH_FREQUENT = 1
				end

				if t.powerThreshold then
					events.UNIT_POWER_UPDATE = 1
					events.UNIT_POWER_FREQUENT = 1
					events.UNIT_DISPLAYPOWER = 1
				end

				if t.threat and t.threat.enable then
					events.UNIT_THREAT_SITUATION_UPDATE = 1
					events.UNIT_THREAT_LIST_UPDATE = 1
				end

				if t.inCombat or t.outOfCombat or t.inCombatUnit or t.outOfCombatUnit then
					events.PLAYER_REGEN_DISABLED = 1
					events.PLAYER_REGEN_ENABLED = 1
					events.UNIT_THREAT_LIST_UPDATE = 1
					events.UNIT_FLAGS = 1
				end

				if t.location then
					if (t.location.mapIDEnabled and next(t.location.mapIDs))
					or (t.location.instanceIDEnabled and next(t.location.instanceIDs))
					or (t.location.zoneNamesEnabled and next(t.location.zoneNames))
					or (t.location.subZoneNamesEnabled and next(t.location.subZoneNames)) then
						events.LOADING_SCREEN_DISABLED = 1
						events.ZONE_CHANGED_NEW_AREA = 1
						events.ZONE_CHANGED_INDOORS = 1
						events.ZONE_CHANGED = 1
					end
				end

				if t.names and next(t.names) then
					for _, value in pairs(t.names) do
						if value then
							events.UNIT_NAME_UPDATE = 1
							break
				end end end

				if t.cooldowns and t.cooldowns.names and next(t.cooldowns.names) then
					for _, value in pairs(t.cooldowns.names) do
						if value == 'ONCD' or value == 'OFFCD' then
							events.SPELL_UPDATE_COOLDOWN = 1
							break
				end end end

				if t.buffs and t.buffs.names and next(t.buffs.names) then
					for _, value in pairs(t.buffs.names) do
						if value then
							events.UNIT_AURA = 1
							break
				end end end

				if t.debuffs and t.debuffs.names and next(t.debuffs.names) then
					for _, value in pairs(t.debuffs.names) do
						if value then
							events.UNIT_AURA = 1
							break
				end end end
	end end end

	mod:StyleFilterWatchEvents()

	if next(list) then
		sort(list, mod.StyleFilterSort) -- sort by priority
	end
end

function mod:StyleFilterUpdate(frame, event)
	if not frame.StyleFilterChanges or not mod.StyleFilterTriggerEvents[event] then return end

	mod:StyleFilterClear(frame, true)

	for filterNum in ipairs(mod.StyleFilterTriggerList) do
		local filter = E.global.nameplate.filters[mod.StyleFilterTriggerList[filterNum][1]]
		if filter then
			mod:StyleFilterConditionCheck(frame, filter, filter.triggers)
		end
	end
end

do -- oUF style filter inject watch functions without actually registering any events
	local update = function(frame, event, ...)
		local eventFunc = mod.StyleFilterEventFunctions[event]
		if eventFunc then eventFunc(frame, event, ...) end

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
				end end

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
				end end
			end
	end end

	function mod:StyleFilterEventWatch(frame)
		for _, event in ipairs(mod.StyleFilterDefaultEvents) do
			local holdsEvent = styleFilterIsWatching(frame, event)
			if mod.StyleFilterPlateEvents[event] then
				if not holdsEvent then
					oUF_fake_register(frame, event)
				end
			elseif holdsEvent then
				oUF_fake_register(frame, event, true)
	end end end

	function mod:StyleFilterRegister(nameplate, event, unitless, func, objectEvent)
		if objectEvent then
			if not nameplate.objectEventFunc then
				nameplate.objectEventFunc = function(_, evnt, ...) update(nameplate, evnt, ...) end
			end
			if not E:HasFunctionForObject(event, objectEvent, nameplate.objectEventFunc) then
				E:RegisterEventForObject(event, objectEvent, nameplate.objectEventFunc)
			end
		elseif not nameplate:IsEventRegistered(event) then
			nameplate:RegisterEvent(event, func or E.noop, unitless)
		end
	end
end

-- events we actually register on plates when they aren't added
function mod:StyleFilterEvents(nameplate)
	-- these events get added onto StyleFilterDefaultEvents to be watched,
	-- the ones added from here should not by registered already
	mod:StyleFilterRegister(nameplate,'MODIFIER_STATE_CHANGED', true)
	mod:StyleFilterRegister(nameplate,'PLAYER_FOCUS_CHANGED', true)
	mod:StyleFilterRegister(nameplate,'PLAYER_REGEN_DISABLED', true)
	mod:StyleFilterRegister(nameplate,'PLAYER_REGEN_ENABLED', true)
	mod:StyleFilterRegister(nameplate,'PLAYER_TARGET_CHANGED', true)
	mod:StyleFilterRegister(nameplate,'PLAYER_UPDATE_RESTING', true)
	mod:StyleFilterRegister(nameplate,'RAID_TARGET_UPDATE', true)
	mod:StyleFilterRegister(nameplate,'SPELL_UPDATE_COOLDOWN', true)
	mod:StyleFilterRegister(nameplate,'UNIT_ENTERED_VEHICLE')
	mod:StyleFilterRegister(nameplate,'UNIT_EXITED_VEHICLE')
	mod:StyleFilterRegister(nameplate,'UNIT_FLAGS')
	mod:StyleFilterRegister(nameplate,'UNIT_TARGET')
	mod:StyleFilterRegister(nameplate,'UNIT_THREAT_LIST_UPDATE')
	mod:StyleFilterRegister(nameplate,'UNIT_THREAT_SITUATION_UPDATE')
	mod:StyleFilterRegister(nameplate,'VEHICLE_UPDATE', true)

	-- object event pathing (these update after MapInfo updates),
	-- these event are not added onto the nameplate itself
	mod:StyleFilterRegister(nameplate,'LOADING_SCREEN_DISABLED', nil, nil, E.MapInfo)
	mod:StyleFilterRegister(nameplate,'ZONE_CHANGED_NEW_AREA', nil, nil, E.MapInfo)
	mod:StyleFilterRegister(nameplate,'ZONE_CHANGED_INDOORS', nil, nil, E.MapInfo)
	mod:StyleFilterRegister(nameplate,'ZONE_CHANGED', nil, nil, E.MapInfo)

	-- fire up the ouf injection watcher
	mod:StyleFilterEventWatch(nameplate)
end

function mod:StyleFilterAddCustomCheck(name, func)
	if not mod.StyleFilterCustomChecks then
		mod.StyleFilterCustomChecks = {}
	end

	mod.StyleFilterCustomChecks[name] = func
end

function mod:StyleFilterRemoveCustomCheck(name)
	if not mod.StyleFilterCustomChecks then
		return
	end

	mod.StyleFilterCustomChecks[name] = nil
end

function mod:PLAYER_LOGOUT()
	mod:StyleFilterClearDefaults(E.global.nameplate.filters)
end

function mod:StyleFilterClearDefaults(tbl)
	for filterName, filterTable in pairs(tbl) do
		if G.nameplate.filters[filterName] then
			local defaultTable = E:CopyTable({}, E.StyleFilterDefaults)
			E:CopyTable(defaultTable, G.nameplate.filters[filterName])
			E:RemoveDefaults(filterTable, defaultTable)
		else
			E:RemoveDefaults(filterTable, E.StyleFilterDefaults)
		end
	end
end

function mod:StyleFilterCopyDefaults(tbl)
	E:CopyDefaults(tbl, E.StyleFilterDefaults)
end

function mod:StyleFilterInitialize()
	for _, filterTable in pairs(E.global.nameplate.filters) do
		mod:StyleFilterCopyDefaults(filterTable)
	end
end
