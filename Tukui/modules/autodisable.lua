------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------

if TukuiCF["actionbar"].bottomrows == 0 or TukuiCF["actionbar"].bottomrows > 3 then
	TukuiCF["actionbar"].bottomrows = 1
end

if TukuiCF["actionbar"].rightbars > 3 then
	TukuiCF["actionbar"].rightbars = 3
end

if TukuiCF["actionbar"].rightbars > 2 and TukuiCF["actionbar"].splitbar == true then
	TukuiCF["actionbar"].rightbars = 2
end

if TukuiCF["unitframes"].classcolor == true then
	TukuiCF["unitframes"].healthcolorbyvalue = false
end

if TukuiCF["actionbar"].bottomrows < 2 then
	TukuiCF["actionbar"].swaptopbottombar = nil
end

if TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].rightbars ~= 0 and TukuiCF["actionbar"].splitbar == true then
	TukuiCF["actionbar"].rightbars = 0
end

if TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].rightbars > 2 then
	TukuiCF["actionbar"].rightbars = 2
end

------------------------------------------------------------------------
-- auto-overwrite script config is X mod is found
------------------------------------------------------------------------

-- because users are too lazy to disable feature in config file
-- adding an auto disable if some mods are loaded

if (IsAddOnLoaded("Stuf") or IsAddOnLoaded("PitBull4") or IsAddOnLoaded("ShadowedUnitFrames") or IsAddOnLoaded("ag_UnitFrames")) then
	TukuiCF["unitframes"].enable = false
	TukuiCF["raidframes"].enable = false
end

if (IsAddOnLoaded("TidyPlates") or IsAddOnLoaded("Aloft")) then
	TukuiCF["nameplate"].enable = false
end

if (IsAddOnLoaded("Dominos") or IsAddOnLoaded("Bartender4")) then
	TukuiCF["actionbar"].enable = false
end

if (IsAddOnLoaded("Mapster")) then
	TukuiCF["others"].enablemap = false
end

if (IsAddOnLoaded("Prat") or IsAddOnLoaded("Chatter")) then
	TukuiCF["chat"].enable = false
end

if (IsAddOnLoaded("Quartz") or IsAddOnLoaded("AzCastBar") or IsAddOnLoaded("eCastingBar")) then
	TukuiCF["unitframes"].unitcastbar = false
end

if (IsAddOnLoaded("Afflicted3") or IsAddOnLoaded("InterruptBar")) then
	TukuiCF["arena"].spelltracker = false
end

if IsAddOnLoaded("ArkInventory") then
	TukuiCF["others"].enablebag = false
end

if IsAddOnLoaded("TipTac") or IsAddOnLoaded("TipTop") then
	TukuiCF["tooltip"].enable = false
end

------------------------
-- Keep tukui config nice and clean if we disable something
------------------------

--change/kill some default options

