local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))

E.Options.args.tagGroup = {
	order = 925,
	type = "group",
	name = L["Available Tags"],
	args = {
		header = {
			order = 1,
			type = "header",
			name = L["Available Tags"],
		},
		general = {
			order = 2,
			type = "group",
			name = "",
			guiInline = true,
			childGroups = 'tab',
			args = {},
		},
	}
}


for Tag in next, E.oUF.Tags.Events do
	if not E.TagInfo[Tag] then
		E.TagInfo[Tag] = { category = 'Miscellanous', description = "" }
		--E:Print("['"..Tag.."'] = { category = 'Miscellanous', description = '' }")
	end

	if not E.Options.args.tagGroup.args.general.args[E.TagInfo[Tag].category] then
		E.Options.args.tagGroup.args.general.args[E.TagInfo[Tag].category] = {
			order = 925,
			type = "group",
			name = E.InfoColor..E.TagInfo[Tag].category,
			args = {}
		}
	end

	E.Options.args.tagGroup.args.general.args[E.TagInfo[Tag].category].args[Tag] = {
		type = "description",
		fontSize = "medium",
		name = format('[%s] - %s', Tag, E.TagInfo[Tag].description),
	}
end
