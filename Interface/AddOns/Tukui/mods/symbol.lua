--[[ 	
		ORIGINAL AUTHOR OF THIS CODE BELOW IS ALZA, I RENAMED THE FILE TO tMark
		BECAUSE IT'S EDITED A BIT AND I'LL ADD SOME NEW FEATURE VERY SOON TO THIS.
--]]


local L = GetLocale()
local L_CLEAR, L_SKULL, L_CROSS, L_SQUARE, L_MOON, L_TRIANGLE, L_DIAMOND, L_CIRCLE, L_STAR
if(L=="frFR") then
	L_CLEAR = "Pas de symbole"
    L_SKULL = "Tête de mort"
    L_CROSS = "Croix"
    L_SQUARE = "Carré"
    L_MOON = "Lune"
    L_TRIANGLE = "Triangle"
    L_DIAMOND = "Diamand"
    L_CIRCLE = "Cercle"
    L_STAR = "Étoile"
else
	L_CLEAR = "Clear"
    L_SKULL = "Skull"
    L_CROSS = "Cross"
    L_SQUARE = "Square"
    L_MOON = "Moon"
    L_TRIANGLE = "Triangle"
    L_DIAMOND = "Diamond"
    L_CIRCLE = "Circle"
    L_STAR = "Star"
end

local menuFrame = CreateFrame("Frame", "aSettingsMarkingFrame", UIParent, "UIDropDownMenuTemplate")
local menuList = {
    {text = L_CLEAR,
    func = function() SetRaidTarget("target", 0) end},
    {text = L_SKULL,
    func = function() SetRaidTarget("target", 8) end},
    {text = "|cffff0000"..L_CROSS.."|r",
    func = function() SetRaidTarget("target", 7) end},
    {text = "|cff00ffff"..L_SQUARE.."|r",
    func = function() SetRaidTarget("target", 6) end},
    {text = "|cffC7C7C7"..L_MOON.."|r",
    func = function() SetRaidTarget("target", 5) end},
    {text = "|cff00ff00"..L_TRIANGLE.."|r",
    func = function() SetRaidTarget("target", 4) end},
    {text = "|cff912CEE"..L_DIAMOND.."|r",
    func = function() SetRaidTarget("target", 3) end},
    {text = "|cffFF8000"..L_CIRCLE.."|r",
    func = function() SetRaidTarget("target", 2) end},
    {text = "|cffffff00"..L_STAR.."|r",
    func = function() SetRaidTarget("target", 1) end},
}

WorldFrame:HookScript("OnMouseDown", function(self, button)
    if(button=="LeftButton" and IsShiftKeyDown() and IsControlKeyDown() and UnitExists("mouseover")) then --IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown()
        local inParty = (GetNumPartyMembers() > 0)
        local inRaid = (GetNumRaidMembers() > 0)
        if(inRaid and (IsRaidLeader() or IsRaidOfficer()) or (inParty and not inRaid)) then
            EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 1)
        end
    end
end)
