local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
local _G = _G
local unpack, type, select, getmetatable, assert = unpack, type, select, getmetatable, assert
--WoW API / Variables
local CreateFrame = CreateFrame
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
-- GLOBALS: CUSTOM_CLASS_COLORS

E.mult = 1
local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0

local function GetTemplate(t, isUnitFrameElement)
	backdropa = 1

	if t == "ClassColor" then
		if CUSTOM_CLASS_COLORS then
			borderr, borderg, borderb = CUSTOM_CLASS_COLORS[E.myclass].r, CUSTOM_CLASS_COLORS[E.myclass].g, CUSTOM_CLASS_COLORS[E.myclass].b
		else
			borderr, borderg, borderb = RAID_CLASS_COLORS[E.myclass].r, RAID_CLASS_COLORS[E.myclass].g, RAID_CLASS_COLORS[E.myclass].b
		end
		if t ~= "Transparent" then
			backdropr, backdropg, backdropb = unpack(E["media"].backdropcolor)
		else
			backdropr, backdropg, backdropb, backdropa = unpack(E["media"].backdropfadecolor)
		end
	elseif t == "Transparent" then
		if isUnitFrameElement then
			borderr, borderg, borderb = unpack(E["media"].unitframeBorderColor)
		else
			borderr, borderg, borderb = unpack(E["media"].bordercolor)
		end
		backdropr, backdropg, backdropb, backdropa = unpack(E["media"].backdropfadecolor)
	else
		if isUnitFrameElement then
			borderr, borderg, borderb = unpack(E["media"].unitframeBorderColor)
		else
			borderr, borderg, borderb = unpack(E["media"].bordercolor)
		end
		backdropr, backdropg, backdropb = unpack(E["media"].backdropcolor)
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

	if type(arg1)=="number" then arg1 = E:Scale(arg1) end
	if type(arg2)=="number" then arg2 = E:Scale(arg2) end
	if type(arg3)=="number" then arg3 = E:Scale(arg3) end
	if type(arg4)=="number" then arg4 = E:Scale(arg4) end
	if type(arg5)=="number" then arg5 = E:Scale(arg5) end

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

	if(t) then
	   f.template = t
	end

	if(glossTex) then
	   f.glossTex = glossTex
	end

	if(ignoreUpdates) then
	   f.ignoreUpdates = ignoreUpdates
	end

	if(forcePixelMode) then
		f.forcePixelMode = forcePixelMode
	end

	if (isUnitFrameElement) then
		f.isUnitFrameElement = isUnitFrameElement
	end

	if t ~= "NoBackdrop" then
		if E.private.general.pixelPerfect or f.forcePixelMode then
			f:SetBackdrop({
			  bgFile = E["media"].blankTex,
			  edgeFile = E["media"].blankTex,
			  tile = false, tileSize = 0, edgeSize = E.mult,
			  insets = { left = 0, right = 0, top = 0, bottom = 0}
			})
		else
			f:SetBackdrop({
			  bgFile = E["media"].blankTex,
			  edgeFile = E["media"].blankTex,
			  tile = false, tileSize = 0, edgeSize = E.mult,
			  insets = { left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
			})
		end

		if not f.backdropTexture and t ~= 'Transparent' then
			local backdropTexture = f:CreateTexture(nil, "BORDER")
			backdropTexture:SetDrawLayer("BACKGROUND", 1)
			f.backdropTexture = backdropTexture
		elseif t == 'Transparent' then
			f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)

			if f.backdropTexture then
				f.backdropTexture:Hide()
				f.backdropTexture = nil
			end

			if not f.oborder and not f.iborder and not E.private.general.pixelPerfect and not f.forcePixelMode then
				local border = CreateFrame("Frame", nil, f)
				border:SetInside(f, E.mult, E.mult)
				border:SetBackdrop({
					edgeFile = E["media"].blankTex,
					edgeSize = E.mult,
					insets = { left = E.mult, right = E.mult, top = E.mult, bottom = E.mult }
				})
				border:SetBackdropBorderColor(0, 0, 0, 1)
				f.iborder = border

				if f.oborder then return end
				border = CreateFrame("Frame", nil, f)
				border:SetOutside(f, E.mult, E.mult)
				border:SetFrameLevel(f:GetFrameLevel() + 1)
				border:SetBackdrop({
					edgeFile = E["media"].blankTex,
					edgeSize = E.mult,
					insets = { left = E.mult, right = E.mult, top = E.mult, bottom = E.mult }
				})
				border:SetBackdropBorderColor(0, 0, 0, 1)
				f.oborder = border
			end
		end

		if f.backdropTexture then
			f:SetBackdropColor(0, 0, 0, backdropa)
			f.backdropTexture:SetVertexColor(backdropr, backdropg, backdropb)
			f.backdropTexture:SetAlpha(backdropa)
			if glossTex then
				f.backdropTexture:SetTexture(E["media"].glossTex)
			else
				f.backdropTexture:SetTexture(E["media"].blankTex)
			end

			if(f.forcePixelMode or forcePixelMode) then
				f.backdropTexture:SetInside(f, E.mult, E.mult)
			else
				f.backdropTexture:SetInside(f)
			end
		end
	else
		f:SetBackdrop(nil)
		if f.backdropTexture then f.backdropTexture:SetTexture(nil) end
	end
	f:SetBackdropBorderColor(borderr, borderg, borderb)

	if not f.ignoreUpdates then
		if f.isUnitFrameElement then
			E["unitFrameElements"][f] = true
		else
			E["frames"][f] = true
		end
	end
