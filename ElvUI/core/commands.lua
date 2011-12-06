local E, L, DF = unpack(select(2, ...)); --Engine

function E:LoadCommands()
	self:RegisterChatCommand("ec", "ToggleConfig")
	self:RegisterChatCommand("elvui", "ToggleConfig")
	
	self:RegisterChatCommand("moveui", "MoveUI")
	self:RegisterChatCommand("resetui", "ResetUI")
	
	if E.ActionBars then
		self:RegisterChatCommand('kb', E.ActionBars.ActivateBindMode)
	end
end

-- Testui Command
local testui = TestUI or function() end
TestUI = function(msg)
	if msg == "a" or msg == "arena" then
			ElvUF_Arena1:Show(); ElvUF_Arena1.Hide = function() end; ElvUF_Arena1.unit = "player"
			ElvUF_Arena2:Show(); ElvUF_Arena2.Hide = function() end; ElvUF_Arena2.unit = "player"
			ElvUF_Arena3:Show(); ElvUF_Arena3.Hide = function() end; ElvUF_Arena3.unit = "player"
			ElvUF_Arena4:Show(); ElvUF_Arena4.Hide = function() end; ElvUF_Arena4.unit = "player"
	elseif msg == "boss" or msg == "b" then
			ElvUF_Boss1:Show(); ElvUF_Boss1.Hide = function() end; ElvUF_Boss1.unit = "player"
			ElvUF_Boss2:Show(); ElvUF_Boss2.Hide = function() end; ElvUF_Boss2.unit = "player"
			ElvUF_Boss3:Show(); ElvUF_Boss3.Hide = function() end; ElvUF_Boss3.unit = "player"
			ElvUF_Boss4:Show(); ElvUF_Boss4.Hide = function() end; ElvUF_Boss4.unit = "player"
	elseif msg == "buffs" then -- better dont test it ^^
		UnitAura = function()
			-- name, rank, texture, count, dtype, duration, timeLeft, caster
			return 139, 'Rank 1', 'Interface\\Icons\\Spell_Holy_Penance', 1, 'Magic', 0, 0, "player"
		end
		if(oUF) then
			for i, v in pairs(oUF.units) do
				if(v.UNIT_AURA) then
					v:UNIT_AURA("UNIT_AURA", v.unit)
				end
			end
		end
	end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"