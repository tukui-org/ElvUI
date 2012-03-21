local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local A = E:NewModule('Auras', 'AceHook-3.0', 'AceEvent-3.0');

local warningTime = 5
local btnspace = -4
local aurapos = "RIGHT"
local mainhand, offhand

function A:UpdateFlash(frame, elapsed)
	local index = frame:GetID();
	if ( frame.timeLeft < warningTime ) then
		frame:SetAlpha(BuffFrame.BuffAlphaValue);
	else
		frame:SetAlpha(1.0);
	end
end

function A:UpdateSettings()
	A:UpdateBuffAnchors()
	BuffFrame_UpdateAllBuffAnchors()
end

function A:StyleBuffs(buttonName, index, debuff)
	local buff = _G[buttonName..index]
	local icon = _G[buttonName..index.."Icon"]
	local border = _G[buttonName..index.."Border"]
	local duration = _G[buttonName..index.."Duration"]
	local count = _G[buttonName..index.."Count"]
	if icon and not buff.backdrop then
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:Point("TOPLEFT", buff, 2, -2)
		icon:Point("BOTTOMRIGHT", buff, -2, 2)
		
		buff:Size(30)
				
		duration:ClearAllPoints()
		duration:Point("BOTTOM", 0, -13)
		duration:FontTemplate(nil, nil, 'OUTLINE')
		
		count:ClearAllPoints()
		count:Point("TOPLEFT", 1, -2)
		count:FontTemplate(nil, nil, 'OUTLINE')
		
		buff:CreateBackdrop('Default')
		buff.backdrop:SetAllPoints()
		
		local highlight = buff:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture(1,1,1,0.45)
		highlight:SetAllPoints(icon)
	end
	if border then border:Hide() end
end

function A:UpdateDebuffAnchors(buttonName, index)
	local debuff = _G[buttonName..index];
	if debuff:IsProtected() then return end -- uhh ohhh
	self:StyleBuffs(buttonName, index, true)
	local dtype = select(5, UnitDebuff("player",index))      
	local color
	if (dtype ~= nil) then
		color = DebuffTypeColor[dtype]
	else
		color = DebuffTypeColor["none"]
	end
	debuff.backdrop:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
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
			debuff:SetPoint("LEFT", _G[buttonName..(index-1)], "RIGHT", -(btnspace), 0)
		end	
	end
	
	if index > self.db.perRow then
		debuff:Hide()
	else
		debuff:Show()
	end	
end

function A:UpdateBuffAnchors()
	local buttonName = "BuffButton"
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	local index;
	for i=1, BUFF_ACTUAL_DISPLAY do
		local buff = _G[buttonName..i]
		if buff:IsProtected() then return end -- uhh ohhh
		self:StyleBuffs(buttonName, i, false)

		if ( buff.consolidated ) then
			if ( buff.parent == BuffFrame ) then
				buff:SetParent(ConsolidatedBuffsContainer)
				buff.parent = ConsolidatedBuffsContainer
			end
		else
			numBuffs = numBuffs + 1
			i = numBuffs
			buff:ClearAllPoints()
			if aurapos == "RIGHT" then
				if ( (i > 1) and (mod(i, self.db.perRow) == 1) ) then
					if ( i == self.db.perRow+1 ) then
						buff:SetPoint("RIGHT", AurasHolder, "RIGHT", 0, 0)
					else
						buff:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)
					end
					aboveBuff = buff;
				elseif ( i == 1 ) then
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
				if ( (i > 1) and (mod(i, self.db.perRow) == 1) ) then
					if ( i == self.db.perRow+1 ) then
						buff:SetPoint("LEFT", AurasHolder, "LEFT", 0, 0)
					else
						buff:SetPoint("TOPLEFT", AurasHolder, "TOPLEFT", 0, 0)
					end
					aboveBuff = buff;
				elseif ( i == 1 ) then
					local mainhand, _, _, offhand, _, _, hand3 = GetWeaponEnchantInfo()
					if (mainhand and offhand and hand3) and not UnitHasVehicleUI("player") then
						buff:SetPoint("LEFT", TempEnchant3, "RIGHT", -(btnspace), 0)
					elseif ((mainhand and offhand) or (mainhand and hand3) or (offhand and hand3)) and not UnitHasVehicleUI("player") then
						buff:SetPoint("LEFT", TempEnchant2, "RIGHT", -(btnspace), 0)
					elseif ((mainhand and not offhand and not hand3) or (offhand and not mainhand and not hand3) or (hand3 and not mainhand and not offhand)) and not UnitHasVehicleUI("player") then
						buff:SetPoint("LEFT", TempEnchant1, "RIGHT", -(btnspace), 0)
					else
						buff:SetPoint("TOPLEFT", AurasHolder, "TOPLEFT", 0, 0)
					end
				else
					buff:SetPoint("LEFT", previousBuff, "RIGHT", -(btnspace), 0)
				end			
			end
			previousBuff = buff
			if i > (self.db.perRow*2) then
				buff:Hide()
			else
				buff:Show()
			end
		end		
	end
	
	for i = 1, 3 do
		_G["TempEnchant"..i].backdrop:SetBackdropBorderColor(137/255, 0, 191/255)
	end	
