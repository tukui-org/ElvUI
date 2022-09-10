local E, L, V, P, G = unpack(ElvUI)
local mod = E:GetModule('NamePlates')
local LSM = E.Libs.LSM
local ElvUF = E.oUF

local _G = _G
local ipairs, next, pairs, select = ipairs, next, pairs, select
local setmetatable, tostring, tonumber, type, unpack = setmetatable, tostring, tonumber, type, unpack
local strmatch, tinsert, tremove, sort, wipe = strmatch, tinsert, tremove, sort, wipe

local GetInstanceInfo = GetInstanceInfo
local GetInventoryItemID = GetInventoryItemID
local GetRaidTargetIndex = GetRaidTargetIndex
local GetSpecializationInfo = GetSpecializationInfo
local GetSpellCharges = GetSpellCharges
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetTalentInfo = GetTalentInfo
local GetTime = GetTime
local IsEquippedItem = IsEquippedItem
local IsResting = IsResting
local UnitAffectingCombat = UnitAffectingCombat
local UnitAura = UnitAura
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitInVehicle = UnitInVehicle
local UnitIsCharmed = UnitIsCharmed
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsInMyGuild = UnitIsInMyGuild
local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit
local UnitIsPossessed = UnitIsPossessed
local UnitIsPVP = UnitIsPVP
local UnitIsQuestBoss = UnitIsQuestBoss
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsTrivial = UnitIsTrivial
local UnitIsUnconscious = UnitIsUnconscious
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitPlayerControlled = UnitPlayerControlled
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitThreatSituation = UnitThreatSituation

local C_Timer_NewTimer = C_Timer.NewTimer
local C_PetBattles_IsInBattle = C_PetBattles and C_PetBattles.IsInBattle
local C_SpecializationInfo_GetPvpTalentSlotInfo = C_SpecializationInfo and C_SpecializationInfo.GetPvpTalentSlotInfo

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
		-- classic / tbc
		[9] = 'legacy40normal',
		[148] = 'legacy20normal',
		[173] = 'normal',
		[174] = 'heroic',
		-- wotlk (pretty sure)
		--[175] = 'legacy10heroic',
		--[176] = 'legacy25heroic',
	}
}

do -- E.CreatureTypes; Do *not* change the value, only the key (['key'] = 'value').
	local c, locale = {}, E.locale
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

function mod:StyleFilterTickerCallback(frame, ticker, timer)
	if frame and frame:IsShown() then
		mod:StyleFilterUpdate(frame, 'FAKE_AuraWaitTimer')
	end

	if ticker[timer] then
		ticker[timer]:Cancel()
		ticker[timer] = nil
	end
end

function mod:StyleFilterTickerCreate(delay, frame, ticker, timer)
	return C_Timer_NewTimer(delay, function() mod:StyleFilterTickerCallback(frame, ticker, timer) end)
end

function mod:StyleFilterAuraWait(frame, ticker, timer, timeLeft, mTimeLeft)
	if not ticker[timer] then
		local updateIn = timeLeft-mTimeLeft
		if updateIn > 0 then -- also add a tenth of a second to updateIn to prevent the timer from firing on the same second
			ticker[timer] = mod:StyleFilterTickerCreate(updateIn+0.1, frame, ticker, timer)
		end
	end
end

function mod:StyleFilterDispelCheck(frame, filter)
	local index = 1
	local name, _, _, debuffType, _, _, _, isStealable = UnitAura(frame.unit, index, filter)
	while name do
		if filter == 'HELPFUL' then
			if isStealable then
				return true
			end
		elseif debuffType and E:IsDispellableByMe(debuffType) then
			return true
		end

		index = index + 1
		name, _, _, debuffType, _, _, _, isStealable = UnitAura(frame.unit, index, filter)
	end
end

function mod:StyleFilterAuraCheck(frame, names, tickers, filter, mustHaveAll, missing, minTimeLeft, maxTimeLeft, fromMe, fromPet)
	local total, matches, now = 0, 0, GetTime()
	for key, value in pairs(names) do
		if value then -- only if they are turned on
			total = total + 1 -- keep track of the names

			local index = 1
			local name, _, count, _, _, expiration, source, _, _, spellID, _, _, _, _, modRate = UnitAura(frame.unit, index, filter)
			while name do
				local spell, stacks, failed = strmatch(key, mod.StyleFilterStackPattern)
				if stacks ~= '' then failed = not (count and count >= tonumber(stacks)) end
				if not failed and ((name and name == spell) or (spellID and spellID == tonumber(spell))) then
					local isMe, isPet = source == 'player' or source == 'vehicle', source == 'pet'
					if fromMe and fromPet and (isMe or isPet) or (fromMe and isMe) or (fromPet and isPet) or (not fromMe and not fromPet) then
						local hasMinTime = minTimeLeft and minTimeLeft ~= 0
						local hasMaxTime = maxTimeLeft and maxTimeLeft ~= 0
						local timeLeft = (hasMinTime or hasMaxTime) and expiration and ((expiration - now) / (modRate or 1))
						local minTimeAllow = not hasMinTime or (timeLeft and timeLeft > minTimeLeft)
						local maxTimeAllow = not hasMaxTime or (timeLeft and timeLeft < maxTimeLeft)

						if minTimeAllow and maxTimeAllow then
							matches = matches + 1 -- keep track of how many matches we have
						end

						if timeLeft then -- if we use a min/max time setting; we must create a delay timer
							if not tickers[matches] then tickers[matches] = {} end
							if hasMinTime then mod:StyleFilterAuraWait(frame, tickers[matches], 'hasMinTimer', timeLeft, minTimeLeft) end
							if hasMaxTime then mod:StyleFilterAuraWait(frame, tickers[matches], 'hasMaxTimer', timeLeft, maxTimeLeft) end
						end
					end
				end

				index = index + 1
				name, _, count, _, _, expiration, source, _, _, spellID, _, _, _, _, modRate = UnitAura(frame.unit, index, filter)
			end

			local stale = matches + 1
			local ticker = tickers[stale]
			while ticker and (ticker.hasMinTimer or ticker.hasMaxTimer) do -- cancel stale timers
				if ticker.hasMinTimer then ticker.hasMinTimer:Cancel() ticker.hasMinTimer = nil end
				if ticker.hasMaxTimer then ticker.hasMaxTimer:Cancel() ticker.hasMaxTimer = nil end

				stale = stale + 1
				ticker = tickers[stale]
			end
		end
	end

	if total == 0 then
		return nil -- If no auras are checked just pass nil, we dont need to run the filter here.
	else
		return ((mustHaveAll and not missing) and total == matches)	-- [x] Check for all [ ] Missing: total needs to match count
		or ((not mustHaveAll and not missing) and matches > 0)		-- [ ] Check for all [ ] Missing: count needs to be greater than zero
		or ((not mustHaveAll and missing) and matches == 0)			-- [ ] Check for all [x] Missing: count needs to be zero
		or ((mustHaveAll and missing) and total ~= matches)			-- [x] Check for all [x] Missing: count must not match total
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

