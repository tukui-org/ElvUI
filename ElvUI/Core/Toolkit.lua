local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

--Lua functions
local _G = _G
local unpack, type, select, getmetatable, assert, pairs, pcall = unpack, type, select, getmetatable, assert, pairs, pcall
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0

-- 8.2 restricted frame check
function E:PointsRestricted(frame)
	if frame and not pcall(frame.GetPoint, frame) then
		return true
	end
end

function E:SafeGetPoint(frame)
	if frame and frame.GetPoint and not E:PointsRestricted(frame) then
		return frame:GetPoint()
	end
end

-- ls, Azil, and Simpy made this to replace Blizzard's SetBackdrop API while the textures can't snap
E.PixelBorders = {'TOPLEFT', 'TOPRIGHT', 'BOTTOMLEFT', 'BOTTOMRIGHT', 'TOP', 'BOTTOM', 'LEFT', 'RIGHT'}
function E:SetBackdrop(frame, giveBorder, bgFile, edgeSize, insetLeft, insetRight, insetTop, insetBottom)
	if not frame.pixelBorders then return end

	if not giveBorder then
		E:TogglePixelBorders(frame)
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

function E:GetBackdropColor(frame)
	if frame.pixelBorders then
		return frame.pixelBorders.CENTER:GetVertexColor()
	else
		return frame:GetBackdropColor()
	end
end

function E:GetBackdropBorderColor(frame)
	if frame.pixelBorders then
		return frame.pixelBorders.TOP:GetVertexColor()
	else
		return frame:GetBackdropBorderColor()
	end
end

function E:SetBackdropColor(frame, r, g, b, a)
	if frame.pixelBorders then
		frame.pixelBorders.CENTER:SetVertexColor(r, g, b, a)
	end
end

function E:SetBackdropBorderColor(frame, r, g, b, a)
	if frame.pixelBorders then
		for _, v in pairs(E.PixelBorders) do
			frame.pixelBorders[v]:SetVertexColor(r or 0, g or 0, b or 0, a)
		end
	end
end

function E:HookedSetBackdropColor(r, g, b, a)
	E:SetBackdropColor(self, r, g, b, a)
end

function E:HookedSetBackdropBorderColor(r, g, b, a)
	E:SetBackdropBorderColor(self, r, g, b, a)
end

function E:TogglePixelBorders(frame, show)
	if frame.pixelBorders then
		for _, v in pairs(E.PixelBorders) do
			if show then
				frame.pixelBorders[v]:Show()
			else
				frame.pixelBorders[v]:Hide()
			end
		end
	end
end

function E:BuildPixelBorders(frame, noSecureHook)
	if frame and not frame.pixelBorders then
		local borders = {}

		for _, v in pairs(E.PixelBorders) do
			borders[v] = frame:CreateTexture('$parentPixelBorder'..v, 'BORDER', nil, 1)
			borders[v]:SetTexture(E.media.blankTex)
		end

		borders.CENTER = frame:CreateTexture('$parentPixelBorderCENTER', 'BACKGROUND', nil, -1)

		borders.TOPLEFT:Point('BOTTOMRIGHT', borders.CENTER, 'TOPLEFT', 1, -1)
		borders.TOPRIGHT:Point('BOTTOMLEFT', borders.CENTER, 'TOPRIGHT', -1, -1)
		borders.BOTTOMLEFT:Point('TOPRIGHT', borders.CENTER, 'BOTTOMLEFT', 1, 1)
		borders.BOTTOMRIGHT:Point('TOPLEFT', borders.CENTER, 'BOTTOMRIGHT', -1, 1)

		borders.TOP:Point('TOPLEFT', borders.TOPLEFT, 'TOPRIGHT', 0, 0)
		borders.TOP:Point('TOPRIGHT', borders.TOPRIGHT, 'TOPLEFT', 0, 0)

		borders.BOTTOM:Point('BOTTOMLEFT', borders.BOTTOMLEFT, 'BOTTOMRIGHT', 0, 0)
		borders.BOTTOM:Point('BOTTOMRIGHT', borders.BOTTOMRIGHT, 'BOTTOMLEFT', 0, 0)

		borders.LEFT:Point('TOPLEFT', borders.TOPLEFT, 'BOTTOMLEFT', 0, 0)
		borders.LEFT:Point('BOTTOMLEFT', borders.BOTTOMLEFT, 'TOPLEFT', 0, 0)

		borders.RIGHT:Point('TOPRIGHT', borders.TOPRIGHT, 'BOTTOMRIGHT', 0, 0)
		borders.RIGHT:Point('BOTTOMRIGHT', borders.BOTTOMRIGHT, 'TOPRIGHT', 0, 0)

		if not noSecureHook then
			hooksecurefunc(frame, 'SetBackdropColor', E.HookedSetBackdropColor)
			hooksecurefunc(frame, 'SetBackdropBorderColor', E.HookedSetBackdropBorderColor)
		end

		frame.pixelBorders = borders
	end
