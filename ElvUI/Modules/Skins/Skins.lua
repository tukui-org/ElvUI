local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local tinsert, xpcall, next = tinsert, xpcall, next
local unpack, assert, pairs, ipairs, select, type, strfind = unpack, assert, pairs, ipairs, select, type, strfind

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
	'Center',
}

-- Depends on the arrow texture to be up by default.
S.ArrowRotation = {
	up = 0,
	down = 3.14,
	left = 1.57,
	right = -1.57,
}

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
function S:HandlePortraitFrame(frame, setBackdrop)
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

	if setBackdrop then
		frame:CreateBackdrop('Transparent')
		frame.backdrop:SetAllPoints()
	else
		frame:SetTemplate('Transparent')
	end
end

function S:SetModifiedBackdrop()
	if self:IsEnabled() then
		if self.backdrop then self = self.backdrop end
		self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end
end

function S:SetOriginalBackdrop()
	if self:IsEnabled() then
		if self.backdrop then self = self.backdrop end
		self:SetBackdropBorderColor(unpack(E.media.bordercolor))
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

-- We need to test this for the BGScore frame
S.PVPHonorXPBarFrames = {}
S.PVPHonorXPBarSkinned = false

function S:SkinPVPHonorXPBar(frame)
	S.PVPHonorXPBarFrames[frame] = true

	if S.PVPHonorXPBarSkinned then return end
	S.PVPHonorXPBarSkinned = true

	hooksecurefunc('PVPHonorXPBar_SetNextAvailable', function(XPBar)
		if not S.PVPHonorXPBarFrames[XPBar:GetParent():GetName()] then return end
		XPBar:StripTextures() --XPBar

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
				XPBar.Bar.OverlayFrame.Text:SetPoint('CENTER', XPBar.Bar)
			end
		end

		if XPBar.PrestigeReward and XPBar.PrestigeReward.Accept then
			XPBar.PrestigeReward.Accept:ClearAllPoints()
			XPBar.PrestigeReward.Accept:SetPoint('TOP', XPBar.PrestigeReward, 'BOTTOM', 0, 0)
			if not XPBar.PrestigeReward.Accept.template then
				S:HandleButton(XPBar.PrestigeReward.Accept)
			end
		end

		if XPBar.NextAvailable then
			if XPBar.Bar then
				XPBar.NextAvailable:ClearAllPoints()
				XPBar.NextAvailable:SetPoint('LEFT', XPBar.Bar, 'RIGHT', 0, -2)
			end

			if not XPBar.NextAvailable.backdrop then
				XPBar.NextAvailable:StripTextures()
				XPBar.NextAvailable:CreateBackdrop()
				if XPBar.NextAvailable.Icon then
					XPBar.NextAvailable.backdrop:SetPoint('TOPLEFT', XPBar.NextAvailable.Icon, -(E.PixelMode and 1 or 2), (E.PixelMode and 1 or 2))
					XPBar.NextAvailable.backdrop:SetPoint('BOTTOMRIGHT', XPBar.NextAvailable.Icon, (E.PixelMode and 1 or 2), -(E.PixelMode and 1 or 2))
				end
			end

			if XPBar.NextAvailable.Icon then
				XPBar.NextAvailable.Icon:SetDrawLayer('ARTWORK')
				XPBar.NextAvailable.Icon:SetTexCoord(unpack(E.TexCoords))
			end
		end
	end)
end

