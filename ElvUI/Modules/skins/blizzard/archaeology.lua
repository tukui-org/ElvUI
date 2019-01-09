local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select = pairs, select
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.archaeology ~= true then return end

	local ArchaeologyFrame = _G.ArchaeologyFrame
	S:HandlePortraitFrame(ArchaeologyFrame, true)

	S:HandleButton(_G.ArchaeologyFrameArtifactPageSolveFrameSolveButton, true)
	S:HandleButton(_G.ArchaeologyFrameArtifactPageBackButton, true)
	_G.ArchaeologyFrameRaceFilter:SetFrameLevel(_G.ArchaeologyFrameRaceFilter:GetFrameLevel() + 2)
	S:HandleDropDownBox(_G.ArchaeologyFrameRaceFilter, 125)

	if E.private.skins.parchmentRemover.enable then
		_G.ArchaeologyFrameBgLeft:Kill()
		_G.ArchaeologyFrameBgRight:Kill()

		_G.ArchaeologyFrameCompletedPage.infoText:SetTextColor(1, 1, 1)
		_G.ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 0)
		_G.ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 0)
		_G.ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
		_G.ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, 1, 0)
		_G.ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)

		for i = 1, _G.ARCHAEOLOGY_MAX_RACES do
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

	S:HandleButton(_G.ArchaeologyFrameSummaryPagePrevPageButton)
	S:HandleButton(_G.ArchaeologyFrameSummaryPageNextPageButton)
	S:HandleButton(_G.ArchaeologyFrameCompletedPageNextPageButton)
	S:HandleButton(_G.ArchaeologyFrameCompletedPagePrevPageButton)

	_G.ArchaeologyFrameRankBar:StripTextures()
	_G.ArchaeologyFrameRankBar:SetStatusBarTexture(E.media.normTex)
	_G.ArchaeologyFrameRankBar:SetFrameLevel(_G.ArchaeologyFrameRankBar:GetFrameLevel() + 2)
	_G.ArchaeologyFrameRankBar:CreateBackdrop("Default")
	E:RegisterStatusBar(_G.ArchaeologyFrameRankBar)

	_G.ArchaeologyFrameArtifactPageSolveFrameStatusBar:StripTextures()
	_G.ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarTexture(E.media.normTex)
	_G.ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarColor(0.7, 0.2, 0)
	_G.ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetFrameLevel(_G.ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	_G.ArchaeologyFrameArtifactPageSolveFrameStatusBar:CreateBackdrop("Default")
	E:RegisterStatusBar(_G.ArchaeologyFrameArtifactPageSolveFrameStatusBar)
	S:HandleIcon(_G.ArchaeologyFrameArtifactPageIcon)

	_G.ArcheologyDigsiteProgressBar:StripTextures()
	_G.ArcheologyDigsiteProgressBar.FillBar:StripTextures()
	_G.ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(E.media.normTex)
	_G.ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.2, 0)
	_G.ArcheologyDigsiteProgressBar.FillBar:SetFrameLevel(_G.ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	_G.ArcheologyDigsiteProgressBar.FillBar:CreateBackdrop("Default")
	_G.ArcheologyDigsiteProgressBar.BarTitle:FontTemplate(nil, nil, 'OUTLINE')
	_G.ArcheologyDigsiteProgressBar:ClearAllPoints()
	_G.ArcheologyDigsiteProgressBar:Point("TOP", _G.UIParent, "TOP", 0, -400)
	E:RegisterStatusBar(_G.ArcheologyDigsiteProgressBar.FillBar)

	_G.UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil
	E:CreateMover(_G.ArcheologyDigsiteProgressBar, "DigSiteProgressBarMover", L["Archeology Progress Bar"])
end

S:AddCallbackForAddon("Blizzard_ArchaeologyUI", "Archaeology", LoadSkin)
