local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')

--Cache global variables
--Lua functions
--WoW API / Variables
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture

function mod:UpdateElement_RaidIcon(frame)
	if (self.db.units[frame.UnitType].enable == false) then
		return;
	end

	local icon = frame.RaidIcon;
	local index = GetRaidTargetIndex(frame.unit);
	icon:ClearAllPoints()
	if(frame.Portrait:IsShown()) then
		icon:SetPoint("RIGHT", frame.Portrait, "LEFT", -6, 0)
	elseif(frame.HealthBar:IsShown()) then
		icon:SetPoint("RIGHT", frame.HealthBar, "LEFT", -6, 0)
	else
		icon:SetPoint("BOTTOM", frame.Name, "TOP", 0, 3)
	end

	if ( index ) then
		SetRaidTargetIconTexture(icon, index);
		icon:Show();
	else
		icon:Hide();
	end
end

function mod:ConstructElement_RaidIcon(frame)
	local texture = frame:CreateTexture(nil, "OVERLAY")
	texture:SetPoint("RIGHT", frame.HealthBar, "LEFT", -6, 0)
	texture:SetSize(40, 40)
	texture:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	texture:Hide()

	return texture
end
