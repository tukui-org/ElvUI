--@@ DEBUG MODE @@
local TukuiCF = TukuiCF

local print = function(...)
	return print('|cff33ff99ElvUI:|r', ...)
end

function TukuiDB.debug(...)
	if TukuiCF["debug"].enabled ~= true then return end
	print(tostring(...))
end

if TukuiCF["debug"].enabled ~= true then return end

TukuiCF["chat"].chatheight = 500

if TukuiCF["debug"].events == true then
	local x = CreateFrame("Frame")
	x:RegisterAllEvents()
	x:SetScript("OnEvent", function(self, event)
		print(event)
	end)
end