import Ember from 'ember';

export default Ember.Component.extend({
  items: [
    Ember.Object.create({ id: 'asc',  label: 'Ascending' }),
    Ember.Object.create({ id: 'desc', label: 'Descending' })
  ]
});

