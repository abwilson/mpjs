rule: Not Amortising
{
    message: "Zow"
    require: not (HaveField("Amortising") and {Amortising})
}
