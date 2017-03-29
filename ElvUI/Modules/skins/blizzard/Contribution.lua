local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local ipairs = ipairs
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Contribution ~= true then return end

	ContributionCollectionFrame:CreateBackdrop("Transparent")
	S:HandleCloseButton(ContributionCollectionFrame.CloseButton)

	-- Needs review
	--[[ for i = 1, 3 do
		S:HandleButton(_G["ContributionCollectionFrame".. i.."ContributeButton"])
	end --]]

	-- Need review
	--[[for i = 1, 3 do
		local statusBar = _G["ContributionCollectionFrame".. i.."Status"]
		if statusBar and not statusBar.skinned then
			statusBar:StripTextures()
			statusBar:SetStatusBarTexture(E['media'].normTex)
			E:RegisterStatusBar(statusBar)
			statusBar:CreateBackdrop('Default')
			statusBar.skinned = true
		end
	end --]]
end

S:AddCallbackForAddon("Blizzard_Contribution", "Contribution", LoadSkin)