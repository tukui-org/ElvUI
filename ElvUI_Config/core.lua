local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local D = E:GetModule("Distributor")
local AceGUI = LibStub("AceGUI-3.0")

local tsort, tinsert = table.sort, table.insert
local floor, ceil = math.floor, math.ceil
local format = string.format
local DEFAULT_WIDTH = 890;
local DEFAULT_HEIGHT = 651;
local AC = LibStub("AceConfig-3.0-ElvUI")
local ACD = LibStub("AceConfigDialog-3.0-ElvUI")
local ACR = LibStub("AceConfigRegistry-3.0-ElvUI")

AC:RegisterOptionsTable("ElvUI", E.Options)
ACD:SetDefaultSize("ElvUI", DEFAULT_WIDTH, DEFAULT_HEIGHT)

--Function we can call on profile change to update GUI
function E:RefreshGUI()
	self:RefreshCustomTextsConfigs()
	ACR:NotifyChange("ElvUI")
end
E.Options.name = E.UIName
E.Options.args = {
	ElvUI_Header = {
		order = 1,
		type = "header",
		name = L["Version"]..format(": |cff99ff33%s|r",E.version),
		width = "full",
	},
	LoginMessage = {
		order = 2,
		type = 'toggle',
		name = L["Login Message"],
		get = function(info) return E.db.general.loginmessage end,
		set = function(info, value) E.db.general.loginmessage = value end,
	},
	ToggleTutorial = {
		order = 3,
		type = 'execute',
		name = L["Toggle Tutorials"],
		func = function() E:Tutorials(true); E:ToggleConfig()  end,
	},
	Install = {
		order = 4,
		type = 'execute',
		name = L["Install"],
		desc = L["Run the installation process."],
		func = function() E:Install(); E:ToggleConfig() end,
	},
	ToggleAnchors = {
		order = 5,
		type = "execute",
		name = L["Toggle Anchors"],
		desc = L["Unlock various elements of the UI to be repositioned."],
		func = function() E:ToggleConfigMode() end,
	},
	ResetAllMovers = {
		order = 6,
		type = "execute",
		name = L["Reset Anchors"],
		desc = L["Reset all frames to their original positions."],
		func = function() E:ResetUI() end,
	},
}

