--And so it begins..
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--Constants
E.dummy = function() return end
E.myname, _ = UnitName("player")
E.myrealm = GetRealmName()
_, E.myclass = UnitClass("player")
E.version = GetAddOnMetadata("ElvUI", "Version")
E.patch = GetBuildInfo()
E.level = UnitLevel("player")
E.IsElvsEdit = true
E.resolution = GetCurrentResolution()
E.getscreenresolution = select(E.resolution, GetScreenResolutions())
E.getscreenheight = tonumber(string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
E.getscreenwidth = tonumber(string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x+%d"))
E.Layouts = {}

--Keybind Header
BINDING_HEADER_ELVUI = GetAddOnMetadata("ElvUI", "Title") --Header name inside keybinds menu

--Check Player's Role
local RoleUpdater = CreateFrame("Frame")
local function CheckRole(self, event, unit)
	local tree = GetPrimaryTalentTree()
	local resilience
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() then
		resilience = true
	else
		resilience = false
	end
	if ((E.myclass == "PALADIN" and tree == 2) or 
	(E.myclass == "WARRIOR" and tree == 3) or 
	(E.myclass == "DEATHKNIGHT" and tree == 1)) and
	resilience == false or
	(E.myclass == "DRUID" and tree == 2 and GetBonusBarOffset() == 3) then
		E.Role = "Tank"
	else
		local playerint = select(2, UnitStat("player", 4))
		local playeragi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (((playerap > playerint) or (playeragi > playerint)) and not (E.myclass == "SHAMAN" and tree ~= 1 and tree ~= 3) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139)))) or E.myclass == "ROGUE" or E.myclass == "HUNTER" or (E.myclass == "SHAMAN" and tree == 2) then
			E.Role = "Melee"
		else
			E.Role = "Caster"
		end
	end
end	
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)
CheckRole()

-- convert datatext E.ValColor from rgb decimal to hex DO NOT TOUCH
local r, g, b = unpack(C["media"].valuecolor)
E.ValColor = ("|cff%.2x%.2x%.2x"):format(r * 255, g * 255, b * 255)