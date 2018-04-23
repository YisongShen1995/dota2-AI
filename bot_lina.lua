local LinaUtility = require(GetScriptDirectory().."/lina_utility");
require(GetScriptDirectory().."/lina_abilityuse");
require(GetScriptDirectory().."/lina_levelup");

--Tree Node Use
--------------------------------------------------------
local NODE_IDLE = "NODE_IDLE";
local NODE_ATTACKING_CREEP = "NODE_ATTACKING_CREEP";
local NODE_FIGHTING = "NODE_FIGHTING";
local NODE_GOTO_POINT = "NODE_GOTO_POINT";
local NODE_RUN_AWAY = "NODE_RUN_AWAY";
local NODE_RETREAT = "NODE_RETREAT";
local NODE_WANDER = "NODE_WANDER";

local NODE = NODE_IDLE;

local LinaRetreatHPThreshold = 0.5;
local LinaRetreatMPThreshold = 0.2;
local LinaGoBaseHPThreshold = 0.25;
local EnemyToKill = nil;
local RunAwayFromLocation = nil;
local Retreating = false;

local state = "";
local pre_state = "";
local isGoingToBase=false;
LANE = LANE_MID


local function GetItem(itemName)
    local npcBot  = GetBot()
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i)
        if (item) and item:GetName() == itemName then
            return item
        end
    end
    return nil
end


--Tree Branch
--------------------------------------------------------
local function IsNearByCreep()
    local npcBot = GetBot();
    local EnemyCreeps = npcBot:GetNearbyCreeps(1000,true);
    return #EnemyCreeps ~= 0;
end

local function IsNearByEnemy()
    local npcBot = GetBot();
    local NearbyEnemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
    if(NearbyEnemyHeroes ~= nil) then
        for _,npcEnemy in pairs( NearbyEnemyHeroes )
        do
            if(npcBot:WasRecentlyDamagedByHero(npcEnemy,1) or GetUnitToUnitDistance(npcBot,npcEnemy) < 700) then
                EnemyToKill = npcEnemy;
                return true;
            end
        end
    end
    return false;
end

