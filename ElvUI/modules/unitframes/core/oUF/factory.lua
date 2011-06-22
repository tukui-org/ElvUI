local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck

local _QUEUE = {}
local _FACTORY = CreateFrame'Frame'
_FACTORY:SetScript('OnEvent', Private.OnEvent)
_FACTORY:RegisterEvent'PLAYER_LOGIN'
_FACTORY.active = true

function _FACTORY:PLAYER_LOGIN()
	if(not self.active) then return end

	for _, func in next, _QUEUE do
		func(oUF)
	end

	-- Avoid creating dupes.
	wipe(_QUEUE)
end

function oUF:Factory(func)
	argcheck(func, 2, 'function')

	-- Call the function directly if we're active and logged in.
	if(IsLoggedIn() and _FACTORY.active) then
		return func(self)
	else
		table.insert(_QUEUE, func)
	end
end

function oUF:EnableFactory()
	_FACTORY.active = true
end

function oUF:DisableFactory()
	_FACTORY.active = nil
end

function oUF:RunFactoryQueue()
	_FACTORY:PLAYER_LOGIN()
end
