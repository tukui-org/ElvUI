local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

--Lua functions
local _G = _G
local unpack, type, select, getmetatable, assert, pairs = unpack, type, select, getmetatable, assert, pairs
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
-- GLOBALS: CUSTOM_CLASS_COLORS

local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0

-- ls, Azil, and Simpy made this to replace Blizzard's SetBackdrop API while the textures can't snap
local BackdropBorders = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}

local function customSetBackdrop(frame, giveBorder, bgFile, edgeSize, insetLeft, insetRight, insetTop, insetBottom)
	if not frame.pixelBorders then return end

	if not giveBorder then
		for _, v in pairs(BackdropBorders) do
			frame.pixelBorders[v]:Hide()
		end
	end

	frame.pixelBorders.CENTER:SetTexture(bgFile)

	if not (giveBorder or bgFile) then return end

	if insetLeft or insetRight or insetTop or insetBottom then
		frame.pixelBorders.CENTER:SetPoint('TOPLEFT', frame, 'TOPLEFT', -insetLeft or 0, insetTop or 0)
		frame.pixelBorders.CENTER:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', insetRight or 0, -insetBottom or 0)
	else
		frame.pixelBorders.CENTER:SetPoint('TOPLEFT', frame)
		frame.pixelBorders.CENTER:SetPoint('BOTTOMRIGHT', frame)
	end

	frame.pixelBorders.TOPLEFT:SetSize(edgeSize, edgeSize)
	frame.pixelBorders.TOPRIGHT:SetSize(edgeSize, edgeSize)
	frame.pixelBorders.BOTTOMLEFT:SetSize(edgeSize, edgeSize)
	frame.pixelBorders.BOTTOMRIGHT:SetSize(edgeSize, edgeSize)

	frame.pixelBorders.TOP:SetHeight(edgeSize)
	frame.pixelBorders.BOTTOM:SetHeight(edgeSize)
	frame.pixelBorders.LEFT:SetWidth(edgeSize)
	frame.pixelBorders.RIGHT:SetWidth(edgeSize)
end

local function customBackdropColor(frame, r, g, b, a)
	if frame.pixelBorders then
		frame.pixelBorders.CENTER:SetVertexColor(r, g, b, a)
	end
end

local function customBackdropBorderColor(frame, r, g, b, a)
	if frame.pixelBorders then
		for _, v in pairs(BackdropBorders) do
			frame.pixelBorders[v]:SetColorTexture(r or 0, g or 0, b or 0, a)
		end
	end
end

