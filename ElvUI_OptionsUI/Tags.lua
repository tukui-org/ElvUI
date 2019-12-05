local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))

local format = format

E.Options.args.tagGroup = {
	order = 3,
	type = "group",
	name = L["Available Tags"],
	childGroups = 'tab',
	args = {
		link = {
			order = 1,
			type = "input",
			width = "full",
			name = L["Guide:"],
			get = function() return "https://www.tukui.org/forum/viewtopic.php?f=9&t=6" end,
		},
		header = {
			order = 2,
			type = "header",
			name = L["Available Tags"],
		},
		Colors = {
			type = "group",
			name = 'Colors',
			args = {
				header = {
					order = 0,
					type = "header",
					name = E.InfoColor..'Colors',
				},
				customTagColorInfo = {
					order = 1,
					type = "input",
					width = 'full',
					name = 'Custom color your Text: replace the XXXXXX with a Hex color code',
					get = function() return '||cffXXXXXX [tags] or text here ||r' end
				}
			}
		},
	},
}

local getTag = function(info) return format('[%s]', info[#info]) end

for _, Table in pairs({'Events', 'Methods'}) do
	for Tag in next, E.oUF.Tags[Table] do
		if not E.TagInfo[Tag] then
			E:AddTagInfo(Tag, 'Miscellanous')
			--E:Print("['"..Tag.."'] = { category = 'Miscellanous', description = '' }")
		end

		if not E.Options.args.tagGroup.args[E.TagInfo[Tag].category] then
			E.Options.args.tagGroup.args[E.TagInfo[Tag].category] = {
				type = "group",
				name = E.TagInfo[Tag].category,
				args = {
					header = {
						order = 0,
						type = "header",
						name = E.InfoColor..E.TagInfo[Tag].category,
					}
				}
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
