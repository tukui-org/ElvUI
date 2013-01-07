local E, L, V, P, G,_ = unpack(ElvUI)
local AS = E:GetModule('AddOnSkins')
local S = E:GetModule('Skins')

local name = "RecountSkin"
local function SkinRecount(self)
	local Recount = _G.Recount

	local function SkinFrame(frame)
		frame.bgMain = CreateFrame("Frame", nil, frame)
		frame.bgMain:SetTemplate("Transparent")
		frame.bgMain:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
		frame.bgMain:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
		frame.bgMain:SetPoint("TOP", frame, "TOP", 0, -7)
		frame.bgMain:SetFrameLevel(frame:GetFrameLevel())
		frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -9)
		frame:SetBackdrop(nil)
		frame.TitleBackground = CreateFrame("Frame", nil, frame.bgMain)
		frame.TitleBackground:SetPoint("TOP", 0)
		frame.TitleBackground:SetPoint("LEFT", 0)
		frame.TitleBackground:SetPoint("RIGHT", 0)
		frame.TitleBackground:SetHeight(24)
		frame.TitleBackground:SetTemplate("Transparent")
		frame.Title:SetParent(frame.TitleBackground)
		frame.Title:ClearAllPoints()
		frame.Title:SetPoint("LEFT", 4, 0)
		if not Recount_MainWindow then S:HandleCloseButton(frame.CloseButton) end
	end

	local function SkinMainFrame(frame)
		frame.bgMain = CreateFrame("Frame", nil, frame)
		frame.bgMain:SetTemplate("Default")
		frame.bgMain:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
		frame.bgMain:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
		frame.bgMain:SetPoint("TOP", frame, "TOP", 0, -7)
		frame.bgMain:SetFrameLevel(frame:GetFrameLevel())
		if (not AS:CheckOption("RecountBackdrop")) then frame.bgMain:Hide() end
		frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -9)
		frame:SetBackdrop(nil)
		frame.TitleBackground = CreateFrame("Frame", nil, frame)
		frame.TitleBackground:SetPoint("TOP", frame, "TOP", 0, -7)
		frame.TitleBackground:SetPoint("LEFT", 0)
		frame.TitleBackground:SetPoint("RIGHT", 0)
		frame.TitleBackground:SetHeight(24)
		frame.TitleBackground:SetTemplate("Transparent")
		frame.Title:SetParent(frame.TitleBackground)
		frame.Title:ClearAllPoints()
		frame.Title:SetPoint("LEFT", 4, 0)
		if not Recount_MainWindow then S:HandleCloseButton(frame.CloseButton) end
	end

	Recount.UpdateBarTextures = function(self)
		for k, v in pairs(Recount.MainWindow.Rows) do
			v.StatusBar:SetStatusBarTexture(AS.LSM:Fetch("statusbar",E.private.general.normTex))
			v.StatusBar:GetStatusBarTexture():SetHorizTile(false)
			v.StatusBar:GetStatusBarTexture():SetVertTile(false)
			if IsAddOnLoaded("Tukui") then
				v.LeftText:SetPoint("LEFT", 4, 0)
				v.RightText:SetPoint("RIGHT", -4, 0)
			end
		end
	end
	Recount.SetBarTextures = Recount.UpdateBarTextures

	Recount.SetupBar_ = Recount.SetupBar
	Recount.SetupBar = function(self, bar)
		self:SetupBar_(bar)
		bar.StatusBar:SetStatusBarTexture(AS.LSM:Fetch("statusbar",E.private.general.normTex))
	end

	Recount.CreateFrame_ = Recount.CreateFrame
	Recount.CreateFrame = function(self, Name, Title, Height, Width, ShowFunc, HideFunc)
		local frame = self:CreateFrame_(Name, Title, Height, Width, ShowFunc, HideFunc)
		SkinFrame(frame)
		return frame
	end

		if Recount.MainWindow then SkinMainFrame(Recount.MainWindow) Recount.MainWindow:SetFrameStrata("MEDIUM") end
		if Recount.ConfigWindow then SkinFrame(Recount.ConfigWindow) end
		if Recount.GraphWindow then SkinFrame(Recount.GraphWindow) end
		if Recount.DetailWindow then SkinFrame(Recount.DetailWindow) end
		if Recount.ResetFrame then SkinFrame(Recount.ResetFrame) end
		if _G["Recount_Realtime_!RAID_DAMAGE"] then SkinFrame(_G["Recount_Realtime_!RAID_DAMAGE"].Window) end
		if _G["Recount_Realtime_!RAID_HEALING"] then SkinFrame(_G["Recount_Realtime_!RAID_HEALING"].Window) end
		if _G["Recount_Realtime_!RAID_HEALINGTAKEN"] then SkinFrame(_G["Recount_Realtime_!RAID_HEALINGTAKEN"].Window) end
		if _G["Recount_Realtime_!RAID_DAMAGETAKEN"] then SkinFrame(_G["Recount_Realtime_!RAID_DAMAGETAKEN"].Window) end
		if _G["Recount_Realtime_Bandwidth Available_AVAILABLE_BANDWIDTH"] then SkinFrame(_G["Recount_Realtime_Bandwidth Available_AVAILABLE_BANDWIDTH"].Window) end
		if _G["Recount_Realtime_FPS_FPS"] then SkinFrame(_G["Recount_Realtime_FPS_FPS"].Window) end
		if _G["Recount_Realtime_Latency_LAG"] then SkinFrame(_G["Recount_Realtime_Latency_LAG"].Window) end
		if _G["Recount_Realtime_Downstream Traffic_DOWN_TRAFFIC"] then SkinFrame(_G["Recount_Realtime_Downstream Traffic_DOWN_TRAFFIC"].Window) end
		if _G["Recount_Realtime_Upstream Traffic_UP_TRAFFIC"] then SkinFrame(_G["Recount_Realtime_Upstream Traffic_UP_TRAFFIC"].Window) end

	Recount:UpdateBarTextures()

	S:HandleScrollBar(Recount_MainWindow_ScrollBarScrollBar)
	hooksecurefunc(Recount,"RefreshMainWindow",function(self,datarefresh)
	 	if not Recount.db.profile.MainWindow.ShowScrollbar then
			Recount_MainWindow_ScrollBarScrollBar:Hide()
		else
			Recount_MainWindow_ScrollBarScrollBar:Show()
		end
	end)

	Recount.MainWindow.FileButton:HookScript("OnClick", function(self) if LibDropdownFrame0 then LibDropdownFrame0:SetTemplate() end end)

	local MWbuttons = {
		Recount.MainWindow.CloseButton,
		Recount.MainWindow.RightButton,
		Recount.MainWindow.LeftButton,
		Recount.MainWindow.ResetButton,
		Recount.MainWindow.FileButton,
		Recount.MainWindow.ConfigButton,
		Recount.MainWindow.ReportButton,
	}
	for i = 1, getn(MWbuttons) do
		local button = MWbuttons[i]
		if button then
			button:GetNormalTexture():SetDesaturated(true)
			button:GetHighlightTexture():SetDesaturated(true)
		end
	end
	AS:Desaturate(Recount.DetailWindow.RightButton)
	AS:Desaturate(Recount.DetailWindow.LeftButton)
	AS:Desaturate(Recount.DetailWindow.ReportButton)
	AS:Desaturate(Recount.DetailWindow.SummaryButton)
end

AS:RegisterSkin(name,SkinRecount)