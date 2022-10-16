local E, L, V, P, G = unpack(ElvUI)
local EM = E:GetModule('EditorMode')

local tremove = tremove
local strmatch = strmatch

local IgnoreFrames = {
	'^ChatFrame%d+',
	'MinimapCluster' -- for now, minimap header fix WoW10
}

function EM:Initialize()
	local frames = _G.EditModeManagerFrame.registeredSystemFrames
	for index, frame in next, frames do
		for _, ignore in next, IgnoreFrames do
			if strmatch(frame:GetName(), ignore) then
				tremove(frames, index)
			end
		end
	end
end

E:RegisterModule(EM:GetName())
