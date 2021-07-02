local E, _, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local next = next
local gsub = gsub
local ipairs = ipairs
local select = select
local format = format
local unpack = unpack
local tinsert = tinsert
local strmatch = strmatch

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
		local r, g, b = unpack(E.media.bordercolor)
		bd:SetBackdropBorderColor(r, g, b, 1)
		r, g, b = unpack(E.media.backdropcolor)
		bd:SetBackdropColor(r, g, b, 1)

		if self.wasRaised then
			LowerFrameLevel(self)
			self.wasRaised = nil
		end
	end
end

function S:Ace3_SkinTab(tab)
	tab:StripTextures()
	tab.text:Point('LEFT', 14, -1)

	tab:CreateBackdrop(nil, true, true)
	tab.backdrop:Point('TOPLEFT', 10, -3)
	tab.backdrop:Point('BOTTOMRIGHT', -10, 0)

	hooksecurefunc(tab, 'SetSelected', S.Ace3_TabSetSelected)
end

local nextPrevColor = {r = 1, g = .8, b = 0}
function S:Ace3_RegisterAsWidget(widget)
	local TYPE = widget.type
	if TYPE == 'MultiLineEditBox' or TYPE == 'MultiLineEditBox-ElvUI' then
		local frame = widget.frame
		S:HandleButton(widget.button)
		S:HandleScrollBar(widget.scrollBar)

		widget.scrollBG:SetTemplate()
		widget.scrollBG:Point('TOPRIGHT', widget.scrollBar, 'TOPLEFT', -2, 19)
		widget.scrollBG:Point('BOTTOMLEFT', widget.button, 'TOPLEFT')

		widget.scrollBar:Point('RIGHT', frame, 'RIGHT', 0 -4)
		widget.scrollFrame:Point('BOTTOMRIGHT', widget.scrollBG, 'BOTTOMRIGHT', -4, 8)
	elseif TYPE == 'CheckBox' then
		local check = widget.check
		local checkbg = widget.checkbg
		local highlight = widget.highlight

		checkbg:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
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
	elseif TYPE == 'Dropdown' or TYPE == 'LQDropdown' then
		local frame = widget.dropdown
		local button = widget.button
		local text = widget.text

		frame:StripTextures()
		frame:CreateBackdrop()
		frame.backdrop:Point('TOPLEFT', 15, -2)
		frame.backdrop:Point('BOTTOMRIGHT', -21, 0)

		S:HandleNextPrevButton(button, nil, nextPrevColor)

		widget.label:ClearAllPoints()
		widget.label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)

		button:ClearAllPoints()
		button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
		button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)

		text:ClearAllPoints()
		text:SetJustifyH('RIGHT')
		text:Point('RIGHT', button, 'LEFT', -3, 0)
		text:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)

		button:SetParent(frame.backdrop)
		text:SetParent(frame.backdrop)
	elseif TYPE == 'LSM30_Font' or TYPE == 'LSM30_Sound' or TYPE == 'LSM30_Border' or TYPE == 'LSM30_Background' or TYPE == 'LSM30_Statusbar' then
		local frame = widget.frame
		local button = frame.dropButton
		local text = frame.text

		frame:StripTextures()
		frame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
		frame.backdrop:Point('TOPLEFT', 0, -21)
		frame.backdrop:Point('BOTTOMRIGHT', -4, -1)

		frame.label:ClearAllPoints()
		frame.label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)

		frame.text:ClearAllPoints()
		frame.text:Point('RIGHT', button, 'LEFT', -2, 0)
		frame.text:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)

		button:ClearAllPoints()
		button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
		button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)

		if TYPE == 'LSM30_Sound' then
			widget.soundbutton:SetParent(frame.backdrop)
			widget.soundbutton:ClearAllPoints()
			widget.soundbutton:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)

			S:HandleNextPrevButton(button, nil, nextPrevColor)
		elseif TYPE == 'LSM30_Statusbar' then
			widget.bar:SetParent(frame.backdrop)
			widget.bar:ClearAllPoints()
			widget.bar:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 1, -1)
			widget.bar:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -1, 1)

			S:HandleNextPrevButton(button, nil, nextPrevColor, true)
		else
			S:HandleNextPrevButton(button, nil, nextPrevColor)
		end

		button:SetParent(frame.backdrop)
		text:SetParent(frame.backdrop)
		button:HookScript('OnClick', S.Ace3_SkinDropdown)
	elseif TYPE == 'EditBox' then
		local frame = widget.editbox
		local button = widget.button
		S:HandleEditBox(frame)
		S:HandleButton(button)

		button:Point('RIGHT', frame.backdrop, 'RIGHT', -2, 0)

		hooksecurefunc(frame, 'SetTextInsets', S.Ace3_EditBoxSetTextInsets)
		hooksecurefunc(frame, 'SetPoint', S.Ace3_EditBoxSetPoint)

		frame.backdrop:Point('TOPLEFT', 0, -2)
		frame.backdrop:Point('BOTTOMRIGHT', -1, 0)
	elseif TYPE == 'Button' or TYPE == 'Button-ElvUI' then
		local frame = widget.frame
		S:HandleButton(frame, true)
	elseif TYPE == 'Slider' or TYPE == 'Slider-ElvUI' then
		local frame = widget.slider
		local editbox = widget.editbox
		local lowtext = widget.lowtext
		local hightext = widget.hightext

		S:HandleSliderFrame(frame)

		editbox:SetTemplate()
		editbox:Height(15)
		editbox:Point('TOP', frame, 'BOTTOM', 0, -1)

		lowtext:Point('TOPLEFT', frame, 'BOTTOMLEFT', 2, -2)
		hightext:Point('TOPRIGHT', frame, 'BOTTOMRIGHT', -2, -2)
	elseif TYPE == 'Keybinding' then
		local button = widget.button
		local msgframe = widget.msgframe

		S:HandleButton(button, true)

		msgframe:StripTextures()
		msgframe:SetTemplate('Transparent')
		msgframe.msg:ClearAllPoints()
		msgframe.msg:Point('CENTER')
	elseif TYPE == 'ColorPicker' or TYPE == 'ColorPicker-ElvUI' then
		local frame = widget.frame
		local colorSwatch = widget.colorSwatch

		frame:CreateBackdrop()
		frame.backdrop:Size(24, 16)
		frame.backdrop:ClearAllPoints()
		frame.backdrop:Point('LEFT', frame, 'LEFT', 4, 0)

		colorSwatch:SetTexture(E.Media.Textures.White8x8)
		colorSwatch:ClearAllPoints()
		colorSwatch:SetParent(frame.backdrop)
		colorSwatch:SetInside(frame.backdrop)

		if colorSwatch.background then
			colorSwatch.background:SetColorTexture(0, 0, 0, 0)
		end

		if colorSwatch.checkers then
			colorSwatch.checkers:ClearAllPoints()
			colorSwatch.checkers:SetParent(frame.backdrop)
			colorSwatch.checkers:SetInside(frame.backdrop)
		end
	elseif TYPE == 'Icon' then
		widget.frame:StripTextures()
	elseif TYPE == 'Dropdown-Pullout' then
		local pullout = widget
		pullout.frame:SetTemplate(nil, true)

		if pullout.slider then
			pullout.slider:SetTemplate()
			pullout.slider:SetThumbTexture(E.Media.Textures.White8x8)
			local t = pullout.slider:GetThumbTexture()
			t:SetVertexColor(1, .82, 0, 0.8)
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
	if not self.tree then return end

	self.border:ClearAllPoints()
	if self.userdata and self.userdata.option and self.userdata.option.childGroups == 'ElvUI_HiddenTree' then
		self.border:Point('TOPLEFT', self.treeframe, 'TOPRIGHT', 1, 13)
		self.border:Point('BOTTOMRIGHT', self.frame, 'BOTTOMRIGHT', 6, 0)
		self.treeframe:Hide()
		return
	else
		self.border:Point('TOPLEFT', self.treeframe, 'TOPRIGHT')
		self.border:Point('BOTTOMRIGHT', self.frame)
		self.treeframe:Show()
	end

	if not E.private.skins.ace3Enable then return end

	local status = self.status or self.localstatus
	local groupstatus = status.groups
	local lines = self.lines
	local buttons = self.buttons
	local offset = status.scrollvalue

	for i = offset + 1, #lines do
		local button = buttons[i - offset]
		if button then
			if button.highlight then
				button.highlight:SetVertexColor(1.0, 0.9, 0.0, 0.8)
			end

			if groupstatus[lines[i].uniquevalue] then
				button.toggle:SetNormalTexture(E.Media.Textures.Minus)
				button.toggle:SetPushedTexture(E.Media.Textures.Minus)
			else
				button.toggle:SetNormalTexture(E.Media.Textures.Plus)
				button.toggle:SetPushedTexture(E.Media.Textures.Plus)
			end

			button.toggle:SetHighlightTexture('')
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
			for i=1, frame:GetNumChildren() do
				local child = select(i, frame:GetChildren())
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

		if TYPE == 'InlineGroup' then -- 'Window' is another type
			frame:SetTemplate('Transparent')
			frame.callbackBackdropColor = S.Ace3_BackdropColor
			S.Ace3_BackdropColor(frame)
		else
			frame:SetTemplate('Transparent')
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
	elseif TYPE == 'SimpleGroup' then
		local frame = widget.content:GetParent()
		frame:SetTemplate('Transparent')
		frame.callbackBackdropColor = S.Ace3_BackdropColor
		S.Ace3_BackdropColor(frame)
	end

	if widget.sizer_se then
		for i = 1, widget.sizer_se:GetNumRegions() do
			local Region = select(i, widget.sizer_se:GetRegions())
			if Region and Region:IsObjectType('Texture') then
				Region:SetTexture(137057) -- Interface\Tooltips\UI-Tooltip-Border
			end
		end
	end
