local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local enableTargetUpdate = Private.enableTargetUpdate

-- Handles unit specific actions.
function oUF:HandleUnit(object, unit)
	local unit = object.unit or unit

	if(unit == 'target') then
		object:RegisterEvent('PLAYER_TARGET_CHANGED', object.UpdateAllElements)
	elseif(unit == 'mouseover') then
		object:RegisterEvent('UPDATE_MOUSEOVER_UNIT', object.UpdateAllElements)
	elseif(unit == 'focus') then
		object:RegisterEvent('PLAYER_FOCUS_CHANGED', object.UpdateAllElements)
	elseif(unit:match('boss%d?$')) then
		object:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT', object.UpdateAllElements, true)
		object:RegisterEvent('UNIT_TARGETABLE_CHANGED', object.UpdateAllElements)
	elseif(unit:match('arena%d?$')) then
		object:RegisterEvent('ARENA_OPPONENT_UPDATE', object.UpdateAllElements)
	elseif(unit:match('%w+target')) then
		enableTargetUpdate(object)
	end
end