function S:StatusBarColorGradient(bar, value, max, backdrop)
	local current = (not max and value) or (value and max and max ~= 0 and value/max)
	if not (bar and current) then return end
	local r, g, b = E:ColorGradient(current, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
	local bg = backdrop or bar.backdrop
	if bg then bg:SetBackdropColor(r*0.25, g*0.25, b*0.25) end
	bar:SetStatusBarColor(r, g, b)
end

-- DropDownMenu library support
function S:SkinLibDropDownMenu(prefix)
	if _G[prefix..'_UIDropDownMenu_CreateFrames'] and not S[prefix..'_UIDropDownMenuSkinned'] then
		local bd = _G[prefix..'_DropDownList1Backdrop']
		local mbd = _G[prefix..'_DropDownList1MenuBackdrop']
		if bd and not bd.template then bd:SetTemplate('Transparent') end
		if mbd and not mbd.template then mbd:SetTemplate('Transparent') end

		S[prefix..'_UIDropDownMenuSkinned'] = true
		hooksecurefunc(prefix..'_UIDropDownMenu_CreateFrames', function()
			local lvls = _G[(prefix == 'Lib' and 'LIB' or prefix)..'_UIDROPDOWNMENU_MAXLEVELS'];
			local ddbd = lvls and _G[prefix..'_DropDownList'..lvls..'Backdrop'];
			local ddmbd = lvls and _G[prefix..'_DropDownList'..lvls..'MenuBackdrop'];
			if ddbd and not ddbd.template then ddbd:SetTemplate('Transparent') end
			if ddmbd and not ddmbd.template then ddmbd:SetTemplate('Transparent') end
		end)
	end
end

function S:SkinTalentListButtons(frame)
	local name = frame and frame.GetName and frame:GetName()
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

		frame.Inset:SetPoint('TOPLEFT', 4, -60)
		frame.Inset:SetPoint('BOTTOMRIGHT', -6, 26)
	end
end

function S:HandleButton(button, strip, isDeclineButton, useCreateBackdrop, noSetTemplate)
	assert(button, 'doesnt exist!')

	if button.isSkinned then return end

	if button.SetNormalTexture then button:SetNormalTexture('') end
	if button.SetHighlightTexture then button:SetHighlightTexture('') end
	if button.SetPushedTexture then button:SetPushedTexture('') end
	if button.SetDisabledTexture then button:SetDisabledTexture('') end

	if strip then button:StripTextures() end

	local buttonName = button.GetName and button:GetName()
	for _, region in pairs(S.Blizzard.Regions) do
		region = buttonName and _G[buttonName..region] or button[region]
		if region then
			region:SetAlpha(0)
		end
	end

	if button.Icon then
		local Texture = button.Icon:GetTexture()
		if Texture and (type(Texture) == 'string' and strfind(Texture, [[Interface\ChatFrame\ChatFrameExpandArrow]])) then
			button.Icon:SetTexture(E.Media.Textures.ArrowUp)
			button.Icon:SetRotation(S.ArrowRotation.right)
			button.Icon:SetVertexColor(1, 1, 1)
		end
	end

	if isDeclineButton then
		if button.Icon then
			button.Icon:SetTexture(E.Media.Textures.Close)
		end
	end

	if useCreateBackdrop then
		button:CreateBackdrop(nil, true)
	elseif not noSetTemplate then
		button:SetTemplate(nil, true)
	end

	button:HookScript('OnEnter', S.SetModifiedBackdrop)
	button:HookScript('OnLeave', S.SetOriginalBackdrop)

	button.isSkinned = true
end

do
	local function GrabScrollBarElement(frame, element)
		local FrameName = frame:GetName()
		return frame[element] or FrameName and (_G[FrameName..element] or strfind(FrameName, element)) or nil
	end

	function S:HandleScrollBar(frame, thumbTrimY, thumbTrimX)
		assert(frame, 'doesnt exist!')

		if frame.backdrop then return end
		local parent = frame:GetParent()
		local ScrollUpButton = GrabScrollBarElement(frame, 'ScrollUpButton') or GrabScrollBarElement(frame, 'UpButton') or GrabScrollBarElement(frame, 'ScrollUp') or GrabScrollBarElement(parent, 'scrollUp')
		local ScrollDownButton = GrabScrollBarElement(frame, 'ScrollDownButton') or GrabScrollBarElement(frame, 'DownButton') or GrabScrollBarElement(frame, 'ScrollDown') or GrabScrollBarElement(parent, 'scrollDown')
		local Thumb = GrabScrollBarElement(frame, 'ThumbTexture') or GrabScrollBarElement(frame, 'thumbTexture') or frame.GetThumbTexture and frame:GetThumbTexture()

		frame:StripTextures()
		frame:CreateBackdrop()
		frame.backdrop:SetPoint('TOPLEFT', ScrollUpButton or frame, ScrollUpButton and 'BOTTOMLEFT' or 'TOPLEFT', 0, 0)
		frame.backdrop:SetPoint('BOTTOMRIGHT', ScrollDownButton or frame, ScrollUpButton and 'TOPRIGHT' or 'BOTTOMRIGHT', 0, 0)
		frame.backdrop:SetFrameLevel(frame.backdrop:GetFrameLevel() + 1)

		for _, Button in pairs({ ScrollUpButton, ScrollDownButton }) do
			if Button then
				S:HandleNextPrevButton(Button)
			end
		end

		if Thumb and not Thumb.backdrop then
			Thumb:SetTexture()
			Thumb:CreateBackdrop(nil, true, true)
			if not thumbTrimY then thumbTrimY = 3 end
			if not thumbTrimX then thumbTrimX = 2 end
			Thumb.backdrop:SetPoint('TOPLEFT', Thumb, 'TOPLEFT', 2, -thumbTrimY)
			Thumb.backdrop:SetPoint('BOTTOMRIGHT', Thumb, 'BOTTOMRIGHT', -thumbTrimX, thumbTrimY)
			Thumb.backdrop:SetFrameLevel(Thumb.backdrop:GetFrameLevel() + 2)
			Thumb.backdrop:SetBackdropColor(0.6, 0.6, 0.6)

			frame.Thumb = Thumb
		end
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

	function S:HandleTab(tab, noBackdrop)
		if not tab or (tab.backdrop and not noBackdrop) then return end

		for _, object in pairs(tabs) do
			local tex = _G[tab:GetName()..object]
			if tex then
				tex:SetTexture()
			end
		end

		local highlightTex = tab.GetHighlightTexture and tab:GetHighlightTexture()
		if highlightTex then
			highlightTex:SetTexture()
		else
			tab:StripTextures()
		end

		if not noBackdrop then
			tab:CreateBackdrop()
			tab.backdrop:SetPoint('TOPLEFT', 10, E.PixelMode and -1 or -3)
			tab.backdrop:SetPoint('BOTTOMRIGHT', -10, 3)
		end
	end
end

function S:HandleRotateButton(btn)
	if btn.isSkinned then return end

	btn:SetTemplate()
	btn:SetSize(btn:GetWidth() - 14, btn:GetHeight() - 14)

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
	function S:HandleMaxMinFrame(frame)
		assert(frame, 'does not exist.')

		if frame.isSkinned then return end

		frame:StripTextures(true)

		for name, direction in pairs(btns) do
			local button = frame[name]
			if button then
				button:SetSize(14, 14)
				button:ClearAllPoints()
				button:SetPoint('CENTER')
				button:SetHitRectInsets(1, 1, 1, 1)
				button:GetHighlightTexture():Kill()

				button:SetScript('OnEnter', function(btn)
					local r,g,b = unpack(E.media.rgbvaluecolor)
					btn:GetNormalTexture():SetVertexColor(r,g,b)
					btn:GetPushedTexture():SetVertexColor(r,g,b)
				end)

				button:SetScript('OnLeave', function(btn)
					btn:GetNormalTexture():SetVertexColor(1, 1, 1)
					btn:GetPushedTexture():SetVertexColor(1, 1, 1)
				end)

				button:SetNormalTexture(E.Media.Textures.ArrowUp)
				button:GetNormalTexture():SetRotation(S.ArrowRotation[direction])

				button:SetPushedTexture(E.Media.Textures.ArrowUp)
				button:GetPushedTexture():SetRotation(S.ArrowRotation[direction])
			end
		end

		frame.isSkinned = true
	end
end

function S:HandleEditBox(frame)
	assert(frame, 'doesnt exist!')

	if frame.backdrop then return end

	local EditBoxName = frame.GetName and frame:GetName()
	for _, Region in pairs(S.Blizzard.Regions) do
		if EditBoxName and _G[EditBoxName..Region] then
			_G[EditBoxName..Region]:SetAlpha(0)
		end
		if frame[Region] then
			frame[Region]:SetAlpha(0)
		end
	end

	frame:CreateBackdrop()
	frame.backdrop:SetFrameLevel(frame:GetFrameLevel())

	if EditBoxName and (strfind(EditBoxName, 'Silver') or strfind(EditBoxName, 'Copper')) then
		frame.backdrop:SetPoint('BOTTOMRIGHT', -12, -2)
	end
end

function S:HandleDropDownBox(frame, width, pos)
	assert(frame, 'doesnt exist!')

	local frameName = frame.GetName and frame:GetName()
	local button = frame.Button or frameName and (_G[frameName..'Button'] or _G[frameName..'_Button'])
	local text = frameName and _G[frameName..'Text'] or frame.Text
	local icon = frame.Icon

	if not width then
		width = 155
	end

	frame:StripTextures()
	frame:SetWidth(width)

	frame:CreateBackdrop()
	frame:SetFrameLevel(frame:GetFrameLevel() + 2)
	frame.backdrop:SetPoint('TOPLEFT', 20, -2)
	frame.backdrop:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 2, -2)

	button:ClearAllPoints()

	if pos then
		button:SetPoint('TOPRIGHT', frame.Right, -20, -21)
	else
		button:SetPoint('RIGHT', frame, 'RIGHT', -10, 3)
	end

	button.SetPoint = E.noop
	S:HandleNextPrevButton(button)

	if text then
		text:ClearAllPoints()
		text:SetPoint('RIGHT', button, 'LEFT', -2, 0)
	end

	if icon then
		icon:SetPoint('LEFT', 23, 0)
	end
