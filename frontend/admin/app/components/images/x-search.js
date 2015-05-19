import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  isDisabled: false,

  //actions
  search: 'search',

  actions: {
    search() {
      this.sendAction('search', this.get('query'));
    }
  }
});
