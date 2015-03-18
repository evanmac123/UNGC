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
  scalar: true,
  label: null,

  connectValue: function() {
    var defaultValue;
    var value;

    this.reopen({
      value: Ember.computed.alias(`data.${this.get('key')}`)
    });

    defaultValue = this.get('default');
    value        = this.get('value');

    if (!defaultValue) {
      return;
    }

    if (!Ember.isNone(value)) {
      return;
    }

    if (this.get('type') === 'boolean' && Ember.isNone(defaultValue)) {
      defaultValue = false;
    }

    this.set('value', defaultValue);
  }.on('init'),

  initLabel: function() {
    if (this.get('label')) {
      return;
    }

    this.set('label', titlecase(this.get('key')));
  }.on('init'),

  uid: function() {
    return `x-field-${Ember.generateGuid()}`;
  }.property(),

  fieldComponentName: Ember.computed('type', function() {
    var type = this.get('type');

    Ember.assert(`type "${type}" isn't in the list`, TYPES[type]);

    return `container/fields/x-${type}`;
  })
});
