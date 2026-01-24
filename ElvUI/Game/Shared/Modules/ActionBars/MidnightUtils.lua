-- MIDNIGHT: ActionBars defensive aura reading utilities
-- Provides bounded, safe aura field access for button glow and buff checking

local E, L, V, P, G = unpack(ElvUI)
local AB = E:GetModule('ActionBars')
local UF = E:GetModule('UnitFrames')

local select = select
local UNKNOWN = UNKNOWN

-- MIDNIGHT: CYCLE 6 - Bounded buff checking with maxChecks guard
function AB:HasPlayerBuff(spellID, maxChecks)
	if not spellID then return false end
	
	-- Default to 100 checks to avoid runaway loops
	maxChecks = maxChecks or 100
	local checkCount = 0
	
	for i = 1, maxChecks do
		checkCount = checkCount + 1
		
		-- Break if we hit the limit
		if checkCount > maxChecks then
			return false
		end
		
		local aura = select(i, UnitAura('player', i, 'HELPFUL'))
		if not aura then break end -- No more auras
		
		-- Use safe aura data extraction
		local name, icon, count, debuffType, duration, expiration, source, isStealable, _, auraSpellID = E:NotSecretValue(aura) and E:GetSafeAuraData('player', i, 'HELPFUL')
		
		if auraSpellID == spellID and name then
			return true
		end
	end
	
	return false
end

-- MIDNIGHT: CYCLE 6 - Safe duration reads with bounded checks
function AB:GetPlayerBuffDuration(spellID, maxChecks)
	if not spellID then return 0 end
	
	maxChecks = maxChecks or 100
	local checkCount = 0
	
	for i = 1, maxChecks do
		checkCount = checkCount + 1
		
		if checkCount > maxChecks then
			return 0
		end
		
		local aura = select(i, UnitAura('player', i, 'HELPFUL'))
		if not aura then break end
		
		local name, icon, count, debuffType, duration, expiration, source, isStealable, _, auraSpellID = E:NotSecretValue(aura) and E:GetSafeAuraData('player', i, 'HELPFUL')
		
		if auraSpellID == spellID and name then
			return duration or 0
		end
	end
	
	return 0
end

-- MIDNIGHT: CYCLE 6 - Button glow only for non-SECRET auras
function AB:UpdateButtonGlowState(button, unit)
	if not button or not unit then
		if button then
			button:SetGlowEffect(0)
		end
		return
	end
	
	unit = unit or 'player'
	local maxChecks = 100
	local checkCount = 0
	local shouldGlow = false
	
	for i = 1, maxChecks do
		checkCount = checkCount + 1
		
		if checkCount > maxChecks then
			break
		end
		
		local aura = select(i, UnitAura(unit, i, 'HELPFUL'))
		if not aura then break end
		
		local name, icon, count, debuffType, duration, expiration, source, isStealable, _, auraSpellID = E:NotSecretValue(aura) and E:GetSafeAuraData(unit, i, 'HELPFUL')
		
		if not name or name == UNKNOWN or not auraSpellID then
			-- SECRET aura detected - skip glow
			goto continue
		end
		
		-- Check if this is the buff the button represents
		if button.spellID and button.spellID == auraSpellID then
			shouldGlow = true
			break
		end
		
		::continue::
	end
	
	if shouldGlow then
		button:SetGlowEffect()
	else
		button:SetGlowEffect(0)
	end
end
