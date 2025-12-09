local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, unpack = ipairs, unpack
local hooksecurefunc = hooksecurefunc

local C_ItemSocketInfo_GetSocketItemInfo = C_ItemSocketInfo.GetSocketItemInfo

local function UpdateItemSocketing()
	local SocketingContainer = _G.ItemSocketingFrame.SocketingContainer
	if not SocketingContainer or not SocketingContainer.SocketFrames then return end

	for i, socket in ipairs(SocketingContainer.SocketFrames) do
		local gemColor = C_ItemSocketInfo_GetSocketItemInfo(i)
		local color = E.GemTypeInfo[gemColor]
		if color then
			socket:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			local r, g, b = unpack(E.media.bordercolor)
			socket:SetBackdropBorderColor(r, g, b)
		end
	end
end

function S:Blizzard_ItemSocketingUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.socket) then return end

	local ItemSocketingFrame = _G.ItemSocketingFrame
	S:HandlePortraitFrame(ItemSocketingFrame)

	_G.ItemSocketingFramePortrait:Kill()
	_G.ItemSocketingDescription:DisableDrawLayer('BORDER')
	_G.ItemSocketingDescription:DisableDrawLayer('BACKGROUND')
	_G.ItemSocketingScrollFrame:StripTextures()
	_G.ItemSocketingScrollFrame:SetTemplate('Transparent')

	S:HandleTrimScrollBar(_G.ItemSocketingScrollFrame.ScrollBar)

	local SocketingContainer = ItemSocketingFrame.SocketingContainer
	if SocketingContainer and SocketingContainer.SocketFrames then
		for _, button in next, SocketingContainer.SocketFrames do
			button:StripTextures()
			button:StyleButton()
			button:SetTemplate(nil, true)

			if button.BracketFrame then
				button.BracketFrame:Kill()
			end

			if button.Background then
				button.Background:Kill()
			end
		end

		local ApplySocketsButton = SocketingContainer.ApplySocketsButton
		if ApplySocketsButton then
			ApplySocketsButton:ClearAllPoints()
			ApplySocketsButton:Point('BOTTOMRIGHT', ItemSocketingFrame, 'BOTTOMRIGHT', -5, 5)

			S:HandleButton(ApplySocketsButton)
		end
	end

	hooksecurefunc('ItemSocketingFrame_Update', UpdateItemSocketing)
end

S:AddCallbackForAddon('Blizzard_ItemSocketingUI')
