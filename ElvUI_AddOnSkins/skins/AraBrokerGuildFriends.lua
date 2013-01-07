local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local function SkinAraGF(self, event, ...)
    local AraGuildFriends = _G["AraBrokerGuildFriends"]
    AraGuildFriends:StripTextures()
    AraGuildFriends:SetTemplate("Default")
end

local name = "AraBrokerGuildFriendsSkin"
local function SkinAraBrokerGuildFriends(self)
    local AraGuildFriends = _G["AraBrokerGuildFriends"]
    AraGuildFriends:SetScript("OnUpdate", SkinAraGF)
end
AS:RegisterSkin(name,SkinAraBrokerGuildFriends)