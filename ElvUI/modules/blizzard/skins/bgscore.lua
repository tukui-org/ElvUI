local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].bgscore ~= true then return end

local function LoadSkin()
	WorldStateScoreScrollFrame:StripTextures()
	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:SetTemplate("Transparent")
	E.SkinCloseButton(WorldStateScoreFrameCloseButton)
	WorldStateScoreFrameInset:Kill()
	E.SkinButton(WorldStateScoreFrameLeaveButton)
	
	for i = 1, WorldStateScoreScrollFrameScrollChildFrame:GetNumChildren() do
		local b = _G["WorldStateScoreButton"..i]
		b:StripTextures()
		b:StyleButton(false)
		b:SetTemplate("Default", true)
	end
	
	for i = 1, 3 do 
		E.SkinTab(_G["WorldStateScoreFrameTab"..i])
	end
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)