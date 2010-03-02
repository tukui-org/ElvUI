if not TukuiErrorHide == true then return end

-- by nc

local f, o, db = CreateFrame("Frame"), "No error yet.", {
	["mode"] = "blacklist", -- This defines the mode of filtering. Options are whitelist and blacklist.
	[ERR_NO_ATTACK_TARGET] = true,
	[OUT_OF_ENERGY] = true,
	[ERR_ABILITY_COOLDOWN] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[ERR_SPELL_COOLDOWN] = true,
	[SPELL_FAILED_INTERRUPTED] = true,
	[SPELL_FAILED_MOVING] = true,
	[SPELL_FAILED_ITEM_NOT_READY] = true,
}

-- DON'T EDIT BELOW THIS LINE --
f:SetScript("OnEvent",function(_,_,e)
	if e=="" then return end
	if db.mode~="whitelist" and not db[e] or db.mode=="whitelist" and db[e] then
	UIErrorsFrame:AddMessage(e,1,0,0) else o=e end
end)
SLASH_NCERROR1 = "/error"
function SlashCmdList.NCERROR() UIErrorsFrame:AddMessage(o,1,0,0) end
UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
f:RegisterEvent("UI_ERROR_MESSAGE")

