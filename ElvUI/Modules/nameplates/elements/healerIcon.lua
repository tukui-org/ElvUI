local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')

--Cache global variables
--Lua functions
--WoW API / Variables
local UnitName = UnitName

function mod:UpdateElement_HealerIcon(frame)
	local icon = frame.HealerIcon;
	local name = UnitName(frame.unit)
	icon:ClearAllPoints()
	if(frame.HealthBar:IsShown()) then
		icon:SetPoint("RIGHT", frame.HealthBar, "LEFT", -6, 0)
	else
		icon:SetPoint("BOTTOM", frame.Name, "TOP", 0, 3)
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
	texture:SetTexture([[Interface\AddOns\ElvUI\media\textures\healer.tga]])
	texture:Hide()

	return texture
end