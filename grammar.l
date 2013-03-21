ID [a-zA-Z_][a-zA-Z0-9_]*

INT \-?[0-9]+
NUM {INT}(\.[0-9]+)?

%x GetLine InRule InSet InRuleRef
%s GetNL InFunction

%{
    var log = console.log;
    log = function(){}
%}

%%

^\$.*\$:           /* RCS Tag */
/* In GetNL mode read NL as token. */
<GetNL>\ *[\r\n]+         this.popState(); return "newLine"

/* In GetLine mode read to end of line as a token. */
<GetLine>.*               this.popState(); yytext = yytext.replace(/\s*$/, ''); return "line"

/* Rule file constructs */
^function\:[ ]*           this.begin("InFunction"); return "functionKW"
<InFunction>\{            this.popState(); return yytext

^include\:[ ]*            this.begin("GetLine"); return "includeKW"

^\ *rule\:[ ]*            this.begin("InRule"); this.begin("GetLine"); return "ruleKW"
<InRule>\{                return yytext
<InRule>\s+                 /* whitespace */
<InRule>\![^=].*          {}

<InRule>^\ *message\:     this.begin("GetNL"); return "messageKW"
<InRule>^\ *require\:     this.begin("GetNL"); return "requireKW"

^set\:[ ]*                this.begin("InSet"); this.begin("GetLine"); return "setKW"
<InSet>^\ *applies\ if\:  this.begin("GetNL"); return "appliesIfKW"
<InSet>^\ *rule\:[ ]*     this.begin("InRuleRef"); this.begin("GetLine"); return "ruleKW"
<InSet>\s+                /* whitespace */
<InSet>\![^=].*           {}

<InRuleRef>.*\:[ ]*       this.begin("GetLine"); yytext = yytext.replace(/\:[ ]*/, ""); return "ruleVarName"
<InRuleRef>\s+            /* whitespace */
<InRuleRef>\![^=].*       {}

^\ *other\ side\:          this.begin("GetNL"); return "otherSideKW"
^\ *other\ side\ error\:   this.begin("GetNL"); return "otherSideErrorKW"

<InRule,InSet,InRuleRef>\{    return yytext
<InRule,InSet,InRuleRef>\}    this.popState(); return yytext

\}                 return "}"

\\\\       this.popState(); this.begin("INITIAL"); return "blockOpen"
'//'       this.popState(); return "blockClose"

\s+                 /* whitespace */

\![^=].*                {}

/* Operators */
':='|'[]'           return yytext
\*                  return "star"
[\+\-\*/]           return yytext
and|AND             return "and"
not|NOT             return "not"
or|OR               return "or"
is                  return "is"

/* Punctuation */
[\[\]\(\)\;:,\.]                    return yytext

\'([^\']|\'\')*\'  { yytext = yytext.slice(1, -1).replace(/''/, "'"); 
                     return 'SQSTRINGLITERAL'; }

\"([^\"]|\"\")*\"  { yytext = yytext.slice(1, -1).replace(/""/, "\""); 
                     return 'DQSTRINGLITERAL'; }

{NUM}     return 'number'

/* Functions translated into coffeescript builtins. */
/* FieldElement         return yytext */

/* Keywords */
(begin|end|if|then|else|until|while|do|case|default|for|repeat|switch)/[^a-zA-Z0-9_] return yytext

/* Types */
boolean|datetime|duration|string   return yytext

link\([^\)]+\)   yytext = yytext.slice(5, -1); return "link"
link\{[^\}]+\}   yytext = yytext.slice(5, -1); return "link"
money\({INT}\)   yytext = yytext.slice(6, -1); return "money"
numeric\({INT}\) yytext = yytext.slice(8, -1); return "numeric"
rate\({INT}\)    yytext = yytext.slice(5, -1); return "rate"

/* Array ops */
resize|size|append|prepend|remove|insert return yytext

/* Constants */
null|false|true|this  return yytext

/* <<EOF>>             { return "EOF"; } */

\$APPID|\$USER|\$MYSIDE|\$MAJORVERSION  return "sysAttr"
\$MINORVERSION|\$TRIGGER|\$N|\$STATE    return "sysAttr"

('#'|'?'|'@'){ID} return envvar

'$'[0-9]+         return "argument"

{ID}              return "identifier"

'<='|'!='|'<>'|'>='|'=='|'='|'>'|'<'  return "comparitor"

'{'[^}[:blank:]][^}\n]*'}'  yytext = yytext.slice(1, -1); return "attribute"

