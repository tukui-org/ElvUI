local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables


local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end

	--[[ Main Frame ]]--

	local Frame = _G.AuctionHouseFrame
	S:HandlePortraitFrame(Frame)

	local Tabs = {
		_G.AuctionHouseFrameBuyTab,
		_G.AuctionHouseFrameSellTab,
		_G.AuctionHouseFrameAuctionsTab,
	}

	for _, tab in pairs(Tabs) do
		if tab then
			S:HandleTab(tab)
		end
	end

	S:HandleButton(Frame.SearchBar.FavoritesSearchButton)
	Frame.SearchBar.FavoritesSearchButton:SetSize(22, 22)
	S:HandleEditBox(Frame.SearchBar.SearchBox)
	S:HandleButton(Frame.SearchBar.FilterButton)
	S:HandleCloseButton(Frame.SearchBar.FilterButton.ClearFiltersButton)
	S:HandleButton(Frame.SearchBar.SearchButton)

	--[[ Categorie List ]]--
	local Categories = Frame.CategoriesList
	Categories.ScrollFrame:StripTextures()
	Categories.Background:Hide()
	Categories.NineSlice:Hide()

	S:HandleScrollBar(_G.AuctionHouseFrameScrollBar)
end

S:AddCallbackForAddon("Blizzard_AuctionHouseUI", "AuctionHouse", LoadSkin)
