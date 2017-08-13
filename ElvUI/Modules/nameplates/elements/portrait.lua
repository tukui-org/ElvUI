local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame

function mod:UpdateElement_Portrait(frame)
	if not (self.db.units[frame.UnitType].portrait and self.db.units[frame.UnitType].portrait.enable) then
		return;
	end

	
	if(not UnitExists(frame.unit) or not UnitIsConnected(frame.unit) or not UnitIsVisible(frame.unit)) then
		--frame.Portrait:SetUnit("")
		frame.Portrait:SetTexture("")
	else
		--frame.Portrait:SetUnit(frame.unit)
		SetPortraitTexture(frame.Portrait, frame.unit)
	end
end

function mod:ConfigureElement_Portrait(frame)
	if not (self.db.units[frame.UnitType].portrait and self.db.units[frame.UnitType].portrait.enable) then
		return;
	end

	frame.Portrait:ClearAllPoints()
	frame.Portrait:Point("LEFT", frame.TopLevelFrame or frame, "RIGHT", 5, 0)
end

function mod:ConstructElement_Portrait(frame)
	--[[local model = CreateFrame("PlayerModel", nil, frame)
	model:Size(75, 75)
	model:Point("BOTTOM", frame, "TOP", 0, 0)
	model:SetFrameStrata("LOW") 


	return model]]

	local texture = frame:CreateTexture(nil, "OVERLAY")
	texture:Size(40, 40)
	texture:Point("CENTER")
	texture:SetTexCoord(.18, .82, .18, .82)
	return texture
end