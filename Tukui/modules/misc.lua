-- always show worldstate behind buffs
WorldStateAlwaysUpFrame:SetFrameStrata("BACKGROUND")
WorldStateAlwaysUpFrame:SetFrameLevel(0)
WorldStateAlwaysUpFrame:ClearAllPoints()
WorldStateAlwaysUpFrame:SetScale(TukuiDB.Scale(0.85))
WorldStateAlwaysUpFrame:SetPoint("TOP", TukuiDB.Scale(-35), TukuiDB.Scale(-75))


StackSplitFrame:SetFrameStrata("TOOLTIP")

if TukuiCF["skin"].embedright == "Skada" and IsAddOnLoaded("Skada") then
	SkadaBarWindowSkada:SetAllPoints(ChatRBackground)
end

-- convert datatext valuecolor from rgb decimal to hex
local r, g, b = unpack(TukuiCF["media"].valuecolor)
valuecolor = ("|cff%.2x%.2x%.2x"):format(r * 255, g * 255, b * 255)

--[[Spin camera while afk 

	Credits:
	Telroth (Darth Android) - Concept and code reference.
	
	Edited and rewritten by: Eclípsé, and Elv
	
]]
if TukuiCF["others"].spincam == true then
	local SpinCam = CreateFrame("Frame")

	local OnEvent = function(self, event, unit)
		if (event == "PLAYER_FLAGS_CHANGED") then
			if unit == "player" then
				if UnitIsAFK(unit) then
					SpinStart()
				else
					SpinStop()
				end
			end
		elseif (event == "PLAYER_LEAVING_WORLD") then
			SpinStop()
		end
	end
	SpinCam:RegisterEvent("PLAYER_ENTERING_WORLD")
	SpinCam:RegisterEvent("PLAYER_LEAVING_WORLD")
	SpinCam:RegisterEvent("PLAYER_FLAGS_CHANGED")
	SpinCam:SetScript("OnEvent", OnEvent)

	function SpinStart()
		spinning = true
		MoveViewRightStart(0.1)
	end

	function SpinStop()
		if not spinning then return end
		spinning = nil
		MoveViewRightStop()
	end
end

--Custom Lag Tolerance 
if TukuiCF["general"].autocustomlagtolerance == true then
	InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset:Hide()
	
	local customlag = CreateFrame("Frame")
	local int = 5
	local LatencyUpdate = function(self, elapsed)
		int = int - elapsed
		if int < 0 then
			if GetCVar("reducedLagTolerance") ~= tostring(1) then SetCVar("reducedLagTolerance", tostring(1)) end
			if select(3, GetNetStats()) ~= 0 and select(3, GetNetStats()) <= 400 then
				SetCVar("maxSpellStartRecoveryOffset", tostring(select(3, GetNetStats())))
			end
			int = 5
		end
	end
	customlag:SetScript("OnUpdate", LatencyUpdate)
	LatencyUpdate(customlag, 10)
end