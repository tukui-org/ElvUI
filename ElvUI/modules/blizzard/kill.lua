local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard');

function B:KillBlizzard()
	HelpOpenTicketButtonTutorial:Kill()
	TalentMicroButtonAlert:Kill()
	HelpPlate:Kill()
	HelpPlateTooltip:Kill()
	CompanionsMicroButtonAlert:Kill()
end