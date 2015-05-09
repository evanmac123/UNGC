import Ember from 'ember';

export default Ember.Component.extend({
  items: [
    Ember.Object.create({ id: 'none',  label: 'None' }),
    Ember.Object.create({ id: 'pdf', label: 'Pdf' }),
    Ember.Object.create({ id: 'web', label: 'Website' }),
    Ember.Object.create({ id: 'video', label: 'Video' })
  ]
});

