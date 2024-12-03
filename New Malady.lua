--credit @realneja <- dont delete this and share to your fellas to appreciate :)

-- Konfig

start_spam_before_malady_end = 5 -- minute 


delay_spam = 8000
text       = { 'jifjvsofjo osifjvoisfjo sifjvsiofsd', 'jodvjsod psvjosdfvjof vvjfs', 'jidv sjdfvosdjfos vjsdfoivjsf',
    'jadjvod jsovjosfjo diojvdfiovjoif sdfv', 'jiosjfovjsdfiov sdfovjsofjvo' }

Malady     = {
    'Torn Punching Muscle',
    'Gem Cuts',
    'Broken Heart',
    'Grumbleteeth',
    'Chicken Feet',
    'Lupus',
    'Moldy Guts',
    'Ecto-Bones',
    'Chaos Infection',
    'Fatty Liver',
    'Brainworms'
}

-- var
bot        = getBot()
rotation   = bot.rotation

local world
-- body ( don't touch any )

function warp(world, id)
    world = world:upper()
    id = id or ''
    nuked = false
    stuck = false
    if not bot:isInWorld(world) then
        addEvent(Event.variantlist, function(var, netid)
            if var:get(0):getString() == "OnConsoleMessage" then
                if var:get(1):getString() == "That world is inaccessible." then
                    nuked = true
                    unlistenEvents()
                end
            end
        end)
        while not bot:isInWorld(world) and not nuked do
            bot:warp(id == '' and world or world .. ('|' .. id))
            sleep(5000)
        end
        removeEvent(Event.variantlist)
    end
    if bot:isInWorld(world) and getTile(bot.x, bot.y).fg == 6 and id ~= '' then
        count = 0
        while getTile(bot.x, bot.y).fg == 6 and not stuck do
            bot:warp(id == '' and world or world .. ('|' .. id))
            sleep(5000)
            count = count + 1
            if count % 5 == 0 then
                stuck = true
            end
        end
    end
end

function reconnect(world, id, x, y)
    if bot.status ~= BotStatus.online then
        local sended = false
        while bot.status ~= BotStatus.online or bot:getPing() == 0 do
            sleep(10000)
            if bot.status == BotStatus.account_banned and not sended then
                log("Failed to reconnect, account is banned")
                sended = true
            end
        end
        sleep(5000)
    end
    if bot.status == BotStatus.online then
        if world and not bot:isInWorld() then
            warp(world, id)
            if x and y then
                while not bot:isInTile(x, y) do
                    bot:findPath(x, y)
                    sleep(500)
                end
            end
        end
    end
end

function custom_status(text)
    getBot().custom_status = tostring(text)
end

function log(text)
    print('[ ' .. bot.name .. ' ] -> ' .. tostring(text))
end

function clear_console()
    for i = 1, 50 do
        bot:getConsole():append("")
    end
end

function find_command_status()
    for _, v in pairs(bot:getConsole().contents) do
        if v:find("Status:") and bot.status == 1 then
            return true
        end
        sleep(10)
    end
    return false
end

function untill_malady()
    for _, content in pairs(bot:getConsole().contents) do
        for _, malady in ipairs(Malady) do
            if content:find(malady) then
                local hours, minutes, seconds
                hours, minutes, seconds = content:match("(%d+) hours?, (%d+) mins?, (%d+) secs? left")

                if not hours then
                    minutes, seconds = content:match("(%d+) mins?, (%d+) secs? left")
                    hours = 0
                end

                if not minutes then
                    seconds = content:match("(%d+) secs? left")
                    minutes = 0
                end

                seconds = seconds or 0

                if hours and minutes and seconds then
                    local total_seconds = (tonumber(hours) * 3600) + (tonumber(minutes) * 60) + tonumber(seconds)
                    return total_seconds, malady
                else
                    custom_status(malady)
                    return 0, malady
                end
            end
        end
    end
    return false, nil
end


function realtime_status(total_seconds, malady, start_spam_before_malady_end)
    if malady == nil then
        return
    end
    local delay_seconds = start_spam_before_malady_end * 60
    total_seconds = total_seconds - delay_seconds
    if total_seconds < 0 then
        total_seconds = 0
    end
    for i = total_seconds, 1, -1 do
        getBot().custom_status = malady .. ' - ' .. i .. 's left '
        sleep(1000)
    end

    local delay_start_time = os.time()
    while os.time() - delay_start_time < delay_seconds do
        rotation.enabled = false
        getBot().custom_status = malady .. ' - ' .. delay_seconds - (os.time() - delay_start_time) .. 's doing spam'
        sleep(1000)
        if bot:isInWorld() and world then
            reconnect(world, '')
            index = math.random(#text)
            bot:say(text[index])
            sleep(delay_spam)
        end
    end
end

function check_malady()
    local malady_duration, malady_name = untill_malady()
    if bot:isInWorld() and not world then
        local t = tostring(getWorld().name)
        if t ~= "EXIT" then
            world = t
        else
            log('bot in exit')
        end

    end

    if bot:isInWorld() and bot.status == 1 and world then
        clear_console()
        sleep(1000)
        bot:say('/status')
        sleep(2000)
    end

    local malady_found = false

    if find_command_status() and bot.status == 1 and world and bot:isInWorld() then
        local malady_duration, content_found = untill_malady()
        if content_found then
            malady_found = true
            rotation.enabled = true
            realtime_status(malady_duration, malady_name, start_spam_before_malady_end) 
            rotation.enabled = false
            return content_found
        else
            log('No malady found')
        end
    end

    if not malady_found and bot.status == 1 and world then
        while not malady_found and bot.status == 1 and world do
            while not bot:isInWorld() do
                warp(world)
            end

            rotation.enabled = false
            custom_status(" No Malady ")
            clear_console()
            sleep(1000)
            bot:say("/status")
            sleep(2000)
            reconnect(world, '')

            if bot:isInWorld() and world then
                reconnect(world, '')
                index = math.random(#text)
                bot:say(text[index])
                sleep(delay_spam)
            end

            local malady_duration, content_found = untill_malady()
            if content_found then
                malady_found = true
                rotation.enabled = true
                log('Malady detected: ' .. content_found)
                realtime_status(malady_duration, malady_name, start_spam_before_malady_end)
                rotation.enabled = false
                return malady_name
            end
        end
    end
    return malady_found
end

while true do
    check_malady()
    sleep(3000)
end

