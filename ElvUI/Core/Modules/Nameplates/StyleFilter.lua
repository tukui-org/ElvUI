local E, L, V, P, G = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local LSM = E.Libs.LSM
local LCG = E.Libs.CustomGlow
local ElvUF = E.oUF
local AuraFiltered = ElvUF.AuraFiltered

local _G = _G
local setmetatable, tostring, tonumber, type, unpack = setmetatable, tostring, tonumber, type, unpack
local strmatch, tinsert, tremove, next, sort, wipe = strmatch, tinsert, tremove, next, sort, wipe

local IsResting = IsResting
local PlaySoundFile = PlaySoundFile
local GetInstanceInfo = GetInstanceInfo
local GetInventoryItemID = GetInventoryItemID
local GetRaidTargetIndex = GetRaidTargetIndex
local GetTime = GetTime
local UnitAffectingCombat = UnitAffectingCombat
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local UnitChannelInfo = UnitChannelInfo
local UnitCastingInfo = UnitCastingInfo
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

local C_Sound_IsPlaying = C_Sound.IsPlaying
local C_Timer_NewTimer = C_Timer.NewTimer
local C_Item_IsEquippedItem = C_Item.IsEquippedItem
local C_PetBattles_IsInBattle = C_PetBattles and C_PetBattles.IsInBattle
local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook or IsSpellKnownOrOverridesKnown
local IsSpellKnown = C_SpellBook.IsSpellKnown or IsPlayerSpell

local BleedList = E.Libs.Dispel:GetBleedList()
local DispelTypes = E.Libs.Dispel:GetMyDispelTypes()

