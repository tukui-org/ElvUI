local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "QuestCompletistSkin"
local function SkinQuestCompletist(self)
	local tooltips = {
		"qcMapTooltip",
		"qcQuestInformationTooltip",
		"qcToastTooltip",
		"qcQuestReputationTooltip",
		"qcNewDataAlertTooltip",
		"qcMutuallyExclusiveAlertTooltip",
	}

	for _, object in pairs(tooltips) do
		if _G[object] then
			_G[object]:HookScript("OnShow", function(self) self:SetFrameStrata("DIALOG") AS:SkinFrame(self) end)
		end
	end

	AS:SkinFrame(qcQuestCompletistUI)
	qcQuestCompletistUI:Size(360,450)
	S:HandleEditBox(qcSearchBox)
	S:HandleButton(qcOptionsButton)
	S:HandleButton(qcCategoryDropdownButton)
	S:HandleCloseButton(qcXButton)
	S:HandleSliderFrame(qcMenuSlider, 16)
	qcMenuSlider:Point("TOPLEFT", qcQuestCompletistUI, "TOPLEFT", 303, -90)
	qcMenuSlider:Height(256)
end

AS:RegisterSkin(name,SkinQuestCompletist)