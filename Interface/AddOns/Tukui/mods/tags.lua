if not TukuiUF == true then return end

oUF.TagEvents['[DiffColor]'] = 'UNIT_LEVEL'
if (not oUF.Tags['[DiffColor]']) then
	oUF.Tags['[DiffColor]']  = function(unit)
		local r, g, b
		local level = UnitLevel(unit)
		if (level < 1) then
			r, g, b = 0.69, 0.31, 0.31
		else
			local DiffColor = UnitLevel('target') - UnitLevel('player')
			if (DiffColor >= 5) then
				r, g, b = 0.69, 0.31, 0.31
			elseif (DiffColor >= 3) then
				r, g, b = 0.71, 0.43, 0.27
			elseif (DiffColor >= -2) then
				r, g, b = 0.84, 0.75, 0.65
			elseif (-DiffColor <= GetQuestGreenRange()) then
				r, g, b = 0.33, 0.59, 0.33
			else
				r, g, b = 0.55, 0.57, 0.61
			end
		end
		return string.format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
	end
end

local colors = setmetatable({
	happiness = setmetatable({
		[1] = {.69,.31,.31},
		[2] = {.65,.63,.35},
		[3] = {.33,.59,.33},
	}, {__index = oUF.colors.happiness}),
}, {__index = oUF.colors})

oUF.TagEvents['[GetNameColor]'] = 'UNIT_HAPPINESS'
if (not oUF.Tags['[GetNameColor]']) then
	oUF.Tags['[GetNameColor]'] = function(unit)
		local reaction = UnitReaction(unit, 'player')
		if (unit == 'pet' and GetPetHappiness()) then
			local c = colors.happiness[GetPetHappiness()]
			return string.format('|cff%02x%02x%02x', c[1] * 255, c[2] * 255, c[3] * 255)
		elseif (UnitIsPlayer(unit)) then
			return oUF.Tags['[raidcolor]'](unit)
		elseif (reaction) then
			local c =  colors.reaction[reaction]
			return string.format('|cff%02x%02x%02x', c[1] * 255, c[2] * 255, c[3] * 255)
		else
			r, g, b = .84,.75,.65
			return string.format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
		end
	end
end

local utf8sub = function(string, i, dots)
	local bytes = string:len()
	if (bytes <= i) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 192 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if (len == i) then break end
		end

		if (len == i and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and '...' or '')
		else
			return string
		end
	end
end

oUF.TagEvents['[NameShort]'] = 'UNIT_NAME_UPDATE'
if (not oUF.Tags['[NameShort]']) then
	oUF.Tags['[NameShort]'] = function(unit)
		local name = UnitName(unit)
		return utf8sub(name, 10, false)
	end
end

oUF.TagEvents['[NameMedium]'] = 'UNIT_NAME_UPDATE'
if (not oUF.Tags['[NameMedium]']) then
	oUF.Tags['[NameMedium]'] = function(unit)
		local name = UnitName(unit)
		if (unit == 'pet' and name == 'Unknown') then
			return 'Pet'
		else
			return utf8sub(name, 18, true)
		end
	end
end

oUF.TagEvents['[NameLong]'] = 'UNIT_NAME_UPDATE'
if (not oUF.Tags['[NameLong]']) then
	oUF.Tags['[NameLong]'] = function(unit)

			local name = UnitName(unit)
			return utf8sub(name, 36, true)

	end
end

-- menu

local menu = CreateFrame("Frame", "oUF_Tukz_DropDown")
menu:RegisterEvent('PARTY_LOOT_METHOD_CHANGED')
menu.displayMode = 'MENU'
menu.info = {}

local loot = {
	freeforall = 'Free for All',
	group = '|cff1eff00Group Loot|r',
	master = '|cff0070ddMaster Loot|r',
}

local globalloot = {
	needbeforegreed = 'Loot: %sNeed & Greed|r',
	freeforall = 'Loot: %sFree for All|r',
	group = 'Loot: %sGroup Loot|r',
	master = 'Loot: %sMaster Loot|r',
}

local party = {
	'5 |cffffff50Normal|r',
	'5 |cffff5050Heroic|r'
}

local raid = {
	'10 |cffffff50Normal|r',
	'25 |cffffff50Normal|r',
	'10 |cffff5050Heroic|r',
	'25 |cffff5050Heroic|r'
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





