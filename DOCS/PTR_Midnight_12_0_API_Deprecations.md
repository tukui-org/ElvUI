# ElvUI PTR 12.0 Midnight - API Deprecation & Migration Guide

**Updated:** 2026-01-24 | **Status:** ACTIVE | **Scope:** Retail PTR

---

## Overview

World of Warcraft 12.0 Midnight introduces breaking API changes that affect addons. This document catalogs:
- **Deprecated APIs** and their Midnight behavior
- **Blocked fields** (SECRET data) that require safe access wrappers
- **Migration patterns** used in ElvUI
- **Workarounds** for removed functionality

---

## Breaking Changes Summary

### 1. **Secret Unit Data (C_UnitAuras)**

**Problem:**  
Certain aura attributes are now marked SECRET and inaccessible to addons.

**Affected Fields:**
- `isBossAura` - Whether aura is from a boss
- `canApplyAura` - Whether aura can be applied
- `isTrivial` - Trivial aura flag

**Blizzard Rationale:**  
Reduce information available to players about hidden mechanics.

**Migration Pattern (ElvUI):**
```lua
-- Safe wrapper in API.lua
function E:GetSafeAuraData(unit, index, filter)
    if not unit or not index then return end
    
    local data = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
    if not data then return end
    
    -- Handle SECRET fields with pcall
    local secretFields = { 'isBossAura', 'canApplyAura', 'isTrivial' }
    for _, field in ipairs(secretFields) do
        local success = pcall(function() return data[field] end)
        if not success then
            data[field] = nil  -- Field is SECRET
        end
    end
    
    return data
end

-- Usage in Auras.lua
local data = E:GetSafeAuraData(unitToken, index, filter)
if not data then return end  -- Handle nil gracefully
```

**Migration Checklist:**
- ✅ Use `E:GetSafeAuraData()` for all aura lookups
- ✅ Check return value for nil before accessing fields
- ✅ Use `E:NotSecretValue()` for defensive checks on secret-prone fields

---

### 2. **Threat APIs (Removed)**

**Problem:**  
`UnitThreatSituation()` and `UnitDetailedThreatSituation()` removed entirely.

**Blizzard Rationale:**  
Threat is class-specific and provides unreliable information to addons.

**Affected Functionality:**
- Threat/taunt warnings for tanks
- Threat meter integration
- DPS threat tracking

**Workarounds:**
1. **Event-based detection** (partial):
   ```lua
   -- Listen for threat-related combat log events
   local COMBAT_LOG_EVENTS = {
       SPELL_AURA_APPLIED = true,  -- Taunt applied
       SPELL_AURA_REMOVED = true,  -- Taunt removed
   }
   ```
   - Limited: Only detects taunt buff/debuff, not actual threat value

2. **External data source** (recommended):
   - Integrate with Details!, Recount, or WCL API
   - Parse threat from combat log parsing addons
   - User awareness: "Threat unknown - use Details for threat data"

**Migration Status in ElvUI:**
- Tags system: `threat` tag marked as **UNFIXABLE** (P3 documentation item)
- Workaround: Hide threat tag, document limitation

---

### 3. **PvP Role APIs (Changed)**

**Problem:**  
`GetPvpRoleForGUID()` now returns SECRET state for hidden-role players.

**Blizzard Rationale:**  
Respect player privacy in rated PvP.

**Affected Functionality:**
- Nameplate role icons (Healer, Tank, DPS indicators)
- Role detection in battlegrounds/arenas

**Migration Pattern (ElvUI):**
```lua
-- Check if role is valid
local role = GetPvpRoleForGUID(guid)

local validRoles = {
    TANK = true,
    HEALER = true,
    DPS = true,
    -- SECRET = false (not valid for display)
}

if role and validRoles[role] then
    -- Display role icon
else
    -- Hide icon gracefully (SECRET or nil)
end
```

**Migration Checklist:**
- ✅ Check role against valid role table before use
- ✅ Hide icon if role is SECRET or invalid
- ✅ Do NOT error on SECRET state

---

### 4. **Combat Indicator APIs (Partial)**

**Problem:**  
Some combat-related APIs deprecated or changed behavior.

**Affected APIs:**
- `InCombatLockdown()` - Still works (secure handler)
- `GetCombatRating()` - Versed rating may be affected
- Combat buff application - Timing may be delayed

**Workaround:**
```lua
-- Use event-driven approach
local inCombat = false

frame:RegisterEvent('PLAYER_REGEN_DISABLED')  -- Combat started
frame:RegisterEvent('PLAYER_REGEN_ENABLED')   -- Combat ended

frame:SetScript('OnEvent', function(_, event)
    if event == 'PLAYER_REGEN_DISABLED' then
        inCombat = true
    elseif event == 'PLAYER_REGEN_ENABLED' then
        inCombat = false
    end
end)
```

---

## Safe Access Patterns

### Pattern 1: Guard Against Secret Values

```lua
-- Unsafe (may error if field is SECRET)
local count = aura.applications

-- Safe (check before access)
local count = E:NotSecretValue(aura.applications) and aura.applications or 0
```

