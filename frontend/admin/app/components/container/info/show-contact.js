import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'span',

  contacts: Ember.inject.service(),
  items: Ember.computed.oneWay('contacts.data'),

  //api
  contactId: null,

  contact: Ember.computed('items.@each', 'contactId', function() {
    return this.get('items').find( (i) => {
      return i.id === this.get('contactId');
    });
  }),

  contactName: Ember.computed.oneWay('contact.name'),

});

