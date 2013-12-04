#!/usr/bin/coffee

io = require 'socket.io-client'
util = require 'util'
socket = io.connect 'ws://yahoobingo.herokuapp.com'
_ = require 'underscore'

bingo = ['B', 'I', 'N', 'G', 'O']
state = 'lost'

fnum = (n) -> if n < 10 then " #{n}" else "#{n}"

socket.on 'connect', ->

    card = {}

    socket.on 'card', (data) ->
        for i in bingo
            card[i] = ({num: j, found: false} for j in data.slots[i])

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

        console.log "BALL: #{ball}"
        for i in bingo
            console.log((if j.found then '[#{fnum(j.n)}]' else ' #{fnum(j.n)} ' for j in card[i]).join(' '))
        if f
            console.log "Looks like you won."
            socket.emit 'bingo'

    socket.on 'win', -> state = 'won'
    socket.on 'lose', -> state = 'lost'

    socket.on 'disconnect', ->
        console.log "You appear to have #{state}"
        process.exit()

    socket.emit 'register',
        name: 'Ken Sternberg'
        email: 'sternberg@mailinator.com'
        url: ''
