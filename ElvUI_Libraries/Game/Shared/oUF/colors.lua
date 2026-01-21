local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local frame_metatable = Private.frame_metatable
local nierror = Private.nierror

local format, type = format, type
local select, next = select, next
local modf = math.modf

local _G = _G
local Mixin = Mixin
local ColorMixin = ColorMixin
local CreateColor = CreateColor
local GetAtlasInfo = C_Texture.GetAtlasInfo

local LibDispel = LibStub('LibDispel-1.0')
local DebuffColors = LibDispel:GetDebuffTypeColor()

local colorMixin = {
	SetAtlas = function(self, atlas)
		local info = GetAtlasInfo(atlas)
		if(not info) then
			return nierror(format('"%s" is an invalid atlas.', atlas))
		end

		self.atlas = atlas
	end,
	GetAtlas = function(self)
		return self.atlas
	end,
	SetCurve = _G.C_CurveUtil and function(self, ...)
		if(...) then
			if(self.curve) then
				self.curve:ClearPoints()
			else
				self.curve = _G.C_CurveUtil.CreateColorCurve()
			end

			if(type(...) == 'table') then
				for x, y in next, (...) do
					self.curve:AddPoint(x, y)
				end
			else
				for i = 1, select('#', ...), 2 do
					self.curve:AddPoint(select(i, ...), select(i+1, ...))
				end
			end
		else
			self.curve = nil
		end
	end or nil,
	GetCurve = _G.C_CurveUtil and function(self)
		return self.curve
	end or nil,
}

