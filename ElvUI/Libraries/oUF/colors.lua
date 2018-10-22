local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local frame_metatable = Private.frame_metatable

local colors = {
	smooth = {
		1, 0, 0,
		1, 1, 0,
		0, 1, 0
	},
	health = {49 / 255, 207 / 255, 37 / 255},
	disconnected = {.6, .6, .6},
	tapped = {.6, .6, .6},
	runes = {
		{247 / 255, 65 / 255, 57 / 255}, -- blood
		{148 / 255, 203 / 255, 247 / 255}, -- frost
		{173 / 255, 235 / 255, 66 / 255}, -- unholy
	},
	class = {},
	debuff = {},
	reaction = {},
	power = {},
}

-- We do this because people edit the vars directly, and changing the default
-- globals makes SPICE FLOW!
local function customClassColors()
	if(CUSTOM_CLASS_COLORS) then
		local function updateColors()
			for classToken, color in next, CUSTOM_CLASS_COLORS do
				colors.class[classToken] = {color.r, color.g, color.b}
			end

			for _, obj in next, oUF.objects do
				obj:UpdateAllElements('CUSTOM_CLASS_COLORS')
			end
		end

		updateColors()
		CUSTOM_CLASS_COLORS:RegisterCallback(updateColors)

		return true
	end
end

if(not customClassColors()) then
	for classToken, color in next, RAID_CLASS_COLORS do
		colors.class[classToken] = {color.r, color.g, color.b}
	end

	local eventHandler = CreateFrame('Frame')
	eventHandler:RegisterEvent('ADDON_LOADED')
	eventHandler:SetScript('OnEvent', function(self)
		if(customClassColors()) then
			self:UnregisterEvent('ADDON_LOADED')
			self:SetScript('OnEvent', nil)
		end
	end)
end

for debuffType, color in next, DebuffTypeColor do
	colors.debuff[debuffType] = {color.r, color.g, color.b}
end

for eclass, color in next, FACTION_BAR_COLORS do
	colors.reaction[eclass] = {color.r, color.g, color.b}
end

for power, color in next, PowerBarColor do
	if (type(power) == 'string') then
		if(type(select(2, next(color))) == 'table') then
			colors.power[power] = {}

			for index, color in next, color do
				colors.power[power][index] = {color.r, color.g, color.b}
			end
		else
			colors.power[power] = {color.r, color.g, color.b, atlas = color.atlas}
		end
	end
end

-- sourced from FrameXML/Constants.lua
colors.power[0] = colors.power.MANA
colors.power[1] = colors.power.RAGE
colors.power[2] = colors.power.FOCUS
colors.power[3] = colors.power.ENERGY
colors.power[4] = colors.power.COMBO_POINTS
colors.power[5] = colors.power.RUNES
colors.power[6] = colors.power.RUNIC_POWER
colors.power[7] = colors.power.SOUL_SHARDS
colors.power[8] = colors.power.LUNAR_POWER
colors.power[9] = colors.power.HOLY_POWER
colors.power[11] = colors.power.MAELSTROM
colors.power[12] = colors.power.CHI
colors.power[13] = colors.power.INSANITY
colors.power[16] = colors.power.ARCANE_CHARGES
colors.power[17] = colors.power.FURY
colors.power[18] = colors.power.PAIN

local function colorsAndPercent(a, b, ...)
	if(a <= 0 or b == 0) then
		return nil, ...
	elseif(a >= b) then
		return nil, select(select('#', ...) - 2, ...)
	end

	local num = select('#', ...) / 3
	local segment, relperc = math.modf((a / b) * (num - 1))
	return relperc, select((segment * 3) + 1, ...)
end

-- http://www.wowwiki.com/ColorGradient
--[[ Colors: oUF:RGBColorGradient(a, b, ...)
Used to convert a percent value (the quotient of `a` and `b`) into a gradient from 2 or more RGB colors. If more than 2
colors are passed, the gradient will be between the two colors which perc lies in an evenly divided range. A RGB color
is a sequence of 3 consecutive RGB percent values (in the range [0-1]). If `a` is negative or `b` is zero then the first
RGB color (the first 3 RGB values passed to the function) is returned. If `a` is bigger than or equal to `b`, then the
last 3 RGB values are returned.

* self - the global oUF object
* a    - value used as numerator to calculate the percentage (number)
* b    - value used as denominator to calculate the percentage (number)
* ...  - a list of RGB percent values. At least 6 values should be passed (number [0-1])
--]]
function oUF:RGBColorGradient(...)
	local relperc, r1, g1, b1, r2, g2, b2 = colorsAndPercent(...)
	if(relperc) then
		return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
	else
		return r1, g1, b1
	end
