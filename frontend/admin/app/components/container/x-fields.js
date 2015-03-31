import Ember from 'ember';

var Scope = Ember.Object.extend({
  errors: null,
  path: null,
  data: null
});

function padArrayWithObjects(ary, size) {
  var i, fill;

  if (!size) {
    return;
  }

  fill = (size - ary.length);

  if (fill <= 0) {
    return;
  }

  for (i = 0; i < fill; i++) {
    ary.pushObject(Ember.Object.create());
  }
}

export default Ember.Component.extend({
  scope:  null,
  key:    null,
  array:  false,
  min:    null,
  max:    null,
  size:   null,

  canVary: function() {
    var min  = this.get('min');
    var max  = this.get('max');
    var size = this.get('size');

    if (size) {
      min = size;
      max = size;
    }

    if (!min && !max) {
      return true;
    }

    if (min !== max) {
      return true;
    }

    return false;
  }.property('min', 'max', 'size'),

  canAdd: function() {
    var max    = this.get('max');
    var length = this.get('yieldValue.length');

    if (!max || !length) {
      return true;
    }

    if (length < max) {
      return true;
    }

    return false;
  }.property('max', 'yieldValue.length'),

  cantAdd: Ember.computed.not('canAdd'),

  actions: {
    addElement() {
      if (!this.get('array')) {
        return;
      }

      var data = this.get('yieldValue');

      if (data && this.get('canAdd')) {
        data.pushObject(
          this.generateScope({
            data:  Ember.Object.create(),
            index: data.length
          })
        );
      }
    }
  },

  generateScope(data, index) {
    var key        = this.get('key');
    var parent     = this.get('scope');
    var parentPath = parent.get('path');
    var rootPath   = parentPath ? `${parentPath}.` : '';
    var myPath, fullPath;

    if (Ember.isNone(index)) {
      myPath = key ? key : '';
    } else {
      myPath = key ? `${key}.[${index}]` : `[${index}]`;
    }

    fullPath = rootPath + myPath;

    return Scope.create({
      errors: parent.get('errors'),
      data: data,
      path: fullPath === '' ? null : fullPath
    });
  },

  connectParent: function() {
    var isArray = this.get('array');
    var key     = this.get('key');
    var source  = this.get('scope.data');
    var data, yieldValue;

    if (key && Ember.isNone(Ember.get(source, key))) {
      Ember.set(source, key, isArray ? [] : Ember.Object.create());
    }

    data = key ? Ember.get(source, key) : source;

    if (isArray) {
      yieldValue = [];

      padArrayWithObjects(data, this.get('min') || this.get('size'));

      data.forEach((item, index) => {
        yieldValue.pushObject(this.generateScope(item, index));
      });
    } else {
      yieldValue = this.generateScope(data);
    }

    this.set('yieldValue', yieldValue);
  }.on('init')
});
