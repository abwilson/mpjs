function: _nullary()
{
  0
}

function: unary(string x)
{
  x
}

function: GetAdditionalPaymentTimeFrameError(numeric(0) payment; datetime date)
{
    datetime startDate := IMM("Start Date");
    datetime endDate := IMM("End Date");

    "Additional payment " + payment + " for " + date + 
        " is not eligible for clearing: the payment date must be between " + 
        startDate + " and " + endDate
}
  
