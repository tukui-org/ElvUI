local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')

--Cache global variables
--Lua functions
--WoW API / Variables
local UnitName = UnitName
local gsub = gsub

function mod:UpdateElement_HealerIcon(frame)
	if (self.db.units[frame.UnitType].enable == false) then
		return;
	end

	local name, realm = UnitName(frame.unit);
	realm = (realm and realm ~= '') and gsub(realm,'[%s%-]','')
	if realm then name = name.."-"..realm end

	local icon = frame.HealerIcon;
	local healthShown = frame.HealthBar:IsShown();
	local portraitShown = frame.Portrait:IsShown();
	icon:ClearAllPoints()
	if healthShown and portraitShown then
		icon:SetPoint("RIGHT", frame.Portrait, "LEFT", -6, 0);
	elseif healthShown then
		icon:SetPoint("RIGHT", frame.HealthBar, "LEFT", -6, 0);
	elseif portraitShown then
		icon:SetPoint("BOTTOM", frame.Portrait, "TOP", 0, 3);
	else
		icon:SetPoint("BOTTOM", frame.Name, "TOP", 0, 3);
	end

	if mod.Healers[name] and frame.UnitType == "ENEMY_PLAYER" then
		icon:Show();
	else
		icon:Hide();
	end
end

function mod:ConstructElement_HealerIcon(frame)
	local texture = frame:CreateTexture(nil, "OVERLAY")
	texture:SetPoint("RIGHT", frame.HealthBar, "LEFT", -6, 0)
	texture:SetSize(40, 40)
	texture:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer]])
	texture:Hide()

	return texture
end
