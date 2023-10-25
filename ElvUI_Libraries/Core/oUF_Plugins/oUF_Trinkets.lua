local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF not loaded')

local factions = {
	Horde = [[Interface\Icons\INV_Jewelry_Necklace_38]],
	Alliance = [[Interface\Icons\INV_Jewelry_Necklace_37]],
	Unknown = [[Interface\Icons\INV_MISC_QUESTIONMARK]]
}

local function GetTrinketIconByFaction(unit)
	local faction = unit and UnitFactionGroup(unit)
	return factions[faction] or factions.Unknown
end

local function UpdateSpell(element, id)
	if id and id ~= 0 and element.spellID ~= id then
		element.spellID = id

		local _, _, spellTexture = GetSpellInfo(id)
		element.icon:SetTexture(spellTexture or factions.Unknown)
	end

end

local function UpdateTrinket(frame, unit)
	local element = frame.Trinket

	local spellID, startTime, duration = C_PvP.GetArenaCrowdControlInfo(unit or frame.unit)
	UpdateSpell(element, spellID)

	if startTime and duration > 0 then
		element.cd:SetCooldown(startTime / 1000, duration / 1000, 1)
		element.cd:Show()
	else
		element.cd:Clear()
		element.cd:Hide()
	end
end

local function ClearCooldowns(frame)
	local element = frame.Trinket

	element.spellID = 0
	element.cd:Clear()
end

local function Update(frame, event, unit, arg2)
	if (frame.isForced and event ~= 'ElvUI_UpdateAllElements') or (unit and frame.unit ~= unit) then return end

	local element = frame.Trinket
	if frame.isForced then
		element.icon:SetTexture(GetTrinketIconByFaction('player'))
		element:Show()

		return
	end

	if (element.PreUpdate) then
		element:PreUpdate(event, unit)
	end

	if event == 'OnShow' or (event == 'ARENA_OPPONENT_UPDATE' and arg2 == 'seen') then -- arg2: updateReason
		C_PvP.RequestCrowdControlSpell(unit)
	elseif event == 'ARENA_COOLDOWNS_UPDATE' then
		UpdateTrinket(frame, unit)
	elseif event == 'ARENA_CROWD_CONTROL_SPELL_UPDATE' then
		UpdateSpell(element, arg2) -- arg2: spellID
	end

	element:SetShown(element.spellID and element.spellID ~= 0)

	if (element.PostUpdate) then
		element:PostUpdate(event, unit)
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(frame)
	local element = frame.Trinket
	if element then
		element.__owner = frame
		element.ForceUpdate = ForceUpdate
		element.Factions = factions

		frame:RegisterEvent('ARENA_OPPONENT_UPDATE', Update)
		frame:RegisterEvent('ARENA_COOLDOWNS_UPDATE', Update, true)
		frame:RegisterEvent('ARENA_CROWD_CONTROL_SPELL_UPDATE', Update, true)

		if oUF.isRetail then
			frame:RegisterEvent('PVP_MATCH_INACTIVE', ClearCooldowns, true)
		end

		return true
	end
end

local function Disable(frame)
	local element = frame.Trinket
	if element then
		frame:UnregisterEvent('ARENA_OPPONENT_UPDATE', Update)
		frame:UnregisterEvent('ARENA_COOLDOWNS_UPDATE', Update)
		frame:UnregisterEvent('ARENA_CROWD_CONTROL_SPELL_UPDATE', Update)

		if oUF.isRetail then
			frame:UnregisterEvent('PVP_MATCH_INACTIVE', ClearCooldowns)
		end

		element:Hide()
	end
end

oUF:AddElement('Trinket', Update, Enable, Disable)
