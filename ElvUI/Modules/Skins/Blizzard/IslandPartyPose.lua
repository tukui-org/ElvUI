local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_IslandsPartyPoseUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.islandsPartyPose) then return end

	local IslandsPartyPoseFrame = _G.IslandsPartyPoseFrame
	IslandsPartyPoseFrame:StripTextures()
	IslandsPartyPoseFrame:SetTemplate('Transparent')
	S:HandleButton(IslandsPartyPoseFrame.LeaveButton)
end

S:AddCallbackForAddon('Blizzard_IslandsPartyPoseUI')