NP.StyleFilterStackPattern = '([^\n]+)\n?(%d*)$'
NP.TriggerConditions = {
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
	difficulties = { -- also has IDs maintained in Difficulty Datatext
		-- dungeons
		[1] = 'normal',
		[2] = 'heroic',
		[8] = 'mythic+',
		[23] = 'mythic',
		[24] = 'timewalking',
		[198] = 'normal', -- Classic: Season of Discovery
		[201] = 'normal', -- Classic: Hardcore
		-- raids
		[7] = 'lfr',
		[17] = 'lfr',
		[151] = 'timewalking', -- lfr
		[14] = 'normal',
		[15] = 'heroic',
		[16] = 'mythic',
		[33] = 'timewalking',
		[3] = 'legacy10normal',
		[4] = 'legacy25normal',
		[5] = 'legacy10heroic',
		[6] = 'legacy25heroic',
		-- pvp
		[25] = 'pvp', -- Scenario: World PvP
		[29] = 'pvp', -- Scenario: PvEvP
		[32] = 'pvp', -- Scenario: World PvP
		[34] = 'pvp',
		[45] = 'pvp', -- Scenario: PvP
		-- scenario
		[11] = 'scenario', -- Scenario: Heroic
		[12] = 'scenario', -- Scenario: Normal
		[30] = 'scenario', -- Event
		[38] = 'scenario', -- Normal
		[39] = 'scenario', -- Heroic
		[40] = 'scenario', -- Mythic
		[147] = 'scenario', -- Warfronts
		[149] = 'scenario', -- Warfronts: Heroic
		[152] = 'scenario', -- Visions of N'Zoth
		[153] = 'scenario', -- Teeming Island
		-- event
		[18] = 'event', -- raid
		[19] = 'event', -- party
		[20] = 'event', -- scenario
		-- classic / tbc
		[9] = 'legacy40normal',
		[148] = 'legacy20normal',
		[173] = 'normal',
		[174] = 'heroic',
		[185] = 'legacy20normal',
		[186] = 'legacy40normal',
		[215] = 'normal', -- Classic: Sunken Temple
		-- wotlk
		[175] = 'legacy10normal',
		[176] = 'legacy25normal',
		[193] = 'legacy10heroic',
		[194] = 'legacy25heroic',
		-- follower dungeon
		[205] = 'follower'
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

function NP:StyleFilterTickerCallback(frame, ticker, timer)
	if frame and frame:IsShown() then
		NP:StyleFilterUpdate(frame, 'FAKE_AuraWaitTimer')
	end

	if ticker[timer] then
		ticker[timer]:Cancel()
		ticker[timer] = nil
	end
end

function NP:StyleFilterTickerCreate(delay, frame, ticker, timer)
	return C_Timer_NewTimer(delay, function() NP:StyleFilterTickerCallback(frame, ticker, timer) end)
end

function NP:StyleFilterAuraWait(frame, ticker, timer, timeLeft, mTimeLeft)
	if not ticker[timer] then
		local updateIn = timeLeft-mTimeLeft
		if updateIn > 0 then -- also add a tenth of a second to updateIn to prevent the timer from firing on the same second
			ticker[timer] = NP:StyleFilterTickerCreate(updateIn+0.1, frame, ticker, timer)
		end
	end
end

function NP:StyleFilterDispelCheck(frame, event, arg1, arg2, filter)
	local unitAuraFiltered = AuraFiltered[filter][frame.unit]
	local auraInstanceID, aura = next(unitAuraFiltered)
	while aura do
		if filter == 'HELPFUL' then
			if aura.isStealable then
				return true
			end
		elseif aura.dispelName and DispelTypes[aura.dispelName] then
			return true -- regular debuff with a type
		elseif not aura.dispelName and DispelTypes.Bleed and BleedList[aura.spellID] then
			return true -- its a bleed debuff
		end

		auraInstanceID, aura = next(unitAuraFiltered, auraInstanceID)
	end
end

function NP:StyleFilterAuraData(frame, event, arg1, arg2, filter, unit, spellName, spellID)
	local index, temp = 1
	local unitAuraFiltered = AuraFiltered[filter][unit]
	local auraInstanceID, aura = next(unitAuraFiltered)
	while aura do
		if spellName == aura.name or spellID == aura.spellId then
			if not temp then temp = {} end

			temp[index] = aura
		end

		index = index + 1
		auraInstanceID, aura = next(unitAuraFiltered, auraInstanceID)
	end

	return temp
end

function NP:StyleFilterAuraCheck(frame, event, arg1, arg2, filter, names, tickers, mustHaveAll, missing, minTimeLeft, maxTimeLeft, fromMe, fromPet, onMe, onPet)
	local total, matches, now = 0, 0, GetTime()

	for key, value in next, names do
		if value then -- only if they are turned on
			total = total + 1 -- keep track of the names

			local spell, count = strmatch(key, NP.StyleFilterStackPattern)
			local auras = NP:StyleFilterAuraData(frame, event, arg1, arg2, filter, (onMe and 'player') or (onPet and 'pet') or frame.unit, spell, tonumber(spell))

			if auras then
				local stacks = tonumber(count) -- send stacks to nil or int
				local hasMinTime = minTimeLeft and minTimeLeft ~= 0
				local hasMaxTime = maxTimeLeft and maxTimeLeft ~= 0

				for _, data in next, auras do -- need to loop for the sources, not all the spells though
					if not stacks or (data.applications and data.applications >= stacks) then
						local isMe, isPet = data.sourceUnit == 'player' or data.sourceUnit == 'vehicle', data.sourceUnit == 'pet'
						if fromMe and fromPet and (isMe or isPet) or (fromMe and isMe) or (fromPet and isPet) or (not fromMe and not fromPet) then
							local timeLeft = (hasMinTime or hasMaxTime) and data.expirationTime and ((data.expirationTime - now) / (data.timeMod or 1))
							local minTimeAllow = not hasMinTime or (timeLeft and timeLeft > minTimeLeft)
							local maxTimeAllow = not hasMaxTime or (timeLeft and timeLeft < maxTimeLeft)

							if minTimeAllow and maxTimeAllow then
								matches = matches + 1 -- keep track of how many matches we have
							end

							if timeLeft then -- if we use a min/max time setting; we must create a delay timer
								if not tickers[matches] then tickers[matches] = {} end
								if hasMinTime then NP:StyleFilterAuraWait(frame, tickers[matches], 'hasMinTimer', timeLeft, minTimeLeft) end
								if hasMaxTime then NP:StyleFilterAuraWait(frame, tickers[matches], 'hasMaxTimer', timeLeft, maxTimeLeft) end
			end end end end end

			local stale = matches + 1
			local ticker = tickers[stale]
			while ticker and (ticker.hasMinTimer or ticker.hasMaxTimer) do -- cancel stale timers
				if ticker.hasMinTimer then ticker.hasMinTimer:Cancel() ticker.hasMinTimer = nil end
				if ticker.hasMaxTimer then ticker.hasMaxTimer:Cancel() ticker.hasMaxTimer = nil end

				stale = stale + 1
				ticker = tickers[stale]
	end end end

	if total == 0 then
		return nil -- If no auras are checked just pass nil, we dont need to run the filter here.
	else
		return ((mustHaveAll and not missing) and total == matches)	-- [x] Check for all [ ] Missing: total needs to match count
		or ((not mustHaveAll and not missing) and matches > 0)		-- [ ] Check for all [ ] Missing: count needs to be greater than zero
		or ((not mustHaveAll and missing) and matches == 0)			-- [ ] Check for all [x] Missing: count needs to be zero
		or ((mustHaveAll and missing) and total ~= matches)			-- [x] Check for all [x] Missing: count must not match total
	end
end

function NP:StyleFilterCooldownCheck(names, mustHaveAll)
	local _, gcd = E:GetSpellCooldown(61304)
	local total, count = 0, 0

	for name, value in next, names do
		if E:GetSpellInfo(name) then -- check spell name valid, GetSpellCharges/GetSpellCooldown will return nil if not known by your class
			if value == 'ONCD' or value == 'OFFCD' then -- only if they are turned on
				total = total + 1 -- keep track of the names

				local charges = E:GetSpellCharges(name)
				local _, duration = E:GetSpellCooldown(name)

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

function NP:StyleFilterFinishedFlash()
	if self:GetChange() == self.customValue then
		self:SetChange(0)
	else
		self:SetChange(self.customValue)
	end
end

function NP:StyleFilterSetupFlash(flashTexture)
	local anim = _G.CreateAnimationGroup(flashTexture)
	anim:SetLooping(true)
	flashTexture.anim = anim

	anim.Fade = anim:CreateAnimation('fade')
	anim.Fade:SetChange(0)
	anim.Fade:SetEasing('in')
	anim.Fade:SetScript('OnFinished', NP.StyleFilterFinishedFlash)

	return anim
end

function NP:StyleFilterBaseUpdate(frame, state)
	if not frame.StyleFilterBaseAlreadyUpdated then -- skip updates from UpdatePlateBase
		NP:UpdatePlate(frame, true) -- enable elements back
	end

	local db = NP:PlateDB(frame) -- keep this after UpdatePlate
	if not db.nameOnly then
		if db.power.enable then frame.Power:ForceUpdate() end
		if db.health.enable then frame.Health:ForceUpdate() end
		if db.castbar.enable then frame.Castbar:ForceUpdate() end

		if NP.db.threat.enable and NP.db.threat.useThreatColor and not UnitIsTapDenied(frame.unit) then
			frame.ThreatIndicator:ForceUpdate() -- this will account for the threat health color
		end

		if frame.isTarget and frame.frameType ~= 'PLAYER' and NP.db.units.TARGET.glowStyle ~= 'none' then
			frame.TargetIndicator:ForceUpdate() -- so the target indicator will show up
		end
	end

	if frame.isTarget then
		NP:SetupTarget(frame, db.nameOnly) -- so the classbar will show up
	end

	if state and not NP.SkipFading then
		NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, 0, 1) -- fade those back in so it looks clean
	end
end

function NP:StyleFilterBorderLock(backdrop, r, g, b, a)
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
	function NP:StyleFilterChanges(frame)
		return (frame and frame.StyleFilterChanges) or empty
	end
end

function NP:StyleFilterSetChangesOnElement(frame, event, actions, temp, changes, bar, cutaway)
	if temp.colors then
		local hc = (actions.colors.playerClass and E.myClassColor) or (actions.colors.unitClass and frame.classColor) or actions.colors.color

		changes.color = hc

		bar:SetStatusBarColor(hc.r, hc.g, hc.b, hc.a or 1)

		if cutaway then
			cutaway:SetVertexColor(hc.r * 1.5, hc.g * 1.5, hc.b * 1.5, hc.a or 1)
		end
	end

	if temp.border then
		local bc = (actions.border.playerClass and E.myClassColor) or (actions.border.unitClass and frame.classColor) or actions.border.color

		changes.border = bc

		NP:StyleFilterBorderLock(bar.backdrop, bc.r, bc.g, bc.b, bc.a or 1)
	end

	if temp.glow then
		bar.glowStyle = actions.glow.style

		changes.glow = actions.glow

		LCG.ShowOverlayGlow(bar, actions.glow)
	end

	local flashTexture = bar.flashTexture
	if temp.flash and flashTexture then
		if not temp.texture then
			flashTexture:SetTexture(LSM:Fetch('statusbar', NP.db.statusbar))
		end

		local anim = flashTexture.anim or NP:StyleFilterSetupFlash(flashTexture)
		if anim and anim.Fade then
			local fc = (actions.flash.playerClass and E.myClassColor) or (actions.flash.unitClass and frame.classColor) or actions.flash.color
			anim.Fade.customValue = fc.a or 1
			anim.Fade:SetDuration(actions.flash.speed * 0.1)
			anim.Fade:SetChange(anim.Fade.customValue)

			changes.flash = fc

			flashTexture:Show()
			flashTexture:SetVertexColor(fc.r, fc.g, fc.b)
			flashTexture:SetAlpha(anim.Fade.customValue) -- set the start alpha

			if not anim:IsPlaying() then
				anim:Play()
			end
		end
	end

	if temp.texture then
		local tx = LSM:Fetch('statusbar', actions.texture.texture)

		changes.texture = actions.texture.texture

		if bar.barTexture then
			bar.barTexture:SetTexture(tx)
		end

		if flashTexture then
			flashTexture:SetTexture(tx)
		end
	end
end

function NP:StyleFilterSetChanges(frame, event, filter, temp)
	local changes = frame.StyleFilterChanges
	local actions = filter.actions
	local general = temp.general

	if general.visibility or general.nameOnly then
		changes.general.visibility = general.visibility
		changes.general.nameOnly = general.nameOnly

		if general.nameOnly then -- only allow name only for the secure plate
			NP:DisablePlate(frame, general.nameOnly and 1 or nil)
		end

		if general.visibility then -- we cant hide a secure plate
			frame:ClearAllPoints() -- lets still move the frame out cause its clickable otherwise
			frame:Point('TOP', E.UIParent, 'BOTTOM', 0, -500)

			return -- We hide it. Lets not do other things (no point)
		end
	end

	-- Keeps Tag changes after NameOnly
	local tags = temp.tags
	if tags.name then
		changes.tags.name = actions.tags.name
		frame:Tag(frame.Name, actions.tags.name)
		frame.Name:UpdateTag()
	end
	if tags.power then
		changes.tags.power = actions.tags.power
		frame:Tag(frame.Power.Text, actions.tags.power)
		frame.Power.Text:UpdateTag()
	end
	if tags.health then
		changes.tags.health = actions.tags.health
		frame:Tag(frame.Health.Text, actions.tags.health)
		frame.Health.Text:UpdateTag()
	end
	if tags.title then
		changes.tags.title = actions.tags.title
		frame:Tag(frame.Title, actions.tags.title)
		frame.Title:UpdateTag()
	end
	if tags.level then
		changes.tags.level = actions.tags.level
		frame:Tag(frame.Level, actions.tags.level)
		frame.Level:UpdateTag()
	end

	-- generic stuff
	if general.scale then
		changes.general.scale = actions.scale
		NP:ScalePlate(frame, actions.scale)
	end
	if general.alpha then
		changes.general.scale = actions.alpha
		NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), actions.alpha * 0.01)
	end
	if general.portrait then
		changes.general.portrait = general.portrait
		NP:Update_Portrait(frame)
		frame.Portrait:ForceUpdate()
	end

	if general.nameOnly then
		return -- skip the other stuff now
	end

	if general.sound then
		local sound = E.LSM:Fetch('sound', actions.sound.soundFile)

		if actions.sound.overlap then
			PlaySoundFile(sound)
		else
			local exists = NP.SoundHandlers[sound]
			if not exists or not C_Sound_IsPlaying(exists) then
				local willPlay, soundHandle = PlaySoundFile(sound, actions.sound.channel)
				if willPlay then -- we can play it, add it to handlers
					NP.SoundHandlers[sound] = soundHandle
				end
			end
		end
	end

	NP:StyleFilterSetChangesOnElement(frame, event, actions.health, temp.health, changes.health, frame.Health, frame.Cutaway.Health)
	NP:StyleFilterSetChangesOnElement(frame, event, actions.power, temp.power, changes.power, frame.Power, frame.Cutaway.Power)
	NP:StyleFilterSetChangesOnElement(frame, event, actions.castbar, temp.castbar, changes.castbar, frame.Castbar)
