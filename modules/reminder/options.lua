local E, L, P, G = unpack(select(2, ...));
local R = E:GetModule('Reminder')

local selectedFilter
local filters

local function UpdateFilterGroup()
	if not selectedFilter or not E.global['reminder']['filters'][E.myclass][selectedFilter] then
		E.Options.args.nameplate.args.filterGroup = nil
		return
	end
	
	E.Options.args.reminder.args.filterGroup = {
		type = 'group',
		name = selectedFilter,
		guiInline = true,
		order = -10,	
		args = {},	
	}
	
	E.Options.args.reminder.args.filterGroup.args.enable = {
		order = 1,
		type = "toggle",
		name = L["Enable"],
		get = function(info) return E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]['enable'] end,
		set = function(info, value) E.global['reminder']['filters'][E.myclass][selectedFilter]['enable'] = value; R:CheckForNewReminders() end,			
	}
	
	E.Options.args.reminder.args.filterGroup.args.spacer = {
		order = 2,
		type = "description",
		name = '',
	}
			
	E.Options.args.reminder.args.filterGroup.args.Role = {
		type = 'select',
		order = 3,
		name = L['Role'],
		desc = L['You must be a certain role for the icon to appear.'],
		values = {
			["Tank"] = L["Tank"],
			["Melee"] = L["Physical DPS"],
			["Caster"] = L["Caster"],
			["ANY"] = L["Any"],
		},	
		get = function(info) 
			if not E.global['reminder']['filters'][E.myclass][selectedFilter] then
				return "ANY" 
			elseif E.global['reminder']['filters'][E.myclass][selectedFilter]["role"] then 
				return E.global['reminder']['filters'][E.myclass][selectedFilter]["role"] 
			else 
				return "ANY" 
			end 
		end,
		set = function(info, value)
			if value == "ANY" then 
				E.global['reminder']['filters'][E.myclass][selectedFilter]["role"] = nil 
			else 
				E.global['reminder']['filters'][E.myclass][selectedFilter]["role"] = value 
			end
			R:CheckForNewReminders()
		end,		
	}
	
	local spec1, spec2, spec3 = select(2, GetTalentTabInfo(1)), select(2, GetTalentTabInfo(2)), select(2, GetTalentTabInfo(3))
	E.Options.args.reminder.args.filterGroup.args["tree"] = {
		type = 'select',
		name = L["Talent Tree"],
		desc = L["You must be using a certain talent tree for the icon to show."],
		order = 4,
		get = function(info) if E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]["tree"] then return tostring(E.global['reminder']['filters'][E.myclass][selectedFilter].tree) else return "ANY" end end,
		set = function(info, value) if value == "ANY" then E.global['reminder']['filters'][E.myclass][selectedFilter].tree = nil else E.global['reminder']['filters'][E.myclass][selectedFilter].tree = tonumber(value) end; R:CheckForNewReminders() end,	
		values = {
			["1"] = spec1,
			["2"] = spec2,
			["3"] = spec3,
			["ANY"] = L["Any"],
		},
	}
	
	E.Options.args.reminder.args.filterGroup.args["level"] = {
		type = "range",
		name = L["Level Requirement"],
		desc = L["Level requirement for the icon to be able to display. 0 for disabled."],
		order = 5,
		min = 0, max = MAX_PLAYER_LEVEL, step = 1,
		get = function(info) if E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]["level"] then return E.global['reminder']['filters'][E.myclass][selectedFilter]["level"] else return 0 end end,
		set = function(info, value) 
			if E.global['reminder']['filters'][E.myclass][selectedFilter]["level"] ~= 0 then 
				E.global['reminder']['filters'][E.myclass][selectedFilter]["level"] = value
			else 
				E.global['reminder']['filters'][E.myclass][selectedFilter]["level"] = nil
			end 
			R:CheckForNewReminders()
		end,
	}
	
	E.Options.args.reminder.args.filterGroup.args["personal"] = {
		type = "toggle",
		name = L["Personal Buffs"],
		desc = L["Only check if the buff is coming from you."],
		order = 6,
		get = function(info) return E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]["personal"] end,
		set = function(info, value) E.global['reminder']['filters'][E.myclass][selectedFilter]["personal"] = value; R:CheckForNewReminders() end,
	}
	
	E.Options.args.reminder.args.filterGroup.args["instance"] = {
		type = "toggle",
		name = L["Inside Raid/Party"],
		desc = L["Only run checks inside raid/party instances."],
		order = 7,
		get = function(info) return E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]["instance"] end,
		set = function(info, value) E.global['reminder']['filters'][E.myclass][selectedFilter]["instance"] = value; R:CheckForNewReminders() end,
	}

	E.Options.args.reminder.args.filterGroup.args["pvp"] = {
		type = "toggle",
		name = L["Inside BG/Arena"],
		desc = L["Only run checks inside BG/Arena instances."],
		order = 8,
		get = function(info) return E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]["pvp"] end,
		set = function(info, value) E.global['reminder']['filters'][E.myclass][selectedFilter]["pvp"] = value; R:CheckForNewReminders() end,
	}	

	E.Options.args.reminder.args.filterGroup.args["combat"] = {
		type = "toggle",
		name = L["Combat"],
		desc = L["Only run checks during combat."],
		order = 9,
		get = function(info) return E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]["combat"] end,
		set = function(info, value) E.global['reminder']['filters'][E.myclass][selectedFilter]["combat"] = value; R:CheckForNewReminders() end,
	}	

	if E.global['reminder']['filters'][E.myclass][selectedFilter]["weapon"] ~= true then
		E.Options.args.reminder.args.filterGroup.args["reverseCheck"] = {
			type = "toggle",
			name = L["Reverse Check"],
			desc = L["Instead of hiding the frame when you have the buff, show the frame when you have the buff. You must have either a Role or Spec set for this option to work."],
			order = 10,
			get = function(info) return E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]["reverseCheck"] end,
			set = function(info, value) E.global['reminder']['filters'][E.myclass][selectedFilter]["reverseCheck"] = value; R:CheckForNewReminders() end,
			disabled = function() return E.global['reminder']['filters'][E.myclass][selectedFilter] and not E.global['reminder']['filters'][E.myclass][selectedFilter]["tree"] and not E.global['reminder']['filters'][E.myclass][selectedFilter]["role"] end,
		}
		
		E.Options.args.reminder.args.filterGroup.args["talentTreeException"] = {
			type = "select",
			name = L["Tree Exception"],
			desc = L["Set a talent tree to not follow the reverse check."],
			order = 11,
			get = function(info) if E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]["talentTreeException"] then return tostring(E.global['reminder']['filters'][E.myclass][selectedFilter]["talentTreeException"]) else return "NONE" end end,
			set = function(info, value) if value == "NONE" then E.global['reminder']['filters'][E.myclass][selectedFilter]["talentTreeException"] = nil else E.global['reminder']['filters'][E.myclass][selectedFilter]["talentTreeException"] = tonumber(value) end; R:CheckForNewReminders() end,	
			disabled = function() return E.global['reminder']['filters'][E.myclass][selectedFilter] and not E.global['reminder']['filters'][E.myclass][selectedFilter]["reverseCheck"] end,
			values = {
				["1"] = spec1,
				["2"] = spec2,
				["3"] = spec3,
				["NONE"] = L["None"],
			},
		}
		
		E.Options.args.reminder.args.filterGroup.args["spellGroup"] = {
			type = "group",
			name = L["Spells"],
			guiInline = true,	
			order = 12,
			args = {},
		}
		
		if not E.global['reminder']['filters'][E.myclass][selectedFilter]['spellGroup'] then E.global['reminder']['filters'][E.myclass][selectedFilter]['spellGroup'] = {}; end
		for spell, value in pairs(E.global['reminder']['filters'][E.myclass][selectedFilter]['spellGroup']) do
			local name = GetSpellInfo(spell)
			if E.Options.args.reminder.args.filterGroup.args[name] == nil then
				local sname = GetSpellInfo(spell)
				sname = sname.." ("..spell..")"					
				E.Options.args.reminder.args.filterGroup.args["spellGroup"]["args"][name] = {
					name = sname,
					type = "toggle",
					get = function(info) if E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]['spellGroup'][spell] then return true else return false end end,
					set = function(info, value)  E.global['reminder']['filters'][E.myclass][selectedFilter]['spellGroup'][spell] = value; R:CheckForNewReminders() end,
				}
			end
		end			

		E.Options.args.reminder.args.filterGroup.args["AddSpell"] = {
			type = 'input',
			name = L["New ID"],
			get = function(info) return "" end,
			set = function(info, value)	
				if not tonumber(value) then
					E:Print(L["Value must be a number"])
				elseif not GetSpellInfo(value) then
					E:Print(L["Not valid spell id"])
				else							
					value = tonumber(value)
					E.global['reminder']['filters'][E.myclass][selectedFilter]["spellGroup"][value] = true

					R:CheckForNewReminders()
					UpdateFilterGroup()
				end					
			end,
			order = 13,
		}
		
		E.Options.args.reminder.args.filterGroup.args["RemoveSpell"] = {
			type = 'input',
			name = L["Remove ID"],
			get = function(info) return "" end,
			set = function(info, value)			
				if not tonumber(value) then
					E:Print(L["Value must be a number"])							
				elseif not GetSpellInfo(value) then
					E:Print(L["Not valid spell id"])
				elseif E.global['reminder']['filters'][E.myclass][selectedFilter]["spellGroup"][tonumber(value)] == nil then
					E:Print(L["Spell not found in list"])
				else
					value = tonumber(value)
					E.global['reminder']['filters'][E.myclass][selectedFilter]["spellGroup"][value] = nil
					R:CheckForNewReminders()	
					UpdateFilterGroup()
				end					
			end,
			order = 14,
		}	
		
		E.Options.args.reminder.args.filterGroup.args["negateGroup"] = {
			type = "group",
			name = L["Negate Spells"],
			guiInline = true,	
			order = 15,
			args = {},
		}

		if not E.global['reminder']['filters'][E.myclass][selectedFilter]['negateGroup'] then E.global['reminder']['filters'][E.myclass][selectedFilter]['negateGroup'] = {}; end
		for spell, value in pairs(E.global['reminder']['filters'][E.myclass][selectedFilter]['negateGroup']) do
			local name = GetSpellInfo(spell)
			if E.Options.args.reminder.args.filterGroup.args["negateGroup"]["args"][name] == nil then
				local sname = GetSpellInfo(spell)
				sname = sname.." ("..spell..")"					
				E.Options.args.reminder.args.filterGroup.args["negateGroup"]["args"][name] = {
					name = sname,
					type = "toggle",
					get = function(info) if E.global['reminder']['filters'][E.myclass][selectedFilter] and E.global['reminder']['filters'][E.myclass][selectedFilter]['negateGroup'][spell] then return true else return false end end,
					set = function(info, value) E.global['reminder']['filters'][E.myclass][selectedFilter]['negateGroup'][spell] = value; R:CheckForNewReminders() end,
				}
			end
		end			

		E.Options.args.reminder.args.filterGroup.args["AddNegateSpell"] = {
			type = 'input',
			name = L["New ID (Negate)"],
			desc = L["If any spell found inside this list is found the icon will hide as well"],
			get = function(info) return "" end,
			set = function(info, value)		
				if not tonumber(value) then
					E:Print(L["Value must be a number"])								
				elseif not GetSpellInfo(value) then
					E:Print(L["Not valid spell id"])
				else
					value = tonumber(value)
					E.global['reminder']['filters'][E.myclass][selectedFilter]['negateGroup'][value] = true
					R:CheckForNewReminders()	
					UpdateFilterGroup()
				end					
			end,
			order = 16,
		}
		
		E.Options.args.reminder.args.filterGroup.args["RemoveNegateSpell"] = {
			type = 'input',
			name = L["Remove ID (Negate)"],
			get = function(info) return "" end,
			set = function(info, value)	
				if not tonumber(value) then
					E:Print(L["Value must be a number"])						
				elseif not GetSpellInfo(value) then
					E:Print(L["Not valid spell id"])
				elseif E.global['reminder']['filters'][E.myclass][selectedFilter]['negateGroup'][tonumber(value)] == nil then
					E:Print(L["Spell not found in list"])
				else
					value = tonumber(value)
					E.global['reminder']['filters'][E.myclass][selectedFilter]['negateGroup'][value] = nil
					R:CheckForNewReminders()									
					UpdateFilterGroup()
				end					
			end,
			order = 17,
		}						
	end
	
