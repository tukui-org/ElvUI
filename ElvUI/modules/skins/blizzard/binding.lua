local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.binding ~= true then return end
	local buttons = {
		"defaultsButton",
		"unbindButton",
		"okayButton",
		"cancelButton",
	}

	for _, v in pairs(buttons) do
		KeyBindingFrame[v]:StripTextures()
		KeyBindingFrame[v]:SetTemplate("Default", true)
	end

	KeyBindingFrame.header:StripTextures()
	KeyBindingFrameScrollFrame:StripTextures()
	S:HandleScrollBar(KeyBindingFrameScrollFrameScrollBar)

	S:HandleCheckBox(KeyBindingFrame.characterSpecificButton)
	KeyBindingFrame.header:ClearAllPoints()
	KeyBindingFrame.header:Point("TOP", KeyBindingFrame, "TOP", 0, -4)
	KeyBindingFrame:StripTextures()
	KeyBindingFrame:SetTemplate("Transparent")

	KeyBindingFrameCategoryList:StripTextures()
	KeyBindingFrameCategoryList:SetTemplate("Transparent")
	KeyBindingFrame.bindingsContainer:StripTextures()
	KeyBindingFrame.bindingsContainer:SetTemplate("Transparent")


	for i = 1, KEY_BINDINGS_DISPLAYED  do
		local button1 = _G["KeyBindingFrameKeyBinding"..i.."Key1Button"]
		local button2 = _G["KeyBindingFrameKeyBinding"..i.."Key2Button"]
		button1:StripTextures(true)
		button1:StyleButton(false)
		button1:SetTemplate("Default", true)
		button2:StripTextures(true)
		button2:StyleButton(false)
		button2:SetTemplate("Default", true)
	end
	KeyBindingFrame.okayButton:SetPoint("BOTTOMLEFT", KeyBindingFrame.unbindButton, "BOTTOMRIGHT", 3, 0)
	KeyBindingFrame.cancelButton:SetPoint("BOTTOMLEFT", KeyBindingFrame.okayButton, "BOTTOMRIGHT", 3, 0)
	KeyBindingFrame.unbindButton:SetPoint("BOTTOMRIGHT", KeyBindingFrame, "BOTTOMRIGHT", -211, 16)

end

S:RegisterSkin("Blizzard_BindingUI", LoadSkin)