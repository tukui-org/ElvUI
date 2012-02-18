local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.db.skins.blizzard.enable ~= true or E.db.skins.blizzard.bgscore ~= true then return end
	WorldStateScoreScrollFrame:StripTextures()
	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:SetTemplate("Transparent")
	S:HandleCloseButton(WorldStateScoreFrameCloseButton)
	WorldStateScoreFrameInset:Kill()
	S:HandleButton(WorldStateScoreFrameLeaveButton)
	
	for i = 1, WorldStateScoreScrollFrameScrollChildFrame:GetNumChildren() do
		local b = _G["WorldStateScoreButton"..i]
		b:StripTextures()
		b:StyleButton(false)
		b:SetTemplate("Default", true)
	end
	
	for i = 1, 3 do 
		S:HandleTab(_G["WorldStateScoreFrameTab"..i])
	end
end

S:RegisterSkin('ElvUI', LoadSkin)