import Ember from 'ember';

export default Ember.Component.extend({
  items: [
    Ember.Object.create({ id: 'none', label: 'None' }),
    Ember.Object.create({ id: 'light', label: 'Light' }),
    Ember.Object.create({ id: 'dark',  label: 'Dark' })
  ]
});
