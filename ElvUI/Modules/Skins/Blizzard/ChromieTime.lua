local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_ChromieTimeUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.chromieTime) then return end

	local frame = _G.ChromieTimeFrame
	S:HandleCloseButton(frame.CloseButton)
	S:HandleButton(frame.SelectButton)

	if E.private.skins.parchmentRemoverEnable then
		frame:StripTextures()
		frame.Background:Hide()
		frame:SetTemplate('Transparent')

		local Title = frame.Title
		Title:DisableDrawLayer('BACKGROUND')
		Title:SetTemplate('Transparent')

		local InfoFrame = frame.CurrentlySelectedExpansionInfoFrame
		InfoFrame:DisableDrawLayer('BACKGROUND')
		InfoFrame:SetTemplate('Transparent')
		InfoFrame.Name:SetTextColor(1, .8, 0)
		InfoFrame.Description:SetTextColor(1, 1, 1)
	end
end

S:AddCallbackForAddon('Blizzard_ChromieTimeUI')
