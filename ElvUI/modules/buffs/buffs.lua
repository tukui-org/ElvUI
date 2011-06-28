
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

ConsolidatedBuffs:ClearAllPoints()
ConsolidatedBuffs:SetPoint("LEFT", Minimap, "LEFT", E.Scale(0), E.Scale(0))
ConsolidatedBuffs:SetSize(16, 16)
ConsolidatedBuffsIcon:SetTexture(nil)
ConsolidatedBuffs.SetPoint = E.dummy

if C["others"].minimapauras ~= true then BuffFrame:Kill() ConsolidatedBuffs:Kill() return end

local mainhand, _, _, offhand = GetWeaponEnchantInfo()
local rowbuffs = 12
local warningtime = 6

--Holder frame for mover
local holder = CreateFrame("Frame", "AurasHolder", E.UIParent)
holder:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", E.Scale(-8), E.Scale(2))
holder:SetWidth(E.Scale(456)) --(30 + 8) * 12)
holder:SetHeight(ElvuiMinimap:GetHeight() + E.Scale(3 + 19))

local btnspace = E.Scale(-4)
local aurapos = "RIGHT"

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)

TempEnchant1:ClearAllPoints()
TempEnchant2:ClearAllPoints()
TempEnchant1:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)
TempEnchant2:SetPoint("RIGHT", TempEnchant1, "LEFT", E.Scale(-4), 0)

for i = 1, 3 do
	local f = CreateFrame("Frame", nil, _G["TempEnchant"..i])
	f:CreatePanel("Default", 30, 30, "CENTER", _G["TempEnchant"..i], "CENTER", 0, 0)	
	_G["TempEnchant"..i.."Border"]:Hide()
	_G["TempEnchant"..i.."Icon"]:SetTexCoord(.08, .92, .08, .92)
	_G["TempEnchant"..i.."Icon"]:SetPoint("TOPLEFT", _G["TempEnchant"..i], E.Scale(2), E.Scale(-2))
	_G["TempEnchant"..i.."Icon"]:SetPoint("BOTTOMRIGHT", _G["TempEnchant"..i], E.Scale(-2), E.Scale(2))
	_G["TempEnchant"..i]:SetHeight(E.Scale(30))
	_G["TempEnchant"..i]:SetWidth(E.Scale(30))	
	_G["TempEnchant"..i.."Duration"]:ClearAllPoints()
	_G["TempEnchant"..i.."Duration"]:SetPoint("BOTTOM", 0, E.Scale(-13))
	_G["TempEnchant"..i.."Duration"]:SetFont(C["media"].font, C["general"].fontscale, "THINOUTLINE")
end

local function StyleBuffs(buttonName, index, debuff)
	local buff		= _G[buttonName..index]
	local icon		= _G[buttonName..index.."Icon"]
	local border	= _G[buttonName..index.."Border"]
	local duration	= _G[buttonName..index.."Duration"]
	local count 	= _G[buttonName..index.."Count"]
	if icon and not _G[buttonName..index.."Panel"] then
		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetPoint("TOPLEFT", buff, E.Scale(2), E.Scale(-2))
		icon:SetPoint("BOTTOMRIGHT", buff, E.Scale(-2), E.Scale(2))
		
		buff:SetHeight(E.Scale(30))
		buff:SetWidth(E.Scale(30))
				
		duration:ClearAllPoints()
		duration:SetPoint("BOTTOM", 0, E.Scale(-13))
		duration:SetFont(C["media"].font, C["general"].fontscale, "THINOUTLINE")
		duration:SetShadowColor(0,0,0,0)
		
		count:ClearAllPoints()
		count:SetPoint("TOPLEFT", E.Scale(1), E.Scale(-2))
		count:SetFont(C["media"].font, C["general"].fontscale, "OUTLINE")
		
		local panel = CreateFrame("Frame", buttonName..index.."Panel", buff)
		panel:CreatePanel("Default", 30, 30, "CENTER", buff, "CENTER", 0, 0)
		panel:SetFrameLevel(buff:GetFrameLevel() - 1)
		panel:SetFrameStrata(buff:GetFrameStrata())

		local highlight = buff:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(1,1,1,0.45)
		highlight:SetAllPoints(icon)
	end
	if border then border:Hide() end
end

function UpdateFlash(self, elapsed)
	local index = self:GetID();
	if ( self.timeLeft < warningtime ) then
		self:SetAlpha(BuffFrame.BuffAlphaValue);
	else
		self:SetAlpha(1.0);
	end
end

