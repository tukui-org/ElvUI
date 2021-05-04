local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local tinsert, tremove, next, wipe, ipairs = tinsert, tremove, next, wipe, ipairs
local select, tonumber, type, unpack, strmatch = select, tonumber, type, unpack, strmatch
local modf, atan2, ceil, floor, abs, sqrt, mod = math.modf, atan2, ceil, floor, abs, sqrt, mod
local format, strsub, strupper, strlen, gsub, gmatch = format, strsub, strupper, strlen, gsub, gmatch
local tostring, pairs, utf8sub, utf8len = tostring, pairs, string.utf8sub, string.utf8len

local CreateFrame = CreateFrame
local UnitPosition = UnitPosition
local GetPlayerFacing = GetPlayerFacing
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local C_Timer_After = C_Timer.After

E.ShortPrefixValues = {}
E.ShortPrefixStyles = {
	TCHINESE = {{1e8,'億'}, {1e4,'萬'}},
	CHINESE = {{1e8,'亿'}, {1e4,'万'}},
	ENGLISH = {{1e12,'T'}, {1e9,'B'}, {1e6,'M'}, {1e3,'K'}},
	GERMAN = {{1e12,'Bio'}, {1e9,'Mrd'}, {1e6,'Mio'}, {1e3,'Tsd'}},
	KOREAN = {{1e8,'억'}, {1e4,'만'}, {1e3,'천'}},
	METRIC = {{1e12,'T'}, {1e9,'G'}, {1e6,'M'}, {1e3,'k'}}
}

E.GetFormattedTextStyles = {
	CURRENT = '%s',
	CURRENT_MAX = '%s - %s',
	CURRENT_PERCENT = '%s - %.1f%%',
	CURRENT_MAX_PERCENT = '%s - %s | %.1f%%',
	PERCENT = '%.1f%%',
	DEFICIT = '-%s',
}

function E:BuildPrefixValues()
	if next(E.ShortPrefixValues) then wipe(E.ShortPrefixValues) end

	E.ShortPrefixValues = E:CopyTable(E.ShortPrefixValues, E.ShortPrefixStyles[E.db.general.numberPrefixStyle])
	E.ShortValueDec = format('%%.%df', E.db.general.decimalLength or 1)

	for _, style in ipairs(E.ShortPrefixValues) do
		style[3] = E.ShortValueDec..style[2]
	end

	local dec = tostring(E.db.general.decimalLength or 1)
	for style, str in pairs(E.GetFormattedTextStyles) do
		E.GetFormattedTextStyles[style] = gsub(str, '%d', dec)
	end
end

--Return short value of a number
function E:ShortValue(value, dec)
	local abs_value = value<0 and -value or value
	local decimal = dec and format('%%.%df', tonumber(dec) or 0)

	for i = 1, #E.ShortPrefixValues do
		if abs_value >= E.ShortPrefixValues[i][1] then
			if decimal then
				return format(decimal..E.ShortPrefixValues[i][2], value / E.ShortPrefixValues[i][1])
			else
				return format(E.ShortPrefixValues[i][3], value / E.ShortPrefixValues[i][1])
			end
		end
	end

	return format('%.0f', value)
end

function E:IsEvenNumber(num)
	return num % 2 == 0
end

