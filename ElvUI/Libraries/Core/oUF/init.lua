local _, ns = ...
ns.oUF = {}
ns.oUF.Private = {}

ns.oUF.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
ns.oUF.isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
ns.oUF.isTBC = select(4, GetBuildInfo()) >= 20500 and select(4, GetBuildInfo()) < 30000 -- TODO: Check back later
ns.oUF.isWotLK = select(4, GetBuildInfo()) >= 30400 and select(4, GetBuildInfo()) < 40000 -- TODO: Check back later