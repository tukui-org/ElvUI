local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local ipairs, select, unpack = ipairs, select, unpack

local CLASS_SORT_ORDER = CLASS_SORT_ORDER
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

function S:Blizzard_Calendar()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.calendar) then return end

	local CalendarFrame = _G.CalendarFrame
	CalendarFrame:DisableDrawLayer('BORDER')
	CalendarFrame:CreateBackdrop('Transparent')
	S:HandleCloseButton(_G.CalendarCloseButton)
	_G.CalendarCloseButton:SetPoint('TOPRIGHT', CalendarFrame, 'TOPRIGHT', -4, -4)

	for i = 1, 7 do
		_G['CalendarWeekday'..i..'Background']:SetAlpha(0)
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
	--_G.CalendarCreateEventBackground:Hide()
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

	S:HandleNextPrevButton(_G.CalendarPrevMonthButton, nil, nil, true)
	S:HandleNextPrevButton(_G.CalendarNextMonthButton, nil, nil, true)

	_G.CalendarFilterFrame:StripTextures()
	_G.CalendarFilterFrame:SetWidth(155)

	_G.CalendarFilterFrameText:ClearAllPoints()
	_G.CalendarFilterFrameText:SetPoint('RIGHT', _G.CalendarFilterButton, 'LEFT', -2, 0)

	_G.CalendarFilterButton:ClearAllPoints()
	_G.CalendarFilterButton:SetPoint('RIGHT', _G.CalendarFilterFrame, 'RIGHT', -10, 3)
	_G.CalendarFilterButton.SetPoint = E.noop

	S:HandleNextPrevButton(_G.CalendarFilterButton)

	_G.CalendarFilterFrame:CreateBackdrop()
	_G.CalendarFilterFrame.backdrop:SetPoint('TOPLEFT', 20, 2)
	_G.CalendarFilterFrame.backdrop:SetPoint('BOTTOMRIGHT', _G.CalendarFilterButton, 'BOTTOMRIGHT', 2, -2)

	_G.CalendarContextMenu:SetTemplate()
	_G.CalendarContextMenu.SetBackdropColor = E.noop
	_G.CalendarContextMenu.SetBackdropBorderColor = E.noop

	_G.CalendarInviteStatusContextMenu:SetTemplate()
	_G.CalendarInviteStatusContextMenu.SetBackdropColor = E.noop
	_G.CalendarInviteStatusContextMenu.SetBackdropBorderColor = E.noop

	--Boost frame levels
	for i = 1, 42 do
		_G['CalendarDayButton'..i..'DarkFrame']:SetAlpha(.5)
		_G['CalendarDayButton'..i]:SetFrameLevel(_G['CalendarDayButton'..i]:GetFrameLevel() + 1)
		local bu = _G['CalendarDayButton'..i]

		if E.private.skins.parchmentRemoverEnable then
			bu:DisableDrawLayer('BACKGROUND') -- This would remove the 'Parchement'
		end

		bu:SetHighlightTexture(E.media.glossTex)
		local hl = bu:GetHighlightTexture()
		hl:SetVertexColor(1, 1, 1, 0.3)
		hl.SetAlpha = E.noop
		hl:SetPoint('TOPLEFT', -1, 1)
		hl:SetPoint('BOTTOMRIGHT')
	end

	_G.CalendarWeekdaySelectedTexture:SetDesaturated(true)
	_G.CalendarWeekdaySelectedTexture:SetVertexColor(1, 1, 1, 0.6)

	for i = 1, 6 do
		local vline = CreateFrame('Frame', nil, _G['CalendarDayButton'..i])
		vline:SetHeight(548)
		vline:SetWidth(1)
		vline:SetPoint('TOP', _G['CalendarDayButton'..i], 'TOPRIGHT')
		vline:CreateBackdrop()
	end

	for i = 1, 36, 7 do
		local hline = CreateFrame('Frame', nil, _G['CalendarDayButton'..i])
		hline:SetWidth(637)
		hline:SetHeight(1)
		hline:SetPoint('LEFT', _G['CalendarDayButton'..i], 'TOPLEFT')
		hline:CreateBackdrop()
	end

	hooksecurefunc('CalendarFrame_SetToday', function()
		_G.CalendarTodayFrame:SetAllPoints()
	end)

	_G.CalendarTodayFrame:SetScript('OnUpdate', nil)
	_G.CalendarTodayTextureGlow:Hide()
	_G.CalendarTodayTexture:Hide()

	_G.CalendarTodayFrame:SetBackdrop({
		edgeFile = E.media.blankTex,
		edgeSize = 2,
	})
	_G.CalendarTodayFrame:SetBackdropBorderColor(_G.NORMAL_FONT_COLOR:GetRGB())

	--CreateEventFrame
	_G.CalendarCreateEventFrame:StripTextures()
	_G.CalendarCreateEventFrame:CreateBackdrop('Transparent')
	_G.CalendarCreateEventFrame:SetPoint('TOPLEFT', CalendarFrame, 'TOPRIGHT', 3, -24)
	_G.CalendarCreateEventFrame.Header:StripTextures()

	S:HandleButton(_G.CalendarCreateEventCreateButton, true)
	S:HandleButton(_G.CalendarCreateEventMassInviteButton, true)
	S:HandleButton(_G.CalendarCreateEventInviteButton, true)
	_G.CalendarCreateEventInviteButton:SetPoint('TOPLEFT', _G.CalendarCreateEventInviteEdit, 'TOPRIGHT', 4, 1)
	_G.CalendarCreateEventInviteEdit:SetWidth(_G.CalendarCreateEventInviteEdit:GetWidth() - 2)

	_G.CalendarCreateEventInviteList:StripTextures()
	_G.CalendarCreateEventInviteList:CreateBackdrop()

	S:HandleEditBox(_G.CalendarCreateEventInviteEdit)
	S:HandleEditBox(_G.CalendarCreateEventTitleEdit)
	S:HandleDropDownBox(_G.CalendarCreateEventTypeDropDown, 120)
	S:HandleDropDownBox(_G.CalendarCreateEventCommunityDropDown, 240)

	_G.CalendarCreateEventDescriptionContainer:StripTextures()
	_G.CalendarCreateEventDescriptionContainer:SetTemplate()

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

	_G.CalendarClassButtonContainer:HookScript('OnShow', function()
		for i, class in ipairs(CLASS_SORT_ORDER) do
			local button = _G['CalendarClassButton'..i]
			local tcoords = CLASS_ICON_TCOORDS[class]
			local buttonIcon = button:GetNormalTexture()
			buttonIcon:SetTexture([[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]])
			buttonIcon:SetTexCoord(tcoords[1] + 0.015, tcoords[2] - 0.02, tcoords[3] + 0.018, tcoords[4] - 0.02) --F U C K I N G H A X
		end
	end)

	_G.CalendarClassButton1:SetPoint('TOPLEFT', _G.CalendarClassButtonContainer, 'TOPLEFT', E.PixelMode and 4 or 8, 0)

	for i = 1, #CLASS_SORT_ORDER do
		local button = _G['CalendarClassButton'..i]
		button:StripTextures()
		button:CreateBackdrop()
		button:SetSize(24, 24)
	end

	_G.CalendarClassTotalsButton:StripTextures()
	_G.CalendarClassTotalsButton:CreateBackdrop()
	_G.CalendarClassTotalsButton:SetWidth(24)

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

	S:HandleCloseButton(_G.CalendarMassInviteCloseButton)

	--Raid View
	_G.CalendarViewRaidFrame:StripTextures()
	_G.CalendarViewRaidFrame:CreateBackdrop('Transparent')
	_G.CalendarViewRaidFrame:SetPoint('TOPLEFT', CalendarFrame, 'TOPRIGHT', 3, -24)
	_G.CalendarViewRaidFrame.Header:StripTextures()
	S:HandleCloseButton(_G.CalendarViewRaidCloseButton)

	--Holiday View
	_G.CalendarViewHolidayFrame:StripTextures(true)
	_G.CalendarViewHolidayFrame:CreateBackdrop('Transparent')
	_G.CalendarViewHolidayFrame:SetPoint('TOPLEFT', CalendarFrame, 'TOPRIGHT', 3, -24)
	_G.CalendarViewHolidayFrame.Header:StripTextures()
	S:HandleCloseButton(_G.CalendarViewHolidayCloseButton)

	-- Event View
	_G.CalendarViewEventFrame:StripTextures()
	_G.CalendarViewEventFrame:CreateBackdrop('Transparent')
	_G.CalendarViewEventFrame:SetPoint('TOPLEFT', CalendarFrame, 'TOPRIGHT', 3, -24)
	_G.CalendarViewEventFrame.Header:StripTextures()
	_G.CalendarViewHolidayFrame.Header:StripTextures()
	_G.CalendarViewEventDescriptionContainer:StripTextures()
	_G.CalendarViewEventDescriptionContainer:SetTemplate('Transparent')
	_G.CalendarViewEventInviteList:StripTextures()
	_G.CalendarViewEventInviteList:SetTemplate('Transparent')
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
