local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local data = S:AddCallbackForAddon('Blizzard_TorghastLevelPicker')
data.toggle = 'torghastLevelPicker'

local function UpdateHighestAvailableLayer(page)
	for layer in page.gossipOptionsPool:EnumerateActive() do
		if not layer.IsSkinned then
			layer.SelectedBorder:SetAtlas('charactercreate-ring-select')
			layer.SelectedBorder:Size(120)
			layer.SelectedBorder:Point('CENTER')
			layer.IsSkinned = true
		end
	end
end

function S:Blizzard_TorghastLevelPicker()
	local frame = _G.TorghastLevelPickerFrame
	frame.Title:FontTemplate(nil, 24)

	S:HandleCloseButton(frame.CloseButton)
	S:HandleNextPrevButton(frame.Pager.PreviousPage)
	S:HandleNextPrevButton(frame.Pager.NextPage)
	S:HandleButton(frame.OpenPortalButton)

	hooksecurefunc(frame, 'ScrollAndSelectHighestAvailableLayer', UpdateHighestAvailableLayer)
end
