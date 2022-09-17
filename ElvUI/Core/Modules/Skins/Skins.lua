local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local LibStub = _G.LibStub

local _G = _G
local tinsert, xpcall, next, ipairs, pairs = tinsert, xpcall, next, ipairs, pairs
local unpack, assert, select, type, strfind = unpack, assert, select, type, strfind

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

S.allowBypass = {}
S.addonsToLoad = {}
S.nonAddonsToLoad = {}

S.Blizzard = {}
S.Blizzard.Regions = {
	'Left',
	'Middle',
	'Right',
	'Mid',
	'LeftDisabled',
	'MiddleDisabled',
	'RightDisabled',
	'TopLeft',
	'TopRight',
	'BottomLeft',
	'BottomRight',
	'TopMiddle',
	'MiddleLeft',
	'MiddleRight',
	'BottomMiddle',
	'MiddleMiddle',
	'TabSpacer',
	'TabSpacer1',
	'TabSpacer2',
	'_RightSeparator',
	'_LeftSeparator',
	'Cover',
	'Border',
	'Background',
	'TopTex',
	'TopLeftTex',
	'TopRightTex',
	'LeftTex',
	'BottomTex',
	'BottomLeftTex',
	'BottomRightTex',
	'RightTex',
	'MiddleTex',
	'Center'
}

-- Depends on the arrow texture to be up by default.
S.ArrowRotation = {
	up = 0,
	down = 3.14,
	left = 1.57,
	right = -1.57,
}

do
	local function HighlightOnEnter(button)
		local r, g, b = unpack(E.media.rgbvaluecolor)
		button.HighlightTexture:SetVertexColor(r, g, b, 0.50)
		button.HighlightTexture:Show()
	end

	local function HighlightOnLeave(button)
		button.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		button.HighlightTexture:Hide()
	end

	function S:HandleCategoriesButtons(button, strip)
		if button.isSkinned then return end

		if button.SetNormalTexture then button:SetNormalTexture('') end
		if button.SetHighlightTexture then button:SetHighlightTexture('') end
		if button.SetPushedTexture then button:SetPushedTexture('') end
		if button.SetDisabledTexture then button:SetDisabledTexture('') end

		if strip then button:StripTextures() end
		S:HandleBlizzardRegions(button)

		button.HighlightTexture = button:CreateTexture(nil, "BACKGROUND")
		button.HighlightTexture:SetBlendMode("BLEND")
		button.HighlightTexture:SetSize(button:GetSize())
		button.HighlightTexture:Point('CENTER', button, 0, 2)
		button.HighlightTexture:SetTexture(E.Media.Textures.Highlight)
		button.HighlightTexture:SetVertexColor(0, 0, 0, 0)
		button.HighlightTexture:Hide()

		button:HookScript('OnEnter', HighlightOnEnter)
		button:HookScript('OnLeave', HighlightOnLeave)

		button.isSkinned = true
	end
end

function S:HandleButtonHighlight(frame, r, g, b)
	if frame.SetHighlightTexture then
		frame:SetHighlightTexture('')
	end

	if not r then r = 0.9 end
	if not g then g = 0.9 end
	if not b then b = 0.9 end

	local leftGrad = frame:CreateTexture(nil, 'HIGHLIGHT')
	leftGrad:Size(frame:GetWidth() * 0.5, frame:GetHeight() * 0.95)
	leftGrad:Point('LEFT', frame, 'CENTER')
	leftGrad:SetTexture(E.media.blankTex)
	leftGrad:SetGradientAlpha('Horizontal', r, g, b, 0.35, r, g, b, 0)

	local rightGrad = frame:CreateTexture(nil, 'HIGHLIGHT')
	rightGrad:Size(frame:GetWidth() * 0.5, frame:GetHeight() * 0.95)
	rightGrad:Point('RIGHT', frame, 'CENTER')
	rightGrad:SetTexture(E.media.blankTex)
	rightGrad:SetGradientAlpha('Horizontal', r, g, b, 0, r, g, b, 0.35)
end

function S:HandlePointXY(frame, x, y)
	local a, b, c, d, e = frame:GetPoint()
	frame:SetPoint(a, b, c, x or d, y or e)
end

function S:HandleFrame(frame, setBackdrop, template, x1, y1, x2, y2)
	assert(frame, "doesn't exist!")

	local name = frame and frame.GetName and frame:GetName()
	local insetFrame = name and _G[name..'Inset'] or frame.Inset
	local portraitFrame = name and _G[name..'Portrait'] or frame.Portrait or frame.portrait
	local portraitFrameOverlay = name and _G[name..'PortraitOverlay'] or frame.PortraitOverlay
	local artFrameOverlay = name and _G[name..'ArtOverlayFrame'] or frame.ArtOverlayFrame

	frame:StripTextures()

	if portraitFrame then portraitFrame:SetAlpha(0) end
	if portraitFrameOverlay then portraitFrameOverlay:SetAlpha(0) end
	if artFrameOverlay then artFrameOverlay:SetAlpha(0) end

	if insetFrame then
		S:HandleInsetFrame(insetFrame)
	end

	if frame.CloseButton then
		S:HandleCloseButton(frame.CloseButton)
	end

	if setBackdrop then
		frame:CreateBackdrop(template or 'Transparent')
	else
		frame:SetTemplate(template or 'Transparent')
	end

	if frame.backdrop then
		frame.backdrop:Point('TOPLEFT', x1 or 0, y1 or 0)
		frame.backdrop:Point('BOTTOMRIGHT', x2 or 0, y2 or 0)
	end
end

function S:HandleInsetFrame(frame)
	assert(frame, 'doesnt exist!')

	if frame.InsetBorderTop then frame.InsetBorderTop:Hide() end
	if frame.InsetBorderTopLeft then frame.InsetBorderTopLeft:Hide() end
	if frame.InsetBorderTopRight then frame.InsetBorderTopRight:Hide() end

	if frame.InsetBorderBottom then frame.InsetBorderBottom:Hide() end
	if frame.InsetBorderBottomLeft then frame.InsetBorderBottomLeft:Hide() end
	if frame.InsetBorderBottomRight then frame.InsetBorderBottomRight:Hide() end

	if frame.InsetBorderLeft then frame.InsetBorderLeft:Hide() end
	if frame.InsetBorderRight then frame.InsetBorderRight:Hide() end

	if frame.Bg then frame.Bg:Hide() end
end

-- All frames that have a Portrait
function S:HandlePortraitFrame(frame, createBackdrop)
	assert(frame, 'doesnt exist!')

	local name = frame and frame.GetName and frame:GetName()
	local insetFrame = name and _G[name..'Inset'] or frame.Inset
	local portraitFrame = name and _G[name..'Portrait'] or frame.Portrait or frame.portrait
	local portraitFrameOverlay = name and _G[name..'PortraitOverlay'] or frame.PortraitOverlay
	local artFrameOverlay = name and _G[name..'ArtOverlayFrame'] or frame.ArtOverlayFrame

	frame:StripTextures()

	if portraitFrame then portraitFrame:SetAlpha(0) end
	if portraitFrameOverlay then portraitFrameOverlay:SetAlpha(0) end
	if artFrameOverlay then artFrameOverlay:SetAlpha(0) end

	if insetFrame then
		S:HandleInsetFrame(insetFrame)
	end

	if frame.CloseButton then
		S:HandleCloseButton(frame.CloseButton)
	end

	if createBackdrop then
		frame:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, true)
	else
		frame:SetTemplate('Transparent')
	end
end

