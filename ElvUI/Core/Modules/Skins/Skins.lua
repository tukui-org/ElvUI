local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local LibStub = _G.LibStub

local _G = _G
local hooksecurefunc = hooksecurefunc
local unpack, type, gsub, rad, strfind = unpack, type, gsub, rad, strfind
local tinsert, xpcall, next, ipairs, pairs = tinsert, xpcall, next, ipairs, pairs

local CreateFrame = CreateFrame
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

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
	'BorderBottom',
	'BorderBottomLeft',
	'BorderBottomRight',
	'BorderLeft',
	'BorderRight',
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
		if button.IsSkinned then return end

		if button.SetNormalTexture then button:SetNormalTexture(E.ClearTexture) end
		if button.SetHighlightTexture then button:SetHighlightTexture(E.ClearTexture) end
		if button.SetPushedTexture then button:SetPushedTexture(E.ClearTexture) end
		if button.SetDisabledTexture then button:SetDisabledTexture(E.ClearTexture) end

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

		button.IsSkinned = true
	end
end

do
	local NavBarCheck = {
		EncounterJournal = function()
			return S.db.blizzard.encounterjournal
		end,
		WorldMapFrame = function()
			return S.db.blizzard.worldmap
		end,
		HelpFrameKnowledgebase = function()
			return S.db.blizzard.help
		end
	}

	local function NavButtonXOffset(button, point, anchor, point2, _, yoffset, skip)
		if not skip then
			button:Point(point, anchor, point2, 1, yoffset, true)
		end
	end

	function S:SkinNavBarButton(button, index)
		if button and not button.IsSkinned then
			S:HandleButton(button, true)
			button:GetFontString():SetTextColor(1, 1, 1)

			local arrow = button.MenuArrowButton
			if arrow then
				arrow:StripTextures()

				local art = arrow.Art
				if art then
					art:SetTexture(E.Media.Textures.ArrowUp)
					art:SetTexCoord(0, 1, 0, 1)
					art:SetRotation(3.14)
				end
			end

			-- setting the xoffset will cause a taint, use the hook below instead to lock the xoffset to 1
			if index > 1 then
				NavButtonXOffset(button, button:GetPoint())
				hooksecurefunc(button, 'SetPoint', NavButtonXOffset)
			end

			button.IsSkinned = true
		end
	end

	function S:HandleNavBarButtons(data)
		local func = NavBarCheck[self:GetParent():GetName()]
		if func and not func() then return end

		if not data then -- init call
			for index, nav in next, self.navList do
				S:SkinNavBarButton(nav, index)
			end
		else
			local lastIndex = #self.navList
			S:SkinNavBarButton(self.navList[lastIndex], lastIndex)
		end
	end
end

function S:ClearSetTexture(texture)
	if texture ~= E.ClearTexture then
		self:SetTexture(E.ClearTexture)
	end
end

function S:ClearNormalTexture(texture)
	if texture ~= E.ClearTexture then
		self:SetNormalTexture(E.ClearTexture)
	end
end

function S:ClearPushedTexture(texture)
	if texture ~= E.ClearTexture then
		self:SetPushedTexture(E.ClearTexture)
	end
end

function S:ClearDisabledTexture(texture)
	if texture ~= E.ClearTexture then
		self:SetDisabledTexture(E.ClearTexture)
	end
end

function S:ClearHighlightTexture(texture)
	if texture ~= E.ClearTexture then
		self:SetHighlightTexture(E.ClearTexture)
	end
end

function S:ClearCheckedTexture(texture)
	if texture ~= E.ClearTexture then
		self:SetCheckedTexture(E.ClearTexture)
	end
end

function S:HandleButtonHighlight(frame, r, g, b)
	if frame.SetHighlightTexture then
		frame:SetHighlightTexture(E.ClearTexture)
	end

	if not frame.highlightGradient then
		local width, h = frame:GetSize()
		local height = h * 0.95

		local gradient = frame:CreateTexture(nil, 'HIGHLIGHT')
		gradient:SetTexture(E.Media.Textures.Highlight)
		gradient:Point('LEFT', frame)
		gradient:Size(width, height)

		frame.highlightGradient = gradient
	end

	if not r then r = 0.9 end
	if not g then g = 0.9 end
	if not b then b = 0.9 end

	frame.highlightGradient:SetVertexColor(r, g, b, 0.3)
end

function S:HandleFrame(frame, setBackdrop, template, x1, y1, x2, y2)
	local name = frame and frame.GetName and frame:GetName()
	local insetFrame = name and _G[name..'Inset'] or frame.Inset
	local portraitFrame = name and _G[name..'Portrait'] or frame.Portrait or frame.portrait
	local portraitFrameOverlay = name and _G[name..'PortraitOverlay'] or frame.PortraitOverlay
	local artFrameOverlay = name and _G[name..'ArtOverlayFrame'] or frame.ArtOverlayFrame
	local closeButton = frame.CloseButton or name and _G[name..'CloseButton']

	frame:StripTextures()

	if portraitFrame then portraitFrame:SetAlpha(0) end
	if portraitFrameOverlay then portraitFrameOverlay:SetAlpha(0) end
	if artFrameOverlay then artFrameOverlay:SetAlpha(0) end

	if insetFrame then
		S:HandleInsetFrame(insetFrame)
	end

	if closeButton then
		S:HandleCloseButton(closeButton)
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
function S:HandlePortraitFrame(frame, createBackdrop, noStrip)
	local name = frame and frame.GetName and frame:GetName()

	local insetFrame = name and _G[name..'Inset'] or frame.Inset
	local portraitFrame = name and _G[name..'Portrait'] or frame.Portrait
	local portraitFrameOverlay = name and _G[name..'PortraitOverlay'] or frame.PortraitOverlay
	local artFrameOverlay = name and _G[name..'ArtOverlayFrame'] or frame.ArtOverlayFrame
	local portraitFrameAlt = frame.portrait -- blizzard uses the same global name on two frames

	if not noStrip then
		frame:StripTextures()

		if portraitFrame then portraitFrame:SetAlpha(0) end
		if portraitFrameOverlay then portraitFrameOverlay:SetAlpha(0) end
		if portraitFrameAlt then portraitFrameAlt:SetAlpha(0) end
		if artFrameOverlay then artFrameOverlay:SetAlpha(0) end

		if insetFrame then
			S:HandleInsetFrame(insetFrame)
		end
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

do
	local hookedFrames = {}
	function S:StaticPopup_OnShow() -- UpdateRecapButton is created OnShow
		if self.UpdateRecapButton and not hookedFrames[self] then
			hookedFrames[self] = true

			hooksecurefunc(self, 'UpdateRecapButton', S.StaticPopup_UpdateRecapButton)
		end
	end
