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

	local CornerVisitorFrame = _G.HousingCornerstoneVisitorFrame
	if CornerVisitorFrame then
		CornerVisitorFrame:StripTextures()
		CornerVisitorFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(CornerVisitorFrame.CloseButton)
	end

	local CornerInfoFrame = _G.HousingCornerstoneHouseInfoFrame
	if CornerInfoFrame then
		CornerInfoFrame:StripTextures()
		CornerInfoFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(CornerInfoFrame.CloseButton)
	end
end

S:AddCallbackForAddon('Blizzard_HousingCornerstone')


function S:Blizzard_HousingBulletinBoard()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local BulletinBoardFrame = _G.HousingBulletinBoardFrame
	if BulletinBoardFrame then
		BulletinBoardFrame:StripTextures()
		-- BulletinBoardFrame.FoliageDecoration:Kill() -- grrr
		S:HandleCloseButton(BulletinBoardFrame.CloseButton)

		local ResidentsTab = BulletinBoardFrame.ResidentsTab
		if ResidentsTab then
			S:HandleTrimScrollBar(ResidentsTab.ScrollBar)
		end
	end
end

S:AddCallbackForAddon('Blizzard_HousingBulletinBoard')


function S:Blizzard_HouseList()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.housing) then return end

	local ListFrame = _G.HouseListFrame
	if ListFrame then
		ListFrame:StripTextures()
		ListFrame:CreateBackdrop('Transparent')
		S:HandleCloseButton(ListFrame.CloseButton)
		S:HandleTrimScrollBar(ListFrame.ScrollBar)
	end
end

S:AddCallbackForAddon('Blizzard_HouseList')
