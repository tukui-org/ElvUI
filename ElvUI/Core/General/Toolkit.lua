local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')
local NP = E:GetModule('NamePlates')

local _G = _G
local pairs, pcall, unpack, type, next = pairs, pcall, unpack, type, next
local hooksecurefunc = hooksecurefunc
local getmetatable = getmetatable

local EnumerateFrames = EnumerateFrames
local CreateFrame = CreateFrame

local backdropr, backdropg, backdropb, backdropa = 0, 0, 0, 1
local borderr, borderg, borderb, bordera = 0, 0, 0, 1

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

local function BackdropFrameLevel(frame, level)
	frame:SetFrameLevel(level)

	if frame.oborder then frame.oborder:SetFrameLevel(level) end
	if frame.iborder then frame.iborder:SetFrameLevel(level) end
end

local function BackdropFrameLower(backdrop, parent)
	local level = parent:GetFrameLevel()
	local minus = level and (level - 1)
	if minus and (minus >= 0) then
		BackdropFrameLevel(backdrop, minus)
	else
		BackdropFrameLevel(backdrop, 0)
	end
end

local function GetTemplate(template, isUnitFrameElement)
	backdropa, bordera = 1, 1

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
	local w = E:Scale(width)
	frame:SetSize(w, (height and E:Scale(height)) or w, ...)
end

local function Width(frame, width, ...)
	frame:SetWidth(E:Scale(width), ...)
end

local function Height(frame, height, ...)
	frame:SetHeight(E:Scale(height), ...)
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5, ...)
	if not arg2 then arg2 = obj:GetParent() end

	if type(arg2)=='number' then arg2 = E:Scale(arg2) end
	if type(arg3)=='number' then arg3 = E:Scale(arg3) end
	if type(arg4)=='number' then arg4 = E:Scale(arg4) end
	if type(arg5)=='number' then arg5 = E:Scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5, ...)
end

local function SetOutside(obj, anchor, xOffset, yOffset, anchor2, noScale)
	if not anchor then anchor = obj:GetParent() end

	if not xOffset then xOffset = E.Border end
	if not yOffset then yOffset = E.Border end
	local x = (noScale and xOffset) or E:Scale(xOffset)
	local y = (noScale and yOffset) or E:Scale(yOffset)

	if E:SetPointsRestricted(obj) or obj:GetPoint() then
		obj:ClearAllPoints()
	end

	DisablePixelSnap(obj)
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -x, y)
	obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', x, -y)
end

local function SetInside(obj, anchor, xOffset, yOffset, anchor2, noScale)
	if not anchor then anchor = obj:GetParent() end

	if not xOffset then xOffset = E.Border end
	if not yOffset then yOffset = E.Border end
	local x = (noScale and xOffset) or E:Scale(xOffset)
	local y = (noScale and yOffset) or E:Scale(yOffset)

	if E:SetPointsRestricted(obj) or obj:GetPoint() then
		obj:ClearAllPoints()
	end

	DisablePixelSnap(obj)
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', x, -y)
	obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', -x, y)
end

local function SetTemplate(frame, template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement, isNamePlateElement, noScale)
	GetTemplate(template, isUnitFrameElement)

	frame.template = template or 'Default'
	frame.glossTex = glossTex
	frame.ignoreUpdates = ignoreUpdates
	frame.forcePixelMode = forcePixelMode
	frame.isUnitFrameElement = isUnitFrameElement
	frame.isNamePlateElement = isNamePlateElement

	if not frame.SetBackdrop then
		_G.Mixin(frame, _G.BackdropTemplateMixin)
		frame:HookScript('OnSizeChanged', frame.OnBackdropSizeChanged)
	end

	if template == 'NoBackdrop' then
		frame:SetBackdrop()
	else
		local edgeSize = E.twoPixelsPlease and 2 or 1

		frame:SetBackdrop({
			edgeFile = E.media.blankTex,
			bgFile = glossTex and (type(glossTex) == 'string' and glossTex or E.media.glossTex) or E.media.blankTex,
			edgeSize = noScale and edgeSize or E:Scale(edgeSize)
		})

		if frame.callbackBackdropColor then
			frame:callbackBackdropColor()
		else
			frame:SetBackdropColor(backdropr, backdropg, backdropb, frame.customBackdropAlpha or (template == 'Transparent' and backdropa) or 1)
		end

		local notPixelMode = not isUnitFrameElement and not isNamePlateElement and not E.PixelMode
		local notThinBorders = (isUnitFrameElement and not UF.thinBorders) or (isNamePlateElement and not NP.thinBorders)
		if (notPixelMode or notThinBorders) and not forcePixelMode then
			local backdrop = {
				edgeFile = E.media.blankTex,
				edgeSize = noScale and 1 or E:Scale(1)
			}

			local level = frame:GetFrameLevel()
			if not frame.iborder then
				local border = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
				border:SetBackdrop(backdrop)
				border:SetBackdropBorderColor(0, 0, 0, 1)
				border:SetFrameLevel(level)
				border:SetInside(frame, 1, 1, nil, noScale)
				frame.iborder = border
			end

			if not frame.oborder then
				local border = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
				border:SetBackdrop(backdrop)
				border:SetBackdropBorderColor(0, 0, 0, 1)
				border:SetFrameLevel(level)
				border:SetOutside(frame, 1, 1, nil, noScale)
				frame.oborder = border
			end
		end
	end

	if frame.forcedBorderColors then
		borderr, borderg, borderb, bordera = unpack(frame.forcedBorderColors)
	end

	frame:SetBackdropBorderColor(borderr, borderg, borderb, bordera)

	if not frame.ignoreUpdates then
		if frame.isUnitFrameElement then
			E.unitFrameElements[frame] = true
		else
			E.frames[frame] = true
		end
	end
