--And so it begins..
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

--Constants
E.dummy = function() return end
E.myname, _ = UnitName("player")
E.myrealm = GetRealmName()
_, E.myclass = UnitClass("player")
E.version = GetAddOnMetadata("ElvUI", "Version")
E.patch = GetBuildInfo()
E.level = UnitLevel("player")
E.IsElvsEdit = true
E.resolution = GetCVar('gxResolution')
E.screenheight = tonumber(string.match(E.resolution, "%d+x(%d+)"))
E.screenwidth = tonumber(string.match(E.resolution, "(%d+)x+%d"))
E.Layouts = {} --Unitframe Layouts
E.UIParent = CreateFrame('Frame', 'ElvUIParent', UIParent)
E.UIParent:SetFrameLevel(E.UIParent:GetFrameLevel())
E.UIParent:SetFrameStrata(E.UIParent:GetFrameStrata())
E.UIParent:SetPoint('CENTER', UIParent, 'CENTER')
E.UIParent:SetSize(UIParent:GetSize())

--Keybind Header
BINDING_HEADER_ELVUI = GetAddOnMetadata("ElvUI", "Title") --Header name inside keybinds menu

--Check Player's Role
local RoleUpdater = CreateFrame("Frame")
local function CheckRole(self, event, unit)
	local tree = GetPrimaryTalentTree()
	local resilience
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() and UnitLevel('player') == MAX_PLAYER_LEVEL then
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



--Check if our embed right addon is shown
function E.CheckAddOnShown()
	if E.ChatRightShown == true and E.RightChat and E.RightChat == true then
		return true
	elseif C["skin"].embedright == "Omen" and IsAddOnLoaded("Omen") and OmenAnchor then
		if OmenAnchor:IsShown() then
			return true
		else
			return false
		end
	elseif C["skin"].embedright == "Recount" and IsAddOnLoaded("Recount") and Recount_MainWindow then
		if Recount_MainWindow:IsShown() then
			return true
		else
			return false
		end
	elseif  C["skin"].embedright ==  "Skada" and IsAddOnLoaded("Skada") and Skada:GetWindows()[1] then
		if Skada:GetWindows()[1].bargroup:IsShown() then
			return true
		else
			return false
		end
	else
		return false
	end
end