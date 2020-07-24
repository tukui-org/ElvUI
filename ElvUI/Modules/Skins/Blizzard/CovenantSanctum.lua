local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

-- SHADOWLANDS
function S:Blizzard_CovenantSanctum()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.CovenantSanctum) then return end

	local frame = _G.CovenantSanctumFrame

	hooksecurefunc(frame, 'SetTab', function() -- check this hook plx
		if not frame.IsSkinned then
			frame:StripTextures()
			frame:CreateBackdrop('Transparent')

			S:HandleButton(frame.UpgradesTab.DepositButton)
			S:HandleButton(frame.UpgradesTab.TalentsList.UpgradeButton)

			frame.IsSkinned = true
		end
	end)

	S:HandleCloseButton(_G.CovenantSanctumFrameCloseButton)
	S:HandleTab(_G.CovenantSanctumFrameTab1)

end

S:AddCallbackForAddon('Blizzard_CovenantSanctum')
