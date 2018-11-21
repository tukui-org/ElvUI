local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local ipairs, select, unpack = ipairs, select, unpack
--WoW API / Variables
local CLASS_SORT_ORDER = CLASS_SORT_ORDER
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local CreateFrame = CreateFrame

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.calendar ~= true then return end

	local CalendarFrame = _G["CalendarFrame"]
	CalendarFrame:DisableDrawLayer("BORDER")
	CalendarFrame:CreateBackdrop("Transparent")
	S:HandleCloseButton(CalendarCloseButton)
	CalendarCloseButton:Point("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -4)

	for i = 1, 9 do
		select(i, _G["CalendarViewEventFrame"]:GetRegions()):Hide()
	end
	select(15, _G["CalendarViewEventFrame"]:GetRegions()):Hide()

	for i = 1, 9 do
		select(i, _G["CalendarViewHolidayFrame"]:GetRegions()):Hide()
		select(i, _G["CalendarViewRaidFrame"]:GetRegions()):Hide()
	end

	for i = 1, 3 do
		select(i, _G["CalendarCreateEventTitleFrame"]:GetRegions()):Hide()
		select(i, _G["CalendarViewEventTitleFrame"]:GetRegions()):Hide()
		select(i, _G["CalendarViewHolidayTitleFrame"]:GetRegions()):Hide()
		select(i, _G["CalendarViewRaidTitleFrame"]:GetRegions()):Hide()
		select(i, _G["CalendarMassInviteTitleFrame"]:GetRegions()):Hide()
	end

	for i = 1, 7 do
		_G["CalendarWeekday"..i.."Background"]:SetAlpha(0)
	end

	_G["CalendarViewEventDivider"]:Hide()
	_G["CalendarCreateEventDivider"]:Hide()
	_G["CalendarViewEventInviteList"]:GetRegions():Hide()
	_G["CalendarViewEventDescriptionContainer"]:GetRegions():Hide()
	select(5, _G["CalendarCreateEventCloseButton"]:GetRegions()):Hide()
	select(5, _G["CalendarViewEventCloseButton"]:GetRegions()):Hide()
	select(5, _G["CalendarViewHolidayCloseButton"]:GetRegions()):Hide()
	select(5, _G["CalendarViewRaidCloseButton"]:GetRegions()):Hide()
	select(5, _G["CalendarMassInviteCloseButton"]:GetRegions()):Hide()
	_G["CalendarCreateEventBackground"]:Hide()
	_G["CalendarCreateEventFrameButtonBackground"]:Hide()
	_G["CalendarCreateEventMassInviteButtonBorder"]:Hide()
	_G["CalendarCreateEventCreateButtonBorder"]:Hide()
	_G["CalendarEventPickerTitleFrameBackgroundLeft"]:Hide()
	_G["CalendarEventPickerTitleFrameBackgroundMiddle"]:Hide()
	_G["CalendarEventPickerTitleFrameBackgroundRight"]:Hide()
	_G["CalendarEventPickerFrameButtonBackground"]:Hide()
	_G["CalendarEventPickerCloseButtonBorder"]:Hide()
	_G["CalendarCreateEventRaidInviteButtonBorder"]:Hide()
	_G["CalendarMonthBackground"]:SetAlpha(0)
	_G["CalendarYearBackground"]:SetAlpha(0)
	_G["CalendarFrameModalOverlay"]:SetAlpha(.25)
	_G["CalendarViewHolidayInfoTexture"]:SetAlpha(0)
	_G["CalendarTexturePickerTitleFrameBackgroundLeft"]:Hide()
	_G["CalendarTexturePickerTitleFrameBackgroundMiddle"]:Hide()
	_G["CalendarTexturePickerTitleFrameBackgroundRight"]:Hide()
	_G["CalendarTexturePickerFrameButtonBackground"]:Hide()
	_G["CalendarTexturePickerAcceptButtonBorder"]:Hide()
	_G["CalendarTexturePickerCancelButtonBorder"]:Hide()
	_G["CalendarClassTotalsButtonBackgroundTop"]:Hide()
	_G["CalendarClassTotalsButtonBackgroundMiddle"]:Hide()
	_G["CalendarClassTotalsButtonBackgroundBottom"]:Hide()
	_G["CalendarFilterFrameLeft"]:Hide()
	_G["CalendarFilterFrameMiddle"]:Hide()
	_G["CalendarFilterFrameRight"]:Hide()

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
	for i = 1, 42 do
		_G["CalendarDayButton"..i.."DarkFrame"]:SetAlpha(.5)
		_G["CalendarDayButton"..i]:SetFrameLevel(_G["CalendarDayButton"..i]:GetFrameLevel() + 1)
		local bu = _G["CalendarDayButton"..i]

		if E.private.skins.parchmentRemover.enable then
			bu:DisableDrawLayer("BACKGROUND") -- This would remove the "Parchement"
		end

		bu:SetHighlightTexture(E.media.glossTex)
		local hl = bu:GetHighlightTexture()
		hl:SetVertexColor(1, 1, 1, 0.3)
		hl.SetAlpha = E.noop
		hl:SetPoint("TOPLEFT", -1, 1)
		hl:SetPoint("BOTTOMRIGHT")
	end

	_G["CalendarWeekdaySelectedTexture"]:SetDesaturated(true)
	_G["CalendarWeekdaySelectedTexture"]:SetVertexColor(1, 1, 1, 0.6)

	for i = 1, 6 do
		local vline = CreateFrame("Frame", nil, _G["CalendarDayButton"..i])
		vline:SetHeight(548)
		vline:SetWidth(1)
		vline:SetPoint("TOP", _G["CalendarDayButton"..i], "TOPRIGHT")
		vline:CreateBackdrop("Default")
	end

	for i = 1, 36, 7 do
		local hline = CreateFrame("Frame", nil, _G["CalendarDayButton"..i])
		hline:SetWidth(637)
		hline:SetHeight(1)
		hline:SetPoint("LEFT", _G["CalendarDayButton"..i], "TOPLEFT")
		hline:CreateBackdrop("Default")
	end

	_G["CalendarTodayFrame"]:SetSize(CalendarDayButton1:GetWidth(), CalendarDayButton1:GetHeight())
	_G["CalendarTodayFrame"]:SetBackdropBorderColor(0, 0.44, .87, 1)
	_G["CalendarTodayFrame"]:SetBackdropColor(0, 0, 0, 0)
	_G["CalendarTodayFrame"]:HookScript("OnUpdate", function(self) self:SetAlpha(CalendarTodayTextureGlow:GetAlpha()) end)
	_G["CalendarTodayTexture"]:Hide()

	--CreateEventFrame
	CalendarCreateEventFrame:StripTextures()
	CalendarCreateEventFrame:CreateBackdrop("Transparent")
	CalendarCreateEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarCreateEventTitleFrame:StripTextures()

	S:HandleButton(CalendarCreateEventCreateButton, true)
	S:HandleButton(CalendarCreateEventMassInviteButton, true)
	S:HandleButton(CalendarCreateEventInviteButton, true)
	CalendarCreateEventInviteButton:Point("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
	CalendarCreateEventInviteEdit:Width(CalendarCreateEventInviteEdit:GetWidth() - 2)

	CalendarCreateEventInviteList:StripTextures()
	CalendarCreateEventInviteList:CreateBackdrop("Default")

	S:HandleEditBox(CalendarCreateEventInviteEdit)
	S:HandleEditBox(CalendarCreateEventTitleEdit)
	S:HandleDropDownBox(CalendarCreateEventTypeDropDown, 120)
	S:HandleDropDownBox(CalendarCreateEventCommunityDropDown, 240)

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

	--Raid View
	CalendarViewRaidFrame:StripTextures()
	CalendarViewRaidFrame:CreateBackdrop("Transparent")
	CalendarViewRaidFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewRaidTitleFrame:StripTextures()
	S:HandleCloseButton(CalendarViewRaidCloseButton)

	--Holiday View
	CalendarViewHolidayFrame:StripTextures(true)
	CalendarViewHolidayFrame:CreateBackdrop("Transparent")
	CalendarViewHolidayFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarViewHolidayTitleFrame:StripTextures()
	S:HandleCloseButton(CalendarViewHolidayCloseButton)

	-- Event View
	CalendarViewEventFrame:StripTextures()
	CalendarViewEventFrame:CreateBackdrop("Transparent")
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

S:AddCallbackForAddon("Blizzard_Calendar", "Calendar", LoadSkin)
