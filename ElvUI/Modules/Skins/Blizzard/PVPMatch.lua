local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs

function S:Blizzard_PVPMatch()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgscore) then return end

	-- Macro to show the PVPMatchScoreboard: /run PVPMatchScoreboard:Show()
	local PVPMatchScoreboard = _G.PVPMatchScoreboard
	PVPMatchScoreboard:StripTextures()
	PVPMatchScoreboard:DisableDrawLayer('BORDER')
	PVPMatchScoreboard:CreateBackdrop('Transparent')

	PVPMatchScoreboard.Content:StripTextures()
	PVPMatchScoreboard.Content.TabContainer.InsetBorderTop:Hide()

	S:HandleScrollBar(PVPMatchScoreboard.Content.ScrollFrame.ScrollBar)
	S:HandleCloseButton(PVPMatchScoreboard.CloseButton)

	--Also have a look at the tabs
	local tabs = {
		PVPMatchScoreboard.Content.TabContainer.TabGroup.Tab1,
		PVPMatchScoreboard.Content.TabContainer.TabGroup.Tab2,
		PVPMatchScoreboard.Content.TabContainer.TabGroup.Tab3,
	}

	for _, tab in pairs(tabs) do
		S:HandleTab(tab)
	end

	PVPMatchScoreboard.Content.TabContainer.MatchmakingText:FontTemplate()

	-- Macro to show the PVPMatchResults: /run PVPMatchResults:Show()
	local PVPMatchResults = _G.PVPMatchResults
	PVPMatchResults:StripTextures()
	PVPMatchResults:DisableDrawLayer('BORDER')
	PVPMatchResults:CreateBackdrop('Transparent')

	PVPMatchResults.content:StripTextures()
	PVPMatchResults.content.tabContainer:StripTextures()

	S:HandleScrollBar(PVPMatchResults.content.scrollFrame.scrollBar)
	S:HandleCloseButton(PVPMatchResults.CloseButton)
	S:HandleButton(PVPMatchResults.buttonContainer.leaveButton)
	S:HandleButton(PVPMatchResults.buttonContainer.requeueButton)

	local tabz = {
		PVPMatchResults.content.tabContainer.tabGroup.tab1,
		PVPMatchResults.content.tabContainer.tabGroup.tab2,
		PVPMatchResults.content.tabContainer.tabGroup.tab3,
	}

	for _, tab in pairs(tabz) do
		S:HandleTab(tab)
	end

	PVPMatchResults.content.tabContainer.matchmakingText:FontTemplate()
end

S:AddCallbackForAddon('Blizzard_PVPMatch')
