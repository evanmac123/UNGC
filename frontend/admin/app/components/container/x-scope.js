import Ember from 'ember';

export default Ember.Component.extend({
  data:  null,
  key:   null,
  array: false,
  scopeData: null,

  canVary: function() {
    var min = this.get('min');
    var max = this.get('max');

    if (!min && !max) {
      return true;
    }

    if (min !== max) {
      return true;
    }

    return false;
  }.property('min', 'max'),

  canAdd: function() {
    var max    = this.get('max');
    var length = this.get('scopeData.length');

    if (!max || !length) {
      return true;
    }

    if (length < max) {
      return true;
    }

    return false;
  }.property('max', 'scopeData.length'),

  cantAdd: Ember.computed.not('canAdd'),

  actions: {
    addElement() {
      if (!this.get('array')) {
        return;
      }

      var data = this.get('scopeData');

      if (data && this.get('canAdd')) {
        data.pushObject({});
      }
    }
  },

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
      this.set(prop, Ember.Object.create());
      return;
    }

    var min = this.get('min');
    var ary = [];
    var i;

    if (min) {
      for (i = 0; i < min; i++) {
        ary.push(Ember.Object.create());
      }
    }

    this.set(prop, ary);
  }.on('init')
});
