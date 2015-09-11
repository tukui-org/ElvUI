local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local datatexts = {}

function DT:PanelLayoutOptions()
	for name, _ in pairs(DT.RegisteredDataTexts) do
		datatexts[name] = name
	end
	datatexts[''] = NONE

	local table = E.Options.args.datatexts.args.panels.args
	local i = 0
	for pointLoc, tab in pairs(P.datatexts.panels) do
		i = i + 1
		if not _G[pointLoc] then table[pointLoc] = nil; return; end
		if type(tab) == 'table' then
			table[pointLoc] = {
				type = 'group',
				args = {},
				name = L[pointLoc] or pointLoc,
				guiInline = true,
				order = i + -10,
			}
			for option, value in pairs(tab) do
				table[pointLoc].args[option] = {
					type = 'select',
					name = L[option] or option:upper(),
					values = datatexts,
					get = function(info) return E.db.datatexts.panels[pointLoc][ info[#info] ] end,
					set = function(info, value) E.db.datatexts.panels[pointLoc][ info[#info] ] = value; DT:LoadDataTexts() end,
				}
			end
		elseif type(tab) == 'string' then
			table[pointLoc] = {
				type = 'select',
				name = L[pointLoc] or pointLoc,
				values = datatexts,
				get = function(info) return E.db.datatexts.panels[pointLoc] end,
				set = function(info, value) E.db.datatexts.panels[pointLoc] = value; DT:LoadDataTexts() end,
			}
		end
	end
end

E.Options.args.datatexts = {
	type = "group",
	name = L["DataTexts"],
	childGroups = "select",
	get = function(info) return E.db.datatexts[ info[#info] ] end,
	set = function(info, value) E.db.datatexts[ info[#info] ] = value; DT:LoadDataTexts() end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["DATATEXT_DESC"],
		},
		time24 = {
			order = 2,
			type = 'toggle',
			name = L["24-Hour Time"],
			desc = L["Toggle 24-hour mode for the time datatext."],
		},
		localtime = {
			order = 3,
			type = 'toggle',
			name = L["Local Time"],
			desc = L["If not set to true then the server time will be displayed instead."],
		},
		battleground = {
			order = 4,
			type = 'toggle',
			name = L["Battleground Texts"],
			desc = L["When inside a battleground display personal scoreboard information on the main datatext bars."],
		},
		minimapPanels = {
			order = 5,
			name = L["Minimap Panels"],
			desc = L["Display minimap panels below the minimap, used for datatexts."],
			type = 'toggle',
			set = function(info, value)
				E.db.datatexts[ info[#info] ] = value
				E:GetModule('Minimap'):UpdateSettings()
			end,
		},
		leftChatPanel = {
			order = 6,
			name = L["Datatext Panel (Left)"],
			desc = L["Display data panels below the chat, used for datatexts."],
			type = 'toggle',
			set = function(info, value)
				E.db.datatexts[ info[#info] ] = value
				if E.db.LeftChatPanelFaded then
					E.db.LeftChatPanelFaded = true;
					HideLeftChat()
				end
				E:GetModule('Chat'):UpdateAnchors()
				E:GetModule('Layout'):ToggleChatPanels()
				E:GetModule('Bags'):PositionBagFrames()
			end,
		},
		rightChatPanel = {
			order = 7,
			name = L["Datatext Panel (Right)"],
			desc = L["Display data panels below the chat, used for datatexts."],
			type = 'toggle',
			set = function(info, value)
				E.db.datatexts[ info[#info] ] = value
				if E.db.RightChatPanelFaded then
					E.db.RightChatPanelFaded = true;
					HideRightChat()
				end
				E:GetModule('Chat'):UpdateAnchors()
				E:GetModule('Layout'):ToggleChatPanels()
				E:GetModule('Bags'):PositionBagFrames()
			end,
		},
		panelTransparency = {
			order = 8,
			name = L["Panel Transparency"],
			type = 'toggle',
			set = function(info, value)
				E.db.datatexts[ info[#info] ] = value
				E:GetModule('Layout'):SetDataPanelStyle()
			end,
		},
		goldFormat = {
			order = 9,
			type = 'select',
			name = L["Gold Format"],
			desc = L["The display format of the money text that is shown in the gold datatext and its tooltip."],
			values = {
				['SMART'] = L["Smart"],
				['FULL'] = L["Full"],
				['SHORT'] = L["Short"],
				['SHORTINT'] = L["Short (Whole Numbers)"],
				['CONDENSED'] = L["Condensed"],
				['BLIZZARD'] = L["Blizzard Style"],
			},
		},
		goldCoins = {
			order = 10,
			type = 'toggle',
			name = L["Show Coins"],
			desc = L["Use coin icons instead of colored text."],
		},
		noCombatClick = {
			order = 11,
			type = "toggle",
			name = L["Block Combat Click"],
			desc = L["Blocks all click events while in combat."],
		},
		noCombatHover = {
			order = 12,
			type = "toggle",
			name = L["Block Combat Hover"],
			desc = L["Blocks datatext tooltip from showing in combat."],
		},
		panels = {
			type = 'group',
			name = L["Panels"],
			order = 100,
			args = {},
			guiInline = true,
		},
		fontGroup = {
			order = 120,
			type = 'group',
			guiInline = true,
			name = L["Fonts"],
			args = {
				font = {
					type = "select", dialogControl = 'LSM30_Font',
					order = 1,
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
				},
				fontSize = {
					order = 2,
					name = L["Font Size"],
					type = "range",
					min = 4, max = 22, step = 1,
				},
				fontOutline = {
					order = 3,
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
				wordWrap = {
					order = 4,
					type = "toggle",
					name = L["Word Wrap"],
				},
			},
		},
	},
}

DT:PanelLayoutOptions()