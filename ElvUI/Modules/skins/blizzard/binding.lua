local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KEY_BINDINGS_DISPLAYED

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.binding ~= true then return end

	local buttons = {
		"defaultsButton",
		"unbindButton",
		"okayButton",
		"cancelButton",
	}

	local KeyBindingFrame = _G["KeyBindingFrame"]
	for _, v in pairs(buttons) do
		S:HandleButton(KeyBindingFrame[v])
	end

	KeyBindingFrame.header:StripTextures()
	_G["KeyBindingFrameScrollFrame"]:StripTextures()
	S:HandleScrollBar(_G["KeyBindingFrameScrollFrameScrollBar"])

	S:HandleCheckBox(KeyBindingFrame.characterSpecificButton)
	KeyBindingFrame.header:ClearAllPoints()
	KeyBindingFrame.header:Point("TOP", KeyBindingFrame, "TOP", 0, -4)
	KeyBindingFrame:StripTextures()
	KeyBindingFrame:SetTemplate("Transparent")

	_G["KeyBindingFrameCategoryList"]:StripTextures()
	_G["KeyBindingFrameCategoryList"]:SetTemplate("Transparent")
	KeyBindingFrame.bindingsContainer:StripTextures()
	KeyBindingFrame.bindingsContainer:SetTemplate("Transparent")

	for i = 1, KEY_BINDINGS_DISPLAYED, 1 do
		local button1 = _G["KeyBindingFrameKeyBinding"..i.."Key1Button"]
		local button2 = _G["KeyBindingFrameKeyBinding"..i.."Key2Button"]
		S:HandleButton(button1)
		S:HandleButton(button2)
	end

	KeyBindingFrame.okayButton:Point("BOTTOMLEFT", KeyBindingFrame.unbindButton, "BOTTOMRIGHT", 3, 0)
	KeyBindingFrame.cancelButton:Point("BOTTOMLEFT", KeyBindingFrame.okayButton, "BOTTOMRIGHT", 3, 0)
	KeyBindingFrame.unbindButton:Point("BOTTOMRIGHT", KeyBindingFrame, "BOTTOMRIGHT", -211, 16)
end

S:AddCallbackForAddon("Blizzard_BindingUI", "Binding", LoadSkin)
