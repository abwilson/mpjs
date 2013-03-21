asNum = (text) ->
    n = +text
    if text == '' or isNaN n
        console.log "text '#{text}'"
    else
        console.log 'n', n

console.log isNaN '10'        

asNum ''
asNum ' '
asNum '-10'