function S:SetBackdropBorderColor(frame, script)
	if frame.backdrop then frame = frame.backdrop end
	if frame.SetBackdropBorderColor then
		frame:SetBackdropBorderColor(unpack(script == 'OnEnter' and E.media.rgbvaluecolor or E.media.bordercolor))
	end
end

function S:SetModifiedBackdrop()
	if self:IsEnabled() then
		S:SetBackdropBorderColor(self, 'OnEnter')
	end
end

function S:SetOriginalBackdrop()
	if self:IsEnabled() then
		S:SetBackdropBorderColor(self, 'OnLeave')
	end
end

function S:SetDisabledBackdrop()
	if self:IsMouseOver() then
		S:SetBackdropBorderColor(self, 'OnDisable')
	end
end

-- function to handle the recap button script
function S:UpdateRecapButton()
	-- when UpdateRecapButton runs and enables the button, it unsets OnEnter
	-- we need to reset it with ours. blizzard will replace it when the button
	-- is disabled. so, we don't have to worry about anything else.
	if self and self.button4 and self.button4:IsEnabled() then
		self.button4:SetScript('OnEnter', S.SetModifiedBackdrop)
		self.button4:SetScript('OnLeave', S.SetOriginalBackdrop)
	end
end

do -- We need to test this for the BGScore frame
	S.PVPHonorXPBarFrames = {}
	S.PVPHonorXPBarSkinned = false

	local function SetNextAvailable(XPBar)
		if not S.PVPHonorXPBarFrames[XPBar:GetParent():GetName()] then return end

		XPBar:StripTextures()

		if XPBar.Bar and not XPBar.Bar.backdrop then
			XPBar.Bar:CreateBackdrop()

			if XPBar.Bar.Background then
				XPBar.Bar.Background:SetInside(XPBar.Bar.backdrop)
			end
			if XPBar.Bar.Spark then
				XPBar.Bar.Spark:SetAlpha(0)
			end
			if XPBar.Bar.OverlayFrame and XPBar.Bar.OverlayFrame.Text then
				XPBar.Bar.OverlayFrame.Text:ClearAllPoints()
				XPBar.Bar.OverlayFrame.Text:Point('CENTER', XPBar.Bar)
			end
		end

		if XPBar.PrestigeReward and XPBar.PrestigeReward.Accept then
			XPBar.PrestigeReward.Accept:ClearAllPoints()
			XPBar.PrestigeReward.Accept:Point('TOP', XPBar.PrestigeReward, 'BOTTOM', 0, 0)
			if not XPBar.PrestigeReward.Accept.template then
				S:HandleButton(XPBar.PrestigeReward.Accept)
			end
		end

		if XPBar.NextAvailable then
			if XPBar.Bar then
				XPBar.NextAvailable:ClearAllPoints()
				XPBar.NextAvailable:Point('LEFT', XPBar.Bar, 'RIGHT', 0, -2)
			end

			if not XPBar.NextAvailable.backdrop then
				XPBar.NextAvailable:StripTextures()
				XPBar.NextAvailable:CreateBackdrop()

				if XPBar.NextAvailable.Icon then
					local x = E.PixelMode and 1 or 2
					XPBar.NextAvailable.backdrop:Point('TOPLEFT', XPBar.NextAvailable.Icon, -x, x)
					XPBar.NextAvailable.backdrop:Point('BOTTOMRIGHT', XPBar.NextAvailable.Icon, x, -x)
				end
			end

			if XPBar.NextAvailable.Icon then
				XPBar.NextAvailable.Icon:SetDrawLayer('ARTWORK')
				XPBar.NextAvailable.Icon:SetTexCoord(unpack(E.TexCoords))
			end
		end
	end

	function S:SkinPVPHonorXPBar(frame)
		S.PVPHonorXPBarFrames[frame] = true

		if S.PVPHonorXPBarSkinned then return end
		S.PVPHonorXPBarSkinned = true

		hooksecurefunc('PVPHonorXPBar_SetNextAvailable', SetNextAvailable)
	end
end