end

function S:HandleStatusBar(frame, color)
	frame:SetFrameLevel(frame:GetFrameLevel() + 1)
	frame:StripTextures()
	frame:CreateBackdrop('Transparent')
	frame:SetStatusBarTexture(E.media.normTex)
	frame:SetStatusBarColor(unpack(color or {.01, .39, .1}))
	E:RegisterStatusBar(frame)
end

do
	local check = [[Interface\Buttons\UI-CheckBox-Check]]
	local disabled = [[Interface\Buttons\UI-CheckBox-Check-Disabled]]
	function S:HandleCheckBox(frame, noBackdrop, noReplaceTextures, forceSaturation)
		assert(frame, 'does not exist.')

		if frame.isSkinned then return end

		frame:StripTextures()
		frame.forceSaturation = forceSaturation

		if noBackdrop then
			frame:SetTemplate()
			frame:SetSize(16, 16)
		else
			frame:CreateBackdrop()
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

			frame:HookScript('OnDisable', function(checkbox)
				if not checkbox.SetDisabledTexture then return; end
				if checkbox:GetChecked() then
					if E.private.skins.checkBoxSkin then
						checkbox:SetDisabledTexture(E.Media.Textures.Melli)
					else
						checkbox:SetDisabledTexture(disabled)
					end
				else
					checkbox:SetDisabledTexture('')
				end
			end)

			hooksecurefunc(frame, 'SetNormalTexture', function(checkbox, texPath)
				if texPath ~= '' then checkbox:SetNormalTexture('') end
			end)
			hooksecurefunc(frame, 'SetPushedTexture', function(checkbox, texPath)
				if texPath ~= '' then checkbox:SetPushedTexture('') end
			end)
			hooksecurefunc(frame, 'SetHighlightTexture', function(checkbox, texPath)
				if texPath ~= '' then checkbox:SetHighlightTexture('') end
			end)
			hooksecurefunc(frame, 'SetCheckedTexture', function(checkbox, texPath)
				if texPath == E.Media.Textures.Melli or texPath == check then return end
				if E.private.skins.checkBoxSkin then
					checkbox:SetCheckedTexture(E.Media.Textures.Melli)
				else
					checkbox:SetCheckedTexture(check)
				end
			end)
		end

		frame.isSkinned = true
	end
