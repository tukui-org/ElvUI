local _, ns = ...
local oUF = ns.oUF
local Profiler = oUF.Profiler.func

-- Event Pooler by Simpy

local next = next
local wipe = wipe
local pairs = pairs
local unpack = unpack
local tinsert = tinsert
local tremove = tremove
local GetTime = GetTime

local object = CreateFrame('Frame')
local pooler = { frame = object }
oUF.Pooler = Profiler(pooler)

object.tracked = {}
object.events = {}
object.times = {}

object.delay = 0.1 -- update check rate
object.instant = 0.2 -- seconds since last event
object.active = true -- off is always instant

pooler.run = function(funcs, frame, event, ...)
	for i = 1, #funcs do
		funcs[i](frame, event, ...)
	end
end

pooler.execute = function(event, pool, instant, arg1, ...)
	for frame, info in pairs(pool) do
		local funcs = info.functions
		if instant and funcs then
			if event == 'UNIT_AURA' and oUF.isRetail then
				local fullUpdate, updatedAuras = ...
				if not oUF:ShouldSkipAuraUpdate(frame, event, arg1, fullUpdate, updatedAuras) then
					pooler.run(funcs, frame, event, arg1, fullUpdate, updatedAuras)
				end
			else
				pooler.run(funcs, frame, event, arg1, ...)
			end
		else
			local data = funcs and info.data[event]
			if data then
				if event == 'UNIT_AURA' and oUF.isRetail then
					local allowUnit = false
					for i = 1, #data do
						local args = data[i]
						local unit, fullUpdate, updatedAuras = unpack(args)
						if not oUF:ShouldSkipAuraUpdate(frame, event, unit, fullUpdate, updatedAuras) then
							allowUnit = unit
							break
						end
					end

					if allowUnit then
						pooler.run(funcs, frame, event, allowUnit)
					end
				else
					local count = #data
					local args = count and data[count]
					if args then
						-- if count > 1 then print(frame:GetDebugName(), event, count, unpack(args)) end
						pooler.run(funcs, frame, event, unpack(args))
					end
				end

				wipe(data)
			end
		end
	end
end

pooler.update = function()
	for event in pairs(object.tracked) do
		local pool = object.events[event]
		if pool then
			pooler.execute(event, pool)
		end

		object.tracked[event] = nil
	end
end

pooler.tracker = function(frame, event, arg1, ...)
	-- print('tracker', frame, event, arg1, ...)
	local pool = object.events[event]
	if not pool then return end

	if object.active then
		local now = GetTime()
		local last = object.times[event]
		if last and (last + object.instant) < now then
			pooler.execute(event, pool, true, arg1, ...)
			-- print('instant', frame:GetDebugName(), event, arg1)
		elseif arg1 ~= nil then -- require arg1, no unitless
			local pooled = pool[frame]
			if pooled then
				if not object.tracked[event] then
					object.tracked[event] = true
				end

				local eventData = pooled.data[event]
				if not eventData then
					eventData = {}
					pooled.data[event] = eventData
				end

				tinsert(eventData, { arg1, ... })
			end
		end

		if not object:IsShown() then
			object:Show()
		end

		object.times[event] = now
	else
		if object:IsShown() then
			object:Hide()
		end

		pooler.execute(event, pool, true, arg1, ...)
	end
end

local wait = 0
pooler.onUpdate = function(_, elapsed)
	if wait > object.delay then
		pooler.update()

		wait = 0
	else
		wait = wait + elapsed
	end
end

object:SetScript('OnUpdate', pooler.onUpdate)
object:Hide()

function oUF:RegisterEvent(frame, event, func, unitless)
	-- print('RegisterEvent', frame, event, func)
	local eventPool = object.events[event]
	if not eventPool then
		eventPool = {}
		object.events[event] = eventPool
	end

	local framePool = eventPool[frame]
	if not framePool then
		framePool = { functions = {}, data = {} }
		eventPool[frame] = framePool
	end

	frame:RegisterEvent(event, pooler.tracker, unitless)
	tinsert(framePool.functions, func)
end

function oUF:UnregisterEvent(frame, event, func)
	-- print('UnregisterEvent', frame, event, func)
	local pool = object.events[event]
	if pool then
		local pooled = pool[frame]
		if pooled then
			local funcs = pooled.functions
			for i = #funcs, 1, -1 do
				if funcs[i] == func then
					tremove(funcs, i)
				end
			end

			if not next(funcs) then
				pool[frame] = nil
			end
		end

		if not next(pool) then
			object.events[event] = nil
			frame:UnregisterEvent(event, pooler.tracker)
		end
	end
end
