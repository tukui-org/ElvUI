local MAJOR, MINOR = 'LibClassicSpecs-ElvUI', 1001
local LCS = LibStub:NewLibrary(MAJOR, MINOR)

if not LCS then
	return
end

local select = select

local UnitClass = UnitClass
local GetNumTalentTabs = GetNumTalentTabs
local GetTalentTabInfo = GetTalentTabInfo
local GetTalentInfo = GetTalentInfo

local DRUID_FERAL_TAB = 2
local DRUID_FERAL_INSTINCT = 3
local DRUID_THICK_HIDE = 5
local DRUID_GUARDIAN_SPEC_INDEX = 3
local DRUID_RESTO_SPEC_INDEX = 4

LCS.MAX_TALENT_TIERS = 7
LCS.NUM_TALENT_COLUMNS = 4

local ClassByID = {
	{ name = 'WARRIOR', specs = { 71, 72, 73 } },
	{ name = 'PALADIN', specs = { 65, 66, 70 } },
	{ name = 'HUNTER', specs = { 253, 254, 255 } },
	{ name = 'ROGUE', specs = { 259, 260, 261 } },
	{ name = 'PRIEST', specs = { 256, 257, 258 } },
	{ name = 'DEATHKNIGHT', specs = { 250, 251, 252 } },
	{ name = 'SHAMAN', specs = { 262, 263, 264 } },
	{ name = 'MAGE', specs = { 62, 63, 64 } },
	{ name = 'WARLOCK', specs = { 265, 266, 267 } },
	{ name = 'MONK', specs = { 268, 269, 270 } },
	{ name = 'DRUID', specs = { 102, 103, 104, 105 } },
	{ name = 'DEMONHUNTER', specs = { 577, 581 } },
}

for _, classInfo in pairs(ClassByID) do classInfo.displayName = LOCALIZED_CLASS_NAMES_MALE[classInfo.name] end

-- Expansions
local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isTBC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local isWrath = false

local Stat = { Strength = 1, Agility = 2, Stamina = 3, Intellect = 4, Spirit = 5 }
local Role = { Damager = 'DAMAGER', Tank = 'TANK', Healer = 'HEALER' }

local ClassID = select(3, UnitClass('player'))