end

function S:HandleRadioButton(Button)
	if Button.isSkinned then return end

	local InsideMask = Button:CreateMaskTexture()
	InsideMask:SetTexture([[Interface\Minimap\UI-Minimap-Background]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	InsideMask:SetSize(10, 10)
	InsideMask:SetPoint('CENTER')

	Button.InsideMask = InsideMask

	local OutsideMask = Button:CreateMaskTexture()
	OutsideMask:SetTexture([[Interface\Minimap\UI-Minimap-Background]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	OutsideMask:SetSize(13, 13)
	OutsideMask:SetPoint('CENTER')

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

	hooksecurefunc(Button, 'SetNormalTexture', function(f, t) if t ~= '' then f:SetNormalTexture('') end end)
	hooksecurefunc(Button, 'SetPushedTexture', function(f, t) if t ~= '' then f:SetPushedTexture('') end end)
	hooksecurefunc(Button, 'SetHighlightTexture', function(f, t) if t ~= '' then f:SetHighlightTexture('') end end)
	hooksecurefunc(Button, 'SetDisabledTexture', function(f, t) if t ~= '' then f:SetDisabledTexture('') end end)

	Button.isSkinned = true
end

function S:HandleIcon(icon, backdrop)
	icon:SetTexCoord(unpack(E.TexCoords))

	if backdrop and not icon.backdrop then
		icon:CreateBackdrop()
	end
end

function S:HandleItemButton(b, shrinkIcon)
	if b.isSkinned then return; end

	local name = b:GetName()
	local icon = b.icon or b.Icon or b.IconTexture or b.iconTexture or (name and (_G[name..'IconTexture'] or _G[name..'Icon']))
	local texture = icon and icon.GetTexture and icon:GetTexture()

	b:StripTextures()
	b:CreateBackdrop(nil, true)
	b:StyleButton()

	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))

		-- create a backdrop around the icon
		if shrinkIcon then
			b.backdrop:SetAllPoints()
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

local handleCloseButtonOnEnter = function(btn) if btn.Texture then btn.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor)) end end
local handleCloseButtonOnLeave = function(btn) if btn.Texture then btn.Texture:SetVertexColor(1, 1, 1) end end

function S:HandleCloseButton(f, point, x, y)
	assert(f, 'doenst exist!')

	f:StripTextures()

	if not f.Texture then
		f.Texture = f:CreateTexture(nil, 'OVERLAY')
		f.Texture:SetPoint('CENTER')
		f.Texture:SetTexture(E.Media.Textures.Close)
		f.Texture:SetSize(12, 12)
		f:HookScript('OnEnter', handleCloseButtonOnEnter)
		f:HookScript('OnLeave', handleCloseButtonOnLeave)
		f:SetHitRectInsets(6, 6, 7, 7)
	end

	if point then
		f:SetPoint('TOPRIGHT', point, 'TOPRIGHT', x or 2, y or 2)
	end
end

function S:HandleSliderFrame(frame)
	assert(frame, 'doesnt exist!')

	local orientation = frame:GetOrientation()
	local SIZE = 12

	frame:StripTextures()
	frame:SetThumbTexture(E.Media.Textures.Melli)

	if not frame.backdrop then
		frame:CreateBackdrop()
		frame.backdrop:SetAllPoints()
	end

	local thumb = frame:GetThumbTexture()
	thumb:SetVertexColor(1, .82, 0, 0.8)
	thumb:SetSize(SIZE-2,SIZE-2)

	if orientation == 'VERTICAL' then
		frame:SetWidth(SIZE)
	else
		frame:SetHeight(SIZE)

		for i=1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region and region:IsObjectType('FontString') then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if strfind(anchorPoint, 'BOTTOM') then
					region:SetPoint(point, anchor, anchorPoint, x, y - 4)
				end
			end
		end
	end
