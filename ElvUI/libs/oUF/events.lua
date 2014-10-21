local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local argcheck = Private.argcheck
local error = Private.error
local frame_metatable = Private.frame_metatable

local tinsert, tremove = table.insert, table.remove

-- Events
local RegisterEvent, UnregisterEvent, IsEventRegistered

do
	local eventFrame = CreateFrame("Frame")
	local registry = {}
	local framesForUnit = {}
	local alternativeUnits = {
		['player'] = 'vehicle',
		['pet'] = 'player',
		['party1'] = 'partypet1',
		['party2'] = 'partypet2',
		['party3'] = 'partypet3',
		['party4'] = 'partypet4',
	}
	
	local RegisterFrameForUnit = function(frame, unit)
		if not unit then return end
		if framesForUnit[unit] then
			framesForUnit[unit][frame] = true
		else
			framesForUnit[unit] = { [frame] = true }
		end
	end

	local UnregisterFrameForUnit = function(frame, unit)
		if not unit then return end
		local frames = framesForUnit[unit]
		if frames and frames[frame] then
			frames[frame] = nil
			if not next(frames) then
				framesForUnit[unit] = nil
			end
		end
	end

	Private.UpdateUnits = function(frame, unit, realUnit)
		if unit == realUnit then
			realUnit = nil
		end
		if frame.unit ~= unit or frame.realUnit ~= realUnit then
			if not frame:GetScript('OnUpdate') then
				UnregisterFrameForUnit(frame, frame.unit)
				UnregisterFrameForUnit(frame, frame.realUnit)
				RegisterFrameForUnit(frame, unit)
				RegisterFrameForUnit(frame, realUnit)
			end

			frame.alternativeUnit = alternativeUnits[unit]
			frame.unit = unit
			frame.realUnit = realUnit
			frame.id = unit:match'^.-(%d+)'
			return true
		end
	end

	-- Holds true for every event, where the first (unit) argument should be ignored.
	local sharedUnitEvents = {
		UNIT_ENTERED_VEHICLE = true,
		UNIT_EXITED_VEHICLE = true,
		UNIT_PET = true,
	}


	eventFrame:SetScript('OnEvent', function(_, event, arg1, ...)
		local listeners = registry[event]
		if arg1 and not sharedUnitEvents[event] then
			local frames = framesForUnit[arg1]
			if frames then
				for frame in next, frames do
					if listeners[frame] and frame:IsVisible() then
						frame[event](frame, event, arg1, ...)
					end
				end
			end
		else
			for frame in next, listeners do
				if frame:IsVisible() or event == 'UNIT_COMBO_POINTS' then
					frame[event](frame, event, arg1, ...)
				end
			end
		end
	end)

	function RegisterEvent(self, event, unitless)
		if(unitless) then
			sharedUnitEvents[event] = true
		end

		if not registry[event] then
			registry[event] = { [self] = true }
			eventFrame:RegisterEvent(event)
		else
			registry[event][self] = true
		end
	end

	function UnregisterEvent(self, event)
		if registry[event] then
			registry[event][self] = nil
			if not next(registry[event]) then
				registry[event] = nil
				eventFrame:UnregisterEvent(event)
			end
		end
	end

	function IsEventRegistered(self, event)
		return registry[event] and registry[event][self]
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

	local curev = self[event]
	local kind = type(curev)
	if(curev and func) then
		if(kind == 'function' and curev ~= func) then
			self[event] = setmetatable({curev, func}, event_metatable)
		elseif(kind == 'table') then
			for _, infunc in next, curev do
				if(infunc == func) then return end
			end

			tinsert(curev, func)
		end
	elseif(IsEventRegistered(self, event)) then
		return
	else
		if(type(func) == 'function') then
			self[event] = func
		elseif(not self[event]) then
			return error("Style [%s] attempted to register event [%s] on unit [%s] with a handler that doesn't exist.", self.style, event, self.unit or 'unknown')
		end

		RegisterEvent(self, event, unitless)
	end
end

function frame_metatable.__index:UnregisterEvent(event, func)
	argcheck(event, 2, 'string')

	local curev = self[event]
	if(type(curev) == 'table' and func) then
		for k, infunc in next, curev do
			if(infunc == func) then
				tremove(curev, k)

				local n = #curev
				if(n == 1) then
					local _, handler = next(curev)
					self[event] = handler
				elseif(n == 0) then
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

function frame_metatable.__index:IsEventRegistered(event)
	return IsEventRegistered(self, event)
end
