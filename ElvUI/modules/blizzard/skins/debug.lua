local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].debug ~= true then return end

local function LoadSkin()
	local noscalemult = E.mult * C["general"].uiscale
	local bg = {
	  bgFile = C["media"].blank, 
	  edgeFile = C["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = noscalemult, 
	  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
	}
	
	ScriptErrorsFrame:SetBackdrop(bg)
	ScriptErrorsFrame:SetBackdropColor(unpack(C.media.backdropfadecolor))
	ScriptErrorsFrame:SetBackdropBorderColor(unpack(C.media.bordercolor))	

	EventTraceFrame:SetTemplate("Transparent")
	local texs = {
		"TopLeft",
		"TopRight",
		"Top",
		"BottomLeft",
		"BottomRight",
		"Bottom",
		"Left",
		"Right",
		"TitleBG",
		"DialogBG",
	}
	
	for i=1, #texs do
		_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
		_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
	end
	
	local bg = {
	  bgFile = C["media"].normTex, 
	  edgeFile = C["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = noscalemult, 
	  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
	}
	
	for i=1, ScriptErrorsFrame:GetNumChildren() do
		local child = select(i, ScriptErrorsFrame:GetChildren())
		if child:GetObjectType() == "Button" and not child:GetName() then
			
			E.SkinButton(child)
			child:SetBackdrop(bg)
			child:SetBackdropColor(unpack(C.media.backdropcolor))
			child:SetBackdropBorderColor(unpack(C.media.bordercolor))	
		end
	end	
end

E.SkinFuncs["Blizzard_DebugTools"] = LoadSkin