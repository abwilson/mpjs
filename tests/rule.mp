
rule: CDSIndex Valid Series
{
    message: "Only trades with an index series of 9 or greater can be cleared."
  require: \\
  {Index Series} >= 9
  //
}


rule: Stub Tenor
{
    message: "Stub Tenor must be greater than or equal to 1 week." 
    require: \\
    numeric(0) floatsp := EUREX_StubPeriod({Float Payment Periods});
    numeric(0) fixedsp := EUREX_StubPeriod({Fixed Payment Periods});    
    not {Has Any Stub} or {Stub At} != 'Start' or ( (floatsp == 0 or floatsp >= 7) and (fixedsp == 0 or fixedsp >= 7) )
    //
}
