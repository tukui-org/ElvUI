local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF not loaded')

local function GetTrinketIconBySpellID(spellID)
	local _, _, spellTexture = GetSpellInfo(spellID)
	return spellTexture
end

local function GetTrinketIconByFaction(unit)
	if UnitFactionGroup(unit) == "Horde" then
		return [[Interface\Icons\INV_Jewelry_Necklace_38]]
	elseif UnitFactionGroup(unit) == "Alliance" then
		return [[Interface\Icons\INV_Jewelry_Necklace_37]]
	else
		return [[Interface\Icons\INV_MISC_QUESTIONMARK]]
	end
end

local function UpdateSpell(element, id)
	if id and id ~= 0 and element.spellID ~= id then
		element.spellID = id
		element.icon:SetTexture(GetTrinketIconBySpellID(id))
	end

end

local function UpdateTrinket(self, unit)
	local element = self.Trinket

	local spellID, startTime, duration = C_PvP.GetArenaCrowdControlInfo(unit or self.unit)
	UpdateSpell(element, spellID)

	if startTime and duration > 0 then
		element.cd:SetCooldown(startTime / 1000, duration / 1000, 1)
		element.cd:Show()
	else
		element.cd:Clear()
		element.cd:Hide()
	end
end

local function ClearCooldowns(self)
	local element = self.Trinket

	element.spellID = 0
	element.cd:Clear()
end

local function Update(self, event, unit, ...)
	if (self.isForced and event ~= 'ElvUI_UpdateAllElements') or (unit and self.unit ~= unit) then return end

	local element = self.Trinket
	if self.isForced then
		element.icon:SetTexture(GetTrinketIconByFaction("player"))
		element:Show()

		return;
	end

	if (element.PreUpdate) then
		element:PreUpdate(event, unit)
	end

	if (event == "ARENA_OPPONENT_UPDATE" or event == "OnShow") then
		local unitEvent = ...
		if (unitEvent ~= "seen" and event ~= "OnShow") then return end

		C_PvP.RequestCrowdControlSpell(unit)
	elseif event == "ARENA_COOLDOWNS_UPDATE" then
		UpdateTrinket(self, unit)
	elseif event == "ARENA_CROWD_CONTROL_SPELL_UPDATE" then
		local spellID = ...
		UpdateSpell(element, spellID)
	end

	element:SetShown(element.spellID and element.spellID ~= 0)

	if (element.PostUpdate) then
		element:PostUpdate(event, unit)
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.Trinket
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent("ARENA_COOLDOWNS_UPDATE", Update, true)
		self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE", Update, true)
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", Update, true)

		if oUF.isRetail then
			self:RegisterEvent("PVP_MATCH_INACTIVE", ClearCooldowns, true)
		end

		return true
	end
end

local function Disable(self)
	local element = self.Trinket
	if element then
		self:UnregisterEvent("ARENA_COOLDOWNS_UPDATE", Update)
		self:UnregisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE", Update)
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE", Update)

		if oUF.isRetail then
			self:UnregisterEvent("PVP_MATCH_INACTIVE", ClearCooldowns)
		end

		element:Hide()
	end
end

oUF:AddElement('Trinket', Update, Enable, Disable)
