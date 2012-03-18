local E, L, P, G = unpack(select(2, ...)); --Import: Engine, Locales, ProfileDB, GlobalDB
local B = E:GetModule('Bags')

E.Options.args.bags = {
	type = 'group',
	name = L['Bags'],
	get = function(info) return E.db.bags[ info[#info] ] end,
	set = function(info, value) E.db.bags[ info[#info] ] = value end,
	disabled = function() return not E.global.bags.enable end,
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
			get = function(info) return E.global.bags.enable end,
			set = function(info, value) E.global.bags.enable = value; StaticPopup_Show("GLOBAL_RL") end
		},			
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			guiInline = true,
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
	},
}