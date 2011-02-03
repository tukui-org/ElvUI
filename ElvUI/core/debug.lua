--@@ DEBUG MODE @@
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local print = function(...)
	return print('|cff1784d1ElvUI:|r', ...)
end

function E.debug(...)
	if C["debug"].enabled ~= true then return end
	print(tostring(...))
end

if C["debug"].enabled ~= true then return end

if C["debug"].events == true then
	C["chat"].chatheight = 500
	local x = CreateFrame("Frame")
	x:RegisterAllEvents()
	x:SetScript("OnEvent", function(self, event)
		print(event)
	end)
end