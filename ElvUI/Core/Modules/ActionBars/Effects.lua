local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')

local wipe = wipe
local pairs = pairs
local ipairs = ipairs
local select = select
local UnitExists = UnitExists
local GetActionInfo = GetActionInfo
local UnitCanAttack = UnitCanAttack
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local ActionButton_HideOverlayGlow = ActionButton_HideOverlayGlow
local ActionButton_ShowOverlayGlow = ActionButton_ShowOverlayGlow

AB.MapSpellIDToButton = {}

local FadeSpeed = 0.75
local config = {
	[980] = { --Agony (spell to look for on actionbar)
		["aura"] = 980, -- aura the unit must have
		["auraType"] = "HARMFUL", -- buff or debuff
		["exists"] = false, -- show effect if aura exists, rather than if it doesn't exist
		["canAttack"] = true, -- only show if you can attack the unit
		["effect"] = "glow", -- blizzardGlow, fade, shake, glow, flash
		["effectColor"] = {r = 1.0, g = 0, b = 0, a = 1,}
	},
	[172] = { --Corruption
		["aura"] = 172,
		["auraType"] = "HARMFUL",
		["exists"] = false,
		["canAttack"] = true,
		["effect"] = "flash",
		["effectColor"] = {r = 1.0, g = 1.0, b = 0, a = 0.45,}
	},
	[316099] = { --Unstable Affliction
		["aura"] = 316099,
		["auraType"] = "HARMFUL",
		["exists"] = false,
		["canAttack"] = true,
		["effect"] = "shake",
		["effectColor"] = {r = 1.0, g = 0, b = 0, a = 1}
	}
}

function AB:MapSpellIDs()
	local SpellID
	wipe(self.MapSpellIDToButton)

	for _, bar in pairs(self.handledBars) do
		for _, button in ipairs(bar.buttons) do
			SpellID = select(2, GetActionInfo(button._state_action)) -- switch this to the lib call on the button

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
			button.shadow:SetBackdropBorderColor(config[button.SpellID].effectColor.r, config[button.SpellID].effectColor.g, config[button.SpellID].effectColor.b, config[button.SpellID].effectColor.a)
			button.flash:SetColorTexture(config[button.SpellID].effectColor.r, config[button.SpellID].effectColor.g, config[button.SpellID].effectColor.b, config[button.SpellID].effectColor.a)
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

function AB:EffectButton(button, stop)
	if stop then
		if config[button.SpellID].effect == "blizzardGlow" then
			ActionButton_HideOverlayGlow(button)
		elseif config[button.SpellID].effect == "fade" then
			E:StopFlash(button)
		elseif config[button.SpellID].effect == "shake" then
			E:StopShake(button)
		elseif config[button.SpellID].effect == "glow" then
			E:StopFlash(button.shadow)
			button.shadow:Hide()
		elseif config[button.SpellID].effect == "flash" then
			E:StopFlash(button.flash)
			button.flash:Hide()
		end
	else
		if config[button.SpellID].effect == "blizzardGlow" then
			ActionButton_ShowOverlayGlow(button)
		elseif config[button.SpellID].effect == "fade" then
			E:Flash(button, FadeSpeed, true)
		elseif config[button.SpellID].effect == "shake" then
			E:Shake(button)
		elseif config[button.SpellID].effect == "glow" then
			button.shadow:Show()
			E:Flash(button.shadow, FadeSpeed, true)
		elseif config[button.SpellID].effect == "flash" then
			button.flash:Show()
			E:Flash(button.flash, FadeSpeed, true)
		end
	end
end

function AB:BUTTON_EVENT(event)
	if event == "UNIT_AURA" or event == "PLAYER_TARGET_CHANGED" then
		local unit = "TARGET"

		if UnitExists(unit) and not UnitIsDeadOrGhost("TARGET") and (config[self.SpellID].canAttack and UnitCanAttack("player", unit) or not config[self.SpellID].canAttack) then
			if E:GetAuraByID(unit, config[self.SpellID].aura, config[self.SpellID].auraType) then
				AB:EffectButton(self, not config[self.SpellID].exists)
			else
				AB:EffectButton(self, config[self.SpellID].exists)
			end
		else
			AB:EffectButton(self, true)
		end
	end
end

function AB:ActionBarEffects()
	for _, bar in pairs(self.handledBars) do
		for _, button in ipairs(bar.buttons) do
			button:HookScript("OnEvent", self.BUTTON_EVENT)

			button:CreateShadow(4)
			button.shadow:Hide()

			button.flash = button:CreateTexture(nil, "OVERLAY")
			button.flash:SetInside()
			button.flash:SetBlendMode("ADD")
			button.flash:Hide()
		end
	end

	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", "MapSpellIDs")

	self:MapSpellIDs()
end
