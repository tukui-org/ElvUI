local E, L, DF = unpack(select(2, ...)); --Engine
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
			get = function(info) return E.db.chat.enable end,
			set = function(info, value) E.db.chat.enable = value; StaticPopup_Show("CONFIG_RL") end
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
			},
		},
		sounds = {
			order = 4,
			type = "group",
			name = L["Sounds"],
			guiInline = true,
			args = {
				whisperwarning = {
					order = 1,
					type = 'toggle',
					name = L['Whisper Warning'],
					desc = L['Plays a sound when you receive a whisper.'],
					set = function(info, value) E.db.chat.whisperwarning = value; StaticPopup_Show("CONFIG_RL") end,
				},
				whispersound = {
					order = 2,
					type = 'select', dialogControl = 'LSM30_Sound',
					name = L['Warning Sound'],
					desc = L['Choose what sound to play.'],
					disabled = function() return not E.db.chat.whisperwarning end,
					values = AceGUIWidgetLSMlists.sound,
					set = function(info, value) E.db.chat[ info[#info] ] = value; E:UpdateSounds(); end,
				},
			},
		},
	},
}