local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local GetNumGuildBankTabs = GetNumGuildBankTabs
local GuildControlGetNumRanks = GuildControlGetNumRanks

local function SkinGuildRanks()
	for i = 1, GuildControlGetNumRanks() do
		local rankFrame = _G['GuildControlUIRankOrderFrameRank'..i]

		S:HandleButton(rankFrame.downButton)
		S:HandleButton(rankFrame.upButton)
		S:HandleButton(rankFrame.deleteButton)

		local rankName = rankFrame.nameBox
		if not rankName.backdrop then
			S:HandleEditBox(rankName)
		end

		rankName.backdrop:ClearAllPoints()
		rankName.backdrop:Point('TOPLEFT', -2, -4)
		rankName.backdrop:Point('BOTTOMRIGHT', -4, 4)
	end
end

local function SkinBankTabs()
	local numTabs = GetNumGuildBankTabs()
	if numTabs < _G.MAX_BUY_GUILDBANK_TABS then
		numTabs = numTabs + 1
	end

	for i = 1, numTabs do
		local tab = _G['GuildControlBankTab'..i]
		S:HandleButton(tab.buy.button)

		local owned = tab.owned
		owned.tabIcon:SetTexCoords()

		if not owned.editBox.backdrop then
			S:HandleEditBox(owned.editBox)
		end

		S:HandleCheckBox(owned.viewCB)
		S:HandleCheckBox(owned.depositCB)
	end
end

local function SkinDiscordFrame() -- the link frame is only created once the guild channel is linked
	local linkFrame = _G.DiscordLinkFrame
	if not linkFrame or linkFrame.IsSkinned then return end

	S:HandleCheckBox(linkFrame.SeparateStream.Button) -- UICheckButtonTemplate
	S:HandleButton(_G.DiscordLinkFrameButton)

	linkFrame.IsSkinned = true
end

function S:Blizzard_GuildControlUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guildcontrol) then return end

	_G.GuildControlUI:StripTextures()
	_G.GuildControlUI:SetTemplate('Transparent')

	local RankSettingsFrameGoldBox = _G.GuildControlUIRankSettingsFrameGoldBox
	S:HandleEditBox(RankSettingsFrameGoldBox)
	RankSettingsFrameGoldBox.backdrop:Point('TOPLEFT', -2, -4)
	RankSettingsFrameGoldBox.backdrop:Point('BOTTOMRIGHT', 2, 4)
	RankSettingsFrameGoldBox:StripTextures()

	S:HandleButton(_G.GuildControlUIRankOrderFrameNewButton)
	S:HandleCloseButton(_G.GuildControlUICloseButton)
	S:HandleDropDownBox(_G.GuildControlUIRankBankFrameRankDropdown, 180)
	S:HandleTrimScrollBar(_G.GuildControlUIRankBankFrameInsetScrollFrame.ScrollBar)
	S:HandleDropDownBox(_G.GuildControlUINavigationDropdown)
	S:HandleDropDownBox(_G.GuildControlUIRankSettingsFrameRankDropdown, 180)

	_G.GuildControlUIRankBankFrame:StripTextures()
	_G.GuildControlUIRankBankFrameInset:StripTextures()
	_G.GuildControlUIRankBankFrameInsetScrollFrame:StripTextures()
	_G.GuildControlUIHbar:StripTextures()
	_G.GuildControlUIRankOrderFrameNewButton:HookScript('OnClick', function()
		E:Delay(1, SkinGuildRanks)
	end)

	S:HandleCheckBox(_G.GuildControlUIRankSettingsFrameOfficerCheckbox)

	-- Discord integration
	S:HandleDropDownBox(_G.GuildControlUIRankDiscordFrameServerDropdown, 180)
	S:HandleDropDownBox(_G.GuildControlUIRankDiscordFrameChannelDropdown, 180)
	S:HandleButton(_G.GuildControlUIRankDiscordFrameChannelButton)
	hooksecurefunc('GuildControlUI_Discord_Update', SkinDiscordFrame)

	for i = 1, _G.NUM_RANK_FLAGS do
		local checkbox = _G['GuildControlUIRankSettingsFrameCheckbox'..i] -- not every flag has one
		if checkbox then S:HandleCheckBox(checkbox) end
	end

	hooksecurefunc('GuildControlUI_BankTabPermissions_Update', SkinBankTabs)
	hooksecurefunc('GuildControlUI_RankOrder_Update', SkinGuildRanks)
end

S:AddCallbackForAddon('Blizzard_GuildControlUI')