end

function S:StaticPopup_UpdateRecapButton()
	-- when UpdateRecapButton runs and enables the button, it unsets OnEnter
	-- we need to reset it with ours. blizzard will replace it when the button
	-- is disabled. so, we don't have to worry about anything else.

	local button = self.button4
	if button and button:IsEnabled() then
		button:SetScript('OnEnter', S.SetModifiedBackdrop)
		button:SetScript('OnLeave', S.SetOriginalBackdrop)
	end
end

function S:StaticPopup_HandleButton(button)
	S:HandleButton(button)

	button:OffsetFrameLevel(1)
	button:CreateShadow(5)
	button.shadow:SetAlpha(0)
	button.shadow:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	button.Flash:Hide()

	local anim1, anim2 = button.PulseAnim:GetAnimations()
	anim1:SetTarget(button.shadow)
	anim2:SetTarget(button.shadow)
end

function S:HandleStaticPopup(popup)
	if not popup then return end

	popup:StripTextures()
	popup:SetTemplate('Transparent')
	popup:HookScript('OnShow', S.StaticPopup_OnShow)

	local i = 1
	local button = E:StaticPopup_GetElement(popup, 'Button'..i)
	while button do
		S:StaticPopup_HandleButton(button)

		i = i + 1
		button = E:StaticPopup_GetElement(popup, 'Button'..i)
	end

	local closeButton = E:StaticPopup_GetElement(popup, 'CloseButton')
	if closeButton then
		S:HandleCloseButton(closeButton)
	end

	local moneyInputFrame = E:StaticPopup_GetElement(popup, 'MoneyInputFrame')
	if moneyInputFrame then
		S:HandleEditBox(moneyInputFrame.gold)
		S:HandleEditBox(moneyInputFrame.silver)
		S:HandleEditBox(moneyInputFrame.copper)
	end

	local editBox = E:StaticPopup_GetElement(popup, 'EditBox')
	if editBox then
		S:HandleEditBox(editBox)
		editBox:OffsetFrameLevel(1)
	end

	local itemFrame = E:StaticPopup_GetElement(popup, 'ItemFrame')
	if itemFrame then
		local itemFrameNameFrame = itemFrame.NameFrame or E:StaticPopup_GetElement(popup, 'ItemFrameNameFrame')
		if itemFrameNameFrame then
			itemFrameNameFrame:StripTextures()
		end

		local item = itemFrame.Item or itemFrame
		S:HandleItemButton(item, true)
		S:HandleIconBorder(item.IconBorder, item.backdrop)

		local normalTexture = item:GetNormalTexture()
		if normalTexture then
			normalTexture:SetTexture()

			hooksecurefunc(normalTexture, 'SetTexture', S.ClearSetTexture)
		end
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

do -- DropDownMenu library support
	local function HandleBackdrop(frame)
		local dropdown = (frame and frame.NineSlice) or frame
		if dropdown and not dropdown.template then
			dropdown:SetTemplate('Transparent')
		end
	end

	local function CreateHandler(key)
		return function()
			local lvls = _G[(key == 'Lib' and 'LIB' or key)..'_UIDROPDOWNMENU_MAXLEVELS'] or 1
			for i = 1, lvls do
				HandleBackdrop(_G[key..'_DropDownList'..i..'Backdrop'])
				HandleBackdrop(_G[key..'_DropDownList'..i..'MenuBackdrop'])
			end
		end
	end

	function S:SkinLibDropDownMenu(prefix)
		if S[prefix..'_UIDropDownMenuSkinned'] then return end

		local key = (prefix == 'L4' or prefix == 'L3') and 'L' or prefix

		HandleBackdrop(_G[key..'_DropDownList1Backdrop'])
		HandleBackdrop(_G[key..'_DropDownList1MenuBackdrop'])

		S[prefix..'_UIDropDownMenuSkinned'] = true

		local func = CreateHandler(key)
		local name = key..'_UIDropDownMenu_CreateFrames'
		local lib = prefix == 'L4' and LibStub.libs['LibUIDropDownMenu-4.0']
		if lib and lib.UIDropDownMenu_CreateFrames then
			hooksecurefunc(lib, 'UIDropDownMenu_CreateFrames', func)
		elseif _G[name] then
			hooksecurefunc(_G, name, func)
		end
	end
end

do -- WIM replaces Blizzard globals we need to rehook
	S.DropDownMenu_Hooks = {}

	function S:DropDownMenu_SkinMenu(prefix, name)
		local backdrop = prefix and _G[name]
		if not backdrop then return end

		if backdrop.NineSlice then
			backdrop = backdrop.NineSlice
		end

		if not backdrop.template then
			backdrop:SetTemplate('Transparent')
		end
	end

	function S:DropDownMenu_CreateFrames(prefix, level, index)
		local listFrame = prefix and level and _G[prefix..level]
		if not listFrame then return end

		local listName = listFrame:GetName()
		if not listName then return end

		local expandArrow = _G[listName..'Button'..index..'ExpandArrow']
		if expandArrow then
			expandArrow:SetNormalTexture(E.Media.Textures.ArrowUp)
			expandArrow:Size(12)

			local normTex = expandArrow:GetNormalTexture()
			if normTex then
				normTex:SetVertexColor(unpack(E.media.rgbvaluecolor))
				normTex:SetRotation(S.ArrowRotation.right)
			end
		end

		S:DropDownMenu_SkinMenu(prefix, listName..'Backdrop')
		S:DropDownMenu_SkinMenu(prefix, listName..'MenuBackdrop')
	end

	function S:DropDownMenu_SetIconImage(prefix, icon, texture)
		if not (prefix and icon and texture) or not strfind(texture, 'Divider') then return end

		local r, g, b = unpack(E.media.rgbvaluecolor)
		icon:SetColorTexture(r, g, b, 0.45)
		icon:Height(1)
	end

	function S:DropDownMenu_Toggle(prefix, level, textX, textY)
		if not prefix then return end

		if not level then level = 1 end
		local r, g, b = unpack(E.media.rgbvaluecolor)

		for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
			local indexName = level..'Button'..i

			local name = prefix..indexName
			local button = _G[name]
			if not button then -- fallback to blizzards
				name = 'DropDownList'..indexName
				button = _G[name]
			end

			if not button then return end -- bail out

			local highlight = _G[name..'Highlight']
			if highlight then
				highlight:SetTexture(E.Media.Textures.Highlight)
				highlight:SetBlendMode('BLEND')
				highlight:SetDrawLayer('BACKGROUND')
				highlight:SetVertexColor(r, g, b)
			end

			if not button.backdrop then
				button:CreateBackdrop()
			end

			local check = _G[name..'Check']
			if not button.notCheckable then
				local text = _G[name..'NormalText']
				if text then
					text:PointXY(textX or 5, textY)
				end

				local uncheck = _G[name..'UnCheck']
				if uncheck then
					uncheck:SetTexture()
				end

				if check then
					if S.db.checkBoxSkin then
						check:SetTexture(E.media.normTex)
						check:SetVertexColor(r, g, b, 1)
						check:Size(10)
						check:SetDesaturated(false)
						button.backdrop:SetOutside(check)
					else
						check:SetTexture([[Interface\Buttons\UI-CheckBox-Check]])
						check:SetVertexColor(r, g, b, 1)
						check:Size(20)
						check:SetDesaturated(true)
						button.backdrop:SetInside(check, 4, 4)
					end

					check:SetTexCoord(0, 1, 0, 1)
				end

				button.backdrop:Show()
			else
				if check then
					check:Size(16)
				end

				button.backdrop:Hide()
			end
		end
	end

	function S:SkinDropDownMenu(prefix, textX, textY)
		if S.DropDownMenu_Hooks[prefix] then return end
		S.DropDownMenu_Hooks[prefix] = true

		hooksecurefunc('UIDropDownMenu_CreateFrames', function(level, index) S:DropDownMenu_CreateFrames(prefix, level, index) end)
		hooksecurefunc('UIDropDownMenu_SetIconImage', function(icon, texture) S:DropDownMenu_SetIconImage(prefix, icon, texture) end)
		hooksecurefunc('ToggleDropDownMenu', function(level) S:DropDownMenu_Toggle(prefix, level, textX, textY) end)
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