end

function A:Update_WeaponEnchantInfo()
	mainhand, _, _, offhand = GetWeaponEnchantInfo()
end

function A:AurasPostDrag(point)
	if string.find(point, "LEFT") then
		TempEnchant1:ClearAllPoints()
		TempEnchant2:ClearAllPoints()
		TempEnchant3:ClearAllPoints()
		TemporaryEnchantFrame:ClearAllPoints()
		aurapos = "LEFT"
		TempEnchant1:SetPoint("TOPLEFT", AurasHolder, "TOPLEFT", 0, 0)
		TempEnchant2:SetPoint("LEFT", TempEnchant1, "RIGHT", -(btnspace), 0)	
		TempEnchant3:SetPoint("LEFT", TempEnchant2, "RIGHT", -(btnspace), 0)		
		TemporaryEnchantFrame:SetPoint("TOPLEFT", AurasHolder, "TOPLEFT", 0, 0)	
	elseif string.find(point, "RIGHT") then
		TempEnchant1:ClearAllPoints()
		TempEnchant2:ClearAllPoints()
		TempEnchant3:ClearAllPoints()
		TemporaryEnchantFrame:ClearAllPoints()
		aurapos = "RIGHT"
		TempEnchant1:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)
		TempEnchant2:SetPoint("RIGHT", TempEnchant1, "LEFT", btnspace, 0)	
		TempEnchant3:SetPoint("RIGHT", TempEnchant2, "LEFT", btnspace, 0)	
		TemporaryEnchantFrame:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)			
	end
	
	A:UpdateBuffAnchors()
	BuffFrame_UpdateAllBuffAnchors()
end

function A:Initialize()
	self.db = E.db.auras
	if E.global.auras.enable ~= true then 
		BuffFrame:Kill();
		return 
	end
	
	ConsolidatedBuffs:ClearAllPoints()
	ConsolidatedBuffs:Point("LEFT", Minimap, "LEFT", 0, 3)
	ConsolidatedBuffs:Size(16, 16)
	ConsolidatedBuffs:SetParent(Minimap)
	ConsolidatedBuffsIcon:SetTexture(nil)
	ConsolidatedBuffs.SetPoint = E.noop
	
	local holder = CreateFrame("Frame", "AurasHolder", E.UIParent)
	holder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -((E.MinimapSize + 4) + E.RBRWidth + 7), -3)
	holder:Width(456)
	holder:Height(E.MinimapHeight)
	
	TemporaryEnchantFrame:ClearAllPoints()
	TemporaryEnchantFrame:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)

	TempEnchant1:ClearAllPoints()
	TempEnchant2:ClearAllPoints()
	TempEnchant3:ClearAllPoints()
	TempEnchant1:Point("TOPRIGHT", AurasHolder, "TOPRIGHT")
	TempEnchant2:Point("RIGHT", TempEnchant1, "LEFT", btnspace, 0)
	TempEnchant3:Point("RIGHT", TempEnchant2, "LEFT", btnspace, 0)
	
	for i = 1, 3 do
		_G["TempEnchant"..i]:Size(30)
		_G["TempEnchant"..i]:CreateBackdrop('Default')
		_G["TempEnchant"..i].backdrop:SetAllPoints()
		_G["TempEnchant"..i.."Border"]:Hide()
		_G["TempEnchant"..i.."Icon"]:SetTexCoord(unpack(E.TexCoords))
		_G["TempEnchant"..i.."Icon"]:Point("TOPLEFT", _G["TempEnchant"..i], 2, -2)
		_G["TempEnchant"..i.."Icon"]:Point("BOTTOMRIGHT", _G["TempEnchant"..i], -2, 2)
		_G["TempEnchant"..i.."Duration"]:ClearAllPoints()
		_G["TempEnchant"..i.."Duration"]:Point("BOTTOM", 0, -13)
		_G["TempEnchant"..i.."Duration"]:FontTemplate(nil, nil, 'OUTLINE')
	end	
	
	self:RegisterEvent('UNIT_INVENTORY_CHANGED', 'Update_WeaponEnchantInfo')
	self:RegisterEvent('PLAYER_EVENTERING_WORLD', 'Update_WeaponEnchantInfo')
	self:SecureHook("AuraButton_OnUpdate", "UpdateFlash")
	self:SecureHook("BuffFrame_UpdateAllBuffAnchors", "UpdateBuffAnchors")
	self:SecureHook("DebuffButton_UpdateAnchors", "UpdateDebuffAnchors")	
	E:CreateMover(AurasHolder, "AurasMover", "Auras Frame", false, A.AurasPostDrag)
	AurasHolder.ClearAllPoints = E.noop
	AurasHolder.SetPoint = E.noop
	AurasHolder.SetAllPoints = E.noop
end

E:RegisterModule(A:GetName())