local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:NewModule('Skins', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')

--Cache global variables
--Lua functions
local _G = _G
local unpack, assert, pairs, ipairs, select, type, pcall = unpack, assert, pairs, ipairs, select, type, pcall
local tinsert, wipe = table.insert, table.wipe
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local SetDesaturation = SetDesaturation
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local GetCVarBool = GetCVarBool
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SquareButton_SetIcon, ScriptErrorsFrame, HybridScrollFrame_GetOffset

E.Skins = S
S.addonsToLoad = {}
S.nonAddonsToLoad = {}
S.allowBypass = {}
S.addonCallbacks = {}
S.nonAddonCallbacks = {["CallPriority"] = {}}

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
	-- EditBox
	'TopTex',
	'TopLeftTex',
	'TopRightTex',
	'LeftTex',
	'BottomTex',
	'BottomLeftTex',
	'BottomRightTex',
	'RightTex',
	'MiddleTex',
}

-- Depends on the arrow texture to be up by default.
S.ArrowRotation = {
	['down'] = 0,
	['up'] = 3.14,
	['left'] = -1.57,
	['right'] = 1.57,
}

function S:SetModifiedBackdrop()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
end

function S:SetOriginalBackdrop()
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

-- function to handle the recap button script
function S:UpdateRecapButton()
	-- when UpdateRecapButton runs and enables the button, it unsets OnEnter
	-- we need to reset it with ours. blizzard will replace it when the button
	-- is disabled. so, we don't have to worry about anything else.
	if self and self.button4 and self.button4:IsEnabled() then
		self.button4:SetScript("OnEnter", S.SetModifiedBackdrop)
		self.button4:SetScript("OnLeave", S.SetOriginalBackdrop)
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
			XPBar.Bar:CreateBackdrop("Default")
			if XPBar.Bar.Background then
				XPBar.Bar.Background:SetInside(XPBar.Bar.backdrop)
			end
			if XPBar.Bar.Spark then
				XPBar.Bar.Spark:SetAlpha(0)
			end
			if XPBar.Bar.OverlayFrame and XPBar.Bar.OverlayFrame.Text then
				XPBar.Bar.OverlayFrame.Text:ClearAllPoints()
				XPBar.Bar.OverlayFrame.Text:Point("CENTER", XPBar.Bar)
			end
		end

		if XPBar.PrestigeReward and XPBar.PrestigeReward.Accept then
			XPBar.PrestigeReward.Accept:ClearAllPoints()
			XPBar.PrestigeReward.Accept:SetPoint("TOP", XPBar.PrestigeReward, "BOTTOM", 0, 0)
			if not XPBar.PrestigeReward.Accept.template then
				S:HandleButton(XPBar.PrestigeReward.Accept)
			end
		end

		if XPBar.NextAvailable then
			if XPBar.Bar then
				XPBar.NextAvailable:ClearAllPoints()
				XPBar.NextAvailable:SetPoint("LEFT", XPBar.Bar, "RIGHT", 0, -2)
			end

			if not XPBar.NextAvailable.backdrop then
				XPBar.NextAvailable:StripTextures()
				XPBar.NextAvailable:CreateBackdrop("Default")
				if XPBar.NextAvailable.Icon then
					XPBar.NextAvailable.backdrop:SetPoint("TOPLEFT", XPBar.NextAvailable.Icon, -(E.PixelMode and 1 or 2), (E.PixelMode and 1 or 2))
					XPBar.NextAvailable.backdrop:SetPoint("BOTTOMRIGHT", XPBar.NextAvailable.Icon, (E.PixelMode and 1 or 2), -(E.PixelMode and 1 or 2))
				end
			end

			if XPBar.NextAvailable.Icon then
				XPBar.NextAvailable.Icon:SetDrawLayer("ARTWORK")
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
		local bd = _G[prefix..'_DropDownList1Backdrop'];
		local mbd = _G[prefix..'_DropDownList1MenuBackdrop'];
		if bd and not bd.template then bd:SetTemplate('Transparent') end
		if mbd and not mbd.template then mbd:SetTemplate('Transparent') end

		S[prefix..'_UIDropDownMenuSkinned'] = true;
		hooksecurefunc(prefix..'_UIDropDownMenu_CreateFrames', function()
			local lvls = _G[(prefix == 'Lib' and 'LIB' or prefix)..'_UIDROPDOWNMENU_MAXLEVELS'];
			local ddbd = lvls and _G[prefix..'_DropDownList'..lvls..'Backdrop'];
			local ddmbd = lvls and _G[prefix..'_DropDownList'..lvls..'MenuBackdrop'];
			if ddbd and not ddbd.template then ddbd:SetTemplate('Transparent') end
			if ddmbd and not ddmbd.template then ddmbd:SetTemplate('Transparent') end
		end)
	end
end

function S:HandleInsetFrameTemplate(frame)
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

function S:SkinTalentListButtons(frame)
	local name = frame and frame.GetName and frame:GetName()
	if name then
		local bcl = _G[name.."BtnCornerLeft"]
		local bcr = _G[name.."BtnCornerRight"]
		local bbb = _G[name.."ButtonBottomBorder"]
		if bcl then bcl:SetTexture("") end
		if bcr then bcr:SetTexture("") end
		if bbb then bbb:SetTexture("") end
	end

	if frame.Inset then
		S:HandleInsetFrameTemplate(frame.Inset)

		frame.Inset:SetPoint("TOPLEFT", 4, -60)
		frame.Inset:SetPoint("BOTTOMRIGHT", -6, 26)
	end
end