end

local function CreateBackdrop(frame, template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement, isNamePlateElement, noScale, allPoints, frameLevel)
	local parent = (frame.IsObjectType and frame:IsObjectType('Texture') and frame:GetParent()) or frame
	local backdrop = frame.backdrop or CreateFrame('Frame', nil, parent)
	if not frame.backdrop then frame.backdrop = backdrop end

	backdrop:SetTemplate(template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement, isNamePlateElement, noScale)

	if allPoints then
		if allPoints == true then
			backdrop:SetAllPoints()
		else
			backdrop:SetAllPoints(allPoints)
		end
	else
		if forcePixelMode then
			backdrop:SetOutside(frame, E.twoPixelsPlease and 2 or 1, E.twoPixelsPlease and 2 or 1, nil, noScale)
		else
			local border = (isUnitFrameElement and UF.BORDER) or (isNamePlateElement and NP.BORDER)
			backdrop:SetOutside(frame, border, border, nil, noScale)
		end
	end

	if frameLevel then
		if frameLevel == true then
			BackdropFrameLevel(backdrop, parent:GetFrameLevel())
		else
			BackdropFrameLevel(backdrop, frameLevel)
		end
	else
		BackdropFrameLower(backdrop, parent)
	end
end

local function CreateShadow(frame, size, pass)
	if not pass and frame.shadow then return end
	if not size then size = 3 end

	backdropr, backdropg, backdropb, borderr, borderg, borderb = 0, 0, 0, 0, 0, 0

	local offset = (E.PixelMode and size) or (size + 1)
	local shadow = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(frame:GetFrameStrata())
	shadow:SetOutside(frame, offset, offset, nil, true)
	shadow:SetBackdrop({edgeFile = E.Media.Textures.GlowTex, edgeSize = size})
	shadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.9)

	if pass then
		return shadow
	else
		frame.shadow = shadow
	end
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

local function KillEditMode(object)
	object.HighlightSystem = E.noop
	object.ClearHighlight = E.noop
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

local STRIP_TEX = 'Texture'
local STRIP_FONT = 'FontString'
local function StripRegion(which, object, kill, zero)
	if kill then
		object:Kill()
	elseif zero then
		object:SetAlpha(0)
	elseif which == STRIP_TEX then
		object:SetTexture('')
		object:SetAtlas('')
	elseif which == STRIP_FONT then
		object:SetText('')
	end
end

local function StripType(which, object, kill, zero)
	if object:IsObjectType(which) then
		StripRegion(which, object, kill, zero)
	else
		if which == STRIP_TEX then
			local FrameName = object.GetName and object:GetName()
			for _, Blizzard in pairs(StripTexturesBlizzFrames) do
				local BlizzFrame = object[Blizzard] or (FrameName and _G[FrameName..Blizzard])
				if BlizzFrame and BlizzFrame.StripTextures then
					BlizzFrame:StripTextures(kill, zero)
				end
			end
		end

		if object.GetNumRegions then
			for _, region in next, { object:GetRegions() } do
				if region and region.IsObjectType and region:IsObjectType(which) then
					StripRegion(which, region, kill, zero)
				end
			end
		end
	end
end

local function StripTextures(object, kill, zero)
	StripType(STRIP_TEX, object, kill, zero)
end

