local E, L, DF = unpack(select(2, ...)); --Engine
local M = E:NewModule('Misc', 'AceEvent-3.0');

E.Misc = M;
local UIErrorsFrame = UIErrorsFrame;

function M:ErrorFrameToggle(event)
	if event == 'PLAYER_REGEN_DISABLED' then
		UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
	else
		UIErrorsFrame:RegisterEvent('UI_ERROR_MESSAGE')
	end
end

function M:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName)
	if not (event == "SPELL_INTERRUPT" and sourceGUID == UnitGUID('player')) then return end
	
	if E.db.core.interruptAnnounce == "PARTY" then
		if GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "PARTY", nil, nil)
		end
	elseif E.db.core.interruptAnnounce == "RAID" then
		if GetRealNumRaidMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "RAID", nil, nil)		
		elseif GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "PARTY", nil, nil)
		end	
	elseif E.db.core.interruptAnnounce == "SAY" then
		if GetRealNumRaidMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "SAY", nil, nil)		
		elseif GetRealNumPartyMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", "SAY", nil, nil)
		end		
	end
end

function M:Initialize()
	self:LoadRaidMarker()
	self:LoadExpRepBar()
	self:LoadMirrorBars()
	self:LoadLoot()
	self:LoadLootRoll()
	self:RegisterEvent('PLAYER_REGEN_DISABLED', 'ErrorFrameToggle')
	self:RegisterEvent('PLAYER_REGEN_ENABLED', 'ErrorFrameToggle')
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

E:RegisterModule(M:GetName())