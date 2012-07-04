local E, L, V, P, G = unpack(select(2, ...)); --Engine

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id) 	
	if not name then
		print('|cff1784d1ElvUI:|r SpellID is not valid: '..id..'. Please check for an updated version, if none exists report to ElvUI author.')
		return 'Impale'
	else
		return name
	end
end

G['classtimer'] = {
	[SpellName(2825)] = true, -- Bloodlust
	[SpellName(32182)] = true, -- Heroism
};