local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local _G = _G
local unpack, type, select, getmetatable, assert, pairs = unpack, type, select, getmetatable, assert, pairs
--WoW API / Variables
local CreateFrame = CreateFrame
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
-- GLOBALS: CUSTOM_CLASS_COLORS

E.mult = 1
local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0

local function GetTemplate(t, isUnitFrameElement)
	backdropa = 1

	if t == 'ClassColor' then
		local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass]
		borderr, borderg, borderb = color.r, color.g, color.b

		if t ~= 'Transparent' then
			backdropr, backdropg, backdropb = unpack(E.media.backdropcolor)
		else
			backdropr, backdropg, backdropb, backdropa = unpack(E.media.backdropfadecolor)
		end
	elseif t == 'Transparent' then
		if isUnitFrameElement then
			borderr, borderg, borderb = unpack(E.media.unitframeBorderColor)
		else
			borderr, borderg, borderb = unpack(E.media.bordercolor)
		end

		backdropr, backdropg, backdropb, backdropa = unpack(E.media.backdropfadecolor)
	else
		if isUnitFrameElement then
			borderr, borderg, borderb = unpack(E.media.unitframeBorderColor)
		else
			borderr, borderg, borderb = unpack(E.media.bordercolor)
		end

		backdropr, backdropg, backdropb = unpack(E.media.backdropcolor)
	end
end

local function Size(frame, width, height)
	assert(width)
	frame:SetSize(E:Scale(width), E:Scale(height or width))
end

local function Width(frame, width)
	assert(width)
	frame:SetWidth(E:Scale(width))
end

local function Height(frame, height)
	assert(height)
	frame:SetHeight(E:Scale(height))
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5)
	if arg2 == nil then
		arg2 = obj:GetParent()
	end

	if type(arg1)=='number' then arg1 = E:Scale(arg1) end
	if type(arg2)=='number' then arg2 = E:Scale(arg2) end
	if type(arg3)=='number' then arg3 = E:Scale(arg3) end
	if type(arg4)=='number' then arg4 = E:Scale(arg4) end
	if type(arg5)=='number' then arg5 = E:Scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
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

	if t then f.template = t end
	if glossTex then f.glossTex = glossTex end
	if ignoreUpdates then f.ignoreUpdates = ignoreUpdates end
	if forcePixelMode then f.forcePixelMode = forcePixelMode end
	if isUnitFrameElement then f.isUnitFrameElement = isUnitFrameElement end

	if t ~= 'NoBackdrop' then
		if E.private.general.pixelPerfect or f.forcePixelMode then
			f:SetBackdrop({
				bgFile = E.media.blankTex,
				edgeFile = E.media.blankTex,
				tile = false, tileSize = 0, edgeSize = E.mult,
				insets = {left = 0, right = 0, top = 0, bottom = 0}
			})
		else
			f:SetBackdrop({
				bgFile = E.media.blankTex,
				edgeFile = E.media.blankTex,
				tile = false, tileSize = 0, edgeSize = E.mult,
				insets = {left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
			})
		end

		if not f.backdropTexture and t ~= 'Transparent' then
			local backdropTexture = f:CreateTexture(nil, 'BORDER')
			backdropTexture:SetDrawLayer('BACKGROUND', 1)
			f.backdropTexture = backdropTexture
		elseif t == 'Transparent' then
			f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)

			if f.backdropTexture then
				f.backdropTexture:Hide()
				f.backdropTexture = nil
			end

			if not E.private.general.pixelPerfect and not f.forcePixelMode then
				if not f.iborder then
					local border = CreateFrame('Frame', nil, f)
					border:SetInside(f, E.mult, E.mult)
					border:SetBackdrop({
						edgeFile = E.media.blankTex,
						edgeSize = E.mult,
						insets = {left = E.mult, right = E.mult, top = E.mult, bottom = E.mult}
					})
					border:SetBackdropBorderColor(0, 0, 0, 1)
					f.iborder = border
				end

				if not f.oborder then
					local border = CreateFrame('Frame', nil, f)
					border:SetOutside(f, E.mult, E.mult)
					border:SetFrameLevel(f:GetFrameLevel() + 1)
					border:SetBackdrop({
						edgeFile = E.media.blankTex,
						edgeSize = E.mult,
						insets = {left = E.mult, right = E.mult, top = E.mult, bottom = E.mult}
					})
					border:SetBackdropBorderColor(0, 0, 0, 1)
					f.oborder = border
				end
			end
		end

		if f.backdropTexture then
			f:SetBackdropColor(0, 0, 0, backdropa)
			f.backdropTexture:SetVertexColor(backdropr, backdropg, backdropb)
			f.backdropTexture:SetAlpha(backdropa)

			if glossTex then
				f.backdropTexture:SetTexture(E.media.glossTex)
			else
				f.backdropTexture:SetTexture(E.media.blankTex)
			end

			if f.forcePixelMode or forcePixelMode then
				f.backdropTexture:SetInside(f, E.mult, E.mult)
			else
				f.backdropTexture:SetInside(f)
			end
		end
	else
		f:SetBackdrop(nil)
		if f.backdropTexture then
			f.backdropTexture:SetTexture(nil)
		end
	end
	f:SetBackdropBorderColor(borderr, borderg, borderb)

	if not f.ignoreUpdates then
		if f.isUnitFrameElement then
			E.unitFrameElements[f] = true
		else
			E.frames[f] = true
		end
	end