end

function NP:StyleFilterClearVisibility(frame, event, previous)
	local state = NP:StyleFilterHiddenState(frame.StyleFilterChanges)

	if (previous == 1 or previous == 3) and (state ~= 1 and state ~= 3) then
		frame:ClearAllPoints() -- pull the frame back in

		if frame == NP.PlayerFrame then
			frame:Point('TOP', NP.PlayerMover)
		else
			frame:Point('CENTER')
		end
	end

	if previous and not state and event ~= 'NAME_PLATE_UNIT_REMOVED' then
		NP:StyleFilterBaseUpdate(frame, state == 1)
	end
end

function NP:StyleFilterClearChangesOnElement(frame, changes, bar, cutaway)
	local db = NP:PlateDB(frame)

	if changes.colors then
		if bar.r and bar.g and bar.b then
			bar:SetStatusBarColor(bar.r, bar.g, bar.b)

			if cutaway then
				cutaway:SetVertexColor(bar.r * 1.5, bar.g * 1.5, bar.b * 1.5, 1)
			end
		end
	end

	if changes.glow then
		LCG.HideOverlayGlow(bar, bar.glowStyle)

		bar.glowStyle = nil
	end

	if changes.border then
		NP:StyleFilterBorderLock(bar.backdrop)

		if frame.Power.backdrop and db.power.enable then
			NP:StyleFilterBorderLock(frame.Power.backdrop)
		end
	end

	if changes.flash then
		local anim = bar.flashTexture.anim
		if anim and anim:IsPlaying() then
			anim:Stop()
		end

		bar.flashTexture:Hide()
	end

	if changes.texture and bar.barTexture then
		local tx = LSM:Fetch('statusbar', NP.db.statusbar)

		bar.barTexture:SetTexture(tx)
	end
end

