local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

-- 9.0 Shadowlands
function S:Blizzard_BarbershopUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.barber) then return end

	local frame = _G.BarberShopFrame

	S:HandleButton(frame.ResetButton)
	S:HandleButton(frame.CancelButton)
	S:HandleButton(frame.AcceptButton)
end

S:AddCallbackForAddon('Blizzard_BarbershopUI')

function S:Blizzard_CharacterCustomize()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.barber) then return end -- yes, it belongs also to tbe BarberUI

	local frame = _G.CharCustomizeFrame

	S:HandleButton(frame.SmallButtons.ResetCameraButton)
	S:HandleButton(frame.SmallButtons.ZoomOutButton)
	S:HandleButton(frame.SmallButtons.ZoomInButton)
	S:HandleButton(frame.SmallButtons.RotateLeftButton)
	S:HandleButton(frame.SmallButtons.RotateRightButton)
end

S:AddCallbackForAddon('Blizzard_CharacterCustomize')
