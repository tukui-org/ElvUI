local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local ACH = E.Libs.ACH

local _G = _G
local format = format

E.Options.args.tagGroup = ACH:Group(L["Available Tags"], nil, 3, 'tab')
E.Options.args.tagGroup.args.GuideLink = ACH:Input(L["Guide:"], nil, 1, nil, nil, function() return "https://www.tukui.org/forum/viewtopic.php?f=9&t=6" end)
E.Options.args.tagGroup.args.GuideLink.customWidth = 310
E.Options.args.tagGroup.args.WikiLink = ACH:Input(L["Wiki:"], nil, 2, nil, nil, function() return "https://git.tukui.org/elvui/elvui/-/wikis/home" end)
E.Options.args.tagGroup.args.WikiLink.customWidth = 290
E.Options.args.tagGroup.args.ColorWheel = ACH:Execute(L["Color Picker"], nil, 3, function() _G.ColorPickerFrame:Show() _G.ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG") _G.ColorPickerFrame:SetClampedToScreen(true) _G.ColorPickerFrame:Raise() end)
E.Options.args.tagGroup.args.ColorWheel.customWidth = 120
E.Options.args.tagGroup.args.Colors = ACH:Group(L["Colors"])
E.Options.args.tagGroup.args.Colors.args.customTagColorInfo  = ACH:Input('Custom color your Text: replace the XXXXXX with a Hex color code', nil, 1, nil, 'full', function() return '||cffXXXXXX [tags] or text here ||r' end)
E.Options.args.tagGroup.args.Names = ACH:Group(L["Names"])
E.Options.args.tagGroup.args.Names.args.nameHealthInfo1 = ACH:Input('|cFF666666[1/5]|r White name text, missing hp red', nil, 1, nil, 'full', function() return '[name:health]' end)
E.Options.args.tagGroup.args.Names.args.nameHealthInfo2 = ACH:Input('|cFF666666[2/5]|r Class color name text, missing hp red', nil, 2, nil, 'full', function() return '[name:health{class}]' end)
E.Options.args.tagGroup.args.Names.args.nameHealthInfo3 = ACH:Input('|cFF666666[3/5]|r Class color name text, missing hp based on hex code', nil, 3, nil, 'full', function() return '[name:health{class:00ff00}]' end)
E.Options.args.tagGroup.args.Names.args.nameHealthInfo4 = ACH:Input('|cFF666666[4/5]|r Name text based on hex code, missing hp red', nil, 4, nil, 'full', function() return '[name:health{00ff00}]' end)
E.Options.args.tagGroup.args.Names.args.nameHealthInfo5 = ACH:Input('|cFF666666[5/5]|r Name text based on hex code, missing hp class color', nil, 5, nil, 'full', function() return '[name:health{00ff00:class}]' end)

local getTag = function(info) return format('[%s]', info[#info]) end

for _, Table in pairs({'Events', 'Methods'}) do
	for Tag in next, E.oUF.Tags[Table] do
		if not E.TagInfo[Tag] then
			E:AddTagInfo(Tag, 'Miscellaneous')
			--E:Print("['"..Tag.."'] = { category = 'Miscellaneous', description = '' }")
		end

		if not E.Options.args.tagGroup.args[E.TagInfo[Tag].category] then
			E.Options.args.tagGroup.args[E.TagInfo[Tag].category] = {
				type = "group",
				name = E.TagInfo[Tag].category,
				args = {}
			}
		end

		E.Options.args.tagGroup.args[E.TagInfo[Tag].category].args[Tag] = E.Options.args.tagGroup.args[E.TagInfo[Tag].category].args[Tag] or {}
		E.Options.args.tagGroup.args[E.TagInfo[Tag].category].args[Tag].type = "input"
		E.Options.args.tagGroup.args[E.TagInfo[Tag].category].args[Tag].name = E.TagInfo[Tag].description
		E.Options.args.tagGroup.args[E.TagInfo[Tag].category].args[Tag].order = E.TagInfo[Tag].order or nil
		E.Options.args.tagGroup.args[E.TagInfo[Tag].category].args[Tag].width = 'full'
		E.Options.args.tagGroup.args[E.TagInfo[Tag].category].args[Tag].get = getTag
	end
end

--[[ THIS SHOULD BE EXECUTED IN THE LAST LOADED CONFIG FILE, AT THE BOTTOM
	NOTE: This is used to make sure Plugins use no less than the options order we want. ]]
E.OriginalOptions = {'plugins'}
for key in pairs(E.Options.args) do table.insert(E.OriginalOptions, key) end
setmetatable(E.OriginalOptions, {__newindex = E.noop})
