-------------------------------------------------------------------------------
-- SPELL LIST IF YOU WANT TO ADD SPELL's (these spells are inactive)
--[[---------------------------------------------------------------------------

[1766] = 10, -- kick
[47476] = 120, --Strangulate
[48792] = 120, --Icebound Fortitude
[6554] = 10, -- pummel
[2139] = 24, -- counterspell
[19647] = 24, -- spell lock
[10890] = 27, -- fear priest
[47476] = 120, -- strangulate
[47528] = 10, -- mindfreeze
[51514] = 45, -- hex
[54428] = 60, -- divine plea time duration
[29166] = 300, -- innervate time duration
[34490] = 20, -- hunter silencing shot
[26090] = 30, -- pummel hunter gorilla
[29166] = 180, -- innervate
[47528] = 10, -- Mind Freeze
[48707] = 45, -- Anti-Magic Shell
[49576] = 35, -- Death Grip
[51052] = 120, -- Anti-Magic Zone
[49028] = 90, -- Dancing Rune Weapon
[49039] = 120, -- Lichborne
[55233] = 60, -- Vampiric Blood
[47482] = 20, -- Leap (Ghoul)
[47481] = 60, -- Gnaw (Ghoul)
[66233] = 120, -- Ardent Defender
[54428] = 60, -- Divine Plea
[31884] = 120, -- Avenging Wrath
[10308] = 40, -- Hammer of Justice
[10278] = 180, -- Hand of Protection
[642] = 300, -- Divine Shield
[1044] = 25, -- Hand of Freedom
[6940] = 120, -- Hand of Sacrifice
[31821] = 120, -- Aura Mastery
[64205] = 120, -- Divine Sacrifice
[23920] = 10, -- Shield Reflect
[72] = 12, -- Shield Bash
[6552] = 10, -- Pummel
[3411] = 30, -- Intervene
[1719] = 300, -- Recklessness
[11578] = 13, -- Charge
[18499] = 30, -- Berserker Rage
[20252] = 15, -- Intercept
[871] = 300, -- Shield Wall
[676] = 60, -- Disarm
[61336] = 300, -- Survival Instincts
[50334] = 180, -- Berserk
[53312] = 60, -- Nature's Grasp
[29166] = 180, -- Innervate
[22842] = 180, -- Frenzied Regeneration
[16979] = 15, -- Feral Charge - Bear
[49376] = 30, -- Feral Charge - Cat
[8983] = 30, -- Bash
[64901] = 360, -- Hymn of Hope
[47585] = 75, -- Dispersion
[47788] = 180, -- Guardian Spirit
[33206] = 144, -- Pain Suppression
[15487] = 45, -- Silence
[10890] = 26, -- Psychic Scream
[18708] = 180, -- Fel Domination
[48011] = 8, -- Devour Magic (Felhunter)
[47996] = 30, -- Intercept (Felguard)
[19647] = 24, -- Spell Lock
[51514] = 45, -- Hex
[57994] = 6, -- Wind Shock
[2825] = 300, -- Bloodlust
[30823] = 60, -- Shamanistic Rage
[16190] = 300, -- Mana Tide Totem
[8177] = 15, -- Grounding Totem
[19574] = 120, -- Bestial Wrath
[49012] = 60, -- Wyvern Sting
[34490] = 20, -- Silencing Shot
[23989] = 180, -- Readiness
[53589] = 40, -- Nether Shock
[53548] = 40, -- Pin (Crab)
[26090] = 30, -- Pummel
[14311] = 30, -- Freezing Trap
[49056] = 30, -- Immolation Trap
[34600] = 30, -- Snake Trap
[19263] = 90, -- Deterrence
[3034] = 15, -- Viper Sting
[11958] = 384, -- Cold Snap
[44572] = 30, -- Deep Freeze
[12472] = 144, -- Icy Veins
[66] = 180, -- Invisibility
[45438] = 240, -- Ice Block
[2139] = 24, -- Counterspell
[1953] = 15, -- Blink
[8643] = 20, -- Kidney Shot
[36554] = 30, -- Shadow Step
[13750] = 180, -- Adrenaline Rush
[14185] = 300, -- Preparation
[31224] = 60, -- Cloak of Shadows
[26889] = 120, -- Vanish
[11305] = 120, -- Sprint
[26669] = 120, -- Evasion
[2094] = 120, -- Blind
[51722] = 60, -- Dismantle
[20589] = 105, -- Escape Artist
}

----------------------------------------------------------------------]]

