----------------------------------------------------------------------------
-- This Module loads new user settings if Tukui_ConfigUI is loaded
----------------------------------------------------------------------------

if not IsAddOnLoaded("Tukui_ConfigUI") or TukuiConfig == nil then return end

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
