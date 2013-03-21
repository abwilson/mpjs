%{
    var log = console.log;
    var _log = function(){}

    var toObject = function(list)
    {
        var o = {};
        var i;
        for(i = 0; i < list.length; ++i)
        {
            o[list[i].name] = list[i].value;
        }
        return o;
    }
%}
%start listDef
%ebnf
%%

listDef: list ':' data '{' item* '}' {
    var o = toObject($5);
    log('exports["', $3, '"] = ', JSON.stringify(o, null, '    '));
 }
;

item: simple | complex
;

simple: name ':' data -> { name: $1, value: $3}
;

complex: value ':' data '{' simple* '}' -> { name: $3, value: toObject($5) }

;
%%