function S:HandleButton(button, strip, isDeclineButton)
	assert(button, "doesn't exist!")

	local buttonName = button.GetName and button:GetName()

	if button.SetNormalTexture then button:SetNormalTexture("") end
	if button.SetHighlightTexture then button:SetHighlightTexture("") end
	if button.SetPushedTexture then button:SetPushedTexture("") end
	if button.SetDisabledTexture then button:SetDisabledTexture("") end

	if strip then button:StripTextures() end

	for _, region in pairs(S.Blizzard.Regions) do
		region = buttonName and _G[buttonName..region] or button[region]
		if region then
			region:SetAlpha(0)
		end
	end

	-- used for a white X on decline buttons (more clear)
	if isDeclineButton then
		if button.Icon then button.Icon:Hide() end
		if not button.text then
			button.text = button:CreateFontString(nil, 'OVERLAY')
			button.text:SetFont([[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], 16, 'OUTLINE')
			button.text:SetText('x')
			button.text:SetJustifyH('CENTER')
			button.text:Point('CENTER', button, 'CENTER')
		end
	end

	button:SetTemplate("Default", true)
	button:HookScript("OnEnter", S.SetModifiedBackdrop)
	button:HookScript("OnLeave", S.SetOriginalBackdrop)
end

function S:HandleScrollBar(frame, thumbTrimY, thumbTrimX)
	if frame:GetName() then
		if frame.Background then frame.Background:SetTexture(nil) end
		if frame.trackBG then frame.trackBG:SetTexture(nil) end
		if frame.Middle then frame.Middle:SetTexture(nil) end
		if frame.Top then frame.Top:SetTexture(nil) end
		if frame.Bottom then frame.Bottom:SetTexture(nil) end
		if frame.ScrollBarTop then frame.ScrollBarTop:SetTexture(nil) end
		if frame.ScrollBarBottom then frame.ScrollBarBottom:SetTexture(nil) end
		if frame.ScrollBarMiddle then frame.ScrollBarMiddle:SetTexture(nil) end

		if _G[frame:GetName().."BG"] then _G[frame:GetName().."BG"]:SetTexture(nil) end
		if _G[frame:GetName().."Track"] then _G[frame:GetName().."Track"]:SetTexture(nil) end
		if _G[frame:GetName().."Top"] then _G[frame:GetName().."Top"]:SetTexture(nil) end
		if _G[frame:GetName().."Bottom"] then _G[frame:GetName().."Bottom"]:SetTexture(nil) end
		if _G[frame:GetName().."Middle"] then _G[frame:GetName().."Middle"]:SetTexture(nil) end

		if _G[frame:GetName().."ScrollUpButton"] and _G[frame:GetName().."ScrollDownButton"] then
			_G[frame:GetName().."ScrollUpButton"]:StripTextures()
			if not _G[frame:GetName().."ScrollUpButton"].icon then
				S:HandleNextPrevButton(_G[frame:GetName().."ScrollUpButton"], true, true)
				_G[frame:GetName().."ScrollUpButton"]:Size(_G[frame:GetName().."ScrollUpButton"]:GetWidth() + 7, _G[frame:GetName().."ScrollUpButton"]:GetHeight() + 7)
			end

			_G[frame:GetName().."ScrollDownButton"]:StripTextures()
			if not _G[frame:GetName().."ScrollDownButton"].icon then
				S:HandleNextPrevButton(_G[frame:GetName().."ScrollDownButton"], true)
				_G[frame:GetName().."ScrollDownButton"]:Size(_G[frame:GetName().."ScrollDownButton"]:GetWidth() + 7, _G[frame:GetName().."ScrollDownButton"]:GetHeight() + 7)
			end

			if not frame.trackbg then
				frame.trackbg = CreateFrame("Frame", nil, frame)
				frame.trackbg:Point("TOPLEFT", _G[frame:GetName().."ScrollUpButton"], "BOTTOMLEFT", 0, -1)
				frame.trackbg:Point("BOTTOMRIGHT", _G[frame:GetName().."ScrollDownButton"], "TOPRIGHT", 0, 1)
				frame.trackbg:SetTemplate("Default", true, true)
			end

			if frame:GetThumbTexture() then
				frame:GetThumbTexture():SetTexture(nil)
				if not frame.thumbbg then
					if not thumbTrimY then thumbTrimY = 3 end
					if not thumbTrimX then thumbTrimX = 2 end
					frame.thumbbg = CreateFrame("Frame", nil, frame)
					frame.thumbbg:Point("TOPLEFT", frame:GetThumbTexture(), "TOPLEFT", 2, -thumbTrimY)
					frame.thumbbg:Point("BOTTOMRIGHT", frame:GetThumbTexture(), "BOTTOMRIGHT", -thumbTrimX, thumbTrimY)
					frame.thumbbg:SetTemplate("Default", true, true)
					frame.thumbbg.backdropTexture:SetVertexColor(0.6, 0.6, 0.6)
					if frame.trackbg then
						frame.thumbbg:SetFrameLevel(frame.trackbg:GetFrameLevel()+1)
					end
				end
			end
		end
	else
		if frame.Background then frame.Background:SetTexture(nil) end
		if frame.trackBG then frame.trackBG:SetTexture(nil) end
		if frame.Middle then frame.Middle:SetTexture(nil) end
		if frame.Top then frame.Top:SetTexture(nil) end
		if frame.Bottom then frame.Bottom:SetTexture(nil) end
		if frame.ScrollBarTop then frame.ScrollBarTop:SetTexture(nil) end
		if frame.ScrollBarBottom then frame.ScrollBarBottom:SetTexture(nil) end
		if frame.ScrollBarMiddle then frame.ScrollBarMiddle:SetTexture(nil) end

		if frame.ScrollUpButton and frame.ScrollDownButton then
			if not frame.ScrollUpButton.icon then
				S:HandleNextPrevButton(frame.ScrollUpButton, true, true)
				frame.ScrollUpButton:Size(frame.ScrollUpButton:GetWidth() + 7, frame.ScrollUpButton:GetHeight() + 7)
			end

			if not frame.ScrollDownButton.icon then
				S:HandleNextPrevButton(frame.ScrollDownButton, true)
				frame.ScrollDownButton:Size(frame.ScrollDownButton:GetWidth() + 7, frame.ScrollDownButton:GetHeight() + 7)
			end

			if not frame.trackbg then
				frame.trackbg = CreateFrame("Frame", nil, frame)
				frame.trackbg:Point("TOPLEFT", frame.ScrollUpButton, "BOTTOMLEFT", 0, -1)
				frame.trackbg:Point("BOTTOMRIGHT", frame.ScrollDownButton, "TOPRIGHT", 0, 1)
				frame.trackbg:SetTemplate("Default", true, true)
			end

			if frame.thumbTexture then
				frame.thumbTexture:SetTexture(nil)
				if not frame.thumbbg then
					if not thumbTrimY then thumbTrimY = 3 end
					if not thumbTrimX then thumbTrimX = 2 end
					frame.thumbbg = CreateFrame("Frame", nil, frame)
					frame.thumbbg:Point("TOPLEFT", frame.thumbTexture, "TOPLEFT", 2, -thumbTrimY)
					frame.thumbbg:Point("BOTTOMRIGHT", frame.thumbTexture, "BOTTOMRIGHT", -thumbTrimX, thumbTrimY)
					frame.thumbbg:SetTemplate("Default", true, true)
					frame.thumbbg.backdropTexture:SetVertexColor(0.6, 0.6, 0.6)
					if frame.trackbg then
						frame.thumbbg:SetFrameLevel(frame.trackbg:GetFrameLevel()+1)
					end
				end
			end
		end
	end
end

-- HybridScrollFrame (Taken from Aurora)
function S:HandleScrollSlider(Slider, thumbTrim)
	local parent = Slider:GetParent()
	if not parent then return end
	Slider:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, -17)
	Slider:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 0, 17)

	Slider:StripTextures()

	if Slider.trackBG then Slider.trackBG:Hide() end
	if Slider.ScrollBarTop then Slider.ScrollBarTop:Hide() end
	if Slider.ScrollBarMiddle then Slider.ScrollBarMiddle:Hide() end
	if Slider.ScrollBarBottom then Slider.ScrollBarBottom:Hide() end
	if Slider.Top then Slider.Top:SetTexture(nil) end
	if Slider.Bottom then Slider.Bottom:SetTexture(nil) end

	if not Slider.trackbg then
		Slider.trackbg = CreateFrame("Frame", nil, Slider)
		if Slider.ScrollUp and Slider.ScrollDown then
			Slider.trackbg:Point("TOPLEFT", Slider.ScrollUp, "BOTTOMLEFT", 0, 0)
			Slider.trackbg:Point("BOTTOMRIGHT", Slider.ScrollDown, "TOPRIGHT", 0, 0)
		elseif Slider.ScrollUpButton and Slider.ScrollDownButton then
			Slider.trackbg:Point("TOPLEFT", Slider.ScrollUpButton, "BOTTOMLEFT", 0, -1)
			Slider.trackbg:Point("BOTTOMRIGHT", Slider.ScrollDownButton, "TOPRIGHT", 0, 1)
		elseif parent.scrollUp and parent.scrollDown then
			Slider.trackbg:Point("TOPLEFT", parent.scrollUp, "BOTTOMLEFT", 0, -1)
			Slider.trackbg:Point("BOTTOMRIGHT", parent.scrollDown, "TOPRIGHT", 0, 1)
		end
		Slider.trackbg:SetTemplate("Default", true, true)
	end

	if Slider.ScrollUp and Slider.ScrollDown then
		if not Slider.ScrollUp.icon then
			S:HandleNextPrevButton(Slider.ScrollUp, true, true)
			Slider.ScrollUp:Size(Slider:GetWidth(), Slider.ScrollUp:GetHeight() + 7)
		end

		if not Slider.ScrollDown.icon then
			S:HandleNextPrevButton(Slider.ScrollDown, true)
			Slider.ScrollDown:Size(Slider:GetWidth(), Slider.ScrollDown:GetHeight() + 7)
		end
	end

	if Slider.ScrollUpButton  and Slider.ScrollDownButton then
		if not Slider.ScrollUpButton.icon then
			S:HandleNextPrevButton(Slider.ScrollUpButton, true, true)
			Slider.ScrollUpButton:Size(Slider:GetWidth(), Slider.ScrollUpButton:GetHeight() + 7)
		end

		if not Slider.ScrollDownButton.icon then
			S:HandleNextPrevButton(Slider.ScrollDownButton, true)
			Slider.ScrollDownButton:Size(Slider:GetWidth(), Slider.ScrollDownButton:GetHeight() + 7)
		end
	end

	if parent.scrollUp and parent.scrollDown then
		if not parent.scrollUp.icon then
			S:HandleNextPrevButton(parent.scrollUp, true, true)
			parent.scrollUp:Size(Slider:GetWidth(), parent.scrollUp:GetHeight() + 7)
		end

		if not parent.scrollDown.icon then
			S:HandleNextPrevButton(parent.scrollDown, true)
			parent.scrollDown:Size(Slider:GetWidth(), parent.scrollDown:GetHeight() + 7)
		end
	end

	if Slider.thumbTexture then
		if not thumbTrim then thumbTrim = 3 end
		Slider.thumbTexture:SetTexture(nil)
		if not Slider.thumbbg then
			Slider.thumbbg = CreateFrame("Frame", nil, Slider)
			Slider.thumbbg:Point("TOPLEFT", Slider.thumbTexture, "TOPLEFT", 2, -thumbTrim)
			Slider.thumbbg:Point("BOTTOMRIGHT", Slider.thumbTexture, "BOTTOMRIGHT", -2, thumbTrim)
			Slider.thumbbg:SetTemplate("Default", true, true)
			Slider.thumbbg.backdropTexture:SetVertexColor(0.6, 0.6, 0.6)
			if Slider.trackbg then
				Slider.thumbbg:SetFrameLevel(Slider.trackbg:GetFrameLevel()+1)
			end
		end
	elseif Slider.ThumbTexture then
		if not thumbTrim then thumbTrim = 3 end
		Slider.ThumbTexture:SetTexture(nil)
		if not Slider.thumbbg then
			Slider.thumbbg = CreateFrame("Frame", nil, Slider)
			Slider.thumbbg:Point("TOPLEFT", Slider.ThumbTexture, "TOPLEFT", 2, -thumbTrim)
			Slider.thumbbg:Point("BOTTOMRIGHT", Slider.ThumbTexture, "BOTTOMRIGHT", -2, thumbTrim)
			Slider.thumbbg:SetTemplate("Default", true, true)
			Slider.thumbbg.backdropTexture:SetVertexColor(0.6, 0.6, 0.6)
			if Slider.trackbg then
				Slider.thumbbg:SetFrameLevel(Slider.trackbg:GetFrameLevel()+1)
			end
		end
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

