local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local validateEvent = Private.validateEvent
local validateUnit = Private.validateUnit
local isUnitEvent = Private.isUnitEvent
local frame_metatable = Private.frame_metatable

-- Original event methods
local registerEvent = frame_metatable.__index.RegisterEvent
local registerUnitEvent = frame_metatable.__index.RegisterUnitEvent
local unregisterEvent = frame_metatable.__index.UnregisterEvent
local isEventRegistered = frame_metatable.__index.IsEventRegistered

-- to update unit frames correctly, some events need to be registered for
-- a specific combination of primary and secondary units
local secondaryUnits = {
	UNIT_ENTERED_VEHICLE = {
		pet = 'player',
	},
	UNIT_EXITED_VEHICLE = {
		pet = 'player',
	},
	UNIT_PET = {
		pet = 'player',
	},
}

function Private.UpdateUnits(frame, unit, realUnit)
	if(unit == realUnit) then
		realUnit = nil
	end

	if(frame.unit ~= unit or frame.realUnit ~= realUnit) then
		-- don't let invalid units in, otherwise unit events will end up being
		-- registered as unitless
		if(frame.unitEvents and validateUnit(unit)) then
			local resetRealUnit = false

			for event in next, frame.unitEvents do
				if(not realUnit and secondaryUnits[event]) then
					realUnit = secondaryUnits[event][unit]
					resetRealUnit = true
				end

				local registered, unit1, unit2 = isEventRegistered(frame, event)
				-- we don't want to re-register unitless/shared events in case
				-- someone added them by hand to the unitEvents table
				if(not registered or unit1 and (unit1 ~= unit or unit2 ~= realUnit)) then
					-- BUG: passing explicit nil units to RegisterUnitEvent
					-- makes it silently fall back to RegisterEvent, using ''
					-- instead of explicit nils doesn't cause this behaviour
					registerUnitEvent(frame, event, unit, realUnit or '')
				end

				if(resetRealUnit) then
					realUnit = nil
					resetRealUnit = false
				end
			end
		end

		frame.unit = unit
		frame.realUnit = realUnit
		frame.id = unit:match('^.-(%d+)')

		return true
	end
end

local function onEvent(self, event, ...)
	if(self:IsVisible()) then
		return self[event](self, event, ...)
	end
end

local event_metatable = {
	__call = function(funcs, self, ...)
		for _, func in next, funcs do
			func(self, ...)
		end
	end,
}

--[[ Events: frame:RegisterEvent(event, func, unitless)
Used to register a frame for a game event and add an event handler. OnUpdate polled frames are prevented from
registering events.

* self     - frame that will be registered for the given event.
* event    - name of the event to register (string)
* func     - a function that will be executed when the event fires. Multiple functions can be added for the same frame
             and event (function)
* unitless - indicates that the event does not fire for a specific unit, so the event arguments won't be
             matched to the frame unit(s). Obligatory for unitless event (boolean)
--]]
function frame_metatable.__index:RegisterEvent(event, func, unitless)
	-- Block OnUpdate polled frames from registering events except for
	-- UNIT_PORTRAIT_UPDATE and UNIT_MODEL_CHANGED which are used for
	-- portrait updates.
	if(self.__eventless and event ~= 'UNIT_PORTRAIT_UPDATE' and event ~= 'UNIT_MODEL_CHANGED') then return end

	argcheck(event, 2, 'string')
	argcheck(func, 3, 'function')

	local curev = self[event]
	if(curev) then
		local kind = type(curev)
		if(kind == 'function' and curev ~= func) then
			self[event] = setmetatable({curev, func}, event_metatable)
		elseif(kind == 'table') then
			for _, infunc in next, curev do
				if(infunc == func) then return end
			end

			table.insert(curev, func)
		end

		if(unitless or self.__eventless) then
			-- re-register the event in case we have mixed registration
			registerEvent(self, event)

			if(self.unitEvents) then
				self.unitEvents[event] = nil
			end
		end
	elseif(validateEvent(event)) then
		self[event] = func

		if(not self:GetScript('OnEvent')) then
			self:SetScript('OnEvent', onEvent)
		end

		if(unitless or self.__eventless) then
			registerEvent(self, event)
		else
			self.unitEvents = self.unitEvents or {}
			self.unitEvents[event] = true

			-- UpdateUnits will take care of unit event registration for header
			-- units in case we don't have a valid unit yet
			local unit1, unit2 = self.unit
			if(unit1 and validateUnit(unit1)) then
				if(secondaryUnits[event]) then
					unit2 = secondaryUnits[event][unit1]
				end

				-- be helpful and throw a custom error when attempting to register
				-- an event that is unitless
				assert(isUnitEvent(event, unit1), string.format('Event "%s" is not an unit event', event))

				registerUnitEvent(self, event, unit1, unit2 or '')
			end
		end
	end
end

--[[ Events: frame:UnregisterEvent(event, func)
Used to remove a function from the event handler list for a game event.

* self  - the frame registered for the event
* event - name of the registered event (string)
* func  - function to be removed from the list of event handlers. If this is the only handler for the given event, then
          the frame will be unregistered for the event (function)
--]]
function frame_metatable.__index:UnregisterEvent(event, func)
	argcheck(event, 2, 'string')

	local cleanUp = false
	local curev = self[event]
	if(type(curev) == 'table' and func) then
		for k, infunc in next, curev do
			if(infunc == func) then
				curev[k] = nil

				break
			end
		end

		if(not next(curev)) then
			cleanUp = true
		end
	end

	if(cleanUp or curev == func) then
		self[event] = nil
		if(self.unitEvents) then
			self.unitEvents[event] = nil
		end

		unregisterEvent(self, event)
	end
end
