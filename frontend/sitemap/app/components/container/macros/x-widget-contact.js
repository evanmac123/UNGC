import Ember from 'ember';

export default Ember.Component.extend({
  contacts: Ember.inject.service(),

  _onInsertElement: function() {
    this.get('contacts.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement')
});
