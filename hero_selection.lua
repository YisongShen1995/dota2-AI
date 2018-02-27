

----------------------------------------------------------------------------------------------------

hero_pool_my=
{
		"npc_dota_hero_lina",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana",
		"npc_dota_hero_mirana"
}
        
function Think()
	for i,id in pairs(GetTeamPlayers(GetTeam())) 
	do
		if ( GetTeam() == TEAM_RADIANT )
		then
				if(IsPlayerBot(id) and (GetSelectedHeroName(id)=="" or GetSelectedHeroName(id)==nil))
				then
					local num= hero_pool_my[2] 		--取随机数
					SelectHero( id, num );			--在保存英雄名称的表中，随机选择出AI的英雄
					table.remove(hero_pool_my,2)		--移除这个英雄
				end
		elseif ( GetTeam() == TEAM_DIRE )
		then
				if(IsPlayerBot(id) and (GetSelectedHeroName(id)=="" or GetSelectedHeroName(id)==nil))
				then
					local num= hero_pool_my[1] 		--取随机数
					SelectHero( id, num );			--在保存英雄名称的表中，随机选择出AI的英雄
					table.remove(hero_pool_my,1)		--移除这个英雄
				end
		end	
	end
end

function UpdateLaneAssignments()

	local lanes=
	{
		[1]=LANE_TOP,
		[2]=LANE_TOP,
		[3]=LANE_TOP,
		[4]=LANE_TOP,
		[5]=LANE_TOP
	}
	return lanes;
end
----------------------------------------------------------------------------------------------------