end

-- TODO: Update the function for BFA
function S:HandleFollowerPage(follower, hasItems, hasEquipment)
	local followerTab = follower and follower.followerTab
	local abilityFrame = followerTab.AbilitiesFrame
	if not abilityFrame then return end

	local abilities = abilityFrame.Abilities
	if abilities then
		for i = 1, #abilities do
			local iconButton = abilities[i].IconButton
			local icon = iconButton and iconButton.Icon
			if icon and not icon.backdrop then
				S:HandleIcon(icon)
				icon:SetDrawLayer('BORDER', 0)
				if iconButton.Border then
					iconButton.Border:SetTexture()
				end
			end
		end
	end

	local combatAllySpells = abilityFrame.CombatAllySpell
	if combatAllySpells then
		for i = 1, #combatAllySpells do
			local icon = combatAllySpells[i].iconTexture
			if icon and not icon.backdrop then
				S:HandleIcon(icon)
			end
		end
	end

	if hasItems then
		local weapon = followerTab.ItemWeapon
		if weapon and not weapon.backdrop then
			S:HandleIcon(weapon.Icon)
			if weapon.Border then
				weapon.Border:SetTexture()
			end
		end

		local armor = followerTab.ItemArmor
		if armor and not armor.backdrop then
			S:HandleIcon(armor.Icon)
			if armor.Border then
				armor.Border:SetTexture()
			end
		end
	end

	local xpbar = followerTab.XPBar
	if xpbar and not xpbar.backdrop then
		xpbar:StripTextures()
		xpbar:SetStatusBarTexture(E.media.normTex)
		xpbar:CreateBackdrop('Transparent')
	end

	-- only OrderHall
	if hasEquipment then
		local equipment = abilityFrame.Equipment
		if equipment then
			for i = 1, #equipment do
				-- fix borders being off
				equipment[i]:SetScale(1)

				-- handle its styling
				if not equipment[i].template then
					equipment[i]:SetTemplate()
					equipment[i]:SetSize(48, 48)
					if equipment[i].BG then
						equipment[i].BG:SetTexture()
					end
					if equipment[i].Border then
						equipment[i].Border:SetTexture()
					end
					if equipment[i].Icon then
						equipment[i].Icon:SetTexCoord(unpack(E.TexCoords))
						equipment[i].Icon:SetInside(equipment[i])
					end
					if equipment[i].EquipGlow then
						equipment[i].EquipGlow:SetSize(78, 78)
					end
					if equipment[i].ValidSpellHighlight then
						equipment[i].ValidSpellHighlight:SetSize(78, 78)
					end
				end

				-- handle the placement slightly to move them apart a bit
				if equipment[i]:IsShown() then
					local point, anchor, secondaryPoint, _, y = equipment[i]:GetPoint();
					if anchor and abilityFrame.EquipmentSlotsLabel then
						local totalWidth = equipment[i]:GetWidth() * #equipment
						if anchor ~= abilityFrame.EquipmentSlotsLabel then
							equipment[i]:SetPoint(point, anchor, secondaryPoint, E.Border*4, y);
						elseif followerTab.isLandingPage then
							equipment[i]:SetPoint('TOPLEFT', abilityFrame.EquipmentSlotsLabel, 'BOTTOM', -totalWidth/2, 0);
						else
							equipment[i]:SetPoint('TOPLEFT', abilityFrame.EquipmentSlotsLabel, 'BOTTOM', -totalWidth/2, -20);
						end
					end
				end
			end
		end
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

