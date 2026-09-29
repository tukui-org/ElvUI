local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function DialogDisplay(dialog, _, _, isRated, queueType)
	dialog.enterButton:ClearAllPoints()

	if dialog.leaveButton:IsShown() then
		dialog.enterButton:Point('BOTTOMRIGHT', dialog, 'BOTTOM', -7, 16)

		dialog.leaveButton:ClearAllPoints()
		dialog.leaveButton:Point('BOTTOMLEFT', dialog, 'BOTTOM', 7, 16)
	else
		dialog.enterButton:Point('BOTTOM', 0, 16)
	end

	if queueType == 'BATTLEGROUND' and not isRated then
		dialog.background:SetTexCoord(0, 1, 0.01, 1)
	end
end

function S:Blizzard_LFGUtil()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.pvp) then return end

	S:HandleCloseButton(_G.PVPReadyDialogCloseButton)
	S:SkinReadyDialog(_G.PVPReadyDialog, 54)

	hooksecurefunc('PVPReadyDialog_Display', DialogDisplay)
end

S:AddCallbackForAddon('Blizzard_LFGUtil')
