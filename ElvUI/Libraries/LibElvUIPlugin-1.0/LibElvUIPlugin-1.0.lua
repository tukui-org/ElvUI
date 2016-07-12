local MAJOR, MINOR = "LibElvUIPlugin-1.0", 13
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

--Cache global variables
--Lua functions
local pairs, tonumber = pairs, tonumber
local format, strsplit = format, strsplit
--WoW API / Variables
local CreateFrame = CreateFrame
local IsInInstance, IsInGroup, IsInRaid = IsInInstance, IsInGroup, IsInRaid
local GetAddOnMetadata = GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded
local RegisterAddonMessagePrefix = RegisterAddonMessagePrefix
local SendAddonMessage = SendAddonMessage
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: ElvUI

lib.plugins = {}
lib.index = 0
lib.prefix = "ElvUIPluginVC"

-- MULTI Language Support (Default Language: English)
local MSG_OUTDATED = "Your version of %s is out of date (latest is version %s). You can download the latest version from http://www.tukui.org"
local HDR_CONFIG = "Plugins"
local HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins Loaded  (Green means you have current version, Red means out of date)"
local INFO_BY = "by"
local INFO_VERSION = "Version:"
local INFO_NEW = "Newest:"
local LIBRARY = "Library"

if GetLocale() == "deDE" then -- German Translation
	MSG_OUTDATED = "Deine Version von %s ist veraltet (akutelle Version ist %s). Du kannst die aktuelle Version von http://www.tukui.org herunterrladen."
	HDR_CONFIG = "Plugins"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins geladen (Grün bedeutet du hast die aktuelle Version, Rot bedeutet es ist veraltet)"
	INFO_BY = "von"
	INFO_VERSION = "Version:"
	INFO_NEW = "Neuste:"
	LIBRARY = "Bibliothek"
end

if GetLocale() == "ruRU" then -- Russian Translations
	MSG_OUTDATED = "Ваша версия %s устарела (последняя версия %s). Вы можете скачать последнюю версию на http://www.tukui.org"
	HDR_CONFIG = "Плагины"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - загруженные плагины (зеленый означает, что у вас последняя версия, красный - устаревшая)"
	INFO_BY = "от"
	INFO_VERSION = "Версия:"
	INFO_NEW = "Последняя:"
	LIBRARY = "Библиотека"
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

function lib:RegisterPlugin(name,callback, isLib)
    local plugin = {}
	plugin.name = name
	plugin.version = name == MAJOR and MINOR or GetAddOnMetadata(name, "Version")
	if isLib then plugin.isLib = true; plugin.version = 1 end
	plugin.callback = callback
	lib.plugins[name] = plugin
	local loaded = IsAddOnLoaded("ElvUI_Config")

	if not lib.vcframe then
		RegisterAddonMessagePrefix(lib.prefix)
		local f = CreateFrame('Frame')
		f:RegisterEvent("GROUP_ROSTER_UPDATE")
		f:RegisterEvent("CHAT_MSG_ADDON")
		f:SetScript('OnEvent', lib.VersionCheck)
		lib.vcframe = f
	end

	if not loaded then
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
	elseif loaded then
		-- Need to update plugins list
		if name ~= MAJOR then
			ElvUI[1].Options.args.plugins.args.plugins.name = lib:GeneratePluginList()
		end
		callback()
	end

	return plugin
end

function lib:GetPluginOptions()
	ElvUI[1].Options.args.plugins = {
        order = -10,
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

function lib:GenerateVersionCheckMessage()
	local list = ""
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			list = list..plugin.name.."="..plugin.version..";"
		end
	end
	return list
end

local function SendPluginVersionCheck(self)
	lib:SendPluginVersionCheck(lib:GenerateVersionCheckMessage())
	
	if self["ElvUIPluginSendMSGTimer"] then
		self:CancelTimer(self["ElvUIPluginSendMSGTimer"])
		self["ElvUIPluginSendMSGTimer"] = nil
	end
end

function lib:VersionCheck(event, prefix, message, channel, sender)
	local E = ElvUI[1]
	if event == "CHAT_MSG_ADDON" then
		if sender == E.myname or not sender or prefix ~= lib.prefix then return end
		if not E["pluginRecievedOutOfDateMessage"] then
			for _, p in pairs({strsplit(";",message)}) do
				local name, version = p:match("([%w_]+)=([%d%p]+)")
				if lib.plugins[name] then
					local plugin = lib.plugins[name]
					if plugin.version ~= 'BETA' and version ~= nil and tonumber(version) ~= nil and plugin.version ~= nil and tonumber(plugin.version) ~= nil and tonumber(version) > tonumber(plugin.version) then
						plugin.old = true
						plugin.newversion = tonumber(version)
						local Pname = GetAddOnMetadata(plugin.name, "Title")
						E:Print(format(MSG_OUTDATED,Pname,plugin.newversion))
						E["pluginRecievedOutOfDateMessage"] = true
					end
				end
			end
		end
	else
		E.SendPluginVersionCheck = E.SendPluginVersionCheck or SendPluginVersionCheck
		E["ElvUIPluginSendMSGTimer"] = E:ScheduleTimer("SendPluginVersionCheck", 2)
	end 
end

function lib:GeneratePluginList()
	local list = ""
	local E = ElvUI[1]
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			local author = GetAddOnMetadata(plugin.name, "Author")
			local Pname = GetAddOnMetadata(plugin.name, "Title") or plugin.name
			local color = plugin.old and E:RGBToHex(1,0,0) or E:RGBToHex(0,1,0)
			list = list .. Pname 
			if author then
			  list = list .. " ".. INFO_BY .." " .. author
			end
			list = list .. color ..(plugin.isLib and " "..LIBRARY or " - " .. INFO_VERSION .." " .. plugin.version)
			if plugin.old then
			  list = list .. INFO_NEW .. plugin.newversion .. ")"
			end
			list = list .. "|r\n"
		end
	end
	return list
end

function lib:SendPluginVersionCheck(message)
	local plist = {strsplit(";",message)}
	local m = ""
	local delay = 1
	local E = ElvUI[1]
	for _, p in pairs(plist) do
		if(#(m .. p .. ";") < 230) then
			m = m .. p .. ";"
		else
			local _, instanceType = IsInInstance()
			if IsInRaid() then
				E:Delay(delay,SendAddonMessage(lib.prefix, m, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID"))
			elseif IsInGroup() then
				E:Delay(delay,SendAddonMessage(lib.prefix, m, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY"))
			end
			m = p .. ";"
			delay = delay + 1
		end
	end
	-- Send the last message
	local _, instanceType = IsInInstance()
	if IsInRaid() then
		E:Delay(delay+1,SendAddonMessage(lib.prefix, m, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID"))
	elseif IsInGroup() then
		E:Delay(delay+1,SendAddonMessage(lib.prefix, m, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY"))
	end
end

lib:RegisterPlugin(MAJOR, lib.GetPluginOptions)