local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local format = format
local ipairs, unpack = ipairs, unpack
local GetSocketTypes = GetSocketTypes
local hooksecurefunc = hooksecurefunc

function S:Blizzard_ItemSocketingUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.socket) then return end

	local ItemSocketingFrame = _G.ItemSocketingFrame
	S:HandlePortraitFrame(ItemSocketingFrame)

	_G.ItemSocketingDescription:DisableDrawLayer('BORDER')
	_G.ItemSocketingDescription:DisableDrawLayer('BACKGROUND')
	_G.ItemSocketingScrollFrame:StripTextures()
	_G.ItemSocketingScrollFrame:SetTemplate('Transparent')
	S:HandleScrollBar(_G.ItemSocketingScrollFrameScrollBar, 2)

	for i = 1, _G.MAX_NUM_SOCKETS do
		local button = _G[format('ItemSocketingSocket%d', i)]
		local button_bracket = _G[format('ItemSocketingSocket%dBracketFrame', i)]
		local button_bg = _G[format('ItemSocketingSocket%dBackground', i)]
		local button_icon = _G[format('ItemSocketingSocket%dIconTexture', i)]

		button:StripTextures()
		button:StyleButton(false)
		button:SetTemplate(nil, true)
		button_bracket:Kill()
		button_bg:Kill()
		button_icon:SetTexCoord(unpack(E.TexCoords))
		button_icon:SetInside()
	end

	hooksecurefunc('ItemSocketingFrame_Update', function()
		for i, socket in ipairs(_G.ItemSocketingFrame.Sockets) do
			local gemColor = GetSocketTypes(i)
			local color = E.GemTypeInfo[gemColor]
			if color then
				socket:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				socket:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end
	end)

	_G.ItemSocketingFramePortrait:Kill()
	_G.ItemSocketingSocketButton:ClearAllPoints()
	_G.ItemSocketingSocketButton:Point('BOTTOMRIGHT', ItemSocketingFrame, 'BOTTOMRIGHT', -5, 5)
	S:HandleButton(_G.ItemSocketingSocketButton)
end

S:AddCallbackForAddon('Blizzard_ItemSocketingUI')
