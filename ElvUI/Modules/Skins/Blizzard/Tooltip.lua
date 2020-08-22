local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local pairs = pairs
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local function IslandTooltipStyle(self)
	self:SetBackdrop(nil)
	self:SetTemplate('Transparent', nil, true)
end

function S:TooltipFrames()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip) then return end

	S:HandleCloseButton(_G.ItemRefCloseButton)

	-- Skin Blizzard Tooltips
	local ItemTooltip = _G.GameTooltip.ItemTooltip
	ItemTooltip:CreateBackdrop('Default')
	ItemTooltip.backdrop:SetOutside(ItemTooltip.Icon)
	ItemTooltip.Count:ClearAllPoints()
	ItemTooltip.Count:SetPoint('BOTTOMRIGHT', ItemTooltip.Icon, 'BOTTOMRIGHT', 1, 0)
	ItemTooltip.Icon:SetTexCoord(unpack(E.TexCoords))
	ItemTooltip.IconBorder:SetAlpha(0)
	hooksecurefunc(ItemTooltip.IconBorder, 'SetVertexColor', function(s, r, g, b)
		s:GetParent().backdrop:SetBackdropBorderColor(r, g, b)
		s:SetTexture()
	end)
	hooksecurefunc(ItemTooltip.IconBorder, 'Hide', function(s)
		s:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)

	-- StoryTooltip
	local StoryTooltip = _G.QuestScrollFrame.StoryTooltip
	StoryTooltip:SetFrameLevel(4)

	-- EmbeddedItemTooltip (also Paragon Reputation)
	local embedded = _G.EmbeddedItemTooltip
	local reward = embedded.ItemTooltip
	local icon = reward.Icon
	embedded:SetTemplate('Transparent')

	if reward and reward.backdrop then
		reward.backdrop:SetPoint('TOPLEFT', icon, 'TOPLEFT', -2, 2)
		reward.backdrop:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 2, -2)
	end

	if icon then
		S:HandleIcon(icon, true)
		hooksecurefunc(reward.IconBorder, 'SetVertexColor', function(border, r, g, b)
			border:GetParent().Icon.backdrop:SetBackdropBorderColor(r, g, b)
			border:SetTexture()
		end)
		hooksecurefunc(reward.IconBorder, 'Hide', function(border)
			border:GetParent().Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)
	end

	embedded:HookScript('OnShow', function(tt)
		tt:SetTemplate('Transparent')
	end)

	-- Skin GameTooltip Status Bar
	_G.GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	_G.GameTooltipStatusBar:CreateBackdrop('Transparent')
	_G.GameTooltipStatusBar:ClearAllPoints()
	_G.GameTooltipStatusBar:SetPoint('TOPLEFT', _G.GameTooltip, 'BOTTOMLEFT', E.Border, -(E.Spacing * 3))
	_G.GameTooltipStatusBar:SetPoint('TOPRIGHT', _G.GameTooltip, 'BOTTOMRIGHT', -E.Border, -(E.Spacing * 3))
	E:RegisterStatusBar(_G.GameTooltipStatusBar)

	-- Tooltip Styling
	TT:SecureHook('GameTooltip_ShowStatusBar') -- Skin Status Bars
	TT:SecureHook('GameTooltip_ShowProgressBar') -- Skin Progress Bars
	TT:SecureHook('GameTooltip_AddQuestRewardsToTooltip') -- Color Progress Bars
	TT:SecureHook('GameTooltip_SetBackdropStyle', 'SetStyle') -- This also deals with other tooltip borders like AzeriteEssence Tooltip

	-- Style Tooltips which are created before load
	local styleTT = {
		_G.GameTooltip,
		_G.ItemRefTooltip,
		_G.FriendsTooltip,
		_G.WarCampaignTooltip,
		_G.EmbeddedItemTooltip,
		_G.ReputationParagonTooltip,
		_G.ElvUIConfigTooltip,
		_G.ElvUISpellBookTooltip,
		-- already have locals
		StoryTooltip,
	}

	for _, tt in pairs(styleTT) do
		TT:SetStyle(tt)
	end

	-- [Backdrop Coloring] There has to be a more elegant way of doing this.
	TT:SecureHookScript(_G.GameTooltip, 'OnUpdate', 'CheckBackdropColor')

	-- Used for Island Skin
	TT:RegisterEvent('ADDON_LOADED', function(event, addon)
		if addon == 'Blizzard_IslandsQueueUI' then
			local tt = _G.IslandsQueueFrameTooltip:GetParent()
			tt:GetParent():HookScript('OnShow', IslandTooltipStyle)
			tt.IconBorder:SetAlpha(0)
			tt.Icon:SetTexCoord(unpack(E.TexCoords))
			TT:UnregisterEvent(event)
		end
	end)

	-- Icon in ItemTooltip is stuck sometimes because of nargles, we dont want that
	-- I have no idea if this actually works, it's a guess. ~Simpy
	hooksecurefunc('EmbeddedItemTooltip_UpdateSize', function(frame)
		if frame.Tooltip:IsShown() then
			local textLeft = _G[frame.Tooltip:GetName() .. 'TextLeft1']
			if textLeft and not textLeft:GetText() then
				frame:Hide()
			end
		end
	end)
end

S:AddCallback('TooltipFrames')
