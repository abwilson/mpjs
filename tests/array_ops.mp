function: foo()
{
  "a;b;c"
}

function: foo2()
{
  "1;2;3"
}

function: bar()
{
  string a[] := "foo;bar;wibble";
  string b[] := "foo;bar;wibble";

  string c := foo2();

  ListContains(foo(), 'a');
  ListContains(c, 2);
  ListContains("a;b;c", "a");

  a.resize 1;
  a.size;
  a.append 1;
  a.prepend 1;
  a.remove "foo";
  a.insert "blah"
}
