local MAJOR, MINOR = 'LibElvUIPlugin-1.0', 27
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

--Lua functions
local pairs, tonumber, strmatch, strsub = pairs, tonumber, strmatch, strsub
local format, gmatch, strlen, gsub, ceil = format, gmatch, strlen, gsub, ceil
--WoW API / Variables
local GetNumGroupMembers = GetNumGroupMembers
local GetLocale, IsInGuild = GetLocale, IsInGuild
local CreateFrame, IsAddOnLoaded = CreateFrame, IsAddOnLoaded
local GetAddOnMetadata = GetAddOnMetadata
local IsInRaid, IsInGroup = IsInRaid, IsInGroup
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
-- GLOBALS: ElvUI

lib.plugins = {}
lib.index = 0
lib.groupSize = 0
lib.prefix = 'ElvUIPluginVC'
------------------------------
local MSG_OUTDATED = "Your version of %s %s is out of date (latest is version %s). You can download the latest version from http://www.tukui.org"
local HDR_CONFIG = "Plugins"
local HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins Loaded  (Green means you have current version, Red means out of date)"
local INFO_BY = "by"
local INFO_VERSION = "Version:"
local INFO_NEW = "Newest:"
local LIBRARY = "Library"

local locale = GetLocale()
if locale == "deDE" then
	MSG_OUTDATED = "Deine Version von %s %s ist veraltet (akutelle Version ist %s). Du kannst die aktuelle Version von http://www.tukui.org herunterrladen."
	HDR_CONFIG = "Plugins"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins geladen (Grün bedeutet du hast die aktuelle Version, Rot bedeutet es ist veraltet)"
	INFO_BY = "von"
	INFO_VERSION = "Version:"
	INFO_NEW = "Neuste:"
	LIBRARY = "Bibliothek"
elseif locale == "ruRU" then
	MSG_OUTDATED = "Ваша версия %s %s устарела (последняя версия %s). Вы можете скачать последнюю версию на http://www.tukui.org"
	HDR_CONFIG = "Плагины"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - загруженные плагины (зеленый означает, что у вас последняя версия, красный - устаревшая)"
	INFO_BY = "от"
	INFO_VERSION = "Версия:"
	INFO_NEW = "Последняя:"
	LIBRARY = "Библиотека"
elseif locale == "zhCN" then
	MSG_OUTDATED = "你的 %s %s 版本已经过期 (最新版本是 %s)。你可以从 http://www.tukui.org 下载最新版本"
	HDR_CONFIG = "插件"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - 载入的插件 (绿色表示拥有当前版本, 红色表示版本已经过期)"
	INFO_BY = "作者"
	INFO_VERSION = "版本:"
	INFO_NEW = "最新:"
	LIBRARY = "库"
elseif locale == "zhTW" then
	MSG_OUTDATED = "你的 %s %s 版本已經過期 (最新版本為 %s)。你可以透過 http://www.tukui.org 下載最新的版本"
	HDR_CONFIG = "插件"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - 載入的插件 (綠色表示擁有當前版本, 紅色表示版本已經過期)"
	INFO_BY = "作者"
	INFO_VERSION = "版本:"
	INFO_NEW = "最新:"
	LIBRARY = "庫"
end

------------------------------
--
-- Plugin table format:
--   { name (string) - The name of the plugin,
--     version (string) - The version of the plugin,
--     optionCallback (string) - The callback to call when ElvUI_OptionsUI is loaded
--   }
--
--
-- RegisterPlugin(name,callback)
--   Registers a module with the given name and option callback, pulls version info from metadata
--
------------------------------
function lib:RegisterPlugin(name, callback, isLib)
	local plugin = {
		name = name,
		callback = callback,
		version = name == MAJOR and MINOR or GetAddOnMetadata(name, 'Version')
	}

	if isLib then
		plugin.isLib = true
		plugin.version = 1
	end

	lib.plugins[name] = plugin

	if not lib.registeredPrefix then
		C_ChatInfo_RegisterAddonMessagePrefix(lib.prefix)
		lib.VCFrame:RegisterEvent('CHAT_MSG_ADDON')
		lib.VCFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
		lib.VCFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
		lib.registeredPrefix = true
	end

	local loaded = IsAddOnLoaded('ElvUI_OptionsUI')
	if not loaded then
		lib.CFFrame:RegisterEvent('ADDON_LOADED')
	elseif loaded then
		-- Need to update plugins list
		if name ~= MAJOR then
			ElvUI[1].Options.args.plugins.args.plugins.name = lib:GeneratePluginList()
		end

		if callback then callback() end
	end

	return plugin
end

local function SendVersionCheckMessage()
	lib:SendPluginVersionCheck(lib:GenerateVersionCheckMessage())
end

function lib:DelayedSendVersionCheck(delay)
	local E = ElvUI[1]

	if not E.SendPluginVersionCheck then
		ElvUI[1].SendPluginVersionCheck = SendVersionCheckMessage
	end

	if not lib.SendMessageWaiting then
		lib.SendMessageWaiting = E:Delay(delay or 10, ElvUI[1].SendPluginVersionCheck)
	end
