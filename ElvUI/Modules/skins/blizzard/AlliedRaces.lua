local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
local _G = _G
--Lua functions
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AlliedRaces ~= true then return end

	-- AlliedRacesFrame:StripTextures() -- this will hide almost everything, not cool
	_G.AlliedRacesFrame:CreateBackdrop("Transparent")
	_G.AlliedRacesFrameBg:Hide()
	_G.AlliedRacesFramePortrait:Hide()
	_G.AlliedRacesFramePortraitFrame:Hide()
	_G.AlliedRacesFrameTitleBg:Hide()
	_G.AlliedRacesFrameTopBorder:Hide()
	_G.AlliedRacesFrameTopRightCorner:Hide()
	_G.AlliedRacesFrameRightBorder:Hide()
	_G.AlliedRacesFrameBotRightCorner:Hide()
	_G.AlliedRacesFrameBotLeftCorner:Hide()
	_G.AlliedRacesFrameBtnCornerRight:Hide()
	_G.AlliedRacesFrameBtnCornerLeft:Hide()
	_G.AlliedRacesFrameButtonBottomBorder:Hide()
	_G.AlliedRacesFrameBottomBorder:Hide()
	_G.AlliedRacesFrameLeftBorder:Hide()
	_G.AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar.Border:Hide()
	_G.AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar.ScrollUpBorder:Hide()
	_G.AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar.ScrollDownBorder:Hide()
	_G.AlliedRacesFrame.ModelFrame:StripTextures()

	S:HandleCloseButton(_G.AlliedRacesFrameCloseButton)
	S:HandleScrollBar(_G.AlliedRacesFrame.RaceInfoFrame.ScrollFrame.ScrollBar)
end

S:AddCallbackForAddon("Blizzard_AlliedRacesUI", "AlliedRaces", LoadSkin)
