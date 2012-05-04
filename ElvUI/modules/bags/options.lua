local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, ProfileDB, GlobalDB
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
			set = function(info, value) E.private.bags.enable = value; StaticPopup_Show("PRIVATE_RL") end
		},	
		BagBarEnable = {
			order = 3,
			type = "toggle",
			name = L["Enable Bag-Bar"],
			desc = L['Enable/Disable the Bag-Bar.'],
			get = function(info) return E.private.bags.bagBar.enable end,
			set = function(info, value) E.private.bags.bagBar.enable = value; StaticPopup_Show("PRIVATE_RL") end,
			disabled = function() return E.bags end,
		},				
		general = {
			order = 4,
			type = "group",
			name = L["General"],
			guiInline = true,
			disabled = function() return not E.bags end,
			args = {			
				bagCols = {
					order = 1,
					type = 'range',
					name = L['Bag Columns'],
					desc = L['Number of columns (width) of bags. Set it to 0 to match the width of the chat panels.'],
					min = 0, max = 20, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout(); B:Layout(true) end,
				},
				bankCols = {
					order = 2,
					type = 'range',
					name = L['Bank Columns'],
					desc = L['Number of columns (width) of the bank. Set it to 0 to match the width of the chat panels.'],
					min = 0, max = 20, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout(); B:Layout(true) end,
				},
				sortOrientation = {
					order = 3,
					type = 'select',
					name = L['Sort Orientation'],
					desc = L['Direction the bag sorting will use to allocate the items.'],
					values = {
						['BOTTOM-TOP'] = L['Bottom to Top'],
						['TOP-BOTTOM'] = L['Top to Bottom'],
					},
				},
				xOffset = {
					order = 4,
					type = 'range',
					name = L["X Offset"],
					min = -5, max = 600, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:PositionBagFrames(); end,				
				},				
				yOffset = {
					order = 5,
					type = 'range',
					name = L["Y Offset"],
					min = 0, max = 600, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:PositionBagFrames(); end,				
				},
			},
		},
		bagBar = {
			order = 5,
			type = "group",
			name = L["Bag-Bar"],
			guiInline = true,
			disabled = function() return E.bags end,
			get = function(info) return E.db.bags.bagBar[ info[#info] ] end,
			set = function(info, value) E.db.bags.bagBar[ info[#info] ] = value; B:SizeAndPositionBagBar() end,
			args = {
				size = {
					order = 1,
					type = 'range',
					name = L["Button Size"],
					desc = L['Set the size of your bag buttons.'],
					min = 24, max = 60, step = 1,
				},
				spacing = {
					order = 2,
					type = 'range',
					name = L['Button Spacing'],
					desc = L['The spacing between buttons.'],
					min = 1, max = 10, step = 1,			
				},
				showBackdrop = {
					order = 3,
					type = 'toggle',
					name = L['Backdrop'],
				},
				mouseover = {
					order = 4,
					name = L['Mouse Over'],
					desc = L['The frame is not shown unless you mouse over the frame.'],
					type = "toggle",
				},
				sortDirection = {
					order = 5,
					type = 'select',
					name = L["Sort Direction"],
					desc = L['The direction that the bag frames be (Horizontal or Vertical).'],
					values = {
						['ASCENDING'] = L['Ascending'],
						['DESCENDING'] = L['Descending'],
					},
				},
				growthDirection = {
					order = 6,
					type = 'select',
					name = L['Bar Direction'],
					desc = L['The direction that the bag frames will grow from the anchor.'],
					values = {
						['VERTICAL'] = L['Vertical'],
						['HORIZONTAL'] = L['Horizontal'],
					},
				},
			},
		},
	},
}