local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function StyleTooltip(frame)
	if not frame then return end

	TT:SetStyle(frame)
end

local function AbilityTooltip(frame)
	if not frame then return end

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

	local reward = tt.ItemTooltip
	local icon = reward and reward.Icon
	if icon then
		S:HandleIcon(icon)

		if reward.IconBorder then
			reward.IconBorder:SetAlpha(0)
		end
	end

	local bonusIcon = tt.BonusReward and tt.BonusReward.Icon
	if bonusIcon then
		S:HandleIcon(bonusIcon)
	end

	-- other tooltips
	StyleTooltip(_G.GarrisonBuildingFrame and _G.GarrisonBuildingFrame.BuildingLevelTooltip)
	StyleTooltip(_G.GarrisonMissionMechanicFollowerCounterTooltip)
	StyleTooltip(_G.GarrisonMissionMechanicTooltip)
	StyleTooltip(_G.GarrisonBonusAreaTooltip)
end

function S:GarrisonTooltip()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tooltip then return end

	StyleTooltip(_G.FloatingGarrisonFollowerTooltip)
	StyleTooltip(_G.FloatingGarrisonMissionTooltip)
	StyleTooltip(_G.FloatingGarrisonShipyardFollowerTooltip)
	StyleTooltip(_G.GarrisonShipyardFollowerTooltip)
	StyleTooltip(_G.GarrisonFollowerTooltip)

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
