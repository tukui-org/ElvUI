local E, L, DF = unpack(select(2, ...)); --Engine
local S = E:GetModule('Skins')

local function SkinFrame(frame)
	frame.bgMain = CreateFrame("Frame", nil, frame)
	frame.bgMain:SetTemplate("Transparent")
	frame.bgMain:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
	frame.bgMain:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	frame.bgMain:SetPoint("TOP", frame, "TOP", 0, -30)
	frame.bgMain:SetFrameLevel(frame:GetFrameLevel())
	
	frame.bgTitle = CreateFrame('Frame', nil, frame)
	frame.bgTitle:SetTemplate('Default', true)
	frame.bgTitle:Point("TOPRIGHT", frame, "TOPRIGHT", 0, -10)
	frame.bgTitle:Point("TOPLEFT", frame, "TOPLEFT", 0, -9)
	frame.bgTitle:Point("BOTTOM", frame, "TOP", 0, -29)
	frame.bgTitle.backdropTexture:SetVertexColor(unpack(E['media'].bordercolor))
	frame.bgTitle:SetFrameLevel(frame:GetFrameLevel())
	
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