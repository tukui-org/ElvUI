local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Blizzard_CovenantRenown()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.covenantRenown) then return end

	local frame = _G.CovenantRenownFrame
	local track = frame.TrackFrame
	S:HandleCloseButton(frame.CloseButton)

	hooksecurefunc(frame, 'SetUpCovenantData', function(Frame)
		Frame.CloseButton.Border:Hide()
		if E.private.skins.parchmentRemoverEnable then
			Frame:StripTextures()
		end
	end)

	if E.private.skins.parchmentRemoverEnable then
		if not frame.backdrop then
			frame:CreateBackdrop('Transparent')
		end
		if not track.backdrop then
			track:CreateBackdrop('Transparent')
		end
	end
end

S:AddCallbackForAddon('Blizzard_CovenantRenown')
