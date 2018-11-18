local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local CP = E:GetModule('CopyProfile');

local XPBAR_LABEL, MINIMAP_LABEL = XPBAR_LABEL, MINIMAP_LABEL
local REPUTATION, HONOR, COLORS = REPUTATION, HONOR, COLORS

--Actionbars
local function CreateActionbarsConfig()
	local config = CP:CreateModuleConfigGroup(L["ActionBars"], "actionbar")
	for i = 1, 6 do
		config.args["bar"..i] = {
			order = i+1,
			type = "toggle",
			name = L["Bar "]..i,
			get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
			set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
		}
	end
	config.args.barPet = {
		order = 8,
		type = "toggle",
		name = L["Pet Bar"],
		get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
	}
	config.args.stanceBar = {
		order = 9,
		type = "toggle",
		name = L["Stance Bar"],
		get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
	}
	config.args.microbar = {
		order = 10,
		type = "toggle",
		name = L["Micro Bar"],
		get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
	}
	config.args.extraActionButton = {
		order = 11,
		type = "toggle",
		name = L["Boss Button"],
		get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
	}
	config.args.cooldown = {
		order = 12,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.actionbar[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.actionbar[ info[#info] ] = value; end
	}

	return config
end

--Auras
local function CreateAurasConfig()
	local config = CP:CreateModuleConfigGroup(L["Auras"], "auras")
	config.args.buffs = {
		order = 2,
		type = "toggle",
		name = L["Buffs"],
		get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
	}
	config.args.debuffs = {
		order = 3,
		type = "toggle",
		name = L["Debuffs"],
		get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
	}
	config.args.cooldown = {
		order = 4,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.auras[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.auras[ info[#info] ] = value; end
	}

	return config
end

--Bags
local function CreateBagsConfig()
	local config = CP:CreateModuleConfigGroup(L["Bags"], "bags")
	config.args.bagBar = {
		order = 2,
		type = "toggle",
		name = L["Bag-Bar"],
		get = function(info) return E.global.profileCopy.bags[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.bags[ info[#info] ] = value; end
	}
	config.args.cooldown = {
		order = 3,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.bags[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.bags[ info[#info] ] = value; end
	}
	config.args.split = {
		order = 4,
		type = "toggle",
		name = L["Split"],
		get = function(info) return E.global.profileCopy.bags[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.bags[ info[#info] ] = value; end
	}
	config.args.vendorGrays = {
		order = 5,
		type = "toggle",
		name = L["Vendor Grays"],
		get = function(info) return E.global.profileCopy.bags[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.bags[ info[#info] ] = value; end
	}

	return config
end

--Chat
local function CreateChatConfig()
	local config = CP:CreateModuleConfigGroup(L["Chat"], "chat")

	return config
end

--Cooldowns
local function CreateCooldownConfig()
	local config = CP:CreateModuleConfigGroup(L["Cooldown Text"], "cooldown")
	config.args.fonts = {
		order = 2,
		type = "toggle",
		name = L["Fonts"],
		get = function(info) return E.global.profileCopy.cooldown[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.cooldown[ info[#info] ] = value; end
	}

	return config
end

--DataBars
local function CreateDatatbarsConfig()
	local config = CP:CreateModuleConfigGroup(L["DataBars"], "databars")

	config.args.experience = {
		order = 2,
		type = "toggle",
		name = XPBAR_LABEL,
		get = function(info) return E.global.profileCopy.databars[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.databars[ info[#info] ] = value; end
	}
	config.args.reputation = {
		order = 3,
		type = "toggle",
		name = REPUTATION,
		get = function(info) return E.global.profileCopy.databars[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.databars[ info[#info] ] = value; end
	}
	config.args.honor = {
		order = 4,
		type = "toggle",
		name = HONOR,
		get = function(info) return E.global.profileCopy.databars[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.databars[ info[#info] ] = value; end
	}
	config.args.azerite = {
		order = 5,
		type = "toggle",
		name = L["Azerite Bar"],
		get = function(info) return E.global.profileCopy.databars[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.databars[ info[#info] ] = value; end
	}

	return config
end

--DataTexts
local function CreateDatatextsConfig()
	local config = CP:CreateModuleConfigGroup(L["DataTexts"], "datatexts")
	config.args.panels = {
		order = 2,
		type = "toggle",
		name = L["Panels"],
		get = function(info) return E.global.profileCopy.datatexts[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.datatexts[ info[#info] ] = value; end
	}

	return config
end

--General
local function CreateGeneralConfig()
	local config = CP:CreateModuleConfigGroup(L["General"], "general")
	config.args.altPowerBar = {
		order = 2,
		type = "toggle",
		name = L["Alternative Power"],
		get = function(info) return E.global.profileCopy.general[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.general[ info[#info] ] = value; end
	}
	config.args.minimap = {
		order = 3,
		type = "toggle",
		name = MINIMAP_LABEL,
		get = function(info) return E.global.profileCopy.general[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.general[ info[#info] ] = value; end
	}
	config.args.threat = {
		order = 4,
		type = "toggle",
		name = L["Threat"],
		get = function(info) return E.global.profileCopy.general[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.general[ info[#info] ] = value; end
	}
	config.args.totems = {
		order = 5,
		type = "toggle",
		name = L["Class Totems"],
		get = function(info) return E.global.profileCopy.general[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.general[ info[#info] ] = value; end
	}

	return config
end

--NamePlates
local function CreateNamePlatesConfig()
	local config = CP:CreateModuleConfigGroup(L["NamePlates"], "nameplates")
	config.args.cooldown = {
		order = 2,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.nameplates[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.nameplates[ info[#info] ] = value; end
	}
	config.args.classbar = {
		order = 3,
		type = "toggle",
		name = L["Classbar"],
		get = function(info) return E.global.profileCopy.nameplates[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.nameplates[ info[#info] ] = value; end
	}
	config.args.reactions = {
		order = 4,
		type = "toggle",
		name = L["Reaction Colors"],
		get = function(info) return E.global.profileCopy.nameplates[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.nameplates[ info[#info] ] = value; end
	}
	config.args.healPrediction = {
		order = 5,
		type = "toggle",
		name = L["Heal Prediction"],
		get = function(info) return E.global.profileCopy.nameplates[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.nameplates[ info[#info] ] = value; end
	}
	config.args.threat = {
		order = 6,
		type = "toggle",
		name = L["Threat"],
		get = function(info) return E.global.profileCopy.nameplates[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.nameplates[ info[#info] ] = value; end
	}
	config.args.units = {
		order = 7,
		type = "group",
		guiInline = true,
		name = L["UnitFrames"],
		get = function(info) return E.global.profileCopy.nameplates[info[#info - 1]][ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.nameplates[info[#info - 1]][ info[#info] ] = value; end,
		args = {
			["PLAYER"] = {
				order = 1,
				type = "toggle",
				name = L["Player Frame"],
			},
			["HEALER"] = {
				order = 2,
				type = "toggle",
				name = L["Healer Frames"],
			},
			["FRIENDLY_PLAYER"] = {
				order = 3,
				type = "toggle",
				name = L["Friendly Player Frames"],
			},
			["ENEMY_PLAYER"] = {
				order = 4,
				type = "toggle",
				name = L["Enemy Player Frames"],
			},
			["FRIENDLY_NPC"] = {
				order = 5,
				type = "toggle",
				name = L["Friendly NPC Frames"],
			},
			["ENEMY_NPC"] = {
				order = 6,
				type = "toggle",
				name = L["Enemy NPC Frames"],
			},
		},
	}

	return config
end

--Tooltip
local function CreateTooltipConfig()
	local config = CP:CreateModuleConfigGroup(L["Tooltip"], "tooltip")
	config.args.visibility = {
		order = 2,
		type = "toggle",
		name = L["Visibility"],
		get = function(info) return E.global.profileCopy.tooltip[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.tooltip[ info[#info] ] = value; end
	}
	config.args.healthBar = {
		order = 3,
		type = "toggle",
		name =L["Health Bar"],
		get = function(info) return E.global.profileCopy.tooltip[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.tooltip[ info[#info] ] = value; end
	}

	return config
end

--UnitFrames
local function CreateUnitframesConfig()
	local config = CP:CreateModuleConfigGroup(L["UnitFrames"], "unitframe")
	config.args.cooldown = {
		order = 2,
		type = "toggle",
		name = L["Cooldown Text"],
		get = function(info) return E.global.profileCopy.unitframe[ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.unitframe[ info[#info] ] = value; end
	}
	config.args.colors = {
		order = 3,
		type = "group",
		guiInline = true,
		name = COLORS,
		get = function(info) return E.global.profileCopy.unitframe[info[#info - 1]][ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.unitframe[info[#info - 1]][ info[#info] ] = value; end,
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
		get = function(info) return E.global.profileCopy.unitframe[info[#info - 1]][ info[#info] ] end,
		set = function(info, value) E.global.profileCopy.unitframe[info[#info - 1]][ info[#info] ] = value; end,
		args = {
			["player"] = {
				order = 1,
				type = "toggle",
				name = L["Player Frame"],
			},
			["target"] = {
				order = 2,
				type = "toggle",
				name = L["Target Frame"],
			},
			["targettarget"] = {
				order = 3,
				type = "toggle",
				name = L["TargetTarget Frame"],
			},
			["targettargettarget"] = {
				order = 4,
				type = "toggle",
				name = L["TargetTargetTarget Frame"],
			},
			["focus"] = {
				order = 5,
				type = "toggle",
				name = L["Focus Frame"],
			},
			["focustarget"] = {
				order = 6,
				type = "toggle",
				name = L["FocusTarget Frame"],
			},
			["pet"] = {
				order = 7,
				type = "toggle",
				name = L["Pet Frame"],
			},
			["pettarget"] = {
				order = 8,
				type = "toggle",
				name = L["PetTarget Frame"],
			},
			["boss"] = {
				order = 9,
				type = "toggle",
				name = L["Boss Frames"],
			},
			["arena"] = {
				order = 10,
				type = "toggle",
				name = L["Arena Frames"],
			},
			["party"] = {
				order = 11,
				type = "toggle",
				name = L["Party Frames"],
			},
			["raid"] = {
				order = 12,
				type = "toggle",
				name = L["Raid Frames"],
			},
			["raid40"] = {
				order = 13,
				type = "toggle",
				name = L["Raid-40 Frames"],
			},
			["raidpet"] = {
				order = 14,
				type = "toggle",
				name = L["Raid Pet Frames"],
			},
			["tank"] = {
				order = 15,
				type = "toggle",
				name = L["Tank Frames"],
			},
			["assist"] = {
				order = 16,
				type = "toggle",
				name = L["Assist Frames"],
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
					args = CP:CreateMoversConfigGroup(),
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

