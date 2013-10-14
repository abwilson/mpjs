RuleBase = require './rulebase'
log = console.log
{funs} = rb = new RuleBase(module)

type = do ->
  classToType = {}
  for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()

  (obj) ->
    strType = Object::toString.call(obj)
    classToType[strType] or "object"

funs.AddBusinessDays = (x, y) -> x + y
funs.BusinessDayDiff = (x, y) -> y - x

funs.ClearingHouse = -> @['Clearing House']

funs.DateAdd = ->

funs.DateVal = (d, m, y) -> Date.UTC y, m, d

funs.DayDiff = do ->
    millisInDay = 24 * 60 * 60 * 1000
    roundToDays = (ms) ->
        Math.floor (ms / millisInDay)
    (b, e) -> (roundToDays e) - (roundToDays b)

funs.Duration = (x) -> 10

funs.FormatDate = ->

funs.getList = do ->
    lists =
        'Clearing Houses': require('./list_clearing_houses')
        'Holidays Per Currency': []

    for n, l of lists
        if not l?
            log n 'undefined'

    (l) ->
        result = lists[l]
        # log "getting #{l}, #{result?}"
#        log result
        result

funs.GetListProperty = (list, key, property) ->
    # log "ListProperty key = #{key}, propert = #{property}"
    list[key]?[property]

funs.ListContains = (l, e) ->
    switch type l
        when 'array' then e of l
        when 'string' then l.indexOf e >= 0
        else false
        
# do ->
#     #
#     # Map from types to implementation for that type.
#     # 
#     impls =
#         array:  (l, e) -> e of l
#         string: (l, e) -> l.indexOf e >= 0

#     (l, e) -> impls[type l]?(l, e)
        
funs.Months = (x) -> 18

funs.NowGMT = -> Date.now()

funs.ProductType = -> @Product

funs.RatesProduct = do ->
    ratesProducts = ['IRS', 'FRA', 'OIS', 'Swaption']
    (p) -> p in ratesProducts
    
funs.ServerFunction = do ->
    impls =
        ClearingHouseOpeningHoursData: (cache, ch, date1, date2) -> []
        GetICEClearingHouseString: -> 'TODO'
        CheckCMEEligibilityRules: -> false

    (f, args...) ->
#        log "ServerFunction called for #{f}"
        impls[f] args...

funs.ServerFunction.isList = -> true        
funs.ServerFunction.isObject = -> true        

funs.Today = -> Date.now()

funs.Year = (x) -> new Date(x).getFullYear()

funs.ListToString = (x) -> x

funs.CDSM_NextStandardRollDate = ->
funs.ICE_GetCHStringFromProductWithLE = ->

funs.IMM = (attr) ->
    if @['IMM']
        @['IMM ' + attr]
    else
         @[attr]

funs.InStr = (string, substring) ->
    return -1 if not string?
    string.indexOf substring

    # log 'InStr', string, substring, ' = ', result
    # result


exports.funs = rb.funs




#
# Grepd from not found.
#
funs.AddlPaymentAvailableSlots = ->
funs.AddlPaymentCount = ->
funs.AnyAreMonthEnd = ->
funs.CME_GoodHolidayCentres = ->
funs.DerivSERVParticipantInvolved = ->
funs.EUREX_IndexFixingDays = ->
funs.EUREX_StubPeriod = ->
funs.EntityType = ->
funs.FieldCount = ->
funs.FindMinor = ->
funs.FindPrevious = ->
funs.GetPartySide = ->
funs.ICE_Eligibility_Rules = ->
funs.ICE_GetCHString = ->
funs.IsBlockLE = ->
funs.IsBroker = ->
funs.IsClearingMember = ->
funs.IsCreditProduct = ->
funs.IsMonthEnd = ->
funs.JSCC_EligibleProduct = ->
funs.JSCC_MandatoryHolidayCentres = ->
funs.KDPW_PaymentFreq = ->
funs.KDPW_PaymentFreq2 = ->
funs.LCH_AdditionalPaymentDateLag = ->
funs.Len = ->
funs.Lower = ->
funs.MEVID = ->
funs.MonthDiff = ->
funs.ParticipantsInteroperable = ->
funs.PartiesValidForClearingHouse = ->
funs.PrivateFundLE = ->
funs.SpotDate52 = ->
funs.SpotDays = ->

