--Contains preset profiles.. 
if(not ElvDB.profiles["Minimalistic"]) then
	ElvDB.profiles["Minimalistic"] = {
		["nameplate"] = {
			["debuffs"] = {
				["font"] = "Expressway",
			},
			["font"] = "Expressway",
			["buffs"] = {
				["font"] = "Expressway",
			},
		},
		["currentTutorial"] = 2,
		["general"] = {
			["reputation"] = {
				["orientation"] = "HORIZONTAL",
				["textFormat"] = "PERCENT",
				["height"] = 16,
				["width"] = 200,
			},
			["bordercolor"] = {
				["r"] = 0.30588235294118,
				["g"] = 0.30588235294118,
				["b"] = 0.30588235294118,
			},
			["font"] = "Expressway",
			["bottomPanel"] = false,
			["backdropfadecolor"] = {
				["a"] = 0.80000001192093,
				["r"] = 0.058823529411765,
				["g"] = 0.058823529411765,
				["b"] = 0.058823529411765,
			},
			["valuecolor"] = {
				["a"] = 1,
				["r"] = 1,
				["g"] = 1,
				["b"] = 1,
			},
			["fontSize"] = 11,
		},
		["movers"] = {
			["PetAB"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-50,-428",
			["ElvUF_RaidMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,51,120",
			["LeftChatMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,50,50",
			["GMMover"] = "TOPLEFT,ElvUIParent,TOPLEFT,250,-50",
			["BossButton"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-117,-298",
			["LootFrameMover"] = "TOPLEFT,ElvUIParent,TOPLEFT,249,-216",
			["ElvUF_RaidpetMover"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,50,827",
			["MicrobarMover"] = "TOPLEFT,ElvUIParent,TOPLEFT,4,-52",
			["VehicleSeatMover"] = "TOPLEFT,ElvUIParent,TOPLEFT,51,-87",
			["ElvUF_TargetTargetMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,143",
			["ElvUF_Raid40Mover"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,392,1073",
			["ElvAB_1"] = "BOTTOM,ElvUIParent,BOTTOM,0,50",
			["ElvAB_2"] = "BOTTOM,ElvUIParent,BOTTOM,0,90",
			["ElvAB_4"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-50,-394",
			["AltPowerBarMover"] = "TOP,ElvUIParent,TOP,0,-186",
			["ElvAB_3"] = "BOTTOM,ElvUIParent,BOTTOM,305,50",
			["ElvAB_5"] = "BOTTOM,ElvUIParent,BOTTOM,-305,50",
			["MinimapMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-50,-50",
			["ElvUF_TargetMover"] = "BOTTOM,ElvUIParent,BOTTOM,230,140",
			["ElvUF_PetMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,200",
			["ObjectiveFrameMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-122,-393",
			["BNETMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,50,232",
			["ShiftAB"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,50,1150",
			["ElvUF_PartyMover"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,184,773",
			["ElvUF_BodyGuardMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-651,-586",
			["ElvAB_6"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-488,330",
			["TooltipMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-50,50",
			["ElvUF_TankMover"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,50,995",
			["TotemBarMover"] = "BOTTOMLEFT,ElvUIParent,BOTTOMLEFT,463,50",
			["ElvUF_PlayerMover"] = "BOTTOM,ElvUIParent,BOTTOM,-230,140",
			["ElvUF_PlayerCastbarMover"] = "BOTTOM,ElvUIParent,BOTTOM,0,133",
			["RightChatMover"] = "BOTTOMRIGHT,ElvUIParent,BOTTOMRIGHT,-50,50",
			["AlertFrameMover"] = "TOP,ElvUIParent,TOP,0,-50",
			["ReputationBarMover"] = "TOPRIGHT,ElvUIParent,TOPRIGHT,-50,-228",
			["ElvUF_AssistMover"] = "TOPLEFT,ElvUIParent,BOTTOMLEFT,51,937",
		},
		["bossAuraFiltersConverted"] = true,
		["hideTutorial"] = true,
		["auras"] = {
			["font"] = "Expressway",
			["consolidatedBuffs"] = {
				["font"] = "Expressway",
			},
			["buffs"] = {
				["maxWraps"] = 2,
			},
			["fontSize"] = 11,
		},
		["bags"] = {
			["itemLevelFontSize"] = 9,
			["countFontSize"] = 9,
		},
		["unitframe"] = {
			["statusbar"] = "ElvUI Blank",
			["fontOutline"] = "THICKOUTLINE",
			["smoothbars"] = true,
			["font"] = "Expressway",
			["fontSize"] = 9,
			["units"] = {
				["tank"] = {
					["enable"] = false,
				},
				["bodyguard"] = {
					["enable"] = false,
				},
				["party"] = {
					["horizontalSpacing"] = 3,
					["debuffs"] = {
						["numrows"] = 4,
						["anchorPoint"] = "BOTTOM",
						["perrow"] = 1,
					},
					["enable"] = false,
					["rdebuffs"] = {
						["font"] = "Expressway",
					},
					["growthDirection"] = "RIGHT_DOWN",
					["roleIcon"] = {
						["position"] = "TOPRIGHT",
					},
					["power"] = {
						["text_format"] = "",
						["height"] = 5,
					},
					["healPrediction"] = true,
					["width"] = 110,
					["infoPanel"] = {
						["enable"] = true,
					},
					["health"] = {
						["attachTextTo"] = "InfoPanel",
						["orientation"] = "VERTICAL",
						["text_format"] = "[healthcolor][health:current]",
						["position"] = "RIGHT",
					},
					["name"] = {
						["attachTextTo"] = "InfoPanel",
						["text_format"] = "[namecolor][name:short]",
						["position"] = "LEFT",
					},
					["height"] = 59,
					["verticalSpacing"] = 0,
				},
				["raid40"] = {
					["enable"] = false,
					["rdebuffs"] = {
						["font"] = "Expressway",
					},
				},
				["focus"] = {
					["threatStyle"] = "NONE",
					["health"] = {
						["attachTextTo"] = "InfoPanel",
						["text_format"] = "[healthcolor][health:current]",
					},
					["width"] = 189,
					["infoPanel"] = {
						["height"] = 17,
						["enable"] = true,
					},
					["name"] = {
						["attachTextTo"] = "InfoPanel",
						["position"] = "LEFT",
					},
					["height"] = 56,
					["castbar"] = {
						["iconSize"] = 26,
						["width"] = 122,
					},
				},
				["target"] = {
					["debuffs"] = {
						["perrow"] = 7,
					},
					["power"] = {
						["attachTextTo"] = "InfoPanel",
						["height"] = 15,
						["hideonnpc"] = false,
						["text_format"] = "[powercolor][power:current-max]",
					},
					["castbar"] = {
						["iconSize"] = 54,
						["iconAttached"] = false,
					},
					["infoPanel"] = {
						["enable"] = true,
					},
					["name"] = {
						["attachTextTo"] = "InfoPanel",
						["text_format"] = "[namecolor][name]",
					},
					["smartAuraPosition"] = "DEBUFFS_ON_BUFFS",
					["height"] = 80,
					["buffs"] = {
						["perrow"] = 7,
					},
					["health"] = {
						["attachTextTo"] = "InfoPanel",
						["text_format"] = "[healthcolor][health:current-max]",
					},
				},
				["raid"] = {
					["debuffs"] = {
						["enable"] = true,
						["sizeOverride"] = 27,
						["perrow"] = 4,
					},
					["rdebuffs"] = {
						["enable"] = false,
						["font"] = "Expressway",
					},
					["growthDirection"] = "UP_RIGHT",
					["roleIcon"] = {
						["position"] = "RIGHT",
					},
					["width"] = 140,
					["groupsPerRowCol"] = 5,
					["health"] = {
						["yOffset"] = -6,
					},
					["name"] = {
						["position"] = "LEFT",
					},
					["height"] = 28,
					["visibility"] = "[nogroup] hide;show",
				},
				["player"] = {
					["debuffs"] = {
						["perrow"] = 7,
					},
					["power"] = {
						["attachTextTo"] = "InfoPanel",
						["text_format"] = "[powercolor][power:current-max]",
						["height"] = 15,
					},
					["combatfade"] = true,
					["castbar"] = {
						["iconAttached"] = false,
						["iconSize"] = 54,
						["height"] = 35,
						["width"] = 478,
					},
					["health"] = {
						["attachTextTo"] = "InfoPanel",
						["text_format"] = "[healthcolor][health:current-max]",
					},
					["name"] = {
						["attachTextTo"] = "InfoPanel",
						["text_format"] = "[namecolor][name]",
					},
					["infoPanel"] = {
						["enable"] = true,
					},
					["height"] = 80,
					["classbar"] = {
						["height"] = 15,
						["autoHide"] = true,
					},
				},
				["targettarget"] = {
					["debuffs"] = {
						["enable"] = false,
					},
					["width"] = 122,
					["infoPanel"] = {
						["enable"] = true,
					},
					["height"] = 50,
					["name"] = {
						["attachTextTo"] = "InfoPanel",
						["yOffset"] = -2,
						["position"] = "TOP",
					},
				},
				["pet"] = {
					["debuffs"] = {
						["enable"] = true,
					},
					["threatStyle"] = "NONE",
					["castbar"] = {
						["width"] = 122,
					},
					["width"] = 122,
					["infoPanel"] = {
						["enable"] = true,
						["height"] = 14,
					},
					["height"] = 50,
					["portrait"] = {
						["camDistanceScale"] = 2,
					},
				},
				["arena"] = {
					["castbar"] = {
						["width"] = 246,
					},
					["spacing"] = 26,
				},
				["assist"] = {
					["enable"] = false,
				},
			},
		},
		["datatexts"] = {
			["minimapPanels"] = false,
			["fontSize"] = 11,
			["leftChatPanel"] = false,
			["goldFormat"] = "SHORT",
			["panelTransparency"] = true,
			["font"] = "Expressway",
			["panels"] = {
				["BottomMiniPanel"] = "Time",
				["RightMiniPanel"] = "",
				["RightChatDataPanel"] = {
					["right"] = "",
					["left"] = "",
					["middle"] = "",
				},
				["LeftMiniPanel"] = "",
				["LeftChatDataPanel"] = {
					["right"] = "",
					["left"] = "",
					["middle"] = "",
				},
			},
			["rightChatPanel"] = false,
		},
		["actionbar"] = {
			["bar3"] = {
				["inheritGlobalFade"] = true,
				["buttonsize"] = 38,
				["buttonsPerRow"] = 3,
			},
			["bar2"] = {
				["enabled"] = true,
				["inheritGlobalFade"] = true,
				["buttonsize"] = 38,
			},
			["bar1"] = {
				["heightMult"] = 2,
				["inheritGlobalFade"] = true,
				["buttonsize"] = 38,
			},
			["bar5"] = {
				["inheritGlobalFade"] = true,
				["buttonsize"] = 38,
				["buttonsPerRow"] = 3,
			},
			["fontSize"] = 9,
			["globalFadeAlpha"] = 0.87,
			["bar6"] = {
				["buttonsize"] = 38,
			},
			["stanceBar"] = {
				["inheritGlobalFade"] = true,
			},
			["bar4"] = {
				["enabled"] = false,
				["backdrop"] = false,
				["buttonsize"] = 38,
			},
		},
		["layoutSet"] = "dpsMelee",
		["chat"] = {
			["chatHistory"] = false,
			["fontSize"] = 11,
			["tabFont"] = "Expressway",
			["fadeUndockedTabs"] = false,
			["editBoxPosition"] = "ABOVE_CHAT",
			["fadeTabsNoBackdrop"] = false,
			["font"] = "Expressway",
			["tapFontSize"] = 11,
			["panelBackdrop"] = "HIDEBOTH",
		},
		["tooltip"] = {
			["textFontSize"] = 11,
			["font"] = "Expressway",
			["healthBar"] = {
				["font"] = "Expressway",
			},
			["fontSize"] = 11,
			["smallTextFontSize"] = 11,
			["headerFontSize"] = 11,
		},
	}
end