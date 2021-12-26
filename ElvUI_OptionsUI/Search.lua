local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.OptionsUI)
local ACH = E.Libs.ACH
local SearchText = ''

local wipe = wipe
local pcall = pcall
local strfind = strfind
local strlower = strlower
local strjoin = strjoin
local strsplit = strsplit

C.SearchCache = {}

E.Options.args.search = ACH:Group(L["Search"], nil, 4, 'tab')
local Search =  E.Options.args.search.args

Search.editbox = ACH:Input(L["Search"], nil, 0, nil, nil, function() return SearchText end, function(_, value) C:ClearSearchResults() SearchText = strlower(value) C:SearchConfig() C:AddSearchResults() end)
Search.results = ACH:Group(L["Results"], nil, 1, 'tree')

local BlockInfoOptions = {
	filters = true,
	info = true,
	plugins = true,
	search = true,
	tagGroup = true,
	modulecontrol = true,
	profiles = true
}

local invalidTypes = {
	description = true,
	header = true
}

local valueTypes = {
	multiselect = true,
	select = true
}

function C:AddSearchResults()
	local resultNum = 1
	for loc, name in pairs(C.SearchCache) do
		local locName = strsplit(',', loc)
		local headerName = E.Options.args[locName].name

		Search.results.args[headerName] = Search.results.args[headerName] or ACH:Group(headerName, nil, E.Options.args[locName].order)
		Search.results.args[headerName].args[''..resultNum] = ACH:Execute(name, nil, nil, function() E.Libs.AceConfigDialog:SelectGroup('ElvUI', strsplit(',', loc)) end, nil, nil, 'full')

		resultNum = resultNum + 1
	end
end

function C:ClearSearchResults()
	wipe(C.SearchCache)
	wipe(Search.results.args)
end

function C:SearchConfig(tbl, loc, locName)
	if SearchText == '' then return end

	for option, infoTable in pairs(tbl or E.Options.args) do
		if not BlockInfoOptions[option] and not invalidTypes[infoTable.type] then
			local name, desc, values
			if type(infoTable.name) == 'function' then
				local success, arg1 = pcall(infoTable.name, option)
				if success then name = arg1 end
			else
				name = infoTable.name
			end
			if type(infoTable.desc) == 'function' then
				local success, arg1 = pcall(infoTable.desc, option)
				if success then desc = arg1 end
			else
				desc = infoTable.desc
			end
			if valueTypes[infoTable.type] and not infoTable.dialogControl then
				if type(infoTable.values) == 'function' then
					local success, arg1 = pcall(infoTable.values, option)
					if success then values = arg1 end
				elseif type(infoTable.values) == 'table' then
					values = infoTable.values
				end
			end

			local location = loc and (not infoTable.inline and strjoin(',', loc, option) or loc) or option
			local locationName = name and (locName and ((name ~= '' and name ~= ' ') and strjoin(' - ', locName, name) or locName) or name)
			if strfind(strlower(name or '\a'), SearchText) or strfind(strlower(desc or '\a'), SearchText) then
				C.SearchCache[location] = locationName
			elseif values then
				for _, subName in next, values do
					if strfind(strlower(subName or '\a'), SearchText) then
						C.SearchCache[location] = locationName
					end
				end
			end
			if type(infoTable) == 'table' and infoTable.args then
				C:SearchConfig(infoTable.args, location, locationName)
			end
		end
	end
end
