import Ember from 'ember';

var STORE_KEY_PREFIX  = 'ui-tree';
var STORE_KEY_DEFAULT = 'nodestates';

export default Ember.Component.extend({
  tagName: 'li',
  classNameBindings: 'isOpen:open:closed',

  actions: {
    toggle: function() {
      if (this.get('isOpen')) {
        this.set('isOpen', false);
      } else {
        this.set('isOpen', true);
      }

      this.saveState();
    }
  },

  storeKey: function() {
    return STORE_KEY_PREFIX + ':' + (this.get('ns') || STORE_KEY_DEFAULT);
  }.property('ns'),

  saveState: function() {
    var id    = this.get('node.id');
    var store = this.getStore();

    if (!id) {
      return;
    }

    store[id] = {
      isOpen: this.get('isOpen')
    };

    this.setStore(store);
  },

  loadState: function() {
    var id = this.get('node.id');
    var store = this.getStore();
    var state;

    if (!id) {
      return;
    }

    if (state = store[id]) {
      this.set('isOpen', state.isOpen ? true : false);
    }
  }.on('init'),

  getStore: function() {
    var storeKey = this.get('storeKey');
    var json;
    var store;

    if (!localStorage) {
      return;
    }

    if (json = localStorage.getItem(storeKey)) {
      store = JSON.parse(json);
    } else {
      store = {};
    }

    return store;
  },

  setStore: function(store) {
    var storeKey = this.get('storeKey');

    if (!localStorage) {
      return;
    }

    localStorage.setItem(storeKey, JSON.stringify(store));
  }
});
