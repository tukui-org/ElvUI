local addonName, addon = ...

--@usage - sets a frame to be outside of another frame
--@param1 - frame to anchor frame, if not set it will use the parent frame
--@param2 - the xOffset (defaults to the pixelPerfect value)
--@param3 - the yOffset (defaults to the pixelPerfect value)
local function SetOutside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or addon.pixelPerfect
	yOffset = yOffset or addon.pixelPerfect
	anchor = anchor or obj:GetParent()
	
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end
	
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -xOffset, yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', xOffset, -yOffset)
end

--@usage - sets a frame to be inside of another frame
--@param1 - frame to anchor frame, if not set it will use the parent frame
--@param2 - the xOffset (defaults to the pixelPerfect value)
--@param3 - the yOffset (defaults to the pixelPerfect value)
local function SetInside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or addon.pixelPerfect
	yOffset = yOffset or addon.pixelPerfect
	anchor = anchor or obj:GetParent()
	
	if obj:GetPoint() then
		obj:ClearAllPoints()
	end
	
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', xOffset, -yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', -xOffset, yOffset)
end

--@usage - sets the frames style to match the addons theme
--@param1 - the template to follow (not required)
		-- Transparent - a transparent backdrop texture
		-- Button - use the statusbar texture as a backdrop
local function SetTemplate(obj, template)
	local bgFile = addon.blankTexture
	local r, g, b = addon:UnpackColor(addon.db.core.primaryColor)
	local a = 1
	if(template == "Transparent") then
		a = addon.db.core.alphaLevel
	elseif(template == "Button") then
		bgFile = addon.statusbarTexture
	end

	obj:SetBackdrop({
		bgFile = bgFile, 
		edgeFile = addon.blankTexture, 
		tile = false, tileSize = 0, edgeSize = addon.pixelPerfect, 
		insets = { left = 0, right = 0, top = 0, bottom = 0}})
	obj:SetBackdropBorderColor(addon:UnpackColor(addon.db.core.secondaryColor))
	obj:SetBackdropColor(r, g, b, a)
end

--@usage - Creates a backdrop frame, does not adjust the backdrop of the target frame itself
--@param1 - template to follow (not required) (see SetTemplate)
--@param2 - if true, sets all points to match the object, if not set then the created frame will be around the target frame
local function CreateBackdrop(obj, template, setAllPoints)
	if(obj.backdrop) then return end

	obj.backdrop = CreateFrame("Frame", nil, obj)
	obj.backdrop:SetTemplate(template)
	
	if(setAllPoints) then
		obj:SetAllPoints()
	else
		obj:SetOutide()
	end
end

--@usage - create a glow around a frame
--@param1 - how far away from the frame to position the glow
--@param2 - the subName of the shadow, defaults to glow
--@param3 - the red color, defaults to 0
--@param4 - the green color, defaults to 0
--@param5 - the blue color, defaults to 0
local function CreateGlow(obj, offset, subName, r, g, b)
	subName = subName or "glow"
	offset = offset or 3
	if(obj[subName]) then return end

	local f = CreateFrame("Frame", nil, obj)
	local inset = offset + 2
	f:SetFrameLevel(0)
	f:SetOutside(offset, offset)
	f:SetBackdrop({
		edgeFile = addon.glowTex, edgeSize = offset,
		insets = {left = inset, right = inset, top = inset, bottom = inset}})
	f:SetBackdropColor(0, 0, 0, 0)
	f:SetBackdropBorderColor(r or 0, g or 0, b or 0, 0.9)

	obj[subName] = f
end

--@usage - removes all textures from the frame, param1 not required
--@param1 - if set to a draw layer ["OVERLAY", "ARTWORK", etc..] it will remove all textures on this draw layer
		--  if set to a specific texture it will remove all textures that don't match
local function StripTexture(obj, arg1)
	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if(arg1 and region:GetDrawLayer() == arg1) then
				region:SetTexture(nil)
			elseif arg1 and region:GetTexture() ~= arg1 then
				region:SetTexture(nil)
			else
				region:SetTexture(nil)
			end
		end
	end
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.CreateGlow then mt.CreateGlow = CreateGlow end
	if not object.StripTextures then mt.StripTextures = StripTextures end
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