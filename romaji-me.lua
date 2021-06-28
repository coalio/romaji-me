unpack = table.unpack or unpack

local mapping = require('src.mapping')

local help = 
    'usage: romaji-me <kana>' .. '\n'

if not arg[1] then print(help) os.exit(22) end

local output = mapping:transliterate(arg[1])
local clean_output = mapping:clean(output)
if (clean_output == '') then
    io.stderr:write(("\n%s"):format('The input contains invalid characters.'))
end

io.stdout:write(("%s - %s\n"):format(arg[1], clean_output))