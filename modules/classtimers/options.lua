local E, L, P, G = unpack(select(2, ...));
local CT = E:GetModule('ClassTimers')

local selectedFilter, selectedSpell, compareTable = nil, nil, {};
local function UpdateFilterGroup()
	local filterTable, defaultTable, name
	if selectedFilter == 'PLAYER' then
		name = PLAYER;
		filterTable = CT.db.spells_filter[E.myclass].player
		defaultTable = P.classtimer.spells_filter[E.myclass].player
	elseif selectedFilter == 'TARGET' then
		name = TARGET;
		filterTable = CT.db.spells_filter[E.myclass].target
		defaultTable = P.classtimer.spells_filter[E.myclass].target
	elseif selectedFilter == 'TRINKET' then
		name = L['Trinket']
		filterTable = CT.db.trinkets_filter
		defaultTable = P.classtimer.trinkets_filter
	elseif selectedFilter == 'PROCS' then
		name = L['Procs']
		filterTable = CT.db.spells_filter[E.myclass].procs
		defaultTable = P.classtimer.spells_filter[E.myclass].procs
	end
	
	E.Options.args.classtimer.args.filters.args.filterGroup = {
		name = name,
		type = 'group',
		guiInline = true,
		order = 2,
		args = {
			selectSpell = {
				order = 1,
				type = 'select',
				name = L['Select Spell'],
				values = {},
				get = function(info) return selectedSpell end,
				set = function(info, value) selectedSpell = value; UpdateFilterGroup() end,
			},	
			addSpell = {
				order = 2,
				type = 'input',
				name = L['Add SpellID'],
				get = function() return '' end,
				set = function(info, value) 
					value = tonumber(value)
					if type(value) ~= 'number' then
						E:Print(L['Not a valid SpellID.'])
						return
					end
					
					if not GetSpellInfo(value) then
						E:Print(L['Not a valid SpellID.'])
						return
					end
					
					local spellMatch;
					for _, spellTable in pairs(filterTable) do
						if spellTable.id == value then
							spellMatch = true
						end
					end
					
					if spellMatch == true then
						E:Print(L['Spell already exists in filter.'])
						return
					end
					
					table.insert(filterTable, {enabled = true, id = value, castByAnyone = false, unitType = 0})
					CT:UpdateFiltersAndColors()
					UpdateFilterGroup()
				end,
			},
			removeSpell = {
				order = 3,
				type = 'input',
				name = L['Remove SpellID'],
				get = function() return '' end,
				set = function(info, value) 
					value = tonumber(value)
					if type(value) ~= 'number' then
						E:Print(L['Not a valid SpellID.'])
						return
					end
					
					if not GetSpellInfo(value) then
						E:Print(L['Not a valid SpellID.'])
						return
					end
					
					local spellMatch;
					for index, spellTable in pairs(filterTable) do
						if spellTable.id == value then
							if defaultTable[index] then
								E:Print(L['You cannot remove a spell that is default, disabling the spell for you however.'])
								spellTable.enabled = false
							else
								filterTable[index] = nil
							end
							CT:UpdateFiltersAndColors()
							UpdateFilterGroup()
							selectedSpell = nil;
							E.Options.args.classtimer.args.filters.args.filterGroup.args.spellGroup = nil;
							return;
						end
					end
					
					if spellMatch == nil then
						E:Print(L['Spell not found.'])
					end		
				end,
			},			
		},
	}

	if selectedFilter then
		for index, spellTable in pairs(filterTable) do
			local id = spellTable.id
			local name = GetSpellInfo(id)
			E.Options.args.classtimer.args.filters.args.filterGroup.args.selectSpell.values[id] = name;
			compareTable[id] = index
		end	
		
		if selectedSpell then
			E.Options.args.classtimer.args.filters.args.filterGroup.args.spellGroup = {
				name = GetSpellInfo(selectedSpell)..' ('..selectedSpell..')',
				type = 'group',
				guiInline = true,
				order = 100,
				args = {
					enable = {
						type = 'toggle',
						order = 1,
						name = L['Enable'],
						get = function(info) local index = compareTable[selectedSpell]; return filterTable[index].enabled end,
						set = function(info, value) local index = compareTable[selectedSpell]; filterTable[index].enabled = value; CT:UpdateFiltersAndColors() end,
					},
					anyUnit = {
						type = 'toggle',
						order = 2,
						name = L['Any Unit'],
						get = function(info) local index = compareTable[selectedSpell]; return filterTable[index].castByAnyone end,
						set = function(info, value) local index = compareTable[selectedSpell]; filterTable[index].castByAnyone = value; CT:UpdateFiltersAndColors() end,					
					},
					unitType = {
						type = 'select',
						order = 3,
						name = L['Unit Type'],
						values = {
							[0] = L["All"],
							[1] = L["Friendly"],
							[2] = L["Enemy"],	
						},
						get = function(info) local index = compareTable[selectedSpell]; return filterTable[index].unitType or 0 end,
						set = function(info, value) local index = compareTable[selectedSpell]; filterTable[index].unitType = value; CT:UpdateFiltersAndColors() end,						
					},
					color = {
						type = 'color',
						order = 4,
						name = L['Color'],
						get = function(info) 
							local index = compareTable[selectedSpell]; 
							local t = filterTable[index].color
							if not t then
								t = {r=0, g=0, b=0}
							end
							
							return t.r, t.g, t.b
						end,
						set = function(info, r, g, b) 
							local index = compareTable[selectedSpell]; 
							filterTable[index].color = {}
							local t = filterTable[index].color
							t.r, t.g, t.b = r, g, b
							
							CT:UpdateFiltersAndColors() 
						end,						
					},
					removeColor = {
						type = 'execute',
						order = 5,
						name = L['Remove Color'],
						desc = L['Reset color back to the bar default.'],
						func = function() 
							local index = compareTable[selectedSpell]; 
							filterTable[index].color = nil;		
							CT:UpdateFiltersAndColors() 
						end,
					},
				},
			}
		else
			E.Options.args.classtimer.args.filters.args.filterGroup.args.spellGroup = nil;
		end
	end