function NP:StyleFilterClearChanges(frame)
	local changes = frame.StyleFilterChanges
	local db = NP:PlateDB(frame)

	if not changes.general.nameOnly then -- Only update these if it wasn't NameOnly. Otherwise, it leads to `Update_Tags` which does the job.
		if changes.tags.name then frame:Tag(frame.Name, db.name.format) frame.Name:UpdateTag() end
		if changes.tags.power then frame:Tag(frame.Power.Text, db.power.text.format) frame.Power.Text:UpdateTag() end
		if changes.tags.health then frame:Tag(frame.Health.Text, db.health.text.format) frame.Health.Text:UpdateTag() end
		if changes.tags.title then frame:Tag(frame.Title, db.title.format) frame.Title:UpdateTag() end
		if changes.tags.level then frame:Tag(frame.Level, db.level.format) frame.Level:UpdateTag() end
	end

	-- generic stuff
	if changes.general.scale then
		NP:ScalePlate(frame, frame.threatScale or 1)
	end

	if changes.general.alpha then
		NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, (frame.FadeObject and frame.FadeObject.endAlpha) or 0.5, 1)
	end

	if changes.general.portrait then
		NP:Update_Portrait(frame)
	end

	NP:StyleFilterClearChangesOnElement(frame, changes.health, frame.Health, frame.Cutaway.Health)
	NP:StyleFilterClearChangesOnElement(frame, changes.power, frame.Power, frame.Cutaway.Power)
	NP:StyleFilterClearChangesOnElement(frame, changes.castbar, frame.Castbar)

	wipe(changes) -- farewell
end

function NP:StyleFilterThreatUpdate(frame, unit)
	if NP:UnitExists(unit) then
		local isTank, offTank, feedbackUnit = NP.ThreatIndicator_PreUpdate(frame.ThreatIndicator, unit, true)
		if feedbackUnit and (feedbackUnit ~= unit) and NP:UnitExists(feedbackUnit) then
			return isTank, offTank, UnitThreatSituation(feedbackUnit, unit)
		else
			return isTank, offTank, UnitThreatSituation(unit)
		end
	end
end

