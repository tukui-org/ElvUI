local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');

local filters = {};

local auraBarsSortValues = {
	['TIME_REMAINING'] = L['Time Remaining'],
	['TIME_REMAINING_REVERSE'] = L['Time Remaining Reverse'],
	['TIME_DURATION'] = L['Duration'],
	['TIME_DURATION_REVERSE'] = L['Duration Reverse'],
	['NAME'] = NAME,
	['NONE'] = NONE,
}

function UF:Construct_AuraBars()
	local bar = self.statusBar
	
	self:SetTemplate('Default')

	bar:SetInside(self)
	UF['statusbars'][bar] = true
	UF:Update_StatusBar(bar)
		
	UF:Configure_FontString(bar.spelltime)
	UF:Configure_FontString(bar.spellname)
	UF:Update_FontString(bar.spelltime)
	UF:Update_FontString(bar.spellname)
	
	bar.spellname:ClearAllPoints()
	bar.spellname:SetPoint('LEFT', bar, 'LEFT', 2, 0)
	bar.spellname:SetPoint('RIGHT', bar.spelltime, 'LEFT', -4, 0)
	
	bar.iconHolder:SetTemplate('Default')
	bar.icon:SetInside(bar.iconHolder)
	bar.icon:SetDrawLayer('OVERLAY')
	
	bar.bg = bar:CreateTexture(nil, 'BORDER')
	bar.bg:Hide()
	
	
	bar.iconHolder:RegisterForClicks('RightButtonUp')
	bar.iconHolder:SetScript('OnClick', function(self)
		if not IsShiftKeyDown() then return; end
		local auraName = self:GetParent().aura.name
		
		if auraName then
			E:Print(format(L['The spell "%s" has been added to the Blacklist unitframe aura filter.'], auraName))
			E.global['unitframe']['aurafilters']['Blacklist']['spells'][auraName] = {
				['enable'] = true,
				['priority'] = 0,			
			}
			UF:Update_AllFrames()
		end
	end)
end

function UF:Construct_AuraBarHeader(frame)
	local auraBar = CreateFrame('Frame', nil, frame)
	auraBar.PostCreateBar = UF.Construct_AuraBars
	auraBar.gap = (E.PixelMode and -1 or 1)
	auraBar.spacing = (E.PixelMode and -1 or 1)
	auraBar.spark = true
	auraBar.filter = UF.AuraBarFilter
	auraBar.PostUpdate = UF.ColorizeAuraBars

	
	return auraBar
end

local huge = math.huge
function UF.SortAuraBarReverse(a, b)
	local compa, compb = a.noTime and huge or a.expirationTime, b.noTime and huge or b.expirationTime
	return compa < compb
end

function UF.SortAuraBarDuration(a, b)
	local compa, compb = a.noTime and huge or a.duration, b.noTime and huge or b.duration
	return compa > compb
end

function UF.SortAuraBarDurationReverse(a, b)
	local compa, compb = a.noTime and huge or a.duration, b.noTime and huge or b.duration
	return compa > compb
end

function UF.SortAuraBarName(a, b)
	return a.name > b.name
end

