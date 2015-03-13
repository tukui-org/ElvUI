--[[
Copyright 2011 João Cardoso
Unfit is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of Unfit.

Unfit is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Unfit is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Unfit. If not, see <http://www.gnu.org/licenses/>.
--]]

local Lib = LibStub:NewLibrary('Unfit-1.0', 3)
if not Lib then
	return
else
	Lib.unusable = Lib.unusable or {}
end


--[[ Data ]]--

local _, Class = UnitClass('player')
local Unusable = Lib.unusable

if Class == 'DEATHKNIGHT' then
	Unusable = {{3, 4, 10, 11, 13, 14, 15, 16}, {6}}
elseif Class == 'DRUID' then
	Unusable = {{1, 2, 3, 4, 8, 9, 14, 15, 16}, {4, 5, 6}, true}
elseif Class == 'HUNTER' then
	Unusable = {{5, 6, 16}, {5, 6, 7}}
elseif Class == 'MAGE' then
	Unusable = {{1, 2, 3, 4, 5, 6, 7, 9, 11, 14, 15}, {3, 4, 5, 6, 7}, true}
elseif Class == 'PALADIN' then
	Unusable = {{3, 4, 10, 11, 13, 14, 15, 16}, {}, true}
elseif Class == 'PRIEST' then
	Unusable = {{1, 2, 3, 4, 6, 7, 8, 9, 11, 14, 15}, {3, 4, 5, 6, 7}, true}
elseif Class == 'ROGUE' then
	Unusable = {{2, 6, 7, 9, 10, 16}, {4, 5, 6, 7}}
elseif Class == 'SHAMAN' then
	Unusable = {{3, 4, 7, 8, 9, 14, 15, 16}, {5}}
elseif Class == 'WARLOCK' then
	Unusable = {{1, 2, 3, 4, 5, 6, 7, 9, 11, 14, 15}, {3, 4, 5, 6, 7}, true}
elseif Class == 'WARRIOR' then
	Unusable = {{16}, {7}}
end

for class = 1, 2 do
	local subs = {GetAuctionItemSubClasses(class)}
	for i, subclass in ipairs(Unusable[class]) do
		Unusable[subs[subclass]] = true
	end
		
	Unusable[class] = nil
	subs = nil
end


--[[ API ]]--

function Lib:IsItemUnusable(...)
	if ... then
		local subclass, _, slot = select(7, GetItemInfo(...))
		return Lib:IsClassUnusable(subclass, slot)
	end
end

function Lib:IsClassUnusable(subclass, slot)
	if subclass then
		return Unusable[subclass] or slot == 'INVTYPE_WEAPONOFFHAND' and Unusable[3]
	end
end