--[[
	Recount Skin by Darth Android / Telroth - Black Dragonflight
	
	Skins Recount to look like TelUI.
	
	Todo:
	 + Reorganize to support skin subclass overrides
	 + Reorganize to support layout subclass overrides
	 + Skin "Reset Data" windows
	 
	(C)2010 Darth Android / Telroth - Black Dragonflight
	File version v15.37
]]
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


if not IsAddOnLoaded("Recount") or not Mod_AddonSkins or not C["skin"].recount == true then return end
local Recount = _G.Recount

Mod_AddonSkins:RegisterSkin("Recount",function(Skin, skin, Layout, layout, config)

	local function SkinFrame(frame)
	    frame.bgMain = CreateFrame("Frame",nil,frame)
	    skin:SkinBackgroundFrame(frame.bgMain)
	    frame.bgMain:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT")
	    frame.bgMain:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT")
	    frame.bgMain:SetPoint("TOP",frame,"TOP",0,-7)
		if frame:GetName() == "Recount_MainWindow" then
			frame.bgMain:SetFrameStrata("MEDIUM")
		else
			frame.bgMain:SetFrameStrata("BACKGROUND")
		end
	    frame.bgMain:SetFrameLevel(31)
	    frame.CloseButton:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-1,-9)
		frame:SetBackdrop(nil)
	end
	
	-- Override bar textures
	Recount.UpdateBarTextures = function(self)
		for k, v in pairs(Recount.MainWindow.Rows) do
			v.StatusBar:SetStatusBarTexture(config.normTexture)
			v.StatusBar:GetStatusBarTexture():SetHorizTile(false)
			v.StatusBar:GetStatusBarTexture():SetVertTile(false)
		end
		Recount:SetFont("Elvui Font")
	end
	Recount.SetBarTextures = Recount.UpdateBarTextures
	
	-- Fix bar textures as they're created
	Recount.SetupBar_ = Recount.SetupBar
	Recount.SetupBar = function(self, bar)
		self:SetupBar_(bar)
		bar.StatusBar:SetStatusBarTexture(config.normTexture)
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
	-- Let's update me some textures!
	Recount:UpdateBarTextures()
end)
