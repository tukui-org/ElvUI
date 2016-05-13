local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

function mod:UpdateElement_Name(frame)
	local name, realm = UnitName(frame.unit)

	frame.Name:SetText(name)
	if(frame.IsFriendlyPlayer) then
		local _, class = UnitClass(frame.unit)
		local color = RAID_CLASS_COLORS[class]
		if(class and color) then
			frame.Name:SetTextColor(color.r, color.g, color.b)
		end
	elseif(frame.IsEnemyPlayer) then
		frame.Name:SetTextColor(0.9, 0.05, 0.05)
	else
		frame.Name:SetTextColor(1, 1, 1)
	end
end

function mod:ConfigureElement_Name(frame)
	local name = frame.Name
	
	name:SetJustifyH("LEFT")
	name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 2)
	name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT")
	name:SetFont([[Interface\AddOns\ElvUI\media\fonts\Homespun.ttf]], 10, "MONOCHROMEOUTLINE")
end

function mod:ConstructElement_Name(frame)
	return frame:CreateFontString(nil, "OVERLAY")
end