function mod:StyleFilterBaseUpdate(frame, state)
	if not frame.StyleFilterBaseAlreadyUpdated then -- skip updates from UpdatePlateBase
		mod:UpdatePlate(frame, true) -- enable elements back
	end

	local db = mod:PlateDB(frame) -- keep this after UpdatePlate
	if not db.nameOnly then
		if db.power.enable then frame.Power:ForceUpdate() end
		if db.health.enable then frame.Health:ForceUpdate() end
		if db.castbar.enable then frame.Castbar:ForceUpdate() end

		if mod.db.threat.enable and mod.db.threat.useThreatColor and not UnitIsTapDenied(frame.unit) then
			frame.ThreatIndicator:ForceUpdate() -- this will account for the threat health color
		end

		if frame.isTarget and frame.frameType ~= 'PLAYER' and mod.db.units.TARGET.glowStyle ~= 'none' then
			frame.TargetIndicator:ForceUpdate() -- so the target indicator will show up
		end
	end

	if frame.isTarget then
		mod:SetupTarget(frame, db.nameOnly) -- so the classbar will show up
	end

	if state and not mod.SkipFading then
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, 0, 1) -- fade those back in so it looks clean
	end
end

function mod:StyleFilterBorderLock(backdrop, r, g, b, a)
	if r then
		backdrop.forcedBorderColors = {r,g,b,a}
		backdrop:SetBackdropBorderColor(r,g,b,a)
	else
		backdrop.forcedBorderColors = nil
		backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end
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

	if Visibility or NameOnly then
		c.NameOnly, c.Visibility = NameOnly, Visibility

		mod:DisablePlate(frame, NameOnly, NameOnly)

		if Visibility then
			frame:ClearAllPoints() -- lets still move the frame out cause its clickable otherwise
			frame:Point('TOP', E.UIParent, 'BOTTOM', 0, -500)
			return -- We hide it. Lets not do other things (no point)
		end
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

	-- generic stuff
	if Scale then
		c.Scale = true
		mod:ScalePlate(frame, actions.scale)
	end
	if Alpha then
		c.Alpha = true
		mod:PlateFade(frame, mod.db.fadeIn and 1 or 0, frame:GetAlpha(), actions.alpha * 0.01)
	end
	if Portrait then
		c.Portrait = true
		mod:Update_Portrait(frame)
		frame.Portrait:ForceUpdate()
	end

	if NameOnly then
		return -- skip the other stuff now
	end

	-- bar stuff
	if HealthColor then
		local hc = (actions.color.healthClass and frame.classColor) or actions.color.healthColor
		c.HealthColor = hc -- used by Health_UpdateColor

		frame.Health:SetStatusBarColor(hc.r, hc.g, hc.b, hc.a or 1)
		frame.Cutaway.Health:SetVertexColor(hc.r * 1.5, hc.g * 1.5, hc.b * 1.5, hc.a or 1)
	end
	if PowerColor then
		local pc = (actions.color.powerClass and frame.classColor) or actions.color.powerColor
		c.PowerColor = true

		frame.Power:SetStatusBarColor(pc.r, pc.g, pc.b, pc.a or 1)
		frame.Cutaway.Power:SetVertexColor(pc.r * 1.5, pc.g * 1.5, pc.b * 1.5, pc.a or 1)
	end
	if Borders then
		local bc = (actions.color.borderClass and frame.classColor) or actions.color.borderColor
		c.Borders = true

		mod:StyleFilterBorderLock(frame.Health.backdrop, bc.r, bc.g, bc.b, bc.a or 1)

		if frame.Power.backdrop and db.power.enable then
			mod:StyleFilterBorderLock(frame.Power.backdrop, bc.r, bc.g, bc.b, bc.a or 1)
		end
	end
	if HealthFlash then
		local fc = (actions.flash.class and frame.classColor) or actions.flash.color
		c.HealthFlash = true

		if not HealthTexture then
			frame.HealthFlashTexture:SetTexture(LSM:Fetch('statusbar', mod.db.statusbar))
		end

		frame.HealthFlashTexture:SetVertexColor(fc.r, fc.g, fc.b)

		local anim = frame.HealthFlashTexture.anim or mod:StyleFilterSetupFlash(frame.HealthFlashTexture)
		anim.fadein:SetToAlpha(fc.a or 1)
		anim.fadeout:SetFromAlpha(fc.a or 1)

		frame.HealthFlashTexture:Show()
		E:Flash(frame.HealthFlashTexture, actions.flash.speed * 0.1, true)
	end
	if HealthTexture then
		local tx = LSM:Fetch('statusbar', actions.texture.texture)
		c.HealthTexture = true

		frame.Health:SetStatusBarTexture(tx)

		if HealthFlash then
			frame.HealthFlashTexture:SetTexture(tx)
		end
	end
