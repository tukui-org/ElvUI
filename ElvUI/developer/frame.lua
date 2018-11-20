--Cache global variables
--Lua functions
local _G = _G
local print, tostring, select = print, tostring, select
local strlower = strlower
local format = format
--WoW API / Variables
local GetMouseFocus = GetMouseFocus
local FrameStackTooltip_Toggle = FrameStackTooltip_Toggle
local IsAddOnLoaded = IsAddOnLoaded
local GetAddOnInfo = GetAddOnInfo
local LoadAddOn = LoadAddOn

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: SLASH_FRAME1, SLASH_FRAMELIST1, SLASH_TEXLIST1, FRAME, ChatFrame1
-- GLOBALS: FrameStackTooltip, UIParentLoadAddOn, CopyChatFrame, ElvUI
-- GLOBALS: SLASH_GETPOINT1, SLASH_DEV1, ElvUIDev

--[[
	Command to grab frame information when mouseing over a frame

	Frame Name
	Width
	Height
	Strata
	Level
	X Offset
	Y Offset
	Point
]]

SLASH_FRAME1 = "/frame"
SlashCmdList["FRAME"] = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end
	if arg ~= nil then FRAME = arg end --Set the global variable FRAME to = whatever we are mousing over to simplify messing with frames that have no name.
	if arg ~= nil and arg:GetName() ~= nil then
		local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
		ChatFrame1:AddMessage("|cffCC0000----------------------------")
		ChatFrame1:AddMessage("Name: |cffFFD100"..arg:GetName())
		if arg:GetParent() and arg:GetParent():GetName() then
			ChatFrame1:AddMessage("Parent: |cffFFD100"..arg:GetParent():GetName())
		end

		ChatFrame1:AddMessage("Width: |cffFFD100"..format("%.2f",arg:GetWidth()))
		ChatFrame1:AddMessage("Height: |cffFFD100"..format("%.2f",arg:GetHeight()))
		ChatFrame1:AddMessage("Strata: |cffFFD100"..arg:GetFrameStrata())
		ChatFrame1:AddMessage("Level: |cffFFD100"..arg:GetFrameLevel())

		if xOfs then
			ChatFrame1:AddMessage("X: |cffFFD100"..format("%.2f",xOfs))
		end
		if yOfs then
			ChatFrame1:AddMessage("Y: |cffFFD100"..format("%.2f",yOfs))
		end
		if relativeTo and relativeTo:GetName() then
			ChatFrame1:AddMessage("Point: |cffFFD100"..point.."|r anchored to "..relativeTo:GetName().."'s |cffFFD100"..relativePoint)
		end
		ChatFrame1:AddMessage("|cffCC0000----------------------------")
	elseif arg == nil then
		ChatFrame1:AddMessage("Invalid frame name")
	else
		ChatFrame1:AddMessage("Could not find frame info")
	end
end

SLASH_FRAMELIST1 = "/framelist"
SlashCmdList["FRAMELIST"] = function(msg)
	if(not FrameStackTooltip) then
		UIParentLoadAddOn("Blizzard_DebugTools");
	end

	local isPreviouslyShown = FrameStackTooltip:IsShown()
	if(not isPreviouslyShown) then
		if(msg == tostring(true)) then
			FrameStackTooltip_Toggle(true);
		else
			FrameStackTooltip_Toggle();
		end
	end

	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	for i = 2, FrameStackTooltip:NumLines() do
		local text = _G["FrameStackTooltipTextLeft"..i]:GetText();
		if(text and text ~= "") then
			print(text)
		end
	end
	print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	if(CopyChatFrame:IsShown()) then
		CopyChatFrame:Hide()
	end

	ElvUI[1]:GetModule("Chat"):CopyChat(ChatFrame1)
	if(not isPreviouslyShown) then
		FrameStackTooltip_Toggle();
	end
end

local function TextureList(frame)
	frame = _G[frame] or FRAME
	--[[for key, obj in pairs(frame) do
		if type(obj) == "table" and obj.GetObjectType and obj:GetObjectType() == "Texture" then
			print(key, obj:GetTexture())
		end
	end]]

	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if(region:GetObjectType() == "Texture") then
			print(region:GetTexture(), region:GetName(), region:GetDrawLayer())
		end
	end
end

SLASH_TEXLIST1 = "/texlist"
SlashCmdList["TEXLIST"] = TextureList

local function GetPoint(frame)
	if frame ~= "" then
		frame = _G[frame]
	else
		frame = GetMouseFocus()
	end

	local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
	local frameName = frame.GetName and frame:GetName() or "nil"
	local relativeToName = relativeTo.GetName and relativeTo:GetName() or "nil"

	print(frameName, point, relativeToName, relativePoint, xOffset, yOffset)
end

SLASH_GETPOINT1 = "/getpoint"
SlashCmdList["GETPOINT"] = GetPoint

SLASH_DEV1 = "/dev"
SlashCmdList["DEV"] = function()
	if not IsAddOnLoaded("ElvUIDev") then
		local _, _, _, loadable, reason = GetAddOnInfo("ElvUIDev")
		if not loadable then
			if reason == "MISSING" then
				print("ElvUIDev addon is missing.")
			elseif reason == "DISABLED" then
				print("ElvUIDev addon is disabled.")
			elseif reason == "DEMAND_LOADED" then
				local loaded, reason = LoadAddOn("ElvUIDev")
				if loaded then
					ElvUIDev:ToggleFrame()
				else
					print("ElvUIDev addon cannot be loaded: %s.", strlower(reason))
				end
			end
		end
	else
		--local addon = self:GetAddOn("ElvUIDev")
		if not ElvUIDev.frame:IsShown() then
			ElvUIDev.frame:Show()
		else
			ElvUIDev.frame:Hide()
		end
	end
end
