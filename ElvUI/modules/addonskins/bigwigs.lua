--[[
Author: Affli@RU-Howling Fjord, 
Modified: Elv
All rights reserved.
]]--
local E, C, L, DB = unpack(select(2, ...))

if not C["skin"].bigwigs == true or not IsAddOnLoaded("BigWigs") then return end

local buttonsize = 19

-- init some tables to store backgrounds
local freebg = {}

-- styling functions
local createbg = function()
	local bg = CreateFrame("Frame")
	bg:SetTemplate("Transparent")
	return bg
end

local function freestyle(bar)

	-- reparent and hide bar background
	local bg = bar:Get("bigwigs:elvui:barbg")
	if bg then
		bg:ClearAllPoints()
		bg:SetParent(E.UIParent)
		bg:Hide()
		freebg[#freebg + 1] = bg
	end

	-- reparent and hide icon background
	local ibg = bar:Get("bigwigs:elvui:iconbg")
	if ibg then
		ibg:ClearAllPoints()
		ibg:SetParent(E.UIParent)
		ibg:Hide()
		freebg[#freebg + 1] = ibg
	end

	-- replace dummies with original method functions
	bar.candyBarBar.SetPoint=bar.candyBarBar.OldSetPoint
	bar.candyBarIconFrame.SetWidth=bar.candyBarIconFrame.OldSetWidth
	bar.SetScale=bar.OldSetScale
	
	--Reset Positions
	--Icon
	bar.candyBarIconFrame:ClearAllPoints()
	bar.candyBarIconFrame:SetPoint("TOPLEFT")
	bar.candyBarIconFrame:SetPoint("BOTTOMLEFT")
	bar.candyBarIconFrame:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	
	--Status Bar
	bar.candyBarBar:ClearAllPoints()
	bar.candyBarBar:SetPoint("TOPRIGHT")
	bar.candyBarBar:SetPoint("BOTTOMRIGHT")
	
	--BG
	bar.candyBarBackground:SetAllPoints()
	
	--Duration
	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 0)
	
	--Name
	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:SetPoint("LEFT", bar.candyBarBar, "LEFT", 2, 0)
	bar.candyBarLabel:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 0)	
end

