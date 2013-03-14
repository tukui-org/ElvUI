if not ElvUI then return end

local MAJOR, MINOR = "LibElvUIPlugin-1.0", 10
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)


if not lib then return end
lib.plugins = {}
lib.index = 0
--
-- GLOBALS:
--

local E = ElvUI[1]
local _

-- MULTI Language Support (Default Language: English)
local MSG_OUTDATED = "Your version of %s is out of date (latest is version %d). You can download the latest version from http://www.tukui.org"
local HDR_CONFIG = "Plugins"
local HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins Loaded  (Green means you have current version, Red means out of date)"
local INFO_BY = "by"
local INFO_VERSION = "Version:"
local INFO_NEW = "Newest:"

if GetLocale() == "ruRU" then -- Russian Translations
	MSG_OUTDATED = "Ваша версия %s устарела. Вы можете скачать последнюю версию на http://www.tukui.org"
	HDR_CONFIG = "Плагины"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - загруженные плагины (зеленый означает, что у вас последняя версия, красный - устаревшая)"
	INFO_BY = "от"
	INFO_VERSION = "Версия:"
	INFO_NEW = "Последняя:"
end

--
-- Plugin table format:
--   { name (string) - The name of the plugin,
--     version (string) - The version of the plugin,
--     optionCallback (string) - The callback to call when ElvUI_Config is loaded
--   }
--

--
-- RegisterPlugin(name,callback)
--   Registers a module with the given name and option callback, pulls version info from metadata
--

function lib:RegisterPlugin(name,callback)
	local plugin = {}
	plugin.name = name
	plugin.version = name == MAJOR and MINOR or GetAddOnMetadata(name, "Version")
	plugin.callback = callback
	lib.plugins[name] = plugin
	local enabled, loadable = select(4,GetAddOnInfo("ElvUI_Config"))
	local loaded = IsAddOnLoaded("ElvUI_Config")
	if enabled and loadable and not loaded then
		if not lib.ConfigFrame then
			local configFrame = CreateFrame("Frame")
			configFrame:RegisterEvent("ADDON_LOADED")
			configFrame:SetScript("OnEvent", function(self,event,addon)
				if addon == "ElvUI_Config" then
					for _, plugin in pairs(lib.plugins) do
						if(plugin.callback) then
							plugin.callback()
						end
					end
				end
			end)
			lib.ConfigFrame = configFrame
		end
	else
		-- Need to update plugins list
		if name ~= MAJOR then
			E.Options.args.plugins.args.plugins.name = lib:GeneratePluginList()
		end
		callback()
	end

	lib:SetupVersionCheck(plugin)
	lib.index = lib.index + 1
	
	return plugin
end

function lib:SetupVersionCheck(plugin)
	local prefix = "EPVC"..lib.index
	E["Send"..plugin.name.."VersionCheck"] = function()
		local _, instanceType = IsInInstance()
		if IsInRaid() then
			SendAddonMessage(prefix, plugin.version, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
		elseif IsInGroup() then
			SendAddonMessage(prefix, plugin.version, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
		end
		
		if E["Send"..plugin.name.."MSGTimer"] then
			E:CancelTimer(E["Send"..plugin.name.."MSGTimer"])
			E["Send"..plugin.name.."MSGTimer"] = nil
		end
	end
	RegisterAddonMessagePrefix(prefix)
	local function SendRecieve(prefix)
		return function(self, event, mprefix, message, channel, sender)
			if event == "CHAT_MSG_ADDON" then
				if sender == E.myname or not sender or mprefix ~= prefix  or plugin.name == MAJOR then return end
				
				if not E[plugin.name.."recievedOutOfDateMessage"] then
					if plugin.version ~= 'BETA' and tonumber(message) ~= nil and tonumber(plugin.version) ~= nil and tonumber(message) > tonumber(plugin.version) then
						plugin.old = true
						plugin.newversion = tonumber(message)
						local Pname = GetAddOnMetadata(plugin.name, "Title")
						E:Print(format(MSG_OUTDATED,Pname,plugin.newversion))
						E[plugin.name.."recievedOutOfDateMessage"] = true
					end
				end
			else
				E["Send"..plugin.name.."MSGTimer"] = E:ScheduleTimer("Send"..plugin.name.."VersionCheck", 12)
			end
		end
	end

	local f = CreateFrame('Frame')
	f:RegisterEvent("GROUP_ROSTER_UPDATE")
	f:RegisterEvent("CHAT_MSG_ADDON")
	f:SetScript('OnEvent', SendRecieve(prefix))
end

function lib:GetPluginOptions()
	E.Options.args.plugins = {
        order = 10000,
        type = "group",
        name = HDR_CONFIG,
        guiInline = false,
        args = {
            pluginheader = {
                order = 1,
                type = "header",
                name = format(HDR_INFORMATION, MINOR),
            },
            plugins = {
                order = 2,
                type = "description",
                name = lib:GeneratePluginList(),
            },
        }
    }
end


function lib:GeneratePluginList()
	list = ""
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			local author = GetAddOnMetadata(plugin.name, "Author")
			local Pname = GetAddOnMetadata(plugin.name, "Title") or plugin.name
			local color = plugin.old and E:RGBToHex(1,0,0) or E:RGBToHex(0,1,0)
			list = list .. Pname 
			if author then
			  list = list .. " ".. INFO_BY .." " .. author
			end
			list = list .. color .. " - " .. INFO_VERSION .." " .. plugin.version
			if plugin.old then
			  list = list .. INFO_NEW .. plugin.newversion .. ")"
			end
			list = list .. "|r\n"
		end
	end
	return list
end

lib:RegisterPlugin(MAJOR, lib.GetPluginOptions)