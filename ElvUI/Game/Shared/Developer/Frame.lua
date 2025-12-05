local _G, UNKNOWN = _G, UNKNOWN
local print, type, next = print, type, next
local strmatch = strmatch

local SlashCmdList = SlashCmdList
local UIParentLoadAddOn = UIParentLoadAddOn

local GetMouseFocus = GetMouseFocus or function()
	local frames = _G.GetMouseFoci()
	return frames and frames[1]
end

-- GLOBALS: ElvUI

local function GetName(frame, text)
	if frame.GetDebugName then
		return frame:GetDebugName()
	elseif frame.GetName then
		return frame:GetName()
	else
		return text or 'nil'
	end
end

local function IsTrue(value)
	return value == 'true' or value == '1'
end

local function AddCommand(name, keys, func)
	if not SlashCmdList[name] then
		SlashCmdList[name] = func

		if type(keys) == 'table' then
			for i, key in next, keys do
				_G['SLASH_'..name..i] = key
			end
		else
			_G['SLASH_'..name..'1'] = keys
		end
	end
end

-- spawn console without starting with `-console`
AddCommand('DEVCON', '/devcon', function()
	if _G.DeveloperConsole then
		_G.DeveloperConsole:Toggle()
	end
end)

-- /rl, /reloadui, /reload NOTE: /reload is from SLASH_RELOAD
AddCommand('RELOADUI', {'/rl','/reloadui'}, _G.ReloadUI)

AddCommand('GETPOINT', '/getpoint', function(arg)
	local frame = (arg ~= '' and _G[arg]) or GetMouseFocus()
	if not frame then return end

	local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
	print(GetName(frame), point, GetName(relativeTo), relativePoint, xOffset, yOffset)
end)

AddCommand('FRAME', '/frame', function(arg)
	local frameName, tinspect = strmatch(arg, '^(%S+)%s*(%S*)$')
	local frame = (frameName ~= '' and _G[frameName]) or GetMouseFocus()
	if not frame then return end

	_G.FRAME = frame -- Set the global variable FRAME to = whatever we are mousing over to simplify messing with frames that have no name.
	ElvUI[1]:Print('_G.FRAME set to: ', GetName(frame, UNKNOWN))

	if IsTrue(tinspect) then
		if not _G.TableAttributeDisplay then
			UIParentLoadAddOn('Blizzard_DebugTools')
		end

		_G.TableAttributeDisplay:InspectTable(frame)
		_G.TableAttributeDisplay:Show()
	end
end)

AddCommand('TEXLIST', '/texlist', function(arg)
	local frame = _G[arg] or _G.FRAME
	if not frame then return end

	for _, region in next, { frame:GetRegions() } do
		if region.IsObjectType and region:IsObjectType('Texture') then
			print(region:GetTexture(), region:GetName(), region:GetDrawLayer())
		end
	end
end)

AddCommand('FRAMELIST', '/framelist', function(arg)
	if not _G.FrameStackTooltip then
		UIParentLoadAddOn('Blizzard_DebugTools')
	end

	local copyChat, showHidden, showRegions, showAnchors = strmatch(arg, '^(%S+)%s*(%S*)%s*(%S*)%s*(%S*)$')

	local wasShown = _G.FrameStackTooltip:IsShown()
	if not wasShown then
		_G.FrameStackTooltip_Toggle(IsTrue(showHidden), IsTrue(showRegions), IsTrue(showAnchors))
	end

	print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
	for i = 2, _G.FrameStackTooltip:NumLines() do
		local text = _G['FrameStackTooltipTextLeft'..i]:GetText()
		if text and text ~= '' then
			print(text)
		end
	end
	print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

	if _G.ElvUI_CopyChatFrame and IsTrue(copyChat) then
		if _G.ElvUI_CopyChatFrame:IsShown() then
			_G.ElvUI_CopyChatFrame:Hide()
		end

		ElvUI[1]:GetModule('Chat'):CopyChat(_G.ChatFrame1)
	end

	if not wasShown then
		_G.FrameStackTooltip_Toggle()
	end
end)