function S:HandleTab(tab)
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
	tab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -1 or -3)
	tab.backdrop:Point("BOTTOMRIGHT", -10, 3)
end

function S:HandleNextPrevButton(btn, useVertical, inverseDirection)
	inverseDirection = inverseDirection or btn:GetName() and (find(btn:GetName():lower(), 'left') or find(btn:GetName():lower(), 'prev') or find(btn:GetName():lower(), 'decrement') or find(btn:GetName():lower(), 'back'))

	btn:StripTextures()
	btn:SetNormalTexture(nil)
	btn:SetPushedTexture(nil)
	btn:SetHighlightTexture(nil)
	btn:SetDisabledTexture(nil)

	if not btn.icon then
		btn.icon = btn:CreateTexture(nil, 'ARTWORK')
		btn.icon:Size(13)
		btn.icon:Point('CENTER')
		btn.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])
		btn.icon:SetTexCoord(0.01562500, 0.20312500, 0.01562500, 0.20312500)

		btn:HookScript('OnMouseDown', function(button)
			if button:IsEnabled() then
				button.icon:Point("CENTER", -1, -1);
			end
		end)

		btn:HookScript('OnMouseUp', function(button)
			button.icon:Point("CENTER", 0, 0);
		end)

		btn:HookScript('OnDisable', function(button)
			SetDesaturation(button.icon, true);
			button.icon:SetAlpha(0.5);
		end)

		btn:HookScript('OnEnable', function(button)
			SetDesaturation(button.icon, false);
			button.icon:SetAlpha(1.0);
		end)

		if not btn:IsEnabled() then
			btn:GetScript('OnDisable')(btn)
		end
	end

	if useVertical then
		if inverseDirection then
			SquareButton_SetIcon(btn, 'UP')
		else
			SquareButton_SetIcon(btn, 'DOWN')
		end
	else
		if inverseDirection then
			SquareButton_SetIcon(btn, 'LEFT')
		else
			SquareButton_SetIcon(btn, 'RIGHT')
		end
	end

	S:HandleButton(btn)
	btn:Size(btn:GetWidth() - 7, btn:GetHeight() - 7)