end

-- HCY functions are based on http://www.chilliant.com/rgb2hsv.html
local function getY(r, g, b)
	return 0.299 * r + 0.587 * g + 0.114 * b
end

local function rgbToHCY(r, g, b)
	local min, max = math.min(r, g, b), math.max(r, g, b)
	local chroma = max - min
	local hue
	if(chroma > 0) then
		if(r == max) then
			hue = ((g - b) / chroma) % 6
		elseif(g == max) then
			hue = (b - r) / chroma + 2
		elseif(b == max) then
			hue = (r - g) / chroma + 4
		end
		hue = hue / 6
	end
	return hue, chroma, getY(r, g, b)
end

local function hcyToRGB(hue, chroma, luma)
	local r, g, b = 0, 0, 0
	if(hue and luma > 0) then
		local h2 = hue * 6
		local x = chroma * (1 - math.abs(h2 % 2 - 1))
		if(h2 < 1) then
			r, g, b = chroma, x, 0
		elseif(h2 < 2) then
			r, g, b = x, chroma, 0
		elseif(h2 < 3) then
			r, g, b = 0, chroma, x
		elseif(h2 < 4) then
			r, g, b = 0, x, chroma
		elseif(h2 < 5) then
			r, g, b = x, 0, chroma
		else
			r, g, b = chroma, 0, x
		end

		local y = getY(r, g, b)
		if(luma < y) then
			chroma = chroma * (luma / y)
		elseif(y < 1) then
			chroma = chroma * (1 - luma) / (1 - y)
		end

		r = (r - y) * chroma + luma
		g = (g - y) * chroma + luma
		b = (b - y) * chroma + luma
	end
	return r, g, b
end

--[[ Colors: oUF:HCYColorGradient(a, b, ...)
Used to convert a percent value (the quotient of `a` and `b`) into a gradient from 2 or more HCY colors. If more than 2
colors are passed, the gradient will be between the two colors which perc lies in an evenly divided range. A HCY color
is a sequence of 3 consecutive values in the range [0-1]. If `a` is negative or `b` is zero then the first
HCY color (the first 3 HCY values passed to the function) is returned. If `a` is bigger than or equal to `b`, then the
last 3 HCY values are returned.

* self - the global oUF object
* a    - value used as numerator to calculate the percentage (number)
* b    - value used as denominator to calculate the percentage (number)
* ...  - a list of HCY color values. At least 6 values should be passed (number [0-1])
--]]
function oUF:HCYColorGradient(...)
	local relperc, r1, g1, b1, r2, g2, b2 = colorsAndPercent(...)
	if(not relperc) then
		return r1, g1, b1
	end

	local h1, c1, y1 = rgbToHCY(r1, g1, b1)
	local h2, c2, y2 = rgbToHCY(r2, g2, b2)
	local c = c1 + (c2 - c1) * relperc
	local y = y1 + (y2 - y1) * relperc

	if(h1 and h2) then
		local dh = h2 - h1
		if(dh < -0.5) then
			dh = dh + 1
		elseif(dh > 0.5) then
			dh = dh - 1
		end

		return hcyToRGB((h1 + dh * relperc) % 1, c, y)
	else
		return hcyToRGB(h1 or h2, c, y)
	end

end

--[[ Colors: oUF:ColorGradient(a, b, ...) or frame:ColorGradient(a, b, ...)
Used as a proxy to call the proper gradient function depending on the user's preference. If `oUF.useHCYColorGradient` is
set to true, `:HCYColorGradient` will be called, else `:RGBColorGradient`.

* self - the global oUF object or a unit frame
* a    - value used as numerator to calculate the percentage (number)
* b    - value used as denominator to calculate the percentage (number)
* ...  - a list of color values. At least 6 values should be passed (number [0-1])
--]]
function oUF:ColorGradient(...)
	return (oUF.useHCYColorGradient and oUF.HCYColorGradient or oUF.RGBColorGradient)(self, ...)
end

oUF.colors = colors
oUF.useHCYColorGradient = false

frame_metatable.__index.colors = colors
frame_metatable.__index.ColorGradient = oUF.ColorGradient
