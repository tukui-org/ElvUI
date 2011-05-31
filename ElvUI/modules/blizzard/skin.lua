local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local FONT = C["media"].font
local FONTSIZE = 18
local FONTFLAG = "THINOUTLINE"

if C["skin"].enable ~= true then return end

local function SetModifiedBackdrop(self)
	if C["general"].classcolortheme == true then
		self:SetBackdropBorderColor(unpack(C["media"].bordercolor))		
	else
		self:SetBackdropBorderColor(unpack(C["media"].valuecolor))	
	end
end

local function SetOriginalBackdrop(self)
	local color = RAID_CLASS_COLORS[E.myclass]
	if C["general"].classcolortheme == true then
		self:SetBackdropBorderColor(color.r, color.g, color.b)
	else
		self:SetTemplate("Default")
	end
end

local function SkinButton(f, strip)
	if f:GetName() then
		local l = _G[f:GetName().."Left"]
		local m = _G[f:GetName().."Middle"]
		local r = _G[f:GetName().."Right"]
		
		
		if l then l:SetAlpha(0) end
		if m then m:SetAlpha(0) end
		if r then r:SetAlpha(0) end
	end

	if f.SetNormalTexture then f:SetNormalTexture("") end
	
	if f.SetHighlightTexture then f:SetHighlightTexture("") end
	
	if f.SetPushedTexture then f:SetPushedTexture("") end
	
	if f.SetDisabledTexture then f:SetDisabledTexture("") end
	
	if strip then f:StripTextures() end
	
	f:SetTemplate("Default", true)
	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end

local function SkinScrollBar(frame)
	if _G[frame:GetName().."BG"] then _G[frame:GetName().."BG"]:SetTexture(nil) end
	if _G[frame:GetName().."Track"] then _G[frame:GetName().."Track"]:SetTexture(nil) end
	
	if _G[frame:GetName().."Top"] then
		_G[frame:GetName().."Top"]:SetTexture(nil)
		_G[frame:GetName().."Bottom"]:SetTexture(nil)
		_G[frame:GetName().."Middle"]:SetTexture(nil)
	end
end

--Tab Regions
local tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right",
}

local function SkinTab(tab)
	if not tab then return end
	for _, object in pairs(tabs) do
		local tex = _G[tab:GetName()..object]
		if tex then
			tex:SetTexture(nil)
		end
	end
	
	if tab.GetHighlightTexture and tab:GetHighlightTexture() then
		tab:GetHighlightTexture():SetTexture(nil)
	else
		tab:StripTextures()
	end
	
	tab.backdrop = CreateFrame("Frame", nil, tab)
	tab.backdrop:SetTemplate("Default")
	tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
	tab.backdrop:Point("TOPLEFT", 10, -3)
	tab.backdrop:Point("BOTTOMRIGHT", -10, 3)				
end

local function SkinNextPrevButton(btn, horizonal)
	btn:SetTemplate("Default")
	btn:Size(btn:GetWidth() - 7, btn:GetHeight() - 7)	

	if horizonal then
		btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.72, 0.65, 0.29, 0.65, 0.72)
		btn:GetPushedTexture():SetTexCoord(0.3, 0.35, 0.3, 0.8, 0.65, 0.35, 0.65, 0.8)
		btn:GetDisabledTexture():SetTexCoord(0.3, 0.29, 0.3, 0.75, 0.65, 0.29, 0.65, 0.75)	
	else
		btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.81, 0.65, 0.29, 0.65, 0.81)
		
		if btn:GetPushedTexture() then
			btn:GetPushedTexture():SetTexCoord(0.3, 0.35, 0.3, 0.81, 0.65, 0.35, 0.65, 0.81)
		end
		if btn:GetDisabledTexture() then
			btn:GetDisabledTexture():SetTexCoord(0.3, 0.29, 0.3, 0.75, 0.65, 0.29, 0.65, 0.75)
		end
	end
	
	btn:GetNormalTexture():ClearAllPoints()
	btn:GetNormalTexture():Point("TOPLEFT", 2, -2)
	btn:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
	if btn:GetDisabledTexture() then
		btn:GetDisabledTexture():SetAllPoints(btn:GetNormalTexture())
	end
	
	if btn:GetPushedTexture() then
		btn:GetPushedTexture():SetAllPoints(btn:GetNormalTexture())
	end
	
	btn:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	btn:GetHighlightTexture():SetAllPoints(btn:GetNormalTexture())
end

local function SkinRotateButton(btn)
	btn:SetTemplate("Default")
	btn:Size(btn:GetWidth() - 14, btn:GetHeight() - 14)	
	
	btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)
	btn:GetPushedTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)	
	
	btn:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	
	btn:GetNormalTexture():ClearAllPoints()
	btn:GetNormalTexture():Point("TOPLEFT", 2, -2)
	btn:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
	btn:GetPushedTexture():SetAllPoints(btn:GetNormalTexture())	
	btn:GetHighlightTexture():SetAllPoints(btn:GetNormalTexture())
end

local function SkinEditBox(frame)
	if _G[frame:GetName().."Left"] then _G[frame:GetName().."Left"]:Kill() end
	if _G[frame:GetName().."Middle"] then _G[frame:GetName().."Middle"]:Kill() end
	if _G[frame:GetName().."Right"] then _G[frame:GetName().."Right"]:Kill() end
	if _G[frame:GetName().."Mid"] then _G[frame:GetName().."Mid"]:Kill() end
	frame:CreateBackdrop("Default")
	
	if frame:GetName() and frame:GetName():find("Silver") or frame:GetName():find("Copper") then
		frame.backdrop:Point("BOTTOMRIGHT", -12, -2)
	end
end

local function SkinDropDownBox(frame, width)
	local button = _G[frame:GetName().."Button"]
	if not width then width = 155 end
	
	frame:StripTextures()
	frame:Width(width)
	
	_G[frame:GetName().."Text"]:ClearAllPoints()
	_G[frame:GetName().."Text"]:Point("RIGHT", button, "LEFT", -2, 0)

	
	button:ClearAllPoints()
	button:Point("RIGHT", frame, "RIGHT", -10, 3)
	button.SetPoint = E.dummy
	
	SkinNextPrevButton(button, true)
	
	frame:CreateBackdrop("Default")
	frame.backdrop:Point("TOPLEFT", 20, -2)
	frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
end

local function SkinCheckBox(frame)
	frame:StripTextures()
	frame:CreateBackdrop("Default")
	frame.backdrop:Point("TOPLEFT", 4, -4)
	frame.backdrop:Point("BOTTOMRIGHT", -4, 4)
	
	if frame.SetCheckedTexture then
		frame:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	end
	
	if frame.SetDisabledTexture then
		frame:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	end
	
	frame.SetNormalTexture = E.dummy
	frame.SetPushedTexture = E.dummy
	frame.SetHighlightTexture = E.dummy
end

