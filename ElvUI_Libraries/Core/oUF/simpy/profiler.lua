local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

-- ElvUI_CPU knock off by Simpy (STILL UNFINISHED)

local type = type
local wipe = wipe
local rawset = rawset
local unpack = unpack
local CopyTable = CopyTable
local getmetatable = getmetatable
local setmetatable = setmetatable
local debugprofilestop = debugprofilestop

-- cpu timing stuff
local _default = { total = 0, average = 0, count = 0 }
local _data, _info, _fps = { _all = CopyTable(_default) }, {}, { _overall = CopyTable(_default), _current = CopyTable(_default) }

local Collect = function(object, key, func, ...)
	local start = debugprofilestop()
	local args = { func(...) }
	local finish = debugprofilestop() - start

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
		data.count = data.count + 1

		if data.finish > data.high then
			data.high = data.finish
		end

		if data.finish < data.low then
			data.low = data.finish
		end

		data.total = data.total + finish
		data.average = data.total / data.count
	else
		data = { high = finish, low = finish, total = finish, average = finish, count = 1 }
		obj[key] = data
	end

	-- update data
	data.start = start
	data.finish = finish

	local module = obj._module
	if module then -- module totals
		module.total = module.total + finish
		module.count = module.count + 1
		module.average = module.total / module.count
	end

	local all = _data._all
	if all then -- overall totals
		all.total = all.total + finish
		all.count = all.count + 1
		all.average = all.total / all.count
	end

	return unpack(args)
end

local Generate = function(object, key, func)
	-- print('Generate', object, key, func)

	return function(...)
		if _info._enabled then
			return Collect(object, key, func, ...)
		else
			return func(...)
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

_info.data = _data
_info.fps = _fps

_info.reset = function()
	wipe(_data)
	wipe(_fps)

	_info.oUF_Private = nil

	_data._all = CopyTable(_default)

	_fps._overall = CopyTable(_default)
	_fps._current = CopyTable(_default)
end

_info.state = function(value)
	_info._enabled = value
end

_info.func = function(tbl, ...)
	-- print('Profiler', tbl)

	local t = getmetatable(tbl)
	if t then
		t.__newindex = Generator

		return tbl, ...
	else
		return setmetatable(tbl, { __newindex = Generator }), ...
	end
end

oUF.Profiler = _info

-- lets collect some FPS info
local CurrentRate = function(rate)
	local cur = _fps._current
	cur.rate = rate
	cur.count = (cur.count or 0) + 1

	-- keep them fresh
	if cur.count >= 10 then
		cur.total = rate
		cur.high = rate
		cur.low = rate
		cur.count = 1
	else
		cur.total = (cur.total or 0) + rate
	end

	cur.average = cur.total / cur.count

	if not cur.high or (rate > cur.high) then
		cur.high = rate
	end

	if not cur.low or (rate < cur.low) then
		cur.low = rate
	end
end

local OverallRate = function(rate)
	local all = _fps._overall
	all.rate = rate
	all.count = (all.count or 0) + 1
	all.total = (all.total or 0) + rate

	all.average = all.total / all.count

	if not all.high or (rate > all.high) then
		all.high = rate
	end

	if not all.low or (rate < all.low) then
		all.low = rate
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
			CurrentRate(rate)
			OverallRate(rate)
		end

		rate = 0 -- ok reset it
	end
end

frame:SetScript('OnUpdate', TrackFramerate)
