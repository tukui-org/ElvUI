local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.calendar ~= true then return end

	CalendarFrame:StripTextures()
	CalendarFrame:SetTemplate("Transparent")
	S:HandleCloseButton(CalendarCloseButton)
	CalendarCloseButton:Point("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -4)

	S:HandleNextPrevButton(CalendarPrevMonthButton)
	S:HandleNextPrevButton(CalendarNextMonthButton)

	CalendarFilterFrame:StripTextures()
	CalendarFilterFrame:Width(155)
	
	CalendarFilterFrameText:ClearAllPoints()
	CalendarFilterFrameText:Point("RIGHT", CalendarFilterButton, "LEFT", -2, 0)

	CalendarFilterButton:ClearAllPoints()
	CalendarFilterButton:Point("RIGHT", CalendarFilterFrame, "RIGHT", -10, 3)
	CalendarFilterButton.SetPoint = E.noop

	S:HandleNextPrevButton(CalendarFilterButton, true)

	CalendarFilterFrame:CreateBackdrop("Default")
	CalendarFilterFrame.backdrop:Point("TOPLEFT", 20, 2)
	CalendarFilterFrame.backdrop:Point("BOTTOMRIGHT", CalendarFilterButton, "BOTTOMRIGHT", 2, -2)

	CalendarContextMenu:SetTemplate("Default")
	CalendarContextMenu.SetBackdropColor = E.noop
	CalendarContextMenu.SetBackdropBorderColor = E.noop

	CalendarInviteStatusContextMenu:SetTemplate("Default")
	CalendarInviteStatusContextMenu.SetBackdropColor = E.noop
	CalendarInviteStatusContextMenu.SetBackdropBorderColor = E.noop

	--Boost frame levels
	for i=1, 42 do
		_G["CalendarDayButton"..i]:SetFrameLevel(_G["CalendarDayButton"..i]:GetFrameLevel() + 1)
	end

	--CreateEventFrame
	CalendarCreateEventFrame:StripTextures()
	CalendarCreateEventFrame:SetTemplate("Transparent")
	CalendarCreateEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarCreateEventTitleFrame:StripTextures()

	S:HandleButton(CalendarCreateEventCreateButton, true)
	S:HandleButton(CalendarCreateEventMassInviteButton, true)
	S:HandleButton(CalendarCreateEventInviteButton, true)
	CalendarCreateEventInviteButton:Point("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
	CalendarCreateEventInviteEdit:Width(CalendarCreateEventInviteEdit:GetWidth() - 2)

	CalendarCreateEventInviteList:StripTextures()
	CalendarCreateEventInviteList:SetTemplate("Default")

	S:HandleEditBox(CalendarCreateEventInviteEdit)
	S:HandleEditBox(CalendarCreateEventTitleEdit)
	S:HandleDropDownBox(CalendarCreateEventTypeDropDown, 120)

	CalendarCreateEventDescriptionContainer:StripTextures()
	CalendarCreateEventDescriptionContainer:SetTemplate("Default")

	S:HandleCloseButton(CalendarCreateEventCloseButton)

	S:HandleCheckBox(CalendarCreateEventLockEventCheck)

	S:HandleDropDownBox(CalendarCreateEventHourDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventMinuteDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventAMPMDropDown, 68)
	S:HandleDropDownBox(CalendarCreateEventDifficultyOptionDropDown)
	--S:HandleDropDownBox(CalendarCreateEventRepeatOptionDropDown, 120)
	CalendarCreateEventIcon:SetTexCoord(unpack(E.TexCoords))
	CalendarCreateEventIcon.SetTexCoord = E.noop

	CalendarCreateEventInviteListSection:StripTextures()

	CalendarClassButtonContainer:HookScript("OnShow", function()
		for i, class in ipairs(CLASS_SORT_ORDER) do
			local button = _G["CalendarClassButton"..i]
			local tcoords = CLASS_ICON_TCOORDS[class]
			local buttonIcon = button:GetNormalTexture()
			buttonIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			buttonIcon:SetTexCoord(tcoords[1] + 0.015, tcoords[2] - 0.02, tcoords[3] + 0.018, tcoords[4] - 0.02) --F U C K I N G H A X
		end
	end)
	
	CalendarClassButton1:Point("TOPLEFT", CalendarClassButtonContainer, "TOPLEFT", 5, 0)

	for i = 1, #CLASS_SORT_ORDER do
		local button = _G["CalendarClassButton"..i]
		button:StripTextures()
		button:CreateBackdrop("Default")
		button:Size(24)
	end
	
	CalendarClassTotalsButton:StripTextures()
	CalendarClassTotalsButton:CreateBackdrop("Default")
	CalendarClassTotalsButton:Width(24)

	--Texture Picker Frame
	CalendarTexturePickerFrame:StripTextures()
	CalendarTexturePickerTitleFrame:StripTextures()
	CalendarTexturePickerFrame:SetTemplate("Transparent")

	S:HandleScrollBar(CalendarTexturePickerScrollBar)
	S:HandleButton(CalendarTexturePickerAcceptButton, true)
	S:HandleButton(CalendarTexturePickerCancelButton, true)
	S:HandleButton(CalendarCreateEventInviteButton, true)
	S:HandleButton(CalendarCreateEventRaidInviteButton, true)

	--Mass Invite Frame
	CalendarMassInviteFrame:StripTextures()
	CalendarMassInviteFrame:SetTemplate("Transparent")
	CalendarMassInviteTitleFrame:StripTextures()

	S:HandleCloseButton(CalendarMassInviteCloseButton)
	S:HandleButton(CalendarMassInviteGuildAcceptButton)
	S:HandleDropDownBox(CalendarMassInviteGuildRankMenu, 130)

	S:HandleEditBox(CalendarMassInviteGuildMinLevelEdit)
	S:HandleEditBox(CalendarMassInviteGuildMaxLevelEdit)

	--Raid View
	CalendarViewRaidFrame:StripTextures()
	CalendarViewRaidFrame:SetTemplate("Transparent")
	CalendarViewRaidFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewRaidTitleFrame:StripTextures()
	S:HandleCloseButton(CalendarViewRaidCloseButton)

	--Holiday View
	CalendarViewHolidayFrame:StripTextures(true)
	CalendarViewHolidayFrame:SetTemplate("Transparent")
	CalendarViewHolidayFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewHolidayTitleFrame:StripTextures()
	S:HandleCloseButton(CalendarViewHolidayCloseButton)

	-- Event View
	CalendarViewEventFrame:StripTextures()
	CalendarViewEventFrame:SetTemplate("Transparent")
	CalendarViewEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewEventTitleFrame:StripTextures()
	CalendarViewEventDescriptionContainer:StripTextures()
	CalendarViewEventDescriptionContainer:SetTemplate("Transparent")
	CalendarViewEventInviteList:StripTextures()
	CalendarViewEventInviteList:SetTemplate("Transparent")
	CalendarViewEventInviteListSection:StripTextures()
	S:HandleCloseButton(CalendarViewEventCloseButton)
	S:HandleScrollBar(CalendarViewEventInviteListScrollFrameScrollBar)

	S:HandleButton(CalendarViewEventAcceptButton)
	S:HandleButton(CalendarViewEventTentativeButton)
	S:HandleButton(CalendarViewEventRemoveButton)
	S:HandleButton(CalendarViewEventDeclineButton)

	--Event Picker Frame
	CalendarEventPickerFrame:StripTextures()
	CalendarEventPickerTitleFrame:StripTextures()
	CalendarEventPickerFrame:SetTemplate("Transparent")

	S:HandleScrollBar(CalendarEventPickerScrollBar)
	S:HandleButton(CalendarEventPickerCloseButton, true)

	S:HandleScrollBar(CalendarCreateEventDescriptionScrollFrameScrollBar)
	S:HandleScrollBar(CalendarCreateEventInviteListScrollFrameScrollBar)
	S:HandleScrollBar(CalendarViewEventDescriptionScrollFrameScrollBar)
end

S:RegisterSkin("Blizzard_Calendar", LoadSkin)