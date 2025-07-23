local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local format = format
local unpack = unpack

local GetNumSockets = GetNumSockets
local GetSocketTypes = GetSocketTypes
local hooksecurefunc = hooksecurefunc

function S:Blizzard_ItemSocketingUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.socket) then return end

	local ItemSocketingFrame = _G.ItemSocketingFrame
	S:HandleFrame(ItemSocketingFrame)

	S:HandleScrollBar(_G.ItemSocketingScrollFrame.ScrollBar)

	_G.ItemSocketingDescription:DisableDrawLayer('BORDER')
	_G.ItemSocketingDescription:DisableDrawLayer('BACKGROUND')
	_G.ItemSocketingScrollFrame:StripTextures()
	_G.ItemSocketingScrollFrame:CreateBackdrop('Transparent')

	for i = 1, _G.MAX_NUM_SOCKETS do
		local button = _G[format('ItemSocketingSocket%d', i)]
		local button_bracket = _G[format('ItemSocketingSocket%dBracketFrame', i)]
		local button_bg = _G[format('ItemSocketingSocket%dBackground', i)]
		local button_icon = _G[format('ItemSocketingSocket%dIconTexture', i)]
		button:StripTextures()
		button:StyleButton(false)
		button:CreateBackdrop(nil, true)
		button_bracket:Kill()
		button_bg:Kill()
		button_icon:SetTexCoord(unpack(E.TexCoords))
		button_icon:SetInside()
	end

	hooksecurefunc('ItemSocketingFrame_Update', function()
		local numSockets = GetNumSockets()
		for i = 1, numSockets do
			local socket = _G['ItemSocketingSocket'..i]
			local gemColor = GetSocketTypes(i)
			local color = E.GemTypeInfo[gemColor]
			socket.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end)

	S:HandleCloseButton(_G.ItemSocketingFrameCloseButton)

	_G.ItemSocketingFramePortrait:Kill()
	_G.ItemSocketingSocketButton:ClearAllPoints()
	_G.ItemSocketingSocketButton:Point('BOTTOMRIGHT', ItemSocketingFrame, 'BOTTOMRIGHT', -5, 5)
	S:HandleButton(_G.ItemSocketingSocketButton)
end

S:AddCallbackForAddon('Blizzard_ItemSocketingUI')