end

function S:Ace3_StyleTooltip(tt)
	if not tt:IsForbidden() and E.private.skins.ace3Enable then
		tt:SetTemplate('Transparent')
	end
end

function S:Ace3_StylePopup()
	if not self:IsForbidden() and E.private.skins.ace3Enable then
		self:SetTemplate('Transparent', nil, true)
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
		S:Ace3_StyleTooltip(lib.tooltip)

		if lib.popup and not S:IsHooked(lib.popup, 'OnShow') then -- StaticPopup
			S:SecureHookScript(lib.popup, 'OnShow', S.Ace3_StylePopup)
		end
	end
end

function S:Ace3_MetaIndex(k, v)
	if k == 'tooltip' then
		rawset(self, k, v)
		S:Ace3_StyleTooltip(v)
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

local lastMinor = 0
function S:HookAce3(lib, minor, earlyLoad) -- lib: AceGUI
	if not lib or (not minor or minor < minorGUI) then return end

	if not S.Ace3_L and not earlyLoad then
		S.Ace3_L = E.Libs.ACL:GetLocale('ElvUI', E.global.general.locale)

		-- Special Enable Coloring
		if not S.Ace3_EnableMatch then S.Ace3_EnableMatch = '^|?c?[Ff]?[Ff]?%x?%x?%x?%x?%x?%x?' .. E:EscapeString(S.Ace3_L.Enable) .. '|?r?$' end
		if not S.Ace3_EnableOff then S.Ace3_EnableOff = format('|cffff3333%s|r', S.Ace3_L.Enable) end
		if not S.Ace3_EnableOn then S.Ace3_EnableOn = format('|cff33ff33%s|r', S.Ace3_L.Enable) end
	end

	local earlyContainer, earlyWidget
	local oldMinor = lastMinor
	if lastMinor < minor then
		lastMinor = minor
	end
	if earlyLoad then
		earlyContainer = lib.RegisterAsContainer
		earlyWidget = lib.RegisterAsWidget
	end
	if earlyLoad or oldMinor ~= minor then
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
		['LibUIDropDownMenu'] = true,
		['LibUIDropDownMenuQuestie'] = true,
		['NoTaint_UIDropDownMenu'] = true,
	}

	S.EarlyAceWidgets = {}
	S.EarlyAceTooltips = {}
	S.EarlyDropdowns = {}

	local LibStub = _G.LibStub
	local numEnding = '%-[%d%.]+$'
	function S:LibStub_NewLib(major, minor)
		local earlyLoad = major == 'ElvUI'
		if earlyLoad then major = minor end

		local n = gsub(major, numEnding, '')
		if Libraries[n] then
			if n == 'AceGUI' then
				S:HookAce3(LibStub.libs[major], LibStub.minors[major], earlyLoad)
				if earlyLoad then
					tinsert(S.EarlyAceTooltips, major)
				else
					S:Ace3_SkinTooltip(LibStub.libs[major])
				end
			elseif n == 'AceConfigDialog' or n == 'AceConfigDialog-3.0-ElvUI' then
				if earlyLoad then
					tinsert(S.EarlyAceTooltips, major)
				else
					S:Ace3_SkinTooltip(LibStub.libs[major], LibStub.minors[major])
				end
			else
				local prefix = (n == 'NoTaint_UIDropDownMenu' and 'Lib') or (n == 'LibUIDropDownMenuQuestie' and 'LQuestie') or (n == 'LibUIDropDownMenu' and 'L')
				if prefix and not S[prefix..'_UIDropDownMenuSkinned'] then
					if earlyLoad then
						tinsert(S.EarlyDropdowns, prefix)
					else
						S:SkinLibDropDownMenu(prefix)
					end
				end
			end
		end
	end

	local findWidget
	local function earlyWidget(y)
		if y.children then findWidget(y.children) end
		if y.frame and (y.base and y.base.Release) then
			tinsert(S.EarlyAceWidgets, y)
		end
	end

	findWidget = function(x)
		for _, y in ipairs(x) do
			earlyWidget(y)
		end
	end

	for n in next, LibStub.libs do
		if n == 'AceGUI-3.0' then
			for _, x in ipairs({_G.UIParent:GetChildren()}) do
				if x and x.obj then earlyWidget(x.obj) end
			end
		end
		if Libraries[gsub(n, numEnding, '')] then
			S:LibStub_NewLib('ElvUI', n)
		end
	end

	hooksecurefunc(LibStub, 'NewLibrary', S.LibStub_NewLib)
end
