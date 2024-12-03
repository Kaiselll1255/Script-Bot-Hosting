-- Script BY ZCScript [DONT REMOVE AND RESELL]
worldList = {
    "WORLD|ID",
    "WORLD|ID"
}
doorEdit = "PUT THE ID DOOR YOU WANT TO CHANGE"

fileSuccesChange = "success.txt"
fileFailChange = "fail.txt"

delayWarp = 8500
delayHardWarp = 60000
delayReconnect = 15000
------------------------------------------------------------------------------------------------------------------------------------------------
client = getBot()
client_world = client:getWorld()

isLocked = false
successEdit = false

client.auto_reconnect = false 

function splitString(str, special)
    local rows = {}
    delimiter = special
    for row in str:gmatch("[^"..delimiter.."]+") do
        table.insert(rows, row)
    end
    return rows
end

addEvent(Event.variantlist, function(variant, netid)
    if variant:get(0):getString() == "OnConsoleMessage" then
        message = variant:get(1):getString()
        if message:find("That world is inaccessible") then 
            nuked = true
        end
        unlistenEvents()
    elseif variant:get(0):getString() == "OnDialogRequest" then
        local message = variant:get(1):getString()
        if message:find("end_dialog|door_edit") then
            if message:find("add_text_input|door_id|ID|"..doorEdit.."|") then successEdit = true else client:sendPacket(2, string.format("action|dialog_return\ndialog_name|door_edit\ntilex|%d|\ntiley|%d|\ndoor_name|ZCScript\ndoor_target|\ndoor_id|"..doorEdit , message:match("tilex|(%d+)"), message:match("tiley|(%d+)"))) end
        end
        unlistenEvents()
    end
end)

function join(world, id)
    local door, hw = 0, 0
    local check = (id and id ~= "") and true or false
    if client_world.name ~= world then 
        while client_world.name ~= world and not nuked do 
            if check then client:warp(world..'|'..id) else client:warp(world) end 
            listenEvents(math.floor(delayWarp/1000))
            if hw >= 4 then 
                if client_world.name ~= world then 
                    client:disconnect()
                    sleep(delayHardWarp)
                end 
                reconnect()
                hw = 0 
            else hw = hw + 1 end 
            reconnect()
        end 
    end 
    if check and not nuked then 
        while client_world:getTile(client.x, client.y).fg == 6 and not nuked and not wrongId do 
            client:warp(world..'|'..id)
            listenEvents(math.floor(delayWarp/1000))
            if door >= 6 then
                if client_world:getTile(client.x, client.y).fg == 6 then
                    wrongId = true 
                end 
                door = 0 
            else door = door + 1 end 
            reconnect()
        end 
    end 
end

function reconnect(world, id)
    if client.status ~= BotStatus.online then 
        while client.status ~= BotStatus.online do 
            client:connect()
            sleep(delayReconnect)
            if client.status == BotStatus.account_banned then 
                print("[ZCScript] [CHANGE DOOR] ["..client.name:upper().."] Your account got banned!")
                client:stopScript()
            end
            if client.status == BotStatus.online then 
                if world ~= "" and world then 
                    if id ~= "" and id then 
                        join(world, id)
                    else 
                        join(world)
                    end 
                end 
            end 
        end 
        print("[ZCScript] [CHANGE DOOR] ["..client.name:upper().."] Success reconnecting!")
    end 
end

function changeDoor(world, id)
    if client_world:hasAccess(client.x, client.y) > 0 then 
        while getInfo(client_world:getTile(client.x, client.y).fg).action_type == 2 and not successEdit do
            client:wrench(client.x, client.y)
            listenEvents(5)
            reconnect(world, id)
        end
        successEdit = false 
    else 
        isLocked = true 
        return false 
    end 
end

i = 1
while i <= #worldList do 
    world, doors = splitString(worldList[i], "|")[1], splitString(worldList[i], "|")[2]
    join(world, doors)
    if not nuked and not wrongId then 
        changeDoor(world, doors)
        if not isLocked then
            append(fileSuccesChange, world.."|"..doors)
            print("[ZCScript] [CHANGE DOOR] ["..client.name:upper().."] Success changing id "..world.." !")
        else
            append(fileFailChange, world.."|"..doors.."|LOCKED")
            print("[ZCScript] [CHANGE DOOR] ["..client.name:upper().."] Failed changing id in "..world.." because bot doesn't have access!")
            isLocked = false
        end
    elseif nuked then
        nuked = false 
        append(fileFailChange, world.."|"..doors.."|NUKED")
        print("[ZCScript] [CHANGE DOOR] ["..client.name:upper().."] Failed to join world because "..world.." got nuked!")
    elseif wrongId then
        wrongId = false
        append(fileFailChange, world.."|"..doors.."|WRONG")
        print("[ZCScript] [CHANGE DOOR] ["..client.name:upper().."] Failed to join world because "..world.." have wrong id!")
    end 
    if i <= #worldList then
        i = i + 1
    end 
    sleep(100)
end
