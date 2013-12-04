#!/usr/bin/coffee

io = require 'socket.io-client'
_ = require 'underscore'

bingo = ['B', 'I', 'N', 'G', 'O']
state = 'lost'

snum = (n) -> if n < 10 then " #{n}" else "#{n}"
fnum = (j) -> if j.found then "[" + snum(j.n) + "]" else " " + snum(j.n) + " "

socket = io.connect 'ws://yahoobingo.herokuapp.com'
socket.on 'connect', ->

    card = {}

    socket.on 'card', (data) ->
        for i in bingo
            card[i] = ({n: j, found: false} for j in data.slots[i])

    socket.on 'number', (ball) ->
        m = ball.match /([BINGO])(\d+)/
        card[m[1]] = for j in card[m[1]]
            if j.found or j.n != +m[2] then j else {n: j.n, found: true}

        may = (m, cond) -> if cond.found then m+1 else m

        f = (->
            for i in bingo
                if 5 == _.reduce card[m[1]], ((m, i) -> may m, i), 0
                    return true

            for i in [0..4]
                if 5 == _.reduce bingo, ((m, j) -> may m, card[j][i]), 0
                    return true

            if 5 == _.reduce [0..4], ((m, j) -> may m, card[bingo[j]][j]), 0
                return true

            if 5 == _.reduce [0..4], ((m, j) -> may m, card[bingo[j]][4 - j]), 0
                return true

            false)()

        console.log "\n\nBALL: #{ball}\n"
        for i in bingo
            console.log(card[i].map(fnum).join(" "))
        if f
            console.log "Looks like you won."
            socket.emit 'bingo'

    socket.on 'win', -> state = 'won'
    socket.on 'lose', -> state = 'lost'

    socket.on 'disconnect', ->
        console.log "You appear to have #{state}."
        process.exit()

    socket.emit 'register',
        name: 'Elf M. Sternberg'
        email: 'elf.sternberg@gmail.com'
        url: 'https://github.com/elfsternberg/yahoobingo'
