local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "LinkWranglerSkin"
local function SkinLinkWrangler(self, event)
	LWTukuiSkinner_Path = "Interface\\AddOns\\Tukui_Skins\\skins\\"
	LWTukuiSkinner_Close = LWTukuiSkinner_Path.."Buttons\\close"
	LWTukuiSkinner_Min = LWTukuiSkinner_Path.."Buttons\\min"
	LWTukuiSkinner_Compare = LWTukuiSkinner_Path.."Buttons\\compare"
	LWTukuiSkinner_CompareDisabled = LWTukuiSkinner_Path.."Buttons\\compareDisable"
	LWTukuiSkinner_Whisper = LWTukuiSkinner_Path.."Buttons\\whisper"
	LWTukuiSkinner_Relink = LWTukuiSkinner_Path.."Buttons\\relink"
	LWTukuiSkinner_Dress = LWTukuiSkinner_Path.."Buttons\\dress"

	function LWTukuiSkinner(frame, link)
		local r, g, b = GetItemQualityColor(select(3,GetItemInfo(link)))
		frame:SetTemplate("Default")
		frame:SetBackdropBorderColor(r,g,b)

		local closeButton = _G[frame:GetName().."CloseButton"]
		LWTukuiSkinner_SkinButton(closeButton,LWTukuiSkinner_Close)

		local minButton = _G[frame:GetName().."MinButton"]
		lastAdded = LWTukuiSkinner_SkinButton(minButton,LWTukuiSkinner_Min)

		local compButton = _G[frame:GetName().."CompButton"]
		LWTukuiSkinner_SkinButton(compButton,LWTukuiSkinner_Compare,LWTukuiSkinner_CompareDisabled)

		local whisperButton = _G[frame:GetName().."WhisperButton"]
		LWTukuiSkinner_SkinButton(whisperButton,LWTukuiSkinner_Whisper)

		local relinkButton = _G[frame:GetName().."RelinkButton"]
		LWTukuiSkinner_SkinButton(relinkButton,LWTukuiSkinner_Relink)

		local dressupButton = _G[frame:GetName().."DressupButton"]
		LWTukuiSkinner_SkinButton(dressupButton,LWTukuiSkinner_Dress)

		local captureButton = _G[frame:GetName().."CaptureButton"]
		LWTukuiSkinner_SkinButton(captureButton,LWTukuiSkinner_Compare)
	end

	function LWTukuiSkinner_PrintTable(t)
		for k,v in pairs(t) do
			if (type(v) == "table") then
				DEFAULT_CHAT_FRAME:AddMessage(k .. ":")
				EIICPrintTable(v)
			else
				DEFAULT_CHAT_FRAME:AddMessage(k .. "(" .. type(v) ..") = " .. tostring(v))
			end
		end
	end

	function LWTukuiSkinner_SkinButton(button, tex, distex)
		if (button == nil) then
			return
		end

		button:SetNormalTexture(tex)
		button:SetDisabledTexture(distex)
		button:SetPushedTexture(tex)
		button:SetHighlightTexture(tex)

		return button
	end

	LinkWrangler.RegisterCallback("Tukui_LinkWrangler_Skin",LWTukuiSkinner,"show","showcomp")

end

AS:RegisterSkin(name,SkinLinkWrangler)