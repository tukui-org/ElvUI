local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local next = next

local hooksecurefunc = hooksecurefunc

function S:Blizzard_CovenantRenown()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantRenown) then return end

	local frame = _G.CovenantRenownFrame
	S:HandleCloseButton(frame.CloseButton)

	hooksecurefunc(frame.TrackFrame, 'Init', function(self)
		for _, element in next, self.Elements do
			if not element.IsSkinned then
				element.LevelBorder:SetAlpha(0)
				element.IsSkinned = true
			end
		end
	end)

	if E.private.skins.parchmentRemoverEnable then
		frame:CreateBackdrop('Transparent')

		hooksecurefunc(frame, 'SetUpTextureKits', function(self)
			self:StripTextures()
			self.CloseButton.Border:Hide()
		end)
	end
end

S:AddCallbackForAddon('Blizzard_CovenantRenown')
