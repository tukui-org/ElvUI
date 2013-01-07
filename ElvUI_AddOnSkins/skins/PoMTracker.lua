local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "PoMTrackerSkin"
local function SkinPoMTracker(self)
	AS:SkinFrame(PoMOptionFrame)
	S:HandleCloseButton(PoMOptionFrame_CloseButton)

	pomtracker1:CreateBackdrop("Transparent")
	pomtracker1:Size(85,15)

	pomtracker2:ClearAllPoints()
	pomtracker2:Point("TOP", pomtracker1, "BOTTOM", 0, -5)
	pomtracker2:StripTextures(True)
	pomtracker2:CreateBackdrop("Transparent")

	pomtracker3:CreateBackdrop("Transparent")
	pomtracker3:ClearAllPoints()
	pomtracker3:Point("TOP", pomtrackerstatusBar, "BOTTOM", 0, -5)
	pomtracker3:Height(15)

	S:HandleButton(pomtracker3_Button1)

	pomtrackerstatusBar:ClearAllPoints()
	pomtrackerstatusBar:Point("TOP", pomtracker2, "BOTTOM", 0, -5)
	pomtrackerstatusBar:CreateBackdrop("Transparent")
	pomtrackerstatusBar:SetStatusBarTexture(AS.LSM:Fetch("statusbar",E.private.general.normTex))

	for i = 1,6 do
		S:HandleCheckBox(_G["PoMOptionFrame_CheckButton"..i])
	end
	pomtracker2:HookScript("OnUpdate", function() pomtrackerstatusBar:Width(pomtracker2:GetWidth()) pomtracker3:Width(pomtracker2:GetWidth()) end)
end

AS:RegisterSkin(name,SkinPoMTracker)