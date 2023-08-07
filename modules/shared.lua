local Utils = {}

function Utils.Debug(TYPE, TXT)
    if Config.Debug then
        print(TYPE..' | '..TXT..' | ')
    end
end

return Utils