if not IsAddOnLoaded("Afflicted3") then
	if TukuiDB["arena"].spelltracker == true then

		tCooldownTracker = CreateFrame("frame")
		tCooldownTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		tCooldownTracker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		TukuiArena = { ["x"] = 677, ["y"] = 383, ["orientation"] = "VERTICALUP" }
		tCooldownTracker.Orientations = { 
			["HORIZONTALRIGHT"] = { ["point"] = "TOPLEFT", ["rpoint"] = "TOPRIGHT", ["x"] = 3, ["y"] = 0 },
			["HORIZONTALLEFT"] = { ["point"] = "TOPRIGHT", ["rpoint"] = "TOPLEFT", ["x"] = -3, ["y"] = 0 }, 
			["VERTICALDOWN"] = { ["point"] = "TOPLEFT", ["rpoint"] = "BOTTOMLEFT", ["x"] = 0, ["y"] = -3 },
			["VERTICALUP"] = { ["point"] = "BOTTOMLEFT", ["rpoint"] = "TOPLEFT", ["x"] = 0, ["y"] = 3 }, 
		}

		------------------------------------------------------------
		-- spell configuration
		------------------------------------------------------------

		tCooldownTracker.Spells = TukuiDB.spelltracker

		------------------------------------------------------------
		-- end of spell configuration
		------------------------------------------------------------

		SlashCmdList["tCooldownTracker"] = function(msg) tCooldownTracker.SlashHandler(msg) end
		SLASH_tCooldownTracker1 = "/tcdt"
		SLASH_tCooldownTracker2 = "/tracker"
		tCooldownTracker:SetScript("OnEvent", function(this, event, ...) tCooldownTracker[event](...) end)

		tCooldownTracker.Icons = { }

		function tCooldownTracker.CreateIcon()
			local i = (#tCooldownTracker.Icons)+1
		   
			tCooldownTracker.Icons[i] = CreateFrame("frame","tCooldownTrackerIcon"..i,UIParent)
			tCooldownTracker.Icons[i]:SetHeight(28)
			tCooldownTracker.Icons[i]:SetWidth(28)
			  
			tCooldownTracker.Icons[i]:Hide()

			tCooldownTracker.Icons[i].Texture = tCooldownTracker.Icons[i]:CreateTexture(nil,"BACKGROUND")
			tCooldownTracker.Icons[i].Texture:SetTexture("Interface\\Icons\\Spell_Nature_Cyclone.blp")
			tCooldownTracker.Icons[i].Texture:SetAllPoints(tCooldownTracker.Icons[i])
			
			--TukuiDB:SetTemplate(tCooldownTracker.Icons[i])

			tCooldownTracker.Icons[i].border = tCooldownTracker.Icons[i]:CreateTexture(nil,"ARTWORK")
			tCooldownTracker.Icons[i].border:SetTexture("Interface\\Addons\\Tukui\\media\\gloss.tga")
			tCooldownTracker.Icons[i].border:SetHeight(32)
			tCooldownTracker.Icons[i].border:SetWidth(32)
			tCooldownTracker.Icons[i].border:SetPoint("CENTER", tCooldownTracker.Icons[i], "CENTER", 0, 0)

			tCooldownTracker.Icons[i].TimerText = tCooldownTracker.Icons[i]:CreateFontString("tCooldownTrackerTimerText","OVERLAY")
			tCooldownTracker.Icons[i].TimerText:SetFont(STANDARD_TEXT_FONT,14,"Outline")
			tCooldownTracker.Icons[i].TimerText:SetTextColor(1,.9294,.7607)
			tCooldownTracker.Icons[i].TimerText:SetShadowColor(0,0,0)
			tCooldownTracker.Icons[i].TimerText:SetShadowOffset(1,-1)
			tCooldownTracker.Icons[i].TimerText:SetPoint("CENTER", tCooldownTracker.Icons[i], "CENTER",1,1)
			tCooldownTracker.Icons[i].TimerText:SetText(5)
		   
			return i
		end

		tCooldownTracker.CreateIcon()
		tCooldownTracker.Icons[1]:RegisterForDrag("LeftButton")
		tCooldownTracker.Icons[1]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", TukuiArena.x, TukuiArena.y)
		tCooldownTracker.Icons[1]:SetScript("OnDragStart", function() tCooldownTracker.Icons[1]:StartMoving() end)
		tCooldownTracker.Icons[1]:SetScript("OnDragStop", function() 
			tCooldownTracker.Icons[1]:StopMovingOrSizing() 
			TukuiArena.x = math.floor(tCooldownTracker.Icons[1]:GetLeft())
			TukuiArena.y = math.floor(tCooldownTracker.Icons[1]:GetTop())
			end)

		function tCooldownTracker.SlashHandler(msg)
			arg = string.upper(msg)
			if (tCooldownTracker[arg]) then
				tCooldownTracker[arg]()
			else
				tCooldownTracker.Print("Tukui Cooldown Tracker Options:")
				DEFAULT_CHAT_FRAME:AddMessage(" - /tcdt unlock")
				DEFAULT_CHAT_FRAME:AddMessage(" - /tcdt lock")
				DEFAULT_CHAT_FRAME:AddMessage(" - /tcdt reset")
				DEFAULT_CHAT_FRAME:AddMessage(" - /tcdt horizontalright")
				DEFAULT_CHAT_FRAME:AddMessage(" - /tcdt horizontalleft")
				DEFAULT_CHAT_FRAME:AddMessage(" - /tcdt verticaldown")
				DEFAULT_CHAT_FRAME:AddMessage(" - /tcdt verticalup")
			end
		end

		function tCooldownTracker.UNLOCK()
			if (not tCooldownTracker.Icons[1]:IsMouseEnabled()) then
				tCooldownTracker.StopAllTimers()
				tCooldownTracker.Icons[1]:EnableMouse(true)
				tCooldownTracker.Icons[1]:SetMovable(true)
				tCooldownTracker.StartTimer(1,60,nil)
			end
		end

		function tCooldownTracker.LOCK()
			if (tCooldownTracker.Icons[1]:IsMouseEnabled()) then
				tCooldownTracker.Icons[1]:EnableMouse(false)
				tCooldownTracker.Icons[1]:SetMovable(false)
				tCooldownTracker.StopTimer(1)
			end
		end

		function tCooldownTracker.RESET()
			TukuiArena.x = 677
			TukuiArena.y = 383
			tCooldownTracker.Icons[1]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", TukuiArena.x, TukuiArena.y)
			tCooldownTracker.Print("Position reset successfully.")
		end

		function tCooldownTracker.HORIZONTALRIGHT()
			TukuiArena.orientation = "HORIZONTALRIGHT"
			tCooldownTracker.Print("Icons will now stack horizontally to the right.")
		end

		function tCooldownTracker.HORIZONTALLEFT()
			TukuiArena.orientation = "HORIZONTALLEFT"
			tCooldownTracker.Print("Icons will now stack horizontally to the left.")
		end

		function tCooldownTracker.VERTICALDOWN()
			TukuiArena.orientation = "VERTICALDOWN"
			tCooldownTracker.Print("Icons will now stack vertically downwards.")
		end

		function tCooldownTracker.VERTICALUP()
			TukuiArena.orientation = "VERTICALUP"
			tCooldownTracker.Print("Icons will now stack vertically upwards.")
		end

		function tCooldownTracker.Print(msg, ...)
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF33[Tukui Cooldown Tracker]|r "..format(msg, ...))
		end

		--  

		function tCooldownTracker.COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID)
				isArena, isRegistered = IsActiveBattlefieldArena();
				if isArena then
					if (event == "SPELL_CAST_SUCCESS" and not tCooldownTracker.Icons[1]:IsMouseEnabled() and (bit.band(sourceFlags,COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE)) then			
						if (sourceName ~= UnitName("player")) then
							if (tCooldownTracker.Spells[spellID]) then
								local _,_,texture = GetSpellInfo(spellID)
								tCooldownTracker.StartTimer(tCooldownTracker.NextAvailable(),tCooldownTracker.Spells[spellID],texture,spellID)
							end
						end
					end
				end
		end

		function tCooldownTracker.NextAvailable()
			for i=1,#tCooldownTracker.Icons do
				if (not tCooldownTracker.Timers[i]) then
					return i
				end
			end
			return tCooldownTracker.CreateIcon()
		end

		tCooldownTracker.Timers = { }
		function tCooldownTracker.StartTimer(icon, duration, texture, spellID)			
			tCooldownTracker.Timers[(icon)] = {
				["Start"] = GetTime(),
				["Duration"] = duration,
				["SpellID"] = spellID,
			}
			UIFrameFadeIn(tCooldownTracker.Icons[icon],0.2,0.0,1.0)
			if (texture) then
				tCooldownTracker.Icons[(active or icon)].Texture:SetTexture(texture)
			end
			tCooldownTracker.Reposition()
			tCooldownTracker:SetScript("OnUpdate", function(this, arg1) tCooldownTracker.OnUpdate(arg1) end)
		end

		function tCooldownTracker.StopTimer(icon)
			if (tCooldownTracker.Icons[icon]:IsMouseEnabled()) then
				tCooldownTracker.LOCK()
			end
			UIFrameFadeOut(tCooldownTracker.Icons[icon],0.2,1.0,0.0)
			tCooldownTracker.Timers[icon] = nil
			tCooldownTracker.Reposition()
			if (#tCooldownTracker.Timers == 0) then
				tCooldownTracker:SetScript("OnUpdate", nil)
			end
		end

		function tCooldownTracker.StopAllTimers()
			for i in pairs(tCooldownTracker.Timers) do
				tCooldownTracker.StopTimer(i)
			end
		end

		function tCooldownTracker.Reposition()
			local sorttable = { }
			local indexes = { }
			
			for i in pairs(tCooldownTracker.Timers) do
				tinsert(sorttable, tCooldownTracker.Timers[i].Start)
				indexes[tCooldownTracker.Timers[i].Start] = i
			end

			table.sort(sorttable)


			local currentactive = 0
			for k=1,#sorttable do
				local v = sorttable[k]
				local i = indexes[v]
				tCooldownTracker.Icons[i]:ClearAllPoints()
				if (currentactive == 0) then
					tCooldownTracker.Icons[i]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", TukuiArena.x, TukuiArena.y)
				else
					tCooldownTracker.Icons[i]:SetPoint(tCooldownTracker.Orientations[TukuiArena.orientation].point, 
						tCooldownTracker.Icons[currentactive], 
						tCooldownTracker.Orientations[TukuiArena.orientation].rpoint, 
						tCooldownTracker.Orientations[TukuiArena.orientation].x, 
						tCooldownTracker.Orientations[TukuiArena.orientation].y)
				end
				currentactive = i
			end
		end

		local updatetimer = 1
		function tCooldownTracker.OnUpdate(elapsed)
			if (updatetimer >= elapsed) then
				updatetimer = 0.05
				if (#tCooldownTracker.Timers > 0) then
					for i in pairs(tCooldownTracker.Timers) do
						local timeleft = tCooldownTracker.Timers[i].Duration+1-(GetTime()-tCooldownTracker.Timers[i].Start)
						if (timeleft < 0) then
							tCooldownTracker.StopTimer(i)
						else
							tCooldownTracker.Icons[i].TimerText:SetText(math.floor(timeleft))
						end
					end
				else
					updatetimer = updatetimer - elapsed;
				end
			end
		end

		function tCooldownTracker:ZONE_CHANGED_NEW_AREA()
				local pvpType = GetZonePVPInfo()
				
				if not pvpType ~= "Arena" then
					for i in pairs(tCooldownTracker.Timers) do
					tCooldownTracker.StopTimer(i)
					end
				end
		end

	end
end