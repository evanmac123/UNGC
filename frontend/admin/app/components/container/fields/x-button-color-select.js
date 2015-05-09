import Ember from 'ember';

export default Ember.Component.extend({
  items: [
    Ember.Object.create({id: 'dark-blue', label: 'Dark Blue'}),
    Ember.Object.create({id: 'blue', label: 'Blue'}),
    Ember.Object.create({id: 'light-blue', label: 'Light Blue'}),
    Ember.Object.create({id: 'dark-green', label: 'Dark Green'}),
    Ember.Object.create({id: 'green', label: 'Green'}),
    Ember.Object.create({id: 'light-green', label: 'Light Green'}),
    Ember.Object.create({id: 'dark-teal', label: 'Dark Teal'}),
    Ember.Object.create({id: 'orange', label: 'Orange'}),
    Ember.Object.create({id: 'dark-orange', label: 'Dark Orange'})
  ]
});