function S:HandleFollowerListOnUpdateDataFunc(Buttons, numButtons, offset, numFollowers)
	if not Buttons or (not numButtons or numButtons == 0) or not offset or not numFollowers then return end
	for i = 1, numButtons do
		local button = Buttons[i]
		local index = offset + i -- adjust index

		if button then
			if (index <= numFollowers) and not button.template then
				button:SetTemplate()

				if button.Category then
					button.Category:ClearAllPoints()
					button.Category:SetPoint('TOP', button, 'TOP', 0, -4)
				end

				if button.Follower then
					button.Follower.Name:SetWordWrap(false)
					button.Follower.BG:Hide()
					button.Follower.Selection:SetTexture()
					button.Follower.AbilitiesBG:SetTexture()
					button.Follower.BusyFrame:SetAllPoints()

					local hl = button.Follower:GetHighlightTexture()
					hl:SetColorTexture(0.9, 0.8, 0.1, 0.3)
					hl:ClearAllPoints()
					hl:SetPoint('TOPLEFT', 1, -1)
					hl:SetPoint('BOTTOMRIGHT', -1, 1)

					if button.Follower.Counters then
						for y = 1, #button.Follower.Counters do
							local counter = button.Follower.Counters[y]
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

					if button.Follower.PortraitFrame and not button.Follower.PortraitFrameStyled then
						S:HandleGarrisonPortrait(button.Follower.PortraitFrame)
						button.Follower.PortraitFrame:ClearAllPoints()
						button.Follower.PortraitFrame:SetPoint('TOPLEFT', 3, -3)
						button.Follower.PortraitFrameStyled = true
					end
				end
			end

			if button.Follower then
				if button.Follower.Selection then
					if button.Follower.Selection:IsShown() then
						button.Follower:SetBackdropColor(0.9, 0.8, 0.1, 0.3)
					else
						button.Follower:SetBackdropColor(0, 0, 0, .25)
					end
				end

				if button.Follower.PortraitFrame and button.Follower.PortraitFrame.quality then
					local color = ITEM_QUALITY_COLORS[button.Follower.PortraitFrame.quality]
					if color and button.Follower.PortraitFrame.backdrop then
						button.Follower.PortraitFrame.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
					end
				end
			end
		end
	end
end