E.Options.args.general = {
	type = "group",
	name = L["General"],
	order = 1,
	childGroups = "select",
	get = function(info) return E.db.general[ info[#info] ] end,
	set = function(info, value) E.db.general[ info[#info] ] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["ELVUI_DESC"]:gsub('ElvUI', E.UIName),
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			args = {
				pixelPerfect = {
					order = 1,
					name = L["Thin Border Theme"],
					desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
					type = 'toggle',
					get = function(info) return E.private.general.pixelPerfect end,
					set = function(info, value) E.private.general.pixelPerfect = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				interruptAnnounce = {
					order = 2,
					name = L["Announce Interrupts"],
					desc = L["Announce when you interrupt a spell to the specified chat channel."],
					type = 'select',
					values = {
						['NONE'] = NONE,
						['SAY'] = SAY,
						['PARTY'] = L["Party Only"],
						['RAID'] = L["Party / Raid"],
						['RAID_ONLY'] = L["Raid Only"],
					},
				},
				autoRepair = {
					order = 3,
					name = L["Auto Repair"],
					desc = L["Automatically repair using the following method when visiting a merchant."],
					type = 'select',
					values = {
						['NONE'] = NONE,
						['GUILD'] = GUILD,
						['PLAYER'] = PLAYER,
					},
				},
				autoAcceptInvite = {
					order = 4,
					name = L["Accept Invites"],
					desc = L["Automatically accept invites from guild/friends."],
					type = 'toggle',
				},
				vendorGrays = {
					order = 5,
					name = L["Vendor Grays"],
					desc = L["Automatically vendor gray items when visiting a vendor."],
					type = 'toggle',
				},
				autoRoll = {
					order = 6,
					name = L["Auto Greed/DE"],
					desc = L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."],
					type = 'toggle',
					disabled = function() return not E.private.general.lootRoll end
				},
				loot = {
					order = 7,
					type = "toggle",
					name = L["Loot"],
					desc = L["Enable/Disable the loot frame."],
					get = function(info) return E.private.general.loot end,
					set = function(info, value) E.private.general.loot = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				lootRoll = {
					order = 8,
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["Enable/Disable the loot roll frame."],
					get = function(info) return E.private.general.lootRoll end,
					set = function(info, value) E.private.general.lootRoll = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				autoScale = {
					order = 9,
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					type = "toggle",
					get = function(info) return E.global.general.autoScale end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				eyefinity = {
					order = 10,
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					type = "toggle",
					get = function(info) return E.global.general.eyefinity end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				hideErrorFrame = {
					order = 11,
					name = L["Hide Error Text"],
					desc = L["Hides the red error text at the top of the screen while in combat."],
					type = "toggle"
				},
				taintLog = {
					order = 12,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."],
				},
				bottomPanel = {
					order = 13,
					type = 'toggle',
					name = L["Bottom Panel"],
					desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
					get = function(info) return E.db.general.bottomPanel end,
					set = function(info, value) E.db.general.bottomPanel = value; E:GetModule('Layout'):BottomPanelVisibility() end
				},
				topPanel = {
					order = 14,
					type = 'toggle',
					name = L["Top Panel"],
					desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
					get = function(info) return E.db.general.topPanel end,
					set = function(info, value) E.db.general.topPanel = value; E:GetModule('Layout'):TopPanelVisibility() end
				},
				afk = {
					order = 15,
					type = 'toggle',
					name = L["AFK Mode"],
					desc = L["When you go AFK display the AFK screen."],
					get = function(info) return E.db.general.afk end,
					set = function(info, value) E.db.general.afk = value; E:GetModule('AFK'):Toggle() end

				},
				smallerWorldMap = {
					order = 16,
					type = 'toggle',
					name = L["Smaller World Map"],
					desc = L["Make the world map smaller."],
					get = function(info) return E.global.general.smallerWorldMap end,
					set = function(info, value) E.global.general.smallerWorldMap = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				WorldMapCoordinates = {
					order = 17,
					type = 'toggle',
					name = L["World Map Coordinates"],
					desc = L["Puts coordinates on the world map."],
					get = function(info) return E.global.general.WorldMapCoordinates end,
					set = function(info, value) E.global.general.WorldMapCoordinates = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				enhancedPvpMessages = {
					order = 18,
					type = 'toggle',
					name = L["Enhanced PVP Messages"],
					desc = L["Display battleground messages in the middle of the screen."],
				},
				disableTutorialButtons = {
					order = 19,
					type = 'toggle',
					name = L["Disable Tutorial Buttons"],
					desc = L["Disables the tutorial button found on some frames."],
					get = function(info) return E.global.general.disableTutorialButtons end,
					set = function(info, value) E.global.general.disableTutorialButtons = value; E:StaticPopup_Show("GLOBAL_RL") end,
				},
				chatBubbles = {
					order = 30,
					type = "group",
					guiInline = true,
					name = L["Chat Bubbles"],
					args = {
						style = {
							order = 1,
							type = "select",
							name = L["Chat Bubbles Style"],
							desc = L["Skin the blizzard chat bubbles."],
							get = function(info) return E.private.general.chatBubbles end,
							set = function(info, value) E.private.general.chatBubbles = value; E:StaticPopup_Show("PRIVATE_RL") end,
							values = {
								['backdrop'] = L["Skin Backdrop"],
								['nobackdrop'] = L["Remove Backdrop"],
								['disabled'] = L["Disabled"]
							}
						},
						font = {
							order = 2,
							type = "select",
							name = L["Font"],
							dialogControl = 'LSM30_Font',
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general.chatBubbleFont end,
							set = function(info, value) E.private.general.chatBubbleFont = value; E:StaticPopup_Show("PRIVATE_RL") end,
						},
						fontSize = {
							order = 3,
							type = "range",
							name = L["Font Size"],
							get = function(info) return E.private.general.chatBubbleFontSize end,
							set = function(info, value) E.private.general.chatBubbleFontSize = value; E:StaticPopup_Show("PRIVATE_RL") end,
							min = 4, max = 20, step = 1,
						},
					},
				},
			},
		},
		media = {
			order = 3,
			type = "group",
			name = L["Media"],
			get = function(info) return E.db.general[ info[#info] ] end,
			set = function(info, value) E.db.general[ info[#info] ] = value end,
			args = {
				fonts = {
					order = 1,
					type = "group",
					name = L["Fonts"],
					guiInline = true,
					args = {
						fontSize = {
							order = 1,
							name = L["Font Size"],
							desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
							type = "range",
							min = 4, max = 22, step = 1,
							set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
						},
						font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 2,
							name = L["Default Font"],
							desc = L["The font that the core of the UI will use."],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
						},
						applyFontToAll = {
							order = 3,
							type = 'execute',
							name = L["Apply Font To All"],
							desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
							func = function()
								local font = E.db.general.font
								local fontSize = E.db.general.fontSize

								E.db.bags.itemLevelFont = font
								E.db.bags.itemLevelFontSize = fontSize
								E.db.bags.countFont = font
								E.db.bags.countFontSize = fontSize
								E.db.nameplate.font = font
								--E.db.nameplate.fontSize = fontSize --Dont use this because nameplate font it somewhat smaller than the rest of the font sizes
								E.db.nameplate.buffs.font = font
								--E.db.nameplate.buffs.fontSize = fontSize  --Dont use this because nameplate font it somewhat smaller than the rest of the font sizes
								E.db.nameplate.debuffs.font = font
								--E.db.nameplate.debuffs.fontSize = fontSize   --Dont use this because nameplate font it somewhat smaller than the rest of the font sizes
								E.db.auras.font = font
								E.db.auras.fontSize = fontSize
								E.db.auras.consolidatedBuffs.font = font
								--E.db.auras.consolidatedBuffs.fontSize = fontSize --Size is smaller by default
								E.db.chat.font = font
								E.db.chat.fontSize = fontSize
								E.db.chat.tabFont = font
								E.db.chat.tapFontSize = fontSize
								E.db.datatexts.font = font
								E.db.datatexts.fontSize = fontSize
								E.db.tooltip.font = font
								E.db.tooltip.fontSize = fontSize
								E.db.tooltip.headerFontSize = fontSize
								E.db.tooltip.textFontSize = fontSize
								E.db.tooltip.smallTextFontSize = fontSize
								E.db.tooltip.healthBar.font = font
								--E.db.tooltip.healthbar.fontSize = fontSize -- Size is smaller than default
								E.db.unitframe.font = font
								--E.db.unitframe.fontSize = fontSize  -- Size is smaller than default
								E.db.unitframe.units.party.rdebuffs.font = font
								E.db.unitframe.units.raid.rdebuffs.font = font
								E.db.unitframe.units.raid40.rdebuffs.font = font

								E:UpdateAll(true)
							end,
						},
						dmgfont = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 4,
							name = L["CombatText Font"],
							desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[ info[#info] ] end,
							set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
						},
						namefont = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 5,
							name = L["Name Font"],
							desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[ info[#info] ] end,
							set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
						},
						replaceBlizzFonts = {
							order = 6,
							type = 'toggle',
							name = L["Replace Blizzard Fonts"],
							desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
							get = function(info) return E.private.general[ info[#info] ] end,
							set = function(info, value) E.private.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
						},
					},
				},
				textures = {
					order = 2,
					type = "group",
					name = L["Textures"],
					guiInline = true,
					args = {
						normTex = {
							type = "select", dialogControl = 'LSM30_Statusbar',
							order = 1,
							name = L["Primary Texture"],
							desc = L["The texture that will be used mainly for statusbars."],
							values = AceGUIWidgetLSMlists.statusbar,
							get = function(info) return E.private.general[ info[#info] ] end,
							set = function(info, value)
								local previousValue = E.private.general[ info[#info] ]
								E.private.general[ info[#info] ] = value;

								if(E.db.unitframe.statusbar == previousValue) then
									E.db.unitframe.statusbar = value
									E:UpdateAll(true)
								else
									E:UpdateMedia()
									E:UpdateStatusBars()
								end

							end
						},
						glossTex = {
							type = "select", dialogControl = 'LSM30_Statusbar',
							order = 2,
							name = L["Secondary Texture"],
							desc = L["This texture will get used on objects like chat windows and dropdown menus."],
							values = AceGUIWidgetLSMlists.statusbar,
							get = function(info) return E.private.general[ info[#info] ] end,
							set = function(info, value)
								E.private.general[ info[#info] ] = value;
								E:UpdateMedia()
								E:UpdateFrameTemplates()
							end
						},
						applyFontToAll = {
							order = 3,
							type = 'execute',
							name = L["Apply Texture To All"],
							desc = L["Applies the primary texture to all statusbars."],
							func = function()
								local texture = E.private.general.normTex
								E.db.unitframe.statusbar = texture
								E:UpdateAll(true)
							end,
						},
					},
				},
				colors = {
					order = 3,
					type = "group",
					name = L["Colors"],
					guiInline = true,
					args = {
						bordercolor = {
							type = "color",
							order = 1,
							name = L["Border Color"],
							desc = L["Main border color of the UI. |cffFF0000This is disabled if you are using the Thin Border Theme.|r"],
							hasAlpha = false,
							get = function(info)
								local t = E.db.general[ info[#info] ]
								local d = P.general[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {}
								local t = E.db.general[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								E:UpdateMedia()
								E:UpdateBorderColors()
							end,
							disabled = function() return E.PixelMode end,
						},
						backdropcolor = {
							type = "color",
							order = 2,
							name = L["Backdrop Color"],
							desc = L["Main backdrop color of the UI."],
							hasAlpha = false,
							get = function(info)
								local t = E.db.general[ info[#info] ]
								local d = P.general[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								E.db.general[ info[#info] ] = {}
								local t = E.db.general[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								E:UpdateMedia()
								E:UpdateBackdropColors()
							end,
						},
						backdropfadecolor = {
							type = "color",
							order = 3,
							name = L["Backdrop Faded Color"],
							desc = L["Backdrop color of transparent frames"],
							hasAlpha = true,
							get = function(info)
								local t = E.db.general[ info[#info] ]
								local d = P.general[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								E.db.general[ info[#info] ] = {}
								local t = E.db.general[ info[#info] ]
								t.r, t.g, t.b, t.a = r, g, b, a
								E:UpdateMedia()
								E:UpdateBackdropColors()
							end,
						},
						valuecolor = {
							type = "color",
							order = 4,
							name = L["Value Color"],
							desc = L["Color some texts use."],
							hasAlpha = false,
							get = function(info)
								local t = E.db.general[ info[#info] ]
								local d = P.general[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b, a)
								E.db.general[ info[#info] ] = {}
								local t = E.db.general[ info[#info] ]
								t.r, t.g, t.b, t.a = r, g, b, a
								E:UpdateMedia()
							end,
						},
					},
				},
			},
		},
		minimap = {
			order = 4,
			get = function(info) return E.db.general.minimap[ info[#info] ] end,
			type = "group",
			name = MINIMAP_LABEL,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r"],
					get = function(info) return E.private.general.minimap[ info[#info] ] end,
					set = function(info, value) E.private.general.minimap[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
				},
				size = {
					order = 2,
					type = "range",
					name = L["Size"],
					desc = L["Adjust the size of the minimap."],
					min = 120, max = 250, step = 1,
					set = function(info, value) E.db.general.minimap[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
					disabled = function() return not E.private.general.minimap.enable end,
				},
				locationText = {
					order = 3,
					type = 'select',
					name = L["Location Text"],
					desc = L["Change settings for the display of the location text that is on the minimap."],
					get = function(info) return E.db.general.minimap.locationText end,
					set = function(info, value) E.db.general.minimap.locationText = value; E:GetModule('Minimap'):UpdateSettings(); E:GetModule('Minimap'):Update_ZoneText() end,
					values = {
						['MOUSEOVER'] = L["Minimap Mouseover"],
						['SHOW'] = L["Always Display"],
						['HIDE'] = L["Hide"],
					},
					disabled = function() return not E.private.general.minimap.enable end,
				},
				spacer = {
					order = 4,
					type = "description",
					name = "\n",
				},
				icons = {
					order = 5,
					type = 'group',
					name = L["Minimap Buttons"],
					args = {
						garrison = {
							order = 1,
							type = 'group',
							name = GARRISON_LOCATION_TOOLTIP,
							get = function(info) return E.db.general.minimap.icons.garrison[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.garrison[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									disabled = function() return E.private.general.minimap.hideGarrison end,
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.private.general.minimap.hideGarrison end,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.private.general.minimap.hideGarrison end,
								},
								hideGarrison = {
									order = 5,
									type = 'toggle',
									name = L["Hide"],
									get = function(info) return E.private.general.minimap.hideGarrison end,
									set = function(info, value) E.private.general.minimap.hideGarrison = value; E:StaticPopup_Show("PRIVATE_RL") end,
								},
							},
						},
						calendar = {
							order = 2,
							type = 'group',
							name = L["Calendar"],
							get = function(info) return E.db.general.minimap.icons.calendar[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.calendar[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									disabled = function() return E.private.general.minimap.hideCalendar end,
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.private.general.minimap.hideCalendar end,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
									disabled = function() return E.private.general.minimap.hideCalendar end,
								},
								hideCalendar = {
									order = 5,
									type = 'toggle',
									name = L["Hide"],
									get = function(info) return E.private.general.minimap.hideCalendar end,
									set = function(info, value) E.private.general.minimap.hideCalendar = value; E:GetModule('Minimap'):UpdateSettings() end,
								},
							},
						},
						mail = {
							order = 3,
							type = 'group',
							name = MAIL_LABEL,
							get = function(info) return E.db.general.minimap.icons.mail[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.mail[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
							},
						},
						lfgEye = {
							order = 3,
							type = 'group',
							name = L["LFG Queue"],
							get = function(info) return E.db.general.minimap.icons.lfgEye[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.lfgEye[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
							},
						},
						difficulty = {
							order = 4,
							type = 'group',
							name = L["Instance Difficulty"],
							get = function(info) return E.db.general.minimap.icons.difficulty[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.difficulty[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
							},
						},
						challengeMode = {
							order = 5,
							type = 'group',
							name = CHALLENGE_MODE,
							get = function(info) return E.db.general.minimap.icons.challengeMode[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.challengeMode[ info[#info] ] = value; E:GetModule('Minimap'):UpdateSettings() end,
							args = {
								scale = {
									order = 1,
									type = 'range',
									name = L["Scale"],
									min = 0.5, max = 2, step = 0.05,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
							},
						},
						vehicleLeave = {
							order = 5,
							type = 'group',
							name = LEAVE_VEHICLE,
							get = function(info) return E.db.general.minimap.icons.vehicleLeave[ info[#info] ] end,
							set = function(info, value) E.db.general.minimap.icons.vehicleLeave[ info[#info] ] = value; E:GetModule('ActionBars'):UpdateVehicleLeave() end,
							args = {
								size = {
									order = 1,
									type = 'range',
									name = L["Size"],
									min = 10, max = 40, step = 1,
								},
								position = {
									order = 2,
									type = 'select',
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"],
									},
								},
								xOffset = {
									order = 3,
									type = 'range',
									name = L["xOffset"],
									min = -50, max = 50, step = 1,
								},
								yOffset = {
									order = 4,
									type = 'range',
									name = L["yOffset"],
									min = -50, max = 50, step = 1,
								},
								hide = {
									order = 5,
									type = 'toggle',
									name = L["Hide"],
								},
							},
						},
					},
				},
			},
		},
		experience = {
			order = 5,
			get = function(info) return E.db.general.experience[ info[#info] ] end,
			set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):UpdateExpRepDimensions() end,
			type = "group",
			name = XPBAR_LABEL,
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):EnableDisable_ExperienceBar() end,
				},
				mouseover = {
					order = 1,
					type = "toggle",
					name = L["Mouseover"],
				},
				hideAtMaxLevel = {
					order = 2,
					type = "toggle",
					name = L["Hide At Max Level"],
					set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):UpdateExperience() end,
				},
				hideInVehicle = {
					order = 3,
					type = "toggle",
					name = L["Hide In Vehicle"],
					set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):UpdateExperience() end,
				},
				reverseFill = {
					order = 4,
					type = "toggle",
					name = L["Reverse Fill Direction"],
				},
				orientation = {
					order = 5,
					type = "select",
					name = L["Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						['HORIZONTAL'] = L["Horizontal"],
						['VERTICAL'] = L["Vertical"]
					}
				},
				width = {
					order = 6,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
				},
				height = {
					order = 7,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
				},
				textSize = {
					order = 8,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
				textFormat = {
					order = 9,
					type = 'select',
					name = L["Text Format"],
					values = {
						NONE = NONE,
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
					},
					set = function(info, value) E.db.general.experience[ info[#info] ] = value; E:GetModule('Misc'):UpdateExperience() end,
				},
			},
		},
		reputation = {
			order = 6,
			get = function(info) return E.db.general.reputation[ info[#info] ] end,
			set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):UpdateExpRepDimensions() end,
			type = "group",
			name = REPUTATION,
			args = {
				enable = {
					order = 0,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):EnableDisable_ReputationBar() end,
				},
				mouseover = {
					order = 1,
					type = "toggle",
					name = L["Mouseover"],
				},
				hideInVehicle = {
					order = 2,
					type = "toggle",
					name = L["Hide In Vehicle"],
					set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):UpdateReputation() end,
				},
				reverseFill = {
					order = 3,
					type = "toggle",
					name = L["Reverse Fill Direction"],
				},
				orientation = {
					order = 4,
					type = "select",
					name = L["Orientation"],
					desc = L["Direction the bar moves on gains/losses"],
					values = {
						['HORIZONTAL'] = L["Horizontal"],
						['VERTICAL'] = L["Vertical"]
					}
				},
				textFormat = {
					order = 5,
					type = 'select',
					name = L["Text Format"],
					values = {
						NONE = NONE,
						PERCENT = L["Percent"],
						CURMAX = L["Current - Max"],
						CURPERC = L["Current - Percent"],
					},
					set = function(info, value) E.db.general.reputation[ info[#info] ] = value; E:GetModule('Misc'):UpdateReputation() end,
				},
				width = {
					order = 6,
					type = "range",
					name = L["Width"],
					min = 5, max = ceil(GetScreenWidth() or 800), step = 1,
				},
				height = {
					order = 7,
					type = "range",
					name = L["Height"],
					min = 5, max = ceil(GetScreenHeight() or 800), step = 1,
				},
				textSize = {
					order = 8,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
				},
			},
		},
		threat = {
			order = 7,
			get = function(info) return E.db.general.threat[ info[#info] ] end,
			set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):ToggleEnable()end,
			type = "group",
			name = L["Threat"],
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
				},
				position = {
					order = 2,
					type = 'select',
					name = L["Position"],
					desc = L["Adjust the position of the threat bar to either the left or right datatext panels."],
					values = {
						['LEFTCHAT'] = L["Left Chat"],
						['RIGHTCHAT'] = L["Right Chat"],
					},
					set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):UpdatePosition() end,
				},
				textSize = {
					order = 3,
					name = L["Font Size"],
					type = "range",
					min = 6, max = 22, step = 1,
					set = function(info, value) E.db.general.threat[ info[#info] ] = value; E:GetModule('Threat'):UpdatePosition() end,
				},
			},
		},
		totems = {
			order = 8,
			type = "group",
			name = L["Class Bar"],
			get = function(info) return E.db.general.totems[ info[#info] ] end,
			set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):PositionAndSize() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):ToggleEnable() end,
				},
				size = {
					order = 2,
					type = 'range',
					name = L["Button Size"],
					min = 24, max = 60, step = 1,
				},
				spacing = {
					order = 3,
					type = 'range',
					name = L["Button Spacing"],
					min = 1, max = 10, step = 1,
				},
				sortDirection = {
					order = 4,
					type = 'select',
					name = L["Sort Direction"],
					values = {
						['ASCENDING'] = L["Ascending"],
						['DESCENDING'] = L["Descending"],
					},
				},
				growthDirection = {
					order = 5,
					type = 'select',
					name = L["Bar Direction"],
					values = {
						['VERTICAL'] = L["Vertical"],
						['HORIZONTAL'] = L["Horizontal"],
					},
				},
			},
		},
		cooldown = {
			type = "group",
			order = 10,
			name = L["Cooldown Text"],
			get = function(info)
				local t = E.db.cooldown[ info[#info] ]
				local d = P.cooldown[info[#info]]
				return t.r, t.g, t.b, t.a, d.r, d.g, d.b
			end,
			set = function(info, r, g, b)
				E.db.cooldown[ info[#info] ] = {}
				local t = E.db.cooldown[ info[#info] ]
				t.r, t.g, t.b = r, g, b
				E:UpdateCooldownSettings();
			end,
			args = {
				enable = {
					type = "toggle",
					order = 1,
					name = L["Enable"],
					desc = L["Display cooldown text on anything with the cooldown spiral."],
					get = function(info) return E.private.cooldown[ info[#info] ] end,
					set = function(info, value) E.private.cooldown[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				threshold = {
					type = 'range',
					name = L["Low Threshold"],
					desc = L["Threshold before text turns red and is in decimal form. Set to -1 for it to never turn red"],
					min = -1, max = 20, step = 1,
					order = 2,
					get = function(info) return E.db.cooldown[ info[#info] ] end,
					set = function(info, value)
						E.db.cooldown[ info[#info] ] = value
						E:UpdateCooldownSettings();
					end,
				},
				expiringColor = {
					type = 'color',
					order = 4,
					name = L["Expiring"],
					desc = L["Color when the text is about to expire"],
				},
				secondsColor = {
					type = 'color',
					order = 5,
					name = L["Seconds"],
					desc = L["Color when the text is in the seconds format."],
				},
				minutesColor = {
					type = 'color',
					order = 6,
					name = L["Minutes"],
					desc = L["Color when the text is in the minutes format."],
				},
				hoursColor = {
					type = 'color',
					order = 7,
					name = L["Hours"],
					desc = L["Color when the text is in the hours format."],
				},
				daysColor = {
					type = 'color',
					order = 8,
					name = L["Days"],
					desc = L["Color when the text is in the days format."],
				},
			},
		},
		objectiveFrame = {
			order = 11,
			type = "group",
			name = L["Objective Frame"],
			get = function(info) return E.db.general[ info[#info] ] end,
			set = function(info, value) E.db.general[ info[#info] ] = value end,
			args = {
				objectiveFrameHeight = {
					order = 1,
					type = 'range',
					name = L["Objective Frame Height"],
					desc = L["Height of the objective tracker. Increase size to be able to see more objectives."],
					min = 400, max = E.screenheight, step = 1,
					set = function(info, value) E.db.general.objectiveFrameHeight = value; E:GetModule('Blizzard'):ObjectiveFrameHeight(); end,
				},
				bonusObjectivePosition = {
					order = 2,
					type = 'select',
					name = L["Bonus Reward Position"],
					desc = L["Position of bonus quest reward frame relative to the objective tracker."],
					values = {
						['RIGHT'] = L["Right"],
						['LEFT'] = L["Left"],
						['AUTO'] = L["Auto"],
					},
				},
			},
		},
	},
}


local DONATOR_STRING = ""
local DEVELOPER_STRING = ""
local TESTER_STRING = ""
local LINE_BREAK = "\n"
local DONATORS = {
	"Dandruff",
	"Tobur/Tarilya",
	"Netu",
	"Alluren",
	"Thorgnir",
	"Emalal",
	"Bendmeova",
	"Curl",
	"Zarac",
	"Emmo",
	"Oz",
	"Hawké",
	"Aynya",
	"Tahira",
	"Karsten Lumbye Thomsen",
	"Thomas B. aka Pitschiqüü",
	"Sea Garnet",
	"Paul Storry",
	"Azagar",
	"Archury",
	"Donhorn",
	"Woodson Harmon",
	"Phoenyx",
	"Feat",
	"Konungr",
	"Leyrin",
	"Dragonsys",
	"Tkalec",
	"Paavi",
	"Giorgio",
	"Bearscantank",
	"Eidolic",
	"Cosmo",
	"Adorno",
	"Domoaligato",
	"Smorg",
	"Pyrokee",
	"Portable",
	"Ithilyn"
}

local DEVELOPERS = {
	"Tukz",
	"Haste",
	"Nightcracker",
	"Omega1970",
	"Hydrazine"
}

local TESTERS = {
	"Tukui Community",
	"|cffF76ADBSarah|r - For Sarahing",
	"Affinity",
	"Modarch",
	"Bladesdruid",
	"Tirain",
	"Phima",
	"Veiled",
	"Blazeflack",
	"Repooc",
	"Darth Predator",
	'Alex',
	'Nidra',
	'Kurhyus',
	'BuG',
	'Yachanay',
	'Catok'
}

tsort(DONATORS, function(a,b) return a < b end) --Alphabetize
for _, donatorName in pairs(DONATORS) do
	tinsert(E.CreditsList, donatorName)
	DONATOR_STRING = DONATOR_STRING..LINE_BREAK..donatorName
end

tsort(DEVELOPERS, function(a,b) return a < b end) --Alphabetize
for _, devName in pairs(DEVELOPERS) do
	tinsert(E.CreditsList, devName)
	DEVELOPER_STRING = DEVELOPER_STRING..LINE_BREAK..devName
end

tsort(TESTERS, function(a,b) return a < b end) --Alphabetize
for _, testerName in pairs(TESTERS) do
	tinsert(E.CreditsList, testerName)
	TESTER_STRING = TESTER_STRING..LINE_BREAK..testerName
end

E.Options.args.credits = {
	type = "group",
	name = L["Credits"],
	order = -1,
	args = {
		text = {
			order = 1,
			type = "description",
			name = L["ELVUI_CREDITS"]..'\n\n'..L["Coding:"]..DEVELOPER_STRING..'\n\n'..L["Testing:"]..TESTER_STRING..'\n\n'..L["Donations:"]..DONATOR_STRING,
		},
	},
}

local profileTypeItems = {
	["profile"] = L["Profile"],
	["private"] = L["Private (Character Settings)"],
	["global"] = L["Global (Account Settings)"],
	["filtersNP"] = L["Filters (NamePlates)"],
	["filtersUF"] = L["Filters (UnitFrames)"],
	["filtersAll"] = L["Filters (All)"],
}
local profileTypeListOrder = {
	"profile",
	"private",
	"global",
	"filtersNP",
	"filtersUF",
	"filtersAll",
}
local exportTypeItems = {
	["text"] = L["Text"],
	["luaTable"] = L["Table"],
	["luaPlugin"] = L["Plugin"],
}
local exportTypeListOrder = {
	"text",
	"luaTable",
	"luaPlugin",
}

local exportString = ""
local function ExportImport_Open(mode)
	local Frame = AceGUI:Create("Frame")
	Frame:SetTitle("")
	Frame:EnableResize(false)
	Frame:SetWidth(800)
	Frame:SetHeight(600)
	Frame.frame:SetFrameStrata("FULLSCREEN_DIALOG")
	Frame:SetLayout("flow")


	local Box = AceGUI:Create("MultiLineEditBox");
	Box:SetNumLines(30)
	Box:DisableButton(true)
	Box:SetWidth(800)
	Box:SetLabel("")
	Frame:AddChild(Box)
	--Save original script so we can restore it later
	Box.editBox.OnTextChangedOrig = Box.editBox:GetScript("OnTextChanged")

	local Label1 = AceGUI:Create("Label")
	local font = GameFontHighlightSmall:GetFont()
	Label1:SetFont(font, 14)
	Label1:SetText(".") --Set temporary text so height is set correctly
	Label1:SetWidth(800)
	Frame:AddChild(Label1)

	local Label2 = AceGUI:Create("Label")
	local font = GameFontHighlightSmall:GetFont()
	Label2:SetFont(font, 14)
	Label2:SetText(".\n.")
	Label2:SetWidth(800)
	Frame:AddChild(Label2)

	if mode == "export" then
		Frame:SetTitle(L["Export Profile"])

		local ProfileTypeDropdown = AceGUI:Create("Dropdown")
		ProfileTypeDropdown:SetMultiselect(false)
		ProfileTypeDropdown:SetLabel(L["Choose What To Export"])
		ProfileTypeDropdown:SetList(profileTypeItems, profileTypeListOrder)
		ProfileTypeDropdown:SetValue("profile") --Default export
		Frame:AddChild(ProfileTypeDropdown)

		local ExportFormatDropdown = AceGUI:Create("Dropdown")
		ExportFormatDropdown:SetMultiselect(false)
		ExportFormatDropdown:SetLabel(L["Choose Export Format"])
		ExportFormatDropdown:SetList(exportTypeItems, exportTypeListOrder)
		ExportFormatDropdown:SetValue("text") --Default format
		ExportFormatDropdown:SetWidth(150)
		Frame:AddChild(ExportFormatDropdown)

		local exportButton = AceGUI:Create("Button")
		exportButton:SetText(L["Export Now"])
		exportButton:SetAutoWidth(true)
		local function OnClick(self)
			--Clear labels
			Label1:SetText("")
			Label2:SetText("")

			local profileType, exportFormat = ProfileTypeDropdown:GetValue(), ExportFormatDropdown:GetValue()
			local profileKey, profileExport = D:ExportProfile(profileType, exportFormat)
			if not profileKey or not profileExport then
				Label1:SetText(L["Error exporting profile!"])
			else
				Label1:SetText(format("%s: %s%s|r", L["Exported"], E.media.hexvaluecolor, profileTypeItems[profileType]))
				if profileType == "profile" then
					Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
				end
			end
			Box:SetText(profileExport);
			Box.editBox:HighlightText();
			Box:SetFocus();
			exportString = profileExport
		end
		exportButton:SetCallback("OnClick", OnClick)
		Frame:AddChild(exportButton)

		--Set scripts
		Box.editBox:SetScript("OnChar", function() Box:SetText(exportString); Box.editBox:HighlightText(); end);
		Box.editBox:SetScript("OnTextChanged", function(self, userInput)
			if userInput then
				--Prevent user from changing export string
				Box:SetText(exportString)
				Box.editBox:HighlightText();
			end
		end)

	elseif mode == "import" then
		Frame:SetTitle(L["Import Profile"])
		local importButton = AceGUI:Create("Button-ElvUI") --This version changes text color on SetDisabled
		importButton:SetDisabled(true)
		importButton:SetText(L["Import Now"])
		importButton:SetAutoWidth(true)
		importButton:SetCallback("OnClick", function()
			--Clear labels
			Label1:SetText("")
			Label2:SetText("")

			local text
			local success = D:ImportProfile(Box:GetText())
			if success then
				text = L["Profile imported successfully!"]
			else
				text = L["Error decoding data. Import string may be corrupted!"]
			end
			Label1:SetText(text)
		end)
		Frame:AddChild(importButton)

		local decodeButton = AceGUI:Create("Button-ElvUI")
		decodeButton:SetDisabled(true)
		decodeButton:SetText(L["Decode Text"])
		decodeButton:SetAutoWidth(true)
		decodeButton:SetCallback("OnClick", function()
			--Clear labels
			Label1:SetText("")
			Label2:SetText("")
			local decodedText
			local profileType, profileKey, profileData = D:Decode(Box:GetText())
			if profileData then
				decodedText = E:TableToLuaString(profileData)
			end
			local importText = D:CreateProfileExport(decodedText, profileType, profileKey)
			Box:SetText(importText)
		end)
		Frame:AddChild(decodeButton)

		local function OnTextChanged()
			local text = Box:GetText()
			if text == "" then
				Label1:SetText("")
				Label2:SetText("")
				importButton:SetDisabled(true)
				decodeButton:SetDisabled(true)
			else
				local stringType = D:GetImportStringType(text)
				if stringType == "Base64" then
					decodeButton:SetDisabled(false)
				else
					decodeButton:SetDisabled(true)
				end

				local profileType, profileKey = D:Decode(text)
				if not profileType or (profileType and profileType == "profile" and not profileKey) then
					Label1:SetText(L["Error decoding data. Import string may be corrupted!"])
					Label2:SetText("")
					importButton:SetDisabled(true)
					decodeButton:SetDisabled(true)
				else
					Label1:SetText(format("%s: %s%s|r", L["Importing"], E.media.hexvaluecolor, profileTypeItems[profileType] or ""))
					if profileType == "profile" then
						Label2:SetText(format("%s: %s%s|r", L["Profile Name"], E.media.hexvaluecolor, profileKey))
					end
					importButton:SetDisabled(false)
				end

				--Scroll frame doesn't scroll to the bottom by itself, so let's do that now
				Box.scrollFrame:SetVerticalScroll(Box.scrollFrame:GetVerticalScrollRange())
			end
		end

		Box.editBox:SetFocus()
		--Set scripts
		Box.editBox:SetScript("OnChar", nil);
		Box.editBox:SetScript("OnTextChanged", OnTextChanged)
	end

	Frame:SetCallback("OnClose", function(widget)
		--Restore changed scripts
		Box.editBox:SetScript("OnChar", nil)
		Box.editBox:SetScript("OnTextChanged", Box.editBox.OnTextChangedOrig)
		Box.editBox.OnTextChangedOrig = nil

		--Clear stored export string
		exportString = ""

		AceGUI:Release(widget)
		ACD:Open("ElvUI")
	end)

	--Clear default text
	Label1:SetText("")
	Label2:SetText("")

	--Close ElvUI Config
	ACD:Close("ElvUI")

	GameTooltip_Hide() --The tooltip from the Export/Import button stays on screen, so hide it
end

--Create Profiles Table
E.Options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(E.data);
AC:RegisterOptionsTable("ElvProfiles", E.Options.args.profiles)
E.Options.args.profiles.order = -10

LibStub('LibDualSpec-1.0'):EnhanceOptions(E.Options.args.profiles, E.data)

if not E.Options.args.profiles.plugins then
	E.Options.args.profiles.plugins = {}
end

E.Options.args.profiles.plugins["ElvUI"] = {
	desc = {
		name = L["This feature will allow you to transfer, settings to other characters."],
		type = 'description',
		order = 40.4,
	},
	distributeProfile = {
		name = L["Share Current Profile"],
		desc = L["Sends your current profile to your target."],
		type = 'execute',
		order = 40.5,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end
			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name)
			elseif server then
				D:Distribute(name, true)
			end
		end,
	},
	distributeGlobal = {
		name = L["Share Filters"],
		desc = L["Sends your filter settings to your target."],
		type = 'execute',
		order = 40.6,
		func = function()
			if not UnitExists("target") or not UnitIsPlayer("target") or not UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
				E:Print(L["You must be targeting a player."])
				return
			end

			local name, server = UnitName("target")
			if name and (not server or server == "") then
				D:Distribute(name, false, true)
			elseif server then
				D:Distribute(name, true, true)
			end
		end,
	},
	spacer = {
		order = 40.7,
		type = 'description',
		name = '',
	},
	exportProfile = {
		name = L["Export Profile"],
		type = 'execute',
		order = 40.8,
		func = function() ExportImport_Open("export") end,
	},
	importProfile = {
		name = L["Import Profile"],
		type = 'execute',
		order = 40.9,
		func = function() ExportImport_Open("import") end,
	},
}
