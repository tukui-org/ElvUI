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
	self:SetBackdrop(nil)
	self:SetTemplate("Transparent", nil, true)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tooltip ~= true then return end

	S:HandleCloseButton(_G.ItemRefCloseButton)

	-- Skin Blizzard Tooltips
	local GameTooltip = _G.GameTooltip
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

	-- StoryTooltip
	local StoryTooltip = _G.QuestScrollFrame.StoryTooltip
	StoryTooltip:SetFrameLevel(4)

	-- EmbeddedItemTooltip
	local reward = _G.EmbeddedItemTooltip.ItemTooltip
	local icon = reward.Icon
	if reward and reward.backdrop then
		reward.backdrop:Point("TOPLEFT", icon, "TOPLEFT", -2, 2)
		reward.backdrop:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
	end

	-- Skin GameTooltip Status Bar
	_G.GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	_G.GameTooltipStatusBar:CreateBackdrop('Transparent')
	_G.GameTooltipStatusBar:ClearAllPoints()
	_G.GameTooltipStatusBar:Point("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
	_G.GameTooltipStatusBar:Point("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))
	E:RegisterStatusBar(_G.GameTooltipStatusBar)

	-- Tooltip Styling
	TT:SecureHook('GameTooltip_ShowStatusBar') -- Skin Status Bars
	TT:SecureHook('GameTooltip_ShowProgressBar') -- Skin Progress Bars
	TT:SecureHook('GameTooltip_AddQuestRewardsToTooltip') -- Color Progress Bars
	TT:SecureHook('GameTooltip_SetBackdropStyle', 'SetStyle') -- This also deals with other tooltip borders like AzeriteEssence Tooltip

	-- Style Tooltips which are created before load
	local styleTT = {
		_G.ItemRefTooltip,
		_G.FriendsTooltip,
		_G.WarCampaignTooltip,
		_G.EmbeddedItemTooltip,
		_G.ReputationParagonTooltip,
		-- already have locals
		StoryTooltip,
		GameTooltip,
	}

	for _, tt in pairs(styleTT) do
		TT:SetStyle(tt)
	end

	-- [Backdrop coloring] There has to be a more elegant way of doing this.
	TT:SecureHookScript(GameTooltip, 'OnUpdate', 'CheckBackdropColor')

	-- Used for Island Skin
	TT:RegisterEvent("ADDON_LOADED", function(event, addon)
		if addon == "Blizzard_IslandsQueueUI" then
			local tt = _G.IslandsQueueFrameTooltip:GetParent()
			tt:GetParent():HookScript("OnShow", IslandTooltipStyle)
			tt.IconBorder:SetAlpha(0)
			tt.Icon:SetTexCoord(unpack(E.TexCoords))
			TT:UnregisterEvent(event)
		end
	end)
end

S:AddCallback('SkinTooltip', LoadSkin)
