--@@ DEBUG MODE @@
local ElvCF = ElvCF

local print = function(...)
	return print('|cff33ff99ElvUI:|r', ...)
end

function ElvDB.debug(...)
	if ElvCF["debug"].enabled ~= true then return end
	print(tostring(...))
end

if ElvCF["debug"].enabled ~= true then return end

ElvCF["chat"].chatheight = 500

if ElvCF["debug"].events == true then
	local x = CreateFrame("Frame")
	x:RegisterAllEvents()
	x:SetScript("OnEvent", function(self, event)
		print(event)
	end)
end