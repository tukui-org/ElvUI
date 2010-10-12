ConsolidatedBuffs:ClearAllPoints()
ConsolidatedBuffs:SetPoint("LEFT", Minimap, "LEFT", TukuiDB.Scale(0), TukuiDB.Scale(0))
ConsolidatedBuffs:SetSize(16, 16)
ConsolidatedBuffsIcon:SetTexture(nil)
ConsolidatedBuffs.SetPoint = TukuiDB.dummy

if TukuiCF.unitframes.playerauras == true then return end

local mainhand, _, _, offhand = GetWeaponEnchantInfo()
local rowbuffs = 16

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, TukuiDB.Scale(-16))
TemporaryEnchantFrame.SetPoint = TukuiDB.dummy

TempEnchant1:ClearAllPoints()
TempEnchant2:ClearAllPoints()
TempEnchant1:SetPoint("TOPRIGHT", UIParent, TukuiDB.Scale(-184), TukuiDB.Scale(-22))
TempEnchant2:SetPoint("RIGHT", TempEnchant1, "LEFT", TukuiDB.Scale(-4), 0)

WorldStateAlwaysUpFrame:SetFrameStrata("BACKGROUND")
WorldStateAlwaysUpFrame:SetFrameLevel(0)

for i = 1, 2 do
	local f = CreateFrame("Frame", nil, _G["TempEnchant"..i])
	TukuiDB.CreatePanel(f, 30, 30, "CENTER", _G["TempEnchant"..i], "CENTER", 0, 0)	
	_G["TempEnchant"..i.."Border"]:Hide()
	_G["TempEnchant"..i.."Icon"]:SetTexCoord(.08, .92, .08, .92)
	_G["TempEnchant"..i.."Icon"]:SetPoint("TOPLEFT", _G["TempEnchant"..i], TukuiDB.Scale(2), TukuiDB.Scale(-2))
	_G["TempEnchant"..i.."Icon"]:SetPoint("BOTTOMRIGHT", _G["TempEnchant"..i], TukuiDB.Scale(-2), TukuiDB.Scale(2))
	_G["TempEnchant"..i]:SetHeight(TukuiDB.Scale(30))
	_G["TempEnchant"..i]:SetWidth(TukuiDB.Scale(30))	
	_G["TempEnchant"..i.."Duration"]:ClearAllPoints()
	_G["TempEnchant"..i.."Duration"]:SetPoint("BOTTOM", 0, TukuiDB.Scale(-13))
	_G["TempEnchant"..i.."Duration"]:SetFont(TukuiCF["media"].font, 12)
end

local function StyleBuffs(buttonName, index, debuff)
	local buff		= _G[buttonName..index]
	local icon		= _G[buttonName..index.."Icon"]
	local border	= _G[buttonName..index.."Border"]
	local duration	= _G[buttonName..index.."Duration"]
	local count 	= _G[buttonName..index.."Count"]
	if icon and not _G[buttonName..index.."Panel"] then
		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetPoint("TOPLEFT", buff, TukuiDB.Scale(2), TukuiDB.Scale(-2))
		icon:SetPoint("BOTTOMRIGHT", buff, TukuiDB.Scale(-2), TukuiDB.Scale(2))
		
		buff:SetHeight(TukuiDB.Scale(30))
		buff:SetWidth(TukuiDB.Scale(30))
				
		duration:ClearAllPoints()
		duration:SetPoint("BOTTOM", 0, TukuiDB.Scale(-13))
		duration:SetFont(TukuiCF["media"].font, 12)
		
		count:ClearAllPoints()
		count:SetPoint("TOPLEFT", TukuiDB.Scale(1), TukuiDB.Scale(-2))
		count:SetFont(TukuiCF["media"].font, 12, "OUTLINE")
		
		local panel = CreateFrame("Frame", buttonName..index.."Panel", buff)
		TukuiDB.CreatePanel(panel, 30, 30, "CENTER", buff, "CENTER", 0, 0)
		panel:SetFrameLevel(buff:GetFrameLevel() - 1)
		panel:SetFrameStrata(buff:GetFrameStrata())
	end
	if border then border:Hide() end
end

local function UpdateBuffAnchors()
	buttonName = "BuffButton"
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	for index=1, BUFF_ACTUAL_DISPLAY do
		local buff = _G[buttonName..index]
		StyleBuffs(buttonName, index, false)
		
		-- Leaving this here just in case someone want to use it
		-- This enable buff border coloring according to Type
		--[[
		local dtype = select(5, UnitBuff("player",index))		
		local color
		if (dtype ~= nil) then
			color = DebuffTypeColor[dtype]
		else
			color = DebuffTypeColor["none"]
		end
		_G[buttonName..index.."Panel"]:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
		--]]
		
		if ( buff.consolidated ) then
			if ( buff.parent == BuffFrame ) then
				buff:SetParent(ConsolidatedBuffsContainer)
				buff.parent = ConsolidatedBuffsContainer
			end
		else
			numBuffs = numBuffs + 1
			index = numBuffs
			buff:ClearAllPoints()
			if ( (index > 1) and (mod(index, rowbuffs) == 1) ) then
				if ( index == rowbuffs+1 ) then
					buff:SetPoint("TOPRIGHT", UIParent, TukuiDB.Scale(-184), TukuiDB.Scale(-92))
				else
					buff:SetPoint("TOPRIGHT", UIParent, TukuiDB.Scale(-184), TukuiDB.Scale(-22))
				end
				aboveBuff = buff;
			elseif ( index == 1 ) then
				local mainhand, _, _, offhand = GetWeaponEnchantInfo()
				if mainhand and offhand and not UnitHasVehicleUI("player") then
					buff:SetPoint("RIGHT", TempEnchant2, "LEFT", TukuiDB.Scale(-4), 0)
				elseif ((mainhand and not offhand) or (offhand and not mainhand)) and not UnitHasVehicleUI("player") then
					buff:SetPoint("RIGHT", TempEnchant1, "LEFT", TukuiDB.Scale(-4), 0)
				else
					buff:SetPoint("TOPRIGHT", UIParent, TukuiDB.Scale(-184), TukuiDB.Scale(-22))
				end
			else
				buff:SetPoint("RIGHT", previousBuff, "LEFT", TukuiDB.Scale(-4), 0)
			end
			previousBuff = buff
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
	if index == 1 then
		debuff:SetPoint("TOPRIGHT", UIParent, TukuiDB.Scale(-184), TukuiDB.Scale(-161))
	else
		debuff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", TukuiDB.Scale(-4), 0)
	end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function() mainhand, _, _, offhand = GetWeaponEnchantInfo() end)
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("PLAYER_EVENTERING_WORLD")

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)
