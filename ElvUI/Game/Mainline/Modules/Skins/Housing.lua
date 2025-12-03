local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_HousingHouseFinder()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local FinderFrame = _G.HouseFinderFrame
	if FinderFrame then
		S:HandleFrame(FinderFrame, true)
	end

	local NeighborhoodListFrame = FinderFrame.NeighborhoodListFrame
	if NeighborhoodListFrame then
		NeighborhoodListFrame:StripTextures()

		NeighborhoodListFrame.BNetFriendSearchBox:DisableDrawLayer('BACKGROUND') -- Pimp me a bit
		S:HandleEditBox(NeighborhoodListFrame.BNetFriendSearchBox)
		S:HandleButton(NeighborhoodListFrame.RefreshButton)
	end
end

S:AddCallbackForAddon('Blizzard_HousingHouseFinder')


function S:Blizzard_HousingCornerstone()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local CornerFrame = _G.HousingCornerstoneVisitorFrame
	if CornerFrame then
		CornerFrame:StripTextures()
		CornerFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(CornerFrame.CloseButton)
	end
end

S:AddCallbackForAddon('Blizzard_HousingCornerstone')
