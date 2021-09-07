local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local ipairs = ipairs
local GameTooltip = _G.GameTooltip
local GameTooltipStatusBar = _G.GameTooltipStatusBar

function S:StyleTooltips()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip) then return end

	for _, tt in pairs({
		_G.ItemRefTooltip,
		_G.ItemRefShoppingTooltip1,
		_G.ItemRefShoppingTooltip2,
		_G.FriendsTooltip,
		_G.EmbeddedItemTooltip,
		_G.ReputationParagonTooltip,
		_G.GameTooltip,
		_G.ShoppingTooltip1,
		_G.ShoppingTooltip2,
		_G.QuickKeybindTooltip,
		-- ours
		_G.ElvUIConfigTooltip,
		_G.ElvUISpellBookTooltip
	}) do
		TT:SetStyle(tt)
	end
end

function S:TooltipFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip) then return end

	S:StyleTooltips()
	S:HandleCloseButton(_G.ItemRefCloseButton)

	-- Skin Blizzard Tooltips
	GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(GameTooltipStatusBar)
	GameTooltipStatusBar:CreateBackdrop('Transparent')
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:Point('TOPLEFT', GameTooltip, 'BOTTOMLEFT', E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar:Point('TOPRIGHT', GameTooltip, 'BOTTOMRIGHT', -E.Border, -(E.Spacing * 3))

	local tooltips = {
		_G.ItemRefTooltip,
		_G.ItemRefShoppingTooltip1,
		_G.ItemRefShoppingTooltip2,
		_G.AutoCompleteBox,
		_G.FriendsTooltip,
		_G.ShoppingTooltip1,
		_G.ShoppingTooltip2,
		_G.EmbeddedItemTooltip,
		_G.WorldMapTooltip,
		_G.ElvUIConfigTooltip,
		-- already have locals
		GameTooltip,
		_G.ElvUISpellBookTooltip
	}

	for _, tt in ipairs(tooltips) do
		TT:SecureHookScript(tt, 'OnShow', 'SetStyle')
	end

	-- EmbeddedItemTooltip
	local reward = _G.EmbeddedItemTooltip.ItemTooltip
	local icon = reward.Icon
	if reward and reward.backdrop then
		reward.backdrop:Point('TOPLEFT', icon, 'TOPLEFT', -2, 2)
		reward.backdrop:Point('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 2, -2)
	end

	TT:SecureHook('GameTooltip_ShowStatusBar') -- Skin Status Bars
	TT:SecureHook('GameTooltip_ShowProgressBar') -- Skin Progress Bars
	TT:SecureHook('GameTooltip_AddQuestRewardsToTooltip') -- Color Progress Bars
	TT:SecureHook('GameTooltip_UpdateStyle', 'SetStyle') -- GameTooltip_SetBackdropStyle
end

S:AddCallback('TooltipFrames')
