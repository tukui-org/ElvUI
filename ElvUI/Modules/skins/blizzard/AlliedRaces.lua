local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AlliedRaces ~= true then return end

	-- AlliedRacesFrame:StripTextures() -- this will hide almost everything, not cool
	AlliedRacesFrame:CreateBackdrop("Transparent")
	AlliedRacesFrameBg:Hide()
	AlliedRacesFramePortrait:Hide()
	AlliedRacesFramePortraitFrame:Hide()
	AlliedRacesFrameTitleBg:Hide()
	AlliedRacesFrameTopBorder:Hide()
	AlliedRacesFrameTopRightCorner:Hide()
	AlliedRacesFrameRightBorder:Hide()
	AlliedRacesFrameBotRightCorner:Hide()
	AlliedRacesFrameBotLeftCorner:Hide()
	AlliedRacesFrameBtnCornerRight:Hide()
	AlliedRacesFrameBtnCornerLeft:Hide()
	AlliedRacesFrameButtonBottomBorder:Hide()
	AlliedRacesFrameBottomBorder:Hide()
	AlliedRacesFrameLeftBorder:Hide()
	AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar.Border:Hide()
	AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar.ScrollUpBorder:Hide()
	AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar.ScrollDownBorder:Hide()
	AlliedRacesFrame.ModelFrame:StripTextures()

	S:HandleCloseButton(AlliedRacesFrameCloseButton)
	S:HandleScrollBar(AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar)
end

S:AddCallbackForAddon("Blizzard_AlliedRacesUI", "AlliedRaces", LoadSkin)