-- http://www.wowwiki.com/ColorGradient
function E:ColorGradient(perc, ...)
	if perc >= 1 then
		return select(select('#', ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end

	local num = select('#', ...) / 3
	local segment, relperc = modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1+(r2-r1)*relperc, g1+(g2-g1)*relperc, b1+(b2-b1)*relperc
end

-- Text Gradient by Simpy
function E:TextGradient(text, ...)
	local msg, len, idx = '', utf8len(text), 0

	for i = 1, len do
		local x = utf8sub(text, i, i)
		if strmatch(x, '%s') then
			msg = msg .. x
			idx = idx + 1
		else
			local num = select('#', ...) / 3
			local segment, relperc = modf((idx/len)*num)
			local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

			if not r2 then
				msg = msg .. E:RGBToHex(r1, g1, b1, nil, x..'|r')
			else
				msg = msg .. E:RGBToHex(r1+(r2-r1)*relperc, g1+(g2-g1)*relperc, b1+(b2-b1)*relperc, nil, x..'|r')
				idx = idx + 1
			end
		end
	end

	return msg
end

-- quick convert function: (nil or table to populate, 'ff0000', '00ff00', '0000ff', ...) to get (1,0,0, 0,1,0, 0,0,1, ...)
function E:HexsToRGBs(rgb, ...)
	if not rgb then rgb = {} end
	for i = 1, select('#', ...) do
		local x, r, g, b = #rgb, E:HexToRGB(select(i, ...))
		rgb[x+1], rgb[x+2], rgb[x+3] = r/255, g/255, b/255
	end

	return unpack(rgb)
end

--Return rounded number
function E:Round(num, idp)
	if type(num) ~= 'number' then
		return num, idp
	end

	if idp and idp > 0 then
		local mult = 10 ^ idp
		return floor(num * mult + 0.5) / mult
	end

	return floor(num + 0.5)
end

--Truncate a number off to n places
function E:Truncate(v, decimals)
	return v - (v % (0.1 ^ (decimals or 0)))
end

--RGB to Hex
function E:RGBToHex(r, g, b, header, ending)
	r = r <= 1 and r >= 0 and r or 1
	g = g <= 1 and g >= 0 and g or 1
	b = b <= 1 and b >= 0 and b or 1
	return format('%s%02x%02x%02x%s', header or '|cff', r*255, g*255, b*255, ending or '')
end

--Hex to RGB
function E:HexToRGB(hex)
	local a, r, g, b = strmatch(hex, '^|?c?(%x%x)(%x%x)(%x%x)(%x?%x?)|?r?$')
	if not a then return 0, 0, 0, 0 end
	if b == '' then r, g, b, a = a, r, g, 'ff' end

	return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16), tonumber(a, 16)
end

--From http://wow.gamepedia.com/UI_coordinates
function E:FramesOverlap(frameA, frameB)
	if not frameA or not frameB then return	end

	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	if not sA or not sB then return	end

	local frameALeft, frameARight, frameABottom, frameATop = frameA:GetLeft(), frameA:GetRight(), frameA:GetBottom(), frameA:GetTop()
	local frameBLeft, frameBRight, frameBBottom, frameBTop = frameB:GetLeft(), frameB:GetRight(), frameB:GetBottom(), frameB:GetTop()
	if not (frameALeft and frameARight and frameABottom and frameATop) then return end
	if not (frameBLeft and frameBRight and frameBBottom and frameBTop) then return end

	return ((frameALeft*sA) < (frameBRight*sB)) and ((frameBLeft*sB) < (frameARight*sA)) and ((frameABottom*sA) < (frameBTop*sB)) and ((frameBBottom*sB) < (frameATop*sA))
end

function E:GetScreenQuadrant(frame)
	local x, y = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()

	if not (x and y) then
		return 'UNKNOWN', frame:GetName()
	end

	local point
	if (x > (screenWidth / 3) and x < (screenWidth / 3)*2) and y > (screenHeight / 3)*2 then
		point = 'TOP'
	elseif x < (screenWidth / 3) and y > (screenHeight / 3)*2 then
		point = 'TOPLEFT'
	elseif x > (screenWidth / 3)*2 and y > (screenHeight / 3)*2 then
		point = 'TOPRIGHT'
	elseif (x > (screenWidth / 3) and x < (screenWidth / 3)*2) and y < (screenHeight / 3) then
		point = 'BOTTOM'
	elseif x < (screenWidth / 3) and y < (screenHeight / 3) then
		point = 'BOTTOMLEFT'
	elseif x > (screenWidth / 3)*2 and y < (screenHeight / 3) then
		point = 'BOTTOMRIGHT'
	elseif x < (screenWidth / 3) and (y > (screenHeight / 3) and y < (screenHeight / 3)*2) then
		point = 'LEFT'
	elseif x > (screenWidth / 3)*2 and y < (screenHeight / 3)*2 and y > (screenHeight / 3) then
		point = 'RIGHT'
	else
		point = 'CENTER'
	end

	return point
end

function E:GetXYOffset(position, forcedX, forcedY)
	local default = E.Spacing
	local x, y = forcedX or default, forcedY or forcedX or default

	if position == 'TOP' then
		return 0, y
	elseif position == 'TOPLEFT' then
		return x, y
	elseif position == 'TOPRIGHT' then
		return -x, y
	elseif position == 'BOTTOM' then
		return 0, -y
	elseif position == 'BOTTOMLEFT' then
		return x, -y
	elseif position == 'BOTTOMRIGHT' then
		return -x, -y
	elseif position == 'LEFT' then
		return -x, 0
	elseif position == 'RIGHT' then
		return x, 0
	elseif position == 'CENTER' then
		return 0, 0
	end
end

function E:GetFormattedText(style, min, max, dec, short)
	if max == 0 then max = 1 end

	if style == 'CURRENT' or ((style == 'CURRENT_MAX' or style == 'CURRENT_MAX_PERCENT' or style == 'CURRENT_PERCENT') and min == max) then
		return format(E.GetFormattedTextStyles.CURRENT, short and E:ShortValue(min, dec) or BreakUpLargeNumbers(min))
	else
		local useStyle = E.GetFormattedTextStyles[style]
		if not useStyle then return end

		if style == 'DEFICIT' then
			local deficit = max - min
			return (deficit > 0 and format(useStyle, short and E:ShortValue(deficit, dec) or BreakUpLargeNumbers(deficit))) or ''
		elseif style == 'CURRENT_MAX' then
			return format(useStyle, short and E:ShortValue(min, dec) or BreakUpLargeNumbers(min), short and E:ShortValue(max, dec) or BreakUpLargeNumbers(max))
		elseif style == 'PERCENT' or style == 'CURRENT_PERCENT' or style == 'CURRENT_MAX_PERCENT' then
			if dec then useStyle = gsub(useStyle, '%d', tonumber(dec) or 0) end
			local perc = min / max * 100

			if style == 'PERCENT' then
				return format(useStyle, perc)
			elseif style == 'CURRENT_PERCENT' then
				return format(useStyle, short and E:ShortValue(min, dec) or BreakUpLargeNumbers(min), perc)
			elseif style == 'CURRENT_MAX_PERCENT' then
				return format(useStyle, short and E:ShortValue(min, dec) or BreakUpLargeNumbers(min), short and E:ShortValue(max, dec) or BreakUpLargeNumbers(max), perc)
			end
		end
	end
end

function E:ShortenString(str, numChars, dots)
	local bytes = #str
	if bytes <= numChars then
		return str
	else
		local len, pos = 0, 1
		while pos <= bytes do
			len = len + 1
			local c = str:byte(pos)
			if c > 0 and c <= 127 then
				pos = pos + 1
			elseif c >= 192 and c <= 223 then
				pos = pos + 2
			elseif c >= 224 and c <= 239 then
				pos = pos + 3
			elseif c >= 240 and c <= 247 then
				pos = pos + 4
			end
			if len == numChars then
				break
			end
		end

		if len == numChars and pos <= bytes then
			return strsub(str, 1, pos - 1)..(dots and '...' or '')
		else
			return str
		end
	end
end

function E:AbbreviateString(str, allUpper)
	local newString = ''
	for word in gmatch(str, '[^%s]+') do
		word = utf8sub(word, 1, 1) --get only first letter of each word
		if allUpper then word = strupper(word) end
		newString = newString..word
	end

	return newString
end

function E:WaitFunc(elapse)
	local i = 1
	while i <= #E.WaitTable do
		local data = E.WaitTable[i]
		if data[1] > elapse then
			data[1], i = data[1] - elapse, i + 1
		else
			tremove(E.WaitTable, i)
			data[2](unpack(data[3]))

			if #E.WaitTable == 0 then
				E.WaitFrame:Hide()
			end
		end
	end
end

E.WaitTable = {}
E.WaitFrame = CreateFrame('Frame', 'ElvUI_WaitFrame', _G.UIParent)
E.WaitFrame:SetScript('OnUpdate', E.WaitFunc)

--Add time before calling a function
function E:Delay(delay, func, ...)
	if type(delay) ~= 'number' or type(func) ~= 'function' then
		return false
	end

	-- Restrict to the lowest time that the C_Timer API allows us
	if delay < 0.01 then delay = 0.01 end

	if select('#', ...) <= 0 then
		C_Timer_After(delay, func)
	else
		tinsert(E.WaitTable,{delay,func,{...}})
		E.WaitFrame:Show()
	end

	return true
end

function E:StringTitle(str)
	return gsub(str, '(.)', strupper, 1)
end

E.TimeThreshold = 3

E.TimeColors = { --aura time colors
	[0] = '|cffeeeeee', --days
	[1] = '|cffeeeeee', --hours
	[2] = '|cffeeeeee', --minutes
	[3] = '|cffeeeeee', --seconds
	[4] = '|cfffe0000', --expire (fade timer)
	[5] = '|cff909090', --mmss
	[6] = '|cff707070', --hhmm
}

E.TimeFormats = { -- short / indicator color
	[0] = {'%dd', '%d%sd|r'},
	[1] = {'%dh', '%d%sh|r'},
	[2] = {'%dm', '%d%sm|r'},
	[3] = {'%ds', '%d%ss|r'},
	[4] = {'%.1fs', '%.1f%ss|r'},
	[5] = {'%d:%02d', '%d%s:|r%02d'}, --mmss
	[6] = {'%d:%02d', '%d%s:|r%02d'}, --hhmm
}

for _, x in pairs(E.TimeFormats) do
	x[3] = gsub(x[1], 's$', '') -- 1 without seconds
	x[4] = gsub(x[2], '%%ss', '%%s') -- 2 without seconds
end

E.TimeIndicatorColors = {
	[0] = '|cff00b3ff',
	[1] = '|cff00b3ff',
	[2] = '|cff00b3ff',
	[3] = '|cff00b3ff',
	[4] = '|cff00b3ff',
	[5] = '|cff00b3ff',
	[6] = '|cff00b3ff',
}

local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for calculating aura time text
local DAYISH, HOURISH, MINUTEISH = HOUR * 23.5, MINUTE * 59.5, 59.5 --used for caclculating aura time at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

-- will return the the value to display, the formatter id to use and calculates the next update for the Aura
function E:GetTimeInfo(s, threshhold, hhmm, mmss)
	if s < MINUTE then
		if s >= threshhold then
			return floor(s), 3, 0.51
		else
			return s, 4, 0.051
		end
	elseif s < HOUR then
		if mmss and s < mmss then
			return s/MINUTE, 5, 0.51, s%MINUTE
		else
			local minutes = floor((s/MINUTE)+.5)
			if hhmm and s < (hhmm * MINUTE) then
				return s/HOUR, 6, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH), minutes%MINUTE
			else
				return ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
			end
		end
	elseif s < DAY then
		if mmss and s < mmss then
			return s/MINUTE, 5, 0.51, s%MINUTE
		elseif hhmm and s < (hhmm * MINUTE) then
			local minutes = floor((s/MINUTE)+.5)
			return s/HOUR, 6, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH), minutes%MINUTE
		else
			local hours = floor((s/HOUR)+.5)
			return ceil(s / HOUR), 1, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
		end
	else
		local days = floor((s/DAY)+.5)
		return ceil(s / DAY), 0, days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

