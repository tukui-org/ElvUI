local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
	hooksecurefunc(WorldMapTooltip.ItemTooltip.IconBorder, 'SetVertexColor', function(self, r, g, b)
		self:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
		self:SetTexture('')
	end)
	hooksecurefunc(WorldMapTooltip.ItemTooltip.IconBorder, 'Hide', function(self)
		self:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)
	WorldMapTooltip.ItemTooltip:CreateBackdrop()
	WorldMapTooltip.ItemTooltip.backdrop:SetOutside(WorldMapTooltip.ItemTooltip.Icon)
	WorldMapTooltip.ItemTooltip.Count:ClearAllPoints()
	WorldMapTooltip.ItemTooltip.Count:SetPoint('BOTTOMRIGHT', WorldMapTooltip.ItemTooltip.Icon, 'BOTTOMRIGHT', 1, 0)

	-- Tooltip Progress Bars
	local function SkinTooltipProgressBar(frame)
		if not (frame and frame.Bar) then return end
		frame.Bar:StripTextures()
		frame.Bar:CreateBackdrop('Transparent')
		frame.Bar:SetStatusBarTexture(E['media'].normTex)
		E:RegisterStatusBar(frame.Bar)
		frame.isSkinned = true
	end
	SkinTooltipProgressBar(ReputationParagonTooltipStatusBar)
	SkinTooltipProgressBar(WorldMapTaskTooltipStatusBar)

	-- Color GameTooltip QuestRewards Progress Bars
	local function QuestRewardsBarColor(tooltip, questID, style)
		if not tooltip or not questID then return end
		local name, cur, max, sb, _ = tooltip.GetName and tooltip:GetName()
		if name and name == 'WorldMapTooltip' then name = 'WorldMapTaskTooltip' end
		sb = name and _G[name..'StatusBar']
		if not sb or not sb.isSkinned then return end
		if sb.Bar and sb.Bar.GetValue then
			cur = sb.Bar:GetValue()
			if cur then
				if sb.Bar.GetMinMaxValues then
					_, max = sb.Bar:GetMinMaxValues()
				end
				S:StatusBarColorGradient(sb.Bar, cur, max)
			end
		end
	end
	hooksecurefunc('GameTooltip_AddQuestRewardsToTooltip', QuestRewardsBarColor)

	-- Skin Blizzard Tooltips
	local GameTooltip = _G['GameTooltip']
	local GameTooltipStatusBar =  _G['GameTooltipStatusBar']
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
	}
	for _, tt in pairs(tooltips) do
		TT:SecureHookScript(tt, 'OnShow', 'SetStyle')
	end

	-- Skin GameTooltip Status Bar
	GameTooltipStatusBar:SetStatusBarTexture(E['media'].normTex)
	E:RegisterStatusBar(GameTooltipStatusBar)
	GameTooltipStatusBar:CreateBackdrop('Transparent')
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:Point("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar:Point("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))

	-- Skin Additional GameTooltip Status Bars
	TT:SecureHook('GameTooltip_ShowStatusBar', 'GameTooltip_ShowStatusBar')

	-- Backdrop coloring
	TT:SecureHookScript(GameTooltip, 'OnSizeChanged', 'CheckBackdropColor')
	TT:SecureHookScript(GameTooltip, 'OnUpdate', 'CheckBackdropColor') --There has to be a more elegant way of doing this.
	TT:RegisterEvent('CURSOR_UPDATE', 'CheckBackdropColor')
end

S:AddCallback('SkinTooltip', LoadSkin)