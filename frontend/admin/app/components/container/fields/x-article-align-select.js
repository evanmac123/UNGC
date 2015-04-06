import Ember from 'ember';

export default Ember.Component.extend({
  items: [
    Ember.Object.create({ id: 'left', label: 'Left' }),
    Ember.Object.create({ id: 'center', label: 'Center' }),
    Ember.Object.create({ id: 'right',  label: 'Right' })
  ]
});
