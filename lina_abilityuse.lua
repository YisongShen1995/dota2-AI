function CanCastLightStrikeArrayOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastDragonSlaveOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastLagunaBladeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and npcTarget:IsHero() and ( GetBot():HasScepter() or not npcTarget:IsMagicImmune() ) and not npcTarget:IsInvulnerable();
end


function ConsiderDragonSlaveFighting(abilityDS,enemy)
    local npcBot = GetBot();

    if ( not abilityDS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	local nCastRange = abilityDS:GetCastRange();
	local d = GetUnitToUnitDistance(npcBot,enemy);

	if(d < nCastRange and CanCastDragonSlaveOnTarget(enemy))then
		return BOT_ACTION_DESIRE_MODERATE, enemy:GetLocation();
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLightStrikeArrayFighting(abilityLSA,enemy)
    local npcBot = GetBot();

	if ( not abilityLSA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	local nCastRange = abilityLSA:GetCastRange();

	local EnemyLocation = predictPosition(enemy,1);

	local d = GetUnitToLocationDistance(npcBot,EnemyLocation);

	if (d < nCastRange and CanCastLightStrikeArrayOnTarget( enemy ) ) 
	then
		return BOT_ACTION_DESIRE_MODERATE, EnemyLocation;
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLagunaBladeFighting(abilityLB,enemy)

	local npcBot = GetBot();

	if ( not abilityLB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityLB:GetCastRange();
	local nDamage = abilityLB:GetSpecialValueInt( "damage" );
	local eDamageType = npcBot:HasScepter() and DAMAGE_TYPE_PURE or DAMAGE_TYPE_MAGICAL;

    local d = GetUnitToUnitDistance(npcBot,enemy);

    if (d < nCastRange and CanCastLagunaBladeOnTarget( enemy ) ) then
		return BOT_ACTION_DESIRE_HIGH, enemy;
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

-----TODO: Maybe we need to change this prediction better
function predictPosition(hero,t)
    local ret = hero:GetLocation();
	local v = hero:GetVelocity();
	ret[1] = ret[1] + t * v[1];
	ret[2] = ret[2] + t * v[2];
	return hero:GetLocation();
end