end

local function CreateBackdrop(f, t, tex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
	if not t then t = "Default" end

	local b = CreateFrame("Frame", nil, f)
	if(f.forcePixelMode or forcePixelMode) then
		b:SetOutside(nil, E.mult, E.mult)
	else
		b:SetOutside()
	end
	b:SetTemplate(t, tex, ignoreUpdates, forcePixelMode, isUnitFrameElement)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end

	f.backdrop = b
end

local function CreateShadow(f)
	if f.shadow then return end

	borderr, borderg, borderb = 0, 0, 0
	backdropr, backdropg, backdropb = 0, 0, 0

	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetOutside(f, 3, 3)
	shadow:SetBackdrop({edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(3)})
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

local function StripTextures(object, kill)
	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if kill and type(kill) == 'boolean' then
				region:Kill()
			elseif region:GetDrawLayer() == kill then
				region:SetTexture(nil)
			elseif kill and type(kill) == 'string' and region:GetTexture() ~= kill then
				region:SetTexture(nil)
			else
				region:SetTexture(nil)
			end
		end
	end
end

local function FontTemplate(fs, font, fontSize, fontStyle)
	fs.font = font
	fs.fontSize = fontSize
	fs.fontStyle = fontStyle

	font = font or LSM:Fetch("font", E.db['general'].font)
	fontSize = fontSize or E.db.general.fontSize

	if fontStyle == 'OUTLINE' and (E.db.general.font == "Homespun") then
		if (fontSize > 10 and not fs.fontSize) then
			fontStyle = 'MONOCHROMEOUTLINE'
			fontSize = 10
		end
	end

	fs:SetFont(font, fontSize, fontStyle)
	if fontStyle and (fontStyle ~= "NONE") then
		fs:SetShadowColor(0, 0, 0, 0.2)
	else
		fs:SetShadowColor(0, 0, 0, 1)
	end
	fs:SetShadowOffset((E.mult or 1), -(E.mult or 1))

	E["texts"][fs] = true
end

local function StyleButton(button, noHover, noPushed, noChecked)
	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetColorTexture(1, 1, 1, 0.3)
		hover:SetInside()
		button.hover = hover
		button:SetHighlightTexture(hover)
	end

	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		pushed:SetInside()
		button.pushed = pushed
		button:SetPushedTexture(pushed)
	end

	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetColorTexture(1, 1, 1, 0.3)
		checked:SetInside()
		button.checked = checked
		button:SetCheckedTexture(checked)
	end

	local cooldown = button:GetName() and _G[button:GetName().."Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetInside()
		cooldown:SetDrawEdge(false)
		cooldown:SetSwipeColor(0, 0, 0, 1)
	end
end

local function CreateCloseButton(frame, size, offset, texture, backdrop)
	size = (size or 16)
	offset = (offset or -6)
	texture = (texture or "Interface\\AddOns\\ElvUI\\media\\textures\\close")

	local CloseButton = CreateFrame("Button", nil, frame)
	CloseButton:Size(size)
	CloseButton:Point("TOPRIGHT", offset, offset)
	if backdrop then
		CloseButton:CreateBackdrop("Default", true)
	end

	CloseButton.Texture = CloseButton:CreateTexture(nil, "OVERLAY")
	CloseButton.Texture:SetAllPoints()
	CloseButton.Texture:SetTexture(texture)

	CloseButton:SetScript("OnClick", function(self)
		self:GetParent():Hide()
	end)
	CloseButton:SetScript("OnEnter", function(self)
		self.Texture:SetVertexColor(unpack(E["media"].rgbvaluecolor))
	end)
	CloseButton:SetScript("OnLeave", function(self)
		self.Texture:SetVertexColor(1, 1, 1)
	end)

	frame.CloseButton = CloseButton
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
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
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
local scrollFrame = CreateFrame("ScrollFrame")
addapi(scrollFrame)
