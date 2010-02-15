
-- credit fatalentity

BUFF_FLASH_TIME_ON = 0.2;
BUFF_FLASH_TIME_OFF = 0.1;
BUFF_MIN_ALPHA = 0.8;
BUFF_WARNING_TIME = 10;
BUFFS_PER_ROW = 16;
BUFF_MAX_DISPLAY = 32;
BUFF_ROW_SPACING = 0;

local dummy = function() return end


ConsolidatedBuffs:ClearAllPoints()
ConsolidatedBuffs:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT",-12,7)
ConsolidatedBuffsIcon:SetAlpha(0)
ConsolidatedBuffs.SetPoint = dummy

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT", -180, -22)
TemporaryEnchantFrame.SetPoint = dummy

for i = 1, 2 do
	local TempBG = CreatePanel(30, 30, -2, 2, "TOPLEFT", "TOPLEFT", _G["TempEnchant"..i], 0, _G["TempEnchant"..i], "BACKGROUND")
	
	_G["TempEnchant"..i.."Border"]:Hide()
	_G["TempEnchant"..i.."Icon"]:SetTexCoord(.1, .9, .1, .9)
	
	if i == 1 then
		TempEnchant1:ClearAllPoints()
		TempEnchant2:ClearAllPoints()
		TempEnchant1:SetPoint("TOPRIGHT")
		TempEnchant2:SetPoint("RIGHT", TempEnchant1, "LEFT", -9,0)
	end
	
	_G["TempEnchant"..i]:SetHeight(26)
	_G["TempEnchant"..i]:SetWidth(26)
	
	_G["TempEnchant"..i.."Duration"]:ClearAllPoints()
	_G["TempEnchant"..i.."Duration"]:SetPoint("BOTTOM", 0, -16)
	_G["TempEnchant"..i.."Duration"]:SetFont("Fonts\\FRIZQT__.TTF", 12)	
end

local function UpdateBuffAnchors()
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	for index = 1, BUFF_ACTUAL_DISPLAY do
		local buff		= _G["BuffButton"..index];
		local icon		= _G["BuffButton"..index.."Icon"]
		local border	= _G["BuffButton"..index.."Border"]
		local duration	= _G["BuffButton"..index.."Duration"]
		local count		= _G["BuffButton"..index.."Count"]
		
		if icon and not _G["BuffButton"..index.."Panel"] then
			icon:SetTexCoord(.1, .9, .1, .9)
			icon:SetDrawLayer("OVERLAY")
			
			duration:SetFont("Fonts\\FRIZQT__.TTF",12)
			duration:ClearAllPoints()
			duration:SetDrawLayer("OVERLAY")
			duration:SetPoint("BOTTOM", .5, -16)
			
			count:SetFont(FONT, 12, "OUTLINE")
			count:ClearAllPoints()
			count:SetDrawLayer("OVERLAY")
			count:SetPoint("TOPLEFT", 0, 0)
			
			buff:SetHeight(26)
			buff:SetWidth(26)
		
			_G["BuffButton"..index.."Panel"] = CreatePanel(30, 30, -2, 2, "TOPLEFT", "TOPLEFT", buff, 0, buff, "BACKGROUND")
			_G["BuffButton"..index.."Panel"] = true
		end
		
		if ( buff.consolidated ) then
			if ( buff.parent == BuffFrame ) then
				buff:SetParent(ConsolidatedBuffsContainer);
				buff.parent = ConsolidatedBuffsContainer;
			end
		else
			numBuffs = numBuffs + 1;
			index = numBuffs;
			if ( buff.parent ~= BuffFrame ) then
				buff.count:SetFontObject(NumberFontNormal);
				buff:SetParent(BuffFrame);
				buff.parent = BuffFrame;
			end
			buff:ClearAllPoints()
			if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
				if ( index == BUFFS_PER_ROW+1 ) then
					buff:SetPoint("TOPRIGHT",UIParent, "TOPRIGHT", -180, -90)
				else
					buff:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -180, -22)
				end
				aboveBuff = buff;
			elseif ( index == 1 ) then
				local mainhand, _, _, offhand = GetWeaponEnchantInfo()
				if mainhand and offhand then
					buff:SetPoint("RIGHT", TempEnchant2, "LEFT", -9, 0)
				elseif (mainhand and not offhand) or (offhand and not mainhand) then
					buff:SetPoint("RIGHT", TempEnchant1, "LEFT", -9, 0)
				else
					buff:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -180, -22);
				end
			else
				buff:SetPoint("RIGHT", previousBuff, "LEFT", -9, 0);
			end
			previousBuff = buff;
		end
		
	end
end

local function UpdateDebuffAnchors(buttonName, index)
	local debuff	= _G[buttonName..index]
	local icon		= _G[buttonName..index.."Icon"]
	local border	= _G[buttonName..index.."Border"]
	local duration	= _G[buttonName..index.."Duration"]
	local count		= _G[buttonName..index.."Count"]
	
	if icon and not _G[buttonName..index.."Panel"] then
		icon:SetTexCoord(.1, .9, .1, .9)
		icon:SetDrawLayer("OVERLAY")
		
		debuff:SetHeight(26)
		debuff:SetWidth(26)
		
		duration:SetFont("Fonts\\FRIZQT__.TTF",12)
		duration:ClearAllPoints()
		duration:SetDrawLayer("OVERLAY")
		duration:SetPoint("BOTTOM", .5, -16)
			
		count:SetFont(FONT, 12, "OUTLINE")
		count:ClearAllPoints()
		count:SetDrawLayer("OVERLAY")
		count:SetPoint("TOPRIGHT", -1, -1)
		
		_G[buttonName..index.."Panel"] = CreatePanel(30, 30, -2, 2, "TOPLEFT", "TOPLEFT", debuff, 0, debuff, "BACKGROUND")
		_G[buttonName..index.."Panel"]:SetBackdropBorderColor(134/255, 12/255, 12/255)
		_G[buttonName..index.."Panel"] = true
	end
	
	if border then border:Hide() end
	debuff:ClearAllPoints()
	if index == 1 then
		debuff:SetPoint("TOPRIGHT",UIParent, "TOPRIGHT", -180, -160)
	else
		debuff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -9, 0)
	end
end

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)

-- Change color and format of duration.
SecondsToTimeAbbrev = function(time)
    local hr, m, s, text
    if time <= 0 then text = ""
    elseif(time < 3600 and time > 60) then
		hr = floor(time / 3600)
		m = floor(mod(time, 3600) / 60 + 1)
		text = format("|cffffffff%dm|r", m)
    elseif time < 60 then
		m = floor(time / 60)
		s = mod(time, 60)
		text = (m == 0 and format("|cffffffff%ds|r", s))
    else
		hr = floor(time / 3600 + 1)
		text = format("|cffffffff%dh|r", hr)
    end
    return text
end