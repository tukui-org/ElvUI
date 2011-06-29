-----------------------------------------------------
-- All starts here baby!

-- Credit Nightcracker
-----------------------------------------------------

-- including system
local addon, engine = ...
engine[1] = {} -- E, functions, constants
engine[2] = {} -- C, config
engine[3] = {} -- L, localization
engine[4] = {} -- DB, database, post config load

ElvUI = engine --Allow other addons to use Engine

local E, C, L, DB = unpack(select(2, ...))
function E.IsPTRVersion()
	local _, version = GetBuildInfo()
	if tonumber(version) > 14333 then
		return true
	else
		return false
	end
end


--[[
	This should be at the top of every file inside of the ElvUI AddOn:
	
	local E, C, L, DB = unpack(select(2, ...))

	This is how another addon imports the ElvUI engine:
	
	local E, C, L, DB = unpack(ElvUI)
]]