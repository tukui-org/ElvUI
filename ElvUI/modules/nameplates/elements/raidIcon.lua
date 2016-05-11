local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')

function mod:UpdateElement_RaidIcon(frame)
	local icon = frame.RaidIcon;
	local index = GetRaidTargetIndex(frame.unit);
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