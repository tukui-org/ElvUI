local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- setup PetActionBar
---------------------------------------------------------------------------

local bar = CreateFrame("Frame", "ElvuiPetBar", ElvuiActionBarBackground, "SecureHandlerStateTemplate")
bar:ClearAllPoints()
bar:SetAllPoints(ElvuiPetActionBarBackground)

function E.PositionBarPet(self)
	local button		
	for i = 1, 10 do
		button = _G["PetActionButton"..i]
		button:ClearAllPoints()
		button:SetParent(ElvuiPetBar)
		ElvuiPetActionBarBackground:SetParent(ElvuiPetBar)
		button:SetFrameStrata("MEDIUM")
		button:SetSize(E.petbuttonsize, E.petbuttonsize)
		if i == 1 then
			button:SetPoint("TOPLEFT", E.buttonspacing, -E.buttonspacing)
		else
			if C["actionbar"].bottompetbar ~= true then
				button:SetPoint("TOP", _G["PetActionButton"..(i - 1)], "BOTTOM", 0, -E.buttonspacing)
			else
				button:SetPoint("LEFT", _G["PetActionButton"..(i - 1)], "RIGHT", E.buttonspacing, 0)
			end	
		end
		button:Show()
		self:SetAttribute("addchild", button)
	end
	
	--Setup Mouseover
	if C["actionbar"].rightbarmouseover == true and C["actionbar"].bottompetbar ~= true then
		ElvuiPetActionBarBackground:SetAlpha(0)
		ElvuiPetActionBarBackground:SetScript("OnEnter", function() RightBarMouseOver(1) end)
		ElvuiPetActionBarBackground:SetScript("OnLeave", function() RightBarMouseOver(0) end)
		ElvuiLineToPetActionBarBackground:SetScript("OnEnter", function() RightBarMouseOver(1) end)
		ElvuiLineToPetActionBarBackground:SetScript("OnLeave", function() RightBarMouseOver(0) end)
		
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
		
		E.PositionBarPet(self)
		RegisterStateDriver(self, "visibility", "[pet,novehicleui,nobonusbar:5] show; hide")
		hooksecurefunc("PetActionBar_Update", E.ElvuiPetBarUpdate)
	elseif event == "PET_BAR_UPDATE" or event == "UNIT_PET" and arg1 == "player" 
	or event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" or event == "UNIT_FLAGS"
	or arg1 == "pet" and (event == "UNIT_AURA") then
		E.ElvuiPetBarUpdate()
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar_UpdateCooldowns()
	else
		E.StylePet()
	end
end)