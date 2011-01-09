local TukuiCF = TukuiCF
local TukuiDB = TukuiDB

------------------------------------------------------------------------
-- Chat Animation Functions
------------------------------------------------------------------------
TukuiDB.ToggleSlideChatL = function()
	if TukuiDB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		TukuiDB.SlideOut(ChatLBackground)	
		TukuiDB.ChatLIn = false
		TukuiInfoLeftLButton.Text:SetTextColor(unpack(TukuiCF["media"].valuecolor))
	else
		TukuiDB.SlideIn(ChatLBackground)
		TukuiDB.ChatLIn = true
		TukuiInfoLeftLButton.Text:SetTextColor(1,1,1,1)
	end
end

TukuiDB.ToggleSlideChatR = function()
	if TukuiDB.ChatRIn == true then
		TukuiDB.SlideOut(ChatRBackground)	
		if IsAddOnLoaded("DXE") and DXEAlertsTopStackAnchor and TukuiCF["skin"].hookdxeright == true and TukuiCF["chat"].rightchat == true and TukuiCF["chat"].showbackdrop == true then
			DXEAlertsTopStackAnchor:ClearAllPoints()
			DXEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, -5)
		end
		TukuiDB.ChatRIn = false
		TukuiDB.ChatRightShown = false
		TukuiInfoRightRButton.Text:SetTextColor(unpack(TukuiCF["media"].valuecolor))
	else
		TukuiDB.SlideIn(ChatRBackground)
		if IsAddOnLoaded("DXE") and DXEAlertsTopStackAnchor and TukuiCF["skin"].hookdxeright == true and TukuiCF["chat"].rightchat == true and TukuiCF["chat"].showbackdrop == true then
			DXEAlertsTopStackAnchor:ClearAllPoints()
			DXEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, 18)
		end
		TukuiDB.ChatRIn = true
		TukuiDB.ChatRightShown = true
		TukuiInfoRightRButton.Text:SetTextColor(1,1,1,1)
	end
end

--Bindings For Chat Sliders
function ChatLeft_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if TukuiDB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		TukuiDB.ToggleSlideChatL()
	else
		TukuiDB.ToggleSlideChatL()
	end		
end

function ChatRight_HotkeyPressed(keystate)
	if keystate == "up" then return end
	TukuiDB.ToggleSlideChatR()		
end

function ChatBoth_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if TukuiDB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		TukuiDB.ToggleSlideChatR()
		TukuiDB.ToggleSlideChatL()
	else
		TukuiDB.ToggleSlideChatR()
		TukuiDB.ToggleSlideChatL()
	end
end