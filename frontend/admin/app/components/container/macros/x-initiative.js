import Ember from 'ember';

export default Ember.Component.extend({
  initiatives: Ember.inject.service(),

  _onInsertElement: function() {
    this.get('initiatives.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement')
});