end

function mod:StyleFilterClearVisibility(frame, previous)
	local state = mod:StyleFilterHiddenState(frame.StyleFilterChanges)

	if (previous == 1 or previous == 3) and (state ~= 1 and state ~= 3) then
		frame:ClearAllPoints() -- pull the frame back in
		frame:Point('CENTER')
	end

	if previous and not state then
		mod:StyleFilterBaseUpdate(frame, state == 1)
	end
end

function mod:StyleFilterClearChanges(frame, HealthColor, PowerColor, Borders, HealthFlash, HealthTexture, Scale, Alpha, NameTag, PowerTag, HealthTag, TitleTag, LevelTag, Portrait, NameOnly, Visibility)
	local db = mod:PlateDB(frame)

	local c = frame.StyleFilterChanges
	if c then wipe(c) end

	if not NameOnly then -- Only update these if it wasn't NameOnly. Otherwise, it leads to `Update_Tags` which does the job.
		if NameTag then frame:Tag(frame.Name, db.name.format) frame.Name:UpdateTag() end
		if PowerTag then frame:Tag(frame.Power.Text, db.power.text.format) frame.Power.Text:UpdateTag() end
		if HealthTag then frame:Tag(frame.Health.Text, db.health.text.format) frame.Health.Text:UpdateTag() end
		if TitleTag then frame:Tag(frame.Title, db.title.format) frame.Title:UpdateTag() end
		if LevelTag then frame:Tag(frame.Level, db.level.format) frame.Level:UpdateTag() end
	end

	-- generic stuff
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

	-- bar stuff
	if HealthColor then
		local h = frame.Health
		if h.r and h.g and h.b then
			h:SetStatusBarColor(h.r, h.g, h.b)
			frame.Cutaway.Health:SetVertexColor(h.r * 1.5, h.g * 1.5, h.b * 1.5, 1)
		end
	end
	if PowerColor then
		local pc = mod.db.colors.power[frame.Power.token] or _G.PowerBarColor[frame.Power.token] or FallbackColor
		frame.Power:SetStatusBarColor(pc.r, pc.g, pc.b)
		frame.Cutaway.Power:SetVertexColor(pc.r * 1.5, pc.g * 1.5, pc.b * 1.5, 1)
	end
	if Borders then
		mod:StyleFilterBorderLock(frame.Health.backdrop)

		if frame.Power.backdrop and db.power.enable then
			mod:StyleFilterBorderLock(frame.Power.backdrop)
		end
	end
	if HealthFlash then
		E:StopFlash(frame.HealthFlashTexture)
		frame.HealthFlashTexture:Hide()
	end
	if HealthTexture then
		local tx = LSM:Fetch('statusbar', mod.db.statusbar)
		frame.Health:SetStatusBarTexture(tx)
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

	-- Class and Specialization
	if trigger.class and next(trigger.class) then
		local Class = trigger.class[E.myclass]
		if not Class or (Class.specs and next(Class.specs) and not Class.specs[E.myspec and GetSpecializationInfo(E.myspec)]) then
			return
		else
			passed = true
		end
	end

	-- Health
	if trigger.healthThreshold then
		local healthUnit = (trigger.healthUsePlayer and 'player') or frame.unit
		local health, maxHealth = UnitHealth(healthUnit), UnitHealthMax(healthUnit)
		local percHealth = (maxHealth and (maxHealth > 0) and health/maxHealth) or 0

		local underHealth = trigger.underHealthThreshold and (trigger.underHealthThreshold ~= 0)
		local overHealth = trigger.overHealthThreshold and (trigger.overHealthThreshold ~= 0)

		local underThreshold = underHealth and (trigger.underHealthThreshold > percHealth)
		local overThreshold = overHealth and (trigger.overHealthThreshold < percHealth)

		if underHealth and overHealth then
			if underThreshold and overThreshold then passed = true else return end
		elseif underThreshold or overThreshold then passed = true else return end
	end

	-- Power
	if trigger.powerThreshold then
		local powerUnit = (trigger.powerUsePlayer and 'player') or frame.unit
		local power, maxPower = UnitPower(powerUnit, frame.PowerType), UnitPowerMax(powerUnit, frame.PowerType)
		local percPower = (maxPower and (maxPower > 0) and power/maxPower) or 0

		local underPower = trigger.underPowerThreshold and (trigger.underPowerThreshold ~= 0)
		local overPower = trigger.overPowerThreshold and (trigger.overPowerThreshold ~= 0)

		local underThreshold = underPower and (trigger.underPowerThreshold > percPower)
		local overThreshold = overPower and (trigger.overPowerThreshold < percPower)

		if underPower and overPower then
			if underThreshold and overThreshold then passed = true else return end
		elseif underThreshold or overThreshold then passed = true else return end
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

	-- Quest Boss
	if E.Retail and trigger.questBoss then
		if UnitIsQuestBoss(frame.unit) then passed = true else return end
	end

	-- Resting State
	if trigger.isResting or trigger.notResting then
		local resting = IsResting()
		if (trigger.isResting and resting) or (trigger.notResting and not resting) then passed = true else return end
	end

	-- Target Existence
	if trigger.requireTarget or trigger.noTarget then
		local target = UnitExists('target')
		if (trigger.requireTarget and target) or (trigger.noTarget and not target) then passed = true else return end
	end

	-- Quest Unit
	if trigger.isQuest or trigger.notQuest then
		local quest = E.TagFunctions.GetQuestData(frame.unit)
		if (trigger.isQuest and quest) or (trigger.notQuest and not quest) then passed = true else return end
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
		if (trigger.isPet and frame.isPet) or (trigger.isNotPet and not frame.isPet) then passed = true else return end
	end

	-- In Pet Battle
	if E.Retail and (trigger.inPetBattle or trigger.notPetBattle) then
		local inBattle = C_PetBattles_IsInBattle()
		if (trigger.inPetBattle and inBattle) or (trigger.notPetBattle and not inBattle) then passed = true else return end
	end

	-- In Party
	if trigger.inParty or trigger.notInParty then
		local inParty = UnitInParty(frame.unit)
		if (trigger.inParty and inParty) or (trigger.notInParty and not inParty) then passed = true else return end
	end

	-- In Raid
	if trigger.inRaid or trigger.notInRaid then
		local inRaid = UnitInRaid(frame.unit)
		if (trigger.inRaid and inRaid) or (trigger.notInRaid and not inRaid) then passed = true else return end
	end

	-- My Guild
	if trigger.inMyGuild or trigger.notMyGuild then
		local myGuild = UnitIsInMyGuild(frame.unit)
		if (trigger.inMyGuild and myGuild) or (trigger.notMyGuild and not myGuild) then passed = true else return end
	end

	-- Other Players Pet
	if trigger.isOthersPet or trigger.notOthersPet then
		local othersPet = UnitIsOtherPlayersPet(frame.unit)
		if (trigger.isOthersPet and othersPet) or (trigger.notOthersPet and not othersPet) then passed = true else return end
	end

	-- Trivial (grey to player)
	if trigger.isTrivial or trigger.notTrivial then
		local trivial = UnitIsTrivial(frame.unit)
		if (trigger.isTrivial and trivial) or (trigger.notTrivial and not trivial) then passed = true else return end
	end

	-- Conscious State
	if trigger.isUnconscious or trigger.isConscious then
		local unconscious = UnitIsUnconscious(frame.unit)
		if (trigger.isUnconscious and unconscious) or (trigger.isConscious and not unconscious) then passed = true else return end
	end

	-- Possessed State
	if trigger.isPossessed or trigger.notPossessed then
		local possessed = UnitIsPossessed(frame.unit)
		if (trigger.isPossessed and possessed) or (trigger.notPossessed and not possessed) then passed = true else return end
	end

	-- Charmed State
	if trigger.isCharmed or trigger.notCharmed then
		local charmed = UnitIsCharmed(frame.unit)
		if (trigger.isCharmed and charmed) or (trigger.notCharmed and not charmed) then passed = true else return end
	end

	-- Dead or Ghost
	if trigger.isDeadOrGhost or trigger.notDeadOrGhost then
		local deadOrGhost = UnitIsDeadOrGhost(frame.unit)
		if (trigger.isDeadOrGhost and deadOrGhost) or (trigger.notDeadOrGhost and not deadOrGhost) then passed = true else return end
	end

	-- Being Resurrected
	if trigger.isBeingResurrected or trigger.notBeingResurrected then
		local beingResurrected = UnitHasIncomingResurrection(frame.unit)
		if (trigger.isBeingResurrected and beingResurrected) or (trigger.notBeingResurrected and not beingResurrected) then passed = true else return end
	end

	-- Unit Connected
	if trigger.isConnected or trigger.notConnected then
		local connected = UnitIsConnected(frame.unit)
		if (trigger.isConnected and connected) or (trigger.notConnected and not connected) then passed = true else return end
	end

	-- Unit Player Controlled
	if trigger.isPlayerControlled or trigger.isNotPlayerControlled then
		local playerControlled = UnitPlayerControlled(frame.unit) and not frame.isPlayer
		if (trigger.isPlayerControlled and playerControlled) or (trigger.isNotPlayerControlled and not playerControlled) then passed = true else return end
	end

	-- Unit Owned By Player
	if trigger.isOwnedByPlayer or trigger.isNotOwnedByPlayer then
		local ownedByPlayer = UnitIsOwnerOrControllerOfUnit('player', frame.unit)
		if (trigger.isOwnedByPlayer and ownedByPlayer) or (trigger.isNotOwnedByPlayer and not ownedByPlayer) then passed = true else return end
	end

	-- Unit PvP
	if trigger.isPvP or trigger.isNotPvP then
		local isPvP = UnitIsPVP(frame.unit)
		if (trigger.isPvP and isPvP) or (trigger.isNotPvP and not isPvP) then passed = true else return end
	end

	-- Unit Tap Denied
	if trigger.isTapDenied or trigger.isNotTapDenied then
		local tapDenied = UnitIsTapDenied(frame.unit)
		if (trigger.isTapDenied and tapDenied) or (trigger.isNotTapDenied and not tapDenied) then passed = true else return end
	end

	-- Player Vehicle
	if (E.Retail or E.Wrath) and (trigger.inVehicle or trigger.outOfVehicle) then
		local inVehicle = UnitInVehicle('player')
		if (trigger.inVehicle and inVehicle) or (trigger.outOfVehicle and not inVehicle) then passed = true else return end
	end

	-- Unit Vehicle
	if (E.Retail or E.Wrath) and (trigger.inVehicleUnit or trigger.outOfVehicleUnit) then
		if (trigger.inVehicleUnit and frame.inVehicle) or (trigger.outOfVehicleUnit and not frame.inVehicle) then passed = true else return end
	end

	-- Player Can Attack
	if trigger.playerCanAttack or trigger.playerCanNotAttack then
		local canAttack = UnitCanAttack('player', frame.unit)
		if (trigger.playerCanAttack and canAttack) or (trigger.playerCanNotAttack and not canAttack) then passed = true else return end
	end

	-- NPC Title
	if trigger.hasTitleNPC or trigger.noTitleNPC then
		local npcTitle = E.TagFunctions.GetTitleNPC(frame.unit)
		if (trigger.hasTitleNPC and npcTitle) or (trigger.noTitleNPC and not npcTitle) then passed = true else return end
	end

	-- Classification
	if trigger.classification.worldboss or trigger.classification.rareelite or trigger.classification.elite or trigger.classification.rare or trigger.classification.normal or trigger.classification.trivial or trigger.classification.minus then
		if trigger.classification[frame.classification] then passed = true else return end
	end

	-- Faction
	if trigger.faction.Alliance or trigger.faction.Horde or trigger.faction.Neutral then
		if trigger.faction[frame.battleFaction] then passed = true else return end
	end

	-- My Role
	if trigger.role.tank or trigger.role.healer or trigger.role.damager then
		if trigger.role[mod.TriggerConditions.roles[E.myrole]] then passed = true else return end
	end

	-- Unit Role
	if E.Retail and (trigger.unitRole.tank or trigger.unitRole.healer or trigger.unitRole.damager) then
		local role = UnitGroupRolesAssigned(frame.unit)
		if trigger.unitRole[mod.TriggerConditions.roles[role]] then passed = true else return end
	end

	-- Unit Type
	if trigger.nameplateType and trigger.nameplateType.enable then
		if trigger.nameplateType[mod.TriggerConditions.frameTypes[frame.frameType]] then passed = true else return end
	end

	-- Creature Type
	if trigger.creatureType and trigger.creatureType.enable then
		if trigger.creatureType[E.CreatureTypes[frame.creatureType]] then passed = true else return end
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

	-- Key Modifier
	if trigger.keyMod and trigger.keyMod.enable then
		for key, value in pairs(trigger.keyMod) do
			local isDown = mod.TriggerConditions.keys[key]
			if value and isDown then
				if isDown() then passed = true else return end
			end
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

	-- Slots
	if trigger.slots and next(trigger.slots) then
		for slot, value in pairs(trigger.slots) do
			if value then -- only run if at least one is selected
				if GetInventoryItemID('player', slot) then passed = true else return end
			end
		end
	end

	-- Items
	if trigger.items and next(trigger.items) then
		for item, value in pairs(trigger.items) do
			if value then -- only run if at least one is selected
				local hasItem = IsEquippedItem(item)
				if (not trigger.negativeMatch and hasItem) or (trigger.negativeMatch and not hasItem) then passed = true else return end
			end
		end
	end

	-- Talents
	if E.Retail and trigger.talent.enabled then
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

		-- Not Status
		if c.notCasting or c.notChanneling then
			if c.notCasting and c.notChanneling then
				if not b.casting and not b.channeling then passed = true else return end
			elseif (c.notCasting and not b.casting) or (c.notChanneling and not b.channeling) then passed = true else return end
		end

		-- Is Status
		if c.isCasting or c.isChanneling then
			if (c.isCasting and b.casting) or (c.isChanneling and b.channeling) then passed = true else return end
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
	if frame.Buffs_ and trigger.buffs then
		-- Has Stealable
		if trigger.buffs.hasStealable or trigger.buffs.hasNoStealable then
			local isStealable = mod:StyleFilterDispelCheck(frame, filter)
			if (trigger.buffs.hasStealable and isStealable) or (trigger.buffs.hasNoStealable and not isStealable) then passed = true else return end
		end

		-- Names / Spell IDs
		if trigger.buffs.names and next(trigger.buffs.names) then
			local buff = mod:StyleFilterAuraCheck(frame, trigger.buffs.names, frame.Buffs_.tickers, 'HELPFUL', trigger.buffs.mustHaveAll, trigger.buffs.missing, trigger.buffs.minTimeLeft, trigger.buffs.maxTimeLeft, trigger.buffs.fromMe, trigger.buffs.fromPet)
			if buff ~= nil then -- ignore if none are selected
				if buff then passed = true else return end
			end
		end
	end

	-- Debuffs
	if frame.Debuffs_ and trigger.debuffs and trigger.debuffs.names and next(trigger.debuffs.names) then
		-- Has Dispellable
		if trigger.debuffs.hasDispellable or trigger.debuffs.hasNoDispellable then
			local canDispel = mod:StyleFilterDispelCheck(frame, filter)
			if (trigger.debuffs.hasDispellable and canDispel) or (trigger.debuffs.hasNoDispellable and not canDispel) then passed = true else return end
		end

		-- Names / Spell IDs
		local debuff = mod:StyleFilterAuraCheck(frame, trigger.debuffs.names, frame.Debuffs_.tickers, 'HARMFUL', trigger.debuffs.mustHaveAll, trigger.debuffs.missing, trigger.debuffs.minTimeLeft, trigger.debuffs.maxTimeLeft, trigger.debuffs.fromMe, trigger.debuffs.fromPet)
		if debuff ~= nil then -- ignore if none are selected
			if debuff then passed = true else return end
		end
	end

	-- BossMod Auras
	if frame.BossMods and trigger.bossMods and trigger.bossMods.enable then
		local element, m = frame.BossMods, trigger.bossMods
		local icons = next(element.activeIcons)

		if m.hasAura or m.missingAura then
			if (m.hasAura and icons) or (m.missingAura and not icons) then passed = true else return end
		elseif icons and m.auras and next(m.auras) then
			for texture, value in pairs(m.auras) do
				if value then -- only if they are turned on
					local active = element.activeIcons[texture]
					if (not m.missingAuras and active) or (m.missingAuras and not active) then passed = true else return end
					break -- we can execute this once on the first enabled option then kill the loop
				end
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
	local healthBarEnabled = db.health.enable or (mod.db.displayStyle ~= 'ALL') or (frame.isTarget and mod.db.alwaysShowTargetHealth)
	local healthBarShown = healthBarEnabled and frame.Health:IsShown()

	mod:StyleFilterSetChanges(frame, actions,
		(healthBarShown and actions.color and actions.color.health), --HealthColor
		(healthBarShown and db.power.enable and actions.color and actions.color.power), --PowerColor
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

function mod:StyleFilterClear(frame)
	if frame == _G.ElvNP_Test then return end

	local c = frame.StyleFilterChanges
	if c and next(c) then
		mod:StyleFilterClearChanges(frame, c.HealthColor, c.PowerColor, c.Borders, c.HealthFlash, c.HealthTexture, c.Scale, c.Alpha, c.NameTag, c.PowerTag, c.HealthTag, c.TitleTag, c.LevelTag, c.Portrait, c.NameOnly, c.Visibility)
	end
end

function mod:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] -- Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

