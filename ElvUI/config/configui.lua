----------------------------------------------------------------------------
-- This Module loads new user settings if ElvUI_ConfigUI is loaded
----------------------------------------------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--Convert default database
for group,options in pairs(DB) do
	if not C[group] then C[group] = {} end
	for option, value in pairs(options) do
		C[group][option] = value
	end
end

if IsAddOnLoaded("ElvUI_Config") then
	local ElvuiConfig = LibStub("AceAddon-3.0"):GetAddon("ElvuiConfig")
	ElvuiConfig:Load()

	--Load settings from ElvuiConfig database
	for group, options in pairs(ElvuiConfig.db.profile) do
		if C[group] then
			for option, value in pairs(options) do
				C[group][option] = value
			end
		end
	end
	
	--Load other lists from ElvuiConfig
		--Raid Debuffs
		E.RaidDebuffs = ElvuiConfig.db.profile.spellfilter.RaidDebuffs
		
		--Debuff Blacklist
		E.DebuffBlacklist = ElvuiConfig.db.profile.spellfilter.DebuffBlacklist
		
		--Target PvP
		E.TargetPVPOnly = ElvuiConfig.db.profile.spellfilter.TargetPVPOnly
		
		--Debuff Whitelist
		E.DebuffWhiteList = ElvuiConfig.db.profile.spellfilter.DebuffWhiteList
		
		--Arena Buffs
		E.ArenaBuffWhiteList = ElvuiConfig.db.profile.spellfilter.ArenaBuffWhiteList
		
		--Nameplate Filter
		E.PlateBlacklist = ElvuiConfig.db.profile.spellfilter.PlateBlacklist
		
		--HealerBuffIDs
		E.HealerBuffIDs = ElvuiConfig.db.profile.spellfilter.HealerBuffIDs
		
		--DPSBuffIDs
		E.DPSBuffIDs = ElvuiConfig.db.profile.spellfilter.DPSBuffIDs
		
		--PetBuffIDs
		E.PetBuffs = ElvuiConfig.db.profile.spellfilter.PetBuffs
		
		--ClassTimers
		TRINKET_FILTER = ElvuiConfig.db.profile.spellfilter.TRINKET_FILTER
		CLASS_FILTERS = ElvuiConfig.db.profile.spellfilter.CLASS_FILTERS
		
		--CastTicks
		E.ChannelTicks = ElvuiConfig.db.profile.spellfilter.ChannelTicks
		
		--Reminders
		E.ReminderBuffs = ElvuiConfig.db.profile.spellfilter.ReminderBuffs
		
		E.SavePath = ElvuiConfig.db.profile
end




