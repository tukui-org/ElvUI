local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CP = E:GetModule('CopyProfile')

E.Options.args.modulecopy = {
	type = "group",
	name = L["Module Copy"],
	order = -2,
	childGroups = "select",
	handler = E.Options.args.profiles.handler,
	args = {
		header = {
			order = 0,
			type = "header",
			name = L["Module Copy"],
		},
		intro = {
			order = 1,
			type = "description",
			name = L["This section will allow you to copy settings to a select module from a different profile."],
		},
		pluginInfo = {
			order = 2,
			type = "description",
			name = L["If you have any plugins supporting this feature installed you can find them in the selection dropdown to the right."],
		},
		profile = {
			order = 3,
			type = "select",
			name = L["Profile"],
			get = function(info) return E.global.profileCopy.selected end,
			set = function(info, value) return E.global.profileCopy.selected == value end,
			-- values = E.Options.args.profiles.args.choose.values,
			values = E.Options.args.profiles.args.copyfrom.values,
			disabled = E.Options.args.profiles.args.copyfrom.disabled,
			arg = E.Options.args.profiles.args.copyfrom.arg,
		},
		elvui = {
			order = 10,
			type = 'group',
			name = "|cfffe7b2cElvUI|r",
			childGroups = "tab",
			disabled = E.Options.args.profiles.args.copyfrom.disabled,
			args = {
				actionbar = CP:CreateModuleConfigGroup(L["ActionBars"], "actionbar"),
				auras = CP:CreateModuleConfigGroup(L["Auras"], "auras"),
				bags = CP:CreateModuleConfigGroup(L["Bags"], "bags"),
				-- chat = CP:CreateModuleConfigGroup(L["Chat"], "chat"),
				-- cooldown = CP:CreateModuleConfigGroup(L["Cooldown Text"], "cooldown"),
				-- databars = CP:CreateModuleConfigGroup(L["DataBars"], "databars"),
				-- datatexts = CP:CreateModuleConfigGroup(L["DataTexts"], "datatexts"),
				-- nameplates = CP:CreateModuleConfigGroup(L["NamePlates"], "nameplates"),
				-- tooltip = CP:CreateModuleConfigGroup(L["Tooltip"], "tooltip"),
				-- uniframes = CP:CreateModuleConfigGroup(L["UnitFrames"], "uniframes"),
			},
		},
	},
}

E.Options.args.modulecopy.args.elvui.args.auras.args.buffs = {
	order = 2,
	type = "toggle",
	name = L["Buffs"],
	get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
}
E.Options.args.modulecopy.args.elvui.args.auras.args.debuffs = {
	order = 3,
	type = "toggle",
	name = L["Debuffs"],
	get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
}
E.Options.args.modulecopy.args.elvui.args.auras.args.cooldown = {
	order = 4,
	type = "toggle",
	name = L["Cooldown Text"],
	get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
}
