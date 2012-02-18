local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function SkinFrame(frame)
	frame.bgMain = CreateFrame("Frame", nil, frame)
	frame.bgMain:SetTemplate("Default")
	frame.bgMain:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
	frame.bgMain:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	frame.bgMain:SetPoint("TOP", frame, "TOP", 0, -30)
	frame.bgMain:SetFrameLevel(frame:GetFrameLevel())
	frame.bgMain:SetScale(1)
	frame.bgMain.SetScale = E.noop
	
	frame.bgTitle = CreateFrame('Frame', nil, frame)
	frame.bgTitle:SetTemplate('Default', true)
	frame.bgTitle:Point("TOPRIGHT", frame, "TOPRIGHT", 0, -10)
	frame.bgTitle:Point("TOPLEFT", frame, "TOPLEFT", 0, -9)
	frame.bgTitle:Point("BOTTOM", frame, "TOP", 0, -29)
	frame.bgTitle.backdropTexture:SetVertexColor(unpack(E['media'].bordercolor))
	frame.bgTitle:SetFrameLevel(frame:GetFrameLevel())
	frame.bgTitle:SetScale(1)
	frame.bgTitle.SetScale = E.noop
	
	frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -9)
	S:HandleCloseButton(frame.CloseButton)
	S:HandleScrollBar(Recount_MainWindow_ScrollBarScrollBar)
	frame:SetBackdrop(nil)
end

local function LoadSkin()
	if E.db.skins.recount.enable ~= true then return end
	-- Override bar textures
	Recount.UpdateBarTextures = function(self)
		for k, v in pairs(Recount.MainWindow.Rows) do
			v.StatusBar:GetStatusBarTexture():SetHorizTile(false)
			v.StatusBar:GetStatusBarTexture():SetVertTile(false)
		end
	end



	-- Skin frames when they're created
	Recount.CreateFrame_ = Recount.CreateFrame
	Recount.CreateFrame = function(self, Name, Title, Height, Width, ShowFunc, HideFunc)
		local frame = self:CreateFrame_(Name, Title, Height, Width, ShowFunc, HideFunc)
		SkinFrame(frame)
		return frame
	end
	
	Recount.HideScrollbarElements_ = Recount.HideScrollbarElements
	Recount.ShowScrollbarElements_ = Recount.ShowScrollbarElements
	
	function Recount.ShowScrollbarElements(self, name)
		local scrollbar=getglobal(name.."ScrollBar")
		scrollbar:Show()
		Recount.ShowScrollbarElements_(self, name)
	end

	function Recount.HideScrollbarElements(self, name)
		local scrollbar=getglobal(name.."ScrollBar")
		scrollbar:Hide()
		Recount.HideScrollbarElements_(self, name)
	end	
	
	if Recount.db.profile.MainWindow.ShowScrollbar then
		Recount:ShowScrollbarElements("Recount_MainWindow_ScrollBar")
	else
		Recount:HideScrollbarElements("Recount_MainWindow_ScrollBar")
	end 
	
	-- skin the buttons o main window
	local PB = Recount.MainWindow.CloseButton
	local MWbuttons = {
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
			if i > 2 then
				button:GetNormalTexture():SetDesaturated(true)
				button:GetHighlightTexture():SetDesaturated(true)
				button:Size(16)
			else
				button:SetNormalTexture("")
				button:SetPushedTexture("")	
				button:SetHighlightTexture("")
				button:SetSize(16, 16)
				button.text = button:CreateFontString(nil, 'OVERLAY')
				button.text:FontTemplate()
				button.text:SetPoint('CENTER')
				button:ClearAllPoints()
				button:SetPoint("RIGHT", PB, "LEFT", -2, 0)
			end
			if button:IsShown() then
				PB = button
			end
		end
	end

	-- set our custom text inside main window buttons
	Recount.MainWindow.RightButton.text:SetText(">")
	Recount.MainWindow.LeftButton.text:SetText("<")

	
	if Recount.MainWindow then SkinFrame(Recount.MainWindow) end
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
end

S:RegisterSkin('Recount', LoadSkin)