function S:SkinReadyDialog(dialog, bottom)
	local background = dialog.background
	if background then
		background:ClearAllPoints()
		background:Point('TOPLEFT', E.Border, -E.Border)
		background:Point('BOTTOMRIGHT', -E.Border, bottom or 50)

		dialog:CreateBackdrop('Transparent', nil, nil, true) -- just for art so pixel mode it
		dialog.backdrop:SetOutside(background)
		dialog.backdrop.Center:Hide()
	end

	if dialog.bottomArt then
		dialog.bottomArt:SetAlpha(0)
	end

	if dialog.Border then -- use backdrop cause we need it a level behind
		dialog.Border:StripTextures()
		dialog.Border:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, true)
	end

	local instance = dialog.instanceInfo
	if instance and instance.underline then
		instance.underline:SetAlpha(0)
	end

	if dialog.enterButton then
		S:HandleButton(dialog.enterButton)

		dialog.enterButton:ClearAllPoints()
		dialog.enterButton:Point('BOTTOMRIGHT', dialog, 'BOTTOM', -10, 15)
	end

	if dialog.leaveButton then
		S:HandleButton(dialog.leaveButton)

		dialog.leaveButton:ClearAllPoints()
		dialog.leaveButton:Point('BOTTOMLEFT', dialog, 'BOTTOM', 10, 15)
	end
end

do
	local ITEMQUALITY = Enum.ItemQuality
	local iconColors = {
		['auctionhouse-itemicon-border-gray']		= ITEMQUALITY.Poor,
		['auctionhouse-itemicon-border-white']		= ITEMQUALITY.Common,
		['auctionhouse-itemicon-border-green']		= ITEMQUALITY.Uncommon,
		['auctionhouse-itemicon-border-blue']		= ITEMQUALITY.Rare,
		['auctionhouse-itemicon-border-purple']		= ITEMQUALITY.Epic,
		['auctionhouse-itemicon-border-orange']		= ITEMQUALITY.Legendary,
		['auctionhouse-itemicon-border-artifact']	= ITEMQUALITY.Artifact,
		['auctionhouse-itemicon-border-account']	= ITEMQUALITY.Heirloom,

		['Professions-Slot-Frame']					= ITEMQUALITY.Common,
		['Professions-Slot-Frame-Green']			= ITEMQUALITY.Uncommon,
		['Professions-Slot-Frame-Blue']				= ITEMQUALITY.Rare,
		['Professions-Slot-Frame-Epic']				= ITEMQUALITY.Epic,
		['Professions-Slot-Frame-Legendary']		= ITEMQUALITY.Legendary
	}

	local function ColorAtlas(border, atlas)
		local quality = iconColors[atlas]
		if not quality then return end

		local r, g, b = E:GetItemQualityColor(iconColors[atlas])

		if border.customFunc then
			local br, bg, bb = unpack(E.media.bordercolor)
			border.customFunc(border, r, g, b, 1, br, bg, bb)
		elseif border.customBackdrop then
			border.customBackdrop:SetBackdropBorderColor(r, g, b)
		end
	end

	local function ColorVertex(border, r, g, b, a)
		local quality = iconColors[border:GetAtlas()]
		if quality then return end

		if border.customFunc then
			local br, bg, bb = unpack(E.media.bordercolor)
			border.customFunc(border, r, g, b, a, br, bg, bb)
		elseif border.customBackdrop then
			border.customBackdrop:SetBackdropBorderColor(r, g, b)
		end
	end

	local function BorderHide(border, value)
		if value == 0 then return end -- hiding blizz border

		local br, bg, bb = unpack(E.media.bordercolor)
		if border.customFunc then
			local r, g, b, a = border:GetVertexColor()
			border.customFunc(border, r, g, b, a, br, bg, bb)
		elseif border.customBackdrop then
			border.customBackdrop:SetBackdropBorderColor(br, bg, bb)
		end
	end

	local function BorderShow(border)
		border:Hide(0)
	end

	local function BorderShown(border, show)
		if show then
			border:Hide(0)
		else
			BorderHide(border)
		end
	end

	function S:HandleIconBorder(border, backdrop, customFunc)
		if not backdrop then
			local parent = border:GetParent()
			backdrop = parent.backdrop or parent
		end

		local r, g, b, a = border:GetVertexColor()
		local quality = iconColors[border:GetAtlas()]
		local atlas = quality and E:GetQualityColor(quality)
		if customFunc then
			border.customFunc = customFunc
			local br, bg, bb = unpack(E.media.bordercolor)
			customFunc(border, r, g, b, a, br, bg, bb)
		elseif atlas then
			backdrop:SetBackdropBorderColor(atlas.r, atlas.g, atlas.b, 1)
		elseif r then
			backdrop:SetBackdropBorderColor(r, g, b, a)
		else
			local br, bg, bb = unpack(E.media.bordercolor)
			backdrop:SetBackdropBorderColor(br, bg, bb)
		end

		if border.customBackdrop ~= backdrop then
			border.customBackdrop = backdrop
		end

		if not border.IconBorderHooked then
			border.IconBorderHooked = true
			border:Hide()

			hooksecurefunc(border, 'SetAtlas', ColorAtlas)
			hooksecurefunc(border, 'SetVertexColor', ColorVertex)
			hooksecurefunc(border, 'SetShown', BorderShown)
			hooksecurefunc(border, 'Show', BorderShow)
			hooksecurefunc(border, 'Hide', BorderHide)
		end
	end
