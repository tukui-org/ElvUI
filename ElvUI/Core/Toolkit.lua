local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

local _G = _G
local unpack, type, select, getmetatable = unpack, type, select, getmetatable
local assert, pairs, pcall, tonumber = assert, pairs, pcall, tonumber
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0

-- 8.2 restricted frame check
function E:SetPointsRestricted(frame)
	if frame and not pcall(frame.GetPoint, frame) then
		return true
	end
end

function E:SafeGetPoint(frame)
	if frame and frame.GetPoint and not E:SetPointsRestricted(frame) then
		return frame:GetPoint()
	end
end

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
		local color = E:ClassColor(E.myclass)
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
	frame:SetSize(width, height or width, ...)
end

local function Width(frame, width, ...)
	assert(width)
	frame:SetWidth(width, ...)
end

local function Height(frame, height, ...)
	assert(height)
	frame:SetHeight(height, ...)
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5, ...)
	obj:SetPoint(arg1, arg2, arg3, arg4, arg5, ...)
end

local function SetOutside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or E.Border
	yOffset = yOffset or E.Border
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if E:SetPointsRestricted(obj) or obj:GetPoint() then
		obj:ClearAllPoints()
	end

	DisablePixelSnap(obj)
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -xOffset, yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset, anchor2)
	xOffset = xOffset or E.Border
	yOffset = yOffset or E.Border
	anchor = anchor or obj:GetParent()

	assert(anchor)
	if E:SetPointsRestricted(obj) or obj:GetPoint() then
		obj:ClearAllPoints()
	end

	DisablePixelSnap(obj)
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', xOffset, -yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', -xOffset, yOffset)
end

local function SetTemplate(frame, template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
	GetTemplate(template, isUnitFrameElement)

	frame.template = template or 'Default'
	if glossTex then frame.glossTex = glossTex end
	if ignoreUpdates then frame.ignoreUpdates = ignoreUpdates end
	if forcePixelMode then frame.forcePixelMode = forcePixelMode end
	if isUnitFrameElement then frame.isUnitFrameElement = isUnitFrameElement end

	if template == 'NoBackdrop' then
		frame:SetBackdrop()
	else
		frame:SetBackdrop({
			edgeFile = E.media.blankTex,
			bgFile = glossTex and (type(glossTex) == 'string' and glossTex or E.media.glossTex) or E.media.blankTex,
			tile = false, tileSize = 0, edgeSize = (not E.twoPixelsPlease and E.mult) or E.mult*2,
			insets = {left = 0, right = 0, top = 0, bottom = 0}
		})

		if frame.callbackBackdropColor then
			frame:callbackBackdropColor()
		else
			frame:SetBackdropColor(backdropr, backdropg, backdropb, frame.customBackdropAlpha or (template == 'Transparent' and backdropa) or 1)
		end

		if not E.PixelMode and not frame.forcePixelMode then
			if not frame.iborder then
				local border = CreateFrame('Frame', nil, frame, "BackdropTemplate")
				border:SetInside(frame, E.mult, E.mult)
				border:SetBackdrop({
					edgeFile = E.media.blankTex, edgeSize = E.mult,
					insets = {left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
				})

				border:SetBackdropBorderColor(0, 0, 0, 1)
				frame.iborder = border
			end

			if not frame.oborder then
				local border = CreateFrame('Frame', nil, frame, "BackdropTemplate")
				border:SetOutside(frame, E.mult, E.mult)
				border:SetBackdrop({
					edgeFile = E.media.blankTex, edgeSize = E.mult,
					insets = {left = E.mult, right = E.mult, top = E.mult, bottom = E.mult}
				})

				border:SetBackdropBorderColor(0, 0, 0, 1)
				frame.oborder = border
			end
		end
	end

	if not frame.ignoreBorderColors then
		frame:SetBackdropBorderColor(borderr, borderg, borderb)
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
	local backdrop = frame.backdrop or CreateFrame('Frame', nil, parent, "BackdropTemplate")
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

local function CreateShadow(frame, size, pass)
	if not pass and frame.shadow then return end

	backdropr, backdropg, backdropb, borderr, borderg, borderb = 0, 0, 0, 0, 0, 0

	local shadow = CreateFrame('Frame', nil, frame, "BackdropTemplate")
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(frame:GetFrameStrata())
	shadow:SetOutside(frame, size or 3, size or 3)
	shadow:SetBackdrop({edgeFile = E.Media.Textures.GlowTex, edgeSize = E:Scale(size or 3)})
	shadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.9)

	if pass then
		return shadow
	else
		frame.shadow = shadow
	end
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
	'ScrollFrameBorder',
}

local STRIP_TEX = 'Texture'
local STRIP_FONT = 'FontString'
local function StripRegion(which, object, kill, alpha)
	if kill then
		object:Kill()
	elseif which == STRIP_TEX then
		if object:GetTexture() then object:SetTexture(nil) end
		if object:GetAtlas() then object:SetAtlas(nil) end
	elseif which == STRIP_FONT then
		object:SetText('')
	end

	if alpha then
		object:SetAlpha(0)
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
	if type(fontSize) == 'string' then
		fontSize = tonumber(fontSize)
	end

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
		hover:SetBlendMode('ADD')
		hover:SetColorTexture(1, 1, 1, 0.3)
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetInside()
		pushed:SetBlendMode('ADD')
		pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		button:SetPushedTexture(pushed)
		button.pushed = pushed
	end

	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetInside()
		checked:SetBlendMode('ADD')
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
		CloseButton:SetSize(size or 16, size or 16)
		CloseButton:SetPoint('TOPRIGHT', offset or -6, offset or -6)
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

local handled = {Frame = true}
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

addapi(_G.GameFontNormal) --Add API to `CreateFont` objects without actually creating one
addapi(CreateFrame('ScrollFrame')) --Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the 'Frame' widget
