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

	_G["BFAMissionFrame"]:StripTextures()
	_G["BFAMissionFrame"]:CreateBackdrop("Transparent")

	_G["BFAMissionFrame"].GarrCorners:Hide()

	S:HandleCloseButton(_G["BFAMissionFrame"].CloseButton)

	for i = 1, 3 do
		S:HandleTab(_G["BFAMissionFrameTab"..i])
	end

	-- Mission Tab
	S:HandleScrollBar(_G["BFAMissionFrameMissionsListScrollFrameScrollBar"])

	-- Follower Tab
	S:HandleScrollBar(_G["BFAMissionFrameFollowersListScrollFrameScrollBar"])

	-- Scouting Map
	-- Probably takes the skin from OrderHallUI
end

S:AddCallbackForAddon('Blizzard_GarrisonUI', "BFAMissions", LoadSkin)