{log, time, timeEnd} = console

funs = (require './functions').funs

{DateVal} = funs

bigDeal =
    'Product': 'FRA'
    "Currency": 'GBP'
    "Start Date": 1,
    "Rolls Type": 9,
    "IMM Stub At": 1,
    "Stub At": 3,
    "Float Notionals": 6,
    "Float Notionals 2": 6,
    "Amortising": 3,
    "Derived Start Date": DateVal 1, 1, 2013
    "Derived End Date": DateVal 1, 6, 2013
    "Trade Date": 1,
    "Fixing Date": 2,
    "Floating Rate Index": 'USD-LIBOR-BBA'
    "Zero Coupon Float": 3,
    "Floating Rate Index 2": 3,
    "Designated Maturity": 3,
    "Designated Maturity 2": 3,
    "FRA Discounting": 1,
    "Interp Index Tenor 1": 2,
    "Interp Index Tenor 2": 2,
    "Zero Coupon Float 2": 1,
    "Adjust Fixed Start Date": 1,
    "Derived Fixed Start Date": 1,
    "Adjust Float Start Date": 1,
    "Derived Float Start Date": 1,
    "Adjust Float Start Date 2": 1,
    "Derived Float Start Date 2": 1,
    "Contractual Definitions": 4,
    "Averaging Method": 1,
    "Averaging Method 2": 1,
    "Add'l Payment 1 Date": 2,
    "Additional Payment 1": 1,
    "Add'l Payment 2 Date": 2,
    "Additional Payment 2": 1,
    "Add'l Payment 3 Date": 2,
    "Additional Payment 3": 1,
    "Add'l Payment 4 Date": 2,
    "Additional Payment 4": 1,
    "Add'l Payment 5 Date": 2,
    "Additional Payment 5": 1,
    "Add'l Payment 6 Date": 2,
    "Additional Payment 6": 1,
    "Fixed Day Basis": 8,
    "Float Day Basis": 7,
    "Float Day Basis 2": 2,
    "Fixed Term Convention": 1,
    "Fixed Convention": 1,
    "Float Term Convention": 2,
    "Float Convention": 3,
    "Float Term Convention 2": 1,
    "Float Convention 2": 1,
    "Has Float Roll Stub": 1,
    "First Reg Float Roll Start": 1,
    "Last Reg Float Roll End": 1,
    "Has Float Roll Stub 2": 1,
    "First Reg Float Roll Start 2": 1,
    "Last Reg Float Roll End 2": 1,
    "Floating Rate Multiplier": 1,
    "Floating Rate Multiplier 2": 1,
    "Rate Cut-Off Days": 1,
    "Rate Cut-Off Days 2": 1,
    "Client Clearing Deal": 1,
    "Clearing House": 'LCHLGB22FCM'
    "First Fixing Different": true
    "First Fixing Different 2": true

lchFra =
    'Product': 'FRA'
    'Clearing House': 'LCHLGB22FCM'
    'Client Clearing Deal': true
    'Currency': 'USD'
    'Derived Start Date': Date.now()
    'Derived End Date': DateVal 1, 6, 2013
    'First Fixing Different': true
    'First Fixing Holiday Centres': ['GBLO']
    'Fixing Date': Date.now()
    'Fixing Days Offset': -2
    'Fixing Holiday Centres': ['GBLO']
    'Float Day Basis': 'ACT/365.FIXED'
    'Floating Rate Index': 'USD-LIBOR-BBA'
    'Float Convention': 'FOLL'
    'FRA Discounting': true
    'Notional': 80000000
    'Payment Holiday Centres': ['GBLO', 'USNY']
    'Trade Date': DateVal 1, 1, 2000

lchIrs =
    'Product': 'IRS'
    'Clearing House': 'LCHLGB22FCM'
    'Client Clearing Deal': true
    'Currency': 'USD'
    'Derived Start Date': Date.now()
    'Derived End Date': DateVal 1, 6, 2013
    'First Fixing Days Offset': -3
    'First Fixing Different': true
    'First Fixing Holiday Centres': ['GBLO']
    'Fixing Date': Date.now()
    'Fixing Days Offset': -2
    'Fixing Holiday Centres': ['GBLO']
    'Float Day Basis': 'ACT/365.FIXED'
    'Floating Rate Index': 'USD-LIBOR-BBA'
    'Float Convention': 'FOLL'
    'Float Term Convention': 'FOLL'
    'FRA Discounting': true
    'Notional': 80000000
    'Payment Holiday Centres': ['GBLO', 'USNY']
    'Payment Lag': 0
    'Roll Holiday Centres': ['GBLO', 'USNY']
    'Trade Date': DateVal 1, 1, 2000

eurexFra =
    'Product': 'FRA'
    'Clearing House': 'LCHLGB22FCM'
    'Client Clearing Deal': true
    'Contractual Definitions': 'ISDA2006'
    'Currency': 'USD'
    'Derived Start Date': Date.now()
    'Derived End Date': DateVal 1, 6, 2013
    'First Fixing Different': true
    'First Fixing Holiday Centres': ['GBLO']
    'Fixed Rate': 1.3
    'Fixing Date': Date.now()
    'Fixing Days Offset': -2
    'Fixing Holiday Centres': ['GBLO']
    'Float Day Basis': 'ACT/360'
    'Floating Rate Index': 'USD-LIBOR-BBA'
    'Float Convention': 'FOLL'
    'FRA Discounting': true
    'Notional': 80000000
    'Payment Holiday Centres': ['GBLO', 'USNY']
    'Trade Date': DateVal 1, 1, 2000