local applystyle = function(bar)

	-- general bar settings
	bar.OldHeight = bar:GetHeight()
	bar.OldScale = bar:GetScale()
	bar.OldSetScale=bar.SetScale
	bar.SetScale=E.dummy
	bar:Height(buttonsize)
	bar:SetScale(1)
	
	-- create or reparent and use bar background
	local bg = nil
	if #freebg > 0 then
		bg = table.remove(freebg)
	else
		bg = createbg()
	end

	bg:SetParent(bar)
	bg:ClearAllPoints()
	bg:Point("TOPLEFT", bar, "TOPLEFT", -2, 2)
	bg:Point("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
	bg:SetFrameStrata("BACKGROUND")
	bg:Show()
	bar:Set("bigwigs:elvui:barbg", bg)

	-- create or reparent and use icon background
	local ibg = nil
	if bar.candyBarIconFrame:GetTexture() then
		if #freebg > 0 then
			ibg = table.remove(freebg)
		else
			ibg = createbg()
		end
		ibg:SetParent(bar)
		ibg:ClearAllPoints()
		ibg:Point("TOPLEFT", bar.candyBarIconFrame, "TOPLEFT", -2, 2)
		ibg:Point("BOTTOMRIGHT", bar.candyBarIconFrame, "BOTTOMRIGHT", 2, -2)
		ibg:SetFrameStrata("BACKGROUND")
		ibg:Show()
		bar:Set("bigwigs:elvui:iconbg", ibg)
	end

	-- setup timer and bar name fonts and positions
	bar.candyBarLabel:SetFont(C["media"].font, 12, "OUTLINE")
	bar.candyBarLabel:SetShadowColor(0, 0, 0, 0)
	bar.candyBarLabel:SetJustifyH("LEFT")
	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:Point("LEFT", bar, "LEFT", 4, 0)

	bar.candyBarDuration:SetFont(C["media"].font, 12, "OUTLINE")
	bar.candyBarDuration:SetShadowColor(0, 0, 0, 0)
	bar.candyBarDuration:SetJustifyH("RIGHT")
	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:Point("RIGHT", bar, "RIGHT", -4, 0)

	-- setup bar positions and look
	bar.candyBarBar.OldPoint, bar.candyBarBar.Anchor, bar.candyBarBar.OldPoint2, bar.candyBarBar.XPoint, bar.candyBarBar.YPoint  = bar.candyBarBar:GetPoint()
	bar.candyBarBar:ClearAllPoints()
	bar.candyBarBar:SetAllPoints(bar)
	bar.candyBarBar.OldSetPoint = bar.candyBarBar.SetPoint
	bar.candyBarBar.SetPoint=E.dummy
	bar.candyBarBar:SetStatusBarTexture(C["media"].normTex)
	bar.candyBarBackground:SetTexture(unpack(C.media.backdropcolor))

	-- setup icon positions and other things
	bar.candyBarIconFrame.OldPoint, bar.candyBarIconFrame.Anchor, bar.candyBarIconFrame.OldPoint2, bar.candyBarIconFrame.XPoint, bar.candyBarIconFrame.YPoint  = bar.candyBarIconFrame:GetPoint()
	bar.candyBarIconFrame.OldWidth = bar.candyBarIconFrame:GetWidth()
	bar.candyBarIconFrame.OldHeight = bar.candyBarIconFrame:GetHeight()
	bar.candyBarIconFrame.OldSetWidth = bar.candyBarIconFrame.SetWidth
	bar.candyBarIconFrame.SetWidth=E.dummy
	bar.candyBarIconFrame:ClearAllPoints()
	bar.candyBarIconFrame:Point("BOTTOMRIGHT", bar, "BOTTOMLEFT", -5, 0)	
	bar.candyBarIconFrame:SetSize(buttonsize, buttonsize)
	bar.candyBarIconFrame:SetTexCoord(0.08, 0.92, 0.08, 0.92)
end


local function RegisterStyle()
	if not BigWigs then return end
	local bars = BigWigs:GetPlugin("Bars", true)
	local prox = BigWigs:GetPlugin("Proximity", true)
	if bars then
		bars:RegisterBarStyle("ElvUI", {
			apiVersion = 1,
			version = 1,
			GetSpacing = function(bar) return 7 end,
			ApplyStyle = applystyle,
			BarStopped = freestyle,
			GetStyleName = function() return "ElvUI" end,
		})
	end
	if prox and bars.db.profile.barStyle == "ElvUI" then
		hooksecurefunc(BigWigs.pluginCore.modules.Proximity, "RestyleWindow", function()
			BigWigsProximityAnchor:SetTemplate("Transparent")
		end)
	end
end

local function PositionBWAnchor()
	if not BigWigsAnchor then return end
	BigWigsAnchor:ClearAllPoints()
	if E.CheckAddOnShown() == true then
		if C["chat"].showbackdrop == true and E.ChatRightShown == true then
			BigWigsAnchor:Point("TOP", ChatRBGDummy, "TOP", 12, 0)	
		else
			BigWigsAnchor:Point("TOP", ChatRBGDummy, "TOP", 12, -32)
		end	
	else
		BigWigsAnchor:Point("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", -5, 8)		
	end
end


local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "BigWigs_Plugins" then
		RegisterStyle()
		local profile = BigWigs3DB["profileKeys"][E.myname.." - "..E.myrealm]
		local path = BigWigs3DB["namespaces"]["BigWigs_Plugins_Bars"]["profiles"][profile]
		path.texture = "ElvUI Norm"
		path.barStyle = "ElvUI"
		path.font = "ElvUI Font"
		
		local path = BigWigs3DB["namespaces"]["BigWigs_Plugins_Messages"]["profiles"][profile]
		path.font = "ElvUI Font"
		
		local path = BigWigs3DB["namespaces"]["BigWigs_Plugins_Proximity"]["profiles"][profile]
		path.font = "ElvUI Font"
		
		f:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_ENTERING_WORLD" then
		LoadAddOn("BigWigs")
		LoadAddOn("BigWigs_Core")
		LoadAddOn("BigWigs_Plugins")
		LoadAddOn("BigWigs_Options")
		if not BigWigs then return end
		BigWigs:Enable()
		BigWigsOptions:SendMessage("BigWigs_StartConfigureMode", true)
		BigWigsOptions:SendMessage("BigWigs_StopConfigureMode")
		PositionBWAnchor()

		if Skada and Skada:GetWindows() and Skada:GetWindows()[1] and C["skin"].embedright == "Skada" then
			Skada:GetWindows()[1].bargroup:HookScript("OnShow", function() PositionBWAnchor() end)
			Skada:GetWindows()[1].bargroup:HookScript("OnHide", function() PositionBWAnchor() end)
		elseif Recount_MainWindow and C["skin"].embedright == "Recount" then
			Recount_MainWindow:HookScript("OnShow", function() PositionBWAnchor() end)
			Recount_MainWindow:HookScript("OnHide", function() PositionBWAnchor() end)
		elseif OmenAnchor and C["skin"].embedright == "Omen" then
			OmenAnchor:HookScript("OnShow", function() PositionBWAnchor() end)
			OmenAnchor:HookScript("OnHide", function() PositionBWAnchor() end)		
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		PositionBWAnchor()
	elseif event == "PLAYER_REGEN_ENABLED" then
		PositionBWAnchor()
	end
end)

--BigWigsAnchor
if C["skin"].hookbwright == true then
	f:RegisterEvent("PLAYER_REGEN_ENABLED")
	f:RegisterEvent("PLAYER_REGEN_DISABLED")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")

	ChatRBG:HookScript("OnHide", function(self)
		PositionBWAnchor()
	end)
	
	ChatRBG:HookScript("OnShow", function(self)
		PositionBWAnchor()
	end)		
end