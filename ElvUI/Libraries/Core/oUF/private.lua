local _, ns = ...
local Private = ns.oUF.Private

function Private.argcheck(value, num, ...)
	assert(type(num) == 'number', "Bad argument #2 to 'argcheck' (number expected, got " .. type(num) .. ')')

	for i = 1, select('#', ...) do
		if(type(value) == select(i, ...)) then return end
	end

	local types = string.join(', ', ...)
	local name = debugstack(2,2,0):match(": in function [`<](.-)['>]")
	error(string.format("Bad argument #%d to '%s' (%s expected, got %s)", num, name, types, type(value)), 3)
end

function Private.print(...)
	print('|cff33ff99oUF:|r', ...)
end

function Private.error(...)
	Private.print('|cffff0000Error:|r ' .. string.format(...))
end

function Private.nierror(...)
	return geterrorhandler()(...)
end

function Private.unitExists(unit)
	return unit and (UnitExists(unit) or ShowBossFrameWhenUninteractable(unit))
end

local validator = CreateFrame('Frame')

function Private.validateUnit(unit)
	local isOK, _ = pcall(validator.RegisterUnitEvent, validator, 'UNIT_HEALTH', unit)
	if(isOK) then
		_, unit = validator:IsEventRegistered('UNIT_HEALTH')
		validator:UnregisterEvent('UNIT_HEALTH')

		return not not unit
	end
end

local selectionTypes = {
	[ 0] = 0,
	[ 1] = 1,
	[ 2] = 2,
	[ 3] = 3,
	[ 4] = 4,
	[ 5] = 5,
	[ 6] = 6,
	[ 7] = 7,
	[ 8] = 8,
	[ 9] = 9,
	-- [10] = 10, -- unavailable to players
	-- [11] = 11, -- unavailable to players
	-- [12] = 12, -- inconsistent due to bugs and its reliance on cvars
	[13] = 13,
}

function Private.unitSelectionType(unit, considerHostile)
	if(considerHostile and UnitThreatSituation('player', unit)) then
		return 0
	else
		return selectionTypes[UnitSelectionType(unit, true)]
	end
end

function Private.xpcall(func, ...)
	return xpcall(func, Private.nierror, ...)
end

function Private.validateEvent(event)
	local isOK = xpcall(validator.RegisterEvent, Private.nierror, validator, event)
	if(isOK) then
		validator:UnregisterEvent(event)
	end

	return isOK
end

function Private.isUnitEvent(event, unit)
	local isOK = pcall(validator.RegisterUnitEvent, validator, event, unit)
	if(isOK) then
		validator:UnregisterEvent(event)
	end

	return isOK
end
