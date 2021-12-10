--[[
Copyright (c) 2019 Alexander Heubner

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local lib = LibStub:NewLibrary('LibClassicSpellActionCount-1.0', 3)

-- already loaded
if not lib then
    return
end

local spellToReagentMapping = {
    [818] = 4470,       -- campfire

    -- warlock
    [697] = 6265,       -- summon voidwalker
    [712] = 6265,       -- summon succubus
    [691] = 6265,       -- summon felhunter
    [1122] = 5565,      -- inferno
    [18540] = 16583,    -- ritual of doom
    [698] = 6265,       -- ritual of summoning
    [6201] = 6265,      -- healthstone (minor)
    [6202] = 6265,      -- healthstone (lesser)
    [5699] = 6265,      -- healthstone
    [11729] = 6265,     -- healthstone (greater)
    [11730] = 6265,     -- healthstone (major)
    [693] = 6265,       -- soulstone (minor)
    [20752] = 6265,     -- soulstone (lesser)
    [20755] = 6265,     -- soulstone
    [20756] = 6265,     -- soulstone (greater)
    [20757] = 6265,     -- soulstone (major)
    [6366] = 6265,      -- firestone (lesser)
    [17951] = 6265,     -- firestone
    [17952] = 6265,     -- firestone (greater)
    [17953] = 6265,     -- firestone (major)
    [2362] = 6265,      -- spellstone
    [17727] = 6265,     -- spellstone (greater)
    [17728] = 6265,     -- spellstone (major)
    [1098] = 6265,      -- enslave demon (rank 1)
    [11725] = 6265,     -- enslave demon (rank 2)
    [11726] = 6265,     -- enslave demon (rank 3)
    [17877] = 6265,     -- shadowburn (rank 1)
    [18867] = 6265,     -- shadowburn (rank 2)
    [18868] = 6265,     -- shadowburn (rank 3)
    [18869] = 6265,     -- shadowburn (rank 4)
    [18870] = 6265,     -- shadowburn (rank 5)
    [18871] = 6265,     -- shadowburn (rank 6)
    [6353] = 6265,      -- soul fire (rank 1)
    [17924] = 6265,     -- soul fire (rank 2)

    -- priest
    [1706] = 17056,     -- levitate
    [21562] = 17028,    -- prayer of fortitude (rank 1)
    [21564] = 17029,    -- prayer of fortitude (rank 2)
    [27683] = 17029,    -- prayer of shadow protection
    [27681] = 17029,    -- prayer of spirit

    -- mage
    [130] = 17056,      -- slow fall
    [3561] = 17031,     -- teleport (SW)
    [3562] = 17031,     -- teleport (IF)
    [3563] = 17031,     -- teleport (UC)
    [3565] = 17031,     -- teleport (DN)
    [3566] = 17031,     -- teleport (TB)
    [3567] = 17031,     -- teleport (OG)
    [11416] = 17032,    -- portal (IF)
    [11417] = 17032,    -- portal (OG)
    [11418] = 17032,    -- portal (UC)
    [10059] = 17032,    -- portal (SW)
    [11419] = 17032,    -- portal (DN)
    [11420] = 17032,    -- portal (TB)
    [23028] = 17020,    -- arcane brilliance

    -- druid
    [20484] = 17034,    -- rebirth (rank 1)
    [20739] = 17035,    -- rebirth (rank 2)
    [20742] = 17036,    -- rebirth (rank 3)
    [20747] = 17037,    -- rebirth (rank 4)
    [20748] = 17038,    -- rebirth (rank 5)
    [21849] = 17021,    -- gift of the wild (rank 1)
    [21850] = 17026,    -- gift of the wild (rank 2)

    -- paladin
    [19752] = 17033,    -- divine intervention
    [25782] = 21177,    -- greater blessing of might (rank 1)
    [25916] = 21177,    -- greater blessing of might (rank 2)
    [25894] = 21177,    -- greater blessing of wisdom (rank 1)
    [25918] = 21177,    -- greater blessing of wisdom (rank 2)
    [25898] = 21177,    -- greater blessing of kings
    [25895] = 21177,    -- greater blessing of salvation
    [25899] = 21177,    -- greater blessing of sanctuary
    [25890] = 21177,    -- greater blessing of light

    -- rogue
    [1856] = 5140,      -- vanish (rank 1)
    [1857] = 5140,      -- vanish (rank 2)
    [2094] = 5530,      -- blind

    -- shaman
    [131] = 17057,      -- water breathing
    [546] = 17058,      -- water walking
}

-- a drop in replacement for blizzard's GetActionCount that will also
-- correctly return reagent count for spells and macros with spells
function lib:GetActionCount(slot)
    local actionType, actionID = GetActionInfo(slot)
    if actionType == 'spell' or actionType == 'macro' then
        if actionType == 'macro' then
            actionID = GetMacroSpell(actionID)
            if not actionID then
                return GetActionCount(slot)
            end
        end

        local reagentID = spellToReagentMapping[actionID]
        if reagentID then
            return GetItemCount(reagentID)
        end
    end

    -- use blizzard's for anything that's not a spell or macro
    return GetActionCount(slot)
end

-- returns reagent count for a given spell id or spell name
function lib:GetSpellReagentCount(idOrName)
    local spellID = select(7, GetSpellInfo(idOrName))
    if not spellID then
        return nil
    end

    local reagentID = spellToReagentMapping[spellID]
    if not reagentID then
        return nil
    end

    return GetItemCount(reagentID)
end
