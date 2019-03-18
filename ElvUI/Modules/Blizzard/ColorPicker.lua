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

local function UpdateAlphaText(displayValue)
	if not displayValue then
		displayValue = floor(((1 - _G.OpacitySliderFrame:GetValue()) * 100) +.05)
	end

	_G.ColorPPBoxA.noUpdateAlpha = true
	_G.ColorPPBoxA:SetText(displayValue)
end

local function UpdateAlpha(tbox)
	if tbox.noUpdateAlpha then
		tbox.noUpdateAlpha = nil
		return
	end

	local a = tbox:GetNumber()
	if a > 100 then
		a = 100
		_G.ColorPPBoxA.noUpdateAlpha = true
		_G.ColorPPBoxA:SetText(a)
	end
	a = 1 - (a / 100)

	_G.OpacitySliderFrame:SetValue(a)
end

local function UpdateColorTexts(r, g, b)
	if not (r and g and b) then
		r, g, b = _G.ColorPickerFrame:GetColorRGB()
	end

	r, g, b = r*255, g*255, b*255
	print('rgb', r, g, b)

	-- this will prevent the infinite loops
	_G.ColorPPBoxH.noUpdateColor = true
	_G.ColorPPBoxR.noUpdateColor = true
	_G.ColorPPBoxG.noUpdateColor = true
	_G.ColorPPBoxB.noUpdateColor = true

	_G.ColorPPBoxH:SetText(("%.2x%.2x%.2x"):format(r, g, b))
	_G.ColorPPBoxR:SetText(r)
	_G.ColorPPBoxG:SetText(g)
	_G.ColorPPBoxB:SetText(b)
end

local function UpdateColor(tbox, isUserInput)
	if tbox.noUpdateColor then
		tbox.noUpdateColor = nil
		return
	end

	local r, g, b = _G.ColorPickerFrame:GetColorRGB()
	print('first', r, g, b)

	if isUserInput then
		if tbox == _G.ColorPPBoxH then
			if tbox:GetNumLetters() == 6 then -- hex values
				local rgb = tbox:GetText()
				r, g, b = tonumber('0x'..strsub(rgb, 0, 2)), tonumber('0x'..strsub(rgb, 3, 4)), tonumber('0x'..strsub(rgb, 5, 6))
				print('hex', r, g, b)
				if not r then r = 0 else r = r/255 end
				if not g then g = 0 else g = g/255 end
				if not b then b = 0 else b = b/255 end
			else
				print('hex broken')
				return
			end
		else
			local c = tbox:GetNumber()
			print('getNumber', c, tbox:GetText())
			if tbox == _G.ColorPPBoxR then r = c;if not r then r = 0 else r = r/255 end end
			if tbox == _G.ColorPPBoxG then g = c;if not g then g = 0 else g = g/255 end end
			if tbox == _G.ColorPPBoxB then b = c;if not b then b = 0 else b = b/255 end end
		end
	end
	print('second', r, g, b, tbox:GetDebugName())

	-- This takes care of updating the hex entry when changing rgb fields and vice versa
	UpdateColorTexts(r, g, b)

	_G.ColorPickerFrame.noColorCallback = true
	_G.ColorPickerFrame:SetColorRGB(r, g, b)
	_G.ColorPickerFrame.noColorCallback = nil
	_G.ColorSwatch:SetColorTexture(r, g, b)
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
local function onColorSelect(frame, r, g, b)
	if frame.noColorCallback then return end

	_G.ColorSwatch:SetColorTexture(r, g, b)
	UpdateColorTexts(r, g, b)

	print('onColorSelect', r, g, b, frame:IsVisible(), _G.ColorPickerFrame.noColorCallback)

	if not frame:IsVisible() then
		delayCall()
	elseif not delayFunc then
		delayFunc = _G.ColorPickerFrame.func
		E:Delay(delayWait, delayCall)
	end
end

local function onValueChanged(frame, value)
	local displayValue = floor(((1 - value) * 100) + .05)
	if frame.lastSliderValue ~= displayValue then
		frame.lastSliderValue = displayValue

		UpdateAlphaText(displayValue)

		print('onValueChanged', _G.ColorPickerFrame:IsVisible(), _G.ColorPickerFrame.noColorCallback)

		if not _G.ColorPickerFrame:IsVisible() then
			delayCall()
		else
			local opacityFunc = _G.ColorPickerFrame.opacityFunc
			if delayFunc and (delayFunc ~= opacityFunc) then
				delayFunc = opacityFunc
			elseif not delayFunc then
				delayFunc = opacityFunc
				E:Delay(delayWait, delayCall)
			end
		end
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
			_G.ColorPPBoxH:SetScript('OnTabPressed', ColorPPBoxA_SetFocus)
			UpdateAlphaText()
			frame:Width(405)
		else
			_G.ColorPPBoxA:Hide()
			_G.ColorPPBoxLabelA:Hide()
			_G.ColorPPBoxH:SetScript('OnTabPressed', ColorPPBoxR_SetFocus)
			frame:Width(345)
		end

		--Memory Fix, Colorpicker will call the self.func() 100x per second, causing fps/memory issues,
		--We overwrite the OnColorSelect script and set a limit on how often we allow a call to self.func
		frame:SetScript('OnColorSelect', onColorSelect)
		_G.OpacitySliderFrame:SetScript('OnValueChanged', onValueChanged)
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
		box:SetFrameStrata("DIALOG")
		box:SetAutoFocus(false)
		box:SetTextInsets(0,7,0,0)
		box:SetJustifyH("RIGHT")
		box:Height(24)
		box:SetID(i)

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
