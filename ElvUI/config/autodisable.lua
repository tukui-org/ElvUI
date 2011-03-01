------------------------------------------------------------------------
-- prevent action bar users config errors
------------------------------------------------------------------------
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


if E.client == "zhTW" or E.client == "zhCN" then
	C["media"].uffont = [[fonts\bLEI00D.ttf]]
	C["media"].font = [[fonts\bLEI00D.ttf]]
	C["media"].dmgfont = [[fonts\bLEI00D.ttf]]
end

if C["general"].classcolortheme == true then
	local c = select(2, UnitClass("player"))
	local r, g, b = RAID_CLASS_COLORS[c].r, RAID_CLASS_COLORS[c].g, RAID_CLASS_COLORS[c].b
	C["media"].altbordercolor = {r, g, b, 1}
	C["unitframes"].classcolor = true
end

------------------------
-- Keep Elvui config nice and clean if we disable something
------------------------

--change/kill some default options

do
	if C["unitframes"].enable ~= true and C["raidframes"].enable ~= true then
		C["auras"]["auratimer"] = nil                  -- enable timers on buffs/debuffs
		C["auras"]["auratextscale"] = nil                -- the font size of buffs/debuffs timers on unitframes
		C["auras"]["playerauras"] = nil               -- enable auras
		C["auras"]["playershowonlydebuffs"] = nil 		-- only show the players debuffs over the player frame not buffs (playerauras must be true)
		C["auras"]["playerdebuffsonly"] = nil			-- show the players debuffs on target and any debuff in the whitelist (see debuffFilter.lua)
		C["auras"]["targetauras"] = nil                -- enable auras on target unit frame
		C["auras"]["arenadebuffs"] = nil 				-- enable debuff filter for arena frames
		C["auras"]["raidunitbuffwatch"] = nil       -- track important spell to watch in pve for grid mode.
		C["auras"]["totdebuffs"] = nil                -- enable tot debuffs (high reso only)
		C["auras"]["focusdebuffs"] = nil              -- enable focus debuffs 
	end
	
	if C["unitframes"].enable ~= true then
		C["unitframes"]["fontsize"] = nil						-- default font height for unitframes
		C["unitframes"]["lowThreshold"] = nil                 -- global low threshold for low mana warning.
		C["unitframes"]["targetpowerplayeronly"] = nil         -- enable power text on pvp target only
		C["unitframes"]["showfocustarget"] = nil           -- show focus's target
		C["unitframes"]["showtotalhpmp"] = nil             -- change the display of info text on player and target with XXXX/Total.
		C["unitframes"]["showsmooth"] = nil                 -- enable smooth bar
		C["unitframes"]["charportrait"] = nil              -- enable character portrait
		C["unitframes"]["combatfeedback"] = nil             -- enable combattext on player and target.
		C["unitframes"]["playeraggro"] = nil                -- color player border to red if you have aggro on current target.
		C["unitframes"]["positionbychar"] = nil             -- save X Y position with /uf (movable frame) per character instead of per account.
		C["unitframes"]["swingbar"] = nil					--enables swingbar (dps layout only)
		C["unitframes"]["debuffhighlight"] = nil			--highlight frame with the debuff color if the frame is dispellable
		C["unitframes"]["showsymbols"] = nil	               -- show symbol.
		C["unitframes"]["aggro"] = nil                      -- show aggro on all raids layouts
		C["unitframes"]["classbar"] = nil
		C["unitframes"]["mendpet"] = nil                  -- enable maintank
		C["unitframes"]["poweroffset"] = nil
		C["auras"]["playtarbuffperrow"] = nil
		C["auras"]["smallbuffperrow"] = nil

		--kill an entire catagory
		ALLOWED_GROUPS.castbar = nil
		ALLOWED_GROUPS.arena = nil
		ALLOWED_GROUPS.framesizes = nil
	end
	
	if C["castbar"].unitcastbar ~= true then
		C["castbar"]["cblatency"] = nil -- enable castbar latency
		C["castbar"]["cbicons"] = nil -- enable icons on castbar
		C["castbar"]["castermode"] = nil -- makes castbar larger and puts it above the actionbar frame
		C["castbar"]["classcolor"] = nil -- classcolor
		C["castbar"]["castbarcolor"] = nil -- Color of player castbar
		C["castbar"]["nointerruptcolor"] = nil -- Color of target castbar	
	end
	
	if C["raidframes"].enable ~= true then
		C["raidframes"]["fontsize"] = nil						-- default font height for raidframes
		C["raidframes"]["scale"] = nil							-- for smaller use a number less than one (0.73) for higher use a number larger than one
		C["raidframes"]["showrange"] = nil                  -- show range opacity on raidframes
		C["raidframes"]["hidenonmana"] = nil					-- hide non mana on party/raid frames
		C["raidframes"]["raidalphaoor"] = nil                -- alpha of raidframes when unit is out of range
		C["raidframes"]["gridonly"] = nil                 -- enable grid only mode for all raid layout.
		C["raidframes"]["gridhealthvertical"] = nil         -- enable vertical grow on health bar for healer layout
		C["raidframes"]["showplayerinparty"] = nil         -- show my player frame in party
		C["raidframes"]["nogriddps"] = nil					--sets up 25man dps layout to be vertical not grid
		C["raidframes"]["centerheallayout"] = nil			--setup healer frames around the center	
	end
	
	if C["nameplate"].enable ~= true then
		C["nameplate"]["showhealth"] = nil					-- show health text on nameplate
		C["nameplate"]["enhancethreat"] = nil				-- threat features based on if your a tank or not
		C["nameplate"]["showclassicons"] = nil				-- show class icons on player nameplates
		C["nameplate"]["showcombo"] = nil					-- show combo points on nameplate	
	end
	
	if C["chat"].enable ~= true then
		C["chat"]["whispersound"] = nil               -- play a sound when receiving whisper
		C["chat"]["showbackdrop"] = nil				-- show a backdrop on the chat panels
		C["chat"]["fadeoutofuse"] = nil				-- fade chat text when out of use	
		C["chat"]["sticky"] = nil
	end
	
	if C["tooltip"].enable ~= true then
		C["tooltip"]["hidecombat"] = nil                -- hide bottom-right tooltip when in combat
		C["tooltip"]["hidecombatraid"] = nil				-- only hide in combat in a raid instance
		C["tooltip"]["hidebuttons"] = nil               -- always hide action bar buttons tooltip.
		C["tooltip"]["hideuf"] = nil                    -- hide tooltip on unitframes
		C["tooltip"]["cursor"] = nil                    -- show anchored to cursor
		C["tooltip"]["colorreaction"] = nil				-- always color border of tooltip by unit reaction
	end
	
	if C["actionbar"].enable ~= true then
		C["actionbar"]["hotkey"] = nil                     -- enable hotkey display because it was a lot requested
		C["actionbar"]["rightbarmouseover"] = nil         -- enable right bars on mouse over
		C["actionbar"]["shapeshiftmouseover"] = nil       -- enable shapeshift or totembar on mouseover
		C["actionbar"]["hideshapeshift"] = nil            -- hide shapeshift or totembar because it was a lot requested.
		C["actionbar"]["showgrid"] = nil                   -- show grid on empty button	
		C["actionbar"]["sixbuttons"] = nil  
	end
	
	if C["buffreminder"].enable ~= true then
		C["buffreminder"]["sound"] = nil
	end

	if C["datatext"].stat1 == 0 then
		C["datatext"].stat1tankstat = nil
		C["datatext"].stat1meleestat = nil
		C["datatext"].stat1casterstat = nil
	end

	if C["datatext"].stat2 == 0 then
		C["datatext"].stat2tankstat = nil
		C["datatext"].stat2meleestat = nil
		C["datatext"].stat2casterstat = nil
	end
end

--------------------------------------------------------------------
-- OTHERS
--------------------------------------------------------------------

if C["media"].glossyTexture ~= true then
	C["media"].normTex = [[Interface\AddOns\ElvUI\media\textures\normTex2]]
end