end

E.Options.args.reminder = {
	type = "group",
	name = L["Reminders"],
	childGroups = "tree",
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["REMINDER_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.global.reminder[ info[#info] ] end,
			set = function(info, value) E.global.reminder[ info[#info] ] = value; StaticPopup_Show("GLOBAL_RL") end
		},
		spacer = {
			order = 3,
			type = "description",
			name = '',
		},	
		addGroup = {
			type = 'input',
			order = 4,
			name = L['Add Group'],
			get = function(info) return "" end,
			set = function(info, value) 
				if E.global.reminder.filters[E.myclass][value] then
					E:Print(L['Group already exists!'])
					return
				end
				
				E.Options.args.reminder.args.filterGroup = nil
				E.global['reminder']['filters'][E.myclass][value] = {};	
				UpdateFilterGroup()
				R:CheckForNewReminders()
			end,
		},
		deleteGroup = {
			type = 'input',
			order = 5,
			name = L['Remove Group'],
			get = function(info) return "" end,
			set = function(info, value) 
				if G.reminder.filters[E.myclass][value] then
					E.global.reminder.filters[E.myclass][value].enable = false;
					E:Print(L["You can't remove a default group from the list, disabling the group."])
				else
					E.global.reminder.filters[E.myclass][value] = nil;
					selectedFilter = nil;
					R.CreatedReminders[value] = nil;
				end
				E.Options.args.reminder.args.filterGroup = nil
				UpdateFilterGroup()
				R:CheckForNewReminders();
			end,				
		},
		selectGroup = {
			order = 6,
			type = 'select',
			name = L['Select Group'],
			get = function(info) return selectedFilter end,
			set = function(info, value) selectedFilter = value; UpdateFilterGroup() end,							
			values = function()
				filters = {}
				for filter in pairs(R.CreatedReminders) do
					filters[filter] = filter
				end
				return filters
			end,
		},		
	},
}