end

do
	local keys = {
		'zoomInButton',
		'zoomOutButton',
		'rotateLeftButton',
		'rotateRightButton',
		'resetButton',
	}

	local function UpdateLayout(frame)
		local last
		for _, name in next, keys do
			local button = frame[name]
			if button then
				if not button.IsSkinned then
					S:HandleButton(button)
					button:Size(22)

					if button.Icon then
						button.Icon:SetInside(nil, 2, 2)
					end
				end

				if button:IsShown() then
					button:ClearAllPoints()

					if last then
						button:Point('LEFT', last, 'RIGHT', 1, 0)
					else
						button:Point('LEFT', 6, 0)
					end

					last = button
				end
			end
		end
	end

	function S:HandleModelSceneControlButtons(frame)
		if not frame.IsSkinned then
			frame.IsSkinned = true

			hooksecurefunc(frame, 'UpdateLayout', UpdateLayout)
		end
	end
end

do
	local arrowDegree = { up = 0, down = 180, left = 90, right = -90 }
	function S:SetupArrow(tex, direction)
		if not tex then return end

		tex:SetTexture(E.Media.Textures.ArrowUp)
		tex:SetRotation(rad(arrowDegree[direction]))
	end
end

do
	local overlays = {}

	local function OverlayHide(button)
		local overlay = overlays[button]
		if not overlay then return end

		overlay:Hide()
	end

	local function OverlayShow(button)
		local overlay = overlays[button]
		if not overlay then return end

		overlay:ClearAllPoints()
		overlay:SetPoint(button:GetPoint())
		overlay:Show()
	end

	local function OverlayOnEnter(button)
		local overlay = overlays[button]
		if not overlay then return end

		overlay.text:SetTextColor(1, 1, 1)
		S:SetBackdropBorderColor(overlay, 'OnEnter')
	end

	local function OverlayOnLeave(button)
		local overlay = overlays[button]
		if not overlay then return end

		overlay.text:SetTextColor(1, 0.81, 0)
		S:SetBackdropBorderColor(overlay, 'OnLeave')
	end

	function S:OverlayButton(button, name, width, height, text, textLayer, level, strata)
		if overlays[button] then return end -- already exists

		local overlay = CreateFrame('Frame', 'ElvUI_OverlayButton_'..name, E.UIParent)
		overlay:Size(width or 120, height or 22) -- dont use GetSize it can taint the owner
		overlay:SetTemplate(nil, true)
		overlay:SetPoint(button:GetPoint())
		overlay:SetFrameLevel(level or 10)
		overlay:SetFrameStrata(strata or 'MEDIUM')
		overlay:Hide()

		local txt = overlay:CreateFontString(nil, textLayer or 'OVERLAY')
		txt:SetPoint('CENTER')
		txt:FontTemplate()
		txt:SetText(text)
		txt:SetTextColor(1, 0.81, 0)
		overlay.text = txt

		button:HookScript('OnEnter', OverlayOnEnter)
		button:HookScript('OnLeave', OverlayOnLeave)
		button:HookScript('OnHide', OverlayHide)
		button:HookScript('OnShow', OverlayShow)

		overlays[button] = overlay
	end
end

function S:HandleButton(button, strip, isDecline, noStyle, createBackdrop, template, noGlossTex, overrideTex, frameLevel, regionsKill, regionsZero, isFilterButton, filterDirection)
	if button.IsSkinned then return end

	if button.SetNormalTexture and not overrideTex then button:SetNormalTexture(E.ClearTexture) end
	if button.SetHighlightTexture then button:SetHighlightTexture(E.ClearTexture) end
	if button.SetPushedTexture then button:SetPushedTexture(E.ClearTexture) end
	if button.SetDisabledTexture then button:SetDisabledTexture(E.ClearTexture) end

	if strip then button:StripTextures() end
	if button.Texture then button.Texture:SetAlpha(0) end

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

	if isFilterButton then
		local arrow = button:CreateTexture(nil, 'ARTWORK')
		arrow:Size(10)
		arrow:ClearAllPoints()
		arrow:Point('RIGHT', -1, 0)

		if filterDirection then
			S:SetupArrow(arrow, filterDirection)
		end
	end

	button.IsSkinned = true
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

		if frame.Texture then
			frame.Texture:SetAlpha(0)

			if frame.Overlay then
				frame.Overlay:SetAlpha(0)
			end
		else
			frame:StripTextures()
		end
	end

	local function ThumbOnEnter(frame)
		local r, g, b = unpack(E.media.rgbvaluecolor)
		local thumb = frame.thumb or frame
		if thumb.backdrop then
			thumb.backdrop:SetBackdropColor(r, g, b, .75)
		end
	end

	local function ThumbOnLeave(frame)
		local r, g, b = unpack(E.media.rgbvaluecolor)
		local thumb = frame.thumb or frame

		if thumb.backdrop and not thumb.__isActive then
			thumb.backdrop:SetBackdropColor(r, g, b, .25)
		end
	end

	local function ThumbOnMouseDown(frame)
		local r, g, b = unpack(E.media.rgbvaluecolor)
		local thumb = frame.thumb or frame
		thumb.__isActive = true

		if thumb.backdrop then
			thumb.backdrop:SetBackdropColor(r, g, b, .75)
		end
	end

	local function ThumbOnMouseUp(frame)
		local r, g, b = unpack(E.media.rgbvaluecolor)
		local thumb = frame.thumb or frame
		thumb.__isActive = nil

		if thumb.backdrop then
			thumb.backdrop:SetBackdropColor(r, g, b, .25)
		end
	end

	function S:HandleTrimScrollBar(frame, ignoreUpdates)
		frame:StripTextures()

		ReskinScrollBarArrow(frame.Back, 'up')
		ReskinScrollBarArrow(frame.Forward, 'down')

		if frame.Background then
			frame.Background:Hide()
		end

		local track = frame.Track
		if track then
			track:DisableDrawLayer('ARTWORK')
		end

		local thumb = frame:GetThumb()
		if thumb then
			thumb:DisableDrawLayer('ARTWORK')
			thumb:DisableDrawLayer('BACKGROUND')

			if not thumb.backdrop then
				thumb:CreateBackdrop('Transparent', nil, ignoreUpdates)

				thumb:HookScript('OnEnter', ThumbOnEnter)
				thumb:HookScript('OnLeave', ThumbOnLeave)
				thumb:HookScript('OnMouseUp', ThumbOnMouseUp)
				thumb:HookScript('OnMouseDown', ThumbOnMouseDown)
			end

			local r, g, b = unpack(E.media.rgbvaluecolor)
			thumb.backdrop:SetBackdropColor(r, g, b, .25)
			thumb.backdrop:OffsetFrameLevel(1, thumb)
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

			local spacing = E.Retail and 3 or 10
			tab.backdrop:Point('TOPLEFT', spacing, E.PixelMode and -1 or -3)
			tab.backdrop:Point('BOTTOMRIGHT', -spacing, 3)
		end
	end