local function UpdateBuffAnchors()
	buttonName = "BuffButton"
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	local index;
	for index=1, BUFF_ACTUAL_DISPLAY do
		local buff = _G[buttonName..index]
		StyleBuffs(buttonName, index, false)
		
		if ( buff.consolidated ) then
			if ( buff.parent == BuffFrame ) then
				buff:SetParent(ConsolidatedBuffsContainer)
				buff.parent = ConsolidatedBuffsContainer
			end
		else
			numBuffs = numBuffs + 1
			index = numBuffs
			buff:ClearAllPoints()
			if aurapos == "RIGHT" then
				if ( (index > 1) and (mod(index, rowbuffs) == 1) ) then
					if ( index == rowbuffs+1 ) then
						buff:SetPoint("RIGHT", AurasHolder, "RIGHT", 0, 0)
					else
						buff:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)
					end
					aboveBuff = buff;
				elseif ( index == 1 ) then
					local mainhand, _, _, offhand, _, _, hand3 = GetWeaponEnchantInfo()
					if (mainhand and offhand and hand3) and not UnitHasVehicleUI("player") then
						buff:SetPoint("RIGHT", TempEnchant3, "LEFT", btnspace, 0)
					elseif ((mainhand and offhand) or (mainhand and hand3) or (offhand and hand3)) and not UnitHasVehicleUI("player") then
						buff:SetPoint("RIGHT", TempEnchant2, "LEFT", btnspace, 0)
					elseif ((mainhand and not offhand and not hand3) or (offhand and not mainhand and not hand3) or (hand3 and not mainhand and not offhand)) and not UnitHasVehicleUI("player") then
						buff:SetPoint("RIGHT", TempEnchant1, "LEFT", btnspace, 0)
					else
						buff:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)
					end
				else
					buff:SetPoint("RIGHT", previousBuff, "LEFT", btnspace, 0)
				end
			else
				if ( (index > 1) and (mod(index, rowbuffs) == 1) ) then
					if ( index == rowbuffs+1 ) then
						buff:SetPoint("LEFT", AurasHolder, "LEFT", 0, 0)
					else
						buff:SetPoint("TOPLEFT", AurasHolder, "TOPLEFT", 0, 0)
					end
					aboveBuff = buff;
				elseif ( index == 1 ) then
					local mainhand, _, _, offhand, _, _, hand3 = GetWeaponEnchantInfo()
					if (mainhand and offhand and hand3) and not UnitHasVehicleUI("player") then
						buff:SetPoint("LEFT", TempEnchant3, "RIGHT", btnspace, 0)
					elseif ((mainhand and offhand) or (mainhand and hand3) or (offhand and hand3)) and not UnitHasVehicleUI("player") then
						buff:SetPoint("LEFT", TempEnchant2, "RIGHT", btnspace, 0)
					elseif ((mainhand and not offhand and not hand3) or (offhand and not mainhand and not hand3) or (hand3 and not mainhand and not offhand)) and not UnitHasVehicleUI("player") then
						buff:SetPoint("LEFT", TempEnchant1, "RIGHT", btnspace, 0)
					else
						buff:SetPoint("TOPLEFT", AurasHolder, "TOPLEFT", 0, 0)
					end
				else
					buff:SetPoint("LEFT", previousBuff, "RIGHT", btnspace, 0)
				end			
			end
			previousBuff = buff
			if index > (rowbuffs*2) then
				buff:Hide()
			else
				buff:Show()
			end
		end		
	end
end

local function UpdateDebuffAnchors(buttonName, index)
	local debuff = _G[buttonName..index];
	StyleBuffs(buttonName, index, true)
	local dtype = select(5, UnitDebuff("player",index))      
	local color
	if (dtype ~= nil) then
		color = DebuffTypeColor[dtype]
	else
		color = DebuffTypeColor["none"]
	end
	_G[buttonName..index.."Panel"]:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
	debuff:ClearAllPoints()
	if aurapos == "RIGHT" then
		if index == 1 then
			debuff:SetPoint("BOTTOMRIGHT", AurasHolder, "BOTTOMRIGHT", 0, 0)
		else
			debuff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", btnspace, 0)
		end
	else
		if index == 1 then
			debuff:SetPoint("BOTTOMLEFT", AurasHolder, "BOTTOMLEFT", 0, 0)
		else
			debuff:SetPoint("LEFT", _G[buttonName..(index-1)], "RIGHT", btnspace, 0)
		end	
	end
	
	if index > rowbuffs then
		debuff:Hide()
	else
		debuff:Show()
	end	
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function() mainhand, _, _, offhand = GetWeaponEnchantInfo() end)
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("PLAYER_EVENTERING_WORLD")

hooksecurefunc("AuraButton_OnUpdate", UpdateFlash)
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)


function E.AurasPostDrag(frame)
	local point = select(1, frame:GetPoint())

	if string.find(point, "LEFT") then
		TempEnchant1:ClearAllPoints()
		TempEnchant2:ClearAllPoints()
		TemporaryEnchantFrame:ClearAllPoints()
		btnspace = E.Scale(4)
		aurapos = "LEFT"
		TempEnchant1:SetPoint("TOPLEFT", AurasHolder, "TOPLEFT", 0, 0)
		TempEnchant2:SetPoint("LEFT", TempEnchant1, "RIGHT", btnspace, 0)		
		TemporaryEnchantFrame:SetPoint("TOPLEFT", AurasHolder, "TOPLEFT", 0, 0)	
	elseif string.find(point, "RIGHT") then
		TempEnchant1:ClearAllPoints()
		TempEnchant2:ClearAllPoints()
		TemporaryEnchantFrame:ClearAllPoints()
		btnspace = E.Scale(-4)
		aurapos = "RIGHT"
		TempEnchant1:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)
		TempEnchant2:SetPoint("RIGHT", TempEnchant1, "LEFT", btnspace, 0)	
		TemporaryEnchantFrame:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)			
	end
	
	UpdateBuffAnchors()
	BuffFrame_UpdateAllBuffAnchors()
	
	if E.Movers and not E.Movers["AurasMover"] or not E.Movers then
		AurasMover:ClearAllPoints()
		AurasMover:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", E.Scale(-8), E.Scale(2))
	end
end

E.CreateMover(AurasHolder, "AurasMover", "Auras Frame", false, E.AurasPostDrag)
