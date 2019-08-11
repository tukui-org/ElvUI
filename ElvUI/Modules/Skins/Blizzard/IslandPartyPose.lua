local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.IslandsPartyPose ~= true then return end

	local IslandsPartyPoseFrame = _G.IslandsPartyPoseFrame
	IslandsPartyPoseFrame:StripTextures()
	IslandsPartyPoseFrame:CreateBackdrop("Transparent")
	S:HandleButton(IslandsPartyPoseFrame.LeaveButton)
end

S:AddCallbackForAddon("Blizzard_IslandsPartyPoseUI", "IslandPartyPose", LoadSkin)
