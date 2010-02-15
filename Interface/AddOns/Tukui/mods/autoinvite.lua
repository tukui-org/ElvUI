if not TukuiAutoInvite == true then return end

local autoinvite = CreateFrame("frame")
autoinvite:RegisterEvent("CHAT_MSG_WHISPER")
autoinvite:SetScript("OnEvent", function(self,event,arg1,arg2)
    if (not UnitExists("party1") or IsPartyLeader("player")) and arg1:lower():match("invite") or arg1:lower():match("inv") then
        InviteUnit(arg2)
    end
end)