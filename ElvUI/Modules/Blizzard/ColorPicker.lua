--[[
	Credit to Jaslm, most of this code is his from the addon ColorPickerPlus
]]

local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard');
local S = E:GetModule('Skins');

local _G = _G
local tonumber = tonumber
local floor = math.floor
local format, strsub = string.format, strsub
--WoW API / Variables
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CALENDAR_COPY_EVENT, CALENDAR_PASTE_EVENT = CALENDAR_COPY_EVENT, CALENDAR_PASTE_EVENT
local CLASS, DEFAULT = CLASS, DEFAULT

local colorBuffer = {}
local editingText

local function UpdateAlphaText()
	local a = _G.OpacitySliderFrame:GetValue()
	a = (1 - a) * 100
	a = floor(a +.05)
	_G.ColorPPBoxA:SetText(("%d"):format(a))
end

local function UpdateAlpha(tbox)
	local a = tbox:GetNumber()
	if a > 100 then
		a = 100
		_G.ColorPPBoxA:SetText(("%d"):format(a))
	end
	a = 1 - (a / 100)
	editingText = true
	_G.OpacitySliderFrame:SetValue(a)
	editingText = nil
end

local function UpdateColorTexts(r, g, b)
	if not r then r, g, b = _G.ColorPickerFrame:GetColorRGB() end
	r = r*255
	g = g*255
	b = b*255
	_G.ColorPPBoxR:SetText(("%d"):format(r))
	_G.ColorPPBoxG:SetText(("%d"):format(g))
	_G.ColorPPBoxB:SetText(("%d"):format(b))
	_G.ColorPPBoxH:SetText(("%.2x%.2x%.2x"):format(r, g, b))
end

local function UpdateColor(tbox)
	local r, g, b = _G.ColorPickerFrame:GetColorRGB()
	local id = tbox:GetID()

	if id == 1 then
		r = format("%d", tbox:GetNumber())
		if not r then r = 0 end
		r = r/255
	elseif id == 2 then
		g = format("%d", tbox:GetNumber())
		if not g then g = 0 end
		g = g/255
	elseif id == 3 then
		b = format("%d", tbox:GetNumber())
		if not b then b = 0 end
		b = b/255
	elseif id == 4 then
		-- hex values
		if tbox:GetNumLetters() == 6 then
			local rgb = tbox:GetText()
			r, g, b = tonumber('0x'..strsub(rgb, 0, 2)), tonumber('0x'..strsub(rgb, 3, 4)), tonumber('0x'..strsub(rgb, 5, 6))
			if not r then r = 0 else r = r/255 end
			if not g then g = 0 else g = g/255 end
			if not b then b = 0 else b = b/255 end
		else
			return
		end
	end

	-- This takes care of updating the hex entry when changing rgb fields and vice versa
	UpdateColorTexts(r,g,b)

	editingText = true
	_G.ColorPickerFrame:SetColorRGB(r, g, b)
	_G.ColorSwatch:SetColorTexture(r, g, b)
	editingText = nil
end

