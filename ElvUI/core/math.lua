local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB


local Astrolabe = DongleStub("Astrolabe-1.0") 
local format = string.format
local sub = string.sub
local upper = string.upper

local atan2 = math.atan2
local modf = math.modf
local ceil = math.ceil
local floor = math.floor

--Return short value of a number
function E:ShortValue(v)
	if v >= 1e9 then
		return ("%.1fb"):format(v / 1e9):gsub("%.?0+([kmb])$", "%1")
	elseif v >= 1e6 then
		return ("%.1fm"):format(v / 1e6):gsub("%.?0+([kmb])$", "%1")
	elseif v >= 1e3 or v <= -1e3 then
		return ("%.1fk"):format(v / 1e3):gsub("%.?0+([kmb])$", "%1")
	else
		return v
	end
end

function E:IsEvenNumber(num)
	if ( num % 2 ) == 0 then
		return true;
	else
		return false;
	end
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

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

--Return rounded number
function E:Round(v, decimals)
    return (("%%.%df"):format(decimals or 0)):format(v)
end

--Truncate a number off to n places
function E:Truncate(v, decimals)
	if not decimals then decimals = 0 end
    return v - (v % (0.1 ^ decimals))
end

--RGB to Hex
function E:RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

--Hex to RGB
function E:HexToRGB(hex)
	local rhex, ghex, bhex = sub(hex, 1, 2), sub(hex, 3, 4), sub(hex, 5, 6)
	return tonumber(rhex, 16), tonumber(ghex, 16), tonumber(bhex, 16)
end

function E:GetScreenQuadrant(frame)
	local x, y = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local point
	
	if not frame:GetCenter() then
		return "UNKNOWN", frame:GetName()
	end
	
	if (x > (screenWidth / 4) and x < (screenWidth / 4)*3) and y > (screenHeight / 4)*3 then
		point = "TOP"
	elseif x < (screenWidth / 4) and y > (screenHeight / 4)*3 then
		point = "TOPLEFT"
	elseif x > (screenWidth / 4)*3 and y > (screenHeight / 4)*3 then
		point = "TOPRIGHT"
	elseif (x > (screenWidth / 4) and x < (screenWidth / 4)*3) and y < (screenHeight / 4) then
		point = "BOTTOM"
	elseif x < (screenWidth / 4) and y < (screenHeight / 4) then
		point = "BOTTOMLEFT"
	elseif x > (screenWidth / 4)*3 and y < (screenHeight / 4) then
		point = "BOTTOMRIGHT"
	elseif x < (screenWidth / 4) and (y > (screenHeight / 4) and y < (screenHeight / 4)*3) then
		point = "LEFT"
	elseif x > (screenWidth / 4)*3 and y < (screenHeight / 4)*3 and y > (screenHeight / 4) then
		point = "RIGHT"
	else
		point = "CENTER"
	end

	return point
end

function E:GetXYOffset(position, override)
	local default = E.PixelMode and 0 or 1
	local x, y = override or default, override or default
	
	if position == 'TOP' or position == 'TOPLEFT' or position == 'TOPRIGHT' then
		return 0, y
	elseif position == 'BOTTOM' or position == 'BOTTOMLEFT' or position == 'BOTTOMRIGHT' then
		return 0, -y
	elseif position == 'LEFT' then
		return -x, 0
	else
		return x, 0
	end
end

local styles = {
	['CURRENT'] = '%s',
	['CURRENT_MAX'] = '%s - %s',
	['CURRENT_PERCENT'] =  '%s - %s%%',
	['CURRENT_MAX_PERCENT'] = '%s - %s | %s%%',
	['PERCENT'] = '%s%%',
	['DEFICIT'] = '-%s'
}

function E:GetFormattedText(style, min, max)
	assert(styles[style], 'Invalid format style: '..style)
	assert(min, 'You need to provide a current value. Usage: E:GetFormattedText(style, min, max)')
	assert(max, 'You need to provide a maximum value. Usage: E:GetFormattedText(style, min, max)')
	
	if max == 0 then max = 1 end
	
	local useStyle = styles[style]

	if style == 'DEFICIT' then
		local deficit = max - min
		if deficit <= 0 then
			return ''
		else
			return format(useStyle, E:ShortValue(deficit))
		end
	elseif style == 'PERCENT' then
		local s = format(useStyle, format("%.1f", min / max * 100))
		s = s:gsub(".0%%", "%%")
		return s
	elseif style == 'CURRENT' or ((style == 'CURRENT_MAX' or style == 'CURRENT_MAX_PERCENT' or style == 'CURRENT_PERCENT') and min == max) then
		return format(styles['CURRENT'],  E:ShortValue(min))
	elseif style == 'CURRENT_MAX' then
		return format(useStyle,  E:ShortValue(min), E:ShortValue(max))
	elseif style == 'CURRENT_PERCENT' then
		local s = format(useStyle, E:ShortValue(min), format("%.1f", min / max * 100))
		s = s:gsub(".0%%", "%%")
		return s
	elseif style == 'CURRENT_MAX_PERCENT' then
		local s = format(useStyle, E:ShortValue(min), E:ShortValue(max), format("%.1f", min / max * 100))
		s = s:gsub(".0%%", "%%")
		return s
	end
