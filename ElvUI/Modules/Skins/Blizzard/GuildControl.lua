local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
				S:HandleButton(rankFrame.downButton)
				S:HandleButton(rankFrame.upButton)
				S:HandleButton(rankFrame.deleteButton)
				S:HandleEditBox(rankFrame.nameBox)
			end

			rankFrame.nameBox.backdrop:ClearAllPoints()
			rankFrame.nameBox.backdrop:Point('TOPLEFT', -2, -4)
			rankFrame.nameBox.backdrop:Point('BOTTOMRIGHT', -4, 4)
		end
	end
end

local function fixSkin(frame)
	frame.backdrop:Hide()
	--Initiate fucked up method of creating a backdrop
	if not E.PixelMode then
		frame.bg1 = frame:CreateTexture(nil, 'BACKGROUND')
		frame.bg1:SetDrawLayer('BACKGROUND', 4)
		frame.bg1:SetTexture(E.media.normTex) --Default TukUI users this is normTex, normTex doesn't exist
		E:RegisterStatusBar(frame.bg1)
		frame.bg1:SetVertexColor(unpack(E.media.backdropcolor))
		frame.bg1:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 4, -4)
		frame.bg1:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -4, 4)

		frame.bg2 = frame:CreateTexture(nil, 'BACKGROUND')
		frame.bg2:SetDrawLayer('BACKGROUND', 3)
		frame.bg2:SetColorTexture(0,0,0)
		frame.bg2:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 3, -3)
		frame.bg2:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -3, 3)

		frame.bg3 = frame:CreateTexture(nil, 'BACKGROUND')
		frame.bg3:SetDrawLayer('BACKGROUND', 2)
		frame.bg3:SetColorTexture(unpack(E.media.bordercolor))
		frame.bg3:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 2, -2)
		frame.bg3:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)

		frame.bg4 = frame:CreateTexture(nil, 'BACKGROUND')
		frame.bg4:SetDrawLayer('BACKGROUND', 1)
		frame.bg4:SetColorTexture(0,0,0)
		frame.bg4:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 1, -1)
		frame.bg4:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -1, 1)
	else
		frame.bg1 = frame:CreateTexture(nil, 'BACKGROUND')
		frame.bg1:SetDrawLayer('BACKGROUND', 4)
		frame.bg1:SetTexture(E.media.normTex) --Default TukUI users this is normTex, normTex doesn't exist
		E:RegisterStatusBar(frame.bg1)
		frame.bg1:SetVertexColor(unpack(E.media.backdropcolor))
		frame.bg1:SetInside(frame.backdrop)

		frame.bg3 = frame:CreateTexture(nil, 'BACKGROUND')
		frame.bg3:SetDrawLayer('BACKGROUND', 2)
		frame.bg3:SetColorTexture(unpack(E.media.bordercolor))
		frame.bg3:SetAllPoints(frame.backdrop)
	end
end

function S:Blizzard_GuildControlUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guildcontrol) then return end

	local GuildControlUI = _G.GuildControlUI
	GuildControlUI:StripTextures()
	GuildControlUI:SetTemplate('Transparent')
	_G.GuildControlUIHbar:StripTextures()
	_G.GuildControlUIRankBankFrameInset:StripTextures()
	_G.GuildControlUIRankBankFrameInsetScrollFrame:StripTextures()
	S:HandleCloseButton(_G.GuildControlUICloseButton)
	S:HandleScrollBar(_G.GuildControlUIRankBankFrameInsetScrollFrameScrollBar)

	hooksecurefunc('GuildControlUI_RankOrder_Update', SkinGuildRanks)
	_G.GuildControlUIRankOrderFrameNewButton:HookScript('OnClick', function()
		E:Delay(1, SkinGuildRanks)
	end)

	S:HandleDropDownBox(_G.GuildControlUINavigationDropDown)
	S:HandleDropDownBox(_G.GuildControlUIRankSettingsFrameRankDropDown, 180)
	_G.GuildControlUINavigationDropDownButton:Width(20)
	_G.GuildControlUIRankSettingsFrameRankDropDownButton:Width(20)

	for i=1, _G.NUM_RANK_FLAGS do
		if _G['GuildControlUIRankSettingsFrameCheckbox'..i] then
			S:HandleCheckBox(_G['GuildControlUIRankSettingsFrameCheckbox'..i])
		end
	end

	S:HandleButton(_G.GuildControlUIRankOrderFrameNewButton)

	local GuildControlUIRankSettingsFrameGoldBox = _G.GuildControlUIRankSettingsFrameGoldBox
	S:HandleEditBox(GuildControlUIRankSettingsFrameGoldBox)
	GuildControlUIRankSettingsFrameGoldBox.backdrop:Point('TOPLEFT', -2, -4)
	GuildControlUIRankSettingsFrameGoldBox.backdrop:Point('BOTTOMRIGHT', 2, 4)
	GuildControlUIRankSettingsFrameGoldBox:StripTextures()

	_G.GuildControlUIRankBankFrame:StripTextures()

	local once = false
	hooksecurefunc('GuildControlUI_BankTabPermissions_Update', function()
		local numTabs = GetNumGuildBankTabs()
		if numTabs < _G.MAX_BUY_GUILDBANK_TABS then
			numTabs = numTabs + 1
		end
		for i=1, numTabs do
			local tab = _G['GuildControlBankTab'..i..'Owned']
			local icon = tab.tabIcon

			icon:SetTexCoord(unpack(E.TexCoords))

			if once == false then
				S:HandleButton(_G['GuildControlBankTab'..i..'BuyPurchaseButton'])
				S:HandleEditBox(_G['GuildControlBankTab'..i..'OwnedStackBox'])
				S:HandleCheckBox(_G['GuildControlBankTab'..i..'OwnedViewCheck'])
				S:HandleCheckBox(_G['GuildControlBankTab'..i..'OwnedDepositCheck'])
				S:HandleCheckBox(_G['GuildControlBankTab'..i..'OwnedUpdateInfoCheck'])

				fixSkin(_G['GuildControlBankTab'..i..'OwnedStackBox'])
				fixSkin(_G['GuildControlBankTab'..i..'OwnedViewCheck'])
				fixSkin(_G['GuildControlBankTab'..i..'OwnedDepositCheck'])
				fixSkin(_G['GuildControlBankTab'..i..'OwnedUpdateInfoCheck'])

			end
		end
		once = true
	end)

	S:HandleDropDownBox(_G.GuildControlUIRankBankFrameRankDropDown, 180)
	_G.GuildControlUIRankBankFrameRankDropDownButton:Width(20)
end

S:AddCallbackForAddon('Blizzard_GuildControlUI')
