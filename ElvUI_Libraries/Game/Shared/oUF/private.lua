local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local print = print
local type, assert = type, assert
local select, error = select, error
local pcall, xpcall = pcall, xpcall
local strjoin, format = strjoin, format
local geterrorhandler = geterrorhandler
local debugstack = debugstack

local UnitHealth = UnitHealth
local UnitSelectionType = UnitSelectionType
local UnitThreatSituation = UnitThreatSituation

function Private.argcheck(value, num, ...)
	assert(type(num) == 'number', "Bad argument #2 to 'argcheck' (number expected, got " .. type(num) .. ')')

	for i = 1, select('#', ...) do
		if(type(value) == select(i, ...)) then return end
	end

	local types = strjoin(', ', ...)
	local name = debugstack(2,2,0):match(": in function [`<](.-)['>]")
	error(format("Bad argument #%d to '%s' (%s expected, got %s)", num, name, types, type(value)), 3)
end

function Private.print(...)
	print('|cff33ff99oUF:|r', ...)
end

function Private.nierror(...)
	return geterrorhandler()(...)
end

function Private.xpcall(func, ...)
	return xpcall(func, Private.nierror, ...)
end

function Private.validateToken(unit)
	if UnitHealth(unit) then
		return unit
	end
end

do
	local validator = CreateFrame('Frame')
	function Private.validateUnit(unit)
		local ok = pcall(validator.RegisterUnitEvent, validator, 'UNIT_HEALTH', unit)
		if not ok then return end

		local _, unit1 = validator:IsEventRegistered('UNIT_HEALTH')
		validator:UnregisterEvent('UNIT_HEALTH')

		return not not unit1
	end

	local validEvent = {}
	function Private.validateEvent(event)
		local ok = validEvent[event]

		if ok == nil then
			ok = xpcall(validator.RegisterEvent, Private.nierror, validator, event)

			if ok then
				validator:UnregisterEvent(event)
			end

			validEvent[event] = ok
		end

		return ok
	end

	function Private.isUnitEvent(event, unit)
		local ok = pcall(validator.RegisterUnitEvent, validator, event, unit)
		if ok then
			validator:UnregisterEvent(event)
		end

		return ok
	end
end

do
	local validSelectionTypes = {}
	for _, selectionType in next, oUF.Enum.SelectionType do
		validSelectionTypes[selectionType] = selectionType
	end

	function Private.unitSelectionType(unit, considerHostile)
		if(considerHostile and UnitThreatSituation('player', unit)) then
			return 0
		elseif oUF.isModern then
			return validSelectionTypes[UnitSelectionType(unit, true)]
		end
	end
end
