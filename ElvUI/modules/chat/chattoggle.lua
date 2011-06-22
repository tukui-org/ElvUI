local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

------------------------------------------------------------------------
-- Chat Toggle Functions
------------------------------------------------------------------------
E.ToggleSlideChatL = function()
	if E.ChatLIn == true then
		ChatLBG:Hide()
		E.ChatLIn = false
		ElvuiInfoLeftLButton.text:SetTextColor(unpack(C["media"].valuecolor))
	else
		ChatLBG:Show()
		E.ChatLIn = true
		ElvuiInfoLeftLButton.text:SetTextColor(1,1,1,1)
	end
end

E.ToggleSlideChatR = function()
	if E.RightChat ~= true then return end
	if E.ChatRIn == true then
		E.ChatRightShown = false
		ChatRBG:Hide()	
		E.ChatRIn = false
		ElvuiInfoRightRButton.text:SetTextColor(unpack(C["media"].valuecolor))
	else
		E.ChatRightShown = true
		ChatRBG:Show()
		E.ChatRIn = true
		ElvuiInfoRightRButton.text:SetTextColor(1,1,1,1)
	end
end

--Bindings For Chat Sliders
function ChatLeft_HotkeyPressed(keystate)
	if keystate == "up" then return end
	if E.ChatLIn == true then
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

--Setup Button Scripts
ElvuiInfoLeftLButton:SetScript("OnMouseDown", function(self, btn)
	if btn == "RightButton" then
		E.ToggleSlideChatR()
		E.ToggleSlideChatL()
	else
		E.ToggleSlideChatL()	
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