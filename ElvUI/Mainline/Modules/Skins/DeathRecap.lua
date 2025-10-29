local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_DeathRecap()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.deathRecap) then return end

	local DeathRecapFrame = _G.DeathRecapFrame
	DeathRecapFrame:StripTextures()
	DeathRecapFrame:SetTemplate('Transparent')
	DeathRecapFrame.CloseButton:SetFrameLevel(5)
	S:HandleCloseButton(DeathRecapFrame.CloseXButton)
	S:HandleButton(DeathRecapFrame.CloseButton)

	for i=1, 5 do
		local recap = DeathRecapFrame['Recap'..i].SpellInfo
		recap:CreateBackdrop()
		recap.backdrop:SetOutside(recap.Icon)
		recap.Icon:SetTexCoords()
		recap.Icon:SetParent(recap.backdrop)
		recap.IconBorder:Kill()
	end
end

S:AddCallbackForAddon('Blizzard_DeathRecap')
