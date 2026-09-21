local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc
local format, next, strmatch = format, next, strmatch

local GetBattlefieldScore = GetBattlefieldScore
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset

local myName = format('> %s <', E.myname)

local function UpdateScore()
	local inArena = IsActiveBattlefieldArena()
	local offset = FauxScrollFrame_GetOffset(_G.WorldStateScoreScrollFrame)

	for i = 1, 20 do -- score rows
		local fullName, _, _, _, _, faction, _, _, _, classToken = GetBattlefieldScore(offset + i)
		if fullName then
			local name, realm = strmatch(fullName, '([^%-]+)(.*)')
			if name == E.myname then
				name = myName
			end

			if realm and realm ~= '' then
				local color

				if inArena then
					color = faction == 1 and '|cffffd100' or '|cff19ff19'
				else
					color = faction == 1 and '|cff00adf0' or '|cffff1919'
				end

				name = format('%s|cffffffff - |r%s%s|r', name, color, realm)
			end

			local classTextColor = E:ClassColor(classToken)
			local nameText = _G['WorldStateScoreButton'..i..'NameText']
			nameText:SetText(name)
			nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
		end
	end
end

function S:SkinWorldStateScore()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.bgscore) then return end

	local WorldStateScoreFrame = _G.WorldStateScoreFrame
	WorldStateScoreFrame:EnableMouse(true)

	S:HandleFrame(WorldStateScoreFrame, true, nil, 0, -12, -102, 25)

	_G.WorldStateScoreScrollFrame:StripTextures()

	local scrollBar = _G.WorldStateScoreScrollFrameScrollBar
	S:HandleScrollBar(scrollBar)
	scrollBar:Point('RIGHT', WorldStateScoreFrame, 'RIGHT', -44, 38)

	for _, button in next, {
		_G.WorldStateScoreFrameKB,
		_G.WorldStateScoreFrameDeaths,
		_G.WorldStateScoreFrameHK,
		_G.WorldStateScoreFrameDamageDone,
		_G.WorldStateScoreFrameHealingDone,
		_G.WorldStateScoreFrameHonorGained,
		_G.WorldStateScoreFrameName,
		_G.WorldStateScoreFrameClass,
		_G.WorldStateScoreFrameTeam
	} do
		button:StyleButton()
	end

	S:HandleButton(_G.WorldStateScoreFrameLeaveButton)

	for i = 1, 3 do
		S:HandleTab(_G['WorldStateScoreFrameTab'..i])
	end

	-- Reposition Tabs
	_G.WorldStateScoreFrameTab1:ClearAllPoints()
	_G.WorldStateScoreFrameTab1:Point('TOPLEFT', _G.WorldStateScoreFrame, 'BOTTOMLEFT', -10, 25)
	_G.WorldStateScoreFrameTab2:Point('TOPLEFT', _G.WorldStateScoreFrameTab1, 'TOPRIGHT', -19, 0)
	_G.WorldStateScoreFrameTab3:Point('TOPLEFT', _G.WorldStateScoreFrameTab2, 'TOPRIGHT', -19, 0)

	for i = 1, 5 do
		_G['WorldStateScoreColumn'..i]:StyleButton()
	end

	hooksecurefunc('WorldStateScoreFrame_Update', UpdateScore)
end

S:AddCallback('SkinWorldStateScore')