end

function S:HandleRotateButton(btn)
	btn:SetTemplate("Default")
	btn:Size(btn:GetWidth() - 14, btn:GetHeight() - 14)

	btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)
	btn:GetPushedTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)

	btn:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.3)

	btn:GetNormalTexture():SetInside()
	btn:GetPushedTexture():SetAllPoints(btn:GetNormalTexture())
	btn:GetHighlightTexture():SetAllPoints(btn:GetNormalTexture())
end

function S:HandleMaxMinFrame(frame)
	assert(frame, "does not exist.")

	frame:StripTextures(true)

	for name, direction in pairs ({ ["MaximizeButton"] = 'up', ["MinimizeButton"] = 'down'}) do
		local button = frame[name]

		if button then
			button:SetSize(16, 16)
			button:ClearAllPoints()
			button:SetPoint("CENTER")
			button:SetHitRectInsets(1, 1, 1, 1)

			S:HandleButton(button)

			button:SetNormalTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
			button:GetNormalTexture():SetRotation(S.ArrowRotation[direction])
			button:GetNormalTexture():SetInside(button, 2, 2)

			button:SetPushedTexture("Interface\\AddOns\\ElvUI\\media\\textures\\vehicleexit")
			button:GetPushedTexture():SetRotation(S.ArrowRotation[direction])
			button:GetPushedTexture():SetInside()
		end
	end
end

function S:HandleEditBox(frame)
	frame:CreateBackdrop("Default")

	if frame.TopLeftTex then frame.TopLeftTex:Kill() end
	if frame.TopRightTex then frame.TopRightTex:Kill() end
	if frame.TopTex then frame.TopTex:Kill() end
	if frame.BottomLeftTex then frame.BottomLeftTex:Kill() end
	if frame.BottomRightTex then frame.BottomRightTex:Kill() end
	if frame.BottomTex then frame.BottomTex:Kill() end
	if frame.LeftTex then frame.LeftTex:Kill() end
	if frame.RightTex then frame.RightTex:Kill() end
	if frame.MiddleTex then frame.MiddleTex:Kill() end
	if frame.Left then frame.Left:Kill() end
	if frame.Right then frame.Right:Kill() end
	if frame.Middle then frame.Middle:Kill() end
	if frame.Mid then frame.Mid:Kill() end

	local frameName = frame.GetName and frame:GetName()
	if frameName then
		if _G[frameName.."Left"] then _G[frameName.."Left"]:Kill() end
		if _G[frameName.."Middle"] then _G[frameName.."Middle"]:Kill() end
		if _G[frameName.."Right"] then _G[frameName.."Right"]:Kill() end
		if _G[frameName.."Mid"] then _G[frameName.."Mid"]:Kill() end

		if frameName:find("Silver") or frameName:find("Copper") then
			frame.backdrop:Point("BOTTOMRIGHT", -12, -2)
		end
	end
end

function S:HandleDropDownBox(frame, width)
	local button = _G[frame:GetName().."Button"]
	if not button then return end

	if not width then width = 155 end

	frame:StripTextures()
	frame:Width(width)

	local frameText = _G[frame:GetName().."Text"]
	if frameText then
		_G[frame:GetName().."Text"]:ClearAllPoints()
		_G[frame:GetName().."Text"]:Point("RIGHT", button, "LEFT", -2, 0)
	end

	if button then
		button:ClearAllPoints()
		button:Point("RIGHT", frame, "RIGHT", -10, 3)
		hooksecurefunc(button, "SetPoint", function(btn, _, _, _, _, _, noReset)
			if not noReset then
				btn:ClearAllPoints()
				btn:SetPoint("RIGHT", frame, "RIGHT", E:Scale(-10), E:Scale(3), true)
			end
		end)

		self:HandleNextPrevButton(button, true)
	end

	frame:CreateBackdrop("Default")
	frame.backdrop:Point("TOPLEFT", 20, -2)
	frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
end

