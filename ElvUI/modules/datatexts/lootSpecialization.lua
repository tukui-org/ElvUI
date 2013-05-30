local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')


local join 			= string.join
local format		= string.format

local menuFrame = CreateFrame("Frame", "LootSpecializationDatatextClickMenu", E.UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
	{ notCheckable = true, func = function() SetLootSpecialization(0) end },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true },
	{ notCheckable = true }
}


local function OnEvent(self, event, ...)
	local specialization = GetLootSpecialization()

	if specialization == 0 then
		local specIndex = GetSpecialization();
		
		if specIndex then
			local specID, specName = GetSpecializationInfo(specIndex);
			self.text:SetText(format('%s **', specName))
		else
			self.text:SetText('N/A')
		end
		
	else
		local specID, specName = GetSpecializationInfoByID(specialization);
		if specID then
			self.text:SetText(specName)
		else
			self.text:SetText('N/A')
		end
	end
end

local function OnClick(self, btn)
	local specIndex = GetSpecialization();
	if not specIndex then return end

	local specID, specName = GetSpecializationInfo(specIndex);
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

	EasyMenu(menuList, menuFrame, "cursor", -15, -7, "MENU", 2)
end

DT:RegisterDatatext('Loot Specialization', {'PLAYER_LOOT_SPEC_UPDATED', 'PLAYER_SPECIALIZATION_CHANGED'}, OnEvent, nil, OnClick)

