local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local pairs = pairs
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ItemRefTooltip, FriendsTooltip, WorldMapTooltip
-- GLOBALS: WorldMapTaskTooltipStatusBar, ReputationParagonTooltipStatusBar
-- GLOBALS: ItemRefShoppingTooltip1, ItemRefShoppingTooltip2, ItemRefShoppingTooltip3
-- GLOBALS: WorldMapCompareTooltip1, WorldMapCompareTooltip2, WorldMapCompareTooltip3
-- GLOBALS: ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3
-- GLOBALS: ItemRefCloseButton, AutoCompleteBox

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tooltip ~= true then return end

	S:HandleCloseButton(ItemRefCloseButton)

	-- World Quest Reward Icon
	WorldMapTooltip.ItemTooltip.Icon:SetTexCoord(unpack(E.TexCoords))
	WorldMapTooltip.ItemTooltip:CreateBackdrop()
	WorldMapTooltip.ItemTooltip.backdrop:SetOutside(WorldMapTooltip.ItemTooltip.Icon)
	WorldMapTooltip.ItemTooltip.Count:ClearAllPoints()
	WorldMapTooltip.ItemTooltip.Count:SetPoint('BOTTOMRIGHT', WorldMapTooltip.ItemTooltip.Icon, 'BOTTOMRIGHT', 1, 0)
	hooksecurefunc(WorldMapTooltip.ItemTooltip.IconBorder, 'SetVertexColor', function(self, r, g, b)
		self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
		self:SetTexture('')
	end)
	hooksecurefunc(WorldMapTooltip.ItemTooltip.IconBorder, 'Hide', function(self)
		self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	-- Skin Blizzard Tooltips
	local GameTooltip = _G['GameTooltip']
	local GameTooltipStatusBar =  _G['GameTooltipStatusBar']

	local StoryTooltip = QuestScrollFrame.StoryTooltip
	StoryTooltip:SetFrameLevel(4)

	local WarCampaignTooltip = QuestScrollFrame.WarCampaignTooltip

	local tooltips = {
		GameTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ItemRefShoppingTooltip3,
		AutoCompleteBox,
		FriendsTooltip,
		ShoppingTooltip1,
		ShoppingTooltip2,
		ShoppingTooltip3,
		WorldMapTooltip,
		WorldMapCompareTooltip1,
		WorldMapCompareTooltip2,
		WorldMapCompareTooltip3,
		ReputationParagonTooltip,
		StoryTooltip,
		EmbeddedItemTooltip,
		WarCampaignTooltip,
	}

	for _, tt in pairs(tooltips) do
		TT:SecureHookScript(tt, 'OnShow', 'SetStyle')
	end

	-- Skin GameTooltip Status Bar
	GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(GameTooltipStatusBar)
	GameTooltipStatusBar:CreateBackdrop('Transparent')
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:Point("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar:Point("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))

	TT:SecureHook('GameTooltip_ShowStatusBar') -- Skin Status Bars
	TT:SecureHook('GameTooltip_ShowProgressBar') -- Skin Progress Bars
	TT:SecureHook('GameTooltip_AddQuestRewardsToTooltip') -- Color Progress Bars
	TT:SecureHook('GameTooltip_UpdateStyle', 'SetStyle')

	-- [Backdrop coloring] There has to be a more elegant way of doing this.
	TT:SecureHookScript(GameTooltip, 'OnUpdate', 'CheckBackdropColor')

	-- Used for Island Skin
	local function style(self)
		if not self.IsSkinned then
			self:SetBackdrop(nil)
			self:SetTemplate("Transparent")

			self.IsSkinned = true
		end
	end

	TT:RegisterEvent("ADDON_LOADED", function(_, addon)
		if addon == "Blizzard_IslandsQueueUI" then
			local IslandTooltip = _G["IslandsQueueFrameTooltip"]
			IslandTooltip:GetParent():GetParent():HookScript("OnShow", style)
			IslandTooltip:GetParent().IconBorder:SetAlpha(0)
			IslandTooltip:GetParent().Icon:SetTexCoord(unpack(E.TexCoords))
		end
	end)
end

S:AddCallback('SkinTooltip', LoadSkin)
