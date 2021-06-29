local MAJOR, MINOR = "LibElvUIPlugin-1.0", 38
local lib = _G.LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end
-- GLOBALS: ElvUI

--[[----------------------------
Plugin Table Format:  (for reference only).
	{
		name		- name of the plugin
		callback	- callback to call when ElvUI_OptionsUI is loaded
		isLib		- plugin is a library
		version		- version of the plugin (pulls version info from metadata, libraries can define their own)

	-- After new version recieved from another user:
		old			- plugin is old version
		newversion	- newer version number
	}

LibElvUIPlugin API:
	RegisterPlugin(name, callback, isLib, libVersion)
	-- Registers a module with the given name and option callback:
		name		- name of plugin
		verion		- version number
		isLib		- plugin is a library
		libVersion	- plugin library version (optional, defaults to 1)

	HookInitialize(table, function)
	-- Posthook ElvUI Initialize function:
		table		- addon table
		function	- function to call after Initialize (may be a string, that exists on the addons table: table['string'])
----------------------------]]--

local tonumber, strmatch, strsub, tinsert, strtrim = tonumber, strmatch, strsub, tinsert, strtrim
local assert, pairs, ipairs, strlen, pcall = assert, pairs, ipairs, strlen, pcall
local format, wipe, type, gmatch, gsub, ceil = format, wipe, type, gmatch, gsub, ceil

local hooksecurefunc = hooksecurefunc
local GetAddOnMetadata = GetAddOnMetadata
local GetNumGroupMembers = GetNumGroupMembers
local GetLocale, IsInGuild = GetLocale, IsInGuild
local CreateFrame, IsAddOnLoaded = CreateFrame, IsAddOnLoaded
local IsInRaid, IsInGroup = IsInRaid, IsInGroup
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local UNKNOWN = UNKNOWN

lib.prefix = "ElvUIPluginVC"
lib.plugins = {}
lib.groupSize = 0
lib.index = 0

local MSG_OUTDATED = "Your version of %s %s is out of date (latest is version %s). You can download the latest version from http://www.tukui.org"
local HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins Loaded  (Green means you have current version, Red means out of date)"
local INFO_BY = "by"
local INFO_VERSION = "Version:"
local INFO_NEW = "Newest:"
local LIBRARY = "Library"

local locale = GetLocale()
if locale == "deDE" then
	MSG_OUTDATED = "Deine Version von %s %s ist veraltet (akutelle Version ist %s). Du kannst die aktuelle Version von http://www.tukui.org herunterrladen."
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - Plugins geladen (Grün bedeutet du hast die aktuelle Version, Rot bedeutet es ist veraltet)"
	INFO_BY = "von"
	INFO_VERSION = "Version:"
	INFO_NEW = "Neuste:"
	LIBRARY = "Bibliothek"
elseif locale == "ruRU" then
	MSG_OUTDATED = "Ваша версия %s %s устарела (последняя версия %s). Вы можете скачать последнюю версию на http://www.tukui.org"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - загруженные плагины (зеленый означает, что у вас последняя версия, красный - устаревшая)"
	INFO_BY = "от"
	INFO_VERSION = "Версия:"
	INFO_NEW = "Последняя:"
	LIBRARY = "Библиотека"
elseif locale == "zhCN" then
	MSG_OUTDATED = "你的 %s %s 版本已经过期 (最新版本是 %s)。你可以从 http://www.tukui.org 下载最新版本"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - 载入的插件 (绿色表示拥有当前版本, 红色表示版本已经过期)"
	INFO_BY = "作者"
	INFO_VERSION = "版本:"
	INFO_NEW = "最新:"
	LIBRARY = "库"
elseif locale == "zhTW" then
	MSG_OUTDATED = "你的 %s %s 版本已經過期 (最新版本為 %s)。你可以透過 http://www.tukui.org 下載最新的版本"
	HDR_INFORMATION = "LibElvUIPlugin-1.0.%d - 載入的插件 (綠色表示擁有當前版本, 紅色表示版本已經過期)"
	INFO_BY = "作者"
	INFO_VERSION = "版本:"
	INFO_NEW = "最新:"
	LIBRARY = "庫"
end

local E, L
local function checkElvUI()
	if not E then
		if ElvUI then
			E = ElvUI[1]
			L = ElvUI[2]
		end

		assert(E, "ElvUI not found.")
	end
end

function lib:RegisterPlugin(name, callback, isLib, libVersion)
	checkElvUI()

	local plugin = {
		name = name,
		callback = callback,
		title = GetAddOnMetadata(name, "Title"),
		author = GetAddOnMetadata(name, "Author")
	}

	if plugin.title then plugin.title = strtrim(plugin.title) end
	if plugin.author then plugin.author = strtrim(plugin.author) end

	if isLib then
		plugin.isLib = true
		plugin.version = libVersion or 1
	else
		plugin.version = (name == MAJOR and MINOR) or GetAddOnMetadata(name, "Version") or UNKNOWN
	end

	lib.plugins[name] = plugin

	if not lib.registeredPrefix then
		C_ChatInfo_RegisterAddonMessagePrefix(lib.prefix)
		lib.VCFrame:RegisterEvent("CHAT_MSG_ADDON")
		lib.VCFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
		lib.VCFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		lib.registeredPrefix = true
	end

	local loaded = IsAddOnLoaded("ElvUI_OptionsUI")
	if not loaded then
		lib.CFFrame:RegisterEvent("ADDON_LOADED")
	elseif loaded then
		if name ~= MAJOR then
			E.Options.args.plugins.args.plugins.name = lib:GeneratePluginList()
		end

		if callback then
			pcall(callback)
		end
	end

	return plugin
