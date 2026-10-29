local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next

S:AddCallback('TooltipFrames', nil, nil, 'tooltip')

function S:StyleTooltips()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip) then return end
	TT.isStyled = true

	TT:SetAuraButtonTooltipStyle()

	for _, tt in next, {
		_G.ItemRefTooltip,
		_G.ItemRefShoppingTooltip1,
		_G.ItemRefShoppingTooltip2,
		_G.FriendsTooltip,
		_G.EmbeddedItemTooltip,
		_G.GameTooltip,
		not E.Modern and _G.WorldMapTooltip or nil,
		_G.ShoppingTooltip1,
		_G.ShoppingTooltip2,
		_G.QuickKeybindTooltip,
		E.Modern and _G.GameSmallHeaderTooltip or nil,
		E.Modern and _G.QuestScrollFrame.StoryTooltip or nil,
		E.Modern and _G.QuestScrollFrame.CampaignTooltip or nil,
		-- ours
		E.ConfigTooltip,
		E.SpellBookTooltip,
		-- libs
		_G.LibDBIconTooltip,
		_G.SettingsTooltip,
	} do
		TT:SetStyle(tt)

		local CompareHeader = tt.CompareHeader
		if CompareHeader and not CompareHeader.template then
			CompareHeader:StripTextures()
			CompareHeader:SetTemplate()
		end
	end
end

function S:TooltipFrames()
	S:StyleTooltips()
	S:HandleCloseButton(E.Modern and _G.ItemRefTooltip.CloseButton or _G.ItemRefCloseButton)

	if E.Modern then
		_G.QuestScrollFrame.StoryTooltip:SetFrameLevel(4)

		local ItemTT = _G.GameTooltip.ItemTooltip
		S:HandleIcon(ItemTT.Icon, true)
		S:HandleIconBorder(ItemTT.IconBorder, ItemTT.Icon.backdrop)
		ItemTT.Count:ClearAllPoints()
		ItemTT.Count:Point('BOTTOMRIGHT', ItemTT.Icon, 'BOTTOMRIGHT', 1, 0)
	end

	-- EmbeddedItemTooltip (also Paragon Reputation)
	local EmbeddedTT = _G.EmbeddedItemTooltip.ItemTooltip
	S:HandleIcon(EmbeddedTT.Icon, true)
	S:HandleIconBorder(EmbeddedTT.IconBorder, EmbeddedTT.Icon.backdrop)

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
	TT:SecureHook('GameTooltip_ClearProgressBars')
	TT:SecureHook('GameTooltip_AddQuestRewardsToTooltip') -- Color Progress Bars
	TT:SecureHook('SharedTooltip_SetBackdropStyle', 'SetStyle') -- This also deals with other tooltip borders like AzeriteEssence Tooltip
end