local function StripTexts(object, kill, zero)
	StripType(STRIP_FONT, object, kill, zero)
end

local function FontTemplate(fs, font, size, style, skip)
	if not skip then -- ignore updates from UpdateFontTemplates
		fs.font, fs.fontSize, fs.fontStyle = font, size, style
	end

	-- grab values from profile before conversion
	if not style then style = E.db.general.fontStyle or P.general.fontStyle end
	if not size then size = E.db.general.fontSize or P.general.fontSize end

	-- shadow mode when using 'NONE'
	if style == 'NONE' then
		fs:SetShadowOffset(1, -0.5)
		fs:SetShadowColor(0, 0, 0, 1)
	else
		fs:SetShadowOffset(0, 0)
		fs:SetShadowColor(0, 0, 0, 0)
	end

	-- convert because of bad values between versions
	if style == 'NONE' and E.Retail then
		style = ''
	elseif style == '' and not E.Retail then
		style = 'NONE'
	end

	fs:SetFont(font or E.media.normFont, size, style)

	E.texts[fs] = true
end

local function StyleButton(button, noHover, noPushed, noChecked)
	if button.SetHighlightTexture and button.CreateTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetInside()
		hover:SetBlendMode('ADD')
		hover:SetColorTexture(1, 1, 1, 0.3)
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	if button.SetPushedTexture and button.CreateTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetInside()
		pushed:SetBlendMode('ADD')
		pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		button:SetPushedTexture(pushed)
		button.pushed = pushed
	end

	if button.SetCheckedTexture and button.CreateTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetInside()
		checked:SetBlendMode('ADD')
		checked:SetColorTexture(1, 1, 1, 0.3)
		button:SetCheckedTexture(checked)
		button.checked = checked
	end

	if button.cooldown then
		button.cooldown:SetDrawEdge(false)
		button.cooldown:SetInside(button, 0, 0)
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
	local mk = getmetatable(object).__index

	if not object.Size then mk.Size = Size end
	if not object.Point then mk.Point = Point end
	if not object.SetOutside then mk.SetOutside = SetOutside end
	if not object.SetInside then mk.SetInside = SetInside end
	if not object.SetTemplate then mk.SetTemplate = SetTemplate end
	if not object.CreateBackdrop then mk.CreateBackdrop = CreateBackdrop end
	if not object.CreateShadow then mk.CreateShadow = CreateShadow end
	if not object.KillEditMode then mk.KillEditMode = KillEditMode end
	if not object.Kill then mk.Kill = Kill end
	if not object.Width then mk.Width = Width end
	if not object.Height then mk.Height = Height end
	if not object.FontTemplate then mk.FontTemplate = FontTemplate end
	if not object.StripTextures then mk.StripTextures = StripTextures end
	if not object.StripTexts then mk.StripTexts = StripTexts end
	if not object.StyleButton then mk.StyleButton = StyleButton end
	if not object.CreateCloseButton then mk.CreateCloseButton = CreateCloseButton end
	if not object.GetNamedChild then mk.GetNamedChild = GetNamedChild end

	if not object.DisabledPixelSnap and (mk.SetSnapToPixelGrid or mk.SetStatusBarTexture or mk.SetColorTexture or mk.SetVertexColor or mk.CreateTexture or mk.SetTexCoord or mk.SetTexture) then
		if mk.SetSnapToPixelGrid then hooksecurefunc(mk, 'SetSnapToPixelGrid', WatchPixelSnap) end
		if mk.SetStatusBarTexture then hooksecurefunc(mk, 'SetStatusBarTexture', DisablePixelSnap) end
		if mk.SetColorTexture then hooksecurefunc(mk, 'SetColorTexture', DisablePixelSnap) end
		if mk.SetVertexColor then hooksecurefunc(mk, 'SetVertexColor', DisablePixelSnap) end
		if mk.CreateTexture then hooksecurefunc(mk, 'CreateTexture', DisablePixelSnap) end
		if mk.SetTexCoord then hooksecurefunc(mk, 'SetTexCoord', DisablePixelSnap) end
		if mk.SetTexture then hooksecurefunc(mk, 'SetTexture', DisablePixelSnap) end
		mk.DisabledPixelSnap = true
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
	local objType = object:GetObjectType()
	if not object:IsForbidden() and not handled[objType] then
		addapi(object)
		handled[objType] = true
	end

	object = EnumerateFrames(object)
end

addapi(_G.GameFontNormal) --Add API to `CreateFont` objects without actually creating one
addapi(CreateFrame('ScrollFrame')) --Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the 'Frame' widget
