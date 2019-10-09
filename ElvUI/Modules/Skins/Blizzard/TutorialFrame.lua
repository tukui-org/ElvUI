local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Tutorials ~= true then return end

	-- Dont use :StripTextures() here
	_G.TutorialFrame:CreateBackdrop("Transparent")
	_G.TutorialFrameBackground:Hide()
	_G.TutorialFrameBackground.Show = E.noop
	_G.TutorialFrame:DisableDrawLayer("BORDER")

	S:HandleCloseButton(_G.TutorialFrameCloseButton)
	S:HandleButton(_G.TutorialFrameOkayButton)
	S:HandleNextPrevButton(_G.TutorialFramePrevButton, "left")
	S:HandleNextPrevButton(_G.TutorialFrameNextButton, "right")
end

S:AddCallback("Tutorial", LoadSkin)