function S:StatusBarColorGradient(bar, value, max, backdrop)
	if not (bar and value) then return end

	local current = (not max and value) or (value and max and max ~= 0 and value/max)
	if not current then return end

	local r, g, b = E:ColorGradient(current, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
	bar:SetStatusBarColor(r, g, b)

	if not backdrop then
		backdrop = bar.backdrop
	end

	if backdrop then
		backdrop:SetBackdropColor(r * 0.25, g * 0.25, b * 0.25)
	end
end

-- DropDownMenu library support
function S:SkinLibDropDownMenu(prefix)
	if S[prefix..'_UIDropDownMenuSkinned'] then return end

	local key = (prefix == 'L4' or prefix == 'L3') and 'L' or prefix

	local bd = _G[key..'_DropDownList1Backdrop']
	local mbd = _G[key..'_DropDownList1MenuBackdrop']
	if bd and not bd.template then bd:SetTemplate('Transparent') end
	if mbd and not mbd.template then mbd:SetTemplate('Transparent') end

	S[prefix..'_UIDropDownMenuSkinned'] = true

	local lib = prefix == 'L4' and LibStub.libs['LibUIDropDownMenu-4.0']
	if (lib and lib.UIDropDownMenu_CreateFrames) or _G[key..'_UIDropDownMenu_CreateFrames'] then
		hooksecurefunc(lib or _G, (lib and '' or key..'_') .. 'UIDropDownMenu_CreateFrames', function()
			local lvls = _G[(key == 'Lib' and 'LIB' or key)..'_UIDROPDOWNMENU_MAXLEVELS']
			local ddbd = lvls and _G[key..'_DropDownList'..lvls..'Backdrop']
			local ddmbd = lvls and _G[key..'_DropDownList'..lvls..'MenuBackdrop']
			if ddbd and not ddbd.template then ddbd:SetTemplate('Transparent') end
			if ddmbd and not ddmbd.template then ddmbd:SetTemplate('Transparent') end
		end)
	end
end

function S:SkinTalentListButtons(frame)
	local name = frame and frame:GetName()
	if name then
		local bcl = _G[name..'BtnCornerLeft']
		local bcr = _G[name..'BtnCornerRight']
		local bbb = _G[name..'ButtonBottomBorder']
		if bcl then bcl:SetTexture() end
		if bcr then bcr:SetTexture() end
		if bbb then bbb:SetTexture() end
	end

	if frame.Inset then
		S:HandleInsetFrame(frame.Inset)

		frame.Inset:Point('TOPLEFT', 4, -60)
		frame.Inset:Point('BOTTOMRIGHT', -6, 26)
	end
end

do
	local function iconBorderColor(border, r, g, b, a)
		border:StripTextures()

		if border.customFunc then
			local br, bg, bb = unpack(E.media.bordercolor)
			border.customFunc(border, r, g, b, a, br, bg, bb)
		elseif border.customBackdrop then
			border.customBackdrop:SetBackdropBorderColor(r, g, b)
		end
	end

	local function iconBorderHide(border)
		local br, bg, bb = unpack(E.media.bordercolor)
		if border.customFunc then
			local r, g, b, a = border:GetVertexColor()
			border.customFunc(border, r, g, b, a, br, bg, bb)
		elseif border.customBackdrop then
			border.customBackdrop:SetBackdropBorderColor(br, bg, bb)
		end
	end

	function S:HandleIconBorder(border, backdrop, customFunc)
		if not backdrop then
			local parent = border:GetParent()
			backdrop = parent.backdrop or parent
		end

		border.customBackdrop = backdrop

		if not border.IconBorderHooked then
			border:StripTextures()

			hooksecurefunc(border, 'SetVertexColor', iconBorderColor)
			hooksecurefunc(border, 'Hide', iconBorderHide)

			border.IconBorderHooked = true
		end

		local r, g, b, a = border:GetVertexColor()
		if customFunc then
			border.customFunc = customFunc
			local br, bg, bb = unpack(E.media.bordercolor)
			customFunc(border, r, g, b, a, br, bg, bb)
		elseif r then
			backdrop:SetBackdropBorderColor(r, g, b, a)
		else
			local br, bg, bb = unpack(E.media.bordercolor)
			backdrop:SetBackdropBorderColor(br, bg, bb)
		end
	end
end

function S:HandleButton(button, strip, isDecline, noStyle, createBackdrop, template, noGlossTex, overrideTex, frameLevel, regionsKill, regionsZero)
	assert(button, 'doesnt exist!')

	if button.isSkinned then return end

	if button.SetNormalTexture and not overrideTex then button:SetNormalTexture('') end
	if button.SetHighlightTexture then button:SetHighlightTexture('') end
	if button.SetPushedTexture then button:SetPushedTexture('') end
	if button.SetDisabledTexture then button:SetDisabledTexture('') end

	if strip then button:StripTextures() end
	S:HandleBlizzardRegions(button, nil, regionsKill, regionsZero)

	if button.Icon then
		local Texture = button.Icon:GetTexture()
		if Texture and (type(Texture) == 'string' and strfind(Texture, [[Interface\ChatFrame\ChatFrameExpandArrow]])) then
			button.Icon:SetTexture(E.Media.Textures.ArrowUp)
			button.Icon:SetRotation(S.ArrowRotation.right)
			button.Icon:SetVertexColor(1, 1, 1)
		end
	end

	if isDecline and button.Icon then
		button.Icon:SetTexture(E.Media.Textures.Close)
	end

	if not noStyle then
		if createBackdrop then
			button:CreateBackdrop(template, not noGlossTex, nil, nil, nil, nil, nil, true, frameLevel)
		else
			button:SetTemplate(template, not noGlossTex)
		end

		button:HookScript('OnEnter', S.SetModifiedBackdrop)
		button:HookScript('OnLeave', S.SetOriginalBackdrop)
		button:HookScript('OnDisable', S.SetDisabledBackdrop)
	end

	button.isSkinned = true
end

do
	local function GetElement(frame, element, useParent)
		if useParent then frame = frame:GetParent() end

		local child = frame[element]
		if child then return child end

		local name = frame:GetName()
		if name then return _G[name..element] end
	end

	local function GetButton(frame, buttons)
		for _, data in ipairs(buttons) do
			if type(data) == 'string' then
				local found = GetElement(frame, data)
				if found then return found end
			else -- has useParent
				local found = GetElement(frame, data[1], data[2])
				if found then return found end
			end
		end
	end

	local function ThumbStatus(frame)
		if not frame.Thumb then
			return
		elseif not frame:IsEnabled() then
			frame.Thumb.backdrop:SetBackdropColor(0.3, 0.3, 0.3)
			return
		end

		local _, max = frame:GetMinMaxValues()
		if max == 0 then
			frame.Thumb.backdrop:SetBackdropColor(0.3, 0.3, 0.3)
		else
			frame.Thumb.backdrop:SetBackdropColor(unpack(E.media.rgbvaluecolor))
		end
	end

	local function ThumbWatcher(frame)
		hooksecurefunc(frame, 'Enable', ThumbStatus)
		hooksecurefunc(frame, 'Disable', ThumbStatus)
		hooksecurefunc(frame, 'SetEnabled', ThumbStatus)
		hooksecurefunc(frame, 'SetMinMaxValues', ThumbStatus)
		ThumbStatus(frame)
	end

	local upButtons = {'ScrollUpButton', 'UpButton', 'ScrollUp', {'scrollUp', true}, 'Back'}
	local downButtons = {'ScrollDownButton', 'DownButton', 'ScrollDown', {'scrollDown', true}, 'Forward'}
	local thumbButtons = {'ThumbTexture', 'thumbTexture', 'Thumb'}

	function S:HandleScrollBar(frame, thumbY, thumbX, template)
		assert(frame, 'doesnt exist!')

		if frame.backdrop then return end

		local upButton, downButton = GetButton(frame, upButtons), GetButton(frame, downButtons)
		local thumb = GetButton(frame, thumbButtons) or (frame.GetThumbTexture and frame:GetThumbTexture())

		frame:StripTextures()
		frame:CreateBackdrop(template or 'Transparent', nil, nil, nil, nil, nil, nil, nil, true)
		frame.backdrop:Point('TOPLEFT', upButton or frame, upButton and 'BOTTOMLEFT' or 'TOPLEFT', 0, 1)
		frame.backdrop:Point('BOTTOMRIGHT', downButton or frame, upButton and 'TOPRIGHT' or 'BOTTOMRIGHT', 0, -1)

		if frame.Background then frame.Background:Hide() end
		if frame.ScrollUpBorder then frame.ScrollUpBorder:Hide() end
		if frame.ScrollDownBorder then frame.ScrollDownBorder:Hide() end

		local frameLevel = frame:GetFrameLevel()
		if upButton then
			S:HandleNextPrevButton(upButton, 'up')
			upButton:SetFrameLevel(frameLevel + 2)
		end
		if downButton then
			S:HandleNextPrevButton(downButton, 'down')
			downButton:SetFrameLevel(frameLevel + 2)
		end
		if thumb and not thumb.backdrop then
			thumb:SetTexture()
			thumb:CreateBackdrop(nil, true, true, nil, nil, nil, nil, nil, frameLevel + 1)

			if not frame.Thumb then
				frame.Thumb = thumb
			end

			if thumb.backdrop then
				if not thumbX then thumbX = 0 end
				if not thumbY then thumbY = 0 end

				thumb.backdrop:Point('TOPLEFT', thumb, thumbX, -thumbY)
				thumb.backdrop:Point('BOTTOMRIGHT', thumb, -thumbX, thumbY)

				if frame.SetEnabled then
					ThumbWatcher(frame)
				else
					thumb.backdrop:SetBackdropColor(unpack(E.media.rgbvaluecolor))
				end
			end
		end
	end

	-- WoWTrimScrollBar
	local function ReskinScrollBarArrow(frame, direction)
		S:HandleNextPrevButton(frame, direction)
		frame.Overlay:SetAlpha(0)
		frame.Texture:Hide()
	end

	function S:HandleTrimScrollBar(frame)
		frame:StripTextures()
		frame.Background:Hide()

		local track = frame.Track
		track:SetTemplate('Transparent')
		track:ClearAllPoints()
		track:Point('TOPLEFT', 4, -21)
		track:Point('BOTTOMRIGHT', -3, 21)

		local thumb = track.Thumb
		thumb.Middle:Hide()
		thumb.Begin:Hide()
		thumb.End:Hide()

		thumb:SetTemplate(nil, true, true)
		thumb:SetBackdropColor(unpack(E.media.rgbvaluecolor))

		ReskinScrollBarArrow(frame.Back, 'up')
		ReskinScrollBarArrow(frame.Forward, 'down')
	end
end

do --Tab Regions
	local tabs = {
		'LeftDisabled',
		'MiddleDisabled',
		'RightDisabled',
		'Left',
		'Middle',
		'Right'
	}

	function S:HandleTab(tab, noBackdrop, template)
		if not tab or (tab.backdrop and not noBackdrop) then return end

		for _, object in pairs(tabs) do
			local textureName = tab:GetName() and _G[tab:GetName()..object]
			if textureName then
				textureName:SetTexture()
			elseif tab[object] then
				tab[object]:SetTexture()
			end
		end

		local highlightTex = tab.GetHighlightTexture and tab:GetHighlightTexture()
		if highlightTex then
			highlightTex:SetTexture()
		else
			tab:StripTextures()
		end

		if not noBackdrop then
			tab:CreateBackdrop(template)
			tab.backdrop:Point('TOPLEFT', 10, E.PixelMode and -1 or -3)
			tab.backdrop:Point('BOTTOMRIGHT', -10, 3)
		end
	end
end

function S:HandleRotateButton(btn)
	if btn.isSkinned then return end

	btn:SetTemplate()
	btn:Size(btn:GetWidth() - 14, btn:GetHeight() - 14)

	local normTex = btn:GetNormalTexture()
	local pushTex = btn:GetPushedTexture()
	local highlightTex = btn:GetHighlightTexture()

	normTex:SetInside()
	normTex:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	pushTex:SetAllPoints(normTex)
	pushTex:SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	highlightTex:SetAllPoints(normTex)
	highlightTex:SetColorTexture(1, 1, 1, 0.3)

	btn.isSkinned = true
end

do
	local btns = {MaximizeButton = 'up', MinimizeButton = 'down'}

	local function buttonOnEnter(btn)
		local r,g,b = unpack(E.media.rgbvaluecolor)
		btn:GetNormalTexture():SetVertexColor(r,g,b)
		btn:GetPushedTexture():SetVertexColor(r,g,b)
	end
	local function buttonOnLeave(btn)
		btn:GetNormalTexture():SetVertexColor(1, 1, 1)
		btn:GetPushedTexture():SetVertexColor(1, 1, 1)
	end

	function S:HandleMaxMinFrame(frame)
		assert(frame, 'does not exist.')

		if frame.isSkinned then return end

		frame:StripTextures(true)

		for name, direction in pairs(btns) do
			local button = frame[name]
			if button then
				button:Size(14, 14)
				button:ClearAllPoints()
				button:Point('CENTER')
				button:SetHitRectInsets(1, 1, 1, 1)
				button:GetHighlightTexture():Kill()

				button:SetScript('OnEnter', buttonOnEnter)
				button:SetScript('OnLeave', buttonOnLeave)

				button:SetNormalTexture(E.Media.Textures.ArrowUp)
				button:GetNormalTexture():SetRotation(S.ArrowRotation[direction])

				button:SetPushedTexture(E.Media.Textures.ArrowUp)
				button:GetPushedTexture():SetRotation(S.ArrowRotation[direction])
			end
		end

		frame.isSkinned = true
	end
end

function S:HandleBlizzardRegions(frame, name, kill, zero)
	if not name then name = frame.GetName and frame:GetName() end
	for _, area in pairs(S.Blizzard.Regions) do
		local object = (name and _G[name..area]) or frame[area]
		if object then
			if kill then
				object:Kill()
			elseif zero then
				object:SetAlpha(0)
			else
				object:Hide()
			end
		end
	end
end

function S:HandleEditBox(frame, template)
	assert(frame, 'doesnt exist!')

	if frame.backdrop then return end

	frame:CreateBackdrop(template, nil, nil, nil, nil, nil, nil, nil, true)
	S:HandleBlizzardRegions(frame)

	local EditBoxName = frame:GetName()
	if EditBoxName and (strfind(EditBoxName, 'Silver') or strfind(EditBoxName, 'Copper')) then
		frame.backdrop:Point('BOTTOMRIGHT', -12, -2)
	end
end

function S:HandleDropDownBox(frame, width, pos, template)
	assert(frame, 'doesnt exist!')

	local frameName = frame.GetName and frame:GetName()
	local button = frame.Button or frameName and (_G[frameName..'Button'] or _G[frameName..'_Button'])
	local text = frameName and _G[frameName..'Text'] or frame.Text
	local icon = frame.Icon

	if not width then
		width = 155
	end

	frame:Width(width)
	frame:StripTextures()
	frame:CreateBackdrop(template)
	frame:SetFrameLevel(frame:GetFrameLevel() + 2)
	frame.backdrop:Point('TOPLEFT', 20, -2)
	frame.backdrop:Point('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 2, -2)

	button:ClearAllPoints()

	if pos then
		button:Point('TOPRIGHT', frame.Right, -20, -21)
	else
		button:Point('RIGHT', frame, 'RIGHT', -10, 3)
	end

	button.SetPoint = E.noop
	S:HandleNextPrevButton(button, 'down')

	if text then
		text:ClearAllPoints()
		text:Point('RIGHT', button, 'LEFT', -2, 0)
	end

	if icon then
		icon:Point('LEFT', 23, 0)
	end
end

function S:HandleStatusBar(frame, color, template)
	frame:SetFrameLevel(frame:GetFrameLevel() + 1)
	frame:StripTextures()
	frame:CreateBackdrop(template or 'Transparent')
	frame:SetStatusBarTexture(E.media.normTex)
	frame:SetStatusBarColor(unpack(color or {.01, .39, .1}))
	E:RegisterStatusBar(frame)
end

do
	local check = [[Interface\Buttons\UI-CheckBox-Check]]
	local disabled = [[Interface\Buttons\UI-CheckBox-Check-Disabled]]

	local function checkNormalTexture(checkbox, texture) if texture ~= '' then checkbox:SetNormalTexture('') end end
	local function checkPushedTexture(checkbox, texture) if texture ~= '' then checkbox:SetPushedTexture('') end end
	local function checkHighlightTexture(checkbox, texture) if texture ~= '' then checkbox:SetHighlightTexture('') end end
	local function checkCheckedTexture(checkbox, texture)
		if texture == E.Media.Textures.Melli or texture == check then return end
		checkbox:SetCheckedTexture(E.private.skins.checkBoxSkin and E.Media.Textures.Melli or check)
	end
	local function checkOnDisable(checkbox)
		if not checkbox.SetDisabledTexture then return end
		checkbox:SetDisabledTexture(checkbox:GetChecked() and (E.private.skins.checkBoxSkin and E.Media.Textures.Melli or disabled) or '')
	end

	function S:HandleCheckBox(frame, noBackdrop, noReplaceTextures, frameLevel, template)
		assert(frame, 'does not exist.')

		if frame.isSkinned then return end

		frame:StripTextures()

		if noBackdrop then
			frame:Size(16)
		else
			frame:CreateBackdrop(template, nil, nil, nil, nil, nil, nil, nil, frameLevel)
			frame.backdrop:SetInside(nil, 4, 4)
		end

		if not noReplaceTextures then
			if frame.SetCheckedTexture then
				if E.private.skins.checkBoxSkin then
					frame:SetCheckedTexture(E.Media.Textures.Melli)

					local checkedTexture = frame:GetCheckedTexture()
					checkedTexture:SetVertexColor(1, .82, 0, 0.8)
					checkedTexture:SetInside(frame.backdrop)
				else
					frame:SetCheckedTexture(check)

					if noBackdrop then
						frame:GetCheckedTexture():SetInside(nil, -4, -4)
					end
				end
			end

			if frame.SetDisabledTexture then
				if E.private.skins.checkBoxSkin then
					frame:SetDisabledTexture(E.Media.Textures.Melli)

					local disabledTexture = frame:GetDisabledTexture()
					disabledTexture:SetVertexColor(.6, .6, .6, .8)
					disabledTexture:SetInside(frame.backdrop)
				else
					frame:SetDisabledTexture(disabled)

					if noBackdrop then
						frame:GetDisabledTexture():SetInside(nil, -4, -4)
					end
				end
			end

			frame:HookScript('OnDisable', checkOnDisable)

			hooksecurefunc(frame, 'SetNormalTexture', checkNormalTexture)
			hooksecurefunc(frame, 'SetPushedTexture', checkPushedTexture)
			hooksecurefunc(frame, 'SetCheckedTexture', checkCheckedTexture)
			hooksecurefunc(frame, 'SetHighlightTexture', checkHighlightTexture)
		end

		frame.isSkinned = true
	end
end

do
	local background = [[Interface\Minimap\UI-Minimap-Background]]
	local function buttonNormalTexture(frame, texture) if texture ~= '' then frame:SetNormalTexture('') end end
	local function buttonPushedTexture(frame, texture) if texture ~= '' then frame:SetPushedTexture('') end end
	local function buttonDisabledTexture(frame, texture) if texture ~= '' then frame:SetDisabledTexture('') end end
	local function buttonHighlightTexture(frame, texture) if texture ~= '' then frame:SetHighlightTexture('') end end

	function S:HandleRadioButton(Button)
		if Button.isSkinned then return end

		local InsideMask = Button:CreateMaskTexture()
		InsideMask:SetTexture(background, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		InsideMask:Size(10, 10)
		InsideMask:Point('CENTER')
		Button.InsideMask = InsideMask

		local OutsideMask = Button:CreateMaskTexture()
		OutsideMask:SetTexture(background, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		OutsideMask:Size(13, 13)
		OutsideMask:Point('CENTER')
		Button.OutsideMask = OutsideMask

		Button:SetCheckedTexture(E.media.normTex)
		Button:SetNormalTexture(E.media.normTex)
		Button:SetHighlightTexture(E.media.normTex)
		Button:SetDisabledTexture(E.media.normTex)

		local Check = Button:GetCheckedTexture()
		Check:SetVertexColor(unpack(E.media.rgbvaluecolor))
		Check:SetTexCoord(0, 1, 0, 1)
		Check:SetInside()
		Check:AddMaskTexture(InsideMask)

		local Highlight = Button:GetHighlightTexture()
		Highlight:SetTexCoord(0, 1, 0, 1)
		Highlight:SetVertexColor(1, 1, 1)
		Highlight:AddMaskTexture(InsideMask)

		local Normal = Button:GetNormalTexture()
		Normal:SetOutside()
		Normal:SetTexCoord(0, 1, 0, 1)
		Normal:SetVertexColor(unpack(E.media.bordercolor))
		Normal:AddMaskTexture(OutsideMask)

		local Disabled = Button:GetDisabledTexture()
		Disabled:SetVertexColor(.3, .3, .3)
		Disabled:AddMaskTexture(OutsideMask)

		hooksecurefunc(Button, 'SetNormalTexture', buttonNormalTexture)
		hooksecurefunc(Button, 'SetPushedTexture', buttonPushedTexture)
		hooksecurefunc(Button, 'SetDisabledTexture', buttonDisabledTexture)
		hooksecurefunc(Button, 'SetHighlightTexture', buttonHighlightTexture)

		Button.isSkinned = true
	end
end

function S:HandleIcon(icon, backdrop)
	icon:SetTexCoord(unpack(E.TexCoords))

	if backdrop and not icon.backdrop then
		icon:CreateBackdrop()
	end
end

function S:HandleItemButton(b, setInside)
	if b.isSkinned then return end

	local name = b:GetName()
	local icon = b.icon or b.Icon or b.IconTexture or b.iconTexture or (name and (_G[name..'IconTexture'] or _G[name..'Icon']))
	local texture = icon and icon.GetTexture and icon:GetTexture()

	b:StripTextures()
	b:CreateBackdrop(nil, true, nil, nil, nil, nil, nil, true)
	b:StyleButton()

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))

		if setInside then
			icon:SetInside(b)
		else
			b.backdrop:SetOutside(icon, 1, 1)
		end

		icon:SetParent(b.backdrop)

		if texture then
			icon:SetTexture(texture)
		end
	end

	b.isSkinned = true
end

do
	local closeOnEnter = function(btn) if btn.Texture then btn.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor)) end end
	local closeOnLeave = function(btn) if btn.Texture then btn.Texture:SetVertexColor(1, 1, 1) end end

	function S:HandleCloseButton(f, point, x, y)
		assert(f, 'doenst exist!')

		f:StripTextures()

		if not f.Texture then
			f.Texture = f:CreateTexture(nil, 'OVERLAY')
			f.Texture:Point('CENTER')
			f.Texture:SetTexture(E.Media.Textures.Close)
			f.Texture:Size(12, 12)
			f:HookScript('OnEnter', closeOnEnter)
			f:HookScript('OnLeave', closeOnLeave)
			f:SetHitRectInsets(6, 6, 7, 7)
		end

		if point then
			f:Point('TOPRIGHT', point, 'TOPRIGHT', x or 2, y or 2)
		end
	end

	function S:HandleNextPrevButton(btn, arrowDir, color, noBackdrop, stripTexts, frameLevel)
		if btn.isSkinned then return end

		if not arrowDir then
			arrowDir = 'down'

			local name = btn:GetDebugName()
			local ButtonName = name and name:lower()
			if ButtonName then
				if strfind(ButtonName, 'left') or strfind(ButtonName, 'prev') or strfind(ButtonName, 'decrement') or strfind(ButtonName, 'backward') or strfind(ButtonName, 'back') then
					arrowDir = 'left'
				elseif strfind(ButtonName, 'right') or strfind(ButtonName, 'next') or strfind(ButtonName, 'increment') or strfind(ButtonName, 'forward') then
					arrowDir = 'right'
				elseif strfind(ButtonName, 'scrollup') or strfind(ButtonName, 'upbutton') or strfind(ButtonName, 'top') or strfind(ButtonName, 'asc') or strfind(ButtonName, 'home') or strfind(ButtonName, 'maximize') then
					arrowDir = 'up'
				end
			end
		end

		btn:StripTextures()

		if btn.Texture then
			btn.Texture:SetAlpha(0)
		end

		if not noBackdrop then
			S:HandleButton(btn, nil, nil, nil, nil, nil, nil, nil, frameLevel)
		end

		if stripTexts then
			btn:StripTexts()
		end

		btn:SetNormalTexture(E.Media.Textures.ArrowUp)
		btn:SetPushedTexture(E.Media.Textures.ArrowUp)
		btn:SetDisabledTexture(E.Media.Textures.ArrowUp)

		local Normal, Disabled, Pushed = btn:GetNormalTexture(), btn:GetDisabledTexture(), btn:GetPushedTexture()

		if noBackdrop then
			btn:Size(20, 20)
			Disabled:SetVertexColor(.5, .5, .5)
			btn.Texture = Normal

			if not color then
				btn:HookScript('OnEnter', closeOnEnter)
				btn:HookScript('OnLeave', closeOnLeave)
			end
		else
			btn:Size(18, 18)
			Disabled:SetVertexColor(.3, .3, .3)
		end

		Normal:SetInside()
		Pushed:SetInside()
		Disabled:SetInside()

		Normal:SetTexCoord(0, 1, 0, 1)
		Pushed:SetTexCoord(0, 1, 0, 1)
		Disabled:SetTexCoord(0, 1, 0, 1)

		local rotation = S.ArrowRotation[arrowDir]
		if rotation then
			Normal:SetRotation(rotation)
			Pushed:SetRotation(rotation)
			Disabled:SetRotation(rotation)
		end

		if color then
			Normal:SetVertexColor(color.r, color.g, color.b)
		else
			Normal:SetVertexColor(1, 1, 1)
		end

		btn.isSkinned = true
	end
