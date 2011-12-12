-------------------------------------------------------------------------------
-- ElvUI Chat Tweaks By Lockslap (US, Bleeding Hollow)
-- <Borderline Amazing>, http://ba-guild.com
-- Based on functionality provided by Prat and/or Chatter
-------------------------------------------------------------------------------
local Module	= ElvUI_ChatTweaks:NewModule("Raid Helper", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
local L			= LibStub("AceLocale-3.0"):GetLocale("ElvUI_ChatTweaks")
Module.name		= L["Raid Helper"]

local format = string.format

local db, options
local defaults = {
	profile = {
		minDelay	= 2,
		maxDelay	= 2,
		refreshment	= true,
		feast		= true,
		cauldron	= true,
		repair		= true,
		souls		= true,
		summon		= true,
		haveGroup	= true,
		massRez		= true,
	}
}

-- spell ids for everything
local feasts = {
	57426,	-- Fish Feast (WOTLK)
	87643,	-- Broiled Dragon Feast
	87915,	-- Goblin BBQ Feast
	87644	-- Seafood Magnifique Feast
}
local cauldrons = {
	92649,	-- Cauldron of Battle
	92712	-- Big Cauldron of Battle
}
local repairBots = {
	67826,	-- Jeeves
	22700,	-- Field Repair Bot 74A
	44389,	-- Field Repair Bot 110G
	54711	-- Scrapbot
}
local ids = {
	-- repair bots
	["67826"]	= "49040",	-- Jeeves
	["22700"]	= "18232",	-- Field Repair Bot 74A
	["44389"]	= "34113",	-- Field Repair Bot 110G
	["54711"]	= "40769",	-- Scrapbot
	
	-- cauldrons
	["92649"]	= "62288",	-- Cauldron of Battle
	["92712"]	= "65460",	-- Big Cauldron of Battle
	
	-- feasts
	["57426"]	= "43015",	-- Fish Feast (WOTLK)
	["87643"]	= "62289",	-- Broiled Dragon Feast
	["87915"]	= "60858",	-- Goblin BBQ Feast
	["87644"]	= "62290"	-- Seafood Magnifique Feast
}

local function InArray(array, needle)
	if #array == 0 then return false end
	for _, value in pairs(array) do
		if needle == value then return true end
	end
	return false
end

local function GetChat()
	if GetNumRaidMembers() > 0 then
		return (IsRaidLeader() or IsRaidOfficer()) and "RAID_WARNING" or "RAID"
	elseif GetNumPartyMembers() > 0 then
		return "PARTY"
	end
	return "SAY"
end

local function InGroup()
	return (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) and true or false
end

function Module:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, subEvent, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType)
	if not InGroup() or InCombatLockdown() or not subEvent or not spellID or not srcName or not spellName then return end
	--if srcName == UnitName("player") then print(subEvent, spellID, spellName:gsub(" ", "_")) end
	if subEvent == "SPELL_CAST_START" then
		if not UnitInRaid(srcName) and not UnitInParty(srcName) then return end
		-- feasts/cauldrons
		if db.feast and InArray(feasts, spellID) or InArray(cauldrons, spellID) then
			local _, link = GetItemInfo(ids[tostring(spellID)])
			SendChatMessage(format(L["%s has prepared a %s."], srcName, link), GetChat(), nil)
		end
	elseif subEvent == "SPELL_CAST_SUCCESS" then
		if not UnitInRaid(srcName) and not UnitInParty(srcName) then return end
		-- repair bot or refreshment table
		if db.refreshment and spellID == 43987 then
			SendChatMessage(format(L["%s has put down a %s."], srcName, "refreshment table"), GetChat(), nil)
		elseif db.souls and spellID == 29893 then	-- ritual of souls
			SendChatMessage(format(L["%s is casting %s.  Click!"], srcName, GetSpellLink(29893)), GetChat(), nil)
		elseif db.summon and spellID == 698 then		-- ritual of summoning
			SendChatMessage(format(L["%s is casting %s.  Click!"], srcName, GetSpellLink(698)), GetChat(), nil)
		elseif db.repair and InArray(repairBots, spellID) then
			local _, link = GetItemInfo(tonumber(ids[tostring(spellID)]))
			SendChatMessage(format(L["%s has put down a %s."], srcName, link), GetChat(), nil)
		elseif db.haveGroup and spellID == 83967 then
			SendChatMessage(format(L["%s has casted %s."], srcName, GetSpellLink(83967)), GetChat(), nil)
		elseif db.massRez and spellID == 83968 then
			SendChatMessage(format(L["%s has casted %s."], srcName, GetSpellLink(83968)), GetChat(), nil)
		end
	end
