local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local select = select

local hooksecurefunc = hooksecurefunc

--ToDo: WoW10
function S:Blizzard_ExpansionLandingPage()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.expansionLanding) then return end

	local frame = _G.ExpansionLandingPage
	local panel

	if frame.Overlay then
		for i = 1, frame.Overlay:GetNumChildren() do
			local child = select(i, frame.Overlay:GetChildren())
			child:StripTextures()
			child:SetTemplate('Transparent')

			if child.DragonridingPanel then
				panel = child
				break
			end
		end
	end

	if not panel then return end

	if panel.DragonridingPanel then
		S:HandleButton(panel.DragonridingPanel.SkillsButton)
	end

	if panel.CloseButton then
		S:HandleCloseButton(panel.CloseButton)
	end

	if panel.MajorFactionList then
		-- ...
	end
end

S:AddCallbackForAddon('Blizzard_ExpansionLandingPage')
