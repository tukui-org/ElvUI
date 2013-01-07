
local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "ArchySkin"

local function SkinArchy(self)
	local function SkinArchyArtifactFrame()
			AS:SkinFrame(ArchyArtifactFrame)

			if ArchyArtifactFrameSkillBar then
				--ArchyArtifactFrameSkillBar:Size(285, 20)	
				ArchyArtifactFrameSkillBar.text:SetTextColor(1, 1, 1)
			end

			--ArchyArtifactFrameContainer:Width(285)
			--ArchyArtifactFrameContainer:ClearAllPoints()
			--ArchyArtifactFrameContainer:SetPoint('TOP', ArchyArtifactFrameSkillBar, 'BOTTOM', 0, -5)
			for i, child in pairs(ArchyArtifactFrame.children) do
				local containerFrame = _G['ArchyArtifactChildFrame'..i]
				local icon = _G['ArchyArtifactChildFrame'..i..'Icon']
				local fragmentBar = _G['ArchyArtifactChildFrame'..i..'FragmentBar']
				local solveButton = _G['ArchyArtifactChildFrame'..i..'SolveButton']

				--if containerFrame then
				--	containerFrame:Width(285)
				--end
				
				if icon then
					icon:SetTemplate('Default')
					--icon:Size(26)
					icon.texture:SetTexCoord(.08, .92, .08, .92)
					icon.texture:SetInside()
				end
				
				if solveButton then
					--solveButton:Size(26)
					solveButton:SetTemplate('Default')
					solveButton:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
					solveButton:GetNormalTexture():SetInside()	
					solveButton:GetDisabledTexture():SetTexCoord(.08, .92, .08, .92)
					solveButton:GetDisabledTexture():SetInside()		
					solveButton:StyleButton()
				end
				
				if fragmentBar then
					AS:SkinStatusBar(fragmentBar)	
					--fragmentBar:Size(180, 24)
					--if IsAddOnLoaded("ElvUI") then
					--	local x = AS:x
					--	fragmentBar.artifact:SetFont(x.pixelFont, 10, "MONOCHROMEOUTLINE")
					--	fragmentBar.fragments:SetFont(x.pixelFont, 10, "MONOCHROMEOUTLINE")
					--	fragmentBar.keystones.count:SetFont(x.pixelFont, 10, "MONOCHROMEOUTLINE")
					--else
					--	fragmentBar.artifact:SetFont(E["media"].pixelfont, 10, "MONOCHROMEOUTLINE")
					--	fragmentBar.fragments:SetFont(E["media"].pixelfont, 10, "MONOCHROMEOUTLINE")
					--	fragmentBar.keystones.count:SetFont(E["media"].pixelfont, 10, "MONOCHROMEOUTLINE")
					--end
				end
			end
	end
	hooksecurefunc(Archy, 'RefreshRacesDisplay', SkinArchyArtifactFrame)
	hooksecurefunc(Archy, "UpdateRacesFrame", SkinArchyArtifactFrame)
	Archy:UpdateRacesFrame()
	Archy:RefreshRacesDisplay()
	
	local function SkinArchyDigSiteFrame()
		AS:SkinFrame(ArchyDigSiteFrame)
		--if not InCombatLockdown() then ArchyDigSiteFrame:SetScale(1) end
	end

	hooksecurefunc(Archy, "UpdateDigSiteFrame", SkinArchyDigSiteFrame)

	if ArchyArtifactFrameSkillBar then
		AS:SkinStatusBar(ArchyArtifactFrameSkillBar)	
	end
	S:HandleButton(ArchyDistanceIndicatorFrameSurveyButton)
	ArchyDistanceIndicatorFrameSurveyButton:SetFrameLevel(ArchyDistanceIndicatorFrameSurveyButton:GetFrameLevel() + 5)
	S:HandleButton(ArchyDistanceIndicatorFrameCrateButton)
 	ArchyDistanceIndicatorFrameCrateButton:SetFrameLevel(ArchyDistanceIndicatorFrameCrateButton:GetFrameLevel() + 5)
	hooksecurefunc(Archy, "LDBTooltipShow", function(self) self.LDB_Tooltip:SetTemplate("Transparent") end)
end

AS:RegisterSkin(name,SkinArchy)