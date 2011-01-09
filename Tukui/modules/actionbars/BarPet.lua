if not TukuiCF["actionbar"].enable == true then return end
local TukuiDB = TukuiDB
local TukuiCF = TukuiCF

---------------------------------------------------------------------------
-- setup PetActionBar
---------------------------------------------------------------------------

local bar = CreateFrame("Frame", "TukuiPetBar", TukuiActionBarBackground, "SecureHandlerStateTemplate")
bar:ClearAllPoints()
bar:SetAllPoints(TukuiPetActionBarBackground)

function PositionBarPet(self)
	local button		
	for i = 1, 10 do
		button = _G["PetActionButton"..i]
		button:ClearAllPoints()
		button:SetParent(TukuiPetBar)
		TukuiPetActionBarBackground:SetParent(TukuiPetBar)
		button:SetFrameStrata("MEDIUM")
		button:SetSize(TukuiDB.petbuttonsize, TukuiDB.petbuttonsize)
		if i == 1 then
			button:SetPoint("TOPLEFT", TukuiDB.petbuttonspacing, -TukuiDB.petbuttonspacing)
		else
			if TukuiCF["actionbar"].bottompetbar ~= true then
				button:SetPoint("TOP", _G["PetActionButton"..(i - 1)], "BOTTOM", 0, -TukuiDB.petbuttonspacing)
			else
				button:SetPoint("LEFT", _G["PetActionButton"..(i - 1)], "RIGHT", TukuiDB.petbuttonspacing, 0)
			end	
		end
		button:Show()
		self:SetAttribute("addchild", button)
	end
	
	--Setup Mouseover
	if TukuiCF["actionbar"].rightbarmouseover == true and TukuiCF["actionbar"].bottompetbar ~= true then
		TukuiPetActionBarBackground:SetAlpha(0)
		TukuiPetActionBarBackground:SetScript("OnEnter", function() RightBarMouseOver(1) end)
		TukuiPetActionBarBackground:SetScript("OnLeave", function() RightBarMouseOver(0) end)
		TukuiLineToPetActionBarBackground:SetScript("OnEnter", function() RightBarMouseOver(1) end)
		TukuiLineToPetActionBarBackground:SetScript("OnLeave", function() RightBarMouseOver(0) end)
		
		for i=1, 10 do
			local b = _G["PetActionButton"..i]
			b:SetAlpha(0)
			b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
			b:HookScript("OnLeave", function() RightBarMouseOver(0) end)
		end
	end
end
	
bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_CONTROL_LOST")
bar:RegisterEvent("PLAYER_CONTROL_GAINED")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
bar:RegisterEvent("PET_BAR_UPDATE")
bar:RegisterEvent("PET_BAR_UPDATE_USABLE")
bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
bar:RegisterEvent("PET_BAR_HIDE")
bar:RegisterEvent("UNIT_PET")
bar:RegisterEvent("UNIT_FLAGS")
bar:RegisterEvent("UNIT_AURA")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then	
		-- bug reported by Affli on t12 BETA
		PetActionBarFrame.showgrid = 1 -- hack to never hide pet button. :X
		
		PositionBarPet(self)
		RegisterStateDriver(self, "visibility", "[pet,novehicleui,nobonusbar:5] show; hide")
		hooksecurefunc("PetActionBar_Update", TukuiDB.TukuiPetBarUpdate)
	elseif event == "PET_BAR_UPDATE" or event == "UNIT_PET" and arg1 == "player" 
	or event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" or event == "UNIT_FLAGS"
	or arg1 == "pet" and (event == "UNIT_AURA") then
		TukuiDB.TukuiPetBarUpdate()
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar_UpdateCooldowns()
	else
		TukuiDB.StylePet()
	end
end)