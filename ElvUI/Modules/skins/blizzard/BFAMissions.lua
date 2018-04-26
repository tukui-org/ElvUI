local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.BFAMissions ~= true then return end

	-------------
	--  Temp   --
	-------------
	local MissionFrame = _G["BFAMissionFrame"]
	MissionFrame:StripTextures()
	MissionFrame:CreateBackdrop("Transparent")

	MissionFrame.GarrCorners:Hide()

	S:HandleCloseButton(MissionFrame.CloseButton)

	for i = 1, 3 do
		S:HandleTab(_G["BFAMissionFrameTab"..i])
	end

	-- Mission Tab
	S:HandleScrollBar(_G["BFAMissionFrameMissionsListScrollFrameScrollBar"])

	-- Follower Tab
	local Follower = _G["BFAMissionFrameFollowers"]
	local XPBar = MissionFrame.FollowerTab.XPBar
	local Class = MissionFrame.FollowerTab.Class
	Follower:StripTextures()
	Follower:SetTemplate("Transparent")
	S:HandleEditBox(Follower.SearchBox)
	S:HandleScrollBar(_G["BFAMissionFrameFollowersListScrollFrameScrollBar"])

	--S:HandleFollowerPage("BFAMissionFrameFollowers") -- The function needs to be updated for BFA

	XPBar:StripTextures()
	XPBar:SetStatusBarTexture(E["media"].normTex)
	XPBar:CreateBackdrop()

	Class:SetSize(50, 43)

	-- Scouting Map
	-- Probably takes the skin from OrderHallUI
end

S:AddCallbackForAddon('Blizzard_GarrisonUI', "BFAMissions", LoadSkin)