end

function S:HandleRotateButton(frame, width, height, noSize)
	if frame.IsSkinned then return end

	if not noSize then
		frame:Size(width or 24, height or 24)
	end

	frame:SetTemplate()

	local left = strfind(frame:GetDebugName(), 'Left')
	local rotate = left and 'common-icon-rotateleft' or 'common-icon-rotateright'

	local normTex = frame:GetNormalTexture()
	if normTex then
		normTex:SetInside()
		normTex:SetAtlas(rotate)
		normTex:SetTexCoord(0.05, 1.05, -0.05, 1)
	end

	local pushTex = frame:GetPushedTexture()
	if pushTex then
		pushTex:SetAllPoints(normTex)
		pushTex:SetAtlas(rotate)
		pushTex:SetTexCoord(0, 1, -0.1, 0.95)
	end

	local highlightTex = frame:GetHighlightTexture()
	if highlightTex then
		highlightTex:SetAllPoints(normTex)
		highlightTex:SetColorTexture(1, 1, 1, 0.3)
	end

	frame.IsSkinned = true
end

do
	local btns = {MaximizeButton = 'up', MinimizeButton = 'down'}

	local function ButtonOnEnter(btn)
		local r,g,b = unpack(E.media.rgbvaluecolor)
		btn:GetNormalTexture():SetVertexColor(r,g,b)
		btn:GetPushedTexture():SetVertexColor(r,g,b)
	end
	local function ButtonOnLeave(btn)
		btn:GetNormalTexture():SetVertexColor(1, 1, 1)
		btn:GetPushedTexture():SetVertexColor(1, 1, 1)
	end

	function S:HandleMaxMinFrame(frame)
		if frame.IsSkinned then return end

		frame:StripTextures(true)

		for name, direction in pairs(btns) do
			local button = frame[name]
			if button then
				button:Size(14)
				button:ClearAllPoints()
				button:Point('CENTER')
				button:SetHitRectInsets(1, 1, 1, 1)
				button:GetHighlightTexture():Kill()

				button:SetScript('OnEnter', ButtonOnEnter)
				button:SetScript('OnLeave', ButtonOnLeave)

				button:SetNormalTexture(E.Media.Textures.ArrowUp)
				button:GetNormalTexture():SetRotation(S.ArrowRotation[direction])

				button:SetPushedTexture(E.Media.Textures.ArrowUp)
				button:GetPushedTexture():SetRotation(S.ArrowRotation[direction])
			end
		end

		frame.IsSkinned = true
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
	if frame.backdrop then return end

	frame:CreateBackdrop(template, nil, nil, nil, nil, nil, nil, nil, true)

	S:HandleBlizzardRegions(frame)

	if frame.NineSlice then
		frame.NineSlice:StripTextures()

		frame.backdrop:SetInside(frame.NineSlice)
	else
		local name = frame:GetDebugName()
		local gold, silver, copper = strfind(name, 'Gold'), strfind(name, 'Silver'), strfind(name, 'Copper')
		if gold or silver or copper then
			if E.Retail then
				frame.backdrop:Point('TOPLEFT', -4, 0)
				frame.backdrop:Point('BOTTOMRIGHT')
			elseif frame.label then -- send mail, popups, and others
				frame.backdrop:Point('TOPLEFT', -4, 2)
				frame.backdrop:Point('BOTTOMRIGHT', (gold and 20) or 10, -2)
			else -- auctionhouse sell tab and others
				frame.backdrop:Point('TOPLEFT', 4, -4)
				frame.backdrop:Point('BOTTOMRIGHT', -4, 6)
			end
		else
			local popup = strfind(name, 'StaticPopup')
			frame.backdrop:Point('TOPLEFT', -4, popup and -4 or 0)
			frame.backdrop:Point('BOTTOMRIGHT', 4, popup and 4 or 0)
		end
	end
end

