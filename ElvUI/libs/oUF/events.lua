local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local error = Private.error
local frame_metatable = Private.frame_metatable

-- Original event methods
local RegisterEvent = frame_metatable.__index.RegisterEvent
local RegisterUnitEvent = frame_metatable.__index.RegisterUnitEvent
local UnregisterEvent = frame_metatable.__index.UnregisterEvent
local IsEventRegistered = frame_metatable.__index.IsEventRegistered

local unitEvents = {}

Private.UpdateUnits = function(frame, unit, realUnit)
	if unit == realUnit then
		realUnit = nil
	end
	if frame.unit ~= unit or frame.realUnit ~= realUnit then
		for event in next, unitEvents do
			-- IsEventRegistered returns the units in case of an event
			-- registered with RegisterUnitEvent
			local registered, unit1 = IsEventRegistered(frame, event)
			if registered and unit1 ~= unit then
				-- RegisterUnitEvent erases previously registered units so
				-- do not bother to unregister it
				RegisterUnitEvent(frame, event, unit, realUnit)
			end
		end
		frame.unit = unit
		frame.realUnit = realUnit
		frame.id = unit:match'^.-(%d+)'
		return true
	end
end

local OnEvent = function(self, event, ...)
	if self:IsVisible() then
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

function frame_metatable.__index:RegisterEvent(event, func, unitless)
	-- Block OnUpdate polled frames from registering events.
	if(self.__eventless) then return end

	argcheck(event, 2, 'string')

	if(type(func) == 'string' and type(self[func]) == 'function') then
		func = self[func]
	end

	-- TODO: should warn the user.
	if not unitless and not (unitEvents[event] or event:match'^UNIT_') then
		unitless = true
	end

	local curev = self[event]
	local kind = type(curev)
	if(curev and func) then
		if(kind == 'function' and curev ~= func) then
			self[event] = setmetatable({curev, func}, event_metatable)
		elseif(kind == 'table') then
			for _, infunc in next, curev do
				if(infunc == func) then return end
			end

			table.insert(curev, func)
		end
	elseif(IsEventRegistered(self, event)) then
		return
	else
		if(type(func) == 'function') then
			self[event] = func
		elseif(not self[event]) then
			return error("Style [%s] attempted to register event [%s] on unit [%s] with a handler that doesn't exist.", self.style, event, self.unit or 'unknown')
		end

		if not self:GetScript('OnEvent') then
			self:SetScript('OnEvent', OnEvent)
		end

		if unitless then
			RegisterEvent(self, event)
		else
			unitEvents[event] = true
			RegisterUnitEvent(self, event, self.unit)
		end
	end
end

function frame_metatable.__index:UnregisterEvent(event, func)
	argcheck(event, 2, 'string')

	local curev = self[event]
	if(type(curev) == 'table' and func) then
		for k, infunc in next, curev do
			if(infunc == func) then
				table.remove(curev, k)

				local n = #curev
				if(n == 1) then
					local _, handler = next(curev)
					self[event] = handler
				elseif(n == 0) then
					-- This should not happen
					UnregisterEvent(self, event)
				end

				break
			end
		end
	elseif(curev == func) then
		self[event] = nil
		UnregisterEvent(self, event)
	end
end
