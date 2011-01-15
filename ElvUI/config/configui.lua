----------------------------------------------------------------------------
-- This Module loads new user settings if ElvUI_ConfigUI is loaded
----------------------------------------------------------------------------
local myPlayerRealm = GetCVar("realmName");
local myPlayerName  = UnitName("player");

if not IsAddOnLoaded("ElvUI_ConfigUI") then return end

if not ElvuiConfigAll then ElvuiConfigAll = {} end		
if (ElvuiConfigAll[myPlayerRealm] == nil) then ElvuiConfigAll[myPlayerRealm] = {} end
if (ElvuiConfigAll[myPlayerRealm][myPlayerName] == nil) then ElvuiConfigAll[myPlayerRealm][myPlayerName] = false end

if ElvuiConfigAll[myPlayerRealm][myPlayerName] == true and not ElvuiConfig then return end
if ElvuiConfigAll[myPlayerRealm][myPlayerName] == false and not ElvuiConfigSettings then return end


if ElvuiConfigAll[myPlayerRealm][myPlayerName] == true then
	for group,options in pairs(ElvuiConfig) do
		if ElvCF[group] then
			local count = 0
			for option,value in pairs(options) do
				if ElvCF[group][option] ~= nil then
					if ElvCF[group][option] == value then
						ElvuiConfig[group][option] = nil	
					else
						count = count+1
						ElvCF[group][option] = value
					end
				end
			end
			-- keeps ElvuiConfig clean and small
			if count == 0 then ElvuiConfig[group] = nil end
		else
			ElvuiConfig[group] = nil
		end
	end
else
	for group,options in pairs(ElvuiConfigSettings) do
		if ElvCF[group] then
			local count = 0
			for option,value in pairs(options) do
				if ElvCF[group][option] ~= nil then
					if ElvCF[group][option] == value then
						ElvuiConfigSettings[group][option] = nil	
					else
						count = count+1
						ElvCF[group][option] = value
					end
				end
			end
			-- keeps ElvuiConfig clean and small
			if count == 0 then ElvuiConfigSettings[group] = nil end
		else
			ElvuiConfigSettings[group] = nil
		end
	end
end

