local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


function E.UIScale()
	if C["general"].autoscale == true then C["general"].uiscale = min(2, max(.64, 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))) end
	
	if tonumber(string.match(GetCVar("gxResolution"), "(%d+)x%d+")) <= 1440 then
		E.lowversion = true
	else
		E.lowversion = false
	end
end
E.UIScale()

-- pixel perfect script of custom ui scale.
local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/C["general"].uiscale
local function scale(x)
    return mult*math.floor(x/mult+.5)
end

function E.Scale(x) return scale(x) end
E.mult = mult