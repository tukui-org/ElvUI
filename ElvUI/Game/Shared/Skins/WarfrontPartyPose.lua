local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_WarfrontsPartyPoseUI', nil, nil, nil, nil, nil, 'islandsPartyPose')

function S:Blizzard_WarfrontsPartyPoseUI()
	local poseFrame = _G.WarfrontsPartyPoseFrame
	poseFrame:StripTextures()
	poseFrame:SetTemplate('Transparent')

	S:HandleButton(poseFrame.LeaveButton)

	local modelScene = poseFrame.ModelScene
	modelScene:StripTextures()
	modelScene:SetTemplate('Transparent')

	local RewardFrame = poseFrame.RewardAnimations.RewardFrame
	RewardFrame:CreateBackdrop('Transparent')
	RewardFrame.backdrop:Point('TOPLEFT', -5, 5)
	RewardFrame.backdrop:Point('BOTTOMRIGHT', RewardFrame.NameFrame, 0, -5)

	RewardFrame.NameFrame:SetAlpha(0)
	RewardFrame.IconBorder:Kill()
	RewardFrame.Icon:SetTexCoords()
end
