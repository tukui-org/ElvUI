local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")

--Cache global variables
--Lua functions
--WoW API / Variables
local UnitClassification = UnitClassification

function mod:UpdateElement_Elite(frame)
	local icon = frame.Elite
	local c = UnitClassification(frame.unit)
	if c == 'elite' or c == "worldboss" then
		icon:SetTexCoord(0,0.15,0.35,0.63)
		icon:Show()
	elseif c == 'rareelite' then
		icon:SetTexCoord(0,0.15,0.63,0.91)
		icon:Show()
	else
		icon:Hide()
	end
end

function mod:ConfigureElement_Elite(frame)
	local icon = frame.Elite
	local size = self.db.units[frame.UnitType].healthbar.height + 10
	icon:SetSize(size,size)
	icon:SetPoint("RIGHT", frame.HealthBar, "RIGHT")
end

function mod:ConstructElement_Elite(parent)
	local icon = parent.HealthBar:CreateTexture(nil, "OVERLAY")
	icon:SetTexture("Interface\\TARGETINGFRAME\\Nameplates")
	icon:Hide()

	return icon
end