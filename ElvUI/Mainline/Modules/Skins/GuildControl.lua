local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc
local GuildControlGetNumRanks = GuildControlGetNumRanks
local GetNumGuildBankTabs = GetNumGuildBankTabs

local function SkinGuildRanks()
	for i=1, GuildControlGetNumRanks() do
		local rankFrame = _G['GuildControlUIRankOrderFrameRank'..i]
		if rankFrame then
			if not rankFrame.nameBox.backdrop then
				S:HandleEditBox(rankFrame.nameBox)

				S:HandleButton(rankFrame.downButton)
				S:HandleButton(rankFrame.upButton)
				S:HandleButton(rankFrame.deleteButton)
			end

			rankFrame.nameBox.backdrop:ClearAllPoints()
			rankFrame.nameBox.backdrop:Point('TOPLEFT', -2, -4)
			rankFrame.nameBox.backdrop:Point('BOTTOMRIGHT', -4, 4)
		end
	end
end

local function SkinBankTabs()
	local numTabs = GetNumGuildBankTabs()
	if numTabs < _G.MAX_BUY_GUILDBANK_TABS then
		numTabs = numTabs + 1
	end

	for i=1, numTabs do
		local tab = _G['GuildControlBankTab'..i]
		if not tab then break end

		local buy = tab.buy
		if buy and buy.button and not buy.button.isSkinned then
			S:HandleButton(buy.button)
		end

		local owned = tab.owned
		if owned then
			owned.tabIcon:SetTexCoord(unpack(E.TexCoords))

			if owned.editBox and not owned.editBox.backdrop then
				S:HandleEditBox(owned.editBox)
			end
			if owned.viewCB and not owned.viewCB.isSkinned then
				S:HandleCheckBox(owned.viewCB)
			end
			if owned.depositCB and not owned.depositCB.isSkinned then
				S:HandleCheckBox(owned.depositCB)
			end
		end
	end
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
	S:HandleDropDownBox(_G.GuildControlUIRankBankFrameRankDropDown, 180)
	S:HandleScrollBar(_G.GuildControlUIRankBankFrameInsetScrollFrameScrollBar)
	S:HandleDropDownBox(_G.GuildControlUINavigationDropDown)
	S:HandleDropDownBox(_G.GuildControlUIRankSettingsFrameRankDropDown, 180)
	_G.GuildControlUINavigationDropDownButton:Width(20)
	_G.GuildControlUIRankSettingsFrameRankDropDownButton:Width(20)
	_G.GuildControlUIRankBankFrameRankDropDownButton:Width(20)
	_G.GuildControlUIRankBankFrame:StripTextures()
	_G.GuildControlUIRankBankFrameInset:StripTextures()
	_G.GuildControlUIRankBankFrameInsetScrollFrame:StripTextures()
	_G.GuildControlUIHbar:StripTextures()
	_G.GuildControlUIRankOrderFrameNewButton:HookScript('OnClick', function()
		E:Delay(1, SkinGuildRanks)
	end)

	S:HandleCheckBox(_G.GuildControlUIRankSettingsFrameOfficerCheckbox)

	for i=1, _G.NUM_RANK_FLAGS do
		local checkbox = _G['GuildControlUIRankSettingsFrameCheckbox'..i]
		if checkbox then S:HandleCheckBox(checkbox) end
	end

	hooksecurefunc('GuildControlUI_BankTabPermissions_Update', SkinBankTabs)
	hooksecurefunc('GuildControlUI_RankOrder_Update', SkinGuildRanks)
end

S:AddCallbackForAddon('Blizzard_GuildControlUI')