end

local function CreateBackdrop(f, t, tex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
	if not t then t = 'Default' end

	local parent = f.IsObjectType and f:IsObjectType('Texture') and f:GetParent() or f
	local b = CreateFrame('Frame', nil, parent)
	if f.forcePixelMode or forcePixelMode then
		b:SetOutside(nil, E.mult, E.mult)
	else
		b:SetOutside()
	end
	b:SetTemplate(t, tex, ignoreUpdates, forcePixelMode, isUnitFrameElement)

	local frameLevel = parent.GetFrameLevel and parent:GetFrameLevel()
	local frameLevelMinusOne = frameLevel and (frameLevel - 1)
	if frameLevelMinusOne and (frameLevelMinusOne >= 0) then
		b:SetFrameLevel(frameLevelMinusOne)
	else
		b:SetFrameLevel(0)
	end

	f.backdrop = b
end

local function CreateShadow(f)
	if f.shadow then return end
	backdropr, backdropg, backdropb, borderr, borderg, borderb = 0, 0, 0, 0, 0, 0

	local shadow = CreateFrame('Frame', nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetOutside(f, 3, 3)
	shadow:SetBackdrop({edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(3)})
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
}

local function StripTextures(object, kill, alpha)
	if object:IsObjectType('Texture') then
		if kill then
			object:Kill()
		elseif alpha then
			object:SetAlpha(0)
		else
			object:SetTexture(nil)
		end
	else
		local FrameName = object.GetName and object:GetName()

		for _, Blizzard in pairs(StripTexturesBlizzFrames) do
			local BlizzFrame = object[Blizzard] or FrameName and _G[FrameName..Blizzard]
			if BlizzFrame then
				BlizzFrame:StripTextures(kill, alpha)
			end
		end

		if object.GetNumRegions then
			for i = 1, object:GetNumRegions() do
				local region = select(i, object:GetRegions())
				if region and region.IsObjectType and region:IsObjectType('Texture') then
					if kill then
						region:Kill()
					elseif alpha then
						region:SetAlpha(0)
					else
						region:SetTexture(nil)
					end
				end
			end
		end
	end
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
		local CloseButton = CreateFrame('Button', nil, frame)
		CloseButton:Size(size or 16)
		CloseButton:Point('TOPRIGHT', offset or -6, offset or -6)
		if backdrop then
			CloseButton:CreateBackdrop('Default', true)
		end

		CloseButton.Texture = CloseButton:CreateTexture(nil, 'OVERLAY')
		CloseButton.Texture:SetAllPoints()
		CloseButton.Texture:SetTexture(texture or 'Interface\\AddOns\\ElvUI\\media\\textures\\close')

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
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.CreateCloseButton then mt.CreateCloseButton = CreateCloseButton end
	if not object.GetNamedChild then mt.GetNamedChild = GetNamedChild end
end

local handled = {['Frame'] = true}
local object = CreateFrame('Frame')
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

--Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the "Frame" widget
local scrollFrame = CreateFrame('ScrollFrame')
addapi(scrollFrame)
