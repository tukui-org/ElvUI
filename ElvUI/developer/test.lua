--[[
	Going to leave this as my bullshit lua file.
	
	So I can test stuff.
]]
local BlazeGrip = CreateFrame("Button", "BlazeGripButton", UIParent, "SecureActionButtonTemplate, ActionButtonTemplate")
BlazeGrip:SetPoint("CENTER")
BlazeGrip:SetWidth(60)
BlazeGrip:SetHeight(60)
BlazeGrip:Hide()

BlazeGrip.Tex = BlazeGrip:CreateTexture(nil, "OVERLAY")
BlazeGrip.Tex:SetAllPoints()
BlazeGrip.Tex:SetTexture("INTERFACE\\ICONS\\priest_spell_leapoffaith_a")

local Check = CreateFrame("Frame")
Check:RegisterEvent("CHAT_MSG_WHISPER")
Check:RegisterEvent("CHAT_MSG_BN_WHISPER")
Check:SetScript("OnEvent", function(self, event, msg, sender)
	if string.find(string.lower(msg), "!grip") then
		local InRange = UnitInRange(sender)
		local _, timeLeft = GetSpellCooldown(73325)
		
		if timeLeft ~= 0 then
			SendChatMessage("Leap of Faith is currently on cooldown, sorry!", "WHISPER", nil, sender)
		elseif InRange then
			BlazeGrip:SetAttribute("type1", "macro")
			BlazeGrip:SetAttribute("macrotext", "/tar "..sender.."\n/cast Leap of Faith\n/run BlazeGripButton:Hide()")
			BlazeGrip:Show()
		else
			SendChatMessage("You're not in range for Leap of Faith, get closer!", "WHISPER", nil, sender)
		end
	end
end)