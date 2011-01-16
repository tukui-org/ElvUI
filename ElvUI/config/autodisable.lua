------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------
local ElvDB = ElvDB
local ElvCF = ElvCF

if ElvCF["actionbar"].bottomrows == 0 or ElvCF["actionbar"].bottomrows > 3 then
	ElvCF["actionbar"].bottomrows = 1
end

if ElvCF["actionbar"].rightbars > 3 then
	ElvCF["actionbar"].rightbars = 3
end

if ElvCF["actionbar"].rightbars > 2 and ElvCF["actionbar"].splitbar == true then
	ElvCF["actionbar"].rightbars = 2
end

if ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].rightbars ~= 0 and ElvCF["actionbar"].splitbar == true then
	ElvCF["actionbar"].rightbars = 0
end

if ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].rightbars > 2 then
	ElvCF["actionbar"].rightbars = 2
end

if ElvDB.client == "zhTW" or ElvDB.client == "zhCN" then
	ElvCF["media"].uffont = [[fonts\bLEI00D.ttf]]
	ElvCF["media"].font = [[fonts\bLEI00D.ttf]]
	ElvCF["media"].dmgfont = [[fonts\bLEI00D.ttf]]
end

if ElvCF["general"].classcolortheme == true then
	local c = select(2, UnitClass("player"))
	local r, g, b = RAID_CLASS_COLORS[c].r, RAID_CLASS_COLORS[c].g, RAID_CLASS_COLORS[c].b
	ElvCF["media"].altbordercolor = {r, g, b, 1}
	ElvCF["unitframes"].classcolor = true
	ElvCF["classtimer"].classcolor = true
end

------------------------
-- Keep Elvui config nice and clean if we disable something
------------------------

--change/kill some default options

