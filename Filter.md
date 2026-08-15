## Friendly Nameplates  
___
### Player  
**Buffs:**  
`HELPFUL|BIG_DEFENSIVE|PLAYER`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_IN_COMBAT|PLAYER`  
**Debuffs:**  
`HARMFUL` + `{ excludeSpellIDs = Blacklist }`  
### Friendly Player  
**Buffs:**  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_IN_COMBAT|PLAYER`  
**Debuffs:**  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
### Friendly NPC  
**Buffs:**  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_IN_COMBAT|PLAYER`  
**Debuffs:**  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  

## Enemy Nameplates  
___
### Enemy Player  
**Custom:**  
`HARMFUL|CROWD_CONTROL` + `{ excludeSpellIDs = Blacklist }`  
**Buffs:**  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_PLAYER_DISPELLABLE`  
`HELPFUL` + `{ isStealable = true, excludeSpellIDs = Blacklist }`  
**Debuffs:**  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY|!CROWD_CONTROL` + `{ nameplateShowPersonal = true, excludeSpellIDs = Blacklist }`  
### Enemy NPC  
**Custom:**  
`HARMFUL|CROWD_CONTROL` + `{ excludeSpellIDs = Blacklist }`  
**Buffs:**  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true, excludeSpellIDs = Blacklist }`  
`HELPFUL|IMPORTANT`  
**Debuffs:**  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY|!CROWD_CONTROL` + `{ nameplateShowPersonal = true, excludeSpellIDs = Blacklist }`  

## Individual Units  
___
### Player  
**Buffs:**  
`HELPFUL|BIG_DEFENSIVE|PLAYER`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
**Debuffs:**  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE` + `{ excludeSpellIDs = Blacklist }`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
`HARMFUL` + `{ isPriorityAura = true, excludeSpellIDs = Blacklist }`  
### Pet  
**Buffs:**  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
**Debuffs:**  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
`HARMFUL` + `{ isPriorityAura = true, excludeSpellIDs = Blacklist }`  
### Target  
**Custom:**  
`HARMFUL|CROWD_CONTROL` + `{ excludeSpellIDs = Blacklist }`  
**Buffs:**  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true, excludeSpellIDs = Blacklist }`  
`HELPFUL|IMPORTANT`  
`HELPFUL` + `{ isFromPlayerOrPlayerPet = true }`  
**Debuffs:**  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY` + `{ nameplateShowPersonal = true, excludeSpellIDs = Blacklist }`  

### Focus  
**Buffs:**  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true, excludeSpellIDs = Blacklist }`  
`HELPFUL|IMPORTANT`  
`HELPFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
**Debuffs:**  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
`HARMFUL` + `{ isPriorityAura = true, excludeSpellIDs = Blacklist }`  
### TargetTarget  
**Buffs:**  
`HELPFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
**Debuffs:**  
`HARMFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
### TargetTargetTarget  
**Buffs:**  
`HELPFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
**Debuffs:**  
`HARMFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
### FocusTarget  
**Buffs:**  
`HELPFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
**Debuffs:**  
`HARMFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
### PetTarget  
**Buffs:**  
`HELPFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
**Debuffs:**  
`HARMFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  

## Group Units  
___
### Arena  
**Buffs:**  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL|RAID_PLAYER_DISPELLABLE`  
`HELPFUL` + `{ isStealable = true, excludeSpellIDs = Blacklist }`  
`HELPFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
**Debuffs:**  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY` + `{ nameplateShowPersonal = true, excludeSpellIDs = Blacklist }`  
`HARMFUL|CROWD_CONTROL`  
### Boss  
**Buffs:**  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true, excludeSpellIDs = Blacklist }`  
`HELPFUL|IMPORTANT`  
**Debuffs:**  
`HARMFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY` + `{ nameplateShowPersonal = true, excludeSpellIDs = Blacklist }`  
### Party  
**Buffs:**  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL` + `{ includeSpellIDs = Whitelist }`  
**Debuffs:**  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
`HARMFUL` + `{ isPriorityAura = true }`  
### Raid  
**Buffs:**  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
`HELPFUL` + `{ includeSpellIDs = Whitelist }`  
**Debuffs:**  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
`HARMFUL` + `{ isPriorityAura = true }`  
### Tank  
**Buffs:**  
`HELPFUL` + `{ isBossOrRoleAura = true }`  
`HELPFUL` + `{ isStealable = true, excludeSpellIDs = Blacklist }`  
`HELPFUL|IMPORTANT`  
`HELPFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
`HELPFUL|BIG_DEFENSIVE`  
`HELPFUL|EXTERNAL_DEFENSIVE`  
**Debuffs:**  
`HARMFUL|IMPORTANT`  
`HARMFUL|RAID_PLAYER_DISPELLABLE`  
`HARMFUL|CROWD_CONTROL`  
`HARMFUL|RAID` + `{ excludeSpellIDs = Blacklist }`  
`HARMFUL` + `{ isPriorityAura = true }`  
### Assist  
**Buffs:**  
`HELPFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
**Debuffs:**  
`HARMFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
### Raid Pet  
**Buffs:**  
`HELPFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  
**Debuffs:**  
`HARMFUL` + `{ excludeSpellIDs = Blacklist }` (Disable module by default)  

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