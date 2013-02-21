local E, L, V, P, G, _ = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local UF = E:GetModule('UnitFrames');
local _, ns = ...
local ElvUF = ns.oUF

UF.FillValues = {
	['fill'] = L['Filled'],
	['spaced'] = L['Spaced'],
};

UF.PositionValues = {
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

local threatValues = {
	values = threatValues,
	['BORDERS'] = L['Borders'],
	['HEALTHBORDER'] = L['Health Border'],
	['ICONTOPLEFT'] = L['Icon: TOPLEFT'],
	['ICONTOPRIGHT'] = L['Icon: TOPRIGHT'],
	['ICONBOTTOMLEFT'] = L['Icon: BOTTOMLEFT'],
	['ICONBOTTOMRIGHT'] = L['Icon: BOTTOMRIGHT'],
	['ICONLEFT'] = L['Icon: LEFT'],
	['ICONRIGHT'] = L['Icon: RIGHT'],
	['ICONTOP'] = L['Icon: TOP'],
	['ICONBOTTOM'] = L['Icon: BOTTOM'],
	['NONE'] = NONE
}

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
								transparentHealth = {
									order = 6,
									type = 'toggle',
									name = L['Transparent'],
									desc = L['Make textures transparent.'],
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
								transparentPower = {
									order = 1,
									type = 'toggle',
									name = L['Transparent'],
									desc = L['Make textures transparent.'],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,										
								},									
								MANA = {
									order = 2,
									name = MANA,
									type = 'color',
								},
								RAGE = {
									order = 3,
									name = RAGE,
									type = 'color',
								},	
								FOCUS = {
									order = 4,
									name = FOCUS,
									type = 'color',
								},	
								ENERGY = {
									order = 5,
									name = ENERGY,
									type = 'color',
								},		
								RUNIC_POWER = {
									order = 6,
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
								transparentCastbar = {
									order = 0,
									type = 'toggle',
									name = L['Transparent'],
									desc = L['Make textures transparent.'],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,										
								},								
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
								transparentAurabars = {
									order = 0,
									type = 'toggle',
									name = L['Transparent'],
									desc = L['Make textures transparent.'],
									get = function(info) return E.db.unitframe.colors[ info[#info] ] end,
									set = function(info, value) E.db.unitframe.colors[ info[#info] ] = value; UF:Update_AllFrames() end,										
								},								
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
		threatStyle = {
			type = 'select',
			order = 11,
			name = L['Threat Display Mode'],
			values = threatValues,
		},
		customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'player'),
		health = UF:GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'player'),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateUF, 'player'),	
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateUF, 'player'),	
		portrait = UF:GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'player'),
		buffs = UF:GetOptionsTable_Auras(true, 'buffs', false, UF.CreateAndUpdateUF, 'player'),
		debuffs = UF:GetOptionsTable_Auras(true, 'debuffs', false, UF.CreateAndUpdateUF, 'player'),
		castbar = UF:GetOptionsTable_Castbar(true, UF.CreateAndUpdateUF, 'player'),
		aurabar = UF:GetOptionsTable_AuraBars(true, UF.CreateAndUpdateUF, 'player'),
		raidicon = UF:GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'player'),			
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
					values = UF.FillValues,
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
					values = UF.PositionValues,
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
		stagger = {
			order = 1400,
			type = 'group',
			name = L['Stagger Bar'],
			get = function(info) return E.db.unitframe.units['player']['stagger'][ info[#info] ] end,
			set = function(info, value) E.db.unitframe.units['player']['stagger'][ info[#info] ] = value; UF:CreateAndUpdateUF('player') end,
			disabled = E.myclass == "MONK",
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
				},
				width = {
					order = 2,
					name = L['Width'],
					type = 'range',
					min = 5, max = 25, step = 1,
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
		rangeCheck = {
			order = 6,
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."],
			type = "toggle",
		},
		healPrediction = {
			order = 7,
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
		threatStyle = {
			type = 'select',
			order = 12,
			name = L['Threat Display Mode'],
			values = threatValues,
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
					values = UF.FillValues,
				},				
			},
		},	
		customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'target'),
		health = UF:GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'target'),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateUF, 'target'),	
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateUF, 'target'),
		portrait = UF:GetOptionsTable_Portrait(UF.CreateAndUpdateUF, 'target'),
		buffs = UF:GetOptionsTable_Auras(false, 'buffs', false, UF.CreateAndUpdateUF, 'target'),
		debuffs = UF:GetOptionsTable_Auras(false, 'debuffs', false, UF.CreateAndUpdateUF, 'target'),
		castbar = UF:GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, 'target'),		
		aurabar = UF:GetOptionsTable_AuraBars(false, UF.CreateAndUpdateUF, 'target'),
		raidicon = UF:GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'target'),	
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
		rangeCheck = {
			order = 6,
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."],
			type = "toggle",
		},		
		hideonnpc = {
			type = 'toggle',
			order = 7,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['targettarget']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['targettarget']['power'].hideonnpc = value; UF:CreateAndUpdateUF('targettarget') end,
		},
		threatStyle = {
			type = 'select',
			order = 11,
			name = L['Threat Display Mode'],
			values = threatValues,
		},		
		customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'targettarget'),		
		health = UF:GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'targettarget'),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateUF, 'targettarget'),	
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateUF, 'targettarget'),
		buffs = UF:GetOptionsTable_Auras(false, 'buffs', false, UF.CreateAndUpdateUF, 'targettarget'),
		debuffs = UF:GetOptionsTable_Auras(false, 'debuffs', false, UF.CreateAndUpdateUF, 'targettarget'),
		raidicon = UF:GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'targettarget'),	
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
		rangeCheck = {
			order = 6,
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."],
			type = "toggle",
		},				
		healPrediction = {
			order = 7,
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
		threatStyle = {
			type = 'select',
			order = 13,
			name = L['Threat Display Mode'],
			values = threatValues,
		},		
		customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'focus'),
		health = UF:GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'focus'),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateUF, 'focus'),	
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateUF, 'focus'),
		buffs = UF:GetOptionsTable_Auras(false, 'buffs', false, UF.CreateAndUpdateUF, 'focus'),
		debuffs = UF:GetOptionsTable_Auras(false, 'debuffs', false, UF.CreateAndUpdateUF, 'focus'),
		castbar = UF:GetOptionsTable_Castbar(false, UF.CreateAndUpdateUF, 'focus'),
		aurabar = UF:GetOptionsTable_AuraBars(false, UF.CreateAndUpdateUF, 'focus'),
		raidicon = UF:GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'focus'),	
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
		rangeCheck = {
			order = 6,
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."],
			type = "toggle",
		},				
		hideonnpc = {
			type = 'toggle',
			order = 7,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['focustarget']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['focustarget']['power'].hideonnpc = value; UF:CreateAndUpdateUF('focustarget') end,
		},	
		threatStyle = {
			type = 'select',
			order = 13,
			name = L['Threat Display Mode'],
			values = threatValues,
		},		
		customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'focustarget'),
		health = UF:GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'focustarget'),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateUF, 'focustarget'),	
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateUF, 'focustarget'),
		buffs = UF:GetOptionsTable_Auras(false, 'buffs', false, UF.CreateAndUpdateUF, 'focustarget'),
		debuffs = UF:GetOptionsTable_Auras(false, 'debuffs', false, UF.CreateAndUpdateUF, 'focustarget'),
		raidicon = UF:GetOptionsTable_RaidIcon(UF.CreateAndUpdateUF, 'focustarget'),	
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
		rangeCheck = {
			order = 6,
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."],
			type = "toggle",
		},				
		healPrediction = {
			order = 7,
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
		threatStyle = {
			type = 'select',
			order = 13,
			name = L['Threat Display Mode'],
			values = threatValues,
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
		customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'pet'),
		health = UF:GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'pet'),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateUF, 'pet'),	
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateUF, 'pet'),
		buffs = UF:GetOptionsTable_Auras(true, 'buffs', false, UF.CreateAndUpdateUF, 'pet'),
		debuffs = UF:GetOptionsTable_Auras(true, 'debuffs', false, UF.CreateAndUpdateUF, 'pet'),		
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
		rangeCheck = {
			order = 6,
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."],
			type = "toggle",
		},			
		hideonnpc = {
			type = 'toggle',
			order = 7,
			name = L['Text Toggle On NPC'],
			desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
			get = function(info) return E.db.unitframe.units['pettarget']['power'].hideonnpc end,
			set = function(info, value) E.db.unitframe.units['pettarget']['power'].hideonnpc = value; UF:CreateAndUpdateUF('pettarget') end,
		},		
		threatStyle = {
			type = 'select',
			order = 13,
			name = L['Threat Display Mode'],
			values = threatValues,
		},			
		customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateUF, 'pettarget'),
		health = UF:GetOptionsTable_Health(false, UF.CreateAndUpdateUF, 'pettarget'),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateUF, 'pettarget'),	
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateUF, 'pettarget'),
		buffs = UF:GetOptionsTable_Auras(false, 'buffs', false, UF.CreateAndUpdateUF, 'pettarget'),
		debuffs = UF:GetOptionsTable_Auras(false, 'debuffs', false, UF.CreateAndUpdateUF, 'pettarget'),
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
		rangeCheck = {
			order = 6,
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."],
			type = "toggle",
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
		threatStyle = {
			type = 'select',
			order = 13,
			name = L['Threat Display Mode'],
			values = threatValues,
		},			
		customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		health = UF:GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),		
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		portrait = UF:GetOptionsTable_Portrait(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),	
		buffs = UF:GetOptionsTable_Auras(true, 'buffs', false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		debuffs = UF:GetOptionsTable_Auras(true, 'debuffs', false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		castbar = UF:GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),
		raidicon = UF:GetOptionsTable_RaidIcon(UF.CreateAndUpdateUFGroup, 'boss', MAX_BOSS_FRAMES),	
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
		rangeCheck = {
			order = 6,
			name = L["Range Check"],
			desc = L["Check if you are in range to cast spells on this specific unit."],
			type = "toggle",
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
		threatStyle = {
			type = 'select',
			order = 13,
			name = L['Threat Display Mode'],
			values = threatValues,
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
		customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateUFGroup, 'arena', 5),		
		health = UF:GetOptionsTable_Health(false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateUFGroup, 'arena', 5),	
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateUFGroup, 'arena', 5),
		buffs = UF:GetOptionsTable_Auras(false, 'buffs', false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		debuffs = UF:GetOptionsTable_Auras(false, 'debuffs', false, UF.CreateAndUpdateUFGroup, 'arena', 5),
		castbar = UF:GetOptionsTable_Castbar(false, UF.CreateAndUpdateUFGroup, 'arena', 5),
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
		configureToggle = {
			order = 1,
			type = 'execute',
			name = L['Display Frames'],
			func = function() 
				UF:HeaderConfig(ElvUF_Party, ElvUF_Party.forceShow ~= true or nil)
			end,
		},		
		resetSettings = {
			type = 'execute',
			order = 2,
			name = L['Restore Defaults'],
			func = function(info, value) UF:ResetUnitSettings('party'); E:ResetMovers('Party Frames') end,
		},
		copyFrom = {
			type = 'select',
			order = 3,
			name = L['Copy From'],
			desc = L['Select a unit to copy settings from.'],
			values = {
				['raid10'] = L['Raid-10 Frames'],
				['raid25'] = L['Raid-25 Frames'],
				['raid40'] = L['Raid-40 Frames'],
			},
			set = function(info, value) UF:MergeUnitSettings(value, 'party', true); end,
		},				
		general = {
			order = 5,
			type = 'group',
			name = L['General'],
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L['Enable'],
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
					min = 10, max = 500, step = 1,
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
				positionOverride = {
					order = 6,
					type = 'select',
					name = L['Position Override'],
					desc = L['This will determine how the party/raid group will grow out when the group is not full. For example setting this to BOTTOMLEFT would cause the first raid frame to spawn from the BOTTOMLEFT corner of where the mover is positioned.'],
					values = {
						['BOTTOMLEFT'] = 'BOTTOMLEFT',
						['BOTTOMRIGHT'] = 'BOTTOMRIGHT',
						['BOTTOM'] = 'BOTTOM',
						['TOP'] = 'TOP',
						['TOPLEFT'] = 'TOPLEFT',
						['TOPRIGHT'] = 'TOPRIGHT',
						['NONE'] = NONE,
					},
					set = function(info, value) 
						E.db.unitframe.units['party'][ info[#info] ] = value;
						ElvUF_PartyMover.positionOverride = value ~= 'NONE' and value or nil
						E:UpdatePositionOverride('ElvUF_PartyMover')
					end,
				},
				maxColumns = {
					order = 7,
					type = 'range',
					name = L['Max Columns'],
					desc = L['The maximum number of columns that the header will create.'],
					min = 1, max = 40, step = 1,
				},
				unitsPerColumn = {
					order = 8,
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
				groupBy = {
					order = 16,
					name = L['Group By'],
					desc = L['Set the order that the group will sort.'],
					type = 'select',		
					values = {
						['CLASS'] = CLASS,
						['ROLE'] = ROLE,
						['NAME'] = NAME,
						['GROUP'] = GROUP,
					},
				},
				sortDir = {
					order = 17,
					name = L['Sort Direction'],
					desc = L['Defines the sort order of the selected sort method.'],
					type = 'select',
					values = {
						['ASC'] = L['Ascending'],
						['DESC'] = L['Descending']
					},
				},
				hideonnpc = {
					type = 'toggle',
					order = 18,
					name = L['Text Toggle On NPC'],
					desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
					get = function(info) return E.db.unitframe.units['party']['power'].hideonnpc end,
					set = function(info, value) E.db.unitframe.units['party']['power'].hideonnpc = value; UF:CreateAndUpdateHeaderGroup('party'); end,
				},
				rangeCheck = {
					order = 19,
					name = L["Range Check"],
					desc = L["Check if you are in range to cast spells on this specific unit."],
					type = "toggle",
				},						
				healPrediction = {
					order = 20,
					name = L['Heal Prediction'],
					desc = L['Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals.'],
					type = 'toggle',
				},		
				threatStyle = {
					type = 'select',
					order = 22,
					name = L['Threat Display Mode'],
					values = threatValues,
				},					
				customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'party'),
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
					values = UF.PositionValues,
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
		health = UF:GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'party'),
		power = UF:GetOptionsTable_Power(UF.CreateAndUpdateHeaderGroup, 'party'),	
		name = UF:GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'party'),
		buffs = UF:GetOptionsTable_Auras(true, 'buffs', true, UF.CreateAndUpdateHeaderGroup, 'party'),
		debuffs = UF:GetOptionsTable_Auras(true, 'debuffs', true, UF.CreateAndUpdateHeaderGroup, 'party'),		
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
		raidicon = UF:GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'party'),	
		GPSArrow = UF:GetOptionsTable_GPS('party')					
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
			configureToggle = {
				order = 1,
				type = 'execute',
				name = L['Display Frames'],
				func = function() 
					UF:HeaderConfig(_G['ElvUF_Raid'..i], _G['ElvUF_Raid'..i].forceShow ~= true or nil)
				end,
			},			
			resetSettings = {
				type = 'execute',
				order = 2,
				name = L['Restore Defaults'],
				func = function(info, value) UF:ResetUnitSettings('raid'..i); E:ResetMovers('Raid 1-'..i..' Frames') end,
			},	
			copyFrom = {
				type = 'select',
				order = 3,
				name = L['Copy From'],
				desc = L['Select a unit to copy settings from.'],
				values = {
					['party'] = L['Party Frames'],
					['raid10'] = 'raid'..i ~= 'raid10' and L['Raid-10 Frames'] or nil,
					['raid25'] = 'raid'..i ~= 'raid25' and L['Raid-25 Frames'] or nil,
					['raid40'] = 'raid'..i ~= 'raid40' and L['Raid-40 Frames'] or nil,
				},
				set = function(info, value) UF:MergeUnitSettings(value, 'raid'..i, true); end,
			},			
			general = {
				order = 5,
				type = 'group',
				name = L['General'],
				args = {
					enable = {
						type = 'toggle',
						order = 1,
						name = L['Enable'],
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
						min = 10, max = 500, step = 1,
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
					positionOverride = {
						order = 6,
						type = 'select',
						name = L['Position Override'],
						desc = L['This will determine how the party/raid group will grow out when the group is not full. For example setting this to BOTTOMLEFT would cause the first raid frame to spawn from the BOTTOMLEFT corner of where the mover is positioned.'],
						values = {
							['BOTTOMLEFT'] = 'BOTTOMLEFT',
							['BOTTOMRIGHT'] = 'BOTTOMRIGHT',
							['BOTTOM'] = 'BOTTOM',
							['TOP'] = 'TOP',
							['TOPLEFT'] = 'TOPLEFT',
							['TOPRIGHT'] = 'TOPRIGHT',
							['NONE'] = NONE,
						},
						set = function(info, value) 
							E.db.unitframe.units['raid'..i][ info[#info] ] = value;
							ElvUF_PartyMover.positionOverride = value ~= 'NONE' and value or nil
							E:UpdatePositionOverride('ElvUF_Raid..'..i..'Mover')
						end,
					},			
					maxColumns = {
						order = 7,
						type = 'range',
						name = L['Max Columns'],
						desc = L['The maximum number of columns that the header will create.'],
						min = 1, max = 40, step = 1,
					},
					unitsPerColumn = {
						order = 8,
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
					groupBy = {
						order = 16,
						name = L['Group By'],
						desc = L['Set the order that the group will sort.'],
						type = 'select',		
						values = {
							['CLASS'] = CLASS,
							['ROLE'] = ROLE,
							['NAME'] = NAME,
							['GROUP'] = GROUP,
						},
					},
					sortDir = {
						order = 17,
						name = L['Sort Direction'],
						desc = L['Defines the sort order of the selected sort method.'],
						type = 'select',
						values = {
							['ASC'] = L['Ascending'],
							['DESC'] = L['Descending']
						},
					},	
					rangeCheck = {
						order = 18,
						name = L["Range Check"],
						desc = L["Check if you are in range to cast spells on this specific unit."],
						type = "toggle",
					},							
					hideonnpc = {
						type = 'toggle',
						order = 19,
						name = L['Text Toggle On NPC'],
						desc = L['Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point.'],
						get = function(info) return E.db.unitframe.units['raid'..i]['power'].hideonnpc end,
						set = function(info, value) E.db.unitframe.units['raid'..i]['power'].hideonnpc = value; UF:CreateAndUpdateHeaderGroup('raid'..i); end,
					},	
					healPrediction = {
						order = 20,
						name = L['Heal Prediction'],
						desc = L['Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals.'],
						type = 'toggle',
					},			
					threatStyle = {
						type = 'select',
						order = 22,
						name = L['Threat Display Mode'],
						values = {

						},
					},						
					customText = UF:GetOptionsTable_CustomText(UF.CreateAndUpdateHeaderGroup, 'raid'..i),
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
			health = UF:GetOptionsTable_Health(true, UF.CreateAndUpdateHeaderGroup, 'raid'..i),
			power = UF:GetOptionsTable_Power(UF.CreateAndUpdateHeaderGroup, 'raid'..i),	
			name = UF:GetOptionsTable_Name(UF.CreateAndUpdateHeaderGroup, 'raid'..i),
			buffs = UF:GetOptionsTable_Auras(true, 'buffs', true, UF.CreateAndUpdateHeaderGroup, 'raid'..i),
			debuffs = UF:GetOptionsTable_Auras(true, 'debuffs', true, UF.CreateAndUpdateHeaderGroup, 'raid'..i),
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
						values = UF.PositionValues,
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
			raidicon = UF:GetOptionsTable_RaidIcon(UF.CreateAndUpdateHeaderGroup, 'raid'..i),	
			GPSArrow = UF:GetOptionsTable_GPS('raid'..i)	
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