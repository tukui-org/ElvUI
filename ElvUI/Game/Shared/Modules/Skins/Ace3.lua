local E = unpack(ElvUI)
local S = E:GetModule('Skins')

local next = next
local gsub = gsub
local ipairs = ipairs
local format = format
local unpack = unpack
local tinsert = tinsert
local strmatch = strmatch

local UIParent = UIParent
local RaiseFrameLevel = RaiseFrameLevel
local LowerFrameLevel = LowerFrameLevel
local hooksecurefunc = hooksecurefunc
local getmetatable = getmetatable
local setmetatable = setmetatable
local rawset = rawset

-- these do *not* need to match the current lib minor version
-- these numbers are used to not attempt skinning way older
-- versions of AceGUI and AceConfigDialog.
local minorGUI, minorConfigDialog = 36, 76

function S:Ace3_BackdropColor()
	self:SetBackdropColor(0, 0, 0, 0.25)
end

function S:Ace3_SkinDropdown()
	if self and self.obj then
		local pullout = self.obj.dropdown -- Don't ask questions.. Just FUCKING ACCEPT IT
		if pullout then
			if pullout.frame then
				pullout.frame:SetTemplate(nil, true)
			else
				pullout:SetTemplate(nil, true)
			end

			if pullout.slider then
				pullout.slider:SetTemplate()
				pullout.slider:SetThumbTexture(E.Media.Textures.White8x8)

				local t = pullout.slider:GetThumbTexture()
				t:SetVertexColor(1, .82, 0, 0.8)
			end
		end
	end
end

function S:Ace3_CheckBoxIsEnable(widget)
	local text = widget and widget.text and widget.text:GetText()
	if text and S.Ace3_EnableMatch then return strmatch(text, S.Ace3_EnableMatch) end
end

function S:Ace3_CheckBoxSetDesaturated(value)
	local widget = self:GetParent().obj
	if value == true then
		self:SetVertexColor(.6, .6, .6, .8)
	elseif S:Ace3_CheckBoxIsEnable(widget) then
		if widget.checked then
			self:SetVertexColor(0.2, 1.0, 0.2, 1.0)
		else
			self:SetVertexColor(1.0, 0.2, 0.2, 1.0)
		end
	else
		self:SetVertexColor(1, .82, 0, 0.8)
	end
end

function S:Ace3_CheckBoxSetDisabled(disabled)
	if S:Ace3_CheckBoxIsEnable(self) then
		local tristateOrDisabled = disabled or (self.tristate and self.checked == nil)
		self:SetLabel((tristateOrDisabled and S.Ace3_L.Enable) or (self.checked and S.Ace3_EnableOn) or S.Ace3_EnableOff)
	end
end

function S:Ace3_EditBoxSetTextInsets(l, r, t, b)
	if l == 0 then self:SetTextInsets(3, r, t, b) end
end

function S:Ace3_EditBoxSetPoint(a, b, c, d, e)
	if d == 7 then
		self:Point(a, b, c, 0, e)
	end
end

function S:Ace3_CheckBoxSetType(type)
	if type == 'radio' then
		self.checkbg:SetSize(20, 20)
	end
end

function S:Ace3_TabSetSelected(selected)
	local bd = self.backdrop
	if not bd then return end

	if selected then
		bd:SetBackdropBorderColor(1, .82, 0, 1)
		bd:SetBackdropColor(1, .82, 0, 0.4)

		if not self.wasRaised then
			RaiseFrameLevel(self)
			self.wasRaised = true
		end
	else
		local br, bg, bb = unpack(E.media.bordercolor)
		bd:SetBackdropBorderColor(br, bg, bb, 1)

		local bdr, bdg, bdb = unpack(E.media.backdropcolor)
		bd:SetBackdropColor(bdr, bdg, bdb, 1)

		if self.wasRaised then
			LowerFrameLevel(self)
			self.wasRaised = nil
		end
	end
end

