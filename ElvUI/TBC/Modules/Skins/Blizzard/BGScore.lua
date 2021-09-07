local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local format, strsplit = format, strsplit

local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetBattlefieldScore = GetBattlefieldScore
local hooksecurefunc = hooksecurefunc

function S:SkinWorldStateScore()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgscore) then return end

	local WorldStateScoreFrame = _G.WorldStateScoreFrame
	S:HandleFrame(WorldStateScoreFrame, true, nil, 0, -5, -70, 25)

	_G.WorldStateScoreScrollFrame:StripTextures()
	_G.WorldStateScoreScrollFrameScrollBar:SetPoint('RIGHT', 110, 40)
	S:HandleScrollBar(_G.WorldStateScoreScrollFrameScrollBar)

	for i = 1, 3 do
		S:HandleTab(_G['WorldStateScoreFrameTab'..i])
		_G['WorldStateScoreFrameTab'..i..'Text']:SetPoint('CENTER', 0, 2)
	end

	S:HandleButton(_G.WorldStateScoreFrameLeaveButton)
	S:HandleCloseButton(_G.WorldStateScoreFrameCloseButton)
	_G.WorldStateScoreFrameCloseButton:SetPoint('TOPRIGHT', -68, 0)

	_G.WorldStateScoreFrameKB:StyleButton()
	_G.WorldStateScoreFrameDeaths:StyleButton()
	_G.WorldStateScoreFrameHK:StyleButton()
	_G.WorldStateScoreFrameHonorGained:StyleButton()
	_G.WorldStateScoreFrameName:StyleButton()

	for i = 1, 7 do
		_G['WorldStateScoreColumn'..i]:StyleButton()
	end

	hooksecurefunc('WorldStateScoreFrame_Update', function()
		local offset = FauxScrollFrame_GetOffset(_G.WorldStateScoreScrollFrame)
		for i = 1, 22 do
			local name, _, _, _, _, faction, _, _, _, classToken = GetBattlefieldScore(offset + i)
			if name then
				if name == E.myname then
					name = format('> %s <', name)
				else
					local Name, Realm = strsplit('-', name, 2)
					if Realm then
						name = format('%s|cffffffff - |r%s%s|r', Name, (faction == 1 and '|cff00adf0') or '|cffff1919', Realm)
					end
				end
			end
		end
	end)
end

S:AddCallback('SkinWorldStateScore')
