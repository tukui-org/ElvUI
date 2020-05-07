local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local Layout = E:GetModule('Layout')
local Chat = E:GetModule('Chat')
local Minimap = E:GetModule('Minimap')

local datatexts = {}

local _G = _G
local tonumber = tonumber
local tostring = tostring
local format = format
local pairs = pairs
local type = type

local DTPanelOptions = {
	numPoints = {
		order = 1,
		type = 'range',
		name = L["Number of DataTexts"],
		min = 1, max = 20, step = 1,
	},
	growth = {
		order = 2,
		type = 'select',
		name = L["Growth"],
		values = {
			HORIZONTAL = 'HORIZONTAL',
			VERTICAL = 'VERTICAL'
		},
	},
	width = {
		order = 3,
		type = 'range',
		name = L["Width"],
		min = 24, max = E.screenwidth, step = 1,
	},
	height = {
		order = 4,
		type = 'range',
		name = L["Height"],
		min = 24, max = E.screenheight, step = 1,
	},
	backdrop = {
		order = 5,
		name = L["Backdrop"],
		type = "toggle",
	},
	panelTransparency = {
		order = 6,
		type = 'toggle',
		name = L["Panel Transparency"],
	},
	mouseover = {
		order = 7,
		name = L["Mouse Over"],
		desc = L["The frame is not shown unless you mouse over the frame."],
		type = "toggle",
	},
	border = {
		order = 8,
		name = L["Show Border"],
		type = "toggle",
	},
	strataAndLevel = {
		order = 9,
		type = "group",
		name = L["Strata and Level"],
		guiInline = true,
		args = {
			frameStrata = {
				order = 2,
				type = "select",
				name = L["Frame Strata"],
				values = {
					["BACKGROUND"] = "BACKGROUND",
					["LOW"] = "LOW",
					["MEDIUM"] = "MEDIUM",
					["HIGH"] = "HIGH",
					["DIALOG"] = "DIALOG",
					["TOOLTIP"] = "TOOLTIP",
				},
			},
			frameLevel = {
				order = 5,
				type = "range",
				name = L["Frame Level"],
				min = 2, max = 128, step = 1,
			},
		},
	},
	tooltip = {
		order = 10,
		type = "group",
		name = L["Tooltip"],
		guiInline = true,
		args = {
			tooltipAnchor = {
				order = 2,
				type = "select",
				name = L["Anchor"],
				values = {
					ANCHOR_TOP = L["ANCHOR_TOP"],
					ANCHOR_RIGHT = L["ANCHOR_RIGHT"],
					ANCHOR_BOTTOM = L["ANCHOR_BOTTOM"],
					ANCHOR_LEFT = L["ANCHOR_LEFT"],
					ANCHOR_TOPRIGHT = L["ANCHOR_TOPRIGHT"],
					ANCHOR_BOTTOMRIGHT = L["ANCHOR_BOTTOMRIGHT"],
					ANCHOR_TOPLEFT = L["ANCHOR_TOPLEFT"],
					ANCHOR_BOTTOMLEFT = L["ANCHOR_BOTTOMLEFT"],
					ANCHOR_CURSOR = L["ANCHOR_CURSOR"],
					ANCHOR_CURSOR_LEFT = L["ANCHOR_CURSOR_LEFT"],
					ANCHOR_CURSOR_RIGHT = L["ANCHOR_CURSOR_RIGHT"],
				},
			},
			tooltipXOffset = {
				order = 2,
				type = 'range',
				name = L["X-Offset"],
				min = -30, max = 30, step = 1,
			},
			tooltipYOffset = {
				order = 3,
				type = 'range',
				name = L["Y-Offset"],
				min = -30, max = 30, step = 1,
			},
		},
	},
	visibility = {
		type = 'input',
		order = 11,
		name = L["Visibility State"],
		desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] show;hide'"],
		width = 'full',
	},
}

local PanelLayoutOptions -- so PanelGroup_Create and PanelLayoutOptions can call each other locally
local function PanelGroup_Delete(panel)
	E.Options.args.datatexts.args.panels.args[panel] = nil