function S:Ace3_ButtonSetPoint(point, anchor, point2, xOffset, yOffset, skip)
	if not skip and point2 == 'TOPRIGHT' then
		self:Point(point, anchor, point2, xOffset + 2, yOffset, true)
	end
end

function S:Ace3_SkinButton(button)
	if not button.IsSkinned then
		S:HandleButton(button, true)

		hooksecurefunc(button, 'SetPoint', S.Ace3_ButtonSetPoint)
	end
end

function S:Ace3_SkinCheckBox(widget, check, checkbg, highlight)
	if not checkbg.backdrop then
		checkbg:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, true)
		checkbg.backdrop:SetInside(widget.checkbg, 4, 4)

		checkbg:SetTexture()
		highlight:SetTexture()

		hooksecurefunc(widget, 'SetDisabled', S.Ace3_CheckBoxSetDisabled)
		hooksecurefunc(widget, 'SetType', S.Ace3_CheckBoxSetType)

		if E.private.skins.checkBoxSkin then
			S.Ace3_CheckBoxSetDesaturated(check, check:GetDesaturation())
			hooksecurefunc(check, 'SetDesaturated', S.Ace3_CheckBoxSetDesaturated)

			checkbg.backdrop:SetInside(widget.checkbg, 5, 5)
			check:SetInside(widget.checkbg.backdrop)

			check:SetTexture(E.Media.Textures.Melli)
			check.SetTexture = E.noop
		else
			check:SetOutside(checkbg.backdrop, 3, 3)
		end

		checkbg.SetTexture = E.noop
		highlight.SetTexture = E.noop
	end
end

function S:Ace3_SkinTab(tab)
	if not tab.backdrop then
		tab:StripTextures()
		tab:CreateBackdrop(nil, true, true)
		tab.backdrop:Point('TOPLEFT', 10, -3)
		tab.backdrop:Point('BOTTOMRIGHT', -10, 0)

		if tab.text and tab.text.Point then -- possible issue with Pally Power
			tab.text:Point('LEFT', 14, -1)
		end

		hooksecurefunc(tab, 'SetSelected', S.Ace3_TabSetSelected)
	end
end

function S:Ace3_SkinEditBox(editbox, button)
	if not editbox.backdrop then
		S:HandleEditBox(editbox)
		S:HandleButton(button)

		button:Point('RIGHT', editbox.backdrop, 'RIGHT', -2, 0)

		hooksecurefunc(editbox, 'SetTextInsets', S.Ace3_EditBoxSetTextInsets)
		hooksecurefunc(editbox, 'SetPoint', S.Ace3_EditBoxSetPoint)

		if not editbox.NineSlice then
			editbox.backdrop:Point('TOPLEFT', 0, -2)
			editbox.backdrop:Point('BOTTOMRIGHT', -1, 1)
		end
	end
end

