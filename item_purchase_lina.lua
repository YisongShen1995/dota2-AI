local tableItemsToBuy = {   
 --    "item_flask",
	-- "item_enchanted_mango",
 --    "item_magic_stick",
	-- "item_circlet",
	-- "item_branches",
	-- "item_branches",
	-- "item_boots"
    };  
  
  
-----------------------------------------------------------------------------  
  
local secretShopThreshold = 100000;  
local distanceBuyShop = 500;  
  
function ItemPurchaseThink()  
  
    local npcBot = GetBot();  
  
  


    if ( #tableItemsToBuy == 0 )  
    then  
        npcBot:SetNextItemPurchaseValue( 0 );  
        return;  
    end  
  
    local sNextItem = tableItemsToBuy[1];  
  
    npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );  
  
    if ( npcBot:GetGold() >= GetItemCost( sNextItem ) )  
    then  
        if ( IsItemPurchasedFromSecretShop(sNextItem) and   
            npcBot:DistanceFromSecretShop() <= secretShopThreshold )  
        then  
            --print("Money is enough,Will Move to secret shop for: ",sNextItem);  
            npcBot.secretShopMode = true;  
  
            local shop_top = Vector(-4600, 1200);  
            local shop_bot = Vector(4600,  -1200);  
  
            local dist_top = GetUnitToLocationDistance( npcBot, shop_top );  
            local dist_bot = GetUnitToLocationDistance( npcBot, shop_bot );  
  
            if (dist_top < dist_bot) then  
                npcBot:Action_MoveToLocation(shop_top);  
            else  
                npcBot:Action_MoveToLocation(shop_bot);  
            end  
  
            if ( npcBot:DistanceFromSecretShop() <= distanceBuyShop )   
            then  
                print("Will buy at secret shop : ",sNextItem," cost is:",  
                    tostring(GetItemCost(sNextItem)));  
                npcBot:ActionImmediate_PurchaseItem( sNextItem );  
                table.remove( tableItemsToBuy, 1 );  
                npcBot.secretShopMode = false;  
            end  
        else  
            print("Money is enough,Will buy: ",sNextItem," cost is:",  
                tostring(GetItemCost(sNextItem)));  
            npcBot:ActionImmediate_PurchaseItem( sNextItem );  
            table.remove( tableItemsToBuy, 1 );  
        end  
    end  
  
end  