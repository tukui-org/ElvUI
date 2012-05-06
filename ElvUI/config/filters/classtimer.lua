local E, L, V, P, G = unpack(select(2, ...)); --Engine

local function CreateSpellEntry(id, castByAnyone, color, unitType, castSpellId)
	return { enabled = true, id = id, castByAnyone = castByAnyone, color = color, unitType = unitType or 0, castSpellId = castSpellId };
end

G['classtimer']['trinkets_filter'] = {

}

G['classtimer']['spells_filter'] = {
	MONK = { 
		target = { 

		},
		player = {

		},
		procs = {

		},
	},
	DEATHKNIGHT = { 
		target = {

		},
		player = {
	
		},
		procs = {

		},
	},
	DRUID = { 
		target = { 

		},
		player = {

		},
		procs = {

		},
	},
	HUNTER = { 
		target = {

		},
		player = {

		},
		procs = {

		},
	},
	MAGE = {
		target = { 

		},
		player = {

		},
		procs = {

		},
	},
	PALADIN = { 
		target = {

		},
		player = {

		},
		procs = {

		},
	},
	PRIEST = { 
		target = { 

		},
		player = {
		
		},
		procs = {
		
		},
	},
	ROGUE = { 
		target = { 

		},
		player = {

		},
		procs = {

		},
	},
	SHAMAN = {
		target = {

		},
		player = {

		},
		procs = {
	
		},
	},
	WARLOCK = {
		target = {

		},
		player = {

		},
		procs = {

		},
	},
	WARRIOR = { 
		target = {

		},
		player = {

		},
		procs = {

		},
	},
};