end

function S:HandleSliderFrame(frame, template, frameLevel)
	assert(frame, 'doesnt exist!')

	local orientation = frame:GetOrientation()
	local SIZE = 12

	if frame.SetBackdrop then
		frame:SetBackdrop()
	end

	frame:StripTextures()
	frame:SetThumbTexture(E.Media.Textures.Melli)

	if not frame.backdrop then
		frame:CreateBackdrop(template, nil, nil, nil, nil, nil, nil, true, frameLevel)
	end

	local thumb = frame:GetThumbTexture()
	thumb:SetVertexColor(1, .82, 0, 0.8)
	thumb:Size(SIZE-2,SIZE-2)

	if orientation == 'VERTICAL' then
		frame:Width(SIZE)
	else
		frame:Height(SIZE)

		for i=1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region and region:IsObjectType('FontString') then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if strfind(anchorPoint, 'BOTTOM') then
					region:Point(point, anchor, anchorPoint, x, y - 4)
				end
			end
		end
	end
end

-- TODO: Update the function for BFA/Shadowlands
function S:HandleFollowerAbilities(followerList)
	local followerTab = followerList and followerList.followerTab
	local abilityFrame = followerTab.AbilitiesFrame
	if not abilityFrame then return end

	local abilities = abilityFrame.Abilities
	if abilities then
		for i = 1, #abilities do
			local iconButton = abilities[i].IconButton
			local icon = iconButton and iconButton.Icon
			if icon then
				iconButton.Border:SetAlpha(0)
				S:HandleIcon(icon, true)
			end
		end
	end

	local equipment = abilityFrame.Equipment
	if equipment then
		for i = 1, #equipment do
			local equip = equipment[i]
			if equip then
				equip.Border:SetAlpha(0)
				equip.BG:SetAlpha(0)

				S:HandleIcon(equip.Icon, true)
				equip.Icon.backdrop:SetBackdropColor(1, 1, 1, .15)
			end
		end
	end

	local combatAllySpell = abilityFrame.CombatAllySpell
	if combatAllySpell then
		for i = 1, #combatAllySpell do
			local icon = combatAllySpell[i].iconTexture
			if icon then
				S:HandleIcon(icon, true)
			end
		end
	end

	local xpbar = followerTab.XPBar
	if xpbar and not xpbar.backdrop then
		xpbar:StripTextures()
		xpbar:SetStatusBarTexture(E.media.normTex)
		xpbar:CreateBackdrop('Transparent')
	end
