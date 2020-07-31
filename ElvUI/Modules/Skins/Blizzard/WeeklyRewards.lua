local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_WeeklyRewards()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.weeklyRewards) then return end

	local WeeklyRewardsFrame = _G.WeeklyRewardsFrame
	WeeklyRewardsFrame:CreateBackdrop('Transparent')
	S:HandleCloseButton(WeeklyRewardsFrame.CloseButton)

	WeeklyRewardsFrame.Name:FontTemplate(nil, 22)
	WeeklyRewardsFrame.Description:FontTemplate()
end

S:AddCallbackForAddon('Blizzard_WeeklyRewards')
