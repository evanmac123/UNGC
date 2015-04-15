import Ember from 'ember';

export default Ember.Component.extend({
  sectors: Ember.inject.service(),

  _onInsertElement: function() {
    this.get('sectors.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement')
});
