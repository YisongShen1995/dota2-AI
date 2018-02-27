local M = {}

M["PointsOnLane"] = {}

local function InitPointsOnLane(PointsOnLane)
    for i = 1, 3, 1 do
        PointsOnLane[i] = {};
        for j = 0, 100, 1 do
            PointsOnLane[i][j] = GetLocationAlongLane(i,j / 100.0);
        end
    end
end

InitPointsOnLane(M["PointsOnLane"]);

function M:GetNearByPrecursorPointOnLane(Lane,Location)
    local npcBot = GetBot();
    local Pos = npcBot:GetLocation();
    if Location ~= nil then
        Pos = Location;
    end
    
    local PointsOnLane =  self["PointsOnLane"][Lane];
    local prevDist = (Pos - PointsOnLane[0]):Length2D();
    for i = 1,100,1 do
        local d = (Pos - PointsOnLane[i]):Length2D();
        if(d > prevDist) then
            if i >= 4 then
                return PointsOnLane[i - 4] + RandomVector(50);
            else
                return PointsOnLane[i - 1];
            end
        else
            prevDist = d;
        end
    end

    return PointsOnLane[100];
end

function M:GetNearBySuccessorPointOnLane(Lane,Location)
    local npcBot = GetBot();
    local Pos = npcBot:GetLocation();
    if Location ~= nil then
        Pos = Location;
    end
    
    local PointsOnLane =  self["PointsOnLane"][Lane];
    local prevDist = (Pos - PointsOnLane[100]):Length2D();
    for i = 100,0,-1 do
        local d = (Pos - PointsOnLane[i]):Length2D();
        if(d > prevDist) then
            if i <= 96 then
                return PointsOnLane[i + 4] + RandomVector(100);
            else
                return PointsOnLane[i + 1];
            end
        else
            prevDist = d;
        end
    end

    return PointsOnLane[0];
end

function M:GetFrontTowerAt(LANE)
    local T1 = -1;
    local T2 = -1;
    local T3 = -1;

    if(LANE == LANE_TOP) then
        T1 = TOWER_TOP_1;
        T2 = TOWER_TOP_2;
        T3 = TOWER_TOP_3;
    elseif(LANE == LANE_MID) then
        T1 = TOWER_MID_1;
        T2 = TOWER_MID_2;
        T3 = TOWER_MID_3;
    elseif(LANE == LANE_BOT) then
        T1 = TOWER_BOT_1;
        T2 = TOWER_BOT_2;
        T3 = TOWER_BOT_3;
    end

    local tower = GetTower(GetTeam(),T1);
    if(tower ~= nil and tower:IsAlive())then
        return tower;
    end

    tower = GetTower(GetTeam(),T2);
    if(tower ~= nil and tower:IsAlive())then
        return tower;
    end

    tower = GetTower(GetTeam(),T3);
    if(tower ~= nil and tower:IsAlive())then
        return tower;
    end
    return nil;
end

function M:GetComfortPoint(creeps,LANE)
    local npcBot = GetBot();
    local mypos = npcBot:GetLocation();
    local x_pos_sum = 0;
    local y_pos_sum = 0;
    local count = 0;
    local meele_coefficient = 5;-- Consider meele creeps first
    local coefficient = 1;
    for creep_k,creep in pairs(creeps)
    do
        local creep_name = creep:GetUnitName();
        local meleepos = string.find( creep_name,"melee");
        if(meleepos ~= nil) then
            coefficient = meele_coefficient;
        else
            coefficient = 1;
        end

        creep_pos = creep:GetLocation();
        x_pos_sum = x_pos_sum + coefficient * creep_pos[1];
        y_pos_sum = y_pos_sum + coefficient * creep_pos[2];
        count = count + coefficient;
    end

    local avg_pos_x = x_pos_sum / count;
    local avg_pos_y = y_pos_sum / count;

    if(count > 0) then      
        return self:GetNearByPrecursorPointOnLane(LANE,Vector(avg_pos_x,avg_pos_y)) + RandomVector(20);
    else
        return nil;
    end;
end

return M;