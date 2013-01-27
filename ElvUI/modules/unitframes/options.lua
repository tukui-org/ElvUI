local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF

local fillValues = {
	['fill'] = L['Filled'],
	['spaced'] = L['Spaced'],
};

local positionValues = {
	TOPLEFT = 'TOPLEFT',
	LEFT = 'LEFT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	RIGHT = 'RIGHT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMRIGHT = 'BOTTOMRIGHT',
	CENTER = 'CENTER',
	TOP = 'TOP',
	BOTTOM = 'BOTTOM',
};

local auraAnchors = {
	TOPLEFT = 'TOPLEFT',
	LEFT = 'LEFT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	RIGHT = 'RIGHT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMRIGHT = 'BOTTOMRIGHT',
};

local petAnchors = {
	TOPLEFT = 'TOPLEFT',
	LEFT = 'LEFT',
	BOTTOMLEFT = 'BOTTOMLEFT',
	RIGHT = 'RIGHT',
	TOPRIGHT = 'TOPRIGHT',
	BOTTOMRIGHT = 'BOTTOMRIGHT',
	TOP = 'TOP',
	BOTTOM = 'BOTTOM',
};

local filters;
local tinsert = table.insert
function UF:CreateCustomTextGroup(unit, objectName)
	if E.Options.args.unitframe.args[unit].args[objectName] then return end
	
	E.Options.args.unitframe.args[unit].args[objectName] = {
		order = -1,
		type = 'group',
		name = objectName,
		get = function(info) return E.db.unitframe.units[unit].customTexts[objectName][ info[#info] ] end,
		set = function(info, value) 
			E.db.unitframe.units[unit].customTexts[objectName][ info[#info] ] = value; 
			
			if unit == 'party' or unit:find('raid') then
				UF:CreateAndUpdateHeaderGroup(unit)
			elseif unit == 'boss' then
				UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES)
			elseif unit == 'arena' then
				UF:CreateAndUpdateUFGroup('arena', 5)
			else
				UF:CreateAndUpdateUF(unit) 
			end
		end,
		args = {
			delete = {
				type = 'execute',
				order = 1,
				name = DELETE,
				func = function() 
					E.Options.args.unitframe.args[unit].args[objectName] = nil; 
					E.db.unitframe.units[unit].customTexts[objectName] = nil; 
					
					if unit == 'boss' or unit == 'arena' then
						for i=1, 5 do
							if UF[unit..i] then
								UF[unit..i]:Tag(UF[unit..i][objectName], ''); 
								UF[unit..i][objectName]:Hide(); 
							end
						end
					elseif unit == 'party' or unit:find('raid') then
						for i=1, UF[unit]:GetNumChildren() do
							local child = select(i, UF[unit]:GetChildren())
							if child.Tag then
								child:Tag(child[objectName], ''); 
								child[objectName]:Hide(); 
							end
						end
					elseif UF[unit] then
						UF[unit]:Tag(UF[unit][objectName], ''); 
						UF[unit][objectName]:Hide(); 
					end
				end,	
			},
			font = {
				type = "select", dialogControl = 'LSM30_Font',
				order = 2,
				name = L["Font"],
				values = AceGUIWidgetLSMlists.font,
			},
			size = {
				order = 3,
				name = L["Font Size"],
				type = "range",
				min = 6, max = 32, step = 1,
			},		
			fontOutline = {
				order = 4,
				name = L["Font Outline"],
				desc = L["Set the font outline."],
				type = "select",
				values = {
					['NONE'] = L['None'],
					['OUTLINE'] = 'OUTLINE',
					['MONOCHROME'] = 'MONOCHROME',
					['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
					['THICKOUTLINE'] = 'THICKOUTLINE',
				},	
			},
			justifyH = {
				order = 5,
				type = 'select',
				name = L['JustifyH'],
				desc = L["Sets the font instance's horizontal text alignment style."],
				values = {
					['CENTER'] = L['Center'],
					['LEFT'] = L['Left'],
					['RIGHT'] = L['Right'],
				},
			},
			xOffset = {
				order = 6,
				type = 'range',
				name = L['xOffset'],
				min = -400, max = 400, step = 1,		
			},
			yOffset = {
				order = 7,
				type = 'range',
				name = L['yOffset'],
				min = -400, max = 400, step = 1,		
			},						
			text_format = {
				order = 100,
				name = L['Text Format'],
				type = 'input',
				width = 'full',
				desc = L['TEXT_FORMAT_DESC'],
			},		
		},
	}		
end

E.Options.args.unitframe = {
	type = "group",
	name = L["UnitFrames"],
	childGroups = "tree",
	get = function(info) return E.db.unitframe[ info[#info] ] end,
	set = function(info, value) E.db.unitframe[ info[#info] ] = value end,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.unitframe.enable end,
			set = function(info, value) E.private.unitframe.enable = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 200,
			type = 'group',
			name = L['General'],
			guiInline = true,
			disabled = function() return not E.private.unitframe.enable end,
			set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_AllFrames() end,
			args = {
				generalGroup = {
					order = 1,
					type = 'group',
					guiInline = true,
					name = L['General'],
					args = {
						disableBlizzard = {
							order = 1,
							name = L['Disable Blizzard'],
							desc = L['Disables the blizzard party/raid frames.'],
							type = 'toggle',
							get = function(info) return E.private.unitframe[ info[#info] ] end,
							set = function(info, value) E.private["unitframe"][ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
						},
						OORAlpha = {
							order = 2,
							name = L['OOR Alpha'],
							desc = L['The alpha to set units that are out of range to.'],
							type = 'range',
							min = 0, max = 1, step = 0.01,
						},
						debuffHighlighting = {
							order = 3,
							name = L['Debuff Highlighting'],
							desc = L['Color the unit healthbar if there is a debuff that can be dispelled by you.'],
							type = 'toggle',
						},
						smartRaidFilter = {
							order = 4,
							name = L['Smart Raid Filter'],
							desc = L['Override any custom visibility setting in certain situations, EX: Only show groups 1 and 2 inside a 10 man instance.'],
							type = 'toggle',
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:UpdateAllHeaders() end
						},
					},
				},
				barGroup = {
					order = 2,
					type = 'group',
					guiInline = true,
					name = L['Bars'],
					args = {
						smoothbars = {
							type = 'toggle',
							order = 2,
							name = L['Smooth Bars'],
							desc = L['Bars will transition smoothly.'],	
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_AllFrames(); end,
						},
						statusbar = {
							type = "select", dialogControl = 'LSM30_Statusbar',
							order = 3,
							name = L["StatusBar Texture"],
							desc = L["Main statusbar texture."],
							values = AceGUIWidgetLSMlists.statusbar,			
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_StatusBars() end,
						},	
					},
				},
				fontGroup = {
					order = 3,
					type = 'group',
					guiInline = true,
					name = L['Fonts'],
					args = {
						font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 4,
							name = L["Default Font"],
							desc = L["The font that the unitframes will use."],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_FontStrings() end,
						},
						fontSize = {
							order = 5,
							name = L["Font Size"],
							desc = L["Set the font size for unitframes."],
							type = "range",
							min = 6, max = 22, step = 1,
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_FontStrings() end,
						},	
						fontOutline = {
							order = 6,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = {
								['NONE'] = L['None'],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROME'] = 'MONOCHROME',
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
							set = function(info, value) E.db.unitframe[ info[#info] ] = value; UF:Update_FontStrings() end,
						},	
					},
				},
				allColorsGroup = {
					order = 4,
					type = 'group',
					guiInline = true,
					name = L['Colors'],
					get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
					set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,					
					args = {				
						colorsGroup = {
							order = 7,
							type = 'group',
							guiInline = true,
							name = HEALTH,
							get = function(info)
								local t = E.db.unitframe.colors[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {}
								local t = E.db.unitframe.colors[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,
							args = {
								healthclass = {
									order = 1,
									type = 'toggle',
									name = L['Class Health'],
									desc = L['Color health by classcolor or reaction.'],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,											
								},	
								colorhealthbyvalue = {
									order = 3,
									type = 'toggle',
									name = L['Health By Value'],
									desc = L['Color health by amount remaining.'],	
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,										
								},
								customhealthbackdrop = {
									order = 4,
									type = 'toggle',
									name = L['Custom Health Backdrop'],
									desc = L['Use the custom health backdrop color instead of a multiple of the main health color.'],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,										
								},
								classbackdrop = {
									order = 5,
									type = 'toggle',
									name = L['Class Backdrop'],
									desc = L['Color the health backdrop by class or reaction.'],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,										
								},								
								health = {
									order = 10,
									type = 'color',
									name = L['Health'],
								},
								health_backdrop = {
									order = 11,
									type = 'color',
									name = L['Health Backdrop'],
								},			
								tapped = {
									order = 12,
									type = 'color',
									name = L['Tapped'],
								},
								disconnected = {
									order = 13,
									type = 'color',
									name = L['Disconnected'],
								},	
							},
						},
						powerGroup = {
							order = 8,
							type = 'group',
							guiInline = true,
							name = L['Powers'],
							get = function(info)
								local t = E.db.unitframe.colors.power[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {}
								local t = E.db.unitframe.colors.power[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,	
							args = {
								powerclass = {
									order = 0,
									type = 'toggle',
									name = L['Class Power'],
									desc = L['Color power by classcolor or reaction.'],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,										
								},								
								MANA = {
									order = 1,
									name = MANA,
									type = 'color',
								},
								RAGE = {
									order = 2,
									name = RAGE,
									type = 'color',
								},	
								FOCUS = {
									order = 3,
									name = FOCUS,
									type = 'color',
								},	
								ENERGY = {
									order = 4,
									name = ENERGY,
									type = 'color',
								},		
								RUNIC_POWER = {
									order = 5,
									name = RUNIC_POWER,
									type = 'color',
								},									
							},
						},
						reactionGroup = {
							order = 9,
							type = 'group',
							guiInline = true,
							name = L['Reactions'],
							get = function(info)
								local t = E.db.unitframe.colors.reaction[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {}
								local t = E.db.unitframe.colors.reaction[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,	
							args = {
								BAD = {
									order = 1,
									name = L['Bad'],
									type = 'color',
								},	
								NEUTRAL = {
									order = 2,
									name = L['Neutral'],
									type = 'color',
								},	
								GOOD = {
									order = 3,
									name = L['Good'],
									type = 'color',
								},									
							},
						},	
						castBars = {
							order = 9,
							type = 'group',
							guiInline = true,
							name = L['Castbar'],
							get = function(info)
								local t = E.db.unitframe.colors[ info[#info] ]
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {}
								local t = E.db.unitframe.colors[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								UF:Update_AllFrames()
							end,			
							args = {
								castColor = {
									order = 1,
									name = L['Interruptable'],
									type = 'color',
								},	
								castNoInterrupt = {
									order = 2,
									name = L['Non-Interruptable'],
									type = 'color',
								},								
							},
						},
						auraBars = {
							order = 9,
							type = 'group',
							guiInline = true,
							name = L['Aura Bars'],
							args = {
								auraBarByType = {
									order = 1,
									name = L['By Type'],
									desc = L['Color aurabar debuffs by type.'],
									type = 'toggle',
								},
								BUFFS = {
									order = 10,
									name = L['Buffs'],
									type = 'color',
									get = function(info)
										local t = E.db.unitframe.colors.auraBarBuff
										return t.r, t.g, t.b, t.a
									end,
									set = function(info, r, g, b)
										E.db.general[ info[#info] ] = {}
										local t = E.db.unitframe.colors.auraBarBuff
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end,										
								},	
								DEBUFFS = {
									order = 11,
									name = L['Debuffs'],
									type = 'color',
									get = function(info)
										local t = E.db.unitframe.colors.auraBarDebuff
										return t.r, t.g, t.b, t.a
									end,
									set = function(info, r, g, b)
										E.db.general[ info[#info] ] = {}
										local t = E.db.unitframe.colors.auraBarDebuff
										t.r, t.g, t.b = r, g, b
										UF:Update_AllFrames()
									end,										
								},
							},
						},							
					},
				},
			},
		},
		},
}

--Player
E.Options.args.unitframe.args.player = {
	name = L['Player Frame'],
	type = 'group',
	order = 300,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['player'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['player'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		copyFrom = {
			type = 'select',
			order = 2,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = UF['units'],
			set = function(info, value) UF:MergeUnitSettings(value, 'player'); end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('player'); E:ResetMovers('Player Frame') end,
		},
		showAuras = {
			order = 4,
			type = 'execute',
			name = L['Show Auras'],
			func = function() 
				local frame = ElvUF_Player
				if frame.forceShowAuras then
					frame.forceShowAuras = nil; 
				else
					frame.forceShowAuras = true; 
				end
				
				UF:CreateAndUpdateUF('player') 
			end,
		},			
		width = {
			order = 4,
			name = L['Width'],
			type = 'range',
			min = 50, max = 500, step = 1,
			set = function(info, value) 
				if E.db.unitframe.units['player'].castbar.width == E.db.unitframe.units['player'][ info[#info] ] then
					E.db.unitframe.units['player'].castbar.width = value;
				end
				
				E.db.unitframe.units['player'][ info[#info] ] = value; 
				UF:CreateAndUpdateUF('player');
			end,
		},
		height = {
			order = 5,
			name = L['Height'],
			type = 'range',
			min = 10, max = 250, step = 1,
		},	
		lowmana = {
			order = 6,
			name = L['Low Mana Threshold'],
			desc = L['When you mana falls below this point, text will flash on the player frame.'],
			type = 'range',
			min = 0, max = 100, step = 1,
		},
		combatfade = {
			order = 7,
			name = L['Combat Fade'],
			desc = L['Fade the unitframe when out of combat, not casting, no target exists.'],
			type = 'toggle',
			set = function(info, value) 
				E.db.unitframe.units['player'][ info[#info] ] = value; 
				UF:CreateAndUpdateUF('player'); 

				if value == true then 
					ElvUF_Pet:SetParent(ElvUF_Player)
				else 
					ElvUF_Pet:SetParent(ElvUF_Parent) 
				end 
			end,
		},
		healPrediction = {
			order = 8,
			name = L['Heal Prediction'],
			desc = L['Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals.'],
			type = 'toggle',
		},
		restIcon = {
			order = 9,
			name = L['Rest Icon'],
			desc = L['Display the rested icon on the unitframe.'],
			type = 'toggle',
		},
		hideonnpc = {
			type = 'toggle',
			order = 10,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['player']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['player']['power'].hideonnpc = value; UF:CreateAndUpdateUF('player') end,
		},	
		customText = {
			order = 50,
			name = L['Custom Texts'],
			type = 'input',
			width = 'full',
			desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
			get = function() return '' end,
			set = function(info, textName)
				for object, _ in pairs(E.db.unitframe.units.player) do
					if object:lower() == textName:lower() then
						E:Print(L['The name you have selected is already in use by another element.'])
						return
					end
				end
				
				if not E.db.unitframe.units['player'].customTexts then
					E.db.unitframe.units['player'].customTexts = {};
				end
				
				if E.db.unitframe.units['player'].customTexts[textName] then
					E:Print(L['The name you have selected is already in use by another element.'])
					return;
				end
				
				E.db.unitframe.units['player'].customTexts[textName] = {
					['text_format'] = '',
					['size'] = E.db.unitframe.fontSize,
					['font'] = E.db.unitframe.font,
					['xOffset'] = 0,
					['yOffset'] = 0,
					['justifyH'] = 'CENTER',
					['fontOutline'] = E.db.unitframe.fontOutline
				};

				UF:CreateCustomTextGroup('player', textName)
				
				UF:CreateAndUpdateUF('player')
			end,
		},				
		health = {
			order = 100,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['player']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['health'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},			
			},
		},
		power = {
			order = 200,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['player']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['power'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},		
			},
		},	
		name = {
			order = 400,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['player']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['name'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},	
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},					
			},
		},
		pvp = {
			order = 450,
			type = 'group',
			name = PVP,
			get = function(info) return E.db.unitframe.units['player']['pvp'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['pvp'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},	
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},					
			},
		},		
		portrait = {
			order = 500,
			type = 'group',
			name = L['Portrait'],
			get = function(info) return E.db.unitframe.units['player']['portrait'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['portrait'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},
				width = {
					type = 'range',
					order = 2,
					name = L['Width'],
					min = 15, max = 150, step = 1,
				},
				overlay = {
					type = 'toggle',
					name = L['Overlay'],
					desc = L['Overlay the healthbar'],
					order = 3,
				},
				camDistanceScale = {
					type = 'range',
					name = L['Camera Distance Scale'],
					desc = L['How far away the portrait is from the camera.'],
					order = 4,
					min = 0.01, max = 4, step = 0.01,
				},
				style = {
					type = 'select',
					name = L['Style'],
					desc = L['Select the display method of the portrait.'],
					order = 5,
					values = {
						['2D'] = L['2D'],
						['3D'] = L['3D'],
					},
				},
			},
		},	
		buffs = {
			order = 600,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['player']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},	
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						noConsolidated = {
							order = 14,
							type = 'toggle',
							name = L["Block Raid Buffs"],
							desc = L["Block Raid Buffs"],		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},		
			},
		},	
		debuffs = {
			order = 700,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['player']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},			
			},
		},	
		castbar = {
			order = 800,
			type = 'group',
			name = L['Castbar'],
			get = function(info) return E.db.unitframe.units['player']['castbar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['castbar'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				matchsize = {
					order = 2,
					type = 'execute',
					name = L['Match Frame Width'],
					func = function() E.db.unitframe.units['player']['castbar']['width'] = E.db.unitframe.units['player']['width']; UF:CreateAndUpdateUF('player') end,
				},			
				forceshow = {
					order = 3,
					name = SHOW..' / '..HIDE,
					func = function() 
						local castbar = ElvUF_Player.Castbar
						if not castbar.oldHide then
							castbar.oldHide = castbar.Hide
							castbar.Hide = castbar.Show
							castbar:Show()
						else
							castbar.Hide = castbar.oldHide
							castbar.oldHide = nil
							castbar:Hide()						
						end
					end,
					type = 'execute',
				},
				width = {
					order = 4,
					name = L['Width'],
					type = 'range',
					min = 50, max = 600, step = 1,
				},
				height = {
					order = 5,
					name = L['Height'],
					type = 'range',
					min = 10, max = 85, step = 1,
				},		
				icon = {
					order = 6,
					name = L['Icon'],
					type = 'toggle',
				},			
				latency = {
					order = 9,
					name = L['Latency'],
					type = 'toggle',				
				},
				format = {
					order = 12,
					type = 'select',
					name = L['Format'],
					values = {
						['CURRENTMAX'] = L['Current / Max'],
						['CURRENT'] = L['Current'],
						['REMAINING'] = L['Remaining'],
					},
				},
				ticks = {
					order = 13,
					type = 'toggle',
					name = L['Ticks'],
					desc = L['Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste.'],
				},
				spark = {
					order = 14,
					type = 'toggle',
					name = L['Spark'],
					desc = L['Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop.'],
				},
				displayTarget = {
					order = 15,
					type = "toggle",
					name = L["Display Target"],
					desc = L["Display the target of the cast on the castbar."],
				},
			},
		},
		classbar = {
			order = 1000,
			type = 'group',
			name = L['Classbar'],
			get = function(info) return E.db.unitframe.units['player']['classbar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['classbar'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},
				height = {
					type = 'range',
					order = 2,
					name = L['Height'],
					min = 5, max = 15, step = 1,
				},	
				fill = {
					type = 'select',
					order = 3,
					name = L['Fill'],
					values = fillValues,
				},				
			},
		},
		aurabar = {
			order = 1100,
			type = 'group',
			name = L['Aura Bars'],
			get = function(info) return E.db.unitframe.units['player']['aurabar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['aurabar'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
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
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						noConsolidated = {
							order = 14,
							type = 'toggle',
							name = L["Block Raid Buffs"],
							desc = L["Block Raid Buffs"],		
						},						
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
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
		},	
		raidicon = {
			order = 2000,
			type = 'group',
			name = L['Raid Icon'],
			get = function(info) return E.db.unitframe.units['player']['raidicon'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['raidicon'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				attachTo = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				size = {
					type = 'range',
					name = L['Size'],
					order = 3,
					min = 8, max = 60, step = 1,
				},				
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -300, max = 300, step = 1,
				},			
			},
		},		
	},
}

--Target
E.Options.args.unitframe.args.target = {
	name = L['Target Frame'],
	type = 'group',
	order = 400,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['target'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['target'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		copyFrom = {
			type = 'select',
			order = 2,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = UF['units'],
			set = function(info, value) UF:MergeUnitSettings(value, 'target'); end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('target'); E:ResetMovers('Target Frame') end,
		},		
		showAuras = {
			order = 4,
			type = 'execute',
			name = L['Show Auras'],
			func = function() 
				local frame = ElvUF_Target
				if frame.forceShowAuras then
					frame.forceShowAuras = nil; 
				else
					frame.forceShowAuras = true; 
				end
				
				UF:CreateAndUpdateUF('target') 
			end,
		},			
		width = {
			order = 4,
			name = L['Width'],
			type = 'range',
			min = 50, max = 500, step = 1,
			set = function(info, value) 
				if E.db.unitframe.units['target'].castbar.width == E.db.unitframe.units['target'][ info[#info] ] then
					E.db.unitframe.units['target'].castbar.width = value;
				end
				
				E.db.unitframe.units['target'][ info[#info] ] = value; 
				UF:CreateAndUpdateUF('target');
			end,			
		},
		height = {
			order = 5,
			name = L['Height'],
			type = 'range',
			min = 10, max = 250, step = 1,
		},	
		healPrediction = {
			order = 6,
			name = L['Heal Prediction'],
			desc = L['Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals.'],
			type = 'toggle',
		},		
		hideonnpc = {
			type = 'toggle',
			order = 10,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['target']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['target']['power'].hideonnpc = value; UF:CreateAndUpdateUF('target') end,
		},
		smartAuraDisplay = {
			type = 'select',
			name = L['Smart Auras'],
			desc = L['When set the Buffs and Debuffs will toggle being displayed depending on if the unit is friendly or an enemy. This will not effect the aurabars module.'],
			order = 11,
			values = {
				['DISABLED'] = L['Disabled'],
				['SHOW_DEBUFFS_ON_FRIENDLIES'] = L['Friendlies: Show Debuffs'],
				['SHOW_BUFFS_ON_FRIENDLIES'] = L['Friendlies: Show Buffs'],
			},
		},
		customText = {
			order = 50,
			name = L['Custom Texts'],
			type = 'input',
			width = 'full',
			desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
			get = function() return '' end,
			set = function(info, textName)
				for object, _ in pairs(E.db.unitframe.units.target) do
					if object:lower() == textName:lower() then
						E:Print(L['The name you have selected is already in use by another element.'])
						return
					end
				end
				
				if not E.db.unitframe.units['target'].customTexts then
					E.db.unitframe.units['target'].customTexts = {};
				end
			
				if E.db.unitframe.units['target'].customTexts[textName] then
					E:Print(L['The name you have selected is already in use by another element.'])
					return;
				end			
				
				E.db.unitframe.units['target'].customTexts[textName] = {
					['text_format'] = '',
					['size'] = 12,
					['font'] = E.db.unitframe.font,
					['xOffset'] = 0,
					['yOffset'] = 0,	
					['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
				};

				UF:CreateCustomTextGroup('target', textName)
				
				UF:CreateAndUpdateUF('target')
			end,
		},				
		health = {
			order = 100,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['target']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['health'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				position = {
					type = 'select',
					order = 3,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},
		power = {
			order = 200,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['target']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['power'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},	
		name = {
			order = 300,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['target']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['name'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},				
			},
		},
		portrait = {
			order = 400,
			type = 'group',
			name = L['Portrait'],
			get = function(info) return E.db.unitframe.units['target']['portrait'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['portrait'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},
				width = {
					type = 'range',
					order = 2,
					name = L['Width'],
					min = 15, max = 150, step = 1,
				},
				overlay = {
					type = 'toggle',
					name = L['Overlay'],
					desc = L['Overlay the healthbar'],
					order = 3,
				},
				camDistanceScale = {
					type = 'range',
					name = L['Camera Distance Scale'],
					desc = L['How far away the portrait is from the camera.'],
					order = 4,
					min = 0.01, max = 4, step = 0.01,
				},
				style = {
					type = 'select',
					name = L['Style'],
					desc = L['Select the display method of the portrait.'],
					order = 5,
					values = {
						['2D'] = L['2D'],
						['3D'] = L['3D'],
					},
				},
			},
		},	
		buffs = {
			order = 500,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['target']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
					set = function(info, value) E.db.unitframe.units['target']['buffs'][ info[#info] ] = value; E.db.unitframe.units['target'].smartAuraDisplay = 'DISABLED'; UF:CreateAndUpdateUF('target') end,
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},	
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},	
						},
						noConsolidated = {
							order = 14,
							guiInline = true,
							type = 'group',
							name = L["Block Raid Buffs"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].noConsolidated.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].noConsolidated.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['buffs'].noConsolidated.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['buffs'].noConsolidated.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		debuffs = {
			order = 600,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['target']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
					set = function(info, value) E.db.unitframe.units['target']['debuffs'][ info[#info] ] = value; E.db.unitframe.units['target'].smartAuraDisplay = 'DISABLED'; UF:CreateAndUpdateUF('target') end,
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},	
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['debuffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['debuffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},	
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},
			},
		},	
		castbar = {
			order = 700,
			type = 'group',
			name = L['Castbar'],
			get = function(info) return E.db.unitframe.units['target']['castbar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['castbar'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				matchsize = {
					order = 2,
					type = 'execute',
					name = L['Match Frame Width'],
					func = function() E.db.unitframe.units['target']['castbar']['width'] = E.db.unitframe.units['target']['width']; UF:CreateAndUpdateUF('target') end,
				},			
				forceshow = {
					order = 3,
					name = SHOW..' / '..HIDE,
					func = function() 
						local castbar = ElvUF_Target.Castbar
						if not castbar.oldHide then
							castbar.oldHide = castbar.Hide
							castbar.Hide = castbar.Show
							castbar:Show()
						else
							castbar.Hide = castbar.oldHide
							castbar.oldHide = nil
							castbar:Hide()						
						end
					end,
					type = 'execute',
				},
				width = {
					order = 4,
					name = L['Width'],
					type = 'range',
					min = 50, max = 600, step = 1,
				},
				height = {
					order = 5,
					name = L['Height'],
					type = 'range',
					min = 10, max = 85, step = 1,
				},		
				icon = {
					order = 6,
					name = L['Icon'],
					type = 'toggle',
				},			
				format = {
					order = 11,
					type = 'select',
					name = L['Format'],
					values = {
						['CURRENTMAX'] = L['Current / Max'],
						['CURRENT'] = L['Current'],
						['REMAINING'] = L['Remaining'],
					},
				},		
				spark = {
					order = 12,
					type = 'toggle',
					name = L['Spark'],
					desc = L['Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop.'],
				},				
			},
		},
		combobar = {
			order = 800,
			type = 'group',
			name = L['Combobar'],
			get = function(info) return E.db.unitframe.units['target']['combobar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['combobar'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},
				height = {
					type = 'range',
					order = 2,
					name = L['Height'],
					min = 5, max = 15, step = 1,
				},	
				fill = {
					type = 'select',
					order = 3,
					name = L['Fill'],
					values = fillValues,
				},				
			},
		},	
		aurabar = {
			order = 900,
			type = 'group',
			name = L['Aura Bars'],
			get = function(info) return E.db.unitframe.units['target']['aurabar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['aurabar'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
					set = function(info, value) E.db.unitframe.units['target']['aurabar'][ info[#info] ] = value; E.db.unitframe.units['target'].smartAuraDisplay = 'DISABLED'; UF:CreateAndUpdateUF('target') end,
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
					set = function(info, value) E.db.unitframe.units['target']['aurabar'][ info[#info] ] = value; E.db.unitframe.units['target'].smartAuraDisplay = 'DISABLED'; UF:CreateAndUpdateUF('target') end,
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
						['PLAYER_AURABARS'] = L['Player Frame Aura Bars'],
					},					
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].playerOnly.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].playerOnly.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].noDuration.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].noDuration.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},	
						},
						noConsolidated = {
							order = 14,
							guiInline = true,
							type = 'group',
							name = L["Block Raid Buffs"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].noConsolidated.friendly end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].noConsolidated.friendly = value; UF:CreateAndUpdateUF('target') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['target']['aurabar'].noConsolidated.enemy end,
									set = function(info, value) E.db.unitframe.units['target']['aurabar'].noConsolidated.enemy = value; UF:CreateAndUpdateUF('target') end,										
								}
							},		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
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
		},
		raidicon = {
			order = 2000,
			type = 'group',
			name = L['Raid Icon'],
			get = function(info) return E.db.unitframe.units['target']['raidicon'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['target']['raidicon'][ info[#info] ] = value; UF:CreateAndUpdateUF('target') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				attachTo = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				size = {
					type = 'range',
					name = L['Size'],
					order = 3,
					min = 8, max = 60, step = 1,
				},				
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -300, max = 300, step = 1,
				},			
			},
		},		
	},
}

--TargetTarget
E.Options.args.unitframe.args.targettarget = {
	name = L['TargetTarget Frame'],
	type = 'group',
	order = 500,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['targettarget'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['targettarget'][ info[#info] ] = value; UF:CreateAndUpdateUF('targettarget') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		copyFrom = {
			type = 'select',
			order = 2,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = UF['units'],
			set = function(info, value) UF:MergeUnitSettings(value, 'targettarget'); end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('targettarget'); E:ResetMovers('TargetTarget Frame') end,
		},	
		showAuras = {
			order = 4,
			type = 'execute',
			name = L['Show Auras'],
			func = function() 
				local frame = ElvUF_TargetTarget
				if frame.forceShowAuras then
					frame.forceShowAuras = nil; 
				else
					frame.forceShowAuras = true; 
				end
				
				UF:CreateAndUpdateUF('targettarget') 
			end,
		},			
		width = {
			order = 4,
			name = L['Width'],
			type = 'range',
			min = 50, max = 500, step = 1,
		},
		height = {
			order = 5,
			name = L['Height'],
			type = 'range',
			min = 10, max = 250, step = 1,
		},	
		hideonnpc = {
			type = 'toggle',
			order = 6,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['targettarget']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['targettarget']['power'].hideonnpc = value; UF:CreateAndUpdateUF('targettarget') end,
		},
		customText = {
			order = 50,
			name = L['Custom Texts'],
			type = 'input',
			width = 'full',
			desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
			get = function() return '' end,
			set = function(info, textName)
				for object, _ in pairs(E.db.unitframe.units.targettarget) do
					if object:lower() == textName:lower() then
						E:Print(L['The name you have selected is already in use by another element.'])
						return
					end
				end
				
				if not E.db.unitframe.units['targettarget'].customTexts then
					E.db.unitframe.units['targettarget'].customTexts = {};
				end
				
				if E.db.unitframe.units['targettarget'].customTexts[textName] then
					E:Print(L['The name you have selected is already in use by another element.'])
					return;
				end				
				
				E.db.unitframe.units['targettarget'].customTexts[textName] = {
					['text_format'] = '',
					['size'] = 12,
					['font'] = E.db.unitframe.font,
					['xOffset'] = 0,
					['yOffset'] = 0,	
					['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
				};

				UF:CreateCustomTextGroup('targettarget', textName)
				
				UF:CreateAndUpdateUF('targettarget')
			end,
		},			
		health = {
			order = 7,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['targettarget']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['targettarget']['health'][ info[#info] ] = value; UF:CreateAndUpdateUF('targettarget') end,
			args = {
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				position = {
					type = 'select',
					order = 3,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},
		power = {
			order = 8,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['targettarget']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['targettarget']['power'][ info[#info] ] = value; UF:CreateAndUpdateUF('targettarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},						
			},
		},	
		name = {
			order = 9,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['targettarget']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['targettarget']['name'][ info[#info] ] = value; UF:CreateAndUpdateUF('targettarget') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},		
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},				
			},
		},
		buffs = {
			order = 11,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['targettarget']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['targettarget']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('targettarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},	
						},
						noConsolidated = {
							order = 14,
							guiInline = true,
							type = 'group',
							name = L["Block Raid Buffs"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].noConsolidated.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].noConsolidated.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['buffs'].noConsolidated.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['buffs'].noConsolidated.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		debuffs = {
			order = 12,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['targettarget']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('targettarget'); end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},	
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('targettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['targettarget']['debuffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['targettarget']['debuffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('targettarget') end,										
								}
							},	
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		raidicon = {
			order = 2000,
			type = 'group',
			name = L['Raid Icon'],
			get = function(info) return E.db.unitframe.units['targettarget']['raidicon'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['targettarget']['raidicon'][ info[#info] ] = value; UF:CreateAndUpdateUF('targettarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				attachTo = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				size = {
					type = 'range',
					name = L['Size'],
					order = 3,
					min = 8, max = 60, step = 1,
				},				
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -300, max = 300, step = 1,
				},			
			},
		},			
	},
}

--Focus
E.Options.args.unitframe.args.focus = {
	name = L['Focus Frame'],
	type = 'group',
	order = 600,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['focus'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['focus'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		copyFrom = {
			type = 'select',
			order = 2,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = UF['units'],
			set = function(info, value) UF:MergeUnitSettings(value, 'focus'); end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('focus'); E:ResetMovers('Focus Frame') end,
		},	
		showAuras = {
			order = 4,
			type = 'execute',
			name = L['Show Auras'],
			func = function() 
				local frame = ElvUF_Focus
				if frame.forceShowAuras then
					frame.forceShowAuras = nil; 
				else
					frame.forceShowAuras = true; 
				end
				
				UF:CreateAndUpdateUF('focus') 
			end,
		},			
		width = {
			order = 4,
			name = L['Width'],
			type = 'range',
			min = 50, max = 500, step = 1,
		},
		height = {
			order = 5,
			name = L['Height'],
			type = 'range',
			min = 10, max = 250, step = 1,
		},	
		healPrediction = {
			order = 6,
			name = L['Heal Prediction'],
			desc = L['Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals.'],
			type = 'toggle',
		},
		hideonnpc = {
			type = 'toggle',
			order = 10,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['focus']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['focus']['power'].hideonnpc = value; UF:CreateAndUpdateUF('focus') end,
		},	
		smartAuraDisplay = {
			type = 'select',
			name = L['Smart Auras'],
			desc = L['When set the Buffs and Debuffs will toggle being displayed depending on if the unit is friendly or an enemy. This will not effect the aurabars module.'],
			order = 11,
			values = {
				['DISABLED'] = L['Disabled'],
				['SHOW_DEBUFFS_ON_FRIENDLIES'] = L['Friendlies: Show Debuffs'],
				['SHOW_BUFFS_ON_FRIENDLIES'] = L['Friendlies: Show Buffs'],
			},
		},
		customText = {
			order = 50,
			name = L['Custom Texts'],
			type = 'input',
			width = 'full',
			desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
			get = function() return '' end,
			set = function(info, textName)
				for object, _ in pairs(E.db.unitframe.units.focus) do
					if object:lower() == textName:lower() then
						E:Print(L['The name you have selected is already in use by another element.'])
						return
					end
				end
				
				if not E.db.unitframe.units['focus'].customTexts then
					E.db.unitframe.units['focus'].customTexts = {};
				end
				
				if E.db.unitframe.units['focus'].customTexts[textName] then
					E:Print(L['The name you have selected is already in use by another element.'])
					return;
				end				
				
				E.db.unitframe.units['focus'].customTexts[textName] = {
					['text_format'] = '',
					['size'] = 12,
					['font'] = E.db.unitframe.font,
					['xOffset'] = 0,
					['yOffset'] = 0,	
					['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
				};

				UF:CreateCustomTextGroup('focus', textName)
				
				UF:CreateAndUpdateUF('focus')
			end,
		},				
		health = {
			order = 100,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['focus']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focus']['health'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
			args = {
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				position = {
					type = 'select',
					order = 3,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},
		power = {
			order = 200,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['focus']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focus']['power'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},	
		name = {
			order = 300,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['focus']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focus']['name'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},				
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},				
			},
		},
		buffs = {
			order = 400,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['focus']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focus']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},	
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},	
						},
						noConsolidated = {
							order = 14,
							guiInline = true,
							type = 'group',
							name = L["Block Raid Buffs"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].noConsolidated.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].noConsolidated.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['buffs'].noConsolidated.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['buffs'].noConsolidated.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		debuffs = {
			order = 500,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['focus']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focus']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['debuffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['debuffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},	
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		castbar = {
			order = 600,
			type = 'group',
			name = L['Castbar'],
			get = function(info) return E.db.unitframe.units['focus']['castbar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focus']['castbar'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				matchsize = {
					order = 2,
					type = 'execute',
					name = L['Match Frame Width'],
					func = function() E.db.unitframe.units['focus']['castbar']['width'] = E.db.unitframe.units['focus']['width']; UF:CreateAndUpdateUF('focus') end,
				},			
				forceshow = {
					order = 3,
					name = SHOW..' / '..HIDE,
					func = function() 
						local castbar = ElvUF_Focus.Castbar
						if not castbar.oldHide then
							castbar.oldHide = castbar.Hide
							castbar.Hide = castbar.Show
							castbar:Show()
						else
							castbar.Hide = castbar.oldHide
							castbar.oldHide = nil
							castbar:Hide()						
						end
					end,
					type = 'execute',
				},
				width = {
					order = 4,
					name = L['Width'],
					type = 'range',
					min = 50, max = 600, step = 1,
				},
				height = {
					order = 5,
					name = L['Height'],
					type = 'range',
					min = 10, max = 85, step = 1,
				},		
				icon = {
					order = 6,
					name = L['Icon'],
					type = 'toggle',
				},			
				format = {
					order = 11,
					type = 'select',
					name = L['Format'],
					values = {
						['CURRENTMAX'] = L['Current / Max'],
						['CURRENT'] = L['Current'],
						['REMAINING'] = L['Remaining'],
					},
				},	
				spark = {
					order = 12,
					type = 'toggle',
					name = L['Spark'],
					desc = L['Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop.'],
				},				
			},
		},	
		aurabar = {
			order = 700,
			type = 'group',
			name = L['Aura Bars'],
			get = function(info) return E.db.unitframe.units['focus']['aurabar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focus']['aurabar'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
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
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].playerOnly.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].playerOnly.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].noDuration.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].noDuration.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},	
						},
						noConsolidated = {
							order = 14,
							guiInline = true,
							type = 'group',
							name = L["Block Raid Buffs"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].noConsolidated.friendly end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].noConsolidated.friendly = value; UF:CreateAndUpdateUF('focus') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focus']['aurabar'].noConsolidated.enemy end,
									set = function(info, value) E.db.unitframe.units['focus']['aurabar'].noConsolidated.enemy = value; UF:CreateAndUpdateUF('focus') end,										
								}
							},		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
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
		},	
		raidicon = {
			order = 2000,
			type = 'group',
			name = L['Raid Icon'],
			get = function(info) return E.db.unitframe.units['focus']['raidicon'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focus']['raidicon'][ info[#info] ] = value; UF:CreateAndUpdateUF('focus') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				attachTo = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				size = {
					type = 'range',
					name = L['Size'],
					order = 3,
					min = 8, max = 60, step = 1,
				},				
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -300, max = 300, step = 1,
				},			
			},
		},			
	},
}

--Focus Target
E.Options.args.unitframe.args.focustarget = {
	name = L['FocusTarget Frame'],
	type = 'group',
	order = 700,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['focustarget'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['focustarget'][ info[#info] ] = value; UF:CreateAndUpdateUF('focustarget') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		copyFrom = {
			type = 'select',
			order = 2,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = UF['units'],
			set = function(info, value) UF:MergeUnitSettings(value, 'focustarget'); end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('focustarget'); E:ResetMovers('FocusTarget Frame') end,
		},	
		showAuras = {
			order = 4,
			type = 'execute',
			name = L['Show Auras'],
			func = function() 
				local frame = ElvUF_FocusTarget
				if frame.forceShowAuras then
					frame.forceShowAuras = nil; 
				else
					frame.forceShowAuras = true; 
				end
				
				UF:CreateAndUpdateUF('focustarget') 
			end,
		},			
		width = {
			order = 4,
			name = L['Width'],
			type = 'range',
			min = 50, max = 500, step = 1,
		},
		height = {
			order = 5,
			name = L['Height'],
			type = 'range',
			min = 10, max = 250, step = 1,
		},	
		hideonnpc = {
			type = 'toggle',
			order = 6,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['focustarget']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['focustarget']['power'].hideonnpc = value; UF:CreateAndUpdateUF('focustarget') end,
		},	
		customText = {
			order = 50,
			name = L['Custom Texts'],
			type = 'input',
			width = 'full',
			desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
			get = function() return '' end,
			set = function(info, textName)
				for object, _ in pairs(E.db.unitframe.units.focustarget) do
					if object:lower() == textName:lower() then
						E:Print(L['The name you have selected is already in use by another element.'])
						return
					end
				end
				
				local unit = 'focustarget'
				if not E.db.unitframe.units[unit].customTexts then
					E.db.unitframe.units[unit].customTexts = {};
				end
				
				if E.db.unitframe.units[unit].customTexts[textName] then
					E:Print(L['The name you have selected is already in use by another element.'])
					return;
				end				
				
				E.db.unitframe.units[unit].customTexts[textName] = {
					['text_format'] = '',
					['size'] = 12,
					['font'] = E.db.unitframe.font,
					['xOffset'] = 0,
					['yOffset'] = 0,	
					['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
				};

				UF:CreateCustomTextGroup(unit, textName)
				
				UF:CreateAndUpdateUF(unit)
			end,
		},				
		health = {
			order = 7,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['focustarget']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focustarget']['health'][ info[#info] ] = value; UF:CreateAndUpdateUF('focustarget') end,
			args = {
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				position = {
					type = 'select',
					order = 3,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},
		power = {
			order = 8,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['focustarget']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focustarget']['power'][ info[#info] ] = value; UF:CreateAndUpdateUF('focustarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},	
		name = {
			order = 9,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['focustarget']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focustarget']['name'][ info[#info] ] = value; UF:CreateAndUpdateUF('focustarget') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},				
			},
		},
		buffs = {
			order = 11,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['focustarget']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focustarget']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('focustarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},	
						},
						noConsolidated = {
							order = 14,
							guiInline = true,
							type = 'group',
							name = L["Block Raid Buffs"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].noConsolidated.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].noConsolidated.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['buffs'].noConsolidated.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['buffs'].noConsolidated.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		debuffs = {
			order = 12,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['focustarget']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('focustarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('focustarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['focustarget']['debuffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['focustarget']['debuffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('focustarget') end,										
								}
							},	
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		raidicon = {
			order = 2000,
			type = 'group',
			name = L['Raid Icon'],
			get = function(info) return E.db.unitframe.units['focustarget']['raidicon'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['focustarget']['raidicon'][ info[#info] ] = value; UF:CreateAndUpdateUF('focustarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				attachTo = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				size = {
					type = 'range',
					name = L['Size'],
					order = 3,
					min = 8, max = 60, step = 1,
				},				
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -300, max = 300, step = 1,
				},			
			},
		},			
	},
}

--Pet
E.Options.args.unitframe.args.pet = {
	name = L['Pet Frame'],
	type = 'group',
	order = 800,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['pet'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['pet'][ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		copyFrom = {
			type = 'select',
			order = 2,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = UF['units'],
			set = function(info, value) UF:MergeUnitSettings(value, 'pet'); end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('pet'); E:ResetMovers('Pet Frame') end,
		},
		showAuras = {
			order = 4,
			type = 'execute',
			name = L['Show Auras'],
			func = function() 
				local frame = ElvUF_Pet
				if frame.forceShowAuras then
					frame.forceShowAuras = nil; 
				else
					frame.forceShowAuras = true; 
				end
				
				UF:CreateAndUpdateUF('pet') 
			end,
		},			
		width = {
			order = 4,
			name = L['Width'],
			type = 'range',
			min = 50, max = 500, step = 1,
		},
		height = {
			order = 5,
			name = L['Height'],
			type = 'range',
			min = 10, max = 250, step = 1,
		},	
		healPrediction = {
			order = 6,
			name = L['Heal Prediction'],
			desc = L['Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals.'],
			type = 'toggle',
		},		
		hideonnpc = {
			type = 'toggle',
			order = 10,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['pet']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['pet']['power'].hideonnpc = value; UF:CreateAndUpdateUF('pet') end,
		},	
		customText = {
			order = 50,
			name = L['Custom Texts'],
			type = 'input',
			width = 'full',
			desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
			get = function() return '' end,
			set = function(info, textName)
				for object, _ in pairs(E.db.unitframe.units.pet) do
					if object:lower() == textName:lower() then
						E:Print(L['The name you have selected is already in use by another element.'])
						return
					end
				end
				
				local unit = 'pet'
				if not E.db.unitframe.units[unit].customTexts then
					E.db.unitframe.units[unit].customTexts = {};
				end
				
				if E.db.unitframe.units[unit].customTexts[textName] then
					E:Print(L['The name you have selected is already in use by another element.'])
					return;
				end						
				
				E.db.unitframe.units[unit].customTexts[textName] = {
					['text_format'] = '',
					['size'] = 12,
					['font'] = E.db.unitframe.font,
					['xOffset'] = 0,
					['yOffset'] = 0,	
					['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
				};

				UF:CreateCustomTextGroup(unit, textName)
				
				UF:CreateAndUpdateUF(unit)
			end,
		},				
		health = {
			order = 100,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['pet']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pet']['health'][ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
			args = {
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				position = {
					type = 'select',
					order = 3,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},
		power = {
			order = 200,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['pet']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pet']['power'][ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},	
		name = {
			order = 300,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['pet']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pet']['name'][ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},	
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},				
			},
		},
		buffs = {
			order = 400,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['pet']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pet']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						noConsolidated = {
							order = 14,
							type = 'toggle',
							name = L["Block Raid Buffs"],
							desc = L["Block Raid Buffs"],		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},				
			},
		},	
		debuffs = {
			order = 500,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['pet']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pet']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},				
			},
		},	
		buffIndicator = {
			order = 600,
			type = 'group',
			name = L['Buff Indicator'],
			get = function(info) return E.db.unitframe.units['pet']['buffIndicator'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pet']['buffIndicator'][ info[#info] ] = value; UF:CreateAndUpdateUF('pet') end,
			args = {
				enable = {
					type = 'toggle',
					name = L['Enable'],
					order = 1,
				},
				size = {
					type = 'range',
					name = L['Size'],
					desc = L['Size of the indicator icon.'],
					order = 3,
					min = 4, max = 15, step = 1,
				},
				fontSize = {
					type = 'range',
					name = L['Font Size'],
					order = 4,
					min = 7, max = 22, step = 1,
				},
			},
		},			
	},
}

--Pet Target
E.Options.args.unitframe.args.pettarget = {
	name = L['PetTarget Frame'],
	type = 'group',
	order = 900,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['pettarget'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['pettarget'][ info[#info] ] = value; UF:CreateAndUpdateUF('pettarget') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		copyFrom = {
			type = 'select',
			order = 2,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = UF['units'],
			set = function(info, value) UF:MergeUnitSettings(value, 'pettarget'); end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('pettarget'); E:ResetMovers('PetTarget Frame') end,
		},	
		showAuras = {
			order = 4,
			type = 'execute',
			name = L['Show Auras'],
			func = function() 
				local frame = ElvUF_PetTarget
				if frame.forceShowAuras then
					frame.forceShowAuras = nil; 
				else
					frame.forceShowAuras = true; 
				end
				
				UF:CreateAndUpdateUF('pettarget') 
			end,
		},			
		width = {
			order = 4,
			name = L['Width'],
			type = 'range',
			min = 50, max = 500, step = 1,
		},
		height = {
			order = 5,
			name = L['Height'],
			type = 'range',
			min = 10, max = 250, step = 1,
		},	
		hideonnpc = {
			type = 'toggle',
			order = 6,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['pettarget']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['pettarget']['power'].hideonnpc = value; UF:CreateAndUpdateUF('pettarget') end,
		},		
		customText = {
			order = 50,
			name = L['Custom Texts'],
			type = 'input',
			width = 'full',
			desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
			get = function() return '' end,
			set = function(info, textName)
				for object, _ in pairs(E.db.unitframe.units.pettarget) do
					if object:lower() == textName:lower() then
						E:Print(L['The name you have selected is already in use by another element.'])
						return
					end
				end
				
				local unit = 'pettarget'
				if not E.db.unitframe.units[unit].customTexts then
					E.db.unitframe.units[unit].customTexts = {};
				end
				
				if E.db.unitframe.units[unit].customTexts[textName] then
					E:Print(L['The name you have selected is already in use by another element.'])
					return;
				end						
				
				E.db.unitframe.units[unit].customTexts[textName] = {
					['text_format'] = '',
					['size'] = 12,
					['font'] = E.db.unitframe.font,
					['xOffset'] = 0,
					['yOffset'] = 0,	
					['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
				};

				UF:CreateCustomTextGroup(unit, textName)
				
				UF:CreateAndUpdateUF(unit)
			end,
		},				
		health = {
			order = 7,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['pettarget']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pettarget']['health'][ info[#info] ] = value; UF:CreateAndUpdateUF('pettarget') end,
			args = {
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				position = {
					type = 'select',
					order = 3,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},
		power = {
			order = 8,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['pettarget']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pettarget']['power'][ info[#info] ] = value; UF:CreateAndUpdateUF('pettarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},	
		name = {
			order = 9,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['pettarget']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pettarget']['name'][ info[#info] ] = value; UF:CreateAndUpdateUF('pettarget') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},	
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},				
			},
		},
		buffs = {
			order = 11,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['pettarget']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pettarget']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('pettarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},	
						},
						noConsolidated = {
							order = 14,
							guiInline = true,
							type = 'group',
							name = L["Block Raid Buffs"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].noConsolidated.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].noConsolidated.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['buffs'].noConsolidated.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['buffs'].noConsolidated.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		debuffs = {
			order = 12,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['pettarget']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateUF('pettarget') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].playerOnly.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].playerOnly.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].noDuration.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].noDuration.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUF('pettarget') end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['pettarget']['debuffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['pettarget']['debuffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUF('pettarget') end,										
								}
							},	
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
	},
}

--Boss Frames
E.Options.args.unitframe.args.boss = {
	name = L['Boss Frames'],
	type = 'group',
	order = 1000,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['boss'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['boss'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		copyFrom = {
			type = 'select',
			order = 2,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = {
				['boss'] = 'boss',
				['arena'] = 'arena',
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'boss'); end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('boss'); E:ResetMovers('Boss Frames') end,
		},		
		displayFrames = {
			type = 'execute',
			order = 3,
			name = L['Display Frames'],
			desc = L['Force the frames to show, they will act as if they are the player frame.'],
			func = function() UF:ToggleForceShowGroupFrames('boss', 4) end,
		},
		width = {
			order = 4,
			name = L['Width'],
			type = 'range',
			min = 50, max = 500, step = 1,
			set = function(info, value) 
				if E.db.unitframe.units['boss'].castbar.width == E.db.unitframe.units['boss'][ info[#info] ] then
					E.db.unitframe.units['boss'].castbar.width = value;
				end
				
				E.db.unitframe.units['boss'][ info[#info] ] = value; 
				UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES);
			end,			
		},
		height = {
			order = 5,
			name = L['Height'],
			type = 'range',
			min = 10, max = 250, step = 1,
		},	
		hideonnpc = {
			type = 'toggle',
			order = 7,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['boss']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['boss']['power'].hideonnpc = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
		},
		growthDirection = {
			order = 8,
			name = L['Growth Direction'],
			type = 'select',
			values = {
				['UP'] = L['Up'],
				['DOWN'] = L['Down'],
			},
		},			
		customText = {
			order = 50,
			name = L['Custom Texts'],
			type = 'input',
			width = 'full',
			desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
			get = function() return '' end,
			set = function(info, textName)
				for object, _ in pairs(E.db.unitframe.units.boss) do
					if object:lower() == textName:lower() then
						E:Print(L['The name you have selected is already in use by another element.'])
						return
					end
				end
				
				local unit = 'boss'
				if not E.db.unitframe.units[unit].customTexts then
					E.db.unitframe.units[unit].customTexts = {};
				end
				
				if E.db.unitframe.units[unit].customTexts[textName] then
					E:Print(L['The name you have selected is already in use by another element.'])
					return;
				end						
				
				E.db.unitframe.units[unit].customTexts[textName] = {
					['text_format'] = '',
					['size'] = 12,
					['font'] = E.db.unitframe.font,
					['xOffset'] = 0,
					['yOffset'] = 0,	
					['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
				};

				UF:CreateCustomTextGroup(unit, textName)
				
				UF:CreateAndUpdateUFGroup(unit, MAX_BOSS_FRAMES)
			end,
		},				
		health = {
			order = 8,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['boss']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['boss']['health'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
			args = {
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				position = {
					type = 'select',
					order = 3,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},
		power = {
			order = 9,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['boss']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['boss']['power'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},	
		name = {
			order = 9,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['boss']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['boss']['name'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},		
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},				
			},
		},
		portrait = {
			order = 10,
			type = 'group',
			name = L['Portrait'],
			get = function(info) return E.db.unitframe.units['boss']['portrait'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['boss']['portrait'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},
				width = {
					type = 'range',
					order = 2,
					name = L['Width'],
					min = 15, max = 150, step = 1,
				},
				overlay = {
					type = 'toggle',
					name = L['Overlay'],
					desc = L['Overlay the healthbar'],
					order = 3,
				},
				camDistanceScale = {
					type = 'range',
					name = L['Camera Distance Scale'],
					desc = L['How far away the portrait is from the camera.'],
					order = 4,
					min = 0.01, max = 4, step = 0.01,
				},
				style = {
					type = 'select',
					name = L['Style'],
					desc = L['Select the display method of the portrait.'],
					order = 5,
					values = {
						['2D'] = L['2D'],
						['3D'] = L['3D'],
					},
				},
			},
		},	
		buffs = {
			order = 11,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['boss']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['boss']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						noConsolidated = {
							order = 14,
							type = 'toggle',
							name = L["Block Raid Buffs"],
							desc = L["Block Raid Buffs"],		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},				
			},
		},	
		debuffs = {
			order = 12,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['boss']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['boss']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},				
			},
		},	
		castbar = {
			order = 13,
			type = 'group',
			name = L['Castbar'],
			get = function(info) return E.db.unitframe.units['boss']['castbar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['boss']['castbar'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				matchsize = {
					order = 2,
					type = 'execute',
					name = L['Match Frame Width'],
					func = function() E.db.unitframe.units['boss']['castbar']['width'] = E.db.unitframe.units['boss']['width']; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
				},				
				width = {
					order = 3,
					name = L['Width'],
					type = 'range',
					min = 50, max = 600, step = 1,
				},
				height = {
					order = 4,
					name = L['Height'],
					type = 'range',
					min = 10, max = 85, step = 1,
				},		
				icon = {
					order = 5,
					name = L['Icon'],
					type = 'toggle',
				},
				format = {
					order = 9,
					type = 'select',
					name = L['Format'],
					values = {
						['CURRENTMAX'] = L['Current / Max'],
						['CURRENT'] = L['Current'],
						['REMAINING'] = L['Remaining'],
					},
				},		
				spark = {
					order = 10,
					type = 'toggle',
					name = L['Spark'],
					desc = L['Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop.'],
				},				
			},
		},	
		raidicon = {
			order = 2000,
			type = 'group',
			name = L['Raid Icon'],
			get = function(info) return E.db.unitframe.units['boss']['raidicon'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['boss']['raidicon'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('boss', MAX_BOSS_FRAMES) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				attachTo = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				size = {
					type = 'range',
					name = L['Size'],
					order = 3,
					min = 8, max = 60, step = 1,
				},				
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -300, max = 300, step = 1,
				},			
			},
		},	
	},
}

--Arena Frames
E.Options.args.unitframe.args.arena = {
	name = L['Arena Frames'],
	type = 'group',
	order = 1000,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['arena'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['arena'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		copyFrom = {
			type = 'select',
			order = 2,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = {
				['boss'] = 'boss',
				['arena'] = 'arena',
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'arena'); end,
		},
		resetSettings = {
			type = 'execute',
			order = 3,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('arena'); E:ResetMovers('Arena Frames') end,
		},			
		displayFrames = {
			type = 'execute',
			order = 3,
			name = L['Display Frames'],
			desc = L['Force the frames to show, they will act as if they are the player frame.'],
			func = function() UF:ToggleForceShowGroupFrames('arena', 5) end,
		},		
		width = {
			order = 4,
			name = L['Width'],
			type = 'range',
			min = 50, max = 500, step = 1,
			set = function(info, value) 
				if E.db.unitframe.units['arena'].castbar.width == E.db.unitframe.units['arena'][ info[#info] ] then
					E.db.unitframe.units['arena'].castbar.width = value;
				end
				
				E.db.unitframe.units['arena'][ info[#info] ] = value; 
				UF:CreateAndUpdateUFGroup('arena', 5);
			end,			
		},
		height = {
			order = 5,
			name = L['Height'],
			type = 'range',
			min = 10, max = 250, step = 1,
		},	
		hideonnpc = {
			type = 'toggle',
			order = 7,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['arena']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['arena']['power'].hideonnpc = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
		},
		pvpSpecIcon = {
			order = 8,
			name = L['Spec Icon'],
			desc = L['Display icon on arena frame indicating the units talent specialization or the units faction if inside a battleground.'],
			type = 'toggle',
		},
		growthDirection = {
			order = 9,
			name = L['Growth Direction'],
			type = 'select',
			values = {
				['UP'] = L['Up'],
				['DOWN'] = L['Down'],
			},
		},
		customText = {
			order = 50,
			name = L['Custom Texts'],
			type = 'input',
			width = 'full',
			desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
			get = function() return '' end,
			set = function(info, textName)
				for object, _ in pairs(E.db.unitframe.units.arena) do
					if object:lower() == textName:lower() then
						E:Print(L['The name you have selected is already in use by another element.'])
						return
					end
				end
				
				local unit = 'arena'
				if not E.db.unitframe.units[unit].customTexts then
					E.db.unitframe.units[unit].customTexts = {};
				end
				
				if E.db.unitframe.units[unit].customTexts[textName] then
					E:Print(L['The name you have selected is already in use by another element.'])
					return;
				end						
				
				E.db.unitframe.units[unit].customTexts[textName] = {
					['text_format'] = '',
					['size'] = 12,
					['font'] = E.db.unitframe.font,
					['xOffset'] = 0,
					['yOffset'] = 0,	
					['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
				};

				UF:CreateCustomTextGroup(unit, textName)
				
				UF:CreateAndUpdateUFGroup(unit, 5)
			end,
		},				
		health = {
			order = 8,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['arena']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['arena']['health'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
			args = {
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				position = {
					type = 'select',
					order = 3,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},
		power = {
			order = 9,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['arena']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['arena']['power'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},	
		name = {
			order = 9,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['arena']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['arena']['name'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},	
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},				
			},
		},
		buffs = {
			order = 11,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['arena']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['arena']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['TRINKET'] = L['PVP Trinket'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].playerOnly.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].playerOnly.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].noDuration.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].noDuration.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},	
						},
						noConsolidated = {
							order = 14,
							guiInline = true,
							type = 'group',
							name = L["Block Raid Buffs"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].noConsolidated.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].noConsolidated.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['buffs'].noConsolidated.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['buffs'].noConsolidated.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		debuffs = {
			order = 12,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['arena']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['arena']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['TRINKET'] = L['PVP Trinket'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Personal Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].playerOnly.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].playerOnly.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].playerOnly.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].playerOnly.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},
						},
						useBlacklist = {
							order = 11,
							guiInline = true,
							type = 'group',
							name = L["Block Blacklisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].useBlacklist.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].useBlacklist.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].useBlacklist.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].useBlacklist.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},
						},
						useWhitelist = {
							order = 12,
							guiInline = true,
							type = 'group',
							name = L["Block Non-Whitelisted Auras"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].useWhitelist.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].useWhitelist.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].useWhitelist.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].useWhitelist.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},
						},
						noDuration = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L["Block Auras Without Duration"],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].noDuration.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].noDuration.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].noDuration.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].noDuration.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},				
						},
						onlyDispellable = {
							order = 13,
							guiInline = true,
							type = 'group',
							name = L['Block Non-Dispellable Auras'],
							args = {
								friendly = {
									order = 2,
									type = 'toggle',
									name = L['Friendly'],
									desc = L['If the unit is friendly then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].onlyDispellable.friendly end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].onlyDispellable.friendly = value; UF:CreateAndUpdateUFGroup('arena', 5) end,									
								},
								enemy = {
									order = 3,
									type = 'toggle',
									name = L['Enemy'],
									desc = L['If the unit is an enemy then this filter will be checked, otherwise it will be ignored.'],
									get = function(info) return E.db.unitframe.units['arena']['debuffs'].onlyDispellable.enemy end,
									set = function(info, value) E.db.unitframe.units['arena']['debuffs'].onlyDispellable.enemy = value; UF:CreateAndUpdateUFGroup('arena', 5) end,										
								}
							},	
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},										
					},
				},				
			},
		},	
		castbar = {
			order = 13,
			type = 'group',
			name = L['Castbar'],
			get = function(info) return E.db.unitframe.units['arena']['castbar'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['arena']['castbar'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				matchsize = {
					order = 2,
					type = 'execute',
					name = L['Match Frame Width'],
					func = function() E.db.unitframe.units['arena']['castbar']['width'] = E.db.unitframe.units['arena']['width']; UF:CreateAndUpdateUFGroup('arena', 5) end,
				},				
				width = {
					order = 3,
					name = L['Width'],
					type = 'range',
					min = 50, max = 600, step = 1,
				},
				height = {
					order = 4,
					name = L['Height'],
					type = 'range',
					min = 10, max = 85, step = 1,
				},		
				icon = {
					order = 5,
					name = L['Icon'],
					type = 'toggle',
				},
				format = {
					order = 9,
					type = 'select',
					name = L['Format'],
					values = {
						['CURRENTMAX'] = L['Current / Max'],
						['CURRENT'] = L['Current'],
						['REMAINING'] = L['Remaining'],
					},
				},	
				spark = {
					order = 10,
					type = 'toggle',
					name = L['Spark'],
					desc = L['Display a spark texture at the end of the castbar statusbar to help show the differance between castbar and backdrop.'],
				},				
			},
		},	
		pvpTrinket = {
			order = 14,
			type = 'group',
			name = L['PVP Trinket'],
			get = function(info) return E.db.unitframe.units['arena']['pvpTrinket'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['arena']['pvpTrinket'][ info[#info] ] = value; UF:CreateAndUpdateUFGroup('arena', 5) end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = {
						['LEFT'] = L['Left'],
						['RIGHT'] = L['Right'],
					},
				},
				size = {
					order = 3,
					type = 'range',
					name = L['Size'],
					min = 10, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 4,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},				
			},
		},
	},
}

local groupPoints = {
	['TOP'] = 'TOP',
	['BOTTOM'] = 'BOTTOM',
	['LEFT'] = 'LEFT',
	['RIGHT'] = 'RIGHT',
}

--Party Frames
E.Options.args.unitframe.args.party = {
	name = L['Party Frames'],
	type = 'group',
	order = 1100,
	childGroups = "select",
	get = function(info) return E.db.unitframe.units['party'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['party'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('party'); E:ResetMovers('Party Frames') end,
		},		
		configureToggle = {
			order = 4,
			type = 'execute',
			name = L['Display Frames'],
			func = function() 
				UF:HeaderConfig(ElvUF_Party, ElvUF_Party.forceShow ~= true or nil)
			end,
		},			
		general = {
			order = 5,
			type = 'group',
			name = L['General'],
			args = {
				width = {
					order = 2,
					name = L['Width'],
					type = 'range',
					min = 50, max = 500, step = 1,
				},			
				height = {
					order = 3,
					name = L['Height'],
					type = 'range',
					min = 10, max = 250, step = 1,
				},	
				point = {
					order = 4,
					type = 'select',
					name = L['Group Point'],
					desc = L['What each frame should attach itself to, example setting it to TOP every unit will attach its top to the last point bottom.'],
					values = groupPoints,
					set = function(info, value) E.db.unitframe.units['party'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party'); end,
				},
				columnAnchorPoint = {
					order = 5,
					type = 'select',
					name = L['Column Point'],
					desc = L['The anchor point for each new column. A value of LEFT will cause the columns to grow to the right.'],
					values = groupPoints,	
					set = function(info, value) E.db.unitframe.units['party'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party'); end,
				},
				maxColumns = {
					order = 6,
					type = 'range',
					name = L['Max Columns'],
					desc = L['The maximum number of columns that the header will create.'],
					min = 1, max = 40, step = 1,
				},
				unitsPerColumn = {
					order = 7,
					type = 'range',
					name = L['Units Per Column'],
					desc = L['The maximum number of units that will be displayed in a single column.'],
					min = 1, max = 40, step = 1,
				},
				xOffset = {
					order = 9,
					type = 'range',
					name = L['xOffset'],
					desc = L['An X offset (in pixels) to be used when anchoring new frames.'],
					min = -50, max = 50, step = 1,		
				},
				yOffset = {
					order = 10,
					type = 'range',
					name = L['yOffset'],
					desc = L['An Y offset (in pixels) to be used when anchoring new frames.'],
					min = -50, max = 50, step = 1,		
				},		
				showParty = {
					order = 11,
					type = 'toggle',
					name = L['Show Party'],
					desc = L['When true, the group header is shown when the player is in a party.'],
				},
				showRaid = {
					order = 12,
					type = 'toggle',
					name = L['Show Raid'],
					desc = L['When true, the group header is shown when the player is in a raid.'],
				},	
				showSolo = {
					order = 13,
					type = 'toggle',
					name = L['Show Solo'],
					desc = L['When true, the header is shown when the player is not in any group.'],		
				},
				showPlayer = {
					order = 14,
					type = 'toggle',
					name = L['Display Player'],
					desc = L['When true, the header includes the player when not in a raid.'],			
				},
				healPrediction = {
					order = 15,
					name = L['Heal Prediction'],
					desc = L['Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals.'],
					type = 'toggle',
				},		
				groupBy = {
					order = 16,
					name = L['Group By'],
					desc = L['Set the order that the group will sort.'],
					type = 'select',		
					values = {
						['CLASS'] = CLASS,
						['ROLE'] = L["MT, MA First"],
						['NAME'] = NAME,
						['GROUP'] = GROUP,
					},
				},
				hideonnpc = {
					type = 'toggle',
					order = 17,
					name = L['Text Toggle On NPC'],
					desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
					get = function(info) return E.db.unitframe.units['party']['power'].hideonnpc end,
					set = function(info, value) E.db.unitframe.units['party']['power'].hideonnpc = value; UF:CreateAndUpdateHeaderGroup('party'); end,
				},
				customText = {
					order = 50,
					name = L['Custom Texts'],
					type = 'input',
					width = 'full',
					desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
					get = function() return '' end,
					set = function(info, textName)
						for object, _ in pairs(E.db.unitframe.units.party) do
							if object:lower() == textName:lower() then
								E:Print(L['The name you have selected is already in use by another element.'])
								return
							end
						end
						
						local unit = 'party'
						if not E.db.unitframe.units[unit].customTexts then
							E.db.unitframe.units[unit].customTexts = {};
						end
								
						if E.db.unitframe.units[unit].customTexts[textName] then
							E:Print(L['The name you have selected is already in use by another element.'])
							return;
						end								
						
						E.db.unitframe.units[unit].customTexts[textName] = {
							['text_format'] = '',
							['size'] = 12,
							['font'] = E.db.unitframe.font,
							['xOffset'] = 0,
							['yOffset'] = 0,	
							['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
						};

						UF:CreateCustomTextGroup(unit, textName)
						
						UF:CreateAndUpdateHeaderGroup(unit)
					end,
				},						
				visibility = {
					order = 200,
					type = 'input',
					name = L['Visibility'],
					desc = L['The following macro must be true in order for the group to be shown, in addition to any filter that may already be set.'],
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},				
			},
		},			
		health = {
			order = 100,
			type = 'group',
			name = L['Health'],
			get = function(info) return E.db.unitframe.units['party']['health'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['health'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party'); end,
			args = {
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				position = {
					type = 'select',
					order = 3,
					name = L['Position'],
					values = positionValues,
				},	
				frequentUpdates = {
					type = 'toggle',
					order = 4,
					name = L['Frequent Updates'],
					desc = L['Rapidly update the health, uses more memory and cpu. Only recommended for healing.'],
				},
				orientation = {
					type = 'select',
					order = 5,
					name = L['Orientation'],
					desc = L['Direction the health bar moves when gaining/losing health.'],
					values = {
						['HORIZONTAL'] = L['Horizontal'],
						['VERTICAL'] = L['Vertical'],
					},
				},		
			},
		},
		power = {
			order = 200,
			type = 'group',
			name = L['Power'],
			get = function(info) return E.db.unitframe.units['party']['power'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['power'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},	
				width = {
					type = 'select',
					order = 4,
					name = L['Width'],
					values = fillValues,
				},
				height = {
					type = 'range',
					name = L['Height'],
					order = 5,
					min = 2, max = 50, step = 1,
				},
				offset = {
					type = 'range',
					name = L['Offset'],
					desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
					order = 6,
					min = 0, max = 20, step = 1,
				},
				position = {
					type = 'select',
					order = 8,
					name = L['Position'],
					values = positionValues,
				},					
			},
		},	
		name = {
			order = 300,
			type = 'group',
			name = L['Name'],
			get = function(info) return E.db.unitframe.units['party']['name'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['name'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},			
				text_format = {
					order = 100,
					name = L['Text Format'],
					type = 'input',
					width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
				},
			},
		},
		buffs = {
			order = 400,
			type = 'group',
			name = L['Buffs'],
			get = function(info) return E.db.unitframe.units['party']['buffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['buffs'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						noConsolidated = {
							order = 14,
							type = 'toggle',
							name = L["Block Raid Buffs"],
							desc = L["Block Raid Buffs"],		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},				
			},
		},	
		debuffs = {
			order = 500,
			type = 'group',
			name = L['Debuffs'],
			get = function(info) return E.db.unitframe.units['party']['debuffs'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},				
			},
		},	
		buffIndicator = {
			order = 600,
			type = 'group',
			name = L['Buff Indicator'],
			get = function(info) return E.db.unitframe.units['party']['buffIndicator'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['buffIndicator'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				enable = {
					type = 'toggle',
					name = L['Enable'],
					order = 1,
				},
				size = {
					type = 'range',
					name = L['Size'],
					desc = L['Size of the indicator icon.'],
					order = 3,
					min = 4, max = 15, step = 1,
				},
				fontSize = {
					type = 'range',
					name = L['Font Size'],
					order = 4,
					min = 7, max = 22, step = 1,
				},
			},
		},
		roleIcon = {
			order = 700,
			type = 'group',
			name = L['Role Icon'],
			get = function(info) return E.db.unitframe.units['party']['roleIcon'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['roleIcon'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,	
			args = {
				enable = {
					type = 'toggle',
					name = L['Enable'],
					order = 1,
				},
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},							
			},
		},
		raidRoleIcons = {
			order = 750,
			type = 'group',
			name = L['RL / ML Icons'],
			get = function(info) return E.db.unitframe.units['party']['raidRoleIcons'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['raidRoleIcons'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,	
			args = {
				enable = {
					type = 'toggle',
					name = L['Enable'],
					order = 1,
				},
				position = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = {
						['TOPLEFT'] = 'TOPLEFT',
						['TOPRIGHT'] = 'TOPRIGHT',
					},
				},							
			},
		},		
		petsGroup = {
			order = 800,
			type = 'group',
			name = L['Party Pets'],
			get = function(info) return E.db.unitframe.units['party']['petsGroup'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['petsGroup'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,	
			args = {		
				enable = {
					type = 'toggle',
					name = L['Enable'],
					order = 1,
				},
				width = {
					order = 2,
					name = L['Width'],
					type = 'range',
					min = 10, max = 500, step = 1,
				},			
				height = {
					order = 3,
					name = L['Height'],
					type = 'range',
					min = 10, max = 250, step = 1,
				},	
				anchorPoint = {
					type = 'select',
					order = 5,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = petAnchors,				
				},	
				xOffset = {
					order = 6,
					type = 'range',
					name = L['xOffset'],
					desc = L['An X offset (in pixels) to be used when anchoring new frames.'],
					min = -500, max = 500, step = 1,		
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L['yOffset'],
					desc = L['An Y offset (in pixels) to be used when anchoring new frames.'],
					min = -500, max = 500, step = 1,		
				},					
			},
		},
		targetsGroup = {
			order = 900,
			type = 'group',
			name = L['Party Targets'],
			get = function(info) return E.db.unitframe.units['party']['targetsGroup'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['targetsGroup'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,	
			args = {		
				enable = {
					type = 'toggle',
					name = L['Enable'],
					order = 1,
				},
				width = {
					order = 2,
					name = L['Width'],
					type = 'range',
					min = 10, max = 500, step = 1,
				},			
				height = {
					order = 3,
					name = L['Height'],
					type = 'range',
					min = 10, max = 250, step = 1,
				},	
				anchorPoint = {
					type = 'select',
					order = 5,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = petAnchors,				
				},	
				xOffset = {
					order = 6,
					type = 'range',
					name = L['xOffset'],
					desc = L['An X offset (in pixels) to be used when anchoring new frames.'],
					min = -500, max = 500, step = 1,		
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L['yOffset'],
					desc = L['An Y offset (in pixels) to be used when anchoring new frames.'],
					min = -500, max = 500, step = 1,	
				},					
			},
		},	
		raidicon = {
			order = 2000,
			type = 'group',
			name = L['Raid Icon'],
			get = function(info) return E.db.unitframe.units['party']['raidicon'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['party']['raidicon'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('party') end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},	
				attachTo = {
					type = 'select',
					order = 2,
					name = L['Position'],
					values = positionValues,
				},
				size = {
					type = 'range',
					name = L['Size'],
					order = 3,
					min = 8, max = 60, step = 1,
				},				
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -300, max = 300, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -300, max = 300, step = 1,
				},			
			},
		},			
	},
}

--Raid Frames
for i=10, 40, 15 do
	E.Options.args.unitframe.args['raid'..i] = {
		name = L['Raid-'..i..' Frames'],
		type = 'group',
		order = 1100,
		childGroups = "select",
		get = function(info) return E.db.unitframe.units['raid'..i][ info[#info] ] end,
		set = function(info, value) E.db.unitframe.units['raid'..i][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,
		args = {
			enable = {
				type = 'toggle',
				order = 1,
				name = L['Enable'],
			},
			resetSettings = {
				type = 'execute',
				order = 2,
				name = L['Restore Defaults'],
				func = function(info, value) UF:ResetUnitSettings('raid'..i); E:ResetMovers('Raid 1-'..i..' Frames') end,
			},	
			configureToggle = {
				order = 4,
				type = 'execute',
				name = L['Display Frames'],
				func = function() 
					UF:HeaderConfig(_G['ElvUF_Raid'..i], _G['ElvUF_Raid'..i].forceShow ~= true or nil)
				end,
			},		
			general = {
				order = 5,
				type = 'group',
				name = L['General'],
				args = {
					width = {
						order = 2,
						name = L['Width'],
						type = 'range',
						min = 50, max = 500, step = 1,
					},			
					height = {
						order = 3,
						name = L['Height'],
						type = 'range',
						min = 10, max = 250, step = 1,
					},	
					point = {
						order = 4,
						type = 'select',
						name = L['Group Point'],
						desc = L['What each frame should attach itself to, example setting it to TOP every unit will attach its top to the last point bottom.'],
						values = groupPoints,
						set = function(info, value) E.db.unitframe.units['raid'..i][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i); end,
					},
					columnAnchorPoint = {
						order = 5,
						type = 'select',
						name = L['Column Point'],
						desc = L['The anchor point for each new column. A value of LEFT will cause the columns to grow to the right.'],
						values = groupPoints,	
						set = function(info, value) E.db.unitframe.units['raid'..i][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i); end,
					},
					maxColumns = {
						order = 6,
						type = 'range',
						name = L['Max Columns'],
						desc = L['The maximum number of columns that the header will create.'],
						min = 1, max = 40, step = 1,
					},
					unitsPerColumn = {
						order = 7,
						type = 'range',
						name = L['Units Per Column'],
						desc = L['The maximum number of units that will be displayed in a single column.'],
						min = 1, max = 40, step = 1,
					},
					xOffset = {
						order = 9,
						type = 'range',
						name = L['xOffset'],
						desc = L['An X offset (in pixels) to be used when anchoring new frames.'],
						min = -50, max = 50, step = 1,		
					},
					yOffset = {
						order = 10,
						type = 'range',
						name = L['yOffset'],
						desc = L['An Y offset (in pixels) to be used when anchoring new frames.'],
						min = -50, max = 50, step = 1,		
					},		
					showParty = {
						order = 11,
						type = 'toggle',
						name = L['Show Party'],
						desc = L['When true, the group header is shown when the player is in a party.'],
					},
					showRaid = {
						order = 12,
						type = 'toggle',
						name = L['Show Raid'],
						desc = L['When true, the group header is shown when the player is in a raid.'],
					},	
					showSolo = {
						order = 13,
						type = 'toggle',
						name = L['Show Solo'],
						desc = L['When true, the header is shown when the player is not in any group.'],		
					},
					showPlayer = {
						order = 14,
						type = 'toggle',
						name = L['Display Player'],
						desc = L['When true, the header includes the player when not in a raid.'],			
					},
					healPrediction = {
						order = 15,
						name = L['Heal Prediction'],
						desc = L['Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals.'],
						type = 'toggle',
					},		
					groupBy = {
						order = 16,
						name = L['Group By'],
						desc = L['Set the order that the group will sort.'],
						type = 'select',		
						values = {
							['CLASS'] = CLASS,
							['ROLE'] = L["MT, MA First"],
							['NAME'] = NAME,
							['GROUP'] = GROUP,
						},
					},		
					hideonnpc = {
						type = 'toggle',
						order = 17,
						name = L['Text Toggle On NPC'],
						desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
						get = function(info) return E.db.unitframe.units['raid'..i]['power'].hideonnpc end,
						set = function(info, value) E.db.unitframe.units['raid'..i]['power'].hideonnpc = value; UF:CreateAndUpdateHeaderGroup('raid'..i); end,
					},		
					customText = {
						order = 50,
						name = L['Custom Texts'],
						type = 'input',
						width = 'full',
						desc = L['Create a custom fontstring. Once you enter a name you will be able to select it from the elements dropdown list.'],
						get = function() return '' end,
						set = function(info, textName)
							for object, _ in pairs(E.Options.args.unitframe.args['raid'..i]) do
								if object:lower() == textName:lower() then
									E:Print(L['The name you have selected is already in use by another element.'])
									return
								end
							end
							
							local unit = 'raid'..i
							if not E.db.unitframe.units[unit].customTexts then
								E.db.unitframe.units[unit].customTexts = {};
							end
							
							if E.db.unitframe.units[unit].customTexts[textName] then
								E:Print(L['The name you have selected is already in use by another element.'])
								return;
							end									
										
							E.db.unitframe.units[unit].customTexts[textName] = {
								['text_format'] = '',
								['size'] = 12,
								['font'] = E.db.unitframe.font,
								['xOffset'] = 0,
								['yOffset'] = 0,	
								['justifyH'] = 'CENTER',
					['fontOutline'] = 'NONE'
							};

							UF:CreateCustomTextGroup(unit, textName)
							
							UF:CreateAndUpdateHeaderGroup(unit)
						end,
					},							
					visibility = {
						order = 200,
						type = 'input',
						name = L['Visibility'],
						desc = L['The following macro must be true in order for the group to be shown, in addition to any filter that may already be set.'],
						width = 'full',
						desc = L['TEXT_FORMAT_DESC'],
					},					
				},
			},			
			health = {
				order = 100,
				type = 'group',
				name = L['Health'],
				get = function(info) return E.db.unitframe.units['raid'..i]['health'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['health'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i); end,
				args = {
					text_format = {
						order = 100,
						name = L['Text Format'],
						type = 'input',
						width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
					},	
					position = {
						type = 'select',
						order = 3,
						name = L['Position'],
						values = positionValues,
					},					
					frequentUpdates = {
						type = 'toggle',
						order = 4,
						name = L['Frequent Updates'],
						desc = L['Rapidly update the health, uses more memory and cpu. Only recommended for healing.'],
					},
					orientation = {
						type = 'select',
						order = 5,
						name = L['Orientation'],
						desc = L['Direction the health bar moves when gaining/losing health.'],
						values = {
							['HORIZONTAL'] = L['Horizontal'],
							['VERTICAL'] = L['Vertical'],
						},
					},	
				},
			},
			power = {
				order = 200,
				type = 'group',
				name = L['Power'],
				get = function(info) return E.db.unitframe.units['raid'..i]['power'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['power'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,
				args = {
					enable = {
						type = 'toggle',
						order = 1,
						name = L['Enable'],
					},			
					text_format = {
						order = 100,
						name = L['Text Format'],
						type = 'input',
						width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
					},	
					width = {
						type = 'select',
						order = 4,
						name = L['Width'],
						values = fillValues,
					},
					height = {
						type = 'range',
						name = L['Height'],
						order = 5,
						min = 2, max = 50, step = 1,
					},
					offset = {
						type = 'range',
						name = L['Offset'],
						desc = L['Offset of the powerbar to the healthbar, set to 0 to disable.'],
						order = 6,
						min = 0, max = 20, step = 1,
					},
					position = {
						type = 'select',
						order = 8,
						name = L['Position'],
						values = positionValues,
					},					
				},
			},	
			name = {
				order = 300,
				type = 'group',
				name = L['Name'],
				get = function(info) return E.db.unitframe.units['raid'..i]['name'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['name'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,
				args = {
					position = {
						type = 'select',
						order = 2,
						name = L['Position'],
						values = positionValues,
					},	
					text_format = {
						order = 100,
						name = L['Text Format'],
						type = 'input',
						width = 'full',
					desc = L['TEXT_FORMAT_DESC'],
					},			
				},
			},
			buffs = {
				order = 400,
				type = 'group',
				name = L['Buffs'],
				get = function(info) return E.db.unitframe.units['raid'..i]['buffs'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['buffs'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,
				args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the buff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['DEBUFFS'] = L['Debuffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						noConsolidated = {
							order = 14,
							type = 'toggle',
							name = L["Block Raid Buffs"],
							desc = L["Block Raid Buffs"],		
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},				
				},
			},	
			debuffs = {
				order = 500,
				type = 'group',
				name = L['Debuffs'],
				get = function(info) return E.db.unitframe.units['raid'..i]['debuffs'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['debuffs'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,
				args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},			
				perrow = {
					type = 'range',
					order = 2,
					name = L['Per Row'],
					min = 1, max = 20, step = 1,
				},
				numrows = {
					type = 'range',
					order = 3,
					name = L['Num Rows'],
					min = 1, max = 4, step = 1,					
				},
				sizeOverride = {
					type = 'range',
					order = 3,
					name = L['Size Override'],
					desc = L['If not set to 0 then override the size of the aura icon to this.'],
					min = 0, max = 60, step = 1,
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L['xOffset'],
					min = -60, max = 60, step = 1,
				},
				yOffset = {
					order = 5,
					type = 'range',
					name = L['yOffset'],
					min = -60, max = 60, step = 1,
				},					
				attachTo = {
					type = 'select',
					order = 7,
					name = L['Attach To'],
					desc = L['What to attach the debuff anchor frame to.'],
					values = {
						['FRAME'] = L['Frame'],
						['BUFFS'] = L['Buffs'],
					},
				},
				anchorPoint = {
					type = 'select',
					order = 8,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = auraAnchors,				
				},
				fontSize = {
					order = 9,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				clickThrough = {
					order = 15,
					name = L['Click Through'],
					desc = L['Ignore mouse events.'],
					type = 'toggle',
				},
				filters = {
					name = L["Filters"],
					guiInline = true,
					type = 'group',
					order = 500,
					args = {
						playerOnly = {
							order = 10,
							type = 'toggle',
							name = L["Block Non-Personal Auras"],
							desc = L["Block Non-Personal Auras"],
						},
						useBlacklist = {
							order = 11,
							type = 'toggle',
							name = L["Block Blacklisted Auras"],
							desc = L["Block Blacklisted Auras"],
						},
						useWhitelist = {
							order = 12,
							type = 'toggle',
							name = L["Block Non-Whitelisted Auras"],
							desc = L["Block Non-Whitelisted Auras"],
						},
						noDuration = {
							order = 13,
							type = 'toggle',
							name = L["Block Auras Without Duration"],
							desc = L["Block Auras Without Duration"],					
						},
						onlyDispellable = {
							order = 13,
							type = 'toggle',
							name = L['Block Non-Dispellable Auras'],
							desc = L['Block Non-Dispellable Auras'],
						},
						useFilter = {
							order = 15,
							name = L['Additional Filter'],
							desc = L['Select a filter to use.'],
							type = 'select',
							values = function()
								filters = {}
								filters[''] = NONE
								for filter in pairs(E.global.unitframe['aurafilters']) do
									filters[filter] = filter
								end
								return filters
							end,
						},						
					},
				},				
				},
			},	
			buffIndicator = {
				order = 600,
				type = 'group',
				name = L['Buff Indicator'],
				get = function(info) return E.db.unitframe.units['raid'..i]['buffIndicator'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['buffIndicator'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,
				args = {
					enable = {
						type = 'toggle',
						name = L['Enable'],
						order = 1,
					},
					size = {
						type = 'range',
						name = L['Size'],
						desc = L['Size of the indicator icon.'],
						order = 3,
						min = 4, max = 15, step = 1,
					},
					fontSize = {
						type = 'range',
						name = L['Font Size'],
						order = 4,
						min = 7, max = 22, step = 1,
					},
				},
			},	
			roleIcon = {
				order = 700,
				type = 'group',
				name = L['Role Icon'],
				get = function(info) return E.db.unitframe.units['raid'..i]['roleIcon'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['roleIcon'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,	
				args = {
					enable = {
						type = 'toggle',
						name = L['Enable'],
						order = 1,
					},
					position = {
						type = 'select',
						order = 2,
						name = L['Position'],
						values = positionValues,
					},							
				},
			},	
			raidRoleIcons = {
				order = 750,
				type = 'group',
				name = L['RL / ML Icons'],
				get = function(info) return E.db.unitframe.units['raid'..i]['raidRoleIcons'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['raidRoleIcons'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,	
				args = {
					enable = {
						type = 'toggle',
						name = L['Enable'],
						order = 1,
					},
					position = {
						type = 'select',
						order = 2,
						name = L['Position'],
						values = {
							['TOPLEFT'] = 'TOPLEFT',
							['TOPRIGHT'] = 'TOPRIGHT',
						},
					},							
				},
			},				
			rdebuffs = {
				order = 800,
				type = 'group',
				name = L['RaidDebuff Indicator'],
				get = function(info) return E.db.unitframe.units['raid'..i]['rdebuffs'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['rdebuffs'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,
				args = {
					enable = {
						type = 'toggle',
						name = L['Enable'],
						order = 1,
					},	
					size = {
						type = 'range',
						name = L['Size'],
						order = 2,
						min = 8, max = 35, step = 1,
					},				
					fontSize = {
						type = 'range',
						name = L['Font Size'],
						order = 3,
						min = 7, max = 22, step = 1,
					},	
					xOffset = {
						order = 4,
						type = 'range',
						name = L['xOffset'],
						min = -300, max = 300, step = 1,
					},
					yOffset = {
						order = 5,
						type = 'range',
						name = L['yOffset'],
						min = -300, max = 300, step = 1,
					},		
				},
			},
			raidicon = {
				order = 2000,
				type = 'group',
				name = L['Raid Icon'],
				get = function(info) return E.db.unitframe.units['raid'..i]['raidicon'][ info[#info] ] end,
				set = function(info, value) E.db.unitframe.units['raid'..i]['raidicon'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('raid'..i) end,
				args = {
					enable = {
						type = 'toggle',
						order = 1,
						name = L['Enable'],
					},	
					attachTo = {
						type = 'select',
						order = 2,
						name = L['Position'],
						values = positionValues,
					},
					size = {
						type = 'range',
						name = L['Size'],
						order = 3,
						min = 8, max = 30, step = 1,
					},				
					xOffset = {
						order = 4,
						type = 'range',
						name = L['xOffset'],
						min = -300, max = 300, step = 1,
					},
					yOffset = {
						order = 5,
						type = 'range',
						name = L['yOffset'],
						min = -300, max = 300, step = 1,
					},			
				},
			},			
		},
	}
end


--Tank Frames
E.Options.args.unitframe.args.tank = {
	name = L['Tank Frames'],
	type = 'group',
	order = 1100,
	get = function(info) return E.db.unitframe.units['tank'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['tank'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('tank') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('tank') end,
		},		
		general = {
			order = 3,
			type = 'group',
			name = L['General'],
			guiInline = true,
			args = {
				width = {
					order = 2,
					name = L['Width'],
					type = 'range',
					min = 50, max = 500, step = 1,
				},			
				height = {
					order = 3,
					name = L['Height'],
					type = 'range',
					min = 10, max = 250, step = 1,
				},					
			},
		},	
		targetsGroup = {
			order = 4,
			type = 'group',
			name = L['Tank Target'],
			guiInline = true,
			get = function(info) return E.db.unitframe.units['tank']['targetsGroup'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['tank']['targetsGroup'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('tank') end,	
			args = {		
				enable = {
					type = 'toggle',
					name = L['Enable'],
					order = 1,
				},
				width = {
					order = 2,
					name = L['Width'],
					type = 'range',
					min = 10, max = 500, step = 1,
				},			
				height = {
					order = 3,
					name = L['Height'],
					type = 'range',
					min = 10, max = 250, step = 1,
				},	
				anchorPoint = {
					type = 'select',
					order = 5,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = petAnchors,				
				},	
				xOffset = {
					order = 6,
					type = 'range',
					name = L['xOffset'],
					desc = L['An X offset (in pixels) to be used when anchoring new frames.'],
					min = -500, max = 500, step = 1,		
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L['yOffset'],
					desc = L['An Y offset (in pixels) to be used when anchoring new frames.'],
					min = -500, max = 500, step = 1,	
				},					
			},
		},			
	},
}

--Assist Frames
E.Options.args.unitframe.args.assist = {
	name = L['Assist Frames'],
	type = 'group',
	order = 1100,
	get = function(info) return E.db.unitframe.units['assist'][ info[#info] ] end,
	set = function(info, value) E.db.unitframe.units['assist'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('assist') end,
	args = {
		enable = {
			type = 'toggle',
			order = 1,
			name = L['Enable'],
		},
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('assist') end,
		},		
		general = {
			order = 3,
			type = 'group',
			name = L['General'],
			guiInline = true,
			args = {
				width = {
					order = 2,
					name = L['Width'],
					type = 'range',
					min = 50, max = 500, step = 1,
				},			
				height = {
					order = 3,
					name = L['Height'],
					type = 'range',
					min = 10, max = 250, step = 1,
				},					
			},
		},
		targetsGroup = {
			order = 4,
			type = 'group',
			name = L['Assist Target'],
			guiInline = true,
			get = function(info) return E.db.unitframe.units['assist']['targetsGroup'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['assist']['targetsGroup'][ info[#info] ] = value; UF:CreateAndUpdateHeaderGroup('assist') end,	
			args = {		
				enable = {
					type = 'toggle',
					name = L['Enable'],
					order = 1,
				},
				width = {
					order = 2,
					name = L['Width'],
					type = 'range',
					min = 10, max = 500, step = 1,
				},			
				height = {
					order = 3,
					name = L['Height'],
					type = 'range',
					min = 10, max = 250, step = 1,
				},	
				anchorPoint = {
					type = 'select',
					order = 5,
					name = L['Anchor Point'],
					desc = L['What point to anchor to the frame you set to attach to.'],
					values = petAnchors,				
				},	
				xOffset = {
					order = 6,
					type = 'range',
					name = L['xOffset'],
					desc = L['An X offset (in pixels) to be used when anchoring new frames.'],
					min = -500, max = 500, step = 1,		
				},
				yOffset = {
					order = 7,
					type = 'range',
					name = L['yOffset'],
					desc = L['An Y offset (in pixels) to be used when anchoring new frames.'],
					min = -500, max = 500, step = 1,	
				},					
			},
		},			
	},
}


--MORE COLORING STUFF YAY
if P.unitframe.colors.classResources[E.myclass] then
	E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup = {
		order = -1,
		type = 'group',
		guiInline = true,
		name = L['Class Resources'],
		get = function(info)
			local t = E.db.unitframe.colors.classResources[ info[#info] ]
			return t.r, t.g, t.b, t.a
		end,
		set = function(info, r, g, b)
			E.db.unitframe.colors.classResources[ info[#info] ] = {}
			local t = E.db.unitframe.colors.classResources[ info[#info] ]
			t.r, t.g, t.b = r, g, b
			UF:Update_AllFrames()
		end,
		args = {}
	}
	
	if E.myclass == 'PALADIN' then
		E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = L['Holy Power'],
		}
	elseif E.myclass == 'MAGE' then
		E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = L['Arcane Charges'],
		}
	elseif E.myclass == 'PRIEST' then
		E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args[E.myclass] = {
			type = 'color',
			name = L['Shadow Orbs'],
		}	
	elseif E.myclass == 'MONK' then
		for i = 1, 5 do
			E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args['resource'..i] = {
				type = 'color',
				name = L['Harmony']..' #'..i,
				get = function(info)
					local t = E.db.unitframe.colors.classResources.MONK[i]
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					E.db.unitframe.colors.classResources.MONK[i] = {}
					local t = E.db.unitframe.colors.classResources.MONK[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end,			
			}
		end
	elseif E.myclass == 'WARLOCK' then
		local names = {
			[1] = L['Affliction'],
			[2] = L['Demonology'],
			[3] = L['Destruction']
		}
		for i = 1, 3 do
			E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args['resource'..i] = {
				type = 'color',
				name = names[i],
				get = function(info)
					local t = E.db.unitframe.colors.classResources.WARLOCK[i]
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					E.db.unitframe.colors.classResources.WARLOCK[i] = {}
					local t = E.db.unitframe.colors.classResources.WARLOCK[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end,			
			}
		end	
	elseif E.myclass == 'DRUID' then
		local names = {
			[1] = L['Lunar'],
			[2] = L['Solar'],
		}
		for i = 1, 2 do
			E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args['resource'..i] = {
				type = 'color',
				name = names[i],
				get = function(info)
					local t = E.db.unitframe.colors.classResources.DRUID[i]
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					E.db.unitframe.colors.classResources.DRUID[i] = {}
					local t = E.db.unitframe.colors.classResources.DRUID[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end,			
			}
		end		
	elseif E.myclass == 'DEATHKNIGHT' then
		local names = {
			[1] = L['Blood'],
			[2] = L['Unholy'],
			[3] = L['Frost'],
			[4] = L['Death'],
		}
		for i = 1, 4 do
			E.Options.args.unitframe.args.general.args.allColorsGroup.args.classResourceGroup.args['resource'..i] = {
				type = 'color',
				name = names[i],
				get = function(info)
					local t = E.db.unitframe.colors.classResources.DEATHKNIGHT[i]
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					E.db.unitframe.colors.classResources.DEATHKNIGHT[i] = {}
					local t = E.db.unitframe.colors.classResources.DEATHKNIGHT[i]
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames()
				end,			
			}
		end		
	end
end