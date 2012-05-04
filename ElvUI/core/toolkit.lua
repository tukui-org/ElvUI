local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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

--[[
	Multisample stuff
	Basically if a frames width/height is an odd number, it will appear blurry
]]

local index = getmetatable(CreateFrame('Frame')).__index
local floor = math.floor
local function SetWidth(self, width)
	if width and width ~= 0 then
		width = floor(width)
		if not E:IsEvenNumber(width) then
			width = width - 1
		end
	end
	
	if not self.IgnoreFixDimensions then
		index.SetWidth(self, width)
	end
end

local function SetHeight(self, height)
	if height and height ~= 0 then
		height = floor(height)
		if not E:IsEvenNumber(height) then
			height = height - 1
		end
	end
	
	if not self.IgnoreFixDimensions then
		index.SetHeight(self, height)
	end
end

local function SetSize(self, width, height)
	if width and width ~= 0 then
		width = floor(width)
		if not E:IsEvenNumber(width) then
			width = width - 1
		end
	end
	
	if height and height ~= 0 then
		height = floor(height)
		if not E:IsEvenNumber(height) then
			height = height - 1
		end
	end
	
	if not self.IgnoreFixDimensions then
		index.SetSize(self, width, height)
	end
end

local blackList = {
	['TemporaryEnchantFrame'] = true;
}

local function FixDimensions(frame)
	if frame:IsProtected() or (frame:GetName() and blackList[frame:GetName()]) or not frame.IgnoreFixDimensions then 
		return; 
	end
	frame.SetWidth = SetWidth
	frame.SetHeight = SetHeight
	frame.SetSize = SetSize
	
	frame:SetWidth(frame:GetWidth())
	frame:SetHeight(frame:GetHeight())
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

local function SetTemplate(f, t, glossTex, ignoreUpdates)
	GetTemplate(t)
	
	f.template = t
	f.glossTex = glossTex

	f:SetBackdrop({
	  bgFile = E["media"].blankTex, 
	  edgeFile = E["media"].blankTex, 
	  tile = false, tileSize = 0, edgeSize = E.mult, 
	  insets = { left = -E.mult, right = -E.mult, top = -E.mult, bottom = -E.mult}
	})

	if not f.backdropTexture and t ~= 'Transparent' then
		local backdropTexture = f:CreateTexture(nil, "BORDER")
		backdropTexture:SetDrawLayer("BACKGROUND", 1)
		f.backdropTexture = backdropTexture
	elseif t == 'Transparent' then
		f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
		
		if not f.oborder and not f.iborder then
			local border = CreateFrame("Frame", nil, f)
			border:Point("TOPLEFT", E.mult, -E.mult)
			border:Point("BOTTOMRIGHT", -E.mult, E.mult)
			border:SetBackdrop({
				edgeFile = E["media"].blankTex, 
				edgeSize = E.mult, 
				insets = { left = E.mult, right = E.mult, top = E.mult, bottom = E.mult }
			})
			border:SetBackdropBorderColor(0, 0, 0, 1)
			f.iborder = border
			
			if f.oborder then return end
			local border = CreateFrame("Frame", nil, f)
			border:Point("TOPLEFT", -E.mult, E.mult)
			border:Point("BOTTOMRIGHT", E.mult, -E.mult)
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
		f.backdropTexture:Point("TOPLEFT", f, "TOPLEFT", 2, -2)
		f.backdropTexture:Point("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)		
	end
	
	f:SetBackdropBorderColor(borderr, borderg, borderb)
	
	if not ignoreUpdates then
		E["frames"][f] = true
	end
end

local function CreateBackdrop(f, t, tex)
	if not t then t = "Default" end
	
	local b = CreateFrame("Frame", nil, f)
	b:Point("TOPLEFT", -2, 2)
	b:Point("BOTTOMRIGHT", 2, -2)
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
	shadow:Point("TOPLEFT", -3, 3)
	shadow:Point("BOTTOMLEFT", -3, -3)
	shadow:Point("TOPRIGHT", 3, 3)
	shadow:Point("BOTTOMRIGHT", 3, -3)
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
			if kill then
				region:Kill()
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
	if not fontSize then fontSize = E.db.general.fontsize end
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
		hover:Point('TOPLEFT', 2, -2)
		hover:Point('BOTTOMRIGHT', -2, 2)
		button.hover = hover
		button:SetHighlightTexture(hover)
	end
	
	if button.SetPushedTexture and not button.pushed then
		local pushed = button:CreateTexture("frame", nil, self)
		pushed:SetTexture(0.9, 0.8, 0.1, 0.3)
		pushed:Point('TOPLEFT', 2, -2)
		pushed:Point('BOTTOMRIGHT', -2, 2)
		button.pushed = pushed
		button:SetPushedTexture(pushed)
	end
	
	if button.SetCheckedTexture and not button.checked then
		local checked = button:CreateTexture("frame", nil, self)
		checked:SetTexture(unpack(E["media"].rgbvaluecolor))
		checked:Point('TOPLEFT', 2, -2)
		checked:Point('BOTTOMRIGHT', -2, 2)
		checked:SetAlpha(0.3)
		button.checked = checked
		button:SetCheckedTexture(checked)
	end
	
	local cooldown = _G[button:GetName().."Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:Point('TOPLEFT', 2, -2)
		cooldown:Point('BOTTOMRIGHT', -2, 2)
	end
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.FixDimensions then mt.FixDimensions = FixDimensions end
	if not object.Size then mt.Size = Size end
	if not object.Point then mt.Point = Point end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
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

	if object.FixDimensions then
		object:FixDimensions()
	end	
	
	object = EnumerateFrames(object)
end