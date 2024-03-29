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
local function alphaValue(num)
	return num and floor((num * 100) + .05) or 0
end

local function UpdateAlphaText(alpha)
	if not alpha then
		alpha = alphaValue(ColorPickerFrame:GetColorAlpha())
	end

	_G.ColorPPBoxA:SetText(alpha)
end

local function expandFromThree(r, g, b)
	return strjoin('',r,r,g,g,b,b)
end

local function extendToSix(str)
	for _=1, 6-strlen(str) do str=str..0 end
	return str
end

local function GetHexColor(box)
	local rgb, rgbSize = box:GetText(), box:GetNumLetters()
	if rgbSize == 3 then
		rgb = gsub(rgb, '(%x)(%x)(%x)$', expandFromThree)
	elseif rgbSize < 6 then
		rgb = gsub(rgb, '(.+)$', extendToSix)
	end

	local r, g, b = tonumber(strsub(rgb,0,2),16) or 0, tonumber(strsub(rgb,3,4),16) or 0, tonumber(strsub(rgb,5,6),16) or 0

	return r/255, g/255, b/255
end

local function UpdateColorTexts(r, g, b, box)
	if not (r and g and b) then
		r, g, b = _G.ColorPickerFrame:GetColorRGB()

		if box then
			if box == ColorPickerFrame.Content.HexBox then
				r, g, b = GetHexColor(box)
			else
				local num = box:GetNumber()
				if num > 255 then
					num = 255
				end

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

	ColorPickerFrame.Content.HexBox:SetText(format('%.2x%.2x%.2x', r, g, b))
	_G.ColorPPBoxR:SetText(r)
	_G.ColorPPBoxG:SetText(g)
	_G.ColorPPBoxB:SetText(b)
end

local function UpdateColor()
	local r, g, b = GetHexColor(ColorPickerFrame.Content.HexBox)
	ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
	ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(r, g, b)
end

local function ColorPPBoxA_SetFocus()
	_G.ColorPPBoxA:SetFocus()
end

local function ColorPPBoxR_SetFocus()
	_G.ColorPPBoxR:SetFocus()
end

local delayWait, delayFunc = 0.15
local function delayCall()
	if delayFunc then
		delayFunc()
		delayFunc = nil
	end
end

local last = { r = 0, g = 0, b = 0, a = 0 }
local function onAlphaValueChanged(_, value)
	local alpha = alphaValue(value)
	if last.a ~= alpha then
		last.a = alpha
	else -- alpha matched so we don't need to update
		return
	end

	UpdateAlphaText(alpha)

	if not _G.ColorPickerFrame:IsVisible() then
		delayCall()
	else
		local opacityFunc = ColorPickerFrame.opacityFunc
		if delayFunc and (delayFunc ~= opacityFunc) then
			delayFunc = opacityFunc
		elseif not delayFunc then
			delayFunc = opacityFunc
			E:Delay(delayWait, delayCall)
		end
	end
end

local function UpdateAlpha(tbox)
	local num = tbox:GetNumber()
	if num > 100 then
		tbox:SetText(100)
		num = 100
	end

	local value = num * 0.01
	ColorPickerFrame.Content.ColorPicker:SetColorAlpha(value)
	onAlphaValueChanged(nil, value)
end

local function onColorSelect(frame, r, g, b)
	if frame.noColorCallback then
		return -- prevent error from E:GrabColorPickerValues, better note in that function
	elseif r ~= last.r or g ~= last.g or b ~= last.b then
		last.r, last.g, last.b = r, g, b
	else -- colors match so we don't need to update, most likely mouse is held down
		return
	end

	ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(r, g, b)
	UpdateColorTexts(r, g, b)
	UpdateAlphaText()

	if not frame:IsVisible() then
		delayCall()
	elseif not delayFunc then
		delayFunc = ColorPickerFrame.swatchFunc

		if delayFunc then
			E:Delay(delayWait, delayCall)
		end
	end
end

