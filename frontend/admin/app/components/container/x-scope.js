import Ember from 'ember';

export default Ember.Component.extend({
  data:  null,
  key:   null,
  array: false,
  scopeData: null,

  initData: function() {
    var key     = this.get('key');
    var isArray = this.get('array');
    var prop    = key ? `data.${key}` : 'data';

    this.reopen({
      scopeData: Ember.computed.alias(prop)
    });

    if (this.get(prop)) {
      return;
    }

    if (!isArray) {
      this.set(prop, {});
      return;
    }

    var min = this.get('min');
    var ary = [];
    var i;

    if (min) {
      for (i = 0; i < min; i++) {
        ary.push({});
      }
    }

    this.set(prop, ary);
  }.on('init')
});
