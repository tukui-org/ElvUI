local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local GetNumSockets = GetNumSockets
local GetSocketTypes = GetSocketTypes
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.socket ~= true then return end

	local ItemSocketingFrame = _G.ItemSocketingFrame
	S:HandlePortraitFrame(ItemSocketingFrame, true)

	_G.ItemSocketingDescription:DisableDrawLayer("BORDER")
	_G.ItemSocketingDescription:DisableDrawLayer("BACKGROUND")
	_G.ItemSocketingScrollFrame:StripTextures()
	_G.ItemSocketingScrollFrame:CreateBackdrop("Transparent")
	S:HandleScrollBar(_G.ItemSocketingScrollFrameScrollBar, 2)

	for i = 1, _G.MAX_NUM_SOCKETS  do
		local button = _G[("ItemSocketingSocket%d"):format(i)]
		local button_bracket = _G[("ItemSocketingSocket%dBracketFrame"):format(i)]
		local button_bg = _G[("ItemSocketingSocket%dBackground"):format(i)]
		local button_icon = _G[("ItemSocketingSocket%dIconTexture"):format(i)]
		button:StripTextures()
		button:StyleButton(false)
		button:SetTemplate("Default", true)
		button_bracket:Kill()
		button_bg:Kill()
		button_icon:SetTexCoord(unpack(E.TexCoords))
		button_icon:SetInside()
	end

	hooksecurefunc("ItemSocketingFrame_Update", function()
		local numSockets = GetNumSockets();
		for i=1, numSockets do
			local color = _G.GEM_TYPE_INFO[GetSocketTypes(i)]

			if color then
				local button = _G["ItemSocketingSocket"..i]
				button:SetBackdropColor(color.r, color.g, color.b, 0.15)
				button:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end)

	_G.ItemSocketingFramePortrait:Kill()
	_G.ItemSocketingSocketButton:ClearAllPoints()
	_G.ItemSocketingSocketButton:Point("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -5, 5)
	S:HandleButton(_G.ItemSocketingSocketButton)
end

S:AddCallbackForAddon("Blizzard_ItemSocketingUI", "ItemSocket", LoadSkin)
