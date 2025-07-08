local E, L, V, P, G = unpack(ElvUI)
local CH = E:GetModule('Chat')
local DT = E:GetModule('DataTexts')
local AB = E:GetModule('ActionBars')

local pairs, sort, tonumber, time = pairs, sort, tonumber, time
local type, lower, wipe, next, print = type, strlower, wipe, next, print
local ipairs, format, tinsert = ipairs, format, tinsert
local strmatch, gsub, ceil = strmatch, gsub, math.ceil

local CopyTable = CopyTable
local ReloadUI = ReloadUI

local DisableAddOn = C_AddOns.DisableAddOn
local EnableAddOn = C_AddOns.EnableAddOn
local GetAddOnInfo = C_AddOns.GetAddOnInfo
local GetNumAddOns = C_AddOns.GetNumAddOns

local PlayerClubRequestStatusNone = Enum.PlayerClubRequestStatus.None
local RequestMembershipToClub = C_ClubFinder.RequestMembershipToClub
local GetPlayerClubApplicationStatus = C_ClubFinder.GetPlayerClubApplicationStatus

-- GLOBALS: ElvUIGrid, ElvDB

--------------------------------------------------------------------
-- ELVUI COMMAND FUNCTIONS
--------------------------------------------------------------------

function E:Grid(msg)
	msg = msg and tonumber(msg)
	if type(msg) == 'number' and (msg <= 256 and msg >= 4) then
		E.db.gridSize = msg
		E:Grid_Show()
	elseif ElvUIGrid and ElvUIGrid:IsShown() then
		E:Grid_Hide()
	else
		E:Grid_Show()
	end
end

function E:LuaError(msg)
	local switch = lower(msg)
	if switch == 'on' or switch == '1' then
		local addon = E.Status_Addons
		local bugsack = E.Status_Bugsack

		for i = 1, GetNumAddOns() do
			local name = GetAddOnInfo(i)
			if (not addon[name] and (switch == '1' or not bugsack[name])) and E:IsAddOnEnabled(name) then
				DisableAddOn(name, E.myname)
				ElvDB.DisabledAddOns[name] = i
			end
		end

		E:SetCVar('scriptErrors', 1)
		ReloadUI()
	elseif switch == 'off' or switch == '0' then
		if switch == 'off' then
			E:SetCVar('scriptProfile', 0)
			E:SetCVar('scriptErrors', 0)
			E:Print('Lua errors off.')
		end

		if next(ElvDB.DisabledAddOns) then
			for name in pairs(ElvDB.DisabledAddOns) do
				EnableAddOn(name, E.myname)
			end

			wipe(ElvDB.DisabledAddOns)
			ReloadUI()
		end
	else
		E:Print('/edebug on - /edebug off')
	end
end

