local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Islands ~= true then return end

	local IslandsFrame = _G["IslandsQueueFrame"]
	IslandsFrame:StripTextures()
	IslandsFrame:CreateBackdrop("Transparent")

	local WeeklyQuest = IslandsFrame.WeeklyQuest
	local StatusBar = WeeklyQuest.StatusBar
	WeeklyQuest.OverlayFrame:StripTextures()

	-- StatusBar
	StatusBar:SetStatusBarTexture(E["media"].normTex)
	E:RegisterStatusBar(StatusBar)
	StatusBar:CreateBackdrop("Default")

	--StatusBar Icon
	WeeklyQuest.QuestReward.Icon:SetTexCoord(unpack(E.TexCoords))

	S:HandleCloseButton(IslandsQueueFrameCloseButton)
	S:HandleButton(IslandsFrame.DifficultySelectorFrame.QueueButton)
end

S:AddCallbackForAddon("Blizzard_IslandsQueueUI", "Islands", LoadSkin)