end

function Module:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Module:OnDisable()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Module:OnInitialize()
	self.db = ElvUI_ChatTweaks.db:RegisterNamespace("RaidHelper", defaults)
	db = self.db.profile
end

function Module:Info()
	return L["Notifies the raid/party when someone places down a feast, cauldron, or repair bot."]
end

function Module:GetOptions()
	if not options then
		options = {
			minDelay = {
				type		= "range",
				order		= 15,
				name		= L["Minimum Delay"],
				desc		= L["Minimum time, in seconds, to wait before announcing."],
				get			= function() return db.minDelay end,
				set			= function(_, value)
					db.minDelay = value
					options.maxDelay.min = value
				end,
				min = 0, max = 5, step = 1,
			},
			maxDelay = {
				type		= "range",
				order		= 16,
				name		= L["Maximum Delay"],
				desc		= L["Maximum time, in seconds, to wait before announcing."],
				get			= function() return db.maxDelay end,
				set			= function(_, value)
					db.maxDelay = value
					options.minDelay.max = value
				end,
				min = 0, max = 5, step = 1,
			},
			refreshment = {
				type	= "toggle",
				name	= L["Ritual of Refreshment"],
				desc	= L["Announce when a mage begins casting Ritual of Refreshment."],
				get		= function() return db.refreshment end,
				set		= function(_, value) db.refreshment = value end,
			},
			feast = {
				type	= "toggle",
				name	= L["Feasts"],
				desc	= L["Announce when someone puts down a feast."],
				get		= function() return db.feast end,
				set		= function(_, value) db.feast = value end,
			},
			cauldron = {
				type	= "toggle",
				name	= L["Cauldron of Battle"],
				desc	= L["Announce when an alchemist puts down a (Big) Cauldron of Battle."],
				get		= function() return db.cauldron end,
				set		= function(_, value) db.cauldron = value end,
			},
			repair = {
				type	= "toggle",
				name	= L["Repair Bot"],
				desc	= L["Announce when an engineer puts down a repair bot."],
				get		= function() return db.repair end,
				set		= function(_, value) db.repair = value end,
			},
			souls = {
				type	= "toggle",
				name	= L["Ritual of Souls"],
				desc	= L["Announce when a warlock puts down a soulwell."],
				get		= function() return db.souls end,
				set		= function(_, value) db.souls = value end,
			},
			summon = {
				type	= "toggle",
				name	= L["Ritual of Summoning"],
				desc	= L["Announce when a warlock puts down a summoning stone."],
				get		= function() return db.summon end,
				set		= function(_, value) db.summon = value end,
			},
			haveGroup = {
				type	= "toggle",
				name	= L["Have Group, Will Travel"],
				desc	= L["Announce when someone casts Have Group, Will Travel, obtained when your guild reaches level 21."],
				get		= function() return db.haveGroup end,
				set		= function(_, value) db.haveGroup = value end,
			},
			massRez = {
				type	= "toggle",
				name	= L["Mass Ressurection"],
				desc	= L["Announce when someone casts Mass Ressurection, obtained when your guild reaches level 25."],
				get		= function() return db.massRez end,
				set		= function(_, value) db.massRez = value end,
			}
		}
	end
	return options
end