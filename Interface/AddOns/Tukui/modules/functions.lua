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


-- these chatframes are the BN chatframes and are only created when user call it.
-- it is the not the best way at all to do this, but at least for now, it work.
-- this function is temporary, i know this part of code really sux
-- 9 additionnal chatframe should be ok, i don't think we need more.
function TukuiDB.NumChat()
	TukuiDB.numChatWindows = NUM_CHAT_WINDOWS
	
	-- ok, a note for me, this part of code need to be rewritten later.
	if ChatFrame11 and not ChatFrame12 then
		TukuiDB.numChatWindows = NUM_CHAT_WINDOWS + 1
	end
	if ChatFrame12 and not ChatFrame13 then
		TukuiDB.numChatWindows = NUM_CHAT_WINDOWS + 2
	end
	if ChatFrame13 and not ChatFrame14 then
		TukuiDB.numChatWindows = NUM_CHAT_WINDOWS + 3
	end	
	if ChatFrame14 and not ChatFrame15 then
		TukuiDB.numChatWindows = NUM_CHAT_WINDOWS + 4
	end
	if ChatFrame15 and not ChatFrame16 then
		TukuiDB.numChatWindows = NUM_CHAT_WINDOWS + 5
	end
	if ChatFrame16 and not ChatFrame17 then
		TukuiDB.numChatWindows = NUM_CHAT_WINDOWS + 6
	end
	if ChatFrame17 and not ChatFrame18 then
		TukuiDB.numChatWindows = NUM_CHAT_WINDOWS + 7
	end						
	if ChatFrame18 and not ChatFrame19 then
		TukuiDB.numChatWindows = NUM_CHAT_WINDOWS + 8
	end								
	if ChatFrame19 then
		TukuiDB.numChatWindows = NUM_CHAT_WINDOWS + 9
	end
	
	if TukuiDB.SetupChatComplete == true then
		TukuiDB.SetupChat()
		TukuiDB.ChannelsEdits()
		TukuiDB.LinkMeURL()
		TukuiDB.HyperlinkMouseover()
		TukuiDB.ChatCopyButtons()
		TukuiDB.TabsMouseover()
	end
end
TukuiDB.NumChat()
hooksecurefunc("FCF_OpenTemporaryWindow", TukuiDB.NumChat)








