local E, L, V, P, G = unpack(ElvUI)
local EM = E:GetModule('EditorMode')

local tremove = tremove
local strmatch = strmatch

local IgnoreFrames = {
	['^ChatFrame%d+'] = function() return E.private.chat.enable end,

	-- for now just going to use our mover, will need to add the setting
	-- header underneath and rotate minimap settings
	['MinimapCluster'] = function() return E.private.general.minimap.enable end
}

function EM:Initialize()
	local frames = _G.EditModeManagerFrame.registeredSystemFrames
	for index, frame in next, frames do
		for name, func in next, IgnoreFrames do
			if strmatch(frame:GetName(), name) and func() then
				tremove(frames, index)
			end
		end
	end
end

E:RegisterModule(EM:GetName())