deals = [
    {
        'Product': 'FRA'
        'Clearing House': 'LCHLGB22FCM'
        'Client Clearing Deal': true
        'Currency': 'GBP'
        'Derived Start Date': Date.now()
        'Derived End Date': DateVal 1, 6, 2013
        'First Fixing Different': true
        'First Fixing Holiday Centres': ['GBLO']
        'Fixing Date': Date.now()
        'Fixing Days Offset': -2
        'Fixing Holiday Centres': ['GBLO']
        'Float Day Basis': 'ACT/365.FIXED'
        'Floating Rate Index': 'USD-LIBOR-BBA'
        'Float Convention': 'FOLL'
        'FRA Discounting': true
        'Notional': 80000000
        'Payment Holiday Centres': ['GBLO', 'USNY']
        'Trade Date': DateVal 1, 1, 2000
    }
    {
        Notional: 800000000
        Currency: 'USD'
        Product: 'IRS'
        'Fixing Holiday Centres': ['GBLO']
        'Clearing House':'LCHLGB22FCM'
    }
    { Notional: 2000, Currency: 'USD',  Product: 'FRA'}
    {
        Notional: 2000000,
        Currency: 'USD'
        Product: 'CDS Index'
        'Fixing Holiday Centres': [1, 2, 3]
    }
    {
        Notional: 2000000,
        Currency: 'USD'
        Product: 'CDS Matrix'
        'Fixing Holiday Centres': [1, 2, 3]
        'Ref Obl Tier': 'SNRFOR'
        'Private Clearing House': "ONBCHLEICEG"
        'Upfront Fee Amount': 2000000
    }
    lchFra
    eurexFra
    bigDeal
]


#iceD2d = require './rules/Clearing_House_ICED2D.rulebase'
#log iceD2d.sets
#log iceD2d.check deals[3]

#return 0


rulesByName = require "./rules"

    # CME:     require './rules/Clearing_House_CME.rulebase'
    # CMECE:   require './rules/Clearing_House_CMECE.rulebase'
    # CMEVCON: require './rules/Clearing_House_CMEVCON.rulebase'
    # EUREX:   require './rules/Clearing_House_EUREX.rulebase'
    # HKEX:    require './rules/Clearing_House_HKEX.rulebase'
    # ICE:     require './rules/Clearing_House_ICE.rulebase'
    # ICED2D:  require './rules/Clearing_House_ICED2D.rulebase'
    # IDCG:    require './rules/Clearing_House_IDCG.rulebase'
    # JSCC:    require './rules/Clearing_House_JSCC.rulebase'
    # KDPW:    require './rules/Clearing_House_KDPW.rulebase'
    # KRX:     require './rules/Clearing_House_KRX.rulebase'
    # SA:      require './rules/Clearing_House_LCH.SA.rulebase'
    # LCH:     require './rules/Clearing_House_LCH.rulebase'
    # LCHVCON: require './rules/Clearing_House_LCHVCON.rulebase'
    # NASDAQ:  require './rules/Clearing_House_NASDAQ.rulebase'
    # NONE:    require './rules/Clearing_House_NONE.rulebase'
    # OCC:     require './rules/Clearing_House_OCC.rulebase'
    # SGX:     require './rules/Clearing_House_SGX.rulebase'
    # TEST:    require './rules/Clearing_House_TEST.rulebase'

{
    CME, CMECE, CMEVCON, EUREX, HKEX, ICE, ICED2D, IDCG, JSCC, KDPW,
    KRX, SA, LCH, LCHVCON, NASDAQ, NONE, OCC, SGX, TEST
} = rulesByName

rules = (r for n, r of rulesByName)

log 'rules.length', rules.length
#log rules.OCC
#log OCC.check deals[4]
#
toUSec = (x) -> (x /1e9).toFixed 6 

time = (r, d, m) ->
    start = process.hrtime()
    log r.check d
    diff = process.hrtime(start)
    log m, toUSec diff[1]

time LCH, lchIrs, 'Time LCH IRS 1st'
return 0

time LCH, lchFra, 'Time LCH FRA 1st'
time LCH, lchFra, 'Time LCH FRA 2nd'
time LCH, lchFra, 'Time LCH FRA 3rd'
time LCH, lchFra, 'Time LCH FRA 4th'
time LCH, lchFra, 'Time LCH FRA 5th'
time LCH, lchFra, 'Time LCH FRA 6th'

time CME, lchFra, 'Time CME FRA 1st'

time EUREX, eurexFra, 'Time EUREX FRA 1st'
#return 0

time CME, lchFra, 'Time CME FRA 2nd'
time CME, lchFra, 'Time CME FRA 3rd'

for i in [1..10000]
    LCH.check lchFra

time LCH, lchFra, 'Time LCH FRA 1st'
    
    
#return 0

n = 1000

tn = deals.length * n * rules.length
log "#{deals.length} deals * #{rules.length} rules * #{n} iterations = #{tn}"

start = process.hrtime()

for i in [1..n]
    for d in deals
        for rb in rules
            r = rb.check d

diff = process.hrtime(start)

log "Time average over loop: #{toUSec (diff[0] * 1e9 + diff[1]) / tn}s"

time LCH, deals[0], 'Time LCH after loop:'
time LCH, bigDeal, 'Time LCH Big Deal 1st:'
time LCH, bigDeal, 'Time LCH Big Deal 2nd:'
time LCH, bigDeal, 'Time LCH Big Deal 3rd:'
time LCH, lchFra, 'Time LCH FRA 1st:'
time LCH, lchFra, 'Time LCH FRA 2nd:'
time LCH, lchFra, 'Time LCH FRA 3rd:'
time LCH, lchFra, 'Time LCH FRA 4th:'
time LCH, lchFra, 'Time LCH FRA 5th:'
time LCH, lchFra, 'Time LCH FRA 6th:'

#console.log r
