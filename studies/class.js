// Generated by CoffeeScript 1.4.0
(function() {
  var Base, Derived, b,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Base = (function() {
    var local;

    function Base() {
      1 + 3;
    }

    Base.foo = 10;

    Base.prototype.bar = 9;

    local = 7;

    Base.prototype.f = local;

    return Base;

  })();

  b = new Base;

  b.prototype = {
    x: 8
  };

  console.log(Base.foo, b.bar, b.prototype, b.x);

  Derived = (function(_super) {

    __extends(Derived, _super);

    function Derived() {
      return Derived.__super__.constructor.apply(this, arguments);
    }

    return Derived;

  })(Base);

}).call(this);