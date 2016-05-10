local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

function mod:UpdateElement_Level(frame)
	local level = UnitLevel(frame.unit)
	
	if(level == -1 or not level) then
		frame.Level:SetText('??')
		frame.Level:SetTextColor(0.9, 0, 0)	
	else
		local color = GetQuestDifficultyColor(level)
		frame.Level:SetText(level)
		frame.Level:SetTextColor(color.r, color.g, color.b)
	end
end

function mod:ConfigureElement_Level(frame)
	local level = frame.Level
	
	level:SetJustifyH("RIGHT")
	level:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, 2)
	level:SetFont(LSM:Fetch("font", self.db.font), self.db.fontSize, self.db.fontOutline)
end

function mod:ConstructElement_Level(frame)
	return frame:CreateFontString(nil, "OVERLAY")
end