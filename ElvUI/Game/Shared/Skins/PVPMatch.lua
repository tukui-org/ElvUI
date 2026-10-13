local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

S:AddCallbackForAddon('Blizzard_PVPMatch', nil, nil, nil, nil, nil, 'bgscore')

function S:Blizzard_PVPMatch()
	-- Macro to show the PVPMatchScoreboard: /run PVPMatchScoreboard:Show()
	local PVPMatchScoreboard = _G.PVPMatchScoreboard
	PVPMatchScoreboard:StripTextures()
	PVPMatchScoreboard:DisableDrawLayer('BORDER')
	PVPMatchScoreboard:CreateBackdrop('Transparent')

	local scoreContent = PVPMatchScoreboard.Content
	local scoreTab = scoreContent.TabContainer
	scoreContent:StripTextures()
	scoreTab.InsetBorderTop:Hide()
	scoreTab.MatchmakingText:FontTemplate()

	S:HandleCloseButton(PVPMatchScoreboard.CloseButton)
	S:HandleTrimScrollBar(scoreContent.ScrollBar)

	-- Macro to show the PVPMatchResults: /run PVPMatchResults:Show()
	local matchResults = _G.PVPMatchResults
	matchResults:StripTextures()
	matchResults:DisableDrawLayer('BORDER')
	matchResults:CreateBackdrop('Transparent')

	local matchContent = matchResults.content
	local matchTab = matchContent.tabContainer
	matchContent:StripTextures()
	matchTab:StripTextures()
	matchTab.matchmakingText:FontTemplate()

	S:HandleTrimScrollBar(matchContent.scrollBar)
	S:HandleCloseButton(matchResults.CloseButton)
	S:HandleButton(matchResults.buttonContainer.leaveButton)
	S:HandleButton(matchResults.buttonContainer.requeueButton)

	for _, tab in next, {
		scoreTab.TabGroup.Tab1,
		scoreTab.TabGroup.Tab2,
		scoreTab.TabGroup.Tab3,

		matchTab.tabGroup.tab1,
		matchTab.tabGroup.tab2,
		matchTab.tabGroup.tab3,
	} do
		S:HandleTab(tab)
	end
end
