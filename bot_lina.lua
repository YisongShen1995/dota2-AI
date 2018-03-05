local LinaUtility = require(GetScriptDirectory().."/lina_utility");
require(GetScriptDirectory().."/lina_abilityuse");
require(GetScriptDirectory().."/lina_levelup");

local STATE_IDLE = "STATE_IDLE";
local STATE_ATTACKING_CREEP = "STATE_ATTACKING_CREEP";
local STATE_FIGHTING = "STATE_FIGHTING";
local STATE_GOTO_POINT = "STATE_GOTO_POINT";
local STATE_RUN_AWAY = "STATE_RUN_AWAY";
local STATE_RETREAT = "STATE_RETREAT";

local STATE = STATE_IDLE;

local LinaRetreatHPThreshold = 0.25;
local LinaRetreatMPThreshold = 0.2;

LANE = LANE_MID
------------------------
local function ConsiderFighting(StateMachine)
    local ShouldFight = false;
    local npcBot = GetBot();

    local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
    if(NearbyEnemyHeroes ~= nil) then
        for _,npcEnemy in pairs( NearbyEnemyHeroes )
        do
            if(npcBot:WasRecentlyDamagedByHero(npcEnemy,1)) then
                StateMachine["EnemyToKill"] = npcEnemy;
                ShouldFight = true;
                break;
            elseif(GetUnitToUnitDistance(npcBot,npcEnemy) < 500) then
                StateMachine["EnemyToKill"] = npcEnemy;
                ShouldFight = true;
                break;
            end
        end
    end
    return ShouldFight;
end

local function ConsiderAttackCreeps(StateMachine)
    local npcBot = GetBot();
    local EnemyCreeps = npcBot:GetNearbyCreeps(1000,true);
    local AllyCreeps = npcBot:GetNearbyCreeps(1000,false);
    if ( npcBot:IsUsingAbility() ) then return end;
    -----just hit-----
    local lowest_hp = 100000;
    local weakest_creep = nil;

    for creep_k,creep in pairs(EnemyCreeps)
    do 
        local creep_name = creep:GetUnitName();
        --LinaUtility:UpdateCreepHealth(creep);
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

    -----Nothing to do. Try to attack hero-----
    local NearbyEnemyHeroes = npcBot:GetNearbyHeroes( 700, true, BOT_MODE_NONE );
    if(NearbyEnemyHeroes ~= nil) then
        for _,npcEnemy in pairs( NearbyEnemyHeroes )
        do
            if(npcEnemy:IsAlive()) then
                npcBot:Action_AttackUnit(npcEnemy,false);
                return;
            end
        end
    end

    -----No Hero Surround: Move Random-----
    npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(250));
    StateMachine.State = STATE_IDLE;
    return;
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

local function ConsiderRetreat()
    local npcBot = GetBot();
    return npcBot:GetHealth()/npcBot:GetMaxHealth() < LinaRetreatHPThreshold or npcBot:GetMana()/npcBot:GetMaxMana() < LinaRetreatMPThreshold;
end