do
	local temp = {}
	local list = {}
	local text = ''

	function E:BuildProfilerText(tbl, data, overall)
		local full = not overall or overall == 2
		for _, info in ipairs(tbl) do
			if info.key == '_module' then
				local all = E.Profiler.data._all
				if all then
					local total = info.total or 0
					local percent = (total / all.total) * 100
					text = format('%s%s total: %0.3f count: %d profiler: %0.2f%%\n', text, info.module or '', total, info.count or 0, percent)
				end
			elseif full then
				local total = info.total or 0
				local modulePercent = (total / data._module.total) * 100

				local all, allPercent = E.Profiler.data._all
				if all then
					allPercent = (total / all.total) * 100
				end

				text = format('%s%s:%s time %0.3f avg %0.3f total %0.3f (count: %d module: %0.2f%% profiler: %0.2f%%)\n', text, info.module or '', info.key or '', info.finish or 0, info.average or 0, total, info.count or 0, modulePercent, allPercent or 0)
			end
		end

		if full then
			text = format('%s\n', text)
		end

		wipe(temp)
		wipe(list)
	end

	function E:ProfilerSort(second)
		return self.total > second.total
	end

	function E:SortProfilerData(module, data, overall)
		for key, value in next, data do
			local info = CopyTable(value)
			info.module = module
			info.key = key

			tinsert(temp, info)
		end

		sort(temp, E.ProfilerSort)

		E:BuildProfilerText(temp, data, overall)
	end

	function E:ShowProfilerText()
		if text ~= '' then
			CH.CopyChatFrameEditBox:SetText(text)
			CH.CopyChatFrame:Show()
		end

		text = ''
	end

	function E:GetProfilerData(msg)
		local switch = lower(msg)
		if switch == '' then return end

		local ouf = switch == 'ouf'
		if ouf or switch == 'e' then
			local data = E.Profiler.data[ouf and E.oUF or E]
			if data then
				E:Dump(data, true)
			end
		elseif switch == 'pooler' then
			local data = E.Profiler.data[E.oUF.Pooler]
			if data then
				E:Dump(data, true)
			end
		elseif strmatch(switch, '^ouf%s+') then
			local element = gsub(switch, '^ouf%s+', '')
			if element == '' then return end

			for key, module in next, E.oUF.elements do
				local data = element == lower(key) and E.Profiler.data[module]
				if data then
					E:Dump(data, true)
				end
			end
		else
			for key, module in next, E.modules do
				local data = switch == lower(key) and E.Profiler.data[module]
				if data then
					E:Dump(data, true)
				end
			end
		end
	end

	local function FetchAll(overall)
		if overall == 2 then
			local ouf = E.Profiler.data[E.oUF]
			if ouf then
				E:SortProfilerData('oUF', ouf, overall)
			end

			local private = E.Profiler.oUF_Private -- this is special
			if private then
				E:SortProfilerData('oUF.Private', private, overall)
			end

			local pooler = E.Profiler.data[E.oUF.Pooler]
			if pooler then
				E:SortProfilerData('oUF.Pooler', pooler, overall)
			end

			for key, module in next, E.oUF.elements do
				local info = E.Profiler.data[module]
				if info then
					E:SortProfilerData(key, info, overall)
				end
			end
		else
			local data = E.Profiler.data[E]
			if data then
				E:SortProfilerData('E', data, overall)
			end

			local ouf = overall and E.Profiler.data[E.oUF]
			if ouf then
				E:SortProfilerData('oUF', ouf, overall)
			end

			for key, module in next, E.modules do
				local info = E.Profiler.data[module]
				if info then
					E:SortProfilerData(key, info, overall)
				end
			end
		end
	end

	function E:FetchProfilerData(msg)
		local switch = lower(msg)
		if switch ~= '' then
			if switch == 'on' then
				E.Profiler.state(true)

				return E:Print('Profiler: Enabled')
			elseif switch == 'off' then
				E.Profiler.state(false)

				return E:Print('Profiler: Disabled')
			elseif switch == 'reset' then
				E.Profiler.reset()

				return E:Print('Profiler: Reset')
			elseif switch == 'all' then
				FetchAll(1)
			elseif switch == 'ouf' then
				FetchAll(2)
			elseif switch == 'e' then
				local data = E.Profiler.data[E]
				if data then
					E:SortProfilerData('E', data)
				end
			elseif switch == 'pooler' then
				local data = E.Profiler.data[E.oUF.Pooler]
				if data then
					E:SortProfilerData('oUF.Pooler', data)
				end
			elseif strmatch(switch, '^ouf%s+') then
				local element = gsub(switch, '^ouf%s+', '')
				if element ~= '' then
					for key, module in next, E.oUF.elements do
						local data = element == lower(key) and E.Profiler.data[module]
						if data then
							E:SortProfilerData(key, data)

							break
						end
					end
				end
			else
				for key, module in next, E.modules do
					local data = switch == lower(key) and E.Profiler.data[module]
					if data then
						E:SortProfilerData(key, data)

						break
					end
				end
			end
		else
			FetchAll()
		end

		E:ShowProfilerText()
	end
end

function E:DisplayCommands()
	print(L["EHELP_COMMANDS"])
end

function E:DBConvertProfile()
	E.db.dbConverted = nil
	E:DBConversions()
	ReloadUI()
end

--------------------------------------------------------------------
-- GUILD APPLY COMMANDS
--------------------------------------------------------------------
function E:GuildListSort(second)
	return self.numActiveMembers > second.numActiveMembers
end

function E:ListGuilds(msg)
	if not next(E.guilds) then
		E:Print('Error: No guilds found. Open Guild Finder and search first.')
		return
	end

	local guildList = {}
	for _, guildData in pairs(E.guilds) do
		tinsert(guildList, guildData)
	end

	sort(guildList, E.GuildListSort)

	E:Print('|cff00BFFF--- Sorted Guild List ---|r')

	local cutoff = tonumber(msg)
	for _, guildData in ipairs(guildList) do
		if not cutoff or guildData.numActiveMembers >= cutoff then
			E:Print(format('Guild: %s, Active Members: %d', guildData.name, guildData.numActiveMembers))
		end
	end

	E:Print('|cff00BFFF-------------------------|r')
