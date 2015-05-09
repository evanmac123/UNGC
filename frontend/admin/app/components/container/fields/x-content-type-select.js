import Ember from 'ember';

export default Ember.Component.extend({
  items: [
    Ember.Object.create({ id: 0, label: 'default' }),
    Ember.Object.create({ id: 1, label: 'action' })
  ]
});