function BL:EnhanceColorPicker()
	if E:IsAddOnEnabled('ColorPickerPlus') then return end

	ColorPickerFrame.Border:Hide()

	ColorPickerFrame.swatchFunc = E.noop -- REMOVE THIS LATER IF WE CAN? errors on Footer.OkayButton

	local Header = ColorPickerFrame.Header or _G.ColorPickerFrameHeader
	Header:StripTextures()
	Header:ClearAllPoints()
	Header:Point('TOP', ColorPickerFrame, 0, 5)

	ColorPickerFrame.Footer.CancelButton:ClearAllPoints()
	ColorPickerFrame.Footer.OkayButton:ClearAllPoints()
	ColorPickerFrame.Footer.CancelButton:Point('BOTTOMRIGHT', ColorPickerFrame, 'BOTTOMRIGHT', -6, 6)
	ColorPickerFrame.Footer.CancelButton:Point('BOTTOMLEFT', ColorPickerFrame, 'BOTTOM', 0, 6)
	ColorPickerFrame.Footer.OkayButton:Point('BOTTOMLEFT', ColorPickerFrame,'BOTTOMLEFT', 6, 6)
	ColorPickerFrame.Footer.OkayButton:Point('RIGHT', ColorPickerFrame.Footer.CancelButton,'LEFT', -4, 0)
	S:HandleButton(ColorPickerFrame.Footer.OkayButton)
	S:HandleButton(ColorPickerFrame.Footer.CancelButton)
	S:HandleEditBox(ColorPickerFrame.Content.HexBox)

	ColorPickerFrame.Content.HexBox.Hash:SetFontObject('ElvUIFontNormal')
	local HexText = ColorPickerFrame.Content.HexBox:GetRegions()
	HexText:SetFontObject('ElvUIFontNormal')

	-- Keep the colors updated
	ColorPickerFrame.Content.ColorPicker:SetScript('OnColorSelect', onColorSelect)

	ColorPickerFrame:HookScript('OnShow', function(frame)
		-- get color that will be replaced
		local r, g, b = frame:GetColorRGB()
		frame.Content.ColorSwatchOriginal:SetColorTexture(r, g, b)

		-- show/hide the alpha box
		if frame.hasOpacity then
			_G.ColorPPBoxA:Show()
			_G.ColorPPBoxLabelA:Show()
			frame.Content.HexBox:SetScript('OnTabPressed', ColorPPBoxA_SetFocus)
			UpdateAlphaText()
			frame:Width(405)
		else
			_G.ColorPPBoxA:Hide()
			_G.ColorPPBoxLabelA:Hide()
			frame.Content.HexBox:SetScript('OnTabPressed', ColorPPBoxR_SetFocus)
			frame:Width(345)
		end

		-- update the color boxes
		UpdateColorTexts(nil, nil, nil, ColorPickerFrame.Content.HexBox)
	end)

	-- add Color Swatch for the copied color
	local swatchWidth, swatchHeight = ColorPickerFrame.Content.ColorSwatchCurrent:GetSize()
	local copiedColor = ColorPickerFrame:CreateTexture('ColorPPCopyColorSwatch')
	copiedColor:SetColorTexture(0,0,0)
	copiedColor:Size(swatchWidth, swatchHeight)
	copiedColor:Hide()

	-- add copy button to the ColorPickerFrame
	local copyButton = CreateFrame('Button', 'ColorPPCopy', ColorPickerFrame, 'UIPanelButtonTemplate')
	copyButton:SetText(CALENDAR_COPY_EVENT)
	copyButton:Size(60, 22)
	S:HandleButton(copyButton)

	-- copy color into buffer on button click
	copyButton:SetScript('OnClick', function()
		-- copy current dialog colors into buffer
		colorBuffer.r, colorBuffer.g, colorBuffer.b = ColorPickerFrame:GetColorRGB()

		-- enable Paste button and display copied color into swatch
		_G.ColorPPPaste:Enable()
		_G.ColorPPCopyColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		_G.ColorPPCopyColorSwatch:Show()

		colorBuffer.a = (ColorPickerFrame.hasOpacity and ColorPickerFrame:GetColorAlpha()) or nil
	end)

	local alphaUpdater = CreateFrame('Frame', '$parent_AlphaUpdater', ColorPickerFrame)
	alphaUpdater:SetScript('OnUpdate', function()
		if ColorPickerFrame.Content.ColorPicker.Alpha:IsMouseOver() then
			onAlphaValueChanged(nil, ColorPickerFrame:GetColorAlpha())
		end
	end)

	-- class color button
	local classButton = CreateFrame('Button', 'ColorPPClass', ColorPickerFrame, 'UIPanelButtonTemplate')
	classButton:SetText(CLASS)
	classButton:Size(80, 22)
	S:HandleButton(classButton)

	classButton:SetScript('OnClick', function()
		local color = E:ClassColor(E.myclass, true)
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(color.r, color.g, color.b)
		ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(color.r, color.g, color.b)
	end)

	-- add paste button to the ColorPickerFrame
	local pasteButton = CreateFrame('Button', 'ColorPPPaste', ColorPickerFrame, 'UIPanelButtonTemplate')
	pasteButton:SetText(CALENDAR_PASTE_EVENT)
	pasteButton:Size(60, 22)
	pasteButton:Disable() -- enable when something has been copied
	S:HandleButton(pasteButton)

	-- paste color on button click, updating frame components
	pasteButton:SetScript('OnClick', function()
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)

		if ColorPickerFrame.hasOpacity and colorBuffer.a then -- color copied had an alpha value
			ColorPickerFrame.Content.ColorPicker:SetColorAlpha(colorBuffer.a)
			onAlphaValueChanged(nil, colorBuffer.a)
		end
	end)

	-- add defaults button to the ColorPickerFrame
	local defaultButton = CreateFrame('Button', 'ColorPPDefault', ColorPickerFrame, 'UIPanelButtonTemplate')
	defaultButton:SetText(DEFAULT)
	defaultButton:Size(80, 22)
	defaultButton:Disable() -- enable when something has been copied
	defaultButton:SetScript('OnHide', function(btn) if btn.colors then wipe(btn.colors) end end)
	defaultButton:SetScript('OnShow', function(btn) btn:SetEnabled(btn.colors) end)
	S:HandleButton(defaultButton)

	-- paste color on button click, updating frame components
	defaultButton:SetScript('OnClick', function(btn)
		local colors = btn.colors
		ColorPickerFrame.Content.ColorPicker:SetColorRGB(colors.r, colors.g, colors.b)
		ColorPickerFrame.Content.ColorSwatchCurrent:SetColorTexture(colors.r, colors.g, colors.b)

		if ColorPickerFrame.hasOpacity and colors.a then
			ColorPickerFrame.Content.ColorPicker:SetColorAlpha(colors.a)
			onAlphaValueChanged(nil, colorBuffer.a)
		end
	end)

	-- set up edit box frames and interior label and text areas
	for i, rgb in next, { 'R', 'G', 'B', 'A' } do
		local box = CreateFrame('EditBox', 'ColorPPBox'..rgb, ColorPickerFrame, 'InputBoxTemplate')
		box:Point('TOP', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOM', 0, -105)
		box:SetFrameStrata('DIALOG')
		box:SetAutoFocus(false)
		box:SetTextInsets(0,7,0,0)
		box:SetJustifyH('RIGHT')
		box:Height(24)
		box:SetID(i)

		S:HandleEditBox(box)
		box:SetFontObject('ElvUIFontNormal')

		box:SetMaxLetters(3)
		box:Width(40)
		box:SetNumeric(true)

		-- label
		local label = box:CreateFontString('ColorPPBoxLabel'..rgb, 'ARTWORK', 'ElvUIFontNormal')
		label:Point('RIGHT', 'ColorPPBox'..rgb, 'LEFT', -5, 0)
		label:SetText(rgb)
		label:SetTextColor(1, 1, 1)

		if i == 4 then
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
			-- set up scripts to handle event appropriately
			box:SetScript('OnKeyUp', function(eb, key)
				local copyPaste = IsControlKeyDown() and key == 'V'
				if key == 'BACKSPACE' or copyPaste or (strlen(key) == 1 and not IsModifierKeyDown()) then
					UpdateColorTexts(nil, nil, nil, eb)
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

	-- resync the alpha background
	ColorPickerFrame.Content.AlphaBackground:SetAllPoints(ColorPickerFrame.Content.ColorPicker.Alpha)

	-- move the Color Swatch
	ColorPickerFrame.Content.ColorSwatchCurrent:Point('TOPLEFT', ColorPickerFrame.Content, 'TOPRIGHT', -120, -37)
	ColorPickerFrame.Content.ColorSwatchOriginal:Point('TOPLEFT', ColorPickerFrame.Content.ColorSwatchCurrent, 'BOTTOMLEFT', 0, -2)

	-- position Color Swatch for copy color
	_G.ColorPPCopyColorSwatch:Point('BOTTOM', 'ColorPPPaste', 'TOP', 0, 5)

	-- right buttons
	copyButton:Point('TOPLEFT', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOMLEFT', -6, -5)
	pasteButton:Point('TOPLEFT', 'ColorPPCopy', 'TOPRIGHT', 2, 0)

	classButton:Point('TOP', 'ColorPPCopy', 'BOTTOMRIGHT', 0, -7)
	defaultButton:Point('TOPLEFT', 'ColorPPClass', 'BOTTOMLEFT', 0, -2)

	ColorPickerFrame.Content.HexBox:ClearAllPoints()
	ColorPickerFrame.Content.HexBox:Point('TOPRIGHT', 'ColorPPDefault', 'BOTTOMRIGHT', 0, -2)
	ColorPickerFrame.Content.HexBox:SetWidth(78)

	_G.ColorPPBoxA:Point('RIGHT', ColorPickerFrame.Content.HexBox, 'LEFT', -45, 0)

	_G.ColorPPBoxR:Point('LEFT', ColorPickerFrame.Content, 25, 0)
	_G.ColorPPBoxG:Point('LEFT', 'ColorPPBoxR', 65, 0)
	_G.ColorPPBoxB:Point('LEFT', 'ColorPPBoxG', 65, 0)

	-- define the order of tab cursor movement
	_G.ColorPPBoxR:SetScript('OnTabPressed', function() _G.ColorPPBoxG:SetFocus() end)
	_G.ColorPPBoxG:SetScript('OnTabPressed', function() _G.ColorPPBoxB:SetFocus() end)
	_G.ColorPPBoxB:SetScript('OnTabPressed', function() ColorPickerFrame.Content.HexBox:SetFocus() end)
	_G.ColorPPBoxA:SetScript('OnTabPressed', function() _G.ColorPPBoxR:SetFocus() end)

	-- make the color picker movable.
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
