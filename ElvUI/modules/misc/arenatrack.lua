
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if C["arena"].spelltracker ~= true then return end

tCooldownTracker = CreateFrame("frame")
tCooldownTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
tCooldownTracker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ElvuiArena = { ["x"] = 677, ["y"] = 383, ["orientation"] = "VERTICALUP" }
tCooldownTracker.Orientations = { 
	["HORIZONTALRIGHT"] = { ["point"] = "TOPLEFT", ["rpoint"] = "TOPRIGHT", ["x"] = 3, ["y"] = 0 },
	["HORIZONTALLEFT"] = { ["point"] = "TOPRIGHT", ["rpoint"] = "TOPLEFT", ["x"] = -3, ["y"] = 0 }, 
	["VERTICALDOWN"] = { ["point"] = "TOPLEFT", ["rpoint"] = "BOTTOMLEFT", ["x"] = 0, ["y"] = -3 },
	["VERTICALUP"] = { ["point"] = "BOTTOMLEFT", ["rpoint"] = "TOPLEFT", ["x"] = 0, ["y"] = 3 }, 
}

------------------------------------------------------------
-- spell configuration
------------------------------------------------------------

tCooldownTracker.Spells = E.spelltracker

------------------------------------------------------------
-- end of spell configuration
------------------------------------------------------------

SlashCmdList["tCooldownTracker"] = function(msg) tCooldownTracker.SlashHandler(msg) end
SLASH_tCooldownTracker1 = "/tcdt"
SLASH_tCooldownTracker2 = "/tracker"
tCooldownTracker:SetScript("OnEvent", function(self, event, ...) tCooldownTracker[event](...) end)

tCooldownTracker.Icons = { }

function tCooldownTracker.CreateIcon()
	local i = (#tCooldownTracker.Icons)+1
   
	tCooldownTracker.Icons[i] = CreateFrame("frame","tCooldownTrackerIcon"..i,UIParent)
	tCooldownTracker.Icons[i]:SetHeight(E.Scale(28))
	tCooldownTracker.Icons[i]:SetWidth(E.Scale(28))
	tCooldownTracker.Icons[i]:SetFrameStrata("BACKGROUND")
	tCooldownTracker.Icons[i]:SetFrameLevel(20)
	  
	tCooldownTracker.Icons[i]:Hide()

	tCooldownTracker.Icons[i].Texture = tCooldownTracker.Icons[i]:CreateTexture(nil,"LOW")
	tCooldownTracker.Icons[i].Texture:SetTexture("Interface\\Icons\\Spell_Nature_Cyclone.blp")
	tCooldownTracker.Icons[i].Texture:SetPoint("TOPLEFT", tCooldownTracker.Icons[i], E.Scale(2), E.Scale(-2))
	tCooldownTracker.Icons[i].Texture:SetPoint("BOTTOMRIGHT", tCooldownTracker.Icons[i], E.Scale(-2), E.Scale(2))
	tCooldownTracker.Icons[i].Texture:SetTexCoord(.08, .92, .08, .92)
	
	tCooldownTracker.Icons[i]:SetTemplate("Default")

	tCooldownTracker.Icons[i].TimerText = tCooldownTracker.Icons[i]:CreateFontString("tCooldownTrackerTimerText","OVERLAY")
	tCooldownTracker.Icons[i].TimerText:SetFont(C.media.font,14,"Outline")
	tCooldownTracker.Icons[i].TimerText:SetTextColor(1,0,0)
	tCooldownTracker.Icons[i].TimerText:SetShadowColor(0,0,0)
	tCooldownTracker.Icons[i].TimerText:SetShadowOffset(E.mult,-E.mult)
	tCooldownTracker.Icons[i].TimerText:SetPoint("CENTER", tCooldownTracker.Icons[i], "CENTER",E.mult,0)
	tCooldownTracker.Icons[i].TimerText:SetText(5)
   
	return i
end

tCooldownTracker.CreateIcon()
tCooldownTracker.Icons[1]:RegisterForDrag("LeftButton")
tCooldownTracker.Icons[1]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", ElvuiArena.x, ElvuiArena.y)
tCooldownTracker.Icons[1]:SetScript("OnDragStart", function() tCooldownTracker.Icons[1]:StartMoving() end)
tCooldownTracker.Icons[1]:SetScript("OnDragStop", function() 
	tCooldownTracker.Icons[1]:StopMovingOrSizing() 
	ElvuiArena.x = math.floor(tCooldownTracker.Icons[1]:GetLeft())
	ElvuiArena.y = math.floor(tCooldownTracker.Icons[1]:GetTop())
end)

function tCooldownTracker.SlashHandler(msg)
	arg = string.upper(msg)
	if (tCooldownTracker[arg]) then
		tCooldownTracker[arg]()
	else
		tCooldownTracker.Print("Elvui Cooldown Tracker Options:")
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
	ElvuiArena.x = 677
	ElvuiArena.y = 383
	tCooldownTracker.Icons[1]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", ElvuiArena.x, ElvuiArena.y)
	tCooldownTracker.Print("Position reset successfully.")
end

function tCooldownTracker.HORIZONTALRIGHT()
	ElvuiArena.orientation = "HORIZONTALRIGHT"
	tCooldownTracker.Print("Icons will now stack horizontally to the right.")
end

function tCooldownTracker.HORIZONTALLEFT()
	ElvuiArena.orientation = "HORIZONTALLEFT"
	tCooldownTracker.Print("Icons will now stack horizontally to the left.")
end

function tCooldownTracker.VERTICALDOWN()
	ElvuiArena.orientation = "VERTICALDOWN"
	tCooldownTracker.Print("Icons will now stack vertically downwards.")
end

function tCooldownTracker.VERTICALUP()
	ElvuiArena.orientation = "VERTICALUP"
	tCooldownTracker.Print("Icons will now stack vertically upwards.")
end

function tCooldownTracker.Print(msg, ...)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF33[Elvui Cooldown Tracker]|r "..format(msg, ...))
end

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
		tCooldownTracker.Icons[(active or icon)].Texture:SetPoint("TOPLEFT", tCooldownTracker.Icons[(active or icon)], E.Scale(2), E.Scale(-2))
		tCooldownTracker.Icons[(active or icon)].Texture:SetPoint("BOTTOMRIGHT", tCooldownTracker.Icons[(active or icon)], E.Scale(-2), E.Scale(2))
		tCooldownTracker.Icons[(active or icon)].Texture:SetTexCoord(.08, .92, .08, .92)
		tCooldownTracker.Icons[(active or icon)]:SetTemplate("Default")
	end
	tCooldownTracker.Reposition()
	tCooldownTracker:SetScript("OnUpdate", function(self, arg1) tCooldownTracker.OnUpdate(arg1) end)
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
			tCooldownTracker.Icons[i]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", ElvuiArena.x, ElvuiArena.y)
		else
			tCooldownTracker.Icons[i]:SetPoint(tCooldownTracker.Orientations[ElvuiArena.orientation].point, 
				tCooldownTracker.Icons[currentactive], 
				tCooldownTracker.Orientations[ElvuiArena.orientation].rpoint, 
				tCooldownTracker.Orientations[ElvuiArena.orientation].x, 
				tCooldownTracker.Orientations[ElvuiArena.orientation].y)
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