end

do
	local sortedGuilds = {}
	local appliedGUIDs = {} -- This list resets on every reload.
	local lastApplyTime = 0 -- Tracks the last time /guildapply was used to enforce a cooldown.
	local APPLY_COOLDOWN = 120 -- 2 minutes

	function E:ApplyGuilds(msg)
		local currentTime = time()
		if currentTime - lastApplyTime < APPLY_COOLDOWN then
			local timeLeft = ceil(APPLY_COOLDOWN - (currentTime - lastApplyTime))
			E:Print(format('|cffff0000Guild apply is on cooldown. Please wait %d more seconds.|r', timeLeft))
			return
		elseif not next(E.guilds) then
			E:Print('Error: No guilds found. Open Guild Finder and search first.')
			return
		end

		-- The message is the only argument, in quotes.
		local playerSpecs = E.SpecByClass[E.myclass]
		if not playerSpecs or #playerSpecs == 0 then
			E:Print('Error: Could not retrieve player specializations.')
			return
		end

		-- Sortable list from the scraped guilds.
		wipe(sortedGuilds)

		for _, guildData in next, E.guilds do
			tinsert(sortedGuilds, guildData)
		end

		-- Sort the list by member count, descending.
		sort(sortedGuilds, E.GuildListSort)

		local applyMessage = strmatch(msg, '^"(.-)"$') or 'Hello, I am interested in joining your guild!'

		E:Print('Beginning smart apply...')
		E:Print(format('Using application message: "%s"', applyMessage))

		local appliedCount = 0
		local maxApplications = 5

		-- Loop through the sorted list and apply to new guilds.
		for _, guildData in ipairs(sortedGuilds) do
			local guid = guildData.clubFinderGUID
			local status = (guid and not appliedGUIDs[guid]) and GetPlayerClubApplicationStatus(guid)
			if status == PlayerClubRequestStatusNone then -- This is a new guild we can apply to!
				E:Print(format('|cffffff00Applying to "%s" (%d members)...|r', guildData.name, guildData.numActiveMembers))

				RequestMembershipToClub(guid, applyMessage, playerSpecs)

				-- Record the GUID in our session table so we don't apply again.
				appliedGUIDs[guid] = true
				appliedCount = appliedCount + 1

				-- Stop if we've hit our limit.
				if appliedCount >= maxApplications then
					E:Print('Application limit of 5 reached for this session.')
					break
				end
			end
		end

		-- Only set the cooldown if we actually sent an application.
		if appliedCount > 0 then
			lastApplyTime = currentTime
		end

		if appliedCount == 0 then
			E:Print('|cff00ff00Smart apply complete. No new guilds to apply to in the current list.|r')
		else
			E:Print(format('|cff00ff00Smart apply complete. Sent %d new applications.|r', appliedCount))
		end
	end
end

--------------------------------------------------------------------
-- COMMAND REGISTRATION
--------------------------------------------------------------------
function E:LoadCommands()
	if E.private.actionbar.enable then
		E:RegisterChatCommand('kb', AB.ActivateBindMode)
	end

	E:RegisterChatCommand('ec', 'ToggleOptions')
	E:RegisterChatCommand('elvui', 'ToggleOptions')

	E:RegisterChatCommand('bgstats', DT.ToggleBattleStats)

	E:RegisterChatCommand('moveui', 'ToggleMoveMode')
	E:RegisterChatCommand('resetui', 'ResetUI')

	E:RegisterChatCommand('emove', 'ToggleMoveMode')
	E:RegisterChatCommand('ereset', 'ResetUI')
	E:RegisterChatCommand('edebug', 'LuaError')

	E:RegisterChatCommand('eprofile', 'GetProfilerData') -- temp until we make display window
	E:RegisterChatCommand('eprofiler', 'FetchProfilerData') -- temp until we make display window

	E:RegisterChatCommand('ehelp', 'DisplayCommands')
	E:RegisterChatCommand('ecommands', 'DisplayCommands')
	E:RegisterChatCommand('estatus', 'ShowStatusReport')
	E:RegisterChatCommand('efixdb', 'DBConvertProfile')
	E:RegisterChatCommand('egrid', 'Grid')

	-- Register Guild Apply Commands
	E:RegisterChatCommand('guildlist', 'ListGuilds')
	E:RegisterChatCommand('guildapply', 'ApplyGuilds')
end
