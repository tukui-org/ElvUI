local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.archaeology ~= true then return end
	ArchaeologyFrame:StripTextures()
	ArchaeologyFrameInset:StripTextures()
	ArchaeologyFrame:CreateBackdrop("Transparent")
	ArchaeologyFrame.backdrop:SetAllPoints()
	ArchaeologyFrame.portrait:SetAlpha(0)

	S:HandleButton(ArchaeologyFrameArtifactPageSolveFrameSolveButton, true)
	S:HandleButton(ArchaeologyFrameArtifactPageBackButton, true)
	ArchaeologyFrameRaceFilter:SetFrameLevel(ArchaeologyFrameRaceFilter:GetFrameLevel() + 2)
	S:HandleDropDownBox(ArchaeologyFrameRaceFilter, 125)

	ArchaeologyFrameBgLeft:Kill()
	ArchaeologyFrameBgRight:Kill()

	for _, Frame in pairs({ ArchaeologyFrameCompletedPage, ArchaeologyFrameSummaryPage}) do
		for i = 1, Frame:GetNumRegions() do
			local Region = select(i, Frame:GetRegions())
			if Region:IsObjectType("FontString") then
				Region:SetTextColor(1, 1, 0)
			end
		end
	end

	ArchaeologyFrameCompletedPage.infoText:SetTextColor(1, 1, 1)
	ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 0)
	ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 0)
	ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
	ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, 1, 0)
	ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)

	S:HandleButton(ArchaeologyFrameSummaryPagePrevPageButton)
	S:HandleButton(ArchaeologyFrameSummaryPageNextPageButton)
	S:HandleButton(ArchaeologyFrameCompletedPageNextPageButton)
	S:HandleButton(ArchaeologyFrameCompletedPagePrevPageButton)

	ArchaeologyFrameRankBar:StripTextures()
	ArchaeologyFrameRankBar:SetStatusBarTexture(E["media"].normTex)
	E:RegisterStatusBar(ArchaeologyFrameRankBar)
	ArchaeologyFrameRankBar:SetFrameLevel(ArchaeologyFrameRankBar:GetFrameLevel() + 2)
	ArchaeologyFrameRankBar:CreateBackdrop("Default")

	ArchaeologyFrameArtifactPageSolveFrameStatusBar:StripTextures()
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarTexture(E["media"].normTex)
	E:RegisterStatusBar(ArchaeologyFrameArtifactPageSolveFrameStatusBar)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarColor(0.7, 0.2, 0)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:CreateBackdrop("Default")

	for i = 1, ARCHAEOLOGY_MAX_RACES do
		local frame = _G["ArchaeologyFrameSummaryPageRace"..i]
		local artifact = _G["ArchaeologyFrameCompletedPageArtifact"..i]
		local icon = _G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"]

		frame.raceName:SetTextColor(1, 1, 1)
		artifact.border:SetTexture(nil)
		_G[artifact:GetName().."Bg"]:Kill()
		artifact:CreateBackdrop()

		icon:SetTexCoord(unpack(E.TexCoords))
		artifact.backdrop:SetOutside(icon)

		artifact.artifactName:SetTextColor(1, 1, 0)
		artifact.artifactSubText:SetTextColor(0.6, 0.6, 0.6)
	end

	ArchaeologyFrameArtifactPageIcon:SetTexCoord(unpack(E.TexCoords))
	ArchaeologyFrameArtifactPageIcon.backdrop = CreateFrame("Frame", nil, ArchaeologyFrameArtifactPage)
	ArchaeologyFrameArtifactPageIcon.backdrop:SetTemplate("Default")
	ArchaeologyFrameArtifactPageIcon.backdrop:SetOutside(ArchaeologyFrameArtifactPageIcon)
	ArchaeologyFrameArtifactPageIcon.backdrop:SetFrameLevel(ArchaeologyFrameArtifactPage:GetFrameLevel())
	ArchaeologyFrameArtifactPageIcon:SetParent(ArchaeologyFrameArtifactPageIcon.backdrop)
	ArchaeologyFrameArtifactPageIcon:SetDrawLayer("OVERLAY")

	S:HandleCloseButton(ArchaeologyFrameCloseButton)

	ArcheologyDigsiteProgressBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(E["media"].normTex)
	E:RegisterStatusBar(ArcheologyDigsiteProgressBar.FillBar)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.2, 0)
	ArcheologyDigsiteProgressBar.FillBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	ArcheologyDigsiteProgressBar.FillBar:CreateBackdrop("Default")
	ArcheologyDigsiteProgressBar.BarTitle:FontTemplate(nil, nil, 'OUTLINE')
	ArcheologyDigsiteProgressBar:ClearAllPoints()
	ArcheologyDigsiteProgressBar:Point("TOP", UIParent, "TOP", 0, -400)
	UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil
	E:CreateMover(ArcheologyDigsiteProgressBar, "DigSiteProgressBarMover", L["Archeology Progress Bar"])
end

S:RegisterSkin("Blizzard_ArchaeologyUI", LoadSkin)
