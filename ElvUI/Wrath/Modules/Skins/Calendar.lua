local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, select, unpack = next, select, unpack

local CLASS_SORT_ORDER = CLASS_SORT_ORDER
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local hooksecurefunc = hooksecurefunc

local function SkinContainer(frame, container)
	frame.NineSlice:Kill()

	local child = container or frame.scrollFrame
	if child and not child.backdrop then
		child:CreateBackdrop('Transparent')
	end
end

local function StripClassTextures(button)
	for y = 1, button:GetNumRegions() do
		local region = select(y, button:GetRegions())
		if region:GetObjectType() == 'Texture' then
			local texture = region:GetTexture()
			if texture == [[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]] then
				local c = CLASS_ICON_TCOORDS[button.class]
				region:SetTexCoord(c[1] + 0.02, c[2] - 0.02, c[3] + 0.02, c[4] - 0.02)
				region:SetInside()
			else
				region:SetTexture(nil)
			end
		end
	end
end

local function HandleEventIcon(icon)
	icon:Size(54)
	icon:ClearAllPoints()
	icon:Point('TOPLEFT', _G.CalendarViewEventFrame.HeaderFrame, 'TOPLEFT', 15, -20)
	icon:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, true)
	icon:SetTexCoord(unpack(E.TexCoords))
	icon.SetTexCoord = E.noop
end

