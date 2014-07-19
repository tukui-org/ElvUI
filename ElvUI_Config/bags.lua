local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, ProfileDB, GlobalDB
local B = E:GetModule('Bags')

E.Options.args.bags = {
	type = 'group',
	name = L['Bags'],
	get = function(info) return E.db.bags[ info[#info] ] end,
	set = function(info, value) E.db.bags[ info[#info] ] = value end,
	args = {
		intro = {
			order = 1,
			type = 'description',
			name = L['BAGS_DESC'],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			desc = L['Enable/Disable the all-in-one bag.'],
			get = function(info) return E.private.bags.enable end,
			set = function(info, value) E.private.bags.enable = value; E:StaticPopup_Show("PRIVATE_RL") end
		},			
		general = {
			order = 4,
			type = "group",
			name = L["General"],
			guiInline = true,
			disabled = function() return not E.bags end,
			args = {			
				bagSize = {
					order = 1,
					type = 'range',
					name = L['Button Size (Bag)'],
					desc = L['The size of the individual buttons on the bag frame.'],
					min = 15, max = 45, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout(); end,
				},
				bankSize = {
					order = 2,
					type = 'range',
					name = L['Button Size (Bank)'],
					desc = L['The size of the individual buttons on the bank frame.'],
					min = 15, max = 45, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout(true) end,
				},				
				sortInverted = {
					order = 3,
					type = 'toggle',
					name = L['Sort Inverted'],
					desc = L['Direction the bag sorting will use to allocate the items.'],
				},
				alignToChat = {
					order = 4,
					type = 'toggle',
					name = L['Align To Chat'],
					desc = L['Align the width of the bag frame to fit inside the chat box.'],
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout(); B:Layout(true) end,
				},						
				bagWidth = {
					order = 5,
					type = 'range',
					name = L['Panel Width (Bags)'],
					desc = L['Adjust the width of the bag frame.'],
					min = 150, max = 700, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout();end,
					disabled = function() return E.db.bags.alignToChat end
				},
				bankWidth = {
					order = 6,
					type = 'range',
					name = L['Panel Width (Bank)'],
					desc = L['Adjust the width of the bank frame.'],
					min = 150, max = 700, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout(true) end,
					disabled = function() return E.db.bags.alignToChat end
				},				
				xOffset = {
					order = 7,
					type = 'range',
					name = L["X Offset"],
					min = -5, max = 600, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:PositionBagFrames(); end,				
				},				
				yOffset = {
					order = 8,
					type = 'range',
					name = L["Y Offset"],
					min = 0, max = 600, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:PositionBagFrames(); end,				
				},
				currencyFormat = {
					order = 9,
					type = 'select',
					name = L['Currency Format'],
					desc = L['The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)'],
					values = {
						['ICON'] = L["Icons Only"],
						['ICON_TEXT'] = L["Icons and Text"],
					},
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:UpdateTokens(); end,
				},
				ignoreItems = {
					order = 100,
					name = L['Ignore Items'],
					desc = L['List of items to ignore when sorting. If you wish to add multiple items you must seperate the word with a comma.'],
					type = 'input',
					width = 'full',
					multiline = true,
					set = function(info, value) E.db.bags[ info[#info] ] = value; end,
				},						
			},
		},
		bagBar = {
			order = 5,
			type = "group",
			name = L["Bag-Bar"],
			guiInline = true,
			get = function(info) return E.db.bags.bagBar[ info[#info] ] end,
			set = function(info, value) E.db.bags.bagBar[ info[#info] ] = value; B:SizeAndPositionBagBar() end,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L['Enable/Disable the Bag-Bar.'],
					get = function(info) return E.private.bags.bagBar end,
					set = function(info, value) E.private.bags.bagBar = value; E:StaticPopup_Show("PRIVATE_RL") end			
				},					
				size = {
					order = 2,
					type = 'range',
					name = L["Button Size"],
					desc = L['Set the size of your bag buttons.'],
					min = 24, max = 60, step = 1,
				},
				spacing = {
					order = 3,
					type = 'range',
					name = L['Button Spacing'],
					desc = L['The spacing between buttons.'],
					min = 1, max = 10, step = 1,			
				},
				showBackdrop = {
					order = 4,
					type = 'toggle',
					name = L['Backdrop'],
				},
				mouseover = {
					order = 5,
					name = L['Mouse Over'],
					desc = L['The frame is not shown unless you mouse over the frame.'],
					type = "toggle",
				},
				sortDirection = {
					order = 6,
					type = 'select',
					name = L["Sort Direction"],
					desc = L['The direction that the bag frames will grow from the anchor.'],
					values = {
						['ASCENDING'] = L['Ascending'],
						['DESCENDING'] = L['Descending'],
					},
				},
				growthDirection = {
					order = 7,
					type = 'select',
					name = L['Bar Direction'],
					desc = L['The direction that the bag frames be (Horizontal or Vertical).'],
					values = {
						['VERTICAL'] = L['Vertical'],
						['HORIZONTAL'] = L['Horizontal'],
					},
				},				
			},
		},			
	},
}