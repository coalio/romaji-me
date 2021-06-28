-- Transliterates kana to a romaji standard

utf8 = require('src.libs.utf8.utf8')

mapping = {
    map = require('src.data.hepburn'),
    buffer = {
        caret = 0,
        content = '',
        append = function(self, str)
            self.content = self.content .. str
            self.caret = self.caret + utf8.len(str)
            return utf8.len(str)
        end
    }
}

setmetatable(mapping.buffer, {
    __call = function(self)
        local str = self.content
        self.content = ''
        self.caret = 0
        return str
    end
});

-- Ranges allowed:
-- 32: space
-- 65 - 90: upper-case ASCII roman letters
-- 97 - 122: lower-case ASCII roman letters
-- 0x3041 - 0x3093: UCS/Unicode 16-bit code range for hiragana 
function mapping:clean(input)
    return utf8.gsub(input, '.', function(character)
        local charcode = utf8.unicode(character)
        local in_range = 
            (charcode == 32)                     or
            (charcode >= 65 and charcode <= 90)  or 
            (charcode >= 97 and charcode <= 122) or 
            (charcode >= 0x3041 and charcode <= 0x3093)
            
        return in_range and character or ''
    end)
end

function mapping:transliterate(input)
    -- Read and convert
    local substring
    for caret = 1, utf8.len(input), 2 do
        substring = utf8.sub(input, caret, 1 + caret)
        if substring == '' then break end

        if (self.map[substring]) then
            self.buffer:append(self.map[substring])
        else
            for i = 1, 2 do
                local character = utf8.sub(substring, i, i)
                if character == 'ー' then
                    -- long vowel dash
                    local vowel = self.buffer.content:sub(-1, -1)
                    character = vowel == 'e' and 'i' or vowel -- えい
                end
                if character == 'ッ' then
                    -- extend consonant
                    local consonant = self.map[utf8.sub(input, caret + 2, caret + 2)]
                    character = consonant and consonant:sub(1,1) or ''
                end
                self.buffer:append(self.map[character] or character)
            end
        end
    end

    return self.buffer()
end

return mapping
