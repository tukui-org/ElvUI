local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local function DoDis(self, event, ...)

		QuestNPCModel:ClearAllPoints()
		QuestNPCModel:SetPoint("TOPLEFT", LightHeadedFrame, "TOPRIGHT", 5, -10)
		QuestNPCModel:SetAlpha(0.85)

		LightHeadedFrame:Point("LEFT",  QuestLogFrame, "RIGHT", 2, 0)
			
end

local function SkinOptions(self, event, ...)-- Skin the Options Frame
		local lhp = _G["LightHeaded_Panel"]
		if lhp:IsVisible() then

		for i = 1, 9 do
			local cbox = _G["LightHeaded_Panel_Toggle"..i]
			S:HandleCheckBox(cbox)
		end

		local buttons = {
			"LightHeaded_Panel_Button1",
			"LightHeaded_Panel_Button2",
			}
	
		for _, button in pairs(buttons) do
			S:HandleButton(_G[button])
		end
		
		LightHeaded_Panel_Button2:Disable()
	
		local detachwarn = CreateFrame("Frame", "DetachWarning", LightHeaded_Panel)
				detachwarn:SetWidth(280)	
				detachwarn.title = detachwarn:CreateFontString(nil, "ARTWORK")
				detachwarn.title2 = detachwarn:CreateFontString(nil, "ARTWORK")
				detachwarn.title:SetFontObject(GameFontHighlight)
				detachwarn.title2:SetFontObject(GameFontHighlight)
				detachwarn.title:SetPoint("LEFT", LightHeaded_Panel_Button2, "RIGHT", 10, 5)
				detachwarn.title2:SetPoint("LEFT", LightHeaded_Panel_Button2, "RIGHT", 12, -7)
				detachwarn.title:SetText("Detach Mode is buggy with Lightheaded Skin!")
				detachwarn.title2:SetText("Type /lh detach to use at your own risk.")
	end
end

local name = "LightheadedSkin"
local function SkinLightHeaded(self)
	AS:SkinFrame(LightHeadedFrame)
	AS:SkinFrame(LightHeadedFrameSub)
	AS:SkinFrame(LightHeadedSearchBox)
	LightHeadedTooltip:HookScript("OnShow", function(self) self:SetTemplate("Transparent") end)
						
	LightHeadedScrollFrame:StripTextures()
	
	local lhframe = LightHeadedFrame		
	lhframe.close:Hide()
	S:HandleCloseButton(lhframe.close)
	lhframe.handle:Hide()
	
	local lhframe = LightHeadedFrameSub
	S:HandleNextPrevButton(lhframe.prev)
	S:HandleNextPrevButton(lhframe.next)

	lhframe.prev:SetWidth(16)
	lhframe.prev:SetHeight(16)
	lhframe.next:SetWidth(16)
	lhframe.next:SetHeight(16)
	lhframe.prev:SetPoint("RIGHT", lhframe.page, "LEFT", -25, 0)
	lhframe.next:SetPoint("LEFT", lhframe.page, "RIGHT", 25, 0)

	S:HandleScrollBar(LightHeadedScrollFrameScrollBar, 5)

	lhframe.title:SetTextColor(23/255, 132/255, 209/255)	

	local LH_OnLoad = _G["LightHeadedFrame"]
	LH_OnLoad:SetScript("OnUpdate", DoDis)

	local LH_Options = _G["LightHeaded_Panel"]
end

AS:RegisterSkin(name,SkinLightHeaded)