-- New BFA DropDown Template (Original Function Credits: Aurora) ~ was modified.
function S:HandleDropDownFrame(frame, width)
	if not width then width = 155 end

	local left = frame.Left
	local middle = frame.Middle
	local right = frame.Right
	if left then
		left:SetAlpha(0)
		left:SetSize(25, 64)
		left:SetPoint("TOPLEFT", 0, 17)
	end
	if middle then
		middle:SetAlpha(0)
		middle:SetHeight(64)
	end
	if right then
		right:SetAlpha(0)
		right:SetSize(25, 64)
	end

	local button = frame.Button
	if button then
		button:SetSize(24, 24)
		button:ClearAllPoints()
		button:Point("RIGHT", right, "RIGHT", -20, 0)

		button.NormalTexture:SetTexture("")
		button.PushedTexture:SetTexture("")
		button.HighlightTexture:SetTexture("")

		hooksecurefunc(button, "SetPoint", function(btn, _, _, _, _, _, noReset)
			if not noReset then
				btn:ClearAllPoints()
				btn:SetPoint("RIGHT", frame, "RIGHT", E:Scale(-20), E:Scale(0), true)
			end
		end)

		self:HandleNextPrevButton(button, true)
	end

	local disabled = button and button.DisabledTexture
	if disabled then
		disabled:SetAllPoints(button)
		disabled:SetColorTexture(0, 0, 0, .3)
		disabled:SetDrawLayer("OVERLAY")
	end

	if middle and (not frame.noResize) then
		frame:SetWidth(40)
		middle:SetWidth(width)
	end

	if right and frame.Text then
		frame.Text:SetSize(0, 10)
		frame.Text:SetPoint("RIGHT", right, -43, 2)
	end

	frame:CreateBackdrop("Default")
	frame.backdrop:Point("TOPLEFT", 20, -2)
	frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
end

function S:HandleCheckBox(frame, noBackdrop, noReplaceTextures)
	assert(frame, 'does not exist.')

	frame:StripTextures()

	if noBackdrop then
		frame:SetTemplate("Default")
		frame:Size(16)
	else
		frame:CreateBackdrop('Default')
		frame.backdrop:SetInside(nil, 4, 4)
	end

	if not noReplaceTextures then
		if frame.SetCheckedTexture then
			frame:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
			if noBackdrop then
				frame:GetCheckedTexture():SetInside(nil, -4, -4)
			end
		end

		if frame.SetDisabledTexture then
			frame:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
			if noBackdrop then
				frame:GetDisabledTexture():SetInside(nil, -4, -4)
			end
		end

		frame:HookScript('OnDisable', function(checkbox)
			if not checkbox.SetDisabledTexture then return; end
			if checkbox:GetChecked() then
				checkbox:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
			else
				checkbox:SetDisabledTexture("")
			end
		end)

		hooksecurefunc(frame, "SetNormalTexture", function(checkbox, texPath)
			if texPath ~= "" then checkbox:SetNormalTexture("") end
		end)
		hooksecurefunc(frame, "SetPushedTexture", function(checkbox, texPath)
			if texPath ~= "" then checkbox:SetPushedTexture("") end
		end)
		hooksecurefunc(frame, "SetHighlightTexture", function(checkbox, texPath)
			if texPath ~= "" then checkbox:SetHighlightTexture("") end
		end)
	end
end

function S:HandleIcon(icon, parent)
	parent = parent or icon:GetParent()

	icon:SetTexCoord(unpack(E.TexCoords))
	parent:CreateBackdrop('Default')
	icon:SetParent(parent.backdrop)
	parent.backdrop:SetOutside(icon)
end

function S:HandleTexture(icon, parent)
	icon:SetTexCoord(unpack(E.TexCoords))
	if parent then
		local layer, subLevel = icon:GetDrawLayer()
		local iconBorder = parent:CreateTexture(nil, layer, nil, subLevel - 1)
		iconBorder:SetPoint("TOPLEFT", icon, -1, 1)
		iconBorder:SetPoint("BOTTOMRIGHT", icon, 1, -1)
		iconBorder:SetColorTexture(0, 0, 0)
		return iconBorder
	end
end

function S:HandleItemButton(b, shrinkIcon)
	if b.isSkinned then return; end

	local icon = b.icon or b.Icon or b.IconTexture or b.iconTexture
	if b:GetName() and _G[b:GetName()..'IconTexture'] then
		icon = _G[b:GetName()..'IconTexture']
	elseif b:GetName() and _G[b:GetName()..'Icon'] then
		icon = _G[b:GetName()..'Icon']
	end

	local texture
	if icon and icon.GetTexture and icon:GetTexture() then
		texture = icon:GetTexture()
	end

	b:StripTextures()
	b:CreateBackdrop('Default', true)
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