end

local function SendVersionCheckMessage()
	lib:SendPluginVersionCheck(lib:GenerateVersionCheckMessage())
end

function lib:DelayedSendVersionCheck(delay)
	if not E.SendPluginVersionCheck then
		E.SendPluginVersionCheck = SendVersionCheckMessage
	end

	if not lib.SendMessageWaiting then
		lib.SendMessageWaiting = E:Delay(delay or 10, E.SendPluginVersionCheck)
	end
end

function lib:OptionsUILoaded(_, addon)
	if addon == "ElvUI_OptionsUI" then
		lib:GetPluginOptions()

		for _, plugin in pairs(lib.plugins) do
			if plugin.callback then
				pcall(plugin.callback)
			end
		end

		lib.CFFrame:UnregisterEvent("ADDON_LOADED")
	end
end

function lib:GenerateVersionCheckMessage()
	local list = ""
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			list = list .. plugin.name .. "=" .. plugin.version .. ";"
		end
	end
	return list
end

function lib:GetPluginOptions()
	E.Options.args.plugins = {
		order = 3,
		type = "group",
		name = L["Plugins"],
		inline = false,
		args = {
			pluginheader = E.Libs.ACH:Header(format(HDR_INFORMATION, MINOR), 1),
			plugins = {
				order = 2,
				type = "description",
				name = lib:GeneratePluginList()
			}
		}
	}
end

do	-- this will handle `8.1.5.0015` into `8.150015` etc
	local verStrip = function(a, b) return a..gsub(b,'%.', '') end
	function lib:StripVersion(version)
		local ver = gsub(version, '(%d-%.)([%d%.]+)', verStrip)
		return tonumber(ver)
	end
end

function lib:VersionCheck(event, prefix, message, _, sender)
	if (event == "CHAT_MSG_ADDON" and prefix == lib.prefix) and (sender and message and not strmatch(message, "^%s-$")) then
		if not lib.myName then lib.myName = format('%s-%s', E.myname, E:ShortenRealm(E.myrealm)) end
		if sender == lib.myName then return end

		if not E.pluginRecievedOutOfDateMessage then
			for name, version in gmatch(message, "([^=]+)=([%d%p]+);") do
				local plugin = (version and name) and lib.plugins[name]
				if plugin and plugin.version then
					local Pver, ver = lib:StripVersion(plugin.version), lib:StripVersion(version)
					if (ver and Pver) and (ver > Pver) then
						plugin.old, plugin.newversion = true, version
						E:Print(format(MSG_OUTDATED, plugin.title or plugin.name, plugin.version, plugin.newversion))
						E.pluginRecievedOutOfDateMessage = true
					end
				end
			end
		end
	elseif event == "GROUP_ROSTER_UPDATE" then
		local num = GetNumGroupMembers()
		if num ~= lib.groupSize then
			if num > 1 and num > lib.groupSize then
				lib:DelayedSendVersionCheck()
			end
			lib.groupSize = num
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		lib:DelayedSendVersionCheck()
	end
end

function lib:GeneratePluginList()
	local list = ""
	for _, plugin in pairs(lib.plugins) do
		if plugin.name ~= MAJOR then
			local color = (plugin.old and E:RGBToHex(1, 0, 0)) or E:RGBToHex(0, 1, 0)
			list = list .. (plugin.title or plugin.name)
			if plugin.author then list = list .. " " .. INFO_BY .. " " .. plugin.author end
			list = list .. color .. (plugin.isLib and " " .. LIBRARY or " - " .. INFO_VERSION .. " " .. plugin.version)
			if plugin.old then list = list .. " (" .. INFO_NEW .. plugin.newversion .. ")" end
			list = list .. "|r\n"
		end
	end
	return list
end

function lib:ClearSendMessageWait()
	lib.SendMessageWaiting = nil
end

function lib:SendPluginVersionCheck(message)
	if (not message) or strmatch(message, "^%s-$") then
		lib.ClearSendMessageWait()
		return
	end

	local ChatType
	if IsInRaid() then
		ChatType = (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID"
	elseif IsInGroup() then
		ChatType = (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY"
	elseif IsInGuild() then
		ChatType = "GUILD"
	end

	if not ChatType then
		lib.ClearSendMessageWait()
		return
	end

	local delay, maxChar, msgLength = 0, 250, strlen(message)
	if msgLength > maxChar then
		local splitMessage
		for _ = 1, ceil(msgLength / maxChar) do
			splitMessage = strmatch(strsub(message, 1, maxChar), ".+;")
			if splitMessage then -- incase the string is over 250 but doesnt contain `;`
				message = gsub(message, "^" .. E:EscapeString(splitMessage), "")
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

function lib.Initialized()
	if not lib.inits then return end

	for _, initTbl in ipairs(lib.inits) do
		initTbl[2](initTbl[1])
	end

	wipe(lib.inits)
end

function lib:HookInitialize(tbl, func)
	if not (tbl and func) then return end

	if type(func) == "string" then
		func = tbl[func]
	end

	if not self.inits then
		self.inits = {}
		checkElvUI()
		hooksecurefunc(E, "Initialize", self.Initialized)
	end

	tinsert(lib.inits, { tbl, func })
end

lib.VCFrame = CreateFrame("Frame")
lib.VCFrame:SetScript("OnEvent", lib.VersionCheck)

lib.CFFrame = CreateFrame("Frame")
lib.CFFrame:SetScript("OnEvent", lib.OptionsUILoaded)
