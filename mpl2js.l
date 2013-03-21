
%{
    var log = console.log;
    var _log = function(){}
%}

%%
\s+                 /* whitespace */

':'|'{'|'}'   return yytext

list|value  return yytext

.*/':'  return 'name'
.*     yytext = yytext.replace(/[ ]*/, ''); return 'data'
