local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select = pairs, select
--WoW API / Variables
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, ARCHAEOLOGY_MAX_RACES, UIPARENT_MANAGED_FRAME_POSITIONS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.archaeology ~= true then return end

	local ArchaeologyFrame = _G["ArchaeologyFrame"]
	ArchaeologyFrame:StripTextures()
	ArchaeologyFrame:CreateBackdrop("Transparent")
	ArchaeologyFrame.backdrop:SetAllPoints()
	ArchaeologyFrame.portrait:SetAlpha(0)

	S:HandleButton(ArchaeologyFrameArtifactPageSolveFrameSolveButton, true)
	S:HandleButton(ArchaeologyFrameArtifactPageBackButton, true)
	ArchaeologyFrameRaceFilter:SetFrameLevel(ArchaeologyFrameRaceFilter:GetFrameLevel() + 2)
	S:HandleDropDownBox(ArchaeologyFrameRaceFilter, 125)

	if E.private.skins.parchmentRemover.enable then
		ArchaeologyFrameBgLeft:Kill()
		ArchaeologyFrameBgRight:Kill()

		ArchaeologyFrameCompletedPage.infoText:SetTextColor(1, 1, 1)
		ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 0)
		ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 0)
		ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
		ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, 1, 0)
		ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)

		for i = 1, ARCHAEOLOGY_MAX_RACES do
			local frame = ArchaeologyFrame.summaryPage['race'..i]
			local artifact = ArchaeologyFrame.completedPage['artifact'..i]
			frame.raceName:SetTextColor(1, 1, 1)

			artifact.border:SetTexture(nil)
			S:HandleTexture(artifact.icon, artifact)
			artifact.artifactName:SetTextColor(1, .8, .1)
			artifact.artifactSubText:SetTextColor(0.6, 0.6, 0.6)
		end

		for _, Frame in pairs({ ArchaeologyFrame.completedPage, ArchaeologyFrame.summaryPage }) do
			for i = 1, Frame:GetNumRegions() do
				local Region = select(i, Frame:GetRegions())
				if Region:IsObjectType("FontString") then
					Region:SetTextColor(1, .8, .1)
				end
			end
		end
	end

	S:HandleButton(ArchaeologyFrameSummaryPagePrevPageButton)
	S:HandleButton(ArchaeologyFrameSummaryPageNextPageButton)
	S:HandleButton(ArchaeologyFrameCompletedPageNextPageButton)
	S:HandleButton(ArchaeologyFrameCompletedPagePrevPageButton)

	ArchaeologyFrameRankBar:StripTextures()
	ArchaeologyFrameRankBar:SetStatusBarTexture(E.media.normTex)
	ArchaeologyFrameRankBar:SetFrameLevel(ArchaeologyFrameRankBar:GetFrameLevel() + 2)
	ArchaeologyFrameRankBar:CreateBackdrop("Default")
	E:RegisterStatusBar(ArchaeologyFrameRankBar)

	ArchaeologyFrameArtifactPageSolveFrameStatusBar:StripTextures()
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarTexture(E.media.normTex)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarColor(0.7, 0.2, 0)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:CreateBackdrop("Default")
	E:RegisterStatusBar(ArchaeologyFrameArtifactPageSolveFrameStatusBar)

	S:HandleCloseButton(ArchaeologyFrameCloseButton)

	S:HandleIcon(ArchaeologyFrameArtifactPageIcon)

	ArcheologyDigsiteProgressBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(E.media.normTex)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.2, 0)
	ArcheologyDigsiteProgressBar.FillBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	ArcheologyDigsiteProgressBar.FillBar:CreateBackdrop("Default")
	ArcheologyDigsiteProgressBar.BarTitle:FontTemplate(nil, nil, 'OUTLINE')
	ArcheologyDigsiteProgressBar:ClearAllPoints()
	ArcheologyDigsiteProgressBar:Point("TOP", UIParent, "TOP", 0, -400)
	E:RegisterStatusBar(ArcheologyDigsiteProgressBar.FillBar)

	UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil
	E:CreateMover(ArcheologyDigsiteProgressBar, "DigSiteProgressBarMover", L["Archeology Progress Bar"])
end

S:AddCallbackForAddon("Blizzard_ArchaeologyUI", "Archaeology", LoadSkin)
