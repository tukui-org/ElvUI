local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_IslandsPartyPoseUI', nil, nil, nil, nil, nil, 'islandsPartyPose')

function S:Blizzard_IslandsPartyPoseUI()
	local IslandsPartyPoseFrame = _G.IslandsPartyPoseFrame
	IslandsPartyPoseFrame:StripTextures()
	IslandsPartyPoseFrame:SetTemplate('Transparent')
	S:HandleButton(IslandsPartyPoseFrame.LeaveButton)
end