function S:HandleCloseButton(f, point, text)
	f:StripTextures()

	if not f.backdrop then
		f:CreateBackdrop('Default', true)
		f.backdrop:Point('TOPLEFT', 7, -8)
		f.backdrop:Point('BOTTOMRIGHT', -8, 8)
		f:HookScript('OnEnter', S.SetModifiedBackdrop)
		f:HookScript('OnLeave', S.SetOriginalBackdrop)
		f:SetHitRectInsets(6, 6, 7, 7)
	end

	if not text then text = 'x' end

	if not f.text then
		f.text = f:CreateFontString(nil, 'OVERLAY')
		f.text:SetFont([[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], 16, 'OUTLINE')
		f.text:SetText(text)
		f.text:SetJustifyH('CENTER')
		f.text:Point('CENTER', f, 'CENTER')
	end

	if point then
		f:Point("TOPRIGHT", point, "TOPRIGHT", 2, 2)
	end
end

function S:HandleSliderFrame(frame)
	assert(frame)

	local orientation = frame:GetOrientation()
	local SIZE = 12

	frame:StripTextures()
	frame:CreateBackdrop('Default')
	frame.backdrop:SetAllPoints()

	hooksecurefunc(frame, "SetBackdrop", function(slider, backdrop)
		if backdrop ~= nil then slider:SetBackdrop(nil) end
	end)

	frame:SetThumbTexture([[Interface\AddOns\ElvUI\media\textures\melli]])
	frame:GetThumbTexture():SetVertexColor(1, .82, 0, 0.8)
	frame:GetThumbTexture():Size(SIZE-2,SIZE-2)

	if orientation == 'VERTICAL' then
		frame:Width(SIZE)
	else
		frame:Height(SIZE)

		for i=1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region and region:GetObjectType() == 'FontString' then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if anchorPoint:find('BOTTOM') then
					region:Point(point, anchor, anchorPoint, x, y - 4)
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
			if icon and not iconButton.backdrop then
				S:HandleIcon(icon, iconButton)
				icon:SetDrawLayer("BORDER", 0)
				if iconButton.Border then
					iconButton.Border:SetTexture(nil)
				end
			end
		end
	end

	local combatAllySpells = abilityFrame.CombatAllySpell
	if combatAllySpells then
		for i = 1, #combatAllySpells do
			local icon = combatAllySpells[i].iconTexture
			if icon and not combatAllySpells[i].backdrop then
				S:HandleIcon(icon, combatAllySpells[i])
			end
		end
	end

	if hasItems then
		local weapon = followerTab.ItemWeapon
		if weapon and not weapon.backdrop then
			S:HandleIcon(weapon.Icon, weapon)
			if weapon.Border then
				weapon.Border:SetTexture(nil)
			end
		end

		local armor = followerTab.ItemArmor
		if armor and not armor.backdrop then
			S:HandleIcon(armor.Icon, armor)
			if armor.Border then
				armor.Border:SetTexture(nil)
			end
		end
	end

	local xpbar = followerTab.XPBar
	if xpbar and not xpbar.backdrop then
		xpbar:StripTextures()
		xpbar:SetStatusBarTexture(E.media.normTex)
		xpbar:CreateBackdrop("Transparent")
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
					equipment[i]:SetTemplate('Default')
					equipment[i]:SetSize(48, 48)
					if equipment[i].BG then
						equipment[i].BG:SetTexture(nil)
					end
					if equipment[i].Border then
						equipment[i].Border:SetTexture(nil)
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
							equipment[i]:SetPoint("TOPLEFT", abilityFrame.EquipmentSlotsLabel, "BOTTOM", -totalWidth/2, 0);
						else
							equipment[i]:SetPoint("TOPLEFT", abilityFrame.EquipmentSlotsLabel, "BOTTOM", -totalWidth/2, -20);
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
		border:SetTexture(nil) -- I think the default border looks nice, not sure if we want to replace that
		-- The landing page icons display inner borders
		if followerTab.isLandingPage then
			icon:SetTexCoord(unpack(E.TexCoords))
		end
	end

	local equipment = followerTab.EquipmentFrame.Equipment
	for i = 1, #equipment do
		local icon = equipment[i].Icon
		local border = equipment[i].Border
		border:SetAtlas("ShipMission_ShipFollower-TypeFrame") -- This border is ugly though, use the traits border instead
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
					button.Category:SetPoint("TOP", button, "TOP", 0, -4)
				end

				if button.Follower then
					button.Follower.Name:SetWordWrap(false)
					button.Follower.BG:Hide()
					button.Follower.Selection:SetTexture("")
					button.Follower.AbilitiesBG:SetTexture("")
					button.Follower.BusyFrame:SetAllPoints()

					local hl = button.Follower:GetHighlightTexture()
					hl:SetColorTexture(0.9, 0.8, 0.1, 0.3)
					hl:ClearAllPoints()
					hl:SetPoint("TOPLEFT", 1, -1)
					hl:SetPoint("BOTTOMRIGHT", -1, 1)

					if button.Follower.Counters then
						for y = 1, #button.Follower.Counters do
							local counter = button.Follower.Counters[y]
							if counter and not counter.template then
								counter:SetTemplate()
								if counter.Border then
									counter.Border:SetTexture(nil)
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
						button.Follower.PortraitFrame:SetPoint("TOPLEFT", 3, -3)
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
	hooksecurefunc(_G[frame], "UpdateData", function(dataFrame)
		if not S.FollowerListUpdateDataFrames[frame] or (not dataFrame or not dataFrame.listScroll) then return end
		local offset = HybridScrollFrame_GetOffset(dataFrame.listScroll)
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
	portrait.Portrait:SetPoint("TOPLEFT", 1, -1)

	portrait.PortraitRing:Hide()
	portrait.PortraitRingQuality:SetTexture("")
	portrait.PortraitRingCover:SetTexture("")
	portrait.LevelBorder:SetAlpha(0)

	portrait.Level:ClearAllPoints()
	portrait.Level:SetPoint("BOTTOM")
	portrait.Level:FontTemplate(nil, 12, "OUTLINE")

	if not portrait.backdrop then
		portrait:CreateBackdrop("Default")
		portrait.backdrop:SetPoint("TOPLEFT", portrait, "TOPLEFT", -1, 1)
		portrait.backdrop:SetPoint("BOTTOMRIGHT", portrait, "BOTTOMRIGHT", 1, -1)
		portrait.backdrop:SetFrameLevel(portrait:GetFrameLevel())
	end
end

-- Interface\SharedXML\SharedUIPanelTemplatex.xml - line 780
function S:HandleTooltipBorderedFrame(frame)
	assert(frame, "doesn't exist!")

	if frame.BorderTopLeft then frame.BorderTopLeft:Hide() end
	if frame.BorderTopRight then frame.BorderTopRight:Hide() end

	if frame.BorderBottomLeft then frame.BorderBottomLeft:Hide() end
	if frame.BorderBottomRight then frame.BorderBottomRight:Hide() end

	if frame.BorderTop then frame.BorderTop:Hide() end
	if frame.BorderBottom then frame.BorderBottom:Hide() end
	if frame.BorderLeft then frame.BorderLeft:Hide() end
	if frame.BorderRight then frame.BorderRight:Hide() end

	if frame.Background then frame.Background:Hide() end

	frame:SetTemplate("Transparent")
end

function S:HandleIconSelectionFrame(frame, numIcons, buttonNameTemplate, frameNameOverride)
	assert(frame, "HandleIconSelectionFrame: frame argument missing")
	assert(numIcons and type(numIcons) == "number", "HandleIconSelectionFrame: numIcons argument missing or not a number")
	assert(buttonNameTemplate and type(buttonNameTemplate) == "string", "HandleIconSelectionFrame: buttonNameTemplate argument missing or not a string")

	local frameName = frameNameOverride or frame:GetName() --We need override in case Blizzard fucks up the naming (guild bank)
	local scrollFrame = _G[frameName.."ScrollFrame"]
	local editBox = _G[frameName.."EditBox"]
	-- We handle the skin in the files for now. (???)
	--local okayButton = _G[frameName.."OkayButton"] or _G[frameName.."Okay"]
	--local cancelButton = _G[frameName.."CancelButton"] or _G[frameName.."Cancel"]

	frame:StripTextures()
	frame.BorderBox:StripTextures()
	scrollFrame:StripTextures()
	editBox:DisableDrawLayer("BACKGROUND") -- Removes textures around it

	frame:SetTemplate("Transparent")
	frame:Height(frame:GetHeight() + 10)
	scrollFrame:Height(scrollFrame:GetHeight() + 10)

	--S:HandleButton(okayButton)
	--S:HandleButton(CancelButton)
	--S:HandleEditBox(editBox)

	--cancelButton:ClearAllPoints()
	--cancelButton:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)

	for i = 1, numIcons do
		local button = _G[buttonNameTemplate..i]
		local icon = _G[button:GetName().."Icon"]
		button:StripTextures()
		button:SetTemplate("Default")
		button:StyleButton(true)
		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))
	end
