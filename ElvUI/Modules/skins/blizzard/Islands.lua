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
	-- The Frame have some nice textures, so don't use :StripTextures()
	IslandsFrame.HelpButton:Hide()
	IslandsFrame.ArtOverlayFrame.portrait:Hide()
	IslandsFrame.ArtOverlayFrame.PortraitFrame:Hide()
	IslandsFrame.TopWoodBorder:Hide()
	IslandsFrame.LeftWoodBorder:Hide()
	IslandsFrame.RightWoodBorder:Hide()
	IslandsFrame.BottomWoodBorder:Hide()
	IslandsFrame.TopBorder:Hide()
	IslandsQueueFrameLeftBorder:Hide()
	IslandsQueueFrameRightBorder:Hide()
	IslandsQueueFrameBottomBorder:Hide()
	IslandsQueueFrameTopRightCorner:Hide()
	IslandsQueueFrameTopLeftCorner:Hide()
	IslandsQueueFrameBotLeftCorner:Hide()
	IslandsQueueFrameBotRightCorner:Hide()
	IslandsQueueFramePortrait:Hide()
	IslandsQueueFramePortraitFrame:Hide()

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

	-- TO DO: Handle the Reward-Tooltip

	-- Maybe Adjust me
	local TutorialFrame = IslandsFrame.TutorialFrame
	S:HandleButton(TutorialFrame.Leave)
	S:HandleCloseButton(TutorialFrame.CloseButton)
end

S:AddCallbackForAddon("Blizzard_IslandsQueueUI", "Islands", LoadSkin)