end

E.Options.args.classtimer = {
	type = "group",
	name = L["ClassTimers"],
	childGroups = "select",
	get = function(info) return E.db.classtimer[ info[#info] ] end,
	set = function(info, value) E.db.classtimer[ info[#info] ] = value; end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["CLASSTIMER_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			set = function(info, value) E.db.classtimer[ info[#info] ] = value; StaticPopup_Show("CONFIG_RL") end
		},
		general = {
			order = 3,
			type = 'group',
			name = L['General'],
			disabled = function() return not E.ClassTimers; end,
			args = {
				player = {
					name = L['Player'],
					type = 'group',
					guiInline = true,
					get = function(info) return E.db.classtimer.player[ info[#info] ] end,
					args = {
						enable = {
							type = 'toggle',
							name = L['Enable'],
							order = 1,
							set = function(info, value) E.db.classtimer.player[ info[#info] ] = value; CT:ToggleTimers() end,
						},
						anchor = {
							type = 'select',
							name = L['Anchor'],
							desc = L['What frame to anchor the class timer bars to.'],
							order = 2,
							values = {
								['PLAYERFRAME'] = L['Player Frame'],
								['PLAYERBUFFS'] = L['Player Buffs'],
								['PLAYERDEBUFFS'] = L['Player Debuffs'],
								['TARGETANCHOR'] = L['Target Anchor'],
								['TARGETFRAME'] = L['Target Frame'],
								['TARGETBUFFS'] = L['Target Buffs'],
								['TARGETDEBUFFS'] = L['Target Debuffs'],
								['TRINKETANCHOR'] = L['Trinket Anchor'],
							},
							set = function(info, value) E.db.classtimer.player[ info[#info] ] = value; CT:PositionTimers() end,	
						},
						buffcolor = {
							type = "color",
							order = 3,
							name = L["Buff Color"],
							hasAlpha = false,
							get = function(info)
								local t = E.db.classtimer.player[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.classtimer.player[ info[#info] ] = {}
								local t = E.db.classtimer.player[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								CT:UpdateFiltersAndColors()
							end,					
						},
						debuffcolor = {
							type = "color",
							order = 3,
							name = L["Debuff Color"],
							hasAlpha = false,
							get = function(info)
								local t = E.db.classtimer.player[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.classtimer.player[ info[#info] ] = {}
								local t = E.db.classtimer.player[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								CT:UpdateFiltersAndColors()
							end,					
						},							
					},
				},	
				target = {
					name = L['Target'],
					type = 'group',
					guiInline = true,
					get = function(info) return E.db.classtimer.target[ info[#info] ] end,
					args = {
						enable = {
							type = 'toggle',
							name = L['Enable'],
							order = 1,
							set = function(info, value) E.db.classtimer.target[ info[#info] ] = value; CT:ToggleTimers() end,
						},
						anchor = {
							type = 'select',
							name = L['Anchor'],
							desc = L['What frame to anchor the class timer bars to.'],
							order = 2,
							values = {
								['PLAYERFRAME'] = L['Player Frame'],
								['PLAYERBUFFS'] = L['Player Buffs'],
								['PLAYERDEBUFFS'] = L['Player Debuffs'],
								['PLAYERANCHOR'] = L['Player Anchor'],
								['TARGETFRAME'] = L['Target Frame'],
								['TARGETBUFFS'] = L['Target Buffs'],
								['TARGETDEBUFFS'] = L['Target Debuffs'],
								['TRINKETANCHOR'] = L['Trinket Anchor'],
							},
							set = function(info, value) E.db.classtimer.target[ info[#info] ] = value; CT:PositionTimers() end,	
						},
						buffcolor = {
							type = "color",
							order = 3,
							name = L["Buff Color"],
							hasAlpha = false,
							get = function(info)
								local t = E.db.classtimer.target[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.classtimer.target[ info[#info] ] = {}
								local t = E.db.classtimer.target[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								CT:UpdateFiltersAndColors()
							end,					
						},
						debuffcolor = {
							type = "color",
							order = 3,
							name = L["Debuff Color"],
							hasAlpha = false,
							get = function(info)
								local t = E.db.classtimer.target[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.classtimer.target[ info[#info] ] = {}
								local t = E.db.classtimer.target[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								CT:UpdateFiltersAndColors()
							end,					
						},							
					},
				},		
				trinket = {
					name = L['Trinket'],
					type = 'group',
					guiInline = true,
					get = function(info) return E.db.classtimer.trinket[ info[#info] ] end,
					args = {
						enable = {
							type = 'toggle',
							name = L['Enable'],
							order = 1,
							set = function(info, value) E.db.classtimer.trinket[ info[#info] ] = value; CT:ToggleTimers() end,
						},
						anchor = {
							type = 'select',
							name = L['Anchor'],
							desc = L['What frame to anchor the class timer bars to.'],
							order = 2,
							values = {
								['PLAYERFRAME'] = L['Player Frame'],
								['PLAYERBUFFS'] = L['Player Buffs'],
								['PLAYERDEBUFFS'] = L['Player Debuffs'],
								['TARGETANCHOR'] = L['Target Anchor'],
								['TARGETFRAME'] = L['Target Frame'],
								['TARGETBUFFS'] = L['Target Buffs'],
								['TARGETDEBUFFS'] = L['Target Debuffs'],
								['PLAYERANCHOR'] = L['Player Anchor'],
							},
							set = function(info, value) E.db.classtimer.trinket[ info[#info] ] = value; CT:PositionTimers() end,	
						},
						color = {
							type = "color",
							order = 3,
							name = L["Color"],
							hasAlpha = false,
							get = function(info)
								local t = E.db.classtimer.trinket[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.classtimer.trinket[ info[#info] ] = {}
								local t = E.db.classtimer.trinket[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								CT:UpdateFiltersAndColors()
							end,					
						},						
					},
				},					
			},
		},
		filters = {
			order = 4,
			type = 'group',
			name = L['Filters'],
			disabled = function() return not E.ClassTimers; end,	
			args = {
				filterType = {
					order = 1,
					type = 'select',
					name = L['Select Filter'],
					values = {
						['TARGET'] = TARGET,
						['PLAYER'] = PLAYER,
						['TRINKET'] = L['Trinket'],	
						['PROCS'] = L['Procs'],
					},
					get = function(info) return selectedFilter end,
					set = function(info, value) selectedFilter = value; selectedSpell = nil; wipe(compareTable); UpdateFilterGroup() end,
				},
			},
		},
	},
}