### Pattern 2: Centralized SECRET Handling

```lua
-- In API.lua - Single source of truth
function E:IsValidUnitForAura(unit)
    if not unit then return false end
    if not UnitExists(unit) then return false end
    if E:ShouldUnitBeSecret(unit) then return false end
    return true
end

-- Usage everywhere
if E:IsValidUnitForAura(unit) then
    local data = E:GetSafeAuraData(unit, index, filter)
    -- Process aura safely
end
```

### Pattern 3: Defensive Nil Checks

```lua
-- For tooltip/display functions
local function SafeGetAuraName(unit, index, filter)
    if not unit or not index then return nil end
    
    local data = E:GetSafeAuraData(unit, index, filter)
    if not data then return nil end
    
    return data.name or "Unknown Aura"
end
```

---

## Migration Checklist for Module Developers

### Phase 1: Audit (Search)
- [ ] Search module for `GetAuraDataByIndex` calls
- [ ] Search for direct aura field access without nil checks
- [ ] Search for threat API calls (`UnitThreatSituation`, etc.)
- [ ] Search for PvP role API calls (`GetPvpRoleForGUID`)

### Phase 2: Isolate
- [ ] Group unsafe calls by type (threat, role, aura fields)
- [ ] Document which calls are critical vs optional
- [ ] Identify fallback behavior

### Phase 3: Migrate
- [ ] Replace aura calls with `E:GetSafeAuraData()`
- [ ] Add nil checks for all aura data access
- [ ] Replace threat calls with workarounds or mark as unfixable
- [ ] Add SECRET value guards with `E:NotSecretValue()`

### Phase 4: Test
- [ ] Test with hidden-role players in PvP
- [ ] Test with bosses (boss aura data)
- [ ] Test in raid with heavy aura spam
- [ ] Check for Lua errors in combat

---

## Reference: All APIs by Status

| API | Status | Impact | Workaround |
|-----|--------|--------|------------|
| `C_UnitAuras.GetAuraDataByIndex` | Modified | Returns data with SECRET fields | Use `E:GetSafeAuraData()` wrapper |
| `C_UnitAuras.GetAuraDataBySlot` | Stable | No changes | Direct use OK |
| `GetPvpRoleForGUID` | Modified | May return SECRET | Check against valid role table |
| `UnitThreatSituation` | Removed | N/A - API gone | Event-based + external addon |
| `UnitDetailedThreatSituation` | Removed | N/A - API gone | Event-based + external addon |
| `InCombatLockdown` | Stable | No changes | Direct use OK |
| `PLAYER_REGEN_DISABLED` | Stable | No changes | Direct use OK |
| `PLAYER_REGEN_ENABLED` | Stable | No changes | Direct use OK |

---

## Open Issues & Tracking

### Resolved ✅
- [x] Aura flickering (OnUpdate throttling)
- [x] Combat Lua errors (SECRET field handling)
- [x] PvP nameplate crashes (role validation)

### Known Unfixable ❌
- [ ] Threat tags (threat APIs removed entirely)
- [ ] DPS tags (requires external data source)

### In Progress 🔄
- [ ] Tags system full compatibility audit
- [ ] Optional aura caching layer

---

## Quick Reference: Helper Functions

```lua
-- API.lua - All helpers available here:

E:GetSafeAuraData(unit, index, filter)          -- Safe aura lookup with SECRET handling
E:IsValidUnitForAura(unit)                      -- Check if unit is safe for aura queries
E:NotSecretValue(value)                         -- Check if value is not SECRET
E:IsSecretValue(value)                          -- Check if value is SECRET
E:ShouldUnitBeSecret(unit)                      -- Check if unit identity should be hidden
```

---

## For Module Maintainers: Converting Common Patterns

### Pattern: Direct Aura Lookup
```lua
-- Before (Broken in Midnight)
local data = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
if data then
    local count = data.applications  -- May error if SECRET!
end

-- After (Safe)
local data = E:GetSafeAuraData(unit, index, filter)
if data then
    local count = E:NotSecretValue(data.applications) and data.applications or 0
end
```

### Pattern: Role Display
```lua
-- Before (Broken in Midnight)
local role = GetPvpRoleForGUID(guid)
if role then
    DisplayRoleIcon(role)  -- Crashes if role == "SECRET"
end

-- After (Safe)
local role = GetPvpRoleForGUID(guid)
local validRoles = { TANK = true, HEALER = true, DPS = true }
if role and validRoles[role] then
    DisplayRoleIcon(role)
else
    HideRoleIcon()  -- Hidden or invalid role
end
```

---

## Summary

**Key Takeaway:** Midnight prioritizes **information security** over addon convenience.  
Addons must now:
1. Handle nil/SECRET returns gracefully
2. Use centralized safe access helpers
3. Provide fallback UI when data unavailable
4. Document removed functionality to users

**For ElvUI specifically:** See commits f8d83c0, 95f0e16, 5a63371 for implementation reference.