end

local function PanelGroup_Create(panel)
	E.Options.args.datatexts.args.panels.args[panel] = {
		type = 'group',
		name = panel,
		get = function(info) return E.db.datatexts.panels[panel][info[#info]] end,
		set = function(info, value)
			E.db.datatexts.panels[panel][info[#info]] = value
			DT:UpdateDTPanelAttributes(panel, E.global.datatexts.customPanels[panel])
		end,
		args = {
			enable = {
				order = 0,
				type = 'toggle',
				name = L['Enable'],
			},
			panelOptions = {
				order = -1,
				name = L["Panel Options"],
				type = 'group',
				guiInline = true,
				get = function(info) return E.global.datatexts.customPanels[panel][info[#info]] end,
				set = function(info, value)
					E.global.datatexts.customPanels[panel][info[#info]] = value
					DT:UpdateDTPanelAttributes(panel, E.global.datatexts.customPanels[panel])
				end,
				args = {
					delete = {
						order = -1,
						type = 'execute',
						name = L['Delete'],
						width = 'full',
						confirm = true,
						func = function(info)
							E.db.datatexts.panels[panel] = nil
							E.global.datatexts.customPanels[panel] = nil
							DT:ReleasePanel(panel)
							PanelGroup_Delete(panel)
							PanelLayoutOptions()
							E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'datatexts', 'panels', 'newPanel')
						end,
					},
				},
			}
		},
	}

	E:CopyTable(E.Options.args.datatexts.args.panels.args[panel].args.panelOptions.args, DTPanelOptions)
	E.Options.args.datatexts.args.panels.args[panel].args.panelOptions.args.tooltip.args.tooltipYOffset.disabled = function() return E.global.datatexts.customPanels[panel].tooltipAnchor == 'ANCHOR_CURSOR' end
	E.Options.args.datatexts.args.panels.args[panel].args.panelOptions.args.tooltip.args.tooltipXOffset.disabled = function() return E.global.datatexts.customPanels[panel].tooltipAnchor == 'ANCHOR_CURSOR' end
end

PanelLayoutOptions = function()
	for name, data in pairs(DT.RegisteredDataTexts) do
		datatexts[name] = data.localizedName or L[name]
	end
	datatexts[''] = L["NONE"]

	local options = E.Options.args.datatexts.args.panels.args

	-- Custom Panels
	for panel in pairs(E.global.datatexts.customPanels) do
		PanelGroup_Create(panel)
	end

	-- This will mixin the options for the Custom Panels.
	for name, tab in pairs(DT.db.panels) do
		if type(tab) == 'table' then
			options[name] = options[name] or {
				type = 'group',
				args = {},
				name = L[name] or name,
				get = function(info) return E.db.datatexts.panels[name][info[#info]] end,
				set = function(info, value)
					E.db.datatexts.panels[name][info[#info]] = value
					DT:UpdateDTPanelAttributes(name, E.global.datatexts.customPanels[name])
				end,
			}

			for option, value in pairs(tab) do
				if type(option) == 'number' then
					options[name].args[tostring(option)] = {
						type = 'select',
						order = option,
						name = L[format("Position %d", option)],
						values = datatexts,
						get = function(info) return E.db.datatexts.panels[name][tonumber(info[#info])] end,
						set = function(info, value)
							E.db.datatexts.panels[name][tonumber(info[#info])] = value
							DT:UpdateDTPanelAttributes(name, E.global.datatexts.customPanels[name])
						end,
					}
				elseif type(value) ~= 'boolean' then
					options[name].args[option] = {
						type = 'select',
						name = L[option],
						values = datatexts,
					}
				end
			end
		elseif type(tab) == 'string' then
			options.smallPanels.args[name] = {
				type = 'select',
				name = L[name] or name,
				values = datatexts,
				get = function(info) return E.db.datatexts.panels[name] end,
				set = function(info, value)
					E.db.datatexts.panels[name] = value
					DT:UpdateDTPanelAttributes(name, E.global.datatexts.customPanels[name])
				end,
			}
		end
	end
end

local function CreateCustomCurrencyOptions(currencyID)
	local currency = E.global.datatexts.customCurrencies[currencyID] --The datatext has been registered prior to this
	if currency then
		E.Options.args.datatexts.args.customCurrency.args.currencies.args[currency.NAME] = {
			order = 1,
			type = "group",
			name = currency.NAME,
			guiInline = false,
			args = {
				removeDT = {
					order = 1,
					type = "execute",
					name = L["DELETE"],
					func = function()
						--Remove stored entries of this currency datatext
						DT:RemoveCustomCurrency(currency.NAME)
						--Remove options group
						E.Options.args.datatexts.args.customCurrency.args.currencies.args[currency.NAME] = nil
						--Remove entry from registered datatext storage
						DT.RegisteredDataTexts[currency.NAME] = nil
						--Remove from persistent storage
						E.global.datatexts.customCurrencies[currencyID] = nil
						--Remove currency from datatext selection
						datatexts[currency.NAME] = nil

						PanelLayoutOptions()

						--Reload datatexts to clear panel
						DT:LoadDataTexts()
					end,
				},
				displayStyle = {
					order = 3,
					type = "select",
					name = L["Display Style"],
					get = function(info) return E.global.datatexts.customCurrencies[currencyID].DISPLAY_STYLE end,
					set = function(info, value)
						--Save new display style
						E.global.datatexts.customCurrencies[currencyID].DISPLAY_STYLE = value
						--Update internal value
						DT:UpdateCustomCurrencySettings(currency.NAME, "DISPLAY_STYLE", value)
						--Reload datatexts
						DT:LoadDataTexts()
					end,
					values = {
						["ICON"] = L["Icons Only"],
						["ICON_TEXT"] = L["Icons and Text"],
						["ICON_TEXT_ABBR"] = L["Icons and Text (Short)"],
					},
				},
				showMax = {
					order = 4,
					type = "toggle",
					name = L["Current / Max"],
					get = function(info) return E.global.datatexts.customCurrencies[currencyID].SHOW_MAX end,
					set = function(info, value)
						--Save new value
						E.global.datatexts.customCurrencies[currencyID].SHOW_MAX = value
						--Update internal value
						DT:UpdateCustomCurrencySettings(currency.NAME, "SHOW_MAX", value)
						--Reload datatexts
						DT:LoadDataTexts()
					end,
				},
				useTooltip = {
					order = 5,
					type = "toggle",
					name = L["Use Tooltip"],
					get = function(info) return E.global.datatexts.customCurrencies[currencyID].USE_TOOLTIP end,
					set = function(info, value)
						--Save new value
						E.global.datatexts.customCurrencies[currencyID].USE_TOOLTIP = value
						--Update internal value
						DT:UpdateCustomCurrencySettings(currency.NAME, "USE_TOOLTIP", value)
					end,
				},
				displayInMainTooltip = {
					order = 6,
					type = "toggle",
					name = L["Display In Main Tooltip"],
					desc = L["If enabled, then this currency will be displayed in the main Currencies datatext tooltip."],
					get = function(info) return E.global.datatexts.customCurrencies[currencyID].DISPLAY_IN_MAIN_TOOLTIP end,
					set = function(info, value)
						--Save new value
						E.global.datatexts.customCurrencies[currencyID].DISPLAY_IN_MAIN_TOOLTIP = value
						--Update internal value
						DT:UpdateCustomCurrencySettings(currency.NAME, "DISPLAY_IN_MAIN_TOOLTIP", value)
					end,
				},
			},
		}
	end
end

local function SetupCustomCurrencies()
	--Create options for all stored custom currency datatexts
	for currencyID in pairs(E.global.datatexts.customCurrencies) do
		CreateCustomCurrencyOptions(currencyID)
	end
end

local clientTable = {
	['WoW'] = "WoW",
	['D3'] = "D3",
	['WTCG'] = "HS", --Hearthstone
	['Hero'] = "HotS", --Heros of the Storm
	['Pro'] = "OW", --Overwatch
	['S1'] = "SC",
	['S2'] = "SC2",
	['DST2'] = "Dst2",
	['VIPR'] = "VIPR", -- COD
	['BSAp'] = L["Mobile"],
	['App'] = "App", --Launcher
}

local function SetupFriendClient(client, order)
	local hideGroup = E.Options.args.datatexts.args.friends.args.hideGroup.args
	if not (hideGroup and client and order) then return end --safety
	local clientName = 'hide'..client
	hideGroup[clientName] = {
		order = order,
		type = 'toggle',
		name = clientTable[client] or client,
		get = function(info) return E.db.datatexts.friends[clientName] or false end,
		set = function(info, value) E.db.datatexts.friends[clientName] = value; DT:LoadDataTexts() end,
	}
end

local function SetupFriendClients() --this function is used to create the client options in order
	SetupFriendClient('App', 3)
	SetupFriendClient('BSAp', 4)
	SetupFriendClient('WoW', 5)
	SetupFriendClient('D3', 6)
	SetupFriendClient('WTCG', 7)
	SetupFriendClient('Hero', 8)
	SetupFriendClient('Pro', 9)
	SetupFriendClient('S1', 10)
	SetupFriendClient('S2', 11)
	SetupFriendClient('DST2', 12)
	SetupFriendClient('VIPR', 13)
end

E.Options.args.datatexts = {
	type = "group",
	name = L["DataTexts"],
	childGroups = "tab",
	order = 2,
	get = function(info) return E.db.datatexts[info[#info]] end,
	set = function(info, value) E.db.datatexts[info[#info]] = value; DT:LoadDataTexts() end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["DATATEXT_DESC"],
		},
		spacer = {
			order = 2,
			type = "description",
			name = "",
		},
		general = {
			order = 3,
			type = "group",
			name = L["General"],
			args = {
				generalGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["General"],
					args = {
						battleground = {
							order = 3,
							type = 'toggle',
							name = L["Battleground Texts"],
							desc = L["When inside a battleground display personal scoreboard information on the main datatext bars."],
						},
						panelTransparency = {
							order = 4,
							name = L["Panel Transparency"],
							type = 'toggle',
							set = function(info, value)
								E.db.datatexts[info[#info]] = value
								Layout:SetDataPanelStyle()
							end,
						},
						panelBackdrop = {
							order = 5,
							name = L["Backdrop"],
							type = 'toggle',
							set = function(info, value)
								E.db.datatexts[info[#info]] = value
								Layout:SetDataPanelStyle()
							end,
						},
						noCombatClick = {
							order = 6,
							type = "toggle",
							name = L["Block Combat Click"],
							desc = L["Blocks all click events while in combat."],
						},
						noCombatHover = {
							order = 7,
							type = "toggle",
							name = L["Block Combat Hover"],
							desc = L["Blocks datatext tooltip from showing in combat."],
						},
					},
				},
				fontGroup = {
					order = 3,
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
							name = L["FONT_SIZE"],
							type = "range",
							min = 4, max = 212, step = 1,
						},
						fontOutline = {
							order = 3,
							name = L["Font Outline"],
							desc = L["Set the font outline."],
							type = "select",
							values = C.Values.FontFlags,
						},
						wordWrap = {
							order = 4,
							type = "toggle",
							name = L["Word Wrap"],
						},
					},
				},
				currencies = {
					order = 4,
					type = "group",
					guiInline = true,
					name = L["CURRENCY"],
					args = {
						displayedCurrency = {
							order = 2,
							type = "select",
							name = L["Displayed Currency"],
							get = function(info) return E.db.datatexts.currencies.displayedCurrency end,
							set = function(info, value) E.db.datatexts.currencies.displayedCurrency = value; DT:LoadDataTexts() end,
							values = DT.CurrencyList,
						},
						displayStyle = {
							order = 3,
							type = "select",
							name = L["Currency Format"],
							get = function(info) return E.db.datatexts.currencies.displayStyle end,
							set = function(info, value) E.db.datatexts.currencies.displayStyle = value; DT:LoadDataTexts() end,
							hidden = function() return (E.db.datatexts.currencies.displayedCurrency == "GOLD") end,
							values = {
								["ICON"] = L["Icons Only"],
								["ICON_TEXT"] = L["Icons and Text"],
								["ICON_TEXT_ABBR"] = L["Icons and Text (Short)"],
							},
						},
						goldFormat = {
							order = 3,
							type = 'select',
							name = L["Gold Format"],
							desc = L["The display format of the money text that is shown in the gold datatext and its tooltip."],
							hidden = function() return (E.db.datatexts.currencies.displayedCurrency ~= "GOLD") end,
							values = {
								['SMART'] = L["Smart"],
								['FULL'] = L["Full"],
								['SHORT'] = L["SHORT"],
								['SHORTINT'] = L["Short (Whole Numbers)"],
								['CONDENSED'] = L["Condensed"],
								['BLIZZARD'] = L["Blizzard Style"],
								['BLIZZARD2'] = L["Blizzard Style"].." 2",
							},
						},
						goldCoins = {
							order = 4,
							type = 'toggle',
							name = L["Show Coins"],
							desc = L["Use coin icons instead of colored text."],
							hidden = function() return (E.db.datatexts.currencies.displayedCurrency ~= "GOLD") end,
						},
					},
				},
				time = {
					order = 6,
					type = "group",
					name = L["Time"],
					guiInline = true,
					args = {
						time24 = {
							order = 2,
							type = 'toggle',
							name = L["24-Hour Time"],
							desc = L["Toggle 24-hour mode for the time datatext."],
							get = function(info) return E.db.datatexts.time24 end,
							set = function(info, value) E.db.datatexts.time24 = value; DT:LoadDataTexts() end,
						},
						localtime = {
							order = 3,
							type = 'toggle',
							name = L["Local Time"],
							desc = L["If not set to true then the server time will be displayed instead."],
							get = function(info) return E.db.datatexts.localtime end,
							set = function(info, value) E.db.datatexts.localtime = value; DT:LoadDataTexts() end,
						},
					},
				},
			},
		},
		panels = {
			type = 'group',
			name = L["Panels"],
			order = 4,
			args = {
				leftChatPanel = {
					order = 2,
					name = L["Datatext Panel (Left)"],
					desc = L["Display data panels below the chat, used for datatexts."],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						if E.db.LeftChatPanelFaded then
							E.db.LeftChatPanelFaded = true;
							_G.HideLeftChat()
						end
						Chat:UpdateAnchors()
						Layout:ToggleChatPanels()
					end,
				},
				rightChatPanel = {
					order = 3,
					name = L["Datatext Panel (Right)"],
					desc = L["Display data panels below the chat, used for datatexts."],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						if E.db.RightChatPanelFaded then
							E.db.RightChatPanelFaded = true;
							_G.HideRightChat()
						end
						Chat:UpdateAnchors()
						Layout:ToggleChatPanels()
					end,
				},
				minimapPanels = {
					order = 4,
					name = L["Minimap Panels"],
					desc = L["Display minimap panels below the minimap, used for datatexts."],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapTop = {
					order = 5,
					name = L["TopMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapTopLeft = {
					order = 6,
					name = L["TopLeftMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapTopRight = {
					order = 7,
					name = L["TopRightMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapBottom = {
					order = 8,
					name = L["BottomMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapBottomLeft = {
					order = 9,
					name = L["BottomLeftMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				minimapBottomRight = {
					order = 10,
					name = L["BottomRightMiniPanel"],
					type = 'toggle',
					set = function(info, value)
						E.db.datatexts[info[#info]] = value
						Minimap:UpdateSettings()
					end,
				},
				newPanel = {
					order = 0,
					type = 'group',
					name = L['New Panel'],
					get = function(info) return E.global.datatexts.newPanelInfo[info[#info]] end,
					set = function(info, value) E.global.datatexts.newPanelInfo[info[#info]] = value end,
					args = {
						name = {
							order = 0,
							type = 'input',
							width = 'full',
							name = L['Name'],
							--validate = function(_, value)
							--	return E.global.datatexts.customPanels[value] and L['Name Taken'] or true
							--end,
						},
						add = {
							order = 14,
							type = 'execute',
							name = L['Add'],
							width = 'full',
							hidden = function()
								return E.global.datatexts.newPanelInfo.name == ''
							end,
							func = function()
								local name = E.global.datatexts.newPanelInfo.name
								E.global.datatexts.customPanels[name] = E:CopyTable({}, E.global.datatexts.newPanelInfo)
								E.db.datatexts.panels[name] = { enable = true }

								for i = 1, E.global.datatexts.newPanelInfo.numPoints do
									E.db.datatexts.panels[name][i] = ''
								end

								PanelGroup_Create(name)
								DT:BuildPanelFrame(name, E.global.datatexts.customPanels[name])
								PanelLayoutOptions()

								E.Libs.AceConfigDialog:SelectGroup('ElvUI', 'datatexts', 'panels', name)
								E.global.datatexts.newPanelInfo = E:CopyTable({}, G.datatexts.newPanelInfo)
							end,
						},
					},
				},
				smallPanels = {
					type = "group",
					name = L["Small Panels"],
					order = 1,
					args = {},
				},
				LeftChatDataPanel = {
					type = "group",
					name = L["LeftChatDataPanel"],
					order = 2,
					args = {},
				},
				RightChatDataPanel = {
					type = "group",
					name = L["RightChatDataPanel"],
					order = 3,
					args = {},
				},
			},
		},
		friends = {
			order = 7,
			type = "group",
			name = L["FRIENDS"],
			args = {
				description = {
					order = 1,
					type = "description",
					name = L["Hide specific sections in the datatext tooltip."],
				},
				hideGroup = {
					order = 2,
					type = "group",
					guiInline = true,
					name = L["HIDE"],
					args = {
						hideAFK = {
							order = 1,
							type = 'toggle',
							name = L["AFK"],
							get = function(info) return E.db.datatexts.friends.hideAFK end,
							set = function(info, value) E.db.datatexts.friends.hideAFK = value; DT:LoadDataTexts() end,
						},
						hideDND = {
							order = 2,
							type = 'toggle',
							name = L["DND"],
							get = function(info) return E.db.datatexts.friends.hideDND end,
							set = function(info, value) E.db.datatexts.friends.hideDND = value; DT:LoadDataTexts() end,
						},
					},
				},
			},
		},
		customCurrency = {
			order = 8,
			type = "group",
			name = L["Custom Currency"],
			args = {
				description = {
					order = 2,
					type = "description",
					name = L["This allows you to create a new datatext which will track the currency with the supplied currency ID. The datatext can be added to a panel immediately after creation."],
				},
				addCustomCurrency = {
					order = 3,
					type = "input",
					name = L["Add Currency ID"],
					desc = "http://www.wowhead.com/currencies",
					get = function() return "" end,
					set = function(info, value)
						local currencyID = tonumber(value)
						if not currencyID then return; end
						--Register a new datatext where name is the name of the currency
						DT:RegisterCustomCurrencyDT(currencyID)
						--Create options for this datatext
						CreateCustomCurrencyOptions(currencyID)
						PanelLayoutOptions()
						--Reload datatexts in case the currency we just added was already selected on a panel
						DT:LoadDataTexts()
					end,
				},
				currencies = {
					order = 5,
					type = "group",
					name = L["Custom Currencies"],
					args = {}
				},
			},
		},
	},
}

E:CopyTable(E.Options.args.datatexts.args.panels.args.newPanel.args, DTPanelOptions)

PanelLayoutOptions()
SetupCustomCurrencies()
SetupFriendClients()
