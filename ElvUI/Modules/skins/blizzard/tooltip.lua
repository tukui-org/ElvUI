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

local function IslandTooltipStyle(self)
	if not self.IsSkinned then
		self:SetBackdrop(nil)
		self:SetTemplate("Transparent")
		self.IsSkinned = true
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tooltip ~= true then return end

	S:HandleCloseButton(_G.ItemRefCloseButton)

	-- World Quest Reward Icon
	local WorldMapTooltip = _G.WorldMapTooltip
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
	local GameTooltip = _G.GameTooltip
	local GameTooltipStatusBar =  _G.GameTooltipStatusBar
	local StoryTooltip = _G.QuestScrollFrame.StoryTooltip
	StoryTooltip:SetFrameLevel(4)

	local WarCampaignTooltip = _G.QuestScrollFrame.WarCampaignTooltip
	local tooltips = {
		_G.ItemRefTooltip,
		_G.ItemRefShoppingTooltip1,
		_G.ItemRefShoppingTooltip2,
		_G.ItemRefShoppingTooltip3,
		_G.AutoCompleteBox,
		_G.FriendsTooltip,
		_G.ShoppingTooltip1,
		_G.ShoppingTooltip2,
		_G.ShoppingTooltip3,
		_G.WorldMapCompareTooltip1,
		_G.WorldMapCompareTooltip2,
		_G.WorldMapCompareTooltip3,
		_G.ReputationParagonTooltip,
		_G.EmbeddedItemTooltip,
		-- already have locals
		GameTooltip,
		StoryTooltip,
		WorldMapTooltip,
		WarCampaignTooltip,
	}

	for _, tt in pairs(tooltips) do
		TT:SecureHookScript(tt, 'OnShow', 'SetStyle')
	end

	-- EmbeddedItemTooltip
	local reward = _G.EmbeddedItemTooltip.ItemTooltip
	local icon = reward.Icon
	if reward and reward.backdrop then
		reward.backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
		reward.backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
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
	TT:RegisterEvent("ADDON_LOADED", function(_, addon)
		if addon == "Blizzard_IslandsQueueUI" then
			local IslandTooltip = _G.IslandsQueueFrameTooltip
			IslandTooltip:GetParent():GetParent():HookScript("OnShow", IslandTooltipStyle)
			IslandTooltip:GetParent().IconBorder:SetAlpha(0)
			IslandTooltip:GetParent().Icon:SetTexCoord(unpack(E.TexCoords))
		end
	end)
end

S:AddCallback('SkinTooltip', LoadSkin)
