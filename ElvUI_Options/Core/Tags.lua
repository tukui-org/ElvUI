local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(E.Config)
local ACH = E.Libs.ACH

local _G = _G
local format = format

local TagGroup = ACH:Group(L["Available Tags"], nil, 3)
TagGroup.args.GuideLink = ACH:Input(L["Guide:"], nil, 1, nil, 310, function() return 'https://github.com/tukui-org/ElvUI/wiki/custom-texts' end)
TagGroup.args.WikiLink = ACH:Input(L["Wiki:"], nil, 2, nil, 290, function() return 'https://github.com/tukui-org/ElvUI/wiki' end)
TagGroup.args.ColorWheel = ACH:Execute(L["Color Picker"], nil, 3, function() _G.ColorPickerFrame:Show() _G.ColorPickerFrame:SetFrameStrata('FULLSCREEN_DIALOG') _G.ColorPickerFrame:SetClampedToScreen(true) _G.ColorPickerFrame:Raise() end, nil, nil, 120)
TagGroup.args.description = ACH:Description(L["|cffFF3333This is for information. This will not change the tags in the UI.|r"], 4, 'large')
TagGroup.args.spacer = ACH:Spacer(5)

TagGroup.args.Colors = ACH:Group(L["Colors"])
TagGroup.args.Colors.args.customTagColorInfo = ACH:Input('Color your tag or text by replacing the XXXXXX with a hex color code. (Name tag as red text. Ex: ||cffFF0000[name]||r)', nil, 1, nil, 'full', function() return '||cffXXXXXX [tag] or text here ||r' end)

TagGroup.args.Names = ACH:Group(L["Names"])
TagGroup.args.Names.args.nameHealthInfo1 = ACH:Input('|cFF666666[1/5]|r White name text, missing hp red', nil, 1, nil, 'full', function() return '[name:health]' end)
TagGroup.args.Names.args.nameHealthInfo2 = ACH:Input('|cFF666666[2/5]|r Class color name text, missing hp red', nil, 2, nil, 'full', function() return '[name:health{class}]' end)
TagGroup.args.Names.args.nameHealthInfo3 = ACH:Input('|cFF666666[3/5]|r Class color name text, missing hp based on hex code', nil, 3, nil, 'full', function() return '[name:health{class:00ff00}]' end)
TagGroup.args.Names.args.nameHealthInfo4 = ACH:Input('|cFF666666[4/5]|r Name text based on hex code, missing hp red', nil, 4, nil, 'full', function() return '[name:health{00ff00}]' end)
TagGroup.args.Names.args.nameHealthInfo5 = ACH:Input('|cFF666666[5/5]|r Name text based on hex code, missing hp class color', nil, 5, nil, 'full', function() return '[name:health{00ff00:class}]' end)

local getTag = function(info) return format('[%s]', info[#info]) end
local groups = {}

for _, which in pairs({'Events','OnUpdateThrottle'}) do
	for Tag in next, E.oUF.Tags[which] do
		local info = E.TagInfo[Tag] or E:AddTagInfo(Tag, 'Miscellaneous')

		local group = TagGroup.args[info.category]
		if not group then
			group = { name = info.category, type = 'group', args = {} }
			TagGroup.args[info.category] = group
			groups[info.category] = group
		end

		local input = group.args[Tag] or {}
		input.name = info.description ~= '' and info.description or getTag
		input.order = info.order or nil
		input.width = 'full'
		input.type = 'input'
		input.hidden = info.hidden
		input.get = getTag

		group.args[Tag] = input
	end
end

-- hide groups when all their inputs are hidden
for _, group in pairs(groups) do
	local hide = true
	for _, section in pairs(group.args) do
		if section.type ~= 'input' or not section.hidden then
			hide = false
			break
		end
	end
	if hide then
		group.hidden = true
	end
end

E.Options.args.tagGroup = TagGroup

--[[ THIS SHOULD BE EXECUTED IN THE LAST LOADED CONFIG FILE, AT THE BOTTOM
	NOTE: This is used to make sure Plugins use no less than the options order we want. ]]
E.OriginalOptions = {'plugins'}
for key in pairs(E.Options.args) do table.insert(E.OriginalOptions, key) end
setmetatable(E.OriginalOptions, {__newindex = E.noop})
