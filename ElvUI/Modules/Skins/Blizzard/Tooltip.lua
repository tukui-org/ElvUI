local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local pairs = pairs
local unpack = unpack

function S:StyleTooltips()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip) then return end

	for _, tt in pairs({
		_G.ItemRefTooltip,
		_G.ItemRefShoppingTooltip1,
		_G.ItemRefShoppingTooltip2,
		_G.FriendsTooltip,
		_G.WarCampaignTooltip,
		_G.EmbeddedItemTooltip,
		_G.ReputationParagonTooltip,
		_G.GameTooltip,
		_G.ShoppingTooltip1,
		_G.ShoppingTooltip2,
		_G.QuickKeybindTooltip,
		_G.QuestScrollFrame.StoryTooltip,
		_G.QuestScrollFrame.CampaignTooltip,
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
	S:HandleCloseButton(_G.ItemRefTooltip.CloseButton)

	-- Skin Blizzard Tooltips
	local ItemTooltip = _G.GameTooltip.ItemTooltip
	ItemTooltip:CreateBackdrop()
	ItemTooltip.backdrop:SetOutside(ItemTooltip.Icon)
	ItemTooltip.Count:ClearAllPoints()
	ItemTooltip.Count:Point('BOTTOMRIGHT', ItemTooltip.Icon, 'BOTTOMRIGHT', 1, 0)
	ItemTooltip.Icon:SetTexCoord(unpack(E.TexCoords))
	S:HandleIconBorder(ItemTooltip.IconBorder)

	-- StoryTooltip
	local StoryTooltip = _G.QuestScrollFrame.StoryTooltip
	StoryTooltip:SetFrameLevel(4)

	-- EmbeddedItemTooltip (also Paragon Reputation)
	local embedded = _G.EmbeddedItemTooltip
	embedded:SetTemplate('Transparent')

	if embedded.ItemTooltip.Icon then
		S:HandleIcon(embedded.ItemTooltip.Icon, true)
	end

	embedded:HookScript('OnShow', function(tt)
		tt:SetTemplate('Transparent')
	end)

	-- Skin GameTooltip Status Bar
	_G.GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	_G.GameTooltipStatusBar:CreateBackdrop('Transparent')
	_G.GameTooltipStatusBar:ClearAllPoints()
	_G.GameTooltipStatusBar:Point('TOPLEFT', _G.GameTooltip, 'BOTTOMLEFT', E.Border, -(E.Spacing * 3))
	_G.GameTooltipStatusBar:Point('TOPRIGHT', _G.GameTooltip, 'BOTTOMRIGHT', -E.Border, -(E.Spacing * 3))
	E:RegisterStatusBar(_G.GameTooltipStatusBar)

	-- Tooltip Styling
	TT:SecureHook('GameTooltip_ShowStatusBar') -- Skin Status Bars
	TT:SecureHook('GameTooltip_ShowProgressBar') -- Skin Progress Bars
	TT:SecureHook('GameTooltip_AddQuestRewardsToTooltip') -- Color Progress Bars
	TT:SecureHook('SharedTooltip_SetBackdropStyle', 'SetStyle') -- This also deals with other tooltip borders like AzeriteEssence Tooltip
end

S:AddCallback('TooltipFrames')