end

-- World Map related Skinning functions used for WoW 8.0
function S:WorldMapMixin_AddOverlayFrame(frame, templateName)
	S[templateName](frame.overlayFrames[#frame.overlayFrames])
end

function S:HandleWorldMapDropDownMenu(frame)
	local left = frame.Left
	local middle = frame.Middle
	local right = frame.Right
	if left then
		left:SetAlpha(0)
		left:SetSize(25, 64)
		left:SetPoint("TOPLEFT", 0, 17)
	end
	if middle then
		middle:SetAlpha(0)
		middle:SetHeight(64)
	end
	if right then
		right:SetAlpha(0)
		right:SetSize(25, 64)
	end

	local button = frame.Button
	if button then
		button:ClearAllPoints()
		button:Point("RIGHT", frame, "RIGHT", -10, 3)
		button:SetSize(20, 20)

		button.NormalTexture:SetTexture("")
		button.PushedTexture:SetTexture("")
		button.HighlightTexture:SetTexture("")
		hooksecurefunc(button, "SetPoint", function(btn, _, _, _, _, _, noReset)
			if not noReset then
				btn:ClearAllPoints()
				btn:SetPoint("RIGHT", frame, "RIGHT", E:Scale(-10), E:Scale(3), true)
			end
		end)

		self:HandleNextPrevButton(button, true)
	end

	local disabled = button and button.DisabledTexture
	if disabled then
		disabled:SetAllPoints(button)
		disabled:SetColorTexture(0, 0, 0, .3)
		disabled:SetDrawLayer("OVERLAY")
	end

	if right and frame.Text then
		frame.Text:FontTemplate(nil, 10)
		frame.Text:SetSize(0, 10)
		frame.Text:SetPoint("RIGHT", right, -43, 2)
	end

	if middle and (not frame.noResize) then
		frame:SetWidth(40)
		middle:SetWidth(115)
	end

	frame:SetHeight(32)
	frame:CreateBackdrop("Default")
	frame.backdrop:Point("TOPLEFT", 20, -2)

	if button then
		frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	end
end

function S:SkinIconAndTextWidget(widgetFrame)
end

function S:SkinCaptureBarWidget(widgetFrame)
end

function S:SkinStatusBarWidget(widgetFrame)
	local bar = widgetFrame.Bar;
	if bar then
		-- Hide StatusBar textures
		if bar.BorderLeft then bar.BorderLeft:Hide() end
		if bar.BorderRight then bar.BorderRight:Hide() end
		if bar.BorderCenter then bar.BorderCenter:Hide() end
		if bar.BGLeft then bar.BGLeft:Hide() end
		if bar.BGRight then bar.BGRight:Hide() end
		if bar.BGCenter then bar.BGCenter:Hide() end

		if not bar.backdrop then
			bar:CreateBackdrop("Default")
		end

		bar.backdrop:Point("TOPLEFT", -2, 2)
		bar.backdrop:Point("BOTTOMRIGHT", 2, -2)
	end
end

function S:SkinDoubleStatusBarWidget(widgetFrame)
end

function S:SkinIconTextAndBackgroundWidget(widgetFrame)
end

function S:SkinDoubleIconAndTextWidget(widgetFrame)
end

function S:SKinStackedResourceTrackerWidget(widgetFrame)
end

function S:SkinIconTextAndCurrenciesWidget(widgetFrame)
end

function S:SkinTextWithStateWidget(widgetFrame)
	local text = widgetFrame.Text;
end

function S:SkinHorizontalCurrenciesWidget(widgetFrame)
end

function S:SkinBulletTextListWidget(widgetFrame)
end

function S:SkinScenarioHeaderCurrenciesAndBackgroundWidget(widgetFrame)
end

function S:SkinTextureWithStateWidget(widgetFrame)
end

local W = Enum.UIWidgetVisualizationType;
S.WidgetSkinningFuncs = {
	[W.IconAndText] = "SkinIconAndTextWidget",
	[W.CaptureBar] = "SkinCaptureBarWidget",
	[W.StatusBar] = "SkinStatusBarWidget",
	[W.DoubleStatusBar] = "SkinDoubleStatusBarWidget",
	[W.IconTextAndBackground] = "SkinIconTextAndBackgroundWidget",
	[W.DoubleIconAndText] = "SkinDoubleIconAndTextWidget",
	[W.StackedResourceTracker] = "SKinStackedResourceTrackerWidget",
	[W.IconTextAndCurrencies] = "SkinIconTextAndCurrenciesWidget",
	[W.TextWithState] = "SkinTextWithStateWidget",
	[W.HorizontalCurrencies] = "SkinHorizontalCurrenciesWidget",
	[W.BulletTextList] = "SkinBulletTextListWidget",
	[W.ScenarioHeaderCurrenciesAndBackground] = "SkinScenarioHeaderCurrenciesAndBackgroundWidget",
	[W.TextureWithState] = "SkinTextureWithStateWidget"
}

function S:SkinWidgetContainer(widgetContainer)
	for _, child in ipairs({widgetContainer:GetChildren()}) do
		if S.WidgetSkinningFuncs[child.widgetType] then
			S[S.WidgetSkinningFuncs[child.widgetType]](S, child)
		end
	end
end

function S:ADDON_LOADED(_, addon)
	if E.private.skins.blizzard.enable and E.private.skins.blizzard.misc then
		if not S.L_UIDropDownMenuSkinned then S:SkinLibDropDownMenu('L') end -- LibUIDropDownMenu
		if not S.Lib_UIDropDownMenuSkinned then S:SkinLibDropDownMenu('Lib') end -- NoTaint_UIDropDownMenu
	end

	if self.allowBypass[addon] then
		if self.addonsToLoad[addon] then
			--Load addons using the old deprecated register method
			self.addonsToLoad[addon]()
			self.addonsToLoad[addon] = nil
		elseif self.addonCallbacks[addon] then
			--Fire events to the skins that rely on this addon
			for index, event in ipairs(self.addonCallbacks[addon].CallPriority) do
				self.addonCallbacks[addon][event] = nil;
				self.addonCallbacks[addon].CallPriority[index] = nil
				E.callbacks:Fire(event)
			end
		end
		return
	end

	if not E.initialized then return end

	if self.addonsToLoad[addon] then
		self.addonsToLoad[addon]()
		self.addonsToLoad[addon] = nil
	elseif self.addonCallbacks[addon] then
		for index, event in ipairs(self.addonCallbacks[addon].CallPriority) do
			self.addonCallbacks[addon][event] = nil;
			self.addonCallbacks[addon].CallPriority[index] = nil
			E.callbacks:Fire(event)
		end
	end
end

--Old deprecated register function. Keep it for the time being for any plugins that may need it.
function S:RegisterSkin(name, loadFunc, forceLoad, bypass)
	if bypass then
		self.allowBypass[name] = true;
	end

	if forceLoad then
		loadFunc()
		self.addonsToLoad[name] = nil;
	elseif name == 'ElvUI' then
		tinsert(self.nonAddonsToLoad, loadFunc)
	else
		self.addonsToLoad[name] = loadFunc;
	end
end

--Add callback for skin that relies on another addon.
--These events will be fired when the addon is loaded.
function S:AddCallbackForAddon(addonName, eventName, loadFunc, forceLoad, bypass)
	if not addonName or type(addonName) ~= "string" then
		E:Print("Invalid argument #1 to S:AddCallbackForAddon (string expected)")
		return
	elseif not eventName or type(eventName) ~= "string" then
		E:Print("Invalid argument #2 to S:AddCallbackForAddon (string expected)")
		return
	elseif not loadFunc or type(loadFunc) ~= "function" then
		E:Print("Invalid argument #3 to S:AddCallbackForAddon (function expected)")
		return
	end

	if bypass then
		self.allowBypass[addonName] = true;
	end

	--Create an event registry for this addon, so that we can fire multiple events when this addon is loaded
	if not self.addonCallbacks[addonName] then
		self.addonCallbacks[addonName] = {["CallPriority"] = {}}
	end

	if self.addonCallbacks[addonName][eventName] or E.ModuleCallbacks[eventName] or E.InitialModuleCallbacks[eventName] then
		--Don't allow a registered callback to be overwritten
		E:Print("Invalid argument #2 to S:AddCallbackForAddon (event name:", eventName, "is already registered, please use a unique event name)")
		return
	end

	--Register loadFunc to be called when event is fired
	E.RegisterCallback(E, eventName, loadFunc)

	if forceLoad then
		E.callbacks:Fire(eventName)
	else
		--Insert eventName in this addons' registry
		self.addonCallbacks[addonName][eventName] = true
		self.addonCallbacks[addonName].CallPriority[#self.addonCallbacks[addonName].CallPriority + 1] = eventName
	end
end

--Add callback for skin that does not rely on a another addon.
--These events will be fired when the Skins module is initialized.
function S:AddCallback(eventName, loadFunc)
	if not eventName or type(eventName) ~= "string" then
		E:Print("Invalid argument #1 to S:AddCallback (string expected)")
		return
	elseif not loadFunc or type(loadFunc) ~= "function" then
		E:Print("Invalid argument #2 to S:AddCallback (function expected)")
		return
	end

	if self.nonAddonCallbacks[eventName] or E.ModuleCallbacks[eventName] or E.InitialModuleCallbacks[eventName] then
		--Don't allow a registered callback to be overwritten
		E:Print("Invalid argument #1 to S:AddCallback (event name:", eventName, "is already registered, please use a unique event name)")
		return
	end

	--Add event name to registry
	self.nonAddonCallbacks[eventName] = true
	self.nonAddonCallbacks.CallPriority[#self.nonAddonCallbacks.CallPriority + 1] = eventName

	--Register loadFunc to be called when event is fired
	E.RegisterCallback(E, eventName, loadFunc)
end

function S:Initialize()
	self.db = E.private.skins

	--Fire events for Blizzard addons that are already loaded
	for addon in pairs(self.addonCallbacks) do
		if IsAddOnLoaded(addon) then
			for index, event in ipairs(S.addonCallbacks[addon].CallPriority) do
				self.addonCallbacks[addon][event] = nil;
				self.addonCallbacks[addon].CallPriority[index] = nil
				E.callbacks:Fire(event)
			end
		end
	end
	--Fire event for all skins that doesn't rely on a Blizzard addon
	for index, event in ipairs(self.nonAddonCallbacks.CallPriority) do
		self.nonAddonCallbacks[event] = nil;
		self.nonAddonCallbacks.CallPriority[index] = nil
		E.callbacks:Fire(event)
	end

	--Old deprecated load functions. We keep this for the time being in case plugins make use of it.
	for addon, loadFunc in pairs(self.addonsToLoad) do
		if IsAddOnLoaded(addon) then
			self.addonsToLoad[addon] = nil;
			local _, catch = pcall(loadFunc)
			if(catch and GetCVarBool('scriptErrors') == true) then
				ScriptErrorsFrame:OnError(catch, false, false)
			end
		end
	end

	for _, loadFunc in pairs(self.nonAddonsToLoad) do
		local _, catch = pcall(loadFunc)
		if(catch and GetCVarBool('scriptErrors') == true) then
			ScriptErrorsFrame:OnError(catch, false, false)
		end
	end
	wipe(self.nonAddonsToLoad)
end

S:RegisterEvent('ADDON_LOADED')

local function InitializeCallback()
	S:Initialize()
end

E:RegisterModule(S:GetName(), InitializeCallback)
