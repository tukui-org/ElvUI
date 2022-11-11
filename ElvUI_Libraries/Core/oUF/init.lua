local _, ns = ...
ns.oUF = {}
ns.oUF.Private = {}

local _, _, _, toc = GetBuildInfo()

ns.oUF.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
ns.oUF.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
ns.oUF.isTBC = toc >= 20500 and toc < 30000 -- TODO: Wrath
ns.oUF.isWrath = toc >= 30400 and toc < 40000 -- TODO: Wrath