local nextPrevColor = {r = 1, g = .8, b = 0}
function S:Ace3_RegisterAsWidget(widget)
	local TYPE = widget.type
	if TYPE == 'MultiLineEditBox' or TYPE == 'MultiLineEditBox-ElvUI' then
		local scrollbar = widget.scrollBar
		if scrollbar then
			S:HandleButton(widget.button)
			S:HandleScrollBar(scrollbar)

			local bg = widget.scrollBG
			if bg then
				bg:SetTemplate()
				bg:Point('TOPRIGHT', scrollbar, 'TOPLEFT', -2, 19)
				bg:Point('BOTTOMLEFT', widget.button, 'TOPLEFT')

				scrollbar:Point('RIGHT', widget.frame, 'RIGHT', 0 -4)
				widget.scrollFrame:Point('BOTTOMRIGHT', bg, 'BOTTOMRIGHT', -4, 8)
			end
		end
	elseif TYPE == 'CheckBox' then
		S:Ace3_SkinCheckBox(widget, widget.check, widget.checkbg, widget.highlight)
	elseif TYPE == 'Dropdown' or TYPE == 'Dropdown-ElvUI' or TYPE == 'LQDropdown' then
		local frame = widget.dropdown

		frame:StripTextures()
		frame:CreateBackdrop()
		frame.backdrop:Point('TOPLEFT', 15, -2)
		frame.backdrop:Point('BOTTOMRIGHT', -21, 0)

		local label = widget.label
		if label then
			label:ClearAllPoints()
			label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)
		end

		local button = widget.button
		if button then
			S:HandleNextPrevButton(button, nil, nextPrevColor)

			button:ClearAllPoints()
			button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
			button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)
			button:SetParent(frame.backdrop)
		end

		local text = widget.text
		if text then
			text:ClearAllPoints()
			text:SetJustifyH('RIGHT')
			text:Point('RIGHT', button, 'LEFT', -3, 0)
			text:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
			text:SetParent(frame.backdrop)
		end
	elseif TYPE == 'LSM30_Font' or TYPE == 'LSM30_Sound' or TYPE == 'LSM30_Border' or TYPE == 'LSM30_Background' or TYPE == 'LSM30_Statusbar' then
		local frame = widget.frame

		frame:StripTextures()
		frame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, true)
		frame.backdrop:Point('TOPLEFT', 0, -21)
		frame.backdrop:Point('BOTTOMRIGHT', -4, -1)

		local label = frame.label
		if label then
			label:ClearAllPoints()
			label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)
		end

		local button = frame.dropButton
		if button then
			local text = frame.text
			if text then
				text:ClearAllPoints()
				text:Point('RIGHT', button, 'LEFT', -2, 0)
				text:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
				text:SetParent(frame.backdrop)
			end

			if TYPE == 'LSM30_Statusbar' then
				S:HandleNextPrevButton(button, nil, nextPrevColor, true)

				local bar = widget.bar
				if bar then
					bar:SetParent(frame.backdrop)
					bar:ClearAllPoints()
					bar:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 1, -1)
					bar:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -1, 1)
				end
			else
				S:HandleNextPrevButton(button, nil, nextPrevColor)

				local soundbutton = TYPE == 'LSM30_Sound' and widget.soundbutton
				if soundbutton then
					soundbutton:SetParent(frame.backdrop)
					soundbutton:ClearAllPoints()
					soundbutton:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
				end
			end

			button:ClearAllPoints()
			button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
			button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)
			button:SetParent(frame.backdrop)
			button:HookScript('OnClick', S.Ace3_SkinDropdown)
		end
	elseif TYPE == 'EditBox' or TYPE == 'EditBox-ElvUI' then
		S:Ace3_SkinEditBox(widget.editbox, widget.button)
	elseif TYPE == 'Button' or TYPE == 'Button-ElvUI' then
		S:Ace3_SkinButton(widget.frame)
	elseif TYPE == 'Slider' or TYPE == 'Slider-ElvUI' then
		local slider = widget.slider
		S:HandleSliderFrame(slider)

		local editbox = widget.editbox
		if editbox then
			editbox:SetTemplate()
			editbox:Height(15)
			editbox:Point('TOP', slider, 'BOTTOM', 0, -1)
		end

		local lowtext = widget.lowtext
		if lowtext then
			lowtext:Point('TOPLEFT', slider, 'BOTTOMLEFT', 2, -2)
		end

		local hightext = widget.hightext
		if hightext then
			hightext:Point('TOPRIGHT', slider, 'BOTTOMRIGHT', -2, -2)
		end
	elseif TYPE == 'Keybinding' then
		local button = widget.button
		if button then
			S:HandleButton(button, true)
		end

		local msgframe = widget.msgframe
		if msgframe then
			msgframe:StripTextures()
			msgframe:SetTemplate('Transparent')

			local msg = msgframe.msg
			if msg then
				msg:ClearAllPoints()
				msg:Point('CENTER')
			end
		end
	elseif TYPE == 'ColorPicker' or TYPE == 'ColorPicker-ElvUI' then
		local frame = widget.frame
		frame:CreateBackdrop()
		frame.backdrop:Size(24, 16)
		frame.backdrop:ClearAllPoints()
		frame.backdrop:Point('LEFT', frame, 'LEFT', 4, 0)

		local colorSwatch = widget.colorSwatch
		if colorSwatch then
			colorSwatch:SetTexture(E.Media.Textures.White8x8)
			colorSwatch:ClearAllPoints()
			colorSwatch:SetParent(frame.backdrop)
			colorSwatch:SetInside(frame.backdrop)

			local bg = colorSwatch.background
			if bg then
				bg:SetColorTexture(0, 0, 0, 0)
			end

			local checkers = colorSwatch.checkers
			if checkers then
				checkers:ClearAllPoints()
				checkers:SetParent(frame.backdrop)
				checkers:SetInside(frame.backdrop)
			end
		end
	elseif TYPE == 'Icon' then
		widget.frame:StripTextures()
	elseif TYPE == 'Dropdown-Pullout' then
		local frame = widget.frame
		if frame then
			frame:SetTemplate(nil, true)
		end

		local slider = widget.slider
		if slider then
			slider:SetTemplate()
			slider:SetThumbTexture(E.Media.Textures.White8x8)

			local thumb = slider:GetThumbTexture()
			if thumb then
				thumb:SetVertexColor(1, .82, 0, 0.8)
			end
		end
	end
