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
blocklist, external defensive, raid:player  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
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
blocklist, is boss or role aura, is stealable, important, raid:player, big defensive, external defensive  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true }`  
`HELPFUL|IMPORTANT`  
`HELPFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
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
blocklist, big defensive, external defensive, raid player dispellable, is stealable, raid:player  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_PLAYER_DISPELLABLE`  
`HELPFUL` + `{ isStealable = true }`  
`HELPFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
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
blocklist, is boss or role aura, is stealable, important, raid:player, big defensive, external defensive  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true }`  
`HELPFUL|IMPORTANT`  
`HELPFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
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
`HELPFUL`  
Require it to be a Buff  

`HARMFUL`  
Require it to be a Debuff  

`PLAYER`  
Require unit: "Player"(You), "Pet"(Yours), "Vehicle"(Yours)  

`RAID`  
If configuring Buffs: "Player"(You) can apply this aura  
If configuring Debuffs: "Player"(You) can dispel it  

`RAID_PLAYER_DISPELLABLE`  
If configuring Buffs: Someone in your party or raid can purge or steal it  
If configuring Debuffs: Someone in your party or raid can dispel it  

`RAID_IN_COMBAT`  
When combined with HELPFUL and PLAYER it will show self-cast hots and shields  
Whats being displayed matches the ElvUI Aura Indicator (Class) list in the Filters Dropdown  

`CANCELABLE`  
Works on HELPFUL|PLAYER to show Buffs "Player"(You) can click off / cancel with right-click  

`INCLUDE_NAME_PLATE_ONLY`  
When added to the string, include nameplate-only flagged auras  

`EXTERNAL_DEFENSIVE`  
You can use /dump C_Spell.IsExternalDefensive(ID) and replace ID with the numeric ID of your test aura  
This will print either true or false in your ingame chat then you'll know if its considered a external defensive or not  
Some examples: Pain suppression, Iron Bark, Life Cocoon  

`CROWD CONTROL`  
You can use /dump C_Spell.IsSpellCrowdControl(ID) and replace ID with the numeric ID of your test aura  
This will print either true or false in your ingame chat then you'll know if its considered CC or not  
Some examples: Fear, Polymorph, Entangling Roots  

`BIG_DEFENSIVE`  
You can use /dump C_UnitAuras.AuraIsBigDefensive(ID) and replace ID with the numeric ID of your test aura  
This will print either true or false in your ingame chat then you'll know if its considered a big defensive or not  
Some examples: Ice Block, Bubble, Blur, Barkskin  

`IMPORTANT`  
You can use /dump C_Spell.IsSpellImportant(ID) and replace ID with the numeric ID of your test aura  
This will print either true or false in your ingame chat then you'll know if its considered important or not  
Those are also special helpful auras that show on enemy even if non-stealable  

`DISPELLABLE`  
Displays auras which are dispellable, purgable or stealable. Regardless if ur party or raid setup can handle it  

## Filter checkboxes  
___
`Player or Pet`  
From any player or pet  
Adds `{isFromPlayerOrPlayerPet = true}`  

`Role`  
Role aura - Tank/Heal/DPS  
Adds `{isRoleAura = true}`  

`Priority`  
Priority aura  
Adds `{isPriorityAura = true}`  

`Stealable`  
Stealable  
Adds `{isStealable = true}`  

`NP: All`  
Nameplate: Show all  
Adds `{nameplateShowAll = true}`  

`NP: Personal`  
Nameplate: Personal  
Adds `{nameplateShowPersonal = true}`  

`Can Apply`  
Can apply aura  
Adds `{canApplyAura = true}`  

`Boss`  
Boss aura - important stuff, was used for damage increase on Alleria P1 adds  
Adds `{isBossAura = true}`  

`Boss or Role`  
The "either-or" between `Role` and `Boss`  
Adds `{isBossOrRoleAura= true}`  