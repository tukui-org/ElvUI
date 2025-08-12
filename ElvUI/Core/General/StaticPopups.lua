local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local UF = E:GetModule('UnitFrames')
local NP = E:GetModule('NamePlates')
local M = E:GetModule('Misc')
local S = E:GetModule('Skins')

local _G = _G
local next, wipe, gsub, strlower = next, wipe, gsub, strlower
local pairs, type, unpack, assert, ceil, error = pairs, type, unpack, assert, ceil, error
local tremove, tContains, tinsert = tremove, tContains, tinsert

local CreateFrame = CreateFrame
local MoneyFrame_Update = MoneyFrame_Update
local UnitIsDeadOrGhost, InCinematic = UnitIsDeadOrGhost, InCinematic
local PurchaseSlot, GetBankSlotCost = PurchaseSlot, GetBankSlotCost
local ReloadUI, PlaySound, StopMusic = ReloadUI, PlaySound, StopMusic
local GetBindingFromClick = GetBindingFromClick

local AutoCompleteEditBox_OnEnterPressed = AutoCompleteEditBox_OnEnterPressed
local AutoCompleteEditBox_OnTextChanged = AutoCompleteEditBox_OnTextChanged
local ChatEdit_FocusActiveWindow = ChatEdit_FocusActiveWindow

local DisableAddOn = C_AddOns.DisableAddOn
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local STATICPOPUP_TEXTURE_ALERT = STATICPOPUP_TEXTURE_ALERT
local STATICPOPUP_TEXTURE_ALERTGEAR = STATICPOPUP_TEXTURE_ALERTGEAR
local YES, NO, OKAY, CANCEL, ACCEPT, DECLINE = YES, NO, OKAY, CANCEL, ACCEPT, DECLINE

-- GLOBALS: ElvUIBindPopupWindowCheckButton

local DOWNLOAD_URL = 'https://tukui.org/elvui'
local FALLBACK_COLOR = { 1, 1, 1, 1 }

E.PopupDialogs = {}
E.StaticPopup_DisplayedFrames = {}
E.MAX_STATIC_POPUPS = 4

E.PopupDialogs.ELVUI_UPDATE_AVAILABLE = {
	text = L["ElvUI is five or more revisions out of date. You can download the newest version from tukui.org."],
	hasEditBox = 1,
	OnShow = function(self)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:Width(220)
		self.editBox:SetText(DOWNLOAD_URL)
		ChatEdit_FocusActiveWindow()
	end,
	OnHide = function(self)
		self.editBox:Width(self.editBox.width or 50)
		self.editBox.width = nil
	end,
	hideOnEscape = 1,
	button1 = OKAY,
	EditBoxOnEnterPressed = function(self)
		ChatEdit_FocusActiveWindow()
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		ChatEdit_FocusActiveWindow()
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() ~= DOWNLOAD_URL then
			self:SetText(DOWNLOAD_URL)
		end

		self:HighlightText()

		ChatEdit_FocusActiveWindow()
	end,
	OnEditFocusGained = function(self)
		self:HighlightText()
	end,
	showAlert = 1,
}

