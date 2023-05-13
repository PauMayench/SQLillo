-- Global variables
local target = nil
local cooldowns = {0, 0, 0}

-- Initialize bot
function bot_init(me)
end

-- Main bot function
function bot_main(me)
    local me_pos = me:pos()
    --returns a vec type with your player position- Update cooldowns
        for i = 1, 3 do
            if cooldowns[i] > 0 then
                cooldowns[i] = cooldowns[i] - 1
            end
        end

    -- Find the closest visible enemy
    local closest_enemy = nil
    local min_distance = math.huge
    for _, player in ipairs(me:visible()) do
        local dist = vec.distance(me_pos, player:pos())
        if dist < min_distance then
            min_distance = dist
            closest_enemy = player
        end
    end

    -- Set target to closest visible enemy
    local target = closest_enemy

    if target then

        -- testing 
        if im_closest(target, me) then
            print("Im the closest")
        else
            print("I'm not")
        end
        -- end testing

        local direction = target:pos():sub(me_pos)
        -- If target is within melee range and melee attack is not on cooldown, use melee at
        if min_distance <= 2 and cooldowns[3] == 0 then
            me:cast(2, direction)
            cooldowns[3] = 50
        -- If target is not within melee range and projectile is not on cooldown, use projec
        elseif cooldowns[1] == 0 then
            me:cast(0, direction)
            cooldowns[1] = 1
        end
        -- Move towards the target
        me:move(direction)
    end
end

-- [[
--      If I'm the closest player, shoot towards his direction
--      Else, try to predict where he's moving to and shoot
-- ]]

-- Check if "me" is the closest to our target
function im_closest(target_player, my_player)
    local my_id = my_player:id()
    local tg_id = target_player:id()

    local my_distance = vec.distance(my_player:pos(), target_player:pos())
    local min_distance2 = math.huge
    
    for _, player in ipairs(my_player:visible()) do
        if player:type() == "player" then
            local pl_id = player:id()
            if (pl_id ~= my_id) and (pl_id ~= tg_id) then 
                local dist = vec.distance(target_player:pos(), player:pos())
    
                print("Curr PLAYER :", player)
                print("Curr TYPE   :", player:type())
                print("Curr DIST   :", dist)
                
                if dist < min_distance2 then
                    min_distance2 = dist
                end
            end
        end
    end
    
    print("MY  dist :", my_distance)
    print("MIN dist :", min_distance2)

    return my_distance <= min_distance2
end
