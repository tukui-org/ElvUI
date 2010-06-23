function TukuiDB:UIScale()
	-- the tukui high reso whitelist
	if not (TukuiDB.getscreenresolution == "1680x945"
		or TukuiDB.getscreenresolution == "2560x1440" 
		or TukuiDB.getscreenresolution == "1680x1050" 
		or TukuiDB.getscreenresolution == "1920x1080" 
		or TukuiDB.getscreenresolution == "1920x1200" 
		or TukuiDB.getscreenresolution == "1600x900" 
		or TukuiDB.getscreenresolution == "2048x1152" 
		or TukuiDB.getscreenresolution == "1776x1000" 
		or TukuiDB.getscreenresolution == "2560x1600" 
		or TukuiDB.getscreenresolution == "1600x1200") then
			if TukuiDB["general"].overridelowtohigh == true then
				TukuiDB["general"].autoscale = false
				TukuiDB.lowversion = false
			else
				TukuiDB.lowversion = true
			end			
	end

	if TukuiDB["general"].autoscale == true then
		-- i'm putting a autoscale feature mainly for an easy auto install process
		-- we all know that it's not very effective to play via 1024x768 on an 0.64 uiscale :P
		-- with this feature on, it should auto choose a very good value for your current reso!
		TukuiDB["general"].uiscale = 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
	end

	if TukuiDB.lowversion then
		TukuiDB.raidscale = 0.8
	else
		TukuiDB.raidscale = 1
	end
end
TukuiDB:UIScale()

-- pixel perfect script of custom ui scale.
local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/TukuiDB["general"].uiscale
local function scale(x)
    return mult*math.floor(x/mult+.5)
end

function TukuiDB:Scale(x) return scale(x) end
TukuiDB.mult = mult

function TukuiDB:CreatePanel(f, w, h, a1, p, a2, x, y)
	sh = scale(h)
	sw = scale(w)
	f:SetFrameLevel(1)
	f:SetHeight(sh)
	f:SetWidth(sw)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, x, y)
	f:SetBackdrop({
	  bgFile = TukuiDB["media"].blank, 
	  edgeFile = TukuiDB["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = mult, 
	  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	f:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
	f:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
end

function TukuiDB:SetTemplate(f)
	f:SetBackdrop({
	  bgFile = TukuiDB["media"].blank, 
	  edgeFile = TukuiDB["media"].blank, 
	  tile = false, tileSize = 0, edgeSize = mult, 
	  insets = { left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	f:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
	f:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
end

function TukuiDB.TempChatSkin()
	if TukuiDB["chat"].enable ~= true then return end
	local chatFrame, chatTab, conversationIcon
	for _, chatFrameName in pairs(CHAT_FRAMES) do
		local frame = _G[chatFrameName]
		if frame.isTemporary then
				chatFrame = frame
				chatTab = _G[chatFrame:GetName().."Tab"]
				
				chatTab.noMouseAlpha = 0
				
				_G[chatFrame:GetName()]:SetClampRectInsets(0,0,0,0)
				_G[chatFrame:GetName()]:SetWidth(TukuiDB:Scale(TukuiDB["panels"].tinfowidth + 1))
				_G[chatFrame:GetName()]:SetHeight(TukuiDB:Scale(111))

				_G[chatFrame:GetName().."ButtonFrameUpButton"]:Hide()
				_G[chatFrame:GetName().."ButtonFrameDownButton"]:Hide()
				_G[chatFrame:GetName().."ButtonFrameBottomButton"]:Hide()
				_G[chatFrame:GetName().."ButtonFrameMinimizeButton"]:Hide()
				_G[chatFrame:GetName().."ResizeButton"]:Hide()
				_G[chatFrame:GetName().."ButtonFrame"]:Hide()

				_G[chatFrame:GetName().."ButtonFrameUpButton"]:SetScript("OnShow", function(self) self:Hide() end)
				_G[chatFrame:GetName().."ButtonFrameDownButton"]:SetScript("OnShow", function(self) self:Hide() end)
				_G[chatFrame:GetName().."ButtonFrameBottomButton"]:SetScript("OnShow", function(self) self:Hide() end)
				_G[chatFrame:GetName().."ButtonFrameMinimizeButton"]:SetScript("OnShow", function(self) self:Hide() end)
				_G[chatFrame:GetName().."ResizeButton"]:SetScript("OnShow", function(self) self:Hide() end)
				_G[chatFrame:GetName().."ButtonFrame"]:SetScript("OnShow", function(self) self:Hide() end)

				_G[chatFrame:GetName().."TabLeft"]:SetTexture(nil)
				_G[chatFrame:GetName().."TabMiddle"]:SetTexture(nil)
				_G[chatFrame:GetName().."TabRight"]:SetTexture(nil)
				
				_G[chatFrame:GetName().."TabSelectedLeft"]:SetTexture(nil)
				_G[chatFrame:GetName().."TabSelectedMiddle"]:SetTexture(nil)
				_G[chatFrame:GetName().."TabSelectedRight"]:SetTexture(nil)
				
				_G[chatFrame:GetName().."TabHighlightLeft"]:SetTexture(nil)
				_G[chatFrame:GetName().."TabHighlightMiddle"]:SetTexture(nil)
				_G[chatFrame:GetName().."TabHighlightRight"]:SetTexture(nil)

				-- Stop the chat frame from fading out
				_G[chatFrame:GetName()]:SetFading(false)
				
				-- Change the chat frame font 
				_G[chatFrame:GetName()]:SetFont(TukuiDB["chat"].font, TukuiDB["chat"].fontsize)
				
				-- Set random stuff
				_G[chatFrame:GetName()]:SetFrameStrata("LOW")
				_G[chatFrame:GetName()]:SetMovable(true)
				_G[chatFrame:GetName()]:SetUserPlaced(true)
				
				-- Hide tab texture
				for j = 1, #CHAT_FRAME_TEXTURES do
					_G[chatFrame:GetName()..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
				end
				break
		end
	end
end
hooksecurefunc("FCF_OpenTemporaryWindow", TukuiDB.TempChatSkin)