function S:Blizzard_Calendar()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.calendar) then return end

	local CalendarFrame = _G.CalendarFrame
	CalendarFrame:DisableDrawLayer('BORDER')
	CalendarFrame:CreateBackdrop('Transparent')

	S:HandleCloseButton(_G.CalendarCloseButton)
	_G.CalendarCloseButton:Point('TOPRIGHT', CalendarFrame, 'TOPRIGHT', -4, -4)

	for i = 1, 7 do
		_G['CalendarWeekday'..i..'Background']:SetAlpha(0)
	end

	SkinContainer(_G.CalendarViewEventInviteList)
	SkinContainer(_G.CalendarCreateEventInviteList)
	SkinContainer(_G.CalendarViewEventDescriptionContainer, _G.CalendarViewEventDescriptionScrollFrame)
	SkinContainer(_G.CalendarCreateEventDescriptionContainer, _G.CalendarCreateEventDescriptionScrollFrame)

	_G.CalendarCreateEventFrameButtonBackground:Hide()
	_G.CalendarCreateEventMassInviteButtonBorder:Hide()
	_G.CalendarCreateEventCreateButtonBorder:Hide()
	_G.CalendarEventPickerFrameButtonBackground:Hide()
	_G.CalendarEventPickerCloseButtonBorder:Hide()
	_G.CalendarCreateEventRaidInviteButtonBorder:Hide()
	_G.CalendarMonthBackground:SetAlpha(0)
	_G.CalendarYearBackground:SetAlpha(0)
	_G.CalendarFrameModalOverlay:SetAlpha(.25)
	_G.CalendarViewHolidayInfoTexture:SetAlpha(0)
	_G.CalendarTexturePickerFrameButtonBackground:Hide()
	_G.CalendarTexturePickerAcceptButtonBorder:Hide()
	_G.CalendarTexturePickerCancelButtonBorder:Hide()
	_G.CalendarClassTotalsButtonBackgroundTop:Hide()
	_G.CalendarClassTotalsButtonBackgroundMiddle:Hide()
	_G.CalendarClassTotalsButtonBackgroundBottom:Hide()
	_G.CalendarFilterFrameLeft:Hide()
	_G.CalendarFilterFrameMiddle:Hide()
	_G.CalendarFilterFrameRight:Hide()
	_G.CalendarViewEventDivider:Hide()
	_G.CalendarCreateEventDivider:Hide()

	S:HandleNextPrevButton(_G.CalendarPrevMonthButton, nil, nil, true)
	S:HandleNextPrevButton(_G.CalendarNextMonthButton, nil, nil, true)

	_G.CalendarFilterFrame:StripTextures()
	_G.CalendarFilterFrame:Width(155)

	_G.CalendarFilterFrameText:ClearAllPoints()
	_G.CalendarFilterFrameText:Point('RIGHT', _G.CalendarFilterButton, 'LEFT', -2, 0)

	_G.CalendarFilterButton:ClearAllPoints()
	_G.CalendarFilterButton:Point('RIGHT', _G.CalendarFilterFrame, 'RIGHT', -10, 3)
	_G.CalendarFilterButton.SetPoint = E.noop

	S:HandleNextPrevButton(_G.CalendarFilterButton)

	_G.CalendarFilterFrame:CreateBackdrop()
	_G.CalendarFilterFrame.backdrop:Point('TOPLEFT', 20, 2)
	_G.CalendarFilterFrame.backdrop:Point('BOTTOMRIGHT', _G.CalendarFilterButton, 'BOTTOMRIGHT', 2, -2)

	_G.CalendarContextMenu.NineSlice:SetTemplate('Transparent')
	_G.CalendarInviteStatusContextMenu.NineSlice:SetTemplate('Transparent')

	--Boost frame levels
	for i = 1, 42 do
		_G['CalendarDayButton'..i..'DarkFrame']:SetAlpha(.5)
		local bu = _G['CalendarDayButton'..i]

		if E.private.skins.parchmentRemoverEnable then
			bu:DisableDrawLayer('BACKGROUND') -- This would remove the 'Parchement'
		end

		bu:SetTemplate(nil, nil, nil, true)
		bu:SetBackdropColor(0,0,0,0)
		bu:SetHighlightTexture(E.media.glossTex)
		bu:SetFrameLevel(bu:GetFrameLevel() + 1)

		local hl = bu:GetHighlightTexture()
		hl:SetVertexColor(1, 1, 1, 0.3)
		hl:Point('TOPLEFT', -1, 1)
		hl:Point('BOTTOMRIGHT')
		hl.SetAlpha = E.noop
	end

	_G.CalendarWeekdaySelectedTexture:SetDesaturated(true)
	_G.CalendarWeekdaySelectedTexture:SetVertexColor(1, 1, 1, 0.6)

	_G.CalendarTodayTexture:Hide()
	_G.CalendarTodayTextureGlow:Hide()

	_G.CalendarTodayFrame:SetTemplate()
	_G.CalendarTodayFrame:SetBackdropBorderColor(_G.NORMAL_FONT_COLOR:GetRGB())
	_G.CalendarTodayFrame:SetBackdropColor(0,0,0,0)
	_G.CalendarTodayFrame:SetScript('OnUpdate', nil)

	hooksecurefunc('CalendarFrame_SetToday', function()
		_G.CalendarTodayFrame:SetAllPoints()
	end)

	--CreateEventFrame
	_G.CalendarCreateEventFrame:StripTextures()
	_G.CalendarCreateEventFrame:SetTemplate('Transparent')
	_G.CalendarCreateEventFrame:Point('TOPLEFT', CalendarFrame, 'TOPRIGHT', 3, -24)
	_G.CalendarCreateEventFrame.Header:StripTextures()

	S:HandleButton(_G.CalendarCreateEventCreateButton, true)
	S:HandleButton(_G.CalendarCreateEventMassInviteButton, true)
	S:HandleButton(_G.CalendarCreateEventInviteButton, true)
	_G.CalendarCreateEventInviteButton:Point('TOPLEFT', _G.CalendarCreateEventInviteEdit, 'TOPRIGHT', 4, 1)
	_G.CalendarCreateEventInviteEdit:Width(_G.CalendarCreateEventInviteEdit:GetWidth() - 2)

	S:HandleEditBox(_G.CalendarCreateEventInviteEdit)
	S:HandleEditBox(_G.CalendarCreateEventTitleEdit)
	S:HandleDropDownBox(_G.CalendarCreateEventTypeDropDown, 120)
	S:HandleDropDownBox(_G.CalendarCreateEventCommunityDropDown, 240)

	S:HandleCloseButton(_G.CalendarCreateEventCloseButton)
	S:HandleCheckBox(_G.CalendarCreateEventLockEventCheck)

	S:HandleDropDownBox(_G.CalendarCreateEventHourDropDown, 75)
	S:HandleDropDownBox(_G.CalendarCreateEventMinuteDropDown, 75)
	S:HandleDropDownBox(_G.CalendarCreateEventAMPMDropDown, 75)
	S:HandleDropDownBox(_G.CalendarCreateEventDifficultyOptionDropDown)

	_G.CalendarViewEventTitle:ClearAllPoints()
	_G.CalendarViewEventTitle:Point('TOPLEFT', _G.CalendarViewEventIcon, 'TOPRIGHT', 5, 0)
	HandleEventIcon(_G.CalendarViewEventIcon)

	_G.CalendarCreateEventDateLabel:ClearAllPoints()
	_G.CalendarCreateEventDateLabel:Point('TOPLEFT', _G.CalendarCreateEventIcon, 'TOPRIGHT', 5, 0)
	HandleEventIcon(_G.CalendarCreateEventIcon)

	_G.CalendarClassButton1:Point('TOPLEFT', _G.CalendarClassButtonContainer, 'TOPLEFT', E.PixelMode and 3 or 5, 0)

	local lastClassButton
	for index in next, CLASS_SORT_ORDER do
		local button = _G['CalendarClassButton'..index]
		local count = _G['CalendarClassButton'..index..'Count']
		StripClassTextures(button)
		button:SetTemplate()
		button:Size(28)

		count:FontTemplate()
		count:ClearAllPoints()
		count:Point('BOTTOMRIGHT', 0, 1)

		if lastClassButton then
			button:ClearAllPoints()
			button:Point('TOPLEFT', lastClassButton, 'BOTTOMLEFT', 0, -8)
		end

		lastClassButton = button
	end

	_G.CalendarClassTotalsButton:StripTextures()
	_G.CalendarClassTotalsButton:SetTemplate()
	_G.CalendarClassTotalsButton:Size(28, 18)

	--Texture Picker Frame
	_G.CalendarTexturePickerFrame:StripTextures()
	_G.CalendarTexturePickerFrame.Header:StripTextures()
	_G.CalendarTexturePickerFrame:SetTemplate('Transparent')

	S:HandleScrollBar(_G.CalendarTexturePickerScrollBar)
	S:HandleButton(_G.CalendarTexturePickerAcceptButton, true)
	S:HandleButton(_G.CalendarTexturePickerCancelButton, true)
	S:HandleButton(_G.CalendarCreateEventInviteButton, true)
	S:HandleButton(_G.CalendarCreateEventRaidInviteButton, true)

	--Mass Invite Frame
	_G.CalendarMassInviteFrame:StripTextures()
	_G.CalendarMassInviteFrame:SetTemplate('Transparent')
	_G.CalendarMassInviteFrame.Header:StripTextures()
	S:HandleDropDownBox(_G.CalendarMassInviteCommunityDropDown, 200)
	S:HandleDropDownBox(_G.CalendarMassInviteRankMenu)
	S:HandleEditBox(_G.CalendarMassInviteMinLevelEdit)
	S:HandleEditBox(_G.CalendarMassInviteMaxLevelEdit)
	S:HandleCloseButton(_G.CalendarMassInviteCloseButton)

	--Raid View
	_G.CalendarViewRaidFrame:StripTextures()
	_G.CalendarViewRaidFrame:SetTemplate('Transparent')
	_G.CalendarViewRaidFrame:Point('TOPLEFT', CalendarFrame, 'TOPRIGHT', 3, -24)
	_G.CalendarViewRaidFrame.Header:StripTextures()
	S:HandleCloseButton(_G.CalendarViewRaidCloseButton)

	--Holiday View
	_G.CalendarViewHolidayFrame:StripTextures(true)
	_G.CalendarViewHolidayFrame:SetTemplate('Transparent')
	_G.CalendarViewHolidayFrame:Point('TOPLEFT', CalendarFrame, 'TOPRIGHT', 3, -24)
	_G.CalendarViewHolidayFrame.Header:StripTextures()
	_G.CalendarViewHolidayFrameModalOverlay:SetAlpha(0)
	S:HandleCloseButton(_G.CalendarViewHolidayCloseButton)

	-- Event View
	_G.CalendarViewEventFrame:StripTextures()
	_G.CalendarViewEventFrame:SetTemplate('Transparent')
	_G.CalendarViewEventFrame:Point('TOPLEFT', CalendarFrame, 'TOPRIGHT', 3, -24)
	_G.CalendarViewEventFrame.Header:StripTextures()
	_G.CalendarViewEventInviteListSection:StripTextures()

	S:HandleCloseButton(_G.CalendarViewEventCloseButton)
	S:HandleScrollBar(_G.CalendarViewEventInviteListScrollFrameScrollBar)
	S:HandleButton(_G.CalendarViewEventAcceptButton)
	S:HandleButton(_G.CalendarViewEventTentativeButton)
	S:HandleButton(_G.CalendarViewEventRemoveButton)
	S:HandleButton(_G.CalendarViewEventDeclineButton)

	--Event Picker Frame
	_G.CalendarEventPickerFrame:StripTextures()
	_G.CalendarEventPickerFrame.Header:StripTextures()
	_G.CalendarEventPickerFrame:SetTemplate('Transparent')

	S:HandleScrollBar(_G.CalendarEventPickerScrollBar)
	S:HandleButton(_G.CalendarEventPickerCloseButton, true)

	S:HandleScrollBar(_G.CalendarCreateEventDescriptionScrollFrameScrollBar)
	S:HandleScrollBar(_G.CalendarCreateEventInviteListScrollFrameScrollBar)
	S:HandleScrollBar(_G.CalendarViewEventDescriptionScrollFrameScrollBar)
end

S:AddCallbackForAddon('Blizzard_Calendar')
