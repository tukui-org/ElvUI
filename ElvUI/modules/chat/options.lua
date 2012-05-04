local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
			set = function(info, value) E.private.chat.enable = value; StaticPopup_Show("PRIVATE_RL") end
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
					name = L['URL Links'],
					desc = L['Attempt to create URL links inside the chat.'],
				},
				shortChannels = {
					order = 2,
					type = 'toggle',
					name = L['Short Channels'],
					desc = L['Shorten the channel names in chat.'],
				},		
				hyperlinkHover = {
					order = 3,
					type = 'toggle',
					name = L['Hyperlink Hover'],
					desc = L['Display the hyperlink tooltip while hovering over a hyperlink.'],
					set = function(info, value) 
						E.db.chat[ info[#info] ] = value 
						if value == true then
							CH:EnableHyperlink()
						else
							CH:DisableHyperlink()
						end
					end,
				},
				throttleInterval = {
					order = 4,
					type = 'range',
					name = L['Spam Interval'],
					desc = L['Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable.'],
					min = 0, max = 120, step = 1,
					set = function(info, value) 
						E.db.chat[ info[#info] ] = value 
						if value ~= 0 then
							CH:EnableChatThrottle()
						else
							CH:DisableChatThrottle()
						end
					end,					
				},
				scrollDownInterval = {
					order = 5,
					type = 'range',
					name = L['Scroll Interval'],
					desc = L['Number of time in seconds to scroll down to the bottom of the chat window if you are not scrolled down completely.'],
					min = 0, max = 120, step = 5,
					set = function(info, value) 
						E.db.chat[ info[#info] ] = value 
					end,					
				},		
				sticky = {
					order = 6,
					type = 'toggle',
					name = L['Sticky Chat'],
					desc = L['When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel.'],
					set = function(info, value)
						E.db.chat[ info[#info] ] = value 
					end,
				},
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 7,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
					set = function(info, value) E.db.chat[ info[#info] ] = value ; CH:SetupChat() end,
				},
				fontoutline = {
					order = 8,
					name = L["Font Outline"],
					desc = L["Set the font outline."],
					type = "select",
					values = {
						['NONE'] = L['None'],
						['OUTLINE'] = 'OUTLINE',
						['MONOCHROME'] = 'MONOCHROME',
						['THICKOUTLINE'] = 'THICKOUTLINE',
					},
					set = function(info, value) E.db.chat[ info[#info] ] = value; CH:SetupChat() end,
				},					
			},
		},
	},
}