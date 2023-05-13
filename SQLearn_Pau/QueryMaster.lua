
-- Global variables
local last_entities = {}
local danger_spots = {}
local mig_cod

-- Initialize bot
function bot_init(me)

end

function set_cod()
    
    mig_cod = vec.new(250,250)
end

function print_list(list)
    for i = 1, #list do
        print(list[i])
    end
end

function bullet_hit(danger_bullets, pos)
    for _, bullet in ipairs(danger_bullets) do
        if vec.distance(bullet, pos) < 1.05 then
            return 1
        end
    end
    return 0
end

function generateCircumferencePoints(center, radius, numPoints)
    local points = {}

    for angle = 0, 360, 360 / numPoints do
        local radians = math.rad(angle)
        local punt = vec.new(radius * math.cos(radians),radius * math.sin(radians)):add(center)
        table.insert(points, punt)
    end

    return points
end

function get_danger_bullets(me)
    local entities = me:visible()
    local danger_bullets = {} -- Posicions dels bullets al seguent tick
    for _, le in pairs(last_entities) do
        for _, e in ipairs(entities) do
            if le:id() == e:id() and e:type() == "small_proj" then
                local aux = le:pos()
                local next_position = aux:sub(e:pos())
                next_position = e:pos():sub(next_position)
                table.insert(danger_bullets, next_position)
            end
        end
    end
    last_entities = entities
    danger_spots = danger_bullets
    return danger_bullets
end

function get_direccio_mes_propera(me,punts_possibles, punt)

    local min_dist = math.huge
    
    local direccio_propera = me:pos()

    for _, punt in ipairs(punts_possibles) do
        local dist = vec.distance(vec.new(250,250), punt)
        if dist < min_dist then
            min_dist = dist
            direccio_propera = punt
        end 
    end
    return direccio_propera
end

function get_punts_possibles(circ, danger_bullets)
    local punts_possibles = {}
    for _, punt in ipairs(circ) do
        if bullet_hit(danger_bullets, punt) == 0 then
            table.insert(punts_possibles, punt)
        end
    end
    return punts_possibles
end

function obtenir_moviment(me)

    local danger_bullets = get_danger_bullets(me)
    local circ = generateCircumferencePoints(me:pos(), 0.660002, 8)
    local punts_possibles = get_punts_possibles(circ, danger_bullets)
    local direccio_propera =  get_direccio_mes_propera(me, punts_possibles, mig_cod)

    return direccio_propera
end

function run_from(me, dir)
end

-- Main bot function
function bot_main(me)
    danger_spots = {}
    set_cod()
    --print(me:health())

    -- moviment --
    direccio_propera = obtenir_moviment(me)
    me:move(direccio_propera:sub(me:pos()))


    -- atac --
    local closest_enemy = closest_enemy_player(me)
    local target = closest_enemy[1]
    local t_distance = closest_enemy[2]
    
    if target then
        local aux = attack(t_distance, target, me)
        local spell = aux[1]
        local dir   = aux[2]
        if spell ~= nil then
            me:cast(spell, dir)
            --print("Dist  :", t_distance)
            --print("Spell :", spell)
            --print("Dir   :", dir)
        end
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
    --print("Calculated distance :", min_distance)
    return {closest_enemy, min_distance}
end

-- [[
-- SKILL SPELLS
--   0 <- small projectile ; damage 10
--   1 <- dash given direction
--   2 <- melee attack ; distance 2 ; damage 20
-- ]]

function attack(t_dist, t_player, my_player)
    local mp = my_player
    local dir = t_player:pos():sub(mp:pos())
    local aux_s = nil
    local aux_d = nil
    if t_dist < 200 then 
        if im_closest(t_player, my_player) then
            aux_s = 0
            aux_d = dir
            -- me:cast(0, dir) -- disparar
            if t_dist < 10 then
            run_from(mp,dir)
            end
            if t_dist <= 5.5 and mp:cooldown(1) == 0 then
                aux_s = 1
                aux_d = dir:neg()
                -- me:cast(1, dir:neg()) --dash en direccio contraria
                run_from(mp,dir)
            end
            if t_dist <= 2 and mp:cooldown(2) == 0 and me:health() > 60 then
                aux_s = 2
                aux_d = dir
                -- me:cast(2, dir) --mele
            end
        else 
            -- NO IMPLEMENTAT -> PREDICCIO
            aux_s = 0
            aux_d = dir
            -- me:cast(0, dir) --aqui podem fer predict
            run_from(mp,dir)
        end
    end
    return {aux_s, aux_d}
end

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