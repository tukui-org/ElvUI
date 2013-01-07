local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "SoundtrackSkin"
local function SkinSoundtrack(self)
	local frames = {
		"SoundtrackFrame",
		"SoundtrackFrameEventList",
		"SoundtrackFrameTrackList",
		"SoundtrackFrame_AssignedFrame",
	}

	local buttons = {
		"SoundtrackFrame_CloseButton",
		"SoundtrackFrameCopyCopiedTracksButton",
		"SoundtrackFramePasteCopiedTracksButton",
		"SoundtrackFrameClearCopiedTracksButton",
		"SoundtrackFrameMoveUp",
		"SoundtrackFrameMoveDown",
		"SoundtrackFrameClearButton",
		"SoundtrackFrameAllButton",
		"SoundtrackFrameDeleteTargetButton",
		"SoundtrackFrameAddBossTargetButton",
		"SoundtrackFrameAddWorldBossTargetButton",
		"SoundtrackFrameRemoveZoneButton",
		"SoundtrackFrameAddZoneButton",
		"SoundtrackFrameDeletePetBattlesTargetButton",
		"SoundtrackFrameAddPetBattlesTargetButton",
		"SoundtrackFrameDeleteCustomEventButton",
		"SoundtrackFrameAddCustomEventButton",
		"SoundtrackFrameEditCustomEventButton",
		"SoundtrackFrameDeletePlaylistButton",
		"SoundtrackFrameAddPlaylistButton",
		"SoundtrackFrame_LoadProject",
		"SoundtrackFrame_RemoveProject",
	}

	local cboxes = {
		"SoundtrackFrame_EnableMinimapButton",
		"SoundtrackFrame_ShowPlaybackControls",
		"SoundtrackFrame_LockPlaybackControls",
		"SoundtrackFrame_ShowTrackInformation",
		"SoundtrackFrame_LockNowPlayingFrame",
		"SoundtrackFrame_ShowDefaultMusic",
		"SoundtrackFrame_HidePlaybackButtons",
		"SoundtrackFrame_AutoAddZones",
		"SoundtrackFrame_AutoEscalateBattleMusic",
		"SoundtrackFrame_YourEnemyLevelOnly",
		"SoundtrackFrame_LoopMusic",
		"SoundtrackFrame_EnableMusic",
		"SoundtrackFrame_EnableZoneMusic",
		"SoundtrackFrame_EnableBattleMusic",
		"SoundtrackFrame_EnableMiscMusic",
		"SoundtrackFrame_EnableCustomMusic",
		"SoundtrackFrame_EnableDebugMode",
		"SoundtrackFrame_ShowEventStack",
		"SoundtrackFrameTrackButton1CheckBox",
		"SoundtrackFrameTrackButton2CheckBox",
		"SoundtrackFrameTrackButton3CheckBox",
		"SoundtrackFrameTrackButton4CheckBox",
		"SoundtrackFrameTrackButton5CheckBox",
		"SoundtrackFrameTrackButton6CheckBox",
		"SoundtrackFrameTrackButton7CheckBox",
		"SoundtrackFrameTrackButton8CheckBox",
		"SoundtrackFrameTrackButton9CheckBox",
		"SoundtrackFrameTrackButton10CheckBox",
		"SoundtrackFrameTrackButton11CheckBox",
		"SoundtrackFrameTrackButton12CheckBox",
		"SoundtrackFrameTrackButton13CheckBox",
		"SoundtrackFrameTrackButton14CheckBox",
		"SoundtrackFrameTrackButton15CheckBox",
		"SoundtrackAssignedTrackButton1CheckBox",
		"SoundtrackAssignedTrackButton2CheckBox",
		"SoundtrackAssignedTrackButton3CheckBox",
		"SoundtrackAssignedTrackButton4CheckBox",
		"SoundtrackAssignedTrackButton5CheckBox",
		"SoundtrackAssignedTrackButton6CheckBox",
	}

	for _, object in pairs(frames) do
		if _G[object] then
			AS:SkinFrame(_G[object])
		end
	end

	for _, object in pairs(buttons) do
		if _G[object] then
			S:HandleButton(_G[object])
		end
	end

	for _, object in pairs(cboxes) do
		if _G[object] then
			S:HandleCheckBox(_G[object])
		end
	end

	for i = 1, 10 do
		S:HandleTab(_G["SoundtrackFrameTab"..i])
	end

	SoundtrackFrameTab1:SetPoint("TOPLEFT", SoundtrackFrame, "BOTTOMLEFT", 10, 2)
	SoundtrackFrame_CloseButton:SetPoint("BOTTOMRIGHT", SoundtrackFrame, "BOTTOMRIGHT", -15, 5)

	S:HandleCloseButton(SoundtrackFrame_TopCloseButton)
	AS:SkinStatusBar(SoundtrackFrame_StatusBarTrack)
	SoundtrackFrame_StatusBarTrackBorder:Kill()
	AS:SkinStatusBar(SoundtrackFrame_StatusBarEvent)
	SoundtrackFrame_StatusBarEventBorder:Kill()
	SoundtrackFrame_TrackFilter:StripTextures()
	SoundtrackFrame_TrackFilter:SetHeight(18)
	S:HandleEditBox(SoundtrackFrame_TrackFilter)
	AS:SkinBackdropFrame(NowPlayingTextFrame)
	S:HandleScrollBar(SoundtrackFrameTrackScrollFrameScrollBar)
	S:HandleScrollBar(SoundtrackFrameAssignedTracksScrollFrameScrollBar)
	S:HandleScrollBar(SoundtrackFrameEventScrollFrameScrollBar)
	S:HandleDropDownBox(SoundtrackFrame_ColumnHeaderNameDropDown)
	S:HandleDropDownBox(SoundtrackFrame_PlaybackButtonsLocationDropDown)
	S:HandleDropDownBox(SoundtrackFrame_BattleCooldownDropDown)
	S:HandleDropDownBox(SoundtrackFrame_LowHealthPercentDropDown)
	S:HandleDropDownBox(SoundtrackFrame_SilenceDropDown)
	S:HandleDropDownBox(SoundtrackFrame_ProjectDropDown)

	SoundtrackTooltip:HookScript("OnShow", function(self) self:SetTemplate("Transparent") end)
	NowPlayingTextFrame:Show()
	NowPlayingTextFrame:Hide()
	NowPlayingTextFrame:Size(200, 40)

end

AS:RegisterSkin(name,SkinSoundtrack)