local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local LSM = LibStub("LibSharedMedia-3.0")

local floor = math.floor
local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0

--Preload shit..
E.mult = 1;

local function GetTemplate(t)
	backdropa = 1
	if t == "ClassColor" then
		borderr, borderg, borderb = RAID_CLASS_COLORS[E.myclass].r, RAID_CLASS_COLORS[E.myclass].g, RAID_CLASS_COLORS[E.myclass].b
		if t ~= "Transparent" then
			backdropr, backdropg, backdropb = unpack(E["media"].backdropcolor)
		else
			backdropr, backdropg, backdropb, backdropa = unpack(E["media"].backdropfadecolor)
		end
	elseif t == "Transparent" then
		borderr, borderg, borderb = unpack(E["media"].bordercolor)
		backdropr, backdropg, backdropb, backdropa = unpack(E["media"].backdropfadecolor)
	else
		borderr, borderg, borderb = unpack(E["media"].bordercolor)
		backdropr, backdropg, backdropb = unpack(E["media"].backdropcolor)
	end
end

local function Size(frame, width, height)
	frame:SetSize(E:Scale(width), E:Scale(height or width))
end

local function Width(frame, width)
	frame:SetWidth(E:Scale(width))
end

local function Height(frame, height)
	frame:SetHeight(E:Scale(height))
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5)
	-- anyone has a more elegant way for this?
	if type(arg1)=="number" then arg1 = E:Scale(arg1) end
	if type(arg2)=="number" then arg2 = E:Scale(arg2) end
	if type(arg3)=="number" then arg3 = E:Scale(arg3) end
	if type(arg4)=="number" then arg4 = E:Scale(arg4) end
	if type(arg5)=="number" then arg5 = E:Scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