end

function S:HandleShipFollowerPage(followerTab)
	local traits = followerTab.Traits
	for i = 1, #traits do
		local icon = traits[i].Portrait
		local border = traits[i].Border
		border:SetTexture() -- I think the default border looks nice, not sure if we want to replace that
		-- The landing page icons display inner borders
		if followerTab.isLandingPage then
			icon:SetTexCoord(unpack(E.TexCoords))
		end
	end

	local equipment = followerTab.EquipmentFrame.Equipment
	for i = 1, #equipment do
		local icon = equipment[i].Icon
		local border = equipment[i].Border
		border:SetAtlas('ShipMission_ShipFollower-TypeFrame') -- This border is ugly though, use the traits border instead
		-- The landing page icons display inner borders
		if followerTab.isLandingPage then
			icon:SetTexCoord(unpack(E.TexCoords))
		end
	end
end

local function UpdateFollowerQuality(self, followerInfo)
	if followerInfo then
		local color = E.QualityColors[followerInfo.quality or 1]
		self.Portrait.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	end
end

function S:HandleFollowerListOnUpdateDataFunc(Buttons, numButtons, offset, numFollowers)
	if not Buttons or (not numButtons or numButtons == 0) or not offset or not numFollowers then return end

	for i = 1, numButtons do
		local button = Buttons[i]
		if button then
			local index = offset + i -- adjust index
			if index <= numFollowers then
				button:SetTemplate(button.mode == 'CATEGORY' and 'NoBackdrop' or 'Transparent')

				if button.Category then
					button.Category:ClearAllPoints()
					button.Category:Point('TOP', button, 'TOP', 0, -4)
				end

				local fl = button.Follower
				if fl then
					if not fl.template then
						fl:SetTemplate('Transparent')
						fl.Name:SetWordWrap(false)
						fl.Selection:SetTexture()
						fl.AbilitiesBG:SetTexture()
						fl.BusyFrame:SetAllPoints()
						fl.BG:Hide()

						local hl = fl:GetHighlightTexture()
						hl:SetColorTexture(0.9, 0.9, 0.9, 0.25)
						hl:SetInside()
					end

					if fl.Counters then
						for y = 1, #fl.Counters do
							local counter = fl.Counters[y]
							if counter and not counter.template then
								counter:SetTemplate()

								if counter.Border then
									counter.Border:SetTexture()
								end

								if counter.Icon then
									counter.Icon:SetTexCoord(unpack(E.TexCoords))
									counter.Icon:SetInside()
								end
							end
						end
					end

					if fl.PortraitFrame then
						if not fl.PortraitFrameStyled then
							S:HandleGarrisonPortrait(fl.PortraitFrame)
							fl.PortraitFrame:ClearAllPoints()
							fl.PortraitFrame:Point('TOPLEFT', 3, -3)
							hooksecurefunc(fl.PortraitFrame, 'SetupPortrait', UpdateFollowerQuality)
							fl.PortraitFrameStyled = true
						end

						if fl.PortraitFrame.quality then
							local color = ITEM_QUALITY_COLORS[fl.PortraitFrame.quality]
							if color and fl.PortraitFrame.backdrop then
								fl.PortraitFrame.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
							end
						end
					end

					if fl.Selection then
						if fl.Selection:IsShown() then
							fl:SetBackdropColor(0.9, 0.8, 0.1, 0.25)
						else
							fl:SetBackdropColor(0, 0, 0, 0.5)
						end
					end
				end
			end
		end
	end