function mod:StyleFilterVehicleFunction(_, unit)
	unit = unit or self.unit
	self.inVehicle = (E.Retail or E.Wrath) and UnitInVehicle(unit) or nil
end

function mod:StyleFilterTargetFunction(_, unit)
	unit = unit or self.unit
	self.isTargetingMe = UnitIsUnit(unit..'target', 'player') or nil
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
	UNIT_TARGET = mod.StyleFilterTargetFunction,
	UNIT_THREAT_LIST_UPDATE = mod.StyleFilterTargetFunction,
	UNIT_ENTERED_VEHICLE = mod.StyleFilterVehicleFunction,
	UNIT_EXITED_VEHICLE = mod.StyleFilterVehicleFunction,
	VEHICLE_UPDATE = mod.StyleFilterVehicleFunction
}

mod.StyleFilterSetVariablesIgnored = {
	UNIT_THREAT_LIST_UPDATE = true,
	UNIT_ENTERED_VEHICLE = true,
	UNIT_EXITED_VEHICLE = true
}

function mod:StyleFilterSetVariables(nameplate)
	if nameplate == _G.ElvNP_Test then return end

	for event, func in pairs(mod.StyleFilterEventFunctions) do
		if not mod.StyleFilterSetVariablesIgnored[event] then -- ignore extras as we just need one call to Vehicle and Target
			func(nameplate)
		end
	end
