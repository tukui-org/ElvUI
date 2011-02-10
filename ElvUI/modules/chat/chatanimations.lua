
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

------------------------------------------------------------------------
-- Chat Animation Functions
------------------------------------------------------------------------
E.ToggleSlideChatL = function()
	if E.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		E.SlideOut(ChatLBackground)	
		E.ChatLIn = false
		ElvuiInfoLeftLButton.text:SetTextColor(unpack(C["media"].valuecolor))
	else
		E.SlideIn(ChatLBackground)
		E.ChatLIn = true
		ElvuiInfoLeftLButton.text:SetTextColor(1,1,1,1)
	end
end

E.ToggleSlideChatR = function()
	if E.RightChat ~= true then return end
	if E.ChatRIn == true then
		E.SlideOut(ChatRBackground)	
		if IsAddOnLoaded("KLE") and KLEAlertsTopStackAnchor and C["skin"].hookkleright == true and C["chat"].showbackdrop == true then
			KLEAlertsTopStackAnchor:ClearAllPoints()
			KLEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, -5)
		end		
		E.ChatRIn = false
		E.ChatRightShown = false
		ElvuiInfoRightRButton.text:SetTextColor(unpack(C["media"].valuecolor))
	else
		E.SlideIn(ChatRBackground)
		if IsAddOnLoaded("KLE") and KLEAlertsTopStackAnchor and C["skin"].hookkleright == true and C["chat"].showbackdrop == true then
			KLEAlertsTopStackAnchor:ClearAllPoints()
			KLEAlertsTopStackAnchor:SetPoint("BOTTOM", ChatRBackground2, "TOP", 13, 18)
		end		
		E.ChatRIn = true
		E.ChatRightShown = true
		ElvuiInfoRightRButton.text:SetTextColor(1,1,1,1)
	end
end

--Bindings For Chat Sliders
function ChatLeft_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if E.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end
		E.ToggleSlideChatL()
	else
		E.ToggleSlideChatL()
	end		
end

function ChatRight_HotkeyPressed(keystate)
	if keystate == "up" then return end
	E.ToggleSlideChatR()		
end

function ChatBoth_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if E.ChatLIn == true then
		E.ToggleSlideChatR()
		E.ToggleSlideChatL()
	else
		E.ToggleSlideChatR()
		E.ToggleSlideChatL()
	end
end

--Fixes chat windows not displaying
ChatLBackground.anim_o:HookScript("OnFinished", function()
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local tab = _G[format("ChatFrame%sTab", i)]
		local id = chat:GetID()
		local point = GetChatWindowSavedPosition(id)
		local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
		chat:SetParent(tab)
	end
end)

ChatLBackground.anim_o:HookScript("OnPlay", function()
	if E.ChatLIn == true then
		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G[format("ChatFrame%s", i)]
			local tab = _G[format("ChatFrame%sTab", i)]
			chat:SetParent(tab)
		end		
	end
end)

ChatLBackground.anim:HookScript("OnFinished", function()
	if E.RightChat ~= true then return end
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local id = chat:GetID()
		local point = GetChatWindowSavedPosition(id)
		local _, _, _, _, _, _, _, _, docked, _ = GetChatWindowInfo(id)
		chat:SetParent(UIParent)
		
		if i == E.RightChatWindowID then
			chat:SetParent(_G[format("ChatFrame%sTab", i)])
		else
			chat:SetParent(UIParent)
		end
	end
	ElvuiInfoLeft.shadow:SetBackdropBorderColor(0,0,0,1)
	ElvuiInfoLeft:SetScript("OnUpdate", function() end)
	E.StopFlash(ElvuiInfoLeft.shadow)
end)

ChatRBackground.anim_o:HookScript("OnPlay", function()
	if E.RightChat ~= true or not E.RightChatWindowID then return end
	local chat = _G[format("ChatFrame%s", E.RightChatWindowID)]
	chat:SetParent(_G[format("ChatFrame%sTab", E.RightChatWindowID)])
	chat:SetFrameStrata("LOW")
end)

ChatRBackground.anim:HookScript("OnFinished", function()
	if E.RightChat ~= true or not E.RightChatWindowID then return end
	local chat = _G[format("ChatFrame%d", E.RightChatWindowID)]
	chat:SetParent(UIParent)
	chat:SetFrameStrata("LOW")
	ElvuiInfoRight.shadow:SetBackdropBorderColor(0,0,0,1)
	ElvuiInfoRight:SetScript("OnUpdate", function() end)
	E.StopFlash(ElvuiInfoRight.shadow)
end)

--Setup Button Scripts
ElvuiInfoLeftLButton:SetScript("OnMouseDown", function(self, btn)
	if btn == "RightButton" then
		if E.ChatLIn == true then
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				local tab = _G[format("ChatFrame%sTab", i)]
				chat:SetParent(tab)
			end
			E.ToggleSlideChatR()
			E.ToggleSlideChatL()
		else
			E.ToggleSlideChatR()
			E.ToggleSlideChatL()
		end	
	else
		if E.ChatLIn == true then
			for i = 1, NUM_CHAT_WINDOWS do
				local chat = _G[format("ChatFrame%s", i)]
				local tab = _G[format("ChatFrame%sTab", i)]
				chat:SetParent(tab)
			end
			E.ToggleSlideChatL()
		else
			E.ToggleSlideChatL()
		end		
	end
end)

ElvuiInfoRightRButton:SetScript("OnMouseDown", function(self, btn)
	if E.RightChat ~= true then return end
	if btn == "RightButton" then
		E.ToggleSlideChatR()
		E.ToggleSlideChatL()
	else
		E.ToggleSlideChatR()
	end
end)