end

function S:Ace3_CreateTab(id)
	local tab = self.old_CreateTab(self, id)
	S:Ace3_SkinTab(tab)

	return tab
end

function S:Ace3_RefreshTree(scrollToSelection)
	self.old_RefreshTree(self, scrollToSelection)

	local tree = self.tree
	if not tree then return end

	local border = self.border
	local treeframe = self.treeframe
	if border and treeframe then
		border:ClearAllPoints()

		local userdata = self.userdata
		local dataoption = userdata and userdata.option
		if dataoption and dataoption.childGroups == 'ElvUI_HiddenTree' then
			border:Point('TOPLEFT', treeframe, 'TOPRIGHT', 1, 13)
			border:Point('BOTTOMRIGHT', self.frame, 'BOTTOMRIGHT', 6, 0)

			treeframe:Point('TOPLEFT', 0, 0)

			if treeframe:IsShown() then
				treeframe:Hide()
			end

			return -- dont proceed
		else
			border:Point('TOPLEFT', treeframe, 'TOPRIGHT')
			border:Point('BOTTOMRIGHT', self.frame)

			treeframe:Point('TOPLEFT', 0, -2)

			if not treeframe:IsShown() then
				treeframe:Show()
			end
		end
	end

	if not E.private.skins.ace3Enable then return end

	local lines = self.lines
	local buttons = self.buttons
	if lines and buttons then
		local status = self.status or self.localstatus
		local offset = status.scrollvalue
		local groupstatus = status.groups

		for i = offset + 1, #lines do
			local button = buttons[i - offset]
			if button then
				if button.highlight then
					button.highlight:SetVertexColor(1.0, 0.9, 0.0, 0.8)
				end

				local line = lines[i]
				local unique = line and line.uniquevalue
				if unique and groupstatus[unique] then
					button.toggle:SetNormalTexture(E.Media.Textures.Minus)
					button.toggle:SetPushedTexture(E.Media.Textures.Minus)
				else
					button.toggle:SetNormalTexture(E.Media.Textures.Plus)
					button.toggle:SetPushedTexture(E.Media.Textures.Plus)
				end

				button.toggle:SetHighlightTexture(E.ClearTexture)
			end
		end
	end
end

