local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "RaidInviteOrganizerSkin"
local function SkinRIO(self)
	AS:SkinFrame(RIO_MainFrame)
	AS:SkinFrame(RIO_GuildMemberFrame)
	AS:SkinFrame(RIO_CodeWordsContainer)
	RIO_SliderContainer:StripTextures(True)

	S:HandleScrollBar(RIO_GuildSlider)
	S:HandleCloseButton(RIO_CloseButtonThing)
	S:HandleButton(RIO_SelectAll)
	S:HandleButton(RIO_SelectNone)
	S:HandleButton(RIO_SendMassInvites)
	S:HandleButton(RIO_SaveCodeWordList)
	S:HandleButton(RIO_ToggleCodewordInvites)

	S:HandleCheckBox(RIO_ShowOfflineBox)
	S:HandleCheckBox(RIO_GuildMessageAtStart)
	S:HandleCheckBox(RIO_NotifyWhenTimerDone)
	S:HandleCheckBox(RIO_OnlyGuildMembers)
	S:HandleCheckBox(RIO_AlwaysInviteListen)
	S:HandleCheckBox(RIO_ShowMinimapIconConfig)
	S:HandleCheckBox(RIO_AutoSet25manBox)
	S:HandleCheckBox(RIO_AutoSetDifficultyBox)
	S:HandleCheckBox(RIO_AutoSetMasterLooter)

	RIO_MainFrameTab1:Point("TOPLEFT", RIO_MainFrame, "BOTTOMLEFT", -5, 2)
	RIO_MainFrameTab2:Point("LEFT", RIO_MainFrameTab1, "RIGHT", -2, 0)
	RIO_MainFrameTab3:Point("LEFT", RIO_MainFrameTab2, "RIGHT", -2, 0)
 
	for i = 1, 3 do
		S:HandleTab(_G["RIO_MainFrameTab"..i])
	end

	for i = 1, 10 do
		S:HandleCheckBox(_G["RIO_ShowRank"..i])
	end

end

AS:RegisterSkin(name,SkinRIO)