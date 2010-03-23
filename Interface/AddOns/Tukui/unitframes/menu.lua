local menu = CreateFrame("Frame", "oUF_Tukz_DropDown")
menu:RegisterEvent('PARTY_LOOT_METHOD_CHANGED')
menu.displayMode = 'MENU'
menu.info = {}

local loot = {
	freeforall = tukuilocal.playermenu_freeforall,
	group = tukuilocal.playermenu_group,
	master = tukuilocal.playermenu_master,
}

local globalloot = {
	needbeforegreed = tukuilocal.playermenu_global_needbeforegreed,
	freeforall = tukuilocal.playermenu_global_freeforall,
	group = tukuilocal.playermenu_global_group,
	master = tukuilocal.playermenu_global_master,
}

local party = {
	tukuilocal.playermenu_normal,
	tukuilocal.playermenu_heroic
}

local raid = {
	tukuilocal.playermenu_raid10,
	tukuilocal.playermenu_raid25,
	tukuilocal.playermenu_raid10h,
	tukuilocal.playermenu_raid25h
}

local function onEvent()
	if(CanGroupInvite() and GetLootMethod() ~= 'freeforall') then
		SetLootThreshold(GetLootMethod() == 'master' and 3 or 2)
	end
end

local function initialize(self, level)
	local info = self.info

	if(level == 1) then
		if(GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) then
			wipe(info)
			info.text = string.format(globalloot[GetLootMethod()], select(4, GetItemQualityColor(GetOptOutOfLoot() and 0 or GetLootThreshold())))
			info.notCheckable = 1
			info.func = function() if(IsShiftKeyDown()) then SetOptOutOfLoot(not GetOptOutOfLoot()) end end
			info.value = CanGroupInvite() and 'loot'
			info.hasArrow = CanGroupInvite() and 1
			UIDropDownMenu_AddButton(info, level)
		end

		wipe(info)
		info.text = string.format('Difficulty: %s', UnitInRaid('player') and raid[GetRaidDifficulty()] or party[GetDungeonDifficulty()])
		info.notCheckable = 1
		info.value = CanGroupInvite() and 'difficulty'
		info.hasArrow = CanGroupInvite() and 1
		UIDropDownMenu_AddButton(info, level)

		if(CanGroupInvite()) then
			wipe(info)
			info.text = RESET_INSTANCES
			info.notCheckable = 1
			info.func = function() ResetInstances() end
			UIDropDownMenu_AddButton(info, level)
		end

		if(GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) then
			wipe(info)
			info.text = PARTY_LEAVE
			info.notCheckable = 1
			info.func = function() LeaveParty() end
			UIDropDownMenu_AddButton(info, level)
		end

		if ( IsInLFGDungeon() ) then
			wipe(info)
			info.text = TELEPORT_OUT_OF_DUNGEON
			info.notCheckable = 1
			info.func = MiniMapLFGFrame_TeleportOut
			UIDropDownMenu_AddButton(info, level)
		elseif ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) then
			wipe(info)
			info.text = TELEPORT_TO_DUNGEON
			info.notCheckable = 1
			info.func = MiniMapLFGFrame_TeleportIn
			UIDropDownMenu_AddButton(info, level)
		end

	elseif(level == 2) then
		if(UIDROPDOWNMENU_MENU_VALUE == 'loot') then
			wipe(info)

			for k, v in next, loot do
				info.text = v
				info.func = function() SetLootMethod(k, UnitName('player')) end
				UIDropDownMenu_AddButton(info, level)
			end
		elseif(UIDROPDOWNMENU_MENU_VALUE == 'difficulty') then
			wipe(info)

			if(UnitInRaid('player')) then
				for k, v in next, raid do
					info.text = v
					info.func = function() SetRaidDifficulty(k) end
					UIDropDownMenu_AddButton(info, level)
				end
			else
				for k, v in next, party do
					info.text = v
					info.func = function() SetDungeonDifficulty(k) end
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end
	end
end

menu:SetScript('OnEvent', onEvent)
menu.initialize = initialize