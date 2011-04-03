----------------------------------------------------------------------------
-- This Module loads new user settings if ElvUI_ConfigUI is loaded
----------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local myPlayerRealm = GetCVar("realmName")
local myPlayerName  = UnitName("player")


for group,options in pairs(DB) do
	if not C[group] then C[group] = {} end
	for option, value in pairs(options) do
		C[group][option] = value
	end
end


if IsAddOnLoaded("ElvUI_Config") and ElvConfig then
	local profile = ElvConfig["profileKeys"][myPlayerName.." - "..myPlayerRealm]
	local path = ElvConfig["profiles"][profile]
	if path then
		for group,options in pairs(path) do
			if C[group] then
				for option, value in pairs(options) do
					if C[group][option] ~= nil then
						C[group][option] = value
					end
				end
			end
		end
	end
	
	--Raid Debuffs
	do
		local list = E.RaidDebuffs
		E.RaidDebuffsList = {}
		for spell, value in pairs(list) do
			if value == true then
				tinsert(E.RaidDebuffsList, spell)
			end
		end
		
		if path and path["spellfilter"] and path["spellfilter"]["RaidDebuffs"] then
			for spell, value in pairs(path["spellfilter"]["RaidDebuffs"]) do
				if value == true then
					tinsert(E.RaidDebuffsList, spell)
				end			
			end
		end
	end
	
	--Debuff Blacklist
	do
		local list = E.DebuffBlacklist
		if path and path["spellfilter"] and path["spellfilter"]["DebuffBlacklist"] then
			for spell, value in pairs(path["spellfilter"]["DebuffBlacklist"]) do
				E.DebuffBlacklist[spell] = value			
			end
		end	
	end
	
	--Target PVP Only
	do
		local list = E.TargetPVPOnly
		if path and path["spellfilter"] and path["spellfilter"]["TargetPVPOnly"] then
			for spell, value in pairs(path["spellfilter"]["TargetPVPOnly"]) do
				E.TargetPVPOnly[spell] = value			
			end
		end		
	end
	
	--DebuffWhiteList
	do
		local list = E.DebuffWhiteList
		if path and path["spellfilter"] and path["spellfilter"]["DebuffWhiteList"] then
			for spell, value in pairs(path["spellfilter"]["DebuffWhiteList"]) do
				E.DebuffWhiteList[spell] = value			
			end
		end			
	end
	
	--ArenaBuffs
	do
		local list = E.ArenaBuffWhiteList
		if path and path["spellfilter"] and path["spellfilter"]["ArenaBuffWhiteList"] then
			for spell, value in pairs(path["spellfilter"]["ArenaBuffWhiteList"]) do
				E.ArenaBuffWhiteList[spell] = value			
			end
		end			
	end
	
	--Nameplate Filter
	do
		local list = E.PlateBlacklist
		if path and path["spellfilter"] and path["spellfilter"]["PlateBlacklist"] then
			for name, value in pairs(path["spellfilter"]["PlateBlacklist"]) do
				E.PlateBlacklist[name] = value			
			end
		end	
	end
end




