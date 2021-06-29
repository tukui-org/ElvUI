local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

function S:Blizzard_WarfrontsPartyPoseUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.IslandsPartyPose) then return end

	local WarfrontsPartyPoseFrame = _G.WarfrontsPartyPoseFrame
	WarfrontsPartyPoseFrame:StripTextures()
	WarfrontsPartyPoseFrame:SetTemplate('Transparent')

	local modelScene = WarfrontsPartyPoseFrame.ModelScene
	modelScene:StripTextures()
	modelScene:SetTemplate('Transparent')

	S:HandleButton(WarfrontsPartyPoseFrame.LeaveButton)

	local rewardFrame = WarfrontsPartyPoseFrame.RewardAnimations.RewardFrame
	rewardFrame:CreateBackdrop('Transparent')
	rewardFrame.backdrop:Point('TOPLEFT', -5, 5)
	rewardFrame.backdrop:Point('BOTTOMRIGHT', rewardFrame.NameFrame, 0, -5)

	rewardFrame.NameFrame:SetAlpha(0)
	rewardFrame.IconBorder:Kill()
	rewardFrame.Icon:SetTexCoord(unpack(E.TexCoords))
end

S:AddCallbackForAddon('Blizzard_WarfrontsPartyPoseUI')