end

function mod:StyleFilterClearVariables(nameplate)
	if nameplate == _G.ElvNP_Test then return end

	nameplate.isTarget = nil
	nameplate.isFocused = nil
	nameplate.inVehicle = nil
	nameplate.isTargetingMe = nil
	nameplate.RaidTargetIndex = nil
	nameplate.ThreatScale = nil
end

mod.StyleFilterTriggerList = {} -- configured filters enabled with sorted priority
mod.StyleFilterTriggerEvents = {} -- events required by the filter that we need to watch for
mod.StyleFilterPlateEvents = {} -- events watched inside of ouf, which is called on the nameplate itself, updated by StyleFilterWatchEvents
mod.StyleFilterDefaultEvents = { -- list of events style filter uses to populate plate events (updated during StyleFilterEvents), true if unitless
	-- existing:
	UNIT_AURA = false,
	UNIT_CONNECTION = false,
	UNIT_DISPLAYPOWER = false,
	UNIT_MAXHEALTH = false,
	UNIT_NAME_UPDATE = false,
	UNIT_PET = false,
	UNIT_POWER_UPDATE = false,
	-- mod events:
	GROUP_ROSTER_UPDATE = true,
	INCOMING_RESURRECT_CHANGED = false,
	MODIFIER_STATE_CHANGED = true,
	PLAYER_EQUIPMENT_CHANGED = true,
	PLAYER_FLAGS_CHANGED = false,
	PLAYER_FOCUS_CHANGED = true,
	PLAYER_REGEN_DISABLED = true,
	PLAYER_REGEN_ENABLED = true,
	PLAYER_TARGET_CHANGED = true,
	PLAYER_UPDATE_RESTING = true,
	QUEST_LOG_UPDATE = true,
	RAID_TARGET_UPDATE = true,
	SPELL_UPDATE_COOLDOWN = true,
	UNIT_ENTERED_VEHICLE = false,
	UNIT_EXITED_VEHICLE = false,
	UNIT_FLAGS = false,
	UNIT_TARGET = false,
	UNIT_THREAT_LIST_UPDATE = false,
	UNIT_THREAT_SITUATION_UPDATE = false,
	VEHICLE_UPDATE = true
}

