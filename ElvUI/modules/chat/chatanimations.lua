local ElvCF = ElvCF
local ElvDB = ElvDB

------------------------------------------------------------------------
-- Chat Animation Functions
------------------------------------------------------------------------
ElvDB.ToggleSlideChatL = function()
	if ElvDB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		ElvDB.SlideOut(ChatLBackground)	
		ElvDB.ChatLIn = false
		ElvuiInfoLeftLButton.Text:SetTextColor(unpack(ElvCF["media"].valuecolor))
	else
		ElvDB.SlideIn(ChatLBackground)
		ElvDB.ChatLIn = true
		ElvuiInfoLeftLButton.Text:SetTextColor(1,1,1,1)
	end
end

ElvDB.ToggleSlideChatR = function()
	if ElvDB.ChatRIn == true then
		ElvDB.SlideOut(ChatRBackground)	
		if IsAddOnLoaded("DXE") and DXEAlertsTopStackAnchor and ElvCF["skin"].hookdxeright == true and ElvCF["chat"].rightchat == true and ElvCF["chat"].showbackdrop == true then
			DXEAlertsTopStackAnchor:ClearAllPoints()
			DXEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, -5)
		end
		ElvDB.ChatRIn = false
		ElvDB.ChatRightShown = false
		ElvuiInfoRightRButton.Text:SetTextColor(unpack(ElvCF["media"].valuecolor))
	else
		ElvDB.SlideIn(ChatRBackground)
		if IsAddOnLoaded("DXE") and DXEAlertsTopStackAnchor and ElvCF["skin"].hookdxeright == true and ElvCF["chat"].rightchat == true and ElvCF["chat"].showbackdrop == true then
			DXEAlertsTopStackAnchor:ClearAllPoints()
			DXEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, 18)
		end
		ElvDB.ChatRIn = true
		ElvDB.ChatRightShown = true
		ElvuiInfoRightRButton.Text:SetTextColor(1,1,1,1)
	end
end

--Bindings For Chat Sliders
function ChatLeft_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if ElvDB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		ElvDB.ToggleSlideChatL()
	else
		ElvDB.ToggleSlideChatL()
	end		
end

function ChatRight_HotkeyPressed(keystate)
	if keystate == "up" then return end
	ElvDB.ToggleSlideChatR()		
end

function ChatBoth_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if ElvDB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		ElvDB.ToggleSlideChatR()
		ElvDB.ToggleSlideChatL()
	else
		ElvDB.ToggleSlideChatR()
		ElvDB.ToggleSlideChatL()
	end
end