--[[ Colors: oUF:CreateColor(r, g, b[, a])
Wrapper for [Blizzard_SharedXMLBase/Color.lua's ColorMixin](https://warcraft.wiki.gg/wiki/ColorMixin), extended with extra methods for dealing with
atlases and curves.

The rgb values can be either normalized (0-1) or bytes (0-255).

* self - the global oUF object
* r    - value used as represent the red color (number)
* g    - value used to represent the green color (number)
* b    - value used to represent the blue color (number)
* a    - value used to represent the opacity (number, optional)

## Returns

* color - the ColorMixin-based object
--]]
function oUF:CreateColor(r, g, b, a)
	if(r > 1 or g > 1 or b > 1) then
		r, g, b = r / 255, g / 255, b / 255
	end

	local color = Mixin({}, ColorMixin, colorMixin)
	color:SetRGBA(r, g, b, a)

	-- provide a default curve for smooth colors
	if color.SetCurve then
		color:SetCurve({
			[  0] = CreateColor(1, 0, 0),
			[0.5] = CreateColor(1, 1, 0),
			[  1] = CreateColor(0, 1, 0),
		})
	end

	return color
end

-- https://warcraft.wiki.gg/wiki/ColorGradient
function oUF:ColorGradient(perc, ...)
	local value = select('#', ...)
	if perc >= 1 then
		return select(value - 2, ...)
	elseif perc <= 0 then
		return ...
	end

	local num = value / 3
	local segment, relperc = modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1+(r2-r1)*relperc, g1+(g2-g1)*relperc, b1+(b2-b1)*relperc
end

local colors = {
	smooth = Mixin({ 1, 0, 0, 1, 1, 0, 0, 1, 0 }, ColorMixin), -- ElvUI: used for classic variants
	happiness = {
		[1] = oUF:CreateColor(.69, .31, .31),
		[2] = oUF:CreateColor(.65, .63, .35),
		[3] = oUF:CreateColor(.33, .59, .33),
	},
	health = oUF:CreateColor(49, 207, 37),
	disconnected = oUF:CreateColor(0.6, 0.6, 0.6),
	tapped = oUF:CreateColor(0.6, 0.6, 0.6),
	runes = {
		oUF:CreateColor(247, 65, 57), -- blood
		oUF:CreateColor(148, 203, 247), -- frost
		oUF:CreateColor(173, 235, 66), -- unholy
		oUF:CreateColor(247, 66, 247), -- death
	},
	selection = {
		-- https://warcraft.wiki.gg/wiki/API_UnitSelectionColor
		[oUF.Enum.SelectionType.Hostile] = oUF:CreateColor(255, 0, 0),
		[oUF.Enum.SelectionType.Unfriendly] = oUF:CreateColor(255, 128, 0),
		[oUF.Enum.SelectionType.Neutral] = oUF:CreateColor(255, 255, 0),
		[oUF.Enum.SelectionType.Friendly] = oUF:CreateColor(0, 255, 0),
		[oUF.Enum.SelectionType.PlayerSimple] = oUF:CreateColor(0, 0, 255),
		[oUF.Enum.SelectionType.PlayerExtended] = oUF:CreateColor(96, 96, 255),
		[oUF.Enum.SelectionType.Party] = oUF:CreateColor(170, 170, 255),
		[oUF.Enum.SelectionType.PartyPvP] = oUF:CreateColor(170, 255, 170),
		[oUF.Enum.SelectionType.Friend] = oUF:CreateColor(83, 201, 255),
		[oUF.Enum.SelectionType.Dead] = oUF:CreateColor(128, 128, 128),
		[oUF.Enum.SelectionType.PartyPvPInBattleground] = oUF:CreateColor(0, 153, 0),
		[oUF.Enum.SelectionType.RecentAlly] = oUF:CreateColor(83, 201, 255),
	},
	class = {},
	dispel = {},
	reaction = {},
	power = {},
	threat = {
		[0] = oUF:CreateColor( .69, .69, .69),
		[1] = oUF:CreateColor( 1, 1, .47 ),
		[2] = oUF:CreateColor( 1, .6, 0 ),
		[3] = oUF:CreateColor( 1, 0, 0 ),
	},
}

do	-- We do this because people edit the vars directly, and changing the default globals makes SPICE FLOW!
	local function updateColors()
		for classToken, color in next, _G.CUSTOM_CLASS_COLORS do
			colors.class[classToken] = oUF:CreateColor(color.r, color.g, color.b)
		end

		for _, obj in next, oUF.objects do
			obj:UpdateAllElements('CUSTOM_CLASS_COLORS')
		end
	end

	local function customClassColors()
		if not _G.CUSTOM_CLASS_COLORS then return end

		updateColors()

		_G.CUSTOM_CLASS_COLORS:RegisterCallback(updateColors)

		return true
	end

	if not customClassColors() then
		for classToken, color in next, _G.RAID_CLASS_COLORS do
			colors.class[classToken] = oUF:CreateColor(color.r, color.g, color.b)
		end

		local eventHandler = CreateFrame('Frame')
		eventHandler:RegisterEvent('ADDON_LOADED')
		eventHandler:RegisterEvent('PLAYER_ENTERING_WORLD')
		eventHandler:SetScript('OnEvent', function(frame)
			if customClassColors() then
				frame:UnregisterAllEvents()
			end
		end)
	end
end

-- copy of DEBUFF_DISPLAY_INFO from AuraUtil
for debuffType, color in next, DebuffColors do
	colors.dispel[debuffType] = oUF:CreateColor(color.r, color.g, color.b)
end

for eclass, color in next, _G.FACTION_BAR_COLORS do
	colors.reaction[eclass] = oUF:CreateColor(color.r, color.g, color.b)
end

local staggerIndices = {
	green = 1,
	yellow = 2,
	red = 3
}

for power, color in next, PowerBarColor do
	if (type(power) == 'string') then
		if(color.r) then
			colors.power[power] = oUF:CreateColor(color.r, color.g, color.b)

			if(color.atlas) then
				colors.power[power]:SetAtlas(color.atlas)
			end
		else
			-- special handling for stagger
			colors.power[power] = {}

			for name, color_ in next, color do
				local index = (oUF.isRetail and staggerIndices[name]) or (not oUF.isRetail and name)
				if(index) then
					colors.power[power][index] = oUF:CreateColor(color_.r, color_.g, color_.b)

					if(color_.atlas) then
						colors.power[power][index]:SetAtlas(color_.atlas)
					end

					if(color_.atlasElementName) then
						colors.power[power]:SetAtlas("UI-HUD-UnitFrame-Player-PortraitOn-Bar-" .. color_.atlasElementName)
					end
				end
			end
		end
	end
end

-- fallback integer index to named index
-- sourced from PowerBarColor - Blizzard_UnitFrame/Mainline/PowerBarColorUtil.lua
colors.power[Enum.PowerType.Mana or 0] = colors.power.MANA
colors.power[Enum.PowerType.Rage or 1] = colors.power.RAGE
colors.power[Enum.PowerType.Focus or 2] = colors.power.FOCUS
colors.power[Enum.PowerType.Energy or 3] = colors.power.ENERGY
colors.power[Enum.PowerType.ComboPoints or 4] = colors.power.COMBO_POINTS
colors.power[Enum.PowerType.Runes or 5] = colors.power.RUNES
colors.power[Enum.PowerType.RunicPower or 6] = colors.power.RUNIC_POWER
colors.power[Enum.PowerType.SoulShards or 7] = colors.power.SOUL_SHARDS
colors.power[Enum.PowerType.LunarPower or 8] = colors.power.LUNAR_POWER
colors.power[Enum.PowerType.HolyPower or 9] = colors.power.HOLY_POWER
colors.power[Enum.PowerType.Maelstrom or 11] = colors.power.MAELSTROM
colors.power[Enum.PowerType.Insanity or 13] = colors.power.INSANITY
colors.power[Enum.PowerType.Fury or 17] = colors.power.FURY
colors.power[Enum.PowerType.Pain or 18] = colors.power.PAIN

-- these two don't have fallback values in PowerBarColor, but we want them
colors.power[Enum.PowerType.Chi or 12] = colors.power.CHI
colors.power[Enum.PowerType.ArcaneCharges or 16] = colors.power.ARCANE_CHARGES

-- there's no official colour for evoker's essence
-- use the average colour of the essence texture instead
colors.power.ESSENCE = oUF:CreateColor(100, 173, 206)
colors.power[Enum.PowerType.Essence or 19] = colors.power.ESSENCE

-- alternate power, sourced from Blizzard_UnitFrame/Mainline/CompactUnitFrame.lua
colors.power.ALTERNATE = oUF:CreateColor(0.7, 0.7, 0.6)
colors.power[Enum.PowerType.Alternate or 10] = colors.power.ALTERNATE

if GetThreatStatusColor then
	for i = 0, 3 do
		colors.threat[i] = oUF:CreateColor(GetThreatStatusColor(i))
	end
end

oUF.colors = colors

frame_metatable.__index.colors = colors
