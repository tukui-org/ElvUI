local E, L, V, P, G, _ = unpack(ElvUI); --Import: Engine, Locales, ProfileDB, GlobalDB
local B = E:GetModule('Bags')

E.Options.args.bags = {
	type = 'group',
	name = L["Bags"],
	childGroups = "tab",
	get = function(info) return E.db.bags[ info[#info] ] end,
	set = function(info, value) E.db.bags[ info[#info] ] = value end,
	args = {
		intro = {
			order = 1,
			type = 'description',
			name = L["BAGS_DESC"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["Enable"],
			desc = L["Enable/Disable the all-in-one bag."],
			get = function(info) return E.private.bags.enable end,
			set = function(info, value) E.private.bags.enable = value; E:StaticPopup_Show("PRIVATE_RL") end
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			disabled = function() return not E.bags end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["General"],
				},
				currencyFormat = {
					order = 1,
					type = 'select',
					name = L["Currency Format"],
					desc = L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"],
					values = {
						['ICON'] = L["Icons Only"],
						['ICON_TEXT'] = L["Icons and Text"],
						["ICON_TEXT_ABBR"] = L["Icons and Text (Short)"],
					},
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:UpdateTokens(); end,
				},
				moneyFormat = {
					order = 2,
					type = 'select',
					name = L["Money Format"],
					desc = L["The display format of the money text that is shown at the top of the main bag."],
					values = {
						['SMART'] = L["Smart"],
						['FULL'] = L["Full"],
						['SHORT'] = L["Short"],
						['SHORTINT'] = L["Short (Whole Numbers)"],
						['CONDENSED'] = L["Condensed"],
						['BLIZZARD'] = L["Blizzard Style"],
					},
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:UpdateGoldText(); end,
				},
				moneyCoins = {
					order = 3,
					type = 'toggle',
					name = L["Show Coins"],
					desc = L["Use coin icons instead of colored text."],
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:UpdateGoldText(); end,
				},
				junkIcon = {
					order = 4,
					type = 'toggle',
					name = L["Show Junk Icon"],
					desc = L["Display the junk icon on all grey items that can be vendored."],
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:UpdateAllBagSlots(); end,
				},
				upgradeIcon = {
					order = 5,
					type = 'toggle',
					name = L["Show Upgrade Icon"],
					desc = L["Display the upgrade icon on items that WoW considers an upgrade for your character."],
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:UpdateAllBagSlots(); end,
				},
				clearSearchOnClose = {
					order = 6,
					type = 'toggle',
					name = L["Clear Search On Close"],
					set = function(info, value) E.db.bags[info[#info]] = value; end
				},
				reverseLoot = {
					order = 7,
					type = "toggle",
					name = REVERSE_NEW_LOOT_TEXT,
					set = function(info, value)
						E.db.bags.reverseLoot = value;
						SetInsertItemsLeftToRight(value)
					end,
				},
				disableBagSort = {
					order = 8,
					type = "toggle",
					name = L["Disable Bag Sort"],
					set = function(info, value) E.db.bags[info[#info]] = value; B:ToggleSortButtonState(false); end
				},
				disableBankSort = {
					order = 9,
					type = "toggle",
					name = L["Disable Bank Sort"],
					set = function(info, value) E.db.bags[info[#info]] = value; B:ToggleSortButtonState(true); end
				},
				countGroup = {
					order = 10,
					type = "group",
					name = L["Item Count Font"],
					guiInline = true,
					args = {
						countFont = {
							order = 1,
							type = "select",
							dialogControl = 'LSM30_Font',
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.bags.countFont = value; B:UpdateCountDisplay() end,
						},
						countFontColor = {
							order = 2,
							type = 'color',
							name = L["Color"],
							get = function(info)
								local t = E.db.bags[ info[#info] ]
								local d = P.bags[info[#info]]
								return t.r, t.g, t.b, t.a, d.r, d.g, d.b
							end,
							set = function(info, r, g, b)
								E.db.bags[ info[#info] ] = {}
								local t = E.db.bags[ info[#info] ]
								t.r, t.g, t.b = r, g, b
								B:UpdateCountDisplay()
							end,
						},
						countFontSize = {
							order = 3,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 212, step = 1,
							set = function(info, value) E.db.bags.countFontSize = value; B:UpdateCountDisplay() end,
						},
						countFontOutline = {
							order = 4,
							type = "select",
							name = L["Font Outline"],
							set = function(info, value) E.db.bags.countFontOutline = value; B:UpdateCountDisplay() end,
							values = {
								['NONE'] = L["None"],
								['OUTLINE'] = 'OUTLINE',
								['MONOCHROMEOUTLINE'] = 'MONOCROMEOUTLINE',
								['THICKOUTLINE'] = 'THICKOUTLINE',
							},
						},
					},
				},
				itemLevelGroup = {
					order = 11,
					type = "group",
					name = L["Item Level"],
					guiInline = true,
					args = {
						itemLevel = {
							order = 1,
							type = 'toggle',
							name = L["Display Item Level"],
							desc = L["Displays item level on equippable items."],
							set = function(info, value) E.db.bags.itemLevel = value; B:UpdateItemLevelDisplay() end,
						},
						itemLevelThreshold = {
							order = 2,
							name = L["Item Level Threshold"],
							desc = L["The minimum item level required for it to be shown."],
							type = 'range',
							min = 1, max = 1000, step = 1,
							disabled = function() return not E.db.bags.itemLevel end,
							set = function(info, value) E.db.bags.itemLevelThreshold = value; B:UpdateItemLevelDisplay() end,
						},
						itemLevelFont = {
							order = 3,
							type = "select",
							dialogControl = 'LSM30_Font',
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							disabled = function() return not E.db.bags.itemLevel end,
							set = function(info, value) E.db.bags.itemLevelFont = value; B:UpdateItemLevelDisplay() end,
						},
						itemLevelFontSize = {
							order = 4,
							type = "range",
							name = L["Font Size"],
							min = 4, max = 212, step = 1,
							disabled = function() return not E.db.bags.itemLevel end,
							set = function(info, value) E.db.bags.itemLevelFontSize = value; B:UpdateItemLevelDisplay() end,
						},
						itemLevelFontOutline = {
							order = 5,
							type = "select",
							name = L["Font Outline"],
							disabled = function() return not E.db.bags.itemLevel end,
							set = function(info, value) E.db.bags.itemLevelFontOutline = value; B:UpdateItemLevelDisplay() end,
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
		},
		sizeGroup = {
			order = 4,
			type = "group",
			name = L["Size"],
			disabled = function() return not E.bags end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Size"],
				},
				bagSize = {
					order = 2,
					type = 'range',
					name = L["Button Size (Bag)"],
					desc = L["The size of the individual buttons on the bag frame."],
					min = 15, max = 45, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout(); end,
				},
				bankSize = {
					order = 3,
					type = 'range',
					name = L["Button Size (Bank)"],
					desc = L["The size of the individual buttons on the bank frame."],
					min = 15, max = 45, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout(true) end,
				},
				bagWidth = {
					order = 4,
					type = 'range',
					name = L["Panel Width (Bags)"],
					desc = L["Adjust the width of the bag frame."],
					min = 150, max = 1400, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout();end,
				},
				bankWidth = {
					order = 5,
					type = 'range',
					name = L["Panel Width (Bank)"],
					desc = L["Adjust the width of the bank frame."],
					min = 150, max = 1400, step = 1,
					set = function(info, value) E.db.bags[ info[#info] ] = value; B:Layout(true) end,
				},
			},
		},
		bagBar = {
			order = 5,
			type = "group",
			name = L["Bag-Bar"],
			get = function(info) return E.db.bags.bagBar[ info[#info] ] end,
			set = function(info, value) E.db.bags.bagBar[ info[#info] ] = value; B:SizeAndPositionBagBar() end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Bag-Bar"],
				},
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable/Disable the Bag-Bar."],
					get = function(info) return E.private.bags.bagBar end,
					set = function(info, value) E.private.bags.bagBar = value; E:StaticPopup_Show("PRIVATE_RL") end
				},
				showBackdrop = {
					order = 2,
					type = 'toggle',
					name = L["Backdrop"],
				},
				mouseover = {
					order = 3,
					name = L["Mouse Over"],
					desc = L["The frame is not shown unless you mouse over the frame."],
					type = "toggle",
				},
				size = {
					order = 4,
					type = 'range',
					name = L["Button Size"],
					desc = L["Set the size of your bag buttons."],
					min = 24, max = 60, step = 1,
				},
				spacing = {
					order = 5,
					type = 'range',
					name = L["Button Spacing"],
					desc = L["The spacing between buttons."],
					min = 1, max = 10, step = 1,
				},
				backdropSpacing = {
					order = 6,
					type = 'range',
					name = L["Backdrop Spacing"],
					desc = L["The spacing between the backdrop and the buttons."],
					min = 0, max = 10, step = 1,
					disabled = function() return not E.private.actionbar.enable end,
				},
				sortDirection = {
					order = 7,
					type = 'select',
					name = L["Sort Direction"],
					desc = L["The direction that the bag frames will grow from the anchor."],
					values = {
						['ASCENDING'] = L["Ascending"],
						['DESCENDING'] = L["Descending"],
					},
				},
				growthDirection = {
					order = 7,
					type = 'select',
					name = L["Bar Direction"],
					desc = L["The direction that the bag frames be (Horizontal or Vertical)."],
					values = {
						['VERTICAL'] = L["Vertical"],
						['HORIZONTAL'] = L["Horizontal"],
					},
				},
			},
		},
		bagSortingGroup = {
			order = 6,
			type = "group",
			name = L["Bag Sorting"],
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Bag Sorting"],
				},
				sortInverted = {
					order = 1,
					type = 'toggle',
					name = L["Sort Inverted"],
					desc = L["Direction the bag sorting will use to allocate the items."],
				},
				spacer = {
					order = 2,
					type = "description",
					name = " ",
				},
				description = {
					order = 3,
					type = "description",
					name = L["Here you can add items or search terms that you want to be excluded from sorting. To remove an item just click on its name in the list."],
				},
				addEntryGroup = {
					order = 4,
					type = "group",
					name = L["Add Item or Search Syntax"],
					guiInline = true,
					args = {
						addEntryProfile = {
							order = 1,
							name = L["Profile"],
							desc = L["Add an item or search syntax to the ignored list. Items matching the search syntax will be ignored."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if value == "" or string.gsub(value, "%s+", "") == "" then return; end --Don't allow empty entries

								--Store by itemID if possible
								local itemID = string.match(value, "item:(%d+)")
								E.db.bags.ignoredItems[(itemID or value)] = value
							end,
						},
						spacer = {
							order = 2,
							type = "description",
							name = " ",
							width = "normal",
						},
						addEntryGlobal = {
							order = 3,
							name = L["Global"],
							desc = L["Add an item or search syntax to the ignored list. Items matching the search syntax will be ignored."],
							type = 'input',
							get = function(info) return "" end,
							set = function(info, value)
								if value == "" or string.gsub(value, "%s+", "") == "" then return; end --Don't allow empty entries

								--Store by itemID if possible
								local itemID = string.match(value, "item:(%d+)")
								E.global.bags.ignoredItems[(itemID or value)] = value
								
								--Remove from profile list if we just added the same item to global list
								if E.db.bags.ignoredItems[(itemID or value)] then
									E.db.bags.ignoredItems[(itemID or value)] = nil
								end
							end,
						},
					},
				},
				ignoredEntriesProfile = {
					order = 5,
					type = "multiselect",
					name = L["Ignored Items and Search Syntax (Profile)"],
					values = function() return E.db.bags.ignoredItems end,
					get = function(info, value)	return E.db.bags.ignoredItems[value] end,
					set = function(info, value)
						E.db.bags.ignoredItems[value] = nil
						GameTooltip:Hide()--Make sure tooltip is properly hidden
					end,
				},
				ignoredEntriesGlobal = {
					order = 6,
					type = "multiselect",
					name = L["Ignored Items and Search Syntax (Global)"],
					values = function() return E.global.bags.ignoredItems end,
					get = function(info, value)	return E.global.bags.ignoredItems[value] end,
					set = function(info, value)
						E.global.bags.ignoredItems[value] = nil
						GameTooltip:Hide()--Make sure tooltip is properly hidden
					end,
				},
			},
		},
		search_syntax = {
			order = 7,
			type = "group",
			name = L["Search Syntax"],
			disabled = function() return not E.bags end,
			args = {
				header = {
					order = 0,
					type = "header",
					name = L["Search Syntax"],
				},
				text = {
					order = 1,
					type = "input",
					multiline = 26,
					width = "full",
					name = "",
					get = function(info) return L["SEARCH_SYNTAX_DESC"]; end,
					set = function(info, value) value = L["SEARCH_SYNTAX_DESC"]; end,
				},
			},
		},
	},
}