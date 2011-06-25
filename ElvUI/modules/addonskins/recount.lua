local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


if not IsAddOnLoaded("Recount") or not C["skin"].recount == true then return end
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
end

-- Override bar textures
Recount.UpdateBarTextures = function(self)
	for k, v in pairs(Recount.MainWindow.Rows) do
		v.StatusBar:SetStatusBarTexture(C["media"].normTex)
		v.StatusBar:GetStatusBarTexture():SetHorizTile(false)
		v.StatusBar:GetStatusBarTexture():SetVertTile(false)
	end
	Recount:SetFont("ElvUI Font")
end
Recount.SetBarTextures = Recount.UpdateBarTextures

-- Fix bar textures as they're created
Recount.SetupBar_ = Recount.SetupBar
Recount.SetupBar = function(self, bar)
	self:SetupBar_(bar)
	bar.StatusBar:SetStatusBarTexture(C["media"].normTex)
end

-- Skin frames when they're created
Recount.CreateFrame_ = Recount.CreateFrame
Recount.CreateFrame = function(self, Name, Title, Height, Width, ShowFunc, HideFunc)
	local frame = self:CreateFrame_(Name, Title, Height, Width, ShowFunc, HideFunc)
	SkinFrame(frame)
	return frame
end

-- Skin existing frames
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

--Update Textures
Recount:UpdateBarTextures()

if C["skin"].embedright == "Recount" then
	local Recount_Skin = CreateFrame("Frame")
	Recount_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
	Recount_Skin:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		self = nil

		Recount_MainWindow:ClearAllPoints()
		Recount_MainWindow:SetPoint("TOPLEFT", ChatRPlaceHolder,"TOPLEFT", 0, 7)
		Recount_MainWindow:SetPoint("BOTTOMRIGHT", ChatRPlaceHolder,"BOTTOMRIGHT", 0, 0)
		Recount.db.profile.FrameStrata = "3-MEDIUM"
		Recount.db.profile.MainWindowWidth = (C["chat"].chatwidth - 4)	
	end)
	
	if ChatRBGTab then
		local button = CreateFrame('Button', 'RecountToggleSwitch', ChatRBGTab)
		button:Width(90)
		button:Height(ChatRBGTab:GetHeight() - 4)
		button:Point("RIGHT", ChatRBGTab, "RIGHT", -2, 0)
		
		button.tex = button:CreateTexture(nil, 'OVERLAY')
		button.tex:SetTexture([[Interface\AddOns\ElvUI\media\textures\vehicleexit.tga]])
		button.tex:Point('TOPRIGHT', -2, -2)
		button.tex:Height(button:GetHeight() - 4)
		button.tex:Width(16)
		
		button:FontString(nil, C["media"].font, 12, 'THINOUTLINE')
		button.text:SetPoint('RIGHT', button.tex, 'LEFT')
		button.text:SetTextColor(unpack(C["media"].valuecolor))
		
		button:SetScript('OnEnter', function(self) button.text:SetText(L.addons_toggle..' Recount') end)
		button:SetScript('OnLeave', function(self) self.tex:Point('TOPRIGHT', -2, -2); button.text:SetText(nil) end)
		button:SetScript('OnMouseDown', function(self) self.tex:Point('TOPRIGHT', -4, -4) end)
		button:SetScript('OnMouseUp', function(self) self.tex:Point('TOPRIGHT', -2, -2) end)
		button:SetScript('OnClick', function(self) ToggleFrame(Recount_MainWindow) end)
	end	
	
	if C["skin"].embedrighttoggle == true then
		ChatRBG:HookScript("OnShow", function() Recount_MainWindow:Hide() end)
		ChatRBG:HookScript("OnHide", function() Recount_MainWindow:Show() end)
	end	
end