local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

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

	-- Skin Blizzard Tooltips
	local GameTooltip = _G.GameTooltip
	local StoryTooltip = _G.QuestScrollFrame.StoryTooltip
	StoryTooltip:SetFrameLevel(4)

	GameTooltip.ItemTooltip.Icon:SetTexCoord(unpack(E.TexCoords))
	GameTooltip.ItemTooltip.IconBorder:SetAlpha(0)
	GameTooltip.ItemTooltip:CreateBackdrop("Default")
	GameTooltip.ItemTooltip.backdrop:SetOutside(GameTooltip.ItemTooltip.Icon)
	GameTooltip.ItemTooltip.Count:ClearAllPoints()
	GameTooltip.ItemTooltip.Count:SetPoint('BOTTOMRIGHT', GameTooltip.ItemTooltip.Icon, 'BOTTOMRIGHT', 1, 0)
	hooksecurefunc(GameTooltip.ItemTooltip.IconBorder, 'SetVertexColor', function(self, r, g, b)
		self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
		self:SetTexture()
	end)
	hooksecurefunc(GameTooltip.ItemTooltip.IconBorder, 'Hide', function(self)
		self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

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
		_G.ReputationParagonTooltip,
		_G.EmbeddedItemTooltip,
		-- already have locals
		GameTooltip,
		StoryTooltip,
		WarCampaignTooltip,
	}

	for _, tt in pairs(tooltips) do
		TT:SecureHookScript(tt, 'OnShow', 'SetStyle')
	end

	-- EmbeddedItemTooltip
	local reward = _G.EmbeddedItemTooltip.ItemTooltip
	local icon = reward.Icon
	if reward and reward.backdrop then
		reward.backdrop:Point("TOPLEFT", icon, "TOPLEFT", -2, 2)
		reward.backdrop:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
	end

	-- Skin GameTooltip Status Bar
	_G.GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(_G.GameTooltipStatusBar)
	_G.GameTooltipStatusBar:CreateBackdrop('Transparent')
	_G.GameTooltipStatusBar:ClearAllPoints()
	_G.GameTooltipStatusBar:Point("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
	_G.GameTooltipStatusBar:Point("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))

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
