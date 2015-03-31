import Ember from 'ember';
import titlecase from 'admin/lib/titlecase';

const TYPES = {
  'string':            true,
  'boolean':           true,
  'image-upload':      true,
  'hero-theme-select': true,
  'tile-color-select': true,
  'text':              true,
  'html':              true,
  'href':              true
};

export default Ember.Component.extend({
  label: null,
  type:  null,
  key:   null,
  scope: null,

  uid: Ember.computed(function() {
    return `x-field-${Ember.generateGuid()}`;
  }),

  fieldComponentName: Ember.computed('type', function() {
    var type = this.get('type');
    Ember.assert(`type "${type}" isn't in the list`, TYPES[type]);

    return `container/fields/x-${type}`;
  }),

  initializeComponent: function() {
    this._connectScope();
    this._initLabel();
  }.on('init'),

  _connectScope() {
    var defaultValue;
    var value;

    this.reopen({
      value: Ember.computed.alias(`scope.data.${this.get('key')}`)
    });

    defaultValue = this.get('default');
    value        = this.get('value');

    if (!defaultValue) {
      return;
    }

    if (!Ember.isNone(value)) {
      return;
    }

    if (('boolean' === this.get('type')) && Ember.isNone(defaultValue)) {
      defaultValue = false;
    }

    this.set('value', defaultValue);
  },

  _initLabel() {
    if (this.get('label')) {
      return;
    }

    this.set('label', titlecase(this.get('key')));
  }
});
