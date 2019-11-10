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


for Tag in next, E.oUF.Tags.Methods do
	if not E.TagInfo[Tag] then
		E.TagInfo[Tag] = { category = 'Miscellanous', description = "" }
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

	E.Options.args.tagGroup.args[E.TagInfo[Tag].category].args[Tag] = {
		type = "input",
		name = E.TagInfo[Tag].description,
		order = E.TagInfo[Tag].order or nil,
		width = 'full',
		get = function() return format('[%s]', Tag) end,
	}
end
