local _, ns = ...
local oUF = { Private = {} }
ns.oUF = oUF

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