function NP:StyleFilterConditionCheck(frame, event, arg1, arg2, filter, trigger)
	local passed -- value we will return at the end

	-- Class and Specialization
	if trigger.class and next(trigger.class) then
		local Class = trigger.class[E.myclass]
		if not Class or (Class.specs and next(Class.specs) and not Class.specs[E.myspecID]) then
			return
		else
			passed = true
		end
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

	do -- Nameplate Amount Displaying
		local below, above = trigger.amountBelow or 0, trigger.amountAbove or 0
		local hasBelow, hasAbove = below > 0, above > 0
		if hasBelow or hasAbove then
			local isBelow = hasBelow and NP.numPlates < below
			local isAbove = hasAbove and NP.numPlates > above
			if hasBelow and hasAbove then
				if isBelow and isAbove then passed = true else return end
			elseif isBelow or isAbove then passed = true else
				return
	end end end

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
	if (E.Retail or E.Mists) and (trigger.inPetBattle or trigger.notPetBattle) then
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
	if (E.Retail or E.Mists) and (trigger.inVehicle or trigger.outOfVehicle) then
		local inVehicle = UnitInVehicle('player')
		if (trigger.inVehicle and inVehicle) or (trigger.outOfVehicle and not inVehicle) then passed = true else return end
	end

	-- Unit Vehicle
	if (E.Retail or E.Mists) and (trigger.inVehicleUnit or trigger.outOfVehicleUnit) then
		if (trigger.inVehicleUnit and frame.inVehicle) or (trigger.outOfVehicleUnit and not frame.inVehicle) then passed = true else return end
	end

	-- Player Can Attack
	if trigger.playerCanAttack or trigger.playerCanNotAttack then
		local canAttack = UnitCanAttack('player', frame.unit)
		if (trigger.playerCanAttack and canAttack) or (trigger.playerCanNotAttack and not canAttack) then passed = true else return end
	end

	-- Unit Role
	if E.allowRoles and trigger.unitRole and (trigger.unitRole.tank or trigger.unitRole.healer or trigger.unitRole.damager) then
		local role = UnitGroupRolesAssigned(frame.unit)
		if trigger.unitRole[NP.TriggerConditions.roles[role]] then passed = true else return end
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

	-- NPC Title
	if trigger.hasTitleNPC or trigger.noTitleNPC then
		local npcTitle = E.TagFunctions.GetTitleNPC(frame.unit)
		if (trigger.hasTitleNPC and npcTitle) or (trigger.noTitleNPC and not npcTitle) then passed = true else return end
	end

	-- Classification
	if trigger.classification and (trigger.classification.worldboss or trigger.classification.rareelite or trigger.classification.elite or trigger.classification.rare or trigger.classification.normal or trigger.classification.trivial or trigger.classification.minus) then
		if trigger.classification[frame.classification] then passed = true else return end
	end

	-- Faction
	if trigger.faction and (trigger.faction.Alliance or trigger.faction.Horde or trigger.faction.Neutral) then
		if trigger.faction[frame.battleFaction] then passed = true else return end
	end

	-- My Role
	if trigger.myRole and (trigger.myRole.tank or trigger.myRole.healer or trigger.myRole.damager) then
		if trigger.myRole[NP.TriggerConditions.roles[E.myrole]] then passed = true else return end
	end

	-- Unit Type
	if trigger.nameplateType and trigger.nameplateType.enable then
		if trigger.nameplateType[NP.TriggerConditions.frameTypes[frame.frameType]] then passed = true else return end
	end

	-- Creature Type
	if trigger.creatureType and trigger.creatureType.enable then
		if trigger.creatureType[E.CreatureTypes[frame.creatureType]] then passed = true else return end
	end

	-- Reaction (or Reputation) Type
	if trigger.reactionType and trigger.reactionType.enable then
		if trigger.reactionType[NP.TriggerConditions.reactions[(trigger.reactionType.reputation and frame.repReaction) or frame.reaction]] then passed = true else return end
	end

	-- Threat
	if trigger.threat and trigger.threat.enable then
		if trigger.threat.good or trigger.threat.goodTransition or trigger.threat.badTransition or trigger.threat.bad or trigger.threat.offTank or trigger.threat.offTankGoodTransition or trigger.threat.offTankBadTransition then
			local isTank, offTank, threat = NP:StyleFilterThreatUpdate(frame, frame.unit)
			local checkOffTank = trigger.threat.offTank or trigger.threat.offTankGoodTransition or trigger.threat.offTankBadTransition
			local status = (checkOffTank and offTank and threat and -threat) or (not checkOffTank and ((isTank and NP.TriggerConditions.tankThreat[threat]) or threat)) or nil
			if trigger.threat[NP.TriggerConditions.threat[status]] then passed = true else return end
		end
	end

	-- Raid Target
	if trigger.raidTarget and (trigger.raidTarget.star or trigger.raidTarget.circle or trigger.raidTarget.diamond or trigger.raidTarget.triangle or trigger.raidTarget.moon or trigger.raidTarget.square or trigger.raidTarget.cross or trigger.raidTarget.skull) then
		if trigger.raidTarget[NP.TriggerConditions.raidTargets[frame.raidTargetIndex]] then passed = true else return end
	end

	do
		local which, location = trigger.instanceType, trigger.location
		local activeType = which and (which.none or which.scenario or which.party or which.raid or which.arena or which.pvp)
		local activeID = location and location.instanceIDEnabled

		-- Instance Type
		local instanceName, instanceType, difficultyID, instanceID, _
		if activeType or activeID then
			instanceName, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
		end

		if activeType then
			if which[instanceType] then
				passed = true

				-- Instance Difficulty
				if instanceType == 'raid' or instanceType == 'party' then
					local D = trigger.instanceDifficulty[(instanceType == 'party' and 'dungeon') or instanceType]
					for _, value in next, D do
						if value and not D[NP.TriggerConditions.difficulties[difficultyID]] then return end
					end
				end
			else return end
		end

		-- Location
		if activeID or (location and (location.mapIDEnabled or location.zoneNamesEnabled or location.subZoneNamesEnabled)) then
			if activeID and next(location.instanceIDs) then
				if (instanceID and location.instanceIDs[tostring(instanceID)]) or location.instanceIDs[instanceName] then passed = true else return end
			end
			if location.mapIDEnabled and next(location.mapIDs) then
				if (E.MapInfo.mapID and location.mapIDs[tostring(E.MapInfo.mapID)]) or location.mapIDs[E.MapInfo.name] then passed = true else return end
			end
			if location.zoneNamesEnabled and next(location.zoneNames) then
				if location.zoneNames[E.MapInfo.realZoneText] then passed = true else return end
			end
			if location.subZoneNamesEnabled and next(location.subZoneNames) then
				if location.subZoneNames[E.MapInfo.subZoneText] then passed = true else return end
			end
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

	-- Key Modifier
	if trigger.keyMod and trigger.keyMod.enable then
		for key, value in next, trigger.keyMod do
			local isDown = NP.TriggerConditions.keys[key]
			if value and isDown then
				if isDown() then passed = true else return end
			end
		end
	end

	-- Name or GUID
	if trigger.names then
		for _, value in next, trigger.names do
			if value then -- only run if at least one is selected
				local npcID = frame.npcID and tostring(frame.npcID) or nil
				local name = trigger.names[frame.unitName] or trigger.names[npcID]
				if (not trigger.negativeMatch and name) or (trigger.negativeMatch and not name) then passed = true else return end
				break -- we can execute this once on the first enabled option then kill the loop
			end
		end
	end

	-- Slots
	if trigger.slots then
		for slot, value in next, trigger.slots do
			if value then -- only run if at least one is selected
				if GetInventoryItemID('player', slot) then passed = true else return end
			end
		end
	end

	-- Items
	if trigger.items then
		for item, value in next, trigger.items do
			if value then -- only run if at least one is selected
				local hasItem = C_Item_IsEquippedItem(item)
				if (not trigger.negativeMatch and hasItem) or (trigger.negativeMatch and not hasItem) then passed = true else return end
			end
		end
	end

	-- Known Spells (new talents)
	if trigger.known and trigger.known.spells then
		for spell, value in next, trigger.known.spells do
			if value then -- only run if at least one is selected
				local name, _, _, _, _, _, spellID = E:GetSpellInfo(spell)
				if name then -- check spell name valid
					local known
					if trigger.known.playerSpell then
						known = IsSpellKnown(spellID)
					else
						known = IsSpellInSpellBook(spellID, nil, true)
					end

					if (not trigger.known.notKnown and known) or (trigger.known.notKnown and not known) then passed = true else return end
				end
			end
		end
	end

	-- Casting
	if trigger.casting then
		local cast = trigger.casting
		local allow = not cast.requireStart or (event == 'UNIT_SPELLCAST_START' or event == 'UNIT_SPELLCAST_CHANNEL_START')

		-- Spell
		if cast.spells then
			for _, value in next, cast.spells do
				if value then -- only run if at least one is selected
					local castingSpell = (frame.castSpellID and cast.spells[tostring(frame.castSpellID)]) or cast.spells[frame.spellName]
					if allow and ((cast.notSpell and not castingSpell) or (castingSpell and not cast.notSpell)) then passed = true else return end
					break -- we can execute this once on the first enabled option then kill the loop
				end
			end
		end

		-- Not Status
		if cast.notCasting or cast.notChanneling then
			if cast.notCasting and cast.notChanneling then
				if allow and (not frame.castCasting and not frame.castChanneling) then passed = true else return end
			elseif allow and ((cast.notCasting and not frame.castCasting) or (cast.notChanneling and not frame.castChanneling)) then passed = true else return end
		end

		-- Is Status
		if cast.isCasting or cast.isChanneling then
			if allow and ((cast.isCasting and frame.castCasting) or (cast.isChanneling and frame.castChanneling)) then passed = true else return end
		end

		-- Interruptible
		if cast.interruptible or cast.notInterruptible then
			if (frame.castCasting or frame.castChanneling) and ((cast.interruptible and frame.castInterruptible)
			or allow and ((cast.notInterruptible and not frame.castInterruptible))) then passed = true else return end
		end
	end

	-- Cooldown
	if trigger.cooldowns and trigger.cooldowns.names and next(trigger.cooldowns.names) then
		local cooldown = NP:StyleFilterCooldownCheck(trigger.cooldowns.names, trigger.cooldowns.mustHaveAll)
		if cooldown ~= nil then -- ignore if none are set to ONCD or OFFCD
			if cooldown then passed = true else return end
		end
	end

	-- Buffs
	if trigger.buffs then
		local buffs = trigger.buffs

		-- Has Stealable
		if buffs.hasStealable or buffs.hasNoStealable then
			local isStealable = NP:StyleFilterDispelCheck(frame, event, arg1, arg2, 'HELPFUL')
			if (buffs.hasStealable and isStealable) or (buffs.hasNoStealable and not isStealable) then passed = true else return end
		end

		-- Names / Spell IDs
		if buffs.names and next(buffs.names) then
			local buff = NP:StyleFilterAuraCheck(frame, event, arg1, arg2, 'HELPFUL', buffs.names, frame.BuffTickers, buffs.mustHaveAll, buffs.missing, buffs.minTimeLeft, buffs.maxTimeLeft, buffs.fromMe, buffs.fromPet, buffs.onMe, buffs.onPet)
			if buff ~= nil then -- ignore if none are selected
				if buff then passed = true else return end
			end
		end
	end

	-- Debuffs
	if trigger.debuffs then
		local debuffs = trigger.debuffs

		-- Has Dispellable
		if debuffs.hasDispellable or debuffs.hasNoDispellable then
			local canDispel = NP:StyleFilterDispelCheck(frame, event, arg1, arg2, 'HARMFUL')
			if (debuffs.hasDispellable and canDispel) or (debuffs.hasNoDispellable and not canDispel) then passed = true else return end
		end

		if debuffs.names and next(debuffs.names) then
			-- Names / Spell IDs
			local debuff = NP:StyleFilterAuraCheck(frame, event, arg1, arg2, 'HARMFUL', debuffs.names, frame.DebuffTickers, debuffs.mustHaveAll, debuffs.missing, debuffs.minTimeLeft, debuffs.maxTimeLeft, debuffs.fromMe, debuffs.fromPet, debuffs.onMe, debuffs.onPet)
			if debuff ~= nil then -- ignore if none are selected
				if debuff then passed = true else return end
			end
		end
	end

	-- BossMod Auras
	if frame.BossMods and trigger.bossMods and trigger.bossMods.enable then
		local element, m = frame.BossMods, trigger.bossMods
		local icons = next(element.activeIcons)

		if m.hasAura or m.missingAura then
			if (m.hasAura and icons) or (m.missingAura and not icons) then passed = true else return end
		elseif icons and m.auras then
			for texture, value in next, m.auras do
				if value then -- only if they are turned on
					local active = element.activeIcons[texture]
					if (not m.missingAuras and active) or (m.missingAuras and not active) then passed = true else return end
					break -- we can execute this once on the first enabled option then kill the loop
				end
			end
		end
	end

	-- Plugin Callback
	if NP.StyleFilterCustomChecks then
		for _, customCheck in next, NP.StyleFilterCustomChecks do
			local custom = customCheck(frame, filter, trigger, event)
			if custom ~= nil then -- ignore if nil return
				if custom then passed = true else return end
			end
		end
	end

	-- Pass it along
	return passed