local function NeedComfortPoint()
    local npcBot = GetBot();
    local creeps = npcBot:GetNearbyCreeps(1000,true);
    local comfortPoint = LinaUtility:GetComfortPoint(creeps, LANE);

    if(#creeps > 0 and comfortPoint ~= nil) then
        return GetUnitToLocationDistance(npcBot, comfortPoint) > 200;
    end

    return false;
end

local function IsTowerAttackingMe()
    local npcBot = GetBot();
    local NearbyTowers = npcBot:GetNearbyTowers(1200,true);
    local AllyCreeps = npcBot:GetNearbyCreeps(650,false);

    if(npcBot:GetAttackTarget() ~= nil and npcBot:GetAttackTarget():IsTower()) then
        print("Lina is Attacking by tower");
        return true;
    end

    if(#NearbyTowers > 0) then
        for _,tower in pairs( NearbyTowers)
        do
            if(GetUnitToUnitDistance(tower,npcBot) < 900 and tower:IsAlive() and #AllyCreeps <= 2) then
                print("Lina Attacked by tower");
                return true;
            end
        end
    end
    return false;
end



local function GetHPRatio(npc)
    return npc:GetHealth()/npc:GetMaxHealth();
end

-- local function BotSpeak(message)l
--     local npcBot = GetBot();
--     npcBot:ActionImmediate_Chat(message,true);    
--     return nil;
-- end

local function ConsiderRetreat()
	
    local npcBot = GetBot();
	-- npcBot:ActionImmediate_Chat("ConsiderRetreat",true);

	-- BotSpeak("ConsiderRetreat");

    if (state == "Fighting") then
        if (EnemyToKill ~= nil and GetHPRatio(EnemyToKill) < GetHPRatio(npcBot)) then
        	-- npcBot:ActionImmediate_Chat("ConsiderRetreat-fight-false",true);
            return false
        end
    end
    
    if (GetHPRatio(npcBot) < LinaRetreatHPThreshold and GetItem("item_flask")) or GetHPRatio(npcBot) < LinaGoBaseHPThreshold then
    	-- npcBot:ActionImmediate_Chat("1",true);
    	-- npcBot:ActionImmediate_Chat("hp<0.5&have item or hp < 0.2",true);
    	return true
    else
    	-- npcBot:ActionImmediate_Chat("2",true);
    	-- npcBot:ActionImmediate_Chat("0.2<hp<0.5&no item  or hp>0.5",true);
    	return false
    end
    -- return GetHPRatio(npcBot) < LinaRetreatHPThreshold-- or npcBot:GetMana()/npcBot:GetMaxMana() < LinaRetreatMPThreshold;
end


--Tree Agent
--------------------------------------------------------
local function ActionIdle()
    local npcBot = GetBot();
    if(DotaTime() < 15) then
        local tower = LinaUtility:GetFrontTowerAt(LANE);
        npcBot:Action_MoveToLocation(tower:GetLocation());
        return;
    else
        local target = LinaUtility:GetNearBySuccessorPointOnLane(LANE);
        npcBot:Action_MoveToLocation(target);
        return;
    end
end

local function ActionFighting()
    if(EnemyToKill ~= nil) then
        local npcBot = GetBot();
        
        local abilityLSA = npcBot:GetAbilityByName( "lina_light_strike_array" );
        local abilityLB = npcBot:GetAbilityByName( "lina_laguna_blade" );
        local abilityDS = npcBot:GetAbilityByName( "lina_dragon_slave" );
        
        local castLBDesire, castLBTarget = ConsiderLagunaBladeFighting(abilityLB,EnemyToKill);
        local castLSADesire, castLSALocation = ConsiderLightStrikeArrayFighting(abilityLSA,EnemyToKill);
        local castDSDesire, castDSLocation = ConsiderDragonSlaveFighting(abilityDS,EnemyToKill);

        if ( castLBDesire > 0 ) then
            npcBot:Action_UseAbilityOnEntity( abilityLB, castLBTarget );
            return;
        elseif ( castLSADesire > 0 ) then
            npcBot:Action_UseAbilityOnLocation( abilityLSA, castLSALocation );
            return;
        elseif ( castDSDesire > 0 ) then
            npcBot:Action_UseAbilityOnLocation( abilityDS, castDSLocation );
            return;
        end

        npcBot:Action_AttackUnit(EnemyToKill,false);
    end
end

local function ActionAttackingCreep()
    local npcBot = GetBot();



    local EnemyCreeps = npcBot:GetNearbyCreeps(1000,true);
    local AllyCreeps = npcBot:GetNearbyCreeps(1000,false);

    local lowest_hp = 100000;
    local weakest_creep = nil;

    for creep_k,creep in pairs(EnemyCreeps)
    do 
        local creep_name = creep:GetUnitName();
        if(creep:IsAlive()) then
            local creep_hp = creep:GetHealth();
            if(lowest_hp > creep_hp) then
                 lowest_hp = creep_hp;
                 weakest_creep = creep;
            end
        end
    end

    -----TODO: ADD MORE LANE CONTROL-----
    if(weakest_creep ~= nil and #AllyCreeps < #EnemyCreeps) then
        npcBot:Action_AttackUnit(weakest_creep,true);
        return;
    end

    if(weakest_creep ~= nil and weakest_creep:GetHealth() / weakest_creep:GetMaxHealth() < 0.5) then
        npcBot:Action_AttackUnit(weakest_creep,true);
        return;
    end

    npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(250));
end

local function ActionGotoPoint()
    local npcBot = GetBot();

    local creeps = npcBot:GetNearbyCreeps(1000,true);
    local comfortPoint = LinaUtility:GetComfortPoint(creeps,LANE);

    if(#creeps > 0 and comfortPoint ~= nil) then
        npcBot:Action_MoveToLocation(comfortPoint);
    else
    	local tower = LinaUtility:GetFrontTowerAt(LANE);
    	npcBot:Action_MoveToLocation(tower:GetLocation());
    end
end

local function ActionRunAway()
    local npcBot = GetBot();
    local mypos = npcBot:GetLocation();
    npcBot:Action_MoveToLocation(LinaUtility:GetNearByPrecursorPointOnLane(LANE));
end



local function GoToBase()
    local npcBot = GetBot()
    if ( GetTeam() == TEAM_RADIANT ) then
        npcBot:Action_MoveToLocation(Vector(-7000,-7000))
    elseif ( GetTeam() == TEAM_DIRE ) then
        npcBot:Action_MoveToLocation(Vector(7200,6500))
    end
end

local function ActionRetreat()
    local npcBot = GetBot();
    Retreating = true;
	
	if(npcBot:GetHealth() == npcBot:GetMaxHealth()) then
        Retreating = false;
        isGoingToBase = false;
    end
        
    --local tower = LinaUtility:GetFrontTowerAt(LANE);
    --npcBot:Action_MoveToLocation(tower:GetLocation());

    local item = GetItem("item_flask")
    if (item) then
        -- use item in safe place
        --local tower = LinaUtility:GetFrontTowerAt(LANE);
        --npcBot:Action_MoveToLocation(tower:GetLocation());
        npcBot:Action_UseAbilityOnEntity(item, npcBot);
        npcBot:ActionImmediate_Chat("use item_flask to retreat",true);
        --ActionRunAway()
        --state = "Runaway"
        Retreating = false;
        return;
    else
        if npcBot:GetHealth()/npcBot:GetMaxHealth() < LinaGoBaseHPThreshold then
            GoToBase()
            isGoingToBase = true
            npcBot:ActionImmediate_Chat("Go to base to retreat",true);
            return;
        end
    end     
end

-- local function ActionRetreatSub()
--     local npcBot = GetBot();
--     if(npcBot:IsAlive() == false) then
--         StateMachine.State = STATE_IDLE;
--         return;
--     end

--     if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then return end;
--     if ( GetTeam() == TEAM_RADIANT ) then
--         npcBot:Action_MoveToLocation(Vector(-7000,-7000));
--     elseif ( GetTeam() == TEAM_DIRE ) then
--         npcBot:Action_MoveToLocation(Vector(7200,6500));
--     end
--     if(npcBot:GetHealth() == npcBot:GetMaxHealth() and npcBot:GetMana() == npcBot:GetMaxMana()) then
--         StateMachine.State = STATE_IDLE;
--         return;
--     end
    
-- end



--Think
--------------------------------------------------------
local NodeData = {};
NodeData["totalLevelOfAbilities"] = 0;

local function NodeUpdate()
    local npcBot = GetBot();
    pre_state = state;
    if(npcBot:IsAlive() == false) then
        return;
    end

    if(npcBot:IsUsingAbility() or npcBot:IsChanneling()) then
        return;
    end

    if(isRetreating) then
        ActionRetreat();
        state = "Retreating";
        return;
    else
        if(IsTowerAttackingMe()) then
            ActionRunAway();
            state = "Runaway";
            return;
        else
            if(ConsiderRetreat()) then
                ActionRetreat();
                state = "Retreating";
                return;
            else
                if(IsNearByEnemy()) then
                    ActionFighting();
                    state = "Fighting";
                    return;
                else
                    if(IsNearByCreep()) then
                        if(NeedComfortPoint()) then

                            ActionGotoPoint();
                            state = "GotoPoint";
                            return;
                        else
                        	--if(isGoingToPoint)then
                        	--	ActionGotoPoint();
                            --	state = "GotoPoint";
                            --	return;
                            --else
                            ActionAttackingCreep();
                            state = "AttackingCreep";
                            return;
                            --end
                        end
                    else
                        ActionIdle();
                        state = "Idle";
                        return;
                    end
                end
            end
        end
    end
end

function Think()
    local npcBot = GetBot();
    if(AbilityLevelUpThink()) then 
        print("Level UP");
    else
        NodeUpdate();
    end
    local message = "Transfer to state: ".. state;
    if(state ~= pre_state)then
        npcBot:ActionImmediate_Chat(message,true);
    end
end