function S:HandleDropDownBox(frame, width, template, old)
	if not width then
		width = 155
	end

	frame:Width(width)
	frame:StripTextures(true)

	if not frame.backdrop then
		frame:CreateBackdrop(template)
		frame:OffsetFrameLevel(2)
	end

	if not old then
		if frame.Arrow then -- most dropdowns
			frame.Arrow:SetAlpha(0)
		end

		if frame.Button then -- Classic Anniversary LFG dropdown
			frame.Button:SetAlpha(0)
		end

		frame.backdrop:Point('TOPLEFT', 0, -2)
		frame.backdrop:Point('BOTTOMRIGHT', 0, 2)

		local tex = frame:CreateTexture(nil, 'ARTWORK')
		tex:SetTexture(E.Media.Textures.ArrowUp)
		tex:SetRotation(3.14)
		tex:Point('RIGHT', frame.backdrop, -3, 0)
		tex:Size(14)
	else
		local frameName = frame.GetName and frame:GetName()
		local button = frame.Button or frameName and (_G[frameName..'Button'] or _G[frameName..'_Button'])
		local text = frameName and _G[frameName..'Text'] or frame.Text
		local icon = frame.Icon

		frame.backdrop:Point('TOPLEFT', 20, -2)
		frame.backdrop:Point('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 2, -2)

		button:ClearAllPoints()
		button:Point('RIGHT', frame, 'RIGHT', -10, 3)

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
end

function S:HandleStatusBar(frame, color, template)
	frame:OffsetFrameLevel(1)
	frame:StripTextures()
	frame:CreateBackdrop(template or 'Transparent')
	frame:SetStatusBarTexture(E.media.normTex)
	frame:SetStatusBarColor(unpack(color or {.01, .39, .1}))
	E:RegisterStatusBar(frame)
end

function S:ForEachCheckboxTextureRegion(checkbox, func)
	for _, region in next, { checkbox:GetRegions() } do
		if region:IsObjectType('Texture') then
			func(checkbox, region)
		end
	end
end

do
	local check = [[Interface\Buttons\UI-CheckBox-Check]]
	local disabled = [[Interface\Buttons\UI-CheckBox-Check-Disabled]]

	local function CheckCheckedTexture(checkbox, texture)
		if texture == E.Media.Textures.Melli or texture == check then return end
		checkbox:SetCheckedTexture(S.db.checkBoxSkin and E.Media.Textures.Melli or check)
	end

	local function CheckOnDisable(checkbox)
		if not checkbox.SetDisabledTexture then return end
		checkbox:SetDisabledTexture(checkbox:GetChecked() and (S.db.checkBoxSkin and E.Media.Textures.Melli or disabled) or '')
	end

	function S:HandleCheckBox(frame, noBackdrop, noReplaceTextures, frameLevel, template)
		if frame.IsSkinned then return end

		frame:StripTextures()

		if noBackdrop then
			frame:Size(16)
		else
			frame:CreateBackdrop(template, nil, nil, nil, nil, nil, nil, nil, frameLevel)
			frame.backdrop:SetInside(nil, 4, 4)
		end

		if not noReplaceTextures then
			if frame.SetCheckedTexture then
				if S.db.checkBoxSkin then
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
				if S.db.checkBoxSkin then
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

			frame:HookScript('OnDisable', CheckOnDisable)

			hooksecurefunc(frame, 'SetCheckedTexture', CheckCheckedTexture)
			hooksecurefunc(frame, 'SetNormalTexture', S.ClearNormalTexture)
			hooksecurefunc(frame, 'SetPushedTexture', S.ClearPushedTexture)
			hooksecurefunc(frame, 'SetHighlightTexture', S.ClearHighlightTexture)
		end

		frame.IsSkinned = true
	end
end

do
	local background = [[Interface\Minimap\UI-Minimap-Background]]

	function S:HandleRadioButton(Button)
		if Button.IsSkinned then return end

		local InsideMask = Button:CreateMaskTexture()
		InsideMask:SetTexture(background, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		InsideMask:Size(10)
		InsideMask:Point('CENTER')
		Button.InsideMask = InsideMask

		local OutsideMask = Button:CreateMaskTexture()
		OutsideMask:SetTexture(background, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
		OutsideMask:Size(13)
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

		hooksecurefunc(Button, 'SetNormalTexture', S.ClearNormalTexture)
		hooksecurefunc(Button, 'SetPushedTexture', S.ClearPushedTexture)
		hooksecurefunc(Button, 'SetDisabledTexture', S.ClearDisabledTexture)
		hooksecurefunc(Button, 'SetHighlightTexture', S.ClearHighlightTexture)

		Button.IsSkinned = true
	end
end

function S:ReplaceIconString(text)
	if not text then text = self:GetText() end
	if not text or text == '' then return end

	local newText, count = gsub(text, '|T([^:]-):[%d+:]+|t', '|T%1:14:14:0:0:64:64:5:59:5:59|t')
	if count > 0 then self:SetFormattedText('%s', newText) end
end

function S:HandleIcon(icon, backdrop)
	icon:SetTexCoord(unpack(E.TexCoords))

	if backdrop and not icon.backdrop then
		icon:CreateBackdrop()
	end
end

function S:HandleItemButton(b, setInside)
	if b.IsSkinned then return end

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

	b.IsSkinned = true
end

do
	local closeOnEnter = function(btn) if btn.Texture then btn.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor)) end end
	local closeOnLeave = function(btn) if btn.Texture then btn.Texture:SetVertexColor(1, 1, 1) end end

	function S:HandleCloseButton(f, point, x, y)
		if f.IsSkinned then return end

		f:StripTextures()

		if not f.Texture then
			f.Texture = f:CreateTexture(nil, 'OVERLAY')
			f.Texture:Point('CENTER')
			f.Texture:SetTexture(E.Media.Textures.Close)
			f.Texture:Size(12)
			f:HookScript('OnEnter', closeOnEnter)
			f:HookScript('OnLeave', closeOnLeave)
			f:SetHitRectInsets(6, 6, 7, 7)
		end

		if point then
			f:Point('TOPRIGHT', point, 'TOPRIGHT', x or 2, y or 2)
		end

		f.IsSkinned = true
	end

	function S:HandleNextPrevButton(btn, arrowDir, color, noBackdrop, stripTexts, frameLevel, buttonSize)
		if btn.IsSkinned then return end

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
			S:HandleButton(btn, nil, nil, true, nil, nil, nil, nil, frameLevel)
		end

		if stripTexts then
			btn:StripTexts()
		end

		btn:SetNormalTexture(E.Media.Textures.ArrowUp)
		btn:SetPushedTexture(E.Media.Textures.ArrowUp)
		btn:SetDisabledTexture(E.Media.Textures.ArrowUp)

		local Normal, Disabled, Pushed = btn:GetNormalTexture(), btn:GetDisabledTexture(), btn:GetPushedTexture()

		btn:Size(buttonSize or (noBackdrop and 20 or 18))

		if noBackdrop then
			Disabled:SetVertexColor(.5, .5, .5)
			btn.Texture = Normal

			if not color then
				btn:HookScript('OnEnter', closeOnEnter)
				btn:HookScript('OnLeave', closeOnLeave)
			end
		else
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

		btn.IsSkinned = true
	end
end

function S:HandleSliderFrame(frame, template, frameLevel)
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

		for _, region in next, { frame:GetRegions() } do
			if region:IsObjectType('FontString') then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if strfind(anchorPoint, 'BOTTOM') then
					region:Point(point, anchor, anchorPoint, x, y - 4)
				end
			end
		end
	end
end

-- ToDO: DF => UpdateME => Credits: NDUI
local sparkTexture = [[Interface\CastingBar\UI-CastingBar-Spark]]
function S:HandleStepSlider(frame, minimal)
	frame:StripTextures()

	local slider = frame.Slider
	if not slider then return end

	slider:DisableDrawLayer('ARTWORK')

	local thumb = slider.Thumb
	if thumb then
		thumb:SetTexture(sparkTexture)
		thumb:SetBlendMode('ADD')
		thumb:SetSize(20, 30)
	end

	local offset = minimal and 10 or 13
	slider:CreateBackdrop()
	slider.backdrop:SetPoint('TOPLEFT', 10, -offset)
	slider.backdrop:SetPoint('BOTTOMRIGHT', -10, offset)

	if not slider.barStep then
		local step = CreateFrame('StatusBar', nil, slider.backdrop)
		step:SetStatusBarTexture(E.Media.Textures.Melli)
		step:SetStatusBarColor(1, .8, 0, .5)
		step:SetPoint('TOPLEFT', slider.backdrop, E.mult, -E.mult)
		step:SetPoint('BOTTOMLEFT', slider.backdrop, E.mult, E.mult)
		step:SetPoint('RIGHT', thumb, 'CENTER')

		slider.barStep = step
	end
end

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
	local r, g, b = E:GetItemQualityColor(followerInfo.quality)
	self.Portrait.backdrop:SetBackdropBorderColor(r, g, b)
end

do
	S.FollowerListUpdateDataFrames = {}

	local function UpdateFollower(button)
		if not E.Retail then
			button:SetTemplate(button.mode == 'CATEGORY' and 'NoBackdrop' or 'Transparent')
		end

		local category = button.Category
		if category then
			category:ClearAllPoints()
			category:Point('TOP', button, 'TOP', 0, -4)
		end

		local follower = button.Follower
		if follower then
			if not follower.template then
				follower:SetTemplate('Transparent')
				follower.Name:SetWordWrap(false)
				follower.Selection:SetTexture()
				follower.AbilitiesBG:SetTexture()
				follower.BusyFrame:SetAllPoints()
				follower.BG:Hide()

				local hl = follower:GetHighlightTexture()
				hl:SetColorTexture(0.9, 0.9, 0.9, 0.25)
				hl:SetInside()
			end

			local counters = follower.Counters
			if counters then
				for _, counter in next, counters do
					if not counter.template then
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

			local portrait = follower.PortraitFrame
			if portrait then
				S:HandleGarrisonPortrait(portrait, true)

				portrait:ClearAllPoints()
				portrait:Point('TOPLEFT', 3, -3)

				if not follower.PortraitFrameStyled then
					hooksecurefunc(portrait, 'SetupPortrait', UpdateFollowerQuality)
					follower.PortraitFrameStyled = true
				end

				if portrait.backdrop then
					local r, g, b = E:GetItemQualityColor(portrait.quality or (follower.info and follower.info.quality))
					portrait.backdrop:SetBackdropBorderColor(r, g, b)
				end
			end

			if follower.Selection then
				if follower.Selection:IsShown() then
					follower:SetBackdropColor(0.9, 0.8, 0.1, 0.25)
				else
					follower:SetBackdropColor(0, 0, 0, 0.5)
				end
			end
		end
	end

	function S:HandleFollowerListOnUpdateDataFunc(buttons, numButtons, offset, numFollowers)
		if not buttons or (not numButtons or numButtons == 0) or not offset or not numFollowers then return end

		for i = 1, numButtons do
			local button = buttons[i]
			if button then
				local index = offset + i -- adjust index
				if index <= numFollowers then
					UpdateFollower(button)
				end
			end
		end
	end

	local function UpdateListScroll(dataFrame)
		if not (dataFrame and dataFrame.listScroll) or not S.FollowerListUpdateDataFrames[dataFrame:GetName()] then return end

		local buttons = dataFrame.listScroll.buttons
		local offset = _G.HybridScrollFrame_GetOffset(dataFrame.listScroll)
		S:HandleFollowerListOnUpdateDataFunc(buttons, buttons and #buttons, offset, dataFrame.listScroll and #dataFrame.listScroll)
	end

	function S:HandleFollowerListOnUpdateData(frame)
		if frame == 'GarrisonLandingPageFollowerList' and (not S.db.blizzard.orderhall or not S.db.blizzard.garrison) then
			return -- Only hook this frame if both Garrison and Orderhall skins are enabled because it's shared.
		end

		if S.FollowerListUpdateDataFrames[frame] then return end -- make sure we don't double hook `GarrisonLandingPageFollowerList`
		S.FollowerListUpdateDataFrames[frame] = true

		if _G.GarrisonFollowerList_InitButton then
			hooksecurefunc(_G, 'GarrisonFollowerList_InitButton', UpdateFollower)
		else
			hooksecurefunc(_G[frame], 'UpdateData', UpdateListScroll) -- pre DF
		end
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

function S:HandleGarrisonPortrait(portrait, updateAtlas)
	local main = portrait.Portrait
	if not main then return end

	if not main.backdrop then
		main:CreateBackdrop('Transparent')
	end

	local level = portrait.Level or portrait.LevelText
	if level then
		level:ClearAllPoints()
		level:Point('BOTTOM', portrait, 0, 15)
		level:FontTemplate(nil, 14, 'OUTLINE')

		if portrait.LevelCircle then portrait.LevelCircle:Hide() end
		if portrait.LevelBorder then portrait.LevelBorder:SetScale(.0001) end
	end

	if portrait.PortraitRing then
		portrait.PortraitRing:Hide()
		portrait.PortraitRingQuality:SetTexture(E.ClearTexture)
		portrait.PortraitRingCover:SetColorTexture(0, 0, 0)
		portrait.PortraitRingCover:SetAllPoints(main.backdrop)
	end

	if portrait.Empty then
		portrait.Empty:SetColorTexture(0, 0, 0)
		portrait.Empty:SetAllPoints(main)
	end

	if portrait.Highlight then portrait.Highlight:Hide() end
	if portrait.PuckBorder then portrait.PuckBorder:SetAlpha(0) end
	if portrait.TroopStackBorder1 then portrait.TroopStackBorder1:SetAlpha(0) end
	if portrait.TroopStackBorder2 then portrait.TroopStackBorder2:SetAlpha(0) end

	if portrait.HealthBar then
		portrait.HealthBar.Border:Hide()

		local roleIcon = portrait.HealthBar.RoleIcon
		roleIcon:ClearAllPoints()
		roleIcon:Point('CENTER', main.backdrop, 'TOPRIGHT')

		if updateAtlas then
			HandleFollowerRole(roleIcon, roleIcon:GetAtlas())
		else
			hooksecurefunc(roleIcon, 'SetAtlas', HandleFollowerRole)
		end

		local background = portrait.HealthBar.Background
		background:SetAlpha(0)
		background:SetInside(main.backdrop, 2, 1) -- unsnap it
		background:Point('TOPLEFT', main.backdrop, 'BOTTOMLEFT', 2, 7)
		portrait.HealthBar.Health:SetTexture(E.media.normTex)
	end
end

do
	local function SelectionOffset(frame)
		local point, anchor, relativePoint, xOffset = frame:GetPoint()
		if xOffset <= 0 then
			local x = frame.BorderBox and 4 or 38 -- adjust values for wrath
			local y = frame.BorderBox and 0 or -10

			frame:ClearAllPoints()
			frame:Point(point, (frame == _G.MacroPopupFrame and _G.MacroFrame) or anchor, relativePoint, strfind(point, 'LEFT') and x or -x, y)
		end
	end

	local function HandleButton(button, i, buttonNameTemplate)
		local icon, texture = button.Icon or _G[buttonNameTemplate..i..'Icon']
		if icon then
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetInside(button)
			texture = icon:GetTexture() -- keep this before strip textures
		end

		button:StripTextures()
		button:SetTemplate()
		button:StyleButton(nil, true)

		if texture then
			icon:SetTexture(texture)
		end
	end

	function S:HandleIconSelectionFrame(frame, numIcons, buttonNameTemplate, nameOverride, dontOffset)
		if frame.IsSkinned then return end

		if not dontOffset then -- place it off to the side of parent with correct offsets
			frame:HookScript('OnShow', SelectionOffset)
			frame:Height(frame:GetHeight() + 10)
		end

		local borderBox = frame.BorderBox or _G.BorderBox -- it's a sub frame only on retail, on wrath it's a global?
		local frameName = nameOverride or frame:GetName() -- we need override in case Blizzard fucks up the naming (guild bank)
		local scrollFrame = frame.ScrollFrame or (frameName and _G[frameName..'ScrollFrame'])
		local editBox = (borderBox and borderBox.IconSelectorEditBox) or frame.EditBox or (frameName and _G[frameName..'EditBox'])
		local cancel = frame.CancelButton or (borderBox and borderBox.CancelButton) or (frameName and _G[frameName..'Cancel'])
		local okay = frame.OkayButton or (borderBox and borderBox.OkayButton) or (frameName and _G[frameName..'Okay'])

		frame:StripTextures()
		frame:SetTemplate('Transparent')

		if borderBox then
			borderBox:StripTextures()

			local dropdown = borderBox.IconTypeDropdown or (borderBox.IconTypeDropDown and borderBox.IconTypeDropDown.DropDownMenu)
			if dropdown then
				S:HandleDropDownBox(dropdown)
			end

			local button = borderBox.SelectedIconArea and borderBox.SelectedIconArea.SelectedIconButton
			if button then
				button:DisableDrawLayer('BACKGROUND')
				S:HandleItemButton(button, true)
			end
		end

		cancel:ClearAllPoints()
		cancel:SetPoint('BOTTOMRIGHT', frame, -4, 4)
		S:HandleButton(cancel)

		okay:ClearAllPoints()
		okay:SetPoint('RIGHT', cancel, 'LEFT', -10, 0)
		S:HandleButton(okay)

		if editBox then
			editBox:DisableDrawLayer('BACKGROUND')
			S:HandleEditBox(editBox)
		end

		if numIcons then
			if scrollFrame then
				scrollFrame:StripTextures()
				scrollFrame:Height(scrollFrame:GetHeight() + 10)
				S:HandleScrollBar(scrollFrame.ScrollBar)
			end

			for i = 1, numIcons do
				local button = _G[buttonNameTemplate..i]
				if button then
					HandleButton(button, i, buttonNameTemplate)
				end
			end
		else
			S:HandleTrimScrollBar(frame.IconSelector.ScrollBar)

			frame.IconSelector.ScrollBox:ForEachFrame(HandleButton)
		end

		frame.IsSkinned = true
	end
end

do -- Handle collapse
	local function UpdateCollapseTexture(button, texture, skip)
		if skip or not texture then return end

		if type(texture) == 'number' then
			if texture == 130838 then -- Interface\Buttons\UI-PlusButton-UP
				button:SetNormalTexture(E.Media.Textures.PlusButton, true)
			elseif texture == 130821 then -- Interface\Buttons\UI-MinusButton-UP
				button:SetNormalTexture(E.Media.Textures.MinusButton, true)
			end
		elseif strfind(texture, 'Plus') or strfind(texture, 'Closed') then
			button:SetNormalTexture(E.Media.Textures.PlusButton, true)
		elseif strfind(texture, 'Minus') or strfind(texture, 'Open') then
			button:SetNormalTexture(E.Media.Textures.MinusButton, true)
		end
	end

	local function SyncPushTexture(button, _, skip)
		if skip then return end

		local normal = button:GetNormalTexture():GetTexture()
		button:SetPushedTexture(normal, true)
	end

	function S:HandleCollapseTexture(button, syncPushed, ignorePushed)
		if button.collapsedSkinned then return end
		button.collapsedSkinned = true -- little bit of a safety precaution

		if syncPushed then -- not needed always
			hooksecurefunc(button, 'SetPushedTexture', SyncPushTexture)
			SyncPushTexture(button)
		elseif not ignorePushed then
			button:SetPushedTexture(E.ClearTexture)
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
	local function HandleBar(bar)
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
		HandleBar(widgetFrame.LeftBar)
		HandleBar(widgetFrame.RightBar)
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
	if not S.allowBypass[addonName] and not E.initialized then
		return
	end

	local object = S.addonsToLoad[addonName]
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

function S:RegisterSkin(addonName, func, forceLoad, bypass, position)
	if bypass then
		S.allowBypass[addonName] = true
	end

	if forceLoad then
		E:CallLoadFunc(func)

		S.addonsToLoad[addonName] = nil
	elseif addonName == 'ElvUI' then
		if position then
			tinsert(S.nonAddonsToLoad, position, func)
		else
			tinsert(S.nonAddonsToLoad, func)
		end
	else
		local addon = S.addonsToLoad[addonName]
		if not addon then
			S.addonsToLoad[addonName] = {}
			addon = S.addonsToLoad[addonName]
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
		E:CallLoadFunc(func)
	end

	S.addonsToLoad[addonName] = nil
end

function S:UpdateAllWidgets()
	for _, widget in pairs(_G.UIWidgetTopCenterContainerFrame.widgetFrames) do
		S:SkinWidgetContainer(widget)
	end
end

function S:Initialize()
	S.Initialized = true

	for index, func in next, S.nonAddonsToLoad do
		E:CallLoadFunc(func)

		S.nonAddonsToLoad[index] = nil
	end

	for addonName, object in pairs(S.addonsToLoad) do
		local isLoaded, isFinished = IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			S:CallLoadedAddon(addonName, object)
		end
	end

	-- Early Skin Handling (populated before ElvUI is loaded from the Ace3 file)
	if S.db.ace3Enable and S.EarlyAceWidgets then
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

	if S.db.libDropdown and S.EarlyDropdowns then
		for _, n in next, S.EarlyDropdowns do
			if n == 'LibDropDownMenu_List' then
				S:SkinDropDownMenu(n, 15)
			else
				S:SkinLibDropDownMenu(n)
			end
		end
	end

	if E.Retail and S.db.blizzard.enable and S.db.blizzard.misc then
		S:RegisterEvent('PLAYER_ENTERING_WORLD', 'UpdateAllWidgets')
		S:RegisterEvent('UPDATE_ALL_UI_WIDGETS', 'UpdateAllWidgets')
	end
end

-- Keep this outside, it's used for skinning addons before ElvUI load
S:RegisterEvent('ADDON_LOADED')

E:RegisterModule(S:GetName())
