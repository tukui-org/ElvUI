------------------------------------------------------------------------------
-- Credit to Jaslm, most of this code is his from the addon ColorPickerPlus.
-- Modified and optimized by Simpy.
------------------------------------------------------------------------------
local E, L, V, P, G = unpack(ElvUI)
local BL = E:GetModule('Blizzard')
local S = E:GetModule('Skins')

local _G = _G
local format, next, wipe = format, next, wipe
local strlen, strjoin, gsub = strlen, strjoin, gsub
local tonumber, floor, strsub = tonumber, floor, strsub

local CreateFrame = CreateFrame
local IsControlKeyDown = IsControlKeyDown
local IsModifierKeyDown = IsModifierKeyDown

local ColorPickerFrame = ColorPickerFrame

local CALENDAR_COPY_EVENT, CALENDAR_PASTE_EVENT = CALENDAR_COPY_EVENT, CALENDAR_PASTE_EVENT
local CLASS, DEFAULT = CLASS, DEFAULT

local colorBuffer = {}
local function AlphaValue(num)
	return num and floor(((1 - num) * 100) + .05) or 0
end

local function UpdateAlphaText(alpha)
	if not alpha then alpha = AlphaValue(_G.OpacitySliderFrame:GetValue()) end

	_G.ColorPPBoxA:SetText(alpha)
end

local function ExpandFromThree(r, g, b)
	return strjoin('',r,r,g,g,b,b)
end

local function ExtendToSix(str)
	for _=1, 6-strlen(str) do str=str..0 end
	return str
end

local function GetHexColor(box)
	local rgb, rgbSize = box:GetText(), box:GetNumLetters()
	if rgbSize == 3 then
		rgb = gsub(rgb, '(%x)(%x)(%x)$', ExpandFromThree)
	elseif rgbSize < 6 then
		rgb = gsub(rgb, '(.+)$', ExtendToSix)
	end

	local r, g, b = tonumber(strsub(rgb,0,2),16) or 0, tonumber(strsub(rgb,3,4),16) or 0, tonumber(strsub(rgb,5,6),16) or 0

	return r/255, g/255, b/255
end

local function UpdateColorTexts(r, g, b, box)
	if not (r and g and b) then
		r, g, b = ColorPickerFrame:GetColorRGB()

		if box then
			if box == _G.ColorPPBoxH then
				r, g, b = GetHexColor(box)
			else
				local num = box:GetNumber()
				if num > 255 then num = 255 end
				local c = num/255
				if box == _G.ColorPPBoxR then
					r = c
				elseif box == _G.ColorPPBoxG then
					g = c
				elseif box == _G.ColorPPBoxB then
					b = c
				end
			end
		end
	end

	-- we want those /255 values
	r, g, b = E:Round(r*255), E:Round(g*255), E:Round(b*255)

	_G.ColorPPBoxH:SetText(format('%.2x%.2x%.2x', r, g, b))
	_G.ColorPPBoxR:SetText(r)
	_G.ColorPPBoxG:SetText(g)
	_G.ColorPPBoxB:SetText(b)
end

local function UpdateColor()
	local r, g, b = GetHexColor(_G.ColorPPBoxH)
	ColorPickerFrame:SetColorRGB(r, g, b)
	_G.ColorSwatch:SetColorTexture(r, g, b)
end

local function ColorPPBoxA_SetFocus()
	_G.ColorPPBoxA:SetFocus()
end

local function ColorPPBoxR_SetFocus()
	_G.ColorPPBoxR:SetFocus()
end

local delayWait, delayFunc = 0.15
local function DelayCall()
	if delayFunc then
		delayFunc()
		delayFunc = nil
	end
end

local last = {r = 0, g = 0, b = 0, a = 0}
local function OnAlphaValueChanged(_, value)
	local alpha = AlphaValue(value)
	if last.a ~= alpha then
		last.a = alpha
	else -- alpha matched so we don't need to update
		return
	end

	UpdateAlphaText(alpha)

	if not ColorPickerFrame:IsVisible() then
		DelayCall()
	else
		local opacityFunc = ColorPickerFrame.opacityFunc
		if delayFunc and (delayFunc ~= opacityFunc) then
			delayFunc = opacityFunc
		elseif not delayFunc then
			delayFunc = opacityFunc
			E:Delay(delayWait, DelayCall)
		end
	end
end

local function UpdateAlpha(tbox)
	local num = tbox:GetNumber()
	if num > 100 then
		tbox:SetText(100)
		num = 100
	end

	local value = 1 - (num * 0.01)
	_G.OpacitySliderFrame:SetValue(value)
	-- OnAlphaValueChanged(nil, value)
