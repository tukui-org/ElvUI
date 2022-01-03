--[[
This library contains work of Hendrick "nevcairiel" Leppkes
https://www.wowace.com/projects/libbuttonglow-1-0
]]

-- luacheck: globals CreateFromMixins ObjectPoolMixin CreateTexturePool CreateFramePool

local MAJOR_VERSION = "LibCustomGlow-1.0"
local MINOR_VERSION = 24
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end
local Masque = LibStub("Masque", true)

local L = CustomGlow.L


local textureList = {
	["empty"] = [[Interface\AdventureMap\BrokenIsles\AM_29]],
	["white"] = [[Interface\BUTTONS\WHITE8X8]],
	["shine"] = [[Interface\Artifacts\Artifacts]]
}

local GlowParent = UIParent

local GlowMaskPool = CreateFromMixins(ObjectPoolMixin)
lib.GlowMaskPool = GlowMaskPool
local function MaskPoolFactory(maskPool)
	return maskPool.parent:CreateMaskTexture()
end

local MaskPoolResetter = function(maskPool,mask)
	mask:Hide()
	mask:ClearAllPoints()
end

ObjectPoolMixin.OnLoad(GlowMaskPool,MaskPoolFactory,MaskPoolResetter)
GlowMaskPool.parent =  GlowParent

local TexPoolResetter = function(pool,tex)
	local maskNum = tex:GetNumMaskTextures()
	for i = maskNum,1 do
		tex:RemoveMaskTexture(tex:GetMaskTexture(i))
	end
	tex:Hide()
	tex:ClearAllPoints()
		tex:SetRotation(0)
end
local GlowTexPool = CreateTexturePool(GlowParent ,"ARTWORK",7,nil,TexPoolResetter)
lib.GlowTexPool = GlowTexPool

local FramePoolResetter = function(framePool,frame)
	frame:SetScript("OnUpdate",nil)
	local parent = frame:GetParent()
	if parent[frame.name] then
		parent[frame.name] = nil
	end
	if frame.textures then
		for _, texture in pairs(frame.textures) do
			GlowTexPool:Release(texture)
		end
	end
	if frame.bg then
		GlowTexPool:Release(frame.bg)
		frame.bg = nil
	end
	if frame.masks then
		for _,mask in pairs(frame.masks) do
			GlowMaskPool:Release(mask)
		end
		frame.masks = nil
	end
	frame.textures = {}
	frame.inf = {}
	frame.name = nil
	frame.timer = nil
		frame:SetAlpha(1)
	frame:Hide()
	frame:ClearAllPoints()
end
local GlowFramePool = CreateFramePool("Frame",GlowParent,nil,FramePoolResetter)
lib.GlowFramePool = GlowFramePool

