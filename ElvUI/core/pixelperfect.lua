local DB, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


function DB.UIScale()
	if C["general"].autoscale == true then C["general"].uiscale = min(2, max(.64, 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))) end
	
	if tonumber(string.match(GetCVar("gxResolution"), "(%d+)x%d+")) <= 1440 then
		DB.lowversion = true
	else
		DB.lowversion = false
	end
end
DB.UIScale()

-- pixel perfect script of custom ui scale.
local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/C["general"].uiscale
local function scale(x)
    return mult*math.floor(x/mult+.5)
end

function DB.Scale(x) return scale(x) end
DB.mult = mult