import Ember from 'ember';
import titlecase from 'admin/lib/titlecase';

const TYPES = {
  'string':            true,
  'boolean':           true,
  'image-upload':      true,
  'hero-theme-select': true,
  'text':              true,
  'html':              true,
  'href':              true
};

export default Ember.Component.extend({
  scalar: true,
  label: null,

  connectValue: function() {
    this.reopen({
      value: Ember.computed.alias(`data.${this.get('key')}`)
    });
  }.on('init'),

  initLabel: function() {
    if (this.get('label')) {
      return;
    }

    this.set('label', titlecase(this.get('key')));
  }.on('init'),

  controlUID: function() {
    return `x-field-${Ember.generateGuid()}`;
  }.property(),

  fieldTemplatePath: Ember.computed('type', function() {
    var type = this.get('type');

    Ember.assert(`type "${type}" isn't in the list`, TYPES[type]);

    return `components/container/x-field/${type}`;
  })
});
