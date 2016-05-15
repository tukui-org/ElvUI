local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local mod = E:GetModule('NamePlates')
local LSM = LibStub("LibSharedMedia-3.0")


function mod:UpdateElement_Glow(frame)
	if(not frame.HealthBar:IsShown()) then return end
	local r, g, b, shouldShow;
	if ( UnitIsUnit(frame.unit, "target") ) then
		r, g, b = 1, 1, 1
		shouldShow = true
	elseif(frame.UnitType == "ENEMY_NPC") then
		-- Use color based on the type of unit (neutral, etc.)
		local isTanking, status = UnitDetailedThreatSituation("player", frame.unit)
		if status then
			if(isTanking) then
				if(E:GetPlayerRole() == "TANK") then
					r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
				else
					r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
				end
			else
				if(E:GetPlayerRole() == "TANK") then
					r, g, b = self.db.threat.badColor.r, self.db.threat.badColor.g, self.db.threat.badColor.b
				else
					r, g, b = self.db.threat.goodColor.r, self.db.threat.goodColor.g, self.db.threat.goodColor.b
				end
			end
			shouldShow = true
		end
	end

	if(shouldShow) then
		frame.Glow:Show()
		if ( (r ~= frame.Glow.r or g ~= frame.Glow.g or b ~= frame.Glow.b) ) then
			frame.Glow:SetBackdropBorderColor(r, g, b);
			frame.Glow.r, frame.Glow.g, frame.Glow.b = r, g, b;
		end
		frame.Glow:SetOutside(frame.HealthBar, 3 + mod.mult, 3 + mod.mult, frame.PowerBar:IsShown() and frame.PowerBar)
	elseif(frame.Glow:IsShown()) then
		frame.Glow:Hide()
	end
	
end

function mod:ConfigureElement_Glow(frame)
	frame.Glow:SetFrameLevel(0)
	frame.Glow:SetFrameStrata("BACKGROUND")
	frame.Glow:SetOutside(frame.HealthBar, 3 + mod.mult, 3 + mod.mult, frame.PowerBar:IsShown() and frame.PowerBar)
	frame.Glow:SetBackdrop( {
		edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(3),
		insets = {left = E:Scale(5), right = E:Scale(5), top = E:Scale(5), bottom = E:Scale(5)},
	})
	frame.Glow:SetBackdropBorderColor(0, 0, 0)
end

function mod:ConstructElement_Glow(frame)
	return CreateFrame("Frame", nil, frame)
end