end

function E:ShortenString(string, numChars, dots)
	assert(string, 'You need to provide a string to shorten. Usage: E:ShortenString(string, numChars, includeDots)')
	assert(numChars, 'You need to provide a length to shorten the string to. Usage: E:ShortenString(string, numChars, includeDots)')
	
	local bytes = string:len()
	if (bytes <= numChars) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 192 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if (len == numChars) then break end
		end

		if (len == numChars and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and '...' or '')
		else
			return string
		end
	end
end

--Add time before calling a function
local waitTable = {}
local waitFrame
function E:Delay(delay, func, ...)
	if(type(delay)~="number" or type(func)~="function") then
		return false
	end
	if(waitFrame == nil) then
		waitFrame = CreateFrame("Frame","WaitFrame", E.UIParent)
		waitFrame:SetScript("onUpdate",function (self,elapse)
			local count = #waitTable
			local i = 1
			while(i<=count) do
				local waitRecord = tremove(waitTable,i)
				local d = tremove(waitRecord,1)
				local f = tremove(waitRecord,1)
				local p = tremove(waitRecord,1)
				if(d>elapse) then
				  tinsert(waitTable,i,{d-elapse,f,p})
				  i = i + 1
				else
				  count = count - 1
				  f(unpack(p))
				end
			end
		end)
	end
	tinsert(waitTable,{delay,func,{...}})
	return true
end

function E:StringTitle(str)
	return str:gsub("(.)", upper, 1)
end

-- aura time colors for days, hours, minutes, seconds, fadetimer
E.TimeColors = {
	[0] = '|cffeeeeee',
	[1] = '|cffeeeeee',
	[2] = '|cffeeeeee',
	[3] = '|cffeeeeee',
	[4] = '|cfffe0000',
}

-- short and long aura time formats
E.TimeFormats = {
	[0] = { '%dd', '%dd', '%d', 'd' },
	[1] = { '%dh', '%dh', '%d', 'h' },
	[2] = { '%dm', '%dm', '%d', 'm' },
	[3] = { '%ds', '%d', '%d', 's' },
	[4] = { '%.1fs', '%.1f', '%.1f', 's' },
}

-- Colors for time indicators: d (days), h (hours), m (minutes), s (seconds), s (seconds, below fade/decimal threshold)
E.IndicatorColors = {
	[0] = '|cff343fb3',
	[1] = '|cff343fb3',
	[2] = '|cff343fb3',
	[3] = '|cff343fb3',
	[4] = '|cff343fb3',
}

local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for calculating aura time text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for caclculating aura time at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

-- will return the the value to display, the formatter id to use and calculates the next update for the Aura
function E:GetTimeInfo(s, threshhold)
	if s < MINUTE then
		if s >= threshhold then
			return floor(s), 3, 0.51
		else
			return s, 4, 0.051
		end
	elseif s < HOUR then
		local minutes = tonumber(E:Round(s/MINUTE))
		return ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAY then
		local hours = tonumber(E:Round(s/HOUR))
		return ceil(s / HOUR), 1, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = tonumber(E:Round(s/DAY))
		return ceil(s / DAY), 0,  days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

local ninetyDegreeAngleInRadians = (3.141592653589793 / 2) 
local function GetPosition(unit, mapScan)
	local m, f, x, y
	if unit == "player" or UnitIsUnit("player", unit) then
		m, f, x, y = Astrolabe:GetCurrentPlayerPosition()
	else
		m, f, x, y = Astrolabe:GetUnitPosition(unit, mapScan or WorldMapFrame:IsVisible())
	end

	if not (m and y) then
		return false
	else
		return true, m, f, x, y
	end
end

function E:GetDistance(unit1, unit2, mapScan)
	local canCalculate, m1, f1, x1, y1 = GetPosition(unit1, mapScan)

	if not canCalculate then return end

	local canCalculate, m2, f2, x2, y2 = GetPosition(unit2, mapScan)

	if not canCalculate then return end

	local distance, xDelta, yDelta = Astrolabe:ComputeDistance(m1, f1, x1, y1, m2, f2, x2, y2)
	if distance and xDelta and yDelta then
		return distance, -ninetyDegreeAngleInRadians -GetPlayerFacing() - atan2(yDelta, xDelta) 
	elseif distance then
		return distance
	end
end