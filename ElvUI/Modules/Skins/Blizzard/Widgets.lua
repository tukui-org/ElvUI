local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local AtlasColors = {
	["UI-Frame-Bar-Fill-Blue"] = {.2, .6, 1},
	["UI-Frame-Bar-Fill-Red"] = {.9, .2, .2},
	["UI-Frame-Bar-Fill-Yellow"] = {1, .6, 0},
	["objectivewidget-bar-fill-left"] = {.2, .6, 1},
	["objectivewidget-bar-fill-right"] = {.9, .2, .2}
}

local function UpdateBarTexture(bar, atlas)
	if AtlasColors[atlas] then
		bar:SetStatusBarTexture(E.media.normTex)
		bar:SetStatusBarColor(unpack(AtlasColors[atlas]))
	end
end

function S:Widgets()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.widgets) then return end

	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, 'Setup', function(self)
		local bar = self.Bar
		local atlas = bar:GetStatusBarAtlas()
		UpdateBarTexture(bar, atlas)

		if not bar.IsSkinned then
			bar.BGLeft:SetAlpha(0)
			bar.BGRight:SetAlpha(0)
			bar.BGCenter:SetAlpha(0)
			bar.BorderLeft:SetAlpha(0)
			bar.BorderRight:SetAlpha(0)
			bar.BorderCenter:SetAlpha(0)
			bar.Spark:SetAlpha(0)
			bar:CreateBackdrop('Transparent')

			bar.IsSkinned = true
		end
	end)
end

S:AddCallback('Widgets')
