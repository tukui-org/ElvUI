local print, select, strmatch, strlower = print, select, strmatch, strlower
local _G, UNKNOWN, format, type, next = _G, UNKNOWN, format, type, next

local LoadAddOn = LoadAddOn
local GetAddOnInfo = GetAddOnInfo
local SlashCmdList = SlashCmdList
local GetMouseFocus = GetMouseFocus
local IsAddOnLoaded = IsAddOnLoaded
local UIParentLoadAddOn = UIParentLoadAddOn
-- GLOBALS: ElvUI_CPU, ElvUI

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

-- /rl, /reloadui, /reload  NOTE: /reload is from SLASH_RELOAD
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

	for i = 1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
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

	if _G.CopyChatFrame and IsTrue(copyChat) then
		if _G.CopyChatFrame:IsShown() then
			_G.CopyChatFrame:Hide()
		end

		ElvUI[1]:GetModule('Chat'):CopyChat(_G.ChatFrame1)
	end

	if not wasShown then
		_G.FrameStackTooltip_Toggle()
	end
end)

AddCommand('ECPU', '/ecpu', function()
	if not IsAddOnLoaded('ElvUI_CPU') then
		local _, _, _, loadable, reason = GetAddOnInfo('ElvUI_CPU')
		if not loadable then
			if reason == 'MISSING' then
				print('ElvUI_CPU addon is missing.')
			elseif reason == 'DISABLED' then
				print('ElvUI_CPU addon is disabled.')
			elseif reason == 'DEMAND_LOADED' then
				local loaded, rsn = LoadAddOn('ElvUI_CPU')
				if loaded then
					ElvUI_CPU:ToggleFrame()
				else
					print(format('ElvUI_CPU addon cannot be loaded: %s.', strlower(rsn)))
				end
			end
		end
	elseif not ElvUI_CPU.frame:IsShown() then
		ElvUI_CPU.frame:Show()
	else
		ElvUI_CPU.frame:Hide()
	end
end)
