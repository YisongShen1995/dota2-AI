
----------------------------------------------------------------------------------------------------

function Think()
	hasLina = false
 	for i,id in pairs(GetTeamPlayers(GetTeam())) do
        if (IsPlayerBot(id)) and (GetSelectedHeroName(id)=="" or GetSelectedHeroName(id)==nil) then
        	if (GetTeam() == TEAM_RADIANT and hasLina == false) then
            	SelectHero( id, "npc_dota_hero_lina" )
            	hasLina = true
            else 
            	SelectHero( id, "npc_dota_hero_mirana" )
            end
        end
    end

end

function UpdateLaneAssignments()

	local lanes=
	{
		[1]=LANE_MID,
		[2]=LANE_TOP,
		[3]=LANE_TOP,
		[4]=LANE_TOP,
		[5]=LANE_TOP
	}
	return lanes;
end
----------------------------------------------------------------------------------------------------