function UF:AuraBarFilter(unit, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID)
	if not self.db then return; end
	if E.global.unitframe.InvalidSpells[spellID] then
		return false;
	end
	
	local db = self.db.aurabar

	local returnValue = true
	local passPlayerOnlyCheck = true
	local anotherFilterExists = false
	local isPlayer = unitCaster == 'player' or unitCaster == 'vehicle'
	local isFriend = UnitIsFriend('player', unit) == 1 and true or false
	local auraType = isFriend and db.friendlyAuraType or db.enemyAuraType
	
	if UF:CheckFilter(db.playerOnly, isFriend) then
		if isPlayer then
			returnValue = true;
		else
			returnValue = false;
		end
		
		passPlayerOnlyCheck = returnValue
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.onlyDispellable, isFriend) then
		if (self.type == 'buffs' and not isStealable) or (self.type == 'debuffs' and dtype and  not E:IsDispellableByMe(dtype)) then
			returnValue = false;
		end
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.noConsolidated, isFriend) then
		if shouldConsolidate == 1 then
			returnValue = false;
		end
		
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.noDuration, isFriend) then
		if (duration == 0 or not duration) then
			returnValue = false;
		end
		
		anotherFilterExists = true
	end

	if UF:CheckFilter(db.useBlacklist, isFriend) then
		local blackList = E.global['unitframe']['aurafilters']['Blacklist'].spells[name]
		if blackList and blackList.enable then
			returnValue = false;
		end
		
		anotherFilterExists = true
	end
	
	if UF:CheckFilter(db.useWhitelist, isFriend) then
		local whiteList = E.global['unitframe']['aurafilters']['Whitelist'].spells[name]
		if whiteList and whiteList.enable then
			returnValue = true;
		elseif not anotherFilterExists then
			returnValue = false
		end
		
		anotherFilterExists = true
	end	

	if db.useFilter and E.global['unitframe']['aurafilters'][db.useFilter] then
		local type = E.global['unitframe']['aurafilters'][db.useFilter].type
		local spellList = E.global['unitframe']['aurafilters'][db.useFilter].spells

		if type == 'Whitelist' then
			if spellList[name] and spellList[name].enable and passPlayerOnlyCheck then
				returnValue = true
			elseif not anotherFilterExists then
				returnValue = false
			end
		elseif type == 'Blacklist' and spellList[name] and spellList[name].enable then
			returnValue = false				
		end
	end		
	
	return returnValue	
end

function UF:ColorizeAuraBars(event, unit)
	local bars = self.bars
	for index = 1, #bars do
		local frame = bars[index]
		if not frame:IsVisible() then break end

		local colors = E.global.unitframe.AuraBarColors[frame.statusBar.aura.name]
		if colors then
			frame.statusBar:SetStatusBarColor(colors.r, colors.g, colors.b)
			frame.statusBar.bg:SetTexture(colors.r * 0.25, colors.g * 0.25, colors.b * 0.25)
		else
			local r, g, b = frame.statusBar:GetStatusBarColor()
			frame.statusBar.bg:SetTexture(r * 0.25, g * 0.25, b * 0.25)			
		end

		if UF.db.colors.transparentAurabars then
			UF:ToggleTransparentStatusBar(true, frame.statusBar, frame.statusBar.bg, nil, true)
			local _, _, _, alpha = frame:GetBackdropColor()
			if colors then
				frame:SetBackdropColor(colors.r * 0.58, colors.g * 0.58, colors.b * 0.58, alpha)
			else
				local r, g, b = frame.statusBar:GetStatusBarColor()
				frame:SetBackdropColor(r * 0.58, g * 0.58, b * 0.58, alpha)
			end			
		else
			UF:ToggleTransparentStatusBar(false, frame.statusBar, frame.statusBar.bg, nil, true)
		end	
	end
end