S.FollowerListUpdateDataFrames = {}
function S:HandleFollowerListOnUpdateData(frame)
	if (frame == 'GarrisonLandingPageFollowerList') and (E.private.skins.blizzard.orderhall ~= true or E.private.skins.blizzard.garrison ~= true) then
		return -- Only hook this frame if both Garrison and Orderhall skins are enabled because it's shared.
	end

	if S.FollowerListUpdateDataFrames[frame] ~= nil then return end -- make sure we don't double hook `GarrisonLandingPageFollowerList`
	S.FollowerListUpdateDataFrames[frame] = 0 -- use this variable to reduce calls to HandleFollowerListOnUpdateDataFunc

	local FollowerListUpdateDataLastOffset = nil
	hooksecurefunc(_G[frame], 'UpdateData', function(dataFrame)
		if not S.FollowerListUpdateDataFrames[frame] or (not dataFrame or not dataFrame.listScroll) then return end
		local offset = _G.HybridScrollFrame_GetOffset(dataFrame.listScroll)
		local Buttons = dataFrame.listScroll.buttons
		local followersList = dataFrame.followersList

		-- store the offset so we can bypass the updateData delay
		if FollowerListUpdateDataLastOffset ~= offset then
			FollowerListUpdateDataLastOffset = offset
		else -- this will delay the function call until every other call
			S.FollowerListUpdateDataFrames[frame] = S.FollowerListUpdateDataFrames[frame] + 1
			-- this is mainly to prevent two calls when you add or remove a follower to a mission
			if S.FollowerListUpdateDataFrames[frame] < 2 then return end
		end

		S.FollowerListUpdateDataFrames[frame] = 0 -- back to zero because we call it
		S:HandleFollowerListOnUpdateDataFunc(Buttons, Buttons and #Buttons, offset, followersList and #followersList)
	end)
end

-- Shared Template on LandingPage/Orderhall-/Garrison-FollowerList
function S:HandleGarrisonPortrait(portrait)
	if not portrait.Portrait then return end

	local size = portrait.Portrait:GetSize() + 2
	portrait:SetSize(size, size)

	portrait.Portrait:SetTexCoord(unpack(E.TexCoords))
	portrait.Portrait:ClearAllPoints()
	portrait.Portrait:SetPoint('TOPLEFT', 1, -1)

	portrait.PortraitRing:Hide()
	portrait.PortraitRingQuality:SetTexture()
	portrait.PortraitRingCover:SetTexture()
	portrait.LevelBorder:SetAlpha(0)

	portrait.Level:ClearAllPoints()
	portrait.Level:SetPoint('BOTTOM')
	portrait.Level:FontTemplate(nil, 12, 'OUTLINE')

	if not portrait.backdrop then
		portrait:CreateBackdrop()
		portrait.backdrop:SetPoint('TOPLEFT', portrait, 'TOPLEFT', -1, 1)
		portrait.backdrop:SetPoint('BOTTOMRIGHT', portrait, 'BOTTOMRIGHT', 1, -1)
		portrait.backdrop:SetFrameLevel(portrait:GetFrameLevel())
	end
end

-- Interface\SharedXML\SharedUIPanelTemplatex.xml - line 780
function S:HandleTooltipBorderedFrame(frame)
	assert(frame, 'doesnt exist!')

	if frame.BorderTopLeft then frame.BorderTopLeft:Hide() end
	if frame.BorderTopRight then frame.BorderTopRight:Hide() end

	if frame.BorderBottomLeft then frame.BorderBottomLeft:Hide() end
	if frame.BorderBottomRight then frame.BorderBottomRight:Hide() end

	if frame.BorderTop then frame.BorderTop:Hide() end
	if frame.BorderBottom then frame.BorderBottom:Hide() end
	if frame.BorderLeft then frame.BorderLeft:Hide() end
	if frame.BorderRight then frame.BorderRight:Hide() end

	if frame.Background then frame.Background:Hide() end

	frame:SetTemplate('Transparent')
end

function S:HandleIconSelectionFrame(frame, numIcons, buttonNameTemplate, frameNameOverride)
	assert(frame, 'HandleIconSelectionFrame: frame argument missing')
	assert(numIcons and type(numIcons) == 'number', 'HandleIconSelectionFrame: numIcons argument missing or not a number')
	assert(buttonNameTemplate and type(buttonNameTemplate) == 'string', 'HandleIconSelectionFrame: buttonNameTemplate argument missing or not a string')

	local frameName = frameNameOverride or frame:GetName() --We need override in case Blizzard fucks up the naming (guild bank)
	local scrollFrame = _G[frameName..'ScrollFrame']
	local editBox = _G[frameName..'EditBox']

	frame:StripTextures()
	frame.BorderBox:StripTextures()
	scrollFrame:StripTextures()
	editBox:DisableDrawLayer('BACKGROUND') -- Removes textures around it

	frame:SetTemplate('Transparent')
	frame:SetHeight(frame:GetHeight() + 10)
	scrollFrame:SetHeight(scrollFrame:GetHeight() + 10)

	for i = 1, numIcons do
		local button = _G[buttonNameTemplate..i]
		if button then
			button:StripTextures()
			button:SetTemplate()
			button:StyleButton(true)

			local icon = _G[buttonNameTemplate..i..'Icon']
			if icon then
				icon:SetTexCoord(unpack(E.TexCoords))
				icon:SetPoint('TOPLEFT', 1, -1)
				icon:SetPoint('BOTTOMRIGHT', -1, 1)
			end
		end
	end
end

function S:HandleNextPrevButton(btn, arrowDir, color, noBackdrop, stripTexts)
	if btn.isSkinned then return end

	if not arrowDir then
		arrowDir = 'down'
		local name = btn:GetDebugName()
		local ButtonName = name and name:lower()
		if ButtonName then
			if (strfind(ButtonName, 'left') or strfind(ButtonName, 'prev') or strfind(ButtonName, 'decrement') or strfind(ButtonName, 'backward') or strfind(ButtonName, 'back')) then
				arrowDir = 'left'
			elseif (strfind(ButtonName, 'right') or strfind(ButtonName, 'next') or strfind(ButtonName, 'increment') or strfind(ButtonName, 'forward')) then
				arrowDir = 'right'
			elseif (strfind(ButtonName, 'scrollup') or strfind(ButtonName, 'upbutton') or strfind(ButtonName, 'top') or strfind(ButtonName, 'asc') or strfind(ButtonName, 'home') or strfind(ButtonName, 'maximize')) then
				arrowDir = 'up'
			end
		end
	end

	btn:StripTextures()
	if not noBackdrop then
		S:HandleButton(btn)
	end

	if stripTexts then
		btn:StripTexts()
	end

	btn:SetNormalTexture(E.Media.Textures.ArrowUp)
	btn:SetPushedTexture(E.Media.Textures.ArrowUp)
	btn:SetDisabledTexture(E.Media.Textures.ArrowUp)

	local Normal, Disabled, Pushed = btn:GetNormalTexture(), btn:GetDisabledTexture(), btn:GetPushedTexture()

	if noBackdrop then
		btn:SetSize(20, 20)
		Disabled:SetVertexColor(.5, .5, .5)
		btn.Texture = Normal
		btn:HookScript('OnEnter', handleCloseButtonOnEnter)
		btn:HookScript('OnLeave', handleCloseButtonOnLeave)
	else
		btn:SetSize(18, 18)
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
	if bar and not bar.IsSkinned then
		-- Hide StatusBar textures
		if bar.BorderLeft then bar.BorderLeft:Hide() end
		if bar.BorderRight then bar.BorderRight:Hide() end
		if bar.BorderCenter then bar.BorderCenter:Hide() end
		if bar.BGLeft then bar.BGLeft:Hide() end
		if bar.BGRight then bar.BGRight:Hide() end
		if bar.BGCenter then bar.BGCenter:Hide() end

		if not bar.backdrop then
			bar:CreateBackdrop()
		end

		bar.backdrop:SetPoint('TOPLEFT', -2, 2)
		bar.backdrop:SetPoint('BOTTOMRIGHT', 2, -2)

		bar.IsSkinned = true
	end
end

-- For now see the function below
function S:SkinDoubleStatusBarWidget()
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

	if text then
		text:SetTextColor(1, 1, 1)
	end
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
		S:HandleIcon(spell.Icon)

		if not spell.Icon.backdrop then
			spell.Icon:CreateBackdrop()
		end

		local x = E.PixelMode and 1 or 2
		spell.Icon.backdrop:ClearAllPoints()
		spell.Icon.backdrop:SetPoint('TOPLEFT', spell.Icon, -x, x)
		spell.Icon.backdrop:SetPoint('BOTTOMRIGHT', spell.Icon, x, -x)
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
		[W.TextureAndText] = 'SkinTextureAndTextWidget',
		[W.SpellDisplay] = 'SkinSpellDisplay',
		[W.DoubleStateIconRow] = 'SkinDoubleStateIconRow',
		[W.TextureAndTextRow] = 'SkinTextureAndTextRowWidget',
		[W.ZoneControl] = 'SkinZoneControl',
		[W.CaptureZone] = 'SkinCaptureZone'
	}
