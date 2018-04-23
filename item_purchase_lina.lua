local tableItemsToBuy = {   
    "item_flask",
	"item_enchanted_mango",
    "item_magic_stick",
	"item_circlet",
	"item_branches",
    "item_flask",
	"item_branches",
	"item_boots",
    "item_flask",
    "item_staff_of_wizardry",
    "item_flask",
    "item_ring_of_regen",
    "item_flask",
    "item_recipe_force_staff",
    "item_point_booster",
    "item_staff_of_wizardry",
    "item_ogre_axe",
    };  
  
  
-----------------------------------------------------------------------------  
  
local secretShopThreshold = 100000;  
local distanceBuyShop = 500;  
  
-- local function BotSpeak(message)l
--     local npcBot = GetBot();
--     npcBot:ActionImmediate_Chat(message,true);
--     return nil;
-- end


function ItemPurchaseThink()  
  
    local npcBot = GetBot();  
  
  
    -- npcBot:ActionImmediate_Chat("ItemPurchaseThink", true)
    local courier = GetCourier(0)
   

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
            print("Money is enough,Will Move to secret shop for: ",sNextItem);  
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

            npcBot:ActionImmediate_Chat("Money is enough,Will buy: "..sNextItem.." cost is:"..
                tostring(GetItemCost(sNextItem)), true);  

            if (GetCourierState(courier) == COURIER_STATE_AT_BASE) then
                npcBot:ActionImmediate_Chat("Courier found", true)

                if courier:ActionImmediate_PurchaseItem( sNextItem ) == PURCHASE_ITEM_SUCCESS then
                    npcBot:ActionImmediate_Chat("Courier buy "..sNextItem, true)
                    table.remove( tableItemsToBuy, 1 );  
                    
                end

                -- npcBot:ActionImmediate_PurchaseItem( sNextItem );  
                
             end
        end  
    else
        if (courier:GetItemInSlot(0) ~= nil and GetCourierState(courier) == COURIER_STATE_AT_BASE) then
            npcBot:ActionImmediate_Courier( courier, COURIER_ACTION_TRANSFER_ITEMS )
        end
    end  
  
end  

