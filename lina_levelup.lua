local SKILL_Q = "lina_dragon_slave"
local SKILL_W = "lina_light_strike_array"
local SKILL_E = "lina_fiery_soul"
local SKILL_R = "lina_laguna_blade"

local TALENT1 = "special_bonus_unique_lina_3"
local TALENT2 = "special_bonus_cast_range_125"
local TALENT3 = "special_bonus_attack_damage_50"
local TALENT4 = "special_bonus_movement_speed_40"
local TALENT5 = "special_bonus_spell_amplify_6"
local TALENT6 = "special_bonus_attack_range_150"
local TALENT7 = "special_bonus_unique_lina_1"
local TALENT8 = "special_bonus_unique_lina_2"

local LinaAbilityPriority = {
    SKILL_Q,    SKILL_E,    SKILL_Q,     SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,     SKILL_E,    TALENT1,
    SKILL_E,    SKILL_R,    SKILL_W,     SKILL_W,    TALENT3,
    SKILL_W,    SKILL_R,    TALENT5,     TALENT7
}

function AbilityLevelUpThink()
    local npcBot = GetBot();
    
    if npcBot:GetAbilityPoints()<1 or #LinaAbilityPriority==0 then
        return false;
    end
    
    local ability=npcBot:GetAbilityByName(LinaAbilityPriority[1]);
    
    if ability~=nil and ability:CanAbilityBeUpgraded() then
        print(LinaAbilityPriority[1]);
        npcBot:ActionImmediate_LevelAbility(LinaAbilityPriority[1]);
        table.remove( LinaAbilityPriority, 1 );
        return true;
    end

    return false;
end