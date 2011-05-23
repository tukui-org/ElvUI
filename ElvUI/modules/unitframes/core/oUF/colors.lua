local WoW41 = select(4, GetBuildInfo()) == 40100

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
	disconnected = {.6, .6, .6},
	tapped = {.6,.6,.6},
	class = {},
	reaction = {},
}

-- We do this because people edit the vars directly, and changing the default
-- globals makes SPICE FLOW!
if(IsAddOnLoaded'!ClassColors' and CUSTOM_CLASS_COLORS) then
	local updateColors = function()
		for eclass, color in next, CUSTOM_CLASS_COLORS do
			colors.class[eclass] = {color.r, color.g, color.b}
		end

		local oUF = ns.oUF or _G[parent]
		if(oUF) then
			for _, obj in next, oUF.objects do
				obj:UpdateAllElements("CUSTOM_CLASS_COLORS")
			end
		end
	end

	updateColors()
	CUSTOM_CLASS_COLORS:RegisterCallback(updateColors)
else
	for eclass, color in next, RAID_CLASS_COLORS do
		colors.class[eclass] = {color.r, color.g, color.b}
	end
end

for eclass, color in next, FACTION_BAR_COLORS do
	colors.reaction[eclass] = {color.r, color.g, color.b}
end

-- http://www.wowwiki.com/ColorGradient
local inf = math.huge
local ColorGradient = function(perc, ...)
	-- Translate divison by zeros into 0, so we don't blow select.
	-- We check perc against itself because we rely on the fact that NaN can't equal NaN.
	if(perc ~= perc or perc == inf) then perc = 0 end

	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3
	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

Private.colors = colors

oUF.colors = colors
oUF.ColorGradient = ColorGradient

frame_metatable.__index.colors = colors
frame_metatable.__index.ColorGradient = ColorGradient
