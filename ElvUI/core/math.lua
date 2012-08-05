local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore

--Return short value of a number
function E:ShortValue(v)
	if v >= 1e6 then
		return ("%.1fm"):format(v / 1e6):gsub("%.?0+([km])$", "%1")
	elseif v >= 1e3 or v <= -1e3 then
		return ("%.1fk"):format(v / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return v
	end
end

function E:IsEvenNumber(num)
	if math.fmod(num, 2) == 0 then
		return true;
	else
		return false;
	end
end

-- http://www.wowwiki.com/ColorGradient
function E:ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3
	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

--Return short negative value of a number, example -1000 returned as string -1k
function E:ShortValueNegative(v)
	if v <= 999 then return v end
	if v >= 1000000 then
		local value = string.format("%.1fm", v/1000000)
		return value
	elseif v >= 1000 then
		local value = string.format("%.1fk", v/1000)
		return value
	end
end

--Return rounded number
function E:Round(v, decimals)
	if not decimals then decimals = 0 end
    return (("%%.%df"):format(decimals)):format(v)
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
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

--Hex to RGB
function E:HexToRGB(hex)
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
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
	local x, y = override or 1, override or 1
	
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

--This is differant than the round function because if a number is 20.0 for example it will return an integer value instead of floating point (20.0 will be 20)
function E:TrimFloatingPoint(number, decimals)
	assert(number, 'You must provide a floating point number to trim decimals from. Usage: E:TrimFloatingPoint(floatingPoint, <decimals>)')
	if not decimals then decimals = 1 end
	if number ~= math.floor(number) then
		return string.format("%%.%df", decimals):format(number)
	end
	
	return number
end

local styles = {
	['CURRENT'] = '|cff%02x%02x%02x%s|r',
	['CURRENT_MAX'] = '|cff%02x%02x%02x%s|r |cff%02x%02x%02x-|r |cff%02x%02x%02x%s|r',
	['CURRENT_PERCENT'] =  '|cff%02x%02x%02x%s|r |cff%02x%02x%02x-|r |cff%02x%02x%02x%s%%|r',
	['CURRENT_MAX_PERCENT'] = '|cff%02x%02x%02x%s|r |cff%02x%02x%02x-|r |cff%02x%02x%02x%s|r |cff%02x%02x%02x| |r|cff%02x%02x%02x%s%%|r',
	['PERCENT'] = '|cff%02x%02x%02x%s%%|r',
}

function E:GetFormattedText(style, min, max, badR, badG, badB, goodR, goodG, goodB, seperatorR, seperatorG, seperatorB)
	assert(styles[style], 'Invalid format style: '..style)
	assert(min, 'You need to provide a current value. Usage: E:GetFormattedText(style, min, max)')
	assert(max, 'You need to provide a maximum value. Usage: E:GetFormattedText(style, min, max)')
	
	local useStyle = styles[style]
	
	if not seperatorR or not seperatorG or not seperatorB then
		seperatorR, seperatorG, seperatorB = 1, 1, 1
	end	
	
	if not badR or not badG or not badB then
		badR, badG, badB = 1, 1, 1
	end
	
	if not goodR or not goodG or not goodB then
		goodR, goodG, goodB = badR, badG, badB
	end	
	
	if min == max then
		badR, badG, badB = goodR, goodG, goodB
	end
	
	badR, badG, badB = badR * 255, badG  * 255, badB  * 255
	goodR, goodG, goodB = goodR * 255, goodG  * 255, goodB  * 255
	seperatorR, seperatorG, seperatorB = seperatorR * 255, seperatorG  * 255, seperatorB  * 255
	
	local percentValue = E:TrimFloatingPoint(min / max * 100)
	
	if style == 'PERCENT' then
		return string.format(useStyle, badR, badG, badB, min / max * 100)
	elseif style == 'CURRENT' or ((style == 'CURRENT_MAX' or style == 'CURRENT_MAX_PERCENT' or style == 'CURRENT_PERCENT') and min == max) then
		return string.format(styles['CURRENT'], badR, badG, badB,  E:ShortValue(min))
	elseif style == 'CURRENT_MAX' then
		return string.format(useStyle,  badR, badG, badB,  E:ShortValue(min), seperatorR, seperatorG, seperatorB,  goodR, goodG, goodB, E:ShortValue(max))
	elseif style == 'CURRENT_PERCENT' then
		return string.format(useStyle, badR, badG, badB, E:ShortValue(min), seperatorR, seperatorG, seperatorB, goodR, goodG, goodB, percentValue)
	elseif style == 'CURRENT_MAX_PERCENT' then
		return string.format(useStyle, badR, badG, badB, E:ShortValue(min), seperatorR, seperatorG, seperatorB, badR, badG, badB, E:ShortValue(max), seperatorR, seperatorG, seperatorB, goodR, goodG, goodB, percentValue)
	end
end

function E:ShortenString(string, numChars, dots)
	assert(string, 'You need to provide a string to shorten. Usage: E:ShortenString(string, numChars, includeDots)')
	assert(string, 'You need to provide a length to shorten the string to. Usage: E:ShortenString(string, numChars, includeDots)')
	
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
	return str:gsub("(.)", string.upper, 1)
end