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
			name = L["This section will allow you to copy settings to a select module from or to a different profile."],
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
			desc = L["Select a profile to copy from/to."],
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
			desc = L["Core |cfffe7b2cElvUI|r options."],
			childGroups = "tab",
			disabled = E.Options.args.profiles.args.copyfrom.disabled,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Core |cfffe7b2cElvUI|r options."],
				},
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

--Actionbars
for i = 1, 6 do
	E.Options.args.modulecopy.args.elvui.args.actionbar.args["bar"..i] = {
		order = i+1,
		type = "toggle",
		name = L["Bar "]..i,
		get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
	}
end
E.Options.args.modulecopy.args.elvui.args.actionbar.args.barPet = {
	order = 8,
	type = "toggle",
	name = L["Pet Bar"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
E.Options.args.modulecopy.args.elvui.args.actionbar.args.stanceBar = {
	order = 9,
	type = "toggle",
	name = L["Stance Bar"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
E.Options.args.modulecopy.args.elvui.args.actionbar.args.microbar = {
	order = 10,
	type = "toggle",
	name = L["Micro Bar"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
E.Options.args.modulecopy.args.elvui.args.actionbar.args.extraActionButton = {
	order = 11,
	type = "toggle",
	name = L["Boss Button"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
E.Options.args.modulecopy.args.elvui.args.actionbar.args.cooldown = {
	order = 12,
	type = "toggle",
	name = L["Cooldown Text"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
--Auras
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
--Bags
E.Options.args.modulecopy.args.elvui.args.bags.args.bagBar = {
	order = 2,
	type = "toggle",
	name = L["Bag-Bar"],
	get = function(info) return E.global.profileCopy.bags[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.bags[ info[#info] ] = value; end
}
E.Options.args.modulecopy.args.elvui.args.bags.args.cooldown = {
	order = 3,
	type = "toggle",
	name = L["Cooldown Text"],
	get = function(info) return E.global.profileCopy.bags[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.bags[ info[#info] ] = value; end
}
