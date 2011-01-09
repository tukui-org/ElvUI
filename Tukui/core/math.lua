local TukuiDB = TukuiDB

--Return shor value of a number
function TukuiDB.ShortValue(v)
	if v >= 1e6 then
		return ("%.1fm"):format(v / 1e6):gsub("%.?0+([km])$", "%1")
	elseif v >= 1e3 or v <= -1e3 then
		return ("%.1fk"):format(v / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return v
	end
end

--Return short negative value of a number, example -1000 returned as string -1k
function TukuiDB.ShortValueNegative(v)
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
function TukuiDB.Round(v, decimals)
	if not decimals then decimals = 0 end
    return (("%%.%df"):format(decimals)):format(v)
end

--Truncate a number off to n places
function TukuiDB.Truncate(v, decimals)
	if not decimals then decimals = 0 end
    return v - (v % (0.1 ^ decimals))
end

--RGB to Hex
function TukuiDB.RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

--RGBPerc to Hex
function TukuiDB.RGBPercToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

--Hex to RGB
function TukuiDB.HexToRGB(hex)
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return tonumber(rhex, 16), tonumber(ghex, 16), tonumber(bhex, 16)
end