// Generated by CoffeeScript 1.4.0
(function() {
  var Deal, Funs, o;

  Funs = (function() {

    function Funs() {}

    Funs.prototype.f = function() {
      return this.value;
    };

    return Funs;

  })();

  Deal = (function() {

    function Deal() {}

    Deal.prototype.value = 10;

    return Deal;

  })();

  o = new Deal;

  console.log(o.prototype = Funs.prototype);

  console.log(Deal.prototype);

  Deal.prototype = Funs.prototype;

  console.log(Deal.prototype);

  console.log(o.f());

}).call(this);
