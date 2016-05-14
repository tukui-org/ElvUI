local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")


function mod:UpdateElement_MaxPower(frame)
	local maxValue = UnitPowerMax("player", frame.PowerToken);
	frame.PowerBar:SetMinMaxValues(0, maxValue);
end

function mod:UpdateElement_Power(frame)
	self:UpdateElement_MaxPower(frame)
	
	local curValue = UnitPower(frame.unit, frame.PowerToken);
	frame.PowerBar:SetValue(curValue);	

	local color = E.db.unitframe.colors.power[frame.PowerToken] or PowerBarColor[frame.PowerToken]
	frame.PowerBar:SetStatusBarColor(color.r, color.g, color.b)
end 

function mod:ConfigureElement_PowerBar(frame)
	local powerBar = frame.PowerBar
	powerBar:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, -3)
	powerBar:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, -3)
	powerBar:SetHeight(self.db.castbar.height)
	powerBar:SetStatusBarTexture(LSM:Fetch("statusbar", self.db.statusbar))
end


function mod:ConstructElement_PowerBar(parent)
	local frame = CreateFrame("StatusBar", "$parentPowerBar", parent)
	self:StyleFrame(frame, true)
	frame:Hide()

	return frame
end