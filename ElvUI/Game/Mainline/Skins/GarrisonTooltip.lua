local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function AbilityTooltip(frame)
	frame.Icon:SetTexCoords()
	S:HandleIcon(frame.Icon, true)
	TT:SetStyle(frame)
end

local function SetGarrisonFollower(tt)
	-- Abilities
	local numAbilities = tt.numAbilitiesStyled or 1
	local abilities = tt.Abilities
	local ability = abilities[numAbilities]
	while ability do
		ability.Icon:SetTexCoords()

		if not ability.border then
			ability.border = CreateFrame('Frame', nil, ability)
			S:HandleIcon(ability.Icon, ability.border)
		end

		numAbilities = numAbilities + 1
		ability = abilities[numAbilities]
	end
	tt.numAbilitiesStyled = numAbilities

	-- Traits
	local numTraits = tt.numTraitsStyled or 1
	local traits = tt.Traits
	local trait = traits[numTraits]
	while trait do
		trait.Icon:SetTexCoords()

		if not trait.border then
			trait.border = CreateFrame('Frame', nil, trait)
			S:HandleIcon(trait.Icon, trait.border)
		end

		numTraits = numTraits + 1
		trait = traits[numTraits]
	end
	tt.numTraitsStyled = numTraits
end

local function SetShipyardFollower(tt)
	local numProperties = tt.numPropertiesStyled or 1
	local properties = tt.Properties
	local property = properties[numProperties]
	while property do
		property.Icon:SetTexCoords()

		if not property.border then
			property.border = CreateFrame('Frame', nil, property)
			S:HandleIcon(property.Icon, property.border)
		end

		numProperties = numProperties + 1
		property = properties[numProperties]
	end

	tt.numPropertiesStyled = numProperties
end

function S:GarrisonShipyardTooltip()
	local tt = _G.GarrisonShipyardMapMissionTooltip
	TT:SetStyle(tt)

	S:HandleIcon(tt.ItemTooltip.Icon)
	tt.ItemTooltip.IconBorder:SetAlpha(0)
	S:HandleIcon(tt.BonusReward.Icon)

	-- other tooltips
	TT:SetStyle(_G.GarrisonBuildingFrame.BuildingLevelTooltip)
	TT:SetStyle(_G.GarrisonMissionMechanicFollowerCounterTooltip)
	TT:SetStyle(_G.GarrisonMissionMechanicTooltip)
	TT:SetStyle(_G.GarrisonBonusAreaTooltip)
end

function S:GarrisonTooltip()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tooltip then return end

	TT:SetStyle(_G.FloatingGarrisonFollowerTooltip)
	TT:SetStyle(_G.FloatingGarrisonMissionTooltip)
	TT:SetStyle(_G.FloatingGarrisonShipyardFollowerTooltip)
	TT:SetStyle(_G.GarrisonShipyardFollowerTooltip)
	TT:SetStyle(_G.GarrisonFollowerTooltip)

	AbilityTooltip(_G.GarrisonFollowerAbilityTooltip)
	AbilityTooltip(_G.FloatingGarrisonFollowerAbilityTooltip)
	AbilityTooltip(_G.GarrisonFollowerMissionAbilityWithoutCountersTooltip)
	AbilityTooltip(_G.GarrisonFollowerAbilityWithoutCountersTooltip)

	S:HandleCloseButton(_G.FloatingGarrisonFollowerTooltip.CloseButton)
	S:HandleCloseButton(_G.FloatingGarrisonFollowerAbilityTooltip.CloseButton)
	S:HandleCloseButton(_G.FloatingGarrisonMissionTooltip.CloseButton)
	S:HandleCloseButton(_G.FloatingGarrisonShipyardFollowerTooltip.CloseButton)

	hooksecurefunc('GarrisonFollowerTooltipTemplate_SetGarrisonFollower', SetGarrisonFollower)
	hooksecurefunc('GarrisonFollowerTooltipTemplate_SetShipyardFollower', SetShipyardFollower)
end

S:AddCallback('GarrisonTooltip')
