local ElvDB = ElvDB
local ElvCF = ElvCF

function ElvDB.UIScale()
	if ElvCF["general"].autoscale == true then ElvCF["general"].uiscale = min(2, max(.64, 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))) end
	
	if tonumber(string.match(GetCVar("gxResolution"), "(%d+)x%d+")) <= 1440 then
		ElvDB.lowversion = true
	else
		ElvDB.lowversion = false
	end
end
ElvDB.UIScale()

-- pixel perfect script of custom ui scale.
local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/ElvCF["general"].uiscale
local function scale(x)
    return mult*math.floor(x/mult+.5)
end

function ElvDB.Scale(x) return scale(x) end
ElvDB.mult = mult