function S:Ace3_RegisterAsContainer(widget)
	local TYPE = widget.type
	if TYPE == 'ScrollFrame' then
		S:HandleScrollBar(widget.scrollbar)
	elseif TYPE == 'InlineGroup' or TYPE == 'TreeGroup' or TYPE == 'TabGroup' or TYPE == 'Frame' or TYPE == 'DropdownGroup' or TYPE == 'Window' then
		local frame = widget.content:GetParent()
		if TYPE == 'Frame' then
			frame:StripTextures()

			for _, child in next, { frame:GetChildren() } do
				if child:IsObjectType('Button') and child:GetText() then
					S:HandleButton(child)
				else
					child:StripTextures()
				end
			end
		elseif TYPE == 'Window' then
			frame:StripTextures()

			S:HandleCloseButton(frame.obj.closebutton)
		end

		frame:SetTemplate('Transparent')

		if TYPE == 'InlineGroup' then -- 'Window' is another type
			frame.callbackBackdropColor = S.Ace3_BackdropColor
			S.Ace3_BackdropColor(frame)
		end

		if widget.treeframe then
			widget.treeframe:SetTemplate('Transparent')
		end

		if TYPE == 'TabGroup' then
			if not widget.old_CreateTab then
				widget.old_CreateTab = widget.CreateTab
				widget.CreateTab = S.Ace3_CreateTab
			end

			if widget.tabs then
				for _, n in next, widget.tabs do
					S:Ace3_SkinTab(n)
				end
			end
		end

		if widget.scrollbar then
			S:HandleScrollBar(widget.scrollbar)
		end
	end

	if widget.sizer_se then
		for _, Region in next, { widget.sizer_se:GetRegions() } do
			if Region:IsObjectType('Texture') then
				Region:SetTexture(137057) -- Interface\Tooltips\UI-Tooltip-Border
			end
		end
	end
end

function S:Ace3_StyleTooltip()
	if not self:IsForbidden() and E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip then
		self:SetTemplate('Transparent')
	end
end

function S:Ace3_StylePopup()
	if not self:IsForbidden() and E.private.skins.ace3Enable then
		self:SetTemplate(nil, nil, true)
		self:GetChildren():StripTextures()

		S:HandleButton(self.accept, true)
		S:HandleButton(self.cancel, true)
	end
end

function S:Ace3_MetaTable(lib)
	local t = getmetatable(lib)
	if t then
		t.__newindex = S.Ace3_MetaIndex
	else
		setmetatable(lib, {__newindex = S.Ace3_MetaIndex})
	end
end

function S:Ace3_SkinTooltip(lib, minor) -- lib: AceConfigDialog or AceGUI
	-- we only check `minor` here when checking an instance of AceConfigDialog
	-- we can safely ignore it when checking AceGUI because we minor check that
	-- inside of its own function.
	if not lib or (minor and minor < minorConfigDialog) then return end

	if not lib.tooltip then
		S:Ace3_MetaTable(lib)
	else
		S.Ace3_StyleTooltip(lib.tooltip)

		if lib.popup and not S:IsHooked(lib.popup, 'OnShow') then -- StaticPopup
			S:SecureHookScript(lib.popup, 'OnShow', S.Ace3_StylePopup)
		end
	end
end

function S:Ace3_MetaIndex(k, v)
	if k == 'tooltip' then
		rawset(self, k, v)

		S.Ace3_StyleTooltip(v)
	elseif k == 'popup' then
		rawset(self, k, v)

		S:SecureHookScript(v, 'OnShow', S.Ace3_StylePopup)
	elseif k == 'RegisterAsContainer' then
		rawset(self, k, function(s, w, ...)
			if E.private.skins.ace3Enable then
				S.Ace3_RegisterAsContainer(s, w, ...)
			end

			if w.treeframe and not w.old_RefreshTree then
				w.old_RefreshTree = w.RefreshTree
				w.RefreshTree = S.Ace3_RefreshTree
			end

			return v(s, w, ...)
		end)
	elseif k == 'RegisterAsWidget' then
		rawset(self, k, function(...)
			if E.private.skins.ace3Enable then
				S.Ace3_RegisterAsWidget(...)
			end

			return v(...)
		end)
	else
		rawset(self, k, v)
	end
end

function S:Ace3_ColorizeEnable(L)
	S.Ace3_L = L

	-- Special Enable Coloring
	S.Ace3_EnableMatch = '^|?c?[Ff]?[Ff]?%x?%x?%x?%x?%x?%x?' .. E:EscapeString(S.Ace3_L.Enable) .. '|?r?$'
	S.Ace3_EnableOff = format('|cffff3333%s|r', S.Ace3_L.Enable)
	S.Ace3_EnableOn = format('|cff33ff33%s|r', S.Ace3_L.Enable)
