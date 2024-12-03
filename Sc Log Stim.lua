data_id = [[
EMAIL:PASS
EMAIL:PASS
EMAIL:PASS
]]

for str in string.gmatch(data_id, "([^\r\n]+)") do
    local email, password= str:gsub(" ",""):match("([^|]+):(.+)")
    addUbiBot(email, password, "",true)
end
