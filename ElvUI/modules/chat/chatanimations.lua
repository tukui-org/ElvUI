
local DB, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

------------------------------------------------------------------------
-- Chat Animation Functions
------------------------------------------------------------------------
DB.ToggleSlideChatL = function()
	if DB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		DB.SlideOut(ChatLBackground)	
		DB.ChatLIn = false
		ElvuiInfoLeftLButton.Text:SetTextColor(unpack(C["media"].valuecolor))
	else
		DB.SlideIn(ChatLBackground)
		DB.ChatLIn = true
		ElvuiInfoLeftLButton.Text:SetTextColor(1,1,1,1)
	end
end

DB.ToggleSlideChatR = function()
	if DB.ChatRIn == true then
		DB.SlideOut(ChatRBackground)	
		if IsAddOnLoaded("DXE") and DXEAlertsTopStackAnchor and C["skin"].hookdxeright == true and C["chat"].rightchat == true and C["chat"].showbackdrop == true then
			DXEAlertsTopStackAnchor:ClearAllPoints()
			DXEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, -5)
		end
		DB.ChatRIn = false
		DB.ChatRightShown = false
		ElvuiInfoRightRButton.Text:SetTextColor(unpack(C["media"].valuecolor))
	else
		DB.SlideIn(ChatRBackground)
		if IsAddOnLoaded("DXE") and DXEAlertsTopStackAnchor and C["skin"].hookdxeright == true and C["chat"].rightchat == true and C["chat"].showbackdrop == true then
			DXEAlertsTopStackAnchor:ClearAllPoints()
			DXEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, 18)
		end
		DB.ChatRIn = true
		DB.ChatRightShown = true
		ElvuiInfoRightRButton.Text:SetTextColor(1,1,1,1)
	end
end

--Bindings For Chat Sliders
function ChatLeft_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if DB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		DB.ToggleSlideChatL()
	else
		DB.ToggleSlideChatL()
	end		
end

function ChatRight_HotkeyPressed(keystate)
	if keystate == "up" then return end
	DB.ToggleSlideChatR()		
end

function ChatBoth_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if DB.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		DB.ToggleSlideChatR()
		DB.ToggleSlideChatL()
	else
		DB.ToggleSlideChatR()
		DB.ToggleSlideChatL()
	end
end