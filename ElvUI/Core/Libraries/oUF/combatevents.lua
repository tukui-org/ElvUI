local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local frame_metatable = Private.frame_metatable

local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo

local event_metatable = {
	__call = function(funcs, ...)
		for self, func in next, funcs do
			if (self:IsVisible()) then
				func(self, ...)
			end
		end
	end,
}

local self_metatable = {
	__call = function(funcs, self, ...)
		for _, func in next, funcs do
			func(self, ...)
		end
	end
}

local listener = CreateFrame('Frame')
listener.activeEvents = 0

local function filter(_, event, ...)
	if(listener[event]) then
		listener[event](event, ...)
	end
end

listener:SetScript('OnEvent', function(self, event)
	filter(CombatLogGetCurrentEventInfo())
end)

--[[ CombatEvents: frame:RegisterCombatEvent(event, handler)
Used to register a frame for a combat log event and add an event handler.

* self     - frame that will be registered for the given event
* event    - name of the combat log event to register (string)
* handler  - function which will be executed when the combat log event fires. Multiple handlers can be added for the
             same frame and event (function)
--]]
function frame_metatable.__index:RegisterCombatEvent(event, handler)
	argcheck(event, 2, 'string')
	argcheck(handler, 3, 'function')

	if(not listener[event]) then
		listener[event] = setmetatable({}, event_metatable)
		listener.activeEvents = listener.activeEvents + 1
	end

	local current = listener[event][self]

	if(current) then
		for _, func in next, current do
			if(func == handler) then return end
		end

		table.insert(current, handler)
	else
		-- even with a single handler we want to make sure the frame is visible
		listener[event][self] = setmetatable({handler}, self_metatable)
	end

	if(listener.activeEvents > 0) then
		listener:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	end
end

--[[ CombatEvents: frame:UnregisterCombatEvent(event, handler)
Used to remove a function from the event handler list for a combat log event.

* self    - the frame registered for the event
* event   - name of the registered combat log event (string)
* handler - function to be removed from the list of event handlers
--]]
function frame_metatable.__index:UnregisterCombatEvent(event, handler)
	argcheck(event, 2, 'string')

	if(not listener[event]) then return end

	local cleanUp = false
	local current = listener[event][self]
	if(current) then
		for i, func in next, current do
			if(func == handler) then
				current[i] = nil

				break
			end
		end

		if(not next(current)) then
			cleanUp = true
		end
	end

	if(cleanUp) then
		listener[event][self] = nil

		if(not next(listener[event])) then
			listener[event] = nil
			listener.activeEvents = listener.activeEvents - 1

			if(listener.activeEvents <= 0) then
				listener:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
			end
		end
	end
end
