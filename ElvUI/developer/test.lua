--[[
	Going to leave this as my bullshit lua file.
	
	So I can test stuff.
]]


--Remove PVPBank.com spam from friends request
local function RemoveSpam()
    for i=1, BNGetNumFriendInvites() do
        local id, _ ,_ , t = BNGetFriendInviteInfo(i)
        if t and t:lower():find("pvpbank") then
            BNDeclineFriendInvite(id)
        end
    end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", RemoveSpam)
f:RegisterEvent("BN_FRIEND_INVITE_ADDED")
f:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED")
f:RegisterEvent("BN_CONNECTED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")