local function SetOutside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 2
	yOffset = yOffset or 2
	anchor = anchor or obj:GetParent()
	
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end
	
	obj:Point('TOPLEFT', anchor, 'TOPLEFT', -xOffset, yOffset)
	obj:Point('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 2
	yOffset = yOffset or 2
	anchor = anchor or obj:GetParent()
	
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end
	
	obj:Point('TOPLEFT', anchor, 'TOPLEFT', xOffset, -yOffset)
	obj:Point('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', -xOffset, yOffset)
end

local function SetVirtualBorderColor(f, r, g, b, a)
	assert(f.virtualBorder, 'Invalid frame type, must be a transparent template.')
	f.borderLeft:SetTexture(r, g, b, a)	
	f.borderRight:SetTexture(r, g, b, a)
	f.borderTop:SetTexture(r, g, b, a)
	f.borderBottom:SetTexture(r, g, b, a)	
end

local function SetTemplate(f, t, glossTex, ignoreUpdates)
	GetTemplate(t)
	
	f.template = t
	f.glossTex = glossTex

	if not f.backdropTexture and t ~= 'Transparent' then
		local backdropTexture = f:CreateTexture(nil, "BORDER")
		backdropTexture:SetDrawLayer("BACKGROUND", 1)
		f.backdropTexture = backdropTexture
		
		f:SetBackdrop({
		  bgFile = E["media"].blankTex,
		  edgeFile = E["media"].blankTex,
		  tile = false, tileSize = 0, edgeSize = E.mult,
		  insets = { left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
		})		
	elseif t == 'Transparent' then
		f:SetBackdrop({
		  bgFile = E["media"].blankTex,
		  tile = false, tileSize = 0,
		})
	
		f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
		
		if not f.virtualBorder then
			f.insetLeft = f:CreateTexture(nil, 'BORDER')
			f.insetLeft:Point('TOPLEFT', f, 'TOPLEFT')
			f.insetLeft:Point('BOTTOMLEFT', f, 'BOTTOMLEFT')
			f.insetLeft:Width(E.mult * 3)
			f.insetLeft:SetTexture(0, 0, 0)
			
			f.insetRight = f:CreateTexture(nil, 'BORDER')
			f.insetRight:Point('TOPRIGHT', f, 'TOPRIGHT')
			f.insetRight:Point('BOTTOMRIGHT', f, 'BOTTOMRIGHT')
			f.insetRight:Width(E.mult * 3)
			f.insetRight:SetTexture(0, 0, 0)
			
			f.insetTop = f:CreateTexture(nil, 'BORDER')
			f.insetTop:Point('TOPLEFT', f, 'TOPLEFT')
			f.insetTop:Point('TOPRIGHT', f, 'TOPRIGHT')
			f.insetTop:Height(E.mult * 3)
			f.insetTop:SetTexture(0, 0, 0)
			
			f.insetBottom = f:CreateTexture(nil, 'BORDER')
			f.insetBottom:Point('BOTTOMLEFT', f, 'BOTTOMLEFT')
			f.insetBottom:Point('BOTTOMRIGHT', f, 'BOTTOMRIGHT')
			f.insetBottom:Height(E.mult * 3)
			f.insetBottom:SetTexture(0, 0, 0)
			
			f.borderLeft = f:CreateTexture(nil, 'BORDER', nil, 1)
			f.borderLeft:Point('TOPLEFT', f, 'TOPLEFT', E.mult, -E.mult)
			f.borderLeft:Point('BOTTOMLEFT', f, 'BOTTOMLEFT', E.mult, E.mult)
			f.borderLeft:Width(E.mult)	
			
			f.borderRight = f:CreateTexture(nil, 'BORDER', nil, 1)
			f.borderRight:Point('TOPRIGHT', f, 'TOPRIGHT', -E.mult, -E.mult)
			f.borderRight:Point('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -E.mult, E.mult)
			f.borderRight:Width(E.mult)
			
			f.borderTop = f:CreateTexture(nil, 'BORDER', nil, 1)
			f.borderTop:Point('TOPLEFT', f, 'TOPLEFT', E.mult, -E.mult)
			f.borderTop:Point('TOPRIGHT', f, 'TOPRIGHT', -E.mult, -E.mult)
			f.borderTop:Height(E.mult)	
			
			f.borderBottom = f:CreateTexture(nil, 'BORDER', nil, 1)
			f.borderBottom:Point('BOTTOMLEFT', f, 'BOTTOMLEFT', E.mult, E.mult)
			f.borderBottom:Point('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -E.mult, E.mult)
			f.borderBottom:Height(E.mult)	
			f.virtualBorder = true;
		end			
		
		f:SetVirtualBorderColor(borderr, borderg, borderb)	
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
		f.backdropTexture:SetInside(f)
	end
	
	if not f.virtualBorder then
		f:SetBackdropBorderColor(borderr, borderg, borderb)
	end
	
	if not ignoreUpdates then
		E["frames"][f] = true
	end
end

local function CreateBackdrop(f, t, tex)
	if not t then t = "Default" end
	
	local b = CreateFrame("Frame", nil, f)
	b:SetOutside()
	b:SetTemplate(t, tex)

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
	shadow:SetBackdrop( {
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(3),
		insets = {left = E:Scale(5), right = E:Scale(5), top = E:Scale(5), bottom = E:Scale(5)},
	})
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
	
	if not font then font = LSM:Fetch("font", E.db['general'].font) end
	if not fontSize then fontSize = E.db.general.fontSize end
	if fontStyle == 'OUTLINE' and E.db.general.font:lower():find('pixel') then
		if (fontSize > 10 and not fs.fontSize) then
			fontStyle = 'MONOCHROMEOUTLINE'
			fontSize = 10
		end
	end
	
	fs:SetFont(font, fontSize, fontStyle)
	if fontStyle then
		fs:SetShadowColor(0, 0, 0, 0.2)
	else
		fs:SetShadowColor(0, 0, 0, 1)
	end
	fs:SetShadowOffset((E.mult or 1), -(E.mult or 1))
	
	E["texts"][fs] = true
end

local function StyleButton(button)
	if button.SetHighlightTexture and not button.hover then
		local hover = button:CreateTexture("frame", nil, self)
		hover:SetTexture(1, 1, 1, 0.3)
		hover:SetInside()
		button.hover = hover
		button:SetHighlightTexture(hover)
	end
	
	if button.SetPushedTexture and not button.pushed then
		local pushed = button:CreateTexture("frame", nil, self)
		pushed:SetTexture(0.9, 0.8, 0.1, 0.3)
		pushed:SetInside()
		button.pushed = pushed
		button:SetPushedTexture(pushed)
	end
	
	if button.SetCheckedTexture and not button.checked then
		local checked = button:CreateTexture("frame", nil, self)
		checked:SetTexture(unpack(E["media"].rgbvaluecolor))
		checked:SetInside()
		checked:SetAlpha(0.3)
		button.checked = checked
		button:SetCheckedTexture(checked)
	end
	
	local cooldown = button:GetName() and _G[button:GetName().."Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetInside()
	end
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.Size then mt.Size = Size end
	if not object.Point then mt.Point = Point end
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.SetVirtualBorderColor then mt.SetVirtualBorderColor = SetVirtualBorderColor end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.Kill then mt.Kill = Kill end
	if not object.Width then mt.Width = Width end
	if not object.Height then mt.Height = Height end
	if not object.FontTemplate then mt.FontTemplate = FontTemplate end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.StyleButton then mt.StyleButton = StyleButton end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end
	
	object = EnumerateFrames(object)
end