-----State function-----
local function StateIdle(StateMachine)




	-- StateMachine.State = STATE_RETREAT --- @@@ DEBUG
	-- return;


    local npcBot = GetBot();
    if(npcBot:IsAlive() == false) then
        return;
    end


    if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then return end;

    local creeps = npcBot:GetNearbyCreeps(1000,true);
    local comfortPoint = LinaUtility:GetComfortPoint(creeps, LANE);

    if( ConsiderRetreat()) then
        StateMachine.State = STATE_RETREAT;
        return;
    elseif(IsTowerAttackingMe()) then
        StateMachine.State = STATE_RUN_AWAY;
        return;
    elseif(npcBot:GetAttackTarget() ~= nil) then
        if(npcBot:GetAttackTarget():IsHero()) then
            print("GOT ATTACK");
            StateMachine["EnemyToKill"] = npcBot:GetAttackTarget();
            StateMachine.State = STATE_FIGHTING;
            return;
        end
    elseif(ConsiderFighting(StateMachine)) then
        StateMachine.State = STATE_FIGHTING;
        return;
    elseif(#creeps > 0 and comfortPoint ~= nil) then
        local mypos = npcBot:GetLocation();
        local d = GetUnitToLocationDistance(npcBot, comfortPoint);
        if(d > 200) then
            StateMachine.State = STATE_GOTO_POINT;
        else
            StateMachine.State = STATE_ATTACKING_CREEP;
        end
        return;
    end


    if(DotaTime() < 20) then
        local tower = LinaUtility:GetFrontTowerAt(LANE);
        npcBot:Action_MoveToLocation(tower:GetLocation());
        return;
    else
        local target = LinaUtility:GetNearBySuccessorPointOnLane(LANE);
        npcBot:Action_MoveToLocation(target);
        return;
    end
end

local function StateFighting(StateMachine)
	

    local npcBot = GetBot();
    if(npcBot:IsAlive() == false) then
        StateMachine.State = STATE_IDLE;
        return;
    end

    if( ConsiderRetreat()) then
        StateMachine.State = STATE_RETREAT;
        return;
    elseif(IsTowerAttackingMe()) then
        StateMachine.State = STATE_RUN_AWAY;
        return;
    elseif(StateMachine["EnemyToKill"]:IsNull()) then
        StateMachine.State = STATE_IDLE;
        return;
    elseif(not StateMachine["EnemyToKill"]:CanBeSeen() or not StateMachine["EnemyToKill"]:IsAlive()) then
        StateMachine.State = STATE_IDLE;
        return;
    end

    local abilityLSA = npcBot:GetAbilityByName( "lina_light_strike_array" );
    local abilityLB = npcBot:GetAbilityByName( "lina_laguna_blade" );
    local abilityDS = npcBot:GetAbilityByName( "lina_dragon_slave" );
    
    local castLBDesire, castLBTarget = ConsiderLagunaBladeFighting(abilityLB,StateMachine["EnemyToKill"]);
    local castLSADesire, castLSALocation = ConsiderLightStrikeArrayFighting(abilityLSA,StateMachine["EnemyToKill"]);
    local castDSDesire, castDSLocation = ConsiderDragonSlaveFighting(abilityDS,StateMachine["EnemyToKill"]);

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

    npcBot:Action_AttackUnit(StateMachine["EnemyToKill"],false);
end

local function StateAttackingCreep(StateMachine)

    local npcBot = GetBot();
    if(npcBot:IsAlive() == false) then
        StateMachine.State = STATE_IDLE;
        return;
    end

    local creeps = npcBot:GetNearbyCreeps(1000,true);
    local comfortPoint = LinaUtility:GetComfortPoint(creeps, LANE);
    
    if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then return end;

    if( ConsiderRetreat()) then
        StateMachine.State = STATE_RETREAT;
        return;
    elseif(IsTowerAttackingMe()) then
        StateMachine.State = STATE_RUN_AWAY;
        return;
    elseif(ConsiderFighting(StateMachine)) then
        StateMachine.State = STATE_FIGHTING;
        return;
    elseif(#creeps > 0 and comfortPoint ~= nil) then
        local mypos = npcBot:GetLocation();
        local d = GetUnitToLocationDistance(npcBot, comfortPoint);
        if(d > 200) then
            StateMachine.State = STATE_GOTO_POINT;
        else
            ConsiderAttackCreeps(StateMachine);
        end
        return;
    else
        StateMachine.State = STATE_IDLE;
        return;
    end
end


local function StateGotoPoint(StateMachine)
	

    local npcBot = GetBot();
    if(npcBot:IsAlive() == false) then
        StateMachine.State = STATE_IDLE;
        return;
    end

    local creeps = npcBot:GetNearbyCreeps(1000,true);
    local comfortPoint = LinaUtility:GetComfortPoint(creeps,LANE);

    if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then return end;

    if( ConsiderRetreat()) then
        StateMachine.State = STATE_RETREAT;
        return;
    elseif(IsTowerAttackingMe()) then
        StateMachine.State = STATE_RUN_AWAY;
    elseif(ConsiderFighting(StateMachine)) then
        StateMachine.State = STATE_FIGHTING;
        return;
    elseif(#creeps > 0 and comfortPoint ~= nil) then
        local mypos = npcBot:GetLocation();
        local d = (npcBot:GetLocation() - comfortPoint):Length2D();
 
        if (d < 200) then
            StateMachine.State = STATE_ATTACKING_CREEP;
        else
            npcBot:Action_MoveToLocation(comfortPoint);
        end
        return;
    else
        StateMachine.State = STATE_IDLE;
        return;
    end

end

local function StateRunAway(StateMachine)


    local npcBot = GetBot();

    if(npcBot:IsAlive() == false) then
        StateMachine.State = STATE_IDLE;
        StateMachine["RunAwayFromLocation"] = nil;
        return;
    end

    if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then return end;

    if( ConsiderRetreat()) then
        StateMachine.State = STATE_RETREAT;
        StateMachine["RunAwayFromLocation"] = nil;
        return;
    end

    local mypos = npcBot:GetLocation();

    if(StateMachine["RunAwayFromLocation"] == nil) then
        StateMachine["RunAwayFromLocation"] = npcBot:GetLocation();
        npcBot:Action_MoveToLocation(LinaUtility:GetNearByPrecursorPointOnLane(LANE));
        return;
    else
        if(GetUnitToLocationDistance(npcBot,StateMachine["RunAwayFromLocation"]) > 400) then
            StateMachine["RunAwayFromLocation"] = nil;
            StateMachine.State = STATE_IDLE;
            return;
        else
            npcBot:Action_MoveToLocation(LinaUtility:GetNearByPrecursorPointOnLane(LANE));
            return;
        end
    end

end


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


local function StateRetreat(StateMachine)

	print("@@@@@@@@@@@@@@@ enter stateRetreat")
    
    local npcBot = GetBot();
    if(npcBot:IsAlive() == false) then
        StateMachine.State = STATE_IDLE;
        return;
    end

    if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then return end;

  
   	if npcBot:GetHealth()/npcBot:GetMaxHealth() < LinaRetreatHPThreshold then
   		local item = GetItem("item_flask")
   		npcBot:Action_UseAbilityOnEntity(item, npcBot)
   		return;
   	elseif npcBot:GetMana()/npcBot:GetMaxMana() < LinaRetreatMPThreshold then
   		local item = GetItem("item_enchanted_mango")
   		npcBot:Action_UseAbility(item)
   		return;
   	end

    -- if ( GetTeam() == TEAM_RADIANT ) then
    --     npcBot:Action_MoveToLocation(Vector(-7000,-7000));
    -- elseif ( GetTeam() == TEAM_DIRE ) then
    --     npcBot:Action_MoveToLocation(Vector(7200,6500));
    -- end

    if(npcBot:GetHealth() == npcBot:GetMaxHealth() and npcBot:GetMana() == npcBot:GetMaxMana()) then
        StateMachine.State = STATE_IDLE;
        return;
    end
end


------------------------
local StateMachine = {};
StateMachine["State"] = STATE_IDLE;
StateMachine[STATE_IDLE] = StateIdle;
StateMachine[STATE_ATTACKING_CREEP] = StateAttackingCreep;
StateMachine[STATE_GOTO_POINT] = StateGotoPoint;
StateMachine[STATE_FIGHTING] = StateFighting;
StateMachine[STATE_RUN_AWAY] = StateRunAway;
StateMachine[STATE_RETREAT] = StateRetreat;
StateMachine["totalLevelOfAbilities"] = 0;

function Think()
    local npcBot = GetBot();
    if(AbilityLevelUpThink()) then 
        print("Level UP");
    else 
        StateMachine[StateMachine.State](StateMachine);
    end

    if(PrevState ~= StateMachine.State) then
        print("Lina bot STATE: "..StateMachine.State);
        PrevState = StateMachine.State;
    end
end

