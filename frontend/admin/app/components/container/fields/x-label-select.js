import Ember from 'ember';

export default Ember.Component.extend({
  items: [
    Ember.Object.create({ id: 'commit',  label: 'Commit' }),
    Ember.Object.create({ id: 'engage', label: 'Engage' }),
    Ember.Object.create({ id: 'implement', label: 'Implement' })
  ]
});