end

local lastMinor = 0
function S:HookAce3(lib, minor, early) -- lib: AceGUI
	if not lib or (not minor or minor < minorGUI) then return end

	local earlyContainer, earlyWidget
	local oldMinor = lastMinor
	if lastMinor < minor then
		lastMinor = minor
	end
	if early then
		earlyContainer = lib.RegisterAsContainer
		earlyWidget = lib.RegisterAsWidget
	end
	if early or oldMinor ~= minor then
		lib.RegisterAsContainer = nil
		lib.RegisterAsWidget = nil
	end

	if not lib.RegisterAsWidget then
		S:Ace3_MetaTable(lib)
	end

	if earlyContainer then lib.RegisterAsContainer = earlyContainer end
	if earlyWidget then lib.RegisterAsWidget = earlyWidget end
end

do -- Early Skin Loading
	local Libraries = {
		['AceGUI'] = true,
		['AceConfigDialog'] = true,
		['AceConfigDialog-3.0-ElvUI'] = true,
		['LibDropDownMenu'] = true,
		['LibUIDropDownMenu'] = true,
		['LibUIDropDownMenuQuestie'] = true,
		['NoTaint_UIDropDownMenu'] = true,
	}

	S.EarlyAceWidgets = {}
	S.EarlyAceTooltips = {}
	S.EarlyDropdowns = {}

	local LibStub = _G.LibStub
	local numEnding = '%-[%d%.]+$'
	function S:LibStub_NewLib(major)
		local early = not E.initialized
		local n = gsub(major, numEnding, '')
		if Libraries[n] then
			if n == 'AceGUI' then
				S:HookAce3(LibStub.libs[major], LibStub.minors[major], early)
				if early then
					tinsert(S.EarlyAceTooltips, major)
				else
					S:Ace3_SkinTooltip(LibStub.libs[major])
				end
			elseif n == 'AceConfigDialog' or n == 'AceConfigDialog-3.0-ElvUI' then
				if early then
					tinsert(S.EarlyAceTooltips, major)
				else
					S:Ace3_SkinTooltip(LibStub.libs[major], LibStub.minors[major])
				end
			elseif n == 'LibDropDownMenu' then
				if early then
					tinsert(S.EarlyDropdowns, 'LibDropDownMenu_List')
				elseif E.private.skins.libDropdown then
					S:SkinDropDownMenu('LibDropDownMenu_List', 15)
				end
			else
				local prefix = (n == 'NoTaint_UIDropDownMenu' and 'Lib') or (n == 'LibUIDropDownMenuQuestie' and 'LQuestie') or (major == 'LibUIDropDownMenu-4.0' and 'L4' or major == 'LibUIDropDownMenu-3.0' and 'L3')
				if prefix and not S[prefix..'_UIDropDownMenuSkinned'] then
					if early then
						tinsert(S.EarlyDropdowns, prefix)
					elseif E.private.skins.libDropdown then
						S:SkinLibDropDownMenu(prefix)
					end
				end
			end
		end
	end

	local FindWidget
	local function EarlyWidget(y)
		if y.children then FindWidget(y.children) end
		if y.frame and (y.base and y.base.Release) then
			tinsert(S.EarlyAceWidgets, y)
		end
	end

	FindWidget = function(x)
		for _, y in ipairs(x) do
			EarlyWidget(y)
		end
	end

	for n in next, LibStub.libs do
		if n == 'AceGUI-3.0' then
			for _, x in next, { UIParent:GetChildren() } do
				if x and x.obj then EarlyWidget(x.obj) end
			end
		end
		if Libraries[gsub(n, numEnding, '')] then
			S:LibStub_NewLib(n)
		end
	end

	hooksecurefunc(LibStub, 'NewLibrary', S.LibStub_NewLib)
end
