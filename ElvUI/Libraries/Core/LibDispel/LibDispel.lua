local MAJOR, MINOR = "LibDispel-1.0", 1
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local next = next
local GetSpecialization = GetSpecialization
local GetSpecializationRole = GetSpecializationRole
local IsSpellKnown = IsSpellKnown

local _, myClass = UnitClass("player")

local DispelClasses = {}
lib.DispelClasses = DispelClasses

for _, classTag in next, {'DRUID', 'HUNTER', 'MAGE' , 'PALADIN', 'PRIEST', 'ROGUE', 'SHAMAN', 'WARLOCK', 'WARRIOR', 'DEATHKNIGHT', 'MONK', 'DEMONHUNTER'} do
	DispelClasses[classTag] = {}
end

local function CheckSpell(spellID, pet)
	return IsSpellKnown(spellID, pet) and true or nil
end

function lib:GetMyDispelTypes()
	return DispelClasses[myClass]
end

do
	local WarlockPetSpells = {
		[89808] = 'Singe',
		[212623] = 'Singe (PvP)',
		[19505] = 'Devour Magic Rank 1',
		[19731] = 'Devour Magic Rank 2',
		[19734] = 'Devour Magic Rank 3',
		[19736] = 'Devour Magic Rank 4',
		[27276] = 'Devour Magic Rank 5',
		[27277] = 'Devour Magic Rank 6'
	}

	local ExcludeClass = {
		PRIEST = true, -- has Mass Dispel on Shadow
		WARLOCK = true, -- uses PET check only
	}

	local function CheckPetSpells()
		if Retail then
			return CheckSpell(89808, true)
		else
			for spellID in next, WarlockPetSpells do
				if CheckSpell(spellID, true) then
					return true
				end
			end
		end
	end

	local function UpdateDispelClasses(event, arg1)
		local dispel = DispelClasses[myClass]

		if event == 'UNIT_PET' then
			dispel.Magic = CheckPetSpells()
		elseif event == 'CHARACTER_POINTS_CHANGED' and arg1 > 0 then
			return -- Not interested in gained points from leveling
		else
			if myClass == 'DRUID' then
				local cure = CheckSpell(88423) -- Nature's Cure
				local corruption = cure or CheckSpell(2782) -- Remove Corruption
				dispel.Magic = cure
				dispel.Curse = corruption
				dispel.Poison = corruption
			elseif myClass == 'PALADIN' then
				local cleanse = CheckSpell(4987) -- Cleanse
				local toxins = cleanse or CheckSpell(213644) -- Cleanse Toxins
				dispel.Magic = cleanse
				dispel.Poison = toxins
				dispel.Disease = toxins
			elseif myClass == 'PRIEST' then
				local purify = CheckSpell(527) -- Purify
				dispel.Magic = purify
				dispel.Disease = purify or CheckSpell(213634) -- Purify Disease
			elseif myClass == 'SHAMAN' then
				local purify = CheckSpell(77130) -- Purify Spirit
				local cleanse = purify or CheckSpell(51886) -- Cleanse Spirit

				dispel.Curse = cleanse
				dispel.Poison = not Retail and cleanse
				dispel.Disease = not Retail and cleanse
			end

			if Retail then
				if myClass == 'DEMONHUNTER' then
					dispel.Magic = CheckSpell(205604) -- Reverse Magic (PvP)
				elseif myClass == 'HUNTER' then
					local mendingBandage = CheckSpell(212640) -- Mending Bandage (PvP)
					dispel.Disease = mendingBandage
					dispel.Poison = mendingBandage
				elseif myClass == 'MONK' then
					local mwDetox = CheckSpell(115450) -- Detox (Mistweaver)
					local detox = mwDetox or CheckSpell(218164) -- Detox (Brewmaster or Windwalker)
					dispel.Magic = mwDetox
					dispel.Disease = detox
					dispel.Poison = detox
				end

				local role = GetSpecializationRole(GetSpecialization())
				if role and not ExcludeClass[myClass] then
					dispel.Magic = (role == 'HEALER')
				end
			end
		end
	end

	local frame = CreateFrame('Frame')
	frame:SetScript('OnEvent', UpdateDispelClasses)

	if myClass == 'WARLOCK' then
		frame:RegisterUnitEvent('UNIT_PET', 'player')
	end

	frame:RegisterEvent('CHARACTER_POINTS_CHANGED')
	frame:RegisterEvent('PLAYER_LOGIN')

	if Retail or Wrath then
		frame:RegisterEvent('PLAYER_TALENT_UPDATE')
	end

	if Retail then
		frame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
	end
end
