local _G = _G
local print, tostring, select = print, tostring, select
local strlower = strlower

local GetAddOnEnableState = GetAddOnEnableState
local UIParentLoadAddOn = UIParentLoadAddOn
local GetMouseFocus = GetMouseFocus
local IsAddOnLoaded = IsAddOnLoaded
local GetAddOnInfo = GetAddOnInfo
local LoadAddOn = LoadAddOn
local SlashCmdList = SlashCmdList
-- GLOBALS: ElvUIDev, ElvUI, FRAME, SLASH_FRAME1, SLASH_FRAMELIST1, SLASH_TEXLIST1, SLASH_GETPOINT1, SLASH_DEV1

local me = UnitName('player')
local IsDebugDisabled = function()
	if GetAddOnEnableState(me, 'Blizzard_DebugTools') == 0 then
		print('Blizzard_DebugTools is disabled.')

		return true
	end
end

_G.SLASH_FRAME1 = '/frame'
SlashCmdList.FRAME = function(arg)
	if IsDebugDisabled() then return end

	if arg ~= '' then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end

	if arg ~= nil then
		_G.FRAME = arg -- Set the global variable FRAME to = whatever we are mousing over to simplify messing with frames that have no name.
	end

	if not _G.TableAttributeDisplay then
		UIParentLoadAddOn('Blizzard_DebugTools')
	end

	if _G.TableAttributeDisplay then
		_G.TableAttributeDisplay:InspectTable(arg)
		_G.TableAttributeDisplay:Show()
	end
end

_G.SLASH_FRAMELIST1 = '/framelist'
SlashCmdList.FRAMELIST = function(msg)
	if IsDebugDisabled() then return end

	if not _G.FrameStackTooltip then
		UIParentLoadAddOn('Blizzard_DebugTools')
	end

	local isPreviouslyShown = _G.FrameStackTooltip:IsShown()
	if not isPreviouslyShown then
		if msg == tostring(true) then
			_G.FrameStackTooltip_Toggle(true)
		else
			_G.FrameStackTooltip_Toggle()
		end
	end

	print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
	for i = 2, _G.FrameStackTooltip:NumLines() do
		local text = _G['FrameStackTooltipTextLeft'..i]:GetText()
		if text and text ~= '' then
			print(text)
		end
	end
	print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

	if _G.CopyChatFrame:IsShown() then
		_G.CopyChatFrame:Hide()
	end

	ElvUI[1]:GetModule('Chat'):CopyChat(_G.ChatFrame1)
	if not isPreviouslyShown then
		_G.FrameStackTooltip_Toggle()
	end
end

local function TextureList(frame)
	frame = _G[frame] or FRAME

	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region.IsObjectType and region:IsObjectType('Texture') then
			print(region:GetTexture(), region:GetName(), region:GetDrawLayer())
		end
	end
end

_G.SLASH_TEXLIST1 = '/texlist'
SlashCmdList.TEXLIST = TextureList

local function GetPoint(frame)
	if frame ~= '' then
		frame = _G[frame]
	else
		frame = GetMouseFocus()
	end

	local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
	local frameName = frame.GetName and frame:GetName() or 'nil'
	local relativeToName = relativeTo.GetName and relativeTo:GetName() or 'nil'

	print(frameName, point, relativeToName, relativePoint, xOffset, yOffset)
end

_G.SLASH_GETPOINT1 = '/getpoint'
SlashCmdList.GETPOINT = GetPoint

_G.SLASH_DEV1 = '/dev'
SlashCmdList.DEV = function()
	if not IsAddOnLoaded('ElvUIDev') then
		local _, _, _, loadable, reason = GetAddOnInfo('ElvUIDev')
		if not loadable then
			if reason == 'MISSING' then
				print('ElvUIDev addon is missing.')
			elseif reason == 'DISABLED' then
				print('ElvUIDev addon is disabled.')
			elseif reason == 'DEMAND_LOADED' then
				local loaded, rsn = LoadAddOn('ElvUIDev')
				if loaded then
					ElvUIDev:ToggleFrame()
				else
					print('ElvUIDev addon cannot be loaded: %s.', strlower(rsn))
				end
			end
		end
	else
		if not ElvUIDev.frame:IsShown() then
			ElvUIDev.frame:Show()
		else
			ElvUIDev.frame:Hide()
		end
	end
end
