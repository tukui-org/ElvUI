local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, next = pairs, next

function S:Blizzard_ArchaeologyUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.archaeology) then return end

	local ArchaeologyFrame = _G.ArchaeologyFrame
	S:HandlePortraitFrame(ArchaeologyFrame)
	S:HandleButton(ArchaeologyFrame.artifactPage.solveFrame.solveButton, true)
	S:HandleButton(ArchaeologyFrame.artifactPage.backButton, true)

	S:HandleDropDownBox(_G.ArchaeologyFrame.raceFilterDropDown)
	_G.ArchaeologyFrame.raceFilterDropDown.Text:ClearAllPoints()
	_G.ArchaeologyFrame.raceFilterDropDown.Text:Point('LEFT', _G.ArchaeologyFrame.raceFilterDropDown.backdrop, 'LEFT', 4, 0)

	if E.private.skins.parchmentRemoverEnable then
		_G.ArchaeologyFrameBgLeft:Kill()
		_G.ArchaeologyFrameBgRight:Kill()

		ArchaeologyFrame.completedPage.infoText:SetTextColor(1, 1, 1)
		ArchaeologyFrame.helpPage.titleText:SetTextColor(1, 1, 0)

		_G.ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 0)
		_G.ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)

		ArchaeologyFrame.artifactPage.historyTitle:SetTextColor(1, 1, 0)
		_G.ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)

		for i = 1, _G.ARCHAEOLOGY_MAX_RACES do
			local frame = ArchaeologyFrame.summaryPage['race'..i]
			local artifact = ArchaeologyFrame.completedPage['artifact'..i]
			frame.raceName:SetTextColor(1, 1, 1)

			S:HandleIcon(artifact.icon, true)

			artifact.border:SetTexture()
			artifact.artifactName:SetTextColor(1, .8, .1)
			artifact.artifactSubText:SetTextColor(0.6, 0.6, 0.6)
		end

		for _, Frame in pairs({ ArchaeologyFrame.completedPage, ArchaeologyFrame.summaryPage }) do
			for _, Region in next, { Frame:GetRegions() } do
				if Region:IsObjectType('FontString') then
					Region:SetTextColor(1, .8, .1)
				end
			end
		end
	else
		_G.ArchaeologyFrameBgLeft:SetDrawLayer('BACKGROUND', 2)
		_G.ArchaeologyFrameBgRight:SetDrawLayer('BACKGROUND', 2)
	end

	S:HandleButton(ArchaeologyFrame.summaryPage.prevPageButton, nil, nil, true)
	S:HandleButton(ArchaeologyFrame.summaryPage.nextPageButton, nil, nil, true)
	S:HandleButton(ArchaeologyFrame.completedPage.prevPageButton, nil, nil, true)
	S:HandleButton(ArchaeologyFrame.completedPage.nextPageButton, nil, nil, true)

	ArchaeologyFrame.rankBar:StripTextures()
	ArchaeologyFrame.rankBar:CreateBackdrop()
	ArchaeologyFrame.rankBar:SetStatusBarTexture(E.media.normTex)
	ArchaeologyFrame.rankBar.backdrop.Center:SetDrawLayer('BACKGROUND', 3) -- over BgLeft and BgRight
	E:RegisterStatusBar(ArchaeologyFrame.rankBar)

	S:HandleStatusBar(ArchaeologyFrame.artifactPage.solveFrame.statusBar, {0.7, 0.2, 0})
	S:HandleIcon(_G.ArchaeologyFrameArtifactPageIcon)

	_G.ArcheologyDigsiteProgressBar:StripTextures()
	_G.ArcheologyDigsiteProgressBar:ClearAllPoints()
	_G.ArcheologyDigsiteProgressBar:Point('TOP', _G.UIParent, 'TOP', 0, -400)
	_G.ArcheologyDigsiteProgressBar.BarTitle:FontTemplate(nil, nil, 'OUTLINE')
	S:HandleStatusBar(_G.ArcheologyDigsiteProgressBar.FillBar, {0.7, 0.2, 0})

	--E:CreateMover(_G.ArcheologyDigsiteProgressBar, 'DigSiteProgressBarMover', L["Archeology Progress Bar"])
end

S:AddCallbackForAddon('Blizzard_ArchaeologyUI')
