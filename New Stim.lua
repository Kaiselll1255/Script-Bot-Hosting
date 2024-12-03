botData = [[
ubiemail|ubipass|stimuser|stimpass
ubiemail|ubipass|stimuser|stimpass
ubiemail|ubipass|stimuser|stimpass
]]

for str in string.gmatch(botData, "([^\r\n]+)") do
    local email, password, steam_user, steam_password = str:gsub(" ",""):match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
    bot = addSteamBot(email, password, steam_user .. ":" .. steam_password)
end