do
	if ElvCF["unitframes"].enable ~= true and ElvCF["raidframes"].enable ~= true then
		ElvCF["auras"]["auratimer"] = nil                  -- enable timers on buffs/debuffs
		ElvCF["auras"]["auratextscale"] = nil                -- the font size of buffs/debuffs timers on unitframes
		ElvCF["auras"]["playerauras"] = nil               -- enable auras
		ElvCF["auras"]["playershowonlydebuffs"] = nil 		-- only show the players debuffs over the player frame not buffs (playerauras must be true)
		ElvCF["auras"]["playerdebuffsonly"] = nil			-- show the players debuffs on target and any debuff in the whitelist (see debuffFilter.lua)
		ElvCF["auras"]["targetauras"] = nil                -- enable auras on target unit frame
		ElvCF["auras"]["arenadebuffs"] = nil 				-- enable debuff filter for arena frames
		ElvCF["auras"]["raidunitbuffwatch"] = nil       -- track important spell to watch in pve for grid mode.
		ElvCF["auras"]["totdebuffs"] = nil                -- enable tot debuffs (high reso only)
		ElvCF["auras"]["focusdebuffs"] = nil              -- enable focus debuffs 
	end
	
	if ElvCF["unitframes"].enable ~= true then
		ElvCF["unitframes"]["fontsize"] = nil						-- default font height for unitframes
		ElvCF["unitframes"]["lowThreshold"] = nil                 -- global low threshold for low mana warning.
		ElvCF["unitframes"]["targetpowerplayeronly"] = nil         -- enable power text on pvp target only
		ElvCF["unitframes"]["showfocustarget"] = nil           -- show focus's target
		ElvCF["unitframes"]["showtotalhpmp"] = nil             -- change the display of info text on player and target with XXXX/Total.
		ElvCF["unitframes"]["showsmooth"] = nil                 -- enable smooth bar
		ElvCF["unitframes"]["showthreat"] = nil                 -- enable the threat bar anchored to info left panel.
		ElvCF["unitframes"]["charportrait"] = nil              -- enable character portrait
		ElvCF["unitframes"]["combatfeedback"] = nil             -- enable combattext on player and target.
		ElvCF["unitframes"]["playeraggro"] = nil                -- color player border to red if you have aggro on current target.
		ElvCF["unitframes"]["positionbychar"] = nil             -- save X Y position with /uf (movable frame) per character instead of per account.
		ElvCF["unitframes"]["swingbar"] = nil					--enables swingbar (dps layout only)
		ElvCF["unitframes"]["debuffhighlight"] = nil			--highlight frame with the debuff color if the frame is dispellable
		ElvCF["unitframes"]["showsymbols"] = nil	               -- show symbol.
		ElvCF["unitframes"]["aggro"] = nil                      -- show aggro on all raids layouts
		ElvCF["unitframes"]["classbar"] = nil
		ElvCF["unitframes"]["mendpet"] = nil                  -- enable maintank
		ElvCF["unitframes"]["poweroffset"] = nil
		ElvCF["auras"]["playtarbuffperrow"] = nil
		ElvCF["auras"]["smallbuffperrow"] = nil

		--kill an entire catagory
		ALLOWED_GROUPS.castbar = nil
		ALLOWED_GROUPS.arena = nil
		ALLOWED_GROUPS.framesizes = nil
	end
	
	if ElvCF["castbar"].unitcastbar ~= true then
		ElvCF["castbar"]["cblatency"] = nil -- enable castbar latency
		ElvCF["castbar"]["cbicons"] = nil -- enable icons on castbar
		ElvCF["castbar"]["castermode"] = nil -- makes castbar larger and puts it above the actionbar frame
		ElvCF["castbar"]["classcolor"] = nil -- classcolor
		ElvCF["castbar"]["castbarcolor"] = nil -- Color of player castbar
		ElvCF["castbar"]["nointerruptcolor"] = nil -- Color of target castbar	
	end
	
	if ElvCF["raidframes"].enable ~= true then
		ElvCF["raidframes"]["fontsize"] = nil						-- default font height for raidframes
		ElvCF["raidframes"]["scale"] = nil							-- for smaller use a number less than one (0.73) for higher use a number larger than one
		ElvCF["raidframes"]["showrange"] = nil                  -- show range opacity on raidframes
		ElvCF["raidframes"]["hidenonmana"] = nil					-- hide non mana on party/raid frames
		ElvCF["raidframes"]["raidalphaoor"] = nil                -- alpha of raidframes when unit is out of range
		ElvCF["raidframes"]["gridonly"] = nil                 -- enable grid only mode for all raid layout.
		ElvCF["raidframes"]["gridhealthvertical"] = nil         -- enable vertical grow on health bar for healer layout
		ElvCF["raidframes"]["showplayerinparty"] = nil         -- show my player frame in party
		ElvCF["raidframes"]["nogriddps"] = nil					--sets up 25man dps layout to be vertical not grid
		ElvCF["raidframes"]["centerheallayout"] = nil			--setup healer frames around the center	
	end
	
	if ElvCF["nameplate"].enable ~= true then
		ElvCF["nameplate"]["showhealth"] = nil					-- show health text on nameplate
		ElvCF["nameplate"]["enhancethreat"] = nil				-- threat features based on if your a tank or not
		ElvCF["nameplate"]["showclassicons"] = nil				-- show class icons on player nameplates
		ElvCF["nameplate"]["showcombo"] = nil					-- show combo points on nameplate	
	end
	
	if ElvCF["chat"].enable ~= true then
		ElvCF["chat"]["whispersound"] = nil               -- play a sound when receiving whisper
		ElvCF["chat"]["showbackdrop"] = nil				-- show a backdrop on the chat panels
		ElvCF["chat"]["fadeoutofuse"] = nil				-- fade chat text when out of use	
		ElvCF["chat"]["sticky"] = nil
	end
	
	if ElvCF["tooltip"].enable ~= true then
		ElvCF["tooltip"]["hidecombat"] = nil                -- hide bottom-right tooltip when in combat
		ElvCF["tooltip"]["hidecombatraid"] = nil				-- only hide in combat in a raid instance
		ElvCF["tooltip"]["hidebuttons"] = nil               -- always hide action bar buttons tooltip.
		ElvCF["tooltip"]["hideuf"] = nil                    -- hide tooltip on unitframes
		ElvCF["tooltip"]["cursor"] = nil                    -- show anchored to cursor
		ElvCF["tooltip"]["colorreaction"] = nil				-- always color border of tooltip by unit reaction
		ElvCF["tooltip"]["xOfs"] = nil							--X offset
		ElvCF["tooltip"]["yOfs"] = nil							--Y offset	
	end
	
	if ElvCF["actionbar"].enable ~= true then
		ElvCF["actionbar"]["hotkey"] = nil                     -- enable hotkey display because it was a lot requested
		ElvCF["actionbar"]["rightbarmouseover"] = nil         -- enable right bars on mouse over
		ElvCF["actionbar"]["shapeshiftmouseover"] = nil       -- enable shapeshift or totembar on mouseover
		ElvCF["actionbar"]["hideshapeshift"] = nil            -- hide shapeshift or totembar because it was a lot requested.
		ElvCF["actionbar"]["bottomrows"] = nil                    -- numbers of row you want to show at the bottom (select between 1 and 2 only)
		ElvCF["actionbar"]["rightbars"] = nil                     -- numbers of right bar you want
		ElvCF["actionbar"]["splitbar"] = nil					-- split the third right actionbar into two rows of 3 on the left and right side of the main actionbar
		ElvCF["actionbar"]["showgrid"] = nil                   -- show grid on empty button	
		ElvCF["actionbar"]["sixbuttons"] = nil  
	end
	
	if ElvCF["buffreminder"].enable ~= true then
		ElvCF["buffreminder"]["sound"] = nil
	end

	if ElvCF["datatext"].stat1 == 0 then
		ElvCF["datatext"].stat1tankstat = nil
		ElvCF["datatext"].stat1meleestat = nil
		ElvCF["datatext"].stat1casterstat = nil
	end

	if ElvCF["datatext"].stat2 == 0 then
		ElvCF["datatext"].stat2tankstat = nil
		ElvCF["datatext"].stat2meleestat = nil
		ElvCF["datatext"].stat2casterstat = nil
	end
end

--------------------------------------------------------------------
-- OTHERS
--------------------------------------------------------------------

if ElvCF["media"].glossyTexture ~= true then
	ElvCF["media"].normTex = [[Interface\AddOns\ElvUI\media\textures\normTex2]]
end