local function HandleUpdateLimiter(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed
	if self.timeSinceUpdate > 0.15 then
		self.allowUpdate = true
	else
		self.allowUpdate = false
	end
end

function B:EnhanceColorPicker()
	if IsAddOnLoaded("ColorPickerPlus") then
		return
	end
	_G.ColorPickerFrame:SetClampedToScreen(true)

	--Skin the default frame, move default buttons into place
	_G.ColorPickerFrame:SetTemplate("Transparent")
	_G.ColorPickerFrameHeader:SetTexture()
	_G.ColorPickerFrameHeader:ClearAllPoints()
	_G.ColorPickerFrameHeader:Point("TOP", _G.ColorPickerFrame, 0, 0)
	S:HandleButton(_G.ColorPickerOkayButton)
	S:HandleButton(_G.ColorPickerCancelButton)
	_G.ColorPickerCancelButton:ClearAllPoints()
	_G.ColorPickerOkayButton:ClearAllPoints()
	_G.ColorPickerCancelButton:Point("BOTTOMRIGHT", _G.ColorPickerFrame, "BOTTOMRIGHT", -6, 6)
	_G.ColorPickerCancelButton:Point("BOTTOMLEFT", _G.ColorPickerFrame, "BOTTOM", 0, 6)
	_G.ColorPickerOkayButton:Point("BOTTOMLEFT", _G.ColorPickerFrame,"BOTTOMLEFT", 6,6)
	_G.ColorPickerOkayButton:Point("RIGHT", _G.ColorPickerCancelButton,"LEFT", -4,0)
	S:HandleSliderFrame(_G.OpacitySliderFrame)
	_G.ColorPickerFrame:HookScript("OnShow", function(frame)
		-- get color that will be replaced
		local r, g, b = frame:GetColorRGB()
		_G.ColorPPOldColorSwatch:SetColorTexture(r,g,b)

			-- show/hide the alpha box
		if frame.hasOpacity then
			_G.ColorPPBoxA:Show()
			_G.ColorPPBoxLabelA:Show()
			_G.ColorPPBoxH:SetScript("OnTabPressed", function() _G.ColorPPBoxA:SetFocus() end)
			UpdateAlphaText()
			frame:Width(405)
		else
			_G.ColorPPBoxA:Hide()
			_G.ColorPPBoxLabelA:Hide()
			_G.ColorPPBoxH:SetScript("OnTabPressed", function() _G.ColorPPBoxR:SetFocus() end)
			frame:Width(345)
		end

		--Set OnUpdate script to handle update limiter
		frame:SetScript("OnUpdate", HandleUpdateLimiter)
	end)

	--Memory Fix, Colorpicker will call the self.func() 100x per second, causing fps/memory issues,
	--We overwrite the OnColorSelect script and set a limit on how often we allow a call to self.func
	_G.ColorPickerFrame:SetScript('OnColorSelect', function(frame, r, g, b)
		_G.ColorSwatch:SetColorTexture(r, g, b)
		if not editingText then
			UpdateColorTexts(r, g, b)
		end
		if frame.allowUpdate then
			frame.func()
			frame.timeSinceUpdate = 0
		end
	end)

	_G.OpacitySliderFrame:HookScript("OnValueChanged", function()
		if not editingText then
			UpdateAlphaText()
		end
	end)

	-- make the Color Picker dialog a bit taller, to make room for edit boxes
	_G.ColorPickerFrame:Height(_G.ColorPickerFrame:GetHeight() + 40)

	-- move the Color Swatch
	_G.ColorSwatch:ClearAllPoints()
	_G.ColorSwatch:Point("TOPLEFT", _G.ColorPickerFrame, "TOPLEFT", 215, -45)

	-- add Color Swatch for original color
	local t = _G.ColorPickerFrame:CreateTexture("ColorPPOldColorSwatch")
	local w, h = _G.ColorSwatch:GetSize()
	t:Size(w*0.75,h*0.75)
	t:SetColorTexture(0,0,0)
	-- OldColorSwatch to appear beneath ColorSwatch
	t:SetDrawLayer("BORDER")
	t:Point("BOTTOMLEFT", "ColorSwatch", "TOPRIGHT", -(w/2), -(h/3))

	-- add Color Swatch for the copied color
	t = _G.ColorPickerFrame:CreateTexture("ColorPPCopyColorSwatch")
	t:Size(w,h)
	t:SetColorTexture(0,0,0)
	t:Hide()

	-- add copy button to the _G.ColorPickerFrame
	local b = CreateFrame("Button", "ColorPPCopy", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	S:HandleButton(b)
	b:SetText(CALENDAR_COPY_EVENT)
	b:Width(60)
	b:Height(22)
	b:Point("TOPLEFT", "ColorSwatch", "BOTTOMLEFT", 0, -5)

	-- copy color into buffer on button click
	b:SetScript("OnClick", function()
		-- copy current dialog colors into buffer
		colorBuffer.r, colorBuffer.g, colorBuffer.b = _G.ColorPickerFrame:GetColorRGB()

		-- enable Paste button and display copied color into swatch
		_G.ColorPPPaste:Enable()
		_G.ColorPPCopyColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		_G.ColorPPCopyColorSwatch:Show()

		if _G.ColorPickerFrame.hasOpacity then
			colorBuffer.a = _G.OpacitySliderFrame:GetValue()
		else
			colorBuffer.a = nil
		end
	end)

	--class color button
	b = CreateFrame('Button', 'ColorPPClass', _G.ColorPickerFrame, 'UIPanelButtonTemplate')
	b:SetText(CLASS)
	S:HandleButton(b)
	b:Width(80)
	b:Height(22)
	b:Point("TOP", "ColorPPCopy", "BOTTOMRIGHT", 0, -7)

	b:SetScript('OnClick', function()
		local color = E.myclass == 'PRIEST' and E.PriestColors or (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]);
		_G.ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
		_G.ColorSwatch:SetColorTexture(color.r, color.g, color.b)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	-- add paste button to the _G.ColorPickerFrame
	b = CreateFrame("Button", "ColorPPPaste", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(CALENDAR_PASTE_EVENT)
	S:HandleButton(b)
	b:Width(60)
	b:Height(22)
	b:Point('TOPLEFT', 'ColorPPCopy', 'TOPRIGHT', 2, 0)
	b:Disable()  -- enable when something has been copied

	-- paste color on button click, updating frame components
	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		_G.ColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		if _G.ColorPickerFrame.hasOpacity then
			if colorBuffer.a then  --color copied had an alpha value
				_G.OpacitySliderFrame:SetValue(colorBuffer.a)
			end
		end
	end)

	-- add defaults button to the _G.ColorPickerFrame
	b = CreateFrame("Button", "ColorPPDefault", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(DEFAULT)
	S:HandleButton(b)
	b:Width(80)
	b:Height(22)
	b:Point("TOPLEFT", "ColorPPClass", "BOTTOMLEFT", 0, -7)
	b:Disable()  -- enable when something has been copied
	b:SetScript("OnHide", function(btn)
		btn.colors = nil
	end)
	b:SetScript("OnShow", function(btn)
		if btn.colors then
			btn:Enable()
		else
			btn:Disable()
		end
	end)

	-- paste color on button click, updating frame components
	b:SetScript("OnClick", function(btn)
		local colors = btn.colors
		_G.ColorPickerFrame:SetColorRGB(colors.r, colors.g, colors.b)
		_G.ColorSwatch:SetColorTexture(colors.r, colors.g, colors.b)
		if _G.ColorPickerFrame.hasOpacity then
			if colors.a then
				_G.OpacitySliderFrame:SetValue(colors.a)
			end
		end
	end)

	-- position Color Swatch for copy color
	_G.ColorPPCopyColorSwatch:Point("BOTTOM", "ColorPPPaste", "TOP", 0, 10)

	-- move the Opacity Slider Frame to align with bottom of Copy ColorSwatch
	_G.OpacitySliderFrame:ClearAllPoints()
	_G.OpacitySliderFrame:Point("BOTTOM", "ColorPPDefault", "BOTTOM", 0, 0)
	_G.OpacitySliderFrame:Point("RIGHT", "ColorPickerFrame", "RIGHT", -35, 18)

	-- set up edit box frames and interior label and text areas
	local boxes = { "R", "G", "B", "H", "A" }
	for i = 1, #boxes do

		local rgb = boxes[i]
		local box = CreateFrame("EditBox", "ColorPPBox"..rgb, _G.ColorPickerFrame, "InputBoxTemplate")
		S:HandleEditBox(box)
		box:SetID(i)
		box:SetFrameStrata("DIALOG")
		box:SetAutoFocus(false)
		box:SetTextInsets(0,7,0,0)
		box:SetJustifyH("RIGHT")
		box:Height(24)

		if i == 4 then
			-- Hex entry box
			box:SetMaxLetters(6)
			box:Width(56)
			box:SetNumeric(false)
		else
			box:SetMaxLetters(3)
			box:Width(40)
			box:SetNumeric(true)
		end
		box:Point("TOP", "ColorPickerWheel", "BOTTOM", 0, -15)

		-- label
		local label = box:CreateFontString("ColorPPBoxLabel"..rgb, "ARTWORK", "GameFontNormalSmall")
		label:SetTextColor(1, 1, 1)
		label:Point("RIGHT", "ColorPPBox"..rgb, "LEFT", -5, 0)
		if i == 4 then
			label:SetText("#")
		else
			label:SetText(rgb)
		end

		-- set up scripts to handle event appropriately
		if i == 5 then
			box:SetScript("OnEscapePressed", function(eb) eb:ClearFocus() UpdateAlphaText() end)
			box:SetScript("OnEnterPressed", function(eb) eb:ClearFocus() UpdateAlphaText() end)
			box:SetScript("OnTextChanged", UpdateAlpha)
		else
			box:SetScript("OnEscapePressed", function(eb) eb:ClearFocus() UpdateColorTexts() end)
			box:SetScript("OnEnterPressed", function(eb) eb:ClearFocus() UpdateColorTexts() end)
			box:SetScript("OnTextChanged", UpdateColor)
		end

		box:SetScript("OnEditFocusGained", function(eb) eb:SetCursorPosition(0) eb:HighlightText() end)
		box:SetScript("OnEditFocusLost", function(eb) eb:HighlightText(0,0) end)
		box:SetScript("OnTextSet", function(eb) eb:ClearFocus() end)
		box:Show()
	end

	-- finish up with placement
	_G.ColorPPBoxA:Point("RIGHT", "OpacitySliderFrame", "RIGHT", 10, 0)
	_G.ColorPPBoxH:Point("RIGHT", "ColorPPDefault", "RIGHT", -10, 0)
	_G.ColorPPBoxB:Point("RIGHT", "ColorPPDefault", "LEFT", -40, 0)
	_G.ColorPPBoxG:Point("RIGHT", "ColorPPBoxB", "LEFT", -25, 0)
	_G.ColorPPBoxR:Point("RIGHT", "ColorPPBoxG", "LEFT", -25, 0)

	-- define the order of tab cursor movement
	_G.ColorPPBoxR:SetScript("OnTabPressed", function() _G.ColorPPBoxG:SetFocus() end)
	_G.ColorPPBoxG:SetScript("OnTabPressed", function() _G.ColorPPBoxB:SetFocus() end)
	_G.ColorPPBoxB:SetScript("OnTabPressed", function() _G.ColorPPBoxH:SetFocus() end)
	_G.ColorPPBoxA:SetScript("OnTabPressed", function() _G.ColorPPBoxR:SetFocus() end)

	-- make the color picker movable.
	local mover = CreateFrame('Frame', nil, _G.ColorPickerFrame)
	mover:Point('TOPLEFT', _G.ColorPickerFrame, 'TOP', -60, 0)
	mover:Point('BOTTOMRIGHT', _G.ColorPickerFrame, 'TOP', 60, -15)
	mover:EnableMouse(true)
	mover:SetScript('OnMouseDown', function() _G.ColorPickerFrame:StartMoving() end)
	mover:SetScript('OnMouseUp', function() _G.ColorPickerFrame:StopMovingOrSizing() end)
	_G.ColorPickerFrame:SetUserPlaced(true)
	_G.ColorPickerFrame:EnableKeyboard(false)
end
