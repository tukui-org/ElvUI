local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

-- ElvUI_CPU knock off by Simpy (STILL UNFINISHED)

local type = type
local next = next
local wipe = wipe
local rawset = rawset
local unpack = unpack
local CopyTable = CopyTable
local getmetatable = getmetatable
local setmetatable = setmetatable
local debugprofilestop = debugprofilestop

-- cpu timing stuff
local _default = { total = 0, average = 0, count = 0 }
local _info, _funcs, _data, _fps = {}, {}, { _all = CopyTable(_default) }, { _all = CopyTable(_default) }

oUF.Profiler = _info

_info.funcs = _funcs
_info.data = _data
_info.fps = _fps

local Profile = function(func, ...)
	local start = debugprofilestop()
	local args = { func(...) }
	local finish = debugprofilestop() - start

	return start, finish, args
end

local Update = function(data, finish)
	local count = data.count + 1
	return count, (finish > data.high) and finish, (finish < data.low) and finish, data.total + finish, data.total / count
end

local Total = function(data, finish)
	local count = data.count + 1
	return count, data.total + finish, data.total / count
end

local Save = function(data, start, finish)
	local count, high, low, total, average = Update(data, finish)

	if high then data.high = high end
	if low then data.low = low end

	data.count = count
	data.total = total
	data.start = start
	data.finish = finish
	data.average = average
end

local Single = function(func, ...)
	local data = _funcs[func]
	if not data then
		return func(...)
	end

	local start, finish, args = Profile(func, ...)
	if not data.count then
		data.high = finish
		data.low = finish
		data.total = finish
		data.average = finish
		data.finish = finish
		data.start = start
		data.count = 1
	else
		Save(data, finish)
	end

	return unpack(args)
end

local Several = function(object, key, func, ...)
	local start, finish, args = Profile(func, ...)

	local obj = _data[object]
	if not obj then
		obj = { _module = CopyTable(_default) }

		if object == Private then
			_info.oUF_Private = obj -- only export timing data
		end

		_data[object] = obj
	end

	local data = obj[key]
	if data then
		Save(data, start, finish)
	else
		data = { start = start, finish = finish, high = finish, low = finish, total = finish, average = finish, count = 1 }
		obj[key] = data
	end

	local module = obj._module -- module totals
	if module then module.count, module.total, module.average = Total(module, finish) end

	local all = _data._all -- overall totals
	if all then all.count, all.total, all.average = Total(all, finish) end

	return unpack(args)
end

local Generate = function(object, key, func)
	-- print('Generate', object, key, func)

	if object then
		return function(...)
			if _info._enabled then
				return Several(object, key, func, ...)
			else
				return func(...)
			end
		end
	else
		return function(...)
			if _info._enabled then
				return Single(func, ...)
			else
				return func(...)
			end
		end
	end
end

local Generator = function(object, key, value)
	-- print('Generator', key, value)

	if type(value) == 'function' then
		local func = Generate(object, key, value)
		rawset(object, key, func)
	else
		rawset(object, key, value)
	end
end

local meta = { __newindex = Generator }
_info.func = function(tbl, ...)
	-- print('Profiler', tbl)

	local t = getmetatable(tbl)
	if t then
		t.__newindex = Generator

		return tbl, ...
	else
		return setmetatable(tbl, meta), ...
	end
end

_info.func(oUF) -- soon as possible

_info.add = function(func)
	if not _funcs[func] then
		_funcs[func] = {}

		return Generate(nil, nil, func)
	end
end

_info.clear = function(object)
	wipe(object)

	object._all = CopyTable(_default)
end

_info.reset = function()
	_info.clear(_data)
	_info.clear(_fps)

	for _, obj in next, _funcs do
		wipe(obj)
	end

	_info.oUF_Private = nil
end

_info.state = function(value)
	_info._enabled = value
end

-- lets collect some FPS info
local CollectRate = function(rate)
	local all = _fps._all
	if all then -- overall rate
		all.count = (all.count or 0) + 1
		all.total = (all.total or 0) + rate

		all.rate = rate
		all.average = all.total / all.count

		if not all.high or (rate > all.high) then
			all.high = rate
		end

		if not all.low or (rate < all.low) then
			all.low = rate
		end
	end
end

local frame, ignore, wait, rate = CreateFrame('Frame'), true, 0, 0
local TrackFramerate = function(_, elapsed)
	if wait < 1 then
		wait = wait + elapsed
		rate = rate + 1
	else
		wait = 0

		if ignore then -- ignore the first update
			ignore = false
		else
			CollectRate(rate)
		end

		rate = 0 -- ok reset it
	end
end

local ResetFramerate = function()
	_info.clear(_fps)

	ignore = true -- ignore the first again
end

frame:SetScript('OnUpdate', TrackFramerate)
frame:SetScript('OnEvent', ResetFramerate)
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
