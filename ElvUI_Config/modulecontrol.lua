local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local NP = E:GetModule("NamePlates")
local CP = E:GetModule('CopyProfile')

E.Options.args.modulecontrol= {
	order = -2,
	type = "group",
	name = L["Module Control"],
	childGroups = "tab",
	args = {
		modulereset = {
			type = "group",
			name = L["Module Reset"],
			order = 1,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Module Reset"],
				},
				intro = {
					order = 1,
					type = "description",
					name = L["This section will help reset specfic settings back to default."],
				},
				space1 = {
					order = 2,
					type = "description",
					name = "",
				},
				general = {
					order = 3,
					type = 'execute',
					name = L["General"],
					confirm = true,
					confirmText = L["Are you sure you want to reset General settings?"],
					func = function() E:CopyTable(E.db.general, P.general) end,
				},
				actionbar = {
					order = 5,
					type = 'execute',
					name = L["ActionBars"],
					confirm = true,
					confirmText = L["Are you sure you want to reset ActionBars settings?"],
					func = function() E:CopyTable(E.db.actionbar, P.actionbar) end,
				},
				bags = {
					order = 6,
					type = 'execute',
					name = L["Bags"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Bags settings?"],
					func = function() E:CopyTable(E.db.bags, P.bags) end,
				},
				auras = {
					order = 7,
					type = 'execute',
					name = L["Auras"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Auras settings?"],
					func = function() E:CopyTable(E.db.auras, P.auras) end,
				},
				chat = {
					order = 8,
					type = 'execute',
					name = L["Chat"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Chat settings?"],
					func = function() E:CopyTable(E.db.chat, P.chat) end,
				},
				cooldown = {
					order = 9,
					type = 'execute',
					name = L["Cooldown Text"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Cooldown settings?"],
					func = function() E:CopyTable(E.db.cooldown, P.cooldown) end,
				},
				databars = {
					order = 10,
					type = 'execute',
					name = L["DataBars"],
					confirm = true,
					confirmText = L["Are you sure you want to reset DataBars settings?"],
					func = function() E:CopyTable(E.db.databars, P.databars) end,
				},
				datatexts = {
					order = 11,
					type = 'execute',
					name = L["DataTexts"],
					confirm = true,
					confirmText = L["Are you sure you want to reset DataTexts settings?"],
					func = function() E:CopyTable(E.db.datatexts, P.datatexts) end,
				},
				nameplates = {
					order = 12,
					type = 'execute',
					name = L["NamePlates"],
					confirm = true,
					confirmText = L["Are you sure you want to reset NamePlates settings?"],
					func = function() E:CopyTable(E.db.nameplates, P.nameplates) end,
				},
				tooltip = {
					order = 13,
					type = 'execute',
					name = L["Tooltip"],
					confirm = true,
					confirmText = L["Are you sure you want to reset Tooltip settings?"],
					func = function() E:CopyTable(E.db.tooltip, P.tooltip) end,
				},
				uniframes = {
					order = 14,
					type = 'execute',
					name = L["UnitFrames"],
					confirm = true,
					confirmText = L["Are you sure you want to reset UnitFrames settings?"],
					func = function() E:CopyTable(E.db.unitframe, P.unitframe); UF:Update_AllFrames() end,
				},
			},
		},
		modulecopy = {
			type = "group",
			name = L["Module Copy"],
			order = 2,
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
					set = function(info, value) E.global.profileCopy.selected = value end,
					-- values = E.Options.args.profiles.args.choose.values,
					values = E.Options.args.profiles.args.copyfrom.values,
					disabled = E.Options.args.profiles.args.copyfrom.disabled,
					arg = E.Options.args.profiles.args.copyfrom.arg,
				},
				elvui = {
					order = 10,
					type = 'group',
					name = E.title,
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
				movers = {
					order = 20,
					type = 'group',
					name = L["Movers"],
					desc = L["On screen positions for different elements."],
					childGroups = "tab",
					disabled = E.Options.args.profiles.args.copyfrom.disabled,
					args = CP:CreateMoversConfigGroup(),
				},
			},
		},
	},
}

--Actionbars
for i = 1, 6 do
	E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.actionbar.args["bar"..i] = {
		order = i+1,
		type = "toggle",
		name = L["Bar "]..i,
		get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
	}
end
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.actionbar.args.barPet = {
	order = 8,
	type = "toggle",
	name = L["Pet Bar"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.actionbar.args.stanceBar = {
	order = 9,
	type = "toggle",
	name = L["Stance Bar"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.actionbar.args.microbar = {
	order = 10,
	type = "toggle",
	name = L["Micro Bar"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.actionbar.args.extraActionButton = {
	order = 11,
	type = "toggle",
	name = L["Boss Button"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.actionbar.args.cooldown = {
	order = 12,
	type = "toggle",
	name = L["Cooldown Text"],
	get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
}
--Auras
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.auras.args.buffs = {
	order = 2,
	type = "toggle",
	name = L["Buffs"],
	get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
}
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.auras.args.debuffs = {
	order = 3,
	type = "toggle",
	name = L["Debuffs"],
	get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
}
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.auras.args.cooldown = {
	order = 4,
	type = "toggle",
	name = L["Cooldown Text"],
	get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
}
--Bags
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.bags.args.bagBar = {
	order = 2,
	type = "toggle",
	name = L["Bag-Bar"],
	get = function(info) return E.global.profileCopy.bags[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.bags[ info[#info] ] = value; end
}
E.Options.args.modulecontrol.args.modulecopy.args.elvui.args.bags.args.cooldown = {
	order = 3,
	type = "toggle",
	name = L["Cooldown Text"],
	get = function(info) return E.global.profileCopy.bags[ info[#info] ] end,
	set = function(info, value) E.global.profileCopy.bags[ info[#info] ] = value; end
}