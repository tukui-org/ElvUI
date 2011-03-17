local E, C, L, DB = unpack(ElvUI) -- Import Functions/Constants, Config, Locales
Tukui = {E, C, L} -- Add support for local T, C, L = unpack(Tukui)

TukuiMinimap = ElvuiMinimap
TukuiActionBarBackground = ElvuiActionBarBackground
TukuiInfoLeft = ElvuiInfoLeft
TukuiInfoRight = ElvuiInfoRight

if IsAddOnLoaded("ElvUI_RaidDPS") then
	TukuiPlayer = ElvDPS_player
	TukuiTarget = ElvDPS_target
	TukuiFocus = ElvDPS_focus
elseif IsAddOnLoaded("ElvUI_RaidHeal") then
	TukuiPlayer = ElvHeal_player
	TukuiTarget = ElvHeal_target
	TukuiFocus = ElvHeal_focus
end