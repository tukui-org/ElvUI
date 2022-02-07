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

do -- Event Pooler by Simpy
	local pooler = CreateFrame('Frame')
	pooler.events = {}
	pooler.times = {}

	pooler.delay = 0.1 -- update check rate
	pooler.instant = 10 -- seconds since last event

	pooler.run = function(funcs, frame, event, ...)
		for _, func in pairs(funcs) do
			func(frame, event, ...)
		end
	end

	pooler.execute = function(event, pool, instant, arg1, ...)
		for frame, info in pairs(pool) do
			local funcs = info.functions
			if instant and funcs then
				pooler.run(funcs, frame, event, arg1, ...)
			else
				local data = funcs and info.data[event]
				local count = data and #data
				if count and data[count] then
					-- if count > 1 then print(frame:GetDebugName(), event, count, unpack(data[count])) end
					pooler.run(funcs, frame, event, unpack(data[count]))
					wipe(data)
				end
			end
		end
	end

	pooler.update = function()
		for event, pool in pairs(pooler.events) do
			pooler.execute(event, pool)
		end
	end

	pooler.tracker = function(frame, event, arg1, ...)
		-- print('tracker', frame, event, arg1, ...)

		local now = time()
		local pool = pooler.events[event]
		if pool then
			local last = pooler.times[event]
			if last and (last + pooler.instant) < now then
				pooler.execute(event, pool, true, arg1, ...)
				-- print('instant', frame:GetDebugName(), event, arg1)
			else
				local pooled = pool[frame]
				if pooled then
					if not pooled.data[event] then
						pooled.data[event] = {}
					end

					if arg1 ~= nil then
						tinsert(pooled.data[event], {arg1, ...})
					end
				end
			end

			pooler.times[event] = now
		end
	end

	pooler.onUpdate = function(self, elapsed)
		if self.elapsed and self.elapsed > pooler.delay then
			pooler.update()

			self.elapsed = 0
		else
			self.elapsed = (self.elapsed or 0) + elapsed
		end
	end

	pooler:SetScript('OnUpdate', pooler.onUpdate)

	function Private:RegisterEvent(frame, event, func)
		-- print('RegisterEvent', frame, event, func)

		if not pooler.events[event] then
			pooler.events[event] = {}
			pooler.events[event][frame] = {functions={},data={}}
		elseif not pooler.events[event][frame] then
			pooler.events[event][frame] = {functions={},data={}}
		end

		frame:RegisterEvent(event, pooler.tracker)
		tinsert(pooler.events[event][frame].functions, func)
	end

	function Private:UnregisterEvent(frame, event, func)
		-- print('UnregisterEvent', frame, event, func)

		local pool = pooler.events[event]
		if pool then
			local pooled = pool[frame]
			if pooled then
				for i, funct in ipairs(pooled.functions) do
					if funct == func then
						tremove(pooled.functions, i)
					end
				end

				if not next(pooled.functions) then
					pooled.functions = nil
					pooled.data = nil -- clear data
				end

				if not next(pooled) then
					pool[frame] = nil
				end
			end

			if not next(pool) then
				pooler.events[event] = nil
				frame:UnregisterEvent(event, pooler.tracker)
			end
		end
	end
end
