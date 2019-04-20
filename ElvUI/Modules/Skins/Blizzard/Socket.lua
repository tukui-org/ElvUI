local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local ipairs, unpack = ipairs, unpack
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
		button:SetTemplate(nil, true)
		button_bracket:Kill()
		button_bg:Kill()
		button_icon:SetTexCoord(unpack(E.TexCoords))
		button_icon:SetInside()
	end

	-- Copied from Blizzard
	local gemTypeInfo ={
		Yellow = {r=0.97, g=0.82, b=0.29},
		Red = {r=1, g=0.47, b=0.47},
		Blue = {r=0.47, g=0.67, b=1},
		Hydraulic = {r=1, g=1, b=1},
		Cogwheel = {r=1, g=1, b=1},
		Meta = {r=1, g=1, b=1},
		Prismatic = {r=1, g=1, b=1},
		PunchcardRed = {r=1, g=0.47, b=0.47},
		PunchcardYellow = {r=0.97, g=0.82, b=0.29},
		PunchcardBlue = {r=0.47, g=0.67, b=1},
	}

	hooksecurefunc("ItemSocketingFrame_Update", function()
		for i, socket in ipairs(_G.ItemSocketingFrame.Sockets) do
			local gemColor = GetSocketTypes(i);
			local color = gemTypeInfo[gemColor]
			socket:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end)

	_G.ItemSocketingFramePortrait:Kill()
	_G.ItemSocketingSocketButton:ClearAllPoints()
	_G.ItemSocketingSocketButton:Point("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -5, 5)
	S:HandleButton(_G.ItemSocketingSocketButton)
end

S:AddCallbackForAddon("Blizzard_ItemSocketingUI", "ItemSocket", LoadSkin)