if E.Retail then
	mod.StyleFilterDefaultEvents.UNIT_HEALTH = false
else
	mod.StyleFilterDefaultEvents.UNIT_HEALTH_FREQUENT = false
end

mod.StyleFilterCastEvents = {
	UNIT_SPELLCAST_START = 1,			-- start
	UNIT_SPELLCAST_CHANNEL_START = 1,
	UNIT_SPELLCAST_STOP = 1,			-- stop
	UNIT_SPELLCAST_CHANNEL_STOP = 1,
	UNIT_SPELLCAST_FAILED = 1,			-- fail
	UNIT_SPELLCAST_INTERRUPTED = 1
}
for event in pairs(mod.StyleFilterCastEvents) do
	mod.StyleFilterDefaultEvents[event] = false
end

function mod:StyleFilterWatchEvents()
	for event in pairs(mod.StyleFilterDefaultEvents) do
		mod.StyleFilterPlateEvents[event] = mod.StyleFilterTriggerEvents[event] and true or nil
	end
end

function mod:StyleFilterConfigure()
	local events = mod.StyleFilterTriggerEvents
	local list = mod.StyleFilterTriggerList
	wipe(events)
	wipe(list)

	if mod.db.filters then
		for filterName, filter in pairs(E.global.nameplates.filters) do
			local t = filter.triggers
			if t and mod.db.filters[filterName] and mod.db.filters[filterName].triggers and mod.db.filters[filterName].triggers.enable then
				tinsert(list, {filterName, t.priority or 1})

				-- NOTE: 0 for fake events
				events.FAKE_AuraWaitTimer = 0 -- for minTimeLeft and maxTimeLeft aura trigger
				events.FAKE_BossModAuras = 0 -- support to trigger filters based on Boss Mod Auras
				events.PLAYER_TARGET_CHANGED = 1
				events.NAME_PLATE_UNIT_ADDED = 1
				events.UNIT_FACTION = 1 -- frameType can change here
				events.ForceUpdate = -1
				events.PoolerUpdate = -1

				if t.casting then
					local spell
					if next(t.casting.spells) then
						for _, value in pairs(t.casting.spells) do
							if value then
								spell = true
								break
					end end end

					if spell or (t.casting.interruptible or t.casting.notInterruptible or t.casting.isCasting or t.casting.isChanneling or t.casting.notCasting or t.casting.notChanneling) then
						for event in pairs(mod.StyleFilterCastEvents) do
							events[event] = 1
						end
					end
				end

				if t.keyMod and t.keyMod.enable then		events.MODIFIER_STATE_CHANGED = 1 end
				if t.isFocus or t.notFocus then				events.PLAYER_FOCUS_CHANGED = 1 end
				if t.isResting then							events.PLAYER_UPDATE_RESTING = 1 end
				if t.isTapDenied or t.isNotTapDenied then	events.UNIT_FLAGS = 1 end
				if t.isPet then								events.UNIT_PET = 1 end

				if t.targetMe or t.notTargetMe then
					events.UNIT_THREAT_LIST_UPDATE = 1
					events.UNIT_TARGET = 1
				end

				if t.raidTarget and (t.raidTarget.star or t.raidTarget.circle or t.raidTarget.diamond or t.raidTarget.triangle or t.raidTarget.moon or t.raidTarget.square or t.raidTarget.cross or t.raidTarget.skull) then
					events.RAID_TARGET_UPDATE = 1
				end

				if t.unitInVehicle then
					events.UNIT_ENTERED_VEHICLE = 1
					events.UNIT_EXITED_VEHICLE = 1
					events.VEHICLE_UPDATE = 1
				end

				if t.healthThreshold then
					events.UNIT_MAXHEALTH = 1

					if E.Retail then
						events.UNIT_HEALTH = 1
					else
						events.UNIT_HEALTH_FREQUENT = 1
					end
				end

				if t.powerThreshold then
					events.UNIT_POWER_UPDATE = 1
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

				if t.inParty or t.notInParty or t.inRaid or t.notInRaid or t.unitRole then
					events.GROUP_ROSTER_UPDATE = 1
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

				if t.isQuest or t.notQuest then
					events.QUEST_LOG_UPDATE = 1
				end

				if t.hasTitleNPC or t.noTitleNPC then
					events.UNIT_NAME_UPDATE = 1
				end

				if t.isBeingResurrected or t.notBeingResurrected then
					events.INCOMING_RESURRECT_CHANGED = 1
				end

				if t.isConnected or t.notConnected then
					events.UNIT_CONNECTION = 1
				end

				if t.isDeadOrGhost or t.notDeadOrGhost then
					events.PLAYER_FLAGS_CHANGED = 1
				end

				if t.isUnconscious or t.isConscious or t.isCharmed or t.notCharmed or t.isPossessed or t.notPossessed then
					events.UNIT_FLAGS = 1 -- instead these might need UNIT_AURA
				end

				if t.buffs and (t.buffs.hasStealable or t.buffs.hasNoStealable) then
					events.UNIT_AURA = 1
				end

				if not events.UNIT_NAME_UPDATE and t.names and next(t.names) then
					for _, value in pairs(t.names) do
						if value then
							events.UNIT_NAME_UPDATE = 1
							break
				end end end

				if not events.PLAYER_EQUIPMENT_CHANGED and t.slots and next(t.slots) then
					for _, value in pairs(t.slots) do
						if value then
							events.PLAYER_EQUIPMENT_CHANGED = 1
							break
				end end end

				if not events.PLAYER_EQUIPMENT_CHANGED and t.items and next(t.items) then
					for _, value in pairs(t.items) do
						if value then
							events.PLAYER_EQUIPMENT_CHANGED = 1
							break
				end end end

				if not events.SPELL_UPDATE_COOLDOWN and t.cooldowns and t.cooldowns.names and next(t.cooldowns.names) then
					for _, value in pairs(t.cooldowns.names) do
						if value == 'ONCD' or value == 'OFFCD' then
							events.SPELL_UPDATE_COOLDOWN = 1
							break
				end end end

				if not events.UNIT_AURA and t.buffs and t.buffs.names and next(t.buffs.names) then
					for _, value in pairs(t.buffs.names) do
						if value then
							events.UNIT_AURA = 1
							break
				end end end

				if not events.UNIT_AURA and t.debuffs and t.debuffs.names and next(t.debuffs.names) then
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

