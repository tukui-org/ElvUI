local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgscore ~= true then return end

	-- Macro to show the WorldStateScoreFrame: /run WorldStateScoreFrame:Show()

	local WorldStateScoreFrame = _G["WorldStateScoreFrame"]
	_G["WorldStateScoreScrollFrame"]:StripTextures()
	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:SetTemplate("Transparent")
	S:HandleCloseButton(WorldStateScoreFrameCloseButton)
	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar)
	WorldStateScoreFrameInset:SetAlpha(0)
	S:HandleButton(WorldStateScoreFrameLeaveButton)
	S:HandleButton(WorldStateScoreFrameQueueButton)
	for i = 1, 3 do
		S:HandleTab(_G["WorldStateScoreFrameTab"..i])
	end

	WorldStateScoreFrame.XPBar:StripTextures()
	WorldStateScoreFrame.XPBar.Bar:CreateBackdrop("Default")
	WorldStateScoreFrame.XPBar.Bar.Spark:SetAlpha(0)

	WorldStateScoreFrame.XPBar.NextAvailable:ClearAllPoints()
	WorldStateScoreFrame.XPBar.NextAvailable:SetPoint("LEFT", WorldStateScoreFrame.XPBar.Bar, "RIGHT", -2, -2)

	WorldStateScoreFrame.XPBar.NextAvailable:StripTextures()
	WorldStateScoreFrame.XPBar.NextAvailable:CreateBackdrop("Default")
	WorldStateScoreFrame.XPBar.NextAvailable.backdrop:SetPoint("TOPLEFT", WorldStateScoreFrame.XPBar.NextAvailable.Icon, -2, 2)
	WorldStateScoreFrame.XPBar.NextAvailable.backdrop:SetPoint("BOTTOMRIGHT", WorldStateScoreFrame.XPBar.NextAvailable.Icon, 2, -2)

	WorldStateScoreFrame.XPBar.NextAvailable.Icon:SetDrawLayer("ARTWORK")
	WorldStateScoreFrame.XPBar.NextAvailable.Icon:SetTexCoord(unpack(E.TexCoords))
	-- This seems to break some icons at higher prestige level. ElvUI/issue#1853
	-- WorldStateScoreFrame.XPBar.NextAvailable.Icon.SetTexCoord = E.noop
end

S:AddCallback("WorldStateScore", LoadSkin)