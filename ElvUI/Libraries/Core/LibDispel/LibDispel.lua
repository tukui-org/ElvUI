local MAJOR, MINOR = "LibDispel-1.0", 1
assert(LibStub, MAJOR.." requires LibStub")
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local Wrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local next = next
local GetCVar, SetCVar = GetCVar, SetCVar
local IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown

local DispelList = {}
lib.DispelList = DispelList

function lib:GetMyDispelTypes()
	return DispelList
end

function lib:IsDispellableByMe(debuffType)
	return DispelList[debuffType]
end

do
	local _, myClass = UnitClass("player")
	local WarlockPetSpells = {
		[89808] = 'Singe',
		[19505] = 'Devour Magic Rank 1',
		[19731] = 'Devour Magic Rank 2',
		[19734] = 'Devour Magic Rank 3',
		[19736] = 'Devour Magic Rank 4',
		[27276] = 'Devour Magic Rank 5',
		[27277] = 'Devour Magic Rank 6'
	}

	local function CheckSpell(spellID, pet)
		return IsSpellKnownOrOverridesKnown(spellID, pet) and true or nil
	end

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

	local function UpdateDispels(_, event, arg1)
		if event == 'CHARACTER_POINTS_CHANGED' and arg1 > 0 then
			return -- Not interested in gained points from leveling
		end

		-- this will fix a problem where spells dont show as existing because they are 'hidden'
		local undoRanks = Wrath and GetCVar('ShowAllSpellRanks') ~= '1' and SetCVar('ShowAllSpellRanks', 1)

		if event == 'UNIT_PET' then
			DispelList.Magic = CheckPetSpells()
		elseif myClass == 'DRUID' then
			local cure = Retail and CheckSpell(88423) -- Nature's Cure
			local corruption = CheckSpell(2782) -- Remove Corruption (retail), Curse (classic)
			DispelList.Magic = cure
			DispelList.Curse = cure or corruption
			DispelList.Poison = cure or (Retail and corruption) or CheckSpell(2893) or CheckSpell(8946) -- Abolish Poison / Cure Poison
		elseif myClass == 'MAGE' then
			DispelList.Curse = CheckSpell(475) -- Remove Curse
		elseif myClass == 'MONK' then
			local mwDetox = CheckSpell(115450) -- Detox (Mistweaver)
			local detox = mwDetox or CheckSpell(218164) -- Detox (Brewmaster or Windwalker)
			DispelList.Magic = mwDetox
			DispelList.Disease = detox
			DispelList.Poison = detox
		elseif myClass == 'PALADIN' then
			local cleanse = CheckSpell(4987) -- Cleanse
			local purify = CheckSpell(1152) -- Purify
			local toxins = cleanse or purify or CheckSpell(213644) -- Cleanse Toxins
			DispelList.Magic = cleanse
			DispelList.Poison = toxins
			DispelList.Disease = toxins
		elseif myClass == 'PRIEST' then
			local dispel = CheckSpell(527) -- Dispel Magic
			DispelList.Magic = dispel or CheckSpell(32375)
			DispelList.Disease = Retail and (dispel or CheckSpell(213634)) or not Retail and (CheckSpell(552) or CheckSpell(528)) -- Purify Disease / Abolish Disease / Cure Disease
		elseif myClass == 'SHAMAN' then
			local purify = Retail and CheckSpell(77130) -- Purify Spirit
			local cleanse = purify or CheckSpell(51886) -- Cleanse Spirit
			local toxins = CheckSpell(526)

			DispelList.Magic = purify
			DispelList.Curse = cleanse
			DispelList.Poison = not Retail and (cleanse or toxins)
			DispelList.Disease = not Retail and (cleanse or toxins)
		end

		if undoRanks then
			SetCVar('ShowAllSpellRanks', 0)
		end
	end

	local frame = CreateFrame('Frame')
	frame:SetScript('OnEvent', UpdateDispels)
	frame:RegisterEvent('CHARACTER_POINTS_CHANGED')
	frame:RegisterEvent('PLAYER_LOGIN')

	if myClass == 'WARLOCK' then
		frame:RegisterUnitEvent('UNIT_PET', 'player')
	end

	if Retail or Wrath then
		frame:RegisterEvent('PLAYER_TALENT_UPDATE')
	end

	if Retail then
		frame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
	end
end
