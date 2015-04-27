import Ember from 'ember';

export default Ember.Component.extend({
  items: [
    Ember.Object.create({ id: 'platform',  label: 'Platform' }),
    Ember.Object.create({ id: 'action', label: 'Action' }),
    Ember.Object.create({ id: 'implementation', label: 'Implementation' })
  ]
});

