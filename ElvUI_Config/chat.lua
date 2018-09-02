local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CH = E:GetModule('Chat')

local _G = _G
local gsub = string.gsub
local strlower = string.lower
local GameTooltip = _G['GameTooltip']

E.Options.args.chat = {
	type = "group",
	name = L["Chat"],
	childGroups = "tab",
	get = function(info) return E.db.chat[ info[#info] ] end,
	set = function(info, value) E.db.chat[ info[#info] ] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["CHAT_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			get = function(info) return E.private.chat.enable end,
			set = function(info, value) E.private.chat.enable = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["General"],
				},
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
						E.db.chat[ info[#info] ] = value
						if value == true then
							CH:EnableHyperlink()
						else
							CH:DisableHyperlink()
						end
					end,
				},
				sticky = {
					order = 3,
					type = 'toggle',
					name = L["Sticky Chat"],
					desc = L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."],
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
					end,
				},
				fade = {
					order = 4,
					type = 'toggle',
					name = L["Fade Chat"],
					desc = L["Fade the chat text when there is no activity."],
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
						CH:UpdateFading()
					end,
				},
				emotionIcons = {
					order = 5,
					type = 'toggle',
					name = L["Emotion Icons"],
					desc = L["Display emotion icons in chat."],
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
					end,
				},
				lfgIcons = {
					order = 6,
					type = 'toggle',
					name = L["LFG Icons"],
					desc = L["Display LFG Icons in group chat."],
					set = function(self, value)
						E.db.chat.lfgIcons = value;
						CH:CheckLFGRoles()
					end,
				},
				fadeUndockedTabs = {
					order = 7,
					type = 'toggle',
					name = L["Fade Undocked Tabs"],
					desc = L["Fades the text on chat tabs that are not docked at the left or right chat panel."],
					set = function(self, value)
						E.db.chat.fadeUndockedTabs = value;
						CH:UpdateChatTabs()
					end,
				},
				fadeTabsNoBackdrop = {
					order = 8,
					type = 'toggle',
					name = L["Fade Tabs No Backdrop"],
					desc = L["Fades the text on chat tabs that are docked in a panel where the backdrop is disabled."],
					set = function(self, value)
						E.db.chat.fadeTabsNoBackdrop = value;
						CH:UpdateChatTabs()
					end,
				},
				chatHistory = {
					order = 9,
					type = 'toggle',
					name = L["Chat History"],
					desc = L["Log the main chat frames history. So when you reloadui or log in and out you see the history from your last session."],
				},
				useAltKey = {
					order = 10,
					type = "toggle",
					name = L["Use Alt Key"],
					desc = L["Require holding the Alt key down to move cursor or cycle through messages in the editbox."],
					set = function(self, value)
						E.db.chat.useAltKey = value;
						CH:UpdateSettings()
					end,
				},
				autoClosePetBattleLog = {
					order = 12,
					type = "toggle",
					name = L["Auto-Close Pet Battle Log"],
				},
				useBTagName = {
					order = 13,
					type = "toggle",
					name = L["Use Real ID BattleTag"],
					desc = L["Use BattleTag instead of Real ID names in chat. Chat History will always use BattleTag."],
				},
				socialQueueMessages = {
					order = 14,
					type = "toggle",
					name = L["Quick Join Messages"],
					desc = L["Show clickable Quick Join messages inside of the chat."],
				},
				copyChatLines = {
					order = 15,
					type = "toggle",
					name = L["Copy Chat Lines"],
					desc = L["Adds an arrow infront of the chat lines to copy the entire line."],
				},
				useCustomTimeColor = {
					order = 16,
					type = "toggle",
					name = L["Custom Timestamp Color"],
					disabled = function() return not E.db.chat.timeStampFormat == "NONE" end,
				},
				customTimeColor = {
					order = 17,
					type = "color",
					hasAlpha = false,
					name = L["Timestamp Color"],
					disabled = function() return (not E.db.chat.timeStampFormat == "NONE" or not E.db.chat.useCustomTimeColor) end,
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
				timeStampFormat = {
					order = 18,
					type = 'select',
					name = TIMESTAMPS_LABEL,
					desc = OPTION_TOOLTIP_TIMESTAMPS,
					values = {
						['NONE'] = NONE,
						["%I:%M "] = "03:27",
						["%I:%M:%S "] = "03:27:32",
						["%I:%M %p "] = "03:27 PM",
						["%I:%M:%S %p "] = "03:27:32 PM",
						["%H:%M "] = "15:27",
						["%H:%M:%S "] =	"15:27:32"
					},
				},
				throttleInterval = {
					order = 19,
					type = 'range',
					name = L["Spam Interval"],
					desc = L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."],
					min = 0, max = 120, step = 1,
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
						if value == 0 then
							CH:DisableChatThrottle()
						end
					end,
				},
				scrollDownInterval = {
					order = 20,
					type = 'range',
					name = L["Scroll Interval"],
					desc = L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."],
					min = 0, max = 120, step = 5,
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
					end,
				},
				numAllowedCombatRepeat = {
					order = 21,
					type = "range",
					name = L["Allowed Combat Repeat"],
					desc = L["Number of repeat characters while in combat before the chat editbox is automatically closed."],
					min = 2, max = 10, step = 1,
				},
				numScrollMessages = {
					order = 22,
					type = "range",
					name = L["Scroll Messages"],
					desc = L["Number of messages you scroll for each step."],
					min = 1, max = 10, step = 1,
				}
			},
		},
		alerts = {
			order = 4,
			type = 'group',
			name = L["Alerts"],
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Alerts"],
				},
				whisperSound = {
					order = 1,
					type = 'select', dialogControl = 'LSM30_Sound',
					name = L["Whisper Alert"],
					values = AceGUIWidgetLSMlists.sound,
				},
				keywordSound = {
					order = 2,
					type = 'select', dialogControl = 'LSM30_Sound',
					name = L["Keyword Alert"],
					values = AceGUIWidgetLSMlists.sound,
				},
				noAlertInCombat = {
					order = 3,
					type = "toggle",
					name = L["No Alert In Combat"],
				},
				keywords = {
					order = 4,
					name = L["Keywords"],
					desc = L["List of words to color in chat if found in a message. If you wish to add multiple words you must seperate the word with a comma. To search for your current name you can use %MYNAME%.\n\nExample:\n%MYNAME%, ElvUI, RBGs, Tank"],
					type = 'input',
					width = 'full',
					set = function(info, value) E.db.chat[ info[#info] ] = value; CH:UpdateChatKeywords() end,
				},
			},
		},
		panels = {
			order = 5,
			type = 'group',
			name = L["Panels"],
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Panels"],
				},
				lockPositions = {
					order = 1,
					type = 'toggle',
					name = L["Lock Positions"],
					desc = L["Attempt to lock the left and right chat frame positions. Disabling this option will allow you to move the main chat frame anywhere you wish."],
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
						if value == true then
							CH:PositionChat(true)
						end
					end,
				},
				panelTabTransparency = {
					order = 2,
					type = 'toggle',
					name = L["Tab Panel Transparency"],
					set = function(info, value) E.db.chat.panelTabTransparency = value; E:GetModule('Layout'):SetChatTabStyle(); end,
				},
				panelTabBackdrop = {
					order = 3,
					type = 'toggle',
					name = L["Tab Panel"],
					desc = L["Toggle the chat tab panel backdrop."],
					set = function(info, value) E.db.chat.panelTabBackdrop = value; E:GetModule('Layout'):ToggleChatPanels(); end,
				},
				editBoxPosition = {
					order = 4,
					type = 'select',
					name = L["Chat EditBox Position"],
					desc = L["Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat."],
					values = {
						['BELOW_CHAT'] = L["Below Chat"],
						['ABOVE_CHAT'] = L["Above Chat"],
					},
					set = function(info, value) E.db.chat[ info[#info] ] = value; CH:UpdateAnchors() end,
				},
				panelBackdrop = {
					order = 5,
					type = 'select',
					name = L["Panel Backdrop"],
					desc = L["Toggle showing of the left and right chat panels."],
					set = function(info, value) E.db.chat.panelBackdrop = value; E:GetModule('Layout'):ToggleChatPanels(); E:GetModule('Chat'):PositionChat(true); E:GetModule('Chat'):UpdateAnchors() end,
					values = {
						['HIDEBOTH'] = L["Hide Both"],
						['SHOWBOTH'] = L["Show Both"],
						['LEFT'] = L["Left Only"],
						['RIGHT'] = L["Right Only"],
					},
				},
				separateSizes = {
					order = 6,
					type = 'toggle',
					name = L["Separate Panel Sizes"],
					desc = L["Enable the use of separate size options for the right chat panel."],
					set = function(info, value)
						E.db.chat.separateSizes = value;
						E:GetModule('Chat'):PositionChat(true);
						E:GetModule('Bags'):Layout();
					end,
				},
				spacer1 = {
					order = 7,
					type = 'description',
					name = '',
				},
				panelHeight = {
					order = 8,
					type = 'range',
					name = L["Panel Height"],
					desc = L["PANEL_DESC"],
					set = function(info, value) E.db.chat.panelHeight = value; E:GetModule('Chat'):PositionChat(true); end,
					min = 60, max = 600, step = 1,
				},
				panelWidth = {
					order = 9,
					type = 'range',
					name = L["Panel Width"],
					desc = L["PANEL_DESC"],
					set = function(info, value)
						E.db.chat.panelWidth = value;
						E:GetModule('Chat'):PositionChat(true);
						local bags = E:GetModule('Bags');
						if not E.db.chat.separateSizes then
							bags:Layout();
						end
						bags:Layout(true);
					end,
					min = 50, max = 1000, step = 1,
				},
				panelColor = {
					order = 10,
					type = "color",
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
				spacer2 = {
					order = 15,
					type = 'description',
					name = '',
				},
				panelHeightRight = {
					order = 16,
					type = 'range',
					name = L["Right Panel Height"],
					desc = L["Adjust the height of your right chat panel."],
					disabled = function() return not E.db.chat.separateSizes end,
					hidden = function() return not E.db.chat.separateSizes end,
					set = function(info, value) E.db.chat.panelHeightRight = value; E:GetModule('Chat'):PositionChat(true); end,
					min = 60, max = 600, step = 1,
				},
				panelWidthRight = {
					order = 17,
					type = 'range',
					name = L["Right Panel Width"],
					desc = L["Adjust the width of your right chat panel."],
					disabled = function() return not E.db.chat.separateSizes end,
					hidden = function() return not E.db.chat.separateSizes end,
					set = function(info, value)
						E.db.chat.panelWidthRight = value;
						E:GetModule('Chat'):PositionChat(true);
						E:GetModule('Bags'):Layout();
					end,
					min = 50, max = 1000, step = 1,
				},
				panelBackdropNameLeft = {
					order = 18,
					type = 'input',
					width = 'full',
					name = L["Panel Texture (Left)"],
					desc = L["Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.\n\nPlease Note:\n-The image size recommended is 256x128\n-You must do a complete game restart after adding a file to the folder.\n-The file type must be tga format.\n\nExample: Interface\\AddOns\\ElvUI\\media\\textures\\copy\n\nOr for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here."],
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
						E:UpdateMedia()
					end,
				},
				panelBackdropNameRight = {
					order = 19,
					type = 'input',
					width = 'full',
					name = L["Panel Texture (Right)"],
					desc = L["Specify a filename located inside the World of Warcraft directory. Textures folder that you wish to have set as a panel background.\n\nPlease Note:\n-The image size recommended is 256x128\n-You must do a complete game restart after adding a file to the folder.\n-The file type must be tga format.\n\nExample: Interface\\AddOns\\ElvUI\\media\\textures\\copy\n\nOr for most users it would be easier to simply put a tga file into your WoW folder, then type the name of the file here."],
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
						E:UpdateMedia()
					end,
				},
			},
		},
		fontGroup = {
			order = 120,
			type = 'group',
			name = L["Fonts"],
			set = function(info, value) E.db.chat[ info[#info] ] = value; CH:SetupChat() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Fonts"],
				},
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 1,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontOutline = {
					order = 2,
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						['NONE'] = NONE,
						['OUTLINE'] = 'OUTLINE',
						['MONOCHROMEOUTLINE'] = 'MONOCHROMEOUTLINE',
						['THICKOUTLINE'] = 'THICKOUTLINE',
					},
				},
				tabFont = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 4,
					name = L["Tab Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				tabFontSize = {
					order = 5,
					name = L["Tab Font Size"],
					type = "range",
					min = 4, max = 212, step = 1,
				},
				tabFontOutline = {
					order = 6,
					name = L["Tab Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						['NONE'] = NONE,
						['OUTLINE'] = 'OUTLINE',

						['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
						['THICKOUTLINE'] = 'THICKOUTLINE',
					},
				},
			},
		},
		classColorMentionGroup = {
			order = 130,
			type = "group",
			name = L["Class Color Mentions"],
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Class Color Mentions"],
				},
				classColorMentionsChat = {
					order = 1,
					type = "toggle",
					name = L["Chat"],
					desc = L["Use class color for the names of players when they are mentioned."],
					get = function(info) return E.db.chat.classColorMentionsChat end,
					set = function(info, value) E.db.chat.classColorMentionsChat = value end,
					disabled = function() return not E.private.chat.enable end,
				},
				classColorMentionsSpeech = {
					order = 2,
					type = "toggle",
					name = L["Chat Bubbles"],
					desc = L["Use class color for the names of players when they are mentioned."],
					get = function(info) return E.private.general.classColorMentionsSpeech end,
					set = function(info, value) E.private.general.classColorMentionsSpeech = value; E:StaticPopup_Show("PRIVATE_RL") end,
					disabled = function() return (E.private.general.chatBubbles == "disabled" or not E.private.chat.enable) end,
				},
				classColorMentionExcludeName = {
					order = 21,
					name = L["Exclude Name"],
					desc = L["Excluded names will not be class colored."],
					type = 'input',
					get = function(info) return "" end,
					set = function(info, value)
						if value == "" or gsub(value, "%s+", "") == "" then return; end --Don't allow empty entries
						E.global.chat.classColorMentionExcludedNames[strlower(value)] = value
					end,
				},
				classColorMentionExcludedNames = {
					order = 22,
					type = "multiselect",
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
}
