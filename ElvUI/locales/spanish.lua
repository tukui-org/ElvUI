local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("ElvuiConfig", "esES") or AceLocale:NewLocale("ElvuiConfig", "esMX")
if not L then return end

--Copy the entire english file here and set values = to something
--[[
	Where it says:
	L["Auto Scale"] = true
	
	That just means thats default, you can still set it to say something else like this
	L["Auto Scale"] = "Blah blah, speaking another language, blah blah"
	
	You can post the file here for it to be added to default ElvUI files: http://www.tukui.org/forums/forum.php?id=88
]]