local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck

local queue = {}
local factory = CreateFrame('Frame')
factory:SetScript('OnEvent', function(self, event, ...)
	return self[event](self, event, ...)
end)

factory:RegisterEvent('PLAYER_LOGIN')
factory.active = true

function factory:PLAYER_LOGIN()
	if(not self.active) then return end

	for _, func in next, queue do
		func(oUF)
	end

	-- Avoid creating dupes.
	table.wipe(queue)
end

--[[ Factory: oUF:Factory(func)
Used to call a function directly if the current character is logged in and the factory is active. Else the function is
queued up to be executed at a later time (upon PLAYER_LOGIN by default).

* self - the global oUF object
* func - function to be executed or delayed (function)
--]]
function oUF:Factory(func)
	argcheck(func, 2, 'function')

	-- Call the function directly if we're active and logged in.
	if(IsLoggedIn() and factory.active) then
		return func(self)
	else
		table.insert(queue, func)
	end
end

--[[ Factory: oUF:EnableFactory()
Used to enable the factory.

* self - the global oUF object
--]]
function oUF:EnableFactory()
	factory.active = true
end

--[[ Factory: oUF:DisableFactory()
Used to disable the factory.

* self - the global oUF object
--]]
function oUF:DisableFactory()
	factory.active = nil
end

--[[ Factory: oUF:RunFactoryQueue()
Used to try to execute queued up functions. The current player must be logged in and the factory must be active for
this to succeed.

* self - the global oUF object
--]]
function oUF:RunFactoryQueue()
	factory:PLAYER_LOGIN()
end
