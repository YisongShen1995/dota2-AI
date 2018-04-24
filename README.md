Update:

We've got a website updating what we have done: https://csci524dota2ai.wordpress.com/

We've developed a decision tree version of our AI.

----
# A dota2-AI for Lina Solo Mid

This project is still under development.

We have developed a state machine for Lina to buy items, learn skills, use items and skills, farm, control her position, attack, retreat and run away. The logic for the state machine for now is as follows:

## Idle State
 - The basic state for our AI.
 - It will determine which state should our AI go to next.
 - If there is no next state, back to the lane where our AI should be.
 
## Fight State
 - Enter the state if there is an enemy hero nearby or be recently attacked by an enemy hero.
 - Casting skills on the target enemy hero if possible.
 - If no skills can be casted, auto attack the target enemy hero .
 - If the target enemy hero cannot be seen, back to “idle stat”

## Attack Creep State
 - Enter the state if there is a enemy creep nearby.
 - Our AI will attack the weakest enemy creep with health lower than 50% trying to last hit.
 - If there is no enemy creep with health lower than 50%, auto attack a enemy hero nearby.
 - If there is no enemy hero nearby, randomly move a specific distance and back to “idle state”.
 
 ## Run Away State
  - Enter the state if our AI is too close to the tower without enough ally creeps surrounded.
 - Or our AI is attacked by the tower.
 - Run away from the tower until our AI is far enough.
 - Back to “idle state” when our AI is far enough to the tower.

## Retreat State
- Enter the state if health or mana of our AI is lower than a specific percentage.
- Use item or go back to the fountain until having enough health and mana.
- Back to “idle state” after having enough health and mana.

## Go to Point State
-  The state is used to adjust our AI position to a better position (comfort point).
-  The comfort point is a position that have appropriate distance from enemy creeps.
 - Enter the state if our AI is trying to attack creeps but the distance to the comfort point is too far.
 - Back to “idle state” if there is no enemy creeps or no comfort point.
