local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CP = E:NewModule('CopyProfile', "AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")

local pairs, next = pairs, next
local format = format

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

function CP:CopyTable(CopyFrom, CopyTo, CopyDefault, module)
	for key, value in pairs(CopyTo) do
		print(key)
		if type(value) ~= "table" then
			if module == true or (type(module) == "table" and module.general == nil or (not CopyTo.general and module.general)) then --Some dark magic of a logic to figure out stuff
				-- print(key)
				print("Debug, copy module option "..key)
				-- print("Key:", key, "CopyFrom:",  CopyFrom[key], "CopyTo:", CopyTo[key], "CopyDefault:", CopyDefault[key])
				--This is actually copying stuff. Don't uncomment unless testing on bogus profiles
				--This check is to see if the profile we are copying from has keys absent from defaults.
				--If key exists, then copy. If not, then clear obsolite key from the profile.
				-- if CopyDefault[key] then 
					-- CopyTo[key] = CopyFrom[key] or CopyDefault[key]
				-- else
					-- CopyFrom[key] = nil
				-- end
			end
		else
			if module == true then
				print("CP:CopyTable - I should copy over the whole section.", key)
				--This is actually copying stuff. Don't uncomment unless testing on bogus profiles
				-- E:CopyTable(CopyTo, CopyDefault)
				-- E:CopyTable(CopyTo, CopyFrom)
			elseif module[key] then
				print("Debug, copy module table "..key)
				CP:CopyTable(CopyFrom[key], CopyTo[key], CopyDefault[key], module[key])
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

function CP:ImportFromProfile(section)
	--Some checks for the occasion someone passes wrong stuff
	if not section then error("No profile section provided. Usage CP:ImportFromProfile(section)") end
	if section == "selected" then error('Section name could not be "selected". This name is reserved for internal setting') end
	print(section)
	local module = E.global.profileCopy[section]
	if not module then error(format('Provided section name "%s" does not have a template for profile copy.', section)) end
	--Starting digging through the settings
	local CopyFrom = ElvDB["profiles"][E.global.profileCopy.selected][section]
	local CopyTo = E.db[section]
	local CopyDefault = P[section]
	if type(module) == "table" and next(module) then
		CP:CopyTable(CopyFrom, CopyTo, CopyDefault, module)
	elseif type(module) == "boolean" then
		print("I should copy over the whole section.")
		--This is actually copying stuff. Don't uncomment unless testing on bogus profiles
		-- E:CopyTable(CopyTo, CopyDefault)
		-- E:CopyTable(CopyTo, CopyFrom)
	else
		error(format('Provided section name "%s" does not have a valid copy template.', section))
	end
	-- E:UpdateAll(true)
end

function CP:ExportToProfile(section)
	--Some checks for the occasion someone passes wrong stuff
	if not section then error("No profile section provided. Usage CP:ImportFromProfile(section)") end
	if section == "selected" then error('Section name could not be "selected". This name is reserved for internal setting') end
	print(section)
	local module = E.global.profileCopy[section]
	if not module then error(format('Provided section name "%s" does not have a template for profile copy.', section)) end
	--Starting digging through the settings
	local CopyFrom = E.db[section]
	local CopyTo = ElvDB["profiles"][E.global.profileCopy.selected][section]
	local CopyDefault = P[section]
	if type(module) == "table" and next(module) then
		CP:CopyTable(CopyFrom, CopyTo, CopyDefault, module)
	elseif type(module) == "boolean" then
		print("I should copy over the whole section.")
		--This is actually copying stuff. Don't uncomment unless testing on bogus profiles
		-- E:CopyTable(CopyTo, CopyDefault)
		-- E:CopyTable(CopyTo, CopyFrom)
	else
		error(format('Provided section name "%s" does not have a valid copy template.', section))
	end
	-- E:UpdateAll(true)
end

--Maybe actually not needed at all
function CP:Initialize()
	
end

local function InitializeCallback()
	CP:Initialize()
end

E:RegisterModule(CP:GetName(), InitializeCallback)
