local TukuiDB = TukuiDB
local TukuiCF = TukuiCF

function TukuiDB.UIScale()
	if TukuiCF["general"].autoscale == true then TukuiCF["general"].uiscale = min(2, max(.64, 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))) end
	
	if tonumber(string.match(GetCVar("gxResolution"), "(%d+)x%d+")) <= 1440 then
		TukuiDB.lowversion = true
	else
		TukuiDB.lowversion = false
	end
end
TukuiDB.UIScale()

-- pixel perfect script of custom ui scale.
local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/TukuiCF["general"].uiscale
local function scale(x)
    return mult*math.floor(x/mult+.5)
end

function TukuiDB.Scale(x) return scale(x) end
TukuiDB.mult = mult