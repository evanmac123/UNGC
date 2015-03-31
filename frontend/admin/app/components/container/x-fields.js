import Ember from 'ember';

var Scope = Ember.Object.extend({
  parentScope: null,
  errors: null,
  path: null,
  index: null,
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
  parent: null,
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
    var parent     = this.get('parent');
    var parentPath = parent.get('path');
    var source     = parent.get('data');
    var errors     = parent.get('errors');
    var path;

    if (Ember.isNone(index)) {
      path = parentPath ? `${parentPath}.${key}` : key;
    } else {
      path = parentPath ? `${parentPath}.${key}.[${index}]` : `${key}.[${index}]`;
    }

    return Scope.create({
      errors: errors,
      data: data,
      path: path,
      parentScope: parent
    });
  },

  connectParent: function() {
    var isArray    = this.get('array');
    var errors     = this.get('errors');
    var parentData = this.get('data');
    var key        = this.get('key');
    var parent     = this.get('parent');
    var parentPath;
    var source;
    var data;
    var yieldValue;
    var min;
    var fill;

    if (Ember.isNone(parent)) {
      if (Ember.isNone(parentData) || Ember.isNone(errors)) {
        throw 'unable to generate root scope without data and errors';
      } else {
        parent = Scope.create({
          errors: errors,
          data: parentData,
          path: null,
          parentScope: null
        });

        this.set('parent', parent);
      }
    } else if (Ember.isNone(key)) {
      throw 'unable to generate scope from parent data without a key';
    }

    source = parent.get('data');

    if (key && Ember.isNone(source.get(key))) {
      source.set(key, isArray ? [] : Ember.Object.create());
    }

    data = key ? source.get(key) : source;

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
