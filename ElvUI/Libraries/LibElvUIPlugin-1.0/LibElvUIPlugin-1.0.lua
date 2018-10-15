local MAJOR, MINOR = "LibElvUIPlugin-1.0", 22
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

--Cache global variables
--Lua functions
local pairs, tonumber, strmatch, strsub = pairs, tonumber, strmatch, strsub
local format, strsplit, strlen, gsub, ceil = format, strsplit, strlen, gsub, ceil
--WoW API / Variables
local GetNumGroupMembers = GetNumGroupMembers
local GetLocale, IsInGuild = GetLocale, IsInGuild
local CreateFrame, IsAddOnLoaded = CreateFrame, IsAddOnLoaded
local GetAddOnMetadata, GetChannelName = GetAddOnMetadata, GetChannelName
local IsInRaid, IsInGroup = IsInRaid, IsInGroup
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: ElvUI

lib.plugins = {}
lib.index = 0
lib.groupSize = 0
lib.prefix = "ElvUIPluginVC"

-- MULTI Language Support (Default Language: English)
local MSG_OUTDATED = "Your version of %s %s is out of date (latest is version %s). You can download the latest version from http://www.tukui.org"
local HDR_CONFIG = "Plugins"
local HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins Loaded  (Green means you have current version, Red means out of date)"
local INFO_BY = "by"
local INFO_VERSION = "Version:"
local INFO_NEW = "Newest:"
local LIBRARY = "Library"

if GetLocale() == "deDE" then -- German Translation
	MSG_OUTDATED = "Deine Version von %s %s ist veraltet (akutelle Version ist %s). Du kannst die aktuelle Version von http://www.tukui.org herunterrladen."
	HDR_CONFIG = "Plugins"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins geladen (Grün bedeutet du hast die aktuelle Version, Rot bedeutet es ist veraltet)"
	INFO_BY = "von"
	INFO_VERSION = "Version:"
	INFO_NEW = "Neuste:"
	LIBRARY = "Bibliothek"
end

if GetLocale() == "ruRU" then -- Russian Translations
	MSG_OUTDATED = "Ваша версия %s %s устарела (последняя версия %s). Вы можете скачать последнюю версию на http://www.tukui.org"
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

function lib:GenerateVersionCheckMessage()
	local list = ""
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			list = list..plugin.name.."="..plugin.version..";"
		end
	end
	return list
end

local function SendPluginVersionCheck()
	lib:SendPluginVersionCheck(lib:GenerateVersionCheckMessage())
end

local function DelayedSendVersionCheck()
	local E = ElvUI[1]

	if not E.SendPluginVersionCheck then
		ElvUI[1].SendPluginVersionCheck = SendPluginVersionCheck
	end

	if not lib.SendMessageTimer then
		lib.SendMessageTimer = E:ScheduleTimer("SendPluginVersionCheck", 10)
	end
end

function lib:RegisterPlugin(name, callback, isLib)
	if not ElvUI then return end -- lol?
	local E = ElvUI[1]

    local plugin = {}
	plugin.name = name
	plugin.version = name == MAJOR and MINOR or GetAddOnMetadata(name, "Version")
	if isLib then plugin.isLib = true; plugin.version = 1 end
	plugin.callback = callback
	lib.plugins[name] = plugin
	local loaded = IsAddOnLoaded("ElvUI_Config")

	if not lib.vcframe then
		C_ChatInfo_RegisterAddonMessagePrefix(lib.prefix)
		local f = CreateFrame('Frame')
		f:RegisterEvent("CHAT_MSG_ADDON")
		f:RegisterEvent("GROUP_ROSTER_UPDATE")
		f:SetScript('OnEvent', lib.VersionCheck)
		lib.vcframe = f
	end

	if not loaded then
		if not lib.ConfigFrame then
			local configFrame = CreateFrame("Frame")
			configFrame:RegisterEvent("ADDON_LOADED")
			configFrame:SetScript("OnEvent", function(_, _, addon)
				if addon == "ElvUI_Config" then
					for _, PlugIn in pairs(lib.plugins) do
						if PlugIn.callback then
							PlugIn.callback()
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

	DelayedSendVersionCheck() -- initial broadcast

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

function lib:VersionCheck(event, prefix, message, _, sender)
	local E = ElvUI[1]
	if (event == "CHAT_MSG_ADDON" and prefix == lib.prefix) and (sender and message and not strmatch(message, "^%s-$")) then
		if not lib.myName then lib.myName = E.myname..'-'..gsub(E.myrealm,'[%s%-]','') end
		if sender == lib.myName then return end

		if not E.pluginRecievedOutOfDateMessage then
			local name, version, plugin, Pname
			for _, p in pairs({strsplit(";",message)}) do
				if not strmatch(p, "^%s-$") then
					name, version = strmatch(p, "([%w_]+)=([%d%p]+)")
					if lib.plugins[name] then
						plugin = lib.plugins[name]
						if (version ~= nil and plugin.version ~= nil and plugin.version ~= 'BETA') and (tonumber(version) ~= nil and tonumber(plugin.version) ~= nil) and (tonumber(version) > tonumber(plugin.version)) then
							plugin.old, plugin.newversion = true, tonumber(version)
							Pname = GetAddOnMetadata(plugin.name, "Title")
							E:Print(format(MSG_OUTDATED,Pname,plugin.version,plugin.newversion))
							ElvUI[1].pluginRecievedOutOfDateMessage = true
						end
					end
				end
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" then
		local num = GetNumGroupMembers()
		if num ~= lib.groupSize then
			if num > 1 and num > lib.groupSize then
				DelayedSendVersionCheck()
			end
			lib.groupSize = num
		end
	end
end

function lib:GeneratePluginList()
	local E, list = ElvUI[1], ""
	local author, Pname, color
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			author = GetAddOnMetadata(plugin.name, "Author")
			Pname = GetAddOnMetadata(plugin.name, "Title") or plugin.name
			color = plugin.old and E:RGBToHex(1,0,0) or E:RGBToHex(0,1,0)
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

function lib:ClearSendMessageTimer()
	lib.SendMessageTimer = nil
end

function lib:SendPluginVersionCheck(message)
	if (not message) or strmatch(message, "^%s-$") then return end
	local ChatType, Channel

	if IsInRaid() then
		ChatType = (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID"
	elseif IsInGroup() then
		ChatType = (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY"
	else
		local ElvUIGVC = GetChannelName('ElvUIGVC')
		if ElvUIGVC and ElvUIGVC > 0 then
			ChatType, Channel = "CHANNEL", ElvUIGVC
		elseif IsInGuild() then
			ChatType = "GUILD"
		end
	end

	if not ChatType then
		lib.ClearSendMessageTimer()
		return
	end

	local delay, maxChar, msgLength = 0, 250, strlen(message)
	if msgLength > maxChar then
		local E, splitMessage = ElvUI[1]
		for _ = 1, ceil(msgLength/maxChar) do
			splitMessage = strmatch(strsub(message, 1, maxChar), '.+;')
			if splitMessage then -- incase the string is over 250 but doesnt contain `;`
				message = gsub(message, "^"..gsub(splitMessage, '([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'), "")
				E:Delay(delay, C_ChatInfo_SendAddonMessage, lib.prefix, splitMessage, ChatType, Channel)
				delay = delay + 1
				E:Delay(delay, lib.ClearSendMessageTimer) -- keep this after `delay = delay + 1`
			end
		end
	else
		C_ChatInfo_SendAddonMessage(lib.prefix, message, ChatType, Channel)
		lib.ClearSendMessageTimer()
	end
end

lib:RegisterPlugin(MAJOR, lib.GetPluginOptions)