end
-- end backdrop replace code

local function WatchPixelSnap(frame, snap)
	if (frame and not frame:IsForbidden()) and frame.PixelSnapDisabled and snap then
		frame.PixelSnapDisabled = nil
	end
end

local function DisablePixelSnap(frame)
	if (frame and not frame:IsForbidden()) and not frame.PixelSnapDisabled then
		if frame.SetSnapToPixelGrid then
			frame:SetSnapToPixelGrid(false)
			frame:SetTexelSnappingBias(0)
		elseif frame.GetStatusBarTexture then
			local texture = frame:GetStatusBarTexture()
			if texture and texture.SetSnapToPixelGrid then
				texture:SetSnapToPixelGrid(false)
				texture:SetTexelSnappingBias(0)
			end
		end

		frame.PixelSnapDisabled = true
	end
end

local function GetTemplate(template, isUnitFrameElement)
	backdropa = 1

	if template == 'ClassColor' then
		local color = _G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[E.myclass] or _G.RAID_CLASS_COLORS[E.myclass]
		borderr, borderg, borderb = color.r, color.g, color.b
		backdropr, backdropg, backdropb = unpack(E.media.backdropcolor)
	elseif template == 'Transparent' then
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
	if E:PointsRestricted(obj) or obj:GetPoint() then
		obj:ClearAllPoints()
	end

	DisablePixelSnap(obj)
	obj:Point('TOPLEFT', anchor, 'TOPLEFT', -xOffset, yOffset)
	obj:Point('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or E.Border
	yOffset = yOffset or E.Border
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if E:PointsRestricted(obj) or obj:GetPoint() then
		obj:ClearAllPoints()
	end

	DisablePixelSnap(obj)
	obj:Point('TOPLEFT', anchor, 'TOPLEFT', xOffset, -yOffset)
	obj:Point('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', -xOffset, yOffset)
end

local function SetTemplate(frame, template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
	GetTemplate(template, isUnitFrameElement)

	frame.template = template or 'Default'
	if glossTex then frame.glossTex = glossTex end
	if ignoreUpdates then frame.ignoreUpdates = ignoreUpdates end
	if forcePixelMode then frame.forcePixelMode = forcePixelMode end
	if isUnitFrameElement then frame.isUnitFrameElement = isUnitFrameElement end

	frame:SetBackdrop(nil)
	E:BuildPixelBorders(frame)

	if template == 'NoBackdrop' then
		E:SetBackdrop(frame)
	else
		E:SetBackdrop(frame, true, glossTex and (type(glossTex) == 'string' and glossTex or E.media.glossTex) or E.media.blankTex, (not E.twoPixelsPlease and E.mult) or E.mult*2)

		if not frame.ignoreBackdropColors then
			if template == 'Transparent' then
				E:SetBackdropColor(frame, backdropr, backdropg, backdropb, backdropa)
			else
				E:SetBackdropColor(frame, backdropr, backdropg, backdropb, 1)
			end
		end

		if not E.PixelMode and not frame.forcePixelMode then
			if not frame.iborder then
				local border = CreateFrame('Frame', nil, frame)
				E:BuildPixelBorders(border, true)
				E:SetBackdrop(border, true, nil, E.mult, -E.mult, -E.mult, -E.mult, -E.mult)
				E:SetBackdropBorderColor(border, 0, 0, 0, 1)
				border:SetAllPoints()
				frame.iborder = border
			end

			if not frame.oborder then
				local border = CreateFrame('Frame', nil, frame)
				E:BuildPixelBorders(border, true)
				E:SetBackdrop(border, true, nil, E.mult, E.mult, E.mult, E.mult, E.mult)
				E:SetBackdropBorderColor(border, 0, 0, 0, 1)
				border:SetAllPoints()
				frame.oborder = border
			end
		end
	end

	if not frame.ignoreBorderColors then
		E:SetBackdropBorderColor(frame, borderr, borderg, borderb)
	end

	if not frame.ignoreUpdates then
		if frame.isUnitFrameElement then
			E.unitFrameElements[frame] = true
		else
			E.frames[frame] = true
		end
	end
end

local function CreateBackdrop(frame, template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
	local parent = (frame.IsObjectType and frame:IsObjectType('Texture') and frame:GetParent()) or frame
	local backdrop = frame.backdrop or CreateFrame('Frame', nil, parent)
	if not frame.backdrop then frame.backdrop = backdrop end

	if frame.forcePixelMode or forcePixelMode then
		backdrop:SetOutside(frame, E.mult, E.mult)
	else
		backdrop:SetOutside(frame)
	end

	backdrop:SetTemplate(template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement)

	local frameLevel = parent.GetFrameLevel and parent:GetFrameLevel()
	local frameLevelMinusOne = frameLevel and (frameLevel - 1)
	if frameLevelMinusOne and (frameLevelMinusOne >= 0) then
		backdrop:SetFrameLevel(frameLevelMinusOne)
	else
		backdrop:SetFrameLevel(0)
	end
end

local function CreateShadow(frame, size)
	if frame.shadow then return end

	backdropr, backdropg, backdropb, borderr, borderg, borderb = 0, 0, 0, 0, 0, 0

	local shadow = CreateFrame('Frame', nil, frame)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(frame:GetFrameStrata())
	shadow:SetOutside(frame, size or 3, size or 3)
	shadow:SetBackdrop({edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(size or 3)})
	shadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.9)
	frame.shadow = shadow
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
	'BG',
	'border',
	'Border',
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
				if BlizzFrame and BlizzFrame.StripTextures then
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
	fs.font, fs.fontSize, fs.fontStyle = font, fontSize, fontStyle

	font = font or LSM:Fetch('font', E.db.general.font)
	fontStyle = fontStyle or E.db.general.fontStyle

	if fontSize and fontSize > 0 then
		fontSize = fontSize
	else
		fontSize = E.db.general.fontSize
	end

	if fontStyle == 'OUTLINE' and E.db.general.font == 'Homespun' and (fontSize > 10 and not fs.fontSize) then
		fontSize, fontStyle = 10, 'MONOCHROMEOUTLINE'
	end

	fs:SetFont(font, fontSize, fontStyle)

	if fontStyle == 'NONE' then
		local s = E.mult or 1
		fs:SetShadowOffset(s, -s/2)
		fs:SetShadowColor(0, 0, 0, 1)
	else
		fs:SetShadowOffset(0, 0)
		fs:SetShadowColor(0, 0, 0, 0)
	end

	E.texts[fs] = true
end

local function StyleButton(button, noHover, noPushed, noChecked)
	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetInside()
		hover:SetColorTexture(1, 1, 1, 0.3)
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetInside()
		pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		button:SetPushedTexture(pushed)
		button.pushed = pushed
	end

	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
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
		if frame.CloseButton then return end

		local CloseButton = CreateFrame('Button', nil, frame)
		CloseButton:Size(size or 16)
		CloseButton:Point('TOPRIGHT', offset or -6, offset or -6)
		if backdrop then CloseButton:CreateBackdrop(nil, true) end

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
	if not object.DisabledPixelSnap then
		if mt.SetSnapToPixelGrid then hooksecurefunc(mt, 'SetSnapToPixelGrid', WatchPixelSnap) end
		if mt.SetStatusBarTexture then hooksecurefunc(mt, 'SetStatusBarTexture', DisablePixelSnap) end
		if mt.SetColorTexture then hooksecurefunc(mt, 'SetColorTexture', DisablePixelSnap) end
		if mt.SetVertexColor then hooksecurefunc(mt, 'SetVertexColor', DisablePixelSnap) end
		if mt.CreateTexture then hooksecurefunc(mt, 'CreateTexture', DisablePixelSnap) end
		if mt.SetTexCoord then hooksecurefunc(mt, 'SetTexCoord', DisablePixelSnap) end
		if mt.SetTexture then hooksecurefunc(mt, 'SetTexture', DisablePixelSnap) end
		mt.DisabledPixelSnap = true
	end
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

--Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the 'Frame' widget
local scrollFrame = CreateFrame('ScrollFrame')
addapi(scrollFrame)
