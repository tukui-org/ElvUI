local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function StyleTooltip(frame)
	if not frame then return end

	TT:SetStyle(frame)
end

local function AbilityTooltip(frame)
	if not frame then return end

	frame.Icon:SetTexCoord(unpack(E.TexCoords))
	S:HandleIcon(frame.Icon, true)
	TT:SetStyle(frame)
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
end

function S:GarrisonTooltip()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tooltip then return end

	StyleTooltip(_G.GarrisonFollowerTooltip)
	StyleTooltip(_G.FloatingGarrisonFollowerTooltip)
	StyleTooltip(_G.FloatingGarrisonMissionTooltip)
	StyleTooltip(_G.FloatingGarrisonShipyardFollowerTooltip)
	StyleTooltip(_G.GarrisonShipyardFollowerTooltip)

	AbilityTooltip(_G.GarrisonFollowerAbilityTooltip)
	AbilityTooltip(_G.FloatingGarrisonFollowerAbilityTooltip)
	AbilityTooltip(_G.GarrisonFollowerMissionAbilityWithoutCountersTooltip)
	AbilityTooltip(_G.GarrisonFollowerAbilityWithoutCountersTooltip)

	S:HandleCloseButton(_G.FloatingGarrisonFollowerTooltip.CloseButton)
	S:HandleCloseButton(_G.FloatingGarrisonFollowerAbilityTooltip.CloseButton)
	S:HandleCloseButton(_G.FloatingGarrisonMissionTooltip.CloseButton)
	S:HandleCloseButton(_G.FloatingGarrisonShipyardFollowerTooltip.CloseButton)

	hooksecurefunc('GarrisonFollowerTooltipTemplate_SetGarrisonFollower', function(tooltipFrame)
		-- Abilities
		if tooltipFrame.numAbilitiesStyled == nil then
			tooltipFrame.numAbilitiesStyled = 1
		end

		local numAbilitiesStyled = tooltipFrame.numAbilitiesStyled
		local abilities = tooltipFrame.Abilities
		local ability = abilities[numAbilitiesStyled]
		while ability do
			local icon = ability.Icon
			icon:SetTexCoord(unpack(E.TexCoords))

			if not ability.border then
				ability.border = CreateFrame('Frame', nil, ability)
				S:HandleIcon(ability.Icon, ability.border)
			end

			numAbilitiesStyled = numAbilitiesStyled + 1
			ability = abilities[numAbilitiesStyled]
		end
		tooltipFrame.numAbilitiesStyled = numAbilitiesStyled

		-- Traits
		if tooltipFrame.numTraitsStyled == nil then
			tooltipFrame.numTraitsStyled = 1
		end

		local numTraitsStyled = tooltipFrame.numTraitsStyled
		local traits = tooltipFrame.Traits
		local trait = traits[numTraitsStyled]
		while trait do
			local icon = trait.Icon
			icon:SetTexCoord(unpack(E.TexCoords))

			if not trait.border then
				trait.border = CreateFrame('Frame', nil, trait)
				S:HandleIcon(trait.Icon, trait.border)
			end

			numTraitsStyled = numTraitsStyled + 1
			trait = traits[numTraitsStyled]
		end
		tooltipFrame.numTraitsStyled = numTraitsStyled
	end)

	hooksecurefunc('GarrisonFollowerTooltipTemplate_SetShipyardFollower', function(tooltipFrame)
		if tooltipFrame.numPropertiesStyled == nil then
			tooltipFrame.numPropertiesStyled = 1
		end

		local numPropertiesStyled = tooltipFrame.numPropertiesStyled
		local properties = tooltipFrame.Properties
		local property = properties[numPropertiesStyled]
		while property do
			property.Icon:SetTexCoord(unpack(E.TexCoords))

			if not property.border then
				property.border = CreateFrame('Frame', nil, property)
				S:HandleIcon(property.Icon, property.border)
			end

			numPropertiesStyled = numPropertiesStyled + 1
			property = properties[numPropertiesStyled]
		end

		tooltipFrame.numPropertiesStyled = numPropertiesStyled
	end)
end

S:AddCallback('GarrisonTooltip')
