local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

local function HandlePanel(panel)
	if panel.DragonridingPanel then
		S:HandleButton(panel.DragonridingPanel.SkillsButton)
	end

	if panel.CloseButton then
		S:HandleCloseButton(panel.CloseButton)
	end

	if panel.MajorFactionList then
		-- 🧁
	end
end

function S:Blizzard_ExpansionLandingPage()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.expansionLanding) then return end

	local frame = _G.ExpansionLandingPage
	if frame.Overlay then
		for _, child in next, { frame.Overlay:GetChildren() } do
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
