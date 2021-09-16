local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local next = next
local tremove = tremove
local UnitAura = UnitAura
local UnitExists = UnitExists
local CreateFrame = CreateFrame

local info = { units = {}, frames = {} }
E.AuraInfo = info

function E:UnitAura(unit, index, filter)
	if not UnitExists(unit) then return end

	local data = info.units[unit]
	local auras = data and data[filter]
	if not auras then return end

	return auras[index]
end

function E:AuraInfo_FindAura(data, value, key)
	for _, aura in next, data do
		if value == aura[key] then
			return aura
		end
	end
end

function E:AuraInfo_GetAuraByID(unit, spellID, filter)
	local data = info.units[unit]
	if not data then return end

	if filter then
		local aura = E:AuraInfo_FindAura(data[filter], spellID, 'spellID')
		if aura then return aura end
	else
		local buff = E:AuraInfo_FindAura(data.HELPFUL, spellID, 'spellID')
		if buff then return buff end

		local debuff = E:AuraInfo_FindAura(data.HARMFUL, spellID, 'spellID')
		if debuff then return debuff end
	end
end

function E:AuraInfo_GetAuraByName(unit, name, filter)
	local data = info.units[unit]
	if not data then return end

	if filter then
		local aura = E:AuraInfo_FindAura(data[filter], name, 'name')
		if aura then return aura end
	else
		local buff = E:AuraInfo_FindAura(data.HELPFUL, name, 'name')
		if buff then return buff end

		local debuff = E:AuraInfo_FindAura(data.HARMFUL, name, 'name')
		if debuff then return debuff end
	end
end

function E:AuraInfo_AuraCollect(unit, filter)
	if not info.units[unit] then info.units[unit] = {} end
	if not info.units[unit][filter] then info.units[unit][filter] = {} end

	return E:AuraInfo_SetInfo(unit, filter, 1, UnitAura(unit, 1, filter)) -- 1) jump in
end

function E:AuraInfo_UnitAura(_, unit)
	E:AuraInfo_AuraCollect(unit, 'HELPFUL')
	E:AuraInfo_AuraCollect(unit, 'HARMFUL')

	for frame, funcs in next, info.frames do
		if frame:IsVisible() then
			for func in next, funcs do
				func(frame, 'UNIT_AURA', unit)
			end
		end
	end
end

function E:AuraInfo_SetInfo(unit, filter, index, name, ...)
	local auras = info.units[unit][filter]

	if not name then -- 3) hit rock bottom
		while auras[index] do
			tremove(auras, index)
		end

		return
	end

	local i = index + 1
	E:AuraInfo_PopulateAura(auras, index, name, ...)
	E:AuraInfo_SetInfo(unit, filter, i, UnitAura(unit, i, filter)) -- 2) jump again :)
end

function E:AuraInfo_PopulateAura(auras, index, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3)
	if not auras[index] then auras[index] = {} end

	local aura = auras[index]
	aura.name = name
	aura.icon = icon
	aura.count = count
	aura.debuffType = debuffType
	aura.duration = duration
	aura.expirationTime = expirationTime
	aura.source = source
	aura.isStealable = isStealable
	aura.nameplateShowPersonal = nameplateShowPersonal
	aura.spellID = spellID
	aura.canApplyAura = canApplyAura
	aura.isBossDebuff = isBossDebuff
	aura.castByPlayer = castByPlayer
	aura.nameplateShowAll = nameplateShowAll
	aura.timeMod = timeMod
	aura.effect1 = effect1
	aura.effect2 = effect2
	aura.effect3 = effect3
end

function E:AuraInfo_OnUpdate(elapsed)
	if self.elapsed > 0.1 then
		for frame in next, self.frames do
			if frame:IsVisible() then
				E:AuraInfo_UnitAura('OnUpdate', frame.unit)
			end
		end

		self.elapsed = 0
	else
		self.elapsed = self.elapsed + elapsed
	end
end

local watcher = CreateFrame('Frame')
watcher:SetScript('OnUpdate', E.AuraInfo_OnUpdate)
watcher:Hide()
watcher.frames = {}
watcher.elapsed = -1

function E:AuraInfo_SetFunction(frame, func, register)
	if register and not info.frames[frame] then
		info.frames[frame] = {}
	end

	local funcs = info.frames[frame]
	if funcs then
		funcs[func] = register or nil

		if not next(funcs) then
			info.frames[frame] = nil
		end
	end

	-- check watcher
	watcher.frames[frame] = frame.onUpdateFrequency

	if next(watcher.frames) then
		watcher:Show()
	else
		watcher:Hide()
	end
end

function E:AuraInfo_RemoveUnit(unit)
	info.units[unit] = nil
end

function E:AuraInfo_PlayerTargetChanged(event)
	E:AuraInfo_UnitAura(event, 'target')
end

function E:AuraInfo_PlayerFocusChanged(event)
	E:AuraInfo_UnitAura(event, 'focus')
end

function E:AuraInfo_TargetChanged(event, unit)
	E:AuraInfo_UnitAura(event, unit)
end

function E:AuraInfo_NameplateAdded(event, unit)
	E:AuraInfo_UnitAura(event, unit)
end

function E:AuraInfo_NameplateRemoved(_, unit)
	E:AuraInfo_RemoveUnit(unit)
end

E:RegisterEvent('UNIT_AURA', 'AuraInfo_UnitAura')
E:RegisterEvent('UNIT_TARGET', 'AuraInfo_TargetChanged')
E:RegisterEvent('PLAYER_FOCUS_CHANGED', 'AuraInfo_PlayerFocusChanged')
E:RegisterEvent('PLAYER_TARGET_CHANGED', 'AuraInfo_PlayerTargetChanged')
--E:RegisterEvent('NAME_PLATE_UNIT_REMOVED', 'AuraInfo_NameplateRemoved')
E:RegisterEvent('NAME_PLATE_UNIT_ADDED', 'AuraInfo_NameplateAdded')
E:AuraInfo_UnitAura('UNIT_AURA', 'player')
