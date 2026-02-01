local _, ns = ...
local oUF = { Private = {} }
ns.oUF = oUF

local mod = mod
local unpack = unpack
local issecretvalue = issecretvalue
local issecrettable = issecrettable

local _, _, _, wowtoc = GetBuildInfo()
oUF.wowtoc = wowtoc
oUF.baseClass, oUF.baseClassID = UnitClassBase('player')
oUF.myLocalizedClass, oUF.myclass, oUF.myClassID = UnitClass('player')

oUF.isTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC -- not used
oUF.isMists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
oUF.isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
oUF.isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
oUF.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
oUF.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local season = C_Seasons and C_Seasons.GetActiveSeason()
oUF.isClassicHC = season == 3 -- Hardcore
oUF.isClassicSOD = season == 2 -- Season of Discovery
oUF.isClassicAnniv = season == 11 -- Anniversary
oUF.isClassicAnnivHC = season == 12 -- Anniversary Hardcore

do -- Time function by Simpy
	local YEAR, DAY, HOUR, MINUTE, SECOND = 31557600, 86400, 3600, 60, 1
	function oUF:GetTime(value, noSecondText)
		if not value then
			return '', ''
		elseif value < SECOND then
			return '%.1f', value
		elseif value < MINUTE then
			return noSecondText and '%d' or'%ds', value
		elseif value < HOUR then
			local mins = mod(value, HOUR) / MINUTE
			return '%dm', mins
		elseif value < DAY then
			local hrs = mod(value, DAY) / HOUR
			return '%dh', hrs
		else
			local days = mod(value, YEAR) / DAY
			return '%dd', days
		end
	end
end

do -- API for secrets by Simpy
	function oUF:IsSecretValue(value)
		return issecretvalue and issecretvalue(value)
	end

	function oUF:IsSecretTable(object)
		return issecrettable and issecrettable(object)
	end

	function oUF:NotSecretValue(value)
		return not issecretvalue or not issecretvalue(value)
	end

	function oUF:NotSecretTable(object)
		return not issecrettable or not issecrettable(object)
	end

	function oUF:HasSecretValues(object)
		return object.HasSecretValues and object:HasSecretValues()
	end

	function oUF:NoSecretValues(object)
		return not object.HasSecretValues or not object:HasSecretValues()
	end
end

function oUF:UnpackAuraData(data) -- we use this directly from oUF in ElvUI
	if not data then return end

	local name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod = data.name, data.icon, data.applications, data.dispelName, data.duration, data.expirationTime, data.sourceUnit, data.isStealable, data.nameplateShowPersonal, data.spellId, data.canApplyAura, data.isBossAura, data.isFromPlayerOrPlayerPet, data.nameplateShowAll, data.timeMod
	if oUF:NotSecretTable(data.points) then
		return name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod, unpack(data.points)
	else
		return name, icon, applications, dispelName, duration, expirationTime, sourceUnit, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossAura, isFromPlayerOrPlayerPet, nameplateShowAll, timeMod
	end
end
