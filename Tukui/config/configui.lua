----------------------------------------------------------------------------
-- This Module loads new user settings if Tukui_ConfigUI is loaded
----------------------------------------------------------------------------
local myPlayerRealm = GetCVar("realmName");
local myPlayerName  = UnitName("player");

if not IsAddOnLoaded("Tukui_ConfigUI") then return end

if not TukuiConfigAll then TukuiConfigAll = {} end		
if (TukuiConfigAll[myPlayerRealm] == nil) then TukuiConfigAll[myPlayerRealm] = {} end
if (TukuiConfigAll[myPlayerRealm][myPlayerName] == nil) then TukuiConfigAll[myPlayerRealm][myPlayerName] = false end

if TukuiConfigAll[myPlayerRealm][myPlayerName] == true and not TukuiConfig then return end
if TukuiConfigAll[myPlayerRealm][myPlayerName] == false and not TukuiConfigSettings then return end


if TukuiConfigAll[myPlayerRealm][myPlayerName] == true then
	for group,options in pairs(TukuiConfig) do
		if TukuiCF[group] then
			local count = 0
			for option,value in pairs(options) do
				if TukuiCF[group][option] ~= nil then
					if TukuiCF[group][option] == value then
						TukuiConfig[group][option] = nil	
					else
						count = count+1
						TukuiCF[group][option] = value
					end
				end
			end
			-- keeps TukuConfig clean and small
			if count == 0 then TukuiConfig[group] = nil end
		else
			TukuiConfig[group] = nil
		end
	end
else
	for group,options in pairs(TukuiConfigSettings) do
		if TukuiCF[group] then
			local count = 0
			for option,value in pairs(options) do
				if TukuiCF[group][option] ~= nil then
					if TukuiCF[group][option] == value then
						TukuiConfigSettings[group][option] = nil	
					else
						count = count+1
						TukuiCF[group][option] = value
					end
				end
			end
			-- keeps TukuConfig clean and small
			if count == 0 then TukuiConfigSettings[group] = nil end
		else
			TukuiConfigSettings[group] = nil
		end
	end
end