end

function NP:StyleFilterTempElement(object, actions)
	if not actions then return wipe(object) end

	object.glow = actions.glow and actions.glow.enable or nil
	object.colors = actions.colors and actions.colors.enable or nil
	object.border = actions.border and actions.border.enable or nil
	object.texture = actions.texture and actions.texture.enable or nil
	object.flash = actions.flash and actions.flash.enable or nil

	return object
end

function NP:StyleFilterTempGeneral(object, actions)
	if not actions then return wipe(object) end

	object.visibility = actions.hide or nil
	object.nameOnly = actions.nameOnly or nil
	object.portrait = actions.usePortrait or nil
	object.scale = actions.scale ~= 1 or nil
	object.alpha = actions.alpha ~= -1 or nil
	object.sound = actions.sound and actions.sound.enable and actions.sound.soundFile ~= '' or nil

	return object
end

function NP:StyleFilterTempTags(object, actions)
	if not actions or not actions.tags then return wipe(object) end

	object.name = actions.tags.name and actions.tags.name ~= '' or nil
	object.power = actions.tags.power and actions.tags.power ~= '' or nil
	object.health = actions.tags.health and actions.tags.health ~= '' or nil
	object.title = actions.tags.title and actions.tags.title ~= '' or nil
	object.level = actions.tags.level and actions.tags.level ~= '' or nil

	return object
end

function NP:StyleFilterPass(frame, event, filter, temp)
	local db = NP:PlateDB(frame)

	-- populate the temporary tables for StyleFilterChanges
	NP:StyleFilterTempElement(temp.health, db.health.enable and filter.actions.health)
	NP:StyleFilterTempElement(temp.power, db.power.enable and filter.actions.power)
	NP:StyleFilterTempElement(temp.castbar, db.castbar.enable and filter.actions.castbar)
	NP:StyleFilterTempGeneral(temp.general, filter.actions)
	NP:StyleFilterTempTags(temp.tags, filter.actions)

	-- use this to export what is changed
	E:CopyTable(frame.StyleFilterChanges, temp)

	-- execute some changes
	NP:StyleFilterSetChanges(frame, event, filter, temp)
end

function NP:StyleFilterSort(place)
	if self[2] and place[2] then
		return self[2] > place[2] -- Sort by priority: 1=first, 2=second, 3=third, etc
	end
end

function NP:StyleFilterVehicleFunction(_, unit)
	unit = unit or self.unit
	self.inVehicle = (E.Retail or E.Mists) and UnitInVehicle(unit) or nil
end

function NP:StyleFilterTargetFunction(_, unit)
	unit = unit or self.unit
	self.isTargetingMe = UnitIsUnit(unit..'target', 'player') or nil
end

function NP:StyleFilterCastingFunction(event, unit, guid, spellID)
	if event == 'UNIT_SPELLCAST_INTERRUPTIBLE' then
		self.castInterruptible = true
	elseif event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE' then
		self.castInterruptible = nil
	else
		self.castEmpowering = event == 'UNIT_SPELLCAST_EMPOWER_START' or nil
		self.castChanneling = event == 'UNIT_SPELLCAST_CHANNEL_START' or nil
		self.castCasting = event == 'UNIT_SPELLCAST_START' or nil

		local _, notInterruptible
		if self.castChanneling or self.castEmpowering then
			_, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
		elseif self.castCasting then
			_, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
		end

		local active = self.castChanneling or self.castCasting or self.castEmpowering
		self.castSpellID = (active and spellID) or nil
		self.castGUID = (active and guid) or nil
		self.castInterruptible = (active and not notInterruptible) or nil
	end
end

NP.StyleFilterCastEvents = {
	UNIT_SPELLCAST_START = 1,			-- start
	UNIT_SPELLCAST_CHANNEL_START = 1,
	UNIT_SPELLCAST_STOP = 1,			-- stop
	UNIT_SPELLCAST_CHANNEL_STOP = 1,
	UNIT_SPELLCAST_FAILED = 1,			-- fail
	UNIT_SPELLCAST_INTERRUPTED = 1,
	UNIT_SPELLCAST_INTERRUPTIBLE = 1,
	UNIT_SPELLCAST_NOT_INTERRUPTIBLE = 1,
	UNIT_SPELLCAST_EMPOWER_START = E.Retail and 1 or nil,
	UNIT_SPELLCAST_EMPOWER_STOP = E.Retail and 1 or nil
}

