%start All
%%

All: NL+  { console.log('Got All', $1); }
 ;

%%
