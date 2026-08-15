## Friendly Nameplates  
___
### Player  
**Buffs:**  
big defensive:player, external defensive, raid in combat:player  
`HELPFUL|BIG_DEFENSIVE|PLAYER`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_IN_COMBAT|PLAYER`  
**Debuffs:**  
blocklist, all  
`HARMFUL` + `{ excludeSpellIDs = Blacklist }`  
### Friendly Player  
**Buffs:**  
big defensive, external defensive, raid in combat:player  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_IN_COMBAT|PLAYER`  
**Debuffs:**  
blocklist, raid:player  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
### Friendly NPC  
**Buffs:**  
big defensive, external defensive, raid in combat:player  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_IN_COMBAT|PLAYER`  
**Debuffs:**  
blocklist, raid:player  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  

## Enemy Nameplates  
___
### Enemy Player  
**Custom:**  
blocklist, crowd control  
`HARMFUL|CROWD_CONTROL` + `{ excludeSpellIDs = Blacklist }`  
**Buffs:**  
big defensive, external defensive, raid player dispellable, is stealable  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_PLAYER_DISPELLABLE`  
`HELPFUL` + `{ isStealable = true }`  
**Debuffs:**  
blocklist, nameplate show personal, block crowd control  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY|!CROWD_CONTROL` + `{ nameplateShowPersonal = true, excludeSpellIDs = Blacklist }`  
### Enemy NPC  
**Custom:**  
blocklist, crowd control  
`HARMFUL|CROWD_CONTROL` + `{ excludeSpellIDs = Blacklist }`  
**Buffs:**  
is boss or role aura, is stealable, important  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true }`  
`HELPFUL|IMPORTANT`  
**Debuffs:**  
blocklist, nameplate show personal, block crowd control  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY|!CROWD_CONTROL` + `{ nameplateShowPersonal = true, excludeSpellIDs = Blacklist }`  

## Individual Units  
___
### Player  
**Buffs:**  
big defensive:player, external defensive  
`HELPFUL|BIG_DEFENSIVE|PLAYER`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID`  
`HARMFUL` + `{ isPriorityAura = true }`  
shared `{ excludeSpellIDs = Blacklist }`  
### Pet  
**Buffs:**  
external defensive, raid:player  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID`  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID`  
`HARMFUL` + `{ isPriorityAura = true }`  
shared `{ excludeSpellIDs = Blacklist }`  
### Target  
**Custom:**  
blocklist, crowd control  
`HARMFUL|CROWD_CONTROL` + `{ excludeSpellIDs = Blacklist }`  
**Buffs:**  
is boss or role aura, is stealable, important, is from player or player pet(for mounts etc?)  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true }`  
`HELPFUL|IMPORTANT`  
`HELPFUL` + `{ isFromPlayerOrPlayerPet = true }`  
**Debuffs:**  
blocklist, nameplate show personal  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY` + `{ nameplateShowPersonal = true, excludeSpellIDs = Blacklist }`  

### Focus  
**Buffs:**  
is boss or role aura, is stealable, important, raid:player, big defensive, external defensive  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true }`  
`HELPFUL|IMPORTANT`  
`HELPFUL|RAID`  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID`  
`HARMFUL` + `{ isPriorityAura = true }`  
shared `{ excludeSpellIDs = Blacklist }`  
### TargetTarget  
**Show all and auras enable off by default**  
`HELPFUL` / `HARMFUL` — enable = false  
### TargetTargetTarget  
**Show all and auras enable off by default**  
`HELPFUL` / `HARMFUL` — enable = false  
### FocusTarget  
**Show all and auras enable off by default**  
`HELPFUL` / `HARMFUL` — enable = false  
### PetTarget  
**Show all and auras enable off by default**  
`HELPFUL` / `HARMFUL` — enable = false  

## Group Units  
___
### Arena  
**Buffs:**  
big defensive, external defensive, raid player dispellable, is stealable, raid:player  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_PLAYER_DISPELLABLE`  
`HELPFUL` + `{ isStealable = true }`  
`HELPFUL|RAID`  
**Debuffs:**  
blocklist, nameplate show personal, block crowd control  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY` + `{ nameplateShowPersonal = true }`  
`HARMFUL|CROWD_CONTROL`  
shared `{ excludeSpellIDs = Blacklist }`  
(`block crowd control` dropped; CC stays on this row)  
### Boss  
**Buffs:**  
is boss or role aura, is stealable, important  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true }`  
`HELPFUL|IMPORTANT`  
**Debuffs:**  
blocklist, nameplate show personal  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY` + `{ nameplateShowPersonal = true, excludeSpellIDs = Blacklist }`  
### Party  
**Buffs:**  
big defensive, external defensive, whitelist include(can we? innervate, power infusion)  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL` + `{ includeSpellIDs = Whitelist }`  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID`  
`HARMFUL` + `{ isPriorityAura = true }`  
shared `{ excludeSpellIDs = Blacklist }`  
### Raid  
**Buffs:**  
big defensive, external defensive, whitelist include(can we? innervate, power infusion)  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL` + `{ includeSpellIDs = Whitelist }`  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID`  
`HARMFUL` + `{ isPriorityAura = true }`  
shared `{ excludeSpellIDs = Blacklist }`  
### Tank  
**Buffs:**  
is boss or role aura, is stealable, important, raid:player, big defensive, external defensive  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true }`  
`HELPFUL|IMPORTANT`  
`HELPFUL|RAID`  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
**Debuffs:**  
blocklist, important, raid player dispellable, crowd control, raid:player, is priority aura  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID`  
`HARMFUL` + `{ isPriorityAura = true }`  
shared `{ excludeSpellIDs = Blacklist }`  
### Assist  
**Show all and auras enable off by default**  
`HELPFUL` / `HARMFUL` — enable = false  
### Raid Pet  
**Show all and auras enable off by default**  
`HELPFUL` / `HARMFUL` — enable = false  

## Filter strings  
___
`HELPFUL` include buffs  
`HARMFUL` include debuffs  
`PLAYER` include unit: player, pet, vehicle  
`RAID` (buff: player can apply) (debuff: player can dispel)  
`RAID_PLAYER_DISPELLABLE` (buff: someone can purge/steal) (debuff: someone can dispel)  
`RAID_IN_COMBAT` (combine with helpful and player for self-cast hots, matches our AuraWatch table of IDs)  
`CANCELABLE` (buffs to cancel, player only)  
`INCLUDE_NAME_PLATE_ONLY` (when used include nameplate-only auras, otherwise excludes nameplate-only auras)  
`EXTERNAL_DEFENSIVE` (buffs: pain suppression, iron bark, time dilation)  
`CROWD CONTROL` (debuffs: stun, fear, silence, slow)  
`BIG_DEFENSIVE` (buffs: bubble, ice block, blur, barkskin)  
`IMPORTANT` (special helpful auras that show on enemy even if non-stealable)  
`DISPELLABLE` (dispellable/purgeable/stealable by at least one class in the game, even if none of the raid classes can handle it)  
## Candidate filters  
___
`isFromPlayerOrPlayerPet` (From any player or pet)  
`isRoleAura` (Role aura - tank/heal/dps?)  
`isPriorityAura` (Priority aura)  
`isStealable` (Stealable)  
`nameplateShowAll` (Nameplate: Show all)  
`nameplateShowPersonal` (Nameplate: Personal)  
`canApplyAura` (Can apply aura)  
`isBossAura` (Boss aura - important shit, was used on last boss this season)  
`isBossOrRoleAura` (the "either-or" between `isRoleAura` and `isBossAura`)  