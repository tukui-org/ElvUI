local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_WarfrontsPartyPoseUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.islandsPartyPose) then return end

	local WarfrontsPartyPoseFrame = _G.WarfrontsPartyPoseFrame
	WarfrontsPartyPoseFrame:StripTextures()
	WarfrontsPartyPoseFrame:SetTemplate('Transparent')

	S:HandleButton(WarfrontsPartyPoseFrame.LeaveButton)

	local ModelScene = WarfrontsPartyPoseFrame.ModelScene
	if ModelScene then
		ModelScene:StripTextures()
		ModelScene:SetTemplate('Transparent')
	end

	local RewardFrame = WarfrontsPartyPoseFrame.RewardAnimations.RewardFrame
	if RewardFrame then
		RewardFrame:CreateBackdrop('Transparent')
		RewardFrame.backdrop:Point('TOPLEFT', -5, 5)
		RewardFrame.backdrop:Point('BOTTOMRIGHT', RewardFrame.NameFrame, 0, -5)

		RewardFrame.NameFrame:SetAlpha(0)
		RewardFrame.IconBorder:Kill()
		RewardFrame.Icon:SetTexCoords()
	end
end

S:AddCallbackForAddon('Blizzard_WarfrontsPartyPoseUI')
