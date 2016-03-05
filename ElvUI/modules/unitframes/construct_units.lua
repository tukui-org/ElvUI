local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");
local _, ns = ...
local ElvUF = ns.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")

--[[
	The plan is to start with transitioning into functions for each element. 
	This will be handled inside the elements files.
	After all elements are transitioned; begin working all units into a single function.
	That will be inside this file.
]]
