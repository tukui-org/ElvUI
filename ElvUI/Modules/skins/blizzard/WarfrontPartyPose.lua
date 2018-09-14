local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.IslandsPartyPose ~= true then return end

	local WarfrontsPartyPoseFrame = _G["WarfrontsPartyPoseFrame"]
	WarfrontsPartyPoseFrame:StripTextures()
	WarfrontsPartyPoseFrame:CreateBackdrop("Transparent")

	local modelScene = WarfrontsPartyPoseFrame.ModelScene
	modelScene:StripTextures()
	modelScene:CreateBackdrop("Transparent")

	S:HandleButton(WarfrontsPartyPoseFrame.LeaveButton)

	local rewardFrame = WarfrontsPartyPoseFrame.RewardAnimations.RewardFrame
	rewardFrame:CreateBackdrop("Transparent")
	rewardFrame.backdrop:SetPoint("TOPLEFT", -5, 5)
	rewardFrame.backdrop:SetPoint("BOTTOMRIGHT", rewardFrame.NameFrame, 0, -5)

	rewardFrame.NameFrame:SetAlpha(0)
	rewardFrame.IconBorder:SetAlpha(0)
	rewardFrame.Icon:SetTexCoord(unpack(E.TexCoords))
end

S:AddCallbackForAddon("Blizzard_WarfrontsPartyPoseUI", "WarfrontPartyPose", LoadSkin)