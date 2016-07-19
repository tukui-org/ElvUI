local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgscore ~= true then return end


	WorldStateScoreScrollFrame:StripTextures()
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
end

S:RegisterSkin('ElvUI', LoadSkin)