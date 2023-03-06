--Blackjack Casino version 0.0.2--

local vers = "0.0.2"

--Made by Mavric--
--How to setup is on my youtube channel--
--Code on https://pastebin.com/u/MavricMC--


local cords = {
    {23},
    {18, 26},
    {14, 22, 30},
    {10, 18, 26, 34},
    {6, 14, 22, 30, 38},
    {3, 11, 19, 27, 35, 43}
}

local pCords = {
    {22},
    {14, 30},
    {7, 22, 38},
    {5, 15, 25, 41},
    {2, 12, 23, 33, 43}
}

local yCords = {16, 18, 20, 22, 24, 26, 28}

local mCords = {
    {23},
    {18, 26},
    {14, 22, 30},
    {10, 18, 26, 34},
    {6, 14, 22, 30, 38},
    {3, 11, 19, 27, 35, 43}
}

--Settings--
local atm = "casino_1"
local bankSide = "back"
local monSide = "top"
local server = 6
local mainC = 5 --channel for sending stuff to the server--
local players = {10, 20, 30} --there should be a channel for every mirror client--
local drives = {"drive_3", "drive_2", "drive_4"} --there should be a drive name for every mirror client--

local buttons = {
    {"Stand", 16, 20}, --text, x, xend
    {"Hit", 25, 27},
    {"Double", 31, 36}
}

local button = {
    {"Stand", 20, colors.black, 18, 24},
    {"Hit", 28, colors.gray, 24, 28}
}

