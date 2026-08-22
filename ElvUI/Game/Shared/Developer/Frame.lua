local E, L, V, P, G = unpack(ElvUI)
local CH = E:GetModule('Chat')

local _G, UNKNOWN = _G, UNKNOWN
local strmatch, next, print = strmatch, next, print

local function IsTrue(value)
	return value == 'true' or value == '1'
end

-- spawn console without starting with `-console`
E:AddSlashCommand('DEVCON', '/devcon', function()
	if _G.DeveloperConsole then
		_G.DeveloperConsole:Toggle()
	end
end)

-- /rl, /reloadui, /reload NOTE: /reload is from SLASH_RELOAD
E:AddSlashCommand('RELOADUI', {'/rl','/reloadui'}, _G.ReloadUI)

E:AddSlashCommand('GETPOINT', '/getpoint', function(arg)
	local frame = (arg ~= '' and _G[arg]) or E:GetMouseFocus()
	if not frame then return end

	local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint()
	print(E:GetFrameName(frame, 'nil', true), point, E:GetFrameName(relativeTo, 'nil', true), relativePoint, xOffset, yOffset)
end)

E:AddSlashCommand('FRAME', '/frame', function(arg)
	local frameName, tinspect = strmatch(arg, '^(%S+)%s*(%S*)$')
	local frame = (frameName ~= '' and _G[frameName]) or E:GetMouseFocus()
	if not frame then return end

	_G.FRAME = frame -- Set the global variable FRAME to = whatever we are mousing over to simplify messing with frames that have no name.
	E:Print('_G.FRAME set to: ', E:GetFrameName(frame, UNKNOWN, true))

	if IsTrue(tinspect) then
		if not _G.TableAttributeDisplay then
			E:LoadAddon('Blizzard_DebugTools')
		end

		_G.TableAttributeDisplay:InspectTable(frame)
		_G.TableAttributeDisplay:Show()
	end
end)

E:AddSlashCommand('TEXLIST', '/texlist', function(arg)
	local frame = _G[arg] or _G.FRAME
	if not frame then return end

	for _, region in next, { frame:GetRegions() } do
		if region.IsObjectType and region:IsObjectType('Texture') then
			print(region:GetTexture(), region:GetName(), region:GetDrawLayer())
		end
	end
end)

E:AddSlashCommand('FRAMELIST', '/framelist', function(arg)
	if not _G.FrameStackTooltip then
		E:LoadAddon('Blizzard_DebugTools')
	end

	local copyChat, showHidden, showRegions, showAnchors = strmatch(arg, '^(%S+)%s*(%S*)%s*(%S*)%s*(%S*)$')

	local wasShown = _G.FrameStackTooltip:IsShown()
	if not wasShown then
		_G.FrameStackTooltip_Toggle(IsTrue(showHidden), IsTrue(showRegions), IsTrue(showAnchors))
	end

	print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
	for i = 2, _G.FrameStackTooltip:NumLines() do
		print(_G['FrameStackTooltipTextLeft'..i]:GetText())
	end
	print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

	if _G.ElvUI_CopyChatFrame and IsTrue(copyChat) then
		if _G.ElvUI_CopyChatFrame:IsShown() then
			_G.ElvUI_CopyChatFrame:Hide()
		end

		CH:CopyChat(_G.ChatFrame1)
	end

	if not wasShown then
		_G.FrameStackTooltip_Toggle()
	end
end)
