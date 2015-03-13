import Ember from 'ember';

export default Ember.Component.extend({
  items: [
    Ember.Object.create({ id: 'light-blue',  label: 'Light Blue' }),
    Ember.Object.create({ id: 'light-green', label: 'Light Green' }),
    Ember.Object.create({ id: 'teal',        label: 'Teal' }),
    Ember.Object.create({ id: 'green',       label: 'Green' }),
    Ember.Object.create({ id: 'orange',      label: 'Orange' }),
    Ember.Object.create({ id: 'pastel-blue', label: 'Pastel Blue' })
  ]
});
