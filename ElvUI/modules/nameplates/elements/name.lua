local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

function mod:UpdateElement_Name(frame)
	local name, realm = UnitName(frame.unit)

	frame.Name:SetText(name)
	if(frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "ENEMY_PLAYER") then
		local _, class = UnitClass(frame.unit)
		local color = RAID_CLASS_COLORS[class]
		if(class and color) then
			frame.Name:SetTextColor(color.r, color.g, color.b)
		end
	elseif(not self.db.units[frame.UnitType].healthbar.enable) then
		local reactionType = UnitReaction(frame.unit, "player")
		local r, g, b
		if(reactionType == 4) then
			r, g, b = self.db.reactions.neutral.r, self.db.reactions.neutral.g, self.db.reactions.neutral.b
		elseif(reactionType > 4) then
			r, g, b = self.db.reactions.good.r, self.db.reactions.good.g, self.db.reactions.good.b
		else
			r, g, b = self.db.reactions.bad.r, self.db.reactions.bad.g, self.db.reactions.bad.b
		end	
		
		frame.Name:SetTextColor(r, g, b)
	else
		frame.Name:SetTextColor(1, 1, 1)
	end
end

function mod:ConfigureElement_Name(frame)
	local name = frame.Name
	
	name:SetJustifyH("LEFT")
	name:ClearAllPoints()
	if(self.db.units[frame.UnitType].healthbar.enable) then
		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 2)
		name:SetPoint("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT")
	else
		name:SetJustifyH("CENTER")
		name:SetPoint("TOP", frame, "CENTER")
	end
	
	name:SetFont([[Interface\AddOns\ElvUI\media\fonts\Homespun.ttf]], 10, "MONOCHROMEOUTLINE")
end

function mod:ConstructElement_Name(frame)
	return frame:CreateFontString(nil, "OVERLAY")
end