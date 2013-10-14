lchIrs =
    "Product": "IRS"
    "Clearing House": "LCHLGB22FCM"
    "Client Clearing Deal": true
    "Currency": "USD"
    "Derived Start Date": Date.now()
    "Derived End Date": Date.UTC 2013, 1, 6
    "First Fixing Days Offset": -3
    "First Fixing Different": true
    "First Fixing Holiday Centres": ["GBLO"]
    "Fixing Date": Date.now()
    "Fixing Days Offset": -2
    "Fixing Holiday Centres": ["GBLO"]
    "Float Day Basis": "ACT/365.FIXED"
    "Floating Rate Index": "USD-LIBOR-BBA"
    "Float Convention": "FOLL"
    "Float Term Convention": "FOLL"
    "FRA Discounting": true
    "Notional": 80000000
    "Payment Holiday Centres": ["GBLO", "USNY"]
    "Payment Lag": 0
    "Roll Holiday Centres": ["GBLO", "USNY"]
    "Trade Date": Date.UTC 2000, 1, 1

console.log JSON.stringify lchIrs
