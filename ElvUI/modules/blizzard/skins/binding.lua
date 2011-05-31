local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].binding ~= true then return end

local function LoadSkin()
	local buttons = {
		"KeyBindingFrameDefaultButton",
		"KeyBindingFrameUnbindButton",
		"KeyBindingFrameOkayButton",
		"KeyBindingFrameCancelButton",
	}
	
	for _, v in pairs(buttons) do
		_G[v]:StripTextures()
		_G[v]:SetTemplate("Default", true)
	end
	
	E.SkinCheckBox(KeyBindingFrameCharacterButton)
	KeyBindingFrameHeaderText:ClearAllPoints()
	KeyBindingFrameHeaderText:Point("TOP", KeyBindingFrame, "TOP", 0, -4)
	KeyBindingFrame:StripTextures()
	KeyBindingFrame:SetTemplate("Transparent")
	
	for i = 1, KEY_BINDINGS_DISPLAYED  do
		local button1 = _G["KeyBindingFrameBinding"..i.."Key1Button"]
		local button2 = _G["KeyBindingFrameBinding"..i.."Key2Button"]
		button1:StripTextures(true)
		button1:StyleButton(false)
		button1:SetTemplate("Default", true)
		button2:StripTextures(true)
		button2:StyleButton(false)
		button2:SetTemplate("Default", true)
	end
	
	KeyBindingFrameUnbindButton:Point("RIGHT", KeyBindingFrameOkayButton, "LEFT", -3, 0)
	KeyBindingFrameOkayButton:Point("RIGHT", KeyBindingFrameCancelButton, "LEFT", -3, 0)
end

E.SkinFuncs["Blizzard_BindingUI"] = LoadSkin