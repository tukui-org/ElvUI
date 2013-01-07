local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "MRTSkin"
local function SkinMRT(self)
	AS:SkinFrame(MRT_GUIFrame)
	AS:SkinFrame(MRT_GUI_FourRowDialog)
	S:HandleCloseButton(MRT_GUIFrame_CloseButton)
	S:HandleButton(MRT_GUIFrame_RaidLog_Export_Button)
	S:HandleButton(MRT_GUIFrame_RaidLog_Delete_Button)
	S:HandleButton(MRT_GUIFrame_RaidLog_ExportNormal_Button)
	S:HandleButton(MRT_GUIFrame_RaidLog_ExportHeroic_Button)
	S:HandleButton(MRT_GUIFrame_RaidBosskills_Add_Button)
	S:HandleButton(MRT_GUIFrame_RaidBosskills_Delete_Button)
	S:HandleButton(MRT_GUIFrame_RaidBosskills_Export_Button)
	S:HandleButton(MRT_GUIFrame_RaidAttendees_Add_Button)
	S:HandleButton(MRT_GUIFrame_RaidAttendees_Delete_Button)
	S:HandleButton(MRT_GUIFrame_TakeSnapshot_Button)
	S:HandleButton(MRT_GUIFrame_StartNewRaid_Button)
	S:HandleButton(MRT_GUIFrame_MakeAttendanceCheck_Button)
	S:HandleButton(MRT_GUIFrame_EndCurrentRaid_Button)
	S:HandleButton(MRT_GUIFrame_ResumeLastRaid_Button)
	S:HandleButton(MRT_GUIFrame_BossLoot_Add_Button)
	S:HandleButton(MRT_GUIFrame_BossLoot_Modify_Button)
	S:HandleButton(MRT_GUIFrame_BossLoot_Delete_Button)
	S:HandleButton(MRT_GUIFrame_BossAttendees_Add_Button)
	S:HandleButton(MRT_GUIFrame_BossAttendees_Delete_Button)
	S:HandleButton(MRT_GUI_FourRowDialog_OKButton)
	S:HandleButton(MRT_GUI_FourRowDialog_CancelButton)

	for i = 1, 6 do
		AS:SkinFrame(_G["ScrollTable"..i])
		_G["ScrollTable"..i.."ScrollFrameScrollBar"]:StripTextures(true)
		S:HandleScrollBar(_G["ScrollTable"..i.."ScrollFrameScrollBar"])
	end

	MRT_GUI_ItemTT:HookScript("OnShow", function(self) self:SetTemplate("Transparent") end)
	MRT_GUI_TT:HookScript("OnShow", function(self) self:SetTemplate("Transparent") end)
end

AS:RegisterSkin(name,SkinMRT)