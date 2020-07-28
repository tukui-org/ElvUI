local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_NewPlayerExperienceGuide()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.Guide) then return end

	local frame = _G.GuideFrame
	S:HandlePortraitFrame(frame)
end

S:AddCallbackForAddon('Blizzard_NewPlayerExperienceGuide')