end

function S:SkinWidgetContainer(widgetContainer)
	for _, child in ipairs({widgetContainer:GetChildren()}) do
		if S.WidgetSkinningFuncs[child.widgetType] then
			S[S.WidgetSkinningFuncs[child.widgetType]](S, child)
		end
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
	local load = (name == 'function' and name) or (not func and (S[name] or S[addonName]))
	S:RegisterSkin(addonName, load or func, forceLoad, bypass, position)
end

-- nonAddonsToLoad:
--- this is used for loading skins when our skin init function executes.
--- please add a given name, non-given-name is specific for elvui core addon.
function S:AddCallback(name, func, position) -- arg1: name is 'given name'
	local load = (name == 'function' and name) or (not func and S[name])
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
			S:Ace3_SkinTooltip(_G.LibStub(n, true))
		end
	end
	if S.EarlyDropdowns then
		for _, n in next, S.EarlyDropdowns do
			S:SkinLibDropDownMenu(n)
		end
	end

	do -- Credits ShestakUI
		hooksecurefunc(_G.UIWidgetTemplateCaptureBarMixin, 'Setup', function(widgetInfo)
			widgetInfo.LeftLine:SetAlpha(0)
			widgetInfo.RightLine:SetAlpha(0)
			widgetInfo.BarBackground:SetAlpha(0)
			widgetInfo.Glow1:SetAlpha(0)
			widgetInfo.Glow2:SetAlpha(0)
			widgetInfo.Glow3:SetAlpha(0)

			widgetInfo.LeftBar:SetTexture(E.media.normTex)
			widgetInfo.NeutralBar:SetTexture(E.media.normTex)
			widgetInfo.RightBar:SetTexture(E.media.normTex)

			widgetInfo.LeftBar:SetVertexColor(0.2, 0.6, 1)
			widgetInfo.NeutralBar:SetVertexColor(0.8, 0.8, 0.8)
			widgetInfo.RightBar:SetVertexColor(0.9, 0.2, 0.2)

			if not widgetInfo.backdrop then
				widgetInfo:CreateBackdrop()
				widgetInfo.backdrop:SetPoint('TOPLEFT', widgetInfo.LeftBar, -2, 2)
				widgetInfo.backdrop:SetPoint('BOTTOMRIGHT', widgetInfo.RightBar, 2, -2)
			end
		end)

		local frame = CreateFrame('Frame')
		frame:RegisterEvent('PLAYER_ENTERING_WORLD')
		frame:RegisterEvent('UPDATE_ALL_UI_WIDGETS')
		frame:SetScript('OnEvent', function()
			for _, widgetFrame in pairs(_G.UIWidgetTopCenterContainerFrame.widgetFrames) do
				if widgetFrame.widgetType == _G.Enum.UIWidgetVisualizationType.DoubleStatusBar then
					for _, bar in pairs({widgetFrame.LeftBar, widgetFrame.RightBar}) do
						if not bar.IsSkinned then
							bar.BG:SetAlpha(0)
							bar.BorderLeft:SetAlpha(0)
							bar.BorderRight:SetAlpha(0)
							bar.BorderCenter:SetAlpha(0)
							bar.Spark:SetAlpha(0)
							bar.SparkGlow:SetAlpha(0)
							bar.BorderGlow:SetAlpha(0)

							bar:CreateBackdrop('Transparent')

							bar.IsSkinned = true
						end
					end
				end
			end
		end)
	end

	hooksecurefunc('TriStateCheckbox_SetState', function(_, checkButton)
		if checkButton.forceSaturation then
			local tex = checkButton:GetCheckedTexture()
			if checkButton.state == 2 then
				tex:SetDesaturated(false)
				tex:SetVertexColor(unpack(E.media.rgbvaluecolor))
			elseif checkButton.state == 1 then
				tex:SetVertexColor(0.6, 0.6, 0.6)
			end
		end
	end)
end

-- Keep this outside, it's used for skinning addons before ElvUI load
S:RegisterEvent('ADDON_LOADED')

E:RegisterModule(S:GetName())