E.PopupDialogs.ELVUI_EDITBOX = {
	text = E.title,
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:Width(280)
		self.editBox:AddHistoryLine('text')
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:SetJustifyH('CENTER')
	end,
	OnHide = function(self)
		self.editBox:Width(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() ~= self.temptxt then
			self:SetText(self.temptxt)
		end

		self:HighlightText()
	end,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

E.PopupDialogs.UPDATE_REQUEST = {
	text = L["UPDATE_REQUEST"],
	button1 = OKAY,
	showAlert = 1,
}

E.PopupDialogs.CONFIRM_LOSE_BINDING_CHANGES = {
	text = CONFIRM_LOSE_BINDING_CHANGES,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		AB:ChangeBindingProfile()
		AB.bindingsChanged = nil
	end,
	OnCancel = function()
		local isChecked = ElvUIBindPopupWindowCheckButton:GetChecked()
		ElvUIBindPopupWindowCheckButton:SetChecked(not isChecked)
	end,
	whileDead = 1,
	showAlert = 1,
}

E.PopupDialogs.TUKUI_ELVUI_INCOMPATIBLE = {
	text = L["Oh lord, you have got ElvUI and Tukui both enabled at the same time. Select an addon to disable."],
	OnAccept = function() DisableAddOn('ElvUI'); ReloadUI() end,
	OnCancel = function() DisableAddOn('Tukui'); ReloadUI() end,
	button1 = 'ElvUI',
	button2 = 'Tukui',
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.DISABLE_INCOMPATIBLE_ADDON = {
	text = L["Do you swear not to post in technical support about something not working without first disabling the addon/module combination first?"],
	OnAccept = function()
		E.global.ignoreIncompatible = true
	end,
	OnCancel = function()
		E:StaticPopup_Hide('DISABLE_INCOMPATIBLE_ADDON')

		local popup = E.PopupDialogs.INCOMPATIBLE_ADDON
		if popup then
			E:StaticPopup_Show('INCOMPATIBLE_ADDON', popup.button1, popup.button2)
		end
	end,
	button1 = L["I Swear"],
	button2 = DECLINE,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.INCOMPATIBLE_ADDON = {
	text = L["INCOMPATIBLE_ADDON"],
	OnAccept = function() local popup = E.PopupDialogs.INCOMPATIBLE_ADDON; popup.accept(popup) end,
	OnCancel = function() local popup = E.PopupDialogs.INCOMPATIBLE_ADDON; popup.cancel(popup) end,
	button3 = L["Disable Warning"],
	OnAlt = function()
		E:StaticPopup_Hide('INCOMPATIBLE_ADDON')
		E:StaticPopup_Show('DISABLE_INCOMPATIBLE_ADDON')
	end,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.CONFIG_RL = {
	text = L["One or more of the changes you have made require a ReloadUI."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = ReloadUI,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.GLOBAL_RL = {
	text = L["One or more of the changes you have made will effect all characters using this addon. You will have to reload the user interface to see the changes you have made."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = ReloadUI,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.PRIVATE_RL = {
	text = L["A setting you have changed will change an option for this character only. This setting that you have changed will be uneffected by changing user profiles. Changing this setting requires that you reload your User Interface."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = ReloadUI,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.RESET_ALL_FILTERS = {
	text = L["Accepting this will reset all filters to default. Are you sure?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		UF:ResetFilters()

		if E:Config_GetWindow() then
			E:RefreshGUI()
		end

		UF:Update_AllFrames()
		NP:ConfigureAll()
	end,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.RESET_UF_UNIT = {
	text = L["Accepting this will reset the UnitFrame settings for %s. Are you sure?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(_, data)
		if data and data.unit then
			UF:ResetUnitSettings(data.unit)
			if data.mover then
				E:ResetMovers(data.mover)
			end

			if data.unit == 'raidpet' then
				UF:CreateAndUpdateHeaderGroup(data.unit, nil, nil, true)
			end

			if IsAddOnLoaded('ElvUI_Options') then
				local ACD = E.Libs.AceConfigDialog
				if ACD and ACD.OpenFrames and ACD.OpenFrames.ElvUI then
					ACD:SelectGroup('ElvUI', 'unitframe', data.unit)
				end
			end
		else
			E:Print(L["Error resetting UnitFrame."])
		end
	end,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.RESET_UF_AF = {
	text = L["Accepting this will reset your Filter Priority lists for all auras on UnitFrames. Are you sure?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		UF:ResetAuraPriority()
	end,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.RESET_NP_AF = {
	text = L["Accepting this will reset your Filter Priority lists for all auras on NamePlates. Are you sure?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		NP:ResetAuraPriority()
	end,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.BUY_BANK_SLOT = {
	text = CONFIRM_BUY_BANK_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = PurchaseSlot,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetBankSlotCost())
	end,
	hasMoneyFrame = 1,
	hideOnEscape = 1,
}

E.PopupDialogs.CANNOT_BUY_BANK_SLOT = {
	text = L["Can't buy anymore slots!"],
	button1 = ACCEPT,
	whileDead = 1,
}

E.PopupDialogs.NO_BANK_BAGS = {
	text = L["You must purchase a bank slot first!"],
	button1 = ACCEPT,
	whileDead = 1,
}

E.PopupDialogs.RESETUI_CHECK = {
	text = L["Are you sure you want to reset every mover back to it's default position?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		E:ResetAllUI()
	end,
	whileDead = 1,
}

E.PopupDialogs.DISBAND_RAID = {
	text = L["Are you sure you want to disband the group?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() M:DisbandRaidGroup() end,
	whileDead = 1,
}

E.PopupDialogs.CONFIRM_LOOT_DISTRIBUTION = {
	text = CONFIRM_LOOT_DISTRIBUTION,
	button1 = YES,
	button2 = NO,
	hideOnEscape = 1,
}

E.PopupDialogs.RESET_PROFILE_PROMPT = {
	text = L["Are you sure you want to reset all the settings on this profile?"],
	button1 = YES,
	button2 = NO,
	hideOnEscape = 1,
	OnAccept = function() E:ResetProfile() end,
}

E.PopupDialogs.RESET_PRIVATE_PROFILE_PROMPT = {
	text = L["Are you sure you want to reset all the settings on this profile?"],
	button1 = YES,
	button2 = NO,
	hideOnEscape = 1,
	OnAccept = function() E:ResetPrivateProfile() end,
}

E.PopupDialogs.APPLY_FONT_WARNING = {
	text = L["Are you sure you want to apply this font to all ElvUI elements?"],
	OnAccept = function() E:GeneralMedia_ApplyToAll() end,
	OnCancel = function() E:StaticPopup_Hide('APPLY_FONT_WARNING') end,
	button1 = YES,
	button2 = CANCEL,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.MODULE_COPY_CONFIRM = {
	button1 = ACCEPT,
	button2 = CANCEL,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs.SCRIPT_PROFILE = {
	text = L["You are using CPU Profiling. This causes decreased performance. Do you want to disable it or continue?"],
	button1 = L["Disable"],
	button2 = L["Continue"],
	OnAccept = function()
		E:SetCVar('scriptProfile', 0)
		ReloadUI()
	end,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = false,
}

function E:StaticPopup_OnShow()
	PlaySound(850) --IG_MAINMENU_OPEN

	local dialog = E.PopupDialogs[self.which]
	if dialog then
		local OnShow = dialog.OnShow
		if OnShow then
			OnShow(self, self.data)
		end

		local dialogName = self:GetName()
		if dialog.hasMoneyInputFrame then
			_G[dialogName..'MoneyInputFrameGold']:SetFocus()
		end

		if dialog.enterClicksFirstButton or dialog.hideOnEscape then
			self:SetScript('OnKeyDown', E.StaticPopup_OnKeyDown)
		end
	end

	-- boost static popups over ace gui
	if IsAddOnLoaded('ElvUI_Options') then
		local ACD = E.Libs.AceConfigDialog
		if ACD and ACD.OpenFrames and ACD.OpenFrames.ElvUI then
			self.frameStrataIncreased = true
			self:SetFrameStrata('FULLSCREEN_DIALOG')

			local popupFrameLevel = self:GetFrameLevel()
			if popupFrameLevel < 100 then
				self:SetFrameLevel(popupFrameLevel+100)
			end
		end
	end
end

function E:StaticPopup_EscapePressed()
	local closed = nil
	for _, frame in pairs(E.StaticPopup_DisplayedFrames) do
		if frame:IsShown() and frame.hideOnEscape then
			local dialog = E.PopupDialogs[frame.which]
			if dialog then
				frame:Hide()

				local OnCancel = dialog.OnCancel
				if OnCancel and not dialog.noCancelOnEscape then
					OnCancel(frame, frame.data, 'clicked')
				end
			else
				E:StaticPopupSpecial_Hide(frame)
			end

			closed = 1
		end
	end

	return closed
end

function E:StaticPopup_CollapseTable()
	local displayedFrames = E.StaticPopup_DisplayedFrames
	local index = #displayedFrames
	while index >= 1 and not displayedFrames[index]:IsShown() do
		tremove(displayedFrames, index)
		index = index - 1
	end
end

function E:StaticPopup_SetUpPosition(dialog)
	if not tContains(E.StaticPopup_DisplayedFrames, dialog) then
		dialog:ClearAllPoints()

		local lastFrame = E.StaticPopup_DisplayedFrames[#E.StaticPopup_DisplayedFrames]
		if lastFrame then
			dialog:Point('TOP', lastFrame, 'BOTTOM', 0, -4)
		else
			dialog:Point('TOP', E.UIParent, 'TOP', 0, -100)
		end

		tinsert(E.StaticPopup_DisplayedFrames, dialog)
	end
end

function E:StaticPopupSpecial_Show(frame)
	if frame.exclusive then
		E:StaticPopup_HideExclusive()
	end

	E:StaticPopup_SetUpPosition(frame)
	frame:Show()
end

function E:StaticPopupSpecial_Hide(frame)
	frame:Hide()
	E:StaticPopup_CollapseTable()
end

function E:StaticPopupSpecial_Toggle(frame)
	if frame:IsShown() then
		E:StaticPopupSpecial_Hide(frame)
	else
		E:StaticPopupSpecial_Show(frame)
	end
end

--Used to figure out if we can resize a frame
function E:StaticPopup_IsLastDisplayedFrame(frame)
	for i = #E.StaticPopup_DisplayedFrames, 1, -1 do
		local popup = E.StaticPopup_DisplayedFrames[i]
		if popup:IsShown() then
			return frame == popup
		end
	end

	return false
end

function E:StaticPopup_ClearText()
	self:SetText('')
	self:ClearFocus()
end

function E:StaticPopup_OnKeyDown(key)
	if GetBindingFromClick(key) == 'TOGGLEGAMEMENU' then
		return E:StaticPopup_EscapePressed()
	end

	local dialog = key == 'ENTER' and E.PopupDialogs[self.which]
	if dialog and dialog.enterClicksFirstButton then
		for i, button in next, self.buttons do
			if button:IsShown() then
				E.StaticPopup_OnClick(self, i)

				break -- we clicked one so stop
			end
		end
	end
end

function E:StaticPopup_OnHide()
	PlaySound(851) --IG_MAINMENU_CLOSE

	E:StaticPopup_CollapseTable()

	local dialog = E.PopupDialogs[self.which]
	if dialog then
		local OnHide = dialog.OnHide
		if OnHide then
			OnHide(self, self.data)
		end

		if dialog.enterClicksFirstButton then
			self:SetScript('OnKeyDown', nil)
		end
	end

	if self.extraFrame then
		self.extraFrame:Hide()
	end

	if self.editBox then
		self.editBox:ClearText()
	end

	if self.insertedFrame then
		self.insertedFrame:Hide()
		self.insertedFrame:SetParent(nil)

		if self.moneyFrame then
			self.moneyFrame:Point('TOP', self.text or self, 'BOTTOM', 0, -5)
		end

		if self.moneyInputFrame then
			self.moneyInputFrame:Point('TOP', self.text or self, 'BOTTOM', 0, -5)
		end
	end

	-- static popup was boosted over ace gui, set it back to normal
	if self.frameStrataIncreased then
		self.frameStrataIncreased = nil
		self:SetFrameStrata('DIALOG')

		local popupFrameLevel = self:GetFrameLevel()
		if popupFrameLevel > 100 then
			self:SetFrameLevel(popupFrameLevel-100)
		end
	end
end

function E:StaticPopup_OnUpdate(elapsed)
	local info = E.PopupDialogs[self.which]
	if not info then return end

	if self.timeleft and self.timeleft > 0 then
		self.timeleft = self.timeleft - elapsed

		if self.timeleft <= 0 then
			if not info.timeoutInformationalOnly then
				self.timeleft = nil

				if info.OnCancel then
					info.OnCancel(self, self.data, 'timeout')
				end

				self:Hide()
			end

			return
		end
	end

	if self.startDelay then
		self.startDelay = self.startDelay - elapsed

		if self.startDelay <= 0 then
			self.startDelay = nil

			self.button1:Enable()

			if self.text then
				self.text:SetFormattedText(info.text, self.text.text_arg1, self.text.text_arg2)
			end

			E:StaticPopup_Resize(self, self.which)

			return
		end
	end

	if self.acceptDelay then
		self.acceptDelay = self.acceptDelay - elapsed

		local enabled = self.acceptDelay <= 0
		self.button1:SetEnabled(enabled)

		if enabled then
			self.button1:SetText(info.button1)

			self.acceptDelay = nil

			if info.OnAcceptDelayExpired ~= nil then
				info.OnAcceptDelayExpired(self, self.data)
			end
		else
			self.button1:SetText(ceil(self.acceptDelay))
		end
	end

	if info and info.OnUpdate then
		info.OnUpdate(self, elapsed)
	end
end

function E:StaticPopup_OnClick(index)
	if not self:IsShown() then return end

	local which = self.which
	local info = E.PopupDialogs[which]
	if not info then return end

	if info.selectCallbackByIndex then
		local func
		if index == 1 then
			func = info.OnAccept or info.OnButton1
		elseif index == 2 then
			func = info.OnCancel or info.OnButton2
		elseif index == 3 then
			func = info.OnButton3
		elseif index == 4 then
			func = info.OnButton4
		elseif index == 5 then
			func = info.OnExtraButton
		end

		if func then
			local keepOpen = func(self, self.data, 'clicked')
			if not keepOpen and which == self.which then
				self:Hide()
			end
		end
	else
		local hide = true
		if index == 1 then
			local OnAccept = info.OnAccept or info.OnButton1
			if OnAccept then
				hide = not OnAccept(self, self.data, self.data2)
			end
		elseif index == 3 then
			local OnAlt = info.OnAlt or info.OnButton2
			if OnAlt then
				OnAlt(self, self.data, 'clicked')
			end
		else
			local OnCancel = info.OnCancel
			if OnCancel then
				hide = not OnCancel(self, self.data, 'clicked')
			end
		end

		-- can self.which change inside one of the On* functions???
		if hide and (which == self.which) then
			self:Hide()
		end
	end
end

function E:StaticPopup_EditBoxOnEnterPressed()
	if not self.autoCompleteParams or not AutoCompleteEditBox_OnEnterPressed(self) then
		local parent = self:GetParent()
		local owner = parent and parent:GetParent()
		local which, dialog

		if parent and parent.which then
			which = parent.which
			dialog = parent
		elseif owner and owner.which then -- This is needed if this is a money input frame since it's nested deeper than a normal edit box
			which = owner.which
			dialog = owner
		end

		local popup = E.PopupDialogs[which]
		local OnEnterPressed = popup and popup.EditBoxOnEnterPressed
		if OnEnterPressed then
			OnEnterPressed(self, dialog.data)
		end
	end
end

function E:StaticPopup_EditBoxOnEscapePressed()
	local parent = self:GetParent()
	local popup = parent and E.PopupDialogs[parent.which]
	local OnEscapePressed = popup and popup.EditBoxOnEscapePressed
	if OnEscapePressed then
		OnEscapePressed(self, parent.data)
	end
end

function E:StaticPopup_EditBoxOnTextChanged(userInput)
	if not self.autoCompleteParams or not AutoCompleteEditBox_OnTextChanged(self, userInput) then
		local parent = self:GetParent()
		local popup = parent and E.PopupDialogs[parent.which]
		local OnTextChanged = popup and popup.EditBoxOnTextChanged
		if OnTextChanged then
			OnTextChanged(self, parent.data)
		end
	end
end

function E:StaticPopup_FindVisible(which, data)
	local info = E.PopupDialogs[which]
	if not info then return end

	for _, popup in next, E.StaticPopupFrames do
		if popup:IsShown() and (popup.which == which) and (not info.multiple or (popup.data == data)) then
			return popup
		end
	end
end

function E:StaticPopup_Resize(dialog, which)
	local info = E.PopupDialogs[which]
	if not info then return end

	local maxHeightSoFar = dialog.maxHeightSoFar or 0
	local maxWidthSoFar = dialog.maxWidthSoFar or 0
	local width = 320

	if dialog.numButtons == 4 then
		width = 574
	elseif dialog.numButtons == 3 then
		width = 440
	elseif info.showAlert or info.showAlertGear or info.closeButton then
		width = 420 -- Widen
	elseif info.editBoxWidth and info.editBoxWidth > 260 then
		width = width + (info.editBoxWidth - 260)
	end

	if width > maxWidthSoFar then
		dialog:Width(width)
		dialog.maxWidthSoFar = width
	end

	dialog.text:Width(info.wideText and 360 or 290)

	local height = 32 + (dialog.text and dialog.text:GetHeight() or 0) + 8 + dialog.button1:GetHeight()
	if info.hasEditBox then
		height = height + 8 + dialog.editBox:GetHeight()
	elseif info.hasMoneyFrame then
		height = height + 16
	elseif info.hasMoneyInputFrame then
		height = height + 22
	end

	if info.hasItemFrame then
		height = height + (info.compactItemFrame and 44 or 64)
	end

	if info.hasCheckButton then
		height = height + 32
	end

	if height > maxHeightSoFar then
		dialog:Height(height)
		dialog.maxHeightSoFar = height
	end
end

function E:StaticPopup_OnEvent()
	self.maxHeightSoFar = 0

	E:StaticPopup_Resize(self, self.which)
end

function E:StaticPopup_HideExclusive()
	for _, frame in pairs(E.StaticPopup_DisplayedFrames) do
		if frame:IsShown() and frame.exclusive then
			local dialog = E.PopupDialogs[frame.which]
			if dialog then
				frame:Hide()

				local OnCancel = dialog.OnCancel
				if OnCancel then
					OnCancel(frame, frame.data, 'override')
				end
			else
				E:StaticPopupSpecial_Hide(frame)
			end

			break
		end
	end
end

local tempButtonLocs = {}	--So we don't make a new table each time.
function E:StaticPopup_Show(which, text_arg1, text_arg2, data, insertedFrame)
	local info = E.PopupDialogs[which]
	if not info then return end

	if UnitIsDeadOrGhost('player') and not info.whileDead then
		if info.OnCancel then
			info.OnCancel()
		end

		return
	end

	if InCinematic() and not info.interruptCinematic then
		if info.OnCancel then
			info.OnCancel()
		end

		return
	end

	if info.exclusive then
		E:StaticPopup_HideExclusive()
	end

	if info.cancels then
		for _, popup in next, E.StaticPopupFrames do
			if popup:IsShown() and (popup.which == info.cancels) then
				popup:Hide()

				local dialog = E.PopupDialogs[popup.which]
				local OnCancel = dialog and dialog.OnCancel
				if OnCancel then
					OnCancel(popup, popup.data, 'override')
				end
			end
		end
	end

	-- Pick a free dialog to use, find an open dialog of the requested type
	local dialog = E:StaticPopup_FindVisible(which, data)
	if dialog then
		local OnCancel = not info.noCancelOnReuse and info.OnCancel
		if OnCancel then
			OnCancel(dialog, dialog.data, 'override')
		end

		dialog:Hide()
	else
		-- Find a free dialog
		for i = (info.preferredIndex or 1), E.MAX_STATIC_POPUPS do
			local popup = _G['ElvUI_StaticPopup'..i]
			if popup and not popup:IsShown() then
				dialog = popup
				break
			end
		end

		--If dialog not found and there's a preferredIndex then try to find an available frame before the preferredIndex
		if not dialog and info.preferredIndex then
			for i = 1, info.preferredIndex do
				local popup = _G['ElvUI_StaticPopup'..i]
				if popup and not popup:IsShown() then
					dialog = popup
					break
				end
			end
		end
	end

	if not dialog then
		if info.OnCancel then
			info.OnCancel()
		end

		return
	end

	-- Set the miscellaneous variables for the dialog
	dialog.which = which
	dialog.data = data
	dialog.maxWidthSoFar = 0
	dialog.maxHeightSoFar = 0
	dialog.insertedFrame = insertedFrame
	dialog.timeleft = info.timeout
	dialog.exclusive = info.exclusive
	dialog.hideOnEscape = info.hideOnEscape
	dialog.enterClicksFirstButton = info.enterClicksFirstButton

	-- Set the text of the dialog
	if dialog.text then
		dialog.text:SetFormattedText(info.text, text_arg1, text_arg2)
	end

	-- Show or hide the close button
	local closeButton = dialog.closeButton
	if closeButton then
		if info.closeButton then
			if info.closeButtonIsHide then
				closeButton:SetNormalTexture([[Interface\Buttons\UI-Panel-HideButton-Up]])
				closeButton:SetPushedTexture([[Interface\Buttons\UI-Panel-HideButton-Down]])
			else
				closeButton:SetNormalTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Up]])
				closeButton:SetPushedTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Down]])
			end

			closeButton:Show()
		else
			closeButton:Hide()
		end
	end

	-- Show or hide money frame
	local moneyFrame = dialog.moneyFrame
	local moneyInputFrame = dialog.moneyInputFrame
	if moneyFrame and moneyInputFrame then
		if info.hasMoneyFrame then
			moneyFrame:Show()
			moneyInputFrame:Hide()
		elseif info.hasMoneyInputFrame then
			moneyInputFrame:Show()
			moneyFrame:Hide()

			-- Set OnEnterPress for money input frames
			if info.EditBoxOnEnterPressed then
				moneyInputFrame.gold:SetScript('OnEnterPressed', E.StaticPopup_EditBoxOnEnterPressed)
				moneyInputFrame.silver:SetScript('OnEnterPressed', E.StaticPopup_EditBoxOnEnterPressed)
				moneyInputFrame.copper:SetScript('OnEnterPressed', E.StaticPopup_EditBoxOnEnterPressed)
			else
				moneyInputFrame.gold:SetScript('OnEnterPressed', nil)
				moneyInputFrame.silver:SetScript('OnEnterPressed', nil)
				moneyInputFrame.copper:SetScript('OnEnterPressed', nil)
			end
		else
			moneyFrame:Hide()
			moneyInputFrame:Hide()
		end
	end

	if insertedFrame then
		insertedFrame:SetParent(dialog)
		insertedFrame:ClearAllPoints()
		insertedFrame:Point('TOP', dialog.text or dialog, 'BOTTOM')
		insertedFrame:Show()

		if moneyFrame then
			moneyFrame:Point('TOP', insertedFrame, 'BOTTOM')
		end

		if moneyInputFrame then
			moneyInputFrame:Point('TOP', insertedFrame, 'BOTTOM')
		end
	end

	-- Show or hide item button
	local itemFrame = dialog.itemFrame
	if itemFrame then
		if info.hasItemFrame then
			itemFrame:Show()

			if data and type(data) == 'table' then
				itemFrame.link = data.link

				if dialog.itemFrameIconTexture then
					dialog.itemFrameIconTexture:SetTexture(data.texture)
				end

				if dialog.itemFrameText then
					dialog.itemFrameText:SetTextColor(unpack(data.color or FALLBACK_COLOR))
					dialog.itemFrameText:SetText(data.name)
				end

				if dialog.itemFrameCount then
					if data.count and data.count > 1 then
						dialog.itemFrameCount:SetText(data.count)
						dialog.itemFrameCount:Show()
					else
						dialog.itemFrameCount:Hide()
					end
				end
			end
		else
			itemFrame:Hide()
		end
	end

	-- Set the editbox of the dialog
	local editBox = dialog.editBox
	if editBox then
		editBox.autoCompleteParams = info.autoCompleteParams
		editBox.autoCompleteRegex = info.autoCompleteRegex
		editBox.autoCompleteFormatRegex = info.autoCompleteFormatRegex
		editBox.addHighlightedText = true

		if info.hasEditBox then
			editBox:Show()

			if info.maxLetters then
				editBox:SetMaxLetters(info.maxLetters)
				editBox:SetCountInvisibleLetters(info.countInvisibleLetters)
			end

			if info.maxBytes then
				editBox:SetMaxBytes(info.maxBytes)
			end

			editBox:Width(info.editBoxWidth or 130)
		else
			editBox:Hide()
		end
	end

	-- Show or hide the alert icon
	local alertIcon = dialog.alertIcon
	if alertIcon then
		if info.showAlert then
			alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERT)
			alertIcon:Point('LEFT', 24, dialog.button3:IsShown() and 10 or 0)
			alertIcon:Show()
		elseif info.showAlertGear then
			alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERTGEAR)
			alertIcon:Point('LEFT', 24, 0)
			alertIcon:Show()
		else
			alertIcon:SetTexture()
			alertIcon:Hide()
		end
	end

	-- Show or hide the checkbox
	local checkButton = dialog.checkButton
	if checkButton then
		if checkButton then
			if info.hasCheckButton then
				checkButton:ClearAllPoints()
				checkButton:Point('BOTTOMLEFT', 24, 20 + dialog.button1:GetHeight())

				if dialog.checkButtonText then
					if info.checkButtonText then
						dialog.checkButtonText:SetText(info.checkButtonText)
						dialog.checkButtonText:Show()
					else
						dialog.checkButtonText:Hide()
					end
				end

				checkButton:Show()
			else
				checkButton:Hide()
			end
		end
	end

	do -- If there is any recursion in this block, we may get errors (tempButtonLocs is static). If you have to recurse, we'll have to create a new table each time.
		assert(#tempButtonLocs == 0) -- If this fails, we're recursing. (See the table.wipe at the end of the block)

		tinsert(tempButtonLocs, dialog.button1)
		tinsert(tempButtonLocs, dialog.button2)
		tinsert(tempButtonLocs, dialog.button3)
		tinsert(tempButtonLocs, dialog.button4)

		for i = #tempButtonLocs, 1, -1 do
			local tempButtonLoc = tempButtonLocs[i]

			-- Do this stuff before we move it. (This is why we go back-to-front)
			local button = info['button'..i]
			tempButtonLoc:SetText(button)
			tempButtonLoc:ClearAllPoints()
			tempButtonLoc:Hide()

			-- Now we possibly remove it.
			local displayButton = info['DisplayButton'..i]
			if not (button and (not displayButton or displayButton(dialog))) then
				tremove(tempButtonLocs, i)
			end
		end

		-- Save off the number of buttons.
		local numButtons = #tempButtonLocs
		dialog.numButtons = numButtons

		if numButtons == 4 then
			tempButtonLocs[1]:Point('BOTTOMRIGHT', dialog, 'BOTTOM', -139, 16);
		elseif numButtons == 3 then
			tempButtonLocs[1]:Point('BOTTOMRIGHT', dialog, 'BOTTOM', -72, 16)
		elseif numButtons == 2 then
			tempButtonLocs[1]:Point('BOTTOMRIGHT', dialog, 'BOTTOM', -6, 16)
		elseif numButtons == 1 then
			tempButtonLocs[1]:Point('BOTTOM', dialog, 'BOTTOM', 0, 16)
		end

		for i = 1, numButtons do
			local tempButtonLoc = tempButtonLocs[i]

			if i > 1 then
				tempButtonLoc:Point('LEFT', tempButtonLocs[i-1], 'RIGHT', 13, 0)
			end

			local width = tempButtonLoc:GetTextWidth()
			tempButtonLoc:Width((width and width > 110 and (width + 20)) or 120)
			tempButtonLoc:Enable()
			tempButtonLoc:Show()
		end

		wipe(tempButtonLocs)
	end

	-- Handle the first button delay
	if info.StartDelay then
		dialog.startDelay = info.StartDelay(dialog)
		dialog.button1:SetEnabled(not dialog.startDelay or dialog.startDelay <= 0)
	elseif info.acceptDelay then
		dialog.acceptDelay = info.acceptDelay
		dialog.button1:Disable()
	else
		dialog.startDelay = nil
		dialog.acceptDelay = nil
		dialog.button1:Enable()
	end

	-- Finally size and show the dialog
	E:StaticPopup_Resize(dialog, which)
	E:StaticPopup_SetUpPosition(dialog)
	dialog:Show()

	if info.sound then
		PlaySound(info.sound)
	end

	return dialog
end

function E:StaticPopup_Hide(which, data)
	for _, popup in next, E.StaticPopupFrames do
		if popup.which == which and (not data or (data == popup.data)) then
			popup:Hide()
		end
	end
end

function E:StaticPopup_ButtonOnClick()
	local id = self:GetID()
	local parent = self:GetParent()

	if E.Retail then -- has ButtonContainer
		E.StaticPopup_OnClick(parent:GetParent(), id)
	else
		E.StaticPopup_OnClick(parent, id)
	end
end

function E:StaticPopup_CheckButtonOnClick()
	local parent = self:GetParent()
	local which = parent and parent.which
	local info = E.PopupDialogs[which]
	if not info then return end

	self:SetChecked(self:GetChecked())

	if info.checkButtonOnClick then
		info.checkButtonOnClick(self)
	end
end

-- Static popup secure buttons
local SecureButtons = {}
local SecureOnEnter = function(frame) frame.text:SetTextColor(1, 1, 1) end
local SecureOnLeave = function(frame) frame.text:SetTextColor(1, 0.2, 0.2) end
function E:StaticPopup_CreateSecureButton(popup, button, text, attributes)
	local btn = CreateFrame('Button', nil, popup, 'SecureActionButtonTemplate')
	btn:RegisterForClicks('AnyUp', 'AnyDown')
	btn:SetAllPoints(button)
	btn:SetSize(button:GetSize())
	btn:HookScript('OnEnter', SecureOnEnter)
	btn:HookScript('OnLeave', SecureOnLeave)
	S:HandleButton(btn)

	for key, value in next, attributes do
		btn:SetAttribute(key, value)
	end

	local txt = btn:CreateFontString(nil, 'OVERLAY')
	txt:Point('CENTER', 0, 1)
	txt:FontTemplate(nil, nil, 'SHADOW')
	txt:SetJustifyH('CENTER')
	txt:SetText(text)

	btn.text = txt
	btn:SetFontString(txt)
	btn:SetTemplate(nil, true)

	SecureOnLeave(btn)

	return btn
end

function E:StaticPopup_GetAllSecureButtons()
	return SecureButtons
end

function E:StaticPopup_GetSecureButton(which)
	return SecureButtons[which]
end

function E:StaticPopup_PositionSecureButton(popup, popupButton, secureButton)
	secureButton:SetParent(popup)
	secureButton:SetAllPoints(popupButton)
	secureButton:SetSize(popupButton:GetSize())
end

function E:StaticPopup_SetSecureButton(which, btn)
	if SecureButtons[which] then
		error('A secure StaticPopup Button called `'..which..'` already exists.')
	end

	SecureButtons[which] = btn
end

function E:StaticPopup_HandleButton(button)
	if not button then return end

	button:OffsetFrameLevel(1)
	button:SetScript('OnClick', E.StaticPopup_ButtonOnClick)

	S:HandleButton(button)
end

function E:StaticPopup_GetElement(popup, text)
	local lower = gsub(text, '^%w', strlower)
	local element = popup[lower] or popup[text]
	if element then
		return element
	end

	local name = popup:GetName()
	if name then
		return _G[name..text]
	end
end

function E:StaticPopup_OnLoad(popup)
	-- reference elements with compatibility
	popup.text = E:StaticPopup_GetElement(popup, 'Text')
	popup.editBox = E:StaticPopup_GetElement(popup, 'EditBox')
	popup.alertIcon = E:StaticPopup_GetElement(popup, 'AlertIcon')
	popup.extraButton = E:StaticPopup_GetElement(popup, 'ExtraButton')
	popup.extraFrame = E:StaticPopup_GetElement(popup, 'ExtraFrame')
	popup.moneyFrame = E:StaticPopup_GetElement(popup, 'MoneyFrame')
	popup.moneyInputFrame = E:StaticPopup_GetElement(popup, 'MoneyInputFrame')
	popup.closeButton = E:StaticPopup_GetElement(popup, 'CloseButton')

	local i = 1
	local button = E:StaticPopup_GetElement(popup, 'Button'..i)
	while button do
		popup['button'..i] = button

		i = i + 1
		button = E:StaticPopup_GetElement(popup, 'Button'..i)
	end

	local itemFrame = E:StaticPopup_GetElement(popup, 'ItemFrame')
	if itemFrame then
		popup.itemFrame = itemFrame -- reference the main element
		popup.itemFrameText = itemFrame.Text or E:StaticPopup_GetElement(popup, 'ItemFrameText')
		popup.itemFrameNameFrame = itemFrame.NameFrame or E:StaticPopup_GetElement(popup, 'ItemFrameNameFrame')

		local item = itemFrame.Item
		if item then
			popup.itemFrameItem = item -- reference the item element
		end

		popup.itemFrameCount = (item and (item.count or item.Count)) or E:StaticPopup_GetElement(popup, 'ItemFrameCount')
		popup.itemFrameIconTexture = (item and (item.icon or item.Icon)) or E:StaticPopup_GetElement(popup, 'ItemFrameIconTexture')
	end

	-- resize on event
	popup:RegisterEvent('DISPLAY_SIZE_CHANGED')
end

function E:StaticPopup_HandleButtons(popup)
	if not popup.buttons then
		popup.buttons = {}
	end

	local i = 1
	local button = popup['button'..i]
	while button do
		E:StaticPopup_HandleButton(button)

		popup.buttons[i] = button

		i = i + 1
		button = popup['button'..i]
	end
end

function E:Contruct_StaticPopups()
	E.StaticPopupFrames = {}

	for index = 1, E.MAX_STATIC_POPUPS do
		local name = 'ElvUI_StaticPopup'..index
		local popup = CreateFrame('Frame', name, E.UIParent, 'ElvUIStaticPopupTemplate')

		E.StaticPopupFrames[index] = popup

		E:StaticPopup_OnLoad(popup)
		E:StaticPopup_HandleButtons(popup)

		popup:SetScript('OnShow', E.StaticPopup_OnShow)
		popup:SetScript('OnHide', E.StaticPopup_OnHide)
		popup:SetScript('OnEvent', E.StaticPopup_OnEvent)
		popup:SetScript('OnUpdate', E.StaticPopup_OnUpdate)
		popup:SetTemplate('Transparent')
		popup:SetID(index)
		popup:Hide()

		if not popup.checkButton then
			popup.checkButton = CreateFrame('CheckButton', name..'CheckButton', popup, 'UICheckButtonTemplate')
			popup.checkButton:SetScript('OnClick', E.StaticPopup_CheckButtonOnClick)
			popup.checkButton:Size(24)

			S:HandleCheckBox(popup.checkButton)

			popup.checkButtonText = _G[name..'CheckButtonText']

			if popup.checkButtonText then
				popup.checkButtonText:Point('LEFT', popup.checkButton, 'RIGHT', 4, 1)
				popup.checkButtonText:FontTemplate(nil, nil, 'SHADOW')
				popup.checkButtonText:SetTextColor(1,0.17,0.26)
			end
		end

		if popup.Border then
			popup.Border:StripTextures()
		end

		local extraButton = popup.extraButton
		if extraButton then
			extraButton:Hide()

			E:StaticPopup_HandleButton(extraButton)
		end

		local moneyInputFrame = popup.moneyInputFrame
		if moneyInputFrame then
			S:HandleEditBox(moneyInputFrame.gold)
			S:HandleEditBox(moneyInputFrame.silver)
			S:HandleEditBox(moneyInputFrame.copper)
		end

		local editBox = popup.editBox
		if editBox then
			editBox.ClearText = E.StaticPopup_ClearText -- use our own function, it doesnt exist on era

			editBox:SetScript('OnEnterPressed', E.StaticPopup_EditBoxOnEnterPressed)
			editBox:SetScript('OnEscapePressed', E.StaticPopup_EditBoxOnEscapePressed)
			editBox:SetScript('OnTextChanged', E.StaticPopup_EditBoxOnTextChanged)
			editBox:OffsetFrameLevel(1)

			S:HandleEditBox(editBox)

			if not editBox.NineSlice then
				editBox.backdrop:Point('TOPLEFT', -2, -4)
				editBox.backdrop:Point('BOTTOMRIGHT', 2, 4)
			end
		end

		local itemFrame = popup.itemFrame
		if itemFrame then
			local item = popup.itemFrameItem or itemFrame
			if item then
				local normalTexture = item:GetNormalTexture()
				if normalTexture then
					normalTexture:Kill()
				end

				item:SetTemplate()
				item:StyleButton()
			end

			if popup.itemFrameIconTexture then
				popup.itemFrameIconTexture:SetTexCoord(unpack(E.TexCoords))
				popup.itemFrameIconTexture:SetInside()
			end

			if popup.itemFrameNameFrame then
				popup.itemFrameNameFrame:Kill()
			end
		end
	end
end
