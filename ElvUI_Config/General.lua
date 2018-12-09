local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule("Blizzard")

local _G = _G
local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames

local function GetChatWindowInfo()
	local ChatTabInfo = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		ChatTabInfo["ChatFrame"..i] = _G["ChatFrame"..i.."Tab"]:GetText()
	end
	return ChatTabInfo
end

E.Options.args.general = {
	type = "group",
	name = L["General"],
	order = 1,
	childGroups = "tab",
	get = function(info) return E.db.general[ info[#info] ] end,
	set = function(info, value) E.db.general[ info[#info] ] = value end,
	args = {
		intro = {
			order = 3,
			type = "description",
			name = L["ELVUI_DESC"],
		},
		general = {
			order = 4,
			type = "group",
			name = L["General"],
			args = {
				generalHeader = {
					order = 0,
					type = "header",
					name = L["General"],
				},
				messageRedirect = {
					order = 1,
					name = L["Chat Output"],
					desc = L["This selects the Chat Frame to use as the output of ElvUI messages."],
					type = 'select',
					values = GetChatWindowInfo()
				},
				pixelPerfect = {
					order = 2,
					name = L["Thin Border Theme"],
					desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
					type = 'toggle',
					get = function(info) return E.private.general.pixelPerfect end,
					set = function(info, value) E.private.general.pixelPerfect = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				interruptAnnounce = {
					order = 3,
					name = L["Announce Interrupts"],
					desc = L["Announce when you interrupt a spell to the specified chat channel."],
					type = 'select',
					values = {
						['NONE'] = NONE,
						['SAY'] = SAY,
						['PARTY'] = L["Party Only"],
						['RAID'] = L["Party / Raid"],
						['RAID_ONLY'] = L["Raid Only"],
						["EMOTE"] = CHAT_MSG_EMOTE,
					},
				},
				autoRepair = {
					order = 4,
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
					order = 5,
					name = L["Accept Invites"],
					desc = L["Automatically accept invites from guild/friends."],
					type = 'toggle',
				},
				autoRoll = {
					order = 8,
					name = L["Auto Greed/DE"],
					desc = L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."],
					type = 'toggle',
					disabled = function() return not E.private.general.lootRoll end
				},
				loot = {
					order = 9,
					type = "toggle",
					name = L["Loot"],
					desc = L["Enable/Disable the loot frame."],
					get = function(info) return E.private.general.loot end,
					set = function(info, value) E.private.general.loot = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				lootRoll = {
					order = 10,
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["Enable/Disable the loot roll frame."],
					get = function(info) return E.private.general.lootRoll end,
					set = function(info, value) E.private.general.lootRoll = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				eyefinity = {
					order = 11,
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					type = "toggle",
					get = function(info) return E.global.general.eyefinity end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				hideErrorFrame = {
					order = 12,
					name = L["Hide Error Text"],
					desc = L["Hides the red error text at the top of the screen while in combat."],
					type = "toggle"
				},
				taintLog = {
					order = 13,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."],
				},
				bottomPanel = {
					order = 14,
					type = 'toggle',
					name = L["Bottom Panel"],
					desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
					get = function(info) return E.db.general.bottomPanel end,
					set = function(info, value) E.db.general.bottomPanel = value; E:GetModule('Layout'):BottomPanelVisibility() end
				},
				topPanel = {
					order = 15,
					type = 'toggle',
					name = L["Top Panel"],
					desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
					get = function(info) return E.db.general.topPanel end,
					set = function(info, value) E.db.general.topPanel = value; E:GetModule('Layout'):TopPanelVisibility() end
				},
				afk = {
					order = 16,
					type = 'toggle',
					name = L["AFK Mode"],
					desc = L["When you go AFK display the AFK screen."],
					get = function(info) return E.db.general.afk end,
					set = function(info, value) E.db.general.afk = value; E:GetModule('AFK'):Toggle() end
				},
				enhancedPvpMessages = {
					order = 17,
					type = 'toggle',
					name = L["Enhanced PVP Messages"],
					desc = L["Display battleground messages in the middle of the screen."],
				},
				disableTutorialButtons = {
					order = 18,
					type = 'toggle',
					name = L["Disable Tutorial Buttons"],
					desc = L["Disables the tutorial button found on some frames."],
					get = function(info) return E.global.general.disableTutorialButtons end,
					set = function(info, value) E.global.general.disableTutorialButtons = value; E:StaticPopup_Show("GLOBAL_RL") end,
				},
				showMissingTalentAlert = {
					order = 19,
					type = "toggle",
					name = L["Missing Talent Alert"],
					desc = L["Show an alert frame if you have unspend talent points."],
					get = function(info) return E.global.general.showMissingTalentAlert end,
					set = function(info, value) E.global.general.showMissingTalentAlert = value; E:StaticPopup_Show("GLOBAL_RL") end,
				},
				autoScale = {
					order = 20,
					name = L["Auto Scale"],
					desc = L["Automatically scale the User Interface based on your screen resolution"],
					type = "toggle",
					get = function(info) return E.global.general.autoScale end,
					set = function(info, value) E.global.general[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				raidUtility = {
					order = 21,
					type = "toggle",
					name = RAID_CONTROL,
					desc = L["Enables the ElvUI Raid Control panel."],
					get = function(info) return E.private.general.raidUtility end,
					set = function(info, value) E.private.general.raidUtility = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				voiceOverlay = {
					order = 22,
					type = "toggle",
					name = E.NewSign..L["Voice Overlay"],
					desc = L["Replace Blizzard's Voice Overlay. |cffFF0000WARNING: WORK IN PROGRESS|r"],
					get = function(info) return E.private.general.voiceOverlay end,
					set = function(info, value) E.private.general.voiceOverlay = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				minUiScale = {
					order = 23,
					type = "range",
					name = L["Lowest Allowed UI Scale"],
					softMin = 0.20, softMax = 0.64, step = 0.01,
					get = function(info) return E.global.general.minUiScale end,
					set = function(info, value) E.global.general.minUiScale = value; E:StaticPopup_Show("GLOBAL_RL") end
				},
				talkingHeadFrameScale = {
					order = 24,
					type = "range",
					name = L["Talking Head Scale"],
					isPercent = true,
					min = 0.5, max = 2, step = 0.01,
					get = function(info) return E.db.general.talkingHeadFrameScale end,
					set = function(info, value) E.db.general.talkingHeadFrameScale = value; B:ScaleTalkingHeadFrame() end,
				},
				vehicleSeatIndicatorSize = {
					order = 25,
					type = "range",
					name = L["Vehicle Seat Indicator Size"],
					min = 64, max = 128, step = 4,
					get = function(info) return E.db.general.vehicleSeatIndicatorSize end,
					set = function(info, value) E.db.general.vehicleSeatIndicatorSize = value; B:UpdateVehicleFrame() end,
				},
				decimalLength = {
					order = 26,
					type = "range",
					name = L["Decimal Length"],
					desc = L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."],
					min = 0, max = 4, step = 1,
					get = function(info) return E.db.general.decimalLength end,
					set = function(info, value) E.db.general.decimalLength = value; E:StaticPopup_Show("GLOBAL_RL") end,
				},
				commandBarSetting = {
					order = 27,
					type = "select",
					name = L["Order Hall Command Bar"],
					get = function(info) return E.global.general.commandBarSetting end,
					set = function(info, value) E.global.general.commandBarSetting = value; E:StaticPopup_Show("GLOBAL_RL") end,
					width = "normal",
					values = {
						["DISABLED"] = L["Disable"],
						["ENABLED"] = L["Enable"],
						["ENABLED_RESIZEPARENT"] = L["Enable + Adjust Movers"],
					},
				},
				numberPrefixStyle = {
					order = 28,
					type = "select",
					name = L["Unit Prefix Style"],
					desc = L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."],
					get = function(info) return E.db.general.numberPrefixStyle end,
					set = function(info, value) E.db.general.numberPrefixStyle = value; E:StaticPopup_Show("CONFIG_RL") end,
					values = {
						["METRIC"] = "Metric (k, M, G)",
						["ENGLISH"] = "English (K, M, B)",
						["CHINESE"] = "Chinese (W, Y)",
						["KOREAN"] = "Korean (천, 만, 억)",
						["GERMAN"] = "German (Tsd, Mio, Mrd)"
					},
				},
			},
		},
		media = {
			order = 5,
			type = "group",
			name = L["Media"],
			get = function(info) return E.db.general[ info[#info] ] end,
			set = function(info, value) E.db.general[ info[#info] ] = value end,
			args = {
				fontHeader = {
					order = 1,
					type = "header",
					name = L["Fonts"],
				},
				fontSize = {
					order = 2,
					name = FONT_SIZE,
					desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
					type = "range",
					min = 4, softMax = 32, step = 1,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 3,
					name = L["Default Font"],
					desc = L["The font that the core of the UI will use."],
					values = AceGUIWidgetLSMlists.font,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},
				fontStyle = {
					type = "select",
					order = 4,
					name = L["Font Outline"],
					values = {
						["NONE"] = NONE,
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
					set = function(info, value) E.db.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); end,
				},
				applyFontToAll = {
					order = 5,
					type = 'execute',
					name = L["Apply Font To All"],
					desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
					func = function() E:StaticPopup_Show("APPLY_FONT_WARNING"); end,
				},
				dmgfont = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 6,
					name = L["CombatText Font"],
					desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
				},
				namefont = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 7,
					name = L["Name Font"],
					desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:UpdateMedia(); E:UpdateFontTemplates(); E:StaticPopup_Show("PRIVATE_RL"); end,
				},
				replaceBlizzFonts = {
					order = 8,
					type = 'toggle',
					name = L["Replace Blizzard Fonts"],
					desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI config. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
					get = function(info) return E.private.general[ info[#info] ] end,
					set = function(info, value) E.private.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				},
				texturesHeaderSpacing = {
					order = 19,
					type = "description",
					name = " ",
				},
				texturesHeader = {
					order = 20,
					type = "header",
					name = L["Textures"],
				},
				normTex = {
					type = "select", dialogControl = 'LSM30_Statusbar',
					order = 21,
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
					order = 22,
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
				applyTextureToAll = {
					order = 23,
					type = 'execute',
					name = L["Apply Texture To All"],
					desc = L["Applies the primary texture to all statusbars."],
					func = function()
						local texture = E.private.general.normTex
						E.db.unitframe.statusbar = texture
						E:UpdateAll(true)
					end,
				},
				colorsHeaderSpacing = {
					order = 29,
					type = "description",
					name = " ",
				},
				colorsHeader = {
					order = 30,
					type = "header",
					name = COLORS,
				},
				bordercolor = {
					type = "color",
					order = 31,
					name = L["Border Color"],
					desc = L["Main border color of the UI."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						E:UpdateMedia()
						E:UpdateBorderColors()
					end,
				},
				backdropcolor = {
					type = "color",
					order = 32,
					name = L["Backdrop Color"],
					desc = L["Main backdrop color of the UI."],
					hasAlpha = false,
					get = function(info)
						local t = E.db.general[ info[#info] ]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.general[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						E:UpdateMedia()
						E:UpdateBackdropColors()
					end,
				},
				backdropfadecolor = {
					type = "color",
					order = 33,
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
					order = 34,
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
				cropIcon = {
					order = 35,
					type = 'toggle',
					name = L["Crop Icons"],
					desc = L["This is for Customized Icons in your Interface/Icons folder."],
					get = function(info) return E.db.general[ info[#info] ] end,
					set = function(info, value) E.db.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				},
			},
		},
		totems = {
			order = 6,
			type = "group",
			name = L["Class Totems"],
			get = function(info) return E.db.general.totems[ info[#info] ] end,
			set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):PositionAndSize() end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Class Totems"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.totems[ info[#info] ] = value; E:GetModule('Totems'):ToggleEnable() end,
				},
				size = {
					order = 3,
					type = 'range',
					name = L["Button Size"],
					min = 24, max = 60, step = 1,
				},
				spacing = {
					order = 4,
					type = 'range',
					name = L["Button Spacing"],
					min = 1, max = 10, step = 1,
				},
				sortDirection = {
					order = 5,
					type = 'select',
					name = L["Sort Direction"],
					values = {
						['ASCENDING'] = L["Ascending"],
						['DESCENDING'] = L["Descending"],
					},
				},
				growthDirection = {
					order = 6,
					type = 'select',
					name = L["Bar Direction"],
					values = {
						['VERTICAL'] = L["Vertical"],
						['HORIZONTAL'] = L["Horizontal"],
					},
				},
			},
		},
		chatBubbles = {
			order = 7,
			type = "group",
			name = L["Chat Bubbles"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Chat Bubbles"],
				},
				style = {
					order = 2,
					type = "select",
					name = L["Chat Bubbles Style"],
					desc = L["Skin the blizzard chat bubbles."],
					get = function(info) return E.private.general.chatBubbles end,
					set = function(info, value) E.private.general.chatBubbles = value; E:StaticPopup_Show("PRIVATE_RL") end,
					values = {
						['backdrop'] = L["Skin Backdrop"],
						['nobackdrop'] = L["Remove Backdrop"],
						['backdrop_noborder'] = L["Skin Backdrop (No Borders)"],
						['disabled'] = DISABLE
					}
				},
				font = {
					order = 3,
					type = "select",
					name = L["Font"],
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					get = function(info) return E.private.general.chatBubbleFont end,
					set = function(info, value) E.private.general.chatBubbleFont = value; E:StaticPopup_Show("PRIVATE_RL") end,
				},
				fontSize = {
					order = 4,
					type = "range",
					name = FONT_SIZE,
					get = function(info) return E.private.general.chatBubbleFontSize end,
					set = function(info, value) E.private.general.chatBubbleFontSize = value; E:StaticPopup_Show("PRIVATE_RL") end,
					min = 4, max = 212, step = 1,
				},
				fontOutline = {
					order = 5,
					type = "select",
					name = L["Font Outline"],
					get = function(info) return E.private.general.chatBubbleFontOutline end,
					set = function(info, value) E.private.general.chatBubbleFontOutline = value; E:StaticPopup_Show("PRIVATE_RL") end,
					values = {
						["NONE"] = NONE,
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
				},
				name = {
					order = 6,
					type = "toggle",
					name = L["Chat Bubble Names"],
					desc = L["Display the name of the unit on the chat bubble. This will not work if backdrop is disabled or when you are in an instance."],
					get = function(info) return E.private.general.chatBubbleName end,
					set = function(info, value) E.private.general.chatBubbleName = value; E:StaticPopup_Show("PRIVATE_RL") end,
				},
			},
		},
		objectiveFrameGroup = {
			order = 8,
			type = "group",
			name = L["Objective Frame"],
			args = {
				objectiveFrameHeader = {
					order = 30,
					type = "header",
					name = L["Objective Frame"],
				},
				objectiveFrameHeight = {
					order = 31,
					type = 'range',
					name = L["Objective Frame Height"],
					desc = L["Height of the objective tracker. Increase size to be able to see more objectives."],
					min = 400, max = E.screenheight, step = 1,
					get = function(info) return E.db.general.objectiveFrameHeight end,
					set = function(info, value) E.db.general.objectiveFrameHeight = value; E:GetModule('Blizzard'):SetObjectiveFrameHeight(); end,
				},
				bonusObjectivePosition = {
					order = 32,
					type = 'select',
					name = L["Bonus Reward Position"],
					desc = L["Position of bonus quest reward frame relative to the objective tracker."],
					get = function(info) return E.db.general.bonusObjectivePosition end,
					set = function(info, value) E.db.general.bonusObjectivePosition = value; end,
					values = {
						['RIGHT'] = L["Right"],
						['LEFT'] = L["Left"],
						['AUTO'] = L["Automatic"],
					},
				},
			},
		},
		threatGroup = {
			order = 9,
			type = "group",
			name = L["Threat"],
			args = {
				threatHeader = {
					order = 40,
					type = "header",
					name = L["Threat"],
				},
				threatEnable = {
					order = 41,
					type = "toggle",
					name = L["Enable"],
					get = function(info) return E.db.general.threat.enable end,
					set = function(info, value) E.db.general.threat.enable = value; E:GetModule('Threat'):ToggleEnable()end,
				},
				threatPosition = {
					order = 42,
					type = 'select',
					name = L["Position"],
					desc = L["Adjust the position of the threat bar to either the left or right datatext panels."],
					values = {
						['LEFTCHAT'] = L["Left Chat"],
						['RIGHTCHAT'] = L["Right Chat"],
					},
					get = function(info) return E.db.general.threat.position end,
					set = function(info, value) E.db.general.threat.position = value; E:GetModule('Threat'):UpdatePosition() end,
				},
				threatTextSize = {
					order = 43,
					name = FONT_SIZE,
					type = "range",
					min = 6, max = 22, step = 1,
					get = function(info) return E.db.general.threat.textSize end,
					set = function(info, value) E.db.general.threat.textSize = value; E:GetModule('Threat'):UpdatePosition() end,
				},
				threatTextOutline = {
					order = 44,
					type = "select",
					name = L["Font Outline"],
					get = function(info) return E.db.general.threat.textOutline end,
					set = function(info, value) E.db.general.threat.textOutline = value; E:GetModule('Threat'):UpdatePosition() end,
					values = {
						["NONE"] = NONE,
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
				},
			},
		},
		alternativePowerGroup = {
			order = 10,
			type = "group",
			name = L["Alternative Power"],
			get = function(info) return E.db.general.altPowerBar[ info[#info] ] end,
			set = function(info, value)
				E.db.general.altPowerBar[ info[#info] ] = value;
				B:UpdateAltPowerBarSettings();
			end,
			args = {
				alternativePowerHeader = {
					order = 1,
					type = "header",
					name = L["Alternative Power"],
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					desc = L["Replace Blizzard's Alternative Power Bar"],
					width = 'full',
					set = function(info, value)
						E.db.general.altPowerBar[ info[#info] ] = value;
						E:StaticPopup_Show("PRIVATE_RL");
					end,
				},
				height = {
					order = 3,
					type = "range",
					name = L["Height"],
					min = 5, max = 100, step = 1,

				},
				width = {
					order = 4,
					type = "range",
					name = L["Width"],
					min = 50, max = 1000, step = 1,
				},
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 5,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontSize = {
					order = 6,
					name = FONT_SIZE,
					type = "range",
					min = 6, max = 22, step = 1,
				},
				fontOutline = {
					order = 7,
					type = "select",
					name = L["Font Outline"],
					values = {
						["NONE"] = NONE,
						["OUTLINE"] = "OUTLINE",
						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
						["THICKOUTLINE"] = "THICKOUTLINE",
					},
				},
				statusBar = {
					order = 7,
					type = "select", dialogControl = 'LSM30_Statusbar',
					name = L["StatusBar Texture"],
					values = AceGUIWidgetLSMlists.statusbar,
				},
				statusBarColorGradient = {
					order = 8,
					name = L["Color Gradient"],
					type = 'toggle',
					get = function(info)
						return E.db.general.altPowerBar[ info[#info] ]
					end,
					set = function(info, value)
						E.db.general.altPowerBar[ info[#info] ] = value;
						B:UpdateAltPowerBarColors();
					end,
				},
				statusBarColor = {
					type = 'color',
					order = 9,
					name = COLOR,
					disabled = function()
						return E.db.general.altPowerBar.statusBarColorGradient
					end,
					get = function(info)
						local t = E.db.general.altPowerBar[ info[#info] ]
						local d = P.general.altPowerBar[ info[#info] ]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b
					end,
					set = function(info, r, g, b)
						local t = E.db.general.altPowerBar[ info[#info] ]
						t.r, t.g, t.b = r, g, b
						B:UpdateAltPowerBarColors();
					end,
				},
				textFormat = {
					order = 10,
					type = 'select',
					name = L["Text Format"],
					sortByValue = true,
					values = {
						NONE = NONE,
						NAME = NAME,
						NAMEPERC = L["Name: Percent"],
						NAMECURMAX = L["Name: Current / Max"],
						NAMECURMAXPERC = L["Name: Current / Max - Percent"],
						PERCENT = L["Percent"],
						CURMAX = L["Current / Max"],
						CURMAXPERC = L["Current / Max - Percent"],
					},
				},
			},
		},
	},
}