local function SkinCloseButton(f, point)
	for i=1, f:GetNumRegions() do
		local region = select(i, f:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetDesaturated(1)
			
			if region:GetTexture() == "Interface\\DialogFrame\\UI-DialogBox-Corner" then
				region:Kill()
			end
		end
	end	
	
	if point then
		f:Point("TOPRIGHT", point, "TOPRIGHT", 2, 2)
	end
end

local ElvuiSkin = CreateFrame("Frame")
ElvuiSkin:RegisterEvent("ADDON_LOADED")
ElvuiSkin:SetScript("OnEvent", function(self, event, addon)
	if IsAddOnLoaded("Skinner") or IsAddOnLoaded("Aurora") then return end

	if addon == "Blizzard_TimeManager" and C["skin"].timemanager == true then
		TimeManagerFrame:StripTextures()
		TimeManagerFrame:SetTemplate("Transparent")

		SkinCloseButton(TimeManagerCloseButton)

		SkinDropDownBox(TimeManagerAlarmHourDropDown, 80)
		SkinDropDownBox(TimeManagerAlarmMinuteDropDown, 80)
		SkinDropDownBox(TimeManagerAlarmAMPMDropDown, 80)
		
		SkinEditBox(TimeManagerAlarmMessageEditBox)
		
		SkinButton(TimeManagerAlarmEnabledButton, true)
		TimeManagerAlarmEnabledButton:HookScript("OnClick", function(self)
			SkinButton(self)
		end)

		TimeManagerFrame:HookScript("OnShow", function(self)
			SkinButton(TimeManagerAlarmEnabledButton)
		end)		
		
		SkinCheckBox(TimeManagerMilitaryTimeCheck)
		SkinCheckBox(TimeManagerLocalTimeCheck)
		
		TimeManagerStopwatchFrame:StripTextures()
		TimeManagerStopwatchCheck:SetTemplate("Default")
		TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
		TimeManagerStopwatchCheck:GetNormalTexture():ClearAllPoints()
		TimeManagerStopwatchCheck:GetNormalTexture():Point("TOPLEFT", 2, -2)
		TimeManagerStopwatchCheck:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
		local hover = TimeManagerStopwatchCheck:CreateTexture("frame", nil, TimeManagerStopwatchCheck) -- hover
		hover:SetTexture(1,1,1,0.3)
		hover:Point("TOPLEFT",TimeManagerStopwatchCheck,2,-2)
		hover:Point("BOTTOMRIGHT",TimeManagerStopwatchCheck,-2,2)
		TimeManagerStopwatchCheck:SetHighlightTexture(hover)
		
		StopwatchFrame:StripTextures()
		StopwatchFrame:CreateBackdrop("Transparent")
		StopwatchFrame.backdrop:Point("TOPLEFT", 0, -17)
		StopwatchFrame.backdrop:Point("BOTTOMRIGHT", 0, 2)
		
		StopwatchTabFrame:StripTextures()
		SkinCloseButton(StopwatchCloseButton)
		SkinNextPrevButton(StopwatchPlayPauseButton)
		SkinNextPrevButton(StopwatchResetButton)
		StopwatchPlayPauseButton:Point("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
		StopwatchResetButton:Point("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 6)
	end
	
	if addon == "Blizzard_ReforgingUI" and C["skin"].reforge == true then
		ReforgingFrame:StripTextures()
		ReforgingFrame:SetTemplate("Transparent")
		
		ReforgingFrameTopInset:StripTextures()
		ReforgingFrameInset:StripTextures()
		ReforgingFrameBottomInset:StripTextures()
		
		SkinButton(ReforgingFrameRestoreButton, true)
		SkinButton(ReforgingFrameReforgeButton, true)
		
		SkinDropDownBox(ReforgingFrameFilterOldStat, 180)
		SkinDropDownBox(ReforgingFrameFilterNewStat, 180)
		
		ReforgingFrameItemButton:StripTextures()
		ReforgingFrameItemButton:SetTemplate("Default", true)
		ReforgingFrameItemButton:StyleButton()
		ReforgingFrameItemButtonIconTexture:ClearAllPoints()
		ReforgingFrameItemButtonIconTexture:Point("TOPLEFT", 2, -2)
		ReforgingFrameItemButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)
		
		hooksecurefunc("ReforgingFrame_Update", function(self)
			local currentReforge, icon, name, quality, bound, cost = GetReforgeItemInfo()
			if icon then
				ReforgingFrameItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
			else
				ReforgingFrameItemButtonIconTexture:SetTexture(nil)
			end
		end)
		
		SkinCloseButton(ReforgingFrameCloseButton)
	end
	
	if addon == "Blizzard_Calendar" and C["skin"].calendar == true then
		local frames = {
			"CalendarFrame",
		}
		
		for _, frame in pairs(frames) do
			_G[frame]:StripTextures()
		end
		
		CalendarFrame:SetTemplate("Transparent")
		SkinCloseButton(CalendarCloseButton)
		CalendarCloseButton:Point("TOPRIGHT", CalendarFrame, "TOPRIGHT", -4, -4)
		
		SkinNextPrevButton(CalendarPrevMonthButton)
		SkinNextPrevButton(CalendarNextMonthButton)
		
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
			
			SkinNextPrevButton(button, true)
			
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
		
		SkinButton(CalendarCreateEventCreateButton, true)
		SkinButton(CalendarCreateEventMassInviteButton, true)
		SkinButton(CalendarCreateEventInviteButton, true)
		CalendarCreateEventInviteButton:Point("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
		CalendarCreateEventInviteEdit:Width(CalendarCreateEventInviteEdit:GetWidth() - 2)
		
		CalendarCreateEventInviteList:StripTextures()
		CalendarCreateEventInviteList:SetTemplate("Default")
		
		SkinEditBox(CalendarCreateEventInviteEdit)
		SkinEditBox(CalendarCreateEventTitleEdit)
		SkinDropDownBox(CalendarCreateEventTypeDropDown, 120)
		
		CalendarCreateEventDescriptionContainer:StripTextures()
		CalendarCreateEventDescriptionContainer:SetTemplate("Default")
		
		SkinCloseButton(CalendarCreateEventCloseButton)
		
		SkinCheckBox(CalendarCreateEventLockEventCheck)
		
		SkinDropDownBox(CalendarCreateEventHourDropDown, 68)
		SkinDropDownBox(CalendarCreateEventMinuteDropDown, 68)
		SkinDropDownBox(CalendarCreateEventAMPMDropDown, 68)
		SkinDropDownBox(CalendarCreateEventRepeatOptionDropDown, 120)
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
		
		SkinScrollBar(CalendarTexturePickerScrollBar)
		SkinButton(CalendarTexturePickerAcceptButton, true)
		SkinButton(CalendarTexturePickerCancelButton, true)
		SkinButton(CalendarCreateEventInviteButton, true)
		SkinButton(CalendarCreateEventRaidInviteButton, true)
		
		--Mass Invite Frame
		CalendarMassInviteFrame:StripTextures()
		CalendarMassInviteFrame:SetTemplate("Transparent")
		CalendarMassInviteTitleFrame:StripTextures()
		
		SkinCloseButton(CalendarMassInviteCloseButton)
		SkinButton(CalendarMassInviteGuildAcceptButton)
		SkinButton(CalendarMassInviteArenaButton2)
		SkinButton(CalendarMassInviteArenaButton3)
		SkinButton(CalendarMassInviteArenaButton5)
		SkinDropDownBox(CalendarMassInviteGuildRankMenu, 130)
		
		SkinEditBox(CalendarMassInviteGuildMinLevelEdit)
		SkinEditBox(CalendarMassInviteGuildMaxLevelEdit)
		
		--Raid View
		CalendarViewRaidFrame:StripTextures()
		CalendarViewRaidFrame:SetTemplate("Transparent")
		CalendarViewRaidFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
		CalendarViewRaidTitleFrame:StripTextures()
		SkinCloseButton(CalendarViewRaidCloseButton)
		
		--Holiday View
		CalendarViewHolidayFrame:StripTextures(true)
		CalendarViewHolidayFrame:SetTemplate("Transparent")
		CalendarViewHolidayFrame:Point("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
		CalendarViewHolidayTitleFrame:StripTextures()
		SkinCloseButton(CalendarViewHolidayCloseButton)
		
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
		SkinCloseButton(CalendarViewEventCloseButton)
		SkinScrollBar(CalendarViewEventInviteListScrollFrameScrollBar)
		
		local buttons = {
		    "CalendarViewEventAcceptButton",
		    "CalendarViewEventTentativeButton",
		    "CalendarViewEventRemoveButton",
			"CalendarViewEventDeclineButton",
		}

		for _, button in pairs(buttons) do
			SkinButton(_G[button])
		end		
	end
	
	if addon == "Blizzard_AchievementUI" and C["skin"].achievement == true then
		local frames = {
			"AchievementFrame",
			"AchievementFrameCategories",
			"AchievementFrameSummary",
			"AchievementFrameHeader",
			"AchievementFrameSummaryCategoriesHeader",
			"AchievementFrameSummaryAchievementsHeader",
			"AchievementFrameStatsBG",
			"AchievementFrameAchievements",
			"AchievementFrameComparison",
			"AchievementFrameComparisonHeader",
			"AchievementFrameComparisonSummaryPlayer",
			"AchievementFrameComparisonSummaryFriend",
		}
		
		for _, frame in pairs(frames) do
			_G[frame]:StripTextures(true)
		end
		
		local noname_frames = {
			"AchievementFrameStats",
			"AchievementFrameSummary",
			"AchievementFrameAchievements",
			"AchievementFrameComparison"
		}
		
		for _, frame in pairs(noname_frames) do
			for i=1, _G[frame]:GetNumChildren() do
				local child = select(i, _G[frame]:GetChildren())
				if child and not child:GetName() then
					child:SetBackdrop(nil)
				end
			end
		end
		
		AchievementFrame:CreateBackdrop("Transparent")
		AchievementFrame.backdrop:Point("TOPLEFT", 0, 6)
		AchievementFrame.backdrop:SetPoint("BOTTOMRIGHT")
		AchievementFrameHeaderTitle:ClearAllPoints()
		AchievementFrameHeaderTitle:Point("TOPLEFT", AchievementFrame.backdrop, "TOPLEFT", -30, -8)
		AchievementFrameHeaderPoints:ClearAllPoints()
		AchievementFrameHeaderPoints:Point("LEFT", AchievementFrameHeaderTitle, "RIGHT", 2, 0)
		
		--Backdrops
		AchievementFrameCategoriesContainer:CreateBackdrop("Default")
		AchievementFrameCategoriesContainer.backdrop:Point("TOPLEFT", 0, 4)
		AchievementFrameCategoriesContainer.backdrop:Point("BOTTOMRIGHT", -2, -3)
		AchievementFrameAchievementsContainer:CreateBackdrop("Default")
		AchievementFrameAchievementsContainer.backdrop:Point("TOPLEFT", 0, 2)
		AchievementFrameAchievementsContainer.backdrop:Point("BOTTOMRIGHT", -3, -3)
		
		SkinCloseButton(AchievementFrameCloseButton, AchievementFrame.backdrop)
		SkinDropDownBox(AchievementFrameFilterDropDown)
		AchievementFrameFilterDropDown:Point("TOPRIGHT", AchievementFrame, "TOPRIGHT", -44, 5)
		
		-- ScrollBars
		SkinScrollBar(AchievementFrameCategoriesContainerScrollBar)
		SkinScrollBar(AchievementFrameAchievementsContainerScrollBar)
		SkinScrollBar(AchievementFrameStatsContainerScrollBar)
		SkinScrollBar(AchievementFrameComparisonContainerScrollBar)
		SkinScrollBar(AchievementFrameComparisonStatsContainerScrollBar)
		
		--Tabs
		for i = 1, 3 do
			SkinTab(_G["AchievementFrameTab"..i])
			_G["AchievementFrameTab"..i]:SetFrameLevel(_G["AchievementFrameTab"..i]:GetFrameLevel() + 2)
		end
		
		local function SkinStatusBar(bar)
			bar:StripTextures()
			bar:SetStatusBarTexture(C["media"].normTex)
			bar:SetStatusBarColor(4/255, 179/255, 30/255)
			bar:CreateBackdrop("Default")
			
			if _G[bar:GetName().."Title"] then
				_G[bar:GetName().."Title"]:SetPoint("LEFT", 4, 0)
			end

			if _G[bar:GetName().."Label"] then
				_G[bar:GetName().."Label"]:SetPoint("LEFT", 4, 0)
			end
			
			if _G[bar:GetName().."Text"] then
				_G[bar:GetName().."Text"]:SetPoint("RIGHT", -4, 0)
			end
		end

		SkinStatusBar(AchievementFrameSummaryCategoriesStatusBar)
		SkinStatusBar(AchievementFrameComparisonSummaryPlayerStatusBar)
		SkinStatusBar(AchievementFrameComparisonSummaryFriendStatusBar)
		AchievementFrameComparisonSummaryFriendStatusBar.text:ClearAllPoints()
		AchievementFrameComparisonSummaryFriendStatusBar.text:SetPoint("CENTER")
		AchievementFrameComparisonHeader:Point("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 45, -20)
		
		for i=1, 8 do
			local frame = _G["AchievementFrameSummaryCategoriesCategory"..i]
			local button = _G["AchievementFrameSummaryCategoriesCategory"..i.."Button"]
			local highlight = _G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]
			SkinStatusBar(frame)
			button:StripTextures()
			highlight:StripTextures()
			
			_G[highlight:GetName().."Middle"]:SetTexture(1, 1, 1, 0.3)
			_G[highlight:GetName().."Middle"]:SetAllPoints(frame)
		end
		
		AchievementFrame:HookScript("OnShow", function()
			for i=1, 20 do
				local frame = _G["AchievementFrameCategoriesContainerButton"..i]
				local lastframe = _G["AchievementFrameCategoriesContainerButton"..i-1]
				
				frame:StripTextures()
				frame:StyleButton()				
			end	
		end)
		
		hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
			for i=1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
				local frame = _G["AchievementFrameSummaryAchievement"..i]
				_G["AchievementFrameSummaryAchievement"..i.."Highlight"]:Kill()
				frame:StripTextures()
				
				
				_G["AchievementFrameSummaryAchievement"..i.."Description"]:SetTextColor(0.6, 0.6, 0.6)
				
				if not frame.backdrop then
					frame:CreateBackdrop("Default", true)
					frame.backdrop:Point("TOPLEFT", 2, -2)
					frame.backdrop:Point("BOTTOMRIGHT", -2, 2)

					_G["AchievementFrameSummaryAchievement"..i.."IconBling"]:Kill()
					_G["AchievementFrameSummaryAchievement"..i.."IconOverlay"]:Kill()
					_G["AchievementFrameSummaryAchievement"..i.."Icon"]:SetTemplate("Default")
					_G["AchievementFrameSummaryAchievement"..i.."Icon"]:Height(_G["AchievementFrameSummaryAchievement"..i.."Icon"]:GetHeight() - 14)
					_G["AchievementFrameSummaryAchievement"..i.."Icon"]:Width(_G["AchievementFrameSummaryAchievement"..i.."Icon"]:GetWidth() - 14)
					_G["AchievementFrameSummaryAchievement"..i.."Icon"]:ClearAllPoints()
					_G["AchievementFrameSummaryAchievement"..i.."Icon"]:Point("LEFT", 6, 0)
					_G["AchievementFrameSummaryAchievement"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
					_G["AchievementFrameSummaryAchievement"..i.."IconTexture"]:ClearAllPoints()
					_G["AchievementFrameSummaryAchievement"..i.."IconTexture"]:Point("TOPLEFT", 2, -2)
					_G["AchievementFrameSummaryAchievement"..i.."IconTexture"]:Point("BOTTOMRIGHT", -2, 2)
				end
			end				
		end)
		
		for i=1, 7 do
			local frame = _G["AchievementFrameAchievementsContainerButton"..i]
			_G["AchievementFrameAchievementsContainerButton"..i.."Highlight"]:Kill()
			frame:StripTextures(true)
			frame.SetBackdropBorderColor = E.dummy

			--Initiate fucked up method of creating a backdrop
			frame.bg1 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg1:SetDrawLayer("BACKGROUND", 4)
			frame.bg1:SetTexture(C["media"].glossTex) --Default TukUI users this is normTex, glossTex doesn't exist
			frame.bg1:SetVertexColor(unpack(C["media"].backdropcolor))
			frame.bg1:Point("TOPLEFT", E.mult*4, -E.mult*4)
			frame.bg1:Point("BOTTOMRIGHT", -E.mult*4, E.mult*4)				
			
			frame.bg2 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg2:SetDrawLayer("BACKGROUND", 3)
			frame.bg2:SetTexture(0,0,0)
			frame.bg2:Point("TOPLEFT", E.mult*3, -E.mult*3)
			frame.bg2:Point("BOTTOMRIGHT", -E.mult*3, E.mult*3)
			
			frame.bg3 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg3:SetDrawLayer("BACKGROUND", 2)
			frame.bg3:SetTexture(unpack(C["media"].bordercolor))
			frame.bg3:Point("TOPLEFT", E.mult*2, -E.mult*2)
			frame.bg3:Point("BOTTOMRIGHT", -E.mult*2, E.mult*2)			

			frame.bg4 = frame:CreateTexture(nil, "BACKGROUND")
			frame.bg4:SetDrawLayer("BACKGROUND", 1)
			frame.bg4:SetTexture(0,0,0)
			frame.bg4:Point("TOPLEFT", E.mult, -E.mult)
			frame.bg4:Point("BOTTOMRIGHT", -E.mult, E.mult)					

	
			
			_G["AchievementFrameAchievementsContainerButton"..i.."Description"]:SetTextColor(0.6, 0.6, 0.6)
			_G["AchievementFrameAchievementsContainerButton"..i.."Description"].SetTextColor = E.dummy
			_G["AchievementFrameAchievementsContainerButton"..i.."HiddenDescription"]:SetTextColor(1, 1, 1)
			_G["AchievementFrameAchievementsContainerButton"..i.."HiddenDescription"].SetTextColor = E.dummy
			
			_G["AchievementFrameAchievementsContainerButton"..i.."IconBling"]:Kill()
			_G["AchievementFrameAchievementsContainerButton"..i.."IconOverlay"]:Kill()
			_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:SetTemplate("Default")
			_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:Height(_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:GetHeight() - 14)
			_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:Width(_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:GetWidth() - 14)
			_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:ClearAllPoints()
			_G["AchievementFrameAchievementsContainerButton"..i.."Icon"]:Point("LEFT", 6, 0)
			_G["AchievementFrameAchievementsContainerButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
			_G["AchievementFrameAchievementsContainerButton"..i.."IconTexture"]:ClearAllPoints()
			_G["AchievementFrameAchievementsContainerButton"..i.."IconTexture"]:Point("TOPLEFT", 2, -2)
			_G["AchievementFrameAchievementsContainerButton"..i.."IconTexture"]:Point("BOTTOMRIGHT", -2, 2)		
			
			
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"].oborder = "Don't use sharp border" --Needed for ElvUI only
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:StripTextures()
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:SetTemplate("Default")
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:Size(12, 12)
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:GetCheckedTexture():Point("TOPLEFT", -4, 4)
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:GetCheckedTexture():Point("BOTTOMRIGHT", 4, -4)
			
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:ClearAllPoints()
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"]:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
			
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"].ClearAllPoints = E.dummy
			_G["AchievementFrameAchievementsContainerButton"..i.."Tracked"].SetPoint = E.dummy
		end

		
		local compares = {
			"Player",
			"Friend"
		}
		
		for _, compare in pairs(compares) do
			for i=1, 9 do
				local frame = "AchievementFrameComparisonContainerButton"..i..compare
				
				_G[frame]:StripTextures()
				_G[frame.."Background"]:Kill()
				
				_G[frame].SetBackdropBorderColor = E.dummy		
				
				if _G[frame.."Description"] then
					_G[frame.."Description"]:SetTextColor(0.6, 0.6, 0.6)
					_G[frame.."Description"].SetTextColor = E.dummy
				end

				--Initiate fucked up method of creating a backdrop
				_G[frame].bg1 = _G[frame]:CreateTexture(nil, "BACKGROUND")
				_G[frame].bg1:SetDrawLayer("BACKGROUND", 4)
				_G[frame].bg1:SetTexture(C["media"].glossTex) --Default TukUI users this is normTex, glossTex doesn't exist
				_G[frame].bg1:SetVertexColor(unpack(C["media"].backdropcolor))
				_G[frame].bg1:Point("TOPLEFT", E.mult*4, -E.mult*4)
				_G[frame].bg1:Point("BOTTOMRIGHT", -E.mult*4, E.mult*4)				
				
				_G[frame].bg2 = _G[frame]:CreateTexture(nil, "BACKGROUND")
				_G[frame].bg2:SetDrawLayer("BACKGROUND", 3)
				_G[frame].bg2:SetTexture(0,0,0)
				_G[frame].bg2:Point("TOPLEFT", E.mult*3, -E.mult*3)
				_G[frame].bg2:Point("BOTTOMRIGHT", -E.mult*3, E.mult*3)
				
				_G[frame].bg3 = _G[frame]:CreateTexture(nil, "BACKGROUND")
				_G[frame].bg3:SetDrawLayer("BACKGROUND", 2)
				_G[frame].bg3:SetTexture(unpack(C["media"].bordercolor))
				_G[frame].bg3:Point("TOPLEFT", E.mult*2, -E.mult*2)
				_G[frame].bg3:Point("BOTTOMRIGHT", -E.mult*2, E.mult*2)			

				_G[frame].bg4 = _G[frame]:CreateTexture(nil, "BACKGROUND")
				_G[frame].bg4:SetDrawLayer("BACKGROUND", 1)
				_G[frame].bg4:SetTexture(0,0,0)
				_G[frame].bg4:Point("TOPLEFT", E.mult, -E.mult)
				_G[frame].bg4:Point("BOTTOMRIGHT", -E.mult, E.mult)	
				
				
				if compare == "Friend" then
					_G[frame.."Shield"]:Point("TOPRIGHT", _G["AchievementFrameComparisonContainerButton"..i.."Friend"], "TOPRIGHT", -20, -3)
				end
								
				_G[frame.."IconBling"]:Kill()
				_G[frame.."IconOverlay"]:Kill()
				_G[frame.."Icon"]:SetTemplate("Default")
				_G[frame.."Icon"]:Height(_G[frame.."Icon"]:GetHeight() - 14)
				_G[frame.."Icon"]:Width(_G[frame.."Icon"]:GetWidth() - 14)
				_G[frame.."Icon"]:ClearAllPoints()
				_G[frame.."Icon"]:Point("LEFT", 6, 0)
				_G[frame.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
				_G[frame.."IconTexture"]:ClearAllPoints()
				_G[frame.."IconTexture"]:Point("TOPLEFT", 2, -2)
				_G[frame.."IconTexture"]:Point("BOTTOMRIGHT", -2, 2)					
			end
		end
		
		for i=1, 20 do
			local frame = _G["AchievementFrameStatsContainerButton"..i]
			frame:StyleButton()
			
			_G["AchievementFrameStatsContainerButton"..i.."BG"]:SetTexture(1, 1, 1, 0.2)
			_G["AchievementFrameStatsContainerButton"..i.."HeaderLeft"]:Kill()
			_G["AchievementFrameStatsContainerButton"..i.."HeaderRight"]:Kill()
			_G["AchievementFrameStatsContainerButton"..i.."HeaderMiddle"]:Kill()
			
			local frame = "AchievementFrameComparisonStatsContainerButton"..i
			_G[frame]:StripTextures()
			_G[frame]:StyleButton()
		
			_G[frame.."BG"]:SetTexture(1, 1, 1, 0.2)
			_G[frame.."HeaderLeft"]:Kill()
			_G[frame.."HeaderRight"]:Kill()
			_G[frame.."HeaderMiddle"]:Kill()			
		end
		
		
		hooksecurefunc("AchievementButton_GetProgressBar", function(index)
			local frame = _G["AchievementFrameProgressBar"..index]
			if frame then
				if not frame.skinned then
					frame:StripTextures()
					frame:SetStatusBarTexture(C["media"].normTex)
					frame:SetStatusBarColor(4/255, 179/255, 30/255)
					frame:SetFrameLevel(frame:GetFrameLevel() + 3)
					
					frame:Height(frame:GetHeight() - 2)
					
					--Initiate fucked up method of creating a backdrop
					frame.bg1 = frame:CreateTexture(nil, "BACKGROUND")
					frame.bg1:SetDrawLayer("BACKGROUND", -7)
					frame.bg1:SetTexture(unpack(C["media"].backdropcolor))
					frame.bg1:Point("TOPLEFT", -E.mult*3, E.mult*3)
					frame.bg1:Point("BOTTOMRIGHT", E.mult*3, -E.mult*3)
					
					frame.bg2 = frame:CreateTexture(nil, "BACKGROUND")
					frame.bg2:SetDrawLayer("BACKGROUND", -6)
					frame.bg2:SetTexture(unpack(C["media"].bordercolor))
					frame.bg2:Point("TOPLEFT", -E.mult*2, E.mult*2)
					frame.bg2:Point("BOTTOMRIGHT", E.mult*2, -E.mult*2)					

					frame.bg3 = frame:CreateTexture(nil, "BACKGROUND")
					frame.bg3:SetDrawLayer("BACKGROUND", -5)
					frame.bg3:SetTexture(unpack(C["media"].backdropcolor))
					frame.bg3:Point("TOPLEFT", -E.mult, E.mult)
					frame.bg3:Point("BOTTOMRIGHT", E.mult, -E.mult)		
					
					frame.text:ClearAllPoints()
					frame.text:SetPoint("CENTER", frame, "CENTER", 0, -1)
					frame.text:SetJustifyH("CENTER")
					
					if index > 1 then
						frame:ClearAllPoints()
						frame:Point("TOP", _G["AchievementFrameProgressBar"..index-1], "BOTTOM", 0, -5)
						frame.SetPoint = E.dummy
						frame.ClearAllPoints = E.dummy
					end
					
					frame.skinned = true
				end

			end
		end)
		
		hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
			local numCriteria = GetAchievementNumCriteria(id)
			local textStrings, metas = 0, 0
			for i = 1, numCriteria do	
				local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i)
				
				if ( criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID ) then
					metas = metas + 1;
					local metaCriteria = AchievementButton_GetMeta(metas);				
					if ( objectivesFrame.completed and completed ) then
						metaCriteria.label:SetShadowOffset(0, 0)
						metaCriteria.label:SetTextColor(1, 1, 1, 1);
					elseif ( completed ) then
						metaCriteria.label:SetShadowOffset(1, -1)
						metaCriteria.label:SetTextColor(0, 1, 0, 1);
					else
						metaCriteria.label:SetShadowOffset(1, -1)
						metaCriteria.label:SetTextColor(.6, .6, .6, 1);
					end				
				elseif criteriaType ~= 1 then
					textStrings = textStrings + 1;
					local criteria = AchievementButton_GetCriteria(textStrings);				
					if ( objectivesFrame.completed and completed ) then
						criteria.name:SetTextColor(1, 1, 1, 1);
						criteria.name:SetShadowOffset(0, 0);
					elseif ( completed ) then
						criteria.name:SetTextColor(0, 1, 0, 1);
						criteria.name:SetShadowOffset(1, -1);
					else
						criteria.name:SetTextColor(.6, .6, .6, 1);
						criteria.name:SetShadowOffset(1, -1);
					end		
				end
			end
		end)
	end	
	
	-- LF guild UI
	if addon == "Blizzard_LookingForGuildUI" and C["skin"].lfguild == true then
		local checkbox = {
			"LookingForGuildPvPButton",
			"LookingForGuildWeekendsButton",
			"LookingForGuildWeekdaysButton",
			"LookingForGuildRPButton",
			"LookingForGuildRaidButton",
			"LookingForGuildQuestButton",
			"LookingForGuildDungeonButton",
		}
		-- skin checkboxes
		for _, v in pairs(checkbox) do
			SkinCheckBox(_G[v])
		end
		
	
		-- have to skin these checkboxes seperate for some reason o_O
		SkinCheckBox(LookingForGuildTankButton.checkButton)
		SkinCheckBox(LookingForGuildHealerButton.checkButton)
		SkinCheckBox(LookingForGuildDamagerButton.checkButton)
		
		-- skinning other frames
		LookingForGuildFrameInset:StripTextures(false)
		LookingForGuildFrame:StripTextures()
		LookingForGuildFrame:SetTemplate("Default")
		LookingForGuildBrowseButton_LeftSeparator:Kill()
		LookingForGuildRequestButton_RightSeparator:Kill()
		SkinScrollBar(LookingForGuildBrowseFrameContainerScrollBar)
		SkinButton(LookingForGuildBrowseButton)
		SkinButton(LookingForGuildRequestButton)
		SkinCloseButton(LookingForGuildFrameCloseButton)
		LookingForGuildCommentInputFrame:CreateBackdrop("Default")
		LookingForGuildCommentInputFrame:StripTextures(false)
		
		-- skin container buttons on browse and request page
		for i = 1, 5 do
			local b = _G["LookingForGuildBrowseFrameContainerButton"..i]
			local t = _G["LookingForGuildAppsFrameContainerButton"..i]
			b:SetBackdrop(nil)
			t:SetBackdrop(nil)
		end
		
		-- skin tabs
		for i= 1, 3 do
			SkinTab(_G["LookingForGuildFrameTab"..i])
		end
		
		GuildFinderRequestMembershipFrame:StripTextures(true)
		GuildFinderRequestMembershipFrame:SetTemplate("Transparent")
		SkinButton(GuildFinderRequestMembershipFrameAcceptButton)
		SkinButton(GuildFinderRequestMembershipFrameCancelButton)
		GuildFinderRequestMembershipFrameInputFrame:StripTextures()
		GuildFinderRequestMembershipFrameInputFrame:SetTemplate("Default")
	end	
	
	--Inspect Frame
	if addon == "Blizzard_InspectUI" and C["skin"].inspect == true then
		InspectFrame:StripTextures(true)
		InspectFrameInset:StripTextures(true)
		InspectTalentFramePointsBar:StripTextures()
		InspectFrame:CreateBackdrop("Transparent")
		InspectFrame.backdrop:SetAllPoints()
		SkinCloseButton(InspectFrameCloseButton)
		
		for i=1, 4 do
			SkinTab(_G["InspectFrameTab"..i])
		end
		
		InspectModelFrameBorderTopLeft:Kill()
		InspectModelFrameBorderTopRight:Kill()
		InspectModelFrameBorderTop:Kill()
		InspectModelFrameBorderLeft:Kill()
		InspectModelFrameBorderRight:Kill()
		InspectModelFrameBorderBottomLeft:Kill()
		InspectModelFrameBorderBottomRight:Kill()
		InspectModelFrameBorderBottom:Kill()
		InspectModelFrameBorderBottom2:Kill()
		InspectModelFrameBackgroundOverlay:Kill()
		InspectModelFrame:CreateBackdrop("Default")
		
			local slots = {
				"HeadSlot",
				"NeckSlot",
				"ShoulderSlot",
				"BackSlot",
				"ChestSlot",
				"ShirtSlot",
				"TabardSlot",
				"WristSlot",
				"HandsSlot",
				"WaistSlot",
				"LegsSlot",
				"FeetSlot",
				"Finger0Slot",
				"Finger1Slot",
				"Trinket0Slot",
				"Trinket1Slot",
				"MainHandSlot",
				"SecondaryHandSlot",
				"RangedSlot",
			}
			for _, slot in pairs(slots) do
				local icon = _G["Inspect"..slot.."IconTexture"]
				local slot = _G["Inspect"..slot]
				slot:StripTextures()
				slot:StyleButton(false)
				icon:SetTexCoord(.08, .92, .08, .92)
				icon:ClearAllPoints()
				icon:Point("TOPLEFT", 2, -2)
				icon:Point("BOTTOMRIGHT", -2, 2)
				
				slot:SetFrameLevel(slot:GetFrameLevel() + 2)
				slot:CreateBackdrop("Default")
				slot.backdrop:SetAllPoints()
			end		
		
		SkinRotateButton(InspectModelFrameRotateLeftButton)
		SkinRotateButton(InspectModelFrameRotateRightButton)
		InspectModelFrameRotateRightButton:Point("TOPLEFT", InspectModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)
		
		InspectPVPFrameBottom:Kill()
		InspectGuildFrameBG:Kill()
		InspectPVPFrame:HookScript("OnShow", function() InspectPVPFrameBG:Kill() end)
		
		for i=1, 3 do
			_G["InspectPVPTeam"..i]:StripTextures()
			_G["InspectTalentFrameTab"..i]:StripTextures()
		end
		
		InspectTalentFrame.bg = CreateFrame("Frame", nil, InspectTalentFrame)
		InspectTalentFrame.bg:SetTemplate("Default")
		InspectTalentFrame.bg:Point("TOPLEFT", InspectTalentFrameBackgroundTopLeft, "TOPLEFT", -2, 2)
		InspectTalentFrame.bg:Point("BOTTOMRIGHT", InspectTalentFrameBackgroundBottomRight, "BOTTOMRIGHT", -20, 52)
		InspectTalentFrame.bg:SetFrameLevel(InspectTalentFrame.bg:GetFrameLevel() - 2)
		
		for i = 1, MAX_NUM_TALENTS do
			local button = _G["InspectTalentFrameTalent"..i]
			local icon = _G["InspectTalentFrameTalent"..i.."IconTexture"]
			if button then
				button:StripTextures()
				button:StyleButton()
				button:SetTemplate("Default")
				button.SetHighlightTexture = E.dummy
				button.SetPushedTexture = E.dummy
				button:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
				button:GetPushedTexture():SetTexCoord(.08, .92, .08, .92)
				button:GetHighlightTexture():SetAllPoints(icon)
				button:GetPushedTexture():SetAllPoints(icon)
				
				if button.Rank then
					button.Rank:SetFont(FONT, 12, FONTFLAG)
					button.Rank:ClearAllPoints()
					button.Rank:SetPoint("BOTTOMRIGHT")
				end		
				
				icon:ClearAllPoints()
				icon:Point("TOPLEFT", 2, -2)
				icon:Point("BOTTOMRIGHT", -2, 2)
				icon:SetTexCoord(.08, .92, .08, .92)
			end
		end		
	end
	
	--Keybinds
	if addon == "Blizzard_BindingUI" and C["skin"].binding == true then
		local buttons = {
			"KeyBindingFrameDefaultButton",
			"KeyBindingFrameUnbindButton",
			"KeyBindingFrameOkayButton",
			"KeyBindingFrameCancelButton",
		}
		
		for _, v in pairs(buttons) do
			_G[v]:StripTextures()
			_G[v]:SetTemplate("Default", true)
		end
		
		SkinCheckBox(KeyBindingFrameCharacterButton)
		KeyBindingFrameHeaderText:ClearAllPoints()
		KeyBindingFrameHeaderText:Point("TOP", KeyBindingFrame, "TOP", 0, -4)
		KeyBindingFrame:StripTextures()
		KeyBindingFrame:SetTemplate("Transparent")
		
		for i = 1, KEY_BINDINGS_DISPLAYED  do
			local button1 = _G["KeyBindingFrameBinding"..i.."Key1Button"]
			local button2 = _G["KeyBindingFrameBinding"..i.."Key2Button"]
			button1:StripTextures(true)
			button1:StyleButton(false)
			button1:SetTemplate("Default", true)
			button2:StripTextures(true)
			button2:StyleButton(false)
			button2:SetTemplate("Default", true)
		end
		
		KeyBindingFrameUnbindButton:Point("RIGHT", KeyBindingFrameOkayButton, "LEFT", -3, 0)
		KeyBindingFrameOkayButton:Point("RIGHT", KeyBindingFrameCancelButton, "LEFT", -3, 0)
	end	
	
	--GBANK
	if addon == "Blizzard_GuildBankUI" and C["skin"].gbank == true then
		GuildBankFrame:StripTextures()
		GuildBankFrame:SetTemplate("Transparent")
		GuildBankEmblemFrame:StripTextures(true)
		
		--Close button doesn't have a fucking name, extreme hackage
		for i=1, GuildBankFrame:GetNumChildren() do
			local child = select(i, GuildBankFrame:GetChildren())
			if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
				SkinCloseButton(child)
			end
		end
		
		SkinButton(GuildBankFrameDepositButton, true)
		SkinButton(GuildBankFrameWithdrawButton, true)
		SkinButton(GuildBankInfoSaveButton, true)
		SkinButton(GuildBankFramePurchaseButton, true)
		
		GuildBankFrameWithdrawButton:Point("RIGHT", GuildBankFrameDepositButton, "LEFT", -2, 0)

		GuildBankInfoScrollFrame:StripTextures()
		GuildBankTransactionsScrollFrame:StripTextures()
		
		GuildBankFrame.inset = CreateFrame("Frame", nil, GuildBankFrame)
		GuildBankFrame.inset:SetTemplate("Default")
		GuildBankFrame.inset:Point("TOPLEFT", 30, -65)
		GuildBankFrame.inset:Point("BOTTOMRIGHT", -20, 63)
		
		for i=1, NUM_GUILDBANK_COLUMNS do
			_G["GuildBankColumn"..i]:StripTextures()
			
			for x=1, NUM_SLOTS_PER_GUILDBANK_GROUP do
				local button = _G["GuildBankColumn"..i.."Button"..x]
				local icon = _G["GuildBankColumn"..i.."Button"..x.."IconTexture"]
				button:StripTextures()
				button:StyleButton()
				button:SetTemplate("Default", true)
				
				icon:ClearAllPoints()
				icon:Point("TOPLEFT", 2, -2)
				icon:Point("BOTTOMRIGHT", -2, 2)
				icon:SetTexCoord(.08, .92, .08, .92)
			end
		end
		
		for i=1, 8 do
			local button = _G["GuildBankTab"..i.."Button"]
			local texture = _G["GuildBankTab"..i.."ButtonIconTexture"]
			_G["GuildBankTab"..i]:StripTextures(true)
			
			button:StripTextures()
			button:StyleButton(true)
			button:SetTemplate("Default", true)
			
			texture:ClearAllPoints()
			texture:Point("TOPLEFT", 2, -2)
			texture:Point("BOTTOMRIGHT", -2, 2)
			texture:SetTexCoord(.08, .92, .08, .92)
		end
		
		for i=1, 4 do
			SkinTab(_G["GuildBankFrameTab"..i])
		end
		
		--Popup
		GuildBankPopupFrame:StripTextures()
		GuildBankPopupScrollFrame:StripTextures()
		GuildBankPopupFrame:SetTemplate("Transparent")
		GuildBankPopupFrame:Point("TOPLEFT", GuildBankFrame, "TOPRIGHT", 1, -30)
		SkinButton(GuildBankPopupOkayButton)
		SkinButton(GuildBankPopupCancelButton)
		SkinEditBox(GuildBankPopupEditBox)
		GuildBankPopupNameLeft:Kill()
		GuildBankPopupNameRight:Kill()
		GuildBankPopupNameMiddle:Kill()
		
		for i=1, 16 do
			local button = _G["GuildBankPopupButton"..i]
			local icon = _G[button:GetName().."Icon"]
			button:StripTextures()
			button:SetTemplate("Default")
			button:StyleButton(true)
			icon:ClearAllPoints()
			icon:Point("TOPLEFT", 2, -2)
			icon:Point("BOTTOMRIGHT", -2, 2)
			icon:SetTexCoord(.08, .92, .08, .92)
		end
	end
	
	--Archaeology
	if addon == "Blizzard_ArchaeologyUI" and C["skin"].archaeology == true then
		ArchaeologyFrame:StripTextures(true)
		ArchaeologyFrameInset:StripTextures(true)
		ArchaeologyFrame:SetTemplate("Transparent")
		ArchaeologyFrame:CreateShadow("Default")
		
		SkinButton(ArchaeologyFrameArtifactPageSolveFrameSolveButton, true)
		SkinButton(ArchaeologyFrameArtifactPageBackButton, true)
		SkinDropDownBox(ArchaeologyFrameRaceFilter, 125)
		
		ArchaeologyFrameRankBar:StripTextures()
		ArchaeologyFrameRankBar:SetStatusBarTexture(C["media"].normTex)
		ArchaeologyFrameRankBar:CreateBackdrop("Default")
		
		ArchaeologyFrameArtifactPageSolveFrameStatusBar:StripTextures()
		ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarTexture(C["media"].normTex)
		ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarColor(0.7, 0.2, 0)
		ArchaeologyFrameArtifactPageSolveFrameStatusBar:CreateBackdrop("Default")
		
		for i=1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
			local artifact = _G["ArchaeologyFrameCompletedPageArtifact"..i]
			
			if artifact then
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."Border"]:Kill()
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."Bg"]:Kill()
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"]:SetTexCoord(.08, .92, .08, .92)
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"].backdrop = CreateFrame("Frame", nil, artifact)
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"].backdrop:SetTemplate("Default")
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"].backdrop:Point("TOPLEFT", _G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"], "TOPLEFT", -2, 2)
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"].backdrop:Point("BOTTOMRIGHT", _G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"], "BOTTOMRIGHT", 2, -2)
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"].backdrop:SetFrameLevel(artifact:GetFrameLevel() - 2)
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"]:SetDrawLayer("OVERLAY")
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."ArtifactName"]:SetTextColor(1, 1, 0)
				_G["ArchaeologyFrameCompletedPageArtifact"..i.."ArtifactSubText"]:SetTextColor(0.6, 0.6, 0.6)
			end
		end
		
		for i=1, ARCHAEOLOGY_MAX_RACES do
			local frame = _G["ArchaeologyFrameSummaryPageRace"..i]
			
			if frame then
				frame.raceName:SetTextColor(1, 1, 1)
			end
		end
		
		for i=1, ArchaeologyFrameCompletedPage:GetNumRegions() do
			local region = select(i, ArchaeologyFrameCompletedPage:GetRegions())
			if region:GetObjectType() == "FontString" then
				region:SetTextColor(1, 1, 0)
			end
		end
		
		for i=1, ArchaeologyFrameSummaryPage:GetNumRegions() do
			local region = select(i, ArchaeologyFrameSummaryPage:GetRegions())
			if region:GetObjectType() == "FontString" then
				region:SetTextColor(1, 1, 0)
			end
		end
		
		ArchaeologyFrameCompletedPage.infoText:SetTextColor(1, 1, 1)
		ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 0)
		ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 0)
		ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
		
		ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, 1, 0)
		ArchaeologyFrameArtifactPageIcon:SetTexCoord(.08, .92, .08, .92)
		ArchaeologyFrameArtifactPageIcon.backdrop = CreateFrame("Frame", nil, ArchaeologyFrameArtifactPage)
		ArchaeologyFrameArtifactPageIcon.backdrop:SetTemplate("Default")
	    ArchaeologyFrameArtifactPageIcon.backdrop:Point("TOPLEFT", ArchaeologyFrameArtifactPageIcon, "TOPLEFT", -2, 2)
		ArchaeologyFrameArtifactPageIcon.backdrop:Point("BOTTOMRIGHT", ArchaeologyFrameArtifactPageIcon, "BOTTOMRIGHT", 2, -2)
		ArchaeologyFrameArtifactPageIcon.backdrop:SetFrameLevel(ArchaeologyFrameArtifactPage:GetFrameLevel())
		ArchaeologyFrameArtifactPageIcon:SetParent(ArchaeologyFrameArtifactPageIcon.backdrop)
		ArchaeologyFrameArtifactPageIcon:SetDrawLayer("OVERLAY")	
		
		ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)
		SkinCloseButton(ArchaeologyFrameCloseButton)
	end
	
	--Guild Control
	if addon == "Blizzard_GuildControlUI" and C["skin"].guildcontrol == true then
		GuildControlUI:StripTextures()
		GuildControlUIHbar:StripTextures()
		GuildControlUI:SetTemplate("Transparent")
		GuildControlUI:CreateShadow("Default")
		
		local function SkinGuildRanks()
			for i=1, GuildControlGetNumRanks() do
				local rankFrame = _G["GuildControlUIRankOrderFrameRank"..i]
				if rankFrame then
					SkinButton(rankFrame.downButton)
					SkinButton(rankFrame.upButton)
					SkinButton(rankFrame.deleteButton)
					
					if not rankFrame.nameBox.backdrop then
						SkinEditBox(rankFrame.nameBox)
					end
					
					rankFrame.nameBox.backdrop:Point("TOPLEFT", -2, -4)
					rankFrame.nameBox.backdrop:Point("BOTTOMRIGHT", -4, 4)
				end
			end				
		end
		hooksecurefunc("GuildControlUI_RankOrder_Update", SkinGuildRanks)
		GuildControlUIRankOrderFrameNewButton:HookScript("OnClick", function()
			E.Delay(1, SkinGuildRanks)
		end)
		
		SkinDropDownBox(GuildControlUINavigationDropDown)
		SkinDropDownBox(GuildControlUIRankSettingsFrameRankDropDown, 180)
		GuildControlUINavigationDropDownButton:Width(20)
		GuildControlUIRankSettingsFrameRankDropDownButton:Width(20)
		
		for i=1, NUM_RANK_FLAGS do
			if _G["GuildControlUIRankSettingsFrameCheckbox"..i] then
				SkinCheckBox(_G["GuildControlUIRankSettingsFrameCheckbox"..i])
			end
		end
		
		SkinButton(GuildControlUIRankOrderFrameNewButton)
		
		SkinEditBox(GuildControlUIRankSettingsFrameGoldBox)
		GuildControlUIRankSettingsFrameGoldBox.backdrop:Point("TOPLEFT", -2, -4)
		GuildControlUIRankSettingsFrameGoldBox.backdrop:Point("BOTTOMRIGHT", 2, 4)
		GuildControlUIRankSettingsFrameGoldBox:StripTextures()
		
		GuildControlUIRankBankFrame:StripTextures()
		
		local once = false
		hooksecurefunc("GuildControlUI_BankTabPermissions_Update", function()
			local numTabs = GetNumGuildBankTabs()
			if numTabs < MAX_BUY_GUILDBANK_TABS then
				numTabs = numTabs + 1
			end
			for i=1, numTabs do
				local tab = _G["GuildControlBankTab"..i.."Owned"]
				local icon = tab.tabIcon
				local editbox = tab.editBox
				
				icon:SetTexCoord(.08, .92, .08, .92)
				
				if once == false then
					SkinButton(_G["GuildControlBankTab"..i.."BuyPurchaseButton"])
					_G["GuildControlBankTab"..i.."OwnedStackBox"]:StripTextures()
				end
			end
			once = true
		end)
		
		SkinDropDownBox(GuildControlUIRankBankFrameRankDropDown, 180)
		GuildControlUIRankBankFrameRankDropDownButton:Width(20)
	end
	
	--Guild
	if addon == "Blizzard_GuildUI" and C["skin"].guild == true then
		GuildFrame:StripTextures(true)
		GuildFrame:SetTemplate("Transparent")
		GuildFrame:CreateShadow("Default")
		GuildLevelFrame:Kill()
		
		SkinCloseButton(GuildMemberDetailCloseButton)
		SkinCloseButton(GuildFrameCloseButton)
		
		local striptextures = {
			"GuildNewPerksFrame",
			"GuildFrameInset",
			"GuildFrameBottomInset",
			"GuildAllPerksFrame",
			"GuildMemberDetailFrame",
			"GuildMemberNoteBackground",
			"GuildInfoFrameInfo",
			"GuildLogContainer",
			"GuildLogFrame",
			"GuildRewardsFrame",
			"GuildMemberOfficerNoteBackground",
			"GuildTextEditContainer",
			"GuildTextEditFrame",
			"GuildRecruitmentRolesFrame",
			"GuildRecruitmentAvailabilityFrame",
			"GuildRecruitmentInterestFrame",
			"GuildRecruitmentLevelFrame",
			"GuildRecruitmentCommentFrame",
			"GuildRecruitmentCommentInputFrame",
			"GuildInfoFrameApplicantsContainer",
			"GuildInfoFrameApplicants",
			"GuildNewsBossModel",
			"GuildNewsBossModelTextFrame",
		}
		GuildRewardsFrameVisitText:ClearAllPoints()
		GuildRewardsFrameVisitText:SetPoint("TOP", GuildRewardsFrame, "TOP", 0, 30)
		for _, frame in pairs(striptextures) do
			_G[frame]:StripTextures()
		end
		
		GuildNewsBossModel:CreateBackdrop("Transparent")
		GuildNewsBossModelTextFrame:CreateBackdrop("Default")
		GuildNewsBossModelTextFrame.backdrop:Point("TOPLEFT", GuildNewsBossModel.backdrop, "BOTTOMLEFT", 0, -1)
		GuildNewsBossModel:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -43)
		
		local buttons = {
			"GuildPerksToggleButton",
			"GuildMemberRemoveButton",
			"GuildMemberGroupInviteButton",
			"GuildAddMemberButton",
			"GuildViewLogButton",
			"GuildControlButton",
			"GuildRecruitmentListGuildButton",
			"GuildTextEditFrameAcceptButton",
			"GuildRecruitmentInviteButton",
			"GuildRecruitmentMessageButton",
			"GuildRecruitmentDeclineButton",
		}
		
		for i, button in pairs(buttons) do
			if i == 1 then
				SkinButton(_G[button])
			else
				SkinButton(_G[button], true)
			end
		end
		
		local checkbuttons = {
			"Quest", 
			"Dungeon",
			"Raid",
			"PvP",
			"RP",
			"Weekdays",
			"Weekends",
			"LevelAny",
			"LevelMax",
		}
		
		for _, frame in pairs(checkbuttons) do
			SkinCheckBox(_G["GuildRecruitment"..frame.."Button"])
		end
		
		SkinCheckBox(GuildRecruitmentTankButton:GetChildren())
		SkinCheckBox(GuildRecruitmentHealerButton:GetChildren())
		SkinCheckBox(GuildRecruitmentDamagerButton:GetChildren())
		
		for i=1,5 do
			SkinTab(_G["GuildFrameTab"..i])
		end
		GuildXPFrame:ClearAllPoints()
		GuildXPFrame:Point("TOP", GuildFrame, "TOP", 0, -40)
		
		SkinScrollBar(GuildPerksContainerScrollBar)
		
		GuildFactionBar:StripTextures()
		GuildFactionBar.progress:SetTexture(C["media"].normTex)
		GuildFactionBar:CreateBackdrop("Default")
		GuildFactionBar.backdrop:Point("TOPLEFT", GuildFactionBar.progress, "TOPLEFT", -2, 2)
		GuildFactionBar.backdrop:Point("BOTTOMRIGHT", GuildFactionBar, "BOTTOMRIGHT", -2, 0)
		
		GuildXPBarLeft:Kill()
		GuildXPBarRight:Kill()
		GuildXPBarMiddle:Kill()
		GuildXPBarBG:Kill()
		GuildXPBarShadow:Kill()
		GuildXPBarCap:Kill()
		GuildXPBar.progress:SetTexture(C["media"].normTex)
		GuildXPBar:CreateBackdrop("Default")
		GuildXPBar.backdrop:Point("TOPLEFT", GuildXPBar.progress, "TOPLEFT", -2, 2)
		GuildXPBar.backdrop:Point("BOTTOMRIGHT", GuildXPBar, "BOTTOMRIGHT", -2, 4)
		
		GuildLatestPerkButton:StripTextures()
		GuildLatestPerkButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
		GuildLatestPerkButtonIconTexture:ClearAllPoints()
		GuildLatestPerkButtonIconTexture:Point("TOPLEFT", 2, -2)
		GuildLatestPerkButton:CreateBackdrop("Default")
		GuildLatestPerkButton.backdrop:Point("TOPLEFT", GuildLatestPerkButtonIconTexture, "TOPLEFT", -2, 2)
		GuildLatestPerkButton.backdrop:Point("BOTTOMRIGHT", GuildLatestPerkButtonIconTexture, "BOTTOMRIGHT", 2, -2)
		
		GuildNextPerkButton:StripTextures()
		GuildNextPerkButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
		GuildNextPerkButtonIconTexture:ClearAllPoints()
		GuildNextPerkButtonIconTexture:Point("TOPLEFT", 2, -2)
		GuildNextPerkButton:CreateBackdrop("Default")
		GuildNextPerkButton.backdrop:Point("TOPLEFT", GuildNextPerkButtonIconTexture, "TOPLEFT", -2, 2)
		GuildNextPerkButton.backdrop:Point("BOTTOMRIGHT", GuildNextPerkButtonIconTexture, "BOTTOMRIGHT", 2, -2)
		
		--Guild Perk buttons list
		for i=1, 8 do
			local button = _G["GuildPerksContainerButton"..i]
			button:StripTextures()
			
			if button.icon then
				button.icon:SetTexCoord(.08, .92, .08, .92)
				button.icon:ClearAllPoints()
				button.icon:Point("TOPLEFT", 2, -2)
				button:CreateBackdrop("Default")
				button.backdrop:Point("TOPLEFT", button.icon, "TOPLEFT", -2, 2)
				button.backdrop:Point("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 2, -2)
				button.icon:SetParent(button.backdrop)
			end
		end
		
		--Roster
		SkinScrollBar(GuildRosterContainerScrollBar)
		SkinCheckBox(GuildRosterShowOfflineButton)
		
		
		for i=1, 4 do
			_G["GuildRosterColumnButton"..i]:StripTextures(true)
		end
		
		SkinDropDownBox(GuildRosterViewDropdown, 200)
		
		for i=1, 14 do
			SkinButton(_G["GuildRosterContainerButton"..i.."HeaderButton"], true)
		end
		
		--Detail Frame
		GuildMemberDetailFrame:SetTemplate("Transparent")
		GuildMemberNoteBackground:SetTemplate("Default")
		GuildMemberOfficerNoteBackground:SetTemplate("Default")
		GuildMemberRankDropdown:SetFrameLevel(GuildMemberRankDropdown:GetFrameLevel() + 5)
		SkinDropDownBox(GuildMemberRankDropdown, 175)

		--News
		GuildNewsFrame:StripTextures()
		for i=1, 17 do
			_G["GuildNewsContainerButton"..i].header:Kill()
		end
		
		GuildNewsFiltersFrame:StripTextures()
		GuildNewsFiltersFrame:SetTemplate("Transparent")
		SkinCloseButton(GuildNewsFiltersFrameCloseButton)
		
		for i=1, 7 do
			SkinCheckBox(_G["GuildNewsFilterButton"..i])
		end
		
		GuildNewsFiltersFrame:Point("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -20)
		SkinScrollBar(GuildNewsContainerScrollBar)
		
		--Info Frame
		SkinScrollBar(GuildInfoDetailsFrameScrollBar)
		
		for i=1, 3 do
			_G["GuildInfoFrameTab"..i]:StripTextures()
		end
		
		local backdrop1 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
		backdrop1:SetTemplate("Default")
		backdrop1:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
		backdrop1:Point("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -22)
		backdrop1:Point("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 200)
		
		local backdrop2 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
		backdrop2:SetTemplate("Default")
		backdrop2:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
		backdrop2:Point("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -158)
		backdrop2:Point("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 118)	

		local backdrop3 = CreateFrame("Frame", nil, GuildInfoFrameInfo)
		backdrop3:SetTemplate("Default")
		backdrop3:SetFrameLevel(GuildInfoFrameInfo:GetFrameLevel() - 1)
		backdrop3:Point("TOPLEFT", GuildInfoFrameInfo, "TOPLEFT", 2, -233)
		backdrop3:Point("BOTTOMRIGHT", GuildInfoFrameInfo, "BOTTOMRIGHT", 0, 3)	
		
		GuildRecruitmentCommentInputFrame:SetTemplate("Default")
		
		for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
			button.selectedTex:Kill()
			button:GetHighlightTexture():Kill()
			button:SetBackdrop(nil)
		end
		
		--Text Edit Frame
		GuildTextEditFrame:SetTemplate("Transparent")
		SkinScrollBar(GuildTextEditScrollFrameScrollBar)
		GuildTextEditContainer:SetTemplate("Default")
		for i=1, GuildTextEditFrame:GetNumChildren() do
			local child = select(i, GuildTextEditFrame:GetChildren())
			if child:GetName() == "GuildTextEditFrameCloseButton" and child:GetWidth() == 32 then
				SkinCloseButton(child)
			elseif child:GetName() == "GuildTextEditFrameCloseButton" then
				SkinButton(child, true)
			end
		end
		
		--Guild Log
		SkinScrollBar(GuildLogScrollFrameScrollBar)
		GuildLogFrame:SetTemplate("Transparent")

		--Blizzard has two buttons with the same name, this is a fucked up way of determining that it isn't the other button
		for i=1, GuildLogFrame:GetNumChildren() do
			local child = select(i, GuildLogFrame:GetChildren())
			if child:GetName() == "GuildLogFrameCloseButton" and child:GetWidth() == 32 then
				SkinCloseButton(child)
			elseif child:GetName() == "GuildLogFrameCloseButton" then
				SkinButton(child, true)
			end
		end
		
		--Rewards
		SkinScrollBar(GuildRewardsContainerScrollBar)
		
		for i=1, 8 do
			local button = _G["GuildRewardsContainerButton"..i]
			button:StripTextures()
			
			if button.icon then
				button.icon:SetTexCoord(.08, .92, .08, .92)
				button.icon:ClearAllPoints()
				button.icon:Point("TOPLEFT", 2, -2)
				button:CreateBackdrop("Default")
				button.backdrop:Point("TOPLEFT", button.icon, "TOPLEFT", -2, 2)
				button.backdrop:Point("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 2, -2)
				button.icon:SetParent(button.backdrop)
			end
		end
		
	
		
	end
	
	--TradeSkill
	if addon == "Blizzard_TradeSkillUI" and C["skin"].tradeskill == true then
		TradeSkillFrame:StripTextures(true)
		TradeSkillListScrollFrame:StripTextures()
		TradeSkillDetailScrollFrame:StripTextures()
		TradeSkillFrameInset:StripTextures()
		TradeSkillExpandButtonFrame:StripTextures()
		TradeSkillDetailScrollChildFrame:StripTextures()
		
		TradeSkillFrame:SetTemplate("Transparent")
		TradeSkillFrame:CreateShadow("Default")
		TradeSkillFrame:Height(TradeSkillFrame:GetHeight() + 12)
		TradeSkillRankFrame:StripTextures()
		TradeSkillRankFrame:CreateBackdrop("Default")
		TradeSkillRankFrame:SetStatusBarTexture(C["media"].normTex)
		
		SkinButton(TradeSkillCreateButton, true)
		SkinButton(TradeSkillCancelButton, true)
		SkinButton(TradeSkillFilterButton, true)
		SkinButton(TradeSkillCreateAllButton, true)
		SkinButton(TradeSkillViewGuildCraftersButton, true)
		
		TradeSkillLinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.37, 0.75)
		TradeSkillLinkButton:GetPushedTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)
		TradeSkillLinkButton:GetHighlightTexture():Kill()
		TradeSkillLinkButton:CreateBackdrop("Default")
		TradeSkillLinkButton:Size(17, 14)
		TradeSkillLinkButton:Point("LEFT", TradeSkillLinkFrame, "LEFT", 5, -1)
		SkinEditBox(TradeSkillFrameSearchBox)
		SkinEditBox(TradeSkillInputBox)
		SkinNextPrevButton(TradeSkillDecrementButton)
		SkinNextPrevButton(TradeSkillIncrementButton)
		TradeSkillIncrementButton:Point("RIGHT", TradeSkillCreateButton, "LEFT", -13, 0)
		
		SkinCloseButton(TradeSkillFrameCloseButton)
		
		local once = false
		hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
			TradeSkillSkillIcon:StyleButton()
			if TradeSkillSkillIcon:GetNormalTexture() then
				TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
				TradeSkillSkillIcon:GetNormalTexture():ClearAllPoints()
				TradeSkillSkillIcon:GetNormalTexture():Point("TOPLEFT", 2, -2)
				TradeSkillSkillIcon:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
			end
			TradeSkillSkillIcon:SetTemplate("Default")

			for i=1, MAX_TRADE_SKILL_REAGENTS do
				local button = _G["TradeSkillReagent"..i]
				local icon = _G["TradeSkillReagent"..i.."IconTexture"]
				local count = _G["TradeSkillReagent"..i.."Count"]
				
				icon:SetTexCoord(.08, .92, .08, .92)
				icon:SetDrawLayer("OVERLAY")
				if not icon.backdrop then
					icon.backdrop = CreateFrame("Frame", nil, button)
					icon.backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
					icon.backdrop:SetTemplate("Default")
					icon.backdrop:Point("TOPLEFT", icon, "TOPLEFT", -2, 2)
					icon.backdrop:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
				end
				
				icon:SetParent(icon.backdrop)
				count:SetParent(icon.backdrop)
				count:SetDrawLayer("OVERLAY")
				
				if i > 2 and once == false then
					local point, anchoredto, point2, x, y = button:GetPoint()
					button:ClearAllPoints()
					button:Point(point, anchoredto, point2, x, y - 3)
					once = true
				end
				
				_G["TradeSkillReagent"..i.."NameFrame"]:Kill()
			end
		end)
		
		
		--Guild Crafters
		TradeSkillGuildFrame:StripTextures()
		TradeSkillGuildFrame:SetTemplate("Transparent")
		TradeSkillGuildFrame:Point("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 19)
		TradeSkillGuildFrameContainer:StripTextures()
		TradeSkillGuildFrameContainer:SetTemplate("Default")
		SkinCloseButton(TradeSkillGuildFrameCloseButton)
	end

	--Raid Frame
	if addon == "Blizzard_RaidUI" and C["skin"].raid == true then
		local buttons = {
			"RaidFrameRaidBrowserButton",
			"RaidFrameRaidInfoButton",
			"RaidFrameReadyCheckButton",
		}

		for i = 1, #buttons do
			SkinButton(_G[buttons[i]])
		end

		local StripAllTextures = {
			"RaidGroup1",
			"RaidGroup2",
			"RaidGroup3",
			"RaidGroup4",
			"RaidGroup5",
			"RaidGroup6",
			"RaidGroup7",
			"RaidGroup8",
		}

		for _, object in pairs(StripAllTextures) do
			_G[object]:StripTextures()
		end

		for i=1, MAX_RAID_GROUPS*5 do
			SkinButton(_G["RaidGroupButton"..i], true)
		end

		for i=1,8 do
			for j=1,5 do
				_G["RaidGroup"..i.."Slot"..j]:StripTextures()
				_G["RaidGroup"..i.."Slot"..j]:SetTemplate("Transparent")
			end
		end
	end	
	
	-- Talent Trees
	if addon == "Blizzard_TalentUI" and C["skin"].talent == true then
		--PLAYER TALENTS
		local buttons = {
			"PlayerTalentFrameToggleSummariesButton",
			"PlayerTalentFrameActivateButton",
		}
		PlayerTalentFrameToggleSummariesButton:Point("BOTTOM", PlayerTalentFrame, "BOTTOM",0,5)

		for i = 1, #buttons do
			_G[buttons[i]]:StripTextures()
			SkinButton(_G[buttons[i]])
		end

		local StripAllTextures = {
			"PlayerTalentFrame",
			"PlayerTalentFrameInset",
			"PlayerTalentFrameTalents",
			"PlayerTalentFramePanel1HeaderIcon",
			"PlayerTalentFramePanel2HeaderIcon",
			"PlayerTalentFramePanel3HeaderIcon",
			"PlayerTalentFramePetTalents",
		}

		for _, object in pairs(StripAllTextures) do
			_G[object]:StripTextures()
		end
		
		local function StripTalentFramePanelTextures(object)
			for i=1, object:GetNumRegions() do
				local region = select(i, object:GetRegions())
				if region:GetObjectType() == "Texture" then
					if region:GetName():find("Branch") then
						region:SetDrawLayer("OVERLAY")
					else
						region:SetTexture(nil)
					end
				end
			end
		end
		
		StripTalentFramePanelTextures(PlayerTalentFramePanel1)
		StripTalentFramePanelTextures(PlayerTalentFramePanel2)
		StripTalentFramePanelTextures(PlayerTalentFramePanel3)
		StripTalentFramePanelTextures(PlayerTalentFramePetPanel)
		
		for i=1, 3 do
			_G["PlayerTalentFramePanel"..i.."SelectTreeButton"]:SetFrameLevel(_G["PlayerTalentFramePanel"..i.."SelectTreeButton"]:GetFrameLevel() + 5)
			_G["PlayerTalentFramePanel"..i.."SelectTreeButton"]:StripTextures(true)
			SkinButton(_G["PlayerTalentFramePanel"..i.."SelectTreeButton"])
		end

		local KillTextures = {
			"PlayerTalentFramePanel1InactiveShadow",
			"PlayerTalentFramePanel2InactiveShadow",
			"PlayerTalentFramePanel3InactiveShadow",
			"PlayerTalentFramePanel1SummaryRoleIcon",
			"PlayerTalentFramePanel2SummaryRoleIcon",
			"PlayerTalentFramePanel3SummaryRoleIcon",
			"PlayerTalentFramePetShadowOverlay",
			"PlayerTalentFrameHeaderHelpBox",
		}

		for _, texture in pairs(KillTextures) do
			_G[texture]:Kill()
		end
		
		for i=1, 3 do
			_G["PlayerTalentFramePanel"..i.."Arrow"]:SetFrameLevel(_G["PlayerTalentFramePanel"..i.."Arrow"]:GetFrameLevel() + 2)
		end
		PlayerTalentFramePetPanelArrow:SetFrameStrata("HIGH")
		

		PlayerTalentFrame:SetTemplate("Transparent")
		PlayerTalentFramePanel1:CreateBackdrop("Transparent")
		PlayerTalentFramePanel1.backdrop:Point( "TOPLEFT", PlayerTalentFramePanel1, "TOPLEFT", 3, -3 )
		PlayerTalentFramePanel1.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePanel1, "BOTTOMRIGHT", -3, 3 )
		PlayerTalentFramePanel2:CreateBackdrop("Transparent")
		PlayerTalentFramePanel2.backdrop:Point( "TOPLEFT", PlayerTalentFramePanel2, "TOPLEFT", 3, -3 )
		PlayerTalentFramePanel2.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePanel2, "BOTTOMRIGHT", -3, 3 )
		PlayerTalentFramePanel3:CreateBackdrop("Transparent")
		PlayerTalentFramePanel3.backdrop:Point( "TOPLEFT", PlayerTalentFramePanel3, "TOPLEFT", 3, -3 )
		PlayerTalentFramePanel3.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePanel3, "BOTTOMRIGHT", -3, 3 )
		PlayerTalentFrame:CreateShadow("Default")
		SkinCloseButton(PlayerTalentFrameCloseButton)

		function talentpairs(inspect,pet)
		   local tab,tal=1,0
		   return function()
			  tal=tal+1
			  if tal>GetNumTalents(tab,inspect,pet) then
				 tal=1
				 tab=tab+1
			  end
			  if tab<=GetNumTalentTabs(inspect,pet) then
				 return tab,tal
			  end
		   end
		end

		--Skin TalentButtons
		local function TalentButtons(self, first, i, j)
			local button = _G["PlayerTalentFramePanel"..i.."Talent"..j]
			local icon = _G["PlayerTalentFramePanel"..i.."Talent"..j.."IconTexture"]

			if first then
				button:StripTextures()
			end
			
			if button.Rank then
				button.Rank:SetFont(FONT, 12, FONTFLAG)
				button.Rank:ClearAllPoints()
				button.Rank:SetPoint("BOTTOMRIGHT")
			end
			
			if icon then
				icon:SetTexCoord(.08, .92, .08, .92)
				button:StyleButton()
				button.SetHighlightTexture = E.dummy
				button.SetPushedTexture = E.dummy
				button:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
				button:GetPushedTexture():SetTexCoord(.08, .92, .08, .92)
				button:GetHighlightTexture():SetAllPoints(icon)
				button:GetPushedTexture():SetAllPoints(icon)
				
				icon:ClearAllPoints()
				icon:SetAllPoints()
				button:SetFrameLevel(button:GetFrameLevel() +1)
				button:CreateBackdrop("Default", true)
			end
		end

		local function TalentSummaryButtons(self, first, active, i, j)
			if active then
				button = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1"]
				icon = _G["PlayerTalentFramePanel"..i.."SummaryActiveBonus1Icon"]
			else
				button = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j]
				icon = _G["PlayerTalentFramePanel"..i.."SummaryBonus"..j.."Icon"]
			end

			if first then
				button:StripTextures()
			end

			if icon then
				icon:SetTexCoord(.08, .92, .08, .92)
				button:SetFrameLevel(button:GetFrameLevel() +1)
				local frame = CreateFrame("Frame",nil, button)
				frame:CreateBackdrop("Default", true)
				frame:SetFrameLevel(button:GetFrameLevel() -1)
				frame:ClearAllPoints()
				frame:Point( "TOPLEFT", icon, "TOPLEFT", 0, 0 )
				frame:Point( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0 )
			end
		end

		for i=1, 2 do
			local tab = _G["PlayerSpecTab"..i]
			if tab then
				local a = tab:GetRegions()
				a:Hide()
				tab:StripTextures()
				tab:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
				
				tab:GetNormalTexture():ClearAllPoints()
				tab:GetNormalTexture():Point("TOPLEFT", 2, -2)
				tab:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)

				tab:CreateBackdrop("Default")
				tab.backdrop:SetAllPoints()
				tab:StyleButton(true)
			end
		end

		--Reposition tabs
		PlayerSpecTab1:ClearAllPoints()
		PlayerSpecTab1:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", 2, -32)
		PlayerSpecTab1.SetPoint = E.dummy
		
		local function TalentSummaryClean(i)
			local frame = _G["PlayerTalentFramePanel"..i.."Summary"]
			frame:SetFrameLevel(frame:GetFrameLevel() + 2)
			frame:CreateBackdrop("Default")
			frame:SetFrameLevel(frame:GetFrameLevel() +1)
			local a,b,_,d,_,_,_,_,_,_,_,_,m,_ = frame:GetRegions()
			a:Hide()
			b:Hide()
			d:Hide()
			m:Hide()
			
			_G["PlayerTalentFramePanel"..i.."SummaryIcon"]:SetTexCoord(.08, .92, .08, .92)
		end

		local function TalentHeaderIcon(self, first, i)
			local button = _G["PlayerTalentFramePanel"..i.."HeaderIcon"]
			local icon = _G["PlayerTalentFramePanel"..i.."HeaderIconIcon"]
			local panel = _G["PlayerTalentFramePanel"..i]
			local text = _G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpent"]

			if first then
				button:StripTextures()
			end
			
			_G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpent"]:SetFont(FONT, 12, FONTFLAG)

			if icon then
				icon:SetTexCoord(.08, .92, .08, .92)
				button:SetFrameLevel(button:GetFrameLevel() +1)
				button:ClearAllPoints()
				button:Point("TOPLEFT",panel,"TOPLEFT", 4, -4)
				text:SetFont(FONT, 12, FONTFLAG)
				text:Point("BOTTOMRIGHT",button, "BOTTOMRIGHT", -1, 2)
				local frame = CreateFrame("Frame",nil, button)
				frame:CreateBackdrop("Default", true)
				frame:SetFrameLevel(button:GetFrameLevel() +1)
				frame:ClearAllPoints()
				frame:Point( "TOPLEFT", icon, "TOPLEFT", 0, 0 )
				frame:Point( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0 )
			end
		end		

		for i=1, 3 do
			TalentSummaryClean(i)
			TalentHeaderIcon(nil, true, i)
			for j=1, 2 do
				TalentSummaryButtons(nil, true, true, i, j)
				TalentSummaryButtons(nil, true, false, i, j)
			end
		end

		for tab,talent in talentpairs() do
			TalentButtons(nil, true, tab, talent)
		end

		for i=1, 3 do
			SkinTab(_G["PlayerTalentFrameTab"..i])
		end

		--PET TALENTS
		SkinRotateButton(PlayerTalentFramePetModelRotateLeftButton)
		SkinRotateButton(PlayerTalentFramePetModelRotateRightButton)
		PlayerTalentFramePetModelRotateLeftButton:Point("BOTTOM", PlayerTalentFramePetModel, "BOTTOM", -4, 4)
		PlayerTalentFramePetModelRotateRightButton:Point("TOPLEFT", PlayerTalentFramePetModelRotateLeftButton, "TOPRIGHT", 4, 0)
		PlayerTalentFramePetPanel:CreateBackdrop("Transparent")
		PlayerTalentFramePetPanel.backdrop:Point( "TOPLEFT", PlayerTalentFramePetPanel, "TOPLEFT", 3, -3 )
		PlayerTalentFramePetPanel.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePetPanel, "BOTTOMRIGHT", -3, 3 )
		PlayerTalentFramePetModel:CreateBackdrop("Transparent")
		PlayerTalentFramePetModel.backdrop:Point( "TOPLEFT", PlayerTalentFramePetModel, "TOPLEFT")
		PlayerTalentFramePetModel.backdrop:Point( "BOTTOMRIGHT", PlayerTalentFramePetModel, "BOTTOMRIGHT")
		SkinButton(PlayerTalentFrameLearnButton, true)
		SkinButton(PlayerTalentFrameResetButton, true)
		
		local function PetHeaderIcon(self, first)
			local button = _G["PlayerTalentFramePetPanelHeaderIcon"]
			local icon = _G["PlayerTalentFramePetPanelHeaderIconIcon"]
			local panel = _G["PlayerTalentFramePetPanel"]
			local d = select(4, button:GetRegions())

			if first then
				button:StripTextures()
			end

			if icon then
				d:ClearAllPoints()
				pointsSpent = select(5,GetTalentTabInfo( 1, Partycheck, true, 1 ))
				icon:SetTexCoord(.08, .92, .08, .92)
				button:SetFrameLevel(button:GetFrameLevel() +1)
				button:ClearAllPoints()
				button:Point("TOPLEFT",panel,"TOPLEFT", 5, -5)
				local text = button:FontString(nil, FONT, 12, FONTFLAG)
				text:Point("BOTTOMRIGHT",button, "BOTTOMRIGHT", -1, 2)
				text:SetText(pointsSpent)
				local frame = CreateFrame("Frame",nil, button)
				frame:CreateBackdrop("Default", true)
				frame:SetFrameLevel(button:GetFrameLevel() +1)
				frame:ClearAllPoints()
				frame:Point( "TOPLEFT", icon, "TOPLEFT", 0, 0 )
				frame:Point( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0 )
			end
		end

		local function PetInfoIcon(self, first)
			local button = _G["PlayerTalentFramePetInfo"]
			local icon = _G["PlayerTalentFramePetIcon"]
			local panel = _G["PlayerTalentFramePetModel"]

			PlayerTalentFramePetDiet:Hide();

			local petFoodList = { GetPetFoodTypes() };
			if #petFoodList > 0 then
				diet = petFoodList[1]
			else
				diet = "None"
			end

			if first then
				button:StripTextures()
			end

			if icon then
				icon:SetTexCoord(.08, .92, .08, .92)
				button:SetFrameLevel(button:GetFrameLevel() +1)
				button:ClearAllPoints()
				button:Point("BOTTOMLEFT",panel,"TOPLEFT", 0, 10)
				local text = button:FontString(nil, FONT, 12, FONTFLAG)
				text:Point("TOPRIGHT",button, "TOPRIGHT", 0, -10)
				text:SetText(diet)
				local frame = CreateFrame("Frame",nil, button)
				frame:CreateBackdrop("Default", true)
				frame:SetFrameLevel(button:GetFrameLevel() +1)
				frame:ClearAllPoints()
				frame:Point( "TOPLEFT", icon, "TOPLEFT", 0, 0 )
				frame:Point( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0 )
			end
		end	

		local function PetTalentButtons(self, first, i)
			local button = _G["PlayerTalentFramePetPanelTalent"..i]
			local icon = _G["PlayerTalentFramePetPanelTalent"..i.."IconTexture"]

			if first then
				button:StripTextures()
			end
			
			if button.Rank then
				button.Rank:SetFont(FONT, 12, FONTFLAG)
				button.Rank:ClearAllPoints()
				button.Rank:SetPoint("BOTTOMRIGHT")
			end
			
			if icon then
				button:StyleButton()
				button.SetHighlightTexture = E.dummy
				button.SetPushedTexture = E.dummy
				button:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
				button:GetPushedTexture():SetTexCoord(.08, .92, .08, .92)
				button:GetHighlightTexture():SetAllPoints(icon)
				button:GetPushedTexture():SetAllPoints(icon)
				
				icon:SetTexCoord(.08, .92, .08, .92)
				icon:ClearAllPoints()
				icon:SetAllPoints()
				button:SetFrameLevel(button:GetFrameLevel() +1)
				button:CreateBackdrop("Default", true)
			end
		end	

		PetInfoIcon(nil, true)
		PetHeaderIcon(nil, true)
		for i=1,GetNumTalents(1,false,true) do
			PetTalentButtons(nil,true,i)
		end

	end

	if addon == "Blizzard_GlyphUI" and C["skin"].glyph == true then

		--GLYPHS TAB
		GlyphFrameSparkleFrame:CreateBackdrop("Default")
		GlyphFrameSparkleFrame.backdrop:Point( "TOPLEFT", GlyphFrameSparkleFrame, "TOPLEFT", 3, -3 )
		GlyphFrameSparkleFrame.backdrop:Point( "BOTTOMRIGHT", GlyphFrameSparkleFrame, "BOTTOMRIGHT", -3, 3 )
		SkinEditBox(GlyphFrameSearchBox)
		SkinDropDownBox(GlyphFrameFilterDropDown, 212)
		
		GlyphFrameBackground:SetParent(GlyphFrameSparkleFrame)
		GlyphFrameBackground:SetPoint("TOPLEFT", 4, -4)
		GlyphFrameBackground:SetPoint("BOTTOMRIGHT", -4, 4)
		
		for i=1, 9 do
			_G["GlyphFrameGlyph"..i]:SetFrameLevel(_G["GlyphFrameGlyph"..i]:GetFrameLevel() + 5)
		end
		
		for i=1, 3 do
			_G["GlyphFrameHeader"..i]:StripTextures()
		end

		local function Glyphs(self, first, i)
			local button = _G["GlyphFrameScrollFrameButton"..i]
			local icon = _G["GlyphFrameScrollFrameButton"..i.."Icon"]

			if first then
				button:StripTextures()
			end

			if icon then
				icon:SetTexCoord(.08, .92, .08, .92)
				SkinButton(button)
			end
		end

		for i=1, 10 do
			Glyphs(nil, true, i)
		end

		GlyphFrameClearInfoFrameIcon:SetTexCoord(.08, .92, .08, .92)
		GlyphFrameClearInfoFrameIcon:ClearAllPoints()
		GlyphFrameClearInfoFrameIcon:Point("TOPLEFT", 2, -2)
		GlyphFrameClearInfoFrameIcon:Point("BOTTOMRIGHT", -2, 2)
		
		GlyphFrameClearInfoFrame:CreateBackdrop("Default", true)
		GlyphFrameClearInfoFrame.backdrop:SetAllPoints()
		GlyphFrameClearInfoFrame:StyleButton()
		GlyphFrameClearInfoFrame:Size(25, 25)
		
		SkinScrollBar(GlyphFrameScrollFrameScrollBar)

		local StripAllTextures = {
			"GlyphFrameScrollFrame",
			"GlyphFrameSideInset",
			"GlyphFrameScrollFrameScrollChild",
		}

		for _, object in pairs(StripAllTextures) do
			_G[object]:StripTextures()
		end

	end
	
	--Auction House
	if addon == "Blizzard_AuctionUI" and C["skin"].auctionhouse == true then
		SkinCloseButton(AuctionFrameCloseButton)
		AuctionFrame:StripTextures(true)
		AuctionFrame:SetTemplate("Transparent")
		AuctionFrame:CreateShadow("Default")
		
		BrowseFilterScrollFrame:StripTextures()
		BrowseScrollFrame:StripTextures()
		AuctionsScrollFrame:StripTextures()
		BidScrollFrame:StripTextures()
		
		SkinDropDownBox(BrowseDropDown)
		SkinDropDownBox(PriceDropDown)
		SkinDropDownBox(DurationDropDown)
		
		SkinCheckBox(IsUsableCheckButton)
		SkinCheckBox(ShowOnPlayerCheckButton)
		
		--Dress Up Frame
		AuctionDressUpFrame:StripTextures()
		AuctionDressUpFrame:SetTemplate("Transparent")
		AuctionDressUpFrame:Point("TOPLEFT", AuctionFrame, "TOPRIGHT", 2, 0)
		SkinButton(AuctionDressUpFrameResetButton)
		AuctionDressUpFrameCloseButton:StripTextures()
		AuctionDressUpFrameCloseButton:SetNormalTexture(AuctionFrameCloseButton:GetNormalTexture():GetTexture())
		AuctionDressUpFrameCloseButton:SetPushedTexture(AuctionFrameCloseButton:GetPushedTexture():GetTexture())
		AuctionDressUpFrameCloseButton:SetHighlightTexture(AuctionFrameCloseButton:GetHighlightTexture():GetTexture())
		AuctionDressUpFrameCloseButton:SetDisabledTexture(AuctionFrameCloseButton:GetDisabledTexture():GetTexture())
		
		SkinRotateButton(AuctionDressUpModelRotateLeftButton)
		SkinRotateButton(AuctionDressUpModelRotateRightButton)
		AuctionDressUpModelRotateRightButton:Point("TOPLEFT", AuctionDressUpModelRotateLeftButton, "TOPRIGHT", 4, 0)
		
		--Progress Frame
		AuctionProgressFrame:StripTextures()
		AuctionProgressFrame:SetTemplate("Transparent")
		AuctionProgressFrame:CreateShadow("Default")
		AuctionProgressFrameCancelButton:StyleButton()
		AuctionProgressFrameCancelButton:SetTemplate("Default")
		AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
		AuctionProgressFrameCancelButton:GetNormalTexture():ClearAllPoints()
		AuctionProgressFrameCancelButton:GetNormalTexture():Point("TOPLEFT", 2, -2)
		AuctionProgressFrameCancelButton:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
		AuctionProgressFrameCancelButton:GetNormalTexture():SetTexCoord(0.67, 0.37, 0.61, 0.26)
		AuctionProgressFrameCancelButton:Size(28, 28)
		AuctionProgressFrameCancelButton:Point("LEFT", AuctionProgressBar, "RIGHT", 8, 0)
		
		AuctionProgressBarIcon:SetTexCoord(0.67, 0.37, 0.61, 0.26)
		
		local backdrop = CreateFrame("Frame", nil, AuctionProgressBarIcon:GetParent())
		backdrop:Point("TOPLEFT", AuctionProgressBarIcon, "TOPLEFT", -2, 2)
		backdrop:Point("BOTTOMRIGHT", AuctionProgressBarIcon, "BOTTOMRIGHT", 2, -2)
		backdrop:SetTemplate("Default")
		AuctionProgressBarIcon:SetParent(backdrop)
		
		AuctionProgressBarText:ClearAllPoints()
		AuctionProgressBarText:SetPoint("CENTER")
		
		AuctionProgressBar:StripTextures()
		AuctionProgressBar:CreateBackdrop("Default")
		AuctionProgressBar:SetStatusBarTexture(C["media"].normTex)
		AuctionProgressBar:SetStatusBarColor(1, 1, 0)
		
		SkinNextPrevButton(BrowseNextPageButton)
		SkinNextPrevButton(BrowsePrevPageButton)
		
		local buttons = {
			"BrowseBidButton",
			"BidBidButton",
			"BrowseBuyoutButton",
			"BidBuyoutButton",
			"BrowseCloseButton",
			"BidCloseButton",
			"BrowseSearchButton",
			"AuctionsCreateAuctionButton",
			"AuctionsCancelAuctionButton",
			"AuctionsCloseButton",
			"BrowseResetButton",
			"AuctionsStackSizeMaxButton",
			"AuctionsNumStacksMaxButton",
		}
		
		for _, button in pairs(buttons) do
			SkinButton(_G[button])
		end
		
		--Fix Button Positions
		AuctionsCloseButton:Point("BOTTOMRIGHT", AuctionFrameAuctions, "BOTTOMRIGHT", 66, 10)
		AuctionsCancelAuctionButton:Point("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)
		BidBuyoutButton:Point("RIGHT", BidCloseButton, "LEFT", -4, 0)
		BidBidButton:Point("RIGHT", BidBuyoutButton, "LEFT", -4, 0)
		BrowseBuyoutButton:Point("RIGHT", BrowseCloseButton, "LEFT", -4, 0)
		BrowseBidButton:Point("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)		
		AuctionsItemButton:StripTextures()
		AuctionsItemButton:StyleButton()
		AuctionsItemButton:SetTemplate("Default", true)
		BrowseResetButton:Point("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 81, -74)
		BrowseSearchButton:Point("TOPRIGHT", AuctionFrameBrowse, "TOPRIGHT", 25, -34)
		
		AuctionsItemButton:SetScript("OnUpdate", function()
			if AuctionsItemButton:GetNormalTexture() then
				AuctionsItemButton:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
				AuctionsItemButton:GetNormalTexture():ClearAllPoints()
				AuctionsItemButton:GetNormalTexture():Point("TOPLEFT", 2, -2)
				AuctionsItemButton:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
			end
		end)
		
		local sorttabs = {
			"BrowseQualitySort",
			"BrowseLevelSort",
			"BrowseDurationSort",
			"BrowseHighBidderSort",
			"BrowseCurrentBidSort",
			"BidQualitySort",
			"BidLevelSort",
			"BidDurationSort",
			"BidBuyoutSort",
			"BidStatusSort",
			"BidBidSort",
			"AuctionsQualitySort",
			"AuctionsDurationSort",
			"AuctionsHighBidderSort",
			"AuctionsBidSort",
		}
		
		for _, sorttab in pairs(sorttabs) do
			_G[sorttab.."Left"]:Kill()
			_G[sorttab.."Middle"]:Kill()
			_G[sorttab.."Right"]:Kill()
		end
		
		for i=1, 3 do
			SkinTab(_G["AuctionFrameTab"..i])
		end
		
		for i=1, NUM_FILTERS_TO_DISPLAY do
			local tab = _G["AuctionFilterButton"..i]
			tab:StripTextures()
			tab:StyleButton()
		end
		
		local editboxs = {
			"BrowseName",
			"BrowseMinLevel",
			"BrowseMaxLevel",
			"BrowseBidPriceGold",
			"BrowseBidPriceSilver",
			"BrowseBidPriceCopper",
			"BidBidPriceGold",
			"BidBidPriceSilver",
			"BidBidPriceCopper",
			"AuctionsStackSizeEntry",
			"AuctionsNumStacksEntry",
			"StartPriceGold",
			"StartPriceSilver",
			"StartPriceCopper",
			"BuyoutPriceGold",
			"BuyoutPriceSilver",
			"BuyoutPriceCopper"			
		}
		
		for _, editbox in pairs(editboxs) do
			SkinEditBox(_G[editbox])
			_G[editbox]:SetTextInsets(1, 1, -1, 1)
		end
		BrowseMaxLevel:Point("LEFT", BrowseMinLevel, "RIGHT", 8, 0)
		AuctionsStackSizeEntry.backdrop:SetAllPoints()
		AuctionsNumStacksEntry.backdrop:SetAllPoints()
		
		for i=1, NUM_BROWSE_TO_DISPLAY do
			local button = _G["BrowseButton"..i]
			local icon = _G["BrowseButton"..i.."Item"]
			
			_G["BrowseButton"..i.."ItemIconTexture"]:SetTexCoord(.08, .92, .08, .92)
			_G["BrowseButton"..i.."ItemIconTexture"]:ClearAllPoints()
			_G["BrowseButton"..i.."ItemIconTexture"]:Point("TOPLEFT", 2, -2)
			_G["BrowseButton"..i.."ItemIconTexture"]:Point("BOTTOMRIGHT", -2, 2)
			
			icon:StyleButton()
			--TODO: Find a better method to ensure that the icon:GetNormalTexture doesn't return after clicking
			icon:HookScript("OnUpdate", function() icon:GetNormalTexture():Kill() end)
			
			icon:CreateBackdrop("Default")
			icon.backdrop:SetAllPoints()

			button:StripTextures()
			button:StyleButton()
			_G["BrowseButton"..i.."Highlight"] = button:GetHighlightTexture()
			button:GetHighlightTexture():ClearAllPoints()
			button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
			button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
			button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())
		end
		
		for i=1, NUM_AUCTIONS_TO_DISPLAY do
			local button = _G["AuctionsButton"..i]
			local icon = _G["AuctionsButton"..i.."Item"]
			
			_G["AuctionsButton"..i.."ItemIconTexture"]:SetTexCoord(.08, .92, .08, .92)
			_G["AuctionsButton"..i.."ItemIconTexture"].SetTexCoord = E.dummy
			_G["AuctionsButton"..i.."ItemIconTexture"]:ClearAllPoints()
			_G["AuctionsButton"..i.."ItemIconTexture"]:Point("TOPLEFT", 2, -2)
			_G["AuctionsButton"..i.."ItemIconTexture"]:Point("BOTTOMRIGHT", -2, 2)
			
			icon:StyleButton()
			--TODO: Find a better method to ensure that the icon:GetNormalTexture doesn't return after clicking
			icon:HookScript("OnUpdate", function() icon:GetNormalTexture():Kill() end)
			
			icon:CreateBackdrop("Default")
			icon.backdrop:SetAllPoints()

			button:StripTextures()
			button:StyleButton()
			_G["AuctionsButton"..i.."Highlight"] = button:GetHighlightTexture()
			button:GetHighlightTexture():ClearAllPoints()
			button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
			button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
			button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())		
		end
		
		for i=1, NUM_BIDS_TO_DISPLAY do
			local button = _G["BidButton"..i]
			local icon = _G["BidButton"..i.."Item"]
			
			_G["BidButton"..i.."ItemIconTexture"]:SetTexCoord(.08, .92, .08, .92)
			_G["BidButton"..i.."ItemIconTexture"]:ClearAllPoints()
			_G["BidButton"..i.."ItemIconTexture"]:Point("TOPLEFT", 2, -2)
			_G["BidButton"..i.."ItemIconTexture"]:Point("BOTTOMRIGHT", -2, 2)
			
			icon:StyleButton()
			icon:HookScript("OnUpdate", function() icon:GetNormalTexture():Kill() end)
			
			icon:CreateBackdrop("Default")
			icon.backdrop:SetAllPoints()

			button:StripTextures()
			button:StyleButton()
			_G["BidButton"..i.."Highlight"] = button:GetHighlightTexture()
			button:GetHighlightTexture():ClearAllPoints()
			button:GetHighlightTexture():Point("TOPLEFT", icon, "TOPRIGHT", 2, 0)
			button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
			button:GetPushedTexture():SetAllPoints(button:GetHighlightTexture())			
		end
		
		--[[for i=1, AuctionFrameBrowse:GetNumRegions() do 
			local region = select(i, AuctionFrameBrowse:GetRegions());
			if region:GetObjectType() == "FontString" then 
				print(region:GetText(), region:GetName()) 
			end 
		end]]
		
		--Custom Backdrops
		AuctionFrameBrowse.bg1 = CreateFrame("Frame", nil, AuctionFrameBrowse)
		AuctionFrameBrowse.bg1:SetTemplate("Default")
		AuctionFrameBrowse.bg1:Point("TOPLEFT", 20, -103)
		AuctionFrameBrowse.bg1:Point("BOTTOMRIGHT", -575, 40)
		BrowseNoResultsText:SetParent(AuctionFrameBrowse.bg1)
		BrowseSearchCountText:SetParent(AuctionFrameBrowse.bg1)
		BrowseFilterScrollFrame:Height(300) --Adjust scrollbar height a little off

		AuctionFrameBrowse.bg2 = CreateFrame("Frame", nil, AuctionFrameBrowse)
		AuctionFrameBrowse.bg2:SetTemplate("Default")
		AuctionFrameBrowse.bg2:Point("TOPLEFT", AuctionFrameBrowse.bg1, "TOPRIGHT", 4, 0)
		AuctionFrameBrowse.bg2:Point("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 40)
		BrowseScrollFrame:Height(300) --Adjust scrollbar height a little off
		
		AuctionFrameBid.bg = CreateFrame("Frame", nil, AuctionFrameBid)
		AuctionFrameBid.bg:SetTemplate("Default")
		AuctionFrameBid.bg:Point("TOPLEFT", 22, -72)
		AuctionFrameBid.bg:Point("BOTTOMRIGHT", 66, 39)
		BidScrollFrame:Height(332)	

		AuctionsScrollFrame:Height(336)	
		AuctionFrameAuctions.bg1 = CreateFrame("Frame", nil, AuctionFrameAuctions)
		AuctionFrameAuctions.bg1:SetTemplate("Default")
		AuctionFrameAuctions.bg1:Point("TOPLEFT", 15, -70)
		AuctionFrameAuctions.bg1:Point("BOTTOMRIGHT", -545, 35)  
		AuctionFrameAuctions.bg1:SetFrameLevel(AuctionFrameAuctions.bg1:GetFrameLevel() - 2)	
		
		AuctionFrameAuctions.bg2 = CreateFrame("Frame", nil, AuctionFrameAuctions)
		AuctionFrameAuctions.bg2:SetTemplate("Default")
		AuctionFrameAuctions.bg2:Point("TOPLEFT", AuctionFrameAuctions.bg1, "TOPRIGHT", 3, 0)
		AuctionFrameAuctions.bg2:Point("BOTTOMRIGHT", AuctionFrame, -8, 35)  
		AuctionFrameAuctions.bg2:SetFrameLevel(AuctionFrameAuctions.bg2:GetFrameLevel() - 2)		
	end
	
	--BarberShop
	if addon == "Blizzard_BarbershopUI" and C["skin"].barber == true then
		local buttons = {
			"BarberShopFrameOkayButton",
			"BarberShopFrameCancelButton",
			"BarberShopFrameResetButton",
		}
		BarberShopFrameOkayButton:Point("RIGHT", BarberShopFrameSelector4, "BOTTOM", 2, -50)
		
		for i = 1, #buttons do
			_G[buttons[i]]:StripTextures()
			SkinButton(_G[buttons[i]])
		end
		

		for i = 1, 4 do
			local f = _G["BarberShopFrameSelector"..i]
			local f2 = _G["BarberShopFrameSelector"..i-1]
			SkinNextPrevButton(_G["BarberShopFrameSelector"..i.."Prev"])
			SkinNextPrevButton(_G["BarberShopFrameSelector"..i.."Next"])
			
			if i ~= 1 then
				f:ClearAllPoints()
				f:Point("TOP", f2, "BOTTOM", 0, -3)			
			end
			
			if f then
				f:StripTextures()
			end
		end
		
		BarberShopFrameSelector1:ClearAllPoints()
		BarberShopFrameSelector1:Point("TOP", 0, -12)
		
		BarberShopFrameResetButton:ClearAllPoints()
		BarberShopFrameResetButton:Point("BOTTOM", 0, 12)
	
		BarberShopFrame:StripTextures()
		BarberShopFrame:SetTemplate("Transparent")
		BarberShopFrame:Size(BarberShopFrame:GetWidth() - 30, BarberShopFrame:GetHeight() - 56)
		
		BarberShopFrameMoneyFrame:StripTextures()
		BarberShopFrameMoneyFrame:CreateBackdrop()
		BarberShopFrameBackground:Kill()
		
		BarberShopBannerFrameBGTexture:Kill()
		BarberShopBannerFrame:Kill()
		
		BarberShopAltFormFrameBorder:StripTextures()
		BarberShopAltFormFrame:Point( "BOTTOM", BarberShopFrame, "TOP", 0, 5 )
		BarberShopAltFormFrame:StripTextures()
		BarberShopAltFormFrame:CreateBackdrop("Transparent")
	end
	
	--Macro Frame
	if addon == "Blizzard_MacroUI" and C["skin"].macro == true then
		SkinCloseButton(MacroFrameCloseButton)
		
		MacroFrame:Width(360)
		
		local buttons = {
			"MacroDeleteButton",
			"MacroNewButton",
			"MacroExitButton",
			"MacroEditButton",
			"MacroFrameTab1",
			"MacroFrameTab2",
			"MacroPopupOkayButton",
			"MacroPopupCancelButton",
		}
		
		for i = 1, #buttons do
			_G[buttons[i]]:StripTextures()
			SkinButton(_G[buttons[i]])
		end
		
		for i = 1, 2 do
			tab = _G[format("MacroFrameTab%s", i)]
			tab:Height(22)
		end
		MacroFrameTab1:Point("TOPLEFT", MacroFrame, "TOPLEFT", 85, -39)
		MacroFrameTab2:Point("LEFT", MacroFrameTab1, "RIGHT", 4, 0)
		
	
		-- General
		MacroFrame:StripTextures()
		MacroFrame:SetTemplate("Transparent")
		MacroFrameTextBackground:StripTextures()
		MacroFrameTextBackground:CreateBackdrop()
		MacroButtonScrollFrame:CreateBackdrop()
		MacroPopupFrame:StripTextures()
		MacroPopupFrame:SetTemplate("Transparent")
		MacroPopupScrollFrame:StripTextures()
		MacroPopupScrollFrame:CreateBackdrop()
		MacroPopupScrollFrame.backdrop:Point("TOPLEFT", 51, 2)
		MacroPopupScrollFrame.backdrop:Point("BOTTOMRIGHT", -4, 4)
		MacroPopupEditBox:CreateBackdrop()
		MacroPopupEditBox:StripTextures()
		
		--Reposition edit button
		MacroEditButton:ClearAllPoints()
		MacroEditButton:Point("BOTTOMLEFT", MacroFrameSelectedMacroButton, "BOTTOMRIGHT", 10, 0)
		
		-- Regular scroll bar
		SkinScrollBar(MacroButtonScrollFrame)
		
		MacroPopupFrame:HookScript("OnShow", function(self)
			self:ClearAllPoints()
			self:Point("TOPLEFT", MacroFrame, "TOPRIGHT", 5, -2)
		end)
		
		-- Big icon
		MacroFrameSelectedMacroButton:StripTextures()
		MacroFrameSelectedMacroButton:StyleButton(true)
		MacroFrameSelectedMacroButton:GetNormalTexture():SetTexture(nil)
		MacroFrameSelectedMacroButton:SetTemplate("Default")
		MacroFrameSelectedMacroButtonIcon:SetTexCoord(.08, .92, .08, .92)
		MacroFrameSelectedMacroButtonIcon:ClearAllPoints()
		MacroFrameSelectedMacroButtonIcon:Point("TOPLEFT", 2, -2)
		MacroFrameSelectedMacroButtonIcon:Point("BOTTOMRIGHT", -2, 2)
		
		-- temporarily moving this text
		MacroFrameCharLimitText:ClearAllPoints()
		MacroFrameCharLimitText:Point("BOTTOM", MacroFrameTextBackground, 0, -70)
		
		-- Skin all buttons
		for i = 1, MAX_ACCOUNT_MACROS do
			local b = _G["MacroButton"..i]
			local t = _G["MacroButton"..i.."Icon"]
			local pb = _G["MacroPopupButton"..i]
			local pt = _G["MacroPopupButton"..i.."Icon"]
			
			if b then
				b:StripTextures()
				b:StyleButton(true)
				
				b:SetTemplate("Default", true)
			end
			
			if t then
				t:SetTexCoord(.08, .92, .08, .92)
				t:ClearAllPoints()
				t:Point("TOPLEFT", 2, -2)
				t:Point("BOTTOMRIGHT", -2, 2)
			end

			if pb then
				pb:StripTextures()
				pb:StyleButton(true)
				
				pb:SetTemplate("Default")					
			end
			
			if pt then
				pt:SetTexCoord(.08, .92, .08, .92)
				pt:ClearAllPoints()
				pt:Point("TOPLEFT", 2, -2)
				pt:Point("BOTTOMRIGHT", -2, 2)
			end
		end
	end		
	
	if addon == "Blizzard_DebugTools" and C["skin"].debug == true then
		local noscalemult = E.mult * C["general"].uiscale
		local bg = {
		  bgFile = C["media"].blank, 
		  edgeFile = C["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = noscalemult, 
		  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		}
		
		ScriptErrorsFrame:SetBackdrop(bg)
		ScriptErrorsFrame:SetBackdropColor(unpack(C.media.backdropfadecolor))
		ScriptErrorsFrame:SetBackdropBorderColor(unpack(C.media.bordercolor))	

		EventTraceFrame:SetTemplate("Transparent")
		
		local texs = {
			"TopLeft",
			"TopRight",
			"Top",
			"BottomLeft",
			"BottomRight",
			"Bottom",
			"Left",
			"Right",
			"TitleBG",
			"DialogBG",
		}
		
		for i=1, #texs do
			_G["ScriptErrorsFrame"..texs[i]]:SetTexture(nil)
			_G["EventTraceFrame"..texs[i]]:SetTexture(nil)
		end
		
		local bg = {
		  bgFile = C["media"].normTex, 
		  edgeFile = C["media"].blank, 
		  tile = false, tileSize = 0, edgeSize = noscalemult, 
		  insets = { left = -noscalemult, right = -noscalemult, top = -noscalemult, bottom = -noscalemult}
		}
		
		for i=1, ScriptErrorsFrame:GetNumChildren() do
			local child = select(i, ScriptErrorsFrame:GetChildren())
			if child:GetObjectType() == "Button" and not child:GetName() then
				
				SkinButton(child)
				child:SetBackdrop(bg)
				child:SetBackdropColor(unpack(C.media.backdropcolor))
				child:SetBackdropBorderColor(unpack(C.media.bordercolor))	
			end
		end	
	end

	if addon == "Blizzard_TrainerUI" and C["skin"].trainer == true then

		--Class Trainer Frame
		local StripAllTextures = {
			"ClassTrainerFrame",
			"ClassTrainerScrollFrameScrollChild",
			"ClassTrainerFrameSkillStepButton",
			"ClassTrainerFrameBottomInset",
		}

		local buttons = {
			"ClassTrainerTrainButton",
		}

		local KillTextures = {
			"ClassTrainerFrameInset",
			"ClassTrainerFramePortrait",
			"ClassTrainerScrollFrameScrollBarBG",
			"ClassTrainerScrollFrameScrollBarTop",
			"ClassTrainerScrollFrameScrollBarBottom",
			"ClassTrainerScrollFrameScrollBarMiddle",
		}

		for i=1,8 do
			_G["ClassTrainerScrollFrameButton"..i]:StripTextures()
			_G["ClassTrainerScrollFrameButton"..i]:StyleButton()
			_G["ClassTrainerScrollFrameButton"..i.."Icon"]:SetTexCoord(.08, .92, .08, .92)
			_G["ClassTrainerScrollFrameButton"..i]:CreateBackdrop()
			_G["ClassTrainerScrollFrameButton"..i].backdrop:Point("TOPLEFT", _G["ClassTrainerScrollFrameButton"..i.."Icon"], "TOPLEFT", -2, 2)
			_G["ClassTrainerScrollFrameButton"..i].backdrop:Point("BOTTOMRIGHT", _G["ClassTrainerScrollFrameButton"..i.."Icon"], "BOTTOMRIGHT", 2, -2)
			_G["ClassTrainerScrollFrameButton"..i.."Icon"]:SetParent(_G["ClassTrainerScrollFrameButton"..i].backdrop)
			
			_G["ClassTrainerScrollFrameButton"..i].selectedTex:SetTexture(1, 1, 1, 0.3)
			_G["ClassTrainerScrollFrameButton"..i].selectedTex:ClearAllPoints()
			_G["ClassTrainerScrollFrameButton"..i].selectedTex:Point("TOPLEFT", 2, -2)
			_G["ClassTrainerScrollFrameButton"..i].selectedTex:Point("BOTTOMRIGHT", -2, 2)
		end

		for _, object in pairs(StripAllTextures) do
			_G[object]:StripTextures()
		end

		for _, texture in pairs(KillTextures) do
			_G[texture]:Kill()
		end

		for i = 1, #buttons do
			_G[buttons[i]]:StripTextures()
			SkinButton(_G[buttons[i]])
		end
		
		SkinDropDownBox(ClassTrainerFrameFilterDropDown, 155)

		ClassTrainerFrame:CreateBackdrop("Transparent")
		ClassTrainerFrame.backdrop:Point("TOPLEFT", ClassTrainerFrame, "TOPLEFT")
		ClassTrainerFrame.backdrop:Point("BOTTOMRIGHT", ClassTrainerFrame, "BOTTOMRIGHT")
		SkinCloseButton(ClassTrainerFrameCloseButton,ClassTrainerFrame)
		ClassTrainerFrameSkillStepButton.icon:SetTexCoord(.08, .92, .08, .92)
		ClassTrainerFrameSkillStepButton:CreateBackdrop("Default")
		ClassTrainerFrameSkillStepButton.backdrop:Point("TOPLEFT", ClassTrainerFrameSkillStepButton.icon, "TOPLEFT", -2, 2)
		ClassTrainerFrameSkillStepButton.backdrop:Point("BOTTOMRIGHT", ClassTrainerFrameSkillStepButton.icon, "BOTTOMRIGHT", 2, -2)
		ClassTrainerFrameSkillStepButton.icon:SetParent(ClassTrainerFrameSkillStepButton.backdrop)
		
		ClassTrainerStatusBar:StripTextures()
		ClassTrainerStatusBar:SetStatusBarTexture(C["media"].normTex)
		ClassTrainerStatusBar:CreateBackdrop("Default")
	end

	-- Socketing UI
	if addon == "Blizzard_ItemSocketingUI" and C["skin"].socket == true then
		ItemSocketingFrame:StripTextures()
		ItemSocketingFrame:SetTemplate("Transparent")
		ItemSocketingScrollFrame:StripTextures()
		ItemSocketingScrollFrame:CreateBackdrop("Transparent")

		for i = 1, MAX_NUM_SOCKETS  do
			local button = _G["ItemSocketingSocket"..i]
			local button_bracket = _G["ItemSocketingSocket"..i.."BracketFrame"]
			local button_bg = _G["ItemSocketingSocket"..i.."Background"]
			local button_icon = _G["ItemSocketingSocket"..i.."IconTexture"]
			button:StripTextures()
			button:StyleButton(false)
			button:SetTemplate("Default", true)
			button_bracket:Kill()
			button_bg:Kill()
			button_icon:SetTexCoord(.08, .92, .08, .92)
			button_icon:ClearAllPoints()
			button_icon:Point("TOPLEFT", 2, -2)
			button_icon:Point("BOTTOMRIGHT", -2, 2)
			ItemSocketingFrame:HookScript("OnUpdate", function(self)
				gemColor = GetSocketTypes(i)
				local color = GEM_TYPE_INFO[gemColor]
				button:SetBackdropColor(color.r, color.g, color.b, 0.15)
				button:SetBackdropBorderColor(color.r, color.g, color.b)
			end)
		end
		
		ItemSocketingFramePortrait:Kill()
		ItemSocketingSocketButton:ClearAllPoints()
		ItemSocketingSocketButton:Point("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -5, 5)
		SkinButton(ItemSocketingSocketButton)
		SkinCloseButton(ItemSocketingCloseButton)
	end
	
	-- stuff not in Blizzard load-on-demand
	if addon == "ElvUI" then
	
		--Achievement Popup Frames
		if C["skin"].achievement_popup == true then		
			local function SkinAchievePopUp()
				for i = 1, MAX_ACHIEVEMENT_ALERTS do
					local frame = _G["AchievementAlertFrame"..i]
					
					if frame then
						frame:SetAlpha(1)
						frame.SetAlpha = E.dummy
						if not frame.backdrop then
							frame:CreateBackdrop("Default")
							frame.backdrop:Point("TOPLEFT", _G[frame:GetName().."Background"], "TOPLEFT", -2, -6)
							frame.backdrop:Point("BOTTOMRIGHT", _G[frame:GetName().."Background"], "BOTTOMRIGHT", -2, 6)		
						end
						
						-- Background
						_G["AchievementAlertFrame"..i.."Background"]:SetTexture(nil)

						_G["AchievementAlertFrame"..i.."Glow"]:Kill()
						_G["AchievementAlertFrame"..i.."Shine"]:Kill()
						
						-- Text
						_G["AchievementAlertFrame"..i.."Unlocked"]:SetFont(C.media.font, 12)
						_G["AchievementAlertFrame"..i.."Unlocked"]:SetTextColor(1, 1, 1)
						_G["AchievementAlertFrame"..i.."Name"]:SetFont(C.media.font, 14)

						-- Icon
						_G["AchievementAlertFrame"..i.."IconTexture"]:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						_G["AchievementAlertFrame"..i.."IconOverlay"]:Kill()
						
						_G["AchievementAlertFrame"..i.."IconTexture"]:ClearAllPoints()
						_G["AchievementAlertFrame"..i.."IconTexture"]:Point("LEFT", frame, 7, 0)
						
						if not _G["AchievementAlertFrame"..i.."IconTexture"].b then
							_G["AchievementAlertFrame"..i.."IconTexture"].b = CreateFrame("Frame", nil, _G["AchievementAlertFrame"..i])
							_G["AchievementAlertFrame"..i.."IconTexture"].b:SetFrameLevel(0)
							_G["AchievementAlertFrame"..i.."IconTexture"].b:SetTemplate("Default")
							_G["AchievementAlertFrame"..i.."IconTexture"].b:Point("TOPLEFT", _G["AchievementAlertFrame"..i.."IconTexture"], "TOPLEFT", -2, 2)
							_G["AchievementAlertFrame"..i.."IconTexture"].b:Point("BOTTOMRIGHT", _G["AchievementAlertFrame"..i.."IconTexture"], "BOTTOMRIGHT", 2, -2)
						end
					end
				end
			end
			hooksecurefunc("AchievementAlertFrame_FixAnchors", SkinAchievePopUp)
			
			function SkinDungeonPopUP()
				for i = 1, DUNGEON_COMPLETION_MAX_REWARDS do
					local frame = _G["DungeonCompletionAlertFrame"..i]
					if frame then
						frame:SetAlpha(1)
						frame.SetAlpha = E.dummy
						if not frame.backdrop then
							frame:CreateBackdrop("Default")
							frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
							frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)		
						end
						
						-- Background
						for i=1, frame:GetNumRegions() do
							local region = select(i, frame:GetRegions())
							if region:GetObjectType() == "Texture" then
								if region:GetTexture() == "Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST" then
									region:Kill()
								end
							end
						end
						
						_G["DungeonCompletionAlertFrame"..i.."Shine"]:Kill()
						_G["DungeonCompletionAlertFrame"..i.."GlowFrame"]:Kill()
						_G["DungeonCompletionAlertFrame"..i.."GlowFrame"].glow:Kill()
						
						-- Icon
						_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"]:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						
						_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"]:ClearAllPoints()
						_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"]:Point("LEFT", frame, 7, 0)
						
						if not _G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b then
							_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b = CreateFrame("Frame", nil, _G["DungeonCompletionAlertFrame"..i])
							_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b:SetFrameLevel(0)
							_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b:SetTemplate("Default")
							_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b:Point("TOPLEFT", _G["DungeonCompletionAlertFrame"..i.."DungeonTexture"], "TOPLEFT", -2, 2)
							_G["DungeonCompletionAlertFrame"..i.."DungeonTexture"].b:Point("BOTTOMRIGHT", _G["DungeonCompletionAlertFrame"..i.."DungeonTexture"], "BOTTOMRIGHT", 2, -2)
						end
					end
				end				
			end
			
			hooksecurefunc("DungeonCompletionAlertFrame_FixAnchors", SkinDungeonPopUP)
		end
		
		-- bg score frame
		if C["skin"].bgscore == true then	
			WorldStateScoreScrollFrame:StripTextures()
			WorldStateScoreFrame:StripTextures()
			WorldStateScoreFrame:SetTemplate("Transparent")
			SkinCloseButton(WorldStateScoreFrameCloseButton)
			WorldStateScoreFrameInset:Kill()
			SkinButton(WorldStateScoreFrameLeaveButton)
			
			for i = 1, WorldStateScoreScrollFrameScrollChildFrame:GetNumChildren() do
				local b = _G["WorldStateScoreButton"..i]
				b:StripTextures()
				b:StyleButton(false)
				b:SetTemplate("Default", true)
			end
			
			for i = 1, 3 do 
				SkinTab(_G["WorldStateScoreFrameTab"..i])
			end
		end
		
		-- Merchant Frame
		if C["skin"].merchant == true then	
			local frames = {
				"MerchantBuyBackItem",
				"MerchantFrame",
			}
			
			-- skin main frames
			for i = 1, #frames do
				_G[frames[i]]:StripTextures(true)
				_G[frames[i]]:CreateBackdrop("Transparent")
			end
			MerchantBuyBackItem.backdrop:Point("TOPLEFT", -6, 6)
			MerchantBuyBackItem.backdrop:Point("BOTTOMRIGHT", 6, -6)
			MerchantFrame.backdrop:Point("TOPLEFT", 6, 0)
			MerchantFrame.backdrop:Point("BOTTOMRIGHT", 0, 35)
			MerchantFrame.backdrop:Point("BOTTOMRIGHT", 0, 60)
			-- skin tabs
			for i= 1, 2 do
				SkinTab(_G["MerchantFrameTab"..i])
			end
			
			-- skin icons / merchant slots
			for i = 1, 12 do
				local b = _G["MerchantItem"..i.."ItemButton"]
				local t = _G["MerchantItem"..i.."ItemButtonIconTexture"]
				local item_bar = _G["MerchantItem"..i]
				item_bar:StripTextures(true)
				item_bar:CreateBackdrop("Default")
				
				b:StripTextures()
				b:StyleButton(false)
				b:SetTemplate("Default", true)
				b:Point("TOPLEFT", item_bar, "TOPLEFT", 4, -4)
				t:SetTexCoord(.08, .92, .08, .92)
				t:ClearAllPoints()
				t:Point("TOPLEFT", 2, -2)
				t:Point("BOTTOMRIGHT", -2, 2)
				
				_G["MerchantItem"..i.."MoneyFrame"]:ClearAllPoints()
				_G["MerchantItem"..i.."MoneyFrame"]:Point("BOTTOMLEFT", b, "BOTTOMRIGHT", 3, 0)
				
			end
			
			-- Skin buyback item frame + icon
			MerchantBuyBackItemItemButton:StripTextures()
			MerchantBuyBackItemItemButton:StyleButton(false)
			MerchantBuyBackItemItemButton:SetTemplate("Default", true)
			MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
			MerchantBuyBackItemItemButtonIconTexture:ClearAllPoints()
			MerchantBuyBackItemItemButtonIconTexture:Point("TOPLEFT", 2, -2)
			MerchantBuyBackItemItemButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)
		
			
			MerchantRepairItemButton:StyleButton(false)
			MerchantRepairItemButton:SetTemplate("Default", true)
			for i=1, MerchantRepairItemButton:GetNumRegions() do
				local region = select(i, MerchantRepairItemButton:GetRegions())
				if region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\MerchantFrame\\UI-Merchant-RepairIcons" then
					region:SetTexCoord(0.04, 0.24, 0.06, 0.5)
					region:ClearAllPoints()
					region:Point("TOPLEFT", 2, -2)
					region:Point("BOTTOMRIGHT", -2, 2)
				end
			end
			
			MerchantGuildBankRepairButton:StyleButton()
			MerchantGuildBankRepairButton:SetTemplate("Default", true)
			MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)
			MerchantGuildBankRepairButtonIcon:ClearAllPoints()
			MerchantGuildBankRepairButtonIcon:Point("TOPLEFT", 2, -2)
			MerchantGuildBankRepairButtonIcon:Point("BOTTOMRIGHT", -2, 2)
			
			MerchantRepairAllButton:StyleButton(false)
			MerchantRepairAllButton:SetTemplate("Default", true)
			MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
			MerchantRepairAllIcon:ClearAllPoints()
			MerchantRepairAllIcon:Point("TOPLEFT", 2, -2)
			MerchantRepairAllIcon:Point("BOTTOMRIGHT", -2, 2)
			
			-- Skin misc frames
			MerchantFrame:Width(360)
			SkinCloseButton(MerchantFrameCloseButton, MerchantFrame.backdrop)
			SkinNextPrevButton(MerchantNextPageButton)
			SkinNextPrevButton(MerchantPrevPageButton)
		end
		
		-- mail frame
		if C["skin"].mail == true then	
			MailFrame:StripTextures(true)
			MailFrame:CreateBackdrop("Transparent")
			MailFrame.backdrop:Point("TOPLEFT", 4, 0)
			MailFrame.backdrop:Point("BOTTOMRIGHT", 2, 74)
			MailFrame.backdrop:CreateShadow("Default")
			MailFrame:SetWidth(360)

			for i = 1, INBOXITEMS_TO_DISPLAY do
				local bg = _G["MailItem"..i]
				bg:StripTextures()
				bg:CreateBackdrop("Default")
				bg.backdrop:Point("TOPLEFT", 2, 1)
				bg.backdrop:Point("BOTTOMRIGHT", -2, 2)
				
				local b = _G["MailItem"..i.."Button"]
				b:StripTextures()
				b:SetTemplate("Default", true)
				b:StyleButton()

				local t = _G["MailItem"..i.."ButtonIcon"]
				t:SetTexCoord(.08, .92, .08, .92)
				t:ClearAllPoints()
				t:Point("TOPLEFT", 2, -2)
				t:Point("BOTTOMRIGHT", -2, 2)
			end
			
			SkinCloseButton(InboxCloseButton)
			SkinNextPrevButton(InboxPrevPageButton)
			SkinNextPrevButton(InboxNextPageButton)

			MailFrameTab1:StripTextures()
			MailFrameTab2:StripTextures()
			SkinTab(MailFrameTab1)
			SkinTab(MailFrameTab2)

			-- send mail
			SendMailScrollFrame:StripTextures(true)
			SendMailScrollFrame:SetTemplate("Default")

			SkinScrollBar(SendMailScrollFrameScrollBar)
			
			SkinEditBox(SendMailNameEditBox)
			SkinEditBox(SendMailSubjectEditBox)
			SkinEditBox(SendMailMoneyGold)
			SkinEditBox(SendMailMoneySilver)
			SkinEditBox(SendMailMoneyCopper)
			
			SendMailNameEditBox.backdrop:Point("BOTTOMRIGHT", 2, 0)
			SendMailSubjectEditBox.backdrop:Point("BOTTOMRIGHT", 2, 0)
			SendMailFrame:StripTextures()
			
			local function MailFrameSkin()
				for i = 1, ATTACHMENTS_MAX_SEND do				
					local b = _G["SendMailAttachment"..i]
					if not b.skinned then
						b:StripTextures()
						b:SetTemplate("Default", true)
						b:StyleButton()
						b.skinned = true
					end
					local t = b:GetNormalTexture()
					if t then
						t:SetTexCoord(.08, .92, .08, .92)
						t:ClearAllPoints()
						t:Point("TOPLEFT", 2, -2)
						t:Point("BOTTOMRIGHT", -2, 2)
					end
				end
			end
			hooksecurefunc("SendMailFrame_Update", MailFrameSkin)
			
			SkinButton(SendMailMailButton)
			SkinButton(SendMailCancelButton)
			
			-- open mail (cod)
			OpenMailFrame:StripTextures(true)
			OpenMailFrame:CreateBackdrop("Transparent")
			OpenMailFrame.backdrop:Point("TOPLEFT", 4, 0)
			OpenMailFrame.backdrop:Point("BOTTOMRIGHT", 2, 74)
			OpenMailFrame.backdrop:CreateShadow("Default")
			OpenMailFrame:SetWidth(360)
			
			SkinCloseButton(OpenMailCloseButton)
			SkinButton(OpenMailReportSpamButton)
			SkinButton(OpenMailReplyButton)
			SkinButton(OpenMailDeleteButton)
			SkinButton(OpenMailCancelButton)
			
			OpenMailScrollFrame:StripTextures(true)
			OpenMailScrollFrame:SetTemplate("Default")

			SkinScrollBar(OpenMailScrollFrameScrollBar)
			
			SendMailBodyEditBox:SetTextColor(1, 1, 1)
			OpenMailBodyText:SetTextColor(1, 1, 1)
			InvoiceTextFontNormal:SetTextColor(1, 1, 1)
			OpenMailArithmeticLine:Kill()
			
			OpenMailLetterButton:StripTextures()
			OpenMailLetterButton:SetTemplate("Default", true)
			OpenMailLetterButton:StyleButton()
			OpenMailLetterButtonIconTexture:SetTexCoord(.08, .92, .08, .92)						
			OpenMailLetterButtonIconTexture:ClearAllPoints()
			OpenMailLetterButtonIconTexture:Point("TOPLEFT", 2, -2)
			OpenMailLetterButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)
			
			OpenMailMoneyButton:StripTextures()
			OpenMailMoneyButton:SetTemplate("Default", true)
			OpenMailMoneyButton:StyleButton()
			OpenMailMoneyButtonIconTexture:SetTexCoord(.08, .92, .08, .92)						
			OpenMailMoneyButtonIconTexture:ClearAllPoints()
			OpenMailMoneyButtonIconTexture:Point("TOPLEFT", 2, -2)
			OpenMailMoneyButtonIconTexture:Point("BOTTOMRIGHT", -2, 2)
			
			for i = 1, ATTACHMENTS_MAX_SEND do				
				local b = _G["OpenMailAttachmentButton"..i]
				b:StripTextures()
				b:SetTemplate("Default", true)
				b:StyleButton()
				
				local t = _G["OpenMailAttachmentButton"..i.."IconTexture"]
				if t then
					t:SetTexCoord(.08, .92, .08, .92)
					t:ClearAllPoints()
					t:Point("TOPLEFT", 2, -2)
					t:Point("BOTTOMRIGHT", -2, 2)
				end				
			end
			
			OpenMailReplyButton:Point("RIGHT", OpenMailDeleteButton, "LEFT", -2, 0)
			OpenMailDeleteButton:Point("RIGHT", OpenMailCancelButton, "LEFT", -2, 0)
			SendMailMailButton:Point("RIGHT", SendMailCancelButton, "LEFT", -2, 0)

		end
		
		--Help Frame
		if C["skin"].help == true then	
			local frames = {
				"HelpFrameLeftInset",
				"HelpFrameMainInset",
				"HelpFrameKnowledgebase",
				"HelpFrameHeader",
				"HelpFrameKnowledgebaseErrorFrame",
			}
			
			local buttons = {
				"HelpFrameAccountSecurityOpenTicket",
				"HelpFrameReportLagLoot",
				"HelpFrameReportLagAuctionHouse",
				"HelpFrameReportLagMail",
				"HelpFrameReportLagMovement",
				"HelpFrameReportLagSpell",
				"HelpFrameReportLagChat",
				"HelpFrameReportAbuseOpenTicket",
				"HelpFrameOpenTicketHelpTopIssues",
				"HelpFrameOpenTicketHelpOpenTicket",
				"HelpFrameKnowledgebaseSearchButton",
				"HelpFrameKnowledgebaseNavBarHomeButton",
				"HelpFrameCharacterStuckStuck",
				"GMChatOpenLog",
				"HelpFrameTicketSubmit",
				"HelpFrameTicketCancel",
			}
			
			-- skin main frames
			for i = 1, #frames do
				_G[frames[i]]:StripTextures(true)
				_G[frames[i]]:CreateBackdrop("Default")
			end
			
			HelpFrameHeader:SetFrameLevel(HelpFrameHeader:GetFrameLevel() + 2)
			HelpFrameKnowledgebaseErrorFrame:SetFrameLevel(HelpFrameKnowledgebaseErrorFrame:GetFrameLevel() + 2)
			
			HelpFrameTicketScrollFrame:StripTextures()
			HelpFrameTicketScrollFrame:CreateBackdrop("Default")
			HelpFrameTicketScrollFrame.backdrop:Point("TOPLEFT", -4, 4)
			HelpFrameTicketScrollFrame.backdrop:Point("BOTTOMRIGHT", 6, -4)
			for i=1, HelpFrameTicket:GetNumChildren() do
				local child = select(i, HelpFrameTicket:GetChildren())
				if not child:GetName() then
					child:StripTextures()
				end
			end
			
			SkinScrollBar(HelpFrameKnowledgebaseScrollFrame2ScrollBar)
			
			-- skin sub buttons
			for i = 1, #buttons do
				_G[buttons[i]]:StripTextures(true)
				SkinButton(_G[buttons[i]], true)
				
				if _G[buttons[i]].text then
					_G[buttons[i]].text:ClearAllPoints()
					_G[buttons[i]].text:SetPoint("CENTER")
					_G[buttons[i]].text:SetJustifyH("CENTER")				
				end
			end
			
			-- skin main buttons
			for i = 1, 6 do
				local b = _G["HelpFrameButton"..i]
				SkinButton(b, true)
				b.text:ClearAllPoints()
				b.text:SetPoint("CENTER")
				b.text:SetJustifyH("CENTER")
			end	
			
			-- skin table options
			for i = 1, HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren() do
				local b = _G["HelpFrameKnowledgebaseScrollFrameButton"..i]
				b:StripTextures(true)
				SkinButton(b, true)
			end
			
			-- skin misc items
			HelpFrameKnowledgebaseSearchBox:ClearAllPoints()
			HelpFrameKnowledgebaseSearchBox:Point("TOPLEFT", HelpFrameMainInset, "TOPLEFT", 13, -10)
			HelpFrameKnowledgebaseNavBarOverlay:Kill()
			
			if E.IsPTRVersion() then
				HelpFrameKnowledgebaseNavBar:StripTextures()
			end
			
			HelpFrame:StripTextures(true)
			HelpFrame:CreateBackdrop("Transparent")
			SkinEditBox(HelpFrameKnowledgebaseSearchBox)
			SkinScrollBar(HelpFrameKnowledgebaseScrollFrameScrollBar)
			SkinCloseButton(HelpFrameCloseButton, HelpFrame.backdrop)	
			SkinCloseButton(HelpFrameKnowledgebaseErrorFrameCloseButton, HelpFrameKnowledgebaseErrorFrame.backdrop)
			
			--Hearth Stone Button
			HelpFrameCharacterStuckHearthstone:StyleButton()
			HelpFrameCharacterStuckHearthstone:SetTemplate("Default", true)
			HelpFrameCharacterStuckHearthstone.IconTexture:ClearAllPoints()
			HelpFrameCharacterStuckHearthstone.IconTexture:Point("TOPLEFT", 2, -2)
			HelpFrameCharacterStuckHearthstone.IconTexture:Point("BOTTOMRIGHT", -2, 2)
			HelpFrameCharacterStuckHearthstone.IconTexture:SetTexCoord(.08, .92, .08, .92)
			
			local function navButtonFrameLevel(self)
				for i=1, #self.navList do
					local navButton = self.navList[i]
					local lastNav = self.navList[i-1]
					if navButton and lastNav then
						navButton:SetFrameLevel(lastNav:GetFrameLevel() - 2)
					end
				end			
			end
			
			hooksecurefunc("NavBar_AddButton", function(self, buttonData)
				local navButton = self.navList[#self.navList]
				
				
				if not navButton.skinned then
					SkinButton(navButton, true)
					navButton.skinned = true
					
					navButton:HookScript("OnClick", function()
						navButtonFrameLevel(self)
					end)
				end
				
				navButtonFrameLevel(self)
			end)
			
			SkinButton(HelpFrameGM_ResponseNeedMoreHelp)
			SkinButton(HelpFrameGM_ResponseCancel)
			for i=1, HelpFrameGM_Response:GetNumChildren() do
				local child = select(i, HelpFrameGM_Response:GetChildren())
				if child and child:GetObjectType() == "Frame" and not child:GetName() then
					child:SetTemplate("Default")
				end
			end
		end
	
		--Trade Frame
		if C["skin"].trade == true then	
			TradeFrame:StripTextures(true)
			TradeFrame:CreateBackdrop("Transparent")
			TradeFrame.backdrop:Point("TOPLEFT", 10, -4)
			TradeFrame.backdrop:Point("BOTTOMRIGHT", -16, 35)
			SkinButton(TradeFrameTradeButton, true)
			SkinButton(TradeFrameCancelButton, true)
			SkinCloseButton(TradeFrameCloseButton, TradeFrame.backdrop)
			
			SkinEditBox(TradePlayerInputMoneyFrameGold)
			SkinEditBox(TradePlayerInputMoneyFrameSilver)
			SkinEditBox(TradePlayerInputMoneyFrameCopper)
			
			for i=1, 7 do
				local player = _G["TradePlayerItem"..i]
				local recipient = _G["TradeRecipientItem"..i]
				local player_button = _G["TradePlayerItem"..i.."ItemButton"]
				local recipient_button = _G["TradeRecipientItem"..i.."ItemButton"]
				local player_button_icon = _G["TradePlayerItem"..i.."ItemButtonIconTexture"]
				local recipient_button_icon = _G["TradeRecipientItem"..i.."ItemButtonIconTexture"]
				
				if player_button and recipient_button then
					player:StripTextures()
					recipient:StripTextures()
					player_button:StripTextures()
					recipient_button:StripTextures()
					
					player_button_icon:ClearAllPoints()
					player_button_icon:Point("TOPLEFT", player_button, "TOPLEFT", 2, -2)
					player_button_icon:Point("BOTTOMRIGHT", player_button, "BOTTOMRIGHT", -2, 2)
					player_button_icon:SetTexCoord(.08, .92, .08, .92)
					player_button:SetTemplate("Default", true)
					player_button:StyleButton()
					player_button.bg = CreateFrame("Frame", nil, player_button)
					player_button.bg:SetTemplate("Default")
					player_button.bg:SetPoint("TOPLEFT", player_button, "TOPRIGHT", 4, 0)
					player_button.bg:SetPoint("BOTTOMRIGHT", _G["TradePlayerItem"..i.."NameFrame"], "BOTTOMRIGHT", 0, 14)
					player_button.bg:SetFrameLevel(player_button:GetFrameLevel() - 3)

					recipient_button_icon:ClearAllPoints()
					recipient_button_icon:Point("TOPLEFT", recipient_button, "TOPLEFT", 2, -2)
					recipient_button_icon:Point("BOTTOMRIGHT", recipient_button, "BOTTOMRIGHT", -2, 2)
					recipient_button_icon:SetTexCoord(.08, .92, .08, .92)
					recipient_button:SetTemplate("Default", true)
					recipient_button:StyleButton()
					recipient_button.bg = CreateFrame("Frame", nil, recipient_button)
					recipient_button.bg:SetTemplate("Default")
					recipient_button.bg:SetPoint("TOPLEFT", recipient_button, "TOPRIGHT", 4, 0)
					recipient_button.bg:SetPoint("BOTTOMRIGHT", _G["TradeRecipientItem"..i.."NameFrame"], "BOTTOMRIGHT", 0, 14)
					recipient_button.bg:SetFrameLevel(recipient_button:GetFrameLevel() - 3)					
					
				end
			end
			
			TradeHighlightPlayerTop:SetTexture(0, 1, 0, 0.2)
			TradeHighlightPlayerBottom:SetTexture(0, 1, 0, 0.2)
			TradeHighlightPlayerMiddle:SetTexture(0, 1, 0, 0.2)
			TradeHighlightPlayer:SetFrameStrata("HIGH")
			TradeHighlightPlayer:Point("TOPLEFT", TradeFrame, "TOPLEFT", 23, -100)
			
			TradeHighlightPlayerEnchantTop:SetTexture(0, 1, 0, 0.2)
			TradeHighlightPlayerEnchantBottom:SetTexture(0, 1, 0, 0.2)
			TradeHighlightPlayerEnchantMiddle:SetTexture(0, 1, 0, 0.2)
			TradeHighlightPlayerEnchant:SetFrameStrata("HIGH")
			
			TradeHighlightRecipientTop:SetTexture(0, 1, 0, 0.2)
			TradeHighlightRecipientBottom:SetTexture(0, 1, 0, 0.2)
			TradeHighlightRecipientMiddle:SetTexture(0, 1, 0, 0.2)
			TradeHighlightRecipient:SetFrameStrata("HIGH")
			TradeHighlightRecipient:Point("TOPLEFT", TradeFrame, "TOPLEFT", 192, -100)
			
			TradeHighlightRecipientEnchantTop:SetTexture(0, 1, 0, 0.2)
			TradeHighlightRecipientEnchantBottom:SetTexture(0, 1, 0, 0.2)
			TradeHighlightRecipientEnchantMiddle:SetTexture(0, 1, 0, 0.2)
			TradeHighlightRecipientEnchant:SetFrameStrata("HIGH")			

		end
		
		--Guild Registrar Frame
		if C["skin"].guildregistrar == true then
			GuildRegistrarFrame:StripTextures(true)
			GuildRegistrarFrame:SetTemplate("Transparent")
			GuildRegistrarGreetingFrame:StripTextures()
			SkinButton(GuildRegistrarFrameGoodbyeButton)
			SkinButton(GuildRegistrarFrameCancelButton)
			SkinButton(GuildRegistrarFramePurchaseButton)
			SkinCloseButton(GuildRegistrarFrameCloseButton)
			SkinEditBox(GuildRegistrarFrameEditBox)
			for i=1, GuildRegistrarFrameEditBox:GetNumRegions() do
				local region = select(i, GuildRegistrarFrameEditBox:GetRegions())
				if region:GetObjectType() == "Texture" then
					if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then
						region:Kill()
					end
				end
			end
			
			GuildRegistrarFrameEditBox:Height(20)
			
			for i=1, 2 do
				_G["GuildRegistrarButton"..i]:GetFontString():SetTextColor(1, 1, 1)
			end
			
			GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
			AvailableServicesText:SetTextColor(1, 1, 0)
		end
		
		--Tabard Frame
		if C["skin"].tabard == true then
			TabardFrame:StripTextures(true)
			TabardFrame:SetTemplate("Transparent")
			TabardModel:CreateBackdrop("Default")
			SkinButton(TabardFrameCancelButton)
			SkinButton(TabardFrameAcceptButton)
			SkinCloseButton(TabardFrameCloseButton)
			SkinRotateButton(TabardCharacterModelRotateLeftButton)
			SkinRotateButton(TabardCharacterModelRotateRightButton)
			TabardFrameCostFrame:StripTextures()
			TabardFrameCustomizationFrame:StripTextures()
			
			for i=1, 5 do
				local custom = "TabardFrameCustomization"..i
				_G[custom]:StripTextures()
				SkinNextPrevButton(_G[custom.."LeftButton"])
				SkinNextPrevButton(_G[custom.."RightButton"])
				
				
				if i > 1 then
					_G[custom]:ClearAllPoints()
					_G[custom]:Point("TOP", _G["TabardFrameCustomization"..i-1], "BOTTOM", 0, -6)
				else
					local point, anchor, point2, x, y = _G[custom]:GetPoint()
					_G[custom]:Point(point, anchor, point2, x, y+4)
				end
			end
			
			TabardCharacterModelRotateLeftButton:Point("BOTTOMLEFT", 4, 4)
			TabardCharacterModelRotateRightButton:Point("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 4, 0)
			TabardCharacterModelRotateLeftButton.SetPoint = E.dummy
			TabardCharacterModelRotateRightButton.SetPoint = E.dummy
		end
		
		--Gossip Frame
		if C["skin"].gossip == true then	

			local StripAllTextures = {
				"GossipFrameGreetingPanel",
			}			

			for _, object in pairs(StripAllTextures) do
				_G[object]:StripTextures()
			end

			local KillTextures = {
				"GossipFramePortrait",
			}

			for _, texture in pairs(KillTextures) do
				_G[texture]:Kill()
			end

			local buttons = {
				"GossipFrameGreetingGoodbyeButton",
			}

			for i = 1, #buttons do
				_G[buttons[i]]:StripTextures()
				SkinButton(_G[buttons[i]])
			end


			for i = 1, NUMGOSSIPBUTTONS do
				obj = select(3,_G["GossipTitleButton"..i]:GetRegions())
				obj:SetTextColor(1,1,1)
			end

			GossipGreetingText:SetTextColor(1,1,1)
			GossipFrame:CreateBackdrop("Transparent")
			GossipFrame.backdrop:Point("TOPLEFT", GossipFrame, "TOPLEFT", 15, -20)
			GossipFrame.backdrop:Point("BOTTOMRIGHT", GossipFrame, "BOTTOMRIGHT", -30, 65)
			SkinCloseButton(GossipFrameCloseButton,GossipFrame.backdrop)
			
			
			--Extreme hackage, blizzard makes button text on quest frame use hex color codes for some reason
			hooksecurefunc("GossipFrameUpdate", function()
				for i=1, NUMGOSSIPBUTTONS do
					local button = _G["GossipTitleButton"..i]
					
					if button:GetFontString() then
						if button:GetFontString():GetText() and button:GetFontString():GetText():find("|cff000000") then
							button:GetFontString():SetText(string.gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
						end
					end
				end
			end)
		end
		
		--Greeting Frame
		if C["skin"].greeting == true then	
			QuestFrameGreetingPanel:HookScript("OnShow", function()
				QuestFrameGreetingPanel:StripTextures()
				SkinButton(QuestFrameGreetingGoodbyeButton, true)
				GreetingText:SetTextColor(1, 1, 1)
				CurrentQuestsText:SetTextColor(1, 1, 0)
				QuestGreetingFrameHorizontalBreak:Kill()
				AvailableQuestsText:SetTextColor(1, 1, 0)
				
				for i=1, MAX_NUM_QUESTS do
					local button = _G["QuestTitleButton"..i]
					if button:GetFontString() then
						if button:GetFontString():GetText() and button:GetFontString():GetText():find("|cff000000") then
							button:GetFontString():SetText(string.gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
						end
					end
				end
			end)
		end
		
		--Minor watch frame skin
		do
			SkinCloseButton(WatchFrameCollapseExpandButton)
		end
		
		--Opacity Frame
		do
			OpacityFrame:StripTextures()
			OpacityFrame:SetTemplate("Transparent")
		end
		
		
		--Encounter Journal
		if E.IsPTRVersion() then
			do
				EncounterJournal:StripTextures(true)
				
				EncounterJournal.backdrop = EncounterJournal:CreateTexture(nil, "BACKGROUND")
				EncounterJournal.backdrop:SetDrawLayer("BACKGROUND", -7)
				EncounterJournal.backdrop:SetTexture(0, 0, 0)
				EncounterJournal.backdrop:Point("TOPLEFT", EncounterJournal, "TOPLEFT", -E.mult*3, E.mult*3)
				EncounterJournal.backdrop:Point("BOTTOMRIGHT", EncounterJournal, "BOTTOMRIGHT", E.mult*3, -E.mult*3)
				
				EncounterJournal.backdrop2 = EncounterJournal:CreateTexture(nil, "BACKGROUND")
				EncounterJournal.backdrop2:SetDrawLayer("BACKGROUND", -6)
				EncounterJournal.backdrop2:SetTexture(unpack(C["media"].bordercolor))
				EncounterJournal.backdrop2:Point("TOPLEFT", EncounterJournal, "TOPLEFT", -E.mult*2, E.mult*2)
				EncounterJournal.backdrop2:Point("BOTTOMRIGHT", EncounterJournal, "BOTTOMRIGHT", E.mult*2, -E.mult*2)						

				EncounterJournal.backdrop3 = EncounterJournal:CreateTexture(nil, "BACKGROUND")
				EncounterJournal.backdrop3:SetDrawLayer("BACKGROUND", -5)
				EncounterJournal.backdrop3:SetTexture(0, 0, 0)
				EncounterJournal.backdrop3:Point("TOPLEFT", EncounterJournal, "TOPLEFT", -E.mult, E.mult)
				EncounterJournal.backdrop3:Point("BOTTOMRIGHT", EncounterJournal, "BOTTOMRIGHT", E.mult, -E.mult)					

				EncounterJournal.backdrop4 = EncounterJournal:CreateTexture(nil, "BACKGROUND")
				EncounterJournal.backdrop4:SetDrawLayer("BACKGROUND", -4)
				EncounterJournal.backdrop4:SetTexture(unpack(C["media"].backdropcolor))
				EncounterJournal.backdrop4:SetAllPoints()						
				
				EncounterJournalNavBar:StripTextures(true)
				EncounterJournalNavBarOverlay:StripTextures(true)
				
				EncounterJournalNavBar:CreateBackdrop("Default")
				EncounterJournalNavBar.backdrop:Point("TOPLEFT", -2, 0)
				EncounterJournalNavBar.backdrop:SetPoint("BOTTOMRIGHT")
				SkinButton(EncounterJournalNavBarHomeButton, true)
				
				SkinEditBox(EncounterJournalSearchBox)
				SkinCloseButton(EncounterJournalCloseButton)
				
				EncounterJournalInset:StripTextures(true)
				EncounterJournal:HookScript("OnShow", function()
					if not EncounterJournalInstanceSelect.backdrop then						
						EncounterJournalInstanceSelect.backdrop = EncounterJournalInstanceSelect:CreateTexture(nil, "BACKGROUND")
						EncounterJournalInstanceSelect.backdrop:SetDrawLayer("BACKGROUND", -3)
						EncounterJournalInstanceSelect.backdrop:SetTexture(0, 0, 0)
						EncounterJournalInstanceSelect.backdrop:Point("TOPLEFT", EncounterJournalInstanceSelect.bg, "TOPLEFT", -E.mult*3, E.mult*3)
						EncounterJournalInstanceSelect.backdrop:Point("BOTTOMRIGHT", EncounterJournalInstanceSelect.bg, "BOTTOMRIGHT", E.mult*3, -E.mult*3)
						
						EncounterJournalInstanceSelect.backdrop2 = EncounterJournalInstanceSelect:CreateTexture(nil, "BACKGROUND")
						EncounterJournalInstanceSelect.backdrop2:SetDrawLayer("BACKGROUND", -2)
						EncounterJournalInstanceSelect.backdrop2:SetTexture(unpack(C["media"].bordercolor))
						EncounterJournalInstanceSelect.backdrop2:Point("TOPLEFT", EncounterJournalInstanceSelect.bg, "TOPLEFT", -E.mult*2, E.mult*2)
						EncounterJournalInstanceSelect.backdrop2:Point("BOTTOMRIGHT", EncounterJournalInstanceSelect.bg, "BOTTOMRIGHT", E.mult*2, -E.mult*2)						

						EncounterJournalInstanceSelect.backdrop3 = EncounterJournalInstanceSelect:CreateTexture(nil, "BACKGROUND")
						EncounterJournalInstanceSelect.backdrop3:SetDrawLayer("BACKGROUND", -1)
						EncounterJournalInstanceSelect.backdrop3:SetTexture(0, 0, 0)
						EncounterJournalInstanceSelect.backdrop3:Point("TOPLEFT", EncounterJournalInstanceSelect.bg, "TOPLEFT", -E.mult, E.mult)
						EncounterJournalInstanceSelect.backdrop3:Point("BOTTOMRIGHT", EncounterJournalInstanceSelect.bg, "BOTTOMRIGHT", E.mult, -E.mult)								
					end
					
					if not EncounterJournalEncounterFrameInfo.backdrop then						
						EncounterJournalEncounterFrameInfo.backdrop = EncounterJournalEncounterFrameInfo:CreateTexture(nil, "BACKGROUND")
						EncounterJournalEncounterFrameInfo.backdrop:SetDrawLayer("BACKGROUND", -3)
						EncounterJournalEncounterFrameInfo.backdrop:SetTexture(0, 0, 0)
						EncounterJournalEncounterFrameInfo.backdrop:Point("TOPLEFT", EncounterJournalEncounterFrameInfoBG, "TOPLEFT", -E.mult*3, E.mult*3)
						EncounterJournalEncounterFrameInfo.backdrop:Point("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoBG, "BOTTOMRIGHT", E.mult*3, -E.mult*3)
						
						EncounterJournalEncounterFrameInfo.backdrop2 = EncounterJournalEncounterFrameInfo:CreateTexture(nil, "BACKGROUND")
						EncounterJournalEncounterFrameInfo.backdrop2:SetDrawLayer("BACKGROUND", -2)
						EncounterJournalEncounterFrameInfo.backdrop2:SetTexture(unpack(C["media"].bordercolor))
						EncounterJournalEncounterFrameInfo.backdrop2:Point("TOPLEFT", EncounterJournalEncounterFrameInfoBG, "TOPLEFT", -E.mult*2, E.mult*2)
						EncounterJournalEncounterFrameInfo.backdrop2:Point("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoBG, "BOTTOMRIGHT", E.mult*2, -E.mult*2)						

						EncounterJournalEncounterFrameInfo.backdrop3 = EncounterJournalEncounterFrameInfo:CreateTexture(nil, "BACKGROUND")
						EncounterJournalEncounterFrameInfo.backdrop3:SetDrawLayer("BACKGROUND", -1)
						EncounterJournalEncounterFrameInfo.backdrop3:SetTexture(0, 0, 0)
						EncounterJournalEncounterFrameInfo.backdrop3:Point("TOPLEFT", EncounterJournalEncounterFrameInfoBG, "TOPLEFT", -E.mult, E.mult)
						EncounterJournalEncounterFrameInfo.backdrop3:Point("BOTTOMRIGHT", EncounterJournalEncounterFrameInfoBG, "BOTTOMRIGHT", E.mult, -E.mult)								
					end	
					EncounterJournalEncounterFrameInfoBossTab:ClearAllPoints()
					EncounterJournalEncounterFrameInfoBossTab:Point("LEFT", EncounterJournalEncounterFrameInfoEncounterTile, "RIGHT", -10, 4)
					EncounterJournalEncounterFrameInfoLootTab:ClearAllPoints()
					EncounterJournalEncounterFrameInfoLootTab:Point("LEFT", EncounterJournalEncounterFrameInfoBossTab, "RIGHT", -24, 0)
					
					EncounterJournalEncounterFrameInfoBossTab:SetFrameStrata("HIGH")
					EncounterJournalEncounterFrameInfoLootTab:SetFrameStrata("HIGH")
					
					EncounterJournalEncounterFrameInfoBossTab:SetScale(0.75)
					EncounterJournalEncounterFrameInfoLootTab:SetScale(0.75)
				end)
				
				SkinScrollBar(EncounterJournalInstanceSelectScrollFrameScrollBar)

				EncounterJournalEncounterFrameInfoBossTab:GetNormalTexture():SetTexture(nil)
				EncounterJournalEncounterFrameInfoBossTab:GetPushedTexture():SetTexture(nil)
				EncounterJournalEncounterFrameInfoBossTab:GetDisabledTexture():SetTexture(nil)
				EncounterJournalEncounterFrameInfoBossTab:GetHighlightTexture():SetTexture(nil)

				EncounterJournalEncounterFrameInfoLootTab:GetNormalTexture():SetTexture(nil)
				EncounterJournalEncounterFrameInfoLootTab:GetPushedTexture():SetTexture(nil)
				EncounterJournalEncounterFrameInfoLootTab:GetDisabledTexture():SetTexture(nil)
				EncounterJournalEncounterFrameInfoLootTab:GetHighlightTexture():SetTexture(nil)		
			end
		end
		
		--WorldMap
		if C["skin"].worldmap == true then	
			WorldMapFrame:CreateBackdrop("Transparent")
			--WorldMapDetailFrame:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1) --BUGFIX: I DON'T REMEMBER WHY I HAD THIS, BUT THIS BREAKS ARCH DIG SITES
			WorldMapDetailFrame.backdrop = CreateFrame("Frame", nil, WorldMapFrame)
			WorldMapDetailFrame.backdrop:SetTemplate("Default")
			WorldMapDetailFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -2, 2)
			WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 2, -2)
			WorldMapDetailFrame.backdrop:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() - 2)

			SkinCloseButton(WorldMapFrameCloseButton)
			SkinCloseButton(WorldMapFrameSizeDownButton)
			SkinCloseButton(WorldMapFrameSizeUpButton)
									
			SkinDropDownBox(WorldMapLevelDropDown)
			SkinDropDownBox(WorldMapZoneMinimapDropDown)
			SkinDropDownBox(WorldMapContinentDropDown)
			SkinDropDownBox(WorldMapZoneDropDown)
			SkinButton(WorldMapZoomOutButton)
			WorldMapZoomOutButton:Point("LEFT", WorldMapZoneDropDown, "RIGHT", 0, 4)
			WorldMapLevelUpButton:Point("TOPLEFT", WorldMapLevelDropDown, "TOPRIGHT", -2, 8)
			WorldMapLevelDownButton:Point("BOTTOMLEFT", WorldMapLevelDropDown, "BOTTOMRIGHT", -2, 2)
			
			SkinCheckBox(WorldMapTrackQuest)
			SkinCheckBox(WorldMapQuestShowObjectives)
			SkinCheckBox(WorldMapShowDigSites)
			
			--Mini
			local function SmallSkin()
				WorldMapLevelDropDown:ClearAllPoints()
				WorldMapLevelDropDown:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -10, -4)

				WorldMapFrame.backdrop:ClearAllPoints()
				WorldMapFrame.backdrop:Point("TOPLEFT", 2, 2)
				WorldMapFrame.backdrop:Point("BOTTOMRIGHT", 2, -2)
			end
			
			--Large
			local function LargeSkin()
				if not InCombatLockdown() then
					WorldMapFrame:SetParent(UIParent)
					WorldMapFrame:EnableMouse(false)
					WorldMapFrame:EnableKeyboard(false)
					SetUIPanelAttribute(WorldMapFrame, "area", "center");
					SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
				end
				
				WorldMapFrame.backdrop:ClearAllPoints()
				WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -25, 70)
				WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 25, -30)    
			end
			
			local function QuestSkin()
				if not InCombatLockdown() then
					WorldMapFrame:SetParent(UIParent)
					WorldMapFrame:EnableMouse(false)
					WorldMapFrame:EnableKeyboard(false)
					SetUIPanelAttribute(WorldMapFrame, "area", "center");
					SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
				end
				
				WorldMapFrame.backdrop:ClearAllPoints()
				WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -25, 70)
				WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 325, -235)  
				
				if not WorldMapQuestDetailScrollFrame.backdrop then
					WorldMapQuestDetailScrollFrame:CreateBackdrop("Default")
					WorldMapQuestDetailScrollFrame.backdrop:Point("TOPLEFT", -22, 2)
					WorldMapQuestDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 23, -4)
				end
				
				if not WorldMapQuestRewardScrollFrame.backdrop then
					WorldMapQuestRewardScrollFrame:CreateBackdrop("Default")
					WorldMapQuestRewardScrollFrame.backdrop:Point("BOTTOMRIGHT", 22, -4)				
				end
				
				if not WorldMapQuestScrollFrame.backdrop then
					WorldMapQuestScrollFrame:CreateBackdrop("Default")
					WorldMapQuestScrollFrame.backdrop:Point("TOPLEFT", 0, 2)
					WorldMapQuestScrollFrame.backdrop:Point("BOTTOMRIGHT", 24, -3)				
				end
			end			
			
			local function FixSkin()
				WorldMapFrame:StripTextures()
				if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
					LargeSkin()
				elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
					SmallSkin()
				elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
					QuestSkin()
				end
	
				if not InCombatLockdown() then
					WorldMapFrame:SetScale(1)
					WorldMapFrameSizeDownButton:Show()
					WorldMapFrame:SetFrameLevel(10)
				else
					WorldMapFrameSizeDownButton:Disable()
					WorldMapFrameSizeUpButton:Disable()
				end	
				
				WorldMapFrameAreaLabel:SetFont(C["media"].font, 50, "OUTLINE")
				WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
				WorldMapFrameAreaLabel:SetTextColor(0.90, 0.8294, 0.6407)	
				
				WorldMapFrameAreaDescription:SetFont(C["media"].font, 40, "OUTLINE")
				WorldMapFrameAreaDescription:SetShadowOffset(2, -2)	
				
				WorldMapZoneInfo:SetFont(C["media"].font, 27, "OUTLINE")
				WorldMapZoneInfo:SetShadowOffset(2, -2)		
			end
			
			WorldMapFrame:HookScript("OnShow", FixSkin)
			hooksecurefunc("WorldMapFrame_SetFullMapView", LargeSkin)
			hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestSkin)
			hooksecurefunc("WorldMap_ToggleSizeUp", FixSkin)
			
			WorldMapFrame:RegisterEvent("PLAYER_LOGIN")
			WorldMapFrame:HookScript("OnEvent", function(self, event)
				if event == "PLAYER_LOGIN" then
					if not GetCVarBool("miniWorldMap") then
						ToggleFrame(WorldMapFrame)				
						ToggleFrame(WorldMapFrame)
					end
				end
			end)
			
			local coords = CreateFrame("Frame", "CoordsFrame", WorldMapFrame)
			local fontheight = select(2, WorldMapQuestShowObjectivesText:GetFont())*1.1
			coords:SetFrameLevel(90)
			coords:FontString("PlayerText", C["media"].font, fontheight, "THINOUTLINE")
			coords:FontString("MouseText", C["media"].font, fontheight, "THINOUTLINE")
			coords.PlayerText:SetTextColor(WorldMapQuestShowObjectivesText:GetTextColor())
			coords.MouseText:SetTextColor(WorldMapQuestShowObjectivesText:GetTextColor())
			coords.PlayerText:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", 5, 5)
			coords.PlayerText:SetText("Player:   0, 0")
			coords.MouseText:SetPoint("BOTTOMLEFT", coords.PlayerText, "TOPLEFT", 0, 5)
			coords.MouseText:SetText("Mouse:   0, 0")
			local int = 0
			
			WorldMapFrame:HookScript("OnUpdate", function(self, elapsed)
				--For some reason these buttons aren't functioning correctly, and we can't afford for it to fuckup because toggling to a big map in combat will cause a taint.
				if InCombatLockdown() then
					WorldMapFrameSizeDownButton:Disable()
					WorldMapFrameSizeUpButton:Disable()
				else
					WorldMapFrameSizeDownButton:Enable()
					WorldMapFrameSizeUpButton:Enable()			
				end
				
				if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
					WorldMapFrameSizeUpButton:Hide()
					WorldMapFrameSizeDownButton:Show()
				elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
					WorldMapFrameSizeUpButton:Show()
					WorldMapFrameSizeDownButton:Hide()
				elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
					WorldMapFrameSizeUpButton:Hide()
					WorldMapFrameSizeDownButton:Show()
				end		

				int = int + 1
				
				if int >= 3 then
					local inInstance, _ = IsInInstance()
					local x,y = GetPlayerMapPosition("player")
					x = math.floor(100 * x)
					y = math.floor(100 * y)
					if x ~= 0 and y ~= 0 then
						coords.PlayerText:SetText(PLAYER..":   "..x..", "..y)
					else
						coords.PlayerText:SetText(" ")
					end
					

					local scale = WorldMapDetailFrame:GetEffectiveScale()
					local width = WorldMapDetailFrame:GetWidth()
					local height = WorldMapDetailFrame:GetHeight()
					local centerX, centerY = WorldMapDetailFrame:GetCenter()
					local x, y = GetCursorPosition()
					local adjustedX = (x / scale - (centerX - (width/2))) / width
					local adjustedY = (centerY + (height/2) - y / scale) / height	

					if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
						adjustedX = math.floor(100 * adjustedX)
						adjustedY = math.floor(100 * adjustedY)
						coords.MouseText:SetText(MOUSE_LABEL..":   "..adjustedX..", "..adjustedY)
					else
						coords.MouseText:SetText(" ")
					end
					
					int = 0
				end				
			end)		
		end
		
		--Item Text Frame
		if C["skin"].gossip == true then
			ItemTextFrame:StripTextures(true)
			ItemTextScrollFrame:StripTextures()
			ItemTextFrame:SetTemplate("Transparent")
			SkinCloseButton(ItemTextCloseButton)
			SkinNextPrevButton(ItemTextPrevPageButton)
			SkinNextPrevButton(ItemTextNextPageButton)
			ItemTextPageText:SetTextColor(1, 1, 1)
			ItemTextPageText.SetTextColor = E.dummy
		end
		
		--Taxi Frame
		if C["skin"].taxi == true then
			TaxiFrame:StripTextures()
			TaxiFrame:CreateBackdrop("Transparent")
			TaxiRouteMap:CreateBackdrop("Default")
			TaxiRouteMap.backdrop:SetAllPoints()
			SkinCloseButton(TaxiFrameCloseButton)
		end
		
		--LFR frame
		if C["skin"].lfr == true then
			local buttons = {
			  "LFRQueueFrameFindGroupButton",
			  "LFRQueueFrameAcceptCommentButton",
			  "LFRBrowseFrameSendMessageButton",
			  "LFRBrowseFrameInviteButton",
			  "LFRBrowseFrameRefreshButton",
			}

			LFRParentFrame:StripTextures()
			LFRParentFrame:SetTemplate("Transparent")
			LFRQueueFrame:StripTextures()
			LFRBrowseFrame:StripTextures()


			for i=1, #buttons do
			  SkinButton(_G[buttons[i]])
			end

			--Close button doesn't have a fucking name, extreme hackage
			for i=1, LFRParentFrame:GetNumChildren() do
			  local child = select(i, LFRParentFrame:GetChildren())
			  if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
				SkinCloseButton(child)
			  end
			end

			SkinTab(LFRParentFrameTab1)
			SkinTab(LFRParentFrameTab2)

			SkinDropDownBox(LFRBrowseFrameRaidDropDown)

			for i=1, 20 do
			  local button = _G["LFRQueueFrameSpecificListButton"..i.."ExpandOrCollapseButton"]

			  if button then
				button:HookScript("OnClick", function()
				  SkinCloseButton(button)
				end)
				SkinCloseButton(button)
			  end
			end

			LFRQueueFrameCommentTextButton:CreateBackdrop("Default")
			LFRQueueFrameCommentTextButton:Height(35)

			for i=1, 7 do
				local button = "LFRBrowseFrameColumnHeader"..i
				_G[button.."Left"]:Kill()
				_G[button.."Middle"]:Kill()
				_G[button.."Right"]:Kill()
			end		
			
			for i=1, NUM_LFR_CHOICE_BUTTONS do
				local button = _G["LFRQueueFrameSpecificListButton"..i]
				SkinCheckBox(button.enableButton)
			end
			
			--DPS, Healer, Tank check button's don't have a name, use it's parent as a referance.
			SkinCheckBox(LFRQueueFrameRoleButtonTank:GetChildren())
			SkinCheckBox(LFRQueueFrameRoleButtonHealer:GetChildren())
			SkinCheckBox(LFRQueueFrameRoleButtonDPS:GetChildren())
			LFRQueueFrameRoleButtonTank:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonTank:GetChildren():GetFrameLevel() + 2)
			LFRQueueFrameRoleButtonHealer:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonHealer:GetChildren():GetFrameLevel() + 2)
			LFRQueueFrameRoleButtonDPS:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonDPS:GetChildren():GetFrameLevel() + 2)
			
			LFRQueueFrameSpecificListScrollFrame:StripTextures()
		end
		
		if C["skin"].lfd == true then
			local StripAllTextures = {
				"LFDParentFrame",
				"LFDQueueFrame",
				"LFDQueueFrameSpecific",
				"LFDQueueFrameRandom",
				"LFDQueueFrameRandomScrollFrame",
				"LFDQueueFrameCapBar",
				"LFDDungeonReadyDialog",
			}

			local KillTextures = {
				"LFDQueueFrameBackground",
				"LFDParentFrameInset",
				"LFDParentFrameEyeFrame",
				"LFDQueueFrameRoleButtonTankBackground",
				"LFDQueueFrameRoleButtonHealerBackground",
				"LFDQueueFrameRoleButtonDPSBackground",
				"LFDDungeonReadyDialogBackground",
			}
			local buttons = {
				"LFDQueueFrameFindGroupButton",
				"LFDQueueFrameCancelButton",
				"LFDQueueFramePartyBackfillBackfillButton",
				"LFDQueueFramePartyBackfillNoBackfillButton",
			}

			local checkButtons = {
				"LFDQueueFrameRoleButtonTank",
				"LFDQueueFrameRoleButtonHealer",
				"LFDQueueFrameRoleButtonDPS",
				"LFDQueueFrameRoleButtonLeader",
			}
			
			for _, object in pairs(checkButtons) do
				_G[object].checkButton:SetFrameLevel(_G[object].checkButton:GetFrameLevel() + 2)
				SkinCheckBox(_G[object].checkButton)
			end
			
			hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", function()
				local dungeonID = LFDQueueFrame.type
				if type(dungeonID) == "string" then return end
				local _, _, _, _, _, numRewards = GetLFGDungeonRewards(dungeonID)
				
				for i=1, LFD_MAX_REWARDS do
					local button = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
					local icon = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"]
					local count = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"]
					local role1 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon1"]
					local role2 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon2"]
					local role3 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon3"]
					
					if button then
						local __texture = _G[button:GetName().."IconTexture"]:GetTexture()
						button:StripTextures()
						icon:SetTexture(__texture)
						icon:SetTexCoord(.08, .92, .08, .92)
						icon:Point("TOPLEFT", 2, -2)
						icon:SetDrawLayer("OVERLAY")
						count:SetDrawLayer("OVERLAY")
						if not button.backdrop then
							button:CreateBackdrop("Default")
							button.backdrop:Point("TOPLEFT", icon, "TOPLEFT", -2, 2)
							button.backdrop:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
							icon:SetParent(button.backdrop)
							icon.SetPoint = E.dummy
							
							if count then
								count:SetParent(button.backdrop)
							end
							if role1 then
								role1:SetParent(button.backdrop)
							end
							if role2 then
								role2:SetParent(button.backdrop)
							end
							if role3 then
								role3:SetParent(button.backdrop)
							end							
						end
					end
				end				
			end)
			
			hooksecurefunc("LFDQueueFrameSpecificListButton_SetDungeon", function(button, dungeonID, mode, submode)
				for _, object in pairs(checkButtons) do
					local button = _G[object]
					if not ( button.checkButton:GetChecked() ) then
						button.checkButton:SetDisabledTexture(nil)	
					else
						button.checkButton:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")	
					end
				end
			end)
			
			
			for _, object in pairs(StripAllTextures) do
				_G[object]:StripTextures()
			end

			for _, texture in pairs(KillTextures) do
				_G[texture]:Kill()
			end

			for i = 1, #buttons do
				_G[buttons[i]]:StripTextures()
				SkinButton(_G[buttons[i]])
			end	

			for i= 1,15 do
				SkinCheckBox(_G["LFDQueueFrameSpecificListButton"..i.."EnableButton"])
			end
			
			LFDQueueFrameCapBar:SetPoint("LEFT", 40, 0)
			
			LFDQueueFrameSpecificListScrollFrame:StripTextures()
			LFDQueueFrameSpecificListScrollFrame:Height(LFDQueueFrameSpecificListScrollFrame:GetHeight() - 8)
			LFDParentFrame:CreateBackdrop("Transparent")
			LFDParentFrame.backdrop:Point( "TOPLEFT", LFDParentFrame, "TOPLEFT")
			LFDParentFrame.backdrop:Point( "BOTTOMRIGHT", LFDParentFrame, "BOTTOMRIGHT")
			SkinCloseButton(LFDParentFrameCloseButton,LFDParentFrame)
			SkinCloseButton(LFDDungeonReadyDialogCloseButton,LFDDungeonReadyDialog)
			SkinDropDownBox(LFDQueueFrameTypeDropDown, 300)
			LFDQueueFrameTypeDropDown:Point("RIGHT",-10,0)
			LFDQueueFrameCapBar:CreateBackdrop("Transparent")
			LFDQueueFrameCapBar.backdrop:Point( "TOPLEFT", LFDQueueFrameCapBar, "TOPLEFT", 1, -1)
			LFDQueueFrameCapBar.backdrop:Point( "BOTTOMRIGHT", LFDQueueFrameCapBar, "BOTTOMRIGHT", -1, 1 )
			LFDQueueFrameCapBarProgress:SetTexture(C["media"].normTex)
			LFDQueueFrameCapBarCap1:SetTexture(C["media"].normTex)
			LFDQueueFrameCapBarCap2:SetTexture(C["media"].normTex)
			SkinScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)
		end
		
		--Quest Frame
		if C["skin"].quest == true then
			QuestFrame:StripTextures(true)
			QuestFrameDetailPanel:StripTextures(true)
			QuestDetailScrollFrame:StripTextures(true)
			QuestDetailScrollChildFrame:StripTextures(true)
			QuestRewardScrollFrame:StripTextures(true)
			QuestRewardScrollChildFrame:StripTextures(true)
			QuestFrameProgressPanel:StripTextures(true)
			QuestFrameRewardPanel:StripTextures(true)
			QuestFrame:CreateBackdrop("Transparent")
			QuestFrame.backdrop:Point("TOPLEFT", 6, -8)
			QuestFrame.backdrop:Point("BOTTOMRIGHT", -20, 65)
			QuestFrame.backdrop:CreateShadow("Default")
			SkinButton(QuestFrameAcceptButton, true)
			SkinButton(QuestFrameDeclineButton, true)
			SkinButton(QuestFrameCompleteButton, true)
			SkinButton(QuestFrameGoodbyeButton, true)
			SkinButton(QuestFrameCompleteQuestButton, true)
			SkinCloseButton(QuestFrameCloseButton, QuestFrame.backdrop)
			
			for i=1, 6 do
				local button = _G["QuestProgressItem"..i]
				local texture = _G["QuestProgressItem"..i.."IconTexture"]
				button:StripTextures()
				button:StyleButton()
				button:Width(_G["QuestProgressItem"..i]:GetWidth() - 4)
				button:SetFrameLevel(button:GetFrameLevel() + 2)
				texture:SetTexCoord(.08, .92, .08, .92)
				texture:SetDrawLayer("OVERLAY")
				texture:Point("TOPLEFT", 2, -2)
				texture:Size(texture:GetWidth() - 2, texture:GetHeight() - 2)
				_G["QuestProgressItem"..i.."Count"]:SetDrawLayer("OVERLAY")
				button:SetTemplate("Default")				
			end
			
			hooksecurefunc("QuestFrameProgressItems_Update", function()
				QuestProgressTitleText:SetTextColor(1, 1, 0)
				QuestProgressText:SetTextColor(1, 1, 1)
				QuestProgressRequiredItemsText:SetTextColor(1, 1, 0)
				QuestProgressRequiredMoneyText:SetTextColor(1, 1, 0)
			end)
			
			QuestNPCModel:StripTextures()
			QuestNPCModel:CreateBackdrop("Transparent")
			QuestNPCModel:Point("TOPLEFT", QuestLogDetailFrame, "TOPRIGHT", 4, -34)
			QuestNPCModelTextFrame:StripTextures()
			QuestNPCModelTextFrame:CreateBackdrop("Default")
			QuestNPCModelTextFrame.backdrop:Point("TOPLEFT", QuestNPCModel.backdrop, "BOTTOMLEFT", 0, -2)
			QuestLogDetailFrame:StripTextures()
			QuestLogDetailFrame:SetTemplate("Transparent")
			QuestLogDetailScrollFrame:StripTextures()
			SkinCloseButton(QuestLogDetailFrameCloseButton)
			
			hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, portrait, text, name, x, y)
				QuestNPCModel:ClearAllPoints();
				QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x + 18, y);			
			end)
		end
		
		--Petition Frame
		if C["skin"].petition == true then
			PetitionFrame:StripTextures(true)
			PetitionFrame:SetTemplate("Transparent")
			PetitionFrame:CreateShadow("Default")
			
			SkinButton(PetitionFrameRequestButton)
			SkinButton(PetitionFrameRenameButton)
			SkinButton(PetitionFrameCancelButton)
			SkinCloseButton(PetitionFrameCloseButton)
			
			PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
			PetitionFrameCharterName:SetTextColor(1, 1, 1)
			PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
			PetitionFrameMasterName:SetTextColor(1, 1, 1)
			PetitionFrameMemberTitle:SetTextColor(1, 1, 0)
			
			for i=1, 9 do
				_G["PetitionFrameMemberName"..i]:SetTextColor(1, 1, 1)
			end
			
			PetitionFrameInstructions:SetTextColor(1, 1, 1)
			
			PetitionFrameRenameButton:Point("LEFT", PetitionFrameRequestButton, "RIGHT", 3, 0)
			PetitionFrameRenameButton:Point("RIGHT", PetitionFrameCancelButton, "LEFT", -3, 0)
			PetitionFrame:Height(PetitionFrame:GetHeight() - 80)
			
			PetitionFrameCancelButton:Point("BOTTOMRIGHT", PetitionFrame, "BOTTOMRIGHT", -40, 20)
			PetitionFrameRequestButton:Point("BOTTOMLEFT", PetitionFrame, "BOTTOMLEFT", 22, 20)
		end
		
		--Quest Log
		if C["skin"].quest == true then
			SkinCloseButton(QuestLogFrameCloseButton)
			QuestLogFrame:StripTextures()
			QuestLogFrame:SetTemplate("Transparent")
			QuestLogFrame:CreateShadow("Default")
			QuestLogCount:StripTextures()
			QuestLogCount:SetTemplate("Default")
			
			EmptyQuestLogFrame:StripTextures()
			
			QuestLogFrameShowMapButton:StripTextures()
			SkinButton(QuestLogFrameShowMapButton)
			QuestLogFrameShowMapButton.text:ClearAllPoints()
			QuestLogFrameShowMapButton.text:SetPoint("CENTER")
			QuestLogFrameShowMapButton:Size(QuestLogFrameShowMapButton:GetWidth() - 30, QuestLogFrameShowMapButton:GetHeight(), - 40)
			
			local buttons = {
				"QuestLogFrameAbandonButton",
				"QuestLogFramePushQuestButton",
				"QuestLogFrameTrackButton",
				"QuestLogFrameCancelButton",
			}
			
			for _, button in pairs(buttons) do
				SkinButton(_G[button])
			end
			QuestLogFramePushQuestButton:Point("LEFT", QuestLogFrameAbandonButton, "RIGHT", 2, 0)
			QuestLogFramePushQuestButton:Point("RIGHT", QuestLogFrameTrackButton, "LEFT", -2, 0)
		
			for i=1, MAX_NUM_ITEMS do
				_G["QuestInfoItem"..i]:StripTextures()
				_G["QuestInfoItem"..i]:StyleButton()
				_G["QuestInfoItem"..i]:Width(_G["QuestInfoItem"..i]:GetWidth() - 4)
				_G["QuestInfoItem"..i]:SetFrameLevel(_G["QuestInfoItem"..i]:GetFrameLevel() + 2)
				_G["QuestInfoItem"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
				_G["QuestInfoItem"..i.."IconTexture"]:SetDrawLayer("OVERLAY")
				_G["QuestInfoItem"..i.."IconTexture"]:Point("TOPLEFT", 2, -2)
				_G["QuestInfoItem"..i.."IconTexture"]:Size(_G["QuestInfoItem"..i.."IconTexture"]:GetWidth() - 2, _G["QuestInfoItem"..i.."IconTexture"]:GetHeight() - 2)
				_G["QuestInfoItem"..i]:SetTemplate("Default")
				_G["QuestInfoItem"..i.."Count"]:SetDrawLayer("OVERLAY")
			end
			
			QuestInfoSkillPointFrame:StripTextures()
			QuestInfoSkillPointFrame:StyleButton()
			QuestInfoSkillPointFrame:Width(QuestInfoSkillPointFrame:GetWidth() - 4)
			QuestInfoSkillPointFrame:SetFrameLevel(QuestInfoSkillPointFrame:GetFrameLevel() + 2)
			QuestInfoSkillPointFrameIconTexture:SetTexCoord(.08, .92, .08, .92)
			QuestInfoSkillPointFrameIconTexture:SetDrawLayer("OVERLAY")
			QuestInfoSkillPointFrameIconTexture:Point("TOPLEFT", 2, -2)
			QuestInfoSkillPointFrameIconTexture:Size(QuestInfoSkillPointFrameIconTexture:GetWidth() - 2, QuestInfoSkillPointFrameIconTexture:GetHeight() - 2)
			QuestInfoSkillPointFrame:SetTemplate("Default")
			QuestInfoSkillPointFrameCount:SetDrawLayer("OVERLAY")
			QuestInfoSkillPointFramePoints:ClearAllPoints()
			QuestInfoSkillPointFramePoints:Point("BOTTOMRIGHT", QuestInfoSkillPointFrameIconTexture, "BOTTOMRIGHT")
			
			QuestInfoItemHighlight:StripTextures()
			QuestInfoItemHighlight:SetTemplate("Default")
			QuestInfoItemHighlight:SetBackdropBorderColor(1, 1, 0)
			QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
			QuestInfoItemHighlight:Size(142, 40)
			
			hooksecurefunc("QuestInfoItem_OnClick", function(self)
				QuestInfoItemHighlight:ClearAllPoints()
				QuestInfoItemHighlight:SetAllPoints(self)
			end)
			
			--Everything here to make the text a readable color
			local function QuestObjectiveText()
				local numObjectives = GetNumQuestLeaderBoards()
				local objective
				local type, finished
				local numVisibleObjectives = 0
				for i = 1, numObjectives do
					_, type, finished = GetQuestLogLeaderBoard(i)
					if (type ~= "spell") then
						numVisibleObjectives = numVisibleObjectives+1
						objective = _G["QuestInfoObjective"..numVisibleObjectives]
						if ( finished ) then
							objective:SetTextColor(1, 1, 0)
						else
							objective:SetTextColor(0.6, 0.6, 0.6)
						end
					end
				end			
			end
			
			hooksecurefunc("QuestInfo_Display", function(template, parentFrame, acceptButton, material)								
				local textColor = {1, 1, 1}
				local titleTextColor = {1, 1, 0}
				
				-- headers
				QuestInfoTitleHeader:SetTextColor(unpack(titleTextColor))
				QuestInfoDescriptionHeader:SetTextColor(unpack(titleTextColor))
				QuestInfoObjectivesHeader:SetTextColor(unpack(titleTextColor))
				QuestInfoRewardsHeader:SetTextColor(unpack(titleTextColor))
				-- other text
				QuestInfoDescriptionText:SetTextColor(unpack(textColor))
				QuestInfoObjectivesText:SetTextColor(unpack(textColor))
				QuestInfoGroupSize:SetTextColor(unpack(textColor))
				QuestInfoRewardText:SetTextColor(unpack(textColor))
				-- reward frame text
				QuestInfoItemChooseText:SetTextColor(unpack(textColor))
				QuestInfoItemReceiveText:SetTextColor(unpack(textColor))
				QuestInfoSpellLearnText:SetTextColor(unpack(textColor))
				QuestInfoXPFrameReceiveText:SetTextColor(unpack(textColor))	
				
				QuestObjectiveText()
			end)
			
			hooksecurefunc("QuestInfo_ShowRequiredMoney", function()
				local requiredMoney = GetQuestLogRequiredMoney()
				if ( requiredMoney > 0 ) then
					if ( requiredMoney > GetMoney() ) then
						-- Not enough money
						QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
					else
						QuestInfoRequiredMoneyText:SetTextColor(1, 1, 0)
					end
				end			
			end)		
			
			QuestLogFrame:HookScript("OnShow", function()
				QuestLogScrollFrame:Height(QuestLogScrollFrame:GetHeight() - 4)
				QuestLogDetailScrollFrame:Height(QuestLogScrollFrame:GetHeight() - 4)
				
				QuestLogScrollFrame:SetTemplate("Default")
				QuestLogDetailScrollFrame:CreateBackdrop("Default")
			end)
		end
		
		
		--Dressing Room Frame
		if C["skin"].dressingroom == true then
			DressUpFrame:StripTextures(true)
			DressUpFrame:CreateBackdrop("Transparent")
			DressUpFrame.backdrop:CreateShadow("Default")
			DressUpFrame.backdrop:Point("TOPLEFT", 6, 0)
			DressUpFrame.backdrop:Point("BOTTOMRIGHT", -32, 70)
			
			SkinButton(DressUpFrameResetButton)
			SkinButton(DressUpFrameCancelButton)
			SkinCloseButton(DressUpFrameCloseButton, DressUpFrame.backdrop)
			SkinRotateButton(DressUpModelRotateLeftButton)
			SkinRotateButton(DressUpModelRotateRightButton)
			DressUpModelRotateRightButton:Point("TOPLEFT", DressUpModelRotateLeftButton, "TOPRIGHT", 2, 0)
			DressUpFrameResetButton:Point("RIGHT", DressUpFrameCancelButton, "LEFT", -2, 0)
		end
		
		--Honor/Conquest Pane
		if C["skin"].pvp == true then
			local buttons = {
				"PVPFrameLeftButton",
				"PVPFrameRightButton",
				"PVPColorPickerButton1",
				"PVPColorPickerButton2",
				"PVPColorPickerButton3",
				"PVPBannerFrameAcceptButton",
			}
			
			if not E.IsPTRVersion() then
				tinsert(buttons, "PVPHonorFrameWarGameButton")
			end
			
			for i = 1, #buttons do
				_G[buttons[i]]:StripTextures()
				SkinButton(_G[buttons[i]])
			end

			local KillTextures = {
				"PVPHonorFrameBGTex",
				"PVPHonorFrameInfoScrollFrameScrollBar",
				"PVPConquestFrameInfoButtonInfoBG",
				"PVPConquestFrameInfoButtonInfoBGOff",
				"PVPTeamManagementFrameFlag2GlowBG",
				"PVPTeamManagementFrameFlag3GlowBG",
				"PVPTeamManagementFrameFlag5GlowBG",
				"PVPTeamManagementFrameFlag2HeaderSelected",
				"PVPTeamManagementFrameFlag3HeaderSelected",
				"PVPTeamManagementFrameFlag5HeaderSelected",
				"PVPTeamManagementFrameFlag2Header",
				"PVPTeamManagementFrameFlag3Header",
				"PVPTeamManagementFrameFlag5Header",
				"PVPTeamManagementFrameWeeklyDisplayLeft",
				"PVPTeamManagementFrameWeeklyDisplayRight",
				"PVPTeamManagementFrameWeeklyDisplayMiddle",
				"PVPBannerFramePortrait",
				"PVPBannerFramePortraitFrame",
				"PVPBannerFrameInset",
				"PVPBannerFrameEditBoxLeft",
				"PVPBannerFrameEditBoxRight",
				"PVPBannerFrameEditBoxMiddle",
				"PVPBannerFrameCancelButton_LeftSeparator",
			}

			for _, texture in pairs(KillTextures) do
				_G[texture]:Kill()
			end

			local StripAllTextures = {
				"PVPFrame",
				"PVPFrameInset",
				"PVPHonorFrame",
				"PVPConquestFrame",
				"PVPTeamManagementFrame",
				"PVPHonorFrameTypeScrollFrame",
				"PVPFrameTopInset",
				"PVPTeamManagementFrameInvalidTeamFrame",
				"PVPBannerFrame",
				"PVPBannerFrameCustomization1",
				"PVPBannerFrameCustomization2",
				"PVPBannerFrameCustomizationFrame",
			}

			for _, object in pairs(StripAllTextures) do
				_G[object]:StripTextures()
			end

			local function ArenaHeader(self, first, i)
				local button = _G["PVPTeamManagementFrameHeader"..i]

				if first then
					button:StripTextures()
				end
			end

			for i=1, 4 do
				ArenaHeader(nil, true, i)
			end	

			PVPBannerFrameEditBox:CreateBackdrop("Default")
			PVPBannerFrameEditBox.backdrop:Point( "TOPLEFT", PVPBannerFrameEditBox, "TOPLEFT" ,-5,-5)
			PVPBannerFrameEditBox.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrameEditBox, "BOTTOMRIGHT",5,5)
			PVPHonorFrameInfoScrollFrameChildFrameDescription:SetTextColor(1,1,1)
			PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(1,1,1)
			PVPTeamManagementFrameInvalidTeamFrame:CreateBackdrop("Default")
			PVPTeamManagementFrameInvalidTeamFrame:SetFrameLevel(PVPTeamManagementFrameInvalidTeamFrame:GetFrameLevel()+1)
			PVPTeamManagementFrameInvalidTeamFrame.backdrop:Point( "TOPLEFT", PVPTeamManagementFrameInvalidTeamFrame, "TOPLEFT")
			PVPTeamManagementFrameInvalidTeamFrame.backdrop:Point( "BOTTOMRIGHT", PVPTeamManagementFrameInvalidTeamFrame, "BOTTOMRIGHT")
			PVPTeamManagementFrameInvalidTeamFrame.backdrop:SetFrameLevel(PVPTeamManagementFrameInvalidTeamFrame:GetFrameLevel())

			if not E.IsPTRVersion() then
				PVPFrameConquestBar:StripTextures()
				PVPFrameConquestBar:SetStatusBarTexture(C["media"].normTex)
				PVPFrameConquestBar:CreateBackdrop("Default")
			else
				PVPFrameConquestBarLeft:Kill()
				PVPFrameConquestBarRight:Kill()
				PVPFrameConquestBarMiddle:Kill()
				PVPFrameConquestBarBG:Kill()
				PVPFrameConquestBarShadow:Kill()
				PVPFrameConquestBar.progress:SetTexture(C["media"].normTex)
				PVPFrameConquestBar:CreateBackdrop("Default")
				PVPFrameConquestBar.backdrop:Point("TOPLEFT", PVPFrameConquestBar.progress, "TOPLEFT", -2, 2)
				PVPFrameConquestBar.backdrop:Point("BOTTOMRIGHT", PVPFrameConquestBar, "BOTTOMRIGHT", -2, 2)			
			end
			
			PVPBannerFrame:CreateBackdrop("Transparent")
			PVPBannerFrame.backdrop:Point( "TOPLEFT", PVPBannerFrame, "TOPLEFT")
			PVPBannerFrame.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrame, "BOTTOMRIGHT")
			PVPBannerFrameCustomization1:CreateBackdrop("Default")
			PVPBannerFrameCustomization1.backdrop:Point( "TOPLEFT", PVPBannerFrameCustomization1LeftButton, "TOPRIGHT" ,2,0)
			PVPBannerFrameCustomization1.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrameCustomization1RightButton, "BOTTOMLEFT",-2,0)
			PVPBannerFrameCustomization2:CreateBackdrop("Default")
			PVPBannerFrameCustomization2.backdrop:Point( "TOPLEFT", PVPBannerFrameCustomization2LeftButton, "TOPRIGHT",2,0)
			PVPBannerFrameCustomization2.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrameCustomization2RightButton, "BOTTOMLEFT",-2,0)
			SkinCloseButton(PVPBannerFrameCloseButton,PVPBannerFrame)
			SkinNextPrevButton(PVPBannerFrameCustomization1LeftButton)
			PVPBannerFrameCustomization1LeftButton:Height(PVPBannerFrameCustomization1:GetHeight())
			SkinNextPrevButton(PVPBannerFrameCustomization1RightButton)
			PVPBannerFrameCustomization1RightButton:Height(PVPBannerFrameCustomization1:GetHeight())
			SkinNextPrevButton(PVPBannerFrameCustomization2LeftButton)
			PVPBannerFrameCustomization2LeftButton:Height(PVPBannerFrameCustomization1:GetHeight())
			SkinNextPrevButton(PVPBannerFrameCustomization2RightButton)
			PVPBannerFrameCustomization2RightButton:Height(PVPBannerFrameCustomization1:GetHeight())
			PVPFrame:CreateBackdrop("Transparent")
			PVPFrame.backdrop:Point( "TOPLEFT", PVPFrame, "TOPLEFT")
			PVPFrame.backdrop:Point( "BOTTOMRIGHT", PVPFrame, "BOTTOMRIGHT")
			SkinCloseButton(PVPFrameCloseButton,PVPFrame)
			SkinNextPrevButton(PVPTeamManagementFrameWeeklyToggleLeft)
			SkinNextPrevButton(PVPTeamManagementFrameWeeklyToggleRight)
			PVPColorPickerButton1:Height(PVPColorPickerButton1:GetHeight()-5)
			PVPColorPickerButton2:Height(PVPColorPickerButton1:GetHeight())
			PVPColorPickerButton3:Height(PVPColorPickerButton1:GetHeight())
			
			--War Games
			if E.IsPTRVersion() then
				SkinButton(WarGameStartButton, true)
				WarGamesFrame:StripTextures()
				SkinScrollBar(WarGamesFrameScrollFrameScrollBar)
				
				WarGameStartButton:ClearAllPoints()
				WarGameStartButton:Point("LEFT", PVPFrameLeftButton, "RIGHT", 2, 0)
				WarGamesFrameDescription:SetTextColor(1, 1, 1)
			end
			
			--Freaking gay Cancel Button FFSlocal
			local f = PVPBannerFrameCancelButton
			local l = _G[f:GetName().."Left"]
			local m = _G[f:GetName().."Middle"]
			local r = _G[f:GetName().."Right"]
			if l then l:SetAlpha(0) end
			if m then m:SetAlpha(0) end
			if r then r:SetAlpha(0) end
			f:CreateBackdrop("Default")
			f:SetFrameLevel(PVPBannerFrameAcceptButton:GetFrameLevel()+1)
			f.backdrop:Point( "TOPLEFT", PVPBannerFrameAcceptButton, "TOPLEFT", PVPBannerFrame:GetWidth()-PVPBannerFrameAcceptButton:GetWidth()-10,0)
			f.backdrop:Point( "BOTTOMRIGHT", PVPBannerFrameAcceptButton, "BOTTOMRIGHT", PVPBannerFrame:GetWidth()-PVPBannerFrameAcceptButton:GetWidth()-10, 0)
			f.backdrop:SetFrameLevel(f:GetFrameLevel()-1)
			
			--Bottom Tabs
			if not E.IsPTRVersion() then
				for i=1,3 do
					SkinTab(_G["PVPFrameTab"..i])
				end
			else
				for i=1,4 do
					SkinTab(_G["PVPFrameTab"..i])
				end			
			end
		end	
	
		--NonRaid Frame
		if C["skin"].nonraid == true then
			local StripAllTextures = {
				"RaidInfoFrame",
				"RaidInfoInstanceLabel",
				"RaidInfoIDLabel",
			}

			local KillTextures = {
				"RaidInfoScrollFrameScrollBarBG",
				"RaidInfoScrollFrameScrollBarTop",
				"RaidInfoScrollFrameScrollBarBottom",
				"RaidInfoScrollFrameScrollBarMiddle",
			}
			local buttons = {
				"RaidFrameConvertToRaidButton",
				"RaidFrameRaidInfoButton",
				"RaidFrameNotInRaidRaidBrowserButton",
				"RaidInfoExtendButton",
				"RaidInfoCancelButton",
			}

			for _, object in pairs(StripAllTextures) do
				_G[object]:StripTextures()
			end

			for _, texture in pairs(KillTextures) do
				_G[texture]:Kill()
			end

			for i = 1, #buttons do
				SkinButton(_G[buttons[i]])
			end
			RaidInfoScrollFrame:StripTextures()
			RaidInfoFrame:CreateBackdrop("Transparent")
			RaidInfoFrame.backdrop:Point( "TOPLEFT", RaidInfoFrame, "TOPLEFT")
			RaidInfoFrame.backdrop:Point( "BOTTOMRIGHT", RaidInfoFrame, "BOTTOMRIGHT")
			SkinCloseButton(RaidInfoCloseButton,RaidInfoFrame)

		end
		
		--Social Frame
		local function SkinSocialHeaderTab(tab)
			if not tab then return end
			for _, object in pairs(tabs) do
				local tex = _G[tab:GetName()..object]
				tex:SetTexture(nil)
			end
			tab:GetHighlightTexture():SetTexture(nil)
			tab.backdrop = CreateFrame("Frame", nil, tab)
			tab.backdrop:SetTemplate("Default")
			tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
			tab.backdrop:Point("TOPLEFT", 3, -8)
			tab.backdrop:Point("BOTTOMRIGHT", -6, 0)
		end

		--Friends/Social Pane
		if C["skin"].friends == true then
			local StripAllTextures = {
				"FriendsListFrame",
				"FriendsTabHeader",
				"FriendsFrameFriendsScrollFrame",
				"WhoFrameColumnHeader1",
				"WhoFrameColumnHeader2",
				"WhoFrameColumnHeader3",
				"WhoFrameColumnHeader4",
				"ChannelListScrollFrame",
				"ChannelRoster",
				"FriendsFramePendingButton1",
				"FriendsFramePendingButton2",
				"FriendsFramePendingButton3",
				"FriendsFramePendingButton4",
				"ChannelFrameDaughterFrame",
				"AddFriendFrame",
				"AddFriendNoteFrame",
			}			

			local KillTextures = {
				"FriendsFrameTopLeft",
				"FriendsFrameTopRight",
				"FriendsFrameBottomLeft",
				"FriendsFrameBottomRight",
				"ChannelFrameVerticalBar",
				"FriendsFrameBroadcastInputLeft",
				"FriendsFrameBroadcastInputRight",
				"FriendsFrameBroadcastInputMiddle",
				"ChannelFrameDaughterFrameChannelNameLeft",
				"ChannelFrameDaughterFrameChannelNameRight",
				"ChannelFrameDaughterFrameChannelNameMiddle",
				"ChannelFrameDaughterFrameChannelPasswordLeft",
				"ChannelFrameDaughterFrameChannelPasswordRight",				
				"ChannelFrameDaughterFrameChannelPasswordMiddle",			
			}

			local buttons = {
				"FriendsFrameAddFriendButton",
				"FriendsFrameSendMessageButton",
				"WhoFrameWhoButton",
				"WhoFrameAddFriendButton",
				"WhoFrameGroupInviteButton",
				"ChannelFrameNewButton",
				"FriendsFrameIgnorePlayerButton",
				"FriendsFrameUnsquelchButton",
				"FriendsFramePendingButton1AcceptButton",
				"FriendsFramePendingButton1DeclineButton",
				"FriendsFramePendingButton2AcceptButton",
				"FriendsFramePendingButton2DeclineButton",
				"FriendsFramePendingButton3AcceptButton",
				"FriendsFramePendingButton3DeclineButton",
				"FriendsFramePendingButton4AcceptButton",
				"FriendsFramePendingButton4DeclineButton",
				"ChannelFrameDaughterFrameOkayButton",
				"ChannelFrameDaughterFrameCancelButton",
				"AddFriendEntryFrameAcceptButton",
				"AddFriendEntryFrameCancelButton",
				"AddFriendInfoFrameContinueButton",
			}			

			for _, button in pairs(buttons) do
				SkinButton(_G[button])
			end
			--Reposition buttons
			WhoFrameWhoButton:Point("RIGHT", WhoFrameAddFriendButton, "LEFT", -2, 0)
			WhoFrameAddFriendButton:Point("RIGHT", WhoFrameGroupInviteButton, "LEFT", -2, 0)
			WhoFrameGroupInviteButton:Point("BOTTOMRIGHT", WhoFrame, "BOTTOMRIGHT", -44, 82)
			--Resize Buttons
			WhoFrameWhoButton:Size(WhoFrameWhoButton:GetWidth() - 4, WhoFrameWhoButton:GetHeight())
			WhoFrameAddFriendButton:Size(WhoFrameAddFriendButton:GetWidth() - 4, WhoFrameAddFriendButton:GetHeight())
			WhoFrameGroupInviteButton:Size(WhoFrameGroupInviteButton:GetWidth() - 4, WhoFrameGroupInviteButton:GetHeight())
			SkinEditBox(WhoFrameEditBox)
			WhoFrameEditBox:Height(WhoFrameEditBox:GetHeight() - 15)
			WhoFrameEditBox:Point("BOTTOM", WhoFrame, "BOTTOM", -10, 108)
			WhoFrameEditBox:Width(WhoFrameEditBox:GetWidth() + 17)
			
			for _, texture in pairs(KillTextures) do
				_G[texture]:Kill()
			end

			for _, object in pairs(StripAllTextures) do
				_G[object]:StripTextures()
			end
			FriendsFrame:StripTextures(true)

			SkinEditBox(AddFriendNameEditBox)
			AddFriendFrame:SetTemplate("Transparent")			
			
			--Who Frame
			local function UpdateWhoSkins()
				WhoListScrollFrame:StripTextures()
			end
			--Channel Frame
			local function UpdateChannel()
				ChannelRosterScrollFrame:StripTextures()
			end
			--BNet Frame
			FriendsFrameBroadcastInput:CreateBackdrop("Default")
			ChannelFrameDaughterFrameChannelName:CreateBackdrop("Default")
			ChannelFrameDaughterFrameChannelPassword:CreateBackdrop("Default")			

			ChannelFrame:HookScript("OnShow", UpdateChannel)
			hooksecurefunc("FriendsFrame_OnEvent", UpdateChannel)

			WhoFrame:HookScript("OnShow", UpdateWhoSkins)
			hooksecurefunc("FriendsFrame_OnEvent", UpdateWhoSkins)

			ChannelFrameDaughterFrame:CreateBackdrop("Transparent")
			FriendsFrame:CreateBackdrop("Transparent")
			FriendsFrame.backdrop:Point( "TOPLEFT", FriendsFrame, "TOPLEFT", 11,-12)
			FriendsFrame.backdrop:Point( "BOTTOMRIGHT", FriendsFrame, "BOTTOMRIGHT", -35, 76)
			SkinCloseButton(ChannelFrameDaughterFrameDetailCloseButton,ChannelFrameDaughterFrame)
			SkinCloseButton(FriendsFrameCloseButton,FriendsFrame.backdrop)
			SkinDropDownBox(WhoFrameDropDown,150)
			SkinDropDownBox(FriendsFrameStatusDropDown,70)

			--Bottom Tabs
			for i=1, 4 do
				SkinTab(_G["FriendsFrameTab"..i])
			end

			for i=1, 3 do
				SkinSocialHeaderTab(_G["FriendsTabHeaderTab"..i])
			end

			local function Channel()
				for i=1, MAX_DISPLAY_CHANNEL_BUTTONS do
					local button = _G["ChannelButton"..i]
					if button then
						button:StripTextures()
						button:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
						
						_G["ChannelButton"..i.."Text"]:SetFont(FONT, 12)
					end
				end
			end
			hooksecurefunc("ChannelList_Update", Channel)
		end
		
		--Spellbook
		if C["skin"].spellbook == true then
			SkinCloseButton(SpellBookFrameCloseButton)
			
			local StripAllTextures = {
				"SpellBookFrame",
				"SpellBookFrameInset",
				"SpellBookSpellIconsFrame",
				"SpellBookSideTabsFrame",
				"SpellBookPageNavigationFrame",
			}
			
			local KillTextures = {
				"SpellBookPage1",
				"SpellBookPage2",
			}
			
			for _, object in pairs(StripAllTextures) do
				_G[object]:StripTextures()
			end
			
			for _, texture in pairs(KillTextures) do
				_G[texture]:Kill()
			end
			
			local pagebackdrop = CreateFrame("Frame", nil, SpellBookPage1:GetParent())
			pagebackdrop:SetTemplate("Transparent")
			pagebackdrop:Point("TOPLEFT", SpellBookFrame, "TOPLEFT", 50, -50)
			pagebackdrop:Point("BOTTOMRIGHT", SpellBookPage1, "BOTTOMRIGHT", 15, 35)

			SkinNextPrevButton(SpellBookPrevPageButton)
			SkinNextPrevButton(SpellBookNextPageButton)
			
			--Skin SpellButtons
			local function SpellButtons(self, first)
				for i=1, SPELLS_PER_PAGE do
					local button = _G["SpellButton"..i]
					local icon = _G["SpellButton"..i.."IconTexture"]
					
					if first then
						--button:StripTextures()
						for i=1, button:GetNumRegions() do
							local region = select(i, button:GetRegions())
							if region:GetObjectType() == "Texture" then
								if region:GetTexture() ~= "Interface\\Buttons\\ActionBarFlyoutButton" then
									region:SetTexture(nil)
								end
							end
						end
					end
					
					if _G["SpellButton"..i.."Highlight"] then
						_G["SpellButton"..i.."Highlight"]:SetTexture(1, 1, 1, 0.3)
						_G["SpellButton"..i.."Highlight"]:ClearAllPoints()
						_G["SpellButton"..i.."Highlight"]:SetAllPoints(icon)
					end

					if icon then
						icon:SetTexCoord(.08, .92, .08, .92)
						icon:ClearAllPoints()
						icon:SetAllPoints()

						if not button.backdrop then
							button:CreateBackdrop("Default", true)	
						end
					end	
					
					local r, g, b = _G["SpellButton"..i.."SpellName"]:GetTextColor()

					if r < 0.8 then
						_G["SpellButton"..i.."SpellName"]:SetTextColor(0.6, 0.6, 0.6)
					end
					_G["SpellButton"..i.."SubSpellName"]:SetTextColor(0.6, 0.6, 0.6)
					_G["SpellButton"..i.."RequiredLevelString"]:SetTextColor(0.6, 0.6, 0.6)
				end
			end
			SpellButtons(nil, true)
			hooksecurefunc("SpellButton_UpdateButton", SpellButtons)
			
			SpellBookPageText:SetTextColor(0.6, 0.6, 0.6)
			
			--Skill Line Tabs
			for i=1, MAX_SKILLLINE_TABS do
				local tab = _G["SpellBookSkillLineTab"..i]
				_G["SpellBookSkillLineTab"..i.."Flash"]:Kill()
				if tab then
					tab:StripTextures()
					tab:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
					tab:GetNormalTexture():ClearAllPoints()
					tab:GetNormalTexture():Point("TOPLEFT", 2, -2)
					tab:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
					
					tab:CreateBackdrop("Default")
					tab.backdrop:SetAllPoints()
					tab:StyleButton(true)				
					
					local point, relatedTo, point2, x, y = tab:GetPoint()
					tab:Point(point, relatedTo, point2, 1, y)
				end
			end
			
			local function SkinSkillLine()
				for i=1, MAX_SKILLLINE_TABS do
					local tab = _G["SpellBookSkillLineTab"..i]
					local _, _, _, _, isGuild = GetSpellTabInfo(i)
					if isGuild then
						tab:GetNormalTexture():ClearAllPoints()
						tab:GetNormalTexture():Point("TOPLEFT", 2, -2)
						tab:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)	
						tab:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)					
					end
				end
			end
			hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", SkinSkillLine)
			SpellBookFrame:SetTemplate("Transparent")
			SpellBookFrame:CreateShadow("Default")
			
			--Profession Tab
			local professionbuttons = {
				"PrimaryProfession1SpellButtonTop",
				"PrimaryProfession1SpellButtonBottom",
				"PrimaryProfession2SpellButtonTop",
				"PrimaryProfession2SpellButtonBottom",
				"SecondaryProfession1SpellButtonLeft",
				"SecondaryProfession1SpellButtonRight",
				"SecondaryProfession2SpellButtonLeft",
				"SecondaryProfession2SpellButtonRight",
				"SecondaryProfession3SpellButtonLeft",
				"SecondaryProfession3SpellButtonRight",
				"SecondaryProfession4SpellButtonLeft",
				"SecondaryProfession4SpellButtonRight",		
			}
			
			local professionheaders = {
				"PrimaryProfession1",
				"PrimaryProfession2",
				"SecondaryProfession1",
				"SecondaryProfession2",
				"SecondaryProfession3",
				"SecondaryProfession4",
			}
			
			for _, header in pairs(professionheaders) do
				_G[header.."Missing"]:SetTextColor(1, 1, 0)
				_G[header].missingText:SetTextColor(0.6, 0.6, 0.6)
			end
			
			for _, button in pairs(professionbuttons) do
				local icon = _G[button.."IconTexture"]
				local button = _G[button]
				button:StripTextures()
				
				if icon then
					icon:SetTexCoord(.08, .92, .08, .92)
					icon:ClearAllPoints()
					icon:Point("TOPLEFT", 2, -2)
					icon:Point("BOTTOMRIGHT", -2, 2)
					
					button:SetFrameLevel(button:GetFrameLevel() + 2)
					if not button.backdrop then
						button:CreateBackdrop("Default", true)	
						button.backdrop:SetAllPoints()
					end
				end					
			end
			
			local professionstatusbars = {
				"PrimaryProfession1StatusBar",	
				"PrimaryProfession2StatusBar",	
				"SecondaryProfession1StatusBar",	
				"SecondaryProfession2StatusBar",	
				"SecondaryProfession3StatusBar",	
				"SecondaryProfession4StatusBar",
			}
			
			for _, statusbar in pairs(professionstatusbars) do
				local statusbar = _G[statusbar]
				statusbar:StripTextures()
				statusbar:SetStatusBarTexture(C["media"].normTex)
				statusbar:SetStatusBarColor(0, 220/255, 0)
				statusbar:CreateBackdrop("Default")
				
				statusbar.rankText:ClearAllPoints()
				statusbar.rankText:SetPoint("CENTER")
			end
			
			--Mounts/Companions
			for i = 1, NUM_COMPANIONS_PER_PAGE do
				local button = _G["SpellBookCompanionButton"..i]
				local icon = _G["SpellBookCompanionButton"..i.."IconTexture"]
				button:StripTextures()
				button:StyleButton(false)
				
				if icon then
					icon:SetTexCoord(.08, .92, .08, .92)
					icon:ClearAllPoints()
					icon:Point("TOPLEFT", 2, -2)
					icon:Point("BOTTOMRIGHT", -2, 2)
					
					button:SetFrameLevel(button:GetFrameLevel() + 2)
					if not button.backdrop then
						button:CreateBackdrop("Default", true)	
						button.backdrop:SetAllPoints()
					end
				end					
			end
			
			SkinButton(SpellBookCompanionSummonButton)
			SpellBookCompanionModelFrame:StripTextures()
			SpellBookCompanionModelFrameShadowOverlay:StripTextures()
			SpellBookCompanionsModelFrame:Kill()
			SpellBookCompanionModelFrame:SetTemplate("Default")
			
			SkinRotateButton(SpellBookCompanionModelFrameRotateRightButton)
			SkinRotateButton(SpellBookCompanionModelFrameRotateLeftButton)
			SpellBookCompanionModelFrameRotateRightButton:Point("TOPLEFT", SpellBookCompanionModelFrameRotateLeftButton, "TOPRIGHT", 3, 0)
			
			
			--Bottom Tabs
			for i=1, 5 do
				SkinTab(_G["SpellBookFrameTabButton"..i])
			end
		end
		
		--Character Frame
		if C["skin"].character == true then
			SkinCloseButton(CharacterFrameCloseButton)
			
			local slots = {
				"HeadSlot",
				"NeckSlot",
				"ShoulderSlot",
				"BackSlot",
				"ChestSlot",
				"ShirtSlot",
				"TabardSlot",
				"WristSlot",
				"HandsSlot",
				"WaistSlot",
				"LegsSlot",
				"FeetSlot",
				"Finger0Slot",
				"Finger1Slot",
				"Trinket0Slot",
				"Trinket1Slot",
				"MainHandSlot",
				"SecondaryHandSlot",
				"RangedSlot",
			}
			for _, slot in pairs(slots) do
				local icon = _G["Character"..slot.."IconTexture"]
				local slot = _G["Character"..slot]
				slot:StripTextures()
				slot:StyleButton(false)
				icon:SetTexCoord(.08, .92, .08, .92)
				icon:ClearAllPoints()
				icon:Point("TOPLEFT", 2, -2)
				icon:Point("BOTTOMRIGHT", -2, 2)
				
				slot:SetFrameLevel(slot:GetFrameLevel() + 2)
				slot:CreateBackdrop("Default")
				slot.backdrop:SetAllPoints()
			end
			
			--Strip Textures
			local charframe = {
				"CharacterFrame",
				"CharacterModelFrame",
				"CharacterFrameInset", 
				"CharacterStatsPane",
				"CharacterFrameInsetRight",
				"PaperDollSidebarTabs",
				"PaperDollEquipmentManagerPane",
				"PaperDollFrameItemFlyout",
			}
			
			CharacterFrameExpandButton:Size(CharacterFrameExpandButton:GetWidth() - 7, CharacterFrameExpandButton:GetHeight() - 7)
			SkinNextPrevButton(CharacterFrameExpandButton)
			
			SkinRotateButton(CharacterModelFrameRotateLeftButton)
			SkinRotateButton(CharacterModelFrameRotateRightButton)
			CharacterModelFrameRotateLeftButton:Point("TOPLEFT", CharacterModelFrame, "TOPLEFT", 4, -4)
			CharacterModelFrameRotateRightButton:Point("TOPLEFT", CharacterModelFrameRotateLeftButton, "TOPRIGHT", 4, 0)
			
			--Swap item flyout frame (shown when holding alt over a slot)
			PaperDollFrameItemFlyout:HookScript("OnShow", function()
				PaperDollFrameItemFlyoutButtons:StripTextures()
				
				for i=1, PDFITEMFLYOUT_MAXITEMS do
					local button = _G["PaperDollFrameItemFlyoutButtons"..i]
					local icon = _G["PaperDollFrameItemFlyoutButtons"..i.."IconTexture"]
					if button then
						button:StyleButton(false)
						
						icon:SetTexCoord(.08, .92, .08, .92)
						button:GetNormalTexture():SetTexture(nil)
						
						icon:ClearAllPoints()
						icon:Point("TOPLEFT", 2, -2)
						icon:Point("BOTTOMRIGHT", -2, 2)	
						button:SetFrameLevel(button:GetFrameLevel() + 2)
						if not button.backdrop then
							button:CreateBackdrop("Default")
							button.backdrop:SetAllPoints()			
						end
					end
				end
			end)
			
			--Icon in upper right corner of character frame
			CharacterFramePortrait:Kill()
			CharacterModelFrame:CreateBackdrop("Default")

			local scrollbars = {
				"PaperDollTitlesPaneScrollBar",
				"PaperDollEquipmentManagerPaneScrollBar",
			}
			
			for _, scrollbar in pairs(scrollbars) do
				SkinScrollBar(_G[scrollbar])
			end
			
			for _, object in pairs(charframe) do
				_G[object]:StripTextures()
			end
			
			--Titles
			PaperDollTitlesPane:HookScript("OnShow", function(self)
				for x, object in pairs(PaperDollTitlesPane.buttons) do
					object.BgTop:SetTexture(nil)
					object.BgBottom:SetTexture(nil)
					object.BgMiddle:SetTexture(nil)

					object.Check:SetTexture(nil)
					object.text:SetFont(C["media"].font,C["general"].fontscale)
					object.text.SetFont = E.dummy
				end
			end)
			
			--Equipement Manager
			SkinButton(PaperDollEquipmentManagerPaneEquipSet)
			SkinButton(PaperDollEquipmentManagerPaneSaveSet)
			PaperDollEquipmentManagerPaneEquipSet:Width(PaperDollEquipmentManagerPaneEquipSet:GetWidth() - 8)
			PaperDollEquipmentManagerPaneSaveSet:Width(PaperDollEquipmentManagerPaneSaveSet:GetWidth() - 8)
			PaperDollEquipmentManagerPaneEquipSet:Point("TOPLEFT", PaperDollEquipmentManagerPane, "TOPLEFT", 8, 0)
			PaperDollEquipmentManagerPaneSaveSet:Point("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 4, 0)
			PaperDollEquipmentManagerPaneEquipSet.ButtonBackground:SetTexture(nil)
			PaperDollEquipmentManagerPane:HookScript("OnShow", function(self)
				for x, object in pairs(PaperDollEquipmentManagerPane.buttons) do
					object.BgTop:SetTexture(nil)
					object.BgBottom:SetTexture(nil)
					object.BgMiddle:SetTexture(nil)

					object.Check:SetTexture(nil)
					object.icon:SetTexCoord(.08, .92, .08, .92)
					
					if not object.backdrop then
						object:CreateBackdrop("Default")
					end
					
					object.backdrop:Point("TOPLEFT", object.icon, "TOPLEFT", -2, 2)
					object.backdrop:Point("BOTTOMRIGHT", object.icon, "BOTTOMRIGHT", 2, -2)
					object.icon:SetParent(object.backdrop)

					--Making all icons the same size and position because otherwise BlizzardUI tries to attach itself to itself when it refreshes
					object.icon:SetPoint("LEFT", object, "LEFT", 4, 0)
					object.icon.SetPoint = E.dummy
					object.icon:Size(36, 36)
					object.icon.SetSize = E.dummy
				end
				GearManagerDialogPopup:StripTextures()
				GearManagerDialogPopup:SetTemplate("Transparent")
				GearManagerDialogPopup:Point("LEFT", PaperDollFrame, "RIGHT", 4, 0)
				GearManagerDialogPopupScrollFrame:StripTextures()
				GearManagerDialogPopupEditBox:StripTextures()
				GearManagerDialogPopupEditBox:SetTemplate("Default")
				SkinButton(GearManagerDialogPopupOkay)
				SkinButton(GearManagerDialogPopupCancel)
				
				for i=1, NUM_GEARSET_ICONS_SHOWN do
					local button = _G["GearManagerDialogPopupButton"..i]
					local icon = button.icon
					
					if button then
						button:StripTextures()
						button:StyleButton(true)
						
						icon:SetTexCoord(.08, .92, .08, .92)
						_G["GearManagerDialogPopupButton"..i.."Icon"]:SetTexture(nil)
						
						icon:ClearAllPoints()
						icon:Point("TOPLEFT", 2, -2)
						icon:Point("BOTTOMRIGHT", -2, 2)	
						button:SetFrameLevel(button:GetFrameLevel() + 2)
						if not button.backdrop then
							button:CreateBackdrop("Default")
							button.backdrop:SetAllPoints()			
						end
					end
				end
			end)
			
			--Handle Tabs at bottom of character frame
			for i=1, 4 do
				SkinTab(_G["CharacterFrameTab"..i])
			end
			
			--Buttons used to toggle between equipment manager, titles, and character stats
			local function FixSidebarTabCoords()
				for i=1, #PAPERDOLL_SIDEBARS do
					local tab = _G["PaperDollSidebarTab"..i]
					if tab then
						tab.Highlight:SetTexture(1, 1, 1, 0.3)
						tab.Highlight:Point("TOPLEFT", 3, -4)
						tab.Highlight:Point("BOTTOMRIGHT", -1, 0)
						tab.Hider:SetTexture(0.4,0.4,0.4,0.4)
						tab.Hider:Point("TOPLEFT", 3, -4)
						tab.Hider:Point("BOTTOMRIGHT", -1, 0)
						tab.TabBg:Kill()
						
						if i == 1 then
							for i=1, tab:GetNumRegions() do
								local region = select(i, tab:GetRegions())
								region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
								region.SetTexCoord = E.dummy
							end
						end
						tab:CreateBackdrop("Default")
						tab.backdrop:Point("TOPLEFT", 1, -2)
						tab.backdrop:Point("BOTTOMRIGHT", 1, -2)	
					end
				end
			end
			hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", FixSidebarTabCoords)
			
			--Stat panels, atm it looks like 7 is the max
			for i=1, 7 do
				_G["CharacterStatsPaneCategory"..i]:StripTextures()
			end
			
			--Reputation
			local function UpdateFactionSkins()
				ReputationListScrollFrame:StripTextures()
				ReputationFrame:StripTextures(true)
				for i=1, GetNumFactions() do
					local statusbar = _G["ReputationBar"..i.."ReputationBar"]

					if statusbar then
						statusbar:SetStatusBarTexture(C["media"].normTex)
						
						if not statusbar.backdrop then
							statusbar:CreateBackdrop("Default")
						end
						
						_G["ReputationBar"..i.."Background"]:SetTexture(nil)
						_G["ReputationBar"..i.."LeftLine"]:Kill()
						_G["ReputationBar"..i.."BottomLine"]:Kill()
						_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
						_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)	
						_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
						_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
						_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
						_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)
						
					end		
				end
				ReputationDetailFrame:StripTextures()
				ReputationDetailFrame:SetTemplate("Transparent")
				ReputationDetailFrame:Point("TOPLEFT", ReputationFrame, "TOPRIGHT", 4, -28)			
			end	
			ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
			hooksecurefunc("ReputationFrame_OnEvent", UpdateFactionSkins)
			
			--Currency
			TokenFrame:HookScript("OnShow", function()
				for i=1, GetCurrencyListSize() do
					local button = _G["TokenFrameContainerButton"..i]
					
					if button then
						button.highlight:Kill()
						button.categoryMiddle:Kill()	
						button.categoryLeft:Kill()	
						button.categoryRight:Kill()
						
						if button.icon then
							button.icon:SetTexCoord(.08, .92, .08, .92)
						end
					end
				end
				TokenFramePopup:StripTextures()
				TokenFramePopup:SetTemplate("Transparent")
				TokenFramePopup:Point("TOPLEFT", TokenFrame, "TOPRIGHT", 4, -28)				
			end)
			
			--Pet
			PetModelFrame:CreateBackdrop("Default")
			PetPaperDollFrameExpBar:StripTextures()
			PetPaperDollFrameExpBar:SetStatusBarTexture(C["media"].normTex)
			PetPaperDollFrameExpBar:CreateBackdrop("Default")
			SkinRotateButton(PetModelFrameRotateRightButton)
			SkinRotateButton(PetModelFrameRotateLeftButton)
			PetModelFrameRotateRightButton:ClearAllPoints()
			PetModelFrameRotateRightButton:Point("LEFT", PetModelFrameRotateLeftButton, "RIGHT", 4, 0)
			
			local xtex = PetPaperDollPetInfo:GetRegions()
			xtex:SetTexCoord(.12, .63, .15, .55)
			PetPaperDollPetInfo:CreateBackdrop("Default")
			PetPaperDollPetInfo:Size(24, 24)
		end
		
		
		if C["skin"].misc == true then
			-- Blizzard frame we want to reskin
			local skins = {
				"StaticPopup1",
				"StaticPopup2",
				"StaticPopup3",
				"GameMenuFrame",
				"InterfaceOptionsFrame",
				"VideoOptionsFrame",
				"AudioOptionsFrame",
				"LFDDungeonReadyStatus",
				"BNToastFrame",
				"TicketStatusFrameButton",
				"DropDownList1MenuBackdrop",
				"DropDownList2MenuBackdrop",
				"DropDownList1Backdrop",
				"DropDownList2Backdrop",
				"LFDSearchStatus",
				"AutoCompleteBox",
				"ConsolidatedBuffsTooltip",
				"ReadyCheckFrame",
				"StackSplitFrame",
				"CharacterFrame",
			}
			
			for i = 1, getn(skins) do
				_G[skins[i]]:SetTemplate("Transparent")
				if _G[skins[i]] ~= _G["GhostFrameContentsFrame"] or _G[skins[i]] ~= _G["AutoCompleteBox"] then -- frame to blacklist from create shadow function
					_G[skins[i]]:CreateShadow("Default")
				end
			end
		
			
			local ChatMenus = {
				"ChatMenu",
				"EmoteMenu",
				"LanguageMenu",
				"VoiceMacroMenu",		
			}
			--
			for i = 1, getn(ChatMenus) do
				if _G[ChatMenus[i]] == _G["ChatMenu"] then
					_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(C["media"].backdropfadecolor)) self:ClearAllPoints() self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, E.Scale(30)) end)
				else
					_G[ChatMenus[i]]:HookScript("OnShow", function(self) self:SetTemplate("Default", true) self:SetBackdropColor(unpack(C["media"].backdropfadecolor)) end)
				end
			end
			
			--LFD Role Picker frame
			LFDRoleCheckPopup:StripTextures()
			LFDRoleCheckPopup:SetTemplate("Transparent")
			SkinButton(LFDRoleCheckPopupAcceptButton)
			SkinButton(LFDRoleCheckPopupDeclineButton)
			SkinCheckBox(LFDRoleCheckPopupRoleButtonTank:GetChildren())
			SkinCheckBox(LFDRoleCheckPopupRoleButtonDPS:GetChildren())
			SkinCheckBox(LFDRoleCheckPopupRoleButtonHealer:GetChildren())
			LFDRoleCheckPopupRoleButtonTank:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonTank:GetChildren():GetFrameLevel() + 1)
			LFDRoleCheckPopupRoleButtonDPS:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonDPS:GetChildren():GetFrameLevel() + 1)
			LFDRoleCheckPopupRoleButtonHealer:GetChildren():SetFrameLevel(LFDRoleCheckPopupRoleButtonHealer:GetChildren():GetFrameLevel() + 1)
			
			-- reskin popup buttons
			for i = 1, 2 do
				for j = 1, 3 do
					SkinButton(_G["StaticPopup"..i.."Button"..j])
					SkinEditBox(_G["StaticPopup"..i.."EditBox"])
					SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameGold"])
					SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameSilver"])
					SkinEditBox(_G["StaticPopup"..i.."MoneyInputFrameCopper"])
					_G["StaticPopup"..i.."EditBox"].backdrop:Point("TOPLEFT", -2, -4)
					_G["StaticPopup"..i.."EditBox"].backdrop:Point("BOTTOMRIGHT", 2, 4)
					_G["StaticPopup"..i.."ItemFrameNameFrame"]:Kill()
					_G["StaticPopup"..i.."ItemFrame"]:GetNormalTexture():Kill()
					_G["StaticPopup"..i.."ItemFrame"]:SetTemplate("Default")
					_G["StaticPopup"..i.."ItemFrame"]:StyleButton()
					_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(.08, .92, .08, .92)
					_G["StaticPopup"..i.."ItemFrameIconTexture"]:ClearAllPoints()
					_G["StaticPopup"..i.."ItemFrameIconTexture"]:Point("TOPLEFT", 2, -2)
					_G["StaticPopup"..i.."ItemFrameIconTexture"]:Point("BOTTOMRIGHT", -2, 2)
				end
			end
			
			-- reskin all esc/menu buttons
			local BlizzardMenuButtons = {
				"Options", 
				"SoundOptions", 
				"UIOptions", 
				"Keybindings", 
				"Macros",
				"Ratings",
				"AddOns", 
				"Logout", 
				"Quit", 
				"Continue", 
				"MacOptions",
				"Help"
			}
			
			for i = 1, getn(BlizzardMenuButtons) do
				local ElvuiMenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
				if ElvuiMenuButtons then
					SkinButton(ElvuiMenuButtons)
				end
			end
			
			if IsAddOnLoaded("OptionHouse") then
				SkinButton(GameMenuButtonOptionHouse)
			end
			
			-- skin return to graveyard button
			do
				SkinButton(GhostFrame)
				GhostFrame:SetBackdropColor(0,0,0,0)
				GhostFrame:SetBackdropBorderColor(0,0,0,0)
				GhostFrame.SetBackdropColor = E.dummy
				GhostFrame.SetBackdropBorderColor = E.dummy
				GhostFrame:ClearAllPoints()
				GhostFrame:SetPoint("TOP", UIParent, "TOP", 0, -150)
				SkinButton(GhostFrameContentsFrame)
				GhostFrameContentsFrameIcon:SetTexture(nil)
				local x = CreateFrame("Frame", nil, GhostFrame)
				x:SetFrameStrata("MEDIUM")
				x:SetTemplate("Default")
				x:SetPoint("TOPLEFT", GhostFrameContentsFrameIcon, "TOPLEFT", E.Scale(-2), E.Scale(2))
				x:SetPoint("BOTTOMRIGHT", GhostFrameContentsFrameIcon, "BOTTOMRIGHT", E.Scale(2), E.Scale(-2))
				local tex = x:CreateTexture(nil, "OVERLAY")
				tex:SetTexture("Interface\\Icons\\spell_holy_guardianspirit")
				tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				tex:SetPoint("TOPLEFT", x, "TOPLEFT", E.Scale(2), E.Scale(-2))
				tex:SetPoint("BOTTOMRIGHT", x, "BOTTOMRIGHT", E.Scale(-2), E.Scale(2))
			end
			
			-- hide header textures and move text/buttons.
			local BlizzardHeader = {
				"GameMenuFrame", 
				"InterfaceOptionsFrame", 
				"AudioOptionsFrame", 
				"VideoOptionsFrame",
			}
			
			for i = 1, getn(BlizzardHeader) do
				local title = _G[BlizzardHeader[i].."Header"]			
				if title then
					title:SetTexture("")
					title:ClearAllPoints()
					if title == _G["GameMenuFrameHeader"] then
						title:SetPoint("TOP", GameMenuFrame, 0, 7)
					else
						title:SetPoint("TOP", BlizzardHeader[i], 0, 0)
					end
				end
			end
			
			-- here we reskin all "normal" buttons
			local BlizzardButtons = {
				"VideoOptionsFrameOkay", 
				"VideoOptionsFrameCancel", 
				"VideoOptionsFrameDefaults", 
				"VideoOptionsFrameApply", 
				"AudioOptionsFrameOkay", 
				"AudioOptionsFrameCancel", 
				"AudioOptionsFrameDefaults", 
				"InterfaceOptionsFrameDefaults", 
				"InterfaceOptionsFrameOkay", 
				"InterfaceOptionsFrameCancel",
				"ReadyCheckFrameYesButton",
				"ReadyCheckFrameNoButton",
				"StackSplitOkayButton",
				"StackSplitCancelButton",
				"RolePollPopupAcceptButton"
			}
			
			for i = 1, getn(BlizzardButtons) do
				local ElvuiButtons = _G[BlizzardButtons[i]]
				if ElvuiButtons then
					SkinButton(ElvuiButtons)
				end
			end
			
			-- if a button position is not really where we want, we move it here
			_G["VideoOptionsFrameCancel"]:ClearAllPoints()
			_G["VideoOptionsFrameCancel"]:SetPoint("RIGHT",_G["VideoOptionsFrameApply"],"LEFT",-4,0)		 
			_G["VideoOptionsFrameOkay"]:ClearAllPoints()
			_G["VideoOptionsFrameOkay"]:SetPoint("RIGHT",_G["VideoOptionsFrameCancel"],"LEFT",-4,0)	
			_G["AudioOptionsFrameOkay"]:ClearAllPoints()
			_G["AudioOptionsFrameOkay"]:SetPoint("RIGHT",_G["AudioOptionsFrameCancel"],"LEFT",-4,0)
			_G["InterfaceOptionsFrameOkay"]:ClearAllPoints()
			_G["InterfaceOptionsFrameOkay"]:SetPoint("RIGHT",_G["InterfaceOptionsFrameCancel"],"LEFT", -4,0)
			_G["ReadyCheckFrameYesButton"]:SetParent(_G["ReadyCheckFrame"])
			_G["ReadyCheckFrameNoButton"]:SetParent(_G["ReadyCheckFrame"]) 
			_G["ReadyCheckFrameYesButton"]:SetPoint("RIGHT", _G["ReadyCheckFrame"], "CENTER", -1, 0)
			_G["ReadyCheckFrameNoButton"]:SetPoint("LEFT", _G["ReadyCheckFrameYesButton"], "RIGHT", 3, 0)
			_G["ReadyCheckFrameText"]:SetParent(_G["ReadyCheckFrame"])	
			_G["ReadyCheckFrameText"]:ClearAllPoints()
			_G["ReadyCheckFrameText"]:SetPoint("TOP", 0, -12)
			
			-- others
			_G["ReadyCheckListenerFrame"]:SetAlpha(0)
			_G["ReadyCheckFrame"]:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end) -- bug fix, don't show it if initiator
			_G["StackSplitFrame"]:GetRegions():Hide()

			RolePollPopup:SetTemplate("Transparent")
			RolePollPopup:CreateShadow("Default")
			LFDDungeonReadyDialog:SetTemplate("Transparent")
			LFDDungeonReadyDialog:CreateShadow("Default")
			SkinButton(LFDDungeonReadyDialogEnterDungeonButton)
			SkinButton(LFDDungeonReadyDialogLeaveQueueButton)
	end
		
		-- mac menu/option panel, made by affli.
		if IsMacClient() then
			-- Skin main frame and reposition the header
			MacOptionsFrame:SetTemplate("Default", true)
			MacOptionsFrameHeader:SetTexture("")
			MacOptionsFrameHeader:ClearAllPoints()
			MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
	 
			--Skin internal frames
			MacOptionsFrameMovieRecording:SetTemplate("Default", true)
			MacOptionsITunesRemote:SetTemplate("Default", true)
	 
			--Skin buttons
			SkinButton(_G["MacOptionsFrameCancel"])
			SkinButton(_G["MacOptionsFrameOkay"])
			SkinButton(_G["MacOptionsButtonKeybindings"])
			SkinButton(_G["MacOptionsFrameDefaults"])
			SkinButton(_G["MacOptionsButtonCompress"])
	 
			--Reposition and resize buttons
			local tPoint, tRTo, tRP, tX, tY =  _G["MacOptionsButtonCompress"]:GetPoint()
			_G["MacOptionsButtonCompress"]:SetWidth(136)
			_G["MacOptionsButtonCompress"]:ClearAllPoints()
			_G["MacOptionsButtonCompress"]:SetPoint(tPoint, tRTo, tRP, E.Scale(4), tY)
	 
			_G["MacOptionsFrameCancel"]:SetWidth(96)
			_G["MacOptionsFrameCancel"]:SetHeight(22)
			tPoint, tRTo, tRP, tX, tY =  _G["MacOptionsFrameCancel"]:GetPoint()
			_G["MacOptionsFrameCancel"]:ClearAllPoints()
			_G["MacOptionsFrameCancel"]:SetPoint(tPoint, tRTo, tRP, E.Scale(-14), tY)
	 
			_G["MacOptionsFrameOkay"]:ClearAllPoints()
			_G["MacOptionsFrameOkay"]:SetWidth(96)
			_G["MacOptionsFrameOkay"]:SetHeight(22)
			_G["MacOptionsFrameOkay"]:SetPoint("LEFT",_G["MacOptionsFrameCancel"],E.Scale(-99),0)
	 
			_G["MacOptionsButtonKeybindings"]:ClearAllPoints()
			_G["MacOptionsButtonKeybindings"]:SetWidth(96)
			_G["MacOptionsButtonKeybindings"]:SetHeight(22)
			_G["MacOptionsButtonKeybindings"]:SetPoint("LEFT",_G["MacOptionsFrameOkay"],E.Scale(-99),0)
	 
			_G["MacOptionsFrameDefaults"]:SetWidth(96)
			_G["MacOptionsFrameDefaults"]:SetHeight(22)

			-- why these buttons is using game menu template? oO
			_G["MacOptionsButtonCompressLeft"]:SetAlpha(0)
			_G["MacOptionsButtonCompressMiddle"]:SetAlpha(0)
			_G["MacOptionsButtonCompressRight"]:SetAlpha(0)
			_G["MacOptionsButtonKeybindingsLeft"]:SetAlpha(0)
			_G["MacOptionsButtonKeybindingsMiddle"]:SetAlpha(0)
			_G["MacOptionsButtonKeybindingsRight"]:SetAlpha(0)
		end
	end
end)