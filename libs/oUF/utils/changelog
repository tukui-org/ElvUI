#!/usr/bin/env lua

local tags = {}
do
	for tag in io.popen('git tag'):lines() do
		local split = tag:gmatch('[^.]+')
		local release, api, bugfix = split(), split(), split() or 0
		table.insert(
			tags,
			{
				string = tag,
				release = release,
				api = api,
				bugfix = bugfix,
			}
		)
	end

	table.sort(tags, function(a,b)
		a = a.release * 1e4 + a.api * 100 + a.bugfix
		b = b.release * 1e4 + b.api * 100 + b.bugfix

		return a > b
	end)
end

local generateLog = function(prevTag, currentTag)
	local ti = table.insert
	local sf = string.format

	local out = {}

	ti(out, sf('[b]Changes in %s:[/b]', currentTag))
	ti(out, '[list]')

	for line in io.popen(sf('git shortlog %s..%s', prevTag, currentTag)):lines() do
		if(line:sub(1, 6) == '      ') then
			local offset = line:match('()     ', 7)
			if(offset) then
				line = line:sub(7, offset - 1)
			else
				line = line:sub(7)
			end

			ti(out, sf('   [*] %s', line))
		elseif(#line == 0) then
			ti(out, '  [/list]')
		else
			ti(out, sf(' [*][i]%s[/i]', line))
			ti(out, '  [list=1]')
		end
	end

	ti(out, '[/list]')

	local p = assert(io.popen(sf('git diff --shortstat %s..%s', prevTag, currentTag)))
	local stat = p:read'*a'
	p:close()

	ti(out, sf('[indent]%s[/indent]', stat:sub(2, -2)))

	return table.concat(out, '\n')
end

local stop
local to = ...
if(to) then
	for i=1, #tags do
		if(tags[i].string == to) then
			stop = i + 1
		end
	end

	if(not stop) then stop = #tags end
else
	stop = #tags
end

for i=2, stop do
	local current, prev = tags[i -1], tags[i]
	print(generateLog(prev.string, current.string))
end

-- vim: set filetype=lua :