end

local function OnColorSelect(frame, r, g, b)
	if frame.noColorCallback then
		return -- prevent error from E:GrabColorPickerValues, better note in that function
	elseif r ~= last.r or g ~= last.g or b ~= last.b then
		last.r, last.g, last.b = r, g, b
	else -- colors match so we don't need to update, most likely mouse is held down
		return
	end

	_G.ColorSwatch:SetColorTexture(r, g, b)
	UpdateColorTexts(r, g, b)
	-- UpdateAlphaText()

	if not frame:IsVisible() then
		DelayCall()
	elseif not delayFunc then
		delayFunc = ColorPickerFrame.swatchFunc
		E:Delay(delayWait, DelayCall)
	end
end

function BL:EnhanceColorPicker()
	if E.OtherAddons.ColorPickerPlus then return end

	ColorPickerFrame.swatchFunc = E.noop -- REMOVE THIS LATER IF WE CAN? errors on Footer.OkayButton

	local Header = ColorPickerFrame.Header or _G.ColorPickerFrameHeader
	Header:StripTextures()
	Header:ClearAllPoints()
	Header:Point('TOP', ColorPickerFrame, 0, 5)

	_G.ColorPickerCancelButton:ClearAllPoints()
	_G.ColorPickerOkayButton:ClearAllPoints()
	_G.ColorPickerCancelButton:Point('BOTTOMRIGHT', ColorPickerFrame, 'BOTTOMRIGHT', -6, 6)
	_G.ColorPickerCancelButton:Point('BOTTOMLEFT', ColorPickerFrame, 'BOTTOM', 0, 6)
	_G.ColorPickerOkayButton:Point('BOTTOMLEFT', ColorPickerFrame,'BOTTOMLEFT', 6,6)
	_G.ColorPickerOkayButton:Point('RIGHT', _G.ColorPickerCancelButton,'LEFT', -4,0)
	S:HandleSliderFrame(_G.OpacitySliderFrame)
	S:HandleButton(_G.ColorPickerOkayButton)
	S:HandleButton(_G.ColorPickerCancelButton)

	-- Memory Fix, Colorpicker will call the self.func() 100x per second, causing fps/memory issues,
	-- We overwrite these two scripts and set a limit on how often we allow a call their update functions
	_G.OpacitySliderFrame:SetScript('OnValueChanged', OnAlphaValueChanged)

	-- Keep the colors updated
	ColorPickerFrame:SetScript('OnColorSelect', OnColorSelect)

	ColorPickerFrame:HookScript('OnShow', function(frame)
		-- get color that will be replaced
		local r, g, b = frame:GetColorRGB()
		_G.ColorPPOldColorSwatch:SetColorTexture(r,g,b)

		-- show/hide the alpha box
		if frame.hasOpacity then
			_G.ColorPPBoxA:Show()
			_G.ColorPPBoxLabelA:Show()
			_G.ColorPPBoxH:SetScript('OnTabPressed', ColorPPBoxA_SetFocus)
			UpdateAlphaText()
			frame:Width(405)
		else
			_G.ColorPPBoxA:Hide()
			_G.ColorPPBoxLabelA:Hide()
			_G.ColorPPBoxH:SetScript('OnTabPressed', ColorPPBoxR_SetFocus)
			frame:Width(345)
		end

		-- update the color boxes
		UpdateColorTexts(nil, nil, nil, _G.ColorPPBoxH)
	end)

	-- move the Color Swatch
	_G.ColorSwatch:ClearAllPoints()
	_G.ColorSwatch:Point('TOPLEFT', ColorPickerFrame, 'TOPLEFT', 215, -45)
	local swatchWidth, swatchHeight = _G.ColorSwatch:GetSize()

	-- add Color Swatch for original color
	local originalColor = ColorPickerFrame:CreateTexture('ColorPPOldColorSwatch')
	originalColor:Size(swatchWidth*0.75, swatchHeight*0.75)
	originalColor:SetColorTexture(0,0,0)
	-- OldColorSwatch to appear beneath ColorSwatch
	originalColor:SetDrawLayer('BORDER')
	originalColor:Point('BOTTOMLEFT', 'ColorSwatch', 'TOPRIGHT', -(swatchWidth*0.5), -(swatchHeight/3))

	-- add Color Swatch for the copied color
	local copiedColor = ColorPickerFrame:CreateTexture('ColorPPCopyColorSwatch')
	copiedColor:SetColorTexture(0,0,0)
	copiedColor:Size(swatchWidth, swatchHeight)
	copiedColor:Hide()

	-- add copy button to the ColorPickerFrame
	local copyButton = CreateFrame('Button', 'ColorPPCopy', ColorPickerFrame, 'UIPanelButtonTemplate')
	copyButton:SetText(CALENDAR_COPY_EVENT)
	copyButton:Size(60, 22)
	copyButton:Point('TOPLEFT', 'ColorSwatch', 'BOTTOMLEFT', 0, -5)
	S:HandleButton(copyButton)

	-- copy color into buffer on button click
	copyButton:SetScript('OnClick', function()
		-- copy current dialog colors into buffer
		colorBuffer.r, colorBuffer.g, colorBuffer.b = ColorPickerFrame:GetColorRGB()

		-- enable Paste button and display copied color into swatch
		_G.ColorPPPaste:Enable()
		_G.ColorPPCopyColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		_G.ColorPPCopyColorSwatch:Show()

		colorBuffer.a = (ColorPickerFrame.hasOpacity and _G.OpacitySliderFrame:GetValue()) or nil
	end)

	-- class color button
	local classButton = CreateFrame('Button', 'ColorPPClass', ColorPickerFrame, 'UIPanelButtonTemplate')
	classButton:SetText(CLASS)
	classButton:Size(80, 22)
	classButton:Point('TOP', 'ColorPPCopy', 'BOTTOMRIGHT', 0, -7)
	S:HandleButton(classButton)

	classButton:SetScript('OnClick', function()
		local color = E.myClassColor
		ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
		_G.ColorSwatch:SetColorTexture(color.r, color.g, color.b)
		if ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	-- add paste button to the ColorPickerFrame
	local pasteButton = CreateFrame('Button', 'ColorPPPaste', ColorPickerFrame, 'UIPanelButtonTemplate')
	pasteButton:SetText(CALENDAR_PASTE_EVENT)
	pasteButton:Size(60, 22)
	pasteButton:Point('TOPLEFT', 'ColorPPCopy', 'TOPRIGHT', 2, 0)
	pasteButton:Disable() -- enable when something has been copied
	S:HandleButton(pasteButton)

	-- paste color on button click, updating frame components
	pasteButton:SetScript('OnClick', function()
		ColorPickerFrame:SetColorRGB(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		_G.ColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		if ColorPickerFrame.hasOpacity then
			if colorBuffer.a then --color copied had an alpha value
				_G.OpacitySliderFrame:SetValue(colorBuffer.a)
			end
		end
	end)

	-- add defaults button to the ColorPickerFrame
	local defaultButton = CreateFrame('Button', 'ColorPPDefault', ColorPickerFrame, 'UIPanelButtonTemplate')
	defaultButton:SetText(DEFAULT)
	defaultButton:Size(80, 22)
	defaultButton:Point('TOPLEFT', 'ColorPPClass', 'BOTTOMLEFT', 0, -7)
	defaultButton:Disable() -- enable when something has been copied
	defaultButton:SetScript('OnHide', function(btn) if btn.colors then wipe(btn.colors) end end)
	defaultButton:SetScript('OnShow', function(btn) btn:SetEnabled(btn.colors) end)
	S:HandleButton(defaultButton)

	-- paste color on button click, updating frame components
	defaultButton:SetScript('OnClick', function(btn)
		local colors = btn.colors
		ColorPickerFrame:SetColorRGB(colors.r, colors.g, colors.b)
		_G.ColorSwatch:SetColorTexture(colors.r, colors.g, colors.b)
		if ColorPickerFrame.hasOpacity then
			if colors.a then
				_G.OpacitySliderFrame:SetValue(colors.a)
			end
		end
	end)

	-- position Color Swatch for copy color
	_G.ColorPPCopyColorSwatch:Point('BOTTOM', 'ColorPPPaste', 'TOP', 0, 10)

	-- move the Opacity Slider to align with bottom of Copy ColorSwatch
	_G.OpacitySliderFrame:ClearAllPoints()
	_G.OpacitySliderFrame:Point('BOTTOM', 'ColorPPDefault', 'BOTTOM', 0, 0)
	_G.OpacitySliderFrame:Point('RIGHT', 'ColorPickerFrame', 'RIGHT', -35, 18)

	-- set up edit box frames and interior label and text areas
	for i, rgb in next, { 'R', 'G', 'B', 'H', 'A' } do
		local box = CreateFrame('EditBox', 'ColorPPBox'..rgb, ColorPickerFrame, 'InputBoxTemplate')
		box:Point('TOP', 'ColorPickerWheel', 'BOTTOM', 0, -15)
		box:SetFrameStrata('DIALOG')
		box:SetAutoFocus(false)
		box:SetTextInsets(0,7,0,0)
		box:SetJustifyH('RIGHT')
		box:Height(24)
		box:SetID(i)

		S:HandleEditBox(box)
		box:SetFontObject('ElvUIFontNormal')

		-- hex entry box
		if i == 4 then
			box:SetMaxLetters(6)
			box:Width(65)
			box:SetNumeric(false)
		else
			box:SetMaxLetters(3)
			box:Width(40)
			box:SetNumeric(true)
		end

		-- label
		local label = box:CreateFontString('ColorPPBoxLabel'..rgb, 'ARTWORK', 'ElvUIFontNormal')
		label:Point('RIGHT', 'ColorPPBox'..rgb, 'LEFT', -5, 0)
		label:SetText(i == 4 and '#' or rgb)
		label:SetTextColor(1, 1, 1)

		-- set up scripts to handle event appropriately
		if i == 5 then
			box:SetScript('OnKeyUp', function(eb, key)
				local copyPaste = IsControlKeyDown() and key == 'V'
				if key == 'BACKSPACE' or copyPaste or (strlen(key) == 1 and not IsModifierKeyDown()) then
					UpdateAlpha(eb)
				elseif key == 'ENTER' or key == 'ESCAPE' then
					eb:ClearFocus()
					UpdateAlpha(eb)
				end
			end)
		else
			box:SetScript('OnKeyUp', function(eb, key)
				local copyPaste = IsControlKeyDown() and key == 'V'
				if key == 'BACKSPACE' or copyPaste or (strlen(key) == 1 and not IsModifierKeyDown()) then
					if i ~= 4 then UpdateColorTexts(nil, nil, nil, eb) end
					if i == 4 and eb:GetNumLetters() ~= 6 then return end
					UpdateColor()
				elseif key == 'ENTER' or key == 'ESCAPE' then
					eb:ClearFocus()
					UpdateColorTexts(nil, nil, nil, eb)
					UpdateColor()
				end
			end)
		end

		box:SetScript('OnEditFocusGained', function(eb) eb:SetCursorPosition(0) eb:HighlightText() end)
		box:SetScript('OnEditFocusLost', function(eb) eb:HighlightText(0,0) end)
		box:Show()
	end

	-- finish up with placement
	_G.ColorPPBoxA:Point('RIGHT', 'OpacitySliderFrame', 'RIGHT', 10, 0)
	_G.ColorPPBoxH:Point('RIGHT', 'ColorPPDefault', 'RIGHT', -10, 0)
	_G.ColorPPBoxB:Point('RIGHT', 'ColorPPDefault', 'LEFT', -40, 0)
	_G.ColorPPBoxG:Point('RIGHT', 'ColorPPBoxB', 'LEFT', -25, 0)
	_G.ColorPPBoxR:Point('RIGHT', 'ColorPPBoxG', 'LEFT', -25, 0)

	-- define the order of tab cursor movement
	_G.ColorPPBoxR:SetScript('OnTabPressed', function() _G.ColorPPBoxG:SetFocus() end)
	_G.ColorPPBoxG:SetScript('OnTabPressed', function() _G.ColorPPBoxB:SetFocus() end)
	_G.ColorPPBoxB:SetScript('OnTabPressed', function() _G.ColorPPBoxH:SetFocus() end)
	_G.ColorPPBoxA:SetScript('OnTabPressed', function() _G.ColorPPBoxR:SetFocus() end)

	-- make the color ColorPickerFrame movable.
	local mover = CreateFrame('Frame', nil, ColorPickerFrame)
	mover:Point('TOPLEFT', ColorPickerFrame, 'TOP', -60, 0)
	mover:Point('BOTTOMRIGHT', ColorPickerFrame, 'TOP', 60, -15)
	mover:SetScript('OnMouseDown', function() ColorPickerFrame:StartMoving() end)
	mover:SetScript('OnMouseUp', function() ColorPickerFrame:StopMovingOrSizing() end)
	mover:EnableMouse(true)

	-- make the frame a bit taller, to make room for edit boxes
	ColorPickerFrame:Height(ColorPickerFrame:GetHeight() + 40)

	-- skin the frame
	ColorPickerFrame:SetTemplate('Transparent')
	ColorPickerFrame:SetClampedToScreen(true)
	ColorPickerFrame:SetUserPlaced(true)
	ColorPickerFrame:EnableKeyboard(false)
end
