

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
					local num= hero_pool_my[2] 		--ȡ�����
					SelectHero( id, num );			--�ڱ���Ӣ�����Ƶı��У����ѡ���AI��Ӣ��
					table.remove(hero_pool_my,2)		--�Ƴ����Ӣ��
				end
		elseif ( GetTeam() == TEAM_DIRE )
		then
				if(IsPlayerBot(id) and (GetSelectedHeroName(id)=="" or GetSelectedHeroName(id)==nil))
				then
					local num= hero_pool_my[1] 		--ȡ�����
					SelectHero( id, num );			--�ڱ���Ӣ�����Ƶı��У����ѡ���AI��Ӣ��
					table.remove(hero_pool_my,1)		--�Ƴ����Ӣ��
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
