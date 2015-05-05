import Ember from 'ember';

export default Ember.Component.extend({
  resources: Ember.inject.service(),

  _onInsertElement: function() {
    this.get('resources.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement')
});
