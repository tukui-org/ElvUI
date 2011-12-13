--------------------------------------------------------
-- Credits --
--------------------------------------------------------
-- Elv
-- the Tuk/Elv community for making this possible!
-- 
--
--------------------------------------------------------
-- System Settable Variables --
--------------------------------------------------------
local E, L, DF = unpack(ElvUI); --Engine
local DT = E:GetModule('DataTexts')

ElvUI_DTbar = CreateFrame('Frame', 'ElvUI_DTbar', E.UIParent)

local bottom_bar, rchat_tab1, rchat_tab2
local PANEL_HEIGHT = 22 -- taken from Layout.lua


--------------------------------------------------------
-- DB Variables --
--------------------------------------------------------
db = db or { -- saved variables
	Bottom_Datatext_Panel = true,
	RightChatTab_Datatext_Panel1 = true,
	RightChatTab_Datatext_Panel2 = true,
}

-- description as shown in /ec -> datatext;  L['panel name'] = 'description';
L['Bottom_Datatext_Panel'] = 'Action Bar 1 (Bottom) Data Panel';
L['RightChatTab_Datatext_Panel1'] = "Upper Right Chat Panel 1";
L['RightChatTab_Datatext_Panel2'] = "Upper Right Chat Panel 2";
--------------------------------------------------------


--------------------------------------------------------
--Bottom_Datatext_Panel
DF.datatexts.panels.spec1.Bottom_Datatext_Panel = {
	left = 'Friends',
	middle = 'Spec Switch',
	right = 'Guild',
}

DF.datatexts.panels.spec2.Bottom_Datatext_Panel = {
	left = 'Friends',
	middle = 'Spec Switch',
	right = 'Guild',
}
 
-- Right Chat Tab Panel 1
DF.datatexts.panels.spec1.RightChatTab_Datatext_Panel1 = 'Call to Arms'
DF.datatexts.panels.spec2.RightChatTab_Datatext_Panel1 = 'Call to Arms'

-- Right Chat Tab Panel 2
DF.datatexts.panels.spec1.RightChatTab_Datatext_Panel2 = 'Bags'
DF.datatexts.panels.spec2.RightChatTab_Datatext_Panel2 = 'Bags'
--------------------------------------------------


--------------------------------------------------------
-- Code  --
--------------------------------------------------------


--------------------------------------------------------
-- right chat tabbar1
--------------------------------------------------------
local function rchat_tab1_setup()
	do
		rchat_tab1:Size((RightChatPanel:GetWidth() / 3),PANEL_HEIGHT)
		rchat_tab1:Point("RIGHT", RightChatTab_Datatext_Panel2, "LEFT")
		rchat_tab1:SetFrameStrata('LOW')
		RightChatTab:HookScript("OnHide", function() rchat_tab1:Hide() end)
		RightChatTab:HookScript("OnShow", function() rchat_tab1:Show() end)		
	end
end

 do
	rchat_tab1 = CreateFrame('Frame', 'RightChatTab_Datatext_Panel1', E.UIParent)
	DT:RegisterPanel(rchat_tab1, 1, 'ANCHOR_BOTTOM', 0, -4)
	rchat_tab1:Hide()
end
--- 
 
 
--------------------------------------------------------
-- right chat tabbar2
--------------------------------------------------------
local function rchat_tab2_setup()
	do
		rchat_tab2:Size((RightChatPanel:GetWidth() / 3),PANEL_HEIGHT)
		rchat_tab2:Point("TOPRIGHT", RightChatTab, "TOPRIGHT", -16, 0)
		rchat_tab2:SetFrameStrata('LOW')
		RightChatTab:HookScript("OnHide", function() rchat_tab2:Hide() end)
		RightChatTab:HookScript("OnShow", function() rchat_tab2:Show() end)		
	end
end

 do
	rchat_tab2 = CreateFrame('Frame', 'RightChatTab_Datatext_Panel2', E.UIParent)
	DT:RegisterPanel(rchat_tab2, 1, 'ANCHOR_BOTTOM', 0, -4)
	rchat_tab2:Hide()
end


--------------------------------------------------------
-- bottom bar					
--------------------------------------------------------
do
	bottom_bar = CreateFrame('Frame', 'Bottom_Datatext_Panel', E.UIParent)
	bottom_bar:SetTemplate('Default', true)
	bottom_bar:SetFrameStrata('BACKGROUND')
	bottom_bar:SetScript('OnShow', function(self) 
		self:Point("TOPLEFT", ElvUI_Bar1, "BOTTOMLEFT", 0, -E.mult); 
		self:Size(ElvUI_Bar1:GetWidth(), PANEL_HEIGHT); 
		E:CreateMover(self, "BottomBarMover", "Bottom Datatext Frame") 
	end)
	bottom_bar:Hide()
	DT:RegisterPanel(bottom_bar, 3, 'ANCHOR_BOTTOM', 0, -4)
end

-- table O tables! we parse and check for GetName() to toggle show/hide :) saves some very nasty lines of code.
ElvUI_DTbar._table = {
	bottom_bar,
	rchat_tab1,
	rchat_tab2,
}

ElvUI_DTbar.db = db

 local function SlashHandler(command)
	if command == 'show all' then						-- show all
		for k,v in ipairs(ElvUI_DTbar._table) do v:Show() db[v:GetName()] = true end
	elseif command:match("^show .*") then				-- show <bar> --> this line is pure beauty
		command = command:gsub("^show ","")
		for k,v in ipairs(ElvUI_DTbar._table) do if (v:GetName():lower():match(command:lower())) then v:Show() db[v:GetName()] = true end end
	elseif command == 'hide all' then					-- hide all
		for k,v in ipairs(ElvUI_DTbar._table) do v:Hide() db[v:GetName()] = false end
	elseif command:match("^hide .*") then				-- hide <bar>  --> this line is pure beauty
		command = command:gsub("^hide ","")
		for k,v in ipairs(ElvUI_DTbar._table) do if (v:GetName():lower():match(command:lower())) then v:Hide() db[v:GetName()] = false end end
	elseif command == 'list' then						-- list
		for k,v in ipairs(ElvUI_DTbar._table) do print ('Frame: '..v:GetName()) end 
	else							-- syntax
		print ('\
			commands are:\
/dtbar show <frameName>\
/dtbar show all\
/dtbar hide <frameName>\
/dtbar hide all\
/dtbar list\
')
	end	
end


function DT:PLAYER_ENTERING_WORLD(...)
	SlashCmdList["ElvUI_DTbar"] = SlashHandler
	SLASH_ElvUI_DTbar1 = "/dtbar"

	rchat_tab1_setup()
	rchat_tab2_setup()
	if db.Bottom_Datatext_Panel then bottom_bar:Show() end
	if db.RightChatTab_Datatext_Panel1 then rchat_tab1:Show() end
	if db.RightChatTab_Datatext_Panel2 then rchat_tab2:Show() end
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

DT:RegisterEvent('PLAYER_ENTERING_WORLD')