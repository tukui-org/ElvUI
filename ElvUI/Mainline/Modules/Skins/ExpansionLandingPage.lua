local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local hooksecurefunc = hooksecurefunc

local function HandlePanel(panel)
	if panel.DragonridingPanel then
		S:HandleButton(panel.DragonridingPanel.SkillsButton)
	end

	if panel.CloseButton then
		S:HandleCloseButton(panel.CloseButton)
	end
end

local function HandleScrollBar(frame)
	if frame.MajorFactionList then
		S:HandleTrimScrollBar(frame.MajorFactionList.ScrollBar)
	end
end

local function DelayedMajorFactionList(frame)
	E:Delay(0.1, HandleScrollBar, frame)
end

function S:Blizzard_ExpansionLandingPage()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.expansionLanding) then return end

	local factionList = _G.LandingPageMajorFactionList
	if factionList then
		hooksecurefunc(factionList, 'Create', DelayedMajorFactionList)
	end

	local overlay = _G.ExpansionLandingPage.Overlay
	if overlay then
		for _, child in next, { overlay:GetChildren() } do
			if E.private.skins.parchmentRemoverEnable then
				child:StripTextures()
				child:SetTemplate('Transparent')
			end

			if child.DragonridingPanel then
				HandlePanel(child)
			end
		end
	end
end

S:AddCallbackForAddon('Blizzard_ExpansionLandingPage')
