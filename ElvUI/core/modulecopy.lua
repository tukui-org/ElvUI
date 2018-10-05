local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CP = E:NewModule('CopyProfile', "AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")

local pairs, next, type = pairs, next, type
local format, error = format, error

--Default template for a config group for a single module.
--Contains header, general group toggle (shown only if the setting actually exists) and imports button.
--Usage as seen in ElvUI_Config\modulecopy.lua
function CP:CreateModuleConfigGroup(Name, section)
	local config = {
		order = 10,
		type = 'group',
		name = Name,
		args = {
			header = {
				order = 0,
				type = "header",
				name = Name,
			},
			general = {
				order = 1,
				type = "toggle",
				name = L["General"],
				hidden = function(info) return E.global.profileCopy[section][ info[#info] ] == nil end,
				get = function(info) return E.global.profileCopy[section][ info[#info] ] end,
				set = function(info, value) E.global.profileCopy[section][ info[#info] ] = value; end
			},
			PreButtonSpacer = {
				order = 200,
				type = "description",
				name = "",
			},
			import = {
				order = 201,
				type = "execute",
				name = L["Import Now"],
				func = function() CP:ImportFromProfile(section) end,
			},
			export = {
				order = 202,
				type = "execute",
				name = L["Export Now"],
				func = function() CP:ExportToProfile(section) end,
			},
		},
	}
	return config
end

function CP:CreateMoversConfigGroup()
	local config = {
		header = {
			order = 0,
			type = "header",
			name = L["On screen positions for different elements."],
		},
		PreButtonSpacer = {
			order = 200,
			type = "description",
			name = "",
		},
		import = {
			order = 201,
			type = "execute",
			name = L["Import Now"],
			func = function() CP:CopyMovers("import") end,
		},
		export = {
			order = 202,
			type = "execute",
			name = L["Export Now"],
			func = function() CP:CopyMovers("export") end,
		},
	}
	for moverName, data in pairs(E.CreatedMovers) do
		if not G.profileCopy.movers[moverName] then G.profileCopy.movers[moverName] = false end
		config[moverName] = {
			order = 1,
			type = "toggle",
			name = data.text,
			get = function(info) return E.global.profileCopy.movers[moverName] end,
			set = function(info, value) E.global.profileCopy.movers[moverName] = value; end
		}
	end
	return config
end

function CP:CopyTable(CopyFrom, CopyTo, CopyDefault, module)
	for key, value in pairs(CopyTo) do
		if type(value) ~= "table" then
			if module == true or (type(module) == "table" and module.general == nil or (not CopyTo.general and module.general)) then --Some dark magic of a logic to figure out stuff
				--This check is to see if the profile we are copying from has keys absent from defaults.
				--If key exists, then copy. If not, then clear obsolite key from the profile.
				if CopyDefault[key] then 
					CopyTo[key] = CopyFrom[key] or CopyDefault[key]
				else
					CopyFrom[key] = nil
				end
			end
		else
			if module == true then --Copy over entire section of profile subgroup
				E:CopyTable(CopyTo, CopyDefault)
				E:CopyTable(CopyTo, CopyFrom)
			elseif module[key] then
				--Making sure tables actually exist in profiles (e.g absent values in ElvDB["profiles"] are for default values)
				CopyFrom[key], CopyTo[key] = CP:TablesExist(CopyFrom[key], CopyTo[key], CopyDefault[key])
				--If key exists, then copy. If not, then clear obsolite key from the profile.
				--Someone should double check this logic. Cause for single keys it is fine, but I'm no sure bout whole tables @Darth
				if CopyFrom[key] then
					CP:CopyTable(CopyFrom[key], CopyTo[key], CopyDefault[key], module[key])
				else
					CopyTo[key] = nil
				end
			end
		end
	end
end

--[[
* Valid copy templates should be as follows
G["profileCopy"][YourOptionGroupName] = {
	[SubGroupName1] = true,
	[SubGroupName2] = true,
	...
}
* For example
G["profileCopy"]["auras"] = {
	["general"] = true,
	["buffs"] = true,
	["debuffs"] = true,
	["cooldown"] = true,
}
* "general" key can refer to a similar named subtable or all non-table variables inside your group
* If you leave the table as G["profileCopy"][YourOptionGroupName] = {}, this will result in no valid copy template error.
* If set to G["profileCopy"][YourOptionGroupName] = true, then this will copy everything without selecting
any particular subcategory from your settings table.
]]

function CP:TablesExist(CopyFrom, CopyTo, CopyDefault)
	if not CopyFrom then CopyFrom = CopyDefault end
	if not CopyTo then CopyTo = CopyDefault end
	return CopyFrom, CopyTo
end

function CP:ImportFromProfile(section)
	--Some checks for the occasion someone passes wrong stuff
	if not section then error("No profile section provided. Usage CP:ImportFromProfile(\"section\")") end
	if section == "selected" or section == "movers" then error(format("Section name could not be \"%s\". This name is reserved for internal setting"), section) end

	local module = E.global.profileCopy[section]
	if not module then error(format("Provided section name \"%s\" does not have a template for profile copy.", section)) end
	--Starting digging through the settings
	local CopyFrom = ElvDB["profiles"][E.global.profileCopy.selected][section]
	local CopyTo = E.db[section]
	local CopyDefault = P[section]
	--Making sure tables actually exist in profiles (e.g absent values in ElvDB["profiles"] are for default values)
	CopyFrom, CopyTo = CP:TablesExist(CopyFrom, CopyTo, CopyDefault)
	if type(module) == "table" and next(module) then --This module is not an empty table
		CP:CopyTable(CopyFrom, CopyTo, CopyDefault, module)
	elseif type(module) == "boolean" then --Copy over entire section of profile subgroup
		E:CopyTable(CopyTo, CopyDefault)
		E:CopyTable(CopyTo, CopyFrom)
	else
		error(format("Provided section name \"%s\" does not have a valid copy template.", section))
	end
	E:UpdateAll(true)
end

function CP:ExportToProfile(section)
	--Some checks for the occasion someone passes wrong stuff
	if not section then error("No profile section provided. Usage CP:ExportToProfile(\"section\")") end
	if section == "selected" or section == "movers" then error(format("Section name could not be \"%s\". This name is reserved for internal setting"), section) end

	local module = E.global.profileCopy[section]
	if not module then error(format("Provided section name \"%s\" does not have a template for profile copy.", section)) end
	--Making sure tables actually exist
	if not ElvDB["profiles"][E.global.profileCopy.selected][section] then ElvDB["profiles"][E.global.profileCopy.selected][section] = {} end
	if not E.db[section] then E.db[section] = {} end
	--Starting digging through the settings
	local CopyFrom = E.db[section]
	local CopyTo = ElvDB["profiles"][E.global.profileCopy.selected][section]
	local CopyDefault = P[section]
	if type(module) == "table" and next(module) then --This module is not an empty table
		CP:CopyTable(CopyFrom, CopyTo, CopyDefault, module)
	elseif type(module) == "boolean" then --Copy over entire section of profile subgroup
		E:CopyTable(CopyTo, CopyDefault)
		E:CopyTable(CopyTo, CopyFrom)
	else
		error(format("Provided section name \"%s\" does not have a valid copy template.", section))
	end
end

function CP:CopyMovers(mode)
	if not E.db.movers then E.db.movers = {} end --Nothing was moved in cutrrent profile
	if not ElvDB["profiles"][E.global.profileCopy.selected].movers then ElvDB["profiles"][E.global.profileCopy.selected].movers = {} end --Nothing was moved in selected profile
	local CopyFrom, CopyTo
	if mode == "export" then
		CopyFrom, CopyTo = E.db.movers, ElvDB["profiles"][E.global.profileCopy.selected].movers
	else
		CopyFrom, CopyTo = ElvDB["profiles"][E.global.profileCopy.selected].movers or {}, E.db.movers
	end

	for moverName, data in pairs(E.CreatedMovers) do
		if E.global.profileCopy.movers[moverName] then
			CopyTo[moverName] = CopyFrom[moverName]
		end
	end
	E:SetMoversPositions()
end

--Maybe actually not needed at all
function CP:Initialize()
	
end

local function InitializeCallback()
	CP:Initialize()
end

E:RegisterModule(CP:GetName(), InitializeCallback)
