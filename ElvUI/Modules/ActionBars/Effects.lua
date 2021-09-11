local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule('ActionBars')

local twipe = table.wipe
AB.MapSpellIDToButton = {}

local config = {
	--[[[980] = { --Agony (spell to look for on actionbar)
		["aura"] = 980, -- aura the unit must have
		["auraType"] = "HARMFUL", -- buff or debuff
		["exists"] = false, -- show effect if aura exists, rather than if it doesn't exist
		["canAttack"] = true, -- only show if you can attack the unit
	},
	[172] = { --Corruption
		["aura"] = 172,
		["auraType"] = "HARMFUL",
		["exists"] = false,
		["canAttack"] = true,
	},
	[316099] = { --Unstable Affliction
		["aura"] = 316099,
		["auraType"] = "HARMFUL",
		["exists"] = false,
		["canAttack"] = true,
	},]]	
}

function AB:MapSpellIDs(event, action)
	local SpellID
	twipe(self.MapSpellIDToButton)
	for _, bar in pairs(self.handledBars) do
		for _, button in ipairs(bar.buttons) do
			SpellID = select(2, GetActionInfo(button._state_action))
			if SpellID then
				self.MapSpellIDToButton[SpellID] = button
				self:RegisterUnitEvents(SpellID, button)
			elseif button.SpellID then
				button:UnregisterEvent("UNIT_AURA")
				button:UnregisterEvent("PLAYER_TARGET_CHANGED")
				button.SpellID = nil
			end
		end
	end
end

function AB:RegisterUnitEvents(SpellID, button)
	if button and SpellID then
		if config[SpellID] then
			button:RegisterUnitEvent("UNIT_AURA", "TARGET")
			button:RegisterEvent("PLAYER_TARGET_CHANGED")
			button.SpellID = SpellID
		end
	else
		for SpellID, button in pairs(self.MapSpellIDToButton) do
			if config[SpellID] then
				button:RegisterUnitEvent("UNIT_AURA", "TARGET")
				button:RegisterEvent("PLAYER_TARGET_CHANGED")
				button.SpellID = SpellID
			end
		end
	end
end

function AB:BUTTON_EVENT(event)
	if event == "UNIT_AURA" or event == "PLAYER_TARGET_CHANGED" then
		local unit = "TARGET"

		if UnitExists(unit) and not UnitIsDeadOrGhost("TARGET") and (config[self.SpellID].canAttack and UnitCanAttack("player", unit) or not config[self.SpellID].canAttack) then
			local name = GetSpellInfo(config[self.SpellID].aura)

			if AuraUtil.FindAuraByName(name, unit, config[self.SpellID].auraType) then
				if config[self.SpellID].exists then
					ActionButton_ShowOverlayGlow(self)
				else
					ActionButton_HideOverlayGlow(self)
				end
			else
				if config[self.SpellID].exists then
					ActionButton_HideOverlayGlow(self)
				else
					ActionButton_ShowOverlayGlow(self)
				end
			end
		else
			ActionButton_HideOverlayGlow(self)
		end
	end
end



function AB:ActionBarEffects()
	for _, bar in pairs(self.handledBars) do
		for _, button in ipairs(bar.buttons) do
			button:HookScript("OnEvent", self.BUTTON_EVENT)
		end
	end

	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", "MapSpellIDs")

	self:MapSpellIDs()
end