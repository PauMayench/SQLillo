-- Global variables
local target = nil
local cooldowns = {0, 0, 0}

-- Initialize bot
function bot_init(me)
end

-- Main bot function
function bot_main(me)
    
    -- Set target to closest visible enemy PLAYER NOT BULLET
    local closest_enemy = closest_enemy_player(me)
    local target = closest_enemy[1]
    local t_distance = closest_enemy[2]

    if target then
        local aux = attack_vector(t_distance, target, me)
        local spell = aux[1]
        local dir   = aux[2]
        if spell ~= nil then
            me:cast(spell, dir)
            print("Dist  :", t_distance)
            print("Spell :", spell)
            print("Dir   :", dir)
        end
        
        -- Move towards the target
        me:move(direction)
    end
end

function closest_enemy_player(my_player)
    -- Find the closest visible enemy
    -- ENEMY PLAYER
    local closest_enemy = nil
    local min_distance = math.huge
    for _, player in ipairs(my_player:visible()) do
        if player:type() == "player" and player:id() ~= my_player:id() then -- ADDED
            local dist = vec.distance(my_player:pos(), player:pos())
            if dist < min_distance then
                min_distance = dist
                closest_enemy = player
            end
        end
    end
    print("Calculated distance :", min_distance)
    return {closest_enemy, min_distance}
end

-- [[
-- SKILL SPELLS
--   0 <- small projectile ; damage 10
--   1 <- dash given direction
--   2 <- melee attack ; distance 2 ; damage 20
-- ]]
function attack_vector(t_dist, t_player, my_player)
    local mp = my_player
    local direction = nil
    local spell = nil
    -- If target is within melee range and melee attack is not on cooldown, use melee at
    -- UPDATED -> MELEE ATTACK
    if t_dist <= 2 and mp:cooldown(2) == 0 then
        spell = 2
    -- If target is not within melee range and projectile is not on cooldown, use projec
    -- UPDATED -> SHOOT
    elseif mp:cooldown(0) == 0 then
        spell = 0
    end
    
    direction = t_player:pos():sub(mp:pos()) -- PROVISIONAL
    return {spell, direction}
end

-- =========== UNUSED ===========
-- Check if "me" is the closest to our target
function im_closest(target_player, my_player)
    local my_id = my_player:id()
    local tg_id = target_player:id()
    local cl_id = my_id
    local dist_to_target = vec.distance(my_player:pos(), target_player:pos())
    for _, player in ipairs(my_player:visible()) do
        if player:type() == "player" and player:id() ~= tg_id and player:id() ~= my_id then
            if vec.distance(target_player:pos(), player:pos()) <= dist_to_target then
                cl_id = player:id()
            end
        end
    end
    return my_id == cl_id
end

-- [[
--      If I'm the closest player, shoot towards his direction
--      Else, try to predict where he's moving to and shoot
-- ]]