--Functions--
function balance(account, ATM, pin)
    local msg = {"bal", account, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "balR" then
        return mes[2], mes[3]
    end
    return false, "oof"
end

function deposit(account, amount, ATM, pin)
    local msg = {"dep", account, amount, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "depR" then
        return mes[2], mes[3]
    end
    return false, "oof"
end

function withdraw(account, amount, ATM, pin)
    local msg = {"wit", account, amount, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "witR" then
        return mes[2], mes[3], amount
    end
    return false, "oof"
end

function transfer(account, account2, amount, ATM, pin)
    local msg = {"tra", account, account2, amount, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "traR" then
        return mes[2], mes[3]
    end
    return false, "oof"
end

function clearRem(player)
    local msg = {"clear"}
    modem.transmit(player, mainC, msg)
end

function lineRem(y, player)
    local msg = {"line", y}
    modem.transmit(player, mainC, msg)
end

function backgroundRem(colour, player)
    local msg = {"background", colour}
    modem.transmit(player, mainC, msg)
end

function cursorRem(x, y, player)
    local msg = {"cursor", x, y}
    modem.transmit(player, mainC, msg)
end

function textRem(colour, player)
    local msg = {"text", colour}
    modem.transmit(player, mainC, msg)
end

function writeRem(text, player)
    local msg = {"write", text}
    modem.transmit(player, mainC, msg)
end

function picRem(picName, x, y, player)
    local msg = {"pic", picName, x, y}
    modem.transmit(player, mainC, msg)
end

function drawCardRem(x, y, char, suit, Cplayer)
    if (suit == "\5" or suit == "\6") then
        colour = colours.black
    else
        colour = colours.red
    end
    picRem("card", x, y, Cplayer)
    cursorRem(x + 1, y + 1, Cplayer)
    backgroundRem(1, Cplayer)
    textRem(colour, Cplayer)
    writeRem(char, Cplayer)
    cursorRem(x + 3, y + 3, Cplayer)
    writeRem(suit, Cplayer)
    if char == 10 then
        cursorRem(x + 4, y + 5, Cplayer)
    else
        cursorRem(x + 5, y + 5, Cplayer)
    end
    writeRem(char, Cplayer)
end

function clearScreenRem(idle, insert, Splayer)
    backgroundRem(colours.green, Splayer)
    clearRem(Splayer)
    cursorRem(1, 1, Splayer)
    textRem(colours.black, Splayer)
    writeRem("Blackjack Mirror OS ", Splayer)
    writeRem(vers, Splayer)
    cursorRem(1, 2, Splayer)
    textRem(colours.yellow, Splayer)
    writeRem("Made By Mavric, Please Report Bugs", Splayer)
    if (idle) then
        picRem("logo", 20, 4, Splayer)
        if (insert) then
            backgroundRem(colours.green, Splayer)
            cursorRem(17, 13, Splayer)
            writeRem("Please insert card", Splayer)
        end
    end
end

function drawBetRem(PIN, number, Bplayer)
    clearScreenRem(false, false, Bplayer)
    picRem("logo", 20, 4, Bplayer)
    backgroundRem(colours.green, Bplayer)
    textRem(colours.lime, Bplayer)
    cursorRem(1, 3, Bplayer)
    if (PIN) then
        writeRem("ID:", Bplayer)
    else
        writeRem("$", Bplayer)
    end
    writeRem(number, Bplayer)
    cursorRem(20, 13, Bplayer)
    textRem(1, Bplayer)
    if (PIN) then
        writeRem("PIN:", Bplayer)
    else
        writeRem("BET:", Bplayer)
    end
    drawX(Bplayer)
end

function checkX(x, y)
    if x == 49 and y == 17 then
        return true
    else
        return false
    end
end

function drawX(Xplayer)
    textRem(colors.white, Xplayer)
    backgroundRem(colours.red, Xplayer)
    cursorRem(49, 17, Xplayer)
    writeRem("X", Xplayer)
end

function clearScreen(insert)
    term.setBackgroundColour(colours.green)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColour(colours.black)
    term.write("Blackjack Mirror OS ")
    term.write(vers)
    term.setCursorPos(1, 2)
    term.setTextColour(colours.yellow)
    term.write("Made By Mavric, Please Report Bugs")
    if (insert) then
        local pic = paintutils.loadImage("/blackjackC/logo.nfp")
        paintutils.drawImage(pic, 20, 14)
        term.setBackgroundColour(colours.green)
        term.setCursorPos(17, 23)
        term.write("Please insert card")
    end
end

function drawCard(x, y, char, suit)
    if (suit == "\5" or suit == "\6") then
        colour = colours.black
    else
        colour = colours.red
    end
    local pic = paintutils.loadImage("/blackjackC/card.nfp")
    paintutils.drawImage(pic, x, y)
    term.setCursorPos(x + 1, y + 1)
    term.setBackgroundColour(1)
    term.setTextColor(colour)
    print(char)
    term.setCursorPos(x + 3, y + 3)
    print(suit)
    if char == 10 then
        term.setCursorPos(x + 4, y + 5)
    else
        term.setCursorPos(x + 5, y + 5)
    end
    print(char)
end

function drawBack(x, y)
    local pic = paintutils.loadImage("/blackjackC/cardBack.nfp")
    paintutils.drawImage(pic, x, y)
end

function drawButtons(double, bPlayer)
    backgroundRem(colors.green, bPlayer)
    textRem(colors.black, bPlayer)
    if (double) then
        for k, v in pairs(buttons) do
            cursorRem(v[2], 18, bPlayer)
            writeRem(v[1], bPlayer)
        end
    else
        for k, v in pairs(button) do
            cursorRem(v[2], 18, bPlayer)
            writeRem(v[1], bPlayer)
        end
    end
end

function drawScreen(sNum, dub, play)
    clearScreen(false)
    for k, v in pairs(cards.dealer) do
        drawCard(cords[table.maxn(cards.dealer)][k], 4, v[2], v[3])
    end
    for k, v in pairs(cards.player) do    
        for k2, v2 in pairs(cards.player[k]) do
            drawCard(pCords[table.maxn(players)][k], yCords[k2], v2[2], v2[3], v)
        end
    end
    if (play) then
        clearScreenRem(false, false, players[sNum])
        drawButtons(dub, players[sNum])
        for k, v in pairs(cards.player[sNum]) do
            drawCardRem(mCords[table.maxn(cards.player[sNum])][k], 10, v[2], v[3], players[sNum])
        end
    end
end

function getDrive(drive)
    for k, v in pairs(drives) do
        if v == drive then
            return true, k
        end
    end
    return false
end

function getPlayer(channel)
    for k, v in pairs(players) do
        if v == channel then
            return true, k
        end
    end
    return false
end

function pinpad(key)
    if (tonumber(key)) then
        if tonumber(key) == 259 then
            return true, 10
        elseif tonumber(key) == 257 then
            return true, 11
        elseif tonumber(key) >= 0 and tonumber(key) <= 9 then
            return true, tonumber(key)
        end
    end
    return false
end

function buttonClick(x, y, cDub)
    if (cDub) then
        for k, v in pairs(buttons) do
            if x >= v[2] and x <= v[3] and y == 18 then
                return true, k
            end
        end
    else
        for k, v in pairs(button) do
            if x >= v[2] and x <= v[3] and y == 18 then
                return true, k
            end
        end
    end
    return false
end

function getTotal(deck)
    local deckTotal = 0
    for k, v in pairs(deck) do
        deckTotal = deckTotal + v[1]
    end
    return deckTotal
end

function allStand()
    local total = {}
    for p, t in pairs(cards.player) do
        total[p] = getTotal(t)
    end
    
    local ress = {}
    
    for k, v in pairs(cards.player) do
        if total[k] > 21 then
            ress[k] = 10
        else
            ress[k] = 11
        end
    end
    
    local dTotal = getTotal(cards.dealer)
    
    while dTotal < 16 do
        num = math.random(1, table.maxn(cards.deck))
        card = cards.deck[num]
        table.remove(cards.deck, num)
        table.insert(cards.dealer, card)
        dTotal = getTotal(cards.dealer)
        drawScreen(0, false, false)
        if dTotal >= 21 then
            return true
        end
    end

    for k, v in pairs(cards.player) do
        if ress[k] == 11 then
            if total[k] > dTotal then
                ress[k] = 1
            elseif total[k] < dTotal then
                ress[k] = 2
            elseif total[k] == dTotal then
                ress[k] = 3
            else
                ress[k] = 0
            end
        end
    end
    return false, ress
end

--setup--
modem = peripheral.wrap("bottom")
modem.open(mainC)
rednet.open(bankSide)

--Betting setup--
local betting = {   --there should be a row of {false, false} for evey mirror client--
    {false, false, false, 0, 0}, --is betting, done betting, is pin, id, balance--
    {false, false, false, 0, 0},
    {false, false, false, 0, 0}
}

--there should be a {"", ""} for evey mirror client--
local text = {
    {"", ""}, --bet amount, pin--
    {"", ""},
    {"", ""}
}

m = peripheral.wrap(monSide)
term.redirect(m)
clearScreen(true)
for k, v in pairs(players) do
    clearScreenRem(true, true, v)
end

--Betting loop--
local loop = false --true
while (loop) do
    local isP = false
    local pNum = 0
    local tNum = 0
    local data = {os.pullEvent()}
    if data[1] == "disk" then
        isP, pNum = getDrive(data[2])
        if (isP) then
            local id = disk.getID(data[2])
            disk.eject(data[2])
            if id ~= nil then
                if betting[pNum][3] == false then
                    drawBetRem(true, id, players[pNum])
                    betting[pNum][3] = true
                    betting[pNum][4] = id
                end
            end
        end
    elseif data[1] == "modem_message" then
        isP, pNum = getPlayer(data[4])
        if (isP) then
            if data[5][1] == "mouse_click" then
                if (betting[pNum][3]) then
                    if (betting[pNum][2] == false) then
                        if (checkX(data[5][3], data[5][4])) then
                            betting[pNum][1] = false
                            betting[pNum][3] = false
                            betting[pNum][4] = 0
                            betting[pNum][5] = 0
                            text[pNum][1] = ""
                            text[pNum][2] = ""
                            clearScreenRem(true, true, players[pNum])
                        end
                    end
                end
            elseif data[5][1] == "char" or data[5][1] == "key" then
                if (betting[pNum][1]) then
                    if (betting[pNum][3]) then
                        if (betting[pNum][2] == false) then
                            local isKey, keyNum = pinpad(data[5][2])
                            if (isKey) then
                                if keyNum == 10 then
                                    if string.len(text[pNum][1]) > 0 then
                                        text[pNum][1] = string.sub(text[pNum][1], 1, string.len(text[pNum][1]) -1)
                                        backgroundRem(colours.green, players[pNum])
                                        textRem(1, players[pNum])
                                        lineRem(13, players[pNum])
                                        cursorRem(20, 13, players[pNum])
                                        writeRem("BET: ", players[pNum])
                                        writeRem(text[pNum][1], players[pNum])
                                    end
                                elseif keyNum == 11 then
                                    if string.len(text[pNum][1]) < 6 then
                                        if text[pNum][1] ~= "" then
                                            if (betting[pNum][5] >= tonumber(text[pNum][1]) and tonumber(text[pNum][1]) ~= 0) then
                                                --local suc, res = withdraw(tonumber(betting[pNum][4], tonumber(text[pNum][1]), atm, 
												tonumber(text[pNum][2])
                                                --withdraw amount using bank code
                                                betting[pNum][2] = true
                                                clearScreenRem(false, false, players[pNum])
                                                backgroundRem(colours.green, players[pNum])
                                                cursorRem(11, 13, players[pNum])
                                                writeRem("Your bet of $".. text[pNum][1].. " has been set", players[pNum])
                                                cursorRem(7, 14, players[pNum])
                                                writeRem("You cant undo this but if you walk away", players[pNum])
                                                cursorRem(14, 15, players[pNum])
                                                writeRem("your card wont be saved!", players[pNum])
                                                local endLoop = true
                                                for k, v in pairs(betting) do
                                                    if (v[2] == false) then
                                                        endLoop = false
                                                    end
                                                end
                                                if (endLoop) then
                                                    loop = false
                                                end
                                            else
                                                clearScreenRem(true, false, players[pNum])
                                                backgroundRem(colours.green, players[pNum])
                                                cursorRem(11, 13, players[pNum])
                                                if (tonumber(text[pNum][1]) == 0) then
                                                    writeRem("Must be more than zero!", players[pNum])
                                                else
                                                    writeRem("Must be enough money in your account!", players[pNum])
                                                end
                                                betting[pNum][1] = false
                                                betting[pNum][3] = false
                                                betting[pNum][4] = 0
                                                betting[pNum][5] = 0
                                                text[pNum][1] = ""
                                                text[pNum][2] = ""
                                                sleep(3)
                                                clearScreenRem(true, true, players[pNum])
                                            end
                                        end
                                    end
                                elseif keyNum >= 0 and keyNum <= 9 then
                                    if string.len(text[pNum][1]) < 5 then
                                        text[pNum][1] = text[pNum][1].. keyNum
                                        backgroundRem(colours.green, players[pNum])
                                        textRem(1, players[pNum])
                                        cursorRem(24 + string.len(text[pNum][1]), 13, players[pNum])
                                        writeRem(keyNum, players[pNum])
                                    end
                                end
                            end
                        end
                    end
                else
                    if (betting[pNum][3]) then
                        if (betting[pNum][2] == false) then
                            local isKey, keyNum = pinpad(data[5][2])
                            if (isKey) then
                                if keyNum == 10 then
                                    if string.len(text[pNum][2]) > 0 then
                                        text[pNum][2] = string.sub(text[pNum][2], 1, string.len(text[pNum][2]) -1)
                                        backgroundRem(colours.green, players[pNum])
                                        textRem(1, players[pNum])
                                        lineRem(13, players[pNum])
                                        cursorRem(20, 13, players[pNum])
                                        writeRem("PIN: ", players[pNum])
                                        writeRem(string.sub("****", 1, string.len(text[pNum][2])), players[pNum])
                                    end
                                elseif keyNum == 11 then
                                    if string.len(text[pNum][2]) == 5 then
                                        local suc, res = balance(betting[pNum][4], atm, text[pNum][2])
                                        if (suc) then
                                            betting[pNum][5] = tonumber(res)
                                            betting[pNum][1] = true
                                            drawBetRem(false, res, players[pNum])
                                        else
                                            betting[pNum][3] = false
                                            betting[pNum][4] = 0
                                            text[pNum][2] = ""
                                            clearScreenRem(true, false, players[pNum])
                                            backgroundRem(colours.green, players[pNum])
                                            cursorRem(11, 13, players[pNum])
                                            writeRem(res, players[pNum])
                                            sleep(3)
                                            clearScreenRem(true, true, players[pNum])
                                        end
                                    end
                                elseif keyNum >= 0 and keyNum <= 9 then
                                    if string.len(text[pNum][2]) < 5 then
                                        text[pNum][2] = text[pNum][2].. keyNum
                                        backgroundRem(colours.green, players[pNum])
                                        textRem(1, players[pNum])
                                        cursorRem(24 + string.len(text[pNum][2]), 13, players[pNum])
                                        writeRem("*", players[pNum])
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

--Mirror game function--
function mirrorGame(gPlayer, playerNum)
    clearScreenRem(false, false, gPlayer)
    local Du = false
    if (betting[playerNum][5] >= (tonumber(text[playerNum][1]) * 2)) then
        Du = true
    end
    num = math.random(1, table.maxn(cards.deck))
    card = cards.deck[num]
    table.remove(cards.deck, num)
    table.insert(cards.player[playerNum], card)
    
    num = math.random(1, table.maxn(cards.deck))
    card = cards.deck[num]
    table.remove(cards.deck, num)
    table.insert(cards.player[playerNum], card)
    drawScreen(playerNum, Du, true)
    
    loop = true
    while (loop) do
        local data = {os.pullEvent()}
        if data[1] == "modem_message" then
            if data[4] == players[playerNum] then
                isP, pNum = getPlayer(data[4])
                if (isP) then
                    if data[5][1] == "mouse_click" then
                        local click, butt = buttonClick(data[5][3], data[5][4], Du)
                        if butt == 1 then
                            return
                        elseif butt == 2 then
                            if table.maxn(cards.player[playerNum]) < 7 then
                                num = math.random(1, table.maxn(cards.deck))
                                card = cards.deck[num]
                                table.remove(cards.deck, num)
                                table.insert(cards.player[playerNum], card)
                                drawScreen(playerNum, Du, true)
                                
                                local total = getTotal(cards.player[playerNum])
                                if total > 21 then
                                    --Player bust--
                                    cursorRem(10, 4, playerNum)
                                    writeRem("Bust", playerNum)
                                    return
                                end
                                
                                if table.maxn(cards.player[playerNum]) > 6 then
                                    --Got 7 cards win out bust--
                                    return
                                end
                            end
                        elseif butt == 3 then
                            if table.maxn(cards.player[playerNum]) == 2 then
                                num = math.random(1, table.maxn(cards.deck))
                                card = cards.deck[num]
                                table.remove(cards.deck, num)
                                table.insert(cards.player[playerNum], card)
                                
                                drawScreen(playerNum, Du, true)
                                return
                            end
                        end
                    end
                end
            end
        end         
    end
end

--Main setup--
os.loadAPI("blackjackC/cards.lua")
clearScreen(false)

--Get dealers cards--
num = math.random(1, table.maxn(cards.deck))
card = cards.deck[num]
table.remove(cards.deck, num)
table.insert(cards.dealer, card)
 
num = math.random(1, table.maxn(cards.deck))
card = cards.deck[num]
table.remove(cards.deck, num)
table.insert(cards.dealer, card)

--Testing code so I dont have to do 3 bets every time--
for k, v in pairs(players) do
    betting[k][5] = 100
    text[k][1] = "10"
end

--Main loop--
for k, v in pairs(players) do
    mirrorGame(v, k)
end
local bust, res = allStand()
if (bust) then
    for k, v in pairs(players) do
        backgroundRem(colours.green, v)
        textRem(colours.black, v)
        cursorRem(18, 6, v)
        if res[k] == 10 then
            writeRem("Bust", v)
        elseif res[k] == 11 then
            writeRem("Dealer Bust", v)
        else
            writeRem("Error. Returning money", v)
        end
    end
    term.setBackgroundColor(colours.green)
    term.setTextColor(colors.black)
    term.setCursorPos(18, 10)
    write("Dealer bust")
else
    for k, v in pairs(players) do
        backgroundRem(colours.green, v)
        textRem(colours.black, v)
        cursorRem(18, 6, v)
        if res[k] == 0 then
            writeRem("Error. Returning money", v)
        elseif res[k] == 1 then
            textRem(colours.red, v)
            writeRem("Win", v)
        elseif res[k] == 2 then
            writeRem("Lose", v)
        elseif res[k] == 3 then
            writeRem("Push", v)
        elseif res[k] == 10 then
            writeRem("Bust", v)
        else
            writeRem("Error. Returning money", v)
        end
    end
end
