import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'span',
  items: [],

  contacts: Ember.inject.service(),

  _onInsertElement: function() {
    this.get('contacts.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement'),

  //api
  contactId: null,

  contact: Ember.computed('items.[]', 'contactId', function() {
    return this.get('items').find( (i) => {
      return parseInt(i.get('id'),10) === this.get('contactId');
    });
  }),

  contactName: Ember.computed.oneWay('contact.name'),

});

