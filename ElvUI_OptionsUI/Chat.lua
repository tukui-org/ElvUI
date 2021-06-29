local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local CH = E:GetModule('Chat')
local Bags = E:GetModule('Bags')
local Layout = E:GetModule('Layout')
local ACH = E.Libs.ACH

local _G = _G
local gsub = gsub
local wipe = wipe
local pairs = pairs
local format = format
local strlower = strlower
local GameTooltip = _G.GameTooltip

local tabSelectorTable = {}

E.Options.args.chat = {
	type = 'group',
	name = L["Chat"],
	childGroups = 'tab',
	order = 2,
	get = function(info) return E.db.chat[info[#info]] end,
	set = function(info, value) E.db.chat[info[#info]] = value end,
	args = {
		intro = ACH:Description(L["CHAT_DESC"], 1),
		enable = {
			order = 2,
			type = 'toggle',
			name = L["Enable"],
			get = function() return E.private.chat.enable end,
			set = function(_, value) E.private.chat.enable = value; E:StaticPopup_Show('PRIVATE_RL') end
		},
		general = {
			order = 3,
			type = 'group',
			name = L["General"],
			disabled = function() return not E.Chat.Initialized end,
			args = {
				url = {
					order = 1,
					type = 'toggle',
					name = L["URL Links"],
					desc = L["Attempt to create URL links inside the chat."],
				},
				shortChannels = {
					order = 2,
					type = 'toggle',
					name = L["Short Channels"],
					desc = L["Shorten the channel names in chat."],
				},
				hyperlinkHover = {
					order = 3,
					type = 'toggle',
					name = L["Hyperlink Hover"],
					desc = L["Display the hyperlink tooltip while hovering over a hyperlink."],
					set = function(info, value)
						E.db.chat[info[#info]] = value
						CH:ToggleHyperlink(value)
					end,
				},
				sticky = {
					order = 3,
					type = 'toggle',
					name = L["Sticky Chat"],
					desc = L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."],
				},
				emotionIcons = {
					order = 5,
					type = 'toggle',
					name = L["Emotion Icons"],
					desc = L["Display emotion icons in chat."],
				},
				lfgIcons = {
					order = 6,
					type = 'toggle',
					name = L["Role Icon"],
					desc = L["Display LFG Icons in group chat."],
					set = function(self, value)
						E.db.chat.lfgIcons = value
						CH:CheckLFGRoles()
					end,
				},
				useAltKey = {
					order = 12,
					type = 'toggle',
					name = L["Use Alt Key"],
					desc = L["Require holding the Alt key down to move cursor or cycle through messages in the editbox."],
					set = function(self, value)
						E.db.chat.useAltKey = value
						CH:UpdateSettings()
					end,
				},
				autoClosePetBattleLog = {
					order = 13,
					type = 'toggle',
					name = L["Auto-Close Pet Battle Log"],
				},
				useBTagName = {
					order = 14,
					type = 'toggle',
					name = L["Use Real ID BattleTag"],
					desc = L["Use BattleTag instead of Real ID names in chat. Chat History will always use BattleTag."],
				},
				socialQueueMessages = {
					order = 15,
					type = 'toggle',
					name = L["Quick Join Messages"],
					desc = L["Show clickable Quick Join messages inside of the chat."],
				},
				copyChatLines = {
					order = 16,
					type = 'toggle',
					name = L["Copy Chat Lines"],
					desc = L["Adds an arrow infront of the chat lines to copy the entire line."],
				},
				hideCopyButton = {
					order = 17,
					type = 'toggle',
					name = L["Hide Copy Button"],
					set = function(self, value)
						E.db.chat.hideCopyButton = value
						CH:ToggleCopyChatButtons()
					end,
				},
				spacer = ACH:Spacer(18, 'full'),
				throttleInterval = {
					order = 20,
					type = 'range',
					name = L["Spam Interval"],
					desc = L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."],
					min = 0, max = 120, step = 1,
					set = function(info, value)
						E.db.chat[info[#info]] = value
						if value == 0 then
							CH:DisableChatThrottle()
						end
					end,
				},
				scrollDownInterval = {
					order = 21,
					type = 'range',
					name = L["Scroll Interval"],
					desc = L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."],
					min = 0, max = 120, step = 5,
				},
				numScrollMessages = {
					order = 22,
					type = 'range',
					name = L["Scroll Messages"],
					desc = L["Number of messages you scroll for each step."],
					min = 1, max = 10, step = 1,
				},
				maxLines = {
					order = 23,
					type = 'range',
					name = L["Max Lines"],
					min = 10, max = 5000, step = 1,
					set = function(info, value) E.db.chat[info[#info]] = value; CH:SetupChat() end,
				},
				editboxHistorySize = {
					order = 24,
					type = 'range',
					name = L["Editbox History"],
					min = 5, max = 50, step = 1,
				},
				resetHistory = {
					order = 25,
					type = 'execute',
					name = L["Reset Editbox History"],
					func = function() CH:ResetEditboxHistory() end
				},
				editBoxPosition = {
					order = 26,
					type = 'select',
					name = L["Chat EditBox Position"],
					desc = L["Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat."],
					values = {
						BELOW_CHAT = L["Below Chat"],
						ABOVE_CHAT = L["Above Chat"],
						BELOW_CHAT_INSIDE = L["Below Chat (Inside)"],
						ABOVE_CHAT_INSIDE = L["Above Chat (Inside)"],
					},
					set = function(info, value)
						E.db.chat[info[#info]] = value
						CH:UpdateEditboxAnchors()
					end,
				},
				tabSelection = {
					order = 60,
					type = 'group',
					name = L["Tab Selector"],
					set = function(info, value)
						E.db.chat[info[#info]] = value
						CH:UpdateChatTabColors()
					end,
					args = {
						tabSelectedTextEnabled = {
							order = 1,
							type = 'toggle',
							name = L["Colorize Selected Text"],
						},
						tabSelectedTextColor = {
							order = 2,
							type = 'color',
							hasAlpha = false,
							name = L["Selected Text Color"],
							disabled = function() return not E.db.chat.tabSelectedTextEnabled end,
							get = function()
								local t = E.db.chat.tabSelectedTextColor
								local d = P.chat.tabSelectedTextColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(_, r, g, b)
								local t = E.db.chat.tabSelectedTextColor
								t.r, t.g, t.b = r, g, b
								CH:UpdateChatTabColors()
							end,
						},
						tabSelector = {
							order = 3,
							type = 'select',
							name = L["Selector Style"],
							values = function()
								wipe(tabSelectorTable)

								for key, value in pairs(CH.TabStyles) do
									if key == 'NONE' then
										tabSelectorTable[key] = 'None'
									else
										local color = CH.db.tabSelectorColor
										local hexColor = E:RGBToHex(color.r, color.g, color.b)

										local selectedColor = E.media.hexvaluecolor
										if CH.db.tabSelectedTextEnabled then
											color = E.db.chat.tabSelectedTextColor
											selectedColor = E:RGBToHex(color.r, color.g, color.b)
										end

										tabSelectorTable[key] = format(value, hexColor, format('%sName|r', selectedColor), hexColor)
									end
								end

								return tabSelectorTable
							end,
						},
						tabSelectorColor = {
							order = 4,
							type = 'color',
							hasAlpha = false,
							name = L["Selector Color"],
							disabled = function() return E.db.chat.tabSelector == 'NONE' end,
							get = function()
								local t = E.db.chat.tabSelectorColor
								local d = P.chat.tabSelectorColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(_, r, g, b)
								local t = E.db.chat.tabSelectorColor
								t.r, t.g, t.b = r, g, b
								E:UpdateMedia()
							end,
						},
					}
				},
				historyGroup = {
					order = 65,
					type = 'group',
					name = L["History"],
					set = function(info, value) E.db.chat[info[#info]] = value end,
					args = {
						chatHistory = {
							order = 1,
							type = 'toggle',
							name = L["Enable"],
							desc = L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session."],
						},
						resetHistory = {
							order = 2,
							type = 'execute',
							name = L["Reset History"],
							func = function() CH:ResetHistory() end
						},
						historySize = {
							order = 3,
							type = 'range',
							name = L["History Size"],
							min = 10, max = 500, step = 1,
							disabled = function() return not E.db.chat.chatHistory end,
						},
						historyTypes = {
							order = 4,
							type = 'multiselect',
							name = L["Display Types"],
							get = function(info, key) return
								E.db.chat.showHistory[key]
							end,
							set = function(info, key, value)
								E.db.chat.showHistory[key] = value
							end,
							disabled = function() return not E.db.chat.chatHistory end,
							values = {
								WHISPER		= L["Whisper"],
								GUILD		= L["Guild"],
								OFFICER		= L["Officer"],
								PARTY		= L["Party"],
								RAID		= L["Raid"],
								INSTANCE	= L["Instance"],
								CHANNEL		= L["Channel"],
								SAY			= L["Say"],
								YELL		= L["Yell"],
								EMOTE		= L["Emote"]
							},
						}
					}
				},
				combatRepeat = {
					order = 70,
					type = 'group',
					name = L["Combat Repeat"],
					args = {
						enableCombatRepeat = {
							order = 1,
							type = 'toggle',
							name = L["Enable"],
						},
						numAllowedCombatRepeat = {
							order = 2,
							type = 'range',
							name = L["Number Allowed"],
							desc = L["Number of repeat characters while in combat before the chat editbox is automatically closed."],
							min = 2, max = 10, step = 1,
						},
					}
				},
				fadingGroup = {
					order = 75,
					type = 'group',
					name = L["Text Fade"],
					disabled = function() return not E.Chat.Initialized end,
					set = function(info, value) E.db.chat[info[#info]] = value; CH:UpdateFading() end,
					args = {
						fade = {
							order = 1,
							type = 'toggle',
							name = L["Enable"],
							desc = L["Fade the chat text when there is no activity."],
						},
						inactivityTimer = {
							order = 2,
							type = 'range',
							name = L["Inactivity Timer"],
							desc = L["Controls how many seconds of inactivity has to pass before chat is faded."],
							disabled = function() return not CH.db.fade end,
							min = 5, softMax = 120, step = 1,
						},
					},
				},
				fontGroup = {
					order = 80,
					type = 'group',
					name = L["Fonts"],
					disabled = function() return not E.Chat.Initialized end,
					set = function(info, value) E.db.chat[info[#info]] = value; CH:SetupChat() end,
					args = {
						font = {
							type = 'select', dialogControl = 'LSM30_Font',
							order = 1,
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						fontOutline = {
							order = 2,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = 'select',
							values = C.Values.FontFlags,
						},
						tabFont = {
							type = 'select', dialogControl = 'LSM30_Font',
							order = 4,
							name = L["Tab Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						tabFontOutline = {
							order = 5,
							name = L["Tab Font Outline"],
							desc = L["Set the font outline."],
							type = 'select',
							values = C.Values.FontFlags,
						},
						tabFontSize = {
							order = 6,
							name = L["Tab Font Size"],
							type = 'range',
							min = 4, max = 60, step = 1,
						},
					},
				},
				alerts = {
					order = 85,
					type = 'group',
					name = L["Alerts"],
					disabled = function() return not E.Chat.Initialized end,
					args = {
						noAlertInCombat = {
							order = 1,
							type = 'toggle',
							name = L["No Alert In Combat"],
						},
						keywordAlerts = {
							order = 2,
							type = 'group',
							name = L["Keyword Alerts"],
							inline = true,
							args = {
								keywordSound = {
									order = 1,
									type = 'select', dialogControl = 'LSM30_Sound',
									name = L["Keyword Alert"],
									width = 'double',
									values = AceGUIWidgetLSMlists.sound,
								},
								keywords = {
									order = 2,
									name = L["Keywords"],
									desc = L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank"],
									type = 'input',
									width = 'full',
									set = function(info, value) E.db.chat[info[#info]] = value; CH:UpdateChatKeywords() end,
								},
							},
						},
						channelAlerts = {
							order = 3,
							type = 'group',
							name = L["Channel Alerts"],
							inline = true,
							get = function(info) return E.db.chat.channelAlerts[info[#info]] end,
							set = function(info, value) E.db.chat.channelAlerts[info[#info]] = value end,
							args = {
								GUILD = {
									type = 'select', dialogControl = 'LSM30_Sound',
									name = L["Guild"],
									width = 'double',
									values = AceGUIWidgetLSMlists.sound,
								},
								OFFICER = {
									type = 'select', dialogControl = 'LSM30_Sound',
									name = L["Officer"],
									width = 'double',
									values = AceGUIWidgetLSMlists.sound,
								},
								INSTANCE = {
									type = 'select', dialogControl = 'LSM30_Sound',
									name = L["Instance"],
									width = 'double',
									values = AceGUIWidgetLSMlists.sound,
								},
								PARTY = {
									type = 'select', dialogControl = 'LSM30_Sound',
									name = L["Party"],
									width = 'double',
									values = AceGUIWidgetLSMlists.sound,
								},
								RAID = {
									type = 'select', dialogControl = 'LSM30_Sound',
									name = L["Raid"],
									width = 'double',
									values = AceGUIWidgetLSMlists.sound,
								},
								WHISPER = {
									type = 'select', dialogControl = 'LSM30_Sound',
									name = L["Whisper"],
									width = 'double',
									values = AceGUIWidgetLSMlists.sound,
								},
							},
						},
					},
				},
				voicechatGroup = {
					order = 90,
					type = 'group',
					name = L["BINDING_HEADER_VOICE_CHAT"],
					args = {
						hideVoiceButtons = {
							order = 1,
							type = 'toggle',
							name = L["Hide Voice Buttons"],
							desc = L["Completely hide the voice buttons."],
							set = function(info, value)
								E.db.chat[info[#info]] = value
								E:StaticPopup_Show('CONFIG_RL')
							end,
						},
						pinVoiceButtons = {
							order = 2,
							type = 'toggle',
							name = L["Pin Voice Buttons"],
							desc = L["This will pin the voice buttons to the chat's tab panel. Unchecking it will create a voice button panel with a mover."],
							disabled = function() return E.db.chat.hideVoiceButtons end,
							set = function(info, value)
								E.db.chat[info[#info]] = value
								E:StaticPopup_Show('CONFIG_RL')
							end,
						},
						desaturateVoiceIcons = {
							order = 3,
							type = 'toggle',
							name = L["Desaturate Voice Icons"],
							disabled = function() return E.db.chat.hideVoiceButtons end,
							set = function(info, value)
								E.db.chat[info[#info]] = value
								CH:UpdateVoiceChatIcons()
							end,
						},
						mouseoverVoicePanel = {
							order = 4,
							type = 'toggle',
							name = L["Mouse Over"],
							disabled = function() return E.db.chat.hideVoiceButtons or E.db.chat.pinVoiceButtons end,
							set = function(info, value) E.db.chat[info[#info]] = value CH:ResetVoicePanelAlpha() end,
						},
						voicePanelAlpha = {
							order = 5,
							type = 'range',
							name = L["Alpha"],
							desc = L["Change the alpha level of the frame."],
							disabled = function() return E.db.chat.hideVoiceButtons or E.db.chat.pinVoiceButtons or not E.db.chat.mouseoverVoicePanel end,
							set = function(info, value) E.db.chat[info[#info]] = value CH:ResetVoicePanelAlpha() end,
							min = 0, max = 1, step = 0.01,
						},
					},
				},
				timestampGroup = {
					order = 95,
					type = 'group',
					name = L["TIMESTAMPS_LABEL"],
					args = {
						useCustomTimeColor = {
							order = 1,
							type = 'toggle',
							name = L["Custom Timestamp Color"],
							disabled = function() return not E.db.chat.timeStampFormat == 'NONE' end,
						},
						customTimeColor = {
							order = 2,
							type = 'color',
							hasAlpha = false,
							name = L["Timestamp Color"],
							disabled = function() return (not E.db.chat.timeStampFormat == 'NONE' or not E.db.chat.useCustomTimeColor) end,
							get = function(info)
								local t = E.db.chat.customTimeColor
								local d = P.chat.customTimeColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								local t = E.db.chat.customTimeColor
								t.r, t.g, t.b = r, g, b
							end,
						},
						timeStampLocalTime = {
							order = 3,
							type = 'toggle',
							name = L["Local Time"],
							desc = L["If not set to true then the server time will be displayed instead."],
						},
						timeStampFormat = {
							order = 4,
							type = 'select',
							name = L["TIMESTAMPS_LABEL"],
							desc = L["OPTION_TOOLTIP_TIMESTAMPS"],
							values = {
								['NONE'] = L["NONE"],
								['%I:%M '] = '03:27',
								['%I:%M:%S '] = '03:27:32',
								['%I:%M %p '] = '03:27 PM',
								['%I:%M:%S %p '] = '03:27:32 PM',
								['%H:%M '] = '15:27',
								['%H:%M:%S '] =	'15:27:32'
							},
						},
					},
				},
				classColorMentionGroup = {
					order = 100,
					type = 'group',
					name = L["Class Color Mentions"],
					disabled = function() return not E.Chat.Initialized end,
					args = {
						classColorMentionsChat = {
							order = 1,
							type = 'toggle',
							name = L["Chat"],
							desc = L["Use class color for the names of players when they are mentioned."],
							get = function(info) return E.db.chat.classColorMentionsChat end,
							set = function(info, value) E.db.chat.classColorMentionsChat = value end,
							disabled = function() return not E.private.chat.enable end,
						},
						classColorMentionsSpeech = {
							order = 2,
							type = 'toggle',
							name = L["Chat Bubbles"],
							desc = L["Use class color for the names of players when they are mentioned."],
							get = function(info) return E.private.general.classColorMentionsSpeech end,
							set = function(info, value) E.private.general.classColorMentionsSpeech = value; E:StaticPopup_Show('PRIVATE_RL') end,
							disabled = function() return (E.private.general.chatBubbles == 'disabled' or not E.private.chat.enable) end,
						},
						classColorMentionExcludeName = {
							order = 21,
							name = L["Exclude Name"],
							desc = L["Excluded names will not be class colored."],
							type = 'input',
							get = function(info) return '' end,
							set = function(info, value)
								if value == '' or gsub(value, '%s+', '') == '' then return end --Don't allow empty entries
								E.global.chat.classColorMentionExcludedNames[strlower(value)] = value
							end,
						},
						classColorMentionExcludedNames = {
							order = 22,
							type = 'multiselect',
							name = L["Excluded Names"],
							values = function() return E.global.chat.classColorMentionExcludedNames end,
							get = function(info, value)	return E.global.chat.classColorMentionExcludedNames[value] end,
							set = function(info, value)
								E.global.chat.classColorMentionExcludedNames[value] = nil
								GameTooltip:Hide()--Make sure tooltip is properly hidden
							end,
						},
					},
				},
			},
		},
		panels = {
			order = 5,
			type = 'group',
			name = L["Panels"],
			args = {
				fadeUndockedTabs = {
					order = 1,
					type = 'toggle',
					name = L["Fade Undocked Tabs"],
					desc = L["Fades the text on chat tabs that are not docked at the left or right chat panel."],
					hidden = function() return not E.Chat.Initialized end,
					set = function(self, value)
						E.db.chat.fadeUndockedTabs = value
						CH:UpdateChatTabs()
					end,
				},
				fadeTabsNoBackdrop = {
					order = 2,
					type = 'toggle',
					name = L["Fade Tabs No Backdrop"],
					desc = L["Fades the text on chat tabs that are docked in a panel where the backdrop is disabled."],
					hidden = function() return not E.Chat.Initialized end,
					set = function(self, value)
						E.db.chat.fadeTabsNoBackdrop = value
						CH:UpdateChatTabs()
					end,
				},
				hideChatToggles = {
					order = 3,
					type = 'toggle',
					name = L["Hide Chat Toggles"],
					set = function(self, value)
						E.db.chat.hideChatToggles = value
						CH:RefreshToggleButtons()
						Layout:RepositionChatDataPanels()
					end,
				},
				fadeChatToggles = {
					order = 4,
					type = 'toggle',
					name = L["Fade Chat Toggles"],
					desc = L["Fades the buttons that toggle chat windows when that window has been toggled off."],
					disabled = function() return E.db.chat.hideChatToggles end,
					set = function(self, value)
						E.db.chat.fadeChatToggles = value
						CH:RefreshToggleButtons()
					end,
				},
				tabGroup = {
					order = 10,
					type = 'group',
					inline = true,
					name = L["Tab Panels"],
					hidden = function() return not E.Chat.Initialized end,
					args = {
						panelTabTransparency = {
							order = 1,
							type = 'toggle',
							name = L["Tab Panel Transparency"],
							customWidth = 250,
							disabled = function() return not E.db.chat.panelTabBackdrop end,
							set = function(info, value) E.db.chat.panelTabTransparency = value; Layout:SetChatTabStyle() end,
						},
						panelTabBackdrop = {
							order = 2,
							type = 'toggle',
							name = L["Tab Panel"],
							desc = L["Toggle the chat tab panel backdrop."],
							set = function(info, value)
								E.db.chat.panelTabBackdrop = value
								Layout:ToggleChatPanels()

								if E.db.chat.pinVoiceButtons and not E.db.chat.hideVoiceButtons then
									CH:ReparentVoiceChatIcon()
								end
							end,
						},
					}
				},
				datatextGroup = {
					order = 15,
					type = 'group',
					inline = true,
					name = L["DataText Panels"],
					args = {
						LeftChatDataPanelAnchor = {
							order = 1,
							type = 'select',
							name = L["Left Position"],
							values = {
								BELOW_CHAT = L["Below Chat"],
								ABOVE_CHAT = L["Above Chat"],
							},
							set = function(info, value) E.db.chat[info[#info]] = value; Layout:RepositionChatDataPanels() end,
						},
						RightChatDataPanelAnchor = {
							order = 2,
							type = 'select',
							name = L["Right Position"],
							values = {
								BELOW_CHAT = L["Below Chat"],
								ABOVE_CHAT = L["Above Chat"],
							},
							set = function(info, value) E.db.chat[info[#info]] = value; Layout:RepositionChatDataPanels() end,
						}
					}
				},
				panels = {
					order = 20,
					type = 'group',
					inline = true,
					name = L["Chat Panels"],
					args = {
						panelColor = {
							order = 1,
							type = 'color',
							name = L["Backdrop Color"],
							hasAlpha = true,
							get = function(info)
								local t = E.db.chat.panelColor
								local d = P.chat.panelColor
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
							end,
							set = function(info, r, g, b, a)
								local t = E.db.chat.panelColor
								t.r, t.g, t.b, t.a = r, g, b, a
								CH:Panels_ColorUpdate()
							end,
						},
						separateSizes = {
							order = 2,
							type = 'toggle',
							name = L["Separate Panel Sizes"],
							desc = L["Enable the use of separate size options for the right chat panel."],
							set = function(info, value)
								E.db.chat.separateSizes = value
								CH:PositionChats()
								Bags:Layout()
							end,
						},
						panelHeight = {
							order = 3,
							type = 'range',
							name = L["Panel Height"],
							desc = L["PANEL_DESC"],
							min = 60, max = 600, step = 1,
							set = function(info, value)
								E.db.chat.panelHeight = value
								CH:PositionChats()
							end,
						},
						panelWidth = {
							order = 4,
							type = 'range',
							name = L["Panel Width"],
							desc = L["PANEL_DESC"],
							set = function(info, value)
								E.db.chat.panelWidth = value
								CH:PositionChats()

								if not E.db.chat.separateSizes then
									Bags:Layout()
								end

								Bags:Layout(true)
							end,
							min = 50, max = 1000, step = 1,
						},
						panelBackdrop = {
							order = 5,
							type = 'select',
							name = L["Panel Backdrop"],
							desc = L["Toggle showing of the left and right chat panels."],
							values = {
								HIDEBOTH = L["Hide Both"],
								SHOWBOTH = L["Show Both"],
								LEFT = L["Left Only"],
								RIGHT = L["Right Only"],
							},
							set = function(info, value)
								E.db.chat.panelBackdrop = value
								Layout:ToggleChatPanels()
								CH:PositionChats()
								CH:UpdateEditboxAnchors()
							end,
						},
						panelSnapping = {
							order = 6,
							type = 'toggle',
							name = L["Panel Snapping"],
							desc = L["When disabled the Chat Background color has to be set via Blizzards Chat Tabs Background setting."],
							hidden = function() return not E.Chat.Initialized end,
							set = function(info, value)
								E.db.chat.panelSnapping = value
								CH:PositionChats()
							end
						},
						panelHeightRight = {
							order = 6,
							type = 'range',
							name = L["Right Panel Height"],
							desc = L["Adjust the height of your right chat panel."],
							min = 60, max = 600, step = 1,
							disabled = function() return not E.db.chat.separateSizes end,
							hidden = function() return not E.db.chat.separateSizes end,
							set = function(info, value)
								E.db.chat.panelHeightRight = value
								CH:PositionChats()
							end,
						},
						panelWidthRight = {
							order = 7,
							type = 'range',
							name = L["Right Panel Width"],
							desc = L["Adjust the width of your right chat panel."],
							disabled = function() return not E.db.chat.separateSizes end,
							hidden = function() return not E.db.chat.separateSizes end,
							set = function(info, value)
								E.db.chat.panelWidthRight = value
								CH:PositionChats()
								Bags:Layout()
							end,
							min = 50, max = 1000, step = 1,
						},
						panelBackdropNameLeft = {
							order = 8,
							type = 'input',
							width = 'full',
							name = L["Panel Texture (Left)"],
							desc = L["Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.\n\nPlease Note:\n-The image size recommended is 256x128\n-You must do a complete game restart after adding a file to the folder.\n-The file type must be tga format.\n\nExample: Interface\\AddOns\\ElvUI\\Media\\Textures\\Copy\n\nOr for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here."],
							set = function(info, value)
								E.db.chat[info[#info]] = value
								E:UpdateMedia()
							end,
						},
						panelBackdropNameRight = {
							order = 9,
							type = 'input',
							width = 'full',
							name = L["Panel Texture (Right)"],
							desc = L["Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.\n\nPlease Note:\n-The image size recommended is 256x128\n-You must do a complete game restart after adding a file to the folder.\n-The file type must be tga format.\n\nExample: Interface\\AddOns\\ElvUI\\Media\\Textures\\Copy\n\nOr for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here."],
							set = function(info, value)
								E.db.chat[info[#info]] = value
								E:UpdateMedia()
							end,
						},
					}
				},
			},
		},
	},
}