NP.StyleFilterEventFunctions = { -- a prefunction to the injected ouf watch
	PLAYER_TARGET_CHANGED = function(self)
		self.isTarget = self.unit and UnitIsUnit(self.unit, 'target') or nil
	end,

	PLAYER_FOCUS_CHANGED = function(self)
		self.isFocused = self.unit and UnitIsUnit(self.unit, 'focus') or nil
	end,

	RAID_TARGET_UPDATE = function(self)
		self.raidTargetIndex = self.unit and GetRaidTargetIndex(self.unit) or nil
	end,

	UNIT_TARGET = NP.StyleFilterTargetFunction,
	UNIT_THREAT_LIST_UPDATE = NP.StyleFilterTargetFunction,

	VEHICLE_UPDATE = NP.StyleFilterVehicleFunction,
	UNIT_ENTERED_VEHICLE = NP.StyleFilterVehicleFunction,
	UNIT_EXITED_VEHICLE = NP.StyleFilterVehicleFunction,
}

for event in next, NP.StyleFilterCastEvents do
	NP.StyleFilterEventFunctions[event] = NP.StyleFilterCastingFunction
end

NP.StyleFilterSetVariablesAllowed = {
	UNIT_TARGET = true,
	VEHICLE_UPDATE = true,
	UNIT_SPELLCAST_START = true,
	PLAYER_TARGET_CHANGED = true,
	PLAYER_FOCUS_CHANGED = true,
	RAID_TARGET_UPDATE = true
}

function NP:StyleFilterSetVariables(nameplate)
	if nameplate == NP.TestFrame then return end

	for event in next, NP.StyleFilterSetVariablesAllowed do
		local eventFunc = NP.StyleFilterEventFunctions[event]
		if eventFunc then -- we only need to call each function once on added
			eventFunc(nameplate)
		end
	end
end

function NP:StyleFilterClearVariables(nameplate)
	if nameplate == NP.TestFrame then return end

	nameplate.isTarget = nil
	nameplate.isFocused = nil
	nameplate.inVehicle = nil
	nameplate.isTargetingMe = nil
	nameplate.raidTargetIndex = nil
	nameplate.threatScale = nil

	-- casting stuff
	nameplate.castInterruptible = nil
	nameplate.castCasting = nil
	nameplate.castChanneling = nil
	nameplate.castEmpowering = nil
	nameplate.castSpellID = nil
	nameplate.castGUID = nil
end

NP.StyleFilterTriggerList = {} -- configured filters enabled with sorted priority
NP.StyleFilterTriggerEvents = {} -- events required by the filter that we need to watch for
NP.StyleFilterPlateEvents = {} -- events watched inside of ouf, which is called on the nameplate itself, updated by StyleFilterWatchEvents
NP.StyleFilterAuraEvents = { -- events that can help populate aura cache
	NAME_PLATE_UNIT_ADDED = true,
	UNIT_AURA = true
}

