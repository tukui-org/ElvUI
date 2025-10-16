local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local format = format
local ipairs, unpack = ipairs, unpack
local GetSocketTypes = GetSocketTypes
local hooksecurefunc = hooksecurefunc

local C_ItemSocketInfo_GetSocketItemInfo = C_ItemSocketInfo.GetSocketItemInfo

function S:Blizzard_ItemSocketingUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.socket) then return end

	local ItemSocketingFrame = _G.ItemSocketingFrame
	S:HandlePortraitFrame(ItemSocketingFrame)

	_G.ItemSocketingDescription:DisableDrawLayer('BORDER')
	_G.ItemSocketingDescription:DisableDrawLayer('BACKGROUND')
	_G.ItemSocketingScrollFrame:StripTextures()
	_G.ItemSocketingScrollFrame:SetTemplate('Transparent')
	S:HandleTrimScrollBar(_G.ItemSocketingScrollFrame.ScrollBar)

	for i = 1, _G.MAX_NUM_SOCKETS do
		local button = _G.ItemSocketingFrame.SocketingContainer['Socket'..i]
		local button_bracket = button.BracketFrame
		local button_bg = button.Background

		button:StripTextures()
		button:StyleButton()
		button:SetTemplate(nil, true)
		button_bracket:Kill()
		button_bg:Kill()
	end

	hooksecurefunc('ItemSocketingFrame_Update', function()
		for i, socket in ipairs(_G.ItemSocketingFrame.SocketingContainer.SocketFrames) do
			local gemColor = C_ItemSocketInfo_GetSocketItemInfo(i)
			local color = E.GemTypeInfo[gemColor]
			if color then
				socket:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				socket:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	_G.ItemSocketingFramePortrait:Kill()
	_G.ItemSocketingFrame.SocketingContainer.ApplySocketsButton:ClearAllPoints()
	_G.ItemSocketingFrame.SocketingContainer.ApplySocketsButton:Point('BOTTOMRIGHT', ItemSocketingFrame, 'BOTTOMRIGHT', -5, 5)
	S:HandleButton(_G.ItemSocketingFrame.SocketingContainer.ApplySocketsButton)
end

S:AddCallbackForAddon('Blizzard_ItemSocketingUI')
