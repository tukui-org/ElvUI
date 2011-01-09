local parent, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

local enableTargetUpdate = Private.enableTargetUpdate

local HandleFrame = function(baseName)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame.Show = frame.Hide
		frame:Hide()

		local health = frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit, object)
	if(not unit) then return end

	local baseName
	if(unit == 'player') then
		HandleFrame(PlayerFrame)

		-- For the damn vehicle support:
		PlayerFrame:RegisterEvent('UNIT_ENTERING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_ENTERED_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITED_VEHICLE')
	elseif(unit == 'pet') then
		baseName = PetFrame
	elseif(unit == 'target') then
		if(object) then
			object:RegisterEvent('PLAYER_TARGET_CHANGED', object.UpdateAllElements)
		end

		HandleFrame(TargetFrame)
		return HandleFrame(ComboFrame)
	elseif(unit == 'mouseover') then
		if(object) then
			return object:RegisterEvent('UPDATE_MOUSEOVER_UNIT', object.UpdateAllElements)
		end
	elseif(unit == 'focus') then
		if(object) then
			object:RegisterEvent('PLAYER_FOCUS_CHANGED', object.UpdateAllElements)
		end

		HandleFrame(FocusFrame)
		HandleFrame(TargetofFocusFrame)
	elseif(unit:match'%w+target') then
		if(unit == 'targettarget') then
			baseName = TargetFrameToT
		end

		enableTargetUpdate(object)
	elseif(unit:match'(boss)%d?$' == 'boss') then
		local id = unit:match'boss(%d)'
		if(id) then
			baseName = 'Boss' .. id .. 'TargetFrame'
		else
			for i=1, 3 do
				HandleFrame(('Boss%dTargetFrame'):format(i))
			end
		end
	elseif(unit:match'(party)%d?$' == 'party') then
		local id = unit:match'party(%d)'
		if(id) then
			baseName = 'PartyMemberFrame' .. id
		else
			for i=1, 4 do
				HandleFrame(('PartyMemberFrame%d'):format(i))
			end
		end
	end

	if(baseName) then
		return HandleFrame(baseName)
	end
end
