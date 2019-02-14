local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgscore ~= true then return end

	-- Macro to show the WorldStateScoreFrame: /run WorldStateScoreFrame:Show()
	local WorldStateScoreFrame = _G.WorldStateScoreFrame
	_G.WorldStateScoreScrollFrame:StripTextures()
	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:SetTemplate("Transparent")
	S:HandleCloseButton(_G.WorldStateScoreFrameCloseButton)
	S:HandleScrollBar(_G.WorldStateScoreScrollFrameScrollBar)
	_G.WorldStateScoreFrameInset:SetAlpha(0)
	S:HandleButton(_G.WorldStateScoreFrameLeaveButton)
	S:HandleButton(_G.WorldStateScoreFrameQueueButton)

	for i = 1, 3 do
		S:HandleTab(_G["WorldStateScoreFrameTab"..i])
	end

	S:SkinPVPHonorXPBar('WorldStateScoreFrame')
end

S:AddCallback("WorldStateScore", LoadSkin)