-- Detailed info for each spec
local SpecInfo = {
	[71] = { -- Warrior: Arms
		name = 'Arms',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = false,
		primaryStat = Stat.Strength
	},
	[72] = { -- Warrior:  Fury
		name = 'Fury',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Strength
	},
	[73] = { -- Warrior: Protection
		name = 'Protection',
		description = '',
		icon = '',
		background = '',
		role = Role.Tank,
		isRecommended = false,
		primaryStat = Stat.Strength
	},
	[65] = { -- Paladin: Holy
		name = 'Holy',
		description = '',
		icon = '',
		background = '',
		role = Role.Healer,
		isRecommended = false,
		primaryStat = Stat.Intellect
	},
	[66] = { -- Paladin: Protection
		name = 'Protection',
		description = '',
		icon = '',
		background = '',
		role = Role.Tank,
		isRecommended = false,
		primaryStat = Stat.Strength
	},
	[70] = { -- Paladin: Retribution
		name = 'Retribution',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Strength
	},
	[253] = { -- Hunter: Beast Mastery
		name = 'Beast Mastery',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Agility
	},
	[254] = { -- Hunter: Marksman
		name = 'Marksman',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Agility
	},
	[255] = { -- Hunter: Survival
		name = 'Survival',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = false,
		primaryStat = Stat.Agility
	},
	[259] = { -- Rogue: Assassination
		name = 'assassination',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Agility
	},
	[260] = { -- Rogue: Combat
		name = 'Combat',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Agility
	},
	[261] = { -- Rogue: Sublety
		name = 'Subtlety',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = false,
		primaryStat = Stat.Agility
	},
	[256] = { -- Priest: Discipline
		name = 'Discipline',
		description = '',
		icon = '',
		background = '',
		role = Role.Healer,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[257] = { -- Priest: Holy
		name = 'Holy',
		description = '',
		icon = '',
		background = '',
		role = Role.Healer,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[258] = { -- Priest: Shadow
		name = 'Shadow',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = false,
		primaryStat = Stat.Intellect
	},
	[262] = { -- Shaman: Elemental
		name = 'Elemental',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[263] = { -- Shaman: Enhancement
		name = 'Enhancement',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Strength
	},
	[264] = { -- Shaman: Restoration
		name = 'Restoration',
		description = '',
		icon = '',
		background = '',
		role = Role.Healer,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[62] = { -- Mage: Arcane
		name = 'Arcane',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = false,
		primaryStat = Stat.Intellect
	},
	[63] = { -- Mage: Fire
		name = 'Fire',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[64] = { -- Mage: Frost
		name = 'Frost',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[265] = { -- Warlock: Affliction
		name = 'Affliction',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = false,
		primaryStat = Stat.Intellect
	},
	[266] = { -- Warlock: Demonology
		name = 'Demonology',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[267] = { -- Warlock: Destruction
		name = 'Destruction',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = false,
		primaryStat = Stat.Intellect
	},
	[102] = { -- Druid: Balance
		name = 'Balance',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[103] = { -- Druid: Feral
		name = 'Feral',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Strength
	},
	[104] = { -- Druid: Guardian
		name = 'Guardian',
		description = '',
		icon = '',
		background = '',
		role = Role.Tank,
		isRecommended = true,
		primaryStat = Stat.Strength
	},
	[105] = { -- Druid: Restoration
		name = 'Restoration',
		description = '',
		icon = '',
		background = '',
		role = Role.Healer,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[251] = { -- Death Knight: Frost
		name = 'Frost',
		description = '',
		icon = '',
		background = '',
		role = Role.Tank,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[250] = { -- Death Knight: Blood
		name = 'Blood',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[252] = { -- Death Knight: Unholy
		name = 'Unholy',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[577] = { -- Demon Hunter: Havoc
		name = 'Havoc',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[581] = { -- Demon Hunter: Vengence
		name = 'Vengeance',
		description = '',
		icon = '',
		background = '',
		role = Role.Tank,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[268] = { -- Monk: Brewmaster
		name = 'Brewmaster',
		description = '',
		icon = '',
		background = '',
		role = Role.Tank,
		isRecommended = true,
		primaryStat = Stat.Agility
	},
	[270] = { -- Monk: Mistweaver
		name = 'Mistweaver',
		description = '',
		icon = '',
		background = '',
		role = Role.Healer,
		isRecommended = true,
		primaryStat = Stat.Intellect
	},
	[269] = { -- Monk: Windwalker
		name = 'Windwalker',
		description = '',
		icon = '',
		background = '',
		role = Role.Damager,
		isRecommended = true,
		primaryStat = Stat.Agility
	}
}

LCS.Stat = Stat
LCS.Role = Role
LCS.SpecInfo = SpecInfo

function LCS.GetClassInfo(classId)
	local info = ClassByID[classId]
	if not info then
		return
	end

	return info.displayName, info.name, classId
end

function LCS.GetNumSpecializationsForClassID(classId)
	if (classId <= 0 or classId > LCS:GetNumClasses()) then
		return
	end

	return #ClassByID[classId].specs
end

function LCS.GetInspectSpecialization() return end

function LCS.GetActiveSpecGroup() return 1 end

function LCS.GetSpecialization(isInspect, isPet)
	if (isInspect or isPet) then
		return
	end

	local specIndex, maxSpent = 0, 0

	for tabIndex = 1, GetNumTalentTabs() do
		local spent = select(3, GetTalentTabInfo(tabIndex))
		if (spent > maxSpent) then
			specIndex, maxSpent = tabIndex, spent
		end
	end

	if (ClassID == 11) then -- Druid
		local feralInstinctPoints = select(5, GetTalentInfo(DRUID_FERAL_TAB, DRUID_FERAL_INSTINCT))
		local thickHidePoints = select(5, GetTalentInfo(DRUID_FERAL_TAB, DRUID_THICK_HIDE))

		if (feralInstinctPoints >= 2 or thickHidePoints >= 2) then
			return DRUID_GUARDIAN_SPEC_INDEX
		end

		-- return 4 if Resto (3rd tab has most points), because Guardian is 3
		if (specIndex == DRUID_GUARDIAN_SPEC_INDEX) then
			return DRUID_RESTO_SPEC_INDEX
		end
	end

	return specIndex
end

function LCS.GetSpecializationInfo(specIndex, isInspect, isPet)
	if (isInspect or isPet) then
		return
	end

	local specId = ClassByID[ClassID].specs[specIndex]
	local spec = SpecInfo[specId]

	if not spec then
		return
	end

	return specId, spec.name, spec.description, spec.icon, spec.background, spec.role, spec.primaryStat
end

function LCS.GetSpecializationInfoForClassID(classId, specIndex)
	local classInfo = ClassByID[classId]

	if not classInfo then
		return
	end

	local specId = classInfo.specs[specIndex]
	local info = SpecInfo[specId]

	if not info then
		return
	end

	local isAllowed = classId == ClassID

	return specId, info.name, info.description, info.icon, info.role, info.isRecommended, isAllowed
end

function LCS.GetSpecializationRoleByID(specId)
	return SpecInfo[specId] and SpecInfo[specId].role
end

function LCS.GetSpecializationRole(specIndex, isInspect, isPet)
	if (isInspect or isPet) then
		return
	end

	local specId = ClassByID[ClassID].specs[specIndex]
	return SpecInfo[specId] and SpecInfo[specId].role
end

function LCS.GetNumClasses()
	return #ClassByID
end