end

function lib:OptionsUILoaded(_, addon)
	if addon == 'ElvUI_OptionsUI' then
		lib:GetPluginOptions()
		for _, plugin in pairs(lib.plugins) do
			if plugin.callback then
				plugin.callback()
			end
		end
	end
end

function lib:GenerateVersionCheckMessage()
	local list = ''
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			list = list..plugin.name..'='..plugin.version..';'
		end
	end
	return list
end

function lib:GetPluginOptions()
	ElvUI[1].Options.args.plugins = {
		order = -10,
		type = 'group',
		name = HDR_CONFIG,
		guiInline = false,
		args = {
			pluginheader = {
				order = 1,
				type = 'header',
				name = format(HDR_INFORMATION, MINOR),
			},
			plugins = {
				order = 2,
				type = 'description',
				name = lib:GeneratePluginList(),
			},
		}
	}
end

function lib:VersionCheck(event, prefix, message, _, sender)
	local E = ElvUI[1]
	if (event == 'CHAT_MSG_ADDON' and prefix == lib.prefix) and (sender and message and not strmatch(message, '^%s-$')) then
		if not lib.myName then lib.myName = E.myname..'-'..gsub(E.myrealm,'[%s%-]','') end
		if sender == lib.myName then return end

		if not E.pluginRecievedOutOfDateMessage then
			for name, version in gmatch(message, '([^=]+)=([%d%p]+);') do
				local plugin = name and lib.plugins[name]
				if version and plugin and plugin.version and (plugin.version ~= 'BETA') then
					local Pver, ver = tonumber(plugin.version), tonumber(version)
					if (ver and Pver) and (ver > Pver) then
						plugin.old, plugin.newversion = true, ver
						local Pname = GetAddOnMetadata(plugin.name, 'Title')
						E:Print(format(MSG_OUTDATED,Pname,plugin.version,plugin.newversion))
						ElvUI[1].pluginRecievedOutOfDateMessage = true
					end
				end
			end
		end
	elseif event == 'GROUP_ROSTER_UPDATE' then
		local num = GetNumGroupMembers()
		if num ~= lib.groupSize then
			if num > 1 and num > lib.groupSize then
				lib:DelayedSendVersionCheck()
			end
			lib.groupSize = num
		end
	elseif event == 'PLAYER_ENTERING_WORLD' then
		lib:DelayedSendVersionCheck()
	end
end

function lib:GeneratePluginList()
	local E, list = ElvUI[1], ''
	local author, Pname, color
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			author = GetAddOnMetadata(plugin.name, 'Author')
			Pname = GetAddOnMetadata(plugin.name, 'Title') or plugin.name
			color = plugin.old and E:RGBToHex(1,0,0) or E:RGBToHex(0,1,0)
			list = list..Pname
			if author then list = list..' '..INFO_BY..' '..author end
			list = list..color..(plugin.isLib and ' '..LIBRARY or ' - '..INFO_VERSION..' '..plugin.version)
			if plugin.old then list = list..' ('..INFO_NEW..plugin.newversion..')' end
			list = list..'|r\n'
		end
	end
	return list
end

function lib:ClearSendMessageWait()
	lib.SendMessageWaiting = nil
end

function lib:SendPluginVersionCheck(message)
	if (not message) or strmatch(message, '^%s-$') then
		lib.ClearSendMessageWait()
		return
	end

	local ChatType
	if IsInRaid() then
		ChatType = (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'RAID'
	elseif IsInGroup() then
		ChatType = (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and 'INSTANCE_CHAT' or 'PARTY'
	elseif IsInGuild() then
		ChatType = 'GUILD'
	end

	if not ChatType then
		lib.ClearSendMessageWait()
		return
	end

	local delay, maxChar, msgLength = 0, 250, strlen(message)
	if msgLength > maxChar then
		local E, splitMessage = ElvUI[1]
		for _ = 1, ceil(msgLength/maxChar) do
			splitMessage = strmatch(strsub(message, 1, maxChar), '.+;')
			if splitMessage then -- incase the string is over 250 but doesnt contain `;`
				message = gsub(message, '^'..gsub(splitMessage, '([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'), '')
				E:Delay(delay, C_ChatInfo_SendAddonMessage, lib.prefix, splitMessage, ChatType)
				delay = delay + 1
			end
		end

		E:Delay(delay, lib.ClearSendMessageWait)
	else
		C_ChatInfo_SendAddonMessage(lib.prefix, message, ChatType)
		lib.ClearSendMessageWait()
	end
end

lib.VCFrame = CreateFrame('Frame')
lib.VCFrame:SetScript('OnEvent', lib.VersionCheck)

lib.CFFrame = CreateFrame('Frame')
lib.CFFrame:SetScript('OnEvent', lib.OptionsUILoaded)
