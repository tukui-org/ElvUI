local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_TorghastLevelPicker()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.torghastLevelPicker) then return end

	local frame = _G.TorghastLevelPickerFrame
	frame.Title:FontTemplate(nil, 24)

	S:HandleCloseButton(frame.CloseButton)
	S:HandleNextPrevButton(frame.Pager.PreviousPage)
	S:HandleNextPrevButton(frame.Pager.NextPage)
	S:HandleButton(frame.OpenPortalButton)
end

S:AddCallbackForAddon('Blizzard_TorghastLevelPicker')
