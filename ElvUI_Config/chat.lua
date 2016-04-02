local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local CH = E:GetModule('Chat')

E.Options.args.chat = {
	type = "group",
	name = L["Chat"],
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
			guiInline = true,
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
				spacer = {
					order = 11,
					type = 'description',
					name = '',
				},
				throttleInterval = {
					order = 12,
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
					order = 13,
					type = 'range',
					name = L["Scroll Interval"],
					desc = L["Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely."],
					min = 0, max = 120, step = 5,
					set = function(info, value)
						E.db.chat[ info[#info] ] = value
					end,
				},
				timeStampFormat = {
					order = 14,
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

			},
		},
		alerts = {
			order = 4,
			type = 'group',
			name = L["Alerts"],
			guiInline = true,
			args = {
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
			guiInline = true,
			args = {
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
					min = 50, max = 700, step = 1,
				},
				spacer2 = {
					order = 10,
					type = 'description',
					name = '',
				},
				panelHeightRight = {
					order = 11,
					type = 'range',
					name = L["Right Panel Height"],
					desc = L["Adjust the height of your right chat panel."],
					disabled = function() return not E.db.chat.separateSizes end,
					hidden = function() return not E.db.chat.separateSizes end,
					set = function(info, value) E.db.chat.panelHeightRight = value; E:GetModule('Chat'):PositionChat(true); end,
					min = 60, max = 600, step = 1,
				},
				panelWidthRight = {
					order = 12,
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
					min = 50, max = 700, step = 1,
				},
				panelBackdropNameLeft = {
					order = 13,
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
					order = 14,
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
			guiInline = true,
			name = L["Fonts"],
			set = function(info, value) E.db.chat[ info[#info] ] = value; CH:SetupChat() end,
			args = {
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
						['NONE'] = L["None"],
						['OUTLINE'] = 'OUTLINE',

						['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
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
					min = 4, max = 22, step = 1,
				},
				tabFontOutline = {
					order = 6,
					name = L["Tab Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						['NONE'] = L["None"],
						['OUTLINE'] = 'OUTLINE',

						['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
						['THICKOUTLINE'] = 'THICKOUTLINE',
					},
				},
			},
		},
	},
}