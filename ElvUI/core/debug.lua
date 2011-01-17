--@@ DEBUG MODE @@
local ElvCF = ElvCF

local print = function(...)
	return print('|cffFF6347ElvUI:|r', ...)
end

function ElvDB.debug(...)
	if ElvCF["debug"].enabled ~= true then return end
	print(tostring(...))
end

if ElvCF["debug"].enabled ~= true then return end

if ElvCF["debug"].events == true then
	ElvCF["chat"].chatheight = 500
	local x = CreateFrame("Frame")
	x:RegisterAllEvents()
	x:SetScript("OnEvent", function(self, event)
		print(event)
	end)
end