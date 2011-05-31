local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].calendar ~= true then return end

local function LoadSkin()
	local frames = {
		"CalendarFrame",
	}
	
	for _, frame in pairs(frames) do
		_G[frame]:StripTextures()
	end
	
	CalendarFrame:SetTemplate("Transparent")
	E.SkinCloseButton(CalendarCloseButton)
	CalendarCloseButton:Point("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -4)
	
	E.SkinNextPrevButton(CalendarPrevMonthButton)
	E.SkinNextPrevButton(CalendarNextMonthButton)
	
	do --Handle drop down button, this one is differant than the others
		local frame = CalendarFilterFrame
		local button = CalendarFilterButton

		frame:StripTextures()
		frame:Width(155)
		
		_G[frame:GetName().."Text"]:ClearAllPoints()
		_G[frame:GetName().."Text"]:Point("RIGHT", button, "LEFT", -2, 0)

		
		button:ClearAllPoints()
		button:Point("RIGHT", frame, "RIGHT", -10, 3)
		button.SetPoint = E.dummy
		
		E.SkinNextPrevButton(button, true)
		
		frame:CreateBackdrop("Default")
		frame.backdrop:Point("TOPLEFT", 20, 2)
		frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	end
	
	
	--backdrop
	local bg = CreateFrame("Frame", "CalendarFrameBackdrop", CalendarFrame)
	bg:SetTemplate("Default")
	bg:Point("TOPLEFT", 10, -72)
	bg:Point("BOTTOMRIGHT", -8, 3)
	
	CalendarContextMenu:SetTemplate("Default")
	CalendarContextMenu.SetBackdropColor = E.dummy
	CalendarContextMenu.SetBackdropBorderColor = E.dummy
	
	--Boost frame levels
	for i=1, 42 do
		_G["CalendarDayButton"..i]:SetFrameLevel(_G["CalendarDayButton"..i]:GetFrameLevel() + 1)
	end
	
	--CreateEventFrame
	CalendarCreateEventFrame:StripTextures()
	CalendarCreateEventFrame:SetTemplate("Transparent")
	CalendarCreateEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarCreateEventTitleFrame:StripTextures()
	
	E.SkinButton(CalendarCreateEventCreateButton, true)
	E.SkinButton(CalendarCreateEventMassInviteButton, true)
	E.SkinButton(CalendarCreateEventInviteButton, true)
	CalendarCreateEventInviteButton:Point("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
	CalendarCreateEventInviteEdit:Width(CalendarCreateEventInviteEdit:GetWidth() - 2)
	
	CalendarCreateEventInviteList:StripTextures()
	CalendarCreateEventInviteList:SetTemplate("Default")
	
	E.SkinEditBox(CalendarCreateEventInviteEdit)
	E.SkinEditBox(CalendarCreateEventTitleEdit)
	E.SkinDropDownBox(CalendarCreateEventTypeDropDown, 120)
	
	CalendarCreateEventDescriptionContainer:StripTextures()
	CalendarCreateEventDescriptionContainer:SetTemplate("Default")
	
	E.SkinCloseButton(CalendarCreateEventCloseButton)
	
	E.SkinCheckBox(CalendarCreateEventLockEventCheck)
	
	E.SkinDropDownBox(CalendarCreateEventHourDropDown, 68)
	E.SkinDropDownBox(CalendarCreateEventMinuteDropDown, 68)
	E.SkinDropDownBox(CalendarCreateEventAMPMDropDown, 68)
	E.SkinDropDownBox(CalendarCreateEventRepeatOptionDropDown, 120)
	CalendarCreateEventIcon:SetTexCoord(.08, .92, .08, .92)
	CalendarCreateEventIcon.SetTexCoord = E.dummy
	
	CalendarCreateEventInviteListSection:StripTextures()
	
	CalendarClassButtonContainer:HookScript("OnShow", function()
		for i, class in ipairs(CLASS_SORT_ORDER) do
			local button = _G["CalendarClassButton"..i]
			button:StripTextures()
			button:CreateBackdrop("Default")
			
			local tcoords = CLASS_ICON_TCOORDS[class]
			local buttonIcon = button:GetNormalTexture()
			buttonIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			buttonIcon:SetTexCoord(tcoords[1] + 0.015, tcoords[2] - 0.02, tcoords[3] + 0.018, tcoords[4] - 0.02) --F U C K I N G H A X
		end
		
		CalendarClassButton1:Point("TOPLEFT", CalendarClassButtonContainer, "TOPLEFT", 5, 0)
		
		CalendarClassTotalsButton:StripTextures()
		CalendarClassTotalsButton:CreateBackdrop("Default")
	end)
	
	--Texture Picker Frame
	CalendarTexturePickerFrame:StripTextures()
	CalendarTexturePickerTitleFrame:StripTextures()
	
	CalendarTexturePickerFrame:SetTemplate("Transparent")
	
	E.SkinScrollBar(CalendarTexturePickerScrollBar)
	E.SkinButton(CalendarTexturePickerAcceptButton, true)
	E.SkinButton(CalendarTexturePickerCancelButton, true)
	E.SkinButton(CalendarCreateEventInviteButton, true)
	E.SkinButton(CalendarCreateEventRaidInviteButton, true)
	
	--Mass Invite Frame
	CalendarMassInviteFrame:StripTextures()
	CalendarMassInviteFrame:SetTemplate("Transparent")
	CalendarMassInviteTitleFrame:StripTextures()
	
	E.SkinCloseButton(CalendarMassInviteCloseButton)
	E.SkinButton(CalendarMassInviteGuildAcceptButton)
	E.SkinButton(CalendarMassInviteArenaButton2)
	E.SkinButton(CalendarMassInviteArenaButton3)
	E.SkinButton(CalendarMassInviteArenaButton5)
	E.SkinDropDownBox(CalendarMassInviteGuildRankMenu, 130)
	
	E.SkinEditBox(CalendarMassInviteGuildMinLevelEdit)
	E.SkinEditBox(CalendarMassInviteGuildMaxLevelEdit)
	
	--Raid View
	CalendarViewRaidFrame:StripTextures()
	CalendarViewRaidFrame:SetTemplate("Transparent")
	CalendarViewRaidFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewRaidTitleFrame:StripTextures()
	E.SkinCloseButton(CalendarViewRaidCloseButton)
	
	--Holiday View
	CalendarViewHolidayFrame:StripTextures(true)
	CalendarViewHolidayFrame:SetTemplate("Transparent")
	CalendarViewHolidayFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewHolidayTitleFrame:StripTextures()
	E.SkinCloseButton(CalendarViewHolidayCloseButton)
	
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
	E.SkinCloseButton(CalendarViewEventCloseButton)
	E.SkinScrollBar(CalendarViewEventInviteListScrollFrameScrollBar)
	
	local buttons = {
		"CalendarViewEventAcceptButton",
		"CalendarViewEventTentativeButton",
		"CalendarViewEventRemoveButton",
		"CalendarViewEventDeclineButton",
	}

	for _, button in pairs(buttons) do
		E.SkinButton(_G[button])
	end	
end

E.SkinFuncs["Blizzard_Calendar"] = LoadSkin