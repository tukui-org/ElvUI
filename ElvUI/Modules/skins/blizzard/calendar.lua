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

	local CalendarFrame = _G.CalendarFrame
	CalendarFrame:DisableDrawLayer("BORDER")
	CalendarFrame:CreateBackdrop("Transparent")
	S:HandleCloseButton(_G.CalendarCloseButton)
	_G.CalendarCloseButton:Point("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -4)

	for i = 1, 9 do
		select(i, _G.CalendarViewEventFrame:GetRegions()):Hide()
	end
	select(15, _G.CalendarViewEventFrame:GetRegions()):Hide()

	for i = 1, 9 do
		select(i, _G.CalendarViewHolidayFrame:GetRegions()):Hide()
		select(i, _G.CalendarViewRaidFrame:GetRegions()):Hide()
	end

	for i = 1, 3 do
		select(i, _G.CalendarCreateEventTitleFrame:GetRegions()):Hide()
		select(i, _G.CalendarViewEventTitleFrame:GetRegions()):Hide()
		select(i, _G.CalendarViewHolidayTitleFrame:GetRegions()):Hide()
		select(i, _G.CalendarViewRaidTitleFrame:GetRegions()):Hide()
		select(i, _G.CalendarMassInviteTitleFrame:GetRegions()):Hide()
	end

	for i = 1, 7 do
		_G["CalendarWeekday"..i.."Background"]:SetAlpha(0)
	end

	_G.CalendarViewEventDivider:Hide()
	_G.CalendarCreateEventDivider:Hide()
	_G.CalendarViewEventInviteList:GetRegions():Hide()
	_G.CalendarViewEventDescriptionContainer:GetRegions():Hide()
	select(5, _G.CalendarCreateEventCloseButton:GetRegions()):Hide()
	select(5, _G.CalendarViewEventCloseButton:GetRegions()):Hide()
	select(5, _G.CalendarViewHolidayCloseButton:GetRegions()):Hide()
	select(5, _G.CalendarViewRaidCloseButton:GetRegions()):Hide()
	select(5, _G.CalendarMassInviteCloseButton:GetRegions()):Hide()
	_G.CalendarCreateEventBackground:Hide()
	_G.CalendarCreateEventFrameButtonBackground:Hide()
	_G.CalendarCreateEventMassInviteButtonBorder:Hide()
	_G.CalendarCreateEventCreateButtonBorder:Hide()
	_G.CalendarEventPickerTitleFrameBackgroundLeft:Hide()
	_G.CalendarEventPickerTitleFrameBackgroundMiddle:Hide()
	_G.CalendarEventPickerTitleFrameBackgroundRight:Hide()
	_G.CalendarEventPickerFrameButtonBackground:Hide()
	_G.CalendarEventPickerCloseButtonBorder:Hide()
	_G.CalendarCreateEventRaidInviteButtonBorder:Hide()
	_G.CalendarMonthBackground:SetAlpha(0)
	_G.CalendarYearBackground:SetAlpha(0)
	_G.CalendarFrameModalOverlay:SetAlpha(.25)
	_G.CalendarViewHolidayInfoTexture:SetAlpha(0)
	_G.CalendarTexturePickerTitleFrameBackgroundLeft:Hide()
	_G.CalendarTexturePickerTitleFrameBackgroundMiddle:Hide()
	_G.CalendarTexturePickerTitleFrameBackgroundRight:Hide()
	_G.CalendarTexturePickerFrameButtonBackground:Hide()
	_G.CalendarTexturePickerAcceptButtonBorder:Hide()
	_G.CalendarTexturePickerCancelButtonBorder:Hide()
	_G.CalendarClassTotalsButtonBackgroundTop:Hide()
	_G.CalendarClassTotalsButtonBackgroundMiddle:Hide()
	_G.CalendarClassTotalsButtonBackgroundBottom:Hide()
	_G.CalendarFilterFrameLeft:Hide()
	_G.CalendarFilterFrameMiddle:Hide()
	_G.CalendarFilterFrameRight:Hide()

	S:HandleNextPrevButton(_G.CalendarPrevMonthButton)
	S:HandleNextPrevButton(_G.CalendarNextMonthButton)

	_G.CalendarFilterFrame:StripTextures()
	_G.CalendarFilterFrame:Width(155)

	_G.CalendarFilterFrameText:ClearAllPoints()
	_G.CalendarFilterFrameText:Point("RIGHT", _G.CalendarFilterButton, "LEFT", -2, 0)

	_G.CalendarFilterButton:ClearAllPoints()
	_G.CalendarFilterButton:Point("RIGHT", _G.CalendarFilterFrame, "RIGHT", -10, 3)
	_G.CalendarFilterButton.SetPoint = E.noop

	S:HandleNextPrevButton(_G.CalendarFilterButton, true)

	_G.CalendarFilterFrame:CreateBackdrop("Default")
	_G.CalendarFilterFrame.backdrop:Point("TOPLEFT", 20, 2)
	_G.CalendarFilterFrame.backdrop:Point("BOTTOMRIGHT", _G.CalendarFilterButton, "BOTTOMRIGHT", 2, -2)

	_G.CalendarContextMenu:SetTemplate("Default")
	_G.CalendarContextMenu.SetBackdropColor = E.noop
	_G.CalendarContextMenu.SetBackdropBorderColor = E.noop

	_G.CalendarInviteStatusContextMenu:SetTemplate("Default")
	_G.CalendarInviteStatusContextMenu.SetBackdropColor = E.noop
	_G.CalendarInviteStatusContextMenu.SetBackdropBorderColor = E.noop

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

	_G.CalendarWeekdaySelectedTexture:SetDesaturated(true)
	_G.CalendarWeekdaySelectedTexture:SetVertexColor(1, 1, 1, 0.6)

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

	_G.CalendarTodayFrame:SetSize(_G.CalendarDayButton1:GetWidth(), _G.CalendarDayButton1:GetHeight())
	_G.CalendarTodayFrame:SetBackdropBorderColor(0, 0.44, .87, 1)
	_G.CalendarTodayFrame:SetBackdropColor(0, 0, 0, 0)
	_G.CalendarTodayFrame:HookScript("OnUpdate", function(self) self:SetAlpha(_G.CalendarTodayTextureGlow:GetAlpha()) end)
	_G.CalendarTodayTexture:Hide()

	--CreateEventFrame
	_G.CalendarCreateEventFrame:StripTextures()
	_G.CalendarCreateEventFrame:CreateBackdrop("Transparent")
	_G.CalendarCreateEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	_G.CalendarCreateEventTitleFrame:StripTextures()

	S:HandleButton(_G.CalendarCreateEventCreateButton, true)
	S:HandleButton(_G.CalendarCreateEventMassInviteButton, true)
	S:HandleButton(_G.CalendarCreateEventInviteButton, true)
	_G.CalendarCreateEventInviteButton:Point("TOPLEFT", _G.CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
	_G.CalendarCreateEventInviteEdit:Width(_G.CalendarCreateEventInviteEdit:GetWidth() - 2)

	_G.CalendarCreateEventInviteList:StripTextures()
	_G.CalendarCreateEventInviteList:CreateBackdrop("Default")

	S:HandleEditBox(_G.CalendarCreateEventInviteEdit)
	S:HandleEditBox(_G.CalendarCreateEventTitleEdit)
	S:HandleDropDownBox(_G.CalendarCreateEventTypeDropDown, 120)
	S:HandleDropDownBox(_G.CalendarCreateEventCommunityDropDown, 240)

	_G.CalendarCreateEventDescriptionContainer:StripTextures()
	_G.CalendarCreateEventDescriptionContainer:SetTemplate("Default")

	S:HandleCloseButton(_G.CalendarCreateEventCloseButton)

	S:HandleCheckBox(_G.CalendarCreateEventLockEventCheck)

	S:HandleDropDownBox(_G.CalendarCreateEventHourDropDown, 68)
	S:HandleDropDownBox(_G.CalendarCreateEventMinuteDropDown, 68)
	S:HandleDropDownBox(_G.CalendarCreateEventAMPMDropDown, 68)
	S:HandleDropDownBox(_G.CalendarCreateEventDifficultyOptionDropDown)
	--S:HandleDropDownBox(CalendarCreateEventRepeatOptionDropDown, 120)
	_G.CalendarCreateEventIcon:SetTexCoord(unpack(E.TexCoords))
	_G.CalendarCreateEventIcon.SetTexCoord = E.noop

	_G.CalendarCreateEventInviteListSection:StripTextures()

	_G.CalendarClassButtonContainer:HookScript("OnShow", function()
		for i, class in ipairs(CLASS_SORT_ORDER) do
			local button = _G["CalendarClassButton"..i]
			local tcoords = CLASS_ICON_TCOORDS[class]
			local buttonIcon = button:GetNormalTexture()
			buttonIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			buttonIcon:SetTexCoord(tcoords[1] + 0.015, tcoords[2] - 0.02, tcoords[3] + 0.018, tcoords[4] - 0.02) --F U C K I N G H A X
		end
	end)

	_G.CalendarClassButton1:Point("TOPLEFT", _G.CalendarClassButtonContainer, "TOPLEFT", 5, 0)

	for i = 1, #CLASS_SORT_ORDER do
		local button = _G["CalendarClassButton"..i]
		button:StripTextures()
		button:CreateBackdrop("Default")
		button:Size(24)
	end

	_G.CalendarClassTotalsButton:StripTextures()
	_G.CalendarClassTotalsButton:CreateBackdrop("Default")
	_G.CalendarClassTotalsButton:Width(24)

	--Texture Picker Frame
	_G.CalendarTexturePickerFrame:StripTextures()
	_G.CalendarTexturePickerTitleFrame:StripTextures()
	_G.CalendarTexturePickerFrame:SetTemplate("Transparent")

	S:HandleScrollBar(_G.CalendarTexturePickerScrollBar)
	S:HandleButton(_G.CalendarTexturePickerAcceptButton, true)
	S:HandleButton(_G.CalendarTexturePickerCancelButton, true)
	S:HandleButton(_G.CalendarCreateEventInviteButton, true)
	S:HandleButton(_G.CalendarCreateEventRaidInviteButton, true)

	--Mass Invite Frame
	_G.CalendarMassInviteFrame:StripTextures()
	_G.CalendarMassInviteFrame:SetTemplate("Transparent")
	_G.CalendarMassInviteTitleFrame:StripTextures()

	S:HandleCloseButton(_G.CalendarMassInviteCloseButton)

	--Raid View
	_G.CalendarViewRaidFrame:StripTextures()
	_G.CalendarViewRaidFrame:CreateBackdrop("Transparent")
	_G.CalendarViewRaidFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	_G.CalendarViewRaidTitleFrame:StripTextures()
	S:HandleCloseButton(_G.CalendarViewRaidCloseButton)

	--Holiday View
	_G.CalendarViewHolidayFrame:StripTextures(true)
	_G.CalendarViewHolidayFrame:CreateBackdrop("Transparent")
	_G.CalendarViewHolidayFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	_G.CalendarViewHolidayTitleFrame:StripTextures()
	S:HandleCloseButton(_G.CalendarViewHolidayCloseButton)

	-- Event View
	_G.CalendarViewEventFrame:StripTextures()
	_G.CalendarViewEventFrame:CreateBackdrop("Transparent")
	_G.CalendarViewEventFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	_G.CalendarViewEventTitleFrame:StripTextures()
	_G.CalendarViewEventDescriptionContainer:StripTextures()
	_G.CalendarViewEventDescriptionContainer:SetTemplate("Transparent")
	_G.CalendarViewEventInviteList:StripTextures()
	_G.CalendarViewEventInviteList:SetTemplate("Transparent")
	_G.CalendarViewEventInviteListSection:StripTextures()
	S:HandleCloseButton(_G.CalendarViewEventCloseButton)
	S:HandleScrollBar(_G.CalendarViewEventInviteListScrollFrameScrollBar)

	S:HandleButton(_G.CalendarViewEventAcceptButton)
	S:HandleButton(_G.CalendarViewEventTentativeButton)
	S:HandleButton(_G.CalendarViewEventRemoveButton)
	S:HandleButton(_G.CalendarViewEventDeclineButton)

	--Event Picker Frame
	_G.CalendarEventPickerFrame:StripTextures()
	_G.CalendarEventPickerTitleFrame:StripTextures()
	_G.CalendarEventPickerFrame:SetTemplate("Transparent")

	S:HandleScrollBar(_G.CalendarEventPickerScrollBar)
	S:HandleButton(_G.CalendarEventPickerCloseButton, true)

	S:HandleScrollBar(_G.CalendarCreateEventDescriptionScrollFrameScrollBar)
	S:HandleScrollBar(_G.CalendarCreateEventInviteListScrollFrameScrollBar)
	S:HandleScrollBar(_G.CalendarViewEventDescriptionScrollFrameScrollBar)
end

S:AddCallbackForAddon("Blizzard_Calendar", "Calendar", LoadSkin)
