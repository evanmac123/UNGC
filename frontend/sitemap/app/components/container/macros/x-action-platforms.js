import Ember from 'ember';

export default Ember.Component.extend({
  actionPlatforms: Ember.inject.service(),

  _onInsertElement: function() {
    this.get('actionPlatforms.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement')
});