function UF:GetOptionsTable_AuraBars(friendlyOnly, updateFunc, groupName)
	local config = {
		order = 1100,
		type = 'group',
		name = L['Aura Bars'],
		get = function(info) return E.db.unitframe.units[groupName]['aurabar'][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units[groupName]['aurabar'][ info[#info] ] = value; updateFunc(self, groupName) end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L['Enable'],
			},				
			anchorPoint = {
				type = 'select',
				order = 2,
				name = L['Anchor Point'],
				desc = L['What point to anchor to the frame you set to attach to.'],
				values = {
					['ABOVE'] = L['Above'],
					['BELOW'] = L['Below'],
				},
			},
			attachTo = {
				type = 'select',
				order = 3,
				name = L['Attach To'],
				desc = L['The object you want to attach to.'],
				values = {
					['FRAME'] = L['Frame'],
					['DEBUFFS'] = L['Debuffs'],
					['BUFFS'] = L['Buffs'],
				},					
			},
			height = {
				type = 'range',
				order = 4,
				name = L['Height'],
				min = 6, max = 40, step = 1,
			},
			sort = {
				type = 'select',
				order = 5,
				name = L['Sort Method'],
				values = auraBarsSortValues,
			},
			filters = {
				name = L["Filters"],
				guiInline = true,
				type = 'group',
				order = 500,
				args = {},
			},				
			friendlyAuraType = {
				type = 'select',
				order = 16,
				name = L['Friendly Aura Type'],
				desc = L['Set the type of auras to show when a unit is friendly.'],
				values = {
					['HARMFUL'] = L['Debuffs'],
					['HELPFUL'] = L['Buffs'],
				},						
			},
			enemyAuraType = {
				type = 'select',
				order = 17,
				name = L['Enemy Aura Type'],
				desc = L['Set the type of auras to show when a unit is a foe.'],
				values = {
					['HARMFUL'] = L['Debuffs'],
					['HELPFUL'] = L['Buffs'],
				},						
			},
		},
	}		
	
	if friendlyOnly then
		config.args.filters.args.playerOnly = {
			order = 10,
			type = 'toggle',
			name = L["Block Non-Personal Auras"],
			desc = L["Don't display auras that are not yours."],
		}
		config.args.filters.args.useBlacklist = {
			order = 11,
			type = 'toggle',
			name = L["Block Blacklisted Auras"],
			desc = L["Don't display any auras found on the 'Blacklist' filter."],
		}
		config.args.filters.args.useWhitelist = {
			order = 12,
			type = 'toggle',
			name = L["Allow Whitelisted Auras"],
			desc = L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
		}
		config.args.filters.args.noDuration = {
			order = 13,
			type = 'toggle',
			name = L["Block Auras Without Duration"],
			desc = L["Don't display auras that have no duration."],					
		}
		config.args.filters.args.onlyDispellable = {
			order = 13,
			type = 'toggle',
			name = L['Block Non-Dispellable Auras'],
			desc = L["Don't display auras that cannot be purged or dispelled by your class."],
		}
		config.args.filters.args.noConsolidated = {
			order = 14,
			type = 'toggle',
			name = L["Block Raid Buffs"],
			desc = L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."],		
		}				
		config.args.filters.args.useFilter = {
			order = 15,
			name = L['Additional Filter'],
			desc = L['Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings.'],
			type = 'select',
			values = function()
				filters = {}
				filters[''] = NONE
				for filter in pairs(E.global.unitframe['aurafilters']) do
					filters[filter] = filter
				end
				return filters
			end,
		}		
	else
		config.args.filters.args.playerOnly = {
			order = 10,
			guiInline = true,
			type = 'group',
			name = L["Block Non-Personal Auras"],
			args = {
				friendly = {
					order = 2,
					type = 'toggle',
					name = L['Friendly'],
					desc = L["If the unit is friendly to you."].." "..L["Don't display auras that are not yours."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].playerOnly.friendly end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].playerOnly.friendly = value; updateFunc(self, groupName) end,									
				},
				enemy = {
					order = 3,
					type = 'toggle',
					name = L['Enemy'],
					desc = L["If the unit is an enemy to you."].." "..L["Don't display auras that are not yours."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].playerOnly.enemy end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].playerOnly.enemy = value; updateFunc(self, groupName) end,										
				}
			},
		}
		config.args.filters.args.useBlacklist = {
			order = 11,
			guiInline = true,
			type = 'group',
			name = L["Block Blacklisted Auras"],
			args = {
				friendly = {
					order = 2,
					type = 'toggle',
					name = L['Friendly'],
					desc = L["If the unit is friendly to you."].." "..L["Don't display any auras found on the 'Blacklist' filter."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].useBlacklist.friendly end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].useBlacklist.friendly = value; updateFunc(self, groupName) end,									
				},
				enemy = {
					order = 3,
					type = 'toggle',
					name = L['Enemy'],
					desc = L["If the unit is an enemy to you."].." "..L["Don't display any auras found on the 'Blacklist' filter."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].useBlacklist.enemy end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].useBlacklist.enemy = value; updateFunc(self, groupName) end,										
				}
			},
		}
		config.args.filters.args.useWhitelist = {
			order = 12,
			guiInline = true,
			type = 'group',
			name = L["Allow Whitelisted Auras"],
			args = {
				friendly = {
					order = 2,
					type = 'toggle',
					name = L['Friendly'],
					desc = L["If the unit is friendly to you."].." "..L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].useWhitelist.friendly end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].useWhitelist.friendly = value; updateFunc(self, groupName) end,									
				},
				enemy = {
					order = 3,
					type = 'toggle',
					name = L['Enemy'],
					desc = L["If the unit is an enemy to you."].." "..L["If no other filter options are being used then it will block anything not on the 'Whitelist' filter, otherwise it will simply add auras on the whitelist in addition to any other filter settings."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].useWhitelist.enemy end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].useWhitelist.enemy = value; updateFunc(self, groupName) end,										
				}
			},
		}
		config.args.filters.args.noDuration = {
			order = 13,
			guiInline = true,
			type = 'group',
			name = L["Block Auras Without Duration"],
			args = {
				friendly = {
					order = 2,
					type = 'toggle',
					name = L['Friendly'],
					desc = L["If the unit is friendly to you."].." "..L["Don't display auras that have no duration."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].noDuration.friendly end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].noDuration.friendly = value; updateFunc(self, groupName) end,									
				},
				enemy = {
					order = 3,
					type = 'toggle',
					name = L['Enemy'],
					desc = L["If the unit is an enemy to you."].." "..L["Don't display auras that have no duration."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].noDuration.enemy end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].noDuration.enemy = value; updateFunc(self, groupName) end,										
				}
			},				
		}
		config.args.filters.args.onlyDispellable = {
			order = 13,
			guiInline = true,
			type = 'group',
			name = L['Block Non-Dispellable Auras'],
			args = {
				friendly = {
					order = 2,
					type = 'toggle',
					name = L['Friendly'],
					desc = L["If the unit is friendly to you."].." "..L["Don't display auras that cannot be purged or dispelled by your class."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].onlyDispellable.friendly end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].onlyDispellable.friendly = value; updateFunc(self, groupName) end,									
				},
				enemy = {
					order = 3,
					type = 'toggle',
					name = L['Enemy'],
					desc = L["If the unit is an enemy to you."].." "..L["Don't display auras that cannot be purged or dispelled by your class."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].onlyDispellable.enemy end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].onlyDispellable.enemy = value; updateFunc(self, groupName) end,										
				}
			},	
		}
		config.args.filters.args.noConsolidated = {
			order = 14,
			guiInline = true,
			type = 'group',
			name = L["Block Raid Buffs"],
			args = {
				friendly = {
					order = 2,
					type = 'toggle',
					name = L['Friendly'],
					desc = L["If the unit is friendly to you."].." "..L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].noConsolidated.friendly end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].noConsolidated.friendly = value; updateFunc(self, groupName) end,									
				},
				enemy = {
					order = 3,
					type = 'toggle',
					name = L['Enemy'],
					desc = L["If the unit is an enemy to you."].." "..L["Don't display raid buffs such as Blessing of Kings or Mark of the Wild."],
					get = function(info) return E.db.unitframe.units[groupName]['aurabar'].noConsolidated.enemy end,
					set = function(info, value) E.db.unitframe.units[groupName]['aurabar'].noConsolidated.enemy = value; updateFunc(self, groupName) end,										
				}
			},		
		}
		config.args.filters.args.useFilter = {
			order = 15,
			name = L['Additional Filter'],
			desc = L['Select an additional filter to use. If the selected filter is a whitelist and no other filters are being used (with the exception of Block Non-Personal Auras) then it will block anything not on the whitelist, otherwise it will simply add auras on the whitelist in addition to any other filter settings.'],
			type = 'select',
			values = function()
				filters = {}
				filters[''] = NONE
				for filter in pairs(E.global.unitframe['aurafilters']) do
					filters[filter] = filter
				end
				return filters
			end,
		}										
	end
	
	return config
end