local E, L, DF = unpack(select(2, ...)); --Engine

function E:LoadCommands()
	self:RegisterChatCommand("ec", "ToggleConfig")
	self:RegisterChatCommand("elvui", "ToggleConfig")
	
	self:RegisterChatCommand("moveui", "MoveUI")
	self:RegisterChatCommand("resetui", "ResetUI")
end