local function buildPixelBorders(frame, noSecureHook)
	if frame and not frame.pixelBorders then
		local borders = {}

		for _, v in pairs(BackdropBorders) do
			borders[v] = frame:CreateTexture("$parentPixelBorder"..v, "BORDER", nil, 1)
			borders[v]:SetSnapToPixelGrid(false)
			borders[v]:SetTexelSnappingBias(0)
		end

		borders.CENTER = frame:CreateTexture("$parentPixelBorderCENTER", "BACKGROUND", nil, 0)
		borders.CENTER:SetSnapToPixelGrid(false)
		borders.CENTER:SetTexelSnappingBias(0)

		borders.TOPLEFT:Point("BOTTOMRIGHT", borders.CENTER, "TOPLEFT", 1, -1)
		borders.TOPRIGHT:Point("BOTTOMLEFT", borders.CENTER, "TOPRIGHT", -1, -1)
		borders.BOTTOMLEFT:Point("TOPRIGHT", borders.CENTER, "BOTTOMLEFT", 1, 1)
		borders.BOTTOMRIGHT:Point("TOPLEFT", borders.CENTER, "BOTTOMRIGHT", -1, 1)

		borders.TOP:Point("TOPLEFT", borders.TOPLEFT, "TOPRIGHT", 0, 0)
		borders.TOP:Point("TOPRIGHT", borders.TOPRIGHT, "TOPLEFT", 0, 0)

		borders.BOTTOM:Point("BOTTOMLEFT", borders.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
		borders.BOTTOM:Point("BOTTOMRIGHT", borders.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

		borders.LEFT:Point("TOPLEFT", borders.TOPLEFT, "BOTTOMLEFT", 0, 0)
		borders.LEFT:Point("BOTTOMLEFT", borders.BOTTOMLEFT, "TOPLEFT", 0, 0)

		borders.RIGHT:Point("TOPRIGHT", borders.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
		borders.RIGHT:Point("BOTTOMRIGHT", borders.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

		if not noSecureHook then
			hooksecurefunc(frame, "SetBackdropColor", customBackdropColor)
			hooksecurefunc(frame, "SetBackdropBorderColor", customBackdropBorderColor)
		end

		frame.pixelBorders = borders
	end
end
-- end backdrop replace code

local function GetTemplate(t, isUnitFrameElement)
	backdropa = 1

	if t == 'ClassColor' then
		local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]
		borderr, borderg, borderb = color.r, color.g, color.b
		backdropr, backdropg, backdropb = unpack(E.media.backdropcolor)
	elseif t == 'Transparent' then
		borderr, borderg, borderb = unpack(isUnitFrameElement and E.media.unitframeBorderColor or E.media.bordercolor)
		backdropr, backdropg, backdropb, backdropa = unpack(E.media.backdropfadecolor)
	else
		borderr, borderg, borderb = unpack(isUnitFrameElement and E.media.unitframeBorderColor or E.media.bordercolor)
		backdropr, backdropg, backdropb = unpack(E.media.backdropcolor)
	end
end

local function Size(frame, width, height, ...)
	assert(width)
	frame:SetSize(E:Scale(width), E:Scale(height or width), ...)
end

local function Width(frame, width, ...)
	assert(width)
	frame:SetWidth(E:Scale(width), ...)
end

local function Height(frame, height, ...)
	assert(height)
	frame:SetHeight(E:Scale(height), ...)
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5, ...)
	if arg2 == nil then arg2 = obj:GetParent() end

	if type(arg2)=='number' then arg2 = E:Scale(arg2) end
	if type(arg3)=='number' then arg3 = E:Scale(arg3) end
	if type(arg4)=='number' then arg4 = E:Scale(arg4) end
	if type(arg5)=='number' then arg5 = E:Scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5, ...)
end

local function SetOutside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or E.Border
	yOffset = yOffset or E.Border
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:Point('TOPLEFT', anchor, 'TOPLEFT', -xOffset, yOffset)
	obj:Point('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or E.Border
	yOffset = yOffset or E.Border
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:Point('TOPLEFT', anchor, 'TOPLEFT', xOffset, -yOffset)
	obj:Point('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', -xOffset, yOffset)
end

local function SetTemplate(f, t, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
	GetTemplate(t, isUnitFrameElement)

	f.template = t or 'Default'
	if glossTex then f.glossTex = glossTex end
	if ignoreUpdates then f.ignoreUpdates = ignoreUpdates end
	if forcePixelMode then f.forcePixelMode = forcePixelMode end
	if isUnitFrameElement then f.isUnitFrameElement = isUnitFrameElement end

	f:SetBackdrop(nil)
	buildPixelBorders(f, ignoreUpdates)

	if t == 'NoBackdrop' then
		customSetBackdrop(f)
	else
		customSetBackdrop(f, true, glossTex and (type(glossTex) == 'string' and glossTex or E.media.glossTex) or E.media.blankTex, (not E.twoPixelsPlease and E.mult) or E.mult*2)

		if not f.ignoreBackdropColors then
			if t == 'Transparent' then
				customBackdropColor(f, backdropr, backdropg, backdropb, backdropa)
			else
				customBackdropColor(f, backdropr, backdropg, backdropb, 1)
			end
		end

		if not E.PixelMode and not f.forcePixelMode then
			if not f.iborder then
				local border = CreateFrame('Frame', nil, f)
				buildPixelBorders(border, true)
				customSetBackdrop(border, true, nil, E.mult, -E.mult, -E.mult, -E.mult, -E.mult)
				customBackdropBorderColor(border, 0, 0, 0, 1)
				border:SetAllPoints()
				f.iborder = border
			end

			if not f.oborder then
				local border = CreateFrame('Frame', nil, f)
				buildPixelBorders(border, true)
				customSetBackdrop(border, true, nil, E.mult, E.mult, E.mult, E.mult, E.mult)
				customBackdropBorderColor(border, 0, 0, 0, 1)
				border:SetAllPoints()
				f.oborder = border
			end
		end
	end

	if not f.ignoreBorderColors then
		customBackdropBorderColor(f, borderr, borderg, borderb)
	end

	if not f.ignoreUpdates then
		if f.isUnitFrameElement then
			E.unitFrameElements[f] = true
		else
			E.frames[f] = true
		end
	end
end

local function CreateBackdrop(f, t, tex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
	local parent = (f.IsObjectType and f:IsObjectType('Texture') and f:GetParent()) or f
	local b = CreateFrame('Frame', nil, parent)
	f.backdrop = b

	if f.forcePixelMode or forcePixelMode then
		b:SetOutside(f, E.mult, E.mult)
	else
		b:SetOutside(f)
	end
	b:SetTemplate(t, tex, ignoreUpdates, forcePixelMode, isUnitFrameElement)

	local frameLevel = parent.GetFrameLevel and parent:GetFrameLevel()
	local frameLevelMinusOne = frameLevel and (frameLevel - 1)
	if frameLevelMinusOne and (frameLevelMinusOne >= 0) then
		b:SetFrameLevel(frameLevelMinusOne)
	else
		b:SetFrameLevel(0)
	end
end

local function CreateShadow(f, size)
	if f.shadow then return end
	backdropr, backdropg, backdropb, borderr, borderg, borderb = 0, 0, 0, 0, 0, 0

	local shadow = CreateFrame('Frame', nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetOutside(f, size or 3, size or 3)
	shadow:SetBackdrop({edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(size or 3)})
	shadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.9)
	f.shadow = shadow
end

local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(E.HiddenFrame)
	else
		object.Show = object.Hide
	end

	object:Hide()
end

local StripTexturesBlizzFrames = {
	'Inset',
	'inset',
	'InsetFrame',
	'LeftInset',
	'RightInset',
	'NineSlice',
	'BorderFrame',
	'bottomInset',
	'BottomInset',
	'bgLeft',
	'bgRight',
	'FilligreeOverlay',
	'PortraitOverlay',
	'ArtOverlayFrame',
	'Portrait',
	'portrait',
}

local STRIP_TEX = 'Texture'
local STRIP_FONT = 'FontString'
local function StripRegion(which, object, kill, alpha)
	if kill then
		object:Kill()
	elseif alpha then
		object:SetAlpha(0)
	elseif which == STRIP_TEX then
		object:SetTexture()
	elseif which == STRIP_FONT then
		object:SetText('')
	end
end

local function StripType(which, object, kill, alpha)
	if object:IsObjectType(which) then
		StripRegion(which, object, kill, alpha)
	else
		if which == STRIP_TEX then
			local FrameName = object.GetName and object:GetName()
			for _, Blizzard in pairs(StripTexturesBlizzFrames) do
				local BlizzFrame = object[Blizzard] or (FrameName and _G[FrameName..Blizzard])
				if BlizzFrame then
					BlizzFrame:StripTextures(kill, alpha)
				end
			end
		end

		if object.GetNumRegions then
			for i = 1, object:GetNumRegions() do
				local region = select(i, object:GetRegions())
				if region and region.IsObjectType and region:IsObjectType(which) then
					StripRegion(which, region, kill, alpha)
				end
			end
		end
	end
end

local function StripTextures(object, kill, alpha)
	StripType(STRIP_TEX, object, kill, alpha)
end

local function StripTexts(object, kill, alpha)
	StripType(STRIP_FONT, object, kill, alpha)
end

local function FontTemplate(fs, font, fontSize, fontStyle)
	fs.font = font
	fs.fontSize = fontSize
	fs.fontStyle = fontStyle

	font = font or LSM:Fetch('font', E.db.general.font)
	fontSize = fontSize or E.db.general.fontSize
	fontStyle = fontStyle or E.db.general.fontStyle

	if fontStyle == 'OUTLINE' and E.db.general.font == 'Homespun' and (fontSize > 10 and not fs.fontSize) then
		fontSize, fontStyle = 10, 'MONOCHROMEOUTLINE'
	end

	fs:SetFont(font, fontSize, fontStyle)
	fs:SetShadowColor(0, 0, 0, (fontStyle and fontStyle ~= 'NONE' and 0.2) or 1)
	fs:SetShadowOffset(E.mult or 1, -(E.mult or 1))

	E.texts[fs] = true
end

local function StyleButton(button, noHover, noPushed, noChecked)
	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetSnapToPixelGrid(false)
		hover:SetTexelSnappingBias(0)
		hover:SetInside()
		hover:SetColorTexture(1, 1, 1, 0.3)
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetSnapToPixelGrid(false)
		pushed:SetTexelSnappingBias(0)
		pushed:SetInside()
		pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		button:SetPushedTexture(pushed)
		button.pushed = pushed
	end

	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetSnapToPixelGrid(false)
		checked:SetTexelSnappingBias(0)
		checked:SetInside()
		checked:SetColorTexture(1, 1, 1, 0.3)
		button:SetCheckedTexture(checked)
		button.checked = checked
	end

	local name = button.GetName and button:GetName()
	local cooldown = name and _G[name..'Cooldown']
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetInside()
		cooldown:SetDrawEdge(false)
		cooldown:SetSwipeColor(0, 0, 0, 1)
	end
end

local CreateCloseButton
do
	local CloseButtonOnClick = function(btn) btn:GetParent():Hide() end
	local CloseButtonOnEnter = function(btn) if btn.Texture then btn.Texture:SetVertexColor(unpack(E.media.rgbvaluecolor)) end end
	local CloseButtonOnLeave = function(btn) if btn.Texture then btn.Texture:SetVertexColor(1, 1, 1) end end
	CreateCloseButton = function(frame, size, offset, texture, backdrop)
		local CloseButton = CreateFrame('Button', nil, frame)
		CloseButton:Size(size or 16)
		CloseButton:Point('TOPRIGHT', offset or -6, offset or -6)
		if backdrop then
			CloseButton:CreateBackdrop(nil, true)
		end

		CloseButton.Texture = CloseButton:CreateTexture(nil, 'OVERLAY')
		CloseButton.Texture:SetAllPoints()
		CloseButton.Texture:SetTexture(texture or E.Media.Textures.Close)

		CloseButton:SetScript('OnClick', CloseButtonOnClick)
		CloseButton:SetScript('OnEnter', CloseButtonOnEnter)
		CloseButton:SetScript('OnLeave', CloseButtonOnLeave)

		frame.CloseButton = CloseButton
	end
end

local function GetNamedChild(frame, childName, index)
	local name = frame and frame.GetName and frame:GetName()
	if not name or not childName then return nil end
	return _G[name..childName..(index or '')]
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.Size then mt.Size = Size end
	if not object.Point then mt.Point = Point end
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.Kill then mt.Kill = Kill end
	if not object.Width then mt.Width = Width end
	if not object.Height then mt.Height = Height end
	if not object.FontTemplate then mt.FontTemplate = FontTemplate end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.StripTexts then mt.StripTexts = StripTexts end
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.CreateCloseButton then mt.CreateCloseButton = CreateCloseButton end
	if not object.GetNamedChild then mt.GetNamedChild = GetNamedChild end
end

local handled = {['Frame'] = true}
local object = CreateFrame('Frame')
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())
addapi(object:CreateMaskTexture())

object = EnumerateFrames()
while object do
	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

--Add API to `CreateFont` objects without actually creating one
addapi(_G.GameFontNormal)

--Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the "Frame" widget
local scrollFrame = CreateFrame('ScrollFrame')
addapi(scrollFrame)