function E:GetDistance(unit1, unit2)
	local x1, y1, _, map1 = UnitPosition(unit1)
	if not x1 then return end

	local x2, y2, _, map2 = UnitPosition(unit2)
	if not x2 then return end

	if map1 ~= map2 then return end

	local dX = x2 - x1
	local dY = y2 - y1
	local distance = sqrt(dX * dX + dY * dY)
	return distance, atan2(dY, dX) - GetPlayerFacing()
end

-- Taken from FormattingUtil.lua and modified by Simpy
function E:FormatLargeNumber(amount, seperator)
	local num, len = '', strlen(amount)
	local trd = len % 3

	if not seperator then seperator = ',' end
	for i=4, len, 3 do num = seperator..strsub(amount, -(i - 1), -(i - 3))..num end

	return strsub(amount, 1, (trd == 0) and 3 or trd)..num
end

--Money text formatting, code taken from Scrooge by thelibrarian ( http://www.wowace.com/addons/scrooge/ )
local COLOR_COPPER, COLOR_SILVER, COLOR_GOLD = '|cffeda55f', '|cffc7c7cf', '|cffffd700'
local ICON_COPPER = [[|TInterface\MoneyFrame\UI-CopperIcon:12:12|t]]
local ICON_SILVER = [[|TInterface\MoneyFrame\UI-SilverIcon:12:12|t]]
local ICON_GOLD = [[|TInterface\MoneyFrame\UI-GoldIcon:12:12|t]]
function E:FormatMoney(amount, style, textonly)
	local coppername = textonly and L["copperabbrev"] or ICON_COPPER
	local silvername = textonly and L["silverabbrev"] or ICON_SILVER
	local goldname = textonly and L["goldabbrev"] or ICON_GOLD

	local value = abs(amount)
	local gold = floor(value / 10000)
	local silver = floor(mod(value / 100, 100))
	local copper = floor(mod(value, 100))

	if not style or style == 'SMART' then
		local str = ''
		if gold > 0 then str = format('%d%s%s', gold, goldname, (silver > 0 or copper > 0) and ' ' or '') end
		if silver > 0 then str = format('%s%d%s%s', str, silver, silvername, copper > 0 and ' ' or '') end
		if copper > 0 or value == 0 then str = format('%s%d%s', str, copper, coppername) end
		return str
	end

	if style == 'FULL' then
		if gold > 0 then
			return format('%d%s %d%s %d%s', gold, goldname, silver, silvername, copper, coppername)
		elseif silver > 0 then
			return format('%d%s %d%s', silver, silvername, copper, coppername)
		else
			return format('%d%s', copper, coppername)
		end
	elseif style == 'SHORT' then
		if gold > 0 then
			return format('%.1f%s', amount / 10000, goldname)
		elseif silver > 0 then
			return format('%.1f%s', amount / 100, silvername)
		else
			return format('%d%s', amount, coppername)
		end
	elseif style == 'SHORTINT' then
		if gold > 0 then
			return format('%d%s', gold, goldname)
		elseif silver > 0 then
			return format('%d%s', silver, silvername)
		else
			return format('%d%s', copper, coppername)
		end
	elseif style == 'SHORTSPACED' then
		if gold > 0 then
			return format('%s%s', E:FormatLargeNumber(gold, ' '), goldname)
		elseif silver > 0 then
			return format('%d%s', silver, silvername)
		else
			return format('%d%s', copper, coppername)
		end
	elseif style == 'CONDENSED' then
		if gold > 0 then
			return format('%s%d|r.%s%02d|r.%s%02d|r', COLOR_GOLD, gold, COLOR_SILVER, silver, COLOR_COPPER, copper)
		elseif silver > 0 then
			return format('%s%d|r.%s%02d|r', COLOR_SILVER, silver, COLOR_COPPER, copper)
		else
			return format('%s%d|r', COLOR_COPPER, copper)
		end
	elseif style == 'CONDENSED_SPACED' then
		if gold > 0 then
			return format('%s%d|r %s%02d|r %s%02d|r', COLOR_GOLD, gold, COLOR_SILVER, silver, COLOR_COPPER, copper)
		elseif silver > 0 then
			return format('%s%d|r %s%02d|r', COLOR_SILVER, silver, COLOR_COPPER, copper)
		else
			return format('%s%d|r', COLOR_COPPER, copper)
		end
	elseif style == 'BLIZZARD' then
		if gold > 0 then
			return format('%s%s %d%s %d%s', BreakUpLargeNumbers(gold), goldname, silver, silvername, copper, coppername)
		elseif silver > 0 then
			return format('%d%s %d%s', silver, silvername, copper, coppername)
		else
			return format('%d%s', copper, coppername)
		end
	elseif style == 'BLIZZARD2' then
		if gold > 0 then
			return format('%s%s %02d%s %02d%s', BreakUpLargeNumbers(gold), goldname, silver, silvername, copper, coppername)
		elseif silver > 0 then
			return format('%d%s %02d%s', silver, silvername, copper, coppername)
		else
			return format('%d%s', copper, coppername)
		end
	end

	-- Shouldn't be here; punt
	return self:FormatMoney(amount, 'SMART')
end
