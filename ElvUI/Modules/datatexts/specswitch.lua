local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local select = select
local format, join = string.format, string.join
--WoW API / Variables
local L_EasyMenu = L_EasyMenu
local GetActiveSpecGroup = GetActiveSpecGroup
local GetLootSpecialization = GetLootSpecialization
local GetNumSpecGroups = GetNumSpecGroups
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local HideUIPanel = HideUIPanel
local IsShiftKeyDown = IsShiftKeyDown
local SetLootSpecialization = SetLootSpecialization
local SetSpecialization = SetSpecialization
local ShowUIPanel = ShowUIPanel
local LOOT = LOOT
local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION
local LOOT_SPECIALIZATION_DEFAULT = LOOT_SPECIALIZATION_DEFAULT

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: PlayerTalentFrame, LoadAddOn

local lastPanel, active
local displayString = '';
local activeString = join("", "|cff00FF00" , ACTIVE_PETS, "|r")
local inactiveString = join("", "|cffFF0000", FACTION_INACTIVE, "|r")
local menuFrame = CreateFrame("Frame", "LootSpecializationDatatextClickMenu", E.UIParent, "L_UIDropDownMenuTemplate")
local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true, func = function() SetLootSpecialization(0) end },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}
local specList = {
	{ text = SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}

local function OnEvent(self)
	lastPanel = self

	local specIndex = GetSpecialization();
	if not specIndex then
		self.text:SetText('N/A')
		return
	end

	active = GetActiveSpecGroup()

	local talent, loot = '', 'N/A'
	local i = GetSpecialization(false, false, active)
	if i then
		i = select(4, GetSpecializationInfo(i))
		if(i) then
			talent = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', i)
		end
	end

	local specialization = GetLootSpecialization()
	if specialization == 0 then
		local specIndex = GetSpecialization();

		if specIndex then
			local _, _, _, texture = GetSpecializationInfo(specIndex);
			if texture then
				loot = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture)
			end
		end
	else
		local _, _, _, texture = GetSpecializationInfoByID(specialization);
		if texture then
			loot = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', texture)
		end
	end

	self.text:SetFormattedText('%s: %s %s: %s', L["Spec"], talent, LOOT, loot)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	for i = 1, GetNumSpecGroups() do
		if GetSpecialization(false, false, i) then
			DT.tooltip:AddLine(join(" ", format(displayString, select(2, GetSpecializationInfo(GetSpecialization(false, false, i)))), (i == active and activeString or inactiveString)),1,1,1)
		end
	end

	DT.tooltip:AddLine(' ')
	local specialization = GetLootSpecialization()
	if specialization == 0 then
		local specIndex = GetSpecialization();

		if specIndex then
			local _, name = GetSpecializationInfo(specIndex);
			DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, format(LOOT_SPECIALIZATION_DEFAULT, name)))
		end
	else
		local specID, name = GetSpecializationInfoByID(specialization);
		if specID then
			DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', SELECT_LOOT_SPECIALIZATION, name))
		end
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["|cffFFFFFFLeft Click:|r Change Talent Specialization"])
	DT.tooltip:AddLine(L["|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI"])
	DT.tooltip:AddLine(L["|cffFFFFFFRight Click:|r Change Loot Specialization"])

	DT.tooltip:Show()
end

local function OnClick(self, button)
	local specIndex = GetSpecialization();
	if not specIndex then return end

	if button == "LeftButton" then
		DT.tooltip:Hide()
		if not PlayerTalentFrame then
			LoadAddOn("Blizzard_TalentUI")
		end
		if IsShiftKeyDown() then
			if not PlayerTalentFrame:IsShown() then
				ShowUIPanel(PlayerTalentFrame)
			else
				HideUIPanel(PlayerTalentFrame)
			end
		else
			for index = 1, 4 do
				local id, name, _, texture = GetSpecializationInfo(index);
				if ( id ) then
					specList[index + 1].text = format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', texture, name)
					specList[index + 1].func = function() SetSpecialization(index) end
				else
					specList[index + 1] = nil
				end
			end
			L_EasyMenu(specList, menuFrame, "cursor", -15, -7, "MENU", 2)
		end
	else
		DT.tooltip:Hide()
		local _, specName = GetSpecializationInfo(specIndex);
		menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName);

		for index = 1, 4 do
			local id, name = GetSpecializationInfo(index);
			if ( id ) then
				menuList[index + 2].text = name
				menuList[index + 2].func = function() SetLootSpecialization(id) end
			else
				menuList[index + 2] = nil
			end
		end

		L_EasyMenu(menuList, menuFrame, "cursor", -15, -7, "MENU", 2)
	end
end

local function ValueColorUpdate()
	displayString = join("", "|cffFFFFFF%s:|r ")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Talent/Loot Specialization',{"PLAYER_ENTERING_WORLD", "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE", "ACTIVE_TALENT_GROUP_CHANGED", 'PLAYER_LOOT_SPEC_UPDATED'}, OnEvent, nil, OnClick, OnEnter, nil, L["Talent/Loot Specialization"])
