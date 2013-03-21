log = console.log

# log matches = '10;20;30;40;;60'.match /([^;]*)/g
# log JSON.stringify (i for i in '10;20;30;'.match /([^;]*)/g by 2)
# log JSON.stringify (x for x in [1, 2, 3, 4, 5, 6, 7, 8] by 2)


toArrayImp = (l) -> i for i in l.match /([^;]*)/g by 2

    
input = 'k1:v1:d1;k2:v2:d2;k3::d3;k4:v4:'

r = {}
for i in toArrayImp input
    [_, k, v, d] = i.match /([^:]*):([^:]*):([^;]*);?/
    r[k] = 
        value: v
        description: d

log r
    
    
# log match = input.match /([^:]*):([^:]*):([^;]*);?/
# log match.input

# log matches = (x for x in input.match /([^:]*):([^:]*):([^;]*);?/g )

#(;[^;]*)*/g
