--credit @realneja <- dont delete this and share to your fellas to appreciate :)

-- Konfig




extra_sleep = 3 -- extra sleep after the malady removed


delay_spam = 8000
text       = {'halo aku adalah neja ya', 'aku pandai membuat script tapi', 'semua berhak keadilan dan di adili','garden elysium hampir mati', ' tempat ku bukan disini' }
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
    for k, content in pairs(bot:getConsole().contents) do
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
                    local total_seconds = (tonumber(hours) * 3600) + (tonumber(minutes) * 60) + tonumber(seconds) + extra_sleep
                    custom_status(malady)
                    return total_seconds, content
                else
                    custom_status(malady)
                    return 0, content
                end
            end
        end
    end
    return false, nil
end

function check_malady()
    if bot:isInWorld() and not world then
        local t = tostring(getWorld().name)
        if t ~= "EXIT" then
            world = t
        else
            log('World is EXIT, not saving to variable')
        end
    end

    if bot:isInWorld() and bot.status == 1 and world then
        clear_console()
        sleep(1000)
        bot:say('/status')
        sleep(3000)
    end

    local malady_found = false

    if find_command_status() and bot.status == 1 and world and bot:isInWorld() then
        local malady_duration, content_found = untill_malady()
        if content_found then
            malady_found = true
            log('Content found: ' .. content_found)
            rotation.enabled = true
            sleep(2000)
            sleep(malady_duration * 1000)
            return content_found
        else
            log('No malady content found in bot console.')
        end
    end

    if not malady_found and bot.status == 1 and world then
        local attempt_counter = 0

        while not malady_found and bot.status == 1 and world do
            while not bot:isInWorld() do
                warp(world)
            end

            custom_status(" ")
            clear_console()
            sleep(1000)
            bot:say("/status")
            sleep(3000)
            rotation.enabled = false
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
                sleep(malady_duration * 1000)
            end

            attempt_counter = attempt_counter + 1

            if attempt_counter >= 25 then
                log('Bot will disconnect and retry after 25 attempts')
                bot:disconnect()
                sleep(5000)
                reconnect(world, '')
                attempt_counter = 0
            end
        end
    end
    return malady_found
end

while true do
    check_malady()
    sleep(3000)
end

