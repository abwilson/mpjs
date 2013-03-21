log = console.log

o = a: 1, b: 2

log 'a' of o

prods = ["IRS","OIS","Basis Swap","FRA"]

log 'FRA' in (["IRS","OIS","Basis Swap","FRA","CDS Index","CDS Matrix"] ? [])


console.log "FRA" in prods

nope = undefined

console.log "FRA" in (nope ? [])
