local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

function E.UIScale()
	if C["general"].autoscale == true then
		C["general"].uiscale = min(2, max(.64, 768/string.match(E.resolution, "%d+x(%d+)")))
	end

	E.lowversion = false

	if E.screenwidth < 1600 then
			E.lowversion = true
	elseif E.screenwidth >= 3840 or (UIParent:GetWidth() + 1 > E.screenwidth) then
		local width = E.screenwidth
		local height = E.screenheight
	
		-- because some user enable bezel compensation, we need to find the real width of a single monitor.
		-- I don't know how it really work, but i'm assuming they add pixel to width to compensate the bezel. :P

		-- HQ resolution
		if width >= 9840 then width = 3280 end                   	                -- WQSXGA
		if width >= 7680 and width < 9840 then width = 2560 end                     -- WQXGA
		if width >= 5760 and width < 7680 then width = 1920 end 	                -- WUXGA & HDTV
		if width >= 5040 and width < 5760 then width = 1680 end 	                -- WSXGA+

		-- adding height condition here to be sure it work with bezel compensation because WSXGA+ and UXGA/HD+ got approx same width
		if width >= 4800 and width < 5760 and height == 900 then width = 1600 end   -- UXGA & HD+

		-- low resolution screen
		if width >= 4320 and width < 4800 then width = 1440 end 	                -- WSXGA
		if width >= 4080 and width < 4320 then width = 1360 end 	                -- WXGA
		if width >= 3840 and width < 4080 then width = 1224 end 	                -- SXGA & SXGA (UVGA) & WXGA & HDTV
		
		-- yep, now set Elvui to lower reso if screen #1 width < 1600
		if width < 1600 then
			E.lowversion = true
		end
		
		-- register a constant, we will need it later for launch.lua
		E.eyefinity = width
	end
	
	if C["general"].resolutionoverride == "Low" then
		E.lowversion = true
	elseif C["general"].resolutionoverride == "High" then
		E.lowversion = false
	end
	
	--Set a value for unitframe scaling
	if E.lowversion == true then
		E.ResScale = 0.9
	else
		E.ResScale = 1
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