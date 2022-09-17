local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

function UF.FilterList_Defaults(priority)
	return {
		enable = true,
		priority = priority or 0,
		stackThreshold = 0
	}
end

-- Profile specific BuffIndicator
P.unitframe.filters = {
	aurawatch = {},
}

G.unitframe.aurafilters = {}

G.unitframe.specialFilters = {
	-- Whitelists
	Boss = true,
	MyPet = true,
	OtherPet = true,
	Personal = true,
	nonPersonal = true,
	CastByUnit = true,
	notCastByUnit = true,
	Dispellable = true,
	notDispellable = true,
	CastByNPC = true,
	CastByPlayers = true,
	BlizzardNameplate = true,

	-- Blacklists
	blockNonPersonal = true,
	blockCastByPlayers = true,
	blockNoDuration = true,
	blockDispellable = true,
	blockNotDispellable = true,
}
