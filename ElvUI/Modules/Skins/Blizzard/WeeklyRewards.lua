local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_WeeklyRewards()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.weeklyRewards) then return end

	local frame = _G.WeeklyRewardsFrame
	if E.private.skins.parchmentRemoverEnable then
		frame:StripTextures()
	end

	frame:CreateBackdrop('Transparent')

	S:HandleCloseButton(frame.CloseButton)
end

S:AddCallbackForAddon('Blizzard_WeeklyRewards')
