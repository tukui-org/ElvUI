local E, L, V, P, G = unpack(ElvUI); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local LSM = LibStub("LibSharedMedia-3.0")

local buttonsize = 20

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
	bar.candyBarIconFrame:SetTexCoord(unpack(E.TexCoords))

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
	--bar.OldHeight = bar:GetHeight()
	--bar.OldScale = bar:GetScale()
	--bar.OldSetScale=bar.SetScale
	--bar.SetScale=E.noop
	bar:Height(buttonsize)
	--bar:SetScale(1)

	-- create or reparent and use bar background
	local bg = nil
	if #freebg > 0 then
		bg = table.remove(freebg)
	else
		bg = createbg()
	end

	bg:SetParent(bar)
	bg:SetOutside(bar)
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
		ibg:SetOutside(bar.candyBarIconFrame)
		ibg:SetFrameStrata("BACKGROUND")
		ibg:Show()
		bar:Set("bigwigs:elvui:iconbg", ibg)
	end

	-- setup timer and bar name fonts and positions
	bar.candyBarLabel:SetJustifyH("LEFT")
	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:Point("LEFT", bar, "LEFT", 4, 0)

	bar.candyBarDuration:SetJustifyH("RIGHT")
	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:Point("RIGHT", bar, "RIGHT", -4, 0)

	-- setup bar positions and look
	bar.candyBarBar.OldPoint, bar.candyBarBar.Anchor, bar.candyBarBar.OldPoint2, bar.candyBarBar.XPoint, bar.candyBarBar.YPoint  = bar.candyBarBar:GetPoint()
	bar.candyBarBar:ClearAllPoints()
	bar.candyBarBar:SetAllPoints(bar)
	bar.candyBarBar.OldSetPoint = bar.candyBarBar.SetPoint
	bar.candyBarBar.SetPoint=E.noop
	bar.candyBarBar:SetStatusBarTexture(LSM:Fetch("statusbar",E.private.general.normTex))
	bar.candyBarBackground:SetTexture(unpack(E.media.backdropcolor))

	-- setup icon positions and other things
	bar.candyBarIconFrame.OldPoint, bar.candyBarIconFrame.Anchor, bar.candyBarIconFrame.OldPoint2, bar.candyBarIconFrame.XPoint, bar.candyBarIconFrame.YPoint  = bar.candyBarIconFrame:GetPoint()
	bar.candyBarIconFrame.OldWidth = bar.candyBarIconFrame:GetWidth()
	bar.candyBarIconFrame.OldHeight = bar.candyBarIconFrame:GetHeight()
	bar.candyBarIconFrame.OldSetWidth = bar.candyBarIconFrame.SetWidth
	bar.candyBarIconFrame.SetWidth=E.noop
	bar.candyBarIconFrame:ClearAllPoints()
	bar.candyBarIconFrame:Point("BOTTOMRIGHT", bar, "BOTTOMLEFT", -(E.PixelMode and 1 or 5), 0)
	bar.candyBarIconFrame:SetSize(buttonsize, buttonsize)
	bar.candyBarIconFrame:SetTexCoord(unpack(E.TexCoords))
end

--[[
	BigWigs load process
	-BigWigs
	-BigWigs_Core (Global 'BigWigs' is set here)
	-BigWigs_Plugins

	Note to self: BigWigs_Core as an OptionalDep breaks ElvUI saved variables if BigWigs isn't loaded.
]]
local function RegisterStyle()
	if not BigWigs then return end

	local bars = BigWigs:GetPlugin("Bars", true)

	if not bars then return end

	bars:RegisterBarStyle("ElvUI", {
		apiVersion = 1,
		version = 1,
		GetSpacing = function(bar) return 8 end,
		ApplyStyle = applystyle,
		BarStopped = freestyle,
		GetStyleName = function() return "ElvUI" end,
	})
	if prox and BigWigs.pluginCore.modules.Bars.db.profile.barStyle == "ElvUI" then
		hooksecurefunc(BigWigs.pluginCore.modules.Proximity, "RestyleWindow", function()
			BigWigsProximityAnchor:SetTemplate("Transparent")
		end)
	end
end

S:RegisterSkin('BigWigs_Plugins', RegisterStyle, nil, true)