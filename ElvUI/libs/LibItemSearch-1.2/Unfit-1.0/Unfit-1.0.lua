--[[
Copyright 2011-2015 João Cardoso
Unfit is distributed under the terms of the GNU General Public License (Version 3).
As a special exception, the copyright holders of this library give you permission to embed it
with independent modules to produce an addon, regardless of the license terms of these
independent modules, and to copy and distribute the resulting software under terms of your
choice, provided that you also meet, for each embedded independent module, the terms and
conditions of the license of that module. Permission is not granted to modify this library.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the library. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.

This file is part of Unfit.
--]]

local Lib = LibStub:NewLibrary('Unfit-1.0', 7)
if not Lib then
	return
end


--[[ Data ]]--

local _, Class = UnitClass('player')
local Unusable

if Class == 'DEATHKNIGHT' then
	Unusable = {{3, 4, 10, 11, 13, 14, 15, 16}, {7}} -- weapons, armor, dual wield
elseif Class == 'DRUID' then
	Unusable = {{1, 2, 3, 4, 8, 9, 14, 15, 16}, {4, 5, 7}, true}
elseif Class == 'HUNTER' then
	Unusable = {{5, 6, 16}, {5, 6}}
elseif Class == 'MAGE' then
	Unusable = {{1, 2, 3, 4, 5, 6, 7, 9, 11, 14, 15}, {3, 4, 5, 7}, true}
elseif Class == 'MONK' then
	Unusable = {{2, 3, 4, 6, 9, 13, 14, 15, 16}, {4, 5, 7}}
elseif Class == 'PALADIN' then
	Unusable = {{3, 4, 10, 11, 13, 14, 15, 16}, {}, true}
elseif Class == 'PRIEST' then
	Unusable = {{1, 2, 3, 4, 6, 7, 8, 9, 11, 14, 15}, {3, 4, 5, 7}, true}
elseif Class == 'ROGUE' then
	Unusable = {{2, 6, 7, 9, 10, 16}, {4, 5, 6}}
elseif Class == 'SHAMAN' then
	Unusable = {{3, 4, 7, 8, 9, 14, 15, 16}, {5}}
elseif Class == 'WARLOCK' then
	Unusable = {{1, 2, 3, 4, 5, 6, 7, 9, 11, 14, 15}, {3, 4, 5, 7}, true}
elseif Class == 'WARRIOR' then
	Unusable = {{16}, {}}
else
	Unusable = {{}, {}}
end

for class = 1, 2 do
	local subs = {GetAuctionItemSubClasses(class)}
	for i, subclass in ipairs(Unusable[class]) do
		Unusable[subs[subclass]] = true
	end
		
	Unusable[class] = nil
	subs = nil
end

Lib.unusable = Unusable


--[[ API ]]--

function Lib:IsItemUnusable(...)
	if ... then
		local subclass, _, slot = select(7, GetItemInfo(...))
		return Lib:IsClassUnusable(subclass, slot)
	end
end

function Lib:IsClassUnusable(subclass, slot)
	if subclass then
		return slot ~= '' and Unusable[subclass] or slot == 'INVTYPE_WEAPONOFFHAND' and Unusable[3]
	end
end