end

do
	S.FollowerListUpdateDataFrames = {}
	local function UpdateData(dataFrame)
		if not (dataFrame and dataFrame.listScroll and S.FollowerListUpdateDataFrames[dataFrame:GetName()]) then return end

		local list = dataFrame.followersList
		local buttons = dataFrame.listScroll.buttons
		local offset = _G.HybridScrollFrame_GetOffset(dataFrame.listScroll)

		S:HandleFollowerListOnUpdateDataFunc(buttons, buttons and #buttons, offset, list and #list)
	end

	function S:HandleFollowerListOnUpdateData(frame)
		if frame == 'GarrisonLandingPageFollowerList' and (not E.private.skins.blizzard.orderhall or not E.private.skins.blizzard.garrison) then
			return -- Only hook this frame if both Garrison and Orderhall skins are enabled because it's shared.
		end

		if S.FollowerListUpdateDataFrames[frame] then return end -- make sure we don't double hook `GarrisonLandingPageFollowerList`
		S.FollowerListUpdateDataFrames[frame] = true

		hooksecurefunc(_G[frame], 'UpdateData', UpdateData)
	end
end

-- Shared Template on LandingPage/Orderhall-/Garrison-FollowerList
local ReplacedRoleTex = {
	['Adventures-Tank'] = 'Soulbinds_Tree_Conduit_Icon_Protect',
	['Adventures-Healer'] = 'ui_adv_health',
	['Adventures-DPS'] = 'ui_adv_atk',
	['Adventures-DPS-Ranged'] = 'Soulbinds_Tree_Conduit_Icon_Utility',
}

local function HandleFollowerRole(roleIcon, atlas)
	local newAtlas = ReplacedRoleTex[atlas]
	if newAtlas then
		roleIcon:SetAtlas(newAtlas)
	end
end

function S:HandleGarrisonPortrait(portrait)
	if not portrait.Portrait then return end

	local level = portrait.Level or portrait.LevelText
	if level then
		level:ClearAllPoints()
		level:Point('BOTTOM', portrait, 0, 15)
		level:FontTemplate(nil, 14, 'OUTLINE')

		if portrait.LevelCircle then portrait.LevelCircle:Hide() end
		if portrait.LevelBorder then portrait.LevelBorder:SetScale(.0001) end
	end

	portrait.Portrait:CreateBackdrop('Transparent')

	if portrait.PortraitRing then
		portrait.PortraitRing:Hide()
		portrait.PortraitRingQuality:SetTexture('')
		portrait.PortraitRingCover:SetColorTexture(0, 0, 0)
		portrait.PortraitRingCover:SetAllPoints(portrait.Portrait.backdrop)
	end

	if portrait.Empty then
		portrait.Empty:SetColorTexture(0, 0, 0)
		portrait.Empty:SetAllPoints(portrait.Portrait)
	end

	if portrait.Highlight then portrait.Highlight:Hide() end
	if portrait.PuckBorder then portrait.PuckBorder:SetAlpha(0) end
	if portrait.TroopStackBorder1 then portrait.TroopStackBorder1:SetAlpha(0) end
	if portrait.TroopStackBorder2 then portrait.TroopStackBorder2:SetAlpha(0) end

	if portrait.HealthBar then
		portrait.HealthBar.Border:Hide()

		local roleIcon = portrait.HealthBar.RoleIcon
		roleIcon:ClearAllPoints()
		roleIcon:Point('CENTER', portrait.Portrait.backdrop, 'TOPRIGHT')
		hooksecurefunc(roleIcon, 'SetAtlas', HandleFollowerRole)

		local background = portrait.HealthBar.Background
		background:SetAlpha(0)
		background:SetInside(portrait.Portrait.backdrop, 2, 1) -- unsnap it
		background:Point('TOPLEFT', portrait.Portrait.backdrop, 'BOTTOMLEFT', 2, 7)
		portrait.HealthBar.Health:SetTexture(E.media.normTex)
	end
end

do
	local function selectionOffset(frame)
		local point, anchor, relativePoint, xOffset = frame:GetPoint()
		if xOffset <= 0 then
			local x = frame.BorderBox and 4 or 38 -- adjust values for wrath
			local y = frame.BorderBox and 0 or -10

			frame:ClearAllPoints()
			frame:Point(point, (frame == _G.MacroPopupFrame and _G.MacroFrame) or anchor, relativePoint, strfind(point, 'LEFT') and x or -x, y)
		end
	end

	function S:HandleIconSelectionFrame(frame, numIcons, buttonNameTemplate, frameNameOverride, dontOffset)
		assert(frame, 'HandleIconSelectionFrame: frame argument missing')
		assert(numIcons and type(numIcons) == 'number', 'HandleIconSelectionFrame: numIcons argument missing or not a number')
		assert(buttonNameTemplate and type(buttonNameTemplate) == 'string', 'HandleIconSelectionFrame: buttonNameTemplate argument missing or not a string')

		if frame.isSkinned then
			return
		elseif frameNameOverride ~= 'MacroPopup' then -- skip macros because it skins on show
			frame:Show() -- spawn the info so we can skin the buttons
			if frame.Update then frame:Update() end -- guild bank popup has update function
			frame:Hide() -- can hide it right away
		end

		if not dontOffset then -- place it off to the side of parent with correct offsets
			frame:HookScript('OnShow', selectionOffset)
		end

		local borderBox = frame.BorderBox or _G.BorderBox -- it's a sub frame only on retail, on wrath it's a global?
		local frameName = frameNameOverride or frame:GetName() --We need override in case Blizzard fucks up the naming (guild bank)
		local scrollFrame = frame.ScrollFrame or _G[frameName..'ScrollFrame']
		local editBox = frame.EditBox or _G[frameName..'EditBox']
		local cancel = frame.CancelButton or (borderBox and borderBox.CancelButton) or _G[frameName..'Cancel']
		local okay = frame.OkayButton or (borderBox and borderBox.OkayButton) or _G[frameName..'Okay']

		frame:StripTextures()
		frame:SetTemplate('Transparent')
		frame:Height(frame:GetHeight() + 10)

		if borderBox then
			borderBox:StripTextures()
		end

		cancel:ClearAllPoints()
		cancel:SetPoint('BOTTOMRIGHT', frame, -4, 4)
		S:HandleButton(cancel)

		okay:ClearAllPoints()
		okay:SetPoint('RIGHT', cancel, 'LEFT', -10, 0)
		S:HandleButton(okay)

		editBox:DisableDrawLayer('BACKGROUND') -- Removes textures around it
		S:HandleEditBox(editBox)

		scrollFrame:StripTextures()
		scrollFrame:Height(scrollFrame:GetHeight() + 10)
		S:HandleScrollBar(scrollFrame.ScrollBar)

		for i = 1, numIcons do
			local button = _G[buttonNameTemplate..i]
			if button then
				button:StripTextures()
				button:SetTemplate()
				button:StyleButton(nil, true)

				local icon, texture = button.Icon or _G[buttonNameTemplate..i..'Icon']
				if icon then
					icon:SetTexCoord(unpack(E.TexCoords))
					icon:SetInside(button)
					texture = icon:GetTexture()
				end

				if texture then
					icon:SetTexture(texture)
				end
			end
		end

		frame.isSkinned = true
	end
end

do -- Handle collapse
	local function UpdateCollapseTexture(button, texture)
		local tex = button:GetNormalTexture()
		if strfind(texture, 'Plus') or strfind(texture, 'Closed') then
			tex:SetTexture(E.Media.Textures.PlusButton)
		elseif strfind(texture, 'Minus') or strfind(texture, 'Open') then
			tex:SetTexture(E.Media.Textures.MinusButton)
		end
	end

	local function syncPushTexture(button, _, skip)
		if not skip then
			local normal = button:GetNormalTexture():GetTexture()
			button:SetPushedTexture(normal, true)
		end
	end

	function S:HandleCollapseTexture(button, syncPushed)
		if syncPushed then -- not needed always
			hooksecurefunc(button, 'SetPushedTexture', syncPushTexture)
			syncPushTexture(button)
		else
			button:SetPushedTexture('')
		end

		hooksecurefunc(button, 'SetNormalTexture', UpdateCollapseTexture)
		UpdateCollapseTexture(button, button:GetNormalTexture():GetTexture())
	end
end

-- World Map related Skinning functions used for WoW 8.0
function S:WorldMapMixin_AddOverlayFrame(frame, templateName)
	S[templateName](frame.overlayFrames[#frame.overlayFrames])
end

-- UIWidgets
function S:SkinIconAndTextWidget()
end

-- For now see the function below
function S:SkinCaptureBarWidget()
end

function S:SkinStatusBarWidget(widgetFrame)
	local bar = widgetFrame.Bar
	if not bar or bar.backdrop then return end

	bar:CreateBackdrop('Transparent')
	bar:SetScale(0.99) -- lol yes, this will keep it placed correctly for Simpy

	if bar.BGLeft then bar.BGLeft:SetAlpha(0) end
	if bar.BGRight then bar.BGRight:SetAlpha(0) end
	if bar.BGCenter then bar.BGCenter:SetAlpha(0) end
	if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
	if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
	if bar.BorderCenter then bar.BorderCenter:SetAlpha(0) end
end

do
	local function handleBar(bar)
		if not bar or bar.backdrop then return end

		bar:CreateBackdrop('Transparent')

		if bar.BG then bar.BG:SetAlpha(0) end
		if bar.Spark then bar.Spark:SetAlpha(0) end
		if bar.SparkGlow then bar.SparkGlow:SetAlpha(0) end
		if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
		if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
		if bar.BorderCenter then bar.BorderCenter:SetAlpha(0) end
		if bar.BorderGlow then bar.BorderGlow:SetAlpha(0) end
	end

	function S:SkinDoubleStatusBarWidget(widgetFrame)
		handleBar(widgetFrame.LeftBar)
		handleBar(widgetFrame.RightBar)
	end
end

function S:SkinIconTextAndBackgroundWidget()
end

function S:SkinDoubleIconAndTextWidget()
end

function S:SkinStackedResourceTrackerWidget()
end

function S:SkinIconTextAndCurrenciesWidget()
end

function S:SkinTextWithStateWidget(widgetFrame)
	local text = widgetFrame.Text
	if not text then return end

	text:SetTextColor(1, 1, 1)
end

function S:SkinHorizontalCurrenciesWidget()
end

function S:SkinBulletTextListWidget()
end

function S:SkinScenarioHeaderCurrenciesAndBackgroundWidget()
end

function S:SkinTextureAndTextWidget()
end

function S:SkinSpellDisplay(widgetFrame)
	local spell = widgetFrame.Spell
	if not spell then return end

	if spell.Border then
		spell.Border:Hide()
	end

	if spell.Text then
		spell.Text:SetTextColor(1, 1, 1)
	end

	if spell.Icon then
		S:HandleIcon(spell.Icon, true)
	end
end

function S:SkinDoubleStateIconRow()
end

function S:SkinTextureAndTextRowWidget()
end

function S:SkinZoneControl()
end

function S:SkinCaptureZone()
end

do
	local W = Enum.UIWidgetVisualizationType
	S.WidgetSkinningFuncs = {
		[W.IconAndText] = 'SkinIconAndTextWidget',
		[W.CaptureBar] = 'SkinCaptureBarWidget',
		[W.StatusBar] = 'SkinStatusBarWidget',
		[W.DoubleStatusBar] = 'SkinDoubleStatusBarWidget',
		[W.IconTextAndBackground] = 'SkinIconTextAndBackgroundWidget',
		[W.DoubleIconAndText] = 'SkinDoubleIconAndTextWidget',
		[W.StackedResourceTracker] = 'SkinStackedResourceTrackerWidget',
		[W.IconTextAndCurrencies] = 'SkinIconTextAndCurrenciesWidget',
		[W.TextWithState] = 'SkinTextWithStateWidget',
		[W.HorizontalCurrencies] = 'SkinHorizontalCurrenciesWidget',
		[W.BulletTextList] = 'SkinBulletTextListWidget',
		[W.ScenarioHeaderCurrenciesAndBackground] = 'SkinScenarioHeaderCurrenciesAndBackgroundWidget',
	}

	if E.Retail then
		S.WidgetSkinningFuncs[W.SpellDisplay] = 'SkinSpellDisplay'
		S.WidgetSkinningFuncs[W.TextureAndText] = 'SkinTextureAndTextWidget'
		S.WidgetSkinningFuncs[W.DoubleStateIconRow] = 'SkinDoubleStateIconRow'
		S.WidgetSkinningFuncs[W.TextureAndTextRow] = 'SkinTextureAndTextRowWidget'
		S.WidgetSkinningFuncs[W.ZoneControl] = 'SkinZoneControl'
		S.WidgetSkinningFuncs[W.CaptureZone] = 'SkinCaptureZone'
	end
end

function S:SkinWidgetContainer(widget)
	local typeFunc = S.WidgetSkinningFuncs[widget.widgetType]
	if typeFunc and S[typeFunc] then
		S[typeFunc](S, widget)
	end
end

function S:ADDON_LOADED(_, addonName)
	if not self.allowBypass[addonName] and not E.initialized then
		return
	end

	local object = self.addonsToLoad[addonName]
	if object then
		S:CallLoadedAddon(addonName, object)
	end
end

-- EXAMPLE:
--- S:AddCallbackForAddon('Details', 'MyAddon_Details', MyAddon.SkinDetails)
---- arg1: Addon name (same as the toc): MyAddon.toc (without extension)
---- arg2: Given name (try to use something that won't be used by someone else)
---- arg3: load function (preferably not-local)
-- this is used for loading skins that should be executed when the addon loads (including blizzard addons that load later).
-- please add a given name, non-given-name is specific for elvui core addon.
function S:AddCallbackForAddon(addonName, name, func, forceLoad, bypass, position) -- arg2: name is 'given name'; see example above.
	local load = (type(name) == 'function' and name) or (not func and (S[name] or S[addonName]))
	S:RegisterSkin(addonName, load or func, forceLoad, bypass, position)
end

-- nonAddonsToLoad:
--- this is used for loading skins when our skin init function executes.
--- please add a given name, non-given-name is specific for elvui core addon.
function S:AddCallback(name, func, position) -- arg1: name is 'given name'
	local load = (type(name) == 'function' and name) or (not func and S[name])
	S:RegisterSkin('ElvUI', load or func, nil, nil, position)
end

local function errorhandler(err)
	return _G.geterrorhandler()(err)
end

function S:RegisterSkin(addonName, func, forceLoad, bypass, position)
	if bypass then
		self.allowBypass[addonName] = true
	end

	if forceLoad then
		xpcall(func, errorhandler)
		self.addonsToLoad[addonName] = nil
	elseif addonName == 'ElvUI' then
		if position then
			tinsert(self.nonAddonsToLoad, position, func)
		else
			tinsert(self.nonAddonsToLoad, func)
		end
	else
		local addon = self.addonsToLoad[addonName]
		if not addon then
			self.addonsToLoad[addonName] = {}
			addon = self.addonsToLoad[addonName]
		end

		if position then
			tinsert(addon, position, func)
		else
			tinsert(addon, func)
		end
	end
end

function S:CallLoadedAddon(addonName, object)
	for _, func in next, object do
		xpcall(func, errorhandler)
	end

	self.addonsToLoad[addonName] = nil
end

function S:Initialize()
	self.Initialized = true
	self.db = E.private.skins

	for index, func in next, self.nonAddonsToLoad do
		xpcall(func, errorhandler)
		self.nonAddonsToLoad[index] = nil
	end

	for addonName, object in pairs(self.addonsToLoad) do
		local isLoaded, isFinished = IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			S:CallLoadedAddon(addonName, object)
		end
	end

	-- Early Skin Handling (populated before ElvUI is loaded from the Ace3 file)
	if E.private.skins.ace3Enable and S.EarlyAceWidgets then
		for _, n in next, S.EarlyAceWidgets do
			if n.SetLayout then
				S:Ace3_RegisterAsContainer(n)
			else
				S:Ace3_RegisterAsWidget(n)
			end
		end
		for _, n in next, S.EarlyAceTooltips do
			S:Ace3_SkinTooltip(LibStub(n, true))
		end
	end
	if S.EarlyDropdowns then
		for _, n in next, S.EarlyDropdowns do
			S:SkinLibDropDownMenu(n)
		end
	end

	if E.Retail then
		local frame = CreateFrame('Frame')
		frame:RegisterEvent('PLAYER_ENTERING_WORLD')
		frame:RegisterEvent('UPDATE_ALL_UI_WIDGETS')
		frame:SetScript('OnEvent', function()
			for _, widget in pairs(_G.UIWidgetTopCenterContainerFrame.widgetFrames) do
				S:SkinWidgetContainer(widget)
			end
		end)
	end
end

-- Keep this outside, it's used for skinning addons before ElvUI load
S:RegisterEvent('ADDON_LOADED')

E:RegisterModule(S:GetName())
