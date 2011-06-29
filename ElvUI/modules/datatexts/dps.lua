
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


--------------------------------------------------------------------
-- SUPPORT FOR DPS Feed... 
--------------------------------------------------------------------

if C["datatext"].dps_text and C["datatext"].dps_text > 0 then
	local events = {SWING_DAMAGE = true, RANGE_DAMAGE = true, SPELL_DAMAGE = true, SPELL_PERIODIC_DAMAGE = true, DAMAGE_SHIELD = true, DAMAGE_SPLIT = true, SPELL_EXTRA_ATTACKS = true}
	local DPS_FEED = CreateFrame("Frame")
	local player_id = UnitGUID("player")
	local dmg_total, last_dmg_amount = 0, 0
	local cmbt_time = 0

	local pet_id = UnitGUID("pet")
     
	local dText = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
	dText:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
	dText:SetShadowOffset(E.mult, -E.mult)
	dText:SetShadowColor(0, 0, 0, 0.4)
	dText:SetText("DPS: "..E.ValColor.."0.0|r")
	
	E.PP(C["datatext"].dps_text, dText)
	DPS_FEED:SetParent(dText:GetParent())
	
	DPS_FEED:EnableMouse(true)
	DPS_FEED:SetFrameStrata("MEDIUM")
	DPS_FEED:SetFrameLevel(3)
	DPS_FEED:SetHeight(E.Scale(20))
	DPS_FEED:SetWidth(E.Scale(100))
	DPS_FEED:SetAllPoints(dText)

	DPS_FEED:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
	DPS_FEED:RegisterEvent("PLAYER_LOGIN")

	DPS_FEED:SetScript("OnUpdate", function(self, elap)
		if UnitAffectingCombat("player") then
			cmbt_time = cmbt_time + elap
		end
       
		dText:SetText(getDPS())
	end)
     
	function DPS_FEED:PLAYER_LOGIN()
		DPS_FEED:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		DPS_FEED:RegisterEvent("PLAYER_REGEN_ENABLED")
		DPS_FEED:RegisterEvent("PLAYER_REGEN_DISABLED")
		DPS_FEED:RegisterEvent("UNIT_PET")
		player_id = UnitGUID("player")
		DPS_FEED:UnregisterEvent("PLAYER_LOGIN")
	end
     
	function DPS_FEED:UNIT_PET(unit)
		if unit == "player" then
			pet_id = UnitGUID("pet")
		end
	end
	
	-- handler for the combat log. used http://www.wowwiki.com/API_COMBAT_LOG_EVENT for api
	function DPS_FEED:COMBAT_LOG_EVENT_UNFILTERED(...)		   
		-- filter for events we only care about. i.e heals
		if not events[select(2, ...)] then return end

		-- only use events from the player
		local id = select(4, ...)
		   
		if id == player_id or id == pet_id then
			if select(2, ...) == "SWING_DAMAGE" then
				last_dmg_amount = select(12, ...)
			else
				last_dmg_amount = select(15, ...)
			end		
			dmg_total = dmg_total + last_dmg_amount
		end       
	end
     
	function getDPS()
		if (dmg_total == 0) then
			return ("DPS: "..E.ValColor.."0.0|r")
		else
			return string.format("DPS: "..E.ValColor.."%.1f|r", (dmg_total or 0) / (cmbt_time or 1))
		end
	end

	function DPS_FEED:PLAYER_REGEN_ENABLED()
		dText:SetText(getDPS())
	end
	
	function DPS_FEED:PLAYER_REGEN_DISABLED()
		cmbt_time = 0
		dmg_total = 0
		last_dmg_amount = 0
	end
     
	DPS_FEED:SetScript("OnMouseDown", function (self, button, down)
		cmbt_time = 0
		dmg_total = 0
		last_dmg_amount = 0
	end)
end