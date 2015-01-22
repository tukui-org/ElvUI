local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.socket ~= true then return end
	ItemSocketingFrame:StripTextures()
	ItemSocketingFrame:SetTemplate("Transparent")
	ItemSocketingFrameInset:Kill()
	ItemSocketingScrollFrame:StripTextures()
	ItemSocketingScrollFrame:CreateBackdrop("Transparent")
	S:HandleScrollBar(ItemSocketingScrollFrameScrollBar, 2)
	for i = 1, MAX_NUM_SOCKETS  do
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
			local button = _G[("ItemSocketingSocket%d"):format(i)]
			local gemColor = GetSocketTypes(i)
			local color = GEM_TYPE_INFO[gemColor]
			button:SetBackdropColor(color.r, color.g, color.b, 0.15)
			button:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end)

	ItemSocketingFramePortrait:Kill()
	ItemSocketingSocketButton:ClearAllPoints()
	ItemSocketingSocketButton:Point("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -5, 5)
	S:HandleButton(ItemSocketingSocketButton)
	S:HandleCloseButton(ItemSocketingFrameCloseButton)
end

S:RegisterSkin("Blizzard_ItemSocketingUI", LoadSkin)