NP.StyleFilterDefaultEvents = { -- list of events style filter uses to populate plate events (updated during StyleFilterEvents), true if unitless
	-- existing:
	UNIT_AURA = false,
	UNIT_CONNECTION = false,
	UNIT_DISPLAYPOWER = false,
	UNIT_MAXHEALTH = false,
	UNIT_HEALTH = false,
	UNIT_NAME_UPDATE = false,
	UNIT_PET = false,
	UNIT_POWER_UPDATE = false,
	-- mod events:
	NAME_PLATE_UNIT_ADDED = true,
	NAME_PLATE_UNIT_REMOVED = true,
	INCOMING_RESURRECT_CHANGED = false,
	GROUP_ROSTER_UPDATE = true,
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

if E.Classic then
	NP.StyleFilterDefaultEvents.UNIT_HEALTH_FREQUENT = false
end

for event in next, NP.StyleFilterCastEvents do
	NP.StyleFilterDefaultEvents[event] = false
end

function NP:StyleFilterWatchEvents()
	for event in next, NP.StyleFilterDefaultEvents do
		NP.StyleFilterPlateEvents[event] = NP.StyleFilterTriggerEvents[event] and true or nil
	end
end

function NP:StyleFilterConfigure()
	local events = NP.StyleFilterTriggerEvents
	local list = NP.StyleFilterTriggerList
	wipe(events)
	wipe(list)

	if NP.db.filters then
		for filterName, filter in next, E.global.nameplates.filters do
			local t, db = filter.triggers, NP.db.filters[filterName]
			if t and db and db.triggers and db.triggers.enable then
				tinsert(list, {filterName, t.priority or 1})

				-- NOTE: -1 is force, 0 for fake events, 1 is real events, 2 has a unitToken but cant use RegisterUnitEvent
				events.PLAYER_TARGET_CHANGED = 1
				events.NAME_PLATE_UNIT_ADDED = 2
				events.NAME_PLATE_UNIT_REMOVED = 2
				events.UNIT_FACTION = 1 -- frameType can change here
				events.FAKE_AuraWaitTimer = 0 -- for minTimeLeft and maxTimeLeft aura trigger
				events.FAKE_BossModAuras = 0 -- support to trigger filters based on Boss Mod Auras
				events.ForceUpdate = -1

				if t.casting then
					local spell
					if t.casting.spells then
						for _, value in next, t.casting.spells do
							if value then
								spell = true
								break
					end end end

					if spell or (t.casting.interruptible or t.casting.notInterruptible or t.casting.isCasting or t.casting.isChanneling or t.casting.notCasting or t.casting.notChanneling) then
						for event in next, NP.StyleFilterCastEvents do
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
					events.UNIT_HEALTH = 1

					if E.Classic then
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

				if t.inParty or t.notInParty or t.inRaid or t.notInRaid or (E.Retail and t.unitRole and (t.unitRole.tank or t.unitRole.healer or t.unitRole.damager)) then
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
					events.UNIT_FLAGS = 1
				end

				if t.buffs and (t.buffs.hasStealable or t.buffs.hasNoStealable) then
					events.UNIT_AURA = 1
				end

				if not events.UNIT_NAME_UPDATE and t.names then
					for _, value in next, t.names do
						if value then
							events.UNIT_NAME_UPDATE = 1
							break
				end end end

				if not events.PLAYER_EQUIPMENT_CHANGED and t.slots then
					for _, value in next, t.slots do
						if value then
							events.PLAYER_EQUIPMENT_CHANGED = 1
							break
				end end end

				if not events.PLAYER_EQUIPMENT_CHANGED and t.items then
					for _, value in next, t.items do
						if value then
							events.PLAYER_EQUIPMENT_CHANGED = 1
							break
				end end end

				if not events.SPELL_UPDATE_COOLDOWN and t.cooldowns and t.cooldowns.names then
					for _, value in next, t.cooldowns.names do
						if value == 'ONCD' or value == 'OFFCD' then
							events.SPELL_UPDATE_COOLDOWN = 1
							break
				end end end

				if not events.UNIT_AURA and t.buffs and t.buffs.names then
					for _, value in next, t.buffs.names do
						if value then
							events.UNIT_AURA = 1
							break
				end end end

				if not events.UNIT_AURA and t.debuffs and t.debuffs.names then
					for _, value in next, t.debuffs.names do
						if value then
							events.UNIT_AURA = 1
							break
				end end end
	end end end

	NP:StyleFilterWatchEvents()

	if next(list) then
		sort(list, NP.StyleFilterSort) -- sort by priority
	end
end

function NP:StyleFilterHiddenState(changes)
	local general = changes and changes.general
	return general and ((general.nameOnly and general.visibility and 3) or (general.nameOnly and 2) or (general.visibility and 1))
end

do
	local temp = { general = {}, tags = {}, health = {}, power = {}, castbar = {} } -- states

	function NP:StyleFilterUpdate(frame, event, arg1, arg2)
		if frame == NP.TestFrame or not frame.StyleFilterChanges or not NP.StyleFilterTriggerEvents[event] then return end

		-- store the previous visibility state
		local state = NP:StyleFilterHiddenState(frame.StyleFilterChanges)

		-- reset the plate back
		if next(frame.StyleFilterChanges) then
			NP:StyleFilterClearChanges(frame)
		end

		if event ~= 'NAME_PLATE_UNIT_REMOVED' then
			for filterNum in next, NP.StyleFilterTriggerList do
				local filter = E.global.nameplates.filters[NP.StyleFilterTriggerList[filterNum][1]]
				if filter and NP:StyleFilterConditionCheck(frame, event, arg1, arg2, filter, filter.triggers) then
					NP:StyleFilterPass(frame, event, filter, temp)
				end
			end
		end

		NP:StyleFilterClearVisibility(frame, event, state)
	end
end

do -- oUF style filter inject watch functions without actually registering any events
	function NP:StyleFilterExecuteUpdate(event, arg1, arg2, ...)
		local eventFunc = NP.StyleFilterEventFunctions[event]
		if eventFunc then
			eventFunc(self, event, arg1, arg2, ...)
		end

		local trigger = NP.StyleFilterTriggerEvents[event]
		if not trigger then return end -- no trigger for this event

		local verifyUnit = (trigger ~= 2 and NP.StyleFilterDefaultEvents[event]) or (arg1 and arg1 == self.unit)
		if not verifyUnit then return end -- this event doesnt match the unit, this checks unitless

		-- REMOVED does not make it here, so we call inside of NamePlateCallBack

		local allowUpdate = not NP.StyleFilterAuraEvents[event] or not ElvUF:ShouldSkipAuraUpdate(self, event, arg1, arg2)
		if not allowUpdate then return end -- should we allow the update, aura events that can help populate cache

		NP:StyleFilterUpdate(self, event, arg1, arg2)
	end

	local update = NP.StyleFilterExecuteUpdate
	function NP:StyleFilterExecuteCall(frame, ...)
		for _, func in next, self do
			func(frame, ...)
		end
	end

	local metatable = { __call = NP.StyleFilterExecuteCall }
	function NP:StyleFilterExecuteRegister(frame, event, remove)
		local curev = frame[event]
		if curev then
			local kind = type(curev)
			if kind == 'function' and curev ~= update then
				frame[event] = setmetatable({curev, update}, metatable)
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

	function NP:StyleFilterIsWatching(frame, event)
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

	function NP:StyleFilterEventWatch(frame, disable)
		if frame == NP.TestFrame then return end

		for event in next, NP.StyleFilterDefaultEvents do
			local holdsEvent = NP:StyleFilterIsWatching(frame, event)
			if disable then
				if holdsEvent then
					NP:StyleFilterExecuteRegister(frame, event, true)
				end
			elseif NP.StyleFilterPlateEvents[event] then
				if not holdsEvent then
					NP:StyleFilterExecuteRegister(frame, event)
				end
			elseif holdsEvent then
				NP:StyleFilterExecuteRegister(frame, event, true)
	end end end

	function NP:StyleFilterEventRegister(nameplate, event, unitless, func, objectEvent)
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
function NP:StyleFilterEvents(nameplate)
	if nameplate == NP.TestFrame then return end

	-- happy little tables
	nameplate.StyleFilterChanges = {}
	nameplate.DebuffTickers = {}
	nameplate.BuffTickers = {}

	-- we may fire events before having any aura data for the unit
	-- populate an empty table because not all events update the cache
	ElvUF:CreateUnitAuraInfo(nameplate.unit)

	-- add events to be watched
	for event, unitless in next, NP.StyleFilterDefaultEvents do
		NP:StyleFilterEventRegister(nameplate, event, unitless)
	end

	-- object event pathing (these update after MapInfo updates), these events are not added onto the nameplate itself
	NP:StyleFilterEventRegister(nameplate,'LOADING_SCREEN_DISABLED', nil, nil, E.MapInfo)
	NP:StyleFilterEventRegister(nameplate,'ZONE_CHANGED_NEW_AREA', nil, nil, E.MapInfo)
	NP:StyleFilterEventRegister(nameplate,'ZONE_CHANGED_INDOORS', nil, nil, E.MapInfo)
	NP:StyleFilterEventRegister(nameplate,'ZONE_CHANGED', nil, nil, E.MapInfo)
end

function NP:StyleFilterAddCustomCheck(name, func)
	if not NP.StyleFilterCustomChecks then
		NP.StyleFilterCustomChecks = {}
	end

	NP.StyleFilterCustomChecks[name] = func
end

function NP:StyleFilterRemoveCustomCheck(name)
	if not NP.StyleFilterCustomChecks then
		return
	end

	NP.StyleFilterCustomChecks[name] = nil
end

function NP:PLAYER_LOGOUT()
	NP:StyleFilterClearDefaults(E.global.nameplates.filters)
end

function NP:StyleFilterClearDefaults(tbl)
	for filterName, filterTable in next, tbl do
		if G.nameplates.filters[filterName] then
			local defaultTable = E:CopyTable({}, E.StyleFilterDefaults)
			E:CopyTable(defaultTable, G.nameplates.filters[filterName])
			E:RemoveDefaults(filterTable, defaultTable)
		else
			E:RemoveDefaults(filterTable, E.StyleFilterDefaults)
		end
	end
end

function NP:StyleFilterCopyDefaults(tbl)
	return E:CopyDefaults(tbl or {}, E.StyleFilterDefaults)
end

function NP:StyleFilterInitialize()
	for _, filterTable in next, E.global.nameplates.filters do
		NP:StyleFilterCopyDefaults(filterTable)
	end
end
