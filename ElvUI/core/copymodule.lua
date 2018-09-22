local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CP = E:NewModule('CopyProfile', "AceEvent-3.0","AceTimer-3.0","AceComm-3.0","AceSerializer-3.0")

--Default template for a config group for a single module.
--Contains header, general group toggle (shown only if the setting actually exists) and imports button.
--Usage as seen in ElvUI_Config\modulecopy.lua
function CP:CreateModuleConfigGroup(Name, section)
	local config = {
		order = 1,
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
				hidden = function(info) return E.global.profileCopy.auras[ info[#info] ] == nil end,
				get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
				set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
			},
			PreButtonSpacer = {
				order = 200,
				type = "description",
				name = "",
			},
			copy = {
				order = 201,
				type = "execute",
				name = L["Import Now"],
				func = function() CP:ImportFromProfile(section) end,
			},
		},
	}
	return config
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
	if not module then error(format('Provided section name "%s" does not have a preset for profile copy.', section)) end
	--Starting digging through the settings
	print(#module)
	if type(module) == "table" and #module > 0 then
		for key, value in pairs(E.db[section]) do
			if type(value) ~= "table" then
				if E.global.profileCopy[section].general == nil or (not E.db[section].general and E.global.profileCopy[section].general) then
					print("Debug, copy "..section.." option "..key)
				end
			else
				if E.global.profileCopy[section][key] then
					print("Debug, copy "..section.." table "..key)
				end
			end
		end
	elseif type(module) == "boolean" then
		print("I should copy over the whole section.")
	else
		error(format('Provided section name "%s" does not have a valid copy template.', section))
	end
end

--Maybe actually not needed at all
function CP:Initialize()
	
end

local function InitializeCallback()
	CP:Initialize()
end

E:RegisterModule(CP:GetName(), InitializeCallback)