function mod:StyleFilterHiddenState(c)
	return c and ((c.NameOnly and c.Visibility and 3) or (c.NameOnly and 2) or (c.Visibility and 1))
end

function mod:StyleFilterUpdate(frame, event)
	if frame == _G.ElvNP_Test or not frame.StyleFilterChanges or not mod.StyleFilterTriggerEvents[event] then return end

	local state = mod:StyleFilterHiddenState(frame.StyleFilterChanges)

	mod:StyleFilterClear(frame)

	for filterNum in ipairs(mod.StyleFilterTriggerList) do
		local filter = E.global.nameplates.filters[mod.StyleFilterTriggerList[filterNum][1]]
		if filter then
			mod:StyleFilterConditionCheck(frame, filter, filter.triggers)
		end
	end

	mod:StyleFilterClearVisibility(frame, state)
end

do -- oUF style filter inject watch functions without actually registering any events
	local pooler = CreateFrame('Frame')
	pooler.frames = {}
	pooler.delay = 0.1 -- update check rate

	pooler.update = function()
		for frame in pairs(pooler.frames) do
			mod:StyleFilterUpdate(frame, 'PoolerUpdate')
		end

		wipe(pooler.frames) -- clear it out
	end

	pooler.onUpdate = function(self, elapsed)
		if self.elapsed and self.elapsed > pooler.delay then
			pooler.update()

			self.elapsed = 0
		else
			self.elapsed = (self.elapsed or 0) + elapsed
		end
	end

	pooler:SetScript('OnUpdate', pooler.onUpdate)

	local update = function(frame, event, arg1, arg2, arg3, ...)
		local eventFunc = mod.StyleFilterEventFunctions[event]
		if eventFunc then
			eventFunc(frame, event, arg1, arg2, arg3, ...)
		end

		local auraEvent = event == 'UNIT_AURA'
		if auraEvent and ElvUF:ShouldSkipAuraUpdate(frame, event, arg1, arg2, arg3) then
			return
		end

		-- Trigger Event and (auraEvent or unitless or verifiedUnit); auraEvent is already unit verified by ShouldSkipAuraUpdate
		if mod.StyleFilterTriggerEvents[event] and (auraEvent or mod.StyleFilterDefaultEvents[event] or (arg1 and arg1 == frame.unit)) then
			pooler.frames[frame] = true
		end
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

	function mod:StyleFilterEventWatch(frame, disable)
		if frame == _G.ElvNP_Test then return end

		for event in pairs(mod.StyleFilterDefaultEvents) do
			local holdsEvent = styleFilterIsWatching(frame, event)
			if disable then
				if holdsEvent then
					oUF_fake_register(frame, event, true)
				end
			elseif mod.StyleFilterPlateEvents[event] then
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
	if nameplate == _G.ElvNP_Test then return end

	-- happy little table
	nameplate.StyleFilterChanges = {}

	-- add events to be watched
	for event, unitless in pairs(mod.StyleFilterDefaultEvents) do
		mod:StyleFilterRegister(nameplate, event, unitless)
	end

	-- object event pathing (these update after MapInfo updates), these events are not added onto the nameplate itself
	mod:StyleFilterRegister(nameplate,'LOADING_SCREEN_DISABLED', nil, nil, E.MapInfo)
	mod:StyleFilterRegister(nameplate,'ZONE_CHANGED_NEW_AREA', nil, nil, E.MapInfo)
	mod:StyleFilterRegister(nameplate,'ZONE_CHANGED_INDOORS', nil, nil, E.MapInfo)
	mod:StyleFilterRegister(nameplate,'ZONE_CHANGED', nil, nil, E.MapInfo)
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
	mod:StyleFilterClearDefaults(E.global.nameplates.filters)
end

function mod:StyleFilterClearDefaults(tbl)
	for filterName, filterTable in pairs(tbl) do
		if G.nameplates.filters[filterName] then
			local defaultTable = E:CopyTable({}, E.StyleFilterDefaults)
			E:CopyTable(defaultTable, G.nameplates.filters[filterName])
			E:RemoveDefaults(filterTable, defaultTable)
		else
			E:RemoveDefaults(filterTable, E.StyleFilterDefaults)
		end
	end
end

function mod:StyleFilterCopyDefaults(tbl)
	return E:CopyDefaults(tbl or {}, E.StyleFilterDefaults)
end

function mod:StyleFilterInitialize()
	for _, filterTable in pairs(E.global.nameplates.filters) do
		mod:StyleFilterCopyDefaults(filterTable)
	end
end