local function addFrameAndTex(r,color,name,key,N,xOffset,yOffset,texture,texCoord,desaturated,frameLevel)
	key = key or ""
	frameLevel = frameLevel or 8
	xOffset = xOffset or 0
	yOffset = yOffset or 0
	local update = true

	if not r[name..key] then
			r[name..key] = GlowFramePool:Acquire()
			r[name..key]:SetParent(r)
			r[name..key].name = name..key
			update = false
	end
	local f = r[name..key]
	f:SetFrameLevel(r:GetFrameLevel()+frameLevel)
	f:SetPoint("TOPLEFT",r,"TOPLEFT",-xOffset,yOffset)
	f:SetPoint("BOTTOMRIGHT",r,"BOTTOMRIGHT",xOffset,-yOffset)
	f:Show()

	if not f.textures then
			f.textures = {}
	end

	for i=1,N do
			if not f.textures[i] then
					f.textures[i] = GlowTexPool:Acquire()
					f.textures[i]: SetTexture(texture)
					f.textures[i]: SetTexCoord(texCoord[1],texCoord[2],texCoord[3],texCoord[4])
					f.textures[i]: SetDesaturated(desaturated)
					f.textures[i]: SetParent(f)
					f.textures[i]: SetDrawLayer("ARTWORK",7)
			end
			f.textures[i]:SetVertexColor(color[1],color[2],color[3],color[4])
			f.textures[i]:Show()
	end
	while #f.textures>N do
			GlowTexPool:Release(f.textures[#f.textures])
			table.remove(f.textures)
	end
	return update
end




local hsvFrame = CreateFrame("Colorselect")
-- HSV transition, for a much prettier color transition in many cases
-- see http://www.wowinterface.com/forums/showthread.php?t=48236
local function GetHSVTransition(perc, c1, c2)
  --get hsv color for colorA
  hsvFrame:SetColorRGB(c1[1], c1[2], c1[3])
  local h1, s1, v1 = hsvFrame:GetColorHSV() -- hue, saturation, value
  --get hsv color for colorB
  hsvFrame:SetColorRGB(c2[1], c2[2], c2[3])
  local h2, s2, v2 = hsvFrame:GetColorHSV() -- hue, saturation, value
  -- find the shortest arc through the color circle, then interpolate
  local diff = h2 - h1
  if diff < -180 then
	diff = diff + 360
  elseif diff > 180 then
	diff = diff - 360
  end

  local h3 = (h1 + perc * diff) % 360
  local s3 = s1 - ( s1 - s2 ) * perc
  local v3 = v1 - ( v1 - v2 ) * perc
  --get the RGB values of the new color
  hsvFrame:SetColorHSV(h3, s3, v3)
  local r, g, b = hsvFrame:GetColorRGB()
  --interpolate alpha
  local a = c1[4] - ( c1[4] - c2[4] ) * perc
  --return the new color
  return {r, g, b, a}
end

local function SetGradA(texture, direction, c1, c2)
	texture:SetGradientAlpha(direction, c1[1], c1[2], c1[3], c1[4], c2[1], c2[2], c2[3], c2[4])
end

local function DeepCopy(original)
	local copy
	if type(original) == "table" then
		copy = {}
		for k,v in pairs(original) do
			copy[k] = DeepCopy(v)
		end
	else
		copy = original
	end
	return copy
end

--Return copy of options table with added missing elements from default--
local function AcquireOptions(options, default, internal)
	if not(internal) then
		options = DeepCopy(options) or {}
	else
		options = options or {}
	end
	for k,v in pairs(default) do
		if type(v) == "table" then
			options[k] = AcquireOptions(options[k], v, true)
		else
			if options[k] == nil then
				options[k] = v
			end
		end
	end
	return options
end

local GlowList = {}
lib.GetGlows = function()
	return DeepCopy(GlowList)
end


---- Border Internal Funcitons ----

local function BorderGradientCorners(inf, elapsed)
	local c1, c2, c3, c4, p1, p2, p3, p4
	g = inf.gradient
	local gN = #g
	local gProgress = inf.gProgress or 0
	gProgress = (gProgress + elapsed * inf.gradientFrequency)%1
	inf.gProgress = gProgress

	p1 = (gProgress + 0.001)%1
	p2 = (gProgress + inf.width / (inf.width + inf.height) / 2)%1
	p3 = (gProgress + 0.5) %1
	p4 = (gProgress + 0.5 + inf.width / (inf.width + inf.height) / 2)%1

	c1 = GetHSVTransition ((p1 * gN) % 1 , g[ceil(p1 * gN)], g[ceil(p1 * gN) % gN + 1])
	c2 = GetHSVTransition ((p2 * gN) % 1 , g[ceil(p2 * gN)], g[ceil(p2 * gN) % gN + 1])
	c3 = GetHSVTransition ((p3 * gN) % 1 , g[ceil(p3 * gN)], g[ceil(p3 * gN) % gN + 1])
	c4 = GetHSVTransition ((p4 * gN) % 1 , g[ceil(p4 * gN)], g[ceil(p4 * gN) % gN + 1])
	return c1, c2, c3, c4
end

local function BorderSet4LinesCenter(f, update)
	local inf = f.inf
	local tails = inf.tail.list
	if not(update) then
		for _, v in pairs(tails) do
			v:ClearAllPoints()
		end
		if inf.tail.mirror then
				tails[1]:SetPoint("TOP", f, "TOP")
				tails[2]:SetPoint("RIGHT", f, "RIGHT")
				tails[3]:SetPoint("BOTTOM", f, "BOTTOM")
				tails[4]:SetPoint("LEFT", f, "LEFT")

				tails[5]:Hide()
				tails[6]:Hide()
				tails[7]:Hide()
				tails[8]:Hide()

				tails[1]:SetHeight(inf.th)
				tails[2]:SetWidth(inf.th)
				tails[3]:SetHeight(inf.th)
				tails[4]:SetWidth(inf.th)
		else
			if inf.tail.clockwise then
				tails[1]:SetPoint("TOPRIGHT", f, "TOP")
				tails[2]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
				tails[3]:SetPoint("TOPLEFT", f, "LEFT")
				tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
				tails[5]:SetPoint("BOTTOMLEFT", f, "BOTTOM")
				tails[6]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
				tails[7]:SetPoint("BOTTOMRIGHT", f, "RIGHT")
				tails[8]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
			else
				tails[1]:SetPoint("TOPLEFT", f, "TOP")
				tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
				tails[3]:SetPoint("TOPRIGHT", f, "RIGHT")
				tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
				tails[5]:SetPoint("BOTTOMRIGHT", f, "BOTTOM")
				tails[6]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
				tails[7]:SetPoint("BOTTOMLEFT", f, "LEFT")
				tails[8]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
			end

			tails[5]:Show()
			tails[6]:Show()
			tails[7]:Show()
			tails[8]:Show()

			tails[1]:SetHeight(inf.th)
			tails[2]:SetWidth(inf.th)
			tails[3]:SetWidth(inf.th)
			tails[4]:SetHeight(inf.th)
			tails[5]:SetHeight(inf.th)
			tails[6]:SetWidth(inf.th)
			tails[7]:SetWidth(inf.th)
			tails[8]:SetHeight(inf.th)
		end
	end

	local width, height = f:GetSize()
	if inf.tail.mirror then
		tails[1]:SetWidth(width)
		tails[2]:SetHeight(height - inf.th * 2)
		tails[3]:SetWidth(width)
		tails[4]:SetHeight(height - inf.th * 2)
	else
		tails[1]:SetWidth(width / 2)
		tails[2]:SetHeight(height / 2 - inf.th)
		tails[3]:SetHeight(height / 2)
		tails[4]:SetWidth(width / 2 - inf.th)
		tails[5]:SetWidth(width / 2)
		tails[6]:SetHeight(height / 2 - inf.th)
		tails[7]:SetHeight(height / 2)
		tails[8]:SetWidth(width / 2 - inf.th)
	end
end

local function BorderUpdate4LinesCenter(f, progress)
	local inf = f.inf
	local tails = inf.tail.list
	local oldProgress = inf.tail.old

	if inf.tail.mirror then
		local newW = inf.width * (1 - progress)
		local newH = (inf.height - inf.th * 2) * (1 - progress)
		tails[1]:SetWidth(newW)
		tails[2]:SetHeight(newH)
		tails[3]:SetWidth(newW)
		tails[4]:SetHeight(newH)
	else
		local cornerP = inf.width / (inf.width + inf.height)
		local updt
		if progress < cornerP then
			if oldProgress > cornerP or oldProgress <= 0 then
				tails[3]:Show()
				tails[4]:Show()
				tails[7]:Show()
				tails[8]:Show()
				updt = true
			else
				local stageProg = 1 - progress / cornerP
				tails[4]:SetWidth(stageProg * (inf.width / 2 - inf.th))
				tails[8]:SetWidth(stageProg * (inf.width / 2 - inf.th))
			end
		else
			if oldProgress >= 0.99 or oldProgress < cornerP then
				tails[3]:Show()
				tails[4]:Hide()
				tails[7]:Show()
				tails[8]:Hide()
				updt = true
			else
				local stageProg = (1 - progress) / (1 - cornerP)
				tails[3]:SetHeight(stageProg * (inf.height / 2))
				tails[7]:SetHeight(stageProg * (inf.height / 2))
			end
		end

		if progress < (1 - cornerP) then
			if oldProgress > (1 - cornerP) or oldProgress <= 0 then
				tails[1]:Show()
				tails[2]:Show()
				tails[5]:Show()
				tails[6]:Show()
				updt = true
			else
				local stageProg = 1 - progress / (1 - cornerP)
				tails[2]:SetHeight(stageProg * (inf.height / 2 - inf.th))
				tails[6]:SetHeight(stageProg * (inf.height / 2 - inf.th))
			end
		else
			if oldProgress >= 0.99 or oldProgress < (1 - cornerP) then
				tails[1]:Show()
				tails[2]:Hide()
				tails[5]:Show()
				tails[6]:Hide()
				updt = true
			else
				local stageProg = (1 - progress) / cornerP
				tails[1]:SetWidth(stageProg * (inf.width / 2))
				tails[5]:SetWidth(stageProg * (inf.width / 2))
			end
		end

		if updt then
				BorderSet4LinesCenter(f, true)
				if progress < cornerP then
					local stageProg = 1 - progress / cornerP
					tails[4]:SetWidth(stageProg * (inf.width / 2- inf.th))
					tails[8]:SetWidth(stageProg * (inf.width / 2- inf.th))
				else
					local stageProg = (1 - progress) / (1 - cornerP)
					tails[3]:SetHeight(stageProg * (inf.height / 2))
					tails[7]:SetHeight(stageProg * (inf.height / 2))
				end

				if progress < (1 - cornerP) then
					local stageProg = 1 - progress / (1 - cornerP)
					tails[2]:SetHeight(stageProg * (inf.height / 2 - inf.th))
					tails[6]:SetHeight(stageProg * (inf.height / 2 - inf.th))
				else
					local stageProg = (1 - progress) / cornerP
					tails[1]:SetWidth(stageProg * (inf.width / 2))
					tails[5]:SetWidth(stageProg * (inf.width / 2))
				end
		end
	end
	inf.tail.old = progress
end

local function BorderGradient4LinesCenter(f, progress, elapsed)
	local inf = f.inf
	local tails = inf.tail.list
	local c1, c2, c3, c4 = BorderGradientCorners(inf, elapsed)


	if inf.tail.mirror then
		local c1x1 = GetHSVTransition(progress / 2, c2, c1)
		local c1x2 = GetHSVTransition(progress / 2, c1, c2)
		local c2x1 = GetHSVTransition(progress / 2, c4, c1)
		local c2x2 = GetHSVTransition(progress / 2, c1, c4)
		local c3x1 = GetHSVTransition(progress / 2, c3, c4)
		local c3x2 = GetHSVTransition(progress / 2, c4, c3)
		local c4x1 = GetHSVTransition(progress / 2, c3, c2)
		local c4x2 = GetHSVTransition(progress / 2, c2, c3)

		SetGradA(tails[1], "HORIZONTAL", c1x1, c1x2)
		SetGradA(tails[2], "VERTICAL", c2x1, c2x2)
		SetGradA(tails[3], "HORIZONTAL", c3x1, c3x2)
		SetGradA(tails[4], "VERTICAL", c4x1, c4x2)

	else
		local c12 = GetHSVTransition(0.5, c1, c2)
		local c23 = GetHSVTransition(0.5, c2, c3)
		local c34 = GetHSVTransition(0.5, c3, c4)
		local c41 = GetHSVTransition(0.5, c4, c1)

		local cornerP = inf.height / (inf.width + inf.height)
		if inf.tail.clockwise then
			if progress < cornerP then
				local c2x = GetHSVTransition(progress, c23, c2)
				local c6x = GetHSVTransition(progress, c41, c4)
				SetGradA(tails[1], "HORIZONTAL", c2, c12)
				SetGradA(tails[2], "VERTICAL", c2x, c2)
				SetGradA(tails[5], "HORIZONTAL", c34, c4)
				SetGradA(tails[6], "VERTICAL", c4, c6x)
			else
				local c1x = GetHSVTransition(progress, c2, c12)
				local c5x = GetHSVTransition(progress, c4, c34)
				SetGradA(tails[1], "HORIZONTAL", c1x, c12)
				SetGradA(tails[5], "HORIZONTAL", c34, c5x)
			end
			if progress < 1 - cornerP then
				local c4x = GetHSVTransition(progress, c34, c3)
				local c8x = GetHSVTransition(progress, c12, c1)
				SetGradA(tails[3], "VERTICAL", c3, c23)
				SetGradA(tails[4], "HORIZONTAL", c3, c4x)
				SetGradA(tails[7], "VERTICAL", c41, c1)
				SetGradA(tails[8], "HORIZONTAL", c8x, c1)
			else
				local c3x = GetHSVTransition(progress, c3, c34)
				local c7x = GetHSVTransition(progress, c1, c41)
				SetGradA(tails[3], "VERTICAL", c3x, c23)
				SetGradA(tails[7], "VERTICAL", c41, c7x)
			end
		else
			if progress < cornerP then
				local c2x = GetHSVTransition(progress, c41, c1)
				local c6x = GetHSVTransition(progress, c23, c3)
				SetGradA(tails[1], "HORIZONTAL", c12, c1)
				SetGradA(tails[2], "VERTICAL", c2x, c1)
				SetGradA(tails[5], "HORIZONTAL", c3, c34)
				SetGradA(tails[6], "VERTICAL", c3, c6x)
			else
				local c1x = GetHSVTransition(progress, c1, c12)
				local c5x = GetHSVTransition(progress, c3, c34)
				SetGradA(tails[1], "HORIZONTAL", c12, c1x)
				SetGradA(tails[5], "HORIZONTAL", c5x, c34)
			end
			if progress < 1 - cornerP then
				local c4x = GetHSVTransition(progress, c34, c4)
				local c8x = GetHSVTransition(progress, c12, c2)
				SetGradA(tails[3], "VERTICAL", c4, c41)
				SetGradA(tails[4], "HORIZONTAL", c4x, c4)
				SetGradA(tails[7], "VERTICAL", c23, c2)
				SetGradA(tails[8], "HORIZONTAL", c2, c8x)
			else
				local c3x = GetHSVTransition(progress, c4, c41)
				local c7x = GetHSVTransition(progress, c2, c23)
				SetGradA(tails[3], "VERTICAL", c3x, c41)
				SetGradA(tails[7], "VERTICAL", c23, c7x)
			end
		end
	end
end

local function BorderSet4LinesCorner(f, update)
	local inf = f.inf
	local tails = inf.tail.list
	if not(update) then
		for _, v in pairs(tails) do
			v:ClearAllPoints()
		end
		if inf.tail.mirror then
			tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT")
			tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
			tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
			tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
			tails[5]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
			tails[6]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
			tails[7]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
			tails[8]:SetPoint("TOPLEFT", f, "TOPLEFT")

			tails[5]:Show()
			tails[6]:Show()
			tails[7]:Show()
			tails[8]:Show()

			tails[1]:SetHeight(inf.th)
			tails[2]:SetWidth(inf.th)
			tails[3]:SetWidth(inf.th)
			tails[4]:SetHeight(inf.th)
			tails[5]:SetHeight(inf.th)
			tails[6]:SetWidth(inf.th)
			tails[7]:SetWidth(inf.th)
			tails[8]:SetHeight(inf.th)
		else
			if inf.tail.clockwise then
				tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT")
				tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
				tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
				tails[4]:SetPoint("TOPLEFT", f, "TOPLEFT")
			else
				tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT")
				tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT")
				tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
				tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
			end
			tails[5]:Hide()
			tails[6]:Hide()
			tails[7]:Hide()
			tails[8]:Hide()

			tails[1]:SetHeight(inf.th)
			tails[2]:SetWidth(inf.th)
			tails[3]:SetHeight(inf.th)
			tails[4]:SetWidth(inf.th)
		end
	end
	local width, height = f:GetSize()
	if inf.tail.mirror then
		tails[1]:SetWidth(width / 2)
		tails[2]:SetHeight(height / 2 - inf.th)
		tails[3]:SetHeight(height / 2 - inf.th)
		tails[4]:SetWidth(width / 2)
		tails[5]:SetWidth(width / 2)
		tails[6]:SetHeight(height / 2 - inf.th)
		tails[7]:SetHeight(height / 2 - inf.th)
		tails[8]:SetWidth(width / 2)
	else
		tails[1]:SetWidth(width - inf.th)
		tails[2]:SetHeight(height - inf.th)
		tails[3]:SetWidth(width - inf.th)
		tails[4]:SetHeight(height - inf.th)
	end
end

local function BorderUpdate4LinesCorner(f, progress)
	local inf = f.inf
	local tails = inf.tail.list

	if inf.tail.mirror then
		local newW = inf.width / 2 * (1 - progress)
		local newH = (inf.height / 2 - inf.th) * (1 - progress)
		tails[1]:SetWidth(newW)
		tails[2]:SetHeight(newH)
		tails[3]:SetHeight(newH)
		tails[4]:SetWidth(newW)
		tails[5]:SetWidth(newW)
		tails[6]:SetHeight(newH)
		tails[7]:SetHeight(newH)
		tails[8]:SetWidth(newW)
	else
		local newW = (inf.width - inf.th) * (1 - progress)
		local newH = (inf.height - inf.th) * (1 - progress)
		tails[1]:SetWidth(newW)
		tails[2]:SetHeight(newH)
		tails[3]:SetWidth(newW)
		tails[4]:SetHeight(newH)
	end
end

local function BorderGradient4LinesCorner(f, progress, elapsed)
	local inf = f.inf
	local tails = inf.tail.list
	local c1, c2, c3, c4 = BorderGradientCorners(inf, elapsed)


	if inf.tail.mirror then
		local gradProg = 0.5 + progress / 2
		local c1x = GetHSVTransition(gradProg, c2, c1)
		local c2x = GetHSVTransition(gradProg, c4, c1)
		local c3x = GetHSVTransition(gradProg, c1, c4)
		local c4x = GetHSVTransition(gradProg, c3, c4)
		local c5x = GetHSVTransition(gradProg, c4, c3)
		local c6x = GetHSVTransition(gradProg, c2, c3)
		local c7x = GetHSVTransition(gradProg, c3, c2)
		local c8x = GetHSVTransition(gradProg, c1, c2)

		SetGradA(tails[1], "HORIZONTAL", c1x, c1)
		SetGradA(tails[2], "VERTICAL", c2x, c1)
		SetGradA(tails[3], "VERTICAL", c4, c3x)
		SetGradA(tails[4], "HORIZONTAL", c4x, c4)
		SetGradA(tails[5], "HORIZONTAL", c3, c5x)
		SetGradA(tails[6], "VERTICAL", c3, c6x)
		SetGradA(tails[7], "VERTICAL", c7x, c2)
		SetGradA(tails[8], "HORIZONTAL", c2, c8x)
	else
		if inf.tail.clockwise then
			local c1x = GetHSVTransition(progress, c2, c1)
			local c2x = GetHSVTransition(progress, c1, c4)
			local c3x = GetHSVTransition(progress, c4, c3)
			local c4x = GetHSVTransition(progress, c3, c2)

			SetGradA(tails[1], "HORIZONTAL", c1x, c1)
			SetGradA(tails[2], "VERTICAL", c4, c2x)
			SetGradA(tails[3], "HORIZONTAL", c3, c3x)
			SetGradA(tails[4], "VERTICAL", c4x, c2)
		else
			local c1x = GetHSVTransition(progress, c1, c2)
			local c2x = GetHSVTransition(progress, c4, c1)
			local c3x = GetHSVTransition(progress, c3, c4)
			local c4x = GetHSVTransition(progress, c2, c3)

			SetGradA(tails[1], "HORIZONTAL", c2, c1x)
			SetGradA(tails[2], "VERTICAL", c2x, c1)
			SetGradA(tails[3], "HORIZONTAL", c3x, c4)
			SetGradA(tails[4], "VERTICAL", c4x, c2)
		end
	end
end

local function BorderSet2LinesCenter(f, update)
	local inf = f.inf
	local tails = inf.tail.list
	if not(update) then
		for _, v in pairs(tails) do
			v:ClearAllPoints()
		end
		if inf.tail.mirror then
			if inf.tail.startPoint == "LEFT" or inf.tail.startPoint == "RIGHT" then
				inf.tail.Set1 = f.SetHeight
				inf.tail.Set2 = f.SetWidth
				tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
				tails[2]:SetPoint("TOP", f, "TOP")
				tails[3]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
				tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
				tails[5]:SetPoint("BOTTOM", f, "BOTTOM")
				tails[6]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
			else
				inf.tail.Set1 = f.SetWidth
				inf.tail.Set2 = f.SetHeight
				tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
				tails[2]:SetPoint("LEFT", f, "LEFT")
				tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
				tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
				tails[5]:SetPoint("RIGHT", f, "RIGHT")
				tails[6]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
			end
		else
			if inf.tail.startPoint == "TOP" or inf.tail.startPoint == "BOTTOM" then
				inf.tail.Set1 = f.SetWidth
				inf.tail.Set2 = f.SetHeight
				if inf.tail.clockwise then
					tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
					tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOM")
					tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[5]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[6]:SetPoint("TOPRIGHT", f, "TOP")
				else
					tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOM")
					tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", - inf.th, 0)
					tails[5]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[6]:SetPoint("TOPLEFT", f, "TOP")
				end
			else
				inf.tail.Set1 = f.SetHeight
				inf.tail.Set2 = f.SetWidth
				if inf.tail.clockwise then
					tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
					tails[3]:SetPoint("BOTTOMRIGHT", f, "RIGHT")
					tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[5]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[6]:SetPoint("TOPLEFT", f, "LEFT")
				else
					tails[1]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
					tails[3]:SetPoint("TOPRIGHT", f, "RIGHT")
					tails[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[5]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[6]:SetPoint("BOTTOMLEFT", f, "LEFT")
				end
			end
		end
		inf.tail.Set2(tails[1], inf.th)
		inf.tail.Set1(tails[2], inf.th)
		inf.tail.Set2(tails[3], inf.th)
		inf.tail.Set2(tails[4], inf.th)
		inf.tail.Set1(tails[5], inf.th)
		inf.tail.Set2(tails[6], inf.th)
	end
	if inf.tail.startPoint == "TOP" or inf.tail.startPoint == "BOTTOM" then
		inf.tail.size1 = f:GetWidth()
		inf.tail.size2 = f:GetHeight()
	else
		inf.tail.size1 = f:GetHeight()
		inf.tail.size2 = f:GetWidth()
	end
	if inf.tail.mirror then
		inf.tail.Set1(tails[1], inf.tail.size1 / 2 - inf.th)
		inf.tail.Set2(tails[2], inf.tail.size2)
		inf.tail.Set1(tails[3], inf.tail.size1 / 2 - inf.th)
		inf.tail.Set1(tails[4], inf.tail.size1 / 2 - inf.th)
		inf.tail.Set2(tails[5], inf.tail.size2)
		inf.tail.Set1(tails[6], inf.tail.size1 / 2 - inf.th)
	else
		inf.tail.Set1(tails[1], inf.tail.size1/2 - inf.th)
		inf.tail.Set2(tails[2], inf.tail.size2- inf.th)
		inf.tail.Set1(tails[3], inf.tail.size1/2)
		inf.tail.Set1(tails[4], inf.tail.size1/2 - inf.th)
		inf.tail.Set2(tails[5], inf.tail.size2 - inf.th)
		inf.tail.Set1(tails[6], inf.tail.size1/2)
	end
end

local function BorderUpdate2LinesCenter(f, progress)
	local inf = f.inf
	local tails = inf.tail.list
	local oldProgress = inf.tail.old

	if inf.tail.mirror then
		local cornerP = inf.tail.size1 / (inf.tail.size1 + inf.tail.size2)
		if progress < cornerP then
			if oldProgress > cornerP or oldProgress <= 0 then
				for _,v in pairs(tails) do
					v:Show()
				end
				BorderSet2LinesCenter(f, true)
			end
			local stageProg = 1 - progress / cornerP
			inf.tail.Set1(tails[1], stageProg * (inf.tail.size1 / 2 - inf.th))
			inf.tail.Set1(tails[3], stageProg * (inf.tail.size1 / 2 - inf.th))
			inf.tail.Set1(tails[4], stageProg * (inf.tail.size1 / 2 - inf.th))
			inf.tail.Set1(tails[6], stageProg * (inf.tail.size1 / 2 - inf.th))
		else
			if oldProgress >= 0.99 or oldProgress < cornerP then
				tails[1]:Hide()
				tails[2]:Show()
				tails[3]:Hide()
				tails[4]:Hide()
				tails[5]:Show()
				tails[6]:Hide()
				BorderSet2LinesCenter(f, true)
			end
			local stageProg = (1 - progress) / (1 - cornerP)
			inf.tail.Set2(tails[2], stageProg * inf.tail.size2)
			inf.tail.Set2(tails[5], stageProg * inf.tail.size2)
		end
	else
		local cornerP = inf.tail.size1/2/(inf.tail.size1 + inf.tail.size2)
		if progress < cornerP then
			if oldProgress > cornerP or oldProgress <= 0 then
				for _, v in pairs(tails) do
					v:Show()
				end
				BorderSet2LinesCenter(f, true)
			end
			local stageProg = 1 - progress / cornerP
			inf.tail.Set1(tails[1], stageProg * (inf.tail.size1 / 2 - inf.th))
			inf.tail.Set1(tails[4], stageProg * (inf.tail.size1 / 2 - inf.th))
		elseif progress < (1 - cornerP) then
			if oldProgress > (1 - cornerP) or oldProgress <= cornerP then
				tails[1]:Hide()
				tails[2]:Show()
				tails[3]:Show()
				tails[4]:Hide()
				tails[5]:Show()
				tails[6]:Show()
				BorderSet2LinesCenter(f, true)
			end
			local stageProg = (1 - cornerP - progress) / ( 1 - 2 * cornerP)
			inf.tail.Set2(tails[2], stageProg * (inf.tail.size2 - inf.th))
			inf.tail.Set2(tails[5], stageProg * (inf.tail.size2 - inf.th))
		elseif progress < 1 then
			if oldProgress >= 0.99 or oldProgress < (1 - cornerP) then
				tails[1]:Hide()
				tails[2]:Hide()
				tails[3]:Show()
				tails[4]:Hide()
				tails[5]:Hide()
				tails[6]:Show()
				BorderSet2LinesCenter(f, true)
			end
				local stageProg = (1 - progress) / cornerP
				inf.tail.Set1(tails[3], stageProg * (inf.tail.size1 / 2))
				inf.tail.Set1(tails[6], stageProg * (inf.tail.size1 / 2))
		end
	end
	inf.tail.old = progress
end

local function BorderGradient2LinesCenter(f, progress, elapsed)
	local inf = f.inf
	local tails = inf.tail.list
	local c1, c2, c3, c4 = BorderGradientCorners(inf, elapsed)

	if inf.tail.mirror then
		local cornerP = inf.tail.size1 / (inf.tail.size1 + inf.tail.size2)
		if progress < cornerP then
			local stageProg = progress / cornerP
			if inf.tail.startPoint == "LEFT" or inf.tail.startPoint == "RIGHT" then
				local c23 = GetHSVTransition(0.5, c2, c3)
				local c41 = GetHSVTransition(0.5, c4, c1)
				local c1x = GetHSVTransition(stageProg, c41, c1)
				local c3x = GetHSVTransition(stageProg, c23, c2)
				local c4x = GetHSVTransition(stageProg, c23, c3)
				local c6x = GetHSVTransition(stageProg, c41, c4)
				SetGradA(tails[1], "VERTICAL", c1x, c1)
				SetGradA(tails[2], "HORIZONTAL", c2, c1)
				SetGradA(tails[3], "VERTICAL", c3x, c2)
				SetGradA(tails[4], "VERTICAL", c3, c4x)
				SetGradA(tails[5], "HORIZONTAL", c3, c4)
				SetGradA(tails[6], "VERTICAL", c4, c6x)
			else
				local c12 = GetHSVTransition(0.5, c1, c2)
				local c34 = GetHSVTransition(0.5, c3, c4)
				local c1x = GetHSVTransition(stageProg, c12, c2)
				local c3x = GetHSVTransition(stageProg, c34, c3)
				local c4x = GetHSVTransition(stageProg, c34, c4)
				local c6x = GetHSVTransition(stageProg, c12, c1)
				SetGradA(tails[1], "HORIZONTAL", c2, c1x)
				SetGradA(tails[2], "VERTICAL", c3, c2)
				SetGradA(tails[3], "HORIZONTAL", c3, c3x)
				SetGradA(tails[4], "HORIZONTAL", c4x, c4)
				SetGradA(tails[5], "VERTICAL", c4, c1)
				SetGradA(tails[6], "HORIZONTAL", c6x, c1)
			end
		else
			local stageProg = (progress - cornerP)/ (1 - cornerP) / 2
			if inf.tail.startPoint == "LEFT" or inf.tail.startPoint == "RIGHT" then
				local c2x1 = GetHSVTransition(stageProg, c2, c1)
				local c2x2 = GetHSVTransition(stageProg, c1, c2)
				local c5x1 = GetHSVTransition(stageProg, c3, c4)
				local c5x2 = GetHSVTransition(stageProg, c4, c3)
				SetGradA(tails[2], "HORIZONTAL", c2x1, c2x2)
				SetGradA(tails[5], "HORIZONTAL", c5x1, c5x2)
			else
				local c2x1 = GetHSVTransition(stageProg, c3, c2)
				local c2x2 = GetHSVTransition(stageProg, c2, c3)
				local c5x1 = GetHSVTransition(stageProg, c4, c1)
				local c5x2 = GetHSVTransition(stageProg, c1, c4)
				SetGradA(tails[2], "VERTICAL", c2x1, c2x2)
				SetGradA(tails[5], "VERTICAL", c5x1, c5x2)
			end
		end
	else
		local cornerP = inf.tail.size1 / (inf.tail.size1 + inf.tail.size2) / 2
		if inf.tail.clockwise then
			if progress < cornerP then
				local stageProg = progress / cornerP
				if inf.tail.startPoint == "TOP" or inf.tail.startPoint == "BOTTOM" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c1x = GetHSVTransition(stageProg, c12, c1)
					local c4x = GetHSVTransition(stageProg, c34, c3)

					SetGradA(tails[1], "HORIZONTAL", c1x, c1)
					SetGradA(tails[2], "VERTICAL", c4, c1)
					SetGradA(tails[3], "HORIZONTAL", c34, c4)
					SetGradA(tails[4], "HORIZONTAL", c3, c4x)
					SetGradA(tails[5], "VERTICAL", c3, c2)
					SetGradA(tails[6], "HORIZONTAL", c2, c12)

				else
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c1x = GetHSVTransition(stageProg, c23, c2)
					local c4x = GetHSVTransition(stageProg, c41, c4)

					SetGradA(tails[1], "VERTICAL", c1x, c2)
					SetGradA(tails[2], "HORIZONTAL", c2, c1)
					SetGradA(tails[3], "VERTICAL", c41, c1)
					SetGradA(tails[4], "VERTICAL", c4, c4x)
					SetGradA(tails[5], "HORIZONTAL", c3, c4)
					SetGradA(tails[6], "VERTICAL", c3, c23)
				end
			elseif progress < (1 - cornerP) then
				local stageProg = (progress - cornerP)  / (1 - cornerP * 2)
				if inf.tail.startPoint == "TOP" or inf.tail.startPoint == "BOTTOM" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c2x = GetHSVTransition(stageProg, c1, c4)
					local c5x = GetHSVTransition(stageProg, c3, c2)

					SetGradA(tails[2], "VERTICAL", c4, c2x)
					SetGradA(tails[3], "HORIZONTAL", c34, c4)
					SetGradA(tails[5], "VERTICAL", c5x, c2)
					SetGradA(tails[6], "HORIZONTAL", c2, c12)

				else
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c2x = GetHSVTransition(stageProg, c2, c1)
					local c5x = GetHSVTransition(stageProg, c4, c3)

					SetGradA(tails[2], "HORIZONTAL", c2x, c1)
					SetGradA(tails[3], "VERTICAL", c41, c1)
					SetGradA(tails[5], "HORIZONTAL", c3, c5x)
					SetGradA(tails[6], "VERTICAL", c3, c23)
				end
			else
				local stageProg = (progress - 1 + cornerP) / cornerP
				if inf.tail.startPoint == "TOP" or inf.tail.startPoint == "BOTTOM" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c3x = GetHSVTransition(stageProg, c4, c34)
					local c6x = GetHSVTransition(stageProg, c2, c12)

					SetGradA(tails[3], "HORIZONTAL", c34, c3x)
					SetGradA(tails[6], "HORIZONTAL", c6x, c12)

				else
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c3x = GetHSVTransition(stageProg, c1, c41)
					local c6x = GetHSVTransition(stageProg, c3, c23)

					SetGradA(tails[3], "VERTICAL", c41, c3x)
					SetGradA(tails[6], "VERTICAL", c6x, c23)
				end
			end
		else
			if progress < cornerP then
				local stageProg = progress / cornerP
				if inf.tail.startPoint == "TOP" or inf.tail.startPoint == "BOTTOM" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c1x = GetHSVTransition(stageProg, c12, c1)
					local c4x = GetHSVTransition(stageProg, c34, c4)

					SetGradA(tails[1], "HORIZONTAL", c2, c1x)
					SetGradA(tails[2], "VERTICAL", c3, c2)
					SetGradA(tails[3], "HORIZONTAL", c3, c34)
					SetGradA(tails[4], "HORIZONTAL", c4x, c4)
					SetGradA(tails[5], "VERTICAL", c4, c1)
					SetGradA(tails[6], "HORIZONTAL", c12, c1)

				else
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c1x = GetHSVTransition(stageProg, c23, c3)
					local c4x = GetHSVTransition(stageProg, c41, c1)

					SetGradA(tails[1], "VERTICAL", c3, c1x)
					SetGradA(tails[2], "HORIZONTAL", c3, c4)
					SetGradA(tails[3], "VERTICAL", c4, c41)
					SetGradA(tails[4], "VERTICAL", c4x, c1)
					SetGradA(tails[5], "HORIZONTAL", c2, c1)
					SetGradA(tails[6], "VERTICAL", c23, c2)
				end
			elseif progress < (1 - cornerP) then
				local stageProg = (progress - cornerP)  / (1 - cornerP * 2)
				if inf.tail.startPoint == "TOP" or inf.tail.startPoint == "BOTTOM" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c2x = GetHSVTransition(stageProg, c2, c3)
					local c5x = GetHSVTransition(stageProg, c4, c1)

					SetGradA(tails[2], "VERTICAL", c3, c2x)
					SetGradA(tails[3], "HORIZONTAL", c3, c34)
					SetGradA(tails[5], "VERTICAL", c5x, c1)
					SetGradA(tails[6], "HORIZONTAL", c12, c1)

				else
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c2x = GetHSVTransition(stageProg, c3, c4)
					local c5x = GetHSVTransition(stageProg, c1, c2)

					SetGradA(tails[2], "HORIZONTAL", c2x, c4)
					SetGradA(tails[3], "VERTICAL", c4, c41)
					SetGradA(tails[5], "HORIZONTAL", c2, c5x)
					SetGradA(tails[6], "VERTICAL", c23, c2)
				end
			else
				local stageProg = (progress - 1 + cornerP) / cornerP
				if inf.tail.startPoint == "TOP" or inf.tail.startPoint == "BOTTOM" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c3x = GetHSVTransition(stageProg, c3, c34)
					local c6x = GetHSVTransition(stageProg, c1, c12)

					SetGradA(tails[3], "HORIZONTAL", c3x, c34)
					SetGradA(tails[6], "HORIZONTAL", c12, c6x)

				else
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c3x = GetHSVTransition(stageProg, c4, c41)
					local c6x = GetHSVTransition(stageProg, c2, c23)

					SetGradA(tails[3], "VERTICAL", c3x, c41)
					SetGradA(tails[6], "VERTICAL", c23, c6x)
				end
			end
		end
	end
end

local function BorderSet2LinesCorner(f, update)
	local inf = f.inf
	local tails = inf.tail.list
	if not(update) then
		for _, v in pairs(tails) do
			v:ClearAllPoints()
		end
		if inf.tail.mirror then
			if inf.tail.startPoint == "TOPLEFT" or inf.tail.startPoint == "BOTTOMRIGHT" then
				tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT")
				tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
				tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
				tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
			else
				tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT")
				tails[2]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
				tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
				tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
			end
			tails[1]:SetHeight(inf.th)
			tails[2]:SetWidth(inf.th)
			tails[3]:SetWidth(inf.th)
			tails[4]:SetHeight(inf.th)
		else
			if inf.tail.startPoint == "TOPLEFT" or inf.tail.startPoint == "BOTTOMRIGHT" then
				if inf.tail.clockwise then
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
					tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
					tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[4]:SetPoint("TOPLEFT", f, "TOPLEFT")
				else
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
					tails[3]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[4]:SetPoint("TOPLEFT", f, "TOPLEFT")
				end
			else
				if inf.tail.clockwise then
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
					tails[3]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT")
				else
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
					tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
					tails[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT")
				end
			end
			inf.tail.Set2(tails[1], inf.th)
			inf.tail.Set1(tails[2], inf.th)
			inf.tail.Set2(tails[3], inf.th)
			inf.tail.Set1(tails[4], inf.th)
		end
	end

	if inf.tail.mirror then
		tails[1]:SetWidth(f:GetWidth())
		tails[2]:SetHeight(f:GetHeight() - inf.th)
		tails[3]:SetHeight(f:GetHeight())
		tails[4]:SetWidth(f:GetWidth() - inf.th)
	else
		if inf.tail.clockwise and (inf.tail.startPoint == "TOPLEFT" or inf.tail.startPoint == "BOTTOMRIGHT") or
			 not(inf.tail.clockwise) and (inf.tail.startPoint == "BOTTOMLEFT" or inf.tail.startPoint == "TOPRIGHT") then
			inf.tail.size1 = f:GetWidth()
		  inf.tail.size2 = f:GetHeight()
		else
			inf.tail.size1 = f:GetHeight()
		  inf.tail.size2 = f:GetWidth()
		end
		inf.tail.Set1(tails[1], inf.tail.size1 - 2*inf.th)
		inf.tail.Set2(tails[2], inf.tail.size2)
		inf.tail.Set1(tails[3], inf.tail.size1 - 2*inf.th)
		inf.tail.Set2(tails[4], inf.tail.size2)
	end
end

local function BorderUpdate2LinesCorner(f, progress)
	local inf = f.inf
	local tails = inf.tail.list
	local oldProgress = inf.tail.old
	if inf.tail.mirror then
		tails[1]:SetWidth((1 - progress) * inf.width)
		tails[2]:SetHeight((1 - progress) * (inf.height - inf.th))
		tails[3]:SetHeight((1 - progress) * inf.height)
		tails[4]:SetWidth((1 - progress) * (inf.width - inf.th))
	else
		local cornerP = inf.tail.size1/(inf.tail.size1 + inf.tail.size2)
		if progress < cornerP then
			if oldProgress > cornerP or oldProgress <= 0 then
				for _, v in pairs(tails) do
					v:Show()
				end
				BorderSet2LinesCorner(f, true)
			end
			local stageProg = 1 - progress / cornerP
			inf.tail.Set1(tails[1], stageProg * (inf.tail.size1 - 2*inf.th))
			inf.tail.Set1(tails[3], stageProg * (inf.tail.size1 - 2*inf.th))
		else
			if oldProgress >= 0.99 or oldProgress < cornerP then
				tails[1]:Hide()
				tails[2]:Show()
				tails[3]:Hide()
				tails[4]:Show()
				BorderSet2LinesCorner(f, true)
			end
				local stageProg = (1 - progress) / (1 - cornerP)
				inf.tail.Set2(tails[2], stageProg * inf.tail.size2)
				inf.tail.Set2(tails[4], stageProg * inf.tail.size2)
		end
	end
	inf.tail.old = progress
end

local function BorderGradient2LinesCorner(f, progress, elapsed)
	local inf = f.inf
	local tails = inf.tail.list
	local c1, c2, c3, c4 = BorderGradientCorners(inf, elapsed)

	if inf.tail.mirror then
		if inf.tail.startPoint == "TOPLEFT" or inf.tail.startPoint == "BOTTOMRIGHT" then
			local c1x = GetHSVTransition(progress, c2, c1)
			local c2x = GetHSVTransition(progress, c4, c1)
			local c3x = GetHSVTransition(progress, c2, c3)
			local c4x = GetHSVTransition(progress, c4, c3)

			SetGradA(tails[1], "HORIZONTAL", c1x, c1)
			SetGradA(tails[2], "VERTICAL", c2x, c1)
			SetGradA(tails[3], "VERTICAL", c3, c3x)
			SetGradA(tails[4], "HORIZONTAL", c3, c4)
		else
			local c1x = GetHSVTransition(progress, c1, c2)
			local c2x = GetHSVTransition(progress, c3, c2)
			local c3x = GetHSVTransition(progress, c1, c4)
			local c4x = GetHSVTransition(progress, c3, c4)

			SetGradA(tails[1], "HORIZONTAL", c2, c1x)
			SetGradA(tails[2], "VERTICAL", c2x, c2)
			SetGradA(tails[3], "VERTICAL", c4, c3x)
			SetGradA(tails[4], "HORIZONTAL", c4x, c4)
		end
	else
		local cornerP = inf.tail.size1/(inf.tail.size1 + inf.tail.size2)
		if inf.tail.clockwise then
			if progress < cornerP then
				local stageProg = progress / cornerP
				if inf.tail.startPoint == "TOPLEFT" or inf.tail.startPoint == "BOTTOMRIGHT" then
					local c1x = GetHSVTransition(stageProg, c2, c1)
					local c3x = GetHSVTransition(stageProg, c4, c3)

					SetGradA(tails[1], "HORIZONTAL", c1x, c1)
					SetGradA(tails[2], "VERTICAL", c4, c1)
					SetGradA(tails[3], "HORIZONTAL", c3, c3x)
					SetGradA(tails[4], "VERTICAL", c3, c2)

				else
					local c1x = GetHSVTransition(stageProg, c1, c4)
					local c3x = GetHSVTransition(stageProg, c3, c2)

					SetGradA(tails[1], "VERTICAL", c4, c1x)
					SetGradA(tails[2], "HORIZONTAL", c3, c4)
					SetGradA(tails[3], "VERTICAL", c3x, c2)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
				end
			else
				local stageProg = (progress - cornerP)  / (1 - cornerP)
				if inf.tail.startPoint == "TOPLEFT" or inf.tail.startPoint == "BOTTOMRIGHT" then
					local c2x = GetHSVTransition(stageProg, c1, c4)
					local c4x = GetHSVTransition(stageProg, c3, c2)


					SetGradA(tails[2], "VERTICAL", c4, c2x)
					SetGradA(tails[4], "VERTICAL", c4x, c2)

				else
					local c2x = GetHSVTransition(stageProg, c4, c3)
					local c4x = GetHSVTransition(stageProg, c2, c1)

					SetGradA(tails[2], "HORIZONTAL", c3, c2x)
					SetGradA(tails[4], "HORIZONTAL", c4x, c1)
				end
			end
		else
			if progress < cornerP then
				local stageProg = progress / cornerP
				if inf.tail.startPoint == "TOPLEFT" or inf.tail.startPoint == "BOTTOMRIGHT" then
					local c1x = GetHSVTransition(stageProg, c2, c3)
					local c3x = GetHSVTransition(stageProg, c4, c1)

					SetGradA(tails[1], "VERTICAL", c3, c1x)
					SetGradA(tails[2], "HORIZONTAL", c3, c4)
					SetGradA(tails[3], "VERTICAL", c3x, c1)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)

				else
					local c1x = GetHSVTransition(stageProg, c1, c2)
					local c3x = GetHSVTransition(stageProg, c3, c4)

					SetGradA(tails[1], "HORIZONTAL", c2, c1x)
					SetGradA(tails[2], "VERTICAL", c3, c2)
					SetGradA(tails[3], "HORIZONTAL", c3x, c4)
					SetGradA(tails[4], "VERTICAL", c4, c1)
				end
			else
				local stageProg = (progress - cornerP)  / (1 - cornerP)
				if inf.tail.startPoint == "TOPLEFT" or inf.tail.startPoint == "BOTTOMRIGHT" then
					local c2x = GetHSVTransition(stageProg, c3, c4)
					local c4x = GetHSVTransition(stageProg, c1, c2)


					SetGradA(tails[2], "HORIZONTAL", c2x, c4)
					SetGradA(tails[4], "HORIZONTAL", c2, c4x)

				else
					local c2x = GetHSVTransition(stageProg, c2, c3)
					local c4x = GetHSVTransition(stageProg, c4, c1)

					SetGradA(tails[2], "VERTICAL", c3, c2x)
					SetGradA(tails[4], "VERTICAL", c4x, c1)
				end
			end
		end
	end
end

local function BorderSet1LineCenter(f, update)
	local inf = f.inf
	local tails = inf.tail.list
	if not(update) then
		for _, v in pairs(tails) do
			v:ClearAllPoints()
		end
		if inf.tail.mirror then
			if inf.tail.startPoint == "TOP" then
				inf.tail.Set1 = f.SetWidth
				inf.tail.Set2 = f.SetHeight
				tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
				tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
				tails[3]:SetPoint("BOTTOM", f, "BOTTOM")
				tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
				tails[5]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
			elseif inf.tail.startPoint == "BOTTOM" then
				inf.tail.Set1 = f.SetWidth
				inf.tail.Set2 = f.SetHeight
				tails[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
				tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
				tails[3]:SetPoint("TOP", f, "TOP")
				tails[4]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
				tails[5]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
			elseif inf.tail.startPoint == "LEFT" then
				inf.tail.Set1 = f.SetHeight
				inf.tail.Set2 = f.SetWidth
				tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
				tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
				tails[3]:SetPoint("RIGHT", f, "RIGHT")
				tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
				tails[5]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
			else
				inf.tail.Set1 = f.SetHeight
				inf.tail.Set2 = f.SetWidth
				tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
				tails[2]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
				tails[3]:SetPoint("LEFT", f, "LEFT")
				tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
				tails[5]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
			end
		else
			if inf.tail.clockwise then
				if inf.tail.startPoint == "TOP" then
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
					tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[4]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[5]:SetPoint("TOPRIGHT", f, "TOP")
				elseif inf.tail.startPoint == "BOTTOM" then
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[2]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[3]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
					tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[5]:SetPoint("BOTTOMLEFT", f, "BOTTOM")
				elseif inf.tail.startPoint == "LEFT" then
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
					tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[5]:SetPoint("TOPLEFT", f, "LEFT")
				else
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[3]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
					tails[5]:SetPoint("BOTTOMRIGHT", f, "RIGHT")
				end
			else
				if inf.tail.startPoint == "TOP" then
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
					tails[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[5]:SetPoint("TOPLEFT", f, "TOP")
				elseif inf.tail.startPoint == "BOTTOM" then
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
					tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[3]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[5]:SetPoint("BOTTOMRIGHT", f, "BOTTOM")
				elseif inf.tail.startPoint == "LEFT" then
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
					tails[3]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[4]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[5]:SetPoint("BOTTOMLEFT", f, "LEFT")
				else
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[2]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
					tails[5]:SetPoint("TOPRIGHT", f, "RIGHT")
				end
			end
		end
		inf.tail.Set2(tails[1], inf.th)
		inf.tail.Set1(tails[2], inf.th)
		inf.tail.Set2(tails[3], inf.th)
		inf.tail.Set1(tails[4], inf.th)
		inf.tail.Set2(tails[5], inf.th)
	end
	if inf.tail.startPoint == "TOP" or inf.tail.startPoint == "BOTTOM" then
		inf.tail.size1 = f:GetWidth()
		inf.tail.size2 = f:GetHeight()
	else
		inf.tail.size1 = f:GetHeight()
		inf.tail.size2 = f:GetWidth()
	end

	if inf.tail.mirror then
		inf.tail.Set1(tails[1], inf.tail.size1/2 - inf.th)
		inf.tail.Set2(tails[2], inf.tail.size2 - inf.th)
		inf.tail.Set1(tails[3], inf.tail.size1)
		inf.tail.Set2(tails[4], inf.tail.size2 - inf.th)
		inf.tail.Set1(tails[5], inf.tail.size1/2 - inf.th)
	else
		inf.tail.Set1(tails[1], inf.tail.size1/2 - inf.th)
		inf.tail.Set2(tails[2], inf.tail.size2 - inf.th)
		inf.tail.Set1(tails[3], inf.tail.size1 - inf.th)
		inf.tail.Set2(tails[4], inf.tail.size2 - inf.th)
		inf.tail.Set1(tails[5], inf.tail.size1/2)
	end
end

local function BorderUpdate1LineCenter(f, progress)
	local inf = f.inf
	local tails = inf.tail.list
	local oldProgress = inf.tail.old

	if inf.tail.mirror then
		local cornerP = inf.tail.size1 / (inf.tail.size1 + inf.tail.size2) / 2
		if progress < cornerP then
			if oldProgress > cornerP or oldProgress <= 0 then
				for _, v in pairs(tails) do
					v:Show()
				end
				BorderSet1LineCenter (f, true)
			end
			local stageProg = 1 - progress / cornerP
			inf.tail.Set1(tails[1], stageProg * (inf.tail.size1 / 2 - inf.th))
			inf.tail.Set1(tails[5], stageProg * (inf.tail.size1 / 2 - inf.th))
		elseif progress < 1 - cornerP then
			if oldProgress > 1 - cornerP or oldProgress <= cornerP then
				tails[1]:Hide()
				tails[2]:Show()
				tails[3]:Show()
				tails[4]:Show()
				tails[5]:Hide()
				BorderSet1LineCenter (f, true)
			end
			local stageProg = (1 - progress - cornerP) / (1 - cornerP * 2)
			inf.tail.Set2(tails[2], stageProg * (inf.tail.size2 - inf.th))
			inf.tail.Set2(tails[4], stageProg * (inf.tail.size2 - inf.th))
		else
			if oldProgress >= 0.99 or oldProgress <= 1 - cornerP then
				tails[1]:Hide()
				tails[2]:Hide()
				tails[3]:Show()
				tails[4]:Hide()
				tails[5]:Hide()
				BorderSet1LineCenter (f, true)
			end
			local stageProg = (1 - progress) / cornerP
			inf.tail.Set1(tails[3], stageProg * inf.tail.size1)
		end
	else
		local cornerP = inf.tail.size1 / (inf.tail.size1 + inf.tail.size2) / 4
		if progress < cornerP then
			if oldProgress > cornerP or oldProgress <= 0 then
				for _, v in pairs(tails) do
					v:Show()
				end
				BorderSet1LineCenter (f, true)
			end
			local stageProg = 1 - progress / cornerP
			inf.tail.Set1(tails[1], stageProg * (inf.tail.size1 / 2 - inf.th))
		elseif progress < 0.5 - cornerP then
			if oldProgress > 0.5 - cornerP or oldProgress <= cornerP then
				tails[1]:Hide()
				tails[2]:Show()
				tails[3]:Show()
				tails[4]:Show()
				tails[5]:Show()
				BorderSet1LineCenter (f, true)
			end
			local stageProg = (0.5 - cornerP - progress) / (0.5 - cornerP * 2)
			inf.tail.Set2(tails[2], stageProg * (inf.tail.size2 - inf.th))
		elseif progress < 0.5 + cornerP then
			if oldProgress > 0.5 + cornerP or oldProgress <= 0.5 - cornerP then
				tails[1]:Hide()
				tails[2]:Hide()
				tails[3]:Show()
				tails[4]:Show()
				tails[5]:Show()
				BorderSet1LineCenter (f, true)
			end
			local stageProg = (0.5 + cornerP - progress) / cornerP / 2
			inf.tail.Set1(tails[3], stageProg * (inf.tail.size1 - inf.th))
		elseif progress < 1 - cornerP then
			if oldProgress > 1 - cornerP or oldProgress <= 0.5 + cornerP then
				tails[1]:Hide()
				tails[2]:Hide()
				tails[3]:Hide()
				tails[4]:Show()
				tails[5]:Show()
				BorderSet1LineCenter (f, true)
			end
			local stageProg = (1 - cornerP - progress) / (0.5 - cornerP * 2)
			inf.tail.Set2(tails[4], stageProg * (inf.tail.size2 - inf.th))
		else
			if oldProgress >= 0.99 or oldProgress <= (1 - cornerP) then
				tails[1]:Hide()
				tails[2]:Hide()
				tails[3]:Hide()
				tails[4]:Hide()
				tails[5]:Show()
				BorderSet1LineCenter (f, true)
			end
			local stageProg = (1 - progress) / cornerP
			inf.tail.Set1(tails[5], stageProg * (inf.tail.size1 / 2))
		end
	end
	inf.tail.old = progress
end

local function BorderGradient1LineCenter(f, progress, elapsed)
	local inf = f.inf
	local tails = inf.tail.list
	local c1, c2, c3, c4 = BorderGradientCorners(inf, elapsed)

	local cornerP = inf.tail.size1 / (inf.tail.size1 + inf.tail.size2) / 4
	if inf.tail.mirror then
		local cornerP = inf.tail.size1 / (inf.tail.size1 + inf.tail.size2) / 2
		if progress < cornerP then
			local stageProg = progress / cornerP
			if inf.tail.startPoint == "TOP" then
				local c12 = GetHSVTransition(0.5, c1, c2)
				local c1x = GetHSVTransition(stageProg, c12, c1)
				local c5x = GetHSVTransition(stageProg, c12, c2)

				SetGradA(tails[1], "HORIZONTAL", c1x, c1)
				SetGradA(tails[2], "VERTICAL", c4, c1)
				SetGradA(tails[3], "HORIZONTAL", c3, c4)
				SetGradA(tails[4], "VERTICAL", c3, c2)
				SetGradA(tails[5], "HORIZONTAL", c2, c5x)

			elseif inf.tail.startPoint == "BOTTOM" then
				local c34 = GetHSVTransition(0.5, c3, c4)
				local c1x = GetHSVTransition(stageProg, c34, c4)
				local c5x = GetHSVTransition(stageProg, c34, c3)

				SetGradA(tails[1], "HORIZONTAL", c1x, c4)
				SetGradA(tails[2], "VERTICAL", c4, c1)
				SetGradA(tails[3], "HORIZONTAL", c2, c1)
				SetGradA(tails[4], "VERTICAL", c3, c2)
				SetGradA(tails[5], "HORIZONTAL", c3, c5x)

			elseif inf.tail.startPoint == "LEFT" then
				local c23 = GetHSVTransition(0.5, c2, c3)
				local c1x = GetHSVTransition(stageProg, c23, c2)
				local c5x = GetHSVTransition(stageProg, c23, c3)

				SetGradA(tails[1], "VERTICAL", c1x, c2)
				SetGradA(tails[2], "HORIZONTAL", c2, c1)
				SetGradA(tails[3], "VERTICAL", c4, c1)
				SetGradA(tails[4], "HORIZONTAL", c3, c4)
				SetGradA(tails[5], "VERTICAL", c3, c5x)

			else
				local c41 = GetHSVTransition(0.5, c4, c1)
				local c1x = GetHSVTransition(stageProg, c41, c1)
				local c5x = GetHSVTransition(stageProg, c41, c4)

				SetGradA(tails[1], "VERTICAL", c1x, c1)
				SetGradA(tails[2], "HORIZONTAL", c2, c1)
				SetGradA(tails[3], "VERTICAL", c3, c2)
				SetGradA(tails[4], "HORIZONTAL", c3, c4)
				SetGradA(tails[5], "VERTICAL", c4, c5x)
			end
		elseif progress < (1 - cornerP) then
			local stageProg = (progress - cornerP)  / (1 - cornerP * 2)
			if inf.tail.startPoint == "TOP" then
				local c2x = GetHSVTransition(stageProg, c1, c4)
				local c4x = GetHSVTransition(stageProg, c2, c3)

				SetGradA(tails[2], "VERTICAL", c4, c2x)
				SetGradA(tails[3], "HORIZONTAL", c3, c4)
				SetGradA(tails[4], "VERTICAL", c3, c4x)
			elseif inf.tail.startPoint == "BOTTOM" then
				local c2x = GetHSVTransition(stageProg, c4, c1)
				local c4x = GetHSVTransition(stageProg, c3, c2)

				SetGradA(tails[2], "VERTICAL", c2x, c1)
				SetGradA(tails[3], "HORIZONTAL", c2, c1)
				SetGradA(tails[4], "VERTICAL", c4x, c2)
			elseif inf.tail.startPoint == "LEFT" then
				local c2x = GetHSVTransition(stageProg, c2, c1)
				local c4x = GetHSVTransition(stageProg, c3, c4)

				SetGradA(tails[2], "HORIZONTAL", c2x, c1)
				SetGradA(tails[3], "VERTICAL", c4, c1)
				SetGradA(tails[4], "HORIZONTAL", c4x, c4)
			else
				local c2x = GetHSVTransition(stageProg, c1, c2)
				local c4x = GetHSVTransition(stageProg, c4, c3)

				SetGradA(tails[2], "HORIZONTAL", c2, c2x)
				SetGradA(tails[3], "VERTICAL", c3, c2)
				SetGradA(tails[4], "HORIZONTAL", c3, c4x)
			end
		else
			local stageProg = (progress - 1 + 0.5) / cornerP
			if inf.tail.startPoint == "TOP" then
				local c34 = GetHSVTransition(0.5, c3, c4)
				local c3x1 = GetHSVTransition(stageProg, c3, c34)
				local c3x2 = GetHSVTransition(stageProg, c4, c34)

				SetGradA(tails[3], "HORIZONTAL", c3x1, c3x2)
			elseif inf.tail.startPoint == "BOTTOM" then
				local c12 = GetHSVTransition(0.5, c1, c2)
				local c3x1 = GetHSVTransition(stageProg, c2, c12)
				local c3x2 = GetHSVTransition(stageProg, c1, c12)

				SetGradA(tails[3], "HORIZONTAL", c3x1, c3x2)
			elseif inf.tail.startPoint == "LEFT" then
				local c41 = GetHSVTransition(0.5, c4, c1)
				local c3x1 = GetHSVTransition(stageProg, c4, c41)
				local c3x2 = GetHSVTransition(stageProg, c1, c41)

				SetGradA(tails[3], "VERTICAL", c3x1, c3x2)
			else
				local c23 = GetHSVTransition(0.5, c2, c3)
				local c3x1 = GetHSVTransition(stageProg, c3, c23)
				local c3x2 = GetHSVTransition(stageProg, c2, c23)

				SetGradA(tails[3], "VERTICAL", c3x1, c3x2)
			end
		end
	else
		if inf.tail.clockwise then
			if progress < cornerP then
				local stageProg = progress / cornerP
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c1x = GetHSVTransition(stageProg, c12, c1)
					SetGradA(tails[1], "HORIZONTAL", c1x, c1)
					SetGradA(tails[2], "VERTICAL", c4, c1)
					SetGradA(tails[3], "HORIZONTAL", c3, c4)
					SetGradA(tails[4], "VERTICAL", c3, c2)
					SetGradA(tails[5], "HORIZONTAL", c2, c12)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c1x = GetHSVTransition(stageProg, c34, c3)
					SetGradA(tails[1], "HORIZONTAL", c3, c1x)
					SetGradA(tails[2], "VERTICAL", c3, c2)
					SetGradA(tails[3], "HORIZONTAL", c2, c1)
					SetGradA(tails[4], "VERTICAL", c4, c1)
					SetGradA(tails[5], "HORIZONTAL", c34, c4)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c1x = GetHSVTransition(stageProg, c23, c2)
					SetGradA(tails[1], "VERTICAL", c1x, c2)
					SetGradA(tails[2], "HORIZONTAL", c2, c1)
					SetGradA(tails[3], "VERTICAL", c4, c1)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
					SetGradA(tails[5], "VERTICAL", c3, c23)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c1x = GetHSVTransition(stageProg, c41, c4)
					SetGradA(tails[1], "VERTICAL", c4, c1x)
					SetGradA(tails[2], "HORIZONTAL", c3, c4)
					SetGradA(tails[3], "VERTICAL", c3, c2)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
					SetGradA(tails[5], "VERTICAL", c41, c1)
				end
			elseif progress < 0.5 - cornerP then
				local stageProg = (progress - cornerP) / (0.5 - cornerP * 2)
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c2x = GetHSVTransition(stageProg, c1, c4)
					SetGradA(tails[2], "VERTICAL", c4, c2x)
					SetGradA(tails[3], "HORIZONTAL", c3, c4)
					SetGradA(tails[4], "VERTICAL", c3, c2)
					SetGradA(tails[5], "HORIZONTAL", c2, c12)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c2x = GetHSVTransition(stageProg, c3, c2)
					SetGradA(tails[2], "VERTICAL", c2x, c2)
					SetGradA(tails[3], "HORIZONTAL", c2, c1)
					SetGradA(tails[4], "VERTICAL", c4, c1)
					SetGradA(tails[5], "HORIZONTAL", c34, c4)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c2x = GetHSVTransition(stageProg, c2, c1)
					SetGradA(tails[2], "HORIZONTAL", c2x, c1)
					SetGradA(tails[3], "VERTICAL", c4, c1)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
					SetGradA(tails[5], "VERTICAL", c3, c23)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c2x = GetHSVTransition(stageProg, c4, c3)
					SetGradA(tails[2], "HORIZONTAL", c3, c2x)
					SetGradA(tails[3], "VERTICAL", c3, c2)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
					SetGradA(tails[5], "VERTICAL", c41, c1)
				end
			elseif progress < 0.5 + cornerP then
				local stageProg = (progress - 0.5 + cornerP) / cornerP / 2
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c3x = GetHSVTransition(stageProg, c4, c3)
					SetGradA(tails[3], "HORIZONTAL", c3, c3x)
					SetGradA(tails[4], "VERTICAL", c3, c2)
					SetGradA(tails[5], "HORIZONTAL", c2, c12)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c3x = GetHSVTransition(stageProg, c2, c1)
					SetGradA(tails[3], "HORIZONTAL", c3x, c1)
					SetGradA(tails[4], "VERTICAL", c4, c1)
					SetGradA(tails[5], "HORIZONTAL", c34, c4)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c3x = GetHSVTransition(stageProg, c1, c4)
					SetGradA(tails[3], "VERTICAL", c4, c3x)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
					SetGradA(tails[5], "VERTICAL", c3, c23)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c3x = GetHSVTransition(stageProg, c3, c2)
					SetGradA(tails[3], "VERTICAL", c3x, c2)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
					SetGradA(tails[5], "VERTICAL", c41, c1)
				end
			elseif progress < 1 - cornerP then
				local stageProg = (progress - 0.5 - cornerP) / (0.5 - cornerP * 2)
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c4x = GetHSVTransition(stageProg, c3, c2)
					SetGradA(tails[4], "VERTICAL", c4x, c2)
					SetGradA(tails[5], "HORIZONTAL", c2, c12)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c4x = GetHSVTransition(stageProg, c1, c4)
					SetGradA(tails[4], "VERTICAL", c4, c4x)
					SetGradA(tails[5], "HORIZONTAL", c34, c4)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c4x = GetHSVTransition(stageProg, c4, c3)
					SetGradA(tails[4], "HORIZONTAL", c3, c4x)
					SetGradA(tails[5], "VERTICAL", c3, c23)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c4x = GetHSVTransition(stageProg, c2, c1)
					SetGradA(tails[4], "HORIZONTAL", c4x, c1)
					SetGradA(tails[5], "VERTICAL", c41, c1)
				end
			else
				local stageProg = (progress - 1 + cornerP) / cornerP
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c5x = GetHSVTransition(stageProg, c2, c12)
					SetGradA(tails[5], "HORIZONTAL", c5x, c12)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c5x = GetHSVTransition(stageProg, c4, c34)
					SetGradA(tails[5], "HORIZONTAL", c34, c5x)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c5x = GetHSVTransition(stageProg, c3, c23)
					SetGradA(tails[5], "VERTICAL", c5x, c23)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c5x = GetHSVTransition(stageProg, c1, c41)
					SetGradA(tails[5], "VERTICAL", c41, c5x)
				end
			end
		else
			if progress < cornerP then
				local stageProg = progress / cornerP
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c1x = GetHSVTransition(stageProg, c2, c12)
					SetGradA(tails[1], "HORIZONTAL", c2, c1x)
					SetGradA(tails[2], "VERTICAL", c3, c2)
					SetGradA(tails[3], "HORIZONTAL", c3, c4)
					SetGradA(tails[4], "VERTICAL", c4, c1)
					SetGradA(tails[5], "HORIZONTAL", c12, c1)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c1x = GetHSVTransition(stageProg, c34, c4)
					SetGradA(tails[1], "HORIZONTAL", c1x, c4)
					SetGradA(tails[2], "VERTICAL", c4, c1)
					SetGradA(tails[3], "HORIZONTAL", c2, c1)
					SetGradA(tails[4], "VERTICAL", c3, c2)
					SetGradA(tails[5], "HORIZONTAL", c3, c34)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c1x = GetHSVTransition(stageProg, c3, c23)
					SetGradA(tails[1], "VERTICAL", c3, c1x)
					SetGradA(tails[2], "HORIZONTAL", c3, c4)
					SetGradA(tails[3], "VERTICAL", c4, c1)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
					SetGradA(tails[5], "VERTICAL", c23, c2)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c1x = GetHSVTransition(stageProg, c41, c1)
					SetGradA(tails[1], "VERTICAL", c1x, c1)
					SetGradA(tails[2], "HORIZONTAL", c2, c1)
					SetGradA(tails[3], "VERTICAL", c3, c2)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
					SetGradA(tails[5], "VERTICAL", c4, c41)
				end
			elseif progress < 0.5 - cornerP then
				local stageProg = (progress - cornerP) / (0.5 - cornerP * 2)
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c2x = GetHSVTransition(stageProg, c2, c3)
					SetGradA(tails[2], "VERTICAL", c3, c2x)
					SetGradA(tails[3], "HORIZONTAL", c3, c4)
					SetGradA(tails[4], "VERTICAL", c4, c1)
					SetGradA(tails[5], "HORIZONTAL", c12, c1)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c2x = GetHSVTransition(stageProg, c4, c1)
					SetGradA(tails[2], "VERTICAL", c2x, c1)
					SetGradA(tails[3], "HORIZONTAL", c2, c1)
					SetGradA(tails[4], "VERTICAL", c3, c2)
					SetGradA(tails[5], "HORIZONTAL", c3, c34)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c2x = GetHSVTransition(stageProg, c3, c4)
					SetGradA(tails[2], "HORIZONTAL", c2x, c4)
					SetGradA(tails[3], "VERTICAL", c4, c1)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
					SetGradA(tails[5], "VERTICAL", c23, c2)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c2x = GetHSVTransition(stageProg, c1, c2)
					SetGradA(tails[2], "HORIZONTAL", c2, c2x)
					SetGradA(tails[3], "VERTICAL", c3, c2)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
					SetGradA(tails[5], "VERTICAL", c4, c41)
				end
			elseif progress < 0.5 + cornerP then
				local stageProg = (progress - 0.5 + cornerP) / cornerP / 2
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c3x = GetHSVTransition(stageProg, c3, c4)
					SetGradA(tails[3], "HORIZONTAL", c3x, c4)
					SetGradA(tails[4], "VERTICAL", c4, c1)
					SetGradA(tails[5], "HORIZONTAL", c12, c1)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c3x = GetHSVTransition(stageProg, c1, c2)
					SetGradA(tails[3], "HORIZONTAL", c2, c3x)
					SetGradA(tails[4], "VERTICAL", c3, c2)
					SetGradA(tails[5], "HORIZONTAL", c3, c34)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c3x = GetHSVTransition(stageProg, c4, c1)
					SetGradA(tails[3], "VERTICAL", c3x, c1)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
					SetGradA(tails[5], "VERTICAL", c23, c2)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c3x = GetHSVTransition(stageProg, c2, c3)
					SetGradA(tails[3], "VERTICAL", c3, c3x)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
					SetGradA(tails[5], "VERTICAL", c4, c41)
				end
			elseif progress < 1 - cornerP then
				local stageProg = (progress - 0.5 - cornerP) / (0.5 - cornerP * 2)
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c4x = GetHSVTransition(stageProg, c4, c1)
					SetGradA(tails[4], "VERTICAL", c4x, c1)
					SetGradA(tails[5], "HORIZONTAL", c12, c1)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c4x = GetHSVTransition(stageProg, c2, c3)
					SetGradA(tails[4], "VERTICAL", c3, c4x)
					SetGradA(tails[5], "HORIZONTAL", c3, c34)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c4x = GetHSVTransition(stageProg, c1, c2)
					SetGradA(tails[4], "HORIZONTAL", c2, c4x)
					SetGradA(tails[5], "VERTICAL", c23, c2)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c4x = GetHSVTransition(stageProg, c3, c4)
					SetGradA(tails[4], "HORIZONTAL", c4x, c4)
					SetGradA(tails[5], "VERTICAL", c4, c41)
				end
			else
				local stageProg = (progress - 1 + cornerP) / cornerP
				if inf.tail.startPoint == "TOP" then
					local c12 = GetHSVTransition(0.5, c1, c2)
					local c5x = GetHSVTransition(stageProg, c1, c12)
					SetGradA(tails[5], "HORIZONTAL", c12, c5x)

				elseif inf.tail.startPoint == "BOTTOM" then
					local c34 = GetHSVTransition(0.5, c3, c4)
					local c5x = GetHSVTransition(stageProg, c3, c34)
					SetGradA(tails[5], "HORIZONTAL", c5x, c34)

				elseif inf.tail.startPoint == "LEFT" then
					local c23 = GetHSVTransition(0.5, c2, c3)
					local c5x = GetHSVTransition(stageProg, c2, c23)
					SetGradA(tails[5], "VERTICAL", c23, c5x)

				else
					local c41 = GetHSVTransition(0.5, c4, c1)
					local c5x = GetHSVTransition(stageProg, c4, c41)
					SetGradA(tails[5], "VERTICAL", c5x, c41)
				end
			end
		end
	end
end

local function BorderSet1LineCorner(f, update)
	local inf = f.inf
	local tails = inf.tail.list
	if not(update) then
		for _, v in pairs(tails) do
			v:ClearAllPoints()
		end
		if inf.tail.mirror then
			if inf.tail.startPoint == "TOPLEFT" then
				tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
				tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
				tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
				tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
			elseif inf.tail.startPoint == "TOPRIGHT" then
				tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
				tails[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
				tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
				tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
			elseif inf.tail.startPoint == "BOTTOMRIGHT" then
				tails[1]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
				tails[2]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
				tails[3]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
				tails[4]:SetPoint("TOPLEFT", f, "TOPLEFT")
			else
				tails[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
				tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
				tails[3]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
				tails[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT")
			end
			tails[1]:SetHeight(inf.th)
			tails[2]:SetWidth(inf.th)
			tails[3]:SetWidth(inf.th)
			tails[4]:SetHeight(inf.th)
		else
			if inf.tail.clockwise then
				if inf.tail.startPoint == "TOPRIGHT" then
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[3]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT")
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
					tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
				elseif inf.tail.startPoint == "TOPLEFT" then
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0)
					tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, inf.th)
					tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[4]:SetPoint("TOPLEFT", f, "TOPLEFT")
				else
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", inf.th, 0)
					tails[2]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -inf.th)
					tails[3]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -inf.th, 0 )
					tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
				end
			else
				if inf.tail.startPoint == "TOPRIGHT" then
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
					tails[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT")
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					inf.tail.Set1 = f.SetWidth
					inf.tail.Set2 = f.SetHeight
					tails[1]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
					tails[2]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[3]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[4]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
				elseif inf.tail.startPoint == "TOPLEFT" then
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inf.th, 0)
					tails[3]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[4]:SetPoint("TOPLEFT", f, "TOPLEFT")
				else
					inf.tail.Set1 = f.SetHeight
					inf.tail.Set2 = f.SetWidth
					tails[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -inf.th)
					tails[2]:SetPoint("TOPLEFT", f, "TOPLEFT", inf.th, 0)
					tails[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, inf.th)
					tails[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
				end
			end

			inf.tail.Set2(tails[1], inf.th)
			inf.tail.Set1(tails[2], inf.th)
			inf.tail.Set2(tails[3], inf.th)
			inf.tail.Set1(tails[4], inf.th)
		end
	end

	if inf.tail.mirror then
		tails[1]:SetWidth(f:GetWidth() - inf.th)
		tails[2]:SetHeight(f:GetHeight() - inf.th)
		tails[3]:SetHeight(f:GetHeight() - 2 * inf.th)
		tails[4]:SetWidth(f:GetWidth())
	else
		if inf.tail.clockwise and (inf.tail.startPoint == "TOPLEFT" or inf.tail.startPoint == "BOTTOMRIGHT")
			or not(inf.tail.clockwise) and (inf.tail.startPoint == "TOPRIGHT" or inf.tail.startPoint == "BOTTOMLEFT")then
			inf.tail.size1 = f:GetWidth()
			inf.tail.size2 = f:GetHeight()
		else
			inf.tail.size1 = f:GetHeight()
			inf.tail.size2 = f:GetWidth()
		end
		inf.tail.Set1(tails[1], inf.tail.size1 - 2 * inf.th)
		inf.tail.Set2(tails[2], inf.tail.size2 - inf.th)
		inf.tail.Set1(tails[3], inf.tail.size1 - inf.th)
		inf.tail.Set2(tails[4], inf.tail.size2)
	end
end

local function BorderUpdate1LineCorner(f, progress)
	local inf = f.inf
	local tails = inf.tail.list
	local oldProgress = inf.tail.old

	if inf.tail.mirror then
		local cornerP = inf.width / (inf.width + inf.height)
		local updt
		if progress < cornerP then
			if oldProgress > cornerP or oldProgress <= 0 then
				tails[1]:Show()
				tails[2]:Show()
				updt = true
			else
				local stageProg = 1 - progress / cornerP
				tails[1]:SetWidth(stageProg * (inf.width - inf.th))
			end
		else
			if oldProgress >= 0.99 or oldProgress < cornerP then
				tails[1]:Hide()
				tails[2]:Show()
				updt = true
			else
				local stageProg = (1 - progress) / (1 - cornerP)
				tails[2]:SetHeight(stageProg * (inf.height - inf.th))
			end
		end

		if progress < (1 - cornerP) then
			if oldProgress > (1 - cornerP) or oldProgress <= 0 then
				tails[3]:Show()
				tails[4]:Show()
				updt = true
			else
				local stageProg = 1 - progress / (1 - cornerP)
				tails[3]:SetHeight(stageProg * (inf.height - 2*inf.th))
			end
		else
			if oldProgress >= 0.99 or oldProgress < (1 - cornerP) then
				tails[3]:Hide()
				tails[4]:Show()
				updt = true
			else
				local stageProg = (1 - progress) / cornerP
				tails[4]:SetWidth(stageProg * (inf.width))
			end
		end

		if updt then
				BorderSet1LineCorner(f, true)
				if progress < cornerP then
					local stageProg = 1 - progress / cornerP
					tails[1]:SetWidth(stageProg * (inf.width - inf.th))
				else
					local stageProg = (1 - progress) / (1 - cornerP)
					tails[2]:SetHeight(stageProg * (inf.height - inf.th))
				end
				if progress < (1 - cornerP) then
					local stageProg = 1 - progress / (1 - cornerP)
					tails[3]:SetHeight(stageProg * (inf.height - 2*inf.th))
				else
					local stageProg = (1 - progress) / cornerP
					tails[4]:SetWidth(stageProg * (inf.width))
				end
		end
	else
		local cornerP = inf.tail.size1 / (inf.tail.size1 + inf.tail.size2) / 2
		if progress < cornerP then
			if oldProgress > cornerP or oldProgress <= 0 then
				for _, v in pairs(tails) do
					v:Show()
				end
				BorderSet1LineCorner (f, true)
			end
			local stageProg = 1 - progress / cornerP
			inf.tail.Set1(tails[1], stageProg * (inf.tail.size1 - 2*inf.th))
		elseif progress < 0.5 then
			if oldProgress > 0.5 or oldProgress <= cornerP then
				tails[1]:Hide()
				tails[2]:Show()
				tails[3]:Show()
				tails[4]:Show()
				BorderSet1LineCorner (f, true)
			end
			local stageProg = (0.5 - progress) / (0.5 - cornerP)
			inf.tail.Set2(tails[2], stageProg * (inf.tail.size2 - inf.th))
		elseif progress < (0.5 + cornerP) then
			if oldProgress > (0.5 + cornerP) or oldProgress <= 0.5 then
				tails[1]:Hide()
				tails[2]:Hide()
				tails[3]:Show()
				tails[4]:Show()
				BorderSet1LineCorner (f, true)
			end
			local stageProg = (0.5 + cornerP - progress) / cornerP
			inf.tail.Set1(tails[3], stageProg * (inf.tail.size1 - inf.th))
		else
			if oldProgress >= 0.99 or oldProgress <= (1 - cornerP) then
				tails[1]:Hide()
				tails[2]:Hide()
				tails[3]:Hide()
				tails[4]:Show()
				BorderSet1LineCorner (f, true)
			end
			local stageProg = (1 - progress ) / (0.5 - cornerP)
			inf.tail.Set2(tails[4], stageProg * inf.tail.size2)
		end
	end
	inf.tail.old = progress
end

local function BorderGradient1LineCorner(f, progress, elapsed)
	local inf = f.inf
	local tails = inf.tail.list
	local c1, c2, c3, c4 = BorderGradientCorners(inf, elapsed)

	if inf.tail.mirror then
		local cornerP = inf.width/(inf.width + inf.height)
		if progress < cornerP then
			local stageProg = progress / cornerP
			if inf.tail.startPoint == "TOPLEFT" then
				local c1x = GetHSVTransition(stageProg, c2, c1)

				SetGradA(tails[1], "HORIZONTAL", c1x, c1)
				SetGradA(tails[2], "VERTICAL", c4, c1)

			elseif inf.tail.startPoint == "TOPRIGHT" then
				local c1x = GetHSVTransition(stageProg, c1, c2)

				SetGradA(tails[1], "HORIZONTAL", c2, c1x)
				SetGradA(tails[2], "VERTICAL", c3, c2)

			elseif inf.tail.startPoint == "BOTTOMRIGHT" then
				local c1x = GetHSVTransition(stageProg, c4, c3)

				SetGradA(tails[1], "HORIZONTAL", c3, c1x)
				SetGradA(tails[2], "VERTICAL", c3, c2)

			else
				local c1x = GetHSVTransition(stageProg, c3, c4)

				SetGradA(tails[1], "HORIZONTAL", c1x, c4)
				SetGradA(tails[2], "VERTICAL", c4, c1)
			end
		else
			local stageProg = (progress - cornerP)  / (1 - cornerP)
			if inf.tail.startPoint == "TOPLEFT" then
				local c2x = GetHSVTransition(stageProg, c1, c4)

				SetGradA(tails[2], "VERTICAL", c4, c2x)

			elseif inf.tail.startPoint == "TOPRIGHT" then
				local c2x = GetHSVTransition(stageProg, c2, c3)

				SetGradA(tails[2], "VERTICAL", c3, c2x)

			elseif inf.tail.startPoint == "BOTTOMRIGHT" then
				local c2x = GetHSVTransition(stageProg, c3, c2)

				SetGradA(tails[2], "VERTICAL", c2x, c2)

			else
				local c2x = GetHSVTransition(stageProg, c4, c1)

				SetGradA(tails[2], "VERTICAL", c2x, c1)
			end
		end
		if progress < (1 - cornerP) then
			local stageProg = progress / (1 - cornerP)
			if inf.tail.startPoint == "TOPLEFT" then
				local c3x = GetHSVTransition(stageProg, c2, c3)

				SetGradA(tails[3], "VERTICAL", c3, c3x)
				SetGradA(tails[4], "HORIZONTAL", c3, c4)

			elseif inf.tail.startPoint == "TOPRIGHT" then
				local c3x = GetHSVTransition(stageProg, c1, c4)

				SetGradA(tails[3], "VERTICAL", c4, c3x)
				SetGradA(tails[4], "HORIZONTAL", c3, c4)

			elseif inf.tail.startPoint == "BOTTOMRIGHT" then
				local c3x = GetHSVTransition(stageProg, c4, c1)

				SetGradA(tails[3], "VERTICAL", c3x, c1)
				SetGradA(tails[4], "HORIZONTAL", c2, c1)

			else
				local c3x = GetHSVTransition(stageProg, c3, c2)

				SetGradA(tails[3], "VERTICAL", c3x, c2)
				SetGradA(tails[4], "HORIZONTAL", c2, c1)
			end
		else
			local stageProg = (progress + cornerP - 1)  / cornerP
			if inf.tail.startPoint == "TOPLEFT" then
				local c4x = GetHSVTransition(stageProg, c3, c4)

				SetGradA(tails[4], "HORIZONTAL", c4x, c4)

			elseif inf.tail.startPoint == "TOPRIGHT" then
				local c4x = GetHSVTransition(stageProg, c4, c3)

				SetGradA(tails[4], "HORIZONTAL", c3, c4x)

			elseif inf.tail.startPoint == "BOTTOMRIGHT" then
				local c4x = GetHSVTransition(stageProg, c1, c2)

				SetGradA(tails[4], "HORIZONTAL", c2, c4x)

			else
				local c4x = GetHSVTransition(stageProg, c2, c1)

				SetGradA(tails[4], "HORIZONTAL", c4x, c1)
			end
		end
	else
		local cornerP = inf.tail.size1 / (inf.tail.size1 + inf.tail.size2) / 2
		if inf.tail.clockwise then
			if progress < cornerP then
				local stageProg = progress / cornerP
				if inf.tail.startPoint == "TOPRIGHT" then
					local c1x = GetHSVTransition(stageProg, c1, c4)
					SetGradA(tails[1], "VERTICAL", c4, c1x)
					SetGradA(tails[2], "HORIZONTAL", c3, c4)
					SetGradA(tails[3], "VERTICAL", c3, c2)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					local c1x = GetHSVTransition(stageProg, c3, c2)
					SetGradA(tails[1], "VERTICAL", c1x, c2)
					SetGradA(tails[2], "HORIZONTAL", c2, c1)
					SetGradA(tails[3], "VERTICAL", c4, c1)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
				elseif inf.tail.startPoint == "TOPLEFT" then
					local c1x = GetHSVTransition(stageProg, c2, c1)
					SetGradA(tails[1], "HORIZONTAL", c1x, c1)
					SetGradA(tails[2], "VERTICAL", c4, c1)
					SetGradA(tails[3], "HORIZONTAL", c3, c4)
					SetGradA(tails[4], "VERTICAL", c3, c2)
				else
					local c1x = GetHSVTransition(stageProg, c4, c3)
					SetGradA(tails[1], "HORIZONTAL", c3, c1x)
					SetGradA(tails[2], "VERTICAL", c3, c2)
					SetGradA(tails[3], "HORIZONTAL", c2, c1)
					SetGradA(tails[4], "VERTICAL", c4, c1)
				end
			elseif progress < 0.5 then
				local stageProg = (progress - cornerP) / (0.5 - cornerP)
				if inf.tail.startPoint == "TOPRIGHT" then
					local c2x = GetHSVTransition(stageProg, c4, c3)
					SetGradA(tails[2], "HORIZONTAL", c3, c2x)
					SetGradA(tails[3], "VERTICAL", c3, c2)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					local c2x = GetHSVTransition(stageProg, c2, c1)
					SetGradA(tails[2], "HORIZONTAL", c2x, c1)
					SetGradA(tails[3], "VERTICAL", c4, c1)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
				elseif inf.tail.startPoint == "TOPLEFT" then
					local c2x = GetHSVTransition(stageProg, c1, c4)
					SetGradA(tails[2], "VERTICAL", c4, c2x)
					SetGradA(tails[3], "HORIZONTAL", c3, c4)
					SetGradA(tails[4], "VERTICAL", c3, c2)
				else
					local c2x = GetHSVTransition(stageProg, c3, c2)
					SetGradA(tails[2], "VERTICAL", c2x, c2)
					SetGradA(tails[3], "HORIZONTAL", c2, c1)
					SetGradA(tails[4], "VERTICAL", c4, c1)
				end
			elseif progress < 0.5 + cornerP then
				local stageProg = (progress - 0.5) / cornerP
				if inf.tail.startPoint == "TOPRIGHT" then
					local c3x = GetHSVTransition(stageProg, c3, c2)
					SetGradA(tails[3], "VERTICAL", c3x, c2)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					local c3x = GetHSVTransition(stageProg, c1, c4)
					SetGradA(tails[3], "VERTICAL", c4, c3x)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
				elseif inf.tail.startPoint == "TOPLEFT" then
					local c3x = GetHSVTransition(stageProg, c4, c3)
					SetGradA(tails[3], "HORIZONTAL", c3, c3x)
					SetGradA(tails[4], "VERTICAL", c3, c2)
				else
					local c3x = GetHSVTransition(stageProg, c2, c1)
					SetGradA(tails[3], "HORIZONTAL", c3x, c1)
					SetGradA(tails[4], "VERTICAL", c4, c1)
				end
			else
				local stageProg = (progress - 0.5 - cornerP) / (0.5 - cornerP)
				if inf.tail.startPoint == "TOPRIGHT" then
					local c4x = GetHSVTransition(stageProg, c2, c3)
					SetGradA(tails[4], "HORIZONTAL", c4x, c1)
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					local c4x = GetHSVTransition(stageProg, c4, c3)
					SetGradA(tails[4], "HORIZONTAL", c3, c4x)
				elseif inf.tail.startPoint == "TOPLEFT" then
					local c4x = GetHSVTransition(stageProg, c3, c2)
					SetGradA(tails[4], "VERTICAL", c4x, c2)
				else
					local c4x = GetHSVTransition(stageProg, c1, c4)
					SetGradA(tails[4], "VERTICAL", c4, c4x)
				end
			end
		else
			if progress < cornerP then
				local stageProg = progress / cornerP
				if inf.tail.startPoint == "TOPRIGHT" then
					local c1x = GetHSVTransition(stageProg, c1, c2)
					SetGradA(tails[1], "HORIZONTAL", c2, c1x)
					SetGradA(tails[2], "VERTICAL", c3, c2)
					SetGradA(tails[3], "HORIZONTAL", c3, c4)
					SetGradA(tails[4], "VERTICAL", c4, c1)
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					local c1x = GetHSVTransition(stageProg, c3, c4)
					SetGradA(tails[1], "HORIZONTAL", c1x, c4)
					SetGradA(tails[2], "VERTICAL", c4, c1)
					SetGradA(tails[3], "HORIZONTAL", c2, c1)
					SetGradA(tails[4], "VERTICAL", c3, c2)
				elseif inf.tail.startPoint == "TOPLEFT" then
					local c1x = GetHSVTransition(stageProg, c2, c3)
					SetGradA(tails[1], "VERTICAL", c3, c1x)
					SetGradA(tails[2], "HORIZONTAL", c3, c4)
					SetGradA(tails[3], "VERTICAL", c4, c1)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
				else
					local c1x = GetHSVTransition(stageProg, c4, c1)
					SetGradA(tails[1], "VERTICAL", c1x, c1)
					SetGradA(tails[2], "HORIZONTAL", c2, c1)
					SetGradA(tails[3], "VERTICAL", c3, c2)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
				end
			elseif progress < 0.5 then
				local stageProg = (progress - cornerP) / (0.5 - cornerP)
				if inf.tail.startPoint == "TOPRIGHT" then
					local c2x = GetHSVTransition(stageProg, c2, c3)
					SetGradA(tails[2], "VERTICAL", c3, c2x)
					SetGradA(tails[3], "HORIZONTAL", c3, c4)
					SetGradA(tails[4], "VERTICAL", c4, c1)
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					local c2x = GetHSVTransition(stageProg, c4, c1)
					SetGradA(tails[2], "VERTICAL", c2x, c1)
					SetGradA(tails[3], "HORIZONTAL", c2, c1)
					SetGradA(tails[4], "VERTICAL", c3, c2)
				elseif inf.tail.startPoint == "TOPLEFT" then
					local c2x = GetHSVTransition(stageProg, c3, c4)
					SetGradA(tails[2], "HORIZONTAL", c2x, c4)
					SetGradA(tails[3], "VERTICAL", c4, c1)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
				else
					local c2x = GetHSVTransition(stageProg, c1, c2)
					SetGradA(tails[2], "HORIZONTAL", c2, c2x)
					SetGradA(tails[3], "VERTICAL", c3, c2)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
				end
			elseif progress < 0.5 + cornerP then
				local stageProg = (progress - 0.5) / cornerP
				if inf.tail.startPoint == "TOPRIGHT" then
					local c3x = GetHSVTransition(stageProg, c3, c4)
					SetGradA(tails[3], "HORIZONTAL", c3x, c4)
					SetGradA(tails[4], "VERTICAL", c4, c1)
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					local c3x = GetHSVTransition(stageProg, c1, c2)
					SetGradA(tails[3], "HORIZONTAL", c2, c3x)
					SetGradA(tails[4], "VERTICAL", c3, c2)
				elseif inf.tail.startPoint == "TOPLEFT" then
					local c3x = GetHSVTransition(stageProg, c4, c1)
					SetGradA(tails[3], "VERTICAL", c3x, c1)
					SetGradA(tails[4], "HORIZONTAL", c2, c1)
				else
					local c3x = GetHSVTransition(stageProg, c2, c3)
					SetGradA(tails[3], "VERTICAL", c3, c3x)
					SetGradA(tails[4], "HORIZONTAL", c3, c4)
				end
			else
				local stageProg = (progress - 0.5 - cornerP) / (0.5 - cornerP)
				if inf.tail.startPoint == "TOPRIGHT" then
					local c4x = GetHSVTransition(stageProg, c4, c1)
					SetGradA(tails[4], "VERTICAL", c4x, c1)
				elseif inf.tail.startPoint == "BOTTOMLEFT" then
					local c4x = GetHSVTransition(stageProg, c2, c3)
					SetGradA(tails[4], "VERTICAL", c3, c4x)
				elseif inf.tail.startPoint == "TOPLEFT" then
					local c4x = GetHSVTransition(stageProg, c1, c2)
					SetGradA(tails[4], "HORIZONTAL", c2, c4x)
				else
					local c4x = GetHSVTransition(stageProg, c3, c4)
					SetGradA(tails[4], "HORIZONTAL", c4x, c4)
				end
			end
		end
	end
end

local borderF = {
	TOPLEFT = {
		[1] = {
			Set = BorderSet1LineCorner,
			Update = BorderUpdate1LineCorner,
			Gradient = BorderGradient1LineCorner,
			tailN = 4
			},
		[2] = {
			Set = BorderSet2LinesCorner,
			Update = BorderUpdate2LinesCorner,
			Gradient = BorderGradient2LinesCorner,
			tailN = 4
			},
		[4] = {
			Set = BorderSet4LinesCorner,
			Update = BorderUpdate4LinesCorner,
			Gradient = BorderGradient4LinesCorner,
			tailN = 8
			}
	},
	TOP = {
		[1] = {
			Set = BorderSet1LineCenter,
			Update = BorderUpdate1LineCenter,
			Gradient = BorderGradient1LineCenter,
			tailN = 5
			},
		[2] = {
			Set = BorderSet2LinesCenter,
			Update = BorderUpdate2LinesCenter,
			Gradient = BorderGradient2LinesCenter,
			tailN = 6
			},
		[4] = {
			Set = BorderSet4LinesCenter,
			Update = BorderUpdate4LinesCenter,
			Gradient = BorderGradient4LinesCenter,
			tailN = 8
			}
	}
}

borderF["TOPRIGHT"] = borderF["TOPLEFT"]
borderF["BOTTOMRIGHT"] = borderF["TOPLEFT"]
borderF["BOTTOMLEFT"] = borderF["TOPLEFT"]
borderF["LEFT"] = borderF["TOP"]
borderF["BOTTOM"] = borderF["TOP"]
borderF["RIGHT"] = borderF["TOP"]

local function BorderReverse(startPoint, N)
	if N == 2 then
		if startPoint == "TOP" or startPoint == "BOTTOM" then
			return "LEFT"
		elseif startPoint == "LEFT" or startPoint == "RIGHT" then
			return "TOP"
		elseif startPoint == "TOPLEFT" or startPoint == "BOTTOMRIGHT" then
			return "TOPRIGHT"
		elseif startPoint == "BOTTOMLEFT" or startPoint == "TOPRIGHT" then
			return "TOPLEFT"
		end
	elseif N == 1 then
		if startPoint == "TOP" then
			return "BOTTOM"
		elseif startPoint == "TOPRIGHT" then
			return "BOTTOMLEFT"
		elseif startPoint == "RIGHT" then
			return "LEFT"
		elseif startPoint == "BOTTOMRIGHT" then
			return "TOPLEFT"
		elseif startPoint == "BOTTOM" then
			return "TOP"
		elseif startPoint == "BOTTOMLEFT" then
			return "TOPRIGHT"
		elseif startPoint == "LEFT" then
			return "RIGHT"
		elseif startPoint == "TOPLEFT" then
			return "BOTTOMRIGHT"
		end
	else
		if startPoint == "TOP" or startPoint == "BOTTOM" or startPoint == "LEFT" or startPoint == "RIGHT" then
			return "TOPLEFT"
		elseif startPoint == "TOPLEFT" or startPoint == "BOTTOMRIGHT" or startPoint == "BOTTOMLEFT" or startPoint == "TOPRIGHT" then
			return "TOP"
		end
	end
end

---- Flash Internal Functions ----
local function FlashSetSplit(f, secondStage)
	local inf = f.inf
	for _,tex in pairs(inf.flash.list) do
		tex:ClearAllPoints()
	end

	if inf.flash.startPoint == "LEFT" or inf.flash.startPoint == "RIGHT" then
		inf.flash.Set1 = f.SetWidth
		inf.flash.size1 = f:GetWidth()
		inf.flash.list[1]:SetHeight(f:GetHeight())
		inf.flash.list[2]:SetHeight(f:GetHeight())
		if secondStage then
			inf.flash.list[1]:SetPoint("LEFT", f, "LEFT")
			inf.flash.list[2]:SetPoint("RIGHT", f, "RIGHT")
		else
			inf.flash.list[1]:SetPoint("RIGHT", f, "CENTER")
			inf.flash.list[2]:SetPoint("LEFT", f, "CENTER")
		end
	elseif inf.flash.startPoint == "TOP" or inf.flash.startPoint == "BOTTOM" then
		inf.flash.Set1 = f.SetHeight
		inf.flash.size1 = f:GetHeight()
		inf.flash.list[1]:SetWidth(f:GetWidth())
		inf.flash.list[2]:SetWidth(f:GetWidth())
		if secondStage then
			inf.flash.list[1]:SetPoint("BOTTOM", f, "CENTER")
			inf.flash.list[2]:SetPoint("TOP", f, "CENTER")
		else
			inf.flash.list[1]:SetPoint("TOP", f, "TOP")
			inf.flash.list[2]:SetPoint("BOTTOM", f, "BOTTOM")
		end
	elseif inf.flash.startPoint == "TOPLEFT" or inf.flash.startPoint == "BOTTOMRIGHT" then
		inf.flash.Set1 = f.SetHeight
		inf.flash.size1 = (f:GetHeight() + f:GetWidth())/2 * sqrt(2)
		inf.flash.list[1]:SetWidth((f:GetHeight() + f:GetWidth())/2 * sqrt(2))
		inf.flash.list[2]:SetWidth((f:GetHeight() + f:GetWidth())/2 * sqrt(2))
		if secondStage then
			inf.flash.list[1]:SetPoint("BOTTOM", f, "CENTER")
			inf.flash.list[2]:SetPoint("TOP", f, "CENTER")
			inf.flash.list[1]:SetRotation(0.785, 0.5, 0)
			inf.flash.list[2]:SetRotation(0.785, 0.5, 1)
		else
			inf.flash.list[1]:SetPoint("TOP", f, "TOPLEFT")
			inf.flash.list[2]:SetPoint("BOTTOM", f, "BOTTOMRIGHT")
			inf.flash.list[1]:SetRotation(0.785, 0.5, 1)
			inf.flash.list[2]:SetRotation(0.785, 0.5, 0)
		end
	else
		inf.flash.Set1 = f.SetHeight
		inf.flash.size1 = (f:GetHeight() + f:GetWidth())/2 * sqrt(2)
		inf.flash.list[1]:SetWidth((f:GetHeight() + f:GetWidth())/2 * sqrt(2))
		inf.flash.list[2]:SetWidth((f:GetHeight() + f:GetWidth())/2 * sqrt(2))
		if secondStage then
			inf.flash.list[1]:SetPoint("BOTTOM", f, "CENTER")
			inf.flash.list[2]:SetPoint("TOP", f, "CENTER")
			inf.flash.list[1]:SetRotation(-0.785, 0.5, 0)
			inf.flash.list[2]:SetRotation(-0.785, 0.5, 1)
		else
			inf.flash.list[1]:SetPoint("TOP", f, "TOPRIGHT")
			inf.flash.list[2]:SetPoint("BOTTOM", f, "BOTTOMLEFT")
			inf.flash.list[1]:SetRotation(-0.785, 0.5, 1)
			inf.flash.list[2]:SetRotation(-0.785, 0.5, 0)
		end
	end
end

local function FlashUpdateSplit(f, progress)
	local inf = f.inf
	local oldProgress = inf.flash.old

	if progress < 0.5 then
		if oldProgress <= 0 or oldProgress > 0.5 then
			FlashSetSplit(f, false)
		end
		inf.flash.Set1(inf.flash.list[1], inf.flash.size1 * progress)
		inf.flash.Set1(inf.flash.list[2], inf.flash.size1 * progress)
	else
		if oldProgress < 0.5 or oldProgress >= 0.99 then
			FlashSetSplit(f, true)
		end
		local stageProg = 1 - progress
		inf.flash.Set1(inf.flash.list[1], (inf.flash.size1) * stageProg)
		inf.flash.Set1(inf.flash.list[2], (inf.flash.size1) * stageProg)
	end
	inf.flash.old = oldProgress
end

local function FlashSetShutter(f)
	local inf = f.inf
	for _,tex in pairs(inf.flash.list) do
		tex:ClearAllPoints()
	end

	inf.flash.list[2]:SetPoint("CENTER", f, "CENTER")
	if inf.flash.startPoint == "LEFT" then
		inf.flash.Set1 = f.SetHeight
		inf.flash.size1 = f:GetHeight()
		inf.flash.list[1]:SetPoint("LEFT", f, "LEFT")
		inf.flash.list[3]:SetPoint("RIGHT", f, "RIGHT")
		inf.flash.list[1]:SetWidth(f:GetWidth() / 3)
		inf.flash.list[2]:SetWidth(f:GetWidth() / 3)
		inf.flash.list[3]:SetWidth(f:GetWidth() / 3)
	elseif inf.flash.startPoint == "RIGHT" then
		inf.flash.Set1 = f.SetHeight
		inf.flash.size1 = f:GetHeight()
		inf.flash.list[1]:SetPoint("RIGHT", f, "RIGHT")
		inf.flash.list[3]:SetPoint("LEFT", f, "LEFT")
		inf.flash.list[1]:SetWidth(f:GetWidth() / 3)
		inf.flash.list[2]:SetWidth(f:GetWidth() / 3)
		inf.flash.list[3]:SetWidth(f:GetWidth() / 3)
	elseif inf.flash.startPoint == "TOP" then
		inf.flash.Set1 = f.SetWidth
		inf.flash.size1 = f:GetWidth()
		inf.flash.list[1]:SetPoint("TOP", f, "TOP")
		inf.flash.list[3]:SetPoint("BOTTOM", f, "BOTTOM")
		inf.flash.list[1]:SetHeight(f:GetHeight() / 3)
		inf.flash.list[2]:SetHeight(f:GetHeight() / 3)
		inf.flash.list[3]:SetHeight(f:GetHeight() / 3)
	elseif inf.flash.startPoint == "BOTTOM" then
		inf.flash.Set1 = f.SetWidth
		inf.flash.size1 = f:GetWidth()
		inf.flash.list[1]:SetPoint("BOTTOM", f, "BOTTOM")
		inf.flash.list[3]:SetPoint("TOP", f, "TOP")
		inf.flash.list[1]:SetHeight(f:GetHeight() / 3)
		inf.flash.list[2]:SetHeight(f:GetHeight() / 3)
		inf.flash.list[3]:SetHeight(f:GetHeight() / 3)
	elseif inf.flash.startPoint == "TOPLEFT" then
		inf.flash.Set1 = f.SetWidth
		inf.flash.size1 = (f:GetWidth() + f:GetHeight()) * sqrt(2) / 2
		inf.flash.list[1]:SetPoint("TOP", f, "TOPLEFT")
		inf.flash.list[3]:SetPoint("BOTTOM", f, "BOTTOMRIGHT")
		inf.flash.list[1]:SetHeight(inf.flash.size1 / 3)
		inf.flash.list[2]:SetHeight(inf.flash.size1 / 3+ 0.1)
		inf.flash.list[3]:SetHeight(inf.flash.size1 / 3)
		inf.flash.list[1]:SetRotation(0.785, 0.5, 1)
		inf.flash.list[2]:SetRotation(0.785, 0.5, 0.5)
		inf.flash.list[3]:SetRotation(0.785, 0.5, 0)
	elseif inf.flash.startPoint == "TOPRIGHT" then
		inf.flash.Set1 = f.SetWidth
		inf.flash.size1 = (f:GetWidth() + f:GetHeight()) * sqrt(2) / 2
		inf.flash.list[1]:SetPoint("TOP", f, "TOPRIGHT")
		inf.flash.list[3]:SetPoint("BOTTOM", f, "BOTTOMLEFT")
		inf.flash.list[1]:SetHeight(inf.flash.size1 / 3)
		inf.flash.list[2]:SetHeight(inf.flash.size1 / 3+ 0.1)
		inf.flash.list[3]:SetHeight(inf.flash.size1 / 3)
		inf.flash.list[1]:SetRotation(-0.785, 0.5, 1)
		inf.flash.list[2]:SetRotation(-0.785, 0.5, 0.5)
		inf.flash.list[3]:SetRotation(-0.785, 0.5, 0)
	elseif inf.flash.startPoint == "BOTTOMRIGHT" then
		inf.flash.Set1 = f.SetWidth
		inf.flash.size1 = (f:GetWidth() + f:GetHeight()) * sqrt(2) / 2
		inf.flash.list[1]:SetPoint("BOTTOM", f, "BOTTOMRIGHT")
		inf.flash.list[3]:SetPoint("TOP", f, "TOPLEFT")
		inf.flash.list[1]:SetHeight(inf.flash.size1 / 3)
		inf.flash.list[2]:SetHeight(inf.flash.size1 / 3+ 0.1)
		inf.flash.list[3]:SetHeight(inf.flash.size1 / 3)
		inf.flash.list[1]:SetRotation(0.785, 0.5, 0)
		inf.flash.list[2]:SetRotation(0.785, 0.5, 0.5)
		inf.flash.list[3]:SetRotation(0.785, 0.5, 1)
	else
		inf.flash.Set1 = f.SetWidth
		inf.flash.size1 = (f:GetWidth() + f:GetHeight()) * sqrt(2) / 2
		inf.flash.list[1]:SetPoint("BOTTOM", f, "BOTTOMLEFT")
		inf.flash.list[3]:SetPoint("TOP", f, "TOPRIGHT")
		inf.flash.list[1]:SetHeight(inf.flash.size1 / 3)
		inf.flash.list[2]:SetHeight(inf.flash.size1 / 3 + 0.1)
		inf.flash.list[3]:SetHeight(inf.flash.size1 / 3)
		inf.flash.list[1]:SetRotation(-0.785, 0.5, 0)
		inf.flash.list[2]:SetRotation(-0.785, 0.5, 0.5)
		inf.flash.list[3]:SetRotation(-0.785, 0.5, 1)
	end
end

local function FlashUpdateShutter(f, progress)
	local inf = f.inf
	local oldProgress = inf.flash.old

	if progress < 0.167 then
		if oldProgress <= 0 or oldProgress > 0.167 then
			inf.flash.list[1]:Show()
			inf.flash.list[2]:Hide()
			inf.flash.list[3]:Hide()
		end
		inf.flash.Set1(inf.flash.list[1], inf.flash.size1 * progress * 6)
	elseif progress < 0.333 then
		if oldProgress < 0.167 or oldProgress >= 0.333 then
			inf.flash.list[1]:Show()
			inf.flash.list[2]:Show()
			inf.flash.list[3]:Hide()
			inf.flash.Set1(inf.flash.list[1], inf.flash.size1)
		end
		inf.flash.Set1(inf.flash.list[2], (inf.flash.size1) * (progress - 0.167) * 6)
	elseif progress < 0.5 then
		if oldProgress < 0.333 or oldProgress >= 0.5 then
			inf.flash.list[1]:Show()
			inf.flash.list[2]:Show()
			inf.flash.list[3]:Show()
			inf.flash.Set1(inf.flash.list[1], inf.flash.size1)
			inf.flash.Set1(inf.flash.list[2], inf.flash.size1)
		end
		inf.flash.Set1(inf.flash.list[3], (inf.flash.size1) * (progress - 0.333) * 6)
	elseif progress < 0.667 then
		if oldProgress < 0.5 or oldProgress >= 0.667 then
			inf.flash.list[1]:Show()
			inf.flash.list[2]:Show()
			inf.flash.list[3]:Show()
			inf.flash.Set1(inf.flash.list[2], inf.flash.size1)
			inf.flash.Set1(inf.flash.list[3], inf.flash.size1)
		end
		inf.flash.Set1(inf.flash.list[1], (inf.flash.size1) * (1 - (progress - 0.5) * 6))
	elseif progress < 0.833 then
		if oldProgress < 0.667 or oldProgress >= 0.833 then
			inf.flash.list[1]:Hide()
			inf.flash.list[2]:Show()
			inf.flash.list[3]:Show()
			inf.flash.Set1(inf.flash.list[3], inf.flash.size1)
		end
		inf.flash.Set1(inf.flash.list[2], (inf.flash.size1) * (1 - (progress - 0.667) * 6))
	else
		if oldProgress < 0.833 or oldProgress >= 0.99 then
			inf.flash.list[1]:Hide()
			inf.flash.list[2]:Hide()
			inf.flash.list[3]:Show()
		end
		inf.flash.Set1(inf.flash.list[3], (inf.flash.size1) * (1 - progress) * 6)
	end
	inf.flash.old = oldProgress
end

local function FlashSetSlide(f)

end

local function FlashUpdateSlide(f, progress)

end

local function FlashSetSquare(f)

end

local function FlashUpdateSquare(f, progress)

end

local flashF = {
	split = {
		Update = FlashUpdateSplit,
		Set = FlashSetSplit,
		flashN = 2
		},
	shutter = {
		Update = FlashUpdateShutter,
		Set = FlashSetShutter,
		flashN = 3
		},
	square = {
		Update = FlashUpdateSquare,
		flashN = 4
	}
}


---- Bling ----
local function BlingUpdate(self, elapsed)
	local inf = self.inf
	local progress = self.timer + (inf.reverse and -1 or 1) * elapsed / inf.duration
	local old, new

	if inf.sine then
		new = math.sin(1.5708 * progress)
		old = math.sin(1.5708 * self.timer)
	else
		new = progress
		old = self.timer
	end

	local width,height = self:GetSize()
	if self.inf.width ~= width or self.inf.height ~= height then
		if inf.noTails then
			inf.FlashSet(self, new > 0.5)
		else
			inf.FlashSet(self, new > 0.33)
			inf.BorderSet(self)
		end
		self.inf.width = width
		self.inf.height = height
	end

	if inf.noTails then
		if new < 0.5 then
			if old >= 0.5 and inf.midCallback then
				inf.midCallback()
			end
			inf.FlashUpdate(self, new)
		else
			if old <= 0.5 and inf.midCallback then
				inf.midCallback()
			end
			inf.FlashUpdate(self, new)
		end

	else
		if new < 0.33 and old >= 0.33 then
			if inf.midCallback then
				inf.midCallback()
			end
			for _,v in pairs(inf.tail.list) do
				v:Hide()
			end
		end

		if new < 0.66 then
			if old >= 0.66 then
				for _, v in pairs(self.inf.flash.list) do
					v:Show()
				end
				inf.BorderSet(self)
			end
			inf.FlashUpdate(self, new / 0.66)
		elseif old < 0.66 or old >= 0.99 then
			for _, v in pairs(self.inf.flash.list) do
				v:Hide()
			end
		end

		if new > 0.33 then
			if old <= 0.33 then
				if inf.midCallback then
					inf.midCallback()
				end
			end

			if old <= 0.33 or self.timer >= 1 then
				for _,v in pairs(inf.tail.list) do
					v:Show()
				end
				inf.BorderSet(self)
			end

			if new > 0.66 then
				inf.BorderUpdate(self, (new - 0.66) / 0.34)
				if inf.gradient then
					inf.BorderGradient(self,    (new - 0.66) / 0.34, elapsed)
				end
			elseif inf.gradient then
					inf.BorderGradient(self,    0, elapsed)
			end
		end
	end

	if progress > 1 or progress < 0 then
		if inf.endCallback then inf.endCallback() end
		self:SetClipsChildren(false)
		GlowFramePool:Release(self)
		return
	end
	self.timer = progress
end

local blingTemplates = {
	default = {
		flash = "split",
		startPoint = "TOPLEFT",
		color = {0.95, 0.95, 0.95, 0.85},
		gradient = {{1, .75, .75, 1}, {.75, 1, .75, 1}, {.75, .75, 1, 1}},
		gradientFrequency = 0.7,
		noTails = false,
		sine = true,
		tails = {
			th = 2,
			N = 1,
			color = {0.95, 0.95, 0.95, 0.85},
			startPoint = "BOTTOMLEFT",
			clockwise = true,
			mirror = true
		},
		reverse = false,
		duration = 0.65,
		xOffset = 0,
		yOffset = 0,
		frameLevel = 8
	}
}

function lib.Bling(r, options)
	if not r then   return end
	local template = options.template and blingTemplates[options.template] or blingTemplates.default
	options = AcquireOptions(options, template)

	local BorderSet = borderF[options.tails.startPoint][options.tails.N].Set
	local BorderUpdate = borderF[options.tails.startPoint][options.tails.N].Update
	local BorderGradient = borderF[options.tails.startPoint][options.tails.N].Gradient
	local tailN = options.noTails and 0 or borderF[options.tails.startPoint][options.tails.N].tailN

	local FlashSet = flashF[options.flash].Set
	local FlashUpdate = flashF[options.flash].Update
	local flashN = flashF[options.flash].flashN

	addFrameAndTex(r,options.color,"_Bling",options.key,tailN + flashN,options.xOffset,options.yOffset,textureList.white,{0,1,0,1},nil,options.frameLevel)
	local f = r["_Bling"..(options.key or "")]

	f.timer = options.reverse and 1 or 0.001

	f.inf = {
		reverse = options.reverse,
		th = options.tails.th,
		duration = options.duration,
		noTails = options.noTails,
		sine = options.sine,
		midCallback = options.midCallback,
		endCallback = options.endCallback,
		gradient = options.gradient,
		gradientFrequency = options.gradientFrequency,
		width = f:GetWidth(),
		height = f:GetHeight(),
		BorderSet = BorderSet,
		BorderUpdate = BorderUpdate,
		BorderGradient = BorderGradient,
		FlashUpdate = FlashUpdate,
		FlashSet = FlashSet
	}

	f.inf.flash = {
		startPoint = options.startPoint,
		list = {},
		old = options.reverse and 1 or 0
		}
	for i = 1,flashN do
		f.inf.flash.list[i] = f.textures[i]
	end

	f.inf.tail = {
		list = {},
		startPoint = options.tails.startPoint,
		mirror = options.tails.mirror,
		old = options.reverse and 1 or 0,
		clockwise = options.tails.clockwise
		}
	for i = 1, tailN do
		f.inf.tail.list[i] = f.textures[i + flashN]
	end
	if options.tails.color then
		local tCol = options.tails.color
		for _, v in pairs(f.inf.tail.list) do
			v:SetVertexColor(tCol[1], tCol[2], tCol[3], tCol[4])
		end
	end

	FlashSet(f, options.reverse)
	BlingUpdate(f, .001)

	f:SetClipsChildren(true)
	f:SetScript("OnUpdate", BlingUpdate)
end

local BlingParamters = {
	name = L["Bling"],
	desc = L["Creates Bling over target region"],
	default = blingTemplates.default,
	start = lib.Bling,
	stop = function() end,
	type = "group",
	args = {
		flash = {
			name = L["Flash"],
			desc = L["Type of flash"],
			type = "select",
			values = {
				["split"] = "split",
				["shutter"] = "shutter",
				["square"] = "square",
				["slide"] = "slide"
			}
		},
		startPoint = {
			name = L["Start point"],
			desc = L["Starting point of flash"],
			type = "select",
			values = {
				["TOPLEFT"] = L["TOPLEFT"],
				["TOP"] = L["TOP"],
				["TOPRIGHT"] = L["TOPRIGHT"],
				["RIGHT"] = L["RIGHT"],
				["BOTTOMRIGHT"] = L["BOTTOMRIGHT"],
				["BOTTOM"] = L["BOTTOM"],
				["BOTTOMLEFT"] = L["BOTTOMLEFT"],
				["LEFT"] = L["LEFT"]
			}
		},
		color = {
			name = L["Color"],
			desc = L["Color of flash"],
			type = "color"
		},
		gradient = {
			name = L["Gradient"],
			desc = L["Grradient of tail lines"],
			type = "gradient"
		},
		gradientFrequency = {
			name = L["Gradient frequency"],
			desc = L["Frequency of gradient rotation"],
			type = "range",
			softMin = -2,
			softMax = 2,
			step = 0.05
		},
		noTails = {
			name = L["Disable tail lines"],
			desc = L["Bling will not show lines, only flash"],
			type = "toggle"
		},
		sine = {
			name = L["Sine"],
			desc = L["Use sinusoidal progress instead of linear"],
			type = "toggle",
		},
		tails = {
			name = L["Tail parameters"],
			desc = L["Parameters of tail lines if enabled"],
			type = "group",
			args = {
				th = {
					name = L["Tail thickness"],
					desc = L["Thickness of tails"],
					type = "range",
					min = 1,
					softMax = 5,
					step = 1
				},
				N = {
					name = L["Tail N"],
					desc = L["Number of tail lines"],
					type = "select",
					values = {
						["1"] = 1,
						["2"] = 2,
						["4"] = 4
					}
				},
				color = {
					name = L["Tail color"],
					desc = L["Color of tail lines"],
					type = "color"
				},
				startPoint = {
					name = L["Tail start point"],
					desc = L["Starting point of tail lines"],
					type = "select",
					values = {
						["TOPLEFT"] = L["TOPLEFT"],
						["TOP"] = L["TOP"],
						["TOPRIGHT"] = L["TOPRIGHT"],
						["RIGHT"] = L["RIGHT"],
						["BOTTOMRIGHT"] = L["BOTTOMRIGHT"],
						["BOTTOM"] = L["BOTTOM"],
						["BOTTOMLEFT"] = L["BOTTOMLEFT"],
						["LEFT"] = L["LEFT"]
					}
				},
				clockwise = {
					name = L["Clockwise"],
					desc = L["Direction of tail progress if not mirrored"],
					type = "toggle"
				},
				mirror = {
					name = L["Mirror"],
					desc = L["Mirror tail line progress"],
					type = "toggle"
				}
			}
		},
		reverse = {
			name = L["Reverse"],
			desc = L["Reverses Bling progress"],
			type = "toggle"
		},
		duration = {
			name = L["Duration"],
			desc = L["Bling duration in seconds"],
			type = "range",
			min = 0.05,
			softMax = 1,
			step = 0.05
		},
		xOffset = {
			name = L["X offset"],
			desc = L["X offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		yOffset = {
			name = L["Y offset"],
			desc = L["Y offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		frameLevel = {
			name = L["Frame level"],
			desc = L["Glow frame level"],
			type = "range",
			softMin = 1,
			softMax = 20,
			min = 0,
			max = 10000,
			step = 1
		}
	}
}
GlowList["Bling"] = BlingParamters

---- New Glow ----
local function BorderPulseUpdate(self, elapsed)
	local progress = self.timer + elapsed * self.inf.frequency * (self.inf.sign or 1)

	if self.inf.finish and (self.inf.forceStop or progress > 1) then
		GlowFramePool:Release(self)
		return
	end

	if self.inf.annoy then
		local annoyProg = (self.inf.annoyProg or 0) + elapsed * self.inf.annoyFrequency
		if annoyProg > 1 then
			lib.Bling(self, self.inf.flashOptions)
			annoyProg = annoyProg % 1
		end
		self.inf.annoyProg = annoyProg
	end

	local width,height = self:GetSize()

	if self.inf.width ~= width or self.inf.height ~= height then
		self.inf.BorderSet(self, true)
		self.inf.width = width
		self.inf.height = height
	end
	if progress < 0 or  progress > 1 then
		self.inf.tail.old = progress
		self.inf.sign = -self.inf.sign
		progress = 1 - progress%1

		if self.inf.tail.mirror then
			self.inf.tail.startPoint = BorderReverse(self.inf.tail.startPoint, self.inf.N)
			if self.inf.N == 4 then
				self.inf.BorderSet = borderF[self.inf.tail.startPoint][self.inf.N].Set
				self.inf.BorderUpdate = borderF[self.inf.tail.startPoint][self.inf.N].Update
				self.inf.BorderGradient = borderF[self.inf.tail.startPoint][self.inf.N].Gradient
			end
		else
			self.inf.tail.clockwise = not(self.inf.tail.clockwise)
		end
		self.inf.BorderSet(self)
	end

	local newProg = self.inf.sine and math.sin(1.5708 * progress) or progress
	self.inf.BorderUpdate(self, newProg)
	if self.inf.gradient then
		self.inf.BorderGradient(self, newProg, elapsed)
	end
	self.timer = progress
end

local borderPulseTemplates = {
	default = {
		N = 1,
		startPoint = "BOTTOMLEFT",
		th = 2,
		color = {0.95, 0.95, 0.95, 0.85},
		gradient = {{1, .75, .75, 1}, {.75, 1, .75, 1}, {.75, .75, 1, 1}},
		gradientFrequency = 0.7,
		sine = true,
		clockwise = true,
		mirror = true,
		startBling = true,
		repeatBling = true,
		annoy = false,
		annoyFrequency = 0.5,
		blingOptions = blingTemplates.default,
		forceStop = false,
		frequency = 2,
		xOffset = 0,
		yOffset = 0,
		frameLevel = 8
	}
}

borderPulseTemplates.default.blingOptions.reverse = true
borderPulseTemplates.default.blingOptions.noTails = true
borderPulseTemplates.default.blingOptions.sine = false
borderPulseTemplates.default.blingOptions.duration = 0.5

function lib.BorderPulse_Start(r, options)
	if not r then   return end
	local template = options.template and borderPulseTemplates[options.template] or borderPulseTemplates.default
	options = AcquireOptions(options, template)


	local BorderSet = borderF[options.startPoint][options.N].Set
	local BorderUpdate = borderF[options.startPoint][options.N].Update
	local BorderGradient = borderF[options.startPoint][options.N].Gradient
	local tailN = borderF[options.startPoint][options.N].tailN


	local update = addFrameAndTex(r,options.color,"_BorderPulse",options.key,tailN,options.xOffset,options.yOffset,textureList.white,{0,1,0,1},nil,options.frameLevel)
	local f = r["_BorderPulse"..(options.key or "")]

	f.timer = f.timer or 0.001

	f.inf = {
		N = options.N,
		th = options.th,
		frequency = options.frequency,
		sine = options.sine,
		forceStop = options.forceStop,
		gradient = options.gradient,
		gradientFrequency = options.gradientFrequency,
		annoy = options.annoy,
		annoyFrequency = options.annoyFrequency,
		BorderSet = BorderSet,
		BorderUpdate = BorderUpdate,
		BorderGradient = BorderGradient,
		width = f:GetWidth(),
		height = f:GetHeight(),
		gProgress = f.inf and  f.inf.gProgress or 0,
		sign = f.inf and f.inf.sign or 1
	}

	f.inf.tail = {
		clockwise = options.clockwise,
		list = f.textures,
		startPoint = options.startPoint,
		mirror = options.mirror,
		old =  f.inf and f.inf.old or 0
	}

	if f.inf.sign == -1 then
		if f.inf.tail.mirror then
			f.inf.tail.startPoint = BorderReverse(f.inf.tail.startPoint, f.inf.N)
			if f.inf.N == 4 then
				f.inf.BorderSet = borderF[f.inf.tail.startPoint][f.inf.N].Set
				f.inf.BorderUpdate = borderF[f.inf.tail.startPoint][f.inf.N].Update
				f.inf.BorderGradient = borderF[f.inf.tail.startPoint][f.inf.N].Gradient
			end
		else
			f.inf.tail.clockwise = not(f.inf.tail.clockwise)
		end
	end

	if options.repeatBling or options.annoy then
		local flashOptions = AcquireOptions(options.blingOptions, blingTemplates.default)
		if not flashOptions.noTails then
			flashOptions.noTails = true
			flashOptions.duration = flashOptions.duration * .66
		end
		f.inf.flashOptions = flashOptions
	end

	f.inf.BorderSet(f)
	BorderPulseUpdate(f, .001)

	if options.startBling then
		if not(update) then
			f:Hide()
		end
		if not(update) then
			options.blingOptions.midCallback = function() if f.name and f.name == "_BorderPulse"..(options.key or "") then f:Show() end end
			options.blingOptions.endCallback = function() if f.name and f.name == "_BorderPulse"..(options.key or "") then f:SetScript("OnUpdate", BorderPulseUpdate) end end
			lib.Bling(r, options.blingOptions)
		elseif options.repeatBling then
			lib.Bling(r, f.inf.flashOptions)
		end
	end
end

function lib.BorderPulse_Stop(r, key, force)
	if not r or not r["_BorderPulse"..(key or "")] then
		return
	end
	if force then
		GlowFramePool:Release(r["_BorderPulse"..(key or "")])
	else
		r["_BorderPulse"..(key or "")].inf.finish = true
	end
end

local BorderPulseParamters = {
	name = L["Border Pulse"],
	desc = L["Creates Border Pulse glow over target region"],
	pixelTemplates = borderPulseTemplates.default,
	start = lib.BorderPulse_Start,
	stop = lib.BorderPulse_Stop,
	type = "group",
	args = {
		N = {
			name = L["Tail N"],
			desc = L["Number of tail lines"],
			type = "select",
			values = {
				["1"] = 1,
				["2"] = 2,
				["4"] = 4
			}
		},
		startPoint = {
			name = L["Start point"],
			desc = L["Starting point of flash"],
			type = "select",
			values = {
				["TOPLEFT"] = L["TOPLEFT"],
				["TOP"] = L["TOP"],
				["TOPRIGHT"] = L["TOPRIGHT"],
				["RIGHT"] = L["RIGHT"],
				["BOTTOMRIGHT"] = L["BOTTOMRIGHT"],
				["BOTTOM"] = L["BOTTOM"],
				["BOTTOMLEFT"] = L["BOTTOMLEFT"],
				["LEFT"] = L["LEFT"]
			}
		},
		th = {
			name = L["Tail thickness"],
			desc = L["Thickness of tails"],
			type = "range",
			min = 1,
			softMax = 5,
			step = 1
		},
		color = {
			name = L["Color"],
			desc = L["Color of flash"],
			type = "color"
		},
		gradient = {
			name = L["Gradient"],
			desc = L["Grradient of tail lines"],
			type = "gradient"
		},
		gradientFrequency = {
			name = L["Gradient frequency"],
			desc = L["Frequency of gradient rotation"],
			type = "range",
			softMin = -2,
			softMax = 2,
			step = 0.05
		},
		sine = {
			name = L["Sine"],
			desc = L["Use sinusoidal progress instead of linear"],
			type = "toggle",
		},
		clockwise = {
			name = L["Clockwise"],
			desc = L["Direction of pulses"],
			type = "toggle"
		},
		mirror = {
			name = L["Mirror"],
			desc = L["Mirror tail line progress"],
			type = "toggle"
		},
		startBling = {
			name = L["Start Bling"],
			desc = L["Show Bling on first application of glow"],
			type = "toggle",
		},
		repeatBling = {
			name = L["Repeat Bling"],
			desc = L["Show Bling on reapplication of glow"],
			type = "toggle",
		},
		annoy = {
			name = L["Annoy"],
			desc = L["Repeat Bling periodically while glow is active"],
			type = "toggle",
		},
		annoyFrequency = {
			name = L["Annoy frequency"],
			desc = L["Frequency of annoy Bling if eenabled"],
			type = "range",
			min = 0.05,
			softMin = 0.25,
			softMax = 2,
			step = 0.05
		},
		blingOptions = BlingParamters,
		forceStop = {
			name = L["Force stop"],
			desc = L["Stops glow immediately without waiting for period end"],
			type = "toggle",
		},
		frequency = {
			name = L["Glow frequency"],
			desc = L["Frequency of glow pulses"],
			type = "range",
			softMin = -2,
			softMax = 2,
			step = 0.05
		},
		xOffset = {
			name = L["X offset"],
			desc = L["X offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		yOffset = {
			name = L["Y offset"],
			desc = L["Y offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		frameLevel = {
			name = L["Frame level"],
			desc = L["Glow frame level"],
			type = "range",
			softMin = 1,
			softMax = 20,
			min = 0,
			max = 10000,
			step = 1
		}
	}
}

GlowList["Border Pulse Glow"] = BorderPulseParamters
---- Pixel Glow ----
local pixelTemplates = {
	default = {
		N = 2,
		th = 2,
		color = {0.95, 0.95, 0.95, 0.85},
		gradient = {{1, .75, .75, 1}, {.75, 1, .75, 1}, {.75, .75, 1, 1}},
		gradientFrequency = .75,
		startBling = true,
		repeatBling = true,
		annoy = false,
		annoyFrequency = 0.5,
		blingOptions = BlingParamters,
		forceStop = false,
		fadeDuration = 0.45,
		frequency = -0.55,
		xOffset = 0,
		yOffset = 0,
		frameLevel = 8
	}
}

local function PixelUpdateInfo(f)
	local width, height = f:GetSize()
	if width ~= f.inf.width or height ~= f.inf.height then
		if not((width + height) > 0) then
				return false
		end
		f.inf.length = min(f.inf.defaultLength, width - 2, height - 2)
		local perimeter = 2*(width + height)
		f.inf.p = {
			[1] = (width - f.inf.length) / perimeter,
			[2] = width / perimeter,
			[3] = (width + height - f.inf.length) / perimeter,
			[4] = (width + height) / perimeter,
			[5] = (2*width + height - f.inf.length) / perimeter,
			[6] = (2*width + height) / perimeter,
			[7] = (perimeter - f.inf.length) / perimeter,
			[8] = 1
		}
		if f.inf.gradient then
			f.inf.gradientStep = f.inf.length / perimeter
		end

		f.inf.add[1]:ClearAllPoints()
		f.inf.add[1]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -f.inf.th)
		f.inf.add[1]:SetWidth(f.inf.th)

		f.inf.add[2]:ClearAllPoints()
		f.inf.add[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", f.inf.th, 0)
		f.inf.add[2]:SetHeight(f.inf.th)

		f.inf.add[3]:ClearAllPoints()
		f.inf.add[3]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, f.inf.th)
		f.inf.add[3]:SetWidth(f.inf.th)

		f.inf.add[4]:ClearAllPoints()
		f.inf.add[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT", -f.inf.th, 0)
		f.inf.add[4]:SetHeight(f.inf.th)

		f.inf.width = width
		f.inf.height = height
		return true, true
	end
	return true, false
end

local function PixelSetLine(f, texN, progress)
	local tex = f.textures[texN]
	local p = f.inf.p
	local length = f.inf.length
	local th = f.inf.th

	tex:ClearAllPoints()
	if progress < p[1] then
			tex: SetWidth(length)
			tex: SetHeight(th)
	elseif progress < p[2] then
			tex:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
			tex:SetHeight(th)
	elseif progress < p[3] then
			tex:SetWidth(th)
			tex:SetHeight(length)
	elseif progress < p[4] then
			tex:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
			tex:SetWidth(th)
	elseif progress < p[5] then
			tex:SetWidth(length)
			tex:SetHeight(th)
	elseif progress < p[6] then
			tex:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
			tex:SetHeight(th)
	elseif progress < p[7] then
			tex:SetWidth(th)
			tex:SetHeight(length)
	else
			tex:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
			tex:SetWidth(th)
	end
end

local function PixelUpdateLine(f, texN, addVisible, oldProgress, progress)
local tex = f.textures[texN]
local p = f.inf.p
local width = f.inf.width
local height = f.inf.height
local length = f.inf.length
local th = f.inf.th
	if progress < p[1] then
		if oldProgress > p[1] then
			tex: ClearAllPoints()
			tex: SetWidth(length)
			tex: SetHeight(th)
		end
		tex:SetPoint("TOPRIGHT", f, "TOPRIGHT", -progress / p[1] * (width - length), 0)

	elseif progress < p[2] then
		if oldProgress > p[2] or oldProgress < p[2] then
			tex:ClearAllPoints()
			tex:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
			tex:SetHeight(th)
		end
		addVisible[1] = true
		local stageProg = (progress - p[1]) / (p[2] - p[1])
		tex:SetWidth((1 - stageProg) * (length - th) + th)
		f.inf.add[1]:SetHeight(stageProg * (length - th))

	elseif progress < p[3] then
		if oldProgress > p[3] or oldProgress < p[2] then
			tex:ClearAllPoints()
			tex:SetWidth(th)
			tex:SetHeight(length)
		end
		tex:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -(progress - p[2]) / (p[3] - p[2])*(height - length))
	elseif progress < p[4] then
		if oldProgress > p[4] or oldProgress > p[3] then
			tex:ClearAllPoints()
			tex:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
			tex:SetWidth(th)
		end
		addVisible[2] = true
		local stageProg = (progress - p[3]) / (p[4] - p[3])
		tex:SetHeight((1 - stageProg) * (length - th) + th)
		f.inf.add[2]:SetWidth(stageProg * (length - th))

	elseif progress < p[5] then
		if oldProgress > p[5] or oldProgress < p[4] then
			tex:ClearAllPoints()
			tex:SetWidth(length)
			tex:SetHeight(th)
		end
		tex:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", (progress - p[4]) / (p[5] - p[4]) * (width - length), 0)

	elseif progress < p[6] then
		if oldProgress > p[6] or oldProgress < p[7] then
			tex:ClearAllPoints()
			tex:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
			tex:SetHeight(th)
		end
		addVisible[3] = true
		local stageProg = (progress - p[5]) / (p[6] - p[5])
		tex:SetWidth((1 - stageProg) * (length - th) + th)
		f.inf.add[3]:SetHeight(stageProg * (length - th))

	elseif progress < p[7] then
		if oldProgress < p[6] or oldProgress > p[7] then
			tex:ClearAllPoints()
			tex:SetWidth(th)
			tex:SetHeight(length)
		end
		tex:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, (progress - p[6]) / (p[7] - p[6]) * (height - length), 0)

	else
		if oldProgress < p[7] then
			tex:ClearAllPoints()
			tex:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
			tex:SetWidth(th)
		end
		addVisible[4] = true
		local stageProg = (progress - p[7]) / (1 - p[7])
		tex:SetHeight((1 - stageProg) * (length - th) + th)
		f.inf.add[4]:SetWidth(stageProg * (length - th))
	end
end

local function PixelGradientLine(f, texN, progress, c1, c2)
	local tex = f.textures[texN]
	local p = f.inf.p
	if progress < p[1] then
		SetGradA(tex, "HORIZONTAL", c2, c1)

	elseif progress < p[2] then
		local stageProg = (progress - p[1])/(p[2] - p[1])
		local c12 = GetHSVTransition ((1-stageProg), c1, c2)
		SetGradA(tex, "HORIZONTAL", c12, c1)
		SetGradA(f.inf.add[1], "VERTICAL", c2, c12)

	elseif progress < p[3] then
		SetGradA(tex, "VERTICAL", c2, c1)

	elseif progress < p[4] then
		local stageProg = (progress - p[3])/(p[4] - p[3])
		local c12 = GetHSVTransition ((1-stageProg), c1, c2)
		SetGradA(tex, "VERTICAL", c12, c1)
		SetGradA(f.inf.add[2], "HORIZONTAL", c12, c2)

	elseif progress < p[5] then
		SetGradA(tex, "HORIZONTAL", c1, c2)

	elseif progress < p[6] then
		local stageProg = (progress - p[5])/(p[6] - p[5])
		local c12 = GetHSVTransition ((1-stageProg), c1, c2)
		SetGradA(tex, "HORIZONTAL", c1, c12)
		SetGradA(f.inf.add[3], "VERTICAL", c12, c2)

	elseif progress < p[7] then
		SetGradA(tex, "VERTICAL", c1, c2)

	else
		local stageProg = (progress - p[7])/(1 - p[7])
		local c12 = GetHSVTransition ((1 - stageProg), c1, c2)
		SetGradA(tex, "VERTICAL", c1, c12)
		SetGradA(f.inf.add[4], "HORIZONTAL", c2, c12)
	end
end

local function PixelUpdate(self, elapsed)
	local oldProgress = self.timer
	local inf = self.inf
	self.timer = self.timer + elapsed * inf.frequency
	self.timer = self.timer%1

	if inf.finish then
		inf.fading = inf.fading or 0
		if inf.forceStop or inf.fading > inf.fadeDuration then
			GlowFramePool:Release(self)
			return
		else
			inf.fading = inf.fading or 0
			self:SetAlpha(1 - inf.fading / inf.fadeDuration)
			inf.fading = inf.fading + elapsed
		end
	else
		if inf.annoy then
			local annoyProg = (inf.annoyProg or 0) + elapsed * inf.annoyFrequency
			if annoyProg > 1 then
				lib.Bling(self, inf.flashOptions)
				annoyProg = annoyProg % 1
			end
			inf.annoyProg = annoyProg
		end
	end

	local nonZero, change = PixelUpdateInfo(self)
	if not(nonZero) then return end

	local tex = self.textures
	local addVisible = {}
	local g = inf.gradient

	if g then
		local gN = #g
		inf.gradientPhase = inf.gradientFrequency * elapsed
		for i = 1, inf.N do
			local old = (oldProgress + (i-1)/inf.N)%1
			local new = (self.timer + (i-1)/inf.N)%1
			if change then
				PixelSetLine(self, i, new)
			end
			PixelUpdateLine(self, i, addVisible, old, new)

			local p1 = (new + inf.gradientPhase + 0.001)%1
			local p2 = (p1 + inf.gradientStep)%1
			local c1 = GetHSVTransition ((p1 * gN)%1 , g[ceil(p1 * gN)], g[ceil(p1 * gN)%gN + 1])
			local c2 = GetHSVTransition ((p2 * gN)%1 , g[ceil(p2 * gN)], g[ceil(p2 * gN)%gN + 1])
			PixelGradientLine(self, i, new, c1, c2)
		end
	else
		for i = 1, inf.N do
			local old = (oldProgress + (i - 1) / inf.N)%1
			local new = (self.timer + (i - 1) / inf.N)%1
			if change then
				PixelSetLine(self, i, new)
			end
			PixelUpdateLine(self, i, addVisible, old, new)
		end
	end

	for i = 1,4 do
		if addVisible[i] ~= inf.addVisible[i] then inf.add[i]:SetShown(addVisible[i]) end
	end
	inf.addVisible = addVisible
end

function lib.PixelGlow_Start(r,options)
	if not r then   return end

	local template = options and options.template and pixelTemplates[options.template] or pixelTemplates.default
	options = AcquireOptions(options, template)

	local update = addFrameAndTex(r,options.color,"_PixelGlow",options.key or "" ,options.N + 4,options.xOffset,options.yOffset,textureList.white,{0,1,0,1},nil,options.frameLevel)
	local f = r["_PixelGlow"..(options.key or "")]

	local width,height = f:GetSize()

	options.length = options.length or min(math.floor((width + height) / options.N * 1.25))
	local length = min(options.length, width - 2, height - 2)

	f.timer = f.timer or 0.001
	f.inf = {
		th = options.th,
		defaultLength = options.length,
		length = length,
		N = options.N,
		frequency = -options.frequency,
		annoy = options.annoy,
		annoyFrequency = options.annoyFrequency,
		add = {f.textures[options.N + 1], f.textures[options.N + 2], f.textures[options.N + 3], f.textures[options.N + 4]},
		addVisible = {},
		gradient = options.gradient,
		gradientFrequency = options.gradientFrequency,
		gradientStep = length/(width + height),
		forceStop = options.forceStop,
		fadeDuration = options.fadeDuration
	}
	PixelUpdateInfo(f)
	for i = 1, options.N do
		local new = (f.timer + (i - 1) / options.N)%1
		local old = (new + 0.5)%1
		PixelUpdateLine(f, i, f.inf.addVisible, old, new)
	end

	for i = 1,4 do
		f.inf.add[i]:SetShown(f.inf.addVisible[i])
	end


	if options.repeatBling or options.annoy then
		local flashOptions = AcquireOptions(options.blingOptions, blingTemplates.default)
		if not flashOptions.noTails then
			flashOptions.noTails = true
			flashOptions.duration = flashOptions.duration * .66
		end
		f.inf.flashOptions = flashOptions
	end

	PixelUpdate(f, .001)

	f:SetScript("OnUpdate",PixelUpdate)
	if options.startBling then
		if not(update) then
			f:Hide()
		end
		if not(update) then
			options.blingOptions.gradient = options.gradient
			options.blingOptions.midCallback = function() if f.name and f.name == "_PixelGlow"..(options.key or "") then f:Show() end end
			lib.Bling(r, options.blingOptions)
		elseif options.repeatBling then
			lib.Bling(r, f.inf.flashOptions)
		end
	end
end

function lib.PixelGlow_Stop(r, key, force)
	if not r or not r["_PixelGlow"..(key or "")] then
		return
	end
	if force then
		GlowFramePool:Release(r["_PixelGlow"..(key or "")])
	else
		r["_PixelGlow"..(key or "")].inf.finish = true
	end
end

local PixelGlowParamters = {
	name = L["Pixel Glow"],
	desc = L["Creates Pixel glow over target region"],
	default = pixelTemplates.default,
	start = lib.PixelGlow_Start,
	stop = lib.PixelGlow_Stop,
	type = "group",
	args = {
		N = {
			name = L["Number of lines"],
			desc = L["Number of lines"],
			type = "range",
			min = 1,
			softMax = 14,
			step = 1
		},
		th = {
			name = L["Line thickness"],
			desc = L["Thickness of lines"],
			type = "range",
			min = 1,
			softMax = 5,
			step = 1
		},
		color = {
			name = L["Color"],
			desc = L["Color of lines"],
			type = "color"
		},
		gradient = {
			name = L["Gradient"],
			desc = L["Gradient of lines"],
			type = "gradient"
		},
		gradientFrequency = {
			name = L["Gradient frequency"],
			desc = L["Frequency of gradient rotation"],
			type = "range",
			softMin = -2,
			softMax = 2,
			step = 0.05
		},
		startBling = {
			name = L["Start Bling"],
			desc = L["Show Bling on first application of glow"],
			type = "toggle",
		},
		repeatBling = {
			name = L["Repeat Bling"],
			desc = L["Show Bling on reapplication of glow"],
			type = "toggle",
		},
		annoy = {
			name = L["Annoy"],
			desc = L["Repeat Bling periodically while glow is active"],
			type = "toggle",
		},
		annoyFrequency = {
			name = L["Annoy frequency"],
			desc = L["Frequency of annoy Bling if eenabled"],
			type = "range",
			min = 0.05,
			softMin = 0.25,
			softMax = 2,
			step = 0.05
		},
		blingOptions = BlingParamters,
		forceStop = {
			name = L["Force stop"],
			desc = L["Stops glow immediately without waiting for fade"],
			type = "toggle",
		},
		fadeDuration = {
			name = L["Fade duration"],
			desc = L["Duration of fade animation if not forced stop"],
			type = "range",
			min = 0,
			softMin = 0.05,
			softMax = 1,
			step = 0.05
		},
		frequency = {
			name = L["Glow frequency"],
			desc = L["Frequency of glow pulses"],
			type = "range",
			softMin = -2,
			softMax = 2,
			step = 0.05
		},
		xOffset = {
			name = L["X offset"],
			desc = L["X offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		yOffset = {
			name = L["Y offset"],
			desc = L["Y offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		frameLevel = {
			name = L["Frame level"],
			desc = L["Glow frame level"],
			type = "range",
			softMin = 1,
			softMax = 20,
			min = 0,
			max = 10000,
			step = 1
		}
	}
}

GlowList["Pixel Glow"] = PixelGlowParamters


---- Autocast Glow ----
local function acUpdate(self,elapsed)
	local width,height = self:GetSize()
	if width ~= self.info.width or height ~= self.info.height then
		self.info.width = width
		self.info.height = height
		self.info.perimeter = 2*(width+height)
		self.info.bottomlim = height*2+width
		self.info.rightlim = height+width
		self.info.space = self.info.perimeter/self.info.N
	end

	local texIndex = 0;
	for k=1,4 do
		self.timer[k] = self.timer[k] + elapsed * self.info.frequency / k
		if self.timer[k] > 1 or self.timer[k] <-1 then
			self.timer[k] = self.timer[k]%1
		end
		for i = 1,self.info.N do
			texIndex = texIndex+1
			local position = (self.info.space*i+self.info.perimeter*self.timer[k])%self.info.perimeter
			if position>self.info.bottomlim then
				self.textures[texIndex]: SetPoint("CENTER",self,"BOTTOMRIGHT",-position+self.info.bottomlim,0)
			elseif position>self.info.rightlim then
				self.textures[texIndex]: SetPoint("CENTER",self,"TOPRIGHT",0,-position+self.info.rightlim)
			elseif position>self.info.height then
				self.textures[texIndex]: SetPoint("CENTER",self,"TOPLEFT",position-self.info.height,0)
			else
				self.textures[texIndex]: SetPoint("CENTER",self,"BOTTOMLEFT",0,position)
			end
		end
	end
end

local autoCastTemplates = {
	default = {
		color = {0.95,0.95,0.32,1},
		N = 4,
		frequency = 0.125,
		scale = 1,
		xOffset = 0,
		yOffset = 0,
		frameLevel = 8
	}
}

function lib.AutoCastGlow_Start(r,options)
	if not r then return end

	local template = options and options.template and autoCastTemplates[options.template] or autoCastTemplates.default
	options = AcquireOptions(options, template)

	addFrameAndTex(r,options.color,"_AutoCastGlow",options.key,options.N * 4,options.xOffset,options.yOffset,textureList.shine,{0.8115234375,0.9169921875,0.8798828125,0.9853515625},true, options.frameLevel)
	local f = r["_AutoCastGlow"..options.key]
	local sizes = {7,6,5,4}
	for k,size in pairs(sizes) do
		for i = 1,options.N do
			f.textures[i + options.N*(k-1)]:SetSize(size * options.scale,size * options.scale)
		end
	end
	f.timer = f.timer or {0,0,0,0}
	f.info = f.info or {}
	f.info = {
		N = options.N,
		frequency = options.frequency
	}
	f:SetScript("OnUpdate",acUpdate)
end

function lib.AutoCastGlow_Stop(r,key)
	if not r then return end

	key = key or ""
	if not r["_AutoCastGlow"..key] then
		return false
	else
		GlowFramePool:Release(r["_AutoCastGlow"..key])
	end
end

local AutoCastParamters = {
	name = L["AutoCast Glow"],
	desc = L["Creates AutoCast glow over target region"],
	default = autoCastTemplates.default,
	start = lib.AutoCastGlow_Start,
	stop = lib.AutoCastGlow_Stop,
	type = "group",
	args = {
		N = {
			name = L["Number of sparks"],
			desc = L["Number of sparks"],
			type = "range",
			min = 1,
			softMax = 15,
			step = 1
		},
		scale = {
			name = L["Spark scale"],
			desc = L["Spark scale"],
			type = "range",
			min = 0,
			softMin = 0.25,
			softMax = 4,
			step = 0.05
		},
		color = {
			name = L["Color"],
			desc = L["Color of sparks"],
			type = "color"
		},
		frequency = {
			name = L["Glow frequency"],
			desc = L["Frequency of glow"],
			type = "range",
			min = 0.05,
			softMin = 0.05,
			softMax = 2,
			step = 0.05
		},
		xOffset = {
			name = L["X offset"],
			desc = L["X offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		yOffset = {
			name = L["Y offset"],
			desc = L["Y offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		frameLevel = {
			name = L["Frame level"],
			desc = L["Glow frame level"],
			type = "range",
			softMin = 1,
			softMax = 20,
			min = 0,
			max = 10000,
			step = 1
		}
	}
}

GlowList["AutoCast Glow"] = AutoCastParamters


---- Action Button Glow ----
local function ButtonGlowResetter(framePool,frame)
	frame:SetScript("OnUpdate",nil)
	local parent = frame:GetParent()
	if parent._ButtonGlow then
		parent._ButtonGlow = nil
	end
	frame:Hide()
	frame:ClearAllPoints()
end
local ButtonGlowPool = CreateFramePool("Frame",GlowParent,nil,ButtonGlowResetter)
lib.ButtonGlowPool = ButtonGlowPool

local function CreateScaleAnim(group, target, order, duration, x, y, delay)
	local scale = group:CreateAnimation("Scale")
	scale:SetChildKey(target)
	scale:SetOrder(order)
	scale:SetDuration(duration)
	scale:SetScale(x, y)

	if delay then
		scale:SetStartDelay(delay)
	end
end

local function CreateAlphaAnim(group, target, order, duration, fromAlpha, toAlpha, delay, appear)
	local alpha = group:CreateAnimation("Alpha")
	alpha:SetChildKey(target)
	alpha:SetOrder(order)
	alpha:SetDuration(duration)
	alpha:SetFromAlpha(fromAlpha)
	alpha:SetToAlpha(toAlpha)
	if delay then
		alpha:SetStartDelay(delay)
	end
	if appear then
		table.insert(group.appear, alpha)
	else
		table.insert(group.fade, alpha)
	end
end

local function AnimIn_OnPlay(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetSize(frameWidth, frameHeight)
	frame.spark:SetAlpha(not(frame.color) and 1.0 or 0.3*frame.color[4])
	frame.innerGlow:SetSize(frameWidth / 2, frameHeight / 2)
	frame.innerGlow:SetAlpha(not(frame.color) and 1.0 or frame.color[4])
	frame.innerGlowOver:SetAlpha(not(frame.color) and 1.0 or frame.color[4])
	frame.outerGlow:SetSize(frameWidth * 2, frameHeight * 2)
	frame.outerGlow:SetAlpha(not(frame.color) and 1.0 or frame.color[4])
	frame.outerGlowOver:SetAlpha(not(frame.color) and 1.0 or frame.color[4])
	frame.ants:SetSize(frameWidth * 0.85, frameHeight * 0.85)
	frame.ants:SetAlpha(0)
	frame:Show()
end

local function AnimIn_OnFinished(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetAlpha(0)
	frame.innerGlow:SetAlpha(0)
	frame.innerGlow:SetSize(frameWidth, frameHeight)
	frame.innerGlowOver:SetAlpha(0.0)
	frame.outerGlow:SetSize(frameWidth, frameHeight)
	frame.outerGlowOver:SetAlpha(0.0)
	frame.outerGlowOver:SetSize(frameWidth, frameHeight)
	frame.ants:SetAlpha(not(frame.color) and 1.0 or frame.color[4])
end

local function AnimIn_OnStop(group)
	local frame = group:GetParent()
	local frameWidth, frameHeight = frame:GetSize()
	frame.spark:SetAlpha(0)
	frame.innerGlow:SetAlpha(0)
	frame.innerGlowOver:SetAlpha(0.0)
	frame.outerGlowOver:SetAlpha(0.0)
end

local function bgHide(self)
	if self.animOut:IsPlaying() then
		self.animOut:Stop()
		ButtonGlowPool:Release(self)
	end
end

local function bgUpdate(self, elapsed)
	AnimateTexCoords(self.ants, 256, 256, 48, 48, 22, elapsed, self.throttle);
	local cooldown = self:GetParent().cooldown;
	if(cooldown and cooldown:IsShown() and cooldown:GetCooldownDuration() > 3000) then
		self:SetAlpha(0.5);
	else
		self:SetAlpha(1.0);
	end
end

local function configureButtonGlow(f,alpha)
	f.spark = f:CreateTexture(nil, "BACKGROUND")
	f.spark:SetPoint("CENTER")
	f.spark:SetAlpha(0)
	f.spark:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.spark:SetTexCoord(0.00781250, 0.61718750, 0.00390625, 0.26953125)

	-- inner glow
	f.innerGlow = f:CreateTexture(nil, "ARTWORK")
	f.innerGlow:SetPoint("CENTER")
	f.innerGlow:SetAlpha(0)
	f.innerGlow:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.innerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

	-- inner glow over
	f.innerGlowOver = f:CreateTexture(nil, "ARTWORK")
	f.innerGlowOver:SetPoint("TOPLEFT", f.innerGlow, "TOPLEFT")
	f.innerGlowOver:SetPoint("BOTTOMRIGHT", f.innerGlow, "BOTTOMRIGHT")
	f.innerGlowOver:SetAlpha(0)
	f.innerGlowOver:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.innerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)

	-- outer glow
	f.outerGlow = f:CreateTexture(nil, "ARTWORK")
	f.outerGlow:SetPoint("CENTER")
	f.outerGlow:SetAlpha(0)
	f.outerGlow:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.outerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

	-- outer glow over
	f.outerGlowOver = f:CreateTexture(nil, "ARTWORK")
	f.outerGlowOver:SetPoint("TOPLEFT", f.outerGlow, "TOPLEFT")
	f.outerGlowOver:SetPoint("BOTTOMRIGHT", f.outerGlow, "BOTTOMRIGHT")
	f.outerGlowOver:SetAlpha(0)
	f.outerGlowOver:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
	f.outerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)

	-- ants
	f.ants = f:CreateTexture(nil, "OVERLAY")
	f.ants:SetPoint("CENTER")
	f.ants:SetAlpha(0)
	f.ants:SetTexture([[Interface\SpellActivationOverlay\IconAlertAnts]])

	f.animIn = f:CreateAnimationGroup()
	f.animIn.appear = {}
	f.animIn.fade = {}
	CreateScaleAnim(f.animIn, "spark",          1, 0.2, 1.5, 1.5)
	CreateAlphaAnim(f.animIn, "spark",          1, 0.2, 0, alpha, nil, true)
	CreateScaleAnim(f.animIn, "innerGlow",      1, 0.3, 2, 2)
	CreateScaleAnim(f.animIn, "innerGlowOver",  1, 0.3, 2, 2)
	CreateAlphaAnim(f.animIn, "innerGlowOver",  1, 0.3, alpha, 0, nil, false)
	CreateScaleAnim(f.animIn, "outerGlow",      1, 0.3, 0.5, 0.5)
	CreateScaleAnim(f.animIn, "outerGlowOver",  1, 0.3, 0.5, 0.5)
	CreateAlphaAnim(f.animIn, "outerGlowOver",  1, 0.3, alpha, 0, nil, false)
	CreateScaleAnim(f.animIn, "spark",          1, 0.2, 2/3, 2/3, 0.2)
	CreateAlphaAnim(f.animIn, "spark",          1, 0.2, alpha, 0, 0.2, false)
	CreateAlphaAnim(f.animIn, "innerGlow",      1, 0.2, alpha, 0, 0.3, false)
	CreateAlphaAnim(f.animIn, "ants",           1, 0.2, 0, alpha, 0.3, true)
	f.animIn:SetScript("OnPlay", AnimIn_OnPlay)
	f.animIn:SetScript("OnStop", AnimIn_OnStop)
	f.animIn:SetScript("OnFinished", AnimIn_OnFinished)

	f.animOut = f:CreateAnimationGroup()
	f.animOut.appear = {}
	f.animOut.fade = {}
	CreateAlphaAnim(f.animOut, "outerGlowOver", 1, 0.2, 0, alpha, nil, true)
	CreateAlphaAnim(f.animOut, "ants",          1, 0.2, alpha, 0, nil, false)
	CreateAlphaAnim(f.animOut, "outerGlowOver", 2, 0.2, alpha, 0, nil, false)
	CreateAlphaAnim(f.animOut, "outerGlow",     2, 0.2, alpha, 0, nil, false)
	f.animOut:SetScript("OnFinished", function(self) ButtonGlowPool:Release(self:GetParent())  end)

	f:SetScript("OnHide", bgHide)
end

local function updateAlphaAnim(f,alpha)
	for _,anim in pairs(f.animIn.appear) do
		anim:SetToAlpha(alpha)
	end
	for _,anim in pairs(f.animIn.fade) do
		anim:SetFromAlpha(alpha)
	end
	for _,anim in pairs(f.animOut.appear) do
		anim:SetToAlpha(alpha)
	end
	for _,anim in pairs(f.animOut.fade) do
		anim:SetFromAlpha(alpha)
	end
end

local ButtonGlowTextures = {["spark"] = true,["innerGlow"] = true,["innerGlowOver"] = true,["outerGlow"] = true,["outerGlowOver"] = true,["ants"] = true}

local buttonGlowTemplates = {
	default = {
		color = nil,
		frequency = 0.25,
		xOffset = 0,
		yOffset = 0,
		frameLevel = 8
	}
}

function lib.ButtonGlow_Start(r,options)
	if not r then return end

	local template = options and options.template and buttonGlowTemplates[options.template] or buttonGlowTemplates.default
	options = AcquireOptions(options, template)

	local throttle
	if options.frequency and options.frequency > 0 then
			throttle = 0.25 / options.frequency * 0.01
	else
			throttle = 0.01
	end

	if r._ButtonGlow then
		local f = r._ButtonGlow
		local width,height = r:GetSize()
		f:SetFrameLevel(r:GetFrameLevel() + options.frameLevel)
		f:SetSize(width*1.4 , height*1.4)
		f:SetPoint("TOPLEFT", r, "TOPLEFT", -width * 0.2, height * 0.2)
		f:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
		f.ants:SetSize(width*1.4*0.85, height*1.4*0.85)
		AnimIn_OnFinished(f.animIn)
		if f.animOut:IsPlaying() then
			f.animOut:Stop()
			f.animIn:Play()
		end

		if not(options.color) then
			for texture in pairs(ButtonGlowTextures) do
				f[texture]:SetDesaturated(nil)
				f[texture]:SetVertexColor(1,1,1)
				f[texture]:SetAlpha(f[texture]:GetAlpha()/(f.color and f.color[4] or 1))
				updateAlphaAnim(f, 1)
			end
			f.color = false
		else
			for texture in pairs(ButtonGlowTextures) do
				f[texture]:SetDesaturated(1)
				f[texture]:SetVertexColor(color[1],color[2],color[3])
				f[texture]:SetAlpha(f[texture]:GetAlpha()/(f.color and f.color[4] or 1)*color[4])
				updateAlphaAnim(f,color and color[4] or 1)
			end
			f.color = color
		end
		f.throttle = throttle
	else
		local f, new = ButtonGlowPool:Acquire()
		if new then
			configureButtonGlow(f,color and color[4] or 1)
		else
				updateAlphaAnim(f,color and color[4] or 1)
		end
		r._ButtonGlow = f
		local width,height = r:GetSize()
		f:SetParent(r)
		f:SetFrameLevel(r:GetFrameLevel() + options.frameLevel)
		f:SetSize(width * 1.4, height * 1.4)
		f:SetPoint("TOPLEFT", r, "TOPLEFT", -width * 0.2, height * 0.2)
		f:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
		if not(color) then
			f.color = false
			for texture in pairs(ButtonGlowTextures) do
				f[texture]:SetDesaturated(nil)
				f[texture]:SetVertexColor(1,1,1)
			end
		else
			f.color = color
			for texture in pairs(ButtonGlowTextures) do
				f[texture]:SetDesaturated(1)
				f[texture]:SetVertexColor(color[1],color[2],color[3])
			end
		end
		f.throttle = throttle
		f:SetScript("OnUpdate", bgUpdate)

		f.animIn:Play()

		if Masque and Masque.UpdateSpellAlert and (not r.overlay or not issecurevariable(r, "overlay")) then
			local old_overlay = r.overlay
			r.overlay = f
			Masque:UpdateSpellAlert(r)
			r.overlay = old_overlay
		end
	end
end

function lib.ButtonGlow_Stop(r)
	if r._ButtonGlow then
		if r._ButtonGlow.animIn:IsPlaying() then
			r._ButtonGlow.animIn:Stop()
			ButtonGlowPool:Release(r._ButtonGlow)
		elseif r:IsVisible() then
			r._ButtonGlow.animOut:Play()
		else
			ButtonGlowPool:Release(r._ButtonGlow)
		end
	end
end

local ButtonGlowParamters = {
	name = L["Blizzard Glow"],
	desc = L["Creates Blizzard glow over target region"],
	default = buttonGlowTemplates.default,
	start = lib.AutoCastGlow_Start,
	stop = lib.AutoCastGlow_Stop,
	type = "group",
	args = {
		color = {
			name = L["Color"],
			desc = L["Color of Blizzard glow"],
			type = "color"
		},
		frequency = {
			name = L["Glow frequency"],
			desc = L["Frequency of glow"],
			type = "range",
			min = 0.05,
			softMin = 0.05,
			softMax = 2,
			step = 0.05
		},
		xOffset = {
			name = L["X offset"],
			desc = L["X offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		yOffset = {
			name = L["Y offset"],
			desc = L["Y offset"],
			type = "range",
			softMin = -5,
			softMax = 5,
			step = 1
		},
		frameLevel = {
			name = L["Frame level"],
			desc = L["Glow frame level"],
			type = "range",
			softMin = 1,
			softMax = 20,
			min = 0,
			max = 10000,
			step = 1
		}
	}
}

GlowList["Button Glow"] = ButtonGlowParamters
