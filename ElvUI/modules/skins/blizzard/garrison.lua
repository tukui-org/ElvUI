local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if not stupidSkinComplete then return end

	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.garrison ~= true then return end

	S:HandleScrollBar(GarrisonLandingPageListListScrollFrameScrollBar)
	S:HandleCloseButton(GarrisonLandingPage.CloseButton)
	GarrisonLandingPage.CloseButton:SetFrameStrata("HIGH")

	for i = 1, GarrisonLandingPageListListScrollFrameScrollChild:GetNumChildren() do
		local child = select(i, GarrisonLandingPageListListScrollFrameScrollChild:GetChildren())
		for j = 1, child:GetNumChildren() do
			local childC = select(j, child:GetChildren())
			childC.Icon:SetTexCoord(unpack(E.TexCoords))
		end
	end

end

S:RegisterSkin('Blizzard_GarrisonUI', LoadSkin)