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




--lol
if(UnitName("player") == "Sarah" and GetRealmName() == "Spirestone") then
	local f = CreateFrame("Frame")
	local min, max = 1800, 3600
	local howdyDelayTime = math.random(min, max)
	local howdySongDelayTime = math.random(1, 14400)
	local sangSong = false
	f:SetScript("OnUpdate", function(self, elapsed)
		self.howdyTime = (self.howdyTime or 0) + elapsed
		self.howdySongTime = (self.howdySongTime or 0) + elapsed
		if(self.howdyTime > howdyDelayTime) then
			SendChatMessage("HOWDY HO!", "YELL")
			howdyDelayTime = math.random(min, max)
			self.howdyTime = 0
		end
		if(self.howdySongTime > howdySongDelayTime and not sangSong) then
			SendChatMessage("Mr. Hankey the Christmas Poo!", "YELL")
			SendChatMessage("He loves me I love you", "YELL")
			SendChatMessage("Therefore vicariously he loves you", "YELL")
			SendChatMessage("I can make a Mr Hankey too!", "YELL")
			ElvUI[1]:Delay(1, DoEmote, "fart")
			sangSong = true
		end
	end)
end