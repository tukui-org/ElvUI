local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local UF = E:GetModule('UnitFrames')
local MC = E:GetModule('ModuleCopy')

--Actionbars
local function CreateActionbarsConfig()
	local config = MC:CreateModuleConfigGroup(L["ActionBars"], "actionbar")
	for i = 1, 6 do
		config.args["bar"..i] = {
			order = i+1,
			type = "toggle",
			name = L["Bar "]..i,
			get = function(info) return E.global.profileCopy.actionbar[info[#info]] end,
			set = function(info, value) E.global.profileCopy.actionbar[info[#info]] = value; end
		}
	end
	config.args.barPet = {
		order = 8,
		type = "toggle",
		name = L["Pet Bar"],
		get = function(info) return E.global.profileCopy.actionbar[info[#info]] end,
		set = function(info, value) E.global.profileCopy.actionbar[info[#info]] = value; end
	}
	config.args.stanceBar = {
		order = 9,
		type = "toggle",
		name = L["Stance Bar"],
		get = function(info) return E.global.profileCopy.actionbar[info[#info]] end,
		set = function(info, value) E.global.profileCopy.actionbar[info[#info]] = value; end
	}
	config.args.microbar = {
		order = 10,
		type = "toggle",
		name = L["Micro Bar"],
		get = function(info) return E.global.profileCopy.actionbar[info[#info]] end,
		set = function(info, value) E.global.profileCopy.actionbar[info[#info]] = value; end
	}
	config.args.extraActionButton = {
		order = 11,
		type = "toggle",
		name = L["Boss Button"],
		get = function(info) return E.global.profileCopy.actionbar[info[#info]] end,
		set = function(info, value) E.global.profileCopy.actionbar[info[#info]] = value; end
	}
	config.args.cooldown = {
		order = 12,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.actionbar[info[#info]] end,
		set = function(info, value) E.global.profileCopy.actionbar[info[#info]] = value; end
	}

	return config
end

--Auras
local function CreateAurasConfig()
	local config = MC:CreateModuleConfigGroup(L["Auras"], "auras")
	config.args.buffs = {
		order = 2,
		type = "toggle",
		name = L["Buffs"],
		get = function(info) return E.global.profileCopy.auras[info[#info]] end,
		set = function(info, value) E.global.profileCopy.auras[info[#info]] = value; end
	}
	config.args.debuffs = {
		order = 3,
		type = "toggle",
		name = L["Debuffs"],
		get = function(info) return E.global.profileCopy.auras[info[#info]] end,
		set = function(info, value) E.global.profileCopy.auras[info[#info]] = value; end
	}
	config.args.cooldown = {
		order = 4,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.auras[info[#info]] end,
		set = function(info, value) E.global.profileCopy.auras[info[#info]] = value; end
	}

	return config
end

--Bags
local function CreateBagsConfig()
	local config = MC:CreateModuleConfigGroup(L["Bags"], "bags")
	config.args.bagBar = {
		order = 2,
		type = "toggle",
		name = L["Bag-Bar"],
		get = function(info) return E.global.profileCopy.bags[info[#info]] end,
		set = function(info, value) E.global.profileCopy.bags[info[#info]] = value; end
	}
	config.args.cooldown = {
		order = 3,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.bags[info[#info]] end,
		set = function(info, value) E.global.profileCopy.bags[info[#info]] = value; end
	}
	config.args.split = {
		order = 4,
		type = "toggle",
		name = L["Split"],
		get = function(info) return E.global.profileCopy.bags[info[#info]] end,
		set = function(info, value) E.global.profileCopy.bags[info[#info]] = value; end
	}
	config.args.vendorGrays = {
		order = 5,
		type = "toggle",
		name = L["Vendor Grays"],
		get = function(info) return E.global.profileCopy.bags[info[#info]] end,
		set = function(info, value) E.global.profileCopy.bags[info[#info]] = value; end
	}

	return config
end

--Chat
local function CreateChatConfig()
	local config = MC:CreateModuleConfigGroup(L["Chat"], "chat")

	return config
end

--Cooldowns
local function CreateCooldownConfig()
	local config = MC:CreateModuleConfigGroup(L["Cooldown Text"], "cooldown")
	config.args.fonts = {
		order = 2,
		type = "toggle",
		name = L["Fonts"],
		get = function(info) return E.global.profileCopy.cooldown[info[#info]] end,
		set = function(info, value) E.global.profileCopy.cooldown[info[#info]] = value; end
	}

	return config
end

--DataBars
local function CreateDatatbarsConfig()
	local config = MC:CreateModuleConfigGroup(L["DataBars"], "databars")

	config.args.experience = {
		order = 2,
		type = "toggle",
		name = L.XPBAR_LABEL,
		get = function(info) return E.global.profileCopy.databars[info[#info]] end,
		set = function(info, value) E.global.profileCopy.databars[info[#info]] = value; end
	}
	config.args.reputation = {
		order = 3,
		type = "toggle",
		name = L.REPUTATION,
		get = function(info) return E.global.profileCopy.databars[info[#info]] end,
		set = function(info, value) E.global.profileCopy.databars[info[#info]] = value; end
	}
	config.args.honor = {
		order = 4,
		type = "toggle",
		name = L.HONOR,
		get = function(info) return E.global.profileCopy.databars[info[#info]] end,
		set = function(info, value) E.global.profileCopy.databars[info[#info]] = value; end
	}
	config.args.azerite = {
		order = 5,
		type = "toggle",
		name = L["Azerite Bar"],
		get = function(info) return E.global.profileCopy.databars[info[#info]] end,
		set = function(info, value) E.global.profileCopy.databars[info[#info]] = value; end
	}

	return config
end

--DataTexts
local function CreateDatatextsConfig()
	local config = MC:CreateModuleConfigGroup(L["DataTexts"], "datatexts")
	config.args.panels = {
		order = 2,
		type = "toggle",
		name = L["Panels"],
		get = function(info) return E.global.profileCopy.datatexts[info[#info]] end,
		set = function(info, value) E.global.profileCopy.datatexts[info[#info]] = value; end
	}

	return config
end

--General
local function CreateGeneralConfig()
	local config = MC:CreateModuleConfigGroup(L["General"], "general")
	config.args.altPowerBar = {
		order = 2,
		type = "toggle",
		name = L["Alternative Power"],
		get = function(info) return E.global.profileCopy.general[info[#info]] end,
		set = function(info, value) E.global.profileCopy.general[info[#info]] = value; end
	}
	config.args.minimap = {
		order = 3,
		type = "toggle",
		name = L.MINIMAP_LABEL,
		get = function(info) return E.global.profileCopy.general[info[#info]] end,
		set = function(info, value) E.global.profileCopy.general[info[#info]] = value; end
	}
	config.args.threat = {
		order = 4,
		type = "toggle",
		name = L["Threat"],
		get = function(info) return E.global.profileCopy.general[info[#info]] end,
		set = function(info, value) E.global.profileCopy.general[info[#info]] = value; end
	}
	config.args.totems = {
		order = 5,
		type = "toggle",
		name = L["Class Totems"],
		get = function(info) return E.global.profileCopy.general[info[#info]] end,
		set = function(info, value) E.global.profileCopy.general[info[#info]] = value; end
	}
	config.args.itemLevel = {
		order = 6,
		type = "toggle",
		name = L["Item Level"],
		get = function(info) return E.global.profileCopy.general[info[#info]] end,
		set = function(info, value) E.global.profileCopy.general[info[#info]] = value; end
	}
	config.args.altPowerBar = {
		order = 7,
		type = "toggle",
		name = L["Alternative Power"],
		get = function(info) return E.global.profileCopy.general[info[#info]] end,
		set = function(info, value) E.global.profileCopy.general[info[#info]] = value; end
	}

	return config
end

--NamePlates
local function CreateNamePlatesConfig()
	local config = MC:CreateModuleConfigGroup(L["NamePlates"], "nameplates")
	config.args.cooldown = {
		order = 2,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.nameplates[info[#info]] end,
		set = function(info, value) E.global.profileCopy.nameplates[info[#info]] = value; end
	}
	config.args.threat = {
		order = 6,
		type = "toggle",
		name = L["Threat"],
		get = function(info) return E.global.profileCopy.nameplates[info[#info]] end,
		set = function(info, value) E.global.profileCopy.nameplates[info[#info]] = value; end
	}
	config.args.units = {
		order = 7,
		type = "group",
		guiInline = true,
		name = L["NamePlates"],
		get = function(info) return E.global.profileCopy.nameplates[info[#info-1]][info[#info]] end,
		set = function(info, value) E.global.profileCopy.nameplates[info[#info-1]][info[#info]] = value; end,
		args = {
			["PLAYER"] = {
				order = 1,
				type = "toggle",
				name = L["Player"],
			},
			["TARGET"] = {
				order = 2,
				type = "toggle",
				name = L["Target"],
			},
			["FRIENDLY_PLAYER"] = {
				order = 3,
				type = "toggle",
				name = L["FRIENDLY_PLAYER"],
			},
			["ENEMY_PLAYER"] = {
				order = 4,
				type = "toggle",
				name = L["ENEMY_PLAYER"],
			},
			["FRIENDLY_NPC"] = {
				order = 5,
				type = "toggle",
				name = L["FRIENDLY_NPC"],
			},
			["ENEMY_NPC"] = {
				order = 6,
				type = "toggle",
				name = L["ENEMY_NPC"],
			},
		},
	}

	return config
end

--Tooltip
local function CreateTooltipConfig()
	local config = MC:CreateModuleConfigGroup(L["Tooltip"], "tooltip")
	config.args.visibility = {
		order = 2,
		type = "toggle",
		name = L["Visibility"],
		get = function(info) return E.global.profileCopy.tooltip[info[#info]] end,
		set = function(info, value) E.global.profileCopy.tooltip[info[#info]] = value; end
	}
	config.args.healthBar = {
		order = 3,
		type = "toggle",
		name =L["Health Bar"],
		get = function(info) return E.global.profileCopy.tooltip[info[#info]] end,
		set = function(info, value) E.global.profileCopy.tooltip[info[#info]] = value; end
	}

	return config
end

--UnitFrames
local function CreateUnitframesConfig()
	local config = MC:CreateModuleConfigGroup(L["UnitFrames"], "unitframe")
	config.args.cooldown = {
		order = 2,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.unitframe[info[#info]] end,
		set = function(info, value) E.global.profileCopy.unitframe[info[#info]] = value; end
	}
	config.args.colors = {
		order = 3,
		type = "group",
		guiInline = true,
		name = L.COLORS,
		get = function(info) return E.global.profileCopy.unitframe[info[#info-1]][info[#info]] end,
		set = function(info, value) E.global.profileCopy.unitframe[info[#info-1]][info[#info]] = value; end,
		args = {
			["general"] = {
				order = 1,
				type = "toggle",
				name = L["General"],
			},
			["power"] = {
				order = 2,
				type = "toggle",
				name = L["Powers"],
			},
			["reaction"] = {
				order = 3,
				type = "toggle",
				name = L["Reactions"],
			},
			["healPrediction"] = {
				order = 4,
				type = "toggle",
				name = L["Heal Prediction"],
			},
			["classResources"] = {
				order = 5,
				type = "toggle",
				name = L["Class Resources"],
			},
			["frameGlow"] = {
				order = 6,
				type = "toggle",
				name = L["Frame Glow"],
			},
			["debuffHighlight"] = {
				order = 7,
				type = "toggle",
				name = L["Debuff Highlighting"],
			},
		},
	}
	config.args.units = {
		order = 4,
		type = "group",
		guiInline = true,
		name = L["UnitFrames"],
		get = function(info) return E.global.profileCopy.unitframe[info[#info-1]][info[#info]] end,
		set = function(info, value) E.global.profileCopy.unitframe[info[#info-1]][info[#info]] = value; end,
		args = {
			["player"] = {
				order = 1,
				type = "toggle",
				name = L["Player"],
			},
			["target"] = {
				order = 2,
				type = "toggle",
				name = L["Target"],
			},
			["targettarget"] = {
				order = 3,
				type = "toggle",
				name = L["TargetTarget"],
			},
			["targettargettarget"] = {
				order = 4,
				type = "toggle",
				name = L["TargetTargetTarget"],
			},
			["focus"] = {
				order = 5,
				type = "toggle",
				name = L["Focus"],
			},
			["focustarget"] = {
				order = 6,
				type = "toggle",
				name = L["FocusTarget"],
			},
			["pet"] = {
				order = 7,
				type = "toggle",
				name = L.PET,
			},
			["pettarget"] = {
				order = 8,
				type = "toggle",
				name = L["PetTarget"],
			},
			["boss"] = {
				order = 9,
				type = "toggle",
				name = L["Boss"],
			},
			["arena"] = {
				order = 10,
				type = "toggle",
				name = L["Arena"],
			},
			["party"] = {
				order = 11,
				type = "toggle",
				name = L.PARTY,
			},
			["raid"] = {
				order = 12,
				type = "toggle",
				name = L["Raid"],
			},
			["raid40"] = {
				order = 13,
				type = "toggle",
				name = L["Raid-40"],
			},
			["raidpet"] = {
				order = 14,
				type = "toggle",
				name = L["Raid Pet"],
			},
			["tank"] = {
				order = 15,
				type = "toggle",
				name = L.TANK,
			},
			["assist"] = {
				order = 16,
				type = "toggle",
				name = L["Assist"],
			},
		},
	}

	return config
end

E.Options.args.modulecontrol= {
	order = -2,
	type = "group",
	name = L["Module Control"],
	childGroups = "tab",
	args = {
		modulecopy = {
			type = "group",
			name = L["Module Copy"],
			order = 1,
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
						actionbar = CreateActionbarsConfig(),
						auras = CreateAurasConfig(),
						bags = CreateBagsConfig(),
						chat = CreateChatConfig(),
						cooldown = CreateCooldownConfig(),
						databars = CreateDatatbarsConfig(),
						datatexts = CreateDatatextsConfig(),
						general = CreateGeneralConfig(),
						nameplates = CreateNamePlatesConfig(),
						tooltip = CreateTooltipConfig(),
						uniframes = CreateUnitframesConfig(),
					},
				},
				movers = {
					order = 20,
					type = 'group',
					name = L["Movers"],
					desc = L["On screen positions for different elements."],
					childGroups = "tab",
					disabled = E.Options.args.profiles.args.copyfrom.disabled,
					args = MC:CreateMoversConfigGroup(),
				},
			},
		},
		modulereset = {
			type = "group",
			name = L["Module Reset"],
			order = 2,
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
	},
}