do
	if TukuiCF["unitframes"].enable ~= true and TukuiCF["raidframes"].enable ~= true then
		TukuiCF["auras"]["auratimer"] = nil                  -- enable timers on buffs/debuffs
		TukuiCF["auras"]["auratextscale"] = nil                -- the font size of buffs/debuffs timers on unitframes
		TukuiCF["auras"]["playerauras"] = nil               -- enable auras
		TukuiCF["auras"]["playershowonlydebuffs"] = nil 		-- only show the players debuffs over the player frame not buffs (playerauras must be true)
		TukuiCF["auras"]["playerdebuffsonly"] = nil			-- show the players debuffs on target and any debuff in the whitelist (see debuffFilter.lua)
		TukuiCF["auras"]["targetauras"] = nil                -- enable auras on target unit frame
		TukuiCF["auras"]["arenadebuffs"] = nil 				-- enable debuff filter for arena frames
		TukuiCF["auras"]["raidunitbuffwatch"] = nil       -- track important spell to watch in pve for grid mode.
		TukuiCF["auras"]["totdebuffs"] = nil                -- enable tot debuffs (high reso only)
		TukuiCF["auras"]["focusdebuffs"] = nil              -- enable focus debuffs 
	end
	
	if TukuiCF["unitframes"].enable ~= true then
		TukuiCF["unitframes"]["fontsize"] = nil						-- default font height for unitframes
		TukuiCF["unitframes"]["lowThreshold"] = nil                 -- global low threshold for low mana warning.
		TukuiCF["unitframes"]["targetpowerplayeronly"] = nil         -- enable power text on pvp target only
		TukuiCF["unitframes"]["showfocustarget"] = nil           -- show focus's target
		TukuiCF["unitframes"]["showtotalhpmp"] = nil             -- change the display of info text on player and target with XXXX/Total.
		TukuiCF["unitframes"]["showsmooth"] = nil                 -- enable smooth bar
		TukuiCF["unitframes"]["showthreat"] = nil                 -- enable the threat bar anchored to info left panel.
		TukuiCF["unitframes"]["charportrait"] = nil              -- enable character portrait
		TukuiCF["unitframes"]["combatfeedback"] = nil             -- enable combattext on player and target.
		TukuiCF["unitframes"]["playeraggro"] = nil                -- color player border to red if you have aggro on current target.
		TukuiCF["unitframes"]["positionbychar"] = nil             -- save X Y position with /uf (movable frame) per character instead of per account.
		TukuiCF["unitframes"]["swingbar"] = nil					--enables swingbar (dps layout only)
		TukuiCF["unitframes"]["debuffhighlight"] = nil			--highlight frame with the debuff color if the frame is dispellable
		TukuiCF["unitframes"]["showsymbols"] = nil	               -- show symbol.
		TukuiCF["unitframes"]["aggro"] = nil                      -- show aggro on all raids layouts
		TukuiCF["unitframes"]["classbar"] = nil
		TukuiCF["unitframes"]["mendpet"] = nil                  -- enable maintank
		TukuiCF["unitframes"]["poweroffset"] = nil
		TukuiCF["auras"]["playtarbuffperrow"] = nil
		TukuiCF["auras"]["smallbuffperrow"] = nil

		--kill an entire catagory
		ALLOWED_GROUPS.castbar = nil
		ALLOWED_GROUPS.arena = nil
		ALLOWED_GROUPS.framesizes = nil
	end
	
	if TukuiCF["castbar"].unitcastbar ~= true then
		TukuiCF["castbar"]["cblatency"] = nil -- enable castbar latency
		TukuiCF["castbar"]["cbicons"] = nil -- enable icons on castbar
		TukuiCF["castbar"]["castermode"] = nil -- makes castbar larger and puts it above the actionbar frame
		TukuiCF["castbar"]["classcolor"] = nil -- classcolor
		TukuiCF["castbar"]["castbarcolor"] = nil -- Color of player castbar
		TukuiCF["castbar"]["nointerruptcolor"] = nil -- Color of target castbar	
	end
	
	if TukuiCF["raidframes"].enable ~= true then
		TukuiCF["raidframes"]["fontsize"] = nil						-- default font height for raidframes
		TukuiCF["raidframes"]["scale"] = nil							-- for smaller use a number less than one (0.73) for higher use a number larger than one
		TukuiCF["raidframes"]["showrange"] = nil                  -- show range opacity on raidframes
		TukuiCF["raidframes"]["hidenonmana"] = nil					-- hide non mana on party/raid frames
		TukuiCF["raidframes"]["raidalphaoor"] = nil                -- alpha of raidframes when unit is out of range
		TukuiCF["raidframes"]["gridonly"] = nil                 -- enable grid only mode for all raid layout.
		TukuiCF["raidframes"]["gridhealthvertical"] = nil         -- enable vertical grow on health bar for healer layout
		TukuiCF["raidframes"]["showplayerinparty"] = nil         -- show my player frame in party
		TukuiCF["raidframes"]["nogriddps"] = nil					--sets up 25man dps layout to be vertical not grid
		TukuiCF["raidframes"]["centerheallayout"] = nil			--setup healer frames around the center	
	end
	
	if TukuiCF["nameplate"].enable ~= true then
		TukuiCF["nameplate"]["showhealth"] = nil					-- show health text on nameplate
		TukuiCF["nameplate"]["enhancethreat"] = nil				-- threat features based on if your a tank or not
		TukuiCF["nameplate"]["showclassicons"] = nil				-- show class icons on player nameplates
		TukuiCF["nameplate"]["showcombo"] = nil					-- show combo points on nameplate	
	end
	
	if TukuiCF["chat"].enable ~= true then
		TukuiCF["chat"]["whispersound"] = nil               -- play a sound when receiving whisper
		TukuiCF["chat"]["showbackdrop"] = nil				-- show a backdrop on the chat panels
		TukuiCF["chat"]["fadeoutofuse"] = nil				-- fade chat text when out of use	
		TukuiCF["chat"]["sticky"] = nil
	end
	
	if TukuiCF["tooltip"].enable ~= true then
		TukuiCF["tooltip"]["hidecombat"] = nil                -- hide bottom-right tooltip when in combat
		TukuiCF["tooltip"]["hidecombatraid"] = nil				-- only hide in combat in a raid instance
		TukuiCF["tooltip"]["hidebuttons"] = nil               -- always hide action bar buttons tooltip.
		TukuiCF["tooltip"]["hideuf"] = nil                    -- hide tooltip on unitframes
		TukuiCF["tooltip"]["cursor"] = nil                    -- show anchored to cursor
		TukuiCF["tooltip"]["colorreaction"] = nil				-- always color border of tooltip by unit reaction
		TukuiCF["tooltip"]["xOfs"] = nil							--X offset
		TukuiCF["tooltip"]["yOfs"] = nil							--Y offset	
	end
	
	if TukuiCF["actionbar"].enable ~= true then
		TukuiCF["actionbar"]["hotkey"] = nil                     -- enable hotkey display because it was a lot requested
		TukuiCF["actionbar"]["rightbarmouseover"] = nil         -- enable right bars on mouse over
		TukuiCF["actionbar"]["shapeshiftmouseover"] = nil       -- enable shapeshift or totembar on mouseover
		TukuiCF["actionbar"]["hideshapeshift"] = nil            -- hide shapeshift or totembar because it was a lot requested.
		TukuiCF["actionbar"]["bottomrows"] = nil                    -- numbers of row you want to show at the bottom (select between 1 and 2 only)
		TukuiCF["actionbar"]["rightbars"] = nil                     -- numbers of right bar you want
		TukuiCF["actionbar"]["splitbar"] = nil					-- split the third right actionbar into two rows of 3 on the left and right side of the main actionbar
		TukuiCF["actionbar"]["showgrid"] = nil                   -- show grid on empty button	
		TukuiCF["actionbar"]["sixbuttons"] = nil  
	end
	
	if TukuiCF["buffreminder"].enable ~= true then
		TukuiCF["buffreminder"]["sound"] = nil
	end

	if TukuiCF["datatext"].stat1 == 0 then
		TukuiCF["datatext"].stat1tankstat = nil
		TukuiCF["datatext"].stat1meleestat = nil
		TukuiCF["datatext"].stat1casterstat = nil
	end

	if TukuiCF["datatext"].stat2 == 0 then
		TukuiCF["datatext"].stat2tankstat = nil
		TukuiCF["datatext"].stat2meleestat = nil
		TukuiCF["datatext"].stat2casterstat = nil
	end
end

--------------------------------------------------------------------
-- OTHERS
--------------------------------------------------------------------
--Auto disable tooltip on Unitframe if tooltip is disabled
if TukuiCF.tooltip.cursor and not TukuiCF.tooltip.hideuf then
	TukuiCF.tooltip.hideuf = true
end

if TukuiCF["media"].glossyTexture ~= true then
	TukuiCF["media"].normTex = [[Interface\AddOns\Tukui\media\textures\normTex2]]
end